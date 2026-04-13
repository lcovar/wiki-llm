# /wiki ingest

Ingest a source into the wiki's `raw/` directory for compilation.

## Usage

```
/wiki ingest <source>
/wiki ingest --research "topic"
/wiki ingest --conversation ["optional topic name"]
/wiki ingest --no-compile <source>
```

## Source Type Detection

Auto-detect the source type from the input:

| Input Pattern                                              | Type         | Handler              |
| ---------------------------------------------------------- | ------------ | -------------------- |
| URL containing `github.com`, `gitlab.com`, `bitbucket.org` | repo         | Repo Handler         |
| URL starting with `http://` or `https://`                  | web          | Web Handler          |
| File path ending with `.pdf`                               | pdf          | PDF Handler          |
| Path to a directory                                        | directory    | Directory Handler    |
| `--research "topic"` flag present                          | research     | Research Handler     |
| `--conversation` flag present                              | conversation | Conversation Handler |
| File path (anything else)                                  | file         | File Handler         |

## Pre-Ingestion Validation (Gate 1)

Before spending any LLM tokens, check:

1. **Source accessible:** Can the URL be fetched? Does the file exist?
2. **Not already ingested:** Check `_sources.md` for duplicate URLs or file paths. If already ingested with the same content hash, tell the user and skip (unless `--force` is passed).
3. **Size reasonable:** If source is >50K words or >100 pages, warn the user and suggest chunking or focusing on specific sections.
4. **Supported type:** Is this something the skill knows how to handle?

If validation fails, report the issue and stop. Don't spend tokens on bad inputs.

## Web Handler

1. Fetch the URL using `WebFetch`
2. Read the fetched content. Extract the substantive content: the actual article, documentation, or information. Strip navigation, footers, ads, cookie banners, sidebars, and boilerplate. Use judgment, not regex.
3. Save to `raw/` as markdown with frontmatter:

```markdown
---
source_type: web
url: "{url}"
title: "{extracted page title}"
fetch_date: { YYYY-MM-DD }
content_hash: { first 8 chars of sha256 of content }
---

{extracted content in markdown}
```

Filename: `raw/web-{slugified-title}.md` (lowercase, hyphens, max 60 chars)

## Repo Handler

1. Clone the repo (shallow: `git clone --depth 1`) to a temp directory
2. Read structural files first:
   - README.md, CONTRIBUTING.md
   - Package manifests: package.json, Cargo.toml, pyproject.toml, go.mod, etc.
   - Architecture docs if they exist: docs/, ARCHITECTURE.md, etc.
3. Identify architecture-relevant code:
   - API route definitions (`**/routes/**`, `**/api/**`, `**/handlers/**`)
   - Database schemas (`**/schema/**`, `**/models/**`, `**/migrations/**`)
   - Config files
   - Main entry points
   - Error types/codes
4. Generate a structured analysis as markdown covering:
   - What the repo does (from README + code inspection)
   - Tech stack and key dependencies
   - Architecture: major modules/services and how they connect
   - Key concepts: domain objects, APIs, data flows
   - Notable patterns or design decisions
5. Save to `raw/repo-{repo-name}.md` with frontmatter:

```markdown
---
source_type: repo
url: "{repo-url}"
name: "{repo-name}"
fetch_date: { YYYY-MM-DD }
content_hash: { hash }
tech_stack: ["{lang}", "{framework}", ...]
---

{structured analysis}
```

6. Clean up the temp directory
7. Note: the analysis should focus on concepts and architecture, NOT list every file. A 500-file repo should produce a 500-2000 word analysis, not a file listing.

## PDF Handler

1. Read the PDF using the Read tool (native PDF support, max 20 pages per read)
2. For large PDFs (>20 pages): read in chunks, focusing on key sections (abstract, introduction, conclusions, key figures)
3. Extract into markdown:
   - Title, authors, date
   - Abstract/summary
   - Key claims, findings, data points
   - Important figures/tables (described in text)
   - References to other works
4. Save to `raw/pdf-{slugified-title}.md` with frontmatter:

```markdown
---
source_type: pdf
original_path: "{path}"
title: "{title}"
authors: ["{author1}", "{author2}"]
date: "{publication date if known}"
ingest_date: { YYYY-MM-DD }
content_hash: { hash }
pages: { total pages }
---

{extracted content}
```

5. Note when content couldn't be fully captured: "Figure 3: [complex diagram, see original PDF page 12]"

## File Handler

1. Read the file directly
2. If it's already well-structured markdown, preserve the structure
3. Add frontmatter if missing:

```markdown
---
source_type: file
original_path: "{absolute path}"
title: "{filename or first heading}"
ingest_date: { YYYY-MM-DD }
content_hash: { hash }
---

{file content}
```

4. Copy to `raw/file-{filename}.md`

## Directory Handler

1. Glob for supported file types: `*.md`, `*.txt`, `*.pdf`, `*.rst`
2. Count the files. If >20 files, warn the user:
   ```
   Found {N} files. Batch ingestion works best in groups of 10-20.
   Process all {N} at once, or in batches? [all/batches]
   ```
