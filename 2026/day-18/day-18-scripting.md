# Day 18 – Shell Scripting: Functions & Strict Mode

Today is the day 18 of 90daysofdevops and  I worked with Bash functions, safe scripting patterns, and built a system monitoring script using everything I've learned so far.

---

## Scripts and Outputs

### 1. `functions.sh`

**Code:**
```bash
#!/bin/bash

greet() {
  echo "Hello, $1!"
}

add() {
  sum=$(( $1 + $2 ))
  echo "Sum is: $sum"
}

greet "Chintamani"
add 5 7
```
Output:
```bash
Hello, Chintamani!
Sum is: 12
```
2. disk_check.sh
Code:
```bash
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
```

main
Output Example:
```bash
Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   15G   35G  30% /

Memory Usage:
              total        used        free ...
Mem:            8G          3G         5G
```
3. strict_demo.sh
Code (tested one line at a time):
```bash
#!/bin/bash
set -euo pipefail

# echo "This will break: $UNDEFINED_VAR"
# ls /nonexistent
# false | grep something

echo "Script completed successfully"
```
Explanation of Flags:

set -e: Exit the script when any command fails

set -u: Exit if any variable is undefined

set -o pipefail: If any part of a pipeline fails, the whole pipeline fails

4. local_demo.sh
Code:
```bash
#!/bin/bash

name="Outside Function"

local_example() {
  local name="Inside Function"
  echo "Inside local_example: $name"
}

global_example() {
  name="Changed Outside"
  echo "Inside global_example: $name"
}

echo "Before local_example: $name"
local_example
echo "After local_example: $name"

echo "Before global_example: $name"
global_example
echo "After global_example: $name"
```
Output:
```bash
Before local_example: Outside Function
Inside local_example: Inside Function
After local_example: Outside Function
Before global_example: Outside Function
Inside global_example: Changed Outside
After global_example: Changed Outside
```
5. system_info.sh
Code:
```bash
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
```
