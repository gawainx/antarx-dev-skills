#!/usr/bin/env bash
set -euo pipefail

CHECK_AGENTS=0
# Default: verify every supported agent. Override with --targets or ANTARX_SKILL_TARGETS.
TARGETS_SPEC="${ANTARX_SKILL_TARGETS:-all}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-agents)
      CHECK_AGENTS=1
      shift
      ;;
    --targets)
      if [[ $# -lt 2 ]]; then
        echo "--targets requires a comma-separated list (codex,grok,claude) or all" >&2
        exit 2
      fi
      TARGETS_SPEC="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_SKILLS_DIR="${REPO_ROOT}/skills"
SRC_AGENTS_FILE="${REPO_ROOT}/AGENTS.md.root"
PLUGIN_MANIFEST="${REPO_ROOT}/.claude-plugin/plugin.json"

CODEX_SKILLS_DIR_RESOLVED="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
GROK_SKILLS_DIR_RESOLVED="${GROK_SKILLS_DIR:-$HOME/.grok/skills}"
CLAUDE_SKILLS_DIR_RESOLVED="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md}"

BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")
CODEX_ONLY_SKILLS=(
  "skill-creation-closeout"
  "skill-improvement-ax"
  "workflow-review-packager"
)
FAIL=0

info() { echo "[doctor] $*"; }
pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*"; FAIL=1; }

is_blacklisted() {
  local name="$1"
  local x
  for x in "${BLACKLIST[@]}"; do
    if [[ "$name" == "$x" ]]; then
      return 0
    fi
  done
  return 1
}

is_codex_only_skill() {
  local name="$1"
  local x
  for x in "${CODEX_ONLY_SKILLS[@]}"; do
    if [[ "$name" == "$x" ]]; then
      return 0
    fi
  done
  return 1
}

skill_allowed_for_target() {
  local name="$1"
  local target="$2"
  if is_codex_only_skill "$name" && [[ "$target" != "codex" ]]; then
    return 1
  fi
  return 0
}

##
# Print the absolute target path for a symlink.
##
resolve_symlink_target() {
  local link_path="$1"
  local target
  target="$(readlink "$link_path")"
  (
    cd "$(dirname "$link_path")"
    cd "$(dirname "$target")"
    printf '%s/%s\n' "$(pwd -P)" "$(basename "$target")"
  )
}

##
# Print the install skill name for a source skill directory.
##
skill_name_from_dir() {
  basename "$1"
}

##
# Print source skill directories that contain SKILL.md, separated by NUL bytes.
##
find_source_skills() {
  find "$SRC_SKILLS_DIR" -mindepth 2 -name SKILL.md -type f -print0 \
    | while IFS= read -r -d '' skill_file; do
        printf '%s\0' "$(dirname "$skill_file")"
      done \
    | sort -z
}

##
# Expand TARGETS_SPEC into the global TARGETS array.
##
parse_targets() {
  local raw item
  TARGETS=()
  raw="$(printf '%s' "$TARGETS_SPEC" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  if [[ -z "$raw" ]]; then
    echo "Empty --targets / ANTARX_SKILL_TARGETS value" >&2
    exit 2
  fi
  if [[ "$raw" == "all" ]]; then
    TARGETS=("codex" "grok" "claude")
    return
  fi
  IFS=',' read -r -a TARGETS <<< "$raw"
  if [[ "${#TARGETS[@]}" -eq 0 ]]; then
    echo "No install targets resolved from: $TARGETS_SPEC" >&2
    exit 2
  fi
  for item in "${TARGETS[@]}"; do
    case "$item" in
      codex|grok|claude) ;;
      *)
        echo "Unknown install target: $item (expected codex, grok, claude, or all)" >&2
        exit 2
        ;;
    esac
  done
}

skills_dir_for_target() {
  case "$1" in
    codex) printf '%s\n' "$CODEX_SKILLS_DIR_RESOLVED" ;;
    grok) printf '%s\n' "$GROK_SKILLS_DIR_RESOLVED" ;;
    claude) printf '%s\n' "$CLAUDE_SKILLS_DIR_RESOLVED" ;;
    *)
      echo "Unknown target: $1" >&2
      return 1
      ;;
  esac
}

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

