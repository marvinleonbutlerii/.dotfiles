---
name: planning
description: |
  Structured planning for complex tasks, features, or projects. Use when
  facing a large or ambiguous task that needs to be broken down into
  manageable steps with clear success criteria.
---

# Planning Skill

## When to Use

Engage this skill when:
- Task requires more than 30 minutes of work
- Multiple components or systems are involved
- Requirements are unclear or ambiguous
- Risk of going down wrong path is significant
- Coordination with user decisions is needed

## Planning Framework

### Phase 1: Clarify

Before ANY planning, ensure you understand:

```markdown
## Understanding Check

**Goal**: What is the desired end state?
**Problem**: What problem does this solve?
**Constraints**: What limitations exist?
**Success Criteria**: How do we know it's done?
**Non-Goals**: What are we explicitly NOT doing?
```

If any of these are unclear, STOP and ask.

### Phase 2: Explore

Investigate the problem space:

```markdown
## Exploration

**Current State**
- What exists today?
- What works/doesn't work?
- What dependencies exist?

**Options Considered**
1. Option A: [description]
   - Pros: [list]
   - Cons: [list]
   - Effort: [estimate]

2. Option B: [description]
   - Pros: [list]
   - Cons: [list]
   - Effort: [estimate]

**Recommendation**
[Which option and why]
```

### Phase 3: Decompose

Break down into atomic tasks:

```markdown
## Task Breakdown

### Must Have (P0)
- [ ] Task 1: [specific, actionable]
- [ ] Task 2: [specific, actionable]

### Should Have (P1)
- [ ] Task 3: [specific, actionable]

### Nice to Have (P2)
- [ ] Task 4: [specific, actionable]

### Dependencies
- Task 2 depends on Task 1
- Task 4 can be done in parallel
```

### Phase 4: Sequence

Order the work:

```markdown
## Execution Plan

### Step 1: [Name]
- Task: [what to do]
- Verify: [how to confirm it worked]
- Rollback: [how to undo if needed]

### Step 2: [Name]
...

### Checkpoints
- After Step 2: Review with user
- After Step 4: Test integration
```

## Planning Principles

### 1. Start Small
- Begin with minimal viable approach
- Add complexity only when needed
- Prefer reversible decisions

### 2. Verify Often
- Each step should be verifiable
- Don't batch too many changes
- Test assumptions early

### 3. Plan for Failure
- What could go wrong?
- How would we detect it?
- How would we recover?

### 4. Time-box Exploration
- Don't research forever
- Set a limit, then decide
- Perfect information doesn't exist

## Red Flags

Stop and reassess if:
- Plan has more than 10 steps
- Any step takes more than 1 hour
- Dependencies form a complex graph
- Success criteria are vague
- Rollback isn't possible

## Output Format

Present plans as:

```markdown
# Plan: [Feature/Task Name]

## Summary
[1-2 sentence overview]

## Goal
[What success looks like]

## Approach
[High-level strategy]

## Steps
1. [Step 1] - [time estimate]
2. [Step 2] - [time estimate]
...

## Risks
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]

## Questions for User
1. [Question needing decision]
2. [Question needing clarification]

## Ready to proceed?
[Wait for confirmation before starting]
```

## Anti-Patterns

**Over-planning**
- Analysis paralysis
- Planning work that may never happen
- Premature optimization of the plan

**Under-planning**
- Starting without understanding goal
- No verification points
- No rollback strategy

**Rigid plans**
- Not adapting to new information
- Following plan when clearly wrong
- Ignoring user feedback
