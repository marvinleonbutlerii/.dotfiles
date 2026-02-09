---
name: debugging
description: |
  Systematic debugging for any type of issue. Activates when any error,
  failure, or unexpected behavior is encountered during any task.
  Root-cause investigation at the deepest architectural level.
  Never symptom-by-symptom patching.
---

# Debugging Skill

## Core Principle

Find the generative mechanism, not the individual symptoms. Before solving any single error, examine the full error landscape to identify the deepest root cause that generates multiple symptoms.

## Debugging Protocol

### Phase 0: Landscape Assessment

This phase is NOT optional. It must complete before ANY individual error is touched.

1. **Survey all errors/symptoms** — list every failure, warning, and unexpected behavior
2. **Read the code holistically** — understand the architecture, not just the error site
3. **Identify patterns** — are multiple errors originating from the same root?
4. **Find the deepest origin** — where in the architecture does the problem first manifest?
5. **Decide: per-error fix or systemic refactor?** — if the same mistake appears in multiple places, the fix is a refactor, not per-error patching

### Phase 1: Reproduce

Before anything else, establish a reliable reproduction:

- Can reproduce the issue consistently
- Have a minimal reproduction case
- Know the exact steps to trigger it
- Have captured the exact error message/behavior

If you cannot reproduce, focus on reproduction first.

### Phase 2: Isolate

Narrow down the problem space:

1. **When did it last work?** Check recent changes
2. **What is different?** Environment, dependencies, data, timing
3. **Where does it fail?** Add logging/breakpoints to pinpoint location
4. **What type of failure?** Crash, wrong result, timeout, etc.

### Phase 2.5: Pattern Scan

After isolating the root cause location:

1. **Search the entire codebase** for the same pattern or mistake
2. **If found elsewhere**, the fix must be systemic, not local
3. **Map all instances** before fixing any single one
4. **Design a fix that addresses all instances** from the same root

### Phase 3: Research and Hypothesize

Before forming a hypothesis, research whether this error pattern is a known issue:
- Search GitHub issues for the library/framework involved
- Search Stack Overflow for the exact error message
- Check community discourse for practitioners who hit the same problem

Then form a single, specific hypothesis:

- BAD: "Something is wrong with the database"
- GOOD: "The query returns NULL because the user_id foreign key constraint fails on soft-deleted records"

A good hypothesis is:
- Specific enough to test
- Falsifiable (can be proven wrong)
- Based on evidence, not guessing
- Targeted at the mechanism layer, not the symptom layer

### Phase 4: Test

Design the minimal test for your hypothesis:

1. What change will you make?
2. What outcome confirms the hypothesis?
3. What outcome refutes the hypothesis?
4. How do you revert if wrong?

Make the change. Observe the result. Do NOT make additional changes.

### Phase 5: Evaluate

**If hypothesis confirmed:**
- Fix verified. Document the root cause.
- Scan the entire codebase for the same class of mistake. This is mandatory.
- Add a recurrence guard (test, assertion, linter rule).
- If partial fix, repeat from Phase 3 for remaining issue.

**If hypothesis refuted:**
- Revert your change.
- What did you learn?
- Form new hypothesis based on new information.
- Return to Phase 3.
