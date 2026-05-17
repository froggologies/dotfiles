#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
    9[1-9]|100) COLOR=${ALPHA_ITEM}${RED} ;;
    8[1-9]|90)  COLOR=${ALPHA_ITEM}${PEACH} ;;
    7[1-9]|80)  COLOR=${ALPHA_ITEM}${YELLOW} ;;
    6[1-9]|70)  COLOR=${ALPHA_ITEM}${TEXT} ;;
    5[1-9]|60)  COLOR=${ALPHA_ITEM}${SUBTEXT1} ;;
    4[1-9]|50)  COLOR=${ALPHA_ITEM}${SUBTEXT0} ;;
    3[1-9]|40)  COLOR=${ALPHA_ITEM}${OVERLAY2} ;;
    2[1-9]|30)  COLOR=${ALPHA_ITEM}${OVERLAY1} ;;
    1[1-9]|20)  COLOR=${ALPHA_ITEM}${OVERLAY0} ;;
    [1-9]|10)   COLOR=${ALPHA_ITEM}${SURFACE2} ;;
    *)          COLOR=${ALPHA_ITEM}${SURFACE1} ;;
  esac

  case "$VOLUME" in
    [6-9][0-9]|100) ICON="" ;;
    [1-5][0-9])     ICON="" ;;
    *)              ICON="" ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%" icon.color=$COLOR
fi
