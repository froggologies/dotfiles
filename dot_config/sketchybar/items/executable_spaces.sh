#!/bin/bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8")

sid=0
spaces=()

for i in "${!SPACE_ICONS[@]}"; do
	sid=$(($i + 1))

	space=(
		associated_space=$sid
		icon=${SPACE_ICONS[i]}
		icon.padding_left=$PADDINGS
		icon.padding_right=0
		icon.highlight_color=${ALPHA_ITEM}${RED}
		label.drawing=off
	)

	sketchybar --add space space.$sid left \
		--set space.$sid "${space[@]}"
done