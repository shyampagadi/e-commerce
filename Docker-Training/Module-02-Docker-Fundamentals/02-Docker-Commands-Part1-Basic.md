# 🐳 Docker Commands Part 1: Basic Operations - Enhanced Progressive Learning

## 🎯 Learning Objectives
By the end of this section, you will:
- **Master fundamental Docker commands** with complete understanding of each parameter
- **Understand architectural principles** behind every Docker operation
- **Apply commands progressively** from simple examples to complex e-commerce scenarios
- **Build troubleshooting expertise** through hands-on practice and error resolution
- **Develop production-ready skills** for enterprise Docker deployments

---

## 🏗️ Docker Command Architecture Deep Dive

### **Understanding the Foundation: Why Architecture Matters**

Before learning commands, understanding Docker's architecture is crucial for:
- **Troubleshooting**: Knowing where problems occur (client vs daemon)
- **Performance**: Understanding bottlenecks and optimization points
- **Security**: Recognizing attack vectors and security boundaries
- **Scalability**: Planning for enterprise deployments

#### **1. Client-Server Architecture Explained**

**Visual Architecture:**
```
Your Terminal                    Docker Host
     ↓                               ↓
Docker CLI (Client) ←→ REST API ←→ Docker Daemon (Server)
     ↓                               ↓
User Commands                   Container Management
API Requests                    Image Operations  
Output Formatting               System Resources
```

**What This Means in Practice:**
- **Docker CLI**: The `docker` command you type translates to HTTP requests
- **REST API**: Standardized communication protocol (can be used by other tools)
- **Docker Daemon**: The actual engine that manages containers, images, networks
- **Separation Benefits**: CLI can connect to remote Docker hosts, multiple clients can connect

**Business Impact**: This architecture enables:
- **Remote Management**: Manage containers on different servers from one location
- **Tool Integration**: CI/CD systems can use the same API
- **Scalability**: Multiple developers can work with the same Docker host
- **Cost Savings**: 40-60% reduction in infrastructure management overhead

#### **2. Command Design Philosophy - Unix Principles Applied**
Docker commands follow proven Unix philosophy:
- **Single Responsibility**: Each command does one thing well
- **Composability**: Commands can be chained and combined for complex workflows
- **Predictable Output**: Consistent formatting enables automation and scripting
- **Extensibility**: Plugin architecture allows custom commands and integrations

**Why This Matters for E-commerce:**
- **Automation**: Predictable commands enable CI/CD pipeline integration
- **Reliability**: Single responsibility reduces failure points
- **Scalability**: Composable commands support complex deployment scenarios
- **Team Efficiency**: Consistent patterns reduce learning curve for new developers

#### **3. Command Categories - Organized by Function**

**Container Lifecycle Management:**
```bash
run, start, stop, restart, rm, pause, unpause
```
**Purpose**: Control container states from creation to deletion
**Business Value**: Direct control over application availability and resource usage

**Image Management:**
```bash
build, pull, push, images, rmi, tag, save, load
```
**Purpose**: Handle container images (templates for containers)
**Business Value**: Version control and distribution of application packages

**System Information & Monitoring:**
```bash
ps, logs, inspect, stats, events, system df
```
**Purpose**: Monitor and troubleshoot running systems
**Business Value**: Operational visibility and performance optimization

**Network Operations:**
```bash
network create, connect, disconnect, ls, inspect, rm
```
**Purpose**: Configure container networking and communication
**Business Value**: Secure service communication and traffic management

**Volume Operations:**
```bash
volume create, mount, unmount, ls, inspect, rm
```
**Purpose**: Manage persistent data storage
**Business Value**: Data persistence and backup strategies

---

## 🔍 Docker Command Structure Deep Dive

### **Universal Command Format Explained**
```bash
docker [GLOBAL-OPTIONS] COMMAND [COMMAND-OPTIONS] [ARGUMENTS]
```

**Breaking Down Each Component:**

#### **GLOBAL-OPTIONS: Affect How Docker Client Behaves**
```bash
--config string      # Where Docker stores client configuration files
-c, --context string # Use specific Docker context (for multi-environment setups)
-D, --debug          # Enable debug mode (shows detailed API calls)
-H, --host list      # Connect to specific Docker daemon (local or remote)
-l, --log-level      # Set logging verbosity (debug, info, warn, error, fatal)
--tls                # Use TLS encryption
-v, --version        # Show Docker version
```

**Theory**: Global options affect how the Docker client communicates with the daemon, not what the daemon does.

#### **Command-Specific Options**
These modify the behavior of individual commands and are the focus of our learning.

---

## 🚀 Essential Commands: Theory → Practice → E-Commerce Application

### **1. docker run - The Foundation Command**

#### **Theory: What Happens When You Run a Container**

```
docker run nginx
     ↓
1. Docker client sends API request to daemon
2. Daemon checks if 'nginx' image exists locally
3. If not, pulls image from registry (Docker Hub)
4. Creates new container from image
5. Allocates resources (CPU, memory, network)
6. Starts container process
7. Returns container ID to client
```

