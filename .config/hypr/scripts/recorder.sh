#!/bin/bash

pidfile="$HOME/.cache/wf-recorder.pid"

# Function to get monitor (system audio) source name
get_monitor_source() {
  pactl list short sources | awk '/monitor/ {print $2; exit}'
}

# Stop recording if already active
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
  kill "$(cat "$pidfile")"
  notify-send "🛑 Screen Recording" "Recording stopped."
  rm "$pidfile"
  exit 0
fi

MONITOR_NAME=$(hyprctl monitors -j | jq -r '.[0].name')

# Ask user which recording type to start
choice=$(printf "Record Internal Device Audio\nRecord Internal + External Audio\nRecord Without Audio" |
  rofi -dmenu -p "🎙️ Select Recording Type" \
    -theme "$HOME/Templates/ThemeM0d/Themes/${MONITOR_NAME}/rofi.rasi")

# Exit if user cancels
[ -z "$choice" ] && exit 0

mkdir -p "$HOME/Videos"
filename="Screenrec@$(date +%A@%H:%M).mp4"
output="$HOME/Videos/$filename"

# Decide audio source based on choice
case "$choice" in
"Record Internal Device Audio")
  monitor_source=$(get_monitor_source)
  wf-recorder --audio="$monitor_source" -f "$output" &
  ;;
"Record Internal + External Audio")
  monitor_source=$(get_monitor_source)
  wf-recorder --audio="$(pactl get-default-source)" --audio="$monitor_source" -f "$output" &
  ;;
"Record Without Audio")
  wf-recorder -f "$output" &
  ;;
esac

# Save process ID and notify
echo $! >"$pidfile"
notify-send "🎥 Screen Recording" "Recording started: $filename"
