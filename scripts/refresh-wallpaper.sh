#/usr/bin/bash

# Get current wallpaper
wp="$(hyprctl hyprpaper listloaded)"

# Refresh pywal colors
wal -q -i $wp

# Reload apps using pywal colorschemes
source ~/.dotfiles/scripts/waybar-startup.sh

# Replace background in hyprpaper and hyprlock with new image
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/hypr/hyprpaper.conf
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/hypr/hyprlock.conf
