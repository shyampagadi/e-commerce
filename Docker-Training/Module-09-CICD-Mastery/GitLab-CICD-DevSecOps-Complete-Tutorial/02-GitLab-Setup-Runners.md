# 🏃‍♂️ GitLab Setup & Runners Mastery

## 📋 Learning Objectives
- **Master** GitLab runners architecture and types
- **Configure** shared, group, and project-specific runners
- **Implement** Docker, Kubernetes, and shell executors
- **Setup** auto-scaling runners for enterprise workloads
- **Secure** runner configurations and access controls

## 🎯 Real-World Context
GitLab runners are the execution engines that power CI/CD pipelines. Companies like GitLab.com itself runs thousands of concurrent jobs using sophisticated runner infrastructure. Understanding runners is critical for performance, security, and cost optimization.

---

## 🏗️ GitLab Runners Architecture Deep Dive

### **Runner Types and Hierarchy**

```
GitLab Runners Architecture
├── Instance Runners (GitLab.com shared)
│   ├── Shared across all projects
│   ├── Limited resources per job
│   ├── Public cloud infrastructure
│   └── Free tier limitations
├── Group Runners
│   ├── Shared within organization/group
│   ├── Custom resource allocation
│   ├── Group-level access control
│   └── Cost optimization for multiple projects
├── Project Runners
│   ├── Dedicated to specific project
│   ├── Maximum security isolation
│   ├── Custom environment configuration
│   └── Full resource control
└── Runner Executors
    ├── Docker Executor (containerized jobs)
    ├── Kubernetes Executor (pod-based execution)
    ├── Shell Executor (direct host execution)
    ├── SSH Executor (remote host execution)
    └── Custom Executor (specialized environments)
```

### **Runner Registration Process**

```bash
# GitLab Runner installation and registration process
# ↑ Complete process for setting up GitLab runners

# Step 1: Install GitLab Runner on your infrastructure
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
# ↑ Downloads and executes GitLab's official installation script
# This adds GitLab's package repository to your system
# Enables automatic updates and security patches

sudo apt-get install gitlab-runner
# ↑ Installs GitLab Runner package from official repository
# Creates gitlab-runner user and service
# Sets up systemd service for automatic startup

# Step 2: Register runner with GitLab instance
sudo gitlab-runner register
# ↑ Interactive registration process that connects runner to GitLab
# Prompts for GitLab URL, registration token, and configuration
# Creates runner configuration in /etc/gitlab-runner/config.toml

# Registration parameters explained:
# GitLab instance URL: https://gitlab.com (for GitLab.com) or your self-hosted URL
# Registration token: Found in GitLab UI → Settings → CI/CD → Runners
# Description: Human-readable name for the runner
# Tags: Labels for job targeting (e.g., "docker", "production", "linux")
# Executor: How jobs are executed (docker, kubernetes, shell, etc.)
```

### **Advanced Runner Configuration**

