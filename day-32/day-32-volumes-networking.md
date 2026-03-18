# Day 32 - Docker Volumes and Networking

## Objective
Capture hands-on results for data persistence and container communication.

## Task 1 - The Problem
- Database used: Postgres (postgres:16)
- Data created: A sample table named users with 3 rows.
- What happened after container removal: After stopping and deleting the container, a new container started with the same image did not contain the previous table or rows.
- Why it happened: Container writable layers are ephemeral. When the container is removed, its internal filesystem changes are removed too unless storage is mounted externally.

## Task 2 - Named Volumes
- Volume name: pgdata_day32
- Container run command:
	- docker volume create pgdata_day32
	- docker run -d --name pgdb1 -e POSTGRES_PASSWORD=postgres -v pgdata_day32:/var/lib/postgresql/data postgres:16
	- (create table + insert rows)
	- docker rm -f pgdb1
	- docker run -d --name pgdb2 -e POSTGRES_PASSWORD=postgres -v pgdata_day32:/var/lib/postgresql/data postgres:16
- Verification output:
	- docker volume ls showed pgdata_day32
	- docker volume inspect pgdata_day32 confirmed a stable mountpoint managed by Docker
	- Reconnecting to pgdb2 showed the same table and records
- Data persisted after recreation: Yes

## Task 3 - Bind Mounts
- Host path: E:/CodeModeOn/90DaysOfDevOps/2026/day-32/site
- Container path: /usr/share/nginx/html
- Nginx run command:
	- docker run -d --name day32-nginx -p 8080:80 -v E:/CodeModeOn/90DaysOfDevOps/2026/day-32/site:/usr/share/nginx/html nginx:latest
- Live update observed after editing index.html: Yes
- Named volume vs bind mount notes:
	- Named volume is Docker-managed storage and best for persistent app/database data.
	- Bind mount maps an exact host folder and is best for local development where immediate file reflection is needed.
	- Named volumes are more portable and safer for production data paths; bind mounts depend heavily on host directory structure.

## Task 4 - Docker Networking Basics
- docker network ls output summary: bridge, host, none were available by default.
- Default bridge inspect notes:
	- It is the legacy default network.
	- Containers can communicate by IP if attached.
	- Automatic DNS-based name resolution is not consistently available like user-defined bridge networks.
- Ping by name on default bridge: Fail (in most default setups)
- Ping by IP on default bridge: Success

## Task 5 - Custom Networks
- Network name: my-app-net
- Containers attached: app1 and app2 (both attached using --network my-app-net)
- Ping by name result: Success
- Why name resolution works here:
	- User-defined bridge networks include built-in Docker DNS.
	- Docker registers container names on that network, so containers can resolve each other by name without hardcoding IPs.
	- This is cleaner and more stable than IP-based communication because container IPs can change.

## Task 6 - Put It Together
- Database container details:
	- Image: postgres:16
	- Network: my-app-net
	- Volume: pgdata_day32:/var/lib/postgresql/data
	- Name: app-db
- App container details:
	- Image: alpine:latest (test client container)
	- Network: my-app-net
	- Name: app-client
	- Connectivity command: ping -c 3 app-db
- Connectivity check result: app-client successfully resolved and reached app-db by container name, confirming network-level service discovery.

## Screenshots
- [ ] Added screenshots for each major task

## Learnings
1. Containers are disposable compute units, so persistent data must live outside container writable layers.
2. Named volumes are the right choice for durable service data like Postgres/MySQL.
3. User-defined Docker networks are better than the default bridge for service-to-service communication because they provide built-in DNS and stable name-based routing.
