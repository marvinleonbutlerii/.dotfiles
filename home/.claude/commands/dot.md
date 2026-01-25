# /dot - Dotfiles Management

Run dotfiles management commands directly from Claude Code.

## Usage

```
/dot <command>
```

## Available Commands

- `doctor` - Run health check
- `stow` - Create/update symlinks
- `backup` - Create backup
- `update` - Update dotfiles
- `edit` - Open dotfiles in editor

## Implementation

When the user runs `/dot <command>`, execute:

```powershell
& "$env:USERPROFILE\.dotfiles\dot.ps1" <command>
```

Show the output and summarize any issues found.
