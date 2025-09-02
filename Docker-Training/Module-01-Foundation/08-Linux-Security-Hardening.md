# 🔒 Linux Security & Hardening: Complete Guide for Docker

## 🎯 Learning Objectives
- Master Linux security fundamentals
- Understand user and permission management
- Learn system hardening techniques
- Prepare for Docker container security

---

## 👥 User Management & Security

### Understanding Linux Users

#### User Types
```bash
# System users (UID 0-999)
cat /etc/passwd | grep -E "^(root|daemon|bin|sys)"

# Regular users (UID 1000+)
cat /etc/passwd | awk -F: '$3 >= 1000 {print $1 ":" $3}'

# Service users (for applications)
cat /etc/passwd | grep -E "(nginx|www-data|mysql|postgres)"
```

**Expected Output:**
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin

user:1000
dockeruser:1001

nginx:x:33:33:www-data:/var/www:/usr/sbin/nologin
mysql:x:27:27:MySQL Server:/var/lib/mysql:/bin/false
```

#### User Creation and Management
```bash
# Create system user (for services)
sudo useradd -r -s /usr/sbin/nologin -d /var/lib/myapp myapp

# Create regular user
sudo useradd -m -s /bin/bash -G sudo newuser

# Set password
sudo passwd newuser

# Modify user properties
sudo usermod -aG docker newuser  # Add to group
sudo usermod -s /bin/zsh newuser  # Change shell
sudo usermod -l newname oldname   # Rename user

# Delete user
sudo userdel -r username  # Remove user and home directory
```

**User Creation Options:**
- `-r`: Create system user
- `-m`: Create home directory
- `-s`: Set shell
- `-G`: Add to supplementary groups
- `-d`: Set home directory
- `-u`: Set specific UID

### Group Management
```bash
# Create group
sudo groupadd developers
sudo groupadd -g 2000 docker-users  # Specific GID

# Add user to group
sudo usermod -aG developers username
sudo gpasswd -a username developers  # Alternative method

# Remove user from group
sudo gpasswd -d username developers

# List group members
getent group developers
grep developers /etc/group

# Delete group
sudo groupdel developers
```

### Password Security
```bash
# Password policies
sudo nano /etc/login.defs

# Key settings:
PASS_MAX_DAYS   90    # Password expires after 90 days
PASS_MIN_DAYS   7     # Minimum days between password changes
PASS_WARN_AGE   7     # Warning days before expiration
PASS_MIN_LEN    8     # Minimum password length

# Check password status
sudo passwd -S username
sudo chage -l username

# Force password change on next login
sudo passwd -e username

# Lock/unlock user account
sudo passwd -l username  # Lock
sudo passwd -u username  # Unlock
```

---

## 🔐 File Permissions & Access Control

### Standard Permissions Deep Dive

#### Permission Types
```bash
# Read (r) = 4, Write (w) = 2, Execute (x) = 1
# Owner, Group, Others

# Examples
ls -la /etc/passwd
# -rw-r--r-- 1 root root 2969 Jan 15 10:30 /etc/passwd
# Owner: rw- (6), Group: r-- (4), Others: r-- (4) = 644

ls -la /usr/bin/sudo
# -rwsr-xr-x 1 root root 166056 Jan 19  2021 /usr/bin/sudo
# s = setuid bit, allows execution as owner (root)
```

#### Changing Permissions
```bash
# Numeric method
chmod 755 script.sh    # rwxr-xr-x
chmod 644 config.txt   # rw-r--r--
chmod 600 private.key  # rw-------

# Symbolic method
chmod u+x script.sh    # Add execute for owner
chmod g-w file.txt     # Remove write for group
chmod o-r secret.txt   # Remove read for others
chmod a+r public.txt   # Add read for all

