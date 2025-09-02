# 🎯 Module 2: Docker Fundamentals - Completion Assessment

## 📋 Assessment Overview

**Assessment Type**: Comprehensive Practical Evaluation  
**Duration**: 4-6 Hours  
**Passing Score**: 80% (240/300 points)  
**Prerequisites**: All Module 2 content completed  

This assessment validates your Docker fundamentals mastery through practical exercises, real-world scenarios, and comprehensive evaluation of skills acquired throughout Module 2.

## 🎯 Assessment Structure

### Part A: Knowledge Assessment (100 points - 33%)
**Duration**: 1 hour  
**Format**: Practical command execution and explanation  

### Part B: Hands-On Implementation (150 points - 50%)
**Duration**: 3-4 hours  
**Format**: Complete Docker project implementation  

### Part C: Troubleshooting & Optimization (50 points - 17%)
**Duration**: 1 hour  
**Format**: Problem-solving scenarios  

## 📚 Part A: Knowledge Assessment (100 points)

### Section A1: Docker Installation & Configuration (25 points)

#### Task A1.1: Multi-Platform Installation Verification (10 points)
```bash
# Demonstrate Docker installation verification on your system
# Execute and explain each command

# 1. Check Docker version and build information
docker --version
docker version

# 2. Verify Docker daemon status and configuration
docker info
docker system info

# 3. Test Docker functionality
docker run hello-world

# 4. Show Docker system resource usage
docker system df
```

**Expected Response**: Provide command outputs and explain what each command reveals about your Docker installation.

#### Task A1.2: Docker Daemon Configuration (15 points)
```bash
# Configure Docker daemon with custom settings
# Create and explain daemon.json configuration

# 1. Show current daemon configuration
docker info | grep -A 20 "Server:"

# 2. Create custom daemon configuration (explain each setting)
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

# 3. Restart Docker and verify configuration
sudo systemctl restart docker
docker info | grep -A 10 "Logging Driver"
```

**Evaluation Criteria**:
- Correct command execution (5 points)
- Proper configuration explanation (5 points)
- Understanding of daemon settings (5 points)

### Section A2: Container Lifecycle Management (25 points)

#### Task A2.1: Advanced Container Operations (15 points)
```bash
# Demonstrate complete container lifecycle management

# 1. Run container with comprehensive configuration
docker run -d --name assessment-web \
  --restart=unless-stopped \
  --memory=256m \
  --cpus=0.5 \
  -p 8080:80 \
  -e ENV=production \
  -v /tmp/web-data:/usr/share/nginx/html:ro \
  nginx:alpine

# 2. Monitor and inspect container
docker ps
docker stats assessment-web --no-stream
docker inspect assessment-web | jq '.[0].Config'
docker logs assessment-web

# 3. Execute commands in container
docker exec assessment-web ps aux
docker exec -it assessment-web /bin/sh
# Inside container: whoami, pwd, ls -la, exit

# 4. Container control operations
docker pause assessment-web
docker unpause assessment-web
docker stop assessment-web
docker start assessment-web
```

#### Task A2.2: Container Resource Management (10 points)
```bash
# Demonstrate resource constraint management

# 1. Run container with strict resource limits
docker run -d --name resource-test \
  --memory=128m \
  --memory-swap=128m \
  --cpus=0.25 \
  --pids-limit=50 \
  nginx:alpine

# 2. Test resource constraints
docker exec resource-test stress --vm 1 --vm-bytes 150M --timeout 10s
docker stats resource-test --no-stream

# 3. Update resource limits
docker update --memory=256m --cpus=0.5 resource-test
docker inspect resource-test | jq '.[0].HostConfig.Memory'
```

**Evaluation Criteria**:
- Correct parameter usage (8 points)
- Resource monitoring understanding (7 points)
- Container control proficiency (10 points)

### Section A3: Image Management (25 points)

