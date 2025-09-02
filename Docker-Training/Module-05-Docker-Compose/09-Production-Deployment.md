# Production Deployment - E-Commerce Production Readiness

## 📋 Learning Objectives
- **Master** production-ready configurations and optimizations
- **Understand** security hardening for production environments
- **Apply** performance tuning and resource optimization
- **Build** robust deployment strategies and rollback procedures

---

## 🤔 Development vs Production: The Critical Differences

### **Development Configuration (What You've Been Using)**
```yaml
# Development - Optimized for speed and debugging
services:
  backend:
    build: ./backend
    volumes:
      - ./backend:/app:cached  # Live code reloading
      - /app/node_modules
    environment:
      NODE_ENV: development
      DEBUG: "true"
      LOG_LEVEL: debug
    ports:
      - "8000:8000"  # Direct port exposure
      - "9229:9229"  # Debug port exposed
```

### **Production Configuration (What You Need)**
```yaml
# Production - Optimized for security, performance, and reliability
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
      target: production
    environment:
      NODE_ENV: production
      DEBUG: "false"
      LOG_LEVEL: warn
    # No port exposure - accessed through load balancer
    # No volume mounts - code baked into image
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
      restart_policy:
        condition: on-failure
        max_attempts: 3
```

---

## 🏗️ Production-Ready E-Commerce Architecture

### **Complete Production Configuration**

```yaml
version: '3.8'

services:
  # Load Balancer (Entry Point)
  traefik:
    image: traefik:v2.9
    command:
      - "--api.dashboard=false"  # Disable dashboard in production
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--log.level=WARN"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access.log"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "letsencrypt:/letsencrypt"
      - "traefik_logs:/var/log/traefik"
    networks:
      - web_network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'

  # Database (High Availability)
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"
      PGDATA: /var/lib/postgresql/data/pgdata
    secrets:
      - postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - postgres_backup:/backup
      - ./database/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    networks:
      - database_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'
        reservations:
          memory: 1G
          cpus: '1.0'
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Redis (Production Configuration)
  redis:
    image: redis:7-alpine
    command: >
      redis-server
      --requirepass-file /run/secrets/redis_password
      --appendonly yes
      --appendfsync everysec
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru
      --tcp-keepalive 60
      --timeout 300
    secrets:
      - redis_password
    volumes:
      - redis_data:/data
    networks:
      - cache_network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  # Backend API (Production Optimized)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
      target: production
      args:
        NODE_ENV: production
        BUILD_DATE: ${BUILD_DATE}
        VERSION: ${VERSION}
    environment:
      NODE_ENV: production
      PORT: 8000
      DATABASE_URL_FILE: /run/secrets/database_url
      REDIS_URL_FILE: /run/secrets/redis_url
      JWT_SECRET_FILE: /run/secrets/jwt_secret
      STRIPE_SECRET_KEY_FILE: /run/secrets/stripe_secret
      LOG_LEVEL: warn
      TRUST_PROXY: "true"
    secrets:
      - database_url
      - redis_url
      - jwt_secret
      - stripe_secret
    volumes:
      - uploads:/app/uploads
      - app_logs:/app/logs
    networks:
      - web_network
      - database_network
      - cache_network
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        order: start-first
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.${DOMAIN_NAME}`)"
      - "traefik.http.routers.backend.entrypoints=websecure"
      - "traefik.http.routers.backend.tls.certresolver=letsencrypt"
      - "traefik.http.services.backend.loadbalancer.server.port=8000"
      - "traefik.http.services.backend.loadbalancer.healthcheck.path=/health"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"

  # Frontend (Production Build)
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
      target: production
      args:
        REACT_APP_API_URL: https://api.${DOMAIN_NAME}
        REACT_APP_ENV: production
    networks:
      - web_network
    depends_on:
      - backend
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`${DOMAIN_NAME}`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=letsencrypt"
      - "traefik.http.services.frontend.loadbalancer.server.port=80"

  # Background Worker
  worker:
    build:
      context: ./worker
      dockerfile: Dockerfile.prod
      target: production
    environment:
      NODE_ENV: production
      DATABASE_URL_FILE: /run/secrets/database_url
      REDIS_URL_FILE: /run/secrets/redis_url
      SENDGRID_API_KEY_FILE: /run/secrets/sendgrid_api_key
    secrets:
      - database_url
      - redis_url
      - sendgrid_api_key
    volumes:
      - worker_logs:/app/logs
    networks:
      - database_network
      - cache_network
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  # Monitoring (Prometheus)
  prometheus:
    image: prom/prometheus:latest
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring_network
      - web_network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  # Log Aggregation (Loki)
  loki:
    image: grafana/loki:latest
    command: -config.file=/etc/loki/local-config.yaml
    volumes:
      - ./monitoring/loki-config.yaml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    networks:
      - monitoring_network
    restart: unless-stopped

  # Backup Service
  backup:
    image: postgres:13-alpine
    environment:
      PGPASSWORD_FILE: /run/secrets/postgres_password
    secrets:
      - postgres_password
    volumes:
      - postgres_backup:/backup
      - ./scripts/backup.sh:/backup.sh:ro
    networks:
      - database_network
    command: |
      sh -c '
        while true; do
          /backup.sh
          sleep 21600  # Every 6 hours
        done
      '
    restart: unless-stopped

