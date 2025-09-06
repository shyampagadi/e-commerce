# 📋 **PersistentVolumeClaim Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **PersistentVolumeClaim Manifest Structure**

```yaml
apiVersion: v1                              # FIXED VALUE: v1
kind: PersistentVolumeClaim                 # FIXED VALUE: PersistentVolumeClaim
metadata:
  name: string                              # REQUIRED: DNS-1123 subdomain
  namespace: string                         # OPTIONAL: target namespace (default: default)
  labels:                                   # OPTIONAL: key-value pairs
    key: value                              # FORMAT: DNS-1123 label format
  annotations:                              # OPTIONAL: key-value pairs
    key: value                              # FORMAT: any string
    # COMMON ANNOTATIONS:
    volume.beta.kubernetes.io/storage-class: string        # Storage class (deprecated, use spec.storageClassName)
    volume.kubernetes.io/selected-node: string             # Node selection hint
    volume.kubernetes.io/storage-provisioner: string      # Provisioner name
  finalizers:                               # OPTIONAL: array of strings
    - kubernetes.io/pvc-protection          # COMMON VALUES: kubernetes.io/pvc-protection
spec:
  accessModes:                              # REQUIRED: array of access modes
    - ReadWriteOnce                         # VALUES: ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod
  resources:                                # REQUIRED: resource requirements
    requests:                               # REQUIRED: minimum resources
      storage: string                       # REQUIRED: storage quantity (e.g., 10Gi)
    limits:                                 # OPTIONAL: maximum resources
      storage: string                       # OPTIONAL: storage quantity limit
  selector:                                 # OPTIONAL: PV selector
    matchLabels:                            # OPTIONAL: exact label matches
      key: value                            # FORMAT: label key-value pairs
    matchExpressions:                       # OPTIONAL: expression-based matching
      - key: string                         # REQUIRED: label key
        operator: string                    # REQUIRED: In|NotIn|Exists|DoesNotExist
        values:                             # OPTIONAL: array of strings
          - string
  storageClassName: string                  # OPTIONAL: storage class name ("" for no class, null for default)
  volumeMode: string                        # OPTIONAL: Filesystem|Block (default: Filesystem)
  volumeName: string                        # OPTIONAL: specific PV name to bind to
  dataSource:                               # OPTIONAL: data source for volume content
    apiGroup: string                        # OPTIONAL: API group (default: "")
    kind: string                            # REQUIRED: resource kind
    name: string                            # REQUIRED: resource name
  dataSourceRef:                            # OPTIONAL: extended data source reference (1.24+)
    apiGroup: string                        # OPTIONAL: API group
    kind: string                            # REQUIRED: resource kind
    name: string                            # REQUIRED: resource name
    namespace: string                       # OPTIONAL: resource namespace
status:                                     # READ-ONLY: managed by system
  phase: string                             # VALUES: Pending|Bound|Lost
  accessModes:                              # ACTUAL: access modes of bound volume
    - string
  capacity:                                 # ACTUAL: capacity of bound volume
    storage: string
  conditions:                               # ARRAY: current conditions
    - type: string                          # CONDITION TYPE: Resizing|FileSystemResizePending
      status: string                        # VALUES: True|False|Unknown
      lastProbeTime: string                 # TIMESTAMP: last probe time
      lastTransitionTime: string            # TIMESTAMP: last transition time
      reason: string                        # REASON: condition reason
      message: string                       # MESSAGE: human-readable message
```

## 📊 **Field Value Details**

### **accessModes Values**
```yaml
# SINGLE ACCESS MODE (most common):
accessModes:
  - ReadWriteOnce                          # RWO: single node read-write access

# MULTIPLE ACCESS MODES (PVC will match PV with any of these):
accessModes:
  - ReadWriteOnce                          # Prefer RWO
  - ReadOnlyMany                           # Accept ROX if RWO not available

# ALL ACCESS MODES:
accessModes:
  - ReadWriteOnce                          # Single node read-write
  - ReadOnlyMany                           # Multiple nodes read-only
  - ReadWriteMany                          # Multiple nodes read-write
  - ReadWriteOncePod                       # Single pod read-write (1.22+)

# ACCESS MODE COMPATIBILITY:
# Block Storage (EBS, GCE PD, Azure Disk): ReadWriteOnce only
# File Storage (NFS, CephFS, GlusterFS): ReadWriteMany supported
# Object Storage (S3, GCS): ReadOnlyMany typically
```

