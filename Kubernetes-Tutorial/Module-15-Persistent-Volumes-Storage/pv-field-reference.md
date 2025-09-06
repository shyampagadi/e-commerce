# 📋 **PersistentVolume Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **PersistentVolume Manifest Structure**

```yaml
apiVersion: v1                              # FIXED VALUE: v1
kind: PersistentVolume                      # FIXED VALUE: PersistentVolume
metadata:
  name: string                              # REQUIRED: DNS-1123 subdomain
  namespace: string                         # NOT APPLICABLE: PV is cluster-scoped
  labels:                                   # OPTIONAL: key-value pairs
    key: value                              # FORMAT: DNS-1123 label format
  annotations:                              # OPTIONAL: key-value pairs
    key: value                              # FORMAT: any string
  finalizers:                               # OPTIONAL: array of strings
    - kubernetes.io/pv-protection           # COMMON VALUES: kubernetes.io/pv-protection
spec:
  capacity:                                 # REQUIRED: storage capacity
    storage: string                         # REQUIRED: quantity (e.g., 10Gi, 100Mi, 1Ti)
  accessModes:                              # REQUIRED: array of access modes
    - ReadWriteOnce                         # VALUES: ReadWriteOnce, ReadOnlyMany, ReadWriteMany, ReadWriteOncePod
  persistentVolumeReclaimPolicy: string     # OPTIONAL: Retain|Delete|Recycle (default: Retain)
  storageClassName: string                  # OPTIONAL: storage class name or "" for no class
  volumeMode: string                        # OPTIONAL: Filesystem|Block (default: Filesystem)
  mountOptions:                             # OPTIONAL: array of mount options
    - string                                # VALUES: filesystem-specific options
  nodeAffinity:                             # OPTIONAL: node affinity rules
    required:                               # OPTIONAL: required node affinity
      nodeSelectorTerms:                    # REQUIRED: array of node selector terms
        - matchExpressions:                 # OPTIONAL: array of expressions
            - key: string                   # REQUIRED: node label key
              operator: string              # REQUIRED: In|NotIn|Exists|DoesNotExist|Gt|Lt
              values:                       # OPTIONAL: array of strings (required for In|NotIn|Gt|Lt)
                - string
          matchFields:                      # OPTIONAL: array of field expressions
            - key: string                   # REQUIRED: node field key
              operator: string              # REQUIRED: In|NotIn|Exists|DoesNotExist|Gt|Lt
              values:                       # OPTIONAL: array of strings
                - string
  # VOLUME TYPE (exactly one required):
  hostPath:                                 # LOCAL: host path volume
    path: string                            # REQUIRED: absolute path on host
    type: string                            # OPTIONAL: ""(default)|DirectoryOrCreate|Directory|FileOrCreate|File|Socket|CharDevice|BlockDevice
  local:                                    # LOCAL: local volume
    path: string                            # REQUIRED: absolute path on node
    fsType: string                          # OPTIONAL: filesystem type
  nfs:                                      # NETWORK: NFS volume
    server: string                          # REQUIRED: NFS server hostname/IP
    path: string                            # REQUIRED: NFS export path
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  iscsi:                                    # NETWORK: iSCSI volume
    targetPortal: string                    # REQUIRED: iSCSI target portal (IP:port)
    iqn: string                             # REQUIRED: iSCSI qualified name
    lun: integer                            # REQUIRED: iSCSI LUN number (0-255)
    fsType: string                          # OPTIONAL: filesystem type (ext4, xfs, etc.)
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
    chapAuthDiscovery: boolean              # OPTIONAL: CHAP discovery authentication
    chapAuthSession: boolean                # OPTIONAL: CHAP session authentication
    secretRef:                              # OPTIONAL: CHAP authentication secret
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    initiatorName: string                   # OPTIONAL: custom initiator name
    portals:                                # OPTIONAL: additional target portals
      - string                              # FORMAT: IP:port
  cephfs:                                   # NETWORK: CephFS volume
    monitors:                               # REQUIRED: array of Ceph monitors
      - string                              # FORMAT: IP:port
    path: string                            # OPTIONAL: CephFS path (default: /)
    user: string                            # OPTIONAL: Ceph user (default: admin)
    secretFile: string                      # OPTIONAL: path to secret file
    secretRef:                              # OPTIONAL: secret reference
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  rbd:                                      # NETWORK: Ceph RBD volume
    monitors:                               # REQUIRED: array of Ceph monitors
      - string                              # FORMAT: IP:port
    image: string                           # REQUIRED: RBD image name
    pool: string                            # OPTIONAL: RBD pool (default: rbd)
    user: string                            # OPTIONAL: Ceph user (default: admin)
    keyring: string                         # OPTIONAL: path to keyring file
    secretRef:                              # OPTIONAL: secret reference
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    fsType: string                          # OPTIONAL: filesystem type
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  glusterfs:                                # NETWORK: GlusterFS volume
    endpoints: string                       # REQUIRED: endpoints resource name
    path: string                            # REQUIRED: GlusterFS volume path
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  # CLOUD PROVIDER VOLUMES:
  awsElasticBlockStore:                     # AWS: EBS volume
    volumeID: string                        # REQUIRED: AWS EBS volume ID (vol-xxxxxxxx)
    fsType: string                          # OPTIONAL: ext4|xfs|ntfs (default: ext4)
    partition: integer                      # OPTIONAL: partition number (1-4)
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  gcePersistentDisk:                        # GCP: Persistent Disk
    pdName: string                          # REQUIRED: GCE PD name
    fsType: string                          # OPTIONAL: ext4|xfs (default: ext4)
    partition: integer                      # OPTIONAL: partition number
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
  azureDisk:                                # AZURE: Managed Disk
    diskName: string                        # REQUIRED: disk name
    diskURI: string                         # REQUIRED: disk URI
    cachingMode: string                     # OPTIONAL: None|ReadOnly|ReadWrite (default: ReadWrite)
    fsType: string                          # OPTIONAL: ext4|xfs (default: ext4)
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
    kind: string                            # OPTIONAL: Shared|Dedicated|Managed (default: Shared)
  azureFile:                                # AZURE: File Share
    secretName: string                      # REQUIRED: secret with storage account credentials
    shareName: string                       # REQUIRED: Azure file share name
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
    secretNamespace: string                 # OPTIONAL: secret namespace
  # CSI VOLUME:
  csi:                                      # CSI: Container Storage Interface
    driver: string                          # REQUIRED: CSI driver name
    volumeHandle: string                    # REQUIRED: unique volume identifier
    readOnly: boolean                       # OPTIONAL: true|false (default: false)
    fsType: string                          # OPTIONAL: filesystem type
    volumeAttributes:                       # OPTIONAL: driver-specific attributes
      key: value                            # FORMAT: string key-value pairs
    controllerPublishSecretRef:             # OPTIONAL: controller publish secret
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    nodeStageSecretRef:                     # OPTIONAL: node stage secret
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    nodePublishSecretRef:                   # OPTIONAL: node publish secret
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
    controllerExpandSecretRef:              # OPTIONAL: controller expand secret
      name: string                          # REQUIRED: secret name
      namespace: string                     # OPTIONAL: secret namespace
status:                                     # READ-ONLY: managed by system
  phase: string                             # VALUES: Pending|Available|Bound|Released|Failed
  message: string                           # OPTIONAL: human-readable message
  reason: string                            # OPTIONAL: reason for current phase
```

