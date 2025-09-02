# 🚀 Docker Performance Engineering & Optimization

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** container performance fundamentals and bottlenecks
- **Master** resource optimization techniques for CPU, memory, and I/O
- **Implement** advanced performance monitoring and profiling
- **Apply** enterprise-grade optimization strategies to e-commerce applications
- **Achieve** production-ready performance tuning skills

## 🎯 Real-World Context
Performance engineering is critical for e-commerce success. A 100ms delay can reduce conversions by 1%, while poor container performance can cost millions in lost revenue. This module teaches you to optimize containers for maximum efficiency and user experience.

---

## 📚 Part 1: Performance Engineering Fundamentals

### Understanding Container Performance

Container performance differs from traditional application performance due to:

**1. Resource Isolation**
- Containers share the host kernel but have isolated resources
- Performance depends on cgroup limits and kernel scheduling
- Resource contention affects multiple containers simultaneously

**2. Layered Architecture Impact**
- Image layers affect startup time and memory usage
- Union filesystem overhead impacts I/O performance
- Network namespace adds latency overhead

**3. Runtime Overhead**
- Container runtime (Docker, containerd) adds processing overhead
- System calls require additional kernel transitions
- Resource monitoring and logging consume CPU cycles

### Performance Metrics That Matter

**Application-Level Metrics:**
- Response time (P50, P95, P99 percentiles)
- Throughput (requests per second)
- Error rates and availability
- Resource utilization efficiency

**Container-Level Metrics:**
- Startup time and initialization duration
- Memory usage patterns and garbage collection
- CPU utilization and context switching
- I/O operations and disk usage

**System-Level Metrics:**
- Host resource utilization
- Network bandwidth and latency
- Storage IOPS and throughput
- Kernel-level performance counters

---

## 🔧 Part 2: Resource Optimization Strategies

### CPU Performance Optimization

**Understanding CPU Limits:**
```yaml
# docker-compose.yml - CPU optimization
version: '3.8'
services:
  ecommerce-api:
    image: ecommerce/api:latest
    deploy:
      resources:
        limits:
          cpus: '2.0'      # Maximum CPU cores
        reservations:
          cpus: '0.5'      # Guaranteed CPU allocation
    cpuset: '0,1'          # Pin to specific CPU cores
```

**CPU Affinity and NUMA Optimization:**
```bash
# Pin container to specific CPU cores
docker run -d \
  --cpuset-cpus="0,1" \
  --cpu-shares=1024 \
  --name ecommerce-api \
  ecommerce/api:latest

# Check CPU affinity
docker exec ecommerce-api cat /proc/self/status | grep Cpus_allowed_list
```

### Memory Performance Optimization

**Memory Limits and Reservations:**
```yaml
services:
  ecommerce-database:
    image: postgres:15
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
    environment:
      # Optimize PostgreSQL memory settings
      POSTGRES_SHARED_BUFFERS: 1GB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 3GB
```

**Memory Usage Monitoring:**
```bash
# Monitor memory usage in real-time
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Detailed memory breakdown
docker exec ecommerce-api cat /proc/meminfo
docker exec ecommerce-api cat /sys/fs/cgroup/memory/memory.usage_in_bytes
```

### I/O Performance Optimization

**Storage Driver Selection:**
```bash
# Check current storage driver
docker info | grep "Storage Driver"

# Optimize for different workloads
# overlay2: Best for general use
# devicemapper: Better for high I/O workloads
# btrfs: Advanced features but higher overhead
```

**Volume Performance Tuning:**
```yaml
services:
  ecommerce-database:
    volumes:
      # Use bind mounts for better performance
      - type: bind
        source: /opt/postgres/data
        target: /var/lib/postgresql/data
        bind:
          propagation: rprivate
      # Optimize tmpfs for temporary data
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 1G
          mode: 1777
```

---

## 🏗️ Part 3: E-Commerce Performance Implementation

### High-Performance E-Commerce Stack

Let's optimize our e-commerce application for maximum performance:

