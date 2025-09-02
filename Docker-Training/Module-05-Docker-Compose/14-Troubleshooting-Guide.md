# Docker Compose Troubleshooting Guide

## Table of Contents
1. [Common Issues and Solutions](#common-issues-and-solutions)
2. [Debugging Techniques](#debugging-techniques)
3. [Performance Issues](#performance-issues)
4. [Network Problems](#network-problems)
5. [Volume Issues](#volume-issues)
6. [Service Dependencies](#service-dependencies)

## Common Issues and Solutions

### 1. Service Startup Failures

#### Issue: Container Exits Immediately
```bash
# Symptoms
docker-compose ps
# NAME                COMMAND             SERVICE             STATUS              PORTS
# myapp_web_1        "nginx -g 'daemon..."   web                 Exited (1)
```

**Diagnosis:**
```bash
# Check container logs
docker-compose logs web

# Check exit code
docker-compose ps web
```

**Common Solutions:**
```yaml
# Fix 1: Correct command syntax
services:
  web:
    image: nginx:alpine
    # ❌ Wrong
    command: nginx -g daemon off;
    # ✅ Correct
    command: ["nginx", "-g", "daemon off;"]

# Fix 2: Proper working directory
services:
  app:
    build: .
    working_dir: /app
    command: ["npm", "start"]

# Fix 3: Environment variables
services:
  app:
    image: node:alpine
    environment:
      - NODE_ENV=production
    command: ["node", "server.js"]
```

#### Issue: Permission Denied Errors
```bash
# Error message
docker-compose logs app
# Error: EACCES: permission denied, open '/app/data/file.txt'
```

**Solutions:**
```yaml
services:
  app:
    image: myapp:latest
    # Fix 1: Set proper user
    user: "1000:1000"
    
    # Fix 2: Fix volume permissions
    volumes:
      - ./data:/app/data
    # Run: chmod -R 755 ./data

  # Fix 3: Init container for permissions
  permission-fix:
    image: alpine:latest
    volumes:
      - ./data:/data
    command: ["chown", "-R", "1000:1000", "/data"]
    restart: "no"
```

### 2. Configuration Errors

#### Issue: Invalid YAML Syntax
```bash
# Error message
ERROR: yaml.scanner.ScannerError: mapping values are not allowed here
```

**Diagnosis and Fix:**
```bash
# Validate YAML syntax
docker-compose config

# Common YAML issues:
# ❌ Wrong indentation
services:
web:
  image: nginx

# ✅ Correct indentation (2 spaces)
services:
  web:
    image: nginx

# ❌ Missing quotes for special characters
environment:
  - PASSWORD=p@ssw0rd!

# ✅ Quoted special characters
environment:
  - PASSWORD="p@ssw0rd!"
```

#### Issue: Environment Variable Substitution
```bash
# Error: WARNING: The PASSWORD variable is not set
```

**Solutions:**
```bash
# Fix 1: Create .env file
echo "PASSWORD=secret123" > .env

# Fix 2: Provide default values
services:
  app:
    environment:
      - PASSWORD=${PASSWORD:-defaultpass}

# Fix 3: Check variable substitution
docker-compose config
```

### 3. Service Communication Issues

#### Issue: Services Cannot Connect
```bash
# Error in logs
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Diagnosis:**
```bash
# Check network connectivity
docker-compose exec web ping database
docker-compose exec web nslookup database
docker-compose exec web telnet database 5432
```

**Solutions:**
```yaml
# Fix 1: Use service names, not localhost
services:
  web:
    environment:
      # ❌ Wrong
      - DATABASE_URL=postgresql://user:pass@localhost:5432/db
      # ✅ Correct
      - DATABASE_URL=postgresql://user:pass@database:5432/db

# Fix 2: Ensure services are on same network
services:
  web:
    networks:
      - app-network
  database:
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

## Debugging Techniques

### 1. Comprehensive Logging
```yaml
services:
  app:
    image: myapp:latest
    # Enable debug logging
    environment:
      - DEBUG=*
      - LOG_LEVEL=debug
    # Custom logging driver
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service,environment"
    labels:
      - "service=app"
      - "environment=development"
```

### 2. Interactive Debugging
```bash
# Access running container
docker-compose exec app sh

# Run one-off debugging container
docker-compose run --rm app sh

# Debug with different entrypoint
docker-compose run --rm --entrypoint sh app

# Debug network issues
docker-compose run --rm app ping database
docker-compose run --rm app nslookup database
docker-compose run --rm app curl -v http://api:3000/health
```

### 3. Service Health Monitoring
```yaml
services:
  app:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    # Detailed health check
    healthcheck:
      test: >
        sh -c "
          curl -f http://localhost:3000/health &&
          nc -z database 5432 &&
          redis-cli -h redis ping | grep -q PONG
        "
```

### 4. Debug Compose Configuration
```bash
# Validate and show resolved configuration
docker-compose config

# Show configuration with environment variables resolved
docker-compose config --resolve-env-vars

# Validate specific file
docker-compose -f docker-compose.prod.yml config

# Show services only
docker-compose config --services

# Show volumes only
docker-compose config --volumes
```

## Performance Issues

### 1. Slow Container Startup
```yaml
# Diagnosis service
services:
  startup-monitor:
    image: alpine:latest
    command: >
      sh -c "
        echo 'Monitoring startup times...'
        while true; do
          echo '=== Container Status ==='
          docker-compose ps
          echo '=== Resource Usage ==='
          docker stats --no-stream
          sleep 10
        done
      "
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

**Optimization Strategies:**
```yaml
services:
  app:
    image: myapp:latest
    # Optimize resource allocation
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    
    # Optimize health checks
    healthcheck:
      interval: 10s  # Faster detection
      timeout: 5s    # Shorter timeout
      start_period: 30s  # Reasonable startup time
    
    # Optimize dependencies
    depends_on:
      database:
        condition: service_healthy  # Wait for readiness
```

### 2. High Memory Usage
```bash
# Monitor memory usage
docker stats

# Check container memory limits
docker-compose exec app cat /sys/fs/cgroup/memory/memory.limit_in_bytes

# Analyze memory usage inside container
docker-compose exec app free -h
docker-compose exec app ps aux --sort=-%mem
```

**Memory Optimization:**
```yaml
services:
  app:
    image: myapp:latest
    # Set memory limits
    mem_limit: 512m
    mem_reservation: 256m
    
    # Optimize application
    environment:
      - NODE_OPTIONS="--max-old-space-size=400"
      - JAVA_OPTS="-Xms256m -Xmx400m"
    
    # Use tmpfs for temporary files
    tmpfs:
      - /tmp:size=100m,noexec
```

## Network Problems

### 1. Port Conflicts
```bash
# Error message
ERROR: for web  Cannot start service web: driver failed programming external connectivity
```

**Diagnosis and Solutions:**
```bash
# Check port usage
netstat -tulpn | grep :80
lsof -i :80

# Solutions:
# 1. Use different host port
services:
  web:
    ports:
      - "8080:80"  # Use 8080 instead of 80

# 2. Use random port
services:
  web:
    ports:
      - "80"  # Docker assigns random host port

# 3. Bind to specific interface
services:
  web:
    ports:
      - "127.0.0.1:80:80"  # Localhost only
```

### 2. DNS Resolution Issues
```bash
# Test DNS resolution
docker-compose exec app nslookup database
docker-compose exec app dig database

# Check network configuration
docker network ls
docker network inspect myproject_default
```

**Solutions:**
```yaml
services:
  app:
    # Add custom DNS
    dns:
      - 8.8.8.8
      - 8.8.4.4
    
    # Add host entries
    extra_hosts:
      - "api.internal:192.168.1.100"
    
    # Use network aliases
    networks:
      app-network:
        aliases:
          - api-server
          - backend
```

### 3. Network Isolation Issues
```yaml
# Debug network connectivity
services:
  network-debug:
    image: alpine:latest
    command: >
      sh -c "
        apk add --no-cache curl netcat-openbsd &&
        echo 'Testing network connectivity...' &&
        ping -c 3 web &&
        nc -zv database 5432 &&
        curl -I http://web:80
      "
    networks:
      - app-network
    depends_on:
      - web
      - database
```

## Volume Issues

### 1. Volume Mount Problems
```bash
# Error: bind source path does not exist
ERROR: for app  Cannot start service app: invalid mount config for type "bind"
```

**Solutions:**
```bash
# Fix 1: Create directory first
mkdir -p ./data ./logs ./config

# Fix 2: Use absolute paths
services:
  app:
    volumes:
      - /absolute/path/to/data:/app/data

# Fix 3: Use named volumes
services:
  app:
    volumes:
      - app_data:/app/data

volumes:
  app_data:
```

### 2. Permission Issues with Volumes
```yaml
# Debug volume permissions
services:
  volume-debug:
    image: alpine:latest
    volumes:
      - app_data:/debug/app_data
      - ./logs:/debug/logs
    command: >
      sh -c "
        echo 'Volume permissions:'
        ls -la /debug/
        echo 'App data:'
        ls -la /debug/app_data/
        echo 'Logs:'
        ls -la /debug/logs/
      "

volumes:
  app_data:
```

### 3. Volume Performance Issues
```yaml
services:
  app:
    volumes:
      # Optimize for different platforms
      - ./src:/app/src:cached     # macOS optimization
      - ./data:/app/data:delegated # macOS optimization
      
      # Use tmpfs for temporary files
      - type: tmpfs
        target: /app/tmp
        tmpfs:
          size: 1G
```

## Service Dependencies

### 1. Startup Order Issues
```yaml
# Problem: App starts before database is ready
services:
  app:
    depends_on:
      - database  # Only waits for container start, not readiness

# Solution: Use health checks
services:
  app:
    depends_on:
      database:
        condition: service_healthy
  
  database:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 30s
      timeout: 5s
      retries: 5
```

### 2. Circular Dependencies
```yaml
# Problem: Circular dependency
services:
  web:
    depends_on:
      - app
  app:
    depends_on:
      - web  # Circular!

# Solution: Remove unnecessary dependencies
services:
  web:
    # Remove depends_on, use health checks instead
  app:
    depends_on:
      - database
```

## Troubleshooting Tools and Scripts

### 1. Health Check Script
```bash
#!/bin/bash
# scripts/health-check.sh

echo "=== Docker Compose Health Check ==="

# Check if services are running
echo "Checking service status..."
docker-compose ps

# Check service health
echo "Checking service health..."
for service in $(docker-compose config --services); do
    echo "Checking $service..."
    if docker-compose exec -T $service sh -c 'exit 0' 2>/dev/null; then
        echo "✓ $service is responsive"
    else
        echo "✗ $service is not responsive"
    fi
done

# Check network connectivity
echo "Checking network connectivity..."
docker-compose exec -T web ping -c 1 database >/dev/null 2>&1 && echo "✓ Network connectivity OK" || echo "✗ Network connectivity failed"

# Check volumes
echo "Checking volumes..."
docker volume ls | grep $(basename $(pwd)) && echo "✓ Volumes exist" || echo "✗ Volume issues"

echo "Health check complete!"
```

### 2. Debug Information Script
```bash
#!/bin/bash
# scripts/debug-info.sh

echo "=== Docker Compose Debug Information ==="

echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker-compose --version

echo "Compose configuration:"
docker-compose config

echo "Running containers:"
docker-compose ps

echo "Container logs (last 50 lines):"
docker-compose logs --tail=50

echo "Network information:"
docker network ls
docker-compose exec web ip addr show

echo "Volume information:"
docker volume ls
docker-compose exec app df -h

echo "Resource usage:"
docker stats --no-stream

echo "Debug information collected!"
```

### 3. Performance Monitoring
```yaml
services:
  performance-monitor:
    image: alpine:latest
    command: >
      sh -c "
        while true; do
          echo '=== Performance Report ==='
          echo 'Memory usage:'
          free -h
          echo 'Disk usage:'
          df -h
          echo 'Network connections:'
          netstat -an | grep ESTABLISHED | wc -l
          echo 'Load average:'
          uptime
          sleep 60
        done
      "
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
```

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common Docker Compose issues, with practical debugging techniques and monitoring tools.
