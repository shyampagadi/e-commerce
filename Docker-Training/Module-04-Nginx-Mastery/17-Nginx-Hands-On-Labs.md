# 🧪 Module 4: Nginx Mastery - Comprehensive Hands-On Labs

## 📋 Lab Overview

**Total Labs**: 10 Comprehensive Labs  
**Duration**: 20-24 Hours  
**Skill Level**: Intermediate to Advanced  
**Prerequisites**: All Module 4 content completed  

These hands-on labs provide comprehensive practical experience with Nginx configuration, matching the detailed approach of Modules 1-3.

## 🔬 Lab 1: Basic Nginx Configuration & Virtual Hosts

### Objective
Master basic Nginx installation, configuration, and virtual host setup.

### Duration: 2-3 Hours

### Exercise 1.1: Nginx Installation and Setup
```bash
# Ubuntu/Debian installation
sudo apt update
sudo apt install nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify installation
nginx -v
sudo nginx -t
curl http://localhost

# Check default configuration
sudo nginx -T | head -50
```

### Exercise 1.2: Create Multiple Virtual Hosts
```bash
# Create directory structure
sudo mkdir -p /var/www/{main.local,api.local,admin.local}/html

# Create test content
echo "<h1>Main Site</h1>" | sudo tee /var/www/main.local/html/index.html
echo "<h1>API Site</h1>" | sudo tee /var/www/api.local/html/index.html
echo "<h1>Admin Site</h1>" | sudo tee /var/www/admin.local/html/index.html

# Create virtual host configurations
sudo tee /etc/nginx/sites-available/main.local <<EOF
server {
    listen 80;
    server_name main.local www.main.local;
    root /var/www/main.local/html;
    index index.html index.htm;
    
    access_log /var/log/nginx/main.local.access.log;
    error_log /var/log/nginx/main.local.error.log;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

sudo tee /etc/nginx/sites-available/api.local <<EOF
server {
    listen 80;
    server_name api.local;
    root /var/www/api.local/html;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location /health {
        return 200 "API Health OK";
        add_header Content-Type text/plain;
    }
}
EOF

# Enable sites
sudo ln -s /etc/nginx/sites-available/main.local /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/api.local /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx

# Test virtual hosts (add to /etc/hosts first)
echo "127.0.0.1 main.local api.local admin.local" | sudo tee -a /etc/hosts
curl -H "Host: main.local" http://localhost
curl -H "Host: api.local" http://localhost/health
```

### Expected Results
```bash
# Virtual host responses
$ curl -H "Host: main.local" http://localhost
<h1>Main Site</h1>

$ curl -H "Host: api.local" http://localhost/health
API Health OK
```

## 🔬 Lab 2: Reverse Proxy Configuration

### Objective
Configure Nginx as reverse proxy for backend applications.

### Duration: 3-4 Hours

### Exercise 2.1: Setup Backend Applications
```bash
# Create simple Python backend
mkdir -p ~/backend-apps
cd ~/backend-apps

# Backend 1 (Port 8001)
cat > app1.py <<EOF
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {"server": "backend-1", "port": 8001, "path": self.path}
        self.wfile.write(json.dumps(response).encode())

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8001), Handler)
    print("Backend 1 running on port 8001")
    server.serve_forever()
EOF

# Backend 2 (Port 8002)
cat > app2.py <<EOF
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {"server": "backend-2", "port": 8002, "path": self.path}
        self.wfile.write(json.dumps(response).encode())

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8002), Handler)
    print("Backend 2 running on port 8002")
    server.serve_forever()
EOF

# Start backends in background
python3 app1.py &
python3 app2.py &

# Test backends
curl http://localhost:8001/test
curl http://localhost:8002/test
```

