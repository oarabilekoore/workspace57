#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
HYPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# --- 1. Get ALL active monitor names dynamically ---
# This command gets a list of all connected monitor names, separated by newlines.
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Let user pick an image from the folder using Rofi with themed config
# NOTE: The selection pattern now explicitly includes *.webp
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) |
 sort |
 rofi -dmenu -p "Choose Wallpaper" -theme "$HOME/Templates/ThemeM0d/Themes/$(echo "$MONITORS" | head -n 1)/rofi.rasi")

# If user made a selection
if [ -n "$SELECTED" ]; then
 # Ensure hyprpaper is running (start if not)
 if ! pgrep -x "hyprpaper" >/dev/null; then
hyprpaper &
# Wait until hyprpaper is ready
 for i in {1..20}; do
   if hyprctl hyprpaper listpreloaded >/dev/null 2>&1; then
    break
   fi
   sleep 0.2
  done
 fi

 # --- 2. Preload the image and prepare the hyprpaper config content ---
 hyprctl hyprpaper preload "$SELECTED"

 # Start a fresh persistent config file
 mkdir -p "$(dirname "$HYPAPER_CONF")"
 echo "preload = $SELECTED" >"$HYPAPER_CONF" # Start with preload

 # --- 3. Loop through all monitors to set the wallpaper via IPC and config file ---
 for MONITOR_NAME in $MONITORS; do
  # Set wallpaper via IPC for immediate effect
  hyprctl hyprpaper wallpaper "$MONITOR_NAME,$SELECTED"

  # Add to persistent hyprpaper.conf
  echo "wallpaper = $MONITOR_NAME,$SELECTED" >>"$HYPAPER_CONF"
 done

 # Your existing theme logic
 PRIMARY_MONITOR=$(echo "$MONITORS" | head -n 1) # Use the first monitor for theme directory name

 # Generate and build new theme
 archThemeM0d generate
 archThemeM0d build
 chmod 644 "$HOME/Templates/ThemeM0d/Themes/$PRIMARY_MONITOR/dunstrc"

 # Restart dunst with themed config
 pkill dunst
 dunst --conf "$HOME/Templates/ThemeM0d/Themes/$PRIMARY_MONITOR/dunst_config" &

 # Restart waybar with themed config
 pkill waybar
 waybar --style "$HOME/Templates/ThemeM0d/Themes/$PRIMARY_MONITOR/waybar.css" &
fi
