# Docker Runtime Architecture - From Black Box to Expert Understanding

## 📋 Learning Objectives
- **Understand** what happens when you run `docker run` at the system level
- **Master** Docker's internal architecture and component relationships  
- **Apply** runtime knowledge to optimize your e-commerce application performance
- **Troubleshoot** production issues using deep runtime understanding

---

## 🤔 Why Learn Docker Runtime Internals?

### **The Problem: Docker as a Black Box**

After Module 6, you can deploy your e-commerce platform successfully:
```bash
docker-compose up -d  # Everything works!
```

But when problems occur in production, you're stuck:
```bash
# Your e-commerce API is slow - why?
docker stats backend  # Shows high CPU, but why?

# Container keeps crashing - what's happening?
docker logs backend  # Shows "killed", but by what?

# Memory usage keeps growing - where's the leak?
docker exec backend ps aux  # Shows processes, but what's the root cause?
```

### **The Solution: Understanding the Runtime**

With runtime knowledge, you become a Docker expert who can:
- **Diagnose** performance issues at the system level
- **Optimize** containers for maximum efficiency  
- **Troubleshoot** complex production problems
- **Design** enterprise-grade container architectures

### **Real-World Impact**

```
Before Runtime Knowledge:
├── "The container is slow" → Restart and hope
├── "Memory usage is high" → Add more RAM
├── "Container crashed" → Check logs and guess
└── "Network is slow" → Blame the infrastructure

After Runtime Knowledge:
├── "High CPU usage" → Analyze cgroup limits and process scheduling
├── "Memory pressure" → Examine memory allocation and garbage collection
├── "Container killed" → Check OOM killer and resource constraints
└── "Network latency" → Investigate namespace routing and bridge configuration
```

---

## 🏗️ Docker Architecture: What You Know vs What's Really Happening

### **What You Think Happens**
```bash
docker run nginx
# "Docker runs nginx"
```

### **What Actually Happens (The Complete Flow)**
```
1. Docker CLI → Docker Engine (dockerd)
2. Docker Engine → containerd (container lifecycle)
3. containerd → containerd-shim (process supervision)
4. containerd-shim → runc (OCI runtime)
5. runc → Linux Kernel (namespaces, cgroups)
6. Linux Kernel → Container Process (nginx)
```

### **The Complete Architecture Stack**
```
┌─────────────────────────────────────┐
│           Docker CLI/API            │ ← What you interact with
├─────────────────────────────────────┤
│         Docker Engine (dockerd)     │ ← What you installed
├─────────────────────────────────────┤
│            containerd               │ ← Container lifecycle manager
├─────────────────────────────────────┤
│         containerd-shim             │ ← Process supervisor
├─────────────────────────────────────┤
│              runc                   │ ← OCI runtime
├─────────────────────────────────────┤
│          Linux Kernel              │ ← Operating system
└─────────────────────────────────────┘
```

**Key Insight**: Docker is actually a collection of specialized tools working together, not a single monolithic system.

---

## 🔍 Understanding Each Layer: Theory → Practice

### **Layer 1: Docker CLI/API - Your Interface**

#### **What You Already Know**
```bash
docker run -d -p 8080:80 nginx
docker ps
docker logs container_name
```

#### **What's Really Happening**
Every Docker command is an HTTP API call to the Docker daemon:

```bash
# When you run this:
docker run nginx

# This actually happens:
curl -X POST http://localhost/containers/create \
  -H "Content-Type: application/json" \
  -d '{
    "Image": "nginx",
    "ExposedPorts": {"80/tcp": {}},
    "HostConfig": {
      "PublishAllPorts": true
    }
  }'
```

#### **Practice: Explore the API**
```bash
# Enable Docker API debugging
export DOCKER_API_VERSION=1.41
docker --debug run hello-world

# You'll see the actual API calls being made
# This helps you understand what Docker CLI does behind the scenes
```

### **Layer 2: Docker Engine (dockerd) - The Orchestrator**

#### **Theory: What Docker Engine Does**
Docker Engine is like a conductor of an orchestra:
- **Receives** API requests from CLI
- **Manages** images, containers, networks, volumes
- **Delegates** actual container operations to containerd
- **Handles** Docker-specific features (Dockerfile builds, Docker Compose)

#### **Understanding Docker Engine's Role**
```bash
# Docker Engine manages these resources:
docker system info  # Shows engine configuration
docker system df     # Shows disk usage
docker system events # Shows real-time events
```

#### **🛒 E-Commerce Application: Engine-Level Monitoring**
```bash
# Monitor your e-commerce containers at engine level
docker system events --filter container=ecommerce-frontend &
docker system events --filter container=ecommerce-backend &

# In another terminal, restart a service
docker restart ecommerce-frontend

# Observe the engine-level events - you'll see:
# - Container stop event
# - Container start event  
# - Network attach/detach events
# - Volume mount events
```

### **Layer 3: containerd - The Container Lifecycle Manager**

#### **Theory: Why containerd Exists**
containerd is the industry-standard container runtime that:
- **Manages** container lifecycle (create, start, stop, delete)
- **Handles** image management and storage
- **Provides** gRPC API for container operations
- **Works** with any OCI-compliant runtime (not just Docker)

#### **Understanding containerd vs Docker**
```
Docker Engine:
├── User-friendly CLI
├── Dockerfile builds  
├── Docker Compose
├── Registry authentication
└── containerd (for actual container operations)

containerd:
├── Container lifecycle management
├── Image management
├── Snapshot management
├── Runtime management
└── gRPC API
```

#### **Practice: Interact with containerd Directly**
```bash
# List containerd namespaces (Docker uses 'moby' namespace)
sudo ctr namespace list

# List containers managed by containerd
sudo ctr -n moby container list

# List images in containerd
sudo ctr -n moby image list

# Get detailed info about a container
sudo ctr -n moby container info <container-id>
```

