# Networking Basics for Docker

## Learning Objectives
- Understand basic networking concepts
- Learn about ports and protocols
- Practice network troubleshooting
- Prepare for Docker networking

## Core Networking Concepts

### IP Addresses and Ports
```bash
# Your machine's IP address
ip addr show
ifconfig  # on macOS/older Linux

# Common port ranges
# 1-1023:    System/privileged ports
# 1024-49151: Registered ports
# 49152-65535: Dynamic/private ports
```

### Localhost and Loopback
```bash
# These all refer to your local machine
ping localhost
ping 127.0.0.1
ping ::1  # IPv6 loopback
```

### Testing Network Connectivity
```bash
# Test if a service is running on a port
telnet localhost 8080
nc -zv localhost 8080  # netcat version

# Test internet connectivity
ping google.com
curl -I https://google.com
```

## Hands-On Exercise 1: Port Testing

Let's simulate what Docker will do - run services on different ports:

```bash
# 1. Start a simple web server on port 8080
cd ~/docker-practice
python3 -m http.server 8080 &
SERVER_PID=$!

# 2. Test the connection
curl http://localhost:8080
# Should show directory listing

# 3. Check what's listening on port 8080
netstat -tlnp | grep 8080
# or
ss -tlnp | grep 8080

# 4. Stop the server
kill $SERVER_PID
```

## Understanding Protocols

### HTTP/HTTPS
```bash
# HTTP request (what browsers do)
curl -v http://httpbin.org/get

# HTTPS request
curl -v https://httpbin.org/get

# Different HTTP methods
curl -X POST http://httpbin.org/post
curl -X PUT http://httpbin.org/put
curl -X DELETE http://httpbin.org/delete
```

### TCP vs UDP
```bash
# TCP connection (reliable, ordered)
nc -l 8080  # listen on TCP port 8080

# In another terminal:
nc localhost 8080  # connect to TCP port 8080

# UDP connection (fast, no guarantees)
nc -u -l 8081  # listen on UDP port 8081

# In another terminal:
nc -u localhost 8081  # connect to UDP port 8081
```

## Hands-On Exercise 2: Multi-Service Setup

Simulate running multiple services (like Docker containers):

```bash
# 1. Create three simple services
mkdir -p ~/multi-service/{web,api,db}

# Web service (port 8080)
cd ~/multi-service/web
cat > index.html << 'EOF'
<h1>Web Service</h1>
<p>Running on port 8080</p>
EOF

# API service files (port 8081)
cd ~/multi-service/api
cat > api.json << 'EOF'
{
  "service": "API",
  "port": 8081,
  "status": "running"
}
EOF

# Database simulation (port 8082)
cd ~/multi-service/db
cat > data.txt << 'EOF'
Database Service
Port: 8082
Status: Active
EOF

# 2. Start all services
cd ~/multi-service/web
python3 -m http.server 8080 &
WEB_PID=$!

cd ~/multi-service/api
python3 -m http.server 8081 &
API_PID=$!

cd ~/multi-service/db
python3 -m http.server 8082 &
DB_PID=$!

# 3. Test all services
echo "Testing Web Service:"
curl http://localhost:8080

echo "Testing API Service:"
curl http://localhost:8081/api.json

echo "Testing DB Service:"
curl http://localhost:8082/data.txt

# 4. Check all running services
netstat -tlnp | grep -E '808[0-2]'

# 5. Clean up
kill $WEB_PID $API_PID $DB_PID
```

## Network Troubleshooting Tools

### Essential Commands
```bash
# Show network interfaces
ip link show

# Show routing table
ip route show

# Show listening ports
netstat -tlnp
ss -tlnp

# Show active connections
netstat -an
ss -an

# DNS lookup
nslookup google.com
dig google.com

# Trace network path
traceroute google.com
```

### Practical Troubleshooting
```bash
# Check if port is in use
lsof -i :8080

# Find process using a port
fuser 8080/tcp

# Kill process on specific port
fuser -k 8080/tcp
```

## Hands-On Exercise 3: Network Debugging

Let's practice debugging network issues:

