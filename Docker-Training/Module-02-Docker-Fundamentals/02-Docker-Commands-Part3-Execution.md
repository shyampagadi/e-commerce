# 🐳 Docker Commands Deep Dive - Part 3: Container Execution & Debugging

## 🎯 Learning Objectives
- Master container execution and debugging commands
- Understand all options for docker exec, logs, and stats
- Learn advanced troubleshooting techniques
- Debug container issues like an expert

---

## 🔧 docker exec - Execute Commands in Running Containers

### Syntax
```bash
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

### All Available Options
```bash
-d, --detach               Detached mode: run command in the background
--detach-keys string       Override the key sequence for detaching a container
-e, --env list             Set environment variables
--env-file list           Read in a file of environment variables
-i, --interactive         Keep STDIN open even if not attached
--privileged              Give extended privileges to the command
-t, --tty                 Allocate a pseudo-TTY
-u, --user string         Username or UID (format: <name|uid>[:<group|gid>])
-w, --workdir string      Working directory inside the container
```

### Detailed Examples

**Interactive Shell Access:**
```bash
# Start a container first
docker run -d --name test-container nginx:alpine

# Get interactive shell
docker exec -it test-container sh
```

**Expected Output:**
```
/ # 
```

**Command Breakdown:**
- `-i`: Keep STDIN open for input
- `-t`: Allocate pseudo-TTY for proper terminal display
- `sh`: Alpine Linux uses sh instead of bash

**Inside Container Commands:**
```bash
# Now you're inside the container
/ # whoami
root
/ # pwd
/
/ # ls -la
total 64
drwxr-xr-x    1 root     root          4096 Jan 15 10:30 .
drwxr-xr-x    1 root     root          4096 Jan 15 10:30 ..
-rwxr-xr-x    1 root     root             0 Jan 15 10:30 .dockerenv
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 bin
drwxr-xr-x    5 root     root           360 Jan 15 10:30 dev
drwxr-xr-x    1 root     root          4096 Jan 15 10:30 etc
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 home
drwxr-xr-x    7 root     root          4096 Dec 28 17:20 lib
drwxr-xr-x    5 root     root          4096 Dec 28 17:20 media
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 mnt
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 opt
dr-xr-xr-x  308 root     root             0 Jan 15 10:30 proc
drwx------    2 root     root          4096 Dec 28 17:20 root
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 run
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 sbin
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 srv
dr-xr-xr-x   13 root     root             0 Jan 15 10:30 sys
drwxrwxrwt    1 root     root          4096 Jan 15 10:30 tmp
drwxr-xr-x    7 root     root          4096 Dec 28 17:20 usr
drwxr-xr-x   12 root     root          4096 Dec 28 17:20 var
/ # exit
```

**Key Observations:**
- `.dockerenv`: File indicating you're in a container
- `/proc`, `/sys`: Virtual filesystems from host kernel
- File permissions and ownership visible

**Execute Single Command:**
```bash
# Run single command without interactive shell
docker exec test-container ls -la /etc/nginx
```

**Expected Output:**
```
total 40
drwxr-xr-x    3 root     root          4096 Dec 28 17:20 .
drwxr-xr-x    1 root     root          4096 Jan 15 10:30 ..
drwxr-xr-x    2 root     root          4096 Dec 28 17:20 conf.d
-rw-r--r--    1 root     root          1007 Dec 13 15:14 fastcgi_params
-rw-r--r--    1 root     root          5349 Dec 13 15:14 mime.types
-rw-r--r--    1 root     root           648 Dec 13 15:14 nginx.conf
-rw-r--r--    1 root     root           636 Dec 13 15:14 scgi_params
-rw-r--r--    1 root     root           664 Dec 13 15:14 uwsgi_params
```

**Execute as Different User:**
```bash
# Run command as specific user
docker exec -u nginx test-container whoami
```

**Expected Output:**
```
nginx
```

**Execute with Environment Variables:**
```bash
# Set environment variables for command
docker exec -e MY_VAR=hello -e DEBUG=true test-container env | grep MY_VAR
```

**Expected Output:**
```
MY_VAR=hello
```

**Execute in Different Working Directory:**
```bash
# Change working directory for command
docker exec -w /var/log/nginx test-container pwd
```

**Expected Output:**
```
/var/log/nginx
```

**Background Command Execution:**
```bash
# Run command in background (detached)
docker exec -d test-container sh -c "sleep 60 && echo 'Background task completed' > /tmp/result.txt"

