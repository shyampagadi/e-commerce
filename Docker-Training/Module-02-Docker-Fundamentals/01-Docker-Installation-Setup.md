# Docker Installation and Setup

## Learning Objectives
- Install Docker on your system
- Verify Docker installation
- Understand Docker architecture
- Run your first container

## Docker Installation

### Linux (Ubuntu/Debian)
```bash
# 1. Update package index
sudo apt update

# 2. Install prerequisites
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# 3. Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 6. Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### macOS
```bash
# Option 1: Docker Desktop (Recommended)
# Download from: https://www.docker.com/products/docker-desktop

# Option 2: Homebrew
brew install --cask docker
```

### Windows
```bash
# Option 1: Docker Desktop (Recommended)
# Download from: https://www.docker.com/products/docker-desktop

# Option 2: WSL2 + Docker (Advanced)
# Install WSL2 first, then follow Linux instructions
```

## Verify Installation

```bash
# Check Docker version
docker --version
docker version

# Check Docker info
docker info

# Test with hello-world
docker run hello-world
```

**Expected output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

## Docker Architecture Overview

### Key Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Docker CLI    │    │  Docker Daemon  │    │   Docker Hub    │
│   (Client)      │───▶│   (dockerd)     │───▶│  (Registry)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Containers    │
                       │   Images        │
                       │   Networks      │
                       │   Volumes       │
                       └─────────────────┘
```

### Understanding the Flow
1. **Docker CLI**: Commands you type (`docker run`, `docker build`)
2. **Docker Daemon**: Background service that manages containers
3. **Docker Registry**: Where images are stored (Docker Hub, private registries)
4. **Images**: Read-only templates for creating containers
5. **Containers**: Running instances of images

## Your First Docker Commands

### Basic Information Commands
```bash
# System information
docker system info
docker system df  # disk usage

# Version information
docker version
docker --version
```

### Working with Images
```bash
# List local images
docker images
docker image ls

# Pull an image from Docker Hub
docker pull nginx
docker pull ubuntu:20.04
docker pull node:16-alpine

# Remove an image
docker rmi nginx
docker image rm ubuntu:20.04
```

### Working with Containers
```bash
# Run a container
docker run nginx
docker run -d nginx  # detached mode
docker run -d --name my-nginx nginx

# List running containers
docker ps
docker container ls

# List all containers (including stopped)
docker ps -a
docker container ls -a

# Stop a container
docker stop my-nginx
docker stop CONTAINER_ID

# Remove a container
docker rm my-nginx
docker container rm CONTAINER_ID
```

## Hands-On Exercise 1: Your First Web Server

Let's run a web server in a container:

```bash
# 1. Run nginx web server
docker run -d -p 8080:80 --name my-web-server nginx

# 2. Test it works
curl http://localhost:8080
# Or open browser to http://localhost:8080

# 3. Check container status
docker ps

# 4. View container logs
docker logs my-web-server

# 5. Execute command inside container
docker exec -it my-web-server bash
# Inside container:
ls /usr/share/nginx/html
cat /usr/share/nginx/html/index.html
exit

# 6. Stop and remove
docker stop my-web-server
docker rm my-web-server
```

## Understanding Docker Run Options

### Common Flags
```bash
# Port mapping: host_port:container_port
docker run -p 8080:80 nginx

# Detached mode (background)
docker run -d nginx

# Interactive terminal
docker run -it ubuntu bash

# Name your container
docker run --name my-container nginx

# Environment variables
docker run -e NODE_ENV=production node

# Volume mounting
docker run -v /host/path:/container/path nginx

# Remove container when it stops
docker run --rm nginx
```

### Practical Examples
```bash
# Interactive Ubuntu container
docker run -it --rm ubuntu:20.04 bash
# Inside container, try:
cat /etc/os-release
ls /
exit

# Node.js container with environment
docker run -it --rm -e NODE_ENV=development node:16 node -e "console.log(process.env.NODE_ENV)"

# Nginx with custom port
docker run -d -p 3000:80 --name web-on-3000 nginx
curl http://localhost:3000
docker stop web-on-3000 && docker rm web-on-3000
```

## Hands-On Exercise 2: Container Lifecycle

Practice the complete container lifecycle:

```bash
# 1. Pull multiple images
docker pull nginx:alpine
docker pull httpd:alpine
docker pull caddy:alpine

# 2. Run containers with different configurations
docker run -d -p 8081:80 --name nginx-server nginx:alpine
docker run -d -p 8082:80 --name apache-server httpd:alpine
docker run -d -p 8083:80 --name caddy-server caddy:alpine

# 3. Test all servers
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083

# 4. Monitor containers
docker ps
docker stats  # real-time stats (Ctrl+C to exit)

# 5. Check logs
docker logs nginx-server
docker logs apache-server
docker logs caddy-server

# 6. Execute commands in containers
docker exec nginx-server ls /etc/nginx
docker exec apache-server ls /usr/local/apache2/conf
docker exec caddy-server ls /etc/caddy

# 7. Stop all containers
docker stop nginx-server apache-server caddy-server

# 8. Remove all containers
docker rm nginx-server apache-server caddy-server

# 9. Clean up images (optional)
docker rmi nginx:alpine httpd:alpine caddy:alpine
```

