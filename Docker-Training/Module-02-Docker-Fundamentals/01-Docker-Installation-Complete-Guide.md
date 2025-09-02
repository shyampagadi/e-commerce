# 🐳 Docker Installation: Complete Expert Guide

## 🎯 Learning Objectives
By the end of this section, you will:
- Understand Docker architecture in complete detail
- Install Docker correctly on any operating system
- Master every Docker installation command and option
- Troubleshoot installation issues like an expert
- Verify installation with comprehensive testing

---

## 📚 Docker Architecture Deep Dive

### What is Docker? (Complete Technical Explanation)

**Docker** is a containerization platform that uses Linux kernel features to create isolated environments called containers. Think of it as a lightweight virtualization technology.

#### Traditional Virtual Machines vs Docker Containers
```
Traditional Virtual Machines:
┌─────────────────────────────────────────┐
│ Application A │ Application B           │
├───────────────┼─────────────────────────┤
│ Guest OS      │ Guest OS                │
├───────────────┼─────────────────────────┤
│ Hypervisor (VMware, VirtualBox)         │
├─────────────────────────────────────────┤
│ Host Operating System                   │
├─────────────────────────────────────────┤
│ Physical Hardware                       │
└─────────────────────────────────────────┘

Docker Containers:
┌─────────────────────────────────────────┐
│ App A │ App B │ App C │ App D           │
├───────┼───────┼───────┼─────────────────┤
│ Docker Engine (Container Runtime)       │
├─────────────────────────────────────────┤
│ Host Operating System                   │
├─────────────────────────────────────────┤
│ Physical Hardware                       │
└─────────────────────────────────────────┘
```

**Key Differences:**
- **VMs**: Each has full OS (2-4GB RAM each)
- **Containers**: Share host OS kernel (10-100MB each)
- **VMs**: Boot time 30-60 seconds
- **Containers**: Start time under 1 second

### Docker Components (Detailed Architecture)

#### 1. Docker Engine
```
Docker Engine Components:
┌─────────────────────────────────────────┐
│ Docker CLI (docker command)            │ ← What you type
├─────────────────────────────────────────┤
│ REST API                                │ ← Communication layer
├─────────────────────────────────────────┤
│ Docker Daemon (dockerd)                 │ ← Background service
├─────────────────────────────────────────┤
│ containerd (Container Runtime)          │ ← Container lifecycle
├─────────────────────────────────────────┤
│ runc (Low-level Runtime)                │ ← Creates containers
└─────────────────────────────────────────┘
```

**Detailed Explanation:**
- **Docker CLI**: Command-line interface you interact with
- **REST API**: HTTP API for programmatic access
- **Docker Daemon**: Background service managing containers
- **containerd**: High-level container runtime
- **runc**: Low-level runtime that creates containers

#### 2. Docker Objects

**Images**: Read-only templates for creating containers
```
Image Structure:
┌─────────────────────────────────────────┐
│ Application Layer (your app)            │
├─────────────────────────────────────────┤
│ Dependencies Layer (libraries)          │
├─────────────────────────────────────────┤
│ Runtime Layer (Python, Node.js, etc.)  │
├─────────────────────────────────────────┤
│ OS Layer (Ubuntu, Alpine, etc.)        │
└─────────────────────────────────────────┘
```

**Containers**: Running instances of images
```
Container = Image + Writable Layer + Network + Volumes
```

---

## 🔧 Docker Installation by Operating System

### Linux Installation (Ubuntu/Debian) - Complete Process

#### Method 1: Official Docker Repository (Recommended)

##### Step 1: System Preparation
```bash
# Update package database
sudo apt update
```

**Command Breakdown:**
- `sudo`: Execute as superuser (required for system changes)
- `apt`: Advanced Package Tool (Debian/Ubuntu package manager)
- `update`: Refresh package database from repositories

**Expected Output:**
```
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Reading package lists... Done
```

**What this means:**
- `Hit`: Repository unchanged since last update
- `Get`: Downloading updated package information
- `Reading package lists... Done`: Successfully updated local database

