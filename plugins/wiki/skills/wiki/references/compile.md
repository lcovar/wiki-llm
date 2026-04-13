# /wiki compile

Compile new and changed raw sources into wiki articles.

**Before compiling, read `references/karpathy-principles.md` for the philosophy that guides all compilation.** Key rules: synthesize don't summarize, one source can touch many pages, cross-reference aggressively, preserve specifics, flag contradictions.

## Usage

```
/wiki compile
/wiki compile --force    # Recompile all sources, not just new/changed
/wiki compile --dry-run  # Show what would be compiled without writing
```

## Pipeline Overview

```
1. Diff Detection     — What's new or changed in raw/?
2. Concept Extraction — What are the key ideas in each source?
3. Article Drafting   — Create or merge articles
4. Quality Validation — Check each article before writing
5. Cross-Link + Index — Update wikilinks, indexes, and logs
```

## Step 1: Diff Detection

1. Read `_sources.md` to get previously compiled sources with their content hashes
2. Scan `raw/` for all files
3. Compare: identify files that are new (not in `_sources.md`) or changed (different hash)
4. Also check `_log.md` for `SESSION_OBSERVATION` entries that haven't been processed
5. Report: "Found {N} new sources, {M} changed sources, {O} session observations to process"
6. If nothing to process, report and exit

## Step 2: Concept Extraction

For each new/changed source:

1. Read the source file
2. Read `_index.md` to know what articles already exist
3. Read `SCHEMA.md` for compilation preferences and terminology
4. Extract:
   - **Key concepts**: the 3-10 main ideas in this source. Each is a potential article or article update.
   - **Facts and claims**: specific assertions with attribution. Numbers, dates, code behavior, etc.
   - **Existing matches**: which existing articles cover the same concepts? For each match, decide: `merge` (enrich existing) or `create_new` (distinct enough for its own article)
   - **Contradictions**: does anything conflict with existing wiki content?
   - **Relationships**: how do concepts from this source relate to existing articles?

**The merge-over-create principle:** Default to merging into existing articles. Only create a new article when the concept is genuinely distinct from everything in the index. Ten sources about the same topic should produce one rich article, not ten thin ones.

**The split-by-concept principle:** One source often contains multiple distinct concepts. A debugging session might cover architecture, failure modes, tooling, and operational patterns. Each independently useful concept should become its own article. Ask: "Would someone searching for just this sub-topic benefit from it being its own article?" If yes, split it out. A single raw source touching 3-5 distinct concepts should produce 3-5 articles, not one mega-article. Cross-link them with wikilinks.

**Preserve ticket and reference numbers:** When raw sources mention ticket numbers (e.g., BTC-3210, JIRA-123), PR numbers, or incident IDs, always preserve them in the compiled articles. These are useful for tracing back to the original context. Include them naturally in the prose or in the Sources section.

For session observations from `_log.md`: treat each observation as a lightweight source. Extract the key claim and check if it should update an existing article or seed a new draft.

## Step 3: Article Drafting

### Creating a New Article

Follow this format:

```markdown
---
title: "{Concept Name}"
tags: [{ tag1 }, { tag2 }]
sources: [{ source-filename-1.md }, { source-filename-2.md }]
related: ["[[other-concept]]", "[[another-concept]]"]
confidence: { high|medium|low }
created: { YYYY-MM-DD }
updated: { YYYY-MM-DD }
source_count: { N }
---

# {Concept Name}

{One-paragraph summary. This is what appears in the index. Make it count: it should tell the reader whether this article answers their question.}

## Details

{Detailed explanation. Encyclopedic prose, not bullet points unless listing discrete items. Preserve specific numbers, dates, formulas, code examples. Synthesize across sources rather than summarizing each source separately.}

## Relationships

- Builds on [[foundation-concept]]
- Contrasts with [[alternative-approach]] on the question of X
- Applied in [[practical-application]]

## Open Questions

- {Any gaps, unresolved questions, or areas needing more sources}

## Sources

- {source-filename-1.md}: {what this source contributed}
- {source-filename-2.md}: {what this source contributed}
```

### Merging Into an Existing Article

1. Read the existing article
2. Add new information from the source:
   - New facts go into the Details section
   - New relationships go into the Relationships section
   - New open questions go into Open Questions
   - New source gets added to Sources section and frontmatter
