#!/usr/bin/env sh

# enable float
WinFloat=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .floating')
WinPinned=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .pinned')

if [ "${WinFloat}" == "false" ] && [ "${WinPinned}" == "false" ]; then
  hyprctl dispatch togglefloating active
  hyprctl dispatch resizeactive exact 1450 860
  hyprctl dispatch centerwindow
else
  # disable float
  WinFloat=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .floating')
  WinPinned=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .pinned')
  if [ "${WinFloat}" == "true" ] && [ "${WinPinned}" == "false" ]; then
    hyprctl dispatch togglefloating active
  fi
fi
