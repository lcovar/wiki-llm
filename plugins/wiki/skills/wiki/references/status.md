# /wiki status

Show a quick dashboard of the wiki's current state.

## Usage

```
/wiki status
```

## What to Display

Read the wiki's files and compute:

1. **Wiki path** — absolute path to the wiki directory
2. **Domain** — from SCHEMA.md Identity section
3. **Wiki type** — from SCHEMA.md
4. **Article count** — count files in `articles/` (and subdirectories), `drafts/`, and `archive/` (if it exists)
5. **Source count** — count files in `raw/`
6. **Uncompiled sources** — sources in `raw/` not yet compiled (check `_sources.md`)
7. **Last compile** — most recent COMPILE entry in `_log.md`
8. **Last ingest** — most recent INGEST entry in `_log.md`
9. **Health summary** — quick counts: contradictions, orphan articles, stale articles
10. **Gap log** — count of unresolved `QUERY_GAP` entries in `_log.md`
11. **Draft count** — articles in `drafts/`

## Output Format

```
Wiki: {path}
Domain: {domain}
Type: {wiki_type}

Articles: {count} ({drafts} drafts, {archived} archived)
Sources: {raw_count} raw ({uncompiled} uncompiled)

Last compile: {date}
Last ingest: {date}

Health: {issues_count} issues ({errors} errors, {warnings} warnings)
Gap log: {gap_count} unresolved gaps

{If uncompiled > 0}
→ Run /wiki compile to process {uncompiled} new sources

{If gap_count > 5}
→ Run /wiki evolve to review accumulated gaps

{If draft_count > 0}
→ Run /wiki promote to review {draft_count} draft articles
```

Keep it concise. This is a quick glance, not a detailed report. Point to `/wiki lint` for full health details.
