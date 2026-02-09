---
name: planning
description: |
  Structured planning for complex tasks, features, or projects. Activates
  when a task requires decomposition, has multiple components, or when
  requirements need clarification before implementation.
---

# Planning Skill

## Core Principle

Planning is root-cause analysis applied to the future. Before planning how to build, understand what the deepest foundational requirement actually is.

## Planning Framework

### Phase 0: Root Requirement

Before any planning, identify the deepest foundational requirement:
- What is the user actually trying to achieve at the most fundamental level?
- What is the root problem beneath the surface request?
- What would a complete, foundational solution look like?

### Phase 1: Research

Before planning implementation — research is mandatory, not optional:
- Research current best practices for this type of work using Tier 1 and Tier 2 sources
- Find reference implementations and prior art on GitHub, in community discourse
- Identify what is known vs. what needs to be discovered
- Use WebSearch for anything that could be verified externally

### Phase 2: Clarify

Ensure you understand:
- **Goal**: What is the desired end state?
- **Problem**: What root problem does this solve?
- **Constraints**: What limitations exist?
- **Success Criteria**: How do we know it is done?
- **Non-Goals**: What are we explicitly NOT doing?

Clarify ALL unknowns before proceeding. Do not infer when you can verify.

### Phase 3: Explore

Investigate options where multiple approaches exist:
- Current state and what exists today
- Options with pros, cons, and effort estimates
- Recommendation with reasoning

### Phase 4: Decompose

Break down into atomic tasks:
- **P0 (Must Have)**: Core requirements
- **P1 (Should Have)**: Important improvements
- **P2 (Nice to Have)**: Optional enhancements
- Dependencies between tasks

### Phase 5: Sequence

Order the work with verification at each step:
- Each step: what to do, how to verify, how to rollback
- Checkpoints for integration testing
- Recurrence guards for each completed phase
