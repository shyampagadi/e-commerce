# 🛠️ Command Line Practice: Hands-On Mastery

## 🎯 Learning Objectives
By the end of this section, you will have:
- Mastered essential command line operations through practice
- Built muscle memory for common command patterns
- Developed troubleshooting skills for command line issues
- Created real projects that demonstrate your skills

---

## 🏃‍♂️ Practice Session 1: Basic Navigation and File Operations

### Exercise 1.1: Directory Navigation Mastery

#### **Objective:** Master directory navigation and understand your file system

#### **Step-by-Step Instructions:**

##### Step 1: Understand Your Starting Point
```bash
# Find out where you are
pwd
```

**Expected Output:**
```
/home/username  # Linux/Mac
C:\Users\Username  # Windows
```

**What this tells you:** `pwd` (Print Working Directory) shows your current location in the file system. This is your "you are here" marker.

##### Step 2: Explore Your Home Directory
```bash
# List contents of current directory
ls
# On Windows: dir
```

**Expected Output:**
```
Desktop    Documents    Downloads    Pictures    Videos
```

**What this tells you:** These are the standard folders in your home directory. Each operating system organizes them slightly differently.

##### Step 3: Detailed Directory Listing
```bash
# List with detailed information
ls -la
# On Windows: dir /a
```

**Expected Output:**
```
drwxr-xr-x  2 user user 4096 Jan 15 10:30 Desktop
drwxr-xr-x  2 user user 4096 Jan 15 10:30 Documents
-rw-r--r--  1 user user  156 Jan 15 09:45 .bashrc
```

**Understanding the Output:**
- First character: `d` = directory, `-` = file
- Next 9 characters: Permissions (read, write, execute for owner, group, others)
- Numbers: Links, owner, group, size, date, name
- Files starting with `.` are hidden files

##### Step 4: Navigate to Different Directories
```bash
# Go to Documents folder
cd Documents

# Verify you moved
pwd

# Go back to parent directory
cd ..

# Verify you're back
pwd

# Go to home directory (multiple ways)
cd ~
cd $HOME
cd  # (just cd with no arguments)
```

**What each command does:**
- `cd Documents`: Move into the Documents subdirectory
- `cd ..`: Move up one level in the directory tree
- `cd ~`: Go to your home directory (~ is a shortcut for home)

#### **Practice Challenge 1.1:** Navigation Speed Test
Create this directory structure and navigate through it efficiently:
```
practice/
├── project1/
│   ├── src/
│   └── docs/
├── project2/
│   ├── src/
│   └── tests/
└── shared/
    ├── configs/
    └── scripts/
```

**Solution:**
```bash
# Create the entire structure
mkdir -p practice/{project1/{src,docs},project2/{src,tests},shared/{configs,scripts}}

# Navigate efficiently
cd practice
cd project1/src
cd ../../project2/tests
cd ../..
cd shared/configs
```

### Exercise 1.2: File Creation and Manipulation

#### **Objective:** Master file operations with detailed understanding

##### Step 1: Create Files Using Different Methods
```bash
# Method 1: Touch command (creates empty file)
touch empty-file.txt

# Method 2: Echo command (creates file with content)
echo "Hello World" > greeting.txt

# Method 3: Cat command with redirection
cat > story.txt << 'EOF'
Once upon a time, there was a developer
who wanted to learn Docker.
They started with the command line
and lived happily ever after.
EOF
```

**Detailed Explanation:**
- `touch`: Creates empty file or updates timestamp of existing file
- `echo "text" >`: Creates file with specified text (overwrites if exists)
- `cat > file << 'EOF'`: Creates multi-line file (type content, end with EOF)

##### Step 2: View File Contents
```bash
# View entire file
cat greeting.txt

# View file page by page (for large files)
less story.txt
# Press 'q' to quit, 'space' for next page, 'b' for previous page

# View first few lines
head story.txt

# View last few lines
tail story.txt

# View specific number of lines
head -n 2 story.txt
tail -n 1 story.txt
```

**When to use each:**
- `cat`: Small files you want to see completely
- `less`: Large files you want to browse through
- `head`: Check the beginning of files (useful for CSV headers, log files)
- `tail`: Check the end of files (useful for recent log entries)

##### Step 3: Copy and Move Files
```bash
# Copy file
cp greeting.txt greeting-backup.txt

# Copy with verbose output (see what's happening)
cp -v story.txt story-backup.txt

# Move/rename file
mv greeting-backup.txt hello-backup.txt

# Move file to different directory
mkdir backups
mv hello-backup.txt backups/
```

