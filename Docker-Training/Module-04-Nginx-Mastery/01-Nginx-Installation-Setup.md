# 🌐 Nginx Installation & Setup: Complete Expert Guide

## 🎯 Learning Objectives
- Master Nginx installation on all major platforms
- Understand Nginx architecture and components
- Configure basic Nginx settings and verify installation
- Learn Nginx service management and troubleshooting

---

## 📚 What is Nginx?

### Definition
**Nginx** (pronounced "engine-x") is a high-performance HTTP server, reverse proxy server, and load balancer. It's designed to handle thousands of concurrent connections efficiently using an event-driven, asynchronous architecture.

### Key Features
- **High Performance**: Handles 10,000+ concurrent connections
- **Low Memory Usage**: Efficient memory management
- **Reverse Proxy**: Forward requests to backend servers
- **Load Balancing**: Distribute traffic across multiple servers
- **SSL/TLS Termination**: Handle HTTPS encryption/decryption
- **Static Content**: Serve files directly from disk
- **Caching**: Cache responses to improve performance

### Nginx vs Apache Comparison

| Feature | Nginx | Apache |
|---------|-------|--------|
| **Architecture** | Event-driven, asynchronous | Process/thread-based |
| **Memory Usage** | Low (~2.5MB per 10k connections) | High (~8MB per connection) |
| **Performance** | Excellent for static content | Good for dynamic content |
| **Configuration** | Simple, declarative | Complex, flexible |
| **Modules** | Compiled-in modules | Dynamic module loading |
| **Use Case** | Reverse proxy, load balancer | Traditional web server |

---

## 🏗️ Nginx Architecture Deep Dive

### Process Model
```
Master Process (nginx)
├── Worker Process 1
├── Worker Process 2
├── Worker Process 3
└── Worker Process N
```

#### Master Process
- **Responsibilities**: Configuration reading, worker management, signal handling
- **Privileges**: Runs as root to bind to privileged ports
- **Operations**: Start/stop workers, reload configuration, log rotation

#### Worker Processes
- **Responsibilities**: Handle client connections, process requests
- **Privileges**: Run as non-privileged user (nginx/www-data)
- **Architecture**: Event-driven, single-threaded with event loop
- **Connections**: Each worker can handle thousands of connections

### Event-Driven Architecture
```
Worker Process Event Loop:
┌─────────────────────────────────────────┐
│ Accept new connections                  │
├─────────────────────────────────────────┤
│ Read HTTP requests                      │
├─────────────────────────────────────────┤
│ Process requests (static/proxy)         │
├─────────────────────────────────────────┤
│ Write HTTP responses                    │
├─────────────────────────────────────────┤
│ Close completed connections             │
└─────────────────────────────────────────┘
```

**Benefits:**
- **Non-blocking I/O**: No waiting for slow operations
- **Memory Efficient**: No thread per connection overhead
- **CPU Efficient**: Minimal context switching
- **Scalable**: Handles many connections with few processes

---

## 🔧 Nginx Installation Methods

### Method 1: Package Manager Installation (Recommended)

#### Ubuntu/Debian Installation
```bash
# Update package database
sudo apt update
```

**Expected Output:**
```
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Reading package lists... Done
```

```bash
# Install Nginx
sudo apt install nginx -y
```

**Expected Output:**
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  nginx-common nginx-core
Suggested packages:
  fcgiwrap nginx-doc
