# 🔧 Module 2: Complete Troubleshooting Guide

## 🎯 Overview

This comprehensive troubleshooting guide covers all common Docker issues encountered during Module 2, with detailed solutions, diagnostic commands, and prevention strategies.

## 🚨 Installation Issues

### Issue 1: Docker Installation Fails

#### Symptoms
```bash
# Error messages during installation
E: Package 'docker-ce' has no installation candidate
curl: (7) Failed to connect to download.docker.com port 443
Permission denied while trying to connect to the Docker daemon socket
```

#### Diagnostic Commands
```bash
# Check system compatibility
uname -a
lsb_release -a
cat /etc/os-release

# Check internet connectivity
ping -c 3 download.docker.com
curl -I https://download.docker.com

# Check existing Docker installations
which docker
docker --version 2>/dev/null || echo "Docker not found"
```

#### Solutions

**Ubuntu/Debian Systems:**
```bash
# Remove old Docker versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify installation
sudo docker run hello-world
```

**CentOS/RHEL Systems:**
```bash
# Remove old versions
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# Install yum-utils
sudo yum install -y yum-utils

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
sudo docker run hello-world
```

### Issue 2: Permission Denied Errors

#### Symptoms
```bash
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

#### Solutions
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group membership (logout/login or use newgrp)
newgrp docker

# Alternative: Change socket permissions (temporary)
sudo chmod 666 /var/run/docker.sock

# Verify fix
docker run hello-world
```

### Issue 3: WSL2 Backend Issues (Windows)

#### Symptoms
```bash
Docker Desktop - WSL 2 installation is incomplete
The WSL 2 Linux kernel is now installed using a separate MSI update package
```

#### Solutions
```bash
# Enable WSL2 feature (PowerShell as Administrator)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer, then download and install WSL2 kernel update
# https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

# Set WSL2 as default version
wsl --set-default-version 2

# Verify WSL2 installation
wsl --list --verbose
```

## 🐳 Container Runtime Issues

### Issue 4: Container Won't Start

#### Symptoms
```bash
docker: Error response from daemon: driver failed programming external connectivity
docker: Error response from daemon: Conflict. The container name "/myapp" is already in use
```

#### Diagnostic Commands
```bash
# Check container status
docker ps -a
docker logs <container_name>
docker inspect <container_name>

# Check port usage
netstat -tulpn | grep <port>
lsof -i :<port>

# Check system resources
docker system df
docker system events --since 1h
```

#### Solutions
```bash
# Remove conflicting containers
docker rm -f <container_name>

# Use different port mapping
docker run -p 8081:80 nginx:alpine

# Check and kill processes using ports
sudo lsof -ti:8080 | xargs sudo kill -9

# Clean up stopped containers
docker container prune -f

# Restart Docker daemon
sudo systemctl restart docker
```

### Issue 5: Container Exits Immediately

#### Symptoms
```bash
# Container starts but exits with code 0 or 1
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS                     PORTS     NAMES
abc123def456   nginx     "nginx"   1 min ago Exited (1) 1 minute ago              test
```

#### Diagnostic Commands
```bash
# Check container logs
docker logs <container_name>

# Run container interactively
docker run -it <image> /bin/bash

# Check container configuration
docker inspect <container_name> | jq '.[0].Config'
```

#### Solutions
```bash
# Common fixes for different scenarios

# 1. Wrong command or entrypoint
docker run -it --entrypoint /bin/bash nginx:alpine

# 2. Missing environment variables
docker run -e REQUIRED_VAR=value <image>

# 3. Permission issues
docker run --user $(id -u):$(id -g) <image>

# 4. Resource constraints
docker run --memory=1g --cpus=1.0 <image>

# 5. Volume mount issues
docker run -v /host/path:/container/path:Z <image>  # SELinux systems
```

## 🌐 Networking Issues

### Issue 6: Port Binding Failures

#### Symptoms
```bash
Error starting userland proxy: listen tcp 0.0.0.0:80: bind: address already in use
```

#### Diagnostic Commands
```bash
# Check what's using the port
sudo netstat -tulpn | grep :80
sudo lsof -i :80

# Check Docker port mappings
docker port <container_name>
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

#### Solutions
```bash
# Kill process using the port
sudo kill -9 $(sudo lsof -t -i:80)