# Production Networks
networks:
  web_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.1.0/24
  
  database_network:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.2.0/24
  
  cache_network:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.3.0/24
  
  monitoring_network:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.4.0/24

# Production Volumes
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/data/postgres
  
  postgres_backup:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/backup/postgres
  
  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/data/redis
  
  uploads:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/data/uploads
  
  app_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/logs/app
  
  worker_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/logs/worker
  
  traefik_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/ecommerce/logs/traefik
  
  prometheus_data:
    driver: local
  
  loki_data:
    driver: local
  
  letsencrypt:
    driver: local

# Production Secrets
secrets:
  postgres_password:
    external: true
  redis_password:
    external: true
  database_url:
    external: true
  redis_url:
    external: true
  jwt_secret:
    external: true
  stripe_secret:
    external: true
  sendgrid_api_key:
    external: true
```

---

## 🔒 Production Security Hardening

### **1. Production Dockerfiles**

#### **Backend Production Dockerfile**
```dockerfile
# Dockerfile.prod
FROM node:16-alpine AS base
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM base AS production
ENV NODE_ENV=production
COPY --from=deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nodejs:nodejs /app/dist ./dist
COPY --from=build --chown=nodejs:nodejs /app/package.json ./

USER nodejs
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["node", "dist/server.js"]
```

### **2. Secret Management**

#### **Create Production Secrets**
```bash
#!/bin/bash
# scripts/create-secrets.sh

# Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 64)

# Create Docker secrets
echo "$POSTGRES_PASSWORD" | docker secret create postgres_password -
echo "$REDIS_PASSWORD" | docker secret create redis_password -
echo "$JWT_SECRET" | docker secret create jwt_secret -

# Create database URL secret
DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB}"
echo "$DATABASE_URL" | docker secret create database_url -

# Create Redis URL secret
REDIS_URL="redis://:${REDIS_PASSWORD}@redis:6379"
echo "$REDIS_URL" | docker secret create redis_url -

echo "Secrets created successfully"
```

### **3. Security Configuration**

#### **PostgreSQL Security Configuration**
```conf
# database/postgresql.conf
# Connection settings
listen_addresses = '*'
port = 5432
max_connections = 100

# Security settings
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
password_encryption = scram-sha-256

# Logging
log_connections = on
log_disconnections = on
log_statement = 'mod'
log_min_duration_statement = 1000

# Performance
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
```

---

## 🚀 Deployment Strategies

### **1. Blue-Green Deployment**

```bash
#!/bin/bash
# scripts/blue-green-deploy.sh

CURRENT_ENV=${1:-blue}
NEW_ENV=${2:-green}

echo "Starting blue-green deployment: $CURRENT_ENV -> $NEW_ENV"

# Deploy to new environment
docker-compose -f docker-compose.yml -f docker-compose.$NEW_ENV.yml up -d

# Wait for health checks
echo "Waiting for health checks..."
sleep 60

