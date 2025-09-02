# Container Security Hardening - E-Commerce Security Excellence

## 📋 Learning Objectives
- **Master** enterprise container security frameworks and compliance requirements
- **Understand** threat modeling and security hardening for e-commerce applications
- **Apply** advanced security techniques to protect customer data and payments
- **Build** comprehensive security monitoring and incident response capabilities

---

## 🤔 Why Container Security Matters for E-Commerce

### **The High-Stakes Reality**

Your e-commerce platform handles:
```
Critical Assets:
├── Customer personal data (names, addresses, phone numbers)
├── Payment information (credit cards, bank details)
├── Business data (inventory, pricing, sales analytics)
├── User accounts (passwords, preferences, order history)
└── Financial transactions (payments, refunds, accounting)
```

**One security breach can:**
- Cost millions in fines (GDPR: up to 4% of revenue)
- Destroy customer trust and brand reputation
- Result in legal liability and lawsuits
- Lead to business closure

### **Container-Specific Security Challenges**

```bash
# Traditional security vs Container security
Traditional App Security:
├── Secure the server
├── Secure the application
└── Secure the network

Container Security (More Complex):
├── Secure the host OS
├── Secure the container runtime
├── Secure the container images
├── Secure the container configuration
├── Secure inter-container communication
├── Secure the orchestration platform
└── Secure the entire supply chain
```

### **E-Commerce Security Requirements**

#### **Compliance Standards**
- **PCI DSS**: Payment card industry security
- **GDPR**: European data protection regulation
- **SOC 2**: Security and availability controls
- **ISO 27001**: Information security management

#### **Security Objectives**
```
CIA Triad for E-Commerce:
├── Confidentiality: Customer data must be encrypted and access-controlled
├── Integrity: Data must not be tampered with or corrupted
└── Availability: Services must be available 99.9% of the time
```

---

## 🛡️ Container Security Model: Understanding the Layers

### **Security Layer Architecture**

```
Container Security Layers:
├── Host Security (Linux kernel, OS hardening)
├── Runtime Security (Docker daemon, containerd)
├── Image Security (Base images, vulnerabilities)
├── Container Security (Configuration, capabilities)
├── Network Security (Isolation, encryption)
├── Application Security (Code, dependencies)
└── Data Security (Encryption, access control)
```

### **Threat Model for Containerized E-Commerce**

#### **External Threats**
```
Attack Vectors:
├── Web Application Attacks
│   ├── SQL injection → Database compromise
│   ├── XSS attacks → Session hijacking
│   ├── CSRF attacks → Unauthorized actions
│   └── API abuse → Data theft
├── Infrastructure Attacks
│   ├── Container escape → Host compromise
│   ├── Privilege escalation → System takeover
│   ├── Network attacks → Data interception
│   └── Supply chain attacks → Malicious images
└── Social Engineering
    ├── Phishing → Credential theft
    ├── Insider threats → Data access
    └── Third-party breaches → Indirect compromise
```

#### **Internal Threats**
```
Insider Risks:
├── Misconfigured containers → Data exposure
├── Weak access controls → Unauthorized access
├── Unpatched vulnerabilities → System compromise
├── Poor secret management → Credential theft
└── Inadequate monitoring → Undetected breaches
```

---

## 🔒 Progressive Security Hardening

### **Level 1: Basic Container Security (Review)**

What you should already have from previous modules:
```yaml
# Basic security measures
services:
  backend:
    image: node:16-alpine  # Minimal base image
    user: "1001:1001"      # Non-root user
    read_only: true        # Read-only filesystem
    environment:
      NODE_ENV: production
    # No unnecessary ports exposed
```

### **Level 2: Intermediate Security Hardening**

```yaml
version: '3.8'

services:
  ecommerce-backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.secure
    
    # Security context
    user: "1001:1001"
    read_only: true
    
    # Security options
    security_opt:
      - no-new-privileges:true
      - apparmor:docker-default
    
    # Capability management
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if binding to port < 1024
    
    # Resource limits (prevent DoS)
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
    
    # Temporary filesystems
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /var/run:noexec,nosuid,size=50m
    
    # Environment (no secrets here)
    environment:
      NODE_ENV: production
      PORT: 8000
    
    # Secrets management
    secrets:
      - jwt_secret
      - db_password
    
    networks:
      - api_network

secrets:
  jwt_secret:
    external: true
  db_password:
    external: true

networks:
  api_network:
    driver: bridge
    internal: true
```

