# 🧪 Module 2: Comprehensive Hands-On Labs

## 🎯 Lab Overview

**Total Labs**: 8 Comprehensive Labs  
**Duration**: 12-16 Hours  
**Skill Level**: Beginner to Intermediate  
**Prerequisites**: Docker installed and configured  

These hands-on labs provide practical experience with Docker fundamentals, progressing from basic operations to advanced production scenarios.

## 🔬 Lab 1: Docker Installation & Verification Challenge

### Objective
Master Docker installation across multiple platforms and verify proper configuration.

### Duration: 2-3 Hours

### Prerequisites
- Administrative access to target systems
- Internet connectivity for downloads
- Basic command-line knowledge

### Lab Exercises

#### Exercise 1.1: Multi-Platform Installation
```bash
# Windows (PowerShell as Administrator)
# Download Docker Desktop
Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "DockerDesktopInstaller.exe"
Start-Process -FilePath "DockerDesktopInstaller.exe" -Wait

# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# CentOS/RHEL
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

#### Exercise 1.2: Installation Verification
```bash
# Verify Docker installation
docker --version
docker-compose --version

# Check Docker daemon status
docker info
docker system info

# Test Docker functionality
docker run hello-world

# Verify Docker daemon is running
sudo systemctl status docker  # Linux
# Or check Docker Desktop status on Windows/macOS

# Test container execution
docker run -it --rm ubuntu:20.04 /bin/bash
# Inside container:
cat /etc/os-release
exit
```

#### Exercise 1.3: Configuration Optimization
```bash
# Configure Docker daemon (Linux)
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
EOF

sudo systemctl restart docker

# Verify configuration
docker info | grep -A 10 "Server:"
```

### Expected Outputs
```bash
# docker --version
Docker version 24.0.6, build ed223bc

# docker info (key sections)
Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 1
 Server Version: 24.0.6
 Storage Driver: overlay2
 Logging Driver: json-file
 Cgroup Driver: systemd
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
```

### Troubleshooting Guide
```bash
# Common issues and solutions

# Issue: Permission denied
sudo chmod 666 /var/run/docker.sock
# Or add user to docker group (requires logout/login)

# Issue: Docker daemon not running
sudo systemctl start docker
sudo systemctl enable docker

# Issue: WSL2 backend error (Windows)
# Enable WSL2 feature and update WSL2 kernel

# Issue: Virtualization not enabled
# Enable virtualization in BIOS/UEFI settings
```

## 🔬 Lab 2: Docker Command Mastery Challenge

### Objective
Master essential Docker commands through progressive exercises.

### Duration: 3-4 Hours

### Exercise 2.1: Container Lifecycle Management
```bash
# Basic container operations
docker run -d --name web-server nginx:alpine
docker ps
docker ps -a
docker logs web-server
docker exec -it web-server /bin/sh
# Inside container: ps aux, exit

# Container control
docker stop web-server
docker start web-server
docker restart web-server
docker pause web-server
docker unpause web-server

# Container inspection
docker inspect web-server
docker stats web-server
docker top web-server

# Container cleanup
docker stop web-server
docker rm web-server
```

### Exercise 2.2: Image Management Operations
```bash
# Image operations
docker images
docker pull ubuntu:20.04
docker pull nginx:1.21-alpine
docker images --filter "reference=nginx*"

# Image inspection
docker inspect nginx:alpine
docker history nginx:alpine

# Image tagging
docker tag nginx:alpine my-nginx:v1.0
docker images | grep my-nginx

# Image cleanup
docker rmi my-nginx:v1.0
docker image prune -f
```

### Exercise 2.3: Advanced Container Operations
```bash
# Port mapping and environment variables
docker run -d --name app-server \
  -p 8080:80 \
  -e ENV=production \
  -e DEBUG=false \
  nginx:alpine

# Test connectivity
curl http://localhost:8080

# Volume mounting
mkdir -p /tmp/docker-data
echo "<h1>Custom Page</h1>" > /tmp/docker-data/index.html

docker run -d --name custom-web \
  -p 8081:80 \
  -v /tmp/docker-data:/usr/share/nginx/html:ro \
  nginx:alpine

curl http://localhost:8081

# Resource constraints
docker run -d --name limited-container \
  --memory=512m \
  --cpus=0.5 \
  --restart=unless-stopped \
  nginx:alpine

docker stats limited-container --no-stream
```

### Expected Outputs
```bash
# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp   app-server

# docker stats (sample)
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT   MEM %     NET I/O       BLOCK I/O   PIDS
a1b2c3d4e5f6   app-server   0.00%     3.2MiB / 7.8GiB    0.04%     1.2kB / 0B    0B / 0B     3
```

## 🔬 Lab 3: E-Commerce Application Containerization

### Objective
Containerize the existing e-commerce application with proper networking and storage.

### Duration: 4-5 Hours

### Exercise 3.1: Backend Containerization
```bash
# Navigate to e-commerce project
cd /mnt/c/Users/Shyam/Documents/e-commerce