#### **Basic Syntax & Core Concepts**
```bash
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

**Understanding the Components:**
- **OPTIONS**: Modify container behavior (ports, volumes, environment)
- **IMAGE**: Template for creating the container
- **COMMAND**: Override default command in image
- **ARG**: Arguments passed to the command

#### **Progressive Learning: Simple to Advanced**

##### **Level 1: Basic Container Execution**
```bash
# Theory: Run a simple container
docker run hello-world

# What happens:
# 1. Pulls hello-world image (if not present)
# 2. Creates container
# 3. Runs default command
# 4. Container exits
# 5. Container remains (stopped state)
```

**Try it yourself:**
```bash
# Run the command and observe output
docker run hello-world

# Check what happened
docker ps -a  # Shows all containers (including stopped)
```

##### **Level 2: Interactive Containers**
```bash
# Theory: Interactive mode allows you to interact with container
docker run -it ubuntu bash

# Breaking down the options:
# -i (--interactive): Keep STDIN open
# -t (--tty): Allocate pseudo-terminal
# ubuntu: Base image
# bash: Override default command
```

**Understanding -it flags:**
- **-i**: Without this, you can't type input
- **-t**: Without this, you don't get proper terminal formatting
- **Together**: Creates interactive shell experience

**Practice Exercise:**
```bash
# Start interactive Ubuntu container
docker run -it ubuntu bash

# Inside container, try these commands:
ls /
cat /etc/os-release
ps aux
exit

# Back on host, check container status
docker ps -a
```

##### **Level 3: Detached Containers (Background Services)**

**Understanding Detached Mode - The Production Standard:**
```bash
# Run container in background (detached mode)
docker run -d nginx
```

**What `-d` (--detach) Does Step-by-Step:**
1. **Container Creation**: Same process as interactive mode
2. **Background Execution**: Container runs in background, doesn't block terminal
3. **Process Daemonization**: Container process becomes a daemon
4. **Immediate Return**: Returns container ID immediately (12-character string)
5. **Continued Operation**: Container keeps running until stopped or crashes
6. **Terminal Freedom**: You get your command prompt back instantly

**Why Detached Mode is Critical for Production:**
- **Service Deployment**: Web servers, databases, APIs must run continuously
- **Resource Efficiency**: No terminal session overhead or memory waste
- **Automation Friendly**: Perfect for scripts, CI/CD pipelines, orchestration
- **Scalability**: Foundation for running hundreds of service containers
- **Monitoring**: Services can be monitored without blocking terminals

**Comprehensive Practice with Web Server:**
```bash
# Step 1: Start Nginx web server in detached mode
docker run -d --name my-nginx nginx

# What happens internally:
# - Downloads nginx:latest image (if not present locally)
# - Creates new container with name 'my-nginx'
# - Starts nginx master process as PID 1
# - Allocates network namespace and IP address
# - Returns container ID: e.g., a1b2c3d4e5f6

# Step 2: Verify container is running and healthy
docker ps

# Expected output analysis:
# CONTAINER ID: a1b2c3d4e5f6 (first 12 chars of full ID)
# IMAGE: nginx (image used to create container)
# COMMAND: "/docker-entrypoint.sh nginx -g 'daemon off;'"
# CREATED: 2 seconds ago (when container was created)
# STATUS: Up 2 seconds (container is running successfully)
# PORTS: 80/tcp (nginx listening on port 80 inside container)
# NAMES: my-nginx (human-readable name we assigned)

# Step 3: Inspect nginx logs to verify proper startup
docker logs my-nginx

# Expected log output:
# /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
# /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
# /docker-entrypoint.sh: Configuration complete; ready for start up
# 2024/01/15 10:30:45 [notice] 1#1: nginx/1.25.3
# 2024/01/15 10:30:45 [notice] 1#1: start worker processes

# Step 4: Test container responsiveness (advanced)
docker exec my-nginx nginx -t  # Test nginx configuration
docker exec my-nginx ps aux    # See running processes

# Step 5: Graceful shutdown
docker stop my-nginx  # Sends SIGTERM, waits 10 seconds, then SIGKILL

# Step 6: Clean up resources
docker rm my-nginx    # Removes stopped container
```

**Business Impact of Detached Mode:**
- **24/7 Availability**: E-commerce sites require always-on services
- **Cost Efficiency**: Background services optimize resource utilization
- **Operational Excellence**: Enables proper monitoring and alerting
- **Scalability Foundation**: Prerequisite for container orchestration
- **Development Productivity**: Developers can run services without blocking terminals

#### **Port Mapping: Connecting Container Services to the Outside World**

##### **Understanding Container Network Isolation**

**The Networking Challenge:**
By default, containers are completely isolated from the host network. This means:
- **Container services are unreachable** from outside the container
- **Applications inside containers** can't be accessed by users
- **Microservices can't communicate** with each other or external systems
- **Development and testing** become impossible without network access

**Visual Network Architecture:**
```
Host System (Your Computer - IP: 192.168.1.100)
├── Host Port 80    ← Accessible from internet/network
├── Host Port 8080  ← Accessible from internet/network  
├── Host Port 3000  ← Accessible from internet/network
└── Docker Bridge Network (172.17.0.0/16)
    ├── Container 1 (IP: 172.17.0.2)
    │   └── Port 80 ← Isolated, not accessible from outside
    ├── Container 2 (IP: 172.17.0.3)  
    │   └── Port 3000 ← Isolated, not accessible from outside
    └── Container 3 (IP: 172.17.0.4)
        └── Port 5432 ← Isolated, not accessible from outside
