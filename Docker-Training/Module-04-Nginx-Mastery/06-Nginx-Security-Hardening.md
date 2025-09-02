# 🛡️ Nginx Security Hardening Complete Guide

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Virtual Hosts configuration completed  

Master comprehensive Nginx security hardening techniques for production environments, including access controls, security headers, and attack prevention.

## 🎯 Learning Objectives

- Implement comprehensive security headers and policies
- Configure access controls and IP restrictions
- Set up rate limiting and DDoS protection
- Secure Nginx configuration and file permissions
- Implement Web Application Firewall (WAF) rules

## 🔒 Basic Security Configuration

### Secure Nginx Installation
```bash
# Remove server tokens (hide Nginx version)
# In /etc/nginx/nginx.conf
http {
    server_tokens off;
    
    # Hide server header completely (requires custom build)
    more_clear_headers Server;
}

# Secure file permissions
sudo chown -R root:root /etc/nginx/
sudo chmod -R 644 /etc/nginx/
sudo chmod 755 /etc/nginx/
sudo chmod 600 /etc/nginx/ssl/private/*
sudo chmod 644 /etc/nginx/ssl/certs/*

# Secure log files
sudo chown -R www-data:adm /var/log/nginx/
sudo chmod -R 640 /var/log/nginx/
```

### Security Headers Configuration
```nginx
# /etc/nginx/snippets/security-headers.conf
# Comprehensive security headers

# HSTS (HTTP Strict Transport Security)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Prevent clickjacking
add_header X-Frame-Options "DENY" always;

# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# XSS Protection
add_header X-XSS-Protection "1; mode=block" always;

# Referrer Policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Content Security Policy
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; media-src 'self'; object-src 'none'; child-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';" always;

# Feature Policy / Permissions Policy
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), speaker=()" always;

# Remove potentially dangerous headers
more_clear_headers "X-Powered-By";
more_clear_headers "X-AspNet-Version";
more_clear_headers "Server";
```

### Secure Server Block Template
```nginx
server {
    listen 443 ssl http2;
    server_name secure.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/secure.example.com.crt;
    ssl_certificate_key /etc/ssl/private/secure.example.com.key;
    
    # Include security headers
    include snippets/security-headers.conf;
    
    # Security configurations
    client_max_body_size 10m;
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    
    # Disable unnecessary HTTP methods
    if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
        return 405;
    }
    
    # Block common attack patterns
    location ~* /(\.git|\.svn|\.env|\.htaccess|\.htpasswd|wp-config\.php|readme\.html) {
        deny all;
        return 404;
    }
    
    # Block suspicious user agents
    if ($http_user_agent ~* (nmap|nikto|wikto|sf|sqlmap|bsqlbf|w3af|acunetix|havij|appscan)) {
        return 403;
    }
    
    # Block suspicious requests
    if ($query_string ~* (\<|%3C).*script.*(\>|%3E)) {
        return 403;
    }
    
    if ($query_string ~* GLOBALS(=|\[|\%[0-9A-Z]{0,2})) {
        return 403;
    }
    
    if ($query_string ~* _REQUEST(=|\[|\%[0-9A-Z]{0,2})) {
        return 403;
    }
    
    root /var/www/secure.example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🚫 Access Control and IP Restrictions

### IP-Based Access Control
```nginx
# Geographic blocking (requires GeoIP module)
geoip_country /usr/share/GeoIP/GeoIP.dat;

map $geoip_country_code $allowed_country {
    default no;
    US yes;
    CA yes;
    GB yes;
    DE yes;
    FR yes;
}

server {
    listen 80;
    server_name restricted.example.com;
    
    # Block by country
    if ($allowed_country = no) {
        return 403 "Access denied from your country";
    }
    
    # IP whitelist for admin areas
    location /admin/ {
        allow 192.168.1.0/24;    # Internal network
        allow 10.0.0.0/8;        # VPN network
        allow 203.0.113.0/24;    # Office network
        deny all;
        
        try_files $uri $uri/ =404;
    }
    
    # IP blacklist for known attackers
    location / {
        deny 198.51.100.0/24;    # Known bad network
        deny 203.0.113.100;      # Specific bad IP
        allow all;
        
        try_files $uri $uri/ =404;
    }
}
```

### Dynamic IP Blocking
```nginx
# Rate limiting with IP blocking
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=global:10m rate=20r/s;

