#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

COLOR=${ALPHA_ITEM}${TEXT}

case "${PERCENTAGE}" in
  9[0-9]|100)
    ICON=""
    COLOR=${ALPHA_ITEM}${GREEN}
  ;;
  [6-8][0-9])
    ICON=""
    COLOR=${ALPHA_ITEM}${YELLOW}
  ;;
  [3-5][0-9])
    ICON=" "
    COLOR=${ALPHA_ITEM}${PEACH}
  ;;
  [1-2][0-9])
    ICON=""
    COLOR=${ALPHA_ITEM}${MAROON}
  ;;
  *)
    ICON=""
    COLOR=${ALPHA_ITEM}${RED}
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" icon.color=$COLOR
