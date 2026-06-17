#!/usr/bin/env bash
set -euo pipefail

CHECK_AGENTS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-agents)
      CHECK_AGENTS=1
      shift
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

TARGET_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md}"

BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")
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

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  fail "missing source skills dir: $SRC_SKILLS_DIR"
fi

if [[ "$CHECK_AGENTS" -eq 1 && ! -f "$SRC_AGENTS_FILE" ]]; then
  fail "missing source AGENTS.md.root: $SRC_AGENTS_FILE"
fi

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

if [[ ! -d "$TARGET_SKILLS_DIR" ]]; then
  fail "target skills dir missing: $TARGET_SKILLS_DIR"
else
  pass "target skills dir exists: $TARGET_SKILLS_DIR"
fi

if [[ "$CHECK_AGENTS" -eq 1 ]]; then
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
  info "skip AGENTS check; use --check-agents to opt in"
fi

while IFS= read -r -d '' src; do
  name="$(skill_name_from_dir "$src")"
  if is_blacklisted "$name"; then
    continue
  fi
  dst="${TARGET_SKILLS_DIR}/${name}"
  if [[ ! -d "$dst" ]]; then
    fail "missing target skill: $name"
    continue
  fi

  rel_src="${src#${REPO_ROOT}/}"
  if [[ ! -L "$dst" ]]; then
    fail "target skill is not a symlink: $name ($dst)"
    continue
  fi

  resolved_dst="$(resolve_symlink_target "$dst" 2>/dev/null || true)"
  if [[ "$resolved_dst" != "$src" ]]; then
    fail "skill symlink target differs: $name ($rel_src)"
    echo "  expected: $src"
    echo "  actual:   ${resolved_dst:-<unresolved>}"
    continue
  fi

  if [[ ! -f "${resolved_dst}/SKILL.md" ]]; then
    fail "skill symlink target missing SKILL.md: $name ($resolved_dst)"
    continue
  fi

  if [[ -f "$dst/.managed-by-antarx-dev-skills" ]]; then
    fail "legacy managed marker exists in source-linked skill: $name"
  else
    pass "skill symlink valid: $name ($rel_src)"
  fi
done < <(find_source_skills)

if [[ "$FAIL" -ne 0 ]]; then
  info "doctor found issues"
  exit 1
fi

info "all checks passed"
