# 📦 **Module 1: Container Fundamentals Review**
## Deep Dive into Containerization for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 4-5 hours (enhanced with complete foundational knowledge)  
**Prerequisites**: See detailed prerequisites below  
**Learning Objectives**: Master container fundamentals essential for Kubernetes with complete foundational knowledge

---

## 🎯 **Detailed Prerequisites**

### **🔧 Technical Prerequisites**

#### **System Requirements**
- **OS**: Linux (Ubuntu 20.04+ recommended), macOS 10.15+, or Windows 10+ with WSL2
- **RAM**: Minimum 4GB (8GB recommended for comfortable container operations)
- **CPU**: 2+ cores (4+ cores recommended for multi-container applications)
- **Storage**: 20GB+ free space (50GB+ for image storage and container operations)
- **Network**: Stable internet connection for image pulls and registry access

#### **Software Requirements**
- **Docker Engine**: Version 20.10+ (latest stable recommended)
  ```bash
  # Install Docker Engine on Ubuntu
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
  # Log out and back in for group changes to take effect
  ```
- **Docker Compose**: Version 2.0+ (included with Docker Desktop)
  ```bash
  # Verify Docker Compose installation
  docker compose version
  # Expected: Docker Compose version v2.x.x
  ```
- **Git**: Version 2.0+ for version control and cloning repositories
  ```bash
  # Install Git
  sudo apt-get install -y git
  git --version
  ```

#### **Package Dependencies**
- **Container Tools**: Docker CLI, containerd, runc
  ```bash
  # Verify container tools
  docker --version
  containerd --version
  runc --version
  ```
- **Build Tools**: Make, build-essential for building custom images
  ```bash
  # Install build tools
  sudo apt-get install -y make build-essential
  make --version
  gcc --version
  ```
- **Network Tools**: curl, wget for downloading and testing
  ```bash
  # Verify network tools
  curl --version
  wget --version
  ```

#### **Network Requirements**
- **Internet Access**: For pulling base images and accessing container registries
- **Registry Access**: Access to Docker Hub, Google Container Registry, or other registries
- **Port Access**: Ensure these ports are available for container networking:
  - `80/443`: HTTP/HTTPS for web applications
  - `3000-9000`: Common application ports
  - `2376`: Docker daemon API (if using remote access)
- **Firewall Configuration**: Allow Docker daemon and container traffic
  ```bash
  # Check Docker daemon status
  sudo systemctl status docker
  # Check Docker network
  docker network ls
  ```

### **📖 Knowledge Prerequisites**

#### **Required Module Completion**
- **Module 0**: Essential Linux Commands - File operations, process management, text processing, system navigation

#### **Concepts to Master**
- **Virtualization Basics**: Understanding of VMs, hypervisors, and resource isolation
- **Linux Fundamentals**: File systems, processes, networking, and system administration
- **Application Packaging**: Understanding of how applications are packaged and deployed
- **Network Concepts**: Basic understanding of TCP/IP, ports, and network protocols
- **File System Concepts**: Understanding of directories, files, permissions, and mounts

#### **Skills Required**
- **Linux Command Line**: Proficiency with basic Linux commands from Module 0
- **File System Navigation**: Ability to navigate and manage files and directories
- **Process Management**: Understanding of running processes and system resources
- **Network Troubleshooting**: Basic network connectivity testing and debugging
- **Text Editing**: Ability to create and edit configuration files

#### **Industry Knowledge**
- **Application Development**: Basic understanding of how applications are built and deployed
- **DevOps Concepts**: Understanding of development and operations workflows
- **Infrastructure as Code**: Basic concepts of infrastructure automation
- **Microservices**: Understanding of distributed application architecture

### **🛠️ Environment Prerequisites**

#### **Development Environment**
- **Text Editor**: VS Code, Vim, or Nano with Dockerfile and YAML support
- **Terminal**: Bash shell with Docker completion enabled
- **IDE Extensions**: Docker extension for VS Code (recommended)
  ```bash
  # Install VS Code Docker extension (if using VS Code)
  code --install-extension ms-azuretools.vscode-docker
  ```

#### **Testing Environment**
- **Docker Daemon**: Running and accessible
  ```bash
  # Verify Docker daemon
  docker info
  docker run hello-world
  ```
- **Container Registry Access**: Docker Hub account or access to private registry
  ```bash
  # Test registry access
  docker pull hello-world
  docker images
  ```
- **Sample Applications**: Access to sample applications for practice
- **Network Access**: Ability to test container networking and connectivity

#### **Production Environment**
- **Security Configuration**: Understanding of container security best practices
- **Resource Management**: Knowledge of CPU and memory limits for containers
- **Logging and Monitoring**: Basic understanding of container logging and monitoring
- **Backup and Recovery**: Understanding of container data persistence and backup

### **📋 Validation Prerequisites**

#### **Pre-Module Assessment**
```bash
# 1. Verify Docker installation and functionality
docker --version
docker info
docker run hello-world

# 2. Verify Docker Compose functionality
docker compose version
docker compose --help

# 3. Verify system resources
free -h
df -h
nproc

# 4. Verify network connectivity
ping -c 3 docker.io
curl -I https://hub.docker.com

# 5. Verify Linux command proficiency (from Module 0)
ls -la
ps aux | head -5
netstat -tuln | head -5
```

#### **Setup Validation Commands**
```bash
# Create Docker practice environment
mkdir -p ~/docker-practice
cd ~/docker-practice

# Test Docker image building
cat > Dockerfile <<EOF
FROM alpine:latest
RUN echo "Hello from Docker!" > /hello.txt
CMD ["cat", "/hello.txt"]
EOF

# Build and run test image
docker build -t test-image .
docker run test-image

# Test Docker Compose
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
EOF

# Test Docker Compose
docker compose up -d
docker compose ps
docker compose down

# Cleanup
docker rmi test-image
rm -rf ~/docker-practice
```

#### **Troubleshooting Common Issues**
- **Docker Daemon Not Running**: Start Docker service and check permissions
- **Permission Denied**: Add user to docker group and restart session
- **Image Pull Failures**: Check network connectivity and registry access
- **Port Conflicts**: Check for existing services using required ports
- **Resource Constraints**: Verify sufficient RAM and disk space

#### **Alternative Options**
- **Docker Desktop**: For Windows and macOS users
- **Podman**: Docker alternative with rootless containers
- **Containerd**: Lower-level container runtime
- **Cloud Providers**: AWS ECS, Google Cloud Run, Azure Container Instances

### **🚀 Quick Start Checklist**

Before starting this module, ensure you have:

- [ ] **Docker Engine 20.10+** installed and running (`docker --version`)
- [ ] **Docker Compose 2.0+** installed (`docker compose version`)
- [ ] **4GB+ RAM** available for container operations
- [ ] **20GB+ disk space** for images and containers
- [ ] **Internet connection** for image pulls and registry access
- [ ] **Linux command proficiency** from Module 0 completion
- [ ] **Docker daemon** running and accessible (`docker info`)
- [ ] **User in docker group** for non-root Docker access
- [ ] **Text editor** with Dockerfile and YAML support
- [ ] **Basic virtualization concepts** understanding

### **⚠️ Important Notes**

- **Resource Requirements**: Containers require significant system resources. Ensure adequate RAM and storage.
- **Security Considerations**: Understand container security implications and best practices.
- **Network Configuration**: Containers create virtual networks. Understand port mapping and networking.
- **Data Persistence**: Container data is ephemeral by default. Plan for data persistence strategies.
- **Image Management**: Container images can consume significant disk space. Implement cleanup strategies.

### **🎯 Success Criteria**

By the end of this module, you should be able to:
- Build and run Docker containers from images and Dockerfiles
- Create multi-container applications using Docker Compose
- Optimize container images for size and security
- Manage container lifecycle and debugging
- Understand container networking and storage concepts
- Implement container security best practices
- Troubleshoot common container issues

---

### **🛠️ Tools Covered**
- **Docker**: Container runtime and image building
- **Docker Compose**: Multi-container application orchestration
- **Dockerfile**: Container image definition and optimization
- **Container Registry**: Image storage and distribution
- **Docker CLI**: Container management and debugging

### **🏭 Industry Tools**
- **Podman**: Docker alternative with rootless containers
- **containerd**: Industry-standard container runtime
- **Buildah**: Container image building without Docker daemon
- **Skopeo**: Container image inspection and copying
- **Docker Desktop**: GUI-based container management
- **Portainer**: Web-based container management interface
- **Rancher**: Container orchestration platform
- **Harbor**: Enterprise container registry
- **Quay**: Red Hat's container registry
- **Amazon ECR**: AWS container registry
- **Google Container Registry**: GCP container registry
- **Azure Container Registry**: Microsoft's container registry

### **🌍 Environment Strategy**
This module prepares containers for deployment across three environments:
- **DEV**: Development containers with debugging tools
- **UAT**: User Acceptance Testing containers with production-like configuration
- **PROD**: Production-optimized containers with security hardening

### **💥 Chaos Engineering**
- **Container restart policies**: Testing application resilience to container failures
- **Resource constraint simulation**: Testing behavior under memory/CPU limits
- **Network partition testing**: Simulating network connectivity issues
- **Storage failure simulation**: Testing data persistence and recovery

---

## 🌍 **Environment-Specific Container Configurations**

### **Development Environment (DEV)**
```dockerfile
# Development Dockerfile with debugging tools
FROM python:3.11-slim as dev

# Install development tools
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    htop \
    strace \
    && rm -rf /var/lib/apt/lists/*

# Enable debug mode
ENV DEBUG=true
ENV LOG_LEVEL=debug

# Install development dependencies
COPY backend/requirements-dev.txt /tmp/requirements-dev.txt
RUN pip install -r /tmp/requirements-dev.txt

# Expose debug port
EXPOSE 5678
```

### **UAT Environment (User Acceptance Testing)**
```dockerfile
# UAT Dockerfile - production-like with testing tools
FROM python:3.11-slim as uat

# Install testing tools
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# UAT-specific environment
ENV DEBUG=false
ENV LOG_LEVEL=info
ENV ENVIRONMENT=uat

# Install testing dependencies
COPY backend/requirements-test.txt /tmp/requirements-test.txt
RUN pip install -r /tmp/requirements-test.txt
```

### **Production Environment (PROD)**
```dockerfile
# Production Dockerfile - optimized and secure
FROM python:3.11-slim as production

# Minimal runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Production environment
ENV DEBUG=false
ENV LOG_LEVEL=warning
ENV ENVIRONMENT=production

# Security hardening
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

---

## 🎯 **Learning Objectives**

By the end of this module, you will:
- Understand container architecture and lifecycle
- Master Docker commands and best practices
- Analyze your e-commerce application's containerization
- Optimize container images for production
- Understand container security fundamentals
- Apply container concepts to Kubernetes preparation

---

## 📚 **Complete Theory Section: Container Fundamentals**

### **Historical Context and Evolution**

#### **The Journey from Physical to Virtual to Containerized**

**Physical Servers Era (1990s-2000s)**:
- Each application required dedicated physical hardware
- **Problems**: Resource waste, slow deployment, hardware dependencies
- **Example**: E-commerce app needed dedicated web server, database server, load balancer

**Virtual Machines Era (2000s-2010s)**:
- Virtualization allowed multiple OS instances on single hardware
- **Benefits**: Better resource utilization, isolation, easier management
- **Problems**: Still heavy (full OS per VM), slow startup, resource overhead
- **Example**: VMware, Hyper-V, VirtualBox

**Container Era (2010s-Present)**:
- **Docker Revolution (2013)**: Made containers mainstream
- **Kubernetes (2014)**: Container orchestration platform
- **Cloud Native**: Containers + microservices + DevOps
- **Current**: Serverless, edge computing, AI/ML containers

### **Complete Container Architecture Deep Dive**

#### **What Are Containers?**

Containers are lightweight, portable, and self-contained units that package applications and their dependencies. Unlike virtual machines that virtualize entire operating systems, containers share the host OS kernel while providing isolated user spaces.

#### **Key Characteristics:**
- **Isolation**: Each container has its own filesystem, network, and process space
- **Portability**: Containers run consistently across different environments
- **Efficiency**: Share the host OS kernel, reducing resource overhead
- **Scalability**: Can be quickly started, stopped, and replicated

#### **Complete Linux Namespaces (All 7 Types)**

**1. PID Namespace (Process ID)**:
- **Purpose**: Isolates process ID space
- **Effect**: Containers see only their own processes
- **Real-world**: Container can't see host processes or other containers
- **Example**: `docker run --pid=host` bypasses this isolation

**2. Network Namespace**:
- **Purpose**: Isolates network interfaces, routing tables, firewall rules
- **Effect**: Each container has its own network stack
- **Real-world**: Container has its own IP address, ports, network interfaces
- **Example**: `docker run --network=host` shares host network

**3. Mount Namespace**:
- **Purpose**: Isolates filesystem mount points
- **Effect**: Container sees only its own filesystem
- **Real-world**: Container can't access host files unless explicitly mounted
- **Example**: `docker run -v /host/path:/container/path` creates mount

**4. UTS Namespace (Unix Timesharing System)**:
- **Purpose**: Isolates hostname and domain name
- **Effect**: Container can have different hostname than host
- **Real-world**: Container appears as different machine on network
- **Example**: `docker run --hostname=mycontainer` sets container hostname

**5. IPC Namespace (Inter-Process Communication)**:
- **Purpose**: Isolates System V IPC objects (message queues, semaphores, shared memory)
- **Effect**: Containers can't interfere with each other's IPC
- **Real-world**: Prevents containers from accessing shared memory of other containers
- **Example**: Used by database containers for shared memory

**6. User Namespace**:
- **Purpose**: Maps user IDs between host and container
- **Effect**: Container can run as root inside but non-root on host
- **Real-world**: Security enhancement - container root != host root
- **Example**: `docker run --user=1000:1000` runs as specific user

**7. Cgroup Namespace**:
- **Purpose**: Isolates control group hierarchy
- **Effect**: Container sees only its own cgroups
- **Real-world**: Container can't see or affect other containers' resource limits
- **Example**: Used for resource management and monitoring

#### **Complete Control Groups (cgroups) Deep Dive**

**What are cgroups?**:
- **Purpose**: Limit and monitor resource usage of process groups
- **History**: Introduced in Linux 2.6.24 (2008)
- **Current**: cgroups v2 (since Linux 4.5)

**Resource Controllers (All Types)**:

**1. CPU Controller**:
- **cpu**: Basic CPU scheduling
- **cpuacct**: CPU accounting
- **cpuset**: CPU and memory node assignment
- **Real-world**: Limit container to 2 CPU cores

**2. Memory Controller**:
- **memory**: Memory usage limits and accounting
- **Real-world**: Limit container to 512MB RAM

**3. I/O Controller**:
- **blkio**: Block I/O limits
- **Real-world**: Limit disk I/O bandwidth

**4. Network Controller**:
- **net_cls**: Network packet classification
- **net_prio**: Network priority
- **Real-world**: Prioritize network traffic

**5. Device Controller**:
- **devices**: Device access control
- **Real-world**: Allow/deny access to specific devices

**6. Freezer Controller**:
- **freezer**: Suspend/resume processes
- **Real-world**: Pause container for maintenance

**7. PIDs Controller**:
- **pids**: Limit number of processes
- **Real-world**: Prevent fork bombs

#### **Complete Container Security Model**

**Security Layers**:

**1. Kernel Security**:
- **Namespaces**: Process isolation
- **cgroups**: Resource isolation
- **Capabilities**: Privilege separation
- **Seccomp**: System call filtering
- **AppArmor/SELinux**: Mandatory access control

**2. Container Runtime Security**:
- **Image scanning**: Vulnerability detection
- **Runtime protection**: Behavioral monitoring
- **Network policies**: Traffic filtering
- **Secrets management**: Credential protection

**3. Host Security**:
- **Kernel hardening**: Security patches
- **Host isolation**: Container escape prevention
- **Resource limits**: DoS protection
- **Monitoring**: Anomaly detection

#### **Complete Container Networking Deep Dive**

**Network Drivers**:

**1. Bridge Network (Default)**:
- **Purpose**: Isolated network for containers
- **How it works**: Docker creates bridge interface, containers get virtual interfaces
- **Real-world**: Containers can communicate with each other and host
- **Example**: `docker network create mynetwork`

**2. Host Network**:
- **Purpose**: Container shares host network stack
- **How it works**: No network isolation, container uses host IP
- **Real-world**: Maximum performance, no port mapping needed
- **Example**: `docker run --network=host`

**3. None Network**:
- **Purpose**: No network access
- **How it works**: Container has no network interfaces
- **Real-world**: Completely isolated, manual network setup required
- **Example**: `docker run --network=none`

**4. Overlay Network**:
- **Purpose**: Multi-host container communication
- **How it works**: Encapsulates packets in VXLAN tunnels
- **Real-world**: Docker Swarm, Kubernetes networking
- **Example**: `docker network create --driver overlay myoverlay`

**5. Macvlan Network**:
- **Purpose**: Containers get MAC addresses on physical network
- **How it works**: Bypasses bridge, direct physical network access
- **Real-world**: Legacy applications requiring MAC addresses
- **Example**: `docker network create --driver macvlan`

#### **Complete Storage Drivers Deep Dive**

**Storage Drivers**:

**1. Overlay2 (Default)**:
- **Purpose**: Union filesystem for containers
- **How it works**: Layers filesystem changes on top of base image
- **Benefits**: Efficient storage, fast container creation
- **Real-world**: Most common driver for production

**2. Device Mapper**:
- **Purpose**: Block-level storage for containers
- **How it works**: Uses thin provisioning on loopback devices
- **Benefits**: Better for high I/O workloads
- **Real-world**: Enterprise environments with specific storage requirements

**3. Btrfs**:
- **Purpose**: Copy-on-write filesystem
- **How it works**: Uses Btrfs subvolumes for containers
- **Benefits**: Built-in snapshots, compression
- **Real-world**: Development environments, backup scenarios

**4. ZFS**:
- **Purpose**: Advanced filesystem with snapshots
- **How it works**: Uses ZFS datasets for containers
- **Benefits**: Compression, deduplication, snapshots
- **Real-world**: High-end storage systems

**5. AUFS (Legacy)**:
- **Purpose**: Union filesystem (deprecated)
- **How it works**: Multiple filesystem layers
- **Status**: Replaced by Overlay2
- **Real-world**: Older Docker installations

### **Container vs Virtual Machine**

| Aspect | Containers | Virtual Machines |
|--------|------------|------------------|
| **OS** | Share host OS kernel | Full OS per VM |
| **Size** | MBs (lightweight) | GBs (heavy) |
| **Startup Time** | Seconds | Minutes |
| **Resource Usage** | Low | High |
| **Isolation** | Process-level | Hardware-level |
| **Portability** | High | Medium |

### **Container Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Host Operating System                    │
├─────────────────────────────────────────────────────────────┤
│  Container Runtime (Docker/containerd)                     │
├─────────────────────────────────────────────────────────────┤
│  Container 1    │  Container 2    │  Container 3           │
│  ┌───────────┐  │  ┌───────────┐  │  ┌───────────┐         │
│  │   App     │  │  │   App     │  │  │   App     │         │
│  │   Libs    │  │  │   Libs    │  │  │   Libs    │         │
│  │   Runtime │  │  │   Runtime │  │  │   Runtime │         │
│  └───────────┘  │  └───────────┘  │  └───────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### **Container Lifecycle**

1. **Create**: Define container from image
2. **Start**: Begin execution
3. **Run**: Execute application
4. **Stop**: Gracefully terminate
5. **Remove**: Delete container instance

---

## 🛠️ **Complete Docker Command Reference with ALL Flags**

### **Docker Build Command - Complete Flag Reference**

```bash
# ALL AVAILABLE FLAGS (Complete Reference)
docker build [OPTIONS] PATH | URL | -

# Build Options:
--add-host <host:ip>           # Add custom host-to-IP mapping
--build-arg <key=value>        # Set build-time variables
--cache-from <image>           # Images to consider as cache sources
--cgroup-parent <path>         # Optional parent cgroup for the container
--compress                    # Compress the build context using gzip
--cpu-period <int>            # Limit the CPU CFS (Completely Fair Scheduler) period
--cpu-quota <int>             # Limit the CPU CFS (Completely Fair Scheduler) quota
--cpu-shares <int>            # CPU shares (relative weight)
--cpuset-cpus <string>        # CPUs in which to allow execution (0-3, 0,1)
--cpuset-mems <string>        # MEMs in which to allow execution (0-3, 0,1)
--disable-content-trust       # Skip image verification (default true)
--file, -f <string>           # Name of the Dockerfile (Default is 'PATH/Dockerfile')
--force-rm                    # Always remove intermediate containers
--iidfile <string>            # Write the image ID to the file
--isolation <string>          # Container isolation technology
--label <list>                # Set metadata for an image
--memory <bytes>              # Memory limit
--memory-swap <bytes>         # Swap limit equal to memory plus swap: '-1' to enable unlimited swap
--network <string>            # Set the networking mode for the RUN instructions during build
--no-cache                    # Do not use cache when building the image
--platform <string>           # Set platform if server is multi-platform capable
--progress <string>           # Set type of progress output (auto, plain, tty)
--pull                        # Always attempt to pull a newer version of the image
--quiet, -q                   # Suppress the build output and print image ID on success
--rm                          # Remove intermediate containers after a successful build (default true)
--secret <string>             # Secret file to expose to the build
--security-opt <list>         # Security options
--shm-size <bytes>            # Size of /dev/shm
--squash                      # Squash newly built layers into a single new layer
--ssh <string>                # SSH agent socket or keys to expose to the build
--stream                      # Stream attaches to server to negotiate build context
--tag, -t <name:tag>          # Name and optionally a tag in the 'name:tag' format
--target <string>             # Set the target build stage to build
--ulimit <list>               # Ulimit options
```

### **Docker Run Command - Complete Flag Reference**

```bash
# ALL AVAILABLE FLAGS (Complete Reference)
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

# Detach and Background:
-d, --detach                  # Run container in background and print container ID
--detach-keys <string>        # Override the key sequence for detaching a container

# Network Options:
--add-host <list>             # Add a custom host-to-IP mapping (host:ip)
--dns <list>                  # Set custom DNS servers
--dns-option <list>           # Set DNS options
--dns-search <list>           # Set custom DNS search domains
--expose <list>               # Expose a port or a range of ports
--ip <string>                 # IPv4 address (e.g., 172.30.100.104)
--ip6 <string>                # IPv6 address (e.g., 2001:db8::33)
--link <list>                 # Add link to another container
--link-local-ip <list>        # Container IPv4/IPv6 link-local addresses
--mac-address <string>        # Container MAC address (e.g., 92:d0:c6:0a:29:33)
--network <string>            # Connect a container to a network
--network-alias <list>        # Add network-scoped alias for the container
--publish, -p <list>          # Publish a container's port(s) to the host
--publish-all, -P             # Publish all exposed ports to random ports

# Restart Policies:
--restart <string>            # Restart policy to apply when a container exits

# Resource Management:
--blkio-weight <uint16>       # Block IO (relative weight), between 10 and 1000, or 0 to disable
--blkio-weight-device <list>  # Block IO weight (relative device weight)
--cpu-count <int>             # CPU count (Windows only)
--cpu-percent <int>           # CPU percent (Windows only)
--cpu-period <int>            # Limit CPU CFS (Completely Fair Scheduler) period
--cpu-quota <int>             # Limit CPU CFS (Completely Fair Scheduler) quota
--cpu-rt-period <int>         # Limit CPU real-time period in microseconds
--cpu-rt-runtime <int>        # Limit CPU real-time runtime in microseconds
--cpu-shares, -c <int>        # CPU shares (relative weight)
--cpus <decimal>              # Number of CPUs
--cpuset-cpus <string>        # CPUs in which to allow execution (0-3, 0,1)
--cpuset-mems <string>        # MEMs in which to allow execution (0-3, 0,1)
--kernel-memory <bytes>       # Kernel memory limit
--memory, -m <bytes>          # Memory limit
--memory-reservation <bytes>  # Memory soft limit
--memory-swap <bytes>         # Swap limit equal to memory plus swap: '-1' to enable unlimited swap
--memory-swappiness <int>     # Tune container memory swappiness (0 to 100)
--oom-kill-disable            # Disable OOM Killer
--oom-score-adj <int>         # Tune host's OOM preferences (-1000 to 1000)
--shm-size <bytes>            # Size of /dev/shm

# Security Options:
--cap-add <list>              # Add Linux capabilities
--cap-drop <list>             # Drop Linux capabilities
--device <list>               # Add a host device to the container
--device-cgroup-rule <list>   # Add a rule to the cgroup allowed devices list
--device-read-bps <list>      # Limit read rate (bytes per second) from a device
--device-read-iops <list>     # Limit read rate (IO per second) from a device
--device-write-bps <list>     # Limit write rate (bytes per second) to a device
--device-write-iops <list>    # Limit write rate (IO per second) to a device
--group-add <list>            # Add additional groups to join
--no-new-privileges           # Disable new privileges
--privileged                  # Give extended privileges to this container
--read-only                   # Mount the container's root filesystem as read only
--security-opt <list>         # Security Options
--tmpfs <list>                # Mount a tmpfs directory
--user, -u <string>           # Username or UID (format: <name|uid>[:<group|gid>])
--userns <string>             # User namespace to use
--uts <string>                # UTS namespace to use

# Environment Variables:
--env, -e <list>              # Set environment variables
--env-file <list>             # Read in a file of environment variables

# Volume Options:
--mount <list>                # Attach a filesystem mount to the container
--volume, -v <list>           # Bind mount a volume
--volumes-from <list>         # Mount volumes from the specified container(s)

# Working Directory and User:
--workdir, -w <string>        # Working directory inside the container

# Container Name and Hostname:
--hostname, -h <string>       # Container host name
--name <string>               # Assign a name to the container

# Interactive and TTY:
--interactive, -i             # Keep STDIN open even if not attached
--tty, -t                     # Allocate a pseudo-TTY

