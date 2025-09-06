# 💾 **Kubectl Storage Command Reference**
*Complete guide to all storage-related kubectl commands and configurations*

## 🗄️ **Persistent Volume (PV) Commands**

### **Create Persistent Volume**
```bash
# Create PV from YAML
kubectl create -f pv.yaml [options]

# Create PV imperatively (limited options)
kubectl create pv <name> --capacity=<size> --access-modes=<modes> --host-path=<path>
```

**Complete PV Creation Options:**
```bash
kubectl create -f pv.yaml \
  --dry-run=client \                        # Validate without creating
  --output=yaml \                           # Output format
  --save-config \                           # Save config in annotation
  --validate=true                           # Validate resource
```

### **Get Persistent Volumes**
```bash
# List all PVs (cluster-wide resource)
kubectl get pv [options]

# Complete get options for PVs
kubectl get pv \
  --field-selector=spec.capacity.storage=10Gi \ # Filter by capacity
  --field-selector=status.phase=Available \  # Filter by status
  --label-selector=type=local \              # Filter by labels
  --no-headers \                             # Skip headers
  --output=wide \                            # Wide output
  --output=yaml \                            # YAML output
  --output=custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,ACCESS:.spec.accessModes,STATUS:.status.phase \
  --show-labels \                            # Show labels
  --sort-by=.spec.capacity.storage \         # Sort by capacity
  --watch                                    # Watch for changes
```

### **Describe Persistent Volume**
```bash
# Describe specific PV
kubectl describe pv <pv-name> [options]

# Describe all PVs
kubectl describe pv

# Show events related to PV
kubectl describe pv <pv-name> --show-events=true
```

### **Delete Persistent Volume**
```bash
# Delete PV
kubectl delete pv <pv-name> [options]

# Delete options
kubectl delete pv my-pv \
  --cascade=background \                     # Cascade deletion
  --dry-run=none \                          # Dry run mode
  --force \                                 # Force deletion
  --grace-period=30 \                       # Grace period
  --ignore-not-found \                      # Ignore if not found
  --now \                                   # Delete immediately
  --timeout=30s \                           # Timeout
  --wait=true                               # Wait for completion
```

## 📋 **Persistent Volume Claim (PVC) Commands**

### **Create PVC**
```bash
# Create PVC imperatively
kubectl create pvc <name> --size=<size> --access-modes=<modes> [options]

# Complete PVC creation
kubectl create pvc my-pvc \
  --size=10Gi \                             # Storage size
  --access-modes=ReadWriteOnce \            # Access modes
  --storage-class=fast-ssd \                # Storage class
  --selector=matchLabels=type=local \       # PV selector
  --namespace=production                     # Target namespace
```

### **Get PVCs**
```bash
# List PVCs in namespace
kubectl get pvc [options]

# Complete get options for PVCs
kubectl get pvc \
  --all-namespaces \                        # All namespaces
  --field-selector=status.phase=Bound \     # Filter by status
  --field-selector=spec.resources.requests.storage=10Gi \ # Filter by size
  --label-selector=app=database \           # Filter by labels
  --output=wide \                           # Wide output
  --output=custom-columns=NAME:.metadata.name,STATUS:.status.phase,VOLUME:.spec.volumeName,CAPACITY:.status.capacity.storage,ACCESS:.status.accessModes \
  --show-labels \                           # Show labels
  --sort-by=.status.capacity.storage        # Sort by capacity
```

### **PVC Status and Binding**
```bash
# Check PVC binding status
kubectl get pvc <pvc-name> -o jsonpath='{.status.phase}'
kubectl get pvc <pvc-name> -o jsonpath='{.spec.volumeName}'

# Wait for PVC to bind
kubectl wait --for=condition=Bound pvc/<pvc-name> --timeout=60s

# Check PVC events
kubectl describe pvc <pvc-name>
kubectl get events --field-selector=involvedObject.name=<pvc-name>
```

## 🏪 **Storage Class Commands**

### **Create Storage Class**
```bash
# Create from YAML (recommended)
kubectl create -f storageclass.yaml

# Create imperatively (basic)
kubectl create storageclass <name> --provisioner=<provisioner> [options]
```