# Create Dockerfile for backend
cat > backend/Dockerfile <<EOF
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create uploads directory
RUN mkdir -p uploads

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Build backend image
docker build -t ecommerce-backend:v1.0 backend/

# Test backend container
docker run -d --name backend-test \
  -p 8000:8000 \
  -e DATABASE_URL="postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db" \
  ecommerce-backend:v1.0

# Verify backend is running
curl http://localhost:8000/docs
docker logs backend-test
```

### Exercise 3.2: Frontend Containerization
```bash
# Create multi-stage Dockerfile for frontend
cat > frontend/Dockerfile <<EOF
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx configuration
cat > frontend/nginx.conf <<EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    sendfile        on;
    keepalive_timeout  65;
    
    server {
        listen       80;
        server_name  localhost;
        
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files \$uri \$uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass http://backend:8000/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

# Build frontend image
docker build -t ecommerce-frontend:v1.0 frontend/

# Test frontend container
docker run -d --name frontend-test \
  -p 3000:80 \
  ecommerce-frontend:v1.0

curl http://localhost:3000
```

### Exercise 3.3: Multi-Container Networking
```bash
# Create custom network
docker network create ecommerce-network

# Run PostgreSQL container
docker run -d --name postgres-db \
  --network ecommerce-network \
  -e POSTGRES_DB=ecommerce_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:13-alpine

# Run backend with network
docker run -d --name backend-app \
  --network ecommerce-network \
  -p 8000:8000 \
  -e DATABASE_URL="postgresql://postgres:admin@postgres-db:5432/ecommerce_db" \
  ecommerce-backend:v1.0

# Run frontend with network
docker run -d --name frontend-app \
  --network ecommerce-network \
  -p 3000:80 \
  ecommerce-frontend:v1.0

# Test full application
curl http://localhost:3000
curl http://localhost:8000/docs

# Check network connectivity
docker exec backend-app ping postgres-db
docker exec frontend-app ping backend-app
```

### Expected Outputs
```bash
# docker images
REPOSITORY           TAG       IMAGE ID       CREATED         SIZE
ecommerce-frontend   v1.0      abc123def456   2 minutes ago   25.3MB
ecommerce-backend    v1.0      def456ghi789   5 minutes ago   145MB

# docker network ls
NETWORK ID     NAME               DRIVER    SCOPE
abc123def456   ecommerce-network  bridge    local

# Application health check
HTTP/1.1 200 OK
Content-Type: application/json
{"status": "healthy", "timestamp": "2024-09-01T09:00:00Z"}
```

## 🔬 Lab 4: Docker Security Implementation

### Objective
Implement comprehensive Docker security practices and vulnerability scanning.

### Duration: 2-3 Hours

### Exercise 4.1: Image Vulnerability Scanning
```bash
# Install Trivy scanner
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan base images
trivy image python:3.11-slim
trivy image nginx:alpine
trivy image postgres:13-alpine

# Scan custom images
trivy image ecommerce-backend:v1.0
trivy image ecommerce-frontend:v1.0

# Generate detailed reports
trivy image --format json --output backend-scan.json ecommerce-backend:v1.0
trivy image --format table --severity HIGH,CRITICAL ecommerce-backend:v1.0
```

### Exercise 4.2: Secure Container Configuration
```bash
# Create non-root user Dockerfile
cat > backend/Dockerfile.secure <<EOF
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Install dependencies as root
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application and change ownership
COPY . .
RUN chown -R appuser:appuser /app
RUN mkdir -p uploads && chown appuser:appuser uploads

# Switch to non-root user
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Build secure image
docker build -f backend/Dockerfile.secure -t ecommerce-backend:secure backend/

# Run with security constraints
docker run -d --name secure-backend \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /app/uploads \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  -p 8001:8000 \
  ecommerce-backend:secure

# Verify non-root execution
docker exec secure-backend whoami
docker exec secure-backend id
```

### Exercise 4.3: Runtime Security Monitoring
```bash
# Create security monitoring script
cat > security-monitor.sh <<'EOF'
#!/bin/bash

echo "=== Docker Security Audit ==="
echo "Date: $(date)"
echo

echo "1. Running containers with root user:"
docker ps --format "table {{.Names}}\t{{.Image}}" | while read name image; do
    if [ "$name" != "NAMES" ]; then
        user=$(docker exec $name whoami 2>/dev/null || echo "N/A")
        if [ "$user" = "root" ]; then
            echo "  ⚠️  $name ($image) - Running as root"
        else
            echo "  ✅ $name ($image) - Running as $user"
        fi
    fi
done

echo
echo "2. Containers with privileged access:"
docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} --format '{{.Name}}: Privileged={{.HostConfig.Privileged}}'