**Understanding the difference:**
- `cp`: Creates a duplicate, original remains
- `mv`: Moves the file, original location is empty
- Moving to same directory = renaming
- Moving to different directory = relocating

#### **Practice Challenge 1.2:** File Management Project
Create a project structure for a web application:

**Requirements:**
1. Create directories: `webapp/{frontend,backend,database,docs}`
2. Create files in each directory with appropriate content
3. Create backup copies of important files
4. Organize files logically

**Detailed Solution:**
```bash
# Step 1: Create directory structure
mkdir -p webapp/{frontend,backend,database,docs}

# Step 2: Create frontend files
cd webapp/frontend
echo "<!DOCTYPE html><html><head><title>My App</title></head><body><h1>Welcome</h1></body></html>" > index.html
echo "body { font-family: Arial; margin: 40px; }" > style.css
echo "console.log('App loaded');" > app.js

# Step 3: Create backend files
cd ../backend
echo "from flask import Flask; app = Flask(__name__)" > app.py
echo "flask==2.0.1" > requirements.txt

# Step 4: Create database files
cd ../database
echo "CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(100));" > schema.sql
echo "INSERT INTO users VALUES (1, 'John Doe');" > seed.sql

# Step 5: Create documentation
cd ../docs
echo "# Web Application Documentation" > README.md
echo "## Setup Instructions" >> README.md
echo "1. Install dependencies" >> README.md
echo "2. Run the application" >> README.md

# Step 6: Create backups
cd ..
cp -r frontend frontend-backup
cp backend/requirements.txt backend/requirements-backup.txt

# Step 7: Verify structure
find . -type f | sort
```

---

## 🔍 Practice Session 2: Text Processing and Search

### Exercise 2.1: Searching and Filtering

#### **Objective:** Master text search and filtering techniques

##### Step 1: Create Sample Data
```bash
# Create a sample log file
cat > application.log << 'EOF'
2024-01-15 10:00:01 INFO Application started
2024-01-15 10:00:02 DEBUG Loading configuration
2024-01-15 10:00:03 INFO Database connected
2024-01-15 10:01:15 WARN Slow query detected: SELECT * FROM users
2024-01-15 10:01:16 ERROR Database connection lost
2024-01-15 10:01:17 INFO Attempting to reconnect
2024-01-15 10:01:18 INFO Database reconnected
2024-01-15 10:02:30 ERROR Invalid user input: email format
2024-01-15 10:03:45 INFO User logged in: john@example.com
2024-01-15 10:04:12 WARN Memory usage high: 85%
2024-01-15 10:05:01 INFO User logged out: john@example.com
EOF
```

##### Step 2: Basic Search Operations
```bash
# Find all ERROR messages
grep "ERROR" application.log
```

**Expected Output:**
```
2024-01-15 10:01:16 ERROR Database connection lost
2024-01-15 10:02:30 ERROR Invalid user input: email format
```

**What happened:** `grep` searched through the file line by line and returned only lines containing "ERROR".

```bash
# Case-insensitive search
grep -i "error" application.log

# Show line numbers
grep -n "ERROR" application.log

# Count occurrences
grep -c "ERROR" application.log
```

**Detailed Explanation:**
- `-i`: Ignore case (ERROR, error, Error all match)
- `-n`: Show line numbers where matches occur
- `-c`: Count how many lines match (just the number)

##### Step 3: Advanced Search Patterns
```bash
# Search for lines starting with specific pattern
grep "^2024-01-15 10:01" application.log

# Search for lines ending with specific pattern
grep "connected$" application.log

# Search for multiple patterns
grep -E "(ERROR|WARN)" application.log

# Invert search (show lines that DON'T match)
grep -v "INFO" application.log
```

**Pattern Explanation:**
- `^`: Beginning of line
- `$`: End of line
- `-E`: Extended regex (allows | for OR)
- `-v`: Invert match (show non-matching lines)

#### **Practice Challenge 2.1:** Log Analysis Project
Analyze the log file to answer these questions:

1. How many different log levels are there?
2. What time period does the log cover?
3. How many database-related events occurred?
4. Which user activities are logged?

