
# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## Objective
Day 15 focused on strengthening core networking fundamentals required for DevOps engineering.  
The goal was to understand DNS resolution, IP addressing, CIDR/subnetting, and port-based communication from a systems perspective.

---

# 1. DNS – How Names Resolve to IP Addresses

# What Happens When You Access google.com?

1. The system checks the local DNS cache.
2. If not found, it queries the configured DNS resolver (e.g., 8.8.8.8).
3. The resolver contacts:
   - Root servers
   - TLD (.com) servers
   - Authoritative name servers
4. The authoritative server returns the A record (IPv4).
5. The browser establishes a TCP connection to the resolved IP.

---

## DNS Record Types

| Record | Purpose |
|---------|---------|
| A       | Maps domain to IPv4 address |
| AAAA    | Maps domain to IPv6 address |
| CNAME   | Alias of another domain |
| MX      | Mail server record |
| NS      | Authoritative name server record |

---

## DNS Lookup

```bash
dig google.com
```

---

#

Example (real output snippet):
```bash
google.com.     300 IN A 142.250.183.14

```

---

```bash

A Record: 142.250.183.14

TTL: 300 seconds
```
TTL defines how long the response is cached.

2. IP Addressing
What is IPv4?

An IPv4 address is a 32-bit numeric identifier written in dotted decimal format:
```bash
192.168.1.10

```
It consists of 4 octets (8 bits each), ranging from 0–255.

Public vs Private IP
```bash
Public IP Example: 8.8.8.8 (Google DNS)

Private IP Example: 192.168.1.15
```
Private IP ranges:
```bash
10.0.0.0 – 10.255.255.255

172.16.0.0 – 172.31.255.255

192.168.0.0 – 192.168.255.255
```
Identifying Local IP
ip addr show


Example output:

inet 192.168.1.15/24


This is a private IP address within the 192.168.x.x range.

3. CIDR & Subnetting
What Does /24 Mean?

192.168.1.0/24 means:

24 bits are allocated for the network

8 bits are allocated for hosts

Subnet mask: 255.255.255.0

Usable Hosts
CIDR	Subnet Mask	Total IPs	Usable Hosts
/24	255.255.255.0	256	254
/16	255.255.0.0	65,536	65,534
/28	255.255.255.240	16	14

Formula:
Usable Hosts = (2^(32 - CIDR)) - 2

Why Subnet?

Subnetting allows:

Logical network segmentation

Reduced broadcast traffic

Improved security boundaries

Efficient IP utilization

Structured cloud/VPC design

4. Ports – Logical Service Endpoints
What is a Port?

A port is a logical communication endpoint that allows multiple services to operate on the same IP address.

Example:
One server can simultaneously run:

SSH on port 22

Web server on port 80

Database on port 3306

| Port  | Service |
| ----- | ------- |
| 22    | SSH     |
| 80    | HTTP    |
| 443   | HTTPS   |
| 53    | DNS     |
| 3306  | MySQL   |
| 6379  | Redis   |
| 27017 | MongoDB |


Example output snippet:

LISTEN 0 128 0.0.0.0:22


This confirms SSH is listening on port 22.

5. Applied Scenario Analysis
# You run curl http://myapp.com:8080 — what networking concepts are involved?

When running this command, DNS first resolves myapp.com to an IP address.
A TCP connection is then established to port 8080, and an HTTP request is sent.
This involves DNS resolution, IP routing, TCP communication, and port-based service access at the application layer.

# Your app can't reach a database at 10.0.1.50:3306 — what would you check first?

First, I would verify whether the database service is running and listening on port 3306.
Then I would check network reachability, firewall/security group rules, and ensure both systems are in the correct subnet or allowed route.
If needed, I would validate connectivity using tools like ping, nc, or telnet.