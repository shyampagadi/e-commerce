# 📏 **LimitRange Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **LimitRange Manifest Structure**

```yaml
apiVersion: v1                              # FIXED VALUE: v1
kind: LimitRange                            # FIXED VALUE: LimitRange
metadata:
  name: string                              # REQUIRED: DNS-1123 subdomain
  namespace: string                         # REQUIRED: target namespace
  labels:                                   # OPTIONAL: key-value pairs
    key: value
  annotations:                              # OPTIONAL: key-value pairs
    key: value
spec:
  limits:                                   # REQUIRED: array of limit definitions
    - type: string                          # REQUIRED: Container|Pod|PersistentVolumeClaim
      default:                              # OPTIONAL: default limits (if not specified)
        cpu: string                         # CPU default limit
        memory: string                      # Memory default limit
        storage: string                     # Storage default limit (PVC only)
        ephemeral-storage: string           # Ephemeral storage default limit
      defaultRequest:                       # OPTIONAL: default requests (if not specified)
        cpu: string                         # CPU default request
        memory: string                      # Memory default request
        storage: string                     # Storage default request (PVC only)
        ephemeral-storage: string           # Ephemeral storage default request
      min:                                  # OPTIONAL: minimum allowed resources
        cpu: string                         # Minimum CPU
        memory: string                      # Minimum memory
        storage: string                     # Minimum storage
        ephemeral-storage: string           # Minimum ephemeral storage
      max:                                  # OPTIONAL: maximum allowed resources
        cpu: string                         # Maximum CPU
        memory: string                      # Maximum memory
        storage: string                     # Maximum storage
        ephemeral-storage: string           # Maximum ephemeral storage
      maxLimitRequestRatio:                 # OPTIONAL: max limit/request ratio
        cpu: string                         # CPU ratio limit
        memory: string                      # Memory ratio limit
        storage: string                     # Storage ratio limit
        ephemeral-storage: string           # Ephemeral storage ratio limit
```

## 📊 **Field Value Details**

### **type Values**
```yaml
type: Container                             # Apply limits to individual containers
type: Pod                                   # Apply limits to entire pods
type: PersistentVolumeClaim                 # Apply limits to PVC storage requests

# TYPE CHARACTERISTICS:
# Container: 
#   - Applies to each container in a pod
#   - Most common type for resource management
#   - Supports CPU, memory, ephemeral-storage

# Pod:
#   - Applies to the sum of all containers in a pod
#   - Used for pod-level resource constraints
#   - Supports CPU, memory, ephemeral-storage

# PersistentVolumeClaim:
#   - Applies to storage requests in PVCs
#   - Only supports storage resource
#   - Controls PVC size limits
```

### **Resource Value Formats**

#### **CPU Values**
```yaml
# CPU CORES:
cpu: "1"                                    # 1 CPU core
cpu: "2.5"                                  # 2.5 CPU cores
cpu: "0.5"                                  # 0.5 CPU cores

# MILLICORES:
cpu: "100m"                                 # 100 millicores (0.1 cores)
cpu: "500m"                                 # 500 millicores (0.5 cores)
cpu: "1000m"                                # 1000 millicores (1 core)
cpu: "2500m"                                # 2500 millicores (2.5 cores)

# COMMON CPU VALUES:
cpu: "50m"                                  # Minimal CPU (0.05 cores)
cpu: "100m"                                 # Light workload (0.1 cores)
cpu: "250m"                                 # Small application (0.25 cores)
cpu: "500m"                                 # Medium application (0.5 cores)
cpu: "1000m"                                # Large application (1 core)
cpu: "2000m"                                # High-performance app (2 cores)
cpu: "4000m"                                # CPU-intensive workload (4 cores)
```

