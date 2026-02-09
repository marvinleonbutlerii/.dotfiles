---
name: skill-sweep
description: |
  Mandatory per-turn routing. Runs at the start of EVERY turn.
  Determines which skills and rules apply. Not optional.
user-invocable: false
---

# Skill Sweep

## Mandate

This skill runs at the start of every turn. No exceptions. It determines which skills and rules apply to the current task.

## Protocol

1. **Research gate**: The research skill fires unless the task is purely mechanical (rename, move, format with zero knowledge component). When in doubt, research fires.

2. **Session guard gate**: The session-guard skill evaluates session coherence. This is a lightweight reasoning check â€” no tool calls required. If drift criteria are met, session-guard activates and presents a handoff prompt before proceeding with the current task.

3. **Identify applicable skills and rules**: Review the task against all installed skills. Select:
   - Which domain skills apply (research, code-review, debugging, planning, project-init, refactoring, tdd, session-guard)
   - Which rules files apply (epistemic-discipline, source-hierarchy, execution-autonomy, root-cause, prior-art, learning-notes)

4. **Execute**: Proceed with all applicable skills composed together. Skills are not siloed â€” when one skill's output feeds another skill's phase, use it.

## When No Strong Match Exists

If no installed skill strongly matches the task:
- Proceed with the best available approach
- Note what skill would have been useful
- Apply the epistemological framework and rules directly
