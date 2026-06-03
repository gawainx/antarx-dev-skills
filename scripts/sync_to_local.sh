#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
SYNC_AGENTS=0
FORCE_AGENTS=0
SKIP_SHELL_ENV=0
CODEX_MEMORY_DIR_CONFIG="${CODEX_MEMORY_DIR:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --sync-agents)
      SYNC_AGENTS=1
      shift
      ;;
    --force-agents)
      FORCE_AGENTS=1
      shift
      ;;
    --skip-shell-env)
      SKIP_SHELL_ENV=1
      shift
      ;;
    --codex-memory-dir)
      if [[ $# -lt 2 ]]; then
        echo "--codex-memory-dir requires a path" >&2
        exit 2
      fi
      CODEX_MEMORY_DIR_CONFIG="$2"
      shift 2
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

MANIFEST_FILE="${TARGET_SKILLS_DIR}/.antarx-managed-skills"
BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")
SKILL_IMPROVEMENT_AX_CONFIG="${TARGET_SKILLS_DIR}/skill-improvement-ax/.skill-improvement-ax.env"
ENV_BLOCK_BEGIN="# >>> antarx-dev-skills env >>>"
ENV_BLOCK_END="# <<< antarx-dev-skills env <<<"

log() { echo "[sync] $*"; }

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

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

shell_quote() {
  printf '%q' "$1"
}

shell_export_line() {
  local name="$1"
  local value="$2"
  printf 'export %s=%s\n' "$name" "$(shell_quote "$value")"
}

detect_shell_rc_file() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    zsh)
      printf '%s\n' "$HOME/.zshrc"
      ;;
    bash)
      printf '%s\n' "$HOME/.bashrc"
      ;;
    fish)
      printf '%s\n' "$HOME/.config/fish/config.fish"
      ;;
    *)
      return 1
      ;;
  esac
}

print_shell_env_commands() {
  shell_export_line "ANTARX_DEV_SKILLS_REPO" "$REPO_ROOT"
  shell_export_line "CODEX_SKILLS_DIR" "$TARGET_SKILLS_DIR"
  shell_export_line "CODEX_AGENTS_FILE" "$TARGET_AGENTS_FILE"
  if [[ -n "$CODEX_MEMORY_DIR_CONFIG" ]]; then
    shell_export_line "CODEX_MEMORY_DIR" "$CODEX_MEMORY_DIR_CONFIG"
  fi
}

print_fish_env_commands() {
  printf 'set -gx ANTARX_DEV_SKILLS_REPO %s\n' "$(shell_quote "$REPO_ROOT")"
  printf 'set -gx CODEX_SKILLS_DIR %s\n' "$(shell_quote "$TARGET_SKILLS_DIR")"
  printf 'set -gx CODEX_AGENTS_FILE %s\n' "$(shell_quote "$TARGET_AGENTS_FILE")"
  if [[ -n "$CODEX_MEMORY_DIR_CONFIG" ]]; then
    printf 'set -gx CODEX_MEMORY_DIR %s\n' "$(shell_quote "$CODEX_MEMORY_DIR_CONFIG")"
  fi
}

build_shell_env_block() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"
  printf '%s\n' "$ENV_BLOCK_BEGIN"
  if [[ "$shell_name" == "fish" ]]; then
    print_fish_env_commands
  else
    print_shell_env_commands
  fi
  printf '%s\n' "$ENV_BLOCK_END"
}

write_shell_env_config() {
  if [[ "$SKIP_SHELL_ENV" -eq 1 ]]; then
    log "skip shell env config; --skip-shell-env was provided"
    return
  fi

  local rc_file
  if ! rc_file="$(detect_shell_rc_file)"; then
    log "unable to detect shell rc file; copy these commands into your shell profile:"
    print_shell_env_commands
    if [[ -z "$CODEX_MEMORY_DIR_CONFIG" ]]; then
      printf 'export CODEX_MEMORY_DIR=<absolute/path/to/CodexMemory>\n'
    fi
    return
  fi

  if [[ -n "$CODEX_MEMORY_DIR_CONFIG" ]]; then
    if [[ ! -d "$CODEX_MEMORY_DIR_CONFIG" ]]; then
      echo "CODEX_MEMORY_DIR does not exist: $CODEX_MEMORY_DIR_CONFIG" >&2
      exit 1
    fi
    if [[ ! -f "${CODEX_MEMORY_DIR_CONFIG}/AGENTS.md" ]]; then
      echo "CODEX_MEMORY_DIR is missing AGENTS.md: $CODEX_MEMORY_DIR_CONFIG" >&2
      exit 1
    fi
  fi

  log "configure shell env in $rc_file"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] update managed env block in '$rc_file'"
    build_shell_env_block
    if [[ -z "$CODEX_MEMORY_DIR_CONFIG" ]]; then
      echo "[dry-run] CODEX_MEMORY_DIR is unset; set it before syncing if you want it written to the shell rc file."
    fi
    return
  fi

  mkdir -p "$(dirname "$rc_file")"
  if [[ -f "$rc_file" ]]; then
    awk -v begin="$ENV_BLOCK_BEGIN" -v end="$ENV_BLOCK_END" '
      $0 == begin { skip = 1; next }
      $0 == end { skip = 0; next }
      skip != 1 { print }
    ' "$rc_file" > "${rc_file}.antarx.tmp"
    mv "${rc_file}.antarx.tmp" "$rc_file"
  fi
  {
    printf '\n'
    build_shell_env_block
  } >> "$rc_file"
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
# Fail before syncing if two grouped source skills would share one install name.
##
validate_source_skills() {
  local seen=()
  local src name existing
  while IFS= read -r -d '' src; do
    name="$(skill_name_from_dir "$src")"
    if [[ "${#seen[@]}" -gt 0 ]]; then
      for existing in "${seen[@]}"; do
        if [[ "$existing" == "$name" ]]; then
          echo "Duplicate source skill name: $name" >&2
          exit 1
        fi
      done
    fi
    seen+=("$name")
  done < <(find_source_skills)
}

