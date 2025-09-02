# Nginx Configuration in Docker

## Learning Objectives
- Understand Nginx architecture and configuration
- Configure Nginx for different use cases
- Implement reverse proxy and load balancing
- Secure Nginx configurations

## Nginx Fundamentals

### What is Nginx?
Nginx is a high-performance web server, reverse proxy, and load balancer. It's commonly used in Docker containers for:
- Serving static files
- Reverse proxying to backend services
- Load balancing across multiple instances
- SSL termination
- Caching

### Nginx Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Client      │───▶│      Nginx      │───▶│   Backend App   │
│   (Browser)     │    │  (Reverse Proxy)│    │   (Node.js)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Basic Nginx Configuration

### Default Configuration Structure
```nginx
# Main context
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;

# Events context
events {
    worker_connections 1024;
}

# HTTP context
http {
    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    
    # Server context
    server {
        listen 80;
        server_name localhost;
        
        # Location context
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
```

## Hands-On Exercise 1: Basic Static Website

Let's create a static website with custom Nginx configuration:

```bash
# 1. Create project directory
mkdir ~/nginx-static-site
cd ~/nginx-static-site

# 2. Create website content
mkdir -p public/css public/js public/images

# Create HTML file
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Docker Nginx Site</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Welcome to My Docker Nginx Site</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/about.html">About</a>
            <a href="/api/status">API Status</a>
        </nav>
    </header>
    <main>
        <section>
            <h2>Features</h2>
            <ul>
                <li>✅ Static file serving</li>
                <li>✅ Custom Nginx configuration</li>
                <li>✅ Docker containerized</li>
                <li>✅ Production ready</li>
            </ul>
        </section>
        <section>
            <h2>Server Info</h2>
            <p>This page is served by Nginx running in a Docker container.</p>
            <button onclick="loadServerInfo()">Load Server Info</button>
            <div id="server-info"></div>
        </section>
    </main>
    <script src="/js/app.js"></script>
</body>
</html>
EOF

# Create CSS file
cat > public/css/style.css << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f4f4f4;
}

header {
    background: #2c3e50;
    color: white;
    padding: 1rem;
    text-align: center;
}

nav {
    margin-top: 1rem;
}

nav a {
    color: white;
    text-decoration: none;
    margin: 0 1rem;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    transition: background 0.3s;
}

nav a:hover {
    background: #34495e;
}

main {
    max-width: 800px;
    margin: 2rem auto;
    padding: 0 1rem;
}

section {
    background: white;
    margin: 2rem 0;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

button {
    background: #3498db;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    cursor: pointer;
    transition: background 0.3s;
}

button:hover {
    background: #2980b9;
}

#server-info {
    margin-top: 1rem;
    padding: 1rem;
    background: #ecf0f1;
    border-radius: 4px;
    font-family: monospace;
}
EOF

# Create JavaScript file
cat > public/js/app.js << 'EOF'
function loadServerInfo() {
    const serverInfo = document.getElementById('server-info');
    serverInfo.innerHTML = `
        <h3>Server Information</h3>
        <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
        <p><strong>User Agent:</strong> ${navigator.userAgent}</p>
        <p><strong>Page URL:</strong> ${window.location.href}</p>
        <p><strong>Server:</strong> Nginx in Docker Container</p>
    `;
}

// Load server info on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('Page loaded successfully');
});
EOF

# Create about page
cat > public/about.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - My Docker Nginx Site</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <header>
        <h1>About This Site</h1>
        <nav>
            <a href="/">Home</a>
            <a href="/about.html">About</a>
            <a href="/api/status">API Status</a>
        </nav>
    </header>
    <main>
        <section>
            <h2>Technology Stack</h2>
            <ul>
                <li><strong>Web Server:</strong> Nginx</li>
                <li><strong>Container:</strong> Docker</li>
                <li><strong>Base Image:</strong> nginx:alpine</li>
                <li><strong>Configuration:</strong> Custom nginx.conf</li>
            </ul>
        </section>
        <section>
            <h2>Features Demonstrated</h2>
            <ul>
                <li>Static file serving</li>
                <li>Custom MIME types</li>
                <li>Error pages</li>
                <li>Security headers</li>
                <li>Gzip compression</li>
            </ul>
        </section>
    </main>
</body>
</html>
EOF

# 3. Create custom Nginx configuration
cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging format
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    # Performance settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html index.htm;

        # Main location
        location / {
            try_files $uri $uri/ =404;
        }

        # API endpoint simulation
        location /api/status {
            add_header Content-Type application/json;
            return 200 '{"status":"healthy","server":"nginx","timestamp":"$time_iso8601"}';
        }

        # Static assets with caching
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Custom error pages
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;

        location = /404.html {
            internal;
        }

        location = /50x.html {
            internal;
        }

        # Security: deny access to hidden files
        location ~ /\. {
            deny all;
        }
    }
}
EOF

# 4. Create error pages
cat > public/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>404 - Page Not Found</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <header>
        <h1>404 - Page Not Found</h1>
    </header>
    <main>
        <section>
            <h2>Oops! Page not found</h2>
            <p>The page you're looking for doesn't exist.</p>
            <a href="/">Go back to home</a>
        </section>
    </main>
</body>
</html>
EOF

cat > public/50x.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Server Error</title>
    <link rel="stylesheet" href="/css/style.css">
</head>
<body>
    <header>
        <h1>Server Error</h1>
    </header>
    <main>
        <section>
            <h2>Something went wrong</h2>
            <p>We're experiencing technical difficulties. Please try again later.</p>
            <a href="/">Go back to home</a>
        </section>
    </main>
</body>
</html>
EOF

# 5. Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy website content
COPY public/ /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# 6. Build and run
docker build -t my-nginx-site .
docker run -d -p 8080:80 --name nginx-site my-nginx-site

# 7. Test the website
curl http://localhost:8080
curl http://localhost:8080/about.html
curl http://localhost:8080/api/status

# 8. Test error pages
curl http://localhost:8080/nonexistent

# 9. Check logs
docker logs nginx-site

# 10. Clean up
docker stop nginx-site
docker rm nginx-site
```

