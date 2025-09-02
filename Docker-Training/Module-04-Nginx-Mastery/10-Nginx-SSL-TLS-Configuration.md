# 🔒 Nginx SSL/TLS Configuration Complete Guide

## 📋 Overview

**Duration**: 6-8 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Virtual Hosts and Reverse Proxy completed  

Master SSL/TLS configuration for production environments, including modern security practices, certificate management, and performance optimization.

## 🎯 Learning Objectives

- Configure modern SSL/TLS protocols and cipher suites
- Implement certificate management and automation
- Master SSL termination and end-to-end encryption
- Optimize SSL/TLS performance for high-traffic sites
- Implement advanced security features (HSTS, OCSP, etc.)

## 📚 SSL/TLS Fundamentals

### Modern SSL/TLS Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name secure.example.com;
    
    # SSL Certificate files
    ssl_certificate /etc/ssl/certs/secure.example.com.crt;
    ssl_certificate_key /etc/ssl/private/secure.example.com.key;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    
    # TLS 1.3 cipher suites (automatic)
    # TLS 1.2 cipher suites
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    # SSL session optimization
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        root /var/www/secure.example.com;
        index index.html;
    }
}
```

### SSL Configuration Snippets
```nginx
# Create reusable SSL configuration snippets

# /etc/nginx/snippets/ssl-modern.conf
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

# /etc/nginx/snippets/ssl-security.conf
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# /etc/nginx/snippets/ssl-performance.conf
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;

# Usage in server blocks
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    include snippets/ssl-modern.conf;
    include snippets/ssl-security.conf;
    include snippets/ssl-performance.conf;
    
    location / {
        root /var/www/example.com;
    }
}
```

## 🔐 Certificate Management

### Self-Signed Certificates (Development)
```bash
# Generate self-signed certificate
sudo mkdir -p /etc/nginx/ssl

# Create private key
sudo openssl genrsa -out /etc/nginx/ssl/nginx-selfsigned.key 2048

# Create certificate signing request
sudo openssl req -new -key /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=*.example.com"

# Generate self-signed certificate
sudo openssl x509 -req -days 365 -in /etc/nginx/ssl/nginx-selfsigned.csr -signkey /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt

# Generate Diffie-Hellman parameters
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/nginx-selfsigned.key
sudo chmod 644 /etc/nginx/ssl/nginx-selfsigned.crt
```

### Let's Encrypt with Certbot
```bash
# Install Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Obtain certificate for single domain
sudo certbot --nginx -d example.com

# Obtain certificate for multiple domains
sudo certbot --nginx -d example.com -d www.example.com -d api.example.com

# Obtain wildcard certificate (DNS challenge required)
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com" -d example.com

# Test automatic renewal
sudo certbot renew --dry-run

# Set up automatic renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Manual Certificate Configuration
```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name example.com www.example.com;
    
    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    # Let's Encrypt certificates
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Include SSL configuration
    include snippets/ssl-modern.conf;
    include snippets/ssl-security.conf;
    include snippets/ssl-performance.conf;
    
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

## 🎯 E-Commerce SSL Configuration

### Complete E-Commerce SSL Setup
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=payment:10m rate=2r/s;

# HTTP to HTTPS redirect for all domains
server {
    listen 80;
    server_name shop.example.com api.shop.example.com admin.shop.example.com;
    
    # Let's Encrypt challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Security headers even for HTTP
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Redirect to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# Main e-commerce site
server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/shop.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/shop.example.com/privkey.pem;
    
    # Modern SSL configuration
    include snippets/ssl-modern.conf;
    include snippets/ssl-performance.conf;
    
    # Enhanced security headers for e-commerce
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://js.stripe.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.stripe.com; frame-src https://js.stripe.com;" always;
    
    # Frontend (React app)
    root /var/www/ecommerce/frontend/build;
    index index.html;
    
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
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://ecommerce_backend/;
        
        # SSL-aware proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-SSL on;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # Security headers for API
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
    }
    
    # Payment endpoints (extra security)
    location /api/payments/ {
        limit_req zone=payment burst=3 nodelay;
        
        # Additional security for payments
        if ($request_method !~ ^(GET|POST)$) {
            return 405;
        }
        
        proxy_pass http://ecommerce_backend/payments/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Payment-Secure "true";
        
        # Strict timeouts for payments
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}

# API subdomain
server {
    listen 443 ssl http2;
    server_name api.shop.example.com;
    
    ssl_certificate /etc/letsencrypt/live/api.shop.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.shop.example.com/privkey.pem;
    
    include snippets/ssl-modern.conf;
    include snippets/ssl-performance.conf;
    
    # API-specific security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        limit_req zone=api burst=30 nodelay;
        
        proxy_pass http://ecommerce_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Admin subdomain (restricted access)
server {
    listen 443 ssl http2;
    server_name admin.shop.example.com;
    
    ssl_certificate /etc/letsencrypt/live/admin.shop.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/admin.shop.example.com/privkey.pem;
    
    include snippets/ssl-modern.conf;
    include snippets/ssl-performance.conf;
    
    # Restrict access to admin IPs
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    # Enhanced security for admin
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Content-Security-Policy "default-src 'self'" always;
    
    location / {
        proxy_pass http://ecommerce_backend/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Admin-Access "true";
    }
}
```

