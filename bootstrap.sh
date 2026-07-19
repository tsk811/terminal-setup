#!/bin/sh
# Rootless terminal setup for Bash and Zsh.
# Recommended:
#   source <(curl -fsSL https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh)

_ts_root=${TERMINAL_SETUP_HOME:-$HOME/.terminal-setup}
_ts_base=${TERMINAL_SETUP_BASE_URL:-https://raw.githubusercontent.com/tsk811/terminal-setup/main}
_ts_aqua_version=v2.62.0
_ts_aqua_installer_version=v4.0.2
_ts_aqua_installer_sha256=98b883756cdd0a6807a8c7623404bfc3bc169275ad9064dc23a6e24ad398f43d

_ts_info() { printf '\033[0;34m[info]\033[0m %s\n' "$*"; }
_ts_ok() { printf '\033[0;32m[ok]\033[0m   %s\n' "$*"; }
_ts_fail() { printf '\033[0;31m[error]\033[0m %s\n' "$*" >&2; return 1; }

_ts_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    return 1
  fi
}

_ts_cleanup() {
  [ -z "${_ts_tmp:-}" ] || [ ! -d "$_ts_tmp" ] || rm -rf "$_ts_tmp"
  unset _ts_tmp _ts_files _ts_file _ts_source _ts_destination _ts_actual _ts_current
}

_ts_download_managed_files() {
  _ts_files='bootstrap.sh
install-tools.sh
shell/init.sh
shell/aliases.sh
shell/fzf.sh
config/aqua.yaml
config/bat.conf
config/tmux.conf
plugins/UPSTREAM.md
plugins/aws.plugin.zsh
plugins/git.plugin.zsh
plugins/terraform.plugin.zsh
plugins/tmux/tmux.extra.conf
plugins/tmux/tmux.only.conf
plugins/tmux/tmux.plugin.zsh
plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

  _ts_tmp=$(mktemp -d 2>/dev/null) || { _ts_fail 'Could not create a temporary directory.'; return 1; }
  _ts_info "Downloading managed files into $_ts_root"

  while IFS= read -r _ts_file; do
    [ -n "$_ts_file" ] || continue
    _ts_destination=$_ts_tmp/$_ts_file
    mkdir -p "$(dirname "$_ts_destination")" || return 1
    curl -fsSL "$_ts_base/$_ts_file" -o "$_ts_destination" || {
      _ts_cleanup
      _ts_fail "Download failed: $_ts_file"
      return 1
    }
  done <<EOF
$_ts_files
EOF

  # Replace files only after every download succeeds. local/ and tools/ are not
  # managed and are never touched by an update.
  while IFS= read -r _ts_file; do
    [ -n "$_ts_file" ] || continue
    mkdir -p "$_ts_root/$(dirname "$_ts_file")" || return 1
    mv "$_ts_tmp/$_ts_file" "$_ts_root/$_ts_file" || return 1
  done <<EOF
$_ts_files
EOF

  mkdir -p "$_ts_root/local" "$_ts_root/tools"
  chmod +x "$_ts_root/bootstrap.sh" "$_ts_root/install-tools.sh"
  _ts_cleanup
  _ts_ok 'Configuration installed.'
}

_ts_install_aqua() {
  export AQUA_ROOT_DIR=$_ts_root/tools
  export AQUA_GLOBAL_CONFIG=$_ts_root/config/aqua.yaml

  if [ -x "$AQUA_ROOT_DIR/bin/aqua" ]; then
    _ts_current=$("$AQUA_ROOT_DIR/bin/aqua" -v 2>/dev/null || true)
    case "$_ts_current" in
      *"${_ts_aqua_version#v}"*)
        _ts_info "Aqua $_ts_aqua_version is already installed."
        return 0
        ;;
      *) _ts_info "Updating Aqua to $_ts_aqua_version" ;;
    esac
  fi

  _ts_tmp=$(mktemp -d 2>/dev/null) || return 1
  _ts_info "Installing Aqua $_ts_aqua_version without root access"
  curl -fsSL "https://raw.githubusercontent.com/aquaproj/aqua-installer/$_ts_aqua_installer_version/aqua-installer" \
    -o "$_ts_tmp/aqua-installer" || return 1
  _ts_actual=$(_ts_sha256 "$_ts_tmp/aqua-installer") || {
    _ts_fail 'sha256sum or shasum is required to verify Aqua.'
    return 1
  }
  [ "$_ts_actual" = "$_ts_aqua_installer_sha256" ] || {
    _ts_fail 'Aqua installer checksum verification failed.'
    return 1
  }
  chmod +x "$_ts_tmp/aqua-installer"
  AQUA_ROOT_DIR=$AQUA_ROOT_DIR "$_ts_tmp/aqua-installer" -v "$_ts_aqua_version" || return 1
  _ts_cleanup
  _ts_ok "Aqua installed under $AQUA_ROOT_DIR"
}

_ts_main() {
  command -v curl >/dev/null 2>&1 || { _ts_fail 'curl is required.'; return 1; }
  command -v mktemp >/dev/null 2>&1 || { _ts_fail 'mktemp is required.'; return 1; }
  _ts_download_managed_files || return 1
  _ts_install_aqua || return 1
  "$_ts_root/install-tools.sh" || return 1

  export TERMINAL_SETUP_HOME=$_ts_root
  # shellcheck disable=SC1090
  . "$_ts_root/shell/init.sh" || return 1
  _ts_ok 'Terminal setup is active in this shell.'
  printf 'Add this to ~/.zshrc or ~/.bashrc if it is not already present:\n\n'
  printf '  [ -r "$HOME/.terminal-setup/shell/init.sh" ] && . "$HOME/.terminal-setup/shell/init.sh"\n\n'
}

_ts_main
_ts_status=$?
_ts_cleanup
unset -f _ts_main _ts_install_aqua _ts_download_managed_files _ts_sha256 \
  _ts_cleanup _ts_info _ts_ok _ts_fail 2>/dev/null
unset _ts_root _ts_base _ts_aqua_version _ts_aqua_installer_version \
  _ts_aqua_installer_sha256
return "$_ts_status" 2>/dev/null || exit "$_ts_status"
