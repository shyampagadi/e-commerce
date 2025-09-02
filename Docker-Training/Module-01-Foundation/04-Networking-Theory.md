# 🌐 Networking Fundamentals: Complete Theory for Docker

## 🎯 Learning Objectives
By the end of this section, you will understand:
- How computer networks work at a fundamental level
- The TCP/IP protocol stack and its layers
- Ports, protocols, and network communication
- How Docker networking builds on these concepts
- Network troubleshooting and debugging techniques

---

## 📚 What is Computer Networking?

### Definition
**Computer networking** is the practice of connecting computers and other devices to share resources, communicate, and exchange data. Think of it like a postal system for digital information.

### Real-World Analogy: The Postal System
```
Sending a Letter (Traditional Mail):
1. Write letter with recipient's address
2. Put in envelope with return address  
3. Drop in mailbox
4. Postal service routes through sorting facilities
5. Local post office delivers to recipient
6. Recipient reads letter and can reply

Sending Data (Computer Network):
1. Application creates data with destination address
2. Network stack adds addressing information
3. Data sent to network interface
4. Routers forward data through internet
5. Destination network receives data
6. Application processes data and can respond
```

### Why Networking Matters for Docker
Docker containers need to:
- Communicate with each other
- Access external services (databases, APIs)
- Serve web traffic to users
- Connect to storage systems
- Integrate with monitoring tools

Understanding networking helps you:
- Configure container communication
- Troubleshoot connectivity issues
- Secure container networks
- Optimize performance
- Design scalable architectures

---

## 🏗️ The Network Stack: Understanding the Layers

### The OSI Model (Conceptual Framework)
```
Layer 7: Application  ← Your programs (HTTP, FTP, SMTP)
Layer 6: Presentation ← Data formatting (encryption, compression)
Layer 5: Session      ← Connection management
Layer 4: Transport    ← Reliable delivery (TCP, UDP)
Layer 3: Network      ← Routing (IP addresses)
Layer 2: Data Link    ← Local network (Ethernet, WiFi)
Layer 1: Physical     ← Hardware (cables, radio waves)
```

### The TCP/IP Model (Practical Implementation)
```
Application Layer    ← HTTP, HTTPS, FTP, SSH, DNS
Transport Layer      ← TCP, UDP
Internet Layer       ← IP (IPv4, IPv6)
Network Access Layer ← Ethernet, WiFi, etc.
```

### Layer-by-Layer Explanation

#### Layer 1: Physical Layer
**What it does:** Transmits raw bits over physical medium

**Examples:**
- Ethernet cables (copper wires)
- Fiber optic cables (light pulses)
- WiFi radio waves
- Bluetooth signals

**Real-world analogy:** The roads and highways that mail trucks use

**Docker relevance:** Docker containers share the host's physical network interface

#### Layer 2: Data Link Layer (Ethernet)
**What it does:** Handles communication between devices on the same local network

**Key concepts:**
- **MAC addresses**: Hardware addresses (like 00:1B:44:11:3A:B7)
- **Frames**: Data packets at this layer
- **Switches**: Connect devices on local network

**Real-world analogy:** Local mail sorting facility that knows all addresses in the neighborhood

**Docker relevance:** Docker creates virtual network interfaces with their own MAC addresses

#### Layer 3: Network Layer (IP)
**What it does:** Routes data between different networks across the internet

**Key concepts:**
- **IP addresses**: Network addresses (like 192.168.1.100)
- **Routing**: Finding path from source to destination
- **Subnets**: Groups of related IP addresses

**Real-world analogy:** The postal service's routing system that gets mail from city to city

**Docker relevance:** Each container gets its own IP address; Docker manages routing between containers

#### Layer 4: Transport Layer (TCP/UDP)
**What it does:** Ensures reliable delivery and manages connections

**TCP (Transmission Control Protocol):**
- Reliable delivery (guarantees data arrives)
- Connection-oriented (establishes connection first)
- Error checking and retransmission
- Used for: Web browsing, email, file transfer

**UDP (User Datagram Protocol):**
- Fast but unreliable (no delivery guarantee)
- Connectionless (just sends data)
- No error checking
- Used for: Video streaming, online gaming, DNS

**Real-world analogy:** 
- TCP = Certified mail (guaranteed delivery, signature required)
- UDP = Regular mail (fast but no guarantee)

