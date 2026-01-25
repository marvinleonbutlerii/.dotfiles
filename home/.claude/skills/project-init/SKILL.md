---
name: project-init
description: |
  Initialize new projects with proper structure, documentation, and Claude
  configuration. Use when starting a new project, repository, or significant
  new component.
---

# Project Initialization Skill

## Purpose

Set up new projects with:
- Proper directory structure
- Essential documentation
- Claude Code configuration (CLAUDE.md)
- Version control setup
- Development environment basics

## Standard Project Structure

### Minimal Project

```
project/
├── README.md           # Project overview
├── CLAUDE.md           # AI assistant context
├── .gitignore          # Git ignore patterns
└── src/                # Source code
```

### Full Project

```
project/
├── README.md           # Project overview
├── CLAUDE.md           # AI assistant context
├── CHANGELOG.md        # Version history
├── CONTRIBUTING.md     # How to contribute
├── LICENSE             # License file
├── .gitignore          # Git ignore patterns
├── .editorconfig       # Editor settings
├── src/                # Source code
├── tests/              # Test files
├── docs/               # Documentation
└── scripts/            # Build/utility scripts
```

## Essential Files

### README.md Template

```markdown
# Project Name

Brief description of what this project does.

## Quick Start

\`\`\`bash
# Installation steps
\`\`\`

## Features

- Feature 1
- Feature 2

## Usage

\`\`\`bash
# Example usage
\`\`\`

## Development

\`\`\`bash
# How to set up dev environment
# How to run tests
\`\`\`

## License

[License type]
```

### CLAUDE.md Template

```markdown
# Project Context

## What this is
[One sentence description]

## Current state
- [x] Initial setup
- [ ] Core feature 1
- [ ] Core feature 2

## Architecture
[High-level overview of how it works]

## Key files
- `src/main.js` - Entry point
- `src/core/` - Core logic

## Commands
\`\`\`bash
# Development
npm run dev

# Testing
npm test

# Build
npm run build
\`\`\`

## Conventions
- [Code style]
- [Naming conventions]
- [Testing approach]

## Known issues
- [Issue 1]

## Future plans
- [Plan 1]
```

### .gitignore Essentials

```gitignore
# Dependencies
node_modules/
vendor/
venv/

# Build outputs
dist/
build/
*.o
*.exe

# IDE
.idea/
.vscode/
*.swp

# Environment
.env
.env.local
*.pem

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.pytest_cache/
```

### .editorconfig

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.{py,rs}]
indent_size = 4

[Makefile]
indent_style = tab
```

## Language-Specific Setup

### Node.js/TypeScript

```
project/
├── package.json
├── tsconfig.json       # If TypeScript
├── .eslintrc.js
├── .prettierrc
├── src/
│   └── index.ts
└── tests/
    └── index.test.ts
```

### Python

```
project/
├── pyproject.toml      # Or setup.py
├── requirements.txt
├── src/
│   └── project_name/
│       └── __init__.py
└── tests/
    └── test_main.py
```

### Rust

```
project/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   └── main.rs
└── tests/
    └── integration_test.rs
```

## Initialization Steps

### 1. Create Directory

```powershell
mkdir project-name
cd project-name
```

### 2. Initialize Git

```powershell
git init
```

### 3. Create Essential Files

```powershell
# Create README
New-Item README.md

# Create CLAUDE.md
New-Item CLAUDE.md

# Create .gitignore
New-Item .gitignore
```

### 4. Language-Specific Init

```powershell
# Node.js
npm init -y

# Python
python -m venv venv

# Rust
cargo init
```

### 5. Initial Commit

```powershell
git add .
git commit -m "Initial project setup"
```

## Quality Checklist

Before considering setup complete:

```
[ ] README explains what and why
[ ] CLAUDE.md provides context
[ ] .gitignore covers common patterns
[ ] Git is initialized
[ ] Dependencies are declared (if any)
[ ] Basic project structure exists
[ ] Can run/build without errors
```

## Output Format

When initializing projects:

```markdown
## Project Initialized: [name]

### Structure Created
\`\`\`
[tree output]
\`\`\`

### Files Created
- README.md: Project overview
- CLAUDE.md: AI context
- .gitignore: Git patterns
- [other files]

### Next Steps
1. [First thing to do]
2. [Second thing to do]

### Commands
\`\`\`bash
[relevant commands for this project type]
\`\`\`
```
