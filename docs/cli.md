# dot CLI Reference (Windows)

## Commands

### System Setup

```powershell
# Full system setup (interactive)
.\dot.ps1 init [--skip-ssh] [--skip-font] [--skip-packages]

# Update symlinks for dotfiles
.\dot.ps1 stow [--force]
.\dot.ps1 unstow

# Update dotfiles and packages
.\dot.ps1 update

# Check installation health
.\dot.ps1 doctor

# Add/remove dotfiles from PATH
.\dot.ps1 link
.\dot.ps1 unlink

# Apply Windows settings and fonts
.\dot.ps1 settings
.\dot.ps1 fonts

# Setup Claude Code
.\dot.ps1 claude
```

### Package Management

```powershell
# List packages
.\dot.ps1 package list
.\dot.ps1 package list base
.\dot.ps1 package list work

# Install packages from manifests
.\dot.ps1 package install          # base
.\dot.ps1 package install work

# Add packages (winget IDs)
.\dot.ps1 package add Git.Git winget base
.\dot.ps1 package add Microsoft.PowerShell winget base
.\dot.ps1 package add SomeTool scoop work

# Update packages
.\dot.ps1 package update           # all
.\dot.ps1 package update Git.Git
.\dot.ps1 package update work

# Remove packages
.\dot.ps1 package remove Git.Git
.\dot.ps1 package remove Git.Git base

# Check installed vs manifest
.\dot.ps1 check-packages

# Retry packages from failed log
.\dot.ps1 retry-failed
```

### Utilities

```powershell
# Generate SSH key
.\dot.ps1 gen-ssh-key
.\dot.ps1 gen-ssh-key user@github.com

# Summarize recent commits with Claude
.\dot.ps1 summary -n 5
.\dot.ps1 summary -n 5 -v -d

# Benchmark PowerShell startup
.\dot.ps1 benchmark-shell -r 20

# Completions info
.\dot.ps1 completions
```

## Options

- `--skip-ssh` - Skip SSH key generation (init only)
- `--skip-font` - Skip font installation (init only)
- `--skip-packages` - Skip package installation (init only)
- `--version` - Show version information
- `-h`, `--help` - Show help

## Command Clarification

- `dot stow` creates symlinks from `home/` into `~`.
- `dot link` adds the repo root to the *user* PATH (so `dot` works everywhere).
- `dot init` requires Windows Developer Mode for symlink creation.

## Running From Anywhere

- `dot.cmd` lets you run `dot` from Command Prompt once the repo is in PATH.
- After `dot link`, `dot <command>` works in PowerShell or cmd.exe.
