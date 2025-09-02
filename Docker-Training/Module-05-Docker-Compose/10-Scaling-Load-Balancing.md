# Scaling & Load Balancing - E-Commerce High Performance Architecture

## 📋 Learning Objectives
- **Master** horizontal and vertical scaling strategies for e-commerce
- **Understand** load balancing configurations and algorithms
- **Apply** auto-scaling based on metrics and demand patterns
- **Build** high-performance architecture for traffic spikes

---

## 🤔 The Scaling Challenge in E-Commerce

### **The Problem: Traffic Spikes**
```
E-Commerce Traffic Patterns:
├── Black Friday: 10x normal traffic
├── Flash Sales: 50x normal traffic in minutes
├── Product Launches: Unpredictable spikes
├── Holiday Seasons: Sustained high traffic
└── Viral Social Media: Sudden massive load
```

### **Single Instance Limitations**
```yaml
# ❌ Single instance - bottleneck and single point of failure
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    # What happens when:
    # - 1000 concurrent users hit this single instance?
    # - The instance crashes or becomes unresponsive?
    # - CPU/Memory usage hits 100%?
```

### **Scaled Solution**
```yaml
# ✅ Multiple instances with load balancing
services:
  backend:
    build: ./backend
    deploy:
      replicas: 5  # 5 instances to handle load
    # Load balancer distributes traffic across all instances
    # If one fails, others continue serving requests
    # Can scale up/down based on demand
```

---

## 🏗️ E-Commerce Scaling Architecture

### **Complete Scalable E-Commerce Stack**

```yaml
version: '3.8'

services:
  # Load Balancer (HAProxy)
  loadbalancer:
    image: haproxy:2.6-alpine
    ports:
      - "80:80"
      - "443:443"
      - "8404:8404"  # Stats page
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
      - ./ssl:/etc/ssl/certs:ro
    networks:
      - web_network
    depends_on:
      - backend
      - frontend
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'

  # Frontend (Horizontally Scaled)
  frontend:
    build: ./frontend
    networks:
      - web_network
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
      update_config:
        parallelism: 1
        delay: 10s
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend API (Horizontally Scaled)
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      NODE_ENV: production
    networks:
      - web_network
      - database_network
      - cache_network
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    deploy:
      replicas: 5  # Scale based on load
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'
      update_config:
        parallelism: 2
        delay: 10s
        failure_action: rollback
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Database (Master-Slave Replication)
  database-master:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_REPLICATION_MODE: master
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: ${REPLICATION_PASSWORD}
    volumes:
      - postgres_master_data:/var/lib/postgresql/data
      - ./database/master.conf:/etc/postgresql/postgresql.conf:ro
    networks:
      - database_network
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
      placement:
        constraints:
          - node.role == manager

  database-slave:
    image: postgres:13-alpine
    environment:
      POSTGRES_MASTER_SERVICE: database-master
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: ${REPLICATION_PASSWORD}
    volumes:
      - postgres_slave_data:/var/lib/postgresql/data
    networks:
      - database_network
    depends_on:
      - database-master
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  # Redis Cluster (High Availability)
  redis-master:
    image: redis:7-alpine
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --appendonly yes
      --save 900 1
      --save 300 10
      --save 60 10000
    volumes:
      - redis_master_data:/data
    networks:
      - cache_network
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  redis-slave:
    image: redis:7-alpine
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --slaveof redis-master 6379
      --masterauth ${REDIS_PASSWORD}
    networks:
      - cache_network
    depends_on:
      - redis-master
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  # Auto-Scaler Service
  autoscaler:
    build: ./autoscaler
    environment:
      DOCKER_HOST: unix:///var/run/docker.sock
      SCALE_UP_THRESHOLD: 80    # CPU percentage
      SCALE_DOWN_THRESHOLD: 30  # CPU percentage
      MIN_REPLICAS: 2
      MAX_REPLICAS: 10
      CHECK_INTERVAL: 30        # seconds
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - monitoring_network
    deploy:
      placement:
        constraints:
          - node.role == manager

  # Monitoring (Prometheus)
  prometheus:
    image: prom/prometheus:latest
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=15d'
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring_network
      - web_network
    ports:
      - "9090:9090"

networks:
  web_network:
    driver: overlay
    attachable: true
  database_network:
    driver: overlay
    internal: true
  cache_network:
    driver: overlay
    internal: true
  monitoring_network:
    driver: overlay
    internal: true

volumes:
  postgres_master_data:
  postgres_slave_data:
  redis_master_data:
  prometheus_data:
```

