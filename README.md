# Dotfiles

A comprehensive, automated dotfiles management system for Windows development environments. Features a powerful CLI tool for setup, maintenance, and Claude Code integration.

## Philosophy

> This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down. You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again. Fight entropy. Leave the codebase better than you found it.

## Overview

This repository contains personal development environment configuration, managed through a custom CLI tool called `dot`. It uses symlinks for file management, winget for package installation, and includes configurations for PowerShell, Git, Windows Terminal, and Claude Code.

### Key Features

- **One-command setup** - Complete development environment in minutes
- **Claude Code Integration** - Global CLAUDE.md and custom skills
- **Resilient Package Management** - Continues installation even if packages fail
- **Compressed Backups** - Create and restore configuration snapshots
- **Health Monitoring** - Comprehensive environment diagnostics
- **Modular Design** - Separate work and personal configurations

## Quick Start

```powershell
# Clone the repository (if not already done)
# The dotfiles are already at ~/.dotfiles

# Navigate to dotfiles
cd $env:USERPROFILE\.dotfiles

# Full setup (installs everything)
.\dot.ps1 init

# Or customize the installation
.\dot.ps1 init --skip-packages
```

After initialization, the `dot` command will be available globally.

## Repository Structure

```
~/.dotfiles/
├── dot.ps1            # Main CLI tool
├── dot.cmd            # Batch wrapper for CLI
├── home/              # Configuration files (stowed to ~)
│   ├── .claude/       # Claude Code configuration
│   │   ├── CLAUDE.md  # Global instructions for Claude
│   │   ├── settings.json
│   │   ├── commands/  # Custom slash commands
│   │   └── skills/    # Custom skills
│   ├── .ideavimrc      # JetBrains IdeaVim config
│   └── .config/
│       ├── git/       # Git configuration
│       ├── jj/        # Jujutsu config
│       ├── nvim/      # Neovim config
│       ├── powershell/  # PowerShell profile
│       ├── ripgrep/   # ripgrep defaults
│       ├── windows-terminal/  # Terminal settings
│       └── starship.toml  # Starship prompt config
├── packages/
│   ├── packages.json      # Base packages (winget)
│   └── packages.work.json # Work-specific packages
├── backups/           # Configuration backups (compressed)
├── scripts/           # Additional scripts
├── CLAUDE.md          # Instructions for Claude Code
└── README.md          # This file
```

## The `dot` CLI Tool

### Installation Commands

#### `dot init` - Initial Setup

```powershell
# Full installation
.\dot.ps1 init

# Skip package installation
.\dot.ps1 init --skip-packages

# Skip SSH key generation
.\dot.ps1 init --skip-ssh

# Skip font installation
.\dot.ps1 init --skip-font
```

**What it does:**
1. Creates a pre-init backup
2. Installs packages from manifest (winget)
3. Generates an SSH key (optional)
4. Installs development fonts (optional)
5. Creates symlinks with PowerShell
6. Adds dotfiles to PATH
7. Runs health check

### Maintenance Commands

#### `dot update` - Update Everything

```powershell
dot update
```

- Pulls latest dotfiles changes (if git repo)
- Re-creates symlinks
- Updates all packages

#### `dot doctor` - Health Check

```powershell
dot doctor
```

Comprehensive diagnostics including:
- System information
- Required tools (git, claude, code)
- Claude Code configuration
- Symlink status
- PATH configuration

#### `dot stow` / `dot unstow` - Symlink Management

```powershell
# Create/update symlinks
dot stow

# Force overwrite existing files
dot stow --force

# Remove managed symlinks
dot unstow
```

### Backup Commands

```powershell
# Create timestamped backup
dot backup

# Create named backup
dot backup my-backup-name

# List available backups
dot backup list

# Restore from backup
dot restore backup-name

# Clean old backups (>30 days)
dot backup clean
```

### Utility Commands