echo
echo "3. Containers with host network:"
docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} --format '{{.Name}}: NetworkMode={{.HostConfig.NetworkMode}}'

echo
echo "4. Images with known vulnerabilities:"
docker images --format "{{.Repository}}:{{.Tag}}" | head -5 | while read image; do
    echo "Scanning $image..."
    trivy image --severity HIGH,CRITICAL --quiet $image | grep -c "Total:" || echo "  ✅ No high/critical vulnerabilities"
done
EOF

chmod +x security-monitor.sh
./security-monitor.sh
```

### Expected Outputs
```bash
# Trivy scan results
Total: 15 (HIGH: 3, CRITICAL: 1)

# Security audit results
=== Docker Security Audit ===
1. Running containers with root user:
  ✅ secure-backend (ecommerce-backend:secure) - Running as appuser
  ⚠️  postgres-db (postgres:13-alpine) - Running as root

2. Containers with privileged access:
/secure-backend: Privileged=false
/postgres-db: Privileged=false
```

## 🔬 Lab 5: Performance Optimization & Monitoring

### Objective
Optimize Docker containers for production performance and implement monitoring.

### Duration: 2-3 Hours

### Exercise 5.1: Resource Optimization
```bash
# Create optimized multi-stage Dockerfile
cat > backend/Dockerfile.optimized <<EOF
# Build stage
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Install runtime dependencies only
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application
COPY . .
RUN chown -R appuser:appuser /app

USER appuser

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
EOF

# Build optimized image
docker build -f backend/Dockerfile.optimized -t ecommerce-backend:optimized backend/

# Compare image sizes
docker images | grep ecommerce-backend
```

### Exercise 5.2: Performance Testing & Monitoring
```bash
# Create performance monitoring script
cat > performance-monitor.sh <<'EOF'
#!/bin/bash

echo "=== Docker Performance Monitor ==="
echo "Timestamp: $(date)"
echo

# Container resource usage
echo "1. Container Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

echo
echo "2. System Resource Usage:"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{printf "%s", $5}')"

echo
echo "3. Docker System Usage:"
docker system df

echo
echo "4. Network Performance:"
for container in $(docker ps --format "{{.Names}}"); do
    echo "Container: $container"
    docker exec $container ping -c 3 google.com 2>/dev/null | tail -1 || echo "  Network test failed"
done
EOF

chmod +x performance-monitor.sh

# Run performance test
./performance-monitor.sh

# Load testing with Apache Bench (if available)
# ab -n 1000 -c 10 http://localhost:8000/
```

### Exercise 5.3: Container Optimization
```bash
# Run containers with optimized settings
docker run -d --name optimized-backend \
  --memory=512m \
  --memory-swap=512m \
  --cpus=1.0 \
  --restart=unless-stopped \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  -p 8002:8000 \
  ecommerce-backend:optimized

# Monitor performance
docker stats optimized-backend --no-stream

# Test application response time
time curl -s http://localhost:8002/docs > /dev/null

# Check container health
docker inspect optimized-backend --format='{{.State.Health.Status}}'
```

### Expected Outputs
```bash
# Image size comparison
ecommerce-backend    optimized   def456ghi789   2 minutes ago   98.2MB
ecommerce-backend    v1.0        abc123def456   1 hour ago      145MB
ecommerce-backend    secure      ghi789jkl012   30 minutes ago  147MB

# Performance stats
CONTAINER          CPU %     MEM USAGE / LIMIT   MEM %     NET I/O       BLOCK I/O
optimized-backend  2.45%     45.2MiB / 512MiB    8.83%     1.2kB / 648B  0B / 0B

# Response time
real    0m0.156s
user    0m0.008s
sys     0m0.012s
```

## 🎯 Lab Assessment & Certification

### Final Challenge: Complete E-Commerce Deployment

Deploy the entire e-commerce application with:
- Secure, optimized containers
- Proper networking and storage
- Monitoring and logging
- Security scanning and compliance

### Success Criteria
- [ ] All containers running without root privileges
- [ ] No high/critical vulnerabilities in images
- [ ] Application responds within 200ms
- [ ] Proper resource constraints applied
- [ ] Monitoring and logging configured
- [ ] Network security implemented

### Certification Requirements
1. Complete all 5 labs successfully
2. Pass the final deployment challenge
3. Demonstrate command-line proficiency
4. Explain Docker concepts and best practices
5. Troubleshoot common issues independently

---

**🎉 Congratulations! You've mastered Docker fundamentals through hands-on practice!**

**Next Steps**: Module 3 - Dockerfile Mastery & Nginx Configuration
