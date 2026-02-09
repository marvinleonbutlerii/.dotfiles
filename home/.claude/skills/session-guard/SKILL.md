---
name: session-guard
description: |
  Monitors session scope and entropy. Activates automatically via skill-sweep.
  Detects when the conversation has drifted significantly from its original
  intent or has accumulated too many unrelated threads. Warns the user and
  generates a handoff prompt for a new session.
user-invocable: false
---

# Session Guard

## Mandate

This skill monitors session coherence. It activates via skill-sweep on every turn — not manually invoked.

## Detection Criteria

Flag the session when ANY of these hold:

1. **Domain sprawl**: 3+ distinct problem domains are actively in play (e.g., dotfiles config + API debugging + UI refactoring)
2. **Disconnected tasks**: The current task has no logical dependency on or connection to the session's first task
3. **Context saturation**: The conversation has been compacted/summarized AND new unrelated work is being added on top
4. **Recovery drift**: Error recovery or troubleshooting has shifted the session's focus permanently away from the original goal
5. **Interleaved incomplete work**: 2+ tasks are partially done with context for each competing for space

## When NOT to Flag

- Tasks that are logically connected steps of a single goal (e.g., "implement feature" → "write tests" → "refactor")
- Deepening investigation within a single domain (e.g., debugging leads to architecture investigation)
- Normal follow-up questions about completed work

## Protocol

When drift is detected:

### Step 1: Inform

Tell the user clearly and concisely:

> **Session scope notice:** This session now covers [list domains]. Continuing to add unrelated work will reduce quality as context competes for space. Recommend splitting into focused sessions.

### Step 2: Generate Handoff Prompt

Produce a structured prompt the user can copy-paste into a new session:

```
## Session Handoff — [Date]

### Context
[1-2 sentence summary of what this session accomplished]

### Remaining Tasks
- [ ] [Task 1 with enough context to resume]
- [ ] [Task 2 with enough context to resume]

### Key Findings This Session
- [Finding 1 — include file paths]
- [Finding 2 — include file paths]

### Current State
- Files modified: [list]
- Files created: [list]
- Pending: [what still needs doing]

### Reference Files
- [path/to/key/file — what it contains]
```

### Step 3: Continue or Split

After presenting the handoff prompt:
- If the user chooses to continue, proceed — do not nag
- If the user copies the prompt, acknowledge and focus the current session on its remaining scope
- Never block the user from continuing; this is advisory, not enforcement

## Integration with Skill-Sweep

Skill-sweep evaluates session-guard every turn. The evaluation is lightweight — it does not require research or tool calls. It is a reasoning-only check based on the conversation history visible to the agent.