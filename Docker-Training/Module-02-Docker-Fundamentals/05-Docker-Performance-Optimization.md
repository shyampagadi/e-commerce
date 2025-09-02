# ⚡ Docker Performance Optimization: Complete Expert Guide

## 🎯 Learning Objectives
- Master Docker resource management and limits
- Optimize container performance and efficiency
- Learn monitoring and profiling techniques
- Implement production-ready performance tuning

---

## 📊 Resource Management and Limits

### Memory Management

#### Memory Limit Options
```bash
# Basic memory limit
docker run -m 512m nginx:alpine

# Memory with swap limit
docker run -m 512m --memory-swap 1g nginx:alpine

# Memory reservation (soft limit)
docker run -m 1g --memory-reservation 512m nginx:alpine

# Disable OOM killer
docker run -m 512m --oom-kill-disable nginx:alpine
```

#### Memory Limit Examples
```bash
# Test memory limits
docker run -it --rm -m 100m alpine:3.17 sh

# Inside container - test memory allocation
dd if=/dev/zero of=/tmp/memory_test bs=1M count=150
# This should fail due to 100MB limit
```

**Expected Output:**
```
dd: error writing '/tmp/memory_test': No space left on device
51+0 records in
50+0 records out
52428800 bytes (52 MB, 50 MiB) copied, 0.123456 s, 425 MB/s
```

#### Memory Monitoring
```bash
# Monitor memory usage
docker stats --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Memory usage inside container
docker exec container_name cat /proc/meminfo
docker exec container_name free -h

# Memory cgroup information
docker exec container_name cat /sys/fs/cgroup/memory/memory.limit_in_bytes
docker exec container_name cat /sys/fs/cgroup/memory/memory.usage_in_bytes
```

### CPU Management

#### CPU Limit Options
```bash
# Limit to 1.5 CPUs
docker run --cpus="1.5" nginx:alpine

# CPU shares (relative weight)
docker run --cpu-shares=512 nginx:alpine  # Half of default 1024

# Specific CPU cores
docker run --cpuset-cpus="0,1" nginx:alpine  # Use only cores 0 and 1
docker run --cpuset-cpus="0-2" nginx:alpine  # Use cores 0, 1, and 2

# CPU quota and period
docker run --cpu-quota=50000 --cpu-period=100000 nginx:alpine  # 50% of one CPU
```

#### CPU Performance Testing
```bash
# Create CPU stress test
docker run -it --rm --cpus="1.0" alpine:3.17 sh -c "
while true; do
    echo 'CPU stress test' > /dev/null
done
" &

# Monitor CPU usage
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Kill stress test
kill %1
```

### I/O Performance Management

#### Block I/O Limits
```bash
# Limit read/write IOPS
docker run --device-read-iops /dev/sda:1000 --device-write-iops /dev/sda:1000 alpine:3.17

# Limit read/write bandwidth
docker run --device-read-bps /dev/sda:10mb --device-write-bps /dev/sda:10mb alpine:3.17

# Blkio weight (relative I/O priority)
docker run --blkio-weight 500 alpine:3.17  # Half of default 1000
```

#### I/O Performance Testing
```bash
# Test write performance
docker run --rm -v $(pwd):/data alpine:3.17 sh -c "
time dd if=/dev/zero of=/data/test_file bs=1M count=100
"

# Test with I/O limits
docker run --rm -v $(pwd):/data --device-write-bps /dev/sda:10mb alpine:3.17 sh -c "
time dd if=/dev/zero of=/data/test_file_limited bs=1M count=100
"

# Compare results
ls -lh test_file*
```

---

## 🔧 Container Optimization Techniques

### Image Size Optimization

#### Multi-Stage Build Example
```dockerfile
# Build stage - full development environment
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage - minimal runtime
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Size Comparison:**
```bash
# Build both versions
docker build --target builder -t app:dev .
docker build --target production -t app:prod .

# Compare sizes
docker images | grep app
```

**Expected Output:**
```
app          prod      abc123def456   2 minutes ago   23.4MB
app          dev       def456ghi789   3 minutes ago   1.2GB
```

#### Alpine vs Standard Base Images
```dockerfile
# Standard Ubuntu image
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3 python3-pip
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .
CMD ["python3", "app.py"]

# Alpine equivalent
FROM python:3.11-alpine
RUN apk add --no-cache gcc musl-dev
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

### Build Performance Optimization