**Detailed Solution:**
```bash
# Question 1: Different log levels
grep -o '\(INFO\|DEBUG\|WARN\|ERROR\)' application.log | sort | uniq
# Expected: DEBUG, ERROR, INFO, WARN

# Question 2: Time period
head -n 1 application.log | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'
tail -n 1 application.log | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]'
# Expected: 10:00:01 to 10:05:01

# Question 3: Database-related events
grep -i "database" application.log | wc -l
# Expected: 3

# Question 4: User activities
grep -i "user" application.log
# Expected: Login and logout events for john@example.com
```

### Exercise 2.2: Data Processing with Pipes

#### **Objective:** Master command chaining and data transformation

##### Step 1: Create Sample Data
```bash
# Create a CSV file with user data
cat > users.csv << 'EOF'
id,name,email,age,city
1,John Doe,john@example.com,25,New York
2,Jane Smith,jane@example.com,30,Los Angeles
3,Bob Johnson,bob@example.com,35,Chicago
4,Alice Brown,alice@example.com,28,Houston
5,Charlie Wilson,charlie@example.com,32,Phoenix
EOF
```

##### Step 2: Basic Data Processing
```bash
# View the data
cat users.csv

# Skip header and show just data
tail -n +2 users.csv

# Show only names and emails
cut -d',' -f2,3 users.csv

# Sort by age (4th column)
tail -n +2 users.csv | sort -t',' -k4 -n
```

**Command Breakdown:**
- `tail -n +2`: Start from line 2 (skip header)
- `cut -d',' -f2,3`: Cut using comma delimiter, show fields 2 and 3
- `sort -t',' -k4 -n`: Sort using comma delimiter, by column 4, numerically

##### Step 3: Complex Data Processing Chains
```bash
# Find users older than 30, show name and city, sort by name
tail -n +2 users.csv | \
awk -F',' '$4 > 30 {print $2 "," $5}' | \
sort

# Count users by city
tail -n +2 users.csv | \
cut -d',' -f5 | \
sort | \
uniq -c

# Find average age
tail -n +2 users.csv | \
cut -d',' -f4 | \
awk '{sum += $1; count++} END {print "Average age:", sum/count}'
```

**Advanced Explanation:**
- `awk -F','`: Use awk with comma field separator
- `$4 > 30`: Condition (4th field greater than 30)
- `{print $2 "," $5}`: Print 2nd and 5th fields
- `uniq -c`: Count unique occurrences
- `awk` with `END`: Perform calculation after processing all lines

#### **Practice Challenge 2.2:** Sales Data Analysis
Create and analyze a sales dataset:

**Requirements:**
1. Create sales data with: date, product, quantity, price, salesperson
2. Find top-selling products
3. Calculate total revenue by salesperson
4. Find sales trends by month

**Detailed Solution:**
```bash
# Step 1: Create sales data
cat > sales.csv << 'EOF'
date,product,quantity,price,salesperson
2024-01-15,Laptop,2,999.99,John
2024-01-16,Mouse,5,29.99,Jane
2024-01-17,Keyboard,3,79.99,John
2024-01-18,Laptop,1,999.99,Bob
2024-01-19,Monitor,2,299.99,Jane
2024-01-20,Mouse,8,29.99,Alice
2024-01-21,Laptop,3,999.99,Bob
2024-01-22,Keyboard,2,79.99,Alice
EOF

# Step 2: Top-selling products by quantity
echo "Top-selling products by quantity:"
tail -n +2 sales.csv | \
awk -F',' '{products[$2] += $3} END {for (p in products) print products[p], p}' | \
sort -nr | \
head -3

# Step 3: Total revenue by salesperson
echo "Total revenue by salesperson:"
tail -n +2 sales.csv | \
awk -F',' '{revenue[$5] += $3 * $4} END {for (s in revenue) printf "%s: $%.2f\n", s, revenue[s]}' | \
sort -k2 -nr

# Step 4: Sales trends (simplified - by day)
echo "Daily sales count:"
tail -n +2 sales.csv | \
cut -d',' -f1 | \
sort | \
uniq -c
```

---

## 🔧 Practice Session 3: Process Management and System Monitoring

### Exercise 3.1: Understanding Processes

#### **Objective:** Master process viewing and management

##### Step 1: View Running Processes
```bash
# Show all processes
ps aux

# Show processes in tree format
ps auxf
# On some systems: pstree

# Show only your processes
ps ux

# Show processes with specific name
ps aux | grep bash
```

**Understanding ps Output:**
```
USER  PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
john  1234  0.1  0.5  12345  6789 pts/0    S    10:30   0:01 bash
```

