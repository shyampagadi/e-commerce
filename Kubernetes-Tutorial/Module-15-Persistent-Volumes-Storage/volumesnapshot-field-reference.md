# 📸 **VolumeSnapshot Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **VolumeSnapshot Manifest Structure**

```yaml
apiVersion: snapshot.storage.k8s.io/v1   # FIXED VALUE: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot                      # FIXED VALUE: VolumeSnapshot
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  namespace: string                       # REQUIRED: target namespace
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs
    key: value
  finalizers:                             # OPTIONAL: array of strings
    - snapshot.storage.kubernetes.io/volumesnapshot-as-source-protection
    - snapshot.storage.kubernetes.io/volumesnapshot-bound-protection
spec:
  source:                                 # REQUIRED: snapshot source (exactly one)
    persistentVolumeClaimName: string     # OPTION 1: PVC name
    volumeSnapshotContentName: string     # OPTION 2: pre-existing content
  volumeSnapshotClassName: string         # OPTIONAL: snapshot class name
status:                                   # READ-ONLY: managed by system
  boundVolumeSnapshotContentName: string  # Bound snapshot content name
  creationTime: string                    # Snapshot creation timestamp
  error:                                  # Error information
    message: string                       # Error message
    time: string                          # Error timestamp
  readyToUse: boolean                     # true when snapshot is ready
  restoreSize: string                     # Size needed to restore snapshot
```

## 📊 **Field Value Details**

### **source Values**
```yaml
# PVC SOURCE (most common):
source:
  persistentVolumeClaimName: my-pvc       # PVC name in same namespace

# VOLUME SNAPSHOT CONTENT SOURCE (advanced):
source:
  volumeSnapshotContentName: snapcontent-12345  # Pre-existing snapshot content

# INVALID SOURCES:
source: {}                                # INVALID: must specify exactly one source
source:
  persistentVolumeClaimName: my-pvc
  volumeSnapshotContentName: content-123  # INVALID: cannot specify both
```

### **volumeSnapshotClassName Values**
```yaml
# EXPLICIT SNAPSHOT CLASS:
volumeSnapshotClassName: "fast-snapshots"     # Use specific snapshot class
volumeSnapshotClassName: "encrypted-snapshots" # Use encrypted snapshot class

# DEFAULT SNAPSHOT CLASS:
volumeSnapshotClassName: null                  # Use cluster default (if exists)
# OR omit the field entirely

# NO SNAPSHOT CLASS:
volumeSnapshotClassName: ""                    # Empty string = no class (static)

# COMMON CLOUD PROVIDER CLASSES:
# AWS:
volumeSnapshotClassName: "ebs-vsc"            # EBS volume snapshot class
volumeSnapshotClassName: "ebs-encrypted-vsc"  # Encrypted EBS snapshots

# GCP:
volumeSnapshotClassName: "pd-vsc"             # Persistent Disk snapshots
volumeSnapshotClassName: "ssd-vsc"            # SSD snapshots

# Azure:
volumeSnapshotClassName: "disk-vsc"           # Azure Disk snapshots
volumeSnapshotClassName: "managed-vsc"        # Managed disk snapshots
```

## 🔧 **VolumeSnapshotClass Manifest Structure**

```yaml
apiVersion: snapshot.storage.k8s.io/v1   # FIXED VALUE: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass                 # FIXED VALUE: VolumeSnapshotClass
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  # namespace: N/A                        # VolumeSnapshotClass is cluster-scoped
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs
    snapshot.storage.kubernetes.io/is-default-class: string  # VALUES: "true"|"false"
    key: value
driver: string                            # REQUIRED: CSI driver name
parameters:                               # OPTIONAL: driver-specific parameters
  key: value                              # FORMAT: string key-value pairs
deletionPolicy: string                    # REQUIRED: Delete|Retain
```

