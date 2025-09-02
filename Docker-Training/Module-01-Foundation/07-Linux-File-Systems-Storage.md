# 🗂️ Linux File Systems & Storage: Complete Guide for Docker

## 🎯 Learning Objectives
- Master Linux file system hierarchy and types
- Understand mount operations and storage management
- Learn disk partitioning and volume management
- Prepare for Docker's overlay2 storage driver concepts

---

## 📁 Linux File System Hierarchy Standard (FHS)

### Complete Directory Structure
```
/ (Root Directory)
├── bin/          # Essential user command binaries
├── boot/         # Boot loader files, kernel images
├── dev/          # Device files (hardware interfaces)
├── etc/          # System configuration files
├── home/         # User home directories
├── lib/          # Essential shared libraries
├── lib64/        # 64-bit shared libraries
├── media/        # Removable media mount points
├── mnt/          # Temporary mount points
├── opt/          # Optional application software
├── proc/         # Process and kernel information (virtual)
├── root/         # Root user's home directory
├── run/          # Runtime data (PID files, sockets)
├── sbin/         # Essential system binaries
├── srv/          # Service data
├── sys/          # System information (virtual)
├── tmp/          # Temporary files
├── usr/          # User programs and data
│   ├── bin/      # User command binaries
│   ├── lib/      # Libraries for /usr/bin and /usr/sbin
│   ├── local/    # Local software installations
│   ├── sbin/     # Non-essential system binaries
│   └── share/    # Architecture-independent data
└── var/          # Variable data files
    ├── cache/    # Application cache data
    ├── lib/      # Variable state information
    ├── lock/     # Lock files
    ├── log/      # Log files
    ├── run/      # Runtime variable data
    ├── spool/    # Spool directories
    └── tmp/      # Temporary files preserved between reboots
```

### Directory Purpose Deep Dive

#### /bin - Essential User Binaries
```bash
# List essential commands
ls -la /bin/

# Common commands in /bin
cat /bin/bash     # Shell
cat /bin/ls       # List files
cat /bin/cp       # Copy files
cat /bin/mv       # Move files
cat /bin/rm       # Remove files
cat /bin/mkdir    # Make directories
```

**Expected Output:**
```
-rwxr-xr-x 1 root root 1183448 Apr 18  2022 /bin/bash
-rwxr-xr-x 1 root root  138208 Sep  5  2019 /bin/ls
-rwxr-xr-x 1 root root  153976 Sep  5  2019 /bin/cp
```

**Docker Relevance:** Container images include these essential binaries for basic operations.

#### /etc - Configuration Files
```bash
# System configuration files
ls -la /etc/ | head -20

# Important configuration files
cat /etc/passwd     # User accounts
cat /etc/group      # Group definitions
cat /etc/hosts      # Host name resolution
cat /etc/fstab      # File system mount table
cat /etc/crontab    # Scheduled tasks
```

**Expected Output:**
```
drwxr-xr-x   2 root root    4096 Jan 15 10:30 apt
-rw-r--r--   1 root root    3028 Jan 15 10:30 bash.bashrc
-rw-r--r--   1 root root      45 Jan 15 10:30 environment
-rw-r--r--   1 root root    2969 Jan 15 10:30 fstab
-rw-r--r--   1 root root     220 Jan 15 10:30 hosts
```

**Docker Relevance:** Container configuration often involves mounting /etc files or creating custom configurations.

#### /proc - Process Information (Virtual)
```bash
# Process information
ls -la /proc/ | head -10

# System information
cat /proc/version      # Kernel version
cat /proc/cpuinfo      # CPU information
cat /proc/meminfo      # Memory information
cat /proc/mounts       # Currently mounted filesystems
cat /proc/filesystems  # Supported filesystems
```

**Expected Output:**
```
dr-xr-xr-x   9 root root          0 Jan 15 10:30 1
dr-xr-xr-x   9 root root          0 Jan 15 10:30 2
dr-xr-xr-x   9 root root          0 Jan 15 10:30 3
-r--r--r--   1 root root          0 Jan 15 10:30 version
-r--r--r--   1 root root          0 Jan 15 10:30 cpuinfo
```

