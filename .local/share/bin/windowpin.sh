#!/usr/bin/env sh

# enable float
WinFloat=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .floating')
WinPinned=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .pinned')

if [ "${WinFloat}" == "false" ] && [ "${WinPinned}" == "false" ] ; then
    hyprctl dispatch togglefloating active
    hyprctl dispatch resizeactive exact 1280 720
    hyprctl dispatch centerwindow
fi

# toggle pin
hyprctl dispatch pin active

# disable float
WinFloat=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .floating')
WinPinned=$(hyprctl -j clients | jq '.[] | select(.focusHistoryID == 0) | .pinned')

if [ "${WinFloat}" == "true" ] && [ "${WinPinned}" == "false" ] ; then
    hyprctl dispatch togglefloating active
fi

