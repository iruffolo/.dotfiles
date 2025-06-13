# Start sway  on TTY1
# if [ "$(tty)" = "/dev/tty1" ];then
#   exec sway --unsupported-gpu
# fi

# Start hyprland on TTY1
if [ "$(tty)" = "/dev/tty1" ];then
  exec Hyprland
fi