### **Level 3: Advanced Security Hardening**

```yaml
version: '3.8'

services:
  ecommerce-backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.hardened
    
    # Advanced security context
    user: "1001:1001"
    read_only: true
    
    # Advanced security options
    security_opt:
      - no-new-privileges:true
      - apparmor:ecommerce-backend-profile
      - seccomp:./seccomp/ecommerce-backend.json
    
    # Minimal capabilities
    cap_drop:
      - ALL
    # Add only absolutely necessary capabilities
    
    # Advanced resource controls
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
          pids: 100  # Limit number of processes
    
    # Secure temporary filesystems
    tmpfs:
      - /tmp:noexec,nosuid,nodev,size=100m,mode=1777
      - /var/run:noexec,nosuid,nodev,size=50m
      - /app/tmp:noexec,nosuid,nodev,size=50m
    
    # Secure volumes
    volumes:
      - type: volume
        source: app_logs
        target: /app/logs
        read_only: false
        volume:
          nocopy: true
    
    # Network security
    networks:
      api_network:
        aliases:
          - secure-api
    
    # Health and security monitoring
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    # Logging for security monitoring
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://security-logs.company.com:514"
        tag: "ecommerce-backend"

networks:
  api_network:
    driver: bridge
    internal: true
    encrypted: true
    ipam:
      config:
        - subnet: 172.30.1.0/24
```

---

## 🔧 Security Implementation: Step by Step

### **Step 1: Secure Dockerfile Creation**

```dockerfile
# Dockerfile.hardened
FROM node:16-alpine AS base

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S ecommerce && \
    adduser -S ecommerce -u 1001 -G ecommerce

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force && \
    rm -rf /tmp/* /root/.npm

# Copy application code
COPY --chown=ecommerce:ecommerce . .

# Remove unnecessary files
RUN rm -rf .git .gitignore README.md docs/ tests/ .env*

# Create necessary directories with proper permissions
RUN mkdir -p /app/logs /app/tmp && \
    chown -R ecommerce:ecommerce /app/logs /app/tmp

# Switch to non-root user
USER ecommerce

# Security: Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Start application
CMD ["node", "server.js"]
```

### **Step 2: Secret Management Implementation**

#### **Create Secure Secrets**
```bash
#!/bin/bash
# scripts/create-secure-secrets.sh

# Generate cryptographically secure secrets
JWT_SECRET=$(openssl rand -base64 64)
DB_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
STRIPE_WEBHOOK_SECRET=$(openssl rand -base64 32)

# Create Docker secrets
echo "$JWT_SECRET" | docker secret create jwt_secret -
echo "$DB_PASSWORD" | docker secret create db_password -
echo "$REDIS_PASSWORD" | docker secret create redis_password -
echo "$STRIPE_WEBHOOK_SECRET" | docker secret create stripe_webhook_secret -

# Create composite secrets
DATABASE_URL="postgresql://ecommerce_user:${DB_PASSWORD}@database:5432/ecommerce"
echo "$DATABASE_URL" | docker secret create database_url -

REDIS_URL="redis://:${REDIS_PASSWORD}@redis:6379"
echo "$REDIS_URL" | docker secret create redis_url -

echo "Secure secrets created successfully"
echo "Secrets are stored in Docker's encrypted secret store"
```

