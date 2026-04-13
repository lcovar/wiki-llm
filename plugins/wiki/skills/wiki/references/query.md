# /wiki ask

Query the wiki and synthesize an answer from compiled articles.

## Usage

```
/wiki ask "question"
/wiki ask --wiki ~/other-wiki "question"
```

## Pipeline

```
1. Find relevant articles (two-hop index search)
2. Read articles + follow links
3. Synthesize answer with citations
4. Assess confidence
5. Log gaps (if low confidence)
6. Offer insight crystallization (if novel synthesis)
```

## Step 1: Find Relevant Articles

### Two-Hop Search

**Hop 1: Master Index**

- Read `_index.md`
- From the article summaries, identify which articles are likely relevant to the question
- If the wiki uses domains/groups, identify which domains/groups to search

**Hop 2: Domain/Group Index (if hierarchical)**

- If the wiki has domain directories with their own `_index.md`, read those
- Identify the 5-15 most relevant articles based on summaries

**Why LLM-native search works:** You're reading summaries and using semantic understanding to find relevant articles. This is better than keyword search for questions like "how do these two things relate?" where no single keyword matches. The index is structured to be scannable.

### Article Selection

Select the most relevant articles. Guidelines:

- Start with the 3-5 most directly relevant
- Cap at 15 articles total (context budget)
- Prefer high-confidence articles over low-confidence ones
- Prefer recently updated articles over stale ones

## Step 2: Read and Assemble Context

1. Read the full content of selected articles
2. If an article references another via `[[wikilink]]` and that linked article seems relevant to the question, follow the link (one hop max)
3. Note any contradictions between articles
4. Note any gaps: the question asks about something the articles touch on but don't fully cover

## Step 3: Synthesize Answer

Answer the question using wiki content. Rules:

1. **Cite articles** using `[[article-name]]` notation so the user knows where information came from
2. **Distinguish wiki knowledge from general knowledge**: if you supplement with training knowledge (because the wiki doesn't fully cover something), say so: "The wiki doesn't cover X directly, but generally..."
3. **Don't hallucinate**: if the wiki doesn't have enough information, say so explicitly rather than making things up
4. **Handle contradictions**: if articles disagree, present both views and note the contradiction. Don't silently pick one.
5. **Be direct**: answer the question first, then provide supporting detail. Don't make the user read 3 paragraphs before getting the answer.

### Answer Format

```
{Direct answer to the question}

{Supporting details, explanation, context}

**Sources:** [[article-a]], [[article-b]], [[article-c]]
**Confidence:** {high|medium|low|no coverage}
```

## Step 4: Confidence Assessment

Rate the answer:

- **High**: 3+ articles directly address the question, no contradictions, information is recent
- **Medium**: 1-2 articles address it, or articles are tangentially related, or information may be stale
- **Low**: no articles directly address the question, answer relies heavily on training knowledge or extrapolation from loosely related articles
- **No coverage**: the wiki has nothing on this topic

Always report confidence to the user.

## Step 5: Gap Logging

If confidence is medium or lower, log the gap in `_log.md`:

```
[{DATE}] QUERY_GAP: "{question}"
  Confidence: {level}
  Articles consulted: [[article-a]], [[article-b]]
  Missing: {what knowledge is missing that would have improved the answer}
```

These gap entries accumulate and surface during `/wiki evolve` as priorities for new ingestion or research.

## Step 6: Insight Crystallization

After synthesizing, check: did this answer connect ideas from 2+ articles in a way that isn't explicitly stated in any single article?

Examples of crystallizable insights:

- A comparison between two approaches that exists in separate articles but isn't documented
- A pattern noticed across multiple articles (e.g., "3 out of 5 services use the same error handling pattern")
- A causal chain pieced together from multiple articles

If a novel insight was synthesized, offer to create a draft:

```
This answer connected ideas from [[article-a]], [[article-b]], and [[article-c]]
in a way that isn't captured in any existing article.

Create a draft article capturing this insight? [y/n]
```

If the user says yes:

- Create a draft in `drafts/` with frontmatter:
  ```yaml
  ---
  title: "{descriptive title for the insight}"
  origin: crystallized
  crystallized_from: ["{article-a}", "{article-b}", "{article-c}"]
  crystallized_query: "{original question}"
  confidence: medium
  created: { YYYY-MM-DD }
  ---
  ```
- Log in `_log.md`: `[{DATE}] CRYSTALLIZED: "{title}" from query "{question}"`

**Be conservative with crystallization.** Only offer it when the synthesis is genuinely novel and useful. If every query triggers a crystallization prompt, it becomes noise. The bar: "would someone searching for this topic benefit from having this as its own article?"

## Multi-Wiki Query

When `--wiki` specifies multiple wikis (comma-separated paths or names):

1. Read the master index from each wiki
2. Find relevant articles from each
3. Read articles from all wikis
4. Synthesize a unified answer, noting which wiki each piece of information came from
5. Cite as `[[wiki-name/article-name]]`

This is expensive (multiple index reads + cross-wiki articles). Use sparingly. If you're querying across wikis frequently, consider merging them.
