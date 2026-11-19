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

## Never touch the live session while testing

Tests run inside a nested Hyprland window, never on the live session. While working:

- Don't start test processes (waybar, wofi, etc.) on the live display. Point them at a
  nested instance's `WAYLAND_DISPLAY` and `HYPRLAND_INSTANCE_SIGNATURE` instead.
- Don't move the cursor, send `hyprctl dispatch`/`keyword`/`eval`, or change
  monitors on the live instance. `hyprctl -i <nested SIG>` only.
- Ask before restarting or reloading anything live (waybar, Hyprland reload,
  hyprpaper, ...), including after a tested change has been written to the repo.
- Read-only queries of the live session (`hyprctl monitors -j`, `grim` screenshots)
  are fine.
- Always close nested instances: start them under `timeout`, and kill them by PID,
  never with `killall`/`pkill` on a name the live session also uses.

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

Copy `config`, `modules.json` and `style.css` to a scratch dir and change the copied
config's `include` to point at the copied `modules.json`. Then run the test bar inside
a nested Hyprland (a minimal config is enough) and screenshot it there:

```sh
cat > <scratch>/nested.lua <<'EOF'
hl.monitor({ output = "", mode = "1600x900@60", position = "auto", scale = 1 })
hl.config({ misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 } })
EOF
timeout 30 Hyprland -c <scratch>/nested.lua >/dev/null 2>&1 & hpid=$!
sleep 4
read SIG SOCK < <(hyprctl instances -j | python3 -I -c "import json,sys; i=next(i for i in json.load(sys.stdin) if i['pid']==$hpid); print(i['instance'], i['wl_socket'])")
WAYLAND_DISPLAY=$SOCK HYPRLAND_INSTANCE_SIGNATURE=$SIG timeout 6 waybar -c <scratch>/config -s <scratch>/style.css >wb.log 2>&1 &
sleep 3
WAYLAND_DISPLAY=$SOCK grim <scratch>/shot.png
sleep 3; kill $hpid
grep -iE '\[(error|warning)\]' wb.log   # "No batteries" is expected on the desktop
```

Both env vars matter: without `HYPRLAND_INSTANCE_SIGNATURE` the workspaces module
talks to the live Hyprland. Tooltips can't be checked this way (a warped cursor
doesn't trigger them), so describe tooltip changes to the user and let them hover.

Once it passes, update the real files, then ask the user before restarting the live
bar (or let them press SUPER+B).

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
