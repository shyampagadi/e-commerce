# Docker Compose Fundamentals - From Theory to E-Commerce Orchestration

## 📋 Learning Objectives
- **Understand** the fundamental problems Docker Compose solves
- **Master** Docker Compose architecture and core concepts
- **Apply** orchestration principles to your e-commerce application
- **Build** your first multi-container e-commerce stack

---

## 🤔 The Problem: Why Docker Compose Exists

### **Your Current Challenge (After Modules 1-4)**

You've learned to containerize individual services, but managing them manually is becoming complex:

```bash
# Your current e-commerce setup (manual and error-prone)
# Terminal 1: Start database
docker run -d --name ecommerce-db \
  -e POSTGRES_DB=ecommerce \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret123 \
  -p 5432:5432 \
  postgres:13

# Terminal 2: Start backend (after database is ready)
docker run -d --name ecommerce-backend \
  -p 8000:8000 \
  -e DATABASE_URL=postgresql://admin:secret123@localhost:5432/ecommerce \
  --link ecommerce-db \
  ecommerce-backend:latest

# Terminal 3: Start frontend (after backend is ready)
docker run -d --name ecommerce-frontend \
  -p 3000:3000 \
  -e REACT_APP_API_URL=http://localhost:8000 \
  --link ecommerce-backend \
  ecommerce-frontend:latest

# Terminal 4: Start nginx (after frontend is ready)
docker run -d --name ecommerce-nginx \
  -p 80:80 \
  --link ecommerce-frontend \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
  nginx:alpine
```

### **Problems with Manual Container Management**

#### **1. Complexity and Human Error**
- **Multiple commands** to remember and execute in order
- **Manual dependency management** - you must start services in correct sequence
- **Configuration drift** - different environments may have different setups
- **Networking complexity** - manual linking and port management

#### **2. Development Team Challenges**
- **Onboarding friction** - new developers need extensive setup documentation
- **Environment inconsistency** - "works on my machine" problems
- **Debugging difficulty** - hard to reproduce issues across environments

#### **3. Production Deployment Issues**
- **No rollback strategy** - difficult to revert to previous versions
- **Scaling challenges** - manual scaling of individual services
- **Monitoring gaps** - no unified view of application health

### **The Docker Compose Solution**

```yaml
# One file to define your entire e-commerce stack
version: '3.8'

services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://admin:secret123@database:5432/ecommerce
    depends_on:
      - database
    
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      REACT_APP_API_URL: http://localhost:8000
    depends_on:
      - backend
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend

volumes:
  postgres_data:
```

**One command to start everything:**
```bash
docker-compose up -d
```

**Benefits achieved:**
- ✅ **Declarative configuration** - describe what you want, not how to get it
- ✅ **Dependency management** - services start in correct order automatically
- ✅ **Environment consistency** - same setup everywhere
- ✅ **Version control** - infrastructure as code
- ✅ **Easy scaling** - scale services with simple commands

---

## 🏗️ Docker Compose Architecture: Understanding the Components

### **Conceptual Architecture**

```
Docker Compose Architecture
├── Compose File (docker-compose.yml)
│   ├── Services (your applications)
│   ├── Networks (communication channels)
│   ├── Volumes (data persistence)
│   └── Secrets (sensitive data)
├── Docker Engine (container runtime)
└── Docker CLI (command interface)
```

### **How Docker Compose Works**

#### **1. Declarative Configuration**
```yaml
# You declare WHAT you want
services:
  web:
    image: nginx
    ports:
      - "80:80"

# Docker Compose figures out HOW to achieve it
# - Pulls nginx image if not present
# - Creates container with port mapping
# - Starts container
# - Manages container lifecycle
```

#### **2. Project-Based Organization**
```
Project: ecommerce-app
├── Services: database, backend, frontend, nginx
├── Networks: default network + custom networks
├── Volumes: postgres_data, nginx_config
└── Environment: development, staging, production
```