## 📊 **Field Value Details**

### **capacity.storage Values**
```yaml
# QUANTITY FORMAT: <number><unit>
# DECIMAL UNITS (SI):
storage: "1000m"      # 1000 millibytes = 1 byte
storage: "1k"         # 1000 bytes
storage: "1M"         # 1000^2 bytes = 1 megabyte
storage: "1G"         # 1000^3 bytes = 1 gigabyte
storage: "1T"         # 1000^4 bytes = 1 terabyte
storage: "1P"         # 1000^5 bytes = 1 petabyte

# BINARY UNITS (IEC):
storage: "1Ki"        # 1024 bytes = 1 kibibyte
storage: "1Mi"        # 1024^2 bytes = 1 mebibyte
storage: "1Gi"        # 1024^3 bytes = 1 gibibyte
storage: "1Ti"        # 1024^4 bytes = 1 tebibyte
storage: "1Pi"        # 1024^5 bytes = 1 pebibyte

# EXAMPLES:
storage: "10Gi"       # 10 gibibytes
storage: "500Mi"      # 500 mebibytes
storage: "1.5Ti"      # 1.5 tebibytes
storage: "100"        # 100 bytes (no unit)
```

### **accessModes Values**
```yaml
# SINGLE VALUES (array can contain multiple):
- ReadWriteOnce       # RWO: volume can be mounted read-write by single node
- ReadOnlyMany        # ROX: volume can be mounted read-only by many nodes
- ReadWriteMany       # RWX: volume can be mounted read-write by many nodes
- ReadWriteOncePod    # RWOP: volume can be mounted read-write by single pod (1.22+)

# COMMON COMBINATIONS:
accessModes: [ReadWriteOnce]                    # Most common for block storage
accessModes: [ReadOnlyMany]                     # For shared read-only data
accessModes: [ReadWriteMany]                    # For shared filesystems (NFS, CephFS)
accessModes: [ReadWriteOnce, ReadOnlyMany]      # Support both modes
```

### **persistentVolumeReclaimPolicy Values**
```yaml
persistentVolumeReclaimPolicy: Retain    # Keep volume after PVC deletion (manual cleanup)
persistentVolumeReclaimPolicy: Delete    # Delete volume after PVC deletion (automatic cleanup)
persistentVolumeReclaimPolicy: Recycle   # DEPRECATED: scrub volume and make available again
```

### **volumeMode Values**
```yaml
volumeMode: Filesystem    # DEFAULT: mount as filesystem (most common)
volumeMode: Block        # Raw block device (for databases, custom filesystems)
```

### **hostPath.type Values**
```yaml
type: ""                 # DEFAULT: no type checking
type: DirectoryOrCreate  # Create directory if it doesn't exist
type: Directory         # Must be existing directory
type: FileOrCreate      # Create file if it doesn't exist
type: File              # Must be existing file
type: Socket            # Must be existing UNIX socket
type: CharDevice        # Must be existing character device
type: BlockDevice       # Must be existing block device
```

