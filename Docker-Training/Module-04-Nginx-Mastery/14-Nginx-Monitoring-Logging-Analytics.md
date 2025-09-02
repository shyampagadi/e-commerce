# 📊 Nginx Monitoring, Logging & Analytics

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Performance Optimization completed  

Master comprehensive Nginx monitoring, logging, and analytics for production environments, including real-time monitoring, log analysis, and performance metrics.

## 🎯 Learning Objectives

- Configure comprehensive logging and monitoring
- Implement real-time performance monitoring
- Set up log analysis and alerting systems
- Integrate with monitoring tools (Prometheus, Grafana, ELK)
- Create custom analytics and reporting dashboards

## 📚 Logging Configuration

### Advanced Log Formats
```nginx
# Custom log formats for different purposes
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';

log_format detailed '$remote_addr - $remote_user [$time_local] "$request" '
                   '$status $body_bytes_sent "$http_referer" '
                   '"$http_user_agent" "$http_x_forwarded_for" '
                   'rt=$request_time uct="$upstream_connect_time" '
                   'uht="$upstream_header_time" urt="$upstream_response_time"';

log_format json escape=json '{'
                '"timestamp":"$time_iso8601",'
                '"remote_addr":"$remote_addr",'
                '"remote_user":"$remote_user",'
                '"request":"$request",'
                '"status":"$status",'
                '"body_bytes_sent":"$body_bytes_sent",'
                '"http_referer":"$http_referer",'
                '"http_user_agent":"$http_user_agent",'
                '"http_x_forwarded_for":"$http_x_forwarded_for",'
                '"request_time":"$request_time",'
                '"upstream_response_time":"$upstream_response_time",'
                '"upstream_addr":"$upstream_addr",'
                '"upstream_status":"$upstream_status"'
                '}';

log_format security '$remote_addr - [$time_local] "$request" '
                   '$status "$http_user_agent" "$args" '
                   '$geoip_country_code $request_time';

log_format performance '$remote_addr [$time_local] "$request" '
                      '$status $body_bytes_sent $request_time '
                      '$upstream_response_time "$upstream_addr" '
                      '$upstream_cache_status';

http {
    # Default logging
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;
    
    # Include custom log configurations
    include /etc/nginx/conf.d/*.conf;
}
```