# Recursive permissions
chmod -R 755 /var/www/html/
find /var/www -type f -exec chmod 644 {} \;  # Files
find /var/www -type d -exec chmod 755 {} \;  # Directories
```

#### Special Permissions
```bash
# Setuid (4000) - Execute as file owner
chmod 4755 /usr/bin/passwd
ls -la /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 Jul 15  2021 /usr/bin/passwd

# Setgid (2000) - Execute as file group
chmod 2755 /usr/bin/wall
ls -la /usr/bin/wall
# -rwxr-sr-x 1 root tty 19048 Apr 16  2020 /usr/bin/wall

# Sticky bit (1000) - Only owner can delete
chmod 1777 /tmp
ls -ld /tmp
# drwxrwxrwt 15 root root 4096 Jan 15 10:30 /tmp
```

### Access Control Lists (ACLs)
```bash
# Check if filesystem supports ACLs
mount | grep acl
tune2fs -l /dev/sda1 | grep acl

# Install ACL tools
sudo apt install acl

# Set ACL permissions
setfacl -m u:username:rwx /path/to/file
setfacl -m g:groupname:rx /path/to/directory
setfacl -R -m u:nginx:rx /var/www/html/

# View ACL permissions
getfacl /path/to/file

# Remove ACL permissions
setfacl -x u:username /path/to/file
setfacl -b /path/to/file  # Remove all ACLs
```

**Expected ACL Output:**
```
# file: /var/www/html/index.html
# owner: root
# group: root
user::rw-
user:nginx:r--
group::r--
mask::r--
other::r--
```

---

## 🛡️ System Hardening

### Service Management & Security
```bash
# List all services
systemctl list-units --type=service
systemctl list-unit-files --type=service

# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl stop bluetooth cups avahi-daemon

# Check service status
systemctl status ssh
systemctl is-enabled ssh
systemctl is-active ssh

# Secure SSH configuration
sudo nano /etc/ssh/sshd_config
```

**SSH Hardening Configuration:**
```bash
# /etc/ssh/sshd_config security settings
Port 2222                    # Change default port
PermitRootLogin no          # Disable root login
PasswordAuthentication no   # Use key-based auth only
PubkeyAuthentication yes    # Enable key authentication
MaxAuthTries 3              # Limit login attempts
ClientAliveInterval 300     # Timeout idle connections
ClientAliveCountMax 2       # Max idle timeouts
AllowUsers username         # Restrict user access
Protocol 2                  # Use SSH protocol 2 only

# Restart SSH service
sudo systemctl restart sshd
```

### Firewall Configuration (UFW)
```bash
# Install and enable UFW
sudo apt install ufw
sudo ufw enable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow specific services
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 192.168.1.0/24 to any port 22

# Allow Docker (if needed)
sudo ufw allow 2376/tcp  # Docker daemon
sudo ufw allow 2377/tcp  # Docker swarm
sudo ufw allow 7946      # Docker overlay network

# Check firewall status
sudo ufw status verbose
sudo ufw status numbered

# Remove rules
sudo ufw delete 2
sudo ufw delete allow 80/tcp
```

**Expected UFW Output:**
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
```

### System Updates & Package Security
```bash
# Update package database
sudo apt update

# List available updates
apt list --upgradable

# Upgrade all packages
sudo apt upgrade -y

# Upgrade with new dependencies
sudo apt full-upgrade -y

# Remove unnecessary packages
sudo apt autoremove -y
sudo apt autoclean

# Check for security updates only
sudo unattended-upgrades --dry-run

# Configure automatic security updates
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

**Automatic Updates Configuration:**
```bash
# /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

---

## 🔍 Security Monitoring & Auditing

### System Logging
```bash
# View system logs
journalctl -f                    # Follow all logs
journalctl -u ssh               # SSH service logs
journalctl -p err               # Error level logs only
journalctl --since "1 hour ago" # Recent logs

# Authentication logs
sudo tail -f /var/log/auth.log
grep "Failed password" /var/log/auth.log
grep "Accepted password" /var/log/auth.log

# System logs
sudo tail -f /var/log/syslog
dmesg | tail -20  # Kernel messages
```