#### **🛒 E-Commerce Application: containerd-Level Debugging**
```bash
# Find your e-commerce containers in containerd
sudo ctr -n moby container list | grep ecommerce

# Get detailed runtime information
CONTAINER_ID=$(docker ps -q --filter name=ecommerce-backend)
sudo ctr -n moby container info $CONTAINER_ID

# This shows you the actual OCI runtime configuration
# You can see resource limits, security settings, and more
```

---

## 🛒 E-Commerce Application: Runtime-Level Optimization

### **Step 1: Analyze Current Runtime Configuration**

```bash
# Get detailed runtime info for your e-commerce services
for service in ecommerce-frontend ecommerce-backend ecommerce-db; do
    echo "=== $service Runtime Analysis ==="
    
    # Docker-level info
    docker inspect $service --format '{{.HostConfig.Memory}}'
    docker inspect $service --format '{{.HostConfig.CpuShares}}'
    
    # containerd-level info
    CONTAINER_ID=$(docker inspect $service --format '{{.Id}}')
    sudo ctr -n moby container info $CONTAINER_ID | grep -A 5 "resources"
    
    echo ""
done
```

### **Step 2: Optimize Runtime Configuration**

#### **Memory Optimization**
```bash
# Current memory usage
docker stats --no-stream ecommerce-backend

# Optimize memory limits based on actual usage
docker update --memory=512m ecommerce-backend
docker update --memory=256m ecommerce-frontend  
docker update --memory=1g ecommerce-db
```

#### **CPU Optimization**
```bash
# Set CPU limits based on service requirements
docker update --cpus="1.0" ecommerce-backend    # API needs more CPU
docker update --cpus="0.5" ecommerce-frontend   # Static serving
docker update --cpus="2.0" ecommerce-db         # Database operations
```

### **Step 3: Runtime Monitoring and Debugging**

#### **Create Runtime Monitoring Script**
```bash
#!/bin/bash
# File: monitor-runtime.sh

echo "E-Commerce Runtime Monitoring"
echo "============================"

for service in ecommerce-frontend ecommerce-backend ecommerce-db; do
    if docker ps --filter name=$service --format '{{.Names}}' | grep -q $service; then
        echo "Service: $service"
        
        # Container-level stats
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $service
        
        # Process-level info
        PID=$(docker inspect $service --format '{{.State.Pid}}')
        echo "  Main PID: $PID"
        echo "  Namespaces: $(sudo ls /proc/$PID/ns/ | tr '\n' ' ')"
        
        # Resource limits
        CONTAINER_ID=$(docker inspect $service --format '{{.Id}}')
        MEMORY_LIMIT=$(sudo cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.limit_in_bytes 2>/dev/null || echo "unlimited")
        echo "  Memory Limit: $MEMORY_LIMIT bytes"
        
        echo ""
    fi
done
```

**Make it executable and run:**
```bash
chmod +x monitor-runtime.sh
./monitor-runtime.sh
```

---

## 🧪 Hands-On Practice: Runtime Deep Dive

### **Exercise 1: Container Lifecycle Tracing**

```bash
# Terminal 1: Monitor containerd events
sudo ctr -n moby events &

# Terminal 2: Monitor Docker events  
docker events &

# Terminal 3: Create and manage a container
docker run -d --name lab-container nginx
docker stop lab-container
docker start lab-container
docker rm lab-container

# Observe the events in terminals 1 and 2
# See how Docker commands translate to containerd operations
```

### **Exercise 2: Resource Limit Testing**

```bash
# Create container with strict limits
docker run -d --name resource-test \
  --memory=100m \
  --cpus="0.5" \
  nginx

# Test memory limit (this should fail)
docker exec resource-test dd if=/dev/zero of=/tmp/bigfile bs=1M count=200

# Monitor resource usage
docker stats resource-test

# Clean up
docker stop resource-test
docker rm resource-test
```

### **Exercise 3: Namespace Exploration**

```bash
# Create container and explore its namespaces
docker run -d --name namespace-test nginx
PID=$(docker inspect namespace-test --format '{{.State.Pid}}')

# Compare namespaces between host and container
echo "Host namespaces:"
ls -la /proc/self/ns/

echo "Container namespaces:"
sudo ls -la /proc/$PID/ns/

# Check if they're different (they should be)
sudo readlink /proc/self/ns/pid
sudo readlink /proc/$PID/ns/pid

# Clean up
docker stop namespace-test
docker rm namespace-test
```

---

## ✅ Knowledge Check: Runtime Understanding

### **Conceptual Understanding**
- [ ] Can explain the difference between Docker Engine, containerd, and runc
- [ ] Understands the role of containerd-shim in process management
- [ ] Knows how Linux namespaces provide container isolation
- [ ] Comprehends how cgroups enforce resource limits
- [ ] Can describe the OCI specification and its importance

### **Practical Skills**
- [ ] Can inspect containers at the containerd level
- [ ] Knows how to monitor runtime performance
- [ ] Can debug container startup issues using runtime tools
- [ ] Understands how to optimize runtime configuration
- [ ] Can trace container lifecycle events

### **E-Commerce Application**
- [ ] Has optimized e-commerce containers at runtime level
- [ ] Implemented runtime monitoring for production services
- [ ] Can troubleshoot performance issues using runtime knowledge
- [ ] Understands security implications of runtime configuration

---

## 🚀 Next Steps: Advanced Container Networking

### **What You've Mastered**
- ✅ **Docker runtime architecture** and component relationships
- ✅ **Container lifecycle management** at the system level
- ✅ **Performance optimization** using runtime knowledge
- ✅ **Debugging techniques** for production issues

