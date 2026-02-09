---
name: tdd
description: |
  Test-Driven Development workflow. Activates when implementing new
  behavior, fixing bugs, or when tests are needed to verify correctness.
  Enforces Red-Green-Refactor discipline. Tests are written BEFORE
  implementation.
---

# Test-Driven Development Skill

## Core Principle

Every single line of production code is written in response to a failing test. No exceptions. Tests verify behavior at the mechanism level, not at the symptom level.

## Pre-Protocol: Research

Before writing the first test, research the testing patterns used in the current project and framework. Understand:
- What test framework is in use
- What conventions exist in the codebase
- What patterns are canonical for this type of test

## The Red-Green-Refactor Cycle

### 1. RED: Write a Failing Test

Before writing ANY production code:

- Write a test that describes the desired behavior
- Run the test. It MUST fail
- Verify it fails for the RIGHT reason
- If it passes, you wrote the wrong test

The test should:
- Be small and focused on one behavior
- Have a descriptive name explaining what it tests
- Fail with a clear error message
- Test the mechanism, not implementation details

### 2. GREEN: Make It Pass

Write the MINIMUM code to make the test pass:

- Write only enough code to pass the test
- Do not anticipate future requirements
- Do not add "obvious" improvements
- Run the test. It MUST pass
- All previous tests must still pass

Rules:
- No new functionality without a test
- No "while I am here" additions
- Resist the urge to optimize
- Ugly code is fine at this stage

### 3. REFACTOR: Improve the Code

Now, and ONLY now, improve the code:

- Tests are green before refactoring
- Make one small change at a time
- Run tests after each change
- Tests must stay green throughout
- Stop when code is clean enough

Refactoring opportunities: remove duplication, improve naming, extract methods, simplify conditionals, apply design patterns.

## Test Quality Guidelines

### Good Tests Are (FIRST):

1. **Fast** — Milliseconds, not seconds
2. **Independent** — No test depends on another
3. **Repeatable** — Same result every time
4. **Self-validating** — Pass or fail, no interpretation
5. **Timely** — Written before the code

### Test Behavior, Not Implementation

- BAD: Test that method X calls method Y
- GOOD: Test that given input A, output is B
- BAD: Test internal state of object
- GOOD: Test observable behavior
- BAD: Test that specific SQL is generated
- GOOD: Test that data is correctly persisted/retrieved

### Test Naming Convention

```
// Pattern: Should_ExpectedBehavior_When_Condition
Should_ReturnEmpty_When_NoItemsExist
Should_ThrowError_When_InvalidInput
Should_UpdateTotal_When_ItemAdded
```

## TDD for Bug Fixes

When fixing a bug:

1. **Write a test that reproduces the bug** (RED) — this test should fail, demonstrating the bug exists
2. **Fix the bug** (GREEN) — minimal change to make the test pass
3. **Verify no regressions** (REFACTOR) — all other tests still pass

## Integration with Debugging

When a test fails unexpectedly:
- Do NOT blindly change code to make it pass
- Invoke the debugging protocol: understand WHY it fails at the mechanism level
- The test failure is a symptom. Find the root cause before changing anything.