- **USER**: Who owns the process
- **PID**: Process ID (unique identifier)
- **%CPU**: CPU usage percentage
- **%MEM**: Memory usage percentage
- **VSZ**: Virtual memory size
- **RSS**: Resident memory size (actual RAM used)
- **TTY**: Terminal associated with process
- **STAT**: Process state (S=sleeping, R=running, Z=zombie)
- **START**: When process started
- **TIME**: Total CPU time used
- **COMMAND**: The actual command/program

##### Step 2: Real-Time Process Monitoring
```bash
# Real-time process monitor
top

# Enhanced process monitor (if available)
htop
```

**Using top effectively:**
- Press `q` to quit
- Press `k` to kill a process (enter PID)
- Press `M` to sort by memory usage
- Press `P` to sort by CPU usage
- Press `1` to show individual CPU cores

##### Step 3: Process Control
```bash
# Start a long-running process in background
sleep 300 &

# List background jobs
jobs

# Find the process ID
ps aux | grep sleep

# Bring background job to foreground
fg %1

# Send to background again (Ctrl+Z, then bg)
# Ctrl+Z (suspend)
bg %1

# Kill the process
kill %1
# or
kill PID_NUMBER
```

**Process States:**
- **Running**: Currently executing
- **Sleeping**: Waiting for something (input, timer, etc.)
- **Stopped**: Suspended (Ctrl+Z)
- **Zombie**: Finished but parent hasn't cleaned up

#### **Practice Challenge 3.1:** Process Investigation
Start multiple processes and practice managing them:

**Requirements:**
1. Start 3 different long-running processes
2. Monitor their resource usage
3. Practice moving between foreground/background
4. Clean up all processes

**Detailed Solution:**
```bash
# Step 1: Start multiple processes
sleep 600 &          # Process 1
ping google.com &     # Process 2 (Ctrl+C to stop later)
yes > /dev/null &     # Process 3 (generates continuous output)

# Step 2: Monitor processes
jobs                  # Show background jobs
ps aux | grep -E "(sleep|ping|yes)" | grep -v grep

# Step 3: Practice control
fg %1                 # Bring sleep to foreground
# Ctrl+Z               # Suspend it
bg %1                 # Send back to background

# Step 4: Monitor resources
top -p $(pgrep -d',' -f "sleep|ping|yes")

# Step 5: Clean up
kill %1 %2 %3         # Kill all background jobs
# or
killall sleep ping yes
```

### Exercise 3.2: System Resource Monitoring

#### **Objective:** Understand system resources and monitoring

##### Step 1: Memory Usage
```bash
# Show memory usage
free -h

# Detailed memory information
cat /proc/meminfo | head -10

# Show memory usage by process
ps aux --sort=-%mem | head -10
```

**Understanding free output:**
```
              total        used        free      shared  buff/cache   available
Mem:           8.0G        2.1G        3.2G        156M        2.7G        5.5G
Swap:          2.0G          0B        2.0G
```

- **total**: Total installed RAM
- **used**: RAM currently in use by programs
- **free**: Completely unused RAM
- **buff/cache**: RAM used for system caching (can be freed if needed)
- **available**: RAM available for new programs

##### Step 2: Disk Usage
```bash
# Show disk space usage
df -h

# Show directory sizes
du -h --max-depth=1

# Find largest files
find . -type f -exec ls -lh {} \; | sort -k5 -hr | head -10
```

**Understanding df output:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   15G  4.2G  79% /
```

- **Size**: Total disk space
- **Used**: Space currently occupied
- **Avail**: Space available for new files
- **Use%**: Percentage of space used
- **Mounted on**: Where this disk is accessible in file system

##### Step 3: Network Monitoring
```bash
# Show network interfaces
ip addr show
# or on older systems: ifconfig

# Show network connections
netstat -tuln
# or on newer systems: ss -tuln

# Monitor network traffic (if available)
iftop
# or
nethogs
```

**Understanding network output:**
- **-t**: TCP connections
- **-u**: UDP connections
- **-l**: Listening ports only
- **-n**: Show numbers instead of resolving names

#### **Practice Challenge 3.2:** System Health Check
Create a system monitoring script:

**Requirements:**
1. Check memory usage and alert if > 80%
2. Check disk usage and alert if > 90%
3. List top 5 CPU-consuming processes
4. Check if specific services are running

**Detailed Solution:**
```bash
#!/bin/bash
# System Health Check Script

