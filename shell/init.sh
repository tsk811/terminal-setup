#!/bin/sh
# Shared Bash/Zsh startup. This file performs no network access.

if [ -n "${TERMINAL_SETUP_LOADED:-}" ] && [ -z "${TERMINAL_SETUP_RELOAD:-}" ]; then
  return 0 2>/dev/null || exit 0
fi

export TERMINAL_SETUP_HOME=${TERMINAL_SETUP_HOME:-$HOME/.terminal-setup}
export AQUA_ROOT_DIR=$TERMINAL_SETUP_HOME/tools
export AQUA_GLOBAL_CONFIG=$TERMINAL_SETUP_HOME/config/aqua.yaml

case ":$PATH:" in
  *":$AQUA_ROOT_DIR/bin:"*) ;;
  *) export PATH="$AQUA_ROOT_DIR/bin:$PATH" ;;
esac

_ts_source() {
  [ -r "$1" ] || return 0
  # shellcheck disable=SC1090
  . "$1" || printf '[terminal-setup] Could not load %s\n' "$1" >&2
}

# Local environment and plugin choices load before managed configuration.
_ts_source "$TERMINAL_SETUP_HOME/local/init.sh"
_ts_source "$TERMINAL_SETUP_HOME/shell/aliases.sh"
_ts_source "$TERMINAL_SETUP_HOME/local/aliases.sh"

if [ -n "${ZSH_VERSION:-}" ]; then
  if ! whence -w compdef >/dev/null 2>&1; then
    autoload -Uz compinit && compinit
  fi

  : "${TERMINAL_SETUP_PLUGINS:=git autosuggestions}"
  for _ts_plugin in ${(z)TERMINAL_SETUP_PLUGINS}; do
    case $_ts_plugin in
      git)
        if command -v git >/dev/null 2>&1; then
          if ! typeset -f git_current_branch >/dev/null 2>&1; then
            git_current_branch() {
              local ref ret
              ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
              ret=$?
              if [ "$ret" != 0 ]; then
                [ "$ret" = 128 ] && return
                ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
              fi
              printf '%s\n' "${ref#refs/heads/}"
            }
          fi
          _ts_source "$TERMINAL_SETUP_HOME/plugins/git.plugin.zsh"
        fi
        ;;
      aws)
        if command -v aws >/dev/null 2>&1; then
          autoload -Uz colors && colors
          _ts_source "$TERMINAL_SETUP_HOME/plugins/aws.plugin.zsh"
        fi
        ;;
      terraform) command -v terraform >/dev/null 2>&1 && _ts_source "$TERMINAL_SETUP_HOME/plugins/terraform.plugin.zsh" ;;
      tmux)
        if command -v tmux >/dev/null 2>&1; then
          : "${ZSH_TMUX_CONFIG:=$TERMINAL_SETUP_HOME/config/tmux.conf}"
          _ts_source "$TERMINAL_SETUP_HOME/plugins/tmux/tmux.plugin.zsh"
        fi
        ;;
      autosuggestions) _ts_source "$TERMINAL_SETUP_HOME/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ;;
      '') ;;
      *) printf '[terminal-setup] Unknown plugin: %s\n' "$_ts_plugin" >&2 ;;
    esac
  done

  if [ -d "$TERMINAL_SETUP_HOME/local/plugins" ]; then
    for _ts_local_plugin in "$TERMINAL_SETUP_HOME"/local/plugins/*.zsh; do
      [ -e "$_ts_local_plugin" ] || continue
      _ts_source "$_ts_local_plugin"
    done
  fi
fi

_ts_source "$TERMINAL_SETUP_HOME/shell/fzf.sh"

export TERMINAL_SETUP_LOADED=1
unset TERMINAL_SETUP_RELOAD _ts_plugin _ts_local_plugin
if [ -n "${ZSH_VERSION:-}" ]; then
  unfunction _ts_source 2>/dev/null
else
  unset -f _ts_source 2>/dev/null
fi
