# Docker Compose YAML Syntax - From Basics to E-Commerce Configuration

## 📋 Learning Objectives
- **Master** YAML syntax fundamentals and Docker Compose specifics
- **Understand** Compose file structure and version differences
- **Apply** advanced YAML features to complex e-commerce configurations
- **Build** production-ready compose files with proper syntax

---

## 🤔 Why YAML for Docker Compose?

### **The Configuration Challenge**

Before YAML, configuration was often done through:
- **Command-line arguments** (hard to manage and reproduce)
- **Shell scripts** (platform-specific and error-prone)
- **JSON files** (verbose and not human-friendly)

### **YAML Benefits for Infrastructure**
```yaml
# YAML is human-readable and concise
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
    volumes:
      - db_data:/var/lib/postgresql/data

# Equivalent JSON (verbose and harder to read)
{
  "services": {
    "database": {
      "image": "postgres:13",
      "environment": {
        "POSTGRES_DB": "ecommerce"
      },
      "volumes": [
        "db_data:/var/lib/postgresql/data"
      ]
    }
  }
}
```

**Key Advantages:**
- ✅ **Human-readable** - Easy to understand and modify
- ✅ **Concise** - Less verbose than JSON or XML
- ✅ **Comments supported** - Document your configuration
- ✅ **Multi-line strings** - Handle complex configurations
- ✅ **Version control friendly** - Clear diffs and merges

---

## 📚 YAML Fundamentals for Docker Compose

### **Basic Data Types**

#### **Scalars (Simple Values)**
```yaml
# Strings (quotes optional for simple strings)
service_name: ecommerce-backend
description: "E-commerce API service"
version: '3.8'  # Quotes prevent version being interpreted as float

# Numbers
port: 8000
memory_limit: 512
cpu_shares: 1024

# Booleans
debug: true
production: false
enable_ssl: yes  # yes/no also work

# Null values
database_password: null
cache_url: ~  # ~ is YAML null
```

#### **Lists (Arrays)**
```yaml
# List syntax (preferred for Docker Compose)
ports:
  - "3000:3000"
  - "8000:8000"
  - "80:80"

# Inline list syntax
ports: ["3000:3000", "8000:8000", "80:80"]

# Environment variables list
environment:
  - NODE_ENV=production
  - DEBUG=false
  - API_KEY=secret123
```

#### **Objects (Dictionaries)**
```yaml
# Object syntax
database:
  image: postgres:13
  environment:
    POSTGRES_DB: ecommerce
    POSTGRES_USER: admin
  volumes:
    - db_data:/var/lib/postgresql/data
```

### **YAML Syntax Rules Critical for Docker Compose**

#### **1. Indentation (Spaces Only!)**
```yaml
# ✅ Correct - 2 spaces per level
services:
  web:
    image: nginx
    ports:
      - "80:80"

# ❌ Wrong - tabs or inconsistent spacing
services:
	web:  # Tab used
    image: nginx
      ports:  # 6 spaces instead of 4
    - "80:80"  # Wrong indentation
```

#### **2. String Quoting Rules**
```yaml
# Simple strings - no quotes needed
image: nginx
name: myapp

# Strings with special characters - quotes required
password: "p@ssw0rd!"
description: "My app: version 2.0"

# Version numbers - always quote to prevent float interpretation
version: '3.8'  # Without quotes becomes 3.8 (float)

# Environment variables with special characters
environment:
  DATABASE_URL: "postgresql://user:p@ss@localhost:5432/db"
```

#### **3. Multi-line Strings**
```yaml
# Literal block (preserves line breaks) - use |
nginx_config: |
  server {
    listen 80;
    server_name example.com;
    location / {
      proxy_pass http://backend:8000;
    }
  }

# Folded block (joins lines with spaces) - use >
description: >
  This is a long description
  that spans multiple lines
  but will be joined into
  a single line with spaces.
```

---

## 🏗️ Docker Compose File Structure

### **Complete File Anatomy**

