#!/bin/bash

sketchybar --add item media left \
           --set media label.color=${ALPHA_ITEM}${TEXT} \
                       label.max_chars=30 \
                       label.scroll_duration=250 \
                       scroll_texts=on \
                       label.drawing=off \
                       icon.drawing=off \
                       background.drawing=off \
                       icon=󰝚 \
                       icon.color=${ALPHA_ITEM}${MAUVE} \
                       script="$PLUGIN_DIR/media.sh" \
                       update_freq=5 \
           --subscribe media media_change