### **resources.requests.storage Values**
```yaml
# BINARY UNITS (recommended for storage):
storage: "1Ki"          # 1024 bytes
storage: "1Mi"          # 1024^2 bytes = 1,048,576 bytes
storage: "1Gi"          # 1024^3 bytes = 1,073,741,824 bytes
storage: "1Ti"          # 1024^4 bytes = 1,099,511,627,776 bytes
storage: "1Pi"          # 1024^5 bytes

# DECIMAL UNITS:
storage: "1k"           # 1000 bytes
storage: "1M"           # 1,000,000 bytes
storage: "1G"           # 1,000,000,000 bytes
storage: "1T"           # 1,000,000,000,000 bytes

# FRACTIONAL VALUES:
storage: "1.5Gi"        # 1.5 gibibytes
storage: "500Mi"        # 500 mebibytes
storage: "2.5Ti"        # 2.5 tebibytes

# COMMON SIZES:
storage: "1Gi"          # Small application data
storage: "10Gi"         # Medium database
storage: "100Gi"        # Large database
storage: "1Ti"          # Data warehouse
storage: "10Ti"         # Big data storage

# MINIMUM/MAXIMUM (provider dependent):
storage: "1Gi"          # AWS EBS minimum
storage: "64Ti"         # AWS EBS maximum (gp3)
storage: "1Mi"          # Some providers allow smaller
```

### **storageClassName Values**
```yaml
# EXPLICIT STORAGE CLASS:
storageClassName: "fast-ssd"               # Use specific storage class
storageClassName: "slow-hdd"               # Use different storage class
storageClassName: "encrypted"              # Use encrypted storage class

# DEFAULT STORAGE CLASS:
storageClassName: null                     # Use cluster default storage class
# OR omit the field entirely

# NO STORAGE CLASS (static provisioning):
storageClassName: ""                       # Empty string = no storage class

# COMMON CLOUD PROVIDER CLASSES:
# AWS:
storageClassName: "gp2"                    # General Purpose SSD (default)
storageClassName: "gp3"                    # General Purpose SSD v3
storageClassName: "io1"                    # Provisioned IOPS SSD
storageClassName: "io2"                    # Provisioned IOPS SSD v2
storageClassName: "st1"                    # Throughput Optimized HDD
storageClassName: "sc1"                    # Cold HDD

# GCP:
storageClassName: "standard"               # Standard persistent disk
storageClassName: "ssd"                    # SSD persistent disk
storageClassName: "standard-rwo"           # Regional standard disk

# Azure:
storageClassName: "default"                # Standard HDD
storageClassName: "managed-premium"        # Premium SSD
storageClassName: "azurefile"              # Azure File Share
```

### **volumeMode Values**
```yaml
volumeMode: Filesystem                     # DEFAULT: mount as filesystem
volumeMode: Block                          # Raw block device access

# FILESYSTEM MODE (most common):
# - Volume mounted as directory
# - Filesystem created automatically
# - Standard file operations
# - Compatible with most applications

# BLOCK MODE (advanced use cases):
# - Raw block device access
# - No filesystem layer
# - Direct I/O operations
# - Used by databases, custom filesystems
# - Requires application support
```

### **selector Values**
```yaml
# NO SELECTOR (any matching PV):
selector: {}                               # Match any PV with compatible specs

# LABEL-BASED SELECTION:
selector:
  matchLabels:
    type: local                            # Exact match: type=local
    environment: production                # Exact match: environment=production
    performance: high                      # Exact match: performance=high

# EXPRESSION-BASED SELECTION:
selector:
  matchExpressions:
    - key: type
      operator: In
      values: [local, network]             # type in (local, network)
    - key: performance
      operator: NotIn
      values: [low]                        # performance not in (low)
    - key: encryption
      operator: Exists                     # encryption label exists
    - key: deprecated
      operator: DoesNotExist               # deprecated label does not exist

# COMBINED SELECTION:
selector:
  matchLabels:
    type: local
  matchExpressions:
    - key: size
      operator: In
      values: [large, xlarge]
```

### **dataSource Values**
```yaml
# PVC CLONING (copy from existing PVC):
dataSource:
  kind: PersistentVolumeClaim
  name: source-pvc                         # Source PVC name
  # apiGroup: ""                          # Default for core resources

# VOLUME SNAPSHOT RESTORE:
dataSource:
  apiGroup: snapshot.storage.k8s.io
  kind: VolumeSnapshot
  name: my-snapshot                        # Snapshot name

# INVALID DATA SOURCES:
dataSource:
  kind: Pod                                # INVALID: unsupported kind
  name: my-pod

dataSource:
  kind: ConfigMap                          # INVALID: unsupported kind
  name: my-config
```