### Exercise 2.2: Configure Reverse Proxy
```bash
# Create reverse proxy configuration
sudo tee /etc/nginx/sites-available/proxy.local <<EOF
upstream backend_servers {
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
}

server {
    listen 80;
    server_name proxy.local;
    
    access_log /var/log/nginx/proxy.local.access.log;
    error_log /var/log/nginx/proxy.local.error.log;
    
    location / {
        proxy_pass http://backend_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Add debug headers
        add_header X-Upstream-Server \$upstream_addr always;
        add_header X-Response-Time \$upstream_response_time always;
    }
    
    location /api/v1/ {
        proxy_pass http://127.0.0.1:8001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    location /api/v2/ {
        proxy_pass http://127.0.0.1:8002/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable and test
sudo ln -s /etc/nginx/sites-available/proxy.local /etc/nginx/sites-enabled/
echo "127.0.0.1 proxy.local" | sudo tee -a /etc/hosts
sudo nginx -t
sudo systemctl reload nginx

# Test load balancing
for i in {1..6}; do
    echo "Request $i:"
    curl -s http://proxy.local/ | jq .
    sleep 1
done

# Test specific routing
curl http://proxy.local/api/v1/users
curl http://proxy.local/api/v2/products
```

### Expected Results
```bash
# Load balancing should alternate between backends
Request 1: {"server": "backend-1", "port": 8001, "path": "/"}
Request 2: {"server": "backend-2", "port": 8002, "path": "/"}
Request 3: {"server": "backend-1", "port": 8001, "path": "/"}
```

## 🔬 Lab 3: SSL/TLS Configuration

### Objective
Implement SSL/TLS encryption with self-signed and Let's Encrypt certificates.

### Duration: 2-3 Hours

### Exercise 3.1: Self-Signed SSL Certificates
```bash
# Create SSL directory
sudo mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=secure.local"

# Create Diffie-Hellman group
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

# Create SSL configuration snippet
sudo tee /etc/nginx/snippets/self-signed.conf <<EOF
ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
EOF

sudo tee /etc/nginx/snippets/ssl-params.conf <<EOF
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/nginx/ssl/dhparam.pem;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384;
ssl_ecdh_curve secp384r1;
ssl_session_timeout 10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
EOF
```

### Exercise 3.2: HTTPS Virtual Host Configuration
```bash
# Create HTTPS virtual host
sudo tee /etc/nginx/sites-available/secure.local <<EOF
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name secure.local;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name secure.local;
    
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;
    
    root /var/www/secure.local/html;
    index index.html;
    
    access_log /var/log/nginx/secure.local.access.log;
    error_log /var/log/nginx/secure.local.error.log;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8001/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-SSL on;
    }
}
EOF

# Create content
sudo mkdir -p /var/www/secure.local/html
echo "<h1>Secure Site - HTTPS Enabled</h1>" | sudo tee /var/www/secure.local/html/index.html

# Enable site
sudo ln -s /etc/nginx/sites-available/secure.local /etc/nginx/sites-enabled/
echo "127.0.0.1 secure.local" | sudo tee -a /etc/hosts

# Test configuration
sudo nginx -t
sudo systemctl reload nginx

# Test HTTPS (ignore certificate warnings for self-signed)
curl -k https://secure.local
curl -I http://secure.local  # Should redirect to HTTPS
```

### Exercise 3.3: SSL Testing and Validation
```bash
# Test SSL configuration
openssl s_client -connect secure.local:443 -servername secure.local

# Check SSL certificate details
echo | openssl s_client -connect secure.local:443 -servername secure.local 2>/dev/null | openssl x509 -noout -text

# Test SSL Labs rating (for real certificates)
# curl -s "https://api.ssllabs.com/api/v3/analyze?host=secure.local"
```

## 🔬 Lab 4: Load Balancing & High Availability

### Objective
Configure advanced load balancing with health checks and failover.

### Duration: 3-4 Hours

### Exercise 4.1: Multiple Backend Setup
```bash
# Create multiple backend applications
cd ~/backend-apps

# Create health check endpoint
cat > health_backend.py <<EOF
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import sys
import random
import time

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            # Simulate occasional health check failures
            if random.random() < 0.1:  # 10% failure rate
                self.send_response(503)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {"status": "unhealthy", "server": f"backend-{sys.argv[1]}"}
            else:
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {"status": "healthy", "server": f"backend-{sys.argv[1]}"}
        else:
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                "server": f"backend-{sys.argv[1]}", 
                "port": int(sys.argv[2]),
                "path": self.path,
                "timestamp": time.time()
            }
        
        self.wfile.write(json.dumps(response).encode())

if __name__ == '__main__':
    port = int(sys.argv[2])
    server = HTTPServer(('localhost', port), HealthHandler)
    print(f"Backend {sys.argv[1]} running on port {port}")
    server.serve_forever()
EOF

# Start multiple backends
python3 health_backend.py 1 8001 &
python3 health_backend.py 2 8002 &
python3 health_backend.py 3 8003 &

# Test health endpoints
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
```