**1. Optimized Application Configuration:**
```yaml
# docker-compose.performance.yml
version: '3.8'

services:
  # Frontend with performance optimizations
  ecommerce-frontend:
    image: ecommerce/frontend:optimized
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    environment:
      NODE_ENV: production
      NODE_OPTIONS: '--max-old-space-size=400'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  # API with CPU optimization
  ecommerce-api:
    image: ecommerce/api:optimized
    deploy:
      replicas: 4
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    cpuset: '0-3'  # Use first 4 CPU cores
    environment:
      NODE_ENV: production
      UV_THREADPOOL_SIZE: 8
      NODE_OPTIONS: '--max-old-space-size=800'

  # Database with memory optimization
  ecommerce-database:
    image: postgres:15-alpine
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '1.0'
          memory: 4G
    environment:
      POSTGRES_SHARED_BUFFERS: 2GB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 6GB
      POSTGRES_WORK_MEM: 64MB
      POSTGRES_MAINTENANCE_WORK_MEM: 512MB
    volumes:
      - type: bind
        source: /opt/postgres/data
        target: /var/lib/postgresql/data
```

**2. Performance Monitoring Setup:**
```yaml
  # Performance monitoring stack
  prometheus:
    image: prom/prometheus:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/etc/prometheus/console_libraries'

  grafana:
    image: grafana/grafana:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    environment:
      GF_PERFORMANCE_CHECK_FOR_UPDATES: false
      GF_ANALYTICS_REPORTING_ENABLED: false
```

### Application-Level Optimizations

**Node.js API Optimization:**
```javascript
// server.js - Optimized Express server
const express = require('express');
const cluster = require('cluster');
const os = require('os');

if (cluster.isMaster) {
  // Fork workers equal to CPU cores
  const numCPUs = os.cpus().length;
  console.log(`Master ${process.pid} is running`);
  
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork();
  });
} else {
  const app = express();
  
  // Performance middleware
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  
  // Connection pooling
  const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    max: 20,                    // Maximum connections
    idleTimeoutMillis: 30000,   // Close idle connections
    connectionTimeoutMillis: 2000,
  });
  
  console.log(`Worker ${process.pid} started`);
  app.listen(3000);
}
```

---

## 📊 Part 4: Advanced Performance Monitoring

### Container Performance Metrics

**Real-Time Performance Dashboard:**
```bash
#!/bin/bash
# performance-monitor.sh - Comprehensive performance monitoring

echo "=== E-Commerce Container Performance Monitor ==="
echo "Timestamp: $(date)"
echo

# Container resource usage
echo "📊 Container Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

echo
echo "🔍 Detailed Memory Analysis:"
for container in $(docker ps --format "{{.Names}}"); do
  echo "Container: $container"
  docker exec $container cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null | \
    awk '{printf "  Memory Usage: %.2f MB\n", $1/1024/1024}'
  docker exec $container cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null | \
    awk '{printf "  Memory Limit: %.2f MB\n", $1/1024/1024}'
  echo
done

echo "⚡ CPU Performance:"
for container in $(docker ps --format "{{.Names}}"); do
  echo "Container: $container"
  docker exec $container cat /sys/fs/cgroup/cpu/cpu.stat 2>/dev/null
  echo
done
```

### Performance Profiling Tools

**Application Profiling:**
```dockerfile
# Dockerfile.profiling - Performance profiling enabled
FROM node:18-alpine

# Install profiling tools
RUN apk add --no-cache \
    perf \
    strace \
    htop \
    iotop

# Enable Node.js profiling
ENV NODE_OPTIONS="--inspect=0.0.0.0:9229 --prof"

COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000 9229

CMD ["node", "server.js"]
```

---

## 🧪 Part 5: Hands-On Performance Labs

### Lab 1: Container Startup Optimization

**Objective:** Reduce container startup time by 50%

```bash
# Measure baseline startup time
time docker run --rm ecommerce/api:latest node -e "console.log('Ready')"

# Optimize with multi-stage build
cat > Dockerfile.optimized << 'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
CMD ["node", "server.js"]
EOF

# Build and test optimized image
docker build -f Dockerfile.optimized -t ecommerce/api:optimized .
time docker run --rm ecommerce/api:optimized node -e "console.log('Ready')"
```

### Lab 2: Memory Usage Optimization

**Objective:** Reduce memory footprint by 30%

```bash
# Monitor memory usage
docker run -d --name memory-test --memory=512m ecommerce/api:latest
docker stats memory-test --no-stream

# Apply memory optimizations
docker run -d --name memory-optimized \
  --memory=512m \
  --memory-swap=512m \
  --oom-kill-disable=false \
  -e NODE_OPTIONS="--max-old-space-size=400" \
  ecommerce/api:optimized

# Compare memory usage
docker stats memory-test memory-optimized --no-stream
```