## Reverse Proxy Configuration

### Basic Reverse Proxy
```nginx
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Hands-On Exercise 2: Reverse Proxy Setup

Let's create a reverse proxy that forwards requests to a backend service:

```bash
# 1. Create reverse proxy project
mkdir ~/nginx-reverse-proxy
cd ~/nginx-reverse-proxy

# 2. Create backend application
mkdir backend
cat > backend/server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// API routes
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'backend-api',
        timestamp: new Date().toISOString(),
        headers: req.headers
    });
});

app.get('/api/users', (req, res) => {
    res.json({
        users: [
            { id: 1, name: 'John Doe', email: 'john@example.com' },
            { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
        ]
    });
});

app.post('/api/users', (req, res) => {
    res.json({
        message: 'User created',
        user: req.body,
        id: Math.floor(Math.random() * 1000)
    });
});

app.listen(PORT, () => {
    console.log(`Backend API running on port ${PORT}`);
});
EOF

cat > backend/package.json << 'EOF'
{
    "name": "backend-api",
    "version": "1.0.0",
    "main": "server.js",
    "scripts": {
        "start": "node server.js"
    },
    "dependencies": {
        "express": "^4.18.0"
    }
}
EOF

cat > backend/Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 3. Create frontend
mkdir frontend
cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Reverse Proxy Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        button { margin: 10px; padding: 10px 20px; }
        .response { background: #f0f0f0; padding: 20px; margin: 20px 0; border-radius: 5px; }
        pre { white-space: pre-wrap; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Nginx Reverse Proxy Demo</h1>
        <p>This frontend communicates with a backend API through Nginx reverse proxy.</p>
        
        <div>
            <button onclick="checkHealth()">Check API Health</button>
            <button onclick="getUsers()">Get Users</button>
            <button onclick="createUser()">Create User</button>
        </div>
        
        <div id="response" class="response" style="display:none;">
            <h3>Response:</h3>
            <pre id="response-content"></pre>
        </div>
    </div>

    <script>
        async function makeRequest(url, options = {}) {
            try {
                const response = await fetch(url, options);
                const data = await response.json();
                showResponse(data);
            } catch (error) {
                showResponse({ error: error.message });
            }
        }

        function showResponse(data) {
            document.getElementById('response').style.display = 'block';
            document.getElementById('response-content').textContent = JSON.stringify(data, null, 2);
        }

        function checkHealth() {
            makeRequest('/api/health');
        }

        function getUsers() {
            makeRequest('/api/users');
        }

        function createUser() {
            makeRequest('/api/users', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name: 'New User', email: 'new@example.com' })
            });
        }
    </script>
</body>
</html>
EOF

# 4. Create Nginx configuration for reverse proxy
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # Serve static frontend files
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # Proxy API requests to backend
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS headers
            add_header Access-Control-Allow-Origin *;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
            add_header Access-Control-Allow-Headers "Content-Type, Authorization";
            
            # Handle preflight requests
            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }

        # Health check for nginx itself
        location /nginx-health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# 5. Create Nginx Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY frontend/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# 6. Create Docker Compose file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  backend:
    build: ./backend
    container_name: api-backend
    networks:
      - app-network

  nginx:
    build: .
    container_name: nginx-proxy
    ports:
      - "8080:80"
    depends_on:
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

# 7. Start the services
docker-compose up -d

# 8. Test the setup
curl http://localhost:8080  # Frontend
curl http://localhost:8080/api/health  # Backend through proxy
curl http://localhost:8080/nginx-health  # Nginx health

# 9. Test in browser
echo "Open http://localhost:8080 in your browser and test the buttons"

# 10. Check logs
docker-compose logs nginx
docker-compose logs backend