##
# Report duplicate source skill names that would collide during flat install.
##
check_duplicate_source_skills() {
  local seen=()
  local src name existing
  while IFS= read -r -d '' src; do
    name="$(skill_name_from_dir "$src")"
    if [[ "${#seen[@]}" -gt 0 ]]; then
      for existing in "${seen[@]}"; do
        if [[ "$existing" == "$name" ]]; then
          fail "duplicate source skill name: $name"
        fi
      done
    fi
    seen+=("$name")
  done < <(find_source_skills)
}

##
# Print plugin manifest skill paths, one per line.
##
plugin_skill_paths() {
  python3 - "$PLUGIN_MANIFEST" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
try:
    data = json.loads(manifest_path.read_text())
except Exception as exc:
    print(f"invalid plugin manifest JSON: {exc}", file=sys.stderr)
    sys.exit(1)

name = data.get("name")
if not isinstance(name, str) or not name.strip():
    print("plugin manifest must contain a non-empty string name", file=sys.stderr)
    sys.exit(1)

skills = data.get("skills")
if not isinstance(skills, list):
    print("plugin manifest must contain a skills array", file=sys.stderr)
    sys.exit(1)

for skill_path in skills:
    if not isinstance(skill_path, str):
        print("plugin manifest skills entries must be strings", file=sys.stderr)
        sys.exit(1)
    print(skill_path)
PY
}

