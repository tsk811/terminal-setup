#!/bin/sh
# fzf integration and bat preview configuration.

export BAT_CONFIG_PATH=$TERMINAL_SETUP_HOME/config/bat.conf
export FZF_DEFAULT_OPTS='--preview "bat {}" --border=bold --preview-window=right:50% --walker-skip=.git,node_modules,target,build,dist,venv,__pycache__'

if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND=
  if [ -n "${ZSH_VERSION:-}" ] && fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  elif [ -n "${BASH_VERSION:-}" ] && fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  fi
fi
