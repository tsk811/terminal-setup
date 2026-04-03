#!/usr/bin/env zsh
# ============================================================================
# Terminal Setup — Main Entry Point
# ============================================================================
# Source this file to load all aliases and plugins.
# Usage:
#   source /path/to/terminal-setup/setup.sh
#   source <(curl -fsSL https://raw.githubusercontent.com/tsk811/terminal-setup/main/setup.sh)
#
# This script ONLY loads aliases and plugins. It does NOT install tools.
# To install tools, run install-tools.sh separately.
# ============================================================================

# -- Resolve the directory this script lives in ------------------------------
# Works whether sourced locally or via curl pipe
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  _TERMINAL_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${(%):-%N}" ]]; then
  _TERMINAL_SETUP_DIR="${${(%):-%N}:A:h}"
else
  # Fallback: if sourced via curl, we can't resolve the dir.
  # Check common clone locations.
  if [[ -d "$HOME/.terminal-setup" ]]; then
    _TERMINAL_SETUP_DIR="$HOME/.terminal-setup"
  elif [[ -d "$HOME/terminal-setup" ]]; then
    _TERMINAL_SETUP_DIR="$HOME/terminal-setup"
  else
    echo "[terminal-setup] ⚠  Cannot resolve script directory."
    echo "[terminal-setup]    Clone the repo and source setup.sh from the clone:"
    echo "[terminal-setup]    git clone https://github.com/tsk811/terminal-setup.git ~/.terminal-setup"
    echo "[terminal-setup]    source ~/.terminal-setup/setup.sh"
    return 1 2>/dev/null || exit 1
  fi
fi

export TERMINAL_SETUP_DIR="$_TERMINAL_SETUP_DIR"

# -- Helper: source a file if it exists --------------------------------------
_ts_source() {
  if [[ -r "$1" ]]; then
    source "$1"
  else
    echo "[terminal-setup] ⚠  Missing: $1"
  fi
}

# ============================================================================
# 1. ALIASES
# ============================================================================
_ts_source "$TERMINAL_SETUP_DIR/aliases/aliases.sh"

# ============================================================================
# 2. PLUGINS (only for zsh)
# ============================================================================
if [[ -n "$ZSH_VERSION" ]]; then
  # Provide git_current_branch if not already defined (required by git plugin)
  if ! typeset -f git_current_branch > /dev/null 2>&1; then
    function git_current_branch() {
      local ref
      ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
      local ret=$?
      if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return  # no git repo
        ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
      fi
      echo ${ref#refs/heads/}
    }
  fi

  # Git plugin
  _ts_source "$TERMINAL_SETUP_DIR/plugins/git.plugin.zsh"

  # AWS plugin
  _ts_source "$TERMINAL_SETUP_DIR/plugins/aws.plugin.zsh"

  # Terraform plugin
  _ts_source "$TERMINAL_SETUP_DIR/plugins/terraform.plugin.zsh"

  # Tmux plugin
  _ts_source "$TERMINAL_SETUP_DIR/plugins/tmux/tmux.plugin.zsh"

  # Zsh Autosuggestions
  _ts_source "$TERMINAL_SETUP_DIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
  echo "[terminal-setup] ℹ  Plugins skipped (zsh-only). Current shell: $SHELL"
fi

# ============================================================================
# 3. TOOL CONFIGS (fzf, bat, etc.)
# ============================================================================
_ts_source "$TERMINAL_SETUP_DIR/config/fzf.sh"

# ============================================================================
# 4. PATH — add repo's tool bin directory
# ============================================================================
if [[ -d "$TERMINAL_SETUP_DIR/bin" ]]; then
  case ":$PATH:" in
    *":$TERMINAL_SETUP_DIR/bin:"*) ;;
    *) export PATH="$TERMINAL_SETUP_DIR/bin:$PATH" ;;
  esac
fi

# ============================================================================
# Done
# ============================================================================
echo "[terminal-setup] ✅ Aliases and plugins loaded from $TERMINAL_SETUP_DIR"

# Cleanup internal helper
unfunction _ts_source 2>/dev/null
unset _TERMINAL_SETUP_DIR
