# 🌐 Nginx Virtual Hosts & Server Blocks Mastery

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Intermediate  
**Prerequisites**: Nginx Configuration Syntax completed  

Master virtual host configuration and server block management for hosting multiple websites and applications on a single Nginx server.

## 🎯 Learning Objectives

- Configure multiple virtual hosts on single Nginx server
- Implement domain-based and IP-based virtual hosting
- Master server block inheritance and optimization
- Configure SSL/TLS for multiple domains
- Implement advanced routing and redirection patterns

## 📚 Virtual Host Fundamentals

### What are Virtual Hosts?

Virtual hosts allow one Nginx server to serve multiple websites or applications, each with different domain names, configurations, or content.

#### Types of Virtual Hosting
1. **Name-based**: Multiple domains on same IP (most common)
2. **IP-based**: Different IPs for different domains
3. **Port-based**: Different ports for different services

### Basic Server Block Structure
```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🔧 Name-Based Virtual Hosts

### Single Domain Configuration
```nginx
# /etc/nginx/sites-available/example.com
server {
    listen 80;
    listen [::]:80;
    
    server_name example.com www.example.com;
    root /var/www/example.com/html;
    index index.html index.htm index.php;
    
    # Logging
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # PHP processing (if needed)
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    
    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }
}
```

### Multiple Domain Configuration
```nginx
# E-commerce main site
server {
    listen 80;
    server_name ecommerce.example.com;
    root /var/www/ecommerce/frontend/build;
    index index.html;
    
    # Frontend (React app)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# Admin panel
server {
    listen 80;
    server_name admin.example.com;
    root /var/www/admin/build;
    index index.html;
    
    # Restrict access
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}

# API documentation
server {
    listen 80;
    server_name docs.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000/docs;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Wildcard and Regex Server Names
```nginx
# Wildcard subdomain
server {
    listen 80;
    server_name *.example.com;
    root /var/www/subdomains;
    
    # Use subdomain in path
    location / {
        root /var/www/subdomains/$host;
        try_files $uri $uri/ =404;
    }
}

# Regex server names with capture groups
server {
    listen 80;
    server_name ~^(?<user>.+)\.users\.example\.com$;
    root /var/www/users/$user;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Multi-tenant application
server {
    listen 80;
    server_name ~^(?<tenant>[^.]+)\.app\.example\.com$;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Tenant $tenant;
    }
}
```

## 🔒 HTTPS Virtual Hosts

### SSL Configuration for Multiple Domains
```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name example.com www.example.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server block
server {
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
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    root /var/www/example.com/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Let's Encrypt with Multiple Domains
```nginx
# Certbot challenge location (shared across all domains)
server {
    listen 80;
    server_name example.com www.example.com api.example.com admin.example.com;
    
    # Let's Encrypt challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# Main domain HTTPS
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# API subdomain HTTPS
server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🌍 IP-Based Virtual Hosts

### Multiple IP Configuration
```nginx
# Primary IP - main website
server {
    listen 192.168.1.100:80;
    server_name example.com;
    root /var/www/main;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Secondary IP - staging environment
server {
    listen 192.168.1.101:80;
    server_name staging.example.com;
    root /var/www/staging;
    
    # Basic auth for staging
    auth_basic "Staging Environment";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Internal IP - admin interface
server {
    listen 10.0.0.100:80;
    server_name admin.internal;
    root /var/www/admin;
    
    # Restrict to internal network only
    allow 10.0.0.0/8;
    deny all;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🔀 Port-Based Virtual Hosts

### Different Services on Different Ports
```nginx
# Main website on port 80
server {
    listen 80;
    server_name example.com;
    root /var/www/main;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Admin panel on port 8080
server {
    listen 8080;
    server_name example.com;
    root /var/www/admin;
    
    # Admin authentication
    auth_basic "Admin Panel";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# API on port 8000
server {
    listen 8000;
    server_name example.com;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Monitoring on port 9090
server {
    listen 9090;
    server_name example.com;
    
    # Restrict access
    allow 192.168.1.0/24;
    deny all;
    
    location / {
        proxy_pass http://127.0.0.1:9090;
        proxy_set_header Host $host;
    }
}
```

## 🎯 E-Commerce Virtual Host Configuration

### Complete E-Commerce Setup
```nginx
# Main e-commerce site
server {
    listen 80;
    server_name shop.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Frontend (React)
    root /var/www/ecommerce/frontend/build;
    index index.html;
    
    # Main application
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # API rate limiting
        limit_req zone=api burst=20 nodelay;
    }
    
    # File uploads
    location /uploads/ {
        root /var/www/ecommerce;
        expires 30d;
    }
}

# Admin panel
server {
    listen 443 ssl http2;
    server_name admin.shop.example.com;
    
    ssl_certificate /etc/ssl/certs/admin.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/admin.shop.example.com.key;
    
    # Restrict access to admin IPs
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    location / {
        proxy_pass http://127.0.0.1:8000/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# API documentation
server {
    listen 443 ssl http2;
    server_name docs.shop.example.com;
    
    ssl_certificate /etc/ssl/certs/docs.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/docs.shop.example.com.key;
    
    location / {
        proxy_pass http://127.0.0.1:8000/docs;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔧 Advanced Virtual Host Patterns

### Environment-Based Configuration
```nginx
# Development environment
server {
    listen 80;
    server_name dev.example.com;
    root /var/www/dev;
    
    # Enable detailed error reporting
    error_log /var/log/nginx/dev.error.log debug;
    
    # Disable caching for development
    location / {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
        try_files $uri $uri/ =404;
    }
}

# Staging environment
server {
    listen 80;
    server_name staging.example.com;
    root /var/www/staging;
    
    # Basic authentication
    auth_basic "Staging Environment";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    location / {
        try_files $uri $uri/ =404;
    }
}

# Production environment
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Production SSL and security configuration
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # Strict security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header Content-Security-Policy "default-src 'self'" always;
    
    root /var/www/production;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Load Balancing with Virtual Hosts
```nginx
upstream backend_pool {
    server 127.0.0.1:8001 weight=3;
    server 127.0.0.1:8002 weight=2;
    server 127.0.0.1:8003 backup;
}

server {
    listen 443 ssl http2;
    server_name app.example.com;
    
    ssl_certificate /etc/ssl/certs/app.example.com.crt;
    ssl_certificate_key /etc/ssl/private/app.example.com.key;
    
    location / {
        proxy_pass http://backend_pool;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Health checks
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
    }
}
```

## 📋 Site Management Commands

### Enable/Disable Sites
```bash
# Create symbolic link to enable site
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# Remove symbolic link to disable site
sudo rm /etc/nginx/sites-enabled/example.com

# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Check enabled sites
ls -la /etc/nginx/sites-enabled/
```

### Site Management Script
```bash
#!/bin/bash
# nginx-site-manager.sh

case "$1" in
    enable)
        if [ -f "/etc/nginx/sites-available/$2" ]; then
            sudo ln -s "/etc/nginx/sites-available/$2" "/etc/nginx/sites-enabled/"
            echo "Site $2 enabled"
            sudo nginx -t && sudo systemctl reload nginx
        else
            echo "Site $2 not found in sites-available"
        fi
        ;;
    disable)
        if [ -L "/etc/nginx/sites-enabled/$2" ]; then
            sudo rm "/etc/nginx/sites-enabled/$2"
            echo "Site $2 disabled"
            sudo nginx -t && sudo systemctl reload nginx
        else
            echo "Site $2 not enabled"
        fi
        ;;
    list)
        echo "Available sites:"
        ls /etc/nginx/sites-available/
        echo "Enabled sites:"
        ls /etc/nginx/sites-enabled/
        ;;
    *)
        echo "Usage: $0 {enable|disable|list} [site-name]"
        ;;
esac
```

## 🎯 Practical Exercises

### Exercise 1: Multi-Domain Setup
Create virtual hosts for:
- main.example.com (static website)
- api.example.com (reverse proxy to :8000)
- admin.example.com (restricted access)

### Exercise 2: SSL Configuration
Configure SSL certificates for all domains with automatic HTTP to HTTPS redirection.

### Exercise 3: E-Commerce Implementation
Set up complete e-commerce virtual host configuration with frontend, API, and admin panel.

---

**🎯 Next**: Static content optimization and caching strategies  
**📚 Resources**: [Nginx Virtual Host Documentation](https://nginx.org/en/docs/http/request_processing.html)  
**🔧 Tools**: Use `nginx -T` to test and display complete configuration