#### **3. Service Discovery**
```yaml
# Services can communicate by name
services:
  database:
    image: postgres:13
  
  backend:
    image: my-api
    environment:
      # Use service name as hostname
      DATABASE_URL: postgresql://user:pass@database:5432/mydb
```

**Key Insight**: Docker Compose creates a private network where services can find each other by name, eliminating the need for manual linking.

---

## 📚 Core Concepts: Building Blocks of Orchestration

### **1. Services - Your Application Components**

#### **Theory: What is a Service?**
A service is a containerized application component that:
- **Runs one or more containers** from the same image
- **Has a specific role** in your application (database, API, frontend)
- **Can be scaled** independently
- **Communicates** with other services

#### **Service Definition Structure**
```yaml
services:
  service-name:
    # How to get the container image
    image: nginx:alpine          # Use existing image
    # OR
    build: ./my-app             # Build from Dockerfile
    
    # How to expose the service
    ports:
      - "host-port:container-port"
    
    # How to configure the service
    environment:
      - KEY=value
    
    # What the service depends on
    depends_on:
      - other-service
    
    # How to persist data
    volumes:
      - volume-name:/container/path
```

### **2. Networks - Service Communication**

#### **Theory: Container Networking in Compose**
```
Default Behavior:
├── Compose creates a default network for your project
├── All services join this network automatically
├── Services can reach each other by service name
└── External access requires port mapping
```

#### **Network Types**
```yaml
# Default network (automatic)
services:
  web:
    image: nginx
  api:
    image: my-api
# web can reach api at http://api:port

# Custom networks (explicit control)
networks:
  frontend:
  backend:

services:
  web:
    networks:
      - frontend
  api:
    networks:
      - frontend
      - backend
  database:
    networks:
      - backend
```

### **3. Volumes - Data Persistence**

#### **Theory: Why Containers Need External Storage**
```
Container Filesystem:
├── Ephemeral by default (data lost when container stops)
├── Read-only layers + writable layer
├── Not suitable for databases or user uploads
└── Volumes provide persistent storage outside container
```

#### **Volume Types in Compose**
```yaml
services:
  database:
    image: postgres:13
    volumes:
      # Named volume (managed by Docker)
      - postgres_data:/var/lib/postgresql/data
      
      # Bind mount (host directory)
      - ./config:/etc/postgresql/conf.d
      
      # Anonymous volume (temporary)
      - /tmp

volumes:
  postgres_data:  # Define named volume
```

---

## 🛒 E-Commerce Application: Your First Compose File

### **Step 1: Analyze Your Current E-Commerce Architecture**

From your previous modules, you have:
```
E-Commerce Components:
├── Frontend (React/Vue) - Port 3000
├── Backend API (Node.js/Python) - Port 8000
├── Database (PostgreSQL) - Port 5432
└── Reverse Proxy (Nginx) - Port 80
```

### **Step 2: Create Your First docker-compose.yml**

```yaml
# File: docker-compose.yml
version: '3.8'

services:
  # Database Service
  database:
    image: postgres:13
    container_name: ecommerce-db
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: ecommerce_user
      POSTGRES_PASSWORD: secure_password123
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ecommerce_user -d ecommerce"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend API Service
  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile
    container_name: ecommerce-backend
    environment:
      DATABASE_URL: postgresql://ecommerce_user:secure_password123@database:5432/ecommerce
      NODE_ENV: development
      PORT: 8000
    ports:
      - "8000:8000"
    depends_on:
      database:
        condition: service_healthy
    volumes:
      - ./backend:/app
      - /app/node_modules
    restart: unless-stopped

  # Frontend Service
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ecommerce-frontend
    environment:
      REACT_APP_API_URL: http://localhost:8000
      REACT_APP_ENV: development
    ports:
      - "3000:3000"
    depends_on:
      - backend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    restart: unless-stopped

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: ecommerce-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
```

### **Step 3: Understanding Each Section**

#### **Version Declaration**
```yaml
version: '3.8'
# Specifies Compose file format version
# 3.8 supports most modern Docker features
```