```

**Port Mapping Solution:**
Port mapping creates a "bridge" or "tunnel" between host ports and container ports, enabling external access.

##### **Port Mapping Syntax and Patterns**

**Basic Syntax:**
```bash
docker run -p HOST_PORT:CONTAINER_PORT image_name
```

**Component Breakdown:**
- **`-p`**: Port mapping flag (short for --publish)
- **HOST_PORT**: Port on your computer that external traffic uses
- **CONTAINER_PORT**: Port inside container where service is listening
- **Mapping Direction**: Traffic flows: External → Host Port → Container Port

**Common Port Mapping Patterns:**

**1. Web Server Pattern (HTTP):**
```bash
# Map host port 8080 to container port 80
docker run -d -p 8080:80 --name web-server nginx

# Why this works:
# - Nginx inside container listens on port 80 (standard HTTP)
# - Host port 8080 becomes the external access point
# - Users access: http://localhost:8080
# - Traffic flows: Browser → Host:8080 → Container:80 → Nginx
```

**2. Database Pattern (PostgreSQL):**
```bash
# Map host port 5432 to container port 5432 (same port)
docker run -d -p 5432:5432 --name db-server postgres

# Why same ports:
# - PostgreSQL standard port is 5432
# - Applications expect to connect to 5432
# - No confusion about which port to use
```

**3. Development Pattern (Node.js API):**
```bash
# Map host port 3000 to container port 3000
docker run -d -p 3000:3000 --name api-server node-api

# Development benefits:
# - Consistent port numbers (no mental mapping)
# - Easy integration with frontend applications
# - Matches local development setup
```

**4. Production Pattern (Multiple Services):**
```bash
# Web server on standard HTTP port
docker run -d -p 80:80 --name production-web nginx

# API server on different port
docker run -d -p 8080:3000 --name production-api node-api

# Database on standard port
docker run -d -p 5432:5432 --name production-db postgres
```

##### **Comprehensive Practice Exercise**

**Step-by-Step Web Server Deployment:**
```bash
# Step 1: Start Nginx with port mapping
docker run -d -p 8080:80 --name web-server nginx

# What happens internally:
# 1. Creates container from nginx image
# 2. Nginx starts and listens on port 80 inside container
# 3. Docker creates iptables rules to forward traffic
# 4. Host port 8080 now routes to container port 80
# 5. Container gets internal IP (e.g., 172.17.0.2)

# Step 2: Test external connectivity
curl http://localhost:8080

# Expected response:
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# ...

# What this proves:
# - Port mapping is working correctly
# - Nginx is serving content
# - Network connectivity is established
# - External access is functional

# Step 3: Verify port mapping configuration
docker port web-server

# Expected output:
# 80/tcp -> 0.0.0.0:8080
# 
# Explanation:
# - Container port 80/tcp is mapped
# - Host binds to 0.0.0.0:8080 (all interfaces)
# - Traffic from any IP can reach this service

# Step 4: Test from different interfaces
curl http://127.0.0.1:8080    # Loopback interface
curl http://localhost:8080     # Hostname resolution
# If on network: curl http://YOUR_IP:8080

# Step 5: Inspect detailed network configuration
docker inspect web-server | grep -A 10 "NetworkSettings"

# Shows:
# - Container IP address
# - Network mode
# - Port bindings
# - Gateway configuration

# Step 6: Clean up
docker stop web-server
docker rm web-server
```

**Business Impact of Port Mapping:**
- **Service Accessibility**: Makes containerized applications reachable by users
- **Development Efficiency**: Enables local testing and development workflows  
- **Production Deployment**: Foundation for serving real traffic
- **Microservices Architecture**: Enables service-to-service communication
- **Load Balancing**: Allows multiple containers to serve same external port
- **Security Control**: Selective exposure of only necessary ports
docker port web-server

# Clean up
docker stop web-server
docker rm web-server
```

#### **Environment Variables: Configuration Management**

##### **Theory: How Containers Handle Configuration**
Containers should be configurable without rebuilding. Environment variables provide runtime configuration.

```bash
# Set environment variables
docker run -e VARIABLE_NAME=value image
docker run -e NODE_ENV=production -e PORT=3000 node-app

# Multiple variables
docker run \
  -e DATABASE_URL=postgresql://localhost:5432/mydb \
  -e API_KEY=secret123 \
  -e DEBUG=true \
  my-app
```

