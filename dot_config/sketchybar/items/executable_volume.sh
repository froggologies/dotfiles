#!/bin/bash

volume=(
  icon.padding_right=0
  label.padding_left=4
  label.padding_right=0
  script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add item volume right \
	--set volume "${volume[@]}"\
	--subscribe volume volume_change