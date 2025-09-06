# 📊 **Kubectl Resource Management Command Reference**
*Complete guide to all resource management kubectl commands and options*

## 🔧 **Resource Quota Commands**

### **Create ResourceQuota**
```bash
# Create resource quota from YAML
kubectl create -f resourcequota.yaml [options]

# Create resource quota imperatively
kubectl create quota <name> [options]
```

**Complete Options:**
```bash
kubectl create quota my-quota \
  --hard=cpu=10,memory=20Gi,pods=50 \     # Resource limits
  --namespace=production \                # Target namespace
  --dry-run=client \                      # Validate without creating
  --output=yaml \                         # Output format
  --save-config                           # Save config in annotation
```

### **Get ResourceQuotas**
```bash
# List resource quotas
kubectl get resourcequota [options]
kubectl get quota [options]  # Short form

# Complete get options
kubectl get resourcequota \
  --all-namespaces \                      # Show all namespaces
  --output=wide \                         # Wide output format
  --output=custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,CPU-REQUESTS:.status.hard.requests\.cpu,MEMORY-REQUESTS:.status.hard.requests\.memory \
  --show-labels \                         # Show resource labels
  --sort-by=.metadata.name                # Sort by name
```

### **Describe ResourceQuota**
```bash
# Describe resource quota usage
kubectl describe resourcequota <name> [options]
kubectl describe quota <name> [options]  # Short form

# Describe options
kubectl describe resourcequota my-quota \
  --namespace=production                  # Target namespace
```

**Expected Output:**
```
Name:                   my-quota
Namespace:              production
Resource                Used   Hard
--------                ----   ----
limits.cpu              8      20
limits.memory           16Gi   40Gi
pods                    25     50
requests.cpu            4      10
requests.memory         8Gi    20Gi
requests.storage        500Gi  1Ti
```

## 🔧 **LimitRange Commands**

### **Create LimitRange**
```bash
# Create limit range from YAML
kubectl create -f limitrange.yaml [options]

# Create limit range imperatively (limited functionality)
kubectl create limitrange <name> [options]
```

### **Get LimitRanges**
```bash
# List limit ranges
kubectl get limitrange [options]
kubectl get limits [options]  # Short form

# Complete get options
kubectl get limitrange \
  --all-namespaces \                      # All namespaces
  --output=wide \                         # Wide output
  --output=yaml \                         # YAML output
  --show-labels                           # Show labels
```

### **Describe LimitRange**
```bash
# Describe limit range details
kubectl describe limitrange <name> [options]
kubectl describe limits <name> [options]  # Short form
```

**Expected Output:**
```
Name:       resource-limits
Namespace:  production
Type        Resource  Min    Max    Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---    ---    ---------------  -------------  -----------------------
Container   cpu       100m   4      200m             500m           4
Container   memory    128Mi  8Gi    256Mi            1Gi            2
Pod         cpu       -      8      -                -              -
Pod         memory    -      16Gi   -                -              -
```

## 📊 **Resource Usage Commands**

### **Top Commands (Resource Usage)**
```bash
# Node resource usage
kubectl top nodes [options]

# Pod resource usage
kubectl top pods [options]

# Complete top options
kubectl top nodes \
  --sort-by=cpu \                         # Sort by CPU usage
  --sort-by=memory \                      # Sort by memory usage
  --no-headers \                          # Skip headers
  --use-protocol-buffers                  # Use protocol buffers (faster)

kubectl top pods \
  --all-namespaces \                      # All namespaces
  --containers \                          # Show container-level usage
  --sort-by=cpu \                         # Sort by CPU
  --sort-by=memory \                      # Sort by memory
  --selector=app=backend \                # Filter by labels
  --field-selector=status.phase=Running   # Filter by fields
```

**Expected Output:**
```bash
# kubectl top nodes
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
worker-node-1  2456m        61%    7892Mi          49%
worker-node-2  1834m        45%    6234Mi          39%
worker-node-3  3012m        75%    9456Mi          59%

# kubectl top pods --containers
POD                               NAME              CPU(cores)   MEMORY(bytes)
ecommerce-backend-7d4b8c8f9d-abc12   fastapi-backend   450m         1200Mi
ecommerce-frontend-6b9c7d8e9f-ghi56  react-frontend    120m         300Mi
ecommerce-database-0                  postgresql        1200m        3200Mi
```

