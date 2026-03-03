#!/usr/bin/env bash

set -u

output(){
    printf "\e[1;34m%-6s\e[m\n" "${@}"
}

window_prompt() {
  output 'Change the current window name (press ENTER to skip): '
    read -r windowname
}

clear
window_prompt
clear

if [[ -z $windowname ]]; then
    exit 0
fi

rand=$(tr -dc '0-9!#$%&~' </dev/urandom | head -c 3; echo)
session=$(tmux list-sessions | grep -i attached | cut -d ":" -f1)

if [ -n "$TMUX" ]; then
  tmux renamew "$windowname"
fi
