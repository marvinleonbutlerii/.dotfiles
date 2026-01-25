# DOTFILES

**Generated:** 2026-01-24T23:07:39-08:00
**Scope:** Windows dev env via PowerShell + winget/scoop + Neovim + Git + jj.

## STRUCTURE

```
.dotfiles/
├── dot.ps1           # CLI (PowerShell)
├── dot.cmd           # Batch wrapper for cmd.exe
├── home/             # Symlinked to ~/
│   ├── .claude/      # Claude Code config
│   ├── .config/      # XDG-style config
│   │   ├── git/      # Git config/ignore
│   │   ├── jj/       # Jujutsu config + hooks
│   │   ├── nvim/     # Neovim (AGENTS.md)
│   │   ├── powershell/  # PowerShell profile
│   │   ├── ripgrep/  # ripgrep config
│   │   ├── windows-terminal/ # Terminal settings
│   │   └── starship.toml
│   └── .ideavimrc
├── packages/
│   ├── packages.json       # Base packages (winget/scoop)
│   ├── packages.work.json  # Work packages
│   └── failed_packages_*.txt
├── scripts/          # Helper scripts (settings/fonts/claude)
└── docs/
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Add package | `dot package add ...` or edit `packages/packages.json` / `packages/packages.work.json` |
| PowerShell profile | `home/.config/powershell/Microsoft.PowerShell_profile.ps1` |
| Git config/aliases | `home/.config/git/config` |
| Git ignore | `home/.config/git/ignore` |
| Neovim plugin | `home/.config/nvim/lua/plugins/<name>.lua` |
| Neovim keymap | `home/.config/nvim/lua/dmmulroy/keymaps.lua` |
| jj config | `home/.config/jj/config.toml` |
| Windows Terminal | `home/.config/windows-terminal/settings.json` |
| Starship | `home/.config/starship.toml` |
| ripgrep | `home/.config/ripgrep/config` |

## CONVENTIONS

- Stow layout: `home/` mirrors `~`, `dot stow` creates file-level symlinks.
- PowerShell: keep shell config in `Microsoft.PowerShell_profile.ps1`.
- Neovim: 1 plugin per file in `lua/plugins/`, `init.lua` loads `dmmulroy`.
- Packages: manifests are the source of truth; prefer `dot package` to edit them.
- Work Git identity: conditional include for `~/Code/work/` in `home/.config/git/config`.

## ANTI-PATTERNS

- Edit `~/.config/*` directly (changes are overwritten by stow).
- Hardcode machine/user paths (use `$env:USERPROFILE` or `$HOME`).
- Add packages outside the manifests without updating `packages/*.json`.
- Store secrets in the repo.

## COMMANDS

```powershell
dot init              # Full setup (settings, ssh, fonts, packages, stow, PATH)
dot update            # Pull + restow + winget upgrade
dot doctor            # Health check
dot stow              # Create/update symlinks (use --force to overwrite)
dot unstow            # Remove managed symlinks
dot package ...       # Package management (see docs/cli.md)
dot check-packages    # Report installed/missing packages
dot retry-failed      # Retry from failed_packages_*.txt
dot gen-ssh-key       # Generate SSH key (optional email)
dot summary           # AI summary of recent commits (requires claude)
dot benchmark-shell   # PowerShell startup perf
```

## KEY CONFIGS

| Tool | Entry | Notes |
|------|-------|-------|
| PowerShell | `home/.config/powershell/Microsoft.PowerShell_profile.ps1` | sets PATH/env + prompt |
| Neovim | `home/.config/nvim/init.lua` | entry point |
| Git | `home/.config/git/config` | includes work config |
| jj | `home/.config/jj/config.toml` | signing + hooks |
| Starship | `home/.config/starship.toml` | prompt |
| Windows Terminal | `home/.config/windows-terminal/settings.json` | profiles/colors |

## UNIQUE STYLES

- nvim: `jj`/`JJ` exits insert mode, `H`/`L` jump line start/end.
- diff tooling: diffview + vcsigns for jj/git (see docs/nvim-vcs-tools.md).

## NOTES

- Developer Mode is required for symlink creation.
- `dot init` stops if Git user name/email are missing in `home/.config/git/config`.
- `dot summary` requires the `claude` CLI in PATH.
- Neovim has its own guidance in `home/.config/nvim/AGENTS.md`.
