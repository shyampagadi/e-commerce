# 🐳 Docker Commands Deep Dive - Part 4: Docker Networking

## 🎯 Learning Objectives
- Master all Docker networking commands and options
- Understand Docker network types and their use cases
- Learn port mapping, DNS resolution, and container communication
- Troubleshoot network issues like an expert

---

## 🌐 docker network - Network Management

### Syntax
```bash
docker network COMMAND
```

### Available Commands
```bash
connect     Connect a container to a network
create      Create a network
disconnect  Disconnect a container from a network
inspect     Display detailed information on one or more networks
ls          List networks
prune       Remove all unused networks
rm          Remove one or more networks
```

---

## 📋 docker network ls - List Networks

### Syntax
```bash
docker network ls [OPTIONS]
```

### All Available Options
```bash
-f, --filter filter   Provide filter values (e.g. 'driver=bridge')
--format string      Pretty-print networks using a Go template
--no-trunc          Do not truncate the output
-q, --quiet         Only display network IDs
```

### Detailed Examples

**Basic Network Listing:**
```bash
# List all networks
docker network ls
```

**Expected Output:**
```
NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local
g7h8i9j0k1l2   host      host      local
m3n4o5p6q7r8   none      none      local
```

**Column Explanations:**
- **NETWORK ID**: Unique identifier (first 12 chars of full ID)
- **NAME**: Human-readable network name
- **DRIVER**: Network driver type (bridge, host, overlay, etc.)
- **SCOPE**: Network scope (local, global, swarm)

**Default Networks Explained:**

**Bridge Network (Default):**
- **Purpose**: Default network for containers
- **Isolation**: Containers can communicate with each other
- **External Access**: Requires port mapping for host access
- **IP Range**: Usually 172.17.0.0/16

**Host Network:**
- **Purpose**: Container shares host's network stack
- **Isolation**: No network isolation
- **Performance**: Better network performance
- **Port Conflicts**: Possible port conflicts with host

**None Network:**
- **Purpose**: Complete network isolation
- **Isolation**: No network connectivity
- **Use Case**: Security-sensitive applications
- **Access**: Only loopback interface available

**Filter Networks:**
```bash
# Show only bridge networks
docker network ls --filter driver=bridge
```

**Expected Output:**
```
NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local
s9t0u1v2w3x4   myapp     bridge    local
```

**Filter by Name:**
```bash
# Show networks with specific name pattern
docker network ls --filter name=my
```

**Custom Format:**
```bash
# Show only name and driver
docker network ls --format "table {{.Name}}\t{{.Driver}}"
```

**Expected Output:**
```
NAME      DRIVER
bridge    bridge
host      host
none      none
```

**Available Format Variables:**
- `.ID`: Network ID
- `.Name`: Network name
- `.Driver`: Network driver
- `.Scope`: Network scope
- `.IPv6`: IPv6 enabled
- `.Internal`: Internal network
- `.Labels`: Network labels

---

## 🔧 docker network create - Create Networks

### Syntax
```bash
docker network create [OPTIONS] NETWORK
```

### All Available Options
```bash
--attachable           Enable manual container attachment
--aux-address map      Auxiliary IPv4 or IPv6 addresses used by Network driver (default map[])
--config-from string   The network from which to copy the configuration
--config-only          Create a configuration only network
-d, --driver string    Driver to manage the Network (default "bridge")
--gateway strings      IPv4 or IPv6 Gateway for the master subnet
--ingress              Create swarm routing-mesh network
--internal             Restrict external access to the network
--ip-range strings     Allocate container ip from a sub-range
--ipam-driver string   IP Address Management Driver (default "default")
--ipam-opt map         Set IPAM driver specific options (default map[])
--ipv6                 Enable IPv6 networking
--label list           Set metadata on a network
-o, --opt map          Set driver specific options (default map[])
--scope string         Control the network's scope
--subnet strings       Subnet in CIDR format that represents a network segment
```

### Detailed Examples

**Create Basic Bridge Network:**
```bash
# Create simple bridge network
docker network create myapp-network
```

**Expected Output:**
```
s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2
```

**Verify Network Creation:**
```bash
# Check network was created
docker network ls | grep myapp
```

**Expected Output:**
```
s9t0u1v2w3x4   myapp-network   bridge    local
```

**Create Network with Custom Subnet:**
```bash
# Create network with specific IP range
docker network create \
  --driver bridge \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  custom-subnet-network
```

**Expected Output:**
```
a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0d1e2f3g4h5
```

**Verify Custom Subnet:**
```bash
# Inspect network configuration
docker network inspect custom-subnet-network --format='{{.IPAM.Config}}'
```