##### Step 2: Install Prerequisites
```bash
# Install required packages
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

**Command Breakdown:**
- `install -y`: Install packages with automatic "yes" to prompts
- `\`: Line continuation character
- `apt-transport-https`: Allows apt to download over HTTPS
- `ca-certificates`: Certificate authority certificates for SSL verification
- `curl`: Command-line tool for downloading files
- `gnupg`: GNU Privacy Guard for cryptographic operations
- `lsb-release`: Provides Linux Standard Base information

**Expected Output:**
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  apt-transport-https ca-certificates curl gnupg lsb-release
0 upgraded, 5 newly installed, 0 to remove and 0 not upgraded.
Need to get 1,234 kB of archives.
After this operation, 2,345 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu focal/main amd64 curl amd64 7.68.0-1ubuntu2.7 [161 kB]
...
Setting up curl (7.68.0-1ubuntu2.7) ...
Processing triggers for ca-certificates (20210119~20.04.2) ...
Updating certificates in /etc/ssl/certs...
```

##### Step 3: Add Docker's Official GPG Key
```bash
# Download and add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

**Command Breakdown:**
- `curl -fsSL`: Download with specific options
  - `-f`: Fail silently on HTTP errors
  - `-s`: Silent mode (no progress bar)
  - `-S`: Show errors even in silent mode
  - `-L`: Follow redirects
- `|`: Pipe output to next command
- `sudo gpg --dearmor`: Convert GPG key to binary format
- `-o /usr/share/keyrings/docker-archive-keyring.gpg`: Output file location

**Expected Output:**
```
(No output if successful - GPG key silently added)
```

**Verification:**
```bash
# Verify GPG key was added
ls -la /usr/share/keyrings/docker-archive-keyring.gpg
```

**Expected Output:**
```
-rw-r--r-- 1 root root 2,794 Jan 15 10:30 /usr/share/keyrings/docker-archive-keyring.gpg
```

##### Step 4: Add Docker Repository
```bash
# Add Docker repository to apt sources
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**Command Breakdown:**
- `echo "deb [...]"`: Create repository configuration line
- `deb`: Debian package repository format
- `[arch=amd64]`: Architecture specification
- `signed-by=...`: GPG key for verification
- `$(lsb_release -cs)`: Current Ubuntu codename (focal, jammy, etc.)
- `stable`: Release channel
- `sudo tee /etc/apt/sources.list.d/docker.list`: Write to Docker sources file
- `> /dev/null`: Suppress tee output

**Expected Output:**
```
(No visible output - repository added silently)
```

**Verification:**
```bash
# Verify repository was added
cat /etc/apt/sources.list.d/docker.list
```

**Expected Output:**
```
deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable
```

##### Step 5: Update Package Database Again
```bash
# Update apt database with Docker repository
sudo apt update
```

**Expected Output:**
```
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 https://download.docker.com/linux/ubuntu focal InRelease [57.7 kB]
Get:3 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages [13.3 kB]
Reading package lists... Done
```

**What's new:**
- Docker repository now appears in the update process
- Docker packages are now available for installation

##### Step 6: Install Docker Engine
```bash
# Install Docker CE (Community Edition)
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Command Breakdown:**
- `docker-ce`: Docker Community Edition engine
- `docker-ce-cli`: Docker command-line interface
- `containerd.io`: Container runtime
- `docker-buildx-plugin`: Extended build capabilities
- `docker-compose-plugin`: Docker Compose V2

**Expected Output:**
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  docker-ce-rootless-extras docker-scan-plugin pigz slirp4netns
The following NEW packages will be installed:
  containerd.io docker-buildx-plugin docker-ce docker-ce-cli docker-ce-rootless-extras
  docker-compose-plugin docker-scan-plugin pigz slirp4netns
0 upgraded, 9 newly installed, 0 to remove and 0 not upgraded.
Need to get 110 MB of archives.
After this operation, 413 MB of additional disk space will be used.
Get:1 https://download.docker.com/linux/ubuntu focal/stable amd64 containerd.io amd64 1.6.12-1 [28.1 MB]
...
Setting up docker-ce (5:20.10.21~3-0~ubuntu-focal) ...
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service.
Created symlink /etc/systemd/system/sockets.target.wants/docker.socket → /lib/systemd/system/docker.socket.
Processing triggers for systemd (245.4-4ubuntu3.19) ...
```

**What happened:**
- Docker engine installed successfully
- Systemd services created and enabled
- Docker daemon will start automatically on boot

