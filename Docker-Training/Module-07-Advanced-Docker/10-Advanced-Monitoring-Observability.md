# 📊 Advanced Monitoring & Observability

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** enterprise observability principles and monitoring strategies
- **Master** advanced metrics collection and analysis techniques
- **Implement** comprehensive monitoring for e-commerce container environments
- **Build** custom dashboards and alerting systems
- **Deploy** production-ready observability solutions

## 🎯 Real-World Context
E-commerce platforms require comprehensive observability to maintain high availability, optimize performance, and ensure customer satisfaction. This module teaches you to build enterprise-grade monitoring systems that provide deep insights into containerized applications and infrastructure.

---

## 📚 Part 1: Observability Fundamentals

### The Three Pillars of Observability

**1. Metrics**
- Quantitative measurements over time
- System performance indicators
- Business metrics and KPIs
- Resource utilization data

**2. Logs**
- Discrete event records
- Application and system logs
- Structured and unstructured data
- Audit trails and debugging information

**3. Traces**
- Request flow through distributed systems
- Performance bottleneck identification
- Service dependency mapping
- End-to-end transaction monitoring

### Monitoring Strategy for E-Commerce

**Infrastructure Monitoring:**
- Container resource usage (CPU, memory, I/O)
- Host system performance
- Network connectivity and latency
- Storage performance and capacity

**Application Monitoring:**
- Response times and throughput
- Error rates and availability
- Database performance
- Cache hit rates

**Business Monitoring:**
- Transaction volumes and success rates
- Revenue metrics
- User experience indicators
- Conversion funnel performance

---

## 🔧 Part 2: Metrics Collection and Analysis

### Prometheus Setup for E-Commerce

**Prometheus Configuration:**
```yaml
# prometheus.yml - E-commerce monitoring configuration
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "ecommerce_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Container metrics
  - job_name: 'docker'
    static_configs:
      - targets: ['localhost:9323']
    metrics_path: /metrics

  # Application metrics
  - job_name: 'ecommerce-api'
    static_configs:
      - targets: ['ecommerce-api:3000']
    metrics_path: /metrics
    scrape_interval: 5s

  - job_name: 'ecommerce-frontend'
    static_configs:
      - targets: ['ecommerce-frontend:80']
    metrics_path: /metrics

  # Database metrics
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  # Redis metrics
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  # Node metrics
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

**Custom Metrics in Applications:**
```javascript
// metrics.js - Custom application metrics
const prometheus = require('prom-client');

// Create custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const activeUsers = new prometheus.Gauge({
  name: 'ecommerce_active_users',
  help: 'Number of active users on the platform'
});

const orderTotal = new prometheus.Counter({
  name: 'ecommerce_orders_total',
  help: 'Total number of orders processed',
  labelNames: ['status', 'payment_method']
});

const inventoryLevel = new prometheus.Gauge({
  name: 'ecommerce_inventory_level',
  help: 'Current inventory levels',
  labelNames: ['product_id', 'category']
});

// Middleware to collect HTTP metrics
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  
  next();
};

// Business metrics collection
const updateBusinessMetrics = async () => {
  try {
    // Update active users
    const activeUserCount = await getUserCount();
    activeUsers.set(activeUserCount);
    
    // Update inventory levels
    const inventory = await getInventoryLevels();
    inventory.forEach(item => {
      inventoryLevel
        .labels(item.product_id, item.category)
        .set(item.quantity);
    });
    
  } catch (error) {
    console.error('Error updating business metrics:', error);
  }
};

// Update business metrics every 30 seconds
setInterval(updateBusinessMetrics, 30000);

module.exports = {
  httpRequestDuration,
  activeUsers,
  orderTotal,
  inventoryLevel,
  metricsMiddleware,
  register: prometheus.register
};
```

### Grafana Dashboard Configuration

**E-Commerce Dashboard:**
```json
{
  "dashboard": {
    "title": "E-Commerce Platform Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_request_duration_seconds_count[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ]
      },
      {
        "title": "Active Users",
        "type": "singlestat",
        "targets": [
          {
            "expr": "ecommerce_active_users"
          }
        ]
      },
      {
        "title": "Order Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ecommerce_orders_total[5m])",
            "legendFormat": "Orders per second"
          }
        ]
      }
    ]
  }
}
```

---

## 🏗️ Part 3: Comprehensive Monitoring Stack

### Complete Monitoring Setup

**Docker Compose Monitoring Stack:**
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./monitoring/rules:/etc/prometheus/rules
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'

  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_USERS_ALLOW_SIGN_UP: false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources

  # AlertManager
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager

  # Node Exporter
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'

  # cAdvisor for container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true

  # Postgres Exporter
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    environment:
      DATA_SOURCE_NAME: "postgresql://postgres:password@ecommerce-database:5432/ecommerce?sslmode=disable"
    ports:
      - "9187:9187"

  # Redis Exporter
  redis-exporter:
    image: oliver006/redis_exporter:latest
    environment:
      REDIS_ADDR: "redis://ecommerce-cache:6379"
    ports:
      - "9121:9121"

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
```

