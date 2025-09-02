# ⚖️ Nginx Advanced Load Balancing

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Reverse Proxy Complete guide finished  

Master advanced load balancing algorithms, health checks, session persistence, and high-availability patterns for production environments.

## 🎯 Learning Objectives

- Configure all load balancing algorithms and their use cases
- Implement advanced health checking and failover strategies
- Master session persistence and sticky sessions
- Configure high-availability load balancer clusters
- Optimize load balancing for different application types

## 📚 Load Balancing Algorithms

### Round Robin (Default)
```nginx
upstream backend_round_robin {
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

server {
    listen 80;
    server_name lb.example.com;
    
    location / {
        proxy_pass http://backend_round_robin;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Weighted Round Robin
```nginx
upstream backend_weighted {
    server backend1.example.com weight=3;  # Gets 3x more requests
    server backend2.example.com weight=2;  # Gets 2x more requests
    server backend3.example.com weight=1;  # Gets 1x requests (default)
}

# Use case: Different server capacities
# backend1: 8 CPU cores, 16GB RAM (weight=3)
# backend2: 4 CPU cores, 8GB RAM (weight=2)  
# backend3: 2 CPU cores, 4GB RAM (weight=1)
```

### Least Connections
```nginx
upstream backend_least_conn {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Best for: Long-running connections, WebSockets, streaming
```

### IP Hash (Session Persistence)
```nginx
upstream backend_ip_hash {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Best for: Session-based applications, shopping carts
```

### Generic Hash
```nginx
upstream backend_generic_hash {
    hash $request_uri consistent;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Best for: Caching, consistent routing based on URL
```

## 🏥 Advanced Health Checks

### Passive Health Checks
```nginx
upstream backend_with_health {
    server backend1.example.com max_fails=3 fail_timeout=30s;
    server backend2.example.com max_fails=3 fail_timeout=30s;
    server backend3.example.com max_fails=5 fail_timeout=60s;
    server backup.example.com backup;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend_with_health;
        
        # Define what constitutes a failure
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 30s;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Custom Health Check Endpoints
```nginx
upstream ecommerce_backend {
    server app1.example.com:8001 max_fails=2 fail_timeout=10s;
    server app2.example.com:8002 max_fails=2 fail_timeout=10s;
    server app3.example.com:8003 max_fails=2 fail_timeout=10s;
}

server {
    listen 80;
    server_name ecommerce.example.com;
    
    # Health check proxy (for monitoring)
    location /health-check {
        internal;
        proxy_pass http://ecommerce_backend/health;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URI $request_uri;
    }
    
    location / {
        # Custom error handling for health checks
        error_page 502 503 504 = @fallback;
        
        proxy_pass http://ecommerce_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location @fallback {
        return 503 '{"error":"Service temporarily unavailable","retry_after":30}';
        add_header Content-Type application/json;
        add_header Retry-After 30;
    }
}
```

## 🔄 Session Persistence Strategies

### Sticky Sessions with IP Hash
```nginx
upstream sticky_backend {
    ip_hash;
    server app1.example.com:8001;
    server app2.example.com:8002;
    server app3.example.com:8003;
}

server {
    listen 80;
    server_name shop.example.com;
    
    location / {
        proxy_pass http://sticky_backend;
        
        # Session debugging headers
        add_header X-Upstream-Server $upstream_addr always;
        add_header X-Client-IP $remote_addr always;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Cookie-Based Session Persistence
```nginx
map $cookie_server_id $backend_pool {
    ~server1 backend1_pool;
    ~server2 backend2_pool;
    ~server3 backend3_pool;
    default backend_round_robin;
}

upstream backend1_pool {
    server app1.example.com:8001;
}

upstream backend2_pool {
    server app2.example.com:8002;
}

upstream backend3_pool {
    server app3.example.com:8003;
}

upstream backend_round_robin {
    server app1.example.com:8001;
    server app2.example.com:8002;
    server app3.example.com:8003;
}

server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://$backend_pool;
        
        # Set server cookie if not present
        if ($cookie_server_id = "") {
            add_header Set-Cookie "server_id=server$upstream_addr; Path=/; HttpOnly";
        }
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🎯 E-Commerce Load Balancing Configuration

### Multi-Tier Load Balancing
```nginx
# Frontend servers (static content + React app)
upstream frontend_servers {
    least_conn;
    server frontend1.example.com:80 weight=2;
    server frontend2.example.com:80 weight=2;
    server frontend3.example.com:80 weight=1;
}

# API servers (FastAPI backend)
upstream api_servers {
    least_conn;
    server api1.example.com:8001 weight=3 max_fails=3 fail_timeout=30s;
    server api2.example.com:8002 weight=2 max_fails=3 fail_timeout=30s;
    server api3.example.com:8003 weight=1 max_fails=3 fail_timeout=30s;
    server api-backup.example.com:8004 backup;
    
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

# Database read replicas
upstream db_read_servers {
    least_conn;
    server db-read1.example.com:5432 weight=2;
    server db-read2.example.com:5432 weight=2;
    server db-read3.example.com:5432 weight=1;
}

# Main load balancer
server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
    
    # Frontend (React SPA)
    location / {
        proxy_pass http://frontend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Frontend-specific settings
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # API endpoints with session persistence
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://api_servers/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Headers for API
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        # API-specific timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Error handling
        proxy_next_upstream error timeout http_500 http_502 http_503;
        proxy_next_upstream_tries 2;
        proxy_next_upstream_timeout 20s;
        
        # Debug headers
        add_header X-Upstream-Server $upstream_addr always;
        add_header X-Response-Time $upstream_response_time always;
    }
    
    # Authentication with stricter limits
    location /api/auth/ {
        limit_req zone=auth burst=5 nodelay;
        
        # Use IP hash for login consistency
        proxy_pass http://api_servers/auth/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Admin panel (restricted and sticky)
    location /admin/ {
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        # Sticky sessions for admin
        proxy_pass http://api_servers/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Admin-Session "true";
    }
}
```

### Microservices Load Balancing
```nginx
# User service cluster
upstream user_service {
    least_conn;
    server user-svc-1.internal:8001 weight=2;
    server user-svc-2.internal:8002 weight=2;
    server user-svc-3.internal:8003 weight=1;
    keepalive 16;
}

# Product service cluster  
upstream product_service {
    hash $request_uri consistent;  # Cache-friendly routing
    server product-svc-1.internal:8004 weight=3;
    server product-svc-2.internal:8005 weight=2;
    server product-svc-3.internal:8006 weight=1;
    keepalive 16;
}

# Order service cluster
upstream order_service {
    ip_hash;  # Session persistence for orders
    server order-svc-1.internal:8007 weight=2;
    server order-svc-2.internal:8008 weight=2;
    keepalive 16;
}

# Payment service cluster (high availability)
upstream payment_service {
    server payment-svc-1.internal:8009 max_fails=1 fail_timeout=5s;
    server payment-svc-2.internal:8010 max_fails=1 fail_timeout=5s;
    server payment-backup.internal:8011 backup;
    keepalive 8;
}

# API Gateway
server {
    listen 443 ssl http2;
    server_name api.shop.example.com;
    
    ssl_certificate /etc/ssl/certs/api.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.shop.example.com.key;
    
    # User service routes
    location /api/users/ {
        proxy_pass http://user_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "user-service";
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Product service routes (cache-optimized)
    location /api/products/ {
        proxy_pass http://product_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "product-service";
        proxy_set_header X-Request-ID $request_id;
        
        # Product caching
        proxy_cache_valid 200 5m;
        proxy_cache_key "$scheme$request_method$host$request_uri";
    }
    
    # Order service routes (session-aware)
    location /api/orders/ {
        proxy_pass http://order_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "order-service";
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-User-Session $cookie_session_id;
    }
    
    # Payment service routes (high security)
    location /api/payments/ {
        # Extra security for payments
        limit_req zone=payment burst=3 nodelay;
        
        proxy_pass http://payment_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "payment-service";
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Payment-specific timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 15s;
        proxy_read_timeout 15s;
        
        # Strict error handling
        proxy_next_upstream error timeout http_500;
        proxy_next_upstream_tries 1;
    }
}
```

## 🔧 Advanced Load Balancing Features

### Dynamic Server Management
```nginx
# Server management with different states
upstream dynamic_backend {
    server backend1.example.com:8001 weight=3;
    server backend2.example.com:8002 weight=2;
    server backend3.example.com:8003 weight=1 down;  # Temporarily disabled
    server backend4.example.com:8004 backup;         # Only used when others fail
    server backend5.example.com:8005 max_fails=1 fail_timeout=10s;
}

# Gradual traffic shifting (Blue-Green deployment)
map $cookie_deployment $backend_version {
    ~green green_backend;
    default blue_backend;
}

upstream blue_backend {
    server blue-app1.example.com:8001;
    server blue-app2.example.com:8002;
}

upstream green_backend {
    server green-app1.example.com:8001;
    server green-app2.example.com:8002;
}

server {
    listen 80;
    server_name app.example.com;
    
    location / {
        # Route based on deployment cookie
        proxy_pass http://$backend_version;
        
        # Set deployment cookie for testing
        if ($arg_version = "green") {
            add_header Set-Cookie "deployment=green; Path=/; HttpOnly";
        }
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Deployment $backend_version;
    }
}
```

### Geographic Load Balancing
```nginx
# Requires GeoIP module
geoip_country /usr/share/GeoIP/GeoIP.dat;

map $geoip_country_code $nearest_datacenter {
    ~^(US|CA|MX)$ us_backend;
    ~^(GB|DE|FR|IT|ES)$ eu_backend;
    ~^(JP|KR|CN|SG)$ asia_backend;
    default us_backend;
}

upstream us_backend {
    server us-east-1.example.com:8001 weight=2;
    server us-west-1.example.com:8002 weight=2;
    server us-central-1.example.com:8003 weight=1;
}

upstream eu_backend {
    server eu-west-1.example.com:8001 weight=2;
    server eu-central-1.example.com:8002 weight=1;
}

upstream asia_backend {
    server asia-east-1.example.com:8001 weight=2;
    server asia-southeast-1.example.com:8002 weight=1;
}

server {
    listen 80;
    server_name global.example.com;
    
    location / {
        proxy_pass http://$nearest_datacenter;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Country-Code $geoip_country_code;
        proxy_set_header X-Datacenter $nearest_datacenter;
    }
}
```

## 📊 Load Balancing Monitoring

### Monitoring Configuration
```nginx
# Status and metrics endpoint
server {
    listen 8080;
    server_name localhost;
    
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    
    location /nginx_status {
        stub_status on;
        access_log off;
    }
    
    location /upstream_status {
        # Custom upstream status (requires custom module or script)
        proxy_pass http://127.0.0.1:9090/status;
    }
    
    location /health_summary {
        return 200 '{"status":"healthy","upstreams":{"api_servers":"3/3","frontend_servers":"3/3"}}';
        add_header Content-Type application/json;
    }
}
```

### Load Balancing Metrics Script
```bash
#!/bin/bash
# lb-monitor.sh - Load balancing monitoring script

echo "=== Nginx Load Balancing Status ==="
echo "Timestamp: $(date)"
echo

# Check Nginx status
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx: Running"
else
    echo "❌ Nginx: Stopped"
    exit 1
fi

# Get basic stats
echo "📊 Connection Stats:"
curl -s http://localhost:8080/nginx_status

echo -e "\n🔄 Upstream Health Check:"
# Test each backend
backends=("backend1.example.com:8001" "backend2.example.com:8002" "backend3.example.com:8003")

for backend in "${backends[@]}"; do
    if curl -s --connect-timeout 5 "http://$backend/health" >/dev/null; then
        echo "✅ $backend: Healthy"
    else
        echo "❌ $backend: Unhealthy"
    fi
done

echo -e "\n📈 Load Distribution Test:"
# Test load distribution
for i in {1..10}; do
    response=$(curl -s http://localhost/api/health | jq -r '.server' 2>/dev/null || echo "error")
    echo "Request $i: $response"
done
```

## 🎯 Practical Exercises

### Exercise 1: Multi-Algorithm Setup
Configure different load balancing algorithms for different services:
- Round robin for web servers
- Least connections for API servers  
- IP hash for user sessions
- Weighted for different server capacities

### Exercise 2: Health Check Implementation
Set up comprehensive health checking with:
- Custom health endpoints
- Automatic failover
- Backup server activation
- Recovery detection

### Exercise 3: Session Persistence
Implement session persistence using:
- IP hash method
- Cookie-based routing
- Custom header routing

---

**🎯 Next**: SSL/TLS configuration and security  
**📚 Resources**: [Nginx Load Balancing](https://nginx.org/en/docs/http/load_balancing.html)  
**🔧 Tools**: Use monitoring scripts to validate load distribution
