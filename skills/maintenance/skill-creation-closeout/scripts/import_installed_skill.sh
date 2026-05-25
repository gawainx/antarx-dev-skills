#!/usr/bin/env bash
set -euo pipefail

##
# Import one installed skill into the grouped antarx-dev-skills source tree.
# Inputs: skill name as $1 and category as $2.
# Outputs: copied source path on success.
##

if [[ $# -ne 2 ]]; then
  printf 'Usage: %s <skill-name> <category>\n' "$0" >&2
  exit 2
fi

SKILL_NAME="$1"
CATEGORY="$2"
LOCAL_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
SOURCE_SKILL="${LOCAL_SKILLS_DIR}/${SKILL_NAME}"
BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")

##
# Return success when the provided skill name is blacklisted.
##
is_blacklisted() {
  local name="$1"
  local item
  for item in "${BLACKLIST[@]}"; do
    if [[ "$name" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

##
# Resolve the antarx-dev-skills repository from cwd, env, or installed config.
##
resolve_repo() {
  if [[ -f "scripts/sync_to_local.sh" && -d "skills" ]]; then
    pwd
    return
  fi

  if [[ -n "${ANTARX_DEV_SKILLS_REPO:-}" ]]; then
    printf '%s\n' "$ANTARX_DEV_SKILLS_REPO"
    return
  fi

  local config="${LOCAL_SKILLS_DIR}/skill-improvement-ax/.skill-improvement-ax.env"
  if [[ -f "$config" ]]; then
    # shellcheck disable=SC1090
    source "$config"
    if [[ -n "${ANTARX_DEV_SKILLS_REPO:-}" ]]; then
      printf '%s\n' "$ANTARX_DEV_SKILLS_REPO"
      return
    fi
  fi

  printf 'Unable to resolve antarx-dev-skills repo path\n' >&2
  exit 3
}

##
# Extract the SKILL.md frontmatter name value.
##
frontmatter_name() {
  local skill_file="$1"
  local value
  value="$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed -n 's/^name:[[:space:]]*//p' | head -n 1)"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  printf '%s\n' "$value"
}

if is_blacklisted "$SKILL_NAME"; then
  printf 'Refusing to import blacklisted skill: %s\n' "$SKILL_NAME" >&2
  exit 4
fi

if [[ ! "$CATEGORY" =~ ^[a-z0-9-]+$ ]]; then
  printf 'Invalid category: %s\n' "$CATEGORY" >&2
  exit 4
fi

if [[ ! -f "${SOURCE_SKILL}/SKILL.md" ]]; then
  printf 'Installed skill missing: %s\n' "$SOURCE_SKILL" >&2
  exit 5
fi

declared_name="$(frontmatter_name "${SOURCE_SKILL}/SKILL.md")"
if [[ "$declared_name" != "$SKILL_NAME" ]]; then
  printf 'SKILL.md name mismatch: expected %s, got %s\n' "$SKILL_NAME" "$declared_name" >&2
  exit 6
fi

REPO_ROOT="$(resolve_repo)"
if [[ ! -f "${REPO_ROOT}/scripts/sync_to_local.sh" || ! -d "${REPO_ROOT}/skills" ]]; then
  printf 'Resolved path is not antarx-dev-skills: %s\n' "$REPO_ROOT" >&2
  exit 3
fi

TARGET_SKILL="${REPO_ROOT}/skills/${CATEGORY}/${SKILL_NAME}"
if [[ -e "$TARGET_SKILL" ]]; then
  printf 'Target skill already exists: %s\n' "$TARGET_SKILL" >&2
  exit 7
fi

mkdir -p "$(dirname "$TARGET_SKILL")"
if command -v rsync >/dev/null 2>&1; then
  rsync -a \
    --exclude '.managed-by-antarx-dev-skills' \
    --exclude '.skill-improvement-ax.env' \
    "$SOURCE_SKILL/" "$TARGET_SKILL/"
else
  cp -R "$SOURCE_SKILL" "$TARGET_SKILL"
  rm -f "${TARGET_SKILL}/.managed-by-antarx-dev-skills" "${TARGET_SKILL}/.skill-improvement-ax.env"
fi

printf '%s\n' "$TARGET_SKILL"