### Advanced Alerting Rules

**Prometheus Alerting Rules:**
```yaml
# ecommerce_rules.yml
groups:
  - name: ecommerce.rules
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(http_request_duration_seconds_count{status_code=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      # Low inventory
      - alert: LowInventory
        expr: ecommerce_inventory_level < 10
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Low inventory for product {{ $labels.product_id }}"
          description: "Only {{ $value }} items remaining"

      # Database connection issues
      - alert: DatabaseDown
        expr: up{job="postgres"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database is down"
          description: "PostgreSQL database is not responding"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage in {{ $labels.name }}"
          description: "Memory usage is {{ $value | humanizePercentage }}"
```

---

## 📋 Part 4: Log Management and Analysis

### Centralized Logging with ELK Stack

**Elasticsearch, Logstash, and Kibana Setup:**
```yaml
# docker-compose.logging.yml
version: '3.8'

services:
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      discovery.type: single-node
      ES_JAVA_OPTS: "-Xms2g -Xmx2g"
      xpack.security.enabled: false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: logstash:8.8.0
    ports:
      - "5044:5044"
      - "9600:9600"
    volumes:
      - ./logging/logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch

  kibana:
    image: kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    depends_on:
      - elasticsearch

  # Filebeat for log shipping
  filebeat:
    image: elastic/filebeat:8.8.0
    user: root
    volumes:
      - ./logging/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logstash

volumes:
  elasticsearch_data:
```

**Structured Logging in Applications:**
```javascript
// logger.js - Structured logging for e-commerce application
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { 
    service: 'ecommerce-api',
    version: process.env.APP_VERSION || '1.0.0'
  },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// Business event logging
const logBusinessEvent = (event, data) => {
  logger.info('Business Event', {
    event_type: event,
    event_data: data,
    timestamp: new Date().toISOString(),
    correlation_id: data.correlation_id || generateCorrelationId()
  });
};

// Performance logging
const logPerformance = (operation, duration, metadata = {}) => {
  logger.info('Performance Metric', {
    operation,
    duration_ms: duration,
    ...metadata,
    timestamp: new Date().toISOString()
  });
};

// Error logging with context
const logError = (error, context = {}) => {
  logger.error('Application Error', {
    error_message: error.message,
    error_stack: error.stack,
    context,
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  logger,
  logBusinessEvent,
  logPerformance,
  logError
};
```

---

## 🔍 Part 5: Distributed Tracing

### Jaeger Tracing Implementation

**Jaeger Setup:**
```yaml
# docker-compose.tracing.yml
version: '3.8'

services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      COLLECTOR_OTLP_ENABLED: true

  # OpenTelemetry Collector
  otel-collector:
    image: otel/opentelemetry-collector:latest
    command: ["--config=/etc/otel-collector-config.yml"]
    volumes:
      - ./tracing/otel-collector-config.yml:/etc/otel-collector-config.yml
    ports:
      - "4317:4317"   # OTLP gRPC receiver
      - "4318:4318"   # OTLP HTTP receiver
    depends_on:
      - jaeger
```

**Application Tracing:**
```javascript
// tracing.js - Distributed tracing setup
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const jaegerExporter = new JaegerExporter({
  endpoint: 'http://jaeger:14268/api/traces',
});

const sdk = new NodeSDK({
  traceExporter: jaegerExporter,
  instrumentations: [getNodeAutoInstrumentations()],
  serviceName: 'ecommerce-api',
  serviceVersion: '1.0.0',
});

sdk.start();

// Custom span creation
const { trace } = require('@opentelemetry/api');

const createCustomSpan = (name, operation) => {
  const tracer = trace.getTracer('ecommerce-api');
  const span = tracer.startSpan(name);
  
  return new Promise((resolve, reject) => {
    operation()
      .then(result => {
        span.setStatus({ code: 1 }); // OK
        span.end();
        resolve(result);
      })
      .catch(error => {
        span.setStatus({ code: 2, message: error.message }); // ERROR
        span.end();
        reject(error);
      });
  });
};

module.exports = { createCustomSpan };
```

