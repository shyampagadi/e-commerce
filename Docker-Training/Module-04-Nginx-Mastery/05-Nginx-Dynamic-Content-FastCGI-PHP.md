# 🔄 Nginx Dynamic Content & FastCGI/PHP Configuration

## 📋 Overview

**Duration**: 4-5 Hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites**: Static Content Optimization completed  

Master dynamic content serving with Nginx, including FastCGI, PHP-FPM, and other dynamic content processors for high-performance web applications.

## 🎯 Learning Objectives

- Configure FastCGI and PHP-FPM with Nginx
- Optimize dynamic content performance and caching
- Implement security best practices for dynamic content
- Set up load balancing for PHP applications
- Configure other dynamic content processors (Python, Node.js, etc.)

## 📚 FastCGI Fundamentals

### Basic PHP-FPM Configuration
```nginx
# PHP-FPM upstream
upstream php_backend {
    server unix:/var/run/php/php8.1-fpm.sock;
    # Alternative: server 127.0.0.1:9000;
}

server {
    listen 80;
    server_name php.example.com;
    root /var/www/php.example.com;
    index index.php index.html;
    
    # PHP processing
    location ~ \.php$ {
        try_files $uri =404;
        
        fastcgi_pass php_backend;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        
        # Standard FastCGI parameters
        include fastcgi_params;
        
        # Additional parameters
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_param REQUEST_METHOD $request_method;
        fastcgi_param CONTENT_TYPE $content_type;
        fastcgi_param CONTENT_LENGTH $content_length;
        fastcgi_param SCRIPT_NAME $fastcgi_script_name;
        fastcgi_param REQUEST_URI $request_uri;
        fastcgi_param DOCUMENT_URI $document_uri;
        fastcgi_param DOCUMENT_ROOT $document_root;
        fastcgi_param SERVER_PROTOCOL $server_protocol;
        fastcgi_param REMOTE_ADDR $remote_addr;
        fastcgi_param REMOTE_PORT $remote_port;
        fastcgi_param SERVER_ADDR $server_addr;
        fastcgi_param SERVER_PORT $server_port;
        fastcgi_param SERVER_NAME $server_name;
        fastcgi_param HTTPS $https if_not_empty;
    }
    
    # Static files
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security - deny access to sensitive files
    location ~ /\.(ht|git|svn) {
        deny all;
    }
    
    location ~ \.php$ {
        deny all;
    }
}
```

### Advanced FastCGI Configuration
```nginx
# Multiple PHP versions support
upstream php81 {
    server unix:/var/run/php/php8.1-fpm.sock;
}

upstream php80 {
    server unix:/var/run/php/php8.0-fpm.sock;
}

upstream php74 {
    server unix:/var/run/php/php7.4-fpm.sock;
}

server {
    listen 80;
    server_name multi-php.example.com;
    root /var/www/multi-php;
    
    # Default to PHP 8.1
    location ~ \.php$ {
        try_files $uri =404;
        
        fastcgi_pass php81;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # FastCGI optimization
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 60s;
        fastcgi_read_timeout 60s;
    }
    
    # PHP 8.0 for legacy applications
    location /legacy/ {
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass php80;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
    
    # PHP 7.4 for older applications
    location /old/ {
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_pass php74;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

## 🚀 Performance Optimization

### FastCGI Caching
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
    server_name cached-php.example.com;
    root /var/www/cached-php;
    
    # Cache bypass conditions
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
    if ($request_uri ~* "/(admin|login|wp-admin|dashboard)") {
        set $skip_cache 1;
    }
    
    # Skip cache for logged-in users (cookie-based)
    if ($http_cookie ~* "logged_in|wordpress_logged_in") {
        set $skip_cache 1;
    }
    
    location ~ \.php$ {
        try_files $uri =404;
        
        # FastCGI cache configuration
        fastcgi_cache php_cache;
        fastcgi_cache_key "$scheme$request_method$host$request_uri";
        fastcgi_cache_valid 200 302 5m;
        fastcgi_cache_valid 301 1h;
        fastcgi_cache_valid 404 1m;
        fastcgi_cache_valid any 1m;
        
        # Cache control
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        fastcgi_cache_use_stale error timeout updating http_500 http_503;
        fastcgi_cache_background_update on;
        fastcgi_cache_lock on;
        
        # Cache headers
        add_header X-FastCGI-Cache $upstream_cache_status always;
        add_header X-Cache-Skip $skip_cache always;
        
        fastcgi_pass php_backend;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Cache purge endpoint
    location ~ /purge(/.*) {
        allow 127.0.0.1;
        allow 192.168.1.0/24;
        deny all;
        
        fastcgi_cache_purge php_cache "$scheme$request_method$host$1";
    }
}
```

