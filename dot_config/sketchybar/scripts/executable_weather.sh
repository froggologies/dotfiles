#!/bin/bash

# Source colors to ensure ALPHA_ITEM, BLUE, YELLOW, etc. are available
source "$HOME/.config/sketchybar/colors.sh"

render_bar() {
  # Get location for more accurate weather fetching
  LOCATION_JSON=$(curl -sL --connect-timeout 3 --max-time 5 "https://ipinfo.io/json")
  CITY_NAME=$(echo "$LOCATION_JSON" | jq -r '.city')
  
  if [ -z "$CITY_NAME" ] || [ "$CITY_NAME" = "null" ]; then
    CITY_NAME="" # wttr.in will auto-detect if empty
  fi

  # Fetch weather info from wttr.in (using detected city if available)
  WEATHER_JSON=$(curl -sL --connect-timeout 3 --max-time 10 "https://wttr.in/${CITY_NAME// /+}/?format=j1")

  if [ -z "$WEATHER_JSON" ] || [ "$WEATHER_JSON" = "null" ]; then
    sketchybar --set "$NAME" label=""
    exit 1
  fi

  # 1. Current status
  TEMPERATURE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C')
  CONDITION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value')
  
  # 2. Location (Prefer detected CITY_NAME)
  WTTR_CITY=$(echo "$WEATHER_JSON" | jq -r '.nearest_area[0].areaName[0].value')
  REGION=$(echo "$WEATHER_JSON" | jq -r '.nearest_area[0].region[0].value')
  
  if [ -n "$CITY_NAME" ]; then
    LOCATION="${CITY_NAME//+/ }, ${REGION}"
  else
    LOCATION="${WTTR_CITY}, ${REGION}"
  fi
  
  # 3. Astronomy (Sunrise, Sunset, Moon)
  SUNRISE=$(echo "$WEATHER_JSON" | jq -r '.weather[0].astronomy[0].sunrise')
  SUNSET=$(echo "$WEATHER_JSON" | jq -r '.weather[0].astronomy[0].sunset')
  
  MOON_PHASE=$(echo "$WEATHER_JSON" | jq -r '.weather[0].astronomy[0].moon_phase')
  MOON_ILLUM=$(echo "$WEATHER_JSON" | jq -r '.weather[0].astronomy[0].moon_illumination')

  # 4. Extra details
  FEELS_LIKE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].FeelsLikeC')
  HUMIDITY=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].humidity')
  WIND=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].windspeedKmph')
  UV_INDEX=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].uvIndex')
  RAIN_CHANCE=$(echo "$WEATHER_JSON" | jq -r '[.weather[0].hourly[].chanceofrain | tonumber] | max')

  # Determine UV color dynamically (Green for Low, Yellow for Mod, Orange for High, Red for Very High, Purple for Extreme)
  if [ -z "$UV_INDEX" ] || [ "$UV_INDEX" = "null" ]; then
    UV_COLOR="${ALPHA_ITEM}${TEXT}"
  elif [ "$UV_INDEX" -le 2 ]; then
    UV_COLOR="${ALPHA_ITEM}${GREEN}"
  elif [ "$UV_INDEX" -le 5 ]; then
    UV_COLOR="${ALPHA_ITEM}${YELLOW}"
  elif [ "$UV_INDEX" -le 7 ]; then
    UV_COLOR="${ALPHA_ITEM}${PEACH}"
  elif [ "$UV_INDEX" -le 10 ]; then
    UV_COLOR="${ALPHA_ITEM}${RED}"
  else
    UV_COLOR="${ALPHA_ITEM}${MAUVE}"
  fi

  # Determine Chance of Rain color dynamically (dim/normal if dry, sky blue if light, rich blue if high)
  if [ -z "$RAIN_CHANCE" ] || [ "$RAIN_CHANCE" = "null" ]; then
    RAIN_COLOR="${ALPHA_ITEM}${TEXT}"
  elif [ "$RAIN_CHANCE" -eq 0 ]; then
    RAIN_COLOR="${ALPHA_ITEM}${TEXT}"
  elif [ "$RAIN_CHANCE" -le 20 ]; then
    RAIN_COLOR="${ALPHA_ITEM}${SUBTEXT1}"
  elif [ "$RAIN_CHANCE" -le 50 ]; then
    RAIN_COLOR="${ALPHA_ITEM}${SKY}"
  else
    RAIN_COLOR="${ALPHA_ITEM}${BLUE}"
  fi

  # --- Condition Icon Mapping ---
  # Based on wttr.in condition codes: https://wttr.in/:help
  WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode')
  case "$WEATHER_CODE" in
    113) ICON="󰖙"; COLOR=${ALPHA_ITEM}${YELLOW} ;; # Clear/Sunny
    116) ICON="󰖕"; COLOR=${ALPHA_ITEM}${PEACH} ;;  # Partly cloudy
    119) ICON="󰖐"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Cloudy
    122) ICON="󰖐"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Overcast
    143) ICON="󰖑"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Mist
    176) ICON="󰼳"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Patchy rain possible
    179) ICON="󰼴"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy snow possible
    182) ICON="󰼵"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy sleet possible
    185) ICON="󰼵"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy freezing drizzle possible
    200) ICON="󰼲"; COLOR=${ALPHA_ITEM}${MAUVE} ;;  # Thundery outbreaks possible
    227) ICON="󰖝"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Blowing snow
    230) ICON="󰼸"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Blizzard
    248) ICON="󰖑"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Fog
    260) ICON="󰖑"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Freezing fog
    263) ICON="󰼳"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Patchy light drizzle
    266) ICON="󰖗"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Light drizzle
    281) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Freezing drizzle
    284) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Heavy freezing drizzle
    293) ICON="󰼳"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Patchy light rain
    296) ICON="󰖗"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Light rain
    299) ICON="󰖗"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Moderate rain at times
    302) ICON="󰖗"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Moderate rain
    305) ICON="󰖖"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Heavy rain at times
    308) ICON="󰖖"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Heavy rain
    311) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Light freezing rain
    314) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Moderate or heavy freezing rain
    317) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Light sleet
    320) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Moderate or heavy sleet
    323) ICON="󰼴"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy light snow
    326) ICON="󰖘"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Light snow
    329) ICON="󰼴"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy moderate snow
    332) ICON="󰖘"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Moderate snow
    335) ICON="󰼶"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Patchy heavy snow
    338) ICON="󰼶"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Heavy snow
    350) ICON="󰖒"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Ice pellets
    353) ICON="󰖗"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Light rain shower
    356) ICON="󰖖"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Moderate or heavy rain shower
    359) ICON="󰖖"; COLOR=${ALPHA_ITEM}${BLUE} ;;   # Torrential rain shower
    362) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Light sleet showers
    365) ICON="󰙿"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Moderate or heavy sleet showers
    368) ICON="󰼴"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Light snow showers
    371) ICON="󰼶"; COLOR=${ALPHA_ITEM}${SKY} ;;    # Moderate or heavy snow showers
    386) ICON="󰙾"; COLOR=${ALPHA_ITEM}${MAUVE} ;;  # Patchy light rain with thunder
    389) ICON="󰙾"; COLOR=${ALPHA_ITEM}${MAUVE} ;;  # Moderate or heavy rain with thunder
    392) ICON="󰼲"; COLOR=${ALPHA_ITEM}${MAUVE} ;;  # Patchy light snow with thunder
    395) ICON="󰼲"; COLOR=${ALPHA_ITEM}${MAUVE} ;;  # Moderate or heavy snow with thunder
    *)   ICON="󰖟"; COLOR=${ALPHA_ITEM}${TEXT} ;;   # Unknown
  esac

  # --- Moon Phase Icon Mapping ---
  case "$MOON_PHASE" in
    "New Moon") MOON_ICON="" ;;        # e38d
    "Full Moon") MOON_ICON="" ;;       # e39b
    "First Quarter") MOON_ICON="" ;;    # e394
    "Last Quarter") MOON_ICON="" ;;     # e3a2
    "Waxing Crescent")
      if [ "$MOON_ILLUM" -lt 8 ]; then MOON_ICON=""      # e38e
      elif [ "$MOON_ILLUM" -lt 16 ]; then MOON_ICON=""    # e38f
      elif [ "$MOON_ILLUM" -lt 24 ]; then MOON_ICON=""    # e390
      elif [ "$MOON_ILLUM" -lt 32 ]; then MOON_ICON=""    # e391
      elif [ "$MOON_ILLUM" -lt 40 ]; then MOON_ICON=""    # e392
      else MOON_ICON=""                                  # e393
      fi ;;
    "Waxing Gibbous")
      if [ "$MOON_ILLUM" -lt 58 ]; then MOON_ICON=""      # e395
      elif [ "$MOON_ILLUM" -lt 66 ]; then MOON_ICON=""    # e396
      elif [ "$MOON_ILLUM" -lt 74 ]; then MOON_ICON=""    # e397
      elif [ "$MOON_ILLUM" -lt 82 ]; then MOON_ICON=""    # e398
      elif [ "$MOON_ILLUM" -lt 90 ]; then MOON_ICON=""    # e399
      else MOON_ICON=""                                  # e39a
      fi ;;
    "Waning Gibbous")
      if [ "$MOON_ILLUM" -gt 92 ]; then MOON_ICON=""      # e39c
      elif [ "$MOON_ILLUM" -gt 84 ]; then MOON_ICON=""    # e39d
      elif [ "$MOON_ILLUM" -gt 76 ]; then MOON_ICON=""    # e39e
      elif [ "$MOON_ILLUM" -gt 68 ]; then MOON_ICON=""    # e39f
      elif [ "$MOON_ILLUM" -gt 60 ]; then MOON_ICON=""    # e3a0
      else MOON_ICON=""                                  # e3a1
      fi ;;
    "Waning Crescent")
      if [ "$MOON_ILLUM" -gt 42 ]; then MOON_ICON=""      # e3a3
      elif [ "$MOON_ILLUM" -gt 34 ]; then MOON_ICON=""    # e3a4
      elif [ "$MOON_ILLUM" -gt 26 ]; then MOON_ICON=""    # e3a5
      elif [ "$MOON_ILLUM" -gt 18 ]; then MOON_ICON=""    # e3a6
      elif [ "$MOON_ILLUM" -gt 10 ]; then MOON_ICON=""    # e3a7
      else MOON_ICON=""                                  # e3a8
      fi ;;
    *) MOON_ICON="" ;;
  esac

  # --- Moon Illumination Color ---
  if [ "$MOON_ILLUM" -ge 90 ]; then
    MOON_ALPHA="ff"
  elif [ "$MOON_ILLUM" -ge 80 ]; then
    MOON_ALPHA="ee"
  elif [ "$MOON_ILLUM" -ge 70 ]; then
    MOON_ALPHA="dd"
  elif [ "$MOON_ILLUM" -ge 60 ]; then
    MOON_ALPHA="cc"
  elif [ "$MOON_ILLUM" -ge 50 ]; then
    MOON_ALPHA="bb"
  elif [ "$MOON_ILLUM" -ge 40 ]; then
    MOON_ALPHA="aa"
  elif [ "$MOON_ILLUM" -ge 30 ]; then
    MOON_ALPHA="99"
  elif [ "$MOON_ILLUM" -ge 20 ]; then
    MOON_ALPHA="88"
  elif [ "$MOON_ILLUM" -ge 10 ]; then
    MOON_ALPHA="77"
  else
    MOON_ALPHA="66"
  fi
  MOON_COLOR="0x${MOON_ALPHA}${YELLOW}"

  # Update the main bar item
  sketchybar --set "$NAME" icon="$ICON" label="${TEMPERATURE}°C" icon.color="$COLOR"

  # Standardize all detail labels to be aligned without a colon using printf %-12s
  SUNRISE_LABEL=$(printf "%-12s  %s" "Sunrise" "${SUNRISE}")
  SUNSET_LABEL=$(printf "%-12s  %s" "Sunset" "${SUNSET}")
  DETAILS_LABEL=$(printf "%-12s  %s" "Feels like" "${FEELS_LIKE}°C")
  UV_LABEL=$(printf "%-12s  %s" "UV Index" "${UV_INDEX}")
  HUMIDITY_LABEL=$(printf "%-12s  %s" "Humidity" "${HUMIDITY}%")
  RAIN_LABEL=$(printf "%-12s  %s" "Rain chance" "${RAIN_CHANCE}%")
  WIND_LABEL=$(printf "%-12s  %s" "Wind" "${WIND} km/h")

  # Update the popup details
  sketchybar --set weather.location label="${LOCATION}" \
             --set weather.sunrise label="${SUNRISE_LABEL}" \
             --set weather.sunset label="${SUNSET_LABEL}" \
             --set weather.moon icon="$MOON_ICON" icon.color="$MOON_COLOR" label="${MOON_PHASE} (${MOON_ILLUM}%)" \
             --set weather.condition icon="$ICON" icon.color="$COLOR" label="${CONDITION}" \
             --set weather.details label="${DETAILS_LABEL}" \
             --set weather.uv icon.color="$UV_COLOR" label="${UV_LABEL}" \
             --set weather.humidity label="${HUMIDITY_LABEL}" \
             --set weather.rain icon.color="$RAIN_COLOR" label="${RAIN_LABEL}" \
             --set weather.wind label="${WIND_LABEL}"
}

