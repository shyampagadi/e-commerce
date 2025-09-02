# ⚙️ Kernel-Level Container Tuning

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** Linux kernel features that impact container performance
- **Master** cgroups v2 configuration and resource management
- **Implement** kernel-level optimizations for e-commerce workloads
- **Configure** advanced networking and storage kernel parameters
- **Apply** production-ready kernel tuning strategies

## 🎯 Real-World Context
E-commerce platforms require maximum performance from their infrastructure. Kernel-level tuning can provide 20-50% performance improvements in CPU scheduling, memory management, and I/O operations. This module teaches you to optimize the Linux kernel for containerized e-commerce applications.

---

## 📚 Part 1: Container Kernel Fundamentals

### Understanding Container-Kernel Interaction

**Key Kernel Subsystems for Containers:**

**1. Control Groups (cgroups)**
- Resource isolation and limiting
- CPU, memory, I/O, and network control
- Hierarchical resource management
- Performance monitoring and accounting

**2. Namespaces**
- Process isolation (PID namespace)
- Network isolation (network namespace)
- Filesystem isolation (mount namespace)
- User isolation (user namespace)

**3. Linux Security Modules (LSM)**
- SELinux and AppArmor integration
- Mandatory access controls
- Container security policies
- Capability management

### Kernel Parameters for Containers

**Essential Kernel Parameters:**
```bash
# /etc/sysctl.conf - Container-optimized kernel parameters

# Network optimizations
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
vm.overcommit_memory = 1
vm.max_map_count = 262144

# File system optimizations
fs.file-max = 2097152
fs.nr_open = 1048576
fs.inotify.max_user_watches = 524288

# Process limits
kernel.pid_max = 4194304
kernel.threads-max = 1048576
```

**Apply Kernel Parameters:**
```bash
# Apply immediately
sudo sysctl -p

# Verify settings
sysctl net.core.somaxconn
sysctl vm.swappiness
sysctl fs.file-max

# Monitor kernel parameters
watch -n 1 'cat /proc/sys/net/core/somaxconn'
```

---

## 🔧 Part 2: Advanced cgroups Configuration

### cgroups v2 for E-Commerce Containers

**Understanding cgroups Hierarchy:**
```bash
# Check cgroups version
mount | grep cgroup

# View cgroups hierarchy
systemd-cgls

# Check container cgroups
docker exec ecommerce-api cat /proc/self/cgroup
```

**Custom cgroups Configuration:**
```bash
#!/bin/bash
# setup-cgroups.sh - Advanced cgroups configuration for e-commerce

# Create custom cgroup for e-commerce services
sudo mkdir -p /sys/fs/cgroup/ecommerce

# Enable controllers
echo "+cpu +memory +io +pids" | sudo tee /sys/fs/cgroup/ecommerce/cgroup.subtree_control

# Configure CPU limits for different tiers
# Database tier - high priority
sudo mkdir -p /sys/fs/cgroup/ecommerce/database
echo "10000 100000" | sudo tee /sys/fs/cgroup/ecommerce/database/cpu.max  # 10 cores max
echo "1000" | sudo tee /sys/fs/cgroup/ecommerce/database/cpu.weight        # High priority

# API tier - balanced
sudo mkdir -p /sys/fs/cgroup/ecommerce/api
echo "6000 100000" | sudo tee /sys/fs/cgroup/ecommerce/api/cpu.max         # 6 cores max
echo "500" | sudo tee /sys/fs/cgroup/ecommerce/api/cpu.weight              # Normal priority

# Frontend tier - lower priority
sudo mkdir -p /sys/fs/cgroup/ecommerce/frontend
echo "2000 100000" | sudo tee /sys/fs/cgroup/ecommerce/frontend/cpu.max    # 2 cores max
echo "100" | sudo tee /sys/fs/cgroup/ecommerce/frontend/cpu.weight         # Lower priority

# Memory limits
echo "8G" | sudo tee /sys/fs/cgroup/ecommerce/database/memory.max
echo "4G" | sudo tee /sys/fs/cgroup/ecommerce/api/memory.max
echo "1G" | sudo tee /sys/fs/cgroup/ecommerce/frontend/memory.max

# I/O limits (IOPS)
echo "8:0 riops=10000 wiops=5000" | sudo tee /sys/fs/cgroup/ecommerce/database/io.max
echo "8:0 riops=5000 wiops=2500" | sudo tee /sys/fs/cgroup/ecommerce/api/io.max
echo "8:0 riops=1000 wiops=500" | sudo tee /sys/fs/cgroup/ecommerce/frontend/io.max
```

