# Docker Compose Services - From Configuration to E-Commerce Architecture

## 📋 Learning Objectives
- **Master** complete service configuration options and their use cases
- **Understand** the difference between image and build strategies
- **Apply** resource management and performance optimization
- **Build** production-ready service definitions for e-commerce platform

---

## 🤔 Understanding Services: The Heart of Docker Compose

### **What is a Service in Docker Compose?**

A service is not just a container - it's a **scalable, configurable application component** that can run multiple container instances.

```yaml
# Service vs Container Concept
services:
  web:
    image: nginx
    # This service can run 1 or many nginx containers
    # All containers from this service share the same configuration
    # Compose manages the lifecycle of all containers in this service
```

### **Service vs Container: Key Differences**

| Aspect | Container (docker run) | Service (docker-compose) |
|--------|----------------------|--------------------------|
| **Scalability** | Single container | Multiple containers (replicas) |
| **Configuration** | Command-line flags | YAML configuration |
| **Networking** | Manual network setup | Automatic service discovery |
| **Dependencies** | Manual startup order | Automatic dependency management |
| **Persistence** | Manual volume management | Declarative volume configuration |
| **Updates** | Manual recreation | Rolling updates possible |

### **Why Services Matter for E-Commerce**

```yaml
# E-Commerce Service Architecture
services:
  # Each service represents a business capability
  product-catalog:     # Manages product information
    # Can scale to handle product searches
  
  user-management:     # Handles authentication and profiles
    # Can scale based on user registration load
  
  order-processing:    # Manages shopping cart and orders
    # Can scale during high-traffic periods
  
  payment-gateway:     # Handles payment processing
    # Needs high availability and security
```

---

## 🏗️ Service Configuration: From Basic to Advanced

### **Level 1: Basic Service Definition**

#### **Essential Service Properties**
```yaml
services:
  # Minimal service definition
  web:
    image: nginx:alpine                    # What to run
    ports:
      - "80:80"                           # How to access it
    
  # More complete basic service
  database:
    image: postgres:13                    # Base image
    container_name: ecommerce-db          # Custom container name
    restart: unless-stopped               # Restart policy
    environment:                          # Configuration
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure123
    volumes:                              # Data persistence
      - db_data:/var/lib/postgresql/data
    ports:                                # Network access
      - "5432:5432"
```

#### **Understanding Each Configuration Option**

##### **Image Selection**
```yaml
services:
  web:
    # Official images (recommended for production)
    image: nginx:1.21-alpine              # Specific version + variant
    image: postgres:13                    # Major version
    image: node:16-alpine                 # LTS version + lightweight
    
    # Version pinning strategies
    image: redis:7.0.5                    # Exact version (most stable)
    image: redis:7.0                      # Minor version (security updates)
    image: redis:7                        # Major version (feature updates)
    image: redis:latest                   # Latest (avoid in production)
```

##### **Container Naming and Identification**
```yaml
services:
  database:
    image: postgres:13
    container_name: ecommerce-database    # Custom name for easy reference
    hostname: db-server                   # Internal hostname
    
    # Without container_name, Compose generates:
    # {project-name}_{service-name}_{replica-number}
    # Example: ecommerce_database_1
```

##### **Restart Policies**
```yaml
services:
  web:
    image: nginx
    restart: unless-stopped               # Recommended for most services
    
    # Available restart policies:
    # no          - Never restart (default)
    # always      - Always restart
    # on-failure  - Restart only on failure
    # unless-stopped - Restart unless manually stopped
```

### **Level 2: Build Configuration**

#### **When to Build vs Use Images**

```yaml
# Use pre-built images when:
services:
  database:
    image: postgres:13                    # Standard database
  
  cache:
    image: redis:alpine                   # Standard cache
  
  proxy:
    image: nginx:alpine                   # Standard web server

# Build custom images when:
services:
  backend:
    build: ./backend                      # Custom application code
  
  frontend:
    build: ./frontend                     # Custom UI application
  
  worker:
    build: ./worker                       # Custom background jobs
```

#### **Build Configuration Options**

##### **Simple Build**
```yaml
services:
  backend:
    build: ./backend                      # Build from ./backend/Dockerfile
    ports:
      - "8000:8000"
```

