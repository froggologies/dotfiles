#!/bin/bash

# CPU Item
sketchybar --add item cpu right \
           --set cpu icon= \
                     update_freq=2 \
                     mach_helper="$HELPER" \
           --subscribe cpu mouse.entered mouse.exited

# CPU Popup Items
sketchybar --add graph cpu.graph popup.cpu 223 \
           --set cpu.graph graph.color=${ALPHA_ITEM}${RED} \
                           graph.fill_color=${ALPHA_ITEM}${RED} \
                           label.drawing=off \
                           icon.drawing=off \
                           background.height=30 \
                           background.drawing=on \
\
           --add item cpu.details.1 popup.cpu \
           --set cpu.details.1 icon.drawing=off \
                               label="Loading..." \
\
           --add item cpu.details.2 popup.cpu \
           --set cpu.details.2 icon.drawing=off \
                               label="Loading..." \
\
           --add item cpu.details.3 popup.cpu \
           --set cpu.details.3 icon.drawing=off \
                               label="Loading..."

# RAM Item
sketchybar --add item ram right \
           --set ram icon= \
                     update_freq=10 \
                     mach_helper="$HELPER" \
           --subscribe ram mouse.entered mouse.exited

# RAM Popup Items
sketchybar --add graph ram.graph popup.ram 223 \
           --set ram.graph graph.color=${ALPHA_ITEM}${BLUE} \
                           graph.fill_color=${ALPHA_ITEM}${BLUE} \
                           label.drawing=off \
                           icon.drawing=off \
                           background.height=30 \
                           background.drawing=on \
\
           --add item ram.details.1 popup.ram \
           --set ram.details.1 icon.drawing=off \
                               label="Loading..." \
\
           --add item ram.details.2 popup.ram \
           --set ram.details.2 icon.drawing=off \
                               label="Loading..." \
\
           --add item ram.details.3 popup.ram \
           --set ram.details.3 icon.drawing=off \
                               label="Loading..."

# Disk Item
sketchybar --add item disk right \
           --set disk icon=󰋊 \
                      update_freq=30 \
                      mach_helper="$HELPER" \
           --subscribe disk mouse.entered mouse.exited

# Disk Popup Items
sketchybar --add graph disk.graph popup.disk 181 \
           --set disk.graph graph.color=${ALPHA_ITEM}${GREEN} \
                            graph.fill_color=${ALPHA_ITEM}${GREEN} \
                            label.drawing=off \
                            icon.drawing=off \
                            background.height=30 \
                            background.drawing=on \
\
           --add item disk.details popup.disk \
           --set disk.details icon.drawing=off \
                              label="Used: Loading..."
