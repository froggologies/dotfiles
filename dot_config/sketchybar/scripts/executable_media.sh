#!/bin/bash

# Use the full path to nowplaying-cli to ensure it works in sketchybar's environment
NOWPLAYING="/opt/homebrew/bin/nowplaying-cli"

STATE=$($NOWPLAYING get playbackRate)
NORMALIZED_STATE=$(printf "%.0f" $STATE 2>/dev/null || echo 0)

if [ "$NORMALIZED_STATE" -ge 1 ]; then
  TITLE=$($NOWPLAYING get title)
  ARTIST=$($NOWPLAYING get artist)
  
  if [ "$TITLE" != "null" ] && [ -n "$TITLE" ]; then
    LABEL="$TITLE"
    if [ "$ARTIST" != "null" ] && [ -n "$ARTIST" ]; then
       LABEL="$TITLE - $ARTIST"
    fi
    # Force label drawing back ON and restore padding
    sketchybar --set $NAME label="$LABEL" \
                           label.drawing=on \
                           icon.drawing=on \
                           background.drawing=on \
                           icon.padding_right=5
  else
    # Fallback for playing state with no metadata
    sketchybar --set $NAME label="Playing..." \
                           label.drawing=on \
                           icon.drawing=on \
                           background.drawing=on \
                           icon.padding_right=5
  fi
else
  # Keep the item visible but hide the label text
  sketchybar --set $NAME label.drawing=off \
                         icon.drawing=off \
                         background.drawing=off \
                         icon.padding_right=0
fi
