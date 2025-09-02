# 🛡️ Nginx Rate Limiting & DDoS Protection

## 📋 Overview

**Duration**: 4-5 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Security Headers & WAF completed  

Master comprehensive rate limiting and DDoS protection strategies using Nginx for high-availability production environments.

## 🎯 Learning Objectives

- Implement advanced rate limiting strategies
- Configure DDoS protection and mitigation
- Set up connection limiting and bandwidth control
- Implement geographic and behavioral blocking
- Create automated threat response systems

## 📚 Rate Limiting Fundamentals

### Basic Rate Limiting Configuration
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=global:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=search:10m rate=5r/s;

# Connection limiting zones
limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
limit_conn_zone $server_name zone=conn_limit_per_server:10m;

server {
    listen 80;
    server_name protected.example.com;
    
    # Global connection limits
    limit_conn conn_limit_per_ip 10;
    limit_conn conn_limit_per_server 1000;
    
    # Global rate limiting
    limit_req zone=global burst=20 nodelay;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # API endpoints
    location /api/ {
        limit_req zone=api burst=40 nodelay;
        proxy_pass http://backend;
    }
    
    # Login endpoint (strict)
    location /login {
        limit_req zone=login burst=3 nodelay;
        try_files $uri $uri/ =404;
    }
    
    # Search endpoint
    location /search {
        limit_req zone=search burst=10 nodelay;
        try_files $uri $uri/ =404;
    }
}
```

### Advanced Rate Limiting Patterns
```nginx
# Multi-tier rate limiting
limit_req_zone $binary_remote_addr zone=tier1:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=tier2:10m rate=15r/s;
limit_req_zone $binary_remote_addr zone=tier3:10m rate=50r/s;

# Rate limiting by user agent
map $http_user_agent $rate_limit_zone {
    ~*bot tier1;
    ~*crawler tier1;
    ~*mobile tier2;
    default tier3;
}

# Rate limiting by geographic location
geoip_country /usr/share/GeoIP/GeoIP.dat;
map $geoip_country_code $country_rate_limit {
    default 10r/s;
    US 20r/s;
    CA 20r/s;
    GB 15r/s;
    CN 5r/s;
    RU 5r/s;
}

server {
    listen 80;
    server_name smart-limits.example.com;
    
    # Apply rate limiting based on user agent
    location /api/ {
        if ($rate_limit_zone = "tier1") {
            limit_req zone=tier1 burst=10 nodelay;
        }
        if ($rate_limit_zone = "tier2") {
            limit_req zone=tier2 burst=30 nodelay;
        }
        if ($rate_limit_zone = "tier3") {
            limit_req zone=tier3 burst=100 nodelay;
        }
        
        proxy_pass http://backend;
        add_header X-Rate-Limit-Tier $rate_limit_zone always;
    }
}
```

## 🚫 DDoS Protection Strategies

### Layer 7 DDoS Protection
```nginx
# DDoS protection zones
limit_req_zone $binary_remote_addr zone=ddos_protection:10m rate=2r/s;
limit_conn_zone $binary_remote_addr zone=ddos_conn:10m;

# Suspicious request detection
map $request_uri $is_ddos_pattern {
    default 0;
    "~*\.(php|asp|jsp|cgi)$" 1;       # Script execution attempts
    "~*/wp-admin" 1;                   # WordPress attacks
    "~*/xmlrpc\.php" 1;                # WordPress XML-RPC attacks
    "~*\.env" 1;                       # Environment file access
    "~*/\.git/" 1;                     # Git directory access
}

# Bot detection for DDoS
map $http_user_agent $is_ddos_bot {
    default 0;
    "" 1;                              # Empty user agent
    "~*curl" 1;                        # Command line tools
    "~*wget" 1;                        # Command line tools
    "~*python" 1;                      # Python scripts
    "~*bot.*bot" 1;                    # Suspicious bot patterns
}

