#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  case "$INFO" in
    "Vivaldi")
      ICON=""
      COLOR=${ALPHA_ITEM}${RED}
      ;;
    "Google Chrome")
      ICON=""
      COLOR=${ALPHA_ITEM}${YELLOW}
      ;;
    "Safari")
      ICON=""
      COLOR=${ALPHA_ITEM}${SAPPHIRE}
      ;;
    "Firefox")
      ICON=""
      COLOR=${ALPHA_ITEM}${PEACH}
      ;;
    "Code" | "Cursor" | "Antigravity IDE")
      ICON="󰨞"
      COLOR=${ALPHA_ITEM}${BLUE}
      ;;
    "Sublime Text" | "IntelliJ IDEA" | "Zed")
      ICON=""
      COLOR=${ALPHA_ITEM}${BLUE}
      ;;
    "iTerm2" | "Alacritty" | "Kitty" | "Terminal" | "Warp" | "Kiro CLI")
      ICON="󰞷"
      COLOR=${ALPHA_ITEM}${GREEN}
      ;;
    "Ghostty")
      ICON=""
      COLOR=${ALPHA_ITEM}${SAPPHIRE}
      ;;
    "Gemini" | "ChatGPT" | "Antigravity")
      ICON="󰫢"
      COLOR=${ALPHA_ITEM}${SKY}
      ;;
    "Slack" | "Discord" | "Telegram" | "WhatsApp" | "Messenger")
      ICON="󰭹"
      COLOR=${ALPHA_ITEM}${LAVENDER}
      ;;
    "Spotify" | "Music")
      ICON="󰓇"
      COLOR=${ALPHA_ITEM}${GREEN}
      ;;
    "Finder")
      ICON="󰀶"
      COLOR=${ALPHA_ITEM}${BLUE}
      ;;
    "System Settings")
      ICON="󰒓"
      COLOR=${ALPHA_ITEM}${OVERLAY2}
      ;;
    "Calendar")
      ICON="󰃭"
      COLOR=${ALPHA_ITEM}${RED}
      ;;
    "Notion" | "Obsidian" | "Notes")
      ICON="󱓧"
      COLOR=${ALPHA_ITEM}${FLAMINGO}
      ;;
    "App Store")
      ICON="󰗚"
      COLOR=${ALPHA_ITEM}${SAPPHIRE}
      ;;
    "Mail" | "Outlook")
      ICON="󰇮"
      COLOR=${ALPHA_ITEM}${SAPPHIRE}
      ;;
    "Shottr")
      ICON=""
      COLOR=${ALPHA_ITEM}${PEACH}
      ;;
    *)
      ICON="󰣆"
      COLOR=${ALPHA_ITEM}${TEXT}
      ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$INFO"
fi
