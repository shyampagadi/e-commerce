# 🔍 Container Forensics & Debugging

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** container forensics principles and investigation techniques
- **Master** advanced debugging tools and methodologies
- **Implement** comprehensive troubleshooting workflows for e-commerce applications
- **Analyze** container security incidents and performance issues
- **Deploy** production-ready debugging and monitoring solutions

## 🎯 Real-World Context
E-commerce platforms face complex issues ranging from performance bottlenecks to security incidents. This module teaches you advanced forensics and debugging techniques to quickly identify, analyze, and resolve critical issues in containerized environments.

---

## 📚 Part 1: Container Debugging Fundamentals

### Understanding Container Runtime Environment

**Container Inspection Basics:**
```bash
# Comprehensive container inspection
docker inspect ecommerce-api | jq '.[0] | {
  State: .State,
  Config: .Config,
  NetworkSettings: .NetworkSettings,
  Mounts: .Mounts
}'

# Process information
docker exec ecommerce-api ps aux
docker exec ecommerce-api cat /proc/1/status

# Resource usage
docker stats ecommerce-api --no-stream
docker exec ecommerce-api cat /proc/meminfo
docker exec ecommerce-api cat /proc/loadavg
```

**Container Filesystem Analysis:**
```bash
# Examine container layers
docker history ecommerce/api:latest
docker diff ecommerce-api

# File system usage
docker exec ecommerce-api df -h
docker exec ecommerce-api du -sh /app/*

# Find large files
docker exec ecommerce-api find /app -type f -size +10M -exec ls -lh {} \;
```

### Common Container Issues

**1. Resource Constraints**
- Memory limits causing OOM kills
- CPU throttling affecting performance
- Disk space exhaustion
- Network bandwidth limitations

**2. Application Issues**
- Startup failures and crashes
- Configuration errors
- Dependency problems
- Performance bottlenecks

**3. Security Issues**
- Unauthorized access attempts
- Privilege escalation
- Data exfiltration
- Malware infections

---

## 🔧 Part 2: Advanced Debugging Tools

### System-Level Debugging

**Process and System Analysis:**
```bash
#!/bin/bash
# debug-toolkit.sh - Comprehensive debugging toolkit

# Function to analyze container processes
analyze_processes() {
    local container_name=$1
    echo "🔍 Analyzing processes in $container_name"
    
    # Get container PID
    local container_pid=$(docker inspect -f '{{.State.Pid}}' $container_name)
    
    if [ "$container_pid" = "0" ]; then
        echo "❌ Container not running"
        return 1
    fi
    
    echo "Container PID: $container_pid"
    
    # Process tree
    echo "📊 Process tree:"
    docker exec $container_name ps -ef --forest
    
    # Resource usage per process
    echo "💾 Memory usage by process:"
    docker exec $container_name ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10
    
    # Open files
    echo "📁 Open files:"
    docker exec $container_name lsof | head -20
    
    # Network connections
    echo "🌐 Network connections:"
    docker exec $container_name netstat -tulpn
}

# Function to analyze container performance
analyze_performance() {
    local container_name=$1
    echo "⚡ Performance analysis for $container_name"
    
    # CPU usage over time
    echo "CPU usage (5 samples):"
    for i in {1..5}; do
        docker exec $container_name cat /proc/loadavg
        sleep 1
    done
    
    # Memory analysis
    echo "📊 Memory breakdown:"
    docker exec $container_name cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached)"
    
    # I/O statistics
    echo "💿 I/O statistics:"
    docker exec $container_name cat /proc/diskstats
}

# Function to collect logs
collect_logs() {
    local container_name=$1
    local output_dir=${2:-"/tmp/debug"}
    
    echo "📋 Collecting logs for $container_name"
    mkdir -p "$output_dir"
    
    # Container logs
    docker logs $container_name > "$output_dir/${container_name}_docker.log" 2>&1
    
    # Application logs
    docker exec $container_name find /var/log -name "*.log" -exec cat {} \; > "$output_dir/${container_name}_app.log" 2>/dev/null
    
    # System logs from container
    docker exec $container_name dmesg > "$output_dir/${container_name}_dmesg.log" 2>/dev/null
    
    echo "✅ Logs collected in $output_dir"
}

# Main debugging function
debug_container() {
    local container_name=$1
    
    if [ -z "$container_name" ]; then
        echo "Usage: debug_container <container_name>"
        return 1
    fi
    
    echo "🚀 Starting comprehensive debug of $container_name"
    echo "=================================================="
    
    analyze_processes $container_name
    echo
    analyze_performance $container_name
    echo
    collect_logs $container_name
    
    echo "🎯 Debug analysis completed"
}

# Usage example
# debug_container ecommerce-api
```

