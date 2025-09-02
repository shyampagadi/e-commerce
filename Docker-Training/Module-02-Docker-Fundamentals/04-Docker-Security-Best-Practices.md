# 🔒 Docker Security & Best Practices: Complete Expert Guide

## 🎯 Learning Objectives
- Master Docker security fundamentals and threat models
- Implement container security best practices
- Learn image scanning and vulnerability management
- Configure secure Docker daemon and runtime settings

---

## 🛡️ Docker Security Fundamentals

### Container Security Model
```
Host Operating System
├── Docker Daemon (Root Privileges)
├── Container 1 (Isolated Process)
├── Container 2 (Isolated Process)
└── Container N (Isolated Process)
```

### Security Boundaries
- **Namespace Isolation**: Process, network, filesystem isolation
- **Control Groups (cgroups)**: Resource limiting and monitoring
- **Capabilities**: Fine-grained privilege control
- **Seccomp**: System call filtering
- **AppArmor/SELinux**: Mandatory access control

---

## 👤 User Security and Non-Root Containers

### The Root Problem
```dockerfile
# DANGEROUS: Running as root
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y nginx
CMD ["nginx", "-g", "daemon off;"]
```

**Security Issues:**
- Container process runs as root (UID 0)
- If container is compromised, attacker has root privileges
- Can potentially escape to host system
- Violates principle of least privilege

### Creating Non-Root Users
```dockerfile
# SECURE: Running as non-root user
FROM ubuntu:20.04

# Create application user
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Install packages as root
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

# Create app directory and set ownership
RUN mkdir -p /app && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Application runs as appuser
CMD ["nginx", "-g", "daemon off;"]
```

### Alpine Linux Non-Root Pattern
```dockerfile
FROM alpine:3.17

# Create user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Install packages
RUN apk add --no-cache nginx

# Set up directories with proper ownership
RUN mkdir -p /app /var/log/nginx /var/lib/nginx && \
    chown -R appuser:appgroup /app /var/log/nginx /var/lib/nginx

USER appuser
WORKDIR /app

CMD ["nginx", "-g", "daemon off;"]
```

### Testing User Security
```bash
# Check user inside container
docker run --rm alpine:3.17 id
# Expected: uid=0(root) gid=0(root) groups=0(root)

docker run --rm --user 1000:1000 alpine:3.17 id
# Expected: uid=1000 gid=1000 groups=1000

# Test file permissions
docker run --rm --user 1000:1000 -v $(pwd):/data alpine:3.17 touch /data/test.txt
ls -la test.txt
# Expected: -rw-r--r-- 1 1000 1000 0 Jan 15 10:30 test.txt
```

---

## 🔐 Image Security and Scanning

### Base Image Security
```dockerfile
# INSECURE: Using latest tag
FROM ubuntu:latest

# BETTER: Using specific version
FROM ubuntu:20.04

# BEST: Using minimal base image with specific version
FROM alpine:3.17.3

# PRODUCTION: Using distroless for runtime
FROM gcr.io/distroless/java:11
```

### Multi-Stage Build Security
```dockerfile
# Build stage - can use full-featured image
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage - minimal runtime image
FROM alpine:3.17
RUN apk add --no-cache nodejs npm
RUN addgroup -g 1001 -S nodejs && \
    adduser -u 1001 -S nodejs -G nodejs

WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

USER nodejs
CMD ["node", "server.js"]
```

### Image Scanning with Docker Scout
```bash
# Enable Docker Scout (if available)
docker scout --help

# Scan local image
docker scout cves nginx:alpine

# Scan with detailed output
docker scout cves --format json nginx:alpine > scan-results.json

# Compare images
docker scout compare nginx:alpine nginx:latest
```

### Image Scanning with Trivy
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan image for vulnerabilities
trivy image nginx:alpine

# Scan with specific severity
trivy image --severity HIGH,CRITICAL nginx:alpine

# Output to JSON
trivy image --format json --output results.json nginx:alpine

# Scan Dockerfile
trivy config Dockerfile
```

**Expected Trivy Output:**
```
nginx:alpine (alpine 3.17.3)
=============================
Total: 2 (HIGH: 1, CRITICAL: 1)