# Use different host port
docker run -p 8080:80 nginx:alpine

# Stop conflicting containers
docker stop $(docker ps -q --filter "publish=80")

# Use host networking (Linux only)
docker run --network host nginx:alpine
```

### Issue 7: Container-to-Container Communication

#### Symptoms
```bash
# Containers can't communicate with each other
curl: (7) Failed to connect to backend port 8000: Connection refused
```

#### Diagnostic Commands
```bash
# Check network configuration
docker network ls
docker network inspect bridge

# Test connectivity between containers
docker exec <container1> ping <container2>
docker exec <container1> nslookup <container2>

# Check container IPs
docker inspect <container> | grep IPAddress
```

#### Solutions
```bash
# Create custom network
docker network create mynetwork

# Run containers on same network
docker run -d --name backend --network mynetwork myapp:backend
docker run -d --name frontend --network mynetwork myapp:frontend

# Use container names for communication
# In frontend container: curl http://backend:8000/api

# Check network connectivity
docker exec frontend ping backend
docker exec frontend curl http://backend:8000/health
```

## 💾 Storage and Volume Issues

### Issue 8: Volume Mount Problems

#### Symptoms
```bash
# Permission denied when accessing mounted volumes
ls: cannot access '/data': Permission denied
```

#### Diagnostic Commands
```bash
# Check volume mounts
docker inspect <container> | grep -A 10 Mounts

# Check host directory permissions
ls -la /host/path
stat /host/path

# Check container user
docker exec <container> id
docker exec <container> ls -la /mounted/path
```

#### Solutions
```bash
# Fix host directory permissions
sudo chown -R $(id -u):$(id -g) /host/path
sudo chmod -R 755 /host/path

# Use correct user in container
docker run --user $(id -u):$(id -g) -v /host/path:/container/path <image>

# SELinux systems - add :Z flag
docker run -v /host/path:/container/path:Z <image>

# Create named volume instead
docker volume create myvolume
docker run -v myvolume:/data <image>
```

### Issue 9: Disk Space Issues

#### Symptoms
```bash
no space left on device
Error response from daemon: mkdir /var/lib/docker/tmp: no space left on device
```

#### Diagnostic Commands
```bash
# Check disk usage
df -h
docker system df
docker system df -v

