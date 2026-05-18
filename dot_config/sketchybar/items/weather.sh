#!/bin/bash

weather=(
  icon=󰖐
  update_freq=1800
  script="$PLUGIN_DIR/weather.sh"
)

sketchybar --add item weather right \
           --set weather "${weather[@]}" \
           --subscribe weather mouse.entered mouse.exited mouse.clicked

# Detail items in the popup
sketchybar --add item weather.location popup.weather \
           --set weather.location icon= \
                                 icon.color=${ALPHA_ITEM}${PEACH} \
                                 label.font="$FONT:Bold:12.0" \
\
           --add item weather.condition popup.weather \
           --set weather.condition icon=󰖐 \
\
           --add item weather.moon popup.weather \
           --set weather.moon icon=󰽢 \
                              icon.color=${ALPHA_ITEM}${TEXT} icon.width=16 \
\
           --add item weather.sunrise popup.weather \
           --set weather.sunrise icon=󰖜 \
                                 icon.color=${ALPHA_ITEM}${YELLOW} \
\
           --add item weather.sunset popup.weather \
           --set weather.sunset icon=󰖛 \
                                icon.color=${ALPHA_ITEM}${PEACH} \
\
           --add item weather.details popup.weather \
           --set weather.details icon=󰔄 \
                                 icon.color=${ALPHA_ITEM}${MAUVE} \
\
           --add item weather.uv popup.weather \
           --set weather.uv icon=󰖨 \
                            icon.color=${ALPHA_ITEM}${YELLOW} \
\
           --add item weather.humidity popup.weather \
           --set weather.humidity icon=󰖏 \
                                   icon.color=${ALPHA_ITEM}${BLUE} \
\
           --add item weather.rain popup.weather \
           --set weather.rain icon= \
                              icon.color=${ALPHA_ITEM}${SKY} \
\
           --add item weather.wind popup.weather \
           --set weather.wind icon=󰖝 \
                              icon.color=${ALPHA_ITEM}${TEAL}