# Verify new environment
if curl -f https://api-$NEW_ENV.${DOMAIN_NAME}/health; then
  echo "New environment healthy, switching traffic..."
  
  # Update load balancer to point to new environment
  # This would typically involve updating DNS or load balancer config
  
  echo "Traffic switched to $NEW_ENV"
  
  # Stop old environment after grace period
  sleep 300
  docker-compose -f docker-compose.yml -f docker-compose.$CURRENT_ENV.yml down
  
  echo "Deployment complete"
else
  echo "New environment unhealthy, rolling back..."
  docker-compose -f docker-compose.yml -f docker-compose.$NEW_ENV.yml down
  exit 1
fi
```

### **2. Rolling Updates**

```yaml
# Rolling update configuration
services:
  backend:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1        # Update 1 container at a time
        delay: 10s           # Wait 10s between updates
        failure_action: rollback
        monitor: 60s         # Monitor for 60s after update
        max_failure_ratio: 0.3
        order: start-first   # Start new before stopping old
      rollback_config:
        parallelism: 1
        delay: 0s
        failure_action: pause
        monitor: 60s
```

### **3. Database Migrations**

```bash
#!/bin/bash
# scripts/migrate.sh

echo "Running database migrations..."

# Create migration container
docker run --rm \
  --network ecommerce_database_network \
  -e DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB}" \
  -v $(pwd)/migrations:/migrations \
  migrate/migrate \
  -path=/migrations \
  -database $DATABASE_URL \
  up

if [ $? -eq 0 ]; then
  echo "Migrations completed successfully"
else
  echo "Migration failed"
  exit 1
fi
```

---

## 🧪 Hands-On Practice: Production Deployment

### **Exercise 1: Production Environment Setup**

```bash
# Create production directory structure
sudo mkdir -p /opt/ecommerce/{data,backup,logs}/{postgres,redis,app,worker,traefik}
sudo chown -R $USER:$USER /opt/ecommerce

# Create secrets
./scripts/create-secrets.sh

# Deploy to production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Verify deployment
docker-compose ps
docker-compose logs --tail=50
```

### **Exercise 2: Security Audit**

```bash
# Check running processes
docker-compose exec backend ps aux

# Verify non-root user
docker-compose exec backend id

# Check file permissions
docker-compose exec backend ls -la /app

# Test security headers
curl -I https://api.${DOMAIN_NAME}/health

# Scan for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce_backend:latest
```

### **Exercise 3: Performance Testing**

```bash
# Load test the API
docker run --rm -i loadimpact/k6 run - <<EOF
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let response = http.get('https://api.${DOMAIN_NAME}/api/products');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
EOF
```

---

## ✅ Knowledge Check: Production Mastery

### **Conceptual Understanding**
- [ ] Understands production vs development configuration differences
- [ ] Knows security hardening best practices
- [ ] Comprehends deployment strategies and rollback procedures
- [ ] Understands monitoring and logging requirements
- [ ] Knows performance optimization techniques

### **Practical Skills**
- [ ] Can create production-ready Docker configurations
- [ ] Knows how to implement security hardening
- [ ] Can deploy using blue-green or rolling update strategies
- [ ] Understands how to manage secrets securely
- [ ] Can monitor and troubleshoot production deployments

### **E-Commerce Application**
- [ ] Has deployed production-ready e-commerce platform
- [ ] Implemented comprehensive security hardening
- [ ] Set up automated deployment and rollback procedures
- [ ] Configured monitoring and alerting
- [ ] Performed load testing and optimization

---

## 🚀 Next Steps: Scaling & Load Balancing

### **What You've Mastered**
- ✅ **Production-ready configurations** and optimizations
- ✅ **Security hardening** for production environments
- ✅ **Performance tuning** and resource optimization
- ✅ **Deployment strategies** and rollback procedures
- ✅ **Monitoring and logging** for production systems

### **Coming Next: Scaling & Load Balancing**
In **10-Scaling-Load-Balancing.md**, you'll learn:
- **Horizontal and vertical scaling** strategies
- **Load balancing** configurations and algorithms
- **Auto-scaling** based on metrics and demand
- **Performance optimization** for high-traffic scenarios

**Continue when you have successfully deployed your e-commerce platform to production with proper security and monitoring.**
