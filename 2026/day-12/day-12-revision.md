### Day 12 – Revision & Consolidation (Days 01–11)

#  Objective
Day 12 was kept as a breather day to revise and consolidate everything learned from Days 01 to 11 of the **90 Days of DevOps challenge by TrainWithShubham**.

The main goal was to strengthen Linux fundamentals, improve retention, and ensure clarity before moving forward.

---

# 1. Mindset & Learning Plan Review
I revisited my Day 01 learning plan to check if my goals and direction were still correct.

- Focus on strong Linux fundamentals  
- Learn through hands-on practice  
- Build troubleshooting mindset instead of memorizing commands  

No major changes were required. The focus going forward is consistency and regular revision.

---

# 2. Processes & Services Revision
Re-ran core process and service-related commands to refresh understanding.

## Commands Practiced
```bash
ps aux | head
systemctl status ssh
journalctl -u ssh -n 10
Observations
ps helps quickly identify running processes

systemctl status gives instant service health information

journalctl is the first place to check when services behave unexpectedly
```

---

# 3. File & Permission Skills Revision
Re-ran


Commands Practiced
```bash

mkdir test-dir
echo "Revision test" >> test.txt
ls -l test.txt
chmod 644 test.txt
```
Observations
Permission changes should always be verified using ls -l

Understanding read, write, and execute permissions is critical for system safety

# 4. Ownership & User/Group Sanity Check
Recreated a simple ownership scenario from earlier days.

Commands Practiced
```bash
id tokyo
ls -l test.txt
sudo chown tokyo:developers test.txt
```
Observations
Ownership issues are a common cause of access problems

Always verify user and group before applying chown

# 5. Cheat Sheet – Top 5 Commands I Reach for First
```bash
ls -l – check permissions and ownership


systemctl status <service> – check service health

journalctl -u <service> – analyze service logs

ps aux – troubleshoot running processes

chmod / chown – fix permission and ownership issues
```

---

# 6. Self-Check
Mini Self-Check
1. Top 3 Time-Saving Commands
ls -l – instant visibility of permissions

systemctl status – quick service check

journalctl – identifies real cause of failures

2. Service Health Check Flow
systemctl status <service>
journalctl -u <service> -n 20
ps aux | grep <service>
3. Safe Ownership & Permission Change Example
sudo chown user:group filename
chmod 640 filename


### Thanks for giving your time for reading this 