## 🔧 Advanced SSL Features

### Client Certificate Authentication (Mutual TLS)
```nginx
server {
    listen 443 ssl http2;
    server_name secure-api.example.com;
    
    # Server certificates
    ssl_certificate /etc/ssl/certs/secure-api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/secure-api.example.com.key;
    
    # Client certificate verification
    ssl_client_certificate /etc/ssl/certs/client-ca.crt;
    ssl_verify_client on;
    ssl_verify_depth 2;
    
    # Pass client certificate info to backend
    location / {
        proxy_pass http://secure_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-SSL-Client-Cert $ssl_client_cert;
        proxy_set_header X-SSL-Client-DN $ssl_client_s_dn;
        proxy_set_header X-SSL-Client-Verify $ssl_client_verify;
    }
}
```

### SSL Proxy to HTTPS Backend
```nginx
upstream secure_backend {
    server secure-app1.internal:8443;
    server secure-app2.internal:8443;
}

server {
    listen 443 ssl http2;
    server_name proxy.example.com;
    
    # Frontend SSL
    ssl_certificate /etc/ssl/certs/proxy.example.com.crt;
    ssl_certificate_key /etc/ssl/private/proxy.example.com.key;
    
    location / {
        # Proxy to HTTPS backend
        proxy_pass https://secure_backend;
        
        # Backend SSL verification
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/backend-ca.crt;
        proxy_ssl_name secure-app.internal;
        proxy_ssl_server_name on;
        
        # Client certificate for backend
        proxy_ssl_certificate /etc/ssl/certs/proxy-client.crt;
        proxy_ssl_certificate_key /etc/ssl/private/proxy-client.key;
        
        # SSL session reuse
        proxy_ssl_session_reuse on;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📊 SSL Performance Optimization

### SSL Session Optimization
```nginx
# Global SSL session configuration
http {
    # Shared SSL session cache across workers
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;  # Disable for better security
    
    # SSL buffer sizes
    ssl_buffer_size 4k;  # Reduce for lower latency
    
    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
}

server {
    listen 443 ssl http2;
    server_name fast.example.com;
    
    ssl_certificate /etc/ssl/certs/fast.example.com.crt;
    ssl_certificate_key /etc/ssl/private/fast.example.com.key;
    
    # Optimize for performance
    ssl_protocols TLSv1.3;  # TLS 1.3 only for best performance
    ssl_early_data on;      # Enable 0-RTT (use with caution)
    
    location / {
        root /var/www/fast.example.com;
        
        # Preload resources
        add_header Link "</css/style.css>; rel=preload; as=style" always;
        add_header Link "</js/app.js>; rel=preload; as=script" always;
    }
}
```

### HTTP/2 and HTTP/3 Configuration
```nginx
# HTTP/2 configuration
server {
    listen 443 ssl http2;
    server_name http2.example.com;
    
    ssl_certificate /etc/ssl/certs/http2.example.com.crt;
    ssl_certificate_key /etc/ssl/private/http2.example.com.key;
    
    # HTTP/2 specific optimizations
    http2_max_field_size 16k;
    http2_max_header_size 32k;
    http2_max_requests 1000;
    
    location / {
        root /var/www/http2.example.com;
        
        # Server push for critical resources
        http2_push /css/critical.css;
        http2_push /js/critical.js;
    }
}

