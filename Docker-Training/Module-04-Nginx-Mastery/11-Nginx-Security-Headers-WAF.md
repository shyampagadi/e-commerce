# 🛡️ Nginx Security Headers & Web Application Firewall

## 📋 Overview

**Duration**: 4-5 Hours  
**Skill Level**: Advanced  
**Prerequisites**: SSL/TLS Configuration completed  

Master comprehensive security headers implementation and Web Application Firewall (WAF) configuration for maximum protection against web attacks.

## 🎯 Learning Objectives

- Implement comprehensive security headers
- Configure Web Application Firewall rules
- Set up Content Security Policy (CSP)
- Implement attack detection and prevention
- Configure security monitoring and alerting

## 📚 Security Headers Fundamentals

### Complete Security Headers Configuration
```nginx
# Comprehensive security headers snippet
# /etc/nginx/snippets/security-headers-complete.conf

# HTTP Strict Transport Security (HSTS)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Prevent clickjacking attacks
add_header X-Frame-Options "DENY" always;

# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# XSS Protection
add_header X-XSS-Protection "1; mode=block" always;

# Referrer Policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Content Security Policy (basic)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; media-src 'self'; object-src 'none'; child-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';" always;

# Permissions Policy (Feature Policy)
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), speaker=(), fullscreen=(self), sync-xhr=()" always;

# Cross-Origin Embedder Policy
add_header Cross-Origin-Embedder-Policy "require-corp" always;

# Cross-Origin Opener Policy
add_header Cross-Origin-Opener-Policy "same-origin" always;

# Cross-Origin Resource Policy
add_header Cross-Origin-Resource-Policy "same-origin" always;

# Remove server information
more_clear_headers "Server";
more_clear_headers "X-Powered-By";
more_clear_headers "X-AspNet-Version";
more_clear_headers "X-AspNetMvc-Version";
```

### Advanced Content Security Policy
```nginx
# CSP for different application types
map $uri $csp_policy {
    default "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; font-src 'self'; connect-src 'self'; media-src 'self'; object-src 'none'; child-src 'none'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';";
    
    # E-commerce with payment integration
    ~^/checkout "default-src 'self'; script-src 'self' 'unsafe-inline' https://js.stripe.com https://checkout.stripe.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.stripe.com; frame-src https://js.stripe.com https://checkout.stripe.com; object-src 'none'; base-uri 'self';";
    
    # Admin panel (strict)
    ~^/admin "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self'; font-src 'self'; connect-src 'self'; object-src 'none'; child-src 'none'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';";
    
    # API endpoints (minimal)
    ~^/api "default-src 'none'; connect-src 'self';";
}

server {
    listen 443 ssl http2;
    server_name secure.example.com;
    
    # Apply dynamic CSP
    add_header Content-Security-Policy $csp_policy always;
    
    # CSP reporting
    add_header Content-Security-Policy-Report-Only "default-src 'self'; report-uri /csp-report;" always;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # CSP violation reporting
    location /csp-report {
        access_log /var/log/nginx/csp_violations.log;
        return 204;
    }
}
```

## 🔥 Web Application Firewall Implementation

