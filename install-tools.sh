#!/bin/sh
# ============================================================================
# Terminal Setup — Interactive Tool Installer
# ============================================================================
# Installs CLI tools into the repo's own bin/ directory (no root required).
# Everything stays self-contained within the terminal-setup folder.
# Compatible with sh, bash, and zsh.
#
# Usage:
#   sh install-tools.sh          (from within the repo)
#   Called automatically by bootstrap.sh
#
# Supported platforms: macOS (arm64/amd64), Linux (x86_64/aarch64)
# ============================================================================

set -eu

# -- Configuration -----------------------------------------------------------
# Resolve the repo root (script lives at <repo>/install-tools.sh)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/bin"
TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# -- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# -- Helpers -----------------------------------------------------------------
info()    { printf "${BLUE}[info]${NC}    %s\n" "$*"; }
success() { printf "${GREEN}[✔]${NC}       %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${NC}    %s\n" "$*"; }
error()   { printf "${RED}[✘]${NC}       %s\n" "$*"; }

detect_platform() {
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux"  ;;
    *)      error "Unsupported OS: $os"; exit 1 ;;
  esac

  case "$arch" in
    x86_64)        ARCH="amd64"; ARCH_ALT="x86_64" ;;
    aarch64|arm64) ARCH="arm64"; ARCH_ALT="aarch64" ;;
    *)             error "Unsupported architecture: $arch"; exit 1 ;;
  esac

  # For tools that use different naming conventions
  if [ "$OS" = "darwin" ]; then
    PLATFORM_APPLE="apple-darwin"
    PLATFORM_GNU=""
  else
    PLATFORM_APPLE=""
    PLATFORM_GNU="unknown-linux-gnu"
  fi
}

ensure_install_dir() {
  if [ ! -d "$INSTALL_DIR" ]; then
    info "Creating install directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
  fi
}

is_installed() {
  cmd="$1"
  [ -x "$INSTALL_DIR/$cmd" ] || command -v "$cmd" >/dev/null 2>&1
}

get_latest_release() {
  repo="$1"
  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'
}

# -- Tool Installers ---------------------------------------------------------

install_fzf() {
  info "Installing fzf..."
  version=$(get_latest_release "junegunn/fzf")
  version="${version#v}"

  if [ "$OS" = "darwin" ]; then
    filename="fzf-${version}-${OS}_${ARCH}.zip"
  else
    filename="fzf-${version}-${OS}_${ARCH}.tar.gz"
  fi

  url="https://github.com/junegunn/fzf/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  case "$filename" in
    *.zip)
      unzip -qo "$TMP_DIR/$filename" -d "$TMP_DIR/fzf"
      ;;
    *)
      mkdir -p "$TMP_DIR/fzf"
      tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR/fzf"
      ;;
  esac

  cp "$TMP_DIR/fzf/fzf" "$INSTALL_DIR/fzf"
  chmod +x "$INSTALL_DIR/fzf"
  success "fzf ${version} installed to $INSTALL_DIR/fzf"
}

install_bat() {
  info "Installing bat..."
  version=$(get_latest_release "sharkdp/bat")
  version="${version#v}"

  if [ "$OS" = "darwin" ]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  filename="bat-v${version}-${target}.tar.gz"
  url="https://github.com/sharkdp/bat/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/bat-v${version}-${target}/bat" "$INSTALL_DIR/bat"
  chmod +x "$INSTALL_DIR/bat"
  success "bat ${version} installed to $INSTALL_DIR/bat"
}

install_dust() {
  info "Installing dust..."
  version=$(get_latest_release "bootandy/dust")
  version="${version#v}"

  if [ "$OS" = "darwin" ]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  filename="dust-v${version}-${target}.tar.gz"
  url="https://github.com/bootandy/dust/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/dust-v${version}-${target}/dust" "$INSTALL_DIR/dust"
  chmod +x "$INSTALL_DIR/dust"
  success "dust ${version} installed to $INSTALL_DIR/dust"
}

install_ripgrep() {
  info "Installing ripgrep..."
  version=$(get_latest_release "BurntSushi/ripgrep")
  version="${version#v}"

  if [ "$OS" = "darwin" ]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  filename="ripgrep-${version}-${target}.tar.gz"
  url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/ripgrep-${version}-${target}/rg" "$INSTALL_DIR/rg"
  chmod +x "$INSTALL_DIR/rg"
  success "ripgrep ${version} installed to $INSTALL_DIR/rg"
}

install_fd() {
  info "Installing fd..."
  version=$(get_latest_release "sharkdp/fd")
  version="${version#v}"

  if [ "$OS" = "darwin" ]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  filename="fd-v${version}-${target}.tar.gz"
  url="https://github.com/sharkdp/fd/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/fd-v${version}-${target}/fd" "$INSTALL_DIR/fd"
  chmod +x "$INSTALL_DIR/fd"
  success "fd ${version} installed to $INSTALL_DIR/fd"
}

