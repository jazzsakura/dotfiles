#!/usr/bin/env bash

set -u

rand=$(tr -dc '0-9!#$%&~' </dev/urandom | head -c 3; echo)
session=$(tmux list-sessions | grep -i attached | cut -d ":" -f1)
tmux neww -n $session$rand -c "#{pane_current_path}"
