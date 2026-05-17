#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"

# File to store the current mode
STATE_FILE="/tmp/sketchybar_finance_mode_${NAME:-finance}"

# Fallback for Alpha if not defined in colors.sh
ALPHA="${ALPHA_ITEM:-0xff}"

# Helper to process label and color
process_item() {
  local data="$1"
  local prefix="$2"
  local suffix="$3"
  
  if [ "$data" = "" ] || [ -z "$data" ]; then
    echo "|${ALPHA}${TEXT}"
    return
  fi

  local price=$(echo "$data" | cut -d'|' -f1)
  local change=$(echo "$data" | cut -d'|' -f2)
  
  local label="${prefix}${price}${suffix}"
  local color="${ALPHA}${TEXT}"
  
  # Only show change if it's not zero
  if [ -n "$change" ] && [ "$(echo "$change != 0" | bc -l)" -eq 1 ]; then
    local abs_change=$(echo "$change" | sed 's/-//')
    local f_change=$(printf "%.2f" "$abs_change")
    label="$label $f_change%"
    if [ "$(echo "$change > 0" | bc -l)" -eq 1 ]; then
      color="${ALPHA}${GREEN}"
    else
      color="${ALPHA}${RED}"
    fi
  fi
  echo "$label|$color"
}

format_number() {
  echo "$1" | rev | sed 's/\([0-9]\{3\}\)/\1./g' | rev | sed 's/^\.//'
}

fetch_btc() {
  local response=$(curl -s --connect-timeout 2 --max-time 5 "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true")
  local btc_price=$(echo "$response" | jq -r '.bitcoin.usd // empty')
  local btc_change=$(echo "$response" | jq -r '.bitcoin.usd_24h_change // empty')
  
  if [ -z "$btc_price" ]; then
    echo ""
  else
    local formatted_price=$(format_number "$btc_price")
    echo "\$$formatted_price|$btc_change"
  fi
}

fetch_usdidr_rate() {
  local yesterday=$(date -v-1d +%Y-%m-%d)
  local resp_today=$(curl -s --connect-timeout 2 --max-time 5 "https://api.frankfurter.dev/v1/latest?base=USD&symbols=IDR")
  local resp_yest=$(curl -s --connect-timeout 2 --max-time 5 "https://api.frankfurter.dev/v1/$yesterday?base=USD&symbols=IDR")
  
  local rate_today=$(echo "$resp_today" | jq -r '.rates.IDR // empty')
  local rate_yest=$(echo "$resp_yest" | jq -r '.rates.IDR // empty')
  
  if [ -n "$rate_today" ] && [ -n "$rate_yest" ]; then
    local change=$(echo "($rate_today - $rate_yest) / $rate_yest * 100" | bc -l)
    echo "$rate_today|$change"
  elif [ -n "$rate_today" ]; then
    echo "$rate_today|0.00"
  else
    echo ""
  fi
}

fetch_xau_usd() {
  local resp_paxg=$(curl -s --connect-timeout 2 --max-time 5 "https://api.coingecko.com/api/v3/simple/price?ids=pax-gold&vs_currencies=usd&include_24hr_change=true")
  local paxg_change=$(echo "$resp_paxg" | jq -r '."pax-gold".usd_24h_change // 0.00')
  
  local xau_price=$(curl -s --connect-timeout 2 --max-time 5 "https://api.gold-api.com/price/XAU" | jq -r '.price // empty')
  
  if [ -n "$xau_price" ]; then
    echo "$xau_price|$paxg_change"
  else
    echo ""
  fi
}