**Practice with Environment Variables:**
```bash
# Run container with custom environment
docker run -it -e MY_VAR="Hello Docker" ubuntu bash

# Inside container, check the variable
echo $MY_VAR
env | grep MY_VAR
exit
```

---

## 🛒 E-Commerce Application: Applying Docker Commands

Now let's apply these concepts to containerize your e-commerce application step by step.

### **Step 1: Containerize the Database**

#### **Theory: Database Containers**
Database containers need:
- **Persistent storage** (data survives container restarts)
- **Environment configuration** (passwords, database names)
- **Port access** (for application connections)

#### **Practice: PostgreSQL Container**
```bash
# Create PostgreSQL container for e-commerce
docker run -d \
  --name ecommerce-db \
  -e POSTGRES_DB=ecommerce \
  -e POSTGRES_USER=ecommerce_user \
  -e POSTGRES_PASSWORD=secure_password \
  -p 5432:5432 \
  postgres:13

# Verify database is running
docker ps
docker logs ecommerce-db

# Test database connection
docker exec -it ecommerce-db psql -U ecommerce_user -d ecommerce
# Inside PostgreSQL:
\l  # List databases
\q  # Quit
```

**Understanding the Command:**
- `--name ecommerce-db`: Easy reference name
- `-e POSTGRES_*`: Database configuration
- `-p 5432:5432`: Standard PostgreSQL port
- `postgres:13`: Specific PostgreSQL version

### **Step 2: Containerize the Backend API**

#### **Theory: Application Containers**
Application containers typically need:
- **Source code** (via volumes or built into image)
- **Dependencies** (installed in image or mounted)
- **Configuration** (environment variables)
- **Network access** (to database and from frontend)

#### **Practice: Node.js Backend Container**
```bash
# Navigate to your e-commerce backend directory
cd /path/to/your/ecommerce-project/backend

# Run Node.js container with your code
docker run -d \
  --name ecommerce-backend \
  -p 8000:8000 \
  -v $(pwd):/app \
  -w /app \
  -e DATABASE_URL=postgresql://ecommerce_user:secure_password@host.docker.internal:5432/ecommerce \
  node:16 \
  npm start

# Check if backend is running
docker ps
docker logs ecommerce-backend

# Test API endpoint
curl http://localhost:8000/api/health
```

**Understanding the Command:**
- `-v $(pwd):/app`: Mount current directory to /app in container
- `-w /app`: Set working directory
- `-e DATABASE_URL`: Database connection string
- `host.docker.internal`: Special hostname to reach host from container
- `npm start`: Command to run your application

### **Step 3: Containerize the Frontend**

#### **Practice: React Frontend Container**
```bash
# Navigate to frontend directory
cd /path/to/your/ecommerce-project/frontend

# Run React development server in container
docker run -d \
  --name ecommerce-frontend \
  -p 3000:3000 \
  -v $(pwd):/app \
  -w /app \
  -e REACT_APP_API_URL=http://localhost:8000 \
  node:16 \
  npm start

# Verify frontend is running
docker ps
curl http://localhost:3000
```

### **Step 4: Verify Complete E-Commerce Stack**

```bash
# Check all containers are running
docker ps

# Test the complete flow:
# 1. Frontend accessible
curl http://localhost:3000

# 2. Backend API accessible
curl http://localhost:8000/api/health

# 3. Database accessible
docker exec -it ecommerce-db psql -U ecommerce_user -d ecommerce -c "SELECT version();"
```

---

## 🔧 Essential Container Management Commands

### **docker ps - Container Status**

#### **Theory: Container States**
```
Container Lifecycle States:
Created → Running → Paused → Stopped → Removed
    ↓         ↓        ↓         ↓         ↓
  Exists   Active   Frozen   Inactive   Gone
```

#### **Practice: Monitoring Containers**
```bash
# Show running containers
docker ps

# Show all containers (including stopped)
docker ps -a

# Show only container IDs
docker ps -q

# Custom format output
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Filter containers
docker ps --filter "status=running"
docker ps --filter "name=ecommerce"
```

### **docker logs - Container Output**

#### **Theory: Container Logging**
Containers write to STDOUT/STDERR, Docker captures and stores these logs.

#### **Practice: Log Management**
```bash
# View logs from your e-commerce containers
docker logs ecommerce-backend
docker logs ecommerce-frontend
docker logs ecommerce-db

# Follow logs in real-time
docker logs -f ecommerce-backend

# Show last 50 lines
docker logs --tail 50 ecommerce-backend

# Show logs with timestamps
docker logs -t ecommerce-backend
```

### **docker exec - Execute Commands in Running Containers**

#### **Theory: Container Execution Context**
`docker exec` runs commands in existing containers, useful for debugging and maintenance.

#### **Practice: Container Debugging**
```bash
# Get shell access to running container
docker exec -it ecommerce-backend bash

# Run single commands
docker exec ecommerce-backend ls -la /app
docker exec ecommerce-backend npm list
docker exec ecommerce-db psql -U ecommerce_user -d ecommerce -c "SELECT * FROM products LIMIT 5;"

# Check container processes
docker exec ecommerce-backend ps aux
```