#### Task A3.1: Image Operations Mastery (15 points)
```bash
# Demonstrate comprehensive image management

# 1. Image discovery and analysis
docker search nginx --limit 5
docker pull nginx:1.21-alpine
docker images --filter "reference=nginx*"

# 2. Image inspection and history
docker inspect nginx:1.21-alpine | jq '.[0].Config'
docker history nginx:1.21-alpine

# 3. Image tagging and management
docker tag nginx:1.21-alpine my-nginx:v1.0
docker tag nginx:1.21-alpine my-nginx:latest
docker images | grep my-nginx

# 4. Image cleanup
docker rmi my-nginx:v1.0
docker image prune -f
```

#### Task A3.2: Registry Operations (10 points)
```bash
# Demonstrate Docker Hub integration

# 1. Login to Docker Hub (use test account)
docker login

# 2. Push custom image (create simple one first)
echo "FROM alpine:latest" > Dockerfile
echo "RUN echo 'Assessment Test' > /test.txt" >> Dockerfile
docker build -t assessment-test:v1.0 .
docker tag assessment-test:v1.0 yourusername/assessment-test:v1.0
docker push yourusername/assessment-test:v1.0

# 3. Pull and verify
docker rmi yourusername/assessment-test:v1.0
docker pull yourusername/assessment-test:v1.0
docker run --rm yourusername/assessment-test:v1.0 cat /test.txt
```

**Evaluation Criteria**:
- Image manipulation skills (8 points)
- Registry operations (7 points)
- Understanding of image layers (10 points)

### Section A4: Networking & Storage (25 points)

#### Task A4.1: Network Configuration (15 points)
```bash
# Demonstrate Docker networking mastery

# 1. Create custom network
docker network create --driver bridge assessment-network
docker network ls
docker network inspect assessment-network

# 2. Run containers on custom network
docker run -d --name web-server \
  --network assessment-network \
  nginx:alpine

docker run -d --name app-server \
  --network assessment-network \
  httpd:alpine

# 3. Test inter-container communication
docker exec web-server ping -c 3 app-server
docker exec app-server nslookup web-server
```

#### Task A4.2: Volume Management (10 points)
```bash
# Demonstrate volume management

# 1. Create and use named volume
docker volume create assessment-data
docker volume ls
docker volume inspect assessment-data

# 2. Use volume with container
docker run -d --name data-container \
  -v assessment-data:/data \
  alpine:latest sleep 3600

# 3. Test data persistence
docker exec data-container sh -c "echo 'Persistent data' > /data/test.txt"
docker stop data-container
docker rm data-container

docker run --rm -v assessment-data:/data alpine:latest cat /data/test.txt
```

**Evaluation Criteria**:
- Network creation and management (8 points)
- Container communication (7 points)
- Volume operations (10 points)

## 🛠️ Part B: Hands-On Implementation (150 points)

### Project: Complete E-Commerce Application Containerization

**Objective**: Containerize the existing e-commerce application with production-ready configuration, security, and optimization.

### Task B1: Application Analysis & Planning (20 points)

#### Requirements Analysis
```bash
# 1. Analyze the e-commerce application structure
cd /mnt/c/Users/Shyam/Documents/e-commerce
find . -name "*.py" -o -name "*.js" -o -name "*.json" | head -20
ls -la backend/ frontend/

# 2. Identify dependencies and requirements
cat backend/requirements.txt
cat frontend/package.json

# 3. Plan containerization strategy
# Document your approach for:
# - Backend containerization
# - Frontend containerization  
# - Database integration
# - Network architecture
# - Security considerations
```

**Deliverable**: Written containerization plan (500 words) explaining your approach.

### Task B2: Backend Containerization (40 points)

#### Secure Backend Container Implementation
```dockerfile
# Create backend/Dockerfile.production
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

WORKDIR /app

# Copy application code
COPY . .
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Update PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

#### Implementation Commands
```bash
# Build and test backend container
docker build -f backend/Dockerfile.production -t ecommerce-backend:prod backend/

# Run with security constraints
docker run -d --name backend-prod \
  --read-only \
  --tmpfs /tmp \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --memory=512m \
  --cpus=1.0 \
  -p 8000:8000 \
  -e DATABASE_URL="postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db" \
  ecommerce-backend:prod

