#!/usr/bin/env bash

# Popup Selector
#tmux list-sessions -F '#{?session_attached,,#{session_name}}' |\
tmux list-sessions -F '#{?session_attached,,#{session_name}}' -f '#{?#{m:_popup_*,#{session_name}},0,1}' |\
sed '/^$/d' |\
fzf --tmux 70% --header 'Jump to session: ' --preview 'tmux capture-pane -e -pt {}' --preview-window=75%  |\
xargs -I{} tmux switch-client -t{}
