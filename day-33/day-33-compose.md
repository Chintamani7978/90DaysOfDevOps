# Day 33 - Docker Compose Multi-Container Basics

## Objective
Document Compose basics and multi-container setup.

## Task 1 - Install and Verify
- Compose availability: Available using Docker Compose V2 plugin.
- Version: Verified with docker compose version.

## Task 2 - First Compose File
- Folder created: compose-basics
- Compose file summary: A single nginx service with port mapping 8080:80 and container auto-name managed by Compose.
- Browser verification: Accessing http://localhost:8080 returned the default Nginx welcome page.

## Task 3 - WordPress + MySQL
- Service definitions:
	- wordpress service with port mapping and DB environment variables.
	- mysql service with MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD.
- Named volume used: mysql_data for MySQL data directory.
- Connection via service name verified: Yes (WordPress connected using mysql as DB host).
- Data persisted after down/up: Yes (using docker compose down and docker compose up without removing volumes).

## Task 4 - Compose Commands Practiced
- Detached start: docker compose up -d
- Service listing: docker compose ps
- Logs all services: docker compose logs -f
- Logs specific service: docker compose logs -f wordpress
- Stop without remove: docker compose stop
- Remove containers and networks: docker compose down
- Rebuild after change: docker compose up --build

## Task 5 - Environment Variables
- Inline env vars used: Service-level environment keys directly inside compose file.
- .env vars used: DB credentials and port variables referenced as ${VAR_NAME}.
- Verification method: docker compose config showed resolved values and containers started with expected configuration.

## Files Added
- docker-compose.yml
- .env

## Learnings
1. Compose makes multi-container setup reproducible and easier than long docker run commands.
2. Service names in Compose act as DNS hostnames, which simplifies app-to-db communication.
3. Named volumes preserve state across container recreation, making local dev and demos stable.
