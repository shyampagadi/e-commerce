# 🔧 Docker System Management: Complete Expert Guide

## 🎯 Learning Objectives
- Master Docker system commands and resource management
- Understand Docker storage drivers and system configuration
- Learn comprehensive cleanup and maintenance procedures
- Implement monitoring and troubleshooting techniques

---

## 📊 docker system - System Management Commands

### Syntax Overview
```bash
docker system COMMAND
```

### Available System Commands
```bash
df          Show docker filesystem usage
events      Get real time events from the server
info        Display system-wide information
prune       Remove unused data
```

---

## 💾 docker system df - Storage Usage Analysis

### Syntax
```bash
docker system df [OPTIONS]
```

### All Available Options
```bash
-v, --verbose    Show detailed information on space usage
```

### Basic Storage Analysis
```bash
# Show Docker storage usage summary
docker system df
```

**Expected Output:**
```
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              15                  5                   2.1GB               1.8GB (85%)
Containers          8                   2                   45MB                32MB (71%)
Local Volumes       4                   2                   1.2GB               800MB (66%)
Build Cache         25                  0                   1.5GB               1.5GB (100%)
```

**Column Explanations:**
- **TYPE**: Resource type (Images, Containers, Volumes, Build Cache)
- **TOTAL**: Total number of items
- **ACTIVE**: Items currently in use
- **SIZE**: Total disk space used
- **RECLAIMABLE**: Space that can be freed by cleanup

### Detailed Storage Analysis
```bash
# Show verbose storage information
docker system df -v
```

**Expected Output:**
```
Images space usage:

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE                SHARED SIZE         UNIQUE SIZE         CONTAINERS
nginx               alpine              bef258acf10d        2 weeks ago         23.4MB              5.6MB               17.8MB              2
node                16-alpine           f20c056e1d8b        3 weeks ago         110MB               5.6MB               104.4MB             1
postgres            13                  2f3c6a7c8b9d        1 month ago         314MB               0B                  314MB               1
<none>              <none>              abc123def456        2 months ago        150MB               0B                  150MB               0

Containers space usage:

CONTAINER ID        IMAGE               COMMAND                  LOCAL VOLUMES       SIZE                CREATED             STATUS
a1b2c3d4e5f6        nginx:alpine        "/docker-entrypoint.…"   1                   2MB                 2 hours ago         Up 2 hours
g7h8i9j0k1l2        node:16-alpine      "docker-entrypoint.s…"   0                   15MB                3 hours ago         Exited (0) 1 hour ago

Local Volumes space usage:

VOLUME NAME                                                        LINKS               SIZE
postgres-data                                                      1                   500MB
redis-data                                                         1                   50MB
app-logs                                                          0                   200MB
temp-volume                                                       0                   450MB

Build Cache usage: 1.5GB

CACHE ID            CACHE TYPE          SIZE                CREATED             LAST USED           USAGE COUNT         SHARED
abc123def456        regular             500MB               2 hours ago         2 hours ago         5                   false
def456ghi789        regular             300MB               1 day ago           1 day ago           2                   true
```

### Storage Analysis Script
```bash
#!/bin/bash
# docker-storage-analysis.sh

echo "=== Docker Storage Analysis ==="
echo "Date: $(date)"
echo

# Basic storage overview
echo "=== Storage Overview ==="
docker system df
echo

# Detailed breakdown
echo "=== Detailed Storage Breakdown ==="
docker system df -v
echo

# Calculate percentages
echo "=== Storage Utilization ==="
TOTAL_SIZE=$(docker system df --format "table {{.Size}}" | tail -n +2 | sed 's/GB\|MB\|KB//g' | awk '{sum += $1} END {print sum}')
echo "Total Docker storage: ${TOTAL_SIZE}GB"

# Check available disk space
echo "=== Host Disk Space ==="
df -h /var/lib/docker
echo

# Recommendations
echo "=== Cleanup Recommendations ==="
RECLAIMABLE=$(docker system df --format "table {{.Reclaimable}}" | tail -n +2 | grep -o '[0-9.]*GB' | sed 's/GB//g' | awk '{sum += $1} END {print sum}')
if (( $(echo "$RECLAIMABLE > 1" | bc -l) )); then
    echo "⚠️  High reclaimable space: ${RECLAIMABLE}GB"
    echo "   Consider running: docker system prune -a"
fi

# Unused volumes
UNUSED_VOLUMES=$(docker volume ls -f dangling=true -q | wc -l)
if [ $UNUSED_VOLUMES -gt 0 ]; then
    echo "⚠️  $UNUSED_VOLUMES unused volumes found"
    echo "   Consider running: docker volume prune"
fi
```

