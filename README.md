# Dotfiles

A Windows dotfiles system with deep Claude Code integration. One command sets up your entire development environment — including a modular AI agent configuration with custom rules, skills, and subagents.

## Quick Start

```powershell
# 1. Enable Developer Mode (required for symlinks)
#    Settings > Privacy & Security > For Developers > Developer Mode: ON

# 2. Clone
git clone https://github.com/YOUR_USERNAME/dotfiles.git $env:USERPROFILE\.dotfiles

# 3. Configure git identity
notepad $env:USERPROFILE\.dotfiles\home\.config\git\config
# Add your name and email under [user]

# 4. Initialize everything
cd $env:USERPROFILE\.dotfiles
.\dot.ps1 init

# 5. Restart your terminal
```

That's it. `dot init` handles packages, symlinks, SSH keys, fonts, Claude Code setup, PATH configuration, and runs a health check.

After restart, the `dot` command is available globally.

## What You Get

### Development Environment

- **PowerShell** profile with aliases and starship prompt
- **Git** config with delta diff viewer and conditional work identity
- **Neovim** (Lua-based) with LSP, Telescope, Treesitter, Harpoon
- **Windows Terminal** profiles and color schemes
- **ripgrep**, **starship**, **IdeaVim** configs
- **Jujutsu** (jj) version control config

### Claude Code Configuration

A modular agent framework that gets symlinked to `~/.claude/`:

| Layer | Purpose | Location |
|-------|---------|----------|
| **CLAUDE.md** | Identity, epistemological framework, execution model | `home/.claude/CLAUDE.md` |
| **Rules** (7) | Operational mandates — one concept per file | `home/.claude/rules/` |
| **Skills** (9) | Domain protocols with principle-level activation | `home/.claude/skills/` |
| **Agents** (3) | Custom subagents that carry the full framework | `home/.claude/agents/` |
| **Commands** (1) | Slash command for dotfiles management | `home/.claude/commands/` |

#### Rules

| File | What it governs |
|------|-----------------|
| `epistemic-discipline.md` | Research mandate, claim labeling |
| `source-hierarchy.md` | Source ranking and quality rubric |
| `execution-autonomy.md` | Autonomous execution, research-then-act |
| `root-cause.md` | Root cause analysis, never error-chase |
| `prior-art.md` | Survey before building |
| `learning-notes.md` | Post-completion documentation |
| `tool-mitigations.md` | Known tool failures and workarounds |

#### Skills

| Skill | Activation |
|-------|------------|
| `research` | Any task requiring factual verification or technical investigation |
| `code-review` | Evaluating code changes for correctness, security, standards |
| `debugging` | Systematic root-cause debugging for any failure |
| `planning` | Structured decomposition of complex tasks |
| `tdd` | Test-Driven Development: Red-Green-Refactor |
| `refactoring` | Improving code structure without changing behavior |
| `project-init` | Bootstrapping new projects |
| `session-guard` | Detecting scope creep and generating handoff prompts |
| `skill-sweep` | Auto-routing to the right skill for any task |

#### Agents

| Agent | Replaces | Purpose |
|-------|----------|---------|
| `researcher` | Explore | Deep research with epistemic discipline |
| `builder` | general-purpose | Implementation with full rule/skill propagation |
| `planner` | Plan | Architectural planning with constraint analysis |

Custom agents exist because built-in subagents (Explore, Plan, general-purpose) do **not** inherit CLAUDE.md, rules, or skills. Custom agents carry the full framework via inline rules and the `skills:` frontmatter field.

## Repository Structure

```
~/.dotfiles/
├── dot.ps1                    # CLI tool (PowerShell)
├── dot.cmd                    # Batch wrapper for cmd.exe
├── home/                      # Symlinked to ~ via dot stow
│   ├── .claude/
│   │   ├── CLAUDE.md          # Global instructions
│   │   ├── settings.json      # Claude Code settings
│   │   ├── agents/            # Custom subagents
│   │   │   ├── builder.md
│   │   │   ├── planner.md
│   │   │   └── researcher.md
│   │   ├── rules/             # Operational mandates
│   │   │   ├── epistemic-discipline.md
│   │   │   ├── execution-autonomy.md
│   │   │   ├── learning-notes.md
│   │   │   ├── prior-art.md
│   │   │   ├── root-cause.md
│   │   │   ├── source-hierarchy.md
│   │   │   └── tool-mitigations.md
│   │   ├── skills/            # Domain protocols
│   │   │   ├── code-review/
│   │   │   ├── debugging/
│   │   │   ├── planning/
│   │   │   ├── project-init/
│   │   │   ├── refactoring/
│   │   │   ├── research/
│   │   │   ├── session-guard/
│   │   │   ├── skill-sweep/
│   │   │   └── tdd/
│   │   └── commands/
│   │       └── dot.md         # /dot slash command
│   ├── .config/
│   │   ├── git/               # Git config + ignore
│   │   ├── jj/                # Jujutsu config + hooks
│   │   ├── nvim/              # Neovim (Lua, plugins, LSP)
│   │   ├── powershell/        # PowerShell profile
│   │   ├── ripgrep/           # ripgrep defaults
│   │   ├── windows-terminal/  # Terminal settings
│   │   └── starship.toml      # Prompt config
│   └── .ideavimrc             # JetBrains Vim config
├── packages/
│   ├── packages.json          # Base packages (winget/scoop)
│   └── packages.work.json     # Work-specific packages
├── scripts/                   # Helper scripts (settings, fonts, claude)
├── backups/                   # Configuration snapshots
└── docs/                      # Architecture docs
```