### Load Balancing PHP-FPM
```nginx
# Multiple PHP-FPM pools
upstream php_pool_1 {
    server unix:/var/run/php/php-fpm-pool1.sock weight=3;
    server unix:/var/run/php/php-fpm-pool2.sock weight=2;
    server unix:/var/run/php/php-fpm-pool3.sock weight=1;
    server unix:/var/run/php/php-fpm-backup.sock backup;
}

upstream php_pool_2 {
    least_conn;
    server 127.0.0.1:9001 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:9002 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:9003 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name balanced-php.example.com;
    root /var/www/balanced-php;
    
    # Main application (pool 1)
    location ~ \.php$ {
        try_files $uri =404;
        
        fastcgi_pass php_pool_1;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # Load balancing headers
        add_header X-PHP-Pool "pool1" always;
        add_header X-Upstream-Server $upstream_addr always;
    }
    
    # Heavy processing (dedicated pool)
    location /heavy/ {
        location ~ \.php$ {
            try_files $uri =404;
            
            fastcgi_pass php_pool_2;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            
            # Extended timeouts for heavy processing
            fastcgi_connect_timeout 120s;
            fastcgi_send_timeout 120s;
            fastcgi_read_timeout 120s;
        }
    }
}
```

## 🔒 Security Configuration

### Secure PHP Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name secure-php.example.com;
    root /var/www/secure-php;
    
    ssl_certificate /etc/ssl/certs/secure-php.example.com.crt;
    ssl_certificate_key /etc/ssl/private/secure-php.example.com.key;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # PHP security configuration
    location ~ \.php$ {
        # Security checks
        if ($request_method !~ ^(GET|POST|HEAD)$) {
            return 405;
        }
        
        # Block suspicious requests
        if ($query_string ~* "(\<|%3C).*script.*(\>|%3E)") {
            return 403;
        }
        
        if ($query_string ~* "GLOBALS(=|\[|\%[0-9A-Z]{0,2})") {
            return 403;
        }
        
        if ($query_string ~* "_REQUEST(=|\[|\%[0-9A-Z]{0,2})") {
            return 403;
        }
        
        try_files $uri =404;
        
        fastcgi_pass php_backend;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # Security parameters
        fastcgi_param HTTPS $https if_not_empty;
        fastcgi_param HTTP_SCHEME $scheme;
        fastcgi_param SERVER_HTTPS $https if_not_empty;
        
        # Hide PHP version
        fastcgi_hide_header X-Powered-By;
    }
    
    # Block access to sensitive PHP files
    location ~* /(config|includes|lib|vendor)/.+\.php$ {
        deny all;
    }
    
    # Block PHP execution in uploads
    location /uploads/ {
        location ~ \.php$ {
            deny all;
        }
    }
    
    # Block common attack files
    location ~* \.(sql|bak|backup|old|tmp)$ {
        deny all;
    }
}
```

## 🎯 E-Commerce PHP Application

### WordPress/WooCommerce Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name shop-wp.example.com;
    root /var/www/wordpress;
    index index.php index.html;
    
    ssl_certificate /etc/ssl/certs/shop-wp.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop-wp.example.com.key;
    
    # WordPress-specific cache bypass
    set $skip_cache 0;
    
    # Skip cache for logged-in users
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
        set $skip_cache 1;
    }
    
    # Skip cache for WooCommerce pages
    if ($request_uri ~* "/store.*|/cart.*|/my-account.*|/checkout.*|/addons.*") {
        set $skip_cache 1;
    }
    
    # Skip cache for admin and login
    if ($request_uri ~* "wp-admin|wp-login") {
        set $skip_cache 1;
    }
    
    # Main WordPress location
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    # PHP processing with caching
    location ~ \.php$ {
        try_files $uri =404;
        
        # FastCGI cache
        fastcgi_cache php_cache;
        fastcgi_cache_key "$scheme$request_method$host$request_uri";
        fastcgi_cache_valid 200 5m;
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        
        fastcgi_pass php_backend;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # WordPress-specific parameters
        fastcgi_param WP_ENV production;
        fastcgi_param WP_HOME https://shop-wp.example.com;
        fastcgi_param WP_SITEURL https://shop-wp.example.com;
    }
    
    # WooCommerce API (no cache)
    location /wp-json/wc/ {
        try_files $uri $uri/ /index.php?$args;
        
        # No caching for API
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
    
    # Static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        log_not_found off;
    }
    
    # Security
    location ~ /\.(ht|git|svn) {
        deny all;
    }
    
    location ~* wp-config\.php {
        deny all;
    }
}
```