```yaml
# 1. Version declaration (required)
version: '3.8'

# 2. Services definition (required)
services:
  service-name:
    # Service configuration

# 3. Networks definition (optional)
networks:
  network-name:
    # Network configuration

# 4. Volumes definition (optional)
volumes:
  volume-name:
    # Volume configuration

# 5. Secrets definition (optional, v3.1+)
secrets:
  secret-name:
    # Secret configuration

# 6. Configs definition (optional, v3.3+)
configs:
  config-name:
    # Config configuration
```

### **Version Evolution and Features**

#### **Version Comparison**
```yaml
# Version 3.8 (recommended for most use cases)
version: '3.8'
# Features: All modern Docker features, health checks, secrets, configs

# Version 3.7
version: '3.7'
# Features: External secrets, rollback config

# Version 3.6
version: '3.6'
# Features: Device mapping, tmpfs size

# Version 3.5
version: '3.5'
# Features: Isolation mode, shm_size

# Version 3.4
version: '3.4'
# Features: Start period for health checks
```

#### **Choosing the Right Version**
```yaml
# For modern Docker installations (recommended)
version: '3.8'

# For older Docker versions (18.06+)
version: '3.7'

# For legacy systems (17.12+)
version: '3.6'
```

---

## 🛒 E-Commerce YAML Configuration: Progressive Complexity

### **Level 1: Basic E-Commerce Stack**

```yaml
version: '3.8'

services:
  # Database service
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure123
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Backend API service
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://admin:secure123@database:5432/ecommerce
    depends_on:
      - database

  # Frontend service
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      REACT_APP_API_URL: http://localhost:8000
    depends_on:
      - backend

volumes:
  postgres_data:
```

### **Level 2: Advanced E-Commerce Configuration**

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  database:
    image: postgres:13-alpine
    container_name: ecommerce-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ecommerce}
      POSTGRES_USER: ${POSTGRES_USER:-admin}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    ports:
      - "${DB_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-admin} -d ${POSTGRES_DB:-ecommerce}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    networks:
      - database_network

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "${REDIS_PORT:-6379}:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - cache_network

  # Backend API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        NODE_ENV: ${NODE_ENV:-development}
    container_name: ecommerce-backend
    restart: unless-stopped
    environment:
      # Database configuration
      DATABASE_URL: postgresql://${POSTGRES_USER:-admin}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB:-ecommerce}
      
      # Redis configuration
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      
      # Application configuration
      NODE_ENV: ${NODE_ENV:-development}
      PORT: 8000
      JWT_SECRET: ${JWT_SECRET}
      API_KEY: ${API_KEY}
      
      # Email configuration
      SMTP_HOST: ${SMTP_HOST}
      SMTP_PORT: ${SMTP_PORT:-587}
      SMTP_USER: ${SMTP_USER}
      SMTP_PASS: ${SMTP_PASS}
    ports:
      - "${API_PORT:-8000}:8000"
    volumes:
      - ./backend:/app
      - /app/node_modules
      - uploads:/app/uploads
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
    networks:
      - database_network
      - cache_network
      - api_network

  # Frontend Application
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        REACT_APP_ENV: ${NODE_ENV:-development}
    container_name: ecommerce-frontend
    restart: unless-stopped
    environment:
      REACT_APP_API_URL: ${REACT_APP_API_URL:-http://localhost:8000}
      REACT_APP_ENV: ${NODE_ENV:-development}
      REACT_APP_STRIPE_KEY: ${STRIPE_PUBLISHABLE_KEY}
    ports:
      - "${FRONTEND_PORT:-3000}:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - api_network
      - web_network

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: ecommerce-nginx
    restart: unless-stopped
    ports:
      - "${HTTP_PORT:-80}:80"
      - "${HTTPS_PORT:-443}:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - uploads:/var/www/uploads:ro
    depends_on:
      - frontend
      - backend
    networks:
      - web_network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

# Network definitions
networks:
  database_network:
    driver: bridge
    internal: true  # Database network is internal only
  
  cache_network:
    driver: bridge
    internal: true  # Cache network is internal only
  
  api_network:
    driver: bridge
  
  web_network:
    driver: bridge

# Volume definitions
volumes:
  postgres_data:
    driver: local
  
  redis_data:
    driver: local
  
  uploads:
    driver: local
```

### **Level 3: Production-Ready Configuration with Secrets**

```yaml
version: '3.8'

services:
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB_FILE: /run/secrets/postgres_db
      POSTGRES_USER_FILE: /run/secrets/postgres_user
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
    secrets:
      - postgres_db
      - postgres_user
      - postgres_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - database_network
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'

  backend:
    build: ./backend
    environment:
      DATABASE_URL_FILE: /run/secrets/database_url
      JWT_SECRET_FILE: /run/secrets/jwt_secret
    secrets:
      - database_url
      - jwt_secret
    networks:
      - database_network
      - api_network
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

# Secrets definition
secrets:
  postgres_db:
    file: ./secrets/postgres_db.txt
  postgres_user:
    file: ./secrets/postgres_user.txt
  postgres_password:
    file: ./secrets/postgres_password.txt
  database_url:
    file: ./secrets/database_url.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

networks:
  database_network:
    driver: bridge
    internal: true
  api_network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
```

---

## 🔧 Advanced YAML Features for Docker Compose

### **1. Environment Variable Substitution**

#### **Basic Variable Substitution**
```yaml
# .env file
POSTGRES_VERSION=13
API_PORT=8000
NODE_ENV=development

# docker-compose.yml
services:
  database:
    image: postgres:${POSTGRES_VERSION}
  
  backend:
    ports:
      - "${API_PORT}:8000"
    environment:
      NODE_ENV: ${NODE_ENV}
```

#### **Default Values**
```yaml
services:
  database:
    image: postgres:${POSTGRES_VERSION:-13}  # Default to 13 if not set
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ecommerce}  # Default to ecommerce
```

#### **Required Variables**
```yaml
services:
  backend:
    environment:
      JWT_SECRET: ${JWT_SECRET?JWT_SECRET is required}  # Error if not set
      API_KEY: ${API_KEY:?Please set API_KEY}  # Custom error message
