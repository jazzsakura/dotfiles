#!/usr/bin/env bash

#pkill -f launcher.sh || kitty --single-instance --app-id=launcher -e bash $HOME/.local/bin/launcher.sh
#pkill -f launcher.sh || ghostty +new-window --title=launcher -e bash $HOME/.local/bin/launcher.sh
#pkill -f launcher.sh || footclient --override="colors-dark.alpha=0.65" --app-id=launcher -e bash $HOME/.local/bin/launcher.sh

if pgrep -x "$(basename "$0")" > /dev/null; then 
  exit 1
else
  ghostty +new-window --title=launcher -e bash $HOME/.local/bin/launcher.sh
  #kitty --single-instance --app-id=launcher zsh -i -c $HOME/.local/bin/launcher.sh
  #footclient --override="colors-dark.alpha=0.65" --app-id=launcher -e bash $HOME/.local/bin/launcher.sh
fi