# Verify security and functionality
docker exec backend-prod whoami
curl http://localhost:8000/docs
```

**Evaluation Criteria**:
- Multi-stage build implementation (10 points)
- Security best practices (10 points)
- Non-root user configuration (10 points)
- Health check implementation (5 points)
- Resource optimization (5 points)

### Task B3: Frontend Containerization (40 points)

#### Optimized Frontend Container
```dockerfile
# Create frontend/Dockerfile.production
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production stage
FROM nginx:alpine

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.prod.conf /etc/nginx/nginx.conf

# Change ownership
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

#### Nginx Configuration
```nginx
# Create frontend/nginx.prod.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    sendfile        on;
    keepalive_timeout  65;
    
    server {
        listen       8080;
        server_name  localhost;
        
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files $uri $uri/ /index.html;
        }
        
        location /api/ {
            proxy_pass http://backend:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
```

**Evaluation Criteria**:
- Multi-stage build optimization (10 points)
- Nginx configuration (10 points)
- Security headers implementation (10 points)
- Non-root execution (5 points)
- Build optimization (5 points)

### Task B4: Multi-Container Orchestration (30 points)

#### Docker Compose Production Configuration
```yaml
# Create docker-compose.prod.yml
version: '3.8'

services:
  database:
    image: postgres:13-alpine
    container_name: ecommerce-db-prod
    environment:
      POSTGRES_DB: ecommerce_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ecommerce-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.production
    container_name: ecommerce-backend-prod
    environment:
      DATABASE_URL: postgresql://postgres:admin@database:5432/ecommerce_db
    depends_on:
      database:
        condition: service_healthy
    networks:
      - ecommerce-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.production
    container_name: ecommerce-frontend-prod
    ports:
      - "3000:8080"
    depends_on:
      - backend
    networks:
      - ecommerce-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'

networks:
  ecommerce-network:
    driver: bridge

volumes:
  postgres_data:
```

#### Deployment Commands
```bash
# Deploy production environment
docker-compose -f docker-compose.prod.yml up -d

# Verify deployment
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs

# Test application
curl http://localhost:3000
curl http://localhost:3000/api/docs
```

**Evaluation Criteria**:
- Compose file structure (10 points)
- Service dependencies (5 points)
- Resource constraints (5 points)
- Network configuration (5 points)
- Health checks (5 points)

### Task B5: Security Implementation (20 points)

#### Security Scanning and Hardening
```bash
# 1. Install and run Trivy scanner
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# 2. Scan all images for vulnerabilities
trivy image ecommerce-backend:prod
trivy image ecommerce-frontend:prod
trivy image postgres:13-alpine

# 3. Generate security report
trivy image --format json --output security-report.json ecommerce-backend:prod

# 4. Implement runtime security
docker run -d --name secure-backend \
  --read-only \
  --tmpfs /tmp \
  --security-opt no-new-privileges:true \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --user 1001:1001 \
  ecommerce-backend:prod

# 5. Security audit script
cat > security-audit.sh <<'EOF'
#!/bin/bash
echo "=== Docker Security Audit ==="
echo "1. Containers running as root:"
docker ps --format "{{.Names}}" | xargs -I {} docker exec {} whoami 2>/dev/null | grep -v "appuser\|nginx"

echo "2. Privileged containers:"
docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} --format '{{.Name}}: {{.HostConfig.Privileged}}'

echo "3. Containers with host network:"
docker ps --format "{{.Names}}" | xargs -I {} docker inspect {} --format '{{.Name}}: {{.HostConfig.NetworkMode}}'
EOF

chmod +x security-audit.sh
./security-audit.sh
```

**Evaluation Criteria**:
- Vulnerability scanning (5 points)
- Security configuration (5 points)
- Runtime security (5 points)
- Security audit implementation (5 points)

## 🔧 Part C: Troubleshooting & Optimization (50 points)

### Scenario C1: Performance Issues (25 points)

#### Problem Description
Your e-commerce application is experiencing slow response times and high resource usage. Containers are consuming excessive CPU and memory.