---

## 📡 docker system events - Real-time Event Monitoring

### Syntax
```bash
docker system events [OPTIONS]
```

### All Available Options
```bash
-f, --filter filter   Filter output based on conditions provided
--format string      Format the output using the given Go template
--since string       Show all events created since timestamp
--until string       Stream events until this timestamp
```

### Basic Event Monitoring
```bash
# Monitor all Docker events in real-time
docker system events
```

**Expected Output:**
```
2024-01-15T10:30:45.123456789Z container create a1b2c3d4e5f6 (image=nginx:alpine, name=web-server)
2024-01-15T10:30:45.234567890Z network connect bridge (container=a1b2c3d4e5f6, name=web-server, type=bridge)
2024-01-15T10:30:45.345678901Z container start a1b2c3d4e5f6 (image=nginx:alpine, name=web-server)
2024-01-15T10:30:46.456789012Z container die a1b2c3d4e5f6 (exitCode=0, image=nginx:alpine, name=web-server)
2024-01-15T10:30:46.567890123Z network disconnect bridge (container=a1b2c3d4e5f6, name=web-server, type=bridge)
```

### Filtered Event Monitoring
```bash
# Monitor only container events
docker system events --filter type=container

# Monitor events for specific container
docker system events --filter container=web-server

# Monitor events for specific image
docker system events --filter image=nginx:alpine

# Monitor events with multiple filters
docker system events --filter type=container --filter event=start
```

**Event Types:**
- **container**: Container lifecycle events
- **image**: Image pull, push, delete events
- **volume**: Volume create, mount, unmount events
- **network**: Network create, connect, disconnect events
- **daemon**: Docker daemon events

### Historical Event Analysis
```bash
# Show events from last hour
docker system events --since 1h

# Show events from specific time
docker system events --since 2024-01-15T10:00:00

# Show events in time range
docker system events --since 2024-01-15T10:00:00 --until 2024-01-15T11:00:00

# Format events as JSON
docker system events --format '{{json .}}'
```

**Expected JSON Output:**
```json
{
  "Type": "container",
  "Action": "start",
  "Actor": {
    "ID": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2",
    "Attributes": {
      "image": "nginx:alpine",
      "name": "web-server"
    }
  },
  "time": 1705315845,
  "timeNano": 1705315845123456789
}
```

### Event Monitoring Script
```bash
#!/bin/bash
# docker-event-monitor.sh

LOG_FILE="/var/log/docker-events.log"
ALERT_THRESHOLD=10

# Function to log events
log_event() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Monitor critical events
docker system events --filter type=container --filter event=die --format '{{.Actor.Attributes.name}} exited with code {{.Actor.Attributes.exitCode}}' | while read event; do
    log_event "CONTAINER_EXIT: $event"
    
    # Alert on non-zero exit codes
    if echo "$event" | grep -v "exited with code 0"; then
        log_event "ALERT: Container crashed - $event"
        # Send notification (email, Slack, etc.)
    fi
done &

# Monitor image events
docker system events --filter type=image --format '{{.Action}}: {{.Actor.Attributes.name}}' | while read event; do
    log_event "IMAGE_EVENT: $event"
done &

echo "Event monitoring started. Logs: $LOG_FILE"
wait
```

---

## ℹ️ docker system info - System Information

### Syntax
```bash
docker system info [OPTIONS]
```

### All Available Options
```bash
-f, --format string   Format the output using the given Go template
```

### Complete System Information
```bash
# Show comprehensive Docker system information
docker system info
```

