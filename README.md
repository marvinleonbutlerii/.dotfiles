# .dotfiles

A Claude Code config that fixes the things that actually drive people crazy: sycophancy, error-chasing loops, hallucinated APIs, subagents that forget everything, and instructions that get read but not followed. Also sets up a full Windows dev environment, but that's not why you're here.

## What this fixes

**Claude agrees with everything you say, even when you're wrong.** Lilith bans performative agreement ("You're right!", "Great point!"), emotional mirroring, and hedging. Lilith states what is true. If you're wrong, it says so.

**Claude guesses instead of looking things up.** The research skill and epistemic discipline rule force Lilith to search external sources before answering any factual or technical question. Training data is treated as unverified hypothesis, not knowledge. Every claim gets labeled: verified, inferred, or unknown.

**Claude chases errors one at a time instead of finding the root cause.** The debugging skill and root-cause rule prohibit sequential error-chasing. Lilith reads the full error landscape before touching anything, identifies the deepest architectural cause, and fixes it in one pass. Then it scans the rest of the codebase for the same class of mistake.

**Claude Code's subagents start from a blank prompt every time.** Built-in subagents (Explore, Plan, general-purpose) don't inherit CLAUDE.md, rules, or skills. Three custom agents (researcher, builder, planner) replace them and carry the full config through inline rules and the `skills:` frontmatter field.

**CLAUDE.md instructions get read but not followed.** Rules are written as hard constraints, not suggestions. Each rule lives in one file and covers one concept. Skills activate based on task type and enforce specific protocols (debugging, TDD, code review, research) instead of leaving Lilith to improvise.

**Claude Code's output reads like AI slop.** The communication rules ban specific detectable patterns: em dashes, sycophantic openers, uniform sentence length, parallel triads, filler transitions, banned vocabulary (delve, comprehensive, robust, leverage, seamless), sign-off summaries, and throat-clearing introductions.

## What's in the config

The Claude Code config lives in `home/.claude/` and gets symlinked to `~/.claude/`.

**CLAUDE.md** sets the identity and operating principles. It controls how Lilith communicates, what it's allowed to assume, and when it must research before acting.

**Rules** (7 files in `rules/`) are hard constraints. One concept per file:
- `epistemic-discipline.md` forces research before answering, labels all claims by confidence level
- `source-hierarchy.md` ranks sources in four tiers and defines what counts as evidence
- `execution-autonomy.md` makes Lilith execute instead of asking permission for obvious next steps
- `root-cause.md` bans error-chasing, requires one-pass holistic review
- `prior-art.md` requires surveying existing solutions before building anything
- `tool-mitigations.md` is a self-healing registry of known tool failures and workarounds
- `learning-notes.md` generates post-completion documentation

**Skills** (9 in `skills/`) are domain protocols that activate based on task type. The debugging skill enforces a specific investigation sequence. The research skill forces source evaluation. TDD enforces Red-Green-Refactor. Code review, planning, refactoring, project-init, and session-guard each have defined workflows.

**Agents** (3 in `agents/`) replace Claude Code's built-in subagents. Researcher replaces Explore. Builder replaces general-purpose. Planner replaces Plan. Each one embeds rules inline and loads skills via frontmatter, so every subprocess operates under the same discipline.

## Dev environment

Also included: PowerShell profile with aliases, starship prompt, git with delta diffs and conditional work identity, Neovim (Lua-based, 80+ plugin configs), Windows Terminal, ripgrep, Jujutsu, and 19 packages installed via winget. Everything in `home/` gets symlinked to `~`.

## Quick start

```powershell
# 1. Enable Developer Mode (required for symlinks)
#    Settings > Privacy & Security > For Developers > Developer Mode: ON

# 2. Clone
git clone https://github.com/marvinleonbutlerii/.dotfiles.git $env:USERPROFILE\.dotfiles

# 3. Set your git identity
notepad $env:USERPROFILE\.dotfiles\home\.config\git\config

# 4. Run init
cd $env:USERPROFILE\.dotfiles
.\dot.ps1 init

# 5. Restart your terminal
```

`dot init` handles packages, symlinks, SSH keys, fonts, Claude Code setup, PATH, and a health check. After restart, `dot` is available globally.

## CLI

```powershell
# Setup
dot init                       # Full setup
dot init --skip-packages       # Skip package installation
dot init --skip-ssh            # Skip SSH key generation

# Day-to-day
dot update                     # Pull, re-stow, upgrade packages
dot doctor                     # Health check
dot stow                      # Create/update symlinks
dot stow --force               # Overwrite conflicts
dot edit                       # Open dotfiles in $EDITOR
dot backup                     # Snapshot before you break something
dot restore my-snapshot        # Undo the breakage

# Packages
dot package list               # What's installed vs. what should be
dot package add Git.Git        # Add to manifest and install
dot package remove Git.Git     # Remove from manifest
dot package update             # Upgrade everything
dot retry-failed               # Retry failed installs
```

## Repo layout

```
~/.dotfiles/
├── dot.ps1                # The CLI
├── home/                  # Everything here gets symlinked to ~
│   ├── .claude/           # Claude Code config
│   │   ├── CLAUDE.md      #   Identity and operating principles
│   │   ├── settings.json  #   Permissions, env vars, MCP servers
│   │   ├── rules/         #   7 operational constraints
│   │   ├── skills/        #   9 domain protocols
│   │   ├── agents/        #   3 custom subagents
│   │   └── commands/      #   /dot slash command
│   └── .config/           # Tool configs
│       ├── git/           #   Git identity + conditional work config
│       ├── nvim/          #   Neovim (Lua, 80+ files)
│       ├── powershell/    #   Shell profile + aliases
│       ├── starship.toml  #   Prompt
│       └── ...            #   ripgrep, windows-terminal, jj
├── packages/              # What to install (JSON manifests)
├── scripts/               # Bootstrap helpers
└── docs/                  # Architecture notes
```

## How it works

`dot stow` creates symlinks from `home/` into your home directory. When you edit `~/.claude/CLAUDE.md`, you're actually editing `~/.dotfiles/home/.claude/CLAUDE.md`. Changes show up in `git diff`. `git pull` + `dot stow` keeps everything in sync.

## Forking this

1. **Change the identity.** Edit `home/.claude/CLAUDE.md`. The identity section defines how Lilith communicates and operates.
2. **Set your git info.** Edit `home/.config/git/config` with your name and email.
3. **Pick your packages.** Edit `packages/packages.json`.
4. **Add skills.** Drop a `SKILL.md` into `home/.claude/skills/your-skill/` and Claude Code picks it up automatically.
5. **Edit rules.** Each file in `home/.claude/rules/` is self-contained. Change what you disagree with, delete what you don't need.

Always edit files in `home/`, not in your actual home directory. `dot stow` overwrites symlink targets.

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ (comes with Windows)
- Developer Mode enabled
- Internet connection for package installation

## Troubleshooting

**`dot: command not found`** Run `.\dot.ps1 link` from the repo directory.

**Symlink permission denied** Enable Developer Mode: Settings > Privacy & Security > For Developers > Developer Mode: ON

**Package install fails** Run `dot check-packages` to see what's missing, `dot retry-failed` to retry, or `winget install Package.Name` manually.

**Claude Code not picking up config** Run `dot stow` to make sure symlinks exist, then `dot doctor` to check.

## Credit

Started from [dmmulroy's dotfiles](https://github.com/dmmulroy/.dotfiles) and went sideways from there.
