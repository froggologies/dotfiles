#!/bin/bash

front_app=(
  icon=
  padding_left=$PADDINGS
  icon.padding_right=0
  icon.padding_left=0
  label.color=${ALPHA_ITEM}${RED}
  script="$PLUGIN_DIR/front_app.sh"
)


sketchybar --add item front_app left \
           --set front_app "${front_app[@]}"\
           --subscribe front_app front_app_switched