#### BuildKit Features
```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with BuildKit cache
docker build --cache-from myapp:latest -t myapp:new .

# Build with inline cache
docker build --cache-from myapp:latest --cache-to type=inline -t myapp:new .

# Parallel builds
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -t myapp .
```

#### .dockerignore Optimization
```bash
# Create comprehensive .dockerignore
cat > .dockerignore << 'EOF'
# Version control
.git
.gitignore
.gitattributes

# Dependencies
node_modules
__pycache__
*.pyc
.pytest_cache
.coverage

# IDE files
.vscode
.idea
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Documentation
README.md
docs/
*.md

# Tests
tests/
test/
spec/

# Build artifacts
dist/
build/
target/
EOF
```

### Runtime Performance Optimization

#### Container Startup Optimization
```dockerfile
# Optimize container startup
FROM node:16-alpine

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Pre-compile/optimize application
RUN npm run build

# Use exec form for faster startup
CMD ["node", "server.js"]
```

#### Resource Allocation Best Practices
```bash
# Web application with optimized resources
docker run -d \
  --name web-app \
  --memory=512m \
  --memory-reservation=256m \
  --cpus="1.0" \
  --restart=unless-stopped \
  -p 3000:3000 \
  myapp:latest

# Database with dedicated resources
docker run -d \
  --name postgres-db \
  --memory=2g \
  --cpus="2.0" \
  --shm-size=256m \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:13
```

---

## 📈 Performance Monitoring and Profiling

### Real-time Performance Monitoring
```bash
# Monitor all containers
docker stats

# Monitor specific containers
docker stats web-app postgres-db redis-cache

# Custom format monitoring
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
```

### Performance Monitoring Script
```bash
#!/bin/bash
# docker-performance-monitor.sh

INTERVAL=${1:-5}
DURATION=${2:-300}  # 5 minutes default
OUTPUT_FILE="performance-$(date +%Y%m%d_%H%M%S).csv"

echo "container,timestamp,cpu_percent,memory_usage,memory_limit,memory_percent,network_rx,network_tx,block_read,block_write" > "$OUTPUT_FILE"

END_TIME=$(($(date +%s) + DURATION))

while [ $(date +%s) -lt $END_TIME ]; do
    docker stats --no-stream --format "{{.Name}},$(date +%s),{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}" | \
    sed 's/%//g' | sed 's/MiB\|GiB\|MB\|GB//g' >> "$OUTPUT_FILE"
    
    sleep $INTERVAL
done

echo "Performance monitoring completed. Data saved to: $OUTPUT_FILE"

# Generate performance report
python3 << EOF
import pandas as pd
import matplotlib.pyplot as plt

# Read performance data
df = pd.read_csv('$OUTPUT_FILE')

# Generate summary statistics
print("=== Performance Summary ===")
print(f"Monitoring Duration: ${DURATION} seconds")
print(f"Data Points: {len(df)}")
print(f"Average CPU Usage: {df['cpu_percent'].mean():.2f}%")
print(f"Peak CPU Usage: {df['cpu_percent'].max():.2f}%")
print(f"Average Memory Usage: {df['memory_percent'].mean():.2f}%")
print(f"Peak Memory Usage: {df['memory_percent'].max():.2f}%")
EOF
```

### Container Profiling
```bash
# Profile container resource usage
docker run -d --name profile-test \
  --memory=1g \
  --cpus="2.0" \
  nginx:alpine

# Generate load for profiling
for i in {1..1000}; do
    curl -s http://localhost > /dev/null &
done

# Monitor during load
docker stats profile-test --no-stream

# Check detailed process information
docker exec profile-test ps aux
docker exec profile-test cat /proc/loadavg
docker exec profile-test cat /proc/meminfo | head -10
```

---

## 🚀 Next Steps

You now have comprehensive Docker performance optimization knowledge:

- ✅ **Resource Management**: Memory, CPU, and I/O limits with all options
- ✅ **Container Optimization**: Image size reduction and startup optimization
- ✅ **Build Performance**: BuildKit features and caching strategies
- ✅ **Runtime Performance**: Resource allocation and monitoring
- ✅ **Performance Monitoring**: Real-time monitoring and profiling tools
- ✅ **Production Tuning**: Best practices for production deployments

**Ready for Part 6: Docker Troubleshooting and Debugging** where you'll master advanced debugging techniques and problem resolution!