### **dataSourceRef Values (1.24+)**
```yaml
# CROSS-NAMESPACE PVC CLONING:
dataSourceRef:
  kind: PersistentVolumeClaim
  name: source-pvc
  namespace: source-namespace              # Different namespace

# VOLUME SNAPSHOT FROM DIFFERENT NAMESPACE:
dataSourceRef:
  apiGroup: snapshot.storage.k8s.io
  kind: VolumeSnapshot
  name: backup-snapshot
  namespace: backup-namespace

# CUSTOM RESOURCE DATA SOURCE:
dataSourceRef:
  apiGroup: example.com
  kind: CustomDataSource
  name: my-data-source
  namespace: data-namespace
```

## 🎯 **Common Patterns and Examples**

### **Basic PVC Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: fast-ssd
```

### **Database PVC Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
  namespace: database
  labels:
    app: postgres
    tier: database
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
    limits:
      storage: 500Gi                      # Allow expansion up to 500Gi
  storageClassName: high-iops-ssd
  selector:
    matchLabels:
      type: database-optimized
```

### **Shared Storage Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-files
  namespace: web-app
spec:
  accessModes:
    - ReadWriteMany                        # Multiple pods can mount
  resources:
    requests:
      storage: 50Gi
  storageClassName: nfs-storage
```

### **Block Storage Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: raw-block-storage
  namespace: database
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
  volumeMode: Block                        # Raw block device
  storageClassName: high-performance-ssd
```

### **PVC from Snapshot Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: restored-data
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: fast-ssd
  dataSource:
    apiGroup: snapshot.storage.k8s.io
    kind: VolumeSnapshot
    name: daily-backup-20240905
```

### **PVC Cloning Pattern**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dev-data-copy
  namespace: development
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: standard
  dataSourceRef:                           # Cross-namespace cloning
    kind: PersistentVolumeClaim
    name: prod-data
    namespace: production
```

## 🔍 **Validation Rules and Constraints**

### **Size Constraints**
```yaml
# MINIMUM SIZE (provider dependent):
resources:
  requests:
    storage: "1Gi"                         # AWS EBS minimum
    storage: "1Mi"                         # Some providers allow smaller

# MAXIMUM SIZE (provider dependent):
resources:
  requests:
    storage: "64Ti"                        # AWS EBS gp3 maximum
    storage: "16Ti"                        # AWS EBS gp2 maximum

# SIZE EXPANSION:
resources:
  requests:
    storage: "20Gi"                        # Can be increased if storage class allows
  limits:
    storage: "100Gi"                       # Maximum allowed expansion
```

### **Access Mode Constraints**
```yaml
# STORAGE TYPE LIMITATIONS:
# Block Storage (EBS, GCE PD, Azure Disk):
accessModes: [ReadWriteOnce]               # Only RWO supported

# Network Storage (NFS, CephFS):
accessModes: [ReadWriteMany]               # RWX supported

# Object Storage (S3, GCS):
accessModes: [ReadOnlyMany]                # Typically ROX only

# INVALID COMBINATIONS:
accessModes: []                            # INVALID: must specify at least one
accessModes: [InvalidMode]                 # INVALID: unknown access mode
```

### **Storage Class Constraints**
```yaml
# VALID STORAGE CLASS REFERENCES:
storageClassName: "existing-class"         # Must exist in cluster
storageClassName: ""                       # Empty string for no class
storageClassName: null                     # Null for default class

# INVALID STORAGE CLASS REFERENCES:
storageClassName: "non-existent"           # Will cause PVC to remain Pending
```

### **Selector Constraints**
```yaml
# SELECTOR LOGIC:
# - Empty selector matches any PV
# - Non-empty selector must match PV labels exactly
# - Multiple expressions use AND logic
# - Multiple values in expression use OR logic

# VALID SELECTORS:
selector: {}                               # Match any PV
selector:
  matchLabels: {}                          # Match any PV (empty labels)
selector:
  matchExpressions: []                     # Match any PV (empty expressions)

# SELECTOR WITH STORAGE CLASS:
# - If both selector and storageClassName specified, both must match
# - PV must have matching labels AND storage class
```
