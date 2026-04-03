#!/usr/bin/env bash
# ============================================================================
# Terminal Setup — Bootstrap
# ============================================================================
# One-liner to download the repo and get started. No git required.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh)
#
# What it does:
#   1. Downloads the repo as a tarball (via curl) into the current directory
#   2. Presents a menu: source aliases/plugins OR install tools
#
# Supported platforms: macOS, Linux
# ============================================================================

set -euo pipefail

# -- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# -- Config ------------------------------------------------------------------
REPO_OWNER="tsk811"
REPO_NAME="terminal-setup"
BRANCH="main"
TARBALL_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"
INSTALL_DIR="$(pwd)/${REPO_NAME}"

# -- Helpers -----------------------------------------------------------------
info()    { echo -e "${BLUE}[info]${NC}    $*"; }
success() { echo -e "${GREEN}[✔]${NC}       $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}    $*"; }
error()   { echo -e "${RED}[✘]${NC}       $*" >&2; }

# ============================================================================
# Step 1: Download the repo
# ============================================================================
download_repo() {
  if [[ -d "$INSTALL_DIR" ]]; then
    warn "Directory already exists: $INSTALL_DIR"
    echo -ne "${BOLD}  Update to latest? (y/N): ${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      info "Removing old copy..."
      # Preserve the bin/ directory (installed tools) during update
      if [[ -d "$INSTALL_DIR/bin" ]]; then
        mv "$INSTALL_DIR/bin" "/tmp/_terminal_setup_bin_backup_$$"
      fi
      rm -rf "$INSTALL_DIR"
    else
      info "Using existing installation."
      return 0
    fi
  fi

  info "Downloading ${REPO_NAME} from GitHub..."
  local tmp_tar
  tmp_tar=$(mktemp)
  trap 'rm -f "$tmp_tar"' RETURN

  if ! curl -fsSL "$TARBALL_URL" -o "$tmp_tar"; then
    error "Failed to download repo. Check your internet connection."
    exit 1
  fi

  info "Extracting to $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tmp_tar" --strip-components=1 -C "$INSTALL_DIR"

  # Restore preserved bin/ directory if it existed
  if [[ -d "/tmp/_terminal_setup_bin_backup_$$" ]]; then
    mv "/tmp/_terminal_setup_bin_backup_$$" "$INSTALL_DIR/bin"
    info "Restored previously installed tools."
  fi

  chmod +x "$INSTALL_DIR/setup.sh" "$INSTALL_DIR/install-tools.sh"
  success "Repository downloaded to $INSTALL_DIR"
}

# ============================================================================
# Step 2: Interactive menu
# ============================================================================
show_bootstrap_menu() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║         🚀 Terminal Setup — Bootstrap                   ║${NC}"
  echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  Location: ${GREEN}${INSTALL_DIR}${NC}"
  echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[1]${NC} Source aliases & plugins                            ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}      ${DIM}Loads aliases, git/aws/terraform/tmux plugins,${NC}     ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}      ${DIM}and zsh-autosuggestions into current shell.${NC}         ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[2]${NC} Install CLI tools (interactive)                     ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}      ${DIM}fzf, bat, dust, ripgrep, fd — choose which${NC}         ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}      ${DIM}to install. Installs into the repo folder.${NC}         ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[3]${NC} Show shell integration instructions                ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}      ${DIM}How to add this to your ~/.zshrc for auto-load.${NC}    ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[q]${NC} Quit                                               ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

show_integration_instructions() {
  echo ""
  echo -e "${BOLD}${CYAN}── Shell Integration ────────────────────────────────────${NC}"
  echo ""
  echo -e "  Add this line to your ${BOLD}~/.zshrc${NC} or ${BOLD}~/.zprofile${NC}:"
  echo ""
  echo -e "    ${GREEN}source \"${INSTALL_DIR}/setup.sh\"${NC}"
  echo ""
  echo -e "  Then reload your shell:"
  echo ""
  echo -e "    ${GREEN}source ~/.zshrc${NC}"
  echo ""
  echo -e "${BOLD}${CYAN}─────────────────────────────────────────────────────────${NC}"
  echo ""
}

# ============================================================================
# Main
# ============================================================================
main() {
  echo -e "${BOLD}${CYAN}"
  echo '  ╺┳╸┏━╸┏━┓┏┳┓╻┏┓╻┏━┓╻        ┏━┓┏━╸╺┳╸╻ ╻┏━┓'
  echo '   ┃ ┣╸ ┣┳┛┃┃┃┃┃┗┫┣━┫┃   ╺━╸  ┗━┓┣╸  ┃ ┃ ┃┣━┛'
  echo '   ╹ ┗━╸╹┗╸╹ ╹╹╹ ╹╹ ╹┗━╸      ┗━┛┗━╸ ╹ ┗━┛╹  '
  echo -e "${NC}"

  # Download / update the repo
  download_repo

  while true; do
    show_bootstrap_menu
    echo -ne "${BOLD}Choose an option (1-3, q=quit): ${NC}"
    read -r choice

    case "$choice" in
      1)
        echo ""
        info "Sourcing aliases & plugins..."
        echo ""
        echo -e "  ${YELLOW}NOTE:${NC} Sourcing must happen in your current shell."
        echo -e "  Run this command manually:"
        echo ""
        echo -e "    ${GREEN}source \"${INSTALL_DIR}/setup.sh\"${NC}"
        echo ""
        ;;
      2)
        echo ""
        bash "$INSTALL_DIR/install-tools.sh"
        ;;
      3)
        show_integration_instructions
        ;;
      q|Q)
        echo ""
        success "All done! Your terminal setup is at: ${GREEN}${INSTALL_DIR}${NC}"
        echo ""
        show_integration_instructions
        exit 0
        ;;
      *)
        warn "Invalid choice. Enter 1, 2, 3, or q."
        ;;
    esac
  done
}

main "$@"