```

### **2. YAML Anchors and Aliases (DRY Principle)**

#### **Common Configuration Patterns**
```yaml
version: '3.8'

# Define reusable configurations
x-common-variables: &common-variables
  NODE_ENV: ${NODE_ENV:-development}
  LOG_LEVEL: ${LOG_LEVEL:-info}
  TZ: ${TIMEZONE:-UTC}

x-restart-policy: &restart-policy
  restart: unless-stopped

x-healthcheck-defaults: &healthcheck-defaults
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s

services:
  backend:
    <<: *restart-policy  # Use restart policy
    environment:
      <<: *common-variables  # Use common variables
      DATABASE_URL: postgresql://user:pass@database:5432/db
    healthcheck:
      <<: *healthcheck-defaults  # Use healthcheck defaults
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]

  worker:
    <<: *restart-policy  # Reuse restart policy
    environment:
      <<: *common-variables  # Reuse common variables
      WORKER_TYPE: background
```

### **3. Extension Fields (x-* fields)**

```yaml
version: '3.8'

# Extension fields (ignored by Docker Compose but useful for organization)
x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"

x-deploy: &default-deploy
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
    reservations:
      memory: 256M
      cpus: '0.25'

services:
  backend:
    image: my-backend
    logging: *default-logging
    deploy: *default-deploy
  
  frontend:
    image: my-frontend
    logging: *default-logging
    deploy: *default-deploy
```

---

## 🧪 Hands-On Practice: YAML Mastery

### **Exercise 1: Environment Variable Management**

Create a comprehensive `.env` file for your e-commerce project:

```bash
# .env
# Database Configuration
POSTGRES_VERSION=13
POSTGRES_DB=ecommerce
POSTGRES_USER=ecommerce_admin
POSTGRES_PASSWORD=secure_password_123

# Application Configuration
NODE_ENV=development
API_PORT=8000
FRONTEND_PORT=3000
NGINX_PORT=80

# Security
JWT_SECRET=your_jwt_secret_here
API_KEY=your_api_key_here

# External Services
REDIS_PASSWORD=redis_password_123
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
```

Update your docker-compose.yml to use these variables:

```yaml
version: '3.8'