## CLI Reference

### Setup

```powershell
dot init                  # Full setup (packages, symlinks, SSH, fonts, PATH)
dot init --skip-packages  # Skip package installation
dot init --skip-ssh       # Skip SSH key generation
dot init --skip-font      # Skip font installation
```

### Maintenance

```powershell
dot update          # Pull latest, re-stow, upgrade packages
dot doctor          # Health check diagnostics
dot stow            # Create/update symlinks
dot stow --force    # Overwrite conflicts
dot unstow          # Remove managed symlinks
dot edit            # Open dotfiles in $EDITOR
```

### Packages

```powershell
dot package list              # Show all packages and status
dot package install           # Install from manifest
dot package add Git.Git       # Add + install a package
dot package remove Git.Git    # Remove from manifest
dot package update            # Upgrade all packages
dot check-packages            # Check installed vs manifest
dot retry-failed              # Retry failed installs
```

### Backup & Restore

```powershell
dot backup                # Create timestamped backup
dot backup my-snapshot    # Create named backup
dot backup list           # List available backups
dot backup clean          # Remove backups older than 30 days
dot restore my-snapshot   # Restore from backup
```

### Utilities

```powershell
dot link              # Add dotfiles to PATH
dot unlink            # Remove from PATH
dot gen-ssh-key       # Generate SSH key
dot summary           # AI summary of recent commits
dot benchmark-shell   # Measure PowerShell startup time
dot settings          # Apply Windows settings
dot fonts             # Install development fonts
dot claude            # Setup Claude Code
```

## Customization

### For friends forking this repo

1. **Identity**: Edit `home/.claude/CLAUDE.md` — change the identity section to your own preferences
2. **Git**: Edit `home/.config/git/config` — set your name and email
3. **Packages**: Edit `packages/packages.json` — add/remove tools
4. **Skills**: Add `home/.claude/skills/your-skill/SKILL.md` — Claude Code picks them up automatically
5. **Rules**: Edit files in `home/.claude/rules/` — each rule is self-contained

### File editing workflow

```powershell
# Always edit in home/, not in your actual home directory
# Changes in ~ get overwritten by dot stow

dot backup pre-changes        # Safety net
# Edit files in home/...
dot stow                      # Apply changes
dot doctor                    # Verify
```

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ (ships with Windows)
- Developer Mode enabled (for symlinks without admin)
- Internet connection (for packages)

## How It Works

`dot stow` creates file-level symlinks from `home/` to `~`. Your home directory points back to the repo — edits to `~/.claude/CLAUDE.md` are actually edits to `~/.dotfiles/home/.claude/CLAUDE.md`. This means `git diff` always shows your changes, and `git pull` + `dot stow` keeps you updated.

`dot init` orchestrates the full setup: Developer Mode check, Windows settings, SSH key generation, font installation, Claude Code setup, git identity verification, backup, package installation, symlink creation, PATH configuration, and health diagnostics.

## Troubleshooting

**`dot: command not found`**

```powershell
cd $env:USERPROFILE\.dotfiles
.\dot.ps1 link
```

**Symlink permission denied**

Enable Developer Mode: Settings > Privacy & Security > For Developers > Developer Mode: ON

**Package installation fails**

```powershell
dot check-packages    # See what's missing
dot retry-failed      # Retry failures
winget install Package.Name  # Manual fallback
```

**Claude Code not picking up config**

```powershell
dot stow              # Ensure symlinks exist
dot doctor            # Check Claude Code section
```

## Acknowledgments

- [dmmulroy/.dotfiles](https://github.com/dmmulroy/.dotfiles) — original inspiration
- [Anthropic Claude Code](https://docs.anthropic.com/en/docs/claude-code) — AI-powered development
