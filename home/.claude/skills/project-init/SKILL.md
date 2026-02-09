---
name: project-init
description: |
  Initialize new projects with proper structure, documentation, and Claude
  configuration. Activates when creating any new project, repository,
  module, or significant component.
---

# Project Initialization Skill

## Core Principle

Every project starts with a clear architectural foundation. The initial structure determines the trajectory of all future work. Get the foundation right, and everything built on it will be sound.

## Initialization Protocol

### Phase 0: Research

Before creating any files â€” research is mandatory:
- Research current best practices for this project type using Tier 1 and Tier 2 sources
- Find canonical project structures and tooling choices in authoritative repositories
- Identify what toolchain is current and well-supported
- Verify all choices against official documentation and community consensus

### Phase 1: Foundation Design

Define the architectural foundation:
- What problem does this project solve at its core?
- What is the right level of complexity for the initial structure?
- What conventions will this project follow?
- What are the non-negotiable quality requirements?

### Phase 2: Create Structure

Structure emerges from research, not from static templates. Based on Phase 0 findings, create the project structure that matches current best practices for the specific language, framework, and project type.

Every project includes at minimum:
- README.md â€” what this project does, how to use it, how to develop
- CLAUDE.md â€” project context, architecture, commands, conventions
- .gitignore â€” appropriate patterns for the project type
- Test infrastructure — include test setup from the start. Apply the TDD skill's setup guidance for the chosen language/framework.
- Language-specific config â€” package.json, pyproject.toml, Cargo.toml, etc.

### Phase 3: Initialize

1. Create the project directory
2. Initialize git
3. Create all files with meaningful content (not boilerplate)
4. Language-specific initialization
5. Initial commit

### Phase 4: Verify

- README explains what and why
- CLAUDE.md provides useful context
- .gitignore covers common patterns
- Git is initialized with clean history
- Dependencies are declared
- Basic structure exists
- Can run/build without errors

