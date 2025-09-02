# Docker Images and Containers Deep Dive

## Learning Objectives
- Understand the difference between images and containers
- Master image layers and caching
- Learn container lifecycle management
- Practice with real-world scenarios

## Images vs Containers

### The Analogy
```
Image = Class (blueprint)
Container = Object (instance)

Just like in programming:
- One class can create many objects
- One image can create many containers
- Objects have state, classes don't
- Containers have state, images don't
```

### Visual Representation
```
Docker Image (Read-Only)
┌─────────────────────────┐
│     Application Layer   │
├─────────────────────────┤
│     Dependencies Layer  │
├─────────────────────────┤
│     OS Libraries Layer  │
├─────────────────────────┤
│     Base OS Layer       │
└─────────────────────────┘
            │
            ▼ docker run
┌─────────────────────────┐
│   Container Layer       │ ← Read/Write
│   (Your changes)        │
├─────────────────────────┤
│     Application Layer   │ ← Read-Only
├─────────────────────────┤
│     Dependencies Layer  │ ← Read-Only
├─────────────────────────┤
│     OS Libraries Layer  │ ← Read-Only
├─────────────────────────┤
│     Base OS Layer       │ ← Read-Only
└─────────────────────────┘
```

## Understanding Image Layers

### Inspecting Image Layers
```bash
# Pull an image and inspect its layers
docker pull nginx:alpine
docker history nginx:alpine

# More detailed layer information
docker inspect nginx:alpine
```

### Hands-On Exercise 1: Layer Exploration

```bash
# 1. Compare different image sizes
docker images
docker pull ubuntu:20.04
docker pull alpine:latest
docker pull nginx:alpine
docker pull nginx:latest

# Compare sizes
docker images | grep -E "(ubuntu|alpine|nginx)"

# 2. Inspect layer differences
echo "=== Alpine layers ==="
docker history alpine:latest

echo "=== Ubuntu layers ==="
docker history ubuntu:20.04

echo "=== Nginx Alpine layers ==="
docker history nginx:alpine

# 3. Understand layer sharing
docker system df -v
```

## Container Lifecycle States

### Container States
```
Created → Running → Paused → Stopped → Removed
   ↑         ↓         ↓         ↓         ↓
   └─────────┴─────────┴─────────┴─────────┘
```

### State Management Commands
```bash
# Create (but don't start)
docker create --name my-container nginx

# Start a created container
docker start my-container

# Run (create + start)
docker run --name my-running-container nginx

# Pause/Unpause
docker pause my-running-container
docker unpause my-running-container

# Stop gracefully
docker stop my-running-container

# Kill forcefully
docker kill my-running-container

# Remove
docker rm my-container my-running-container
```

## Hands-On Exercise 2: Container Lifecycle Practice

```bash
# 1. Create multiple containers in different states
docker create --name created-container nginx
docker run -d --name running-container nginx
docker run -d --name paused-container nginx
docker run -d --name stopped-container nginx

# 2. Manipulate their states
docker pause paused-container
docker stop stopped-container

# 3. Check all container states
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.State}}"

# 4. Practice state transitions
docker start created-container
docker pause running-container
docker unpause running-container
docker restart stopped-container

# 5. Clean up
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

## Working with Container Data

### Understanding Container Filesystem
```bash
# 1. Run a container and make changes
docker run -it --name data-test ubuntu:20.04 bash

# Inside container:
echo "Hello from container" > /tmp/container-file.txt
echo "Modified data" > /etc/hostname
ls -la /tmp/
exit

# 2. Check changes persist in stopped container
docker start data-test
docker exec data-test cat /tmp/container-file.txt
docker exec data-test cat /etc/hostname

# 3. Create new container from same image
docker run -it --name data-test2 ubuntu:20.04 bash
# Inside container:
ls /tmp/  # container-file.txt won't be here
cat /etc/hostname  # original hostname
exit

