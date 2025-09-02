# 🐳 Docker Commands Deep Dive - Part 5: Volumes & Data Management

## 🎯 Learning Objectives
- Master all Docker volume commands and options
- Understand data persistence strategies in containers
- Learn bind mounts, named volumes, and tmpfs mounts
- Implement data sharing between containers

---

## 💾 Understanding Docker Data Storage

### Container Data Layers
```
Container Filesystem Structure:
┌─────────────────────────────────────────┐
│ Container Layer (Read/Write)            │ ← Your changes
├─────────────────────────────────────────┤
│ Image Layer 4 (Read-Only)              │
├─────────────────────────────────────────┤
│ Image Layer 3 (Read-Only)              │
├─────────────────────────────────────────┤
│ Image Layer 2 (Read-Only)              │
├─────────────────────────────────────────┤
│ Image Layer 1 (Read-Only)              │
└─────────────────────────────────────────┘
```

### Data Persistence Problem
```bash
# Demonstrate data loss
docker run -d --name temp-container nginx:alpine
docker exec temp-container sh -c "echo 'Important data' > /tmp/data.txt"
docker exec temp-container cat /tmp/data.txt

# Stop and remove container
docker rm -f temp-container

# Data is lost forever!
docker run --name new-container nginx:alpine cat /tmp/data.txt
# File doesn't exist
```

### Docker Storage Types

#### 1. Bind Mounts
```
Host filesystem path mounted into container
┌─────────────────────────────────────────┐
│ Host: /home/user/data                   │
│         ↕                               │
│ Container: /app/data                    │
└─────────────────────────────────────────┘
```

#### 2. Named Volumes
```
Docker-managed storage with lifecycle
┌─────────────────────────────────────────┐
│ Docker Volume: my-data-volume           │
│         ↕                               │
│ Container: /app/data                    │
└─────────────────────────────────────────┘
```

#### 3. tmpfs Mounts
```
Memory-based temporary storage
┌─────────────────────────────────────────┐
│ Host RAM: tmpfs                         │
│         ↕                               │
│ Container: /tmp/memory-data             │
└─────────────────────────────────────────┘
```

---

## 📋 docker volume - Volume Management

### Syntax
```bash
docker volume COMMAND
```

### Available Commands
```bash
create      Create a volume
inspect     Display detailed information on one or more volumes
ls          List volumes
prune       Remove all unused local volumes
rm          Remove one or more volumes
```

---

## 📋 docker volume ls - List Volumes

### Syntax
```bash
docker volume ls [OPTIONS]
```

### All Available Options
```bash
-f, --filter filter   Provide filter values (e.g. 'dangling=true')
--format string      Pretty-print volumes using a Go template
-q, --quiet         Only display volume names
```

### Detailed Examples

**Basic Volume Listing:**
```bash
# List all volumes
docker volume ls
```

**Expected Output:**
```
DRIVER    VOLUME NAME
local     my-app-data
local     postgres-data
local     nginx-config
```

**Column Explanations:**
- **DRIVER**: Volume driver (local, nfs, etc.)
- **VOLUME NAME**: Unique volume identifier

**Filter Volumes:**
```bash
# Show dangling volumes (not used by containers)
docker volume ls --filter dangling=true
```

**Expected Output:**
```
DRIVER    VOLUME NAME
local     unused-volume-1
local     old-backup-volume
```

**Filter by Driver:**
```bash
# Show only local volumes
docker volume ls --filter driver=local
```

**Custom Format:**
```bash
# Show only volume names
docker volume ls --format "{{.Name}}"
```

**Expected Output:**
```
my-app-data
postgres-data
nginx-config
```

**Available Format Variables:**
- `.Name`: Volume name
- `.Driver`: Volume driver
- `.Scope`: Volume scope
- `.Mountpoint`: Host path where volume is mounted
- `.Labels`: Volume labels

---

## 🔧 docker volume create - Create Volumes

### Syntax
```bash
docker volume create [OPTIONS] [VOLUME]
```

### All Available Options
```bash
-d, --driver string        Specify volume driver name (default "local")
--label list              Set metadata for a volume
-o, --opt map             Set driver specific options (default map[])
```