### Network Debugging

**Network Troubleshooting Tools:**
```bash
#!/bin/bash
# network-debug.sh - Network debugging for containers

# Function to test network connectivity
test_connectivity() {
    local container_name=$1
    local target=${2:-"google.com"}
    
    echo "🌐 Testing network connectivity from $container_name"
    
    # Basic connectivity
    echo "Ping test:"
    docker exec $container_name ping -c 3 $target
    
    # DNS resolution
    echo "DNS resolution:"
    docker exec $container_name nslookup $target
    
    # Port connectivity
    echo "Port connectivity test:"
    docker exec $container_name nc -zv $target 80
    docker exec $container_name nc -zv $target 443
}

# Function to analyze container networking
analyze_networking() {
    local container_name=$1
    
    echo "🔍 Network analysis for $container_name"
    
    # Network interfaces
    echo "Network interfaces:"
    docker exec $container_name ip addr show
    
    # Routing table
    echo "Routing table:"
    docker exec $container_name ip route show
    
    # Network statistics
    echo "Network statistics:"
    docker exec $container_name cat /proc/net/dev
    
    # Active connections
    echo "Active connections:"
    docker exec $container_name ss -tuln
}

# Function to capture network traffic
capture_traffic() {
    local container_name=$1
    local duration=${2:-30}
    local output_file="/tmp/${container_name}_traffic.pcap"
    
    echo "📡 Capturing network traffic for $container_name ($duration seconds)"
    
    # Get container network namespace
    local container_pid=$(docker inspect -f '{{.State.Pid}}' $container_name)
    
    if [ "$container_pid" != "0" ]; then
        # Capture traffic using tcpdump
        timeout $duration nsenter -t $container_pid -n tcpdump -i any -w $output_file
        echo "✅ Traffic captured to $output_file"
    else
        echo "❌ Container not running"
    fi
}
```

---

## 🏗️ Part 3: E-Commerce Specific Debugging

### Application Performance Debugging

**E-Commerce Performance Analysis:**
```javascript
// performance-debugger.js - E-commerce performance debugging
const express = require('express');
const { performance } = require('perf_hooks');

class PerformanceDebugger {
    constructor() {
        this.metrics = new Map();
        this.slowQueries = [];
        this.errorPatterns = new Map();
    }
    
    // Middleware to track request performance
    trackPerformance() {
        return (req, res, next) => {
            const start = performance.now();
            const originalSend = res.send;
            
            res.send = function(data) {
                const duration = performance.now() - start;
                
                // Log slow requests
                if (duration > 1000) { // > 1 second
                    console.warn(`🐌 Slow request detected:`, {
                        method: req.method,
                        url: req.url,
                        duration: `${duration.toFixed(2)}ms`,
                        userAgent: req.get('User-Agent'),
                        ip: req.ip
                    });
                }
                
                // Track metrics
                const key = `${req.method} ${req.route?.path || req.url}`;
                if (!this.metrics.has(key)) {
                    this.metrics.set(key, { count: 0, totalTime: 0, errors: 0 });
                }
                
                const metric = this.metrics.get(key);
                metric.count++;
                metric.totalTime += duration;
                
                if (res.statusCode >= 400) {
                    metric.errors++;
                }
                
                originalSend.call(this, data);
            }.bind(this);
            
            next();
        };
    }
    
    // Database query debugging
    debugQuery(query, params, duration) {
        if (duration > 500) { // > 500ms
            this.slowQueries.push({
                query,
                params,
                duration,
                timestamp: new Date().toISOString()
            });
            
            console.warn(`🗄️ Slow database query:`, {
                query: query.substring(0, 100) + '...',
                duration: `${duration}ms`,
                timestamp: new Date().toISOString()
            });
        }
    }
    
    // Memory usage monitoring
    monitorMemory() {
        setInterval(() => {
            const usage = process.memoryUsage();
            const usageMB = {
                rss: Math.round(usage.rss / 1024 / 1024),
                heapTotal: Math.round(usage.heapTotal / 1024 / 1024),
                heapUsed: Math.round(usage.heapUsed / 1024 / 1024),
                external: Math.round(usage.external / 1024 / 1024)
            };
            
            // Alert on high memory usage
            if (usageMB.heapUsed > 500) { // > 500MB
                console.warn(`🧠 High memory usage:`, usageMB);
            }
            
            // Force garbage collection if memory is very high
            if (usageMB.heapUsed > 800 && global.gc) {
                console.log('🗑️ Forcing garbage collection');
                global.gc();
            }
        }, 30000); // Check every 30 seconds
    }
    
    // Generate performance report
    generateReport() {
        const report = {
            timestamp: new Date().toISOString(),
            endpoints: {},
            slowQueries: this.slowQueries.slice(-10), // Last 10 slow queries
            memoryUsage: process.memoryUsage()
        };
        
        // Calculate endpoint statistics
        for (const [endpoint, metric] of this.metrics) {
            report.endpoints[endpoint] = {
                requests: metric.count,
                averageTime: metric.totalTime / metric.count,
                errorRate: (metric.errors / metric.count) * 100
            };
        }
        
        return report;
    }
}

module.exports = PerformanceDebugger;
```

