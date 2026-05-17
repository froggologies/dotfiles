#!/bin/bash

# Detect the number of spaces on the primary monitor
TEMP_PLIST="$HOME/.config/sketchybar/spaces_temp.plist"
defaults read com.apple.spaces > "$TEMP_PLIST"
SPACES_COUNT=$(plutil -convert json -o - "$TEMP_PLIST" | jq '.SpacesDisplayConfiguration."Management Data".Monitors[0].Spaces | length')
rm "$TEMP_PLIST"

# Fallback if detection fails
if [ -z "$SPACES_COUNT" ] || [ "$SPACES_COUNT" -eq 0 ]; then
  SPACES_COUNT=6
fi

SPACE_ICONS=("󰖟" "" "" "" "" "󰣆" "󰣆" "󰣆")

for i in $(seq 0 $(($SPACES_COUNT - 1))); do
	sid=$(($i + 1))

	space=(
		associated_space=$sid
		icon=${SPACE_ICONS[i]}
		icon.highlight_color=${ALPHA_ITEM}${RED}
		label.drawing=off
		padding_right=10
		padding_left=0
		icon.padding_left=0
		icon.padding_right=0
	)

	if [ $sid -eq 1 ]; then
		space+=(padding_left=$PADDING)
	fi

	if [ $sid -eq $SPACES_COUNT ]; then
		space+=(padding_right=$PADDING)
	fi

	sketchybar --add space space.$sid left \
		       --set space.$sid "${space[@]}"
done