##### **Advanced Build Configuration**
```yaml
services:
  backend:
    build:
      context: ./backend                  # Build context directory
      dockerfile: Dockerfile.prod         # Custom Dockerfile name
      args:                              # Build arguments
        NODE_ENV: production
        API_VERSION: v2.1.0
      target: production                  # Multi-stage build target
      cache_from:                        # Cache sources
        - backend:latest
        - node:16-alpine
    image: ecommerce-backend:latest       # Tag the built image
```

##### **Build Arguments for Environment-Specific Builds**
```yaml
# Dockerfile
ARG NODE_ENV=development
ARG API_VERSION=latest
RUN echo "Building for ${NODE_ENV} environment"

# docker-compose.yml
services:
  backend:
    build:
      context: ./backend
      args:
        NODE_ENV: ${NODE_ENV:-development}
        API_VERSION: ${API_VERSION:-latest}
```

### **Level 3: Advanced Service Configuration**

#### **Environment Variable Management**

##### **Different Ways to Set Environment Variables**
```yaml
services:
  backend:
    # Method 1: List format
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - PORT=8000
    
    # Method 2: Object format (preferred)
    environment:
      NODE_ENV: production
      DEBUG: false
      PORT: 8000
    
    # Method 3: Environment file
    env_file:
      - .env                             # Load from file
      - .env.production                  # Multiple files
    
    # Method 4: Mixed approach
    env_file: .env
    environment:
      NODE_ENV: production               # Override specific variables
```

##### **Environment Variable Precedence**
```yaml
# Priority (highest to lowest):
# 1. Compose file environment section
# 2. Shell environment variables
# 3. Environment file (.env)
# 4. Dockerfile ENV instructions

services:
  backend:
    env_file: .env                       # Lowest priority
    environment:
      NODE_ENV: ${NODE_ENV}              # Shell variable (medium priority)
      DEBUG: true                        # Compose file (highest priority)
```

#### **Port Configuration and Networking**

##### **Port Mapping Strategies**
```yaml
services:
  # Development: Expose all ports for debugging
  backend-dev:
    ports:
      - "8000:8000"                      # API port
      - "9229:9229"                      # Debug port
  
  # Production: Only expose necessary ports
  backend-prod:
    ports:
      - "8000:8000"                      # Only API port
    expose:
      - "9229"                           # Internal debugging (no host mapping)
```

##### **Advanced Port Configuration**
```yaml
services:
  web:
    ports:
      # Long syntax for advanced configuration
      - target: 80                       # Container port
        published: 8080                  # Host port
        protocol: tcp                    # Protocol (tcp/udp)
        mode: host                       # Port mode (host/ingress)
      
      # Short syntax
      - "443:443"                        # HTTPS
      - "80:80"                          # HTTP
      
      # Dynamic port assignment
      - "8000"                           # Docker assigns random host port
```

#### **Volume Configuration and Data Management**

##### **Volume Types and Use Cases**
```yaml
services:
  database:
    volumes:
      # Named volume (managed by Docker)
      - postgres_data:/var/lib/postgresql/data
      
      # Bind mount (host directory)
      - ./database/config:/etc/postgresql/conf.d:ro
      
      # Anonymous volume (temporary)
      - /tmp
      
      # tmpfs mount (in-memory)
      - type: tmpfs
        target: /app/cache
        tmpfs:
          size: 100M

volumes:
  postgres_data:                         # Define named volume
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/docker/postgres
```

##### **Volume Configuration Options**
```yaml
services:
  backend:
    volumes:
      # Long syntax with options
      - type: bind
        source: ./backend
        target: /app
        read_only: false
        bind:
          propagation: rprivate
      
      # Volume with specific driver
      - type: volume
        source: app_data
        target: /app/data
        volume:
          nocopy: true

volumes:
  app_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/dir"
```

---

## 🛒 E-Commerce Services: Complete Configuration

### **Production-Ready E-Commerce Service Stack**

