# 🚀 Nginx Performance Optimization Complete Guide

## 📋 Overview

**Duration**: 6-8 Hours  
**Skill Level**: Advanced  
**Prerequisites**: SSL/TLS Configuration completed  

Master Nginx performance optimization techniques for high-traffic production environments, including caching, compression, connection optimization, and resource tuning.

## 🎯 Learning Objectives

- Optimize Nginx for maximum performance and throughput
- Implement advanced caching strategies
- Configure compression and content optimization
- Tune worker processes and connection handling
- Monitor and measure performance improvements

## 📚 Core Performance Configuration

### Worker Process Optimization
```nginx
# /etc/nginx/nginx.conf - Global performance settings

# Worker processes (usually = CPU cores)
worker_processes auto;

# Worker connections (max connections per worker)
events {
    worker_connections 4096;
    use epoll;                    # Linux: epoll, FreeBSD: kqueue
    multi_accept on;              # Accept multiple connections at once
    accept_mutex off;             # Disable for better performance with epoll
}

# Worker process limits
worker_rlimit_nofile 65535;      # Max open files per worker

# CPU affinity (bind workers to specific CPU cores)
worker_cpu_affinity auto;

http {
    # Sendfile optimization
    sendfile on;
    tcp_nopush on;               # Send headers in one packet
    tcp_nodelay on;              # Don't buffer data-sends
    
    # Connection keep-alive
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Client timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;
    
    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 100m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    output_buffers 1 32k;
    postpone_output 1460;
    
    # Hash table sizes
    server_names_hash_bucket_size 128;
    server_names_hash_max_size 1024;
    types_hash_max_size 2048;
}
```

### High-Performance Server Block
```nginx
server {
    listen 80 default_server reuseport;
    listen [::]:80 default_server reuseport;
    server_name example.com www.example.com;
    
    # Performance optimizations
    access_log off;              # Disable for static content
    error_log /var/log/nginx/error.log crit;  # Only critical errors
    
    # Root and index
    root /var/www/example.com;
    index index.html index.htm;
    
    # Efficient file serving
    location / {
        try_files $uri $uri/ =404;
        
        # Open file cache
        open_file_cache max=10000 inactive=5m;
        open_file_cache_valid 2m;
        open_file_cache_min_uses 1;
        open_file_cache_errors on;
    }
    
    # Static assets optimization
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|pdf|txt)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
        log_not_found off;
        
        # Efficient static file serving
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
    }
}
```

## 🗜️ Compression Optimization

### Advanced Gzip Configuration
```nginx
http {
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;           # Balance between compression and CPU
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    
    # Gzip file types
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml
        application/x-font-ttf
        application/vnd.ms-fontobject
        font/opentype;
    
    # Brotli compression (if module available)
    # brotli on;
    # brotli_comp_level 6;
    # brotli_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}

server {
    listen 80;
    server_name compressed.example.com;
    
    location / {
        root /var/www/compressed;
        
        # Pre-compressed files
        gzip_static on;          # Serve .gz files if available
        # brotli_static on;      # Serve .br files if available
        
        try_files $uri $uri/ =404;
    }
}
```

### Pre-Compression Strategy
```bash
#!/bin/bash
# pre-compress.sh - Pre-compress static assets

WEBROOT="/var/www/example.com"

echo "Pre-compressing static assets..."

# Find and compress CSS, JS, HTML, XML files
find $WEBROOT -type f \( -name "*.css" -o -name "*.js" -o -name "*.html" -o -name "*.xml" -o -name "*.json" \) -exec gzip -k -9 {} \;

# Brotli compression (if available)
# find $WEBROOT -type f \( -name "*.css" -o -name "*.js" -o -name "*.html" -o -name "*.xml" -o -name "*.json" \) -exec brotli -k -9 {} \;

echo "Pre-compression complete"

# Set up cron job for automatic pre-compression
# 0 2 * * * /path/to/pre-compress.sh
```

## 🚀 Caching Strategies