#### **Services Section**
```yaml
services:
  database:
    # Service configuration goes here
```
**Key Concepts:**
- Each service represents one component of your application
- Service names become hostnames in the internal network
- Services can reference each other by name

#### **Environment Variables**
```yaml
environment:
  DATABASE_URL: postgresql://user:pass@database:5432/db
  # Note: 'database' is the service name, not localhost
```

#### **Dependency Management**
```yaml
depends_on:
  database:
    condition: service_healthy
# Ensures database is healthy before starting this service
```

#### **Volume Definitions**
```yaml
volumes:
  postgres_data:
# Creates a named volume managed by Docker
```

---

## 🔧 Essential Docker Compose Commands

### **Basic Lifecycle Commands**

#### **Start Your E-Commerce Stack**
```bash
# Start all services in background
docker-compose up -d

# Start with build (if Dockerfiles changed)
docker-compose up -d --build

# Start specific services only
docker-compose up -d database backend
```

#### **Monitor Your Services**
```bash
# View running services
docker-compose ps

# View service logs
docker-compose logs
docker-compose logs backend
docker-compose logs -f frontend  # Follow logs

# View resource usage
docker-compose top
```

#### **Manage Service Lifecycle**
```bash
# Stop all services
docker-compose stop

# Stop specific service
docker-compose stop frontend

# Restart services
docker-compose restart
docker-compose restart backend

# Remove stopped containers
docker-compose rm
```

#### **Complete Cleanup**
```bash
# Stop and remove containers, networks
docker-compose down

# Also remove volumes (careful - deletes data!)
docker-compose down -v

# Remove everything including images
docker-compose down --rmi all -v
```

### **Development Commands**

#### **Execute Commands in Services**
```bash
# Get shell access to backend
docker-compose exec backend bash

# Run database commands
docker-compose exec database psql -U ecommerce_user -d ecommerce

# Run one-off commands
docker-compose run backend npm test
```

#### **Scaling Services**
```bash
# Scale backend to 3 instances
docker-compose up -d --scale backend=3

# Scale multiple services
docker-compose up -d --scale backend=2 --scale frontend=2
```

---

## 🧪 Hands-On Practice: Build Your E-Commerce Stack

### **Exercise 1: Create Basic Compose File**

1. **Create project structure:**
```bash
mkdir ecommerce-compose
cd ecommerce-compose
mkdir -p backend frontend database nginx
```

2. **Create docker-compose.yml:**
```yaml
version: '3.8'

services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password123
    volumes:
      - db_data:/var/lib/postgresql/data

  backend:
    image: node:16
    working_dir: /app
    command: npm start
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://admin:password123@database:5432/ecommerce
    depends_on:
      - database

volumes:
  db_data:
```

3. **Test the setup:**
```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs

# Clean up
docker-compose down
```

### **Exercise 2: Add Health Checks**

```yaml
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password123
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d ecommerce"]
      interval: 30s
      timeout: 10s
      retries: 3
    volumes:
      - db_data:/var/lib/postgresql/data

  backend:
    image: node:16
    working_dir: /app
    command: npm start
    ports:
      - "8000:8000"
    depends_on:
      database:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### **Exercise 3: Environment-Specific Configuration**

Create `.env` file:
```bash
# .env
POSTGRES_DB=ecommerce
POSTGRES_USER=admin
POSTGRES_PASSWORD=secure_password_123
API_PORT=8000
FRONTEND_PORT=3000
```

Update docker-compose.yml:
```yaml
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  
  backend:
    ports:
      - "${API_PORT}:8000"
```

---

## 📊 Understanding Docker Compose Networking

### **Default Network Behavior**

When you run `docker-compose up`, Compose automatically:

1. **Creates a network** named `{project-name}_default`
2. **Connects all services** to this network
3. **Enables service discovery** by service name
4. **Isolates your project** from other Docker networks

### **Service Communication Example**

```yaml
services:
  frontend:
    image: nginx
    # Can reach backend at: http://backend:8000
  
  backend:
    image: node:16
    # Can reach database at: postgresql://user:pass@database:5432/db
  
  database:
    image: postgres:13
    # Accessible to other services as 'database'
