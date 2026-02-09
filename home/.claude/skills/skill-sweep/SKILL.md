---
name: skill-sweep
description: |
  Mandatory per-turn gate protocol. Runs at the start of EVERY turn.
  Four sequential gates must be evaluated before any work begins.
  Not optional. Not skippable. Not implicit.
user-invocable: false
---

# Skill Sweep — Turn Protocol

## Mandate

This protocol executes at the start of every turn. Four gates, in order. Each gate produces an explicit output before the next gate opens. Skipping a gate is a protocol violation.

## Gate 1: Session Guard

**Time:** ~10 seconds. **Tools:** None (reasoning only).

Evaluate session coherence against these criteria:
- 3+ distinct problem domains actively in play
- Current task has no logical connection to the session's first task
- Context has been compacted AND new unrelated work is being added
- Error recovery has permanently shifted focus from original goal
- 2+ tasks are partially done with context competing for space

**Output:** `CLEAR` or `DRIFT DETECTED` (if drift, present handoff prompt per session-guard skill before continuing).

## Gate 2: Research

**Decision test — the task is mechanical ONLY when ALL three are true:**
1. The exact change is fully specified by the user (no decisions needed)
2. No API, library, pattern, or tool selection is involved
3. The correctness of the change can be verified by syntax alone

**If ANY answer is NO:** research fires. Execute the research skill protocol (WebSearch/WebFetch for Tier 1/2 sources, community discourse, prior art check). No exceptions.

**If ALL three are YES:** skip research.

**Output:** `RESEARCH COMPLETE` (with key findings) or `MECHANICAL TASK` (with three YES justifications).

## Gate 3: Skill Routing

Review the task against all installed skills. Select which apply:

- **Domain skills:** research, code-review, debugging, planning, project-init, refactoring, tdd
- **Rules:** epistemic-discipline, source-hierarchy, execution-autonomy, root-cause, prior-art, learning-notes

Skills compose together. When one skill's output feeds another skill's phase, use it.

**Output:** List of active skills and rules for this turn.

## Gate 4: Execution + Holistic Review

Execute with all active skills composed. Before shipping ANY output:

1. Review the ENTIRE output for the same class of error (per `rules/root-cause.md` § One-Pass Holistic Review)
2. If code was modified, scan the codebase for the same pattern or mistake
3. If the root cause could manifest elsewhere, fix all instances in this pass

**Output:** `SHIPPED` after holistic review is complete. Never before.

## When No Strong Skill Match Exists

- Proceed with the best available approach
- Note what skill would have been useful
- Apply the epistemological framework and rules directly
- Gates 1, 2, and 4 still apply regardless