### Detailed Examples

**Create Basic Volume:**
```bash
# Create simple named volume
docker volume create my-data-volume
```

**Expected Output:**
```
my-data-volume
```

**Verify Volume Creation:**
```bash
# Check volume exists
docker volume ls | grep my-data-volume
```

**Expected Output:**
```
local     my-data-volume
```

**Create Volume with Labels:**
```bash
# Create volume with metadata
docker volume create \
  --label environment=production \
  --label backup=daily \
  --label team=backend \
  production-data
```

**Verify Labels:**
```bash
# Check volume labels
docker volume inspect production-data --format='{{.Labels}}'
```

**Expected Output:**
```
map[backup:daily environment:production team:backend]
```

**Create Volume with Driver Options:**
```bash
# Create volume with specific options
docker volume create \
  --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=100m,uid=1000 \
  memory-volume
```

**Auto-Generated Volume Names:**
```bash
# Create volume with auto-generated name
docker volume create
```

**Expected Output:**
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4
```

---

## 🔍 docker volume inspect - Volume Details

### Syntax
```bash
docker volume inspect [OPTIONS] VOLUME [VOLUME...]
```

### All Available Options
```bash
-f, --format string   Format the output using the given Go template
```

### Detailed Examples

**Basic Volume Inspection:**
```bash
# Inspect volume details
docker volume inspect my-data-volume
```

**Expected Output:**
```json
[
    {
        "CreatedAt": "2024-01-15T10:30:45Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-data-volume/_data",
        "Name": "my-data-volume",
        "Options": {},
        "Scope": "local"
    }
]
```

**Key Information Explained:**
- **CreatedAt**: When volume was created
- **Driver**: Storage driver used
- **Mountpoint**: Host filesystem path
- **Options**: Driver-specific configuration
- **Scope**: Volume scope (local, global)

**Extract Specific Information:**
```bash
# Get volume mountpoint
docker volume inspect my-data-volume --format='{{.Mountpoint}}'
```

**Expected Output:**
```
/var/lib/docker/volumes/my-data-volume/_data
```

**Get Volume Driver:**
```bash
# Check volume driver
docker volume inspect my-data-volume --format='{{.Driver}}'
```

**Expected Output:**
```
local
```

**Inspect Multiple Volumes:**
```bash
# Inspect multiple volumes
docker volume inspect my-data-volume production-data --format='{{.Name}}: {{.Mountpoint}}'
```

**Expected Output:**
```
my-data-volume: /var/lib/docker/volumes/my-data-volume/_data
production-data: /var/lib/docker/volumes/production-data/_data
```

---

## 🗑️ docker volume rm/prune - Volume Cleanup

### Remove Syntax
```bash
docker volume rm VOLUME [VOLUME...]
```

### Prune Syntax
```bash
docker volume prune [OPTIONS]
```

### Prune Options
```bash
--filter filter   Provide filter values (e.g. 'label=<key>=<value>')
-f, --force      Do not prompt for confirmation
```

### Detailed Examples

**Remove Single Volume:**
```bash
# Remove unused volume
docker volume rm my-data-volume
```

**Expected Output:**
```
my-data-volume
```

**Remove Multiple Volumes:**
```bash
# Remove multiple volumes
docker volume rm volume1 volume2 volume3
```

**Error When Volume In Use:**
```bash
# Try to remove volume used by container
docker run -d -v my-data-volume:/data --name test-container nginx:alpine
docker volume rm my-data-volume
```

**Expected Output:**
```
Error response from daemon: remove my-data-volume: volume is in use - [a1b2c3d4e5f6]
```

**Remove All Unused Volumes:**
```bash
# Remove all dangling volumes
docker volume prune
```

**Expected Output:**
```
WARNING! This will remove all local volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Volumes:
unused-volume-1
old-backup-volume
temp-volume

