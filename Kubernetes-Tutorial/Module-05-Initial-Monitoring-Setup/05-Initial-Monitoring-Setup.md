# 📊 **Module 5: Initial Monitoring Setup (Prometheus & Grafana)**
## Essential Monitoring Skills for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 2-3 hours  
**Prerequisites**: Basic understanding of system monitoring  
**Learning Objectives**: Master monitoring setup essential for Kubernetes

### **🛠️ Tools Covered**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Node Exporter**: Node-level metrics collection
- **cAdvisor**: Container metrics collection
- **AlertManager**: Alerting and notification management

### **🏭 Industry Tools**
- **Datadog**: Cloud-based monitoring and analytics
- **New Relic**: Application performance monitoring
- **Splunk**: Log analysis and monitoring
- **Dynatrace**: Application performance monitoring
- **CloudWatch**: AWS cloud monitoring
- **Azure Monitor**: Microsoft Azure monitoring

### **🌍 Environment Strategy**
This module prepares monitoring skills for all environments:
- **DEV**: Development monitoring with basic metrics
- **UAT**: User Acceptance Testing monitoring with full stack
- **PROD**: Production monitoring with comprehensive alerting

### **💥 Chaos Engineering**
- **Monitoring system failure testing**: Testing behavior under monitoring failures
- **Alert fatigue simulation**: Testing alert management under high alert volume
- **Metrics collection disruption**: Testing application behavior when metrics are unavailable
- **Dashboard corruption testing**: Testing monitoring system resilience

### **Chaos Packages**
- **None (manual monitoring disruption testing)**: Manual testing with monitoring system failures

---

## 🎯 **Learning Objectives**

By the end of this module, you will:
- Master Prometheus metrics collection and configuration
- Understand Grafana dashboard creation and management
- Learn alerting and notification setup
- Master monitoring best practices and patterns
- Understand observability principles and implementation
- Apply monitoring concepts to Kubernetes cluster management
- Implement chaos engineering scenarios for monitoring resilience

---

## 📚 **Theory Section: Monitoring Fundamentals**

### **Why Monitoring for Kubernetes?**

Kubernetes clusters require comprehensive monitoring for:
- **Cluster Health**: Node status, pod health, resource utilization
- **Application Performance**: Response times, error rates, throughput
- **Resource Management**: CPU, memory, storage usage and limits
- **Security**: Unusual activity, policy violations, access patterns
- **Cost Optimization**: Resource efficiency, unused resources
- **Incident Response**: Quick problem identification and resolution

### **Monitoring Stack Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                        │
├─────────────────────────────────────────────────────────────┤
│  Grafana (Visualization & Dashboards)                      │
├─────────────────────────────────────────────────────────────┤
│  AlertManager (Alerting & Notifications)                   │
├─────────────────────────────────────────────────────────────┤
│  Prometheus (Metrics Collection & Storage)                 │
├─────────────────────────────────────────────────────────────┤
│  Node Exporter (Node Metrics)                              │
│  cAdvisor (Container Metrics)                              │
│  Application Metrics (Custom Metrics)                      │
└─────────────────────────────────────────────────────────────┘
```

### **Essential Monitoring Concepts**

#### **1. Metrics Types**
- **Counter**: Monotonically increasing values (requests, errors)
- **Gauge**: Values that can go up or down (memory usage, active connections)
- **Histogram**: Distribution of values (response times, request sizes)
- **Summary**: Quantiles and counts (percentiles, averages)

#### **2. Monitoring Layers**
- **Infrastructure**: CPU, memory, disk, network
- **Platform**: Kubernetes cluster, nodes, pods
- **Application**: Business metrics, performance metrics
- **User Experience**: Response times, error rates, availability

#### **3. Alerting Principles**
- **Alert Rules**: Conditions that trigger alerts
- **Alert Severity**: Critical, warning, info levels
- **Alert Routing**: Different channels for different severities
- **Alert Fatigue**: Avoiding too many false positives

#### **4. Observability Pillars**
- **Metrics**: Quantitative data about system behavior
- **Logs**: Event records with timestamps
- **Traces**: Request flow through distributed systems
- **Profiles**: Detailed performance analysis

---

## 🔧 **Hands-on Lab: Monitoring Setup**

### **Lab 1: Prometheus Installation and Configuration**

**📋 Overview**: Set up Prometheus for metrics collection and storage.

**🔍 Detailed Installation Analysis**:

```bash
# Create monitoring namespace
kubectl create namespace monitoring
```

**Explanation**:
- `kubectl create namespace monitoring`: Create dedicated namespace for monitoring
- **Purpose**: Isolate monitoring components from application workloads

```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "alert_rules.yml"
    
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - source_labels: [__address__]
            regex: '(.*):10250'
            target_label: __address__
            replacement: '${1}:9100'
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
```

**Explanation**:
- `global:`: Global configuration for Prometheus
- `scrape_interval: 15s`: How often to scrape metrics
- `evaluation_interval: 15s`: How often to evaluate alert rules
- `rule_files:`: Alert rules configuration
- `alerting:`: AlertManager configuration
- `scrape_configs:`: Targets to scrape metrics from
- **Purpose**: Configure Prometheus to collect metrics from various sources

```yaml
# prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-pvc
```

**Explanation**:
- `image: prom/prometheus:latest`: Official Prometheus image
- `--config.file=/etc/prometheus/prometheus.yml`: Configuration file path
- `--storage.tsdb.path=/prometheus`: Metrics storage path
- `--storage.tsdb.retention.time=200h`: Data retention period
- `--web.enable-lifecycle`: Enable configuration reloading
- **Purpose**: Deploy Prometheus with persistent storage and configuration

### **Lab 2: Grafana Installation and Dashboard Setup**

**📋 Overview**: Set up Grafana for metrics visualization and dashboard creation.

**🔍 Detailed Installation Analysis**:

```yaml
# grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-piechart-panel"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning/datasources
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-config
        configMap:
          name: grafana-datasources
