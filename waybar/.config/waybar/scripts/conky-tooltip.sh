#!/usr/bin/env bash
set -euo pipefail

ICON=""
CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-conky-cpu.cache"

critical_any=0
colorized=""

json_escape() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  printf '%s' "$s"
}

colorize_percent() {
  local val="${1:-}"
  local num

  if [ -z "$val" ]; then
    colorized="?"
    return 0
  fi

  num=$(printf '%s' "$val" | awk -F. '{print $1}')
  if ! [[ "$num" =~ ^[0-9]+$ ]]; then
    colorized="${val}%"
    return 0
  fi

  if [ "$num" -ge 90 ]; then
    critical_any=1
    colorized="<span foreground=\"#ff4040\">${val}%</span>"
  elif [ "$num" -ge 75 ]; then
    colorized="<span foreground=\"#ff8c00\">${val}%</span>"
  else
    colorized="${val}%"
  fi
}

detect_power_mode() {
  local mode=""

  if command -v powerprofilesctl >/dev/null 2>&1; then
    mode=$(powerprofilesctl get 2>/dev/null || true)
  fi

  if [ -z "$mode" ] && [ -r /sys/firmware/acpi/platform_profile ]; then
    mode=$(tr '[:upper:]' '[:lower:]' < /sys/firmware/acpi/platform_profile | tr -d '[:space:]')
  fi

  case "$mode" in
    power-saver|powersave|low-power)
      printf '%s' "powersave"
      ;;
    performance)
      printf '%s' "performance"
      ;;
    balanced)
      printf '%s' "balanced"
      ;;
    *)
      printf '%s' "unknown"
      ;;
  esac
}

colorize_power_mode() {
  local mode="${1:-unknown}"

  case "$mode" in
    powersave)
      colorized="<span foreground=\"#ffd54a\">powersave</span>"
      ;;
    performance)
      colorized="<span foreground=\"#4aa3ff\">performance</span>"
      ;;
    balanced)
      colorized="balanced"
      ;;
    *)
      colorized="unknown"
      ;;
  esac
}

# CPU % from /proc/stat using previous sample cache (no sleep needed).
cpu=0
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_all=$((idle + iowait))

if [ -f "$CACHE_FILE" ]; then
  read -r prev_total prev_idle < "$CACHE_FILE" || true
  delta_total=$((total - prev_total))
  delta_idle=$((idle_all - prev_idle))
  if [ "$delta_total" -gt 0 ]; then
    cpu=$(( (100 * (delta_total - delta_idle)) / delta_total ))
  fi
fi
printf '%s %s\n' "$total" "$idle_all" > "$CACHE_FILE"

# Memory % from /proc/meminfo.
mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
if [ -n "$mem_total" ] && [ "$mem_total" -gt 0 ]; then
  mem=$(( (100 * (mem_total - mem_avail)) / mem_total ))
else
  mem=0
fi

# Root disk usage %.
disk=$(df --output=pcent / | awk 'NR==2 {gsub(/%/,"",$1); print $1}')

# Uptime short (Xm Ys).
up_seconds=$(cut -d. -f1 /proc/uptime)
up_m=$((up_seconds / 60))
up_s=$((up_seconds % 60))
up="${up_m}m ${up_s}s"

colorize_percent "$cpu"
cpu_fmt="$colorized"
colorize_percent "$mem"
mem_fmt="$colorized"
colorize_percent "$disk"
disk_fmt="$colorized"

power_mode=$(detect_power_mode)
colorize_power_mode "$power_mode"
power_fmt="$colorized"

tooltip=$(printf 'CPU: %s  MEM: %s\nDisk: %s  Up: %s\nMode: %s' "$cpu_fmt" "$mem_fmt" "$disk_fmt" "$up" "$power_fmt")

classes=("$power_mode")
if [ "$critical_any" -eq 1 ]; then
  classes+=("critical")
fi

tooltip_json=$(json_escape "$tooltip")
if [ ${#classes[@]} -gt 0 ]; then
  printf '{"text":"%s","tooltip":"%s","class":[' "$ICON" "$tooltip_json"
  for i in "${!classes[@]}"; do
    if [ $i -gt 0 ]; then printf ','; fi
    printf '"%s"' "${classes[$i]}"
  done
  printf ']}\n'
else
  printf '{"text":"%s","tooltip":"%s"}\n' "$ICON" "$tooltip_json"
fi