### Docker Integration with Custom cgroups

**Docker Compose with cgroups:**
```yaml
# docker-compose.cgroups.yml
version: '3.8'

services:
  ecommerce-database:
    image: postgres:15
    deploy:
      resources:
        limits:
          cpus: '10.0'
          memory: 8G
        reservations:
          cpus: '4.0'
          memory: 4G
    # Custom cgroup path
    cgroup_parent: ecommerce/database
    
  ecommerce-api:
    image: ecommerce/api:latest
    deploy:
      resources:
        limits:
          cpus: '6.0'
          memory: 4G
        reservations:
          cpus: '2.0'
          memory: 2G
    cgroup_parent: ecommerce/api
    
  ecommerce-frontend:
    image: ecommerce/frontend:latest
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    cgroup_parent: ecommerce/frontend
```

---

## 🏗️ Part 3: CPU and Memory Optimization

### CPU Scheduling Optimization

**CPU Affinity and NUMA Optimization:**
```bash
#!/bin/bash
# cpu-optimization.sh - CPU optimization for containers

# Check NUMA topology
numactl --hardware
lscpu | grep NUMA

# Set CPU affinity for database containers
docker run -d \
  --name ecommerce-database \
  --cpuset-cpus="0-7" \
  --cpuset-mems="0" \
  postgres:15

# Set CPU affinity for API containers
docker run -d \
  --name ecommerce-api \
  --cpuset-cpus="8-15" \
  --cpuset-mems="1" \
  ecommerce/api:latest

# Monitor CPU usage by NUMA node
numastat -c

# Check CPU affinity of running containers
for container in $(docker ps --format "{{.Names}}"); do
  echo "Container: $container"
  docker exec $container cat /proc/self/status | grep Cpus_allowed_list
done
```

**CPU Governor Optimization:**
```bash
#!/bin/bash
# cpu-governor.sh - Optimize CPU governor for containers

# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set performance governor for database nodes
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set ondemand governor for API nodes (balanced performance/power)
echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Configure ondemand parameters
echo 10 | sudo tee /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
echo 5 | sudo tee /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
```

### Memory Management Optimization

**Memory Allocation Strategies:**
```bash
#!/bin/bash
# memory-optimization.sh - Memory optimization for containers

# Configure transparent huge pages
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

# Optimize memory allocation for databases
echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode
echo 1 | sudo tee /proc/sys/vm/swappiness

# Configure NUMA memory policy
echo 1 | sudo tee /proc/sys/kernel/numa_balancing

# Set memory overcommit for containers
echo 1 | sudo tee /proc/sys/vm/overcommit_memory
echo 80 | sudo tee /proc/sys/vm/overcommit_ratio
```