Total reclaimed space: 1.2GB
```

**Force Prune Without Confirmation:**
```bash
# Skip confirmation prompt
docker volume prune -f
```

**Prune with Filters:**
```bash
# Remove volumes with specific label
docker volume prune --filter "label=environment=test"
```

---

## 📁 Volume Usage Patterns

### Named Volumes

**Database Data Persistence:**
```bash
# Create database volume
docker volume create postgres-data

# Run PostgreSQL with persistent data
docker run -d \
  --name postgres-db \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=myapp \
  postgres:13

# Add some data
docker exec -it postgres-db psql -U postgres -d myapp -c "
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('John Doe'), ('Jane Smith');
"

# Stop and remove container
docker rm -f postgres-db

# Start new container with same volume
docker run -d \
  --name postgres-db-new \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# Verify data persisted
docker exec postgres-db-new psql -U postgres -d myapp -c "SELECT * FROM users;"
```

**Expected Output:**
```
 id |   name    
----+-----------
  1 | John Doe
  2 | Jane Smith
(2 rows)
```

**Application Configuration:**
```bash
# Create config volume
docker volume create app-config

# Initialize configuration
docker run --rm \
  -v app-config:/config \
  alpine sh -c "
echo 'database_host=localhost' > /config/app.conf
echo 'database_port=5432' >> /config/app.conf
echo 'debug=false' >> /config/app.conf
"

# Use config in application
docker run -d \
  --name web-app \
  -v app-config:/app/config \
  -p 8080:80 \
  nginx:alpine

# Verify config exists
docker exec web-app cat /app/config/app.conf
```

**Expected Output:**
```
database_host=localhost
database_port=5432
debug=false
```

### Bind Mounts

**Development Environment:**
```bash
# Create project directory
mkdir -p ~/my-web-project
cd ~/my-web-project

# Create simple HTML file
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>My Web Project</title></head>
<body>
    <h1>Hello from Development!</h1>
    <p>This file is mounted from the host.</p>
</body>
</html>
EOF

# Run web server with bind mount
docker run -d \
  --name dev-server \
  -v $(pwd):/usr/share/nginx/html \
  -p 8080:80 \
  nginx:alpine

# Test the website
curl http://localhost:8080
```

**Expected Output:**
```html
<!DOCTYPE html>
<html>
<head><title>My Web Project</title></head>
<body>
    <h1>Hello from Development!</h1>
    <p>This file is mounted from the host.</p>
</body>
</html>
```

**Live Development:**
```bash
# Modify file on host
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Updated Project</title></head>
<body>
    <h1>Updated Content!</h1>
    <p>Changes appear immediately.</p>
</body>
</html>
EOF

# Check changes immediately reflected
curl http://localhost:8080
```

**Expected Output:**
```html
<!DOCTYPE html>
<html>
<head><title>Updated Project</title></head>
<body>
    <h1>Updated Content!</h1>
    <p>Changes appear immediately.</p>
</body>
</html>
```

**Log File Access:**
```bash
# Create log directory on host
mkdir -p ~/app-logs

# Run application with log bind mount
docker run -d \
  --name app-with-logs \
  -v ~/app-logs:/var/log/nginx \
  -p 8081:80 \
  nginx:alpine

# Generate some traffic
curl http://localhost:8081
curl http://localhost:8081/test

# Check logs on host
ls -la ~/app-logs/
cat ~/app-logs/access.log
```

**Expected Output:**
```
total 8
drwxr-xr-x 2 user user 4096 Jan 15 10:45 .
drwxr-xr-x 8 user user 4096 Jan 15 10:45 ..
-rw-r--r-- 1 user user  180 Jan 15 10:45 access.log
-rw-r--r-- 1 user user    0 Jan 15 10:45 error.log

