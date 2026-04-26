#!/usr/bin/env bash
set -euo pipefail

##
# Initialize Codex continuous development workflow structure in current working directory.
# Inputs: none (uses current working directory; reads templates from sibling assets/).
# Outputs: creates missing directories/files, prints CREATE/SKIP logs only.
##

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ASSETS_DIR="${SKILL_DIR}/assets"

created_count=0
skipped_count=0

log_create() {
  printf 'CREATE %s\n' "$1"
  created_count=$((created_count + 1))
}

log_skip() {
  printf 'SKIP   %s\n' "$1"
  skipped_count=$((skipped_count + 1))
}

ensure_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    log_skip "$path/"
  else
    mkdir -p "$path"
    log_create "$path/"
  fi
}

ensure_file_from_asset() {
  local target_path="$1"
  local asset_path="${ASSETS_DIR}/${target_path}"
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

printf '\nDone. created=%d skipped=%d\n' "$created_count" "$skipped_count"