### Exercise 4.2: Advanced Load Balancing Configuration
```bash
# Create advanced load balancing configuration
sudo tee /etc/nginx/sites-available/loadbalancer.local <<EOF
# Define upstream with different load balancing methods
upstream backend_round_robin {
    server 127.0.0.1:8001 weight=3 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 weight=2 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8003 weight=1 max_fails=3 fail_timeout=30s;
}

upstream backend_least_conn {
    least_conn;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

upstream backend_ip_hash {
    ip_hash;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

upstream backend_with_backup {
    server 127.0.0.1:8001 max_fails=2 fail_timeout=10s;
    server 127.0.0.1:8002 max_fails=2 fail_timeout=10s;
    server 127.0.0.1:8003 backup;
}

server {
    listen 80;
    server_name lb.local;
    
    # Default load balancing (round robin)
    location / {
        proxy_pass http://backend_round_robin;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        
        # Error handling
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
        proxy_next_upstream_timeout 10s;
        
        # Add upstream info to response
        add_header X-Upstream-Server \$upstream_addr always;
        add_header X-Upstream-Response-Time \$upstream_response_time always;
        add_header X-Upstream-Status \$upstream_status always;
    }
    
    # Least connections
    location /least_conn/ {
        proxy_pass http://backend_least_conn/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # IP hash (session persistence)
    location /session/ {
        proxy_pass http://backend_ip_hash/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # With backup server
    location /backup/ {
        proxy_pass http://backend_with_backup/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # Health check aggregation
    location /health {
        access_log off;
        return 200 "Load Balancer OK";
        add_header Content-Type text/plain;
    }
}
EOF

# Enable and test
sudo ln -s /etc/nginx/sites-available/loadbalancer.local /etc/nginx/sites-enabled/
echo "127.0.0.1 lb.local" | sudo tee -a /etc/hosts
sudo nginx -t
sudo systemctl reload nginx
```

### Exercise 4.3: Load Balancing Testing
```bash
# Test round robin load balancing
echo "=== Round Robin Load Balancing ==="
for i in {1..9}; do
    echo "Request $i:"
    curl -s http://lb.local/ | jq -r '.server'
done

# Test session persistence (IP hash)
echo -e "\n=== Session Persistence (IP Hash) ==="
for i in {1..6}; do
    echo "Request $i:"
    curl -s http://lb.local/session/ | jq -r '.server'
done

# Test failover by stopping a backend
echo -e "\n=== Testing Failover ==="
# Kill backend 1
pkill -f "health_backend.py 1"

# Test requests (should not go to backend 1)
for i in {1..6}; do
    echo "Request $i (backend 1 down):"
    curl -s http://lb.local/ | jq -r '.server'
done

# Restart backend 1
python3 health_backend.py 1 8001 &
sleep 2

# Test recovery
echo -e "\n=== Testing Recovery ==="
for i in {1..6}; do
    echo "Request $i (backend 1 recovered):"
    curl -s http://lb.local/ | jq -r '.server'
done
```

## 🔬 Lab 5: E-Commerce Application Deployment

### Objective
Deploy complete e-commerce application with Nginx as frontend and reverse proxy.

### Duration: 4-5 Hours

### Exercise 5.1: E-Commerce Backend Setup
```bash
# Navigate to e-commerce project
cd /mnt/c/Users/Shyam/Documents/e-commerce

# Start backend (ensure database is running)
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Start backend on multiple ports for load balancing
uvicorn main:app --host 0.0.0.0 --port 8001 &
uvicorn main:app --host 0.0.0.0 --port 8002 &

# Test backends
curl http://localhost:8001/docs
curl http://localhost:8002/health
```

### Exercise 5.2: Frontend Build and Deployment
```bash
# Build React frontend
cd ../frontend
npm install
npm run build

# Copy build to Nginx directory
sudo mkdir -p /var/www/ecommerce
sudo cp -r build/* /var/www/ecommerce/
sudo chown -R www-data:www-data /var/www/ecommerce
```