### **Resource Capacity Commands**
```bash
# Check node capacity and allocatable resources
kubectl describe nodes [node-name]

# Get node capacity in custom format
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU-CAPACITY:.status.capacity.cpu,MEMORY-CAPACITY:.status.capacity.memory,CPU-ALLOCATABLE:.status.allocatable.cpu,MEMORY-ALLOCATABLE:.status.allocatable.memory

# Check resource requests and limits for pods
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU-REQUEST:.spec.containers[*].resources.requests.cpu,MEMORY-REQUEST:.spec.containers[*].resources.requests.memory,CPU-LIMIT:.spec.containers[*].resources.limits.cpu,MEMORY-LIMIT:.spec.containers[*].resources.limits.memory
```

## 🔧 **VPA Commands**

### **Create VerticalPodAutoscaler**
```bash
# Create VPA from YAML
kubectl create -f vpa.yaml [options]

# Get VPA status
kubectl get vpa [options]

# Describe VPA recommendations
kubectl describe vpa <name> [options]
```

**VPA Status Output:**
```bash
# kubectl get vpa
NAME          MODE   CPU    MEM      PROVIDED   AGE
backend-vpa   Auto   587m   943Mi    True       2d
frontend-vpa  Off    142m   256Mi    True       2d

# kubectl describe vpa backend-vpa
Name:         backend-vpa
Namespace:    ecommerce-prod
API Version:  autoscaling.k8s.io/v1
Kind:         VerticalPodAutoscaler
...
Status:
  Conditions:
    Status:  True
    Type:    RecommendationProvided
  Recommendation:
    Container Recommendations:
      Container Name:  fastapi-backend
      Lower Bound:
        Cpu:     400m
        Memory:  800Mi
      Target:
        Cpu:     587m
        Memory:  943Mi
      Uncapped Target:
        Cpu:     587m
        Memory:  943Mi
      Upper Bound:
        Cpu:     1200m
        Memory:  2Gi
```

## 📊 **Resource Analysis Commands**

### **Resource Utilization Analysis**
```bash
# Analyze resource requests vs usage
kubectl get pods -o json | jq -r '.items[] | select(.spec.containers[].resources.requests) | "\(.metadata.name) \(.spec.containers[].resources.requests.cpu // "0") \(.spec.containers[].resources.requests.memory // "0")"'

# Check QoS classes
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,NODE:.spec.nodeName

# Find pods without resource requests/limits
kubectl get pods -o json | jq -r '.items[] | select(.spec.containers[].resources | not) | .metadata.name'

# Calculate resource utilization percentage
kubectl top pods --no-headers | awk '{print $1, $2, $3}' | while read name cpu memory; do
  requests=$(kubectl get pod $name -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null || echo "0")
  echo "Pod: $name, CPU Usage: $cpu, CPU Request: $requests"
done
```

### **Resource Pressure Detection**
```bash
# Check for resource pressure events
kubectl get events --field-selector=reason=FailedScheduling
kubectl get events --field-selector=reason=Evicted
kubectl get events --field-selector=reason=OutOfMemory

# Check node conditions for resource pressure
kubectl get nodes -o custom-columns=NAME:.metadata.name,MEMORY-PRESSURE:.status.conditions[?(@.type==\"MemoryPressure\")].status,DISK-PRESSURE:.status.conditions[?(@.type==\"DiskPressure\")].status,PID-PRESSURE:.status.conditions[?(@.type==\"PIDPressure\")].status

# Find pods in pending state due to resource constraints
kubectl get pods --field-selector=status.phase=Pending -o custom-columns=NAME:.metadata.name,REASON:.status.conditions[?(@.type==\"PodScheduled\")].reason,MESSAGE:.status.conditions[?(@.type==\"PodScheduled\")].message
```

## 🔧 **Resource Modification Commands**

### **Patch Resource Requests/Limits**
```bash
# Update deployment resources
kubectl patch deployment <name> --patch '
spec:
  template:
    spec:
      containers:
      - name: <container-name>
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 1000m
            memory: 2Gi
'

# Update StatefulSet resources
kubectl patch statefulset <name> --patch '
spec:
  template:
    spec:
      containers:
      - name: <container-name>
        resources:
          requests:
            cpu: 1000m
            memory: 2Gi
          limits:
            cpu: 2000m
            memory: 4Gi
'

# Scale deployment replicas
kubectl scale deployment <name> --replicas=<count>

# Update resource quota
kubectl patch resourcequota <name> --patch '
spec:
  hard:
    requests.cpu: "20"
    requests.memory: 40Gi
    limits.cpu: "40"
    limits.memory: 80Gi
'
```

### **Resource Validation Commands**
```bash
# Validate resource configuration before applying
kubectl apply --dry-run=client -f resource-config.yaml

# Check if resources fit within quota
kubectl auth can-i create pods --as=system:serviceaccount:default:default

# Simulate pod scheduling
kubectl create --dry-run=server -f pod.yaml

# Check resource availability on nodes
kubectl describe nodes | grep -A 5 "Allocated resources"
```

