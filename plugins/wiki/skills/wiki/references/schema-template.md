# Schema Template

This is the default SCHEMA.md generated during `/wiki init`. Replace placeholders with user-provided values.

---

```markdown
# Wiki Schema

## Identity

This is a knowledge base about {DOMAIN}.
It serves {AUDIENCE}.
Wiki type: {TYPE}

## Compilation Preferences

- Write in encyclopedic prose, not bullet lists (unless listing discrete items)
- Preserve specific numbers, dates, versions, code examples, and benchmarks
- Prefer depth over breadth: fewer rich articles over many thin ones
- But split distinct concepts into separate articles: one source can produce 3-5 articles if it covers architecture, failure modes, tooling, and patterns
- When merging information from multiple sources, synthesize rather than concatenate
- Always attribute claims to their source
- Preserve ticket numbers, PR numbers, and incident IDs from source material

## Terminology

- Use consistent terminology throughout (add project-specific terms below)
- Prefer the most common/recognizable term when alternatives exist

## Article Structure

Required sections for every article:

- **Summary** (1-2 paragraphs, appears in index)
- **Details** (main content)
- **Relationships** (wikilinks to related articles)
- **Sources** (which raw sources contributed)

Optional sections:

- **Open Questions** (gaps, unresolved contradictions)
- **Examples** (code snippets, worked examples)
- **History** (how this changed over time, if relevant)

### Troubleshooting Case Studies

When an article originates from a debugging/investigation session, use this structure instead:

- **Summary** (what went wrong, one paragraph)
- **Symptoms** (what the user/system reported, error messages, ticket numbers)
- **Investigation** (step-by-step debugging process, tools used, what each step revealed)
- **Root Cause** (the actual mechanism of failure)
- **Fix** (exact commands, PRs, DB queries to resolve)
- **Prevention** (systemic fixes, code changes, or checks to prevent recurrence)
- **Relationships** (wikilinks to related articles)
- **Sources** (tickets, PRs, conversations)

The investigative narrative matters. Someone facing the same symptoms should be able to follow the investigation path, not just skip to the answer.

## Tag Taxonomy

- Tags are freeform but should be reused consistently
- Check existing tags in \_index.md before creating new ones
- Maximum 5 tags per article

## Quality Settings

auto_publish: true
min_article_words: 150
staleness_threshold_days: 180
max_articles_per_domain: 100
contradiction_handling: preserve_both
index_grouping_threshold: 15

## Source Authority Hierarchy

Ranked from most to least authoritative:

1. Source code (what actually executes)
2. Official documentation
3. API specifications
4. Internal docs (Confluence, wiki, etc.)
5. Resolved tickets and incident postmortems
6. Blog posts and tutorials
7. Chat messages (Slack, Teams, etc.)
8. Forum answers and comments
```