### Database Connection Debugging

**Database Performance Analysis:**
```bash
#!/bin/bash
# db-debug.sh - Database debugging for e-commerce

# Function to analyze database performance
analyze_database() {
    local container_name="ecommerce-database"
    
    echo "🗄️ Database Performance Analysis"
    echo "================================"
    
    # Connection count
    echo "Active connections:"
    docker exec $container_name psql -U postgres -d ecommerce -c "
        SELECT count(*) as active_connections 
        FROM pg_stat_activity 
        WHERE state = 'active';"
    
    # Slow queries
    echo "Slow queries (>1 second):"
    docker exec $container_name psql -U postgres -d ecommerce -c "
        SELECT query, mean_exec_time, calls 
        FROM pg_stat_statements 
        WHERE mean_exec_time > 1000 
        ORDER BY mean_exec_time DESC 
        LIMIT 10;"
    
    # Lock analysis
    echo "Current locks:"
    docker exec $container_name psql -U postgres -d ecommerce -c "
        SELECT mode, locktype, database, relation::regclass, page, tuple, pid 
        FROM pg_locks 
        WHERE NOT granted;"
    
    # Cache hit ratio
    echo "Cache hit ratio:"
    docker exec $container_name psql -U postgres -d ecommerce -c "
        SELECT 
            sum(heap_blks_read) as heap_read,
            sum(heap_blks_hit) as heap_hit,
            sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
        FROM pg_statio_user_tables;"
}

# Function to monitor database in real-time
monitor_database() {
    local container_name="ecommerce-database"
    
    echo "📊 Real-time database monitoring (press Ctrl+C to stop)"
    
    while true; do
        clear
        echo "Database Status - $(date)"
        echo "========================"
        
        # Current activity
        docker exec $container_name psql -U postgres -d ecommerce -c "
            SELECT pid, usename, application_name, state, query_start, query 
            FROM pg_stat_activity 
            WHERE state != 'idle' 
            ORDER BY query_start;"
        
        sleep 5
    done
}
```

---

## 🔒 Part 4: Security Forensics

### Container Security Analysis