### Conditional Logging
```nginx
# Conditional logging based on status codes
map $status $loggable {
    ~^[23]  0;  # Don't log successful requests
    default 1;  # Log errors and redirects
}

# Conditional logging based on request type
map $request_uri $log_api {
    ~^/api/  1;
    default  0;
}

server {
    listen 80;
    server_name monitored.example.com;
    
    # Main access log
    access_log /var/log/nginx/access.log main;
    
    # Error-only logging
    access_log /var/log/nginx/errors.log detailed if=$loggable;
    
    # API-specific logging
    access_log /var/log/nginx/api.log json if=$log_api;
    
    # Security events logging
    access_log /var/log/nginx/security.log security;
    
    # Performance monitoring
    access_log /var/log/nginx/performance.log performance;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # API endpoints with detailed logging
    location /api/ {
        # Log all API requests with detailed format
        access_log /var/log/nginx/api_detailed.log detailed;
        
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📈 Real-Time Monitoring

### Nginx Status Module
```nginx
# Status monitoring server
server {
    listen 8080;
    server_name localhost;
    
    # Restrict access
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    # Basic status
    location /nginx_status {
        stub_status on;
        access_log off;
    }
    
    # Extended status (requires additional modules)
    location /status {
        # Custom status page
        return 200 '{"status":"healthy","timestamp":"$time_iso8601","connections":{"active":"$connections_active","reading":"$connections_reading","writing":"$connections_writing","waiting":"$connections_waiting"}}';
        add_header Content-Type application/json;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Custom Metrics Collection
```bash
#!/bin/bash
# nginx-metrics-collector.sh - Collect Nginx metrics

NGINX_STATUS_URL="http://localhost:8080/nginx_status"
METRICS_FILE="/var/log/nginx/metrics.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Collect basic metrics
METRICS=$(curl -s $NGINX_STATUS_URL)

if [ $? -eq 0 ]; then
    # Parse nginx status
    ACTIVE=$(echo "$METRICS" | grep "Active connections" | awk '{print $3}')
    ACCEPTS=$(echo "$METRICS" | awk 'NR==3 {print $1}')
    HANDLED=$(echo "$METRICS" | awk 'NR==3 {print $2}')
    REQUESTS=$(echo "$METRICS" | awk 'NR==3 {print $3}')
    READING=$(echo "$METRICS" | awk 'NR==4 {print $2}')
    WRITING=$(echo "$METRICS" | awk 'NR==4 {print $4}')
    WAITING=$(echo "$METRICS" | awk 'NR==4 {print $6}')
    
    # Log metrics in JSON format
    echo "{\"timestamp\":\"$TIMESTAMP\",\"active_connections\":$ACTIVE,\"accepts\":$ACCEPTS,\"handled\":$HANDLED,\"requests\":$REQUESTS,\"reading\":$READING,\"writing\":$WRITING,\"waiting\":$WAITING}" >> $METRICS_FILE
    
    echo "Metrics collected successfully"
else
    echo "Failed to collect metrics"
    exit 1
fi

# Collect system metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | awk 'NR==2{printf "%s", $5}' | sed 's/%//')

# Log system metrics
echo "{\"timestamp\":\"$TIMESTAMP\",\"cpu_usage\":$CPU_USAGE,\"memory_usage\":$MEM_USAGE,\"disk_usage\":$DISK_USAGE}" >> /var/log/nginx/system_metrics.log
```

## 🔍 Log Analysis

### Real-Time Log Analysis
```bash
#!/bin/bash
# nginx-log-analyzer.sh - Real-time log analysis

ACCESS_LOG="/var/log/nginx/access.log"
ERROR_LOG="/var/log/nginx/error.log"
ALERT_EMAIL="admin@example.com"

echo "=== Nginx Log Analysis ==="
echo "Timestamp: $(date)"

# Analyze last hour of access logs
echo "1. Top 10 IP addresses (last hour):"
grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
awk '{print $1}' | sort | uniq -c | sort -nr | head -10

echo -e "\n2. Top 10 requested URLs (last hour):"
grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
awk '{print $7}' | sort | uniq -c | sort -nr | head -10

echo -e "\n3. HTTP status code distribution (last hour):"
grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
awk '{print $9}' | sort | uniq -c | sort -nr

echo -e "\n4. Response time analysis (last hour):"
grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
awk '{print $NF}' | awk '{sum+=$1; count++} END {if(count>0) printf "Average: %.3fs\n", sum/count}'

# Check for errors
ERROR_COUNT=$(grep "$(date '+%Y/%m/%d %H')" $ERROR_LOG | wc -l)
echo -e "\n5. Error count (current hour): $ERROR_COUNT"

if [ $ERROR_COUNT -gt 10 ]; then
    echo "⚠️  High error rate detected!"
    # Send alert email
    echo "High error rate detected on $(hostname): $ERROR_COUNT errors in current hour" | \
    mail -s "Nginx Alert: High Error Rate" $ALERT_EMAIL
fi

# Check for slow requests
SLOW_REQUESTS=$(grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
awk '$NF > 5.0 {count++} END {print count+0}')
echo "6. Slow requests (>5s) in last hour: $SLOW_REQUESTS"

# Check for suspicious activity
SUSPICIOUS=$(grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $ACCESS_LOG | \
grep -E "(union|select|script|alert)" | wc -l)
echo "7. Suspicious requests in last hour: $SUSPICIOUS"

if [ $SUSPICIOUS -gt 5 ]; then
    echo "⚠️  Suspicious activity detected!"
fi
```

### Log Rotation Configuration
```bash
# /etc/logrotate.d/nginx - Log rotation configuration
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endscript
}

# Custom log rotation for high-traffic sites
/var/log/nginx/access.log {
    hourly
    rotate 168  # Keep 1 week of hourly logs
    compress
    delaycompress
    missingok
    notifempty
    sharedscripts
    postrotate
        /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
```

## 📊 Integration with Monitoring Tools

### Prometheus Integration
```nginx
# Prometheus metrics endpoint
server {
    listen 9113;
    server_name localhost;
    
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    
    location /metrics {
        # nginx-prometheus-exporter metrics
        proxy_pass http://127.0.0.1:9114/metrics;
    }
}
```

### Prometheus Configuration
```yaml
# prometheus.yml - Nginx monitoring configuration
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
    scrape_interval: 5s
    metrics_path: /metrics

  - job_name: 'nginx-vts'
    static_configs:
      - targets: ['localhost:8080']
    scrape_interval: 5s
    metrics_path: /status/format/prometheus

rule_files:
  - "nginx_alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### Grafana Dashboard Configuration
```json
{
  "dashboard": {
    "title": "Nginx Performance Dashboard",
    "panels": [
      {
        "title": "Requests per Second",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total[5m])",
            "legendFormat": "{{server}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "nginx_http_request_duration_seconds",
            "legendFormat": "{{quantile}}"
          }
        ]
      },
      {
        "title": "Active Connections",
        "type": "singlestat",
        "targets": [
          {
            "expr": "nginx_connections_active"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total{status=~\"4..|5..\"}[5m])",
            "legendFormat": "{{status}}"
          }
        ]
      }
    ]
  }
}
```

## 🎯 E-Commerce Monitoring Setup

### Complete E-Commerce Monitoring
```nginx
# E-commerce monitoring configuration
log_format ecommerce escape=json '{'
    '"timestamp":"$time_iso8601",'
    '"remote_addr":"$remote_addr",'
    '"request":"$request",'
    '"status":"$status",'
    '"body_bytes_sent":"$body_bytes_sent",'
    '"http_referer":"$http_referer",'
    '"http_user_agent":"$http_user_agent",'
    '"request_time":"$request_time",'
    '"upstream_response_time":"$upstream_response_time",'
    '"upstream_addr":"$upstream_addr",'
    '"cache_status":"$upstream_cache_status",'
    '"geoip_country":"$geoip_country_code",'
    '"session_id":"$cookie_session_id",'
    '"user_id":"$cookie_user_id"'