### Failed Login Monitoring
```bash
# Check failed login attempts
sudo lastb | head -20

# Check successful logins
last | head -20

# Current logged-in users
who
w

# Login history for specific user
last username
```

### Process Monitoring
```bash
# Monitor running processes
ps aux --sort=-%cpu | head -10  # Top CPU users
ps aux --sort=-%mem | head -10  # Top memory users

# Monitor system resources
top -d 1
htop

# Check for suspicious processes
ps aux | grep -E "(nc|netcat|nmap|tcpdump)"
netstat -tlnp | grep LISTEN
ss -tlnp | grep LISTEN
```

### File Integrity Monitoring
```bash
# Install AIDE (Advanced Intrusion Detection Environment)
sudo apt install aide

# Initialize AIDE database
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Check file integrity
sudo aide --check

# Update database after legitimate changes
sudo aide --update
```

---

## 🔐 Container Security Preparation

### Docker Security Fundamentals
```bash
# Create non-root user for containers
sudo useradd -r -s /usr/sbin/nologin -u 1001 containeruser

# Set up directory with proper permissions
sudo mkdir -p /opt/containers/app
sudo chown -R containeruser:containeruser /opt/containers/app
sudo chmod 755 /opt/containers/app

# Test user switching
sudo -u containeruser whoami
sudo -u containeruser id
```

### Security Scanning Tools
```bash
# Install security scanning tools
sudo apt install -y \
    lynis \      # Security auditing
    chkrootkit \ # Rootkit detection
    rkhunter \   # Rootkit hunter
    clamav       # Antivirus

# Update virus definitions
sudo freshclam

# Run security audit
sudo lynis audit system

# Check for rootkits
sudo chkrootkit
sudo rkhunter --check
```

### AppArmor/SELinux Basics
```bash
# Check AppArmor status (Ubuntu/Debian)
sudo apparmor_status

# List AppArmor profiles
sudo aa-status

# Check SELinux status (CentOS/RHEL)
sestatus
getenforce

# View SELinux contexts
ls -Z /etc/passwd
ps auxZ | head -5
```

---

## 🚨 Incident Response & Recovery

### System Backup Strategies
```bash
# Create system backup script
sudo tee /usr/local/bin/system-backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup critical system files
tar -czf $BACKUP_DIR/etc-backup.tar.gz /etc/
tar -czf $BACKUP_DIR/home-backup.tar.gz /home/
tar -czf $BACKUP_DIR/var-log-backup.tar.gz /var/log/

# Backup package list
dpkg --get-selections > $BACKUP_DIR/package-list.txt

# Backup user accounts
cp /etc/passwd $BACKUP_DIR/
cp /etc/group $BACKUP_DIR/
cp /etc/shadow $BACKUP_DIR/

echo "Backup completed: $BACKUP_DIR"
EOF

sudo chmod +x /usr/local/bin/system-backup.sh
```

### Emergency Access & Recovery
```bash
# Create emergency user account
sudo useradd -m -s /bin/bash -G sudo emergency
sudo passwd emergency

# Set up SSH key for emergency access
sudo mkdir -p /home/emergency/.ssh
sudo chmod 700 /home/emergency/.ssh
sudo chown emergency:emergency /home/emergency/.ssh

# Create recovery script
sudo tee /usr/local/bin/emergency-recovery.sh << 'EOF'
#!/bin/bash
echo "=== Emergency System Recovery ==="
echo "1. Check system status"
systemctl status
df -h
free -h

echo "2. Check critical services"
systemctl status ssh docker nginx

echo "3. Check network connectivity"
ping -c 3 8.8.8.8

echo "4. Check recent logs"
journalctl --since "1 hour ago" -p err
EOF

sudo chmod +x /usr/local/bin/emergency-recovery.sh
```

---

## 🔧 Security Automation Scripts

