# CLAUDE.md - Dotfiles Project

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This is a dotfiles repository for managing development environment configurations on Windows. It provides:

- A PowerShell-based CLI tool (`dot.ps1`) for dotfiles management
- Configuration files that get symlinked to the home directory
- Package manifests for winget-based installation
- Claude Code integration (global CLAUDE.md, skills, commands)

## Key Commands

```powershell
# Run the CLI
.\dot.ps1 <command>

# Or if linked to PATH
dot <command>
```

Available commands:
- `init` - Full setup with packages and symlinks
- `update` - Pull changes, refresh symlinks
- `doctor` - Run health diagnostics
- `stow` - Create/update symlinks
- `backup` - Create configuration backup
- `package list` - Show package status

## Directory Structure

```
.dotfiles/
├── dot.ps1           # Main CLI (PowerShell)
├── dot.cmd           # Batch wrapper
├── home/             # Files to symlink to ~
│   ├── .claude/      # Claude Code config
│   │   ├── CLAUDE.md       # Global instructions
│   │   ├── settings.json   # Claude Code settings
│   │   ├── agents/         # Custom subagents (researcher, builder, planner)
│   │   ├── rules/          # Operational mandates (7 files)
│   │   ├── skills/         # Domain protocols (9 skills)
│   │   └── commands/       # Slash commands (dot.md)
│   └── .config/      # XDG-style config
├── packages/         # Package manifests (JSON)
├── backups/          # Backup archives
└── scripts/          # Helper scripts
```

## Architecture Principles

1. **Symlink-based**: Files in `home/` are symlinked to `~`, not copied
2. **Idempotent**: Running `dot init` multiple times is safe
3. **Resilient**: Package installation continues despite failures
4. **Transparent**: `dot doctor` shows full system state

## When Modifying

- Edit files in `home/` directory, not the actual home directory
- After editing, run `dot stow` to update symlinks
- Create a backup before major changes: `dot backup pre-changes`
- Test with `dot doctor` after changes

## Windows-Specific Notes

- Uses PowerShell (not Bash)
- Symlinks may require Developer Mode or Admin
- Paths use backslash but forward slash works in most contexts
- Line endings should be CRLF for PowerShell files

## File Locations After Stow

| Source | Destination |
|--------|-------------|
| `home/.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `home/.config/git/config` | `~/.config/git/config` |
| `home/.config/powershell/*.ps1` | `~/.config/powershell/*.ps1` |

## Testing

No formal test framework. Verify with:
```powershell
dot doctor  # Check all components
```