### **Coming Next: Advanced Container Networking**
In **02-Advanced-Container-Networking.md**, you'll learn:
- **Enterprise networking patterns** for complex applications
- **Custom network solutions** for security and performance
- **Service mesh integration** for microservices
- **Network troubleshooting** at the expert level

### **E-Commerce Evolution Preview**
Your runtime knowledge will enable you to:
- **Optimize performance** by 50%+ through runtime tuning
- **Debug complex issues** that stump other developers
- **Design enterprise architectures** with deep technical understanding
- **Implement advanced monitoring** at the system level

**Continue to Advanced Container Networking when you're comfortable with runtime concepts and have optimized your e-commerce platform using runtime knowledge.**

## 🤔 Why Learn Docker Internals?

### **The Problem Most Developers Face**
```bash
# When this fails in production:
docker run -d --name ecommerce-api my-api:latest

# Most developers can only try:
docker logs ecommerce-api
docker restart ecommerce-api

# But experts can:
# - Analyze containerd logs
# - Inspect OCI runtime configuration
# - Debug namespace and cgroup issues
# - Optimize at the kernel level
```

### **What You'll Gain**
- **Faster Troubleshooting**: Diagnose issues others can't solve
- **Better Performance**: Optimize at levels others don't know exist
- **Production Confidence**: Understand exactly what's happening in your containers
- **Career Advancement**: Knowledge that puts you in the top 10% of Docker users

---

## 🏗️ Docker Architecture: What You Already Know vs What's Really Happening

### **What You Think Happens**
```bash
docker run nginx
# "Docker runs nginx"
```

### **What Actually Happens (Simplified)**
```
Your Command → Docker CLI → Docker Engine → containerd → runc → Linux Kernel
     ↓              ↓            ↓             ↓         ↓         ↓
"docker run"   API call    Container mgmt   Runtime   Process   Namespaces
                                                      creation   & cgroups
```

### **The Complete Architecture Stack**
```
┌─────────────────────────────────────┐
│           Docker CLI/API            │ ← What you interact with
├─────────────────────────────────────┤
│         Docker Engine (dockerd)     │ ← What you installed
├─────────────────────────────────────┤
│            containerd               │ ← Container lifecycle manager
├─────────────────────────────────────┤
│         containerd-shim             │ ← Process supervisor
├─────────────────────────────────────┤
│              runc                   │ ← Container runtime
├─────────────────────────────────────┤
│          Linux Kernel              │ ← Operating system
└─────────────────────────────────────┘
```

**Key Insight**: Docker is actually a collection of specialized tools working together, not a single monolithic system.

---

## 🔍 Understanding Each Layer: Theory → Practice

### **Layer 1: Docker CLI/API - Your Interface**

#### **What You Already Know**
```bash
docker run -d -p 8080:80 nginx
docker ps
docker logs container_name
```

#### **What's Really Happening**
```bash
# Every Docker command is an HTTP API call
curl -X POST http://localhost/containers/create \
  -H "Content-Type: application/json" \
  -d '{
    "Image": "nginx",
    "ExposedPorts": {"80/tcp": {}},
    "HostConfig": {
      "PortBindings": {"80/tcp": [{"HostPort": "8080"}]}
    }
  }'
```

#### **Practice: Explore the API**
```bash
# Enable Docker API (if not already enabled)
# Check what Docker CLI is really doing
docker --debug run hello-world

# You'll see the actual API calls being made
```

### **Layer 2: Docker Engine (dockerd) - The Orchestrator**

#### **Theory: What Docker Engine Does**
Docker Engine is like a conductor of an orchestra:
- **Receives** API requests from CLI
- **Manages** images, containers, networks, volumes
- **Delegates** actual container operations to containerd
- **Handles** Docker-specific features (Dockerfile builds, Docker Compose)

#### **Practice: Inspect Docker Engine**
```bash
# Check Docker Engine status
systemctl status docker

# View Docker Engine configuration
docker system info

# See what Docker Engine is managing
docker system df  # Disk usage
docker system events  # Real-time events
```

#### **🛒 E-Commerce Application: Engine-Level Monitoring**
```bash
# Monitor your e-commerce containers at engine level
docker system events --filter container=ecommerce-frontend &
docker system events --filter container=ecommerce-backend &

# In another terminal, restart a service
docker restart ecommerce-frontend

# Observe the engine-level events
```

### **Layer 3: containerd - The Container Lifecycle Manager**

#### **Theory: Why containerd Exists**
containerd is the industry-standard container runtime that:
- **Manages** container lifecycle (create, start, stop, delete)
- **Handles** image management and storage
- **Provides** gRPC API for container operations
- **Works** with any OCI-compliant runtime (not just Docker)

#### **Understanding containerd vs Docker**
```
Docker Engine:
├── User-friendly CLI
├── Dockerfile builds
├── Docker Compose
├── Registry authentication
└── containerd (for actual container operations)

containerd:
├── Container lifecycle management
├── Image management
├── Snapshot management
├── Runtime management
└── gRPC API
```

#### **Practice: Interact with containerd Directly**
```bash
# List containerd namespaces (Docker uses 'moby' namespace)
sudo ctr namespace list

# List containers managed by containerd
sudo ctr -n moby container list

# List images in containerd
sudo ctr -n moby image list

# Get detailed info about a container
sudo ctr -n moby container info <container-id>
```

#### **🛒 E-Commerce Application: containerd-Level Debugging**
```bash
# Find your e-commerce containers in containerd
sudo ctr -n moby container list | grep ecommerce

# Get detailed runtime information
sudo ctr -n moby container info $(docker ps -q --filter name=ecommerce-backend)

# This shows you the actual OCI runtime configuration
```

### **Layer 4: containerd-shim - The Process Supervisor**