The following NEW packages will be installed:
  nginx nginx-common nginx-core
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 604 kB of archives.
After this operation, 2,224 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-common all 1.18.0-0ubuntu1.4 [37.5 kB]
Get:2 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx-core amd64 1.18.0-0ubuntu1.4 [425 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 nginx all 1.18.0-0ubuntu1.4 [3,620 B]
Fetched 604 kB in 2s (301 kB/s)
Selecting previously unselected package nginx-common.
(Reading database ... 185743 files and directories currently installed.)
Preparing to unpack .../nginx-common_1.18.0-0ubuntu1.4_all.deb ...
Unpacking nginx-common (1.18.0-0ubuntu1.4) ...
Setting up nginx-common (1.18.0-0ubuntu1.4) ...
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
```

#### CentOS/RHEL Installation
```bash
# Install EPEL repository
sudo yum install epel-release -y

# Install Nginx
sudo yum install nginx -y

# For newer versions, use dnf
sudo dnf install nginx -y
```

**Expected Output:**
```
Installed:
  nginx-1:1.20.1-13.el8.x86_64
  nginx-core-1:1.20.1-13.el8.x86_64
  nginx-filesystem-1:1.20.1-13.el8.noarch

Complete!
```

#### macOS Installation
```bash
# Using Homebrew
brew install nginx
```

**Expected Output:**
```
==> Downloading https://ghcr.io/v2/homebrew/core/nginx/manifests/1.23.3
==> Downloading https://ghcr.io/v2/homebrew/core/nginx/blobs/sha256:abc123...
==> Installing nginx
==> Pouring nginx--1.23.3.monterey.bottle.tar.gz
==> Caveats
Docroot is: /usr/local/var/www

The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
nginx can run without sudo.
```

### Method 2: Official Nginx Repository

#### Add Official Repository (Ubuntu)
```bash
# Install prerequisites
sudo apt install curl gnupg2 ca-certificates lsb-release -y

# Add Nginx signing key
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# Set repository priority
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx

# Update and install
sudo apt update
sudo apt install nginx -y
```

#### Add Official Repository (CentOS)
```bash
# Create repository file
sudo tee /etc/yum.repos.d/nginx.repo << 'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF

# Install Nginx
sudo yum install nginx -y
```

### Method 3: Compile from Source

#### Download and Compile
```bash
# Install build dependencies
sudo apt install build-essential libpcre3-dev libssl-dev zlib1g-dev -y

# Download Nginx source
cd /tmp
wget http://nginx.org/download/nginx-1.23.3.tar.gz
tar -xzf nginx-1.23.3.tar.gz
cd nginx-1.23.3

# Configure build
./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module

# Compile and install
make
sudo make install
```

**Expected Output:**
```
Configuration summary
  + using threads
  + using system PCRE library
  + using system OpenSSL library
  + using system zlib library

  nginx path prefix: "/etc/nginx"
  nginx binary file: "/usr/sbin/nginx"
  nginx modules path: "/usr/lib/nginx/modules"
  nginx configuration prefix: "/etc/nginx"
  nginx configuration file: "/etc/nginx/nginx.conf"
  nginx pid file: "/var/run/nginx.pid"
  nginx error log file: "/var/log/nginx/error.log"
  nginx http access log file: "/var/log/nginx/access.log"
```

---

## ✅ Installation Verification

### Check Nginx Version
```bash
# Check installed version
nginx -v
```

**Expected Output:**
```
nginx version: nginx/1.18.0 (Ubuntu)
```

```bash
# Detailed version information
nginx -V
```

**Expected Output:**
```
nginx version: nginx/1.18.0 (Ubuntu)
built with OpenSSL 1.1.1f  31 Mar 2020
TLS SNI support enabled
configure arguments: --with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-KTLRnK/nginx-1.18.0=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-mail=dynamic --with-mail_ssl_module
```

### Test Configuration Syntax
```bash
# Test Nginx configuration
sudo nginx -t
```

**Expected Output:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Check Nginx Status
```bash
# Check if Nginx is running
sudo systemctl status nginx
```

**Expected Output:**
```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:30:45 UTC; 2min 3s ago
       Docs: man:nginx(8)
   Main PID: 12345 (nginx)
      Tasks: 3 (limit: 2359)
     Memory: 6.2M
     CGroup: /system.slice/nginx.service
             ├─12345 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─12346 nginx: worker process
             └─12347 nginx: worker process

Jan 15 10:30:45 ubuntu systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 15 10:30:45 ubuntu systemd[1]: Started A high performance web server and a reverse proxy server.
```

---

## 🎛️ Nginx Service Management

### Systemd Service Control

#### Start/Stop/Restart Nginx
```bash
# Start Nginx
sudo systemctl start nginx

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx (stop then start)
sudo systemctl restart nginx

# Reload configuration without stopping
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx
```

#### Enable/Disable Auto-start
```bash
# Enable Nginx to start on boot
sudo systemctl enable nginx
```

**Expected Output:**
```
Synchronizing state of nginx.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable nginx
```

```bash
# Disable auto-start
sudo systemctl disable nginx

# Check if enabled
sudo systemctl is-enabled nginx
```

### Direct Nginx Commands

#### Configuration Testing
```bash
# Test configuration syntax
sudo nginx -t

# Test and dump configuration
sudo nginx -T

# Test specific configuration file
sudo nginx -t -c /path/to/nginx.conf
```

#### Signal Management
```bash
# Reload configuration gracefully
sudo nginx -s reload

# Stop gracefully (finish current requests)
sudo nginx -s quit

# Stop immediately
sudo nginx -s stop

# Reopen log files (for log rotation)
sudo nginx -s reopen
```

#### Process Information
```bash
# Show Nginx processes
ps aux | grep nginx
```

**Expected Output:**
```
root     12345  0.0  0.1  55180  1368 ?        Ss   10:30   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data 12346  0.0  0.1  55520  2024 ?        S    10:30   0:00 nginx: worker process
www-data 12347  0.0  0.1  55520  2024 ?        S    10:30   0:00 nginx: worker process
```

```bash
# Show listening ports
sudo netstat -tlnp | grep nginx
```

**Expected Output:**
```
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      12345/nginx: master
tcp6       0      0 :::80                   :::*                    LISTEN      12345/nginx: master
```

---

## 📁 Nginx Directory Structure

### Default Installation Paths

#### Ubuntu/Debian Structure
```bash
# Main configuration directory
ls -la /etc/nginx/
```

**Expected Output:**
```
total 72
drwxr-xr-x  8 root root 4096 Jan 15 10:30 .
drwxr-xr-x 95 root root 4096 Jan 15 10:30 ..
drwxr-xr-x  2 root root 4096 Jan 15 10:30 conf.d
-rw-r--r--  1 root root 1077 Feb 14  2022 fastcgi.conf
-rw-r--r--  1 root root 1007 Feb 14  2022 fastcgi_params
-rw-r--r--  1 root root 2837 Feb 14  2022 koi-utf
-rw-r--r--  1 root root 2223 Feb 14  2022 koi-win
-rw-r--r--  1 root root 3957 Feb 14  2022 mime.types
drwxr-xr-x  2 root root 4096 Jan 15 10:30 modules-available
drwxr-xr-x  2 root root 4096 Jan 15 10:30 modules-enabled
-rw-r--r--  1 root root 1447 Feb 14  2022 nginx.conf
-rw-r--r--  1 root root  180 Feb 14  2022 proxy_params
-rw-r--r--  1 root root  636 Feb 14  2022 scgi_params
drwxr-xr-x  2 root root 4096 Jan 15 10:30 sites-available
drwxr-xr-x  2 root root 4096 Jan 15 10:30 sites-enabled
drwxr-xr-x  2 root root 4096 Jan 15 10:30 snippets
-rw-r--r--  1 root root  664 Feb 14  2022 uwsgi_params
-rw-r--r--  1 root root 3071 Feb 14  2022 win-utf
```

#### Directory Purposes
```bash
# Configuration files
/etc/nginx/nginx.conf           # Main configuration file
/etc/nginx/conf.d/              # Additional configuration files
/etc/nginx/sites-available/     # Available virtual host configurations
/etc/nginx/sites-enabled/       # Enabled virtual host configurations (symlinks)
/etc/nginx/snippets/            # Reusable configuration snippets

# Content directories
/var/www/html/                  # Default document root
/usr/share/nginx/html/          # Alternative document root

# Log files
/var/log/nginx/access.log       # Access log
/var/log/nginx/error.log        # Error log

# Runtime files
/var/run/nginx.pid              # Process ID file
/var/cache/nginx/               # Cache directory
```

### CentOS/RHEL Structure
```bash
# Main configuration
/etc/nginx/nginx.conf           # Main configuration file
/etc/nginx/conf.d/              # Additional configuration files

# Content
/usr/share/nginx/html/          # Default document root

# Logs
/var/log/nginx/                 # Log directory
```

---

## 🌐 Basic Nginx Configuration

### Default Configuration Analysis
```bash
# View main configuration file
sudo cat /etc/nginx/nginx.conf
```

**Expected Output:**
```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    # multi_accept on;
}