# 11. Clean up
docker-compose down
```

## Load Balancing Configuration

### Round Robin Load Balancing
```nginx
upstream backend {
    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### Weighted Load Balancing
```nginx
upstream backend {
    server backend1:3000 weight=3;
    server backend2:3000 weight=2;
    server backend3:3000 weight=1;
}
```

### Health Checks
```nginx
upstream backend {
    server backend1:3000 max_fails=3 fail_timeout=30s;
    server backend2:3000 max_fails=3 fail_timeout=30s;
    server backend3:3000 backup;  # backup server
}
```

## Hands-On Exercise 3: Load Balancer

```bash
# 1. Create load balancer project
mkdir ~/nginx-load-balancer
cd ~/nginx-load-balancer

# 2. Create simple backend service
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const INSTANCE_ID = process.env.INSTANCE_ID || 'unknown';

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from backend!',
        instance: INSTANCE_ID,
        timestamp: new Date().toISOString(),
        hostname: require('os').hostname()
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy', instance: INSTANCE_ID });
});

app.listen(PORT, () => {
    console.log(`Backend ${INSTANCE_ID} running on port ${PORT}`);
});
EOF

cat > package.json << 'EOF'
{
    "name": "backend-service",
    "version": "1.0.0",
    "main": "app.js",
    "scripts": {
        "start": "node app.js"
    },
    "dependencies": {
        "express": "^4.18.0"
    }
}
EOF

cat > Dockerfile.backend << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY app.js .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# 3. Create load balancer configuration
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    # Define upstream servers
    upstream backend_servers {
        server backend1:3000 weight=2;
        server backend2:3000 weight=2;
        server backend3:3000 weight=1;
        
        # Health check settings
        # max_fails=3 fail_timeout=30s;
    }

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" upstream: $upstream_addr';

    access_log /var/log/nginx/access.log main;

    server {
        listen 80;
        server_name localhost;

        # Load balance all requests
        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Connection settings
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
        }

        # Health check endpoint
        location /nginx-status {
            access_log off;
            return 200 "nginx is healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# 4. Create Docker Compose with multiple backend instances
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  backend1:
    build:
      context: .
      dockerfile: Dockerfile.backend
    environment:
      - INSTANCE_ID=backend-1
      - PORT=3000
    networks:
      - app-network

  backend2:
    build:
      context: .
      dockerfile: Dockerfile.backend
    environment:
      - INSTANCE_ID=backend-2
      - PORT=3000
    networks:
      - app-network

  backend3:
    build:
      context: .
      dockerfile: Dockerfile.backend
    environment:
      - INSTANCE_ID=backend-3
      - PORT=3000
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend1
      - backend2
      - backend3
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

# 5. Start all services
docker-compose up -d

# 6. Test load balancing
echo "Testing load balancing - making 10 requests:"
for i in {1..10}; do
    echo "Request $i:"
    curl -s http://localhost:8080 | jq '.instance'
    sleep 1
done

# 7. Test health checks
curl http://localhost:8080/health

# 8. Scale backend services
docker-compose up -d --scale backend2=2

# 9. Test again
echo "Testing after scaling:"
for i in {1..5}; do
    curl -s http://localhost:8080 | jq '.instance'
done

# 10. Check logs
docker-compose logs nginx

# 11. Clean up
docker-compose down
```

## SSL/TLS Configuration

### Basic SSL Setup
```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://backend;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

## Performance Optimization

### Caching Configuration
```nginx
# Proxy cache
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=10g 
                 inactive=60m use_temp_path=off;

server {
    location / {
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_pass http://backend;
    }
}
```

### Rate Limiting
```nginx
# Define rate limit zone
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://backend;
    }
}
```

## Security Best Practices

### Security Headers
```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self'" always;

# Hide nginx version
server_tokens off;
```

### Access Control
```nginx
# IP-based access control
location /admin/ {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    proxy_pass http://backend;
}

# Basic authentication
location /secure/ {
    auth_basic "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://backend;
}
```

## Monitoring and Logging

### Custom Log Formats
```nginx
log_format detailed '$remote_addr - $remote_user [$time_local] '
                   '"$request" $status $body_bytes_sent '
                   '"$http_referer" "$http_user_agent" '
                   'rt=$request_time uct="$upstream_connect_time" '
                   'uht="$upstream_header_time" urt="$upstream_response_time"';

access_log /var/log/nginx/detailed.log detailed;
```

### Status Module
```nginx
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}
```

## Troubleshooting Common Issues

### Debug Configuration
```bash
# Test nginx configuration
docker exec nginx-container nginx -t

# Reload configuration
docker exec nginx-container nginx -s reload

# Check error logs
docker logs nginx-container
docker exec nginx-container tail -f /var/log/nginx/error.log
```

### Common Problems and Solutions

#### 502 Bad Gateway
- Backend service is down
- Wrong upstream configuration
- Network connectivity issues

#### 413 Request Entity Too Large
```nginx
client_max_body_size 100M;
```

#### Slow Response Times
```nginx
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
```

## Next Steps

You now understand Nginx configuration in Docker:
- ✅ Basic Nginx configuration
- ✅ Static file serving
- ✅ Reverse proxy setup
- ✅ Load balancing
- ✅ Security configurations
- ✅ Performance optimization

**Ready for Module 4: Docker Compose** where you'll learn to orchestrate multi-container applications!
