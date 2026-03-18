#!/bin/bash
set -euo pipefail

print_os_info() {
  echo "===== Hostname & OS Info ====="
  echo "Hostname: $(hostname)"
  echo "OS: $(uname -a)"
  echo
}

print_uptime() {
  echo "===== Uptime ====="
  uptime
  echo
}

print_disk_usage() {
  echo "===== Disk Usage (Top 5) ====="
  df -h | head -n 1
  df -h | sort -rh -k 5 | head -n 5
  echo
}

print_memory_usage() {
  echo "===== Memory Usage ====="
  free -h
  echo
}

print_top_cpu_processes() {
  echo "===== Top 5 CPU-Consuming Processes ====="
  ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
  echo
}

main() {
  print_os_info
  print_uptime
  print_disk_usage
  print_memory_usage
  print_top_cpu_processes
}

main