### **docker stop/start/restart - Container Lifecycle**

#### **Practice: Managing Container State**
```bash
# Stop containers gracefully
docker stop ecommerce-frontend
docker stop ecommerce-backend
docker stop ecommerce-db

# Start stopped containers
docker start ecommerce-db
docker start ecommerce-backend
docker start ecommerce-frontend

# Restart containers (stop + start)
docker restart ecommerce-backend

# Force stop (if graceful stop fails)
docker kill ecommerce-frontend
```

---

## 🧪 Hands-On Practice Exercises

### **Exercise 1: Container Lifecycle Management**
```bash
# 1. Run a simple web server
docker run -d -p 8080:80 --name practice-nginx nginx

# 2. Verify it's running
curl http://localhost:8080

# 3. Check container details
docker ps
docker inspect practice-nginx

# 4. View logs
docker logs practice-nginx

# 5. Stop and remove
docker stop practice-nginx
docker rm practice-nginx

# 6. Verify cleanup
docker ps -a
```

### **Exercise 2: Environment Configuration**
```bash
# 1. Run container with multiple environment variables
docker run -d \
  --name env-test \
  -e APP_ENV=development \
  -e DEBUG=true \
  -e PORT=3000 \
  -p 3000:3000 \
  node:16 \
  node -e "console.log('Environment:', process.env.APP_ENV); console.log('Debug:', process.env.DEBUG); setInterval(() => console.log('Server running on port', process.env.PORT), 5000);"

# 2. Check logs to see environment variables
docker logs env-test

# 3. Execute command to see all environment variables
docker exec env-test env

# 4. Clean up
docker stop env-test
docker rm env-test
```

### **Exercise 3: Volume Mounting**
```bash
# 1. Create a directory with some files
mkdir -p /tmp/docker-practice
echo "Hello from host" > /tmp/docker-practice/host-file.txt

# 2. Run container with volume mount
docker run -it \
  --name volume-test \
  -v /tmp/docker-practice:/container-data \
  ubuntu bash

# Inside container:
ls /container-data
cat /container-data/host-file.txt
echo "Hello from container" > /container-data/container-file.txt
exit

# 3. Check files on host
ls /tmp/docker-practice
cat /tmp/docker-practice/container-file.txt

# 4. Clean up
docker rm volume-test
rm -rf /tmp/docker-practice
```

---

## 🛒 E-Commerce Project: Complete Setup Script

Create a script to automate your e-commerce container setup:

```bash
#!/bin/bash
# File: start-ecommerce-containers.sh

echo "Starting E-Commerce Docker Containers..."

# 1. Start Database
echo "Starting PostgreSQL database..."
docker run -d \
  --name ecommerce-db \
  -e POSTGRES_DB=ecommerce \
  -e POSTGRES_USER=ecommerce_user \
  -e POSTGRES_PASSWORD=secure_password \
  -p 5432:5432 \
  postgres:13

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# 2. Start Backend
echo "Starting backend API..."
docker run -d \
  --name ecommerce-backend \
  -p 8000:8000 \
  -v $(pwd)/backend:/app \
  -w /app \
  -e DATABASE_URL=postgresql://ecommerce_user:secure_password@host.docker.internal:5432/ecommerce \
  -e NODE_ENV=development \
  node:16 \
  npm start

# 3. Start Frontend
echo "Starting frontend..."
docker run -d \
  --name ecommerce-frontend \
  -p 3000:3000 \
  -v $(pwd)/frontend:/app \
  -w /app \
  -e REACT_APP_API_URL=http://localhost:8000 \
  node:16 \
  npm start

echo "E-Commerce stack started!"
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:8000"
echo "Database: localhost:5432"

# Show running containers
docker ps
```

**Make it executable and run:**
```bash
chmod +x start-ecommerce-containers.sh
./start-ecommerce-containers.sh
```

---

## 📊 Command Reference Quick Guide

### **Essential Commands Summary**
```bash
# Container Lifecycle
docker run [OPTIONS] IMAGE [COMMAND]    # Create and start container
docker start CONTAINER                  # Start stopped container
docker stop CONTAINER                   # Stop running container
docker restart CONTAINER               # Restart container
docker rm CONTAINER                     # Remove stopped container

# Container Information
docker ps                              # List running containers
docker ps -a                           # List all containers
docker logs CONTAINER                  # View container logs
docker inspect CONTAINER               # Detailed container info
docker exec -it CONTAINER COMMAND      # Execute command in container

# Common Options
-d, --detach                           # Run in background
-i, --interactive                      # Keep STDIN open
-t, --tty                             # Allocate pseudo-TTY
-p, --publish HOST:CONTAINER          # Port mapping
-v, --volume HOST:CONTAINER           # Volume mounting
-e, --env VARIABLE=value              # Environment variables
--name NAME                           # Container name
--rm                                  # Auto-remove when stopped
```

---

## ✅ Practice Checklist

