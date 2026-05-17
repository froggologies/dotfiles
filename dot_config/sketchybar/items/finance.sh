#!/bin/bash

bitcoin=(
  icon=
  icon.color=${ALPHA_ITEM}${YELLOW}
  update_freq=300
  script="$PLUGIN_DIR/finance.sh"
)

sketchybar --add item finance right \
           --set finance "${bitcoin[@]}" \
           --subscribe finance mouse.entered mouse.exited mouse.clicked

# Detail items in the popup
sketchybar --add item finance.usdidr popup.finance \
           --set finance.usdidr icon= \
                                 icon.color=${ALPHA_ITEM}${GREEN} \
\
           --add item finance.xauidr popup.finance \
           --set finance.xauidr icon=󱉏 \
                                 icon.color=${ALPHA_ITEM}${YELLOW}
