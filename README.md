# Terminal Setup

A rootless, self-contained shell environment for macOS and Linux. Everything is
kept under one directory in the user's home folder:

```text
~/.terminal-setup/
├── bootstrap.sh
├── install-tools.sh
├── shell/
│   ├── init.sh
│   ├── aliases.sh
│   ├── prompt.sh
│   └── fzf.sh
├── config/
│   ├── aqua.yaml
│   ├── bat.conf
│   └── tmux.conf
├── plugins/
├── local/                 # private, machine-specific overrides
└── tools/                 # Aqua and all managed executables
```

The setup never uses `sudo`, a system package manager, `/usr/local`, `/opt`,
`~/.config`, or `~/.local`. A writable home directory and `curl` are the only
initial requirements.

## Install or update

Source the bootstrap from Bash or Zsh:

```sh
source <(curl -fsSL "https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh?$(date +%s)")
```

The bootstrap:

1. Downloads managed shell files directly into `~/.terminal-setup`.
2. Preserves `~/.terminal-setup/local` and `~/.terminal-setup/tools`.
3. Installs a pinned Aqua binary through Aqua's checksum-verified installer.
4. Uses Aqua to install the declared command-line tools.
5. Sources the environment into the current shell.

No repository clone or Git installation is required. Running the same command
again updates the managed configuration without deleting tools or local files.

To use a different private root, set it before bootstrapping and before shell
startup:

```sh
export TERMINAL_SETUP_HOME="$HOME/.my-terminal"
source <(curl -fsSL "https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh?$(date +%s)")
```

## Automatic shell startup

Add one line to `~/.zshrc` or `~/.bashrc`:

```sh
[ -r "$HOME/.terminal-setup/shell/init.sh" ] && . "$HOME/.terminal-setup/shell/init.sh"
```

Shell startup is entirely local and performs no network access. `init.sh` sets:

```sh
TERMINAL_SETUP_HOME="$HOME/.terminal-setup"
AQUA_ROOT_DIR="$TERMINAL_SETUP_HOME/tools"
AQUA_GLOBAL_CONFIG="$TERMINAL_SETUP_HOME/config/aqua.yaml"
PATH="$AQUA_ROOT_DIR/bin:$PATH"
```

## Tools

[Aqua](https://aquaproj.github.io/) manages the tools declaratively from
`config/aqua.yaml`:

- fzf
- bat
- dust
- ripgrep (`rg`)
- fd
- jq
- yq
- tmux

Install or repair the declared tools at any time:

```sh
~/.terminal-setup/install-tools.sh
```

Aqua handles operating-system and CPU differences, downloads release assets,
and applies the verification supported by its pinned standard registry. Its
binary, registry data, packages, and command proxies all remain under
`~/.terminal-setup/tools`.

Some upstream projects do not publish native binaries for every platform. Aqua
uses supported compatibility mechanisms such as Rosetta 2 where its registry
allows them and reports unsupported combinations rather than requesting root.

## Aliases

Managed aliases are in `shell/aliases.sh`:

| Alias | Action |
|---|---|
| `dev` | Go to `~/Documents/DEV` |
| `doc` | Go to `~/Documents` |
| `pro` | Go to `~/Documents/DEV/projects` |
| `dwn` | Go to `~/Downloads` |
| `b` | Go up one directory |
| `x` | Clear the terminal |
| `l` | Forced-colour listing: hidden entries, directories, then files; each group alphabetical |
| `rl` | Reload Zsh's `.zprofile` and `.zshrc`, or Bash's login profile and `.bashrc` |

## Zsh plugins

Git aliases, tmux integration, and Zsh autosuggestions are enabled by default.
The tmux plugin uses the managed `config/tmux.conf` and does not automatically
start a tmux session. Configure the plugin list in
`~/.terminal-setup/local/init.sh`:

```sh
TERMINAL_SETUP_PLUGINS="git aws terraform tmux autosuggestions"
```

AWS, Terraform, and tmux plugins load only when their corresponding command is
available. Bash receives aliases, Aqua tools, bat configuration, and fzf shell
integration, but not Zsh plugins.

## Tmux shortcuts

Tmux uses `Ctrl-a` as its prefix. Press the prefix, release it, and then press:

| Shortcut | Action |
|---|---|
| `\|` / `-` | Split left/right or top/bottom in the current directory |
| Arrow keys or `h` / `j` / `k` / `l` | Move between panes |
| `H` / `J` / `K` / `L` | Resize the current pane; hold the final key to repeat |
| `c` | Create a window in the current directory |
| `n` / `p` | Select the next/previous window |
| `x` | Kill the current pane immediately |
| `X` | Kill the current session immediately |
| `d` | Detach from the session |
| `r` | Reload the managed tmux configuration |

Mouse support is enabled for selecting panes, dragging pane borders to resize,
and scrolling through tmux history. To select text using the terminal itself,
hold its mouse-bypass modifier while dragging (commonly `Shift`; some macOS
terminal configurations use `Option`), then use the normal copy shortcut.

## Local customisation

The bootstrap never overwrites `local/`. Use:

```text
~/.terminal-setup/local/init.sh       environment and plugin selection
~/.terminal-setup/local/aliases.sh    additional or replacement aliases
~/.terminal-setup/local/plugins/*.zsh additional Zsh plugins
```

Local aliases load after managed aliases, so they can override defaults.

## Prompt

Interactive Bash and Zsh sessions show the user, host, current directory name,
and current Git branch (or short commit when detached) on a single line. The Git
segment appears only inside a repository. To keep a machine's existing prompt, add this to
`~/.terminal-setup/local/init.sh`:

```sh
TERMINAL_SETUP_PROMPT=0
```

## Uninstall

Remove the startup line from `~/.zshrc` or `~/.bashrc`, then remove the single
private directory:

```sh
rm -rf "$HOME/.terminal-setup"
```

No files elsewhere are created by terminal-setup itself.

## Source repository

The repository is only the source for the remotely managed files. For local
development, `setup.sh` remains as a compatibility entry point that loads the
repository through the same `shell/init.sh` path.

## Licence

The project is Apache-2.0. Vendored plugins retain their upstream licences; see
`plugins/UPSTREAM.md`.