---

## ⚖️ Load Balancing Strategies

### **1. HAProxy Configuration**

```conf
# haproxy/haproxy.cfg
global
    daemon
    log stdout local0
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy

defaults
    mode http
    log global
    option httplog
    option dontlognull
    option http-server-close
    option forwardfor except 127.0.0.0/8
    option redispatch
    retries 3
    timeout http-request 10s
    timeout queue 1m
    timeout connect 10s
    timeout client 1m
    timeout server 1m
    timeout http-keep-alive 10s
    timeout check 10s
    maxconn 3000

# Frontend Load Balancer
frontend ecommerce_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/ecommerce.pem
    redirect scheme https if !{ ssl_fc }
    
    # Route based on path
    acl is_api path_beg /api
    acl is_admin path_beg /admin
    
    use_backend api_servers if is_api
    use_backend admin_servers if is_admin
    default_backend web_servers

# Backend Servers
backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    
    server web1 frontend:80 check inter 5s fall 3 rise 2
    server web2 frontend:80 check inter 5s fall 3 rise 2
    server web3 frontend:80 check inter 5s fall 3 rise 2

backend api_servers
    balance leastconn
    option httpchk GET /api/health
    http-check expect status 200
    
    server api1 backend:8000 check inter 5s fall 3 rise 2 weight 100
    server api2 backend:8000 check inter 5s fall 3 rise 2 weight 100
    server api3 backend:8000 check inter 5s fall 3 rise 2 weight 100
    server api4 backend:8000 check inter 5s fall 3 rise 2 weight 100
    server api5 backend:8000 check inter 5s fall 3 rise 2 weight 100

# Statistics
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
```

### **2. Load Balancing Algorithms**

#### **Round Robin (Default)**
```conf
backend api_servers
    balance roundrobin
    # Distributes requests evenly across all servers
    # Request 1 -> Server 1
    # Request 2 -> Server 2
    # Request 3 -> Server 3
    # Request 4 -> Server 1 (cycle repeats)
```

#### **Least Connections**
```conf
backend api_servers
    balance leastconn
    # Routes to server with fewest active connections
    # Best for long-running requests
    # Automatically adapts to server performance differences
```

#### **Weighted Round Robin**
```conf
backend api_servers
    balance roundrobin
    server api1 backend:8000 weight 100  # Standard capacity
    server api2 backend:8000 weight 150  # 50% more capacity
    server api3 backend:8000 weight 50   # 50% less capacity
```

#### **IP Hash (Session Affinity)**
```conf
backend api_servers
    balance source
    # Routes based on client IP hash
    # Same client always goes to same server
    # Useful for session-based applications
```

---

## 📈 Auto-Scaling Implementation

### **1. Metrics-Based Auto-Scaler**