```yaml
version: '3.8'

services:
  # PostgreSQL Database Service
  database:
    image: postgres:13-alpine
    container_name: ecommerce-database
    restart: unless-stopped
    
    # Security: Run as non-root user
    user: postgres
    
    # Environment configuration
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ecommerce}
      POSTGRES_USER: ${POSTGRES_USER:-ecommerce_admin}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"
      PGDATA: /var/lib/postgresql/data/pgdata
    
    # Data persistence
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d:ro
      - ./database/config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    
    # Network configuration
    ports:
      - "${DB_PORT:-5432}:5432"
    expose:
      - "5432"
    
    # Health monitoring
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-ecommerce_admin} -d ${POSTGRES_DB:-ecommerce}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
    
    # Logging configuration
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    networks:
      - database_network

  # Redis Cache Service
  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis
    restart: unless-stopped
    
    # Custom command with configuration
    command: >
      redis-server
      --appendonly yes
      --requirepass ${REDIS_PASSWORD}
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
    
    # Data persistence
    volumes:
      - redis_data:/data
      - ./redis/redis.conf:/usr/local/etc/redis/redis.conf:ro
    
    # Network configuration
    ports:
      - "${REDIS_PORT:-6379}:6379"
    
    # Health monitoring
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    
    networks:
      - cache_network

  # Backend API Service
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        NODE_ENV: ${NODE_ENV:-production}
        BUILD_DATE: ${BUILD_DATE}
        VERSION: ${VERSION:-latest}
      target: production
    
    container_name: ecommerce-backend
    restart: unless-stopped
    
    # Security: Run as non-root user
    user: "1000:1000"
    
    # Working directory
    working_dir: /app
    
    # Environment configuration
    environment:
      # Application settings
      NODE_ENV: ${NODE_ENV:-production}
      PORT: 8000
      
      # Database connection
      DATABASE_URL: postgresql://${POSTGRES_USER:-ecommerce_admin}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB:-ecommerce}
      
      # Cache connection
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      
      # Security settings
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRES_IN: ${JWT_EXPIRES_IN:-24h}
      BCRYPT_ROUNDS: ${BCRYPT_ROUNDS:-12}
      
      # API configuration
      API_RATE_LIMIT: ${API_RATE_LIMIT:-100}
      API_TIMEOUT: ${API_TIMEOUT:-30000}
      
      # External services
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      SENDGRID_API_KEY: ${SENDGRID_API_KEY}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET_NAME: ${S3_BUCKET_NAME}
    
    # Environment file
    env_file:
      - .env
      - .env.production
    
    # Network configuration
    ports:
      - "${API_PORT:-8000}:8000"
    expose:
      - "8000"
      - "9229"  # Debug port (internal only)
    
    # Volume mounts
    volumes:
      # Application code (development)
      - ./backend:/app:cached
      - /app/node_modules
      
      # File uploads
      - uploads:/app/uploads
      
      # Logs
      - ./logs/backend:/app/logs
    
    # Service dependencies
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    
    # Health monitoring
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    # Resource limits
    deploy:
      replicas: 2
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
    
    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    
    networks:
      - database_network
      - cache_network
      - api_network

  # Frontend Application Service
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        REACT_APP_ENV: ${NODE_ENV:-production}
        REACT_APP_VERSION: ${VERSION:-latest}
      target: production
    
    container_name: ecommerce-frontend
    restart: unless-stopped
    
    # Environment configuration
    environment:
      # Application settings
      REACT_APP_API_URL: ${REACT_APP_API_URL:-http://localhost:8000}
      REACT_APP_ENV: ${NODE_ENV:-production}
      
      # Feature flags
      REACT_APP_ENABLE_ANALYTICS: ${ENABLE_ANALYTICS:-true}
      REACT_APP_ENABLE_CHAT: ${ENABLE_CHAT:-false}
      
      # External services
      REACT_APP_STRIPE_PUBLISHABLE_KEY: ${STRIPE_PUBLISHABLE_KEY}
      REACT_APP_GOOGLE_ANALYTICS_ID: ${GOOGLE_ANALYTICS_ID}
    
    # Network configuration
    ports:
      - "${FRONTEND_PORT:-3000}:3000"
    
    # Volume mounts
    volumes:
      # Source code (development)
      - ./frontend:/app:cached
      - /app/node_modules
      
      # Build output
      - frontend_build:/app/build
    
    # Service dependencies
    depends_on:
      backend:
        condition: service_healthy
    
    # Health monitoring
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    
    networks:
      - api_network
      - web_network

  # Nginx Reverse Proxy Service
  nginx:
    image: nginx:1.21-alpine
    container_name: ecommerce-nginx
    restart: unless-stopped
    
    # Network configuration
    ports:
      - "${HTTP_PORT:-80}:80"
      - "${HTTPS_PORT:-443}:443"
    
    # Configuration and content
    volumes:
      # Nginx configuration
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      
      # SSL certificates
      - ./nginx/ssl:/etc/nginx/ssl:ro
      
      # Static content
      - frontend_build:/var/www/html:ro
      - uploads:/var/www/uploads:ro
      
      # Logs
      - ./logs/nginx:/var/log/nginx
    
    # Service dependencies
    depends_on:
      frontend:
        condition: service_healthy
      backend:
        condition: service_healthy
    
    # Health monitoring
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'
    
    networks:
      - web_network

# Network definitions
networks:
  database_network:
    driver: bridge
    internal: true                        # Database network is internal only
    ipam:
      config:
        - subnet: 172.20.1.0/24
  
  cache_network:
    driver: bridge
    internal: true                        # Cache network is internal only
    ipam:
      config:
        - subnet: 172.20.2.0/24
  
  api_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.3.0/24
  
  web_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.4.0/24

# Volume definitions
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/postgres
  
  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/redis
  
  uploads:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/uploads
  
  frontend_build:
    driver: local
```