#### **Memory Values**
```yaml
# BINARY UNITS (IEC):
memory: "128Mi"                             # 128 mebibytes
memory: "256Mi"                             # 256 mebibytes
memory: "512Mi"                             # 512 mebibytes
memory: "1Gi"                               # 1 gibibyte
memory: "2Gi"                               # 2 gibibytes
memory: "4Gi"                               # 4 gibibytes
memory: "8Gi"                               # 8 gibibytes
memory: "16Gi"                              # 16 gibibytes

# DECIMAL UNITS (SI):
memory: "128M"                              # 128 megabytes
memory: "1G"                                # 1 gigabyte
memory: "1T"                                # 1 terabyte

# BYTES:
memory: "134217728"                         # 128 MiB in bytes
memory: "1073741824"                        # 1 GiB in bytes

# COMMON MEMORY VALUES:
memory: "64Mi"                              # Minimal memory
memory: "128Mi"                             # Small application
memory: "256Mi"                             # Light workload
memory: "512Mi"                             # Medium application
memory: "1Gi"                               # Standard application
memory: "2Gi"                               # Large application
memory: "4Gi"                               # Memory-intensive app
memory: "8Gi"                               # Database/cache
memory: "16Gi"                              # Big data processing
```

#### **Storage Values**
```yaml
# STORAGE SIZES:
storage: "1Gi"                              # 1 gibibyte
storage: "10Gi"                             # 10 gibibytes
storage: "100Gi"                            # 100 gibibytes
storage: "1Ti"                              # 1 tebibyte

# COMMON STORAGE VALUES:
storage: "1Gi"                              # Small storage
storage: "10Gi"                             # Application data
storage: "50Gi"                             # Medium database
storage: "100Gi"                            # Large database
storage: "500Gi"                            # Data warehouse
storage: "1Ti"                              # Big data storage
```

#### **Ephemeral Storage Values**
```yaml
# EPHEMERAL STORAGE (temporary disk space):
ephemeral-storage: "1Gi"                    # 1 GiB ephemeral storage
ephemeral-storage: "5Gi"                    # 5 GiB ephemeral storage
ephemeral-storage: "10Gi"                   # 10 GiB ephemeral storage

# COMMON EPHEMERAL STORAGE VALUES:
ephemeral-storage: "500Mi"                  # Minimal temp space
ephemeral-storage: "1Gi"                    # Small temp files
ephemeral-storage: "5Gi"                    # Medium temp processing
ephemeral-storage: "10Gi"                   # Large temp processing
ephemeral-storage: "20Gi"                   # Batch processing temp space
```

### **maxLimitRequestRatio Values**
```yaml
# RATIO VALUES (limit/request):
maxLimitRequestRatio:
  cpu: "2"                                  # Limit can be 2x request
  memory: "1.5"                             # Limit can be 1.5x request
  storage: "1"                              # Limit must equal request

# COMMON RATIOS:
maxLimitRequestRatio:
  cpu: "1"                                  # No overcommit (Guaranteed QoS)
  cpu: "2"                                  # 2x overcommit allowed
  cpu: "4"                                  # 4x overcommit allowed
  cpu: "10"                                 # High overcommit for burstable workloads

maxLimitRequestRatio:
  memory: "1"                               # No memory overcommit
  memory: "1.5"                             # 50% memory overcommit
  memory: "2"                               # 100% memory overcommit
```

## 🎯 **Complete LimitRange Examples**

### **Container-Level Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-limits
  namespace: production
spec:
  limits:
    - type: Container                       # Apply to individual containers
      default:                              # Default limits if not specified
        cpu: 500m                           # Default CPU limit (0.5 cores)
        memory: 1Gi                         # Default memory limit (1 GiB)
        ephemeral-storage: 2Gi              # Default ephemeral storage limit
      defaultRequest:                       # Default requests if not specified
        cpu: 100m                           # Default CPU request (0.1 cores)
        memory: 256Mi                       # Default memory request (256 MiB)
        ephemeral-storage: 1Gi              # Default ephemeral storage request
      min:                                  # Minimum allowed resources
        cpu: 50m                            # Minimum CPU (0.05 cores)
        memory: 64Mi                        # Minimum memory (64 MiB)
        ephemeral-storage: 500Mi            # Minimum ephemeral storage
      max:                                  # Maximum allowed resources
        cpu: 4000m                          # Maximum CPU (4 cores)
        memory: 8Gi                         # Maximum memory (8 GiB)
        ephemeral-storage: 20Gi             # Maximum ephemeral storage
      maxLimitRequestRatio:                 # Maximum limit/request ratios
        cpu: "4"                            # CPU limit can be 4x request
        memory: "2"                         # Memory limit can be 2x request
        ephemeral-storage: "2"              # Ephemeral storage limit can be 2x request
