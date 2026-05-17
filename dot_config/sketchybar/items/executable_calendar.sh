#!/bin/bash

sketchybar --add item calendar right \
           --set calendar icon=󰃭 \
                         label= \
                         update_freq=30 \
                         mach_helper="$HELPER" \
                         popup.align=center \
           --subscribe calendar system_woke mouse.clicked mouse.entered mouse.exited
