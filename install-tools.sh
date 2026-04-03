#!/usr/bin/env bash
# ============================================================================
# Terminal Setup — Interactive Tool Installer
# ============================================================================
# Installs CLI tools into the repo's own bin/ directory (no root required).
# Everything stays self-contained within the terminal-setup folder.
#
# Usage:
#   bash install-tools.sh          (from within the repo)
#   Called automatically by bootstrap.sh
#
# Supported platforms: macOS (arm64/amd64), Linux (x86_64/aarch64)
# ============================================================================

set -euo pipefail

# -- Configuration -----------------------------------------------------------
# Resolve the repo root (script lives at <repo>/install-tools.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/bin"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# -- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# -- Helpers -----------------------------------------------------------------
info()    { echo -e "${BLUE}[info]${NC}    $*"; }
success() { echo -e "${GREEN}[✔]${NC}       $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}    $*"; }
error()   { echo -e "${RED}[✘]${NC}       $*"; }

detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux"  ;;
    *)      error "Unsupported OS: $os"; exit 1 ;;
  esac

  case "$arch" in
    x86_64)       ARCH="amd64"; ARCH_ALT="x86_64" ;;
    aarch64|arm64) ARCH="arm64"; ARCH_ALT="aarch64" ;;
    *)            error "Unsupported architecture: $arch"; exit 1 ;;
  esac

  # For tools that use different naming conventions
  if [[ "$OS" == "darwin" ]]; then
    PLATFORM_APPLE="apple-darwin"
    PLATFORM_GNU=""
  else
    PLATFORM_APPLE=""
    PLATFORM_GNU="unknown-linux-gnu"
    if [[ "$ARCH" == "arm64" ]]; then
      PLATFORM_GNU="unknown-linux-gnu"
    fi
  fi
}

ensure_install_dir() {
  if [[ ! -d "$INSTALL_DIR" ]]; then
    info "Creating install directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
  fi
}

is_installed() {
  local cmd="$1"
  # Check in INSTALL_DIR first, then PATH
  [[ -x "$INSTALL_DIR/$cmd" ]] || command -v "$cmd" &>/dev/null
}

get_latest_release() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/'
}

# -- Tool Installers ---------------------------------------------------------

install_fzf() {
  info "Installing fzf..."
  local version
  version=$(get_latest_release "junegunn/fzf")
  version="${version#v}"  # strip leading 'v'

  local filename
  if [[ "$OS" == "darwin" ]]; then
    filename="fzf-${version}-${OS}_${ARCH}.zip"
  else
    filename="fzf-${version}-${OS}_${ARCH}.tar.gz"
  fi

  local url="https://github.com/junegunn/fzf/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  if [[ "$filename" == *.zip ]]; then
    unzip -qo "$TMP_DIR/$filename" -d "$TMP_DIR/fzf"
  else
    mkdir -p "$TMP_DIR/fzf"
    tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR/fzf"
  fi

  cp "$TMP_DIR/fzf/fzf" "$INSTALL_DIR/fzf"
  chmod +x "$INSTALL_DIR/fzf"
  success "fzf ${version} installed to $INSTALL_DIR/fzf"
}

install_bat() {
  info "Installing bat..."
  local version
  version=$(get_latest_release "sharkdp/bat")
  version="${version#v}"

  local target
  if [[ "$OS" == "darwin" ]]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  local filename="bat-v${version}-${target}.tar.gz"
  local url="https://github.com/sharkdp/bat/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/bat-v${version}-${target}/bat" "$INSTALL_DIR/bat"
  chmod +x "$INSTALL_DIR/bat"
  success "bat ${version} installed to $INSTALL_DIR/bat"
}

install_dust() {
  info "Installing dust..."
  local version
  version=$(get_latest_release "bootandy/dust")
  version="${version#v}"

  local target
  if [[ "$OS" == "darwin" ]]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  local filename="dust-v${version}-${target}.tar.gz"
  local url="https://github.com/bootandy/dust/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/dust-v${version}-${target}/dust" "$INSTALL_DIR/dust"
  chmod +x "$INSTALL_DIR/dust"
  success "dust ${version} installed to $INSTALL_DIR/dust"
}

install_ripgrep() {
  info "Installing ripgrep..."
  local version
  version=$(get_latest_release "BurntSushi/ripgrep")
  version="${version#v}"

  local target
  if [[ "$OS" == "darwin" ]]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  local filename="ripgrep-${version}-${target}.tar.gz"
  local url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/ripgrep-${version}-${target}/rg" "$INSTALL_DIR/rg"
  chmod +x "$INSTALL_DIR/rg"
  success "ripgrep ${version} installed to $INSTALL_DIR/rg"
}

