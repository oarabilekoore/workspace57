#!/bin/bash

# Suppress all stderr output from this script to keep stdout clean for Waybar.
exec 2>/dev/null

BRIGHTNESS_PERCENT=0
BRIGHTNESS_VALUE="N/A"

# --- Try 'brightnessctl' (as you confirmed it works) ---
# Get the raw percentage value without '%' for numerical comparisons
RAW_PERCENT=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
# Get the value with '%' for displaying to the user
RAW_VALUE=$(brightnessctl -m | awk -F, '{print $4}')

# Validate the extracted percentage.
# Check if it's not empty and contains only digits.
if [[ -n "$RAW_PERCENT" && "$RAW_PERCENT" =~ ^[0-9]+$ ]]; then
    BRIGHTNESS_PERCENT="$RAW_PERCENT" # Assign the numeric percentage for any future logic
    BRIGHTNESS_VALUE="$RAW_VALUE"     # Assign the value with '%' for display
fi

# --- Always use the moon-like icon for brightness ---
BRIGHTNESS_ICON="" # Font Awesome moon/sleep icon

# Output the icon and text directly to stdout (e.g., " 50%")
echo "${BRIGHTNESS_ICON} ${BRIGHTNESS_VALUE}"