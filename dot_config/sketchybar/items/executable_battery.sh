#!/bin/bash

battery=(
  icon.padding_right=0
  label.padding_left=4
  label.padding_right=0
  update_freq=120
  script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
	--set battery "${battery[@]}"\
	--subscribe battery system_woke power_source_change