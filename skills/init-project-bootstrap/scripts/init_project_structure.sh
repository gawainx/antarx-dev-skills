#!/usr/bin/env bash
set -euo pipefail

##
# Initialize project directory structure in current working directory.
# Inputs: none (uses current working directory).
# Outputs: creates missing directories/files, prints CREATE/SKIP logs.
##

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

ensure_file() {
  local path="$1"
  local template="$2"
  local parent_dir
  parent_dir="$(dirname "$path")"

  mkdir -p "$parent_dir"
  if [[ -e "$path" ]]; then
    log_skip "$path"
    return
  fi

  printf '%s\n' "$template" > "$path"
  log_create "$path"
}

ensure_dir "docs/design-docs"
ensure_dir "docs/exec-plans/active"
ensure_dir "docs/exec-plans/completed"
ensure_dir "docs/generated"
ensure_dir "docs/product-specs"
ensure_dir "docs/references"

ensure_file "AGENTS.md" "# AGENTS"
ensure_file "ARCHITECTURE.md" "# ARCHITECTURE"
ensure_file "docs/design-docs/index.md" "# Design Docs Index"
ensure_file "docs/design-docs/core-beliefs.md" "# Core Beliefs"
ensure_file "docs/exec-plans/tech-debt-tracker.md" "# Tech Debt Tracker"
ensure_file "docs/product-specs/index.md" "# Product Specs Index"
ensure_file "docs/DESIGN.md" "# DESIGN"
ensure_file "docs/FRONTEND.md" "# FRONTEND"
ensure_file "docs/PLANS.md" "# PLANS"
ensure_file "docs/PRODUCT_SENSE.md" "# PRODUCT_SENSE"
ensure_file "docs/QUALITY_SCORE.md" "# QUALITY_SCORE"
ensure_file "docs/RELIABILITY.md" "# RELIABILITY"
ensure_file "docs/SECURITY.md" "# SECURITY"

printf '\nDone. created=%d skipped=%d\n' "$created_count" "$skipped_count"

