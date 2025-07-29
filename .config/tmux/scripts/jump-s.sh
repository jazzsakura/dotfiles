#!/usr/bin/env bash

tmux switch-client -t$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | sed '/^$/d' | cut -d ":" -f1 | fzf --tmux 50% --header 'Jump to session: ')
#tmux switch-client -t$(tmux list-sessions | cut -d ":" -f1 | fzf --tmux 50% --header 'Jump to session: ')
