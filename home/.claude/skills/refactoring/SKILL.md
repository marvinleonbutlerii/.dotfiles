---
name: refactoring
description: |
  Systematic code refactoring to improve design without changing behavior.
  Activates when code structure needs improvement without behavior change,
  including during the refactor phase of TDD cycles.
---

# Refactoring Skill

## Core Principle

Refactoring targets the structural mechanism that generates code smells, not individual smell instances. If you find the same smell in multiple places, the fix is to change the pattern that produces them, not to fix each instance independently.

## Prerequisites

Do NOT refactor when:
- Tests are failing or missing
- You do not understand the code
- While adding new features simultaneously

## Refactoring Protocol

### Step 0: Research

Before refactoring â€” research is mandatory:
- Research the canonical pattern or design for this type of code using Tier 1 and Tier 2 sources
- Compare the current implementation against reference implementations
- Understand why the current design exists before changing it

### Step 1: Verify Readiness

- All tests pass
- Test coverage is adequate for the area being changed
- You understand what the code does and why
- You have a specific improvement goal
- Changes are version controlled

### Step 2: Identify the Smell

Common code smells grouped by the mechanism that generates them:

**Bloaters** (code grew without structural discipline):
- Long Method (>20 lines), Large Class (>300 lines)
- Long Parameter List (>3 params), Data Clumps

**Change Preventers** (coupling prevents isolated changes):
- Divergent Change, Shotgun Surgery, Parallel Inheritance

**Dispensables** (things that should not exist):
- Duplicate Code, Dead Code, Speculative Generality

**Couplers** (inappropriate dependencies):
- Feature Envy, Inappropriate Intimacy, Message Chains

### Step 3: Choose the Refactoring

Select the smallest refactoring that improves the smell:

- **Extract/Inline**: Method, Variable, Class
- **Rename**: Variable, Method, Class
- **Move**: Method, Field, Statements
- **Organize Data**: Replace Primitive with Object, Introduce Parameter Object
- **Simplify Conditionals**: Decompose, Consolidate, Replace with Polymorphism
- **Simplify Method Calls**: Add/Remove Parameter, Separate Query from Modifier

### Step 4: Execute Mechanically

1. Make one structural change
2. Run tests immediately
3. If tests fail: REVERT. If the failure reveals a pre-existing latent bug (not caused by the refactoring), invoke the debugging protocol before continuing the refactoring cycle.
4. If tests pass: continue
5. Repeat with next small change

One refactoring at a time. Do not batch.

### Step 5: Verify

After each refactoring:
- All tests still pass
- Behavior is unchanged
- Code is measurably better
- No new warnings or errors
- Add a recurrence guard to prevent the smell from being reintroduced

