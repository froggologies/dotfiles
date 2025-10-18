#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

TIME=$(date '+%p')

COLOR=${ALPHA_ITEM}${TEXT}

if [ "$TIME" = "AM" ]; then
    COLOR=${ALPHA_ITEM}${YELLOW}
else
   COLOR=${ALPHA_ITEM}${BLUE}
fi

sketchybar --set $NAME label="$(date '+%a %d %b %I:%M %p')" icon.color=$COLOR