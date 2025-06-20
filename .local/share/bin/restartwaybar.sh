#!/usr/bin/env sh

# read control file and initialize variables

export scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
waybar_dir="${confDir}/waybar"
modules_dir="$waybar_dir/modules"
conf_file="$waybar_dir/config.jsonc"
conf_ctl="$waybar_dir/config.ctl"

readarray -t read_ctl < $conf_ctl
num_files="${#read_ctl[@]}"
switch=0

# restart waybar

if [ "$reload_flag" == "1" ] ; then
    killall waybar
    waybar --config ${waybar_dir}/config.jsonc --style ${waybar_dir}/style.css > /dev/null 2>&1 &
fi

