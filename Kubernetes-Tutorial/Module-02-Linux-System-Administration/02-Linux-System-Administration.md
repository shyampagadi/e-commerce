# 🐧 **Module 2: Linux System Administration**
## Essential Linux Skills for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 2-3 hours  
**Prerequisites**: Basic understanding of operating systems  
**Learning Objectives**: Master Linux system administration skills essential for Kubernetes

### **🛠️ Tools Covered**
- **bash**: Shell scripting and command-line operations
- **systemd**: Service management and process control
- **journald**: System logging and log management
- **htop/iotop**: System monitoring and resource analysis
- **netstat/ss**: Network connection analysis
- **lsof**: File and process monitoring
- **strace**: System call tracing and debugging

### **🏭 Industry Tools**
- **Ansible**: Configuration management and automation
- **Puppet**: Infrastructure as Code and configuration management
- **Chef**: Configuration management and deployment automation
- **SaltStack**: Infrastructure automation and configuration management
- **Terraform**: Infrastructure as Code and cloud provisioning
- **Cloud-init**: Cloud instance initialization and configuration

### **🌍 Environment Strategy**
This module prepares Linux administration skills for all environments:
- **DEV**: Development environment management and debugging
- **UAT**: User Acceptance Testing environment monitoring
- **PROD**: Production system administration and troubleshooting

### **💥 Chaos Engineering**
- **System resource exhaustion**: Testing behavior under memory/CPU pressure
- **Process killing**: Testing application resilience to process failures
- **File system corruption simulation**: Testing data integrity and recovery
- **Network interface failures**: Testing network resilience

### **Chaos Packages**
- **stress-ng**: System stress testing and resource exhaustion
- **iotop**: I/O monitoring and disk stress testing
- **htop**: Process monitoring and system resource analysis

---

## 🎯 **Learning Objectives**

By the end of this module, you will:
- Master essential Linux commands for Kubernetes administration
- Understand process management and system monitoring
- Learn file system operations and permissions
- Master network configuration and troubleshooting
- Understand system logging and debugging techniques
- Apply Linux skills to Kubernetes node management
- Implement chaos engineering scenarios for system resilience

---

## 📚 **Theory Section: Linux System Administration**

### **Why Linux for Kubernetes?**

Kubernetes runs on Linux nodes, making Linux system administration skills essential for:
- **Node Management**: Understanding how Kubernetes components interact with the OS
- **Troubleshooting**: Debugging issues at the system level
- **Performance Optimization**: Monitoring and tuning system resources
- **Security**: Implementing security policies and access controls

