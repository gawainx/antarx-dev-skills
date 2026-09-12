#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
SYNC_AGENTS=0
FORCE_AGENTS=0
TARGETS_SPEC="all"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_SKILLS_DIR="${REPO_ROOT}/skills"
SRC_AGENTS_FILE="${REPO_ROOT}/AGENTS.md.root"
SRC_DESIGN_FILE="${REPO_ROOT}/DESIGN.md"
CONFIG_FILE="${REPO_ROOT}/.env"

unset ANTARX_SKILL_TARGETS CODEX_SKILLS_DIR GROK_SKILLS_DIR CLAUDE_SKILLS_DIR CODEX_AGENTS_FILE CODEX_DESIGN_FILE
ANTARX_SKILL_TARGETS=""
CODEX_SKILLS_DIR=""
GROK_SKILLS_DIR=""
CLAUDE_SKILLS_DIR=""
CODEX_AGENTS_FILE=""
CODEX_DESIGN_FILE=""

BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")
# Strongly Codex-bound skills: install only to codex by default.
CODEX_ONLY_SKILLS=(
  "skill-creation-closeout"
  "skill-improvement-ax"
  "workflow-review-packager"
)
log() { echo "[sync] $*"; }

load_config() {
  local line key value
  [[ -f "$CONFIG_FILE" ]] || return

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
    if [[ "$line" != *=* ]]; then
      echo "Invalid .env entry (expected KEY=value): $line" >&2
      exit 2
    fi
    key="${line%%=*}"
    value="${line#*=}"
    case "$key" in
      ANTARX_SKILL_TARGETS|CODEX_SKILLS_DIR|GROK_SKILLS_DIR|CLAUDE_SKILLS_DIR|CODEX_AGENTS_FILE|CODEX_DESIGN_FILE)
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

TARGETS_SPEC="${ANTARX_SKILL_TARGETS:-all}"
CODEX_SKILLS_DIR_RESOLVED="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
GROK_SKILLS_DIR_RESOLVED="${GROK_SKILLS_DIR:-$HOME/.grok/skills}"
CLAUDE_SKILLS_DIR_RESOLVED="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md}"
TARGET_DESIGN_FILE="${CODEX_DESIGN_FILE:-$HOME/.codex/DESIGN.md}"

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
    --targets)
      if [[ $# -lt 2 ]]; then
        echo "--targets requires a comma-separated list (codex,grok,claude) or all" >&2
        exit 2
      fi
      TARGETS_SPEC="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

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

is_codex_only_skill() {
  local name="$1"
  local x
  for x in "${CODEX_ONLY_SKILLS[@]}"; do
    if [[ "$name" == "$x" ]]; then
      return 0
    fi
  done
  return 1
}

##
# Return success when this skill should be installed for the given agent target.
##
skill_allowed_for_target() {
  local name="$1"
  local target="$2"
  if is_codex_only_skill "$name" && [[ "$target" != "codex" ]]; then
    return 1
  fi
  return 0
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

##
# Expand TARGETS_SPEC into the global TARGETS array.
##
parse_targets() {
  local raw item
  TARGETS=()
  raw="$(printf '%s' "$TARGETS_SPEC" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  if [[ -z "$raw" ]]; then
    echo "Empty --targets / ANTARX_SKILL_TARGETS value" >&2
    exit 2
  fi
  if [[ "$raw" == "all" ]]; then
    TARGETS=("codex" "grok" "claude")
    return
  fi
  IFS=',' read -r -a TARGETS <<< "$raw"
  if [[ "${#TARGETS[@]}" -eq 0 ]]; then
    echo "No install targets resolved from: $TARGETS_SPEC" >&2
    exit 2
  fi
  for item in "${TARGETS[@]}"; do
    case "$item" in
      codex|grok|claude) ;;
      *)
        echo "Unknown install target: $item (expected codex, grok, claude, or all)" >&2
        exit 2
        ;;
    esac
  done
}

##
# Print the skills install directory for one agent target.
##
skills_dir_for_target() {
  case "$1" in
    codex) printf '%s\n' "$CODEX_SKILLS_DIR_RESOLVED" ;;
    grok) printf '%s\n' "$GROK_SKILLS_DIR_RESOLVED" ;;
    claude) printf '%s\n' "$CLAUDE_SKILLS_DIR_RESOLVED" ;;
    *)
      echo "Unknown target: $1" >&2
      return 1
      ;;
  esac
}

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

manifest_contains() {
  local manifest_file="$1"
  local name="$2"
  [[ -f "$manifest_file" ]] || return 1
  grep -Fxq "$name" "$manifest_file"
}

##
# True when an install entry is listed in this target's managed manifest.
##
is_managed_install_entry() {
  local manifest_file="$1"
  local name="$2"
  manifest_contains "$manifest_file" "$name"
}

