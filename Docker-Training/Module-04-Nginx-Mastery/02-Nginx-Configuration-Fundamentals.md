# 🔧 Nginx Configuration Fundamentals: Complete Expert Guide

## 🎯 Learning Objectives
- Master Nginx configuration syntax and structure
- Understand server blocks and virtual hosts
- Learn location directives and request routing
- Configure basic web server functionality

---

## 📚 Nginx Configuration Syntax

### Configuration File Structure
```nginx
# Global context (main)
user nginx;
worker_processes auto;

# Events context
events {
    worker_connections 1024;
}

# HTTP context
http {
    # HTTP directives
    
    # Server context
    server {
        # Server directives
        
        # Location context
        location / {
            # Location directives
        }
    }
}
```

### Syntax Rules

#### Directives and Blocks
```nginx
# Simple directive (ends with semicolon)
worker_processes 4;

# Block directive (contains other directives)
http {
    # Nested directives
    sendfile on;
    
    server {
        listen 80;
    }
}
```

#### Comments
```nginx
# This is a single-line comment
worker_processes auto;  # Inline comment

# Multi-line comments require # on each line
# This is line 1 of comment
# This is line 2 of comment
```

#### Variables
```nginx
# Built-in variables
$remote_addr        # Client IP address
$request_uri        # Full original request URI
$host              # Host header value
$server_name       # Server name
$request_method    # HTTP method (GET, POST, etc.)

# Custom variables
set $custom_var "value";
set $backend_pool "backend1";
```

#### String Values
```nginx
# Simple string
root /var/www/html;

# Quoted string (for spaces or special characters)
error_page 404 "/custom 404 page.html";

# Variable interpolation
root /var/www/$host;
```

---

## 🏗️ Configuration Contexts Deep Dive

### Main Context (Global)
```nginx
# Process management
user nginx;                    # User to run worker processes
worker_processes auto;         # Number of worker processes
worker_rlimit_nofile 65535;   # Max open files per worker

# Error logging
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# Load dynamic modules
load_module modules/ngx_http_geoip_module.so;
```

**Expected nginx -t Output:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Events Context
```nginx
events {
    # Connection processing method
    use epoll;                 # Linux: epoll, BSD: kqueue, Windows: select
    
    # Worker connections
    worker_connections 1024;   # Max connections per worker
    multi_accept on;          # Accept multiple connections at once
    
    # Connection processing
    accept_mutex on;          # Serialize accept() calls
    accept_mutex_delay 500ms; # Delay before trying accept() again
}
```

**Performance Calculation:**
```
Max Connections = worker_processes × worker_connections
Example: 4 workers × 1024 connections = 4096 total connections
```

