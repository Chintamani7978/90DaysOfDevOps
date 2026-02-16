# Day 20 – Log Analyzer and Report Generator

## Overview

Today’s challenge was to build a Bash script that analyzes log files and generates a structured daily summary report.

The goal was to simulate a real-world DevOps task where a system administrator processes logs to detect errors, critical events, and recurring issues.

---

# My Approach

## Step 1: Input Validation

Before processing anything, I ensured the script:

- Accepts a log file path as a command-line argument
- Exits with a proper usage message if no argument is passed
- Verifies that the provided file exists

This prevents the script from failing unexpectedly.

Example logic:

```bash
if [ $# -eq 0 ]; then
  echo "Usage: $0 <log_file_path>"
  exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
  echo "Error: File '$LOG_FILE' does not exist."
  exit 1
fi
```
Step 2: Counting Errors
To count errors, I searched for lines containing:

ERROR

Failed

I used:
```bash
grep -iE "ERROR|Failed" "$LOG_FILE" | wc -l
Explanation:

-i → case insensitive

-E → allows use of |

wc -l → counts matching lines
```
The result was stored in a variable for later use in the report.

Step 3: Identifying Critical Events
I extracted lines containing CRITICAL and printed them with line numbers using:
```bash
grep -n "CRITICAL" "$LOG_FILE"
To prevent the script from exiting when no matches are found (due to set -e), I used:

grep -n "CRITICAL" "$LOG_FILE" || true
Then handled empty output safely.

Step 4: Finding Top 5 Error Messages
To identify recurring issues:
```
Extracted lines containing ERROR

Removed timestamps using awk

Sorted them

Counted duplicates

Sorted in descending order

Displayed top 5

Pipeline used:
```bash
grep "ERROR" "$LOG_FILE" | \
awk '{$1=$2=$3=""; print}' | \
sort | uniq -c | sort -nr | head -5
Tools used:

grep

awk

sort

uniq

head
```
Step 5: Generating Summary Report
I generated a timestamped report file:
```bash
DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_$DATE.txt"
The report includes:

Date of analysis

Log file name

Total lines processed

Total error count

Top 5 error messages

Critical events

I redirected grouped output into the report file using:

{ ... } > "$REPORT_FILE"
Step 6: Archiving Processed Logs
To simulate production workflow:

Created an archive/ directory if it didn’t exist

Moved processed log file into it

mkdir -p archive
mv "$LOG_FILE" archive/
This prevents re-processing the same log.

Sample Output (Console)
----- Error Summary -----
Total errors found: 595

----- Critical Events -----
No critical events found.

----- Top 5 Error Messages -----
45 Connection timed out
32 File not found
28 Permission denied
Sample Generated Report
File created:

log_report_2026-02-16.txt
Contains:

Date

Log file name

Total lines

Total errors

Top 5 recurring errors

Critical events list

Commands and Tools Used
grep

awk

sort

uniq

wc

head

date

mkdir

mv

Bash conditionals

Strict mode (set -euo pipefail)

What I Learned
How to safely handle input validation in Bash scripts.
How to process structured log data using text-processing pipelines.
How to build a production-style reporting workflow with archiving and automation mindset.