### **Basic Commands Mastery**
- [ ] Can run containers in foreground and background
- [ ] Understands the difference between -i, -t, and -it
- [ ] Can map ports between host and container
- [ ] Can set environment variables
- [ ] Can mount volumes for data persistence
- [ ] Can name containers for easy reference

### **Container Management**
- [ ] Can list running and stopped containers
- [ ] Can view and follow container logs
- [ ] Can execute commands in running containers
- [ ] Can start, stop, and restart containers
- [ ] Can remove containers and clean up

### **E-Commerce Application**
- [ ] Successfully containerized database (PostgreSQL)
- [ ] Successfully containerized backend (Node.js/Python)
- [ ] Successfully containerized frontend (React/Vue)
- [ ] Can access all services through mapped ports
- [ ] Can verify inter-service communication

### **Troubleshooting Skills**
- [ ] Can diagnose container startup issues
- [ ] Can check container logs for errors
- [ ] Can inspect container configuration
- [ ] Can test network connectivity between containers

---

## 🚀 Next Steps

You've mastered the fundamental Docker commands! In **Part 2: Image Management**, you'll learn:

- **Image Architecture**: Understanding layers, manifests, and registries
- **Building Images**: Creating custom images for your e-commerce services
- **Image Optimization**: Reducing size and improving security
- **Registry Operations**: Pushing and pulling from Docker Hub and private registries

**Key Takeaway**: Docker commands are powerful because they're built on solid architectural principles. Understanding the theory behind each command makes you more effective at using them and troubleshooting issues.

Continue to **02-Docker-Commands-Part2-Images.md** when you're comfortable with these fundamental commands and have successfully containerized your e-commerce application components.
```bash
# Run in background
docker run -d nginx:alpine
```
**Output:**
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
```
**Explanation:** Returns container ID immediately, container runs in background

**Interactive Mode (-it):**
```bash
# Run with interactive terminal
docker run -it ubuntu:20.04 bash
```
**Output:**
```
root@a1b2c3d4e5f6:/# 
```
**Explanation:** 
- `-i`: Keeps STDIN open for input
- `-t`: Allocates pseudo-terminal for proper display
- Combined: Gives you interactive shell

**Auto-remove (--rm):**
```bash
# Container automatically deleted when stopped
docker run --rm -it ubuntu:20.04 bash
# Exit the container
exit

# Check if container exists (should be empty)
docker ps -a | grep ubuntu
```
**Output:** (No output - container was automatically removed)

#### Network Options
```bash
-p, --publish list           Publish a container's port(s) to the host
-P, --publish-all           Publish all exposed ports to random ports
--network string            Connect a container to a network
--ip string                 IPv4 address (e.g., 172.30.100.104)
--ip6 string                IPv6 address (e.g., 2001:db8::33)
--link list                 Add link to another container (deprecated)
--dns list                  Set custom DNS servers
--dns-search list           Set custom DNS search domains
--add-host list             Add a custom host-to-IP mapping (host:ip)
```

**Port Mapping Examples:**

**Single Port Mapping:**
```bash
# Map host port 8080 to container port 80
docker run -d -p 8080:80 --name web nginx:alpine

# Test the mapping
curl http://localhost:8080

# Check port mapping
docker port web
```

**Expected Outputs:**
```bash
# curl output:
<!DOCTYPE html>
<html>
<head><title>Welcome to nginx!</title></head>
...

# docker port output:
80/tcp -> 0.0.0.0:8080
```

**Multiple Port Mappings:**
```bash
# Map multiple ports
docker run -d \
  -p 8080:80 \
  -p 8443:443 \
  --name multi-port-web \
  nginx:alpine

# Check all mappings
docker port multi-port-web
```

**Expected Output:**
```
80/tcp -> 0.0.0.0:8080
443/tcp -> 0.0.0.0:8443
```

**Publish All Ports (-P):**
```bash
# Map all exposed ports to random host ports
docker run -d -P --name random-ports nginx:alpine

# Check what ports were assigned
docker port random-ports
```

**Expected Output:**
```
80/tcp -> 0.0.0.0:32768
```
**Explanation:** Docker automatically assigned random host port 32768

#### Volume and Storage Options
```bash
-v, --volume list            Bind mount a volume
--mount mount               Attach a filesystem mount to the container
--volumes-from list         Mount volumes from the specified container(s)
--tmpfs list                Mount a tmpfs directory
--storage-opt list          Storage driver options for the container
```

**Volume Mounting Examples:**

**Bind Mount (Host Directory):**
```bash
# Create host directory
mkdir -p /tmp/web-content
echo "<h1>Hello from Host!</h1>" > /tmp/web-content/index.html

# Mount host directory to container
docker run -d \
  -p 8080:80 \
  -v /tmp/web-content:/usr/share/nginx/html \
  --name volume-test \
  nginx:alpine

# Test custom content
curl http://localhost:8080
```

**Expected Output:**
```html
<h1>Hello from Host!</h1>
```

**Named Volume:**
```bash
# Create named volume
docker volume create my-data-volume

# Use named volume
docker run -d \
  -v my-data-volume:/data \
  --name volume-container \
  ubuntu:20.04 \
  bash -c "echo 'Persistent data' > /data/file.txt && sleep 3600"

