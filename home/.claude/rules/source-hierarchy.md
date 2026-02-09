# Source Hierarchy

## What Counts as Valid Knowledge

Sources are ranked by reliability. Higher tiers take precedence in case of conflict.

### Tier 1: Foundational Sources
- Research papers and academic publications
- Peer-reviewed literature and primary datasets
- Government documents and regulatory text
- Official specifications and standards bodies (IEEE, W3C, IETF, ISO, etc.)

### Tier 2: Authoritative Technical Sources
- Official vendor documentation and product specifications
- Canonical source code and tagged releases in authoritative repositories
- Official API references and SDK documentation
- Blog posts, articles, or tutorials written by the creator or core maintainer of the tool/library being discussed â€” these function as de facto documentation

### Tier 3: Qualified Community Discourse

Any platform where practitioners interact directly with each other qualifies. The platform name is irrelevant. What matters is the rubric below.

#### Credibility Rubric â€” ALL must hold:
1. The author demonstrates domain expertise through their contribution history, maintainer status, or verifiable track record
2. The claim is corroborated by at least one independent source
3. Working code, reproducible evidence, or demonstrated results are provided

When fewer than all three hold, label the source explicitly and note what is missing.

#### Platform Signal Indicators
A platform hosts qualified discourse when:
- Users can respond to, challenge, and build on each other's claims
- Contribution history is visible and inspectable
- The community has mechanisms for surfacing quality (votes, reactions, maintainer endorsements, peer review)
- Technical depth is the norm, not the exception

**Examples (non-exhaustive):** Reddit, GitHub (issues/PRs/discussions), Stack Overflow, Discord servers, Discourse forums, mailing lists, X/Twitter, YouTube, Hacker News, Telegram groups, Matrix channels, specialized technical forums, IRC logs

#### Per-Source Evaluation â€” regardless of platform:
- Proximity to source code (closer = stronger signal)
- Involvement of maintainers or recognized experts
- Presence of working, testable code
- Resolution status (solved problems > open speculation)
- Recency relative to the technology's release cycle
- Corroboration from independent practitioners

### Tier 4: Field Evidence
- Practitioner threads and experience reports explicitly labeled as field evidence
- Conference talks and technical presentations with demonstrated results
- Well-maintained wikis and community-curated references

## Source Quality Test

Every source must pass this test regardless of its format label (blog, article, news, tutorial, guide, etc.):

1. Does the author demonstrate first-hand expertise? (built it, maintained it, debugged it, measured it — not summarized someone else's work)
2. Is the content independent of commercial interest? (not selling the solution it recommends, not SEO-optimized content marketing)

Sources that fail EITHER of these are excluded regardless of format.
Sources that pass BOTH are admissible regardless of format.

Evidence (working code, measured data, reproducible steps, linked primary sources) elevates confidence but is not a gate. An experienced maintainer's account without reproducible steps is admissible at reduced confidence. A content farm article with a code snippet is still excluded (fails test 1).

The following are ALWAYS excluded (no test needed):
- AI-generated content regardless of disclaimers
- Content that does not cite its own evidence
- Sponsored content or product marketing disguised as technical guidance

## Usage Rules

- When using Tier 3 or Tier 4 sources, label them explicitly (e.g., "community evidence", "field report")
- Multiple independent sources at the same tier increase confidence
- Absence of disagreement among qualified sources does NOT equal consensus; look for active confirmation
- A single Tier 1 source outweighs multiple Tier 4 sources
- If only excluded sources are available, state that evidence quality is low and label the claim accordingly

