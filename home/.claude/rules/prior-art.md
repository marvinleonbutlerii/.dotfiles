# Prior Art Invariant

## Principle

Before building anything, survey the solution landscape. The first implementation question is never "how do I build this?" — it is "does this already exist?"

## Why

Building from scratch when a vetted solution exists wastes resources, introduces unnecessary risk, and ignores the accumulated work of the ecosystem. The default mode is discovery, not construction.

## Mandatory Reconnaissance Phase

Before any task that involves creating functionality, survey the relevant solution landscape. This phase produces a deliberate decision: build, integrate, adapt, or compose.

### What to survey

The full ecosystem relevant to the task. This includes but is not limited to: tools already available in the current environment (MCP servers, CLI tools, installed packages), package registries, platform extensions and plugins, APIs and services, platform-specific SDKs, community templates and boilerplates, and existing code in the current codebase.

The principle is "search the ecosystem." Any enumerated list is illustrative, not exhaustive.

### Decision framework

After surveying, choose one:

1. **Integrate**: An existing solution fully solves the problem. Use it.
2. **Adapt**: An existing solution partially solves the problem. Extend or configure it.
3. **Compose**: Multiple existing solutions can be combined. Wire them together.
4. **Build**: No adequate solution exists, or existing solutions fail on critical criteria (security, maintenance, dependency cost, performance). Build from scratch and document why existing solutions were rejected.

Option 4 requires explicit justification. "I didn't find anything" after a cursory search is not justification. "I surveyed X, Y, and Z; they fail because [specific reason]" is.

## Proportionality

The depth of reconnaissance scales with the cost of building:

- **Trivial** (a utility function, a config change): Quick mental check — is there an obvious existing solution? If not, proceed.
- **Moderate** (a feature, a service integration, a tool): Active search of package registries, relevant tool ecosystems, and community discourse. Brief but deliberate.
- **Significant** (an architecture component, a new system, a major feature): Thorough landscape survey including competing approaches and prior art. Document the survey results.

## Exceptions

- Purely mechanical tasks (rename, move, format) — no knowledge component, no reconnaissance needed.
- Explicit user instruction to build from scratch — the user has made the decision. Proceed, but note if a strong existing solution was found.
- Learning contexts where the point is to build it yourself.
