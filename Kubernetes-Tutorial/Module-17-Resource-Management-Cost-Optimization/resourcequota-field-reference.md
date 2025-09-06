# 📊 **ResourceQuota Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **ResourceQuota Manifest Structure**

```yaml
apiVersion: v1                              # FIXED VALUE: v1
kind: ResourceQuota                         # FIXED VALUE: ResourceQuota
metadata:
  name: string                              # REQUIRED: DNS-1123 subdomain
  namespace: string                         # REQUIRED: target namespace
  labels:                                   # OPTIONAL: key-value pairs
    key: value
  annotations:                              # OPTIONAL: key-value pairs
    key: value
spec:
  hard:                                     # OPTIONAL: hard resource limits
    # COMPUTE RESOURCES:
    requests.cpu: string                    # Total CPU requests limit
    requests.memory: string                 # Total memory requests limit
    limits.cpu: string                      # Total CPU limits
    limits.memory: string                   # Total memory limits
    
    # STORAGE RESOURCES:
    requests.storage: string                # Total storage requests
    persistentvolumeclaims: string          # Max number of PVCs
    
    # OBJECT COUNT LIMITS:
    count/pods: string                      # Max number of pods
    count/services: string                  # Max number of services
    count/secrets: string                   # Max number of secrets
    count/configmaps: string                # Max number of ConfigMaps
    count/persistentvolumeclaims: string    # Max number of PVCs
    count/replicationcontrollers: string    # Max number of RCs
    count/deployments.apps: string          # Max number of Deployments
    count/replicasets.apps: string          # Max number of ReplicaSets
    count/statefulsets.apps: string         # Max number of StatefulSets
    count/jobs.batch: string                # Max number of Jobs
    count/cronjobs.batch: string            # Max number of CronJobs
    
    # SERVICE-SPECIFIC LIMITS:
    services.loadbalancers: string          # Max LoadBalancer services
    services.nodeports: string              # Max NodePort services
    
    # EXTENDED RESOURCES:
    requests.nvidia.com/gpu: string         # GPU requests
    limits.nvidia.com/gpu: string           # GPU limits
    
  scopes:                                   # OPTIONAL: quota scopes
    - Terminating                           # VALUES: Terminating|NotTerminating|BestEffort|NotBestEffort|PriorityClass
  scopeSelector:                            # OPTIONAL: scope selector
    matchExpressions:                       # OPTIONAL: scope expressions
      - scopeName: string                   # REQUIRED: scope name
        operator: string                    # REQUIRED: In|NotIn|Exists|DoesNotExist
        values:                             # OPTIONAL: array of values
          - string
status:                                     # READ-ONLY: managed by system
  hard:                                     # Current hard limits
    key: value
  used:                                     # Current usage
    key: value
```

## 📊 **Field Value Details**

### **Compute Resource Values**
```yaml
# CPU RESOURCES (cores):
requests.cpu: "10"                          # 10 CPU cores
requests.cpu: "500m"                        # 0.5 CPU cores (millicores)
requests.cpu: "2.5"                         # 2.5 CPU cores
limits.cpu: "20"                            # 20 CPU cores limit
limits.cpu: "1000m"                         # 1 CPU core limit

# MEMORY RESOURCES:
requests.memory: "10Gi"                     # 10 gibibytes
requests.memory: "5000Mi"                   # 5000 mebibytes
requests.memory: "1Ti"                      # 1 tebibyte
limits.memory: "20Gi"                       # 20 gibibytes limit
limits.memory: "50000Mi"                    # 50000 mebibytes limit

# STORAGE RESOURCES:
requests.storage: "100Gi"                   # 100 gibibytes storage
requests.storage: "1Ti"                     # 1 tebibyte storage
requests.storage: "500000Mi"                # 500000 mebibytes storage
```

