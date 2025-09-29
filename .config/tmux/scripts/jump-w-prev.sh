#!/usr/bin/env bash

# Popup Selector
tmux list-windows -F '#D' |\
sed '$d' |\
fzf --tmux 65% --header 'Jump to window: ' --preview 'tmux capture-pane -e -pt {}'  |\
xargs tmux switch-client -t