**Docker Relevance:** Containers share the host's /proc filesystem, providing system information.

#### /var - Variable Data
```bash
# Variable data directories
ls -la /var/

# Log files
ls -la /var/log/
tail /var/log/syslog

# Package cache
ls -la /var/cache/apt/

# Application data
ls -la /var/lib/
```

**Expected Output:**
```
drwxr-xr-x  2 root root  4096 Jan 15 10:30 cache
drwxr-xr-x  2 root root  4096 Jan 15 10:30 lib
drwxrwxr-x  2 root syslog 4096 Jan 15 10:30 log
drwxr-xr-x  2 root root  4096 Jan 15 10:30 spool
```

**Docker Relevance:** Docker stores container data in /var/lib/docker/, and containers often mount /var directories for persistent data.

---

## 💾 File System Types

### Common File System Types

#### ext4 (Fourth Extended File System)
```bash
# Check ext4 filesystem
df -T | grep ext4

# ext4 features
tune2fs -l /dev/sda1 | grep -E "(Filesystem features|Block size|Inode count)"

# Create ext4 filesystem
sudo mkfs.ext4 /dev/sdb1
```

**Expected Output:**
```
/dev/sda1      ext4      20G  15G  4.2G  79% /
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file dir_nlink extra_isize metadata_csum
Block size:               4096
Inode count:              1310720
```

**Characteristics:**
- **Journaling**: Prevents corruption during crashes
- **Large files**: Supports files up to 16TB
- **Large volumes**: Supports volumes up to 1EB
- **Extents**: Efficient storage of large files
- **Backward compatibility**: Can mount as ext2/ext3

#### xfs (XFS File System)
```bash
# Check XFS filesystem
df -T | grep xfs

# XFS information
xfs_info /dev/sdb1

# Create XFS filesystem
sudo mkfs.xfs /dev/sdb1
```

**Expected Output:**
```
meta-data=/dev/sdb1              isize=512    agcount=4, agsize=655360 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1
data     =                       bsize=4096   blocks=2621440, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
```

**Characteristics:**
- **High performance**: Optimized for large files and high I/O
- **Scalability**: Supports very large filesystems
- **Online defragmentation**: Can defragment while mounted
- **Delayed allocation**: Improves performance

#### btrfs (B-tree File System)
```bash
# Check Btrfs filesystem
df -T | grep btrfs

# Btrfs information
sudo btrfs filesystem show
sudo btrfs filesystem usage /

# Create Btrfs filesystem
sudo mkfs.btrfs /dev/sdb1
```

**Expected Output:**
```
Label: none  uuid: a1b2c3d4-e5f6-7890-abcd-ef1234567890
        Total devices 1 FS bytes used 1.50GiB
        devid    1 size 10.00GiB used 3.02GiB path /dev/sdb1

Overall:
    Device size:                  10.00GiB
    Device allocated:              3.02GiB
    Device unallocated:            6.98GiB
    Device missing:                  0.00B
    Used:                          1.50GiB
    Free (estimated):              8.25GiB
```

**Characteristics:**
- **Copy-on-write**: Efficient snapshots and cloning
- **Checksums**: Data integrity verification
- **Compression**: Built-in compression support
- **RAID**: Software RAID capabilities
- **Snapshots**: Instant filesystem snapshots

#### overlay2 (Docker's Storage Driver)
```bash
# Docker's overlay2 information
sudo ls -la /var/lib/docker/overlay2/

# Overlay2 mount information
mount | grep overlay2

# Docker storage driver info
docker info | grep -A 10 "Storage Driver"
```

**Expected Output:**
```
Storage Driver: overlay2
 Backing Filesystem: ext4
 Supports d_type: true
 Native Overlay Diff: true
 userxattr: false
```

**How overlay2 Works:**
```
Container Layer (Read/Write)
├── Upper Dir: /var/lib/docker/overlay2/abc123/diff
├── Work Dir:  /var/lib/docker/overlay2/abc123/work
└── Merged:    /var/lib/docker/overlay2/abc123/merged

Image Layers (Read-Only)
├── Lower Dir: /var/lib/docker/overlay2/def456/diff
├── Lower Dir: /var/lib/docker/overlay2/ghi789/diff
└── Lower Dir: /var/lib/docker/overlay2/jkl012/diff
```

