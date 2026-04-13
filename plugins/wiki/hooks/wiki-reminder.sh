#!/bin/bash
# Stop hook: prompts Claude to summarize what's worth capturing to the wiki.
# Uses a cooldown so it only fires once per 15-minute window.

cat > /dev/null

WIKI_PATH=$("${CLAUDE_PLUGIN_ROOT}/hooks/find-wiki.sh") || exit 0

# Cooldown: only fire once per 15 minutes
FLAG="$HOME/.claude/.wiki-reminder-last"
COOLDOWN=900
if [ -f "$FLAG" ]; then
  last=$(cat "$FLAG")
  now=$(date +%s)
  elapsed=$((now - last))
  if [ "$elapsed" -lt "$COOLDOWN" ]; then
    exit 0
  fi
fi
date +%s > "$FLAG"

cat <<PROMPT
Wiki capture check: Review this conversation for any of the following worth preserving:
- Debugging discoveries or root causes
- Architecture insights or design decisions
- Operational patterns or runbook-worthy procedures
- Corrections to existing wiki content

If you found anything, list each item as a one-line bullet describing what you'd write, then ask the user which (if any) they want captured to $WIKI_PATH/. If nothing notable was learned, say nothing and do not mention the wiki.
PROMPT
