#!/usr/bin/env bash

# Quit any running instances of waybar
killall waybar

if [[ $USER = "ian" ]]
then
    waybar -s ~/dev/config/waybar/style.css &
else
    waybar &
fi