#### **Theory: Why Shims Exist**
The containerd-shim is a small process that:
- **Supervises** each container process
- **Handles** container I/O (stdin, stdout, stderr)
- **Manages** container lifecycle events
- **Allows** containerd to restart without affecting running containers

#### **Practice: Observe Shims in Action**
```bash
# See containerd-shim processes
ps aux | grep containerd-shim

# Each running container has its own shim process
# The shim stays running even if containerd restarts
```

#### **🛒 E-Commerce Application: Shim-Level Process Management**
```bash
# Find shim processes for your e-commerce containers
ps aux | grep containerd-shim | grep -E "(ecommerce|postgres)"

# Each line represents a shim managing one of your containers
# This is how your containers stay running independently
```

### **Layer 5: runc - The OCI Runtime**

#### **Theory: What runc Actually Does**
runc is the low-level runtime that:
- **Creates** Linux namespaces (PID, network, mount, etc.)
- **Sets up** cgroups for resource limits
- **Configures** security (capabilities, seccomp, AppArmor)
- **Executes** the container process
- **Exits** after container starts (stateless)

#### **Understanding OCI (Open Container Initiative)**
```
OCI Specification:
├── Runtime Spec: How to run containers
├── Image Spec: How to package containers
└── Distribution Spec: How to distribute containers

runc implements the Runtime Spec
```

#### **Practice: Use runc Directly**
```bash
# Create a simple container bundle
mkdir /tmp/mycontainer
cd /tmp/mycontainer

# Generate OCI runtime configuration
runc spec

# Edit config.json to use a simple rootfs
# (This is advanced - normally containerd handles this)

# You can see the raw OCI configuration that runc uses
cat config.json | jq .process.args
```

### **Layer 6: Linux Kernel - The Foundation**

#### **Theory: Kernel Features Docker Uses**
```
Linux Kernel Features:
├── Namespaces: Process isolation
│   ├── PID: Process ID isolation
│   ├── Network: Network stack isolation
│   ├── Mount: Filesystem isolation
│   ├── UTS: Hostname isolation
│   ├── IPC: Inter-process communication isolation
│   └── User: User ID isolation
├── Cgroups: Resource limits and accounting
├── Capabilities: Fine-grained privileges
├── Seccomp: System call filtering
└── AppArmor/SELinux: Mandatory access control
```

#### **Practice: Inspect Kernel-Level Container Features**
```bash
# See namespaces for a running container
docker run -d --name test-container nginx
PID=$(docker inspect test-container --format '{{.State.Pid}}')

# Check namespaces
sudo ls -la /proc/$PID/ns/

# Check cgroups
sudo cat /sys/fs/cgroup/memory/docker/$(docker inspect test-container --format '{{.Id}}')/memory.limit_in_bytes

# Clean up
docker stop test-container
docker rm test-container
```

---

## 🛒 E-Commerce Application: Runtime-Level Optimization

### **Step 1: Analyze Current Runtime Configuration**

```bash
# Get detailed runtime info for your e-commerce services
for service in ecommerce-frontend ecommerce-backend ecommerce-db; do
    echo "=== $service Runtime Analysis ==="
    
    # Docker-level info
    docker inspect $service --format '{{.HostConfig.Memory}}'
    docker inspect $service --format '{{.HostConfig.CpuShares}}'
    
    # containerd-level info
    CONTAINER_ID=$(docker inspect $service --format '{{.Id}}')
    sudo ctr -n moby container info $CONTAINER_ID | grep -A 5 "resources"
    
    echo ""
done
```

### **Step 2: Optimize Runtime Configuration**

#### **Memory Optimization**
```bash
# Current memory usage
docker stats --no-stream ecommerce-backend

# Optimize memory limits based on actual usage
docker update --memory=512m ecommerce-backend
docker update --memory=256m ecommerce-frontend
docker update --memory=1g ecommerce-db
```

#### **CPU Optimization**
```bash
# Set CPU limits based on service requirements
docker update --cpus="1.0" ecommerce-backend    # API needs more CPU
docker update --cpus="0.5" ecommerce-frontend   # Static serving
docker update --cpus="2.0" ecommerce-db         # Database operations
```

### **Step 3: Runtime Monitoring and Debugging**

#### **Create Runtime Monitoring Script**
```bash
#!/bin/bash
# File: monitor-runtime.sh

echo "E-Commerce Runtime Monitoring"
echo "============================"

for service in ecommerce-frontend ecommerce-backend ecommerce-db; do
    if docker ps --filter name=$service --format '{{.Names}}' | grep -q $service; then
        echo "Service: $service"
        
        # Container-level stats
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $service
        
        # Process-level info
        PID=$(docker inspect $service --format '{{.State.Pid}}')
        echo "  Main PID: $PID"
        echo "  Namespaces: $(sudo ls /proc/$PID/ns/ | tr '\n' ' ')"
        
        # Resource limits
        CONTAINER_ID=$(docker inspect $service --format '{{.Id}}')
        MEMORY_LIMIT=$(sudo cat /sys/fs/cgroup/memory/docker/$CONTAINER_ID/memory.limit_in_bytes 2>/dev/null || echo "unlimited")
        echo "  Memory Limit: $MEMORY_LIMIT bytes"
        
        echo ""
    fi
done
```

**Make it executable and run:**
```bash
chmod +x monitor-runtime.sh
./monitor-runtime.sh
```

---

## 🔧 Advanced Runtime Techniques

### **1. Custom Runtime Configuration**

#### **Theory: When to Customize Runtime**
- **High-performance applications**: Custom cgroup settings
- **Security-sensitive workloads**: Additional isolation
- **Resource-constrained environments**: Fine-tuned limits
- **Debugging scenarios**: Enhanced observability