**Expected Output (Comprehensive):**
```
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc., v0.11.2)
  compose: Docker Compose (Docker Inc., v2.21.0)
  scan: Docker Scan (Docker Inc., v0.21.0)

Server:
 Containers: 5
  Running: 2
  Paused: 0
  Stopped: 3
 Images: 15
 Server Version: 24.0.6
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Using metacopy: false
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
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 61f9fd88f79f081d64d6fa3bb1a0dc71ec870523
 runc version: v1.1.9-0-gccaecfc
 init version: de40ad0
 Security Options:
  apparmor
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 5.15.0-88-generic
 Operating System: Ubuntu 22.04.3 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 4
 Total Memory: 7.775GiB
 Name: docker-host
 ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
 Product License: Community Engine

WARNING: No swap limit support
```

### Key Information Breakdown

#### Client Information
- **Context**: Current Docker context
- **Debug Mode**: Client debug status
- **Plugins**: Installed Docker plugins

#### Server Information
- **Containers**: Container counts by status
- **Images**: Total number of images
- **Server Version**: Docker Engine version
- **Storage Driver**: How Docker stores data
- **Logging Driver**: Default logging mechanism
- **Cgroup Driver**: Container resource management

#### System Resources
- **CPUs**: Available CPU cores
- **Total Memory**: Available RAM
- **Kernel Version**: Host kernel version
- **Operating System**: Host OS information
- **Architecture**: CPU architecture

### Formatted System Information
```bash
# Extract specific information
docker system info --format '{{.ServerVersion}}'
docker system info --format '{{.Driver}}'
docker system info --format '{{.SystemTime}}'

# Custom format for monitoring
docker system info --format 'Containers: {{.Containers}} | Images: {{.Images}} | Storage: {{.Driver}}'
```

**Expected Formatted Output:**
```
24.0.6
overlay2
2024-01-15T10:30:45.123456789Z
Containers: 5 | Images: 15 | Storage: overlay2
```

### System Health Check Script
```bash
#!/bin/bash
# docker-health-check.sh

echo "=== Docker System Health Check ==="
echo "Timestamp: $(date)"
echo

# Basic system info
echo "=== System Overview ==="
docker system info --format "Docker Version: {{.ServerVersion}}"
docker system info --format "Storage Driver: {{.Driver}}"
docker system info --format "Containers: {{.ContainersRunning}} running, {{.ContainersStopped}} stopped"
docker system info --format "Images: {{.Images}}"
echo

# Resource usage
echo "=== Resource Usage ==="
docker system info --format "CPU Cores: {{.NCPU}}"
docker system info --format "Total Memory: {{.MemTotal}}"
docker system df
echo

# Check for warnings
echo "=== System Warnings ==="
WARNINGS=$(docker system info 2>&1 | grep "WARNING" | wc -l)
if [ $WARNINGS -gt 0 ]; then
    echo "⚠️  $WARNINGS warnings found:"
    docker system info 2>&1 | grep "WARNING"
else
    echo "✅ No system warnings"
fi
echo

# Storage driver health
echo "=== Storage Driver Status ==="
STORAGE_DRIVER=$(docker system info --format '{{.Driver}}')
echo "Current driver: $STORAGE_DRIVER"

if [ "$STORAGE_DRIVER" = "overlay2" ]; then
    echo "✅ Using recommended overlay2 driver"
else
    echo "⚠️  Consider switching to overlay2 for better performance"
fi

# Check Docker daemon status
echo "=== Docker Daemon Status ==="
if docker version > /dev/null 2>&1; then
    echo "✅ Docker daemon is running"
else
    echo "❌ Docker daemon is not responding"
fi
```

---

## 🧹 docker system prune - System Cleanup

### Syntax
```bash
docker system prune [OPTIONS]
```

### All Available Options
```bash
-a, --all             Remove all unused images not just dangling ones
--filter filter       Provide filter values (e.g. 'until=<timestamp>')
-f, --force          Do not prompt for confirmation
--volumes            Prune volumes
```

### Basic System Cleanup
```bash
# Remove unused data (with confirmation)
docker system prune
```

**Expected Output:**
```
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

Are you sure you want to continue? [y/N] y
Deleted Containers:
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4
b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5

Deleted Networks:
bridge_network_1
custom_network_2

Deleted Images:
untagged: temp-image:latest
deleted: sha256:abc123def456789012345678901234567890123456789012345678901234567890

Deleted build cache objects:
cache_object_1
cache_object_2

Total reclaimed space: 2.1GB
```

