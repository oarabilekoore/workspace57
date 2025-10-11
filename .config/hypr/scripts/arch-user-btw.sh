sudo tee /usr/local/bin/archbtw >/dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Check required programs
for cmd in kitty toilet; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required program '$cmd' not found. Install it, e.g.: sudo pacman -S $cmd"
    exit 1
  fi
done

# Optional: use lolcat if available for rainbow effect
# If you don't have lolcat and want it: sudo pacman -S lolcat
# Create a temporary inner script that will run inside kitty (avoids quoting issues)
TMP_SCRIPT=$(mktemp /tmp/archbtw.XXXXXX.sh)

cat > "$TMP_SCRIPT" <<'INNER'
#!/usr/bin/env bash
set -euo pipefail
clear
sleep 0.2

# center_lines: read stdin and print each line centered horizontally
center_lines() {
  cols=$(tput cols 2>/dev/null || echo 80)
  while IFS= read -r line || [ -n "$line" ]; do
    # strip ANSI escape sequences for length calculation
    clean=$(printf '%s' "$line" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
    # get printable length (fallback to 0 on error)
    len=$(printf '%s' "$clean" | awk '{print length($0)}' 2>/dev/null || echo 0)
    # sanitize len (ensure it's numeric)
    if ! printf '%s' "$len" | grep -qE '^[0-9]+$'; then
      len=0
    fi
    pad=$(( (cols - len) / 2 ))
    if [ "$pad" -lt 0 ]; then pad=0; fi
    # print padding then the original (possibly coloured) line
    printf "%*s%s\n" "$pad" "" "$line"
  done
}

# Print three banners, centered
toilet -f mono12 "I f***in use    arch !" | center_lines
sleep 0.6

toilet -f term -F border "I f***in use arch bitch" | center_lines
sleep 0.6
echo
printf "%s" "Press any key to exit..."
read -n 1 -s
INNER

chmod +x "$TMP_SCRIPT"

# Launch kitty fullscreen and run the inner script; remove tmp script after kitty exits
kitty --start-as=fullscreen "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"
EOF

sudo chmod +x /usr/local/bin/archbtw