# 4. Clean up
docker rm data-test data-test2
```

### Container Diff
```bash
# See what changed in a container
docker run -d --name change-tracker nginx
docker exec change-tracker touch /tmp/new-file.txt
docker exec change-tracker rm /etc/nginx/conf.d/default.conf

# See the changes
docker diff change-tracker
# A = Added, D = Deleted, C = Changed

docker rm -f change-tracker
```

## Advanced Container Operations

### Container Resource Management
```bash
# 1. Run container with resource limits
docker run -d --name resource-limited \
  --memory=512m \
  --cpus="1.0" \
  --memory-swap=1g \
  nginx

# 2. Monitor resource usage
docker stats resource-limited

# 3. Update resource limits (while running)
docker update --memory=256m resource-limited
docker update --cpus="0.5" resource-limited

# 4. Check updated limits
docker inspect resource-limited | grep -A 10 "Memory\|Cpu"

docker rm -f resource-limited
```

### Container Networking Basics
```bash
# 1. Run container with custom network settings
docker run -d --name network-test \
  -p 8080:80 \
  --hostname my-web-server \
  nginx

# 2. Inspect network configuration
docker inspect network-test | grep -A 20 "NetworkSettings"

# 3. Test connectivity
curl http://localhost:8080

# 4. Check container's view of network
docker exec network-test hostname
docker exec network-test ip addr show
docker exec network-test cat /etc/hosts

docker rm -f network-test
```

## Hands-On Exercise 3: Multi-Container Application

Let's create a simple multi-container setup:

```bash
# 1. Run a database container
docker run -d --name my-postgres \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=myapp \
  postgres:13

# 2. Wait for database to start
sleep 10

# 3. Run an application container that connects to database
docker run -d --name my-app \
  --link my-postgres:db \
  -e DATABASE_URL=postgresql://postgres:mypassword@db:5432/myapp \
  -p 8080:80 \
  nginx

# 4. Check both containers are running
docker ps

# 5. Test connectivity between containers
docker exec my-app ping db
docker exec my-app nslookup db

# 6. Check environment variables
docker exec my-app env | grep DATABASE

# 7. View logs
docker logs my-postgres
docker logs my-app

# 8. Clean up
docker rm -f my-postgres my-app
```

## Image Management Deep Dive

### Image Tagging and Versioning
```bash
# 1. Pull different versions
docker pull nginx:1.20
docker pull nginx:1.21
docker pull nginx:latest

# 2. Tag images with custom names
docker tag nginx:1.20 my-nginx:stable
docker tag nginx:1.21 my-nginx:testing
docker tag nginx:latest my-nginx:latest

# 3. List all nginx-related images
docker images | grep nginx

# 4. Remove specific tags
docker rmi my-nginx:testing
docker rmi nginx:1.20

# 5. Clean up
docker rmi my-nginx:stable my-nginx:latest nginx:1.21 nginx:latest
```

### Image Inspection and Analysis
```bash
# 1. Pull a complex image
docker pull node:16

# 2. Detailed inspection
docker inspect node:16 | jq '.[0].Config'
docker inspect node:16 | jq '.[0].RootFS'

# 3. Layer analysis
docker history node:16 --no-trunc

# 4. Size analysis
docker images node:16
docker system df -v | grep node
```

## Container Debugging and Troubleshooting

### Common Debugging Techniques
```bash
# 1. Run a problematic container
docker run -d --name debug-test \
  -e INVALID_CONFIG=true \
  nginx

# 2. Check if it's running
docker ps -a | grep debug-test

# 3. Check logs for errors
docker logs debug-test

# 4. Execute debugging commands
docker exec debug-test ps aux
docker exec debug-test ls -la /etc/nginx/
docker exec debug-test nginx -t  # test configuration

# 5. Interactive debugging
docker exec -it debug-test bash
# Inside container:
cat /etc/nginx/nginx.conf
nginx -T  # dump configuration
exit

docker rm -f debug-test
```

### Container Health Checks
```bash
# 1. Run container with health check
docker run -d --name health-test \
  --health-cmd="curl -f http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  nginx