##
# Install one managed skill as a symlink to its source directory.
##
install_skill_link() {
  local src="$1"
  local name="$2"
  local dst="$3"
  local manifest_file="$4"
  local agent="$5"
  local rel_src="${src#${REPO_ROOT}/}"
  local resolved_dst

  log "[$agent] link skill: $name from $rel_src"

  if [[ -L "$dst" ]]; then
    resolved_dst="$(cd "$(dirname "$dst")" && cd "$(dirname "$(readlink "$dst")")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "$(readlink "$dst")")")" || true
    if [[ "$resolved_dst" == "$src" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] symlink already correct: '$dst' -> '$src'"
      fi
      return
    fi

    if is_managed_install_entry "$manifest_file" "$name"; then
      run_cmd rm -f "$dst"
    else
      echo "Refusing to replace unmanaged symlink: $dst" >&2
      exit 1
    fi
  elif [[ -e "$dst" ]]; then
    if is_managed_install_entry "$manifest_file" "$name"; then
      log "[$agent] replace managed install entry with symlink: $name"
      run_cmd rm -rf "$dst"
    else
      echo "Refusing to replace unmanaged install entry: $dst" >&2
      exit 1
    fi
  fi

  run_cmd ln -s "$src" "$dst"
}

##
# Link the repository design conventions into Codex's system configuration.
##
install_design_link() {
  local resolved_dst

  log "[codex] link DESIGN.md -> $TARGET_DESIGN_FILE"

  if [[ -L "$TARGET_DESIGN_FILE" ]]; then
    resolved_dst="$(cd "$(dirname "$TARGET_DESIGN_FILE")" && cd "$(dirname "$(readlink "$TARGET_DESIGN_FILE")")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "$(readlink "$TARGET_DESIGN_FILE")")")" || true
    if [[ "$resolved_dst" == "$SRC_DESIGN_FILE" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] symlink already correct: '$TARGET_DESIGN_FILE' -> '$SRC_DESIGN_FILE'"
      fi
      return
    fi
    run_cmd rm -f "$TARGET_DESIGN_FILE"
  elif [[ -e "$TARGET_DESIGN_FILE" ]]; then
    echo "Refusing to replace existing DESIGN.md that is not a symlink: $TARGET_DESIGN_FILE" >&2
    exit 1
  fi

  run_cmd mkdir -p "$(dirname "$TARGET_DESIGN_FILE")"
  run_cmd ln -s "$SRC_DESIGN_FILE" "$TARGET_DESIGN_FILE"
}

##
# Remove stale managed installs for one agent target (manifest-only).
##
cleanup_stale_managed() {
  local agent="$1"
  local target_dir="$2"
  local manifest_file="$3"
  shift 3
  local managed_now=("$@")
  local old stale_path

  if [[ ! -f "$manifest_file" ]]; then
    return
  fi

  while IFS= read -r old; do
    [[ -z "$old" ]] && continue
    if array_contains "$old" "${managed_now[@]+"${managed_now[@]}"}"; then
      continue
    fi
    stale_path="${target_dir}/${old}"
    if [[ -e "$stale_path" || -L "$stale_path" ]]; then
      log "[$agent] remove stale managed skill: $old"
      run_cmd rm -rf "$stale_path"
    fi
  done < "$manifest_file"
}

##
# Sync all allowed source skills into one agent install directory.
##
sync_target() {
  local agent="$1"
  local target_dir
  local manifest_file
  local src name dst
  local managed_now=()

  target_dir="$(skills_dir_for_target "$agent")"
  manifest_file="${target_dir}/.antarx-managed-skills"

  log "[$agent] install root: $target_dir"
  run_cmd mkdir -p "$target_dir"

  while IFS= read -r -d '' src; do
    name="$(skill_name_from_dir "$src")"
    if is_blacklisted "$name"; then
      log "[$agent] skip blacklisted skill: $name"
      continue
    fi
    if ! skill_allowed_for_target "$name" "$agent"; then
      log "[$agent] skip codex-only skill: $name"
      continue
    fi
    managed_now+=("$name")
    dst="${target_dir}/${name}"
    install_skill_link "$src" "$name" "$dst" "$manifest_file" "$agent"
  done < <(find_source_skills)

  cleanup_stale_managed "$agent" "$target_dir" "$manifest_file" "${managed_now[@]+"${managed_now[@]}"}"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] write manifest: $manifest_file (${#managed_now[@]} skills)"
  else
    {
      for name in "${managed_now[@]+"${managed_now[@]}"}"; do
        printf "%s\n" "$name"
      done
    } > "$manifest_file"
    log "[$agent] wrote manifest with ${#managed_now[@]} skills"
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

if [[ ! -f "$SRC_DESIGN_FILE" ]]; then
  echo "Source DESIGN.md not found: $SRC_DESIGN_FILE" >&2
  exit 1
fi

if [[ "$FORCE_AGENTS" -eq 1 && "$SYNC_AGENTS" -ne 1 ]]; then
  echo "--force-agents requires --sync-agents" >&2
  exit 2
fi

parse_targets
validate_source_skills

log "targets: ${TARGETS[*]}"

for agent in "${TARGETS[@]}"; do
  sync_target "$agent"
done

if array_contains "codex" "${TARGETS[@]}"; then
  install_design_link
else
  log "skip DESIGN.md link; codex is not among targets"
fi

if [[ "$SYNC_AGENTS" -eq 1 ]]; then
  if ! array_contains "codex" "${TARGETS[@]}"; then
    log "skip AGENTS sync; --sync-agents only applies when codex is among targets"
  else
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
  fi
else
  log "skip AGENTS sync; use --sync-agents to opt in"
fi

log "done"
