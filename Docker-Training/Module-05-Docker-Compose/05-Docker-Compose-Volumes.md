# Docker Compose Volumes - From Data Loss to E-Commerce Persistence

## 📋 Learning Objectives
- **Master** Docker volume concepts and data persistence strategies
- **Understand** volume types and their appropriate use cases
- **Apply** backup and recovery procedures for production data
- **Build** resilient data management for e-commerce applications

---

## 🤔 The Data Persistence Challenge

### **The Container Data Problem**

```bash
# Without volumes - data is lost when container stops
docker-compose up -d database
# Add products, users, orders to database
docker-compose down
docker-compose up -d database
# All data is gone! 😱
```

### **Why Containers Lose Data**

```
Container Filesystem Layers:
├── Base Image Layer (read-only)
├── Additional Layers (read-only)
└── Container Layer (read-write, ephemeral)
    ├── Application logs
    ├── Temporary files
    ├── Database data ← LOST when container stops!
    └── User uploads ← LOST when container stops!
```

### **The Volume Solution**

```yaml
version: '3.8'
services:
  database:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data  # Persistent storage
    environment:
      POSTGRES_DB: ecommerce

volumes:
  postgres_data:  # Data survives container restarts!
```

---

## 🏗️ Volume Types and Use Cases

### **1. Named Volumes (Recommended for Production)**

```yaml
services:
  database:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
```

**Benefits:**
- ✅ **Managed by Docker** - automatic cleanup and management
- ✅ **Portable** - can be moved between hosts
- ✅ **Performance optimized** - Docker optimizes storage
- ✅ **Backup friendly** - easy to backup and restore

### **2. Bind Mounts (Development and Configuration)**

```yaml
services:
  backend:
    build: ./backend
    volumes:
      # Source code for development
      - ./backend:/app
      - /app/node_modules  # Anonymous volume for node_modules
  
  nginx:
    image: nginx:alpine
    volumes:
      # Configuration files
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
```

**Use Cases:**
- 📁 **Development** - live code reloading
- ⚙️ **Configuration** - external config files
- 📋 **Logs** - access logs from host
- 🔧 **Tools** - share tools between host and container

### **3. Anonymous Volumes (Temporary Data)**

```yaml
services:
  app:
    image: node:16
    volumes:
      - /app/node_modules  # Anonymous volume
      - /tmp               # Temporary files
```

---

## 🛒 E-Commerce Data Management Strategy

### **E-Commerce Data Classification**

```
E-Commerce Data Types:
├── Critical Data (Must Persist)
│   ├── Customer accounts and profiles
│   ├── Product catalog and inventory
│   ├── Order history and transactions
│   ├── Payment information (encrypted)
│   └── User preferences and settings
├── Important Data (Should Persist)
│   ├── Application logs
│   ├── Analytics data
│   ├── Search indexes
│   └── Cache data (for performance)
├── Temporary Data (Can Be Lost)
│   ├── Session data
│   ├── Temporary uploads
│   └── Processing queues
└── Configuration Data (External)
    ├── Application settings
    ├── SSL certificates
    └── Environment configurations
```

### **Complete E-Commerce Volume Strategy**