## Docker Hub Exploration

### Searching for Images
```bash
# Search for images
docker search nginx
docker search node
docker search python

# Pull specific versions
docker pull node:16
docker pull node:18
docker pull node:latest

# Check image details
docker inspect node:16
```

### Understanding Image Tags
```bash
# Different ways to specify images
docker pull ubuntu          # latest tag
docker pull ubuntu:latest   # explicit latest
docker pull ubuntu:20.04    # specific version
docker pull ubuntu:focal    # codename

# Alpine versions (smaller)
docker pull node:16-alpine
docker pull nginx:alpine
docker pull python:3.9-alpine
```

## Container Management

### Monitoring and Debugging
```bash
# Real-time container stats
docker stats

# Container processes
docker top CONTAINER_NAME

# Container details
docker inspect CONTAINER_NAME

# Container logs
docker logs CONTAINER_NAME
docker logs -f CONTAINER_NAME  # follow logs
docker logs --tail 50 CONTAINER_NAME  # last 50 lines
```

### Container Interaction
```bash
# Execute commands
docker exec CONTAINER_NAME ls /
docker exec -it CONTAINER_NAME bash

# Copy files to/from container
docker cp file.txt CONTAINER_NAME:/path/to/destination
docker cp CONTAINER_NAME:/path/to/file.txt ./local-file.txt
```

## Hands-On Exercise 3: Real Application

Let's run a real application - a simple Node.js app:

```bash
# 1. Create a simple Node.js app
mkdir ~/docker-node-app
cd ~/docker-node-app

cat > app.js << 'EOF'
const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
        <h1>Hello from Docker!</h1>
        <p>Hostname: ${os.hostname()}</p>
        <p>Platform: ${os.platform()}</p>
        <p>Node.js version: ${process.version}</p>
        <p>Current time: ${new Date().toISOString()}</p>
    `);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

cat > package.json << 'EOF'
{
    "name": "docker-node-app",
    "version": "1.0.0",
    "description": "Simple Node.js app for Docker",
    "main": "app.js",
    "scripts": {
        "start": "node app.js"
    }
}
EOF

# 2. Run the app in a container
docker run -d -p 3000:3000 -v $(pwd):/app -w /app --name node-app node:16 npm start

# 3. Test the application
curl http://localhost:3000
# Or open browser to http://localhost:3000

# 4. Check logs
docker logs node-app

# 5. Make changes to app.js and refresh browser
# The changes appear immediately due to volume mounting

# 6. Clean up
docker stop node-app
docker rm node-app
```

## Common Issues and Solutions

### Permission Issues
```bash
# If you get permission denied:
sudo docker run hello-world

# Better solution - add user to docker group:
sudo usermod -aG docker $USER
newgrp docker
```

### Port Already in Use
```bash
# Find what's using the port
lsof -i :8080
netstat -tlnp | grep 8080

# Use different port
docker run -p 8081:80 nginx
```

### Container Won't Start
```bash
# Check logs for errors
docker logs CONTAINER_NAME

# Run interactively to debug
docker run -it IMAGE_NAME bash
```

### Out of Disk Space
```bash
# Clean up unused containers
docker container prune

# Clean up unused images
docker image prune

# Clean up everything unused
docker system prune

# See disk usage
docker system df
```

## Best Practices

### Container Naming
```bash
# Use descriptive names
docker run --name web-frontend nginx
docker run --name api-backend node
docker run --name postgres-db postgres
```

### Resource Management
```bash
# Limit memory and CPU
docker run -m 512m --cpus="1.0" nginx

# Always clean up
docker run --rm nginx  # auto-remove when stopped
```

### Security Basics
```bash
# Don't run as root (we'll cover this more later)
docker run --user 1000:1000 nginx

# Read-only filesystem
docker run --read-only nginx
```

## Practice Challenges

### Challenge 1: Multi-Container Setup
Run three different web servers on different ports and compare their default pages.

### Challenge 2: Container Communication
Run two containers and make them communicate (we'll expand on this in networking module).

### Challenge 3: Persistent Data
Run a container, create some data, stop it, and run a new container with the same data.

## Next Steps

You now understand Docker fundamentals:
- ✅ Docker installation and setup
- ✅ Basic Docker commands
- ✅ Container lifecycle management
- ✅ Image management
- ✅ Port mapping and networking basics

**Ready for Module 3: Dockerfile and Nginx** where you'll learn to create your own Docker images!
