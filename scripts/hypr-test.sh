#!/usr/bin/env bash
# Test a Hyprland Lua config in a nested Hyprland window before installing it.
#
# Usage: hypr-test.sh [-r] [-i] <config.lua>
#   (default)  verify-config + start nested Hyprland, check it survives startup
#   -r         also run the runtime test: switch workspaces 4/5/1/2 and reload,
#              printing the monitor scale and the commands the hooks would run
#   -i         install: if all tests pass, copy <config.lua> over ~/.config/hypr/hyprland.lua
#
# Safety: nothing is ever executed by the config under test. hl.exec_cmd is
# replaced with a print, autostart is skipped, and DP-1 is redirected to the
# nested window's output, so your real session, waybar, etc. are untouched.
set -u

RUNTIME=0 INSTALL=0
while getopts "ri" opt; do
	case $opt in
	r) RUNTIME=1 ;;
	i) INSTALL=1 ;;
	*) sed -n '2,13p' "$0"; exit 2 ;;
	esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] && [ -f "$1" ] || { sed -n '2,13p' "$0"; exit 2; }

CONFIG="$(realpath "$1")"
LIVE="$HOME/.config/hypr/hyprland.lua"
TMP="$(mktemp -d)"
pid=""
# Always close the nested instance and clean up, even on Ctrl+C or a closed pipe.
cleanup() {
	[ -n "$pid" ] && kill "$pid" 2>/dev/null && wait "$pid" 2>/dev/null
	rm -rf "$TMP"
}
trap cleanup EXIT
trap 'exit 130' INT TERM PIPE
FAILED=0

# Harness: wraps the config under test with the safety stubs above.
cat >"$TMP/harness.lua" <<EOF
hl.config({ debug = { disable_logs = false, enable_stdout_logs = true } })
local real_on, real_monitor, real_get_monitor = hl.on, hl.monitor, hl.get_monitor
hl.exec_cmd = function(cmd) print("[test] exec: " .. cmd) end
hl.on = function(ev, fn)
	if ev == "hyprland.start" then return end
	return real_on(ev, fn)
end
local function nested() local m = hl.get_monitors()[1]; return m and m.name or "" end
hl.get_monitor = function(sel)
	if sel == "DP-1" then return real_get_monitor(nested()) end
	return real_get_monitor(sel)
end
hl.monitor = function(spec)
	if spec.output == "DP-1" then
		print("[test] set scale -> " .. tostring(spec.scale))
		-- 1280x720 so that 1.25 divides evenly and scale changes are visible
		spec = { output = nested(), mode = "1280x720@60", position = "auto", scale = spec.scale }
	end
	return real_monitor(spec)
end
dofile("$CONFIG")
EOF

echo "== verify-config"
result=$(Hyprland --verify-config -c "$TMP/harness.lua" 2>&1 | sed -n '/Config parsing result/,$p' | tail -n +2 | sed '/^$/d')
echo "$result" | sed 's/^/   /'
[ "$result" = "config ok" ] || exit 1

echo "== nested startup"
LOG="$TMP/nested.log"
Hyprland -c "$TMP/harness.lua" >"$LOG" 2>&1 &
pid=$!
sleep 6
if ! kill -0 $pid 2>/dev/null; then
	echo "   DIED during startup:"
	tail -20 "$LOG" | sed 's/^/   /'
	ls -t ~/.cache/hyprland/hyprlandCrashReport*.txt 2>/dev/null | head -1 | sed 's/^/   crash report: /'
	exit 1
fi
echo "   alive after 6s"

SIG=$(hyprctl instances -j | python3 -I -c "import json,sys; print(next((i['instance'] for i in json.load(sys.stdin) if i['pid']==$pid), ''))")
if [ -z "$SIG" ] || [ "$SIG" = "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
	echo "   could not identify the nested instance; refusing to send it commands"
	kill $pid; exit 1
fi
H() { hyprctl -i "$SIG" "$@"; }
state() {
	printf 'ws=%s scale=%s' \
		"$(H activeworkspace -j | python3 -I -c "import json,sys; print(json.load(sys.stdin)['id'])")" \
		"$(H monitors -j | python3 -I -c "import json,sys; print(json.load(sys.stdin)[0]['scale'])")"
}
# Print what the hooks ran since the given log line count.
ran_since() { grep -oE "\[test\].*" "$LOG" | tail -n +$(($1 + 1)) | sed 's/\[test\] //' | paste -sd ';'; }

if [ $RUNTIME -eq 1 ]; then
	echo "== runtime"
	for ws in 4 5 1 2 4; do
		n=$(grep -c "\[test\]" "$LOG")
		H eval "hl.dispatch(hl.dsp.focus({ workspace = $ws }))" >/dev/null
		sleep 1
		printf '   %-12s %-18s | %s\n' "focus $ws" "$(state)" "$(ran_since "$n")"
	done
	n=$(grep -c "\[test\]" "$LOG")
	H reload >/dev/null
	sleep 1
	printf '   %-12s %-18s | %s\n' "reload" "$(state)" "$(ran_since "$n")"
fi

if kill -0 $pid 2>/dev/null; then
	echo "== PASS: nested instance still running"
else
	echo "== FAIL: nested instance died"; FAILED=1
fi
errs=$(grep -E "\bERR\b" "$LOG" | grep -viE "socket2|seatd|libseat|aquamarine|DRM|Invalid scale")
[ -n "$errs" ] && { echo "== errors in log:"; echo "$errs" | cut -c1-200 | sed 's/^/   /'; }
kill $pid 2>/dev/null; wait $pid 2>/dev/null

if [ $INSTALL -eq 1 ]; then
	if [ $FAILED -eq 0 ]; then
		cp "$CONFIG" "$LIVE" && echo "== installed to $LIVE (Hyprland will reload)"
	else
		echo "== not installing: tests failed"
	fi
fi
exit $FAILED