# Connection limiting
limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
limit_conn_zone $server_name zone=conn_limit_per_server:10m;

server {
    listen 80;
    server_name protected.example.com;
    
    # Global connection limits
    limit_conn conn_limit_per_ip 10;
    limit_conn conn_limit_per_server 1000;
    
    # Global rate limiting
    limit_req zone=global burst=50 nodelay;
    
    # Login protection
    location /login {
        limit_req zone=login burst=3 nodelay;
        
        # Additional security for login
        if ($request_method = POST) {
            access_log /var/log/nginx/login_attempts.log;
        }
        
        try_files $uri $uri/ =404;
    }
    
    # API protection
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        # Block requests with no User-Agent
        if ($http_user_agent = "") {
            return 403;
        }
        
        proxy_pass http://backend;
    }
}
```

## 🛡️ Web Application Firewall (WAF) Rules

### Basic WAF Implementation
```nginx
# WAF rules configuration
map $request_uri $is_suspicious_uri {
    default 0;
    "~*\.\./\.\." 1;                    # Directory traversal
    "~*\.(php|asp|jsp|cgi)$" 1;        # Script files
    "~*/proc/self/environ" 1;          # System file access
    "~*/etc/passwd" 1;                 # Password file access
    "~*union.*select" 1;               # SQL injection
    "~*concat.*\(" 1;                  # SQL injection
    "~*<script" 1;                     # XSS attempts
    "~*javascript:" 1;                 # XSS attempts
    "~*vbscript:" 1;                   # XSS attempts
}

map $args $is_suspicious_args {
    default 0;
    "~*\.\./\.\." 1;                   # Directory traversal in args
    "~*union.*select" 1;               # SQL injection in args
    "~*<script" 1;                     # XSS in args
    "~*base64_decode" 1;               # Code injection
    "~*eval\(" 1;                      # Code injection
}

map $http_user_agent $is_bot {
    default 0;
    "~*bot" 1;
    "~*crawler" 1;
    "~*spider" 1;
    "~*scraper" 1;
}

