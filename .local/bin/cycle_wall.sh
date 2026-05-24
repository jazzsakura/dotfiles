#!/bin/bash

# full path to that random image file
IMG_PATH=$(find -L "$HOME/Pictures" -type f | shuf -n 1)
# Command to change wallpaper
awww img $IMG_PATH --transition-type any --transition-fps 144 --transition-step 5
