#!/bin/bash
# 自启动脚本 仅作参考

set +e

# ensure xdg-desktop-portal running without last dirty state
systemctl --user restart xdg-desktop-portal &

# some env can't auto run the portal, so need this
/usr/lib/xdg-desktop-portal-wlr  >/dev/null 2>&1 &

# xwayland dpi scale
#echo "Xft.dpi: 140" | xrdb -merge #dpi缩放

# keep clipboard content
#wl-clip-persist --clipboard regular --reconnect-tries 0 >/dev/null 2>&1 &

# clipboard content manager
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &

# bluetooth 
blueman-applet >/dev/null 2>&1 &

# network
#nm-applet >/dev/null 2>&1 &

# Start on boot
awww-daemon
#exec-once = sleep 1 && bash $HOME/.config/Scripts/random_wall_on_home.sh
foot --server 2>&1 &
awww img ~/.config/niri/wall.jpg --transition-type any --transition-step 5 --transition-fps 165 --transition-duration 2
mpd
mpDris2
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
kitty -1 --session <(echo 'launch --allow-remote-control --hold kitten @ resize-os-window --action=hide')
# exec-once = sleep 3 && paplay /usr/share/sounds/freedesktop/stereo/message.oga|notify-send --icon ~/.config/Resources/images/PFP.jpg "Welcome back" $USER
# exec-once = waybar -c $HOME/.config/waybar/MangoWC/config.jsonc -s $HOME/.config/waybar/style.css
# exec-once = swayidle -w timeout 300 'systemctl suspend' before-sleep 'hyprlock'