#### **Practice: Custom containerd Configuration**
```bash
# View current containerd configuration
sudo cat /etc/containerd/config.toml

# Key sections you can customize:
# - Runtime options
# - Plugin configurations
# - Registry settings
# - Networking options
```

### **2. Runtime Performance Profiling**

#### **CPU Profiling**
```bash
# Profile CPU usage of your e-commerce backend
docker exec ecommerce-backend top -b -n 1

# Get detailed process information
docker exec ecommerce-backend ps aux

# Monitor system calls (advanced debugging)
docker exec ecommerce-backend strace -c -p 1
```

#### **Memory Profiling**
```bash
# Memory usage breakdown
docker exec ecommerce-backend cat /proc/meminfo

# Process memory mapping
docker exec ecommerce-backend cat /proc/1/smaps
```

### **3. Runtime Security Analysis**

```bash
# Check security context of your containers
for service in ecommerce-frontend ecommerce-backend ecommerce-db; do
    echo "=== $service Security Analysis ==="
    
    # User context
    docker exec $service id
    
    # Capabilities
    docker exec $service cat /proc/1/status | grep Cap
    
    # Seccomp profile
    docker exec $service cat /proc/1/status | grep Seccomp
    
    echo ""
done
```

---

## 🧪 Hands-On Lab: Runtime Deep Dive

### **Lab 1: Container Lifecycle Tracing**

```bash
# Terminal 1: Monitor containerd events
sudo ctr -n moby events &

# Terminal 2: Monitor Docker events
docker events &

# Terminal 3: Create and manage a container
docker run -d --name lab-container nginx
docker stop lab-container
docker start lab-container
docker rm lab-container

# Observe the events in terminals 1 and 2
# See how Docker commands translate to containerd operations
```

### **Lab 2: Resource Limit Testing**

```bash
# Create container with strict limits
docker run -d --name resource-test \
  --memory=100m \
  --cpus="0.5" \
  --name resource-test \
  nginx

# Test memory limit
docker exec resource-test dd if=/dev/zero of=/tmp/bigfile bs=1M count=200

# Monitor resource usage
docker stats resource-test

# Clean up
docker stop resource-test
docker rm resource-test
```

### **Lab 3: Namespace Exploration**

```bash
# Create container and explore its namespaces
docker run -d --name namespace-test nginx
PID=$(docker inspect namespace-test --format '{{.State.Pid}}')

# Compare namespaces between host and container
echo "Host namespaces:"
ls -la /proc/self/ns/

echo "Container namespaces:"
sudo ls -la /proc/$PID/ns/

# Check if they're different (they should be)
sudo readlink /proc/self/ns/pid
sudo readlink /proc/$PID/ns/pid

# Clean up
docker stop namespace-test
docker rm namespace-test
```

---

## 📊 Runtime Knowledge Assessment

### **Conceptual Understanding**
- [ ] Can explain the difference between Docker Engine, containerd, and runc
- [ ] Understands the role of containerd-shim in process management
- [ ] Knows how Linux namespaces provide container isolation
- [ ] Comprehends how cgroups enforce resource limits
- [ ] Can describe the OCI specification and its importance

### **Practical Skills**
- [ ] Can inspect containers at the containerd level
- [ ] Knows how to monitor runtime performance
- [ ] Can debug container startup issues using runtime tools
- [ ] Understands how to optimize runtime configuration
- [ ] Can trace container lifecycle events

### **E-Commerce Application**
- [ ] Has optimized e-commerce containers at runtime level
- [ ] Implemented runtime monitoring for production services
- [ ] Can troubleshoot performance issues using runtime knowledge
- [ ] Understands security implications of runtime configuration

---

## 🚀 Next Steps: Applying Runtime Knowledge

### **Immediate Applications**
1. **Performance Optimization**: Use runtime knowledge to optimize your e-commerce services
2. **Debugging Skills**: Troubleshoot issues at the runtime level
3. **Security Hardening**: Apply runtime security best practices
4. **Monitoring Enhancement**: Implement runtime-level monitoring

### **Advanced Topics Coming Next**
- **Advanced Container Networking**: How network namespaces enable complex networking
- **Container Security Hardening**: Using runtime security features
- **Performance Engineering**: Runtime-level performance optimization
- **Custom Runtime Development**: Building specialized container runtimes

---

## ✅ Key Takeaways

### **Mental Model Shift**
```
Before: "Docker runs containers"
After: "Docker CLI → dockerd → containerd → runc → Linux kernel features"
```

### **Practical Benefits**
- **Faster Troubleshooting**: Know where to look when things go wrong
- **Better Performance**: Optimize at the right level
- **Enhanced Security**: Understand the security boundaries
- **Production Confidence**: Know exactly what's happening in your systems

### **Career Impact**
This runtime knowledge puts you in the top 10% of Docker users. You can now:
- Debug issues others can't solve
- Optimize performance at levels others don't know exist
- Design secure, production-ready container architectures
- Lead technical discussions about container platforms

**Continue to Advanced Container Networking** where you'll apply this runtime knowledge to build sophisticated networking solutions for your e-commerce platform.
                    {Type: oci.IPCNamespace},
                    {Type: oci.UTSNamespace},
                    {Type: oci.MountNamespace},
                },
            },
        },
    })

    // Create container
    container, err := client.NewContainer(ctx, "nginx-advanced",
        containerd.WithImage(image),
        containerd.WithNewSnapshot("nginx-snapshot", image),
        containerd.WithNewSpec(oci.WithImageConfig(image), oci.WithHostNamespace(oci.NetworkNamespace)),
    )
    if err != nil {
        log.Fatal(err)
    }
    defer container.Delete(ctx, containerd.WithSnapshotCleanup)

    // Create task (what actually runs)
    task, err := container.NewTask(ctx, cio.NewCreator(cio.WithStdio))
    if err != nil {
        log.Fatal(err)
    }
    defer task.Delete(ctx)

    // Start container
    if err := task.Start(ctx); err != nil {
        log.Fatal(err)
    }

    fmt.Printf("Container started with PID: %d\n", task.Pid())

    // Wait for container to exit
    exitStatusC, err := task.Wait(ctx)
    if err != nil {
        log.Fatal(err)
    }

    // Stop container after 30 seconds
    time.Sleep(30 * time.Second)
    if err := task.Kill(ctx, syscall.SIGTERM); err != nil {
        log.Fatal(err)
    }

    status := <-exitStatusC
    fmt.Printf("Container exited with status: %d\n", status.ExitCode())
}

