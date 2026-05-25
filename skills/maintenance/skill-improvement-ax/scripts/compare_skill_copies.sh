#!/usr/bin/env bash
set -euo pipefail

##
# Compare a managed skill in the source repository with the installed local copy.
# Inputs: skill name as $1.
# Outputs: diff summary or an in-sync message.
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

if [[ ! -d "$SOURCE_SKILL" ]]; then
  printf 'Source skill missing: %s\n' "$SOURCE_SKILL" >&2
  exit 3
fi

if [[ ! -d "$LOCAL_SKILL" ]]; then
  printf 'Local skill missing: %s\n' "$LOCAL_SKILL" >&2
  exit 3
fi

if diff -qr \
  -x '.managed-by-antarx-dev-skills' \
  -x '.skill-improvement-ax.env' \
  "$SOURCE_SKILL" "$LOCAL_SKILL" >/dev/null; then
  printf 'IN_SYNC %s\n' "$SKILL_NAME"
else
  printf 'DIFF %s\n' "$SKILL_NAME"
  diff -qr \
    -x '.managed-by-antarx-dev-skills' \
    -x '.skill-improvement-ax.env' \
    "$SOURCE_SKILL" "$LOCAL_SKILL"
  exit 1
fi