```

### **Network Inspection Commands**

```bash
# List networks
docker network ls

# Inspect project network
docker network inspect ecommerce-compose_default

# See which containers are connected
docker-compose ps
```

---

## ✅ Knowledge Check: Compose Fundamentals

### **Conceptual Understanding**
- [ ] Can explain why Docker Compose is needed for multi-container applications
- [ ] Understands the relationship between services, networks, and volumes
- [ ] Knows how service discovery works in Compose networks
- [ ] Comprehends the difference between `image` and `build` directives
- [ ] Understands dependency management with `depends_on`

### **Practical Skills**
- [ ] Can write a basic docker-compose.yml file
- [ ] Knows essential Compose commands (up, down, ps, logs)
- [ ] Can configure environment variables and volumes
- [ ] Understands how to use health checks
- [ ] Can troubleshoot basic Compose issues

### **E-Commerce Application**
- [ ] Has created a basic compose file for e-commerce stack
- [ ] Successfully started all services with one command
- [ ] Verified service communication between components
- [ ] Implemented basic data persistence for database

---

## 🚀 Next Steps: Building on the Foundation

### **What You've Accomplished**
- ✅ **Understood the orchestration problem** and Docker Compose solution
- ✅ **Learned core Compose concepts** - services, networks, volumes
- ✅ **Created your first compose file** for e-commerce application
- ✅ **Mastered essential commands** for managing multi-container apps

### **Coming Next: YAML Mastery**
In **02-Docker-Compose-YAML-Syntax.md**, you'll learn:
- **Advanced YAML syntax** and best practices
- **Complex service configurations** with all available options
- **Environment variable management** and templating
- **Multi-file composition** for different environments

### **E-Commerce Evolution Preview**
Your e-commerce stack will evolve from basic orchestration to:
- **Custom networks** for security isolation
- **Advanced volume management** for data backup and recovery
- **Environment-specific configurations** for dev/staging/production
- **Health monitoring** and automatic recovery
- **Scaling strategies** for handling increased load

**Continue to YAML Syntax when you're comfortable with these fundamentals and have successfully orchestrated your basic e-commerce stack.**

## Basic Concepts

### 1. Services
Services are the building blocks of your application - each service represents a container.

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
  
  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
```

### 2. Networks
Networks enable communication between services.

```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

services:
  web:
    networks:
      - frontend
  api:
    networks:
      - frontend
      - backend
  database:
    networks:
      - backend
```

### 3. Volumes
Volumes provide persistent data storage.

```yaml
volumes:
  postgres_data:
  app_logs:

services:
  database:
    volumes:
      - postgres_data:/var/lib/postgresql/data
  app:
    volumes:
      - app_logs:/var/log/app
```

### 4. Environment Variables
Configure services with environment-specific values.

```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    env_file:
      - .env
      - .env.production
```

## Your First Compose File

### Simple Web Application
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Web server
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped

  # Application server
  app:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./app:/app
    command: npm start
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
    depends_on:
      - database

  # Database
  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: secret123
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

### Directory Structure
```
my-compose-project/
├── docker-compose.yml
├── .env
├── app/
│   ├── package.json
│   ├── server.js
│   └── ...
└── html/
    └── index.html
```

### Environment File (.env)
```bash
# .env
POSTGRES_PASSWORD=secret123
NODE_ENV=development
APP_PORT=3000
WEB_PORT=8080
```

## Essential Commands

### Basic Operations
```bash
# Start all services
docker compose up

# Start in detached mode (background)
docker compose up -d

# Start specific services
docker compose up web database

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# Stop and remove images
docker compose down --rmi all
```

### Service Management
```bash
# View running services
docker compose ps

# View service logs
docker compose logs
docker compose logs web
docker compose logs -f app  # Follow logs

# Execute commands in running containers
docker compose exec web sh
docker compose exec app npm install

# Run one-off commands
docker compose run app npm test
docker compose run --rm app bash
```

