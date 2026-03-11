#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_SKILLS_DIR="${REPO_ROOT}/skills"
SRC_AGENTS_FILE="${REPO_ROOT}/AGENTS.md.root"

TARGET_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md.root}"

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

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  fail "missing source skills dir: $SRC_SKILLS_DIR"
fi

if [[ ! -f "$SRC_AGENTS_FILE" ]]; then
  fail "missing source AGENTS.md.root: $SRC_AGENTS_FILE"
fi

for bad in "${BLACKLIST[@]}"; do
  if [[ -e "${SRC_SKILLS_DIR}/${bad}" ]]; then
    fail "blacklisted skill exists in repo: ${SRC_SKILLS_DIR}/${bad}"
  else
    pass "blacklisted skill absent in repo: $bad"
  fi
done

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

if [[ ! -f "$TARGET_AGENTS_FILE" ]]; then
  fail "target AGENTS.md.root missing: $TARGET_AGENTS_FILE"
else
  if cmp -s "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE"; then
    pass "AGENTS.md.root is in sync"
  else
    fail "AGENTS.md.root differs from source: $TARGET_AGENTS_FILE"
  fi
fi

while IFS= read -r -d '' src; do
  name="$(basename "$src")"
  if is_blacklisted "$name"; then
    continue
  fi
  dst="${TARGET_SKILLS_DIR}/${name}"
  if [[ ! -d "$dst" ]]; then
    fail "missing target skill: $name"
    continue
  fi

  if diff -qr -x '.managed-by-antarx-dev-skills' "$src" "$dst" >/dev/null; then
    pass "skill in sync: $name"
  else
    fail "skill differs: $name"
  fi
done < <(find "$SRC_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ "$FAIL" -ne 0 ]]; then
  info "doctor found issues"
  exit 1
fi

info "all checks passed"