┌─────────────────┬────────────────┬──────────┬───────────────────┬───────────────┬─────────────────────────────────────┐
│     Library     │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │                Title                │
├─────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────┤
│ libssl3         │ CVE-2023-0464  │ HIGH     │ 3.0.8-r3          │ 3.0.8-r4      │ openssl: Denial of service by       │
│                 │                │          │                   │               │ excessive resource usage in...      │
├─────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────┤
│ libcrypto3      │ CVE-2023-0465  │ CRITICAL │ 3.0.8-r3          │ 3.0.8-r4      │ openssl: Invalid certificate        │
│                 │                │          │                   │               │ policies in leaf certificates...    │
└─────────────────┴────────────────┴──────────┴───────────────────┴───────────────┴─────────────────────────────────────┘
```

### Automated Security Scanning Script
```bash
#!/bin/bash
# docker-security-scan.sh

IMAGE_NAME=${1:-"nginx:alpine"}
SEVERITY_THRESHOLD=${2:-"HIGH"}
OUTPUT_DIR="security-scans/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "=== Docker Security Scan ==="
echo "Image: $IMAGE_NAME"
echo "Severity Threshold: $SEVERITY_THRESHOLD"
echo "Output Directory: $OUTPUT_DIR"
echo

# Trivy scan
if command -v trivy >/dev/null 2>&1; then
    echo "Running Trivy scan..."
    trivy image --format json --output "$OUTPUT_DIR/trivy-scan.json" "$IMAGE_NAME"
    trivy image --severity "$SEVERITY_THRESHOLD" "$IMAGE_NAME" | tee "$OUTPUT_DIR/trivy-summary.txt"
else
    echo "Trivy not installed. Install with:"
    echo "curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
fi

# Docker Scout scan (if available)
if docker scout --help >/dev/null 2>&1; then
    echo "Running Docker Scout scan..."
    docker scout cves --format json "$IMAGE_NAME" > "$OUTPUT_DIR/scout-scan.json"
    docker scout cves "$IMAGE_NAME" | tee "$OUTPUT_DIR/scout-summary.txt"
fi

# Generate security report
cat > "$OUTPUT_DIR/security-report.md" << EOF
# Security Scan Report

**Image:** $IMAGE_NAME  
**Scan Date:** $(date)  
**Severity Threshold:** $SEVERITY_THRESHOLD

## Summary

$(if [ -f "$OUTPUT_DIR/trivy-summary.txt" ]; then
    TOTAL_VULNS=$(grep "Total:" "$OUTPUT_DIR/trivy-summary.txt" | head -1)
    echo "**Trivy Results:** $TOTAL_VULNS"
fi)

## Recommendations

1. Update base image to latest patched version
2. Use minimal base images (Alpine, Distroless)
3. Implement multi-stage builds
4. Run containers as non-root users
5. Regular security scanning in CI/CD pipeline

## Files Generated

- trivy-scan.json: Detailed vulnerability data
- trivy-summary.txt: Human-readable summary
- scout-scan.json: Docker Scout results (if available)
- security-report.md: This report
EOF

echo "Security scan completed. Results in: $OUTPUT_DIR"
```

---

## 🔧 Docker Daemon Security

### Secure Daemon Configuration
```bash
# Create secure daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp.json",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# Restart Docker daemon
sudo systemctl restart docker
```

### TLS Configuration for Remote Access
```bash
# Generate CA private key
openssl genrsa -aes256 -out ca-key.pem 4096

# Generate CA certificate
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem

# Generate server private key
openssl genrsa -out server-key.pem 4096

# Generate server certificate signing request
openssl req -subj "/CN=docker-host" -sha256 -new -key server-key.pem -out server.csr

# Generate server certificate
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -out server-cert.pem -CAcreateserial

# Generate client private key
openssl genrsa -out key.pem 4096

# Generate client certificate signing request
openssl req -subj '/CN=client' -new -key key.pem -out client.csr

# Generate client certificate
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -out cert.pem -CAcreateserial

# Set proper permissions
chmod 400 ca-key.pem key.pem server-key.pem
chmod 444 ca.pem server-cert.pem cert.pem

# Configure Docker daemon for TLS
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"],
  "tls": true,
  "tlscert": "/etc/docker/server-cert.pem",
  "tlskey": "/etc/docker/server-key.pem",
  "tlsverify": true,
  "tlscacert": "/etc/docker/ca.pem"
}
EOF
```

---

## 🛡️ Runtime Security Controls

### Linux Capabilities
```bash
# Run container with dropped capabilities
docker run --rm --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx:alpine

