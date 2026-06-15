# tmux-pane-status

Live status labels in tmux window tabs — see at a glance which panes have a
running coding agent (⟳), which are idle at a shell prompt (⌄), which have an
editor open (✎), and more.

## Quick start

### Via TPM (recommended)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'duyet/tmux-pane-status'
```

Then `<prefix> + I` to install.

### Manual

```bash
git clone https://github.com/duyet/tmux-pane-status ~/.config/tmux-pane-status
```

Add to `~/.tmux.conf`:

```tmux
source-file ~/.config/tmux-pane-status/tmux-pane-status.tmux
```

### Standalone (script only)

Copy `scripts/pane-label.sh` to somewhere in `$PATH` (e.g. `~/.local/bin/tmux-pane-label`)
and add to `~/.tmux.conf`:

```tmux
set -g automatic-rename-format \
  "#{?pane_in_mode,[tmux],#(tmux-pane-label #{pane_id})}#{?pane_dead,[dead],}"
bind R set-window-option automatic-rename on \; display "Dynamic naming ON"
```

## Label reference

| Foreground command | Tab label | Meaning |
|---|---|---|
| `opencode`, `claude`, `codex`, `cursor` | `⟳ name` | Agent actively running |
| `bash`, `sh`, `zsh`, `fish` | `⌄ name` | Idle at shell prompt |
| `nvim`, `vim`, `nano`, `micro` | `✎ name` | Editor open |
| `node`, `npm`, `bun`, `deno` | `⚡ name` | Dev tool running |
| `python`, `python3` | `🐍 python` | Python process |
| `ssh`, `mosh`, `telnet` | `🌐 name` | Remote session |
| `htop`, `top`, `btm` | `📊 name` | System monitor |
| `docker`, `podman` | `🐳 name` | Container tool |
| `sudo`, `doas` | `🔒 name` | Privileged command |
| `make`, `cargo`, `go`, `rustc`, `just` | `🔨 name` | Build tool |
| `less`, `more`, `man` | `📄 name` | Pager |
| `tail`, `watch` | `📋 name` | Log follow |
| `tmux` | `⏎` | Tmux internal |
| anything else | raw command | Fallback |

## Key bindings

| Binding | Action |
|---|---|
| `<prefix> R` | Re-enable dynamic naming on current window |

Windows renamed with `<prefix> + ,` get `automatic-rename` turned off.
`<prefix> R` turns it back on so the label updates again.

## How it works

Tmux's `automatic-rename-format` dynamically sets window names based on the
active pane's foreground command. This plugin provides a classifier script that
maps `#{pane_current_command}` to descriptive icon+label pairs, keeping the
format string clean and the mapping extensible.