'}';

server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # E-commerce specific logging
    access_log /var/log/nginx/ecommerce.log ecommerce;
    
    # Separate logs for different sections
    location /api/products/ {
        access_log /var/log/nginx/products.log ecommerce;
        proxy_pass http://backend;
    }
    
    location /api/orders/ {
        access_log /var/log/nginx/orders.log ecommerce;
        proxy_pass http://backend;
    }
    
    location /api/payments/ {
        access_log /var/log/nginx/payments.log ecommerce;
        proxy_pass http://backend;
    }
    
    # Performance monitoring
    location /api/ {
        # Log slow API requests
        if ($request_time ~ "^[5-9]|^[1-9][0-9]") {
            access_log /var/log/nginx/slow_requests.log ecommerce;
        }
        
        proxy_pass http://backend;
    }
}
```

### E-Commerce Analytics Script
```bash
#!/bin/bash
# ecommerce-analytics.sh - E-commerce specific analytics

ECOMMERCE_LOG="/var/log/nginx/ecommerce.log"
PRODUCTS_LOG="/var/log/nginx/products.log"
ORDERS_LOG="/var/log/nginx/orders.log"
PAYMENTS_LOG="/var/log/nginx/payments.log"

echo "=== E-Commerce Analytics Report ==="
echo "Generated: $(date)"
echo

# Product analytics
echo "1. Product Performance (last 24 hours):"
grep "$(date -d '1 day ago' '+%Y-%m-%d')" $PRODUCTS_LOG | \
jq -r '.request' | grep -o '/api/products/[0-9]*' | \
sort | uniq -c | sort -nr | head -10

# Order analytics
echo -e "\n2. Order Volume (last 24 hours):"
ORDER_COUNT=$(grep "$(date -d '1 day ago' '+%Y-%m-%d')" $ORDERS_LOG | \
grep '"status":"200"' | wc -l)
echo "Total orders: $ORDER_COUNT"

# Payment analytics
echo -e "\n3. Payment Success Rate (last 24 hours):"
PAYMENT_TOTAL=$(grep "$(date -d '1 day ago' '+%Y-%m-%d')" $PAYMENTS_LOG | wc -l)
PAYMENT_SUCCESS=$(grep "$(date -d '1 day ago' '+%Y-%m-%d')" $PAYMENTS_LOG | \
grep '"status":"200"' | wc -l)