```

### **Pod-Level Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limits
  namespace: development
spec:
  limits:
    - type: Pod                             # Apply to entire pods
      max:                                  # Maximum pod resources (sum of all containers)
        cpu: 8000m                          # Maximum pod CPU (8 cores)
        memory: 16Gi                        # Maximum pod memory (16 GiB)
        ephemeral-storage: 50Gi             # Maximum pod ephemeral storage
      min:                                  # Minimum pod resources
        cpu: 100m                           # Minimum pod CPU (0.1 cores)
        memory: 128Mi                       # Minimum pod memory (128 MiB)
        ephemeral-storage: 1Gi              # Minimum pod ephemeral storage
```

### **PVC Storage Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pvc-limits
  namespace: data-processing
spec:
  limits:
    - type: PersistentVolumeClaim           # Apply to PVC storage requests
      min:                                  # Minimum PVC size
        storage: 1Gi                        # Minimum 1 GiB storage
      max:                                  # Maximum PVC size
        storage: 1Ti                        # Maximum 1 TiB storage
```

### **Multi-Type LimitRange**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: comprehensive-limits
  namespace: multi-tenant
spec:
  limits:
    # Container limits
    - type: Container
      default:
        cpu: 200m
        memory: 512Mi
      defaultRequest:
        cpu: 50m
        memory: 128Mi
      min:
        cpu: 10m
        memory: 32Mi
      max:
        cpu: 2000m
        memory: 4Gi
      maxLimitRequestRatio:
        cpu: "10"
        memory: "4"
    
    # Pod limits
    - type: Pod
      max:
        cpu: 4000m
        memory: 8Gi
      min:
        cpu: 50m
        memory: 64Mi
    
    # PVC limits
    - type: PersistentVolumeClaim
      min:
        storage: 1Gi
      max:
        storage: 100Gi
```

### **Development Environment Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: development
spec:
  limits:
    - type: Container
      default:                              # Conservative defaults for development
        cpu: 100m                           # Low CPU default
        memory: 256Mi                       # Low memory default
      defaultRequest:
        cpu: 50m                            # Minimal CPU request
        memory: 128Mi                       # Minimal memory request
      min:
        cpu: 10m                            # Very low minimum
        memory: 32Mi                        # Very low memory minimum
      max:
        cpu: 1000m                          # Limited maximum for cost control
        memory: 2Gi                         # Limited memory for cost control
      maxLimitRequestRatio:
        cpu: "10"                           # Allow high CPU bursting
        memory: "4"                         # Allow memory bursting
```

### **Production Environment Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: prod-limits
  namespace: production
spec:
  limits:
    - type: Container
      default:                              # Production-ready defaults
        cpu: 500m                           # Higher CPU default
        memory: 1Gi                         # Higher memory default
      defaultRequest:
        cpu: 200m                           # Reasonable CPU request
        memory: 512Mi                       # Reasonable memory request
      min:
        cpu: 100m                           # Higher minimum for stability
        memory: 256Mi                       # Higher memory minimum
      max:
        cpu: 8000m                          # Higher maximum for performance
        memory: 16Gi                        # Higher memory maximum
      maxLimitRequestRatio:
        cpu: "2"                            # Conservative CPU overcommit
        memory: "1.5"                       # Conservative memory overcommit
```

### **GPU Workload Limits**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: gpu-limits
  namespace: ml-workloads
