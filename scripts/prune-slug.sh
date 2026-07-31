#!/bin/bash
# Remove non-runtime artifacts from node_modules to keep the Scalingo image under the size limit.
# Invoked via the scalingo-cleanup package.json script (runs after install + prune).

set -euo pipefail

ROOT="${1:-node_modules}"

if [[ ! -d "$ROOT" ]]; then
  echo " !     $ROOT not found, skipping prune"
  exit 0
fi

before=$(du -sm "$ROOT" | cut -f1)
echo "-----> Pruning non-runtime files from $ROOT (${before}M before)"

# Source maps are not needed at runtime (~500M+ with current n8n).
find "$ROOT" -type f -name '*.map' -delete

# TypeScript sources shipped alongside compiled JS (keep *.d.ts).
find "$ROOT" -type f -name '*.ts' ! -name '*.d.ts' -delete

# Docs / licenses / changelogs.
# Use exact names or NAME.* — never NAME* (would delete runtime files like license-state.js).
find "$ROOT" -type f \( \
  -iname 'README' -o -iname 'README.*' -o \
  -iname 'CHANGELOG' -o -iname 'CHANGELOG.*' -o \
  -iname 'HISTORY' -o -iname 'HISTORY.*' -o \
  -iname 'LICENSE' -o -iname 'LICENSE.*' -o \
  -iname 'LICENCE' -o -iname 'LICENCE.*' -o \
  -iname 'NOTICE' -o -iname 'NOTICE.*' -o \
  -iname '*.md' -o \
  -iname '*.markdown' \
\) -delete

# Test / CI / example trees that are never required at runtime.
# Delete one directory at a time to avoid ARG_MAX limits with find -exec +.
find "$ROOT" -depth -type d \( \
  -name test -o \
  -name tests -o \
  -name __tests__ -o \
  -name .github -o \
  -name coverage -o \
  -name example -o \
  -name examples \
\) -exec rm -rf {} \;

after=$(du -sm "$ROOT" | cut -f1)
echo "-----> Pruned $ROOT (${after}M after, saved $((before - after))M)"