### Basic WAF Rules
```nginx
# WAF rule definitions
map $request_uri $is_malicious_uri {
    default 0;
    "~*\.\./\.\." 1;                    # Directory traversal
    "~*\.(php|asp|jsp|cgi)$" 1;        # Script execution attempts
    "~*/proc/self/environ" 1;          # System file access
    "~*/etc/passwd" 1;                 # Password file access
    "~*union.*select" 1;               # SQL injection
    "~*concat.*\(" 1;                  # SQL injection
    "~*<script" 1;                     # XSS attempts
    "~*javascript:" 1;                 # XSS attempts
    "~*vbscript:" 1;                   # XSS attempts
    "~*onload=" 1;                     # XSS attempts
    "~*onerror=" 1;                    # XSS attempts
}

map $args $is_malicious_args {
    default 0;
    "~*\.\./\.\." 1;                   # Directory traversal in args
    "~*union.*select" 1;               # SQL injection in args
    "~*<script" 1;                     # XSS in args
    "~*base64_decode" 1;               # Code injection
    "~*eval\(" 1;                      # Code injection
    "~*exec\(" 1;                      # Code injection
    "~*system\(" 1;                    # System command injection
    "~*passthru\(" 1;                  # Command injection
    "~*shell_exec\(" 1;                # Command injection
}

map $http_user_agent $is_malicious_ua {
    default 0;
    "~*sqlmap" 1;                      # SQL injection tool
    "~*nikto" 1;                       # Vulnerability scanner
    "~*nmap" 1;                        # Network scanner
    "~*masscan" 1;                     # Port scanner
    "~*zmap" 1;                        # Network scanner
    "~*w3af" 1;                        # Web application scanner
    "~*acunetix" 1;                    # Vulnerability scanner
    "~*havij" 1;                       # SQL injection tool
    "~*bsqlbf" 1;                      # SQL injection tool
}

server {
    listen 443 ssl http2;
    server_name waf-protected.example.com;
    
    # Block malicious requests
    if ($is_malicious_uri = 1) {
        access_log /var/log/nginx/waf_blocked.log;
        return 403 '{"error":"Request blocked by WAF","code":"URI_VIOLATION"}';
    }
    
    if ($is_malicious_args = 1) {
        access_log /var/log/nginx/waf_blocked.log;
        return 403 '{"error":"Request blocked by WAF","code":"ARGS_VIOLATION"}';
    }
    
    if ($is_malicious_ua = 1) {
        access_log /var/log/nginx/waf_blocked.log;
        return 403 '{"error":"Request blocked by WAF","code":"UA_VIOLATION"}';
    }
    
    # Block empty user agents
    if ($http_user_agent = "") {
        return 403 '{"error":"User agent required","code":"NO_UA"}';
    }
    
    # Block requests with suspicious headers
    if ($http_x_forwarded_for ~* "(\<|\>|'|\"|;|\(|\)|&|\+)") {
        return 403 '{"error":"Invalid header","code":"HEADER_VIOLATION"}';
    }
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Advanced WAF with ModSecurity
```nginx
# ModSecurity configuration
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
SecResponseBodyMimeType text/plain text/html text/xml application/json
SecResponseBodyLimit 524288
SecResponseBodyLimitAction ProcessPartial

# File handling
SecTmpDir /tmp/
SecDataDir /tmp/

# Logging
SecDebugLog /var/log/nginx/modsec_debug.log
SecDebugLogLevel 0
SecAuditEngine RelevantOnly
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
SecAuditLogParts ABIJDEFHZ
SecAuditLogType Serial
SecAuditLog /var/log/nginx/modsec_audit.log

