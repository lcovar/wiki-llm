# /wiki init

Initialize a new wiki knowledge base.

## Usage

```
/wiki init [path]
```

- Default path: `./wiki/`
- If path already contains a wiki (has SCHEMA.md), warn the user and abort

## Steps

### 1. Ask the User Two Questions

Before creating anything, ask:

1. **"What is this wiki about?"** — The domain. Examples: "our microservices architecture", "quantum computing research", "cooking recipes", "support knowledge for our SaaS product"
2. **"Who is the audience?"** — Who will query this wiki. Examples: "engineers on my team", "just me for learning", "support agents and engineers", "anyone onboarding to this codebase"

If the user skips (says "skip" or similar), use generic defaults. They can edit SCHEMA.md later.

### 2. Detect Wiki Type

From the user's answers, infer the wiki type. This affects hierarchy recommendations and compilation style:

| Type       | Signals                                      | Default Hierarchy       |
| ---------- | -------------------------------------------- | ----------------------- |
| `research` | papers, studies, concepts, learning          | Flat until 50+ articles |
| `code`     | repo, codebase, architecture, services, APIs | Grouped early           |
| `support`  | tickets, issues, customers, troubleshooting  | Hierarchical early      |
| `personal` | notes, reading, ideas, personal              | Flat for a long time    |
| `learning` | studying, course, textbook, new field        | Flat initially          |

### 3. Create Directory Structure

```
{path}/
  SCHEMA.md           # Generated from user answers + schema-template
  _index.md           # Empty, will be populated during compile
  _log.md             # Activity log, starts with init entry
  _sources.md         # Source manifest, starts empty
  raw/                # Raw ingested sources land here
  articles/           # Compiled wiki articles
  drafts/             # Articles pending review/promotion
  meta/               # Glossary, conventions, etc.
    glossary.md       # Empty starter glossary
```

### 4. Generate SCHEMA.md

Read `references/schema-template.md` for the template. Fill in:

- Domain from user's answer to question 1
- Audience from user's answer to question 2
- Wiki type from detection
- Sensible defaults for everything else

### 5. Initialize \_log.md

```markdown
# Wiki Activity Log

[{DATE}] INIT: Wiki created at {path}
Domain: {domain}
Type: {wiki_type}
Audience: {audience}
```

### 6. Initialize \_index.md

```markdown
# {Domain} Wiki

> {One-line description based on user's answers}

## Articles

_No articles yet. Run `/wiki ingest <source>` to add sources, then `/wiki compile` to create articles._
```

### 7. Initialize \_sources.md

```markdown
# Source Manifest

Tracks all ingested sources with content hashes for incremental compilation.

| Source File | Type | Ingested | Content Hash | Articles |
| ----------- | ---- | -------- | ------------ | -------- |
```

### 8. Offer CLAUDE.md Integration

Ask the user: "Want me to add wiki awareness to this project's CLAUDE.md? This lets future Claude sessions passively log observations to the wiki."

If yes, append to the project's CLAUDE.md (create if needed):

```markdown
## Wiki

A knowledge base exists at {path}/. It covers {domain}.

**Before starting work**, scan {path}/\_index.md to check if the wiki has articles relevant to your current task. If it does, read those articles for context before proceeding. If nothing is relevant, just move on.

When you encounter information during this session that:

- Contradicts existing wiki content
- Fills a gap the wiki doesn't cover
- Updates something the wiki documents with newer information

Append an observation to {path}/\_log.md:

[DATE] SESSION_OBSERVATION: "brief description of what was learned"
Context: what the user was working on
Relevant articles: [[existing-article]] if applicable
Suggested action: update | create | investigate

Do NOT auto-compile or modify wiki articles. Just log observations.
```

### 9. Offer Wiki Registration

If `~/.claude/wiki-registry.json` exists, offer to register this wiki. If it doesn't exist, ask if the user wants to create a registry (useful if they'll have multiple wikis).

Registry format:

```json
{
  "wikis": [
    {
      "name": "{short-name}",
      "path": "{absolute-path}",
      "domain": "{domain}",
      "type": "{wiki_type}",
      "created": "{date}"
    }
  ]
}
```

### 10. Summary

Print a summary:

```
Wiki initialized at {path}/
  Domain: {domain}
  Type: {wiki_type}
  Audience: {audience}

Next steps:
  /wiki ingest <source>  — Add a source (URL, file, repo, PDF)
  /wiki compile           — Compile sources into articles
  /wiki ask "question"    — Query the wiki
```