### **driver Values**
```yaml
# AWS EBS CSI DRIVER:
driver: ebs.csi.aws.com

# GCP PERSISTENT DISK CSI DRIVER:
driver: pd.csi.storage.gke.io

# AZURE DISK CSI DRIVER:
driver: disk.csi.azure.com

# CEPH RBD CSI DRIVER:
driver: rook-ceph.rbd.csi.ceph.com

# CEPH FS CSI DRIVER:
driver: rook-ceph.cephfs.csi.ceph.com

# CUSTOM CSI DRIVERS:
driver: my-custom.csi.driver.com
```

### **deletionPolicy Values**
```yaml
deletionPolicy: Delete                    # Delete snapshot when VolumeSnapshot deleted
deletionPolicy: Retain                    # Keep snapshot when VolumeSnapshot deleted
```

### **parameters Values by Driver**

#### **AWS EBS Parameters**
```yaml
parameters:
  # ENCRYPTION:
  encrypted: "true"                       # Enable encryption
  encrypted: "false"                      # Disable encryption
  
  # KMS KEY:
  kmsKeyId: "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  # TAGS:
  tagSpecification_1: "key1=value1"       # Custom tags
  tagSpecification_2: "key2=value2"
  
  # DESCRIPTION:
  description: "Automated backup snapshot"
```

#### **GCP Persistent Disk Parameters**
```yaml
parameters:
  # STORAGE LOCATIONS:
  storage-locations: "us-central1"        # Regional storage
  storage-locations: "us-central1-a"      # Zonal storage
  
  # SNAPSHOT TYPE:
  snapshot-type: "STANDARD"               # Standard snapshot
  snapshot-type: "ARCHIVE"                # Archive snapshot (cheaper, slower)
  
  # LABELS:
  labels: "environment=production,team=backend"
```

#### **Azure Disk Parameters**
```yaml
parameters:
  # RESOURCE GROUP:
  resourceGroup: "my-resource-group"      # Target resource group
  
  # TAGS:
  tags: "environment=production,backup=daily"
  
  # INCREMENTAL:
  incremental: "true"                     # Incremental snapshot
  incremental: "false"                    # Full snapshot
```

## 🎯 **Complete Examples**

### **Basic VolumeSnapshot**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: database-backup-20240905
  namespace: production
  labels:
    app: postgres
    backup-type: daily
spec:
  source:
    persistentVolumeClaimName: postgres-data
  volumeSnapshotClassName: ebs-vsc
```

### **Encrypted Snapshot with Custom Class**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: secure-backup
  namespace: finance
  labels:
    security-level: high
    compliance: pci-dss
  annotations:
    backup.company.com/retention: "7-years"
spec:
  source:
    persistentVolumeClaimName: financial-data
  volumeSnapshotClassName: encrypted-snapshots
---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: encrypted-snapshots
  annotations:
    snapshot.storage.kubernetes.io/is-default-class: "false"
driver: ebs.csi.aws.com
parameters:
  encrypted: "true"
  kmsKeyId: "arn:aws:kms:us-east-1:123456789012:key/abcd1234-a123-456a-a12b-a123b4cd56ef"
  tagSpecification_1: "Environment=Production"
  tagSpecification_2: "Compliance=PCI-DSS"
deletionPolicy: Retain
```

### **Scheduled Backup Pattern**
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: app-data-backup-{{ .Values.timestamp }}
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ .Values.app }}
    backup-schedule: daily
    retention-days: "30"
  annotations:
    backup.company.com/created-by: "cronjob"
    backup.company.com/schedule: "0 2 * * *"
spec:
  source:
    persistentVolumeClaimName: {{ .Values.pvcName }}
  volumeSnapshotClassName: {{ .Values.snapshotClass }}
```

## 🔧 **VolumeSnapshotContent Structure**

```yaml
apiVersion: snapshot.storage.k8s.io/v1   # FIXED VALUE: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotContent               # FIXED VALUE: VolumeSnapshotContent
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  # namespace: N/A                        # VolumeSnapshotContent is cluster-scoped
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs
    key: value
  finalizers:                             # OPTIONAL: array of strings
    - snapshot.storage.kubernetes.io/volumesnapshotcontent-bound-protection
