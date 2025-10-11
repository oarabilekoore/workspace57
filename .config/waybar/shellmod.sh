#!/bin/bash

# Script to intelligently toggle the quickshell application.
# If quickshell is running, it kills the process (closing it).
# If quickshell is not running, it launches the application.

# Check if any process named 'quickshell' is running.
# -f includes the full command line, making the match more reliable.
if pgrep -x quickshell >/dev/null; then
  # quickshell is running, so kill it.
  pkill -f quickshell
else
  # quickshell is not running, so launch it.
  # We use '&' to run it in the background so the script exits immediately.
  quickshell &
fi
