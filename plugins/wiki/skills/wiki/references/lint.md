# /wiki lint

Run health checks on the wiki and report issues.

## Usage

```
/wiki lint
/wiki lint --fix    # Auto-fix mechanical issues without asking
```

## Checks

Run all checks and compile results into a report.

### 1. Broken Wikilinks (Error, Auto-fixable)

- Scan all articles for `[[wikilink]]` patterns
- Check that each linked article exists
- Fix: remove the broken link, or create a stub article in `drafts/`

### 2. Missing Index Entries (Error, Auto-fixable)

- Compare articles in `articles/` (and domain subdirectories) against `_index.md`
- Any article not in the index is a missing entry
- Fix: add the article to `_index.md` with its summary

### 3. Orphan Articles (Warning)

- Find articles with zero inbound wikilinks from other articles
- These might be isolated or might just need connections
- Not auto-fixable: needs judgment about whether to connect or archive

### 4. Orphan Sources (Warning, Auto-fixable)

- Find files in `raw/` that aren't listed in `_sources.md` as compiled
- These were ingested but never compiled
- Fix: trigger compile for these sources

### 5. Stale Articles (Warning)

Time-based: articles whose sources are older than `staleness_threshold_days` (from SCHEMA.md).

Source-change: if a source URL can be checked (HEAD request), compare content-length or last-modified with stored values. If changed, the article may be stale.

Contradiction-based: articles with `[CONTRADICTION]` blocks that haven't been resolved.

### 6. Contradictions (Warning)

- Scan for `[CONTRADICTION]` blocks across all articles
- List each with both sides and source information
- Not auto-fixable: requires judgment

### 7. Sparse Articles (Suggestion)

- Articles under `min_article_words` (from SCHEMA.md, default 150 words)
- These might need expansion or merging into another article
- Suggest: expand with `/wiki ingest --research "topic"` or merge

### 8. Tag Inconsistency (Suggestion, Auto-fixable)

- Collect all tags across articles
- Find near-duplicates: "auth" vs "authentication", "k8s" vs "kubernetes"
- Fix: normalize to the more common/descriptive variant

### 9. Duplicate Articles (Warning)

- Compare article summaries and content
- Flag pairs with 80%+ content overlap
- Not auto-fixable: needs merge decision

### 10. Empty Related Section (Suggestion, Auto-fixable)

- Articles with no wikilinks in their Relationships section
- Fix: scan for connections to other articles and add links

### 11. Unprocessed Log Entries (Suggestion)

- Check `_log.md` for `SESSION_OBSERVATION` or `QUERY_GAP` entries that haven't been addressed
- Suggest running `/wiki compile` or `/wiki evolve`

## Report Format

```markdown
# Wiki Lint Report - {DATE}

## Errors ({count})

- **Broken link**: [[nonexistent]] in articles/{file}.md
  Fix: Remove link [auto-fix available]
- **Missing index**: articles/{file}.md not in \_index.md
  Fix: Add to index [auto-fix available]

## Warnings ({count})

- **Orphan article**: articles/{file}.md (0 inbound links)
  Consider: Add references from related articles or archive
- **Stale source**: raw/{file}.md (source changed since fetch)
  Fix: Re-ingest {url}
- **Contradiction**: articles/{a}.md vs articles/{b}.md
  Review: {brief description of conflict}

## Suggestions ({count})

- **Sparse article**: articles/{file}.md ({N} words)
  Consider: Expand or merge
- **Tag inconsistency**: "auth" vs "authentication" across {N} articles
  Fix: Normalize [auto-fix available]

## Summary

- {total_articles} articles, {drafts} drafts
- {errors} errors, {warnings} warnings, {suggestions} suggestions
- {auto_fixable} issues can be auto-fixed

Auto-fix {auto_fixable} issues? [y/n]
```

If `--fix` was passed, auto-fix all fixable issues without asking and report what was fixed.
