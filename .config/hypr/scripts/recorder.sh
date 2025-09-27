#!/bin/bash

pidfile="$HOME/.cache/wf-recorder.pid"

if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
  kill "$(cat "$pidfile")"
  notify-send "🛑 Screen Recording" "Recording stopped."
  rm "$pidfile"
else
  mkdir -p "$HOME/Videos"
  filename="Screenrec@$(date +%A@%H:%M).mp4"
  output="$HOME/Videos/$filename"

  # Just record audio from default source
  wf-recorder -f "$output" &

  echo $! >"$pidfile"
  notify-send "🎥 Screen Recording" "Recording started: $filename"
fi
