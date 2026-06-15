# tmux-pane-status.tmux — Tmux plugin for dynamic pane status labels.
#
# Sourced by tmux (source-file). Uses $HOME in #() because the
# shell expands it at runtime.
#
# Install via TPM:
#   set -g @plugin 'duyet/tmux-pane-status'
#
# Or manually from ~/.tmux.conf:
#   source-file ~/.config/tmux-pane-status/tmux-pane-status.tmux

# Dynamic window naming — labels panes by their foreground command
set -g automatic-rename-format \
  "#{?pane_in_mode,[tmux],#($HOME/.config/tmux-pane-status/scripts/pane-label.sh #{pane_id})}#{?pane_dead,[dead],}"

# ⌃b + Shift+R — re-enable dynamic naming on a manually-renamed window
bind R set-window-option automatic-rename on \; display "Dynamic naming ON"