### Lab 3: I/O Performance Tuning

**Objective:** Improve database I/O performance by 40%

```bash
# Test baseline I/O performance
docker run --rm -v postgres_data:/var/lib/postgresql/data \
  postgres:15 \
  pgbench -i -s 10 ecommerce

# Optimize with performance settings
docker run -d --name postgres-optimized \
  -v postgres_data_optimized:/var/lib/postgresql/data \
  -e POSTGRES_SHARED_BUFFERS=256MB \
  -e POSTGRES_EFFECTIVE_CACHE_SIZE=1GB \
  -e POSTGRES_CHECKPOINT_COMPLETION_TARGET=0.9 \
  postgres:15

# Run performance comparison
docker exec postgres-optimized pgbench -c 10 -j 2 -t 1000 ecommerce
```

---

## 🎯 Part 6: Production Performance Strategies

### Enterprise Performance Patterns

**1. Container Warm-Up Strategy:**
```yaml
# Implement container warm-up for faster scaling
services:
  ecommerce-api:
    image: ecommerce/api:latest
    deploy:
      replicas: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/warmup"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

**2. Resource Scaling Automation:**
```bash
#!/bin/bash
# auto-scale.sh - Automatic performance-based scaling

THRESHOLD_CPU=80
THRESHOLD_MEMORY=85
SERVICE_NAME="ecommerce_api"

while true; do
  CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" $SERVICE_NAME | sed 's/%//')
  MEM_USAGE=$(docker stats --no-stream --format "{{.MemPerc}}" $SERVICE_NAME | sed 's/%//')
  
  if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
    echo "High CPU usage detected: ${CPU_USAGE}%"
    docker service update --replicas-max-per-node 2 $SERVICE_NAME
  fi
  
  if (( $(echo "$MEM_USAGE > $THRESHOLD_MEMORY" | bc -l) )); then
    echo "High memory usage detected: ${MEM_USAGE}%"
    docker service update --limit-memory 2G $SERVICE_NAME
  fi
  
  sleep 30
done
```

### Performance Testing Framework

**Load Testing Configuration:**
```yaml
# docker-compose.loadtest.yml
version: '3.8'

services:
  loadtest:
    image: loadimpact/k6:latest
    volumes:
      - ./loadtests:/scripts
    command: run --vus 100 --duration 5m /scripts/ecommerce-test.js
    depends_on:
      - ecommerce-api

  performance-monitor:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring:/etc/prometheus
    ports:
      - "9090:9090"
```

---

## 📈 Part 7: Performance Assessment

### Performance Benchmarking

**Container Performance Scorecard:**
```bash
#!/bin/bash
# performance-scorecard.sh

echo "🏆 E-Commerce Container Performance Scorecard"
echo "=============================================="

# Startup time test
echo "⏱️  Startup Time Test:"
START_TIME=$(date +%s%N)
docker run --rm ecommerce/api:latest node -e "console.log('Ready')" > /dev/null
END_TIME=$(date +%s%N)
STARTUP_MS=$(( (END_TIME - START_TIME) / 1000000 ))
echo "   Startup Time: ${STARTUP_MS}ms"

# Memory efficiency test
echo "💾 Memory Efficiency Test:"
MEMORY_USAGE=$(docker stats --no-stream --format "{{.MemUsage}}" ecommerce_api | cut -d'/' -f1)
echo "   Memory Usage: $MEMORY_USAGE"

# CPU efficiency test
echo "⚡ CPU Efficiency Test:"
CPU_USAGE=$(docker stats --no-stream --format "{{.CPUPerc}}" ecommerce_api)
echo "   CPU Usage: $CPU_USAGE"

