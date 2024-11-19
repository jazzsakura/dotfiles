#!/bin/sh

image_path="/tmp/currently-playing.jpg"
test -d "$HOME/.cache/ncmpcpp/images/" || mkdir -p "$HOME/.cache/ncmpcpp/images/"

song_path=$(playerctl metadata xesam:url | sed -nE "s@file://(/home/.*)@\1@p")
ffmpegthumbnailer -i "$song_path" -o "$image_path" -s0 2>/dev/null
magick "$image_path" "$image_path" 2>/dev/null || notify-send "ffmpegthumbnailer failed"
title=$(playerctl metadata xesam:url | sed -nE "s@.*/(.*)\.(mp3|flac|opus|mkv|m4a)@\1@p")
# check if a file with the same name already exists
test -f "$HOME/.cache/ncmpcpp/images/""$title.jpg" || cp "$image_path" "$HOME/.cache/ncmpcpp/images/""$title.jpg"
notify-send "Now Playing" "$title" -i "$image_path" -h string:x-dunst-stack-tag:vol