**Memory Monitoring and Tuning:**
```python
# memory_monitor.py - Advanced memory monitoring
import os
import time
import docker
from typing import Dict

class MemoryMonitor:
    def __init__(self):
        self.client = docker.from_env()
        
    def get_memory_stats(self, container_name: str) -> Dict:
        """Get detailed memory statistics for container"""
        try:
            container = self.client.containers.get(container_name)
            stats = container.stats(stream=False)
            
            memory_stats = stats['memory_stats']
            
            return {
                'usage': memory_stats.get('usage', 0),
                'limit': memory_stats.get('limit', 0),
                'cache': memory_stats.get('stats', {}).get('cache', 0),
                'rss': memory_stats.get('stats', {}).get('rss', 0),
                'swap': memory_stats.get('stats', {}).get('swap', 0),
                'usage_percent': (memory_stats.get('usage', 0) / memory_stats.get('limit', 1)) * 100
            }
        except Exception as e:
            print(f"Error getting memory stats: {e}")
            return {}
    
    def optimize_memory_settings(self, container_name: str, stats: Dict):
        """Dynamically optimize memory settings based on usage"""
        usage_percent = stats.get('usage_percent', 0)
        
        if usage_percent > 85:
            print(f"⚠️ High memory usage in {container_name}: {usage_percent:.1f}%")
            # Trigger memory cleanup or scaling
            self.trigger_memory_cleanup(container_name)
        elif usage_percent < 30:
            print(f"💡 Low memory usage in {container_name}: {usage_percent:.1f}%")
            # Consider reducing memory allocation
    
    def trigger_memory_cleanup(self, container_name: str):
        """Trigger memory cleanup in container"""
        try:
            container = self.client.containers.get(container_name)
            
            # For database containers, trigger cache cleanup
            if 'database' in container_name:
                container.exec_run("psql -c 'SELECT pg_reload_conf();'")
            
            # For application containers, trigger garbage collection
            elif 'api' in container_name:
                container.exec_run("kill -USR2 1")  # Trigger GC in Node.js
                
        except Exception as e:
            print(f"Error triggering cleanup: {e}")
    
    def monitor_loop(self):
        """Main monitoring loop"""
        while True:
            containers = ['ecommerce-database', 'ecommerce-api', 'ecommerce-frontend']
            
            for container_name in containers:
                stats = self.get_memory_stats(container_name)
                if stats:
                    print(f"📊 {container_name}: "
                          f"Memory: {stats['usage_percent']:.1f}%, "
                          f"RSS: {stats['rss'] / 1024 / 1024:.1f}MB, "
                          f"Cache: {stats['cache'] / 1024 / 1024:.1f}MB")
                    
                    self.optimize_memory_settings(container_name, stats)
            
            time.sleep(30)

if __name__ == "__main__":
    monitor = MemoryMonitor()
    monitor.monitor_loop()
```

---

## 🌐 Part 4: Network and I/O Optimization

### Network Stack Tuning

**Network Performance Optimization:**
```bash
#!/bin/bash
# network-tuning.sh - Network optimization for containers

# TCP buffer sizes
echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf

# TCP window scaling
echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf

# Connection tracking
echo 'net.netfilter.nf_conntrack_max = 1048576' >> /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_tcp_timeout_established = 1200' >> /etc/sysctl.conf

# Apply settings
sysctl -p

# Configure network interfaces for containers
ip link set dev docker0 txqueuelen 1000
ethtool -G docker0 rx 4096 tx 4096 2>/dev/null || true
```

### Storage I/O Optimization

**I/O Scheduler and Block Device Tuning:**
```bash
#!/bin/bash
# io-optimization.sh - I/O optimization for container storage

# Set I/O scheduler for different workloads
# Database storage - deadline scheduler for consistent latency
echo deadline | sudo tee /sys/block/sda/queue/scheduler

# Application storage - mq-deadline for multi-queue
echo mq-deadline | sudo tee /sys/block/sdb/queue/scheduler

# Configure I/O queue depth
echo 32 | sudo tee /sys/block/sda/queue/nr_requests
echo 128 | sudo tee /sys/block/sdb/queue/nr_requests

# Optimize read-ahead for sequential workloads
blockdev --setra 4096 /dev/sda  # Database
blockdev --setra 256 /dev/sdb   # Applications

# Configure filesystem mount options for containers
mount -o remount,noatime,nodiratime /var/lib/docker
```

---

## 🧪 Part 5: Hands-On Kernel Tuning Labs

### Lab 1: CPU Performance Tuning

**Objective:** Optimize CPU performance for e-commerce workloads