```

**Explanation**:
- `image: grafana/grafana:latest`: Official Grafana image
- `GF_SECURITY_ADMIN_PASSWORD: "admin123"`: Admin password
- `GF_INSTALL_PLUGINS`: Additional plugins to install
- `volumeMounts:`: Persistent storage for Grafana data
- **Purpose**: Deploy Grafana with persistent storage and configuration

```yaml
# grafana-datasources.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  prometheus.yaml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus:9090
        access: proxy
        isDefault: true
```

**Explanation**:
- `type: prometheus`: Data source type
- `url: http://prometheus:9090`: Prometheus service URL
- `access: proxy`: Access mode (proxy or direct)
- `isDefault: true`: Set as default data source
- **Purpose**: Configure Prometheus as data source for Grafana

```bash
# Access Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Access: http://localhost:3000
# Username: admin
# Password: admin123
```

**Explanation**:
- `kubectl port-forward`: Forward local port to Grafana service
- **Purpose**: Access Grafana web interface for dashboard creation

### **Lab 3: Node Exporter and cAdvisor Setup**

**📋 Overview**: Set up node and container metrics collection.

**🔍 Detailed Setup Analysis**:

```yaml
# node-exporter-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        args:
          - '--path.procfs=/host/proc'
          - '--path.sysfs=/host/sys'
          - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
```

**Explanation**:
- `kind: DaemonSet`: Deploy one pod per node
- `hostNetwork: true`: Use host network for node metrics
- `hostPID: true`: Access host process information
- `--path.procfs=/host/proc`: Path to host proc filesystem
- `--path.sysfs=/host/sys`: Path to host sys filesystem
- **Purpose**: Collect node-level metrics from all cluster nodes

```yaml
# cadvisor-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cadvisor
  namespace: monitoring
  labels:
    app: cadvisor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cadvisor
  template:
    metadata:
      labels:
        app: cadvisor
    spec:
      containers:
      - name: cadvisor
        image: gcr.io/cadvisor/cadvisor:latest
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
        - name: var-run
          mountPath: /var/run
          readOnly: true
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: docker
          mountPath: /var/lib/docker
          readOnly: true
        - name: disk
          mountPath: /dev/disk
          readOnly: true
      volumes:
      - name: rootfs
        hostPath:
          path: /
      - name: var-run
        hostPath:
          path: /var/run
      - name: sys
        hostPath:
          path: /sys
      - name: docker
        hostPath:
          path: /var/lib/docker
      - name: disk
        hostPath:
          path: /dev/disk
```

**Explanation**:
- `image: gcr.io/cadvisor/cadvisor:latest`: cAdvisor container image
- `volumeMounts:`: Mount host filesystems for container metrics
- **Purpose**: Collect container-level metrics and resource usage