### **Mount Options by Filesystem**
```yaml
# EXT4 OPTIONS:
mountOptions:
  - rw                  # Read-write (default)
  - ro                  # Read-only
  - noatime            # Don't update access times
  - relatime           # Update access times relatively
  - barrier=1          # Enable write barriers
  - data=ordered       # Data ordering mode
  - errors=remount-ro  # Error handling

# XFS OPTIONS:
mountOptions:
  - rw
  - noatime
  - attr2              # Enable extended attributes
  - inode64            # Allow 64-bit inode numbers
  - noquota            # Disable quotas

# NFS OPTIONS:
mountOptions:
  - vers=4.1           # NFS version
  - rsize=1048576      # Read buffer size
  - wsize=1048576      # Write buffer size
  - hard               # Hard mount (default)
  - soft               # Soft mount
  - intr               # Interruptible
  - timeo=600          # Timeout in deciseconds
  - retrans=2          # Number of retransmissions

# CIFS/SMB OPTIONS:
mountOptions:
  - vers=3.0           # SMB version
  - cache=strict       # Cache mode
  - uid=1000           # User ID
  - gid=1000           # Group ID
  - file_mode=0755     # File permissions
  - dir_mode=0755      # Directory permissions
```

### **Node Affinity Operators**
```yaml
# LABEL OPERATORS:
operator: In             # Label value must be in values list
operator: NotIn          # Label value must not be in values list
operator: Exists         # Label key must exist (values ignored)
operator: DoesNotExist   # Label key must not exist (values ignored)
operator: Gt             # Label value must be greater than values[0]
operator: Lt             # Label value must be less than values[0]

# EXAMPLES:
matchExpressions:
  - key: kubernetes.io/arch
    operator: In
    values: [amd64, arm64]
  - key: node.kubernetes.io/instance-type
    operator: NotIn
    values: [t2.micro, t2.small]
  - key: topology.kubernetes.io/zone
    operator: Exists
  - key: node.kubernetes.io/unreachable
    operator: DoesNotExist
```

### **Common Node Label Keys**
```yaml
# STANDARD KUBERNETES LABELS:
kubernetes.io/arch                    # VALUES: amd64, arm64, ppc64le, s390x
kubernetes.io/os                      # VALUES: linux, windows
kubernetes.io/hostname                # Node hostname
node.kubernetes.io/instance-type      # Cloud instance type
topology.kubernetes.io/zone          # Availability zone
topology.kubernetes.io/region        # Cloud region
node.kubernetes.io/unreachable       # Node unreachable taint
node.kubernetes.io/not-ready         # Node not ready taint

# CLOUD PROVIDER LABELS:
# AWS:
failure-domain.beta.kubernetes.io/zone     # AWS AZ
failure-domain.beta.kubernetes.io/region   # AWS region
beta.kubernetes.io/instance-type           # EC2 instance type
kubernetes.io/role                         # master, node

# GCP:
cloud.google.com/gke-nodepool             # GKE node pool
cloud.google.com/machine-family          # Machine family

# AZURE:
kubernetes.azure.com/cluster             # AKS cluster name
kubernetes.azure.com/node-image-version  # Node image version
```

## 🔍 **Validation Rules**

### **Name Validation**
```yaml
# DNS-1123 SUBDOMAIN FORMAT:
# - Lowercase alphanumeric characters or '-'
# - Start and end with alphanumeric character
# - Maximum 253 characters
# - No consecutive dots

# VALID NAMES:
name: my-pv
name: storage-volume-1
name: app-data-volume

# INVALID NAMES:
name: My-PV              # Uppercase not allowed
name: -my-pv             # Cannot start with '-'
name: my-pv-             # Cannot end with '-'
name: my..pv             # Consecutive dots not allowed
```

### **Label Validation**
```yaml
# LABEL KEY FORMAT:
# - Optional prefix (DNS subdomain) + '/' + name
# - Name: alphanumeric, '-', '_', '.' (max 63 chars)
# - Must start/end with alphanumeric

# LABEL VALUE FORMAT:
# - Alphanumeric, '-', '_', '.' (max 63 chars)
# - Must start/end with alphanumeric
# - Can be empty string

# VALID LABELS:
labels:
  app: database
  version: v1.2.3
  environment: production
  kubernetes.io/managed-by: helm
  example.com/component: storage

# INVALID LABELS:
labels:
  -app: database         # Key cannot start with '-'
  app: -database         # Value cannot start with '-'
  "": value              # Key cannot be empty
```

### **Capacity Validation**
```yaml
# MINIMUM VALUES:
capacity:
  storage: "1"           # 1 byte minimum

# MAXIMUM VALUES (implementation dependent):
capacity:
  storage: "8Ei"         # 8 exbibytes (theoretical max)

# PRECISION:
capacity:
  storage: "1.5Gi"       # Decimal values allowed
  storage: "1500Mi"      # Equivalent to 1.5Gi
```