```powershell
# Open dotfiles in editor
dot edit

# Add dotfiles to PATH
dot link

# Remove from PATH
dot unlink

# List/install packages
dot package list
dot package install
dot package add Git.Git winget base
dot package remove Git.Git
dot package update
dot check-packages
dot retry-failed

# Generate SSH key
dot gen-ssh-key your.email@example.com

# AI summary of git commits
dot summary
dot summary -n 10

# Benchmark shell startup
dot benchmark-shell
```

## Configuration

### Package Management

Packages are defined in JSON manifests:

**`packages/packages.json`** - Base packages:
- Development tools: git, neovim, code
- CLI utilities: ripgrep, fd, fzf, bat, eza
- Shell tools: starship, zoxide

**`packages/packages.work.json`** - Work-specific:
- Docker, Kubernetes tools
- Cloud CLIs (AWS, Azure)
- Communication apps

### Claude Code Configuration

The `home/.claude/` directory contains:

- **CLAUDE.md** - Global instructions and values
- **settings.json** - Claude Code settings
- **commands/** - Custom slash commands
- **skills/** - Custom skills for specific tasks

### Key Configurations

- **PowerShell Profile**: Aliases, functions, prompt customization
- **Git**: Aliases, delta diff viewer, conditional includes
- **Windows Terminal**: Keybindings, color schemes, profiles
- **Neovim**: Lua-based configuration under `home/.config/nvim`
- **Starship**: Prompt configuration in `home/.config/starship.toml`
- **ripgrep**: Default search flags in `home/.config/ripgrep/config`
- **IdeaVim**: JetBrains Vim config in `home/.ideavimrc`

## First-Time Setup

### Prerequisites

- Windows 10/11
- PowerShell 5.1+ (comes with Windows)
- Internet connection

### Installation Steps

1. **Run initialization:**
   ```powershell
   cd $env:USERPROFILE\.dotfiles
   .\dot.ps1 init
   ```

2. **Restart terminal** to apply changes

3. **Verify installation:**
   ```powershell
   dot doctor
   ```

### Post-Installation

1. **Configure Git identity:**
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Authenticate Claude Code:**
   ```powershell
   claude
   # Follow authentication prompts
   ```

## Customization

### Adding Packages

Preferred (updates manifest + installs):
```powershell
dot package add Your.Package.Id
```

Manual edit:
```json
{
  "winget": [
    "Your.Package.Id"
  ]
}
```

Then run:
```powershell
dot package install
```

### Modifying Configurations

1. Edit files in `home/` directory (not your actual home)
2. Re-stow: `dot stow`
3. Test configuration

### Adding Claude Skills

Create `home/.claude/skills/your-skill/SKILL.md`:
```yaml
---
name: your-skill
description: |
  Description of when to use this skill
---

# Your Skill

Instructions for Claude...
```

## Troubleshooting

### Common Issues

**Command not found: `dot`**
```powershell
# Add to PATH manually
$env:PATH = "$env:USERPROFILE\.dotfiles;$env:PATH"

# Or run link command
cd $env:USERPROFILE\.dotfiles
.\dot.ps1 link
```

**Symlink permission denied**
- Enable Developer Mode in Windows Settings
- Or run PowerShell as Administrator

**Package installation fails**
```powershell
# Check what failed
dot package list

# Install specific package manually
winget install Package.Name
```

### Getting Help

- Run `dot help` for command overview
- Run `dot doctor` for environment issues

## Development

### Testing Changes

```powershell
# Create backup first
dot backup pre-changes

# Make modifications to home/ files
# ...

# Re-stow
dot stow

# Test
dot doctor

# If issues, restore
dot restore pre-changes
```

## Acknowledgments

- [dmmulroy/.dotfiles](https://github.com/dmmulroy/.dotfiles) - Inspiration
- [Anthropic Claude](https://www.anthropic.com/) - Start
- [Anthropic Claude](https://openai.com/codex/) - Binding
- [chezmoi](https://www.chezmoi.io/) - Dotfiles
- The dotfiles community for patterns and best practices

---

