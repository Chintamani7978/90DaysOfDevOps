### Day 14 – Networking Fundamentals & Hands-on Checks

## Objective
Day 14 focused on understanding core networking fundamentals and practicing the basic commands that are commonly used during real-world troubleshooting.  
The goal was to keep things practical, simple, and repeatable.

---

## Quick Concepts

### OSI vs TCP/IP Model
- **OSI Model (7 layers):** 
                            Physical
                            Data Link
                            Network
                            Transport
                            Session
                            Presentation 
                            Application  
-Network, Transport, Session, Presentation, Application  
- **TCP/IP Model (4 layers):**  Link,
                                Internet, 
                                Transport,
                                Application  
- OSI is mainly for understanding concepts, TCP/IP is what actually runs on systems.

### Where Things Fit
- **IP** → Network layer (OSI) / Internet layer (TCP/IP)  
- **TCP / UDP** → Transport layer  
- **HTTP / HTTPS** → Application layer  
- **DNS** → Application layer  

### Real Example
- `curl https://chintamani.me`  
  Application layer (HTTP) → Transport layer (TCP) → Network layer (IP)

---

## Hands-on Networking Checks

### 1. Identity – Check IP Address
```bash
hostname -I
```
Observation:
This shows the private IP address assigned to the machine.

2. Reachability – Ping Test
```
ping -c 4 google.com
```
Observation:
Packets were successfully sent and received with low latency, confirming basic network connectivity.

3. Path – Traceroute
```bash
traceroute google.com
(or)
```
```bash
tracepath google.com
```
Observation:
Multiple hops were visible. Some hops may not reply, which is normal due to firewall rules.

4. Ports – Check Listening Services
```bash
ss -tulpn
```
Observation:
Confirmed services like SSH listening on port 22.

5. Name Resolution – DNS Check
```bash
dig google.com
(or)

nslookup google.com
```
Observation:
Domain name resolved successfully to an IP address, confirming DNS is working.

6. HTTP Check
```bash
```bash
curl -I https://google.com
```
Observation:
Received HTTP status code 200 OK, confirming the service is reachable.

7. Connections Snapshot
```bash
netstat -an | head
```
Observation:
Saw a mix of LISTEN and ESTABLISHED connections, showing active network communication.

Mini Task – Port Probe & Interpretation
Identified Listening Port
SSH service running on port 22
```bash
Port Test
nc -zv localhost 22
```
Result:
Port is reachable and accepting connections.

If not reachable:
Next checks would be:
```bash
systemctl status ssh
```
Firewall rules (ufw status or iptables -L)

Reflection
Fastest signal command: ping — quickly shows if the host is reachable.

If DNS fails: Check Application layer (DNS resolution).

If HTTP 500 error appears: Check Application layer logs and service status.

Two Follow-up Checks in Real Incidents
Check service logs using journalctl

Verify firewall and listening ports using ss or netstat