echo "=== System Health Check ==="
echo "Date: $(date)"
echo

# Memory check
echo "=== Memory Usage ==="
memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
echo "Memory usage: ${memory_usage}%"
if [ $memory_usage -gt 80 ]; then
    echo "⚠️  WARNING: High memory usage!"
fi
echo

# Disk check
echo "=== Disk Usage ==="
df -h | grep -E '^/dev/' | while read line; do
    usage=$(echo $line | awk '{print $5}' | sed 's/%//')
    partition=$(echo $line | awk '{print $1}')
    echo "$partition: ${usage}%"
    if [ $usage -gt 90 ]; then
        echo "⚠️  WARNING: High disk usage on $partition!"
    fi
done
echo

# Top CPU processes
echo "=== Top 5 CPU Processes ==="
ps aux --sort=-%cpu | head -6 | tail -5
echo

# Service check (example services)
echo "=== Service Status ==="
services=("ssh" "cron" "systemd")
for service in "${services[@]}"; do
    if pgrep $service > /dev/null; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done
```

---

## 🎓 Comprehensive Practice Challenges

### Challenge 1: Log Analysis Automation

#### **Objective:** Create a comprehensive log analysis tool

#### **Requirements:**
1. Parse web server access logs
2. Extract statistics (top IPs, most requested pages, error rates)
3. Generate a summary report
4. Handle different log formats

#### **Sample Data Creation:**
```bash
# Create sample web server log
cat > access.log << 'EOF'
192.168.1.100 - - [15/Jan/2024:10:00:01 +0000] "GET / HTTP/1.1" 200 1234
192.168.1.101 - - [15/Jan/2024:10:00:02 +0000] "GET /about HTTP/1.1" 200 2345
192.168.1.100 - - [15/Jan/2024:10:00:03 +0000] "POST /login HTTP/1.1" 302 567
192.168.1.102 - - [15/Jan/2024:10:00:04 +0000] "GET /products HTTP/1.1" 200 3456
192.168.1.100 - - [15/Jan/2024:10:00:05 +0000] "GET /nonexistent HTTP/1.1" 404 123
192.168.1.103 - - [15/Jan/2024:10:00:06 +0000] "GET / HTTP/1.1" 200 1234
192.168.1.101 - - [15/Jan/2024:10:00:07 +0000] "GET /contact HTTP/1.1" 500 89
EOF
```

#### **Complete Solution:**
```bash
#!/bin/bash
# Web Log Analyzer

LOG_FILE="access.log"
echo "=== Web Server Log Analysis ==="
echo "Analyzing: $LOG_FILE"
echo "Generated: $(date)"
echo

# Total requests
total_requests=$(wc -l < $LOG_FILE)
echo "Total Requests: $total_requests"
echo

# Top 5 IP addresses
echo "=== Top 5 IP Addresses ==="
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -5 | \
while read count ip; do
    echo "$ip: $count requests"
done
echo

# Most requested pages
echo "=== Most Requested Pages ==="
awk '{print $7}' $LOG_FILE | sort | uniq -c | sort -nr | head -5 | \
while read count page; do
    echo "$page: $count requests"
done
echo

# HTTP status codes
echo "=== HTTP Status Codes ==="
awk '{print $9}' $LOG_FILE | sort | uniq -c | sort -nr | \
while read count status; do
    case $status in
        2*) status_type="Success" ;;
        3*) status_type="Redirect" ;;
        4*) status_type="Client Error" ;;
        5*) status_type="Server Error" ;;
        *) status_type="Unknown" ;;
    esac
    echo "$status ($status_type): $count"
done
echo

# Error rate
error_count=$(awk '$9 >= 400 {count++} END {print count+0}' $LOG_FILE)
error_rate=$(echo "scale=2; $error_count * 100 / $total_requests" | bc -l 2>/dev/null || echo "0")
echo "Error Rate: ${error_rate}% ($error_count errors out of $total_requests requests)"
echo

# Hourly traffic
echo "=== Hourly Traffic Distribution ==="
awk '{
    match($4, /\[.*:([0-9]{2}):/, hour)
    traffic[hour[1]]++
} END {
    for (h in traffic) printf "%02d:00 - %d requests\n", h, traffic[h]
}' $LOG_FILE | sort
```

### Challenge 2: System Backup Automation

#### **Objective:** Create an automated backup system

#### **Requirements:**
1. Backup specified directories
2. Compress backups
3. Rotate old backups (keep only last 5)
4. Log all operations
5. Send email notification (simulate)

#### **Complete Solution:**
```bash
#!/bin/bash
# Automated Backup System

