---
name: refactoring
description: |
  Systematic code refactoring to improve design without changing behavior.
  Use when code needs restructuring, simplification, or improvement while
  maintaining all existing functionality and tests.
---

# Refactoring Skill

## Core Principle

**Refactoring changes structure, not behavior.**

If tests fail after refactoring, you broke something. Revert and try smaller steps.

## When to Refactor

**Good times:**
- Tests are green and comprehensive
- You understand the code well
- There's a clear improvement goal
- After completing a feature (in TDD refactor phase)

**Bad times:**
- Tests are failing or missing
- Under time pressure
- You don't understand the code
- While adding new features simultaneously

## The Refactoring Process

### Step 0: Prerequisites

Before starting:

```
[ ] All tests pass
[ ] Test coverage is adequate
[ ] You understand what the code does
[ ] You have a specific improvement goal
[ ] Changes are version controlled
```

### Step 1: Identify the Smell

Common code smells to address:

**Bloaters**
- Long Method (>20 lines)
- Large Class (>300 lines)
- Long Parameter List (>3 params)
- Primitive Obsession
- Data Clumps

**Object-Orientation Abusers**
- Switch Statements
- Refused Bequest
- Temporary Field

**Change Preventers**
- Divergent Change
- Shotgun Surgery
- Parallel Inheritance

**Dispensables**
- Comments (explaining bad code)
- Duplicate Code
- Dead Code
- Speculative Generality

**Couplers**
- Feature Envy
- Inappropriate Intimacy
- Message Chains
- Middle Man

### Step 2: Choose the Refactoring

Select the smallest refactoring that improves the smell:

**Extract/Inline**
- Extract Method
- Extract Variable
- Extract Class
- Inline Method
- Inline Variable

**Rename**
- Rename Variable
- Rename Method
- Rename Class

**Move**
- Move Method
- Move Field
- Move Statements

**Organize Data**
- Replace Primitive with Object
- Replace Array with Object
- Introduce Parameter Object

**Simplify Conditionals**
- Decompose Conditional
- Consolidate Conditional
- Replace Conditional with Polymorphism
- Remove Control Flag

**Simplify Method Calls**
- Rename Method
- Add Parameter
- Remove Parameter
- Separate Query from Modifier

### Step 3: Execute Mechanically

Apply the refactoring as a mechanical transformation:

```
1. Make the structural change
2. Run tests immediately
3. If tests fail: REVERT
4. If tests pass: COMMIT
5. Repeat with next small change
```

**Critical:** One refactoring at a time. Do not batch.

### Step 4: Verify

After each refactoring:

```
[ ] All tests still pass
[ ] Behavior is unchanged
[ ] Code is measurably better
[ ] No new warnings/errors
```

## Refactoring Recipes

### Extract Method

When: Long method, code with comment explaining it

```
Before:
function process() {
    // validate input
    if (!data) throw new Error('missing');
    if (data.length > 100) throw new Error('too long');
    
    // transform
    const result = data.map(x => x * 2);
    
    // save
    db.save(result);
}

After:
function process() {
    validate(data);
    const result = transform(data);
    save(result);
}

function validate(data) { ... }
function transform(data) { ... }
function save(result) { ... }
```

### Rename for Clarity

When: Name doesn't describe purpose

```
Before:
const d = new Date();
const x = calculate(d);

After:
const orderDate = new Date();
const totalPrice = calculateOrderTotal(orderDate);
```

### Replace Conditional with Polymorphism

When: Switch statement selecting behavior by type

```
Before:
function getArea(shape) {
    switch (shape.type) {
        case 'circle': return Math.PI * shape.r ** 2;
        case 'square': return shape.side ** 2;
    }
}

After:
class Circle { getArea() { return Math.PI * this.r ** 2; } }
class Square { getArea() { return this.side ** 2; } }
```

## Red Flags

Stop refactoring if:

- Tests start failing
- You're not sure what the code does
- Changes are getting larger, not smaller
- You're "improving" code you don't need to touch
- You're mixing refactoring with feature work

## Output Format

When refactoring, report as:

```markdown
## Refactoring: [Description]

### Target
[What code is being refactored]

### Smell
[What problem we're addressing]

### Steps Taken
1. [Refactoring 1] ✅
2. [Refactoring 2] ✅
...

### Before/After
[Show meaningful comparison]

### Verification
- Tests: All passing
- Behavior: Unchanged
- Improvement: [What's better now]
```