**Security Incident Investigation:**
```bash
#!/bin/bash
# security-forensics.sh - Container security forensics

# Function to check for security indicators
security_scan() {
    local container_name=$1
    
    echo "🔒 Security Analysis for $container_name"
    echo "========================================"
    
    # Check for suspicious processes
    echo "Suspicious processes:"
    docker exec $container_name ps aux | grep -E "(nc|netcat|nmap|wget|curl)" || echo "None found"
    
    # Check for unusual network connections
    echo "Network connections:"
    docker exec $container_name netstat -tulpn | grep -v "127.0.0.1"
    
    # Check file permissions
    echo "Suspicious file permissions:"
    docker exec $container_name find /app -perm -4000 -o -perm -2000 2>/dev/null || echo "None found"
    
    # Check for modified system files
    echo "Recently modified files:"
    docker exec $container_name find /etc /usr/bin /usr/sbin -mtime -1 2>/dev/null | head -10
    
    # Check environment variables for secrets
    echo "Environment variables (filtered):"
    docker exec $container_name env | grep -v -E "(PASSWORD|SECRET|KEY|TOKEN)" | head -10
}

# Function to collect forensic evidence
collect_evidence() {
    local container_name=$1
    local evidence_dir="/tmp/forensics/$(date +%Y%m%d_%H%M%S)"
    
    echo "🕵️ Collecting forensic evidence for $container_name"
    mkdir -p "$evidence_dir"
    
    # Container metadata
    docker inspect $container_name > "$evidence_dir/container_inspect.json"
    
    # Process list
    docker exec $container_name ps aux > "$evidence_dir/processes.txt"
    
    # Network connections
    docker exec $container_name netstat -tulpn > "$evidence_dir/network.txt"
    
    # File system changes
    docker diff $container_name > "$evidence_dir/filesystem_changes.txt"
    
    # Logs
    docker logs $container_name > "$evidence_dir/container_logs.txt" 2>&1
    
    # System information
    docker exec $container_name uname -a > "$evidence_dir/system_info.txt"
    docker exec $container_name cat /proc/version >> "$evidence_dir/system_info.txt"
    
    echo "✅ Evidence collected in $evidence_dir"
}
```

---

## 🧪 Part 5: Hands-On Debugging Labs

### Lab 1: Performance Issue Investigation

**Scenario:** E-commerce API is responding slowly

```bash
#!/bin/bash
# performance-lab.sh

echo "🔍 Performance Investigation Lab"
echo "================================"

# Simulate performance issue
docker run -d --name slow-api \
  --memory=256m \
  --cpus=0.5 \
  nginx:alpine

# Investigation steps
echo "1. Check resource usage:"
docker stats slow-api --no-stream

echo "2. Analyze processes:"
docker exec slow-api ps aux

echo "3. Check memory usage:"
docker exec slow-api cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)"

echo "4. Monitor in real-time:"
docker stats slow-api
```

### Lab 2: Network Connectivity Issues

**Scenario:** Container cannot connect to external services

```bash
#!/bin/bash
# network-lab.sh

echo "🌐 Network Debugging Lab"
echo "========================"

# Create test container
docker run -d --name network-test alpine:latest sleep 3600

# Test connectivity
echo "1. Test DNS resolution:"
docker exec network-test nslookup google.com

echo "2. Test HTTP connectivity:"
docker exec network-test wget -O- --timeout=5 http://google.com

echo "3. Check network configuration:"
docker exec network-test ip addr show
docker exec network-test ip route show

# Cleanup
docker stop network-test
docker rm network-test
```

---

## 📊 Part 6: Automated Debugging Tools

### Debugging Automation Script

**Comprehensive Debug Automation:**
```python
#!/usr/bin/env python3
# auto-debugger.py - Automated container debugging

import docker
import json
import subprocess
import time
from datetime import datetime

class ContainerDebugger:
    def __init__(self):
        self.client = docker.from_env()
        self.debug_results = {}
    
    def debug_container(self, container_name):
        """Run comprehensive debugging on a container"""
        print(f"🔍 Starting automated debug of {container_name}")
        
        try:
            container = self.client.containers.get(container_name)
            
            # Collect basic information
            self.debug_results[container_name] = {
                'timestamp': datetime.now().isoformat(),
                'status': container.status,
                'image': container.image.tags[0] if container.image.tags else 'unknown',
                'created': container.attrs['Created'],
                'started': container.attrs['State'].get('StartedAt'),
            }
            
            # Resource usage
            stats = container.stats(stream=False)
            self.debug_results[container_name]['resources'] = {
                'cpu_percent': self.calculate_cpu_percent(stats),
                'memory_usage': stats['memory_stats'].get('usage', 0),
                'memory_limit': stats['memory_stats'].get('limit', 0),
            }
            
            # Process information
            processes = container.exec_run('ps aux').output.decode()
            self.debug_results[container_name]['processes'] = processes.split('\n')[:10]
            
            # Network information
            network_info = container.exec_run('netstat -tulpn').output.decode()
            self.debug_results[container_name]['network'] = network_info.split('\n')[:10]
            
            # Recent logs
            logs = container.logs(tail=50).decode()
            self.debug_results[container_name]['recent_logs'] = logs.split('\n')[-10:]
            
            print(f"✅ Debug completed for {container_name}")
            
        except Exception as e:
            print(f"❌ Error debugging {container_name}: {e}")
            self.debug_results[container_name] = {'error': str(e)}
    
    def calculate_cpu_percent(self, stats):
        """Calculate CPU percentage from stats"""
        try:
            cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                       stats['precpu_stats']['cpu_usage']['total_usage']
            system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                          stats['precpu_stats']['system_cpu_usage']
            
            if system_delta > 0:
                return (cpu_delta / system_delta) * 100.0
        except (KeyError, ZeroDivisionError):
            pass
        return 0.0
    
    def generate_report(self):
        """Generate debugging report"""
        report = {
            'debug_session': {
                'timestamp': datetime.now().isoformat(),
                'containers_analyzed': len(self.debug_results)
            },
            'results': self.debug_results
        }
        
        # Save report
        with open(f'/tmp/debug_report_{int(time.time())}.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        return report
    
    def debug_all_ecommerce_containers(self):
        """Debug all e-commerce related containers"""
        containers = self.client.containers.list(
            filters={'label': 'app=ecommerce'}
        )
        
        for container in containers:
            self.debug_container(container.name)
        
        return self.generate_report()

if __name__ == "__main__":
    debugger = ContainerDebugger()
    
    # Debug specific container
    # debugger.debug_container('ecommerce-api')
    
    # Debug all e-commerce containers
    report = debugger.debug_all_ecommerce_containers()
    print(f"📋 Debug report generated: {json.dumps(report, indent=2)}")
```