# Check container capabilities
docker run --rm alpine:3.17 cat /proc/1/status | grep Cap

# Run with no new privileges
docker run --rm --security-opt=no-new-privileges alpine:3.17 id
```

### Seccomp Profiles
```bash
# Run with default seccomp profile
docker run --rm alpine:3.17 uname -a

# Run without seccomp (less secure)
docker run --rm --security-opt seccomp=unconfined alpine:3.17 uname -a

# Custom seccomp profile
docker run --rm --security-opt seccomp=./custom-seccomp.json alpine:3.17
```

### AppArmor/SELinux Integration
```bash
# Check AppArmor status
sudo apparmor_status

# Run with AppArmor profile
docker run --rm --security-opt apparmor=docker-default alpine:3.17

# Check SELinux status
sestatus

# Run with SELinux context
docker run --rm --security-opt label=level:s0:c100,c200 alpine:3.17
```

### Read-Only Root Filesystem
```bash
# Run container with read-only root filesystem
docker run --rm --read-only alpine:3.17 touch /test.txt
# This should fail

# Read-only with tmpfs for writable areas
docker run --rm --read-only --tmpfs /tmp alpine:3.17 touch /tmp/test.txt
# This should succeed
```

---

## 🔍 Security Monitoring and Auditing

### Container Security Monitoring Script
```bash
#!/bin/bash
# docker-security-monitor.sh

LOG_FILE="/var/log/docker-security.log"
ALERT_THRESHOLD=5

log_security_event() {
    echo "$(date): SECURITY: $1" | tee -a "$LOG_FILE"
}

# Monitor privileged containers
check_privileged_containers() {
    PRIVILEGED=$(docker ps --filter "label=privileged=true" -q | wc -l)
    if [ $PRIVILEGED -gt 0 ]; then
        log_security_event "WARNING: $PRIVILEGED privileged containers running"
    fi
}

# Monitor root containers
check_root_containers() {
    docker ps --format "table {{.Names}}\t{{.Image}}" | tail -n +2 | while read name image; do
        USER_ID=$(docker exec "$name" id -u 2>/dev/null || echo "unknown")
        if [ "$USER_ID" = "0" ]; then
            log_security_event "WARNING: Container $name running as root"
        fi
    done
}

# Monitor exposed ports
check_exposed_ports() {
    EXPOSED=$(docker ps --format "table {{.Names}}\t{{.Ports}}" | grep "0.0.0.0" | wc -l)
    if [ $EXPOSED -gt $ALERT_THRESHOLD ]; then
        log_security_event "WARNING: $EXPOSED containers with exposed ports"
    fi
}

# Monitor volume mounts
check_sensitive_mounts() {
    docker ps --format "table {{.Names}}\t{{.Mounts}}" | while read name mounts; do
        if echo "$mounts" | grep -q "/etc\|/var/run/docker.sock\|/proc\|/sys"; then
            log_security_event "WARNING: Container $name has sensitive volume mounts"
        fi
    done
}

# Run all checks
echo "Running Docker security checks..."
check_privileged_containers
check_root_containers
check_exposed_ports
check_sensitive_mounts

echo "Security check completed. Log: $LOG_FILE"
```

### Docker Bench Security
```bash
# Install Docker Bench Security
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security

# Run security benchmark
sudo ./docker-bench-security.sh

# Run with specific tests
sudo ./docker-bench-security.sh -c container_images,container_runtime

# Generate JSON report
sudo ./docker-bench-security.sh -l /tmp/docker-bench.log -j
```

---

## 🚀 Next Steps

You now have comprehensive Docker security knowledge:

- ✅ **User Security**: Non-root containers and privilege management
- ✅ **Image Security**: Vulnerability scanning and secure base images
- ✅ **Daemon Security**: Secure configuration and TLS setup
- ✅ **Runtime Security**: Capabilities, seccomp, and access controls
- ✅ **Security Monitoring**: Automated security auditing and alerting

**Ready for Part 5: Docker Performance Optimization** where you'll learn resource management, performance tuning, and monitoring techniques!