### Exercise 5.3: Complete Nginx Configuration
```bash
# Create comprehensive e-commerce Nginx configuration
sudo tee /etc/nginx/sites-available/ecommerce.local <<EOF
# Rate limiting
limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=auth:10m rate=5r/s;

# Backend upstream
upstream ecommerce_backend {
    least_conn;
    server 127.0.0.1:8001 weight=2 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:8002 weight=1 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

# Main e-commerce server
server {
    listen 80;
    server_name ecommerce.local www.ecommerce.local;
    
    root /var/www/ecommerce;
    index index.html;
    
    # Logging
    access_log /var/log/nginx/ecommerce.access.log;
    error_log /var/log/nginx/ecommerce.error.log;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Frontend (React SPA)
    location / {
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            access_log off;
        }
        
        # Cache HTML files briefly
        location ~* \.html$ {
            expires 1h;
            add_header Cache-Control "public, must-revalidate";
        }
    }
    
    # API endpoints
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://ecommerce_backend/;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Headers
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Request-ID \$request_id;
        
        # CORS headers
        add_header Access-Control-Allow-Origin "http://ecommerce.local" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
        
        # Handle preflight requests
        if (\$request_method = OPTIONS) {
            return 204;
        }
        
        # Timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Error handling
        proxy_next_upstream error timeout http_500 http_502 http_503;
        proxy_next_upstream_tries 2;
        proxy_next_upstream_timeout 10s;
    }
    
    # Authentication endpoints (stricter rate limiting)
    location /api/auth/ {
        limit_req zone=auth burst=5 nodelay;
        
        proxy_pass http://ecommerce_backend/auth/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # File uploads
    location /uploads/ {
        root /var/www/ecommerce;
        expires 30d;
        add_header Cache-Control "public";
    }
    
    # Health check
    location /health {
        access_log off;
        return 200 "E-commerce site healthy";
        add_header Content-Type text/plain;
    }
    
    # Admin access (restricted)
    location /admin {
        allow 127.0.0.1;
        allow 192.168.1.0/24;
        deny all;
        
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/ecommerce.local /etc/nginx/sites-enabled/
echo "127.0.0.1 ecommerce.local" | sudo tee -a /etc/hosts

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

### Exercise 5.4: Application Testing
```bash
# Test frontend
curl -I http://ecommerce.local
curl http://ecommerce.local/health

# Test API endpoints
curl http://ecommerce.local/api/products/
curl http://ecommerce.local/api/categories/

# Test load balancing
for i in {1..10}; do
    echo "API Request $i:"
    curl -s http://ecommerce.local/api/health | jq .
    sleep 0.5
done

# Test rate limiting
echo "Testing rate limiting..."
for i in {1..15}; do
    curl -w "%{http_code}\n" -o /dev/null -s http://ecommerce.local/api/products/
done

# Performance testing
ab -n 100 -c 10 http://ecommerce.local/
ab -n 50 -c 5 http://ecommerce.local/api/products/
```

### Expected Results
```bash
# Frontend should load React application
# API endpoints should return JSON responses
# Load balancing should distribute requests
# Rate limiting should return 429 after limits exceeded
# Performance tests should show response times <200ms
```

## 🎯 Lab Assessment Criteria

### Technical Requirements (80%)
- [ ] All virtual hosts configured and accessible
- [ ] Reverse proxy working with proper headers
- [ ] SSL/TLS configured with security headers
- [ ] Load balancing distributing requests correctly
- [ ] Rate limiting and security measures active
- [ ] E-commerce application fully functional

### Performance Benchmarks (20%)
- [ ] Response times <200ms for static content
- [ ] API response times <500ms
- [ ] Load balancing efficiency >95%
- [ ] SSL handshake time <100ms
- [ ] Concurrent connections >1000

## 📊 Success Metrics

### Configuration Mastery
- Create complex Nginx configurations from scratch
- Implement production-ready security headers
- Configure advanced load balancing strategies
- Troubleshoot configuration issues quickly

### Performance Optimization
- Achieve sub-200ms response times
- Handle 1000+ concurrent connections
- Implement effective caching strategies
- Optimize SSL/TLS performance

---

**🎯 Next**: Module 4 comprehensive assessment  
**📚 Resources**: [Nginx Testing Guide](https://nginx.org/en/docs/debugging_log.html)  
**🔧 Tools**: Use `nginx -t`, `curl`, and `ab` for testing configurations