##
# Report plugin manifest entries that cannot be installed by skills.sh.
##
check_plugin_manifest() {
  if [[ ! -f "$PLUGIN_MANIFEST" ]]; then
    fail "missing plugin manifest: ${PLUGIN_MANIFEST#${REPO_ROOT}/}"
    return
  fi

  local paths
  if ! paths="$(plugin_skill_paths 2>&1)"; then
    fail "$paths"
    return
  fi

  pass "plugin manifest JSON valid: ${PLUGIN_MANIFEST#${REPO_ROOT}/}"

  local seen=()
  local manifest_path abs_path skill_file name existing
  while IFS= read -r manifest_path; do
    [[ -n "$manifest_path" ]] || continue
    if [[ "$manifest_path" != ./* ]]; then
      fail "plugin skill path must be repo-relative with ./ prefix: $manifest_path"
      continue
    fi

    abs_path="${REPO_ROOT}/${manifest_path#./}"
    if [[ ! -d "$abs_path" ]]; then
      fail "plugin skill path missing directory: $manifest_path"
      continue
    fi

    skill_file="${abs_path}/SKILL.md"
    if [[ ! -f "$skill_file" ]]; then
      fail "plugin skill path missing SKILL.md: $manifest_path"
      continue
    fi

    name="$(skill_name_from_dir "$abs_path")"
    if is_blacklisted "$name"; then
      fail "plugin manifest includes blacklisted skill: $name"
      continue
    fi

    if [[ "${#seen[@]}" -gt 0 ]]; then
      for existing in "${seen[@]}"; do
        if [[ "$existing" == "$manifest_path" ]]; then
          fail "plugin manifest duplicate path: $manifest_path"
        fi
      done
    fi
    seen+=("$manifest_path")

    if ! grep -Eq '^name:[[:space:]]*"?'"$name"'"?[[:space:]]*$' "$skill_file"; then
      fail "plugin skill frontmatter name does not match directory: $manifest_path"
      continue
    fi

    if ! grep -Eq '^description:[[:space:]]*.+' "$skill_file"; then
      fail "plugin skill missing frontmatter description: $manifest_path"
      continue
    fi

    pass "plugin skill valid: $manifest_path"
  done <<< "$paths"
}

##
# Verify managed symlinks for one agent install root.
##
check_target_installs() {
  local agent="$1"
  local target_dir
  local src name dst rel_src resolved_dst
  local expected_count=0
  local ok_count=0

  target_dir="$(skills_dir_for_target "$agent")"
  info "[$agent] checking install root: $target_dir"

  if [[ ! -d "$target_dir" ]]; then
    fail "[$agent] target skills dir missing: $target_dir"
    return
  fi
  pass "[$agent] target skills dir exists: $target_dir"

  while IFS= read -r -d '' src; do
    name="$(skill_name_from_dir "$src")"
    if is_blacklisted "$name"; then
      continue
    fi
    if ! skill_allowed_for_target "$name" "$agent"; then
      dst="${target_dir}/${name}"
      if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ ! -L "$dst" && -f "${dst}/.managed-by-antarx-dev-skills" ]]; then
          fail "[$agent] codex-only skill still present as legacy managed copy: $name"
        elif [[ -L "$dst" ]]; then
          fail "[$agent] codex-only skill should not be installed here: $name"
        else
          info "[$agent] unmanaged entry named like codex-only skill left alone: $name"
        fi
      else
        pass "[$agent] codex-only skill correctly absent: $name"
      fi
      continue
    fi

    expected_count=$((expected_count + 1))
    dst="${target_dir}/${name}"
    if [[ ! -e "$dst" && ! -L "$dst" ]]; then
      fail "[$agent] missing target skill: $name"
      continue
    fi

    rel_src="${src#${REPO_ROOT}/}"
    if [[ ! -L "$dst" ]]; then
      fail "[$agent] target skill is not a symlink: $name ($dst)"
      continue
    fi

    resolved_dst="$(resolve_symlink_target "$dst" 2>/dev/null || true)"
    if [[ "$resolved_dst" != "$src" ]]; then
      fail "[$agent] skill symlink target differs: $name ($rel_src)"
      echo "  expected: $src"
      echo "  actual:   ${resolved_dst:-<unresolved>}"
      continue
    fi

    if [[ ! -f "${resolved_dst}/SKILL.md" ]]; then
      fail "[$agent] skill symlink target missing SKILL.md: $name ($resolved_dst)"
      continue
    fi

    if [[ -f "$dst/.managed-by-antarx-dev-skills" ]]; then
      fail "[$agent] legacy managed marker exists in source-linked skill: $name"
      continue
    fi

    ok_count=$((ok_count + 1))
    pass "[$agent] skill symlink valid: $name ($rel_src)"
  done < <(find_source_skills)

  info "[$agent] ${ok_count}/${expected_count} portable/managed skills verified"
}

parse_targets

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  fail "missing source skills dir: $SRC_SKILLS_DIR"
fi

if [[ "$CHECK_AGENTS" -eq 1 && ! -f "$SRC_AGENTS_FILE" ]]; then
  fail "missing source AGENTS.md.root: $SRC_AGENTS_FILE"
fi

info "targets: ${TARGETS[*]}"

for bad in "${BLACKLIST[@]}"; do
  if find "$SRC_SKILLS_DIR" -type d -name "$bad" -exec test -f '{}/SKILL.md' ';' -print -quit | grep -q .; then
    fail "blacklisted skill exists in repo: $bad"
  else
    pass "blacklisted skill absent in repo: $bad"
  fi
done

check_duplicate_source_skills
check_plugin_manifest

BROKEN_LINKS="$(find "$SRC_SKILLS_DIR" -xtype l 2>/dev/null || true)"
if [[ -n "$BROKEN_LINKS" ]]; then
  fail "broken symlink(s) found in source skills"
  echo "$BROKEN_LINKS"
else
  pass "no broken symlink in source skills"
fi

if [[ "$CHECK_AGENTS" -eq 1 ]]; then
  if array_contains "codex" "${TARGETS[@]}"; then
    if [[ ! -f "$TARGET_AGENTS_FILE" ]]; then
      fail "target AGENTS file missing: $TARGET_AGENTS_FILE"
    else
      if cmp -s "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE"; then
        pass "AGENTS file is in sync"
      else
        fail "AGENTS file differs from source: $TARGET_AGENTS_FILE"
      fi
    fi
  else
    info "skip AGENTS check; codex is not among targets"
  fi
else
  info "skip AGENTS check; use --check-agents to opt in"
fi

for agent in "${TARGETS[@]}"; do
  check_target_installs "$agent"
done

if [[ "$FAIL" -ne 0 ]]; then
  info "doctor found issues"
  exit 1
fi

info "all checks passed"