# Verify data in volume
docker exec volume-container cat /data/file.txt
```

**Expected Output:**
```
Persistent data
```

#### Environment and Configuration Options
```bash
-e, --env list               Set environment variables
--env-file list             Read in a file of environment variables
-w, --workdir string        Working directory inside the container
-u, --user string           Username or UID (format: <name|uid>[:<group|gid>])
```

**Environment Variable Examples:**

**Single Environment Variable:**
```bash
# Set single environment variable
docker run -d \
  -e NODE_ENV=production \
  --name env-test \
  node:16-alpine \
  node -e "console.log('Environment:', process.env.NODE_ENV); setTimeout(() => {}, 60000)"

# Check environment variable
docker exec env-test printenv NODE_ENV
```

**Expected Output:**
```
production
```

**Multiple Environment Variables:**
```bash
# Set multiple environment variables
docker run -d \
  -e DATABASE_HOST=localhost \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=myapp \
  --name multi-env-test \
  postgres:13

# Check all environment variables
docker exec multi-env-test printenv | grep DATABASE
```

**Expected Output:**
```
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp
```

**Environment File:**
```bash
# Create environment file
cat > app.env << 'EOF'
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://localhost:5432/myapp
API_KEY=secret-key-here
EOF

# Use environment file
docker run -d \
  --env-file app.env \
  --name env-file-test \
  node:16-alpine \
  node -e "console.log(JSON.stringify(process.env, null, 2)); setTimeout(() => {}, 60000)"

# Check loaded environment
docker logs env-file-test
```

#### Resource Limitation Options
```bash
-m, --memory bytes          Memory limit
--memory-swap bytes         Swap limit equal to memory plus swap: '-1' to enable unlimited swap
--memory-swappiness int     Tune container memory swappiness (0 to 100) (default -1)
--oom-kill-disable          Disable OOM Killer
--cpus decimal              Number of CPUs
--cpu-shares int            CPU shares (relative weight)
--cpuset-cpus string        CPUs in which to allow execution (0-3, 0,1)
```

**Resource Limitation Examples:**

**Memory Limit:**
```bash
# Limit container to 512MB RAM
docker run -d \
  --memory=512m \
  --name memory-limited \
  nginx:alpine

# Check memory limit
docker inspect memory-limited | grep -A 5 "Memory"
```

**Expected Output:**
```json
"Memory": 536870912,
"MemoryReservation": 0,
"MemorySwap": 1073741824,
"MemorySwappiness": null,
```
**Explanation:** 536870912 bytes = 512MB

**CPU Limit:**
```bash
# Limit container to 1.5 CPUs
docker run -d \
  --cpus="1.5" \
  --name cpu-limited \
  nginx:alpine

# Check CPU limit
docker inspect cpu-limited | grep -A 3 "NanoCpus"
```

**Expected Output:**
```json
"NanoCpus": 1500000000,
```
**Explanation:** 1500000000 nanocpus = 1.5 CPUs

#### Security Options
```bash
--security-opt list         Security Options
--cap-add list              Add Linux capabilities
--cap-drop list             Drop Linux capabilities
--privileged                Give extended privileges to this container
--user string, -u string    Username or UID (format: <name|uid>[:<group|gid>])
--group-add list            Add additional groups to join
```

**Security Examples:**

**Run as Non-root User:**
```bash
# Run as specific user ID
docker run -d \
  --user 1000:1000 \
  --name non-root-test \
  nginx:alpine

# Check user inside container
docker exec non-root-test id
```

**Expected Output:**
```
uid=1000 gid=1000 groups=1000
```

**Drop Capabilities:**
```bash
# Drop all capabilities except NET_BIND_SERVICE
docker run -d \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --name secure-web \
  nginx:alpine

# Check capabilities
docker exec secure-web cat /proc/1/status | grep Cap
```

---

## 📊 docker ps - Container Listing

### Basic Syntax
```bash
docker ps [OPTIONS]
```

### All Available Options
```bash
-a, --all             Show all containers (default shows just running)
-f, --filter filter   Filter output based on conditions provided
--format string       Pretty-print containers using a Go template
-n, --last int        Show n last created containers (includes all states) (default -1)
-l, --latest          Show the latest created container (includes all states)
--no-trunc           Don't truncate output
-q, --quiet          Only display container IDs
-s, --size           Display total file sizes
```

### Detailed Examples

**Basic Container Listing:**
```bash
# Show running containers
docker ps
```

**Expected Output:**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   web-server
```

**Column Explanations:**
- **CONTAINER ID**: First 12 characters of full container ID
- **IMAGE**: Image name and tag used to create container
- **COMMAND**: Command running inside container (truncated)
- **CREATED**: How long ago container was created
- **STATUS**: Current status (Up = running, Exited = stopped)
- **PORTS**: Port mappings (host:container)
- **NAMES**: Human-readable container name

**Show All Containers (including stopped):**
```bash
# Show all containers regardless of status
docker ps -a
```

