# Day 35 - Multi-Stage Builds and Docker Hub

## Objective
Compare single-stage vs multi-stage images and publish to Docker Hub.

## Task 1 - Single-Stage Baseline
- App type: Node.js Hello World API.
- Dockerfile summary: Single-stage build that installed dependencies and ran app in the same runtime image.
- Image size: Baseline image was significantly larger due to build tools and dependency cache in final image.

## Task 2 - Multi-Stage Build
- Builder stage base image: node:20
- Runtime stage base image: node:20-alpine
- New image size: Reduced noticeably versus single-stage build.
- Size difference: Smaller final image because build-only files were excluded.
- Why smaller: Multi-stage keeps only runtime artifacts, dropping compilers, package manager cache, and unnecessary intermediate layers.

## Task 3 - Push to Docker Hub
- Repo name: <dockerhub-username>/day35-node-app
- Tag pushed: latest and v1
- Push result: Image successfully uploaded and visible in Docker Hub tags.
- Pull verification: Image pulled on fresh environment and ran successfully.

## Task 4 - Docker Hub Repo Review
- Description updated: Yes
- Tags reviewed: latest, v1
- latest vs specific tag note: latest can drift over time; specific tags are safer for predictable deployments and rollback.

## Task 5 - Best Practices Applied
- Minimal base image used: Yes (alpine variant for runtime).
- Non-root user configured: Yes (USER appuser).
- Layer optimization done: Yes (combined RUN commands and cleaned package cache).
- Specific base tags used: Yes (pinned major/minor tags instead of latest).
- Final size: Improved from baseline and better suited for fast pull and lower attack surface.

## Docker Hub Link
- https://hub.docker.com/r/<dockerhub-username>/day35-node-app

## Learnings
1. Multi-stage builds are one of the highest-impact Docker optimizations for size and security.
2. Tag discipline matters for release safety and reproducible deployments.
3. Running as non-root and using minimal base images are practical production defaults.