**Complete Storage Class Creation:**
```bash
kubectl create storageclass fast-ssd \
  --provisioner=kubernetes.io/aws-ebs \     # Provisioner
  --parameters=type=gp3,fsType=ext4 \       # Parameters
  --reclaim-policy=Delete \                 # Reclaim policy
  --volume-binding-mode=WaitForFirstConsumer \ # Binding mode
  --allow-volume-expansion=true             # Allow expansion
```

### **Get Storage Classes**
```bash
# List all storage classes
kubectl get storageclass [options]
kubectl get sc [options]  # Short form

# Complete get options
kubectl get storageclass \
  --output=wide \                           # Wide output
  --output=custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner,RECLAIM:.reclaimPolicy,BINDING:.volumeBindingMode \
  --show-labels \                           # Show labels
  --sort-by=.metadata.name                  # Sort by name
```

### **Set Default Storage Class**
```bash
# Set as default
kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Remove default annotation
kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Check default storage class
kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}'
```

## 📊 **Volume Management Commands**

### **Volume Expansion**
```bash
# Expand PVC (if storage class allows)
kubectl patch pvc <pvc-name> -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# Check expansion status
kubectl get pvc <pvc-name> -o jsonpath='{.status.conditions[?(@.type=="Resizing")].status}'

# Wait for expansion to complete
kubectl wait --for=condition=FileSystemResizePending=false pvc/<pvc-name> --timeout=300s
```

### **Volume Snapshots**
```bash
# Create volume snapshot
kubectl create -f volumesnapshot.yaml

# List volume snapshots
kubectl get volumesnapshot [options]
kubectl get vs [options]  # Short form

# Get volume snapshot classes
kubectl get volumesnapshotclass [options]
kubectl get vsc [options]  # Short form

# Describe volume snapshot
kubectl describe volumesnapshot <snapshot-name>
```

## 🔧 **Storage Troubleshooting Commands**

### **Pod Volume Mounting**
```bash
# Check pod volume mounts
kubectl describe pod <pod-name>
kubectl get pod <pod-name> -o jsonpath='{.spec.volumes}'
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].volumeMounts}'

# Check volume mount status
kubectl exec -it <pod-name> -- df -h
kubectl exec -it <pod-name> -- mount | grep <mount-path>
kubectl exec -it <pod-name> -- ls -la <mount-path>
```

### **Storage Events and Logs**
```bash
# Get storage-related events
kubectl get events --field-selector=reason=FailedMount
kubectl get events --field-selector=reason=VolumeBindingFailed
kubectl get events --field-selector=involvedObject.kind=PersistentVolumeClaim

# Check CSI driver logs
kubectl logs -n kube-system -l app=csi-driver
kubectl logs -n kube-system -l app=ebs-csi-controller
kubectl logs -n kube-system -l app=efs-csi-controller
```

### **Storage Metrics**
```bash
# Check storage usage
kubectl top pods --containers --use-protocol-buffers
kubectl exec -it <pod-name> -- du -sh <mount-path>

# PV and PVC capacity
kubectl get pv -o custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage,USED:.status.capacity.storage
kubectl get pvc -o custom-columns=NAME:.metadata.name,REQUESTED:.spec.resources.requests.storage,CAPACITY:.status.capacity.storage
```

## 🎯 **Advanced Storage Operations**

### **StatefulSet Storage**
```bash
# Create StatefulSet with storage
kubectl create -f statefulset-with-storage.yaml

# Scale StatefulSet (creates new PVCs)
kubectl scale statefulset <name> --replicas=5

# Delete StatefulSet (preserves PVCs)
kubectl delete statefulset <name> --cascade=orphan

# Check StatefulSet PVCs
kubectl get pvc -l app=<statefulset-name>
```

### **Storage Migration**
```bash
# Clone PVC (if supported)
kubectl create -f pvc-clone.yaml

# Backup PVC data
kubectl exec -it <pod-name> -- tar czf - <data-path> > backup.tar.gz

# Restore PVC data
kubectl exec -it <pod-name> -- tar xzf - < backup.tar.gz
```

