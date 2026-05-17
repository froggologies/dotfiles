#include "cpu.h"
#include "ram.h"
#include "disk.h"
#include "clock.h"
#include "calendar.h"
#include "sketchybar.h"

struct cpu g_cpu;
struct ram g_ram;
struct disk g_disk;
struct clock_state g_clock;
struct calendar_state g_calendar;

void handler(env env) {
  char* name = env_get_value_for_key(env, "NAME");
  char* sender = env_get_value_for_key(env, "SENDER");

  if (strcmp(sender, "mouse.entered") == 0) {
    if (strcmp(name, "calendar") == 0) {
      calendar_draw_popup();
    } else {
      char cmd[128];
      snprintf(cmd, sizeof(cmd), "--set %s popup.drawing=on", name);
      sketchybar(cmd);
    }
  } else if (strcmp(sender, "mouse.exited") == 0) {
    char cmd[128];
    snprintf(cmd, sizeof(cmd), "--set %s popup.drawing=off", name);
    sketchybar(cmd);
  } else if (strcmp(sender, "mouse.clicked") == 0) {
    if (strcmp(name, "clock") == 0) {
      time_t rawtime;
      struct tm timeinfo;
      time(&rawtime);
      localtime_r(&rawtime, &timeinfo);
      char date_str[64];
      strftime(date_str, sizeof(date_str), "%Y-%m-%dT%H:%M:%S%z", &timeinfo);
      
      FILE* pbcopy = popen("pbcopy", "w");
      if (pbcopy) {
        fputs(date_str, pbcopy);
        pclose(pbcopy);
      }
      
      char cmd[128];
      char* env_yellow = getenv("YELLOW");
      snprintf(cmd, sizeof(cmd), "--set clock label.color=0xff%s", env_yellow ? env_yellow : "f9e2af");
      sketchybar(cmd);

      char* env_text = getenv("TEXT");
      char text_color[32];
      snprintf(text_color, sizeof(text_color), "0xff%s", env_text ? env_text : "cdd6f4");

      char reset_cmd[256];
      snprintf(reset_cmd, sizeof(reset_cmd), "(sleep 1 && sketchybar --set clock label.color=%s) &", text_color);
      system(reset_cmd);
    } else if (strcmp(name, "calendar") == 0) {
      time_t rawtime;
      time(&rawtime);
      char* date_str = ctime(&rawtime);
      if (date_str) {
        size_t len = strlen(date_str);
        if (len > 0 && date_str[len - 1] == '\n') {
          date_str[len - 1] = '\0';
        }
        FILE* pbcopy = popen("pbcopy", "w");
        if (pbcopy) {
          fputs(date_str, pbcopy);
          pclose(pbcopy);
        }
      }
      
      char cmd[128];
      char* env_yellow = getenv("YELLOW");
      snprintf(cmd, sizeof(cmd), "--set calendar label.color=0xff%s", env_yellow ? env_yellow : "f9e2af");
      sketchybar(cmd);

      char* env_text = getenv("TEXT");
      char text_color[32];
      snprintf(text_color, sizeof(text_color), "0xff%s", env_text ? env_text : "cdd6f4");

      char reset_cmd[256];
      snprintf(reset_cmd, sizeof(reset_cmd), "(sleep 1 && sketchybar --set calendar label.color=%s) &", text_color);
      system(reset_cmd);
    }
  } else if (strcmp(sender, "routine") == 0 || strcmp(sender, "forced") == 0) {
    if (strcmp(name, "cpu") == 0) {
      cpu_update(&g_cpu);
      if (strlen(g_cpu.command) > 0) sketchybar(g_cpu.command);
    } else if (strcmp(name, "ram") == 0) {
      ram_update(&g_ram);
      if (strlen(g_ram.command) > 0) sketchybar(g_ram.command);
    } else if (strcmp(name, "disk") == 0) {
      disk_update(&g_disk);
      if (strlen(g_disk.command) > 0) sketchybar(g_disk.command);
    } else if (strcmp(name, "clock") == 0) {
      clock_update(&g_clock);
      if (strlen(g_clock.command) > 0) sketchybar(g_clock.command);
    } else if (strcmp(name, "calendar") == 0) {
      calendar_update(&g_calendar);
      if (strlen(g_calendar.command) > 0) sketchybar(g_calendar.command);
    }
  }
}

int main (int argc, char** argv) {
  cpu_init(&g_cpu);
  ram_init(&g_ram);
  disk_init(&g_disk);
  clock_init(&g_clock);
  calendar_init(&g_calendar);

  if (argc < 2) {
    printf("Usage: provider \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
