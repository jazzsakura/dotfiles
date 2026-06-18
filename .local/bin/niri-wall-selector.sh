#!/usr/bin/env bash
set -e

wallDir="${HOME}/Pictures/wallhaven"
export wallSet="${HOME}/.config/niri/wall.jpg"
export homeDir="${PWD}"

IMG=$(rg --color never -L -u --hidden --no-config --files --glob '!.*git*' --glob '!.npm*' $wallDir |
shuf |
sed -nE '/.*\.(jpg|jpeg|png|gif|bmp|mp4)$/Ip' |
fzf --bind 'j:down,k:up' --preview 'kitty icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no {}' --preview-window 'up,99%,border-none,noinfo' --reverse --header-first --inline-info --prompt='' --no-sort --no-input --info='hidden')
pgrep -f mpvpaper && pkill mpvpaper
awww img "$IMG" --transition-type any --transition-step 5 --transition-fps 165 --transition-duration=2
ln -fs "${IMG}" "${wallSet}"
