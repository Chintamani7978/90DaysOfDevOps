# Linux Architecture – Day 02 Notes

Author: Chintamani Mohanta  

---

## 🔹 Core Parts of Linux

### Kernel
- Controls CPU, memory, disk, network, and devices.
- Decides which process gets CPU time.
- Talks directly to hardware.

### User Space
- Where users and applications run.
- Includes shell, commands, browsers, servers, editors.
- Users interact with Linux from here.

### systemd (Init System)
- First process started by kernel (PID 1).
- Starts all services during boot.
- Restarts failed services automatically.
- Manages logs and service dependencies.

---

## 🔹 Process Basics

- A process = a running program.
- Created when we run a command from terminal.
- Every process has:
  - PID (process ID)
  - Owner
  - Memory and CPU usage
  - State

---

## 🔹 Process States

- **Running (R)** – Using CPU right now.
- **Sleeping (S)** – Waiting for input or resource.
- **Stopped (T)** – Paused manually or by signal.
- **Zombie (Z)** – Finished but parent has not cleaned it.
- **Idle (I)** – Waiting for CPU.

Zombie processes waste PID but not memory.

---

## 🔹 Why systemd Matters

- Keeps services running automatically.
- Makes boot faster and organized.
- Helps debug using logs.
- Controls service start/stop easily.

---

## 🔹 Daily Linux Commands

- `ps aux` → View running processes.
- `top` → Monitor CPU and memory.
- `systemctl status nginx` → Check service status.
- `journalctl -xe` → View logs.
- `kill PID` → Stop a process.

---

## 🔹 DevOps Importance

- Faster troubleshooting.
- Better system monitoring.
- Confident service management.
- Reduced downtime during incidents.
