#!/usr/bin/env bash

# Popup Selector
tmux list-sessions -F '#{?session_attached,,#{session_name}}' |\
sed '/^$/d' |\
fzf --tmux 65% --header 'Jump to session: ' --preview 'tmux capture-pane -e -pt {}'  |\
xargs tmux switch-client -t