### **CSI Driver Management**
```bash
# List CSI drivers
kubectl get csidriver

# Get CSI nodes
kubectl get csinode

# Check CSI storage capacity
kubectl get csistoragecapacity

# CSI driver info
kubectl describe csidriver <driver-name>
```

## 📋 **Storage Configuration Examples**

### **PV Manifest Options**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
  labels:                                   # Labels for selection
    type: local
    environment: production
  annotations:                              # Annotations for metadata
    volume.beta.kubernetes.io/storage-class: manual
spec:
  capacity:
    storage: 10Gi                          # Storage capacity
  accessModes:                             # Access modes
    - ReadWriteOnce                        # RWO, ROX, RWX, RWOP
  persistentVolumeReclaimPolicy: Retain    # Retain, Delete, Recycle
  storageClassName: manual                 # Storage class name
  volumeMode: Filesystem                   # Filesystem or Block
  hostPath:                                # Host path volume
    path: /mnt/data
    type: DirectoryOrCreate                # Directory, File, Socket, etc.
  # Alternative volume types:
  # awsElasticBlockStore:
  #   volumeID: vol-12345678
  #   fsType: ext4
  # nfs:
  #   server: nfs-server.example.com
  #   path: /path/to/share
  # iscsi:
  #   targetPortal: 10.0.2.15:3260
  #   iqn: iqn.2001-04.com.example:storage.kube.sys1.xyz
  #   lun: 0
  #   fsType: ext4
```

### **PVC Manifest Options**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: production
  labels:
    app: database
  annotations:
    volume.beta.kubernetes.io/storage-class: fast-ssd
spec:
  accessModes:
    - ReadWriteOnce                        # Must match PV access modes
  resources:
    requests:
      storage: 10Gi                        # Requested storage size
    limits:
      storage: 20Gi                        # Maximum storage size
  storageClassName: fast-ssd               # Storage class
  volumeMode: Filesystem                   # Filesystem or Block
  selector:                                # PV selector
    matchLabels:
      type: local
    matchExpressions:
      - key: environment
        operator: In
        values: ["production", "staging"]
  dataSource:                              # Data source for cloning
    kind: PersistentVolumeClaim
    name: source-pvc
  dataSourceRef:                           # Extended data source
    kind: VolumeSnapshot
    name: my-snapshot
    apiGroup: snapshot.storage.k8s.io
```

### **Storage Class Manifest Options**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"  # Default class
provisioner: kubernetes.io/aws-ebs        # Provisioner
parameters:                                # Provisioner-specific parameters
  type: gp3                               # EBS volume type
  fsType: ext4                            # Filesystem type
  encrypted: "true"                       # Encryption
  kmsKeyId: arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012
reclaimPolicy: Delete                      # Delete, Retain
volumeBindingMode: WaitForFirstConsumer    # Immediate, WaitForFirstConsumer
allowVolumeExpansion: true                 # Allow expansion
mountOptions:                              # Mount options
  - debug
  - rsize=1048576
allowedTopologies:                         # Topology constraints
  - matchLabelExpressions:
    - key: topology.kubernetes.io/zone
      values:
        - us-west-2a
        - us-west-2b
```

## 🔍 **Storage Debugging Checklist**

### **Common Issues and Commands**
```bash
# PVC stuck in Pending
kubectl describe pvc <pvc-name>           # Check events
kubectl get pv                            # Check available PVs
kubectl get storageclass                  # Verify storage class exists

# Pod stuck in ContainerCreating
kubectl describe pod <pod-name>           # Check volume mount errors
kubectl get events --field-selector=involvedObject.name=<pod-name>

# Volume mount failures
kubectl logs -n kube-system -l app=csi-driver  # Check CSI logs
kubectl exec -it <pod-name> -- mount     # Check mount status

# Performance issues
kubectl exec -it <pod-name> -- iostat -x 1  # I/O statistics
kubectl exec -it <pod-name> -- iotop     # I/O monitoring
kubectl top pods --containers            # Resource usage
```
