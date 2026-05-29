# Docker Usage

This document provides a basic guide to using Docker, including common commands and concepts relevant to a development workflow.

## Overview

[Docker](https://www.docker.com/) is a platform for developing, shipping, and running applications in containers. Containers allow you to package an application with all of its dependencies into a standardized unit for software development.

## Installation

*   **Docker Desktop**: For macOS and Windows, [Docker Desktop](https://www.docker.com/products/docker-desktop/) is the easiest way to install Docker. It includes the Docker Engine, Docker CLI client, Docker Compose, Kubernetes, and more.
*   **Linux**: On Linux, you can install the Docker Engine and CLI separately. Follow the official installation guides for your distribution (e.g., [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)).

Installation might be managed by `chezmoi` if Docker is part of your standard toolset defined in your dotfiles.

## Common Docker CLI Commands

Here are some of the most frequently used Docker commands:

*   **Pull an image from a registry (e.g., Docker Hub)**:
    ```sh
    docker pull <image_name>:<tag>
    # Example: docker pull ubuntu:latest
    ```

*   **Run a container from an image**:
    ```sh
    docker run [options] <image_name>:<tag> [command]
    # Example (interactive shell in an Ubuntu container):
    # docker run -it ubuntu:latest /bin/bash
    # Example (run a web server, map port 8080 to container's port 80):
    # docker run -d -p 8080:80 nginx:latest
    ```
    *   `-d`: Detached mode (run in background)
    *   `-it`: Interactive TTY
    *   `-p <host_port>:<container_port>`: Port mapping
    *   `--name <container_name>`: Assign a name to the container
    *   `-v <host_path>:<container_path>`: Mount a volume

*   **List running containers**:
    ```sh
    docker ps
    ```

*   **List all containers (running and stopped)**:
    ```sh
    docker ps -a
    ```

*   **View logs of a container**:
    ```sh
    docker logs <container_name_or_id>
    # Follow logs: docker logs -f <container_name_or_id>
    ```

*   **Stop a running container**:
    ```sh
    docker stop <container_name_or_id>
    ```

*   **Remove a stopped container**:
    ```sh
    docker rm <container_name_or_id>
    ```

*   **List images**:
    ```sh
    docker images
    ```

*   **Remove an image**:
    ```sh
    docker rmi <image_name_or_id>
    ```

*   **Clean up unused resources (containers, networks, images)**:
    ```sh
    docker system prune
    # To remove all unused images, not just dangling ones:
    # docker system prune -a
    ```

## Docker Compose

[Docker Compose](https://docs.docker.com/compose/) is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file (`docker-compose.yml`) to configure your application's services.

### Example `docker-compose.yml` snippet:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  app:
    image: my-custom-app
    build: .
    ports:
      - "3000:3000"
```

### Common Docker Compose Commands:

*   **Start services defined in `docker-compose.yml`**:
    ```sh
    docker-compose up
    # Start in detached mode: docker-compose up -d
    ```

*   **Stop services**:
    ```sh
    docker-compose down
    ```

*   **List services**:
    ```sh
    docker-compose ps
    ```

## Development Containers (Dev Containers)

[Development Containers](https://containers.dev/) (Dev Containers) allow you to use a Docker container as a full-featured development environment. This is particularly useful with editors like VS Code.

A `devcontainer.json` file in your project tells VS Code (and other tools) how to access (or create) a development container with a well-defined tool and runtime stack.

### Key Benefits:
*   **Consistent Environment**: Ensures everyone on the team uses the same development environment.
*   **Tool Isolation**: Keeps tools and dependencies for different projects separate.
*   **Pre-configured Setups**: Quickly onboard new developers with ready-to-use environments.

Refer to the [official Dev Containers documentation](https://containers.dev/docs) and the [VS Code Remote - Containers documentation](https://code.visualstudio.com/docs/remote/containers) for setup and usage details.

## Resources

*   **Official Docker Documentation**: [https://docs.docker.com/](https://docs.docker.com/)
*   **Docker Hub (Image Registry)**: [https://hub.docker.com/](https://hub.docker.com/)
*   **Docker Compose Documentation**: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
*   **Development Containers**: [https://containers.dev/](https://containers.dev/)
*   **VS Code Remote - Containers**: [https://code.visualstudio.com/docs/devcontainers/containers](https://code.visualstudio.com/docs/devcontainers/containers) (Note: VS Code documentation now prefers /devcontainers/ over /remote/)

This guide provides a starting point. Docker is a vast ecosystem, so refer to the official documentation for in-depth information.