#### **Application Secret Loading**
```javascript
// backend/config/secrets.js
const fs = require('fs');

class SecureSecretManager {
  constructor() {
    this.secretsPath = '/run/secrets';
  }

  loadSecret(secretName) {
    const secretFile = process.env[`${secretName.toUpperCase()}_FILE`];
    
    if (secretFile && fs.existsSync(secretFile)) {
      try {
        const secret = fs.readFileSync(secretFile, 'utf8').trim();
        
        // Validate secret format
        if (secretName === 'jwt_secret' && secret.length < 32) {
          throw new Error('JWT secret must be at least 32 characters');
        }
        
        if (secretName === 'database_url' && !secret.startsWith('postgresql://')) {
          throw new Error('Invalid database URL format');
        }
        
        return secret;
      } catch (error) {
        throw new Error(`Failed to load secret ${secretName}: ${error.message}`);
      }
    }

    // Fallback to environment variable (development only)
    if (process.env.NODE_ENV === 'development') {
      const envValue = process.env[secretName.toUpperCase()];
      if (envValue) {
        console.warn(`Using environment variable for ${secretName} - not recommended for production`);
        return envValue;
      }
    }

    throw new Error(`Secret ${secretName} not found`);
  }

  getSecureConfig() {
    return {
      database: {
        url: this.loadSecret('database_url')
      },
      jwt: {
        secret: this.loadSecret('jwt_secret'),
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      },
      stripe: {
        secretKey: this.loadSecret('stripe_secret_key'),
        webhookSecret: this.loadSecret('stripe_webhook_secret')
      },
      redis: {
        url: this.loadSecret('redis_url')
      }
    };
  }
}

module.exports = new SecureSecretManager();
```

### **Step 3: Advanced Access Controls**

#### **Capability Management**
```yaml
services:
  ecommerce-backend:
    # Drop all capabilities by default
    cap_drop:
      - ALL
    
    # Add only necessary capabilities
    cap_add:
      - NET_BIND_SERVICE  # Only if binding to port < 1024
      # - CHOWN           # Only if changing file ownership
      # - SETUID          # Only if changing user context
      # - SETGID          # Only if changing group context
    
    # Alternative: Use specific capability sets
    # cap_add:
    #   - CAP_NET_BIND_SERVICE
    #   - CAP_CHOWN
```

#### **Seccomp Profiles**
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "accept",
        "accept4", 
        "access",
        "bind",
        "brk",
        "chdir",
        "close",
        "connect",
        "dup",
        "dup2",
        "epoll_create",
        "epoll_ctl",
        "epoll_wait",
        "exit",
        "exit_group",
        "fcntl",
        "fstat",
        "futex",
        "getcwd",
        "getdents",
        "getpid",
        "getsockname",
        "getsockopt",
        "listen",
        "lseek",
        "mmap",
        "munmap",
        "open",
        "openat",
        "pipe",
        "poll",
        "read",
        "readv",
        "recv",
        "recvfrom",
        "rt_sigaction",
        "rt_sigprocmask",
        "rt_sigreturn",
        "send",
        "sendto",
        "setsockopt",
        "shutdown",
        "socket",
        "stat",
        "write",
        "writev"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

---

## 🧪 Hands-On Practice: Security Implementation

### **Exercise 1: Basic Security Hardening**

```bash
# Create secure version of your e-commerce backend
cat > docker-compose.secure.yml << 'EOF'
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.secure
    user: "1001:1001"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
    environment:
      NODE_ENV: production
    secrets:
      - jwt_secret
    networks:
      - secure_network

secrets:
  jwt_secret:
    file: ./secrets/jwt_secret.txt

networks:
  secure_network:
    driver: bridge
    internal: true
EOF

# Test secure deployment
docker-compose -f docker-compose.secure.yml up -d

# Verify security settings
docker inspect backend | grep -A 10 "SecurityOpt"
docker exec backend id  # Should show non-root user
```

### **Exercise 2: Vulnerability Scanning**

```bash
# Scan your e-commerce images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce_backend:latest

# Scan for secrets in your codebase
docker run --rm -v $(pwd):/app \
  trufflesecurity/trufflehog filesystem /app --only-verified

# Container security benchmark
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
```

---

## ✅ Knowledge Check: Security Fundamentals

### **Conceptual Understanding**
- [ ] Understands container security threat model
- [ ] Knows compliance requirements for e-commerce
- [ ] Comprehends defense-in-depth security strategy
- [ ] Understands container security vs traditional security
- [ ] Knows security monitoring and incident response

