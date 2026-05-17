#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/param.h>
#include <sys/mount.h>

struct disk {
  char command[512];
};

static inline void disk_init(struct disk* disk) {
  snprintf(disk->command, sizeof(disk->command), "");
}

static inline void disk_update(struct disk* disk) {
  struct statfs stats;
  if (statfs("/", &stats) == 0) {
    uint64_t total = stats.f_blocks * stats.f_bsize;
    uint64_t free = stats.f_bavail * stats.f_bsize;
    uint64_t used = total - free;

    double used_perc = (double)used / (double)total;
    double used_gb = (double)used / (1024.0 * 1024.0 * 1024.0);
    double total_gb = (double)total / (1024.0 * 1024.0 * 1024.0);

    char color[16];
    char* env_green = getenv("GREEN");
    char* env_yellow = getenv("YELLOW");
    char* env_peach = getenv("PEACH");
    char* env_red = getenv("RED");

    if (used_perc >= 0.8) {
      snprintf(color, 16, "0xff%s", env_red ? env_red : "f38ba8");
    } else if (used_perc >= 0.6) {
      snprintf(color, 16, "0xff%s", env_peach ? env_peach : "fab387");
    } else if (used_perc >= 0.3) {
      snprintf(color, 16, "0xff%s", env_yellow ? env_yellow : "f9e2af");
    } else {
      snprintf(color, 16, "0xff%s", env_green ? env_green : "a6e3a1");
    }

    snprintf(disk->command, sizeof(disk->command), 
             "--push disk.graph %.2f --push disk.graph %.2f "
             "--set disk.graph graph.color=%s graph.fill_color=%s "
             "--set disk label=\"%.0f%%\" icon.color=%s "
             "--set disk.details label=\"Used: %.1f GB / %.1f GB\"",
             used_perc, used_perc, color, color, used_perc * 100.0, color, used_gb, total_gb);
  } else {
    snprintf(disk->command, sizeof(disk->command), "");
  }
}