# Other Options:
--disable-content-trust       # Skip image verification (default true)
--domainname <string>         # Container NIS domain name
--entrypoint <string>         # Override the default ENTRYPOINT of the image
--health-cmd <string>         # Command to run to check health
--health-interval <duration>  # Time between running the check (ms|s|m|h) (default 0s)
--health-retries <int>        # Consecutive failures needed to report unhealthy
--health-start-period <duration> # Start period for the container to initialize before starting health-retries countdown (ms|s|m|h) (default 0s)
--health-timeout <duration>   # Maximum time to allow one check to run (ms|s|m|h) (default 0s)
--help                        # Print usage
--init                        # Run an init inside the container that forwards signals and reaps processes
--ipc <string>                # IPC mode to use
--isolation <string>          # Container isolation technology
--label <list>                # Set metadata on container
--label-file <list>           # Read in a line delimited file of labels
--log-driver <string>         # Logging driver for the container
--log-opt <list>              # Log driver options
--pid <string>                # PID namespace to use
--platform <string>           # Set platform if server is multi-platform capable
--rm                          # Automatically remove the container when it exits
--runtime <string>            # Runtime to use for this container
--sig-proxy                   # Proxy received signals to the process (default true)
--stop-signal <string>        # Signal to stop a container (default "SIGTERM")
--stop-timeout <int>          # Timeout (in seconds) to stop a container
--sysctl <list>               # Sysctl options
--ulimit <list>               # Ulimit options
```

### **Docker Images Command - Complete Flag Reference**

```bash
# ALL AVAILABLE FLAGS (Complete Reference)
docker images [OPTIONS] [REPOSITORY[:TAG]]

# Filter Options:
--filter, -f <filter>         # Filter output based on conditions provided
--format <string>             # Pretty-print images using a Go template
--no-trunc                    # Don't truncate output
--quiet, -q                   # Only show image IDs
--digests                     # Show digests
```

### **Docker PS Command - Complete Flag Reference**

```bash
# ALL AVAILABLE FLAGS (Complete Reference)
docker ps [OPTIONS]

# Filter Options:
--filter, -f <filter>         # Filter output based on conditions provided
--format <string>             # Pretty-print containers using a Go template
--no-trunc                    # Don't truncate output
--no-stream                   # Disable streaming stats and only pull the first result
--quiet, -q                   # Only display container IDs
--size, -s                    # Display total file sizes
```

### **Docker Logs Command - Complete Reference**

#### **1. Command Overview**
```bash
# Command: docker logs
# Purpose: Fetch and display logs from a running or stopped container
# Category: Container Operations
# Complexity: Beginner to Intermediate
# Real-world Usage: Container debugging, monitoring, troubleshooting
```

#### **2. Command Purpose and Context**
```bash
# What docker logs does:
# - Retrieves stdout and stderr logs from containers
# - Shows historical output from container processes
# - Essential for debugging and monitoring containerized applications
# - Works with both running and stopped containers

# When to use docker logs:
# - Debugging application issues in containers
# - Monitoring container application output
# - Troubleshooting container startup problems
# - Analyzing application behavior and errors
# - Real-time monitoring of container processes
# - Post-mortem analysis of failed containers

# Command relationships:
# - Often used with docker ps to identify container names/IDs
# - Complementary to docker exec for interactive debugging
# - Works with docker inspect for comprehensive container information
# - Used with grep/awk for log filtering and analysis
# - Combined with tail/head for log management
```

#### **3. Complete Flag Reference (ALL Available Flags)**
```bash
# ALL AVAILABLE FLAGS (Complete Reference)
docker logs [OPTIONS] CONTAINER

# Log Options:
--details                     # Show extra details provided to logs
--follow, -f                  # Follow log output
--since <string>              # Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
--tail, -n <string>           # Number of lines to show from the end of the logs (default "all")
--timestamps, -t              # Show timestamps
--until <string>              # Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
```

#### **4. Flag Discovery Methods**
```bash
# How to discover all available flags:

# Method 1: Built-in help
docker logs --help

# Method 2: Docker documentation
docker --help | grep logs

# Method 3: Online documentation
# Visit: https://docs.docker.com/engine/reference/commandline/logs/

# Method 4: Man pages (if available)
man docker-logs
```

#### **5. Structured Command Analysis Section**
```bash
#### **🔧 Command Analysis: docker logs -f --timestamps ecommerce-backend**

# Command Breakdown:
echo "Command: docker logs -f --timestamps ecommerce-backend"
echo "Purpose: Follow real-time logs from ecommerce backend container with timestamps"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker logs: Command to retrieve container logs"
echo "2. -f: Follow flag (stream live logs in real-time)"
echo "3. --timestamps: Add timestamps to each log line"
echo "4. ecommerce-backend: Container name to get logs from"
echo ""

# Expected output format:
echo "Expected Output Format:"
echo "2023-12-15T10:30:15.123456789Z [INFO] Starting e-commerce backend server"
echo "2023-12-15T10:30:15.456789123Z [INFO] Database connection established"
echo "2023-12-15T10:30:16.789123456Z [INFO] Server listening on port 8000"
echo "2023-12-15T10:30:17.123456789Z [DEBUG] Processing incoming request"
echo ""

# Output interpretation:
echo "Output Interpretation:"
echo "- Each line shows timestamp + log message"
echo "- Logs are displayed in chronological order"
echo "- -f flag keeps connection open for real-time streaming"
echo "- Use Ctrl+C to stop following logs"
echo "- Shows both stdout and stderr from container"
echo ""
```

#### **6. Real-time Examples with Input/Output Analysis**
```bash
# Example 1: Basic log retrieval
echo "=== EXAMPLE 1: Basic Log Retrieval ==="
docker logs ecommerce-backend
# Expected output: All logs from container start to current time
# - Shows complete log history
# - Useful for debugging startup issues
# - No real-time following

# Example 2: Follow logs in real-time
echo "=== EXAMPLE 2: Follow Logs in Real-time ==="
docker logs -f ecommerce-backend
# Expected output: Live streaming of new log entries
# - Streams new logs as they are generated
# - Essential for monitoring running applications
# - Use Ctrl+C to stop

# Example 3: Show recent logs with timestamps
echo "=== EXAMPLE 3: Recent Logs with Timestamps ==="
docker logs --tail 20 --timestamps ecommerce-backend
# Expected output: Last 20 log lines with timestamps
# - --tail 20 limits to last 20 lines
# - --timestamps adds time information
# - Useful for quick status checks
```

#### **7. Flag Exploration Exercises**
```bash
# Exercise 1: Explore different time filtering options
echo "=== FLAG EXPLORATION EXERCISE 1: Time Filtering ==="
echo "Testing different time filtering options:"
echo ""

echo "1. Logs since specific time:"
docker logs --since "2023-12-15T10:00:00" ecommerce-backend
echo ""

echo "2. Logs from last 30 minutes:"
docker logs --since "30m" ecommerce-backend
echo ""

echo "3. Logs until specific time:"
docker logs --until "2023-12-15T11:00:00" ecommerce-backend
echo ""

echo "4. Logs between time range:"
docker logs --since "1h" --until "30m" ecommerce-backend
echo ""
```

#### **8. Performance and Security Considerations**
```bash
# Performance Considerations:
echo "=== PERFORMANCE CONSIDERATIONS ==="
echo "1. Limit log output for large containers:"
echo "   - Use --tail to limit number of lines"
echo "   - Use --since to limit time range"
echo "   - Avoid following logs indefinitely in production"
echo ""

echo "2. Optimize for monitoring:"
echo "   - Use --timestamps for time correlation"
echo "   - Combine with external log management tools"
echo "   - Consider log rotation and retention policies"
echo ""

# Security Considerations:
echo "=== SECURITY CONSIDERATIONS ==="
echo "1. Be aware of sensitive information:"
echo "   - Logs may contain sensitive data"
echo "   - Be cautious when sharing log outputs"
echo "   - Consider log sanitization for external sharing"
echo ""

echo "2. Access control:"
echo "   - Only authorized users should access container logs"
echo "   - Use appropriate Docker socket permissions"
echo "   - Consider centralized logging for audit trails"
echo ""
```

#### **9. Troubleshooting Scenarios**
```bash
# Common Issues and Solutions:
echo "=== TROUBLESHOOTING SCENARIOS ==="
echo ""
echo "1. No logs displayed:"
echo "   Problem: docker logs shows no output"
echo "   Solution: Check if container exists and has generated logs"
echo "   Command: docker ps -a | grep container-name"
echo ""

echo "2. Container not found:"
echo "   Problem: 'Error: No such container: container-name'"
echo "   Solution: Verify container name or ID"
echo "   Command: docker ps -a"
echo ""

echo "3. Permission denied:"
echo "   Problem: 'Permission denied' when accessing logs"
echo "   Solution: Check Docker daemon permissions"
echo "   Command: sudo docker logs container-name"
echo ""

echo "4. Logs too large:"
echo "   Problem: Too many logs to display"
echo "   Solution: Use --tail or --since to limit output"
echo "   Command: docker logs --tail 100 container-name"
echo ""
```

### **Flag Discovery Methods**

```bash
# How to discover all available flags:

# Method 1: Built-in help
docker --help
docker build --help
docker run --help
docker images --help
docker ps --help
docker logs --help

# Method 2: Manual pages
man docker
man docker-build
man docker-run
man docker-images
man docker-ps
man docker-logs

# Method 3: Command-specific help
docker build -h
docker run -h
docker images -h
docker ps -h
docker logs -h

# Method 4: Online documentation
# Visit: https://docs.docker.com/engine/reference/commandline/
```

## 🔧 **Structured Command Analysis Sections**

### **Docker Build Command Analysis**

#### **🔧 Command Analysis: docker build -f Dockerfile.backend -t ecommerce-backend:latest .**

```bash
# Command Breakdown:
echo "Command: docker build -f Dockerfile.backend -t ecommerce-backend:latest ."
echo "Purpose: Build a Docker image from a Dockerfile with specific configuration"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker build: Command to build a Docker image from a Dockerfile"
echo "2. -f Dockerfile.backend: Specify the Dockerfile path (instead of default 'Dockerfile')"
echo "3. -t ecommerce-backend:latest: Tag the image with name 'ecommerce-backend' and tag 'latest'"
echo "4. .: Build context (current directory containing source code)"
echo ""

# Execute command with detailed output analysis:
echo "=== BUILDING ECOMMERCE BACKEND IMAGE ==="
docker build -f Dockerfile.backend -t ecommerce-backend:latest .
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output Format:"
echo "Sending build context to Docker daemon  2.048kB"
echo "Step 1/8 : FROM python:3.9-slim"
echo " ---> 1234567890ab"
echo "Step 2/8 : WORKDIR /app"
echo " ---> Running in abc123def456"
echo " ---> 7890123456cd"
echo "..."
echo "Successfully built 1234567890ab"
echo "Successfully tagged ecommerce-backend:latest"
echo ""
echo "Output Interpretation:"
echo "- Build context: Source code being sent to Docker daemon"
echo "- Step X/Y: Each instruction in the Dockerfile"
echo "- ---> Running in: Intermediate container ID"
echo "- ---> Final ID: Final layer ID after instruction"
echo "- Successfully built: Final image ID"
echo "- Successfully tagged: Image name and tag assigned"
echo ""
```

#### **🔧 Command Analysis: docker build --no-cache --build-arg VERSION=1.0.0 -t ecommerce-backend:v1.0.0 .**

```bash
# Command Breakdown:
echo "Command: docker build --no-cache --build-arg VERSION=1.0.0 -t ecommerce-backend:v1.0.0 ."
echo "Purpose: Build image without cache and with build-time variables"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker build: Build command"
echo "2. --no-cache: Ignore cache and rebuild all layers from scratch"
echo "3. --build-arg VERSION=1.0.0: Pass build-time variable to Dockerfile"
echo "4. -t ecommerce-backend:v1.0.0: Tag with specific version"
echo "5. .: Build context"
echo ""

# Execute command with detailed output analysis:
echo "=== BUILDING WITH BUILD ARGUMENTS ==="
docker build --no-cache --build-arg VERSION=1.0.0 -t ecommerce-backend:v1.0.0 .
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output:"
echo "Sending build context to Docker daemon  2.048kB"
echo "Step 1/8 : ARG VERSION"
echo " ---> Running in abc123def456"
echo "Step 2/8 : FROM python:3.9-slim"
echo " ---> 1234567890ab"
echo "..."
echo "Successfully built 1234567890ab"
echo "Successfully tagged ecommerce-backend:v1.0.0"
echo ""
echo "Output Interpretation:"
echo "- --no-cache: All layers rebuilt (no 'Using cache' messages)"
echo "- ARG VERSION: Build argument processed in Dockerfile"
echo "- Version-specific tag: Image tagged with version number"
echo ""
```

### **Docker Run Command Analysis**

#### **🔧 Command Analysis: docker run -d --name ecommerce-backend -p 8000:8000 ecommerce-backend:latest**

```bash
# Command Breakdown:
echo "Command: docker run -d --name ecommerce-backend -p 8000:8000 ecommerce-backend:latest"
echo "Purpose: Run a container in detached mode with port mapping and custom name"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker run: Command to create and start a new container"
echo "2. -d: Run container in detached mode (background)"
echo "3. --name ecommerce-backend: Assign custom name to container"
echo "4. -p 8000:8000: Map host port 8000 to container port 8000"
echo "5. ecommerce-backend:latest: Image to run (name:tag format)"
echo ""

# Execute command with detailed output analysis:
echo "=== RUNNING ECOMMERCE BACKEND CONTAINER ==="
docker run -d --name ecommerce-backend -p 8000:8000 ecommerce-backend:latest
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output:"
echo "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
echo ""
echo "Output Interpretation:"
echo "- Container ID: 64-character hexadecimal container identifier"
echo "- Detached mode: Container runs in background"
echo "- Port mapping: Host:container port binding established"
echo "- Custom name: Container accessible by name 'ecommerce-backend'"
echo ""

# Verify container is running:
echo "=== VERIFICATION ==="
docker ps --filter "name=ecommerce-backend"
echo ""
echo "Expected Output:"
echo "CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                    NAMES"
echo "1234567890ab  ecommerce-backend:latest \"python main.py\"        2 minutes ago   Up 2 minutes   0.0.0.0:8000->8000/tcp   ecommerce-backend"
echo ""
echo "Status Interpretation:"
echo "- STATUS: Up 2 minutes (container running for 2 minutes)"
echo "- PORTS: 0.0.0.0:8000->8000/tcp (port mapping active)"
echo "- NAMES: ecommerce-backend (custom name assigned)"
echo ""
```

#### **🔧 Command Analysis: docker run --rm -it --memory=100m --cpus=0.5 ecommerce-backend:latest /bin/bash**

```bash
# Command Breakdown:
echo "Command: docker run --rm -it --memory=100m --cpus=0.5 ecommerce-backend:latest /bin/bash"
echo "Purpose: Run interactive container with resource limits and auto-removal"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker run: Create and start container"
echo "2. --rm: Automatically remove container when it exits"
echo "3. -it: Interactive terminal (combines -i and -t flags)"
echo "4. --memory=100m: Limit container memory to 100 megabytes"
echo "5. --cpus=0.5: Limit container to 0.5 CPU cores"
echo "6. ecommerce-backend:latest: Image to run"
echo "7. /bin/bash: Override default command with bash shell"
echo ""

# Execute command with detailed output analysis:
echo "=== RUNNING INTERACTIVE CONTAINER WITH RESOURCE LIMITS ==="
docker run --rm -it --memory=100m --cpus=0.5 ecommerce-backend:latest /bin/bash
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output:"
echo "root@1234567890ab:/app# "
echo ""
echo "Output Interpretation:"
echo "- root@: Running as root user"
echo "- 1234567890ab: Container ID (first 12 characters)"
echo "- /app: Current working directory"
echo "- #: Root user prompt"
echo "- Interactive shell: Ready for commands"
echo ""
echo "Resource Limits Active:"
echo "- Memory: Limited to 100MB (container will be killed if exceeded)"
echo "- CPU: Limited to 0.5 cores (50% of one CPU core)"
echo "- Auto-removal: Container will be deleted when bash exits"
echo ""
```

### **Docker PS Command Analysis**

#### **🔧 Command Analysis: docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"**

```bash
# Command Breakdown:
echo "Command: docker ps -a --format \"table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}\""
echo "Purpose: List all containers with custom formatted output"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker ps: List containers command"
echo "2. -a: Show all containers (including stopped ones)"
echo "3. --format: Custom output format using Go template syntax"
echo "4. table: Display as table with headers"
echo "5. {{.Names}}: Container name field"
echo "6. {{.Status}}: Container status field"
echo "7. {{.Ports}}: Port mappings field"
echo "8. {{.Size}}: Container size field"
echo ""

# Execute command with detailed output analysis:
echo "=== LISTING ALL CONTAINERS WITH CUSTOM FORMAT ==="
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output:"
echo "NAMES              STATUS                    PORTS                    SIZE"
echo "ecommerce-backend  Up 5 minutes             0.0.0.0:8000->8000/tcp   1.2MB (virtual 150MB)"
echo "test-container     Exited (0) 2 hours ago                            0B (virtual 100MB)"
echo ""
echo "Output Interpretation:"
echo "- NAMES: Container names (easier to identify than container IDs)"
echo "- STATUS: Current state and uptime or exit information"
echo "- PORTS: Port mappings (host:container format)"
echo "- SIZE: Container size (actual size vs virtual image size)"
echo ""
echo "Status Types:"
echo "- Up X minutes: Container running for X minutes"
echo "- Exited (0): Container stopped with exit code 0 (success)"
echo "- Exited (1): Container stopped with exit code 1 (error)"
echo "- Created: Container created but not started"
echo "- Restarting: Container in restart loop"
echo ""
```

### **Docker Logs Command Analysis**

#### **🔧 Command Analysis: docker logs --tail=50 --timestamps ecommerce-backend**

```bash
# Command Breakdown:
echo "Command: docker logs --tail=50 --timestamps ecommerce-backend"
echo "Purpose: View last 50 log entries with timestamps for ecommerce-backend container"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. docker logs: Command to retrieve container logs"
echo "2. --tail=50: Show last 50 lines of logs"
echo "3. --timestamps: Include timestamps with each log entry"
echo "4. ecommerce-backend: Container name (can also use container ID)"
echo ""

# Execute command with detailed output analysis:
echo "=== RETRIEVING CONTAINER LOGS ==="
docker logs --tail=50 --timestamps ecommerce-backend
echo ""

echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output:"
echo "2024-01-15T10:30:15.123456789Z INFO: Application started successfully"
echo "2024-01-15T10:30:15.234567890Z INFO: Database connection established"
echo "2024-01-15T10:30:15.345678901Z INFO: Server listening on port 8000"
echo "2024-01-15T10:30:20.456789012Z INFO: GET /api/v1/products - 200 OK"
echo "2024-01-15T10:30:25.567890123Z INFO: GET /api/v1/categories - 200 OK"
echo ""
echo "Output Interpretation:"
echo "- Timestamp: ISO 8601 format with nanoseconds (Z indicates UTC)"
echo "- Log Level: INFO, WARN, ERROR, DEBUG levels"
echo "- Message: Application log message"
echo "- HTTP Logs: Request method, path, and response status"
echo ""
echo "Log Analysis Benefits:"
echo "- Timestamps: Track when events occurred"
echo "- Limited output: --tail prevents overwhelming output"
echo "- Container identification: Use name instead of long container ID"
echo ""
```

## 🚨 **Troubleshooting Scenarios**

### **Docker Build Troubleshooting**

#### **🔧 Common Build Issues and Solutions**

```bash
# Issue 1: Build context too large
echo "=== TROUBLESHOOTING: Build Context Too Large ==="
echo "Problem: 'build context is larger than 50MB'"
echo "Solution: Add .dockerignore file to exclude unnecessary files"
echo ""
echo "Create .dockerignore file:"
cat > .dockerignore << 'EOF'
node_modules
.git
.gitignore
README.md
.env
.nyc_output
coverage
.vscode
.idea
*.log
*.tmp
EOF
echo ""
echo "Verify .dockerignore is working:"
docker build --no-cache -t test-image . 2>&1 | grep "build context"
echo ""

# Issue 2: Permission denied during build
echo "=== TROUBLESHOOTING: Permission Denied ==="
echo "Problem: 'permission denied' during COPY or RUN commands"
echo "Solution: Check file permissions and use appropriate user"
echo ""
echo "Check file permissions:"
ls -la Dockerfile
echo ""
echo "Fix permissions if needed:"
chmod 644 Dockerfile
echo ""
echo "Use non-root user in Dockerfile:"
echo "FROM python:3.9-slim"
echo "RUN groupadd -r appuser && useradd -r -g appuser appuser"
echo "USER appuser"
echo ""

# Issue 3: Build cache issues
echo "=== TROUBLESHOOTING: Build Cache Issues ==="
echo "Problem: Changes not reflected in build"
echo "Solution: Use --no-cache flag or clear build cache"
echo ""
echo "Clear build cache:"
docker builder prune -f
echo ""
echo "Build without cache:"
docker build --no-cache -t ecommerce-backend:latest .
echo ""
```

### **Docker Run Troubleshooting**

#### **🔧 Common Runtime Issues and Solutions**

```bash
# Issue 1: Port already in use
echo "=== TROUBLESHOOTING: Port Already in Use ==="
echo "Problem: 'bind: address already in use'"
echo "Solution: Check for existing containers using the port"
echo ""
echo "Check what's using port 8000:"
docker ps --filter "publish=8000"
echo ""
echo "Alternative: Use different host port:"
docker run -d --name ecommerce-backend -p 8001:8000 ecommerce-backend:latest
echo ""

# Issue 2: Container exits immediately
echo "=== TROUBLESHOOTING: Container Exits Immediately ==="
echo "Problem: Container starts and immediately stops"
echo "Solution: Check container logs and ensure proper command"
echo ""
echo "Check container status:"
docker ps -a --filter "name=ecommerce-backend"
echo ""
echo "View container logs:"
docker logs ecommerce-backend
echo ""
echo "Run container interactively to debug:"
docker run -it --rm ecommerce-backend:latest /bin/bash
echo ""

# Issue 3: Out of memory
echo "=== TROUBLESHOOTING: Out of Memory ==="
echo "Problem: Container killed due to memory limit"
echo "Solution: Increase memory limit or optimize application"
echo ""
echo "Check system memory:"
free -h
echo ""
echo "Run with increased memory limit:"
docker run -d --name ecommerce-backend --memory=512m ecommerce-backend:latest
echo ""
echo "Monitor container memory usage:"
docker stats ecommerce-backend
echo ""
```

### **Docker PS Troubleshooting**

#### **🔧 Common Listing Issues and Solutions**

```bash
# Issue 1: No containers showing
echo "=== TROUBLESHOOTING: No Containers Showing ==="
echo "Problem: docker ps shows no containers"
echo "Solution: Check if containers exist and Docker daemon is running"
echo ""
echo "Check Docker daemon status:"
sudo systemctl status docker
echo ""
echo "List all containers (including stopped):"
docker ps -a
echo ""
echo "Check Docker daemon logs:"
sudo journalctl -u docker.service --no-pager -l
echo ""

# Issue 2: Container names not showing
echo "=== TROUBLESHOOTING: Container Names Not Showing ==="
echo "Problem: Container names appear as random strings"
echo "Solution: Use --name flag when creating containers"
echo ""
echo "Create container with custom name:"
docker run -d --name ecommerce-backend ecommerce-backend:latest
echo ""
echo "Verify name is set:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
echo ""
```

## ⚡ **Performance and Security Considerations**

### **Docker Build Performance**

```bash
# Performance Optimization Tips:
echo "=== DOCKER BUILD PERFORMANCE OPTIMIZATION ==="
echo ""
echo "1. Use .dockerignore to reduce build context:"
echo "   - Exclude node_modules, .git, documentation"
echo "   - Reduces build time and image size"
echo ""
echo "2. Leverage build cache:"
echo "   - Order Dockerfile instructions from least to most frequently changed"
echo "   - Use multi-stage builds for optimization"
echo ""
echo "3. Use specific base images:"
echo "   - Use alpine variants for smaller images"
echo "   - Pin to specific versions for reproducibility"
echo ""
echo "4. Parallel builds:"
echo "   - Use BuildKit for parallel layer building"
echo "   - Enable with: export DOCKER_BUILDKIT=1"
echo ""

# Security Considerations:
echo "=== DOCKER BUILD SECURITY CONSIDERATIONS ==="
echo ""
echo "1. Use non-root users:"
echo "   - Create dedicated user in Dockerfile"
echo "   - Reduces security risks"
echo ""
echo "2. Scan images for vulnerabilities:"
echo "   - Use docker scan or third-party tools"
echo "   - Regular security updates"
echo ""
echo "3. Use specific image tags:"
echo "   - Avoid 'latest' tag in production"
echo "   - Use semantic versioning"
echo ""
echo "4. Minimize attack surface:"
echo "   - Use minimal base images"
echo "   - Remove unnecessary packages"
echo ""
```

### **Docker Run Performance**

```bash
# Performance Optimization Tips:
echo "=== DOCKER RUN PERFORMANCE OPTIMIZATION ==="
echo ""
echo "1. Resource limits:"
echo "   - Set appropriate memory and CPU limits"
echo "   - Prevents resource exhaustion"
echo ""
echo "2. Volume optimization:"
echo "   - Use named volumes for persistent data"
echo "   - Avoid bind mounts for performance-critical data"
echo ""
echo "3. Network optimization:"
echo "   - Use custom networks for container communication"
echo "   - Avoid host networking unless necessary"
echo ""
echo "4. Container lifecycle:"
echo "   - Use restart policies appropriately"
echo "   - Monitor container health"
echo ""

# Security Considerations:
echo "=== DOCKER RUN SECURITY CONSIDERATIONS ==="
echo ""
echo "1. Resource limits:"
echo "   - Set memory and CPU limits"
echo "   - Prevent resource exhaustion attacks"
echo ""
echo "2. User privileges:"
echo "   - Run containers as non-root user"
echo "   - Use --user flag when needed"
echo ""
echo "3. Network security:"
echo "   - Use custom networks"
echo "   - Limit exposed ports"
echo ""
echo "4. File system security:"
echo "   - Use read-only containers when possible"
echo "   - Limit volume access"
echo ""
```

### **Real-time Examples with ALL Flags**

```bash
# Example 1: Complete Docker Build with Multiple Flags
docker build \
  --build-arg VERSION=1.0.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --tag ecommerce-backend:latest \
  --tag ecommerce-backend:1.0.0 \
  --file docker/Dockerfile.backend \
  --no-cache \
  --pull \
  --progress=plain \
  --target production \
  --label "maintainer=ecommerce-team@example.com" \
  --label "version=1.0.0" \
  --label "description=E-commerce backend application" \
  --memory=2g \
  --cpus=2 \
  --network=host \
  --secret id=github_token,src=./github_token.txt \
  --ssh default \
  .

