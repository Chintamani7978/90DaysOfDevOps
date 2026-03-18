#!/bin/bash

check_disk() {
  echo "Disk Usage:"
  df -h /
  echo
}

check_memory() {
  echo "Memory Usage:"
  free -h
  echo
}

main() {
  check_disk
  check_memory
}

main