```javascript
// autoscaler/index.js
const Docker = require('dockerode');
const docker = new Docker();

class AutoScaler {
  constructor() {
    this.scaleUpThreshold = parseInt(process.env.SCALE_UP_THRESHOLD) || 80;
    this.scaleDownThreshold = parseInt(process.env.SCALE_DOWN_THRESHOLD) || 30;
    this.minReplicas = parseInt(process.env.MIN_REPLICAS) || 2;
    this.maxReplicas = parseInt(process.env.MAX_REPLICAS) || 10;
    this.checkInterval = parseInt(process.env.CHECK_INTERVAL) || 30;
    this.serviceName = process.env.SERVICE_NAME || 'ecommerce_backend';
  }

  async getServiceMetrics() {
    try {
      const service = docker.getService(this.serviceName);
      const tasks = await service.tasks();
      
      let totalCpu = 0;
      let totalMemory = 0;
      let runningTasks = 0;

      for (const task of tasks) {
        if (task.Status.State === 'running') {
          const container = docker.getContainer(task.Status.ContainerStatus.ContainerID);
          const stats = await container.stats({ stream: false });
          
          // Calculate CPU percentage
          const cpuPercent = this.calculateCpuPercent(stats);
          totalCpu += cpuPercent;
          
          // Calculate memory percentage
          const memoryPercent = (stats.memory_stats.usage / stats.memory_stats.limit) * 100;
          totalMemory += memoryPercent;
          
          runningTasks++;
        }
      }

      return {
        avgCpu: totalCpu / runningTasks,
        avgMemory: totalMemory / runningTasks,
        currentReplicas: runningTasks
      };
    } catch (error) {
      console.error('Error getting metrics:', error);
      return null;
    }
  }

  calculateCpuPercent(stats) {
    const cpuDelta = stats.cpu_stats.cpu_usage.total_usage - stats.precpu_stats.cpu_usage.total_usage;
    const systemDelta = stats.cpu_stats.system_cpu_usage - stats.precpu_stats.system_cpu_usage;
    const numberCpus = stats.cpu_stats.online_cpus;
    
    return (cpuDelta / systemDelta) * numberCpus * 100.0;
  }

  async scaleService(replicas) {
    try {
      const service = docker.getService(this.serviceName);
      const spec = await service.inspect();
      
      spec.Spec.Mode.Replicated.Replicas = replicas;
      
      await service.update(spec.Spec, {
        version: spec.Version.Index
      });
      
      console.log(`Scaled ${this.serviceName} to ${replicas} replicas`);
      return true;
    } catch (error) {
      console.error('Error scaling service:', error);
      return false;
    }
  }

  async checkAndScale() {
    const metrics = await this.getServiceMetrics();
    if (!metrics) return;

    console.log(`Current metrics: CPU: ${metrics.avgCpu.toFixed(2)}%, Memory: ${metrics.avgMemory.toFixed(2)}%, Replicas: ${metrics.currentReplicas}`);

    // Scale up if CPU is high and we're below max replicas
    if (metrics.avgCpu > this.scaleUpThreshold && metrics.currentReplicas < this.maxReplicas) {
      const newReplicas = Math.min(metrics.currentReplicas + 1, this.maxReplicas);
      console.log(`Scaling up to ${newReplicas} replicas (CPU: ${metrics.avgCpu.toFixed(2)}%)`);
      await this.scaleService(newReplicas);
    }
    // Scale down if CPU is low and we're above min replicas
    else if (metrics.avgCpu < this.scaleDownThreshold && metrics.currentReplicas > this.minReplicas) {
      const newReplicas = Math.max(metrics.currentReplicas - 1, this.minReplicas);
      console.log(`Scaling down to ${newReplicas} replicas (CPU: ${metrics.avgCpu.toFixed(2)}%)`);
      await this.scaleService(newReplicas);
    }
  }

  start() {
    console.log(`Auto-scaler started for ${this.serviceName}`);
    console.log(`Scale up threshold: ${this.scaleUpThreshold}%`);
    console.log(`Scale down threshold: ${this.scaleDownThreshold}%`);
    console.log(`Min replicas: ${this.minReplicas}, Max replicas: ${this.maxReplicas}`);
    
    setInterval(() => {
      this.checkAndScale();
    }, this.checkInterval * 1000);
  }
}

const scaler = new AutoScaler();
scaler.start();
```

### **2. Queue-Based Scaling**

```javascript
// autoscaler/queue-scaler.js
const Redis = require('redis');

class QueueBasedScaler {
  constructor() {
    this.redis = Redis.createClient({ url: process.env.REDIS_URL });
    this.queueName = 'background_jobs';
    this.workersPerJob = 10; // Scale 1 worker per 10 jobs
    this.minWorkers = 2;
    this.maxWorkers = 20;
  }

  async getQueueLength() {
    return await this.redis.llen(this.queueName);
  }

  async scaleWorkers() {
    const queueLength = await this.getQueueLength();
    const desiredWorkers = Math.ceil(queueLength / this.workersPerJob);
    const targetWorkers = Math.max(this.minWorkers, Math.min(desiredWorkers, this.maxWorkers));

    console.log(`Queue length: ${queueLength}, Target workers: ${targetWorkers}`);

    // Scale worker service
    await this.scaleService('ecommerce_worker', targetWorkers);
  }

  async scaleService(serviceName, replicas) {
    // Implementation similar to previous example
    const service = docker.getService(serviceName);
    const spec = await service.inspect();
    spec.Spec.Mode.Replicated.Replicas = replicas;
    await service.update(spec.Spec, { version: spec.Version.Index });
  }
}
```

---

## 🧪 Hands-On Practice: Scaling Implementation

