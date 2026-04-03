#!/usr/bin/env bash
# ============================================================================
# Terminal Aliases
# ============================================================================
# Sourced automatically by setup.sh
# Add, remove or modify aliases here freely.
# ============================================================================

# -- Navigation --------------------------------------------------------------
alias dev="cd ~/Documents/DEV"
alias doc="cd ~/Documents"
alias pro="cd ~/Documents/DEV/projects"
alias dwn="cd ~/Downloads"
alias b="cd .."

# -- Utilities ----------------------------------------------------------------
alias x="clear"
alias rl="source ~/.zprofile"

# -- ls override (with color) ------------------------------------------------
# macOS ls doesn't support --color=always natively; use gls if available,
# otherwise fallback to macOS-style coloring.
if ls --color=always / >/dev/null 2>&1; then
  alias ls="ls -lah --color=always"
else
  alias ls="ls -lahG"
fi
