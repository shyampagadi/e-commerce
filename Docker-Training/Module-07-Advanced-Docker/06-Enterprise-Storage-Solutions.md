# 💾 Enterprise Storage Solutions

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** enterprise storage patterns and distributed storage systems
- **Master** advanced volume management and storage drivers
- **Implement** high-performance storage solutions for e-commerce applications
- **Configure** backup, replication, and disaster recovery strategies
- **Deploy** production-ready persistent storage architectures

## 🎯 Real-World Context
Enterprise e-commerce platforms require robust, scalable storage solutions that can handle millions of transactions, product catalogs, user data, and media files. This module teaches you to architect and implement enterprise-grade storage systems that ensure data durability, performance, and availability.

---

## 📚 Part 1: Enterprise Storage Fundamentals

### Understanding Container Storage Challenges

**Traditional vs. Container Storage:**

**Traditional Storage:**
- Direct filesystem access
- Persistent storage by default
- Simple backup and recovery
- Single-host limitations

**Container Storage:**
- Ephemeral by default
- Requires explicit persistence
- Complex multi-host scenarios
- Dynamic scaling requirements

### Storage Types and Use Cases

**1. Ephemeral Storage**
- Container filesystem layers
- Temporary data and caches
- Application logs (before collection)
- Build artifacts and temporary files

**2. Persistent Volumes**
- Database data files
- User-uploaded content
- Configuration files
- Application state

**3. Shared Storage**
- Static assets (images, CSS, JS)
- Shared configuration
- Inter-service communication files
- Distributed cache data

### Enterprise Storage Requirements

**Performance Requirements:**
- IOPS (Input/Output Operations Per Second)
- Throughput (MB/s read/write)
- Latency (response time)
- Concurrent access patterns

