#!/usr/bin/env bash

# 1. Fetch all panes across all sessions with clean formatting
# Format: [session] [window] [pane_index] [current_command] [path]
target=$(tmux list-panes -s -F '#{session_name}:#{window_index}.#{pane_index} | #{window_name} -> Pane #{pane_index} [#{pane_current_command}] (#{pane_current_path})' | \
    fzf --popup 80%,70% \
        --border-label=" Switch Tmux Pane " \
        --header="Enter: Switch to selected pane" \
        --preview="tmux capture-pane -e -pt {1}")

# 2. Extract the target identifier and switch to it if a choice was made
if [ -n "$target" ]; then
    pane_id=$(echo "$target" | cut -d' ' -f1)
    tmux switch-client -t "$pane_id"
fi
