#!/usr/bin/env bash
set -euo pipefail

##
# Locate a managed skill directory in the source repository.
# Inputs: skill name as $1.
# Outputs: absolute source skill path.
##

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s <skill-name>\n' "$0" >&2
  exit 2
fi

SKILL_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO="$("${SCRIPT_DIR}/resolve_source_repo.sh")"
SOURCE_SKILLS_DIR="${SOURCE_REPO}/skills"

MATCHES=()
while IFS= read -r -d '' skill_file; do
  skill_dir="$(dirname "$skill_file")"
  if [[ "$(basename "$skill_dir")" == "$SKILL_NAME" ]]; then
    MATCHES+=("$skill_dir")
  fi
done < <(find "$SOURCE_SKILLS_DIR" -mindepth 2 -name SKILL.md -type f -print0 | sort -z)

case "${#MATCHES[@]}" in
  0)
    printf 'Source skill missing: %s under %s\n' "$SKILL_NAME" "$SOURCE_SKILLS_DIR" >&2
    exit 3
    ;;
  1)
    printf '%s\n' "${MATCHES[0]}"
    ;;
  *)
    printf 'Multiple source skills named %s:\n' "$SKILL_NAME" >&2
    printf '  %s\n' "${MATCHES[@]}" >&2
    exit 4
    ;;
esac
