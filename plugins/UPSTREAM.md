# Plugin provenance

The managed plugin files are snapshots imported in repository commit
`3b1ffc08327f72b485268cc8f898eaa8363e4eea` on 2026-04-03.

| Local path | Upstream project | Upstream path |
|---|---|---|
| `git.plugin.zsh` | `ohmyzsh/ohmyzsh` | `plugins/git/git.plugin.zsh` |
| `aws.plugin.zsh` | `ohmyzsh/ohmyzsh` | `plugins/aws/aws.plugin.zsh` |
| `terraform.plugin.zsh` | `ohmyzsh/ohmyzsh` | `plugins/terraform/terraform.plugin.zsh` |
| `tmux/` | `ohmyzsh/ohmyzsh` | `plugins/tmux/` |
| `zsh-autosuggestions/` | `zsh-users/zsh-autosuggestions` | `zsh-autosuggestions.zsh` |

The exact upstream commit used by the original import was not recorded. Do not
silently imply otherwise. Future refreshes should record the upstream commit in
this file, replace the snapshot without local modifications, run syntax and
clean-shell loading checks, and mention the new commit in the change log.

Compatibility changes belong in `setup.sh`, not in these vendored snapshots.

The tmux snapshot has one local integration fix: generated helper functions
such as `ts` route through the plugin wrapper so a newly created tmux server
always receives terminal-setup's managed configuration.