### Build and Development
```bash
# Build services (if using build context)
docker compose build

# Build without cache
docker compose build --no-cache

# Pull latest images
docker compose pull

# Restart services
docker compose restart
docker compose restart web
```

### Scaling Services
```bash
# Scale specific service
docker compose up -d --scale app=3

# Scale multiple services
docker compose up -d --scale app=3 --scale worker=2
```

## Architecture Overview

### Compose File Structure
```yaml
version: '3.8'  # Compose file format version

services:       # Define application services
  service1:
    # Service configuration
  service2:
    # Service configuration

networks:       # Define custom networks (optional)
  network1:
    # Network configuration

volumes:        # Define named volumes (optional)
  volume1:
    # Volume configuration

configs:        # Define configuration objects (optional)
  config1:
    # Configuration

secrets:        # Define secrets (optional)
  secret1:
    # Secret configuration
```

### Service Configuration Options
```yaml
services:
  myapp:
    # Image or build context
    image: myapp:latest
    # OR
    build: 
      context: .
      dockerfile: Dockerfile

    # Port mapping
    ports:
      - "8080:80"
      - "443:443"

    # Environment variables
    environment:
      - NODE_ENV=production
      - DEBUG=false

    # Volume mounts
    volumes:
      - ./app:/usr/src/app
      - app_data:/data

    # Network configuration
    networks:
      - frontend
      - backend

    # Dependencies
    depends_on:
      - database
      - redis

    # Restart policy
    restart: unless-stopped

    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Network Types
```yaml
networks:
  # Bridge network (default)
  frontend:
    driver: bridge

  # Host network
  host_network:
    driver: host

  # Overlay network (Swarm mode)
  overlay_network:
    driver: overlay

  # Custom bridge with configuration
  custom_bridge:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Volume Types
```yaml
volumes:
  # Named volume
  app_data:

  # Named volume with driver options
  nfs_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/dir"

  # External volume
  external_data:
    external: true
```

## Best Practices

### 1. File Organization
```yaml
# Use consistent naming
services:
  web-server:     # Use hyphens
  app-backend:    # Be descriptive
  postgres-db:    # Include service type

# Group related configurations
services:
  web:
    image: nginx:alpine
    ports: ["80:80"]
    networks: [frontend]
    
  app:
    build: .
    networks: [frontend, backend]
    depends_on: [database]
```

### 2. Environment Management
```yaml
# Use environment files
env_file:
  - .env
  - .env.local

# Provide defaults
environment:
  - NODE_ENV=${NODE_ENV:-development}
  - PORT=${PORT:-3000}
```

### 3. Security Considerations
```yaml
# Don't expose unnecessary ports
ports:
  - "127.0.0.1:5432:5432"  # Bind to localhost only

# Use secrets for sensitive data
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  database:
    secrets:
      - db_password
```

### 4. Development vs Production
```yaml
# docker-compose.yml (base configuration)
services:
  app:
    build: .
    environment:
      - NODE_ENV=production

# docker-compose.override.yml (development overrides)
services:
  app:
    volumes:
      - .:/app
    environment:
      - NODE_ENV=development
    command: npm run dev
```

## Common Patterns

### 1. Web Application Stack
```yaml
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports: ["80:80"]
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on: [app]

  app:
    build: .
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/app
    depends_on: [postgres, redis]

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 2. Microservices Architecture
```yaml
version: '3.8'
services:
  api-gateway:
    image: nginx:alpine
    ports: ["80:80"]
    volumes:
      - ./gateway.conf:/etc/nginx/nginx.conf:ro

  user-service:
    build: ./services/user
    networks: [backend]

  order-service:
    build: ./services/order
    networks: [backend]

  database:
    image: postgres:15-alpine
    networks: [backend]
    environment:
      POSTGRES_DB: microservices
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret

networks:
  backend:
    driver: bridge
```

This comprehensive guide covers Docker Compose fundamentals, providing the foundation for building and managing multi-container applications.
