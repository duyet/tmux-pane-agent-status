#!/bin/bash
# pane-label.sh — Classify a tmux pane's foreground command into a status label.
#
# Called from tmux automatic-rename-format via #() expansion.
# Maps pane_current_command to icons for at-a-glance awareness:
#   ⟳ agent   = coding agent actively running (opencode, claude, codex, cursor)
#   ⌄ shell   = idle at shell prompt (bash, zsh, fish)
#   ✎ editor  = editor open (nvim, vim, nano)
#   ⚡ dev     = dev tool running (node, npm, bun, python, cargo, make, go)
#   🌐 remote  = ssh session
#   📊 monitor = system monitoring (htop, top, btm)
#   🔒 sudo    = privileged command
#   🐳 docker  = container tool
#   📄 pager   = less, more, man
#   📋 log     = tail, watch
#   otherwise  = raw command name as fallback
#
# Usage (from tmux):
#   set -g automatic-rename-format \
#     "#{?pane_in_mode,[tmux],#(/path/to/pane-label.sh #{pane_id})}#{?pane_dead,[dead],}"

set -euo pipefail

pane_id="${1:?}"
cmd=$(tmux display -t "$pane_id" -p '#{pane_current_command}' 2>/dev/null || true)
pid=$(tmux display -t "$pane_id" -p '#{pane_pid}' 2>/dev/null || true)

# Guard: pane gone or command unreadable
[ -z "$cmd" ] && { echo "?"; exit 0; }

case "${cmd}" in
  # AI coding agents — binary-based, process name matches
  opencode|claude|codex|cursor|"cursor-agent"|agy|grok|agent|cr|coderabbit)
    echo "⟳ ${cmd}"
    ;;

  # Python-based agents — process shows as python/python3
  python|python3)
    name=""
    if [ -n "$pid" ]; then
      full_cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
      case "$full_cmd" in
        *hermes*)      name="hermes"      ;;
        *SuperClaude*) name="SuperClaude" ;;
      esac
    fi
    if [ -n "$name" ]; then
      echo "⟳ $name"
    else
      echo "🐍 python"
    fi
    ;;

  # Shells — idle, waiting at prompt
  bash|sh)           echo "⌄ bash"      ;;
  zsh)               echo "⌄ zsh"       ;;
  fish)              echo "⌄ fish"      ;;

  # Editors
  nvim|vim)          echo "✎ ${cmd}"    ;;
  nano|micro)        echo "✎ ${cmd}"    ;;

  # Dev tooling running
  node|npm|npx)      echo "⚡ ${cmd}"    ;;
  bun|deno)          echo "⚡ ${cmd}"    ;;
  make|cargo|go|rustc|just) echo "🔨 ${cmd}" ;;

  # Remote sessions
  ssh|mosh|telnet)   echo "🌐 ${cmd}"    ;;

  # System monitoring / paging
  htop|top|btm|bpytop|bashtop) echo "📊 ${cmd}" ;;
  less|more|man)     echo "📄 ${cmd}"    ;;

  # Privilege escalation
  sudo|doas)         echo "🔒 ${cmd}"    ;;

  # Containers
  docker|docker-compose|podman) echo "🐳 ${cmd}" ;;

  # Tmux itself (status line processes etc.)
  tmux)              echo "⏎"            ;;

  # Logs / tailing
  tail|tailf|watch)  echo "📋 ${cmd}"    ;;

  # Generic fallback — show raw command name
  *)                 echo "${cmd}"       ;;
esac