### **Exercise 1: Manual Scaling**

```bash
# Scale backend service to 5 replicas
docker service scale ecommerce_backend=5

# Check scaling status
docker service ls
docker service ps ecommerce_backend

# Monitor resource usage
docker stats

# Scale down
docker service scale ecommerce_backend=2
```

### **Exercise 2: Load Testing**

```bash
# Install load testing tool
npm install -g artillery

# Create load test configuration
cat > load-test.yml << 'EOF'
config:
  target: 'https://api.yourdomain.com'
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Ramp up load"
    - duration: 300
      arrivalRate: 100
      name: "Sustained load"
  defaults:
    headers:
      Content-Type: 'application/json'

scenarios:
  - name: "E-commerce API test"
    weight: 100
    flow:
      - get:
          url: "/api/products"
      - think: 2
      - get:
          url: "/api/products/{{ $randomInt(1, 100) }}"
      - think: 1
      - post:
          url: "/api/cart/add"
          json:
            productId: "{{ $randomInt(1, 100) }}"
            quantity: "{{ $randomInt(1, 5) }}"
EOF

# Run load test
artillery run load-test.yml

# Monitor scaling during test
watch -n 2 'docker service ls'
```

### **Exercise 3: Database Read Replica Setup**

```bash
# Create read replica
docker service create \
  --name postgres-read-replica \
  --network database_network \
  --env POSTGRES_MASTER_SERVICE=database-master \
  --env POSTGRES_REPLICATION_MODE=slave \
  --env POSTGRES_REPLICATION_USER=replicator \
  --env POSTGRES_REPLICATION_PASSWORD=${REPLICATION_PASSWORD} \
  --mount type=volume,source=postgres_replica_data,target=/var/lib/postgresql/data \
  postgres:13-alpine

# Configure application to use read replica for queries
# Update backend configuration to separate read/write connections
```

---

## 📊 Performance Monitoring

### **1. Prometheus Metrics Configuration**

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'haproxy'
    static_configs:
      - targets: ['loadbalancer:8404']
    metrics_path: /stats/prometheus

  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: /metrics

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### **2. Grafana Dashboard Configuration**

```json
{
  "dashboard": {
    "title": "E-Commerce Performance Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(haproxy_frontend_http_requests_total[5m])",
            "legendFormat": "Requests/sec"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph", 
        "targets": [
          {
            "expr": "haproxy_backend_response_time_average_seconds",
            "legendFormat": "Avg Response Time"
          }
        ]
      },
      {
        "title": "Active Connections",
        "type": "singlestat",
        "targets": [
          {
            "expr": "haproxy_backend_current_sessions",
            "legendFormat": "Active Connections"
          }
        ]
      }
    ]
  }
}
```

---

## ✅ Knowledge Check: Scaling Mastery

### **Conceptual Understanding**
- [ ] Understands horizontal vs vertical scaling strategies
- [ ] Knows load balancing algorithms and their use cases
- [ ] Comprehends auto-scaling triggers and metrics
- [ ] Understands database scaling patterns (read replicas, sharding)
- [ ] Knows performance monitoring and optimization techniques

### **Practical Skills**
- [ ] Can implement load balancing with HAProxy/Nginx
- [ ] Knows how to scale services manually and automatically
- [ ] Can set up database replication for read scaling
- [ ] Understands how to monitor and optimize performance
- [ ] Can conduct load testing and capacity planning

### **E-Commerce Application**
- [ ] Has implemented horizontal scaling for all services
- [ ] Set up load balancing with health checks
- [ ] Created auto-scaling based on metrics
- [ ] Implemented database read replicas
- [ ] Configured comprehensive performance monitoring

---

## 🚀 Next Steps: Security Best Practices

### **What You've Mastered**
- ✅ **Horizontal and vertical scaling** strategies
- ✅ **Load balancing** configurations and algorithms
- ✅ **Auto-scaling** based on metrics and demand
- ✅ **Performance optimization** for high-traffic scenarios
- ✅ **Monitoring and alerting** for scalable systems

### **Coming Next: Security Best Practices**
In **11-Security-Best-Practices.md**, you'll learn:
- **Container security** hardening and vulnerability management
- **Network security** and access controls
- **Secret management** and encryption
- **Security monitoring** and incident response

**Continue when you have successfully implemented scaling and load balancing for your e-commerce platform.**
