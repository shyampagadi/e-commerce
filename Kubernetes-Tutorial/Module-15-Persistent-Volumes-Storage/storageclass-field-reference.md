# 🏪 **StorageClass Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **StorageClass Manifest Structure**

```yaml
apiVersion: storage.k8s.io/v1             # FIXED VALUE: storage.k8s.io/v1
kind: StorageClass                        # FIXED VALUE: StorageClass
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  # namespace: N/A                        # StorageClass is cluster-scoped
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs
    storageclass.kubernetes.io/is-default-class: string  # VALUES: "true"|"false"
    key: value
provisioner: string                       # REQUIRED: provisioner name
parameters:                               # OPTIONAL: provisioner-specific parameters
  key: value                              # FORMAT: string key-value pairs
reclaimPolicy: string                     # OPTIONAL: Delete|Retain (default: Delete)
allowVolumeExpansion: boolean             # OPTIONAL: true|false (default: false)
mountOptions:                             # OPTIONAL: array of mount options
  - string
volumeBindingMode: string                 # OPTIONAL: Immediate|WaitForFirstConsumer (default: Immediate)
allowedTopologies:                        # OPTIONAL: topology constraints
  - matchLabelExpressions:                # REQUIRED: array of expressions
      - key: string                       # REQUIRED: topology key
        values:                           # REQUIRED: array of values
          - string
```

## 📊 **Field Value Details**

### **provisioner Values**

#### **AWS EBS Provisioners**
```yaml
# IN-TREE PROVISIONER (deprecated):
provisioner: kubernetes.io/aws-ebs

# CSI PROVISIONER (recommended):
provisioner: ebs.csi.aws.com
```

#### **GCP Persistent Disk Provisioners**
```yaml
# IN-TREE PROVISIONER (deprecated):
provisioner: kubernetes.io/gce-pd

# CSI PROVISIONER (recommended):
provisioner: pd.csi.storage.gke.io
```

#### **Azure Disk Provisioners**
```yaml
# IN-TREE PROVISIONER (deprecated):
provisioner: kubernetes.io/azure-disk

# CSI PROVISIONER (recommended):
provisioner: disk.csi.azure.com
```

#### **Azure File Provisioners**
```yaml
# IN-TREE PROVISIONER (deprecated):
provisioner: kubernetes.io/azure-file

# CSI PROVISIONER (recommended):
provisioner: file.csi.azure.com
```

#### **Network Storage Provisioners**
```yaml
# NFS PROVISIONERS:
provisioner: nfs.csi.k8s.io              # NFS CSI driver
provisioner: cluster.local/nfs-client-provisioner  # External NFS provisioner

# CEPH PROVISIONERS:
provisioner: rook-ceph.rbd.csi.ceph.com  # Rook Ceph RBD
provisioner: rook-ceph.cephfs.csi.ceph.com  # Rook Ceph FS

# GLUSTER PROVISIONERS:
provisioner: kubernetes.io/glusterfs     # GlusterFS

# ISCSI PROVISIONERS:
provisioner: iscsi.csi.k8s.io           # iSCSI CSI driver
```

#### **Local Storage Provisioners**
```yaml
# LOCAL PROVISIONERS:
provisioner: kubernetes.io/no-provisioner  # Static local volumes
provisioner: local.csi.k8s.io            # Local CSI driver

# HOSTPATH PROVISIONERS:
provisioner: rancher.io/local-path       # Rancher local-path provisioner
provisioner: openebs.io/local           # OpenEBS local provisioner
```

### **parameters Values by Provisioner**

#### **AWS EBS Parameters**
```yaml
parameters:
  # VOLUME TYPE:
  type: gp2                               # General Purpose SSD v2
  type: gp3                               # General Purpose SSD v3 (recommended)
  type: io1                               # Provisioned IOPS SSD v1
  type: io2                               # Provisioned IOPS SSD v2
  type: st1                               # Throughput Optimized HDD
  type: sc1                               # Cold HDD
  
  # FILESYSTEM:
  fsType: ext4                            # Default filesystem
  fsType: xfs                             # XFS filesystem
  fsType: ntfs                            # NTFS (Windows)
  
  # ENCRYPTION:
  encrypted: "true"                       # Enable encryption
  encrypted: "false"                      # Disable encryption (default)
  
  # KMS KEY:
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  # IOPS (io1/io2 only):
  iops: "3000"                            # Provisioned IOPS (100-64000)
  
  # THROUGHPUT (gp3 only):
  throughput: "125"                       # Throughput in MiB/s (125-1000)
  
  # AVAILABILITY ZONE:
  zone: us-west-2a                        # Specific AZ
  zones: us-west-2a,us-west-2b           # Multiple AZs
```