func int64Ptr(i int64) *int64   { return &i }
func uint64Ptr(i uint64) *uint64 { return &i }
```

### Advanced containerd Configuration
```toml
# /etc/containerd/config.toml - Production-grade configuration
version = 2

# Root directory for persistent data
root = "/var/lib/containerd"
state = "/run/containerd"
temp = ""
plugin_dir = ""
disabled_plugins = []
required_plugins = []
oom_score = 0

# gRPC configuration
[grpc]
  address = "/run/containerd/containerd.sock"
  tcp_address = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

# Metrics configuration for production monitoring
[metrics]
  address = "127.0.0.1:1338"
  grpc_histogram = false

# Plugin configurations
[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"

  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    sandbox_image = "k8s.gcr.io/pause:3.6"
    stats_collect_period = 10
    systemd_cgroup = false
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    unset_seccomp_profile = ""
    tolerate_missing_hugetlb_controller = true
    disable_hugetlb_controller = true
    ignore_image_defined_volumes = false

    # Advanced registry configuration
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry-1.docker.io"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."private-registry.company.com"]
          endpoint = ["https://private-registry.company.com"]
      
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."private-registry.company.com".tls]
          cert_file = "/etc/containerd/certs/client.crt"
          key_file = "/etc/containerd/certs/client.key"
          ca_file = "/etc/containerd/certs/ca.crt"
        [plugins."io.containerd.grpc.v1.cri".registry.configs."private-registry.company.com".auth]
          username = "registry-user"
          password = "registry-password"

  # Snapshotter configuration for performance
  [plugins."io.containerd.snapshotter.v1.overlayfs"]
    root_path = ""
    upperdir_label = false
    mount_options = []
    sync_remove = false

  # Content store configuration
  [plugins."io.containerd.content.v1.content"]
    gc_ref_threshold = 1
```

## ⚡ runc Deep Dive

### OCI Runtime Specification Implementation
```bash
# Create OCI bundle manually (what runc uses)
mkdir -p /tmp/mycontainer/rootfs

# Extract container filesystem
docker export $(docker create nginx:alpine) | tar -C /tmp/mycontainer/rootfs -xf -

# Generate OCI spec
cd /tmp/mycontainer
runc spec

# Customize config.json for advanced features
cat > config.json << 'EOF'
{
    "ociVersion": "1.0.2",
    "process": {
        "terminal": false,
        "user": {
            "uid": 0,
            "gid": 0
        },
        "args": ["nginx", "-g", "daemon off;"],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "NGINX_VERSION=1.21.6"
        ],
        "cwd": "/",
        "capabilities": {
            "bounding": [
                "CAP_AUDIT_WRITE",
                "CAP_KILL",
                "CAP_NET_BIND_SERVICE"
            ],
            "effective": [
                "CAP_AUDIT_WRITE",
                "CAP_KILL",
                "CAP_NET_BIND_SERVICE"
            ],
            "inheritable": [
                "CAP_AUDIT_WRITE",
                "CAP_KILL",
                "CAP_NET_BIND_SERVICE"
            ],
            "permitted": [
                "CAP_AUDIT_WRITE",
                "CAP_KILL",
                "CAP_NET_BIND_SERVICE"
            ]
        },
        "rlimits": [
            {
                "type": "RLIMIT_NOFILE",
                "hard": 1024,
                "soft": 1024
            }
        ],
        "noNewPrivileges": true
    },
    "root": {
        "path": "rootfs",
        "readonly": false
    },
    "hostname": "nginx-container",
    "mounts": [
        {
            "destination": "/proc",
            "type": "proc",
            "source": "proc"
        },
        {
            "destination": "/dev",
            "type": "tmpfs",
            "source": "tmpfs",
            "options": [
                "nosuid",
                "strictatime",
                "mode=755",
                "size=65536k"
            ]
        },
        {
            "destination": "/sys",
            "type": "sysfs",
            "source": "sysfs",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "ro"
            ]
        }
    ],
    "linux": {
        "resources": {
            "devices": [
                {
                    "allow": false,
                    "access": "rwm"
                }
            ],
            "memory": {
                "limit": 134217728,
                "reservation": 67108864
            },
            "cpu": {
                "quota": 50000,
                "period": 100000,
                "cpus": "0-1"
            },
            "blockIO": {
                "weight": 10,
                "leafWeight": 10,
                "weightDevice": [
                    {
                        "major": 8,
                        "minor": 0,
                        "weight": 500,
                        "leafWeight": 300
                    }
                ],
                "throttleReadBpsDevice": [
                    {
                        "major": 8,
                        "minor": 0,
                        "rate": 104857600
                    }
                ]
            }
        },
        "namespaces": [
            {
                "type": "pid"
            },
            {
                "type": "network"
            },
            {
                "type": "ipc"
            },
            {
                "type": "uts"
            },
            {
                "type": "mount"
            }
        ],
        "maskedPaths": [
            "/proc/acpi",
            "/proc/asound",
            "/proc/kcore",
            "/proc/keys",
            "/proc/latency_stats",
            "/proc/timer_list",
            "/proc/timer_stats",
            "/proc/sched_debug",
            "/sys/firmware",
            "/proc/scsi"
        ],
        "readonlyPaths": [
            "/proc/bus",
            "/proc/fs",
            "/proc/irq",
            "/proc/sys",
            "/proc/sysrq-trigger"
        ]
    }
}
EOF