spec:
  deletionPolicy: string                  # REQUIRED: Delete|Retain
  driver: string                          # REQUIRED: CSI driver name
  source:                                 # REQUIRED: snapshot source (exactly one)
    snapshotHandle: string                # OPTION 1: pre-existing snapshot ID
    volumeHandle: string                  # OPTION 2: volume to snapshot
  sourceVolumeMode: string                # OPTIONAL: Filesystem|Block
  volumeSnapshotClassName: string         # OPTIONAL: snapshot class name
  volumeSnapshotRef:                      # REQUIRED: reference to VolumeSnapshot
    apiVersion: string                    # REQUIRED: snapshot.storage.k8s.io/v1
    kind: string                          # REQUIRED: VolumeSnapshot
    name: string                          # REQUIRED: VolumeSnapshot name
    namespace: string                     # REQUIRED: VolumeSnapshot namespace
    resourceVersion: string               # OPTIONAL: resource version
    uid: string                           # OPTIONAL: VolumeSnapshot UID
status:                                   # READ-ONLY: managed by system
  creationTime: integer                   # Snapshot creation timestamp (nanoseconds)
  error:                                  # Error information
    message: string                       # Error message
    time: string                          # Error timestamp
  readyToUse: boolean                     # true when snapshot is ready
  restoreSize: integer                    # Size in bytes needed to restore
  snapshotHandle: string                  # Provider-specific snapshot identifier
```

## 🔍 **Validation Rules**

### **Source Validation**
```yaml
# VALID SOURCES:
source:
  persistentVolumeClaimName: existing-pvc # PVC must exist in same namespace

source:
  volumeSnapshotContentName: content-123  # Content must exist

# INVALID SOURCES:
source: {}                                # Must specify exactly one source
source:
  persistentVolumeClaimName: ""           # Empty string not allowed
source:
  persistentVolumeClaimName: non-existent # PVC must exist
```

### **Snapshot Class Validation**
```yaml
# VALID SNAPSHOT CLASSES:
volumeSnapshotClassName: "existing-class" # Must exist in cluster
volumeSnapshotClassName: ""               # Empty string for no class
volumeSnapshotClassName: null             # Null for default class

# INVALID SNAPSHOT CLASSES:
volumeSnapshotClassName: "non-existent"   # Will cause snapshot to fail
```

### **Driver Compatibility**
```yaml
# DRIVER MUST SUPPORT SNAPSHOTS:
# Check CSI driver capabilities:
# - CREATE_DELETE_SNAPSHOT
# - LIST_SNAPSHOTS (optional)

# VOLUME MUST BE SNAPSHOT-CAPABLE:
# Not all volume types support snapshots
# Local volumes typically don't support snapshots
# Network volumes (NFS) may not support snapshots
```

## 📋 **Common Patterns**

### **Backup and Restore Workflow**
```yaml
# 1. CREATE SNAPSHOT
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: backup-before-upgrade
  namespace: production
spec:
  source:
    persistentVolumeClaimName: app-data
  volumeSnapshotClassName: fast-snapshots

---
# 2. RESTORE FROM SNAPSHOT
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
  dataSource:
    apiGroup: snapshot.storage.k8s.io
    kind: VolumeSnapshot
    name: backup-before-upgrade
  storageClassName: fast-ssd
```

### **Cross-Namespace Restore**
```yaml
# SNAPSHOT IN SOURCE NAMESPACE
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: prod-backup
  namespace: production
spec:
  source:
    persistentVolumeClaimName: prod-data
  volumeSnapshotClassName: encrypted-snapshots

---
# RESTORE IN DIFFERENT NAMESPACE
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dev-data
  namespace: development
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  dataSourceRef:                          # Use dataSourceRef for cross-namespace
    apiGroup: snapshot.storage.k8s.io
    kind: VolumeSnapshot
    name: prod-backup
    namespace: production                  # Source namespace
  storageClassName: standard
```