install_fd() {
  info "Installing fd..."
  local version
  version=$(get_latest_release "sharkdp/fd")
  version="${version#v}"

  local target
  if [[ "$OS" == "darwin" ]]; then
    target="${ARCH_ALT}-${PLATFORM_APPLE}"
  else
    target="${ARCH_ALT}-${PLATFORM_GNU}"
  fi

  local filename="fd-v${version}-${target}.tar.gz"
  local url="https://github.com/sharkdp/fd/releases/download/v${version}/${filename}"
  info "Downloading $url"
  curl -fsSL "$url" -o "$TMP_DIR/$filename"

  tar -xzf "$TMP_DIR/$filename" -C "$TMP_DIR"
  cp "$TMP_DIR/fd-v${version}-${target}/fd" "$INSTALL_DIR/fd"
  chmod +x "$INSTALL_DIR/fd"
  success "fd ${version} installed to $INSTALL_DIR/fd"
}

# -- Interactive Menu --------------------------------------------------------

declare -A TOOLS
TOOLS=(
  [1]="fzf|Fuzzy finder|install_fzf|fzf"
  [2]="bat|A cat clone with wings|install_bat|bat"
  [3]="dust|A more intuitive du|install_dust|dust"
  [4]="ripgrep|Ultra-fast grep|install_ripgrep|rg"
  [5]="fd|A simple, fast find|install_fd|fd"
)

show_menu() {
  echo ""
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║         🚀 Terminal Setup — Tool Installer              ║${NC}"
  echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}${CYAN}║  Install directory: ${GREEN}${INSTALL_DIR}${NC}"
  echo -e "${BOLD}${CYAN}║  Platform: ${GREEN}${OS}/${ARCH}${CYAN}$(printf '%*s' $((31 - ${#OS} - ${#ARCH})) '')║${NC}"
  echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"

  for key in $(echo "${!TOOLS[@]}" | tr ' ' '\n' | sort -n); do
    IFS='|' read -r name desc func cmd <<< "${TOOLS[$key]}"
    local status
    if is_installed "$cmd"; then
      status="${GREEN}✔ installed${NC}"
    else
      status="${YELLOW}○ not installed${NC}"
    fi
    printf "${BOLD}${CYAN}║${NC}  ${BOLD}[%s]${NC} %-12s %-22s %s  ${BOLD}${CYAN}║${NC}\n" "$key" "$name" "$desc" "$status"
  done

  echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[a]${NC} Install all tools                                  ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}[q]${NC} Quit                                               ${BOLD}${CYAN}║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

install_tool_by_key() {
  local key="$1"
  if [[ -z "${TOOLS[$key]+_}" ]]; then
    warn "Invalid selection: $key"
    return 1
  fi

  IFS='|' read -r name desc func cmd <<< "${TOOLS[$key]}"

  if is_installed "$cmd"; then
    warn "$name is already installed. Reinstall? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      info "Skipping $name"
      return 0
    fi
  fi

  $func
}

install_all() {
  for key in $(echo "${!TOOLS[@]}" | tr ' ' '\n' | sort -n); do
    IFS='|' read -r name desc func cmd <<< "${TOOLS[$key]}"
    if is_installed "$cmd"; then
      info "$name is already installed, skipping."
    else
      $func
    fi
  done
}

# -- Main --------------------------------------------------------------------

main() {
  echo -e "${BOLD}${CYAN}"
  echo '  ╺┳╸┏━╸┏━┓┏┳┓╻┏┓╻┏━┓╻        ┏━┓┏━╸╺┳╸╻ ╻┏━┓'
  echo '   ┃ ┣╸ ┣┳┛┃┃┃┃┃┗┫┣━┫┃   ╺━╸  ┗━┓┣╸  ┃ ┃ ┃┣━┛'
  echo '   ╹ ┗━╸╹┗╸╹ ╹╹╹ ╹╹ ╹┗━╸      ┗━┛┗━╸ ╹ ┗━┛╹  '
  echo -e "${NC}"

  detect_platform
  ensure_install_dir

  while true; do
    show_menu
    echo -ne "${BOLD}Select tools to install (1-5, a=all, q=quit): ${NC}"
    read -r choice

    case "$choice" in
      [1-5])
        install_tool_by_key "$choice"
        ;;
      a|A)
        install_all
        ;;
      q|Q)
        echo ""
        info "Done. Tools installed to: ${GREEN}${INSTALL_DIR}${NC}"
        info "PATH is automatically managed by ${GREEN}setup.sh${NC} when sourced."
        echo ""
        exit 0
        ;;
      *)
        warn "Invalid choice. Please enter 1-5, 'a', or 'q'."
        ;;
    esac
  done
}

main "$@"