**Docker relevance:** Container services use specific ports; Docker maps host ports to container ports

#### Layer 5-7: Application Layers
**What they do:** Handle application-specific protocols and data formatting

**Common protocols:**
- **HTTP/HTTPS**: Web traffic (ports 80/443)
- **SSH**: Secure remote access (port 22)
- **FTP**: File transfer (port 21)
- **SMTP**: Email sending (port 25)
- **DNS**: Domain name resolution (port 53)

**Docker relevance:** Your containerized applications use these protocols to communicate

---

## 🔢 IP Addresses and Subnets: The Network Addressing System

### IPv4 Addresses
**Format:** Four numbers separated by dots (e.g., 192.168.1.100)
**Range:** Each number is 0-255 (8 bits each, 32 bits total)

#### Address Classes and Private Ranges
```
Class A: 10.0.0.0 to 10.255.255.255        (16.7 million addresses)
Class B: 172.16.0.0 to 172.31.255.255      (1 million addresses)  
Class C: 192.168.0.0 to 192.168.255.255    (65,536 addresses)
```

**Why private ranges matter:**
- Used for internal networks (home, office, Docker)
- Not routable on the internet
- Allow reuse of same addresses in different networks
- Provide security through network isolation

#### Special IP Addresses
```
127.0.0.1     ← Localhost (your own computer)
0.0.0.0       ← All interfaces (listen on all network cards)
255.255.255.255 ← Broadcast (send to everyone on network)
```

### Subnet Masks and CIDR Notation
**Purpose:** Define which part of IP address is network vs host

#### Subnet Mask Examples
```
255.255.255.0   ← First 3 numbers are network, last is host
255.255.0.0     ← First 2 numbers are network, last 2 are host
255.0.0.0       ← First number is network, last 3 are host
```

#### CIDR Notation (Classless Inter-Domain Routing)
```
192.168.1.0/24  ← /24 means first 24 bits are network
                  ← Allows 256 addresses (192.168.1.0 to 192.168.1.255)
                  
192.168.0.0/16  ← /16 means first 16 bits are network  
                  ← Allows 65,536 addresses (192.168.0.0 to 192.168.255.255)
```

#### Practical Examples
```
Network: 192.168.1.0/24
├── Network address: 192.168.1.0 (not usable for devices)
├── Usable addresses: 192.168.1.1 to 192.168.1.254
├── Broadcast address: 192.168.1.255 (not usable for devices)
└── Total usable: 254 addresses
```

**Docker networking uses these concepts:**
- Default Docker network: 172.17.0.0/16
- Custom networks: You can specify any private range
- Container IPs: Automatically assigned from network range

---

## 🚪 Ports and Protocols: The Communication Endpoints

### What are Ports?
**Ports** are numbered endpoints that allow multiple services to run on the same computer. Think of them like apartment numbers in a building.

#### Port Analogy
```
IP Address = Building Address (123 Main Street)
Port = Apartment Number (#101, #102, #103)

192.168.1.100:80   ← Web server apartment
192.168.1.100:22   ← SSH server apartment  
192.168.1.100:3306 ← Database server apartment
```

### Port Ranges and Categories
```
0-1023:     System/Privileged Ports (require admin rights)
1024-49151: Registered Ports (assigned to specific services)
49152-65535: Dynamic/Private Ports (temporary connections)
```

### Common Port Numbers (Essential for Docker)
```
Port 20/21:  FTP (File Transfer Protocol)
Port 22:     SSH (Secure Shell)
Port 23:     Telnet (insecure remote access)
Port 25:     SMTP (Email sending)
Port 53:     DNS (Domain Name System)
Port 80:     HTTP (Web traffic)
Port 110:    POP3 (Email retrieval)
Port 143:    IMAP (Email access)
Port 443:    HTTPS (Secure web traffic)
Port 993:    IMAPS (Secure IMAP)
Port 995:    POP3S (Secure POP3)

Database Ports:
Port 3306:   MySQL/MariaDB
Port 5432:   PostgreSQL
Port 1521:   Oracle
Port 1433:   Microsoft SQL Server
Port 27017:  MongoDB
Port 6379:   Redis

Application Ports:
Port 3000:   Node.js development server
Port 8000:   Django development server
Port 8080:   Alternative HTTP (Tomcat, Jenkins)
Port 9000:   Various applications
```

