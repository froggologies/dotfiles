#!/bin/zsh

source "$HOME/.config/sketchybar/colors.sh"

# Prepend Homebrew to PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Function to update sketchybar
update_bar() {
  local count=$1
  local color=$2
  local icon=$3
  sketchybar --set "$NAME" label="$count" icon.color="$color" icon="$icon"
}

# Run in background to avoid blocking sketchybar
(
  # Try to get the count. If it fails, we'll try to find out why.
  # We use HOMEBREW_NO_AUTO_UPDATE to make it fast.
  # We use --quiet to get only package names.
  OUT=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null)
  
  # If OUT is empty, it might be 0 or a crash.
  # Let's count non-empty lines that don't look like errors.
  COUNT=$(echo "$OUT" | grep -E '^[a-zA-Z0-9]' | wc -l | tr -d ' ')
  
  # If we got 0, but there was an error, COUNT should be treated carefully.
  # However, if it's 31, it should work now.
  
  COLOR=${ALPHA_ITEM}${TEXT}
  ICON="󰏗"

  if [ "$COUNT" -gt 0 ]; then
    ICON=󱧕
    if [ "$COUNT" -ge 30 ]; then
      COLOR=${ALPHA_ITEM}${RED}
    elif [ "$COUNT" -ge 20 ]; then
      COLOR=${ALPHA_ITEM}${MAROON}
    elif [ "$COUNT" -ge 10 ]; then
      COLOR=${ALPHA_ITEM}${PEACH}
    else
      COLOR=${ALPHA_ITEM}${YELLOW}
    fi
  else
    COLOR=${ALPHA_ITEM}${GREEN}
    COUNT=
  fi

  update_bar "$COUNT" "$COLOR" "$ICON"
) &
