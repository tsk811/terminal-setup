#!/bin/sh
# Portable aliases shared by Bash and Zsh.

alias dev='cd "$HOME/Documents/DEV"'
alias doc='cd "$HOME/Documents"'
alias pro='cd "$HOME/Documents/DEV/projects"'
alias dwn='cd "$HOME/Downloads"'
alias b='cd ..'
alias x='clear'

# Detailed listing in three alphabetical groups:
#   1. hidden entries, 2. visible directories, 3. visible non-directories.
# A subshell keeps null-glob settings and helper functions local to each call.
l() (
  local -a _ts_hidden _ts_directories _ts_files
  local _ts_entry

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt local_options null_glob
  else
    shopt -s nullglob
  fi

  _ts_hidden=(.[!.]* ..?*)
  for _ts_entry in *; do
    if [ -d "$_ts_entry" ]; then
      _ts_directories+=("$_ts_entry")
    else
      _ts_files+=("$_ts_entry")
    fi
  done

  _ts_l_print() {
    [ "$#" -gt 0 ] || return 0
    if command ls --color=always -d . >/dev/null 2>&1; then
      command ls -ldh --color=always -- "$@"
    else
      command env CLICOLOR=1 CLICOLOR_FORCE=1 ls -ldhG -- "$@"
    fi
  }

  _ts_l_print "${_ts_hidden[@]}"
  _ts_l_print "${_ts_directories[@]}"
  _ts_l_print "${_ts_files[@]}"
)

if [ -n "${ZSH_VERSION:-}" ]; then
  alias rl='source ~/.zshrc'
else
  alias rl='source ~/.bashrc'
fi
