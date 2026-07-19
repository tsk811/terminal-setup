#!/bin/sh
# Install the tools declared in config/aqua.yaml. No root access is used.

set -eu

TERMINAL_SETUP_HOME=${TERMINAL_SETUP_HOME:-$HOME/.terminal-setup}
export TERMINAL_SETUP_HOME
export AQUA_ROOT_DIR=$TERMINAL_SETUP_HOME/tools
export AQUA_GLOBAL_CONFIG=$TERMINAL_SETUP_HOME/config/aqua.yaml

AQUA=$AQUA_ROOT_DIR/bin/aqua
[ -x "$AQUA" ] || {
  printf '[terminal-setup] Aqua is missing. Run the bootstrap again.\n' >&2
  exit 1
}
[ -r "$AQUA_GLOBAL_CONFIG" ] || {
  printf '[terminal-setup] Missing %s\n' "$AQUA_GLOBAL_CONFIG" >&2
  exit 1
}

"$AQUA" --config "$AQUA_GLOBAL_CONFIG" install
