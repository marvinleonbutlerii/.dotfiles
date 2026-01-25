# Architecture

This dotfiles repository is a Windows-first environment built around PowerShell, winget/scoop, and file-level symlinks. All configuration files live under `home/` and are linked into the user profile.

## Key Design Patterns

- Stow-like symlinks: `dot stow` mirrors `home/` into `~` using file-level symbolic links.
- JSON package manifests: `packages/packages.json` (base) and `packages/packages.work.json` (work) are the source of truth for installs.
- Conditional Git config: `home/.config/git/config` includes work-specific config for `~/Code/work/`.
- Tool-specific config under `~/.config` (git, jj, nvim, powershell, ripgrep, windows-terminal, starship).

## Important Relationships

- `dot init` orchestrates settings -> SSH key -> fonts -> Claude -> backup -> packages -> symlinks -> PATH -> doctor.
- `dot update` runs `git pull` (if available), recreates symlinks, and runs `winget upgrade --all`.
- `dot doctor` checks required tools, Claude config, symlink health, and PATH.
- `dot package` installs via winget/scoop and logs failures to `packages/failed_packages_*.txt` for `dot retry-failed`.

## Non-obvious Details

- Symlinks require Windows Developer Mode; `dot init` exits early if it is disabled.
- `dot stow --force` overwrites existing targets; without `--force`, existing files are skipped.
- `dot gen-ssh-key` derives the key name from the email domain (for example, `id_ed25519_github_com`).
- `dot link` edits the *user* PATH, not the system PATH.
- `dot summary` shells out to the `claude` CLI and must run inside a git repo.