```toml
# /etc/gitlab-runner/config.toml
# ↑ GitLab Runner configuration file with detailed explanations
# This file controls all aspects of runner behavior

concurrent = 4
# ↑ Maximum number of jobs that can run simultaneously
# Higher values = more parallelism but more resource usage
# Recommended: 1-2x number of CPU cores

check_interval = 3
# ↑ How often (seconds) runner checks GitLab for new jobs
# Lower values = faster job pickup but more API calls
# Recommended: 3-10 seconds for most use cases

log_level = "info"
# ↑ Logging verbosity level
# Options: debug, info, warn, error, fatal, panic
# Use "debug" for troubleshooting, "info" for production

shutdown_timeout = 0
# ↑ Graceful shutdown timeout in seconds
# 0 = wait indefinitely for jobs to complete
# >0 = force shutdown after specified time

[[runners]]
# ↑ Runner configuration block (can have multiple runners)
  name = "docker-runner-production"
  # ↑ Human-readable runner name (appears in GitLab UI)
  
  url = "https://gitlab.com/"
  # ↑ GitLab instance URL this runner connects to
  
  token = "your-runner-token-here"
  # ↑ Authentication token (generated during registration)
  # Keep this secret - it provides access to your GitLab instance
  
  executor = "docker"
  # ↑ Execution method for jobs
  # docker = runs jobs in Docker containers (most common)
  # kubernetes = runs jobs as Kubernetes pods
  # shell = runs jobs directly on host (less secure)
  
  [runners.custom_build_dir]
  # ↑ Custom build directory configuration
    enabled = true
    # ↑ Allows jobs to specify custom working directories
    
  [runners.cache]
  # ↑ Cache configuration for faster builds
    Type = "s3"
    # ↑ Cache storage type (s3, gcs, azure, local)
    Path = "cache"
    # ↑ Cache path/prefix in storage
    Shared = true
    # ↑ Share cache between different jobs/projects
    
    [runners.cache.s3]
    # ↑ S3-specific cache configuration
      ServerAddress = "s3.amazonaws.com"
      # ↑ S3 endpoint URL
      AccessKey = "your-access-key"
      # ↑ AWS access key for S3 access
      SecretKey = "your-secret-key"
      # ↑ AWS secret key for S3 access
      BucketName = "gitlab-runner-cache"
      # ↑ S3 bucket name for cache storage
      BucketLocation = "us-east-1"
      # ↑ AWS region for S3 bucket
      
  [runners.docker]
  # ↑ Docker executor specific configuration
    tls_verify = false
    # ↑ Docker TLS verification (set true for production)
    image = "docker:20.10.16"
    # ↑ Default Docker image for jobs (if not specified in .gitlab-ci.yml)
    privileged = true
    # ↑ Run containers in privileged mode
    # Required for Docker-in-Docker (building images in CI)
    # Security risk: only enable if needed
    
    disable_entrypoint_overwrite = false
    # ↑ Allow jobs to override container entrypoint
    
    oom_kill_disable = false
    # ↑ Disable out-of-memory killer
    # false = containers killed if they use too much memory
    
    disable_cache = false
    # ↑ Enable/disable cache functionality
    
    volumes = [
      "/certs/client",
      "/cache",
      "/var/run/docker.sock:/var/run/docker.sock"
    ]
    # ↑ Volume mounts for Docker containers
    # /certs/client = Docker TLS certificates
    # /cache = Cache directory mount
    # /var/run/docker.sock = Docker socket for Docker-in-Docker
    
    shm_size = 2147483648
    # ↑ Shared memory size in bytes (2GB in this example)
    # Important for applications that use shared memory
    
    [runners.docker.tmpfs]
    # ↑ Temporary filesystem mounts (in-memory storage)
      "/tmp" = "rw,size=1g"
      # ↑ Mount /tmp as 1GB tmpfs for faster temporary file operations
```

---

## 🐳 Docker Executor Deep Dive

### **Docker Executor Configuration**

