# 🐳 Complete Docker Deployment Guide for E-Commerce Application

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Docker Compose Configurations](#docker-compose-configurations)
3. [Database Setup Integration](#database-setup-integration)
4. [Environment Configuration](#environment-configuration)
5. [Deployment Commands](#deployment-commands)
6. [Production Deployment](#production-deployment)
7. [Monitoring & Troubleshooting](#monitoring--troubleshooting)

---

## 🚀 Quick Start

### **Prerequisites**
- Docker Desktop installed and running
- Git repository cloned
- 8GB RAM minimum, 16GB recommended

### **One-Command Deployment**
```bash
# Clone and deploy in one go
git clone <your-repo-url>
cd e-commerce
./deploy.sh
```

**That's it! Your application will be running at:**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Database**: localhost:5432

---

## 🐳 Docker Compose Configurations

### **Main Configuration (`docker-compose.yml`)**

```yaml
version: '3.8'

services:
  # Database Tier (PostgreSQL)
  database:
    image: postgres:15-alpine
    container_name: ecommerce-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ecommerce_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d ecommerce_db"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Backend Tier (FastAPI)
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ecommerce-backend
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://postgres:admin@database:5432/ecommerce_db
      SECRET_KEY: ${SECRET_KEY:-dev-secret-key}
      DEBUG: ${DEBUG:-true}
      ENVIRONMENT: ${ENVIRONMENT:-development}
    ports:
      - "8000:8000"
    volumes:
      - backend_uploads:/app/uploads
      - backend_logs:/app/logs
    depends_on:
      database:
        condition: service_healthy
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Frontend Tier (React + Nginx)
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        - REACT_APP_API_URL=http://localhost:8000
        - REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
    container_name: ecommerce-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  backend_uploads:
  backend_logs:

networks:
  ecommerce-network:
    driver: bridge
```

### **Development Configuration (`docker-compose.dev.yml`)**

```yaml
version: '3.8'

services:
  database:
    image: postgres:15-alpine
    container_name: ecommerce-db-dev
    environment:
      POSTGRES_DB: ecommerce_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data
    networks:
      - ecommerce-dev

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: ecommerce-backend-dev
    environment:
      DATABASE_URL: postgresql://postgres:admin@database:5432/ecommerce_dev
      SECRET_KEY: dev-secret-key
      DEBUG: "true"
      RELOAD: "true"
    ports:
      - "8000:8000"
      - "5678:5678"  # Debug port
    volumes:
      - ./backend:/app
      - /app/__pycache__
    depends_on:
      - database
    networks:
      - ecommerce-dev
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: ecommerce-frontend-dev
    environment:
      - REACT_APP_API_URL=http://localhost:8000
      - CHOKIDAR_USEPOLLING=true
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend
    networks:
      - ecommerce-dev
    stdin_open: true
    tty: true

volumes:
  postgres_dev_data:

networks:
  ecommerce-dev:
    driver: bridge
```

---

## 🗄️ Database Setup Integration

### **Automated Database Initialization**

The Docker setup now integrates with our consolidated `database/setup.py` script:

#### **Method 1: Docker + Setup Script (Recommended)**
```bash
# 1. Start database container
docker-compose up -d database

# 2. Wait for database to be ready
docker-compose logs -f database

# 3. Run database setup
python database/setup.py --all

# 4. Start remaining services
docker-compose up -d backend frontend
```

#### **Method 2: Full Docker Compose**
```bash
# Start all services (database will auto-initialize)
docker-compose up -d

# Check if database needs setup
docker-compose exec backend python -c "
from app.database import engine
from sqlalchemy import text
with engine.connect() as conn:
    result = conn.execute(text('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \\'public\\''))
    if result.scalar() == 0:
        print('Database needs initialization')
    else:
        print('Database already initialized')
"

# If needed, run setup inside container
docker-compose exec backend python /app/database/setup.py --all
```

### **Database Configuration in Docker**

The database container uses these settings:
```yaml
environment:
  POSTGRES_DB: ecommerce_db
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: admin  # Matches setup.py configuration
```

---

## ⚙️ Environment Configuration

### **Environment Variables (`.env`)**

```env
# Database Configuration
DATABASE_URL=postgresql://postgres:admin@database:5432/ecommerce_db
DB_HOST=database
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=postgres
DB_PASSWORD=admin

# Application Configuration
SECRET_KEY=your-super-secret-key-change-in-production
DEBUG=true
ENVIRONMENT=development

# Frontend Configuration
REACT_APP_API_URL=http://localhost:8000
REACT_APP_API_BASE_URL=http://localhost:8000/api/v1

# CORS Configuration
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:3001"]
```

### **Docker Environment Variables**

```yaml
# Backend service environment
environment:
  DATABASE_URL: postgresql://postgres:admin@database:5432/ecommerce_db
  SECRET_KEY: ${SECRET_KEY:-dev-secret-key}
  DEBUG: ${DEBUG:-true}
  ENVIRONMENT: ${ENVIRONMENT:-development}

# Frontend build arguments
build:
  args:
    - REACT_APP_API_URL=http://localhost:8000
    - REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
```

---

## 🚀 Deployment Commands

### **Basic Operations**

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up --build -d

# View service status
docker-compose ps
```

### **Using the Management Script**

```bash
# Start everything with setup
./docker-manage.sh start

# Check status
./docker-manage.sh status

# View logs for specific service
./docker-manage.sh logs backend

# Scale services
./docker-manage.sh scale backend 3

# Backup database
./docker-manage.sh backup

# Clean up
./docker-manage.sh cleanup
```

### **Database Operations in Docker**

```bash
# Initialize database with sample data
docker-compose exec backend python database/setup.py --all

# Validate database connection
docker-compose exec backend python database/setup.py --validate

# Reset database
docker-compose exec backend python database/setup.py --reset

# Create backup
docker-compose exec backend python database/setup.py --backup

# Access database directly
docker-compose exec database psql -U postgres -d ecommerce_db
```

---

## 🏭 Production Deployment

### **Production Docker Compose (`docker-compose.prod.yml`)**

```yaml
version: '3.8'

services:
  database:
    image: postgres:15-alpine
    container_name: ecommerce-db-prod
    restart: always
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
      - ./database/backup:/backup
    networks:
      - ecommerce-prod
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 30s
      timeout: 10s
      retries: 3
    # No port exposure for security
    expose:
      - "5432"

  backend:
    image: ${DOCKER_REGISTRY}/ecommerce-backend:${IMAGE_TAG}
    container_name: ecommerce-backend-prod
    restart: always
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB}
      SECRET_KEY: ${SECRET_KEY}
      DEBUG: "false"
      ENVIRONMENT: production
    volumes:
      - backend_uploads:/app/uploads
      - backend_logs:/app/logs
    depends_on:
      database:
        condition: service_healthy
    networks:
      - ecommerce-prod
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    expose:
      - "8000"

  frontend:
    image: ${DOCKER_REGISTRY}/ecommerce-frontend:${IMAGE_TAG}
    container_name: ecommerce-frontend-prod
    restart: always
    depends_on:
      - backend
    networks:
      - ecommerce-prod
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
          cpus: '0.25'
    expose:
      - "80"

  nginx:
    image: nginx:alpine
    container_name: ecommerce-nginx-prod
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/prod.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx_logs:/var/log/nginx
    depends_on:
      - frontend
      - backend
    networks:
      - ecommerce-prod

volumes:
  postgres_prod_data:
  backend_uploads:
  backend_logs:
  nginx_logs:

networks:
  ecommerce-prod:
    driver: bridge
```

### **Production Deployment Steps**

```bash
# 1. Set production environment variables
export POSTGRES_DB=ecommerce_prod
export POSTGRES_USER=ecommerce_user
export POSTGRES_PASSWORD=secure_production_password
export SECRET_KEY=your-production-secret-key
export DOCKER_REGISTRY=your-registry.com
export IMAGE_TAG=latest

# 2. Build production images
docker build -f docker/Dockerfile.backend -t ${DOCKER_REGISTRY}/ecommerce-backend:${IMAGE_TAG} .
docker build -f docker/Dockerfile.frontend -t ${DOCKER_REGISTRY}/ecommerce-frontend:${IMAGE_TAG} .

# 3. Push to registry
docker push ${DOCKER_REGISTRY}/ecommerce-backend:${IMAGE_TAG}
docker push ${DOCKER_REGISTRY}/ecommerce-frontend:${IMAGE_TAG}

# 4. Deploy to production
docker-compose -f docker-compose.prod.yml up -d

# 5. Initialize production database
docker-compose -f docker-compose.prod.yml exec backend python database/setup.py --init-clean
```

---

## 📊 Monitoring & Troubleshooting

### **Health Checks**

```bash
# Check all service health
docker-compose ps

# Check specific service health
docker inspect --format='{{.State.Health.Status}}' ecommerce-backend

# View health check logs
docker inspect ecommerce-backend | jq '.[0].State.Health'
```

### **Service Logs**

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f database

# View logs with timestamps
docker-compose logs -f -t backend

# View last 100 lines
docker-compose logs --tail=100 backend
```

### **Resource Monitoring**

```bash
# View resource usage
docker stats

# View detailed container info
docker inspect ecommerce-backend

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

### **Common Issues & Solutions**

#### **Database Connection Issues**
```bash
# Check database status
docker-compose exec database pg_isready -U postgres

# Test connection from backend
docker-compose exec backend python -c "
import psycopg2
conn = psycopg2.connect('postgresql://postgres:admin@database:5432/ecommerce_db')
print('Connection successful')
"

# Reset database if needed
docker-compose exec backend python database/setup.py --reset
docker-compose exec backend python database/setup.py --init-sample
```

#### **Port Conflicts**
```bash
# Check what's using ports
lsof -i :3000
lsof -i :8000
lsof -i :5432

# Kill processes using ports
kill -9 $(lsof -t -i:3000)
```

#### **Build Issues**
```bash
# Clean build cache
docker-compose build --no-cache

# Remove all containers and rebuild
docker-compose down -v
docker-compose up --build -d
```

#### **Volume Issues**
```bash
# Check volume mounts
docker inspect ecommerce-backend | grep -A 10 "Mounts"

# Reset volumes
docker-compose down -v
docker volume prune
docker-compose up -d
```

### **Performance Optimization**

```bash
# Limit container resources
docker-compose -f docker-compose.yml up -d --scale backend=2

# Monitor performance
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Optimize images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

---

## 🎯 Quick Reference

### **Essential Commands**
```bash
# Complete deployment
./deploy.sh

# Manual deployment
docker-compose up -d
python database/setup.py --all

# Check status
docker-compose ps
./docker-manage.sh status

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

### **Service URLs**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432

### **Default Credentials**
- **Admin**: admin@ecommerce.com / admin123
- **User**: user@ecommerce.com / user123
- **Database**: postgres / admin

### **File Locations**
- **Main Config**: `docker-compose.yml`
- **Dev Config**: `docker-compose.dev.yml`
- **Prod Config**: `docker-compose.prod.yml`
- **Database Setup**: `database/setup.py`
- **Environment**: `.env`

---

## 🚀 Success!

Your Docker deployment is now configured with:
- ✅ **3-tier architecture** (Frontend + Backend + Database)
- ✅ **Automated database setup** with consolidated script
- ✅ **Health checks** for all services
- ✅ **Development and production** configurations
- ✅ **Comprehensive monitoring** and troubleshooting
- ✅ **Security best practices**
- ✅ **Scalable architecture**

**Start your application:**
```bash
./deploy.sh
```

**Access at http://localhost:3000 🎉**