### Aggressive System Cleanup
```bash
# Remove all unused data including unused images
docker system prune -a --volumes -f
```

**What gets removed with -a --volumes:**
- All stopped containers
- All networks not used by containers
- All images without at least one container associated
- All unused volumes
- All build cache

### Filtered System Cleanup
```bash
# Remove data older than 24 hours
docker system prune --filter "until=24h"

# Remove data older than specific date
docker system prune --filter "until=2024-01-14T00:00:00"

# Remove data with specific labels
docker system prune --filter "label=environment=test"
```

### Comprehensive Cleanup Script
```bash
#!/bin/bash
# docker-cleanup.sh - Comprehensive Docker cleanup script

set -euo pipefail

# Configuration
DRY_RUN=${DRY_RUN:-false}
FORCE=${FORCE:-false}
KEEP_DAYS=${KEEP_DAYS:-7}
LOG_FILE="/var/log/docker-cleanup.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Show current usage
show_usage() {
    log "=== Current Docker Usage ==="
    docker system df
    echo
}

# Cleanup function
cleanup_docker() {
    local dry_run_flag=""
    local force_flag=""
    
    if [ "$DRY_RUN" = "true" ]; then
        log "=== DRY RUN MODE - No changes will be made ==="
        return 0
    fi
    
    if [ "$FORCE" = "true" ]; then
        force_flag="--force"
    fi
    
    log "=== Starting Docker cleanup ==="
    
    # Stop all containers (optional)
    if [ "${STOP_ALL:-false}" = "true" ]; then
        log "Stopping all running containers..."
        docker ps -q | xargs -r docker stop
    fi
    
    # Remove stopped containers
    log "Removing stopped containers..."
    docker container prune $force_flag
    
    # Remove unused networks
    log "Removing unused networks..."
    docker network prune $force_flag
    
    # Remove unused volumes
    log "Removing unused volumes..."
    docker volume prune $force_flag
    
    # Remove unused images
    log "Removing unused images..."
    docker image prune $force_flag
    
    # Remove build cache older than specified days
    log "Removing build cache older than $KEEP_DAYS days..."
    docker builder prune --filter "until=${KEEP_DAYS}d" $force_flag
    
    # Aggressive cleanup if requested
    if [ "${AGGRESSIVE:-false}" = "true" ]; then
        log "Performing aggressive cleanup..."
        docker system prune -a --volumes $force_flag
    fi
    
    log "=== Cleanup completed ==="
}

# Show usage before cleanup
show_usage

# Perform cleanup
cleanup_docker

# Show usage after cleanup
show_usage

# Calculate space reclaimed
SPACE_BEFORE=$(docker system df --format "{{.Size}}" | head -1)
SPACE_AFTER=$(docker system df --format "{{.Size}}" | head -1)
log "Cleanup completed. Check 'docker system df' for current usage."
```

### Scheduled Cleanup with Cron
```bash
# Add to crontab for weekly cleanup
# Run every Sunday at 2 AM
0 2 * * 0 /usr/local/bin/docker-cleanup.sh

# Create the cleanup script
sudo tee /usr/local/bin/docker-cleanup.sh << 'EOF'
#!/bin/bash
# Weekly Docker cleanup
export FORCE=true
export KEEP_DAYS=7
export LOG_FILE="/var/log/docker-weekly-cleanup.log"

echo "$(date): Starting weekly Docker cleanup" >> "$LOG_FILE"
docker system prune -f --filter "until=168h" >> "$LOG_FILE" 2>&1
docker volume prune -f >> "$LOG_FILE" 2>&1
echo "$(date): Weekly cleanup completed" >> "$LOG_FILE"
EOF

sudo chmod +x /usr/local/bin/docker-cleanup.sh
```

---

## 🔍 Advanced System Monitoring