services:
  database:
    image: postgres:${POSTGRES_VERSION}
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "${DB_PORT:-5432}:5432"

  backend:
    build: ./backend
    ports:
      - "${API_PORT}:8000"
    environment:
      NODE_ENV: ${NODE_ENV}
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB}
      JWT_SECRET: ${JWT_SECRET}

  frontend:
    build: ./frontend
    ports:
      - "${FRONTEND_PORT}:3000"
    environment:
      REACT_APP_API_URL: http://localhost:${API_PORT}
      REACT_APP_ENV: ${NODE_ENV}
```

### **Exercise 2: Using YAML Anchors**

Create a DRY (Don't Repeat Yourself) compose file:

```yaml
version: '3.8'

# Reusable configurations
x-common-env: &common-env
  NODE_ENV: ${NODE_ENV:-development}
  LOG_LEVEL: ${LOG_LEVEL:-info}
  TZ: ${TIMEZONE:-UTC}

x-restart-policy: &restart-policy
  restart: unless-stopped

x-healthcheck: &healthcheck
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s

services:
  backend:
    <<: *restart-policy
    build: ./backend
    environment:
      <<: *common-env
      DATABASE_URL: postgresql://user:pass@database:5432/db
    healthcheck:
      <<: *healthcheck
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]

  worker:
    <<: *restart-policy
    build: ./backend
    command: npm run worker
    environment:
      <<: *common-env
      WORKER_TYPE: background
    healthcheck:
      <<: *healthcheck
      test: ["CMD", "curl", "-f", "http://localhost:8000/worker/health"]
```

### **Exercise 3: Multi-Environment Configuration**

Create environment-specific override files:

**docker-compose.yml** (base configuration):
```yaml
version: '3.8'

services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin

  backend:
    build: ./backend
    environment:
      NODE_ENV: development
```

**docker-compose.override.yml** (development overrides):
```yaml
version: '3.8'

services:
  database:
    ports:
      - "5432:5432"  # Expose database port in development
    environment:
      POSTGRES_PASSWORD: dev_password

  backend:
    volumes:
      - ./backend:/app  # Mount source code for hot reload
      - /app/node_modules
    environment:
      DEBUG: "true"
```

**docker-compose.prod.yml** (production overrides):
```yaml
version: '3.8'

services:
  database:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

  backend:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

secrets:
  db_password:
    external: true
```

**Usage:**
```bash
# Development (uses docker-compose.yml + docker-compose.override.yml)
docker-compose up -d

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## ✅ YAML Syntax Validation and Best Practices

### **1. Validation Tools**

#### **Built-in Validation**
```bash
# Validate compose file syntax
docker-compose config

# Validate and show resolved configuration
docker-compose config --resolve-env-vars

# Validate specific file
docker-compose -f docker-compose.prod.yml config
```

#### **Online YAML Validators**
- **YAML Lint**: http://www.yamllint.com/
- **Docker Compose Validator**: Various online tools
- **IDE Extensions**: VS Code YAML extension with Docker Compose schema

### **2. Common YAML Mistakes and Solutions**

#### **Indentation Errors**
```yaml
# ❌ Wrong - inconsistent indentation
services:
  web:
  image: nginx  # Should be indented
    ports:
      - "80:80"

# ✅ Correct - consistent 2-space indentation
services:
  web:
    image: nginx
    ports:
      - "80:80"
```

#### **Quote Issues**
```yaml
# ❌ Wrong - version interpreted as float
version: 3.8

# ✅ Correct - version as string
version: '3.8'

# ❌ Wrong - special characters without quotes
password: p@ssw0rd!

# ✅ Correct - special characters quoted
password: "p@ssw0rd!"
```

#### **List vs Object Confusion**
```yaml
# ❌ Wrong - mixing list and object syntax
environment:
  - NODE_ENV: production  # This creates a list with an object
  - DEBUG: false

# ✅ Correct - consistent list syntax
environment:
  - NODE_ENV=production
  - DEBUG=false

# ✅ Alternative - object syntax
environment:
  NODE_ENV: production
  DEBUG: false
```

### **3. Best Practices**

