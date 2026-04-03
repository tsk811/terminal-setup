#!/bin/sh
# ============================================================================
# Terminal Aliases
# ============================================================================
# Sourced automatically by setup.sh
# Compatible with sh, bash, and zsh.
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
alias rl=". ~/.zprofile"

# -- ls override (with color) ------------------------------------------------
# macOS ls doesn't support --color=always natively;
# fallback to macOS-style coloring (-G).
if ls --color=always / >/dev/null 2>&1; then
  alias ls="ls -lah --color=always"
else
  alias ls="ls -lahG"
fi