render_bar() {
  if [ ! -f "$STATE_FILE" ]; then
    echo "btc" > "$STATE_FILE"
  fi
  MODE=$(cat "$STATE_FILE")

  # 1. Fetch all data
  BTC_DATA=$(fetch_btc)
  USDIDR_DATA=$(fetch_usdidr_rate)
  XAU_DATA=$(fetch_xau_usd)

  # Extract USDIDR rate for XAU calculation
  USDIDR_RATE=$(echo "$USDIDR_DATA" | cut -d'|' -f1)

  # 2. Process each asset
  # BTC
  BTC_RES=$(process_item "$BTC_DATA" "" "")
  BTC_VAL=$(echo "$BTC_RES" | cut -d'|' -f1)
  BTC_LCOLOR=$(echo "$BTC_RES" | cut -d'|' -f2)

  # USD/IDR
  if [ -n "$USDIDR_RATE" ]; then
    USDIDR_INT=$(printf "%.0f" "$USDIDR_RATE")
    USDIDR_FORMATTED=$(format_number "$USDIDR_INT")
    USDIDR_CHANGE=$(echo "$USDIDR_DATA" | cut -d'|' -f2)
    USDIDR_RES=$(process_item "Rp $USDIDR_FORMATTED|$USDIDR_CHANGE" "" "")
  else
    USDIDR_RES="|${ALPHA}${TEXT}"
  fi
  USDIDR_VAL=$(echo "$USDIDR_RES" | cut -d'|' -f1)
  USDIDR_LCOLOR=$(echo "$USDIDR_RES" | cut -d'|' -f2)

  # XAU/IDR
  if [ -n "$XAU_DATA" ] && [ -n "$USDIDR_RATE" ]; then
    XAU_PRICE=$(echo "$XAU_DATA" | cut -d'|' -f1)
    XAU_CHANGE=$(echo "$XAU_DATA" | cut -d'|' -f2)
    # 1 troy oz = 31.1035 grams
    XAUIDR_PER_GRAM=$(echo "$XAU_PRICE * $USDIDR_RATE / 31.1035" | bc -l)
    XAUIDR_INT=$(printf "%.0f" "$XAUIDR_PER_GRAM")
    XAUIDR_FORMATTED=$(format_number "$XAUIDR_INT")
    XAUIDR_RES=$(process_item "Rp $XAUIDR_FORMATTED/g|$XAU_CHANGE" "" "")
  else
    XAUIDR_RES="|${ALPHA}${TEXT}"
  fi
  XAUIDR_VAL=$(echo "$XAUIDR_RES" | cut -d'|' -f1)
  XAUIDR_LCOLOR=$(echo "$XAUIDR_RES" | cut -d'|' -f2)

  # Icons and Colors
  ICON_BTC=""; COLOR_BTC="${ALPHA}${YELLOW}"
  ICON_XAU="󱉏"; COLOR_XAU="${ALPHA}${YELLOW}"
  ICON_USD=""; COLOR_USD="${ALPHA}${GREEN}"

  # 4. Define Labels, Icons and Colors based on mode
  case "$MODE" in
    "xau")
      MAIN_ICON="$ICON_XAU"; MAIN_COLOR="$COLOR_XAU"; MAIN_LABEL="$XAUIDR_VAL"; MAIN_LCOLOR="$XAUIDR_LCOLOR"
      POPUP_1_ICON="$ICON_BTC"; POPUP_1_COLOR="$COLOR_BTC"; POPUP_1_LABEL="BTCUSD: $BTC_VAL"; POPUP_1_LCOLOR="$BTC_LCOLOR"
      POPUP_2_ICON="$ICON_USD"; POPUP_2_COLOR="$COLOR_USD"; POPUP_2_LABEL="USDIDR: $USDIDR_VAL"; POPUP_2_LCOLOR="$USDIDR_LCOLOR"
      ;;
    "usd")
      MAIN_ICON="$ICON_USD"; MAIN_COLOR="$COLOR_USD"; MAIN_LABEL="$USDIDR_VAL"; MAIN_LCOLOR="$USDIDR_LCOLOR"
      POPUP_1_ICON="$ICON_BTC"; POPUP_1_COLOR="$COLOR_BTC"; POPUP_1_LABEL="BTCUSD: $BTC_VAL"; POPUP_1_LCOLOR="$BTC_LCOLOR"
      POPUP_2_ICON="$ICON_XAU"; POPUP_2_COLOR="$COLOR_XAU"; POPUP_2_LABEL="XAUIDRG: $XAUIDR_VAL"; POPUP_2_LCOLOR="$XAUIDR_LCOLOR"
      ;;
    *) # btc
      MAIN_ICON="$ICON_BTC"; MAIN_COLOR="$COLOR_BTC"; MAIN_LABEL="$BTC_VAL"; MAIN_LCOLOR="$BTC_LCOLOR"
      POPUP_1_ICON="$ICON_USD"; POPUP_1_COLOR="$COLOR_USD"; POPUP_1_LABEL="USDIDR: $USDIDR_VAL"; POPUP_1_LCOLOR="$USDIDR_LCOLOR"
      POPUP_2_ICON="$ICON_XAU"; POPUP_2_COLOR="$COLOR_XAU"; POPUP_2_LABEL="XAUIDRG: $XAUIDR_VAL"; POPUP_2_LCOLOR="$XAUIDR_LCOLOR"
      ;;
  esac

  sketchybar --set "$NAME" icon="$MAIN_ICON" icon.color="$MAIN_COLOR" label="$MAIN_LABEL" label.color="$MAIN_LCOLOR" \
             --set finance.usdidr icon="$POPUP_1_ICON" icon.color="$POPUP_1_COLOR" label="$POPUP_1_LABEL" label.color="$POPUP_1_LCOLOR" \
             --set finance.xauidr icon="$POPUP_2_ICON" icon.color="$POPUP_2_COLOR" label="$POPUP_2_LABEL" label.color="$POPUP_2_LCOLOR"
}

case "$SENDER" in
  "mouse.clicked")
    if [ ! -f "$STATE_FILE" ]; then
      CURRENT_MODE="btc"
    else
      CURRENT_MODE=$(cat "$STATE_FILE")
    fi

    case "$CURRENT_MODE" in
      "btc") NEXT_MODE="xau" ;;
      "xau") NEXT_MODE="usd" ;;
      "usd") NEXT_MODE="btc" ;;
      *)     NEXT_MODE="btc" ;;
    esac

    echo "$NEXT_MODE" > "$STATE_FILE"

    sketchybar --set "$NAME" label="" label.color="${ALPHA}${TEXT}" \
               --set finance.usdidr label="" label.color="${ALPHA}${TEXT}" \
               --set finance.xauidr label="" label.color="${ALPHA}${TEXT}"
    render_bar
    ;;
  "mouse.entered")
    sketchybar --set "$NAME" popup.drawing=on
    ;;
  "mouse.exited")
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  *)
    render_bar
    ;;
esac
