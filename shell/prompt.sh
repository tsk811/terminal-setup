#!/bin/sh
# Lightweight interactive prompt for Bash and Zsh.

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# Set TERMINAL_SETUP_PROMPT=0 in local/init.sh to keep the existing prompt.
[ "${TERMINAL_SETUP_PROMPT:-1}" = 1 ] || return 0 2>/dev/null || exit 0

_terminal_setup_git_segment() {
  local _ts_ref

  command -v git >/dev/null 2>&1 || return 0
  _ts_ref=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    _ts_ref=$(command git rev-parse --short HEAD 2>/dev/null) || return 0

  # A doubled percent sign prevents branch names from becoming Zsh prompt escapes.
  if [ -n "${ZSH_VERSION:-}" ]; then
    _ts_ref=${_ts_ref//\%/%%}
  fi
  printf ' git:(%s)' "$_ts_ref"
}

if [ -n "${ZSH_VERSION:-}" ]; then
  setopt prompt_subst
  PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f%F{yellow}$(_terminal_setup_git_segment)%f
%# '
elif [ -n "${BASH_VERSION:-}" ]; then
  PS1='\[\033[36m\]\u@\h\[\033[0m\] \[\033[34m\]\w\[\033[33m\]$(_terminal_setup_git_segment)\[\033[0m\]
\$ '
fi