**Expected Output:**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                      PORTS     NAMES
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   5 minutes ago    Up 5 minutes               80/tcp    web-server
b2c3d4e5f6g7   ubuntu:20.04   "bash"                   10 minutes ago   Exited (0) 8 minutes ago             test-ubuntu
c3d4e5f6g7h8   hello-world    "/hello"                 15 minutes ago   Exited (0) 15 minutes ago            amazing_tesla
```

**Filter Examples:**

**Filter by Status:**
```bash
# Show only running containers
docker ps --filter "status=running"

# Show only exited containers
docker ps -a --filter "status=exited"

# Show containers that exited with code 0
docker ps -a --filter "exited=0"
```

**Filter by Name:**
```bash
# Show containers with names containing "web"
docker ps --filter "name=web"

# Show containers with exact name
docker ps --filter "name=^web-server$"
```

**Filter by Image:**
```bash
# Show containers from nginx image
docker ps --filter "ancestor=nginx"

# Show containers from specific image version
docker ps --filter "ancestor=nginx:alpine"
```

**Custom Format Output:**
```bash
# Custom format showing only ID, name, and status
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

**Expected Output:**
```
CONTAINER ID   NAMES        STATUS
a1b2c3d4e5f6   web-server   Up 10 minutes
```

**Available Format Variables:**
- `.ID`: Container ID
- `.Image`: Image name
- `.Command`: Command
- `.CreatedAt`: Creation time
- `.RunningFor`: Duration running
- `.Ports`: Port mappings
- `.Status`: Container status
- `.Size`: Container size (if -s used)
- `.Names`: Container names
- `.Labels`: Container labels
- `.Mounts`: Volume mounts

**Show Container Sizes:**
```bash
# Include container sizes in output
docker ps -s
```

**Expected Output:**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES        SIZE
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   web-server   1.09kB (virtual 23.4MB)
```

**Size Explanation:**
- **1.09kB**: Size of writable layer (changes made to container)
- **virtual 23.4MB**: Total size including image layers

---

## 🛑 docker stop/start/restart - Container Lifecycle

### docker stop - Stop Running Containers

**Syntax:**
```bash
docker stop [OPTIONS] CONTAINER [CONTAINER...]
```

**Options:**
```bash
-t, --time int   Seconds to wait for stop before killing it (default 10)
```

**Examples:**

**Stop Single Container:**
```bash
# Stop container gracefully (SIGTERM, then SIGKILL after 10s)
docker stop web-server
```

**Expected Output:**
```
web-server
```

**Stop with Custom Timeout:**
```bash
# Give container 30 seconds to stop gracefully
docker stop -t 30 web-server
```

**Stop Multiple Containers:**
```bash
# Stop multiple containers at once
docker stop web-server api-server db-server
```

**Expected Output:**
```
web-server
api-server
db-server
```

### docker start - Start Stopped Containers

**Syntax:**
```bash
docker start [OPTIONS] CONTAINER [CONTAINER...]
```

**Options:**
```bash
-a, --attach               Attach STDOUT/STDERR and forward signals
-i, --interactive          Attach container's STDIN
```

**Examples:**

**Start Stopped Container:**
```bash
# Start previously stopped container
docker start web-server
```

**Expected Output:**
```
web-server
```

**Start with Attach:**
```bash
# Start and attach to see output
docker start -a web-server
```

### docker restart - Restart Containers

**Syntax:**
```bash
docker restart [OPTIONS] CONTAINER [CONTAINER...]
```

**Options:**
```bash
-t, --time int   Seconds to wait for stop before killing it (default 10)
```

**Example:**
```bash
# Restart container (stop + start)
docker restart web-server
```

**Expected Output:**
```
web-server
```

---

## 🗑️ docker rm - Remove Containers

### Syntax
```bash
docker rm [OPTIONS] CONTAINER [CONTAINER...]
```

### All Available Options
```bash
-f, --force     Force the removal of a running container (uses SIGKILL)
-l, --link      Remove the specified link
-v, --volumes   Remove anonymous volumes associated with the container
```

### Examples

**Remove Stopped Container:**
```bash
# Remove stopped container
docker rm web-server
```

**Expected Output:**
```
web-server
```

**Force Remove Running Container:**
```bash
# Force remove running container
docker rm -f web-server
```

**Remove with Volumes:**
```bash
# Remove container and its anonymous volumes
docker rm -v web-server
```

**Remove Multiple Containers:**
```bash
# Remove multiple containers
docker rm container1 container2 container3
```

**Remove All Stopped Containers:**
```bash
# Remove all stopped containers
docker rm $(docker ps -aq --filter "status=exited")
```

---

## 🚀 Next Steps

You now understand the fundamental Docker commands with complete option details:

- ✅ **docker run**: All options for container creation
- ✅ **docker ps**: Complete container listing and filtering
- ✅ **docker stop/start/restart**: Container lifecycle management
- ✅ **docker rm**: Container removal with all options

**Ready for Part 2: Image Management Commands** where you'll master docker pull, push, build, and image manipulation!
