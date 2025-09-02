# 🔄 Nginx Reverse Proxy Complete Guide

## 📋 Overview

**Duration**: 6-8 Hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites**: Virtual Hosts & Server Blocks completed  

Master Nginx reverse proxy configuration for modern web applications, microservices, and API gateways with comprehensive examples and production patterns.

## 🎯 Learning Objectives

- Configure reverse proxy for various backend applications
- Implement advanced proxy headers and request modification
- Master upstream server configuration and health checks
- Configure SSL termination and end-to-end encryption
- Implement request routing and load distribution strategies

## 📚 Reverse Proxy Fundamentals

### What is a Reverse Proxy?

A reverse proxy sits between clients and backend servers, forwarding client requests to backend servers and returning responses back to clients. Unlike forward proxies, reverse proxies are transparent to clients.

#### Benefits of Reverse Proxy
- **Load Distribution**: Distribute requests across multiple backend servers
- **SSL Termination**: Handle SSL/TLS encryption/decryption
- **Caching**: Cache responses to improve performance
- **Security**: Hide backend server details and add security layers
- **Compression**: Compress responses to reduce bandwidth
- **Request Modification**: Add headers, modify requests

### Basic Reverse Proxy Configuration
```nginx
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔧 Essential Proxy Directives

### proxy_pass Configuration
```nginx
# Basic proxy to backend server
location / {
    proxy_pass http://127.0.0.1:8000;
}

# Proxy with path modification
location /api/ {
    proxy_pass http://127.0.0.1:8000/;  # Removes /api/ from path
}

location /api {
    proxy_pass http://127.0.0.1:8000;   # Keeps /api in path
}

# Proxy to different protocols
location /secure/ {
    proxy_pass https://secure-backend.internal:8443/;
}

# Proxy to Unix socket
location /app/ {
    proxy_pass http://unix:/tmp/backend.sock:/;
}