### Proxy Caching Configuration
```nginx
# Cache path configuration
proxy_cache_path /var/cache/nginx/proxy 
                 levels=1:2 
                 keys_zone=api_cache:100m 
                 max_size=10g 
                 inactive=60m 
                 use_temp_path=off;

proxy_cache_path /var/cache/nginx/static 
                 levels=1:2 
                 keys_zone=static_cache:50m 
                 max_size=5g 
                 inactive=30d 
                 use_temp_path=off;

upstream api_backend {
    server api1.example.com:8001;
    server api2.example.com:8002;
    keepalive 32;
}

server {
    listen 80;
    server_name cache.example.com;
    
    # API caching
    location /api/ {
        proxy_cache api_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        proxy_cache_valid 200 302 5m;
        proxy_cache_valid 404 1m;
        proxy_cache_valid any 1m;
        
        # Cache control
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_background_update on;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 5s;
        
        # Cache bypass conditions
        proxy_cache_bypass $cookie_nocache $arg_nocache $arg_comment;
        proxy_no_cache $cookie_nocache $arg_nocache $arg_comment;
        
        # Headers
        add_header X-Cache-Status $upstream_cache_status always;
        
        proxy_pass http://api_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Static content caching
    location /static/ {
        proxy_cache static_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1h;
        
        add_header X-Cache-Status $upstream_cache_status always;
        
        proxy_pass http://static_backend/;
    }
    
    # Cache purge endpoint (for cache invalidation)
    location ~ /purge(/.*) {
        allow 127.0.0.1;
        allow 192.168.1.0/24;
        deny all;
        
        proxy_cache_purge api_cache "$scheme$request_method$host$1";
    }
}
```

### FastCGI Caching (for PHP)
```nginx
# FastCGI cache configuration
fastcgi_cache_path /var/cache/nginx/fastcgi 
                   levels=1:2 
                   keys_zone=php_cache:100m 
                   max_size=5g 
                   inactive=60m 
                   use_temp_path=off;

server {
    listen 80;
    server_name php.example.com;
    root /var/www/php.example.com;
    index index.php index.html;
    
    # PHP processing with caching
    location ~ \.php$ {
        # FastCGI cache
        fastcgi_cache php_cache;
        fastcgi_cache_key "$scheme$request_method$host$request_uri";
        fastcgi_cache_valid 200 302 5m;
        fastcgi_cache_valid 404 1m;
        
        # Cache bypass for dynamic content
        set $skip_cache 0;
        
        # Skip cache for POST requests
        if ($request_method = POST) {
            set $skip_cache 1;
        }
        
        # Skip cache for URLs with query strings
        if ($query_string != "") {
            set $skip_cache 1;
        }
        
        # Skip cache for admin/login pages
        if ($request_uri ~* "/(admin|login|wp-admin)") {
            set $skip_cache 1;
        }
        
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        
        # Cache headers
        add_header X-FastCGI-Cache $upstream_cache_status always;
        
        # FastCGI configuration
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## 🎯 E-Commerce Performance Optimization

### High-Performance E-Commerce Configuration
```nginx
# Cache zones for different content types
proxy_cache_path /var/cache/nginx/api levels=1:2 keys_zone=api:100m max_size=1g inactive=10m;
proxy_cache_path /var/cache/nginx/products levels=1:2 keys_zone=products:200m max_size=5g inactive=1h;
proxy_cache_path /var/cache/nginx/static levels=1:2 keys_zone=static:50m max_size=2g inactive=7d;

# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=search:10m rate=5r/s;

# Upstream backend
upstream ecommerce_api {
    least_conn;
    server api1.shop.com:8001 weight=3 max_fails=3 fail_timeout=30s;
    server api2.shop.com:8002 weight=2 max_fails=3 fail_timeout=30s;
    server api3.shop.com:8003 weight=1 max_fails=3 fail_timeout=30s;
    
    keepalive 64;
    keepalive_requests 1000;
    keepalive_timeout 60s;
}

