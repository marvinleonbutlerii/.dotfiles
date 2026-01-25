---
name: code-review
description: |
  Perform thorough code review with focus on correctness, maintainability,
  and adherence to project standards. Use when reviewing PRs, commits, or
  code changes before merging.
---

# Code Review Skill

When reviewing code, follow this systematic approach:

## 1. Understand Context
- What is the purpose of this change?
- What problem does it solve?
- Are there related issues or tickets?

## 2. Check Correctness
- Does the code do what it claims to do?
- Are edge cases handled?
- Are there potential bugs or logic errors?
- Are error conditions handled properly?

## 3. Evaluate Design
- Is this the right approach to the problem?
- Are there simpler alternatives?
- Does it follow existing patterns in the codebase?
- Is the abstraction level appropriate?

## 4. Review Maintainability
- Is the code readable and self-documenting?
- Are names descriptive and consistent?
- Is there appropriate documentation?
- Will this be easy to modify in the future?

## 5. Check Security
- Are there potential security vulnerabilities?
- Is user input properly validated?
- Are secrets handled correctly?
- Are permissions checked appropriately?

## 6. Verify Tests
- Are there tests for the new functionality?
- Do existing tests still pass?
- Are edge cases tested?
- Is test coverage adequate?

## Output Format

Provide review in this structure:

### Summary
One paragraph overview of the change and overall assessment.

### Issues (if any)
- **Critical**: Must fix before merge
- **Major**: Should fix before merge
- **Minor**: Consider fixing
- **Nitpick**: Optional style suggestions

### Questions
Things that need clarification from the author.

### Positive Feedback
What was done well (be specific).

### Verdict
- ✅ Approve
- 🔄 Request Changes
- ❓ Need More Information
