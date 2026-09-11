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

# Markdown docs.
find "$ROOT" -type f \( -iname '*.md' -o -iname '*.markdown' \) -delete

after=$(du -sm "$ROOT" | cut -f1)
echo "-----> Pruned $ROOT (${after}M after, saved $((before - after))M)"
