# Day 29 – Introduction to Docker
Overview

Today I learned the fundamentals of Docker and ran my first containers.

This marks the beginning of containerization in my DevOps journey — understanding how applications can be packaged and run consistently across different environments.

# Task 1 – What is Docker?
What is a Container?

A container is a lightweight, isolated environment that packages an application along with all its dependencies, libraries, and runtime.

Containers ensure that an application runs the same way regardless of the underlying system.

They solve the classic problem:

"It works on my machine."

Containers vs Virtual Machines
Virtual Machines (VMs)

Full operating system

Separate kernel

Heavy resource usage

Slower startup time

Containers

Share the host OS kernel

Lightweight

Start in seconds

More resource-efficient

Key Difference:

VMs use hardware-level virtualization.
Containers use OS-level virtualization.

# Docker Architecture

Docker consists of the following components:

1. Docker Client

The command-line interface where we run commands like:

docker run nginx
2. Docker Daemon (dockerd)

Runs in the background and manages images and containers.

3. Docker Images

Blueprints used to create containers.

Example:

nginx image

ubuntu image

4. Docker Containers

Running instances of Docker images.

5. Docker Registry

A place where images are stored (e.g., Docker Hub).

# Architecture Flow

User → Docker Client → Docker Daemon → Pull Image from Registry → Run Container

# Task 2 – Install Docker

Verified Docker installation:
```bash
docker --version
```
Ran the first test container:
```bash
docker run hello-world
```
The output confirmed:

Docker client connected to daemon

Image pulled from Docker Hub

Container executed successfully

# Task 3 – Running Real Containers
Run Nginx Container
docker run -d -p 8080:80 --name my-nginx nginx

-d → Detached mode

-p 8080:80 → Port mapping (host:container)

--name → Custom container name

Accessed in browser:
```bash
http://localhost:8080
```
Run Ubuntu in Interactive Mode
```bash
docker run -it ubuntu bash
```
```bash

-it → Interactive terminal
```
Explored container like a mini Linux environment

List Running Containers
```bash
docker ps
```
List All Containers (Including Stopped)
```bash
docker ps -a
```
Stop and Remove a Container
```bash
docker stop my-nginx
docker rm my-nginx
```
# Task 4 – Exploring Docker Features
Detached Mode
```bash
docker run -d nginx
```
Container runs in background.

View Logs
```bash
docker logs my-nginx
```
Execute Command Inside Running Container
```bash
docker exec -it my-nginx bash
```