#### **File Organization**
```yaml
version: '3.8'

# 1. Services (main section)
services:
  # Order services by dependency (database first, then app services)
  database:
    # Configuration
  
  backend:
    # Configuration
  
  frontend:
    # Configuration

# 2. Networks (if custom networks needed)
networks:
  # Network definitions

# 3. Volumes (persistent storage)
volumes:
  # Volume definitions

# 4. Secrets (sensitive data)
secrets:
  # Secret definitions
```

#### **Naming Conventions**
```yaml
services:
  # Use descriptive, consistent names
  ecommerce-database:    # Clear purpose
  ecommerce-backend:     # Consistent prefix
  ecommerce-frontend:    # Easy to identify

networks:
  ecommerce-network:     # Project-specific naming

volumes:
  ecommerce-db-data:     # Descriptive volume names
  ecommerce-uploads:     # Clear data purpose
```

#### **Documentation**
```yaml
version: '3.8'

# E-Commerce Application Stack
# This compose file defines a complete e-commerce platform with:
# - PostgreSQL database for data persistence
# - Node.js backend API for business logic
# - React frontend for user interface
# - Nginx reverse proxy for load balancing

services:
  # PostgreSQL Database Service
  # Stores product catalog, user accounts, and order data
  database:
    image: postgres:13
    # ... configuration
  
  # Backend API Service
  # Provides REST API for frontend and mobile apps
  backend:
    build: ./backend
    # ... configuration
```

---

## 📊 Knowledge Check: YAML Mastery

### **Conceptual Understanding**
- [ ] Understands YAML syntax rules and data types
- [ ] Knows Docker Compose file structure and sections
- [ ] Comprehends environment variable substitution
- [ ] Can use YAML anchors and aliases for DRY configuration
- [ ] Understands multi-file composition strategies

### **Practical Skills**
- [ ] Can write syntactically correct docker-compose.yml files
- [ ] Knows how to validate YAML syntax and configuration
- [ ] Can create environment-specific configurations
- [ ] Understands how to use secrets and configs
- [ ] Can troubleshoot common YAML syntax errors

### **E-Commerce Application**
- [ ] Has created comprehensive compose file for e-commerce stack
- [ ] Implemented environment variable management
- [ ] Used advanced YAML features for configuration reuse
- [ ] Created multi-environment setup (dev/staging/prod)

---

## 🚀 Next Steps: Service Configuration Deep Dive

### **What You've Mastered**
- ✅ **YAML syntax fundamentals** and Docker Compose specifics
- ✅ **Environment variable management** and substitution
- ✅ **Advanced YAML features** like anchors and extension fields
- ✅ **Multi-environment configuration** strategies
- ✅ **Validation and best practices** for production-ready files

### **Coming Next: Service Configuration**
In **03-Docker-Compose-Services.md**, you'll learn:
- **Complete service configuration options** and their use cases
- **Build vs image strategies** for different scenarios
- **Resource management** and performance optimization
- **Health checks and monitoring** for production reliability

### **E-Commerce Evolution Preview**
Your YAML skills will enable you to:
- **Configure complex service relationships** with proper dependencies
- **Implement environment-specific optimizations** for dev/staging/prod
- **Use advanced features** like secrets, configs, and resource limits
- **Create maintainable configurations** that scale with your application

**Continue to Service Configuration when you're comfortable with YAML syntax and have created comprehensive compose files for your e-commerce application.**

# Service definitions
services:
  service-name:
    # Service configuration options
    
# Network definitions (optional)
networks:
  network-name:
    # Network configuration

# Volume definitions (optional)
volumes:
  volume-name:
    # Volume configuration

# Configuration definitions (optional)
configs:
  config-name:
    # Configuration options

# Secret definitions (optional)
secrets:
  secret-name:
    # Secret configuration
```

### Version Compatibility
```yaml
# Version 3.8 (recommended for Docker Engine 19.03+)
version: '3.8'

# Version 3.7 (Docker Engine 18.06+)
version: '3.7'

# Version 3.6 (Docker Engine 18.02+)
version: '3.6'

