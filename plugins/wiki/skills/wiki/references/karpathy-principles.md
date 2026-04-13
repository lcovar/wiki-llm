# Karpathy Wiki Principles

Core philosophy from Andrej Karpathy's LLM wiki pattern. These principles guide how the skill compiles, maintains, and evolves knowledge.

Source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## The Core Insight

RAG rediscovers knowledge from scratch on every query. A wiki compiles knowledge once and keeps it current. The wiki is a persistent, compounding artifact. Each new source doesn't just get stored, it gets integrated: cross-references updated, contradictions flagged, summaries revised, gaps identified.

## Three-Layer Architecture

1. **Raw sources** — Immutable. The LLM reads but never modifies these. Articles, papers, code, tickets, conversations.
2. **The wiki** — LLM-generated markdown files: summaries, entity pages, concept pages, cross-references. The LLM owns this layer entirely, creating and updating pages as new sources arrive.
3. **The schema** — Configuration that establishes conventions and workflows. Guides how the LLM processes sources, answers questions, and maintains the wiki.

## Three Core Operations

**Ingest**: Add a new source. The LLM reads it, discusses takeaways, writes a summary page, updates the index, revises relevant entity and concept pages, and logs the entry. A single source might touch 10-15 wiki pages.

**Query**: Ask questions against the wiki. Search relevant pages, synthesize answers with citations, and optionally file valuable outputs back into the wiki as new pages (crystallization).

**Lint**: Periodically health-check for contradictions, stale claims superseded by newer sources, orphan pages, missing cross-references, and data gaps. Suggest new investigation directions.

## Article Style

When compiling wiki articles, follow these principles:

- **Encyclopedic prose, not bullet lists** (unless listing discrete items). Write like a well-maintained wiki, not like meeting notes.
- **Synthesize, don't summarize**. Don't just reformat the source. Extract the knowledge, connect it to what's already known, and write something more useful than the original.
- **One source might touch 10-15 pages**. A single ingested document should update the index, create or update entity/concept pages, add cross-references, and log the activity. Don't just create one article per source.
- **Cross-reference aggressively**. The value of a wiki is in the connections. Every article should link to related articles. Every concept mentioned that has its own page should be linked.
- **Preserve specifics**. Numbers, dates, version numbers, code snippets, error messages, benchmarks. These are what make wiki articles useful vs. generic summaries.
- **Flag contradictions, don't hide them**. When new information conflicts with existing articles, mark both sides explicitly. Never silently overwrite.
- **The index is the search mechanism**. index.md is a content-oriented catalog with one-line summaries per article. It's how the LLM (and humans) find relevant pages. Keep it current, keep it scannable.
- **The log is the timeline**. log.md is append-only, chronological. Every ingest, query, and lint pass gets logged. This enables tracking what was learned when.

## Why This Works

The core burden of knowledge base maintenance (updating cross-references, keeping summaries current, flagging contradictions, maintaining consistency) is what causes humans to abandon wikis. LLMs don't experience maintenance fatigue. By shifting bookkeeping to the model while humans focus on curation and direction, the wiki stays alive.

## The Human's Role

The human remains in charge of:

- **Sourcing**: deciding what to ingest
- **Direction**: deciding what questions to ask
- **Judgment**: resolving contradictions, promoting drafts, setting quality standards
- **Exploration**: browsing the wiki, noticing patterns, following threads

The LLM handles:

- **Summarization**: distilling sources into articles
- **Cross-referencing**: maintaining links between related articles
- **Filing and bookkeeping**: indexes, logs, source manifests
- **Consistency**: flagging contradictions, staleness, gaps