### **Linux Architecture Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                    User Space                               │
├─────────────────────────────────────────────────────────────┤
│  Applications (Docker, Kubernetes, etc.)                   │
├─────────────────────────────────────────────────────────────┤
│  System Libraries (glibc, systemd, etc.)                  │
├─────────────────────────────────────────────────────────────┤
│                    Kernel Space                             │
├─────────────────────────────────────────────────────────────┤
│  System Calls Interface                                     │
├─────────────────────────────────────────────────────────────┤
│  Kernel (Process Management, Memory, I/O, Network)         │
├─────────────────────────────────────────────────────────────┤
│                    Hardware                                 │
└─────────────────────────────────────────────────────────────┘
```

### **Essential Linux Concepts**

#### **1. Process Management**
- **Processes**: Running programs with unique Process IDs (PIDs)
- **Process States**: Running, sleeping, stopped, zombie
- **Process Hierarchy**: Parent-child relationships
- **Signals**: Inter-process communication mechanism

#### **2. File System**
- **Hierarchical Structure**: Tree-like organization starting from root (/)
- **File Types**: Regular files, directories, symbolic links, devices
- **Permissions**: Read, write, execute for owner, group, and others
- **Inodes**: File system metadata storage

#### **3. Memory Management**
- **Virtual Memory**: Process isolation and memory protection
- **Swap Space**: Disk-based memory extension
- **Memory Mapping**: File-to-memory mapping
- **Buffer Cache**: Kernel memory for I/O optimization

#### **4. Network Stack**
- **TCP/IP Stack**: Network protocol implementation
- **Network Interfaces**: Physical and virtual network adapters
- **Routing**: Packet forwarding between networks
- **Firewall**: Packet filtering and network security

---

## 🔧 **Hands-on Lab: Linux System Administration**

### **Lab 1: Essential Commands and File Operations**

**📋 Overview**: Master fundamental Linux commands for system administration.

**🔍 Detailed Command Analysis**:

```bash
# Navigate to your e-commerce project directory
cd /path/to/your/e-commerce
```

**Explanation**:
- `cd`: Change directory command
- `/path/to/your/e-commerce`: Absolute path to your project directory
- **Purpose**: Navigate to your project for hands-on practice

```bash
# Check current directory and list contents
pwd
ls -la
```

**Explanation**:
- `pwd`: Print working directory - shows current location
- `ls -la`: List directory contents with detailed information
  - `-l`: Long format showing permissions, size, date
  - `-a`: Show all files including hidden ones (starting with .)
- **Output**: Shows file permissions, ownership, size, and modification date

```bash
# Check system information
uname -a
cat /etc/os-release
```

**Explanation**:
- `uname -a`: Display system information (kernel version, architecture)
- `cat /etc/os-release`: Display operating system release information
- **Purpose**: Understand the Linux distribution and kernel version

```bash
# Check disk usage
df -h
du -sh *
```

**Explanation**:
- `df -h`: Display disk space usage in human-readable format
- `du -sh *`: Display directory sizes in human-readable format
  - `-s`: Summarize (show total only)
  - `-h`: Human-readable format (KB, MB, GB)
- **Purpose**: Monitor disk space usage for your e-commerce project

### **Lab 2: Process Management and Monitoring**

**📋 Overview**: Learn to monitor and manage system processes.

**🔍 Detailed Command Analysis**:

```bash
# View running processes
ps aux
```

**Explanation**:
- `ps aux`: Display all running processes
  - `a`: Show processes for all users
  - `u`: Display user-oriented format
  - `x`: Show processes without controlling terminals
- **Output**: Shows PID, CPU usage, memory usage, command

```bash
# Monitor processes in real-time
htop
```

**Explanation**:
- `htop`: Interactive process viewer (install with `sudo apt install htop`)
- **Features**: Real-time updates, process tree view, resource usage
- **Navigation**: Use arrow keys, F9 to kill processes, F10 to quit

```bash
# Check system resources
free -h
top
```

**Explanation**:
- `free -h`: Display memory usage in human-readable format
- `top`: Display running processes and system resource usage
- **Purpose**: Monitor system performance and resource utilization

```bash
# Find processes by name
pgrep -f "python"
ps -ef | grep "uvicorn"
```

**Explanation**:
- `pgrep -f "python"`: Find processes with "python" in command line
- `ps -ef | grep "uvicorn"`: Find processes with "uvicorn" in command line
- **Purpose**: Locate specific application processes (like your e-commerce backend)

### **Lab 3: File System Operations and Permissions**

**📋 Overview**: Master file system operations and permission management.

**🔍 Detailed Command Analysis**:

```bash
# Create directory structure for e-commerce project
mkdir -p ecommerce-linux-lab/{logs,data,config}
```

**Explanation**:
- `mkdir -p`: Create directories recursively
- `ecommerce-linux-lab/{logs,data,config}`: Create multiple directories at once
- **Purpose**: Set up directory structure for Linux administration practice

```bash
# Set permissions
chmod 755 ecommerce-linux-lab
chmod 644 ecommerce-linux-lab/config/*
```

**Explanation**:
- `chmod 755`: Set permissions (owner: read/write/execute, group/others: read/execute)
- `chmod 644`: Set permissions (owner: read/write, group/others: read only)
- **Purpose**: Control access to files and directories

```bash
# Change ownership
sudo chown -R $USER:$USER ecommerce-linux-lab
```

**Explanation**:
- `sudo chown -R $USER:$USER`: Change ownership recursively
- `$USER`: Current user environment variable
- **Purpose**: Ensure proper ownership of files and directories

```bash
# Create symbolic links
ln -s /var/log/syslog ecommerce-linux-lab/logs/system.log
```

**Explanation**:
- `ln -s`: Create symbolic link
- `/var/log/syslog`: Source file
- `ecommerce-linux-lab/logs/system.log`: Link destination
- **Purpose**: Create shortcuts to system files for monitoring

### **Lab 4: Network Configuration and Troubleshooting**

**📋 Overview**: Learn network configuration and troubleshooting techniques.

**🔍 Detailed Command Analysis**:

```bash
# Check network interfaces
ip addr show
ifconfig
```

**Explanation**:
- `ip addr show`: Display network interface information (modern command)
- `ifconfig`: Display network interface information (legacy command)
- **Output**: Shows IP addresses, MAC addresses, interface status

```bash
# Check network connections
netstat -tulpn
ss -tulpn
```

**Explanation**:
- `netstat -tulpn`: Display network connections
  - `-t`: TCP connections
  - `-u`: UDP connections
  - `-l`: Listening ports
  - `-p`: Show process IDs
  - `-n`: Show numerical addresses
- `ss -tulpn`: Modern replacement for netstat with same options
- **Purpose**: Monitor network connections and listening ports

```bash
# Test network connectivity
ping -c 4 google.com
curl -I https://httpbin.org/get
```

**Explanation**:
- `ping -c 4 google.com`: Send 4 ping packets to google.com
- `curl -I https://httpbin.org/get`: Send HTTP HEAD request to test connectivity
- **Purpose**: Test network connectivity and HTTP services

```bash
# Check DNS resolution
nslookup google.com
dig google.com
```

**Explanation**:
- `nslookup google.com`: Query DNS for google.com
- `dig google.com`: More detailed DNS query tool
- **Purpose**: Troubleshoot DNS resolution issues

### **Lab 5: System Logging and Debugging**

**📋 Overview**: Master system logging and debugging techniques.

**🔍 Detailed Command Analysis**:

```bash
# View system logs
journalctl -f
tail -f /var/log/syslog
```

**Explanation**:
- `journalctl -f`: Follow systemd journal logs in real-time
- `tail -f /var/log/syslog`: Follow system log file in real-time
- **Purpose**: Monitor system events and application logs

```bash
# Check specific service logs
journalctl -u docker.service
journalctl -u kubelet.service
```

**Explanation**:
- `journalctl -u docker.service`: View Docker service logs
- `journalctl -u kubelet.service`: View Kubernetes kubelet service logs
- **Purpose**: Debug specific service issues

```bash
# Use strace for debugging
strace -p $(pgrep -f "uvicorn")
```

**Explanation**:
- `strace -p $(pgrep -f "uvicorn")`: Trace system calls for uvicorn process
- `$(pgrep -f "uvicorn")`: Command substitution to get process ID
- **Purpose**: Debug application behavior at system call level

```bash
# Check file descriptors
lsof -p $(pgrep -f "uvicorn")
```

**Explanation**:
- `lsof -p $(pgrep -f "uvicorn")`: List open files for uvicorn process
- **Purpose**: Debug file access issues and resource leaks

---

## 🎯 **Practice Problems**

### **Problem 1: System Resource Monitoring**

**Scenario**: Your e-commerce application is experiencing performance issues. Monitor system resources.

**Requirements**:
1. Monitor CPU and memory usage
2. Identify resource-intensive processes
3. Check disk I/O performance
4. Analyze network connections

**Expected Output**:
- System resource analysis report
- Process identification and recommendations
- Performance optimization suggestions

### **Problem 2: File System Management**

**Scenario**: Set up proper file permissions and directory structure for your e-commerce application.

**Requirements**:
1. Create secure directory structure
2. Set appropriate file permissions
3. Implement backup procedures
4. Monitor disk usage

**Expected Output**:
- Secure directory structure
- Permission configuration
- Backup script
- Disk usage monitoring setup

### **Problem 3: Network Troubleshooting**

**Scenario**: Your e-commerce application cannot connect to external APIs.

**Requirements**:
1. Test network connectivity
2. Check DNS resolution
3. Analyze firewall rules
4. Debug network configuration

**Expected Output**:
- Network connectivity test results
- DNS resolution analysis
- Firewall configuration
- Troubleshooting documentation

### **Problem 4: Chaos Engineering Scenarios**

**Scenario**: Test your e-commerce application's resilience to system failures.

**Requirements**:
1. **System Resource Exhaustion**:
   - Simulate high CPU usage
   - Test memory pressure scenarios
   - Monitor application behavior

2. **Process Failure Testing**:
   - Kill application processes
   - Test restart mechanisms
   - Monitor recovery time

3. **File System Corruption Simulation**:
   - Test file access failures
   - Verify data integrity
   - Test recovery procedures

4. **Network Interface Failures**:
   - Simulate network disconnections
   - Test failover mechanisms
   - Monitor application resilience

**Expected Output**:
- Chaos engineering test results
- Failure mode analysis
- Recovery time measurements
- Resilience improvement recommendations

---

## 📝 **Assessment Quiz**

### **Multiple Choice Questions**

1. **What command displays all running processes with detailed information?**
   - A) `ps aux`
   - B) `top`
   - C) `htop`
   - D) All of the above

2. **What does `chmod 755` set for file permissions?**
   - A) Owner: read/write/execute, Group: read/write, Others: read/write
   - B) Owner: read/write/execute, Group: read/execute, Others: read/execute
   - C) Owner: read/write, Group: read/execute, Others: read/execute
   - D) Owner: read/write/execute, Group: read/write/execute, Others: read/write/execute

3. **Which command is the modern replacement for `netstat`?**
   - A) `ss`
   - B) `ip`
   - C) `curl`
   - D) `dig`

### **Practical Questions**

4. **Explain the difference between `ps aux` and `htop`.**

5. **How would you troubleshoot a network connectivity issue?**

6. **What is the purpose of `strace` and when would you use it?**

---

## 🚀 **Mini-Project: E-commerce System Administration**

### **Project Requirements**

Set up comprehensive system administration for your e-commerce application:

1. **System Monitoring Setup**
   - Configure system resource monitoring
   - Set up log aggregation
   - Implement performance monitoring
   - Create alerting mechanisms

2. **Security Hardening**
   - Configure file permissions
   - Set up user access controls
   - Implement firewall rules
   - Configure system security

3. **Backup and Recovery**
   - Implement automated backups
   - Test recovery procedures
   - Set up data integrity checks
   - Configure disaster recovery

4. **Chaos Engineering Implementation**
   - Design system failure scenarios
   - Implement resilience testing
   - Create monitoring and alerting
   - Document failure modes and recovery procedures

### **Deliverables**

- **System Monitoring Dashboard**: Real-time system resource monitoring
- **Security Configuration**: Hardened system configuration
- **Backup Procedures**: Automated backup and recovery system
- **Chaos Engineering Report**: System resilience testing results
- **Documentation**: Complete system administration guide

---

## 🎤 **Interview Questions and Answers**

### **Q1: How would you monitor system resources on a Linux server?**

**Answer**:
System resource monitoring involves multiple tools and approaches:

1. **Real-time Monitoring**:
```bash
# CPU and memory usage
htop
top

# Memory usage
free -h

# Disk usage
df -h
du -sh *
```

2. **Process Monitoring**:
```bash
# Find resource-intensive processes
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

3. **I/O Monitoring**:
```bash
# Install iotop for I/O monitoring
sudo apt install iotop
iotop
```

4. **Network Monitoring**:
```bash
# Network connections
ss -tulpn
netstat -i
```

**Best Practices**:
- Set up automated monitoring with tools like Prometheus
- Configure alerts for resource thresholds
- Use log aggregation for historical analysis
- Implement capacity planning based on trends

### **Q2: How would you troubleshoot a performance issue in a Linux system?**

**Answer**:
Systematic troubleshooting approach:

1. **Identify the Problem**:
```bash
# Check system load
uptime
w

# Check resource usage
htop
free -h
df -h
```

2. **Analyze Processes**:
```bash
# Find resource-intensive processes
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# Check process details
top -p <PID>
```

3. **Check System Logs**:
```bash
# System logs
journalctl -f
tail -f /var/log/syslog

# Application logs
journalctl -u <service-name>
```

4. **Network Analysis**:
```bash
# Network connections
ss -tulpn
netstat -i

# Network traffic
iftop
nethogs
```

5. **I/O Analysis**:
```bash
# Disk I/O
iotop
iostat -x 1

# File system
lsof | grep <process-name>
```

**Common Issues and Solutions**:
- **High CPU**: Check for runaway processes, optimize code
- **Memory Issues**: Check for memory leaks, adjust swap
- **Disk I/O**: Check for disk space, optimize I/O operations
- **Network Issues**: Check connectivity, analyze traffic patterns

### **Q3: How would you secure a Linux system for production use?**

**Answer**:
Comprehensive security hardening approach:

1. **System Updates**:
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Enable automatic security updates
sudo apt install unattended-upgrades
```

2. **User Management**:
```bash
# Create dedicated users
sudo useradd -m -s /bin/bash appuser
sudo usermod -aG docker appuser

# Configure sudo access
sudo visudo
```

3. **File Permissions**:
```bash
# Set secure permissions
chmod 755 /home/appuser
chmod 600 /home/appuser/.ssh/authorized_keys
chmod 644 /etc/ssl/certs/*
```

4. **Firewall Configuration**:
```bash
# Install and configure UFW
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

5. **SSH Security**:
```bash
# Edit SSH configuration
sudo nano /etc/ssh/sshd_config

# Disable root login
PermitRootLogin no

# Use key-based authentication
PasswordAuthentication no
PubkeyAuthentication yes
```

6. **System Monitoring**:
```bash
# Install fail2ban
sudo apt install fail2ban

# Configure log monitoring
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**Additional Security Measures**:
- Regular security audits
- Intrusion detection systems
- File integrity monitoring
- Network segmentation
- Regular backups and testing

---

## 📈 **Real-world Scenarios**

### **Scenario 1: Production Server Performance Issue**

**Challenge**: Your e-commerce application server is experiencing slow response times.

**Requirements**:
- Diagnose the performance bottleneck
- Implement monitoring solution
- Optimize system configuration
- Set up alerting

**Solution Approach**:
1. Use `htop`, `iotop`, and `ss` to identify bottlenecks
2. Implement Prometheus and Grafana for monitoring
3. Optimize system parameters and application configuration
4. Set up automated alerting for future issues

### **Scenario 2: Security Incident Response**

**Challenge**: Suspicious activity detected on your e-commerce server.

**Requirements**:
- Investigate the security incident
- Implement security hardening
- Set up monitoring and alerting
- Document incident response procedures

**Solution Approach**:
1. Analyze system logs and network connections
2. Implement comprehensive security hardening
3. Set up intrusion detection and monitoring
4. Create incident response playbook

---

## 🎯 **Module Completion Checklist**

### **Core Linux Administration**
- [ ] Master essential Linux commands
- [ ] Understand process management
- [ ] Learn file system operations
- [ ] Master network configuration
- [ ] Understand system logging

### **System Monitoring**
- [ ] Set up resource monitoring
- [ ] Configure log aggregation
- [ ] Implement performance monitoring
- [ ] Create alerting mechanisms
- [ ] Monitor system health

### **Security and Hardening**
- [ ] Configure file permissions
- [ ] Set up user access controls
- [ ] Implement firewall rules
- [ ] Configure system security
- [ ] Test security measures

### **Chaos Engineering**
- [ ] Implement system resource exhaustion testing
- [ ] Test process failure scenarios
- [ ] Simulate file system corruption
- [ ] Test network interface failures
- [ ] Document failure modes and recovery procedures

### **Assessment and Practice**
- [ ] Complete all practice problems
- [ ] Pass assessment quiz
- [ ] Complete mini-project
- [ ] Answer interview questions correctly
- [ ] Apply concepts to real-world scenarios

---

## 📚 **Additional Resources**

### **Documentation**
- [Linux System Administration Guide](https://www.tldp.org/LDP/sag/html/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [systemd Documentation](https://systemd.io/)
- [Linux Performance Tools](http://www.brendangregg.com/linuxperf.html)

### **Tools**
- [htop Process Viewer](https://htop.dev/)
- [iotop I/O Monitor](https://github.com/Tomas-M/iotop)
- [strace System Call Tracer](https://strace.io/)
- [lsof File Monitor](https://github.com/lsof-org/lsof)

### **Practice Platforms**
- [Linux Academy](https://linuxacademy.com/)
- [Linux Foundation Training](https://training.linuxfoundation.org/)
- [Red Hat Learning](https://www.redhat.com/en/services/training)

---

## 🚀 **Next Steps**

1. **Complete this module** by working through all labs and assessments
2. **Practice Linux commands** on your local system
3. **Set up monitoring** for your e-commerce application
4. **Move to Module 3**: Networking Fundamentals
5. **Prepare for Kubernetes** by understanding Linux system administration

---

**Congratulations! You've completed the Linux System Administration module. You now have essential Linux skills for Kubernetes administration. 🎉**
