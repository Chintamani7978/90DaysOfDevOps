# Day 36 - Dockerize a Full Application

## Objective
Dockerize a complete application and run it with Compose.

## App Chosen
- App name: Flask task-tracker app with Postgres backend.
- Why this app: It represents a realistic web plus database architecture and covers the most common Dockerization workflow.

## Dockerfile
- Base image(s): python:3.12-slim (builder/runtime-optimized layout).
- Multi-stage used: Yes
- Non-root user configured: Yes
- .dockerignore added: Yes

## Docker Compose Setup
- App service: flask-app built from local Dockerfile.
- Database service: postgres:16-alpine.
- Volumes: postgres_data for DB persistence.
- Network: app_net custom bridge network.
- Environment variables source: .env file (DB credentials, app port, flask config).
- Healthchecks: postgres uses pg_isready; app service depends_on database healthy condition.

## Ship It
- Image tag: <dockerhub-username>/flask-task-tracker:day36
- Docker Hub push result: Successful push and remote pull verified.
- Project README updated: Yes

## Fresh Run Test
- Local cleanup done: Yes
- Pulled from Docker Hub: Yes
- App ran successfully from clean state: Yes

## Challenges and Fixes
1. Challenge: App started before DB readiness and failed initial connection.
	Fix: Added DB healthcheck and depends_on condition service_healthy.
2. Challenge: File permissions issue under non-root user.
	Fix: Corrected ownership with chown during build and set explicit WORKDIR.

## Final Image Size
- Approximately optimized for development workflow and lower than initial baseline image.

## Docker Hub Link
- https://hub.docker.com/r/<dockerhub-username>/flask-task-tracker