```yaml
# .gitlab-ci.yml - Docker executor job examples
# ↑ GitLab CI configuration showing Docker executor usage

# Global variables for Docker configuration
variables:
  # ↑ Variables available to all jobs in the pipeline
  DOCKER_DRIVER: overlay2
  # ↑ Docker storage driver for better performance
  # overlay2 is fastest and most stable driver
  
  DOCKER_TLS_CERTDIR: "/certs"
  # ↑ Directory for Docker TLS certificates
  # Required for Docker-in-Docker security
  
  DOCKER_HOST: tcp://docker:2376
  # ↑ Docker daemon connection string
  # Points to Docker-in-Docker service
  
  DOCKER_TLS_VERIFY: 1
  # ↑ Enable Docker TLS verification for security

# Basic Docker job example
build-application:
  # ↑ Job name for building application
  stage: build
  # ↑ Pipeline stage this job belongs to
  
  image: docker:20.10.16
  # ↑ Docker image to run this job in
  # docker:20.10.16 includes Docker CLI and tools
  
  services:
    # ↑ Additional containers to run alongside main job
    - docker:20.10.16-dind
    # ↑ Docker-in-Docker service for building images
    # "dind" = Docker in Docker
    # Allows building Docker images within CI jobs
  
  before_script:
    # ↑ Commands to run before main script
    - docker info
    # ↑ Display Docker system information
    # Useful for debugging Docker connectivity issues
    
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    # ↑ Login to GitLab Container Registry
    # $CI_REGISTRY_USER = automatically provided by GitLab
    # $CI_REGISTRY_PASSWORD = automatically provided by GitLab
    # $CI_REGISTRY = GitLab registry URL for this project
  
  script:
    # ↑ Main job commands
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    # ↑ Build Docker image with commit SHA as tag
    # $CI_REGISTRY_IMAGE = full image name including registry
    # $CI_COMMIT_SHA = git commit hash for unique tagging
    
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    # ↑ Push built image to GitLab Container Registry
    
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    # ↑ Tag image as "latest" for convenience
    
    - docker push $CI_REGISTRY_IMAGE:latest
    # ↑ Push latest tag to registry
  
  rules:
    # ↑ Conditions for when this job should run
    - if: $CI_COMMIT_BRANCH == "main"
    # ↑ Only run on main branch commits
    # Prevents building images for every feature branch

# Multi-stage Docker build example
build-optimized:
  # ↑ Job demonstrating optimized Docker builds
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  
  variables:
    # ↑ Job-specific variables
    DOCKER_BUILDKIT: 1
    # ↑ Enable Docker BuildKit for advanced features
    # Provides better caching, multi-platform builds, secrets
    
    BUILDKIT_PROGRESS: plain
    # ↑ BuildKit progress output format
    # "plain" shows detailed build steps in CI logs
  
  script:
    - |
      # ↑ Multi-line script using YAML literal block
      # Build multi-stage Docker image with caching
      docker build \
        --cache-from $CI_REGISTRY_IMAGE:cache \
        --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA \
        --tag $CI_REGISTRY_IMAGE:cache \
        --file Dockerfile.production \
        .
      # ↑ Advanced Docker build with layer caching
      # --cache-from uses previous build as cache source
      # --tag creates multiple tags in single build
      # --file specifies custom Dockerfile name
      
      # Push both the versioned image and cache
      docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      docker push $CI_REGISTRY_IMAGE:cache
```

---

## ☸️ Kubernetes Executor Configuration

### **Kubernetes Executor Setup**

```toml
# Kubernetes executor configuration in config.toml
# ↑ Advanced configuration for running GitLab jobs in Kubernetes

[[runners]]
  name = "kubernetes-runner"
  url = "https://gitlab.com/"
  token = "your-token"
  executor = "kubernetes"
  # ↑ Use Kubernetes executor instead of Docker
  
  [runners.kubernetes]
  # ↑ Kubernetes-specific configuration section
    host = "https://kubernetes.example.com"
    # ↑ Kubernetes API server URL
    # Can be cluster internal URL if runner runs inside cluster
    
    namespace = "gitlab-runner"
    # ↑ Kubernetes namespace for runner pods
    # Should be dedicated namespace for security isolation
    
    namespace_overwrite_allowed = "ci-.*"
    # ↑ Regex pattern for allowed namespace overrides
    # Jobs can specify different namespaces matching this pattern
    
    privileged = false
    # ↑ Run pods in privileged mode (security consideration)
    # Only enable if absolutely necessary (e.g., Docker-in-Docker)
    
    cpu_limit = "2"
    # ↑ Maximum CPU cores per job pod
    # Kubernetes CPU units (1 = 1 CPU core)
    
    memory_limit = "4Gi"
    # ↑ Maximum memory per job pod
    # Kubernetes memory units (Gi = Gibibytes)
    
    service_cpu_limit = "500m"
    # ↑ CPU limit for service containers
    # "m" suffix = millicores (500m = 0.5 CPU cores)
    
    service_memory_limit = "1Gi"
    # ↑ Memory limit for service containers
    
    helper_cpu_limit = "100m"
    # ↑ CPU limit for GitLab helper containers
    # Helper containers handle Git operations, artifacts, etc.
    
    helper_memory_limit = "128Mi"
    # ↑ Memory limit for helper containers
    # "Mi" = Mebibytes (binary megabytes)
    
    poll_interval = 3
    # ↑ How often to check for new jobs (seconds)
    
    poll_timeout = 180
    # ↑ Timeout for polling operations (seconds)
    
    pod_termination_grace_period_seconds = 600
    # ↑ Grace period before forcefully killing pods
    # Allows jobs to clean up gracefully
    
    image_pull_secrets = ["gitlab-registry-secret"]
    # ↑ Kubernetes secrets for pulling private images
    # Must be created in the runner namespace
    
    [runners.kubernetes.node_selector]
    # ↑ Node selection constraints for job pods
      "node-type" = "ci-runner"
      # ↑ Only schedule pods on nodes with this label
      # Useful for dedicating specific nodes to CI workloads
      
    [runners.kubernetes.node_tolerations]
    # ↑ Tolerations for scheduling on tainted nodes
      "ci-runner/dedicated" = "NoSchedule:Equal"
      # ↑ Allow scheduling on nodes tainted for CI workloads
      
    [[runners.kubernetes.volumes.host_path]]
    # ↑ Mount host directories into job pods
      name = "docker-socket"
      mount_path = "/var/run/docker.sock"
      host_path = "/var/run/docker.sock"
      # ↑ Mount Docker socket for Docker-in-Docker
      # Security risk: only use in trusted environments
      
    [[runners.kubernetes.volumes.pvc]]
    # ↑ Mount persistent volume claims
      name = "cache-pvc"
      mount_path = "/cache"
      # ↑ Persistent cache storage across job runs
      
    [[runners.kubernetes.volumes.config_map]]
    # ↑ Mount ConfigMaps as volumes
      name = "runner-config"
      mount_path = "/etc/runner-config"
      # ↑ Mount configuration files from ConfigMap
      
    [[runners.kubernetes.volumes.secret]]
    # ↑ Mount Secrets as volumes
      name = "runner-secrets"
      mount_path = "/etc/runner-secrets"
      # ↑ Mount sensitive data from Kubernetes Secrets
```

