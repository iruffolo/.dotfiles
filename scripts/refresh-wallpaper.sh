#/usr/bin/bash

# Get current wallpaper
# wp="$(hyprctl hyprpaper listloaded)"
#
# path='/home/ian/Pictures/backgrounds/'
# fn="$(ps aux | grep swaybg | awk -F$path '{print $2}' | awk '{print $1}' | xargs)"
# wp=${path}${fn}

# Can pass wallpaper path as arg from waypaper post_command
wp=$1

# Refresh pywal colors
wal -q -i $wp


# Replace background in hyprpaper and hyprlock with new image (or sway)
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp fill#g" ~/.dotfiles/.config/sway/config
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/swaylock/config

sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/hypr/hyprlock.conf
sed -i "s#/home/ian/Pictures/backgrounds/.*#$wp#g" ~/.dotfiles/.config/hypr/hyprpaper.conf

# Reloads sway config, waybar etc.
# swaymsg reload
#
# Reload apps using pywal colorschemes
source ~/.dotfiles/scripts/waybar-startup.sh