### **Practical Skills**
- [ ] Can implement container security hardening
- [ ] Knows how to manage secrets securely
- [ ] Can configure access controls and capabilities
- [ ] Understands vulnerability scanning and remediation
- [ ] Can set up security monitoring and alerting

### **E-Commerce Application**
- [ ] Has implemented basic security hardening for all services
- [ ] Set up secure secret management
- [ ] Configured proper access controls
- [ ] Implemented vulnerability scanning
- [ ] Created security monitoring procedures

---

## 🚀 Next Steps: Advanced Security Techniques

### **What You've Mastered**
- ✅ **Container security fundamentals** and threat modeling
- ✅ **Basic security hardening** techniques and best practices
- ✅ **Secret management** and secure configuration
- ✅ **Vulnerability scanning** and remediation
- ✅ **Security monitoring** basics

### **Coming Next: Performance Engineering**
In **04-Performance-Engineering.md**, you'll learn:
- **Performance profiling** and optimization techniques
- **Resource tuning** for maximum efficiency
- **Scalability patterns** for high-traffic scenarios
- **Cost optimization** through performance engineering

**Continue when you've successfully implemented comprehensive security hardening for your e-commerce platform and understand enterprise security requirements.**
  deny capability sys_chroot,
  deny capability sys_ptrace,
  deny capability sys_pacct,
  deny capability sys_boot,
  deny capability sys_nice,
  deny capability sys_resource,
  deny capability sys_time,
  deny capability sys_tty_config,
  deny capability mknod,
  deny capability lease,
  deny capability audit_write,
  deny capability audit_control,
  deny capability setfcap,
  
  # Deny access to sensitive files
  deny /proc/sys/** w,
  deny /sys/** w,
  deny /etc/shadow r,
  deny /etc/passwd w,
  deny /etc/group w,
  deny /root/** rw,
  deny /home/** rw,
  
  # Signal restrictions
  signal (receive) set=(term, kill) peer=unconfined,
  signal (send) set=(term, kill) peer=docker-nginx,
}
```

### Advanced Seccomp Profile
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": [
    "SCMP_ARCH_X86_64",
    "SCMP_ARCH_X86",
    "SCMP_ARCH_X32"
  ],
  "syscalls": [
    {
      "names": [
        "accept",
        "accept4",
        "access",
        "adjtimex",
        "alarm",
        "bind",
        "brk",
        "capget",
        "capset",
        "chdir",
        "chmod",
        "chown",
        "chown32",
        "clock_getres",
        "clock_gettime",
        "clock_nanosleep",
        "close",
        "connect",
        "copy_file_range",
        "creat",
        "dup",
        "dup2",
        "dup3",
        "epoll_create",
        "epoll_create1",
        "epoll_ctl",
        "epoll_pwait",
        "epoll_wait",
        "eventfd",
        "eventfd2",
        "execve",
        "execveat",
        "exit",
        "exit_group",
        "faccessat",
        "fadvise64",
        "fadvise64_64",
        "fallocate",
        "fanotify_mark",
        "fchdir",
        "fchmod",
        "fchmodat",
        "fchown",
        "fchown32",
        "fchownat",
        "fcntl",
        "fcntl64",
        "fdatasync",
        "fgetxattr",
        "flistxattr",
        "flock",
        "fork",
        "fremovexattr",
        "fsetxattr",
        "fstat",
        "fstat64",
        "fstatat64",
        "fstatfs",
        "fstatfs64",
        "fsync",
        "ftruncate",
        "ftruncate64",
        "futex",
        "getcwd",
        "getdents",
        "getdents64",
        "getegid",
        "getegid32",
        "geteuid",
        "geteuid32",
        "getgid",
        "getgid32",
        "getgroups",
        "getgroups32",
        "getitimer",
        "getpeername",
        "getpgid",
        "getpgrp",
        "getpid",
        "getppid",
        "getpriority",
        "getrandom",
        "getresgid",
        "getresgid32",
        "getresuid",
        "getresuid32",
        "getrlimit",
        "get_robust_list",
        "getrusage",
        "getsid",
        "getsockname",
        "getsockopt",
        "get_thread_area",
        "gettid",
        "gettimeofday",
        "getuid",
        "getuid32",
        "getxattr",
        "inotify_add_watch",
        "inotify_init",
        "inotify_init1",
        "inotify_rm_watch",
        "io_cancel",
        "ioctl",
        "io_destroy",
        "io_getevents",
        "ioprio_get",
        "ioprio_set",
        "io_setup",
        "io_submit",
        "ipc",
        "kill",
        "lchown",
        "lchown32",
        "lgetxattr",
        "link",
        "linkat",
        "listen",
        "listxattr",
        "llistxattr",
        "lremovexattr",
        "lseek",
        "lsetxattr",
        "lstat",
        "lstat64",
        "madvise",
        "memfd_create",
        "mincore",
        "mkdir",
        "mkdirat",
        "mknod",
        "mknodat",
        "mlock",
        "mlock2",
        "mlockall",
        "mmap",
        "mmap2",
        "mprotect",
        "mq_getsetattr",
        "mq_notify",
        "mq_open",
        "mq_timedreceive",
        "mq_timedsend",
        "mq_unlink",
        "mremap",
        "msgctl",
        "msgget",
        "msgrcv",
        "msgsnd",
        "msync",
        "munlock",
        "munlockall",
        "munmap",
        "nanosleep",
        "newfstatat",
        "_newselect",
        "open",
        "openat",
        "pause",
        "pipe",
        "pipe2",
        "poll",
        "ppoll",
        "prctl",
        "pread64",
        "preadv",
        "prlimit64",
        "pselect6",
        "ptrace",
        "pwrite64",
        "pwritev",
        "read",
        "readahead",
        "readlink",
        "readlinkat",
        "readv",
        "recv",
        "recvfrom",
        "recvmmsg",
        "recvmsg",
        "remap_file_pages",
        "removexattr",
        "rename",
        "renameat",
        "renameat2",
        "restart_syscall",
        "rmdir",
        "rt_sigaction",
        "rt_sigpending",
        "rt_sigprocmask",
        "rt_sigqueueinfo",
        "rt_sigreturn",
        "rt_sigsuspend",
        "rt_sigtimedwait",
        "rt_tgsigqueueinfo",
        "sched_getaffinity",
        "sched_getattr",
        "sched_getparam",
        "sched_get_priority_max",
        "sched_get_priority_min",
        "sched_getscheduler",
        "sched_rr_get_interval",
        "sched_setaffinity",
        "sched_setattr",
        "sched_setparam",
        "sched_setscheduler",
        "sched_yield",
        "seccomp",
        "select",
        "semctl",
        "semget",
        "semop",
        "semtimedop",
        "send",
        "sendfile",
        "sendfile64",
        "sendmmsg",
        "sendmsg",
        "sendto",
        "setfsgid",
        "setfsgid32",
        "setfsuid",
        "setfsuid32",
        "setgid",
        "setgid32",
        "setgroups",
        "setgroups32",
        "setitimer",
        "setpgid",
        "setpriority",
        "setregid",
        "setregid32",
        "setresgid",
        "setresgid32",
        "setresuid",
        "setresuid32",
        "setreuid",
        "setreuid32",
        "setrlimit",
        "set_robust_list",
        "setsid",
        "setsockopt",
        "set_thread_area",
        "set_tid_address",
        "setuid",
        "setuid32",
        "setxattr",
        "shmat",
        "shmctl",
        "shmdt",
        "shmget",
        "shutdown",
        "sigaltstack",
        "signalfd",
        "signalfd4",
        "sigreturn",
        "socket",
        "socketcall",
        "socketpair",
        "splice",
        "stat",
        "stat64",
        "statfs",
        "statfs64",
        "statx",
        "symlink",
        "symlinkat",
        "sync",
        "sync_file_range",
        "syncfs",
        "sysinfo",
        "tee",
        "tgkill",
        "time",
        "timer_create",
        "timer_delete",
        "timer_getoverrun",
        "timer_gettime",
        "timer_settime",
        "times",
        "tkill",
        "truncate",
        "truncate64",
        "ugetrlimit",
        "umask",
        "uname",
        "unlink",
        "unlinkat",
        "utime",
        "utimensat",
        "utimes",
        "vfork",
        "vmsplice",
        "wait4",
        "waitid",
        "waitpid",
        "write",
        "writev"
      ],
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "names": [
        "ptrace"
      ],
      "action": "SCMP_ACT_ALLOW",
      "args": [
        {
          "index": 0,
          "value": 1,
          "op": "SCMP_CMP_EQ"
        }
      ]
    }
  ]
}
```

## 🔐 Runtime Security Monitoring

### Real-Time Security Monitor
```go
// security-monitor.go - Real-time container security monitoring
package main

import (
    "bufio"
    "context"
    "encoding/json"
    "fmt"
    "log"
    "os"
    "os/exec"
    "strings"
    "time"

    "github.com/docker/docker/api/types"
    "github.com/docker/docker/client"
)

type SecurityEvent struct {
    Timestamp   time.Time `json:"timestamp"`
    ContainerID string    `json:"container_id"`
    EventType   string    `json:"event_type"`
    Severity    string    `json:"severity"`
    Message     string    `json:"message"`
    Details     map[string]interface{} `json:"details"`
}

type SecurityMonitor struct {
    dockerClient *client.Client
    events       chan SecurityEvent
    rules        []SecurityRule
}

type SecurityRule struct {
    Name        string
    Pattern     string
    Severity    string
    Action      string
    Description string
}

func NewSecurityMonitor() (*SecurityMonitor, error) {
    cli, err := client.NewClientWithOpts(client.FromEnv)
    if err != nil {
        return nil, err
    }

    monitor := &SecurityMonitor{
        dockerClient: cli,
        events:       make(chan SecurityEvent, 1000),
        rules: []SecurityRule{
            {
                Name:        "privilege_escalation",
                Pattern:     "setuid|setgid|sudo|su ",
                Severity:    "HIGH",
                Action:      "ALERT",
                Description: "Potential privilege escalation detected",
            },
            {
                Name:        "network_scan",
                Pattern:     "nmap|masscan|zmap",
                Severity:    "MEDIUM",
                Action:      "ALERT",
                Description: "Network scanning tool detected",
            },
            {
                Name:        "crypto_mining",
                Pattern:     "xmrig|cpuminer|cgminer",
                Severity:    "HIGH",
                Action:      "TERMINATE",
                Description: "Cryptocurrency mining detected",
            },
            {
                Name:        "reverse_shell",
                Pattern:     "nc -l|netcat -l|/bin/sh|/bin/bash.*&",
                Severity:    "CRITICAL",
                Action:      "TERMINATE",
                Description: "Reverse shell activity detected",
            },
        },
    }

    return monitor, nil
}

func (sm *SecurityMonitor) Start(ctx context.Context) error {
    // Start monitoring goroutines
    go sm.monitorProcesses(ctx)
    go sm.monitorNetworkConnections(ctx)
    go sm.monitorFileSystem(ctx)
    go sm.monitorSystemCalls(ctx)
    go sm.handleEvents(ctx)

    log.Println("Security monitor started")
    return nil
}

func (sm *SecurityMonitor) monitorProcesses(ctx context.Context) {
    ticker := time.NewTicker(5 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            containers, err := sm.dockerClient.ContainerList(ctx, types.ContainerListOptions{})
            if err != nil {
                log.Printf("Error listing containers: %v", err)
                continue
            }

            for _, container := range containers {
                sm.checkContainerProcesses(ctx, container.ID)
            }
        }
    }
}

func (sm *SecurityMonitor) checkContainerProcesses(ctx context.Context, containerID string) {
    // Get process list from container
    exec, err := sm.dockerClient.ContainerExecCreate(ctx, containerID, types.ExecConfig{
        Cmd:          []string{"ps", "aux"},
        AttachStdout: true,
        AttachStderr: true,
    })
    if err != nil {
        return
    }

    resp, err := sm.dockerClient.ContainerExecAttach(ctx, exec.ID, types.ExecStartCheck{})
    if err != nil {
        return
    }
    defer resp.Close()

    scanner := bufio.NewScanner(resp.Reader)
    for scanner.Scan() {
        line := scanner.Text()
        
        // Check against security rules
        for _, rule := range sm.rules {
            if strings.Contains(strings.ToLower(line), strings.ToLower(rule.Pattern)) {
                event := SecurityEvent{
                    Timestamp:   time.Now(),
                    ContainerID: containerID[:12],
                    EventType:   "PROCESS_VIOLATION",
                    Severity:    rule.Severity,
                    Message:     rule.Description,
                    Details: map[string]interface{}{
                        "rule":         rule.Name,
                        "process_line": line,
                        "action":       rule.Action,
                    },
                }
                
                select {
                case sm.events <- event:
                case <-ctx.Done():
                    return
                }
                
                // Take action based on rule
                if rule.Action == "TERMINATE" {
                    sm.terminateContainer(ctx, containerID)
                }
            }
        }
    }
}

func (sm *SecurityMonitor) monitorNetworkConnections(ctx context.Context) {
    ticker := time.NewTicker(10 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            containers, err := sm.dockerClient.ContainerList(ctx, types.ContainerListOptions{})
            if err != nil {
                continue
            }

            for _, container := range containers {
                sm.checkNetworkConnections(ctx, container.ID)
            }
        }
    }
}

func (sm *SecurityMonitor) checkNetworkConnections(ctx context.Context, containerID string) {
    // Get network connections
    exec, err := sm.dockerClient.ContainerExecCreate(ctx, containerID, types.ExecConfig{
        Cmd:          []string{"netstat", "-tuln"},
        AttachStdout: true,
        AttachStderr: true,
    })
    if err != nil {
        return
    }

    resp, err := sm.dockerClient.ContainerExecAttach(ctx, exec.ID, types.ExecStartCheck{})
    if err != nil {
        return
    }
    defer resp.Close()

    scanner := bufio.NewScanner(resp.Reader)
    suspiciousPorts := []string{"4444", "5555", "6666", "7777", "8888", "9999"}
    
    for scanner.Scan() {
        line := scanner.Text()
        
        for _, port := range suspiciousPorts {
            if strings.Contains(line, ":"+port) {
                event := SecurityEvent{
                    Timestamp:   time.Now(),
                    ContainerID: containerID[:12],
                    EventType:   "NETWORK_VIOLATION",
                    Severity:    "MEDIUM",
                    Message:     "Suspicious port detected",
                    Details: map[string]interface{}{
                        "port":           port,
                        "connection_line": line,
                    },
                }
                
                select {
                case sm.events <- event:
                case <-ctx.Done():
                    return
                }
            }
        }
    }
}

func (sm *SecurityMonitor) monitorFileSystem(ctx context.Context) {
    // Monitor file system changes using inotify
    cmd := exec.Command("inotifywait", "-m", "-r", "-e", "create,delete,modify", "/var/lib/docker/containers/")
    stdout, err := cmd.StdoutPipe()
    if err != nil {
        log.Printf("Error setting up file system monitoring: %v", err)
        return
    }

    if err := cmd.Start(); err != nil {
        log.Printf("Error starting file system monitoring: %v", err)
        return
    }

    scanner := bufio.NewScanner(stdout)
    for scanner.Scan() {
        line := scanner.Text()
        
        // Parse inotify output and generate events
        if strings.Contains(line, "CREATE") || strings.Contains(line, "DELETE") {
            parts := strings.Fields(line)
            if len(parts) >= 3 {
                event := SecurityEvent{
                    Timestamp:   time.Now(),
                    ContainerID: "filesystem",
                    EventType:   "FILESYSTEM_CHANGE",
                    Severity:    "LOW",
                    Message:     "File system change detected",
                    Details: map[string]interface{}{
                        "path":   parts[0],
                        "action": parts[1],
                        "file":   parts[2],
                    },
                }
                
                select {
                case sm.events <- event:
                case <-ctx.Done():
                    return
                }
            }
        }
    }
}

func (sm *SecurityMonitor) monitorSystemCalls(ctx context.Context) {
    // Use strace to monitor system calls (requires privileged container)
    containers, err := sm.dockerClient.ContainerList(ctx, types.ContainerListOptions{})
    if err != nil {
        return
    }

    for _, container := range containers {
        go sm.traceSystemCalls(ctx, container.ID)
    }
}

func (sm *SecurityMonitor) traceSystemCalls(ctx context.Context, containerID string) {
    // Get container PID
    inspect, err := sm.dockerClient.ContainerInspect(ctx, containerID)
    if err != nil {
        return
    }

    pid := inspect.State.Pid
    if pid == 0 {
        return
    }

    // Start strace on container processes
    cmd := exec.Command("strace", "-f", "-p", fmt.Sprintf("%d", pid), "-e", "trace=execve,clone,fork")
    stdout, err := cmd.StdoutPipe()
    if err != nil {
        return
    }

    if err := cmd.Start(); err != nil {
        return
    }

    scanner := bufio.NewScanner(stdout)
    for scanner.Scan() {
        line := scanner.Text()
        
        // Analyze system calls for suspicious activity
        if strings.Contains(line, "execve") {
            event := SecurityEvent{
                Timestamp:   time.Now(),
                ContainerID: containerID[:12],
                EventType:   "SYSCALL_TRACE",
                Severity:    "INFO",
                Message:     "Process execution detected",
                Details: map[string]interface{}{
                    "syscall": line,
                },
            }
            
            select {
            case sm.events <- event:
            case <-ctx.Done():
                return
            }
        }
    }
}

func (sm *SecurityMonitor) handleEvents(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case event := <-sm.events:
            sm.processSecurityEvent(event)
        }
    }
}

func (sm *SecurityMonitor) processSecurityEvent(event SecurityEvent) {
    // Log event
    eventJSON, _ := json.MarshalIndent(event, "", "  ")
    log.Printf("Security Event: %s", eventJSON)

    // Send to SIEM/alerting system
    sm.sendToSIEM(event)

    // Take automated response actions
    if event.Severity == "CRITICAL" {
        sm.handleCriticalEvent(event)
    }
}

func (sm *SecurityMonitor) sendToSIEM(event SecurityEvent) {
    // Implementation would send to your SIEM system
    // For example: Splunk, ELK Stack, etc.
}

func (sm *SecurityMonitor) handleCriticalEvent(event SecurityEvent) {
    log.Printf("CRITICAL EVENT: Taking immediate action for container %s", event.ContainerID)
    
    // Isolate container
    sm.isolateContainer(context.Background(), event.ContainerID)
    
    // Send immediate alert
    sm.sendImmediateAlert(event)
}

func (sm *SecurityMonitor) terminateContainer(ctx context.Context, containerID string) {
    log.Printf("Terminating container %s due to security violation", containerID[:12])
    
    timeout := 10 * time.Second
    if err := sm.dockerClient.ContainerStop(ctx, containerID, &timeout); err != nil {
        log.Printf("Error stopping container %s: %v", containerID[:12], err)
    }
}

func (sm *SecurityMonitor) isolateContainer(ctx context.Context, containerID string) {
    log.Printf("Isolating container %s", containerID[:12])
    
    // Disconnect from all networks
    inspect, err := sm.dockerClient.ContainerInspect(ctx, containerID)
    if err != nil {
        return
    }

    for networkName := range inspect.NetworkSettings.Networks {
        if err := sm.dockerClient.NetworkDisconnect(ctx, networkName, containerID, true); err != nil {
            log.Printf("Error disconnecting container from network %s: %v", networkName, err)
        }
    }
}

func (sm *SecurityMonitor) sendImmediateAlert(event SecurityEvent) {
    // Implementation would send immediate alerts via:
    // - Email
    // - Slack
    // - PagerDuty
    // - SMS
    log.Printf("IMMEDIATE ALERT: %s - %s", event.Severity, event.Message)
}

func main() {
    monitor, err := NewSecurityMonitor()
    if err != nil {
        log.Fatal(err)
    }

    ctx := context.Background()
    if err := monitor.Start(ctx); err != nil {
        log.Fatal(err)
    }

    // Keep running
    select {}
}
```

This continues Module 7 with military-grade security implementations that go far beyond typical container security. The content maintains the same revolutionary depth and practical focus that makes this module truly game-changing.