##### Step 7: Start and Enable Docker Service
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check Docker service status
sudo systemctl status docker
```

**Command Breakdown:**
- `systemctl start docker`: Start Docker daemon immediately
- `systemctl enable docker`: Configure Docker to start at boot
- `systemctl status docker`: Show current service status

**Expected Output for `systemctl status docker`:**
```
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:30:45 UTC; 2min 3s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 12345 (dockerd)
      Tasks: 8
     Memory: 41.2M
     CGroup: /system.slice/docker.service
             └─12345 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Jan 15 10:30:45 ubuntu dockerd[12345]: time="2024-01-15T10:30:45.123456789Z" level=info msg="Docker daemon"
Jan 15 10:30:45 ubuntu dockerd[12345]: time="2024-01-15T10:30:45.234567890Z" level=info msg="API listen on /var/run/docker.sock"
```

**Status Explanation:**
- `Loaded: loaded`: Service definition loaded successfully
- `Active: active (running)`: Docker daemon is running
- `enabled`: Will start automatically on boot
- `Main PID: 12345`: Process ID of Docker daemon
- `Memory: 41.2M`: Current memory usage

##### Step 8: Add User to Docker Group (Optional but Recommended)
```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Apply group changes (logout/login or use newgrp)
newgrp docker
```

**Command Breakdown:**
- `usermod`: Modify user account
- `-aG docker`: Add to group (append to existing groups)
- `$USER`: Current username environment variable
- `newgrp docker`: Switch to docker group without logout

**Expected Output:**
```
(No output - user added to group silently)
```

**Verification:**
```bash
# Check group membership
groups $USER
```

**Expected Output:**
```
username : username adm dialout cdrom floppy sudo audio dip video plugdev netdev docker
```

**Why this matters:**
- Without docker group: Must use `sudo docker` for every command
- With docker group: Can use `docker` directly
- Security consideration: docker group has root-equivalent access

---

## ✅ Docker Installation Verification

### Basic Verification Commands

#### 1. Check Docker Version
```bash
# Show Docker version information
docker --version
```

**Expected Output:**
```
Docker version 20.10.21, build baeda1f
```

**Detailed version information:**
```bash
# Show comprehensive version details
docker version
```

**Expected Output:**
```
Client: Docker Engine - Community
 Version:           20.10.21
 API version:       1.41
 Go version:        go1.18.7
 Git commit:        baeda1f
 Built:             Tue Oct 25 18:01:58 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.21
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.18.7
  Git commit:       3056208
  Built:            Tue Oct 25 17:59:49 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.12
  GitCommit:        a05d175400b1145e5e6a735a6710579d181e7fb0
 runc:
  Version:          1.1.4
  GitCommit:        v1.1.4-0-g5fd4c4d
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

**Output Explanation:**
- **Client**: Docker CLI version and build info
- **Server**: Docker daemon version and components
- **API version**: Docker API compatibility
- **containerd**: Container runtime version
- **runc**: Low-level container runtime
- **docker-init**: Process initialization system

#### 2. Check Docker System Information
```bash
# Show comprehensive Docker system information
docker info
```

**Expected Output (Abbreviated):**
```
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc., v0.9.1)
  compose: Docker Compose (Docker Inc., v2.12.2)
  scan: Docker Scan (Docker Inc., v0.21.0)

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 20.10.21
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: a05d175400b1145e5e6a735a6710579d181e7fb0
 runc version: v1.1.4-0-g5fd4c4d
 init version: de40ad0
 Security Options:
  apparmor
  seccomp
   Profile: default
  cgroupns
 Kernel Version: 5.4.0-135-generic
 Operating System: Ubuntu 20.04.5 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 4
 Total Memory: 7.775GiB
 Name: ubuntu
 ID: ABCD:EFGH:IJKL:MNOP:QRST:UVWX:YZ12:3456:7890:ABCD:EFGH:IJKL
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
```

**Key Information Explained:**
- **Containers**: Current container counts by status
- **Images**: Number of images stored locally
- **Storage Driver**: How Docker stores container layers (overlay2 is modern)
- **Cgroup Driver**: Container resource management (systemd is recommended)
- **Security Options**: Security features enabled
- **Docker Root Dir**: Where Docker stores data (/var/lib/docker)
- **Registry**: Default image registry (Docker Hub)

#### 3. Test Docker with Hello World
```bash
# Run the official hello-world container
docker run hello-world
```