# 2. Check health status
docker ps  # shows health status
docker inspect health-test | grep -A 10 "Health"

# 3. Wait and check again
sleep 35
docker ps

docker rm -f health-test
```

## Performance and Optimization

### Container Performance Monitoring
```bash
# 1. Run a resource-intensive container
docker run -d --name perf-test \
  --memory=1g \
  --cpus="2.0" \
  nginx

# 2. Monitor performance
docker stats perf-test

# 3. Check detailed metrics
docker exec perf-test cat /proc/meminfo
docker exec perf-test cat /proc/cpuinfo
docker exec perf-test df -h

docker rm -f perf-test
```

### Image Size Optimization Preview
```bash
# Compare image sizes
docker pull ubuntu:20.04
docker pull alpine:latest
docker pull node:16
docker pull node:16-alpine

# See the difference
docker images | grep -E "(ubuntu|alpine|node)"

# This shows why we'll learn about multi-stage builds later
```

## Hands-On Exercise 4: Container Orchestration Basics

Simulate a simple web application stack:

```bash
# 1. Create a custom network (preview of networking module)
docker network create myapp-network

# 2. Run database
docker run -d --name myapp-db \
  --network myapp-network \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  postgres:13

# 3. Run backend API
docker run -d --name myapp-api \
  --network myapp-network \
  -e DATABASE_URL=postgresql://postgres:secret@myapp-db:5432/myapp \
  -p 8000:80 \
  nginx

# 4. Run frontend
docker run -d --name myapp-frontend \
  --network myapp-network \
  -e API_URL=http://myapp-api:80 \
  -p 3000:80 \
  nginx

# 5. Test the stack
curl http://localhost:3000  # frontend
curl http://localhost:8000  # api

# 6. Check inter-container communication
docker exec myapp-frontend ping myapp-api
docker exec myapp-api ping myapp-db

# 7. Monitor all containers
docker ps
docker stats --no-stream

# 8. Clean up
docker rm -f myapp-db myapp-api myapp-frontend
docker network rm myapp-network
```

## Best Practices Summary

### Image Management
- Use specific tags, not `latest` in production
- Regularly clean up unused images
- Understand layer caching for faster builds

### Container Management
- Use meaningful container names
- Set resource limits appropriately
- Always clean up stopped containers
- Use health checks for critical services

### Security Basics
- Don't run containers as root
- Use read-only filesystems when possible
- Limit container capabilities
- Keep images updated

## Practice Challenges

### Challenge 1: Container States
Create containers in all possible states and practice transitioning between them.

### Challenge 2: Resource Management
Run multiple containers with different resource constraints and monitor their behavior.

### Challenge 3: Data Persistence
Create a container, add data, stop it, and recover the data in a new container.

### Challenge 4: Multi-Container Communication
Set up containers that need to communicate and troubleshoot connectivity issues.

## Troubleshooting Guide

### Container Won't Start
```bash
# Check logs
docker logs CONTAINER_NAME

# Try running interactively
docker run -it IMAGE_NAME bash

# Check resource constraints
docker inspect CONTAINER_NAME | grep -A 5 "Memory\|Cpu"
```

### Container Exits Immediately
```bash
# Check exit code
docker ps -a

# Run with different command
docker run -it IMAGE_NAME bash

# Check if main process is running
docker exec CONTAINER_NAME ps aux
```

### Performance Issues
```bash
# Monitor resources
docker stats

# Check container limits
docker inspect CONTAINER_NAME | grep -A 10 "Resources"

# Check host resources
free -h
df -h
```

## Next Steps

You now have a deep understanding of Docker images and containers:

- ✅ Image layers and caching
- ✅ Container lifecycle management
- ✅ Resource management
- ✅ Basic networking and communication
- ✅ Debugging and troubleshooting

**Ready for Module 3: Dockerfile and Nginx** where you'll learn to create custom images and configure web servers!
