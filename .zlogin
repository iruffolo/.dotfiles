if [ "$(tty)" = "/dev/tty1" ];then
  # exec Hyprland
  exec qtile start -b wayland 
fi