---

## 🔧 Mount Operations

### Understanding Mount Points

#### What is Mounting?
Mounting is the process of making a filesystem accessible at a specific directory (mount point) in the Linux directory tree.

```bash
# View currently mounted filesystems
mount

# View with filesystem types
mount -t ext4

# View specific mount point
mount | grep /home
```

**Expected Output:**
```
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)
/dev/sda2 on /home type ext4 (rw,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev)
```

#### Mount Command Syntax
```bash
# Basic mount syntax
sudo mount [options] <device> <mount-point>

# Mount with filesystem type
sudo mount -t ext4 /dev/sdb1 /mnt/data

# Mount with options
sudo mount -o rw,noexec,nosuid /dev/sdb1 /mnt/data
```

### Practical Mount Examples

#### Mounting a USB Drive
```bash
# List available devices
lsblk

# Create mount point
sudo mkdir -p /mnt/usb

# Mount USB drive
sudo mount /dev/sdb1 /mnt/usb

# Verify mount
df -h /mnt/usb
ls -la /mnt/usb

# Unmount when done
sudo umount /mnt/usb
```

**Expected Output:**
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
├─sda1   8:1    0   19G  0 part /
└─sda2   8:2    0    1G  0 part [SWAP]
sdb      8:16   1    8G  0 disk 
└─sdb1   8:17   1    8G  0 part 

Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb1       7.5G  1.2G  6.0G  17% /mnt/usb
```

#### Bind Mounts (Docker-style)
```bash
# Create directories
mkdir -p /home/user/source
mkdir -p /home/user/target

# Create test file
echo "Hello from source" > /home/user/source/test.txt

# Bind mount (like Docker volume mount)
sudo mount --bind /home/user/source /home/user/target

# Verify bind mount
cat /home/user/target/test.txt
ls -la /home/user/target/

# Changes in either location are reflected in both
echo "Modified in target" >> /home/user/target/test.txt
cat /home/user/source/test.txt
```

**Expected Output:**
```
Hello from source
Modified in target
```

#### tmpfs Mounts (Memory-based)
```bash
# Create tmpfs mount (like Docker tmpfs)
sudo mkdir -p /mnt/memory
sudo mount -t tmpfs -o size=100M tmpfs /mnt/memory

# Verify tmpfs
df -h /mnt/memory
mount | grep tmpfs

# Test memory filesystem
echo "This is in RAM" > /mnt/memory/test.txt
cat /mnt/memory/test.txt

# Check memory usage
free -h
```

**Expected Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           100M     0  100M   0% /mnt/memory

tmpfs on /mnt/memory type tmpfs (rw,relatime,size=102400k)
```

### Mount Options Deep Dive

#### Common Mount Options
```bash
# Read-write (default)
sudo mount -o rw /dev/sdb1 /mnt/data

# Read-only
sudo mount -o ro /dev/sdb1 /mnt/data

# No execute permissions
sudo mount -o noexec /dev/sdb1 /mnt/data

# No setuid/setgid
sudo mount -o nosuid /dev/sdb1 /mnt/data

# No device files
sudo mount -o nodev /dev/sdb1 /mnt/data

# Combination of options
sudo mount -o rw,noexec,nosuid,nodev /dev/sdb1 /mnt/data
```

#### Security-Focused Mount Options
```bash
# Secure mount for untrusted content
sudo mount -o ro,noexec,nosuid,nodev /dev/sdb1 /mnt/untrusted

# Verify security options
mount | grep /mnt/untrusted

# Test restrictions
# This should fail due to noexec
cp /bin/ls /mnt/untrusted/
chmod +x /mnt/untrusted/ls
/mnt/untrusted/ls  # Permission denied
```

---

## 💿 Disk Management

### Disk Information Commands

#### lsblk - List Block Devices
```bash
# Basic block device listing
lsblk

# Detailed information
lsblk -f

# Show filesystem information
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID
```

**Expected Output:**
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
├─sda1   8:1    0   19G  0 part /
└─sda2   8:2    0    1G  0 part [SWAP]
sr0     11:0    1 1024M  0 rom  

NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda                                                      
├─sda1 ext4         a1b2c3d4-e5f6-7890-abcd-ef1234567890 /
└─sda2 swap         f1e2d3c4-b5a6-9870-dcba-fe0987654321 [SWAP]
```

#### fdisk - Disk Partitioning
```bash
# List all disks
sudo fdisk -l

# Interactive partitioning
sudo fdisk /dev/sdb

# Common fdisk commands:
# p - print partition table
# n - new partition
# d - delete partition
# w - write changes
# q - quit without saving
```

**Expected Output:**
```
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x12345678

Device     Boot Start      End  Sectors Size Id Type
/dev/sda1  *     2048 39845887 39843840  19G 83 Linux
/dev/sda2      39847934 41940991  2093058   1G 82 Linux swap / Solaris
```

#### df - Disk Space Usage
```bash
# Basic disk usage
df

# Human-readable format
df -h

# Show filesystem types
df -T

# Show inodes usage
df -i

# Specific filesystem
df -h /
```

**Expected Output:**
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        19G   15G  3.2G  83% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           2.0G  1.2M  2.0G   1% /run
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
```

#### du - Directory Usage
```bash
# Directory size
du -h /home/user

# Summarize directory
du -sh /home/user

# Show all subdirectories
du -h --max-depth=2 /home/user

# Largest directories
du -h /home/user | sort -hr | head -10

# Exclude certain directories
du -h --exclude="*.cache" /home/user
```

**Expected Output:**
```
4.0K    /home/user/.ssh
12K     /home/user/.config
8.0K    /home/user/Documents
156K    /home/user/.cache
180K    /home/user
```

### Disk Partitioning Example

#### Creating a New Partition
```bash
# Step 1: Identify the disk
sudo fdisk -l | grep "Disk /dev"

# Step 2: Start fdisk
sudo fdisk /dev/sdb

# Step 3: Create partition (in fdisk)
# Command (m for help): n
# Partition type: p (primary)
# Partition number: 1
# First sector: (default)
# Last sector: +5G

# Step 4: Write changes
# Command (m for help): w

# Step 5: Format the partition
sudo mkfs.ext4 /dev/sdb1

# Step 6: Create mount point and mount
sudo mkdir -p /mnt/newdisk
sudo mount /dev/sdb1 /mnt/newdisk

# Step 7: Verify
df -h /mnt/newdisk
```

---

## 🔄 Logical Volume Management (LVM)

### LVM Concepts
```
Physical Volumes (PV) → Volume Groups (VG) → Logical Volumes (LV)
     /dev/sdb              vg_data           lv_app_data
     /dev/sdc                                lv_log_data
```

### LVM Commands

#### Physical Volumes
```bash
# Create physical volume
sudo pvcreate /dev/sdb /dev/sdc

# List physical volumes
sudo pvs
sudo pvdisplay

# Remove physical volume
sudo pvremove /dev/sdb
```

**Expected Output:**
```
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sdb          lvm2 ---   5.00g 5.00g
  /dev/sdc          lvm2 ---   5.00g 5.00g
```

#### Volume Groups
```bash
# Create volume group
sudo vgcreate vg_data /dev/sdb /dev/sdc

# List volume groups
sudo vgs
sudo vgdisplay

# Extend volume group
sudo vgextend vg_data /dev/sdd

# Remove volume group
sudo vgremove vg_data
```

**Expected Output:**
```
  VG      #PV #LV #SN Attr   VSize  VFree
  vg_data   2   0   0 wz--n- 10.00g 10.00g
```

#### Logical Volumes
```bash
# Create logical volume
sudo lvcreate -L 3G -n lv_app_data vg_data

# List logical volumes
sudo lvs
sudo lvdisplay

# Extend logical volume
sudo lvextend -L +2G /dev/vg_data/lv_app_data

# Format and mount
sudo mkfs.ext4 /dev/vg_data/lv_app_data
sudo mkdir -p /mnt/app_data
sudo mount /dev/vg_data/lv_app_data /mnt/app_data
```

**Expected Output:**
```
  LV          VG      Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_app_data vg_data -wi-a----- 3.00g
```

