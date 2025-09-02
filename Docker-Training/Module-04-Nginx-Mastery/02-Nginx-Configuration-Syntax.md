# 🔧 Nginx Configuration Syntax Complete Reference

## 📋 Overview

**Duration**: 6-8 Hours  
**Skill Level**: Intermediate  
**Prerequisites**: Basic Nginx installation completed  

This comprehensive guide covers every aspect of Nginx configuration syntax, directives, contexts, and advanced configuration patterns for building production-ready web server configurations.

## 🎯 Learning Objectives

- Master Nginx configuration file structure and syntax
- Understand all configuration contexts and their hierarchy
- Implement advanced directive usage and inheritance
- Configure complex server blocks and location matching
- Debug and validate Nginx configurations
- Apply configuration best practices and optimization techniques

## 📚 Nginx Configuration Fundamentals

### Configuration File Structure

Nginx configuration follows a hierarchical block structure with contexts containing directives and other contexts.

```nginx
# Main context (global)
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# Events context
events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

# HTTP context
http {
    # HTTP-level directives
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Server context
    server {
        # Server-level directives
        listen 80;
        server_name example.com;
        
        # Location context
        location / {
            # Location-level directives
            root /var/www/html;
            index index.html;
        }
    }
}
```

### Configuration Syntax Rules

```nginx
# 1. Directives end with semicolon
worker_processes 4;
keepalive_timeout 65;

# 2. Blocks use curly braces
server {
    listen 80;
}

# 3. Comments start with #
# This is a comment
server_name example.com; # Inline comment

# 4. Include files
include /etc/nginx/conf.d/*.conf;
include mime.types;

# 5. Variables start with $
set $root_path /var/www;
root $root_path/html;

# 6. String values can be quoted or unquoted
server_name "example.com";
server_name example.com;

# 7. Regular expressions use ~ and ~*
location ~ \.php$ {
    # PHP files
}

location ~* \.(jpg|jpeg|png|gif)$ {
    # Image files (case-insensitive)
}
```

## 🏗️ Configuration Contexts

### 1. Main Context (Global)

The main context contains directives that affect the entire Nginx process.

```nginx
# Process and file settings
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
pid /var/run/nginx.pid;

# Error logging
error_log /var/log/nginx/error.log warn;

# Load dynamic modules
load_module modules/ngx_http_geoip_module.so;

# Include additional configuration files
include /etc/nginx/modules-enabled/*.conf;
```

#### Key Main Context Directives

```nginx
# Worker process configuration
user nginx;                    # User to run worker processes
worker_processes auto;         # Number of worker processes (auto = CPU cores)
worker_cpu_affinity auto;      # Bind workers to CPU cores
worker_rlimit_nofile 65535;   # Max open files per worker

# Process identification
pid /var/run/nginx.pid;       # PID file location
lock_file /var/lock/nginx.lock; # Lock file for shared memory

# Error handling
error_log /var/log/nginx/error.log warn; # Error log location and level
# Levels: debug, info, notice, warn, error, crit, alert, emerg

# Dynamic modules
load_module modules/ngx_http_realip_module.so;
load_module modules/ngx_http_geoip_module.so;

# Working directory
working_directory /var/cache/nginx;

# Core dumps (for debugging)
worker_rlimit_core 500M;
```

### 2. Events Context

The events context configures connection processing methods.

```nginx
events {
    # Connection method (Linux: epoll, FreeBSD: kqueue)
    use epoll;
    
    # Maximum connections per worker
    worker_connections 1024;
    
    # Accept multiple connections at once
    multi_accept on;
    
    # Accept mutex for load balancing
    accept_mutex on;
    accept_mutex_delay 500ms;
    
    # Debug connections
    debug_connection 192.168.1.1;
    debug_connection 10.0.0.0/8;
}
```

#### Events Context Directives Explained

```nginx
events {
    # Connection processing method
    use epoll;                 # Linux: epoll, kqueue, select, poll
    
    # Worker connections
    worker_connections 4096;   # Max connections per worker process
    # Total connections = worker_processes × worker_connections
    
    # Connection acceptance
    multi_accept on;           # Accept multiple connections at once
    accept_mutex on;           # Serialize accept() calls
    accept_mutex_delay 500ms;  # Delay before trying accept mutex again
    
    # Debugging
    debug_connection 127.0.0.1;     # Debug specific IP
    debug_connection localhost;      # Debug specific hostname
    debug_connection 192.168.0.0/16; # Debug IP range
}
```

### 3. HTTP Context

The HTTP context contains directives for HTTP server configuration.