# Configuration
BACKUP_SOURCE="/home/user/important-data"
BACKUP_DEST="/backup"
LOG_FILE="/var/log/backup.log"
MAX_BACKUPS=5
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Function to send notification (simulated)
send_notification() {
    local status=$1
    local message=$2
    log_message "NOTIFICATION: $status - $message"
    # In real scenario: mail -s "Backup $status" admin@company.com <<< "$message"
}

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DEST

log_message "Starting backup process"

# Check if source directory exists
if [ ! -d "$BACKUP_SOURCE" ]; then
    log_message "ERROR: Source directory $BACKUP_SOURCE does not exist"
    send_notification "FAILED" "Source directory not found"
    exit 1
fi

# Create backup
log_message "Creating backup: $BACKUP_NAME"
if tar -czf "$BACKUP_DEST/$BACKUP_NAME" -C "$(dirname $BACKUP_SOURCE)" "$(basename $BACKUP_SOURCE)" 2>>$LOG_FILE; then
    backup_size=$(du -h "$BACKUP_DEST/$BACKUP_NAME" | cut -f1)
    log_message "Backup created successfully: $backup_size"
else
    log_message "ERROR: Backup creation failed"
    send_notification "FAILED" "Backup creation failed"
    exit 1
fi

# Rotate old backups
log_message "Rotating old backups (keeping last $MAX_BACKUPS)"
cd $BACKUP_DEST
backup_count=$(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)

if [ $backup_count -gt $MAX_BACKUPS ]; then
    old_backups=$(ls -1t backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)))
    for old_backup in $old_backups; do
        log_message "Removing old backup: $old_backup"
        rm -f "$old_backup"
    done
fi

# Generate backup report
log_message "Generating backup report"
echo "=== Backup Report ===" > /tmp/backup_report.txt
echo "Date: $(date)" >> /tmp/backup_report.txt
echo "Backup Name: $BACKUP_NAME" >> /tmp/backup_report.txt
echo "Backup Size: $backup_size" >> /tmp/backup_report.txt
echo "Source: $BACKUP_SOURCE" >> /tmp/backup_report.txt
echo "Destination: $BACKUP_DEST" >> /tmp/backup_report.txt
echo "" >> /tmp/backup_report.txt
echo "Current Backups:" >> /tmp/backup_report.txt
ls -lh $BACKUP_DEST/backup_*.tar.gz >> /tmp/backup_report.txt

log_message "Backup process completed successfully"
send_notification "SUCCESS" "Backup completed: $BACKUP_NAME ($backup_size)"

# Display report
cat /tmp/backup_report.txt
```

---

## 🏆 Mastery Assessment

### Final Challenge: Complete System Administration Task

#### **Scenario:**
You're a new system administrator. Your first task is to set up monitoring and maintenance for a web server.

#### **Requirements:**
1. **System Health Monitoring**: Create a script that checks CPU, memory, disk usage
2. **Log Management**: Analyze web server logs and rotate them
3. **Process Management**: Monitor critical services and restart if needed
4. **Backup System**: Implement automated backups with rotation
5. **Reporting**: Generate daily system reports
6. **Automation**: Set up the entire system to run automatically

#### **Evaluation Criteria:**
- Script functionality and error handling
- Code organization and comments
- Understanding of system concepts
- Problem-solving approach
- Automation and efficiency

#### **Time Limit:** 2 hours

#### **Starter Template:**
```bash
#!/bin/bash
# System Administration Master Script
# Your Name: _______________
# Date: ___________________

# Configuration section
# TODO: Define all configuration variables

# Function definitions
# TODO: Create functions for each major task

# Main execution
# TODO: Implement the main logic

echo "System Administration Script Starting..."
# Your implementation here
echo "System Administration Script Completed."
```

---

## 🎯 Next Steps

Congratulations! You've completed comprehensive command line training. You now have:

- ✅ **Solid foundation** in command line operations
- ✅ **Practical experience** with real-world scenarios  
- ✅ **Problem-solving skills** for system administration
- ✅ **Automation capabilities** for repetitive tasks
- ✅ **Debugging skills** for troubleshooting issues

**You're now ready for Module 2: Docker Fundamentals** where you'll apply these command line skills to master Docker!