---

## 🔍 File System Monitoring and Troubleshooting

### I/O Monitoring

#### iostat - I/O Statistics
```bash
# Install sysstat if needed
sudo apt install sysstat

# Basic I/O statistics
iostat

# Continuous monitoring (every 2 seconds)
iostat 2

# Extended statistics
iostat -x 2

# Specific device
iostat -x /dev/sda 2
```

**Expected Output:**
```
Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
sda              1.23    4.56     15.67     89.12     0.12     2.34   8.89  33.89    2.34    5.67   0.02    12.73    19.54   1.23   0.67
```

#### iotop - I/O by Process
```bash
# Install iotop
sudo apt install iotop

# Monitor I/O by process
sudo iotop

# Show only processes doing I/O
sudo iotop -o

# Show accumulated I/O
sudo iotop -a
```

### File System Checking

#### fsck - File System Check
```bash
# Check filesystem (unmounted)
sudo fsck /dev/sdb1

# Force check
sudo fsck -f /dev/sdb1

# Check and repair automatically
sudo fsck -y /dev/sdb1

# Check specific filesystem type
sudo fsck.ext4 /dev/sdb1
```

**Expected Output:**
```
fsck from util-linux 2.34
e2fsck 1.45.5 (07-Jan-2020)
/dev/sdb1: clean, 11/327680 files, 26156/1310720 blocks
```

#### File System Repair
```bash
# ext4 filesystem repair
sudo e2fsck -f -y /dev/sdb1

# XFS filesystem repair
sudo xfs_repair /dev/sdb1

# Check bad blocks
sudo badblocks -v /dev/sdb1
```

---

## 🐳 Docker Storage Integration

### Understanding Docker's Storage
```bash
# Docker storage information
docker info | grep -A 20 "Storage Driver"

# Docker root directory
sudo ls -la /var/lib/docker/

# Overlay2 directories
sudo ls -la /var/lib/docker/overlay2/ | head -10

# Container layer information
docker inspect container_name | grep -A 10 "GraphDriver"
```

**Expected Output:**
```
Storage Driver: overlay2
 Backing Filesystem: ext4
 Supports d_type: true
 Native Overlay Diff: true
 userxattr: false

"GraphDriver": {
    "Data": {
        "LowerDir": "/var/lib/docker/overlay2/abc123/diff:/var/lib/docker/overlay2/def456/diff",
        "MergedDir": "/var/lib/docker/overlay2/ghi789/merged",
        "UpperDir": "/var/lib/docker/overlay2/ghi789/diff",
        "WorkDir": "/var/lib/docker/overlay2/ghi789/work"
    },
    "Name": "overlay2"
}
```

### Docker Volume Storage
```bash
# Docker volumes location
sudo ls -la /var/lib/docker/volumes/

# Create and inspect volume
docker volume create test-volume
docker volume inspect test-volume

# Volume mountpoint
sudo ls -la /var/lib/docker/volumes/test-volume/_data/
```

### Storage Performance for Docker
```bash
# Test filesystem performance for Docker
sudo mkdir -p /docker-test
cd /docker-test

# Write performance test
sudo dd if=/dev/zero of=testfile bs=1M count=1000 oflag=direct

# Read performance test
sudo dd if=testfile of=/dev/null bs=1M iflag=direct

# Random I/O test
sudo fio --name=random-rw --ioengine=libaio --iodepth=4 --rw=randrw --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting
```

---

## 🚀 Next Steps

You now have comprehensive knowledge of Linux file systems and storage:

- ✅ **File System Hierarchy**: Complete understanding of Linux directory structure
- ✅ **File System Types**: ext4, xfs, btrfs, overlay2 characteristics and usage
- ✅ **Mount Operations**: Mounting, unmounting, bind mounts, tmpfs
- ✅ **Disk Management**: Partitioning, formatting, LVM concepts
- ✅ **Monitoring**: I/O statistics, performance analysis, troubleshooting
- ✅ **Docker Integration**: Understanding Docker's storage architecture

**Ready for Module 1, Part 8: Security & Hardening** where you'll learn system security fundamentals essential for container security!