# Explanation of each flag:
# --build-arg VERSION=1.0.0: Sets build-time variable VERSION
# --build-arg BUILD_DATE=...: Sets build timestamp
# --tag ecommerce-backend:latest: Tags image with latest tag
# --tag ecommerce-backend:1.0.0: Tags image with version tag
# --file docker/Dockerfile.backend: Specifies Dockerfile path
# --no-cache: Disables build cache
# --pull: Always pull latest base image
# --progress=plain: Shows build progress in plain text
# --target production: Builds only the production stage
# --label "maintainer=...": Adds metadata labels
# --memory=2g: Limits build memory to 2GB
# --cpus=2: Limits build to 2 CPU cores
# --network=host: Uses host network during build
# --secret id=github_token,src=./github_token.txt: Mounts secret file
# --ssh default: Uses SSH agent for private repositories
# .: Build context (current directory)
```

```bash
# Example 2: Complete Docker Run with Multiple Flags
docker run \
  --detach \
  --name ecommerce-backend \
  --hostname backend-server \
  --restart=unless-stopped \
  --memory=1g \
  --memory-swap=2g \
  --cpus=1.5 \
  --cpuset-cpus=0-1 \
  --cpu-shares=1024 \
  --blkio-weight=300 \
  --device-read-bps=/dev/sda:1mb \
  --device-write-bps=/dev/sda:1mb \
  --publish 8000:8000 \
  --publish 8001:8001 \
  --expose 8002 \
  --network ecommerce-network \
  --add-host database:192.168.1.100 \
  --dns=8.8.8.8 \
  --dns=8.8.4.4 \
  --dns-search=example.com \
  --volume /host/data:/app/data:rw \
  --volume /host/logs:/app/logs:ro \
  --mount type=tmpfs,destination=/tmp,tmpfs-size=100m \
  --env DATABASE_URL=postgresql://user:pass@database:5432/db \
  --env DEBUG=false \
  --env-file .env.production \
  --user 1000:1000 \
  --group-add docker \
  --cap-add NET_ADMIN \
  --cap-drop ALL \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --read-only \
  --tmpfs /tmp:rw,size=100m \
  --tmpfs /var/run:rw,size=10m \
  --health-cmd="curl -f http://localhost:8000/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  --health-start-period=40s \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --ulimit nofile=65536:65536 \
  --ulimit nproc=32768:32768 \
  --sysctl net.core.somaxconn=1024 \
  --init \
  --stop-signal=SIGTERM \
  --stop-timeout=30 \
  --workdir /app \
  --entrypoint /app/entrypoint.sh \
  ecommerce-backend:latest \
  uvicorn main:app --host 0.0.0.0 --port 8000

# Explanation of key flags:
# --detach: Run in background
# --name ecommerce-backend: Container name
# --hostname backend-server: Container hostname
# --restart=unless-stopped: Restart policy
# --memory=1g: Memory limit
# --memory-swap=2g: Swap limit
# --cpus=1.5: CPU limit
# --cpuset-cpus=0-1: Use CPUs 0 and 1
# --cpu-shares=1024: CPU weight
# --blkio-weight=300: Block I/O weight
# --device-read-bps=/dev/sda:1mb: Read speed limit
# --device-write-bps=/dev/sda:1mb: Write speed limit
# --publish 8000:8000: Port mapping
# --publish 8001:8001: Additional port mapping
# --expose 8002: Expose port without mapping
# --network ecommerce-network: Custom network
# --add-host database:192.168.1.100: Custom host mapping
# --dns=8.8.8.8: Custom DNS server
# --dns-search=example.com: DNS search domain
# --volume /host/data:/app/data:rw: Volume mount with read-write
# --volume /host/logs:/app/logs:ro: Volume mount with read-only
# --mount type=tmpfs,destination=/tmp,tmpfs-size=100m: Tmpfs mount
# --env DATABASE_URL=...: Environment variable
# --env-file .env.production: Environment file
# --user 1000:1000: Run as specific user
# --group-add docker: Add to docker group
# --cap-add NET_ADMIN: Add capability
# --cap-drop ALL: Drop all capabilities
# --security-opt seccomp=unconfined: Security option
# --security-opt apparmor=unconfined: Security option
# --read-only: Read-only root filesystem
# --tmpfs /tmp:rw,size=100m: Tmpfs mount
# --health-cmd="curl -f http://localhost:8000/health || exit 1": Health check
# --health-interval=30s: Health check interval
# --health-timeout=10s: Health check timeout
# --health-retries=3: Health check retries
# --health-start-period=40s: Health check start period
# --log-driver=json-file: Log driver
# --log-opt max-size=10m: Log size limit
# --log-opt max-file=3: Log file count limit
# --ulimit nofile=65536:65536: File descriptor limit
# --ulimit nproc=32768:32768: Process limit
# --sysctl net.core.somaxconn=1024: System control
# --init: Use init system
# --stop-signal=SIGTERM: Stop signal
# --stop-timeout=30: Stop timeout
# --workdir /app: Working directory
# --entrypoint /app/entrypoint.sh: Custom entrypoint
# ecommerce-backend:latest: Image name
# uvicorn main:app --host 0.0.0.0 --port 8000: Command and arguments
```

### **Flag Exploration Exercises**

```bash
# Exercise 1: Explore Docker Build Flags
echo "Testing different build flags:"
docker build --help | grep -A 5 -B 5 "build-arg"
docker build --help | grep -A 5 -B 5 "tag"
docker build --help | grep -A 5 -B 5 "file"
docker build --help | grep -A 5 -B 5 "no-cache"
docker build --help | grep -A 5 -B 5 "pull"

# Exercise 2: Explore Docker Run Flags
echo "Testing different run flags:"
docker run --help | grep -A 5 -B 5 "detach"
docker run --help | grep -A 5 -B 5 "memory"
docker run --help | grep -A 5 -B 5 "cpus"
docker run --help | grep -A 5 -B 5 "publish"
docker run --help | grep -A 5 -B 5 "volume"

# Exercise 3: Combine Flags and Observe Differences
echo "Testing flag combinations:"
docker run -d --name test1 --memory=100m --cpus=0.5 alpine sleep 60
docker run -d --name test2 --memory=200m --cpus=1.0 alpine sleep 60
docker run -d --name test3 --memory=100m --cpus=1.0 alpine sleep 60
docker stats --no-stream test1 test2 test3
```

### **Performance and Security Considerations**

```bash
# Performance Considerations:
# - Use specific flags to optimize resource usage
# - Use --no-cache for fresh builds
# - Use --pull to ensure latest base images
# - Use --target for multi-stage builds
# - Use --compress for large build contexts

# Security Considerations:
# - Be careful with --privileged flag
# - Use --user to run as non-root
# - Use --cap-drop ALL and --cap-add specific capabilities
# - Use --read-only for immutable containers
# - Use --security-opt for additional security
# - Use --no-new-privileges to prevent privilege escalation
```

---

## 🔧 **Hands-on Lab: Analyzing Your E-commerce Application**

### **Lab 1: Examining Your Docker Setup**

Let's analyze your existing e-commerce application's containerization:

```bash
# Navigate to your e-commerce project
cd /path/to/your/e-commerce

# Examine the backend Dockerfile
cat docker/Dockerfile.backend
```

#### **Backend Dockerfile Analysis**

**📋 Overview**: This is a multi-stage Dockerfile that creates a production-ready FastAPI backend container. It uses two stages: a builder stage for compiling dependencies and a production stage for the final runtime image.

**🔍 Detailed Line-by-Line Analysis**:

```dockerfile
# Multi-stage Dockerfile for Backend (FastAPI)
# Optimized for production with security best practices
```
**Explanation**: Comments explaining the purpose - this is a multi-stage build for production optimization and security.

```dockerfile
# Build stage - Creates a temporary environment for building
FROM python:3.11-slim as builder
```
**Explanation**: 
- `FROM`: Specifies the base image to start from
- `python:3.11-slim`: Official Python 3.11 image with minimal packages (slim variant reduces size)
- `as builder`: Names this stage "builder" for reference in later stages
- **Why slim?**: Reduces attack surface and image size by excluding development tools

```dockerfile
# Build arguments - Allow customization during build
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
```
**Explanation**:
- `ARG`: Defines build-time variables that can be passed during build
- `BUILD_DATE`: Timestamp when image was built (for traceability)
- `VCS_REF`: Git commit hash (for version tracking)
- `VERSION`: Application version (for release management)
- **Usage**: `docker build --build-arg VERSION=1.0.0 .`

```dockerfile
# Labels for metadata - Provide information about the image
LABEL maintainer="ecommerce-team@example.com" \
      org.opencontainers.image.title="E-Commerce Backend" \
      org.opencontainers.image.description="FastAPI backend for e-commerce application" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://gitlab.com/your-org/e-commerce"
```
**Explanation**:
- `LABEL`: Adds metadata to the image (following OCI standards)
- `maintainer`: Contact information for the image maintainer
- `org.opencontainers.image.*`: Standard OCI labels for image metadata
- `$VERSION`, `$BUILD_DATE`, `$VCS_REF`: References to ARG variables defined above
- **Benefits**: Enables image tracking, compliance, and automated tooling

```dockerfile
# Set environment variables - Optimize Python behavior
ENV PYTHONDONTWRITEBYTECODE=1 \    # Don't write .pyc files
    PYTHONUNBUFFERED=1 \           # Don't buffer stdout/stderr
    PIP_NO_CACHE_DIR=1 \           # Don't cache pip downloads
    PIP_DISABLE_PIP_VERSION_CHECK=1 # Skip pip version checks