### Port States
```
LISTENING:    Port is open and waiting for connections
ESTABLISHED:  Active connection exists
CLOSED:       Port is not accepting connections
TIME_WAIT:    Connection recently closed, waiting for cleanup
```

---

## 🔄 How Network Communication Works

### The Complete Journey of a Web Request

#### Step 1: DNS Resolution
```
User types: https://www.example.com
Browser asks: "What's the IP address for www.example.com?"
DNS server responds: "It's 93.184.216.34"
```

**Detailed DNS Process:**
1. Check browser cache
2. Check operating system cache
3. Query local DNS server (usually your ISP)
4. If not found, query root DNS servers
5. Query top-level domain servers (.com)
6. Query authoritative servers for example.com
7. Return IP address to browser

#### Step 2: TCP Connection Establishment (3-Way Handshake)
```
Browser → Server: SYN (Synchronize) - "Can we talk?"
Server → Browser: SYN-ACK (Synchronize-Acknowledge) - "Yes, let's talk"
Browser → Server: ACK (Acknowledge) - "Great, let's start"
```

**What happens:**
- Browser chooses random port (e.g., 54321)
- Connects to server port 443 (HTTPS)
- Connection established: 192.168.1.100:54321 ↔ 93.184.216.34:443

#### Step 3: HTTP Request
```
GET / HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
Accept: text/html,application/xhtml+xml
Connection: keep-alive
```

#### Step 4: Server Processing
```
Web server receives request
├── Parses HTTP headers
├── Determines requested resource
├── Checks permissions
├── Generates response
└── Sends back to client
```

#### Step 5: HTTP Response
```
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1234
Server: nginx/1.18.0

<!DOCTYPE html>
<html>
<head><title>Example</title></head>
<body><h1>Hello World!</h1></body>
</html>
```

#### Step 6: Connection Cleanup
```
Browser → Server: FIN (Finish) - "I'm done"
Server → Browser: ACK - "OK"
Server → Browser: FIN - "I'm done too"
Browser → Server: ACK - "OK, goodbye"
```

### Network Packet Structure
```
┌─────────────────────────────────────────┐
│ Ethernet Header (Layer 2)              │
├─────────────────────────────────────────┤
│ IP Header (Layer 3)                    │
├─────────────────────────────────────────┤
│ TCP Header (Layer 4)                   │
├─────────────────────────────────────────┤
│ HTTP Header (Layer 7)                  │
├─────────────────────────────────────────┤
│ Actual Data (HTML, JSON, etc.)         │
└─────────────────────────────────────────┘
```

**Each layer adds its own header:**
- **Ethernet**: Source/destination MAC addresses
- **IP**: Source/destination IP addresses
- **TCP**: Source/destination ports, sequence numbers
- **HTTP**: Request method, headers, content type

---

## 🐳 Docker Networking Concepts

### How Docker Networking Works

#### Traditional Networking
```
Physical Server
├── Network Interface (eth0: 192.168.1.100)
├── Application 1 (port 80)
├── Application 2 (port 8080)
└── Application 3 (port 3000)
```

**Problems:**
- Port conflicts (only one app per port)
- No isolation between applications
- Difficult to manage dependencies
- Hard to scale individual services

#### Docker Networking
```
Docker Host (192.168.1.100)
├── Docker Network Bridge (docker0: 172.17.0.1)
├── Container 1 (172.17.0.2:80) → Host port 8080
├── Container 2 (172.17.0.3:80) → Host port 8081  
└── Container 3 (172.17.0.4:3000) → Host port 3000
```

**Benefits:**
- Each container has its own IP address
- No port conflicts within containers
- Network isolation between containers
- Easy port mapping to host
- Scalable and manageable

### Docker Network Types

#### 1. Bridge Network (Default)
```
┌─────────────────────────────────────────┐
│ Docker Host                             │
│ ┌─────────────────────────────────────┐ │
│ │ Bridge Network (docker0)            │ │
│ │ ├── Container A (172.17.0.2)       │ │
│ │ ├── Container B (172.17.0.3)       │ │
│ │ └── Container C (172.17.0.4)       │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Containers can communicate with each other
- Isolated from host network by default
- Port mapping required for external access
- Default network for containers

#### 2. Host Network
```
┌─────────────────────────────────────────┐
│ Docker Host Network                     │
│ ├── Host Process (port 80)             │
│ ├── Container A (port 8080)            │
│ └── Container B (port 3000)            │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Container shares host's network interface
- No network isolation
- Better performance (no network translation)
- Port conflicts possible