### **Kubernetes Job Example**

```yaml
# .gitlab-ci.yml - Kubernetes executor job configuration
# ↑ GitLab CI configuration optimized for Kubernetes executor

variables:
  # ↑ Global variables for Kubernetes jobs
  KUBERNETES_NAMESPACE_OVERWRITE: "ci-${CI_PROJECT_ID}"
  # ↑ Override default namespace with project-specific namespace
  # Provides isolation between different projects
  
  KUBERNETES_CPU_REQUEST: "100m"
  # ↑ Minimum CPU guaranteed for job pods
  # Kubernetes will reserve this CPU for the pod
  
  KUBERNETES_CPU_LIMIT: "2"
  # ↑ Maximum CPU the pod can use
  # Pod will be throttled if it exceeds this limit
  
  KUBERNETES_MEMORY_REQUEST: "128Mi"
  # ↑ Minimum memory guaranteed for job pods
  
  KUBERNETES_MEMORY_LIMIT: "4Gi"
  # ↑ Maximum memory the pod can use
  # Pod will be killed if it exceeds this limit

# Kubernetes-optimized build job
k8s-build:
  # ↑ Job name indicating Kubernetes execution
  stage: build
  image: docker:20.10.16
  
  services:
    # ↑ Service containers for Kubernetes pods
    - name: docker:20.10.16-dind
      # ↑ Docker-in-Docker service
      alias: docker
      # ↑ Service alias for network connectivity
      
  variables:
    # ↑ Job-specific variables for Kubernetes
    KUBERNETES_SERVICE_CPU_REQUEST: "100m"
    # ↑ CPU request for service containers
    KUBERNETES_SERVICE_MEMORY_REQUEST: "256Mi"
    # ↑ Memory request for service containers
    
    DOCKER_HOST: tcp://docker:2376
    # ↑ Connect to Docker service using alias
    DOCKER_TLS_CERTDIR: "/certs"
    # ↑ TLS certificate directory for secure Docker connection
  
  before_script:
    # ↑ Pre-execution setup commands
    - until docker info; do sleep 1; done
    # ↑ Wait for Docker service to be ready
    # Kubernetes pods start asynchronously, so we need to wait
    
  script:
    # ↑ Main build commands
    - docker build -t $CI_REGISTRY_IMAGE:k8s-$CI_COMMIT_SHA .
    # ↑ Build image with Kubernetes-specific tag
    - docker push $CI_REGISTRY_IMAGE:k8s-$CI_COMMIT_SHA
    # ↑ Push to registry
  
  rules:
    # ↑ Execution conditions
    - if: $CI_KUBERNETES_ACTIVE
    # ↑ Only run if Kubernetes integration is active
```