### Security Monitoring Script
```bash
# Create comprehensive security monitoring script
sudo tee /usr/local/bin/security-monitor.sh << 'EOF'
#!/bin/bash

LOG_FILE="/var/log/security-monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

log_message() {
    echo "[$DATE] $1" | sudo tee -a $LOG_FILE
}

# Check for failed login attempts
FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | wc -l)
if [ $FAILED_LOGINS -gt 10 ]; then
    log_message "WARNING: $FAILED_LOGINS failed login attempts detected"
fi

# Check for new users
NEW_USERS=$(find /home -maxdepth 1 -type d -mtime -1 | wc -l)
if [ $NEW_USERS -gt 0 ]; then
    log_message "INFO: $NEW_USERS new user directories created"
fi

# Check disk usage
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    log_message "CRITICAL: Disk usage at $DISK_USAGE%"
fi

# Check for suspicious processes
SUSPICIOUS=$(ps aux | grep -E "(nc|netcat|nmap)" | grep -v grep | wc -l)
if [ $SUSPICIOUS -gt 0 ]; then
    log_message "WARNING: Suspicious processes detected"
fi

# Check system load
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
if (( $(echo "$LOAD > 5.0" | bc -l) )); then
    log_message "WARNING: High system load: $LOAD"
fi

log_message "Security check completed"
EOF

sudo chmod +x /usr/local/bin/security-monitor.sh

# Add to crontab for regular execution
echo "*/15 * * * * /usr/local/bin/security-monitor.sh" | sudo crontab -
```

### System Hardening Script
```bash
# Create system hardening script
sudo tee /usr/local/bin/harden-system.sh << 'EOF'
#!/bin/bash

echo "=== System Hardening Script ==="

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y

# Remove unnecessary packages
echo "Removing unnecessary packages..."
apt autoremove -y

# Configure SSH security
echo "Hardening SSH configuration..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure firewall
echo "Configuring firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp  # SSH on custom port

# Set file permissions
echo "Setting secure file permissions..."
chmod 600 /etc/ssh/sshd_config
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group

# Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable bluetooth
systemctl disable cups
systemctl stop bluetooth cups

echo "System hardening completed!"
echo "IMPORTANT: SSH is now on port 2222"
echo "Connect with: ssh -p 2222 username@server"
EOF

sudo chmod +x /usr/local/bin/harden-system.sh
```

---

## 🧪 Security Testing & Validation

### Security Audit Commands
```bash
# Run comprehensive security audit
sudo lynis audit system --quick

# Check for world-writable files
find / -type f -perm -002 2>/dev/null | head -20

# Check for files with no owner
find / -nouser -o -nogroup 2>/dev/null | head -20

# Check for SUID/SGID files
find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null

# Check open ports
netstat -tlnp
ss -tlnp

# Check running services
systemctl list-units --type=service --state=running
```

### Password Security Testing
```bash
# Install password cracking tools (for testing)
sudo apt install john hashcat

# Test password strength
echo "password123" | pwscore

# Check for weak passwords (use carefully)
sudo john --wordlist=/usr/share/wordlists/rockyou.txt /etc/shadow
```

### Network Security Testing
```bash
# Install network security tools
sudo apt install nmap nikto

# Scan local system (self-test only)
nmap -sS -O localhost
nmap -sV -p 1-1000 localhost

# Check for open ports
nmap -p- localhost

# Web vulnerability scan (if web server running)
nikto -h http://localhost
```

---

## 🚀 Next Steps

You now have comprehensive Linux security knowledge:

- ✅ **User Management**: Account creation, groups, password policies
- ✅ **File Permissions**: Standard and advanced ACL permissions
- ✅ **System Hardening**: Service management, firewall, SSH security
- ✅ **Security Monitoring**: Logging, auditing, intrusion detection
- ✅ **Container Security**: Preparation for Docker security practices
- ✅ **Automation**: Security monitoring and hardening scripts

**Ready for Module 1, Part 9: Scripting & Automation** where you'll master bash scripting for Docker automation!