3. For each file, dispatch to the appropriate handler (PDF, file)
4. After all files are ingested, trigger a single compile pass for all new sources

## Research Handler

1. Use `WebSearch` to find 5-10 sources on the topic
2. Evaluate search result snippets for relevance. Skip obviously irrelevant results.
3. Fetch the top 3-5 most promising URLs with `WebFetch`
4. Process each fetched page through the Web Handler (save individually to `raw/`)
5. Log which sources were used and which were skipped
6. Note subtopics that weren't well covered (these become gap entries in `_log.md`)
7. Trigger compile with a note that these sources should be compiled together as a coherent set

## Conversation Handler

Captures knowledge from the current Claude Code conversation and saves it as a wiki source.

**Detection**: `--conversation` flag present.

**Usage**:

```
/wiki ingest --conversation                        # auto-detect topic from conversation
/wiki ingest --conversation "fee estimation deep dive"  # optional topic name
```

**Pipeline**:

1. Reflect on the current conversation from the beginning
2. Identify the substantive knowledge: findings, explanations, decisions, discoveries, debugging insights, architecture understanding, behavioral quirks of systems, anything that would be useful to know in the future
3. Ignore the noise: back-and-forth clarifications, "let me check that", tool output, error messages that were just stepping stones, pleasantries
4. If no topic name was provided, generate one from the conversation's main theme
5. Detect conversation type and pick the right template:

**Type detection**: Look at the conversation's nature. If it involves debugging, support tickets, root cause analysis, incident investigation, or error tracing, use the **troubleshooting template**. Otherwise, use the **general template**.

6. Write a structured source file using the appropriate template:

**General template** (architecture discussions, design decisions, learning sessions):

```markdown
---
source_type: conversation
conversation_type: general
topic: "{topic name, provided or auto-generated}"
session_date: { YYYY-MM-DD }
ingest_date: { YYYY-MM-DD }
content_hash: { hash }
---

# {Topic Name}

## Context

{What was the user working on? What prompted this conversation?}

## Key Findings

{The substantive knowledge extracted from the conversation. Written as clear, standalone prose, not a transcript. Someone reading this should understand the knowledge without needing to see the original conversation.}

## Decisions Made

{Any decisions or conclusions reached during the conversation, with reasoning.}

## Open Questions

{Anything unresolved or worth investigating further.}
```

**Troubleshooting template** (debugging sessions, support tickets, incident investigations):

```markdown
---
source_type: conversation
conversation_type: troubleshooting
topic: "{topic name, provided or auto-generated}"
tickets: ["{TICKET-123}", "{TICKET-456}"]
session_date: { YYYY-MM-DD }
ingest_date: { YYYY-MM-DD }
content_hash: { hash }
---

# {Topic Name}

## Context

{What ticket(s) or issue prompted this? What were the symptoms? Include full wallet IDs, txids, error messages.}

## Investigation Steps

{The step-by-step debugging process in order. What did we check first? What tools did we use? What did each step reveal? Preserve the investigative narrative so someone facing a similar issue can follow the same path.}

## Root Cause

{What was actually wrong? Be specific. Include the exact mechanism, not just a summary.}

## Fix Applied

{What was done to fix it? Include specific commands, PR numbers, DB queries, job configs. Someone should be able to replicate the fix.}

## Tools & Techniques

{What tools were used during investigation? Include specific commands, gotchas, and tips discovered. Example: "mempool.space outspend API returns spent:false for non-existent outputs, must verify parent tx exists separately."}

## Broader Implications

{Does this point to a systemic issue? Are other wallets/transactions affected? Should code be changed to prevent recurrence?}

## Open Questions

{Anything unresolved or worth investigating further.}
```

7. Save to `raw/conversation-{slugified-topic}-{date}.md`
8. Auto-trigger compile

**Quality considerations**: Conversations are messy. The extraction should be aggressive about filtering. A 200-message debugging session might produce 300 words of actual knowledge. That's fine. The value is in distilling the signal, not preserving the volume. If the conversation didn't produce any substantive knowledge worth keeping, say so and skip the ingest rather than creating a thin source file.

## Post-Ingestion

After saving to `raw/`:

1. Update `_sources.md` with the new source entry:
   ```
   | {filename} | {type} | {date} | {hash} | pending |
   ```
2. Log the ingestion in `_log.md`:
   ```
   [{DATE}] INGEST: {source_type} "{title}" -> raw/{filename}
   ```
3. Unless `--no-compile` was passed, automatically run the compilation pipeline (see `references/compile.md`)

## Re-Ingestion

If a source was previously ingested (same URL or path):

- Fetch/read the new version
- Compare content hash with `_sources.md`
- If unchanged: "Source hasn't changed since last ingestion. Skip? [y/n]"
- If changed: ingest the new version, mark old articles as potentially needing update, trigger compile
