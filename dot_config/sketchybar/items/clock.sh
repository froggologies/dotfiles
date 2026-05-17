#!/bin/bash

sketchybar --add item clock right \
           --set clock icon=󰥔 \
                       update_freq=1 \
                       mach_helper="$HELPER" \
           --subscribe clock system_woke mouse.clicked
