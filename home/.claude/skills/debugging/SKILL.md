---
name: debugging
description: |
  Systematic debugging approach for any type of issue. Use when something
  is broken, behaving unexpectedly, or producing errors. Emphasizes
  hypothesis-driven investigation over random changes.
---

# Debugging Skill

## Core Principle

**One hypothesis at a time, smallest possible change, verify before continuing.**

Never "try a bunch of things and see what works." Each debugging step should:
1. Test a single hypothesis
2. Make the minimal change needed
3. Provide clear pass/fail signal

## Debugging Protocol

### Phase 1: Reproduce

Before anything else, establish a reliable reproduction:

```
[ ] Can reproduce the issue consistently
[ ] Have a minimal reproduction case
[ ] Know the exact steps to trigger it
[ ] Have captured the exact error message/behavior
```

If you cannot reproduce, debugging is premature. Focus on reproduction first.

### Phase 2: Isolate

Narrow down the problem space:

1. **When did it last work?** Check recent changes
2. **What's different?** Environment, dependencies, data, timing
3. **Where does it fail?** Add logging/breakpoints to pinpoint location
4. **What type of failure?** Crash, wrong result, timeout, etc.

### Phase 3: Hypothesize

Form a single, specific hypothesis:

- BAD: "Something's wrong with the database"
- GOOD: "The query is returning NULL because the user_id foreign key constraint is failing"

A good hypothesis is:
- Specific enough to test
- Falsifiable (can be proven wrong)
- Based on evidence, not guessing

### Phase 4: Test

Design the minimal test for your hypothesis:

1. What change will you make?
2. What outcome confirms the hypothesis?
3. What outcome refutes the hypothesis?
4. How do you revert if wrong?

Make the change. Observe the result. Do NOT make additional changes.

### Phase 5: Evaluate

Did the test pass or fail?

**If hypothesis confirmed:**
- Fix verified, document and commit
- If partial fix, repeat from Phase 3 for remaining issue

**If hypothesis refuted:**
- Revert your change
- What did you learn?
- Form new hypothesis based on new information
- Return to Phase 3

### Common Debugging Mistakes

1. **Changing multiple things at once** - Impossible to know what worked
2. **Not reverting failed attempts** - Accumulating cruft obscures the real issue
3. **Fixing symptoms not causes** - Issue will return in different form
4. **Assuming you know the cause** - Let evidence guide you
5. **Giving up too early** - Systematic approach always finds the bug

## Debugging Questions to Ask

- What changed recently?
- What are the exact inputs?
- What is the exact error (full text)?
- What did you expect to happen?
- What actually happened?
- Is it environment-specific?
- Is it data-specific?
- Is it timing-specific?
- What have you already tried?

## Output Format

When reporting debugging findings:

```markdown
## Issue
[One sentence description]

## Reproduction
[Exact steps to reproduce]

## Investigation
1. [Hypothesis 1]: [Result]
2. [Hypothesis 2]: [Result]
...

## Root Cause
[What actually caused the issue]

## Fix
[What change resolves it]

## Verification
[How we confirmed it's fixed]

## Prevention
[How to prevent this in the future]
```