## 📊 **Cost Analysis Commands**

### **Resource Cost Calculation**
```bash
# Calculate total resource requests by namespace
kubectl get pods --all-namespaces -o json | jq -r '
.items[] | 
select(.spec.containers[].resources.requests) |
{
  namespace: .metadata.namespace,
  name: .metadata.name,
  cpu: (.spec.containers[].resources.requests.cpu // "0"),
  memory: (.spec.containers[].resources.requests.memory // "0")
}' | jq -s 'group_by(.namespace) | map({namespace: .[0].namespace, pods: length, total_cpu: map(.cpu) | add, total_memory: map(.memory) | add})'

# Find most resource-intensive pods
kubectl top pods --all-namespaces --sort-by=cpu | head -10
kubectl top pods --all-namespaces --sort-by=memory | head -10

# Identify unused resources
kubectl get nodes -o json | jq -r '.items[] | {name: .metadata.name, capacity: .status.capacity, allocatable: .status.allocatable, usage: .status.usage}'
```

### **Resource Optimization Recommendations**
```bash
# Find pods with high limit/request ratios
kubectl get pods -o json | jq -r '
.items[] | 
select(.spec.containers[].resources.requests and .spec.containers[].resources.limits) |
{
  name: .metadata.name,
  namespace: .metadata.namespace,
  cpu_request: .spec.containers[0].resources.requests.cpu,
  cpu_limit: .spec.containers[0].resources.limits.cpu,
  memory_request: .spec.containers[0].resources.requests.memory,
  memory_limit: .spec.containers[0].resources.limits.memory
}'

# Find pods without resource specifications
kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.spec.containers[].resources | not) | "\(.metadata.namespace)/\(.metadata.name)"'

# Check for BestEffort QoS pods (potential optimization targets)
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,QOS:.status.qosClass | grep BestEffort
```

## 🔍 **Troubleshooting Commands**

### **Resource-Related Issues**
```bash
# Check why pod is not scheduled
kubectl describe pod <pod-name> | grep -A 10 Events

# Find resource pressure on nodes
kubectl describe nodes | grep -A 5 "Conditions:"

# Check for evicted pods
kubectl get pods --all-namespaces | grep Evicted

# Analyze resource quota usage
kubectl describe resourcequota --all-namespaces

# Check limit range violations
kubectl get events --field-selector=reason=LimitRangeViolation

# Find pods exceeding resource limits
kubectl top pods --containers | awk 'NR>1 && $3+0 > 1000 {print "High CPU: " $0}'
kubectl top pods --containers | awk 'NR>1 && $4+0 > 2000 {print "High Memory: " $0}'
```

### **Performance Analysis**
```bash
# Monitor resource usage over time
watch kubectl top nodes
watch kubectl top pods --sort-by=cpu

# Check resource allocation efficiency
kubectl get nodes -o json | jq -r '.items[] | {
  name: .metadata.name,
  cpu_capacity: .status.capacity.cpu,
  memory_capacity: .status.capacity.memory,
  cpu_allocatable: .status.allocatable.cpu,
  memory_allocatable: .status.allocatable.memory
}'

# Analyze pod distribution across nodes
kubectl get pods -o wide --all-namespaces | awk '{print $8}' | sort | uniq -c | sort -nr
```

## 📋 **Command Patterns and Best Practices**

### **Resource Management Workflow**
```bash
# 1. Analyze current usage
kubectl top nodes
kubectl top pods --all-namespaces --containers

# 2. Check resource quotas and limits
kubectl get resourcequota --all-namespaces
kubectl get limitrange --all-namespaces

# 3. Identify optimization opportunities
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass | grep BestEffort

# 4. Apply optimizations
kubectl patch deployment <name> --patch '<resource-patch>'

# 5. Monitor impact
watch kubectl top pods -l app=<app-name>

# 6. Validate performance
kubectl get events --field-selector=reason=FailedScheduling
```

### **Emergency Resource Management**
```bash
# Quickly scale down resource-intensive workloads
kubectl scale deployment <name> --replicas=0

# Emergency resource quota increase
kubectl patch resourcequota <name> --patch '{"spec":{"hard":{"requests.cpu":"50","requests.memory":"100Gi"}}}'

# Find and delete evicted pods
kubectl get pods --all-namespaces | grep Evicted | awk '{print $2 " -n " $1}' | xargs -r kubectl delete pod

# Force pod eviction for resource reclamation
kubectl delete pod <pod-name> --grace-period=0 --force
```
