# Docker Cheatsheet

## Container Commands
- docker run -d --name app -p 8080:80 nginx:latest : start container in detached mode
- docker ps : list running containers
- docker ps -a : list all containers
- docker stop <container> : gracefully stop container
- docker rm <container> : remove stopped container
- docker exec -it <container> sh : open interactive shell in container
- docker logs -f <container> : stream container logs

## Image Commands
- docker build -t myapp:1.0 . : build image from Dockerfile
- docker pull nginx:latest : download image from registry
- docker push <user>/<repo>:tag : upload image to Docker Hub
- docker tag myapp:1.0 <user>/<repo>:v1 : retag local image
- docker images : list local images
- docker rmi <image> : remove local image

## Volume Commands
- docker volume create pgdata : create named volume
- docker volume ls : list volumes
- docker volume inspect pgdata : inspect mount details
- docker volume rm pgdata : remove volume

## Network Commands
- docker network create my-app-net : create user-defined bridge network
- docker network ls : list networks
- docker network inspect my-app-net : view network configuration and attached containers
- docker network connect my-app-net <container> : attach existing container to network

## Compose Commands
- docker compose up : start services in foreground
- docker compose up -d : start services in background
- docker compose down : stop and remove containers and networks
- docker compose ps : list compose services
- docker compose logs -f : follow logs for all services
- docker compose up --build : rebuild images and start services

## Cleanup Commands
- docker system df : show Docker disk usage
- docker system prune -a : remove unused containers, images, networks, and build cache

## Dockerfile Instructions
- FROM : base image for the build stage
- RUN : execute commands at build time
- COPY : copy files from build context to image
- WORKDIR : set working directory for subsequent instructions
- EXPOSE : document container listening port
- CMD : default command arguments, overridable at runtime
- ENTRYPOINT : fixed executable that runs when container starts