#### **GCP Persistent Disk Parameters**
```yaml
parameters:
  # DISK TYPE:
  type: pd-standard                       # Standard persistent disk (HDD)
  type: pd-ssd                           # SSD persistent disk
  type: pd-balanced                      # Balanced persistent disk
  type: pd-extreme                       # Extreme persistent disk
  
  # FILESYSTEM:
  fstype: ext4                           # Default filesystem
  fstype: xfs                            # XFS filesystem
  
  # REPLICATION:
  replication-type: none                 # Zonal disk (default)
  replication-type: regional-pd          # Regional disk
  
  # ZONES:
  zone: us-central1-a                    # Specific zone
  zones: us-central1-a,us-central1-b     # Multiple zones
  
  # PROVISIONED IOPS (pd-extreme only):
  provisioned-iops-on-create: "10000"    # IOPS for pd-extreme
```

#### **Azure Disk Parameters**
```yaml
parameters:
  # SKU NAME:
  skuName: Standard_LRS                   # Standard HDD locally redundant
  skuName: Premium_LRS                    # Premium SSD locally redundant
  skuName: StandardSSD_LRS               # Standard SSD locally redundant
  skuName: UltraSSD_LRS                  # Ultra SSD locally redundant
  skuName: Premium_ZRS                   # Premium SSD zone redundant
  skuName: StandardSSD_ZRS               # Standard SSD zone redundant
  
  # FILESYSTEM:
  fsType: ext4                           # Default filesystem
  fsType: xfs                            # XFS filesystem
  fsType: ntfs                           # NTFS (Windows)
  
  # CACHING:
  cachingmode: ReadOnly                  # Read-only caching
  cachingmode: ReadWrite                 # Read-write caching (default)
  cachingmode: None                      # No caching
  
  # DISK IOPS (UltraSSD only):
  diskIOPSReadWrite: "2000"              # IOPS for Ultra SSD
  
  # DISK THROUGHPUT (UltraSSD only):
  diskMBpsReadWrite: "125"               # Throughput in MB/s
```

#### **NFS Parameters**
```yaml
parameters:
  # NFS SERVER:
  server: nfs-server.example.com         # NFS server hostname/IP
  
  # NFS PATH:
  path: /exports/volumes                 # Base path for volumes
  
  # NFS VERSION:
  nfsvers: "4.1"                         # NFS version
  nfsvers: "3"                           # NFSv3
  
  # MOUNT OPTIONS:
  mountOptions: "nfsvers=4.1,rsize=1048576,wsize=1048576,hard,intr"
```

### **reclaimPolicy Values**
```yaml
reclaimPolicy: Delete                     # Delete volume when PVC deleted (default)
reclaimPolicy: Retain                     # Keep volume when PVC deleted
# reclaimPolicy: Recycle                  # DEPRECATED: not supported
```

### **volumeBindingMode Values**
```yaml
volumeBindingMode: Immediate              # Bind PVC immediately (default)
volumeBindingMode: WaitForFirstConsumer   # Wait for pod to be scheduled

# IMMEDIATE MODE:
# - PVC binds to PV immediately when created
# - Volume provisioned in random zone
# - May cause pod scheduling issues if volume in wrong zone

# WAIT FOR FIRST CONSUMER MODE:
# - PVC remains unbound until pod uses it
# - Volume provisioned in same zone as scheduled pod
# - Recommended for multi-zone clusters
```

### **allowVolumeExpansion Values**
```yaml
allowVolumeExpansion: true                # Allow PVC size expansion
allowVolumeExpansion: false               # Disallow expansion (default)

# EXPANSION SUPPORT BY PROVISIONER:
# AWS EBS: true (online expansion supported)
# GCP PD: true (online expansion supported)
# Azure Disk: true (online expansion supported)
# NFS: depends on implementation
# Local: false (cannot expand local volumes)
```

