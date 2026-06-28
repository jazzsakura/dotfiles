#!/usr/bin/env bash
set -e

export wallSet="${HOME}/.config/niri/wall.jpg"
export homeDir="${PWD}"

IMG=$(rg --color never -L -u --hidden --no-config --files --glob '!.*git*' --glob '!.npm*' | sed -nE '/.*\.(jpg|jpeg|png|gif|bmp)$/Ip' | fzf --preview '~/.local/bin/fzf-preview.sh {}')
awww img "$IMG" --transition-type any --transition-fps 165 --transition-duration=1.6 --transition-bezier 0.33,1.0,0.68,1.0
notify-send "Wallpaper changed" "$IMG" -i "$homeDir/$IMG"
ln -fs "${homeDir}/${IMG}" "${wallSet}"