**Expected Output:**
```
[{192.168.100.0/24 192.168.100.1 map[]}]
```

**Create Network with IP Range:**
```bash
# Create network with limited IP allocation range
docker network create \
  --driver bridge \
  --subnet=10.0.0.0/16 \
  --ip-range=10.0.1.0/24 \
  --gateway=10.0.0.1 \
  limited-range-network
```

**Test IP Range:**
```bash
# Run containers and check assigned IPs
docker run -d --network limited-range-network --name test1 nginx:alpine
docker run -d --network limited-range-network --name test2 nginx:alpine

# Check assigned IPs
docker inspect test1 --format='{{.NetworkSettings.Networks.limited_range_network.IPAddress}}'
docker inspect test2 --format='{{.NetworkSettings.Networks.limited_range_network.IPAddress}}'
```

**Expected Output:**
```
10.0.1.2
10.0.1.3
```

**Create Internal Network (No External Access):**
```bash
# Create isolated internal network
docker network create \
  --internal \
  --subnet=172.20.0.0/16 \
  internal-network
```

**Test Internal Network:**
```bash
# Run container on internal network
docker run -it --network internal-network --name internal-test alpine sh

# Inside container - try to reach external internet
ping -c 3 8.8.8.8
# This should fail - no external connectivity

# Exit container
exit
```

**Create Network with Labels:**
```bash
# Create network with metadata labels
docker network create \
  --label environment=production \
  --label team=backend \
  --label version=1.0 \
  production-network
```

**Verify Labels:**
```bash
# Check network labels
docker network inspect production-network --format='{{.Labels}}'
```

**Expected Output:**
```
map[environment:production team:backend version:1.0]
```

**Create IPv6 Enabled Network:**
```bash
# Create network with IPv6 support
docker network create \
  --ipv6 \
  --subnet=2001:db8::/64 \
  ipv6-network
```

---

## 🔌 docker network connect/disconnect - Container Network Management

### Connect Syntax
```bash
docker network connect [OPTIONS] NETWORK CONTAINER
```

### Connect Options
```bash
--alias strings        Add network-scoped alias for the container
--driver-opt strings   driver options for the network
--ip string           IPv4 address (e.g., 172.30.100.104)
--ip6 string          IPv6 address (e.g., 2001:db8::33)
--link list           Add link to another container
--link-local-ip strings  Add a link-local address for the container
```

### Disconnect Syntax
```bash
docker network disconnect [OPTIONS] NETWORK CONTAINER
```

### Disconnect Options
```bash
-f, --force   Force the container to disconnect from a network
```

### Detailed Examples

**Connect Container to Additional Network:**
```bash
# Create container on default bridge
docker run -d --name web-server nginx:alpine

# Create custom network
docker network create backend-network

# Connect container to additional network
docker network connect backend-network web-server

# Verify container is on both networks
docker inspect web-server --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}: {{$v.IPAddress}} {{end}}'
```

**Expected Output:**
```
backend-network: 172.18.0.2 bridge: 172.17.0.2
```

**Connect with Custom IP:**
```bash
# Connect container with specific IP address
docker network connect --ip 192.168.100.50 custom-subnet-network web-server

# Verify custom IP assignment
docker inspect web-server --format='{{.NetworkSettings.Networks.custom_subnet_network.IPAddress}}'
```

**Expected Output:**
```
192.168.100.50
```

**Connect with Network Alias:**
```bash
# Connect with custom hostname for this network
docker network connect --alias api-server backend-network web-server

# Test alias resolution from another container
docker run --rm --network backend-network alpine nslookup api-server
```

**Expected Output:**
```
Server:    127.0.0.11
Address 1: 127.0.0.11

Name:      api-server
Address 1: 172.18.0.2 web-server.backend-network
```

**Disconnect Container from Network:**
```bash
# Disconnect container from specific network
docker network disconnect backend-network web-server

# Verify disconnection
docker inspect web-server --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}: {{$v.IPAddress}} {{end}}'
```

**Expected Output:**
```
bridge: 172.17.0.2 custom-subnet-network: 192.168.100.50
```

**Force Disconnect:**
```bash
# Force disconnect even if container is running critical services
docker network disconnect --force backend-network web-server
```

---

## 🔍 docker network inspect - Network Details

### Syntax
```bash
docker network inspect [OPTIONS] NETWORK [NETWORK...]
```

### All Available Options
```bash
-f, --format string   Format the output using the given Go template
-v, --verbose        Verbose output for diagnostics
```

### Detailed Examples

