#!/usr/bin/env bash

# Quit any running instances of waybar
killall waybar
waybar &

# if [[ $USER = "ian" ]]
# then
#     waybar -s ~/.dotfiles/.config/waybar/style.css &
# else
#     waybar &
# fi