---

## 🎓 Module Summary

You've mastered container forensics and debugging by learning:

**Core Concepts:**
- Container debugging fundamentals and investigation techniques
- Advanced debugging tools and methodologies
- Security forensics and incident analysis

**Practical Skills:**
- Implementing comprehensive troubleshooting workflows
- Using system-level debugging tools effectively
- Analyzing performance and security issues

**Enterprise Techniques:**
- Automated debugging and monitoring solutions
- Forensic evidence collection and analysis
- Production-ready debugging workflows

**Next Steps:**
- Implement debugging tools for your e-commerce platform
- Set up automated issue detection and analysis
- Prepare for Module 12: Enterprise Deployment Strategies

---

## 📚 Additional Resources

- [Docker Debugging Guide](https://docs.docker.com/config/containers/logging/)
- [Linux Debugging Tools](http://www.brendangregg.com/linuxperf.html)
- [Container Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Performance Analysis Tools](https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)
    gcore -o "$output_dir/container-$container_id-memory" $pid
    
    # Create process memory maps
    cat /proc/$pid/maps > "$output_dir/container-$container_id-maps.txt"
    
    # Dump process status
    cat /proc/$pid/status > "$output_dir/container-$container_id-status.txt"
    
    # Dump file descriptors
    ls -la /proc/$pid/fd/ > "$output_dir/container-$container_id-fds.txt"
    
    # Dump network connections
    netstat -tulpn | grep $pid > "$output_dir/container-$container_id-network.txt"
    
    echo "Memory dump created in $output_dir"
}

analyze_memory_dump() {
    local dump_file=$1
    local output_file=${2:-"memory-analysis.txt"}
    
    echo "Analyzing memory dump: $dump_file"
    
    # Use volatility for memory analysis
    if command -v volatility &> /dev/null; then
        echo "Running Volatility analysis..."
        
        # Get process list
        volatility -f "$dump_file" --profile=LinuxUbuntu1804x64 linux_pslist > "${output_file}.pslist"
        
        # Get network connections
        volatility -f "$dump_file" --profile=LinuxUbuntu1804x64 linux_netstat > "${output_file}.netstat"
        
        # Get loaded modules
        volatility -f "$dump_file" --profile=LinuxUbuntu1804x64 linux_lsmod > "${output_file}.lsmod"
        
        # Extract strings
        strings "$dump_file" | grep -E "(http|ftp|ssh|password|key)" > "${output_file}.strings"
    fi
    
    # Use gdb for analysis
    if command -v gdb &> /dev/null; then
        echo "Running GDB analysis..."
        
        gdb -batch -ex "info registers" -ex "info threads" -ex "bt" \
            -ex "quit" --core="$dump_file" > "${output_file}.gdb"
    fi
}

extract_container_filesystem() {
    local container_id=$1
    local output_dir=${2:-"/tmp/forensics/filesystem"}
    
    echo "Extracting filesystem for container $container_id"
    
    mkdir -p "$output_dir"
    
    # Export container filesystem
    docker export $container_id | tar -C "$output_dir" -xf -
    
    # Create file timeline
    find "$output_dir" -type f -exec stat -c "%Y %n" {} \; | \
        sort -n > "$output_dir/../filesystem-timeline.txt"
    
    # Extract configuration files
    mkdir -p "$output_dir/../configs"
    find "$output_dir" -name "*.conf" -o -name "*.cfg" -o -name "*.ini" | \
        xargs -I {} cp {} "$output_dir/../configs/"
    
    # Extract log files
    mkdir -p "$output_dir/../logs"
    find "$output_dir" -name "*.log" -o -path "*/log/*" | \
        xargs -I {} cp {} "$output_dir/../logs/" 2>/dev/null
    
    echo "Filesystem extracted to $output_dir"
}

analyze_container_logs() {
    local container_id=$1
    local output_file=${2:-"log-analysis.txt"}
    
    echo "Analyzing container logs for $container_id"
    
    # Get container logs
    docker logs $container_id > "$output_file.raw" 2>&1
    
    # Analyze log patterns
    {
        echo "=== ERROR ANALYSIS ==="
        grep -i "error\|exception\|fail\|critical" "$output_file.raw" | head -20
        
        echo -e "\n=== NETWORK ACTIVITY ==="
        grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" "$output_file.raw" | head -20
        
        echo -e "\n=== AUTHENTICATION EVENTS ==="
        grep -i "login\|auth\|password\|token" "$output_file.raw" | head -20
        
        echo -e "\n=== SUSPICIOUS ACTIVITY ==="
        grep -i "wget\|curl\|download\|upload\|shell\|exec" "$output_file.raw" | head -20
        
        echo -e "\n=== TIMELINE ANALYSIS ==="
        awk '{print $1, $2, $NF}' "$output_file.raw" | sort | uniq -c | sort -nr | head -10
        
    } > "$output_file"
    
    echo "Log analysis saved to $output_file"
}

network_forensics() {
    local container_id=$1
    local duration=${2:-60}
    local output_dir=${3:-"/tmp/forensics/network"}
    
    echo "Starting network forensics for container $container_id"
    
    mkdir -p "$output_dir"
    
    # Get container network namespace
    local pid=$(docker inspect -f '{{.State.Pid}}' $container_id)
    local netns_path="/proc/$pid/ns/net"
    
    # Capture network traffic
    timeout $duration nsenter -t $pid -n tcpdump -i any -w "$output_dir/capture.pcap" &
    
    # Monitor network connections
    while [ $duration -gt 0 ]; do
        echo "$(date): $(nsenter -t $pid -n netstat -tuln)" >> "$output_dir/connections.log"
        sleep 5
        duration=$((duration-5))
    done
    
    # Analyze captured traffic
    if command -v tshark &> /dev/null; then
        echo "Analyzing network capture..."
        
        # Extract HTTP requests
        tshark -r "$output_dir/capture.pcap" -Y "http.request" \
            -T fields -e http.host -e http.request.uri > "$output_dir/http-requests.txt"
        
        # Extract DNS queries
        tshark -r "$output_dir/capture.pcap" -Y "dns.qry.name" \
            -T fields -e dns.qry.name > "$output_dir/dns-queries.txt"
        
        # Extract IP conversations
        tshark -r "$output_dir/capture.pcap" -q -z conv,ip > "$output_dir/ip-conversations.txt"
    fi
    
    echo "Network forensics completed. Results in $output_dir"
}

process_forensics() {
    local container_id=$1
    local output_dir=${2:-"/tmp/forensics/processes"}
    
    echo "Performing process forensics for container $container_id"
    
    mkdir -p "$output_dir"
    
    local pid=$(docker inspect -f '{{.State.Pid}}' $container_id)
    
    # Get process tree
    pstree -p $pid > "$output_dir/process-tree.txt"
    
    # Get detailed process information
    ps -eo pid,ppid,cmd,etime,user --forest | grep -A 50 $pid > "$output_dir/process-details.txt"
    
    # Get process memory maps for all processes
    for proc_pid in $(pgrep -P $pid); do
        if [ -r "/proc/$proc_pid/maps" ]; then
            echo "=== Process $proc_pid ===" >> "$output_dir/memory-maps.txt"
            cat "/proc/$proc_pid/maps" >> "$output_dir/memory-maps.txt"
            echo "" >> "$output_dir/memory-maps.txt"
        fi
    done
    
    # Get open files
    lsof -p $pid > "$output_dir/open-files.txt" 2>/dev/null
    
    # Get system calls trace
    timeout 30 strace -f -p $pid -o "$output_dir/syscalls.trace" 2>/dev/null &
    
    echo "Process forensics completed. Results in $output_dir"
}

security_analysis() {
    local container_id=$1
    local output_file=${2:-"security-analysis.txt"}
    
    echo "Performing security analysis for container $container_id"
    
    {
        echo "=== CONTAINER SECURITY ANALYSIS ==="
        echo "Container ID: $container_id"
        echo "Analysis Date: $(date)"
        echo ""
        
        echo "=== CONTAINER CONFIGURATION ==="
        docker inspect $container_id | jq '.[] | {
            Image: .Config.Image,
            User: .Config.User,
            Privileged: .HostConfig.Privileged,
            PidMode: .HostConfig.PidMode,
            NetworkMode: .HostConfig.NetworkMode,
            Mounts: .Mounts,
            SecurityOpt: .HostConfig.SecurityOpt,
            CapAdd: .HostConfig.CapAdd,
            CapDrop: .HostConfig.CapDrop
        }'
        
        echo -e "\n=== RUNNING PROCESSES ==="
        docker exec $container_id ps aux 2>/dev/null || echo "Cannot access processes"
        
        echo -e "\n=== NETWORK CONNECTIONS ==="
        docker exec $container_id netstat -tuln 2>/dev/null || echo "Cannot access network info"
        
        echo -e "\n=== LISTENING SERVICES ==="
        docker exec $container_id ss -tlnp 2>/dev/null || echo "Cannot access service info"
        
        echo -e "\n=== SUID/SGID FILES ==="
        docker exec $container_id find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -la {} \; 2>/dev/null | head -20
        
        echo -e "\n=== WORLD WRITABLE FILES ==="
        docker exec $container_id find / -type f -perm -002 -exec ls -la {} \; 2>/dev/null | head -10
        
        echo -e "\n=== SUSPICIOUS BINARIES ==="
        docker exec $container_id find / -name "*nc*" -o -name "*netcat*" -o -name "*nmap*" -o -name "*wget*" -o -name "*curl*" 2>/dev/null
        
        echo -e "\n=== ENVIRONMENT VARIABLES ==="
        docker exec $container_id env 2>/dev/null | grep -v "^PATH="
        
        echo -e "\n=== CRONTAB ENTRIES ==="
        docker exec $container_id crontab -l 2>/dev/null || echo "No crontab"
        
        echo -e "\n=== RECENT FILE MODIFICATIONS ==="
        docker exec $container_id find / -type f -mtime -1 -exec ls -la {} \; 2>/dev/null | head -20
        
    } > "$output_file"
    
    echo "Security analysis saved to $output_file"
}