# Performance score calculation
if [ $STARTUP_MS -lt 1000 ]; then STARTUP_SCORE=100; elif [ $STARTUP_MS -lt 2000 ]; then STARTUP_SCORE=80; else STARTUP_SCORE=60; fi
echo "📊 Performance Score: $STARTUP_SCORE/100"
```

---

## 🎓 Module Summary

You've mastered Docker performance engineering by learning:

**Core Concepts:**
- Container performance fundamentals and bottlenecks
- Resource optimization strategies for CPU, memory, and I/O
- Performance monitoring and profiling techniques

**Practical Skills:**
- Implementing high-performance e-commerce container configurations
- Setting up comprehensive performance monitoring
- Optimizing application-level performance within containers

**Enterprise Techniques:**
- Advanced performance tuning strategies
- Automated scaling based on performance metrics
- Production-ready performance testing frameworks

**Next Steps:**
- Apply these optimizations to your e-commerce project
- Implement continuous performance monitoring
- Prepare for Module 8: Docker API & SDK Mastery

---

## 📚 Additional Resources

- [Docker Performance Best Practices](https://docs.docker.com/config/containers/resource_constraints/)
- [Container Performance Tuning Guide](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Linux Performance Tools](http://www.brendangregg.com/linuxperf.html)
- [Application Performance Monitoring](https://prometheus.io/docs/practices/instrumentation/)
    for i := 0; i < count; i++ {
        containerID := fmt.Sprintf("warm-%s-%d", image, i)
        
        // Create container in paused state
        container, err := so.createPausedContainer(image, containerID)
        if err != nil {
            return fmt.Errorf("failed to create warm container: %v", err)
        }
        
        so.warmContainers[containerID] = container
    }
    
    return nil
}

func (so *StartupOptimizer) createPausedContainer(image, containerID string) (*Container, error) {
    start := time.Now()
    
    // Use clone() with CLONE_NEWPID for faster namespace creation
    cmd := exec.Command("/proc/self/exe", "container-init", image)
    cmd.SysProcAttr = &syscall.SysProcAttr{
        Cloneflags: syscall.CLONE_NEWUTS | 
                   syscall.CLONE_NEWPID | 
                   syscall.CLONE_NEWNS |
                   syscall.CLONE_NEWNET |
                   syscall.CLONE_NEWIPC,
    }
    
    if err := cmd.Start(); err != nil {
        return nil, err
    }
    
    container := &Container{
        ID:      containerID,
        Image:   image,
        Pid:     cmd.Process.Pid,
        Ready:   false,
        Created: start,
    }
    
    // Pause the container immediately
    if err := syscall.Kill(cmd.Process.Pid, syscall.SIGSTOP); err != nil {
        return nil, err
    }
    
    log.Printf("Warm container %s created in %v", containerID, time.Since(start))
    return container, nil
}

// Ultra-fast container activation
func (so *StartupOptimizer) ActivateContainer(image string) (*Container, error) {
    start := time.Now()
    
    // Find available warm container
    for id, container := range so.warmContainers {
        if container.Image == image && !container.Ready {
            // Resume the paused container
            if err := syscall.Kill(container.Pid, syscall.SIGCONT); err != nil {
                return nil, err
            }
            
            container.Ready = true
            delete(so.warmContainers, id)
            
            log.Printf("Container activated in %v", time.Since(start))
            return container, nil
        }
    }
    
    // No warm container available, create new one
    return so.createFastContainer(image)
}

func (so *StartupOptimizer) createFastContainer(image string) (*Container, error) {
    start := time.Now()
    
    // Use vfork() for faster process creation
    pid, err := so.vforkContainer(image)
    if err != nil {
        return nil, err
    }
    
    container := &Container{
        ID:      fmt.Sprintf("fast-%d", pid),
        Image:   image,
        Pid:     pid,
        Ready:   true,
        Created: start,
    }
    
    log.Printf("Fast container created in %v", time.Since(start))
    return container, nil
}

func (so *StartupOptimizer) vforkContainer(image string) (int, error) {
    // Use vfork for copy-on-write optimization
    pid, _, errno := syscall.RawSyscall(syscall.SYS_VFORK, 0, 0, 0)
    
    if errno != 0 {
        return 0, errno
    }
    
    if pid == 0 {
        // Child process - exec the container
        so.execContainer(image)
        os.Exit(1) // Should never reach here
    }
    
    return int(pid), nil
}

func (so *StartupOptimizer) execContainer(image string) {
    // Setup container environment with minimal overhead
    so.setupMinimalEnvironment()
    
    // Execute container process
    if err := syscall.Exec("/usr/bin/docker", []string{"docker", "run", image}, os.Environ()); err != nil {
        log.Printf("Failed to exec container: %v", err)
    }
}

func (so *StartupOptimizer) setupMinimalEnvironment() {
    // Minimal environment setup for fastest startup
    
    // Set minimal PATH
    os.Setenv("PATH", "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")
    
    // Disable unnecessary features
    os.Setenv("DEBIAN_FRONTEND", "noninteractive")
    os.Setenv("TERM", "xterm")
    
    // Optimize memory allocation
    os.Setenv("MALLOC_ARENA_MAX", "2")
    os.Setenv("MALLOC_MMAP_THRESHOLD_", "131072")
}

// Memory-mapped file optimization for faster I/O
func (so *StartupOptimizer) OptimizeFileAccess(filePath string) error {
    file, err := os.Open(filePath)
    if err != nil {
        return err
    }
    defer file.Close()
    
    stat, err := file.Stat()
    if err != nil {
        return err
    }
    
    // Memory map the file for faster access
    data, err := unix.Mmap(int(file.Fd()), 0, int(stat.Size()), 
                          unix.PROT_READ, unix.MAP_SHARED)
    if err != nil {
        return err
    }
    
    // Advise kernel about access pattern
    if err := unix.Madvise(data, unix.MADV_SEQUENTIAL); err != nil {
        return err
    }
    
    // Prefault pages for immediate access
    if err := unix.Madvise(data, unix.MADV_WILLNEED); err != nil {
        return err
    }
    
    return unix.Munmap(data)
}

// CPU affinity optimization
func (so *StartupOptimizer) OptimizeCPUAffinity(pid int, cpus []int) error {
    var cpuSet unix.CPUSet
    cpuSet.Zero()
    
    for _, cpu := range cpus {
        cpuSet.Set(cpu)
    }
    
    return unix.SchedSetaffinity(pid, &cpuSet)
}

// Memory optimization with huge pages
func (so *StartupOptimizer) EnableHugePages(size int) error {
    // Allocate memory with huge pages for better performance
    flags := unix.MAP_PRIVATE | unix.MAP_ANONYMOUS | unix.MAP_HUGETLB
    
    addr, err := unix.Mmap(-1, 0, size, unix.PROT_READ|unix.PROT_WRITE, flags)
    if err != nil {
        return err
    }
    
    // Lock pages in memory to prevent swapping
    if err := unix.Mlock(addr); err != nil {
        unix.Munmap(addr)
        return err
    }
    
    log.Printf("Allocated %d bytes with huge pages", size)
    return nil
}
```