if [ $PAYMENT_TOTAL -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; $PAYMENT_SUCCESS * 100 / $PAYMENT_TOTAL" | bc)
    echo "Success rate: $SUCCESS_RATE% ($PAYMENT_SUCCESS/$PAYMENT_TOTAL)"
else
    echo "No payment attempts"
fi

# Geographic analytics
echo -e "\n4. Top Countries (last 24 hours):"
grep "$(date -d '1 day ago' '+%Y-%m-%d')" $ECOMMERCE_LOG | \
jq -r '.geoip_country' | grep -v null | sort | uniq -c | sort -nr | head -10

# Performance analytics
echo -e "\n5. Average Response Times (last 24 hours):"
grep "$(date -d '1 day ago' '+%Y-%m-%d')" $ECOMMERCE_LOG | \
jq -r '.request_time' | awk '{sum+=$1; count++} END {if(count>0) printf "Average: %.3fs\n", sum/count}'

# Cache performance
echo -e "\n6. Cache Hit Rate (last 24 hours):"
CACHE_TOTAL=$(grep "$(date -d '1 day ago' '+%Y-%m-%d')" $ECOMMERCE_LOG | \
jq -r '.cache_status' | grep -v null | wc -l)
CACHE_HITS=$(grep "$(date -d '1 day ago' '+%Y-%m-%d')" $ECOMMERCE_LOG | \
jq -r '.cache_status' | grep -c "HIT")

if [ $CACHE_TOTAL -gt 0 ]; then
    HIT_RATE=$(echo "scale=2; $CACHE_HITS * 100 / $CACHE_TOTAL" | bc)
    echo "Cache hit rate: $HIT_RATE% ($CACHE_HITS/$CACHE_TOTAL)"
fi
```

## 🚨 Alerting and Notifications

### Alert Configuration
```bash
#!/bin/bash
# nginx-alerts.sh - Automated alerting system

ALERT_EMAIL="admin@example.com"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
THRESHOLD_ERROR_RATE=5
THRESHOLD_RESPONSE_TIME=2.0
THRESHOLD_CONNECTIONS=1000

# Check error rate
ERROR_RATE=$(grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/access.log | \
awk '$9 >= 400 {errors++} {total++} END {if(total>0) print errors*100/total; else print 0}')

if (( $(echo "$ERROR_RATE > $THRESHOLD_ERROR_RATE" | bc -l) )); then
    MESSAGE="High error rate detected: ${ERROR_RATE}%"
    echo "$MESSAGE" | mail -s "Nginx Alert: High Error Rate" $ALERT_EMAIL
    
    # Slack notification
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"🚨 $MESSAGE\"}" \
    $SLACK_WEBHOOK
fi

# Check response time
AVG_RESPONSE_TIME=$(grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/access.log | \
awk '{print $NF}' | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')

if (( $(echo "$AVG_RESPONSE_TIME > $THRESHOLD_RESPONSE_TIME" | bc -l) )); then
    MESSAGE="High response time detected: ${AVG_RESPONSE_TIME}s"
    echo "$MESSAGE" | mail -s "Nginx Alert: High Response Time" $ALERT_EMAIL
fi

# Check active connections
ACTIVE_CONNECTIONS=$(curl -s http://localhost:8080/nginx_status | \
grep "Active connections" | awk '{print $3}')

if [ $ACTIVE_CONNECTIONS -gt $THRESHOLD_CONNECTIONS ]; then
    MESSAGE="High connection count: $ACTIVE_CONNECTIONS active connections"
    echo "$MESSAGE" | mail -s "Nginx Alert: High Connection Count" $ALERT_EMAIL
fi
```

## 🎯 Practical Exercises

### Exercise 1: Comprehensive Logging Setup
Configure advanced logging:
- Multiple log formats
- Conditional logging
- Log rotation
- Real-time analysis

### Exercise 2: Monitoring Integration
Set up monitoring stack:
- Prometheus metrics
- Grafana dashboards
- Alert configuration
- Performance tracking

### Exercise 3: E-Commerce Analytics
Implement e-commerce analytics:
- Business metrics tracking
- Performance monitoring
- User behavior analysis
- Automated reporting

---

**🎯 Next**: Caching strategies and CDN integration  
**📚 Resources**: [Nginx Logging Guide](https://nginx.org/en/docs/http/ngx_http_log_module.html)  
**🔧 Tools**: Use ELK stack, Prometheus, and Grafana for comprehensive monitoring