```bash
#!/bin/bash
# cpu-tuning-lab.sh

echo "🔧 CPU Performance Tuning Lab"
echo "=============================="

# Check current CPU configuration
echo "Current CPU configuration:"
lscpu | grep -E "(CPU\(s\)|Thread|Core|Socket|NUMA)"

# Set CPU governor to performance
echo "Setting CPU governor to performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Configure CPU affinity for containers
echo "Configuring CPU affinity..."
docker run -d --name cpu-test-db --cpuset-cpus="0-3" postgres:15
docker run -d --name cpu-test-api --cpuset-cpus="4-7" nginx:alpine

# Monitor CPU usage
echo "Monitoring CPU usage (press Ctrl+C to stop):"
top -p $(docker inspect --format='{{.State.Pid}}' cpu-test-db),$(docker inspect --format='{{.State.Pid}}' cpu-test-api)

# Cleanup
docker stop cpu-test-db cpu-test-api
docker rm cpu-test-db cpu-test-api
```

### Lab 2: Memory Optimization

**Objective:** Configure optimal memory settings for containers

```bash
#!/bin/bash
# memory-tuning-lab.sh

echo "💾 Memory Optimization Lab"
echo "=========================="

# Check current memory configuration
echo "Current memory configuration:"
free -h
cat /proc/meminfo | grep -E "(MemTotal|MemAvailable|SwapTotal)"

# Configure memory parameters
echo "Configuring memory parameters..."
echo 1 | sudo tee /proc/sys/vm/swappiness
echo 15 | sudo tee /proc/sys/vm/dirty_ratio
echo 5 | sudo tee /proc/sys/vm/dirty_background_ratio

# Test memory limits
echo "Testing memory limits..."
docker run -d --name memory-test --memory=512m --memory-swap=512m nginx:alpine

# Monitor memory usage
echo "Memory usage for container:"
docker stats memory-test --no-stream

# Cleanup
docker stop memory-test
docker rm memory-test
```

---

## 📊 Part 6: Performance Monitoring and Tuning

### Kernel Performance Monitoring

**Comprehensive Performance Monitoring:**
```bash
#!/bin/bash
# kernel-monitor.sh - Comprehensive kernel performance monitoring

echo "🔍 Kernel Performance Monitor"
echo "============================="

# CPU performance
echo "CPU Performance:"
mpstat 1 1 | tail -n +4

# Memory performance
echo -e "\nMemory Performance:"
vmstat 1 1 | tail -n +3

# I/O performance
echo -e "\nI/O Performance:"
iostat -x 1 1 | tail -n +4

# Network performance
echo -e "\nNetwork Performance:"
sar -n DEV 1 1 | tail -n +3

# Container-specific metrics
echo -e "\nContainer Metrics:"
for container in $(docker ps --format "{{.Names}}"); do
    echo "Container: $container"
    docker exec $container cat /proc/loadavg
    docker exec $container cat /proc/meminfo | grep MemAvailable
done

# Kernel parameters check
echo -e "\nKey Kernel Parameters:"
echo "vm.swappiness: $(cat /proc/sys/vm/swappiness)"
echo "net.core.somaxconn: $(cat /proc/sys/net/core/somaxconn)"
echo "fs.file-max: $(cat /proc/sys/fs/file-max)"
```

---

## 🎓 Module Summary

You've mastered kernel-level container tuning by learning:

**Core Concepts:**
- Linux kernel subsystems affecting container performance
- cgroups v2 configuration and resource management
- Kernel parameter optimization for containers

**Practical Skills:**
- CPU scheduling and NUMA optimization
- Memory management and allocation strategies
- Network and I/O performance tuning

**Enterprise Techniques:**
- Production-ready kernel tuning workflows
- Advanced performance monitoring and alerting
- Dynamic resource optimization based on workload patterns

**Next Steps:**
- Apply kernel optimizations to your e-commerce infrastructure
- Implement automated performance monitoring
- Prepare for Module 10: Advanced Monitoring & Observability

---

## 📚 Additional Resources

