#!/bin/sh
# ============================================================================
# fzf & bat Configuration
# ============================================================================
# Sourced automatically by setup.sh when fzf is available.
# Compatible with sh, bash, and zsh.
# ============================================================================

# -- bat config path (bundled in this repo) ----------------------------------
export BAT_CONFIG_PATH="$TERMINAL_SETUP_DIR/config/bat.conf"

# -- fzf shell integration --------------------------------------------------
# Modern method (fzf >= 0.48): generates key bindings + completion on the fly.
# FZF_CTRL_T_COMMAND= disables CTRL-T file widget (blank = disabled).
# Falls back to sourcing ~/.fzf.zsh or ~/.fzf.bash for older fzf versions.
if command -v fzf >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    # zsh: use process substitution for modern fzf
    if fzf --zsh >/dev/null 2>&1; then
      FZF_CTRL_T_COMMAND= eval "$(fzf --zsh)"
    elif [ -f ~/.fzf.zsh ]; then
      . ~/.fzf.zsh
    fi
  elif [ -n "${BASH_VERSION:-}" ]; then
    # bash: use eval for modern fzf
    if fzf --bash >/dev/null 2>&1; then
      FZF_CTRL_T_COMMAND= eval "$(fzf --bash)"
    elif [ -f ~/.fzf.bash ]; then
      . ~/.fzf.bash
    fi
  fi
fi

# -- fzf default options -----------------------------------------------------
export FZF_DEFAULT_OPTS='--preview "bat {}" --border=bold --preview-window=right:50% --walker-skip=.git,node_modules,target,build,dist,venv,__pycache__'
