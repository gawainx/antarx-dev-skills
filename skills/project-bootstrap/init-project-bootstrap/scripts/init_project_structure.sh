#!/usr/bin/env bash
set -euo pipefail

##
# Initialize Codex continuous development workflow structure in current working directory.
# Inputs: optional --simple flag (uses current working directory; reads templates from sibling assets/).
# Outputs: creates missing directories/files, prints CREATE/SKIP logs only.
##

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FULL_ASSETS_DIR="${SKILL_DIR}/assets"
SIMPLE_ASSETS_DIR="${SKILL_DIR}/assets-simple"
MODE="full"
ASSETS_DIR="${FULL_ASSETS_DIR}"

created_count=0
skipped_count=0

usage() {
  printf 'Usage: %s [--simple]\n' "$(basename "$0")"
}

##
# Parse command-line flags and select the initialization mode.
# Inputs: "$@" from the script entrypoint.
# Outputs: sets MODE and ASSETS_DIR, or exits on help/invalid input.
##
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --simple)
        MODE="simple"
        ASSETS_DIR="${SIMPLE_ASSETS_DIR}"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown argument: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done
}

##
# Record a created path in the script log.
# Inputs: path printed to stdout.
# Outputs: increments created_count.
##
log_create() {
  printf 'CREATE %s\n' "$1"
  created_count=$((created_count + 1))
}

##
# Record an existing path skipped by the script.
# Inputs: path printed to stdout.
# Outputs: increments skipped_count.
##
log_skip() {
  printf 'SKIP   %s\n' "$1"
  skipped_count=$((skipped_count + 1))
}

##
# Ensure a directory exists without changing existing content.
# Inputs: target directory path.
# Outputs: creates the directory if missing and logs CREATE/SKIP.
##
ensure_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    log_skip "$path/"
  else
    mkdir -p "$path"
    log_create "$path/"
  fi
}

##
# Copy one template file to a target path if the target is missing.
# Inputs: target path, optional source path relative to ASSETS_DIR.
# Outputs: creates the file if missing and logs CREATE/SKIP.
##
ensure_file_from_asset() {
  local target_path="$1"
  local source_path="${2:-$target_path}"
  local asset_path="${ASSETS_DIR}/${source_path}"
  local parent_dir

  if [[ ! -f "$asset_path" ]]; then
    printf 'Missing asset template: %s\n' "$asset_path" >&2
    exit 1
  fi

  parent_dir="$(dirname "$target_path")"
  mkdir -p "$parent_dir"

  if [[ -e "$target_path" ]]; then
    log_skip "$target_path"
    return
  fi

  cp "$asset_path" "$target_path"
  log_create "$target_path"
}

##
# Initialize the full antarx-harness documentation structure.
# Inputs: none.
# Outputs: creates missing full-mode directories and files.
##
init_full() {
  ensure_dir "docs/request-clarify"
  ensure_dir "docs/design-docs"
  ensure_dir "docs/exec-plans/active"
  ensure_dir "docs/exec-plans/completed"
  ensure_dir "docs/generated"
  ensure_dir "docs/product-specs"
  ensure_dir "docs/references"

  ensure_file_from_asset "AGENTS.md"
  ensure_file_from_asset "ARCHITECTURE.md"
  ensure_file_from_asset "docs/request-clarify/index.md"
  ensure_file_from_asset "docs/design-docs/index.md"
  ensure_file_from_asset "docs/design-docs/core-beliefs.md"
  ensure_file_from_asset "docs/exec-plans/tech-debt-tracker.md"
  ensure_file_from_asset "docs/product-specs/index.md"
  ensure_file_from_asset "docs/DESIGN.md"
  ensure_file_from_asset "docs/FRONTEND.md"
  ensure_file_from_asset "docs/PROGRESS.md"
  ensure_file_from_asset "docs/PRODUCT_SENSE.md"
  ensure_file_from_asset "docs/QUALITY_SCORE.md"
  ensure_file_from_asset "docs/RELIABILITY.md"
  ensure_file_from_asset "docs/SECURITY.md"
}

##
# Initialize the lightweight antarx-harness documentation structure.
# Inputs: none.
# Outputs: creates missing simple-mode directories and files.
##
init_simple() {
  ensure_dir "docs/requirements"

  ensure_file_from_asset "AGENTS.md" "AGENTS.simple.md"
  ensure_file_from_asset "ARCHITECTURE.md"
  ensure_file_from_asset "docs/requirements/index.md"
  ensure_file_from_asset "docs/requirements/REQ-0001-template.md"
}

parse_args "$@"

case "$MODE" in
  full)
    init_full
    ;;
  simple)
    init_simple
    ;;
esac

printf '\nDone. created=%d skipped=%d\n' "$created_count" "$skipped_count"