- [Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [cgroups v2 Documentation](https://www.kernel.org/doc/Documentation/cgroup-v2.txt)
- [Linux Performance Tools](http://www.brendangregg.com/linuxperf.html)
- [Container Performance Tuning](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/tuning-the-task-scheduler_managing-monitoring-and-updating-the-kernel)
    if (!cg)
        return ERR_PTR(-ENOMEM);
        
    cg->cpu_quota_us = 100000; // Default 100ms
    cg->memory_limit = 1024 * 1024 * 1024; // Default 1GB
    cg->io_weight = 100; // Default weight
    cg->network_priority = 0; // Default priority
    
    return &cg->css;
}

static void container_css_free(struct cgroup_subsys_state *css)
{
    struct container_cgroup *cg = container_of(css, struct container_cgroup, css);
    kfree(cg);
}

static ssize_t container_cpu_quota_write(struct kernfs_open_file *of,
                                       char *buf, size_t nbytes, loff_t off)
{
    struct container_cgroup *cg = container_of(of_css(of), struct container_cgroup, css);
    u64 quota;
    int ret;
    
    ret = kstrtoull(buf, 0, &quota);
    if (ret)
        return ret;
        
    cg->cpu_quota_us = quota;
    
    // Apply CPU quota to all tasks in cgroup
    container_apply_cpu_quota(cg);
    
    return nbytes;
}

static int container_apply_cpu_quota(struct container_cgroup *cg)
{
    struct css_task_iter it;
    struct task_struct *task;
    
    css_task_iter_start(&cg->css, 0, &it);
    while ((task = css_task_iter_next(&it))) {
        // Apply CPU quota to task
        task->se.cfs_rq->runtime_quota = cg->cpu_quota_us * 1000;
    }
    css_task_iter_end(&it);
    
    return 0;
}

static struct cftype container_files[] = {
    {
        .name = "cpu.quota_us",
        .write = container_cpu_quota_write,
        .seq_show = container_cpu_quota_show,
    },
    {
        .name = "memory.limit_bytes",
        .write = container_memory_limit_write,
        .seq_show = container_memory_limit_show,
    },
    {
        .name = "io.weight",
        .write = container_io_weight_write,
        .seq_show = container_io_weight_show,
    },
    { } /* terminate */
};

struct cgroup_subsys container_cgrp_subsys = {
    .css_alloc = container_css_alloc,
    .css_free = container_css_free,
    .legacy_cftypes = container_files,
    .dfl_cftypes = container_files,
};
```

### Advanced Namespace Configuration
```bash
#!/bin/bash
# namespace-optimizer.sh - Advanced namespace configuration

setup_advanced_namespaces() {
    local container_name=$1
    local config_file=$2
    
    echo "Setting up advanced namespaces for $container_name"
    
    # Create custom network namespace with optimizations
    ip netns add ${container_name}-net
    
    # Setup high-performance network stack
    ip netns exec ${container_name}-net sysctl -w net.core.rmem_max=134217728
    ip netns exec ${container_name}-net sysctl -w net.core.wmem_max=134217728
    ip netns exec ${container_name}-net sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728"
    ip netns exec ${container_name}-net sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"
    ip netns exec ${container_name}-net sysctl -w net.core.netdev_max_backlog=30000
    ip netns exec ${container_name}-net sysctl -w net.ipv4.tcp_congestion_control=bbr
    
    # Create custom mount namespace with optimizations
    unshare --mount --propagation private bash -c "
        # Setup optimized tmpfs
        mount -t tmpfs -o size=1G,noatime,mode=1777 tmpfs /tmp
        
        # Setup optimized /dev/shm
        mount -t tmpfs -o size=2G,noatime,mode=1777 tmpfs /dev/shm
        
        # Setup optimized /var/log
        mount -t tmpfs -o size=512M,noatime,mode=755 tmpfs /var/log
        
        # Bind mount optimized directories
        mount --bind /opt/container-optimized/bin /usr/local/bin
        mount --bind /opt/container-optimized/lib /usr/local/lib
    "
    
    # Create custom PID namespace with limits
    echo 1024 > /sys/fs/cgroup/pids/${container_name}/pids.max
    
    # Create custom IPC namespace with optimizations
    sysctl -w kernel.shmmax=68719476736  # 64GB
    sysctl -w kernel.shmall=4294967296   # 16TB
    sysctl -w kernel.msgmax=65536
    sysctl -w kernel.msgmnb=65536
    
    # Create custom UTS namespace
    unshare --uts bash -c "
        hostname ${container_name}
        domainname container.local
    "
}

optimize_container_kernel_params() {
    local container_pid=$1
    
    echo "Optimizing kernel parameters for container PID $container_pid"
    
    # CPU optimizations
    echo 1 > /proc/$container_pid/oom_score_adj  # Prefer killing this process under OOM
    echo 0 > /proc/$container_pid/coredump_filter  # Disable core dumps
    
    # Memory optimizations
    echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
    echo defer > /sys/kernel/mm/transparent_hugepage/defrag
    
    # I/O optimizations
    echo noop > /sys/block/sda/queue/scheduler  # Use noop scheduler for SSDs
    echo 1024 > /sys/block/sda/queue/nr_requests
    echo 2 > /sys/block/sda/queue/rq_affinity
    
    # Network optimizations
    echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
    echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
    echo 65536 > /proc/sys/net/core/somaxconn
    echo 1024 65000 > /proc/sys/net/ipv4/ip_local_port_range
}

setup_custom_seccomp_bpf() {
    local container_name=$1
    
    cat > /tmp/${container_name}-seccomp.bpf << 'EOF'
# Custom BPF seccomp filter for high-performance containers
# Allow only essential system calls

# Load architecture
BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, arch))
BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, AUDIT_ARCH_X86_64, 1, 0)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL)

