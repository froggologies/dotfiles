#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  COLOR=${ALPHA_ITEM}${TEXT}

  case "$VOLUME" in
    [6-9][0-9]|100)
      ICON=""
      COLOR=${ALPHA_ITEM}${TEXT}
    ;;
    [3-5][0-9])
      ICON=""
      COLOR=${ALPHA_ITEM}${SUBTEXT1}
    ;;
    [1-9]|[1-2][0-9])
      ICON=""
      COLOR=${ALPHA_ITEM}${SUBTEXT0}
    ;;
    *)
      ICON=""
      COLOR=${ALPHA_ITEM}${OVERLAY2}
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" icon.color=$COLOR
fi
