#/bin/bash

case "$1" in
"fullscreen")
  filename="$HOME/Pictures/Screenshots/$(date +"%A at %I:%M %p")-fullscreen.jpeg"
  grim -t jpeg -q 100 - | tee "$filename" >/dev/null
  notify-send "Screenshot saved as $filename" -t 2000
  ;;

"area")
  filename="$HOME/Pictures/Screenshots/$(date +"%A at %I:%M %p")-area.jpeg"
  grim -g "$(slurp)" -t jpeg -q 100 - | tee "$filename" | swappy -f -
  notify-send "Area screenshot saved as $filename" -t 2000
  ;;
esac
