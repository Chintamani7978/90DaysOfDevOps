# Day 37 - Docker Revision

## Self-Assessment
- [x] Run container from Docker Hub
- [x] Manage containers and images
- [x] Explain layers and caching
- [x] Write Dockerfile from scratch
- [x] Explain CMD vs ENTRYPOINT
- [x] Build and tag custom image
- [x] Use named volumes
- [x] Use bind mounts
- [x] Use custom networks
- [x] Write multi-container compose file
- [x] Use env vars and .env in Compose
- [x] Write multi-stage Dockerfile
- [x] Push image to Docker Hub
- [x] Use healthchecks and depends_on

## Quick-Fire Answers
1. An image is an immutable template; a container is a running instance of that template with a writable layer.
2. Data in the container writable layer is lost when the container is removed.
3. They communicate using built-in DNS on user-defined bridge networks via container or service names.
4. docker compose down -v also removes named and anonymous volumes created by the project; down alone keeps volumes.
5. Multi-stage builds reduce final image size and attack surface by copying only runtime artifacts.
6. COPY transfers local files directly; ADD can also fetch remote URLs and auto-extract local tar archives.
7. -p 8080:80 maps host port 8080 to container port 80.
8. Use docker system df to view disk usage by images, containers, volumes, and build cache.

## Weak Spots Revisited
- Topic 1: Healthchecks with depends_on condition service_healthy.
- Topic 2: Multi-stage optimization and non-root hardening.

## Notes
- Revision improved confidence in container persistence, networking behavior, and practical Compose troubleshooting.
