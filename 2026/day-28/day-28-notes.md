# Day 28 – Revision Day (Day 1 to Day 27)
Overview

Day 28 was focused entirely on revision and consolidation.

After covering DevOps fundamentals, Linux deep dives, shell scripting projects, Git workflows, GitHub CLI, and profile optimization, I paused to strengthen my understanding instead of moving forward with new topics.

The objective was to reinforce concepts, revisit important areas, and validate my practical knowledge.

Topics Revised
1️⃣ Linux Fundamentals

Revisited:

File system navigation and management

Process management (ps, top, kill)

Service management using systemctl

File permissions (chmod, chown, chgrp)

Linux file system hierarchy (/etc, /var, /home, /tmp)

Disk and memory troubleshooting (df, du, free)

User and group management

Key takeaway:
Confidence comes from repetition. Linux commands now feel more intuitive rather than memorized.

2️⃣ LVM (Logical Volume Manager)

Revised:

Physical Volume (PV)

Volume Group (VG)

Logical Volume (LV)

Creating and resizing logical volumes

Why LVM is more flexible than traditional partitions

Key takeaway:
LVM provides scalable and flexible storage management, making it ideal for production systems where resizing may be required.

3️⃣ Networking & DNS

Revisited:

IP addressing basics

DNS resolution process

Common ports (80, 443, 22, 3306)

Troubleshooting tools:
```bash
ping

curl

dig

nslookup

ss
```
Key takeaway:
Understanding networking fundamentals is essential for debugging real-world deployment issues.

4️⃣ Shell Scripting Concepts

Reinforced:

Loops (for, while)

Functions and local variables

Argument handling
```bash
set -euo pipefail for safer scripts
```
Text processing (grep, awk, sort, uniq)

Cron job scheduling

Key takeaway:
Production-ready scripts require proper error handling and predictable behavior.

5️⃣ Git & GitHub

Reviewed:

Branching and merging

Fast-forward vs merge commit

Rebase vs merge

Stash and cherry-pick

Reset vs revert

GitHub Flow vs GitFlow

GitHub CLI usage

Key takeaway:
Version control is not just about committing code — it is about maintaining clean, collaborative workflows.

Quick Concept Reinforcement
What does chmod 755 script.sh do?

Owner: read, write, execute

Group: read, execute

Others: read, execute

What does set -euo pipefail do?

-e → Exit on error

-u → Fail on undefined variables

pipefail → Fail if any command in a pipeline fails

Cron Example – Run Daily at 3 AM
```bash
0 3 * * * /path/to/script.sh
```
Reflection

Day 28 reinforced an important principle:

Learning builds exposure.
Practice builds skill.
Revision builds mastery.

This day helped solidify my understanding across Linux, scripting, networking, and Git workflows.

I now feel more structured and confident in the foundation built over the past 27 days.

Status

All previous days (1–27) are committed and pushed.
GitHub profile and repositories are organized and updated.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham