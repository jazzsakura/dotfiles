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
awww img "$IMG" --transition-type any --transition-step 2 --transition-fps 165 --transition-duration=1.6 --transition-bezier 0.33,1.0,0.68,1.0
#awww img "$IMG" --transition-type any --transition-step 5 --transition-fps 165 --transition-duration=2
notify-send "Wallpaper changed"  "$(basename "$IMG")" -i "$IMG"
ln -fs "${IMG}" "${wallSet}"