# Features by version
# 3.8: Support for external networks, init option
# 3.7: Support for rollback_config, update_config
# 3.6: Support for tmpfs size option
```

## Service Configuration

### Basic Service Options
```yaml
services:
  web:
    # Image specification
    image: nginx:alpine
    
    # OR build from Dockerfile
    build: .
    
    # OR build with context
    build:
      context: .
      dockerfile: Dockerfile.prod
      args:
        - NODE_ENV=production
    
    # Container name
    container_name: my-web-server
    
    # Hostname
    hostname: web-server
    
    # Restart policy
    restart: unless-stopped  # no, always, on-failure, unless-stopped
    
    # Working directory
    working_dir: /app
    
    # User specification
    user: "1000:1000"
    
    # Command override
    command: ["nginx", "-g", "daemon off;"]
    
    # Entrypoint override
    entrypoint: ["/docker-entrypoint.sh"]
```

### Port Configuration
```yaml
services:
  web:
    ports:
      # Short syntax: HOST:CONTAINER
      - "8080:80"
      - "443:443"
      
      # Long syntax with protocol
      - target: 80
        published: 8080
        protocol: tcp
        mode: host
      
      # Bind to specific interface
      - "127.0.0.1:8080:80"
      
      # Random host port
      - "80"
      
    # Expose ports without publishing
    expose:
      - "3000"
      - "8000"
```

### Volume Configuration
```yaml
services:
  app:
    volumes:
      # Bind mounts
      - ./app:/usr/src/app                    # Relative path
      - /host/path:/container/path            # Absolute path
      - /host/path:/container/path:ro         # Read-only
      
      # Named volumes
      - app_data:/data
      - logs:/var/log
      
      # Anonymous volumes
      - /var/lib/mysql
      
      # Tmpfs mounts
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 100M
      
      # Long syntax
      - type: bind
        source: ./app
        target: /usr/src/app
        read_only: true
      
      - type: volume
        source: app_data
        target: /data
        volume:
          nocopy: true
```

### Environment Variables
```yaml
services:
  app:
    # Simple key-value pairs
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - PORT=3000
    
    # Alternative dictionary syntax
    environment:
      NODE_ENV: production
      DEBUG: false
      PORT: 3000
    
    # Environment files
    env_file:
      - .env
      - .env.local
      - path/to/env.file
    
    # Variable substitution
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - PORT=${PORT:-3000}              # Default value
      - HOST=${HOST:-0.0.0.0}
```

### Network Configuration
```yaml
services:
  web:
    # Use default network
    networks:
      - default
    
    # Use custom networks
    networks:
      - frontend
      - backend
    
    # Network with aliases
    networks:
      frontend:
        aliases:
          - web-server
          - www
    
    # Network with static IP
    networks:
      frontend:
        ipv4_address: 172.20.0.10
    
    # External links (legacy)
    external_links:
      - redis_1
      - project_db_1:mysql
```

### Dependencies and Health Checks
```yaml
services:
  web:
    # Service dependencies
    depends_on:
      - database
      - redis
    
    # Dependencies with conditions (requires healthcheck)
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_started
    
    # Health check configuration
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Disable health check
    healthcheck:
      disable: true
```

## Advanced YAML Features

### YAML Anchors and Aliases
```yaml
# Define reusable configurations
x-common-variables: &common-env
  NODE_ENV: production
  LOG_LEVEL: info

x-restart-policy: &restart
  restart: unless-stopped

services:
  web:
    <<: *restart              # Merge restart policy
    environment:
      <<: *common-env         # Merge common environment
      PORT: 3000              # Add specific variables
  
  api:
    <<: *restart
    environment:
      <<: *common-env
      PORT: 8080

# Common service template
x-service-template: &service
  restart: unless-stopped
  networks:
    - backend
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  user-service:
    <<: *service
    build: ./services/user
    
  order-service:
    <<: *service
    build: ./services/order
```

### Variable Substitution
```yaml
# Environment variable substitution
services:
  web:
    image: ${WEB_IMAGE:-nginx:alpine}
    ports:
      - "${WEB_PORT:-80}:80"
    environment:
      - API_URL=http://api:${API_PORT:-8080}

# .env file
WEB_IMAGE=nginx:1.21-alpine
WEB_PORT=8080
API_PORT=3000
```

### Extension Fields
```yaml
# Extension fields (ignored by Compose)
x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