```
**Explanation**:
- `ENV`: Sets environment variables for the container
- `PYTHONDONTWRITEBYTECODE=1`: Prevents Python from writing .pyc files (reduces image size)
- `PYTHONUNBUFFERED=1`: Ensures Python output is sent directly to terminal (better logging)
- `PIP_NO_CACHE_DIR=1`: Prevents pip from caching packages (reduces image size)
- `PIP_DISABLE_PIP_VERSION_CHECK=1`: Skips pip version checks (faster builds)
- **Backslash (\)**: Line continuation for multi-line ENV statements

```dockerfile
# Install system dependencies - Required for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \              # Compiler tools
    libpq-dev \                   # PostgreSQL development headers
    && rm -rf /var/lib/apt/lists/* # Clean up package cache
```
**Explanation**:
- `RUN`: Executes commands during image build
- `apt-get update`: Updates package list from repositories
- `apt-get install -y`: Installs packages without prompting (-y = yes to all)
- `--no-install-recommends`: Only installs essential packages (reduces size)
- `build-essential`: Includes gcc, g++, make (needed for compiling Python packages)
- `libpq-dev`: PostgreSQL development libraries (needed for psycopg2)
- `&& rm -rf /var/lib/apt/lists/*`: Removes package cache to reduce image size
- **Best Practice**: Combine commands with && to reduce layers

```dockerfile
# Create virtual environment - Isolate Python dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
```
**Explanation**:
- `python -m venv /opt/venv`: Creates Python virtual environment in /opt/venv
- **Why virtual env?**: Isolates dependencies from system Python
- `ENV PATH="/opt/venv/bin:$PATH"`: Adds virtual environment's bin directory to PATH
- **Result**: Python and pip commands will use the virtual environment

```dockerfile
# Copy requirements and install Python dependencies
COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt
```
**Explanation**:
- `COPY backend/requirements.txt /tmp/requirements.txt`: Copies requirements file to container
- **Why /tmp?**: Temporary location, will be cleaned up
- `pip install --upgrade pip`: Updates pip to latest version
- `pip install -r /tmp/requirements.txt`: Installs all Python dependencies
- **Layer Optimization**: Copy requirements first, then install (enables Docker layer caching)

```dockerfile
# Production stage - Final, optimized image
FROM python:3.11-slim as production
```
**Explanation**:
- `FROM python:3.11-slim as production`: Starts new stage with fresh base image
- **Why new stage?**: Builder stage included build tools we don't need in production
- **Result**: Smaller, more secure production image

```dockerfile
# Install runtime dependencies - Only what's needed to run
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \                      # PostgreSQL runtime library
    curl \                        # For health checks
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
```
**Explanation**:
- `libpq5`: PostgreSQL client library (runtime dependency, not dev headers)
- `curl`: HTTP client for health checks
- `apt-get clean`: Additional cleanup of package cache
- **Security**: Only runtime dependencies, no build tools

```dockerfile
# Create non-root user - Security best practice
RUN groupadd -r appuser && useradd -r -g appuser appuser
```
**Explanation**:
- `groupadd -r appuser`: Creates system group "appuser" (-r = system group)
- `useradd -r -g appuser appuser`: Creates system user "appuser" in group "appuser"
- **Security Benefit**: Prevents privilege escalation if container is compromised
- **Best Practice**: Never run containers as root in production

```dockerfile
# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
```
**Explanation**:
- `COPY --from=builder`: Copies files from the "builder" stage
- `/opt/venv /opt/venv`: Source and destination paths
- **Result**: Production image gets compiled Python packages without build tools
- `ENV PATH="/opt/venv/bin:$PATH"`: Sets up PATH for virtual environment

```dockerfile
# Set working directory
WORKDIR /app
```
**Explanation**:
- `WORKDIR /app`: Sets /app as the current working directory
- **Effect**: All subsequent commands run from /app
- **Benefit**: Consistent file paths, easier debugging

```dockerfile
# Copy application code
COPY backend/ .
```
**Explanation**:
- `COPY backend/ .`: Copies entire backend directory to current working directory (/app)
- **Note**: This copies source code, not the requirements.txt (already handled)
- **Layer Caching**: This layer will be rebuilt when source code changes

```dockerfile
# Create necessary directories and set permissions
RUN mkdir -p uploads/products logs && \
    chown -R appuser:appuser /app
```
**Explanation**:
- `mkdir -p uploads/products logs`: Creates directory structure (-p creates parent directories)
- `chown -R appuser:appuser /app`: Changes ownership of /app to appuser
- **Security**: Ensures application can write to required directories
- **Structure**: uploads/products for file uploads, logs for application logs

```dockerfile
# Switch to non-root user - Security best practice
USER appuser
```
**Explanation**:
- `USER appuser`: Switches to non-root user for all subsequent commands
- **Security**: Container runs as unprivileged user
- **Effect**: If container is compromised, attacker has limited privileges

```dockerfile
# Health check - Monitor application health
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```
**Explanation**:
- `HEALTHCHECK`: Defines how Docker checks if container is healthy
- `--interval=30s`: Check every 30 seconds
- `--timeout=30s`: Wait 30 seconds for response
- `--start-period=5s`: Wait 5 seconds before first check (app startup time)
- `--retries=3`: Mark unhealthy after 3 consecutive failures
- `CMD curl -f http://localhost:8000/health || exit 1`: Health check command
- **Benefits**: Enables container orchestration health monitoring

```dockerfile
# Expose port - Document which port the app uses
EXPOSE 8000
```
**Explanation**:
- `EXPOSE 8000`: Documents that the application listens on port 8000
- **Note**: This doesn't actually publish the port (done with -p flag)
- **Purpose**: Documentation and metadata for orchestration tools

```dockerfile
# Default command - How to start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```
**Explanation**:
- `CMD`: Defines the default command to run when container starts
- `["uvicorn", ...]`: Exec form (recommended) - runs command directly
- `main:app`: FastAPI app object in main.py file
- `--host 0.0.0.0`: Listen on all interfaces (not just localhost)
- `--port 8000`: Listen on port 8000
- `--workers 4`: Run 4 worker processes for better performance
- **Production Ready**: Optimized for production deployment

#### **Frontend Dockerfile Analysis**

```bash
# Examine the frontend Dockerfile
cat docker/Dockerfile.frontend
```

**📋 Overview**: This is a multi-stage Dockerfile for a React frontend application. It builds the React app in the first stage and serves it with Nginx in the production stage.

**🔍 Detailed Line-by-Line Analysis**:

```dockerfile
# Build Stage - Compile React application
FROM node:18-alpine AS builder
```
**Explanation**:
- `FROM node:18-alpine AS builder`: Uses Node.js 18 Alpine image as base
- `node:18-alpine`: Official Node.js 18 image with Alpine Linux (very small)
- `AS builder`: Names this stage "builder" for multi-stage build
- **Why Alpine?**: Extremely small (~5MB base), security-focused, minimal attack surface

```dockerfile
# Build arguments - Allow customization during build
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG REACT_APP_API_URL=http://localhost:8000
ARG REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
```
**Explanation**:
- `ARG BUILD_DATE`, `VCS_REF`, `VERSION`: Standard build metadata
- `ARG REACT_APP_API_URL=http://localhost:8000`: API URL for React app (default value)
- `ARG REACT_APP_API_BASE_URL=http://localhost:8000/api/v1`: API base URL (default value)
- **React Specific**: React apps use REACT_APP_ prefix for environment variables
- **Build-time**: These are set during docker build, not runtime

```dockerfile
# Labels for metadata
LABEL maintainer="ecommerce-team@example.com" \
      org.opencontainers.image.title="E-Commerce Frontend" \
      org.opencontainers.image.description="React frontend for e-commerce application" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://gitlab.com/your-org/e-commerce"
```
**Explanation**:
- Same OCI standard labels as backend
- **Consistency**: Maintains metadata standards across all images
- **Traceability**: Enables tracking and compliance across the application stack

```dockerfile
# Set working directory
WORKDIR /app
```
**Explanation**:
- `WORKDIR /app`: Sets /app as working directory for all subsequent commands
- **Effect**: All file operations will be relative to /app
- **Consistency**: Matches backend Dockerfile structure

```dockerfile
# Copy package files first - Leverage Docker layer caching
COPY frontend/package*.json ./
RUN npm ci --silent
```
**Explanation**:
- `COPY frontend/package*.json ./`: Copies package.json and package-lock.json
- **Why first?**: Dependencies change less frequently than source code
- **Layer Caching**: If source code changes, this layer won't be rebuilt
- `npm ci --silent`: Installs exact versions from package-lock.json
- `--silent`: Reduces build output noise
- **npm ci vs npm install**: ci is faster, more reliable for production builds

```dockerfile
# Copy source code
COPY frontend/ .
```
**Explanation**:
- `COPY frontend/ .`: Copies entire frontend directory to /app
- **After dependencies**: This layer will be rebuilt when source code changes
- **Efficiency**: Dependencies are already installed, so only source changes trigger rebuild

```dockerfile
# Set environment variables for build
ENV REACT_APP_API_URL=$REACT_APP_API_URL \
    REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL \
    NODE_ENV=production
```
**Explanation**:
- `REACT_APP_API_URL=$REACT_APP_API_URL`: Uses build argument value
- `REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL`: Uses build argument value
- `NODE_ENV=production`: Sets production mode for React build
- **React Build**: These variables are embedded in the built JavaScript bundle
- **Build-time**: Values are fixed at build time, not runtime

```dockerfile
# Build the application
RUN npm run build
```
**Explanation**:
- `npm run build`: Runs the build script defined in package.json
- **Result**: Creates optimized production build in /app/build directory
- **Optimization**: Minifies code, removes dev dependencies, optimizes assets
- **Output**: Static files ready for web server

```dockerfile
# Production Stage with Nginx - Serve static files
FROM nginx:1.25-alpine AS production
```
**Explanation**:
- `FROM nginx:1.25-alpine AS production`: Starts new stage with Nginx
- **Why Nginx?**: High-performance web server, excellent for static files
- **Alpine**: Small, secure base image
- **Separation**: Build tools (Node.js) not needed in production

```dockerfile
# Update packages and install curl for health checks
RUN apk update && apk upgrade && apk add --no-cache curl
RUN rm /etc/nginx/conf.d/default.conf
```
**Explanation**:
- `apk update && apk upgrade`: Updates Alpine package database and upgrades packages
- `apk add --no-cache curl`: Installs curl for health checks
- `--no-cache`: Doesn't store package cache (reduces image size)
- `rm /etc/nginx/conf.d/default.conf`: Removes default Nginx configuration
- **Security**: Updates packages to latest versions, removes unnecessary config

```dockerfile
# Copy nginx configuration files
COPY docker/nginx.conf /etc/nginx/conf.d/
COPY docker/security-headers.conf /etc/nginx/conf.d/
```
**Explanation**:
- `COPY docker/nginx.conf /etc/nginx/conf.d/`: Copies custom Nginx configuration
- `COPY docker/security-headers.conf /etc/nginx/conf.d/`: Copies security headers config
- **Custom Config**: Replaces default Nginx behavior with application-specific settings
- **Security**: Security headers protect against common web vulnerabilities

```dockerfile
# Copy built application from builder stage
COPY --from=builder /app/build /usr/share/nginx/html
```
**Explanation**:
- `COPY --from=builder`: Copies from the "builder" stage
- `/app/build /usr/share/nginx/html`: Source and destination paths
- **Nginx Default**: /usr/share/nginx/html is Nginx's default document root
- **Result**: Static React app is served by Nginx

```dockerfile
# Create non-root user for security
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-user nginx-user && \
    chown -R nginx-user:nginx-user /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d
```
**Explanation**:
- `addgroup -g 1001 -S nginx-user`: Creates system group with GID 1001
- `adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-user nginx-user`: Creates system user
  - `-S`: System user
  - `-D`: Don't assign password
  - `-H`: Don't create home directory
  - `-u 1001`: User ID 1001
  - `-h /var/cache/nginx`: Home directory
  - `-s /sbin/nologin`: No shell access
  - `-G nginx-user`: Add to nginx-user group
- `chown -R nginx-user:nginx-user /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d`: Changes ownership
- **Security**: Nginx runs as unprivileged user

```dockerfile
# Switch to non-root user
USER nginx-user
```
**Explanation**:
- `USER nginx-user`: Switches to nginx-user for all subsequent commands
- **Security**: Container runs as non-root user
- **Principle**: Least privilege access

```dockerfile
# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```
**Explanation**:
- Same health check pattern as backend
- `curl -f http://localhost/`: Tests if Nginx is serving content
- `-f`: Fail silently on HTTP errors
- **Monitoring**: Enables container orchestration health monitoring

```dockerfile
# Expose port
EXPOSE 80
```
**Explanation**:
- `EXPOSE 80`: Documents that Nginx listens on port 80 (HTTP)
- **Standard**: Port 80 is the standard HTTP port
- **Documentation**: Helps orchestration tools understand port requirements

```dockerfile
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```
**Explanation**:
- `CMD ["nginx", "-g", "daemon off;"]`: Starts Nginx in foreground mode
- `-g "daemon off;"`: Runs Nginx in foreground (required for containers)
- **Container Requirement**: Containers need a foreground process to stay running
- **Production Ready**: Optimized Nginx configuration for serving React app

### **Lab 2: Building and Running Containers**

**📋 Overview**: This lab demonstrates how to build Docker images and run containers with detailed command explanations.

**🔍 Detailed Command Analysis**:

```bash
# Build the backend image
docker build -f docker/Dockerfile.backend -t ecommerce-backend:latest .
```
**Explanation**:
- `docker build`: Command to build a Docker image from a Dockerfile
- `-f docker/Dockerfile.backend`: Specifies the Dockerfile path (default is ./Dockerfile)
- `-t ecommerce-backend:latest`: Tags the image with name "ecommerce-backend" and tag "latest"
- `.`: Build context (current directory) - all files in this directory are available to the build
- **Result**: Creates an image named ecommerce-backend:latest

```bash
# Build the frontend image
docker build -f docker/Dockerfile.frontend -t ecommerce-frontend:latest .
```
**Explanation**:
- Same pattern as backend build
- `-f docker/Dockerfile.frontend`: Uses the frontend-specific Dockerfile
- `-t ecommerce-frontend:latest`: Tags the frontend image
- **Multi-stage**: This will build both the Node.js builder stage and Nginx production stage

```bash
# List built images
docker images
```

# =============================================================================
# DOCKER IMAGES COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker images
# Purpose: List all Docker images on the local system with detailed information
# Category: Image Management
# Complexity: Beginner
# Real-world Usage: Image inventory, system administration, image management

# 1. Command Overview:
# docker images lists all Docker images stored locally
# Shows essential information including repository, tag, image ID, creation date, and size
# Essential for image management and system administration

# 2. Command Purpose and Context:
# What docker images does:
# - Lists all Docker images on the local system
# - Shows image identification information (repository, tag, ID)
# - Displays image metadata (creation date, size)
# - Provides comprehensive image inventory

# When to use docker images:
# - Checking available images on the system
# - Verifying image builds and pulls
# - System administration and cleanup
# - Image inventory management

# Command relationships:
# - Often used with docker build to verify newly built images
# - Works with docker run to identify available images
# - Used with docker rmi to remove specific images
# - Complementary to docker pull for image management

# 3. Complete Flag Reference:
# docker images [OPTIONS] [REPOSITORY[:TAG]]
# Options:
# -a, --all: Show all images (default hides intermediate images)
# --filter, -f: Filter output based on conditions
# --format: Pretty-print using a Go template
# --no-trunc: Don't truncate output
# --quiet, -q: Only display image IDs
# --digests: Show digests

# 4. Flag Discovery Methods:
# docker images --help          # Show all available options
# man docker-images             # Manual page with complete documentation
# docker --help | grep images   # Filter help for images command

# 5. Structured Command Analysis Section:
# Command: docker images
# - docker images: Command to list Docker images
# - No additional parameters: Shows all images
# - Output format: Table with columns for repository, tag, image ID, created, size

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker images
# Expected Output:
# REPOSITORY            TAG       IMAGE ID       CREATED        SIZE
# ecommerce-backend     latest    abc123def456   2 hours ago    150MB
# ecommerce-frontend    latest    def456ghi789   2 hours ago    25MB
# nginx                 latest    123456789abc   3 days ago     133MB
# python                3.9       456789abcdef   1 week ago     900MB
# 
# Output Analysis:
# - REPOSITORY: Image repository name
# - TAG: Image tag (version identifier)
# - IMAGE ID: Unique image identifier (first 12 characters)
# - CREATED: When the image was created
# - SIZE: Image size on disk

# 7. Flag Exploration Exercises:
# docker images -a              # Show all images including intermediate
# docker images --filter "dangling=true"  # Show dangling images
# docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"  # Custom format
# docker images -q              # Show only image IDs
# docker images --no-trunc      # Show full output without truncation

# 8. Performance and Security Considerations:
# Performance: Fast operation, minimal system impact
# Security: Reveals image information and system inventory
# Best Practices: Use for inventory management, combine with filters for specific needs
# Privacy: May expose image names and system information

# 9. Troubleshooting Scenarios:
# Error: "Cannot connect to the Docker daemon"
# Solution: Check if Docker daemon is running with sudo systemctl status docker
# Error: "No images showing"
# Solution: Check if images exist with docker images -a
# Error: "Permission denied"
# Solution: Add user to docker group or use sudo

# 10. Complete Code Documentation:
# Command: docker images
# Purpose: List all Docker images for inventory and verification
# Context: Hands-on lab exercise for image management and verification
# Expected Input: No input required
# Expected Output: Table of all Docker images with detailed information
# Error Conditions: Docker daemon not running, permission denied
# Verification: Check output shows expected images with correct repository names and tags

```bash
# Run the backend container
docker run -d \
  --name ecommerce-backend \
  -p 8000:8000 \
  -e DATABASE_URL=postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db \
  ecommerce-backend:latest
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name ecommerce-backend -p 8000:8000 -e DATABASE_URL=postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db ecommerce-backend:latest
# Purpose: Create and start a new container in detached mode with port mapping and environment variables
# Category: Container Operations
# Complexity: Intermediate
# Real-world Usage: Application deployment, container orchestration, service management

# 1. Command Overview:
# docker run creates and starts a new container from an image
# Combines multiple flags for comprehensive container configuration
# Essential for deploying applications with specific requirements

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container from a Docker image
# - Starts the container with specified configuration
# - Applies port mappings, environment variables, and other settings
# - Runs the container in detached mode for background operation

# When to use docker run:
# - Deploying applications in containers
# - Running services with specific configurations
# - Testing containerized applications
# - Setting up development environments

# Command relationships:
# - Often used with docker build to run newly built images
# - Works with docker ps to verify container status
# - Used with docker logs to monitor container output
# - Complementary to docker stop/start for container management

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# -p, --publish: Publish container's port(s) to the host
# -e, --env: Set environment variables
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --memory: Memory limit
# --cpus: CPU limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name ecommerce-backend -p 8000:8000 -e DATABASE_URL=postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db ecommerce-backend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name ecommerce-backend: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - -p 8000:8000: Port mapping
#   - Maps host port 8000 to container port 8000
#   - Format: host_port:container_port
#   - Enables external access to containerized application
# - -e DATABASE_URL=...: Environment variable
#   - Sets database connection string
#   - Available to application inside container
#   - postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db
#     - postgres:admin: Database credentials
#     - host.docker.internal: Special hostname for host access
#     - 5432: PostgreSQL default port
#     - ecommerce_db: Database name
# - ecommerce-backend:latest: Image specification
#   - ecommerce-backend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name ecommerce-backend -p 8000:8000 -e DATABASE_URL=postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db ecommerce-backend:latest
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - No additional output unless there are errors

# 7. Flag Exploration Exercises:
# docker run -it --name test-container ecommerce-backend:latest /bin/bash  # Interactive mode
# docker run --rm ecommerce-backend:latest python --version              # Auto-remove after exit
# docker run --restart=always ecommerce-backend:latest                   # Auto-restart policy
# docker run --memory=512m ecommerce-backend:latest                      # Memory limit
# docker run --cpus=1.0 ecommerce-backend:latest                        # CPU limit

# 8. Performance and Security Considerations:
# Performance: Container startup time depends on image size and complexity
# Security: Environment variables may contain sensitive data
# Best Practices: Use secrets management for sensitive data, limit resource usage
# Privacy: Environment variables are visible in container inspection

# 9. Troubleshooting Scenarios:
# Error: "Port already in use"
# Solution: Check for existing containers using the port with docker ps
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker run -d --name ecommerce-backend -p 8000:8000 -e DATABASE_URL=postgresql://postgres:admin@host.docker.internal:5432/ecommerce_db ecommerce-backend:latest
# Purpose: Deploy ecommerce backend container with database connectivity
# Context: Hands-on lab exercise for container deployment with environment configuration
# Expected Input: Docker image name and configuration parameters
# Expected Output: Container ID and background container execution
# Error Conditions: Port conflict, name conflict, image not found, permission denied
# Verification: Check container status with docker ps and logs with docker logs

```bash
# Run the frontend container
docker run -d \
  --name ecommerce-frontend \
  -p 3000:80 \
  ecommerce-frontend:latest
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name ecommerce-frontend -p 3000:80 ecommerce-frontend:latest
# Purpose: Create and start a frontend container in detached mode with port mapping
# Category: Container Operations
# Complexity: Beginner to Intermediate
# Real-world Usage: Web application deployment, frontend service management

# 1. Command Overview:
# docker run creates and starts a new frontend container from an image
# Configures port mapping for web server access
# Essential for deploying web applications with external access

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new frontend container from a Docker image
# - Starts the container with port mapping configuration
# - Runs the container in detached mode for background operation
# - Enables external access to the web application

# When to use docker run:
# - Deploying web applications in containers
# - Running frontend services with specific port configurations
# - Testing containerized web applications
# - Setting up development environments

# Command relationships:
# - Often used with docker build to run newly built frontend images
# - Works with docker ps to verify container status
# - Used with docker logs to monitor web server output
# - Complementary to docker stop/start for container management

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# -p, --publish: Publish container's port(s) to the host
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --memory: Memory limit
# --cpus: CPU limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name ecommerce-frontend -p 3000:80 ecommerce-frontend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name ecommerce-frontend: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - -p 3000:80: Port mapping
#   - Maps host port 3000 to container port 80
#   - Format: host_port:container_port
#   - Enables external access to web application
#   - Port 80 is Nginx default port
# - ecommerce-frontend:latest: Image specification
#   - ecommerce-frontend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name ecommerce-frontend -p 3000:80 ecommerce-frontend:latest
# Expected Output:
# 0987654321cdef0987654321cdef0987654321cdef0987654321cdef0987654321cdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - No additional output unless there are errors

# 7. Flag Exploration Exercises:
# docker run -it --name test-frontend ecommerce-frontend:latest /bin/bash  # Interactive mode
# docker run --rm ecommerce-frontend:latest nginx -v                       # Auto-remove after exit
# docker run --restart=always ecommerce-frontend:latest                    # Auto-restart policy
# docker run --memory=256m ecommerce-frontend:latest                       # Memory limit
# docker run --cpus=0.5 ecommerce-frontend:latest                         # CPU limit

# 8. Performance and Security Considerations:
# Performance: Container startup time depends on image size and complexity
# Security: No sensitive environment variables in this example
# Best Practices: Use appropriate resource limits, monitor web server logs
# Privacy: Web server logs may contain user access patterns

# 9. Troubleshooting Scenarios:
# Error: "Port already in use"
# Solution: Check for existing containers using port 3000 with docker ps
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker run -d --name ecommerce-frontend -p 3000:80 ecommerce-frontend:latest
# Purpose: Deploy ecommerce frontend container with web server access
# Context: Hands-on lab exercise for frontend container deployment
# Expected Input: Docker image name and port mapping configuration
# Expected Output: Container ID and background container execution
# Error Conditions: Port conflict, name conflict, image not found, permission denied
# Verification: Check container status with docker ps and access web application at http://localhost:3000

```bash
# Check running containers
docker ps
```

# =============================================================================
# DOCKER PS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker ps
# Purpose: List currently running containers with detailed information
# Category: Container Operations
# Complexity: Beginner
# Real-world Usage: Container monitoring, system administration, debugging

# 1. Command Overview:
# docker ps lists all currently running containers
# Shows essential information including container ID, image, status, ports, and names
# Essential for container monitoring and system administration

# 2. Command Purpose and Context:
# What docker ps does:
# - Lists all currently running containers
# - Shows container identification information (ID, name, image)
# - Displays container status and resource information
# - Provides port mappings and creation timestamps

# When to use docker ps:
# - Monitoring running containers
# - Verifying container status
# - System administration and troubleshooting
# - Container inventory management

# Command relationships:
# - Often used with docker logs to identify container names
# - Works with docker exec to access running containers
# - Used with docker stop/start for container management
# - Complementary to docker ps -a for complete container listing

# 3. Complete Flag Reference:
# docker ps [OPTIONS]
# Options:
# -a, --all: Show all containers (default shows just running)
# --filter, -f: Filter output based on conditions
# --format: Pretty-print using a Go template
# --no-trunc: Don't truncate output
# --quiet, -q: Only display container IDs
# --size, -s: Display total file sizes

# 4. Flag Discovery Methods:
# docker ps --help          # Show all available options
# man docker-ps             # Manual page with complete documentation
# docker --help | grep ps   # Filter help for ps command

# 5. Structured Command Analysis Section:
# Command: docker ps
# - docker: Docker CLI command
# - ps: Process status command (similar to Unix ps)
# - No additional parameters: Shows all running containers
# - Output format: Table with columns for ID, image, command, created, status, ports, names

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker ps
# Expected Output:
# CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                    NAMES
# 1234567890ab  ecommerce-backend:latest "python main.py"        2 minutes ago   Up 2 minutes   0.0.0.0:8000->8000/tcp   ecommerce-backend
# 0987654321cd  ecommerce-frontend:latest "nginx -g 'daemon off'" 1 minute ago    Up 1 minute    0.0.0.0:3000->80/tcp     ecommerce-frontend
# 
# Output Analysis:
# - CONTAINER ID: Unique identifier for each container
# - IMAGE: Docker image used to create the container
# - COMMAND: Command being executed inside the container
# - CREATED: When the container was created
# - STATUS: Current container status (Up X minutes)
# - PORTS: Port mappings (host:container)
# - NAMES: Container names for easy identification

# 7. Flag Exploration Exercises:
# docker ps -a              # Show all containers (including stopped)
# docker ps --filter "status=running"  # Filter by status
# docker ps --format "table {{.Names}}\t{{.Status}}"  # Custom format
# docker ps -q              # Show only container IDs
# docker ps --no-trunc      # Show full output without truncation

# 8. Performance and Security Considerations:
# Performance: Fast operation, minimal system impact
# Security: Reveals running container information
# Best Practices: Use for monitoring, combine with filters for specific needs
# Privacy: May expose container names and port mappings

# 9. Troubleshooting Scenarios:
# Error: "Cannot connect to the Docker daemon"
# Solution: Check if Docker daemon is running with sudo systemctl status docker
# Error: "No containers showing"
# Solution: Check if containers are actually running with docker ps -a
# Error: "Permission denied"
# Solution: Add user to docker group or use sudo

# 10. Complete Code Documentation:
# Command: docker ps
# Purpose: List currently running containers for monitoring and verification
# Context: Hands-on lab exercise for container status verification
# Expected Input: No input required
# Expected Output: Table of running containers with detailed information
# Error Conditions: Docker daemon not running, permission denied
# Verification: Check output shows expected containers with correct status

```bash
# View container logs
docker logs ecommerce-backend
docker logs ecommerce-frontend
```

# =============================================================================
# DOCKER LOGS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker logs ecommerce-backend
# Purpose: Retrieve and display logs from a specific container
# Category: Container Operations
# Complexity: Beginner to Intermediate
# Real-world Usage: Container debugging, monitoring, troubleshooting

# 1. Command Overview:
# docker logs retrieves stdout and stderr logs from containers
# Shows historical output from container processes
# Essential for debugging and monitoring containerized applications

# 2. Command Purpose and Context:
# What docker logs does:
# - Retrieves stdout and stderr logs from containers
# - Shows historical output from container processes
# - Works with both running and stopped containers
# - Provides essential debugging information

# When to use docker logs:
# - Debugging application issues in containers
# - Monitoring container application output
# - Troubleshooting container startup problems
# - Analyzing application behavior and errors

# Command relationships:
# - Often used with docker ps to identify container names/IDs
# - Complementary to docker exec for interactive debugging
# - Works with docker inspect for comprehensive container information
# - Used with grep/awk for log filtering and analysis

# 3. Complete Flag Reference:
# docker logs [OPTIONS] CONTAINER
# Options:
# --details: Show extra details provided to logs
# --follow, -f: Follow log output
# --since: Show logs since timestamp or relative time
# --tail: Number of lines to show from end of logs
# --timestamps, -t: Show timestamps
# --until: Show logs before timestamp or relative time

# 4. Flag Discovery Methods:
# docker logs --help          # Show all available options
# man docker-logs             # Manual page with complete documentation
# docker --help | grep logs   # Filter help for logs command

# 5. Structured Command Analysis Section:
# Command: docker logs ecommerce-backend
# - docker logs: Command to retrieve container logs
# - ecommerce-backend: Container name to get logs from
# - No additional flags: Shows all available logs
# - Output: Complete log history from container start

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker logs ecommerce-backend
# Expected Output:
# INFO:     Started server process [1]
# INFO:     Waiting for application startup.
# INFO:     Application startup complete.
# INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
# 
# Output Analysis:
# - Shows FastAPI/Uvicorn startup messages
# - Indicates server is running on port 8000
# - Provides application status information
# - Essential for verifying successful startup

# 7. Flag Exploration Exercises:
# docker logs -f ecommerce-backend        # Follow logs in real-time
# docker logs --tail 20 ecommerce-backend # Show last 20 lines
# docker logs --timestamps ecommerce-backend # Add timestamps
# docker logs --since 1h ecommerce-backend  # Show logs from last hour
# docker logs --until 30m ecommerce-backend # Show logs until 30 minutes ago

# 8. Performance and Security Considerations:
# Performance: Can be slow for containers with large log volumes
# Security: May expose sensitive application information
# Best Practices: Use filters to limit output, be careful with sensitive data
# Privacy: Logs may contain user data or application secrets

# 9. Troubleshooting Scenarios:
# Error: "No such container: ecommerce-backend"
# Solution: Check container name with docker ps -a
# Error: "No logs available"
# Solution: Container may not have generated logs yet
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker logs ecommerce-backend
# Purpose: Retrieve application logs for debugging and monitoring
# Context: Hands-on lab exercise for container log analysis
# Expected Input: Container name or ID
# Expected Output: Application logs from container stdout/stderr
# Error Conditions: Container not found, no logs available, permission denied
# Verification: Check output shows expected application startup messages

# =============================================================================
# DOCKER LOGS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker logs ecommerce-frontend
# Purpose: Retrieve and display logs from frontend container
# Category: Container Operations
# Complexity: Beginner to Intermediate
# Real-world Usage: Container debugging, monitoring, troubleshooting

# 1. Command Overview:
# docker logs retrieves stdout and stderr logs from frontend container
# Shows Nginx startup messages and web server logs
# Essential for debugging frontend container issues

# 2. Command Purpose and Context:
# What docker logs ecommerce-frontend does:
# - Retrieves logs from the frontend container
# - Shows Nginx web server startup messages
# - Displays web server access and error logs
# - Provides frontend application debugging information

# When to use docker logs ecommerce-frontend:
# - Debugging frontend container issues
# - Monitoring web server startup
# - Troubleshooting frontend application problems
# - Analyzing web server logs

# Command relationships:
# - Often used with docker ps to verify frontend container status
# - Complementary to docker exec for interactive debugging
# - Works with docker inspect for comprehensive container information
# - Used with grep for log filtering

# 3. Complete Flag Reference:
# docker logs [OPTIONS] CONTAINER
# Options:
# --details: Show extra details provided to logs
# --follow, -f: Follow log output
# --since: Show logs since timestamp or relative time
# --tail: Number of lines to show from end of logs
# --timestamps, -t: Show timestamps
# --until: Show logs before timestamp or relative time

# 4. Flag Discovery Methods:
# docker logs --help          # Show all available options
# man docker-logs             # Manual page with complete documentation
# docker --help | grep logs   # Filter help for logs command

# 5. Structured Command Analysis Section:
# Command: docker logs ecommerce-frontend
# - docker logs: Command to retrieve container logs
# - ecommerce-frontend: Frontend container name
# - No additional flags: Shows all available logs
# - Output: Complete log history from container start

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker logs ecommerce-frontend
# Expected Output:
# /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
# /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
# /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
# /docker-entrypoint.sh: Configuration complete; ready for start up
# 
# Output Analysis:
# - Shows Nginx startup sequence
# - Indicates configuration is complete
# - Provides web server status information
# - Essential for verifying successful frontend startup

# 7. Flag Exploration Exercises:
# docker logs -f ecommerce-frontend        # Follow logs in real-time
# docker logs --tail 20 ecommerce-frontend # Show last 20 lines
# docker logs --timestamps ecommerce-frontend # Add timestamps
# docker logs --since 1h ecommerce-frontend  # Show logs from last hour
# docker logs --until 30m ecommerce-frontend # Show logs until 30 minutes ago

# 8. Performance and Security Considerations:
# Performance: Can be slow for containers with large log volumes
# Security: May expose web server configuration information
# Best Practices: Use filters to limit output, monitor for sensitive data
# Privacy: Logs may contain user access patterns

# 9. Troubleshooting Scenarios:
# Error: "No such container: ecommerce-frontend"
# Solution: Check container name with docker ps -a
# Error: "No logs available"
# Solution: Container may not have generated logs yet
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker logs ecommerce-frontend
# Purpose: Retrieve frontend container logs for debugging and monitoring
# Context: Hands-on lab exercise for frontend container log analysis
# Expected Input: Frontend container name or ID
# Expected Output: Nginx web server logs from container stdout/stderr
# Error Conditions: Container not found, no logs available, permission denied
# Verification: Check output shows expected Nginx startup messages

### **Lab 3: Container Inspection and Analysis**

**📋 Overview**: This lab demonstrates how to inspect and analyze running containers for debugging and monitoring purposes.

### **Lab 4: Chaos Engineering Experiments**

**📋 Overview**: This lab introduces chaos engineering concepts by testing container resilience through controlled failure scenarios.

**🔍 Detailed Chaos Engineering Analysis**:

```bash
# Test 1: Container Restart Policy Testing
docker run -d --name test-container --restart=always ecommerce-backend:latest
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name test-container --restart=always ecommerce-backend:latest
# Purpose: Create and start a container with automatic restart policy for chaos engineering testing
# Category: Container Operations with Chaos Engineering
# Complexity: Intermediate
# Real-world Usage: High availability testing, resilience validation, chaos engineering

# 1. Command Overview:
# docker run creates a container with automatic restart policy
# Essential for testing application resilience and high availability
# Critical for chaos engineering and fault tolerance validation

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container with automatic restart policy
# - Starts the container in detached mode for background operation
# - Configures restart behavior for resilience testing
# - Enables chaos engineering experiments

# When to use docker run with restart policy:
# - Testing application resilience
# - Validating high availability configurations
# - Chaos engineering experiments
# - Production-like environment simulation

# Command relationships:
# - Often used with docker kill to test restart behavior
# - Works with docker ps to monitor container status
# - Used with docker logs to monitor restart events
# - Complementary to docker stop for controlled testing

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# --restart: Restart policy for the container
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --memory: Memory limit
# --cpus: CPU limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name test-container --restart=always ecommerce-backend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name test-container: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - --restart=always: Restart policy
#   - Container will restart automatically if it stops
#   - Applies to both manual stops and crashes
#   - Ensures high availability and resilience
# - ecommerce-backend:latest: Image specification
#   - ecommerce-backend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name test-container --restart=always ecommerce-backend:latest
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - Restart policy is applied and active

# 7. Flag Exploration Exercises:
# docker run -d --name test-container --restart=unless-stopped ecommerce-backend:latest  # Restart unless manually stopped
# docker run -d --name test-container --restart=on-failure ecommerce-backend:latest     # Restart only on failure
# docker run -d --name test-container --restart=no ecommerce-backend:latest             # No automatic restart
# docker run -d --name test-container --restart=always --memory=512m ecommerce-backend:latest  # With memory limit

# 8. Performance and Security Considerations:
# Performance: Restart policy may impact system resources during frequent restarts
# Security: Restart policies can mask security issues by automatically recovering
# Best Practices: Monitor restart frequency, use appropriate restart policies
# Privacy: Restart events are logged and may contain sensitive information

# 9. Troubleshooting Scenarios:
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "Restart policy not working"
# Solution: Check Docker daemon configuration and container logs

# 10. Complete Code Documentation:
# Command: docker run -d --name test-container --restart=always ecommerce-backend:latest
# Purpose: Deploy container with automatic restart policy for chaos engineering testing
# Context: Chaos engineering experiment for testing container resilience
# Expected Input: Docker image name and restart policy configuration
# Expected Output: Container ID and background container execution with restart policy
# Error Conditions: Name conflict, image not found, permission denied
# Verification: Check container status with docker ps and test restart behavior with docker kill

```bash
# Test 2: Resource Constraint Simulation
docker run -d --name memory-test --memory=100m --cpus=0.5 ecommerce-backend:latest
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name memory-test --memory=100m --cpus=0.5 ecommerce-backend:latest
# Purpose: Create and start a container with resource constraints for chaos engineering testing
# Category: Container Operations with Resource Management
# Complexity: Intermediate
# Real-world Usage: Resource testing, performance validation, chaos engineering

# 1. Command Overview:
# docker run creates a container with specific memory and CPU limits
# Essential for testing application behavior under resource constraints
# Critical for chaos engineering and performance validation

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container with resource constraints
# - Starts the container in detached mode for background operation
# - Applies memory and CPU limits for testing
# - Enables resource constraint chaos engineering experiments

# When to use docker run with resource limits:
# - Testing application behavior under resource constraints
# - Validating performance under limited resources
# - Chaos engineering experiments
# - Production-like resource constraint simulation

# Command relationships:
# - Often used with docker stats to monitor resource usage
# - Works with docker ps to monitor container status
# - Used with docker logs to monitor resource-related events
# - Complementary to docker exec for resource monitoring

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# --memory: Memory limit for the container
# --cpus: CPU limit for the container
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --oom-kill-disable: Disable OOM killer

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name memory-test --memory=100m --cpus=0.5 ecommerce-backend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name memory-test: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - --memory=100m: Memory limit
#   - Limits container to 100 megabytes of RAM
#   - Prevents container from using excessive memory
#   - Enables memory constraint testing
# - --cpus=0.5: CPU limit
#   - Limits container to 0.5 CPU cores
#   - Prevents container from using excessive CPU
#   - Enables CPU constraint testing
# - ecommerce-backend:latest: Image specification
#   - ecommerce-backend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name memory-test --memory=100m --cpus=0.5 ecommerce-backend:latest
# Expected Output:
# 0987654321cdef0987654321cdef0987654321cdef0987654321cdef0987654321cdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - Resource limits are applied and active

# 7. Flag Exploration Exercises:
# docker run -d --name memory-test --memory=512m --cpus=1.0 ecommerce-backend:latest  # Higher limits
# docker run -d --name memory-test --memory=50m --cpus=0.25 ecommerce-backend:latest  # Lower limits
# docker run -d --name memory-test --memory=100m ecommerce-backend:latest             # Memory only
# docker run -d --name memory-test --cpus=0.5 ecommerce-backend:latest               # CPU only

# 8. Performance and Security Considerations:
# Performance: Resource limits may impact application performance
# Security: Resource limits prevent resource exhaustion attacks
# Best Practices: Set appropriate limits based on application requirements
# Privacy: Resource usage patterns may reveal application behavior

# 9. Troubleshooting Scenarios:
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "Container killed due to memory limit"
# Solution: Increase memory limit or optimize application

# 10. Complete Code Documentation:
# Command: docker run -d --name memory-test --memory=100m --cpus=0.5 ecommerce-backend:latest
# Purpose: Deploy container with resource constraints for chaos engineering testing
# Context: Chaos engineering experiment for testing resource constraint behavior
# Expected Input: Docker image name and resource limit configuration
# Expected Output: Container ID and background container execution with resource limits
# Error Conditions: Name conflict, image not found, permission denied, resource limit exceeded
# Verification: Check container status with docker ps and monitor resource usage with docker stats

```bash
# Test 3: Network Partition Simulation
docker network create --driver bridge test-network
docker run -d --name backend-test --network test-network ecommerce-backend:latest
docker run -d --name frontend-test --network test-network ecommerce-frontend:latest
```

# =============================================================================
# DOCKER NETWORK CREATE COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker network create --driver bridge test-network
# Purpose: Create a custom Docker network for chaos engineering testing
# Category: Network Management
# Complexity: Intermediate
# Real-world Usage: Network isolation, chaos engineering, container networking

# 1. Command Overview:
# docker network create establishes a custom network for container communication
# Essential for network isolation and chaos engineering experiments
# Critical for testing network dependencies and failure modes

# 2. Command Purpose and Context:
# What docker network create does:
# - Creates a new Docker network with specified driver
# - Establishes network isolation for testing
# - Enables controlled network communication
# - Provides foundation for chaos engineering experiments

# When to use docker network create:
# - Testing network isolation
# - Chaos engineering experiments
# - Container communication testing
# - Network failure simulation

# Command relationships:
# - Often used with docker run --network to connect containers
# - Works with docker network ls to list networks
# - Used with docker network rm to remove networks
# - Complementary to docker network inspect for network details

# 3. Complete Flag Reference:
# docker network create [OPTIONS] NETWORK
# Options used in this command:
# --driver: Network driver to use
# Additional useful flags:
# --subnet: Subnet in CIDR format
# --gateway: Gateway for the subnet
# --ip-range: Allocate container IP from a range
# --aux-address: Auxiliary IPv4 or IPv6 addresses

# 4. Flag Discovery Methods:
# docker network create --help          # Show all available options
# man docker-network-create             # Manual page with complete documentation
# docker --help | grep network          # Filter help for network commands

# 5. Structured Command Analysis Section:
# Command: docker network create --driver bridge test-network
# - docker network create: Command to create a new Docker network
# - --driver bridge: Network driver specification
#   - bridge: Default network driver for single-host networking
#   - Enables container-to-container communication
#   - Provides network isolation from other networks
# - test-network: Network name
#   - Custom name for the network
#   - Must be unique on the host
#   - Used for container network assignment

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker network create --driver bridge test-network
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - Network ID (64-character hexadecimal)
# - Network created successfully
# - Network is ready for container assignment

# 7. Flag Exploration Exercises:
# docker network create --driver bridge --subnet=172.20.0.0/16 test-network  # Custom subnet
# docker network create --driver bridge --gateway=172.20.0.1 test-network    # Custom gateway
# docker network create --driver host test-network                           # Host network
# docker network create --driver none test-network                           # No network

# 8. Performance and Security Considerations:
# Performance: Network creation is fast with minimal system impact
# Security: Network isolation provides security boundaries
# Best Practices: Use appropriate network drivers for use case
# Privacy: Network names may reveal system information

# 9. Troubleshooting Scenarios:
# Error: "Network name already exists"
# Solution: Use different name or remove existing network
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "Driver not available"
# Solution: Check available drivers with docker info

# 10. Complete Code Documentation:
# Command: docker network create --driver bridge test-network
# Purpose: Create custom network for chaos engineering testing
# Context: Chaos engineering experiment for network isolation testing
# Expected Input: Network driver and custom network name
# Expected Output: Network ID and successful network creation
# Error Conditions: Name conflict, permission denied, driver unavailable
# Verification: Check network creation with docker network ls

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name backend-test --network test-network ecommerce-backend:latest
# Purpose: Create and start a container on a custom network for chaos engineering testing
# Category: Container Operations with Network Management
# Complexity: Intermediate
# Real-world Usage: Network testing, chaos engineering, container networking

# 1. Command Overview:
# docker run creates a container on a specific network
# Essential for network isolation testing and chaos engineering
# Critical for testing network dependencies and communication

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container on the specified network
# - Starts the container in detached mode for background operation
# - Connects container to custom network for testing
# - Enables network isolation chaos engineering experiments

# When to use docker run with custom network:
# - Testing network isolation
# - Chaos engineering experiments
# - Container communication testing
# - Network failure simulation

# Command relationships:
# - Often used with docker network create to establish network
# - Works with docker ps to monitor container status
# - Used with docker network inspect to verify network connectivity
# - Complementary to docker network disconnect for testing

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# --network: Connect container to a network
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --memory: Memory limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name backend-test --network test-network ecommerce-backend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name backend-test: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - --network test-network: Network assignment
#   - Connects container to custom network
#   - Enables network isolation testing
#   - Provides controlled network communication
# - ecommerce-backend:latest: Image specification
#   - ecommerce-backend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name backend-test --network test-network ecommerce-backend:latest
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - Container is connected to test-network

# 7. Flag Exploration Exercises:
# docker run -d --name backend-test --network test-network --memory=512m ecommerce-backend:latest  # With memory limit
# docker run -d --name backend-test --network test-network --restart=always ecommerce-backend:latest  # With restart policy
# docker run -it --name backend-test --network test-network ecommerce-backend:latest /bin/bash  # Interactive mode
# docker run --rm --name backend-test --network test-network ecommerce-backend:latest  # Auto-remove

# 8. Performance and Security Considerations:
# Performance: Network assignment has minimal impact on container startup
# Security: Network isolation provides security boundaries
# Best Practices: Use appropriate networks for testing scenarios
# Privacy: Network names may reveal system information

# 9. Troubleshooting Scenarios:
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Network not found"
# Solution: Create the network first with docker network create
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker run -d --name backend-test --network test-network ecommerce-backend:latest
# Purpose: Deploy container on custom network for chaos engineering testing
# Context: Chaos engineering experiment for network isolation testing
# Expected Input: Docker image name and custom network name
# Expected Output: Container ID and background container execution on custom network
# Error Conditions: Name conflict, network not found, image not found, permission denied
# Verification: Check container status with docker ps and network connectivity with docker network inspect

```bash
# Test 4: Storage Failure Simulation
docker run -d --name storage-test -v /tmp/test-data:/app/data ecommerce-backend:latest
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name storage-test -v /tmp/test-data:/app/data ecommerce-backend:latest
# Purpose: Create and start a container with volume mount for storage failure testing
# Category: Container Operations with Storage Management
# Complexity: Intermediate
# Real-world Usage: Storage testing, chaos engineering, data persistence validation

# 1. Command Overview:
# docker run creates a container with volume mount for data persistence
# Essential for testing storage failure scenarios and data persistence
# Critical for chaos engineering and storage resilience validation

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container with volume mount
# - Starts the container in detached mode for background operation
# - Mounts host directory as volume for data persistence
# - Enables storage failure chaos engineering experiments

# When to use docker run with volume mount:
# - Testing data persistence
# - Chaos engineering experiments
# - Storage failure simulation
# - Data backup and recovery testing

# Command relationships:
# - Often used with docker volume create for named volumes
# - Works with docker ps to monitor container status
# - Used with docker logs to monitor storage-related events
# - Complementary to docker volume inspect for volume details

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# -v, --volume: Mount a volume
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --memory: Memory limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name storage-test -v /tmp/test-data:/app/data ecommerce-backend:latest
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name storage-test: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - -v /tmp/test-data:/app/data: Volume mount
#   - Mounts host directory /tmp/test-data to container directory /app/data
#   - Enables data persistence between container and host
#   - Provides foundation for storage failure testing
# - ecommerce-backend:latest: Image specification
#   - ecommerce-backend: Image name
#   - latest: Image tag (version)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name storage-test -v /tmp/test-data:/app/data ecommerce-backend:latest
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - Volume mount is established and active

# 7. Flag Exploration Exercises:
# docker run -d --name storage-test -v /tmp/test-data:/app/data:ro ecommerce-backend:latest  # Read-only mount
# docker run -d --name storage-test -v /tmp/test-data:/app/data:rw ecommerce-backend:latest  # Read-write mount
# docker run -d --name storage-test -v /tmp/test-data:/app/data:z ecommerce-backend:latest  # SELinux labeling
# docker run -d --name storage-test -v /tmp/test-data:/app/data:Z ecommerce-backend:latest  # Private SELinux labeling

# 8. Performance and Security Considerations:
# Performance: Volume mounts may impact I/O performance
# Security: Volume mounts can expose host filesystem
# Best Practices: Use appropriate mount options, validate host paths
# Privacy: Volume mounts may expose sensitive host data

# 9. Troubleshooting Scenarios:
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Host path does not exist"
# Solution: Create the host directory first with mkdir -p /tmp/test-data
# Error: "Permission denied"
# Solution: Check directory permissions or use sudo
# Error: "Mount point not accessible"
# Solution: Verify container image has the target directory

# 10. Complete Code Documentation:
# Command: docker run -d --name storage-test -v /tmp/test-data:/app/data ecommerce-backend:latest
# Purpose: Deploy container with volume mount for storage failure testing
# Context: Chaos engineering experiment for storage resilience testing
# Expected Input: Docker image name and volume mount configuration
# Expected Output: Container ID and background container execution with volume mount
# Error Conditions: Name conflict, host path not found, permission denied, mount point inaccessible
# Verification: Check container status with docker ps and volume mount with docker inspect

**🔧 Chaos Engineering Commands**:

```bash
# Monitor container resource usage during chaos tests
docker stats --no-stream
```

# =============================================================================
# DOCKER STATS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker stats --no-stream
# Purpose: Display real-time resource usage statistics for all running containers
# Category: Container Monitoring
# Complexity: Intermediate
# Real-world Usage: Performance monitoring, resource analysis, system administration

# 1. Command Overview:
# docker stats displays real-time resource usage statistics for containers
# Essential for monitoring container performance and resource consumption
# Critical for system administration and performance optimization

# 2. Command Purpose and Context:
# What docker stats does:
# - Displays real-time resource usage statistics for containers
# - Shows CPU, memory, network, and disk I/O usage
# - Provides performance monitoring capabilities
# - Enables resource consumption analysis

# When to use docker stats:
# - Monitoring container performance
# - Analyzing resource consumption
# - System administration and troubleshooting
# - Performance optimization and capacity planning

# Command relationships:
# - Often used with docker ps to identify running containers
# - Works with docker logs to correlate performance with application behavior
# - Used with docker top to get detailed process information
# - Complementary to docker system df for disk usage analysis

# 3. Complete Flag Reference:
# docker stats [OPTIONS] [CONTAINER...]
# Options used in this command:
# --no-stream: Disable streaming stats and only pull the first result
# Additional useful flags:
# --format: Pretty-print stats using a Go template
# --all, -a: Show all containers (default shows just running)
# --no-trunc: Don't truncate output

# 4. Flag Discovery Methods:
# docker stats --help          # Show all available options
# man docker-stats             # Manual page with complete documentation
# docker --help | grep stats   # Filter help for stats command

# 5. Structured Command Analysis Section:
# Command: docker stats --no-stream
# - docker stats: Command to display container resource usage statistics
# - --no-stream: Disable streaming flag
#   - Shows statistics only once instead of continuous updates
#   - Useful for scripting and automation
#   - Prevents continuous output that can interfere with other commands
# - No container specified: Shows statistics for all running containers

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker stats --no-stream
# Expected Output:
# CONTAINER ID   NAME                CPU %     MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O        PIDS
# 1234567890ab  ecommerce-backend   0.15%     45.2MiB / 512MiB      8.83%     1.2kB / 856B     0B / 0B         15
# 0987654321cd  ecommerce-frontend  0.05%     12.8MiB / 256MiB      5.00%     856B / 1.2kB     0B / 0B         8
# 
# Output Analysis:
# - CONTAINER ID: Unique container identifier (first 12 characters)
# - NAME: Container name
# - CPU %: CPU usage percentage
# - MEM USAGE / LIMIT: Memory usage and limit
# - MEM %: Memory usage percentage
# - NET I/O: Network input/output
# - BLOCK I/O: Block device input/output
# - PIDS: Number of processes

# 7. Flag Exploration Exercises:
# docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"  # Custom format
# docker stats --no-stream --all  # Show all containers including stopped
# docker stats --no-stream ecommerce-backend  # Show specific container
# docker stats --no-stream --no-trunc  # Show full output without truncation

# 8. Performance and Security Considerations:
# Performance: Minimal impact on system performance
# Security: Reveals resource usage patterns and system information
# Best Practices: Use for monitoring, combine with filters for specific needs
# Privacy: May expose resource usage patterns and system information

# 9. Troubleshooting Scenarios:
# Error: "Cannot connect to the Docker daemon"
# Solution: Check if Docker daemon is running with sudo systemctl status docker
# Error: "No containers showing"
# Solution: Check if containers are running with docker ps
# Error: "Permission denied"
# Solution: Add user to docker group or use sudo

# 10. Complete Code Documentation:
# Command: docker stats --no-stream
# Purpose: Monitor container resource usage for chaos engineering testing
# Context: Chaos engineering experiment for resource monitoring and analysis
# Expected Input: No input required
# Expected Output: Table of container resource usage statistics
# Error Conditions: Docker daemon not running, permission denied
# Verification: Check output shows expected containers with resource usage data

```bash
# Check container logs for error patterns
docker logs --tail 100 -f test-container
```

# =============================================================================
# DOCKER LOGS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker logs --tail 100 -f test-container
# Purpose: Display and follow container logs with tail functionality for chaos engineering monitoring
# Category: Container Monitoring and Logging
# Complexity: Intermediate
# Real-world Usage: Log monitoring, error analysis, chaos engineering validation

# 1. Command Overview:
# docker logs displays and follows container logs with tail functionality
# Essential for monitoring container behavior during chaos engineering experiments
# Critical for error analysis and application behavior validation

# 2. Command Purpose and Context:
# What docker logs does:
# - Displays container logs with tail functionality
# - Follows log output in real-time
# - Shows recent log entries for analysis
# - Enables continuous monitoring during chaos experiments

# When to use docker logs with tail and follow:
# - Monitoring container behavior during chaos experiments
# - Analyzing error patterns and application behavior
# - Real-time log monitoring and validation
# - Troubleshooting and debugging container issues

# Command relationships:
# - Often used with docker stats to correlate performance with logs
# - Works with docker ps to identify running containers
# - Used with docker exec to access container for debugging
# - Complementary to docker logs without flags for complete log history

# 3. Complete Flag Reference:
# docker logs [OPTIONS] CONTAINER
# Options used in this command:
# --tail: Number of lines to show from the end of logs
# -f, --follow: Follow log output
# Additional useful flags:
# --timestamps: Show timestamps
# --since: Show logs since timestamp
# --until: Show logs before timestamp
# --details: Show extra details

# 4. Flag Discovery Methods:
# docker logs --help          # Show all available options
# man docker-logs             # Manual page with complete documentation
# docker --help | grep logs   # Filter help for logs command

# 5. Structured Command Analysis Section:
# Command: docker logs --tail 100 -f test-container
# - docker logs: Command to display container logs
# - --tail 100: Tail flag with line count
#   - Shows last 100 lines of log output
#   - Provides recent log history for analysis
#   - Useful for focusing on recent events
# - -f: Follow flag
#   - Follows log output in real-time
#   - Continues to display new log entries
#   - Enables continuous monitoring
# - test-container: Container name
#   - Specifies which container to monitor
#   - Must be a running or stopped container

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker logs --tail 100 -f test-container
# Expected Output:
# 2024-01-15T10:30:15.123Z INFO: Application started successfully
# 2024-01-15T10:30:16.456Z INFO: Database connection established
# 2024-01-15T10:30:17.789Z INFO: Server listening on port 8000
# 2024-01-15T10:30:18.012Z INFO: Health check endpoint responding
# 2024-01-15T10:30:19.345Z ERROR: Connection timeout to external service
# 2024-01-15T10:30:20.678Z INFO: Retrying connection...
# 
# Output Analysis:
# - Timestamp: ISO 8601 format timestamp
# - Log Level: INFO, ERROR, WARN, DEBUG levels
# - Message: Detailed log message content
# - Real-time updates: New entries appear as they occur

# 7. Flag Exploration Exercises:
# docker logs --tail 50 -f test-container  # Show last 50 lines
# docker logs --tail 100 --timestamps test-container  # Show with timestamps
# docker logs --tail 100 --since 2024-01-15T10:30:00 test-container  # Show since timestamp
# docker logs --tail 100 --details test-container  # Show extra details

# 8. Performance and Security Considerations:
# Performance: Minimal impact on container performance
# Security: Logs may contain sensitive information
# Best Practices: Use appropriate tail count, monitor log rotation
# Privacy: Logs may expose application behavior and sensitive data

# 9. Troubleshooting Scenarios:
# Error: "Container not found"
# Solution: Check container name with docker ps
# Error: "Container not running"
# Solution: Start the container first with docker start
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "No logs available"
# Solution: Check if container has generated logs

# 10. Complete Code Documentation:
# Command: docker logs --tail 100 -f test-container
# Purpose: Monitor container logs during chaos engineering experiments
# Context: Chaos engineering experiment for log monitoring and error analysis
# Expected Input: Container name and log monitoring parameters
# Expected Output: Real-time log output with recent history
# Error Conditions: Container not found, not running, permission denied
# Verification: Check output shows expected log entries and real-time updates

```bash
# Simulate network connectivity issues
docker network disconnect bridge test-container
```

# =============================================================================
# DOCKER NETWORK DISCONNECT COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker network disconnect bridge test-container
# Purpose: Disconnect a container from a network for chaos engineering testing
# Category: Network Management
# Complexity: Intermediate
# Real-world Usage: Network testing, chaos engineering, connectivity simulation

# 1. Command Overview:
# docker network disconnect removes a container from a specific network
# Essential for testing network failure scenarios and chaos engineering
# Critical for simulating network connectivity issues and failure modes

# 2. Command Purpose and Context:
# What docker network disconnect does:
# - Removes a container from a specific network
# - Simulates network connectivity issues
# - Enables network failure testing
# - Provides foundation for chaos engineering experiments

# When to use docker network disconnect:
# - Testing network failure scenarios
# - Chaos engineering experiments
# - Simulating connectivity issues
# - Network isolation testing

# Command relationships:
# - Often used with docker network connect to restore connectivity
# - Works with docker network ls to list available networks
# - Used with docker network inspect to verify network status
# - Complementary to docker run --network for initial network assignment

# 3. Complete Flag Reference:
# docker network disconnect [OPTIONS] NETWORK CONTAINER
# Options used in this command:
# No additional flags used in this command
# Additional useful flags:
# --force: Force the container to disconnect from the network

# 4. Flag Discovery Methods:
# docker network disconnect --help          # Show all available options
# man docker-network-disconnect             # Manual page with complete documentation
# docker --help | grep network              # Filter help for network commands

# 5. Structured Command Analysis Section:
# Command: docker network disconnect bridge test-container
# - docker network disconnect: Command to disconnect container from network
# - bridge: Network name
#   - Specifies which network to disconnect from
#   - bridge is the default Docker network
#   - Must be an existing network
# - test-container: Container name
#   - Specifies which container to disconnect
#   - Must be a running or stopped container
#   - Container must be connected to the specified network

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker network disconnect bridge test-container
# Expected Output:
# (No output on success)
# 
# Output Analysis:
# - No output indicates successful disconnection
# - Container is removed from the specified network
# - Network connectivity is lost for the container

# 7. Flag Exploration Exercises:
# docker network disconnect --force bridge test-container  # Force disconnection
# docker network disconnect test-network test-container    # Disconnect from custom network
# docker network disconnect bridge test-container --force  # Force disconnection with flag order

# 8. Performance and Security Considerations:
# Performance: Minimal impact on system performance
# Security: Network disconnection may affect application security
# Best Practices: Use for testing, restore connectivity after testing
# Privacy: Network disconnection may expose application behavior

# 9. Troubleshooting Scenarios:
# Error: "Network not found"
# Solution: Check network name with docker network ls
# Error: "Container not found"
# Solution: Check container name with docker ps
# Error: "Container not connected to network"
# Solution: Verify container network connection with docker network inspect
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker network disconnect bridge test-container
# Purpose: Disconnect container from network for chaos engineering testing
# Context: Chaos engineering experiment for network failure simulation
# Expected Input: Network name and container name
# Expected Output: No output on successful disconnection
# Error Conditions: Network not found, container not found, not connected, permission denied
# Verification: Check network connectivity with docker network inspect

```bash
# Test container health checks
docker inspect test-container | grep -A 10 Health
```

# =============================================================================
# DOCKER INSPECT COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker inspect test-container | grep -A 10 Health
# Purpose: Inspect container configuration and filter health check information
# Category: Container Inspection and Analysis
# Complexity: Intermediate
# Real-world Usage: Container analysis, health check validation, configuration inspection

# 1. Command Overview:
# docker inspect displays detailed configuration information for containers
# Essential for analyzing container configuration and health status
# Critical for troubleshooting and validation of container settings

# 2. Command Purpose and Context:
# What docker inspect does:
# - Displays detailed configuration information for containers
# - Shows container metadata, configuration, and status
# - Provides comprehensive container analysis
# - Enables health check validation and troubleshooting

# When to use docker inspect:
# - Analyzing container configuration
# - Validating health check settings
# - Troubleshooting container issues
# - Inspecting container metadata and status

# Command relationships:
# - Often used with grep to filter specific information
# - Works with docker ps to identify containers
# - Used with docker logs to correlate configuration with behavior
# - Complementary to docker exec for container access

# 3. Complete Flag Reference:
# docker inspect [OPTIONS] NAME|ID [NAME|ID...]
# Options used in this command:
# No additional flags used in this command
# Additional useful flags:
# --format: Format output using a Go template
# --type: Return JSON for specified type
# --size: Display total file sizes

# 4. Flag Discovery Methods:
# docker inspect --help          # Show all available options
# man docker-inspect             # Manual page with complete documentation
# docker --help | grep inspect   # Filter help for inspect command

# 5. Structured Command Analysis Section:
# Command: docker inspect test-container | grep -A 10 Health
# - docker inspect: Command to display container configuration
# - test-container: Container name
#   - Specifies which container to inspect
#   - Must be an existing container (running or stopped)
#   - Can also use container ID
# - |: Pipe operator
#   - Redirects output to the next command
#   - Enables command chaining and filtering
# - grep -A 10 Health: Filter command
#   - grep: Search for patterns in text
#   - -A 10: Show 10 lines after the match
#   - Health: Search pattern for health-related information

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker inspect test-container | grep -A 10 Health
# Expected Output:
# "Health": {
#     "Status": "healthy",
#     "FailingStreak": 0,
#     "Log": [
#         {
#             "Start": "2024-01-15T10:30:00.000Z",
#             "End": "2024-01-15T10:30:05.000Z",
#             "ExitCode": 0,
#             "Output": "Health check passed"
#         }
#     ]
# }
# 
# Output Analysis:
# - Status: Current health status (healthy, unhealthy, starting)
# - FailingStreak: Number of consecutive failed health checks
# - Log: Array of health check execution logs
# - Start/End: Timestamps of health check execution
# - ExitCode: Health check exit code (0 = success)
# - Output: Health check output message

# 7. Flag Exploration Exercises:
# docker inspect --format '{{.State.Health.Status}}' test-container  # Get only health status
# docker inspect --format '{{.Config.Healthcheck}}' test-container   # Get health check configuration
# docker inspect --format '{{.State.Status}}' test-container         # Get container status
# docker inspect --format '{{.NetworkSettings.IPAddress}}' test-container  # Get IP address

# 8. Performance and Security Considerations:
# Performance: Minimal impact on container performance
# Security: May expose sensitive configuration information
# Best Practices: Use appropriate filters, avoid exposing sensitive data
# Privacy: Configuration may contain sensitive information

# 9. Troubleshooting Scenarios:
# Error: "Container not found"
# Solution: Check container name with docker ps -a
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "No health check configured"
# Solution: Check if container has health check configured
# Error: "grep: command not found"
# Solution: Install grep or use alternative filtering

# 10. Complete Code Documentation:
# Command: docker inspect test-container | grep -A 10 Health
# Purpose: Inspect container health check configuration and status
# Context: Chaos engineering experiment for health check validation
# Expected Input: Container name and health check filter
# Expected Output: Health check configuration and status information
# Error Conditions: Container not found, permission denied, no health check
# Verification: Check output shows expected health check information

**📊 Chaos Engineering Results Analysis**:

1. **Container Restart Behavior**: Document restart frequency and success rate
2. **Resource Constraint Impact**: Measure performance degradation under limits
3. **Network Failure Recovery**: Test application resilience to network issues
4. **Storage Failure Handling**: Verify data persistence and recovery mechanisms

**🎯 Chaos Engineering Learning Objectives**:
- Understand failure modes in containerized applications
- Learn to design resilient container architectures
- Practice monitoring and observability during failures
- Develop troubleshooting skills for production issues

**🔍 Detailed Command Analysis**:

```bash
# Inspect container configuration
docker inspect ecommerce-backend
```
**Explanation**:
- `docker inspect <container-name>`: Returns detailed information about a container
- **Output includes**: Configuration, network settings, environment variables, mounts, etc.
- **JSON format**: Returns data in JSON format for programmatic access
- **Use cases**: Debugging configuration issues, understanding container setup
- **Example output**: Shows all container metadata, including IP address, port mappings, environment variables

```bash
# Check container resource usage
docker stats ecommerce-backend ecommerce-frontend
```
**Explanation**:
- `docker stats <container-names>`: Shows real-time resource usage statistics
- **Metrics shown**: CPU usage, memory usage, network I/O, block I/O
- **Real-time**: Updates continuously (use Ctrl+C to exit)
- **Monitoring**: Essential for performance analysis and capacity planning
- **Columns**: CONTAINER ID, NAME, CPU %, MEM USAGE / LIMIT, MEM %, NET I/O, BLOCK I/O, PIDs

```bash
# Execute commands inside running container
docker exec -it ecommerce-backend /bin/bash
```
**Explanation**:
- `docker exec`: Execute a command in a running container
- `-i`: Interactive mode (keeps STDIN open)
- `-t`: Allocate a pseudo-TTY (terminal)
- `ecommerce-backend`: Target container name
- `/bin/bash`: Command to execute (starts bash shell)
- **Result**: Opens an interactive bash session inside the container
- **Use cases**: Debugging, file system inspection, manual testing

```bash
# Check container processes
docker exec ecommerce-backend ps aux
```
**Explanation**:
- `docker exec ecommerce-backend ps aux`: Runs ps command inside the container
- `ps aux`: Lists all running processes with detailed information
- **Output shows**: Process ID, CPU usage, memory usage, command, etc.
- **Debugging**: Helps identify what processes are running inside the container
- **Security**: Verify only expected processes are running

```bash
# Check container network
docker network ls
docker network inspect bridge
```
**Explanation**:
- `docker network ls`: Lists all Docker networks
- **Default networks**: bridge (default), host, none
- **Custom networks**: Any user-created networks
- `docker network inspect bridge`: Shows detailed information about the bridge network
- **Bridge network**: Default network where containers communicate
- **Information includes**: Network ID, driver, IP range, connected containers
- **Debugging**: Helps understand container networking and connectivity issues

---

## 🎯 **Practice Problems**

### **Problem 1: Container Optimization**

**Scenario**: Your e-commerce backend container is using too much memory. Optimize it.

**Requirements**:
1. Analyze current resource usage
2. Identify optimization opportunities
3. Implement multi-stage build improvements
4. Reduce image size by at least 30%

**DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**:

**Step 1: Analyze Current Resource Usage**
```bash
# Navigate to your e-commerce project
cd /path/to/your/e-commerce

# Create analysis directory
mkdir -p container-optimization
cd container-optimization

# Create current Dockerfile for analysis
cat > Dockerfile.current << 'EOF'
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "main.py"]
EOF

# Build current image
docker build -f Dockerfile.current -t ecommerce-backend:current .
```

# =============================================================================
# DOCKER BUILD COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker build -f Dockerfile.current -t ecommerce-backend:current .
# Purpose: Build a Docker image from a Dockerfile with custom filename and tag
# Category: Image Building and Management
# Complexity: Intermediate
# Real-world Usage: Image creation, application packaging, containerization

# 1. Command Overview:
# docker build creates a Docker image from a Dockerfile
# Essential for containerizing applications and creating deployable images
# Critical for application packaging and deployment pipeline

# 2. Command Purpose and Context:
# What docker build does:
# - Creates a Docker image from a Dockerfile
# - Builds application containerization
# - Packages application with dependencies
# - Enables application deployment and distribution

# When to use docker build:
# - Containerizing applications
# - Creating deployable images
# - Building application packages
# - Setting up development environments

# Command relationships:
# - Often used with docker run to run the built image
# - Works with docker images to list built images
# - Used with docker push to distribute images
# - Complementary to docker tag for image versioning

# 3. Complete Flag Reference:
# docker build [OPTIONS] PATH | URL | -
# Options used in this command:
# -f, --file: Name of the Dockerfile
# -t, --tag: Name and optionally a tag in the 'name:tag' format
# Additional useful flags:
# --build-arg: Set build-time variables
# --no-cache: Do not use cache when building the image
# --pull: Always attempt to pull a newer version of the image
# --rm: Remove intermediate containers after a successful build

# 4. Flag Discovery Methods:
# docker build --help          # Show all available options
# man docker-build             # Manual page with complete documentation
# docker --help | grep build   # Filter help for build command

# 5. Structured Command Analysis Section:
# Command: docker build -f Dockerfile.current -t ecommerce-backend:current .
# - docker build: Command to build a Docker image
# - -f Dockerfile.current: Custom Dockerfile specification
#   - Uses Dockerfile.current instead of default Dockerfile
#   - Enables multiple Dockerfile configurations
#   - Allows for different build configurations
# - -t ecommerce-backend:current: Image tagging
#   - ecommerce-backend: Image name
#   - current: Image tag (version identifier)
#   - Enables image identification and versioning
# - .: Build context
#   - Current directory as build context
#   - Contains source code and Dockerfile
#   - Defines what files are available during build

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker build -f Dockerfile.current -t ecommerce-backend:current .
# Expected Output:
# Sending build context to Docker daemon  2.048kB
# Step 1/5 : FROM python:3.9
# 3.9: Pulling from library/python
# 1234567890ab: Pull complete
# 0987654321cd: Pull complete
# def456ghi789: Pull complete
# Step 2/5 : WORKDIR /app
# ---> Running in abc123def456
# ---> def456ghi789
# Step 3/5 : COPY requirements.txt .
# ---> 1234567890ab
# Step 4/5 : RUN pip install -r requirements.txt
# ---> Running in 0987654321cd
# Collecting requests==2.28.1
# Installing collected packages: requests
# Successfully installed requests-2.28.1
# ---> abc123def456
# Step 5/5 : COPY . .
# ---> 1234567890ab
# Successfully built 1234567890ab
# Successfully tagged ecommerce-backend:current
# 
# Output Analysis:
# - Sending build context: Uploading build context to Docker daemon
# - Step X/Y: Build step progress (current step / total steps)
# - FROM python:3.9: Base image specification
# - Pulling from library/python: Downloading base image
# - Pull complete: Base image download completed
# - WORKDIR /app: Setting working directory
# - COPY requirements.txt .: Copying dependency file
# - RUN pip install: Installing Python dependencies
# - Successfully built: Image build completed
# - Successfully tagged: Image tagged with specified name and tag

# 7. Flag Exploration Exercises:
# docker build -f Dockerfile.current -t ecommerce-backend:current --no-cache .  # Build without cache
# docker build -f Dockerfile.current -t ecommerce-backend:current --build-arg VERSION=1.0 .  # With build args
# docker build -f Dockerfile.current -t ecommerce-backend:current --pull .  # Always pull base image
# docker build -f Dockerfile.current -t ecommerce-backend:current --rm .  # Remove intermediate containers

# 8. Performance and Security Considerations:
# Performance: Build time depends on image size and complexity
# Security: Build context may contain sensitive files
# Best Practices: Use .dockerignore, minimize build context, use multi-stage builds
# Privacy: Build context may expose source code and sensitive information

# 9. Troubleshooting Scenarios:
# Error: "Dockerfile not found"
# Solution: Check if Dockerfile.current exists in the current directory
# Error: "Build context not found"
# Solution: Ensure you're in the correct directory with source code
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "Base image not found"
# Solution: Check internet connection and base image availability

# 10. Complete Code Documentation:
# Command: docker build -f Dockerfile.current -t ecommerce-backend:current .
# Purpose: Build ecommerce backend image with custom Dockerfile for optimization testing
# Context: Image optimization exercise for comparing current and optimized builds
# Expected Input: Custom Dockerfile and build context directory
# Expected Output: Successfully built and tagged Docker image
# Error Conditions: Dockerfile not found, build context missing, permission denied
# Verification: Check image creation with docker images and verify tag with docker inspect

```bash
# Analyze image size
echo "=== CURRENT IMAGE ANALYSIS ==="
docker images ecommerce-backend:current

# Get detailed image information
docker history ecommerce-backend:current
```

# =============================================================================
# DOCKER HISTORY COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker history ecommerce-backend:current
# Purpose: Display the history of an image showing all layers and their sizes
# Category: Image Analysis and Management
# Complexity: Intermediate
# Real-world Usage: Image analysis, layer optimization, size reduction

# 1. Command Overview:
# docker history displays the history of an image showing all layers
# Essential for analyzing image composition and identifying optimization opportunities
# Critical for understanding image structure and layer dependencies

# 2. Command Purpose and Context:
# What docker history does:
# - Displays the history of an image showing all layers
# - Shows layer sizes and creation information
# - Provides insight into image composition
# - Enables layer optimization and size reduction

# When to use docker history:
# - Analyzing image composition
# - Identifying optimization opportunities
# - Understanding layer dependencies
# - Troubleshooting image issues

# Command relationships:
# - Often used with docker images to get image overview
# - Works with docker build to understand build process
# - Used with docker inspect for detailed image information
# - Complementary to docker system df for disk usage analysis

# 3. Complete Flag Reference:
# docker history [OPTIONS] IMAGE
# Options used in this command:
# No additional flags used in this command
# Additional useful flags:
# --format: Pretty-print using a Go template
# --human: Print sizes and dates in human readable format
# --no-trunc: Don't truncate output
# --quiet: Only show numeric IDs

# 4. Flag Discovery Methods:
# docker history --help          # Show all available options
# man docker-history             # Manual page with complete documentation
# docker --help | grep history   # Filter help for history command

# 5. Structured Command Analysis Section:
# Command: docker history ecommerce-backend:current
# - docker history: Command to display image history
# - ecommerce-backend:current: Image specification
#   - ecommerce-backend: Image name
#   - current: Image tag (version identifier)
#   - Must be an existing image

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker history ecommerce-backend:current
# Expected Output:
# IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
# 1234567890ab  2 hours ago    /bin/sh -c #(nop)  CMD ["python" "main.py"]    0B        buildkit.dockerfile.v0
# 0987654321cd  2 hours ago    /bin/sh -c #(nop)  EXPOSE 8000                 0B        buildkit.dockerfile.v0
# def456ghi789  2 hours ago    /bin/sh -c #(nop)  COPY . .                     2.1MB     buildkit.dockerfile.v0
# abc123def456  2 hours ago    /bin/sh -c pip install -r requirements.txt     45.2MB    buildkit.dockerfile.v0
# 456789abcdef  2 hours ago    /bin/sh -c #(nop)  COPY requirements.txt .      1.2MB     buildkit.dockerfile.v0
# 789abcdef123  2 hours ago    /bin/sh -c #(nop)  WORKDIR /app                 0B        buildkit.dockerfile.v0
# 321654987fed  2 hours ago    /bin/sh -c #(nop)  FROM python:3.9              900MB     buildkit.dockerfile.v0
# 
# Output Analysis:
# - IMAGE: Layer ID (first 12 characters)
# - CREATED: When the layer was created
# - CREATED BY: Command that created the layer
# - SIZE: Size of the layer
# - COMMENT: Additional information about the layer

# 7. Flag Exploration Exercises:
# docker history --human ecommerce-backend:current  # Human readable format
# docker history --format "table {{.ID}}\t{{.Size}}\t{{.CreatedBy}}" ecommerce-backend:current  # Custom format
# docker history --no-trunc ecommerce-backend:current  # Show full output
# docker history --quiet ecommerce-backend:current  # Show only IDs

# 8. Performance and Security Considerations:
# Performance: Fast operation with minimal system impact
# Security: May expose build process and layer information
# Best Practices: Use for analysis, combine with other tools for optimization
# Privacy: May expose build process and application structure

# 9. Troubleshooting Scenarios:
# Error: "Image not found"
# Solution: Check image name and tag with docker images
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "No history available"
# Solution: Check if image exists and is accessible

# 10. Complete Code Documentation:
# Command: docker history ecommerce-backend:current
# Purpose: Analyze image layers and composition for optimization
# Context: Image optimization exercise for understanding current image structure
# Expected Input: Image name and tag
# Expected Output: Table of image layers with sizes and creation information
# Error Conditions: Image not found, permission denied
# Verification: Check output shows expected layers with correct sizes and creation information

# Analyze layers and sizes
docker inspect ecommerce-backend:current | jq '.[0].Size'
```

# =============================================================================
# DOCKER INSPECT COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker inspect ecommerce-backend:current | jq '.[0].Size'
# Purpose: Inspect image configuration and extract size information using jq
# Category: Image Analysis and Management
# Complexity: Intermediate
# Real-world Usage: Image analysis, size extraction, configuration inspection

# 1. Command Overview:
# docker inspect displays detailed configuration information for images
# Essential for analyzing image metadata and extracting specific information
# Critical for image analysis and configuration validation

# 2. Command Purpose and Context:
# What docker inspect does:
# - Displays detailed configuration information for images
# - Shows image metadata, configuration, and properties
# - Provides comprehensive image analysis
# - Enables specific information extraction

# When to use docker inspect:
# - Analyzing image configuration
# - Extracting specific image properties
# - Validating image metadata
# - Inspecting image details

# Command relationships:
# - Often used with jq to filter and extract specific information
# - Works with docker images to get image overview
# - Used with docker history to understand image composition
# - Complementary to docker build for configuration validation

# 3. Complete Flag Reference:
# docker inspect [OPTIONS] NAME|ID [NAME|ID...]
# Options used in this command:
# No additional flags used in this command
# Additional useful flags:
# --format: Format output using a Go template
# --type: Return JSON for specified type
# --size: Display total file sizes

# 4. Flag Discovery Methods:
# docker inspect --help          # Show all available options
# man docker-inspect             # Manual page with complete documentation
# docker --help | grep inspect   # Filter help for inspect command

# 5. Structured Command Analysis Section:
# Command: docker inspect ecommerce-backend:current | jq '.[0].Size'
# - docker inspect: Command to display image configuration
# - ecommerce-backend:current: Image specification
#   - ecommerce-backend: Image name
#   - current: Image tag (version identifier)
#   - Must be an existing image
# - |: Pipe operator
#   - Redirects output to the next command
#   - Enables command chaining and filtering
# - jq '.[0].Size': JSON processing command
#   - jq: JSON processor for filtering and extracting data
#   - '.[0].Size': JSONPath expression to extract size from first array element
#   - Extracts the Size field from the image configuration

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker inspect ecommerce-backend:current | jq '.[0].Size'
# Expected Output:
# 948576000
# 
# Output Analysis:
# - 948576000: Image size in bytes
# - Represents the total size of the image
# - Can be converted to human-readable format (e.g., 948.6 MB)

# 7. Flag Exploration Exercises:
# docker inspect --format '{{.Size}}' ecommerce-backend:current  # Get size using Go template
# docker inspect ecommerce-backend:current | jq '.[0].Created'   # Get creation date
# docker inspect ecommerce-backend:current | jq '.[0].Config'    # Get configuration
# docker inspect ecommerce-backend:current | jq '.[0].Architecture'  # Get architecture

# 8. Performance and Security Considerations:
# Performance: Minimal impact on system performance
# Security: May expose image configuration information
# Best Practices: Use appropriate filters, avoid exposing sensitive data
# Privacy: Configuration may contain sensitive information

# 9. Troubleshooting Scenarios:
# Error: "Image not found"
# Solution: Check image name and tag with docker images
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "jq: command not found"
# Solution: Install jq or use alternative JSON processing
# Error: "Invalid JSON"
# Solution: Check if docker inspect output is valid JSON

# 10. Complete Code Documentation:
# Command: docker inspect ecommerce-backend:current | jq '.[0].Size'
# Purpose: Extract image size information for optimization analysis
# Context: Image optimization exercise for size comparison and analysis
# Expected Input: Image name and tag with JSON processing
# Expected Output: Image size in bytes
# Error Conditions: Image not found, permission denied, jq not available
# Verification: Check output shows expected size value in bytes

# Run container and monitor resource usage
docker run -d --name ecommerce-current -p 8000:8000 ecommerce-backend:current
```

# =============================================================================
# DOCKER RUN COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker run -d --name ecommerce-current -p 8000:8000 ecommerce-backend:current
# Purpose: Create and start a container from the current image for optimization testing
# Category: Container Operations with Image Testing
# Complexity: Intermediate
# Real-world Usage: Image testing, optimization validation, performance analysis

# 1. Command Overview:
# docker run creates a container from the current image for testing
# Essential for validating image optimization and performance analysis
# Critical for comparing current and optimized image performance

# 2. Command Purpose and Context:
# What docker run does:
# - Creates a new container from the current image
# - Starts the container in detached mode for background operation
# - Configures port mapping for external access
# - Enables performance testing and optimization validation

# When to use docker run for optimization testing:
# - Testing image performance
# - Validating optimization results
# - Comparing current and optimized images
# - Performance analysis and benchmarking

# Command relationships:
# - Often used with docker stats to monitor performance
# - Works with docker ps to verify container status
# - Used with docker logs to monitor application behavior
# - Complementary to docker stop for container management

# 3. Complete Flag Reference:
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
# Options used in this command:
# -d, --detach: Run container in background and print container ID
# --name: Assign a name to the container
# -p, --publish: Publish container's port(s) to the host
# Additional useful flags:
# -it: Interactive terminal
# --rm: Automatically remove container when it exits
# --restart: Restart policy
# --memory: Memory limit

# 4. Flag Discovery Methods:
# docker run --help          # Show all available options
# man docker-run             # Manual page with complete documentation
# docker --help | grep run   # Filter help for run command

# 5. Structured Command Analysis Section:
# Command: docker run -d --name ecommerce-current -p 8000:8000 ecommerce-backend:current
# - docker run: Command to create and start a new container
# - -d: Detached mode flag
#   - Runs container in background
#   - Returns container ID immediately
#   - Container continues running after command exits
# - --name ecommerce-current: Container naming
#   - Assigns custom name for easy reference
#   - Enables container management by name
#   - Must be unique on the host
# - -p 8000:8000: Port mapping
#   - Maps host port 8000 to container port 8000
#   - Format: host_port:container_port
#   - Enables external access to containerized application
# - ecommerce-backend:current: Image specification
#   - ecommerce-backend: Image name
#   - current: Image tag (version identifier)

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker run -d --name ecommerce-current -p 8000:8000 ecommerce-backend:current
# Expected Output:
# 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
# 
# Output Analysis:
# - 64-character hexadecimal container ID
# - Container ID is returned immediately
# - Container runs in background (detached mode)
# - Port mapping is established and active

# 7. Flag Exploration Exercises:
# docker run -d --name ecommerce-current -p 8000:8000 --memory=512m ecommerce-backend:current  # With memory limit
# docker run -d --name ecommerce-current -p 8000:8000 --restart=always ecommerce-backend:current  # With restart policy
# docker run -it --name ecommerce-current -p 8000:8000 ecommerce-backend:current /bin/bash  # Interactive mode
# docker run --rm --name ecommerce-current -p 8000:8000 ecommerce-backend:current  # Auto-remove

# 8. Performance and Security Considerations:
# Performance: Container startup time depends on image size and complexity
# Security: No sensitive environment variables in this example
# Best Practices: Use appropriate resource limits, monitor performance
# Privacy: Container may expose application behavior

# 9. Troubleshooting Scenarios:
# Error: "Container name already exists"
# Solution: Use different name or remove existing container
# Error: "Port already in use"
# Solution: Check for existing containers using the port with docker ps
# Error: "Image not found"
# Solution: Build the image first with docker build
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo

# 10. Complete Code Documentation:
# Command: docker run -d --name ecommerce-current -p 8000:8000 ecommerce-backend:current
# Purpose: Deploy current image container for optimization testing and performance analysis
# Context: Image optimization exercise for testing current image performance
# Expected Input: Docker image name and port mapping configuration
# Expected Output: Container ID and background container execution
# Error Conditions: Name conflict, port conflict, image not found, permission denied
# Verification: Check container status with docker ps and monitor performance with docker stats

```bash
# Monitor memory usage
echo "=== MEMORY USAGE ANALYSIS ==="
docker stats ecommerce-current --no-stream
```

# =============================================================================
# DOCKER STATS COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker stats ecommerce-current --no-stream
# Purpose: Display resource usage statistics for a specific container
# Category: Container Monitoring and Performance Analysis
# Complexity: Intermediate
# Real-world Usage: Performance monitoring, resource analysis, optimization validation

# 1. Command Overview:
# docker stats displays resource usage statistics for a specific container
# Essential for monitoring container performance and resource consumption
# Critical for optimization validation and performance analysis

# 2. Command Purpose and Context:
# What docker stats does:
# - Displays resource usage statistics for a specific container
# - Shows CPU, memory, network, and disk I/O usage
# - Provides performance monitoring capabilities
# - Enables resource consumption analysis for optimization

# When to use docker stats for specific containers:
# - Monitoring specific container performance
# - Analyzing resource consumption for optimization
# - Performance validation and benchmarking
# - Troubleshooting container performance issues

# Command relationships:
# - Often used with docker ps to identify containers
# - Works with docker logs to correlate performance with application behavior
# - Used with docker top to get detailed process information
# - Complementary to docker system df for disk usage analysis

# 3. Complete Flag Reference:
# docker stats [OPTIONS] [CONTAINER...]
# Options used in this command:
# --no-stream: Disable streaming stats and only pull the first result
# Additional useful flags:
# --format: Pretty-print stats using a Go template
# --all, -a: Show all containers (default shows just running)
# --no-trunc: Don't truncate output

# 4. Flag Discovery Methods:
# docker stats --help          # Show all available options
# man docker-stats             # Manual page with complete documentation
# docker --help | grep stats   # Filter help for stats command

# 5. Structured Command Analysis Section:
# Command: docker stats ecommerce-current --no-stream
# - docker stats: Command to display container resource usage statistics
# - ecommerce-current: Container name
#   - Specifies which container to monitor
#   - Must be a running container
#   - Can also use container ID
# - --no-stream: Disable streaming flag
#   - Shows statistics only once instead of continuous updates
#   - Useful for scripting and automation
#   - Prevents continuous output that can interfere with other commands

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker stats ecommerce-current --no-stream
# Expected Output:
# CONTAINER ID   NAME                CPU %     MEM USAGE / LIMIT     MEM %     NET I/O          BLOCK I/O        PIDS
# 1234567890ab  ecommerce-current   0.15%     45.2MiB / 512MiB      8.83%     1.2kB / 856B     0B / 0B         15
# 
# Output Analysis:
# - CONTAINER ID: Unique container identifier (first 12 characters)
# - NAME: Container name (ecommerce-current)
# - CPU %: CPU usage percentage (0.15%)
# - MEM USAGE / LIMIT: Memory usage and limit (45.2MiB / 512MiB)
# - MEM %: Memory usage percentage (8.83%)
# - NET I/O: Network input/output (1.2kB / 856B)
# - BLOCK I/O: Block device input/output (0B / 0B)
# - PIDS: Number of processes (15)

# 7. Flag Exploration Exercises:
# docker stats ecommerce-current --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"  # Custom format
# docker stats ecommerce-current --no-stream --no-trunc  # Show full output without truncation
# docker stats ecommerce-current  # Continuous streaming (without --no-stream)
# docker stats ecommerce-current --format "{{.CPUPerc}}"  # Get only CPU percentage

# 8. Performance and Security Considerations:
# Performance: Minimal impact on container performance
# Security: Reveals resource usage patterns and system information
# Best Practices: Use for monitoring, combine with filters for specific needs
# Privacy: May expose resource usage patterns and system information

# 9. Troubleshooting Scenarios:
# Error: "Container not found"
# Solution: Check container name with docker ps
# Error: "Container not running"
# Solution: Start the container first with docker start
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "No statistics available"
# Solution: Check if container is running and accessible

# 10. Complete Code Documentation:
# Command: docker stats ecommerce-current --no-stream
# Purpose: Monitor specific container resource usage for optimization analysis
# Context: Image optimization exercise for performance monitoring and validation
# Expected Input: Container name and monitoring parameters
# Expected Output: Resource usage statistics for the specified container
# Error Conditions: Container not found, not running, permission denied
# Verification: Check output shows expected container with resource usage data

# Get detailed container information
docker inspect ecommerce-current | jq '.[0].State'

# Check running processes inside container
docker exec ecommerce-current ps aux
```

# =============================================================================
# DOCKER EXEC COMMAND - COMPLETE 9-SECTION DOCUMENTATION
# =============================================================================

# Command: docker exec ecommerce-current ps aux
# Purpose: Execute a command inside a running container to check processes
# Category: Container Operations and Process Management
# Complexity: Intermediate
# Real-world Usage: Container debugging, process monitoring, system administration

# 1. Command Overview:
# docker exec executes a command inside a running container
# Essential for debugging, monitoring, and administering running containers
# Critical for troubleshooting and process analysis

# 2. Command Purpose and Context:
# What docker exec does:
# - Executes a command inside a running container
# - Provides access to container's internal processes
# - Enables debugging and troubleshooting
# - Allows system administration within containers

# When to use docker exec:
# - Debugging container issues
# - Monitoring running processes
# - System administration tasks
# - Troubleshooting application behavior

# Command relationships:
# - Often used with docker ps to identify running containers
# - Works with docker logs to correlate process information with logs
# - Used with docker stats to understand resource usage
# - Complementary to docker run for container access

# 3. Complete Flag Reference:
# docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
# Options used in this command:
# No additional flags used in this command
# Additional useful flags:
# -it: Interactive terminal
# --user: Username or UID to run command as
# --workdir: Working directory inside the container
# --env: Set environment variables

# 4. Flag Discovery Methods:
# docker exec --help          # Show all available options
# man docker-exec             # Manual page with complete documentation
# docker --help | grep exec   # Filter help for exec command

# 5. Structured Command Analysis Section:
# Command: docker exec ecommerce-current ps aux
# - docker exec: Command to execute a command inside a container
# - ecommerce-current: Container name
#   - Specifies which container to execute command in
#   - Must be a running container
#   - Can also use container ID
# - ps aux: Command to execute
#   - ps: Process status command
#   - aux: Flags for ps command
#     - a: Show processes for all users
#     - u: Display user-oriented format
#     - x: Show processes without controlling terminals

# 6. Real-time Examples with Input/Output Analysis:
# Input: docker exec ecommerce-current ps aux
# Expected Output:
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.1   1234   567 ?        Ss   10:30   0:00 python main.py
# root        15  0.0  0.0   2345   123 ?        S    10:30   0:00 ps aux
# 
# Output Analysis:
# - USER: User running the process (root)
# - PID: Process ID (1, 15)
# - %CPU: CPU usage percentage (0.0)
# - %MEM: Memory usage percentage (0.1, 0.0)
# - VSZ: Virtual memory size (1234, 2345)
# - RSS: Resident set size (567, 123)
# - TTY: Terminal type (? for no terminal)
# - STAT: Process status (Ss, S)
# - START: Start time (10:30)
# - TIME: CPU time (0:00)
# - COMMAND: Command being executed (python main.py, ps aux)

# 7. Flag Exploration Exercises:
# docker exec -it ecommerce-current /bin/bash  # Interactive shell
# docker exec --user root ecommerce-current whoami  # Run as specific user
# docker exec --workdir /app ecommerce-current pwd  # Set working directory
# docker exec ecommerce-current env  # Show environment variables

# 8. Performance and Security Considerations:
# Performance: Minimal impact on container performance
# Security: Executing commands may expose sensitive information
# Best Practices: Use appropriate user permissions, avoid sensitive commands
# Privacy: Commands may expose application behavior and system information

# 9. Troubleshooting Scenarios:
# Error: "Container not found"
# Solution: Check container name with docker ps
# Error: "Container not running"
# Solution: Start the container first with docker start
# Error: "Permission denied"
# Solution: Check Docker daemon permissions or use sudo
# Error: "Command not found"
# Solution: Check if the command exists in the container

# 10. Complete Code Documentation:
# Command: docker exec ecommerce-current ps aux
# Purpose: Check running processes inside container for optimization analysis
# Context: Image optimization exercise for process monitoring and analysis
# Expected Input: Container name and command to execute
# Expected Output: List of running processes with detailed information
# Error Conditions: Container not found, not running, permission denied, command not found
# Verification: Check output shows expected processes running in the container

# Analyze memory usage by process
docker exec ecommerce-current cat /proc/meminfo
```

**Step 2: Identify Optimization Opportunities**
```bash
# Create optimization analysis script
cat > analyze_optimization.sh << 'EOF'
#!/bin/bash

echo "=== CONTAINER OPTIMIZATION ANALYSIS ==="
echo "Date: $(date)"
echo ""

# 1. Analyze base image
echo "1. BASE IMAGE ANALYSIS:"
echo "Current base image: python:3.9"
echo "Base image size: $(docker images python:3.9 --format 'table {{.Size}}')"
echo ""

# 2. Analyze dependencies
echo "2. DEPENDENCIES ANALYSIS:"
echo "Requirements.txt contents:"
cat requirements.txt
echo ""

# Count dependencies
echo "Total dependencies: $(wc -l < requirements.txt)"
echo ""

# 3. Analyze application code
echo "3. APPLICATION CODE ANALYSIS:"
echo "Total files: $(find . -type f | wc -l)"
echo "Total size: $(du -sh . | cut -f1)"
echo ""

# 4. Identify large files
echo "4. LARGE FILES IDENTIFICATION:"
find . -type f -size +1M -exec ls -lh {} \; | head -10
echo ""

# 5. Check for unnecessary files
echo "5. UNNECESSARY FILES CHECK:"
echo "Cache directories:"
find . -name "__pycache__" -type d
echo "Log files:"
find . -name "*.log" -type f
echo "Temporary files:"
find . -name "*.tmp" -type f
echo ""

# 6. Analyze Docker layers
echo "6. DOCKER LAYERS ANALYSIS:"
docker history ecommerce-backend:current --format "table {{.CreatedBy}}\t{{.Size}}"
echo ""

# 7. Check for security vulnerabilities
echo "7. SECURITY VULNERABILITY CHECK:"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce-backend:current
echo ""

echo "=== OPTIMIZATION RECOMMENDATIONS ==="
echo "1. Use multi-stage build to reduce final image size"
echo "2. Use alpine-based Python image for smaller base"
echo "3. Remove unnecessary dependencies and files"
echo "4. Implement proper layer caching"
echo "5. Use .dockerignore to exclude unnecessary files"
echo "6. Run as non-root user for security"
echo "7. Implement health checks"
echo "8. Use specific version tags instead of latest"
EOF

chmod +x analyze_optimization.sh
./analyze_optimization.sh
```

**Step 3: Create Optimized Dockerfile with Multi-stage Build**
```bash
# Create .dockerignore file
cat > .dockerignore << 'EOF'
# Git
.git
.gitignore

# Documentation
README.md
*.md

# IDE
.vscode
.idea
*.swp
*.swo

# Python
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
pip-log.txt
pip-delete-this-directory.txt
.tox
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.git
.mypy_cache
.pytest_cache
.hypothesis

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Development
.env
.env.local
.env.development
.env.test
.env.production

# Testing
tests/
test_*
*_test.py

# Build artifacts
build/
dist/
*.egg-info/
EOF

# Create optimized multi-stage Dockerfile
cat > Dockerfile.optimized << 'EOF'
# =============================================================================
# Multi-stage Dockerfile for E-commerce Backend
# Purpose: Optimized container with minimal size and security hardening
# =============================================================================

# Stage 1: Build stage
FROM python:3.9-alpine AS builder

# Set build arguments
ARG BUILDPLATFORM
ARG TARGETPLATFORM

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    build-base

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Production stage
FROM python:3.9-alpine AS production

# Install runtime dependencies only
RUN apk add --no-cache \
    libffi \
    openssl \
    ca-certificates \
    tzdata

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=appuser:appgroup . .

# Create necessary directories with proper permissions
RUN mkdir -p /app/logs /app/data && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV FLASK_ENV=production

# Run application
CMD ["python", "main.py"]
EOF

# Create optimized requirements.txt
cat > requirements.optimized.txt << 'EOF'
# Core dependencies only
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
sqlalchemy==2.0.23
alembic==1.13.1
psycopg2-binary==2.9.9
redis==5.0.1
celery==5.3.4
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
EOF
```

**Step 4: Build and Test Optimized Container**
```bash
# Build optimized image
echo "=== BUILDING OPTIMIZED IMAGE ==="
docker build -f Dockerfile.optimized -t ecommerce-backend:optimized .

# Compare image sizes
echo "=== IMAGE SIZE COMPARISON ==="
echo "Current image:"
docker images ecommerce-backend:current --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo ""
echo "Optimized image:"
docker images ecommerce-backend:optimized --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo ""

# Calculate size reduction
CURRENT_SIZE=$(docker images ecommerce-backend:current --format "{{.Size}}" | sed 's/[^0-9.]//g')
OPTIMIZED_SIZE=$(docker images ecommerce-backend:optimized --format "{{.Size}}" | sed 's/[^0-9.]//g')
echo "Size reduction: $(( (CURRENT_SIZE - OPTIMIZED_SIZE) * 100 / CURRENT_SIZE ))%"
echo ""

# Test optimized container
echo "=== TESTING OPTIMIZED CONTAINER ==="
docker run -d --name ecommerce-optimized -p 8001:8000 ecommerce-backend:optimized

# Wait for container to start
sleep 10

# Check container status
docker ps | grep ecommerce-optimized

# Test health check
echo "=== HEALTH CHECK TEST ==="
docker exec ecommerce-optimized python -c "import requests; print('Health check:', requests.get('http://localhost:8000/health').status_code)"

# Monitor resource usage
echo "=== RESOURCE USAGE COMPARISON ==="
echo "Current container:"
docker stats ecommerce-current --no-stream
echo ""
echo "Optimized container:"
docker stats ecommerce-optimized --no-stream
echo ""

# Test application functionality
echo "=== FUNCTIONALITY TEST ==="
curl -f http://localhost:8001/health || echo "Health endpoint not available"
curl -f http://localhost:8001/docs || echo "API docs not available"
```

**Step 5: Advanced Optimization Techniques**
```bash
# Create advanced optimization script
cat > advanced_optimization.sh << 'EOF'
#!/bin/bash

echo "=== ADVANCED OPTIMIZATION TECHNIQUES ==="

# 1. Image layer analysis
echo "1. LAYER ANALYSIS:"
docker history ecommerce-backend:optimized --format "table {{.CreatedBy}}\t{{.Size}}"
echo ""

# 2. Security scan
echo "2. SECURITY SCAN:"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce-backend:optimized
echo ""

# 3. Performance testing
echo "3. PERFORMANCE TESTING:"
# Test container startup time
echo "Container startup time:"
time docker run --rm ecommerce-backend:optimized python -c "print('Container started')"
echo ""

# 4. Memory usage analysis
echo "4. MEMORY USAGE ANALYSIS:"
docker run -d --name mem-test ecommerce-backend:optimized
sleep 5
docker exec mem-test cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"
docker stop mem-test && docker rm mem-test
echo ""

# 5. File system analysis
echo "5. FILE SYSTEM ANALYSIS:"
docker run --rm ecommerce-backend:optimized find /app -type f | wc -l
docker run --rm ecommerce-backend:optimized du -sh /app
echo ""

# 6. Dependency analysis
echo "6. DEPENDENCY ANALYSIS:"
docker run --rm ecommerce-backend:optimized pip list
echo ""

echo "=== OPTIMIZATION SUMMARY ==="
echo "✅ Multi-stage build implemented"
echo "✅ Alpine base image used"
echo "✅ Non-root user configured"
echo "✅ Health checks added"
echo "✅ Security vulnerabilities addressed"
echo "✅ Image size reduced significantly"
echo "✅ Runtime dependencies minimized"
EOF

chmod +x advanced_optimization.sh
./advanced_optimization.sh
```

**Step 6: Create Production-Ready Configuration**
```bash
# Create production Docker Compose file
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  ecommerce-backend:
    build:
      context: .
      dockerfile: Dockerfile.optimized
    image: ecommerce-backend:optimized
    container_name: ecommerce-backend-prod
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/ecommerce
      - REDIS_URL=redis://redis:6379/0
    volumes:
      - ./logs:/app/logs:rw
      - ./data:/app/data:rw
    networks:
      - ecommerce-network
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8000/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'

  db:
    image: postgres:15-alpine
    container_name: ecommerce-db-prod
    restart: unless-stopped
    environment:
      - POSTGRES_DB=ecommerce
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ecommerce-network
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis-prod
    restart: unless-stopped
    networks:
      - ecommerce-network
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'

networks:
  ecommerce-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
EOF

# Create monitoring script
cat > monitor_containers.sh << 'EOF'
#!/bin/bash

echo "=== CONTAINER MONITORING ==="
echo "Date: $(date)"
echo ""

# Container status
echo "1. CONTAINER STATUS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"
echo ""

# Resource usage
echo "2. RESOURCE USAGE:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
echo ""

# Health checks
echo "3. HEALTH CHECKS:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(healthy|unhealthy)"
echo ""

# Log analysis
echo "4. RECENT LOGS:"
docker logs --tail 10 ecommerce-backend-prod
echo ""

# Performance metrics
echo "5. PERFORMANCE METRICS:"
docker exec ecommerce-backend-prod python -c "
import psutil
import os
print(f'CPU Usage: {psutil.cpu_percent()}%')
print(f'Memory Usage: {psutil.virtual_memory().percent}%')
print(f'Disk Usage: {psutil.disk_usage(\"/\").percent}%')
"
EOF

chmod +x monitor_containers.sh
```

**Step 7: Validation and Testing**
```bash
# Create comprehensive test script
cat > test_optimization.sh << 'EOF'
#!/bin/bash

echo "=== COMPREHENSIVE OPTIMIZATION TEST ==="

# 1. Build and start containers
echo "1. BUILDING AND STARTING CONTAINERS:"
docker-compose -f docker-compose.prod.yml up -d --build

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# 2. Test container health
echo "2. TESTING CONTAINER HEALTH:"
docker-compose -f docker-compose.prod.yml ps

# 3. Test application endpoints
echo "3. TESTING APPLICATION ENDPOINTS:"
curl -f http://localhost:8000/health && echo "✅ Health endpoint working"
curl -f http://localhost:8000/docs && echo "✅ API docs accessible"

# 4. Performance testing
echo "4. PERFORMANCE TESTING:"
# Test response time
time curl -s http://localhost:8000/health > /dev/null

# 5. Resource usage testing
echo "5. RESOURCE USAGE TESTING:"
docker stats --no-stream

# 6. Security testing
echo "6. SECURITY TESTING:"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce-backend:optimized

# 7. Cleanup
echo "7. CLEANUP:"
docker-compose -f docker-compose.prod.yml down
docker system prune -f
EOF

chmod +x test_optimization.sh
./test_optimization.sh
```

**COMPLETE VALIDATION STEPS**:
```bash
# 1. Verify image size reduction
echo "=== IMAGE SIZE VALIDATION ==="
docker images | grep ecommerce-backend

# 2. Verify security improvements
echo "=== SECURITY VALIDATION ==="
docker run --rm ecommerce-backend:optimized whoami
docker run --rm ecommerce-backend:optimized id

# 3. Verify functionality
echo "=== FUNCTIONALITY VALIDATION ==="
docker run -d --name test-optimized -p 8002:8000 ecommerce-backend:optimized
sleep 10
curl -f http://localhost:8002/health
docker stop test-optimized && docker rm test-optimized

# 4. Verify resource usage
echo "=== RESOURCE USAGE VALIDATION ==="
docker run -d --name resource-test ecommerce-backend:optimized
sleep 5
docker stats resource-test --no-stream
docker stop resource-test && docker rm resource-test
```

**ERROR HANDLING AND TROUBLESHOOTING**:
```bash
# If build fails:
echo "=== BUILD TROUBLESHOOTING ==="
# Check Dockerfile syntax
docker build --no-cache -f Dockerfile.optimized -t ecommerce-backend:debug .

# If container fails to start:
echo "=== CONTAINER STARTUP TROUBLESHOOTING ==="
# Check logs
docker logs ecommerce-optimized

# Check container configuration
docker inspect ecommerce-optimized

# If health check fails:
echo "=== HEALTH CHECK TROUBLESHOOTING ==="
# Test health endpoint manually
docker exec ecommerce-optimized curl -f http://localhost:8000/health

# If performance is poor:
echo "=== PERFORMANCE TROUBLESHOOTING ==="
# Monitor resource usage
docker stats ecommerce-optimized

# Check for memory leaks
docker exec ecommerce-optimized ps aux --sort=-%mem
```

**Expected Output**:
- **Optimized Dockerfile** with multi-stage build and security hardening
- **Before/after image size comparison** showing 30%+ reduction
- **Resource usage analysis** with detailed memory and CPU metrics
- **Security improvements** with non-root user and vulnerability scanning
- **Performance testing** results with response time measurements
- **Production-ready configuration** with Docker Compose and monitoring
- **Comprehensive validation** confirming all optimizations work correctly

### **Problem 2: Container Security Hardening**

**Scenario**: Implement security best practices for your containers.

**Requirements**:
1. Run containers as non-root user
2. Implement proper health checks
3. Use minimal base images
4. Scan for vulnerabilities

**DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**:

**Step 1: Security Assessment and Planning**
```bash
# Navigate to your e-commerce project
cd /path/to/your/e-commerce

# Create security hardening directory
mkdir -p container-security
cd container-security

# Create security assessment script
cat > security_assessment.sh << 'EOF'
#!/bin/bash

echo "=== CONTAINER SECURITY ASSESSMENT ==="
echo "Date: $(date)"
echo ""

# 1. Current security posture analysis
echo "1. CURRENT SECURITY POSTURE:"
echo "Analyzing existing containers..."

# Check if any containers are running as root
echo "Containers running as root:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Command}}" | while read line; do
    if [[ $line == *"root"* ]]; then
        echo "⚠️  $line"
    fi
done
echo ""

# 2. Base image security analysis
echo "2. BASE IMAGE SECURITY ANALYSIS:"
echo "Current base images in use:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | head -10
echo ""

# 3. Vulnerability scanning setup
echo "3. VULNERABILITY SCANNING SETUP:"
echo "Installing Trivy for vulnerability scanning..."

# Install Trivy if not present
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy..."
    # For Ubuntu/Debian
    sudo apt-get update
    sudo apt-get install wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy
else
    echo "✅ Trivy already installed"
fi
echo ""

# 4. Security requirements checklist
echo "4. SECURITY REQUIREMENTS CHECKLIST:"
echo "□ Run containers as non-root user"
echo "□ Use minimal base images (Alpine/Distroless)"
echo "□ Implement proper health checks"
echo "□ Scan for vulnerabilities"
echo "□ Use specific version tags"
echo "□ Implement resource limits"
echo "□ Use read-only filesystems where possible"
echo "□ Implement proper secrets management"
echo "□ Use multi-stage builds"
echo "□ Implement proper logging"
echo ""

echo "=== SECURITY ASSESSMENT COMPLETED ==="
EOF

chmod +x security_assessment.sh
./security_assessment.sh
```

**Step 2: Create Security-Hardened Dockerfile**
```bash
# Create security-hardened Dockerfile
cat > Dockerfile.secure << 'EOF'
# =============================================================================
# Security-Hardened Dockerfile for E-commerce Backend
# Purpose: Implement comprehensive security best practices
# =============================================================================

# Stage 1: Build stage with security hardening
FROM python:3.9-alpine AS builder

# Set build arguments for security
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Add security labels
LABEL maintainer="security-team@company.com" \
      org.opencontainers.image.title="E-commerce Backend" \
      org.opencontainers.image.description="Security-hardened e-commerce backend" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="Company" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://company.com" \
      org.opencontainers.image.documentation="https://docs.company.com" \
      org.opencontainers.image.source="https://github.com/company/ecommerce"

# Install build dependencies with security updates
RUN apk add --no-cache --update \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    build-base \
    && apk upgrade --no-cache

# Create non-root user for build stage
RUN addgroup -g 1001 -S buildgroup && \
    adduser -u 1001 -S builduser -G buildgroup

# Create virtual environment with proper permissions
RUN python -m venv /opt/venv && \
    chown -R builduser:buildgroup /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Switch to non-root user
USER builduser

# Copy requirements and install dependencies securely
COPY --chown=builduser:buildgroup requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production stage with maximum security
FROM python:3.9-alpine AS production

# Set security-related environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

# Install only runtime dependencies with security updates
RUN apk add --no-cache --update \
    libffi \
    openssl \
    ca-certificates \
    tzdata \
    dumb-init \
    && apk upgrade --no-cache \
    && rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup -h /app -s /bin/sh

# Create application directory with proper permissions
WORKDIR /app
RUN chown -R appuser:appgroup /app

# Copy virtual environment from builder stage
COPY --from=builder --chown=appuser:appgroup /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code with proper ownership
COPY --chown=appuser:appgroup . .

# Create necessary directories with minimal permissions
RUN mkdir -p /app/logs /app/data /app/tmp && \
    chown -R appuser:appgroup /app && \
    chmod -R 755 /app && \
    chmod 700 /app/tmp

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Add comprehensive health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health', timeout=5)" || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Run application
CMD ["python", "main.py"]
EOF

# Create security-focused .dockerignore
cat > .dockerignore.secure << 'EOF'
# Security-sensitive files
.env*
*.key
*.pem
*.crt
*.p12
*.pfx
secrets/
keys/
certificates/

# Git and version control
.git
.gitignore
.gitattributes

# Documentation
README.md
*.md
docs/

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
.pytest_cache/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.mypy_cache/
.hypothesis/

# Testing
tests/
test_*
*_test.py
.pytest_cache/

# Build artifacts
build/
dist/
*.egg-info/

# Temporary files
*.tmp
*.temp
temp/
tmp/

# Logs
logs/
*.log

# Database files
*.db
*.sqlite
*.sqlite3

# Backup files
*.bak
*.backup
backup/
EOF
```

**Step 3: Implement Comprehensive Security Scanning**
```bash
# Create security scanning script
cat > security_scan.sh << 'EOF'
#!/bin/bash

echo "=== COMPREHENSIVE SECURITY SCANNING ==="
echo "Date: $(date)"
echo ""

# 1. Build security-hardened image
echo "1. BUILDING SECURITY-HARDENED IMAGE:"
docker build -f Dockerfile.secure -t ecommerce-backend:secure .

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Exiting."
    exit 1
fi
echo "✅ Image built successfully"
echo ""

# 2. Vulnerability scanning with Trivy
echo "2. VULNERABILITY SCANNING:"
echo "Scanning for vulnerabilities..."

# High and critical vulnerabilities
echo "=== HIGH AND CRITICAL VULNERABILITIES ==="
trivy image --severity HIGH,CRITICAL ecommerce-backend:secure

# All vulnerabilities with detailed output
echo "=== ALL VULNERABILITIES (DETAILED) ==="
trivy image --format table ecommerce-backend:secure

# Export vulnerability report
echo "=== EXPORTING VULNERABILITY REPORT ==="
trivy image --format json --output vulnerability-report.json ecommerce-backend:secure
trivy image --format sarif --output vulnerability-report.sarif ecommerce-backend:secure
echo "✅ Vulnerability reports exported"
echo ""

# 3. Security configuration scanning
echo "3. SECURITY CONFIGURATION SCANNING:"
echo "Checking security configurations..."

# Check if running as root
echo "=== ROOT USER CHECK ==="
docker run --rm ecommerce-backend:secure whoami
docker run --rm ecommerce-backend:secure id

# Check file permissions
echo "=== FILE PERMISSIONS CHECK ==="
docker run --rm ecommerce-backend:secure ls -la /app

# Check for unnecessary packages
echo "=== PACKAGE ANALYSIS ==="
docker run --rm ecommerce-backend:secure apk list --installed

# Check for exposed ports
echo "=== EXPOSED PORTS CHECK ==="
docker run --rm ecommerce-backend:secure netstat -tlnp
echo ""

# 4. Runtime security testing
echo "4. RUNTIME SECURITY TESTING:"
echo "Testing container runtime security..."

# Start container for testing
docker run -d --name security-test -p 8003:8000 ecommerce-backend:secure
sleep 10

# Test health check
echo "=== HEALTH CHECK TEST ==="
docker exec security-test python -c "import requests; print('Health check:', requests.get('http://localhost:8000/health').status_code)"

# Test process isolation
echo "=== PROCESS ISOLATION TEST ==="
docker exec security-test ps aux

# Test network isolation
echo "=== NETWORK ISOLATION TEST ==="
docker exec security-test netstat -tlnp

# Test file system access
echo "=== FILE SYSTEM ACCESS TEST ==="
docker exec security-test ls -la /
docker exec security-test touch /tmp/test_file && echo "✅ Can write to /tmp" || echo "❌ Cannot write to /tmp"

# Cleanup
docker stop security-test && docker rm security-test
echo ""

# 5. Security best practices validation
echo "5. SECURITY BEST PRACTICES VALIDATION:"
echo "Validating security implementations..."

# Check for security labels
echo "=== SECURITY LABELS CHECK ==="
docker inspect ecommerce-backend:secure | jq '.[0].Config.Labels'

# Check for non-root user
echo "=== NON-ROOT USER VALIDATION ==="
USER_ID=$(docker run --rm ecommerce-backend:secure id -u)
if [ "$USER_ID" = "1001" ]; then
    echo "✅ Running as non-root user (UID: $USER_ID)"
else
    echo "❌ Not running as expected non-root user (UID: $USER_ID)"
fi

# Check for minimal base image
echo "=== BASE IMAGE VALIDATION ==="
BASE_IMAGE=$(docker inspect ecommerce-backend:secure | jq -r '.[0].Config.Image')
if [[ $BASE_IMAGE == *"alpine"* ]]; then
    echo "✅ Using Alpine-based minimal image"
else
    echo "❌ Not using minimal base image"
fi

# Check for health check
echo "=== HEALTH CHECK VALIDATION ==="
HEALTH_CHECK=$(docker inspect ecommerce-backend:secure | jq '.[0].Config.Healthcheck')
if [ "$HEALTH_CHECK" != "null" ]; then
    echo "✅ Health check configured"
else
    echo "❌ Health check not configured"
fi
echo ""

echo "=== SECURITY SCANNING COMPLETED ==="
EOF

chmod +x security_scan.sh
./security_scan.sh
```

**Step 4: Implement Advanced Security Features**
```bash
# Create advanced security configuration
cat > docker-compose.secure.yml << 'EOF'
version: '3.8'

services:
  ecommerce-backend:
    build:
      context: .
      dockerfile: Dockerfile.secure
    image: ecommerce-backend:secure
    container_name: ecommerce-backend-secure
    restart: unless-stopped
    
    # Security configurations
    security_opt:
      - no-new-privileges:true
      - seccomp:unconfined
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
    
    # Read-only root filesystem
    read_only: true
    
    # Temporary filesystem for writable directories
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /app/logs:noexec,nosuid,size=200m
    
    # Environment variables
    environment:
      - FLASK_ENV=production
      - PYTHONUNBUFFERED=1
      - PYTHONDONTWRITEBYTECODE=1
    
    # Ports
    ports:
      - "8000:8000"
    
    # Networks
    networks:
      - secure-network
    
    # Health check
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8000/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    # Capabilities
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    
    # User
    user: "1001:1001"
    
    # Working directory
    working_dir: /app
    
    # Command
    command: ["dumb-init", "--", "python", "main.py"]

  # Database with security hardening
  db:
    image: postgres:15-alpine
    container_name: ecommerce-db-secure
    restart: unless-stopped
    
    # Security configurations
    security_opt:
      - no-new-privileges:true
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
    
    # Environment variables
    environment:
      - POSTGRES_DB=ecommerce
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
      - POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256
    
    # Secrets
    secrets:
      - db_password
    
    # Volumes
    volumes:
      - postgres_data:/var/lib/postgresql/data:Z
    
    # Networks
    networks:
      - secure-network
    
    # Health check
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d ecommerce"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis with security hardening
  redis:
    image: redis:7-alpine
    container_name: ecommerce-redis-secure
    restart: unless-stopped
    
    # Security configurations
    security_opt:
      - no-new-privileges:true
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'
    
    # Command with security options
    command: redis-server --requirepass $$REDIS_PASSWORD --appendonly yes
    
    # Environment variables
    environment:
      - REDIS_PASSWORD_FILE=/run/secrets/redis_password
    
    # Secrets
    secrets:
      - redis_password
    
    # Networks
    networks:
      - secure-network
    
    # Health check
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

# Networks
networks:
  secure-network:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.enable_icc: "false"
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.bridge.host_binding_ipv4: "127.0.0.1"

# Volumes
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /var/lib/docker/volumes/postgres_data

# Secrets
secrets:
  db_password:
    file: ./secrets/db_password.txt
  redis_password:
    file: ./secrets/redis_password.txt
EOF

# Create secrets directory and files
mkdir -p secrets
echo "secure_db_password_123" > secrets/db_password.txt
echo "secure_redis_password_456" > secrets/redis_password.txt
chmod 600 secrets/*.txt
```

**Step 5: Implement Security Monitoring and Alerting**
```bash
# Create security monitoring script
cat > security_monitor.sh << 'EOF'
#!/bin/bash

echo "=== SECURITY MONITORING ==="
echo "Date: $(date)"
echo ""

# 1. Container security status
echo "1. CONTAINER SECURITY STATUS:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep secure
echo ""

# 2. Security event monitoring
echo "2. SECURITY EVENT MONITORING:"
# Check for privilege escalation attempts
echo "=== PRIVILEGE ESCALATION MONITORING ==="
docker logs ecommerce-backend-secure 2>&1 | grep -i "sudo\|su\|root" | tail -5

# Check for suspicious network activity
echo "=== NETWORK ACTIVITY MONITORING ==="
docker exec ecommerce-backend-secure netstat -tlnp | grep -v "127.0.0.1"
echo ""

# 3. Resource usage monitoring
echo "3. RESOURCE USAGE MONITORING:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo ""

# 4. File system integrity check
echo "4. FILE SYSTEM INTEGRITY CHECK:"
echo "=== FILE PERMISSIONS CHECK ==="
docker exec ecommerce-backend-secure find /app -type f -perm /o+w
echo ""

# 5. Security configuration validation
echo "5. SECURITY CONFIGURATION VALIDATION:"
echo "=== SECURITY OPTIONS CHECK ==="
docker inspect ecommerce-backend-secure | jq '.[0].HostConfig.SecurityOpt'
echo ""

echo "=== CAPABILITIES CHECK ==="
docker inspect ecommerce-backend-secure | jq '.[0].HostConfig.CapAdd, .[0].HostConfig.CapDrop'
echo ""

# 6. Vulnerability monitoring
echo "6. VULNERABILITY MONITORING:"
echo "Running periodic vulnerability scan..."
trivy image --severity HIGH,CRITICAL ecommerce-backend:secure | head -20
echo ""

echo "=== SECURITY MONITORING COMPLETED ==="
EOF

chmod +x security_monitor.sh
```

**Step 6: Create Security Testing Suite**
```bash
# Create comprehensive security testing script
cat > security_test.sh << 'EOF'
#!/bin/bash

echo "=== COMPREHENSIVE SECURITY TESTING ==="
echo "Date: $(date)"
echo ""

# 1. Start secure containers
echo "1. STARTING SECURE CONTAINERS:"
docker-compose -f docker-compose.secure.yml up -d --build

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# 2. Test security configurations
echo "2. TESTING SECURITY CONFIGURATIONS:"

# Test non-root user
echo "=== NON-ROOT USER TEST ==="
USER_ID=$(docker exec ecommerce-backend-secure id -u)
if [ "$USER_ID" = "1001" ]; then
    echo "✅ Running as non-root user (UID: $USER_ID)"
else
    echo "❌ Not running as expected non-root user (UID: $USER_ID)"
fi

# Test read-only filesystem
echo "=== READ-ONLY FILESYSTEM TEST ==="
if docker exec ecommerce-backend-secure touch /test_file 2>/dev/null; then
    echo "❌ Root filesystem is writable"
else
    echo "✅ Root filesystem is read-only"
fi

# Test tmpfs mounts
echo "=== TMPFS MOUNTS TEST ==="
if docker exec ecommerce-backend-secure touch /tmp/test_file; then
    echo "✅ /tmp is writable (tmpfs)"
    docker exec ecommerce-backend-secure rm /tmp/test_file
else
    echo "❌ /tmp is not writable"
fi

# Test network isolation
echo "=== NETWORK ISOLATION TEST ==="
docker exec ecommerce-backend-secure netstat -tlnp | grep -v "127.0.0.1" | head -5
echo ""

# 3. Test application security
echo "3. TESTING APPLICATION SECURITY:"

# Test health endpoint
echo "=== HEALTH ENDPOINT TEST ==="
curl -f http://localhost:8000/health && echo "✅ Health endpoint accessible" || echo "❌ Health endpoint not accessible"

# Test for information disclosure
echo "=== INFORMATION DISCLOSURE TEST ==="
curl -s http://localhost:8000/ | grep -i "error\|exception\|stack" && echo "❌ Potential information disclosure" || echo "✅ No obvious information disclosure"

# Test for common vulnerabilities
echo "=== COMMON VULNERABILITIES TEST ==="
# Test for SQL injection (basic)
curl -s "http://localhost:8000/api/users?id=1' OR '1'='1" | grep -i "error\|exception" && echo "❌ Potential SQL injection vulnerability" || echo "✅ No obvious SQL injection"

# Test for XSS (basic)
curl -s "http://localhost:8000/api/search?q=<script>alert('xss')</script>" | grep -i "script" && echo "❌ Potential XSS vulnerability" || echo "✅ No obvious XSS"
echo ""

# 4. Test resource limits
echo "4. TESTING RESOURCE LIMITS:"
echo "=== MEMORY LIMIT TEST ==="
docker stats --no-stream ecommerce-backend-secure | grep ecommerce-backend-secure
echo ""

# 5. Test secrets management
echo "5. TESTING SECRETS MANAGEMENT:"
echo "=== SECRETS ACCESS TEST ==="
docker exec ecommerce-backend-secure ls -la /run/secrets/ 2>/dev/null && echo "✅ Secrets accessible" || echo "❌ Secrets not accessible"
echo ""

# 6. Test logging
echo "6. TESTING LOGGING:"
echo "=== LOG OUTPUT TEST ==="
docker logs --tail 10 ecommerce-backend-secure
echo ""

# 7. Cleanup
echo "7. CLEANUP:"
docker-compose -f docker-compose.secure.yml down
echo "✅ Cleanup completed"
echo ""

echo "=== SECURITY TESTING COMPLETED ==="
EOF

chmod +x security_test.sh
./security_test.sh
```

**Step 7: Create Security Documentation**
```bash
# Create comprehensive security documentation
cat > SECURITY.md << 'EOF'
# Container Security Documentation

## Overview
This document outlines the security measures implemented in the e-commerce backend container.

## Security Features Implemented

### 1. Non-Root User
- **Implementation**: Container runs as user with UID 1001
- **Benefit**: Reduces attack surface and limits privilege escalation
- **Validation**: `docker exec container_name id -u`

### 2. Minimal Base Image
- **Implementation**: Alpine Linux base image
- **Benefit**: Smaller attack surface, fewer vulnerabilities
- **Size**: ~5MB base vs ~100MB+ for full distributions

### 3. Multi-Stage Build
- **Implementation**: Separate build and runtime stages
- **Benefit**: Excludes build tools from final image
- **Result**: Smaller, more secure production image

### 4. Read-Only Root Filesystem
- **Implementation**: `read_only: true` in Docker Compose
- **Benefit**: Prevents malicious file modifications
- **Exception**: Writable tmpfs for /tmp and /app/logs

### 5. Security Options
- **Implementation**: `no-new-privileges:true`
- **Benefit**: Prevents privilege escalation
- **Additional**: Dropped all capabilities except NET_BIND_SERVICE

### 6. Resource Limits
- **Implementation**: Memory and CPU limits
- **Benefit**: Prevents resource exhaustion attacks
- **Limits**: 512MB memory, 0.5 CPU cores

### 7. Health Checks
- **Implementation**: Comprehensive health monitoring
- **Benefit**: Early detection of issues
- **Interval**: 30 seconds with 3 retries

### 8. Vulnerability Scanning
- **Tool**: Trivy
- **Frequency**: Continuous integration and periodic scans
- **Severity**: High and Critical vulnerabilities flagged

### 9. Secrets Management
- **Implementation**: Docker secrets
- **Benefit**: Secure credential storage
- **Access**: Runtime-only, not in image layers

### 10. Network Security
- **Implementation**: Isolated network with ICC disabled
- **Benefit**: Limits container-to-container communication
- **Configuration**: Bridge network with security options

## Security Monitoring

### Automated Checks
- Vulnerability scanning with Trivy
- Resource usage monitoring
- Security configuration validation
- File system integrity checks

### Manual Checks
- Regular security audits
- Penetration testing
- Code security reviews
- Dependency updates

## Incident Response

### Security Events
1. **Vulnerability Detection**: Immediate patching or mitigation
2. **Resource Exhaustion**: Scale or optimize resources
3. **Unauthorized Access**: Immediate container restart and investigation
4. **Data Breach**: Follow incident response procedures

### Monitoring Alerts
- High CPU/Memory usage
- Failed health checks
- Security option violations
- Unusual network activity

## Compliance

### Standards Met
- OWASP Container Security
- CIS Docker Benchmark
- NIST Cybersecurity Framework
- Industry best practices

### Regular Updates
- Base image updates
- Dependency updates
- Security patch management
- Configuration reviews

## Security Contacts
- Security Team: security@company.com
- Incident Response: incident@company.com
- Emergency: +1-XXX-XXX-XXXX
EOF
```

**COMPLETE VALIDATION STEPS**:
```bash
# 1. Verify security implementations
echo "=== SECURITY VALIDATION ==="
docker run --rm ecommerce-backend:secure whoami
docker run --rm ecommerce-backend:secure id

# 2. Verify vulnerability scanning
echo "=== VULNERABILITY VALIDATION ==="
trivy image --severity HIGH,CRITICAL ecommerce-backend:secure

# 3. Verify security configurations
echo "=== SECURITY CONFIGURATION VALIDATION ==="
docker inspect ecommerce-backend:secure | jq '.[0].HostConfig.SecurityOpt'
docker inspect ecommerce-backend:secure | jq '.[0].HostConfig.CapDrop'

# 4. Verify resource limits
echo "=== RESOURCE LIMITS VALIDATION ==="
docker run -d --name security-test ecommerce-backend:secure
sleep 5
docker stats security-test --no-stream
docker stop security-test && docker rm security-test
```

**ERROR HANDLING AND TROUBLESHOOTING**:
```bash
# If security scan fails:
echo "=== SECURITY SCAN TROUBLESHOOTING ==="
# Check Trivy installation
trivy --version

# If container fails to start:
echo "=== CONTAINER STARTUP TROUBLESHOOTING ==="
# Check logs
docker logs ecommerce-backend-secure

# If security options fail:
echo "=== SECURITY OPTIONS TROUBLESHOOTING ==="
# Check Docker version
docker version

# If secrets are not accessible:
echo "=== SECRETS TROUBLESHOOTING ==="
# Check secrets files
ls -la secrets/
```

**Expected Output**:
- **Security-hardened Dockerfile** with comprehensive security measures
- **Vulnerability scan results** with detailed security assessment
- **Security configuration documentation** with implementation details
- **Production-ready security setup** with monitoring and alerting
- **Comprehensive security testing** with validation results
- **Security incident response procedures** and monitoring setup

### **Problem 3: Container Networking**

**Scenario**: Set up communication between your frontend and backend containers.

**Requirements**:
1. Create a custom Docker network
2. Configure container-to-container communication
3. Implement proper service discovery
4. Test connectivity

**Expected Output**:
- Docker Compose configuration
- Network connectivity test results
- Service discovery setup

### **Problem 4: Chaos Engineering Scenarios**

**Scenario**: Test your e-commerce application's resilience to various failure scenarios.

**Requirements**:
1. **Container Failure Testing**:
   - Simulate container crashes and restarts
   - Test different restart policies
   - Measure recovery time and data loss

2. **Resource Constraint Testing**:
   - Test application behavior under memory limits
   - Simulate CPU constraints
   - Monitor performance degradation

3. **Network Failure Testing**:
   - Simulate network partitions
   - Test service discovery failures
   - Verify graceful degradation

4. **Storage Failure Testing**:
   - Test volume mount failures
   - Simulate disk space issues
   - Verify data persistence mechanisms

**Expected Output**:
- Chaos engineering test results
- Failure mode analysis
- Resilience improvement recommendations
- Monitoring and alerting setup

### **Problem 5: Multi-Environment Container Strategy**

**Scenario**: Design container configurations for DEV, UAT, and PROD environments.

**Requirements**:
1. **Development Environment**:
   - Enable debugging tools
   - Configure hot reloading
   - Set up development databases

2. **UAT Environment**:
   - Production-like configuration
   - Testing tools integration
   - Performance monitoring

3. **Production Environment**:
   - Security hardening
   - Performance optimization
   - Monitoring and logging

**Expected Output**:
- Environment-specific Dockerfiles
- Docker Compose configurations
- Deployment strategies
- Environment promotion pipeline

**📋 Detailed Solution with Line-by-Line Analysis**:

Create a `docker-compose.yml` file:

```yaml
# Docker Compose configuration for e-commerce application
# Enables container-to-container communication and service discovery
version: '3.8'
```
**Explanation**:
- `version: '3.8'`: Specifies Docker Compose file format version
- **Version 3.8**: Supports most modern Docker features including health checks, deploy configurations

```yaml
services:
  # Backend service definition
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile.backend
```
**Explanation**:
- `services:`: Defines the services (containers) in this application
- `backend:`: Service name (becomes hostname for service discovery)
- `build:`: Specifies how to build the image
- `context: .`: Build context (current directory)
- `dockerfile: docker/Dockerfile.backend`: Path to Dockerfile

```yaml
    environment:
      - DATABASE_URL=postgresql://postgres:admin@postgres:5432/ecommerce_db
      - SECRET_KEY=your-secret-key-here
      - DEBUG=false
```
**Explanation**:
- `environment:`: Sets environment variables for the container
- `DATABASE_URL=postgresql://postgres:admin@postgres:5432/ecommerce_db`: Database connection
  - `postgres:5432`: Uses service name "postgres" as hostname (service discovery)
  - `ecommerce_db`: Database name
- `SECRET_KEY`: Application secret key
- `DEBUG=false`: Production mode

```yaml
    ports:
      - "8000:8000"
```
**Explanation**:
- `ports:`: Maps host ports to container ports
- `"8000:8000"`: Host port 8000 maps to container port 8000
- **Access**: Backend accessible at http://localhost:8000

```yaml
    depends_on:
      - postgres
```
**Explanation**:
- `depends_on:`: Defines service dependencies
- `postgres`: Backend waits for postgres service to start
- **Order**: Ensures database is ready before backend starts

```yaml
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```
**Explanation**:
- `healthcheck:`: Defines health check for the service
- `test: ["CMD", "curl", "-f", "http://localhost:8000/health"]`: Health check command
- `interval: 30s`: Check every 30 seconds
- `timeout: 10s`: Wait 10 seconds for response
- `retries: 3`: Mark unhealthy after 3 failures
- `start_period: 40s`: Wait 40 seconds before first check

```yaml
    networks:
      - ecommerce-network
```
**Explanation**:
- `networks:`: Specifies which networks this service connects to
- `ecommerce-network`: Custom network for service communication

```yaml
  # Frontend service definition
  frontend:
    build:
      context: .
      dockerfile: docker/Dockerfile.frontend
      args:
        - REACT_APP_API_URL=http://localhost:8000
        - REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
```
**Explanation**:
- `frontend:`: Frontend service name
- `args:`: Build arguments passed to Dockerfile
- `REACT_APP_API_URL=http://localhost:8000`: API URL for React app
- `REACT_APP_API_BASE_URL=http://localhost:8000/api/v1`: API base URL

```yaml
    ports:
      - "3000:80"
    depends_on:
      - backend
```
**Explanation**:
- `"3000:80"`: Maps host port 3000 to container port 80 (Nginx)
- `depends_on: - backend`: Frontend waits for backend to be ready
- **Access**: Frontend accessible at http://localhost:3000

```yaml
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - ecommerce-network
```
**Explanation**:
- Similar health check pattern as backend
- `http://localhost/`: Tests Nginx serving content
- Same network configuration for service communication

```yaml
  # Database service definition
  postgres:
    image: postgres:13-alpine
```
**Explanation**:
- `postgres:`: Database service name (used in DATABASE_URL)
- `image: postgres:13-alpine`: Uses official PostgreSQL 13 Alpine image
- **Alpine**: Smaller, more secure base image

```yaml
    environment:
      - POSTGRES_DB=ecommerce_db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=admin
```
**Explanation**:
- `POSTGRES_DB=ecommerce_db`: Creates database named ecommerce_db
- `POSTGRES_USER=postgres`: Creates user postgres
- `POSTGRES_PASSWORD=admin`: Sets password for postgres user
- **Security Note**: Use strong passwords in production

```yaml
    volumes:
      - postgres_data:/var/lib/postgresql/data
```
**Explanation**:
- `volumes:`: Defines persistent storage
- `postgres_data:/var/lib/postgresql/data`: Named volume for database persistence
- **Persistence**: Data survives container restarts

```yaml
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - ecommerce-network
```
**Explanation**:
- `pg_isready -U postgres`: PostgreSQL-specific health check
- `interval: 10s`: Check every 10 seconds (more frequent for database)
- `retries: 5`: More retries for database startup

```yaml
# Network definition
networks:
  ecommerce-network:
    driver: bridge
```
**Explanation**:
- `networks:`: Defines custom networks
- `ecommerce-network:`: Network name
- `driver: bridge`: Uses bridge network driver
- **Service Discovery**: Containers can reach each other by service name

```yaml
# Volume definition
volumes:
  postgres_data:
```
**Explanation**:
- `volumes:`: Defines named volumes
- `postgres_data:`: Volume name for database persistence
- **Management**: Docker manages the volume location

**🔧 Usage Commands**:

```bash
# Start all services
docker-compose up -d
```
**Explanation**:
- `docker-compose up`: Creates and starts all services
- `-d`: Detached mode (runs in background)
- **Result**: All containers start with proper networking

```bash
# Check service status
docker-compose ps
```
**Explanation**:
- `docker-compose ps`: Shows status of all services
- **Output**: Service name, command, state, ports

```bash
# View logs
docker-compose logs -f backend
```
**Explanation**:
- `docker-compose logs`: Shows logs from services
- `-f`: Follow logs in real-time
- `backend`: Specific service name

```bash
# Test connectivity
docker-compose exec backend curl http://postgres:5432
```
**Explanation**:
- `docker-compose exec`: Execute command in running service
- `backend`: Service name
- `curl http://postgres:5432`: Test connection to postgres service
- **Service Discovery**: Uses service name "postgres" as hostname

```bash
# Stop all services
docker-compose down
```
**Explanation**:
- `docker-compose down`: Stops and removes all services
- **Cleanup**: Removes containers, networks, but preserves volumes

---

## 📝 **Assessment Quiz**

### **Multiple Choice Questions**

1. **What is the primary advantage of containers over virtual machines?**
   - A) Better security
   - B) Lower resource overhead
   - C) Easier management
   - D) Better performance

2. **In a multi-stage Docker build, what happens to the build stage?**
   - A) It becomes part of the final image
   - B) It's discarded after the build
   - C) It's cached for future builds
   - D) It's pushed to the registry

3. **What does the `HEALTHCHECK` instruction do?**
   - A) Monitors container resource usage
   - B) Checks if the application is responding
   - C) Validates container configuration
   - D) Tests network connectivity

### **Practical Questions**

4. **Explain the difference between `COPY` and `ADD` in Dockerfiles.**

5. **Why is it important to run containers as non-root users?**

6. **How does Docker layer caching work, and how can you optimize it?**

---

## 🚀 **Mini-Project: Production-Ready Container Strategy**

### **Project Requirements**

Design and implement a comprehensive container strategy for your e-commerce application across all environments:

1. **Multi-Environment Containerization**
   - Create DEV, UAT, and PROD specific Dockerfiles
   - Implement environment-specific configurations
   - Set up proper environment variable management
   - Design environment promotion pipeline

2. **Image Size Optimization**
   - Reduce backend image size by 40%
   - Reduce frontend image size by 50%
   - Implement proper layer caching
   - Use multi-stage builds effectively

3. **Security Hardening**
   - Run all containers as non-root users
   - Implement proper health checks
   - Use minimal base images
   - Scan for vulnerabilities
   - Implement secrets management

4. **Chaos Engineering Implementation**
   - Design failure scenarios for each environment
   - Implement resilience testing
   - Create monitoring and alerting
   - Document failure modes and recovery procedures

5. **Performance Optimization**
   - Optimize build times
   - Implement proper resource limits
   - Configure logging properly
   - Set up performance monitoring

### **Deliverables**

- **Environment-Specific Dockerfiles**: DEV, UAT, and PROD configurations
- **Docker Compose Configurations**: For each environment
- **Chaos Engineering Test Suite**: Automated failure testing
- **Security Scan Results**: Vulnerability assessment and remediation
- **Performance Benchmarks**: Before/after optimization metrics
- **Monitoring Setup**: Health checks, logging, and alerting
- **Documentation**: Complete container strategy and deployment guide
- **CI/CD Pipeline**: Automated building, testing, and deployment

### **Chaos Engineering Deliverables**

- **Failure Scenario Documentation**: Detailed test cases for each failure mode
- **Resilience Test Results**: Recovery time and data loss measurements
- **Monitoring Dashboards**: Real-time visibility into system health
- **Alerting Rules**: Automated notifications for failure scenarios
- **Recovery Procedures**: Step-by-step guides for common failures

---

## 🎤 **Interview Questions and Answers**

### **Q1: Explain the difference between containers and virtual machines.**

**Answer**:
Containers and VMs differ fundamentally in their architecture:

**Containers**:
- Share the host OS kernel
- Lightweight (MBs in size)
- Fast startup (seconds)
- Process-level isolation
- High resource efficiency

**Virtual Machines**:
- Each VM has its own OS
- Heavy (GBs in size)
- Slower startup (minutes)
- Hardware-level isolation
- Higher resource overhead

**Real-world example**: In our e-commerce application, we can run multiple containers (frontend, backend, database) on a single host, whereas VMs would require separate OS instances for each service.

### **Q2: What are the benefits of multi-stage Docker builds?**

**Answer**:
Multi-stage builds provide several key benefits:

1. **Smaller Final Images**: Build dependencies are discarded
2. **Security**: Build tools aren't included in production images
3. **Efficiency**: Only runtime dependencies in final image
4. **Caching**: Each stage can be cached independently

**Example from our e-commerce backend**:
```dockerfile
# Build stage - includes build tools
FROM python:3.11-slim as builder
RUN apt-get install -y build-essential  # Build tools

# Production stage - only runtime dependencies
FROM python:3.11-slim as production
RUN apt-get install -y libpq5  # Only runtime library
```

### **Q3: How do you ensure container security in production?**

**Answer**:
Container security involves multiple layers:

1. **Base Image Security**:
   - Use minimal, official base images
   - Regularly update base images
   - Scan images for vulnerabilities

2. **Runtime Security**:
   - Run containers as non-root users
   - Implement proper resource limits
   - Use read-only filesystems where possible

3. **Network Security**:
   - Use custom networks
   - Implement network policies
   - Encrypt traffic between containers

4. **Secrets Management**:
   - Never hardcode secrets in images
   - Use external secret management
   - Rotate secrets regularly

**Example from our e-commerce app**:
```dockerfile
# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Health check for monitoring
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

### **Q4: Explain Docker layer caching and how to optimize it.**

**Answer**:
Docker layer caching works by storing intermediate layers and reusing them when possible:

**How it works**:
- Each instruction creates a new layer
- Layers are cached based on instruction content
- If instruction changes, all subsequent layers are rebuilt

**Optimization strategies**:

1. **Order Instructions by Change Frequency**:
```dockerfile
# Copy package files first (changes less frequently)
COPY package*.json ./
RUN npm install

# Copy source code last (changes more frequently)
COPY . .
```

2. **Use .dockerignore**:
```dockerignore
node_modules
.git
*.md
.env
```

3. **Combine Related Commands**:
```dockerfile
# Good - single layer
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Bad - multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*
```

### **Q5: How would you troubleshoot a container that won't start?**

**Answer**:
Troubleshooting container startup issues involves systematic debugging:

1. **Check Container Logs**:
```bash
docker logs <container-name>
docker logs --tail 100 -f <container-name>
```

2. **Inspect Container Configuration**:
```bash
docker inspect <container-name>
```

3. **Test Image Locally**:
```bash
docker run -it <image-name> /bin/bash
```

4. **Check Resource Constraints**:
```bash
docker stats
docker system df
```

5. **Verify Dependencies**:
```bash
docker network ls
docker volume ls
```

**Common issues and solutions**:
- **Port conflicts**: Check if port is already in use
- **Missing environment variables**: Verify required env vars
- **File permissions**: Check file ownership and permissions
- **Resource limits**: Ensure sufficient memory/CPU
- **Network issues**: Verify network configuration

### **Q6: How would you implement chaos engineering for containerized applications?**

**Answer**:
Chaos engineering for containers involves systematic failure testing:

1. **Container Failure Testing**:
```bash
# Test restart policies
docker run -d --restart=always --name test-app my-app:latest
docker kill test-app  # Simulate crash
docker ps  # Verify restart
```

2. **Resource Constraint Testing**:
```bash
# Test memory limits
docker run -d --memory=100m --name memory-test my-app:latest
docker stats memory-test  # Monitor behavior
```

3. **Network Failure Testing**:
```bash
# Test network isolation
docker network create test-net
docker run -d --network test-net --name isolated-app my-app:latest
docker network disconnect test-net isolated-app  # Simulate partition
```

4. **Storage Failure Testing**:
```bash
# Test volume failures
docker run -d -v /tmp/test-data:/app/data --name storage-test my-app:latest
rm -rf /tmp/test-data  # Simulate storage failure
```

**Benefits**:
- **Resilience Validation**: Ensures applications handle failures gracefully
- **Recovery Testing**: Validates restart and recovery mechanisms
- **Performance Impact**: Measures degradation under stress
- **Monitoring Validation**: Tests alerting and monitoring systems

### **Q7: How would you design containers for different environments (DEV, UAT, PROD)?**

**Answer**:
Environment-specific container design requires different configurations:

1. **Development Environment**:
```dockerfile
# DEV Dockerfile
FROM python:3.11-slim as dev
RUN apt-get install -y vim curl htop  # Debug tools
ENV DEBUG=true LOG_LEVEL=debug
EXPOSE 5678  # Debug port
```

2. **UAT Environment**:
```dockerfile
# UAT Dockerfile
FROM python:3.11-slim as uat
RUN apt-get install -y curl jq  # Testing tools
ENV DEBUG=false LOG_LEVEL=info ENVIRONMENT=uat
```

3. **Production Environment**:
```dockerfile
# PROD Dockerfile
FROM python:3.11-slim as production
RUN apt-get install -y --no-install-recommends libpq5 curl
ENV DEBUG=false LOG_LEVEL=warning ENVIRONMENT=production
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
```

**Key Differences**:
- **DEV**: Debug tools, verbose logging, hot reloading
- **UAT**: Testing tools, production-like config, performance monitoring
- **PROD**: Security hardening, minimal dependencies, health checks

**Benefits**:
- **Environment Isolation**: Each environment optimized for its purpose
- **Security**: Production containers hardened and secure
- **Debugging**: Development containers include necessary tools
- **Testing**: UAT containers include testing and monitoring tools

---

## 📈 **Real-world Scenarios**

### **Scenario 1: Production Container Deployment**

**Challenge**: Deploy your e-commerce application containers to production with zero downtime.

**Requirements**:
- Implement blue-green deployment
- Set up health checks and monitoring
- Configure proper logging
- Implement security best practices

**Solution Approach**:
1. Create production-optimized images
2. Set up container orchestration
3. Implement health checks and monitoring
4. Configure logging aggregation
5. Set up security scanning

### **Scenario 2: Container Performance Optimization**

**Challenge**: Your e-commerce application is experiencing performance issues in containers.

**Requirements**:
- Identify performance bottlenecks
- Optimize container resource usage
- Implement proper monitoring
- Scale containers effectively

**Solution Approach**:
1. Profile application performance
2. Optimize container images
3. Implement resource limits
4. Set up performance monitoring
5. Configure auto-scaling

---

## 🎯 **Module Completion Checklist**

### **Core Container Fundamentals**
- [ ] Understand container architecture and lifecycle
- [ ] Analyze e-commerce application containerization
- [ ] Build and run containers successfully
- [ ] Implement container security best practices
- [ ] Optimize container images for production

### **Environment Strategy**
- [ ] Create DEV environment container configuration
- [ ] Create UAT environment container configuration
- [ ] Create PROD environment container configuration
- [ ] Implement environment-specific Dockerfiles
- [ ] Set up environment promotion pipeline

### **Chaos Engineering**
- [ ] Implement container failure testing
- [ ] Test resource constraint scenarios
- [ ] Simulate network partition failures
- [ ] Test storage failure scenarios
- [ ] Document failure modes and recovery procedures

### **Tools and Industry Knowledge**
- [ ] Master Docker CLI commands
- [ ] Understand Docker Compose orchestration
- [ ] Learn about alternative container runtimes (Podman, containerd)
- [ ] Explore container registries and management tools
- [ ] Understand industry best practices

### **Assessment and Practice**
- [ ] Complete all practice problems
- [ ] Pass assessment quiz
- [ ] Complete mini-project with all deliverables
- [ ] Answer interview questions correctly
- [ ] Apply concepts to real-world scenarios

### **Production Readiness**
- [ ] Implement comprehensive monitoring
- [ ] Set up health checks and alerting
- [ ] Create security scanning pipeline
- [ ] Document deployment procedures
- [ ] Prepare for Kubernetes deployment

---

## 📚 **Additional Resources**

### **Documentation**
- [Docker Official Documentation](https://docs.docker.com/)
- [Container Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Multi-stage Builds Guide](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/)
- [Podman Documentation](https://docs.podman.io/)
- [containerd Documentation](https://containerd.io/docs/)

### **Chaos Engineering Resources**
- [Chaos Engineering Principles](https://principlesofchaos.org/)
- [Chaos Monkey](https://github.com/Netflix/chaosmonkey)
- [Litmus Chaos Engineering](https://litmuschaos.io/)
- [Chaos Mesh](https://chaos-mesh.org/)
- [Gremlin Chaos Engineering](https://www.gremlin.com/)

### **Environment Strategy Resources**
- [12-Factor App Methodology](https://12factor.net/)
- [Environment Configuration Best Practices](https://docs.docker.com/compose/environment-variables/)
- [Secrets Management in Containers](https://docs.docker.com/engine/swarm/secrets/)
- [Container Security Scanning](https://docs.docker.com/engine/scan/)

### **Tools**
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/)
- [Trivy Security Scanner](https://trivy.dev/)
- [Dive Image Analyzer](https://github.com/wagoodman/dive)
- [Portainer Container Management](https://www.portainer.io/)
- [Rancher Container Platform](https://rancher.com/)

### **Practice Platforms**
- [Play with Docker](https://labs.play-with-docker.com/)
- [Katacoda Docker Scenarios](https://www.katacoda.com/courses/docker)
- [Docker Labs](https://github.com/docker/labs)
- [Container Training](https://container.training/)

---

## 🚀 **Next Steps**

1. **Complete this module** by working through all labs and assessments
2. **Set up your Kubernetes cluster** using the cluster setup guide
3. **Move to Module 2**: Linux System Administration
4. **Prepare for Kubernetes** by understanding container fundamentals

---

**Congratulations! You've completed the Container Fundamentals Review. You now have a solid foundation in containerization that will be essential for your Kubernetes journey. 🎉**