# Proxy with variables
set $backend_server backend.internal;
location / {
    proxy_pass http://$backend_server:8000;
}
```

### Essential Proxy Headers
```nginx
location / {
    proxy_pass http://backend;
    
    # Host information
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;
    
    # Original request information
    proxy_set_header X-Original-URI $request_uri;
    proxy_set_header X-Original-Method $request_method;
    
    # Custom headers
    proxy_set_header X-Request-ID $request_id;
    proxy_set_header X-Timestamp $time_iso8601;
}
```

### Proxy Timeouts and Buffering
```nginx
location / {
    proxy_pass http://backend;
    
    # Timeout settings
    proxy_connect_timeout 30s;
    proxy_send_timeout 30s;
    proxy_read_timeout 30s;
    
    # Buffering settings
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    proxy_max_temp_file_size 1024m;
    
    # Request body settings
    client_max_body_size 100m;
    client_body_buffer_size 128k;
    proxy_request_buffering on;
}
```

## 🌐 Upstream Server Configuration

### Basic Upstream Definition
```nginx
upstream backend {
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Advanced Upstream Configuration
```nginx
upstream backend_api {
    # Load balancing method
    least_conn;
    
    # Backend servers with weights and options
    server 127.0.0.1:8001 weight=3 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 weight=2 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8003 weight=1 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8004 backup;
    
    # Keep-alive connections
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend_api;
        
        # Connection settings for keep-alive
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Standard headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Health Checks and Failover
```nginx
upstream backend_with_health {
    server 127.0.0.1:8001 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8003 backup;
    
    # Health check configuration (Nginx Plus)
    # health_check interval=5s fails=3 passes=2 uri=/health;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend_with_health;
        
        # Error handling
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 30s;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

## 🔒 SSL Termination and End-to-End Encryption

### SSL Termination (HTTPS to HTTP)
```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    location / {
        # Terminate SSL here, proxy to HTTP backend
        proxy_pass http://127.0.0.1:8000;
        
        # SSL termination headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-SSL on;
    }
}
```

### End-to-End Encryption (HTTPS to HTTPS)
```nginx
server {
    listen 443 ssl http2;
    server_name secure-api.example.com;
    
    # Frontend SSL configuration
    ssl_certificate /etc/ssl/certs/secure-api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/secure-api.example.com.key;
    
    location / {
        # Proxy to HTTPS backend
        proxy_pass https://secure-backend.internal:8443;
        
        # Backend SSL verification
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/backend-ca.crt;
        proxy_ssl_name secure-backend.internal;
        
        # SSL client certificate (mutual TLS)
        proxy_ssl_certificate /etc/ssl/certs/client.crt;
        proxy_ssl_certificate_key /etc/ssl/private/client.key;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🎯 E-Commerce Application Reverse Proxy

### Complete E-Commerce Proxy Configuration
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=upload:10m rate=1r/s;

# Backend upstream servers
upstream ecommerce_backend {
    least_conn;
    server 127.0.0.1:8001 weight=3;
    server 127.0.0.1:8002 weight=2;
    server 127.0.0.1:8003 backup;
    keepalive 32;
}

# Main e-commerce proxy server
server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Frontend static files (served directly by Nginx)
    root /var/www/ecommerce/frontend/build;
    index index.html;
    
    # Main application
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API endpoints
    location /api/ {
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
        
        # Proxy to backend
        proxy_pass http://ecommerce_backend/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        # Timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Error handling
        proxy_next_upstream error timeout http_500 http_502 http_503;
        proxy_next_upstream_tries 2;
    }
    
    # Authentication endpoints (stricter rate limiting)
    location /api/auth/ {
        limit_req zone=auth burst=5 nodelay;
        
        proxy_pass http://ecommerce_backend/auth/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # File upload endpoints
    location /api/upload/ {
        limit_req zone=upload burst=3 nodelay;
        
        # Large file upload settings
        client_max_body_size 50m;
        client_body_timeout 60s;
        
        proxy_pass http://ecommerce_backend/upload/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # Upload timeout settings
        proxy_connect_timeout 10s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # WebSocket support (for real-time features)
    location /ws/ {
        proxy_pass http://ecommerce_backend/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Admin panel (restricted access)
    location /admin/ {
        # IP restriction
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        proxy_pass http://ecommerce_backend/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Admin-Access "true";
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://ecommerce_backend/health;
        proxy_set_header Host $host;
    }
}
```

### Microservices Proxy Configuration
```nginx
# User service
upstream user_service {
    server user-service-1:8001;
    server user-service-2:8002;
    keepalive 16;
}

# Product service
upstream product_service {
    server product-service-1:8003;
    server product-service-2:8004;
    keepalive 16;
}

# Order service
upstream order_service {
    server order-service-1:8005;
    server order-service-2:8006;
    keepalive 16;
}

# API Gateway
server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    ssl_certificate /etc/ssl/certs/api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;
    
    # User service routes
    location /api/users/ {
        proxy_pass http://user_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "user-service";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Product service routes
    location /api/products/ {
        proxy_pass http://product_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "product-service";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Order service routes
    location /api/orders/ {
        proxy_pass http://order_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Service "order-service";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Service discovery endpoint
    location /api/services {
        return 200 '{"services":["users","products","orders"]}';
        add_header Content-Type application/json;
    }
}
```

## 🔍 Advanced Proxy Patterns

### Request Routing Based on Headers
```nginx
map $http_user_agent $backend_pool {
    ~*mobile mobile_backend;
    default web_backend;
}

upstream web_backend {
    server web-1:8001;
    server web-2:8002;
}

upstream mobile_backend {
    server mobile-1:8003;
    server mobile-2:8004;
}

server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://$backend_pool;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Backend-Pool $backend_pool;
    }
}
```

### Geographic Load Balancing
```nginx
# Requires GeoIP module
geoip_country /usr/share/GeoIP/GeoIP.dat;

map $geoip_country_code $backend_pool {
    US us_backend;
    CA us_backend;
    GB eu_backend;
    DE eu_backend;
    FR eu_backend;
    default us_backend;
}

upstream us_backend {
    server us-east-1:8001;
    server us-west-1:8002;
}

upstream eu_backend {
    server eu-west-1:8003;
    server eu-central-1:8004;
}

server {
    listen 80;
    server_name global.example.com;
    
    location / {
        proxy_pass http://$backend_pool;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Country-Code $geoip_country_code;
        proxy_set_header X-Backend-Region $backend_pool;
    }
}
```

### Circuit Breaker Pattern
```nginx
# Simple circuit breaker using error tracking
upstream backend_with_circuit_breaker {
    server 127.0.0.1:8001 max_fails=5 fail_timeout=60s;
    server 127.0.0.1:8002 max_fails=5 fail_timeout=60s;
    server 127.0.0.1:8003 backup;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend_with_circuit_breaker;
        
        # Circuit breaker configuration
        proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
        proxy_next_upstream_tries 2;
        proxy_next_upstream_timeout 10s;
        
        # Fallback for when all backends are down
        error_page 502 503 504 = @fallback;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location @fallback {
        return 503 '{"error":"Service temporarily unavailable","retry_after":60}';
        add_header Content-Type application/json;
        add_header Retry-After 60;
    }
}
```

## 📊 Monitoring and Debugging

### Proxy Status and Metrics
```nginx
# Status endpoint for monitoring
server {
    listen 8080;
    server_name localhost;
    
    # Restrict access
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    
    location /nginx_status {
        stub_status on;
        access_log off;
    }
    
    location /upstream_status {
        # Requires upstream module (Nginx Plus)
        # upstream_conf;
        return 200 "Upstream status endpoint";
    }
}
```

### Debug Logging
```nginx
# Enable debug logging for proxy
error_log /var/log/nginx/proxy_debug.log debug;

server {
    listen 80;
    server_name debug.example.com;
    
    location / {
        # Debug headers
        add_header X-Debug-Backend $upstream_addr always;
        add_header X-Debug-Response-Time $upstream_response_time always;
        add_header X-Debug-Status $upstream_status always;
        
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🎯 Practical Exercises

### Exercise 1: Basic Reverse Proxy
Set up reverse proxy for FastAPI backend with proper headers and error handling.

### Exercise 2: Load Balancing
Configure upstream servers with different load balancing methods and health checks.

### Exercise 3: SSL Termination
Implement SSL termination with proper security headers and HTTPS redirection.

### Exercise 4: Microservices Gateway
Create API gateway routing requests to different microservices based on URL paths.

---

**🎯 Next**: Load balancing advanced strategies and algorithms  
**📚 Resources**: [Nginx Proxy Module Documentation](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)  
**🔧 Tools**: Use `curl -H "Host: example.com" http://localhost/` to test proxy configurations