---

## 🔧 Runner Auto-Scaling Configuration

### **Docker Machine Auto-Scaling**

```toml
# Auto-scaling runner configuration using Docker Machine
# ↑ Configuration for automatically scaling runners based on demand

[[runners]]
  name = "auto-scaling-runner"
  url = "https://gitlab.com/"
  token = "your-token"
  executor = "docker+machine"
  # ↑ Docker Machine executor for auto-scaling
  # Creates and destroys VMs automatically based on job queue
  
  limit = 20
  # ↑ Maximum number of concurrent jobs
  # Also limits maximum number of VMs created
  
  [runners.docker]
    image = "docker:20.10.16"
    privileged = true
    
  [runners.machine]
  # ↑ Docker Machine configuration for auto-scaling
    IdleCount = 2
    # ↑ Number of idle VMs to keep running
    # Provides immediate capacity for new jobs
    
    IdleTime = 1800
    # ↑ Time (seconds) to keep idle VMs before destroying
    # 1800 = 30 minutes idle time
    
    MaxBuilds = 100
    # ↑ Maximum jobs per VM before recreation
    # Prevents resource leaks and ensures fresh environment
    
    MachineDriver = "amazonec2"
    # ↑ Cloud provider driver (amazonec2, google, azure, etc.)
    
    MachineName = "gitlab-runner-%s"
    # ↑ VM naming pattern (%s replaced with unique identifier)
    
    MachineOptions = [
      # ↑ Cloud provider specific options
      "amazonec2-access-key=your-access-key",
      # ↑ AWS access key for EC2 operations
      "amazonec2-secret-key=your-secret-key", 
      # ↑ AWS secret key for EC2 operations
      "amazonec2-region=us-east-1",
      # ↑ AWS region for VM creation
      "amazonec2-vpc-id=vpc-12345678",
      # ↑ VPC ID for network isolation
      "amazonec2-subnet-id=subnet-12345678",
      # ↑ Subnet ID for VM placement
      "amazonec2-security-group=gitlab-runner-sg",
      # ↑ Security group for network access control
      "amazonec2-instance-type=t3.medium",
      # ↑ EC2 instance type (CPU/memory configuration)
      "amazonec2-ami=ami-0abcdef1234567890",
      # ↑ Amazon Machine Image ID (OS template)
      "amazonec2-root-size=20",
      # ↑ Root disk size in GB
      "amazonec2-tags=Name,GitLab Runner,Environment,CI",
      # ↑ EC2 tags for resource management and billing
    ]
    
    OffPeakPeriods = [
      # ↑ Time periods with reduced capacity needs
      "* * 0-7,18-23 * * mon-fri *",
      # ↑ Weekday nights and early mornings
      "* * * * * sat,sun *"
      # ↑ Weekends
    ]
    
    OffPeakIdleCount = 0
    # ↑ Idle VMs during off-peak periods
    # Reduces costs when demand is low
    
    OffPeakIdleTime = 300
    # ↑ Faster VM destruction during off-peak (5 minutes)
```

---

## 🛡️ Runner Security Best Practices

### **Security Configuration**

