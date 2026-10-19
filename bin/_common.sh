#!/usr/bin/env bash
# Shared helpers for the bin/ scripts. Sourced, never executed directly.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

# --- Ruby version guard ------------------------------------------------------
# Chirpy requires Ruby ~> 3.1 (i.e. 3.x, NOT 4.x). This Mac's default Ruby is
# 4.0.6, so builds fail with "version solving has failed" unless a 3.4 keg is
# used. Prefer Homebrew's ruby@3.4 when it exists; CI pins 3.4 independently.
for _keg in /usr/local/opt/ruby@3.4 /opt/homebrew/opt/ruby@3.4; do
  if [ -x "$_keg/bin/ruby" ]; then
    export PATH="$_keg/bin:$PATH"
    break
  fi
done
unset _keg

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