if [ "$SENDER" = "mouse.clicked" ]; then
  # Update the main bar item
  sketchybar --set "$NAME" label=""

  SUNRISE_LOAD=$(printf "%-12s  %s" "Sunrise" "")
  SUNSET_LOAD=$(printf "%-12s  %s" "Sunset" "")
  DETAILS_LOAD=$(printf "%-12s  %s" "Feels like" "")
  UV_LOAD=$(printf "%-12s  %s" "UV Index" "")
  HUMIDITY_LOAD=$(printf "%-12s  %s" "Humidity" "")
  RAIN_LOAD=$(printf "%-12s  %s" "Rain chance" "")
  WIND_LOAD=$(printf "%-12s  %s" "Wind" "")

  # Update the popup details
  sketchybar --set weather.location label="" \
             --set weather.sunrise label="${SUNRISE_LOAD}" \
             --set weather.sunset label="${SUNSET_LOAD}" \
             --set weather.moon label="" \
             --set weather.condition label="" \
             --set weather.details label="${DETAILS_LOAD}" \
             --set weather.uv label="${UV_LOAD}" \
             --set weather.humidity label="${HUMIDITY_LOAD}" \
             --set weather.rain label="${RAIN_LOAD}" \
             --set weather.wind label="${WIND_LOAD}"
  render_bar
elif [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
else
  render_bar
fi
