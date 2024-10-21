#!/usr/bin/env bash

# Target top and bottom placements
T_1080=300
B_1080=300
L_1080=800
R_1080=800

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

wlogout -T $top -B $bot -L $left -R $right &
