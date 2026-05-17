#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>

static const char TOPPROC[32] = { "/bin/ps -Aceo pid,pcpu,comm -r" };
static const char FILTER_PATTERN[16] = { "com.apple." };

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;

  char command[512];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  snprintf(cpu->command, 100, "");
}

static inline void parse_line(const char* line, char* out, size_t out_len) {
  char* start = strstr(line, FILTER_PATTERN);
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

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    double user_perc = (double)delta_user / (double)(delta_system
                                                     + delta_user
                                                     + delta_idle);

    double sys_perc = (double)delta_system / (double)(delta_system
                                                       + delta_user
                                                       + delta_idle);

    double total_perc = user_perc + sys_perc;

    FILE* file;
    char line[1024] = {0};
    char topproc1[32] = {0};
    char topproc2[32] = {0};
    char topproc3[32] = {0};

    file = popen(TOPPROC, "r");
    if (!file) {
      printf("Error: TOPPROC command errored out...\n" );
      return;
    }

    // Skip header line
    fgets(line, sizeof(line), file);

    // Read top 1
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topproc1, 32, "None");
    } else {
      parse_line(line, topproc1, sizeof(topproc1));
    }

    // Read top 2
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topproc2, 32, "None");
    } else {
      parse_line(line, topproc2, sizeof(topproc2));
    }

    // Read top 3
    if (fgets(line, sizeof(line), file) == NULL) {
      snprintf(topproc3, 32, "None");
    } else {
      parse_line(line, topproc3, sizeof(topproc3));
    }

    pclose(file);

    char color[16];
    if (total_perc >= .7) {
      snprintf(color, 16, "%s", getenv("CPU_RED"));
    } else if (total_perc >= .3) {
      snprintf(color, 16, "%s", getenv("CPU_ORANGE"));
    } else if (total_perc >= .1) {
      snprintf(color, 16, "%s", getenv("CPU_YELLOW"));
    } else {
      snprintf(color, 16, "%s", getenv("CPU_LABEL_COLOR"));
    }

    snprintf(cpu->command, sizeof(cpu->command),
             "--push cpu.graph %.2f --push cpu.graph %.2f "
             "--set cpu.graph graph.color=%s graph.fill_color=%s "
             "--set cpu label=\"%.0f%%\" icon.color=%s "
             "--set cpu.details.1 label=\"%s\" "
             "--set cpu.details.2 label=\"%s\" "
             "--set cpu.details.3 label=\"%s\"",
             total_perc,
             total_perc,
             color,
             color,
             total_perc*100.,
             color,
             topproc1,
             topproc2,
             topproc3);
  }
  else {
    snprintf(cpu->command, sizeof(cpu->command), "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