```yaml
version: '3.8'

services:
  # PostgreSQL Database - Critical Data
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      # Critical: Database data (must persist)
      - postgres_data:/var/lib/postgresql/data
      
      # Configuration: Database initialization
      - ./database/init:/docker-entrypoint-initdb.d:ro
      
      # Configuration: Custom PostgreSQL settings
      - ./database/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    
    # Backup configuration
    labels:
      backup.enable: "true"
      backup.schedule: "0 2 * * *"  # Daily at 2 AM

  # Redis Cache - Important Data
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      # Important: Cache data (improves performance if persisted)
      - redis_data:/data
      
      # Configuration: Redis settings
      - ./redis/redis.conf:/usr/local/etc/redis/redis.conf:ro

  # Backend API - Logs and Uploads
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
    volumes:
      # Critical: User uploads (product images, documents)
      - uploads:/app/uploads
      
      # Important: Application logs
      - logs:/app/logs
      
      # Development: Source code (remove in production)
      - ./backend:/app:cached
      - /app/node_modules
    
    depends_on:
      - database
      - redis

  # Frontend - Static Assets
  frontend:
    build: ./frontend
    volumes:
      # Important: Built assets (for nginx serving)
      - frontend_build:/app/build
      
      # Development: Source code (remove in production)
      - ./frontend:/app:cached
      - /app/node_modules

  # Nginx - Configuration and Logs
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      # Configuration: Nginx settings
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      
      # Configuration: SSL certificates
      - ./nginx/ssl:/etc/nginx/ssl:ro
      
      # Static content: Frontend build
      - frontend_build:/var/www/html:ro
      
      # Static content: User uploads
      - uploads:/var/www/uploads:ro
      
      # Important: Access and error logs
      - nginx_logs:/var/log/nginx
    
    depends_on:
      - frontend
      - backend

  # Backup Service
  backup:
    image: postgres:13-alpine
    environment:
      PGPASSWORD: ${DB_PASSWORD}
    volumes:
      # Backup storage
      - backup_data:/backups
      
      # Access to database data for backup
      - postgres_data:/source/postgres:ro
      - uploads:/source/uploads:ro
    
    command: |
      sh -c '
        while true; do
          echo "Creating backup at $$(date)"
          pg_dump -h database -U admin ecommerce > /backups/ecommerce_$$(date +%Y%m%d_%H%M%S).sql
          tar -czf /backups/uploads_$$(date +%Y%m%d_%H%M%S).tar.gz -C /source uploads/
          find /backups -name "*.sql" -mtime +7 -delete
          find /backups -name "*.tar.gz" -mtime +7 -delete
          sleep 86400  # Daily backup
        done
      '

# Volume Definitions
volumes:
  # Critical data volumes
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/postgres
  
  uploads:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/uploads
  
  # Important data volumes
  redis_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/redis
  
  logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/logs
  
  nginx_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DATA_PATH:-./data}/nginx-logs
  
  frontend_build:
    driver: local
  
  # Backup storage
  backup_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${BACKUP_PATH:-./backups}
```

---

## 🔧 Advanced Volume Configuration

### **1. Volume Drivers and Options**

#### **Local Driver with Custom Options**
```yaml
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/docker/postgres
  
  nfs_storage:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/nfs/share"
```

#### **External Volumes**
```yaml
volumes:
  shared_data:
    external: true
    name: company_shared_volume

services:
  app:
    image: my-app
    volumes:
      - shared_data:/app/shared
```

### **2. Volume Performance Optimization**

#### **Volume Mount Options**
```yaml
services:
  database:
    image: postgres:13
    volumes:
      # Optimized for database performance
      - type: volume
        source: postgres_data
        target: /var/lib/postgresql/data
        volume:
          nocopy: true  # Don't copy existing data
  
  backend:
    build: ./backend
    volumes:
      # Optimized for development
      - type: bind
        source: ./backend
        target: /app
        bind:
          propagation: cached  # macOS/Windows optimization
      
      # Read-only configuration
      - type: bind
        source: ./config
        target: /app/config
        read_only: true
```

### **3. Backup and Recovery Strategies**

#### **Automated Backup Service**
```yaml
services:
  backup:
    image: alpine:latest
    volumes:
      - postgres_data:/data/postgres:ro
      - uploads:/data/uploads:ro
      - backup_storage:/backups
    environment:
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET: ${BACKUP_S3_BUCKET}
    command: |
      sh -c '
        apk add --no-cache aws-cli postgresql-client
        while true; do
          DATE=$$(date +%Y%m%d_%H%M%S)
          
          # Database backup
          pg_dump -h database -U admin ecommerce > /backups/db_$$DATE.sql
          
          # File backup
          tar -czf /backups/uploads_$$DATE.tar.gz -C /data uploads/
          
          # Upload to S3
          aws s3 cp /backups/db_$$DATE.sql s3://$$S3_BUCKET/database/
          aws s3 cp /backups/uploads_$$DATE.tar.gz s3://$$S3_BUCKET/uploads/
          
          # Cleanup local backups older than 3 days
          find /backups -name "*.sql" -mtime +3 -delete
          find /backups -name "*.tar.gz" -mtime +3 -delete
          
          sleep 21600  # Every 6 hours
        done
      '
```

#### **Recovery Procedures**
```bash
# Database recovery
docker-compose exec database psql -U admin -d ecommerce < backup_20231201_120000.sql

# File recovery
docker-compose down
tar -xzf uploads_20231201_120000.tar.gz -C ./data/
docker-compose up -d
```

---

## 🧪 Hands-On Practice: Data Management Implementation

### **Exercise 1: Complete Data Persistence Setup**

Create comprehensive data management:

