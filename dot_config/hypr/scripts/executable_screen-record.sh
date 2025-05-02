#!/bin/env bash

# Stop if already recording
pgrep -x "wf-recorder" && pkill -INT -x wf-recorder && notify-send -h string:wf-recorder:record -t 1000 "Finished Recording" && exit 0

# Get monitor name from fuzzel
monitor=$(hyprctl monitors -j | jq -r '.[].name' | fuzzel --dmenu)

# Exit if none selected
[ -z "$monitor" ] && exit 1

# Countdown notifications
for i in 3 2 1; do
  notify-send -h string:wf-recorder:record -t 1000 "Recording in:" "<span color='#90a4f4' font='26px'><i><b>$i</b></i></span>"
  sleep 1
done

# Start recording
dateTime=$(date +%m-%d-%Y-%H:%M:%S)
wf-recorder --output "$monitor" --bframes max_b_frames -f "$HOME/Videos/$dateTime.mp4"