# HTTP/3 configuration (if supported)
server {
    listen 443 ssl http2;
    listen 443 http3 reuseport;  # Requires nginx with HTTP/3 support
    server_name http3.example.com;
    
    ssl_certificate /etc/ssl/certs/http3.example.com.crt;
    ssl_certificate_key /etc/ssl/private/http3.example.com.key;
    
    # Advertise HTTP/3 support
    add_header Alt-Svc 'h3=":443"; ma=86400' always;
    
    location / {
        root /var/www/http3.example.com;
    }
}
```

## 🔍 SSL Testing and Validation

### SSL Configuration Testing
```bash
#!/bin/bash
# ssl-test.sh - SSL configuration testing script

DOMAIN="example.com"
PORT="443"

echo "=== SSL Configuration Test for $DOMAIN ==="
echo

# Test SSL connection
echo "1. SSL Connection Test:"
timeout 10 openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN </dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ SSL connection successful"
else
    echo "❌ SSL connection failed"
fi

# Check certificate validity
echo -e "\n2. Certificate Validity:"
CERT_INFO=$(echo | openssl s_client -connect $DOMAIN:$PORT -servername $DOMAIN 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
echo "$CERT_INFO"

# Check supported protocols
echo -e "\n3. Supported Protocols:"
for protocol in ssl3 tls1 tls1_1 tls1_2 tls1_3; do
    result=$(timeout 5 openssl s_client -connect $DOMAIN:$PORT -$protocol </dev/null 2>&1)
    if echo "$result" | grep -q "Verify return code: 0"; then
        echo "✅ $protocol: Supported"
    else
        echo "❌ $protocol: Not supported"
    fi
done

# Check cipher suites
echo -e "\n4. Cipher Suites:"
openssl s_client -connect $DOMAIN:$PORT -cipher 'ECDHE+AESGCM' </dev/null 2>/dev/null | grep "Cipher is"

# Check HSTS header
echo -e "\n5. HSTS Header:"
HSTS=$(curl -s -I https://$DOMAIN | grep -i strict-transport-security)
if [ -n "$HSTS" ]; then
    echo "✅ HSTS: $HSTS"
else
    echo "❌ HSTS: Not configured"
fi

# SSL Labs rating (requires internet)
echo -e "\n6. SSL Labs Rating:"
echo "Check manually at: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
```

### Performance Testing
```bash
#!/bin/bash
# ssl-performance-test.sh

DOMAIN="example.com"

echo "=== SSL Performance Test ==="

# Test SSL handshake time
echo "1. SSL Handshake Performance:"
for i in {1..5}; do
    time_output=$(curl -w "@curl-format.txt" -o /dev/null -s https://$DOMAIN)
    echo "Test $i: $time_output"
done

# curl-format.txt content:
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Test concurrent SSL connections
echo -e "\n2. Concurrent Connection Test:"
ab -n 100 -c 10 https://$DOMAIN/
```

## 🎯 Practical Exercises

### Exercise 1: Complete SSL Setup
Configure SSL for e-commerce application with:
- Let's Encrypt certificates
- Modern TLS configuration
- Security headers
- Performance optimization

### Exercise 2: Multi-Domain SSL
Set up SSL for multiple subdomains:
- Wildcard certificate
- Individual domain certificates
- Proper redirects and headers

### Exercise 3: SSL Performance Optimization
Optimize SSL configuration for:
- Minimum handshake time
- Maximum throughput
- HTTP/2 support
- Session reuse

---

**🎯 Next**: Security headers and Web Application Firewall  
**📚 Resources**: [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)  
**🔧 Tools**: Use SSL Labs test to validate configuration