### **Lab 4: AlertManager Configuration**

**📋 Overview**: Set up alerting and notification management.

**🔍 Detailed Configuration Analysis**:

```yaml
# alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alerts@ecommerce.com'
    
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://webhook:5001/'
    
    - name: 'critical-alerts'
      email_configs:
      - to: 'admin@ecommerce.com'
        subject: 'Critical Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    
    - name: 'warning-alerts'
      email_configs:
      - to: 'team@ecommerce.com'
        subject: 'Warning Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

**Explanation**:
- `global:`: Global configuration for AlertManager
- `route:`: Alert routing configuration
- `group_by: ['alertname']`: Group alerts by alert name
- `group_wait: 10s`: Wait time before sending grouped alerts
- `receivers:`: Alert notification channels
- **Purpose**: Configure alert routing and notification channels

```yaml
# alert-rules.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alert-rules
  namespace: monitoring
data:
  alert_rules.yml: |
    groups:
    - name: ecommerce-alerts
      rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"
      
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 5 minutes"
      
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.pod }} is restarting frequently"
```

**Explanation**:
- `groups:`: Alert rule groups
- `alert: HighCPUUsage`: Alert name
- `expr:`: PromQL expression for alert condition
- `for: 5m`: Duration before alert fires
- `labels:`: Alert labels for routing
- `annotations:`: Alert description and summary
- **Purpose**: Define alert rules for monitoring system health

### **Lab 5: E-commerce Application Monitoring**

**📋 Overview**: Set up monitoring for your e-commerce application.

**🔍 Detailed Application Monitoring Analysis**:

```yaml
# ecommerce-backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: default
  labels:
    app: ecommerce-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: PROMETHEUS_MULTIPROC_DIR
          value: "/tmp"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Explanation**:
- `prometheus.io/scrape: "true"`: Enable Prometheus scraping
- `prometheus.io/port: "8000"`: Metrics port
- `prometheus.io/path: "/metrics"`: Metrics endpoint path
- `PROMETHEUS_MULTIPROC_DIR: "/tmp"`: Prometheus multiprocess directory
- `livenessProbe:`: Health check for container liveness
- `readinessProbe:`: Health check for container readiness
- **Purpose**: Configure e-commerce backend for monitoring

```python
# Add to your FastAPI backend (main.py)
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi import FastAPI, Request
import time

app = FastAPI()

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_DURATION.observe(process_time)
    
    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/ready")
async def ready():
    return {"status": "ready"}
```

**Explanation**:
- `from prometheus_client import Counter, Histogram`: Import Prometheus metrics
- `REQUEST_COUNT`: Counter for HTTP requests
- `REQUEST_DURATION`: Histogram for request duration
- `@app.middleware("http")`: Middleware to collect metrics
- `@app.get("/metrics")`: Metrics endpoint for Prometheus
- **Purpose**: Add Prometheus metrics to your e-commerce backend

---

## 🎯 **Practice Problems**

### **Problem 1: Monitoring Stack Setup**

**Scenario**: Set up complete monitoring stack for your e-commerce application.

**Requirements**:
1. Install Prometheus with configuration
2. Set up Grafana with dashboards
3. Configure Node Exporter and cAdvisor
4. Set up AlertManager with alert rules

**Expected Output**:
- Complete monitoring stack deployment
- Grafana dashboards for system and application metrics
- Alert rules for critical system events
- Monitoring documentation

### **Problem 2: Custom Metrics Implementation**

**Scenario**: Add custom metrics to your e-commerce application.

**Requirements**:
1. Add Prometheus metrics to backend
2. Create custom dashboards in Grafana
3. Set up alerting for business metrics
4. Test metrics collection and visualization

**Expected Output**:
- Custom metrics implementation
- Grafana dashboards for business metrics
- Alert rules for business events
- Metrics testing documentation

### **Problem 3: Alerting and Notification Setup**

**Scenario**: Configure comprehensive alerting for your e-commerce application.

**Requirements**:
1. Create alert rules for system metrics
2. Set up alert rules for application metrics
3. Configure notification channels
4. Test alerting system

**Expected Output**:
- Alert rules configuration
- Notification channel setup
- Alert testing results
- Alerting documentation

### **Problem 4: Chaos Engineering Scenarios**

**Scenario**: Test your e-commerce application's monitoring resilience.

