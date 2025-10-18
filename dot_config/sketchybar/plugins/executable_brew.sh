#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

COUNT=$(brew outdated | wc -l | tr -d ' ')

COLOR=${ALPHA_ITEM}${TEXT}
ICON="󰏗"

case "$COUNT" in
30 | [3-9][0-9] | [1-9][0-9][0-9]*)
	COLOR=${ALPHA_ITEM}${RED}
	ICON=󱧕
	;;
2[0-9])
	COLOR=${ALPHA_ITEM}${MAROON}
	ICON=󱧕
	;;
1[0-9])
	COLOR=${ALPHA_ITEM}${PEACH}
	ICON=󱧕
	;;
[1-9])
	COLOR=${ALPHA_ITEM}${YELLOW}
	ICON=󱧕
	;;
0)
	COLOR=${ALPHA_ITEM}${GREEN}
	COUNT=
	;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR icon=$ICON