incident_response() {
    local container_id=$1
    local incident_type=${2:-"unknown"}
    local output_dir="/tmp/forensics/incident-$(date +%Y%m%d-%H%M%S)"
    
    echo "Starting incident response for container $container_id"
    echo "Incident type: $incident_type"
    
    mkdir -p "$output_dir"
    
    # Create incident report
    {
        echo "CONTAINER INCIDENT RESPONSE REPORT"
        echo "=================================="
        echo "Container ID: $container_id"
        echo "Incident Type: $incident_type"
        echo "Response Time: $(date)"
        echo "Analyst: $(whoami)"
        echo ""
    } > "$output_dir/incident-report.txt"
    
    # Immediate containment
    echo "Step 1: Containment"
    docker pause $container_id
    echo "Container paused for analysis" >> "$output_dir/incident-report.txt"
    
    # Evidence collection
    echo "Step 2: Evidence Collection"
    
    # Memory dump
    create_memory_dump $container_id "$output_dir/memory"
    
    # Filesystem extraction
    extract_container_filesystem $container_id "$output_dir/filesystem"
    
    # Log analysis
    analyze_container_logs $container_id "$output_dir/logs/analysis"
    
    # Network forensics (if container is still running)
    docker unpause $container_id
    network_forensics $container_id 60 "$output_dir/network"
    docker pause $container_id
    
    # Process forensics
    process_forensics $container_id "$output_dir/processes"
    
    # Security analysis
    security_analysis $container_id "$output_dir/security-analysis.txt"
    
    # Create timeline
    create_incident_timeline $container_id "$output_dir/timeline.txt"
    
    # Generate final report
    generate_incident_report "$output_dir"
    
    echo "Incident response completed. Evidence in $output_dir"
}