---

## 🧪 Part 6: Hands-On Monitoring Labs

### Lab 1: Custom Metrics Implementation

**Objective:** Implement custom business metrics for e-commerce

```javascript
// business-metrics.js
const prometheus = require('prom-client');

// Revenue metrics
const revenueTotal = new prometheus.Counter({
  name: 'ecommerce_revenue_total',
  help: 'Total revenue generated',
  labelNames: ['currency', 'payment_method']
});

// Cart abandonment rate
const cartAbandonmentRate = new prometheus.Gauge({
  name: 'ecommerce_cart_abandonment_rate',
  help: 'Cart abandonment rate percentage'
});

// Product popularity
const productViews = new prometheus.Counter({
  name: 'ecommerce_product_views_total',
  help: 'Total product views',
  labelNames: ['product_id', 'category']
});

// Update metrics
const updateBusinessMetrics = async () => {
  // Calculate cart abandonment rate
  const totalCarts = await getTotalCarts();
  const completedOrders = await getCompletedOrders();
  const abandonmentRate = ((totalCarts - completedOrders) / totalCarts) * 100;
  cartAbandonmentRate.set(abandonmentRate);
};

setInterval(updateBusinessMetrics, 60000); // Update every minute
```

### Lab 2: Alert Configuration

**Objective:** Set up comprehensive alerting for e-commerce platform

