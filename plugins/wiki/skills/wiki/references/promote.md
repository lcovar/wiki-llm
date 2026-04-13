# /wiki promote

Review and promote draft articles from `drafts/` into the wiki.

## Usage

```
/wiki promote              # Review all drafts
/wiki promote "{title}"    # Promote a specific draft
```

## Steps

### 1. List Drafts

Read all files in `drafts/`. For each, show:

- Title
- Origin (crystallized from query, compiled from source, manual)
- Created date
- Confidence level
- One-line summary

```
Drafts ({count}):

1. "{title}" — crystallized from query "{question}" ({date})
   Confidence: medium | Summary: {one-line}

2. "{title}" — compiled from {source} ({date})
   Confidence: high | Summary: {one-line}

Review which? [1/2/all/skip]
```

### 2. Review Each Draft

For each draft the user wants to review, display the full article and ask:

```
---
{full draft content}
---

Actions:
  [p] Promote to wiki as-is
  [e] Edit first, then promote
  [d] Delete draft
  [s] Skip (keep in drafts)
```

### 3. Promote

When promoting:

1. Move the file from `drafts/` to `articles/` (or the appropriate subdirectory)
2. Remove `origin`, `crystallized_from`, `crystallized_query` from frontmatter (these are draft metadata)
3. Run cross-link scan: add wikilinks to/from other articles
4. Update `_index.md` with the new article
5. Log: `[{DATE}] PROMOTED: "{title}" from drafts to articles`

### 4. Edit + Promote

If the user wants to edit first:

1. Show the draft content
2. Ask what they want to change
3. Apply edits
4. Show the updated version for confirmation
5. Then promote as above