### Resource Monitoring Script
```bash
#!/bin/bash
# docker-resource-monitor.sh

INTERVAL=${1:-5}
DURATION=${2:-60}
OUTPUT_FILE="docker-metrics-$(date +%Y%m%d_%H%M%S).log"

echo "Monitoring Docker resources every ${INTERVAL}s for ${DURATION}s"
echo "Output file: $OUTPUT_FILE"

# Header
echo "timestamp,containers_running,containers_total,images,cpu_usage,memory_usage,disk_usage" > "$OUTPUT_FILE"

END_TIME=$(($(date +%s) + DURATION))

while [ $(date +%s) -lt $END_TIME ]; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Container counts
    CONTAINERS_RUNNING=$(docker ps -q | wc -l)
    CONTAINERS_TOTAL=$(docker ps -aq | wc -l)
    
    # Image count
    IMAGES=$(docker images -q | wc -l)
    
    # System resources
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    DISK_USAGE=$(df /var/lib/docker | awk 'NR==2 {print $5}' | sed 's/%//')
    
    # Log metrics
    echo "$TIMESTAMP,$CONTAINERS_RUNNING,$CONTAINERS_TOTAL,$IMAGES,$CPU_USAGE,$MEMORY_USAGE,$DISK_USAGE" >> "$OUTPUT_FILE"
    
    sleep $INTERVAL
done

echo "Monitoring completed. Results saved to $OUTPUT_FILE"

# Generate summary
echo "=== Monitoring Summary ==="
echo "Average containers running: $(awk -F, 'NR>1 {sum+=$2; count++} END {printf "%.1f", sum/count}' "$OUTPUT_FILE")"
echo "Peak memory usage: $(awk -F, 'NR>1 {if($6>max) max=$6} END {print max"%"}' "$OUTPUT_FILE")"
echo "Peak disk usage: $(awk -F, 'NR>1 {if($7>max) max=$7} END {print max"%"}' "$OUTPUT_FILE")"
```

### Docker Daemon Configuration Analysis
```bash
#!/bin/bash
# docker-config-analysis.sh

echo "=== Docker Daemon Configuration Analysis ==="

# Check daemon configuration file
DAEMON_CONFIG="/etc/docker/daemon.json"
if [ -f "$DAEMON_CONFIG" ]; then
    echo "Daemon configuration file found: $DAEMON_CONFIG"
    echo "Contents:"
    cat "$DAEMON_CONFIG" | jq '.' 2>/dev/null || cat "$DAEMON_CONFIG"
else
    echo "No custom daemon configuration found"
fi
echo

# Check systemd service configuration
SYSTEMD_CONFIG="/lib/systemd/system/docker.service"
if [ -f "$SYSTEMD_CONFIG" ]; then
    echo "Systemd service configuration:"
    grep "ExecStart" "$SYSTEMD_CONFIG"
fi
echo

# Check current runtime configuration
echo "=== Current Runtime Configuration ==="
docker system info --format "Storage Driver: {{.Driver}}"
docker system info --format "Logging Driver: {{.LoggingDriver}}"
docker system info --format "Cgroup Driver: {{.CgroupDriver}}"
docker system info --format "Cgroup Version: {{.CgroupVersion}}"
docker system info --format "Security Options: {{.SecurityOptions}}"
echo

# Check for optimization opportunities
echo "=== Optimization Recommendations ==="

# Check storage driver
STORAGE_DRIVER=$(docker system info --format '{{.Driver}}')
if [ "$STORAGE_DRIVER" != "overlay2" ]; then
    echo "⚠️  Consider switching to overlay2 storage driver for better performance"
fi

# Check logging driver
LOGGING_DRIVER=$(docker system info --format '{{.LoggingDriver}}')
if [ "$LOGGING_DRIVER" = "json-file" ]; then
    echo "💡 Consider configuring log rotation to prevent disk space issues"
fi

# Check for swap limit support
if docker system info 2>&1 | grep -q "No swap limit support"; then
    echo "⚠️  Swap limit support is disabled. Consider enabling for better resource control"
fi
```

---

## 🚀 Next Steps

You now have complete mastery of Docker system management:

- ✅ **docker system df**: Storage usage analysis and monitoring
- ✅ **docker system events**: Real-time event monitoring and logging
- ✅ **docker system info**: Comprehensive system information analysis
- ✅ **docker system prune**: Advanced cleanup and maintenance procedures
- ✅ **System Monitoring**: Resource monitoring and performance analysis
- ✅ **Automation Scripts**: Production-ready system management tools

**Ready for Part 4: Docker Security and Best Practices** where you'll learn container security, image scanning, and production hardening techniques!