# Include OWASP Core Rule Set
Include /etc/nginx/modsec/crs-setup.conf
Include /etc/nginx/modsec/rules/*.conf

# Custom rules for e-commerce
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

SecRule ARGS "@detectXSS" \
    "id:1002,\
    phase:2,\
    block,\
    msg:'XSS Attack Detected',\
    logdata:'Matched Data: %{MATCHED_VAR} found within %{MATCHED_VAR_NAME}',\
    tag:'application-multi',\
    tag:'language-multi',\
    tag:'platform-multi',\
    tag:'attack-xss'"

# E-commerce specific rules
SecRule REQUEST_URI "@beginsWith /api/payments/" \
    "id:2001,\
    phase:1,\
    pass,\
    setvar:'tx.payment_endpoint=1',\
    msg:'Payment endpoint accessed'"

SecRule TX:PAYMENT_ENDPOINT "@eq 1" \
    "id:2002,\
    phase:2,\
    chain,\
    block,\
    msg:'Suspicious payment request'"
    SecRule ARGS "@rx (?i)(union|select|insert|delete|update|drop|create|alter)"

# Rate limiting rules
SecAction \
    "id:3001,\
    phase:1,\
    nolog,\
    pass,\
    initcol:ip=%{REMOTE_ADDR},\
    setvar:ip.requests_per_minute=+1,\
    expirevar:ip.requests_per_minute=60"

SecRule IP:REQUESTS_PER_MINUTE "@gt 60" \
    "id:3002,\
    phase:1,\
    block,\
    msg:'Rate limit exceeded',\
    logdata:'Requests per minute: %{ip.requests_per_minute}'"
```

## 🎯 E-Commerce Security Implementation

### Complete E-Commerce Security Setup
```nginx
# E-commerce security configuration
server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Enable ModSecurity
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    
    # E-commerce specific security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # E-commerce CSP with payment providers
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://js.stripe.com https://checkout.stripe.com https://www.paypal.com; style-src 'self' 'unsafe-inline' https://checkout.stripe.com; img-src 'self' data: https: *.stripe.com *.paypal.com; font-src 'self' data: https://checkout.stripe.com; connect-src 'self' https://api.stripe.com https://checkout.stripe.com wss://checkout.stripe.com; frame-src https://js.stripe.com https://checkout.stripe.com https://www.paypal.com; object-src 'none'; base-uri 'self'; form-action 'self' https://checkout.stripe.com;" always;
    
    # Remove server information
    more_clear_headers "Server";
    more_clear_headers "X-Powered-By";
    
    # Frontend application
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
    
    # API endpoints with enhanced security
    location /api/ {
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
        
        # Block common attack patterns
        if ($args ~* "(union|select|insert|delete|update|drop|create|alter|script|alert|prompt|confirm|eval|expression)" ) {
            access_log /var/log/nginx/api_attacks.log;
            return 403 '{"error":"Malicious request detected"}';
        }
        
        # Block suspicious user agents
        if ($http_user_agent ~* "(sqlmap|nikto|nmap|masscan|w3af|acunetix|havij|bsqlbf)") {
            access_log /var/log/nginx/scanner_attempts.log;
            return 403 '{"error":"Scanner detected"}';
        }
        
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Authentication endpoints (extra protection)
    location /api/auth/ {
        # Strict rate limiting
        limit_req zone=auth burst=3 nodelay;
        
        # Enhanced logging
        access_log /var/log/nginx/auth_attempts.log;
        
        # Block brute force patterns
        if ($request_method = POST) {
            set $auth_attempt 1;
        }
        
        proxy_pass http://backend/auth/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Auth-Attempt $auth_attempt;
    }
    
    # Payment endpoints (maximum security)
    location /api/payments/ {
        # Very strict rate limiting
        limit_req zone=payment burst=2 nodelay;
        
        # Only allow POST requests
        if ($request_method != POST) {
            return 405;
        }
        
        # Require specific content type
        if ($http_content_type !~ "application/json") {
            return 400 '{"error":"Invalid content type"}';
        }
        
        # Enhanced security logging
        access_log /var/log/nginx/payment_requests.log;
        
        # Additional security headers
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        
        proxy_pass http://backend/payments/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Payment-Request "true";
        
        # Strict timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
    
    # Admin panel (IP restricted + additional security)
    location /admin/ {
        # IP whitelist
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        # Basic authentication
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        # Enhanced CSP for admin
        add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self'; font-src 'self'; connect-src 'self'; object-src 'none'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';" always;
        
        proxy_pass http://backend/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Admin-Access "true";
    }
    
    # Block access to sensitive files
    location ~* /\.(git|svn|env|htaccess|htpasswd|ini|log|sh|sql|conf)$ {
        deny all;
        return 404;
    }
    
    # Block PHP execution (if not needed)
    location ~* \.php$ {
        deny all;
        return 404;
    }
    
    # Security headers for error pages
    error_page 403 /403.html;
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    
    location = /403.html {
        root /var/www/error-pages;
        add_header X-Frame-Options DENY always;
        add_header X-Content-Type-Options nosniff always;
    }
}
```

## 🚨 Security Monitoring & Alerting

### Security Event Monitoring
```bash
#!/bin/bash
# security-monitor.sh - Real-time security monitoring

WAF_LOG="/var/log/nginx/waf_blocked.log"
AUTH_LOG="/var/log/nginx/auth_attempts.log"
PAYMENT_LOG="/var/log/nginx/payment_requests.log"
ALERT_EMAIL="security@example.com"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"

echo "=== Security Monitoring Report ==="
echo "Timestamp: $(date)"

# Check WAF blocks in last hour
WAF_BLOCKS=$(grep "$(date -d '1 hour ago' '+%d/%b/%Y:%H')" $WAF_LOG 2>/dev/null | wc -l)
echo "WAF blocks (last hour): $WAF_BLOCKS"

if [ $WAF_BLOCKS -gt 10 ]; then
    MESSAGE="High WAF activity: $WAF_BLOCKS blocks in last hour"
    echo "⚠️  $MESSAGE"
    
    # Send alert
    echo "$MESSAGE" | mail -s "Security Alert: High WAF Activity" $ALERT_EMAIL
    
    # Slack notification
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"🚨 $MESSAGE\"}" \
    $SLACK_WEBHOOK
fi

# Check failed authentication attempts
FAILED_AUTH=$(grep "$(date '+%d/%b/%Y:%H')" $AUTH_LOG 2>/dev/null | grep "401\|403" | wc -l)
echo "Failed auth attempts (current hour): $FAILED_AUTH"

if [ $FAILED_AUTH -gt 20 ]; then
    MESSAGE="High failed authentication rate: $FAILED_AUTH attempts"
    echo "⚠️  $MESSAGE"
    
    # Block top attacking IPs
    grep "$(date '+%d/%b/%Y:%H')" $AUTH_LOG | grep "401\|403" | \
    awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
    while read count ip; do
        if [ $count -gt 5 ]; then
            echo "Blocking IP $ip (failed attempts: $count)"
            iptables -A INPUT -s $ip -j DROP
        fi
    done
fi

# Check payment security
PAYMENT_ATTEMPTS=$(grep "$(date '+%d/%b/%Y:%H')" $PAYMENT_LOG 2>/dev/null | wc -l)
PAYMENT_ERRORS=$(grep "$(date '+%d/%b/%Y:%H')" $PAYMENT_LOG 2>/dev/null | grep "40[0-9]\|50[0-9]" | wc -l)

echo "Payment requests (current hour): $PAYMENT_ATTEMPTS"
echo "Payment errors (current hour): $PAYMENT_ERRORS"

if [ $PAYMENT_ATTEMPTS -gt 0 ] && [ $PAYMENT_ERRORS -gt 0 ]; then
    ERROR_RATE=$(echo "scale=2; $PAYMENT_ERRORS * 100 / $PAYMENT_ATTEMPTS" | bc)
    if (( $(echo "$ERROR_RATE > 10" | bc -l) )); then
        MESSAGE="High payment error rate: ${ERROR_RATE}%"
        echo "⚠️  $MESSAGE"
    fi
fi

# Check for security scanner activity
SCANNER_ACTIVITY=$(grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/scanner_attempts.log 2>/dev/null | wc -l)
echo "Scanner attempts (current hour): $SCANNER_ACTIVITY"

if [ $SCANNER_ACTIVITY -gt 0 ]; then
    echo "⚠️  Security scanners detected: $SCANNER_ACTIVITY attempts"
    
    # Extract and block scanner IPs
    grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/scanner_attempts.log | \
    awk '{print $1}' | sort -u | \
    while read ip; do
        echo "Blocking scanner IP: $ip"
        iptables -A INPUT -s $ip -j DROP
    done
fi
```

## 🎯 Practical Exercises

### Exercise 1: Security Headers Implementation
Configure comprehensive security headers:
- HSTS with preload
- CSP for e-commerce application
- All modern security headers
- Test with security scanners

### Exercise 2: WAF Configuration
Implement Web Application Firewall:
- ModSecurity with OWASP rules
- Custom e-commerce rules
- Attack detection and blocking
- Security event logging

### Exercise 3: Security Monitoring
Set up security monitoring:
- Real-time attack detection
- Automated IP blocking
- Security alerting system
- Compliance reporting

---

**🎯 Next**: Rate limiting and DDoS protection  
**📚 Resources**: [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)  
**🔧 Tools**: Use security scanners like OWASP ZAP, Nessus, or online tools to test configurations
