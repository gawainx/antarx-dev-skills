#!/usr/bin/env bash
set -euo pipefail

# Install only Codex DESIGN.md and optionally AGENTS.md.

DRY_RUN=0
SYNC_AGENTS=0
FORCE_AGENTS=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_AGENTS_FILE="${REPO_ROOT}/AGENTS.root.md"
SRC_DESIGN_FILE="${REPO_ROOT}/DESIGN.md"
CONFIG_FILE="${REPO_ROOT}/.env"

unset CODEX_AGENTS_FILE CODEX_DESIGN_FILE
CODEX_AGENTS_FILE=""
CODEX_DESIGN_FILE=""

log() { echo "[sync] $*"; }

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
      CODEX_AGENTS_FILE|CODEX_DESIGN_FILE)
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

##
# Reject an existing DESIGN.md unless it links to this repository's source.
##
validate_design_target() {
  if [[ -L "$TARGET_DESIGN_FILE" ]]; then
    if [[ "$TARGET_DESIGN_FILE" -ef "$SRC_DESIGN_FILE" ]]; then
      return
    fi
  elif [[ ! -e "$TARGET_DESIGN_FILE" ]]; then
    return
  fi

  echo "DESIGN.md already exists and is not a link to this project's source: $TARGET_DESIGN_FILE" >&2
  echo "Expected source: $SRC_DESIGN_FILE" >&2
  echo "Stopped without replacing it. Review the existing entry and decide how to handle it before retrying." >&2
  exit 1
}

##
# Link the repository design conventions into Codex's system configuration.
##
install_design_link() {
  validate_design_target
  if [[ -L "$TARGET_DESIGN_FILE" ]]; then
    log "[codex] DESIGN.md symlink already correct: $TARGET_DESIGN_FILE"
    return
  fi

  log "[codex] link DESIGN.md -> $TARGET_DESIGN_FILE"
  run_cmd mkdir -p "$(dirname "$TARGET_DESIGN_FILE")"
  run_cmd ln -s "$SRC_DESIGN_FILE" "$TARGET_DESIGN_FILE"
}

if [[ "$SYNC_AGENTS" -eq 1 && ! -f "$SRC_AGENTS_FILE" ]]; then
  echo "Source AGENTS.root.md not found: $SRC_AGENTS_FILE" >&2
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

install_design_link

if [[ "$SYNC_AGENTS" -eq 1 ]]; then
  run_cmd mkdir -p "$(dirname "$TARGET_AGENTS_FILE")"

  # Repository AGENTS.md is never an installation source.
  resolved_agents=""
  if [[ -L "$TARGET_AGENTS_FILE" ]]; then
    resolved_agents="$(cd "$(dirname "$TARGET_AGENTS_FILE")" && cd "$(dirname "$(readlink "$TARGET_AGENTS_FILE")")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "$(readlink "$TARGET_AGENTS_FILE")")")" || true
  fi
  if [[ "$resolved_agents" == "$SRC_AGENTS_FILE" ]]; then
    log "AGENTS symlink already correct: $TARGET_AGENTS_FILE"
  else
    if [[ -e "$TARGET_AGENTS_FILE" || -L "$TARGET_AGENTS_FILE" ]]; then
      if [[ -d "$TARGET_AGENTS_FILE" && ! -L "$TARGET_AGENTS_FILE" ]]; then
        echo "Refusing to replace AGENTS directory: $TARGET_AGENTS_FILE" >&2
        exit 1
      fi
      if [[ "$FORCE_AGENTS" -ne 1 ]]; then
        echo "Refusing to replace existing AGENTS entry: $TARGET_AGENTS_FILE" >&2
        echo "Re-run with --sync-agents --force-agents only after backing up or reviewing the target." >&2
        exit 1
      fi
      run_cmd rm -f "$TARGET_AGENTS_FILE"
    fi
    log "link AGENTS.root.md -> $TARGET_AGENTS_FILE"
    run_cmd ln -s "$SRC_AGENTS_FILE" "$TARGET_AGENTS_FILE"
  fi
else
  log "skip AGENTS sync; use --sync-agents to opt in"
fi

log "done"
