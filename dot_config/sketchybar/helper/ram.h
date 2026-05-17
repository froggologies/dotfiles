#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <sys/sysctl.h>
#include <stdbool.h>

static const char TOPMEM[32] = { "/bin/ps -Aceo pid,pmem,comm -m" };
static const char RAM_FILTER_PATTERN[16] = { "com.apple." };

struct ram {
  char command[512];
};

static inline void ram_init(struct ram* ram) {
  snprintf(ram->command, sizeof(ram->command), "");
}

static inline void parse_ram_line(const char* line, char* out, size_t out_len) {
  char* start = strstr(line, RAM_FILTER_PATTERN);
  uint32_t caret = 0;
  for (int i = 0; line[i] != '\0'; i++) {
    if (start && i == start - line) {
      i += 9;
      continue;
    }

    if (caret >= out_len - 4 && caret <= out_len - 2) {
      out[caret++] = '.';
      continue;
    }
    if (caret > out_len - 2) break;
    out[caret++] = line[i];
  }
  out[caret] = '\0';
  
  for (int i = (int)caret - 1; i >= 0; i--) {
    if (out[i] == '\n' || out[i] == '\r' || out[i] == ' ') {
      out[i] = '\0';
    } else {
      break;
    }
  }
}

static inline void ram_update(struct ram* ram) {
  int64_t total_ram = 0;
  size_t len = sizeof(total_ram);
  sysctlbyname("hw.memsize", &total_ram, &len, NULL, 0);

  mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
  vm_statistics64_data_t vm_stats;
  if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vm_stats, &count) == KERN_SUCCESS) {
    vm_size_t page_size;
    host_page_size(mach_host_self(), &page_size);

    uint64_t active = vm_stats.active_count * (uint64_t)page_size;
    uint64_t wired = vm_stats.wire_count * (uint64_t)page_size;
    uint64_t compressed = vm_stats.compressor_page_count * (uint64_t)page_size;
    uint64_t free = vm_stats.free_count * (uint64_t)page_size;
    uint64_t inactive = vm_stats.inactive_count * (uint64_t)page_size;
    
    uint64_t used = active + wired + compressed;
    uint64_t total_computed = used + free + inactive;
    if (total_computed == 0) total_computed = total_ram;

    double used_perc = (double)used / (double)total_computed;

    FILE* file;
    char line[1024] = {0};
    char topmem1[32] = {0};
    char topmem2[32] = {0};
    char topmem3[32] = {0};

    file = popen(TOPMEM, "r");
    if (!file) {
      printf("Error: TOPMEM command errored out...\n" );
      return;
    }

    // Skip header line
    fgets(line, sizeof(line), file);

    // Read top 1
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topmem1, 32, "None");
    } else {
      parse_ram_line(line, topmem1, sizeof(topmem1));
    }

    // Read top 2
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topmem2, 32, "None");
    } else {
      parse_ram_line(line, topmem2, sizeof(topmem2));
    }

    // Read top 3
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topmem3, 32, "None");
    } else {
      parse_ram_line(line, topmem3, sizeof(topmem3));
    }

    pclose(file);

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

    snprintf(ram->command, sizeof(ram->command), 
             "--push ram.graph %.2f --push ram.graph %.2f "
             "--set ram.graph graph.color=%s graph.fill_color=%s "
             "--set ram label=\"%.0f%%\" icon.color=%s "
             "--set ram.details.1 label=\"%s\" "
             "--set ram.details.2 label=\"%s\" "
             "--set ram.details.3 label=\"%s\"",
             used_perc, used_perc, color, color, used_perc * 100.0, color, topmem1, topmem2, topmem3);
  } else {
    snprintf(ram->command, sizeof(ram->command), "");
  }
}
