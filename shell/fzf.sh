#!/bin/sh
# fzf integration and bat preview configuration.

export BAT_CONFIG_PATH=$TERMINAL_SETUP_HOME/config/bat.conf

# The preview forces colour itself, so bat.conf can leave colour on auto and
# piped bat output stays plain. Entries that are not files get an empty pane.
export FZF_DEFAULT_OPTS='--preview "[ -f {} ] && bat --color=always {}" --border=bold --preview-window=right:50% --walker-skip=.git,node_modules,target,build,dist,venv,__pycache__'

# History lines and directories are not files; hide the preview pane for them.
# Values already set in local/init.sh are kept.
export FZF_CTRL_R_OPTS=${FZF_CTRL_R_OPTS---no-preview}
export FZF_ALT_C_OPTS=${FZF_ALT_C_OPTS---no-preview}

if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND=
  if [ -n "${ZSH_VERSION:-}" ] && fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  elif [ -n "${BASH_VERSION:-}" ] && fzf --bash >/dev/null 2>&1; then
    eval "$(fzf --bash)"
  fi
fi
