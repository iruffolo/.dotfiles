-- Hyprland Lua config (Hyprland >= 0.57)
-- Wiki: https://wiki.hypr.land/configuring/
-- API stubs: /usr/share/hypr/stubs/hl.meta.lua

------------------
---- MONITORS ----
------------------

local MONITOR = "DP-1"
local MODE = "5120x1440@240"
local SCALE_DESKTOP = 1.25
local SCALE_NATIVE = 1

hl.monitor({ output = MONITOR, mode = MODE, position = "auto", scale = SCALE_DESKTOP })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "nautilus"
local browser = "firefox"
local menu = "bash ~/.dotfiles/scripts/wofi-startup.sh mocha"
local waybar = "bash ~/.dotfiles/scripts/waybar-startup.sh"
local refreshwp = "bash ~/.dotfiles/scripts/refresh-wallpaper.sh"
local logout = "bash ~/.dotfiles/scripts/wlogout-hypr.sh"
local lock = "hyprlock"

local kill_waybar = "killall -SIGUSR1 waybar" -- toggles waybar visibility

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle & waybar & swaync & hyprpaper")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd(lock)
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	cursor = {
		no_warps = false,
		no_hardware_cursors = true,
	},
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},
	decoration = {
		rounding = 10,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "slave",
		new_on_top = false,
		allow_small_split = true,
		orientation = "center",
		slave_count_for_center_master = 0,
		special_scale_factor = 0.80,
		mfact = 0.45,
	},
	misc = {
		force_default_wallpaper = 0,
		on_focus_under_fullscreen = 1,
		disable_hyprland_logo = true,
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		numlock_by_default = true,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		touchpad = {
			natural_scroll = false,
		},
	},
	debug = {
		disable_logs = false,
		enable_stdout_logs = true,
	},
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-----------------------------------
---- PER-WORKSPACE SCALE + BAR ----
-----------------------------------

-- Each workspace's monitor scale and whether waybar is shown.
-- Workspaces not listed here (6+, special) leave things as they are.
local workspaces = {
	[1] = { scale = SCALE_DESKTOP, bar = true },
	[2] = { scale = SCALE_DESKTOP, bar = true },
	[3] = { scale = SCALE_DESKTOP, bar = true },
	[4] = { scale = SCALE_NATIVE, bar = false }, -- gaming: native res, no bar
	[5] = { scale = SCALE_NATIVE, bar = true }, -- native res
}

-- Set the monitor scale. Returns true if it actually changed.
local function set_scale(scale)
	local mon = hl.get_monitor(MONITOR)
	if mon and math.abs(mon.scale - scale) < 0.01 then
		return false
	end
	hl.monitor({ output = MONITOR, mode = MODE, position = "auto", scale = scale })
	return true
end

-- Apply a workspace's profile.
local function apply_workspace(id)
	local p = workspaces[id]
	if not p then
		return
	end
	local changed = set_scale(p.scale)
	if not p.bar then
		hl.exec_cmd("killall -q waybar")
	elseif changed then
		hl.exec_cmd(waybar) -- restart: waybar renders at the wrong size after a scale change
	else
		hl.exec_cmd("pidof waybar >/dev/null || " .. waybar) -- start only if missing
	end
end

-- Runs every time the active workspace changes; ws is the new workspace.
hl.on("workspace.active", function(ws)
	apply_workspace(ws.id)
end)

-- Saving this file reloads it, which re-runs hl.monitor() at the top with the
-- desktop scale. Re-apply the current workspace's profile afterwards.
hl.on("config.reloaded", function()
	local ws = hl.get_active_workspace()
	if ws then
		apply_workspace(ws.id)
	end
end)

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + M", hl.dsp.layout("swapwithmaster master"))

hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind(mainMod .. " + CTRL + l", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + ALT + l", hl.dsp.exec_cmd(logout))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(waybar))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(kill_waybar))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(refreshwp))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

-- Workspaces 1-5: plain switch / move binds. Scale + waybar are handled by
-- the workspace.active hook above, so they apply however you get there
-- (keybind, mouse scroll, a window rule, hyprctl, ...).
for ws = 1, 5 do
	hl.bind(mainMod .. " + " .. ws, hl.dsp.focus({ workspace = ws }))
	hl.bind(mainMod .. " + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Manual scale override
hl.bind(mainMod .. " + 6", function()
	set_scale(SCALE_DESKTOP)
	hl.exec_cmd(refreshwp)
end)
hl.bind(mainMod .. " + 7", function()
	set_scale(SCALE_NATIVE)
	hl.exec_cmd(refreshwp)
end)

hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), media)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), media)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), media)

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({ name = "kitty-opacity", match = { class = "kitty" }, opacity = "0.9 0.9" })
hl.window_rule({ name = "float-pavucontrol", match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ name = "float-blueman", match = { class = "blueman-manager" }, float = true })

hl.window_rule({ name = "slack-ws5", match = { class = "Slack" }, workspace = "5 silent" })
hl.window_rule({ name = "signal-ws5", match = { class = "signal" }, workspace = "5 silent" })
hl.window_rule({ name = "steam-ws4", match = { class = "steam" }, workspace = "4 silent" })

-- Ignore maximize requests from apps
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Blur behind wlogout
hl.layer_rule({ name = "blur-wlogout", match = { namespace = "logout_dialog" }, blur = true })
