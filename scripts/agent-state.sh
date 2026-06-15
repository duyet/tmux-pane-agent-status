#!/bin/bash
# agent-state.sh — Lightweight agent state detection for tmux status bar.
#
# Scans all panes for running coding agents and reports their state:
#   ⟳ name  – agent is actively running / working
#   ⌨ name  – agent is waiting for user input (heuristic)
#
# Called from status-right via #() expansion every status-interval.
# Fast: ~2ms per pane (list-panes + capture-pane of 3 lines).

set -euo pipefail

output=""

while read -r pane_id cmd; do
  [ -z "$cmd" ] && continue

  name=""

  # ── Direct binary agents (process name matches) ──
  case "$cmd" in
    opencode|claude|codex|cursor|"cursor-agent")           name="$cmd"  ;;
    agy|grok|agent|cr|coderabbit)                          name="$cmd"  ;;
  esac

  # ── Python-based agents (need deeper inspection) ──
  if [ -z "$name" ] && { [ "$cmd" = "python" ] || [ "$cmd" = "python3" ]; }; then
    pid=$(tmux display -t "$pane_id" -p '#{pane_pid}' 2>/dev/null || true)
    if [ -n "$pid" ]; then
      full_cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
      case "$full_cmd" in
        *hermes*)      name="hermes"      ;;
        *SuperClaude*) name="SuperClaude" ;;
      esac
    fi
  fi

  [ -z "$name" ] && continue

  # Default: actively working
  icon="⟳"

  # ── Heuristic: waiting for input? Capture last 3 lines of pane output ──
  last=$(tmux capture-pane -t "$pane_id" -p -S -3 2>/dev/null || true)
  case "$last" in
    # Common confirmation prompts
    *'[y/N]'*|*'[Y/n]'*|*'[Y/N]'*|*'[y/n]'*)           icon="⌨" ;;
    *'Continue?'*|*'Proceed?'*|*' (Y/n):'*|*' (y/N):'*) icon="⌨" ;;
    *'Press Enter'*|*'Press any key'*)                   icon="⌨" ;;
    # Line ending with ? — likely a question if short
    *\?)
      lastnl=$(echo "$last" | grep -v '^$' | tail -1)
      [ "${#lastnl}" -lt 120 ] && icon="⌨"
      ;;
  esac

  output="$output ${icon}${name}"

done < <(tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null || true)

echo "$output" | sed 's/^ //'
