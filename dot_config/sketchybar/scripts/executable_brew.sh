#!/bin/zsh

source "$HOME/.config/sketchybar/colors.sh"

# Prepend Homebrew to PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

render_bar() {
  # Try to get the count.
  OUT=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null)
  
  PACKAGES=$(echo "$OUT" | grep -E '^[a-zA-Z0-9]')
  COUNT=$(echo "$PACKAGES" | wc -l | tr -d ' ')
  
  COLOR=${ALPHA_ITEM}${TEXT}
  ICON="󰏗"

  if [ "$COUNT" -gt 0 ] && [ -n "$PACKAGES" ]; then
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
    PACKAGES=""
  fi

  # Update the main bar item
  sketchybar --set "$NAME" label="$COUNT" icon.color="$COLOR" icon="$ICON"

  # Remove existing dynamic items
  sketchybar --remove '/brew.package\..*/'

  if [ -n "$PACKAGES" ]; then
    # Update and show package slots, limit to 10
    local max_items=10
    local counter=0
    
    # We use a temporary array to build the command for better performance
    args=()
    
    while read -r line; do
      if [ -n "$line" ]; then
        if [ "$counter" -lt "$max_items" ]; then
          args+=(--add item "brew.package.$((counter + 1))" popup.brew)
          args+=(--set "brew.package.$((counter + 1))" \
                           label="$line")
        fi
        counter=$((counter + 1))
      fi
    done <<< "$PACKAGES"

    if [ "$counter" -gt "$max_items" ]; then
      local remaining=$((counter - max_items))
      args+=(--add item brew.package.more popup.brew)
      args+=(--set brew.package.more \
                 label="... and $remaining more.")
    fi
    
    if [ ${#args[@]} -gt 0 ]; then
      sketchybar "${args[@]}"
    fi
  fi
}

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set "$NAME" label=""
  sketchybar --remove '/brew.package\..*/'
  render_bar
elif [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
else
  render_bar
fi
