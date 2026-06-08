#!/usr/bin/env bash
set -euo pipefail

##
# Resolve and validate the antarx-dev-skills source repository path.
# Inputs: none.
# Outputs: prints the absolute source repository path.
##

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO="$(cd "${SCRIPT_DIR}/../../../.." && pwd -P)"

if [[ ! -d "$SOURCE_REPO" ]]; then
  printf 'Resolved repo does not exist: %s\n' "$SOURCE_REPO" >&2
  exit 3
fi

if [[ ! -d "${SOURCE_REPO}/.git" ]]; then
  printf 'Resolved path is not a git repo: %s\n' "$SOURCE_REPO" >&2
  exit 3
fi

if [[ ! -d "${SOURCE_REPO}/skills" || ! -f "${SOURCE_REPO}/scripts/sync_to_local.sh" ]]; then
  printf 'Resolved repo is not an antarx-dev-skills checkout: %s\n' "$SOURCE_REPO" >&2
  exit 3
fi

printf '%s\n' "$SOURCE_REPO"
