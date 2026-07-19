#!/bin/sh
# Compatibility entry point when this source repository is used directly.
if [ -n "${BASH_VERSION:-}" ]; then
  TERMINAL_SETUP_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
elif [ -n "${ZSH_VERSION:-}" ]; then
  TERMINAL_SETUP_HOME="${${(%):-%x}:A:h}"
else
  printf '%s\n' 'terminal-setup supports Bash and Zsh.' >&2
  return 1 2>/dev/null || exit 1
fi
export TERMINAL_SETUP_HOME
# shellcheck disable=SC1090
. "$TERMINAL_SETUP_HOME/shell/init.sh"
