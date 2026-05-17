#pragma once
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include "sketchybar.h"

struct calendar_state {
  char command[256];
};

static inline void calendar_init(struct calendar_state* cal) {
  snprintf(cal->command, sizeof(cal->command), "");
}

static inline void calendar_update(struct calendar_state* cal) {
  time_t rawtime;
  struct tm timeinfo;
  time(&rawtime);
  localtime_r(&rawtime, &timeinfo);

  char label_str[32];
  strftime(label_str, sizeof(label_str), "%a %d %b", &timeinfo);

  int wday = timeinfo.tm_wday; 
  char* env_var = NULL;
  char* default_hex = "cdd6f4";
  switch (wday) {
    case 0: env_var = getenv("MAROON"); default_hex = "eba0ac"; break; // Sunday
    case 1: env_var = getenv("SAPPHIRE"); default_hex = "74c7ec"; break; // Monday
    case 2: env_var = getenv("SKY"); default_hex = "89dceb"; break;      // Tuesday
    case 3: env_var = getenv("TEAL"); default_hex = "94e2d5"; break;     // Wednesday
    case 4: env_var = getenv("GREEN"); default_hex = "a6e3a1"; break;    // Thursday
    case 5: env_var = getenv("YELLOW"); default_hex = "f9e2af"; break;   // Friday
    case 6: env_var = getenv("PEACH"); default_hex = "fab387"; break;    // Saturday
  }

  char* env_text = getenv("TEXT");
  char text_color[32];
  snprintf(text_color, sizeof(text_color), "0xff%s", env_text ? env_text : "cdd6f4");

  snprintf(cal->command, sizeof(cal->command),
           "--set calendar label=\"%s\" label.color=%s icon.color=0xff%s",
           label_str, text_color, env_var ? env_var : default_hex);
}

static inline void calendar_draw_popup() {
  time_t rawtime;
  struct tm timeinfo;
  time(&rawtime);
  localtime_r(&rawtime, &timeinfo);

  char month_year[64];
  strftime(month_year, sizeof(month_year), "%B %Y", &timeinfo);

  // Clear old items and add new base items
  sketchybar("--remove \"/calendar\\..*/\"");
  sketchybar("--add item calendar.month popup.calendar "
             "--set calendar.month label.font=\"JetBrainsMono Nerd Font:Bold:14.0\" "
             "--add item calendar.weekdays popup.calendar "
             "--set calendar.weekdays label.font=\"JetBrainsMono Nerd Font:Semibold:12.0\"");

  char row_add_cmd[256] = "";
  for (int row = 1; row <= 6; row++) {
    char temp[64];
    snprintf(temp, sizeof(temp), "--add item calendar.row.%d popup.calendar ", row);
    strcat(row_add_cmd, temp);
  }
  sketchybar(row_add_cmd);

  sketchybar("--set calendar.weekdays label=\" SU  MO  TU  WE  TH  FR  SA \" width=212");
  
  char set_month_cmd[128];
  snprintf(set_month_cmd, sizeof(set_month_cmd), "--set calendar.month label=\"%s\"", month_year);
  sketchybar(set_month_cmd);

  struct tm first_day = timeinfo;
  first_day.tm_mday = 1;
  first_day.tm_hour = 12; // Avoid daylight saving shifts
  first_day.tm_min = 0;
  first_day.tm_sec = 0;
  mktime(&first_day);
  int first_day_wday = first_day.tm_wday;

  // Day colors for dynamic color row
  int today_wday = timeinfo.tm_wday;
  char* env_var = NULL;
  char* default_hex = "cdd6f4";
  switch (today_wday) {
    case 0: env_var = getenv("MAROON"); default_hex = "eba0ac"; break;
    case 1: env_var = getenv("SAPPHIRE"); default_hex = "74c7ec"; break;
    case 2: env_var = getenv("SKY"); default_hex = "89dceb"; break;
    case 3: env_var = getenv("TEAL"); default_hex = "94e2d5"; break;
    case 4: env_var = getenv("GREEN"); default_hex = "a6e3a1"; break;
    case 5: env_var = getenv("YELLOW"); default_hex = "f9e2af"; break;
    case 6: env_var = getenv("PEACH"); default_hex = "fab387"; break;
  }
  char current_day_color[32];
  snprintf(current_day_color, sizeof(current_day_color), "0xff%s", env_var ? env_var : default_hex);

  char* env_text = getenv("TEXT");
  char text_color[32];
  snprintf(text_color, sizeof(text_color), "0xff%s", env_text ? env_text : "cdd6f4");

  for (int row = 1; row <= 6; row++) {
    char row_label[128] = "";
    int is_current_week = 0;

    for (int col = 0; col < 7; col++) {
      int idx = (row - 1) * 7 + col;
      
      struct tm slot_time = first_day;
      slot_time.tm_mday = 1 + (idx - first_day_wday);
      mktime(&slot_time);

      char item_text[16];
      if (slot_time.tm_mon == timeinfo.tm_mon && slot_time.tm_mday == timeinfo.tm_mday) {
        snprintf(item_text, sizeof(item_text), "%2d ", slot_time.tm_mday);
        is_current_week = 1;
      } else {
        snprintf(item_text, sizeof(item_text), " %2d ", slot_time.tm_mday);
      }
      strcat(row_label, item_text);
    }

    char* row_color = is_current_week ? current_day_color : text_color;

    char set_row_cmd[256];
    snprintf(set_row_cmd, sizeof(set_row_cmd), 
             "--set calendar.row.%d label=\"%s \" label.color=%s width=212", 
             row, row_label, row_color);
    sketchybar(set_row_cmd);
  }

  sketchybar("--set calendar popup.drawing=on");
}
