#!/bin/bash

MONITOR_NAME=$(hyprctl monitors -j | jq -r '.[0].name')

systemctl --user start hyprpolkitagent &
hyprpaper &
nm-applet &
hypridle &
swaync --style "$HOME/Templates/ThemeM0d/Themes/$MONITOR_NAME/swaync.css" &
waybar --style "$HOME/Templates/ThemeM0d/Themes/$MONITOR_NAME/waybar.css" &
