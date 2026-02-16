#!/usr/bin/env bash

session="$(tmux list-sessions | grep -i attached | cut -d ":" -f1)"

# Popup Selector
tmux list-windows -F '#{?#{window_active},,#{window_name}}' |\
sed '/^$/d' |\
fzf --tmux 70% --header 'Jump to window: ' --preview 'tmux capture-pane -e -pt {}' --preview-window=70% |\
xargs -I{} tmux switch-client -t$session:{}