### Advanced Performance Profiling
```python
#!/usr/bin/env python3
# performance-profiler.py - Comprehensive container performance analysis

import time
import psutil
import docker
import subprocess
import json
import threading
from collections import defaultdict, deque
import numpy as np

class ContainerProfiler:
    def __init__(self):
        self.client = docker.from_env()
        self.metrics = defaultdict(lambda: defaultdict(deque))
        self.profiling = False
        
    def profile_container_startup(self, image, iterations=100):
        """Profile container startup performance with statistical analysis"""
        startup_times = []
        
        print(f"Profiling startup time for {image} ({iterations} iterations)")
        
        for i in range(iterations):
            start_time = time.perf_counter()
            
            # Create and start container
            container = self.client.containers.run(
                image, 
                command="echo 'ready'",
                detach=True,
                remove=True
            )
            
            # Wait for container to be ready
            container.wait()
            
            end_time = time.perf_counter()
            startup_time = (end_time - start_time) * 1000  # Convert to milliseconds
            startup_times.append(startup_time)
            
            if i % 10 == 0:
                print(f"Iteration {i}: {startup_time:.2f}ms")
        
        # Statistical analysis
        stats = {
            'mean': np.mean(startup_times),
            'median': np.median(startup_times),
            'std': np.std(startup_times),
            'min': np.min(startup_times),
            'max': np.max(startup_times),
            'p95': np.percentile(startup_times, 95),
            'p99': np.percentile(startup_times, 99)
        }
        
        print(f"\nStartup Time Statistics (ms):")
        for metric, value in stats.items():
            print(f"  {metric}: {value:.2f}")
        
        return stats
    
    def profile_memory_usage(self, container_id, duration=60):
        """Profile memory usage patterns with detailed analysis"""
        print(f"Profiling memory usage for container {container_id[:12]} for {duration}s")
        
        container = self.client.containers.get(container_id)
        memory_stats = []
        
        start_time = time.time()
        
        while time.time() - start_time < duration:
            try:
                stats = container.stats(stream=False)
                
                # Calculate memory metrics
                memory_usage = stats['memory_stats']['usage']
                memory_limit = stats['memory_stats']['limit']
                memory_percent = (memory_usage / memory_limit) * 100
                
                # Cache statistics
                cache = stats['memory_stats'].get('stats', {})
                cache_usage = cache.get('cache', 0)
                rss = cache.get('rss', 0)
                
                memory_data = {
                    'timestamp': time.time(),
                    'usage_bytes': memory_usage,
                    'usage_percent': memory_percent,
                    'cache_bytes': cache_usage,
                    'rss_bytes': rss,
                    'limit_bytes': memory_limit
                }
                
                memory_stats.append(memory_data)
                
                # Real-time analysis
                if len(memory_stats) > 10:
                    recent_usage = [m['usage_percent'] for m in memory_stats[-10:]]
                    trend = np.polyfit(range(len(recent_usage)), recent_usage, 1)[0]
                    
                    if trend > 1.0:  # Memory usage increasing rapidly
                        print(f"WARNING: Memory usage trending up: {trend:.2f}%/sample")
                
            except Exception as e:
                print(f"Error collecting memory stats: {e}")
            
            time.sleep(1)
        
        return self.analyze_memory_patterns(memory_stats)
    
    def analyze_memory_patterns(self, memory_stats):
        """Analyze memory usage patterns for optimization opportunities"""
        if not memory_stats:
            return {}
        
        usage_values = [m['usage_percent'] for m in memory_stats]
        cache_values = [m['cache_bytes'] for m in memory_stats]
        
        analysis = {
            'peak_usage_percent': max(usage_values),
            'average_usage_percent': np.mean(usage_values),
            'memory_volatility': np.std(usage_values),
            'cache_efficiency': np.mean(cache_values) / np.mean([m['usage_bytes'] for m in memory_stats]),
            'memory_leaks_detected': self.detect_memory_leaks(usage_values),
            'optimization_recommendations': []
        }
        
        # Generate recommendations
        if analysis['peak_usage_percent'] > 90:
            analysis['optimization_recommendations'].append(
                "Consider increasing memory limit or optimizing application memory usage"
            )
        
        if analysis['memory_volatility'] > 20:
            analysis['optimization_recommendations'].append(
                "High memory volatility detected - investigate memory allocation patterns"
            )
        
        if analysis['cache_efficiency'] < 0.1:
            analysis['optimization_recommendations'].append(
                "Low cache efficiency - consider optimizing I/O patterns"
            )
        
        return analysis
    
    def detect_memory_leaks(self, usage_values, window_size=20):
        """Detect potential memory leaks using trend analysis"""
        if len(usage_values) < window_size * 2:
            return False
        
        # Calculate trend over sliding windows
        trends = []
        for i in range(len(usage_values) - window_size):
            window = usage_values[i:i + window_size]
            trend = np.polyfit(range(len(window)), window, 1)[0]
            trends.append(trend)
        
        # Memory leak if consistently increasing trend
        positive_trends = sum(1 for t in trends if t > 0.1)
        return positive_trends > len(trends) * 0.8
    
    def profile_cpu_performance(self, container_id, duration=60):
        """Profile CPU performance with detailed analysis"""
        print(f"Profiling CPU performance for container {container_id[:12]}")
        
        container = self.client.containers.get(container_id)
        cpu_stats = []
        
        # Get container PID for detailed analysis
        inspect = container.attrs
        pid = inspect['State']['Pid']
        
        start_time = time.time()
        prev_stats = None
        
        while time.time() - start_time < duration:
            try:
                stats = container.stats(stream=False)
                
                if prev_stats:
                    # Calculate CPU usage percentage
                    cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                               prev_stats['cpu_stats']['cpu_usage']['total_usage']
                    system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                                  prev_stats['cpu_stats']['system_cpu_usage']
                    
                    if system_delta > 0:
                        cpu_percent = (cpu_delta / system_delta) * 100.0
                        
                        # Get per-CPU usage
                        per_cpu_usage = []
                        if 'percpu_usage' in stats['cpu_stats']['cpu_usage']:
                            current_per_cpu = stats['cpu_stats']['cpu_usage']['percpu_usage']
                            prev_per_cpu = prev_stats['cpu_stats']['cpu_usage']['percpu_usage']
                            
                            for i, (curr, prev) in enumerate(zip(current_per_cpu, prev_per_cpu)):
                                if system_delta > 0:
                                    per_cpu_percent = ((curr - prev) / system_delta) * 100.0
                                    per_cpu_usage.append(per_cpu_percent)
                        
                        cpu_data = {
                            'timestamp': time.time(),
                            'cpu_percent': cpu_percent,
                            'per_cpu_usage': per_cpu_usage,
                            'throttled_periods': stats['cpu_stats'].get('throttling_data', {}).get('throttled_periods', 0),
                            'throttled_time': stats['cpu_stats'].get('throttling_data', {}).get('throttled_time', 0)
                        }
                        
                        cpu_stats.append(cpu_data)
                        
                        # Real-time throttling detection
                        if cpu_data['throttled_periods'] > 0:
                            print(f"WARNING: CPU throttling detected - {cpu_data['throttled_periods']} periods")
                
                prev_stats = stats
                
            except Exception as e:
                print(f"Error collecting CPU stats: {e}")
            
            time.sleep(1)
        
        return self.analyze_cpu_patterns(cpu_stats)
    
    def analyze_cpu_patterns(self, cpu_stats):
        """Analyze CPU usage patterns for optimization"""
        if not cpu_stats:
            return {}
        
        cpu_values = [c['cpu_percent'] for c in cpu_stats]
        throttled_periods = [c['throttled_periods'] for c in cpu_stats]
        
        analysis = {
            'peak_cpu_percent': max(cpu_values),
            'average_cpu_percent': np.mean(cpu_values),
            'cpu_volatility': np.std(cpu_values),
            'total_throttled_periods': sum(throttled_periods),
            'cpu_efficiency': self.calculate_cpu_efficiency(cpu_stats),
            'optimization_recommendations': []
        }
        
        # Generate recommendations
        if analysis['total_throttled_periods'] > 0:
            analysis['optimization_recommendations'].append(
                f"CPU throttling detected ({analysis['total_throttled_periods']} periods) - consider increasing CPU limits"
            )
        
        if analysis['cpu_volatility'] > 30:
            analysis['optimization_recommendations'].append(
                "High CPU volatility - investigate workload patterns and consider CPU pinning"
            )
        
        if analysis['cpu_efficiency'] < 0.5:
            analysis['optimization_recommendations'].append(
                "Low CPU efficiency - optimize application CPU usage patterns"
            )
        
        return analysis
    
    def calculate_cpu_efficiency(self, cpu_stats):
        """Calculate CPU efficiency based on usage patterns"""
        if not cpu_stats:
            return 0
        
        # Efficiency = consistent usage / peak usage
        cpu_values = [c['cpu_percent'] for c in cpu_stats]
        consistent_usage = np.percentile(cpu_values, 75)  # 75th percentile
        peak_usage = max(cpu_values)
        
        return consistent_usage / peak_usage if peak_usage > 0 else 0
    
    def profile_io_performance(self, container_id, duration=60):
        """Profile I/O performance with detailed analysis"""
        print(f"Profiling I/O performance for container {container_id[:12]}")
        
        container = self.client.containers.get(container_id)
        io_stats = []
        
        start_time = time.time()
        prev_stats = None
        
        while time.time() - start_time < duration:
            try:
                stats = container.stats(stream=False)
                
                if prev_stats and 'blkio_stats' in stats:
                    blkio = stats['blkio_stats']
                    prev_blkio = prev_stats['blkio_stats']
                    
                    # Calculate I/O rates
                    read_bytes = self.get_blkio_value(blkio, 'Read') - \
                                self.get_blkio_value(prev_blkio, 'Read')
                    write_bytes = self.get_blkio_value(blkio, 'Write') - \
                                 self.get_blkio_value(prev_blkio, 'Write')
                    
                    io_data = {
                        'timestamp': time.time(),
                        'read_bytes_per_sec': read_bytes,
                        'write_bytes_per_sec': write_bytes,
                        'total_io_bytes_per_sec': read_bytes + write_bytes,
                        'read_ops_per_sec': self.get_blkio_ops(blkio, 'Read') - \
                                           self.get_blkio_ops(prev_blkio, 'Read'),
                        'write_ops_per_sec': self.get_blkio_ops(blkio, 'Write') - \
                                            self.get_blkio_ops(prev_blkio, 'Write')
                    }
                    
                    io_stats.append(io_data)
                
                prev_stats = stats
                
            except Exception as e:
                print(f"Error collecting I/O stats: {e}")
            
            time.sleep(1)
        
        return self.analyze_io_patterns(io_stats)
    
    def get_blkio_value(self, blkio_stats, op_type):
        """Extract block I/O values from stats"""
        for entry in blkio_stats.get('io_service_bytes_recursive', []):
            if entry['op'] == op_type:
                return entry['value']
        return 0
    
    def get_blkio_ops(self, blkio_stats, op_type):
        """Extract block I/O operations from stats"""
        for entry in blkio_stats.get('io_serviced_recursive', []):
            if entry['op'] == op_type:
                return entry['value']
        return 0
    
    def analyze_io_patterns(self, io_stats):
        """Analyze I/O patterns for optimization"""
        if not io_stats:
            return {}
        
        read_values = [io['read_bytes_per_sec'] for io in io_stats]
        write_values = [io['write_bytes_per_sec'] for io in io_stats]
        
        analysis = {
            'peak_read_bps': max(read_values),
            'peak_write_bps': max(write_values),
            'average_read_bps': np.mean(read_values),
            'average_write_bps': np.mean(write_values),
            'io_pattern': self.classify_io_pattern(io_stats),
            'optimization_recommendations': []
        }
        
        # Generate recommendations
        if analysis['peak_read_bps'] > 100 * 1024 * 1024:  # > 100 MB/s
            analysis['optimization_recommendations'].append(
                "High read I/O detected - consider using faster storage or caching"
            )
        
        if analysis['peak_write_bps'] > 50 * 1024 * 1024:  # > 50 MB/s
            analysis['optimization_recommendations'].append(
                "High write I/O detected - consider optimizing write patterns or using write-back caching"
            )
        
        return analysis
    
    def classify_io_pattern(self, io_stats):
        """Classify I/O access patterns"""
        if not io_stats:
            return "unknown"
        
        read_values = [io['read_bytes_per_sec'] for io in io_stats]
        write_values = [io['write_bytes_per_sec'] for io in io_stats]
        
        avg_read = np.mean(read_values)
        avg_write = np.mean(write_values)
        
        if avg_read > avg_write * 3:
            return "read-heavy"
        elif avg_write > avg_read * 3:
            return "write-heavy"
        else:
            return "balanced"
    
    def comprehensive_performance_report(self, container_id, duration=300):
        """Generate comprehensive performance report"""
        print(f"Generating comprehensive performance report for {container_id[:12]}")
        
        # Run all profiling in parallel
        results = {}
        
        # Memory profiling
        memory_thread = threading.Thread(
            target=lambda: results.update({'memory': self.profile_memory_usage(container_id, duration)})
        )
        
        # CPU profiling
        cpu_thread = threading.Thread(
            target=lambda: results.update({'cpu': self.profile_cpu_performance(container_id, duration)})
        )
        
        # I/O profiling
        io_thread = threading.Thread(
            target=lambda: results.update({'io': self.profile_io_performance(container_id, duration)})
        )
        
        # Start all threads
        memory_thread.start()
        cpu_thread.start()
        io_thread.start()
        
        # Wait for completion
        memory_thread.join()
        cpu_thread.join()
        io_thread.join()
        
        # Generate overall recommendations
        overall_recommendations = self.generate_overall_recommendations(results)
        results['overall_recommendations'] = overall_recommendations
        
        return results
    
    def generate_overall_recommendations(self, results):
        """Generate overall optimization recommendations"""
        recommendations = []
        
        # Cross-metric analysis
        if 'memory' in results and 'cpu' in results:
            memory_peak = results['memory'].get('peak_usage_percent', 0)
            cpu_peak = results['cpu'].get('peak_cpu_percent', 0)
            
            if memory_peak > 80 and cpu_peak < 30:
                recommendations.append(
                    "Memory-bound workload detected - consider optimizing memory usage or increasing memory limits"
                )
            elif cpu_peak > 80 and memory_peak < 30:
                recommendations.append(
                    "CPU-bound workload detected - consider optimizing algorithms or increasing CPU limits"
                )
        
        return recommendations

def main():
    profiler = ContainerProfiler()
    
    # Example usage
    container_id = "your-container-id"  # Replace with actual container ID
    
    # Generate comprehensive report
    report = profiler.comprehensive_performance_report(container_id, duration=60)
    
    # Save report
    with open(f'performance_report_{container_id[:12]}.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print("Performance report generated successfully!")

if __name__ == "__main__":
    main()
```

This continues Module 7 with cutting-edge performance engineering techniques that go far beyond typical container optimization. The content maintains the revolutionary depth and practical implementation focus that makes this module truly game-changing for container performance mastery.