---

## 🔧 Advanced Service Features

### **1. Health Checks and Monitoring**

#### **Health Check Configuration**
```yaml
services:
  backend:
    healthcheck:
      # Command to test service health
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      
      # How often to check
      interval: 30s
      
      # How long to wait for response
      timeout: 10s
      
      # How many failures before unhealthy
      retries: 3
      
      # How long to wait before first check
      start_period: 60s
      
      # Disable health check
      # disable: true
```

#### **Custom Health Check Scripts**
```yaml
services:
  database:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  backend:
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### **2. Resource Management and Limits**

#### **Resource Constraints**
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          # Maximum resources
          cpus: '1.0'                     # 1 CPU core
          memory: 1G                      # 1 GB RAM
          pids: 100                       # Max processes
        
        reservations:
          # Guaranteed resources
          cpus: '0.5'                     # 0.5 CPU core
          memory: 512M                    # 512 MB RAM
```

#### **Legacy Resource Limits (Compose v2)**
```yaml
services:
  backend:
    # CPU limits
    cpus: 1.5                            # 1.5 CPU cores
    cpu_shares: 1024                     # CPU weight
    cpu_quota: 50000                     # CPU quota
    cpu_period: 100000                   # CPU period
    
    # Memory limits
    mem_limit: 1g                        # Memory limit
    mem_reservation: 512m                # Memory reservation
    memswap_limit: 2g                    # Memory + swap limit
    
    # Other limits
    pids_limit: 100                      # Process limit
    ulimits:                             # System limits
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
```

### **3. Service Dependencies and Startup Order**

#### **Basic Dependencies**
```yaml
services:
  database:
    image: postgres:13
  
  backend:
    build: ./backend
    depends_on:
      - database                         # Start database first
  
  frontend:
    build: ./frontend
    depends_on:
      - backend                          # Start backend first
```

#### **Advanced Dependencies with Conditions**
```yaml
services:
  database:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  backend:
    build: ./backend
    depends_on:
      database:
        condition: service_healthy       # Wait for healthy database
      redis:
        condition: service_started       # Wait for redis to start
```

### **4. Scaling and Replication**

#### **Service Scaling**
```yaml
services:
  backend:
    build: ./backend
    deploy:
      replicas: 3                        # Run 3 instances
      
      # Update configuration
      update_config:
        parallelism: 1                   # Update 1 at a time
        delay: 10s                       # Wait 10s between updates
        failure_action: rollback         # Rollback on failure
      
      # Restart policy
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```

#### **Load Balancing Configuration**
```yaml
services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
    ports:
      - "80:80"
  
  backend:
    build: ./backend
    deploy:
      replicas: 3
    # No ports exposed - accessed through nginx
```

---

## 🧪 Hands-On Practice: Service Configuration Mastery

### **Exercise 1: Complete E-Commerce Service Setup**

Create a comprehensive service configuration:

```bash
# Create project structure
mkdir ecommerce-services
cd ecommerce-services
mkdir -p backend frontend database nginx redis logs data/{postgres,redis,uploads}
```

