---
name: research
description: |
  Deep research and knowledge synthesis. Activates for ANY task involving
  factual claims, technical decisions, implementation patterns, or domain
  knowledge. Deactivated ONLY when the mechanical task test passes (all
  three conditions true).
---

# Research Skill

## Core Principle

The model does not "know" things. It synthesizes. This skill ensures that synthesis is grounded in externally verified human knowledge, not in training-data recall presented as fact.

## When NOT to Use

**Mechanical task test (research skips ONLY when ALL three are true):**
1. The exact change is fully specified by the user (no decisions needed)
2. No API, library, pattern, or tool selection is involved
3. The correctness of the change can be verified by syntax alone

If ANY answer is NO, research fires. Examples of mechanical: rename a variable to a user-specified name, move a file to a user-specified path, apply a formatter with existing config. Everything else triggers research.

## Prior Art Check

When the task involves building or implementing functionality, survey the solution landscape before writing code. Check the relevant ecosystem for existing tools, libraries, packages, APIs, MCP servers, platform extensions, and community solutions that address the same problem. This is part of the research mandate, not a separate step.

## Research Protocol

### Phase 0: Session Cache Check

Before executing Phases 1-3, check if prior research from this session covers the current question.

Reuse prior research ONLY when ALL three conditions hold:
1. The prior research was performed in the current session
2. The topic has not changed
3. The information is not time-sensitive

If all three hold, proceed to Phase 4 (Synthesize). Otherwise, execute Phases 1-3.

### Phase 1: Frame the Question

Before searching, define precisely what you need to know:
- What is the core claim or concept?
- What would confirm it? What would refute it?
- What domain does this fall in? (technical, philosophical, scientific, legal, etc.)

### Phase 2: Search with Intent

Use WebSearch and WebFetch to find primary and authoritative sources:
- Search for the concept + authoritative qualifiers (e.g., "specification", "RFC", "paper", "documentation")
- Search for the concept + known expert names or organizations
- Search for counterarguments and alternative views
- Search community discourse from qualified practitioners:
  - Reddit: relevant subreddits for practitioner experience reports
  - GitHub: issues, PRs, discussions for implementation examples and known problems
  - X/Twitter: tool creator posts documenting their approach
  - YouTube: niche practitioners demonstrating working implementations
  - Stack Overflow: high-quality answers with working code

### Phase 3: Filter Sources

Apply the source hierarchy from the source hierarchy (embedded in the agent's context or in the system rules):
- Prioritize Tier 1 and Tier 2 sources
- Use Tier 3 community discourse for practical context â€” apply the quality rubric
- Discard all blog posts except those by tool creators or core maintainers (reclassified as Tier 2)
- Discard AI-generated summaries regardless of disclaimers
- Note when evidence quality is limited

### Phase 4: Synthesize

Structure output as:

1. **Foundations**: Define terms precisely. Frame the question.
2. **Evidence**: Cite what primary and high-quality sources say. Summarize support.
3. **Counterposition**: Include at least one serious alternative view or limitation.
4. **Synthesis**: The best-supported current answer given all evidence.
5. **Confidence**: Label as verified, inferred, or unknown. State what evidence would improve certainty.

### Phase 5: Label Everything

- Every claim that originates from training data gets a confidence label
- Sources are cited with tier classification
- Gaps in evidence are stated explicitly
- Training-data-only claims are marked as `inferred` at best

## Anti-Patterns

- Stating something as fact because it "sounds right" from training data
- Using a single blog post as evidence for a critical claim
- Presenting consensus without checking if disagreement exists
- Stopping research after one confirming source
- Confusing popularity with correctness