# Run container with runc directly
sudo runc run mycontainer
```

## 🛠️ Building Custom Container Runtime

### Minimal Container Runtime in Go
```go
// custom-runtime.go - Build your own container runtime
package main

import (
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "syscall"
    "log"
)

func main() {
    switch os.Args[1] {
    case "run":
        run()
    case "child":
        child()
    default:
        panic("Invalid command")
    }
}

func run() {
    fmt.Printf("Running %v as PID %d\n", os.Args[2:], os.Getpid())

    cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    // Create new namespaces
    cmd.SysProcAttr = &syscall.SysProcAttr{
        Cloneflags: syscall.CLONE_NEWUTS | 
                   syscall.CLONE_NEWPID | 
                   syscall.CLONE_NEWNS |
                   syscall.CLONE_NEWNET |
                   syscall.CLONE_NEWIPC,
        Unshareflags: syscall.CLONE_NEWNS,
    }

    must(cmd.Run())
}

func child() {
    fmt.Printf("Running %v as PID %d\n", os.Args[2:], os.Getpid())

    // Setup cgroups for resource control
    cg()

    // Change hostname
    must(syscall.Sethostname([]byte("container")))

    // Change root filesystem
    must(syscall.Chroot("/tmp/container-root"))
    must(os.Chdir("/"))

    // Mount proc filesystem
    must(syscall.Mount("proc", "proc", "proc", 0, ""))

    // Execute the command
    cmd := exec.Command(os.Args[2], os.Args[3:]...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    must(cmd.Run())

    // Cleanup
    must(syscall.Unmount("proc", 0))
}

func cg() {
    cgroups := "/sys/fs/cgroup/"
    pids := filepath.Join(cgroups, "pids")
    
    // Create cgroup directory
    os.Mkdir(filepath.Join(pids, "container"), 0755)
    
    // Set PID limit
    must(os.WriteFile(filepath.Join(pids, "container/pids.max"), []byte("20"), 0700))
    
    // Add current process to cgroup
    must(os.WriteFile(filepath.Join(pids, "container/cgroup.procs"), 
                     []byte(fmt.Sprintf("%d", os.Getpid())), 0700))
}

func must(err error) {
    if err != nil {
        log.Fatal(err)
    }
}
```

### Advanced Runtime with Security Features
```go
// secure-runtime.go - Production-grade security features
package main

import (
    "fmt"
    "os"
    "os/exec"
    "syscall"
    "unsafe"
    "golang.org/x/sys/unix"
)

// Seccomp filter to restrict system calls
func setupSeccomp() error {
    // Allow only essential system calls
    allowedSyscalls := []int{
        unix.SYS_READ,
        unix.SYS_WRITE,
        unix.SYS_OPEN,
        unix.SYS_CLOSE,
        unix.SYS_STAT,
        unix.SYS_FSTAT,
        unix.SYS_LSTAT,
        unix.SYS_MMAP,
        unix.SYS_MUNMAP,
        unix.SYS_BRK,
        unix.SYS_RT_SIGACTION,
        unix.SYS_RT_SIGPROCMASK,
        unix.SYS_IOCTL,
        unix.SYS_ACCESS,
        unix.SYS_EXIT,
        unix.SYS_EXIT_GROUP,
    }

    // Create seccomp filter
    filter := unix.SockFilter{
        Code: unix.BPF_LD | unix.BPF_W | unix.BPF_ABS,
        Jt:   0,
        Jf:   0,
        K:    4, // offsetof(struct seccomp_data, nr)
    }

    prog := unix.SockFprog{
        Len:    1,
        Filter: (*unix.SockFilter)(unsafe.Pointer(&filter)),
    }

    return unix.Prctl(unix.PR_SET_SECCOMP, unix.SECCOMP_MODE_FILTER, 
                     uintptr(unsafe.Pointer(&prog)), 0, 0)
}

// Drop capabilities for security
func dropCapabilities() error {
    // Keep only essential capabilities
    keepCaps := []uintptr{
        unix.CAP_NET_BIND_SERVICE,
        unix.CAP_SETUID,
        unix.CAP_SETGID,
    }

    // Clear all capabilities first
    for i := 0; i <= 37; i++ {
        if err := unix.Prctl(unix.PR_CAPBSET_DROP, uintptr(i), 0, 0, 0); err != nil {
            return err
        }
    }

    // Set only required capabilities
    for _, cap := range keepCaps {
        if err := unix.Prctl(unix.PR_CAP_AMBIENT, unix.PR_CAP_AMBIENT_RAISE, cap, 0, 0); err != nil {
            return err
        }
    }

    return nil
}

func secureChild() {
    fmt.Printf("Secure container starting as PID %d\n", os.Getpid())

    // Setup security features
    if err := setupSeccomp(); err != nil {
        fmt.Printf("Failed to setup seccomp: %v\n", err)
    }

    if err := dropCapabilities(); err != nil {
        fmt.Printf("Failed to drop capabilities: %v\n", err)
    }

    // Set no new privileges
    if err := unix.Prctl(unix.PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0); err != nil {
        fmt.Printf("Failed to set no new privs: %v\n", err)
    }

    // Continue with container setup...
    child()
}
```

## 📊 Performance Profiling & Optimization

### Runtime Performance Analysis
```bash
#!/bin/bash
# runtime-profiler.sh - Analyze container runtime performance

# Function to measure container startup time
measure_startup_time() {
    local runtime=$1
    local image=$2
    local iterations=${3:-10}
    
    echo "Measuring startup time for $runtime with $image ($iterations iterations)"
    
    total_time=0
    for i in $(seq 1 $iterations); do
        start_time=$(date +%s%N)
        
        case $runtime in
            "docker")
                container_id=$(docker run -d --rm $image sleep 1)
                docker wait $container_id > /dev/null
                ;;
            "containerd")
                ctr run --rm docker.io/library/$image test-$i sleep 1
                ;;
            "runc")
                # Assuming OCI bundle is prepared
                runc run test-$i
                ;;
        esac
        
        end_time=$(date +%s%N)
        duration=$((end_time - start_time))
        total_time=$((total_time + duration))
        
        echo "Iteration $i: ${duration}ns"
    done
    
    average=$((total_time / iterations))
    echo "Average startup time: ${average}ns ($(echo "scale=3; $average/1000000" | bc)ms)"
}

