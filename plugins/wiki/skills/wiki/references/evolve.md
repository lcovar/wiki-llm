# /wiki evolve

Proactively analyze the wiki and suggest improvements.

## Usage

```
/wiki evolve
```

## Analysis

Read the following to understand the wiki's current state:

1. `_log.md` — accumulated gaps, session observations, recent activity
2. `_index.md` — current article inventory
3. `SCHEMA.md` — domain and quality settings
4. `drafts/` — pending draft articles
5. Sample of articles — spot-check for quality, connections, staleness

## Signals to Analyze

### Gap Clusters

Read all `QUERY_GAP` entries from `_log.md`. Cluster similar ones (same topic area, related questions). Rank by frequency.

A gap queried 4 times is much higher priority than one queried once.

### Orphan Concepts

Scan articles for terms, names, or concepts that are mentioned but don't have their own article or wikilink. These are candidates for new articles.

Filter out: common terms that don't need articles. Focus on domain-specific concepts that would benefit from their own entry.

### Weak Articles

Find articles with:

- `confidence: low` older than 30 days
- Under `min_article_words`
- Only 1 source
- Zero query hits (never returned in a `/wiki ask` response, if tracked in `_log.md`)

### Missing Connections

Find pairs of articles that discuss related concepts but don't link to each other. Look for:

- Shared tags with no wikilinks between them
- Mentions of the same concepts/terms
- Articles from the same source that aren't cross-linked

### Draft Backlog

List articles in `drafts/` with age and origin (crystallized, compiled, manual).

### Enrichment Opportunities

Articles that could be improved with publicly available information. Look for:

- Articles with open questions
- Articles with `confidence: low` on topics that likely have good public sources
- Articles that reference external projects, libraries, or standards without linking to docs

### Staleness Candidates

Articles whose source material may have changed (time-based check against `staleness_threshold_days`).

## Output Format

Present as a ranked list grouped by priority:

```
Wiki evolution suggestions:

[HIGH] — Address these first
1. Create article: "{topic}" (queried {N} times, no coverage)
   → /wiki ingest --research "{topic}"

2. Resolve contradiction: [[article-a]] vs [[article-b]] ({description})
   → Review both articles and determine which is correct

[MEDIUM] — Worth doing when you have time
3. Promote draft: "{title}" (crystallized {N} days ago)
   → /wiki promote

4. Connect: [[article-a]] and [[article-b]] (both discuss {concept}, not linked)
   → Auto-fix? [y/n]

5. Enrich: [[thin-article]] ({N} words, 1 source, has open questions)
   → /wiki ingest --research "{topic}"

[LOW] — Nice to have
6. Archive: [[old-article]] (confidence=low, 0 query hits in 90 days)
   → /wiki archive

7. Tag cleanup: {N} inconsistent tags found
   → /wiki lint --fix
```

Let the user pick which items to act on. Execute their choices.

## Hierarchy Transition

If the article count has crossed a threshold (50 for flat->grouped, 200 for grouped->hierarchical), include a reorganization suggestion:

```
[MEDIUM] Your wiki has {N} articles in a flat structure.
Consider organizing into subdirectories by topic for easier navigation.

Suggested groups based on tag analysis:
  - {tag-a}: {count} articles
  - {tag-b}: {count} articles
  - {tag-c}: {count} articles

Reorganize? This will:
  - Create subdirectories under articles/
  - Move articles into appropriate directories
  - Update all wikilinks
  - Regenerate _index.md with sections

Proceed? [y/n]
```