http {
    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    ##
    # Logging Settings
    ##

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;

    # gzip_vary on;
    # gzip_proxied any;
    # gzip_comp_level 6;
    # gzip_buffers 16 8k;
    # gzip_http_version 1.1;
    # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

### Configuration Structure Explanation

#### Main Context
```nginx
# Global directives
user www-data;                    # User to run worker processes
worker_processes auto;            # Number of worker processes
pid /run/nginx.pid;              # PID file location
```

#### Events Context
```nginx
events {
    worker_connections 768;       # Max connections per worker
    use epoll;                   # Event method (Linux)
    multi_accept on;             # Accept multiple connections
}
```

#### HTTP Context
```nginx
http {
    # HTTP-specific directives
    sendfile on;                 # Efficient file serving
    keepalive_timeout 65;        # Keep connections alive
    
    # Include other configurations
    include /etc/nginx/mime.types;
    include /etc/nginx/sites-enabled/*;
}
```

### First Configuration Test
```bash
# Create simple test page
sudo mkdir -p /var/www/test
sudo tee /var/www/test/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Test Page</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .success { color: #28a745; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">✅ Nginx is Working!</h1>
        <p>This is a test page served by Nginx.</p>
        <hr>
        <p><strong>Server:</strong> Nginx</p>
        <p><strong>Document Root:</strong> /var/www/test</p>
        <p><strong>Time:</strong> <span id="time"></span></p>
    </div>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF
```

```bash
# Create basic server configuration
sudo tee /etc/nginx/sites-available/test << 'EOF'
server {
    listen 8080;
    server_name localhost;
    
    root /var/www/test;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/test /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

**Test the Configuration:**
```bash
# Test with curl
curl http://localhost:8080
```

**Expected Output:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Test Page</title>
    ...
</head>
<body>
    <div class="container">
        <h1 class="success">✅ Nginx is Working!</h1>
        ...
    </div>
</body>
</html>
```

---

## 🔍 Troubleshooting Common Issues

### Issue 1: Nginx Won't Start

#### Check Service Status
```bash
# Check detailed status
sudo systemctl status nginx -l
```

#### Check Configuration
```bash
# Test configuration syntax
sudo nginx -t
```

**Common Error:**
```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

**Solution:**
```bash
# Check what's using port 80
sudo netstat -tlnp | grep :80
sudo lsof -i :80

# Kill conflicting process or change port
sudo systemctl stop apache2  # If Apache is running
```

### Issue 2: Permission Denied

#### Check File Permissions
```bash
# Check document root permissions
ls -la /var/www/html/

# Fix permissions if needed
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

#### Check SELinux (CentOS/RHEL)
```bash
# Check SELinux status
sestatus

# Check SELinux denials
sudo ausearch -m AVC -ts recent

# Set SELinux context for web content
sudo setsebool -P httpd_can_network_connect 1
sudo restorecon -R /var/www/html/
```

### Issue 3: 502 Bad Gateway

#### Check Backend Services
```bash
# If using proxy_pass, check backend
curl http://backend-server:port/

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Issue 4: Configuration Not Loading

#### Check Include Paths
```bash
# Verify include statements
sudo nginx -T | grep include

# Check file existence
ls -la /etc/nginx/sites-enabled/
ls -la /etc/nginx/conf.d/
```

---

## 📊 Performance Verification

### Basic Performance Test
```bash
# Install Apache Bench
sudo apt install apache2-utils -y

# Test Nginx performance
ab -n 1000 -c 10 http://localhost/
```

**Expected Output:**
```
Server Software:        nginx/1.18.0
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        612 bytes

Concurrency Level:      10
Time taken for tests:   0.234 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      853000 bytes
HTML transferred:       612000 bytes
Requests per second:    4273.50 [#/sec] (mean)
Time per request:       2.341 [ms] (mean)
Time per request:       0.234 [ms] (mean, across all concurrent requests)
Transfer rate:          3559.87 [Kbytes/sec] received
```

### Monitor Nginx Processes
```bash
# Watch Nginx processes
watch 'ps aux | grep nginx'

# Monitor connections
watch 'netstat -an | grep :80 | wc -l'
```

---

## 🚀 Next Steps

You now have Nginx installed and running with basic configuration:

- ✅ **Installation Methods**: Package manager, official repo, source compilation
- ✅ **Service Management**: Start, stop, reload, enable/disable
- ✅ **Directory Structure**: Configuration files, logs, content directories
- ✅ **Basic Configuration**: Main config file structure and testing
- ✅ **Troubleshooting**: Common issues and solutions
- ✅ **Performance Testing**: Basic benchmarking and monitoring

**Ready for Part 2: Nginx Configuration Fundamentals** where you'll master server blocks, location directives, and basic web server configuration!