# Memory usage analysis
analyze_memory_usage() {
    local container_id=$1
    
    echo "Analyzing memory usage for container $container_id"
    
    # Get cgroup memory stats
    cgroup_path="/sys/fs/cgroup/memory/docker/$container_id"
    
    if [ -d "$cgroup_path" ]; then
        echo "Memory usage: $(cat $cgroup_path/memory.usage_in_bytes) bytes"
        echo "Memory limit: $(cat $cgroup_path/memory.limit_in_bytes) bytes"
        echo "Memory stats:"
        cat $cgroup_path/memory.stat | head -10
    fi
    
    # Process-level analysis
    pid=$(docker inspect -f '{{.State.Pid}}' $container_id)
    if [ "$pid" != "0" ]; then
        echo "Process memory info:"
        cat /proc/$pid/status | grep -E "(VmSize|VmRSS|VmData|VmStk|VmExe)"
    fi
}

# CPU performance analysis
analyze_cpu_performance() {
    local container_id=$1
    local duration=${2:-30}
    
    echo "Analyzing CPU performance for $duration seconds"
    
    # Start performance monitoring
    perf record -g -p $(docker inspect -f '{{.State.Pid}}' $container_id) sleep $duration
    
    # Generate report
    perf report --stdio > cpu_analysis_$container_id.txt
    echo "CPU analysis saved to cpu_analysis_$container_id.txt"
}

# I/O performance analysis
analyze_io_performance() {
    local container_id=$1
    
    echo "Analyzing I/O performance"
    
    # Monitor I/O using iotop
    iotop -a -o -d 1 -n 10 -p $(docker inspect -f '{{.State.Pid}}' $container_id)
    
    # Block device statistics
    iostat -x 1 10
}

# Network performance analysis
analyze_network_performance() {
    local container_id=$1
    
    echo "Analyzing network performance"
    
    # Get network namespace
    pid=$(docker inspect -f '{{.State.Pid}}' $container_id)
    netns_path="/proc/$pid/ns/net"
    
    # Network statistics
    nsenter -t $pid -n netstat -i
    nsenter -t $pid -n ss -tuln
    
    # Bandwidth testing (if iperf3 is available)
    if command -v iperf3 &> /dev/null; then
        echo "Running network bandwidth test..."
        docker exec $container_id iperf3 -c iperf.he.net -t 10
    fi
}

# Main execution
if [ $# -lt 2 ]; then
    echo "Usage: $0 <command> <container_id_or_image>"
    echo "Commands: startup, memory, cpu, io, network"
    exit 1
fi

command=$1
target=$2

case $command in
    "startup")
        measure_startup_time docker $target
        ;;
    "memory")
        analyze_memory_usage $target
        ;;
    "cpu")
        analyze_cpu_performance $target
        ;;
    "io")
        analyze_io_performance $target
        ;;
    "network")
        analyze_network_performance $target
        ;;
    *)
        echo "Unknown command: $command"
        exit 1
        ;;
esac
```

### Advanced Performance Tuning
```bash
# performance-tuning.sh - Optimize container runtime performance

# Optimize containerd configuration
optimize_containerd() {
    cat > /etc/containerd/config.toml << 'EOF'
version = 2

# Performance optimizations
[grpc]
  max_recv_message_size = 67108864  # 64MB
  max_send_message_size = 67108864  # 64MB

[plugins."io.containerd.gc.v1.scheduler"]
  pause_threshold = 0.02
  deletion_threshold = 0
  mutation_threshold = 100
  schedule_delay = "0s"
  startup_delay = "100ms"

# Snapshotter optimizations
[plugins."io.containerd.snapshotter.v1.overlayfs"]
  sync_remove = false
  mount_options = ["noatime", "nodiratime"]

# CRI optimizations
[plugins."io.containerd.grpc.v1.cri"]
  max_concurrent_downloads = 10
  max_container_log_line_size = 65536
EOF

    systemctl restart containerd
}

# Kernel parameter tuning for containers
tune_kernel_parameters() {
    cat > /etc/sysctl.d/99-container-performance.conf << 'EOF'
# Network performance
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_tw_buckets = 400000

# Memory management
vm.swappiness = 1
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# File system
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512

# Process limits
kernel.pid_max = 4194304
kernel.threads-max = 4194304
EOF

    sysctl -p /etc/sysctl.d/99-container-performance.conf
}

# Optimize Docker daemon
optimize_docker_daemon() {
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'EOF'
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-shm-size": "128M",
  "userland-proxy": false,
  "experimental": true,
  "metrics-addr": "127.0.0.1:9323",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  }
}
EOF

    systemctl restart docker
}

echo "Applying performance optimizations..."
optimize_containerd
tune_kernel_parameters
optimize_docker_daemon
echo "Performance tuning completed!"
```

This is just the beginning of Module 7! This first file establishes the foundation with deep runtime architecture knowledge that 99% of developers never learn. The module will continue with equally advanced and unique content across all 17 files.
