#!/usr/bin/env bash
set -euo pipefail

##
# Verify that a managed skill's installed entry links to the source repository.
# Inputs: skill name as $1.
# Outputs: linked status or mismatch details.
##

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s <skill-name>\n' "$0" >&2
  exit 2
fi

SKILL_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
SOURCE_SKILL="$("${SCRIPT_DIR}/find_source_skill.sh" "$SKILL_NAME")"
LOCAL_SKILL="${LOCAL_SKILLS_DIR}/${SKILL_NAME}"

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

if [[ ! -d "$SOURCE_SKILL" ]]; then
  printf 'Source skill missing: %s\n' "$SOURCE_SKILL" >&2
  exit 3
fi

if [[ ! -d "$LOCAL_SKILL" ]]; then
  printf 'Local skill missing: %s\n' "$LOCAL_SKILL" >&2
  exit 3
fi

if [[ ! -L "$LOCAL_SKILL" ]]; then
  printf 'NOT_LINKED %s\n' "$SKILL_NAME" >&2
  printf 'Installed entry is not a symlink: %s\n' "$LOCAL_SKILL" >&2
  exit 1
fi

RESOLVED_LOCAL="$(resolve_symlink_target "$LOCAL_SKILL")"
if [[ "$RESOLVED_LOCAL" != "$SOURCE_SKILL" ]]; then
  printf 'LINK_MISMATCH %s\n' "$SKILL_NAME" >&2
  printf '  expected: %s\n' "$SOURCE_SKILL" >&2
  printf '  actual:   %s\n' "$RESOLVED_LOCAL" >&2
  exit 1
fi

printf 'LINKED %s %s\n' "$SKILL_NAME" "$SOURCE_SKILL"
