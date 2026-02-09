# .dotfiles

My Windows dev environment. One command installs everything, symlinks all configs, and sets up Claude Code with a custom agent framework that actually makes it useful.

## Why this exists

Claude Code's default agents are amnesiacs. When Claude spawns a subagent (Explore, Plan, general-purpose), that subagent gets *nothing*. No CLAUDE.md. No rules. No skills. It starts from a blank prompt every time. So all the effort you put into configuring Claude's behavior? Gone the moment it delegates work.

I fixed that. This repo includes three custom agents that replace the built-ins and carry the full config with them — rules, skills, everything. The subagents work the same way the main agent does. That's the whole point.

It also sets up my full Windows dev environment in one command (`dot init` — packages, symlinks, SSH keys, fonts, PATH, the works), but the Claude Code config is the reason you're here.

## What's in the box

**Dev environment:** PowerShell profile with aliases, starship prompt, git with delta diffs and conditional work identity, Neovim (Lua-based, 80+ plugin configs, LSP, Telescope, Treesitter, Harpoon), Windows Terminal, ripgrep, Jujutsu, and about 19 packages installed via winget. Everything lives in `home/` and gets symlinked to `~`.

**Claude Code config:** This is the part I spent the most time on. It's a layered system:

- **CLAUDE.md** gives the agent an identity and a set of operating principles. Mine is configured to research before acting, never present training data as knowledge, and find a better path when the requested one has problems. You'd change this to match how you want Claude to work.
- **Rules** (7 files) are hard constraints. Things like "always do root-cause analysis, never chase symptoms" and "survey existing solutions before building from scratch." Each rule covers one concept and lives in one file.
- **Skills** (9) are domain protocols that activate based on what you're doing. When Claude hits a bug, the debugging skill kicks in and enforces a specific investigation protocol instead of letting it guess-and-check. When it needs to research something, the research skill forces it through source evaluation and claim labeling. TDD, code review, planning, refactoring — each one has a defined workflow.
- **Agents** (3) are the custom subagents. Researcher replaces Explore, builder replaces general-purpose, planner replaces Plan. They embed the rules inline and load skills via frontmatter so the full framework propagates to every subprocess.

The difference is real. Without this, Claude guesses at answers, skips research, chases error messages one by one, and forgets everything when it spawns a subagent. With it, Claude looks things up before answering, tells you when it's unsure, fixes root causes instead of symptoms, and the subagents behave the same way.

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

`dot stow` creates symlinks from `home/` into your home directory. When you edit `~/.claude/CLAUDE.md`, you're actually editing `~/.dotfiles/home/.claude/CLAUDE.md`. Your changes show up in `git diff`, and `git pull` + `dot stow` keeps everything in sync.

## Forking this

If you want to use this as a starting point:

1. **Change the identity.** Edit `home/.claude/CLAUDE.md` — the identity section defines how Claude behaves. Make it yours.
2. **Set your git info.** Edit `home/.config/git/config` with your name and email.
3. **Pick your packages.** Edit `packages/packages.json` — add or remove whatever you want.
4. **Add skills.** Drop a `SKILL.md` into `home/.claude/skills/your-skill/` and Claude Code picks it up automatically.
5. **Edit rules.** Each file in `home/.claude/rules/` is self-contained. Change what you disagree with, delete what you don't need.

One thing to keep in mind: always edit files in `home/`, not in your actual home directory. `dot stow` overwrites symlink targets with whatever's in `home/`.

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ (comes with Windows)
- Developer Mode enabled
- Internet connection for package installation

## Troubleshooting

**`dot: command not found`** — Run `.\dot.ps1 link` from the repo directory.

**Symlink permission denied** — Enable Developer Mode: Settings > Privacy & Security > For Developers > Developer Mode: ON

**Package install fails** — Run `dot check-packages` to see what's missing, `dot retry-failed` to retry, or install manually with `winget install Package.Name`.

**Claude Code not picking up config** — Run `dot stow` to make sure symlinks exist, then `dot doctor` to check.

## Credit

Started from [dmmulroy's dotfiles](https://github.com/dmmulroy/.dotfiles) and went sideways from there.
