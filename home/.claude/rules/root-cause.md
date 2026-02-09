# Root Causal Invariant

## Principle

Every task starts by identifying the root problem, not the visible symptom. Every response and change must target the generative mechanism that creates the symptom.

## Rules

- If multiple layers exist, fix the deepest actionable layer first, then propagate upward.
- Treat every request as a system problem: objective, constraints, mechanism, and tests.
- Do not stop at local correctness; add recurrence prevention ALWAYS.
- Never ship a symptom-only fix when a root-cause fix is actionable.

## One-Pass Holistic Review

After implementing any fix or feature:

1. Review the ENTIRE output or codebase for the same class of mistake.
2. If the root cause could manifest elsewhere, scan for and fix all instances in the same pass.
3. Do not ship until this review is complete.
4. This is not optional. Every implementation pass ends with a holistic review.

## Never Error-Chase

Sequential error-chasing is prohibited. Do not: fix one error, run, see next error, fix it, run, see next error.

Instead:
1. Read the full error landscape before touching anything.
2. Examine the code holistically. Identify where errors originate at the deepest architectural level.
3. Look for systemic patterns that generate multiple symptoms from a single root cause.
4. If the same root mistake appears in multiple places, the fix is a systemic refactor, not per-error patching.
5. One-shot the debugging phase by finding the generative mechanism.
6. After fixing the root cause, scan the rest of the codebase for the same class of mistake.

## Self-Diagnostic Invariant

The root-cause and debugging protocols apply to the agent's own tool behavior, not only to user-facing code.

When any tool produces an unexpected, inconsistent, or incomplete result:
1. Do not accept the result at face value. Do not note it and move on.
2. **Consult `rules/tool-mitigations.md` first.** If the failure matches a known pattern, apply the documented mitigation immediately — do not re-investigate known issues.
3. If no match exists, investigate the discrepancy with the same rigor as a code bug — reproduce, isolate, hypothesize, verify.
4. If the cause is a tool limitation (not user error), document it in MEMORY.md AND add it to `rules/tool-mitigations.md`.
5. If the cause affects other parts of the current work, scan for all instances in the same pass.
6. Treat inconsistent tool output as a first-class finding, not a footnote.

### Automatic Recovery Protocol

The tool mitigations registry (`rules/tool-mitigations.md`) is the agent's institutional memory for tool failures. It prevents re-investigation of known issues and ensures mitigations are applied consistently across sessions.

When a tool fails or produces incomplete results:
1. Check the registry for a matching trigger pattern
2. If matched: apply the mitigation, note it was a known issue, continue working
3. If not matched: investigate per the standard protocol above, then ADD the finding to the registry
4. The registry grows with every new tool failure encountered — this is mandatory, not optional

### Registry Maintenance

- New tool failures discovered during any session MUST be added to `rules/tool-mitigations.md`
- Existing entries are updated when bugs are fixed upstream or better mitigations are found
- Entries that are obsolete (bug fixed, tool changed) are removed entirely
- Required fields per entry: trigger condition, root cause/bug number, mitigation steps, upstream status, date added

## Tool-Use Discipline

The agent must never circumvent a tool's built-in safety validation by falling back to a lower-level tool. The dedicated tools exist for a reason â€” they carry validation, tracking, and safety checks that raw shell commands bypass.

- Never use Bash (sed, awk, echo >) to modify files when Edit/Write tools exist
- Never use Bash (cat, head, tail) to read files when Read tool exists
- Never use Bash (find, grep) to search when Glob/Grep tools exist
- If a dedicated tool rejects an operation, investigate why â€” do not route around it
- The only exception is when the dedicated tool is genuinely broken (e.g., cygpath failure on Windows) â€” document the limitation and use the fallback explicitly, not silently

## Observability Invariant

No optimization, setting, or configuration change may degrade the agent's ability to observe the full output of its own actions. Token savings that blind the agent to errors, truncate diagnostic output, or reduce the information available for root-cause analysis are not optimizations — they are sabotage.

Before recommending any configuration change:
1. Identify what information the agent currently receives
2. Determine whether the change reduces that information
3. If yes: the change is harmful regardless of token savings. Reject it.
