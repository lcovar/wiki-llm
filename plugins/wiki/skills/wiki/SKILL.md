---
name: wiki
description: "Build and maintain LLM-compiled knowledge bases following the Karpathy wiki pattern. Use when the user wants to create a knowledge base, ingest sources into a wiki, query compiled knowledge, or maintain wiki quality. Triggers: /wiki, knowledge base, wiki, ingest sources, compile articles."
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebFetch
  - WebSearch
  - Agent
---

# Wiki Skill

A Claude Code skill for building and maintaining LLM-compiled knowledge bases following the Karpathy wiki pattern. Raw sources go in, compiled interlinked wiki articles come out. The wiki compounds knowledge over time instead of rediscovering it from scratch on every question.

## When to Use

- Building a knowledge base from scattered sources (docs, repos, URLs, PDFs, conversations)
- Querying compiled knowledge with synthesized, cited answers
- Maintaining wiki quality: detecting contradictions, staleness, orphans, gaps
- Capturing knowledge from the current conversation for future reference
- Researching a topic and compiling findings into structured articles
- Onboarding to a codebase or domain by compiling existing documentation

## Command Routing

Parse the user's `/wiki` subcommand and dispatch accordingly:

| Command                 | Action                                                                                                                     |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `/wiki init [path]`     | Initialize a new wiki. Read `references/init.md` for full instructions.                                                    |
| `/wiki ingest <source>` | Ingest a source (URL, file, repo, PDF, directory, `--research "topic"`, or `--conversation`). Read `references/ingest.md`. |
| `/wiki compile`         | Compile new/changed raw sources into wiki articles. Read `references/compile.md`.                                          |
| `/wiki "<question>"`    | Query the wiki and synthesize an answer. Read `references/query.md`.                                                       |
| `/wiki lint`            | Run health checks on the wiki. Read `references/lint.md`.                                                                  |
| `/wiki evolve`          | Suggest improvements based on gaps, observations, and structure. Read `references/evolve.md`.                              |
| `/wiki status`          | Show wiki stats. Read `references/status.md`.                                                                              |
| `/wiki promote`         | Review and promote draft articles to the wiki. Read `references/promote.md`.                                               |

**Default behavior:** If the argument doesn't match a known subcommand (init, ingest, compile, lint, evolve, status, promote), treat it as a question and route to the query pipeline. So `/wiki "how does auth work?"` and `/wiki ask "how does auth work?"` both work.

## Wiki Detection

Find the active wiki in this order:

1. If the user passes a path (`/wiki --wiki ~/my-wiki "question"`), use that
2. Look for a `wiki/` directory in the current working directory
3. Look for a `wiki/` directory in parent directories (up to 3 levels)
4. Check `~/.claude/wiki-registry.json` for registered wikis
5. If none found, tell the user: "No wiki found. Run `/wiki init` to create one, or specify a path."

## Karpathy Principles

Before any compilation or query operation, read `references/karpathy-principles.md` for the foundational philosophy. The wiki pattern comes from Andrej Karpathy: compile knowledge once into interlinked articles rather than rediscovering it from scratch every query.

## Key Principles

1. **Plain files, no runtime.** The wiki is markdown files in a directory. No databases, no daemons. Claude reads and writes files directly. The index files ARE the search index.

2. **Merge over create.** Default to enriching existing articles over creating new thin ones. The wiki should have fewer, richer articles.

3. **Schema-driven.** `SCHEMA.md` controls compilation style, terminology, and quality settings. Same skill works for quantum physics and cooking recipes.

4. **Quality gates on every write.** Nothing enters the wiki without passing validation. Articles must be substantive, non-duplicate, and schema-compliant.

5. **Co-evolution through use.** Queries log gaps. Sessions capture observations. The wiki improves from being used, not just from explicit ingestion.

## Quick Reference

**Init:** Creates `wiki/` with SCHEMA.md, \_index.md, \_log.md, \_sources.md, raw/, articles/, drafts/, meta/.

**Ingest:** Auto-detects source type. Fetches/copies to `raw/` with frontmatter. Auto-triggers compile unless `--no-compile` is passed.

**Compile:** Reads new/changed files from `raw/`. Extracts concepts. Creates or merges articles. Validates quality. Updates cross-links and indexes. Logs activity.

**Ask:** Two-hop search: master index -> domain/group index -> articles. Synthesize answer with citations. Score confidence. Log gaps for low-confidence answers.

**Lint:** Checks for broken links, orphans, stale articles, contradictions, sparse articles, missing index entries, tag inconsistencies, duplicates.

**Evolve:** Reads gap log, session observations, and wiki structure. Ranks improvement suggestions by impact. User picks which to act on.

## Passive Learning

When a wiki exists in the project, the skill adds awareness to CLAUDE.md so that every Claude Code session can passively log observations. See `references/init.md` for the CLAUDE.md snippet.

## Adaptive Hierarchy

The directory structure scales with wiki size:

- **0-50 articles:** Flat `articles/` directory, single `_index.md`
- **50-200 articles:** Grouped subdirectories by tag/category
- **200+ articles:** Domain directories with their own indexes

Transitions are suggested during `/wiki compile` or `/wiki evolve` when thresholds are crossed.
