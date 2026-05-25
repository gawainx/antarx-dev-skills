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
  if diff -qr -x '.managed-by-antarx-dev-skills' -x '.skill-improvement-ax.env' "$src" "$dst" >/dev/null; then
    pass "skill in sync: $name ($rel_src)"
  else
    fail "skill differs: $name ($rel_src)"
  fi
done < <(find_source_skills)

if [[ "$FAIL" -ne 0 ]]; then
  info "doctor found issues"
  exit 1
fi

info "all checks passed"