# Check Docker root directory
sudo du -sh /var/lib/docker/*
```

#### Solutions
```bash
# Clean up Docker resources
docker system prune -a -f
docker volume prune -f
docker network prune -f

# Remove unused images
docker image prune -a -f

# Remove specific large images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k 3 -h
docker rmi <large_image_id>

# Clean up build cache
docker builder prune -a -f

# Move Docker root directory (if needed)
sudo systemctl stop docker
sudo mv /var/lib/docker /new/location/docker
sudo ln -s /new/location/docker /var/lib/docker
sudo systemctl start docker
```

## 🔒 Security Issues

### Issue 10: Image Vulnerability Warnings

#### Symptoms
```bash
# Trivy or other scanners report vulnerabilities
Total: 45 (UNKNOWN: 0, LOW: 12, MEDIUM: 28, HIGH: 4, CRITICAL: 1)
```

#### Diagnostic Commands
```bash
# Scan images for vulnerabilities
trivy image <image_name>
docker scout cves <image_name>

# Check image layers
docker history <image_name>
dive <image_name>  # If dive tool is installed
```

#### Solutions
```bash
# Use minimal base images
FROM alpine:3.18
FROM distroless/java:11
FROM scratch  # For static binaries

# Update base images regularly
docker pull alpine:latest
docker build --no-cache -t myapp:latest .

# Multi-stage builds to reduce attack surface
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM alpine:3.18
RUN apk add --no-cache nodejs npm
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "app.js"]

# Run as non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs
```

### Issue 11: Container Running as Root

#### Symptoms
```bash
# Security scanners flag root execution
Container running as root user (UID 0)
```

#### Solutions
```bash
# Create non-root user in Dockerfile
FROM ubuntu:20.04
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Run container with specific user
docker run --user 1001:1001 <image>

# Use security options
docker run --security-opt no-new-privileges:true \
           --cap-drop ALL \
           --cap-add NET_BIND_SERVICE \
           <image>
```

## 🚀 Performance Issues

### Issue 12: Slow Container Performance

#### Symptoms
```bash
# High CPU/memory usage, slow response times
Container using 100% CPU
Application response time > 5 seconds
```

#### Diagnostic Commands
```bash
# Monitor container resources
docker stats <container_name>
docker exec <container> top
docker exec <container> free -h

# Check container limits
docker inspect <container> | grep -A 10 Resources
```

#### Solutions
```bash
# Set appropriate resource limits
docker run --memory=512m --cpus=1.0 <image>

# Optimize Dockerfile
# Use multi-stage builds
# Minimize layers
# Use .dockerignore

# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker build .

# Use layer caching
docker build --cache-from <image> .
```

### Issue 13: Build Performance Issues

#### Symptoms
```bash
# Slow Docker builds, large image sizes
Build time: 15+ minutes
Image size: 2GB+
```

#### Solutions
```bash
# Create .dockerignore file
cat > .dockerignore <<EOF
node_modules
.git
.gitignore
README.md
Dockerfile
.dockerignore
npm-debug.log
coverage
.nyc_output
EOF

# Optimize layer ordering
# Put frequently changing files last
COPY package*.json ./
RUN npm install
COPY . .

# Use multi-stage builds
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
```

## 🔍 Debugging Techniques

### Advanced Debugging Commands

```bash
# Container debugging
docker exec -it <container> /bin/bash
docker logs -f --tail 100 <container>
docker inspect <container> | jq '.[0].State'

# Network debugging
docker network inspect <network>
docker exec <container> netstat -tulpn
docker exec <container> ss -tulpn

# Process debugging
docker exec <container> ps aux
docker exec <container> pstree
docker top <container>

# File system debugging
docker exec <container> df -h
docker exec <container> mount
docker diff <container>

# System debugging
docker system events --since 1h
docker system info
journalctl -u docker.service --since "1 hour ago"
```

### Debugging Checklist

1. **Check container status**: `docker ps -a`
2. **Review logs**: `docker logs <container>`
3. **Inspect configuration**: `docker inspect <container>`
4. **Test connectivity**: `docker exec <container> ping <target>`
5. **Check resources**: `docker stats <container>`
6. **Verify mounts**: `docker exec <container> mount`
7. **Check processes**: `docker exec <container> ps aux`
8. **Review events**: `docker system events`

## 📋 Prevention Strategies

### Best Practices Checklist

- [ ] Use official base images from trusted sources
- [ ] Keep base images updated regularly
- [ ] Implement multi-stage builds for optimization
- [ ] Run containers as non-root users
- [ ] Set appropriate resource limits
- [ ] Use health checks for containers
- [ ] Implement proper logging strategies
- [ ] Regular security scanning of images
- [ ] Use .dockerignore to exclude unnecessary files
- [ ] Monitor container performance and resources

### Monitoring Setup

```bash
# Set up basic monitoring
docker run -d --name monitoring \
  -p 9090:9090 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  prom/prometheus

# Container health checks
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Log management
docker run --log-driver=json-file \
           --log-opt max-size=10m \
           --log-opt max-file=3 \
           <image>
```

## 🆘 Emergency Recovery

### Complete Docker Reset

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Remove all volumes
docker volume rm $(docker volume ls -q)

# Remove all networks (except defaults)
docker network rm $(docker network ls -q)

# Clean system
docker system prune -a -f --volumes

# Restart Docker daemon
sudo systemctl restart docker
```

### System Recovery

```bash
# If Docker daemon won't start
sudo systemctl status docker
sudo journalctl -u docker.service

# Reset Docker daemon configuration
sudo rm /etc/docker/daemon.json
sudo systemctl restart docker

# Reinstall Docker (last resort)
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
# Then reinstall following installation guide
```

---

**🎯 Remember**: Most Docker issues can be resolved by understanding the root cause through proper diagnostics. Always check logs first, then inspect configuration, and finally test connectivity and resources.

**Next Module**: Dockerfile Mastery & Nginx Configuration
