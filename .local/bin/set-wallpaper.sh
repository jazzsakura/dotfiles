#!/usr/bin/env bash
set -e

export wallSet="${HOME}/.config/niri/wall.jpg"
export homeDir="${PWD}"

#IMG=$(find -L "${homeDir}" -type f | fzf --preview '~/.local/bin/fzf-preview.sh {}')
IMG=$(rg --color never -L -u --hidden --no-config --files --glob '!.*git*' --glob '!.npm*' | sed -nE '/.*\.(jpg|jpeg|png|gif|bmp)$/Ip' | fzf --preview '~/.local/bin/fzf-preview.sh {}')
swww img "$IMG" --transition-type any --transition-step 5 --transition-fps 165 --transition-duration=2
ln -fs "${homeDir}/${IMG}" "${wallSet}"