**Requirements**:
1. **Monitoring System Failure Testing**:
   - Simulate Prometheus failures
   - Test application behavior under monitoring failures
   - Monitor recovery mechanisms

2. **Alert Fatigue Simulation**:
   - Generate high volume of alerts
   - Test alert management under high alert volume
   - Monitor alert handling efficiency

3. **Metrics Collection Disruption**:
   - Simulate metrics collection failures
   - Test application behavior when metrics are unavailable
   - Monitor system resilience

4. **Dashboard Corruption Testing**:
   - Simulate dashboard failures
   - Test monitoring system resilience
   - Monitor recovery procedures

**Expected Output**:
- Monitoring chaos engineering test results
- Failure mode analysis
- Recovery time measurements
- Monitoring resilience recommendations

---

## 📝 **Assessment Quiz**

### **Multiple Choice Questions**

1. **What is the default port for Prometheus?**
   - A) 3000
   - B) 9090
   - C) 8080
   - D) 9100

2. **Which tool collects node-level metrics?**
   - A) cAdvisor
   - B) Node Exporter
   - C) Prometheus
   - D) Grafana

3. **What is the purpose of AlertManager?**
   - A) Metrics collection
   - B) Dashboard creation
   - C) Alert routing and notification
   - D) Data storage

### **Practical Questions**

4. **Explain the difference between metrics, logs, and traces.**

5. **How would you set up alerting for high CPU usage?**

6. **What are the benefits of using Grafana for monitoring?**

---

## 🚀 **Mini-Project: E-commerce Monitoring System**

### **Project Requirements**

Implement comprehensive monitoring for your e-commerce application:

1. **Monitoring Stack Setup**
   - Deploy Prometheus with configuration
   - Set up Grafana with dashboards
   - Configure Node Exporter and cAdvisor
   - Set up AlertManager with alert rules

2. **Application Monitoring**
   - Add custom metrics to backend
   - Create application dashboards
   - Set up business metrics monitoring
   - Implement health checks

3. **Alerting and Notification**
   - Create alert rules for system metrics
   - Set up alert rules for application metrics
   - Configure notification channels
   - Test alerting system

4. **Chaos Engineering Implementation**
   - Design monitoring failure scenarios
   - Implement resilience testing
   - Create monitoring and alerting
   - Document failure modes and recovery procedures

### **Deliverables**

- **Monitoring Stack**: Complete Prometheus and Grafana setup
- **Application Metrics**: Custom metrics implementation
- **Dashboards**: System and application dashboards
- **Alerting System**: Comprehensive alerting configuration
- **Chaos Engineering Report**: Monitoring resilience testing results
- **Documentation**: Complete monitoring setup guide

---

## 🎤 **Interview Questions and Answers**

### **Q1: How would you set up monitoring for a Kubernetes cluster?**

**Answer**:
Comprehensive Kubernetes monitoring setup:

1. **Prometheus Configuration**:
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):10250'
        target_label: __address__
        replacement: '${1}:9100'
  
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

2. **Node Exporter DaemonSet**:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    spec:
      hostNetwork: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
```

3. **Grafana Dashboard**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Kubernetes Cluster Monitoring",
        "panels": [
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
              }
            ]
          }
        ]
      }
    }
```

4. **Alert Rules**:
```yaml
groups:
- name: kubernetes-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
```

**Best Practices**:
- **Comprehensive Coverage**: Monitor infrastructure, platform, and application
- **Alert Tuning**: Set appropriate thresholds and durations
- **Dashboard Design**: Create clear, actionable dashboards
- **Documentation**: Document monitoring setup and procedures

### **Q2: How would you implement custom metrics for an application?**

**Answer**:
Custom metrics implementation approach:

1. **Add Metrics to Application**:
```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Define custom metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_DURATION.observe(process_time)
    
    return response
```

2. **Expose Metrics Endpoint**:
```python
@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

3. **Configure Prometheus Scraping**:
```yaml
# Add to pod annotations
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8000"
    prometheus.io/path: "/metrics"
```

4. **Create Grafana Dashboard**:
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

5. **Set Up Alerting**:
```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
```

**Best Practices**:
- **Meaningful Metrics**: Choose metrics that provide business value
- **Proper Labeling**: Use labels for filtering and aggregation
- **Performance Impact**: Minimize performance impact of metrics collection
- **Documentation**: Document custom metrics and their purpose

### **Q3: How would you handle alert fatigue in a monitoring system?**

**Answer**:
Comprehensive alert fatigue management:

1. **Alert Tuning**:
```yaml
# Set appropriate thresholds and durations
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m  # Wait 5 minutes before firing
  labels:
    severity: warning