## 🐍 Other Dynamic Content Processors

### Python/Django Configuration
```nginx
# Python/Django with uWSGI
upstream django_backend {
    server unix:/tmp/django.sock;
}

server {
    listen 80;
    server_name django.example.com;
    
    location / {
        uwsgi_pass django_backend;
        include uwsgi_params;
        
        # uWSGI parameters
        uwsgi_param Host $host;
        uwsgi_param X-Real-IP $remote_addr;
        uwsgi_param X-Forwarded-For $proxy_add_x_forwarded_for;
        uwsgi_param X-Forwarded-Proto $scheme;
    }
    
    # Static files (served by Nginx)
    location /static/ {
        alias /var/www/django/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /media/ {
        alias /var/www/django/media/;
        expires 30d;
        add_header Cache-Control "public";
    }
}
```

### Node.js Configuration
```nginx
# Node.js application
upstream nodejs_backend {
    server 127.0.0.1:3000;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    keepalive 32;
}

server {
    listen 80;
    server_name node.example.com;
    
    location / {
        proxy_pass http://nodejs_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Node.js specific timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # WebSocket support
    location /socket.io/ {
        proxy_pass http://nodejs_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📊 Monitoring and Debugging

### FastCGI Monitoring
```nginx
# FastCGI status endpoint
server {
    listen 8080;
    server_name localhost;
    
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    deny all;
    
    location /php-status {
        fastcgi_pass php_backend;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # PHP-FPM status page
        fastcgi_param SCRIPT_NAME /status;
    }
    
    location /php-ping {
        fastcgi_pass php_backend;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        # PHP-FPM ping page
        fastcgi_param SCRIPT_NAME /ping;
    }
}
```

### Performance Testing
```bash
#!/bin/bash
# php-performance-test.sh

DOMAIN="php.example.com"
PHP_SCRIPT="/test.php"

echo "=== PHP Performance Test ==="

# Test PHP response time
echo "1. PHP Response Time Test:"
for i in {1..10}; do
    TIME=$(curl -w "%{time_total}" -o /dev/null -s "http://$DOMAIN$PHP_SCRIPT")
    echo "Request $i: ${TIME}s"
done

# Test FastCGI cache
echo -e "\n2. FastCGI Cache Test:"
for i in {1..5}; do
    CACHE_STATUS=$(curl -s -I "http://$DOMAIN$PHP_SCRIPT" | grep X-FastCGI-Cache)
    echo "Request $i: $CACHE_STATUS"
done

# Load test
echo -e "\n3. Load Test:"
ab -n 100 -c 10 "http://$DOMAIN$PHP_SCRIPT"
```

## 🎯 Practical Exercises

### Exercise 1: PHP-FPM Setup
Configure PHP-FPM with Nginx:
- Multiple PHP versions
- FastCGI caching
- Security hardening
- Performance optimization

### Exercise 2: WordPress Optimization
Set up optimized WordPress/WooCommerce:
- Cache bypass rules
- Security configuration
- Performance tuning
- Load balancing

### Exercise 3: Multi-Language Support
Configure multiple dynamic processors:
- PHP applications
- Python/Django apps
- Node.js applications
- Performance comparison

---

**🎯 Next**: Monitoring, logging, and analytics  
**📚 Resources**: [Nginx FastCGI Module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)  
**🔧 Tools**: Use `php-fpm` status pages and monitoring tools for optimization