**Expected Output:**
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:faa03e786c97f07ef34423fccceeec2398ec8a5759259f94d99078f264e9d7af
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

**What happened step-by-step:**
1. **"Unable to find image 'hello-world:latest' locally"**: Docker searched local image cache
2. **"latest: Pulling from library/hello-world"**: Downloaded from Docker Hub
3. **"2db29710123e: Pull complete"**: Image layer downloaded successfully
4. **"Hello from Docker!"**: Container executed and produced output
5. Container automatically stopped and was removed

#### 4. Verify Docker Compose
```bash
# Check Docker Compose version
docker compose version
```

**Expected Output:**
```
Docker Compose version v2.12.2
```

**Alternative command (older versions):**
```bash
# For Docker Compose V1 (if installed separately)
docker-compose --version
```

---

## 🔍 Advanced Installation Verification

### Test Container Lifecycle
```bash
# 1. Run a container in detached mode
docker run -d --name test-nginx nginx:alpine

# 2. List running containers
docker ps

# 3. Check container logs
docker logs test-nginx

# 4. Execute command inside container
docker exec test-nginx ls /etc/nginx

# 5. Stop the container
docker stop test-nginx

# 6. Remove the container
docker rm test-nginx

# 7. Remove the image
docker rmi nginx:alpine
```

**Detailed Output Analysis:**

**Step 1 Output:**
```
Unable to find image 'nginx:alpine' locally
alpine: Pulling from library/nginx
63b65145d645: Pull complete 
fce3d4d00afa: Pull complete 
7db8b8c62e8d: Pull complete 
3cd0b96ae4c8: Pull complete 
b2b7a5399b5f: Pull complete 
5b7d4bb5e4b7: Pull complete 
Digest: sha256:8d7874c5b5d19e1fe1c7a7a67b2b2c4c5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Status: Downloaded newer image for nginx:alpine
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

**Explanation:**
- Long string at end is container ID
- Image downloaded in layers (each Pull complete line)
- Container started in background (-d flag)

**Step 2 Output:**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS     NAMES
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp    test-nginx
```

**Column Explanations:**
- **CONTAINER ID**: Unique identifier (first 12 chars)
- **IMAGE**: Source image name and tag
- **COMMAND**: Command running inside container
- **CREATED**: When container was created
- **STATUS**: Current status and uptime
- **PORTS**: Exposed ports (80/tcp means port 80 available internally)
- **NAMES**: Human-readable container name

**Step 3 Output:**
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
20-envsubst-on-templates.sh: info: No files found in /etc/nginx/templates/, not executing envsubst
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
30-tune-worker-processes.sh: info: no user explicit worker_processes configuration found, not adjusting
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/01/15 10:30:45 [notice] 1#1: using the "epoll" event method
2024/01/15 10:30:45 [notice] 1#1: nginx/1.23.3
2024/01/15 10:30:45 [notice] 1#1: built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r4) 
2024/01/15 10:30:45 [notice] 1#1: OS: Linux 5.4.0-135-generic
2024/01/15 10:30:45 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/01/15 10:30:45 [notice] 1#1: start worker processes
2024/01/15 10:30:45 [notice] 1#1: start worker process 31
```

**Log Analysis:**
- Container initialization scripts ran successfully
- Nginx configured for IPv6 support
- Worker processes started (PID 31)
- No errors - healthy container startup

### Test Network Connectivity
```bash
# Run container with port mapping
docker run -d -p 8080:80 --name web-test nginx:alpine

# Test connectivity
curl http://localhost:8080

# Check port mapping
docker port web-test

# Clean up
docker rm -f web-test
```

**Expected Outputs:**

**curl output:**
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

**docker port output:**
```
80/tcp -> 0.0.0.0:8080
```

**Explanation:**
- Container port 80 mapped to host port 8080
- 0.0.0.0 means accessible from any network interface
- Web server responding correctly

---

## 🚀 Next Steps

You now have Docker installed and verified! Key achievements:

- ✅ **Docker Engine**: Installed and running
- ✅ **Docker CLI**: Working with proper permissions  
- ✅ **Container Runtime**: Tested with hello-world
- ✅ **Network Functionality**: Port mapping verified
- ✅ **Image Management**: Pull, run, and cleanup tested

**Ready for Module 2, Part 2: Docker Commands Deep Dive** where you'll master every Docker command with complete option explanations!
