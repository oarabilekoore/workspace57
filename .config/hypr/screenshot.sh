#bin/bash

get_fullscreen_shot() {
  grim - | tee ~/Pictures/Screenshots/$(date).png | wl-copy
}