### HTTP Context
```nginx
http {
    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    # Performance settings
    sendfile on;              # Efficient file serving
    tcp_nopush on;           # Send headers in one packet
    tcp_nodelay on;          # Don't buffer small packets
    keepalive_timeout 65;    # Keep connections alive
    
    # Compression
    gzip on;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript;
    
    # Include server configurations
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

---

## 🌐 Server Blocks (Virtual Hosts)

### Basic Server Block
```nginx
server {
    # Listening configuration
    listen 80;                    # IPv4 port 80
    listen [::]:80;              # IPv6 port 80
    
    # Server identification
    server_name example.com www.example.com;
    
    # Document root
    root /var/www/example.com;
    index index.html index.htm;
    
    # Basic location
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Listen Directive Options
```nginx
server {
    # Basic listening
    listen 80;                           # Port only
    listen 192.168.1.100:80;            # IP and port
    listen [::1]:80;                     # IPv6
    
    # SSL/TLS
    listen 443 ssl;                      # SSL on port 443
    listen 443 ssl http2;                # SSL with HTTP/2
    
    # Special options
    listen 80 default_server;            # Default server for this port
    listen 80 reuseport;                 # Enable SO_REUSEPORT
    listen 80 backlog=511;               # Set listen backlog
    listen 80 rcvbuf=8k sndbuf=8k;      # Set socket buffers
}
```

**Test Configuration:**
```bash
# Create test server block
sudo tee /etc/nginx/sites-available/example.com << 'EOF'
server {
    listen 80;
    server_name example.com www.example.com;
    
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Create document root and test page
sudo mkdir -p /var/www/example.com
sudo tee /var/www/example.com/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Example.com - Nginx Server Block Test</title>
</head>
<body>
    <h1>Welcome to example.com</h1>
    <p>This page is served by a custom server block.</p>
</body>
</html>
EOF

# Set permissions
sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R 755 /var/www/example.com

# Enable site
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

### Server Name Matching
```nginx
# Exact match
server_name example.com;

# Multiple exact matches
server_name example.com www.example.com;

# Wildcard matching
server_name *.example.com;          # Matches any.example.com
server_name example.*;              # Matches example.anything

# Regular expression matching
server_name ~^(?<subdomain>.+)\.example\.com$;

# Default server (catches all unmatched requests)
server_name _;
```

**Server Name Priority:**
1. Exact name match
2. Longest wildcard starting with `*`
3. Longest wildcard ending with `*`
4. First matching regular expression
5. Default server

### Multiple Server Blocks Example
```nginx
# Production site
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Staging site
server {
    listen 80;
    server_name staging.example.com;
    root /var/www/staging;
    
    # Basic authentication for staging
    auth_basic "Staging Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Development site
server {
    listen 8080;
    server_name dev.example.com localhost;
    root /var/www/dev;
    
    # Enable directory listing for development
    location / {
        autoindex on;
        try_files $uri $uri/ =404;
    }
}

# Default server (catch-all)
server {
    listen 80 default_server;
    server_name _;
    
    # Return 444 (close connection) for unknown hosts
    return 444;
}
```

---

## 📍 Location Directives

### Location Syntax
```nginx
location [modifier] pattern {
    # Location-specific directives
}
```

### Location Modifiers

#### Exact Match (=)
```nginx
# Matches exactly "/login"
location = /login {
    # Only matches http://example.com/login
    # Does NOT match http://example.com/login/
    proxy_pass http://auth-server;
}

# Matches exactly root "/"
location = / {
    # Only matches http://example.com/
    # Does NOT match http://example.com/anything
    return 301 /home;
}
```

#### Prefix Match (default)
```nginx
# Matches any URI starting with "/api/"
location /api/ {
    # Matches:
    # /api/users
    # /api/products/123
    # /api/orders/search
    proxy_pass http://api-backend;
}

# Matches any URI starting with "/static/"
location /static/ {
    # Matches:
    # /static/css/style.css
    # /static/js/app.js
    # /static/images/logo.png
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

#### Preferential Prefix Match (^~)
```nginx
# Stops searching after this match
location ^~ /images/ {
    # If this matches, nginx stops looking for regex matches
    root /var/www/static;
    expires 30d;
}

# Without ^~, this regex might override the above
location ~* \.(jpg|jpeg|png|gif)$ {
    expires 1y;
}
```

#### Case-Sensitive Regex (~)
```nginx
# Case-sensitive regular expression
location ~ \.(php|php5)$ {
    # Matches: .php, .php5
    # Does NOT match: .PHP, .Php
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    include fastcgi_params;
}

# Match specific file patterns
location ~ ^/admin/.*\.php$ {
    # Matches PHP files in /admin/ directory only
    # Requires authentication
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
}
```

#### Case-Insensitive Regex (~*)
```nginx
# Case-insensitive regular expression
location ~* \.(jpg|jpeg|png|gif|ico|svg)$ {
    # Matches: .jpg, .JPG, .Jpg, .png, .PNG, etc.
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}

# Match various document types
location ~* \.(pdf|doc|docx|xls|xlsx)$ {
    # Matches any case variation of document extensions
    add_header Content-Disposition "attachment";
}
```

### Location Priority Order
1. **Exact match (=)**: Highest priority
2. **Preferential prefix (^~)**: Stops regex matching
3. **Regular expressions (~, ~*)**: First match wins
4. **Prefix match**: Longest match wins

### Location Examples

#### Static File Serving
```nginx
server {
    listen 80;
    server_name static.example.com;
    root /var/www/static;
    
    # Exact match for root
    location = / {
        return 301 /index.html;
    }
    
    # CSS files with long cache
    location ~* \.css$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip_static on;
    }
    
    # JavaScript files with long cache
    location ~* \.js$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip_static on;
    }
    
    # Images with long cache
    location ~* \.(jpg|jpeg|png|gif|ico|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Fonts with long cache
    location ~* \.(woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
        access_log off;
    }
    
    # Default location
    location / {
        try_files $uri $uri/ =404;
    }
}
```

#### API Routing
```nginx
server {
    listen 80;
    server_name api.example.com;
    
    # API versioning
    location /v1/ {
        proxy_pass http://api-v1-backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /v2/ {
        proxy_pass http://api-v2-backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Authentication endpoint
    location = /auth {
        internal;
        proxy_pass http://auth-service;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URI $request_uri;
    }
    
    # Protected API endpoints
    location /protected/ {
        auth_request /auth;
        proxy_pass http://protected-backend/;
    }
    
    # Health check endpoint
    location = /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Rate-limited endpoints
    location /upload/ {
        limit_req zone=upload_zone burst=5 nodelay;
        client_max_body_size 100M;
        proxy_pass http://upload-backend/;
    }
}
```

---

## 🔄 Request Processing Flow

### try_files Directive
```nginx
# Basic try_files usage
location / {
    try_files $uri $uri/ =404;
}

# Explanation:
# 1. Try to serve $uri (exact file)
# 2. If not found, try $uri/ (as directory with index)
# 3. If not found, return 404
```

#### Advanced try_files Examples
```nginx
# Single Page Application (SPA)
location / {
    try_files $uri $uri/ /index.html;
    # Falls back to index.html for client-side routing
}

# PHP application with clean URLs
location / {
    try_files $uri $uri/ /index.php?$query_string;
    # Falls back to index.php with query parameters
}

# Static files with fallback to backend
location / {
    try_files $uri $uri/ @backend;
}

location @backend {
    proxy_pass http://app-server;
}

# Multiple fallbacks
location /assets/ {
    try_files $uri $uri/ @s3_fallback @cdn_fallback =404;
}

location @s3_fallback {
    proxy_pass https://mybucket.s3.amazonaws.com;
}

location @cdn_fallback {
    proxy_pass https://cdn.example.com;
}
```

### Named Locations
```nginx
# Named location for error handling
location / {
    try_files $uri $uri/ @fallback;
}

location @fallback {
    proxy_pass http://backend;
    proxy_set_header Host $host;
}

# Named location for maintenance mode
location / {
    try_files $uri $uri/ @maintenance;
}

location @maintenance {
    if (-f /var/www/maintenance.html) {
        return 503;
    }
    try_files $uri $uri/ =404;
}

error_page 503 @maintenance_page;

location @maintenance_page {
    root /var/www;
    try_files /maintenance.html =503;
}
```

---

## 📝 Common Configuration Patterns

### Basic Web Server
```nginx
server {
    listen 80;
    server_name mysite.com www.mysite.com;
    root /var/www/mysite;
    index index.html index.htm;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # Deny access to backup files
    location ~ ~$ {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /404.html {
        root /var/www/errors;
        internal;
    }
    
    location = /50x.html {
        root /var/www/errors;
        internal;
    }
}
```

### PHP Application Server
```nginx
server {
    listen 80;
    server_name phpapp.com;
    root /var/www/phpapp;
    index index.php index.html;
    
    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Deny access to PHP files in uploads directory
    location ~* /uploads/.*\.php$ {
        deny all;
    }
    
    # Static files
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Clean URLs for PHP framework
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Security
    location ~ /\.(ht|git|svn) {
        deny all;
    }
}
```

### Reverse Proxy Configuration
```nginx
upstream backend {
    server 127.0.0.1:3000;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
}

server {
    listen 80;
    server_name app.example.com;
    
    # Proxy to backend
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffering
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }
    
    # Static files served directly
    location /static/ {
        root /var/www/app;
        expires 1y;
        access_log off;
    }
    
    # WebSocket support
    location /ws/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

---

## 🧪 Configuration Testing

### Syntax Testing
```bash
# Test configuration syntax
sudo nginx -t
```

**Expected Output (Success):**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**Expected Output (Error):**
```
nginx: [emerg] unexpected "}" in /etc/nginx/sites-enabled/example.com:15
nginx: configuration file /etc/nginx/nginx.conf test failed
```

### Configuration Dump
```bash
# Show complete configuration
sudo nginx -T

# Show configuration with line numbers
sudo nginx -T | nl
```

### Reload vs Restart
```bash
# Reload configuration (graceful, no downtime)
sudo nginx -s reload
# or
sudo systemctl reload nginx

# Restart service (brief downtime)
sudo systemctl restart nginx
```

### Testing Specific Configurations
```bash
# Test with custom config file
sudo nginx -t -c /path/to/custom/nginx.conf

# Test specific server block
sudo nginx -t -g "daemon off;" -c /etc/nginx/sites-available/example.com
```

---

## 🔍 Debugging Configuration Issues

### Common Configuration Errors

#### Syntax Errors
```nginx
# WRONG: Missing semicolon
server {
    listen 80
    server_name example.com;
}

# CORRECT:
server {
    listen 80;
    server_name example.com;
}
```

#### Context Errors
```nginx
# WRONG: server directive in wrong context
http {
    listen 80;  # This should be inside server block
}

# CORRECT:
http {
    server {
        listen 80;
    }
}
```

#### File Path Errors
```bash
# Check if paths exist
ls -la /var/www/example.com/
ls -la /etc/nginx/sites-enabled/

# Check permissions
sudo -u www-data test -r /var/www/example.com/index.html
echo $?  # Should return 0 if readable
```

### Debugging Tools
```bash
# Check error logs
sudo tail -f /var/log/nginx/error.log

# Check access logs
sudo tail -f /var/log/nginx/access.log

# Test with curl
curl -v http://localhost/
curl -H "Host: example.com" http://localhost/

# Check listening ports
sudo netstat -tlnp | grep nginx
sudo ss -tlnp | grep nginx
```

---

## 🚀 Next Steps

You now have mastery of Nginx configuration fundamentals:

- ✅ **Configuration Syntax**: Contexts, directives, variables, and syntax rules
- ✅ **Server Blocks**: Virtual hosts, server names, and listening configuration
- ✅ **Location Directives**: All modifiers, priority, and matching patterns
- ✅ **Request Processing**: try_files, named locations, and processing flow
- ✅ **Common Patterns**: Web server, PHP, and reverse proxy configurations
- ✅ **Testing & Debugging**: Configuration validation and troubleshooting

**Ready for Part 3: Advanced Nginx Features** where you'll master proxy configuration, load balancing, SSL/TLS, and performance optimization!
