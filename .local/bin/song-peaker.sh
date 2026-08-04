#!/usr/bin/env bash
set -e

wallDir="${HOME}/Music"
export homeDir="${PWD}"

cd "$wallDir"
IMG=$(ag -f -i --hidden --ignore '.gitignore' --ignore-dir '.*git*' -g '' $wallDir 2>/dev/null | sed "s@^$wallDir@@" | sed 's/^\///' | sed '/^$/d' |
sed -nE '/.*\.(mp3|gif|bmp|mp4)$/Ip' |
fzf --preview 'ffprobe -v error -show_entries format_tags -of default=noprint_wrappers=1:nokey=0 {}' --preview-window 'noinfo' --reverse --header-first --inline-info --info='hidden')
rmpc add "$IMG"
notify-send "Song added..." "$(basename "$IMG")" -i "$IMG"