```nginx
http {
    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    # Access logging
    access_log /var/log/nginx/access.log main;
    
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Server tokens (security)
    server_tokens off;
    
    # Client settings
    client_max_body_size 64M;
    client_body_timeout 12;
    client_header_timeout 12;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript;
    
    # Include server configurations
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

### 4. Server Context

The server context defines virtual hosts and server-specific settings.

```nginx
server {
    # Listening configuration
    listen 80;
    listen [::]:80;  # IPv6
    listen 443 ssl http2;  # HTTPS with HTTP/2
    
    # Server identification
    server_name example.com www.example.com;
    server_name *.example.com;  # Wildcard
    server_name ~^(?<subdomain>.+)\.example\.com$;  # Regex with capture
    
    # Document root
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    # Logging
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # Location blocks
    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### Advanced Server Block Patterns

```nginx
# Multiple server names
server {
    listen 80;
    server_name example.com www.example.com api.example.com;
}

# Wildcard server names
server {
    listen 80;
    server_name *.example.com;  # Matches any subdomain
    server_name .example.com;   # Matches example.com and any subdomain
}

# Regular expression server names
server {
    listen 80;
    server_name ~^(?<user>.+)\.users\.example\.com$;
    root /var/www/users/$user;
}

# Default server (catch-all)
server {
    listen 80 default_server;
    server_name _;
    return 444;  # Close connection without response
}

# IP-based virtual hosting
server {
    listen 192.168.1.100:80;
    server_name example.com;
}

# Port-based virtual hosting
server {
    listen 8080;
    server_name example.com;
}
```

### 5. Location Context

The location context defines how to process requests for specific URIs.

```nginx
# Exact match
location = /favicon.ico {
    log_not_found off;
    access_log off;
}

# Prefix match
location /images/ {
    root /var/www;
    expires 30d;
}

# Regular expression match (case-sensitive)
location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
}

# Regular expression match (case-insensitive)
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Named location (for internal redirects)
location @fallback {
    proxy_pass http://backend;
}
```

#### Location Matching Priority

```nginx
server {
    listen 80;
    server_name example.com;
    
    # 1. Exact match (highest priority)
    location = /exact {
        return 200 "Exact match";
    }
    
    # 2. Preferential prefix match
    location ^~ /prefix {
        return 200 "Preferential prefix";
    }
    
    # 3. Regular expression match (in order of appearance)
    location ~ /regex {
        return 200 "Regex match";
    }
    
    location ~* /case-insensitive {
        return 200 "Case-insensitive regex";
    }
    
    # 4. Prefix match (lowest priority)
    location /prefix {
        return 200 "Regular prefix";
    }
    
    # 5. Default location
    location / {
        return 200 "Default location";
    }
}
```

## 🔧 Core Directives Reference

### File and Path Directives

```nginx
# Document root
root /var/www/html;
root /var/www/$host;  # Using variables

# Alias (alternative to root)
location /images/ {
    alias /var/www/static/img/;
}

# Index files
index index.html index.htm index.php;
index index-$geo.html index.html;  # Using variables

# Try files in order
try_files $uri $uri/ @fallback;
try_files $uri $uri/ /index.php?$query_string;

# Internal redirects
location @fallback {
    proxy_pass http://backend;
}
```

### Client Request Directives

```nginx
# Request body size
client_max_body_size 64M;
client_body_buffer_size 128k;
client_body_timeout 12s;

# Request headers
client_header_buffer_size 1k;
large_client_header_buffers 4 8k;
client_header_timeout 12s;

# Keep-alive connections
keepalive_timeout 65s;
keepalive_requests 100;

# Request rate limiting
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
limit_req zone=login burst=5 nodelay;
```

### Response and Caching Directives

```nginx
# Response headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;

# Expires and caching
expires 1y;
expires modified +1h;
expires @15h30m;  # Specific time
expires -1;       # No cache
expires epoch;    # January 1, 1970

# ETag handling
etag on;
if_modified_since exact;

# Content compression
gzip on;
gzip_comp_level 6;
gzip_min_length 1000;
gzip_types text/plain text/css application/json;
```

### Proxy and Upstream Directives

```nginx
# Proxy configuration
proxy_pass http://backend;
proxy_pass http://127.0.0.1:8080;
proxy_pass http://unix:/tmp/backend.socket;

# Proxy headers
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

# Proxy timeouts
proxy_connect_timeout 30s;
proxy_send_timeout 30s;
proxy_read_timeout 30s;

# Proxy buffering
proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;
```

## 🌐 Advanced Configuration Patterns

### Virtual Host Configuration

```nginx
# Complete virtual host example
server {
    # Basic server configuration
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    # HTTPS configuration
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;
    
    # SSL certificates
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Document root and index
    root /var/www/example.com;
    index index.html index.htm index.php;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Main location
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # PHP processing
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Static assets
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        log_not_found off;
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(config|logs|temp)/ {
        deny all;
    }
}
```

### Reverse Proxy Configuration

```nginx
# Upstream backend servers
upstream backend {
    server 127.0.0.1:8001 weight=3;
    server 127.0.0.1:8002 weight=2;
    server 127.0.0.1:8003 backup;
    
    # Load balancing method
    least_conn;
    
    # Health checks
    keepalive 32;
}

server {
    listen 80;
    server_name api.example.com;
    
    # Proxy to backend
    location / {
        proxy_pass http://backend;
        
        # Proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Proxy timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Proxy buffering
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        
        # Error handling
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 30s;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Load Balancing Configuration

```nginx
# Different load balancing methods
upstream backend_round_robin {
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

upstream backend_least_conn {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

upstream backend_ip_hash {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

upstream backend_weighted {
    server backend1.example.com weight=3;
    server backend2.example.com weight=2;
    server backend3.example.com weight=1;
}

upstream backend_with_backup {
    server backend1.example.com max_fails=3 fail_timeout=30s;
    server backend2.example.com max_fails=3 fail_timeout=30s;
    server backup.example.com backup;
}
```

## 🔍 Variables and Conditionals

### Built-in Variables

```nginx
# Request variables
$request_method     # GET, POST, etc.
$request_uri        # Full original request URI
$uri               # Current URI in request
$args              # Query string arguments
$query_string      # Same as $args

# Client variables
$remote_addr       # Client IP address
$remote_user       # Username from HTTP auth
$http_user_agent   # User-Agent header
$http_referer      # Referer header
$http_host         # Host header

# Server variables
$server_name       # Server name
$server_port       # Server port
$scheme           # http or https
$host             # Host from request line or Host header

# Time variables
$time_local       # Local time
$time_iso8601     # ISO 8601 time format
$msec            # Current time in milliseconds

# Response variables
$status          # Response status code
$body_bytes_sent # Number of bytes sent to client
$bytes_sent      # Total bytes sent to client
```

### Custom Variables

```nginx
# Set custom variables
set $mobile_rewrite do_not_perform;

# Conditional variable setting
if ($http_user_agent ~* "(android|bb\d+|meego).+mobile|avantgo|bada/") {
    set $mobile_rewrite perform;
}

# Map directive for complex variable mapping
map $http_user_agent $mobile {
    default 0;
    "~Opera Mini" 1;
    "~Mobile" 1;
    "~iPhone" 1;
    "~Android" 1;
}

# Geographic variables (requires GeoIP module)
geoip_country /usr/share/GeoIP/GeoIP.dat;
map $geoip_country_code $allowed_country {
    default no;
    US yes;
    CA yes;
    GB yes;
}
```

### Conditional Configuration

```nginx
# Basic if conditions
location / {
    if ($request_method = POST) {
        return 405;
    }
    
    if ($http_user_agent ~ MSIE) {
        rewrite ^(.*)$ /msie/$1 break;
    }
    
    if ($http_cookie ~* "id=([^;]+)(?:;|$)") {
        set $id $1;
    }
}

# Complex conditionals with map
map $request_method $not_allowed_method {
    default 0;
    POST 1;
    PUT 1;
    DELETE 1;
}

server {
    if ($not_allowed_method) {
        return 405;
    }
}
```

## 🎯 Practical Configuration Examples

### E-Commerce Application Configuration

```nginx
# E-commerce Nginx configuration
upstream backend_api {
    server 127.0.0.1:8000;
    keepalive 32;
}

server {
    listen 80;
    server_name ecommerce.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ecommerce.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/ecommerce.crt;
    ssl_certificate_key /etc/ssl/private/ecommerce.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Frontend (React app)
    location / {
        root /var/www/ecommerce/build;
        index index.html;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://backend_api/;
        
        # Proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers for API
        add_header Access-Control-Allow-Origin "https://ecommerce.example.com" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
        
        # Handle preflight requests
        if ($request_method = OPTIONS) {
            return 204;
        }
    }
    
    # File uploads
    location /uploads/ {
        root /var/www/ecommerce;
        expires 30d;
        add_header Cache-Control "public";
    }
    
    # Admin panel (restricted access)
    location /admin/ {
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        proxy_pass http://backend_api/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📊 Configuration Validation and Testing

### Syntax Validation

```bash
# Test configuration syntax
nginx -t

# Test configuration with specific file
nginx -t -c /etc/nginx/nginx.conf

# Test and dump configuration
nginx -T

# Check configuration and exit
nginx -t && echo "Configuration is valid"
```

### Configuration Debugging

```nginx
# Enable debug logging
error_log /var/log/nginx/debug.log debug;

# Debug specific connections
events {
    debug_connection 192.168.1.100;
}

# Debug location matching
location /debug/ {
    add_header X-Debug-Location "Debug location matched" always;
    return 200 "Debug location\n";
}
```

### Performance Testing

```bash
# Test with Apache Bench
ab -n 1000 -c 10 http://example.com/

# Test with curl
curl -w "@curl-format.txt" -o /dev/null -s http://example.com/

# curl-format.txt content:
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

---

**🎯 Next**: Virtual hosts and server blocks configuration  
**📚 Resources**: [Nginx Configuration Reference](https://nginx.org/en/docs/dirindex.html)  
**🔧 Tools**: Use `nginx -t` to validate configurations before applying