# -- Status helpers ----------------------------------------------------------

tool_status() {
  # $1 = binary name
  if is_installed "$1"; then
    printf "${GREEN}✔ installed${NC}"
  else
    printf "${YELLOW}○ not installed${NC}"
  fi
}

# -- Interactive Menu --------------------------------------------------------

show_menu() {
  printf "\n"
  printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}\n"
  printf "${BOLD}${CYAN}║         🚀 Terminal Setup — Tool Installer              ║${NC}\n"
  printf "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  Install directory: ${GREEN}%s${NC}\n" "$INSTALL_DIR"
  printf "${BOLD}${CYAN}║${NC}  Platform: ${GREEN}%s/%s${NC}\n" "$OS" "$ARCH"
  printf "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}\n"

  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[1]${NC} %-12s %-22s %b  ${BOLD}${CYAN}║${NC}\n" "fzf" "Fuzzy finder" "$(tool_status fzf)"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[2]${NC} %-12s %-22s %b  ${BOLD}${CYAN}║${NC}\n" "bat" "A cat clone with wings" "$(tool_status bat)"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[3]${NC} %-12s %-22s %b  ${BOLD}${CYAN}║${NC}\n" "dust" "A more intuitive du" "$(tool_status dust)"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[4]${NC} %-12s %-22s %b  ${BOLD}${CYAN}║${NC}\n" "ripgrep" "Ultra-fast grep" "$(tool_status rg)"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[5]${NC} %-12s %-22s %b  ${BOLD}${CYAN}║${NC}\n" "fd" "A simple, fast find" "$(tool_status fd)"

  printf "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[a]${NC} Install all tools                                  ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}║${NC}  ${BOLD}[q]${NC} Quit                                               ${BOLD}${CYAN}║${NC}\n"
  printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}\n"
  printf "\n"
}

confirm_reinstall() {
  # $1 = tool name, $2 = binary name
  if is_installed "$2"; then
    warn "$1 is already installed. Reinstall? (y/N)"
    read response
    case "$response" in
      y|Y) return 0 ;;
      *)   info "Skipping $1"; return 1 ;;
    esac
  fi
  return 0
}

install_tool_by_key() {
  case "$1" in
    1) confirm_reinstall "fzf"     "fzf"  && install_fzf     ;;
    2) confirm_reinstall "bat"     "bat"  && install_bat     ;;
    3) confirm_reinstall "dust"    "dust" && install_dust    ;;
    4) confirm_reinstall "ripgrep" "rg"   && install_ripgrep ;;
    5) confirm_reinstall "fd"      "fd"   && install_fd      ;;
    *) warn "Invalid selection: $1" ;;
  esac
}

install_all() {
  if ! is_installed "fzf";  then install_fzf;     else info "fzf already installed, skipping.";     fi
  if ! is_installed "bat";  then install_bat;     else info "bat already installed, skipping.";     fi
  if ! is_installed "dust"; then install_dust;    else info "dust already installed, skipping.";    fi
  if ! is_installed "rg";   then install_ripgrep; else info "ripgrep already installed, skipping."; fi
  if ! is_installed "fd";   then install_fd;      else info "fd already installed, skipping.";      fi
}

# -- Main --------------------------------------------------------------------

main() {
  printf "${BOLD}${CYAN}"
  printf '  ╺┳╸┏━╸┏━┓┏┳┓╻┏┓╻┏━┓╻        ┏━┓┏━╸╺┳╸╻ ╻┏━┓\n'
  printf '   ┃ ┣╸ ┣┳┛┃┃┃┃┃┗┫┣━┫┃   ╺━╸  ┗━┓┣╸  ┃ ┃ ┃┣━┛\n'
  printf '   ╹ ┗━╸╹┗╸╹ ╹╹╹ ╹╹ ╹┗━╸      ┗━┛┗━╸ ╹ ┗━┛╹  \n'
  printf "${NC}\n"

  detect_platform
  ensure_install_dir

  while true; do
    show_menu
    printf "${BOLD}Select tools to install (1-5, a=all, q=quit): ${NC}"
    read choice

    case "$choice" in
      1|2|3|4|5)
        install_tool_by_key "$choice"
        ;;
      a|A)
        install_all
        ;;
      q|Q)
        printf "\n"
        info "Done. Tools installed to: ${GREEN}${INSTALL_DIR}${NC}"
        info "PATH is automatically managed by ${GREEN}setup.sh${NC} when sourced."
        printf "\n"
        exit 0
        ;;
      *)
        warn "Invalid choice. Please enter 1-5, 'a', or 'q'."
        ;;
    esac
  done
}

main "$@"
