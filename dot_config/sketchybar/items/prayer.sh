#!/bin/bash

prayer=(
  icon=
  update_freq=60
  script="$PLUGIN_DIR/prayer.sh"
)

sketchybar --add item prayer right \
           --set prayer "${prayer[@]}" \
           --subscribe prayer mouse.entered mouse.exited mouse.clicked

# Detail items in the popup
sketchybar --add item prayer.location popup.prayer \
           --set prayer.location icon= \
                                 icon.color=${ALPHA_ITEM}${PEACH} \
                                 label.font="$FONT:Bold:12.0" \
                                 label="Loading..." \
\
           --add item prayer.fajr popup.prayer \
           --set prayer.fajr icon=󰖜 \
                             icon.color=${ALPHA_ITEM}${BLUE} \
                             label="Fajr     --:--" \
\
           --add item prayer.dhuhr popup.prayer \
           --set prayer.dhuhr icon=󰖙 \
                              icon.color=${ALPHA_ITEM}${YELLOW} \
                              label="Dhuhr    --:--" \
\
           --add item prayer.asr popup.prayer \
           --set prayer.asr icon=󰖕 \
                            icon.color=${ALPHA_ITEM}${PEACH} \
                            label="Asr      --:--" \
\
           --add item prayer.maghrib popup.prayer \
           --set prayer.maghrib icon=󰖛 \
                                icon.color=${ALPHA_ITEM}${FLAMINGO} \
                                label="Maghrib  --:--" \
\
           --add item prayer.isha popup.prayer \
           --set prayer.isha icon=󰖔 \
                             icon.color=${ALPHA_ITEM}${MAUVE} \
                             label="Isha     --:--"
