# 🌐 Networking Practice Part 1: Basic Connectivity

## 🎯 Objectives
- Test network connectivity
- Understand port usage
- Practice with network tools
- Prepare for Docker networking

## Exercise 1: Network Discovery

### Step 1: Find Your Network Information
```bash
# Your IP address
ip addr show
# Windows: ipconfig

# Your network gateway
ip route show default
# Windows: route print

# DNS servers
cat /etc/resolv.conf
# Windows: nslookup
```

### Step 2: Test Basic Connectivity
```bash
# Test internet connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
ping -c 4 google.com

# Test specific ports
nc -zv google.com 80
nc -zv google.com 443
```

**Expected Results:**
- Ping should show response times
- Port tests should show "succeeded"
- DNS should resolve names to IPs

## Exercise 2: Port Investigation

### Step 1: Check What's Running
```bash
# Show listening ports
netstat -tuln
# or: ss -tuln

# Find specific port usage
lsof -i :22
lsof -i :80
```

### Step 2: Start Simple Services
```bash
# Start HTTP server on port 8000
python3 -m http.server 8000 &
SERVER_PID=$!

# Test it works
curl http://localhost:8000

# Check port is in use
netstat -tuln | grep 8000

# Clean up
kill $SERVER_PID
```

## Exercise 3: Multi-Port Services

### Create Test Environment
```bash
# Start services on different ports
python3 -m http.server 8001 &
PID1=$!
python3 -m http.server 8002 &
PID2=$!
python3 -m http.server 8003 &
PID3=$!

# Test all services
for port in 8001 8002 8003; do
    echo "Testing port $port:"
    curl -s http://localhost:$port | head -1
done

# Clean up
kill $PID1 $PID2 $PID3
```

## Practice Challenge 1: Port Scanner
Create a simple port scanner script:

```bash
#!/bin/bash
# Simple port scanner
HOST=${1:-localhost}
START_PORT=${2:-80}
END_PORT=${3:-90}

echo "Scanning $HOST ports $START_PORT-$END_PORT"

for port in $(seq $START_PORT $END_PORT); do
    if nc -zv -w1 $HOST $port 2>/dev/null; then
        echo "Port $port: OPEN"
    fi
done
```

**Usage:**
```bash
chmod +x port_scanner.sh
./port_scanner.sh localhost 8000 8010
```

## Next: Part 2 - Service Communication