```bash
# Create data directories
mkdir -p data/{postgres,redis,uploads,logs,nginx-logs}
mkdir -p backups
mkdir -p config/{database,redis,nginx}

# Set proper permissions
chmod 700 data/postgres
chmod 755 data/uploads
chmod 755 data/logs
```

Create environment file:
```bash
# .env
DB_PASSWORD=secure_database_password_123
REDIS_PASSWORD=secure_redis_password_123
DATA_PATH=./data
BACKUP_PATH=./backups
```

### **Exercise 2: Backup and Recovery Testing**

```bash
# Test backup creation
docker-compose exec backup sh -c "
  pg_dump -h database -U admin ecommerce > /backups/test_backup.sql
  tar -czf /backups/test_uploads.tar.gz -C /source uploads/
"

# Verify backups
ls -la backups/

# Test recovery
docker-compose down
docker volume rm ecommerce_postgres_data
docker-compose up -d database
# Wait for database to be ready
docker-compose exec database psql -U admin -d ecommerce < backups/test_backup.sql
```

### **Exercise 3: Performance Monitoring**

```bash
# Monitor volume usage
docker system df -v

# Check volume performance
docker-compose exec database iostat -x 1

# Monitor disk space
docker-compose exec backend df -h /app/uploads
docker-compose exec database df -h /var/lib/postgresql/data
```

---

## 📊 Volume Management Best Practices

### **1. Development vs Production**

#### **Development Configuration**
```yaml
# docker-compose.override.yml (development)
version: '3.8'
services:
  backend:
    volumes:
      - ./backend:/app:cached  # Live code reloading
      - /app/node_modules      # Preserve node_modules
  
  database:
    ports:
      - "5432:5432"           # Expose for debugging
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/dev-init:/docker-entrypoint-initdb.d
```

#### **Production Configuration**
```yaml
# docker-compose.prod.yml (production)
version: '3.8'
services:
  backend:
    volumes:
      - uploads:/app/uploads   # Only persistent data
      - logs:/app/logs         # Application logs
    # No source code mounting
  
  database:
    # No port exposure
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/prod-init:/docker-entrypoint-initdb.d:ro
```

### **2. Security Considerations**

```yaml
services:
  database:
    volumes:
      # Read-only configuration
      - ./database/postgresql.conf:/etc/postgresql/postgresql.conf:ro
      
      # Secure permissions for data
      - postgres_data:/var/lib/postgresql/data
    user: postgres  # Run as non-root user

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind,uid=999,gid=999  # PostgreSQL user/group
      device: /secure/postgres/data
```

### **3. Monitoring and Alerting**

```yaml
services:
  monitoring:
    image: prom/node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
      - postgres_data:/monitor/postgres:ro
      - uploads:/monitor/uploads:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
```

---

## ✅ Knowledge Check: Volume Mastery

### **Conceptual Understanding**
- [ ] Understands why containers need external storage
- [ ] Knows different volume types and their use cases
- [ ] Comprehends backup and recovery strategies
- [ ] Understands performance implications of volume choices
- [ ] Knows security considerations for data persistence

### **Practical Skills**
- [ ] Can configure appropriate volume types for different data
- [ ] Knows how to implement backup and recovery procedures
- [ ] Can optimize volume performance for production workloads
- [ ] Understands how to secure sensitive data in volumes
- [ ] Can monitor and troubleshoot volume issues

### **E-Commerce Application**
- [ ] Has implemented comprehensive data persistence strategy
- [ ] Created backup and recovery procedures for all critical data
- [ ] Configured appropriate volume types for different data types
- [ ] Set up monitoring for storage usage and performance
- [ ] Implemented security measures for sensitive data

---

## 🚀 Next Steps: Multi-Container Applications

### **What You've Mastered**
- ✅ **Volume concepts** and data persistence strategies
- ✅ **Volume types** and their appropriate use cases
- ✅ **Backup and recovery** procedures for production data
- ✅ **Performance optimization** for storage-intensive applications
- ✅ **Security considerations** for data management

### **Coming Next: Multi-Container Applications**
In **06-Multi-Container-Applications.md**, you'll learn:
- **Application architecture patterns** for microservices
- **Service coordination** and dependency management
- **Inter-service communication** strategies
- **Complete e-commerce stack** orchestration

**Continue to Multi-Container Applications when you're comfortable with volume management and have implemented comprehensive data persistence for your e-commerce platform.**