server {
    listen 443 ssl http2 reuseport;
    server_name shop.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Performance SSL settings
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    ssl_buffer_size 4k;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Frontend (React SPA) - Highly optimized
    root /var/www/ecommerce/build;
    index index.html;
    
    # Main application
    location / {
        try_files $uri $uri/ /index.html;
        
        # HTML caching
        location ~* \.html$ {
            expires 1h;
            add_header Cache-Control "public, must-revalidate";
            
            # Compression
            gzip_static on;
            
            # Security headers for HTML
            add_header X-Frame-Options "DENY" always;
            add_header X-Content-Type-Options "nosniff" always;
        }
        
        # Static assets - Long-term caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
            
            # Compression
            gzip_static on;
            
            # Open file cache
            open_file_cache max=10000 inactive=5m;
            open_file_cache_valid 2m;
            open_file_cache_min_uses 1;
            open_file_cache_errors on;
        }
    }
    
    # Product API - Aggressive caching
    location /api/products/ {
        limit_req zone=api burst=50 nodelay;
        
        proxy_cache products;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 1h;
        proxy_cache_valid 404 5m;
        
        # Cache optimization
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_background_update on;
        proxy_cache_lock on;
        
        # Conditional caching
        proxy_cache_bypass $cookie_admin $arg_nocache;
        proxy_no_cache $cookie_admin $arg_nocache;
        
        proxy_pass http://ecommerce_api/products/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Optimized headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Performance headers
        add_header X-Cache-Status $upstream_cache_status always;
        add_header X-Response-Time $upstream_response_time always;
        
        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
    
    # Search API - Rate limited
    location /api/search/ {
        limit_req zone=search burst=10 nodelay;
        
        proxy_cache api;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 5m;
        
        proxy_pass http://ecommerce_api/search/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # User API - No caching for personalized content
    location /api/users/ {
        limit_req zone=api burst=20 nodelay;
        
        # No caching for user-specific data
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        
        proxy_pass http://ecommerce_api/users/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Cart API - Session-based
    location /api/cart/ {
        limit_req zone=api burst=30 nodelay;
        
        # Session-based routing
        proxy_pass http://ecommerce_api/cart/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Session-ID $cookie_session_id;
    }
}
```

### CDN Integration
```nginx
# CDN-optimized configuration
server {
    listen 80;
    server_name cdn.example.com;
    
    # CDN-friendly headers
    location /static/ {
        root /var/www/cdn;
        
        # Long-term caching for CDN
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # CDN headers
        add_header X-CDN-Cache "HIT" always;
        add_header Access-Control-Allow-Origin "*" always;
        
        # Compression
        gzip_static on;
        
        # Efficient file serving
        sendfile on;
        tcp_nopush on;
        
        # CORS for cross-origin requests
        location ~* \.(woff|woff2|ttf|eot)$ {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept" always;
        }
    }
    
    # Image optimization
    location /images/ {
        root /var/www/cdn;
        
        # Image-specific caching
        expires 30d;
        add_header Cache-Control "public";
        
        # WebP support
        location ~* \.(png|jpg|jpeg)$ {
            add_header Vary Accept;
            try_files $uri$webp_suffix $uri =404;
        }
    }
}

# WebP detection
map $http_accept $webp_suffix {
    "~*webp" ".webp";
    default "";
}
```

## 📊 Performance Monitoring

### Real-Time Performance Monitoring
```nginx
# Status and metrics server
server {
    listen 8080;
    server_name localhost;
    
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    
    # Basic status
    location /nginx_status {
        stub_status on;
        access_log off;
    }
    
    # Cache status
    location /cache_status {
        return 200 '{"api_cache_size":"$upstream_cache_status","products_cache_size":"$upstream_cache_status"}';
        add_header Content-Type application/json;
    }
    
    # Performance metrics
    location /metrics {
        return 200 'nginx_connections_active $connections_active\nnginx_connections_reading $connections_reading\nnginx_connections_writing $connections_writing\nnginx_connections_waiting $connections_waiting\n';
        add_header Content-Type text/plain;
    }
}
```

### Performance Testing Scripts
```bash
#!/bin/bash
# performance-test.sh - Comprehensive performance testing

DOMAIN="shop.example.com"
CONCURRENT_USERS=100
TOTAL_REQUESTS=10000

echo "=== Nginx Performance Test ==="
echo "Domain: $DOMAIN"
echo "Concurrent Users: $CONCURRENT_USERS"
echo "Total Requests: $TOTAL_REQUESTS"
echo

# Test static content performance
echo "1. Static Content Performance:"
ab -n $TOTAL_REQUESTS -c $CONCURRENT_USERS https://$DOMAIN/css/main.css

# Test API performance
echo -e "\n2. API Performance:"
ab -n 1000 -c 50 https://$DOMAIN/api/products/

# Test with keep-alive
echo -e "\n3. Keep-Alive Performance:"
ab -n $TOTAL_REQUESTS -c $CONCURRENT_USERS -k https://$DOMAIN/

# Test SSL performance
echo -e "\n4. SSL Performance:"
ab -n 1000 -c 20 -f TLS1.2 https://$DOMAIN/

# Cache hit ratio test
echo -e "\n5. Cache Performance:"
for i in {1..10}; do
    curl -s -I https://$DOMAIN/api/products/ | grep X-Cache-Status
done

# Connection test
echo -e "\n6. Connection Statistics:"
curl -s http://localhost:8080/nginx_status
```

### Performance Optimization Checklist
```bash
#!/bin/bash
# performance-check.sh - Performance configuration checker

echo "=== Nginx Performance Configuration Check ==="

# Check worker processes
WORKERS=$(nginx -T 2>/dev/null | grep "worker_processes" | head -1)
CPU_CORES=$(nproc)
echo "Worker processes: $WORKERS (CPU cores: $CPU_CORES)"

# Check worker connections
CONNECTIONS=$(nginx -T 2>/dev/null | grep "worker_connections" | head -1)
echo "Worker connections: $CONNECTIONS"

# Check gzip configuration
GZIP=$(nginx -T 2>/dev/null | grep "gzip on" | wc -l)
if [ $GZIP -gt 0 ]; then
    echo "✅ Gzip compression: Enabled"
else
    echo "❌ Gzip compression: Disabled"
fi

# Check sendfile
SENDFILE=$(nginx -T 2>/dev/null | grep "sendfile on" | wc -l)
if [ $SENDFILE -gt 0 ]; then
    echo "✅ Sendfile: Enabled"
else
    echo "❌ Sendfile: Disabled"
fi

# Check open file cache
CACHE=$(nginx -T 2>/dev/null | grep "open_file_cache" | wc -l)
if [ $CACHE -gt 0 ]; then
    echo "✅ Open file cache: Configured"
else
    echo "❌ Open file cache: Not configured"
fi

# Check SSL session cache
SSL_CACHE=$(nginx -T 2>/dev/null | grep "ssl_session_cache" | wc -l)
if [ $SSL_CACHE -gt 0 ]; then
    echo "✅ SSL session cache: Configured"
else
    echo "❌ SSL session cache: Not configured"
fi

echo -e "\n=== System Resource Check ==="
echo "CPU usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory usage: $(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"
echo "Disk usage: $(df -h / | awk 'NR==2{printf "%s", $5}')"
```

## 🎯 Practical Exercises

### Exercise 1: Worker Process Optimization
Configure optimal worker processes and connections for your system:
- Calculate optimal worker_processes
- Set appropriate worker_connections
- Configure CPU affinity
- Test performance improvements

### Exercise 2: Caching Implementation
Set up comprehensive caching:
- Proxy cache for API responses
- Static file caching
- Cache invalidation strategy
- Performance measurement

### Exercise 3: Compression Optimization
Implement advanced compression:
- Gzip configuration
- Pre-compression setup
- Brotli compression (if available)
- Performance comparison

---

**🎯 Next**: Monitoring, logging, and analytics  
**📚 Resources**: [Nginx Performance Tuning](https://nginx.org/en/docs/http/ngx_http_core_module.html)  
**🔧 Tools**: Use `ab`, `wrk`, or `siege` for performance testing
