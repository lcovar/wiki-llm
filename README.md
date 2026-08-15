# wiki-llm

Claude Code skill plugin for building and maintaining LLM-compiled knowledge bases using the Karpathy wiki pattern.

## What it is

A skill plugin that turns scattered sources (URLs, files, repos, PDFs, conversations) into a maintained knowledge base. Raw sources go in, compiled interlinked wiki articles come out. The wiki compounds knowledge over time instead of rediscovering it from scratch on every question.

This is the Karpathy wiki pattern mechanized: compile knowledge once into persistent articles rather than reindexing raw sources every query. RAG rediscovers knowledge from scratch. A wiki compiles it once and keeps it current.

Source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## Quick start

```bash
# install the plugin
git clone https://github.com/luiscovarrubias/wiki-llm.git ~/.claude/plugins/wiki-llm
cd ~/.claude/plugins/wiki-llm
~/.claude/bin/plugin install plugins/wiki

# initialize a wiki in your project
cd ~/your-project
claude "/wiki init"

# ingest a source
claude "/wiki ingest https://docs.example.com/api"
claude "/wiki ingest ~/path/to/notes.md"
claude "/wiki ingest --conversation"  # capture current session

# query the wiki
claude "/wiki how does authentication work?"

# maintain quality
claude "/wiki lint"     # health checks
claude "/wiki status"   # stats
claude "/wiki evolve"   # suggest improvements
```

## Available commands

- `/wiki init [path]` — Initialize a new wiki
- `/wiki ingest <source>` — Add a source (URL, file, repo, PDF, `--conversation`, `--research "topic"`)
- `/wiki compile` — Compile raw sources into wiki articles
- `/wiki "<question>"` — Query the wiki with synthesized answers
- `/wiki lint` — Run health checks (broken links, orphans, staleness, contradictions)
- `/wiki evolve` — Suggest improvements based on gaps and structure
- `/wiki status` — Show wiki stats
- `/wiki promote` — Review and promote draft articles

## How it works

### Three layers

1. **Raw sources** (`raw/`) — Immutable. Articles, papers, code, tickets, conversations.
2. **The wiki** (`articles/`) — LLM-generated markdown: summaries, entity pages, concept pages, cross-references. The LLM owns this layer entirely.
3. **The schema** (`SCHEMA.md`) — Configuration that establishes conventions and workflows.

### Core operations

**Ingest:** Reads the source, creates or merges articles, updates cross-references, logs activity. A single source might touch 10-15 pages.

**Query:** Two-hop search (master index → domain index → articles). Synthesizes answer with citations. Logs gaps for low-confidence answers.

**Compile:** Extracts concepts from raw sources, creates or merges articles, validates quality, updates indexes.

**Lint:** Checks for broken links, orphans, stale articles, contradictions, sparse articles, missing index entries, duplicates.

**Evolve:** Reads gap log and session observations. Ranks improvement suggestions by impact.

### Principles

- **Plain files, no runtime.** The wiki is markdown files in a directory. No databases, no daemons.
- **Merge over create.** Default to enriching existing articles over creating new thin ones.
- **Schema-driven.** `SCHEMA.md` controls compilation style, terminology, and quality settings.
- **Quality gates on every write.** Nothing enters the wiki without passing validation.
- **Co-evolution through use.** Queries log gaps. Sessions capture observations. The wiki improves from being used.

## Structure

```
wiki/
├── SCHEMA.md         # Configuration: domain, style, terminology, quality rules
├── _index.md         # Master index of all articles
├── _log.md           # Chronological activity log
├── _sources.md       # Manifest of ingested sources
├── raw/              # Immutable sources
├── articles/         # Compiled wiki articles
├── drafts/           # Staged articles awaiting review
└── meta/             # Observations, gaps, contradictions
```

The structure scales with wiki size:

- **0-50 articles:** Flat `articles/` directory, single `_index.md`
- **50-200 articles:** Grouped subdirectories by tag/category
- **200+ articles:** Domain directories with their own indexes

## Passive learning

When a wiki exists in the project, every Claude Code session can passively log observations. The skill adds awareness to `CLAUDE.md` so that during normal work, Claude can capture useful knowledge without explicit user commands.

## Example workflow

```bash
# start a wiki for your codebase
cd ~/myproject
claude "/wiki init"

# ingest existing docs
claude "/wiki ingest ./docs"
claude "/wiki ingest https://api-docs.example.com"

# capture a debugging session
claude "figure out why auth is failing"
# ... session happens ...
claude "/wiki ingest --conversation"

# query compiled knowledge later
claude "/wiki how does token refresh work?"

# maintain quality
claude "/wiki lint"
claude "/wiki evolve"  # get suggestions, pick what to act on
```

## Why this works

The burden of wiki maintenance (updating cross-references, keeping summaries current, flagging contradictions, maintaining consistency) is what causes humans to abandon wikis. LLMs don't experience maintenance fatigue.

The human remains in charge of sourcing, direction, judgment, and exploration. The LLM handles summarization, cross-referencing, filing, bookkeeping, and consistency checks.

## Plugin structure

```
plugins/wiki/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   └── wiki.md              # User-facing /wiki command
│   └── wiki/
│       ├── compile.md
│       ├── lint.md
│       ├── status.md
│       ├── evolve.md
│       ├── ingest.md
│       └── promote.md
├── skills/
│   └── wiki/
│       ├── SKILL.md         # Skill definition and routing logic
│       └── references/      # Implementation details for each operation
├── hooks/
│   ├── hooks.json           # Hook configuration
│   ├── wiki-context.sh      # SessionStart: inject wiki awareness
│   ├── wiki-reminder.sh     # Stop: suggest capturing knowledge
│   └── find-wiki.sh         # Helper: locate active wiki
```

## License

MIT