spec:
  limits:
    - type: Container
      default:
        cpu: 4000m                          # High CPU for GPU workloads
        memory: 8Gi                         # High memory for GPU workloads
        nvidia.com/gpu: "1"                 # Default 1 GPU
      defaultRequest:
        cpu: 2000m                          # High CPU request
        memory: 4Gi                         # High memory request
        nvidia.com/gpu: "1"                 # GPU request
      min:
        cpu: 1000m                          # Minimum CPU for GPU efficiency
        memory: 2Gi                         # Minimum memory for GPU workloads
        nvidia.com/gpu: "1"                 # Minimum 1 GPU
      max:
        cpu: 16000m                         # Maximum 16 CPU cores
        memory: 64Gi                        # Maximum 64 GiB memory
        nvidia.com/gpu: "8"                 # Maximum 8 GPUs
```

## 🔍 **Validation Rules**

### **Resource Format Validation**
```yaml
# VALID FORMATS:
cpu: "1"                                    # Integer cores
cpu: "1.5"                                  # Decimal cores
cpu: "500m"                                 # Millicores
memory: "1Gi"                               # Binary units
memory: "1000Mi"                            # Binary units
storage: "10Gi"                             # Storage size

# INVALID FORMATS:
cpu: "1 core"                               # No units allowed
cpu: "-1"                                   # No negative values
memory: "1 GB"                              # No spaces
memory: "-1Gi"                              # No negative values
storage: "unlimited"                        # No text values
```

### **Ratio Validation**
```yaml
# VALID RATIOS:
maxLimitRequestRatio:
  cpu: "1"                                  # 1:1 ratio (no overcommit)
  cpu: "2.5"                                # 2.5:1 ratio
  cpu: "10"                                 # 10:1 ratio (high overcommit)

# INVALID RATIOS:
maxLimitRequestRatio:
  cpu: "0"                                  # Zero not allowed
  cpu: "-1"                                 # Negative not allowed
  cpu: "0.5"                                # Less than 1 not allowed (limit < request)
```

### **Min/Max Validation**
```yaml
# VALID MIN/MAX:
min:
  cpu: 100m
max:
  cpu: 2000m                                # Max must be >= min

# INVALID MIN/MAX:
min:
  cpu: 2000m
max:
  cpu: 100m                                 # INVALID: max < min
```

## 📋 **Common Patterns**

### **Microservices Pattern**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: microservices-limits
  namespace: microservices
spec:
  limits:
    - type: Container
      default:
        cpu: 200m                           # Small CPU for microservices
        memory: 256Mi                       # Small memory footprint
      defaultRequest:
        cpu: 50m                            # Minimal CPU request
        memory: 128Mi                       # Minimal memory request
      max:
        cpu: 1000m                          # Limit microservice size
        memory: 1Gi                         # Limit memory usage
```

### **Batch Processing Pattern**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: batch-limits
  namespace: batch-processing
spec:
  limits:
    - type: Container
      default:
        cpu: 2000m                          # Higher CPU for batch jobs
        memory: 4Gi                         # Higher memory for data processing
      max:
        cpu: 8000m                          # Allow high CPU usage
        memory: 32Gi                        # Allow high memory usage
      maxLimitRequestRatio:
        cpu: "1"                            # No overcommit for batch jobs
        memory: "1"                         # Guaranteed resources
```

### **Database Pattern**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: database-limits
  namespace: databases
spec:
  limits:
    - type: Container
      default:
        cpu: 1000m                          # Standard CPU for databases
        memory: 2Gi                         # Standard memory for databases
      min:
        cpu: 500m                           # Minimum for database performance
        memory: 1Gi                         # Minimum memory for databases
      max:
        cpu: 8000m                          # High CPU for large databases
        memory: 32Gi                        # High memory for databases
      maxLimitRequestRatio:
        cpu: "1"                            # No CPU overcommit for databases
        memory: "1"                         # No memory overcommit for stability
```
