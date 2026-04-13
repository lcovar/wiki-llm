#!/bin/bash
# SessionStart hook: loads wiki article index into Claude's context
# so it can reference existing knowledge without being asked.

cat > /dev/null

WIKI_PATH=$("${CLAUDE_PLUGIN_ROOT}/hooks/find-wiki.sh") || exit 0

echo "=== Wiki Knowledge Base ($WIKI_PATH/) ==="
cat "$WIKI_PATH/_index.md"
echo "=== End Wiki Index ==="
echo "If any articles above are relevant to the user's request, read them from $WIKI_PATH/articles/ before starting work."