**Basic Network Inspection:**
```bash
# Inspect default bridge network
docker network inspect bridge
```

**Expected Output (Abbreviated):**
```json
[
    {
        "Name": "bridge",
        "Id": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2",
        "Created": "2024-01-15T10:30:45.123456789Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3": {
                "Name": "web-server",
                "EndpointID": "c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

**Key Information Explained:**
- **IPAM**: IP Address Management configuration
- **Containers**: Currently connected containers
- **Options**: Driver-specific configuration
- **Internal**: Whether network has external connectivity
- **Attachable**: Whether containers can be manually attached

**Extract Specific Information:**
```bash
# Get network subnet
docker network inspect bridge --format='{{range .IPAM.Config}}{{.Subnet}}{{end}}'
```

**Expected Output:**
```
172.17.0.0/16
```

**Get Connected Containers:**
```bash
# List containers on network
docker network inspect bridge --format='{{range $k, $v := .Containers}}{{$v.Name}}: {{$v.IPv4Address}} {{end}}'
```

**Expected Output:**
```
web-server: 172.17.0.2/16 
```

**Get Network Gateway:**
```bash
# Get gateway IP
docker network inspect bridge --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}'
```

**Expected Output:**
```
172.17.0.1
```

**Inspect Multiple Networks:**
```bash
# Inspect multiple networks at once
docker network inspect bridge host none --format='{{.Name}}: {{.Driver}}'
```

**Expected Output:**
```
bridge: bridge
host: host
none: null
```

---

## 🗑️ docker network rm/prune - Network Cleanup

### Remove Syntax
```bash
docker network rm NETWORK [NETWORK...]
```

### Prune Syntax
```bash
docker network prune [OPTIONS]
```

### Prune Options
```bash
--filter filter   Provide filter values (e.g. 'until=<timestamp>')
-f, --force      Do not prompt for confirmation
```

### Detailed Examples

**Remove Single Network:**
```bash
# Remove unused network
docker network rm myapp-network
```

**Expected Output:**
```
myapp-network
```

**Remove Multiple Networks:**
```bash
# Remove multiple networks
docker network rm backend-network production-network internal-network
```

**Expected Output:**
```
backend-network
production-network
internal-network
```

**Error When Network In Use:**
```bash
# Try to remove network with connected containers
docker network rm bridge
```

**Expected Output:**
```
Error response from daemon: network bridge id a1b2c3d4e5f6 has active endpoints
```

**Remove All Unused Networks:**
```bash
# Remove all networks not used by containers
docker network prune
```

**Expected Output:**
```
WARNING! This will remove all custom networks not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Networks:
custom-subnet-network
limited-range-network
ipv6-network

Total reclaimed space: 0B
```

**Force Prune Without Confirmation:**
```bash
# Skip confirmation prompt
docker network prune -f
```

**Prune with Filters:**
```bash
# Remove networks created more than 24 hours ago
docker network prune --filter "until=24h"
```

---

## 🌐 Container Communication Examples

### Same Network Communication

**Setup Multi-Container Application:**
```bash
# Create application network
docker network create app-network

# Run database container
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  postgres:13

# Run web application container
docker run -d \
  --name web-app \
  --network app-network \
  -p 8080:80 \
  nginx:alpine

# Run API container
docker run -d \
  --name api-server \
  --network app-network \
  -e DATABASE_URL=postgresql://postgres:secret@postgres-db:5432/myapp \
  nginx:alpine
```

**Test Container Communication:**
```bash
# Test DNS resolution between containers
docker exec web-app nslookup postgres-db
```

**Expected Output:**
```
Server:    127.0.0.11
Address 1: 127.0.0.11

Name:      postgres-db
Address 1: 172.18.0.2 postgres-db.app-network
```

**Test Network Connectivity:**
```bash
# Test connectivity between containers
docker exec web-app ping -c 3 api-server
```

**Expected Output:**
```
PING api-server (172.18.0.4): 56 data bytes
64 bytes from 172.18.0.4: seq=0 ttl=64 time=0.123 ms
64 bytes from 172.18.0.4: seq=1 ttl=64 time=0.089 ms
64 bytes from 172.18.0.4: seq=2 ttl=64 time=0.095 ms

--- api-server ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
round-trip min/avg/max = 0.089/0.102/0.123 ms
```

### Cross-Network Communication

**Setup Multiple Networks:**
```bash
# Create frontend network
docker network create frontend-network

# Create backend network  
docker network create backend-network

# Run frontend container
docker run -d \
  --name frontend \
  --network frontend-network \
  -p 3000:80 \
  nginx:alpine

