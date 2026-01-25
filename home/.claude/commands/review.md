# /review - Code Review

Perform a thorough code review of the specified files or changes.

## Usage

```
/review [file or git ref]
```

## Examples

```
/review src/main.js
/review HEAD~3..HEAD
/review --staged
```

## Implementation

When the user runs `/review`, engage the code-review skill and:

1. If a file is specified, review that file
2. If a git ref is specified, review those changes
3. If `--staged` is specified, review staged changes
4. If nothing specified, review recent changes in the working directory

Provide structured feedback following the code-review skill format.
