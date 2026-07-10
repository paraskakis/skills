#!/usr/bin/env bash
# check-drift.sh — assert that duplicated blocks in the API skills stay identical.
#
# Every skill installs as a single self-contained directory (`npx skills add
# --skill design-api`), so design-api CANNOT reference its siblings at runtime.
# It must carry its own copy of the story-format, spec-generation, lint, and
# preview blocks. That duplication is load-bearing, not accidental.
#
# The failure mode it creates is silent drift: on 2026-07-09 design-api's story
# rules were found missing the auth line that design-api-stories still had, so
# /design-api and /design-api-stories generated stories under different rules.
#
# This script compares each shared block across its copies. Step numbers differ
# by design (design-api runs both phases, so its steps are offset) and are
# normalized away, as is the block's own heading line. Everything else must match.
#
# Usage: scripts/check-drift.sh        (exit 0 = in sync, 1 = drift)

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

API=api
fail=0

# Print the body of a block: lines strictly after the line matching $2,
# up to (not including) the next line matching $3. The heading itself is
# dropped so that "Save the Spec" vs "Save the File" is not a difference.
extract() {
  awk -v s="$2" -v e="$3" '
    !inb && $0 ~ s { inb = 1; next }
    inb  && $0 ~ e { exit }
    inb            { print }
  ' "$1"
}

# Normalize incidental differences: step numbers, trailing whitespace,
# and leading/trailing blank lines.
normalize() {
  sed -E 's/Step [0-9]+/Step N/g; s/[[:space:]]+$//' \
    | sed -e '/./,$!d' \
    | awk 'BEGIN{RS=""} {print}'
}

# compare <label> <fileA> <fileB> <start-regex> <end-regex>
compare() {
  local label=$1 a=$2 b=$3 start=$4 end=$5
  local ta tb
  ta=$(mktemp) tb=$(mktemp)
  extract "$API/$a/SKILL.md" "$start" "$end" | normalize >"$ta"
  extract "$API/$b/SKILL.md" "$start" "$end" | normalize >"$tb"

  if [ ! -s "$ta" ] || [ ! -s "$tb" ]; then
    printf '  \033[31mERROR\033[0m %-22s block not found (marker moved?) — %s / %s\n' "$label" "$a" "$b"
    fail=1
  elif diff -q "$ta" "$tb" >/dev/null; then
    printf '  \033[32mOK\033[0m    %-22s %s == %s\n' "$label" "$a" "$b"
  else
    printf '  \033[31mDRIFT\033[0m %-22s %s vs %s\n' "$label" "$a" "$b"
    diff "$ta" "$tb" | sed 's/^/          /'
    fail=1
  fi
  rm -f "$ta" "$tb"
}

echo "Checking duplicated blocks across the API design skills..."
echo

compare "simple story format" design-api design-api-stories \
  '^### Simple Story Format' '^### Detailed Story Format'

compare "generate openapi"    design-api design-api-spec \
  '^## Step [0-9]+: Generate the OpenAPI Document' '^## Step [0-9]+: Validate JSON'

compare "validate json"       design-api design-api-spec \
  '^## Step [0-9]+: Validate JSON' '^## Step [0-9]+: Save'

compare "save the spec"       design-api design-api-spec \
  '^## Step [0-9]+: Save' '^## Step [0-9]+: Lint'

compare "rmoa lint"           design-api design-api-spec \
  '^## Step [0-9]+: Lint with RateMyOpenAPI' '^## Step [0-9]+: Report'

compare "report + preview"    design-api design-api-spec \
  '^## Step [0-9]+: Report' '^(#+ Key Principles|---)$'

# ---------------------------------------------------------------------------
# Whole-file duplicates.
#
# The CLI skills bundle reference docs verbatim — the checklist in all five, the
# frameworks guidance in three. Same reason as the API blocks: a skill installs
# as a standalone directory and cannot reach a sibling. Every copy must match.
# ---------------------------------------------------------------------------

# identical <label> <relative-path-under-each-skill> <skill-dir> ...
identical() {
  local label=$1 rel=$2; shift 2
  local first="" ref=""
  for d in "$@"; do
    local f="$d/$rel"
    if [ ! -f "$f" ]; then
      printf '  \033[31mERROR\033[0m %-22s missing: %s\n' "$label" "$f"; fail=1; return
    fi
    if [ -z "$first" ]; then first=$f; ref=$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1); continue; fi
    local h; h=$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1)
    if [ "$h" != "$ref" ]; then
      printf '  \033[31mDRIFT\033[0m %-22s %s\n' "$label" "$f"
      diff "$first" "$f" | head -20 | sed 's/^/          /'
      fail=1; return
    fi
  done
  printf '  \033[32mOK\033[0m    %-22s %s copies identical\n' "$label" "$#"
}

CLI=cli
identical "cli checklist" references/agent-ready-cli-checklist-v2.md \
  $CLI/agent-ready-cli-story $CLI/agent-ready-cli-spec $CLI/agent-ready-cli-build \
  $CLI/agent-ready-cli-audit $CLI/agent-ready-cli-end-to-end

identical "cli frameworks doc" references/frameworks-and-implementation-guidance.md \
  $CLI/agent-ready-cli-spec $CLI/agent-ready-cli-build $CLI/agent-ready-cli-end-to-end

echo
if [ $fail -eq 0 ]; then
  echo "All shared blocks and bundled reference docs in sync."
else
  echo "Drift found. Apply the edit to every copy, then re-run." >&2
fi
exit $fail