#### 3. None Network
```
┌─────────────────────────────────────────┐
│ Container (No Network)                  │
│ ├── Application running                 │
│ └── No network connectivity            │
└─────────────────────────────────────────┘
```

**Characteristics:**
- Complete network isolation
- No network interface
- Used for security or batch processing
- Manual network configuration required

#### 4. Custom Networks
```
┌─────────────────────────────────────────┐
│ Custom Network (myapp-network)          │
│ ├── Web Container (10.0.1.2)           │
│ ├── API Container (10.0.1.3)           │
│ └── DB Container (10.0.1.4)            │
└─────────────────────────────────────────┘
```

**Characteristics:**
- User-defined IP ranges
- Built-in DNS resolution
- Better isolation and security
- Recommended for production

### Port Mapping in Docker
```bash
# Map host port 8080 to container port 80
docker run -p 8080:80 nginx

# Map host port 3000 to container port 3000
docker run -p 3000:3000 node-app

# Map all container ports to random host ports
docker run -P my-app
```

**Port Mapping Flow:**
```
Internet Request → Host:8080 → Docker Bridge → Container:80
```

---

## 🔧 Network Troubleshooting and Tools

### Essential Network Commands

#### Connectivity Testing
```bash
# Test if host is reachable
ping google.com
ping 8.8.8.8

# Test specific port connectivity
telnet google.com 80
nc -zv google.com 80

# Trace route to destination
traceroute google.com
# Windows: tracert google.com
```

#### Network Interface Information
```bash
# Show network interfaces (Linux/Mac)
ip addr show
ifconfig

# Show network interfaces (Windows)
ipconfig
ipconfig /all

# Show routing table
ip route show
route -n
# Windows: route print
```

#### Port and Connection Information
```bash
# Show listening ports
netstat -tuln
ss -tuln

# Show all connections
netstat -an
ss -an

# Show processes using ports
lsof -i :80
netstat -tulnp | grep :80
```

#### DNS Tools
```bash
# DNS lookup
nslookup google.com
dig google.com

# Reverse DNS lookup
nslookup 8.8.8.8
dig -x 8.8.8.8
```

### Docker-Specific Network Commands
```bash
# List Docker networks
docker network ls

# Inspect network details
docker network inspect bridge

# Create custom network
docker network create mynetwork

# Connect container to network
docker network connect mynetwork mycontainer

# Show container network settings
docker inspect mycontainer | grep -A 20 NetworkSettings
```

### Common Network Issues and Solutions

#### Issue 1: Cannot Connect to Container Service
**Symptoms:**
- Browser shows "connection refused"
- `curl` fails to connect
- Service works inside container but not from host

**Debugging Steps:**
```bash
# 1. Check if container is running
docker ps

# 2. Check port mapping
docker port mycontainer

# 3. Test from inside container
docker exec -it mycontainer curl localhost:80

# 4. Check if service is listening
docker exec -it mycontainer netstat -tuln

# 5. Test host connectivity
curl localhost:8080
```

**Common Solutions:**
- Verify correct port mapping (-p host:container)
- Check if service binds to 0.0.0.0, not 127.0.0.1
- Ensure firewall allows connections
- Verify service is actually running

#### Issue 2: Containers Cannot Communicate
**Symptoms:**
- Container A cannot reach Container B
- DNS resolution fails between containers
- Network timeouts

**Debugging Steps:**
```bash
# 1. Check if containers are on same network
docker network inspect bridge

# 2. Test connectivity by IP
docker exec -it containerA ping containerB_IP

# 3. Test DNS resolution
docker exec -it containerA nslookup containerB

# 4. Check network configuration
docker inspect containerA | grep -A 10 Networks
```

**Common Solutions:**
- Use custom networks instead of default bridge
- Ensure containers are on same network
- Use container names for DNS resolution
- Check network policies and firewalls

#### Issue 3: Performance Issues
**Symptoms:**
- Slow network responses
- High latency
- Connection timeouts

**Debugging Steps:**
```bash
# 1. Test network performance
docker exec -it container ping -c 10 target

# 2. Check network statistics
docker exec -it container cat /proc/net/dev

# 3. Monitor network traffic
docker exec -it container iftop
```

