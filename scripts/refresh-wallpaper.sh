#!/usr/bin/bash
wp="$1"

if [ -z "$wp" ]; then
    wp=$(grep -oP '^wallpaper = \K.*' ~/.config/waypaper/config.ini)
    wp="${wp/#\~/$HOME}"
fi

if [ -z "$wp" ]; then
    echo "Error: no wallpaper path provided or found" >&2
    exit 1
fi

wal -q -i "$wp"
sed -i "s#^\(\s*path = \).*#\1$wp#" ~/.dotfiles/.config/hypr/hyprlock.conf
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp fill#g" ~/.dotfiles/.config/sway/config
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/swaylock/config

# preload the new image, assign it, THEN unload the old one —
# this way there's no gap where nothing is loaded
hyprctl hyprpaper preload "$wp"
hyprctl hyprpaper wallpaper "DP-1,$wp"
hyprctl hyprpaper unload unused
