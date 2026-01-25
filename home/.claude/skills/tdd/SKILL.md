---
name: tdd
description: |
  Test-Driven Development workflow. Use when implementing new features,
  fixing bugs, or refactoring code. Enforces Red-Green-Refactor discipline
  and ensures tests are written BEFORE implementation.
---

# Test-Driven Development Skill

## Core Principle

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.**

Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles.

## The Red-Green-Refactor Cycle

### 1. RED: Write a Failing Test

Before writing ANY production code:

```
[ ] Write a test that describes the desired behavior
[ ] Run the test - it MUST fail
[ ] Verify it fails for the RIGHT reason
[ ] If it passes, you wrote the wrong test
```

The test should:
- Be small and focused on one behavior
- Have a descriptive name explaining what it tests
- Fail with a clear error message
- Not test implementation details

### 2. GREEN: Make It Pass

Write the MINIMUM code to make the test pass:

```
[ ] Write only enough code to pass the test
[ ] Don't anticipate future requirements
[ ] Don't add "obvious" improvements
[ ] Run the test - it MUST pass
[ ] All previous tests must still pass
```

Rules:
- No new functionality without a test
- No "while I'm here" additions
- Resist the urge to optimize
- Ugly code is fine at this stage

### 3. REFACTOR: Improve the Code

Now, and ONLY now, improve the code:

```
[ ] Tests are green before refactoring
[ ] Make one small change at a time
[ ] Run tests after each change
[ ] Tests must stay green throughout
[ ] Stop when code is clean enough
```

Refactoring opportunities:
- Remove duplication
- Improve naming
- Extract methods/functions
- Simplify conditionals
- Apply design patterns

## Test Quality Guidelines

### Good Tests Are:

1. **Fast** - Milliseconds, not seconds
2. **Independent** - No test depends on another
3. **Repeatable** - Same result every time
4. **Self-validating** - Pass or fail, no interpretation
5. **Timely** - Written before the code

### Test Behavior, Not Implementation

```
❌ BAD: Test that method X calls method Y
✅ GOOD: Test that given input A, output is B

❌ BAD: Test internal state of object
✅ GOOD: Test observable behavior

❌ BAD: Test that specific SQL is generated
✅ GOOD: Test that data is correctly persisted/retrieved
```

### Test Naming Convention

```
// Pattern: Should_ExpectedBehavior_When_Condition

Should_ReturnEmpty_When_NoItemsExist
Should_ThrowError_When_InvalidInput
Should_UpdateTotal_When_ItemAdded
```

## TDD for Bug Fixes

When fixing a bug:

1. **Write a test that reproduces the bug** (RED)
   - This test should fail, demonstrating the bug exists

2. **Fix the bug** (GREEN)
   - Minimal change to make the test pass

3. **Verify no regressions** (REFACTOR)
   - All other tests still pass
   - Consider if this reveals other issues

## Common TDD Mistakes

1. **Writing code first, tests later**
   - Tests become an afterthought
   - Tests verify implementation, not behavior
   - Missing edge cases

2. **Testing too much at once**
   - Tests are hard to understand
   - Failures don't pinpoint problems
   - Slow feedback cycle

3. **Skipping the refactor step**
   - Technical debt accumulates
   - Code becomes harder to change
   - Tests become hard to maintain

4. **Testing implementation details**
   - Tests break when refactoring
   - Tests don't describe behavior
   - False sense of coverage

## Output Format

When doing TDD work, report progress as:

```markdown
## Feature: [Feature Name]

### Cycle 1
- **TEST**: [Test name/description]
- **RED**: [Why it fails]
- **GREEN**: [Minimal code written]
- **REFACTOR**: [Improvements made]

### Cycle 2
...

## Test Summary
- Total tests: X
- All passing: ✅
- Coverage: [relevant areas covered]
```
