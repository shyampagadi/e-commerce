# 🌐 Networking Practice Part 2: Service Communication

## Exercise 4: Client-Server Communication

### Step 1: Create Simple Server
```bash
# Create echo server
cat > echo_server.py << 'EOF'
import socket
import threading

def handle_client(conn, addr):
    print(f"Connected by {addr}")
    while True:
        data = conn.recv(1024)
        if not data:
            break
        conn.sendall(data)
    conn.close()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(('localhost', 9999))
server.listen(5)
print("Server listening on port 9999")

while True:
    conn, addr = server.accept()
    thread = threading.Thread(target=handle_client, args=(conn, addr))
    thread.start()
EOF

# Start server
python3 echo_server.py &
SERVER_PID=$!
```

### Step 2: Test with Client
```bash
# Test with telnet
echo "Hello Server" | nc localhost 9999

# Test with multiple connections
for i in {1..3}; do
    echo "Message $i" | nc localhost 9999 &
done
wait

# Clean up
kill $SERVER_PID
```

## Exercise 5: HTTP API Communication

### Step 1: Create Simple API
```bash
cat > simple_api.py << 'EOF'
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class APIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {"status": "healthy", "port": 8080}
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

server = HTTPServer(('localhost', 8080), APIHandler)
print("API server running on port 8080")
server.serve_forever()
EOF

# Start API
python3 simple_api.py &
API_PID=$!
```

### Step 2: Test API Endpoints
```bash
# Test health endpoint
curl http://localhost:8080/health

# Test 404 endpoint
curl -i http://localhost:8080/notfound

# Clean up
kill $API_PID
```

## Exercise 6: Service Discovery Simulation

### Create Service Registry
```bash
cat > service_registry.sh << 'EOF'
#!/bin/bash
# Simple service registry

REGISTRY_FILE="/tmp/services.txt"

register_service() {
    echo "$1:$2" >> $REGISTRY_FILE
    echo "Registered $1 on port $2"
}

discover_service() {
    grep "^$1:" $REGISTRY_FILE | cut -d: -f2
}

list_services() {
    cat $REGISTRY_FILE 2>/dev/null || echo "No services registered"
}

case $1 in
    register) register_service $2 $3 ;;
    discover) discover_service $2 ;;
    list) list_services ;;
    *) echo "Usage: $0 {register|discover|list} [service] [port]" ;;
esac
EOF

chmod +x service_registry.sh
```

### Test Service Registry
```bash
# Register services
./service_registry.sh register web 8080
./service_registry.sh register api 8081
./service_registry.sh register db 5432

# Discover services
./service_registry.sh discover web
./service_registry.sh list
```

## Practice Challenge 2: Load Balancer Simulation
Create a simple load balancer:

```bash
#!/bin/bash
# Simple round-robin load balancer

SERVERS=("localhost:8001" "localhost:8002" "localhost:8003")
CURRENT=0

# Start backend servers
for port in 8001 8002 8003; do
    python3 -m http.server $port &
    echo $! >> /tmp/servers.pid
done

# Load balancer function
load_balance() {
    server=${SERVERS[$CURRENT]}
    echo "Routing to: $server"
    curl -s http://$server
    CURRENT=$(( (CURRENT + 1) % ${#SERVERS[@]} ))
}

# Test load balancing
for i in {1..6}; do
    echo "Request $i:"
    load_balance
    echo "---"
done

# Clean up
kill $(cat /tmp/servers.pid)
rm /tmp/servers.pid
```

## Next: Part 3 - Docker Network Preparation
