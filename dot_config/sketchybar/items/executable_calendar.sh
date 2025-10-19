#!/bin/bash

calendar=(
  icon=󰃭
  background.color=${ALPHA_ITEM}${BASE}
  icon.padding_right=0
  label.padding_left=6
  padding_left=$PADDINGS
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
