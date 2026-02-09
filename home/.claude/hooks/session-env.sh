#!/bin/bash
# Prepend Git usr/bin to PATH so standard Unix utilities (cat, tr, head,
# tail, which, wc, sort, etc.) resolve by name in Claude Code's Bash shell.

if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo 'export PATH="/c/Tools/Git/usr/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi

exit 0
