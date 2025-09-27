#!/usr/bin/env bash

# Options with icons
options=" Shutdown
 Reboot
 Lock
 Suspend
 Logout"

# Path to custom Wofi CSS theme
WOFI_THEME="$HOME/.config/wofi/system-menu.css"

# Run wofi with dmenu mode, 25% width, centered
chosen=$(echo -e "$options" | wofi --dmenu \
  --style $WOFI_THEME \
  --width 25 \
  --lines 5 \
  --center)

# Execute selected action
case $chosen in
" Shutdown")
  systemctl poweroff
  ;;
" Reboot")
  systemctl reboot
  ;;
" Lock")
  hyprlock
  ;;
" Suspend")
  systemctl suspend && hyprlock
  ;;
" Logout")
  hyprctl dispatch exit
  ;;
esac