write_skill_improvement_ax_config() {
  local target_skill_dir="${TARGET_SKILLS_DIR}/skill-improvement-ax"
  if [[ ! -d "$target_skill_dir" && "$DRY_RUN" -ne 1 ]]; then
    return
  fi

  log "write skill-improvement-ax source repo config"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] write '$SKILL_IMPROVEMENT_AX_CONFIG'"
  else
    {
      printf '# Local machine config written by antarx-dev-skills/scripts/sync_to_local.sh\n'
      printf 'ANTARX_DEV_SKILLS_REPO=%s\n' "$(shell_quote "$REPO_ROOT")"
    } > "$SKILL_IMPROVEMENT_AX_CONFIG"
  fi
}

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  echo "Source skills dir not found: $SRC_SKILLS_DIR" >&2
  exit 1
fi

if [[ "$SYNC_AGENTS" -eq 1 && ! -f "$SRC_AGENTS_FILE" ]]; then
  echo "Source AGENTS.md.root not found: $SRC_AGENTS_FILE" >&2
  exit 1
fi

if [[ "$FORCE_AGENTS" -eq 1 && "$SYNC_AGENTS" -ne 1 ]]; then
  echo "--force-agents requires --sync-agents" >&2
  exit 2
fi

validate_source_skills

run_cmd mkdir -p "$TARGET_SKILLS_DIR"

declare -a MANAGED_NOW=()

while IFS= read -r -d '' src; do
  name="$(skill_name_from_dir "$src")"
  if is_blacklisted "$name"; then
    log "skip blacklisted skill: $name"
    continue
  fi
  MANAGED_NOW+=("$name")
  dst="${TARGET_SKILLS_DIR}/${name}"
  rel_src="${src#${REPO_ROOT}/}"
  log "sync skill: $name from $rel_src"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if command -v rsync >/dev/null 2>&1; then
      echo "[dry-run] rsync -a --delete '$src/' '$dst/'"
    else
      echo "[dry-run] replace '$dst' with copy from '$src'"
    fi
  else
    if command -v rsync >/dev/null 2>&1; then
      mkdir -p "$dst"
      rsync -a --delete "$src/" "$dst/"
    else
      rm -rf "$dst"
      cp -R "$src" "$dst"
    fi
    printf "managed-by=antarx-dev-skills\n" > "${dst}/.managed-by-antarx-dev-skills"
  fi
done < <(find_source_skills)

write_skill_improvement_ax_config
write_shell_env_config

if [[ -f "$MANIFEST_FILE" ]]; then
  while IFS= read -r old; do
    [[ -z "$old" ]] && continue
    keep=0
    for current in "${MANAGED_NOW[@]}"; do
      if [[ "$old" == "$current" ]]; then
        keep=1
        break
      fi
    done
    if [[ "$keep" -eq 0 ]]; then
      stale_path="${TARGET_SKILLS_DIR}/${old}"
      if [[ -e "$stale_path" ]]; then
        log "remove stale managed skill: $old"
        run_cmd rm -rf "$stale_path"
      fi
    fi
  done < "$MANIFEST_FILE"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] write manifest: $MANIFEST_FILE"
else
  {
    for name in "${MANAGED_NOW[@]}"; do
      printf "%s\n" "$name"
    done
  } > "$MANIFEST_FILE"
fi

if [[ "$SYNC_AGENTS" -eq 1 ]]; then
  run_cmd mkdir -p "$(dirname "$TARGET_AGENTS_FILE")"

  if [[ -f "$TARGET_AGENTS_FILE" ]] \
    && ! cmp -s "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE" \
    && [[ "$FORCE_AGENTS" -ne 1 ]]; then
    echo "Refusing to overwrite existing AGENTS file: $TARGET_AGENTS_FILE" >&2
    echo "Re-run with --sync-agents --force-agents only after backing up or reviewing the target." >&2
    exit 1
  fi

  log "sync AGENTS.md.root -> $TARGET_AGENTS_FILE"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] cp '$SRC_AGENTS_FILE' '$TARGET_AGENTS_FILE'"
  else
    cp "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE"
  fi
else
  log "skip AGENTS sync; use --sync-agents to opt in"
fi

log "done"
