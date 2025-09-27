#!/usr/bin/env bash

# caffeine.sh - toggle caffeine mode for Hyprland + hyprlock

STATE_FILE="/tmp/caffeine_on"

enable_caffeine() {
  echo "Caffeine enabled: preventing idle + lock"
  notify-send "Caffeine Enabled; Preventing Idle & Lock"
  touch "$STATE_FILE"
  # Kill hypridle (the idle manager) if running
  pkill -STOP hypridle 2>/dev/null
}

disable_caffeine() {
  echo "Caffeine disabled: restoring idle + lock"
  notify-send "Caffeine Disabled"
  rm -f "$STATE_FILE"
  # Resume hypridle
  pkill -CONT hypridle 2>/dev/null
  # Reset idle timers so lock happens properly
  hypridle &
}

toggle_caffeine() {
  if [[ -f "$STATE_FILE" ]]; then
    disable_caffeine
  else
    enable_caffeine
  fi
}

case "$1" in
on) enable_caffeine ;;
off) disable_caffeine ;;
toggle) toggle_caffeine ;;
status)
  if [[ -f "$STATE_FILE" ]]; then
    echo "Caffeine is ON"
  else
    echo "Caffeine is OFF"
  fi
  ;;
*)
  echo "Usage: $0 {on|off|toggle|status}"
  ;;
esac