# Load syscall number
BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr))

# Allow essential syscalls for high performance
BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_read, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_write, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_mmap, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_munmap, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_brk, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

# Network syscalls for high-performance networking
BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_socket, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_sendmsg, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_recvmsg, 0, 1)
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW)

# Deny all other syscalls
BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL)
EOF

    # Compile and apply BPF filter
    gcc -o /tmp/${container_name}-seccomp /tmp/${container_name}-seccomp.bpf
}

tune_container_memory_management() {
    local container_pid=$1
    local memory_limit=$2
    
    echo "Tuning memory management for container PID $container_pid"
    
    # Setup custom memory cgroup
    mkdir -p /sys/fs/cgroup/memory/container-$container_pid
    echo $memory_limit > /sys/fs/cgroup/memory/container-$container_pid/memory.limit_in_bytes
    
    # Optimize memory reclaim
    echo 1 > /sys/fs/cgroup/memory/container-$container_pid/memory.oom_control
    echo 90 > /sys/fs/cgroup/memory/container-$container_pid/memory.swappiness
    
    # Setup memory pressure notifications
    echo $memory_limit*0.8 > /sys/fs/cgroup/memory/container-$container_pid/memory.soft_limit_in_bytes
    
    # Configure NUMA policy for multi-socket systems
    if [ -d /sys/devices/system/node/node1 ]; then
        echo "Configuring NUMA policy"
        numactl --cpunodebind=0 --membind=0 --pid=$container_pid
    fi
    
    # Setup huge pages if available
    if [ -d /sys/kernel/mm/hugepages ]; then
        echo "Configuring huge pages"
        echo 100 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
        mount -t hugetlbfs hugetlbfs /dev/hugepages
    fi
}

optimize_container_cpu_scheduling() {
    local container_pid=$1
    local cpu_quota=$2
    local cpu_period=$3
    
    echo "Optimizing CPU scheduling for container PID $container_pid"
    
    # Setup CPU cgroup
    mkdir -p /sys/fs/cgroup/cpu/container-$container_pid
    echo $cpu_quota > /sys/fs/cgroup/cpu/container-$container_pid/cpu.cfs_quota_us
    echo $cpu_period > /sys/fs/cgroup/cpu/container-$container_pid/cpu.cfs_period_us
    
    # Set CPU affinity for optimal performance
    local cpu_count=$(nproc)
    local cpu_mask=""
    
    if [ $cpu_count -gt 4 ]; then
        # Use specific CPU cores for container
        cpu_mask="0-3"  # Use first 4 cores
    else
        cpu_mask="0-$((cpu_count-1))"
    fi
    
    taskset -cp $cpu_mask $container_pid
    
    # Set real-time scheduling for high-priority containers
    if [ "$CONTAINER_PRIORITY" = "high" ]; then
        chrt -f -p 50 $container_pid  # FIFO scheduling with priority 50
    fi
    
    # Optimize CPU governor
    echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    
    # Disable CPU idle states for low latency
    if [ "$LOW_LATENCY" = "true" ]; then
        for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
            echo 1 > $state 2>/dev/null || true
        done
    fi
}

