# 📁 Nginx Static Content Optimization

## 📋 Overview

**Duration**: 3-4 Hours  
**Skill Level**: Intermediate  
**Prerequisites**: Virtual Hosts configuration completed  

Master static content serving optimization for maximum performance, including caching, compression, and CDN integration.

## 🎯 Learning Objectives

- Optimize static file serving for maximum performance
- Implement browser caching and cache control strategies
- Configure compression for different file types
- Set up efficient file serving with sendfile and TCP optimizations
- Integrate with CDN and implement cache invalidation

## 📚 Static File Serving Fundamentals

### Basic Static Content Configuration
```nginx
server {
    listen 80;
    server_name static.example.com;
    root /var/www/static;
    
    # Efficient file serving
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # Open file cache
    open_file_cache max=10000 inactive=5m;
    open_file_cache_valid 2m;
    open_file_cache_min_uses 1;
    open_file_cache_errors on;
    
    location / {
        try_files $uri $uri/ =404;
        
        # Basic caching
        expires 1d;
        add_header Cache-Control "public";
    }
}
```

### File Type Specific Optimization
```nginx
server {
    listen 80;
    server_name assets.example.com;
    root /var/www/assets;
    
    # Images - Long-term caching
    location ~* \.(jpg|jpeg|png|gif|ico|webp|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        
        # WebP support
        location ~* \.(png|jpg|jpeg)$ {
            add_header Vary Accept;
            try_files $uri$webp_suffix $uri =404;
        }
    }
    
    # CSS and JavaScript - Versioned assets
    location ~* \.(css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Gzip compression
        gzip_static on;
        
        # Security headers
        add_header X-Content-Type-Options nosniff;
    }
    
    # Fonts - Cross-origin support
    location ~* \.(woff|woff2|ttf|eot|otf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
        add_header Access-Control-Allow-Methods "GET, OPTIONS";
    }
    
    # Documents and media
    location ~* \.(pdf|doc|docx|zip|mp4|mp3)$ {
        expires 30d;
        add_header Cache-Control "public";
        
        # Large file optimization
        sendfile on;
        tcp_nopush on;
    }
    
    # HTML files - Short caching
    location ~* \.html$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }
}

# WebP detection
map $http_accept $webp_suffix {
    "~*webp" ".webp";
    default "";
}
```

## 🗜️ Advanced Compression

### Comprehensive Gzip Configuration
```nginx
http {
    # Gzip settings
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_proxied any;
    
    # Gzip file types
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        text/csv
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        application/x-javascript
        application/x-font-ttf
        application/vnd.ms-fontobject
        font/opentype
        image/svg+xml
        image/x-icon;
    
    # Brotli compression (if available)
    brotli on;
    brotli_comp_level 6;
    brotli_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}

server {
    listen 80;
    server_name compressed.example.com;
    root /var/www/compressed;
    
    location / {
        # Pre-compressed files
        gzip_static on;
        brotli_static on;
        
        try_files $uri $uri/ =404;
    }
}
```

### Pre-compression Setup
```bash
#!/bin/bash
# pre-compress.sh - Automated pre-compression

WEBROOT="/var/www/assets"
EXTENSIONS="css js html xml json svg"

echo "Starting pre-compression for $WEBROOT"

for ext in $EXTENSIONS; do
    echo "Compressing .$ext files..."
    
    # Gzip compression
    find $WEBROOT -name "*.$ext" -type f -exec gzip -k -9 {} \;
    
    # Brotli compression (if available)
    if command -v brotli &> /dev/null; then
        find $WEBROOT -name "*.$ext" -type f -exec brotli -k -9 {} \;
    fi
done

echo "Pre-compression complete"

# Set proper permissions
chown -R www-data:www-data $WEBROOT
find $WEBROOT -name "*.gz" -exec chmod 644 {} \;
find $WEBROOT -name "*.br" -exec chmod 644 {} \;
```

## 🚀 Performance Optimization