```toml
# Security-hardened runner configuration
# ↑ Production-ready security settings for GitLab runners

[[runners]]
  name = "secure-production-runner"
  url = "https://gitlab.com/"
  token = "your-secure-token"
  executor = "docker"
  
  # Security settings
  [runners.docker]
    image = "docker:20.10.16"
    privileged = false
    # ↑ Disable privileged mode for security
    # Only enable if absolutely necessary
    
    disable_entrypoint_overwrite = true
    # ↑ Prevent jobs from overriding container entrypoint
    # Reduces attack surface
    
    disable_cache = false
    # ↑ Keep cache enabled for performance
    
    volumes = [
      "/cache",
      # ↑ Only mount necessary volumes
      # Avoid mounting sensitive host directories
    ]
    
    security_opt = [
      "no-new-privileges:true",
      # ↑ Prevent privilege escalation within containers
      "seccomp:unconfined"
      # ↑ Security compute mode (adjust based on needs)
    ]
    
    cap_drop = ["ALL"]
    # ↑ Drop all Linux capabilities by default
    # Add back only specific capabilities if needed
    
    cap_add = ["NET_ADMIN"]
    # ↑ Add only required capabilities
    # Example: NET_ADMIN for network configuration
    
    devices = []
    # ↑ Don't expose host devices to containers
    # Only add specific devices if absolutely necessary
    
    [runners.docker.tmpfs]
      "/tmp" = "rw,size=100m,noexec"
      # ↑ Mount /tmp as tmpfs with security restrictions
      # noexec prevents execution of files in /tmp
```

### **Network Security Configuration**

```bash
# Network security setup for GitLab runners
# ↑ Commands to secure runner network access

# Create dedicated network for runner containers
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  gitlab-runner-network
# ↑ Creates isolated network for runner containers
# Prevents containers from accessing host network directly

# Configure firewall rules for runner host
sudo ufw enable
# ↑ Enable Ubuntu firewall

sudo ufw default deny incoming
# ↑ Block all incoming connections by default

sudo ufw default allow outgoing
# ↑ Allow outgoing connections (needed for GitLab communication)

sudo ufw allow ssh
# ↑ Allow SSH for remote administration

sudo ufw allow from 172.20.0.0/16 to any port 22
# ↑ Allow SSH only from runner network

# Allow GitLab.com IP ranges (update as needed)
sudo ufw allow out 443 comment 'GitLab HTTPS'
# ↑ Allow HTTPS to GitLab for API communication

sudo ufw allow out 22 comment 'GitLab SSH'
# ↑ Allow SSH to GitLab for Git operations
```

---

## 📊 Runner Monitoring and Troubleshooting

### **Monitoring Configuration**

```bash
# GitLab Runner monitoring and logging setup
# ↑ Commands to monitor runner health and performance

# Enable detailed logging
sudo gitlab-runner --debug run
# ↑ Run runner with debug logging
# Shows detailed information about job execution

# Check runner status
sudo gitlab-runner status
# ↑ Display current runner status and configuration

# List registered runners
sudo gitlab-runner list
# ↑ Show all registered runners and their configuration

# Monitor runner logs
sudo journalctl -u gitlab-runner -f
# ↑ Follow GitLab Runner service logs in real-time
# Useful for troubleshooting job execution issues

# Check runner metrics (if Prometheus integration enabled)
curl http://localhost:9252/metrics
# ↑ Retrieve Prometheus metrics from runner
# Provides detailed performance and usage statistics
```

### **Common Troubleshooting Commands**

```bash
# GitLab Runner troubleshooting toolkit
# ↑ Essential commands for diagnosing runner issues

# Verify runner registration
sudo gitlab-runner verify
# ↑ Check if runner can communicate with GitLab
# Tests authentication and network connectivity

# Test runner connectivity
sudo gitlab-runner exec docker test-job
# ↑ Execute a test job locally without GitLab
# Useful for testing runner configuration

# Reset runner registration
sudo gitlab-runner unregister --name "runner-name"
# ↑ Remove runner registration from GitLab
sudo gitlab-runner register
# ↑ Re-register runner with new configuration

# Check Docker connectivity (for Docker executor)
docker info
# ↑ Verify Docker daemon is accessible
docker run --rm hello-world
# ↑ Test basic Docker functionality

# Monitor resource usage
htop
# ↑ Monitor CPU and memory usage during job execution
df -h
# ↑ Check disk space usage
docker system df
# ↑ Check Docker disk usage (images, containers, volumes)
```

This comprehensive runners module provides detailed explanations for every aspect of GitLab runner configuration, from basic setup to enterprise auto-scaling and security hardening. Each code block includes extensive comments explaining the purpose and impact of every configuration option.