```bash
# 1. Start a service with a common problem
python3 -m http.server 8080 &
SERVICE_PID=$!

# 2. Try to start another service on same port (will fail)
python3 -m http.server 8080 &
# This should show "Address already in use"

# 3. Debug the issue
echo "Checking what's using port 8080:"
lsof -i :8080

echo "All Python processes:"
ps aux | grep python

# 4. Fix by using different port
python3 -m http.server 8081 &
SERVICE2_PID=$!

# 5. Verify both services work
curl http://localhost:8080
curl http://localhost:8081

# 6. Clean up
kill $SERVICE_PID $SERVICE2_PID
```

## Docker Networking Preview

### Concepts You'll Use in Docker
```bash
# Port mapping concept (Docker does this automatically)
# Host port 3000 -> Container port 80
# curl http://localhost:3000 -> reaches container on port 80

# Network isolation concept
# Containers can talk to each other by name
# Container "web" can reach container "api" at http://api:8080
```

### Practice Network Mapping
```bash
# Simulate Docker port mapping
# Start service on high port (simulating container)
python3 -m http.server 9999 &
CONTAINER_PID=$!

# Use SSH tunnel to map to standard port (simulating Docker)
# This maps localhost:80 -> localhost:9999
sudo ssh -L 80:localhost:9999 localhost -N &
TUNNEL_PID=$!

# Test the mapping
curl http://localhost:80
# This reaches the service on port 9999

# Clean up
sudo kill $TUNNEL_PID
kill $CONTAINER_PID
```

## Security Basics

### Firewall Concepts
```bash
# Check firewall status (Ubuntu/Debian)
sudo ufw status

# Check firewall (CentOS/RHEL)
sudo firewall-cmd --list-all

# Check iptables rules
sudo iptables -L
```

### Safe Practices
```bash
# Only bind to localhost for development
python3 -m http.server 8080 --bind 127.0.0.1

# Check what's exposed to the network
netstat -tlnp | grep -v 127.0.0.1
```

## Real-World Scenarios

### Scenario 1: Web Application Stack
```bash
# Typical web app has:
# - Frontend (port 3000)
# - Backend API (port 8000)
# - Database (port 5432)

# Test connectivity between services
curl http://localhost:3000  # Frontend
curl http://localhost:8000/api/health  # Backend
nc -zv localhost 5432  # Database
```

### Scenario 2: Microservices
```bash
# Multiple services need to communicate:
# - User service (port 8001)
# - Product service (port 8002)
# - Order service (port 8003)
# - Gateway (port 8000)

# Gateway routes requests to appropriate service
curl http://localhost:8000/users -> routes to :8001
curl http://localhost:8000/products -> routes to :8002
curl http://localhost:8000/orders -> routes to :8003
```

## Practice Challenges

### Challenge 1: Service Discovery
Create a simple service registry:

```bash
# Create service registry file
cat > services.txt << 'EOF'
web:8080
api:8081
db:8082
cache:8083
EOF

# Script to check all services
cat > check_services.sh << 'EOF'
#!/bin/bash
while IFS=':' read -r service port; do
    if nc -zv localhost $port 2>/dev/null; then
        echo "✓ $service is running on port $port"
    else
        echo "✗ $service is NOT running on port $port"
    fi
done < services.txt
EOF

chmod +x check_services.sh
./check_services.sh
```

### Challenge 2: Load Balancing Simulation
```bash
# Start multiple instances of same service
python3 -m http.server 8080 &
PID1=$!
python3 -m http.server 8081 &
PID2=$!
python3 -m http.server 8082 &
PID3=$!

# Simple round-robin test
for i in {1..6}; do
    port=$((8080 + (i % 3)))
    echo "Request $i -> port $port"
    curl -s http://localhost:$port | head -1
done

# Clean up
kill $PID1 $PID2 $PID3
```

## Next Steps

You now understand networking fundamentals needed for Docker:

**Key concepts mastered:**
- Ports and protocols
- Service communication
- Network troubleshooting
- Multi-service architectures

**Docker networking will build on:**
- Port mapping (host:container)
- Container-to-container communication
- Network isolation
- Service discovery

Ready for **Module 2: Docker Fundamentals** where you'll see how Docker makes networking easier!