### E-Commerce Static Assets Configuration
```nginx
# CDN and static assets server
server {
    listen 80;
    listen 443 ssl http2;
    server_name cdn.shop.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/cdn.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/cdn.shop.example.com.key;
    
    root /var/www/ecommerce/static;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # CORS for cross-origin requests
    add_header Access-Control-Allow-Origin "https://shop.example.com" always;
    add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always;
    
    # Product images - Optimized delivery
    location /images/products/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Image optimization
        location ~* \.(jpg|jpeg|png)$ {
            # WebP support
            add_header Vary Accept;
            try_files $uri$webp_suffix $uri =404;
            
            # Image resizing (if using image processing module)
            # image_filter resize 800 600;
            # image_filter_jpeg_quality 85;
        }
    }
    
    # CSS and JavaScript bundles
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # Pre-compressed files
        gzip_static on;
        brotli_static on;
        
        # Security for JS files
        location ~* \.js$ {
            add_header Content-Security-Policy "script-src 'self'" always;
        }
    }
    
    # User uploaded content
    location /uploads/ {
        expires 30d;
        add_header Cache-Control "public";
        
        # Security restrictions
        location ~* \.(php|asp|jsp|cgi|pl)$ {
            deny all;
        }
        
        # File size limits
        client_max_body_size 10m;
    }
    
    # Favicon and robots
    location = /favicon.ico {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
        log_not_found off;
    }
    
    location = /robots.txt {
        expires 1d;
        add_header Cache-Control "public";
        access_log off;
    }
}
```

### Advanced File Serving
```nginx
server {
    listen 80;
    server_name files.example.com;
    root /var/www/files;
    
    # Large file optimization
    location /downloads/ {
        # Efficient large file serving
        sendfile on;
        tcp_nopush on;
        tcp_nodelay off;
        
        # Range requests support
        add_header Accept-Ranges bytes;
        
        # Download headers
        add_header Content-Disposition "attachment";
        
        # Rate limiting for downloads
        limit_rate 1m;  # 1MB/s per connection
        
        # Security
        internal;  # Only accessible via X-Accel-Redirect
    }
    
    # Streaming media
    location /media/ {
        # MP4 streaming support
        location ~* \.mp4$ {
            mp4;
            mp4_buffer_size 1m;
            mp4_max_buffer_size 5m;
        }
        
        # FLV streaming support
        location ~* \.flv$ {
            flv;
        }
        
        expires 7d;
        add_header Cache-Control "public";
    }
    
    # Protected downloads (X-Accel-Redirect)
    location /protected/ {
        internal;
        alias /var/www/protected/;
    }
    
    # API endpoint for protected downloads
    location /download/ {
        # Authentication check would go here
        # Then redirect to protected location
        add_header X-Accel-Redirect /protected/$arg_file;
        return 200;
    }
}
```

## 📊 Cache Control Strategies