172.17.0.1 - - [15/Jan/2024:10:45:23 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.68.0" "-"
172.17.0.1 - - [15/Jan/2024:10:45:25 +0000] "GET /test HTTP/1.1" 404 153 "-" "curl/7.68.0" "-"
```

### tmpfs Mounts

**Temporary Data Storage:**
```bash
# Run container with tmpfs mount
docker run -d \
  --name temp-storage \
  --tmpfs /tmp/cache:rw,noexec,nosuid,size=100m \
  nginx:alpine

# Test tmpfs mount
docker exec temp-storage df -h /tmp/cache
```

**Expected Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           100M     0  100M   0% /tmp/cache
```

**Memory-Based Cache:**
```bash
# Create cache data in memory
docker exec temp-storage sh -c "
echo 'Cached data 1' > /tmp/cache/item1.txt
echo 'Cached data 2' > /tmp/cache/item2.txt
dd if=/dev/zero of=/tmp/cache/large-file bs=1M count=50
"

# Check memory usage
docker exec temp-storage df -h /tmp/cache
```

**Expected Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           100M   50M   50M  50% /tmp/cache
```

**Restart Container - Data Lost:**
```bash
# Restart container
docker restart temp-storage

# Check if data exists (it won't)
docker exec temp-storage ls /tmp/cache/
```

**Expected Output:**
```
(empty - tmpfs data is lost on restart)
```

---

## 🔄 Data Sharing Between Containers

### Shared Volume Pattern

**Setup Shared Data Volume:**
```bash
# Create shared volume
docker volume create shared-data

# Container 1: Data producer
docker run -d \
  --name producer \
  -v shared-data:/data \
  alpine sh -c "
while true; do
  echo \$(date): Producer data >> /data/producer.log
  sleep 5
done
"

# Container 2: Data consumer
docker run -d \
  --name consumer \
  -v shared-data:/data \
  alpine sh -c "
while true; do
  echo 'Consumer reading:'
  tail -3 /data/producer.log 2>/dev/null || echo 'No data yet'
  sleep 10
done
"

# Monitor both containers
docker logs --tail 5 producer
docker logs --tail 5 consumer
```

**Expected Output:**
```
# Producer logs:
Mon Jan 15 10:50:01 UTC 2024: Producer data
Mon Jan 15 10:50:06 UTC 2024: Producer data

# Consumer logs:
Consumer reading:
Mon Jan 15 10:50:01 UTC 2024: Producer data
Mon Jan 15 10:50:06 UTC 2024: Producer data
```

### Volumes-From Pattern (Legacy)

**Data Container Pattern:**
```bash
# Create data-only container
docker create \
  --name data-container \
  -v /data \
  alpine

# Add data to data container
docker run --rm \
  --volumes-from data-container \
  alpine sh -c "echo 'Shared data' > /data/shared.txt"

# Use data in application containers
docker run -d \
  --name app1 \
  --volumes-from data-container \
  nginx:alpine

docker run -d \
  --name app2 \
  --volumes-from data-container \
  nginx:alpine

# Verify both containers have access
docker exec app1 cat /data/shared.txt
docker exec app2 cat /data/shared.txt
```

**Expected Output:**
```
Shared data
Shared data
```

---

## 🔧 Volume Performance and Optimization

### Performance Comparison

**Test Volume Performance:**
```bash
# Create test volumes
docker volume create test-volume

# Test named volume performance
docker run --rm \
  -v test-volume:/data \
  alpine sh -c "
time dd if=/dev/zero of=/data/test-file bs=1M count=100
"

# Test bind mount performance
mkdir -p ~/test-bind
docker run --rm \
  -v ~/test-bind:/data \
  alpine sh -c "
time dd if=/dev/zero of=/data/test-file bs=1M count=100
"

# Test tmpfs performance
docker run --rm \
  --tmpfs /data:rw,size=200m \
  alpine sh -c "
time dd if=/dev/zero of=/data/test-file bs=1M count=100
"
```

**Expected Performance Order:**
1. **tmpfs**: Fastest (memory-based)
2. **Named volumes**: Good performance
3. **Bind mounts**: Slower (depends on host filesystem)

### Volume Backup and Restore

**Backup Volume Data:**
```bash
# Create backup of volume
docker run --rm \
  -v postgres-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/postgres-backup-$(date +%Y%m%d).tar.gz -C /data .

# Verify backup
ls -la postgres-backup-*.tar.gz
```

**Restore Volume Data:**
```bash
# Create new volume
docker volume create postgres-data-restored

# Restore from backup
docker run --rm \
  -v postgres-data-restored:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/postgres-backup-20240115.tar.gz -C /data

# Verify restore
docker run --rm \
  -v postgres-data-restored:/data \
  alpine ls -la /data
```

### Volume Migration

**Migrate Data Between Volumes:**
```bash
# Create source and destination volumes
docker volume create source-volume
docker volume create destination-volume

# Add data to source
docker run --rm \
  -v source-volume:/data \
  alpine sh -c "
echo 'Important data' > /data/important.txt
mkdir /data/subdir
echo 'More data' > /data/subdir/more.txt
"

# Migrate data
docker run --rm \
  -v source-volume:/source \
  -v destination-volume:/destination \
  alpine cp -a /source/. /destination/

# Verify migration
docker run --rm \
  -v destination-volume:/data \
  alpine find /data -type f -exec cat {} \;
```

**Expected Output:**
```
Important data
More data
```

---

## 🔍 Volume Troubleshooting

### Common Volume Issues

**Issue 1: Permission Problems**

**Diagnosis:**
```bash
# Check file permissions in volume
docker run --rm \
  -v my-volume:/data \
  alpine ls -la /data

# Check container user
docker run --rm \
  -v my-volume:/data \
  alpine id
```

**Solutions:**
```bash
# Fix permissions
docker run --rm \
  -v my-volume:/data \
  alpine chown -R 1000:1000 /data

# Run container as specific user
docker run --user 1000:1000 \
  -v my-volume:/data \
  alpine touch /data/test.txt
```

**Issue 2: Volume Not Mounting**

**Diagnosis:**
```bash
# Check if volume exists
docker volume ls | grep my-volume

# Check mount points
docker inspect container-name --format='{{.Mounts}}'

# Check volume details
docker volume inspect my-volume
```

**Issue 3: Data Not Persisting**

**Diagnosis:**
```bash
# Verify volume is actually mounted
docker exec container-name mount | grep /data

# Check if using anonymous volume
docker inspect container-name --format='{{range .Mounts}}{{.Type}}: {{.Source}} -> {{.Destination}}{{end}}'
```

### Volume Monitoring

**Monitor Volume Usage:**
```bash
# Check volume disk usage
docker system df -v

# Monitor volume mountpoints
docker volume ls --format "table {{.Name}}\t{{.Driver}}" | while read name driver; do
  if [ "$name" != "VOLUME" ]; then
    mountpoint=$(docker volume inspect $name --format='{{.Mountpoint}}')
    size=$(sudo du -sh $mountpoint 2>/dev/null | cut -f1)
    echo "$name: $size"
  fi
done
```

**Volume Health Check:**
```bash
# Test volume accessibility
test_volume() {
  local volume_name=$1
  docker run --rm \
    -v $volume_name:/test \
    alpine sh -c "
    echo 'test' > /test/health-check.txt &&
    cat /test/health-check.txt &&
    rm /test/health-check.txt
  " > /dev/null 2>&1
  
  if [ $? -eq 0 ]; then
    echo "✅ $volume_name: Healthy"
  else
    echo "❌ $volume_name: Failed"
  fi
}

# Test all volumes
docker volume ls -q | while read volume; do
  test_volume $volume
done
```

---

## 🚀 Next Steps

You now have complete mastery of Docker volumes and data management:

- ✅ **docker volume ls**: List and filter volumes with all options
- ✅ **docker volume create**: Create volumes with advanced configurations
- ✅ **docker volume inspect**: Analyze volume details and metadata
- ✅ **docker volume rm/prune**: Clean up unused volumes efficiently
- ✅ **Named Volumes**: Persistent data storage managed by Docker
- ✅ **Bind Mounts**: Direct host filesystem access for development
- ✅ **tmpfs Mounts**: Memory-based temporary storage
- ✅ **Data Sharing**: Multi-container data sharing patterns
- ✅ **Performance Optimization**: Volume performance tuning
- ✅ **Backup/Restore**: Data protection strategies
- ✅ **Troubleshooting**: Diagnose and fix volume issues

**Ready for Module 2 Completion Assessment** where you'll demonstrate mastery of all Docker fundamentals through comprehensive practical challenges!
