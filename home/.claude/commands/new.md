# /new - Initialize New Project

Create a new project with proper structure and configuration.

## Usage

```
/new [project-name] [type]
```

## Types

- `node` - Node.js/TypeScript project
- `python` - Python project
- `rust` - Rust project
- `basic` - Minimal project (just git + docs)

## Examples

```
/new my-api node
/new data-processor python
/new cli-tool rust
/new quick-script basic
```

## Implementation

When the user runs `/new`, engage the project-init skill and:

1. Create the project directory
2. Initialize git
3. Create appropriate files for the project type
4. Set up CLAUDE.md with project context
5. Make initial commit

Follow the project-init skill templates and output format.
