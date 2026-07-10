#!/usr/bin/bash

wp="$1"

if [ -z "$wp" ]; then
    echo "Error: no wallpaper path provided" >&2
    exit 1
fi

wal -q -i "$wp"

sed -i "s#^\(\s*path = \).*#\1$wp#" ~/.dotfiles/.config/hypr/hyprlock.conf
sed -i "s#^\(\s*wallpaper = \).*#\1$wp#" ~/.dotfiles/.config/hypr/hyprpaper.conf
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp fill#g" ~/.dotfiles/.config/sway/config
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/swaylock/config

source ~/.dotfiles/scripts/waybar-startup.sh