```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@ecommerce.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'admin@ecommerce.com'
        subject: 'E-Commerce Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

---

## 🎓 Module Summary

You've mastered advanced monitoring and observability by learning:

**Core Concepts:**
- Three pillars of observability (metrics, logs, traces)
- Enterprise monitoring strategies and best practices
- Custom metrics collection and analysis techniques

**Practical Skills:**
- Implementing comprehensive monitoring stacks
- Creating custom dashboards and alerting systems
- Setting up distributed tracing and log management

**Enterprise Techniques:**
- Production-ready observability solutions
- Advanced alerting and incident response
- Performance optimization through monitoring insights

**Next Steps:**
- Implement monitoring for your e-commerce platform
- Set up automated alerting and incident response
- Prepare for Module 11: Container Forensics & Debugging

---

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [ELK Stack Guide](https://www.elastic.co/guide/)
    
    // Prometheus metrics
    cpuUsage       *prometheus.GaugeVec
    memoryUsage    *prometheus.GaugeVec
    networkIO      *prometheus.CounterVec
    diskIO         *prometheus.CounterVec
    customMetrics  *prometheus.GaugeVec
}

type ContainerMetrics struct {
    ID            string                 `json:"id"`
    Name          string                 `json:"name"`
    CPUUsage      float64               `json:"cpu_usage"`
    MemoryUsage   int64                 `json:"memory_usage"`
    MemoryLimit   int64                 `json:"memory_limit"`
    NetworkRx     uint64                `json:"network_rx"`
    NetworkTx     uint64                `json:"network_tx"`
    DiskRead      uint64                `json:"disk_read"`
    DiskWrite     uint64                `json:"disk_write"`
    ProcessCount  int                   `json:"process_count"`
    ThreadCount   int                   `json:"thread_count"`
    FileDescriptors int                 `json:"file_descriptors"`
    Timestamp     time.Time             `json:"timestamp"`
    CustomMetrics map[string]float64    `json:"custom_metrics"`
}

func NewMetricsCollector(interval time.Duration) *MetricsCollector {
    return &MetricsCollector{
        containers:      make(map[string]*ContainerMetrics),
        collectInterval: interval,
        
        cpuUsage: promauto.NewGaugeVec(
            prometheus.GaugeOpts{
                Name: "container_cpu_usage_percent",
                Help: "Container CPU usage percentage",
            },
            []string{"container_id", "container_name"},
        ),
        
        memoryUsage: promauto.NewGaugeVec(
            prometheus.GaugeOpts{
                Name: "container_memory_usage_bytes",
                Help: "Container memory usage in bytes",
            },
            []string{"container_id", "container_name"},
        ),
        
        networkIO: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Name: "container_network_io_bytes_total",
                Help: "Container network I/O bytes",
            },
            []string{"container_id", "container_name", "direction"},
        ),
        
        diskIO: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Name: "container_disk_io_bytes_total",
                Help: "Container disk I/O bytes",
            },
            []string{"container_id", "container_name", "operation"},
        ),
        
        customMetrics: promauto.NewGaugeVec(
            prometheus.GaugeOpts{
                Name: "container_custom_metric",
                Help: "Custom container metrics",
            },
            []string{"container_id", "container_name", "metric_name"},
        ),
    }
}

func (mc *MetricsCollector) Start(ctx context.Context) error {
    ticker := time.NewTicker(mc.collectInterval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case <-ticker.C:
            if err := mc.collectMetrics(); err != nil {
                log.Printf("Error collecting metrics: %v", err)
            }
        }
    }
}

func (mc *MetricsCollector) collectMetrics() error {
    // Get list of running containers
    containers, err := mc.getRunningContainers()
    if err != nil {
        return err
    }

    var wg sync.WaitGroup
    for _, containerID := range containers {
        wg.Add(1)
        go func(id string) {
            defer wg.Done()
            mc.collectContainerMetrics(id)
        }(containerID)
    }
    
    wg.Wait()
    return nil
}

func (mc *MetricsCollector) collectContainerMetrics(containerID string) {
    metrics := &ContainerMetrics{
        ID:            containerID,
        Timestamp:     time.Now(),
        CustomMetrics: make(map[string]float64),
    }

    // Collect basic metrics
    mc.collectCPUMetrics(containerID, metrics)
    mc.collectMemoryMetrics(containerID, metrics)
    mc.collectNetworkMetrics(containerID, metrics)
    mc.collectDiskMetrics(containerID, metrics)
    mc.collectProcessMetrics(containerID, metrics)
    mc.collectCustomMetrics(containerID, metrics)

    // Store metrics
    mc.mutex.Lock()
    mc.containers[containerID] = metrics
    mc.mutex.Unlock()

    // Update Prometheus metrics
    mc.updatePrometheusMetrics(metrics)
}

func (mc *MetricsCollector) collectCPUMetrics(containerID string, metrics *ContainerMetrics) {
    // Read CPU stats from cgroup
    cpuStatPath := fmt.Sprintf("/sys/fs/cgroup/cpu/docker/%s/cpuacct.stat", containerID)
    cpuUsagePath := fmt.Sprintf("/sys/fs/cgroup/cpu/docker/%s/cpuacct.usage", containerID)
    
    // Implementation would read actual cgroup files
    // For demonstration, using mock values
    metrics.CPUUsage = mc.calculateCPUUsage(containerID)
}

func (mc *MetricsCollector) calculateCPUUsage(containerID string) float64 {
    // Read current CPU usage
    currentUsage := mc.readCPUUsage(containerID)
    
    // Calculate usage percentage based on previous reading
    mc.mutex.RLock()
    prevMetrics, exists := mc.containers[containerID]
    mc.mutex.RUnlock()
    
    if !exists {
        return 0.0
    }
    
    // Calculate CPU percentage
    timeDelta := time.Since(prevMetrics.Timestamp).Nanoseconds()
    if timeDelta == 0 {
        return 0.0
    }
    
    // Mock calculation - in real implementation would use actual cgroup values
    return float64(currentUsage) / float64(timeDelta) * 100.0
}

func (mc *MetricsCollector) readCPUUsage(containerID string) uint64 {
    // Read from /sys/fs/cgroup/cpu/docker/{containerID}/cpuacct.usage
    // Mock implementation
    return uint64(time.Now().UnixNano() % 1000000)
}

func (mc *MetricsCollector) collectMemoryMetrics(containerID string, metrics *ContainerMetrics) {
    memoryUsagePath := fmt.Sprintf("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes", containerID)
    memoryLimitPath := fmt.Sprintf("/sys/fs/cgroup/memory/docker/%s/memory.limit_in_bytes", containerID)
    
    // Read memory usage and limit
    metrics.MemoryUsage = mc.readMemoryUsage(containerID)
    metrics.MemoryLimit = mc.readMemoryLimit(containerID)
}

func (mc *MetricsCollector) readMemoryUsage(containerID string) int64 {
    // Read from cgroup memory.usage_in_bytes
    // Mock implementation
    return int64(1024 * 1024 * 512) // 512MB
}

func (mc *MetricsCollector) readMemoryLimit(containerID string) int64 {
    // Read from cgroup memory.limit_in_bytes
    // Mock implementation
    return int64(1024 * 1024 * 1024) // 1GB
}

func (mc *MetricsCollector) collectNetworkMetrics(containerID string, metrics *ContainerMetrics) {
    // Read network stats from /proc/net/dev inside container namespace
    netStats := mc.readNetworkStats(containerID)
    metrics.NetworkRx = netStats.RxBytes
    metrics.NetworkTx = netStats.TxBytes
}

type NetworkStats struct {
    RxBytes uint64
    TxBytes uint64
}

func (mc *MetricsCollector) readNetworkStats(containerID string) NetworkStats {
    // Read from container's network namespace
    // Mock implementation
    return NetworkStats{
        RxBytes: uint64(time.Now().Unix() * 1024),
        TxBytes: uint64(time.Now().Unix() * 512),
    }
}

func (mc *MetricsCollector) collectDiskMetrics(containerID string, metrics *ContainerMetrics) {
    // Read I/O stats from cgroup blkio
    ioStats := mc.readDiskIOStats(containerID)
    metrics.DiskRead = ioStats.ReadBytes
    metrics.DiskWrite = ioStats.WriteBytes
}

type DiskIOStats struct {
    ReadBytes  uint64
    WriteBytes uint64
}

func (mc *MetricsCollector) readDiskIOStats(containerID string) DiskIOStats {
    // Read from /sys/fs/cgroup/blkio/docker/{containerID}/blkio.throttle.io_service_bytes
    // Mock implementation
    return DiskIOStats{
        ReadBytes:  uint64(time.Now().Unix() * 2048),
        WriteBytes: uint64(time.Now().Unix() * 1024),
    }
}

func (mc *MetricsCollector) collectProcessMetrics(containerID string, metrics *ContainerMetrics) {
    // Count processes and threads in container
    processInfo := mc.getProcessInfo(containerID)
    metrics.ProcessCount = processInfo.ProcessCount
    metrics.ThreadCount = processInfo.ThreadCount
    metrics.FileDescriptors = processInfo.FileDescriptors
}

type ProcessInfo struct {
    ProcessCount    int
    ThreadCount     int
    FileDescriptors int
}

func (mc *MetricsCollector) getProcessInfo(containerID string) ProcessInfo {
    // Read from /proc inside container or from cgroup pids
    // Mock implementation
    return ProcessInfo{
        ProcessCount:    5,
        ThreadCount:     20,
        FileDescriptors: 100,
    }
}

func (mc *MetricsCollector) collectCustomMetrics(containerID string, metrics *ContainerMetrics) {
    // Collect application-specific metrics
    customMetrics := mc.getCustomMetrics(containerID)
    for name, value := range customMetrics {
        metrics.CustomMetrics[name] = value
    }
}

func (mc *MetricsCollector) getCustomMetrics(containerID string) map[string]float64 {
    // Read custom metrics from application endpoints or files
    // Mock implementation
    return map[string]float64{
        "response_time_ms":    float64(time.Now().Unix() % 100),
        "active_connections":  float64(time.Now().Unix() % 50),
        "queue_length":       float64(time.Now().Unix() % 20),
        "error_rate":         float64(time.Now().Unix() % 5),
    }
}

func (mc *MetricsCollector) updatePrometheusMetrics(metrics *ContainerMetrics) {
    labels := prometheus.Labels{
        "container_id":   metrics.ID,
        "container_name": metrics.Name,
    }

    // Update basic metrics
    mc.cpuUsage.With(labels).Set(metrics.CPUUsage)
    mc.memoryUsage.With(labels).Set(float64(metrics.MemoryUsage))
    
    // Update network metrics
    mc.networkIO.With(prometheus.Labels{
        "container_id":   metrics.ID,
        "container_name": metrics.Name,
        "direction":      "rx",
    }).Add(float64(metrics.NetworkRx))
    
    mc.networkIO.With(prometheus.Labels{
        "container_id":   metrics.ID,
        "container_name": metrics.Name,
        "direction":      "tx",
    }).Add(float64(metrics.NetworkTx))
    
    // Update disk I/O metrics
    mc.diskIO.With(prometheus.Labels{
        "container_id":   metrics.ID,
        "container_name": metrics.Name,
        "operation":      "read",
    }).Add(float64(metrics.DiskRead))
    
    mc.diskIO.With(prometheus.Labels{
        "container_id":   metrics.ID,
        "container_name": metrics.Name,
        "operation":      "write",
    }).Add(float64(metrics.DiskWrite))
    
    // Update custom metrics
    for metricName, value := range metrics.CustomMetrics {
        mc.customMetrics.With(prometheus.Labels{
            "container_id":   metrics.ID,
            "container_name": metrics.Name,
            "metric_name":    metricName,
        }).Set(value)
    }
}

func (mc *MetricsCollector) getRunningContainers() ([]string, error) {
    // Get list of running containers
    // Mock implementation
    return []string{"container1", "container2", "container3"}, nil
}

func (mc *MetricsCollector) GetMetrics(containerID string) (*ContainerMetrics, error) {
    mc.mutex.RLock()
    defer mc.mutex.RUnlock()
    
    metrics, exists := mc.containers[containerID]
    if !exists {
        return nil, fmt.Errorf("metrics not found for container %s", containerID)
    }
    
    return metrics, nil
}

func (mc *MetricsCollector) GetAllMetrics() map[string]*ContainerMetrics {
    mc.mutex.RLock()
    defer mc.mutex.RUnlock()
    
    result := make(map[string]*ContainerMetrics)
    for id, metrics := range mc.containers {
        result[id] = metrics
    }
    
    return result
}
```

