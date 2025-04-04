#!/bin/sh

dbus-update-activation-environment --systemd \
	WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP

# pkill -f swayidle
swayidle -w &

# pkill -f swaylock
# swaylock -f