**Common Solutions:**
- Use host networking for performance-critical apps
- Optimize network drivers
- Check for network congestion
- Consider container placement

---

## 🎯 Real-World Networking Scenarios

### Scenario 1: Web Application Stack
```
┌─────────────────────────────────────────┐
│ Load Balancer (nginx)                   │
│ Port: 80/443                           │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
┌───▼────┐         ┌───▼────┐
│Web App │         │Web App │
│Port:3000│         │Port:3000│
└───┬────┘         └───┬────┘
    │                   │
    └─────────┬─────────┘
              │
    ┌─────────▼─────────┐
    │ Database          │
    │ Port: 5432        │
    └───────────────────┘
```

**Network Requirements:**
- Load balancer accessible from internet (ports 80/443)
- Web apps communicate with database (port 5432)
- Web apps not directly accessible from internet
- Database only accessible from web apps

**Docker Implementation:**
```bash
# Create custom network
docker network create webapp-network

# Database (internal only)
docker run -d --name database \
  --network webapp-network \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# Web applications
docker run -d --name webapp1 \
  --network webapp-network \
  -e DATABASE_URL=postgresql://postgres:secret@database:5432/myapp \
  my-webapp:latest

docker run -d --name webapp2 \
  --network webapp-network \
  -e DATABASE_URL=postgresql://postgres:secret@database:5432/myapp \
  my-webapp:latest

# Load balancer (public access)
docker run -d --name loadbalancer \
  --network webapp-network \
  -p 80:80 -p 443:443 \
  nginx:alpine
```

### Scenario 2: Microservices Architecture
```
┌─────────────────────────────────────────┐
│ API Gateway                             │
│ Port: 8080                             │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
┌───▼────┐ ┌─▼────┐ ┌──▼─────┐
│User    │ │Product│ │Order   │
│Service │ │Service│ │Service │
│:3001   │ │:3002  │ │:3003   │
└────────┘ └───────┘ └────────┘
```

**Network Requirements:**
- Services communicate via service names
- API Gateway routes requests to appropriate services
- Each service has its own database
- Internal communication only (except API Gateway)

**Docker Implementation:**
```bash
# Create microservices network
docker network create microservices

# User service
docker run -d --name user-service \
  --network microservices \
  -e PORT=3001 \
  user-service:latest

# Product service  
docker run -d --name product-service \
  --network microservices \
  -e PORT=3002 \
  product-service:latest

# Order service
docker run -d --name order-service \
  --network microservices \
  -e PORT=3003 \
  -e USER_SERVICE_URL=http://user-service:3001 \
  -e PRODUCT_SERVICE_URL=http://product-service:3002 \
  order-service:latest

# API Gateway
docker run -d --name api-gateway \
  --network microservices \
  -p 8080:8080 \
  -e USER_SERVICE=user-service:3001 \
  -e PRODUCT_SERVICE=product-service:3002 \
  -e ORDER_SERVICE=order-service:3003 \
  api-gateway:latest
```

---

## 🧠 Key Concepts Summary

### Essential Networking Concepts for Docker
1. **IP Addresses**: Unique identifiers for network devices
2. **Ports**: Endpoints for network services
3. **Protocols**: Rules for network communication (TCP/UDP)
4. **DNS**: System for resolving names to IP addresses
5. **Routing**: Path determination for network traffic

### Docker Networking Principles
1. **Isolation**: Containers have separate network namespaces
2. **Connectivity**: Containers can communicate via networks
3. **Port Mapping**: Host ports map to container ports
4. **Service Discovery**: Containers find each other by name
5. **Security**: Network policies control traffic flow

### Troubleshooting Methodology
1. **Identify**: What exactly is not working?
2. **Isolate**: Is it network, DNS, or application issue?
3. **Test**: Use tools to verify connectivity
4. **Analyze**: Check logs and configurations
5. **Fix**: Apply appropriate solution
6. **Verify**: Confirm issue is resolved

---

## 🚀 Next Steps

You now have a solid foundation in networking concepts essential for Docker:

- ✅ **Network fundamentals**: How data flows across networks
- ✅ **IP addressing**: Understanding network addressing and subnets
- ✅ **Ports and protocols**: How services communicate
- ✅ **Docker networking**: How containers connect and communicate
- ✅ **Troubleshooting**: Tools and techniques for network issues

**Ready for Module 1, Part 5: Networking Practice** where you'll apply these concepts hands-on!
