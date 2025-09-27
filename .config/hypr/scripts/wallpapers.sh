#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
HYPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# Get primary monitor name dynamically
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

# Let user pick an image from the folder using Rofi with themed config
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) |
  sort |
  rofi -dmenu -p "Choose Wallpaper" -theme "$HOME/Templates/ThemeM0d/Themes/$MONITOR/rofi.rasi")

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

  # Preload and set wallpaper
  hyprctl hyprpaper preload "$SELECTED"
  hyprctl hyprpaper wallpaper "$MONITOR,$SELECTED"

  # Generate and build new theme
  archThemeM0d generate
  archThemeM0d build
  chmod 644 "$HOME/Templates/ThemeM0d/Themes/$MONITOR/dunstrc"

  # Restart dunst with themed config
  pkill dunst
  dunst --conf "$HOME/Templates/ThemeM0d/Themes/$MONITOR/dunstrc" &

  # Restart waybar with themed config
  pkill waybar
  waybar --style "$HOME/Templates/ThemeM0d/Themes/$MONITOR/waybar.css" &

  # Save persistent config for hyprpaper
  mkdir -p "$(dirname "$HYPAPER_CONF")"
  {
    echo "preload = $SELECTED"
    echo "wallpaper = $MONITOR,$SELECTED"
  } >"$HYPAPER_CONF"
fi
