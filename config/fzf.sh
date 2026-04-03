#!/usr/bin/env bash
# ============================================================================
# fzf & bat Configuration
# ============================================================================
# Sourced automatically by setup.sh when fzf is available.
# ============================================================================

# -- bat config path (bundled in this repo) ----------------------------------
export BAT_CONFIG_PATH="$TERMINAL_SETUP_DIR/config/bat.conf"

# -- fzf shell integration --------------------------------------------------
# Modern method (fzf >= 0.48): generates key bindings + completion on the fly.
# FZF_CTRL_T_COMMAND= disables CTRL-T file widget (blank = disabled).
# Falls back to sourcing ~/.fzf.zsh for older fzf versions.
if command -v fzf &>/dev/null; then
  if fzf --zsh &>/dev/null 2>&1; then
    FZF_CTRL_T_COMMAND= source <(fzf --zsh)
  elif [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  fi
fi

# -- fzf default options -----------------------------------------------------
export FZF_DEFAULT_OPTS='\
  --preview "bat {}" \
  --border=bold \
  --preview-window=right:50% \
  --walker-skip=.git,node_modules,target,build,dist,venv,__pycache__'