```

2. **Alert Grouping**:
```yaml
# AlertManager configuration
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h  # Reduce repeat frequency
```

3. **Alert Severity Levels**:
```yaml
# Different severity levels
- alert: CriticalCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
  labels:
    severity: critical

- alert: WarningCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  labels:
    severity: warning
```

4. **Alert Routing**:
```yaml
# Route alerts to different channels
receivers:
- name: 'critical-alerts'
  email_configs:
  - to: 'admin@company.com'
    subject: 'Critical Alert: {{ .GroupLabels.alertname }}'

- name: 'warning-alerts'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/...'
    channel: '#alerts'
```

5. **Alert Suppression**:
```yaml
# Suppress alerts during maintenance
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  equal: ['alertname', 'instance']
```

**Best Practices**:
- **Threshold Tuning**: Set realistic thresholds based on historical data
- **Alert Grouping**: Group related alerts to reduce noise
- **Escalation Policies**: Implement escalation for unacknowledged alerts
- **Regular Review**: Regularly review and tune alert rules
- **Documentation**: Document alert procedures and response playbooks

---

## 📈 **Real-world Scenarios**

### **Scenario 1: Production Monitoring Setup**

**Challenge**: Set up comprehensive monitoring for a production e-commerce application.

**Requirements**:
- Monitor infrastructure, platform, and application
- Set up alerting for critical issues
- Create dashboards for different teams
- Implement monitoring best practices

**Solution Approach**:
1. Deploy Prometheus with comprehensive configuration
2. Set up Grafana with role-based dashboards
3. Configure AlertManager with escalation policies
4. Implement custom metrics for business monitoring

### **Scenario 2: Monitoring System Optimization**

**Challenge**: Optimize monitoring system performance and reduce alert fatigue.

**Requirements**:
- Optimize Prometheus performance
- Reduce false positive alerts
- Improve dashboard performance
- Implement monitoring automation

**Solution Approach**:
1. Optimize Prometheus configuration and storage
2. Tune alert rules and thresholds
3. Implement dashboard caching and optimization
4. Set up automated monitoring maintenance

---

## 🎯 **Module Completion Checklist**

### **Core Monitoring Concepts**
- [ ] Understand monitoring principles and best practices
- [ ] Master Prometheus metrics collection
- [ ] Learn Grafana dashboard creation
- [ ] Understand alerting and notification setup
- [ ] Master observability principles

### **Monitoring Tools**
- [ ] Use Prometheus for metrics collection
- [ ] Create Grafana dashboards
- [ ] Configure AlertManager
- [ ] Set up Node Exporter and cAdvisor
- [ ] Implement custom metrics

### **Application Monitoring**
- [ ] Add metrics to applications
- [ ] Create application dashboards
- [ ] Set up health checks
- [ ] Implement business metrics
- [ ] Monitor application performance

### **Chaos Engineering**
- [ ] Implement monitoring system failure testing
- [ ] Test alert fatigue scenarios
- [ ] Simulate metrics collection disruption
- [ ] Test dashboard corruption scenarios
- [ ] Document monitoring failure modes and recovery procedures

### **Assessment and Practice**
- [ ] Complete all practice problems
- [ ] Pass assessment quiz
- [ ] Complete mini-project
- [ ] Answer interview questions correctly
- [ ] Apply concepts to real-world scenarios

---

## 📚 **Additional Resources**

### **Documentation**
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

### **Tools**
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [cAdvisor](https://github.com/google/cadvisor)

### **Practice Platforms**
- [Prometheus Playground](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Grafana Playground](https://play.grafana.org/)
- [Kubernetes Monitoring Examples](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/prometheus)

---

## 🚀 **Next Steps**

1. **Complete this module** by working through all labs and assessments
2. **Set up monitoring** for your e-commerce application
3. **Create custom dashboards** for your specific needs
4. **Move to Module 6**: Kubernetes Architecture and Components
5. **Prepare for Kubernetes** by understanding monitoring fundamentals

---

**Congratulations! You've completed the Initial Monitoring Setup module. You now have essential monitoring skills for Kubernetes administration. 🎉**