server {
    listen 80;
    server_name ddos-protected.example.com;
    
    # Connection limits for DDoS protection
    limit_conn ddos_conn 5;
    
    # Rate limiting for DDoS protection
    limit_req zone=ddos_protection burst=10 nodelay;
    
    # Block DDoS patterns
    if ($is_ddos_pattern = 1) {
        access_log /var/log/nginx/ddos_attempts.log;
        return 444;  # Close connection without response
    }
    
    # Block suspicious bots
    if ($is_ddos_bot = 1) {
        access_log /var/log/nginx/bot_blocks.log;
        return 429 "Too Many Requests";
    }
    
    # Block requests without proper headers
    if ($http_accept = "") {
        return 444;
    }
    
    # Block requests with suspicious headers
    if ($http_x_forwarded_for ~* "(\<|\>|'|\"|;|\(|\)|&|\+)") {
        return 444;
    }
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Bandwidth Limiting
```nginx
# Bandwidth limiting zones
limit_rate_zone $binary_remote_addr zone=download_limit:10m;

server {
    listen 80;
    server_name downloads.example.com;
    
    # Global bandwidth limit
    limit_rate 100k;  # 100KB/s per connection
    
    location /downloads/ {
        # Specific bandwidth limits for downloads
        limit_rate 500k;  # 500KB/s for download area
        
        # Connection limits for downloads
        limit_conn download_limit 2;  # Max 2 concurrent downloads per IP
        
        try_files $uri =404;
    }
    
    # Premium users (higher bandwidth)
    location /premium-downloads/ {
        # Check for premium cookie/header
        if ($cookie_premium_user != "true") {
            return 403;
        }
        
        limit_rate 2m;  # 2MB/s for premium users
        limit_conn download_limit 5;
        
        try_files $uri =404;
    }
    
    # Streaming content
    location /stream/ {
        # Adaptive bandwidth based on content type
        location ~* \.mp4$ {
            limit_rate 1m;  # 1MB/s for video
        }
        
        location ~* \.mp3$ {
            limit_rate 128k;  # 128KB/s for audio
        }
        
        try_files $uri =404;
    }
}
```

## 🎯 E-Commerce DDoS Protection

### Complete E-Commerce Protection
```nginx
# E-commerce specific rate limiting
limit_req_zone $binary_remote_addr zone=ecom_browse:10m rate=30r/s;
limit_req_zone $binary_remote_addr zone=ecom_api:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=ecom_auth:10m rate=2r/s;
limit_req_zone $binary_remote_addr zone=ecom_checkout:10m rate=1r/s;
limit_req_zone $binary_remote_addr zone=ecom_payment:10m rate=1r/m;

# Connection limits
limit_conn_zone $binary_remote_addr zone=ecom_conn:10m;

# Suspicious activity detection
map $request_uri $is_ecom_attack {
    default 0;
    "~*/admin" 1;                      # Admin access attempts
    "~*wp-" 1;                         # WordPress attacks on non-WP site
    "~*phpmyadmin" 1;                  # Database admin attacks
    "~*\.php$" 1;                      # PHP execution on React app
    "~*\.(asp|jsp|cgi)$" 1;           # Other script attacks
}

# Geographic blocking for high-risk countries
geoip_country /usr/share/GeoIP/GeoIP.dat;
map $geoip_country_code $blocked_country {
    default 0;
    CN 1;  # Block China (adjust based on your needs)
    RU 1;  # Block Russia
    # Add other countries as needed
}

server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    ssl_certificate /etc/ssl/certs/shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/shop.example.com.key;
    
    # Global connection limit
    limit_conn ecom_conn 20;
    
    # Block high-risk countries (optional)
    if ($blocked_country = 1) {
        access_log /var/log/nginx/geo_blocks.log;
        return 403 "Access denied from your location";
    }
    
    # Block attack patterns
    if ($is_ecom_attack = 1) {
        access_log /var/log/nginx/ecom_attacks.log;
        return 444;
    }
    
    # Frontend browsing
    location / {
        limit_req zone=ecom_browse burst=60 nodelay;
        
        try_files $uri $uri/ /index.html;
    }
    
    # Product API (moderate limits)
    location /api/products/ {
        limit_req zone=ecom_api burst=40 nodelay;
        
        proxy_pass http://product_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Authentication (strict limits)
    location /api/auth/ {
        limit_req zone=ecom_auth burst=5 nodelay;
        
        # Log all auth attempts
        access_log /var/log/nginx/ecom_auth.log;
        
        proxy_pass http://auth_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Checkout process (very strict)
    location /api/checkout/ {
        limit_req zone=ecom_checkout burst=2 nodelay;
        
        # Require authentication
        auth_request /auth-validate;
        
        proxy_pass http://order_service/checkout/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # Payment processing (extremely strict)
    location /api/payments/ {
        limit_req zone=ecom_payment burst=1 nodelay;
        
        # Only POST allowed
        if ($request_method != POST) {
            return 405;
        }
        
        # Require authentication
        auth_request /auth-validate;
        
        # Enhanced logging
        access_log /var/log/nginx/payments.log;
        
        proxy_pass http://payment_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Payment-Protected "true";
    }
    
    # Search (moderate limits)
    location /api/search/ {
        limit_req zone=ecom_api burst=20 nodelay;
        
        proxy_pass http://search_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🚨 Automated Threat Response

### Dynamic IP Blocking
```bash
#!/bin/bash
# ddos-protection.sh - Automated DDoS protection

ACCESS_LOG="/var/log/nginx/access.log"
BLOCK_LOG="/var/log/nginx/blocked_ips.log"
TEMP_BLOCK_LIST="/tmp/nginx_blocked_ips"

# Thresholds
REQUEST_THRESHOLD=100    # Requests per minute
ERROR_THRESHOLD=50      # 4xx/5xx errors per minute
BLOCK_DURATION=3600     # Block for 1 hour

echo "=== DDoS Protection Monitor ==="
echo "Timestamp: $(date)"

# Analyze current minute traffic
CURRENT_MINUTE=$(date '+%d/%b/%Y:%H:%M')

# Find IPs with excessive requests
grep "$CURRENT_MINUTE" $ACCESS_LOG | \
awk '{print $1}' | sort | uniq -c | \
while read count ip; do
    if [ $count -gt $REQUEST_THRESHOLD ]; then
        echo "⚠️  High request rate from $ip: $count requests/minute"
        
        # Check if already blocked
        if ! grep -q "$ip" $TEMP_BLOCK_LIST 2>/dev/null; then
            echo "Blocking IP: $ip"
            iptables -A INPUT -s $ip -j DROP
            echo "$ip $(date +%s)" >> $TEMP_BLOCK_LIST
            echo "$(date): Blocked $ip for excessive requests ($count/min)" >> $BLOCK_LOG
        fi
    fi
done

# Find IPs with high error rates
grep "$CURRENT_MINUTE" $ACCESS_LOG | \
awk '$9 >= 400 {print $1}' | sort | uniq -c | \
while read count ip; do
    if [ $count -gt $ERROR_THRESHOLD ]; then
        echo "⚠️  High error rate from $ip: $count errors/minute"
        
        if ! grep -q "$ip" $TEMP_BLOCK_LIST 2>/dev/null; then
            echo "Blocking IP: $ip"
            iptables -A INPUT -s $ip -j DROP
            echo "$ip $(date +%s)" >> $TEMP_BLOCK_LIST
            echo "$(date): Blocked $ip for high error rate ($count/min)" >> $BLOCK_LOG
        fi
    fi
done

# Unblock IPs after block duration
if [ -f $TEMP_BLOCK_LIST ]; then
    CURRENT_TIME=$(date +%s)
    
    while read ip block_time; do
        if [ $((CURRENT_TIME - block_time)) -gt $BLOCK_DURATION ]; then
            echo "Unblocking IP: $ip"
            iptables -D INPUT -s $ip -j DROP 2>/dev/null
            sed -i "/$ip/d" $TEMP_BLOCK_LIST
            echo "$(date): Unblocked $ip after timeout" >> $BLOCK_LOG
        fi
    done < $TEMP_BLOCK_LIST
fi
```

### Fail2Ban Integration
```ini
# /etc/fail2ban/jail.d/nginx-ddos.conf
[nginx-ddos]
enabled = true
port = http,https
filter = nginx-ddos
logpath = /var/log/nginx/access.log
maxretry = 100
findtime = 60
bantime = 3600
action = iptables[name=nginx-ddos, port=http, protocol=tcp]

[nginx-auth]
enabled = true
port = http,https
filter = nginx-auth
logpath = /var/log/nginx/access.log
maxretry = 5
findtime = 300
bantime = 1800
action = iptables[name=nginx-auth, port=http, protocol=tcp]

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6
findtime = 60
bantime = 86400
action = iptables[name=nginx-noscript, port=http, protocol=tcp]
```

```ini
# /etc/fail2ban/filter.d/nginx-ddos.conf
[Definition]
failregex = ^<HOST> -.*"(GET|POST).*" (200|404) .*$
ignoreregex =

# /etc/fail2ban/filter.d/nginx-auth.conf
[Definition]
failregex = ^<HOST> -.*"(GET|POST) .*/login.*" (401|403) .*$
            ^<HOST> -.*"POST .*/api/auth/.*" (401|403) .*$
ignoreregex =

# /etc/fail2ban/filter.d/nginx-noscript.conf
[Definition]
failregex = ^<HOST> -.*"(GET|HEAD) .*/\.(php|asp|exe|pl|cgi|scr).*" .*$
ignoreregex =
```

## 🌍 Geographic and Behavioral Blocking

### Advanced Geographic Blocking
```nginx
# Geographic blocking with exceptions
geoip_country /usr/share/GeoIP/GeoIP.dat;
geoip_city /usr/share/GeoIP/GeoLiteCity.dat;

# Country-based access control
map $geoip_country_code $allowed_country {
    default yes;
    CN no;      # Block China
    RU no;      # Block Russia
    KP no;      # Block North Korea
    IR no;      # Block Iran
}

# City-based rate limiting
map $geoip_city $city_rate_limit {
    default 10r/s;
    "New York" 50r/s;
    "London" 30r/s;
    "Tokyo" 20r/s;
}

server {
    listen 80;
    server_name geo-protected.example.com;
    
    # Block countries
    if ($allowed_country = no) {
        access_log /var/log/nginx/geo_blocks.log;
        return 403 "Access denied from your country";
    }
    
    # Apply city-based rate limiting
    limit_req_zone $binary_remote_addr zone=city_limit:10m rate=$city_rate_limit;
    limit_req zone=city_limit burst=20 nodelay;
    
    # Add geographic headers
    add_header X-Country-Code $geoip_country_code always;
    add_header X-City $geoip_city always;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Behavioral Analysis
```nginx
# Behavioral pattern detection
map $request_uri $request_pattern {
    ~^/api/products/\d+$ "product_view";
    ~^/api/search "search";
    ~^/api/cart "cart_action";
    ~^/api/auth "authentication";
    default "other";
}

# Request frequency analysis
limit_req_zone $binary_remote_addr$request_pattern zone=behavior:10m rate=5r/s;

server {
    listen 80;
    server_name behavior-analysis.example.com;
    
    # Behavioral rate limiting
    location /api/ {
        limit_req zone=behavior burst=15 nodelay;
        
        # Add behavioral headers
        add_header X-Request-Pattern $request_pattern always;
        
        proxy_pass http://backend;
        proxy_set_header X-Request-Pattern $request_pattern;
    }
    
    # Detect scraping behavior
    location /api/products/ {
        # Detect rapid sequential product access
        if ($args ~* "id=\d+") {
            set $product_access 1;
        }
        
        # More restrictive limits for product scraping
        if ($product_access = 1) {
            limit_req zone=anti_scraping burst=5 nodelay;
        }
        
        proxy_pass http://backend;
    }
}
```

## 📊 Monitoring and Response

### Real-Time DDoS Monitoring
```bash
#!/bin/bash
# ddos-monitor.sh - Real-time DDoS monitoring

ACCESS_LOG="/var/log/nginx/access.log"
ALERT_THRESHOLD=1000
CURRENT_MINUTE=$(date '+%d/%b/%Y:%H:%M')

echo "=== DDoS Monitoring Dashboard ==="
echo "Time: $(date)"

# Current requests per minute
CURRENT_RPM=$(grep "$CURRENT_MINUTE" $ACCESS_LOG | wc -l)
echo "Current requests/minute: $CURRENT_RPM"

if [ $CURRENT_RPM -gt $ALERT_THRESHOLD ]; then
    echo "🚨 POTENTIAL DDOS DETECTED!"
    
    # Top attacking IPs
    echo "Top 10 requesting IPs:"
    grep "$CURRENT_MINUTE" $ACCESS_LOG | \
    awk '{print $1}' | sort | uniq -c | sort -nr | head -10
    
    # Request patterns
    echo "Request patterns:"
    grep "$CURRENT_MINUTE" $ACCESS_LOG | \
    awk '{print $7}' | sort | uniq -c | sort -nr | head -10
    
    # User agents
    echo "Top user agents:"
    grep "$CURRENT_MINUTE" $ACCESS_LOG | \
    awk -F'"' '{print $6}' | sort | uniq -c | sort -nr | head -5
    
    # Auto-block top attackers
    grep "$CURRENT_MINUTE" $ACCESS_LOG | \
    awk '{print $1}' | sort | uniq -c | sort -nr | head -5 | \
    while read count ip; do
        if [ $count -gt 100 ]; then
            echo "Auto-blocking $ip ($count requests)"
            iptables -A INPUT -s $ip -j DROP
        fi
    done
fi

# Connection statistics
echo "Active connections:"
curl -s http://localhost:8080/nginx_status | grep "Active connections"

# Error rate analysis
ERROR_RATE=$(grep "$CURRENT_MINUTE" $ACCESS_LOG | \
awk '$9 >= 400 {errors++} {total++} END {if(total>0) printf "%.2f", errors*100/total; else print "0"}')
echo "Current error rate: $ERROR_RATE%"
```

## 🎯 Practical Exercises

### Exercise 1: Rate Limiting Implementation
Configure comprehensive rate limiting:
- Multi-tier rate limiting
- Connection limits
- Bandwidth control
- Geographic restrictions

### Exercise 2: DDoS Protection Setup
Implement DDoS protection:
- Attack pattern detection
- Automated IP blocking
- Fail2Ban integration
- Real-time monitoring

### Exercise 3: E-Commerce Protection
Set up complete e-commerce protection:
- Business logic protection
- Payment security
- Behavioral analysis
- Automated threat response

---

**🎯 Next**: Performance optimization  
**📚 Resources**: [Nginx Rate Limiting](https://nginx.org/en/docs/http/ngx_http_limit_req_module.html)  
**🔧 Tools**: Use `iptables`, `fail2ban`, and monitoring tools for comprehensive protection
