#!/usr/bin/env bash
set -euo pipefail

# Check only Codex/Claude global instruction links; skills are managed by npx skills.
CHECK_AGENTS=0
CHECK_CLAUDE=0
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${REPO_ROOT}/.env"
unset CODEX_AGENTS_FILE CODEX_DESIGN_FILE CLAUDE_AGENTS_FILE
CODEX_AGENTS_FILE=""
CODEX_DESIGN_FILE=""
CLAUDE_AGENTS_FILE=""

load_config() {
  local line key value
  [[ -f "$CONFIG_FILE" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
    if [[ "$line" != *=* ]]; then
      echo "Invalid .env entry (expected KEY=value): $line" >&2
      exit 2
    fi
    key="${line%%=*}"
    value="${line#*=}"
    case "$key" in
      CODEX_AGENTS_FILE|CODEX_DESIGN_FILE|CLAUDE_AGENTS_FILE)
        printf -v "$key" '%s' "$value"
        ;;
      *)
        echo "Unsupported .env key: $key" >&2
        exit 2
        ;;
    esac
  done < "$CONFIG_FILE"
}

load_config

TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md}"
TARGET_DESIGN_FILE="${CODEX_DESIGN_FILE:-$HOME/.codex/DESIGN.md}"
TARGET_CLAUDE_FILE="${CLAUDE_AGENTS_FILE:-$HOME/.claude/CLAUDE.md}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-agents) CHECK_AGENTS=1; shift ;;
    --check-claude) CHECK_CLAUDE=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

FAIL=0
check_link() {
  local target="$1"
  local source="$2"
  if [[ -L "$target" && "$target" -ef "$source" ]]; then
    echo "[PASS] $target -> $source"
  else
    echo "[FAIL] Expected a link to $source: $target" >&2
    FAIL=1
  fi
}

check_link "$TARGET_DESIGN_FILE" "${REPO_ROOT}/DESIGN.md"
if [[ "$CHECK_AGENTS" -eq 1 ]]; then
  check_link "$TARGET_AGENTS_FILE" "${REPO_ROOT}/AGENTS.root.md"
fi
if [[ "$CHECK_CLAUDE" -eq 1 ]]; then
  check_link "$TARGET_CLAUDE_FILE" "${REPO_ROOT}/AGENTS.root.md"
fi
exit "$FAIL"
