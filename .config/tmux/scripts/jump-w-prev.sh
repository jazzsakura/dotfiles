#!/usr/bin/env bash

session="$(tmux list-sessions | grep -i attached | cut -d ":" -f1)"

# Popup Selector
#tmux list-windows -F '#D' |\
tmux list-windows -F '#W' |\
sed '$d' |\
fzf --tmux 65% --header 'Jump to window: ' --preview 'tmux capture-pane -e -pt {}' |\
xargs -I{} tmux switch-client -t$session:{}