### Distributed Tracing System
```python
#!/usr/bin/env python3
# distributed-tracing.py - Custom distributed tracing for containers

import time
import json
import uuid
import threading
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
import asyncio
import aiohttp

@dataclass
class Span:
    trace_id: str
    span_id: str
    parent_span_id: Optional[str]
    operation_name: str
    start_time: float
    end_time: Optional[float]
    duration: Optional[float]
    tags: Dict[str, str]
    logs: List[Dict]
    container_id: str
    service_name: str

class DistributedTracer:
    def __init__(self, service_name: str, container_id: str):
        self.service_name = service_name
        self.container_id = container_id
        self.active_spans: Dict[str, Span] = {}
        self.completed_spans: List[Span] = []
        self.span_processors = []
        
    def start_span(self, operation_name: str, parent_span_id: Optional[str] = None, 
                   trace_id: Optional[str] = None) -> Span:
        """Start a new span"""
        
        if not trace_id:
            trace_id = str(uuid.uuid4())
            
        span = Span(
            trace_id=trace_id,
            span_id=str(uuid.uuid4()),
            parent_span_id=parent_span_id,
            operation_name=operation_name,
            start_time=time.time(),
            end_time=None,
            duration=None,
            tags={},
            logs=[],
            container_id=self.container_id,
            service_name=self.service_name
        )
        
        self.active_spans[span.span_id] = span
        return span
        
    def finish_span(self, span: Span):
        """Finish a span"""
        
        span.end_time = time.time()
        span.duration = span.end_time - span.start_time
        
        # Remove from active spans
        if span.span_id in self.active_spans:
            del self.active_spans[span.span_id]
            
        # Add to completed spans
        self.completed_spans.append(span)
        
        # Process span
        for processor in self.span_processors:
            processor.process_span(span)
            
    def add_tag(self, span: Span, key: str, value: str):
        """Add tag to span"""
        span.tags[key] = value
        
    def add_log(self, span: Span, message: str, level: str = "info"):
        """Add log entry to span"""
        span.logs.append({
            'timestamp': time.time(),
            'level': level,
            'message': message
        })
        
    def inject_context(self, span: Span) -> Dict[str, str]:
        """Inject tracing context for propagation"""
        return {
            'trace-id': span.trace_id,
            'span-id': span.span_id,
            'service-name': self.service_name,
            'container-id': self.container_id
        }
        
    def extract_context(self, headers: Dict[str, str]) -> Optional[Dict[str, str]]:
        """Extract tracing context from headers"""
        if 'trace-id' in headers:
            return {
                'trace_id': headers['trace-id'],
                'parent_span_id': headers.get('span-id'),
                'parent_service': headers.get('service-name'),
                'parent_container': headers.get('container-id')
            }
        return None

class SpanProcessor:
    def process_span(self, span: Span):
        raise NotImplementedError

class ConsoleSpanProcessor(SpanProcessor):
    def process_span(self, span: Span):
        print(f"Span completed: {span.operation_name} ({span.duration:.3f}s)")

class JaegerSpanProcessor(SpanProcessor):
    def __init__(self, jaeger_endpoint: str):
        self.jaeger_endpoint = jaeger_endpoint
        
    def process_span(self, span: Span):
        """Send span to Jaeger"""
        jaeger_span = self.convert_to_jaeger_format(span)
        asyncio.create_task(self.send_to_jaeger(jaeger_span))
        
    def convert_to_jaeger_format(self, span: Span) -> Dict:
        """Convert span to Jaeger format"""
        return {
            'traceID': span.trace_id.replace('-', ''),
            'spanID': span.span_id.replace('-', ''),
            'parentSpanID': span.parent_span_id.replace('-', '') if span.parent_span_id else None,
            'operationName': span.operation_name,
            'startTime': int(span.start_time * 1000000),  # microseconds
            'duration': int(span.duration * 1000000) if span.duration else 0,
            'tags': [{'key': k, 'value': v} for k, v in span.tags.items()],
            'logs': [
                {
                    'timestamp': int(log['timestamp'] * 1000000),
                    'fields': [
                        {'key': 'level', 'value': log['level']},
                        {'key': 'message', 'value': log['message']}
                    ]
                }
                for log in span.logs
            ],
            'process': {
                'serviceName': span.service_name,
                'tags': [
                    {'key': 'container.id', 'value': span.container_id}
                ]
            }
        }
        
    async def send_to_jaeger(self, jaeger_span: Dict):
        """Send span to Jaeger collector"""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.post(
                    f"{self.jaeger_endpoint}/api/traces",
                    json={'data': [jaeger_span]}
                ) as response:
                    if response.status != 200:
                        print(f"Failed to send span to Jaeger: {response.status}")
        except Exception as e:
            print(f"Error sending span to Jaeger: {e}")

class ContainerTraceCollector:
    def __init__(self):
        self.tracers: Dict[str, DistributedTracer] = {}
        self.trace_storage = {}
        
    def get_tracer(self, service_name: str, container_id: str) -> DistributedTracer:
        """Get or create tracer for service/container"""
        key = f"{service_name}:{container_id}"
        
        if key not in self.tracers:
            tracer = DistributedTracer(service_name, container_id)
            
            # Add processors
            tracer.span_processors.append(ConsoleSpanProcessor())
            tracer.span_processors.append(JaegerSpanProcessor("http://jaeger:14268"))
            
            self.tracers[key] = tracer
            
        return self.tracers[key]
        
    def collect_container_traces(self, container_id: str) -> List[Span]:
        """Collect all traces for a container"""
        traces = []
        
        for tracer in self.tracers.values():
            if tracer.container_id == container_id:
                traces.extend(tracer.completed_spans)
                
        return traces
        
    def analyze_trace_performance(self, trace_id: str) -> Dict:
        """Analyze performance of a distributed trace"""
        
        # Collect all spans for trace
        trace_spans = []
        for tracer in self.tracers.values():
            for span in tracer.completed_spans:
                if span.trace_id == trace_id:
                    trace_spans.append(span)
                    
        if not trace_spans:
            return {'error': 'Trace not found'}
            
        # Build trace tree
        trace_tree = self.build_trace_tree(trace_spans)
        
        # Calculate metrics
        total_duration = max(span.end_time for span in trace_spans) - min(span.start_time for span in trace_spans)
        
        service_durations = {}
        for span in trace_spans:
            if span.service_name not in service_durations:
                service_durations[span.service_name] = 0
            service_durations[span.service_name] += span.duration or 0
            
        return {
            'trace_id': trace_id,
            'total_duration': total_duration,
            'span_count': len(trace_spans),
            'service_count': len(set(span.service_name for span in trace_spans)),
            'container_count': len(set(span.container_id for span in trace_spans)),
            'service_durations': service_durations,
            'critical_path': self.find_critical_path(trace_tree),
            'bottlenecks': self.identify_bottlenecks(trace_spans)
        }
        
    def build_trace_tree(self, spans: List[Span]) -> Dict:
        """Build hierarchical trace tree"""
        span_map = {span.span_id: span for span in spans}
        root_spans = []
        
        for span in spans:
            if span.parent_span_id is None:
                root_spans.append(span)
            elif span.parent_span_id in span_map:
                parent = span_map[span.parent_span_id]
                if not hasattr(parent, 'children'):
                    parent.children = []
                parent.children.append(span)
                
        return {'roots': root_spans, 'span_map': span_map}
        
    def find_critical_path(self, trace_tree: Dict) -> List[str]:
        """Find critical path through trace"""
        
        def find_longest_path(span, current_path, current_duration):
            path_with_span = current_path + [span.span_id]
            duration_with_span = current_duration + (span.duration or 0)
            
            if not hasattr(span, 'children') or not span.children:
                return path_with_span, duration_with_span
                
            longest_path = path_with_span
            longest_duration = duration_with_span
            
            for child in span.children:
                child_path, child_duration = find_longest_path(child, path_with_span, duration_with_span)
                if child_duration > longest_duration:
                    longest_path = child_path
                    longest_duration = child_duration
                    
            return longest_path, longest_duration
            
        critical_path = []
        max_duration = 0
        
        for root in trace_tree['roots']:
            path, duration = find_longest_path(root, [], 0)
            if duration > max_duration:
                critical_path = path
                max_duration = duration
                
        return critical_path
        
    def identify_bottlenecks(self, spans: List[Span]) -> List[Dict]:
        """Identify performance bottlenecks"""
        
        # Sort spans by duration
        sorted_spans = sorted(spans, key=lambda s: s.duration or 0, reverse=True)
        
        # Calculate statistics
        durations = [s.duration or 0 for s in spans]
        avg_duration = sum(durations) / len(durations)
        
        bottlenecks = []
        for span in sorted_spans[:5]:  # Top 5 slowest spans
            if span.duration and span.duration > avg_duration * 2:
                bottlenecks.append({
                    'span_id': span.span_id,
                    'operation': span.operation_name,
                    'service': span.service_name,
                    'container': span.container_id,
                    'duration': span.duration,
                    'severity': 'high' if span.duration > avg_duration * 5 else 'medium'
                })
                
        return bottlenecks

# Example usage and instrumentation
class InstrumentedHTTPClient:
    def __init__(self, tracer: DistributedTracer):
        self.tracer = tracer
        
    async def make_request(self, url: str, method: str = 'GET', 
                          parent_span: Optional[Span] = None) -> Dict:
        """Make instrumented HTTP request"""
        
        # Start span for HTTP request
        span = self.tracer.start_span(
            f"HTTP {method}",
            parent_span_id=parent_span.span_id if parent_span else None,
            trace_id=parent_span.trace_id if parent_span else None
        )
        
        # Add tags
        self.tracer.add_tag(span, 'http.method', method)
        self.tracer.add_tag(span, 'http.url', url)
        
        try:
            # Inject tracing context
            headers = self.tracer.inject_context(span)
            
            # Make request
            async with aiohttp.ClientSession() as session:
                async with session.request(method, url, headers=headers) as response:
                    # Add response tags
                    self.tracer.add_tag(span, 'http.status_code', str(response.status))
                    
                    if response.status >= 400:
                        self.tracer.add_tag(span, 'error', 'true')
                        self.tracer.add_log(span, f"HTTP error: {response.status}", 'error')
                        
                    result = await response.json()
                    
        except Exception as e:
            self.tracer.add_tag(span, 'error', 'true')
            self.tracer.add_log(span, f"Request failed: {str(e)}", 'error')
            raise
        finally:
            self.tracer.finish_span(span)
            
        return result

async def main():
    # Initialize trace collector
    collector = ContainerTraceCollector()
    
    # Get tracer for service
    tracer = collector.get_tracer('web-service', 'container-123')
    
    # Create instrumented HTTP client
    http_client = InstrumentedHTTPClient(tracer)
    
    # Start root span
    root_span = tracer.start_span('handle_request')
    tracer.add_tag(root_span, 'request.id', 'req-456')
    
    try:
        # Make downstream requests
        await http_client.make_request('http://api-service/users', parent_span=root_span)
        await http_client.make_request('http://db-service/query', parent_span=root_span)
        
    finally:
        tracer.finish_span(root_span)
    
    # Analyze trace performance
    analysis = collector.analyze_trace_performance(root_span.trace_id)
    print(json.dumps(analysis, indent=2))

if __name__ == "__main__":
    asyncio.run(main())
```
