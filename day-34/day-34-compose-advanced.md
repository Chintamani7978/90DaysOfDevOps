# Day 34 - Docker Compose Advanced

## Objective
Build a production-like multi-service Compose setup.

## Task 1 - App Stack
- App service: web (Node.js app built from local Dockerfile).
- Database service: postgres (postgres:16).
- Cache service: redis (redis:7-alpine).
- Dockerfile path: ./app/Dockerfile

## Task 2 - depends_on and Healthchecks
- Healthcheck config summary: postgres service used pg_isready check with interval, timeout, retries, and start_period.
- depends_on with service_healthy configured: Yes
- Startup behavior observed: web service waited until postgres reported healthy before starting, reducing connection-refused errors.

## Task 3 - Restart Policies
- restart: always test result: DB container restarted automatically even after manual stop/daemon restart.
- restart: on-failure test result: Container restarted only when exit code was non-zero.
- When to use each:
	- always: critical infra components that should stay up continuously.
	- on-failure: batch or app processes where retries are needed only for crashes.

## Task 4 - Build from Dockerfile
- build context: ./app
- Rebuild command used: docker compose up --build -d
- Result after code change: Updated app code reflected in new container image and service behavior.

## Task 5 - Named Networks and Volumes
- Networks defined: app_net (custom bridge)
- Volumes defined: pgdata_advanced for postgres persistent storage.
- Labels added: com.project=90days-devops, com.service=web|db|cache

## Task 6 - Scaling Bonus
- Scale command: docker compose up -d --scale web=3
- Result: Multiple web containers started.
- What broke and why: Static host port mapping conflicts with multiple replicas because one host port cannot be bound by multiple containers simultaneously. A reverse proxy or dynamic service discovery is needed.

## Learnings
1. depends_on alone is not enough; healthchecks make startup ordering reliable.
2. Restart policies must match workload type to avoid unnecessary restarts or downtime.
3. Scaling needs load balancing strategy, not only replica count.