#### Tasks
```bash
# 1. Diagnose performance issues
docker stats --no-stream
docker system df
docker system events --since 1h

# 2. Identify bottlenecks
docker exec backend-prod top
docker exec backend-prod free -h
docker logs backend-prod --tail 100

# 3. Implement optimizations
# - Adjust resource limits
# - Optimize container configuration
# - Implement monitoring

# 4. Measure improvements
# Before and after performance metrics
```

**Deliverable**: Performance analysis report with before/after metrics and optimization steps.

### Scenario C2: Container Communication Issues (25 points)

#### Problem Description
Frontend container cannot communicate with backend container. API calls are failing with connection refused errors.

#### Tasks
```bash
# 1. Diagnose network issues
docker network ls
docker network inspect ecommerce-network
docker exec frontend-prod ping backend-prod

# 2. Test connectivity
docker exec frontend-prod nslookup backend-prod
docker exec frontend-prod curl http://backend-prod:8000/health

# 3. Fix network configuration
# Implement solution and verify

# 4. Document resolution steps
```

**Deliverable**: Network troubleshooting report with diagnostic steps and solution implementation.

## 📊 Assessment Scoring

### Scoring Breakdown
| Section | Points | Weight | Criteria |
|---------|--------|--------|----------|
| **Part A: Knowledge** | 100 | 33% | Command proficiency, concept understanding |
| **Part B: Implementation** | 150 | 50% | Practical skills, security, optimization |
| **Part C: Troubleshooting** | 50 | 17% | Problem-solving, diagnostic skills |
| **Total** | 300 | 100% | Overall Docker mastery |

### Grading Scale
- **Expert (270-300 points)**: 90-100% - Ready for advanced Docker topics
- **Proficient (240-269 points)**: 80-89% - Solid Docker fundamentals
- **Developing (180-239 points)**: 60-79% - Needs additional practice
- **Novice (0-179 points)**: 0-59% - Requires Module 2 review

## 🎯 Success Criteria

### Technical Requirements
- [ ] All containers run without root privileges
- [ ] No high/critical vulnerabilities in images
- [ ] Application responds within 500ms
- [ ] Proper resource constraints applied
- [ ] Security best practices implemented
- [ ] Multi-container networking functional

### Skill Demonstration
- [ ] Execute 50+ Docker commands proficiently
- [ ] Build optimized, secure container images
- [ ] Configure multi-container applications
- [ ] Implement security scanning and hardening
- [ ] Troubleshoot common Docker issues
- [ ] Optimize container performance

## 📋 Submission Requirements

### Deliverables
1. **Command Execution Log**: All commands with outputs
2. **Containerization Plan**: Written strategy document
3. **Docker Files**: All Dockerfiles and configurations
4. **Security Report**: Vulnerability scan results and mitigations
5. **Performance Report**: Before/after optimization metrics
6. **Troubleshooting Report**: Problem diagnosis and solutions

### Submission Format
```
Module-2-Assessment-[YourName]/
├── command-log.txt
├── containerization-plan.md
├── dockerfiles/
│   ├── backend/Dockerfile.production
│   ├── frontend/Dockerfile.production
│   └── docker-compose.prod.yml
├── security/
│   ├── security-report.json
│   ├── security-audit.sh
│   └── vulnerability-analysis.md
├── performance/
│   ├── before-metrics.txt
│   ├── after-metrics.txt
│   └── optimization-report.md
└── troubleshooting/
    ├── network-diagnosis.md
    └── performance-diagnosis.md
```

## 🎉 Certification

Upon successful completion (≥240 points), you will receive:

- **Docker Fundamentals Mastery Certificate**
- **Module 2 Completion Badge**
- **Recommendation for Module 3**
- **Portfolio Project Recognition**

## 🚀 Next Steps

After passing this assessment:

1. **Module 3**: Dockerfile Mastery & Nginx Configuration
2. **Advanced Topics**: Docker Compose, Swarm, Security
3. **Cloud Integration**: AWS Container Services
4. **Career Development**: DevOps and Cloud Engineering roles

---

**🎯 Assessment Timeline**: Complete within 2 weeks of Module 2 content completion  
**🔄 Retake Policy**: One retake allowed after additional study  
**📞 Support**: Instructor available for clarification questions  

**Good luck with your Docker Fundamentals Assessment! 🐳**