server {
    listen 80;
    server_name waf-protected.example.com;
    
    # Block suspicious requests
    if ($is_suspicious_uri = 1) {
        return 403 "Suspicious request blocked";
    }
    
    if ($is_suspicious_args = 1) {
        return 403 "Suspicious arguments blocked";
    }
    
    # Rate limit bots more aggressively
    if ($is_bot = 1) {
        limit_req zone=bot_limit burst=5 nodelay;
    }
    
    # Block empty user agents
    if ($http_user_agent = "") {
        return 403 "User agent required";
    }
    
    # Block requests with suspicious headers
    if ($http_x_forwarded_for ~* "(\<|\>|'|\"|;|\(|\)|&|\+)") {
        return 403 "Invalid X-Forwarded-For header";
    }
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Advanced WAF with ModSecurity
```nginx
# ModSecurity configuration (requires nginx-modsecurity module)
# /etc/nginx/modsec/main.conf

# Enable ModSecurity
SecRuleEngine On

# Request body handling
SecRequestBodyAccess On
SecRequestBodyLimit 13107200
SecRequestBodyNoFilesLimit 131072
SecRequestBodyInMemoryLimit 131072
SecRequestBodyLimitAction Reject

# Response body handling
SecResponseBodyAccess On
SecResponseBodyMimeType text/plain text/html text/xml
SecResponseBodyLimit 524288
SecResponseBodyLimitAction ProcessPartial

# Temporary directory
SecTmpDir /tmp/
SecDataDir /tmp/

# Debug log
SecDebugLog /var/log/nginx/modsec_debug.log
SecDebugLogLevel 0

# Audit log
SecAuditEngine RelevantOnly
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
SecAuditLogParts ABIJDEFHZ
SecAuditLogType Serial
SecAuditLog /var/log/nginx/modsec_audit.log

# Include OWASP Core Rule Set
Include /etc/nginx/modsec/crs-setup.conf
Include /etc/nginx/modsec/rules/*.conf

# Custom rules
SecRule ARGS "@detectSQLi" \
    "id:1001,\
    phase:2,\
    block,\
    msg:'SQL Injection Attack Detected',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'application-multi',\
    tag:'language-multi',\
    tag:'platform-multi',\
    tag:'attack-sqli'"

# Usage in server block
server {
    listen 80;
    server_name modsec.example.com;
    
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🎯 E-Commerce Security Configuration

### Complete E-Commerce Security Setup
```nginx
# Security zones and limits
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=payment:10m rate=2r/s;
limit_req_zone $binary_remote_addr zone=search:10m rate=5r/s;

# Bot detection
map $http_user_agent $limit_bots {
    default 0;
    "~*bot|crawler|spider|scraper" 1;
}

# Suspicious request detection
map $request_uri $is_attack {
    default 0;
    "~*\.\./\.\." 1;                   # Directory traversal
    "~*union.*select" 1;               # SQL injection
    "~*<script" 1;                     # XSS
    "~*/etc/passwd" 1;                 # System file access
    "~*wp-admin|wp-login" 1;           # WordPress attacks
}

server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # SSL configuration
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Enhanced security headers for e-commerce
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # E-commerce specific CSP
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://js.stripe.com https://checkout.stripe.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.stripe.com; frame-src https://js.stripe.com https://checkout.stripe.com; font-src 'self' data:;" always;
    
    # Block attack attempts
    if ($is_attack = 1) {
        return 403 "Security violation detected";
    }
    
    # Block bots from sensitive areas
    if ($limit_bots = 1) {
        set $block_bot 1;
    }
    
    if ($uri ~* "/(checkout|payment|admin)") {
        set $block_bot "${block_bot}1";
    }
    
    if ($block_bot = "11") {
        return 403 "Bot access denied";
    }
    
    # Frontend (React app)
    root /var/www/ecommerce/build;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
        
        # Security for static files
        location ~* \.(js|css)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            
            # Prevent hotlinking
            valid_referers none blocked server_names *.example.com;
            if ($invalid_referer) {
                return 403;
            }
        }
    }
    
    # Authentication endpoints
    location /api/auth/ {
        limit_req zone=login burst=3 nodelay;
        
        # Additional auth security
        if ($request_method = POST) {
            access_log /var/log/nginx/auth_attempts.log;
        }
        
        # Block common attack patterns
        if ($args ~* "(union|select|insert|delete|update|drop|create|alter)" ) {
            return 403;
        }
        
        proxy_pass http://ecommerce_backend/auth/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Payment endpoints (maximum security)
    location /api/payments/ {
        limit_req zone=payment burst=2 nodelay;
        
        # Only allow POST for payments
        if ($request_method != POST) {
            return 405;
        }
        
        # Additional payment security
        if ($http_content_type !~ "application/json") {
            return 400;
        }
        
        # Log all payment attempts
        access_log /var/log/nginx/payment_access.log;
        
        proxy_pass http://ecommerce_backend/payments/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Payment-Request "true";
        
        # Strict timeouts for payments
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
    
    # Admin panel (restricted access)
    location /admin/ {
        # IP restrictions
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        # Additional admin security
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        # Rate limiting for admin
        limit_req zone=api burst=10 nodelay;
        
        proxy_pass http://ecommerce_backend/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Admin-Access "true";
    }
    
    # API endpoints
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        # Block suspicious requests
        if ($args ~* "(\<|\>|'|\"|;|\(|\)|&|\+|union|select|insert|delete|update|drop)") {
            return 403;
        }
        
        proxy_pass http://ecommerce_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Search endpoint (rate limited)
    location /api/search/ {
        limit_req zone=search burst=10 nodelay;
        
        proxy_pass http://ecommerce_backend/search/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Block access to sensitive files
    location ~* /\.(git|svn|env|htaccess|htpasswd) {
        deny all;
        return 404;
    }
    
    # Block PHP execution (if not needed)
    location ~* \.php$ {
        deny all;
        return 404;
    }
}
```

## 🔍 Security Monitoring and Logging

### Security Event Logging
```nginx
# Custom log formats for security monitoring
log_format security '$remote_addr - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent" '
                   '$request_time $upstream_response_time '
                   '$geoip_country_code';

log_format attacks '$remote_addr - [$time_local] '
                  '"$request" $status '
                  '"$http_user_agent" "$args"';

server {
    listen 80;
    server_name monitored.example.com;
    
    # Security logging
    access_log /var/log/nginx/security.log security;
    
    # Log blocked requests
    location / {
        if ($is_attack = 1) {
            access_log /var/log/nginx/attacks.log attacks;
            return 403;
        }
        
        try_files $uri $uri/ =404;
    }
}
```

### Security Monitoring Script
```bash
#!/bin/bash
# security-monitor.sh - Security monitoring and alerting

LOG_FILE="/var/log/nginx/attacks.log"
ALERT_EMAIL="admin@example.com"
THRESHOLD=10

echo "=== Nginx Security Monitor ==="
echo "Timestamp: $(date)"

# Check for attack patterns in last hour
ATTACKS=$(grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $LOG_FILE 2>/dev/null | wc -l)

if [ $ATTACKS -gt $THRESHOLD ]; then
    echo "⚠️  High attack volume detected: $ATTACKS attacks in last hour"
    
    # Send alert email
    echo "High attack volume detected on $(hostname): $ATTACKS attacks in last hour" | \
    mail -s "Security Alert: High Attack Volume" $ALERT_EMAIL
    
    # Block top attacking IPs
    grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $LOG_FILE | \
    awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
    while read count ip; do
        if [ $count -gt 5 ]; then
            echo "Blocking IP $ip (attack count: $count)"
            iptables -A INPUT -s $ip -j DROP
        fi
    done
else
    echo "✅ Attack volume normal: $ATTACKS attacks in last hour"
fi

# Check for failed login attempts
FAILED_LOGINS=$(grep "POST /login" /var/log/nginx/auth_attempts.log 2>/dev/null | \
                grep "$(date '+%d/%b/%Y')" | wc -l)

echo "🔐 Failed login attempts today: $FAILED_LOGINS"

# Check SSL certificate expiry
CERT_FILE="/etc/ssl/certs/example.com.crt"
if [ -f "$CERT_FILE" ]; then
    EXPIRY=$(openssl x509 -enddate -noout -in $CERT_FILE | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
    
    if [ $DAYS_LEFT -lt 30 ]; then
        echo "⚠️  SSL certificate expires in $DAYS_LEFT days"
    else
        echo "✅ SSL certificate valid for $DAYS_LEFT days"
    fi
fi
```

## 🎯 Practical Exercises

### Exercise 1: Security Headers Implementation
Configure comprehensive security headers:
- HSTS with preload
- CSP for e-commerce site
- All security headers
- Test with security scanners

### Exercise 2: WAF Rules Setup
Implement Web Application Firewall:
- Block common attack patterns
- Rate limiting configuration
- IP-based restrictions
- Attack logging and monitoring

### Exercise 3: Security Monitoring
Set up security monitoring:
- Attack detection and logging
- Automated IP blocking
- Security alerting system
- Regular security audits

---

**🎯 Next**: Rate limiting and DDoS protection  
**📚 Resources**: [OWASP Nginx Security](https://cheatsheetseries.owasp.org/cheatsheets/Nginx_Hardening_Cheat_Sheet.html)  
**🔧 Tools**: Use security scanners like `nmap`, `nikto`, or online tools to test configurations