3. Update the summary if the new information changes the big picture
4. Increment `source_count` in frontmatter
5. Update `updated` date
6. **Never delete existing information during a merge.** Only add. If new info contradicts old, add a contradiction note (don't silently overwrite).
7. If the article has grown past ~2000 words after merge, consider whether it should be split into sub-topics

### Handling Contradictions

When new information contradicts an existing article:

1. Do NOT silently replace the old claim
2. Add a contradiction block in both articles:
   ```
   > **[CONTRADICTION]** This article states {X}. However, [[other-article]]
   > (sourced from {source}) states {Y}. The {newer/more authoritative} source
   > suggests {X/Y} is more likely correct.
   ```
3. Log the contradiction in `_log.md`
4. Use the source authority hierarchy from SCHEMA.md to suggest which is more likely correct

### Confidence Scoring

Assign confidence based on:

- **high**: 3+ independent sources corroborate, OR 1 highly authoritative source (source code, official docs, peer-reviewed paper)
- **medium**: 1-2 sources, or sources are secondary (blog posts, tutorials, chat messages)
- **low**: single non-authoritative source, or the article contains extrapolation beyond what sources directly state

## Step 4: Quality Validation

Before writing each article to disk, evaluate it:

1. **Substantiveness**: Does this article teach something beyond what the title implies? Reject articles under `min_article_words` (from SCHEMA.md, default 150) that don't add real information.

2. **Deduplication**: Check `_index.md`. Does an existing article cover 80%+ of the same ground? If so, merge instead of creating.

3. **Schema compliance**: Does it follow SCHEMA.md requirements? Required sections present? Tags from the approved taxonomy?

4. **Confidence assignment**: Is the confidence score justified by the sources?

If an article fails validation:

- Log the rejection in `_log.md`: `[{DATE}] REJECTED: "{title}" - Reason: {reason}`
- The raw source is preserved in `raw/` for future reprocessing
- Report the rejection to the user

If SCHEMA.md has `auto_publish: false`, write to `drafts/` instead of `articles/`. The user promotes via `/wiki promote`.

## Step 5: Cross-Linking and Index Update

After all articles are created/updated:

### Cross-Link Scan

- Read through all new/updated articles
- Find mentions of concepts that have their own articles but aren't linked with `[[wikilinks]]`
- Add wikilinks where appropriate (don't over-link: link on first mention in each section, not every occurrence)
- **Never create wikilinks to articles that don't exist.** Only link to articles present in `_index.md`. If a concept deserves its own article but doesn't have one yet, mention it in plain text and add it to Open Questions or `_log.md` as a gap, not as a dead `[[wikilink]]`.

### Backlink Update

- If article A now links to article B, check that B's `related` frontmatter includes A
- Add missing backlinks

### Index Regeneration

- Read current `_index.md`
- Add entries for new articles, update entries for changed articles
- Each entry: `- [[article-name]] — {one-line summary from the article's first paragraph}. Tags: {comma-separated tags}`
- **Keep the index flat (no category headers) until there are 15+ articles.** A category with 1-2 articles is noise. Let categories emerge naturally from tag clusters once there's enough content to group meaningfully.
- Once grouping is warranted, group by the most common tags and keep entries sorted alphabetically within each group

### Source Manifest Update

- Update `_sources.md` for each processed source:
  - Update content hash
  - Update the "Articles" column with which articles this source contributed to
  - Change status from "pending" to "compiled"

### Activity Log

- Append to `_log.md`:
  ```
  [{DATE}] COMPILE: Processed {N} sources
    Created: {list of new articles}
    Updated: {list of merged articles}
    Rejected: {list with reasons}
    Contradictions: {list if any}
  ```

## Compilation Report

After compilation, print a summary:

```
Compiled {N} sources into wiki articles:
  Created: {count} new articles
  Updated: {count} existing articles
  Rejected: {count} (see _log.md for details)
  Contradictions found: {count}

Wiki now has {total} articles ({drafts} in drafts/).
```

## Adaptive Hierarchy Check

After compilation, check if the wiki has crossed a hierarchy threshold:

- **At ~50 articles (flat -> grouped):** "Your wiki has {N} articles. Consider organizing into subdirectories by topic. Run `/wiki evolve` for reorganization suggestions."
- **At ~200 articles (grouped -> hierarchical):** "Your wiki has {N} articles. Consider creating domain directories with their own indexes. Run `/wiki evolve` for reorganization suggestions."

Don't auto-reorganize. Just suggest.
