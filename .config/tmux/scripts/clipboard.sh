#!/bin/bash

cliphist list | fzf --popup 85% \
  --prompt=" Search clipboard: " \
  --reverse \
  --preview 'echo {} | cliphist decode 2>/dev/null' \
  --preview-window=right:40%:wrap \
  --header ' Enter: copy | Ctrl+D: delete | Ctrl+A: clear all | Esc: quit' \
  --bind 'ctrl-d:execute(echo {} | cliphist delete)+reload(cliphist list)' \
  --bind 'ctrl-a:execute(cliphist wipe)+reload(cliphist list)' \
  | cliphist decode | wl-copy