Create `.env` file:
```bash
# .env
# Database
POSTGRES_DB=ecommerce
POSTGRES_USER=ecommerce_admin
POSTGRES_PASSWORD=secure_db_password_123

# Redis
REDIS_PASSWORD=secure_redis_password_123

# Application
NODE_ENV=production
API_PORT=8000
FRONTEND_PORT=3000
JWT_SECRET=your_jwt_secret_here_make_it_long_and_secure

# External Services
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
```

### **Exercise 2: Health Check Implementation**

Create health check endpoints in your applications:

**Backend health check (Node.js):**
```javascript
// backend/healthcheck.js
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 8000,
  path: '/api/health',
  method: 'GET',
  timeout: 5000
};

const req = http.request(options, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

req.on('error', () => {
  process.exit(1);
});

req.on('timeout', () => {
  req.destroy();
  process.exit(1);
});

req.end();
```

**Health endpoint in your API:**
```javascript
// backend/routes/health.js
app.get('/api/health', async (req, res) => {
  try {
    // Check database connection
    await db.query('SELECT 1');
    
    // Check Redis connection
    await redis.ping();
    
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        cache: 'connected'
      }
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});
```

### **Exercise 3: Resource Optimization**

Test and optimize resource usage:

```bash
# Monitor resource usage
docker-compose up -d
docker stats

# Test with different resource limits
docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d

# Load test your services
curl -X GET http://localhost:8000/api/health
ab -n 1000 -c 10 http://localhost:8000/api/products
```

---

## ✅ Knowledge Check: Service Configuration Mastery

### **Conceptual Understanding**
- [ ] Understands the difference between services and containers
- [ ] Knows when to use image vs build configurations
- [ ] Comprehends resource management and limits
- [ ] Understands health checks and monitoring
- [ ] Knows service dependency management

### **Practical Skills**
- [ ] Can configure complete service definitions
- [ ] Knows how to implement health checks
- [ ] Can set up resource limits and constraints
- [ ] Understands scaling and replication
- [ ] Can troubleshoot service configuration issues

### **E-Commerce Application**
- [ ] Has configured all e-commerce services with proper options
- [ ] Implemented health checks for all services
- [ ] Set up appropriate resource limits
- [ ] Configured service dependencies correctly
- [ ] Created production-ready service definitions

---

## 🚀 Next Steps: Networking Deep Dive

### **What You've Mastered**
- ✅ **Complete service configuration** options and best practices
- ✅ **Build vs image strategies** for different use cases
- ✅ **Resource management** and performance optimization
- ✅ **Health checks and monitoring** for production reliability
- ✅ **Service dependencies** and startup orchestration

### **Coming Next: Docker Compose Networks**
In **04-Docker-Compose-Networks.md**, you'll learn:
- **Advanced networking concepts** and custom network creation
- **Service discovery** and inter-service communication
- **Network security** and isolation strategies
- **Load balancing** and traffic management

### **E-Commerce Evolution Preview**
Your service configuration skills will enable you to:
- **Create scalable service architectures** that can handle growth
- **Implement proper monitoring** for production reliability
- **Optimize resource usage** for cost-effective deployment
- **Build resilient systems** with proper health checks and dependencies

**Continue to Networking when you're comfortable with service configuration and have implemented comprehensive service definitions for your e-commerce platform.**
  # Official images
  nginx:
    image: nginx:alpine
  
  postgres:
    image: postgres:15-alpine
  
  redis:
    image: redis:7-alpine
  
  # Specific versions (recommended for production)
  node-app:
    image: node:18.17.0-alpine
  
  # Custom registry images
  private-app:
    image: myregistry.com/myapp:v1.2.3
  
  # Docker Hub user images
  monitoring:
    image: prom/prometheus:latest
```

### Build Configuration
```yaml
services:
  # Simple build from current directory
  app:
    build: .
  
  # Build with custom Dockerfile
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
  
  # Build with arguments
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
        - API_URL=https://api.example.com
        - BUILD_VERSION=${BUILD_VERSION}
  
  # Build with target stage (multi-stage Dockerfile)
  web:
    build:
      context: .
      target: production
      dockerfile: Dockerfile
  
  # Build with cache configuration
  service:
    build:
      context: .
      cache_from:
        - myapp:cache
        - node:18-alpine
  
  # Build with labels
  labeled-service:
    build:
      context: .
      labels:
        - "com.example.version=1.0"
        - "com.example.environment=production"