### **mountOptions Values**
```yaml
# EXT4 MOUNT OPTIONS:
mountOptions:
  - rw                                    # Read-write (default)
  - ro                                    # Read-only
  - noatime                              # Don't update access times
  - relatime                             # Relative access time updates
  - barrier=1                            # Enable write barriers
  - data=ordered                         # Ordered data mode
  - errors=remount-ro                    # Remount read-only on errors
  - user_xattr                           # Enable extended attributes
  - acl                                  # Enable POSIX ACLs

# XFS MOUNT OPTIONS:
mountOptions:
  - rw
  - noatime
  - attr2                                # Enable version 2 extended attributes
  - inode64                              # Allow 64-bit inode numbers
  - noquota                              # Disable quotas
  - logbufs=8                            # Number of log buffers
  - logbsize=32k                         # Log buffer size

# NFS MOUNT OPTIONS:
mountOptions:
  - vers=4.1                             # NFS version
  - rsize=1048576                        # Read buffer size (1MB)
  - wsize=1048576                        # Write buffer size (1MB)
  - hard                                 # Hard mount (default)
  - soft                                 # Soft mount
  - intr                                 # Allow interrupts
  - timeo=600                            # Timeout (60 seconds)
  - retrans=2                            # Retransmission count
  - proto=tcp                            # Use TCP protocol
  - fsc                                  # Enable local caching
```

### **allowedTopologies Values**
```yaml
# ZONE CONSTRAINTS:
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.kubernetes.io/zone
        values:
          - us-west-2a                    # Only zone us-west-2a
          - us-west-2b                    # Or zone us-west-2b

# REGION CONSTRAINTS:
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.kubernetes.io/region
        values:
          - us-west-2                     # Only us-west-2 region

# INSTANCE TYPE CONSTRAINTS:
allowedTopologies:
  - matchLabelExpressions:
      - key: node.kubernetes.io/instance-type
        values:
          - m5.large                      # Only m5.large instances
          - m5.xlarge                     # Or m5.xlarge instances

# MULTIPLE CONSTRAINTS (AND logic):
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.kubernetes.io/zone
        values: [us-west-2a]
      - key: node.kubernetes.io/instance-type
        values: [m5.large, m5.xlarge]

# MULTIPLE TOPOLOGIES (OR logic):
allowedTopologies:
  - matchLabelExpressions:              # First topology option
      - key: topology.kubernetes.io/zone
        values: [us-west-2a]
  - matchLabelExpressions:              # Second topology option
      - key: topology.kubernetes.io/zone
        values: [us-west-2b]
```

## 🎯 **Complete StorageClass Examples**

### **AWS EBS GP3 StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
  throughput: "250"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.kubernetes.io/zone
        values:
          - us-west-2a
          - us-west-2b
          - us-west-2c
```

### **High-Performance Database StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: database-high-iops
  labels:
    performance: high
    use-case: database
provisioner: ebs.csi.aws.com
parameters:
  type: io2
  fsType: xfs
  encrypted: "true"
  iops: "10000"
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - noatime
  - attr2
  - inode64
  - logbufs=8
  - logbsize=32k
```

### **Shared NFS StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: shared-nfs
  labels:
    access-mode: shared
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.internal.com
  path: /exports/shared
  nfsvers: "4.1"
reclaimPolicy: Retain
allowVolumeExpansion: false
volumeBindingMode: Immediate
mountOptions:
  - vers=4.1
  - rsize=1048576
  - wsize=1048576
  - hard
  - intr
  - timeo=600
```

### **Local SSD StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-ssd
  labels:
    storage-type: local
    performance: ultra-high
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
allowVolumeExpansion: false
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
  - matchLabelExpressions:
      - key: node-type
        values:
          - ssd-optimized
```

## 🔍 **Validation Rules**

### **Provisioner Validation**
```yaml
# VALID PROVISIONERS:
provisioner: ebs.csi.aws.com             # Must be valid CSI driver or in-tree provisioner
provisioner: kubernetes.io/aws-ebs       # Deprecated but valid

# INVALID PROVISIONERS:
provisioner: ""                          # Empty string not allowed
provisioner: invalid-provisioner        # Non-existent provisioner
```

### **Parameters Validation**
```yaml
# PROVISIONER-SPECIFIC:
# Each provisioner validates its own parameters
# Invalid parameters cause StorageClass creation to succeed but PVC provisioning to fail

# COMMON VALIDATION ISSUES:
parameters:
  type: invalid-type                     # Invalid for AWS EBS
  iops: "abc"                           # Must be numeric
  encrypted: "yes"                      # Must be "true" or "false"
```

### **Topology Validation**
```yaml
# VALID TOPOLOGY KEYS:
# Must match actual node labels in cluster
topology.kubernetes.io/zone: us-west-2a  # Standard zone label
topology.kubernetes.io/region: us-west-2 # Standard region label
node.kubernetes.io/instance-type: m5.large # Standard instance type label

# INVALID TOPOLOGY:
allowedTopologies:
  - matchLabelExpressions:
      - key: non-existent-label         # Label doesn't exist on nodes
        values: [some-value]
```
