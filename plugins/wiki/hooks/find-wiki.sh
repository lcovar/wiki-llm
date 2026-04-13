#!/bin/bash
# Shared helper: finds the first registered wiki path.
# Prints the wiki path to stdout, exits 1 if none found.

REGISTRY="$HOME/.claude/wiki-registry.json"

if [ ! -f "$REGISTRY" ]; then
  exit 1
fi

# Parse first wiki path from registry (no jq dependency, just grep+sed)
path=$(grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' "$REGISTRY" | head -1 | sed 's/.*"path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

if [ -z "$path" ] || [ ! -f "$path/_index.md" ]; then
  exit 1
fi

echo "$path"
