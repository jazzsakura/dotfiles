#!/bin/bash

# Get random image file name
IMG_NAME=$(ls $HOME/Pictures/walls | shuf -n 1)
# full path to that random image file
IMG_PATH=$(find -L "$HOME/Pictures" -type f | shuf -n 1)
# Command to change wallpaper
swww img $IMG_PATH --transition-type random --transition-fps 144 --transition-step 5
