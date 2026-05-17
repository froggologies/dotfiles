#!/bin/bash

# Source colors
source "$HOME/.config/sketchybar/colors.sh"

render_bar() {
  # Get location with a timeout
  LOCATION_JSON=$(curl -sL --connect-timeout 3 --max-time 5 "https://ipinfo.io/json")
  CITY=$(echo "$LOCATION_JSON" | jq -r '.city')
  COUNTRY=$(echo "$LOCATION_JSON" | jq -r '.country')
  
  if [ -z "$CITY" ] || [ "$CITY" = "null" ]; then
    CITY="Jakarta"
    COUNTRY="Indonesia"
  fi

  # Fetch prayer times with method=20 (Kemenag Indonesia)
  PRAYER_JSON=$(curl -sL --connect-timeout 3 --max-time 10 "https://api.aladhan.com/v1/timingsByCity?city=$CITY&country=$COUNTRY&method=20")
  
  if [ -z "$PRAYER_JSON" ] || [ "$(echo "$PRAYER_JSON" | jq -r '.code')" != "200" ]; then
    sketchybar --set "$NAME" label=""
    exit 1
  fi

  # Extract timings
  FAJR=$(echo "$PRAYER_JSON" | jq -r '.data.timings.Fajr')
  DHUHR=$(echo "$PRAYER_JSON" | jq -r '.data.timings.Dhuhr')
  ASR=$(echo "$PRAYER_JSON" | jq -r '.data.timings.Asr')
  MAGHRIB=$(echo "$PRAYER_JSON" | jq -r '.data.timings.Maghrib')
  ISHA=$(echo "$PRAYER_JSON" | jq -r '.data.timings.Isha')

  # Determine if it's Friday for Jumaah label
  DAY_OF_WEEK=$(date +"%u")
  DHUHR_NAME="Dhuhr"
  if [ "$DAY_OF_WEEK" -eq 5 ]; then
    DHUHR_NAME="Jumaah"
  fi

  # Current time in HH:MM
  CURRENT_TIME=$(date +"%H:%M")
  
  # Function to convert HH:MM to minutes since midnight
  to_minutes() {
    local HH=$(echo $1 | cut -d: -f1)
    local MM=$(echo $1 | cut -d: -f2)
    echo $((10#$HH * 60 + 10#$MM))
  }

  NOW_MIN=$(to_minutes "$CURRENT_TIME")
  FAJR_MIN=$(to_minutes "$FAJR")
  DHUHR_MIN=$(to_minutes "$DHUHR")
  ASR_MIN=$(to_minutes "$ASR")
  MAGHRIB_MIN=$(to_minutes "$MAGHRIB")
  ISHA_MIN=$(to_minutes "$ISHA")

  # Determine next prayer
  NEXT_NAME=""
  NEXT_TIME=""
  NEXT_ICON=""
  NEXT_COLOR=""

  if [ "$NOW_MIN" -lt "$FAJR_MIN" ]; then
    NEXT_NAME="Fajr"
    NEXT_TIME="$FAJR"
    NEXT_ICON="󰖜"
    NEXT_COLOR=${ALPHA_ITEM}${BLUE}
  elif [ "$NOW_MIN" -lt "$DHUHR_MIN" ]; then
    NEXT_NAME="$DHUHR_NAME"
    NEXT_TIME="$DHUHR"
    NEXT_ICON="󰖙"
    NEXT_COLOR=${ALPHA_ITEM}${YELLOW}
  elif [ "$NOW_MIN" -lt "$ASR_MIN" ]; then
    NEXT_NAME="Asr"
    NEXT_TIME="$ASR"
    NEXT_ICON="󰖕"
    NEXT_COLOR=${ALPHA_ITEM}${PEACH}
  elif [ "$NOW_MIN" -lt "$MAGHRIB_MIN" ]; then
    NEXT_NAME="Maghrib"
    NEXT_TIME="$MAGHRIB"
    NEXT_ICON="󰖛"
    NEXT_COLOR=${ALPHA_ITEM}${FLAMINGO}
  elif [ "$NOW_MIN" -lt "$ISHA_MIN" ]; then
    NEXT_NAME="Isha"
    NEXT_TIME="$ISHA"
    NEXT_ICON="󰖔"
    NEXT_COLOR=${ALPHA_ITEM}${MAUVE}
  else
    NEXT_NAME="Fajr"
    NEXT_TIME="$FAJR"
    NEXT_ICON="󰖜"
    NEXT_COLOR=${ALPHA_ITEM}${BLUE}
  fi

  # Update main bar item (no colon)
  sketchybar --set "$NAME" icon="$NEXT_ICON" label="$NEXT_NAME $NEXT_TIME" icon.color="$NEXT_COLOR"

  # Standardize all detail labels to be aligned without a colon using printf %-7s
  FAJR_LABEL=$(printf "%-7s  %s" "Fajr" "$FAJR")
  DHUHR_LABEL=$(printf "%-7s  %s" "$DHUHR_NAME" "$DHUHR")
  ASR_LABEL=$(printf "%-7s  %s" "Asr" "$ASR")
  MAGHRIB_LABEL=$(printf "%-7s  %s" "Maghrib" "$MAGHRIB")
  ISHA_LABEL=$(printf "%-7s  %s" "Isha" "$ISHA")

  # Update popup details
  sketchybar --set prayer.location label="$CITY, $COUNTRY" \
             --set prayer.fajr label="$FAJR_LABEL" \
             --set prayer.dhuhr label="$DHUHR_LABEL" \
             --set prayer.asr label="$ASR_LABEL" \
             --set prayer.maghrib label="$MAGHRIB_LABEL" \
             --set prayer.isha label="$ISHA_LABEL"
}

if [ "$SENDER" = "mouse.clicked" ]; then
  FAJR_LOAD=$(printf "%-7s  %s" "Fajr" "")
  DHUHR_LOAD=$(printf "%-7s  %s" "Dhuhr" "")
  ASR_LOAD=$(printf "%-7s  %s" "Asr" "")
  MAGHRIB_LOAD=$(printf "%-7s  %s" "Maghrib" "")
  ISHA_LOAD=$(printf "%-7s  %s" "Isha" "")

  sketchybar --set "$NAME" label="" icon="" \
             --set prayer.location label="" \
             --set prayer.fajr label="$FAJR_LOAD" \
             --set prayer.dhuhr label="$DHUHR_LOAD" \
             --set prayer.asr label="$ASR_LOAD" \
             --set prayer.maghrib label="$MAGHRIB_LOAD" \
             --set prayer.isha label="$ISHA_LOAD"
  render_bar
elif [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
else
  render_bar
fi
