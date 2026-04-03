# 🚀 Terminal Setup

> ⚠️ **Work in Progress** — This repository is actively being developed. Features and structure may change.

A portable, modular terminal setup for **macOS** and **Linux**. Quickly configure shell aliases, zsh plugins, and CLI tools from a single repository — no root or git required.

## Quick Start

```bash
# One-liner — curl and run (no git needed):
bash <(curl -fsSL https://raw.githubusercontent.com/tsk811/terminal-setup/main/bootstrap.sh)
```

This will:
1. Download the entire repo into `./terminal-setup` (current directory)
2. Present an interactive menu to **source aliases/plugins** or **install CLI tools**
3. Everything stays self-contained inside that folder

## Architecture

```
terminal-setup/
├── bootstrap.sh                # One-liner entry point (curl this)
├── setup.sh                    # Sources aliases & plugins into current shell
├── install-tools.sh            # Interactive CLI tool installer
├── aliases/
│   └── aliases.sh              # Shell aliases
├── config/
│   ├── bat.conf                # bat configuration
│   └── fzf.sh                  # fzf/bat integration config
├── plugins/
│   ├── git.plugin.zsh          # Oh My Zsh git plugin
│   ├── aws.plugin.zsh          # Oh My Zsh AWS plugin
│   ├── terraform.plugin.zsh    # Oh My Zsh terraform plugin
│   ├── tmux/                   # Oh My Zsh tmux plugin
│   │   ├── tmux.plugin.zsh
│   │   ├── tmux.extra.conf
│   │   └── tmux.only.conf
│   └── zsh-autosuggestions/
│       └── zsh-autosuggestions.zsh
└── bin/                        # ← Created at runtime (gitignored)
    ├── fzf                     #   Downloaded tool binaries live here
    ├── bat
    ├── dust
    ├── rg
    └── fd
```

## How It Works

### bootstrap.sh (entry point)
- Downloads the repo as a **tarball via curl** — no git required
- Extracts to `./terminal-setup` in the current directory
- Presents a menu: source plugins, install tools, or view shell integration instructions
- On re-run, updates the repo while **preserving installed tools** in `bin/`

### setup.sh (source this)
- Loads all aliases and zsh plugins into the current shell
- Adds `<repo>/bin` to `$PATH` so installed tools are available
- Loads fzf/bat configuration

### install-tools.sh (run this)
- Interactive menu to select which tools to install
- Downloads prebuilt binaries from GitHub Releases
- Installs into `<repo>/bin/` — **no root**, everything stays in one place

## Design Principles

| Principle | Detail |
|---|---|
| **Self-contained** | Everything (scripts, plugins, tools) lives in one folder |
| **No root** | All tools install to `<repo>/bin/` — no `sudo` needed |
| **No git required** | Bootstrap uses `curl` to download a tarball |
| **Modular** | Aliases, plugins, and tools are independent; add or remove freely |
| **Interactive tools** | Tool installer is opt-in and interactive; nothing auto-installs |
| **Auto-load plugins** | Plugins load automatically when you source `setup.sh` |
| **Cross-platform** | Works on macOS (arm64/amd64) and Linux (x86_64/aarch64) |

## Shell Integration

After bootstrapping, add this line to your `~/.zshrc` or `~/.zprofile`:

```bash
source "/path/to/terminal-setup/setup.sh"
```

## Aliases

| Alias | Command |
|---|---|
| `dev` | `cd ~/Documents/DEV` |
| `doc` | `cd ~/Documents` |
| `pro` | `cd ~/Documents/DEV/projects` |
| `dwn` | `cd ~/Downloads` |
| `x` | `clear` |
| `b` | `cd ..` |
| `ls` | `ls -lah --color=always` (auto-detects macOS) |
| `rl` | `source ~/.zprofile` |

## Plugins

- **git** — 200+ git aliases and helpers (from Oh My Zsh)
- **aws** — AWS profile/region switching and prompt (from Oh My Zsh)
- **terraform** — Terraform aliases and prompt helpers (from Oh My Zsh)
- **tmux** — tmux session management and aliases (from Oh My Zsh)
- **zsh-autosuggestions** — Fish-like autosuggestions for zsh

## Tools

The interactive installer supports:

| Tool | Description |
|---|---|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [bat](https://github.com/sharkdp/bat) | A `cat` clone with wings |
| [dust](https://github.com/bootandy/dust) | A more intuitive `du` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Ultra-fast `grep` |
| [fd](https://github.com/sharkdp/fd) | A simple, fast `find` |

## License

See [LICENSE](LICENSE) for details.