# Check if file was created (after 60 seconds)
docker exec test-container cat /tmp/result.txt
```

**Privileged Command Execution:**
```bash
# Run with extended privileges
docker exec --privileged test-container mount
```

**Expected Output:**
```
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev type tmpfs (rw,nosuid,size=65536k,mode=755)
...
```

**Multiple Commands:**
```bash
# Execute multiple commands
docker exec test-container sh -c "cd /etc/nginx && ls -la && cat nginx.conf | head -10"
```

---

## 📋 docker logs - View Container Logs

### Syntax
```bash
docker logs [OPTIONS] CONTAINER
```

### All Available Options
```bash
--details                Show extra details provided to logs
-f, --follow            Follow log output
--since string          Show logs since timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)
-n, --tail string       Number of lines to show from the end of the logs (default "all")
-t, --timestamps        Show timestamps
--until string          Show logs before a timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)
```

### Detailed Examples

**Basic Log Viewing:**
```bash
# View all logs from container
docker logs test-container
```

**Expected Output:**
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
- **Initialization**: Container startup scripts
- **Configuration**: Nginx configuration process
- **Process Start**: Main nginx process and workers
- **PID Information**: Process 1 is main, 31 is worker

**Follow Logs in Real-time:**
```bash
# Follow logs as they're generated
docker logs -f test-container
```

**Expected Behavior:**
- Command doesn't exit
- New log entries appear immediately
- Press Ctrl+C to stop following

**Generate some traffic to see new logs:**
```bash
# In another terminal, generate requests
curl http://localhost:8080
curl http://localhost:8080/nonexistent
```

**New Log Entries:**
```
172.17.0.1 - - [15/Jan/2024:10:35:23 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.68.0" "-"
172.17.0.1 - - [15/Jan/2024:10:35:25 +0000] "GET /nonexistent HTTP/1.1" 404 153 "-" "curl/7.68.0" "-"
```

**Show Timestamps:**
```bash
# Include timestamps in log output
docker logs -t test-container
```

**Expected Output:**
```
2024-01-15T10:30:45.123456789Z /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
2024-01-15T10:30:45.234567890Z /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
2024-01-15T10:30:45.345678901Z /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
...
```

**Show Last N Lines:**
```bash
# Show only last 10 lines
docker logs --tail 10 test-container
```

**Expected Output:**
```
2024/01/15 10:30:45 [notice] 1#1: using the "epoll" event method
2024/01/15 10:30:45 [notice] 1#1: nginx/1.23.3
2024/01/15 10:30:45 [notice] 1#1: built by gcc 12.2.1 20220924 (Alpine 12.2.1_git20220924-r4) 
2024/01/15 10:30:45 [notice] 1#1: OS: Linux 5.4.0-135-generic
2024/01/15 10:30:45 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/01/15 10:30:45 [notice] 1#1: start worker processes
2024/01/15 10:30:45 [notice] 1#1: start worker process 31
172.17.0.1 - - [15/Jan/2024:10:35:23 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.68.0" "-"
172.17.0.1 - - [15/Jan/2024:10:35:25 +0000] "GET /nonexistent HTTP/1.1" 404 153 "-" "curl/7.68.0" "-"
```

**Show Logs Since Specific Time:**
```bash
# Show logs from last 30 minutes
docker logs --since 30m test-container

# Show logs since specific timestamp
docker logs --since 2024-01-15T10:30:00Z test-container

# Show logs from last 1 hour
docker logs --since 1h test-container
```

**Show Logs Until Specific Time:**
```bash
# Show logs until 10 minutes ago
docker logs --until 10m test-container

# Show logs until specific timestamp
docker logs --until 2024-01-15T10:35:00Z test-container
```

**Combine Options:**
```bash
# Show last 20 lines with timestamps, follow new entries
docker logs -t --tail 20 -f test-container

# Show logs from last hour with timestamps
docker logs -t --since 1h test-container
```

---

## 📊 docker stats - Container Resource Usage

### Syntax
```bash
docker stats [OPTIONS] [CONTAINER...]
```

### All Available Options
```bash
-a, --all             Show all containers (default shows just running)
--format string       Pretty-print images using a Go template
--no-stream          Disable streaming stats and only pull the first result
--no-trunc           Do not truncate output
```

### Detailed Examples

**Real-time Stats for All Running Containers:**
```bash
# Show live resource usage
docker stats
```

**Expected Output:**
```
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
a1b2c3d4e5f6   test-container   0.00%     3.45MiB / 7.775GiB    0.04%     1.23kB / 656B     0B / 0B           2
```

**Column Explanations:**
- **CONTAINER ID**: First 12 chars of container ID
- **NAME**: Container name
- **CPU %**: Percentage of host CPU being used
- **MEM USAGE / LIMIT**: Current memory usage / memory limit
- **MEM %**: Percentage of available memory being used
- **NET I/O**: Network bytes received / sent
- **BLOCK I/O**: Disk bytes read / written
- **PIDS**: Number of processes/threads in container

**Stats for Specific Container:**
```bash
# Monitor specific container
docker stats test-container
```

**One-time Stats (No Streaming):**
```bash
# Get single snapshot of stats
docker stats --no-stream
```

**Expected Output:**
```
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
a1b2c3d4e5f6   test-container   0.01%     3.45MiB / 7.775GiB    0.04%     1.23kB / 656B     0B / 0B           2
```

**Custom Format:**
```bash
# Show only name, CPU, and memory
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Expected Output:**
```
NAME             CPU %     MEM USAGE / LIMIT
test-container   0.00%     3.45MiB / 7.775GiB
```

**Available Format Variables:**
- `.Container`: Container name or ID
- `.Name`: Container name
- `.ID`: Container ID
- `.CPUPerc`: CPU percentage
- `.MemUsage`: Memory usage
- `.NetIO`: Network I/O
- `.BlockIO`: Block I/O
- `.MemPerc`: Memory percentage
- `.PIDs`: Number of PIDs

**Generate Load to See Stats Change:**
```bash
# Create CPU load in container
docker exec -d test-container sh -c "while true; do echo 'CPU load test' > /dev/null; done"

# Create memory load
docker exec -d test-container sh -c "dd if=/dev/zero of=/tmp/memory_test bs=1M count=100"

# Monitor the changes
docker stats test-container
```

**Expected Output with Load:**
```
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
a1b2c3d4e5f6   test-container   25.67%    103.2MiB / 7.775GiB   1.30%     1.45kB / 876B     105MB / 0B        4
```

**Stop Load Tests:**
```bash
# Kill background processes
docker exec test-container pkill -f "CPU load test"
docker exec test-container rm /tmp/memory_test
```

---

## 🔍 docker top - Process Information

### Syntax
```bash
docker top CONTAINER [ps OPTIONS]
```

### Detailed Examples

**Basic Process List:**
```bash
# Show processes running in container
docker top test-container
```

**Expected Output:**
```
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                12345               12344               0                   10:30               ?                   00:00:00            nginx: master process nginx -g daemon off;
101                 12367               12345               0                   10:30               ?                   00:00:00            nginx: worker process
```

**Column Explanations:**
- **UID**: User ID running the process
- **PID**: Process ID (from host perspective)
- **PPID**: Parent Process ID
- **C**: CPU utilization
- **STIME**: Start time
- **TTY**: Terminal (? means no terminal)
- **TIME**: CPU time consumed
- **CMD**: Command being executed

**Custom ps Options:**
```bash
# Show additional process information
docker top test-container aux
```

**Expected Output:**
```
USER                PID                 %CPU                %MEM                VSZ                 RSS                 TTY                 STAT                START               TIME                COMMAND
root                12345               0.0                 0.1                 8892                3456                ?                   Ss                  10:30               0:00                nginx: master process nginx -g daemon off;
101                 12367               0.0                 0.0                 9012                2345                ?                   S                   10:30               0:00                nginx: worker process
```

**Additional Columns:**
- **%CPU**: CPU percentage
- **%MEM**: Memory percentage
- **VSZ**: Virtual memory size
- **RSS**: Resident memory size
- **STAT**: Process state (S=sleeping, R=running, Z=zombie)

**Show Process Tree:**
```bash
# Show process hierarchy
docker top test-container f
```

---

## 🔧 docker cp - Copy Files Between Container and Host

### Syntax
```bash
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-
docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH
```

### All Available Options
```bash
-a, --archive       Archive mode (copy all uid/gid information)
-L, --follow-link   Always follow symbol link in SRC_PATH
```

### Detailed Examples

**Copy File from Container to Host:**
```bash
# Copy nginx config from container to host
docker cp test-container:/etc/nginx/nginx.conf ./nginx-backup.conf

# Verify file was copied
ls -la nginx-backup.conf
cat nginx-backup.conf | head -10
```

**Expected Output:**
```
-rw-r--r-- 1 user user 648 Jan 15 10:45 nginx-backup.conf

user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log notice;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}
```

**Copy File from Host to Container:**
```bash
# Create custom config on host
cat > custom-nginx.conf << 'EOF'
user nginx;
worker_processes 2;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 2048;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

# Copy to container
docker cp custom-nginx.conf test-container:/etc/nginx/nginx.conf

# Verify copy
docker exec test-container cat /etc/nginx/nginx.conf | head -5
```

**Expected Output:**
```
user nginx;
worker_processes 2;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;
```

**Copy Directory:**
```bash
# Copy entire directory from container
docker cp test-container:/etc/nginx ./nginx-config-backup

# Verify directory structure
ls -la nginx-config-backup/
```

**Expected Output:**
```
total 32
drwxr-xr-x 3 user user 4096 Jan 15 10:50 .
drwxr-xr-x 8 user user 4096 Jan 15 10:50 ..
drwxr-xr-x 2 user user 4096 Jan 15 10:50 conf.d
-rw-r--r-- 1 user user 1007 Jan 15 10:50 fastcgi_params
-rw-r--r-- 1 user user 5349 Jan 15 10:50 mime.types
-rw-r--r-- 1 user user  648 Jan 15 10:50 nginx.conf
-rw-r--r-- 1 user user  636 Jan 15 10:50 scgi_params
-rw-r--r-- 1 user user  664 Jan 15 10:50 uwsgi_params
```

**Archive Mode (Preserve Permissions):**
```bash
# Copy with original permissions and ownership
docker cp -a test-container:/etc/nginx ./nginx-archive

# Check permissions
ls -la nginx-archive/
```

**Copy to/from STDIN/STDOUT:**
```bash
# Copy file content to stdout
docker cp test-container:/etc/nginx/nginx.conf - | tar -tv

# Copy from stdin
echo "Hello Container" | docker cp - test-container:/tmp/hello.txt
```

---

## 🚀 Advanced Debugging Techniques

### Container Health Diagnosis

**Complete Container Inspection:**
```bash
# Get all container information
docker inspect test-container | jq '.[0] | {
    State: .State,
    Config: .Config,
    NetworkSettings: .NetworkSettings,
    Mounts: .Mounts
}'
```

**Process Debugging:**
```bash
# Check all processes
docker exec test-container ps aux

# Check process tree
docker exec test-container ps auxf

# Check system resources inside container
docker exec test-container free -h
docker exec test-container df -h
```

**Network Debugging:**
```bash
# Check network configuration
docker exec test-container ip addr show
docker exec test-container ip route show

# Test connectivity
docker exec test-container ping -c 3 8.8.8.8
docker exec test-container nslookup google.com
```

**Log Analysis:**
```bash
# Check system logs inside container
docker exec test-container dmesg | tail -20

# Check application logs
docker exec test-container find /var/log -name "*.log" -exec tail -5 {} \;
```

### Performance Analysis

**Resource Usage Over Time:**
```bash
# Monitor stats for 60 seconds
timeout 60 docker stats test-container > stats.log

# Analyze the data
cat stats.log
```

**Memory Analysis:**
```bash
# Check memory details
docker exec test-container cat /proc/meminfo

# Check memory usage by process
docker exec test-container cat /proc/*/status | grep -E "(Name|VmRSS)"
```

**Disk Usage Analysis:**
```bash
# Check disk usage inside container
docker exec test-container du -sh /*

# Check inode usage
docker exec test-container df -i
```

---

## 🚀 Next Steps

You now have complete mastery of Docker container execution and debugging:

- ✅ **docker exec**: Execute commands with all options and use cases
- ✅ **docker logs**: View and filter logs with timestamps and following
- ✅ **docker stats**: Monitor resource usage in real-time
- ✅ **docker top**: Analyze running processes
- ✅ **docker cp**: Copy files between container and host
- ✅ **Advanced debugging**: Complete troubleshooting techniques

**Ready for Module 2, Part 4: Docker Networking Deep Dive** where you'll master container networking, port mapping, and multi-container communication!
