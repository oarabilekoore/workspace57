#!/bin/bash

# Check required tools
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: $1 not found. Please install $2." >&2
    exit 1
  fi
}

check_command "brightnessctl" "brightnessctl"
check_command "pactl" "pipewire-pulse or pulseaudio"
check_command "notify-send" "libnotify"

# Function to get brightness percentage
get_brightness() {
  local current=$(brightnessctl get)
  local max=$(brightnessctl max)
  echo $(((current * 100) / max))
}

# Function to get volume percentage
get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1
}

# Function to show progress notification with short lifespan
show_progress() {
  local percent=$1
  local title=$2
  local icon=$3

  # Send notification with 1-second timeout
  notify-send -u normal -i "$icon" -h string:synchronous:"$title" -h int:value:$percent -t 999 "$title" "${percent}%"
}

case "$1" in
"light up")
  # Increase brightness by 10%
  brightnessctl set +10%

  # Show progress notification
  show_progress "$(get_brightness)" "Brightness" "video-brightness-high"
  ;;

"light down")
  # Decrease brightness by 10%
  brightnessctl set 10%-

  # Show progress notification
  show_progress "$(get_brightness)" "Brightness" "video-brightness-high"
  ;;

"volume up")
  # Increase volume by 10%
  pactl set-sink-volume @DEFAULT_SINK@ +10%

  # Show progress notification
  show_progress "$(get_volume)" "Volume" "audio-volume-high"
  ;;

"volume down")
  # Decrease volume by 10%
  pactl set-sink-volume @DEFAULT_SINK@ -10%

  # Show progress notification
  show_progress "$(get_volume)" "Volume" "audio-volume-high"
  ;;

"volume toggle")
  # Toggle mute status
  pactl set-sink-mute @DEFAULT_SINK@ toggle

  # Get the current mute status (more reliable parsing)
  mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

  if [ "$mute_status" = "yes" ]; then
    # Use a fallback icon if audio-volume-muted isn't available
    notify-send "🔇 Audio Muted" -t 990
  else
    show_progress "$(get_volume)" "Volume" "audio-volume-high"
  fi
  ;;

*)
  echo "Usage: $0 {light up|light down|volume up|volume down|volume toggle}" >&2
  exit 1
  ;;
esac