x-deploy: &default-deploy
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3

services:
  web:
    image: nginx
    logging: *default-logging
    deploy: *default-deploy
  
  app:
    build: .
    logging: *default-logging
    deploy: *default-deploy
```

## Validation and Best Practices

### YAML Validation
```bash
# Validate Compose file syntax
docker compose config

# Validate and show resolved configuration
docker compose config --resolve-env-vars

# Validate specific file
docker compose -f docker-compose.prod.yml config

# Check for unused variables
docker compose config --quiet
```

### Common YAML Mistakes
```yaml
# ❌ Wrong indentation
services:
web:              # Missing indentation
  image: nginx

# ❌ Mixing tabs and spaces
services:
  web:
	image: nginx    # Tab used instead of spaces

# ❌ Missing quotes for special characters
environment:
  - PASSWORD=p@ssw0rd!    # Should be quoted

# ❌ Incorrect list syntax
ports:
  - 80:80         # Missing quotes for port mapping
  
# ✅ Correct versions
services:
  web:              # Proper indentation (2 spaces)
    image: nginx
    
environment:
  - PASSWORD="p@ssw0rd!"  # Quoted special characters
  
ports:
  - "80:80"       # Quoted port mapping
```

### Best Practices
```yaml
# 1. Use consistent indentation (2 spaces)
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"

# 2. Quote port mappings and special values
ports:
  - "8080:80"
  - "443:443"

environment:
  - DATABASE_URL="postgresql://user:pass@host:5432/db"

# 3. Use meaningful service names
services:
  web-server:           # Clear purpose
  api-backend:          # Descriptive
  postgres-database:    # Include technology

# 4. Group related configurations
services:
  web:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
    volumes: ["./nginx.conf:/etc/nginx/nginx.conf:ro"]
    networks: [frontend]
    depends_on: [app]
    restart: unless-stopped

# 5. Use environment files for sensitive data
env_file:
  - .env
  - .env.local

# 6. Document complex configurations
services:
  database:
    image: postgres:15-alpine
    # Database configuration for production use
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: appuser
      # Password loaded from .env file
      POSTGRES_PASSWORD: ${DB_PASSWORD}
```

## Common Patterns

### 1. Multi-Environment Configuration
```yaml
# docker-compose.yml (base)
version: '3.8'
services:
  app:
    build: .
    environment:
      - NODE_ENV=production
    networks:
      - app-network

networks:
  app-network:

# docker-compose.override.yml (development)
version: '3.8'
services:
  app:
    volumes:
      - .:/app
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
    command: npm run dev

# docker-compose.prod.yml (production)
version: '3.8'
services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
```

### 2. Microservices Template
```yaml
version: '3.8'

x-service-defaults: &service-defaults
  restart: unless-stopped
  networks:
    - microservices
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  api-gateway:
    <<: *service-defaults
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf:ro

  user-service:
    <<: *service-defaults
    build: ./services/user
    environment:
      - DATABASE_URL=${USER_DB_URL}
      - JWT_SECRET=${JWT_SECRET}

  order-service:
    <<: *service-defaults
    build: ./services/order
    environment:
      - DATABASE_URL=${ORDER_DB_URL}
      - PAYMENT_API_KEY=${PAYMENT_API_KEY}

  shared-database:
    <<: *service-defaults
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: microservices
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

networks:
  microservices:
    driver: bridge

volumes:
  postgres_data:
```

### 3. Development Stack
```yaml
version: '3.8'

services:
  # Frontend development server
  frontend:
    build:
      context: ./frontend
      target: development
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8080
    command: npm start

  # Backend API server
  backend:
    build:
      context: ./backend
      target: development
    volumes:
      - ./backend:/app
      - /app/node_modules
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://dev:dev@postgres:5432/devdb
    depends_on:
      - postgres
      - redis
    command: npm run dev

  # Database
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev:/var/lib/postgresql/data

  # Cache
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_dev:/data

volumes:
  postgres_dev:
  redis_dev:
```

This comprehensive guide covers Docker Compose YAML syntax, from basic concepts to advanced patterns, ensuring you can create maintainable and scalable multi-container applications.
