#!/usr/bin/env bash

# Target top and bottom placements
T_1080=500
B_1080=500
L_1080=1200
R_1080=1200

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
width=`swaymsg -t get_outputs | jq -r '.[] | .current_mode | .width'`
height=`swaymsg -t get_outputs | jq -r '.[] | .current_mode | .height'`

scale=$((width/height))

# top=$(awk "BEGIN {printf \"%.0f\", $T_1080 * 1080 * $scale / $resolution}") 
# bot=$(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $scale / $resolution}") 
top=$((T_1080 / scale))
bot=$((B_1080 / scale))
left=$((L_1080 / scale))
right=$((R_1080 / scale))

wlogout -T $top -B $bot -L $left -R $right &