create_incident_timeline() {
    local container_id=$1
    local output_file=$2
    
    {
        echo "INCIDENT TIMELINE"
        echo "================"
        echo ""
        
        echo "Container Events:"
        docker events --since="24h" --filter="container=$container_id" --format="{{.Time}}: {{.Action}} - {{.Actor.Attributes.name}}"
        
        echo -e "\nImage History:"
        docker history $(docker inspect -f '{{.Config.Image}}' $container_id) --format="{{.CreatedAt}}: {{.CreatedBy}}"
        
        echo -e "\nSystem Events (last 24h):"
        journalctl --since="24 hours ago" | grep -i docker | tail -20
        
    } > "$output_file"
}

generate_incident_report() {
    local evidence_dir=$1
    local report_file="$evidence_dir/FINAL-INCIDENT-REPORT.md"
    
    {
        echo "# Container Security Incident Report"
        echo ""
        echo "## Executive Summary"
        echo "This report contains the forensic analysis of a container security incident."
        echo ""
        echo "## Evidence Collected"
        echo "- Memory dumps and analysis"
        echo "- Complete filesystem extraction"
        echo "- Network traffic capture and analysis"
        echo "- Process and system call traces"
        echo "- Security configuration analysis"
        echo "- Timeline reconstruction"
        echo ""
        echo "## Key Findings"
        
        # Analyze evidence and generate findings
        if [ -f "$evidence_dir/security-analysis.txt" ]; then
            echo "### Security Issues Identified"
            grep -A 5 "SUSPICIOUS\|SUID\|WRITABLE" "$evidence_dir/security-analysis.txt" | head -20
        fi
        
        if [ -f "$evidence_dir/network/http-requests.txt" ]; then
            echo "### Network Activity"
            echo "HTTP requests detected:"
            head -10 "$evidence_dir/network/http-requests.txt"
        fi
        
        echo ""
        echo "## Recommendations"
        echo "1. Review container security configuration"
        echo "2. Implement additional monitoring"
        echo "3. Update security policies"
        echo "4. Consider container replacement"
        echo ""
        echo "## Evidence Location"
        echo "All evidence has been preserved in: $evidence_dir"
        
    } > "$report_file"
    
    echo "Final incident report generated: $report_file"
}

