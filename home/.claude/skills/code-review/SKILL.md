---
name: code-review
description: |
  Evaluates code changes, output, and implementations for correctness,
  maintainability, security, and adherence to project standards. Activates
  when evaluating any code — whether user-requested or as part of the
  mandatory holistic review before shipping.
---

# Code Review Skill

## Core Principle

A code review examines whether changes address the root mechanism or merely patch symptoms. Every finding is evidence-based, not opinion-based.

## Review Protocol

### 0. Research

Before reviewing, research current best practices for the patterns being used. Apply the research skill to understand what the canonical implementation looks like. Do not review against training-data assumptions — verify against Tier 1 and Tier 2 sources.

### 1. Understand Context

- What is the purpose of this change?
- What root problem does it solve?
- Does it address the mechanism or a symptom?

For each finding: state the observation, why it matters, the confidence level (high/moderate/low), and the evidence (file, line, test, or source).

### 2. Check Correctness

- Does the code do what it claims to do?
- Are edge cases handled?
- Are there potential bugs or logic errors?
- Are error conditions handled properly?

### 3. Evaluate Design

- Is this the right approach to the problem?
- Are there simpler alternatives?
- Does it follow existing patterns in the codebase?
- Is the abstraction level appropriate?
- Does the design address the root cause or just the surface?

### 4. Review Maintainability

- Is the code readable and self-documenting?
- Are names descriptive and consistent?
- Will this be easy to modify in the future?

### 5. Check Security

- Are there potential security vulnerabilities?
- Is user input properly validated?
- Are secrets handled correctly?

### 6. Verify Tests

- Are there tests for the new functionality?
- Do existing tests still pass?
- Are edge cases tested?
- Do tests verify behavior at the mechanism level, not just symptoms?

### 7. Recurrence Check

- Add a recurrence guard for every finding. This is not optional.
- Are there other locations in the codebase with the same pattern?
- If the same mistake exists elsewhere, flag all instances for systemic fix.

## Output

### Summary
One paragraph overview and overall assessment.

### Issues (if any)
- **Critical**: Must fix
- **Major**: Should fix
- **Minor**: Consider fixing