```

### Advanced Build Options
```yaml
services:
  complex-build:
    build:
      context: .
      dockerfile: Dockerfile.complex
      args:
        - BUILD_DATE=${BUILD_DATE}
        - VERSION=${VERSION}
        - COMMIT_SHA=${COMMIT_SHA}
      target: production
      cache_from:
        - myapp:builder
        - myapp:latest
      extra_hosts:
        - "internal.api:192.168.1.100"
      shm_size: 256M
      network: host
```

## Runtime Configuration

### Container Lifecycle
```yaml
services:
  app:
    # Container name (must be unique)
    container_name: my-application
    
    # Hostname inside container
    hostname: app-server
    
    # Restart policy
    restart: unless-stopped  # no, always, on-failure, unless-stopped
    
    # Init process
    init: true
    
    # Stop grace period
    stop_grace_period: 30s
    
    # Stop signal
    stop_signal: SIGTERM
    
    # Working directory
    working_dir: /app
    
    # User and group
    user: "1000:1000"
    
    # Process limits
    pid: host  # Use host PID namespace
    
    # IPC namespace
    ipc: host
```

### Command and Entrypoint
```yaml
services:
  # Override default command
  web:
    image: nginx:alpine
    command: ["nginx", "-g", "daemon off;"]
  
  # Override entrypoint
  app:
    image: node:alpine
    entrypoint: ["/docker-entrypoint.sh"]
    command: ["npm", "start"]
  
  # Shell form (not recommended for production)
  shell-app:
    image: alpine
    command: echo "Hello World"
  
  # Multi-line command
  complex-app:
    image: alpine
    command: >
      sh -c "
        echo 'Starting application...' &&
        sleep 5 &&
        echo 'Application started'
      "
```

### Environment Configuration
```yaml
services:
  app:
    # Environment variables (array format)
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - PORT=3000
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    
    # Environment variables (object format)
    environment:
      NODE_ENV: production
      DEBUG: false
      PORT: 3000
    
    # Environment files
    env_file:
      - .env                    # Default environment
      - .env.production         # Environment-specific
      - config/app.env          # Custom location
    
    # Variable substitution with defaults
    environment:
      - API_URL=${API_URL:-http://localhost:8080}
      - WORKERS=${WORKERS:-4}
      - LOG_LEVEL=${LOG_LEVEL:-info}
```

## Resource Management

### Memory and CPU Limits
```yaml
services:
  resource-limited:
    image: myapp:latest
    
    # Memory limits
    mem_limit: 512m
    mem_reservation: 256m
    
    # CPU limits
    cpus: 0.5                   # 50% of one CPU
    cpu_shares: 512             # Relative weight
    
    # OOM killer disable
    oom_kill_disable: true
    
    # Memory swappiness
    mem_swappiness: 60
    
    # CPU set (specific cores)
    cpuset: "0,1"
```

### Deploy Configuration (Swarm Mode)
```yaml
services:
  scalable-app:
    image: myapp:latest
    deploy:
      # Replica configuration
      replicas: 3
      
      # Resource limits
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
      
      # Restart policy
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
      
      # Update configuration
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        monitor: 60s
        max_failure_ratio: 0.3
      
      # Placement constraints
      placement:
        constraints:
          - node.role == worker
          - node.labels.environment == production
```

### Health Checks
```yaml
services:
  monitored-app:
    image: myapp:latest
    
    # HTTP health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Custom script health check
    healthcheck:
      test: ["CMD", "/app/health-check.sh"]
      interval: 1m
      timeout: 5s
      retries: 2
    
    # Disable inherited health check
    healthcheck:
      disable: true

  database:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 30s
```

## Service Communication

### Dependencies
```yaml
services:
  web:
    image: nginx:alpine
    depends_on:
      - app
      - database
    ports:
      - "80:80"
  
  app:
    build: .
    depends_on:
      - database
      - redis
    environment:
      - DATABASE_URL=postgresql://user:pass@database:5432/myapp
      - REDIS_URL=redis://redis:6379
  
  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
  
  redis:
    image: redis:alpine
```

### Advanced Dependencies with Conditions
```yaml
services:
  web:
    image: nginx:alpine
    depends_on:
      app:
        condition: service_healthy
      database:
        condition: service_healthy
  
  app:
    build: .
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  database:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  redis:
    image: redis:alpine
```

### External Links (Legacy)
```yaml
services:
  web:
    image: nginx:alpine
    # Link to external containers
    external_links:
      - redis_container
      - postgres_container:database
    
    # Modern approach: use external networks instead
    networks:
      - external_network

networks:
  external_network:
    external: true
```

## Advanced Service Options

### Security Configuration
```yaml
services:
  secure-app:
    image: myapp:latest
    
    # Security options
    security_opt:
      - no-new-privileges:true
      - apparmor:unconfined
    
    # Capabilities
    cap_add:
      - NET_ADMIN
      - SYS_TIME
    cap_drop:
      - ALL
    
    # Privileged mode (avoid in production)
    privileged: false
    
    # Read-only root filesystem
    read_only: true
    
    # Temporary filesystems
    tmpfs:
      - /tmp
      - /var/tmp:noexec,nosuid,size=100m
    
    # User namespace
    userns_mode: host
```

### Logging Configuration
```yaml
services:
  logged-app:
    image: myapp:latest
    
    # Logging driver and options
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
        labels: "production"
    
    # Syslog logging
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://192.168.1.100:514"
        tag: "myapp"
    
    # Disable logging
    logging:
      driver: none
```

### Device and System Access
```yaml
services:
  system-app:
    image: myapp:latest
    
    # Device access
    devices:
      - "/dev/sda:/dev/xvda:rwm"
      - "/dev/ttyUSB0:/dev/ttyUSB0"
    
    # System calls
    sysctls:
      - net.core.somaxconn=1024
      - net.ipv4.tcp_syncookies=0
    
    # Ulimits
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
    
    # Extra hosts
    extra_hosts:
      - "api.internal:192.168.1.100"
      - "db.internal:192.168.1.101"
```

### Labels and Metadata
```yaml
services:
  labeled-app:
    image: myapp:latest
    
    # Service labels
    labels:
      - "com.example.version=1.0"
      - "com.example.environment=production"
      - "com.example.team=backend"
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`app.example.com`)"
    
    # Alternative label format
    labels:
      com.example.version: "1.0"
      com.example.environment: "production"
      traefik.enable: "true"
