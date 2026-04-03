#!/bin/sh
# ============================================================================
# Terminal Setup — Bootstrap
# ============================================================================
# One-liner to download the repo and get started. No git required.
# Compatible with sh, bash, and zsh.
#
# Usage:
#   sh <(curl -fsSL https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh)
#
# What it does:
#   1. Downloads the repo as a tarball (via curl) into the current directory
#   2. Presents a menu: source aliases/plugins OR install tools
#
# Supported platforms: macOS, Linux
# ============================================================================

set -eu

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
info()    { printf "${BLUE}[info]${NC}    %s\n" "$*"; }
success() { printf "${GREEN}[✔]${NC}       %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${NC}    %s\n" "$*"; }
error()   { printf "${RED}[✘]${NC}       %s\n" "$*" >&2; }

# ============================================================================
# Step 1: Download the repo
# ============================================================================
download_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    warn "Directory already exists: $INSTALL_DIR"
    printf "${BOLD}  Update to latest? (y/N): ${NC}"
    read response
    case "$response" in
      y|Y|yes|YES)
        info "Removing old copy..."
        # Preserve the bin/ directory (installed tools) during update
        if [ -d "$INSTALL_DIR/bin" ]; then
          mv "$INSTALL_DIR/bin" "/tmp/_terminal_setup_bin_backup_$$"
        fi
        rm -rf "$INSTALL_DIR"
        ;;
      *)
        info "Using existing installation."
        return 0
        ;;
    esac
  fi

  info "Downloading ${REPO_NAME} from GitHub..."
  tmp_tar=$(mktemp)

  if ! curl -fsSL "$TARBALL_URL" -o "$tmp_tar"; then
    error "Failed to download repo. Check your internet connection."
    rm -f "$tmp_tar"
    exit 1
  fi

  info "Extracting to $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tmp_tar" --strip-components=1 -C "$INSTALL_DIR"
  rm -f "$tmp_tar"

  # Restore preserved bin/ directory if it existed
  if [ -d "/tmp/_terminal_setup_bin_backup_$$" ]; then
    mv "/tmp/_terminal_setup_bin_backup_$$" "$INSTALL_DIR/bin"
    info "Restored previously installed tools."
  fi

  chmod +x "$INSTALL_DIR/setup.sh" "$INSTALL_DIR/install-tools.sh" "$INSTALL_DIR/bootstrap.sh"
  success "Repository downloaded to $INSTALL_DIR"
}

# ============================================================================
# Step 2: Interactive menu
# ============================================================================
show_bootstrap_menu() {
  printf "\n"
  printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}\n"
  printf "${BOLD}${CYAN}║         🚀 Terminal Setup — Bootstrap                   ║${NC}\n"
  printf "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  Location: ${GREEN}%s${NC}\n" "$INSTALL_DIR"
  printf "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}\n"
  printf "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[1]${NC} Source aliases & plugins                            ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}      ${DIM}Loads aliases, git/aws/terraform/tmux plugins,${NC}     ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}      ${DIM}and zsh-autosuggestions into current shell.${NC}         ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[2]${NC} Install CLI tools (interactive)                     ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}      ${DIM}fzf, bat, dust, ripgrep, fd — choose which${NC}         ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}      ${DIM}to install. Installs into the repo folder.${NC}         ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[3]${NC} Show shell integration instructions                ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}      ${DIM}How to add this to your ~/.zshrc for auto-load.${NC}    ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[q]${NC} Quit                                               ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}                                                          ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}\n"
  printf "\n"
}

show_integration_instructions() {
  printf "\n"
  printf "${BOLD}${CYAN}── Shell Integration ────────────────────────────────────${NC}\n"
  printf "\n"
  printf "  Add this line to your ${BOLD}~/.zshrc${NC} or ${BOLD}~/.bashrc${NC}:\n"
  printf "\n"
  printf "    ${GREEN}. \"%s/setup.sh\"${NC}\n" "$INSTALL_DIR"
  printf "\n"
  printf "  Then reload your shell:\n"
  printf "\n"
  printf "    ${GREEN}source ~/.zshrc${NC}  or  ${GREEN}source ~/.bashrc${NC}\n"
  printf "\n"
  printf "${BOLD}${CYAN}─────────────────────────────────────────────────────────${NC}\n"
  printf "\n"
}

# ============================================================================
# Main
# ============================================================================
main() {
  printf "${BOLD}${CYAN}"
  printf '  ╺┳╸┏━╸┏━┓┏┳┓╻┏┓╻┏━┓╻        ┏━┓┏━╸╺┳╸╻ ╻┏━┓\n'
  printf '   ┃ ┣╸ ┣┳┛┃┃┃┃┃┗┫┣━┫┃   ╺━╸  ┗━┓┣╸  ┃ ┃ ┃┣━┛\n'
  printf '   ╹ ┗━╸╹┗╸╹ ╹╹╹ ╹╹ ╹┗━╸      ┗━┛┗━╸ ╹ ┗━┛╹  \n'
  printf "${NC}\n"

  # Download / update the repo
  download_repo

  while true; do
    show_bootstrap_menu
    printf "${BOLD}Choose an option (1-3, q=quit): ${NC}"
    read choice

    case "$choice" in
      1)
        printf "\n"
        info "Sourcing aliases & plugins..."
        printf "\n"
        printf "  ${YELLOW}NOTE:${NC} Sourcing must happen in your current shell.\n"
        printf "  Run this command manually:\n"
        printf "\n"
        printf "    ${GREEN}. \"%s/setup.sh\"${NC}\n" "$INSTALL_DIR"
        printf "\n"
        ;;
      2)
        printf "\n"
        sh "$INSTALL_DIR/install-tools.sh"
        ;;
      3)
        show_integration_instructions
        ;;
      q|Q)
        printf "\n"
        success "All done! Your terminal setup is at: ${GREEN}${INSTALL_DIR}${NC}"
        printf "\n"
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
