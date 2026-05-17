#pragma once
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include "sketchybar.h"

struct clock_state {
  char command[256];
};

static inline void clock_init(struct clock_state* c) {
  snprintf(c->command, sizeof(c->command), "");
}

static inline void clock_update(struct clock_state* c) {
  time_t rawtime;
  struct tm timeinfo;
  time(&rawtime);
  localtime_r(&rawtime, &timeinfo);

  char time_str[32];
  // Format: "12:51:30 PM" (updating every second)
  strftime(time_str, sizeof(time_str), "%I:%M:%S %p", &timeinfo);

  char* color = "cdd6f4"; // Default TEXT
  char* env_yellow = getenv("YELLOW");
  char* env_blue = getenv("BLUE");

  // If AM, yellow. If PM, blue.
  if (timeinfo.tm_hour < 12) {
    color = env_yellow ? env_yellow : "f9e2af";
  } else {
    color = env_blue ? env_blue : "89b4fa";
  }

  char* env_text = getenv("TEXT");
  char text_color[32];
  snprintf(text_color, sizeof(text_color), "0xff%s", env_text ? env_text : "cdd6f4");

  snprintf(c->command, sizeof(c->command),
           "--set clock label=\"%s\" label.color=%s icon.color=0xff%s",
           time_str, text_color, color);
}
