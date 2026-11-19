#!/usr/bin/env bash

# Target top/bottom/left/right margins (physical px), per machine
# (laptop = portable chassis type or a battery; same check as hyprland.lua)
case "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" in
    8|9|10|14|30|31|32) laptop=1 ;;
    *) ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && laptop=1 || laptop=0 ;;
esac
if [ "$laptop" = 1 ]; then
    T_1080=200; B_1080=200; L_1080=200; R_1080=200 # laptop
else
    T_1080=300; B_1080=300; L_1080=800; R_1080=800 # desktop ultrawide
fi

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
resolution=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')

# top=$(awk "BEGIN {printf \"%.0f\", $T_1080 * 1080 * $scale / $resolution}") 
# bot=$(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $scale / $resolution}") 
top=$(awk "BEGIN {printf \"%.0f\", $T_1080 / $scale}") 
bot=$(awk "BEGIN {printf \"%.0f\", $B_1080 / $scale}") 
left=$(awk "BEGIN {printf \"%.0f\", $L_1080 / $scale}") 
right=$(awk "BEGIN {printf \"%.0f\", $R_1080 / $scale}") 

# Make sure to refresh colorscheme
# source ~/.dotfiles/scripts/refresh-colors.sh

wlogout -T $top -B $bot -L $left -R $right &
