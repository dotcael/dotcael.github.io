#!/usr/bin/env bash
# Shared helpers for the bin/ scripts. Sourced, never executed directly.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

# Where the private denylist lives (outside this repo, on purpose).
DENYLIST="${BLOG_DENYLIST:-$HOME/Developer/writing/denylist.txt}"
export DENYLIST

# The only four categories. Adding one here means adding it in README.md too.
CATEGORIES="Guides Notes Opinion Writeups"

BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
NC=$'\033[0m'

die()  { echo "${RED}error:${NC} $*" >&2; exit 1; }
ok()   { echo "${GREEN}ok${NC}  $*"; }
warn() { echo "${YELLOW}warn${NC} $*"; }
info() { echo "${DIM}$*${NC}"; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

in_repo() {
  cd "$REPO_ROOT"
}

# Lowercase, hyphenated slug from an arbitrary title.
slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# Canonical-cased category name, or empty if not one of the four.
canon_category() {
  local want lower
  want="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  for c in $CATEGORIES; do
    lower="$(printf '%s' "$c" | tr '[:upper:]' '[:lower:]')"
    if [ "$lower" = "$want" ]; then
      printf '%s' "$c"
      return 0
    fi
  done
  return 1
}