```

## Service Patterns

### 1. Web Application Service
```yaml
services:
  web-app:
    build:
      context: .
      dockerfile: Dockerfile.prod
      target: production
    
    container_name: webapp-prod
    hostname: webapp
    
    ports:
      - "80:3000"
      - "443:3443"
    
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_URL=postgresql://user:pass@database:5432/webapp
    
    volumes:
      - ./uploads:/app/uploads
      - app_logs:/var/log/app
    
    networks:
      - frontend
      - backend
    
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    restart: unless-stopped
    
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.webapp.rule=Host(`app.example.com`)"
```

### 2. Database Service
```yaml
services:
  database:
    image: postgres:15-alpine
    
    container_name: postgres-db
    hostname: database
    
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
      - ./backups:/backups
    
    ports:
      - "127.0.0.1:5432:5432"  # Bind to localhost only
    
    networks:
      - backend
    
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 30s
    
    restart: unless-stopped
    
    # Resource limits
    mem_limit: 1g
    cpus: 0.5
    
    # Security
    security_opt:
      - no-new-privileges:true
    
    labels:
      - "com.example.service=database"
      - "com.example.backup=required"
```

### 3. Microservice Template
```yaml
services:
  user-service:
    build:
      context: ./services/user
      dockerfile: Dockerfile
      args:
        - SERVICE_NAME=user-service
        - VERSION=${USER_SERVICE_VERSION}
    
    container_name: user-service
    hostname: user-service
    
    environment:
      - SERVICE_NAME=user-service
      - SERVICE_PORT=8080
      - DATABASE_URL=${USER_DB_URL}
      - JWT_SECRET=${JWT_SECRET}
      - LOG_LEVEL=${LOG_LEVEL:-info}
    
    ports:
      - "8080:8080"
    
    networks:
      - microservices
      - database
    
    depends_on:
      shared-database:
        condition: service_healthy
      message-queue:
        condition: service_started
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 45s
    
    restart: unless-stopped
    
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    
    labels:
      - "com.example.service=user-service"
      - "com.example.version=${USER_SERVICE_VERSION}"
      - "traefik.enable=true"
      - "traefik.http.routers.user.rule=PathPrefix(`/api/users`)"
```

This comprehensive guide covers all aspects of Docker Compose service configuration, from basic setups to advanced production-ready deployments.