### Advanced Cache Control
```nginx
# Cache control mapping
map $sent_http_content_type $expires {
    default                    off;
    text/html                  1h;
    text/css                   1y;
    application/javascript     1y;
    ~image/                    1y;
    ~font/                     1y;
    application/pdf            30d;
    ~video/                    30d;
}

server {
    listen 80;
    server_name cache.example.com;
    root /var/www/cache;
    
    # Dynamic expires based on content type
    expires $expires;
    
    # ETag configuration
    etag on;
    
    # If-Modified-Since handling
    if_modified_since exact;
    
    # Conditional requests
    location / {
        try_files $uri $uri/ =404;
        
        # Cache busting for development
        if ($arg_v) {
            expires epoch;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
    }
    
    # API responses (no cache)
    location /api/ {
        expires epoch;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        
        proxy_pass http://backend;
    }
    
    # Versioned assets (aggressive caching)
    location ~* \.(css|js)\?v=[\d\w]+$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### CDN Integration
```nginx
# CDN-optimized configuration
server {
    listen 80;
    server_name cdn-origin.example.com;
    root /var/www/cdn;
    
    # CDN-friendly headers
    location / {
        # Long-term caching for CDN
        expires 1y;
        add_header Cache-Control "public, max-age=31536000, immutable";
        
        # CDN headers
        add_header X-CDN-Cache "MISS" always;
        add_header Vary "Accept-Encoding, Accept";
        
        # CORS for CDN
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always;
        
        # Efficient serving
        sendfile on;
        tcp_nopush on;
        
        try_files $uri =404;
    }
    
    # Cache purge endpoint (for CDN invalidation)
    location /purge/ {
        allow 192.168.1.0/24;  # CDN servers
        deny all;
        
        # Custom purge logic would go here
        return 200 "Purge requested for $arg_url";
    }
    
    # Health check for CDN
    location /cdn-health {
        access_log off;
        return 200 "CDN Origin Healthy";
        add_header Content-Type text/plain;
    }
}
```

## 🎯 Practical Implementation

### Complete E-Commerce Static Setup
```nginx
# Main e-commerce static assets server
server {
    listen 443 ssl http2;
    server_name static.shop.example.com;
    
    ssl_certificate /etc/ssl/certs/static.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/static.shop.example.com.key;
    
    root /var/www/ecommerce/static;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # CORS for main domain
    add_header Access-Control-Allow-Origin "https://shop.example.com" always;
    
    # Product catalog images
    location /catalog/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # WebP support
        location ~* \.(jpg|jpeg|png)$ {
            add_header Vary Accept;
            try_files $uri$webp_suffix $uri =404;
        }
        
        # Thumbnail generation (if using image processing)
        location ~ ^/catalog/(.+)_(\d+)x(\d+)\.(jpg|jpeg|png)$ {
            try_files $uri @resize;
        }
    }
    
    # CSS and JavaScript assets
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        gzip_static on;
        brotli_static on;
        
        # Prevent hotlinking
        valid_referers none blocked server_names *.shop.example.com;
        if ($invalid_referer) {
            return 403;
        }
    }
    
    # User uploads (with security)
    location /uploads/ {
        expires 30d;
        add_header Cache-Control "public";
        
        # Block script execution
        location ~* \.(php|asp|jsp|cgi|pl|py|rb)$ {
            deny all;
        }
        
        # File type restrictions
        location ~* \.(exe|bat|sh|com|scr)$ {
            deny all;
        }
    }
    
    # Resize endpoint (internal)
    location @resize {
        internal;
        # Image resizing logic would go here
        # This requires additional modules like ngx_http_image_filter_module
    }
}
```

### Performance Monitoring
```bash
#!/bin/bash
# static-performance-monitor.sh

DOMAIN="static.shop.example.com"
LOG_FILE="/var/log/nginx/static_performance.log"

echo "=== Static Content Performance Monitor ===" | tee -a $LOG_FILE
echo "Timestamp: $(date)" | tee -a $LOG_FILE

# Test static file performance
echo "Testing static file performance:" | tee -a $LOG_FILE

# Test different file types
FILES=("css/main.css" "js/app.js" "images/logo.png" "fonts/main.woff2")

for file in "${FILES[@]}"; do
    echo "Testing $file:" | tee -a $LOG_FILE
    
    # Test response time and caching
    RESULT=$(curl -w "Time: %{time_total}s, Size: %{size_download} bytes, Cache: %{http_cache_control}\n" \
                  -o /dev/null -s "https://$DOMAIN/$file")
    
    echo "$RESULT" | tee -a $LOG_FILE
done

# Test compression
echo "Testing compression:" | tee -a $LOG_FILE
GZIP_TEST=$(curl -H "Accept-Encoding: gzip" -s -I "https://$DOMAIN/css/main.css" | grep -i "content-encoding")
echo "Gzip: $GZIP_TEST" | tee -a $LOG_FILE

# Test cache headers
echo "Testing cache headers:" | tee -a $LOG_FILE
CACHE_TEST=$(curl -s -I "https://$DOMAIN/images/logo.png" | grep -i "cache-control\|expires")
echo "$CACHE_TEST" | tee -a $LOG_FILE
```

## 🎯 Practical Exercises

### Exercise 1: Static Asset Optimization
Configure optimized static file serving:
- File type specific caching
- Compression setup
- Performance optimization
- Security headers

### Exercise 2: CDN Integration
Set up CDN-ready configuration:
- CORS headers
- Cache control optimization
- Purge endpoints
- Performance monitoring

### Exercise 3: E-Commerce Assets
Implement complete e-commerce static setup:
- Product image optimization
- Asset bundling and caching
- User upload security
- Performance validation

---

**🎯 Next**: Dynamic content and FastCGI configuration  
**📚 Resources**: [Nginx Static Content](https://nginx.org/en/docs/http/ngx_http_core_module.html#sendfile)  
**🔧 Tools**: Use browser dev tools and `curl` to test caching and compression