### **Object Count Values**
```yaml
# POD LIMITS:
count/pods: "100"                           # Maximum 100 pods
pods: "50"                                  # Alternative syntax (deprecated)

# SERVICE LIMITS:
count/services: "20"                        # Maximum 20 services
services: "15"                              # Alternative syntax
services.loadbalancers: "5"                 # Maximum 5 LoadBalancer services
services.nodeports: "10"                    # Maximum 10 NodePort services

# STORAGE LIMITS:
persistentvolumeclaims: "20"                # Maximum 20 PVCs
count/persistentvolumeclaims: "25"          # Alternative syntax

# WORKLOAD LIMITS:
count/deployments.apps: "30"                # Maximum 30 Deployments
count/statefulsets.apps: "10"               # Maximum 10 StatefulSets
count/jobs.batch: "50"                      # Maximum 50 Jobs
count/cronjobs.batch: "20"                  # Maximum 20 CronJobs

# CONFIGURATION LIMITS:
count/secrets: "50"                         # Maximum 50 Secrets
count/configmaps: "50"                      # Maximum 50 ConfigMaps
```

### **scopes Values**
```yaml
# TERMINATION SCOPES:
scopes:
  - Terminating                             # Pods with activeDeadlineSeconds
  - NotTerminating                          # Pods without activeDeadlineSeconds

# QOS SCOPES:
scopes:
  - BestEffort                              # BestEffort QoS pods only
  - NotBestEffort                           # Guaranteed and Burstable QoS pods

# PRIORITY SCOPES:
scopes:
  - PriorityClass                           # Pods with specific priority class

# CROSS-NAMESPACE SCOPES (1.17+):
scopes:
  - CrossNamespacePodAffinity               # Pods with cross-namespace affinity
```

### **scopeSelector Values**
```yaml
# PRIORITY CLASS SELECTOR:
scopeSelector:
  matchExpressions:
    - scopeName: PriorityClass              # Priority class scope
      operator: In                          # Operator type
      values:
        - high-priority                     # High priority class
        - medium-priority                   # Medium priority class

# QOS CLASS SELECTOR:
scopeSelector:
  matchExpressions:
    - scopeName: BestEffort                 # QoS scope
      operator: Exists                      # Existence check

# OPERATORS:
operator: In                                # Value must be in values list
operator: NotIn                             # Value must not be in values list
operator: Exists                            # Scope must exist
operator: DoesNotExist                      # Scope must not exist
```

### **Extended Resource Values**
```yaml
# GPU RESOURCES:
requests.nvidia.com/gpu: "4"                # 4 NVIDIA GPUs
limits.nvidia.com/gpu: "8"                  # 8 NVIDIA GPU limit

# CUSTOM RESOURCES:
requests.example.com/custom-resource: "10"  # Custom resource requests
limits.example.com/custom-resource: "20"    # Custom resource limits

# INTEL GPU:
requests.gpu.intel.com/i915: "2"           # Intel GPU resources
limits.gpu.intel.com/i915: "4"             # Intel GPU limits

# AMD GPU:
requests.amd.com/gpu: "2"                   # AMD GPU resources
limits.amd.com/gpu: "4"                     # AMD GPU limits
```

## 🎯 **Complete ResourceQuota Examples**

### **Basic Compute and Storage Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "10"                      # 10 CPU cores total requests
    requests.memory: 20Gi                   # 20 GiB memory total requests
    limits.cpu: "20"                        # 20 CPU cores total limits
    limits.memory: 40Gi                     # 40 GiB memory total limits
    requests.storage: 1Ti                   # 1 TiB storage requests
    persistentvolumeclaims: "10"            # Maximum 10 PVCs
```

### **Object Count Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-count-quota
  namespace: development
spec:
  hard:
    count/pods: "50"                        # Maximum 50 pods
    count/services: "20"                    # Maximum 20 services
    count/secrets: "30"                     # Maximum 30 secrets
    count/configmaps: "30"                  # Maximum 30 ConfigMaps
    count/deployments.apps: "25"            # Maximum 25 Deployments
    count/statefulsets.apps: "5"            # Maximum 5 StatefulSets
    count/jobs.batch: "100"                 # Maximum 100 Jobs
    count/cronjobs.batch: "10"              # Maximum 10 CronJobs
```

### **Service-Specific Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: service-quota
  namespace: web-services
spec:
  hard:
    services: "15"                          # Maximum 15 services total
    services.loadbalancers: "3"             # Maximum 3 LoadBalancer services
    services.nodeports: "5"                 # Maximum 5 NodePort services
    count/ingresses.networking.k8s.io: "10" # Maximum 10 Ingresses
```

### **QoS-Specific Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: besteffort-quota
  namespace: batch-jobs
spec:
  hard:
    count/pods: "100"                       # Maximum 100 BestEffort pods
    requests.cpu: "0"                       # No CPU requests for BestEffort
    requests.memory: "0"                    # No memory requests for BestEffort
  scopes:
    - BestEffort                            # Apply only to BestEffort pods
```