# Run API gateway on both networks
docker run -d \
  --name api-gateway \
  --network frontend-network \
  nginx:alpine

# Connect API gateway to backend network
docker network connect backend-network api-gateway

# Run backend service
docker run -d \
  --name backend-service \
  --network backend-network \
  nginx:alpine
```

**Test Cross-Network Communication:**
```bash
# Frontend can reach API gateway
docker exec frontend ping -c 2 api-gateway

# API gateway can reach both networks
docker exec api-gateway ping -c 2 frontend
docker exec api-gateway ping -c 2 backend-service

# Frontend cannot directly reach backend (different networks)
docker exec frontend ping -c 2 backend-service
# This should fail
```

### Port Mapping Deep Dive

**Understanding Port Mapping:**
```bash
# Run container with port mapping
docker run -d \
  --name port-test \
  -p 8080:80 \
  -p 8443:443 \
  -p 127.0.0.1:9000:9000 \
  nginx:alpine

# Check port mappings
docker port port-test
```

**Expected Output:**
```
80/tcp -> 0.0.0.0:8080
443/tcp -> 0.0.0.0:8443
9000/tcp -> 127.0.0.1:9000
```

**Port Mapping Explanations:**
- `8080:80`: Host port 8080 → Container port 80 (all interfaces)
- `8443:443`: Host port 8443 → Container port 443 (all interfaces)  
- `127.0.0.1:9000:9000`: Host port 9000 → Container port 9000 (localhost only)

**Test Port Access:**
```bash
# Test external access
curl http://localhost:8080
curl https://localhost:8443 -k

# Test localhost-only access
curl http://localhost:9000
curl http://$(hostname -I | awk '{print $1}'):9000
# Second command should fail - not accessible from external IPs
```

**Dynamic Port Mapping:**
```bash
# Let Docker assign random ports
docker run -d --name random-ports -P nginx:alpine

# Check assigned ports
docker port random-ports
```

**Expected Output:**
```
80/tcp -> 0.0.0.0:32768
```

---

## 🔧 Network Troubleshooting

### Common Network Issues

**Issue 1: Container Cannot Reach External Internet**

**Diagnosis:**
```bash
# Test from inside container
docker exec container-name ping -c 3 8.8.8.8
docker exec container-name nslookup google.com

# Check network configuration
docker network inspect bridge --format='{{.Options}}'
```

**Solutions:**
```bash
# Check Docker daemon DNS settings
docker info | grep -A 5 "DNS"

# Restart Docker daemon if needed
sudo systemctl restart docker

# Use custom DNS
docker run --dns 8.8.8.8 --dns 8.8.4.4 nginx:alpine
```

**Issue 2: Containers Cannot Communicate**

**Diagnosis:**
```bash
# Check if containers are on same network
docker inspect container1 --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
docker inspect container2 --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'

# Test connectivity
docker exec container1 ping container2
```

**Solutions:**
```bash
# Connect containers to same network
docker network create shared-network
docker network connect shared-network container1
docker network connect shared-network container2
```

**Issue 3: Port Mapping Not Working**

**Diagnosis:**
```bash
# Check port mapping
docker port container-name

# Check if port is listening inside container
docker exec container-name netstat -tlnp

# Check host firewall
sudo iptables -L -n | grep 8080
```

**Solutions:**
```bash
# Ensure service binds to 0.0.0.0, not 127.0.0.1
# Check firewall rules
# Verify correct port mapping syntax
```

### Network Performance Testing

**Bandwidth Testing Between Containers:**
```bash
# Install iperf3 in containers
docker exec -it container1 apk add iperf3
docker exec -it container2 apk add iperf3

# Start server on container1
docker exec -d container1 iperf3 -s

# Test from container2
docker exec container2 iperf3 -c container1 -t 10
```

**Latency Testing:**
```bash
# Test latency between containers
docker exec container1 ping -c 100 container2 | tail -1
```

---

## 🚀 Next Steps

You now have complete mastery of Docker networking:

- ✅ **docker network ls**: List and filter networks with all options
- ✅ **docker network create**: Create custom networks with advanced configurations
- ✅ **docker network connect/disconnect**: Manage container network connections
- ✅ **docker network inspect**: Analyze network configurations in detail
- ✅ **docker network rm/prune**: Clean up unused networks
- ✅ **Container Communication**: Multi-container networking patterns
- ✅ **Port Mapping**: Complete port mapping and access control
- ✅ **Network Troubleshooting**: Diagnose and fix network issues

**Ready for Module 2, Part 5: Docker Volumes and Data Management** where you'll master persistent data, volume mounting, and data sharing between containers!
