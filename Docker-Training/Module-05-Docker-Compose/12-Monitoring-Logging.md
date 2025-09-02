# Monitoring and Logging with Docker Compose

## Table of Contents
1. [Monitoring Stack Setup](#monitoring-stack-setup)
2. [Prometheus Configuration](#prometheus-configuration)
3. [Grafana Dashboards](#grafana-dashboards)
4. [Log Aggregation](#log-aggregation)
5. [Alerting Systems](#alerting-systems)
6. [Application Metrics](#application-metrics)

## Monitoring Stack Setup

### Complete Monitoring Stack
```yaml
version: '3.8'

services:
  # Application with metrics
  app:
    image: myapp:latest
    environment:
      - METRICS_ENABLED=true
      - METRICS_PORT=9090
    ports:
      - "3000:3000"
      - "9090:9090"
    networks:
      - app-network
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"
      - "prometheus.path=/metrics"

  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9091:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules:/etc/prometheus/rules:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'

  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./grafana/datasources:/etc/grafana/provisioning/datasources:ro
    networks:
      - monitoring

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
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  app-network:
    driver: bridge
  monitoring:
    driver: bridge
```

## Prometheus Configuration

### prometheus.yml
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "/etc/prometheus/rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'docker-containers'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: [__meta_docker_container_label_prometheus_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_docker_container_label_prometheus_port]
        action: replace
        target_label: __address__
        regex: (.+)
        replacement: ${1}
```

## Log Aggregation

### ELK Stack Setup
```yaml
version: '3.8'

services:
  # Elasticsearch
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - elk

  # Logstash
  logstash:
    image: logstash:8.8.0
    volumes:
      - ./logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    ports:
      - "5000:5000"
      - "9600:9600"
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  # Kibana
  kibana:
    image: kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    networks:
      - elk
    depends_on:
      - elasticsearch

  # Filebeat
  filebeat:
    image: elastic/filebeat:8.8.0
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - elk
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:

networks:
  elk:
    driver: bridge
```

### Loki Stack (Alternative)
```yaml
version: '3.8'

services:
  # Loki
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki.yml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    networks:
      - logging

  # Promtail
  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./promtail/promtail.yml:/etc/promtail/config.yml:ro
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    networks:
      - logging
    depends_on:
      - loki

  # Grafana with Loki
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - logging

volumes:
  loki_data:
  grafana_data:

networks:
  logging:
    driver: bridge
```

## Alerting Systems

### AlertManager Configuration
```yaml
version: '3.8'

services:
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    networks:
      - monitoring
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.external-url=http://localhost:9093'

networks:
  monitoring:
    external: true
```

### alertmanager.yml
```yaml
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  email_configs:
  - to: 'admin@company.com'
    subject: 'Alert: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      Alert: {{ .Annotations.summary }}
      Description: {{ .Annotations.description }}
      {{ end }}
  
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#alerts'
    title: 'Alert: {{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

## Application Metrics

### Custom Application Metrics
```yaml
version: '3.8'

services:
  # Node.js app with Prometheus metrics
  nodejs-app:
    build: ./nodejs-app
    ports:
      - "3000:3000"
      - "9090:9090"
    environment:
      - METRICS_PORT=9090
    networks:
      - app-network
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9090"

  # Python app with metrics
  python-app:
    build: ./python-app
    ports:
      - "8000:8000"
      - "9091:9091"
    environment:
      - METRICS_PORT=9091
    networks:
      - app-network
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9091"

networks:
  app-network:
    driver: bridge
  monitoring:
    external: true
```

### Node.js Metrics Implementation
```javascript
// metrics.js
const promClient = require('prom-client');

// Create a Registry
const register = new promClient.Registry();

// Add default metrics
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestTotal);

module.exports = { register, httpRequestDuration, httpRequestTotal };
```

### Database Monitoring
```yaml
version: '3.8'

services:
  # PostgreSQL with exporter
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    networks:
      - db-network

  # PostgreSQL Exporter
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    environment:
      DATA_SOURCE_NAME: "postgresql://user:pass@postgres:5432/myapp?sslmode=disable"
    ports:
      - "9187:9187"
    networks:
      - db-network
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9187"
    depends_on:
      - postgres

  # Redis with exporter
  redis:
    image: redis:alpine
    networks:
      - cache-network

  # Redis Exporter
  redis-exporter:
    image: oliver006/redis_exporter:latest
    environment:
      REDIS_ADDR: "redis://redis:6379"
    ports:
      - "9121:9121"
    networks:
      - cache-network
      - monitoring
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=9121"
    depends_on:
      - redis

networks:
  db-network:
    driver: bridge
  cache-network:
    driver: bridge
  monitoring:
    external: true
```

This comprehensive monitoring and logging guide provides complete observability for Docker Compose applications with metrics collection, log aggregation, and alerting systems.
