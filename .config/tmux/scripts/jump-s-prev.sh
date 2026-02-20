#!/usr/bin/env bash

# Popup Selector
tmux list-sessions -F '#{?session_attached,,#{session_name}}' |\
sed '/^$/d' |\
fzf --tmux 70% --header 'Jump to session: ' --preview 'tmux capture-pane -e -pt {}' --preview-window=75%  |\
xargs -I{} tmux switch-client -t{}
