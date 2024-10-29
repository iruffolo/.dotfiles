
# Configurations 
- nvim
- zsh
- tmux
- waybar
- wofi
- wlogout
- waypaper

# Dependencies 
- [Pywal](https://github.com/dylanaraps/pywal)

### Hyprland
- hyprpaper
- hypridle
- hyprlock
- hyprshot

# TODO

- [ ] Swaync notification config 
- [ ] mpd with waybar 

# Progress
- [x] Hyprland
- [x] Hyprlock
- [X] Wofi
- [x] Waybar
- [x] Wlogout
- [x] Waypaper

# Install 
## Manual with Symlinks
E.g
~~~
ln -s ~/.dotfiles/.config/nvim ~/.config/nvim
~~~

## Recommended Install 
Using GNU Stow:
1. Clone repo directly into home directory e.g ~/.dotfiles
2. Run Stow:
~~~
cd ~/.dotfiles
stow .
~~~

## Uninstall
To remove links managed by stow:
~~~
cd ~/.dotfiles
stow -D .
~~~