# Main forensics function
container_forensics() {
    local action=$1
    local container_id=$2
    shift 2
    
    case "$action" in
        "memory-dump")
            create_memory_dump "$container_id" "$@"
            ;;
        "filesystem")
            extract_container_filesystem "$container_id" "$@"
            ;;
        "logs")
            analyze_container_logs "$container_id" "$@"
            ;;
        "network")
            network_forensics "$container_id" "$@"
            ;;
        "processes")
            process_forensics "$container_id" "$@"
            ;;
        "security")
            security_analysis "$container_id" "$@"
            ;;
        "incident")
            incident_response "$container_id" "$@"
            ;;
        "full")
            echo "Performing full forensic analysis..."
            local output_dir="/tmp/forensics/full-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$output_dir"
            
            create_memory_dump "$container_id" "$output_dir/memory"
            extract_container_filesystem "$container_id" "$output_dir/filesystem"
            analyze_container_logs "$container_id" "$output_dir/logs"
            network_forensics "$container_id" 60 "$output_dir/network"
            process_forensics "$container_id" "$output_dir/processes"
            security_analysis "$container_id" "$output_dir/security-analysis.txt"
            
            echo "Full forensic analysis completed in $output_dir"
            ;;
        *)
            echo "Usage: $0 {memory-dump|filesystem|logs|network|processes|security|incident|full} <container_id> [options]"
            exit 1
            ;;
    esac
}

# Execute if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    container_forensics "$@"
fi
```