setup_advanced_io_scheduling() {
    local container_pid=$1
    local io_priority=$2
    
    echo "Setting up advanced I/O scheduling for container PID $container_pid"
    
    # Setup I/O cgroup
    mkdir -p /sys/fs/cgroup/blkio/container-$container_pid
    echo $container_pid > /sys/fs/cgroup/blkio/container-$container_pid/cgroup.procs
    
    # Set I/O weight (100-1000)
    echo $io_priority > /sys/fs/cgroup/blkio/container-$container_pid/blkio.weight
    
    # Configure I/O throttling
    local device_major_minor=$(stat -c "%t:%T" /dev/sda)
    echo "$device_major_minor 104857600" > /sys/fs/cgroup/blkio/container-$container_pid/blkio.throttle.read_bps_device
    echo "$device_major_minor 104857600" > /sys/fs/cgroup/blkio/container-$container_pid/blkio.throttle.write_bps_device
    
    # Set I/O nice level
    ionice -c 1 -n 4 -p $container_pid  # Real-time class, priority 4
    
    # Optimize block device queue
    echo mq-deadline > /sys/block/sda/queue/scheduler
    echo 128 > /sys/block/sda/queue/nr_requests
    echo 4096 > /sys/block/sda/queue/read_ahead_kb
}

monitor_kernel_performance() {
    local container_pid=$1
    local duration=${2:-60}
    
    echo "Monitoring kernel performance for container PID $container_pid for ${duration}s"
    
    # Start perf monitoring
    perf record -g -p $container_pid -o /tmp/container-$container_pid-perf.data sleep $duration &
    
    # Monitor system calls
    strace -c -p $container_pid -o /tmp/container-$container_pid-syscalls.log &
    
    # Monitor memory usage
    while [ $duration -gt 0 ]; do
        echo "$(date): $(cat /proc/$container_pid/status | grep VmRSS)" >> /tmp/container-$container_pid-memory.log
        sleep 1
        duration=$((duration-1))
    done
    
    # Generate performance report
    perf report -i /tmp/container-$container_pid-perf.data > /tmp/container-$container_pid-perf-report.txt
    
    echo "Performance monitoring completed. Reports saved to /tmp/"
}

# Main optimization function
optimize_container_kernel() {
    local container_name=$1
    local container_pid=$2
    local config_file=${3:-"/etc/container-kernel-config.conf"}
    
    echo "Starting kernel-level optimization for container: $container_name (PID: $container_pid)"
    
    # Load configuration
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi
    
    # Setup advanced namespaces
    setup_advanced_namespaces "$container_name" "$config_file"
    
    # Optimize kernel parameters
    optimize_container_kernel_params "$container_pid"
    
    # Setup custom seccomp filter
    setup_custom_seccomp_bpf "$container_name"
    
    # Tune memory management
    tune_container_memory_management "$container_pid" "${MEMORY_LIMIT:-1073741824}"
    
    # Optimize CPU scheduling
    optimize_container_cpu_scheduling "$container_pid" "${CPU_QUOTA:-100000}" "${CPU_PERIOD:-100000}"
    
    # Setup I/O scheduling
    setup_advanced_io_scheduling "$container_pid" "${IO_PRIORITY:-500}"
    
    # Start performance monitoring
    if [ "$ENABLE_MONITORING" = "true" ]; then
        monitor_kernel_performance "$container_pid" "${MONITOR_DURATION:-300}" &
    fi
    
    echo "Kernel-level optimization completed for container: $container_name"
}

# Usage example
if [ "$1" = "optimize" ]; then
    optimize_container_kernel "$2" "$3" "$4"
elif [ "$1" = "monitor" ]; then
    monitor_kernel_performance "$2" "$3"
else
    echo "Usage: $0 {optimize|monitor} <container_name> <container_pid> [config_file]"
    exit 1
fi
```
