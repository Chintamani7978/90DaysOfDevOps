# Day 45 - Docker Build and Push in GitHub Actions

## Objective
Automate Docker build and publish flow from push to Docker Hub.

## Workflow
- File: .github/workflows/docker-publish.yml
- Trigger on main push: Yes

## Build Stage
- Dockerfile source: Reused Dockerized app from Day 36.
- Build result: Image build completed successfully in GitHub Actions runner.
- Tags generated: latest and sha-<short-commit-hash>

## Push Stage
- Docker login via secrets: Yes
- latest tag pushed: Yes
- sha tag pushed: Yes
- Main-only push condition verified: Yes

## Badge
- Badge URL added to README: Yes

## Pull and Run Validation
- Image pulled locally/server: Yes
- Container started successfully: Yes

## Full Journey
Describe the path from git push to running container:
- Developer pushes code to main branch.
- GitHub Actions workflow triggers automatically.
- Runner checks out repository and builds Docker image.
- Workflow logs in to Docker Hub using repository secrets.
- Workflow tags image as latest and sha-based version.
- Workflow pushes tags to Docker Hub.
- Deployment host (or local machine) pulls tagged image.
- Container is started from the pulled image and becomes accessible.

## Links and Evidence
- Docker Hub image link: https://hub.docker.com/r/<dockerhub-username>/<repo>
- Workflow run screenshot/link: To be added from Actions tab.
