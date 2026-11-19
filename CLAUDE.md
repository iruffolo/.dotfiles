# Dotfiles

Configs here are **live**: `~/.config/{hypr,waybar,nvim,wofi,wlogout,...}`, `~/.zshrc`,
`~/.zlogin` and `~/.tmux.conf` are symlinks into this repo. Editing a file in the repo
edits the running setup, and Hyprland reloads `hyprland.lua` the moment it is saved.

## Test before changing a live config

Never edit a live config file directly while working on a change. A half-finished or
broken edit takes effect immediately and can break the active session (no binds, no
monitor, no bar). Instead:

1. Copy the file to the scratchpad and make the edits there.
2. Test the copy (see below). Fix and re-test until it passes.
3. Only then write the change into the real file in the repo.

### Hyprland (`.config/hypr/hyprland.lua`)

Use `scripts/hypr-test.sh`. It runs the config in a nested Hyprland window with safety
stubs (no `exec_cmd` runs, no autostart, DP-1 redirected to the nested output), so the
real session is untouched.

```sh
bash scripts/hypr-test.sh -r /path/to/copy.lua      # verify + nested startup + workspace/reload runtime test
bash scripts/hypr-test.sh -r -i /path/to/copy.lua   # same, then install over the live config if it passes
```

The config has a desktop and a laptop profile (see below). Test both when a change
touches anything profile-specific: make a second copy with the chassis path pointed at
a fake file containing `10`, e.g.
`sed 's#"/sys/class/dmi/id/chassis_type"#"<scratch>/fake_chassis"#' copy.lua > laptop.lua`.

### Waybar (`.config/waybar/`)

Copy `config`, `modules.json` and `style.css` to a scratch dir, change the copied
config's `include` to point at the copied `modules.json`, and run a throwaway instance:

```sh
timeout 4 waybar -c <scratch>/config -s <scratch>/style.css 2>&1 | grep -iE '\[(error|warning)\]'
```

Screenshot it with `grim` to check the look. Only after that, update the real files
and restart the live bar (`killall waybar; setsid waybar &`, or SUPER+B).

### Shell scripts (`scripts/`)

At minimum `bash -n script.sh`. Run against a scratch copy when practical.

## Machines

One `main` branch serves both machines; there is no per-machine branch. Both machines
have hostname `iantron`, so never key behavior off the hostname.

- **Desktop:** 5120x1440 ultrawide on DP-1, nvidia, Hyprland scale 1.25 (native 1 on
  workspaces 4-5), centered master layout.
- **Laptop:** eDP-1 at scale 1, dwindle layout, natural touchpad scroll, has a battery.

Detection: a portable DMI `chassis_type` (8, 9, 10, 14, 30, 31, 32) or a `BAT*` in
`/sys/class/power_supply` means laptop (`IS_DESKTOP` in `hyprland.lua`, same check in
`scripts/wlogout-hypr.sh`). Put laptop-only or desktop-only settings behind that check.
The waybar battery module hides itself on the desktop.