### **Priority Class Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: high-priority-quota
  namespace: critical-services
spec:
  hard:
    requests.cpu: "20"                      # 20 CPU cores for high priority
    requests.memory: 40Gi                   # 40 GiB memory for high priority
    count/pods: "20"                        # Maximum 20 high priority pods
  scopeSelector:
    matchExpressions:
      - scopeName: PriorityClass
        operator: In
        values:
          - high-priority
          - critical-priority
```

### **GPU Resource Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gpu-quota
  namespace: ml-workloads
spec:
  hard:
    requests.nvidia.com/gpu: "8"            # 8 NVIDIA GPUs total
    limits.nvidia.com/gpu: "16"             # 16 NVIDIA GPUs limit
    requests.cpu: "32"                      # 32 CPU cores for GPU workloads
    requests.memory: 128Gi                  # 128 GiB memory for GPU workloads
    count/pods: "10"                        # Maximum 10 GPU pods
```

## 🔍 **Validation Rules**

### **Resource Format Validation**
```yaml
# VALID CPU FORMATS:
requests.cpu: "1"                           # 1 CPU core
requests.cpu: "500m"                        # 500 millicores
requests.cpu: "1.5"                         # 1.5 CPU cores
requests.cpu: "2000m"                       # 2000 millicores (2 cores)

# INVALID CPU FORMATS:
requests.cpu: "1 core"                      # Units not allowed
requests.cpu: "-1"                          # Negative values not allowed
requests.cpu: "1.5.0"                       # Invalid decimal format

# VALID MEMORY FORMATS:
requests.memory: "1Gi"                      # 1 gibibyte
requests.memory: "1000Mi"                   # 1000 mebibytes
requests.memory: "1Ti"                      # 1 tebibyte
requests.memory: "500000000"                # 500 million bytes

# INVALID MEMORY FORMATS:
requests.memory: "1 GB"                     # Spaces not allowed
requests.memory: "-1Gi"                     # Negative values not allowed
requests.memory: "1.5.0Gi"                 # Invalid format
```

### **Scope Validation**
```yaml
# VALID SCOPE COMBINATIONS:
scopes:
  - Terminating                             # Valid single scope
  
scopes:
  - NotTerminating                          # Valid single scope
  - NotBestEffort                           # Compatible combination

# INVALID SCOPE COMBINATIONS:
scopes:
  - Terminating                             # INVALID: conflicting scopes
  - NotTerminating                          # Cannot have both

scopes:
  - BestEffort                              # INVALID: conflicting scopes
  - NotBestEffort                           # Cannot have both
```

### **Object Count Validation**
```yaml
# VALID OBJECT COUNTS:
count/pods: "0"                             # Zero is valid (no pods allowed)
count/pods: "1000"                          # Large numbers allowed
persistentvolumeclaims: "50"                # Standard format

# INVALID OBJECT COUNTS:
count/pods: "-1"                            # Negative not allowed
count/pods: "1.5"                           # Decimals not allowed
count/pods: "unlimited"                     # Text not allowed
```

## 📋 **Common Patterns**

### **Development Environment Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"                       # Limited CPU for development
    requests.memory: 8Gi                    # Limited memory
    requests.storage: 100Gi                 # Limited storage
    count/pods: "20"                        # Limited pod count
    count/services: "10"                    # Limited services
    persistentvolumeclaims: "5"             # Limited PVCs
```

### **Production Environment Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    requests.cpu: "50"                      # Higher CPU allocation
    requests.memory: 100Gi                  # Higher memory allocation
    requests.storage: 10Ti                  # Higher storage allocation
    count/pods: "200"                       # Higher pod count
    services.loadbalancers: "10"            # LoadBalancer services allowed
    count/secrets: "100"                    # More secrets for production
```

### **Batch Processing Quota**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: batch-quota
  namespace: batch-processing
spec:
  hard:
    count/jobs.batch: "1000"                # Many batch jobs
    count/cronjobs.batch: "50"              # Scheduled jobs
    requests.cpu: "100"                     # High CPU for batch processing
    requests.memory: 200Gi                  # High memory for data processing
  scopes:
    - NotTerminating                        # Long-running batch jobs
```
