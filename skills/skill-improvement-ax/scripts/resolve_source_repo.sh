#!/usr/bin/env bash
set -euo pipefail

##
# Resolve and validate the antarx-dev-skills source repository path.
# Inputs: optional AX_CONFIG_FILE; otherwise uses ../.skill-improvement-ax.env.
# Outputs: prints the absolute source repository path.
##

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${AX_CONFIG_FILE:-${SKILL_DIR}/.skill-improvement-ax.env}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Missing config file: %s\n' "$CONFIG_FILE" >&2
  exit 2
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ -z "${ANTARX_DEV_SKILLS_REPO:-}" ]]; then
  printf 'ANTARX_DEV_SKILLS_REPO is not set in %s\n' "$CONFIG_FILE" >&2
  exit 2
fi

if [[ ! -d "$ANTARX_DEV_SKILLS_REPO" ]]; then
  printf 'Configured repo does not exist: %s\n' "$ANTARX_DEV_SKILLS_REPO" >&2
  exit 3
fi

if [[ ! -d "${ANTARX_DEV_SKILLS_REPO}/.git" ]]; then
  printf 'Configured path is not a git repo: %s\n' "$ANTARX_DEV_SKILLS_REPO" >&2
  exit 3
fi

if [[ ! -d "${ANTARX_DEV_SKILLS_REPO}/skills" || ! -f "${ANTARX_DEV_SKILLS_REPO}/scripts/sync_to_local.sh" ]]; then
  printf 'Configured repo is not an antarx-dev-skills checkout: %s\n' "$ANTARX_DEV_SKILLS_REPO" >&2
  exit 3
fi

printf '%s\n' "$ANTARX_DEV_SKILLS_REPO"
