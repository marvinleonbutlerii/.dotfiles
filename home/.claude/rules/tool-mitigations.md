# Tool Mitigations Registry

## Purpose

Known tool failures and their automatic workarounds. When a tool produces unexpected results, consult this registry BEFORE investigating from scratch. If the failure matches a known pattern, apply the mitigation immediately.

This registry grows: every new tool failure discovered during any session MUST be added here.

## Registry

### Glob — Symlink Blindness
- **Trigger:** Glob returns fewer results than expected on directories containing symlinks
- **Bug:** #16507 (fast-glob doesn't follow Windows symlinks/ReparsePoints)
- **Mitigation:** Use PowerShell `Get-ChildItem` for completeness-critical file discovery on symlinked directories. Alternatively, Glob against the canonical source directory (`~/.dotfiles/home/.claude/`) which contains real files, not symlinks.
- **Status:** Open, no upstream fix
- **Added:** 2026-02-08

### Parallel Tool Calls — Cascade Failure
- **Trigger:** `<tool_use_error>Sibling tool call errored</tool_use_error>`
- **Bug:** #22264 (one failed parallel call cancels all siblings)
- **Mitigation:** When any parallel call might fail (e.g., Bash commands that may hit `command not found`), run calls sequentially instead. After a cascade failure, retry the cancelled siblings individually.
- **Status:** Open, partial fix in v2.1.7
- **Added:** 2026-02-08

### Bash — Minimal Environment
- **Trigger:** `command not found` for basic Unix utils (tr, head, which, type, less, etc.)
- **Root cause:** Claude Code's Bash is Git Bash with a stripped `/usr/bin`. Many standard Unix utilities are absent.
- **Mitigation:** SessionStart hook (`hooks/session-env.sh`) prepends `/c/Tools/Git/usr/bin` to PATH via `CLAUDE_ENV_FILE`. Standard utils (cat, tr, head, tail, sort, wc, etc.) now resolve by name. Fallback: use full paths or PowerShell.
- **Status:** Fixed via SessionStart hook (2026-02-08). Requires new session to activate.
- **Added:** 2026-02-08

### Bash — cygpath Not Resolvable by Bare Name
- **Trigger:** `cygpath: command not found` when using bare `cygpath` in Bash
- **Root cause:** Despite `C:\Tools\Git\usr\bin` being on SYSTEM PATH and visible in `$PATH`, Bash cannot resolve `cygpath` by name. Claude Code may use a hardcoded path (`C:\Program Files\Git\usr\bin\cygpath.exe`) internally.
- **Mitigation:** Use full path: `/c/Tools/Git/usr/bin/cygpath.exe`. Core tools (Read, Write, Edit, Glob, Grep) work regardless — this only affects direct Bash invocations.
- **Status:** Workaround applied (PATH addition), core tools functional
- **Added:** 2026-02-08

### Read — PDF Support
- **Trigger:** User asks to read a PDF file
- **Capability:** The Read tool natively supports PDF files. Use the `pages` parameter for large PDFs (max 20 pages per request).
- **Mitigation:** Never refuse PDF reading. No MCP plugin or external tool needed. For PDFs over 10 pages, the `pages` parameter is REQUIRED.
- **Status:** Working
- **Added:** 2026-02-08

## Registry Maintenance Rules

1. **Add immediately:** When a new tool failure is encountered that isn't in this registry, add it in the same session
2. **Update on fix:** When an upstream bug is fixed, update the status and test whether the mitigation is still needed
3. **Remove when obsolete:** If a mitigation is no longer needed (bug fixed, tool changed), remove the entry entirely
4. **Required fields:** Trigger, root cause or bug number, mitigation steps, status, date added
