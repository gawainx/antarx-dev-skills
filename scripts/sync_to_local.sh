#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
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
TARGET_AGENTS_FILE="${CODEX_AGENTS_FILE:-$HOME/.codex/AGENTS.md.root}"

MANIFEST_FILE="${TARGET_SKILLS_DIR}/.antarx-managed-skills"
BLACKLIST=("skill-creator" "skill-installer" "swiftui-macos-llm-chat-module")

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

if [[ ! -d "$SRC_SKILLS_DIR" ]]; then
  echo "Source skills dir not found: $SRC_SKILLS_DIR" >&2
  exit 1
fi

if [[ ! -f "$SRC_AGENTS_FILE" ]]; then
  echo "Source AGENTS.md.root not found: $SRC_AGENTS_FILE" >&2
  exit 1
fi

run_cmd mkdir -p "$TARGET_SKILLS_DIR"
run_cmd mkdir -p "$(dirname "$TARGET_AGENTS_FILE")"

declare -a MANAGED_NOW=()

while IFS= read -r -d '' src; do
  name="$(basename "$src")"
  if is_blacklisted "$name"; then
    log "skip blacklisted skill: $name"
    continue
  fi
  MANAGED_NOW+=("$name")
  dst="${TARGET_SKILLS_DIR}/${name}"
  log "sync skill: $name"
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
done < <(find "$SRC_SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

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

log "sync AGENTS.md.root -> $TARGET_AGENTS_FILE"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] cp '$SRC_AGENTS_FILE' '$TARGET_AGENTS_FILE'"
else
  cp "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE"
fi

log "done"
