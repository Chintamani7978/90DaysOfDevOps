# Linux Commands Cheat Sheet – Day 03

## 90DaysOfDevOps
hii my name is chintamani mohanta a Btech 2nd year student in a University so with college studies with simultaniously . i hope by doing this i can land a internship this summer . 

This cheat sheet contains essential Linux commands used daily by DevOps engineers. Commands are grouped by category for quick troubleshooting and system inspection.

---

## 🔹 Process Management

- `ps` – Show running processes
- `ps aux` – Display all processes with detailed info
- `top` – Real-time process and CPU usage
- `htop` – Interactive process viewer (if installed)
- `kill PID` – Terminate a process by PID
- `killall process_name` – Kill process by name

---

## 🔹 File System & Logs

- `pwd` – Show current directory path
- `ls -la` – List files with permissions and hidden files
- `cd /path` – Change directory
- `mkdir dir_name` – Create a directory
- `touch file.txt` – Create an empty file
- `cat file.txt` – View file content
- `less file.txt` – Read large files safely
- `tail -f file.txt` – Monitor logs in real time
- `cp src dest` – Copy files
- `mv old new` – Rename or move files
- `rm file.txt` – Delete file
- `df -h` – Disk usage in human readable form
- `free -h` – Memory usage

---

## 🔹 Networking & Troubleshooting
- i think every cloud enthusiast needs to learn this cmd's 
   here are some my recommendations for you 
- `ip addr` – Show IP address and network interfaces
- `ping google.com` – Check network connectivity
- `curl https://example.com` – Test HTTP response
- `dig google.com` – DNS lookup
- `netstat -tulnp` – Show listening ports (legacy)
- `ss -tulnp` – Show active network sockets

---

## 🔹 Permissions

- `chmod 755 file` – Change file permissions
- `chown user file` – Change file owner

---

## 📌 Why This Matters

Fast command-line troubleshooting helps DevOps engineers:
 
- Restore services quickly
- Reduce downtime
- Build operational trust

---