**Reliability Requirements:**
- Data durability (99.999999999% - 11 9's)
- Availability (99.99% uptime)
- Backup and recovery (RTO/RPO targets)
- Disaster recovery capabilities

**Scalability Requirements:**
- Horizontal scaling (add more storage nodes)
- Vertical scaling (increase storage capacity)
- Dynamic provisioning
- Multi-region replication

---

## 🔧 Part 2: Advanced Volume Management

### Docker Volume Drivers

**Built-in Volume Drivers:**
```bash
# Local driver (default)
docker volume create --driver local \
  --opt type=ext4 \
  --opt device=/dev/sdb1 \
  ecommerce-data

# NFS driver for shared storage
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/shared/storage \
  ecommerce-shared

# Bind mount for development
docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/host/path/to/data \
  ecommerce-dev-data
```

### Custom Storage Solutions

**High-Performance Storage Configuration:**
```yaml
# docker-compose.storage.yml
version: '3.8'

services:
  # Database with optimized storage
  ecommerce-database:
    image: postgres:15
    volumes:
      # Separate data and WAL for performance
      - postgres_data:/var/lib/postgresql/data
      - postgres_wal:/var/lib/postgresql/wal
      # Optimized tmpfs for temporary operations
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 2G
          mode: 1777
    environment:
      POSTGRES_WAL_LEVEL: replica
      POSTGRES_CHECKPOINT_COMPLETION_TARGET: 0.9
      POSTGRES_WAL_BUFFERS: 64MB

  # Redis with persistence optimization
  ecommerce-cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 512M
    command: >
      redis-server
      --appendonly yes
      --appendfsync everysec
      --save 900 1
      --save 300 10
      --save 60 10000

  # File storage service
  ecommerce-files:
    image: minio/minio:latest
    volumes:
      - minio_data:/data
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    command: server /data --console-address ":9001"

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/postgres-data
  
  postgres_wal:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime,sync
      device: /dev/disk/by-label/postgres-wal
  
  redis_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/redis-data
  
  minio_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/minio-data
```

---

## 🏗️ Part 3: E-Commerce Storage Architecture

### Multi-Tier Storage Strategy

**E-Commerce Storage Tiers:**

**Tier 1: Hot Data (High Performance)**
- Active user sessions
- Shopping cart data
- Real-time inventory
- Payment processing data

**Tier 2: Warm Data (Balanced Performance)**
- Product catalog
- User profiles
- Order history
- Search indexes

**Tier 3: Cold Data (Cost Optimized)**
- Historical analytics
- Archived orders
- Backup data
- Compliance logs

### Production Storage Implementation

**Complete E-Commerce Storage Stack:**
```yaml
# docker-compose.production-storage.yml
version: '3.8'

services:
  # Primary database cluster
  postgres-primary:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: master
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres_primary_data:/var/lib/postgresql/data
      - postgres_primary_wal:/var/lib/postgresql/wal
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4'
        reservations:
          memory: 4G
          cpus: '2'

  postgres-replica:
    image: postgres:15
    environment:
      POSTGRES_REPLICATION_MODE: slave
      POSTGRES_MASTER_HOST: postgres-primary
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: replicator_password
    volumes:
      - postgres_replica_data:/var/lib/postgresql/data
    depends_on:
      - postgres-primary

  # Distributed cache cluster
  redis-cluster-1:
    image: redis:7-alpine
    command: >
      redis-server
      --cluster-enabled yes
      --cluster-config-file nodes.conf
      --cluster-node-timeout 5000
      --appendonly yes
    volumes:
      - redis_cluster_1:/data

  redis-cluster-2:
    image: redis:7-alpine
    command: >
      redis-server
      --cluster-enabled yes
      --cluster-config-file nodes.conf
      --cluster-node-timeout 5000
      --appendonly yes
    volumes:
      - redis_cluster_2:/data

  redis-cluster-3:
    image: redis:7-alpine
    command: >
      redis-server
      --cluster-enabled yes
      --cluster-config-file nodes.conf
      --cluster-node-timeout 5000
      --appendonly yes
    volumes:
      - redis_cluster_3:/data

  # Object storage for media files
  minio-1:
    image: minio/minio:latest
    command: server http://minio-{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio_1_data:/data

  minio-2:
    image: minio/minio:latest
    command: server http://minio-{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio_2_data:/data

  # Search engine with persistent storage
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      discovery.type: single-node
      ES_JAVA_OPTS: "-Xms2g -Xmx2g"
      xpack.security.enabled: false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G

volumes:
  postgres_primary_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/pg-primary-data
  
  postgres_primary_wal:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime,sync
      device: /dev/disk/by-label/pg-primary-wal
  
  postgres_replica_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/pg-replica-data
  
  redis_cluster_1:
    driver: local
  redis_cluster_2:
    driver: local
  redis_cluster_3:
    driver: local
  
  minio_1_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/minio-1-data
  
  minio_2_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/minio-2-data
  
  elasticsearch_data:
    driver: local
    driver_opts:
      type: ext4
      o: defaults,noatime
      device: /dev/disk/by-label/elasticsearch-data
```

---

## 🔄 Part 4: Backup and Disaster Recovery

### Automated Backup Strategies

**Database Backup Automation:**
```bash
#!/bin/bash
# backup-automation.sh - Automated backup system

BACKUP_DIR="/backups"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# PostgreSQL backup
backup_postgres() {
    echo "🗄️ Starting PostgreSQL backup..."
    
    docker exec ecommerce-database pg_dump \
        -U postgres \
        -d ecommerce \
        --verbose \
        --format=custom \
        --compress=9 \
        > "${BACKUP_DIR}/postgres_${TIMESTAMP}.dump"
    
    # Verify backup
    if [ $? -eq 0 ]; then
        echo "✅ PostgreSQL backup completed: postgres_${TIMESTAMP}.dump"
    else
        echo "❌ PostgreSQL backup failed"
        exit 1
    fi
}

# Redis backup
backup_redis() {
    echo "💾 Starting Redis backup..."
    
    docker exec ecommerce-cache redis-cli BGSAVE
    
    # Wait for background save to complete
    while [ "$(docker exec ecommerce-cache redis-cli LASTSAVE)" = "$(docker exec ecommerce-cache redis-cli LASTSAVE)" ]; do
        sleep 1
    done
    
    docker cp ecommerce-cache:/data/dump.rdb "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb"
    echo "✅ Redis backup completed: redis_${TIMESTAMP}.rdb"
}

# MinIO backup
backup_minio() {
    echo "📁 Starting MinIO backup..."
    
    docker exec ecommerce-files mc mirror /data "${BACKUP_DIR}/minio_${TIMESTAMP}/"
    
    if [ $? -eq 0 ]; then
        echo "✅ MinIO backup completed: minio_${TIMESTAMP}/"
    else
        echo "❌ MinIO backup failed"
        exit 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    echo "🧹 Cleaning up backups older than ${RETENTION_DAYS} days..."
    find "${BACKUP_DIR}" -type f -mtime +${RETENTION_DAYS} -delete
    find "${BACKUP_DIR}" -type d -empty -delete
}

# Main backup process
main() {
    echo "🚀 Starting automated backup process..."
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Perform backups
    backup_postgres
    backup_redis
    backup_minio
    
    # Cleanup old backups
    cleanup_old_backups
    
    echo "✅ Backup process completed successfully!"
}

# Run main function
main
```

### Disaster Recovery Implementation

**Recovery Procedures:**
```bash
#!/bin/bash
# disaster-recovery.sh - Disaster recovery automation

BACKUP_DIR="/backups"
RECOVERY_POINT=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --recovery-point)
            RECOVERY_POINT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$RECOVERY_POINT" ]; then
    echo "Usage: $0 --recovery-point YYYYMMDD_HHMMSS"
    exit 1
fi

# PostgreSQL recovery
recover_postgres() {
    echo "🔄 Starting PostgreSQL recovery..."
    
    # Stop current database
    docker stop ecommerce-database
    
    # Remove old data
    docker volume rm ecommerce_postgres_data
    
    # Create new volume
    docker volume create ecommerce_postgres_data
    
    # Start database
    docker start ecommerce-database
    
    # Wait for database to be ready
    sleep 30
    
    # Restore from backup
    docker exec -i ecommerce-database pg_restore \
        -U postgres \
        -d ecommerce \
        --verbose \
        --clean \
        --if-exists \
        < "${BACKUP_DIR}/postgres_${RECOVERY_POINT}.dump"
    
    echo "✅ PostgreSQL recovery completed"
}

# Redis recovery
recover_redis() {
    echo "🔄 Starting Redis recovery..."
    
    # Stop Redis
    docker stop ecommerce-cache
    
    # Copy backup file
    docker cp "${BACKUP_DIR}/redis_${RECOVERY_POINT}.rdb" ecommerce-cache:/data/dump.rdb
    
    # Start Redis
    docker start ecommerce-cache
    
    echo "✅ Redis recovery completed"
}

# MinIO recovery
recover_minio() {
    echo "🔄 Starting MinIO recovery..."
    
    # Stop MinIO
    docker stop ecommerce-files
    
    # Remove old data
    docker volume rm ecommerce_minio_data
    
    # Create new volume
    docker volume create ecommerce_minio_data
    
    # Start MinIO
    docker start ecommerce-files
    
    # Wait for MinIO to be ready
    sleep 30
    
    # Restore data
    docker exec ecommerce-files mc mirror "${BACKUP_DIR}/minio_${RECOVERY_POINT}/" /data/
    
    echo "✅ MinIO recovery completed"
}

# Main recovery process
main() {
    echo "🚨 Starting disaster recovery process..."
    echo "Recovery point: ${RECOVERY_POINT}"
    
    # Confirm recovery
    read -p "This will overwrite current data. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Recovery cancelled"
        exit 1
    fi
    
    # Perform recovery
    recover_postgres
    recover_redis
    recover_minio
    
    echo "✅ Disaster recovery completed successfully!"
    echo "Please verify data integrity and application functionality"
}

# Run main function
main
```

---

## 📊 Part 5: Storage Performance Monitoring

### Storage Metrics Collection

**Comprehensive Storage Monitoring:**
```bash
#!/bin/bash
# storage-monitor.sh - Storage performance monitoring

echo "📊 E-Commerce Storage Performance Monitor"
echo "========================================"
echo "Timestamp: $(date)"
echo

# Docker volume usage
echo "💾 Volume Usage:"
docker system df -v | grep -A 20 "Local Volumes:"

echo
echo "📈 Container Storage Stats:"
for container in $(docker ps --format "{{.Names}}"); do
    echo "Container: $container"
    
    # Get container storage stats
    docker exec $container df -h / 2>/dev/null | tail -n 1 | \
        awk '{printf "  Root FS: %s used, %s available (%s usage)\n", $3, $4, $5}'
    
    # Get volume mount stats
    docker inspect $container | jq -r '.Mounts[]? | "  Volume: \(.Source) -> \(.Destination)"' 2>/dev/null
    
    echo
done

# I/O statistics
echo "⚡ I/O Performance:"
iostat -x 1 1 | grep -E "(Device|sd|nvme)" | tail -n +2

echo
echo "🔍 Storage Health Check:"

# Check for storage errors
dmesg | grep -i "error\|fail" | grep -i "storage\|disk\|sda\|sdb" | tail -5

# Check filesystem health
for mount in $(docker volume ls -q); do
    volume_path=$(docker volume inspect $mount | jq -r '.[0].Mountpoint')
    if [ -d "$volume_path" ]; then
        echo "Volume: $mount"
        echo "  Path: $volume_path"
        echo "  Usage: $(df -h $volume_path | tail -1 | awk '{print $5}')"
        echo "  Inodes: $(df -i $volume_path | tail -1 | awk '{print $5}')"
    fi
done
```

---

## 🧪 Part 6: Hands-On Storage Labs

### Lab 1: High-Performance Database Storage

**Objective:** Configure optimized PostgreSQL storage

```bash
# Create optimized storage setup
sudo mkdir -p /opt/postgres/{data,wal,logs}
sudo chown 999:999 /opt/postgres/{data,wal,logs}

# Create optimized Docker Compose
cat > docker-compose.postgres-optimized.yml << 'EOF'
version: '3.8'

services:
  postgres-optimized:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: secretpassword
      # Performance tuning
      POSTGRES_SHARED_BUFFERS: 2GB
      POSTGRES_EFFECTIVE_CACHE_SIZE: 6GB
      POSTGRES_WORK_MEM: 64MB
      POSTGRES_MAINTENANCE_WORK_MEM: 512MB
      POSTGRES_CHECKPOINT_COMPLETION_TARGET: 0.9
      POSTGRES_WAL_BUFFERS: 64MB
      POSTGRES_DEFAULT_STATISTICS_TARGET: 100
    volumes:
      - /opt/postgres/data:/var/lib/postgresql/data
      - /opt/postgres/wal:/var/lib/postgresql/wal
      - /opt/postgres/logs:/var/log/postgresql
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 1G
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4'
    ports:
      - "5432:5432"
EOF

# Deploy and test
docker-compose -f docker-compose.postgres-optimized.yml up -d

# Run performance test
docker exec postgres-optimized_postgres-optimized_1 \
  pgbench -i -s 100 ecommerce

docker exec postgres-optimized_postgres-optimized_1 \
  pgbench -c 10 -j 2 -t 1000 ecommerce
```

### Lab 2: Distributed Object Storage

**Objective:** Set up MinIO cluster for file storage

```bash
# Create MinIO cluster
cat > docker-compose.minio-cluster.yml << 'EOF'
version: '3.8'

services:
  minio1:
    image: minio/minio:latest
    command: server http://minio{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio1_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"

  minio2:
    image: minio/minio:latest
    command: server http://minio{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio2_data:/data

  minio3:
    image: minio/minio:latest
    command: server http://minio{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio3_data:/data

  minio4:
    image: minio/minio:latest
    command: server http://minio{1...4}/data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: secretpassword
    volumes:
      - minio4_data:/data

volumes:
  minio1_data:
  minio2_data:
  minio3_data:
  minio4_data:
EOF

# Deploy cluster
docker-compose -f docker-compose.minio-cluster.yml up -d

# Test cluster functionality
docker exec minio-cluster_minio1_1 mc alias set local http://localhost:9000 admin secretpassword
docker exec minio-cluster_minio1_1 mc mb local/ecommerce-images
docker exec minio-cluster_minio1_1 mc cp /etc/hosts local/ecommerce-images/test-file
```

---

## 🎓 Module Summary

You've mastered enterprise storage solutions by learning:

**Core Concepts:**
- Enterprise storage patterns and distributed systems
- Advanced volume management and storage drivers
- Multi-tier storage architectures

**Practical Skills:**
- Implementing high-performance storage for e-commerce applications
- Configuring backup and disaster recovery systems
- Setting up distributed storage clusters

**Enterprise Techniques:**
- Production-ready storage monitoring and alerting
- Automated backup and recovery procedures
- Performance optimization for different storage workloads

**Next Steps:**
- Implement storage solutions for your e-commerce project
- Set up automated backup and monitoring systems
- Prepare for Module 7: Advanced Orchestration Patterns

---

## 📚 Additional Resources

- [Docker Storage Documentation](https://docs.docker.com/storage/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [MinIO Distributed Setup](https://docs.min.io/docs/distributed-minio-quickstart-guide.html)
- [Redis Persistence Configuration](https://redis.io/topics/persistence)
}

type Volume struct {
    Name       string            `json:"name"`
    Path       string            `json:"path"`
    Options    map[string]string `json:"options"`
    Mountpoint string            `json:"mountpoint"`
    RefCount   int               `json:"ref_count"`
    Size       int64             `json:"size"`
    IOPS       int               `json:"iops"`
    Encrypted  bool              `json:"encrypted"`
}

func NewHPVolumeDriver(basePath string) *HPVolumeDriver {
    return &HPVolumeDriver{
        volumes:  make(map[string]*Volume),
        basePath: basePath,
    }
}

func (d *HPVolumeDriver) Create(req *volume.CreateRequest) error {
    d.mutex.Lock()
    defer d.mutex.Unlock()

    if _, exists := d.volumes[req.Name]; exists {
        return fmt.Errorf("volume %s already exists", req.Name)
    }

    vol := &Volume{
        Name:    req.Name,
        Path:    filepath.Join(d.basePath, req.Name),
        Options: req.Options,
    }

    // Parse options
    if size, ok := req.Options["size"]; ok {
        vol.Size = parseSize(size)
    }
    if iops, ok := req.Options["iops"]; ok {
        vol.IOPS = parseInt(iops)
    }
    if encrypted, ok := req.Options["encrypted"]; ok && encrypted == "true" {
        vol.Encrypted = true
    }

    // Create volume directory
    if err := os.MkdirAll(vol.Path, 0755); err != nil {
        return err
    }

    // Setup high-performance storage
    if err := d.setupHighPerformanceStorage(vol); err != nil {
        return err
    }

    d.volumes[req.Name] = vol
    log.Printf("Created volume: %s", req.Name)

    return nil
}

func (d *HPVolumeDriver) setupHighPerformanceStorage(vol *Volume) error {
    // Create sparse file for volume
    if vol.Size > 0 {
        volumeFile := filepath.Join(vol.Path, "volume.img")
        
        file, err := os.Create(volumeFile)
        if err != nil {
            return err
        }
        defer file.Close()

        // Create sparse file
        if err := file.Truncate(vol.Size); err != nil {
            return err
        }

        // Setup loop device for better performance
        if err := d.setupLoopDevice(volumeFile, vol); err != nil {
            log.Printf("Warning: Failed to setup loop device: %v", err)
        }
    }

    // Setup encryption if requested
    if vol.Encrypted {
        if err := d.setupEncryption(vol); err != nil {
            return err
        }
    }

    // Optimize for IOPS if specified
    if vol.IOPS > 0 {
        if err := d.optimizeForIOPS(vol); err != nil {
            log.Printf("Warning: Failed to optimize IOPS: %v", err)
        }
    }

    return nil
}

func (d *HPVolumeDriver) setupLoopDevice(volumeFile string, vol *Volume) error {
    // In production, would setup actual loop device
    log.Printf("Setting up loop device for %s", volumeFile)
    return nil
}

func (d *HPVolumeDriver) setupEncryption(vol *Volume) error {
    // Setup LUKS encryption
    log.Printf("Setting up encryption for volume %s", vol.Name)
    
    // In production implementation:
    // 1. Generate encryption key
    // 2. Setup LUKS container
    // 3. Format encrypted filesystem
    
    return nil
}

func (d *HPVolumeDriver) optimizeForIOPS(vol *Volume) error {
    // Optimize filesystem for high IOPS
    log.Printf("Optimizing volume %s for %d IOPS", vol.Name, vol.IOPS)
    
    // In production:
    // 1. Use appropriate filesystem (ext4, xfs, btrfs)
    // 2. Set optimal mount options
    // 3. Configure I/O scheduler
    
    return nil
}

func (d *HPVolumeDriver) Remove(req *volume.RemoveRequest) error {
    d.mutex.Lock()
    defer d.mutex.Unlock()

    vol, exists := d.volumes[req.Name]
    if !exists {
        return fmt.Errorf("volume %s not found", req.Name)
    }

    if vol.RefCount > 0 {
        return fmt.Errorf("volume %s is in use", req.Name)
    }

    // Cleanup encryption
    if vol.Encrypted {
        d.cleanupEncryption(vol)
    }

    // Remove volume directory
    if err := os.RemoveAll(vol.Path); err != nil {
        return err
    }

    delete(d.volumes, req.Name)
    log.Printf("Removed volume: %s", req.Name)

    return nil
}

func (d *HPVolumeDriver) cleanupEncryption(vol *Volume) {
    log.Printf("Cleaning up encryption for volume %s", vol.Name)
    // Cleanup LUKS container
}

func (d *HPVolumeDriver) Mount(req *volume.MountRequest) (*volume.MountResponse, error) {
    d.mutex.Lock()
    defer d.mutex.Unlock()

    vol, exists := d.volumes[req.Name]
    if !exists {
        return nil, fmt.Errorf("volume %s not found", req.Name)
    }

    vol.RefCount++
    vol.Mountpoint = vol.Path

    // Setup optimal mount options
    if err := d.setupOptimalMount(vol); err != nil {
        return nil, err
    }

    return &volume.MountResponse{Mountpoint: vol.Mountpoint}, nil
}

func (d *HPVolumeDriver) setupOptimalMount(vol *Volume) error {
    // Setup optimal mount options based on volume configuration
    mountOptions := []string{"rw"}

    if vol.IOPS > 1000 {
        // High IOPS optimizations
        mountOptions = append(mountOptions, "noatime", "nodiratime")
    }

    if vol.Size > 100*1024*1024*1024 { // > 100GB
        // Large volume optimizations
        mountOptions = append(mountOptions, "largeio")
    }

    log.Printf("Mounting volume %s with options: %v", vol.Name, mountOptions)
    return nil
}

func (d *HPVolumeDriver) Unmount(req *volume.UnmountRequest) error {
    d.mutex.Lock()
    defer d.mutex.Unlock()

    vol, exists := d.volumes[req.Name]
    if !exists {
        return fmt.Errorf("volume %s not found", req.Name)
    }

    if vol.RefCount > 0 {
        vol.RefCount--
    }

    log.Printf("Unmounted volume: %s (ref count: %d)", req.Name, vol.RefCount)
    return nil
}

func (d *HPVolumeDriver) Path(req *volume.PathRequest) (*volume.PathResponse, error) {
    d.mutex.RLock()
    defer d.mutex.RUnlock()

    vol, exists := d.volumes[req.Name]
    if !exists {
        return nil, fmt.Errorf("volume %s not found", req.Name)
    }

    return &volume.PathResponse{Mountpoint: vol.Mountpoint}, nil
}

func (d *HPVolumeDriver) Get(req *volume.GetRequest) (*volume.GetResponse, error) {
    d.mutex.RLock()
    defer d.mutex.RUnlock()

    vol, exists := d.volumes[req.Name]
    if !exists {
        return nil, fmt.Errorf("volume %s not found", req.Name)
    }

    return &volume.GetResponse{
        Volume: &volume.Volume{
            Name:       vol.Name,
            Mountpoint: vol.Mountpoint,
        },
    }, nil
}

func (d *HPVolumeDriver) List() (*volume.ListResponse, error) {
    d.mutex.RLock()
    defer d.mutex.RUnlock()

    var volumes []*volume.Volume
    for _, vol := range d.volumes {
        volumes = append(volumes, &volume.Volume{
            Name:       vol.Name,
            Mountpoint: vol.Mountpoint,
        })
    }

    return &volume.ListResponse{Volumes: volumes}, nil
}

func (d *HPVolumeDriver) Capabilities() *volume.CapabilitiesResponse {
    return &volume.CapabilitiesResponse{
        Capabilities: volume.Capability{Scope: "local"},
    }
}

func parseSize(sizeStr string) int64 {
    // Parse size string (e.g., "10GB", "1TB")
    // Simplified implementation
    return 1024 * 1024 * 1024 // 1GB default
}

func parseInt(intStr string) int {
    // Parse integer string
    return 1000 // Default IOPS
}

func main() {
    driver := NewHPVolumeDriver("/var/lib/hp-volumes")
    handler := volume.NewHandler(driver)

    log.Println("Starting high-performance volume driver...")
    if err := handler.ServeUnix("hp-volume", 0); err != nil {
        log.Fatal(err)
    }
}
```

### Distributed Storage Cluster
```python
#!/usr/bin/env python3
# distributed-storage.py - Distributed storage cluster for containers

import hashlib
import json
import time
import threading
import socket
from collections import defaultdict
import requests

class DistributedStorageNode:
    def __init__(self, node_id, listen_port, cluster_nodes=None):
        self.node_id = node_id
        self.listen_port = listen_port
        self.cluster_nodes = cluster_nodes or []
        self.local_storage = {}
        self.metadata = {}
        self.replication_factor = 3
        self.running = True
        
    def start(self):
        """Start the storage node"""
        # Start HTTP server for API
        threading.Thread(target=self.start_api_server, daemon=True).start()
        
        # Start replication worker
        threading.Thread(target=self.replication_worker, daemon=True).start()
        
        # Start health checker
        threading.Thread(target=self.health_checker, daemon=True).start()
        
        print(f"Storage node {self.node_id} started on port {self.listen_port}")
        
    def start_api_server(self):
        """Start HTTP API server"""
        from http.server import HTTPServer, BaseHTTPRequestHandler
        
        class StorageHandler(BaseHTTPRequestHandler):
            def __init__(self, storage_node):
                self.storage_node = storage_node
                super().__init__()
                
            def do_GET(self):
                if self.path.startswith('/data/'):
                    key = self.path[6:]  # Remove '/data/'
                    data = self.storage_node.get_data(key)
                    if data:
                        self.send_response(200)
                        self.send_header('Content-Type', 'application/octet-stream')
                        self.end_headers()
                        self.wfile.write(data)
                    else:
                        self.send_response(404)
                        self.end_headers()
                elif self.path == '/health':
                    self.send_response(200)
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    health = self.storage_node.get_health_status()
                    self.wfile.write(json.dumps(health).encode())
                else:
                    self.send_response(404)
                    self.end_headers()
                    
            def do_PUT(self):
                if self.path.startswith('/data/'):
                    key = self.path[6:]
                    content_length = int(self.headers['Content-Length'])
                    data = self.rfile.read(content_length)
                    
                    success = self.storage_node.store_data(key, data)
                    if success:
                        self.send_response(201)
                    else:
                        self.send_response(500)
                    self.end_headers()
                else:
                    self.send_response(404)
                    self.end_headers()
                    
            def do_DELETE(self):
                if self.path.startswith('/data/'):
                    key = self.path[6:]
                    success = self.storage_node.delete_data(key)
                    if success:
                        self.send_response(204)
                    else:
                        self.send_response(404)
                    self.end_headers()
                else:
                    self.send_response(404)
                    self.end_headers()
        
        # Create handler with storage node reference
        def handler_factory(*args):
            return StorageHandler(self, *args)
            
        server = HTTPServer(('', self.listen_port), handler_factory)
        server.serve_forever()
        
    def store_data(self, key, data):
        """Store data with replication"""
        try:
            # Store locally
            self.local_storage[key] = data
            self.metadata[key] = {
                'size': len(data),
                'checksum': hashlib.sha256(data).hexdigest(),
                'timestamp': time.time(),
                'replicas': [self.node_id]
            }
            
            # Replicate to other nodes
            replica_nodes = self.select_replica_nodes(key)
            for node in replica_nodes:
                if node != self.node_id:
                    self.replicate_to_node(node, key, data)
                    
            return True
        except Exception as e:
            print(f"Error storing data {key}: {e}")
            return False
            
    def get_data(self, key):
        """Get data from local storage or replicas"""
        # Try local storage first
        if key in self.local_storage:
            return self.local_storage[key]
            
        # Try replicas
        if key in self.metadata:
            for replica_node in self.metadata[key]['replicas']:
                if replica_node != self.node_id:
                    data = self.fetch_from_replica(replica_node, key)
                    if data:
                        # Cache locally
                        self.local_storage[key] = data
                        return data
                        
        return None
        
    def delete_data(self, key):
        """Delete data from all replicas"""
        try:
            # Delete locally
            if key in self.local_storage:
                del self.local_storage[key]
                
            # Delete from replicas
            if key in self.metadata:
                for replica_node in self.metadata[key]['replicas']:
                    if replica_node != self.node_id:
                        self.delete_from_replica(replica_node, key)
                        
                del self.metadata[key]
                
            return True
        except Exception as e:
            print(f"Error deleting data {key}: {e}")
            return False
            
    def select_replica_nodes(self, key):
        """Select nodes for replication using consistent hashing"""
        # Simple consistent hashing
        hash_value = int(hashlib.sha256(key.encode()).hexdigest(), 16)
        
        # Sort nodes by hash distance
        node_distances = []
        for node in self.cluster_nodes:
            node_hash = int(hashlib.sha256(node.encode()).hexdigest(), 16)
            distance = abs(hash_value - node_hash)
            node_distances.append((distance, node))
            
        node_distances.sort()
        
        # Select top N nodes for replication
        selected_nodes = [node for _, node in node_distances[:self.replication_factor]]
        return selected_nodes
        
    def replicate_to_node(self, node, key, data):
        """Replicate data to another node"""
        try:
            node_url = f"http://{node}/data/{key}"
            response = requests.put(node_url, data=data, timeout=10)
            
            if response.status_code == 201:
                if key in self.metadata:
                    self.metadata[key]['replicas'].append(node)
                return True
        except Exception as e:
            print(f"Error replicating to node {node}: {e}")
            
        return False
        
    def fetch_from_replica(self, node, key):
        """Fetch data from replica node"""
        try:
            node_url = f"http://{node}/data/{key}"
            response = requests.get(node_url, timeout=10)
            
            if response.status_code == 200:
                return response.content
        except Exception as e:
            print(f"Error fetching from replica {node}: {e}")
            
        return None
        
    def delete_from_replica(self, node, key):
        """Delete data from replica node"""
        try:
            node_url = f"http://{node}/data/{key}"
            response = requests.delete(node_url, timeout=10)
            return response.status_code == 204
        except Exception as e:
            print(f"Error deleting from replica {node}: {e}")
            return False
            
    def replication_worker(self):
        """Background worker for replication maintenance"""
        while self.running:
            try:
                self.check_replication_health()
                self.rebalance_data()
            except Exception as e:
                print(f"Replication worker error: {e}")
                
            time.sleep(60)  # Check every minute
            
    def check_replication_health(self):
        """Check health of replicas and repair if needed"""
        for key, metadata in self.metadata.items():
            healthy_replicas = []
            
            for replica_node in metadata['replicas']:
                if self.check_replica_health(replica_node, key):
                    healthy_replicas.append(replica_node)
                    
            # If we have fewer healthy replicas than desired, create new ones
            if len(healthy_replicas) < self.replication_factor:
                self.repair_replicas(key, healthy_replicas)
                
    def check_replica_health(self, node, key):
        """Check if replica node has the data"""
        try:
            node_url = f"http://{node}/data/{key}"
            response = requests.head(node_url, timeout=5)
            return response.status_code == 200
        except:
            return False
            
    def repair_replicas(self, key, healthy_replicas):
        """Repair missing replicas"""
        if key not in self.local_storage:
            return
            
        needed_replicas = self.replication_factor - len(healthy_replicas)
        available_nodes = [node for node in self.cluster_nodes 
                          if node not in healthy_replicas]
        
        for i in range(min(needed_replicas, len(available_nodes))):
            node = available_nodes[i]
            if self.replicate_to_node(node, key, self.local_storage[key]):
                print(f"Repaired replica for {key} on node {node}")
                
    def rebalance_data(self):
        """Rebalance data across cluster"""
        # Simple rebalancing logic
        # In production, would implement more sophisticated algorithms
        pass
        
    def health_checker(self):
        """Monitor cluster health"""
        while self.running:
            try:
                cluster_health = self.get_cluster_health()
                if cluster_health['unhealthy_nodes']:
                    print(f"Unhealthy nodes detected: {cluster_health['unhealthy_nodes']}")
                    
            except Exception as e:
                print(f"Health checker error: {e}")
                
            time.sleep(30)
            
    def get_cluster_health(self):
        """Get cluster health status"""
        healthy_nodes = []
        unhealthy_nodes = []
        
        for node in self.cluster_nodes:
            if self.ping_node(node):
                healthy_nodes.append(node)
            else:
                unhealthy_nodes.append(node)
                
        return {
            'healthy_nodes': healthy_nodes,
            'unhealthy_nodes': unhealthy_nodes,
            'total_nodes': len(self.cluster_nodes),
            'health_percentage': len(healthy_nodes) / len(self.cluster_nodes) * 100
        }
        
    def ping_node(self, node):
        """Ping a cluster node"""
        try:
            response = requests.get(f"http://{node}/health", timeout=5)
            return response.status_code == 200
        except:
            return False
            
    def get_health_status(self):
        """Get this node's health status"""
        return {
            'node_id': self.node_id,
            'status': 'healthy',
            'storage_used': len(self.local_storage),
            'metadata_entries': len(self.metadata),
            'uptime': time.time()
        }

class DistributedStorageClient:
    def __init__(self, cluster_nodes):
        self.cluster_nodes = cluster_nodes
        
    def store(self, key, data):
        """Store data in the cluster"""
        # Select primary node using consistent hashing
        primary_node = self.select_primary_node(key)
        
        try:
            response = requests.put(f"http://{primary_node}/data/{key}", 
                                  data=data, timeout=30)
            return response.status_code == 201
        except Exception as e:
            print(f"Error storing data: {e}")
            return False
            
    def retrieve(self, key):
        """Retrieve data from the cluster"""
        # Try primary node first
        primary_node = self.select_primary_node(key)
        
        try:
            response = requests.get(f"http://{primary_node}/data/{key}", timeout=10)
            if response.status_code == 200:
                return response.content
        except:
            pass
            
        # Try other nodes if primary fails
        for node in self.cluster_nodes:
            if node != primary_node:
                try:
                    response = requests.get(f"http://{node}/data/{key}", timeout=10)
                    if response.status_code == 200:
                        return response.content
                except:
                    continue
                    
        return None
        
    def delete(self, key):
        """Delete data from the cluster"""
        primary_node = self.select_primary_node(key)
        
        try:
            response = requests.delete(f"http://{primary_node}/data/{key}", timeout=10)
            return response.status_code == 204
        except Exception as e:
            print(f"Error deleting data: {e}")
            return False
            
    def select_primary_node(self, key):
        """Select primary node for key using consistent hashing"""
        hash_value = int(hashlib.sha256(key.encode()).hexdigest(), 16)
        node_index = hash_value % len(self.cluster_nodes)
        return self.cluster_nodes[node_index]

def main():
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python distributed-storage.py <node_id> <port> [cluster_nodes...]")
        sys.exit(1)
        
    node_id = sys.argv[1]
    port = int(sys.argv[2])
    cluster_nodes = sys.argv[3:] if len(sys.argv) > 3 else []
    
    # Start storage node
    node = DistributedStorageNode(node_id, port, cluster_nodes)
    node.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        node.running = False
        print(f"Shutting down node {node_id}")

if __name__ == "__main__":
    main()
```
