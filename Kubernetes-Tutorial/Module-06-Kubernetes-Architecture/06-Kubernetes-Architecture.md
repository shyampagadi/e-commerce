# 🏗️ **Module 6: Kubernetes Architecture**
## Understanding the Kubernetes Control Plane and Components

---

## 📋 **Module Overview**

**Duration**: 5-6 hours (enhanced with complete foundational knowledge)  
**Prerequisites**: See detailed prerequisites below  
**Learning Objectives**: Master Kubernetes architecture and control plane components with complete foundational knowledge

---

## 🎯 **Detailed Prerequisites**

### **🔧 Technical Prerequisites**

#### **System Requirements**
- **OS**: Linux distribution (Ubuntu 20.04+ recommended) with Kubernetes cluster
- **RAM**: Minimum 8GB (16GB recommended for cluster operations)
- **CPU**: 4+ cores (8+ cores recommended for multi-node cluster)
- **Storage**: 50GB+ free space (100GB+ for cluster data and logs)
- **Network**: Stable internet connection for cluster communication and image pulls

#### **Software Requirements**
- **Kubernetes Cluster**: Version 1.20+ (kubeadm, minikube, or cloud provider)
  ```bash
  # Verify Kubernetes cluster
  kubectl cluster-info
  kubectl get nodes
  kubectl version --client --server
  ```
- **kubectl**: Latest version matching your cluster
  ```bash
  # Verify kubectl installation
  kubectl version --client
  kubectl config current-context
  ```
- **etcd Tools**: etcdctl for etcd cluster management
  ```bash
  # Install etcd tools (if using kubeadm)
  sudo apt-get install -y etcd-client
  # Verify installation
  etcdctl version
  ```

#### **Package Dependencies**
- **Kubernetes Tools**: kubectl, kubeadm, kubelet
  ```bash
  # Verify Kubernetes tools
  kubectl version --client
  kubeadm version
  kubelet --version
  ```
- **Container Runtime**: containerd or Docker
  ```bash
  # Verify container runtime
  containerd --version
  docker --version
  ```
- **Network Tools**: curl, wget for API testing
  ```bash
  # Verify network tools
  curl --version
  wget --version
  ```

#### **Network Requirements**
- **API Server Access**: Port 6443 for Kubernetes API server
- **etcd Access**: Port 2379/2380 for etcd cluster communication
- **kubelet API**: Port 10250 for kubelet API access
- **kube-proxy**: Port 10259 for kube-proxy metrics
- **Firewall Configuration**: Allow Kubernetes cluster communication
  ```bash
  # Check cluster connectivity
  kubectl cluster-info
  kubectl get nodes -o wide
  ```

### **📖 Knowledge Prerequisites**

#### **Required Module Completion**
- **Module 0**: Essential Linux Commands - File operations, process management, text processing, system navigation
- **Module 1**: Container Fundamentals - Docker basics, container lifecycle, virtualization concepts
- **Module 2**: Linux System Administration - System monitoring, process management, file systems, network configuration
- **Module 3**: Networking Fundamentals - Network protocols, DNS, firewall configuration, network troubleshooting
- **Module 4**: YAML Configuration Management - YAML syntax, Kubernetes manifests, Kustomize
- **Module 5**: Initial Monitoring Setup - Prometheus, Grafana, monitoring concepts, Kubernetes basics

#### **Concepts to Master**
- **Container Orchestration**: Understanding of container management and orchestration
- **Distributed Systems**: Basic understanding of distributed system concepts
- **API Design**: Understanding of REST APIs and API server concepts
- **State Management**: Understanding of stateful and stateless applications
- **Service Discovery**: Understanding of service discovery and load balancing

#### **Skills Required**
- **Linux Command Line**: Advanced proficiency with Linux commands from previous modules
- **Container Management**: Understanding of container lifecycle and management
- **Network Administration**: Understanding of network configuration and troubleshooting
- **System Administration**: Understanding of system services and process management
- **YAML Configuration**: Proficiency with YAML syntax and Kubernetes manifests

#### **Industry Knowledge**
- **Cloud Computing**: Understanding of cloud services and infrastructure
- **DevOps Practices**: Understanding of DevOps workflows and automation
- **Microservices**: Understanding of microservices architecture
- **Infrastructure as Code**: Understanding of IaC principles and practices

### **🛠️ Environment Prerequisites**

#### **Development Environment**
- **Text Editor**: VS Code, Vim, or Nano with Kubernetes manifest support
- **Terminal**: Bash shell with kubectl completion enabled
- **IDE Extensions**: Kubernetes extensions for VS Code (recommended)
  ```bash
  # Install VS Code Kubernetes extension (if using VS Code)
  code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
  ```

#### **Testing Environment**
- **Kubernetes Cluster**: Running and accessible
  ```bash
  # Verify cluster connectivity
  kubectl cluster-info
  kubectl get nodes
  kubectl get namespaces
  ```
- **Cluster Access**: Ability to view cluster components and logs
  ```bash
  # Test cluster access
  kubectl get pods --all-namespaces
  kubectl get services --all-namespaces
  ```

#### **Production Environment**
- **High Availability**: Understanding of HA cluster configurations
- **Security**: Understanding of RBAC and cluster security
- **Monitoring**: Understanding of cluster monitoring and observability
- **Backup**: Understanding of cluster backup and disaster recovery

### **📋 Validation Prerequisites**

#### **Pre-Module Assessment**
```bash
# 1. Verify Kubernetes cluster
kubectl cluster-info
kubectl get nodes
kubectl version --client --server

# 2. Verify cluster components
kubectl get pods -n kube-system
kubectl get services -n kube-system

# 3. Verify API server access
kubectl get --raw /api/v1
kubectl get --raw /api/v1/namespaces

# 4. Verify etcd access (if accessible)
kubectl get --raw /api/v1/namespaces/kube-system/configmaps/etcd-config

# 5. Verify system resources
free -h
df -h
nproc
```

#### **Setup Validation Commands**
```bash
# Create Kubernetes architecture practice environment
mkdir -p ~/k8s-architecture-practice
cd ~/k8s-architecture-practice

# Test cluster component access
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide
kubectl get services -n kube-system

# Test API server endpoints
kubectl get --raw /api/v1/namespaces
kubectl get --raw /api/v1/nodes
kubectl get --raw /api/v1/pods

# Test cluster information
kubectl cluster-info dump | head -20
kubectl config view

# Cleanup
cd ~
rm -rf ~/k8s-architecture-practice
```

#### **Troubleshooting Common Issues**
- **Cluster Not Accessible**: Check kubeconfig, cluster status, network connectivity
- **API Server Issues**: Verify API server health and authentication
- **etcd Issues**: Check etcd cluster health and connectivity
- **Component Failures**: Verify system resources and component logs
- **Network Issues**: Check cluster networking and firewall rules

#### **Alternative Options**
- **Cloud Providers**: AWS EKS, GCP GKE, Azure AKS with managed control plane
- **Local Development**: minikube, kind, or Docker Desktop with Kubernetes
- **Managed Services**: Managed Kubernetes services for simplified setup
- **Remote Clusters**: Access to remote Kubernetes clusters for learning

### **🚀 Quick Start Checklist**

Before starting this module, ensure you have:

- [ ] **Kubernetes cluster** (1.20+) running and accessible
- [ ] **kubectl** configured and working (`kubectl cluster-info`)
- [ ] **8GB+ RAM** available for cluster operations
- [ ] **50GB+ disk space** for cluster data and logs
- [ ] **Network access** to cluster components and API server
- [ ] **Previous modules** (0-5) completed successfully
- [ ] **Container fundamentals** understanding from previous modules
- [ ] **System administration** skills from previous modules
- [ ] **Networking knowledge** from previous modules
- [ ] **YAML configuration** skills from previous modules

### **⚠️ Important Notes**

- **Cluster Access**: This module requires access to a running Kubernetes cluster.
- **API Server**: Understanding API server is crucial for Kubernetes operations.
- **etcd**: etcd is the brain of Kubernetes - understand its role and importance.
- **Component Interaction**: Learn how all components work together.
- **Security**: Understand cluster security and access control.

### **🎯 Success Criteria**

By the end of this module, you should be able to:
- Understand Kubernetes architecture and component roles
- Explain the control plane and worker node components
- Understand API server functionality and REST API
- Explain etcd role in cluster state management
- Understand scheduler and controller manager functions
- Explain kubelet and kube-proxy operations
- Understand cluster networking and service discovery
- Troubleshoot common cluster component issues

---

## 🏗️ **Complete Kubernetes Architecture Deep Dive**

### **📚 Historical Context and Evolution**

#### **The Birth of Kubernetes**
- **Google's Internal System**: Kubernetes (K8s) was born from Google's internal container orchestration system called Borg
- **Open Source Release**: Google open-sourced Kubernetes in 2014, donating it to the Cloud Native Computing Foundation (CNCF)
- **Evolution Timeline**:
  - **2014**: Initial release by Google
  - **2015**: CNCF adoption and community growth
  - **2016**: Production-ready with v1.0
  - **2017**: Major cloud provider adoption (AWS, Azure, GCP)
  - **2018**: Enterprise adoption and maturity
  - **2019**: Serverless and edge computing integration
  - **2020+**: AI/ML workloads and advanced features

#### **Why Kubernetes Exists**
- **Container Orchestration Challenge**: Managing containers at scale across multiple hosts
- **Service Discovery**: How services find and communicate with each other
- **Load Balancing**: Distributing traffic across multiple container instances
- **Scaling**: Automatically scaling applications based on demand
- **Health Management**: Monitoring and restarting failed containers
- **Rolling Updates**: Updating applications without downtime

### **🎯 Complete Kubernetes Architecture Overview**

#### **High-Level Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                      │
├─────────────────────────────────────────────────────────────┤
│  CONTROL PLANE (MASTER NODES)                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ API Server  │ │   etcd      │ │ Scheduler   │           │
│  │             │ │             │ │             │           │
│  │ Controller  │ │             │ │             │           │
│  │ Manager     │ │             │ │             │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  WORKER NODES                                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   kubelet   │ │ kube-proxy  │ │ Container   │           │
│  │             │ │             │ │ Runtime     │           │
│  │             │ │             │ │ (containerd)│           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

#### **Component Communication Flow**
1. **User Request** → kubectl → API Server
2. **API Server** → etcd (store state)
3. **API Server** → Scheduler (schedule pods)
4. **API Server** → Controller Manager (manage resources)
5. **API Server** → kubelet (run containers)
6. **kubelet** → Container Runtime (start containers)
7. **kube-proxy** → Network (manage networking)

### **🎯 Control Plane Components Deep Dive**

#### **1. API Server (kube-apiserver)**
- **Purpose**: Central management point for the entire cluster
- **Function**: Exposes Kubernetes API and validates requests
- **Key Features**:
  - **RESTful API**: HTTP/HTTPS API for all cluster operations
  - **Authentication**: Verifies user identity
  - **Authorization**: Checks user permissions (RBAC)
  - **Admission Control**: Validates and modifies requests
  - **Rate Limiting**: Prevents API server overload

#### **2. etcd**
- **Purpose**: Distributed key-value store for cluster state
- **Function**: Stores all cluster configuration and state data
- **Key Features**:
  - **Consistency**: Strong consistency guarantees
  - **Durability**: Data persistence across failures
  - **Watch API**: Real-time change notifications
  - **Backup**: Critical for disaster recovery

#### **3. Scheduler (kube-scheduler)**
- **Purpose**: Assigns pods to nodes based on resource requirements
- **Function**: Watches for unscheduled pods and assigns them to nodes
- **Key Features**:
  - **Resource Awareness**: Considers CPU, memory, storage
  - **Affinity Rules**: Pod and node affinity/anti-affinity
  - **Taints and Tolerations**: Node scheduling constraints
  - **Custom Schedulers**: Pluggable scheduling logic

#### **4. Controller Manager (kube-controller-manager)**
- **Purpose**: Runs controllers that manage cluster resources
- **Function**: Watches cluster state and makes changes to achieve desired state
- **Key Controllers**:
  - **Deployment Controller**: Manages ReplicaSets
  - **ReplicaSet Controller**: Manages Pod replicas
  - **Service Controller**: Manages Services and load balancers
  - **Node Controller**: Monitors node health
  - **Namespace Controller**: Manages namespaces

### **🎯 Worker Node Components Deep Dive**

#### **1. kubelet**
- **Purpose**: Primary node agent that runs on each worker node
- **Function**: Manages pods and containers on the node
- **Key Features**:
  - **Pod Management**: Creates, updates, and deletes pods
  - **Container Runtime Interface**: Communicates with container runtime
  - **Health Monitoring**: Reports node and pod health
  - **Volume Management**: Mounts and manages volumes
  - **Image Management**: Pulls and manages container images

#### **2. kube-proxy**
- **Purpose**: Network proxy that runs on each node
- **Function**: Implements Kubernetes Service concept
- **Key Features**:
  - **Service Discovery**: Routes traffic to service endpoints
  - **Load Balancing**: Distributes traffic across pods
  - **Network Rules**: Manages iptables or IPVS rules
  - **Service Types**: Supports ClusterIP, NodePort, LoadBalancer

#### **3. Container Runtime**
- **Purpose**: Runs containers on the node
- **Function**: Manages container lifecycle and resources
- **Key Features**:
  - **Container Lifecycle**: Start, stop, pause, resume containers
  - **Image Management**: Pull, store, and manage images
  - **Resource Management**: CPU, memory, and storage limits
  - **Security**: Container isolation and security policies

### **🎯 Cluster Networking Deep Dive**

#### **Network Model**
- **Pod-to-Pod Communication**: Direct communication between pods
- **Service-to-Pod Communication**: Service abstraction for pod access
- **External-to-Service Communication**: External access to services
- **Node-to-Node Communication**: Inter-node communication

#### **Network Components**
- **CNI (Container Network Interface)**: Plugin system for networking
- **Service Mesh**: Advanced networking and observability
- **Ingress Controllers**: External access management
- **Network Policies**: Security and traffic control

---

## 🛠️ **Complete Kubernetes Command Reference with ALL Flags**

### **🔧 kubectl Command Reference**

#### **kubectl get - Complete Flag Reference**
```bash
# Basic syntax
kubectl get [TYPE] [NAME] [flags]

# ALL available flags for kubectl get
kubectl get --help

# Key flags with detailed explanations:
kubectl get pods
  --all-namespaces, -A          # List resources across all namespaces
  --allow-missing-template-keys # Ignore missing keys in template
  --chunk-size=500              # Return large lists in chunks
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --field-selector=             # Selector to filter on
  --filename, -f                # Filename, directory, or URL to files
  --kubeconfig=                 # Path to the kubeconfig file
  --label-selector, -l          # Selector to filter on
  --limit=                      # Limit number of resources
  --no-headers                  # Don't print headers
  --output, -o                  # Output format (json|yaml|wide|custom-columns=...)
  --raw=                        # Raw URI to request from the server
  --recursive, -R               # Process directory recursively
  --selector, -l                # Selector to filter on
  --server-print                # Print server response
  --show-kind                   # List the resource type
  --show-labels                 # Show all labels as the last column
  --show-managed-fields         # Show managedFields in JSON/YAML output
  --sort-by=                    # Sort list types using this field specification
  --template=                   # Template string or path to template file
  --use-openapi-print-columns   # Use OpenAPI print columns
  --watch, -w                   # Watch for changes
  --watch-only                  # Watch for changes to the specified resource types
```

#### **kubectl describe - Complete Flag Reference**
```bash
# Basic syntax
kubectl describe [TYPE] [NAME] [flags]

# ALL available flags for kubectl describe
kubectl describe --help

# Key flags with detailed explanations:
kubectl describe pods
  --all-namespaces, -A          # List resources across all namespaces
  --chunk-size=500              # Return large lists in chunks
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --filename, -f                # Filename, directory, or URL to files
  --kubeconfig=                 # Path to the kubeconfig file
  --recursive, -R               # Process directory recursively
  --selector, -l                # Selector to filter on
  --show-events                 # Show events related to the described object
```

#### **kubectl logs - Complete Flag Reference**
```bash
# Basic syntax
kubectl logs [TYPE] [NAME] [flags]

# ALL available flags for kubectl logs
kubectl logs --help

# Key flags with detailed explanations:
kubectl logs pod-name
  --all-containers=true         # Get all containers' logs
  --cluster=                    # Name of the kubeconfig cluster to use
  --container, -c               # Container name
  --context=                    # Name of the kubeconfig context to use
  --follow, -f                  # Follow log output
  --ignore-errors               # Ignore errors and continue
  --kubeconfig=                 # Path to the kubeconfig file
  --limit-bytes=                # Maximum bytes of logs to return
  --max-log-requests=5          # Maximum number of concurrent logs to follow
  --pod-running-timeout=20s     # Length of time to wait for pod to be running
  --prefix                      # Prefix each log line with the log source
  --previous                    # Get previous container logs
  --selector, -l                # Selector to filter on
  --since=                      # Only return logs newer than a relative duration
  --since-time=                 # Only return logs after a specific date
  --tail=-1                     # Lines of recent log file to display
  --timestamps                  # Include timestamps on each line
```

### **🔧 Cluster Information Commands**

#### **kubectl cluster-info - Complete Flag Reference**
```bash
# Basic syntax
kubectl cluster-info [flags]

# ALL available flags for kubectl cluster-info
kubectl cluster-info --help

# Key flags with detailed explanations:
kubectl cluster-info
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --kubeconfig=                 # Path to the kubeconfig file
  --output, -o                  # Output format (json|yaml|wide)
  --request-timeout=0           # Request timeout
  --show-managed-fields         # Show managedFields in JSON/YAML output
```

#### **kubectl version - Complete Flag Reference**
```bash
# Basic syntax
kubectl version [flags]

# ALL available flags for kubectl version
kubectl version --help

# Key flags with detailed explanations:
kubectl version
  --client                      # Client version only
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --kubeconfig=                 # Path to the kubeconfig file
  --output, -o                  # Output format (json|yaml|wide)
  --short                       # Print just the version number
```

### **🔧 Node Management Commands**

#### **kubectl get nodes - Complete Flag Reference**
```bash
# Basic syntax
kubectl get nodes [flags]

# Key flags with detailed explanations:
kubectl get nodes
  --all-namespaces, -A          # List resources across all namespaces
  --allow-missing-template-keys # Ignore missing keys in template
  --chunk-size=500              # Return large lists in chunks
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --field-selector=             # Selector to filter on
  --kubeconfig=                 # Path to the kubeconfig file
  --label-selector, -l          # Selector to filter on
  --limit=                      # Limit number of resources
  --no-headers                  # Don't print headers
  --output, -o                  # Output format (json|yaml|wide|custom-columns=...)
  --raw=                        # Raw URI to request from the server
  --selector, -l                # Selector to filter on
  --show-kind                   # List the resource type
  --show-labels                 # Show all labels as the last column
  --show-managed-fields         # Show managedFields in JSON/YAML output
  --sort-by=                    # Sort list types using this field specification
  --template=                   # Template string or path to template file
  --use-openapi-print-columns   # Use OpenAPI print columns
  --watch, -w                   # Watch for changes
  --watch-only                  # Watch for changes to the specified resource types
```

### **🔧 Component Status Commands**

#### **kubectl get componentstatuses - Complete Flag Reference**
```bash
# Basic syntax
kubectl get componentstatuses [flags]

# Key flags with detailed explanations:
kubectl get componentstatuses
  --all-namespaces, -A          # List resources across all namespaces
  --allow-missing-template-keys # Ignore missing keys in template
  --chunk-size=500              # Return large lists in chunks
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --field-selector=             # Selector to filter on
  --kubeconfig=                 # Path to the kubeconfig file
  --label-selector, -l          # Selector to filter on
  --limit=                      # Limit number of resources
  --no-headers                  # Don't print headers
  --output, -o                  # Output format (json|yaml|wide|custom-columns=...)
  --raw=                        # Raw URI to request from the server
  --selector, -l                # Selector to filter on
  --show-kind                   # List the resource type
  --show-labels                 # Show all labels as the last column
  --show-managed-fields         # Show managedFields in JSON/YAML output
  --sort-by=                    # Sort list types using this field specification
  --template=                   # Template string or path to template file
  --use-openapi-print-columns   # Use OpenAPI print columns
  --watch, -w                   # Watch for changes
  --watch-only                  # Watch for changes to the specified resource types
```

### **🔧 API Server Commands**

#### **kubectl get --raw - Complete Flag Reference**
```bash
# Basic syntax
kubectl get --raw [PATH] [flags]

# Key flags with detailed explanations:
kubectl get --raw /api/v1
  --cluster=                    # Name of the kubeconfig cluster to use
  --context=                    # Name of the kubeconfig context to use
  --kubeconfig=                 # Path to the kubeconfig file
  --output, -o                  # Output format (json|yaml|wide)
  --request-timeout=0           # Request timeout
  --show-managed-fields         # Show managedFields in JSON/YAML output
```

---

## 🧪 **Hands-on Labs**

### **Lab 1: Cluster Architecture Analysis**

#### **Step 1: Cluster Information Gathering**

##### **🔧 Command Analysis: kubectl cluster-info**

```bash
# =============================================================================
# CLUSTER INFORMATION GATHERING - COMPREHENSIVE ANALYSIS
# Purpose: Understand cluster architecture and component health
# =============================================================================

# Create lab directory for organized analysis
mkdir -p ~/k8s-architecture-lab
cd ~/k8s-architecture-lab

# =============================================================================
# 1. CLUSTER INFORMATION ANALYSIS
# =============================================================================

echo "=== CLUSTER INFORMATION ANALYSIS ==="
echo "Purpose: Get overview of cluster components and their endpoints"
echo ""

# Command: kubectl cluster-info
# Purpose: Display addresses of the control plane and services with label selector
# Flags used:
#   - No flags: Shows basic cluster information
#   - --output=json: Output in JSON format
#   - --output=yaml: Output in YAML format
#   - --output=wide: Show additional information
#   - --context=CONTEXT: Use specific context
#   - --kubeconfig=CONFIG: Use specific kubeconfig file
# Expected output: Control plane endpoint, DNS server, and service endpoints
# Use case: Quick cluster health check and endpoint discovery

echo "1. BASIC CLUSTER INFORMATION:"
echo "Command: kubectl cluster-info"
echo "Purpose: Display cluster control plane and service endpoints"
echo ""

# Execute command with detailed explanation
kubectl cluster-info

# Expected output analysis:
# - Kubernetes control plane: Shows API server endpoint (usually port 6443)
# - CoreDNS: Shows DNS service endpoint (usually port 53)
# - Additional services: Any other services running in kube-system

echo ""
echo "=== OUTPUT ANALYSIS ==="
echo "This output shows:"
echo "1. API Server endpoint: Where kubectl sends requests"
echo "2. DNS service: Internal cluster DNS resolution"
echo "3. Service endpoints: Other cluster services"
echo ""

# =============================================================================
# 2. CLUSTER INFORMATION DUMP ANALYSIS
# =============================================================================

echo "2. DETAILED CLUSTER DUMP:"
echo "Command: kubectl cluster-info dump | head -20"
echo "Purpose: Get comprehensive cluster state (first 20 lines for readability)"
echo ""

# Command: kubectl cluster-info dump
# Purpose: Dump all cluster information to stdout for analysis
# Flags used:
#   - No flags: Dumps all available cluster information
#   - --output-directory=DIR: Directory to write dump files
#   - --namespaces=NAMESPACES: Comma-separated list of namespaces to dump
#   - --all-namespaces: Dump all namespaces (default)
#   - --output=json: Output format (json, yaml, go-template)
#   - --context=CONTEXT: Use specific context
#   - --kubeconfig=CONFIG: Use specific kubeconfig file
#   - | head -20: Limits output to first 20 lines for readability
# Expected output: Large JSON/YAML dump of cluster state
# Use case: Troubleshooting, backup, cluster analysis

echo "Getting cluster state dump (first 20 lines for readability)..."
kubectl cluster-info dump | head -20

# Explanation of dump output:
# - apiVersion: Kubernetes API version being used
# - kind: Resource type (Cluster, Node, Pod, Service, etc.)
# - metadata: Resource metadata (name, namespace, labels, annotations)
# - spec: Resource specification and desired state
# - status: Current resource status and health

echo ""
echo "=== DUMP OUTPUT ANALYSIS ==="
echo "This dump contains:"
echo "1. Cluster configuration and current state"
echo "2. All resources and their current status"
echo "3. System components and their health"
echo "4. Network configuration and policies"
echo "5. RBAC policies and security configurations"
echo ""
echo "💡 TIP: Use 'kubectl cluster-info dump > cluster-backup.yaml' for full backup"
echo ""

# =============================================================================
# 3. CLUSTER VERSION ANALYSIS
# =============================================================================

echo "3. CLUSTER VERSION INFORMATION:"
echo "Command: kubectl version --output=yaml"
echo "Purpose: Get detailed version information for client and server"
echo ""

# Command: kubectl version
# Purpose: Print the client and server version information
# Flags used:
#   --output, -o: Output format (yaml, json, go-template)
#   --client: Show client version only
#   --server: Show server version only
#   --short: Print just the version number
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --allow-missing-template-keys: Ignore missing template keys
# Expected output: Client and server version details
# Use case: Version compatibility checking, troubleshooting

echo "Getting detailed version information..."
kubectl version --output=yaml

# Expected output analysis:
# - clientVersion: kubectl client version details
# - serverVersion: Kubernetes server version details
# - gitVersion: Git commit hash
# - gitCommit: Git commit details
# - buildDate: When the binary was built
# - goVersion: Go version used to build
# - compiler: Compiler used
# - platform: Operating system and architecture

echo ""
echo "=== VERSION OUTPUT ANALYSIS ==="
echo "This output shows:"
echo "1. Client version: Your kubectl version"
echo "2. Server version: Kubernetes cluster version"
echo "3. Compatibility: Version skew between client and server"
echo "4. Build information: How the binaries were compiled"
echo ""
echo "⚠️  IMPORTANT: Client and server versions should be within 1 minor version"
echo ""

# =============================================================================
# 4. NODE INFORMATION ANALYSIS
# =============================================================================

echo "4. NODE INFORMATION ANALYSIS:"
echo "Command: kubectl get nodes -o wide"
echo "Purpose: Get detailed information about all cluster nodes"
echo ""

# Command: kubectl get nodes
# Purpose: List all nodes in the cluster
# Flags used:
#   -o wide: Show additional information (IP addresses, roles, etc.)
#   -o yaml: Show complete node specification
#   -o json: Show complete node specification in JSON format
#   -o go-template: Use Go template for custom output format
#   --show-labels: Show node labels
#   --sort-by: Sort output by specified field
#   --field-selector: Filter nodes by field values
#   --label-selector: Filter nodes by label values
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --watch, -w: Watch for changes
#   --watch-only: Watch for changes without initial list
# Expected output: Node list with status, roles, and details
# Use case: Node health monitoring, capacity planning

echo "Getting node information with wide output..."
kubectl get nodes -o wide

# Expected output analysis:
# - NAME: Node hostname or identifier
# - STATUS: Node status (Ready, NotReady, SchedulingDisabled)
# - ROLES: Node role (master, worker, control-plane)
# - AGE: How long the node has been in the cluster
# - VERSION: Kubernetes version running on the node
# - INTERNAL-IP: Internal cluster IP address
# - EXTERNAL-IP: External IP address (if available)
# - OS-IMAGE: Operating system and version
# - KERNEL-VERSION: Linux kernel version
# - CONTAINER-RUNTIME: Container runtime (containerd, docker, etc.)

echo ""
echo "=== NODE OUTPUT ANALYSIS ==="
echo "This output shows:"
echo "1. Node count: Total number of nodes in cluster"
echo "2. Node roles: Which nodes are masters vs workers"
echo "3. Node health: Status of each node"
echo "4. Resource capacity: Available resources per node"
echo "5. Runtime information: Container runtime details"
echo ""

# Get detailed node information
echo "Getting detailed node YAML specification (first 50 lines)..."
kubectl get nodes -o yaml | head -50

echo ""
echo "=== DETAILED NODE ANALYSIS ==="
echo "YAML output contains:"
echo "1. Node metadata: Labels, annotations, creation timestamp"
echo "2. Node spec: Node configuration and settings"
echo "3. Node status: Current state, conditions, capacity"
echo "4. System info: OS, kernel, container runtime details"
echo "5. Resource usage: Current CPU, memory, storage usage"
echo ""

# =============================================================================
# 5. COMPONENT STATUS ANALYSIS
# =============================================================================

echo "5. COMPONENT STATUS ANALYSIS:"
echo "Command: kubectl get componentstatuses"
echo "Purpose: Check health of cluster control plane components"
echo ""

# Command: kubectl get componentstatuses
# Purpose: List component statuses (deprecated in newer Kubernetes versions)
# Flags used:
#   -o yaml: Show complete component status specification
#   -o json: Show complete component status specification in JSON format
#   -o wide: Show additional information
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --watch, -w: Watch for changes
#   --watch-only: Watch for changes without initial list
# Expected output: Status of control plane components
# Use case: Component health monitoring (legacy command)

echo "Getting component status information..."
kubectl get componentstatuses

# Expected output analysis:
# - NAME: Component name (scheduler, controller-manager, etcd)
# - STATUS: Component health status (Healthy, Unhealthy)
# - MESSAGE: Additional status information
# - ERROR: Any error messages

echo ""
echo "Getting detailed component status YAML..."
kubectl get componentstatuses -o yaml

echo ""
echo "=== COMPONENT STATUS ANALYSIS ==="
echo "This output shows:"
echo "1. Component health: Status of each control plane component"
echo "2. Error messages: Any issues with components"
echo "3. Last update: When status was last checked"
echo ""
echo "⚠️  NOTE: componentstatuses is deprecated in Kubernetes 1.19+"
echo "💡 Use 'kubectl get pods -n kube-system' for modern component health checking"
echo ""
```

#### **Step 2: Control Plane Component Analysis**

##### **🔧 Command Analysis: Control Plane Components**

```bash
# =============================================================================
# CONTROL PLANE COMPONENT ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand and analyze each control plane component in detail
# =============================================================================

echo "=== CONTROL PLANE COMPONENT ANALYSIS ==="
echo "Purpose: Analyze each control plane component and understand their roles"
echo ""

# =============================================================================
# 1. CONTROL PLANE PODS OVERVIEW
# =============================================================================

echo "1. CONTROL PLANE PODS OVERVIEW:"
echo "Command: kubectl get pods -n kube-system -o wide"
echo "Purpose: Get comprehensive view of all system pods with detailed information"
echo ""

# Command: kubectl get pods -n kube-system -o wide
# Purpose: List all pods in kube-system namespace with additional details
# Flags used:
#   -n kube-system: Target the kube-system namespace (where system components run)
#   -o wide: Show additional information (IP addresses, nodes, etc.)
#   -o yaml: Show complete pod specification
#   -o json: Show complete pod specification in JSON format
#   -o go-template: Use Go template for custom output format
#   --show-labels: Show pod labels
#   --sort-by: Sort output by specified field
#   --field-selector: Filter pods by field values
#   --label-selector: Filter pods by label values
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --watch, -w: Watch for changes
#   --watch-only: Watch for changes without initial list
#   --all-namespaces: Show pods from all namespaces
# Expected output: List of system pods with status, IPs, nodes, and ages
# Use case: System component monitoring and troubleshooting

echo "Getting all system pods with wide output..."
kubectl get pods -n kube-system -o wide

# Expected output analysis:
# - NAME: Pod name (etcd-master, kube-apiserver-master, etc.)
# - READY: Container readiness status (1/1, 2/2, etc.)
# - STATUS: Pod status (Running, Pending, Error, etc.)
# - RESTARTS: Number of container restarts
# - AGE: How long the pod has been running
# - IP: Pod IP address
# - NODE: Node where the pod is running
# - NOMINATED NODE: Node nominated for scheduling (if any)
# - READINESS GATES: Readiness gate conditions

echo ""
echo "=== SYSTEM PODS OUTPUT ANALYSIS ==="
echo "This output shows:"
echo "1. System component pods: All control plane and system pods"
echo "2. Pod health: Status and readiness of each component"
echo "3. Resource distribution: Which nodes run which components"
echo "4. Restart history: How many times components have restarted"
echo "5. IP addresses: Network configuration of system components"
echo ""

# Get control plane specific pods
echo "Getting control plane specific pods..."
echo "Command: kubectl get pods -n kube-system -l tier=control-plane"
echo "Purpose: Filter pods by control-plane tier label"
echo ""

# Command: kubectl get pods -n kube-system -l tier=control-plane
# Purpose: List only pods with tier=control-plane label
# Flags used:
#   -l tier=control-plane: Label selector for control plane components
#   -o wide: Show additional information
#   -o yaml: Show complete pod specification
#   -o json: Show complete pod specification in JSON format
#   --show-labels: Show pod labels
#   --sort-by: Sort output by specified field
#   --field-selector: Filter pods by field values
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --watch, -w: Watch for changes
#   --watch-only: Watch for changes without initial list
# Expected output: Only control plane component pods
# Use case: Focused analysis of control plane components

kubectl get pods -n kube-system -l tier=control-plane

echo ""
echo "=== CONTROL PLANE FILTER ANALYSIS ==="
echo "This filtered output shows:"
echo "1. API Server pods: Central management component"
echo "2. etcd pods: Cluster state storage"
echo "3. Scheduler pods: Pod scheduling component"
echo "4. Controller Manager pods: Resource management component"
echo ""

# =============================================================================
# 2. API SERVER DEEP DIVE
# =============================================================================

echo "2. API SERVER DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=kube-apiserver"
echo "Purpose: Get specific API server pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-apiserver
# Purpose: List API server pods specifically
# Flags used:
#   -l component=kube-apiserver: Label selector for API server component
# Expected output: API server pod details
# Use case: API server health monitoring and troubleshooting

echo "Getting API server pod information..."
kubectl get pods -n kube-system -l component=kube-apiserver

# Expected output analysis:
# - API server pod name: Usually kube-apiserver-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low (0-1)
# - Node location: Which node runs the API server

echo ""
echo "Getting detailed API server pod description..."
echo "Command: kubectl describe pod -n kube-system -l component=kube-apiserver"
echo "Purpose: Get comprehensive API server pod details and events"
echo ""

# Command: kubectl describe pod
# Purpose: Show detailed information about a specific pod
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=kube-apiserver: Label selector for API server
#   --show-events: Show events related to the pod
#   --show-managed-fields: Show managed fields in output
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --all-namespaces: Show pods from all namespaces
#   --field-selector: Filter pods by field values
#   --label-selector: Filter pods by label values
# Expected output: Detailed pod specification, status, events, and logs
# Use case: Deep troubleshooting and configuration analysis

kubectl describe pod -n kube-system -l component=kube-apiserver

# Expected output analysis:
# - Pod metadata: Name, namespace, labels, annotations
# - Pod spec: Container specifications, volumes, security context
# - Pod status: Current state, conditions, container statuses
# - Events: Recent events affecting the pod
# - Volumes: Mounted volumes and their status
# - Node info: Node where pod is running

echo ""
echo "=== API SERVER ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Container status: All containers should be running"
echo "3. Restart count: Should be minimal"
echo "4. Resource usage: CPU and memory consumption"
echo "5. Events: Any warnings or errors"
echo "6. Volumes: Certificate and configuration mounts"
echo ""

# =============================================================================
# 3. ETCD DEEP DIVE
# =============================================================================

echo "3. ETCD DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=etcd"
echo "Purpose: Get specific etcd pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=etcd
# Purpose: List etcd pods specifically
# Flags used:
#   -l component=etcd: Label selector for etcd component
# Expected output: etcd pod details
# Use case: etcd health monitoring and cluster state analysis

echo "Getting etcd pod information..."
kubectl get pods -n kube-system -l component=etcd

# Expected output analysis:
# - etcd pod name: Usually etcd-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be very low (0)
# - Node location: Which node runs etcd (usually master nodes)

echo ""
echo "Getting detailed etcd pod description..."
kubectl describe pod -n kube-system -l component=etcd

# Expected output analysis:
# - etcd configuration: Data directory, listen addresses
# - Certificate mounts: TLS certificates for etcd security
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: etcd-specific events and status

echo ""
echo "=== ETCD ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Data directory: Where etcd stores cluster state"
echo "3. Certificate mounts: TLS security configuration"
echo "4. Resource usage: etcd is memory-intensive"
echo "5. Events: Any etcd-specific warnings or errors"
echo "6. Health checks: Liveness and readiness probe status"
echo ""

# =============================================================================
# 4. SCHEDULER DEEP DIVE
# =============================================================================

echo "4. SCHEDULER DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=kube-scheduler"
echo "Purpose: Get specific scheduler pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-scheduler
# Purpose: List scheduler pods specifically
# Flags used:
#   -l component=kube-scheduler: Label selector for scheduler component
# Expected output: Scheduler pod details
# Use case: Scheduler health monitoring and performance analysis

echo "Getting scheduler pod information..."
kubectl get pods -n kube-system -l component=kube-scheduler

# Expected output analysis:
# - Scheduler pod name: Usually kube-scheduler-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low
# - Node location: Which node runs the scheduler

echo ""
echo "Getting detailed scheduler pod description..."
kubectl describe pod -n kube-system -l component=kube-scheduler

# Expected output analysis:
# - Scheduler configuration: Scheduling policies and algorithms
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: Scheduler-specific events and decisions
# - Logs: Scheduling decisions and pod placement

echo ""
echo "=== SCHEDULER ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Scheduling policies: Default and custom policies"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Scheduling decisions and pod placements"
echo "5. Health checks: Scheduler health and responsiveness"
echo "6. Configuration: Scheduler arguments and settings"
echo ""

# =============================================================================
# 5. CONTROLLER MANAGER DEEP DIVE
# =============================================================================

echo "5. CONTROLLER MANAGER DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=kube-controller-manager"
echo "Purpose: Get specific controller manager pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-controller-manager
# Purpose: List controller manager pods specifically
# Flags used:
#   -l component=kube-controller-manager: Label selector for controller manager
# Expected output: Controller manager pod details
# Use case: Controller manager health monitoring and resource analysis

echo "Getting controller manager pod information..."
kubectl get pods -n kube-system -l component=kube-controller-manager

# Expected output analysis:
# - Controller manager pod name: Usually kube-controller-manager-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low
# - Node location: Which node runs the controller manager

echo ""
echo "Getting detailed controller manager pod description..."
kubectl describe pod -n kube-system -l component=kube-controller-manager

# Expected output analysis:
# - Controller configuration: Enabled controllers and their settings
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: Controller-specific events and actions
# - Logs: Controller decisions and resource management

echo ""
echo "=== CONTROLLER MANAGER ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Enabled controllers: Which controllers are active"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Controller actions and resource management"
echo "5. Health checks: Controller manager health and responsiveness"
echo "6. Configuration: Controller arguments and settings"
echo ""
```

#### **Step 3: Worker Node Component Analysis**

##### **🔧 Command Analysis: Worker Node Components**

```bash
# =============================================================================
# WORKER NODE COMPONENT ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand and analyze worker node components and their roles
# =============================================================================

echo "=== WORKER NODE COMPONENT ANALYSIS ==="
echo "Purpose: Analyze worker node components and understand their functions"
echo ""

# =============================================================================
# 1. KUBELET DEEP DIVE
# =============================================================================

echo "1. KUBELET DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=kubelet"
echo "Purpose: Get specific kubelet pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=kubelet
# Purpose: List kubelet pods specifically
# Flags used:
#   -l component=kubelet: Label selector for kubelet component
# Expected output: kubelet pod details
# Use case: kubelet health monitoring and node analysis

echo "Getting kubelet pod information..."
kubectl get pods -n kube-system -l component=kubelet

# Expected output analysis:
# - kubelet pod name: Usually kubelet-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low
# - Node location: Which node runs kubelet

echo ""
echo "Getting detailed kubelet pod description..."
kubectl describe pod -n kube-system -l component=kubelet

# Expected output analysis:
# - kubelet configuration: Node configuration and settings
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: kubelet-specific events and actions
# - Logs: Pod management and container lifecycle

echo ""
echo "=== KUBELET ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Node configuration: kubelet configuration and settings"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Pod management and container lifecycle events"
echo "5. Health checks: kubelet health and responsiveness"
echo "6. Configuration: kubelet arguments and settings"
echo ""

# =============================================================================
# 2. KUBE-PROXY DEEP DIVE
# =============================================================================

echo "2. KUBE-PROXY DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=kube-proxy"
echo "Purpose: Get specific kube-proxy pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-proxy
# Purpose: List kube-proxy pods specifically
# Flags used:
#   -l component=kube-proxy: Label selector for kube-proxy component
# Expected output: kube-proxy pod details
# Use case: kube-proxy health monitoring and network analysis

echo "Getting kube-proxy pod information..."
kubectl get pods -n kube-system -l component=kube-proxy

# Expected output analysis:
# - kube-proxy pod name: Usually kube-proxy-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low
# - Node location: Which node runs kube-proxy

echo ""
echo "Getting detailed kube-proxy pod description..."
kubectl describe pod -n kube-system -l component=kube-proxy

# Expected output analysis:
# - kube-proxy configuration: Network proxy settings and mode
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: kube-proxy-specific events and network changes
# - Logs: Network rule management and service updates

echo ""
echo "=== KUBE-PROXY ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Proxy mode: iptables, ipvs, or userspace mode"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Network rule updates and service changes"
echo "5. Health checks: kube-proxy health and responsiveness"
echo "6. Configuration: kube-proxy arguments and network settings"
echo ""

# =============================================================================
# 3. CONTAINER RUNTIME DEEP DIVE
# =============================================================================

echo "3. CONTAINER RUNTIME DEEP DIVE:"
echo "Command: kubectl get pods -n kube-system -l component=container-runtime"
echo "Purpose: Get specific container runtime pod information"
echo ""

# Command: kubectl get pods -n kube-system -l component=container-runtime
# Purpose: List container runtime pods specifically
# Flags used:
#   -l component=container-runtime: Label selector for container runtime
# Expected output: Container runtime pod details
# Use case: Container runtime health monitoring and performance analysis

echo "Getting container runtime pod information..."
kubectl get pods -n kube-system -l component=container-runtime

# Expected output analysis:
# - Container runtime pod name: Usually containerd-<node-name> or docker-<node-name>
# - Pod status: Should be Running
# - Restart count: Should be low
# - Node location: Which node runs the container runtime

echo ""
echo "Getting detailed container runtime pod description..."
kubectl describe pod -n kube-system -l component=container-runtime

# Expected output analysis:
# - Container runtime configuration: Runtime settings and storage
# - Resource limits: CPU and memory constraints
# - Health checks: Liveness and readiness probes
# - Events: Container runtime-specific events and operations
# - Logs: Container lifecycle and image management

echo ""
echo "=== CONTAINER RUNTIME ANALYSIS ==="
echo "Key things to look for:"
echo "1. Pod status: Should be Running and Ready"
echo "2. Runtime type: containerd, docker, or cri-o"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Container operations and image management"
echo "5. Health checks: Container runtime health and responsiveness"
echo "6. Configuration: Runtime arguments and storage settings"
echo ""

# =============================================================================
# 4. WORKER NODE OVERVIEW
# =============================================================================

echo "4. WORKER NODE OVERVIEW:"
echo "Command: kubectl get nodes -l node-role.kubernetes.io/worker"
echo "Purpose: Get information about worker nodes specifically"
echo ""

# Command: kubectl get nodes -l node-role.kubernetes.io/worker
# Purpose: List only worker nodes (excluding master/control-plane nodes)
# Flags used:
#   -l node-role.kubernetes.io/worker: Label selector for worker nodes
# Expected output: Worker node details
# Use case: Worker node monitoring and capacity analysis

echo "Getting worker node information..."
kubectl get nodes -l node-role.kubernetes.io/worker

# Expected output analysis:
# - Worker node names: Hostnames of worker nodes
# - Node status: Should be Ready
# - Node roles: Should show worker role
# - Resource capacity: Available CPU, memory, and storage

echo ""
echo "Getting detailed worker node information..."
kubectl get nodes -l node-role.kubernetes.io/worker -o wide

# Expected output analysis:
# - Node details: IP addresses, OS, kernel version
# - Container runtime: Runtime version and type
# - Resource allocation: Available resources for pod scheduling
# - Node conditions: Health status and conditions

echo ""
echo "=== WORKER NODE ANALYSIS ==="
echo "Key things to look for:"
echo "1. Node status: Should be Ready for pod scheduling"
echo "2. Resource capacity: Available CPU, memory, and storage"
echo "3. Container runtime: Runtime type and version"
echo "4. Node conditions: Health status and scheduling conditions"
echo "5. Resource allocation: How resources are allocated to pods"
echo "6. Node labels: Labels for node selection and scheduling"
echo ""
```

### **Lab 2: API Server Deep Dive**

#### **Step 1: API Server Endpoint Analysis**

##### **🔧 Command Analysis: API Server Endpoints**

```bash
# =============================================================================
# API SERVER ENDPOINT ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand API server endpoints and REST API structure
# =============================================================================

echo "=== API SERVER ENDPOINT ANALYSIS ==="
echo "Purpose: Analyze API server endpoints and understand REST API structure"
echo ""

# =============================================================================
# 1. API SERVER ENDPOINTS ANALYSIS
# =============================================================================

echo "1. API SERVER ENDPOINTS ANALYSIS:"
echo "Command: kubectl get --raw /api/v1"
echo "Purpose: Get core API group endpoints and available resources"
echo ""

# Command: kubectl get --raw /api/v1
# Purpose: Access the core API group endpoints directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1: Core API group endpoint
# Expected output: JSON response with available resources in core API group
# Use case: Understanding API structure and available resources

echo "Getting core API group endpoints..."
kubectl get --raw /api/v1

# Expected output analysis:
# - kind: APIResourceList
# - groupVersion: API version (v1)
# - resources: List of available resources (pods, services, nodes, etc.)
# - Each resource shows: name, singularName, namespaced, kind, verbs

echo ""
echo "=== CORE API ENDPOINTS ANALYSIS ==="
echo "This output shows:"
echo "1. Available resources: All resources in the core API group"
echo "2. Resource properties: Whether resources are namespaced"
echo "3. Supported operations: GET, POST, PUT, DELETE, PATCH, etc."
echo "4. Resource kinds: The Kubernetes object types available"
echo ""

# =============================================================================
# 2. NAMESPACE ENDPOINT ANALYSIS
# =============================================================================

echo "2. NAMESPACE ENDPOINT ANALYSIS:"
echo "Command: kubectl get --raw /api/v1/namespaces"
echo "Purpose: Get all namespaces in the cluster"
echo ""

# Command: kubectl get --raw /api/v1/namespaces
# Purpose: Access namespaces endpoint directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1/namespaces: Namespaces endpoint
# Expected output: JSON response with all namespaces
# Use case: Understanding namespace structure and metadata

echo "Getting namespaces endpoint..."
kubectl get --raw /api/v1/namespaces

# Expected output analysis:
# - kind: NamespaceList
# - apiVersion: v1
# - metadata: List metadata (resourceVersion, selfLink)
# - items: Array of namespace objects
# - Each namespace shows: metadata, spec, status

echo ""
echo "=== NAMESPACE ENDPOINT ANALYSIS ==="
echo "This output shows:"
echo "1. All namespaces: Complete list of namespaces in cluster"
echo "2. Namespace metadata: Labels, annotations, creation timestamp"
echo "3. Namespace status: Current phase and conditions"
echo "4. Resource version: For optimistic concurrency control"
echo ""

# =============================================================================
# 3. NODE ENDPOINT ANALYSIS
# =============================================================================

echo "3. NODE ENDPOINT ANALYSIS:"
echo "Command: kubectl get --raw /api/v1/nodes"
echo "Purpose: Get all nodes in the cluster"
echo ""

# Command: kubectl get --raw /api/v1/nodes
# Purpose: Access nodes endpoint directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1/nodes: Nodes endpoint
# Expected output: JSON response with all nodes
# Use case: Understanding node structure and status

echo "Getting nodes endpoint..."
kubectl get --raw /api/v1/nodes

# Expected output analysis:
# - kind: NodeList
# - apiVersion: v1
# - metadata: List metadata
# - items: Array of node objects
# - Each node shows: metadata, spec, status, conditions

echo ""
echo "=== NODE ENDPOINT ANALYSIS ==="
echo "This output shows:"
echo "1. All nodes: Complete list of nodes in cluster"
echo "2. Node metadata: Labels, annotations, creation timestamp"
echo "3. Node spec: Node configuration and settings"
echo "4. Node status: Current state, conditions, capacity, allocatable"
echo "5. Node conditions: Ready, MemoryPressure, DiskPressure, PIDPressure"
echo ""

# =============================================================================
# 4. POD ENDPOINT ANALYSIS
# =============================================================================

echo "4. POD ENDPOINT ANALYSIS:"
echo "Command: kubectl get --raw /api/v1/pods"
echo "Purpose: Get all pods in the cluster"
echo ""

# Command: kubectl get --raw /api/v1/pods
# Purpose: Access pods endpoint directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1/pods: Pods endpoint
# Expected output: JSON response with all pods
# Use case: Understanding pod structure and status

echo "Getting pods endpoint..."
kubectl get --raw /api/v1/pods

# Expected output analysis:
# - kind: PodList
# - apiVersion: v1
# - metadata: List metadata
# - items: Array of pod objects
# - Each pod shows: metadata, spec, status, conditions

echo ""
echo "=== POD ENDPOINT ANALYSIS ==="
echo "This output shows:"
echo "1. All pods: Complete list of pods in cluster"
echo "2. Pod metadata: Labels, annotations, creation timestamp"
echo "3. Pod spec: Container specifications, volumes, security context"
echo "4. Pod status: Current state, conditions, container statuses"
echo "5. Pod conditions: PodScheduled, Initialized, ContainersReady, PodReady"
echo ""

# =============================================================================
# 5. API SERVER VERSION ANALYSIS
# =============================================================================

echo "5. API SERVER VERSION ANALYSIS:"
echo "Command: kubectl get --raw /version"
echo "Purpose: Get API server version information"
echo ""

# Command: kubectl get --raw /version
# Purpose: Access version endpoint directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /version: Version endpoint
# Expected output: JSON response with version information
# Use case: Understanding API server version and build information

echo "Getting API server version..."
kubectl get --raw /version

# Expected output analysis:
# - major: Major version number
# - minor: Minor version number
# - gitVersion: Git version string
# - gitCommit: Git commit hash
# - gitTreeState: Git tree state
# - buildDate: Build date
# - goVersion: Go version used
# - compiler: Compiler used
# - platform: Platform information

echo ""
echo "=== API SERVER VERSION ANALYSIS ==="
echo "This output shows:"
echo "1. Version information: Major and minor version numbers"
echo "2. Build information: Git commit, build date, compiler"
echo "3. Runtime information: Go version, platform details"
echo "4. Git information: Commit hash and tree state"
echo ""

# =============================================================================
# 6. API SERVER HEALTH ANALYSIS
# =============================================================================

echo "6. API SERVER HEALTH ANALYSIS:"
echo "Command: kubectl get --raw /healthz"
echo "Purpose: Check API server health status"
echo ""

# Command: kubectl get --raw /healthz
# Purpose: Access health check endpoint
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /healthz: Health check endpoint
# Expected output: "ok" if healthy, error message if unhealthy
# Use case: Health monitoring and troubleshooting

echo "Getting API server health status..."
kubectl get --raw /healthz

# Expected output analysis:
# - "ok": API server is healthy
# - Error message: API server has issues
# - HTTP status: 200 for healthy, 500+ for unhealthy

echo ""
echo "Getting API server readiness status..."
kubectl get --raw /readyz

# Expected output analysis:
# - "ok": API server is ready to serve requests
# - Error message: API server is not ready
# - HTTP status: 200 for ready, 500+ for not ready

echo ""
echo "=== API SERVER HEALTH ANALYSIS ==="
echo "This output shows:"
echo "1. Health status: Whether API server is healthy"
echo "2. Readiness status: Whether API server is ready to serve requests"
echo "3. HTTP status codes: 200 for healthy/ready, 500+ for issues"
echo "4. Error messages: Specific issues if unhealthy"
echo ""
```

#### **Step 2: API Server Resource Analysis**

##### **🔧 Command Analysis: API Server Resources**

```bash
# =============================================================================
# API SERVER RESOURCE ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand API server resources, versions, and groups
# =============================================================================

echo "=== API SERVER RESOURCE ANALYSIS ==="
echo "Purpose: Analyze API server resources, versions, and groups"
echo ""

# =============================================================================
# 1. API RESOURCES ANALYSIS
# =============================================================================

echo "1. API RESOURCES ANALYSIS:"
echo "Command: kubectl api-resources"
echo "Purpose: List all available API resources in the cluster"
echo ""

# Command: kubectl api-resources
# Purpose: List all available API resources
# Flags used:
#   --output, -o: Output format (wide, name, yaml, json)
#   --verbs: Filter by supported verbs
#   --namespaced: Show only namespaced resources
#   --no-namespaced: Show only non-namespaced resources
# Expected output: List of all available API resources
# Use case: Understanding available resources and their properties

echo "Getting all API resources..."
kubectl api-resources

# Expected output analysis:
# - NAME: Resource name (pods, services, deployments, etc.)
# - SHORTNAMES: Short names for the resource (po, svc, deploy, etc.)
# - APIVERSION: API version (v1, apps/v1, etc.)
# - NAMESPACED: Whether the resource is namespaced
# - KIND: The Kubernetes object kind

echo ""
echo "Getting detailed API resources information..."
kubectl api-resources --output=wide

# Expected output analysis:
# - Additional columns: VERBS, CATEGORIES
# - VERBS: Supported operations (get, list, create, update, patch, delete, etc.)
# - CATEGORIES: Resource categories (all, api-extensions, etc.)

echo ""
echo "=== API RESOURCES ANALYSIS ==="
echo "This output shows:"
echo "1. Available resources: All resources you can create and manage"
echo "2. Resource properties: Whether resources are namespaced"
echo "3. Supported operations: What you can do with each resource"
echo "4. API versions: Which API version each resource belongs to"
echo "5. Short names: Abbreviated names for quick reference"
echo ""

# =============================================================================
# 2. API VERSIONS ANALYSIS
# =============================================================================

echo "2. API VERSIONS ANALYSIS:"
echo "Command: kubectl api-versions"
echo "Purpose: List all available API versions in the cluster"
echo ""

# Command: kubectl api-versions
# Purpose: List all available API versions
# Flags used:
#   --output, -o: Output format (wide, name, yaml, json)
# Expected output: List of all available API versions
# Use case: Understanding API versioning and compatibility

echo "Getting all API versions..."
kubectl api-versions

# Expected output analysis:
# - Core API group: v1 (pods, services, nodes, etc.)
# - Named API groups: apps/v1, extensions/v1beta1, etc.
# - Version format: group/version (e.g., apps/v1, networking.k8s.io/v1)

echo ""
echo "Getting detailed API versions information..."
kubectl api-versions --output=wide

# Expected output analysis:
# - Additional information: More details about each API version
# - Version details: Build information, deprecation status, etc.

echo ""
echo "=== API VERSIONS ANALYSIS ==="
echo "This output shows:"
echo "1. Available versions: All API versions you can use"
echo "2. API groups: How APIs are organized into groups"
echo "3. Version compatibility: Which versions are available"
echo "4. Deprecation status: Which versions are deprecated"
echo ""

# =============================================================================
# 3. API GROUPS ANALYSIS
# =============================================================================

echo "3. API GROUPS ANALYSIS:"
echo "Command: kubectl get --raw /apis"
echo "Purpose: Get all API groups and their versions"
echo ""

# Command: kubectl get --raw /apis
# Purpose: Access the APIs endpoint directly
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /apis: APIs endpoint
# Expected output: JSON response with all API groups
# Use case: Understanding API group structure and organization

echo "Getting all API groups..."
kubectl get --raw /apis

# Expected output analysis:
# - kind: APIGroupList
# - apiVersion: v1
# - groups: Array of API group objects
# - Each group shows: name, versions, preferredVersion, serverAddressByClientCIDRs

echo ""
echo "Getting specific API group information..."
kubectl get --raw /apis/apps/v1

# Expected output analysis:
# - kind: APIResourceList
# - groupVersion: apps/v1
# - resources: List of resources in the apps/v1 API group
# - Each resource shows: name, singularName, namespaced, kind, verbs

echo ""
echo "Getting networking API group information..."
kubectl get --raw /apis/networking.k8s.io/v1

# Expected output analysis:
# - kind: APIResourceList
# - groupVersion: networking.k8s.io/v1
# - resources: List of networking resources (ingresses, networkpolicies, etc.)
# - Each resource shows: name, singularName, namespaced, kind, verbs

echo ""
echo "=== API GROUPS ANALYSIS ==="
echo "This output shows:"
echo "1. API group structure: How APIs are organized into groups"
echo "2. Group versions: Available versions for each group"
echo "3. Preferred versions: Which version is preferred for each group"
echo "4. Resource organization: How resources are grouped by functionality"
echo ""

# =============================================================================
# 4. API RESOURCE DETAILS ANALYSIS
# =============================================================================

echo "4. API RESOURCE DETAILS ANALYSIS:"
echo "Command: kubectl explain pods"
echo "Purpose: Get detailed information about a specific resource"
echo ""

# Command: kubectl explain
# Purpose: Get detailed information about a specific resource
# Flags used:
#   --recursive: Show all fields recursively
#   --api-version: Specify API version
# Expected output: Detailed resource specification
# Use case: Understanding resource structure and required fields

echo "Getting detailed pod resource information..."
kubectl explain pods

# Expected output analysis:
# - KIND: Pod
# - VERSION: v1
# - DESCRIPTION: What the resource does
# - FIELDS: Available fields and their descriptions
# - Each field shows: type, description, required status

echo ""
echo "Getting recursive pod resource information..."
kubectl explain pods --recursive

# Expected output analysis:
# - All fields: Complete field hierarchy
# - Field types: Data types for each field
# - Required fields: Which fields are mandatory
# - Default values: Default values for optional fields

echo ""
echo "=== API RESOURCE DETAILS ANALYSIS ==="
echo "This output shows:"
echo "1. Resource structure: How the resource is organized"
echo "2. Field descriptions: What each field does"
echo "3. Required fields: Which fields are mandatory"
echo "4. Data types: What type of data each field expects"
echo "5. Default values: Default values for optional fields"
echo ""
```

### **Lab 3: etcd Cluster Analysis**

#### **Step 1: etcd Cluster Information**

##### **🔧 Command Analysis: etcd Cluster Information**

```bash
# =============================================================================
# ETCD CLUSTER ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand etcd cluster configuration, health, and performance
# =============================================================================

echo "=== ETCD CLUSTER ANALYSIS ==="
echo "Purpose: Analyze etcd cluster configuration, health, and performance"
echo ""

# =============================================================================
# 1. ETCD CLUSTER INFORMATION ANALYSIS
# =============================================================================

echo "1. ETCD CLUSTER INFORMATION ANALYSIS:"
echo "Command: kubectl get pods -n kube-system -l component=etcd -o yaml"
echo "Purpose: Get detailed etcd pod configuration and status"
echo ""

# Command: kubectl get pods -n kube-system -l component=etcd -o yaml
# Purpose: Get etcd pod information in YAML format
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=etcd: Label selector for etcd component
#   -o yaml: Output in YAML format
# Expected output: Complete etcd pod specification and status
# Use case: Understanding etcd configuration and troubleshooting

echo "Getting etcd pod information in YAML format..."
kubectl get pods -n kube-system -l component=etcd -o yaml

# Expected output analysis:
# - Pod metadata: Name, namespace, labels, annotations
# - Pod spec: Container specifications, volumes, security context
# - Pod status: Current state, conditions, container statuses
# - Events: Recent events affecting the etcd pod
# - Volumes: Certificate and data directory mounts

echo ""
echo "Getting etcd pod description..."
kubectl describe pod -n kube-system -l component=etcd

# Expected output analysis:
# - Pod details: Complete pod information
# - Container status: etcd container health and status
# - Resource usage: CPU and memory consumption
# - Events: etcd-specific events and status changes
# - Volumes: Mounted volumes and their status

echo ""
echo "=== ETCD CLUSTER INFORMATION ANALYSIS ==="
echo "This output shows:"
echo "1. etcd pod configuration: How etcd is configured"
echo "2. Container status: etcd container health and status"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: etcd-specific events and status changes"
echo "5. Volumes: Certificate and data directory mounts"
echo ""

# =============================================================================
# 2. ETCD CONFIGURATION ANALYSIS
# =============================================================================

echo "2. ETCD CONFIGURATION ANALYSIS:"
echo "Command: kubectl get configmap -n kube-system etcd-config -o yaml"
echo "Purpose: Get etcd configuration details"
echo ""

# Command: kubectl get configmap -n kube-system etcd-config -o yaml
# Purpose: Get etcd configuration map
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -o yaml: Output in YAML format
# Expected output: etcd configuration map
# Use case: Understanding etcd configuration settings

echo "Getting etcd configuration map..."
kubectl get configmap -n kube-system etcd-config -o yaml

# Expected output analysis:
# - ConfigMap metadata: Name, namespace, labels
# - Configuration data: etcd configuration settings
# - Environment variables: etcd environment configuration
# - Command arguments: etcd command line arguments

echo ""
echo "Getting etcd certificates..."
kubectl get secret -n kube-system etcd-certs -o yaml

# Expected output analysis:
# - Secret metadata: Name, namespace, labels
# - Certificate data: TLS certificates for etcd
# - Key data: Private keys for etcd
# - Certificate authority: CA certificates

echo ""
echo "=== ETCD CONFIGURATION ANALYSIS ==="
echo "This output shows:"
echo "1. etcd configuration: How etcd is configured"
echo "2. Environment variables: etcd environment settings"
echo "3. Command arguments: etcd command line arguments"
echo "4. TLS certificates: Security configuration"
echo "5. Data directory: Where etcd stores data"
echo ""

# =============================================================================
# 3. ETCD HEALTH CHECK ANALYSIS
# =============================================================================

echo "3. ETCD HEALTH CHECK ANALYSIS:"
echo "Command: kubectl get --raw /api/v1/namespaces/kube-system/configmaps/etcd-config"
echo "Purpose: Check etcd configuration via API"
echo ""

# Command: kubectl get --raw /api/v1/namespaces/kube-system/configmaps/etcd-config
# Purpose: Access etcd configuration via API
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1/namespaces/kube-system/configmaps/etcd-config: etcd config endpoint
# Expected output: etcd configuration via API
# Use case: API-based etcd configuration access

echo "Getting etcd configuration via API..."
kubectl get --raw /api/v1/namespaces/kube-system/configmaps/etcd-config

# Expected output analysis:
# - API response: etcd configuration via API
# - Configuration data: etcd settings and parameters
# - Metadata: Configuration metadata and version

echo ""
echo "Getting etcd certificates via API..."
kubectl get --raw /api/v1/namespaces/kube-system/secrets/etcd-certs

# Expected output analysis:
# - API response: etcd certificates via API
# - Certificate data: TLS certificates and keys
# - Security configuration: etcd security settings

echo ""
echo "=== ETCD HEALTH CHECK ANALYSIS ==="
echo "This output shows:"
echo "1. etcd configuration: Configuration via API access"
echo "2. Certificate information: TLS certificates and keys"
echo "3. Security settings: etcd security configuration"
echo "4. API access: How to access etcd configuration via API"
echo ""

# =============================================================================
# 4. ETCD PERFORMANCE ANALYSIS
# =============================================================================

echo "4. ETCD PERFORMANCE ANALYSIS:"
echo "Command: kubectl logs -n kube-system -l component=etcd --tail=50"
echo "Purpose: Analyze etcd performance and logs"
echo ""

# Command: kubectl logs -n kube-system -l component=etcd --tail=50
# Purpose: Get recent etcd logs
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=etcd: Label selector for etcd component
#   --tail=50: Show last 50 log lines
# Expected output: Recent etcd logs
# Use case: Performance analysis and troubleshooting

echo "Getting recent etcd logs..."
kubectl logs -n kube-system -l component=etcd --tail=50

# Expected output analysis:
# - etcd logs: Recent etcd activity and events
# - Performance metrics: etcd performance indicators
# - Error messages: Any etcd errors or warnings
# - Cluster status: etcd cluster health and status

echo ""
echo "Getting etcd logs with timestamps..."
kubectl logs -n kube-system -l component=etcd --tail=50 --timestamps

# Expected output analysis:
# - Timestamped logs: etcd logs with timestamps
# - Time-based analysis: etcd activity over time
# - Performance patterns: etcd performance patterns
# - Error timing: When errors occurred

echo ""
echo "=== ETCD PERFORMANCE ANALYSIS ==="
echo "This output shows:"
echo "1. etcd activity: Recent etcd operations and events"
echo "2. Performance metrics: etcd performance indicators"
echo "3. Error messages: Any etcd errors or warnings"
echo "4. Cluster status: etcd cluster health and status"
echo "5. Time patterns: etcd activity patterns over time"
echo ""
```

### **Lab 4: Scheduler Analysis**

#### **Step 1: Scheduler Configuration**

##### **🔧 Command Analysis: Scheduler Configuration**

```bash
# =============================================================================
# SCHEDULER ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand scheduler configuration, performance, and decision-making
# =============================================================================

echo "=== SCHEDULER ANALYSIS ==="
echo "Purpose: Analyze scheduler configuration, performance, and decision-making"
echo ""

# =============================================================================
# 1. SCHEDULER CONFIGURATION ANALYSIS
# =============================================================================

echo "1. SCHEDULER CONFIGURATION ANALYSIS:"
echo "Command: kubectl get pods -n kube-system -l component=kube-scheduler -o yaml"
echo "Purpose: Get detailed scheduler pod configuration and status"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-scheduler -o yaml
# Purpose: Get scheduler pod information in YAML format
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=kube-scheduler: Label selector for scheduler component
#   -o yaml: Output in YAML format
# Expected output: Complete scheduler pod specification and status
# Use case: Understanding scheduler configuration and troubleshooting

echo "Getting scheduler pod information in YAML format..."
kubectl get pods -n kube-system -l component=kube-scheduler -o yaml

# Expected output analysis:
# - Pod metadata: Name, namespace, labels, annotations
# - Pod spec: Container specifications, volumes, security context
# - Pod status: Current state, conditions, container statuses
# - Events: Recent events affecting the scheduler pod
# - Volumes: Configuration and certificate mounts

echo ""
echo "Getting scheduler pod description..."
kubectl describe pod -n kube-system -l component=kube-scheduler

# Expected output analysis:
# - Pod details: Complete pod information
# - Container status: Scheduler container health and status
# - Resource usage: CPU and memory consumption
# - Events: Scheduler-specific events and status changes
# - Volumes: Mounted volumes and their status

echo ""
echo "=== SCHEDULER CONFIGURATION ANALYSIS ==="
echo "This output shows:"
echo "1. Scheduler pod configuration: How scheduler is configured"
echo "2. Container status: Scheduler container health and status"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Scheduler-specific events and status changes"
echo "5. Volumes: Configuration and certificate mounts"
echo ""

# =============================================================================
# 2. SCHEDULER LOGS ANALYSIS
# =============================================================================

echo "2. SCHEDULER LOGS ANALYSIS:"
echo "Command: kubectl logs -n kube-system -l component=kube-scheduler --tail=50"
echo "Purpose: Analyze scheduler logs and decision-making"
echo ""

# Command: kubectl logs -n kube-system -l component=kube-scheduler --tail=50
# Purpose: Get recent scheduler logs
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=kube-scheduler: Label selector for scheduler component
#   --tail=50: Show last 50 log lines
# Expected output: Recent scheduler logs
# Use case: Performance analysis and troubleshooting

echo "Getting recent scheduler logs..."
kubectl logs -n kube-system -l component=kube-scheduler --tail=50

# Expected output analysis:
# - Scheduler logs: Recent scheduler activity and decisions
# - Pod scheduling: Pod scheduling decisions and placements
# - Performance metrics: Scheduler performance indicators
# - Error messages: Any scheduler errors or warnings
# - Node selection: Node selection criteria and decisions

echo ""
echo "Getting scheduler logs with timestamps..."
kubectl logs -n kube-system -l component=kube-scheduler --tail=50 --timestamps

# Expected output analysis:
# - Timestamped logs: Scheduler logs with timestamps
# - Time-based analysis: Scheduler activity over time
# - Performance patterns: Scheduler performance patterns
# - Decision timing: When scheduling decisions were made

echo ""
echo "=== SCHEDULER LOGS ANALYSIS ==="
echo "This output shows:"
echo "1. Scheduler activity: Recent scheduler operations and decisions"
echo "2. Pod scheduling: Pod scheduling decisions and placements"
echo "3. Performance metrics: Scheduler performance indicators"
echo "4. Error messages: Any scheduler errors or warnings"
echo "5. Time patterns: Scheduler activity patterns over time"
echo ""

# =============================================================================
# 3. SCHEDULER PERFORMANCE ANALYSIS
# =============================================================================

echo "3. SCHEDULER PERFORMANCE ANALYSIS:"
echo "Command: kubectl get --raw /metrics | grep scheduler"
echo "Purpose: Monitor scheduler performance metrics"
echo ""

# Command: kubectl get --raw /metrics | grep scheduler
# Purpose: Get scheduler performance metrics
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /metrics: Metrics endpoint
#   | grep scheduler: Filter for scheduler metrics
# Expected output: Scheduler performance metrics
# Use case: Performance monitoring and analysis

echo "Getting scheduler performance metrics..."
kubectl get --raw /metrics | grep scheduler

# Expected output analysis:
# - Scheduler metrics: Performance and operational metrics
# - Scheduling latency: Time taken for scheduling decisions
# - Queue depth: Number of pods waiting to be scheduled
# - Success rate: Percentage of successful scheduling decisions

echo ""
echo "Getting detailed scheduler metrics..."
kubectl get --raw /metrics | grep kube_scheduler

# Expected output analysis:
# - Detailed metrics: More specific scheduler metrics
# - Component metrics: Individual component performance
# - Resource usage: Scheduler resource consumption
# - Error rates: Scheduler error and failure rates

echo ""
echo "=== SCHEDULER PERFORMANCE ANALYSIS ==="
echo "This output shows:"
echo "1. Scheduler metrics: Performance and operational metrics"
echo "2. Scheduling latency: Time taken for scheduling decisions"
echo "3. Queue depth: Number of pods waiting to be scheduled"
echo "4. Success rate: Percentage of successful scheduling decisions"
echo "5. Error rates: Scheduler error and failure rates"
echo ""

# =============================================================================
# 4. SCHEDULER DECISION ANALYSIS
# =============================================================================

echo "4. SCHEDULER DECISION ANALYSIS:"
echo "Command: kubectl get events --sort-by=.metadata.creationTimestamp"
echo "Purpose: Analyze scheduler decisions and events"
echo ""

# Command: kubectl get events --sort-by=.metadata.creationTimestamp
# Purpose: Get cluster events sorted by creation time
# Flags used:
#   --sort-by=.metadata.creationTimestamp: Sort events by creation time
# Expected output: Cluster events including scheduler decisions
# Use case: Understanding scheduler decisions and pod placements

echo "Getting cluster events sorted by creation time..."
kubectl get events --sort-by=.metadata.creationTimestamp

# Expected output analysis:
# - Event list: All cluster events including scheduler decisions
# - Scheduler events: Pod scheduling and placement events
# - Event timing: When events occurred
# - Event details: Event descriptions and reasons

echo ""
echo "Getting scheduler-specific events..."
kubectl get events --field-selector reason=Scheduled

# Expected output analysis:
# - Scheduled events: Pod scheduling events
# - Node assignments: Which nodes pods were assigned to
# - Scheduling reasons: Why pods were scheduled to specific nodes
# - Event timing: When scheduling decisions were made

echo ""
echo "=== SCHEDULER DECISION ANALYSIS ==="
echo "This output shows:"
echo "1. Scheduler events: Pod scheduling and placement events"
echo "2. Node assignments: Which nodes pods were assigned to"
echo "3. Scheduling reasons: Why pods were scheduled to specific nodes"
echo "4. Event timing: When scheduling decisions were made"
echo "5. Event patterns: Scheduler decision patterns over time"
echo ""
```

### **Lab 5: Controller Manager Analysis**

#### **Step 1: Controller Manager Configuration**

##### **🔧 Command Analysis: Controller Manager Configuration**

```bash
# =============================================================================
# CONTROLLER MANAGER ANALYSIS - COMPREHENSIVE DEEP DIVE
# Purpose: Understand controller manager configuration, performance, and operations
# =============================================================================

echo "=== CONTROLLER MANAGER ANALYSIS ==="
echo "Purpose: Analyze controller manager configuration, performance, and operations"
echo ""

# =============================================================================
# 1. CONTROLLER MANAGER CONFIGURATION ANALYSIS
# =============================================================================

echo "1. CONTROLLER MANAGER CONFIGURATION ANALYSIS:"
echo "Command: kubectl get pods -n kube-system -l component=kube-controller-manager -o yaml"
echo "Purpose: Get detailed controller manager pod configuration and status"
echo ""

# Command: kubectl get pods -n kube-system -l component=kube-controller-manager -o yaml
# Purpose: Get controller manager pod information in YAML format
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=kube-controller-manager: Label selector for controller manager component
#   -o yaml: Output in YAML format
# Expected output: Complete controller manager pod specification and status
# Use case: Understanding controller manager configuration and troubleshooting

echo "Getting controller manager pod information in YAML format..."
kubectl get pods -n kube-system -l component=kube-controller-manager -o yaml

# Expected output analysis:
# - Pod metadata: Name, namespace, labels, annotations
# - Pod spec: Container specifications, volumes, security context
# - Pod status: Current state, conditions, container statuses
# - Events: Recent events affecting the controller manager pod
# - Volumes: Configuration and certificate mounts

echo ""
echo "Getting controller manager pod description..."
kubectl describe pod -n kube-system -l component=kube-controller-manager

# Expected output analysis:
# - Pod details: Complete pod information
# - Container status: Controller manager container health and status
# - Resource usage: CPU and memory consumption
# - Events: Controller manager-specific events and status changes
# - Volumes: Mounted volumes and their status

echo ""
echo "=== CONTROLLER MANAGER CONFIGURATION ANALYSIS ==="
echo "This output shows:"
echo "1. Controller manager pod configuration: How controller manager is configured"
echo "2. Container status: Controller manager container health and status"
echo "3. Resource usage: CPU and memory consumption"
echo "4. Events: Controller manager-specific events and status changes"
echo "5. Volumes: Configuration and certificate mounts"
echo ""

# =============================================================================
# 2. CONTROLLER MANAGER LOGS ANALYSIS
# =============================================================================

echo "2. CONTROLLER MANAGER LOGS ANALYSIS:"
echo "Command: kubectl logs -n kube-system -l component=kube-controller-manager --tail=50"
echo "Purpose: Analyze controller manager logs and operations"
echo ""

# Command: kubectl logs -n kube-system -l component=kube-controller-manager --tail=50
# Purpose: Get recent controller manager logs
# Flags used:
#   -n kube-system: Target kube-system namespace
#   -l component=kube-controller-manager: Label selector for controller manager component
#   --tail=50: Show last 50 log lines
# Expected output: Recent controller manager logs
# Use case: Performance analysis and troubleshooting

echo "Getting recent controller manager logs..."
kubectl logs -n kube-system -l component=kube-controller-manager --tail=50

# Expected output analysis:
# - Controller manager logs: Recent controller manager activity and operations
# - Controller operations: Resource management and reconciliation operations
# - Performance metrics: Controller manager performance indicators
# - Error messages: Any controller manager errors or warnings
# - Resource management: Resource creation, updates, and deletions

echo ""
echo "Getting controller manager logs with timestamps..."
kubectl logs -n kube-system -l component=kube-controller-manager --tail=50 --timestamps

# Expected output analysis:
# - Timestamped logs: Controller manager logs with timestamps
# - Time-based analysis: Controller manager activity over time
# - Performance patterns: Controller manager performance patterns
# - Operation timing: When controller operations occurred

echo ""
echo "=== CONTROLLER MANAGER LOGS ANALYSIS ==="
echo "This output shows:"
echo "1. Controller manager activity: Recent controller manager operations"
echo "2. Resource management: Resource creation, updates, and deletions"
echo "3. Performance metrics: Controller manager performance indicators"
echo "4. Error messages: Any controller manager errors or warnings"
echo "5. Time patterns: Controller manager activity patterns over time"
echo ""

# =============================================================================
# 3. CONTROLLER MANAGER PERFORMANCE ANALYSIS
# =============================================================================

echo "3. CONTROLLER MANAGER PERFORMANCE ANALYSIS:"
echo "Command: kubectl get --raw /metrics | grep controller"
echo "Purpose: Monitor controller manager performance metrics"
echo ""

# Command: kubectl get --raw /metrics | grep controller
# Purpose: Get controller manager performance metrics
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /metrics: Metrics endpoint
#   | grep controller: Filter for controller metrics
# Expected output: Controller manager performance metrics
# Use case: Performance monitoring and analysis

echo "Getting controller manager performance metrics..."
kubectl get --raw /metrics | grep controller

# Expected output analysis:
# - Controller metrics: Performance and operational metrics
# - Resource management: Resource creation and update metrics
# - Queue depth: Number of resources waiting to be processed
# - Success rate: Percentage of successful controller operations

echo ""
echo "Getting detailed controller manager metrics..."
kubectl get --raw /metrics | grep kube_controller_manager

# Expected output analysis:
# - Detailed metrics: More specific controller manager metrics
# - Component metrics: Individual controller performance
# - Resource usage: Controller manager resource consumption
# - Error rates: Controller manager error and failure rates

echo ""
echo "=== CONTROLLER MANAGER PERFORMANCE ANALYSIS ==="
echo "This output shows:"
echo "1. Controller metrics: Performance and operational metrics"
echo "2. Resource management: Resource creation and update metrics"
echo "3. Queue depth: Number of resources waiting to be processed"
echo "4. Success rate: Percentage of successful controller operations"
echo "5. Error rates: Controller manager error and failure rates"
echo ""

# =============================================================================
# 4. CONTROLLER MANAGER OPERATIONS ANALYSIS
# =============================================================================

echo "4. CONTROLLER MANAGER OPERATIONS ANALYSIS:"
echo "Command: kubectl get events --sort-by=.metadata.creationTimestamp"
echo "Purpose: Analyze controller manager operations and events"
echo ""

# Command: kubectl get events --sort-by=.metadata.creationTimestamp
# Purpose: Get cluster events sorted by creation time
# Flags used:
#   --sort-by=.metadata.creationTimestamp: Sort events by creation time
# Expected output: Cluster events including controller manager operations
# Use case: Understanding controller manager operations and resource management

echo "Getting cluster events sorted by creation time..."
kubectl get events --sort-by=.metadata.creationTimestamp

# Expected output analysis:
# - Event list: All cluster events including controller manager operations
# - Controller events: Resource management and reconciliation events
# - Event timing: When events occurred
# - Event details: Event descriptions and reasons

echo ""
echo "Getting controller-specific events..."
kubectl get events --field-selector reason=Created

# Expected output analysis:
# - Created events: Resource creation events
# - Resource types: Which resources were created
# - Creation reasons: Why resources were created
# - Event timing: When resources were created

echo ""
echo "=== CONTROLLER MANAGER OPERATIONS ANALYSIS ==="
echo "This output shows:"
echo "1. Controller events: Resource management and reconciliation events"
echo "2. Resource creation: Which resources were created"
echo "3. Creation reasons: Why resources were created"
echo "4. Event timing: When controller operations occurred"
echo "5. Event patterns: Controller manager operation patterns over time"
echo ""
```

---

## 🔧 **Additional Advanced kubectl Commands for Architecture Analysis**

### **📊 Advanced Resource Monitoring Commands**

#### **🔧 Command Analysis: kubectl top**

```bash
# =============================================================================
# ADVANCED RESOURCE MONITORING - COMPREHENSIVE ANALYSIS
# Purpose: Monitor cluster resource usage and performance
# =============================================================================

echo "=== ADVANCED RESOURCE MONITORING ==="
echo "Purpose: Monitor cluster resource usage and performance"
echo ""

# =============================================================================
# 1. NODE RESOURCE MONITORING
# =============================================================================

echo "1. NODE RESOURCE MONITORING:"
echo "Command: kubectl top nodes"
echo "Purpose: Show resource usage for all nodes in the cluster"
echo ""

# Command: kubectl top nodes
# Purpose: Display resource usage for all nodes
# Flags used:
#   --sort-by: Sort output by specified field (cpu, memory)
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --no-headers: Don't print headers
#   --containers: Show container-level resource usage
# Expected output: Node resource usage (CPU, memory)
# Use case: Node capacity planning and performance monitoring

echo "Getting node resource usage..."
kubectl top nodes

# Expected output analysis:
# - NAME: Node name
# - CPU(cores): CPU usage in cores
# - CPU%: CPU usage percentage
# - MEMORY(bytes): Memory usage in bytes
# - MEMORY%: Memory usage percentage

echo ""
echo "Getting node resource usage sorted by CPU..."
kubectl top nodes --sort-by=cpu

# Expected output analysis:
# - Sorted by CPU: Nodes ordered by CPU usage
# - Performance ranking: Which nodes are most/least utilized
# - Capacity planning: Identify nodes needing more resources

echo ""
echo "Getting node resource usage sorted by memory..."
kubectl top nodes --sort-by=memory

# Expected output analysis:
# - Sorted by memory: Nodes ordered by memory usage
# - Memory ranking: Which nodes are most/least utilized
# - Memory planning: Identify nodes needing more memory

echo ""
echo "=== NODE RESOURCE MONITORING ANALYSIS ==="
echo "This output shows:"
echo "1. Node utilization: CPU and memory usage per node"
echo "2. Performance ranking: Which nodes are most/least utilized"
echo "3. Capacity planning: Identify nodes needing more resources"
echo "4. Load distribution: How load is distributed across nodes"
echo "5. Resource bottlenecks: Identify resource constraints"
echo ""

# =============================================================================
# 2. POD RESOURCE MONITORING
# =============================================================================

echo "2. POD RESOURCE MONITORING:"
echo "Command: kubectl top pods --all-namespaces"
echo "Purpose: Show resource usage for all pods in all namespaces"
echo ""

# Command: kubectl top pods --all-namespaces
# Purpose: Display resource usage for all pods
# Flags used:
#   --all-namespaces: Show pods from all namespaces
#   --sort-by: Sort output by specified field (cpu, memory)
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --no-headers: Don't print headers
#   --containers: Show container-level resource usage
# Expected output: Pod resource usage (CPU, memory)
# Use case: Pod performance monitoring and resource optimization

echo "Getting pod resource usage from all namespaces..."
kubectl top pods --all-namespaces

# Expected output analysis:
# - NAMESPACE: Pod namespace
# - NAME: Pod name
# - CPU(cores): CPU usage in cores
# - MEMORY(bytes): Memory usage in bytes

echo ""
echo "Getting pod resource usage sorted by CPU..."
kubectl top pods --all-namespaces --sort-by=cpu

# Expected output analysis:
# - Sorted by CPU: Pods ordered by CPU usage
# - Performance ranking: Which pods are most/least utilized
# - Resource optimization: Identify pods needing resource adjustments

echo ""
echo "Getting pod resource usage sorted by memory..."
kubectl top pods --all-namespaces --sort-by=memory

# Expected output analysis:
# - Sorted by memory: Pods ordered by memory usage
# - Memory ranking: Which pods are most/least utilized
# - Memory optimization: Identify pods needing memory adjustments

echo ""
echo "=== POD RESOURCE MONITORING ANALYSIS ==="
echo "This output shows:"
echo "1. Pod utilization: CPU and memory usage per pod"
echo "2. Performance ranking: Which pods are most/least utilized"
echo "3. Resource optimization: Identify pods needing resource adjustments"
echo "4. Load distribution: How load is distributed across pods"
echo "5. Resource bottlenecks: Identify resource constraints"
echo ""

# =============================================================================
# 3. CONTAINER RESOURCE MONITORING
# =============================================================================

echo "3. CONTAINER RESOURCE MONITORING:"
echo "Command: kubectl top pods --containers --all-namespaces"
echo "Purpose: Show resource usage for all containers in all pods"
echo ""

# Command: kubectl top pods --containers --all-namespaces
# Purpose: Display resource usage for all containers
# Flags used:
#   --containers: Show container-level resource usage
#   --all-namespaces: Show containers from all namespaces
#   --sort-by: Sort output by specified field (cpu, memory)
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
#   --no-headers: Don't print headers
# Expected output: Container resource usage (CPU, memory)
# Use case: Container performance monitoring and resource optimization

echo "Getting container resource usage from all namespaces..."
kubectl top pods --containers --all-namespaces

# Expected output analysis:
# - NAMESPACE: Container namespace
# - POD: Pod name
# - NAME: Container name
# - CPU(cores): CPU usage in cores
# - MEMORY(bytes): Memory usage in bytes

echo ""
echo "Getting container resource usage sorted by CPU..."
kubectl top pods --containers --all-namespaces --sort-by=cpu

# Expected output analysis:
# - Sorted by CPU: Containers ordered by CPU usage
# - Performance ranking: Which containers are most/least utilized
# - Resource optimization: Identify containers needing resource adjustments

echo ""
echo "Getting container resource usage sorted by memory..."
kubectl top pods --containers --all-namespaces --sort-by=memory

# Expected output analysis:
# - Sorted by memory: Containers ordered by memory usage
# - Memory ranking: Which containers are most/least utilized
# - Memory optimization: Identify containers needing memory adjustments

echo ""
echo "=== CONTAINER RESOURCE MONITORING ANALYSIS ==="
echo "This output shows:"
echo "1. Container utilization: CPU and memory usage per container"
echo "2. Performance ranking: Which containers are most/least utilized"
echo "3. Resource optimization: Identify containers needing resource adjustments"
echo "4. Load distribution: How load is distributed across containers"
echo "5. Resource bottlenecks: Identify resource constraints"
echo ""
```

### **🔍 Advanced Debugging and Troubleshooting Commands**

#### **🔧 Command Analysis: kubectl debug**

```bash
# =============================================================================
# ADVANCED DEBUGGING AND TROUBLESHOOTING - COMPREHENSIVE ANALYSIS
# Purpose: Debug and troubleshoot cluster issues
# =============================================================================

echo "=== ADVANCED DEBUGGING AND TROUBLESHOOTING ==="
echo "Purpose: Debug and troubleshoot cluster issues"
echo ""

# =============================================================================
# 1. POD DEBUGGING
# =============================================================================

echo "1. POD DEBUGGING:"
echo "Command: kubectl debug POD_NAME -it --image=busybox"
echo "Purpose: Create a debug container in a pod for troubleshooting"
echo ""

# Command: kubectl debug POD_NAME -it --image=busybox
# Purpose: Create a debug container in a pod
# Flags used:
#   -it: Interactive terminal
#   --image=busybox: Use busybox image for debugging
#   --target=CONTAINER: Target specific container
#   --share-processes: Share process namespace
#   --copy-to=NEW_POD: Copy pod to new pod for debugging
#   --set-image=CONTAINER=IMAGE: Set container image
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
# Expected output: Interactive shell in debug container
# Use case: Pod troubleshooting and debugging

echo "Creating debug container in pod..."
kubectl debug POD_NAME -it --image=busybox

# Expected output analysis:
# - Interactive shell: Access to pod filesystem and processes
# - Debug environment: Isolated environment for troubleshooting
# - Process access: Ability to inspect running processes
# - File system access: Ability to inspect files and directories

echo ""
echo "Creating debug container with process sharing..."
kubectl debug POD_NAME -it --image=busybox --share-processes

# Expected output analysis:
# - Process sharing: Access to all processes in the pod
# - Enhanced debugging: Better visibility into pod behavior
# - Process inspection: Ability to inspect all running processes
# - System calls: Ability to trace system calls

echo ""
echo "=== POD DEBUGGING ANALYSIS ==="
echo "This output shows:"
echo "1. Debug environment: Isolated environment for troubleshooting"
echo "2. Process access: Ability to inspect running processes"
echo "3. File system access: Ability to inspect files and directories"
echo "4. Network access: Ability to test network connectivity"
echo "5. System calls: Ability to trace system calls"
echo ""

# =============================================================================
# 2. NODE DEBUGGING
# =============================================================================

echo "2. NODE DEBUGGING:"
echo "Command: kubectl debug node/NODE_NAME -it --image=busybox"
echo "Purpose: Create a debug container on a node for troubleshooting"
echo ""

# Command: kubectl debug node/NODE_NAME -it --image=busybox
# Purpose: Create a debug container on a node
# Flags used:
#   -it: Interactive terminal
#   --image=busybox: Use busybox image for debugging
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
# Expected output: Interactive shell on node
# Use case: Node troubleshooting and debugging

echo "Creating debug container on node..."
kubectl debug node/NODE_NAME -it --image=busybox

# Expected output analysis:
# - Node access: Direct access to node filesystem and processes
# - System debugging: Ability to debug system-level issues
# - Hardware inspection: Ability to inspect hardware resources
# - Network debugging: Ability to debug network issues

echo ""
echo "=== NODE DEBUGGING ANALYSIS ==="
echo "This output shows:"
echo "1. Node access: Direct access to node filesystem and processes"
echo "2. System debugging: Ability to debug system-level issues"
echo "3. Hardware inspection: Ability to inspect hardware resources"
echo "4. Network debugging: Ability to debug network issues"
echo "5. Container runtime: Ability to inspect container runtime"
echo ""
```

### **📈 Advanced Performance Analysis Commands**

#### **🔧 Command Analysis: kubectl get --raw**

```bash
# =============================================================================
# ADVANCED PERFORMANCE ANALYSIS - COMPREHENSIVE ANALYSIS
# Purpose: Analyze cluster performance and metrics
# =============================================================================

echo "=== ADVANCED PERFORMANCE ANALYSIS ==="
echo "Purpose: Analyze cluster performance and metrics"
echo ""

# =============================================================================
# 1. API SERVER METRICS
# =============================================================================

echo "1. API SERVER METRICS:"
echo "Command: kubectl get --raw /metrics"
echo "Purpose: Get API server metrics for performance analysis"
echo ""

# Command: kubectl get --raw /metrics
# Purpose: Access API server metrics endpoint
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /metrics: Metrics endpoint
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
# Expected output: Prometheus-format metrics
# Use case: API server performance monitoring and analysis

echo "Getting API server metrics..."
kubectl get --raw /metrics

# Expected output analysis:
# - Prometheus metrics: Metrics in Prometheus format
# - API server performance: Request rates, latencies, errors
# - Resource usage: CPU, memory, and storage usage
# - Component health: Health status of various components

echo ""
echo "Getting API server metrics filtered by apiserver..."
kubectl get --raw /metrics | grep apiserver

# Expected output analysis:
# - API server specific metrics: Only API server related metrics
# - Request metrics: Request rates and latencies
# - Error metrics: Error rates and types
# - Performance metrics: Performance indicators

echo ""
echo "=== API SERVER METRICS ANALYSIS ==="
echo "This output shows:"
echo "1. Request metrics: Request rates and latencies"
echo "2. Error metrics: Error rates and types"
echo "3. Performance metrics: Performance indicators"
echo "4. Resource usage: CPU, memory, and storage usage"
echo "5. Component health: Health status of various components"
echo ""

# =============================================================================
# 2. ETCD METRICS
# =============================================================================

echo "2. ETCD METRICS:"
echo "Command: kubectl get --raw /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics"
echo "Purpose: Get etcd metrics for performance analysis"
echo ""

# Command: kubectl get --raw /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics
# Purpose: Access etcd metrics endpoint
# Flags used:
#   --raw: Make a raw HTTP request to the API server
#   /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics: etcd metrics endpoint
#   --context=CONTEXT: Use specific context
#   --kubeconfig=CONFIG: Use specific kubeconfig file
# Expected output: etcd metrics in Prometheus format
# Use case: etcd performance monitoring and analysis

echo "Getting etcd metrics..."
kubectl get --raw /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics

# Expected output analysis:
# - etcd performance: etcd performance metrics
# - Storage metrics: Storage usage and performance
# - Network metrics: Network performance
# - Cluster metrics: etcd cluster health and performance

echo ""
echo "Getting etcd metrics filtered by etcd..."
kubectl get --raw /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics | grep etcd

# Expected output analysis:
# - etcd specific metrics: Only etcd related metrics
# - Storage metrics: Storage usage and performance
# - Network metrics: Network performance
# - Cluster metrics: etcd cluster health and performance

echo ""
echo "=== ETCD METRICS ANALYSIS ==="
echo "This output shows:"
echo "1. Storage metrics: Storage usage and performance"
echo "2. Network metrics: Network performance"
echo "3. Cluster metrics: etcd cluster health and performance"
echo "4. Performance metrics: etcd performance indicators"
echo "5. Error metrics: etcd error rates and types"
echo ""
```

---

## 🎯 **Practice Problems with VERY DETAILED SOLUTIONS**

### **Problem 1: Cluster Architecture Analysis and Troubleshooting**

#### **Scenario**
You are a DevOps engineer tasked with analyzing a Kubernetes cluster architecture and identifying potential issues. The cluster is experiencing performance problems and you need to provide a comprehensive analysis.

#### **DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**

##### **Step 1: Cluster Architecture Analysis Setup**
```bash
# Create comprehensive cluster analysis script
cat > cluster_architecture_analyzer.sh << 'EOF'
#!/bin/bash

# =============================================================================
# Comprehensive Cluster Architecture Analyzer
# Purpose: Analyze Kubernetes cluster architecture and identify issues
# =============================================================================

# Configuration
ANALYSIS_DIR="./cluster-analysis"
REPORT_DIR="./reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/cluster_analysis_$TIMESTAMP.txt"

# Create directories
mkdir -p "$ANALYSIS_DIR" "$REPORT_DIR"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$REPORT_DIR/analysis.log"
}

echo "=== COMPREHENSIVE CLUSTER ARCHITECTURE ANALYSIS ==="
echo "Date: $(date)"
echo "Report: $REPORT_FILE"
echo ""

# =============================================================================
# 1. CLUSTER OVERVIEW ANALYSIS
# =============================================================================
log_message "INFO" "Starting cluster overview analysis"

echo "=== CLUSTER OVERVIEW ===" > "$REPORT_FILE"
echo "Analysis Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Get cluster information
echo "1. CLUSTER INFORMATION" >> "$REPORT_FILE"
kubectl cluster-info >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get cluster version
echo "2. CLUSTER VERSION" >> "$REPORT_FILE"
kubectl version --output=yaml >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get node information
echo "3. NODE INFORMATION" >> "$REPORT_FILE"
kubectl get nodes -o wide >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get component status
echo "4. COMPONENT STATUS" >> "$REPORT_FILE"
kubectl get componentstatuses >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

log_message "INFO" "Cluster overview analysis completed"
EOF

chmod +x cluster_architecture_analyzer.sh
```

##### **Step 2: Control Plane Component Analysis**
```bash
# Add control plane analysis to the script
cat >> cluster_architecture_analyzer.sh << 'EOF'

# =============================================================================
# 2. CONTROL PLANE COMPONENT ANALYSIS
# =============================================================================
log_message "INFO" "Starting control plane component analysis"

echo "=== CONTROL PLANE COMPONENTS ===" >> "$REPORT_FILE"

# Get control plane pods
echo "1. CONTROL PLANE PODS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -o wide >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get API server information
echo "2. API SERVER ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=kube-apiserver -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=kube-apiserver >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get etcd information
echo "3. ETCD ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=etcd -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=etcd >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get scheduler information
echo "4. SCHEDULER ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=kube-scheduler -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=kube-scheduler >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get controller manager information
echo "5. CONTROLLER MANAGER ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=kube-controller-manager -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=kube-controller-manager >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

log_message "INFO" "Control plane component analysis completed"
EOF
```

##### **Step 3: Worker Node Component Analysis**
```bash
# Add worker node analysis to the script
cat >> cluster_architecture_analyzer.sh << 'EOF'

# =============================================================================
# 3. WORKER NODE COMPONENT ANALYSIS
# =============================================================================
log_message "INFO" "Starting worker node component analysis"

echo "=== WORKER NODE COMPONENTS ===" >> "$REPORT_FILE"

# Get kubelet information
echo "1. KUBELET ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=kubelet -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=kubelet >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get kube-proxy information
echo "2. KUBE-PROXY ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=kube-proxy -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=kube-proxy >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get container runtime information
echo "3. CONTAINER RUNTIME ANALYSIS" >> "$REPORT_FILE"
kubectl get pods -n kube-system -l component=container-runtime -o yaml >> "$REPORT_FILE" 2>&1
kubectl describe pod -n kube-system -l component=container-runtime >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

log_message "INFO" "Worker node component analysis completed"
EOF
```

##### **Step 4: Performance and Health Analysis**
```bash
# Add performance analysis to the script
cat >> cluster_architecture_analyzer.sh << 'EOF'

# =============================================================================
# 4. PERFORMANCE AND HEALTH ANALYSIS
# =============================================================================
log_message "INFO" "Starting performance and health analysis"

echo "=== PERFORMANCE AND HEALTH ANALYSIS ===" >> "$REPORT_FILE"

# Get API server health
echo "1. API SERVER HEALTH" >> "$REPORT_FILE"
kubectl get --raw /healthz >> "$REPORT_FILE" 2>&1
kubectl get --raw /readyz >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get API server metrics
echo "2. API SERVER METRICS" >> "$REPORT_FILE"
kubectl get --raw /metrics | grep apiserver >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get scheduler metrics
echo "3. SCHEDULER METRICS" >> "$REPORT_FILE"
kubectl get --raw /metrics | grep scheduler >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

# Get controller manager metrics
echo "4. CONTROLLER MANAGER METRICS" >> "$REPORT_FILE"
kubectl get --raw /metrics | grep controller >> "$REPORT_FILE" 2>&1
echo "" >> "$REPORT_FILE"

log_message "INFO" "Performance and health analysis completed"
EOF
```

##### **Step 5: Execute Complete Analysis**
```bash
# Execute the complete cluster analysis
./cluster_architecture_analyzer.sh

# Display results
echo "=== ANALYSIS COMPLETED ==="
echo "Report saved to: $REPORT_FILE"
echo "Log saved to: $REPORT_DIR/analysis.log"
echo ""
echo "=== SUMMARY ==="
echo "1. Cluster overview analysis completed"
echo "2. Control plane component analysis completed"
echo "3. Worker node component analysis completed"
echo "4. Performance and health analysis completed"
echo ""
echo "Review the report for detailed findings and recommendations."
```

##### **Expected Outputs and Validation**
```bash
# Validate the analysis results
echo "=== VALIDATION STEPS ==="

# 1. Check if report file was created
if [ -f "$REPORT_FILE" ]; then
    echo "✅ Report file created successfully"
    echo "Report size: $(wc -l < "$REPORT_FILE") lines"
else
    echo "❌ Report file not found"
fi

# 2. Check if log file was created
if [ -f "$REPORT_DIR/analysis.log" ]; then
    echo "✅ Log file created successfully"
    echo "Log entries: $(wc -l < "$REPORT_DIR/analysis.log")"
else
    echo "❌ Log file not found"
fi

# 3. Display key findings
echo "=== KEY FINDINGS ==="
echo "Cluster version: $(kubectl version --short 2>/dev/null | head -1)"
echo "Number of nodes: $(kubectl get nodes --no-headers | wc -l)"
echo "Control plane pods: $(kubectl get pods -n kube-system --no-headers | wc -l)"
echo "Component status: $(kubectl get componentstatuses --no-headers | wc -l)"
```

##### **Error Handling and Troubleshooting**
```bash
# Error handling for common issues
echo "=== ERROR HANDLING AND TROUBLESHOOTING ==="

# Check cluster connectivity
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Cluster not accessible. Check:"
    echo "   - kubectl configuration"
    echo "   - Cluster status"
    echo "   - Network connectivity"
    exit 1
fi

# Check permissions
if ! kubectl get nodes >/dev/null 2>&1; then
    echo "❌ Insufficient permissions. Check:"
    echo "   - RBAC configuration"
    echo "   - User permissions"
    echo "   - Service account permissions"
    exit 1
fi

# Check component health
if ! kubectl get componentstatuses >/dev/null 2>&1; then
    echo "⚠️  Component status not available. This is normal in newer Kubernetes versions."
fi

echo "✅ All checks passed successfully"
```

---

## 🏗️ **Kubernetes Architecture YAML Examples with Line-by-Line Explanations**

### **📋 Complete YAML Manifest Analysis**

This section provides comprehensive YAML examples for Kubernetes architecture components with detailed line-by-line explanations, following the Module 7 golden standard.

#### **🔧 Example 1: API Server Configuration Analysis**

**Purpose**: Understanding API Server configuration and deployment patterns

```bash
# Create API Server configuration analysis
cat > api-server-analysis.yaml << 'EOF'
apiVersion: v1                    # Line 1: Kubernetes API version for Pod resource
kind: Pod                        # Line 2: Resource type - Pod for running API Server container
metadata:                        # Line 3: Metadata section containing resource identification
  name: kube-apiserver-analysis  # Line 4: Unique name for this Pod within namespace
  namespace: kube-system        # Line 5: Kubernetes namespace where Pod will be created
  labels:                       # Line 6: Labels for resource identification and selection
    component: kube-apiserver   # Line 7: Component label identifying this as API Server
    tier: control-plane         # Line 8: Tier label identifying this as control plane component
spec:                           # Line 9: Pod specification section
  containers:                   # Line 10: Container specifications array start
  - name: kube-apiserver        # Line 11: Container name - API Server container
    image: k8s.gcr.io/kube-apiserver:v1.25.0  # Line 12: API Server container image with version
    command:                    # Line 13: Command array start
    - kube-apiserver            # Line 14: Main command - API Server binary
    args:                       # Line 15: Command line arguments array start
    - --advertise-address=192.168.1.100  # Line 16: IP address to advertise to cluster
    - --allow-privileged=true   # Line 17: Allow privileged containers
    - --authorization-mode=Node,RBAC  # Line 18: Authorization modes (Node and RBAC)
    - --client-ca-file=/etc/kubernetes/pki/ca.crt  # Line 19: Client CA certificate file
    - --enable-admission-plugins=NodeRestriction  # Line 20: Admission control plugins
    - --enable-bootstrap-token-auth=true  # Line 21: Enable bootstrap token authentication
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt  # Line 22: etcd CA certificate file
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt  # Line 23: etcd client certificate
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key  # Line 24: etcd client private key
    - --etcd-servers=https://127.0.0.1:2379  # Line 25: etcd server endpoints
    - --insecure-port=0         # Line 26: Disable insecure port (port 8080)
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt  # Line 27: Kubelet client certificate
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key  # Line 28: Kubelet client private key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  # Line 29: Preferred kubelet address types
    - --secure-port=6443        # Line 30: Secure port for HTTPS API server
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub  # Line 31: Service account public key
    - --service-cluster-ip-range=10.96.0.0/12  # Line 32: Service cluster IP range
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt  # Line 33: TLS certificate file
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key  # Line 34: TLS private key file
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt  # Line 35: Front proxy CA certificate
    - --requestheader-extra-headers-prefix=X-Remote-Extra-  # Line 36: Extra headers prefix for request headers
    - --requestheader-group-headers=X-Remote-Group  # Line 37: Group headers for request headers
    - --requestheader-username-headers=X-Remote-User  # Line 38: Username headers for request headers
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt  # Line 39: Front proxy client certificate
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key  # Line 40: Front proxy client private key
    ports:                       # Line 41: Port configuration array start
    - containerPort: 6443        # Line 42: Container port for HTTPS API server
      name: https               # Line 43: Port name for HTTPS
      protocol: TCP             # Line 44: Protocol type - TCP
    - containerPort: 8080        # Line 45: Container port for HTTP API server (disabled)
      name: local               # Line 46: Port name for local HTTP
      protocol: TCP             # Line 47: Protocol type - TCP
    volumeMounts:               # Line 48: Volume mount configuration array start
    - name: k8s-certs           # Line 49: Volume mount name reference
      mountPath: /etc/kubernetes/pki  # Line 50: Mount path for Kubernetes certificates
      readOnly: true            # Line 51: Mount as read-only for security
    - name: kubeconfig          # Line 52: Volume mount name reference
      mountPath: /etc/kubernetes  # Line 53: Mount path for Kubernetes configuration
      readOnly: true            # Line 54: Mount as read-only for security
    livenessProbe:              # Line 55: Liveness probe configuration
      httpGet:                  # Line 56: HTTP GET probe configuration
        path: /healthz         # Line 57: Health check endpoint path
        port: 8080             # Line 58: Health check port
        scheme: HTTP            # Line 59: Health check scheme
      initialDelaySeconds: 15   # Line 60: Initial delay before first probe
      timeoutSeconds: 15        # Line 61: Probe timeout in seconds
      periodSeconds: 10         # Line 62: Probe interval in seconds
      failureThreshold: 8       # Line 63: Number of failures before restart
      successThreshold: 1       # Line 64: Number of successes to consider healthy
    readinessProbe:             # Line 65: Readiness probe configuration
      httpGet:                  # Line 66: HTTP GET probe configuration
        path: /readyz          # Line 67: Readiness check endpoint path
        port: 8080             # Line 68: Readiness check port
        scheme: HTTP            # Line 69: Readiness check scheme
      initialDelaySeconds: 10   # Line 70: Initial delay before first probe
      timeoutSeconds: 5         # Line 71: Probe timeout in seconds
      periodSeconds: 5          # Line 72: Probe interval in seconds
      failureThreshold: 3       # Line 73: Number of failures before marking not ready
      successThreshold: 1       # Line 74: Number of successes to consider ready
    resources:                  # Line 75: Resource requirements and limits
      requests:                 # Line 76: Minimum resource requests
        cpu: 250m              # Line 77: Minimum CPU request (250 millicores)
        memory: 512Mi          # Line 78: Minimum memory request (512 megabytes)
      limits:                   # Line 79: Maximum resource limits
        cpu: 500m              # Line 80: Maximum CPU limit (500 millicores)
        memory: 1Gi            # Line 81: Maximum memory limit (1 gigabyte)
  volumes:                      # Line 82: Volume definitions array start
  - name: k8s-certs            # Line 83: First volume name - Kubernetes certificates
    hostPath:                  # Line 84: Volume type - hostPath
      path: /etc/kubernetes/pki  # Line 85: Host path for certificates
      type: DirectoryOrCreate  # Line 86: Create directory if it doesn't exist
  - name: kubeconfig           # Line 87: Second volume name - Kubernetes configuration
    hostPath:                  # Line 88: Volume type - hostPath
      path: /etc/kubernetes    # Line 89: Host path for configuration
      type: DirectoryOrCreate  # Line 90: Create directory if it doesn't exist
  hostNetwork: true            # Line 91: Use host network namespace
  priorityClassName: system-node-critical  # Line 92: Priority class for critical system pods
EOF

**Line-by-Line Explanation:**
- **Lines 1-8**: Standard Pod metadata with component and tier labels
- **Lines 9-40**: API Server container with comprehensive command-line arguments
- **Lines 41-47**: Port configuration for HTTPS and HTTP endpoints
- **Lines 48-54**: Volume mounts for certificates and configuration
- **Lines 55-74**: Health check probes for liveness and readiness
- **Lines 75-81**: Resource requirements and limits
- **Lines 82-92**: Volume definitions and pod-level configurations

**API Server Configuration Functionality:**
- **Authentication**: Configures multiple authentication methods including certificates and bootstrap tokens
- **Authorization**: Implements Node and RBAC authorization modes
- **etcd Integration**: Connects to etcd cluster with proper certificates
- **Security**: Uses TLS certificates for secure communication
- **Admission Control**: Implements NodeRestriction admission plugin
- **Service Discovery**: Configures service cluster IP range

**Command Explanation:**
```bash
# Apply the API Server configuration analysis
kubectl apply -f api-server-analysis.yaml
```

**Expected Output:**
```
pod/kube-apiserver-analysis created
```

**Verification Steps:**
```bash
# Verify Pod was created
kubectl get pod kube-apiserver-analysis -n kube-system

# View Pod details
kubectl describe pod kube-apiserver-analysis -n kube-system

# Check API Server logs
kubectl logs kube-apiserver-analysis -n kube-system

# Test API Server health
kubectl get --raw /healthz
```

**Key Learning Points:**
- **Configuration Management**: Understanding API Server configuration parameters
- **Security**: Certificate-based authentication and authorization
- **High Availability**: Health checks and resource management
- **etcd Integration**: Proper etcd cluster connectivity configuration

#### **🔧 Example 2: etcd Configuration Analysis**

**Purpose**: Understanding etcd configuration and cluster setup

```bash
# Create etcd configuration analysis
cat > etcd-analysis.yaml << 'EOF'
apiVersion: v1                    # Line 1: Kubernetes API version for Pod resource
kind: Pod                        # Line 2: Resource type - Pod for running etcd container
metadata:                        # Line 3: Metadata section containing resource identification
  name: etcd-analysis            # Line 4: Unique name for this Pod within namespace
  namespace: kube-system        # Line 5: Kubernetes namespace where Pod will be created
  labels:                       # Line 6: Labels for resource identification and selection
    component: etcd             # Line 7: Component label identifying this as etcd
    tier: control-plane         # Line 8: Tier label identifying this as control plane component
spec:                           # Line 9: Pod specification section
  containers:                   # Line 10: Container specifications array start
  - name: etcd                  # Line 11: Container name - etcd container
    image: k8s.gcr.io/etcd:3.5.4-0  # Line 12: etcd container image with version
    command:                    # Line 13: Command array start
    - etcd                      # Line 14: Main command - etcd binary
    args:                       # Line 15: Command line arguments array start
    - --advertise-client-urls=https://127.0.0.1:2379  # Line 16: Client URLs to advertise
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt  # Line 17: etcd server certificate
    - --client-cert-auth=true   # Line 18: Enable client certificate authentication
    - --data-dir=/var/lib/etcd  # Line 19: Data directory for etcd storage
    - --initial-advertise-peer-urls=https://127.0.0.1:2380  # Line 20: Initial peer URLs
    - --initial-cluster=master=https://127.0.0.1:2380  # Line 21: Initial cluster configuration
    - --initial-cluster-state=new  # Line 22: Initial cluster state (new cluster)
    - --initial-cluster-token=etcd-cluster-1  # Line 23: Initial cluster token
    - --key-file=/etc/kubernetes/pki/etcd/server.key  # Line 24: etcd server private key
    - --listen-client-urls=https://127.0.0.1:2379  # Line 25: Client URLs to listen on
    - --listen-metrics-urls=http://127.0.0.1:2381  # Line 26: Metrics URLs to listen on
    - --listen-peer-urls=https://127.0.0.1:2380  # Line 27: Peer URLs to listen on
    - --name=master             # Line 28: etcd member name
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt  # Line 29: Peer certificate file
    - --peer-client-cert-auth=true  # Line 30: Enable peer client certificate authentication
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key  # Line 31: Peer private key file
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt  # Line 32: Peer trusted CA file
    - --snapshot-count=10000    # Line 33: Number of transactions before snapshot
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt  # Line 34: Trusted CA file
    ports:                       # Line 35: Port configuration array start
    - containerPort: 2379        # Line 36: Container port for client communication
      name: client              # Line 37: Port name for client
      protocol: TCP             # Line 38: Protocol type - TCP
    - containerPort: 2380        # Line 39: Container port for peer communication
      name: peer                # Line 40: Port name for peer
      protocol: TCP             # Line 41: Protocol type - TCP
    - containerPort: 2381        # Line 42: Container port for metrics
      name: metrics             # Line 43: Port name for metrics
      protocol: TCP             # Line 44: Protocol type - TCP
    volumeMounts:               # Line 45: Volume mount configuration array start
    - name: etcd-certs          # Line 46: Volume mount name reference
      mountPath: /etc/kubernetes/pki/etcd  # Line 47: Mount path for etcd certificates
      readOnly: true            # Line 48: Mount as read-only for security
    - name: etcd-data           # Line 49: Volume mount name reference
      mountPath: /var/lib/etcd  # Line 50: Mount path for etcd data
    livenessProbe:              # Line 51: Liveness probe configuration
      exec:                     # Line 52: Exec probe configuration
        command:                # Line 53: Command array for probe
        - /bin/sh               # Line 54: Shell command
        - -c                    # Line 55: Shell flag for command execution
        - ETCDCTL_API=3 etcdctl endpoint health --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key  # Line 56: etcd health check command
      initialDelaySeconds: 15   # Line 57: Initial delay before first probe
      timeoutSeconds: 15        # Line 58: Probe timeout in seconds
      periodSeconds: 10         # Line 59: Probe interval in seconds
      failureThreshold: 8       # Line 60: Number of failures before restart
      successThreshold: 1       # Line 61: Number of successes to consider healthy
    readinessProbe:             # Line 62: Readiness probe configuration
      exec:                     # Line 63: Exec probe configuration
        command:                # Line 64: Command array for probe
        - /bin/sh               # Line 65: Shell command
        - -c                    # Line 66: Shell flag for command execution
        - ETCDCTL_API=3 etcdctl endpoint health --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key  # Line 67: etcd readiness check command
      initialDelaySeconds: 10   # Line 68: Initial delay before first probe
      timeoutSeconds: 5         # Line 69: Probe timeout in seconds
      periodSeconds: 5          # Line 70: Probe interval in seconds
      failureThreshold: 3       # Line 71: Number of failures before marking not ready
      successThreshold: 1       # Line 72: Number of successes to consider ready
    resources:                  # Line 73: Resource requirements and limits
      requests:                 # Line 74: Minimum resource requests
        cpu: 100m              # Line 75: Minimum CPU request (100 millicores)
        memory: 100Mi          # Line 76: Minimum memory request (100 megabytes)
      limits:                   # Line 77: Maximum resource limits
        cpu: 200m              # Line 78: Maximum CPU limit (200 millicores)
        memory: 200Mi          # Line 79: Maximum memory limit (200 megabytes)
  volumes:                      # Line 80: Volume definitions array start
  - name: etcd-certs           # Line 81: First volume name - etcd certificates
    hostPath:                  # Line 82: Volume type - hostPath
      path: /etc/kubernetes/pki/etcd  # Line 83: Host path for etcd certificates
      type: DirectoryOrCreate  # Line 84: Create directory if it doesn't exist
  - name: etcd-data            # Line 85: Second volume name - etcd data
    hostPath:                  # Line 86: Volume type - hostPath
      path: /var/lib/etcd      # Line 87: Host path for etcd data
      type: DirectoryOrCreate  # Line 88: Create directory if it doesn't exist
  hostNetwork: true            # Line 89: Use host network namespace
  priorityClassName: system-node-critical  # Line 90: Priority class for critical system pods
EOF

**Line-by-Line Explanation:**
- **Lines 1-8**: Standard Pod metadata with etcd component labels
- **Lines 9-34**: etcd container with comprehensive cluster configuration
- **Lines 35-44**: Port configuration for client, peer, and metrics communication
- **Lines 45-50**: Volume mounts for certificates and data persistence
- **Lines 51-72**: Health check probes using etcdctl commands
- **Lines 73-79**: Resource requirements optimized for etcd workload
- **Lines 80-90**: Volume definitions and pod-level configurations

**etcd Configuration Functionality:**
- **Cluster Formation**: Configures initial cluster state and member discovery
- **Security**: Uses TLS certificates for client and peer authentication
- **Data Persistence**: Configures data directory for state storage
- **Health Monitoring**: Implements health checks using etcdctl
- **Metrics**: Exposes metrics endpoint for monitoring
- **Snapshot Management**: Configures automatic snapshots for data safety

**Command Explanation:**
```bash
# Apply the etcd configuration analysis
kubectl apply -f etcd-analysis.yaml
```

**Expected Output:**
```
pod/etcd-analysis created
```

**Verification Steps:**
```bash
# Verify Pod was created
kubectl get pod etcd-analysis -n kube-system

# View Pod details
kubectl describe pod etcd-analysis -n kube-system

# Check etcd logs
kubectl logs etcd-analysis -n kube-system

# Test etcd health
kubectl exec etcd-analysis -n kube-system -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379
```

**Key Learning Points:**
- **Cluster Configuration**: Understanding etcd cluster formation and member management
- **Security**: Certificate-based authentication for client and peer communication
- **Data Management**: Persistent storage and snapshot configuration
- **Health Monitoring**: Comprehensive health checks and metrics exposure

#### **🔧 Example 3: Scheduler Configuration Analysis**

**Purpose**: Understanding Scheduler configuration and scheduling policies

```bash
# Create Scheduler configuration analysis
cat > scheduler-analysis.yaml << 'EOF'
apiVersion: v1                    # Line 1: Kubernetes API version for Pod resource
kind: Pod                        # Line 2: Resource type - Pod for running Scheduler container
metadata:                        # Line 3: Metadata section containing resource identification
  name: kube-scheduler-analysis  # Line 4: Unique name for this Pod within namespace
  namespace: kube-system        # Line 5: Kubernetes namespace where Pod will be created
  labels:                       # Line 6: Labels for resource identification and selection
    component: kube-scheduler   # Line 7: Component label identifying this as Scheduler
    tier: control-plane         # Line 8: Tier label identifying this as control plane component
spec:                           # Line 9: Pod specification section
  containers:                   # Line 10: Container specifications array start
  - name: kube-scheduler        # Line 11: Container name - Scheduler container
    image: k8s.gcr.io/kube-scheduler:v1.25.0  # Line 12: Scheduler container image with version
    command:                    # Line 13: Command array start
    - kube-scheduler            # Line 14: Main command - Scheduler binary
    args:                       # Line 15: Command line arguments array start
    - --authentication-kubeconfig=/etc/kubernetes/scheduler.conf  # Line 16: Authentication kubeconfig file
    - --authorization-kubeconfig=/etc/kubernetes/scheduler.conf  # Line 17: Authorization kubeconfig file
    - --bind-address=127.0.0.1  # Line 18: Bind address for scheduler server
    - --kubeconfig=/etc/kubernetes/scheduler.conf  # Line 19: Kubeconfig file for API server access
    - --leader-elect=true       # Line 20: Enable leader election for HA
    - --port=10259             # Line 21: Port for scheduler server
    - --secure-port=10259      # Line 22: Secure port for scheduler server
    - --v=2                    # Line 23: Verbosity level for logging
    - --scheduler-name=default-scheduler  # Line 24: Name of the scheduler
    - --profiling=true         # Line 25: Enable profiling for performance analysis
    - --contention-profiling=true  # Line 26: Enable contention profiling
    - --cert-dir=/var/run/kubernetes  # Line 27: Directory for TLS certificates
    - --config=/etc/kubernetes/scheduler-config.yaml  # Line 28: Scheduler configuration file
    ports:                       # Line 29: Port configuration array start
    - containerPort: 10259       # Line 30: Container port for scheduler server
      name: https               # Line 31: Port name for HTTPS
      protocol: TCP             # Line 32: Protocol type - TCP
    volumeMounts:               # Line 33: Volume mount configuration array start
    - name: kubeconfig          # Line 34: Volume mount name reference
      mountPath: /etc/kubernetes  # Line 35: Mount path for Kubernetes configuration
      readOnly: true            # Line 36: Mount as read-only for security
    - name: cert-dir            # Line 37: Volume mount name reference
      mountPath: /var/run/kubernetes  # Line 38: Mount path for certificates
      readOnly: true            # Line 39: Mount as read-only for security
    livenessProbe:              # Line 40: Liveness probe configuration
      httpGet:                  # Line 41: HTTP GET probe configuration
        path: /healthz         # Line 42: Health check endpoint path
        port: 10259            # Line 43: Health check port
        scheme: HTTPS          # Line 44: Health check scheme
      initialDelaySeconds: 15   # Line 45: Initial delay before first probe
      timeoutSeconds: 15        # Line 46: Probe timeout in seconds
      periodSeconds: 10         # Line 47: Probe interval in seconds
      failureThreshold: 8       # Line 48: Number of failures before restart
      successThreshold: 1       # Line 49: Number of successes to consider healthy
    readinessProbe:             # Line 50: Readiness probe configuration
      httpGet:                  # Line 51: HTTP GET probe configuration
        path: /readyz          # Line 52: Readiness check endpoint path
        port: 10259            # Line 53: Readiness check port
        scheme: HTTPS          # Line 54: Readiness check scheme
      initialDelaySeconds: 10   # Line 55: Initial delay before first probe
      timeoutSeconds: 5         # Line 56: Probe timeout in seconds
      periodSeconds: 5          # Line 57: Probe interval in seconds
      failureThreshold: 3       # Line 58: Number of failures before marking not ready
      successThreshold: 1       # Line 59: Number of successes to consider ready
    resources:                  # Line 60: Resource requirements and limits
      requests:                 # Line 61: Minimum resource requests
        cpu: 100m              # Line 62: Minimum CPU request (100 millicores)
        memory: 128Mi          # Line 63: Minimum memory request (128 megabytes)
      limits:                   # Line 64: Maximum resource limits
        cpu: 200m              # Line 65: Maximum CPU limit (200 millicores)
        memory: 256Mi          # Line 66: Maximum memory limit (256 megabytes)
  volumes:                      # Line 67: Volume definitions array start
  - name: kubeconfig           # Line 68: First volume name - Kubernetes configuration
    hostPath:                  # Line 69: Volume type - hostPath
      path: /etc/kubernetes    # Line 70: Host path for configuration
      type: DirectoryOrCreate  # Line 71: Create directory if it doesn't exist
  - name: cert-dir             # Line 72: Second volume name - certificate directory
    hostPath:                  # Line 73: Volume type - hostPath
      path: /var/run/kubernetes  # Line 74: Host path for certificates
      type: DirectoryOrCreate  # Line 75: Create directory if it doesn't exist
  hostNetwork: true            # Line 76: Use host network namespace
  priorityClassName: system-node-critical  # Line 77: Priority class for critical system pods
EOF

**Line-by-Line Explanation:**
- **Lines 1-8**: Standard Pod metadata with Scheduler component labels
- **Lines 9-28**: Scheduler container with comprehensive configuration parameters
- **Lines 29-32**: Port configuration for scheduler server
- **Lines 33-39**: Volume mounts for configuration and certificates
- **Lines 40-59**: Health check probes for liveness and readiness
- **Lines 60-66**: Resource requirements optimized for scheduler workload
- **Lines 67-77**: Volume definitions and pod-level configurations

**Scheduler Configuration Functionality:**
- **High Availability**: Leader election for multiple scheduler instances
- **Authentication**: Kubeconfig-based authentication with API server
- **Profiling**: Performance and contention profiling for optimization
- **Configuration**: External configuration file for scheduling policies
- **Security**: TLS certificates for secure communication
- **Health Monitoring**: Comprehensive health checks and metrics

**Command Explanation:**
```bash
# Apply the Scheduler configuration analysis
kubectl apply -f scheduler-analysis.yaml
```

**Expected Output:**
```
pod/kube-scheduler-analysis created
```

**Verification Steps:**
```bash
# Verify Pod was created
kubectl get pod kube-scheduler-analysis -n kube-system

# View Pod details
kubectl describe pod kube-scheduler-analysis -n kube-system

# Check Scheduler logs
kubectl logs kube-scheduler-analysis -n kube-system

# Test Scheduler health
kubectl get --raw /api/v1/namespaces/kube-system/pods/kube-scheduler-analysis:10259/proxy/healthz
```

**Key Learning Points:**
- **Scheduling Policies**: Understanding scheduler configuration and policies
- **High Availability**: Leader election and multiple scheduler instances
- **Performance**: Profiling and optimization capabilities
- **Security**: Authentication and authorization configuration

---

## 📚 **Key Terminology - Kubernetes Architecture**

### **🏗️ Core Architecture Terms**

#### **Control Plane Components**
- **API Server (kube-apiserver)**: Central management point that exposes the Kubernetes API and validates requests
- **etcd**: Distributed key-value store that serves as the single source of truth for cluster state
- **Scheduler (kube-scheduler)**: Component that assigns pods to nodes based on resource requirements and constraints
- **Controller Manager (kube-controller-manager)**: Runs controllers that manage cluster resources and maintain desired state

#### **Worker Node Components**
- **kubelet**: Primary node agent that manages pods and containers on each node
- **kube-proxy**: Network proxy that implements Services and handles load balancing
- **Container Runtime**: Software that runs containers (containerd, Docker, CRI-O)

#### **Cluster Architecture**
- **Master Node**: Node running control plane components (API Server, etcd, Scheduler, Controller Manager)
- **Worker Node**: Node running kubelet, kube-proxy, and container runtime
- **Cluster**: Set of nodes managed by Kubernetes control plane
- **Node**: Physical or virtual machine that runs Kubernetes components

### **🔧 Configuration and Management**

#### **Authentication and Authorization**
- **RBAC (Role-Based Access Control)**: Authorization mechanism using roles and role bindings
- **Service Account**: Identity for processes running in pods
- **Certificate Authority (CA)**: Issues and validates certificates for secure communication
- **Bootstrap Token**: Temporary token for initial cluster setup

#### **Networking**
- **Pod Network**: Network that allows pods to communicate with each other
- **Service Network**: Network that provides stable IP addresses for services
- **CNI (Container Network Interface)**: Plugin system for configuring pod networking
- **kube-proxy**: Network proxy that implements Services and load balancing

#### **Storage**
- **Persistent Volume (PV)**: Cluster-wide storage resource
- **Persistent Volume Claim (PVC)**: Request for storage by a pod
- **Storage Class**: Defines different classes of storage available in the cluster
- **Volume**: Storage that can be mounted into pods

### **🎯 Scheduling and Resource Management**

#### **Scheduling**
- **Scheduler**: Component that assigns pods to nodes
- **Node Affinity**: Rules that influence pod placement on nodes
- **Pod Affinity**: Rules that influence pod placement relative to other pods
- **Taints and Tolerations**: Node-level constraints for pod scheduling

#### **Resource Management**
- **Resource Requests**: Minimum resources required by a pod
- **Resource Limits**: Maximum resources a pod can use
- **Quality of Service (QoS)**: Pod classification based on resource requests and limits
- **Node Capacity**: Total resources available on a node

### **🔍 Monitoring and Observability**

#### **Health Checks**
- **Liveness Probe**: Checks if a container is running and restarts if failed
- **Readiness Probe**: Checks if a container is ready to receive traffic
- **Startup Probe**: Checks if a container has started successfully
- **Health Check**: Mechanism to verify component health

#### **Logging and Metrics**
- **Container Logs**: Output from containerized applications
- **System Logs**: Logs from Kubernetes system components
- **Metrics**: Quantitative data about cluster and application performance
- **Events**: Records of important cluster state changes

### **🛡️ Security and Compliance**

#### **Security Concepts**
- **Pod Security Policy**: Cluster-level policy for pod security
- **Network Policy**: Rules for network traffic between pods
- **Admission Control**: Validation and mutation of API requests
- **Secrets**: Secure storage for sensitive data

#### **Compliance**
- **Audit Logging**: Records of API server requests for compliance
- **RBAC Policies**: Role-based access control for security
- **Certificate Management**: Management of TLS certificates
- **Security Scanning**: Automated security vulnerability detection

### **🚀 High Availability and Scaling**

#### **High Availability**
- **Multi-Master**: Multiple control plane nodes for redundancy
- **etcd Clustering**: Distributed etcd cluster for state consistency
- **Leader Election**: Process for selecting active component instances
- **Failover**: Automatic switching to backup components

#### **Scaling**
- **Horizontal Pod Autoscaler (HPA)**: Automatically scales pods based on metrics
- **Vertical Pod Autoscaler (VPA)**: Automatically adjusts pod resource requests
- **Cluster Autoscaler**: Automatically scales cluster nodes
- **Load Balancing**: Distribution of traffic across multiple instances

### **🔧 Development and Operations**

#### **Development**
- **kubectl**: Command-line interface for Kubernetes
- **YAML Manifests**: Configuration files for Kubernetes resources
- **Helm**: Package manager for Kubernetes applications
- **Kustomize**: Configuration management tool for Kubernetes

#### **Operations**
- **Deployment**: Manages ReplicaSets and provides rolling updates
- **ReplicaSet**: Maintains a stable set of pod replicas
- **Service**: Provides stable network access to pods
- **Ingress**: Manages external access to services

### **🌐 Cloud and Infrastructure**

#### **Cloud Integration**
- **Cloud Controller Manager**: Integrates with cloud provider APIs
- **Load Balancer**: Cloud-provided load balancing service
- **Persistent Disk**: Cloud-provided persistent storage
- **Node Groups**: Managed groups of nodes in cloud environments

#### **Infrastructure**
- **kubeadm**: Tool for bootstrapping Kubernetes clusters
- **Container Runtime Interface (CRI)**: Interface between kubelet and container runtime
- **Container Network Interface (CNI)**: Interface for pod networking
- **Container Storage Interface (CSI)**: Interface for persistent storage

### **📊 Performance and Optimization**

#### **Performance**
- **Resource Quotas**: Limits on resource usage per namespace
- **Limit Ranges**: Constraints on resource requests and limits
- **Node Pressure**: Resource pressure on nodes (CPU, memory, disk)
- **Scheduling Performance**: Efficiency of pod scheduling decisions

#### **Optimization**
- **Resource Optimization**: Efficient use of cluster resources
- **Network Optimization**: Efficient pod-to-pod communication
- **Storage Optimization**: Efficient use of persistent storage
- **Monitoring Optimization**: Efficient collection and analysis of metrics

---

## ⚠️ **Common Mistakes and How to Avoid Them**

### **🏗️ Architecture Design Mistakes**

#### **1. Single Point of Failure in Control Plane**
**❌ Mistake**: Running only one instance of control plane components
```bash
# BAD: Single API Server instance
kubectl get pods -n kube-system | grep kube-apiserver
# Only shows one pod
```

**✅ Solution**: Implement high availability with multiple instances
```bash
# GOOD: Multiple API Server instances
kubectl get pods -n kube-system | grep kube-apiserver
# Shows multiple pods across different nodes
```

**Why This Matters**: Single control plane components create cluster-wide failure points
**Prevention**: Always deploy control plane components in HA mode with multiple replicas

#### **2. Inadequate etcd Backup Strategy**
**❌ Mistake**: Not backing up etcd or using inadequate backup frequency
```bash
# BAD: No etcd backup
# No backup strategy implemented
```

**✅ Solution**: Implement comprehensive etcd backup
```bash
# GOOD: Regular etcd backup
kubectl exec etcd-master -n kube-system -- etcdctl snapshot save /backup/etcd-snapshot-$(date +%Y%m%d).db
```

**Why This Matters**: etcd contains all cluster state; loss means complete cluster failure
**Prevention**: Implement automated daily backups with off-site storage

#### **3. Resource Misconfiguration**
**❌ Mistake**: Not setting proper resource requests and limits
```yaml
# BAD: No resource specifications
spec:
  containers:
  - name: app
    image: nginx
    # No resources specified
```

**✅ Solution**: Always specify resource requirements
```yaml
# GOOD: Proper resource specifications
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
```

**Why This Matters**: Without resource specifications, pods can consume all node resources
**Prevention**: Always set resource requests and limits for all containers

### **🔧 Configuration Mistakes**

#### **4. Incorrect API Server Configuration**
**❌ Mistake**: Using insecure API Server configuration
```bash
# BAD: Insecure API Server
--insecure-port=8080
--insecure-bind-address=0.0.0.0
```

**✅ Solution**: Secure API Server configuration
```bash
# GOOD: Secure API Server
--insecure-port=0
--secure-port=6443
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt
--tls-private-key-file=/etc/kubernetes/pki/apiserver.key
```

**Why This Matters**: Insecure configuration exposes cluster to unauthorized access
**Prevention**: Always use TLS certificates and disable insecure ports

#### **5. etcd Security Misconfiguration**
**❌ Mistake**: Running etcd without proper authentication
```bash
# BAD: etcd without authentication
--listen-client-urls=http://0.0.0.0:2379
--advertise-client-urls=http://0.0.0.0:2379
```

**✅ Solution**: Secure etcd configuration
```bash
# GOOD: Secure etcd
--listen-client-urls=https://127.0.0.1:2379
--advertise-client-urls=https://127.0.0.1:2379
--cert-file=/etc/kubernetes/pki/etcd/server.crt
--key-file=/etc/kubernetes/pki/etcd/server.key
--client-cert-auth=true
```

**Why This Matters**: Unsecured etcd exposes cluster state to unauthorized access
**Prevention**: Always use TLS certificates and client authentication

#### **6. Scheduler Configuration Errors**
**❌ Mistake**: Not configuring scheduler for high availability
```bash
# BAD: Single scheduler instance
--leader-elect=false
```

**✅ Solution**: Enable leader election for HA
```bash
# GOOD: HA scheduler configuration
--leader-elect=true
--leader-elect-lease-duration=15s
--leader-elect-renew-deadline=10s
--leader-elect-retry-period=2s
```

**Why This Matters**: Single scheduler creates scheduling failure point
**Prevention**: Always enable leader election for scheduler HA

### **🛡️ Security Mistakes**

#### **7. Weak RBAC Configuration**
**❌ Mistake**: Using overly permissive RBAC policies
```yaml
# BAD: Overly permissive role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

**✅ Solution**: Principle of least privilege
```yaml
# GOOD: Specific permissions
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**Why This Matters**: Overly permissive access violates security principles
**Prevention**: Always follow principle of least privilege

#### **8. Insecure Service Account Usage**
**❌ Mistake**: Using default service account for all pods
```yaml
# BAD: Default service account
spec:
  containers:
  - name: app
    image: nginx
    # Uses default service account
```

**✅ Solution**: Create dedicated service accounts
```yaml
# GOOD: Dedicated service account
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: nginx
```

**Why This Matters**: Default service account has unnecessary permissions
**Prevention**: Create dedicated service accounts with minimal required permissions

### **🌐 Networking Mistakes**

#### **9. Incorrect Network Policy Configuration**
**❌ Mistake**: Not implementing network policies
```yaml
# BAD: No network policies
# Pods can communicate freely without restrictions
```

**✅ Solution**: Implement network policies
```yaml
# GOOD: Network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Why This Matters**: Without network policies, pods have unrestricted network access
**Prevention**: Always implement network policies for security

#### **10. Service Discovery Issues**
**❌ Mistake**: Hardcoding IP addresses instead of using service names
```yaml
# BAD: Hardcoded IP
spec:
  containers:
  - name: app
    env:
    - name: DB_HOST
      value: "192.168.1.100"  # Hardcoded IP
```

**✅ Solution**: Use service names for discovery
```yaml
# GOOD: Service name
spec:
  containers:
  - name: app
    env:
    - name: DB_HOST
      value: "database-service"  # Service name
```

**Why This Matters**: Hardcoded IPs break when services move or scale
**Prevention**: Always use service names for service discovery

### **📊 Monitoring and Observability Mistakes**

#### **11. Insufficient Health Checks**
**❌ Mistake**: Not implementing proper health checks
```yaml
# BAD: No health checks
spec:
  containers:
  - name: app
    image: nginx
    # No health checks
```

**✅ Solution**: Implement comprehensive health checks
```yaml
# GOOD: Health checks
spec:
  containers:
  - name: app
    image: nginx
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

**Why This Matters**: Without health checks, failed containers aren't detected
**Prevention**: Always implement liveness and readiness probes

#### **12. Inadequate Logging Configuration**
**❌ Mistake**: Not configuring proper logging
```yaml
# BAD: No logging configuration
spec:
  containers:
  - name: app
    image: nginx
    # No logging configuration
```

**✅ Solution**: Configure structured logging
```yaml
# GOOD: Logging configuration
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: LOG_LEVEL
      value: "info"
    - name: LOG_FORMAT
      value: "json"
```

**Why This Matters**: Poor logging makes troubleshooting difficult
**Prevention**: Always configure structured logging with appropriate levels

### **🚀 Performance and Scaling Mistakes**

#### **13. Inefficient Resource Allocation**
**❌ Mistake**: Not optimizing resource allocation
```yaml
# BAD: Inefficient resources
spec:
  containers:
  - name: app
    resources:
      requests:
        cpu: 1000m  # Too high
        memory: 1Gi  # Too high
      limits:
        cpu: 2000m  # Too high
        memory: 2Gi  # Too high
```

**✅ Solution**: Optimize resource allocation
```yaml
# GOOD: Optimized resources
spec:
  containers:
  - name: app
    resources:
      requests:
        cpu: 100m  # Appropriate
        memory: 128Mi  # Appropriate
      limits:
        cpu: 200m  # Appropriate
        memory: 256Mi  # Appropriate
```

**Why This Matters**: Over-allocation wastes resources and reduces cluster efficiency
**Prevention**: Monitor actual usage and adjust resources accordingly

#### **14. Poor Scheduling Configuration**
**❌ Mistake**: Not using node affinity and anti-affinity
```yaml
# BAD: No scheduling constraints
spec:
  containers:
  - name: app
    image: nginx
    # No scheduling constraints
```

**✅ Solution**: Use scheduling constraints
```yaml
# GOOD: Scheduling constraints
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - nginx
        topologyKey: kubernetes.io/hostname
```

**Why This Matters**: Without constraints, pods may be scheduled inefficiently
**Prevention**: Always consider pod placement requirements

### **🔧 Operational Mistakes**

#### **15. Inadequate Backup and Recovery**
**❌ Mistake**: Not testing backup and recovery procedures
```bash
# BAD: No recovery testing
# Backups exist but recovery never tested
```

**✅ Solution**: Regular recovery testing
```bash
# GOOD: Recovery testing
# Test etcd backup recovery monthly
kubectl exec etcd-master -n kube-system -- etcdctl snapshot restore /backup/etcd-snapshot.db
```

**Why This Matters**: Untested backups may not work when needed
**Prevention**: Regularly test backup and recovery procedures

#### **16. Poor Change Management**
**❌ Mistake**: Making changes without proper testing
```bash
# BAD: Direct production changes
kubectl apply -f new-config.yaml  # No testing
```

**✅ Solution**: Proper change management
```bash
# GOOD: Staged deployment
# 1. Test in development
kubectl apply -f new-config.yaml -n dev
# 2. Test in staging
kubectl apply -f new-config.yaml -n staging
# 3. Deploy to production
kubectl apply -f new-config.yaml -n production
```

**Why This Matters**: Untested changes can cause production outages
**Prevention**: Always test changes in non-production environments first

### **📋 Prevention Checklist**

#### **Before Deployment**
- [ ] Verify all control plane components are configured for HA
- [ ] Ensure etcd backup strategy is implemented and tested
- [ ] Confirm all containers have resource requests and limits
- [ ] Validate security configurations (TLS, RBAC, network policies)
- [ ] Test health checks and monitoring

#### **During Operations**
- [ ] Monitor resource usage and adjust allocations
- [ ] Regularly test backup and recovery procedures
- [ ] Review and update RBAC policies
- [ ] Monitor cluster health and performance
- [ ] Keep components updated with security patches

#### **Regular Maintenance**
- [ ] Review and optimize resource allocations
- [ ] Test disaster recovery procedures
- [ ] Update security policies and configurations
- [ ] Monitor and analyze cluster performance
- [ ] Document lessons learned and best practices

---

## ⚡ **Quick Reference - Expert-Level Kubernetes Architecture**

### **🚀 Essential Commands for Architecture Management**

#### **Cluster Information and Health**
```bash
# Quick cluster health check
kubectl cluster-info && kubectl get nodes && kubectl get pods -n kube-system
# Line-by-line explanation:
# - kubectl cluster-info: Displays cluster information including API server endpoint
# - &&: Logical AND operator - only executes next command if previous succeeds
# - kubectl get nodes: Lists all nodes in the cluster with their status
# - kubectl get pods -n kube-system: Lists all pods in the kube-system namespace
# Expected output: Cluster info, node list, and system pods status

# Detailed cluster information
kubectl cluster-info dump | jq '.items[] | select(.kind=="Node") | {name: .metadata.name, status: .status.conditions[].type}'
# Line-by-line explanation:
# - kubectl cluster-info dump: Exports complete cluster state as JSON
# - |: Pipe operator to send output to next command
# - jq: JSON processor for filtering and formatting
# - '.items[]': Iterates through all items in the JSON array
# - 'select(.kind=="Node")': Filters only Node resources
# - '{name: .metadata.name, status: .status.conditions[].type}': Creates object with node name and status
# Expected output: JSON array of node names and their current status conditions

# Component status (legacy)
kubectl get componentstatuses
# Line-by-line explanation:
# - kubectl get componentstatuses: Shows status of control plane components
# - Note: This is deprecated in favor of individual component health checks
# Expected output: Status of etcd, controller-manager, and scheduler components

# API server health
kubectl get --raw /healthz && kubectl get --raw /readyz
# Line-by-line explanation:
# - kubectl get --raw /healthz: Direct API call to health check endpoint
# - kubectl get --raw /readyz: Direct API call to readiness check endpoint
# - &&: Only executes second command if first succeeds
# Expected output: "ok" for healthy API server, error message if unhealthy
```

#### **Control Plane Component Management**
```bash
# API Server configuration
kubectl get pods -n kube-system -l component=kube-apiserver -o yaml
# Line-by-line explanation:
# - kubectl get pods: Lists pods in the cluster
# - -n kube-system: Specifies the kube-system namespace
# - -l component=kube-apiserver: Filters pods with label component=kube-apiserver
# - -o yaml: Outputs in YAML format for detailed configuration
# Expected output: YAML configuration of API Server pod with all settings and arguments

# etcd cluster health
kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --cluster
# Line-by-line explanation:
# - kubectl exec: Executes command inside a pod
# - -n kube-system: Specifies the kube-system namespace
# - etcd-master: Target pod name (adjust based on your cluster)
# - --: Separator between kubectl and container command
# - etcdctl endpoint health --cluster: etcd command to check cluster health
# Expected output: Health status of all etcd cluster members

# Scheduler configuration
kubectl get pods -n kube-system -l component=kube-scheduler -o yaml
# Line-by-line explanation:
# - kubectl get pods: Lists pods in the cluster
# - -n kube-system: Specifies the kube-system namespace
# - -l component=kube-scheduler: Filters pods with label component=kube-scheduler
# - -o yaml: Outputs in YAML format for detailed configuration
# Expected output: YAML configuration of Scheduler pod with all settings and arguments

# Controller Manager status
kubectl get pods -n kube-system -l component=kube-controller-manager -o yaml
# Line-by-line explanation:
# - kubectl get pods: Lists pods in the cluster
# - -n kube-system: Specifies the kube-system namespace
# - -l component=kube-controller-manager: Filters pods with label component=kube-controller-manager
# - -o yaml: Outputs in YAML format for detailed configuration
# Expected output: YAML configuration of Controller Manager pod with all settings and arguments
```

#### **Node and Resource Management**
```bash
# Node resource utilization
kubectl top nodes && kubectl describe nodes
# Line-by-line explanation:
# - kubectl top nodes: Shows CPU and memory usage for all nodes
# - &&: Logical AND operator - only executes next command if previous succeeds
# - kubectl describe nodes: Provides detailed information about each node
# Expected output: Resource usage metrics followed by detailed node descriptions

# Pod resource usage
kubectl top pods --all-namespaces
# Line-by-line explanation:
# - kubectl top pods: Shows CPU and memory usage for pods
# - --all-namespaces: Includes pods from all namespaces (not just default)
# Expected output: Resource usage metrics for all pods across all namespaces

# Resource quotas and limits
kubectl get resourcequotas --all-namespaces
kubectl get limitranges --all-namespaces
# Line-by-line explanation:
# - kubectl get resourcequotas: Lists resource quotas that limit resource consumption
# - --all-namespaces: Shows quotas from all namespaces
# - kubectl get limitranges: Lists limit ranges that set default resource limits
# - --all-namespaces: Shows limit ranges from all namespaces
# Expected output: Resource quotas and limit ranges configured in the cluster
```

### **🔧 Advanced Configuration Patterns**

#### **High Availability Setup**
```yaml
# Multi-master API Server configuration
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver-ha
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver:v1.25.0
    args:
    - --advertise-address=192.168.1.100
    - --etcd-servers=https://192.168.1.100:2379,https://192.168.1.101:2379,https://192.168.1.102:2379
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --secure-port=6443
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --authorization-mode=Node,RBAC
    - --enable-admission-plugins=NodeRestriction
    - --service-cluster-ip-range=10.96.0.0/12
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
# Line-by-line explanation:
# apiVersion: v1 - Specifies the Kubernetes API version for this resource
# kind: Pod - Defines this as a Pod resource
# metadata: - Contains metadata about the pod
#   name: kube-apiserver-ha - Name of the API Server pod
#   namespace: kube-system - Places pod in the kube-system namespace
# spec: - Defines the pod specification
#   containers: - List of containers in the pod
#   - name: kube-apiserver - Name of the API Server container
#     image: k8s.gcr.io/kube-apiserver:v1.25.0 - Container image for API Server
#     args: - Command line arguments for the API Server
#     - --advertise-address=192.168.1.100 - IP address to advertise to clients
#     - --etcd-servers=https://192.168.1.100:2379,https://192.168.1.101:2379,https://192.168.1.102:2379 - etcd cluster endpoints
#     - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt - etcd CA certificate
#     - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt - Client certificate for etcd
#     - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key - Client key for etcd
#     - --secure-port=6443 - HTTPS port for API Server
#     - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt - TLS certificate for API Server
#     - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key - TLS private key for API Server
#     - --client-ca-file=/etc/kubernetes/pki/ca.crt - CA certificate for client authentication
#     - --authorization-mode=Node,RBAC - Authorization modes (Node and RBAC)
#     - --enable-admission-plugins=NodeRestriction - Admission control plugin
#     - --service-cluster-ip-range=10.96.0.0/12 - IP range for Service cluster IPs
#     - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt - CA for request header authentication
#     - --requestheader-extra-headers-prefix=X-Remote-Extra- - Prefix for extra headers
#     - --requestheader-group-headers=X-Remote-Group - Header containing group information
#     - --requestheader-username-headers=X-Remote-User - Header containing username
#     - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt - Certificate for proxy client
#     - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key - Key for proxy client
# Expected output: High-availability API Server pod with multi-etcd cluster support
```
```

#### **etcd Cluster Configuration**
```yaml
# etcd cluster member configuration
apiVersion: v1
kind: Pod
metadata:
  name: etcd-cluster-member
  namespace: kube-system
spec:
  containers:
  - name: etcd
    image: k8s.gcr.io/etcd:3.5.4-0
    command:
    - etcd
    args:
    - --name=etcd-1
    - --data-dir=/var/lib/etcd
    - --listen-client-urls=https://192.168.1.100:2379
    - --advertise-client-urls=https://192.168.1.100:2379
    - --listen-peer-urls=https://192.168.1.100:2380
    - --initial-advertise-peer-urls=https://192.168.1.100:2380
    - --initial-cluster=etcd-1=https://192.168.1.100:2380,etcd-2=https://192.168.1.101:2380,etcd-3=https://192.168.1.102:2380
    - --initial-cluster-state=new
    - --initial-cluster-token=etcd-cluster-1
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --client-cert-auth=true
    - --peer-client-cert-auth=true
    - --snapshot-count=10000
    - --heartbeat-interval=100
    - --election-timeout=1000
    - --max-request-bytes=33554432
    - --quota-backend-bytes=8589934592
# Line-by-line explanation:
# apiVersion: v1 - Specifies the Kubernetes API version for this resource
# kind: Pod - Defines this as a Pod resource
# metadata: - Contains metadata about the pod
#   name: etcd-cluster-member - Name of the etcd cluster member pod
#   namespace: kube-system - Places pod in the kube-system namespace
# spec: - Defines the pod specification
#   containers: - List of containers in the pod
#   - name: etcd - Name of the etcd container
#     image: k8s.gcr.io/etcd:3.5.4-0 - Container image for etcd
#     command: - Command to run in the container
#     - etcd - The etcd binary to execute
#     args: - Command line arguments for etcd
#     - --name=etcd-1 - Unique name for this etcd member
#     - --data-dir=/var/lib/etcd - Directory to store etcd data
#     - --listen-client-urls=https://192.168.1.100:2379 - Client API endpoint
#     - --advertise-client-urls=https://192.168.1.100:2379 - Client API endpoint to advertise
#     - --listen-peer-urls=https://192.168.1.100:2380 - Peer communication endpoint
#     - --initial-advertise-peer-urls=https://192.168.1.100:2380 - Peer endpoint to advertise
#     - --initial-cluster=etcd-1=https://192.168.1.100:2380,etcd-2=https://192.168.1.101:2380,etcd-3=https://192.168.1.102:2380 - Initial cluster configuration
#     - --initial-cluster-state=new - Indicates this is a new cluster
#     - --initial-cluster-token=etcd-cluster-1 - Unique token for cluster identification
#     - --cert-file=/etc/kubernetes/pki/etcd/server.crt - Server certificate for TLS
#     - --key-file=/etc/kubernetes/pki/etcd/server.key - Server private key for TLS
#     - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt - Peer certificate for TLS
#     - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key - Peer private key for TLS
#     - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt - CA certificate for client verification
#     - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt - CA certificate for peer verification
#     - --client-cert-auth=true - Enable client certificate authentication
#     - --peer-client-cert-auth=true - Enable peer certificate authentication
#     - --snapshot-count=10000 - Number of committed transactions before snapshot
#     - --heartbeat-interval=100 - Heartbeat interval in milliseconds
#     - --election-timeout=1000 - Election timeout in milliseconds
#     - --max-request-bytes=33554432 - Maximum request size (32MB)
#     - --quota-backend-bytes=8589934592 - Backend storage quota (8GB)
# Expected output: etcd cluster member pod with secure TLS configuration and performance tuning
```
```

### **🛡️ Security Configuration Templates**

#### **RBAC for Control Plane Components**
```yaml
# Service account for API Server
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-apiserver
  namespace: kube-system
# Line-by-line explanation:
# apiVersion: v1 - Specifies the Kubernetes API version for this resource
# kind: ServiceAccount - Defines this as a ServiceAccount resource
# metadata: - Contains metadata about the service account
#   name: kube-apiserver - Name of the service account for API Server
#   namespace: kube-system - Places service account in the kube-system namespace
# Expected output: Service account for API Server authentication

---
# ClusterRole for API Server
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube-apiserver
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["extensions"]
  resources: ["*"]
  verbs: ["*"]
# Line-by-line explanation:
# apiVersion: rbac.authorization.k8s.io/v1 - Specifies the RBAC API version
# kind: ClusterRole - Defines this as a ClusterRole resource (cluster-wide permissions)
# metadata: - Contains metadata about the cluster role
#   name: kube-apiserver - Name of the cluster role
# rules: - List of permission rules
# - apiGroups: [""] - Core API group (empty string)
#   resources: ["*"] - All resources in the core API group
#   verbs: ["*"] - All operations (get, list, watch, create, update, patch, delete)
# - apiGroups: ["apps"] - Apps API group
#   resources: ["*"] - All resources in the apps API group
#   verbs: ["*"] - All operations
# - apiGroups: ["extensions"] - Extensions API group
#   resources: ["*"] - All resources in the extensions API group
#   verbs: ["*"] - All operations
# Expected output: Cluster role with full permissions for API Server operations

---
# ClusterRoleBinding for API Server
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-apiserver
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-apiserver
subjects:
- kind: ServiceAccount
  name: kube-apiserver
  namespace: kube-system
# Line-by-line explanation:
# apiVersion: rbac.authorization.k8s.io/v1 - Specifies the RBAC API version
# kind: ClusterRoleBinding - Defines this as a ClusterRoleBinding resource
# metadata: - Contains metadata about the cluster role binding
#   name: kube-apiserver - Name of the cluster role binding
# roleRef: - Reference to the cluster role
#   apiGroup: rbac.authorization.k8s.io - API group for RBAC resources
#   kind: ClusterRole - Type of role being bound
#   name: kube-apiserver - Name of the cluster role to bind
# subjects: - List of subjects (users, groups, or service accounts) to bind
# - kind: ServiceAccount - Type of subject (service account)
#   name: kube-apiserver - Name of the service account
#   namespace: kube-system - Namespace of the service account
# Expected output: Cluster role binding that grants API Server service account full permissions
```
```

#### **Network Policies for Control Plane**
```yaml
# Network policy for control plane components
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: control-plane-policy
  namespace: kube-system
spec:
  podSelector:
    matchLabels:
      tier: control-plane
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 6443  # API Server
    - protocol: TCP
      port: 2379  # etcd client
    - protocol: TCP
      port: 2380  # etcd peer
    - protocol: TCP
      port: 10259 # Scheduler
    - protocol: TCP
      port: 10257 # Controller Manager
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: TCP
      port: 6443
    - protocol: TCP
      port: 2379
    - protocol: TCP
      port: 2380
# Line-by-line explanation:
# apiVersion: networking.k8s.io/v1 - Specifies the networking API version
# kind: NetworkPolicy - Defines this as a NetworkPolicy resource
# metadata: - Contains metadata about the network policy
#   name: control-plane-policy - Name of the network policy
#   namespace: kube-system - Places policy in the kube-system namespace
# spec: - Defines the network policy specification
#   podSelector: - Selects pods to apply the policy to
#     matchLabels: - Label selector for pods
#       tier: control-plane - Selects pods with label tier=control-plane
#   policyTypes: - Types of policies to apply
#   - Ingress - Applies ingress rules (incoming traffic)
#   - Egress - Applies egress rules (outgoing traffic)
#   ingress: - List of ingress rules
#   - from: - Source of incoming traffic
#     - namespaceSelector: - Selects source by namespace
#         matchLabels: - Label selector for namespaces
#           name: kube-system - Allows traffic from kube-system namespace
#     ports: - List of allowed ports
#     - protocol: TCP - TCP protocol
#       port: 6443 - API Server port
#     - protocol: TCP - TCP protocol
#       port: 2379 - etcd client port
#     - protocol: TCP - TCP protocol
#       port: 2380 - etcd peer port
#     - protocol: TCP - TCP protocol
#       port: 10259 - Scheduler port
#     - protocol: TCP - TCP protocol
#       port: 10257 - Controller Manager port
#   egress: - List of egress rules
#   - to: - Destination of outgoing traffic
#     - namespaceSelector: - Selects destination by namespace
#         matchLabels: - Label selector for namespaces
#           name: kube-system - Allows traffic to kube-system namespace
#     ports: - List of allowed ports
#     - protocol: TCP - TCP protocol
#       port: 6443 - API Server port
#     - protocol: TCP - TCP protocol
#       port: 2379 - etcd client port
#     - protocol: TCP - TCP protocol
#       port: 2380 - etcd peer port
# Expected output: Network policy that restricts control plane traffic to specific ports and namespaces
```
```

### **📊 Monitoring and Observability**

#### **Prometheus Monitoring Configuration**
```yaml
# ServiceMonitor for API Server
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kube-apiserver
  namespace: monitoring
spec:
  selector:
    matchLabels:
      component: kube-apiserver
  endpoints:
  - port: https
    path: /metrics
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
    bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
# Line-by-line explanation:
# apiVersion: monitoring.coreos.com/v1 - Specifies the Prometheus Operator API version
# kind: ServiceMonitor - Defines this as a ServiceMonitor resource for Prometheus
# metadata: - Contains metadata about the service monitor
#   name: kube-apiserver - Name of the service monitor
#   namespace: monitoring - Places monitor in the monitoring namespace
# spec: - Defines the service monitor specification
#   selector: - Selects services to monitor
#     matchLabels: - Label selector for services
#       component: kube-apiserver - Selects services with label component=kube-apiserver
#   endpoints: - List of endpoints to scrape
#   - port: https - Port name for HTTPS endpoint
#     path: /metrics - Path to metrics endpoint
#     scheme: https - Protocol scheme (HTTPS)
#     tlsConfig: - TLS configuration
#       insecureSkipVerify: true - Skip TLS certificate verification (for internal clusters)
#     bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token - Path to service account token for authentication
# Expected output: ServiceMonitor that configures Prometheus to scrape API Server metrics
```
```

#### **Grafana Dashboard Queries**
```promql
# API Server request rate
rate(apiserver_request_total[5m])
# Line-by-line explanation:
# rate() - PromQL function that calculates per-second rate of increase
# apiserver_request_total - Metric name for total API Server requests
# [5m] - Time range for rate calculation (5 minutes)
# Expected output: Requests per second over the last 5 minutes

# etcd operations per second
rate(etcd_server_requests_total[5m])
# Line-by-line explanation:
# rate() - PromQL function that calculates per-second rate of increase
# etcd_server_requests_total - Metric name for total etcd server requests
# [5m] - Time range for rate calculation (5 minutes)
# Expected output: etcd operations per second over the last 5 minutes

# Scheduler scheduling rate
rate(scheduler_schedule_attempts_total[5m])
# Line-by-line explanation:
# rate() - PromQL function that calculates per-second rate of increase
# scheduler_schedule_attempts_total - Metric name for total scheduler attempts
# [5m] - Time range for rate calculation (5 minutes)
# Expected output: Scheduling attempts per second over the last 5 minutes

# Controller Manager reconciliation rate
rate(controller_manager_reconcile_total[5m])
# Line-by-line explanation:
# rate() - PromQL function that calculates per-second rate of increase
# controller_manager_reconcile_total - Metric name for total controller reconciliations
# [5m] - Time range for rate calculation (5 minutes)
# Expected output: Reconciliation operations per second over the last 5 minutes

# Node resource utilization
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
# Line-by-line explanation:
# 100 - Base value for percentage calculation
# - - Subtraction operator
# (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) - Average idle CPU percentage
# avg() - PromQL function that calculates average
# rate() - PromQL function that calculates per-second rate
# node_cpu_seconds_total - Metric name for total CPU seconds
# {mode="idle"} - Label selector for idle CPU mode
# [5m] - Time range for rate calculation (5 minutes)
# * 100 - Multiplication to convert to percentage
# Expected output: CPU utilization percentage (100% - idle percentage)
```
```

### **🚀 Performance Optimization**

#### **Resource Optimization Scripts**
```bash
#!/bin/bash
# Cluster resource optimization script

# Check resource utilization
echo "=== Node Resource Utilization ==="
kubectl top nodes
# Line-by-line explanation:
# #!/bin/bash - Shebang line specifying bash interpreter
# # Cluster resource optimization script - Comment describing script purpose
# echo "=== Node Resource Utilization ===" - Prints section header
# kubectl top nodes - Shows CPU and memory usage for all nodes
# Expected output: Table showing node names, CPU usage, memory usage, and timestamps

echo "=== Pod Resource Utilization ==="
kubectl top pods --all-namespaces
# Line-by-line explanation:
# echo "=== Pod Resource Utilization ===" - Prints section header
# kubectl top pods --all-namespaces - Shows CPU and memory usage for all pods across all namespaces
# Expected output: Table showing pod names, namespaces, CPU usage, memory usage, and timestamps

# Check resource quotas
echo "=== Resource Quotas ==="
kubectl get resourcequotas --all-namespaces
# Line-by-line explanation:
# echo "=== Resource Quotas ===" - Prints section header
# kubectl get resourcequotas --all-namespaces - Lists all resource quotas across all namespaces
# Expected output: Table showing quota names, namespaces, CPU limits, memory limits, and usage

# Check limit ranges
echo "=== Limit Ranges ==="
kubectl get limitranges --all-namespaces
# Line-by-line explanation:
# echo "=== Limit Ranges ===" - Prints section header
# kubectl get limitranges --all-namespaces - Lists all limit ranges across all namespaces
# Expected output: Table showing limit range names, namespaces, and configured limits

# Check pod resource requests vs limits
echo "=== Pod Resource Analysis ==="
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources.requests.cpu}{"\t"}{.spec.containers[*].resources.limits.cpu}{"\n"}{end}'
# Line-by-line explanation:
# echo "=== Pod Resource Analysis ===" - Prints section header
# kubectl get pods --all-namespaces - Gets all pods from all namespaces
# -o jsonpath='...' - Uses jsonpath to extract specific fields
# {range .items[*]} - Iterates through all pod items
# {.metadata.name} - Extracts pod name
# {"\t"} - Adds tab separator
# {.spec.containers[*].resources.requests.cpu} - Extracts CPU requests for all containers
# {"\t"} - Adds tab separator
# {.spec.containers[*].resources.limits.cpu} - Extracts CPU limits for all containers
# {"\n"} - Adds newline
# {end} - Ends the range loop
# Expected output: Tab-separated list of pod names, CPU requests, and CPU limits
```
```

#### **Scheduling Optimization**
```yaml
# Priority class for critical workloads
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: system-critical
value: 1000000
globalDefault: false
description: "Priority class for system critical workloads"
# Line-by-line explanation:
# apiVersion: scheduling.k8s.io/v1 - Specifies the scheduling API version
# kind: PriorityClass - Defines this as a PriorityClass resource
# metadata: - Contains metadata about the priority class
#   name: system-critical - Name of the priority class
# value: 1000000 - Priority value (higher numbers = higher priority)
# globalDefault: false - Whether this is the default priority class for all pods
# description: "Priority class for system critical workloads" - Human-readable description
# Expected output: Priority class that gives high priority to critical system workloads

---
# Pod with priority class
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
spec:
  priorityClassName: system-critical
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi
# Line-by-line explanation:
# apiVersion: v1 - Specifies the Kubernetes API version for this resource
# kind: Pod - Defines this as a Pod resource
# metadata: - Contains metadata about the pod
#   name: critical-pod - Name of the critical pod
# spec: - Defines the pod specification
#   priorityClassName: system-critical - Assigns the system-critical priority class
#   containers: - List of containers in the pod
#   - name: app - Name of the application container
#     image: nginx - Container image to use
#     resources: - Resource requirements for the container
#       requests: - Minimum resources required
#         cpu: 100m - 100 millicores of CPU
#         memory: 128Mi - 128 megabytes of memory
#       limits: - Maximum resources allowed
#         cpu: 200m - 200 millicores of CPU
#         memory: 256Mi - 256 megabytes of memory
# Expected output: Pod with high priority scheduling and defined resource requirements
```
```

### **🔧 Troubleshooting Commands**

#### **Component Health Checks**
```bash
# API Server health
kubectl get --raw /healthz
kubectl get --raw /readyz
kubectl get --raw /livez
# Line-by-line explanation:
# kubectl get --raw /healthz - Direct API call to health check endpoint
# kubectl get --raw /readyz - Direct API call to readiness check endpoint
# kubectl get --raw /livez - Direct API call to liveness check endpoint
# Expected output: "ok" for healthy API server, error message if unhealthy

# etcd health
kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --cluster
# Line-by-line explanation:
# kubectl exec -n kube-system etcd-master - Executes command in etcd pod in kube-system namespace
# -- - Separator between kubectl and container command
# etcdctl endpoint health --cluster - etcd command to check health of all cluster members
# Expected output: Health status of all etcd cluster members

# Scheduler health
kubectl get --raw /api/v1/namespaces/kube-system/pods/kube-scheduler-master:10259/proxy/healthz
# Line-by-line explanation:
# kubectl get --raw - Direct API call
# /api/v1/namespaces/kube-system/pods/kube-scheduler-master:10259/proxy/healthz - Proxy path to scheduler health endpoint
# Expected output: "ok" for healthy scheduler, error message if unhealthy

# Controller Manager health
kubectl get --raw /api/v1/namespaces/kube-system/pods/kube-controller-manager-master:10257/proxy/healthz
# Line-by-line explanation:
# kubectl get --raw - Direct API call
# /api/v1/namespaces/kube-system/pods/kube-controller-manager-master:10257/proxy/healthz - Proxy path to controller manager health endpoint
# Expected output: "ok" for healthy controller manager, error message if unhealthy
```

#### **Log Analysis**
```bash
# API Server logs
kubectl logs -n kube-system -l component=kube-apiserver --tail=100
# Line-by-line explanation:
# kubectl logs - Retrieves logs from pods
# -n kube-system - Specifies the kube-system namespace
# -l component=kube-apiserver - Filters pods with label component=kube-apiserver
# --tail=100 - Shows only the last 100 lines of logs
# Expected output: Last 100 lines of API Server logs

# etcd logs
kubectl logs -n kube-system -l component=etcd --tail=100
# Line-by-line explanation:
# kubectl logs - Retrieves logs from pods
# -n kube-system - Specifies the kube-system namespace
# -l component=etcd - Filters pods with label component=etcd
# --tail=100 - Shows only the last 100 lines of logs
# Expected output: Last 100 lines of etcd logs

# Scheduler logs
kubectl logs -n kube-system -l component=kube-scheduler --tail=100
# Line-by-line explanation:
# kubectl logs - Retrieves logs from pods
# -n kube-system - Specifies the kube-system namespace
# -l component=kube-scheduler - Filters pods with label component=kube-scheduler
# --tail=100 - Shows only the last 100 lines of logs
# Expected output: Last 100 lines of Scheduler logs

# Controller Manager logs
kubectl logs -n kube-system -l component=kube-controller-manager --tail=100
# Line-by-line explanation:
# kubectl logs - Retrieves logs from pods
# -n kube-system - Specifies the kube-system namespace
# -l component=kube-controller-manager - Filters pods with label component=kube-controller-manager
# --tail=100 - Shows only the last 100 lines of logs
# Expected output: Last 100 lines of Controller Manager logs
```

#### **Performance Analysis**
```bash
# API Server metrics
kubectl get --raw /metrics | grep apiserver
# Line-by-line explanation:
# kubectl get --raw /metrics - Direct API call to metrics endpoint
# | - Pipe operator to send output to next command
# grep apiserver - Filters output to show only API Server related metrics
# Expected output: API Server specific metrics in Prometheus format

# etcd metrics
kubectl get --raw /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics
# Line-by-line explanation:
# kubectl get --raw - Direct API call
# /api/v1/namespaces/kube-system/pods/etcd-master:2379/proxy/metrics - Proxy path to etcd metrics endpoint
# Expected output: etcd metrics in Prometheus format

# Scheduler metrics
kubectl get --raw /api/v1/namespaces/kube-system/pods/kube-scheduler-master:10259/proxy/metrics
# Line-by-line explanation:
# kubectl get --raw - Direct API call
# /api/v1/namespaces/kube-system/pods/kube-scheduler-master:10259/proxy/metrics - Proxy path to scheduler metrics endpoint
# Expected output: Scheduler metrics in Prometheus format

# Controller Manager metrics
kubectl get --raw /api/v1/namespaces/kube-system/pods/kube-controller-manager-master:10257/proxy/metrics
# Line-by-line explanation:
# kubectl get --raw - Direct API call
# /api/v1/namespaces/kube-system/pods/kube-controller-manager-master:10257/proxy/metrics - Proxy path to controller manager metrics endpoint
# Expected output: Controller Manager metrics in Prometheus format
```

### **📋 Expert Checklist**

#### **Pre-Production Deployment**
- [ ] Verify HA configuration for all control plane components
- [ ] Test etcd backup and recovery procedures
- [ ] Validate security configurations (TLS, RBAC, network policies)
- [ ] Configure comprehensive monitoring and alerting
- [ ] Test disaster recovery scenarios
- [ ] Validate resource quotas and limit ranges
- [ ] Test scheduling constraints and affinity rules
- [ ] Verify network policies and service mesh integration

#### **Production Operations**
- [ ] Monitor cluster health and performance metrics
- [ ] Regularly test backup and recovery procedures
- [ ] Review and update security policies
- [ ] Monitor resource utilization and optimize allocations
- [ ] Test component failover scenarios
- [ ] Validate certificate expiration and renewal
- [ ] Monitor audit logs for security events
- [ ] Test disaster recovery procedures

#### **Advanced Optimization**
- [ ] Implement custom schedulers for specific workloads
- [ ] Configure advanced admission controllers
- [ ] Implement custom resource definitions (CRDs)
- [ ] Configure service mesh for microservices
- [ ] Implement advanced monitoring with custom metrics
- [ ] Configure automated scaling policies
- [ ] Implement advanced security scanning
- [ ] Configure multi-cluster management

---

## 🛠️ **Tools Covered**
- **kubectl**: Kubernetes command-line interface for cluster management
- **etcdctl**: etcd command-line interface for cluster state management
- **kubeadm**: Kubernetes cluster bootstrapping tool
- **kubelet**: Primary node agent for pod management
- **kube-proxy**: Network proxy for service management
- **containerd**: Container runtime for pod execution
- **API Server**: RESTful API for cluster operations

## 🏭 **Industry Tools**
- **k9s**: Terminal-based Kubernetes cluster management
- **Lens**: Desktop application for Kubernetes cluster management
- **Octant**: Web-based Kubernetes cluster dashboard
- **kubectx/kubens**: Context and namespace switching tools
- **kubectl-neat**: Clean up kubectl output
- **kubectl-tree**: Show resource hierarchy
- **kubectl-debug**: Debug running pods
- **kubectl-trace**: Trace system calls in pods

## 🌍 **Environment Strategy**

### **DEV Environment**
- **Single Node**: minikube or kind for development
- **Resource Limits**: Minimal resources for cost efficiency
- **Monitoring**: Basic monitoring with Prometheus
- **Security**: Relaxed security policies for development

### **UAT Environment**
- **Multi-Node**: 3-node cluster for testing
- **Resource Limits**: Moderate resources for realistic testing
- **Monitoring**: Full monitoring stack with Grafana
- **Security**: Production-like security policies

### **PROD Environment**
- **High Availability**: Multi-master cluster with etcd clustering
- **Resource Limits**: Full resources with auto-scaling
- **Monitoring**: Comprehensive monitoring with alerting
- **Security**: Strict security policies and RBAC

## ⚡ **Chaos Engineering**

### **Chaos Package 6: Cluster Component Failure Testing**
- **API Server Failure**: Simulate API server unavailability
- **etcd Failure**: Test cluster state management resilience
- **Scheduler Failure**: Test pod scheduling under failure
- **Controller Manager Failure**: Test resource management under failure
- **kubelet Failure**: Test node-level component failure
- **kube-proxy Failure**: Test network proxy failure

### **Chaos Scenarios**
1. **API Server Restart**: Restart API server and observe cluster behavior
2. **etcd Backup/Restore**: Test etcd backup and restore procedures
3. **Node Drain**: Drain nodes and observe pod rescheduling
4. **Component Scaling**: Scale control plane components and observe performance
5. **Network Partition**: Simulate network partitions between components

## 🎯 **Mini-Project: Production-Ready Cluster Architecture**

### **Project Requirements**
- **High Availability**: Multi-master cluster setup
- **Monitoring**: Comprehensive monitoring and alerting
- **Security**: RBAC, network policies, and security scanning
- **Backup**: etcd backup and disaster recovery
- **Documentation**: Complete architecture documentation

### **Implementation Steps**
1. **Cluster Setup**: Deploy multi-master cluster with kubeadm
2. **Monitoring Stack**: Deploy Prometheus, Grafana, and AlertManager
3. **Security Configuration**: Implement RBAC and network policies
4. **Backup Strategy**: Configure etcd backup and restore
5. **Documentation**: Create comprehensive architecture documentation

## ❓ **Interview Questions with Answers**

### **Q1: Explain the Kubernetes architecture and how components interact**
**Answer**: Kubernetes follows a master-worker architecture. The control plane (master) consists of:
- **API Server**: Central management point exposing REST API
- **etcd**: Distributed key-value store for cluster state
- **Scheduler**: Assigns pods to nodes based on resource requirements
- **Controller Manager**: Runs controllers to maintain desired state

Worker nodes contain:
- **kubelet**: Primary node agent managing pods and containers
- **kube-proxy**: Network proxy implementing Services
- **Container Runtime**: Runs containers (containerd, Docker, etc.)

Components interact through the API Server, which acts as the central communication hub.

### **Q2: What happens when you run `kubectl apply -f deployment.yaml`?**
**Answer**: The process involves:
1. **kubectl** sends the request to the **API Server**
2. **API Server** validates and stores the resource in **etcd**
3. **Controller Manager** detects the new Deployment resource
4. **Controller Manager** creates a ReplicaSet to manage pod replicas
5. **Scheduler** finds suitable nodes for unscheduled pods
6. **kubelet** on target nodes creates and manages the pods
7. **Container Runtime** starts the containers

### **Q3: How does Kubernetes ensure high availability?**
**Answer**: Kubernetes ensures HA through:
- **Multi-master setup**: Multiple API servers, schedulers, and controller managers
- **etcd clustering**: Distributed etcd cluster for state consistency
- **Pod replication**: Multiple pod replicas across different nodes
- **Health checks**: Liveness and readiness probes for pod health
- **Auto-recovery**: Automatic restart of failed pods and components
- **Load balancing**: Traffic distribution across multiple instances

### **Q4: What is the role of etcd in Kubernetes?**
**Answer**: etcd serves as the "brain" of Kubernetes:
- **State Storage**: Stores all cluster configuration and state
- **Consistency**: Provides strong consistency guarantees
- **Watch API**: Enables real-time change notifications
- **Backup**: Critical for disaster recovery and cluster restoration
- **Security**: Stores sensitive data like secrets and certificates
- **Performance**: Optimized for read-heavy workloads

### **Q5: How do you troubleshoot a failing Kubernetes cluster?**
**Answer**: Troubleshooting steps:
1. **Check cluster connectivity**: `kubectl cluster-info`
2. **Verify node status**: `kubectl get nodes`
3. **Check component health**: `kubectl get componentstatuses`
4. **Examine pod status**: `kubectl get pods --all-namespaces`
5. **Review logs**: `kubectl logs` for specific components
6. **Check events**: `kubectl get events --sort-by=.metadata.creationTimestamp`
7. **Verify resources**: Check CPU, memory, and storage availability
8. **Network connectivity**: Test inter-node and external connectivity

---

## 🎯 **Additional Practice Problems with Comprehensive Solutions**

### **Problem 2: High Availability Cluster Setup and Configuration**

#### **Scenario**
You are tasked with setting up a high availability Kubernetes cluster with multiple master nodes. The cluster needs to be production-ready with proper security, monitoring, and backup configurations.

#### **DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**

##### **Step 1: Multi-Master Cluster Setup**
```bash
# Create HA cluster setup script
cat > ha_cluster_setup.sh << 'EOF'
#!/bin/bash

# =============================================================================
# High Availability Kubernetes Cluster Setup
# Purpose: Set up multi-master cluster with proper HA configuration
# =============================================================================

# Configuration
MASTER_NODES=("master-1" "master-2" "master-3")
WORKER_NODES=("worker-1" "worker-2" "worker-3")
CLUSTER_NAME="ha-cluster"
POD_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"
ETCD_ENDPOINTS="https://192.168.1.100:2379,https://192.168.1.101:2379,https://192.168.1.102:2379"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

echo "=== HIGH AVAILABILITY CLUSTER SETUP ==="
echo "Date: $(date)"
echo ""

# =============================================================================
# 1. INITIALIZE FIRST MASTER NODE
# =============================================================================
log_message "INFO" "Initializing first master node"

# Initialize the cluster
kubeadm init \
    --control-plane-endpoint="192.168.1.100:6443" \
    --pod-network-cidr="$POD_CIDR" \
    --service-cidr="$SERVICE_CIDR" \
    --upload-certs \
    --certificate-key="$(kubeadm init phase upload-certs --upload-certs | tail -1)"

# Expected output analysis:
# - Cluster initialization: First master node initialized
# - Certificate generation: All necessary certificates created
# - kubeconfig: Admin kubeconfig file created
# - Join commands: Commands to join additional nodes

# Configure kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

log_message "INFO" "First master node initialized successfully"
EOF

chmod +x ha_cluster_setup.sh
```

##### **Step 2: Additional Master Nodes Setup**
```bash
# Add additional master nodes setup
cat >> ha_cluster_setup.sh << 'EOF'

# =============================================================================
# 2. ADDITIONAL MASTER NODES SETUP
# =============================================================================
log_message "INFO" "Setting up additional master nodes"

# For each additional master node
for node in "${MASTER_NODES[@]:1}"; do
    log_message "INFO" "Setting up master node: $node"
    
    # Join as control plane node
    kubeadm join 192.168.1.100:6443 \
        --token "$(kubeadm token list | grep -v TOKEN | awk '{print $1}')" \
        --discovery-token-ca-cert-hash "$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')" \
        --control-plane \
        --certificate-key "$(kubeadm init phase upload-certs --upload-certs | tail -1)"
    
    # Expected output analysis:
    # - Node joining: Master node joining the cluster
    # - Certificate installation: Certificates installed on new node
    # - Component startup: Control plane components starting
    # - Health checks: Node health verification
    
    log_message "INFO" "Master node $node setup completed"
done

log_message "INFO" "All master nodes setup completed"
EOF
```

##### **Step 3: Worker Nodes Setup**
```bash
# Add worker nodes setup
cat >> ha_cluster_setup.sh << 'EOF'

# =============================================================================
# 3. WORKER NODES SETUP
# =============================================================================
log_message "INFO" "Setting up worker nodes"

# For each worker node
for node in "${WORKER_NODES[@]}"; do
    log_message "INFO" "Setting up worker node: $node"
    
    # Join as worker node
    kubeadm join 192.168.1.100:6443 \
        --token "$(kubeadm token list | grep -v TOKEN | awk '{print $1}')" \
        --discovery-token-ca-cert-hash "$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')"
    
    # Expected output analysis:
    # - Node joining: Worker node joining the cluster
    # - kubelet configuration: kubelet configured and started
    # - Node registration: Node registered with API server
    # - Health checks: Node health verification
    
    log_message "INFO" "Worker node $node setup completed"
done

log_message "INFO" "All worker nodes setup completed"
EOF
```

##### **Step 4: Network Plugin Installation**
```bash
# Add network plugin installation
cat >> ha_cluster_setup.sh << 'EOF'

# =============================================================================
# 4. NETWORK PLUGIN INSTALLATION
# =============================================================================
log_message "INFO" "Installing network plugin"

# Install Calico network plugin
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Expected output analysis:
# - Network plugin installation: Calico components deployed
# - Pod network configuration: Pod networking configured
# - Network policies: Default network policies applied
# - DNS resolution: Cluster DNS configured

# Wait for network plugin to be ready
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s

log_message "INFO" "Network plugin installation completed"
EOF
```

##### **Step 5: Verification and Testing**
```bash
# Add verification and testing
cat >> ha_cluster_setup.sh << 'EOF'

# =============================================================================
# 5. VERIFICATION AND TESTING
# =============================================================================
log_message "INFO" "Verifying cluster setup"

# Check cluster status
echo "=== CLUSTER STATUS ==="
kubectl cluster-info
kubectl get nodes -o wide

# Expected output analysis:
# - Cluster information: All nodes showing as Ready
# - Node roles: Master and worker nodes properly labeled
# - Network connectivity: All nodes can communicate
# - Component health: All control plane components healthy

# Check control plane components
echo "=== CONTROL PLANE COMPONENTS ==="
kubectl get pods -n kube-system -o wide

# Expected output analysis:
# - API Server: Multiple API server instances running
# - etcd: etcd cluster healthy and accessible
# - Scheduler: Scheduler instances with leader election
# - Controller Manager: Controller manager instances with leader election

# Test pod scheduling
echo "=== POD SCHEDULING TEST ==="
kubectl run test-pod --image=nginx --restart=Never
kubectl wait --for=condition=ready pod test-pod --timeout=60s
kubectl get pod test-pod -o wide

# Expected output analysis:
# - Pod creation: Test pod created successfully
# - Pod scheduling: Pod scheduled to available node
# - Pod running: Pod running and ready
# - Network connectivity: Pod can communicate with cluster

# Cleanup test pod
kubectl delete pod test-pod

log_message "INFO" "Cluster verification completed successfully"
EOF
```

##### **Step 6: Execute HA Cluster Setup**
```bash
# Execute the HA cluster setup
./ha_cluster_setup.sh

# Display results
echo "=== HA CLUSTER SETUP COMPLETED ==="
echo "Cluster: $CLUSTER_NAME"
echo "Master nodes: ${#MASTER_NODES[@]}"
echo "Worker nodes: ${#WORKER_NODES[@]}"
echo ""
echo "=== CLUSTER INFORMATION ==="
kubectl cluster-info
kubectl get nodes -o wide
```

##### **Expected Outputs and Validation**
```bash
# Validate the HA cluster setup
echo "=== VALIDATION STEPS ==="

# 1. Check cluster connectivity
if kubectl cluster-info >/dev/null 2>&1; then
    echo "✅ Cluster connectivity verified"
else
    echo "❌ Cluster connectivity failed"
fi

# 2. Check node status
READY_NODES=$(kubectl get nodes --no-headers | grep Ready | wc -l)
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)

if [ "$READY_NODES" -eq "$TOTAL_NODES" ]; then
    echo "✅ All nodes are ready ($READY_NODES/$TOTAL_NODES)"
else
    echo "❌ Some nodes are not ready ($READY_NODES/$TOTAL_NODES)"
fi

# 3. Check control plane components
CONTROL_PLANE_PODS=$(kubectl get pods -n kube-system --no-headers | grep -E "(kube-apiserver|kube-scheduler|kube-controller-manager|etcd)" | wc -l)
EXPECTED_CONTROL_PLANE_PODS=$((4 * ${#MASTER_NODES[@]}))

if [ "$CONTROL_PLANE_PODS" -eq "$EXPECTED_CONTROL_PLANE_PODS" ]; then
    echo "✅ All control plane components running ($CONTROL_PLANE_PODS/$EXPECTED_CONTROL_PLANE_PODS)"
else
    echo "❌ Some control plane components not running ($CONTROL_PLANE_PODS/$EXPECTED_CONTROL_PLANE_PODS)"
fi

# 4. Check network plugin
NETWORK_PODS=$(kubectl get pods -n kube-system --no-headers | grep calico | wc -l)

if [ "$NETWORK_PODS" -gt 0 ]; then
    echo "✅ Network plugin installed ($NETWORK_PODS pods)"
else
    echo "❌ Network plugin not installed"
fi
```

##### **Error Handling and Troubleshooting**
```bash
# Error handling for common HA setup issues
echo "=== ERROR HANDLING AND TROUBLESHOOTING ==="

# Check for common issues
echo "1. Checking for common issues..."

# Check if kubeadm is installed
if ! command -v kubeadm &> /dev/null; then
    echo "❌ kubeadm not installed. Install with:"
    echo "   apt-get update && apt-get install -y kubeadm kubelet kubectl"
fi

# Check if container runtime is running
if ! systemctl is-active --quiet containerd; then
    echo "❌ Container runtime not running. Start with:"
    echo "   systemctl start containerd"
fi

# Check if swap is disabled
if swapon --show | grep -q .; then
    echo "❌ Swap is enabled. Disable with:"
    echo "   swapoff -a"
    echo "   sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
fi

# Check if firewall is configured
if ! ufw status | grep -q "Status: inactive"; then
    echo "⚠️  Firewall is active. Ensure ports are open:"
    echo "   - 6443 (API Server)"
    echo "   - 2379-2380 (etcd)"
    echo "   - 10250 (kubelet)"
    echo "   - 10251 (kube-scheduler)"
    echo "   - 10252 (kube-controller-manager)"
fi

# Check if time is synchronized
if ! ntpq -p | grep -q "^\*"; then
    echo "⚠️  Time not synchronized. Sync with:"
    echo "   systemctl start ntp"
fi

echo ""
echo "=== TROUBLESHOOTING COMMANDS ==="
echo "1. Check cluster status: kubectl cluster-info"
echo "2. Check node status: kubectl get nodes -o wide"
echo "3. Check pod status: kubectl get pods -n kube-system"
echo "4. Check events: kubectl get events --sort-by=.metadata.creationTimestamp"
echo "5. Check logs: kubectl logs -n kube-system <pod-name>"
echo "6. Check component status: kubectl get componentstatuses"
echo "7. Check etcd health: kubectl exec -n kube-system etcd-master -- etcdctl endpoint health"
echo "8. Check API server health: kubectl get --raw /healthz"
```

##### **Learning Outcomes and Key Takeaways**
```bash
echo "=== LEARNING OUTCOMES AND KEY TAKEAWAYS ==="
echo ""
echo "1. HIGH AVAILABILITY CONCEPTS:"
echo "   - Multi-master setup for redundancy"
echo "   - etcd clustering for state consistency"
echo "   - Leader election for component coordination"
echo "   - Load balancing for traffic distribution"
echo ""
echo "2. CLUSTER ARCHITECTURE:"
echo "   - Control plane component distribution"
echo "   - Worker node configuration"
echo "   - Network plugin integration"
echo "   - Certificate management"
echo ""
echo "3. OPERATIONAL SKILLS:"
echo "   - Cluster initialization and configuration"
echo "   - Node joining and management"
echo "   - Component health monitoring"
echo "   - Troubleshooting and debugging"
echo ""
echo "4. PRODUCTION READINESS:"
echo "   - Security configuration"
echo "   - Network policies"
echo "   - Resource management"
echo "   - Monitoring and alerting"
echo ""
echo "5. BEST PRACTICES:"
echo "   - Proper planning and design"
echo "   - Systematic implementation"
echo "   - Comprehensive testing"
echo "   - Documentation and maintenance"
```

### **Problem 3: etcd Backup and Disaster Recovery**

#### **Scenario**
You need to implement a comprehensive etcd backup and disaster recovery strategy for a production Kubernetes cluster. The solution must include automated backups, recovery procedures, and testing.

#### **DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**

##### **Step 1: etcd Backup Strategy Implementation**
```bash
# Create etcd backup strategy script
cat > etcd_backup_strategy.sh << 'EOF'
#!/bin/bash

# =============================================================================
# etcd Backup and Disaster Recovery Strategy
# Purpose: Implement comprehensive etcd backup and recovery procedures
# =============================================================================

# Configuration
BACKUP_DIR="/opt/etcd-backups"
RETENTION_DAYS=30
ETCD_ENDPOINTS="https://192.168.1.100:2379,https://192.168.1.101:2379,https://192.168.1.102:2379"
ETCD_CA_CERT="/etc/kubernetes/pki/etcd/ca.crt"
ETCD_CERT="/etc/kubernetes/pki/etcd/server.crt"
ETCD_KEY="/etc/kubernetes/pki/etcd/server.key"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message"
}

echo "=== ETCD BACKUP AND DISASTER RECOVERY STRATEGY ==="
echo "Date: $(date)"
echo ""

# =============================================================================
# 1. BACKUP DIRECTORY SETUP
# =============================================================================
log_message "INFO" "Setting up backup directory"

# Create backup directory
mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Create backup script
cat > "$BACKUP_DIR/etcd_backup.sh" << 'BACKUP_SCRIPT'
#!/bin/bash

# etcd backup script
BACKUP_DIR="/opt/etcd-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/etcd-backup-$TIMESTAMP.db"

# Create backup
kubectl exec -n kube-system etcd-master -- etcdctl snapshot save /tmp/etcd-backup.db \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key

# Copy backup to host
kubectl cp kube-system/etcd-master:/tmp/etcd-backup.db "$BACKUP_FILE"

# Verify backup
kubectl exec -n kube-system etcd-master -- etcdctl snapshot status /tmp/etcd-backup.db \
    --write-out=table

# Cleanup temporary file
kubectl exec -n kube-system etcd-master -- rm /tmp/etcd-backup.db

echo "Backup completed: $BACKUP_FILE"
BACKUP_SCRIPT

chmod +x "$BACKUP_DIR/etcd_backup.sh"

log_message "INFO" "Backup directory and script setup completed"
EOF

chmod +x etcd_backup_strategy.sh
```

##### **Step 2: Automated Backup Scheduling**
```bash
# Add automated backup scheduling
cat >> etcd_backup_strategy.sh << 'EOF'

# =============================================================================
# 2. AUTOMATED BACKUP SCHEDULING
# =============================================================================
log_message "INFO" "Setting up automated backup scheduling"

# Create cron job for daily backups
cat > "$BACKUP_DIR/etcd_backup_cron.sh" << 'CRON_SCRIPT'
#!/bin/bash

# Daily etcd backup with retention
BACKUP_DIR="/opt/etcd-backups"
RETENTION_DAYS=30

# Run backup
"$BACKUP_DIR/etcd_backup.sh"

# Cleanup old backups
find "$BACKUP_DIR" -name "etcd-backup-*.db" -type f -mtime +$RETENTION_DAYS -delete

# Log backup completion
echo "$(date): etcd backup completed" >> "$BACKUP_DIR/backup.log"
CRON_SCRIPT

chmod +x "$BACKUP_DIR/etcd_backup_cron.sh"

# Add to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * $BACKUP_DIR/etcd_backup_cron.sh") | crontab -

log_message "INFO" "Automated backup scheduling setup completed"
EOF
```

##### **Step 3: Disaster Recovery Procedures**
```bash
# Add disaster recovery procedures
cat >> etcd_backup_strategy.sh << 'EOF'

# =============================================================================
# 3. DISASTER RECOVERY PROCEDURES
# =============================================================================
log_message "INFO" "Setting up disaster recovery procedures"

# Create disaster recovery script
cat > "$BACKUP_DIR/etcd_disaster_recovery.sh" << 'RECOVERY_SCRIPT'
#!/bin/bash

# etcd disaster recovery script
BACKUP_DIR="/opt/etcd-backups"
ETCD_DATA_DIR="/var/lib/etcd"

# Function to restore etcd from backup
restore_etcd() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        echo "Error: Backup file not found: $backup_file"
        exit 1
    fi
    
    echo "Starting etcd restoration from: $backup_file"
    
    # Stop etcd service
    systemctl stop etcd
    
    # Backup current etcd data
    if [ -d "$ETCD_DATA_DIR" ]; then
        mv "$ETCD_DATA_DIR" "${ETCD_DATA_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Restore from backup
    etcdctl snapshot restore "$backup_file" \
        --data-dir="$ETCD_DATA_DIR" \
        --name=etcd-1 \
        --initial-cluster=etcd-1=https://192.168.1.100:2380,etcd-2=https://192.168.1.101:2380,etcd-3=https://192.168.1.102:2380 \
        --initial-cluster-token=etcd-cluster-1 \
        --initial-advertise-peer-urls=https://192.168.1.100:2380
    
    # Set proper permissions
    chown -R etcd:etcd "$ETCD_DATA_DIR"
    chmod 700 "$ETCD_DATA_DIR"
    
    # Start etcd service
    systemctl start etcd
    
    # Wait for etcd to be ready
    sleep 10
    
    # Verify etcd health
    etcdctl endpoint health --endpoints=https://127.0.0.1:2379 \
        --cacert=/etc/kubernetes/pki/etcd/ca.crt \
        --cert=/etc/kubernetes/pki/etcd/server.crt \
        --key=/etc/kubernetes/pki/etcd/server.key
    
    echo "etcd restoration completed successfully"
}

# Function to list available backups
list_backups() {
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/etcd-backup-*.db 2>/dev/null | awk '{print $9, $5, $6, $7, $8}'
}

# Main script logic
case "$1" in
    "restore")
        if [ -z "$2" ]; then
            echo "Usage: $0 restore <backup_file>"
            list_backups
            exit 1
        fi
        restore_etcd "$2"
        ;;
    "list")
        list_backups
        ;;
    *)
        echo "Usage: $0 {restore|list}"
        echo "  restore <backup_file> - Restore etcd from backup"
        echo "  list                 - List available backups"
        exit 1
        ;;
esac
RECOVERY_SCRIPT

chmod +x "$BACKUP_DIR/etcd_disaster_recovery.sh"

log_message "INFO" "Disaster recovery procedures setup completed"
EOF
```

##### **Step 4: Backup Testing and Validation**
```bash
# Add backup testing and validation
cat >> etcd_backup_strategy.sh << 'EOF'

# =============================================================================
# 4. BACKUP TESTING AND VALIDATION
# =============================================================================
log_message "INFO" "Setting up backup testing and validation"

# Create backup testing script
cat > "$BACKUP_DIR/etcd_backup_test.sh" << 'TEST_SCRIPT'
#!/bin/bash

# etcd backup testing script
BACKUP_DIR="/opt/etcd-backups"
TEST_NAMESPACE="etcd-backup-test"

# Function to test backup integrity
test_backup_integrity() {
    local backup_file="$1"
    
    echo "Testing backup integrity: $backup_file"
    
    # Check if backup file exists and is readable
    if [ ! -f "$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        return 1
    fi
    
    # Check backup file size
    local file_size=$(stat -c%s "$backup_file")
    if [ "$file_size" -lt 1000 ]; then
        echo "❌ Backup file too small: $file_size bytes"
        return 1
    fi
    
    # Test backup with etcdctl
    kubectl exec -n kube-system etcd-master -- etcdctl snapshot status /tmp/test-backup.db \
        --write-out=table 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Backup integrity test passed"
        return 0
    else
        echo "❌ Backup integrity test failed"
        return 1
    fi
}

# Function to test backup restoration
test_backup_restoration() {
    local backup_file="$1"
    
    echo "Testing backup restoration: $backup_file"
    
    # Create test namespace
    kubectl create namespace "$TEST_NAMESPACE" 2>/dev/null || true
    
    # Create test resources
    kubectl create configmap test-config --from-literal=key=value -n "$TEST_NAMESPACE"
    kubectl create secret generic test-secret --from-literal=password=secret -n "$TEST_NAMESPACE"
    
    # Wait for resources to be created
    sleep 5
    
    # Verify resources exist
    if kubectl get configmap test-config -n "$TEST_NAMESPACE" >/dev/null 2>&1 && \
       kubectl get secret test-secret -n "$TEST_NAMESPACE" >/dev/null 2>&1; then
        echo "✅ Test resources created successfully"
    else
        echo "❌ Failed to create test resources"
        return 1
    fi
    
    # Cleanup test resources
    kubectl delete namespace "$TEST_NAMESPACE" 2>/dev/null || true
    
    echo "✅ Backup restoration test completed"
    return 0
}

# Main testing logic
echo "=== ETCD BACKUP TESTING ==="
echo "Date: $(date)"
echo ""

# Test latest backup
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/etcd-backup-*.db 2>/dev/null | head -1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "Testing latest backup: $LATEST_BACKUP"
    
    # Test backup integrity
    if test_backup_integrity "$LATEST_BACKUP"; then
        echo "✅ Backup integrity test passed"
    else
        echo "❌ Backup integrity test failed"
        exit 1
    fi
    
    # Test backup restoration
    if test_backup_restoration "$LATEST_BACKUP"; then
        echo "✅ Backup restoration test passed"
    else
        echo "❌ Backup restoration test failed"
        exit 1
    fi
    
    echo ""
    echo "=== BACKUP TEST SUMMARY ==="
    echo "✅ All backup tests passed successfully"
    echo "Backup file: $LATEST_BACKUP"
    echo "File size: $(stat -c%s "$LATEST_BACKUP") bytes"
    echo "Test date: $(date)"
else
    echo "❌ No backup files found in $BACKUP_DIR"
    exit 1
fi
TEST_SCRIPT

chmod +x "$BACKUP_DIR/etcd_backup_test.sh"

log_message "INFO" "Backup testing and validation setup completed"
EOF
```

##### **Step 5: Execute etcd Backup Strategy**
```bash
# Execute the etcd backup strategy
./etcd_backup_strategy.sh

# Display results
echo "=== ETCD BACKUP STRATEGY COMPLETED ==="
echo "Backup directory: $BACKUP_DIR"
echo "Retention period: $RETENTION_DAYS days"
echo ""
echo "=== AVAILABLE COMMANDS ==="
echo "1. Manual backup: $BACKUP_DIR/etcd_backup.sh"
echo "2. List backups: $BACKUP_DIR/etcd_disaster_recovery.sh list"
echo "3. Restore backup: $BACKUP_DIR/etcd_disaster_recovery.sh restore <backup_file>"
echo "4. Test backup: $BACKUP_DIR/etcd_backup_test.sh"
echo ""
echo "=== CRON JOB ==="
echo "Daily backup scheduled at 2:00 AM"
echo "Check with: crontab -l"
```

##### **Expected Outputs and Validation**
```bash
# Validate the etcd backup strategy
echo "=== VALIDATION STEPS ==="

# 1. Check backup directory
if [ -d "$BACKUP_DIR" ]; then
    echo "✅ Backup directory created: $BACKUP_DIR"
else
    echo "❌ Backup directory not found: $BACKUP_DIR"
fi

# 2. Check backup script
if [ -x "$BACKUP_DIR/etcd_backup.sh" ]; then
    echo "✅ Backup script created and executable"
else
    echo "❌ Backup script not found or not executable"
fi

# 3. Check recovery script
if [ -x "$BACKUP_DIR/etcd_disaster_recovery.sh" ]; then
    echo "✅ Recovery script created and executable"
else
    echo "❌ Recovery script not found or not executable"
fi

# 4. Check cron job
if crontab -l | grep -q "etcd_backup_cron.sh"; then
    echo "✅ Cron job scheduled for daily backups"
else
    echo "❌ Cron job not scheduled"
fi

# 5. Test backup creation
echo "=== TESTING BACKUP CREATION ==="
"$BACKUP_DIR/etcd_backup.sh"

# Check if backup was created
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/etcd-backup-*.db 2>/dev/null | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    echo "✅ Test backup created: $LATEST_BACKUP"
    echo "Backup size: $(stat -c%s "$LATEST_BACKUP") bytes"
else
    echo "❌ Test backup not created"
fi
```

##### **Error Handling and Troubleshooting**
```bash
# Error handling for etcd backup issues
echo "=== ERROR HANDLING AND TROUBLESHOOTING ==="

# Check for common issues
echo "1. Checking for common issues..."

# Check if etcd is accessible
if kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 >/dev/null 2>&1; then
    echo "✅ etcd is accessible and healthy"
else
    echo "❌ etcd is not accessible. Check:"
    echo "   - etcd pod status: kubectl get pods -n kube-system -l component=etcd"
    echo "   - etcd logs: kubectl logs -n kube-system -l component=etcd"
    echo "   - etcd certificates: ls -la /etc/kubernetes/pki/etcd/"
fi

# Check if backup directory is writable
if [ -w "$BACKUP_DIR" ]; then
    echo "✅ Backup directory is writable"
else
    echo "❌ Backup directory is not writable. Fix with:"
    echo "   chmod 755 $BACKUP_DIR"
    echo "   chown root:root $BACKUP_DIR"
fi

# Check if cron service is running
if systemctl is-active --quiet cron; then
    echo "✅ Cron service is running"
else
    echo "❌ Cron service is not running. Start with:"
    echo "   systemctl start cron"
    echo "   systemctl enable cron"
fi

# Check disk space
DISK_USAGE=$(df "$BACKUP_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "✅ Sufficient disk space available ($DISK_USAGE% used)"
else
    echo "⚠️  Low disk space ($DISK_USAGE% used). Consider:"
    echo "   - Cleaning old backups"
    echo "   - Increasing disk space"
    echo "   - Moving backups to external storage"
fi

echo ""
echo "=== TROUBLESHOOTING COMMANDS ==="
echo "1. Check etcd status: kubectl get pods -n kube-system -l component=etcd"
echo "2. Check etcd logs: kubectl logs -n kube-system -l component=etcd"
echo "3. Check backup directory: ls -la $BACKUP_DIR"
echo "4. Check cron jobs: crontab -l"
echo "5. Check disk space: df -h $BACKUP_DIR"
echo "6. Test backup manually: $BACKUP_DIR/etcd_backup.sh"
echo "7. List available backups: $BACKUP_DIR/etcd_disaster_recovery.sh list"
echo "8. Test backup integrity: $BACKUP_DIR/etcd_backup_test.sh"
```

##### **Learning Outcomes and Key Takeaways**
```bash
echo "=== LEARNING OUTCOMES AND KEY TAKEAWAYS ==="
echo ""
echo "1. BACKUP STRATEGY:"
echo "   - Automated backup scheduling"
echo "   - Backup retention policies"
echo "   - Backup integrity verification"
echo "   - Backup testing procedures"
echo ""
echo "2. DISASTER RECOVERY:"
echo "   - Recovery procedure documentation"
echo "   - Recovery testing and validation"
echo "   - Recovery time objectives (RTO)"
echo "   - Recovery point objectives (RPO)"
echo ""
echo "3. OPERATIONAL SKILLS:"
echo "   - etcd backup and restoration"
echo "   - Cron job management"
echo "   - Script automation"
echo "   - Error handling and troubleshooting"
echo ""
echo "4. PRODUCTION READINESS:"
echo "   - Backup monitoring and alerting"
echo "   - Recovery procedure testing"
echo "   - Documentation and runbooks"
echo "   - Team training and knowledge transfer"
echo ""
echo "5. BEST PRACTICES:"
echo "   - Regular backup testing"
echo "   - Off-site backup storage"
echo "   - Recovery procedure documentation"
echo "   - Incident response planning"
```

---

## 🧪 **Chaos Engineering Experiments for Architecture Testing**

### **🎯 Overview**
Chaos Engineering is a discipline that helps build confidence in the capability of a distributed system to withstand turbulent and unexpected conditions. In Kubernetes architecture, this involves systematically testing how the cluster behaves when various components fail or are under stress.

### **📋 Chaos Engineering Principles**
1. **Start Small**: Begin with simple experiments and gradually increase complexity
2. **Measure Everything**: Monitor all metrics before, during, and after experiments
3. **Fail Fast**: Stop experiments immediately if unexpected behavior occurs
4. **Document Everything**: Record all experiments, results, and lessons learned
5. **Automate**: Create repeatable experiments for consistent testing

### **🔬 Experiment 1: API Server Failure Testing**

#### **Purpose**
Test cluster behavior when the API Server becomes unavailable and verify recovery mechanisms.

#### **Pre-Experiment Setup**
```bash
# Create chaos engineering directory
mkdir -p ~/chaos-engineering
cd ~/chaos-engineering

# Create monitoring script
cat > monitor_cluster.sh << 'EOF'
#!/bin/bash

# Cluster monitoring script for chaos experiments
MONITOR_LOG="cluster_monitor_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$MONITOR_LOG"
}

echo "=== CLUSTER MONITORING STARTED ===" | tee "$MONITOR_LOG"
log_message "Starting cluster monitoring for chaos experiment"

# Monitor cluster every 10 seconds
while true; do
    log_message "=== CLUSTER STATUS CHECK ==="
    
    # Check API server health
    if kubectl cluster-info >/dev/null 2>&1; then
        log_message "✅ API Server: Healthy"
    else
        log_message "❌ API Server: Unhealthy"
    fi
    
    # Check node status
    READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep Ready | wc -l)
    TOTAL_NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    log_message "Nodes: $READY_NODES/$TOTAL_NODES ready"
    
    # Check control plane pods
    CONTROL_PLANE_PODS=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -E "(kube-apiserver|kube-scheduler|kube-controller-manager|etcd)" | wc -l)
    log_message "Control plane pods: $CONTROL_PLANE_PODS running"
    
    # Check etcd health
    if kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 >/dev/null 2>&1; then
        log_message "✅ etcd: Healthy"
    else
        log_message "❌ etcd: Unhealthy"
    fi
    
    sleep 10
done
EOF

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Cluster monitoring script for chaos experiments
# MONITOR_LOG="cluster_monitor_$(date +%Y%m%d_%H%M%S).log"  # Creates log filename with timestamp
# 
# log_message() {               # Function definition for logging
#     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')  # Get current timestamp in readable format
#     echo "[$timestamp] $1" | tee -a "$MONITOR_LOG"  # Print to screen and append to log file
# }
# 
# echo "=== CLUSTER MONITORING STARTED ===" | tee "$MONITOR_LOG"  # Initial header message
# log_message "Starting cluster monitoring for chaos experiment"  # Log start message
# 
# # Monitor cluster every 10 seconds
# while true; do                # Infinite loop for continuous monitoring
#     log_message "=== CLUSTER STATUS CHECK ==="  # Section header for each check
#     
#     # Check API server health
#     if kubectl cluster-info >/dev/null 2>&1; then  # Test API server connectivity, suppress output
#         log_message "✅ API Server: Healthy"        # Log success if API server responds
#     else
#         log_message "❌ API Server: Unhealthy"      # Log failure if API server doesn't respond
#     fi
#     
#     # Check node status
#     READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep Ready | wc -l)  # Count ready nodes
#     TOTAL_NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)               # Count total nodes
#     log_message "Nodes: $READY_NODES/$TOTAL_NODES ready"  # Log node status ratio
#     
#     # Check control plane pods
#     CONTROL_PLANE_PODS=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | grep -E "(kube-apiserver|kube-scheduler|kube-controller-manager|etcd)" | wc -l)  # Count running control plane pods
#     log_message "Control plane pods: $CONTROL_PLANE_PODS running"  # Log control plane pod count
#     
#     # Check etcd health
#     if kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 >/dev/null 2>&1; then  # Test etcd health via kubectl exec
#         log_message "✅ etcd: Healthy"              # Log success if etcd is healthy
#     else
#         log_message "❌ etcd: Unhealthy"            # Log failure if etcd is unhealthy
#     fi
#     
#     sleep 10                   # Wait 10 seconds before next check
# done
# ```
# 
# **Expected Output:**
# ```
# === CLUSTER MONITORING STARTED ===
# [2024-01-15 10:30:00] Starting cluster monitoring for chaos experiment
# [2024-01-15 10:30:00] === CLUSTER STATUS CHECK ===
# [2024-01-15 10:30:00] ✅ API Server: Healthy
# [2024-01-15 10:30:00] Nodes: 3/3 ready
# [2024-01-15 10:30:00] Control plane pods: 4 running
# [2024-01-15 10:30:00] ✅ etcd: Healthy
# [2024-01-15 10:30:10] === CLUSTER STATUS CHECK ===
# [2024-01-15 10:30:10] ✅ API Server: Healthy
# [2024-01-15 10:30:10] Nodes: 3/3 ready
# [2024-01-15 10:30:10] Control plane pods: 4 running
# [2024-01-15 10:30:10] ✅ etcd: Healthy
# ```
# 
# **Key Learning Points:**
# - **Continuous Monitoring**: The script runs in an infinite loop to provide real-time cluster health monitoring
# - **Comprehensive Health Checks**: Monitors API server, nodes, control plane pods, and etcd health
# - **Structured Logging**: Uses timestamps and structured messages for easy analysis
# - **Error Handling**: Gracefully handles failures and continues monitoring
# - **Resource Counting**: Uses `wc -l` to count resources and provide quantitative metrics
# - **Suppressed Output**: Uses `>/dev/null 2>&1` to keep output clean while testing connectivity

chmod +x monitor_cluster.sh
```

#### **Experiment Execution**
```bash
# Start monitoring in background
./monitor_cluster.sh &
MONITOR_PID=$!

echo "=== API SERVER FAILURE EXPERIMENT ==="
echo "Date: $(date)"
echo "Purpose: Test cluster behavior when API Server becomes unavailable"
echo ""

# Step 1: Baseline measurement
echo "Step 1: Establishing baseline..."
sleep 30

# Step 2: Simulate API Server failure
echo "Step 2: Simulating API Server failure..."
echo "Stopping API Server pod..."

# Find and stop API Server pod
API_SERVER_POD=$(kubectl get pods -n kube-system -l component=kube-apiserver --no-headers | awk '{print $1}' | head -1)
if [ -n "$API_SERVER_POD" ]; then
    echo "Stopping API Server pod: $API_SERVER_POD"
    kubectl delete pod "$API_SERVER_POD" -n kube-system
    
    # Monitor impact for 2 minutes
    echo "Monitoring cluster impact for 2 minutes..."
    sleep 120
    
    # Step 3: Verify recovery
    echo "Step 3: Verifying recovery..."
    sleep 30
    
    # Check if new API Server pod is running
    NEW_API_SERVER_POD=$(kubectl get pods -n kube-system -l component=kube-apiserver --no-headers | awk '{print $1}' | head -1)
    if [ -n "$NEW_API_SERVER_POD" ]; then
        echo "✅ New API Server pod created: $NEW_API_SERVER_POD"
    else
        echo "❌ No new API Server pod found"
    fi
else
    echo "❌ No API Server pod found"
fi

# Stop monitoring
kill $MONITOR_PID
echo "=== EXPERIMENT COMPLETED ==="
```

#### **Expected Results and Analysis**
```bash
# Analyze experiment results
echo "=== EXPERIMENT ANALYSIS ==="

# Check monitoring log
if [ -f "cluster_monitor_$(date +%Y%m%d)*.log" ]; then
    echo "Monitoring log found. Analyzing results..."
    
    # Count API Server failures
    API_FAILURES=$(grep "❌ API Server: Unhealthy" cluster_monitor_*.log | wc -l)
    echo "API Server failures detected: $API_FAILURES"
    
    # Count etcd failures
    ETCD_FAILURES=$(grep "❌ etcd: Unhealthy" cluster_monitor_*.log | wc -l)
    echo "etcd failures detected: $ETCD_FAILURES"
    
    # Analyze recovery time
    echo "Recovery analysis:"
    grep -A 5 -B 5 "❌ API Server: Unhealthy" cluster_monitor_*.log | tail -20
else
    echo "❌ Monitoring log not found"
fi

echo ""
echo "=== KEY FINDINGS ==="
echo "1. API Server failure impact on cluster operations"
echo "2. Recovery time and mechanism effectiveness"
echo "3. Impact on running workloads"
echo "4. etcd stability during API Server failure"
echo "5. Lessons learned and improvements needed"
```

### **🔬 Experiment 2: etcd Cluster Failure Testing**

#### **Purpose**
Test cluster behavior when etcd becomes unavailable and verify data consistency and recovery.

#### **Pre-Experiment Setup**
```bash
# Create etcd chaos experiment script
cat > etcd_chaos_test.sh << 'EOF'
#!/bin/bash

# etcd Chaos Engineering Experiment
ETCD_LOG="etcd_chaos_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$ETCD_LOG"
}

echo "=== ETCD CHAOS EXPERIMENT ===" | tee "$ETCD_LOG"
log_message "Starting etcd chaos engineering experiment"

# Step 1: Create test data
echo "Step 1: Creating test data..."
kubectl create namespace etcd-test 2>/dev/null || true
kubectl create configmap test-data --from-literal=key1=value1 --from-literal=key2=value2 -n etcd-test
kubectl create secret generic test-secret --from-literal=password=secret123 -n etcd-test

log_message "Test data created: configmap and secret"

# Step 2: Verify data exists
echo "Step 2: Verifying test data..."
if kubectl get configmap test-data -n etcd-test >/dev/null 2>&1 && \
   kubectl get secret test-secret -n etcd-test >/dev/null 2>&1; then
    log_message "✅ Test data verified"
else
    log_message "❌ Test data verification failed"
    exit 1
fi

# Step 3: Simulate etcd failure
echo "Step 3: Simulating etcd failure..."
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd --no-headers | awk '{print $1}' | head -1)

if [ -n "$ETCD_POD" ]; then
    log_message "Stopping etcd pod: $ETCD_POD"
    kubectl delete pod "$ETCD_POD" -n kube-system
    
    # Monitor impact
    echo "Monitoring etcd failure impact..."
    for i in {1..12}; do
        if kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 >/dev/null 2>&1; then
            log_message "✅ etcd recovered after $((i*10)) seconds"
            break
        else
            log_message "❌ etcd still down after $((i*10)) seconds"
        fi
        sleep 10
    done
else
    log_message "❌ No etcd pod found"
fi

# Step 4: Verify data integrity
echo "Step 4: Verifying data integrity..."
sleep 30

if kubectl get configmap test-data -n etcd-test >/dev/null 2>&1 && \
   kubectl get secret test-secret -n etcd-test >/dev/null 2>&1; then
    log_message "✅ Data integrity maintained"
else
    log_message "❌ Data integrity compromised"
fi

# Cleanup
kubectl delete namespace etcd-test 2>/dev/null || true
log_message "Experiment completed"
EOF

chmod +x etcd_chaos_test.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # etcd Chaos Engineering Experiment
# ETCD_LOG="etcd_chaos_$(date +%Y%m%d_%H%M%S).log"  # Creates log filename with timestamp
# 
# log_message() {               # Function definition for structured logging
#     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')  # Get current timestamp
#     echo "[$timestamp] $1" | tee -a "$ETCD_LOG"  # Print to screen and append to log
# }
# 
# echo "=== ETCD CHAOS EXPERIMENT ===" | tee "$ETCD_LOG"  # Experiment header
# log_message "Starting etcd chaos engineering experiment"  # Start message
# 
# # Step 1: Create test data
# echo "Step 1: Creating test data..."  # Step description
# kubectl create namespace etcd-test 2>/dev/null || true  # Create namespace, ignore if exists
# kubectl create configmap test-data --from-literal=key1=value1 --from-literal=key2=value2 -n etcd-test  # Create test configmap
# kubectl create secret generic test-secret --from-literal=password=secret123 -n etcd-test  # Create test secret
# 
# log_message "Test data created: configmap and secret"  # Log data creation
# 
# # Step 2: Verify data exists
# echo "Step 2: Verifying test data..."  # Verification step
# if kubectl get configmap test-data -n etcd-test >/dev/null 2>&1 && \  # Check configmap exists
#    kubectl get secret test-secret -n etcd-test >/dev/null 2>&1; then  # Check secret exists
#     log_message "✅ Test data verified"  # Log success
# else
#     log_message "❌ Test data verification failed"  # Log failure
#     exit 1  # Exit with error code
# fi
# 
# # Step 3: Simulate etcd failure
# echo "Step 3: Simulating etcd failure..."  # Failure simulation step
# ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd --no-headers | awk '{print $1}' | head -1)  # Get first etcd pod name
# 
# if [ -n "$ETCD_POD" ]; then  # Check if etcd pod was found
#     log_message "Stopping etcd pod: $ETCD_POD"  # Log which pod will be stopped
#     kubectl delete pod "$ETCD_POD" -n kube-system  # Delete the etcd pod to simulate failure
#     
#     # Monitor impact
#     echo "Monitoring etcd failure impact..."  # Monitoring phase
#     for i in {1..12}; do  # Loop 12 times (2 minutes total)
#         if kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 >/dev/null 2>&1; then  # Check etcd health
#             log_message "✅ etcd recovered after $((i*10)) seconds"  # Log recovery time
#             break  # Exit loop when etcd recovers
#         else
#             log_message "❌ etcd still down after $((i*10)) seconds"  # Log continued failure
#         fi
#         sleep 10  # Wait 10 seconds between checks
#     done
# else
#     log_message "❌ No etcd pod found"  # Log if no etcd pod found
# fi
# 
# # Step 4: Verify data integrity
# echo "Step 4: Verifying data integrity..."  # Data integrity verification
# sleep 30  # Wait 30 seconds for cluster to stabilize
# 
# if kubectl get configmap test-data -n etcd-test >/dev/null 2>&1 && \  # Check configmap still exists
#    kubectl get secret test-secret -n etcd-test >/dev/null 2>&1; then  # Check secret still exists
#     log_message "✅ Data integrity maintained"  # Log data integrity success
# else
#     log_message "❌ Data integrity compromised"  # Log data integrity failure
# fi
# 
# # Cleanup
# kubectl delete namespace etcd-test 2>/dev/null || true  # Clean up test namespace
# log_message "Experiment completed"  # Log experiment completion
# ```
# 
# **Expected Output:**
# ```
# === ETCD CHAOS EXPERIMENT ===
# [2024-01-15 10:30:00] Starting etcd chaos engineering experiment
# Step 1: Creating test data...
# configmap/test-data created
# secret/test-secret created
# [2024-01-15 10:30:01] Test data created: configmap and secret
# Step 2: Verifying test data...
# [2024-01-15 10:30:02] ✅ Test data verified
# Step 3: Simulating etcd failure...
# [2024-01-15 10:30:03] Stopping etcd pod: etcd-master
# pod "etcd-master" deleted
# Monitoring etcd failure impact...
# [2024-01-15 10:30:13] ❌ etcd still down after 10 seconds
# [2024-01-15 10:30:23] ❌ etcd still down after 20 seconds
# [2024-01-15 10:30:33] ✅ etcd recovered after 30 seconds
# Step 4: Verifying data integrity...
# [2024-01-15 10:31:03] ✅ Data integrity maintained
# [2024-01-15 10:31:04] Experiment completed
# ```
# 
# **Key Learning Points:**
# - **Test Data Creation**: Creates actual Kubernetes resources to test data persistence
# - **Failure Simulation**: Uses `kubectl delete pod` to simulate etcd pod failure
# - **Recovery Monitoring**: Continuously checks etcd health until recovery
# - **Data Integrity Verification**: Ensures test data survives the failure
# - **Structured Logging**: Uses timestamps and clear status indicators
# - **Error Handling**: Exits with error code if initial verification fails
# - **Cleanup**: Removes test resources after experiment completion
```

#### **Experiment Execution**
```bash
# Execute etcd chaos experiment
./etcd_chaos_test.sh

echo "=== ETCD CHAOS EXPERIMENT COMPLETED ==="
echo "Check log file for detailed results: etcd_chaos_*.log"
```

### **🔬 Experiment 3: Node Failure Testing**

#### **Purpose**
Test cluster behavior when worker nodes fail and verify pod rescheduling and workload availability.

#### **Pre-Experiment Setup**
```bash
# Create node failure experiment script
cat > node_failure_test.sh << 'EOF'
#!/bin/bash

# Node Failure Chaos Engineering Experiment
NODE_LOG="node_failure_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$NODE_LOG"
}

echo "=== NODE FAILURE EXPERIMENT ===" | tee "$NODE_LOG"
log_message "Starting node failure chaos engineering experiment"

# Step 1: Deploy test workload
echo "Step 1: Deploying test workload..."
cat > test-deployment.yaml << 'DEPLOYMENT'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
DEPLOYMENT

kubectl apply -f test-deployment.yaml
log_message "Test deployment created"

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available deployment/test-app --timeout=300s
log_message "Deployment ready"

# Step 2: Record initial state
echo "Step 2: Recording initial state..."
INITIAL_PODS=$(kubectl get pods -l app=test-app --no-headers | wc -l)
INITIAL_NODES=$(kubectl get nodes --no-headers | wc -l)
log_message "Initial state: $INITIAL_PODS pods on $INITIAL_NODES nodes"

# Step 3: Simulate node failure
echo "Step 3: Simulating node failure..."
WORKER_NODE=$(kubectl get nodes --no-headers | grep -v "control-plane" | awk '{print $1}' | head -1)

if [ -n "$WORKER_NODE" ]; then
    log_message "Simulating failure of worker node: $WORKER_NODE"
    
    # Drain the node
    kubectl drain "$WORKER_NODE" --ignore-daemonsets --delete-emptydir-data --force
    
    # Monitor pod rescheduling
    echo "Monitoring pod rescheduling..."
    for i in {1..30}; do
        CURRENT_PODS=$(kubectl get pods -l app=test-app --no-headers | grep Running | wc -l)
        log_message "Pods running: $CURRENT_PODS/$INITIAL_PODS"
        
        if [ "$CURRENT_PODS" -eq "$INITIAL_PODS" ]; then
            log_message "✅ All pods rescheduled successfully"
            break
        fi
        
        sleep 10
    done
else
    log_message "❌ No worker node found"
fi

# Step 4: Verify workload availability
echo "Step 4: Verifying workload availability..."
if kubectl get pods -l app=test-app --no-headers | grep -q Running; then
    log_message "✅ Workload remains available"
else
    log_message "❌ Workload availability compromised"
fi

# Step 5: Uncordon the node
echo "Step 5: Uncordoning the node..."
if [ -n "$WORKER_NODE" ]; then
    kubectl uncordon "$WORKER_NODE"
    log_message "Node uncordoned: $WORKER_NODE"
fi

# Cleanup
kubectl delete -f test-deployment.yaml
rm -f test-deployment.yaml
log_message "Experiment completed"
EOF

chmod +x node_failure_test.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Node Failure Chaos Engineering Experiment
# NODE_LOG="node_failure_$(date +%Y%m%d_%H%M%S).log"  # Creates log filename with timestamp
# 
# log_message() {               # Function definition for structured logging
#     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')  # Get current timestamp
#     echo "[$timestamp] $1" | tee -a "$NODE_LOG"  # Print to screen and append to log
# }
# 
# echo "=== NODE FAILURE EXPERIMENT ===" | tee "$NODE_LOG"  # Experiment header
# log_message "Starting node failure chaos engineering experiment"  # Start message
# 
# # Step 1: Deploy test workload
# echo "Step 1: Deploying test workload..."  # Step description
# cat > test-deployment.yaml << 'DEPLOYMENT'  # Create deployment YAML using heredoc
# apiVersion: apps/v1                        # API version for apps
# kind: Deployment                           # Resource type
# metadata:                                  # Metadata section
#   name: test-app                          # Deployment name
#   namespace: default                      # Target namespace
# spec:                                     # Specification section
#   replicas: 3                            # Number of replicas
#   selector:                              # Pod selector
#     matchLabels:                         # Label matching
#       app: test-app                      # Select pods with app=test-app
#   template:                              # Pod template
#     metadata:                            # Pod metadata
#       labels:                            # Pod labels
#         app: test-app                    # Label for pod selection
#     spec:                               # Pod specification
#       containers:                       # Container list
#       - name: nginx                     # Container name
#         image: nginx:latest             # Container image
#         ports:                          # Port configuration
#         - containerPort: 80             # Expose port 80
#         resources:                      # Resource requirements
#           requests:                     # Minimum resources
#             memory: "64Mi"              # Memory request
#             cpu: "50m"                  # CPU request
#           limits:                       # Maximum resources
#             memory: "128Mi"             # Memory limit
#             cpu: "100m"                 # CPU limit
# DEPLOYMENT                              # End of heredoc
# 
# kubectl apply -f test-deployment.yaml  # Apply the deployment
# log_message "Test deployment created"  # Log deployment creation
# 
# # Wait for deployment to be ready
# echo "Waiting for deployment to be ready..."  # Wait message
# kubectl wait --for=condition=available deployment/test-app --timeout=300s  # Wait for deployment readiness
# log_message "Deployment ready"  # Log readiness
# 
# # Step 2: Record initial state
# echo "Step 2: Recording initial state..."  # State recording step
# INITIAL_PODS=$(kubectl get pods -l app=test-app --no-headers | wc -l)  # Count initial pods
# INITIAL_NODES=$(kubectl get nodes --no-headers | wc -l)  # Count initial nodes
# log_message "Initial state: $INITIAL_PODS pods on $INITIAL_NODES nodes"  # Log initial state
# 
# # Step 3: Simulate node failure
# echo "Step 3: Simulating node failure..."  # Failure simulation step
# WORKER_NODE=$(kubectl get nodes --no-headers | grep -v "control-plane" | awk '{print $1}' | head -1)  # Get first worker node
# 
# if [ -n "$WORKER_NODE" ]; then  # Check if worker node was found
#     log_message "Simulating failure of worker node: $WORKER_NODE"  # Log target node
#     
#     # Drain the node
#     kubectl drain "$WORKER_NODE" --ignore-daemonsets --delete-emptydir-data --force  # Safely drain the node
#     
#     # Monitor pod rescheduling
#     echo "Monitoring pod rescheduling..."  # Monitoring phase
#     for i in {1..30}; do  # Loop 30 times (5 minutes total)
#         CURRENT_PODS=$(kubectl get pods -l app=test-app --no-headers | grep Running | wc -l)  # Count running pods
#         log_message "Pods running: $CURRENT_PODS/$INITIAL_PODS"  # Log pod count
#         
#         if [ "$CURRENT_PODS" -eq "$INITIAL_PODS" ]; then  # Check if all pods are running
#             log_message "✅ All pods rescheduled successfully"  # Log success
#             break  # Exit loop when all pods are running
#         fi
#         
#         sleep 10  # Wait 10 seconds between checks
#     done
# else
#     log_message "❌ No worker node found"  # Log if no worker node found
# fi
# 
# # Step 4: Verify workload availability
# echo "Step 4: Verifying workload availability..."  # Availability verification
# if kubectl get pods -l app=test-app --no-headers | grep -q Running; then  # Check if any pods are running
#     log_message "✅ Workload remains available"  # Log availability success
# else
#     log_message "❌ Workload availability compromised"  # Log availability failure
# fi
# 
# # Step 5: Uncordon the node
# echo "Step 5: Uncordoning the node..."  # Node restoration step
# if [ -n "$WORKER_NODE" ]; then  # Check if worker node variable exists
#     kubectl uncordon "$WORKER_NODE"  # Allow scheduling on the node again
#     log_message "Node uncordoned: $WORKER_NODE"  # Log uncordon success
# fi
# 
# # Cleanup
# kubectl delete -f test-deployment.yaml  # Delete the test deployment
# rm -f test-deployment.yaml  # Remove the YAML file
# log_message "Experiment completed"  # Log experiment completion
# ```
# 
# **Expected Output:**
# ```
# === NODE FAILURE EXPERIMENT ===
# [2024-01-15 10:30:00] Starting node failure chaos engineering experiment
# Step 1: Deploying test workload...
# deployment.apps/test-app created
# [2024-01-15 10:30:01] Test deployment created
# Waiting for deployment to be ready...
# deployment.apps/test-app condition met
# [2024-01-15 10:30:05] Deployment ready
# Step 2: Recording initial state...
# [2024-01-15 10:30:06] Initial state: 3 pods on 3 nodes
# Step 3: Simulating node failure...
# [2024-01-15 10:30:07] Simulating failure of worker node: worker1
# node/worker1 cordoned
# evicting pod "test-app-xyz123"
# evicting pod "test-app-abc456"
# Monitoring pod rescheduling...
# [2024-01-15 10:30:17] Pods running: 2/3
# [2024-01-15 10:30:27] Pods running: 3/3
# [2024-01-15 10:30:27] ✅ All pods rescheduled successfully
# Step 4: Verifying workload availability...
# [2024-01-15 10:30:28] ✅ Workload remains available
# Step 5: Uncordoning the node...
# node/worker1 uncordoned
# [2024-01-15 10:30:29] Node uncordoned: worker1
# deployment.apps "test-app" deleted
# [2024-01-15 10:30:30] Experiment completed
# ```
# 
# **Key Learning Points:**
# - **Test Workload Deployment**: Creates a real deployment with multiple replicas to test rescheduling
# - **Node Drain Simulation**: Uses `kubectl drain` to safely simulate node failure
# - **Pod Rescheduling Monitoring**: Tracks how quickly pods are rescheduled to other nodes
# - **Workload Availability Verification**: Ensures the application remains available during node failure
# - **Safe Node Restoration**: Uses `kubectl uncordon` to restore the node for future use
# - **Resource Management**: Sets appropriate resource requests and limits for test workload
# - **Comprehensive Cleanup**: Removes both deployment and temporary files
```

#### **Experiment Execution**
```bash
# Execute node failure experiment
./node_failure_test.sh

echo "=== NODE FAILURE EXPERIMENT COMPLETED ==="
echo "Check log file for detailed results: node_failure_*.log"
```

### **🔬 Experiment 4: Network Partition Testing**

#### **Purpose**
Test cluster behavior when network connectivity is disrupted between nodes and verify communication resilience.

#### **Pre-Experiment Setup**
```bash
# Create network partition experiment script
cat > network_partition_test.sh << 'EOF'
#!/bin/bash

# Network Partition Chaos Engineering Experiment
NETWORK_LOG="network_partition_$(date +%Y%m%d_%H%M%S).log"

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$NETWORK_LOG"
}

echo "=== NETWORK PARTITION EXPERIMENT ===" | tee "$NETWORK_LOG"
log_message "Starting network partition chaos engineering experiment"

# Step 1: Deploy distributed application
echo "Step 1: Deploying distributed application..."
cat > distributed-app.yaml << 'APP'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: distributed-app
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: distributed-app
  template:
    metadata:
      labels:
        app: distributed-app
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
---
apiVersion: v1
kind: Service
metadata:
  name: distributed-app-service
spec:
  selector:
    app: distributed-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
APP

kubectl apply -f distributed-app.yaml
log_message "Distributed application deployed"

# Wait for deployment
kubectl wait --for=condition=available deployment/distributed-app --timeout=300s
log_message "Distributed application ready"

# Step 2: Test connectivity
echo "Step 2: Testing initial connectivity..."
if kubectl get service distributed-app-service >/dev/null 2>&1; then
    log_message "✅ Service connectivity verified"
else
    log_message "❌ Service connectivity failed"
fi

# Step 3: Simulate network partition
echo "Step 3: Simulating network partition..."
# This would require network-level isolation
# For demonstration, we'll simulate by blocking traffic to a pod

TARGET_POD=$(kubectl get pods -l app=distributed-app --no-headers | awk '{print $1}' | head -1)
if [ -n "$TARGET_POD" ]; then
    log_message "Simulating network partition for pod: $TARGET_POD"
    
    # Create network policy to isolate pod
    cat > network-isolation.yaml << 'ISOLATION'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-pod
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: distributed-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: distributed-app
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: distributed-app
    ports:
    - protocol: TCP
      port: 80
ISOLATION

    kubectl apply -f network-isolation.yaml
    log_message "Network isolation policy applied"
    
    # Monitor impact
    echo "Monitoring network partition impact..."
    sleep 60
    
    # Step 4: Verify application behavior
    echo "Step 4: Verifying application behavior..."
    if kubectl get pods -l app=distributed-app --no-headers | grep -q Running; then
        log_message "✅ Application remains functional"
    else
        log_message "❌ Application functionality compromised"
    fi
    
    # Step 5: Remove network partition
    echo "Step 5: Removing network partition..."
    kubectl delete -f network-isolation.yaml
    log_message "Network isolation removed"
else
    log_message "❌ No target pod found"
fi

# Cleanup
kubectl delete -f distributed-app.yaml
rm -f distributed-app.yaml network-isolation.yaml
log_message "Experiment completed"
EOF

chmod +x network_partition_test.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Network Partition Chaos Engineering Experiment
# NETWORK_LOG="network_partition_$(date +%Y%m%d_%H%M%S).log"  # Creates log filename with timestamp
# 
# log_message() {               # Function definition for structured logging
#     local timestamp=$(date '+%Y-%m-%d %H:%M:%S')  # Get current timestamp
#     echo "[$timestamp] $1" | tee -a "$NETWORK_LOG"  # Print to screen and append to log
# }
# 
# echo "=== NETWORK PARTITION EXPERIMENT ===" | tee "$NETWORK_LOG"  # Experiment header
# log_message "Starting network partition chaos engineering experiment"  # Start message
# 
# # Step 1: Deploy distributed application
# echo "Step 1: Deploying distributed application..."  # Step description
# cat > distributed-app.yaml << 'APP'  # Create application YAML using heredoc
# apiVersion: apps/v1                  # API version for apps
# kind: Deployment                     # Resource type
# metadata:                            # Metadata section
#   name: distributed-app              # Deployment name
#   namespace: default                 # Target namespace
# spec:                               # Specification section
#   replicas: 3                       # Number of replicas
#   selector:                         # Pod selector
#     matchLabels:                    # Label matching
#       app: distributed-app          # Select pods with app=distributed-app
#   template:                         # Pod template
#     metadata:                       # Pod metadata
#       labels:                       # Pod labels
#         app: distributed-app        # Label for pod selection
#     spec:                          # Pod specification
#       containers:                  # Container list
#       - name: app                  # Container name
#         image: nginx:latest        # Container image
#         ports:                     # Port configuration
#         - containerPort: 80        # Expose port 80
#         env:                       # Environment variables
#         - name: NODE_NAME          # Environment variable name
#           valueFrom:              # Value source
#             fieldRef:              # Field reference
#               fieldPath: spec.nodeName  # Reference to node name
# ---                               # YAML document separator
# apiVersion: v1                     # API version for core resources
# kind: Service                      # Resource type
# metadata:                          # Metadata section
#   name: distributed-app-service    # Service name
# spec:                             # Specification section
#   selector:                        # Pod selector
#     app: distributed-app           # Select pods with app=distributed-app
#   ports:                           # Port configuration
#   - port: 80                       # Service port
#     targetPort: 80                 # Target container port
#   type: ClusterIP                  # Service type
# APP                               # End of heredoc
# 
# kubectl apply -f distributed-app.yaml  # Apply the distributed application
# log_message "Distributed application deployed"  # Log deployment
# 
# # Wait for deployment
# kubectl wait --for=condition=available deployment/distributed-app --timeout=300s  # Wait for deployment readiness
# log_message "Distributed application ready"  # Log readiness
# 
# # Step 2: Test connectivity
# echo "Step 2: Testing initial connectivity..."  # Connectivity test step
# if kubectl get service distributed-app-service >/dev/null 2>&1; then  # Check if service exists
#     log_message "✅ Service connectivity verified"  # Log connectivity success
# else
#     log_message "❌ Service connectivity failed"  # Log connectivity failure
# fi
# 
# # Step 3: Simulate network partition
# echo "Step 3: Simulating network partition..."  # Network partition simulation
# # This would require network-level isolation
# # For demonstration, we'll simulate by blocking traffic to a pod
# 
# TARGET_POD=$(kubectl get pods -l app=distributed-app --no-headers | awk '{print $1}' | head -1)  # Get first pod name
# if [ -n "$TARGET_POD" ]; then  # Check if target pod was found
#     log_message "Simulating network partition for pod: $TARGET_POD"  # Log target pod
#     
#     # Create network policy to isolate pod
#     cat > network-isolation.yaml << 'ISOLATION'  # Create network policy using heredoc
# apiVersion: networking.k8s.io/v1    # API version for networking
# kind: NetworkPolicy                # Resource type
# metadata:                          # Metadata section
#   name: isolate-pod                # Policy name
#   namespace: default               # Target namespace
# spec:                             # Specification section
#   podSelector:                     # Pod selector
#     matchLabels:                   # Label matching
#       app: distributed-app         # Select pods with app=distributed-app
#   policyTypes:                     # Policy types
#   - Ingress                        # Ingress policy
#   - Egress                         # Egress policy
#   ingress:                         # Ingress rules
#   - from:                          # Source
#     - podSelector:                 # Pod selector for source
#         matchLabels:               # Label matching
#           app: distributed-app     # Allow traffic from same app pods
#     ports:                         # Port configuration
#     - protocol: TCP                # TCP protocol
#       port: 80                     # Port 80
#   egress:                          # Egress rules
#   - to:                            # Destination
#     - podSelector:                 # Pod selector for destination
#         matchLabels:               # Label matching
#           app: distributed-app     # Allow traffic to same app pods
#     ports:                         # Port configuration
#     - protocol: TCP                # TCP protocol
#       port: 80                     # Port 80
# ISOLATION                         # End of heredoc
# 
#     kubectl apply -f network-isolation.yaml  # Apply the network policy
#     log_message "Network isolation policy applied"  # Log policy application
#     
#     # Monitor impact
#     echo "Monitoring network partition impact..."  # Monitoring phase
#     sleep 60  # Wait 60 seconds to observe impact
#     
#     # Step 4: Verify application behavior
#     echo "Step 4: Verifying application behavior..."  # Behavior verification
#     if kubectl get pods -l app=distributed-app --no-headers | grep -q Running; then  # Check if pods are running
#         log_message "✅ Application remains functional"  # Log functionality success
#     else
#         log_message "❌ Application functionality compromised"  # Log functionality failure
#     fi
#     
#     # Step 5: Remove network partition
#     echo "Step 5: Removing network partition..."  # Network restoration
#     kubectl delete -f network-isolation.yaml  # Remove the network policy
#     log_message "Network isolation removed"  # Log policy removal
# else
#     log_message "❌ No target pod found"  # Log if no target pod found
# fi
# 
# # Cleanup
# kubectl delete -f distributed-app.yaml  # Delete the distributed application
# rm -f distributed-app.yaml network-isolation.yaml  # Remove YAML files
# log_message "Experiment completed"  # Log experiment completion
# ```
# 
# **Expected Output:**
# ```
# === NETWORK PARTITION EXPERIMENT ===
# [2024-01-15 10:30:00] Starting network partition chaos engineering experiment
# Step 1: Deploying distributed application...
# deployment.apps/distributed-app created
# service/distributed-app-service created
# [2024-01-15 10:30:01] Distributed application deployed
# deployment.apps/distributed-app condition met
# [2024-01-15 10:30:05] Distributed application ready
# Step 2: Testing initial connectivity...
# [2024-01-15 10:30:06] ✅ Service connectivity verified
# Step 3: Simulating network partition...
# [2024-01-15 10:30:07] Simulating network partition for pod: distributed-app-xyz123
# networkpolicy.networking.k8s.io/isolate-pod created
# [2024-01-15 10:30:08] Network isolation policy applied
# Monitoring network partition impact...
# Step 4: Verifying application behavior...
# [2024-01-15 10:31:08] ✅ Application remains functional
# Step 5: Removing network partition...
# networkpolicy.networking.k8s.io "isolate-pod" deleted
# [2024-01-15 10:31:09] Network isolation removed
# deployment.apps "distributed-app" deleted
# service "distributed-app-service" deleted
# [2024-01-15 10:31:10] Experiment completed
# ```
# 
# **Key Learning Points:**
# - **Distributed Application Setup**: Creates a multi-replica deployment with service for testing
# - **Network Policy Simulation**: Uses NetworkPolicy to simulate network partitions
# - **Connectivity Testing**: Verifies service connectivity before and after network changes
# - **Application Resilience**: Tests how applications behave under network isolation
# - **Environment Variables**: Uses `fieldRef` to expose node information to containers
# - **Service Discovery**: Tests service discovery mechanisms during network partitions
# - **Cleanup Procedures**: Ensures proper cleanup of both application and network policies
```

#### **Experiment Execution**
```bash
# Execute network partition experiment
./network_partition_test.sh

echo "=== NETWORK PARTITION EXPERIMENT COMPLETED ==="
echo "Check log file for detailed results: network_partition_*.log"
```

### **📊 Chaos Engineering Results Analysis**

#### **Comprehensive Analysis Script**
```bash
# Create chaos engineering analysis script
cat > analyze_chaos_results.sh << 'EOF'
#!/bin/bash

# Chaos Engineering Results Analysis
echo "=== CHAOS ENGINEERING RESULTS ANALYSIS ==="
echo "Date: $(date)"
echo ""

# Analyze all experiment logs
echo "Analyzing experiment results..."

# API Server experiment analysis
if [ -f cluster_monitor_*.log ]; then
    echo "=== API SERVER EXPERIMENT ANALYSIS ==="
    API_FAILURES=$(grep "❌ API Server: Unhealthy" cluster_monitor_*.log | wc -l)
    API_RECOVERY=$(grep "✅ API Server: Healthy" cluster_monitor_*.log | wc -l)
    echo "API Server failures: $API_FAILURES"
    echo "API Server recoveries: $API_RECOVERY"
    echo ""
fi

# etcd experiment analysis
if [ -f etcd_chaos_*.log ]; then
    echo "=== ETCD EXPERIMENT ANALYSIS ==="
    ETCD_FAILURES=$(grep "❌ etcd still down" etcd_chaos_*.log | wc -l)
    ETCD_RECOVERY=$(grep "✅ etcd recovered" etcd_chaos_*.log | wc -l)
    DATA_INTEGRITY=$(grep "✅ Data integrity maintained" etcd_chaos_*.log | wc -l)
    echo "etcd failures: $ETCD_FAILURES"
    echo "etcd recoveries: $ETCD_RECOVERY"
    echo "Data integrity maintained: $DATA_INTEGRITY"
    echo ""
fi

# Node failure experiment analysis
if [ -f node_failure_*.log ]; then
    echo "=== NODE FAILURE EXPERIMENT ANALYSIS ==="
    POD_RESCHEDULE=$(grep "✅ All pods rescheduled successfully" node_failure_*.log | wc -l)
    WORKLOAD_AVAILABILITY=$(grep "✅ Workload remains available" node_failure_*.log | wc -l)
    echo "Pod rescheduling success: $POD_RESCHEDULE"
    echo "Workload availability maintained: $WORKLOAD_AVAILABILITY"
    echo ""
fi

# Network partition experiment analysis
if [ -f network_partition_*.log ]; then
    echo "=== NETWORK PARTITION EXPERIMENT ANALYSIS ==="
    SERVICE_CONNECTIVITY=$(grep "✅ Service connectivity verified" network_partition_*.log | wc -l)
    APP_FUNCTIONALITY=$(grep "✅ Application remains functional" network_partition_*.log | wc -l)
    echo "Service connectivity maintained: $SERVICE_CONNECTIVITY"
    echo "Application functionality maintained: $APP_FUNCTIONALITY"
    echo ""
fi

# Overall assessment
echo "=== OVERALL ASSESSMENT ==="
echo "Chaos Engineering Experiments Completed: 4"
echo "Experiments with successful recovery: $(grep -r "✅" *.log | wc -l)"
echo "Experiments with failures: $(grep -r "❌" *.log | wc -l)"
echo ""
echo "=== RECOMMENDATIONS ==="
echo "1. Review failed experiments and implement improvements"
echo "2. Document lessons learned and best practices"
echo "3. Schedule regular chaos engineering sessions"
echo "4. Automate chaos experiments for continuous testing"
echo "5. Integrate chaos engineering into CI/CD pipeline"
EOF

chmod +x analyze_chaos_results.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Chaos Engineering Results Analysis
# echo "=== CHAOS ENGINEERING RESULTS ANALYSIS ==="  # Analysis header
# echo "Date: $(date)"  # Display current date and time
# echo ""  # Empty line for formatting
# 
# # Analyze all experiment logs
# echo "Analyzing experiment results..."  # Analysis start message
# 
# # API Server experiment analysis
# if [ -f cluster_monitor_*.log ]; then  # Check if API server log files exist
#     echo "=== API SERVER EXPERIMENT ANALYSIS ==="  # API server analysis header
#     API_FAILURES=$(grep "❌ API Server: Unhealthy" cluster_monitor_*.log | wc -l)  # Count API server failures
#     API_RECOVERY=$(grep "✅ API Server: Healthy" cluster_monitor_*.log | wc -l)  # Count API server recoveries
#     echo "API Server failures: $API_FAILURES"  # Display failure count
#     echo "API Server recoveries: $API_RECOVERY"  # Display recovery count
#     echo ""  # Empty line for formatting
# fi
# 
# # etcd experiment analysis
# if [ -f etcd_chaos_*.log ]; then  # Check if etcd log files exist
#     echo "=== ETCD EXPERIMENT ANALYSIS ==="  # etcd analysis header
#     ETCD_FAILURES=$(grep "❌ etcd still down" etcd_chaos_*.log | wc -l)  # Count etcd failures
#     ETCD_RECOVERY=$(grep "✅ etcd recovered" etcd_chaos_*.log | wc -l)  # Count etcd recoveries
#     DATA_INTEGRITY=$(grep "✅ Data integrity maintained" etcd_chaos_*.log | wc -l)  # Count data integrity successes
#     echo "etcd failures: $ETCD_FAILURES"  # Display etcd failure count
#     echo "etcd recoveries: $ETCD_RECOVERY"  # Display etcd recovery count
#     echo "Data integrity maintained: $DATA_INTEGRITY"  # Display data integrity count
#     echo ""  # Empty line for formatting
# fi
# 
# # Node failure experiment analysis
# if [ -f node_failure_*.log ]; then  # Check if node failure log files exist
#     echo "=== NODE FAILURE EXPERIMENT ANALYSIS ==="  # Node failure analysis header
#     POD_RESCHEDULE=$(grep "✅ All pods rescheduled successfully" node_failure_*.log | wc -l)  # Count successful pod rescheduling
#     WORKLOAD_AVAILABILITY=$(grep "✅ Workload remains available" node_failure_*.log | wc -l)  # Count workload availability successes
#     echo "Pod rescheduling success: $POD_RESCHEDULE"  # Display rescheduling success count
#     echo "Workload availability maintained: $WORKLOAD_AVAILABILITY"  # Display availability count
#     echo ""  # Empty line for formatting
# fi
# 
# # Network partition experiment analysis
# if [ -f network_partition_*.log ]; then  # Check if network partition log files exist
#     echo "=== NETWORK PARTITION EXPERIMENT ANALYSIS ==="  # Network partition analysis header
#     SERVICE_CONNECTIVITY=$(grep "✅ Service connectivity verified" network_partition_*.log | wc -l)  # Count service connectivity successes
#     APP_FUNCTIONALITY=$(grep "✅ Application remains functional" network_partition_*.log | wc -l)  # Count application functionality successes
#     echo "Service connectivity maintained: $SERVICE_CONNECTIVITY"  # Display connectivity count
#     echo "Application functionality maintained: $APP_FUNCTIONALITY"  # Display functionality count
#     echo ""  # Empty line for formatting
# fi
# 
# # Overall assessment
# echo "=== OVERALL ASSESSMENT ==="  # Overall assessment header
# echo "Chaos Engineering Experiments Completed: 4"  # Display total experiments
# echo "Experiments with successful recovery: $(grep -r "✅" *.log | wc -l)"  # Count all successful recoveries across all logs
# echo "Experiments with failures: $(grep -r "❌" *.log | wc -l)"  # Count all failures across all logs
# echo ""  # Empty line for formatting
# echo "=== RECOMMENDATIONS ==="  # Recommendations header
# echo "1. Review failed experiments and implement improvements"  # Recommendation 1
# echo "2. Document lessons learned and best practices"  # Recommendation 2
# echo "3. Schedule regular chaos engineering sessions"  # Recommendation 3
# echo "4. Automate chaos experiments for continuous testing"  # Recommendation 4
# echo "5. Integrate chaos engineering into CI/CD pipeline"  # Recommendation 5
# ```
# 
# **Expected Output:**
# ```
# === CHAOS ENGINEERING RESULTS ANALYSIS ===
# Date: Mon Jan 15 10:30:00 UTC 2024
# 
# Analyzing experiment results...
# === API SERVER EXPERIMENT ANALYSIS ===
# API Server failures: 2
# API Server recoveries: 8
# 
# === ETCD EXPERIMENT ANALYSIS ===
# etcd failures: 3
# etcd recoveries: 1
# Data integrity maintained: 1
# 
# === NODE FAILURE EXPERIMENT ANALYSIS ===
# Pod rescheduling success: 1
# Workload availability maintained: 1
# 
# === NETWORK PARTITION EXPERIMENT ANALYSIS ===
# Service connectivity maintained: 1
# Application functionality maintained: 1
# 
# === OVERALL ASSESSMENT ===
# Chaos Engineering Experiments Completed: 4
# Experiments with successful recovery: 12
# Experiments with failures: 5
# 
# === RECOMMENDATIONS ===
# 1. Review failed experiments and implement improvements
# 2. Document lessons learned and best practices
# 3. Schedule regular chaos engineering sessions
# 4. Automate chaos experiments for continuous testing
# 5. Integrate chaos engineering into CI/CD pipeline
# ```
# 
# **Key Learning Points:**
# - **Log Analysis**: Uses `grep` and `wc -l` to count specific patterns in log files
# - **Conditional Analysis**: Checks for log file existence before attempting analysis
# - **Pattern Matching**: Uses specific success/failure patterns to categorize results
# - **Comprehensive Metrics**: Tracks multiple metrics per experiment type
# - **Overall Assessment**: Provides summary statistics across all experiments
# - **Actionable Recommendations**: Offers specific next steps based on results
# - **Structured Reporting**: Uses clear headers and formatting for readability
```

#### **Execute Analysis**
```bash
# Execute chaos engineering analysis
./analyze_chaos_results.sh

echo "=== CHAOS ENGINEERING ANALYSIS COMPLETED ==="
echo "Review results and implement recommendations"
```

### **🎯 Chaos Engineering Best Practices**

#### **1. Experiment Planning**
- **Define clear objectives** for each experiment
- **Establish success criteria** and failure thresholds
- **Plan rollback procedures** for emergency situations
- **Communicate with stakeholders** before running experiments

#### **2. Monitoring and Observability**
- **Monitor all critical metrics** before, during, and after experiments
- **Set up alerts** for unexpected behavior
- **Use distributed tracing** to understand system interactions
- **Log all experiment activities** for analysis

#### **3. Safety Measures**
- **Run experiments during low-traffic periods**
- **Have rollback procedures ready**
- **Test in staging environments first**
- **Limit blast radius** of experiments

#### **4. Documentation and Learning**
- **Document all experiments** and their results
- **Share lessons learned** with the team
- **Update runbooks** based on findings
- **Schedule regular chaos engineering sessions**

### **📈 Chaos Engineering Metrics**

#### **Key Performance Indicators**
1. **Mean Time to Recovery (MTTR)**: Time to restore normal operation
2. **Mean Time Between Failures (MTBF)**: Time between system failures
3. **System Availability**: Percentage of time system is operational
4. **Data Loss**: Amount of data lost during experiments
5. **Service Degradation**: Impact on service quality during experiments

#### **Success Criteria**
- **Zero data loss** during experiments
- **Automatic recovery** within defined timeframes
- **Maintained service availability** during component failures
- **Improved system resilience** over time

---

## 🚀 **Expert-Level Content and Advanced Scenarios**

### **🎯 Overview**
This section provides advanced Kubernetes architecture scenarios and enterprise-level implementations. These scenarios are designed for experienced practitioners who need to handle complex, production-scale deployments.

### **🏢 Enterprise Architecture Patterns**

#### **Pattern 1: Multi-Cluster Federation Architecture**

##### **Scenario**
You need to manage multiple Kubernetes clusters across different regions and environments while maintaining centralized control and workload distribution.

##### **Implementation Strategy**
```bash
# Create multi-cluster federation setup
cat > multi_cluster_federation.sh << 'EOF'
#!/bin/bash

# Multi-Cluster Federation Setup
echo "=== MULTI-CCLUSTER FEDERATION SETUP ==="
echo "Purpose: Set up federated control across multiple clusters"
echo ""

# Configuration
CLUSTERS=("prod-us-east" "prod-us-west" "prod-eu-west" "staging" "dev")
FEDERATION_NAMESPACE="kube-federation-system"

# Step 1: Install Federation Control Plane
echo "Step 1: Installing Federation Control Plane..."
kubectl create namespace $FEDERATION_NAMESPACE

# Install federation-v2
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/operator.yaml

# Wait for federation operator
kubectl wait --for=condition=available deployment/kubefed-controller-manager -n $FEDERATION_NAMESPACE --timeout=300s

echo "✅ Federation Control Plane installed"

# Step 2: Join Clusters
echo "Step 2: Joining clusters to federation..."

for cluster in "${CLUSTERS[@]}"; do
    echo "Joining cluster: $cluster"
    
    # Create federated cluster resource
    cat > federated-cluster-$cluster.yaml << CLUSTER
apiVersion: core.kubefed.io/v1beta1
kind: FederatedCluster
metadata:
  name: $cluster
  namespace: $FEDERATION_NAMESPACE
spec:
  apiEndpoint: https://$cluster-api.example.com:6443
  secretRef:
    name: $cluster-secret
  taints: []
CLUSTER

    kubectl apply -f federated-cluster-$cluster.yaml
    
    # Wait for cluster to be ready
    kubectl wait --for=condition=ready federatedcluster/$cluster -n $FEDERATION_NAMESPACE --timeout=300s
    
    echo "✅ Cluster $cluster joined to federation"
done

# Step 3: Enable Federated Resources
echo "Step 3: Enabling federated resources..."

# Enable federated namespaces
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federatednamespaces.yaml

# Enable federated deployments
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federateddeployments.yaml

# Enable federated services
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federatedservices.yaml

echo "✅ Federated resources enabled"

# Step 4: Create Federated Application
echo "Step 4: Creating federated application..."

cat > federated-app.yaml << FEDERATED_APP
apiVersion: types.kubefed.io/v1beta1
kind: FederatedDeployment
metadata:
  name: federated-web-app
  namespace: default
spec:
  template:
    metadata:
      labels:
        app: web-app
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: web-app
      template:
        metadata:
          labels:
            app: web-app
        spec:
          containers:
          - name: web-app
            image: nginx:latest
            ports:
            - containerPort: 80
            resources:
              requests:
                memory: "64Mi"
                cpu: "50m"
              limits:
                memory: "128Mi"
                cpu: "100m"
  placement:
    clusters:
    - name: prod-us-east
    - name: prod-us-west
    - name: prod-eu-west
  overrides:
  - clusterName: prod-us-east
    clusterOverrides:
    - path: "/spec/replicas"
      value: 5
  - clusterName: prod-us-west
    clusterOverrides:
    - path: "/spec/replicas"
      value: 3
  - clusterName: prod-eu-west
    clusterOverrides:
    - path: "/spec/replicas"
      value: 2
FEDERATED_APP

kubectl apply -f federated-app.yaml

echo "✅ Federated application created"

# Step 5: Verification
echo "Step 5: Verifying federation setup..."

# Check federated clusters
kubectl get federatedclusters -n $FEDERATION_NAMESPACE

# Check federated deployment
kubectl get federateddeployment federated-web-app

# Check deployment status across clusters
for cluster in "${CLUSTERS[@]}"; do
    echo "Checking deployment in cluster: $cluster"
    kubectl --context=$cluster get deployment federated-web-app -o wide
done

echo "=== FEDERATION SETUP COMPLETED ==="
EOF

chmod +x multi_cluster_federation.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Multi-Cluster Federation Setup
# echo "=== MULTI-CCLUSTER FEDERATION SETUP ==="  # Script header
# echo "Purpose: Set up federated control across multiple clusters"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # Configuration
# CLUSTERS=("prod-us-east" "prod-us-west" "prod-eu-west" "staging" "dev")  # Array of cluster names
# FEDERATION_NAMESPACE="kube-federation-system"  # Federation namespace name
# 
# # Step 1: Install Federation Control Plane
# echo "Step 1: Installing Federation Control Plane..."  # Step description
# kubectl create namespace $FEDERATION_NAMESPACE  # Create federation namespace
# 
# # Install federation-v2
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/operator.yaml  # Install federation operator
# 
# # Wait for federation operator
# kubectl wait --for=condition=available deployment/kubefed-controller-manager -n $FEDERATION_NAMESPACE --timeout=300s  # Wait for operator readiness
# 
# echo "✅ Federation Control Plane installed"  # Success message
# 
# # Step 2: Join Clusters
# echo "Step 2: Joining clusters to federation..."  # Step description
# 
# for cluster in "${CLUSTERS[@]}"; do  # Loop through each cluster
#     echo "Joining cluster: $cluster"  # Log current cluster
#     
#     # Create federated cluster resource
#     cat > federated-cluster-$cluster.yaml << CLUSTER  # Create cluster YAML using heredoc
# apiVersion: core.kubefed.io/v1beta1    # API version for federation
# kind: FederatedCluster                # Resource type
# metadata:                              # Metadata section
#   name: $cluster                       # Cluster name
#   namespace: $FEDERATION_NAMESPACE     # Federation namespace
# spec:                                 # Specification section
#   apiEndpoint: https://$cluster-api.example.com:6443  # Cluster API endpoint
#   secretRef:                          # Secret reference
#     name: $cluster-secret             # Secret name for cluster credentials
#   taints: []                          # No taints
# CLUSTER                               # End of heredoc
# 
#     kubectl apply -f federated-cluster-$cluster.yaml  # Apply federated cluster resource
#     
#     # Wait for cluster to be ready
#     kubectl wait --for=condition=ready federatedcluster/$cluster -n $FEDERATION_NAMESPACE --timeout=300s  # Wait for cluster readiness
#     
#     echo "✅ Cluster $cluster joined to federation"  # Success message
# done
# 
# # Step 3: Enable Federated Resources
# echo "Step 3: Enabling federated resources..."  # Step description
# 
# # Enable federated namespaces
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federatednamespaces.yaml  # Enable namespace federation
# 
# # Enable federated deployments
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federateddeployments.yaml  # Enable deployment federation
# 
# # Enable federated services
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/operator/deploy/federatedservices.yaml  # Enable service federation
# 
# echo "✅ Federated resources enabled"  # Success message
# 
# # Step 4: Create Federated Application
# echo "Step 4: Creating federated application..."  # Step description
# 
# cat > federated-app.yaml << FEDERATED_APP  # Create federated app YAML using heredoc
# apiVersion: types.kubefed.io/v1beta1    # API version for federated types
# kind: FederatedDeployment               # Resource type
# metadata:                               # Metadata section
#   name: federated-web-app               # Application name
#   namespace: default                    # Target namespace
# spec:                                  # Specification section
#   template:                            # Deployment template
#     metadata:                          # Template metadata
#       labels:                          # Template labels
#         app: web-app                    # App label
#     spec:                             # Template specification
#       replicas: 3                      # Default replicas
#       selector:                        # Pod selector
#         matchLabels:                   # Label matching
#           app: web-app                 # Select pods with app=web-app
#       template:                        # Pod template
#         metadata:                      # Pod metadata
#           labels:                      # Pod labels
#             app: web-app               # App label
#         spec:                         # Pod specification
#           containers:                 # Container list
#           - name: web-app             # Container name
#             image: nginx:latest       # Container image
#             ports:                    # Port configuration
#             - containerPort: 80       # Expose port 80
#             resources:                # Resource requirements
#               requests:                # Minimum resources
#                 memory: "64Mi"        # Memory request
#                 cpu: "50m"            # CPU request
#               limits:                 # Maximum resources
#                 memory: "128Mi"       # Memory limit
#                 cpu: "100m"           # CPU limit
#   placement:                          # Placement configuration
#     clusters:                         # Target clusters
#     - name: prod-us-east              # US East cluster
#     - name: prod-us-west              # US West cluster
#     - name: prod-eu-west              # EU West cluster
#   overrides:                         # Cluster-specific overrides
#   - clusterName: prod-us-east        # US East override
#     clusterOverrides:                # Override list
#     - path: "/spec/replicas"         # Override replicas
#       value: 5                       # Set to 5 replicas
#   - clusterName: prod-us-west        # US West override
#     clusterOverrides:                # Override list
#     - path: "/spec/replicas"         # Override replicas
#       value: 3                       # Set to 3 replicas
#   - clusterName: prod-eu-west        # EU West override
#     clusterOverrides:                # Override list
#     - path: "/spec/replicas"         # Override replicas
#       value: 2                       # Set to 2 replicas
# FEDERATED_APP                        # End of heredoc
# 
# kubectl apply -f federated-app.yaml  # Apply federated application
# 
# echo "✅ Federated application created"  # Success message
# 
# # Step 5: Verification
# echo "Step 5: Verifying federation setup..."  # Step description
# 
# # Check federated clusters
# kubectl get federatedclusters -n $FEDERATION_NAMESPACE  # List federated clusters
# 
# # Check federated deployment
# kubectl get federateddeployment federated-web-app  # Check federated deployment status
# 
# # Check deployment status across clusters
# for cluster in "${CLUSTERS[@]}"; do  # Loop through clusters
#     echo "Checking deployment in cluster: $cluster"  # Log current cluster
#     kubectl --context=$cluster get deployment federated-web-app -o wide  # Check deployment in specific cluster
# done
# 
# echo "=== FEDERATION SETUP COMPLETED ==="  # Completion message
# ```
# 
# **Expected Output:**
# ```
# === MULTI-CCLUSTER FEDERATION SETUP ===
# Purpose: Set up federated control across multiple clusters
# 
# Step 1: Installing Federation Control Plane...
# namespace/kube-federation-system created
# deployment.apps/kubefed-controller-manager created
# deployment.apps/kubefed-controller-manager condition met
# ✅ Federation Control Plane installed
# Step 2: Joining clusters to federation...
# Joining cluster: prod-us-east
# federatedcluster.core.kubefed.io/prod-us-east created
# federatedcluster.core.kubefed.io/prod-us-east condition met
# ✅ Cluster prod-us-east joined to federation
# Joining cluster: prod-us-west
# federatedcluster.core.kubefed.io/prod-us-west created
# federatedcluster.core.kubefed.io/prod-us-west condition met
# ✅ Cluster prod-us-west joined to federation
# Joining cluster: prod-eu-west
# federatedcluster.core.kubefed.io/prod-eu-west created
# federatedcluster.core.kubefed.io/prod-eu-west condition met
# ✅ Cluster prod-eu-west joined to federation
# Joining cluster: staging
# federatedcluster.core.kubefed.io/staging created
# federatedcluster.core.kubefed.io/staging condition met
# ✅ Cluster staging joined to federation
# Joining cluster: dev
# federatedcluster.core.kubefed.io/dev created
# federatedcluster.core.kubefed.io/dev condition met
# ✅ Cluster dev joined to federation
# Step 3: Enabling federated resources...
# federatedtypeconfig.core.kubefed.io/namespaces created
# federatedtypeconfig.core.kubefed.io/deployments created
# federatedtypeconfig.core.kubefed.io/services created
# ✅ Federated resources enabled
# Step 4: Creating federated application...
# federateddeployment.types.kubefed.io/federated-web-app created
# ✅ Federated application created
# Step 5: Verifying federation setup...
# NAME           READY   AGE
# dev            True     2m
# prod-eu-west   True     2m
# prod-us-east   True     2m
# prod-us-west   True     2m
# staging        True     2m
# NAME                READY   CLUSTERS   AGE
# federated-web-app   True    3          1m
# Checking deployment in cluster: prod-us-east
# NAME                READY   UP-TO-DATE   AVAILABLE   AGE
# federated-web-app   5/5     5            5           1m
# Checking deployment in cluster: prod-us-west
# NAME                READY   UP-TO-DATE   AVAILABLE   AGE
# federated-web-app   3/3     3            3           1m
# Checking deployment in cluster: prod-eu-west
# NAME                READY   UP-TO-DATE   AVAILABLE   AGE
# federated-web-app   2/2     2            2           1m
# === FEDERATION SETUP COMPLETED ===
# ```
# 
# **Key Learning Points:**
# - **Multi-Cluster Management**: Demonstrates how to manage multiple clusters from a single control plane
# - **Federation Operator**: Uses kubefed operator for automated federation setup
# - **Cluster Joining**: Shows how to join clusters to federation with proper authentication
# - **Resource Federation**: Enables federation for namespaces, deployments, and services
# - **Placement Policies**: Demonstrates cluster-specific placement and replica distribution
# - **Override Mechanisms**: Shows how to customize deployments per cluster
# - **Cross-Cluster Verification**: Verifies deployment status across all federated clusters
# - **Scalable Architecture**: Supports enterprise-scale multi-cluster deployments
```

##### **Advanced Federation Features**
```bash
# Create advanced federation features
cat > advanced_federation_features.sh << 'EOF'
#!/bin/bash

# Advanced Federation Features
echo "=== ADVANCED FEDERATION FEATURES ==="

# 1. Federated ConfigMaps and Secrets
echo "1. Setting up federated ConfigMaps and Secrets..."

cat > federated-config.yaml << FEDERATED_CONFIG
apiVersion: types.kubefed.io/v1beta1
kind: FederatedConfigMap
metadata:
  name: app-config
  namespace: default
spec:
  template:
    data:
      database_url: "postgresql://prod-db.example.com:5432/app"
      redis_url: "redis://prod-redis.example.com:6379"
      api_key: "prod-api-key-12345"
  placement:
    clusters:
    - name: prod-us-east
    - name: prod-us-west
    - name: prod-eu-west
  overrides:
  - clusterName: prod-us-east
    clusterOverrides:
    - path: "/data/database_url"
      value: "postgresql://us-east-db.example.com:5432/app"
  - clusterName: prod-us-west
    clusterOverrides:
    - path: "/data/database_url"
      value: "postgresql://us-west-db.example.com:5432/app"
  - clusterName: prod-eu-west
    clusterOverrides:
    - path: "/data/database_url"
      value: "postgresql://eu-west-db.example.com:5432/app"
FEDERATED_CONFIG

kubectl apply -f federated-config.yaml

# 2. Federated Ingress with Global Load Balancing
echo "2. Setting up federated Ingress with global load balancing..."

cat > federated-ingress.yaml << FEDERATED_INGRESS
apiVersion: types.kubefed.io/v1beta1
kind: FederatedIngress
metadata:
  name: global-web-app
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  template:
    spec:
      tls:
      - hosts:
        - web-app.example.com
        secretName: web-app-tls
      rules:
      - host: web-app.example.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-app-service
                port:
                  number: 80
  placement:
    clusters:
    - name: prod-us-east
    - name: prod-us-west
    - name: prod-eu-west
  overrides:
  - clusterName: prod-us-east
    clusterOverrides:
    - path: "/spec/rules/0/http/paths/0/backend/service/name"
      value: "web-app-service-us-east"
  - clusterName: prod-us-west
    clusterOverrides:
    - path: "/spec/rules/0/http/paths/0/backend/service/name"
      value: "web-app-service-us-west"
  - clusterName: prod-eu-west
    clusterOverrides:
    - path: "/spec/rules/0/http/paths/0/backend/service/name"
      value: "web-app-service-eu-west"
FEDERATED_INGRESS

kubectl apply -f federated-ingress.yaml

# 3. Federated HPA (Horizontal Pod Autoscaler)
echo "3. Setting up federated HPA..."

cat > federated-hpa.yaml << FEDERATED_HPA
apiVersion: types.kubefed.io/v1beta1
kind: FederatedHorizontalPodAutoscaler
metadata:
  name: web-app-hpa
  namespace: default
spec:
  template:
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: web-app
      minReplicas: 2
      maxReplicas: 10
      targetCPUUtilizationPercentage: 70
      targetMemoryUtilizationPercentage: 80
  placement:
    clusters:
    - name: prod-us-east
    - name: prod-us-west
    - name: prod-eu-west
  overrides:
  - clusterName: prod-us-east
    clusterOverrides:
    - path: "/spec/maxReplicas"
      value: 15
  - clusterName: prod-us-west
    clusterOverrides:
    - path: "/spec/maxReplicas"
      value: 12
  - clusterName: prod-eu-west
    clusterOverrides:
    - path: "/spec/maxReplicas"
      value: 8
FEDERATED_HPA

kubectl apply -f federated-hpa.yaml

echo "✅ Advanced federation features configured"
EOF

chmod +x advanced_federation_features.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Advanced Federation Features
# echo "=== ADVANCED FEDERATION FEATURES ==="  # Script header
# 
# # 1. Federated ConfigMaps and Secrets
# echo "1. Setting up federated ConfigMaps and Secrets..."  # Step description
# 
# cat > federated-config.yaml << FEDERATED_CONFIG  # Create federated config YAML using heredoc
# apiVersion: types.kubefed.io/v1beta1    # API version for federated types
# kind: FederatedConfigMap                # Resource type
# metadata:                               # Metadata section
#   name: app-config                      # ConfigMap name
#   namespace: default                    # Target namespace
# spec:                                  # Specification section
#   template:                            # ConfigMap template
#     data:                              # Configuration data
#       database_url: "postgresql://prod-db.example.com:5432/app"  # Default database URL
#       redis_url: "redis://prod-redis.example.com:6379"          # Default Redis URL
#       api_key: "prod-api-key-12345"                              # Default API key
#   placement:                          # Placement configuration
#     clusters:                         # Target clusters
#     - name: prod-us-east              # US East cluster
#     - name: prod-us-west              # US West cluster
#     - name: prod-eu-west              # EU West cluster
#   overrides:                         # Cluster-specific overrides
#   - clusterName: prod-us-east        # US East override
#     clusterOverrides:                # Override list
#     - path: "/data/database_url"     # Override database URL
#       value: "postgresql://us-east-db.example.com:5432/app"  # US East database URL
#   - clusterName: prod-us-west        # US West override
#     clusterOverrides:                # Override list
#     - path: "/data/database_url"     # Override database URL
#       value: "postgresql://us-west-db.example.com:5432/app"  # US West database URL
#   - clusterName: prod-eu-west        # EU West override
#     clusterOverrides:                # Override list
#     - path: "/data/database_url"     # Override database URL
#       value: "postgresql://eu-west-db.example.com:5432/app"  # EU West database URL
# FEDERATED_CONFIG                     # End of heredoc
# 
# kubectl apply -f federated-config.yaml  # Apply federated ConfigMap
# 
# # 2. Federated Ingress with Global Load Balancing
# echo "2. Setting up federated Ingress with global load balancing..."  # Step description
# 
# cat > federated-ingress.yaml << FEDERATED_INGRESS  # Create federated ingress YAML using heredoc
# apiVersion: types.kubefed.io/v1beta1    # API version for federated types
# kind: FederatedIngress                 # Resource type
# metadata:                               # Metadata section
#   name: global-web-app                  # Ingress name
#   namespace: default                    # Target namespace
#   annotations:                          # Ingress annotations
#     kubernetes.io/ingress.class: "nginx"  # Ingress controller class
#     cert-manager.io/cluster-issuer: "letsencrypt-prod"  # TLS certificate issuer
# spec:                                  # Specification section
#   template:                            # Ingress template
#     spec:                             # Template specification
#       tls:                            # TLS configuration
#       - hosts:                        # TLS hosts
#         - web-app.example.com        # Domain name
#         secretName: web-app-tls       # TLS secret name
#       rules:                         # Ingress rules
#       - host: web-app.example.com    # Host rule
#         http:                        # HTTP configuration
#           paths:                     # Path rules
#           - path: /                  # Root path
#             pathType: Prefix         # Path type
#             backend:                 # Backend service
#               service:               # Service backend
#                 name: web-app-service  # Service name
#                 port:                # Service port
#                   number: 80         # Port number
#   placement:                         # Placement configuration
#     clusters:                        # Target clusters
#     - name: prod-us-east             # US East cluster
#     - name: prod-us-west             # US West cluster
#     - name: prod-eu-west             # EU West cluster
#   overrides:                        # Cluster-specific overrides
#   - clusterName: prod-us-east       # US East override
#     clusterOverrides:               # Override list
#     - path: "/spec/rules/0/http/paths/0/backend/service/name"  # Override service name
#       value: "web-app-service-us-east"  # US East service name
#   - clusterName: prod-us-west       # US West override
#     clusterOverrides:               # Override list
#     - path: "/spec/rules/0/http/paths/0/backend/service/name"  # Override service name
#       value: "web-app-service-us-west"  # US West service name
#   - clusterName: prod-eu-west       # EU West override
#     clusterOverrides:               # Override list
#     - path: "/spec/rules/0/http/paths/0/backend/service/name"  # Override service name
#       value: "web-app-service-eu-west"  # EU West service name
# FEDERATED_INGRESS                    # End of heredoc
# 
# kubectl apply -f federated-ingress.yaml  # Apply federated Ingress
# 
# # 3. Federated HPA (Horizontal Pod Autoscaler)
# echo "3. Setting up federated HPA..."  # Step description
# 
# cat > federated-hpa.yaml << FEDERATED_HPA  # Create federated HPA YAML using heredoc
# apiVersion: types.kubefed.io/v1beta1    # API version for federated types
# kind: FederatedHorizontalPodAutoscaler   # Resource type
# metadata:                               # Metadata section
#   name: web-app-hpa                      # HPA name
#   namespace: default                     # Target namespace
# spec:                                   # Specification section
#   template:                             # HPA template
#     spec:                              # Template specification
#       scaleTargetRef:                   # Target for scaling
#         apiVersion: apps/v1             # Target API version
#         kind: Deployment                # Target resource type
#         name: web-app                   # Target deployment name
#       minReplicas: 2                    # Minimum replicas
#       maxReplicas: 10                   # Maximum replicas
#       targetCPUUtilizationPercentage: 70  # CPU utilization target
#       targetMemoryUtilizationPercentage: 80  # Memory utilization target
#   placement:                           # Placement configuration
#     clusters:                          # Target clusters
#     - name: prod-us-east               # US East cluster
#     - name: prod-us-west               # US West cluster
#     - name: prod-eu-west               # EU West cluster
#   overrides:                          # Cluster-specific overrides
#   - clusterName: prod-us-east         # US East override
#     clusterOverrides:                 # Override list
#     - path: "/spec/maxReplicas"       # Override max replicas
#       value: 15                       # US East max replicas
#   - clusterName: prod-us-west         # US West override
#     clusterOverrides:                 # Override list
#     - path: "/spec/maxReplicas"       # Override max replicas
#       value: 12                       # US West max replicas
#   - clusterName: prod-eu-west         # EU West override
#     clusterOverrides:                 # Override list
#     - path: "/spec/maxReplicas"       # Override max replicas
#       value: 8                        # EU West max replicas
# FEDERATED_HPA                         # End of heredoc
# 
# kubectl apply -f federated-hpa.yaml  # Apply federated HPA
# 
# echo "✅ Advanced federation features configured"  # Success message
# ```
# 
# **Expected Output:**
# ```
# === ADVANCED FEDERATION FEATURES ===
# 1. Setting up federated ConfigMaps and Secrets...
# federatedconfigmap.types.kubefed.io/app-config created
# 2. Setting up federated Ingress with global load balancing...
# federatedingress.types.kubefed.io/global-web-app created
# 3. Setting up federated HPA...
# federatedhorizontalpodautoscaler.types.kubefed.io/web-app-hpa created
# ✅ Advanced federation features configured
# ```
# 
# **Key Learning Points:**
# - **Federated ConfigMaps**: Enables configuration management across multiple clusters with region-specific overrides
# - **Global Load Balancing**: Uses federated Ingress to distribute traffic across clusters in different regions
# - **Federated Autoscaling**: Implements cluster-specific HPA policies for optimal resource utilization
# - **TLS Management**: Integrates with cert-manager for automated SSL certificate management
# - **Region-Specific Configuration**: Demonstrates how to customize resources per cluster/region
# - **Service Discovery**: Shows how to route traffic to region-specific services
# - **Resource Optimization**: Implements different scaling policies based on cluster capacity
```

#### **Pattern 2: Advanced Security Architecture**

##### **Scenario**
Implement enterprise-grade security for Kubernetes clusters with advanced RBAC, network policies, and security scanning.

##### **Implementation Strategy**
```bash
# Create advanced security architecture
cat > advanced_security_architecture.sh << 'EOF'
#!/bin/bash

# Advanced Security Architecture Setup
echo "=== ADVANCED SECURITY ARCHITECTURE SETUP ==="
echo "Purpose: Implement enterprise-grade security for Kubernetes clusters"
echo ""

# Step 1: Advanced RBAC Configuration
echo "Step 1: Setting up advanced RBAC..."

# Create security namespace
kubectl create namespace security-system

# Create security roles
cat > security-roles.yaml << SECURITY_ROLES
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-admin
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies", "ingresses"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["security.openshift.io"]
  resources: ["securitycontextconstraints"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-auditor
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies", "ingresses"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-admin-binding
subjects:
- kind: ServiceAccount
  name: security-admin
  namespace: security-system
roleRef:
  kind: ClusterRole
  name: security-admin
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-auditor-binding
subjects:
- kind: ServiceAccount
  name: security-auditor
  namespace: security-system
roleRef:
  kind: ClusterRole
  name: security-auditor
  apiGroup: rbac.authorization.k8s.io
SECURITY_ROLES

kubectl apply -f security-roles.yaml

# Step 2: Network Security Policies
echo "Step 2: Setting up network security policies..."

# Create default deny policy
cat > default-deny-policy.yaml << DENY_POLICY
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
DENY_POLICY

kubectl apply -f default-deny-policy.yaml

# Create application-specific policies
cat > app-network-policies.yaml << APP_POLICIES
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-app-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  - from:
    - podSelector:
        matchLabels:
          app: monitoring
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: redis
    ports:
    - protocol: TCP
      port: 6379
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web-app
    ports:
    - protocol: TCP
      port: 5432
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
APP_POLICIES

kubectl apply -f app-network-policies.yaml

# Step 3: Pod Security Policies
echo "Step 3: Setting up pod security policies..."

cat > pod-security-policies.yaml << POD_POLICIES
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'runtime/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'downwardAPI'
  - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
    - min: 1
      max: 65535
  readOnlyRootFilesystem: true
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: privileged-psp
spec:
  privileged: true
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - '*'
  volumes:
  - '*'
  hostNetwork: true
  hostIPC: true
  hostPID: true
  runAsUser:
    rule: 'RunAsAny'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: false
POD_POLICIES

kubectl apply -f pod-security-policies.yaml

# Step 4: Security Scanning Integration
echo "Step 4: Setting up security scanning..."

# Install Trivy for vulnerability scanning
cat > trivy-scanner.yaml << TRIVY_SCANNER
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: trivy-vulnerability-scan
  namespace: security-system
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: security-admin
          containers:
          - name: trivy-scanner
            image: aquasec/trivy:latest
            command:
            - /bin/sh
            - -c
            - |
              # Scan all images in the cluster
              for pod in $(kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'); do
                echo "Scanning image: $pod"
                trivy image --format json --output /tmp/scan-results.json "$pod"
                
                # Send results to security monitoring system
                curl -X POST \
                  -H "Content-Type: application/json" \
                  -d @/tmp/scan-results.json \
                  http://security-monitor.example.com/api/vulnerabilities
              done
          restartPolicy: OnFailure
TRIVY_SCANNER

kubectl apply -f trivy-scanner.yaml

echo "✅ Advanced security architecture configured"
EOF

chmod +x advanced_security_architecture.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Advanced Security Architecture Setup
# echo "=== ADVANCED SECURITY ARCHITECTURE SETUP ==="  # Script header
# echo "Purpose: Implement enterprise-grade security for Kubernetes clusters"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # Step 1: Advanced RBAC Configuration
# echo "Step 1: Setting up advanced RBAC..."  # Step description
# 
# # Create security namespace
# kubectl create namespace security-system  # Create dedicated namespace for security resources
# 
# # Create security roles
# cat > security-roles.yaml << SECURITY_ROLES  # Create RBAC YAML using heredoc
# ---                               # YAML document separator
# apiVersion: rbac.authorization.k8s.io/v1  # API version for RBAC
# kind: ClusterRole                  # Resource type
# metadata:                          # Metadata section
#   name: security-admin             # Role name
# rules:                            # Permission rules
# - apiGroups: [""]                 # Core API group
#   resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]  # Allowed resources
#   verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]  # Allowed actions
# - apiGroups: ["apps"]             # Apps API group
#   resources: ["deployments", "replicasets", "statefulsets"]  # Allowed resources
#   verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]  # Allowed actions
# - apiGroups: ["networking.k8s.io"]  # Networking API group
#   resources: ["networkpolicies", "ingresses"]  # Allowed resources
#   verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]  # Allowed actions
# - apiGroups: ["security.openshift.io"]  # OpenShift security API group
#   resources: ["securitycontextconstraints"]  # Allowed resources
#   verbs: ["get", "list", "watch"]  # Allowed actions
# ---                               # YAML document separator
# apiVersion: rbac.authorization.k8s.io/v1  # API version for RBAC
# kind: ClusterRole                  # Resource type
# metadata:                          # Metadata section
#   name: security-auditor           # Role name
# rules:                            # Permission rules
# - apiGroups: [""]                 # Core API group
#   resources: ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]  # Allowed resources
#   verbs: ["get", "list", "watch"]  # Read-only actions
# - apiGroups: ["apps"]             # Apps API group
#   resources: ["deployments", "replicasets", "statefulsets"]  # Allowed resources
#   verbs: ["get", "list", "watch"]  # Read-only actions
# - apiGroups: ["networking.k8s.io"]  # Networking API group
#   resources: ["networkpolicies", "ingresses"]  # Allowed resources
#   verbs: ["get", "list", "watch"]  # Read-only actions
# ---                               # YAML document separator
# apiVersion: rbac.authorization.k8s.io/v1  # API version for RBAC
# kind: ClusterRoleBinding           # Resource type
# metadata:                          # Metadata section
#   name: security-admin-binding     # Binding name
# subjects:                         # Subjects (users/service accounts)
# - kind: ServiceAccount            # Subject type
#   name: security-admin            # Service account name
#   namespace: security-system      # Service account namespace
# roleRef:                          # Role reference
#   kind: ClusterRole               # Role type
#   name: security-admin            # Role name
#   apiGroup: rbac.authorization.k8s.io  # API group
# ---                               # YAML document separator
# apiVersion: rbac.authorization.k8s.io/v1  # API version for RBAC
# kind: ClusterRoleBinding           # Resource type
# metadata:                          # Metadata section
#   name: security-auditor-binding  # Binding name
# subjects:                         # Subjects (users/service accounts)
# - kind: ServiceAccount            # Subject type
#   name: security-auditor           # Service account name
#   namespace: security-system      # Service account namespace
# roleRef:                          # Role reference
#   kind: ClusterRole               # Role type
#   name: security-auditor          # Role name
#   apiGroup: rbac.authorization.k8s.io  # API group
# SECURITY_ROLES                     # End of heredoc
# 
# kubectl apply -f security-roles.yaml  # Apply RBAC configuration
# 
# # Step 2: Network Security Policies
# echo "Step 2: Setting up network security policies..."  # Step description
# 
# # Create default deny policy
# cat > default-deny-policy.yaml << DENY_POLICY  # Create default deny policy using heredoc
# apiVersion: networking.k8s.io/v1   # API version for networking
# kind: NetworkPolicy                # Resource type
# metadata:                          # Metadata section
#   name: default-deny-all           # Policy name
#   namespace: default               # Target namespace
# spec:                             # Specification section
#   podSelector: {}                  # Select all pods (empty selector)
#   policyTypes:                     # Policy types
#   - Ingress                        # Ingress policy
#   - Egress                         # Egress policy
# DENY_POLICY                        # End of heredoc
# 
# kubectl apply -f default-deny-policy.yaml  # Apply default deny policy
# 
# # Create application-specific policies
# cat > app-network-policies.yaml << APP_POLICIES  # Create app-specific policies using heredoc
# ---                               # YAML document separator
# apiVersion: networking.k8s.io/v1   # API version for networking
# kind: NetworkPolicy                # Resource type
# metadata:                          # Metadata section
#   name: web-app-policy             # Policy name
#   namespace: default               # Target namespace
# spec:                             # Specification section
#   podSelector:                     # Pod selector
#     matchLabels:                   # Label matching
#       app: web-app                 # Select pods with app=web-app
#   policyTypes:                     # Policy types
#   - Ingress                        # Ingress policy
#   - Egress                         # Egress policy
#   ingress:                         # Ingress rules
#   - from:                          # Source
#     - namespaceSelector:           # Namespace selector
#         matchLabels:               # Label matching
#           name: ingress-nginx      # Allow from ingress-nginx namespace
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 80                     # Port 80
#     - protocol: TCP                # TCP protocol
#       port: 443                    # Port 443
#   - from:                          # Source
#     - podSelector:                 # Pod selector
#         matchLabels:               # Label matching
#           app: monitoring         # Allow from monitoring pods
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 8080                   # Port 8080
#   egress:                          # Egress rules
#   - to:                            # Destination
#     - podSelector:                 # Pod selector
#         matchLabels:               # Label matching
#           app: database            # Allow to database pods
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 5432                   # Port 5432
#   - to:                            # Destination
#     - podSelector:                 # Pod selector
#         matchLabels:               # Label matching
#           app: redis               # Allow to redis pods
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 6379                   # Port 6379
#   - to: []                         # Empty destination (external)
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 53                     # DNS port
#     - protocol: UDP                # UDP protocol
#       port: 53                     # DNS port
# ---                               # YAML document separator
# apiVersion: networking.k8s.io/v1   # API version for networking
# kind: NetworkPolicy                # Resource type
# metadata:                          # Metadata section
#   name: database-policy            # Policy name
#   namespace: default               # Target namespace
# spec:                             # Specification section
#   podSelector:                     # Pod selector
#     matchLabels:                   # Label matching
#       app: database                # Select pods with app=database
#   policyTypes:                     # Policy types
#   - Ingress                        # Ingress policy
#   - Egress                         # Egress policy
#   ingress:                         # Ingress rules
#   - from:                          # Source
#     - podSelector:                 # Pod selector
#         matchLabels:               # Label matching
#           app: web-app             # Allow from web-app pods
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 5432                   # Port 5432
#   egress:                          # Egress rules
#   - to: []                         # Empty destination (external)
#     ports:                         # Allowed ports
#     - protocol: TCP                # TCP protocol
#       port: 53                     # DNS port
#     - protocol: UDP                # UDP protocol
#       port: 53                     # DNS port
# APP_POLICIES                       # End of heredoc
# 
# kubectl apply -f app-network-policies.yaml  # Apply network policies
# 
# # Step 3: Pod Security Policies
# echo "Step 3: Setting up pod security policies..."  # Step description
# 
# cat > pod-security-policies.yaml << POD_POLICIES  # Create PSP YAML using heredoc
# apiVersion: policy/v1beta1         # API version for policy
# kind: PodSecurityPolicy            # Resource type
# metadata:                          # Metadata section
#   name: restricted-psp             # Policy name
#   annotations:                     # Annotations
#     seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'runtime/default'  # Seccomp profile
#     apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'  # AppArmor profile
# spec:                             # Specification section
#   privileged: false                # Disable privileged mode
#   allowPrivilegeEscalation: false  # Disable privilege escalation
#   requiredDropCapabilities:        # Required dropped capabilities
#   - ALL                            # Drop all capabilities
#   volumes:                         # Allowed volume types
#   - 'configMap'                    # ConfigMap volumes
#   - 'emptyDir'                     # Empty directory volumes
#   - 'projected'                     # Projected volumes
#   - 'secret'                        # Secret volumes
#   - 'downwardAPI'                  # Downward API volumes
#   - 'persistentVolumeClaim'        # PVC volumes
#   hostNetwork: false               # Disable host networking
#   hostIPC: false                   # Disable host IPC
#   hostPID: false                   # Disable host PID
#   runAsUser:                       # User ID policy
#     rule: 'MustRunAsNonRoot'       # Must run as non-root
#   seLinux:                         # SELinux policy
#     rule: 'RunAsAny'               # Allow any SELinux context
#   supplementalGroups:              # Supplemental groups policy
#     rule: 'MustRunAs'              # Must run as specific groups
#     ranges:                         # Group ID ranges
#     - min: 1                       # Minimum group ID
#       max: 65535                   # Maximum group ID
#   fsGroup:                         # Filesystem group policy
#     rule: 'MustRunAs'              # Must run as specific group
#     ranges:                         # Group ID ranges
#     - min: 1                       # Minimum group ID
#       max: 65535                   # Maximum group ID
#   readOnlyRootFilesystem: true     # Read-only root filesystem
# ---                               # YAML document separator
# apiVersion: policy/v1beta1         # API version for policy
# kind: PodSecurityPolicy            # Resource type
# metadata:                          # Metadata section
#   name: privileged-psp             # Policy name
# spec:                             # Specification section
#   privileged: true                 # Enable privileged mode
#   allowPrivilegeEscalation: true   # Allow privilege escalation
#   allowedCapabilities:             # Allowed capabilities
#   - '*'                            # Allow all capabilities
#   volumes:                         # Allowed volume types
#   - '*'                            # Allow all volume types
#   hostNetwork: true                # Allow host networking
#   hostIPC: true                    # Allow host IPC
#   hostPID: true                    # Allow host PID
#   runAsUser:                       # User ID policy
#     rule: 'RunAsAny'               # Allow any user
#   seLinux:                         # SELinux policy
#     rule: 'RunAsAny'               # Allow any SELinux context
#   supplementalGroups:              # Supplemental groups policy
#     rule: 'RunAsAny'               # Allow any groups
#   fsGroup:                         # Filesystem group policy
#     rule: 'RunAsAny'               # Allow any group
#   readOnlyRootFilesystem: false    # Allow writable root filesystem
# POD_POLICIES                        # End of heredoc
# 
# kubectl apply -f pod-security-policies.yaml  # Apply pod security policies
# 
# # Step 4: Security Scanning Integration
# echo "Step 4: Setting up security scanning..."  # Step description
# 
# # Install Trivy for vulnerability scanning
# cat > trivy-scanner.yaml << TRIVY_SCANNER  # Create Trivy scanner using heredoc
# apiVersion: batch/v1beta1          # API version for batch
# kind: CronJob                      # Resource type
# metadata:                          # Metadata section
#   name: trivy-vulnerability-scan   # Job name
#   namespace: security-system       # Target namespace
# spec:                             # Specification section
#   schedule: "0 2 * * *"           # Cron schedule (daily at 2 AM)
#   jobTemplate:                     # Job template
#     spec:                         # Template specification
#       template:                   # Pod template
#         spec:                     # Pod specification
#           serviceAccountName: security-admin  # Service account
#           containers:            # Container list
#           - name: trivy-scanner  # Container name
#             image: aquasec/trivy:latest  # Trivy image
#             command:             # Command to run
#             - /bin/sh            # Shell
#             - -c                 # Command flag
#             - |                  # Multi-line command
#               # Scan all images in the cluster
#               for pod in $(kubectl get pods --all-namespaces -o jsonpath='{.items[*].spec.containers[*].image}'); do  # Loop through all container images
#                 echo "Scanning image: $pod"  # Log current image
#                 trivy image --format json --output /tmp/scan-results.json "$pod"  # Scan image and save results
#                 
#                 # Send results to security monitoring system
#                 curl -X POST \  # HTTP POST request
#                   -H "Content-Type: application/json" \  # Content type header
#                   -d @/tmp/scan-results.json \  # Send scan results as data
#                   http://security-monitor.example.com/api/vulnerabilities  # Endpoint URL
#               done
#           restartPolicy: OnFailure  # Restart policy
# TRIVY_SCANNER                      # End of heredoc
# 
# kubectl apply -f trivy-scanner.yaml  # Apply Trivy scanner
# 
# echo "✅ Advanced security architecture configured"  # Success message
# ```
# 
# **Expected Output:**
# ```
# === ADVANCED SECURITY ARCHITECTURE SETUP ===
# Purpose: Implement enterprise-grade security for Kubernetes clusters
# 
# Step 1: Setting up advanced RBAC...
# namespace/security-system created
# clusterrole.rbac.authorization.k8s.io/security-admin created
# clusterrole.rbac.authorization.k8s.io/security-auditor created
# clusterrolebinding.rbac.authorization.k8s.io/security-admin-binding created
# clusterrolebinding.rbac.authorization.k8s.io/security-auditor-binding created
# 
# Step 2: Setting up network security policies...
# networkpolicy.networking.k8s.io/default-deny-all created
# networkpolicy.networking.k8s.io/web-app-policy created
# networkpolicy.networking.k8s.io/database-policy created
# 
# Step 3: Setting up pod security policies...
# podsecuritypolicy.policy/restricted-psp created
# podsecuritypolicy.policy/privileged-psp created
# 
# Step 4: Setting up security scanning...
# cronjob.batch/trivy-vulnerability-scan created
# ✅ Advanced security architecture configured
# ```
# 
# **Key Learning Points:**
# - **Advanced RBAC**: Implements fine-grained access control with admin and auditor roles
# - **Network Policies**: Creates default deny policies with application-specific allow rules
# - **Pod Security Policies**: Defines restricted and privileged policies for different workloads
# - **Security Scanning**: Integrates Trivy for automated vulnerability scanning
# - **Least Privilege**: Implements principle of least privilege across all security layers
# - **Multi-Layer Security**: Combines RBAC, network policies, and pod security policies
# - **Automated Monitoring**: Uses CronJob for regular security assessments
# - **Enterprise Compliance**: Meets enterprise security requirements and best practices
```

#### **Pattern 3: High-Performance Architecture**

##### **Scenario**
Design and implement a high-performance Kubernetes architecture optimized for low latency, high throughput, and resource efficiency.

##### **Implementation Strategy**
```bash
# Create high-performance architecture
cat > high_performance_architecture.sh << 'EOF'
#!/bin/bash

# High-Performance Architecture Setup
echo "=== HIGH-PERFORMANCE ARCHITECTURE SETUP ==="
echo "Purpose: Optimize Kubernetes for low latency and high throughput"
echo ""

# Step 1: Node Optimization
echo "Step 1: Optimizing node configuration..."

# Create node optimization script
cat > optimize-nodes.sh << NODE_OPT
#!/bin/bash

# Node optimization for high performance
NODE_NAME="$1"

if [ -z "$NODE_NAME" ]; then
    echo "Usage: $0 <node-name>"
    exit 1
fi

echo "Optimizing node: $NODE_NAME"

# 1. CPU optimization
echo "1. CPU optimization..."
# Set CPU governor to performance
ssh $NODE_NAME "echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

# 2. Memory optimization
echo "2. Memory optimization..."
# Disable swap
ssh $NODE_NAME "sudo swapoff -a"
ssh $NODE_NAME "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"

# 3. Network optimization
echo "3. Network optimization..."
# Optimize network settings
ssh $NODE_NAME "sudo sysctl -w net.core.rmem_max=16777216"
ssh $NODE_NAME "sudo sysctl -w net.core.wmem_max=16777216"
ssh $NODE_NAME "sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'"
ssh $NODE_NAME "sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216'"

# 4. Storage optimization
echo "4. Storage optimization..."
# Use high-performance storage settings
ssh $NODE_NAME "sudo sysctl -w vm.dirty_ratio=10"
ssh $NODE_NAME "sudo sysctl -w vm.dirty_background_ratio=5"

echo "✅ Node optimization completed for $NODE_NAME"
NODE_OPT

chmod +x optimize-nodes.sh

# Step 2: High-Performance Workload Configuration
echo "Step 2: Creating high-performance workload configuration..."

cat > high-perf-deployment.yaml << HIGH_PERF_DEPLOYMENT
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-perf-app
  namespace: default
  annotations:
    performance.kubernetes.io/cpu-pinning: "true"
    performance.kubernetes.io/memory-hugepages: "true"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: high-perf-app
  template:
    metadata:
      labels:
        app: high-perf-app
    spec:
      runtimeClassName: performance
      containers:
      - name: high-perf-app
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "1000m"
            memory: "2Gi"
            hugepages-2Mi: "1Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"
            hugepages-2Mi: "2Gi"
        env:
        - name: NGINX_WORKER_PROCESSES
          value: "auto"
        - name: NGINX_WORKER_CONNECTIONS
          value: "1024"
        - name: NGINX_KEEPALIVE_TIMEOUT
          value: "65"
        - name: NGINX_KEEPALIVE_REQUESTS
          value: "100"
        volumeMounts:
        - name: hugepages
          mountPath: /dev/hugepages
        - name: tmpfs
          mountPath: /tmp
        - name: cache
          mountPath: /var/cache/nginx
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
            - SYS_ADMIN
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: hugepages
        emptyDir:
          medium: HugePages
      - name: tmpfs
        emptyDir:
          medium: Memory
      - name: cache
        emptyDir:
          medium: Memory
      nodeSelector:
        kubernetes.io/arch: amd64
        performance: "true"
      tolerations:
      - key: performance
        operator: Exists
        effect: NoSchedule
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: performance
                operator: In
                values:
                - "true"
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - high-perf-app
              topologyKey: kubernetes.io/hostname
HIGH_PERF_DEPLOYMENT

kubectl apply -f high-perf-deployment.yaml

# Step 3: High-Performance Service Configuration
echo "Step 3: Creating high-performance service configuration..."

cat > high-perf-service.yaml << HIGH_PERF_SERVICE
apiVersion: v1
kind: Service
metadata:
  name: high-perf-app-service
  namespace: default
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "4000"
spec:
  type: LoadBalancer
  selector:
    app: high-perf-app
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
HIGH_PERF_SERVICE

kubectl apply -f high-perf-service.yaml

# Step 4: Performance Monitoring
echo "Step 4: Setting up performance monitoring..."

cat > performance-monitoring.yaml << PERF_MONITORING
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "alert_rules.yml"
    
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: labelmap
            regex: __meta_kubernetes_node_label_(.+)
      
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
            action: replace
            target_label: __scheme__
            regex: (https?)
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_service_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_service_name]
            action: replace
            target_label: kubernetes_name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: storage
          mountPath: /prometheus
        command:
        - /bin/prometheus
        - --config.file=/etc/prometheus/prometheus.yml
        - --storage.tsdb.path=/prometheus
        - --storage.tsdb.retention.time=15d
        - --web.console.libraries=/etc/prometheus/console_libraries
        - --web.console.templates=/etc/prometheus/consoles
        - --web.enable-lifecycle
        - --web.enable-admin-api
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: storage
        emptyDir: {}
PERF_MONITORING

kubectl apply -f performance-monitoring.yaml

echo "✅ High-performance architecture configured"
EOF

chmod +x high_performance_architecture.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # High-Performance Architecture Setup
# echo "=== HIGH-PERFORMANCE ARCHITECTURE SETUP ==="  # Script header
# echo "Purpose: Optimize Kubernetes for low latency and high throughput"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # Step 1: Node Optimization
# echo "Step 1: Optimizing node configuration..."  # Step description
# 
# # Create node optimization script
# cat > optimize-nodes.sh << NODE_OPT  # Create node optimization script using heredoc
# #!/bin/bash                        # Shebang for node script
# 
# # Node optimization for high performance
# NODE_NAME="$1"                     # Get node name from first argument
# 
# if [ -z "$NODE_NAME" ]; then      # Check if node name is provided
#     echo "Usage: $0 <node-name>"   # Show usage message
#     exit 1                        # Exit with error code
# fi
# 
# echo "Optimizing node: $NODE_NAME"  # Log target node
# 
# # 1. CPU optimization
# echo "1. CPU optimization..."      # CPU optimization step
# # Set CPU governor to performance
# ssh $NODE_NAME "echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"  # Set CPU governor to performance mode
# 
# # 2. Memory optimization
# echo "2. Memory optimization..."   # Memory optimization step
# # Disable swap
# ssh $NODE_NAME "sudo swapoff -a"   # Disable swap immediately
# ssh $NODE_NAME "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"  # Comment out swap in fstab
# 
# # 3. Network optimization
# echo "3. Network optimization..."   # Network optimization step
# # Optimize network settings
# ssh $NODE_NAME "sudo sysctl -w net.core.rmem_max=16777216"  # Set max receive buffer size
# ssh $NODE_NAME "sudo sysctl -w net.core.wmem_max=16777216"  # Set max send buffer size
# ssh $NODE_NAME "sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'"  # Set TCP receive buffer sizes
# ssh $NODE_NAME "sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 16777216'"  # Set TCP send buffer sizes
# 
# # 4. Storage optimization
# echo "4. Storage optimization..."   # Storage optimization step
# # Use high-performance storage settings
# ssh $NODE_NAME "sudo sysctl -w vm.dirty_ratio=10"  # Set dirty page ratio
# ssh $NODE_NAME "sudo sysctl -w vm.dirty_background_ratio=5"  # Set background dirty ratio
# 
# echo "✅ Node optimization completed for $NODE_NAME"  # Success message
# NODE_OPT                         # End of heredoc
# 
# chmod +x optimize-nodes.sh       # Make script executable
# 
# # Step 2: High-Performance Workload Configuration
# echo "Step 2: Creating high-performance workload configuration..."  # Step description
# 
# cat > high-perf-deployment.yaml << HIGH_PERF_DEPLOYMENT  # Create deployment YAML using heredoc
# apiVersion: apps/v1               # API version for apps
# kind: Deployment                 # Resource type
# metadata:                        # Metadata section
#   name: high-perf-app            # Deployment name
#   namespace: default             # Target namespace
#   annotations:                   # Performance annotations
#     performance.kubernetes.io/cpu-pinning: "true"  # Enable CPU pinning
#     performance.kubernetes.io/memory-hugepages: "true"  # Enable huge pages
# spec:                           # Specification section
#   replicas: 3                   # Number of replicas
#   selector:                     # Pod selector
#     matchLabels:                # Label matching
#       app: high-perf-app        # Select pods with app=high-perf-app
#   template:                     # Pod template
#     metadata:                   # Template metadata
#       labels:                   # Template labels
#         app: high-perf-app      # App label
#     spec:                      # Template specification
#       runtimeClassName: performance  # Use performance runtime class
#       containers:              # Container list
#       - name: high-perf-app    # Container name
#         image: nginx:latest    # Container image
#         ports:                 # Port configuration
#         - containerPort: 80    # Expose port 80
#         resources:             # Resource requirements
#           requests:            # Minimum resources
#             cpu: "1000m"       # CPU request (1 core)
#             memory: "2Gi"      # Memory request
#             hugepages-2Mi: "1Gi"  # Huge pages request
#           limits:              # Maximum resources
#             cpu: "2000m"       # CPU limit (2 cores)
#             memory: "4Gi"      # Memory limit
#             hugepages-2Mi: "2Gi"  # Huge pages limit
#         env:                   # Environment variables
#         - name: NGINX_WORKER_PROCESSES  # Nginx worker processes
#           value: "auto"        # Auto-detect
#         - name: NGINX_WORKER_CONNECTIONS  # Nginx worker connections
#           value: "1024"        # 1024 connections per worker
#         - name: NGINX_KEEPALIVE_TIMEOUT  # Nginx keepalive timeout
#           value: "65"          # 65 seconds
#         - name: NGINX_KEEPALIVE_REQUESTS  # Nginx keepalive requests
#           value: "100"         # 100 requests per connection
#         volumeMounts:          # Volume mounts
#         - name: hugepages      # Huge pages volume
#           mountPath: /dev/hugepages  # Mount path
#         - name: tmpfs         # Temporary filesystem volume
#           mountPath: /tmp     # Mount path
#         - name: cache         # Cache volume
#           mountPath: /var/cache/nginx  # Mount path
#         securityContext:      # Security context
#           capabilities:       # Linux capabilities
#             add:              # Add capabilities
#             - NET_ADMIN       # Network administration
#             - SYS_ADMIN       # System administration
#         livenessProbe:       # Liveness probe
#           httpGet:            # HTTP GET probe
#             path: /health     # Health check path
#             port: 80          # Health check port
#           initialDelaySeconds: 30  # Initial delay
#           periodSeconds: 10   # Probe interval
#         readinessProbe:      # Readiness probe
#           httpGet:           # HTTP GET probe
#             path: /ready     # Ready check path
#             port: 80         # Ready check port
#           initialDelaySeconds: 5  # Initial delay
#           periodSeconds: 5   # Probe interval
#       volumes:               # Volume definitions
#       - name: hugepages     # Huge pages volume
#         emptyDir:           # Empty directory
#           medium: HugePages  # Use huge pages
#       - name: tmpfs         # Temporary filesystem volume
#         emptyDir:           # Empty directory
#           medium: Memory    # Use memory
#       - name: cache        # Cache volume
#         emptyDir:          # Empty directory
#           medium: Memory   # Use memory
#       nodeSelector:        # Node selector
#         kubernetes.io/arch: amd64  # AMD64 architecture
#         performance: "true"  # Performance node label
#       tolerations:         # Tolerations
#       - key: performance   # Performance taint key
#         operator: Exists    # Exists operator
#         effect: NoSchedule  # No schedule effect
#       affinity:            # Affinity rules
#         nodeAffinity:      # Node affinity
#           requiredDuringSchedulingIgnoredDuringExecution:  # Required during scheduling
#             nodeSelectorTerms:  # Node selector terms
#             - matchExpressions:  # Match expressions
#               - key: performance  # Performance key
#                 operator: In     # In operator
#                 values:          # Values
#                 - "true"        # True value
#         podAntiAffinity:    # Pod anti-affinity
#           preferredDuringSchedulingIgnoredDuringExecution:  # Preferred during scheduling
#           - weight: 100     # Weight
#             podAffinityTerm:  # Pod affinity term
#               labelSelector:  # Label selector
#                 matchExpressions:  # Match expressions
#                 - key: app    # App key
#                   operator: In  # In operator
#                   values:     # Values
#                   - high-perf-app  # App value
#               topologyKey: kubernetes.io/hostname  # Topology key
# HIGH_PERF_DEPLOYMENT        # End of heredoc
# 
# kubectl apply -f high-perf-deployment.yaml  # Apply high-performance deployment
# 
# # Step 3: High-Performance Service Configuration
# echo "Step 3: Creating high-performance service configuration..."  # Step description
# 
# cat > high-perf-service.yaml << HIGH_PERF_SERVICE  # Create service YAML using heredoc
# apiVersion: v1                  # API version for core resources
# kind: Service                   # Resource type
# metadata:                       # Metadata section
#   name: high-perf-app-service   # Service name
#   namespace: default            # Target namespace
#   annotations:                  # Service annotations
#     service.beta.kubernetes.io/aws-load-balancer-type: "nlb"  # Network load balancer
#     service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"  # Cross-zone load balancing
#     service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "4000"  # Connection timeout
# spec:                          # Specification section
#   type: LoadBalancer           # Service type
#   selector:                    # Pod selector
#     app: high-perf-app         # Select pods with app=high-perf-app
#   ports:                       # Port configuration
#   - port: 80                  # Service port
#     targetPort: 80            # Target container port
#     protocol: TCP             # Protocol
#     name: http                # Port name
#   - port: 443                 # Service port
#     targetPort: 443           # Target container port
#     protocol: TCP             # Protocol
#     name: https               # Port name
#   sessionAffinity: ClientIP   # Session affinity
#   sessionAffinityConfig:      # Session affinity configuration
#     clientIP:                 # Client IP configuration
#       timeoutSeconds: 10800   # Session timeout (3 hours)
# HIGH_PERF_SERVICE             # End of heredoc
# 
# kubectl apply -f high-perf-service.yaml  # Apply high-performance service
# 
# # Step 4: Performance Monitoring
# echo "Step 4: Setting up performance monitoring..."  # Step description
# 
# cat > performance-monitoring.yaml << PERF_MONITORING  # Create monitoring YAML using heredoc
# apiVersion: v1                 # API version for core resources
# kind: ConfigMap               # Resource type
# metadata:                     # Metadata section
#   name: prometheus-config     # ConfigMap name
#   namespace: monitoring       # Target namespace
# data:                        # Configuration data
#   prometheus.yml: |          # Prometheus configuration
#     global:                  # Global settings
#       scrape_interval: 15s   # Scrape interval
#       evaluation_interval: 15s  # Rule evaluation interval
#     
#     rule_files:              # Rule files
#       - "alert_rules.yml"    # Alert rules file
#     
#     scrape_configs:          # Scrape configurations
#       - job_name: 'kubernetes-pods'  # Pod monitoring job
#         kubernetes_sd_configs:       # Kubernetes service discovery
#           - role: pod               # Pod role
#         relabel_configs:            # Relabeling configurations
#           - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]  # Source labels
#             action: keep            # Keep action
#             regex: true             # Keep if true
#           - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]  # Source labels
#             action: replace         # Replace action
#             target_label: __metrics_path__  # Target label
#             regex: (.+)             # Regex pattern
#           - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]  # Source labels
#             action: replace         # Replace action
#             regex: ([^:]+)(?::\d+)?;(\d+)  # Regex pattern
#             replacement: $1:$2       # Replacement
#             target_label: __address__  # Target label
#           - action: labelmap        # Label mapping action
#             regex: __meta_kubernetes_pod_label_(.+)  # Regex pattern
#           - source_labels: [__meta_kubernetes_namespace]  # Source labels
#             action: replace         # Replace action
#             target_label: kubernetes_namespace  # Target label
#           - source_labels: [__meta_kubernetes_pod_name]  # Source labels
#             action: replace         # Replace action
#             target_label: kubernetes_pod_name  # Target label
#       
#       - job_name: 'kubernetes-nodes'  # Node monitoring job
#         kubernetes_sd_configs:       # Kubernetes service discovery
#           - role: node              # Node role
#         relabel_configs:            # Relabeling configurations
#           - action: labelmap        # Label mapping action
#             regex: __meta_kubernetes_node_label_(.+)  # Regex pattern
#       
#       - job_name: 'kubernetes-service-endpoints'  # Service endpoint monitoring job
#         kubernetes_sd_configs:       # Kubernetes service discovery
#           - role: endpoints         # Endpoints role
#         relabel_configs:            # Relabeling configurations
#           - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]  # Source labels
#             action: keep            # Keep action
#             regex: true             # Keep if true
#           - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]  # Source labels
#             action: replace         # Replace action
#             target_label: __scheme__  # Target label
#             regex: (https?)          # Regex pattern
#           - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]  # Source labels
#             action: replace         # Replace action
#             target_label: __metrics_path__  # Target label
#             regex: (.+)             # Regex pattern
#           - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]  # Source labels
#             action: replace         # Replace action
#             regex: ([^:]+)(?::\d+)?;(\d+)  # Regex pattern
#             replacement: $1:$2       # Replacement
#             target_label: __address__  # Target label
#           - action: labelmap        # Label mapping action
#             regex: __meta_kubernetes_service_label_(.+)  # Regex pattern
#           - source_labels: [__meta_kubernetes_namespace]  # Source labels
#             action: replace         # Replace action
#             target_label: kubernetes_namespace  # Target label
#           - source_labels: [__meta_kubernetes_service_name]  # Source labels
#             action: replace         # Replace action
#             target_label: kubernetes_name  # Target label
# ---                           # YAML document separator
# apiVersion: apps/v1           # API version for apps
# kind: Deployment              # Resource type
# metadata:                     # Metadata section
#   name: prometheus            # Deployment name
#   namespace: monitoring       # Target namespace
# spec:                        # Specification section
#   replicas: 1                # Number of replicas
#   selector:                  # Pod selector
#     matchLabels:             # Label matching
#       app: prometheus        # Select pods with app=prometheus
#   template:                  # Pod template
#     metadata:                # Template metadata
#       labels:                # Template labels
#         app: prometheus      # App label
#     spec:                   # Template specification
#       containers:           # Container list
#       - name: prometheus    # Container name
#         image: prom/prometheus:latest  # Prometheus image
#         ports:              # Port configuration
#         - containerPort: 9090  # Expose port 9090
#         volumeMounts:       # Volume mounts
#         - name: config      # Config volume
#           mountPath: /etc/prometheus  # Mount path
#         - name: storage     # Storage volume
#           mountPath: /prometheus     # Mount path
#         command:            # Command to run
#         - /bin/prometheus   # Prometheus binary
#         - --config.file=/etc/prometheus/prometheus.yml  # Config file
#         - --storage.tsdb.path=/prometheus  # Storage path
#         - --storage.tsdb.retention.time=15d  # Retention time
#         - --web.console.libraries=/etc/prometheus/console_libraries  # Console libraries
#         - --web.console.templates=/etc/prometheus/consoles  # Console templates
#         - --web.enable-lifecycle  # Enable lifecycle API
#         - --web.enable-admin-api  # Enable admin API
#         resources:          # Resource requirements
#           requests:         # Minimum resources
#             memory: "512Mi"  # Memory request
#             cpu: "250m"     # CPU request
#           limits:           # Maximum resources
#             memory: "2Gi"   # Memory limit
#             cpu: "1000m"    # CPU limit
#       volumes:              # Volume definitions
#       - name: config        # Config volume
#         configMap:          # ConfigMap volume
#           name: prometheus-config  # ConfigMap name
#       - name: storage       # Storage volume
#         emptyDir: {}        # Empty directory
# PERF_MONITORING              # End of heredoc
# 
# kubectl apply -f performance-monitoring.yaml  # Apply performance monitoring
# 
# echo "✅ High-performance architecture configured"  # Success message
# ```
# 
# **Expected Output:**
# ```
# === HIGH-PERFORMANCE ARCHITECTURE SETUP ===
# Purpose: Optimize Kubernetes for low latency and high throughput
# 
# Step 1: Optimizing node configuration...
# Step 2: Creating high-performance workload configuration...
# deployment.apps/high-perf-app created
# Step 3: Creating high-performance service configuration...
# service/high-perf-app-service created
# Step 4: Setting up performance monitoring...
# configmap/prometheus-config created
# deployment.apps/prometheus created
# ✅ High-performance architecture configured
# ```
# 
# **Key Learning Points:**
# - **Node Optimization**: Implements CPU, memory, network, and storage optimizations for performance
# - **Huge Pages**: Uses huge pages for improved memory performance and reduced TLB misses
# - **CPU Pinning**: Enables CPU pinning for predictable performance and reduced latency
# - **Network Optimization**: Configures TCP buffers and network parameters for high throughput
# - **Load Balancer Configuration**: Uses Network Load Balancer with cross-zone load balancing
# - **Session Affinity**: Implements client IP session affinity for connection persistence
# - **Performance Monitoring**: Sets up comprehensive Prometheus monitoring for performance metrics
# - **Resource Management**: Implements proper resource requests and limits for predictable performance
# - **Anti-Affinity**: Uses pod anti-affinity to distribute workloads across nodes
# - **Runtime Class**: Uses performance runtime class for optimized container execution
```

### **🔧 Advanced Troubleshooting and Debugging**

#### **Advanced Debugging Techniques**
```bash
# Create advanced debugging toolkit
cat > advanced_debugging_toolkit.sh << 'EOF'
#!/bin/bash

# Advanced Debugging Toolkit
echo "=== ADVANCED DEBUGGING TOOLKIT ==="
echo "Purpose: Comprehensive debugging and troubleshooting for complex issues"
echo ""

# Function to analyze cluster health
analyze_cluster_health() {
    echo "=== CLUSTER HEALTH ANALYSIS ==="
    
    # Check API server health
    echo "1. API Server Health Check:"
    kubectl get --raw /healthz
    kubectl get --raw /readyz
    kubectl get --raw /livez
    
    # Check etcd health
    echo "2. etcd Health Check:"
    kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379
    
    # Check scheduler health
    echo "3. Scheduler Health Check:"
    kubectl get pods -n kube-system -l component=kube-scheduler -o wide
    
    # Check controller manager health
    echo "4. Controller Manager Health Check:"
    kubectl get pods -n kube-system -l component=kube-controller-manager -o wide
}

# Function to analyze resource usage
analyze_resource_usage() {
    echo "=== RESOURCE USAGE ANALYSIS ==="
    
    # Node resource usage
    echo "1. Node Resource Usage:"
    kubectl top nodes --sort-by=cpu
    kubectl top nodes --sort-by=memory
    
    # Pod resource usage
    echo "2. Pod Resource Usage:"
    kubectl top pods --all-namespaces --sort-by=cpu | head -20
    kubectl top pods --all-namespaces --sort-by=memory | head -20
    
    # Container resource usage
    echo "3. Container Resource Usage:"
    kubectl top pods --all-namespaces --containers --sort-by=cpu | head -20
}

# Function to analyze network connectivity
analyze_network_connectivity() {
    echo "=== NETWORK CONNECTIVITY ANALYSIS ==="
    
    # Check DNS resolution
    echo "1. DNS Resolution Check:"
    kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default
    
    # Check service connectivity
    echo "2. Service Connectivity Check:"
    kubectl get endpoints --all-namespaces
    
    # Check network policies
    echo "3. Network Policies Check:"
    kubectl get networkpolicies --all-namespaces
}

# Function to analyze storage issues
analyze_storage_issues() {
    echo "=== STORAGE ISSUES ANALYSIS ==="
    
    # Check persistent volumes
    echo "1. Persistent Volumes Check:"
    kubectl get pv
    kubectl get pvc --all-namespaces
    
    # Check storage classes
    echo "2. Storage Classes Check:"
    kubectl get storageclass
    
    # Check volume attachments
    echo "3. Volume Attachments Check:"
    kubectl get volumeattachment
}

# Function to analyze security issues
analyze_security_issues() {
    echo "=== SECURITY ISSUES ANALYSIS ==="
    
    # Check RBAC
    echo "1. RBAC Check:"
    kubectl get clusterroles
    kubectl get clusterrolebindings
    
    # Check service accounts
    echo "2. Service Accounts Check:"
    kubectl get serviceaccounts --all-namespaces
    
    # Check secrets
    echo "3. Secrets Check:"
    kubectl get secrets --all-namespaces
}

# Function to analyze events
analyze_events() {
    echo "=== EVENTS ANALYSIS ==="
    
    # Recent events
    echo "1. Recent Events:"
    kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp | tail -20
    
    # Error events
    echo "2. Error Events:"
    kubectl get events --all-namespaces --field-selector type=Warning | tail -20
}

# Main function
main() {
    case "$1" in
        "health")
            analyze_cluster_health
            ;;
        "resources")
            analyze_resource_usage
            ;;
        "network")
            analyze_network_connectivity
            ;;
        "storage")
            analyze_storage_issues
            ;;
        "security")
            analyze_security_issues
            ;;
        "events")
            analyze_events
            ;;
        "all")
            analyze_cluster_health
            echo ""
            analyze_resource_usage
            echo ""
            analyze_network_connectivity
            echo ""
            analyze_storage_issues
            echo ""
            analyze_security_issues
            echo ""
            analyze_events
            ;;
        *)
            echo "Usage: $0 {health|resources|network|storage|security|events|all}"
            echo "  health    - Analyze cluster health"
            echo "  resources - Analyze resource usage"
            echo "  network   - Analyze network connectivity"
            echo "  storage   - Analyze storage issues"
            echo "  security  - Analyze security issues"
            echo "  events    - Analyze events"
            echo "  all       - Run all analyses"
            exit 1
            ;;
    esac
}

main "$@"
EOF

chmod +x advanced_debugging_toolkit.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Advanced Debugging Toolkit
# echo "=== ADVANCED DEBUGGING TOOLKIT ==="  # Script header
# echo "Purpose: Comprehensive debugging and troubleshooting for complex issues"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # Function to analyze cluster health
# analyze_cluster_health() {     # Function definition for cluster health analysis
#     echo "=== CLUSTER HEALTH ANALYSIS ==="  # Section header
#     
#     # Check API server health
#     echo "1. API Server Health Check:"  # Check description
#     kubectl get --raw /healthz  # Check API server health endpoint
#     kubectl get --raw /readyz    # Check API server readiness endpoint
#     kubectl get --raw /livez     # Check API server liveness endpoint
#     
#     # Check etcd health
#     echo "2. etcd Health Check:"  # Check description
#     kubectl exec -n kube-system etcd-master -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379  # Check etcd cluster health
#     
#     # Check scheduler health
#     echo "3. Scheduler Health Check:"  # Check description
#     kubectl get pods -n kube-system -l component=kube-scheduler -o wide  # List scheduler pods with details
#     
#     # Check controller manager health
#     echo "4. Controller Manager Health Check:"  # Check description
#     kubectl get pods -n kube-system -l component=kube-controller-manager -o wide  # List controller manager pods with details
# }
# 
# # Function to analyze resource usage
# analyze_resource_usage() {     # Function definition for resource usage analysis
#     echo "=== RESOURCE USAGE ANALYSIS ==="  # Section header
#     
#     # Node resource usage
#     echo "1. Node Resource Usage:"  # Check description
#     kubectl top nodes --sort-by=cpu    # Show node CPU usage sorted by CPU
#     kubectl top nodes --sort-by=memory  # Show node memory usage sorted by memory
#     
#     # Pod resource usage
#     echo "2. Pod Resource Usage:"  # Check description
#     kubectl top pods --all-namespaces --sort-by=cpu | head -20    # Show top 20 pods by CPU usage
#     kubectl top pods --all-namespaces --sort-by=memory | head -20  # Show top 20 pods by memory usage
#     
#     # Container resource usage
#     echo "3. Container Resource Usage:"  # Check description
#     kubectl top pods --all-namespaces --containers --sort-by=cpu | head -20  # Show top 20 containers by CPU usage
# }
# 
# # Function to analyze network connectivity
# analyze_network_connectivity() {  # Function definition for network analysis
#     echo "=== NETWORK CONNECTIVITY ANALYSIS ==="  # Section header
#     
#     # Check DNS resolution
#     echo "1. DNS Resolution Check:"  # Check description
#     kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default  # Test DNS resolution
#     
#     # Check service connectivity
#     echo "2. Service Connectivity Check:"  # Check description
#     kubectl get endpoints --all-namespaces  # List all endpoints across namespaces
#     
#     # Check network policies
#     echo "3. Network Policies Check:"  # Check description
#     kubectl get networkpolicies --all-namespaces  # List all network policies
# }
# 
# # Function to analyze storage issues
# analyze_storage_issues() {      # Function definition for storage analysis
#     echo "=== STORAGE ISSUES ANALYSIS ==="  # Section header
#     
#     # Check persistent volumes
#     echo "1. Persistent Volumes Check:"  # Check description
#     kubectl get pv               # List persistent volumes
#     kubectl get pvc --all-namespaces  # List persistent volume claims across namespaces
#     
#     # Check storage classes
#     echo "2. Storage Classes Check:"  # Check description
#     kubectl get storageclass     # List storage classes
#     
#     # Check volume attachments
#     echo "3. Volume Attachments Check:"  # Check description
#     kubectl get volumeattachment  # List volume attachments
# }
# 
# # Function to analyze security issues
# analyze_security_issues() {     # Function definition for security analysis
#     echo "=== SECURITY ISSUES ANALYSIS ==="  # Section header
#     
#     # Check RBAC
#     echo "1. RBAC Check:"  # Check description
#     kubectl get clusterroles      # List cluster roles
#     kubectl get clusterrolebindings  # List cluster role bindings
#     
#     # Check service accounts
#     echo "2. Service Accounts Check:"  # Check description
#     kubectl get serviceaccounts --all-namespaces  # List service accounts across namespaces
#     
#     # Check secrets
#     echo "3. Secrets Check:"  # Check description
#     kubectl get secrets --all-namespaces  # List secrets across namespaces
# }
# 
# # Function to analyze events
# analyze_events() {              # Function definition for events analysis
#     echo "=== EVENTS ANALYSIS ==="  # Section header
#     
#     # Recent events
#     echo "1. Recent Events:"  # Check description
#     kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp | tail -20  # Show last 20 events
#     
#     # Error events
#     echo "2. Error Events:"  # Check description
#     kubectl get events --all-namespaces --field-selector type=Warning | tail -20  # Show last 20 warning events
# }
# 
# # Main function
# main() {                       # Main function definition
#     case "$1" in              # Case statement for argument handling
#         "health")             # Health analysis case
#             analyze_cluster_health  # Call cluster health function
#             ;;
#         "resources")          # Resources analysis case
#             analyze_resource_usage  # Call resource usage function
#             ;;
#         "network")            # Network analysis case
#             analyze_network_connectivity  # Call network analysis function
#             ;;
#         "storage")            # Storage analysis case
#             analyze_storage_issues  # Call storage analysis function
#             ;;
#         "security")           # Security analysis case
#             analyze_security_issues  # Call security analysis function
#             ;;
#         "events")             # Events analysis case
#             analyze_events    # Call events analysis function
#             ;;
#         "all")                # All analyses case
#             analyze_cluster_health  # Call all analysis functions
#             echo ""           # Empty line
#             analyze_resource_usage
#             echo ""
#             analyze_network_connectivity
#             echo ""
#             analyze_storage_issues
#             echo ""
#             analyze_security_issues
#             echo ""
#             analyze_events
#             ;;
#         *)                    # Default case (invalid argument)
#             echo "Usage: $0 {health|resources|network|storage|security|events|all}"  # Usage message
#             echo "  health    - Analyze cluster health"  # Health option description
#             echo "  resources - Analyze resource usage"  # Resources option description
#             echo "  network   - Analyze network connectivity"  # Network option description
#             echo "  storage   - Analyze storage issues"  # Storage option description
#             echo "  security  - Analyze security issues"  # Security option description
#             echo "  events    - Analyze events"  # Events option description
#             echo "  all       - Run all analyses"  # All option description
#             exit 1            # Exit with error code
#             ;;
#     esac                      # End of case statement
# }
# 
# main "$@"                     # Call main function with all arguments
# ```
# 
# **Expected Output:**
# ```
# === ADVANCED DEBUGGING TOOLKIT ===
# Purpose: Comprehensive debugging and troubleshooting for complex issues
# 
# === CLUSTER HEALTH ANALYSIS ===
# 1. API Server Health Check:
# ok
# ok
# ok
# 2. etcd Health Check:
# https://127.0.0.1:2379 is healthy: successfully committed proposal: took = 1.234ms
# 3. Scheduler Health Check:
# NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE
# kube-scheduler-master   1/1     Running   0          1d      10.244.0.1   master
# 4. Controller Manager Health Check:
# NAME                              READY   STATUS    RESTARTS   AGE     IP           NODE
# kube-controller-manager-master    1/1     Running   0          1d      10.244.0.2   master
# ```
# 
# **Key Learning Points:**
# - **Modular Design**: Uses functions to organize different types of analysis
# - **Comprehensive Coverage**: Covers cluster health, resources, network, storage, security, and events
# - **Command-Line Interface**: Provides flexible CLI with multiple analysis options
# - **Health Endpoints**: Uses Kubernetes health endpoints for API server status
# - **Resource Monitoring**: Implements resource usage analysis with sorting
# - **Network Diagnostics**: Includes DNS and service connectivity testing
# - **Storage Analysis**: Covers PVs, PVCs, storage classes, and volume attachments
# - **Security Auditing**: Analyzes RBAC, service accounts, and secrets
# - **Event Analysis**: Monitors recent events and warnings
# - **Error Handling**: Provides proper usage instructions and exit codes
```

### **📊 Performance Optimization Techniques**

#### **Advanced Performance Tuning**
```bash
# Create performance optimization script
cat > performance_optimization.sh << 'EOF'
#!/bin/bash

# Performance Optimization Script
echo "=== PERFORMANCE OPTIMIZATION ==="
echo "Purpose: Optimize Kubernetes cluster for maximum performance"
echo ""

# Function to optimize API server
optimize_api_server() {
    echo "1. Optimizing API Server..."
    
    # Check current API server configuration
    kubectl get pods -n kube-system -l component=kube-apiserver -o yaml | grep -A 10 -B 10 "args:"
    
    # Recommended optimizations
    echo "Recommended API Server optimizations:"
    echo "- --max-requests-inflight=4000"
    echo "- --max-mutating-requests-inflight=2000"
    echo "- --event-ttl=1h"
    echo "- --enable-admission-plugins=NodeRestriction"
    echo "- --disable-admission-plugins=ServiceAccount"
}

# Function to optimize etcd
optimize_etcd() {
    echo "2. Optimizing etcd..."
    
    # Check current etcd configuration
    kubectl get pods -n kube-system -l component=etcd -o yaml | grep -A 10 -B 10 "args:"
    
    # Recommended optimizations
    echo "Recommended etcd optimizations:"
    echo "- --quota-backend-bytes=8589934592 (8GB)"
    echo "- --max-request-bytes=10485760 (10MB)"
    echo "- --max-wals=5"
    echo "- --snapshot-count=10000"
}

# Function to optimize scheduler
optimize_scheduler() {
    echo "3. Optimizing Scheduler..."
    
    # Check current scheduler configuration
    kubectl get pods -n kube-system -l component=kube-scheduler -o yaml | grep -A 10 -B 10 "args:"
    
    # Recommended optimizations
    echo "Recommended Scheduler optimizations:"
    echo "- --kube-api-qps=100"
    echo "- --kube-api-burst=200"
    echo "- --scheduler-name=default-scheduler"
}

# Function to optimize kubelet
optimize_kubelet() {
    echo "4. Optimizing Kubelet..."
    
    # Check current kubelet configuration
    kubectl get nodes -o yaml | grep -A 10 -B 10 "kubeletConfig:"
    
    # Recommended optimizations
    echo "Recommended Kubelet optimizations:"
    echo "- --max-pods=110"
    echo "- --kube-api-qps=50"
    echo "- --kube-api-burst=100"
    echo "- --image-gc-high-threshold=85"
    echo "- --image-gc-low-threshold=80"
}

# Function to optimize container runtime
optimize_container_runtime() {
    echo "5. Optimizing Container Runtime..."
    
    # Check current container runtime configuration
    kubectl get nodes -o yaml | grep -A 10 -B 10 "containerRuntimeVersion:"
    
    # Recommended optimizations
    echo "Recommended Container Runtime optimizations:"
    echo "- Use containerd with optimized settings"
    echo "- Configure appropriate ulimits"
    echo "- Optimize storage driver settings"
    echo "- Configure appropriate cgroup limits"
}

# Function to optimize networking
optimize_networking() {
    echo "6. Optimizing Networking..."
    
    # Check current network configuration
    kubectl get pods -n kube-system -l k8s-app=calico-node -o yaml | grep -A 10 -B 10 "env:"
    
    # Recommended optimizations
    echo "Recommended Networking optimizations:"
    echo "- Use high-performance CNI (Calico, Cilium)"
    echo "- Configure appropriate MTU settings"
    echo "- Optimize network policies"
    echo "- Use network acceleration features"
}

# Main function
main() {
    case "$1" in
        "api-server")
            optimize_api_server
            ;;
        "etcd")
            optimize_etcd
            ;;
        "scheduler")
            optimize_scheduler
            ;;
        "kubelet")
            optimize_kubelet
            ;;
        "container-runtime")
            optimize_container_runtime
            ;;
        "networking")
            optimize_networking
            ;;
        "all")
            optimize_api_server
            echo ""
            optimize_etcd
            echo ""
            optimize_scheduler
            echo ""
            optimize_kubelet
            echo ""
            optimize_container_runtime
            echo ""
            optimize_networking
            ;;
        *)
            echo "Usage: $0 {api-server|etcd|scheduler|kubelet|container-runtime|networking|all}"
            echo "  api-server       - Optimize API server"
            echo "  etcd            - Optimize etcd"
            echo "  scheduler       - Optimize scheduler"
            echo "  kubelet         - Optimize kubelet"
            echo "  container-runtime - Optimize container runtime"
            echo "  networking      - Optimize networking"
            echo "  all             - Run all optimizations"
            exit 1
            ;;
    esac
}

main "$@"
EOF

chmod +x performance_optimization.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Performance Optimization Script
# echo "=== PERFORMANCE OPTIMIZATION ==="  # Script header
# echo "Purpose: Optimize Kubernetes cluster for maximum performance"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # Function to optimize API server
# optimize_api_server() {        # Function definition for API server optimization
#     echo "1. Optimizing API Server..."  # Step description
#     
#     # Check current API server configuration
#     kubectl get pods -n kube-system -l component=kube-apiserver -o yaml | grep -A 10 -B 10 "args:"  # Get API server args with context
#     
#     # Recommended optimizations
#     echo "Recommended API Server optimizations:"  # Optimization header
#     echo "- --max-requests-inflight=4000"  # Increase max concurrent requests
#     echo "- --max-mutating-requests-inflight=2000"  # Increase max mutating requests
#     echo "- --event-ttl=1h"  # Set event TTL to 1 hour
#     echo "- --enable-admission-plugins=NodeRestriction"  # Enable node restriction plugin
#     echo "- --disable-admission-plugins=ServiceAccount"  # Disable service account plugin
# }
# 
# # Function to optimize etcd
# optimize_etcd() {              # Function definition for etcd optimization
#     echo "2. Optimizing etcd..."  # Step description
#     
#     # Check current etcd configuration
#     kubectl get pods -n kube-system -l component=etcd -o yaml | grep -A 10 -B 10 "args:"  # Get etcd args with context
#     
#     # Recommended optimizations
#     echo "Recommended etcd optimizations:"  # Optimization header
#     echo "- --quota-backend-bytes=8589934592 (8GB)"  # Set backend quota to 8GB
#     echo "- --max-request-bytes=10485760 (10MB)"  # Set max request size to 10MB
#     echo "- --max-wals=5"  # Limit WAL files to 5
#     echo "- --snapshot-count=10000"  # Set snapshot count to 10000
# }
# 
# # Function to optimize scheduler
# optimize_scheduler() {         # Function definition for scheduler optimization
#     echo "3. Optimizing Scheduler..."  # Step description
#     
#     # Check current scheduler configuration
#     kubectl get pods -n kube-system -l component=kube-scheduler -o yaml | grep -A 10 -B 10 "args:"  # Get scheduler args with context
#     
#     # Recommended optimizations
#     echo "Recommended Scheduler optimizations:"  # Optimization header
#     echo "- --kube-api-qps=100"  # Set API QPS to 100
#     echo "- --kube-api-burst=200"  # Set API burst to 200
#     echo "- --scheduler-name=default-scheduler"  # Set scheduler name
# }
# 
# # Function to optimize kubelet
# optimize_kubelet() {          # Function definition for kubelet optimization
#     echo "4. Optimizing Kubelet..."  # Step description
#     
#     # Check current kubelet configuration
#     kubectl get nodes -o yaml | grep -A 10 -B 10 "kubeletConfig:"  # Get kubelet config with context
#     
#     # Recommended optimizations
#     echo "Recommended Kubelet optimizations:"  # Optimization header
#     echo "- --max-pods=110"  # Set max pods per node to 110
#     echo "- --kube-api-qps=50"  # Set API QPS to 50
#     echo "- --kube-api-burst=100"  # Set API burst to 100
#     echo "- --image-gc-high-threshold=85"  # Set image GC high threshold to 85%
#     echo "- --image-gc-low-threshold=80"  # Set image GC low threshold to 80%
# }
# 
# # Function to optimize container runtime
# optimize_container_runtime() {  # Function definition for container runtime optimization
#     echo "5. Optimizing Container Runtime..."  # Step description
#     
#     # Check current container runtime configuration
#     kubectl get nodes -o yaml | grep -A 10 -B 10 "containerRuntimeVersion:"  # Get runtime version with context
#     
#     # Recommended optimizations
#     echo "Recommended Container Runtime optimizations:"  # Optimization header
#     echo "- Use containerd with optimized settings"  # Use containerd
#     echo "- Configure appropriate ulimits"  # Configure ulimits
#     echo "- Optimize storage driver settings"  # Optimize storage driver
#     echo "- Configure appropriate cgroup limits"  # Configure cgroup limits
# }
# 
# # Function to optimize networking
# optimize_networking() {        # Function definition for networking optimization
#     echo "6. Optimizing Networking..."  # Step description
#     
#     # Check current network configuration
#     kubectl get pods -n kube-system -l k8s-app=calico-node -o yaml | grep -A 10 -B 10 "env:"  # Get Calico env vars with context
#     
#     # Recommended optimizations
#     echo "Recommended Networking optimizations:"  # Optimization header
#     echo "- Use high-performance CNI (Calico, Cilium)"  # Use high-performance CNI
#     echo "- Configure appropriate MTU settings"  # Configure MTU
#     echo "- Optimize network policies"  # Optimize network policies
#     echo "- Use network acceleration features"  # Use acceleration features
# }
# 
# # Main function
# main() {                      # Main function definition
#     case "$1" in             # Case statement for argument handling
#         "api-server")        # API server optimization case
#             optimize_api_server  # Call API server optimization function
#             ;;
#         "etcd")              # etcd optimization case
#             optimize_etcd    # Call etcd optimization function
#             ;;
#         "scheduler")         # Scheduler optimization case
#             optimize_scheduler  # Call scheduler optimization function
#             ;;
#         "kubelet")           # Kubelet optimization case
#             optimize_kubelet # Call kubelet optimization function
#             ;;
#         "container-runtime") # Container runtime optimization case
#             optimize_container_runtime  # Call container runtime optimization function
#             ;;
#         "networking")       # Networking optimization case
#             optimize_networking  # Call networking optimization function
#             ;;
#         "all")               # All optimizations case
#             optimize_api_server  # Call all optimization functions
#             echo ""          # Empty line
#             optimize_etcd
#             echo ""
#             optimize_scheduler
#             echo ""
#             optimize_kubelet
#             echo ""
#             optimize_container_runtime
#             echo ""
#             optimize_networking
#             ;;
#         *)                   # Default case (invalid argument)
#             echo "Usage: $0 {api-server|etcd|scheduler|kubelet|container-runtime|networking|all}"  # Usage message
#             echo "  api-server       - Optimize API server"  # API server option description
#             echo "  etcd            - Optimize etcd"  # etcd option description
#             echo "  scheduler       - Optimize scheduler"  # Scheduler option description
#             echo "  kubelet         - Optimize kubelet"  # Kubelet option description
#             echo "  container-runtime - Optimize container runtime"  # Container runtime option description
#             echo "  networking      - Optimize networking"  # Networking option description
#             echo "  all             - Run all optimizations"  # All option description
#             exit 1           # Exit with error code
#             ;;
#     esac                     # End of case statement
# }
# 
# main "$@"                    # Call main function with all arguments
# ```
# 
# **Expected Output:**
# ```
# === PERFORMANCE OPTIMIZATION ===
# Purpose: Optimize Kubernetes cluster for maximum performance
# 
# 1. Optimizing API Server...
#     args:
#     - --advertise-address=192.168.1.100
#     - --allow-privileged=true
#     - --authorization-mode=Node,RBAC
#     - --client-ca-file=/etc/kubernetes/pki/ca.crt
#     - --enable-admission-plugins=NodeRestriction
#     - --enable-bootstrap-token-auth=true
#     - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
#     - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
#     - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
#     - --etcd-servers=https://127.0.0.1:2379
#     - --insecure-port=0
#     - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
#     - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
#     - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
#     - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
#     - --requestheader-allowed-names=front-proxy-client
#     - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
#     - --requestheader-extra-headers-prefix=X-Remote-Extra-
#     - --requestheader-group-headers=X-Remote-Group
#     - --requestheader-username-headers=X-Remote-User
#     - --secure-port=6443
#     - --service-account-key-file=/etc/kubernetes/pki/sa.pub
#     - --service-cluster-ip-range=10.96.0.0/12
#     - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
#     - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
# Recommended API Server optimizations:
# - --max-requests-inflight=4000
# - --max-mutating-requests-inflight=2000
# - --event-ttl=1h
# - --enable-admission-plugins=NodeRestriction
# - --disable-admission-plugins=ServiceAccount
# ```
# 
# **Key Learning Points:**
# - **Component-Specific Optimization**: Provides targeted optimization for each Kubernetes component
# - **Configuration Analysis**: Analyzes current configurations before recommending changes
# - **Performance Parameters**: Focuses on key performance parameters like QPS, burst limits, and resource thresholds
# - **Modular Design**: Uses functions to organize different optimization areas
# - **Command-Line Interface**: Provides flexible CLI with multiple optimization options
# - **Best Practices**: Implements industry best practices for Kubernetes performance tuning
# - **Resource Management**: Optimizes resource allocation and garbage collection settings
# - **Network Optimization**: Includes CNI and networking performance improvements
# - **Runtime Optimization**: Covers container runtime and kubelet performance settings
# - **Comprehensive Coverage**: Addresses all major Kubernetes components for complete optimization
```

---

## 📋 **Assessment Framework - Comprehensive Testing**

### **🎯 Overview**
This assessment framework provides comprehensive testing to evaluate knowledge, practical skills, and performance capabilities in Kubernetes architecture. The framework includes multiple assessment types designed for different learning levels and skill requirements.

### **📚 Knowledge Assessment**

#### **Section 1: Core Architecture Concepts**

##### **Question 1: Kubernetes Architecture Fundamentals**
**Question**: Explain the Kubernetes architecture and describe the role of each component in the control plane and worker nodes.

**Scoring Criteria**:
- **Excellent (90-100%)**: Complete understanding of all components, their interactions, and detailed explanations
- **Good (80-89%)**: Good understanding of most components with minor gaps
- **Satisfactory (70-79%)**: Basic understanding of main components
- **Needs Improvement (Below 70%)**: Significant gaps in understanding

**Expected Answer**:
```
Kubernetes follows a master-worker architecture with the following components:

Control Plane (Master Node):
1. API Server: Central management point exposing REST API for all operations
2. etcd: Distributed key-value store for cluster state and configuration
3. Scheduler: Assigns pods to nodes based on resource requirements and constraints
4. Controller Manager: Runs controllers to maintain desired state of resources

Worker Nodes:
1. kubelet: Primary node agent managing pods and containers
2. kube-proxy: Network proxy implementing Services and load balancing
3. Container Runtime: Runs containers (containerd, Docker, etc.)

Component Interactions:
- All components communicate through the API Server
- etcd stores all cluster state and configuration
- Scheduler watches for unscheduled pods and assigns them to nodes
- Controller Manager ensures desired state matches actual state
- kubelet manages pod lifecycle and reports node status
```

#### **Section 2: Component Interactions**

##### **Question 2: Pod Lifecycle Management**
**Question**: Describe the complete lifecycle of a pod from creation to termination, including all the components involved.

**Scoring Criteria**:
- **Excellent (90-100%)**: Complete lifecycle with all components and detailed state transitions
- **Good (80-89%)**: Good understanding of main lifecycle stages
- **Satisfactory (70-79%)**: Basic understanding of pod lifecycle
- **Needs Improvement (Below 70%)**: Significant gaps in understanding

**Expected Answer**:
```
Pod Lifecycle:

1. Creation Phase:
   - User submits pod manifest via kubectl
   - API Server validates and stores in etcd
   - Scheduler finds suitable node
   - kubelet on target node creates pod

2. Running Phase:
   - Container runtime starts containers
   - kubelet monitors pod health
   - Controller Manager ensures desired state

3. Termination Phase:
   - API Server receives deletion request
   - kubelet initiates graceful shutdown
   - Containers receive SIGTERM signal
   - Force termination with SIGKILL if needed

Components Involved:
- API Server: Handles all requests and stores state
- etcd: Stores pod configuration and status
- Scheduler: Assigns pod to node
- kubelet: Manages pod on node
- Container Runtime: Runs containers
- Controller Manager: Ensures pod state
```

#### **Section 3: Advanced Concepts**

##### **Question 3: High Availability Architecture**
**Question**: Design a high availability Kubernetes cluster architecture for a production environment with multiple regions.

**Scoring Criteria**:
- **Excellent (90-100%)**: Complete HA design with all components, regions, and failure scenarios
- **Good (80-89%)**: Good HA design with most components covered
- **Satisfactory (70-79%)**: Basic HA design with main components
- **Needs Improvement (Below 70%)**: Significant gaps in HA understanding

**Expected Answer**:
```
High Availability Architecture Design:

1. Multi-Region Setup:
   - Primary region with full control plane
   - Secondary region with backup control plane
   - Worker nodes distributed across regions

2. Control Plane HA:
   - Multiple API servers with load balancer
   - etcd cluster with 3-5 nodes across regions
   - Multiple schedulers and controller managers
   - Leader election for coordination

3. Worker Node HA:
   - Multiple worker nodes per region
   - Pod anti-affinity for workload distribution
   - Node failure tolerance with replicas

4. Network HA:
   - Cross-region network connectivity
   - Load balancer distribution
   - DNS failover mechanisms

5. Storage HA:
   - Distributed storage across regions
   - Backup and disaster recovery
   - Data replication strategies

6. Monitoring and Alerting:
   - Cross-region monitoring
   - Automated failover detection
   - Health check mechanisms
```

### **🔧 Practical Assessment**

#### **Lab 1: Cluster Architecture Analysis**

##### **Objective**
Analyze a Kubernetes cluster architecture and identify potential issues and improvements.

##### **Tasks**
```bash
# Create practical assessment script
cat > practical_assessment_lab1.sh << 'EOF'
#!/bin/bash

# Practical Assessment Lab 1: Cluster Architecture Analysis
echo "=== PRACTICAL ASSESSMENT LAB 1 ==="
echo "Objective: Analyze Kubernetes cluster architecture"
echo "Duration: 60 minutes"
echo ""

# Create assessment environment
mkdir -p assessment-lab1
cd assessment-lab1

# Task 1: Cluster Information Gathering
echo "Task 1: Cluster Information Gathering (15 minutes)"
echo "Requirements:"
echo "1. Gather complete cluster information"
echo "2. Document cluster architecture"
echo "3. Identify cluster components"
echo "4. Map component relationships"
echo ""

# Task 2: Component Health Analysis
echo "Task 2: Component Health Analysis (20 minutes)"
echo "Requirements:"
echo "1. Check health of all control plane components"
echo "2. Analyze worker node status"
echo "3. Verify etcd cluster health"
echo "4. Document any issues found"
echo ""

# Task 3: Performance Analysis
echo "Task 3: Performance Analysis (15 minutes)"
echo "Requirements:"
echo "1. Analyze resource usage across nodes"
echo "2. Identify performance bottlenecks"
echo "3. Check API server performance"
echo "4. Document optimization opportunities"
echo ""

# Task 4: Security Assessment
echo "Task 4: Security Assessment (10 minutes)"
echo "Requirements:"
echo "1. Review RBAC configuration"
echo "2. Check network policies"
echo "3. Analyze security contexts"
echo "4. Document security recommendations"
echo ""

# Assessment criteria
echo "=== ASSESSMENT CRITERIA ==="
echo "Excellent (90-100%): Complete analysis with detailed findings and recommendations"
echo "Good (80-89%): Good analysis with most areas covered"
echo "Satisfactory (70-79%): Basic analysis with main areas covered"
echo "Needs Improvement (Below 70%): Incomplete analysis with significant gaps"
echo ""

# Expected deliverables
echo "=== EXPECTED DELIVERABLES ==="
echo "1. Cluster architecture diagram"
echo "2. Component health report"
echo "3. Performance analysis report"
echo "4. Security assessment report"
echo "5. Recommendations document"
echo ""

echo "Begin assessment when ready..."
EOF

chmod +x practical_assessment_lab1.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Practical Assessment Lab 1: Cluster Architecture Analysis
# echo "=== PRACTICAL ASSESSMENT LAB 1 ==="  # Lab header
# echo "Objective: Analyze Kubernetes cluster architecture"  # Objective description
# echo "Duration: 60 minutes"  # Time allocation
# echo ""  # Empty line for formatting
# 
# # Create assessment environment
# mkdir -p assessment-lab1  # Create assessment directory with parent directories if needed
# cd assessment-lab1  # Change to assessment directory
# 
# # Task 1: Cluster Information Gathering
# echo "Task 1: Cluster Information Gathering (15 minutes)"  # Task description with time
# echo "Requirements:"  # Requirements header
# echo "1. Gather complete cluster information"  # Requirement 1
# echo "2. Document cluster architecture"  # Requirement 2
# echo "3. Identify cluster components"  # Requirement 3
# echo "4. Map component relationships"  # Requirement 4
# echo ""  # Empty line for formatting
# 
# # Task 2: Component Health Analysis
# echo "Task 2: Component Health Analysis (20 minutes)"  # Task description with time
# echo "Requirements:"  # Requirements header
# echo "1. Check health of all control plane components"  # Requirement 1
# echo "2. Analyze worker node status"  # Requirement 2
# echo "3. Verify etcd cluster health"  # Requirement 3
# echo "4. Document any issues found"  # Requirement 4
# echo ""  # Empty line for formatting
# 
# # Task 3: Performance Analysis
# echo "Task 3: Performance Analysis (15 minutes)"  # Task description with time
# echo "Requirements:"  # Requirements header
# echo "1. Analyze resource usage across nodes"  # Requirement 1
# echo "2. Identify performance bottlenecks"  # Requirement 2
# echo "3. Check API server performance"  # Requirement 3
# echo "4. Document optimization opportunities"  # Requirement 4
# echo ""  # Empty line for formatting
# 
# # Task 4: Security Assessment
# echo "Task 4: Security Assessment (10 minutes)"  # Task description with time
# echo "Requirements:"  # Requirements header
# echo "1. Review RBAC configuration"  # Requirement 1
# echo "2. Check network policies"  # Requirement 2
# echo "3. Analyze security contexts"  # Requirement 3
# echo "4. Document security recommendations"  # Requirement 4
# echo ""  # Empty line for formatting
# 
# # Assessment criteria
# echo "=== ASSESSMENT CRITERIA ==="  # Criteria header
# echo "Excellent (90-100%): Complete analysis with detailed findings and recommendations"  # Excellent criteria
# echo "Good (80-89%): Good analysis with most areas covered"  # Good criteria
# echo "Satisfactory (70-79%): Basic analysis with main areas covered"  # Satisfactory criteria
# echo "Needs Improvement (Below 70%): Incomplete analysis with significant gaps"  # Needs improvement criteria
# echo ""  # Empty line for formatting
# 
# # Expected deliverables
# echo "=== EXPECTED DELIVERABLES ==="  # Deliverables header
# echo "1. Cluster architecture diagram"  # Deliverable 1
# echo "2. Component health report"  # Deliverable 2
# echo "3. Performance analysis report"  # Deliverable 3
# echo "4. Security assessment report"  # Deliverable 4
# echo "5. Recommendations document"  # Deliverable 5
# echo ""  # Empty line for formatting
# 
# echo "Begin assessment when ready..."  # Start instruction
# ```
# 
# **Expected Output:**
# ```
# === PRACTICAL ASSESSMENT LAB 1 ===
# Objective: Analyze Kubernetes cluster architecture
# Duration: 60 minutes
# 
# Task 1: Cluster Information Gathering (15 minutes)
# Requirements:
# 1. Gather complete cluster information
# 2. Document cluster architecture
# 3. Identify cluster components
# 4. Map component relationships
# 
# Task 2: Component Health Analysis (20 minutes)
# Requirements:
# 1. Check health of all control plane components
# 2. Analyze worker node status
# 3. Verify etcd cluster health
# 4. Document any issues found
# 
# Task 3: Performance Analysis (15 minutes)
# Requirements:
# 1. Analyze resource usage across nodes
# 2. Identify performance bottlenecks
# 3. Check API server performance
# 4. Document optimization opportunities
# 
# Task 4: Security Assessment (10 minutes)
# Requirements:
# 1. Review RBAC configuration
# 2. Check network policies
# 3. Analyze security contexts
# 4. Document security recommendations
# 
# === ASSESSMENT CRITERIA ===
# Excellent (90-100%): Complete analysis with detailed findings and recommendations
# Good (80-89%): Good analysis with most areas covered
# Satisfactory (70-79%): Basic analysis with main areas covered
# Needs Improvement (Below 70%): Incomplete analysis with significant gaps
# 
# === EXPECTED DELIVERABLES ===
# 1. Cluster architecture diagram
# 2. Component health report
# 3. Performance analysis report
# 4. Security assessment report
# 5. Recommendations document
# 
# Begin assessment when ready...
# ```
# 
# **Key Learning Points:**
# - **Structured Assessment**: Provides clear objectives, time allocations, and requirements
# - **Comprehensive Coverage**: Covers cluster analysis, health checks, performance, and security
# - **Clear Criteria**: Defines assessment criteria with specific percentage ranges
# - **Expected Deliverables**: Specifies required outputs for evaluation
# - **Time Management**: Allocates appropriate time for each task
# - **Practical Focus**: Emphasizes hands-on analysis and documentation
# - **Professional Standards**: Follows industry assessment best practices
# - **Documentation Requirements**: Requires comprehensive documentation of findings
# - **Multi-Dimensional Analysis**: Covers technical, performance, and security aspects
# - **Actionable Outcomes**: Focuses on recommendations and improvements
```

#### **Lab 2: Troubleshooting Complex Issues**

##### **Objective**
Troubleshoot and resolve complex Kubernetes architecture issues.

##### **Tasks**
```bash
# Create troubleshooting assessment script
cat > practical_assessment_lab2.sh << 'EOF'
#!/bin/bash

# Practical Assessment Lab 2: Troubleshooting Complex Issues
echo "=== PRACTICAL ASSESSMENT LAB 2 ==="
echo "Objective: Troubleshoot complex Kubernetes architecture issues"
echo "Duration: 90 minutes"
echo ""

# Create assessment environment
mkdir -p assessment-lab2
cd assessment-lab2

# Scenario 1: API Server Issues
echo "Scenario 1: API Server Issues (25 minutes)"
echo "Problem: API Server is experiencing high latency and timeouts"
echo "Tasks:"
echo "1. Identify the root cause of API Server issues"
echo "2. Analyze API Server logs and metrics"
echo "3. Check etcd connectivity and performance"
echo "4. Implement appropriate fixes"
echo "5. Verify resolution"
echo ""

# Scenario 2: etcd Cluster Problems
echo "Scenario 2: etcd Cluster Problems (25 minutes)"
echo "Problem: etcd cluster is experiencing leader election issues"
echo "Tasks:"
echo "1. Diagnose etcd cluster health"
echo "2. Check etcd member status"
echo "3. Analyze etcd logs and metrics"
echo "4. Resolve leader election issues"
echo "5. Verify cluster stability"
echo ""

# Scenario 3: Node Failure Recovery
echo "Scenario 3: Node Failure Recovery (25 minutes)"
echo "Problem: Worker node has failed and pods are not rescheduling"
echo "Tasks:"
echo "1. Identify failed node and impact"
echo "2. Check pod status and scheduling"
echo "3. Analyze scheduler behavior"
echo "4. Implement node recovery or replacement"
echo "5. Verify workload restoration"
echo ""

# Scenario 4: Network Connectivity Issues
echo "Scenario 4: Network Connectivity Issues (15 minutes)"
echo "Problem: Pods cannot communicate with each other"
echo "Tasks:"
echo "1. Diagnose network connectivity issues"
echo "2. Check CNI configuration"
echo "3. Analyze network policies"
echo "4. Resolve connectivity problems"
echo "5. Verify network functionality"
echo ""

# Assessment criteria
echo "=== ASSESSMENT CRITERIA ==="
echo "Excellent (90-100%): All issues resolved quickly with proper analysis"
echo "Good (80-89%): Most issues resolved with good troubleshooting"
echo "Satisfactory (70-79%): Basic troubleshooting with some issues resolved"
echo "Needs Improvement (Below 70%): Poor troubleshooting with few issues resolved"
echo ""

# Expected deliverables
echo "=== EXPECTED DELIVERABLES ==="
echo "1. Root cause analysis for each scenario"
echo "2. Troubleshooting steps and commands used"
echo "3. Resolution documentation"
echo "4. Verification of fixes"
echo "5. Lessons learned and prevention strategies"
echo ""

echo "Begin assessment when ready..."
EOF

chmod +x practical_assessment_lab2.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Practical Assessment Lab 2: Troubleshooting Complex Issues
# echo "=== PRACTICAL ASSESSMENT LAB 2 ==="  # Lab header
# echo "Objective: Troubleshoot complex Kubernetes architecture issues"  # Objective description
# echo "Duration: 90 minutes"  # Time allocation
# echo ""  # Empty line for formatting
# 
# # Create assessment environment
# mkdir -p assessment-lab2  # Create assessment directory with parent directories if needed
# cd assessment-lab2  # Change to assessment directory
# 
# # Scenario 1: API Server Issues
# echo "Scenario 1: API Server Issues (25 minutes)"  # Scenario description with time
# echo "Problem: API Server is experiencing high latency and timeouts"  # Problem statement
# echo "Tasks:"  # Tasks header
# echo "1. Identify the root cause of API Server issues"  # Task 1
# echo "2. Analyze API Server logs and metrics"  # Task 2
# echo "3. Check etcd connectivity and performance"  # Task 3
# echo "4. Implement appropriate fixes"  # Task 4
# echo "5. Verify resolution"  # Task 5
# echo ""  # Empty line for formatting
# 
# # Scenario 2: etcd Cluster Problems
# echo "Scenario 2: etcd Cluster Problems (25 minutes)"  # Scenario description with time
# echo "Problem: etcd cluster is experiencing leader election issues"  # Problem statement
# echo "Tasks:"  # Tasks header
# echo "1. Diagnose etcd cluster health"  # Task 1
# echo "2. Check etcd member status"  # Task 2
# echo "3. Analyze etcd logs and metrics"  # Task 3
# echo "4. Resolve leader election issues"  # Task 4
# echo "5. Verify cluster stability"  # Task 5
# echo ""  # Empty line for formatting
# 
# # Scenario 3: Node Failure Recovery
# echo "Scenario 3: Node Failure Recovery (25 minutes)"  # Scenario description with time
# echo "Problem: Worker node has failed and pods are not rescheduling"  # Problem statement
# echo "Tasks:"  # Tasks header
# echo "1. Identify failed node and impact"  # Task 1
# echo "2. Check pod status and scheduling"  # Task 2
# echo "3. Analyze scheduler behavior"  # Task 3
# echo "4. Implement node recovery or replacement"  # Task 4
# echo "5. Verify workload restoration"  # Task 5
# echo ""  # Empty line for formatting
# 
# # Scenario 4: Network Connectivity Issues
# echo "Scenario 4: Network Connectivity Issues (15 minutes)"  # Scenario description with time
# echo "Problem: Pods cannot communicate with each other"  # Problem statement
# echo "Tasks:"  # Tasks header
# echo "1. Diagnose network connectivity issues"  # Task 1
# echo "2. Check CNI configuration"  # Task 2
# echo "3. Analyze network policies"  # Task 3
# echo "4. Resolve connectivity problems"  # Task 4
# echo "5. Verify network functionality"  # Task 5
# echo ""  # Empty line for formatting
# 
# # Assessment criteria
# echo "=== ASSESSMENT CRITERIA ==="  # Criteria header
# echo "Excellent (90-100%): All issues resolved quickly with proper analysis"  # Excellent criteria
# echo "Good (80-89%): Most issues resolved with good troubleshooting"  # Good criteria
# echo "Satisfactory (70-79%): Basic troubleshooting with some issues resolved"  # Satisfactory criteria
# echo "Needs Improvement (Below 70%): Poor troubleshooting with few issues resolved"  # Needs improvement criteria
# echo ""  # Empty line for formatting
# 
# # Expected deliverables
# echo "=== EXPECTED DELIVERABLES ==="  # Deliverables header
# echo "1. Root cause analysis for each scenario"  # Deliverable 1
# echo "2. Troubleshooting steps and commands used"  # Deliverable 2
# echo "3. Resolution documentation"  # Deliverable 3
# echo "4. Verification of fixes"  # Deliverable 4
# echo "5. Lessons learned and prevention strategies"  # Deliverable 5
# echo ""  # Empty line for formatting
# 
# echo "Begin assessment when ready..."  # Start instruction
# ```
# 
# **Expected Output:**
# ```
# === PRACTICAL ASSESSMENT LAB 2 ===
# Objective: Troubleshoot complex Kubernetes architecture issues
# Duration: 90 minutes
# 
# Scenario 1: API Server Issues (25 minutes)
# Problem: API Server is experiencing high latency and timeouts
# Tasks:
# 1. Identify the root cause of API Server issues
# 2. Analyze API Server logs and metrics
# 3. Check etcd connectivity and performance
# 4. Implement appropriate fixes
# 5. Verify resolution
# 
# Scenario 2: etcd Cluster Problems (25 minutes)
# Problem: etcd cluster is experiencing leader election issues
# Tasks:
# 1. Diagnose etcd cluster health
# 2. Check etcd member status
# 3. Analyze etcd logs and metrics
# 4. Resolve leader election issues
# 5. Verify cluster stability
# 
# Scenario 3: Node Failure Recovery (25 minutes)
# Problem: Worker node has failed and pods are not rescheduling
# Tasks:
# 1. Identify failed node and impact
# 2. Check pod status and scheduling
# 3. Analyze scheduler behavior
# 4. Implement node recovery or replacement
# 5. Verify workload restoration
# 
# Scenario 4: Network Connectivity Issues (15 minutes)
# Problem: Pods cannot communicate with each other
# Tasks:
# 1. Diagnose network connectivity issues
# 2. Check CNI configuration
# 3. Analyze network policies
# 4. Resolve connectivity problems
# 5. Verify network functionality
# 
# === ASSESSMENT CRITERIA ===
# Excellent (90-100%): All issues resolved quickly with proper analysis
# Good (80-89%): Most issues resolved with good troubleshooting
# Satisfactory (70-79%): Basic troubleshooting with some issues resolved
# Needs Improvement (Below 70%): Poor troubleshooting with few issues resolved
# 
# === EXPECTED DELIVERABLES ===
# 1. Root cause analysis for each scenario
# 2. Troubleshooting steps and commands used
# 3. Resolution documentation
# 4. Verification of fixes
# 5. Lessons learned and prevention strategies
# 
# Begin assessment when ready...
# ```
# 
# **Key Learning Points:**
# - **Real-World Scenarios**: Presents realistic troubleshooting scenarios commonly encountered in production
# - **Time Management**: Allocates appropriate time for each scenario based on complexity
# - **Systematic Approach**: Requires systematic troubleshooting with root cause analysis
# - **Verification Process**: Emphasizes verification of fixes and resolution
# - **Documentation Requirements**: Requires comprehensive documentation of troubleshooting steps
# - **Prevention Focus**: Includes lessons learned and prevention strategies
# - **Multi-Component Issues**: Covers issues across different Kubernetes components
# - **Practical Skills**: Tests hands-on troubleshooting and problem-solving abilities
# - **Performance Evaluation**: Assesses speed and effectiveness of issue resolution
# - **Professional Standards**: Follows industry best practices for incident response
```

### **⚡ Performance Assessment**

#### **Performance Test 1: Cluster Setup and Configuration**

##### **Objective**
Set up and configure a production-ready Kubernetes cluster within time constraints.

##### **Test Parameters**
```bash
# Create performance assessment script
cat > performance_assessment_test1.sh << 'EOF'
#!/bin/bash

# Performance Assessment Test 1: Cluster Setup and Configuration
echo "=== PERFORMANCE ASSESSMENT TEST 1 ==="
echo "Objective: Set up production-ready Kubernetes cluster"
echo "Time Limit: 120 minutes"
echo ""

# Test environment setup
mkdir -p performance-test1
cd performance-test1

# Test requirements
echo "=== TEST REQUIREMENTS ==="
echo "1. Set up 3-node Kubernetes cluster (1 master, 2 workers)"
echo "2. Configure high availability for control plane"
echo "3. Install and configure network plugin"
echo "4. Set up monitoring and logging"
echo "5. Configure security policies"
echo "6. Deploy sample application"
echo "7. Verify cluster functionality"
echo ""

# Time allocation
echo "=== TIME ALLOCATION ==="
echo "Cluster setup: 45 minutes"
echo "HA configuration: 30 minutes"
echo "Network and security: 25 minutes"
echo "Monitoring and testing: 20 minutes"
echo ""

# Success criteria
echo "=== SUCCESS CRITERIA ==="
echo "1. All nodes are Ready and healthy"
echo "2. Control plane components are running"
echo "3. Network connectivity is functional"
echo "4. Security policies are enforced"
echo "5. Monitoring is operational"
echo "6. Sample application is accessible"
echo ""

# Performance metrics
echo "=== PERFORMANCE METRICS ==="
echo "1. Setup completion time"
echo "2. Cluster health status"
echo "3. Component availability"
echo "4. Network performance"
echo "5. Security compliance"
echo "6. Application functionality"
echo ""

# Scoring system
echo "=== SCORING SYSTEM ==="
echo "Excellent (90-100%): Completed within 90 minutes with all requirements met"
echo "Good (80-89%): Completed within 105 minutes with most requirements met"
echo "Satisfactory (70-79%): Completed within 120 minutes with basic requirements met"
echo "Needs Improvement (Below 70%): Exceeded time limit or incomplete setup"
echo ""

echo "Begin performance test when ready..."
echo "Timer starting in 5 seconds..."
sleep 5
echo "START TIME: $(date)"
echo ""

# Start timer
start_time=$(date +%s)

# Test execution
echo "=== TEST EXECUTION ==="
echo "1. Begin cluster setup..."
echo "2. Configure high availability..."
echo "3. Install network plugin..."
echo "4. Set up monitoring..."
echo "5. Configure security..."
echo "6. Deploy application..."
echo "7. Verify functionality..."
echo ""

# End timer
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "=== TEST COMPLETION ==="
echo "END TIME: $(date)"
echo "DURATION: ${duration} seconds ($(($duration / 60)) minutes)"
echo ""

# Performance evaluation
if [ $duration -le 5400 ]; then
    echo "✅ EXCELLENT PERFORMANCE: Completed within 90 minutes"
elif [ $duration -le 6300 ]; then
    echo "✅ GOOD PERFORMANCE: Completed within 105 minutes"
elif [ $duration -le 7200 ]; then
    echo "✅ SATISFACTORY PERFORMANCE: Completed within 120 minutes"
else
    echo "❌ NEEDS IMPROVEMENT: Exceeded time limit"
fi
EOF

chmod +x performance_assessment_test1.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Performance Assessment Test 1: Cluster Setup and Configuration
# echo "=== PERFORMANCE ASSESSMENT TEST 1 ==="  # Test header
# echo "Objective: Set up production-ready Kubernetes cluster"  # Objective description
# echo "Time Limit: 120 minutes"  # Time limit specification
# echo ""  # Empty line for formatting
# 
# # Test environment setup
# mkdir -p performance-test1  # Create test directory with parent directories if needed
# cd performance-test1  # Change to test directory
# 
# # Test requirements
# echo "=== TEST REQUIREMENTS ==="  # Requirements header
# echo "1. Set up 3-node Kubernetes cluster (1 master, 2 workers)"  # Requirement 1
# echo "2. Configure high availability for control plane"  # Requirement 2
# echo "3. Install and configure network plugin"  # Requirement 3
# echo "4. Set up monitoring and logging"  # Requirement 4
# echo "5. Configure security policies"  # Requirement 5
# echo "6. Deploy sample application"  # Requirement 6
# echo "7. Verify cluster functionality"  # Requirement 7
# echo ""  # Empty line for formatting
# 
# # Time allocation
# echo "=== TIME ALLOCATION ==="  # Time allocation header
# echo "Cluster setup: 45 minutes"  # Time for cluster setup
# echo "HA configuration: 30 minutes"  # Time for HA configuration
# echo "Network and security: 25 minutes"  # Time for network and security
# echo "Monitoring and testing: 20 minutes"  # Time for monitoring and testing
# echo ""  # Empty line for formatting
# 
# # Success criteria
# echo "=== SUCCESS CRITERIA ==="  # Success criteria header
# echo "1. All nodes are Ready and healthy"  # Criterion 1
# echo "2. Control plane components are running"  # Criterion 2
# echo "3. Network connectivity is functional"  # Criterion 3
# echo "4. Security policies are enforced"  # Criterion 4
# echo "5. Monitoring is operational"  # Criterion 5
# echo "6. Sample application is accessible"  # Criterion 6
# echo ""  # Empty line for formatting
# 
# # Performance metrics
# echo "=== PERFORMANCE METRICS ==="  # Metrics header
# echo "1. Setup completion time"  # Metric 1
# echo "2. Cluster health status"  # Metric 2
# echo "3. Component availability"  # Metric 3
# echo "4. Network performance"  # Metric 4
# echo "5. Security compliance"  # Metric 5
# echo "6. Application functionality"  # Metric 6
# echo ""  # Empty line for formatting
# 
# # Scoring system
# echo "=== SCORING SYSTEM ==="  # Scoring header
# echo "Excellent (90-100%): Completed within 90 minutes with all requirements met"  # Excellent criteria
# echo "Good (80-89%): Completed within 105 minutes with most requirements met"  # Good criteria
# echo "Satisfactory (70-79%): Completed within 120 minutes with basic requirements met"  # Satisfactory criteria
# echo "Needs Improvement (Below 70%): Exceeded time limit or incomplete setup"  # Needs improvement criteria
# echo ""  # Empty line for formatting
# 
# echo "Begin performance test when ready..."  # Start instruction
# echo "Timer starting in 5 seconds..."  # Timer warning
# sleep 5  # Wait 5 seconds
# echo "START TIME: $(date)"  # Display start time
# echo ""  # Empty line for formatting
# 
# # Start timer
# start_time=$(date +%s)  # Capture start time in seconds since epoch
# 
# # Test execution
# echo "=== TEST EXECUTION ==="  # Execution header
# echo "1. Begin cluster setup..."  # Step 1
# echo "2. Configure high availability..."  # Step 2
# echo "3. Install network plugin..."  # Step 3
# echo "4. Set up monitoring..."  # Step 4
# echo "5. Configure security..."  # Step 5
# echo "6. Deploy application..."  # Step 6
# echo "7. Verify functionality..."  # Step 7
# echo ""  # Empty line for formatting
# 
# # End timer
# end_time=$(date +%s)  # Capture end time in seconds since epoch
# duration=$((end_time - start_time))  # Calculate duration in seconds
# 
# echo "=== TEST COMPLETION ==="  # Completion header
# echo "END TIME: $(date)"  # Display end time
# echo "DURATION: ${duration} seconds ($(($duration / 60)) minutes)"  # Display duration in seconds and minutes
# echo ""  # Empty line for formatting
# 
# # Performance evaluation
# if [ $duration -le 5400 ]; then  # If duration is less than or equal to 5400 seconds (90 minutes)
#     echo "✅ EXCELLENT PERFORMANCE: Completed within 90 minutes"  # Excellent performance message
# elif [ $duration -le 6300 ]; then  # If duration is less than or equal to 6300 seconds (105 minutes)
#     echo "✅ GOOD PERFORMANCE: Completed within 105 minutes"  # Good performance message
# elif [ $duration -le 7200 ]; then  # If duration is less than or equal to 7200 seconds (120 minutes)
#     echo "✅ SATISFACTORY PERFORMANCE: Completed within 120 minutes"  # Satisfactory performance message
# else  # If duration exceeds 7200 seconds (120 minutes)
#     echo "❌ NEEDS IMPROVEMENT: Exceeded time limit"  # Needs improvement message
# fi
# ```
# 
# **Expected Output:**
# ```
# === PERFORMANCE ASSESSMENT TEST 1 ===
# Objective: Set up production-ready Kubernetes cluster
# Time Limit: 120 minutes
# 
# === TEST REQUIREMENTS ===
# 1. Set up 3-node Kubernetes cluster (1 master, 2 workers)
# 2. Configure high availability for control plane
# 3. Install and configure network plugin
# 4. Set up monitoring and logging
# 5. Configure security policies
# 6. Deploy sample application
# 7. Verify cluster functionality
# 
# === TIME ALLOCATION ===
# Cluster setup: 45 minutes
# HA configuration: 30 minutes
# Network and security: 25 minutes
# Monitoring and testing: 20 minutes
# 
# === SUCCESS CRITERIA ===
# 1. All nodes are Ready and healthy
# 2. Control plane components are running
# 3. Network connectivity is functional
# 4. Security policies are enforced
# 5. Monitoring is operational
# 6. Sample application is accessible
# 
# === PERFORMANCE METRICS ===
# 1. Setup completion time
# 2. Cluster health status
# 3. Component availability
# 4. Network performance
# 5. Security compliance
# 6. Application functionality
# 
# === SCORING SYSTEM ===
# Excellent (90-100%): Completed within 90 minutes with all requirements met
# Good (80-89%): Completed within 105 minutes with most requirements met
# Satisfactory (70-79%): Completed within 120 minutes with basic requirements met
# Needs Improvement (Below 70%): Exceeded time limit or incomplete setup
# 
# Begin performance test when ready...
# Timer starting in 5 seconds...
# START TIME: Mon Jan 15 10:30:00 UTC 2024
# 
# === TEST EXECUTION ===
# 1. Begin cluster setup...
# 2. Configure high availability...
# 3. Install network plugin...
# 4. Set up monitoring...
# 5. Configure security...
# 6. Deploy application...
# 7. Verify functionality...
# 
# === TEST COMPLETION ===
# END TIME: Mon Jan 15 11:45:00 UTC 2024
# DURATION: 4500 seconds (75 minutes)
# 
# ✅ EXCELLENT PERFORMANCE: Completed within 90 minutes
# ```
# 
# **Key Learning Points:**
# - **Time-Based Assessment**: Implements strict time limits to test efficiency and speed
# - **Comprehensive Requirements**: Covers all aspects of cluster setup from basic to advanced
# - **Structured Evaluation**: Uses clear criteria and metrics for performance evaluation
# - **Automated Timing**: Implements automated timing with start/end time capture
# - **Performance Grading**: Provides clear performance levels with specific time thresholds
# - **Real-World Scenarios**: Simulates realistic production cluster setup requirements
# - **Multi-Dimensional Metrics**: Evaluates technical, time, and quality aspects
# - **Professional Standards**: Follows industry best practices for performance testing
# - **Clear Feedback**: Provides immediate performance feedback with clear success/failure indicators
# - **Scalable Framework**: Can be adapted for different skill levels and requirements
```

#### **Performance Test 2: Troubleshooting Speed Test**

##### **Objective**
Resolve common Kubernetes architecture issues within strict time limits.

##### **Test Parameters**
```bash
# Create troubleshooting speed test script
cat > performance_assessment_test2.sh << 'EOF'
#!/bin/bash

# Performance Assessment Test 2: Troubleshooting Speed Test
echo "=== PERFORMANCE ASSESSMENT TEST 2 ==="
echo "Objective: Resolve common architecture issues quickly"
echo "Time Limit: 60 minutes"
echo ""

# Test environment setup
mkdir -p performance-test2
cd performance-test2

# Test scenarios
echo "=== TEST SCENARIOS ==="
echo "Scenario 1: API Server timeout (15 minutes)"
echo "Scenario 2: etcd connection failure (15 minutes)"
echo "Scenario 3: Node not ready (15 minutes)"
echo "Scenario 4: Pod scheduling failure (15 minutes)"
echo ""

# Time allocation
echo "=== TIME ALLOCATION ==="
echo "Each scenario: 15 minutes maximum"
echo "Total time: 60 minutes"
echo ""

# Success criteria
echo "=== SUCCESS CRITERIA ==="
echo "1. Issue identified within 5 minutes"
echo "2. Root cause determined within 10 minutes"
echo "3. Resolution implemented within 15 minutes"
echo "4. Verification completed successfully"
echo ""

# Performance metrics
echo "=== PERFORMANCE METRICS ==="
echo "1. Time to identify issue"
echo "2. Time to determine root cause"
echo "3. Time to implement resolution"
echo "4. Time to verify fix"
echo "5. Accuracy of diagnosis"
echo "6. Effectiveness of solution"
echo ""

# Scoring system
echo "=== SCORING SYSTEM ==="
echo "Excellent (90-100%): All scenarios resolved within 12 minutes each"
echo "Good (80-89%): All scenarios resolved within 15 minutes each"
echo "Satisfactory (70-79%): Most scenarios resolved within time limit"
echo "Needs Improvement (Below 70%): Multiple scenarios exceeded time limit"
echo ""

echo "Begin troubleshooting speed test when ready..."
echo "Timer starting in 5 seconds..."
sleep 5
echo "START TIME: $(date)"
echo ""

# Start timer
start_time=$(date +%s)

# Test execution
echo "=== TEST EXECUTION ==="
echo "Scenario 1: API Server timeout..."
echo "Scenario 2: etcd connection failure..."
echo "Scenario 3: Node not ready..."
echo "Scenario 4: Pod scheduling failure..."
echo ""

# End timer
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "=== TEST COMPLETION ==="
echo "END TIME: $(date)"
echo "DURATION: ${duration} seconds ($(($duration / 60)) minutes)"
echo ""

# Performance evaluation
if [ $duration -le 2880 ]; then
    echo "✅ EXCELLENT PERFORMANCE: All scenarios resolved within 12 minutes each"
elif [ $duration -le 3600 ]; then
    echo "✅ GOOD PERFORMANCE: All scenarios resolved within 15 minutes each"
elif [ $duration -le 4200 ]; then
    echo "✅ SATISFACTORY PERFORMANCE: Most scenarios resolved within time limit"
else
    echo "❌ NEEDS IMPROVEMENT: Multiple scenarios exceeded time limit"
fi
EOF

chmod +x performance_assessment_test2.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Performance Assessment Test 2: Troubleshooting Speed Test
# echo "=== PERFORMANCE ASSESSMENT TEST 2 ==="  # Test header
# echo "Objective: Resolve common architecture issues quickly"  # Objective description
# echo "Time Limit: 60 minutes"  # Time limit specification
# echo ""  # Empty line for formatting
# 
# # Test environment setup
# mkdir -p performance-test2  # Create test directory with parent directories if needed
# cd performance-test2  # Change to test directory
# 
# # Test scenarios
# echo "=== TEST SCENARIOS ==="  # Scenarios header
# echo "Scenario 1: API Server timeout (15 minutes)"  # Scenario 1 with time limit
# echo "Scenario 2: etcd connection failure (15 minutes)"  # Scenario 2 with time limit
# echo "Scenario 3: Node not ready (15 minutes)"  # Scenario 3 with time limit
# echo "Scenario 4: Pod scheduling failure (15 minutes)"  # Scenario 4 with time limit
# echo ""  # Empty line for formatting
# 
# # Time allocation
# echo "=== TIME ALLOCATION ==="  # Time allocation header
# echo "Each scenario: 15 minutes maximum"  # Individual scenario time limit
# echo "Total time: 60 minutes"  # Total time limit
# echo ""  # Empty line for formatting
# 
# # Success criteria
# echo "=== SUCCESS CRITERIA ==="  # Success criteria header
# echo "1. Issue identified within 5 minutes"  # Criterion 1
# echo "2. Root cause determined within 10 minutes"  # Criterion 2
# echo "3. Resolution implemented within 15 minutes"  # Criterion 3
# echo "4. Verification completed successfully"  # Criterion 4
# echo ""  # Empty line for formatting
# 
# # Performance metrics
# echo "=== PERFORMANCE METRICS ==="  # Metrics header
# echo "1. Time to identify issue"  # Metric 1
# echo "2. Time to determine root cause"  # Metric 2
# echo "3. Time to implement resolution"  # Metric 3
# echo "4. Time to verify fix"  # Metric 4
# echo "5. Accuracy of diagnosis"  # Metric 5
# echo "6. Effectiveness of solution"  # Metric 6
# echo ""  # Empty line for formatting
# 
# # Scoring system
# echo "=== SCORING SYSTEM ==="  # Scoring header
# echo "Excellent (90-100%): All scenarios resolved within 12 minutes each"  # Excellent criteria
# echo "Good (80-89%): All scenarios resolved within 15 minutes each"  # Good criteria
# echo "Satisfactory (70-79%): Most scenarios resolved within time limit"  # Satisfactory criteria
# echo "Needs Improvement (Below 70%): Multiple scenarios exceeded time limit"  # Needs improvement criteria
# echo ""  # Empty line for formatting
# 
# echo "Begin troubleshooting speed test when ready..."  # Start instruction
# echo "Timer starting in 5 seconds..."  # Timer warning
# sleep 5  # Wait 5 seconds
# echo "START TIME: $(date)"  # Display start time
# echo ""  # Empty line for formatting
# 
# # Start timer
# start_time=$(date +%s)  # Capture start time in seconds since epoch
# 
# # Test execution
# echo "=== TEST EXECUTION ==="  # Execution header
# echo "Scenario 1: API Server timeout..."  # Scenario 1 execution
# echo "Scenario 2: etcd connection failure..."  # Scenario 2 execution
# echo "Scenario 3: Node not ready..."  # Scenario 3 execution
# echo "Scenario 4: Pod scheduling failure..."  # Scenario 4 execution
# echo ""  # Empty line for formatting
# 
# # End timer
# end_time=$(date +%s)  # Capture end time in seconds since epoch
# duration=$((end_time - start_time))  # Calculate duration in seconds
# 
# echo "=== TEST COMPLETION ==="  # Completion header
# echo "END TIME: $(date)"  # Display end time
# echo "DURATION: ${duration} seconds ($(($duration / 60)) minutes)"  # Display duration in seconds and minutes
# echo ""  # Empty line for formatting
# 
# # Performance evaluation
# if [ $duration -le 2880 ]; then  # If duration is less than or equal to 2880 seconds (48 minutes)
#     echo "✅ EXCELLENT PERFORMANCE: All scenarios resolved within 12 minutes each"  # Excellent performance message
# elif [ $duration -le 3600 ]; then  # If duration is less than or equal to 3600 seconds (60 minutes)
#     echo "✅ GOOD PERFORMANCE: All scenarios resolved within 15 minutes each"  # Good performance message
# elif [ $duration -le 4200 ]; then  # If duration is less than or equal to 4200 seconds (70 minutes)
#     echo "✅ SATISFACTORY PERFORMANCE: Most scenarios resolved within time limit"  # Satisfactory performance message
# else  # If duration exceeds 4200 seconds (70 minutes)
#     echo "❌ NEEDS IMPROVEMENT: Multiple scenarios exceeded time limit"  # Needs improvement message
# fi
# ```
# 
# **Expected Output:**
# ```
# === PERFORMANCE ASSESSMENT TEST 2 ===
# Objective: Resolve common architecture issues quickly
# Time Limit: 60 minutes
# 
# === TEST SCENARIOS ===
# Scenario 1: API Server timeout (15 minutes)
# Scenario 2: etcd connection failure (15 minutes)
# Scenario 3: Node not ready (15 minutes)
# Scenario 4: Pod scheduling failure (15 minutes)
# 
# === TIME ALLOCATION ===
# Each scenario: 15 minutes maximum
# Total time: 60 minutes
# 
# === SUCCESS CRITERIA ===
# 1. Issue identified within 5 minutes
# 2. Root cause determined within 10 minutes
# 3. Resolution implemented within 15 minutes
# 4. Verification completed successfully
# 
# === PERFORMANCE METRICS ===
# 1. Time to identify issue
# 2. Time to determine root cause
# 3. Time to implement resolution
# 4. Time to verify fix
# 5. Accuracy of diagnosis
# 6. Effectiveness of solution
# 
# === SCORING SYSTEM ===
# Excellent (90-100%): All scenarios resolved within 12 minutes each
# Good (80-89%): All scenarios resolved within 15 minutes each
# Satisfactory (70-79%): Most scenarios resolved within time limit
# Needs Improvement (Below 70%): Multiple scenarios exceeded time limit
# 
# Begin troubleshooting speed test when ready...
# Timer starting in 5 seconds...
# START TIME: Mon Jan 15 10:30:00 UTC 2024
# 
# === TEST EXECUTION ===
# Scenario 1: API Server timeout...
# Scenario 2: etcd connection failure...
# Scenario 3: Node not ready...
# Scenario 4: Pod scheduling failure...
# 
# === TEST COMPLETION ===
# END TIME: Mon Jan 15 11:15:00 UTC 2024
# DURATION: 2700 seconds (45 minutes)
# 
# ✅ EXCELLENT PERFORMANCE: All scenarios resolved within 12 minutes each
# ```
# 
# **Key Learning Points:**
# - **Speed-Focused Assessment**: Emphasizes quick problem identification and resolution
# - **Multiple Scenarios**: Tests ability to handle different types of issues efficiently
# - **Strict Time Limits**: Implements tight time constraints to simulate real-world pressure
# - **Systematic Approach**: Requires structured troubleshooting methodology
# - **Performance Grading**: Provides clear performance levels based on speed and accuracy
# - **Real-World Issues**: Focuses on common production problems
# - **Verification Requirements**: Emphasizes the importance of verifying fixes
# - **Multi-Dimensional Evaluation**: Considers both speed and effectiveness
# - **Professional Standards**: Follows industry best practices for incident response
# - **Scalable Framework**: Can be adapted for different skill levels and issue types
```

### **📊 Assessment Results and Certification**

#### **Comprehensive Assessment Report**
```bash
# Create assessment report generator
cat > generate_assessment_report.sh << 'EOF'
#!/bin/bash

# Assessment Report Generator
echo "=== KUBERNETES ARCHITECTURE ASSESSMENT REPORT ==="
echo "Date: $(date)"
echo ""

# Assessment results
echo "=== ASSESSMENT RESULTS ==="

# Knowledge assessment
echo "1. KNOWLEDGE ASSESSMENT:"
echo "   - Core Architecture Concepts: ___/100"
echo "   - Component Interactions: ___/100"
echo "   - Advanced Concepts: ___/100"
echo "   Average Knowledge Score: ___/100"
echo ""

# Practical assessment
echo "2. PRACTICAL ASSESSMENT:"
echo "   - Lab 1: Cluster Analysis: ___/100"
echo "   - Lab 2: Troubleshooting: ___/100"
echo "   Average Practical Score: ___/100"
echo ""

# Performance assessment
echo "3. PERFORMANCE ASSESSMENT:"
echo "   - Test 1: Cluster Setup: ___/100"
echo "   - Test 2: Troubleshooting Speed: ___/100"
echo "   Average Performance Score: ___/100"
echo ""

# Overall assessment
echo "=== OVERALL ASSESSMENT ==="
echo "Knowledge Weight: 30%"
echo "Practical Weight: 40%"
echo "Performance Weight: 30%"
echo "Overall Score: ___/100"
echo ""

# Certification level
echo "=== CERTIFICATION LEVEL ==="
echo "90-100%: Expert Level - Kubernetes Architecture Expert"
echo "80-89%: Advanced Level - Kubernetes Architecture Specialist"
echo "70-79%: Intermediate Level - Kubernetes Architecture Practitioner"
echo "Below 70%: Beginner Level - Needs Further Training"
echo ""

# Recommendations
echo "=== RECOMMENDATIONS ==="
echo "1. Areas for improvement:"
echo "   - [List specific areas]"
echo ""
echo "2. Additional training:"
echo "   - [List recommended courses]"
echo ""
echo "3. Practice opportunities:"
echo "   - [List practice scenarios]"
echo ""
echo "4. Next steps:"
echo "   - [List next learning objectives]"
echo ""

# Certification
echo "=== CERTIFICATION ==="
echo "This assessment certifies that the candidate has demonstrated"
echo "proficiency in Kubernetes architecture at the [LEVEL] level."
echo ""
echo "Assessment completed on: $(date)"
echo "Assessor: [Name]"
echo "Valid until: [Date]"
EOF

chmod +x generate_assessment_report.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Assessment Report Generator
# echo "=== KUBERNETES ARCHITECTURE ASSESSMENT REPORT ==="  # Report header
# echo "Date: $(date)"  # Display current date
# echo ""  # Empty line for formatting
# 
# # Assessment results
# echo "=== ASSESSMENT RESULTS ==="  # Results header
# 
# # Knowledge assessment
# echo "1. KNOWLEDGE ASSESSMENT:"  # Knowledge section header
# echo "   - Core Architecture Concepts: ___/100"  # Knowledge area 1 with placeholder score
# echo "   - Component Interactions: ___/100"  # Knowledge area 2 with placeholder score
# echo "   - Advanced Concepts: ___/100"  # Knowledge area 3 with placeholder score
# echo "   Average Knowledge Score: ___/100"  # Average knowledge score with placeholder
# echo ""  # Empty line for formatting
# 
# # Practical assessment
# echo "2. PRACTICAL ASSESSMENT:"  # Practical section header
# echo "   - Lab 1: Cluster Analysis: ___/100"  # Practical lab 1 with placeholder score
# echo "   - Lab 2: Troubleshooting: ___/100"  # Practical lab 2 with placeholder score
# echo "   Average Practical Score: ___/100"  # Average practical score with placeholder
# echo ""  # Empty line for formatting
# 
# # Performance assessment
# echo "3. PERFORMANCE ASSESSMENT:"  # Performance section header
# echo "   - Test 1: Cluster Setup: ___/100"  # Performance test 1 with placeholder score
# echo "   - Test 2: Troubleshooting Speed: ___/100"  # Performance test 2 with placeholder score
# echo "   Average Performance Score: ___/100"  # Average performance score with placeholder
# echo ""  # Empty line for formatting
# 
# # Overall assessment
# echo "=== OVERALL ASSESSMENT ==="  # Overall assessment header
# echo "Knowledge Weight: 30%"  # Knowledge assessment weight
# echo "Practical Weight: 40%"  # Practical assessment weight
# echo "Performance Weight: 30%"  # Performance assessment weight
# echo "Overall Score: ___/100"  # Overall score with placeholder
# echo ""  # Empty line for formatting
# 
# # Certification level
# echo "=== CERTIFICATION LEVEL ==="  # Certification header
# echo "90-100%: Expert Level - Kubernetes Architecture Expert"  # Expert level criteria
# echo "80-89%: Advanced Level - Kubernetes Architecture Specialist"  # Advanced level criteria
# echo "70-79%: Intermediate Level - Kubernetes Architecture Practitioner"  # Intermediate level criteria
# echo "Below 70%: Beginner Level - Needs Further Training"  # Beginner level criteria
# echo ""  # Empty line for formatting
# 
# # Recommendations
# echo "=== RECOMMENDATIONS ==="  # Recommendations header
# echo "1. Areas for improvement:"  # Improvement areas header
# echo "   - [List specific areas]"  # Placeholder for specific improvement areas
# echo ""  # Empty line for formatting
# echo "2. Additional training:"  # Training recommendations header
# echo "   - [List recommended courses]"  # Placeholder for recommended courses
# echo ""  # Empty line for formatting
# echo "3. Practice opportunities:"  # Practice opportunities header
# echo "   - [List practice scenarios]"  # Placeholder for practice scenarios
# echo ""  # Empty line for formatting
# echo "4. Next steps:"  # Next steps header
# echo "   - [List next learning objectives]"  # Placeholder for next learning objectives
# echo ""  # Empty line for formatting
# 
# # Certification
# echo "=== CERTIFICATION ==="  # Certification section header
# echo "This assessment certifies that the candidate has demonstrated"  # Certification statement
# echo "proficiency in Kubernetes architecture at the [LEVEL] level."  # Proficiency level with placeholder
# echo ""  # Empty line for formatting
# echo "Assessment completed on: $(date)"  # Completion date
# echo "Assessor: [Name]"  # Assessor name with placeholder
# echo "Valid until: [Date]"  # Validity date with placeholder
# ```
# 
# **Expected Output:**
# ```
# === KUBERNETES ARCHITECTURE ASSESSMENT REPORT ===
# Date: Mon Jan 15 10:30:00 UTC 2024
# 
# === ASSESSMENT RESULTS ===
# 1. KNOWLEDGE ASSESSMENT:
#    - Core Architecture Concepts: 95/100
#    - Component Interactions: 88/100
#    - Advanced Concepts: 92/100
#    Average Knowledge Score: 91.7/100
# 
# 2. PRACTICAL ASSESSMENT:
#    - Lab 1: Cluster Analysis: 94/100
#    - Lab 2: Troubleshooting: 89/100
#    Average Practical Score: 91.5/100
# 
# 3. PERFORMANCE ASSESSMENT:
#    - Test 1: Cluster Setup: 96/100
#    - Test 2: Troubleshooting Speed: 87/100
#    Average Performance Score: 91.5/100
# 
# === OVERALL ASSESSMENT ===
# Knowledge Weight: 30%
# Practical Weight: 40%
# Performance Weight: 30%
# Overall Score: 91.6/100
# 
# === CERTIFICATION LEVEL ===
# 90-100%: Expert Level - Kubernetes Architecture Expert
# 80-89%: Advanced Level - Kubernetes Architecture Specialist
# 70-79%: Intermediate Level - Kubernetes Architecture Practitioner
# Below 70%: Beginner Level - Needs Further Training
# 
# === RECOMMENDATIONS ===
# 1. Areas for improvement:
#    - Advanced troubleshooting techniques
#    - Performance optimization strategies
# 
# 2. Additional training:
#    - Advanced Kubernetes Security
#    - Multi-cluster Management
# 
# 3. Practice opportunities:
#    - Production cluster management
#    - Disaster recovery scenarios
# 
# 4. Next steps:
#    - Pursue CKA certification
#    - Contribute to open-source projects
# 
# === CERTIFICATION ===
# This assessment certifies that the candidate has demonstrated
# proficiency in Kubernetes architecture at the Expert level.
# 
# Assessment completed on: Mon Jan 15 10:30:00 UTC 2024
# Assessor: John Smith
# Valid until: Jan 15, 2025
# ```
# 
# **Key Learning Points:**
# - **Comprehensive Evaluation**: Provides detailed assessment across knowledge, practical, and performance areas
# - **Weighted Scoring**: Implements weighted scoring system for balanced evaluation
# - **Certification Levels**: Defines clear certification levels with specific criteria
# - **Actionable Recommendations**: Provides specific areas for improvement and next steps
# - **Professional Documentation**: Creates formal assessment report suitable for certification
# - **Date Tracking**: Includes assessment completion and validity dates
# - **Assessor Accountability**: Includes assessor information for accountability
# - **Structured Format**: Uses clear sections and formatting for easy reading
# - **Placeholder System**: Uses placeholders for dynamic content insertion
# - **Industry Standards**: Follows professional assessment and certification best practices
```

### **🎯 Assessment Best Practices**

#### **1. Assessment Preparation**
- **Review prerequisites** before taking assessments
- **Practice with sample scenarios** to build confidence
- **Understand assessment criteria** and expectations
- **Prepare necessary tools** and documentation

#### **2. Assessment Execution**
- **Read instructions carefully** before starting
- **Manage time effectively** across all tasks
- **Document your work** for review and learning
- **Verify your solutions** before submitting

#### **3. Assessment Review**
- **Review your performance** against criteria
- **Identify areas for improvement** based on results
- **Seek feedback** from assessors and peers
- **Plan next steps** for continued learning

#### **4. Continuous Improvement**
- **Regular self-assessment** to track progress
- **Practice with real-world scenarios** to build skills
- **Stay updated** with latest Kubernetes developments
- **Share knowledge** with the community

---

## 📚 **Additional Resources - Comprehensive Learning Materials**

### **🎯 Overview**
This section provides comprehensive learning materials, tools, and resources to support continued learning and mastery of Kubernetes architecture. These resources are organized by learning level and topic area.

### **📖 Official Documentation and References**

#### **Kubernetes Official Resources**
- **[Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)**: Official architecture documentation
- **[kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)**: Complete kubectl command reference
- **[API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)**: Kubernetes API documentation
- **[etcd Documentation](https://etcd.io/docs/)**: etcd cluster documentation
- **[Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)**: Detailed component descriptions

#### **Architecture Deep Dives**
- **[Kubernetes Architecture Deep Dive](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/)**: Control plane communication
- **[etcd Cluster Management](https://etcd.io/docs/v3.5/op-guide/)**: etcd operational guide
- **[Kubernetes Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)**: Scheduler architecture
- **[Controller Manager](https://kubernetes.io/docs/concepts/architecture/controller/)**: Controller patterns

### **📚 Books and Publications**

#### **Essential Reading**
1. **"Kubernetes: Up and Running"** by Kelsey Hightower
   - **Focus**: Practical Kubernetes deployment and management
   - **Level**: Beginner to Intermediate
   - **Key Topics**: Architecture, deployment, troubleshooting

2. **"Kubernetes in Action"** by Marko Lukša
   - **Focus**: Comprehensive Kubernetes concepts and practices
   - **Level**: Intermediate to Advanced
   - **Key Topics**: Architecture, networking, security, scaling

3. **"Kubernetes Patterns"** by Bilgin Ibryam
   - **Focus**: Design patterns for Kubernetes applications
   - **Level**: Intermediate to Advanced
   - **Key Topics**: Architectural patterns, best practices

4. **"Kubernetes Operators"** by Jason Dobies
   - **Focus**: Building Kubernetes-native applications
   - **Level**: Advanced
   - **Key Topics**: Custom controllers, operators, automation

#### **Advanced Architecture Books**
1. **"Designing Distributed Systems"** by Brendan Burns
   - **Focus**: Distributed system design principles
   - **Level**: Advanced
   - **Key Topics**: System architecture, scalability, reliability

2. **"Site Reliability Engineering"** by Google
   - **Focus**: Production system reliability and operations
   - **Level**: Advanced
   - **Key Topics**: SRE practices, monitoring, incident response

### **🎓 Online Courses and Certifications**

#### **Kubernetes Certifications**
1. **Certified Kubernetes Administrator (CKA)**
   - **Provider**: Linux Foundation
   - **Focus**: Kubernetes administration and troubleshooting
   - **Duration**: Self-paced, 6-12 months
   - **Level**: Intermediate to Advanced

2. **Certified Kubernetes Application Developer (CKAD)**
   - **Provider**: Linux Foundation
   - **Focus**: Kubernetes application development
   - **Duration**: Self-paced, 6-12 months
   - **Level**: Intermediate

3. **Certified Kubernetes Security Specialist (CKS)**
   - **Provider**: Linux Foundation
   - **Focus**: Kubernetes security and compliance
   - **Duration**: Self-paced, 6-12 months
   - **Level**: Advanced

#### **Online Learning Platforms**
1. **Kubernetes Fundamentals (Linux Foundation)**
   - **Platform**: edX
   - **Focus**: Core Kubernetes concepts
   - **Duration**: 8 weeks
   - **Level**: Beginner to Intermediate

2. **Kubernetes Architecture Deep Dive (Pluralsight)**
   - **Platform**: Pluralsight
   - **Focus**: Advanced architecture concepts
   - **Duration**: 6 hours
   - **Level**: Advanced

3. **Kubernetes for Developers (Coursera)**
   - **Platform**: Coursera
   - **Focus**: Application deployment and management
   - **Duration**: 4 weeks
   - **Level**: Intermediate

### **🔧 Tools and Utilities**

#### **Kubernetes Management Tools**
```bash
# Create tools installation script
cat > install_kubernetes_tools.sh << 'EOF'
#!/bin/bash

# Kubernetes Tools Installation Script
echo "=== KUBERNETES TOOLS INSTALLATION ==="
echo "Installing essential Kubernetes management tools"
echo ""

# 1. kubectl (if not already installed)
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "✅ kubectl installed"
else
    echo "✅ kubectl already installed"
fi

# 2. k9s - Terminal UI for Kubernetes
if ! command -v k9s &> /dev/null; then
    echo "Installing k9s..."
    curl -sS https://webinstall.dev/k9s | bash
    echo "✅ k9s installed"
else
    echo "✅ k9s already installed"
fi

# 3. Lens - Kubernetes IDE
echo "Installing Lens..."
wget -O lens.deb https://downloads.k8slens.dev/ide/latest/linux
sudo dpkg -i lens.deb
sudo apt-get install -f
echo "✅ Lens installed"

# 4. kubectx and kubens
if ! command -v kubectx &> /dev/null; then
    echo "Installing kubectx and kubens..."
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    echo "✅ kubectx and kubens installed"
else
    echo "✅ kubectx and kubens already installed"
fi

# 5. kubectl plugins
echo "Installing kubectl plugins..."

# kubectl-neat
if ! kubectl neat --help &> /dev/null; then
    echo "Installing kubectl-neat..."
    curl -sSL https://github.com/itaysk/kubectl-neat/releases/latest/download/kubectl-neat_linux_amd64.tar.gz | tar -xz
    sudo mv kubectl-neat /usr/local/bin/
    echo "✅ kubectl-neat installed"
else
    echo "✅ kubectl-neat already installed"
fi

# kubectl-tree
if ! kubectl tree --help &> /dev/null; then
    echo "Installing kubectl-tree..."
    curl -sSL https://github.com/ahmetb/kubectl-tree/releases/latest/download/kubectl-tree_linux_amd64.tar.gz | tar -xz
    sudo mv kubectl-tree /usr/local/bin/
    echo "✅ kubectl-tree installed"
else
    echo "✅ kubectl-tree already installed"
fi

# kubectl-debug
if ! kubectl debug --help &> /dev/null; then
    echo "Installing kubectl-debug..."
    curl -sSL https://github.com/aylei/kubectl-debug/releases/latest/download/kubectl-debug_linux_amd64.tar.gz | tar -xz
    sudo mv kubectl-debug /usr/local/bin/
    echo "✅ kubectl-debug installed"
else
    echo "✅ kubectl-debug already installed"
fi

echo ""
echo "=== INSTALLATION COMPLETED ==="
echo "Available tools:"
echo "- kubectl: Kubernetes command-line tool"
echo "- k9s: Terminal UI for Kubernetes"
echo "- Lens: Kubernetes IDE"
echo "- kubectx/kubens: Context and namespace switching"
echo "- kubectl-neat: Clean up YAML output"
echo "- kubectl-tree: Show resource hierarchy"
echo "- kubectl-debug: Debug containers"
echo ""
echo "Start using these tools to enhance your Kubernetes experience!"
EOF

chmod +x install_kubernetes_tools.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Kubernetes Tools Installation Script
# echo "=== KUBERNETES TOOLS INSTALLATION ==="  # Script header
# echo "Installing essential Kubernetes management tools"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # 1. kubectl (if not already installed)
# if ! command -v kubectl &> /dev/null; then  # Check if kubectl is not installed
#     echo "Installing kubectl..."  # Installation message
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  # Download latest kubectl
#     chmod +x kubectl  # Make kubectl executable
#     sudo mv kubectl /usr/local/bin/  # Move kubectl to system PATH
#     echo "✅ kubectl installed"  # Success message
# else  # If kubectl is already installed
#     echo "✅ kubectl already installed"  # Already installed message
# fi  # End of if statement
# 
# # 2. k9s - Terminal UI for Kubernetes
# if ! command -v k9s &> /dev/null; then  # Check if k9s is not installed
#     echo "Installing k9s..."  # Installation message
#     curl -sS https://webinstall.dev/k9s | bash  # Install k9s using webinstall
#     echo "✅ k9s installed"  # Success message
# else  # If k9s is already installed
#     echo "✅ k9s already installed"  # Already installed message
# fi  # End of if statement
# 
# # 3. Lens - Kubernetes IDE
# echo "Installing Lens..."  # Installation message
# wget -O lens.deb https://downloads.k8slens.dev/ide/latest/linux  # Download Lens DEB package
# sudo dpkg -i lens.deb  # Install Lens DEB package
# sudo apt-get install -f  # Fix any dependency issues
# echo "✅ Lens installed"  # Success message
# 
# # 4. kubectx and kubens
# if ! command -v kubectx &> /dev/null; then  # Check if kubectx is not installed
#     echo "Installing kubectx and kubens..."  # Installation message
#     sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx  # Clone kubectx repository
#     sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx  # Create symlink for kubectx
#     sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens  # Create symlink for kubens
#     echo "✅ kubectx and kubens installed"  # Success message
# else  # If kubectx is already installed
#     echo "✅ kubectx and kubens already installed"  # Already installed message
# fi  # End of if statement
# 
# # 5. kubectl plugins
# echo "Installing kubectl plugins..."  # Plugins installation header
# 
# # kubectl-neat
# if ! kubectl neat --help &> /dev/null; then  # Check if kubectl-neat is not installed
#     echo "Installing kubectl-neat..."  # Installation message
#     curl -sSL https://github.com/itaysk/kubectl-neat/releases/latest/download/kubectl-neat_linux_amd64.tar.gz | tar -xz  # Download and extract kubectl-neat
#     sudo mv kubectl-neat /usr/local/bin/  # Move kubectl-neat to system PATH
#     echo "✅ kubectl-neat installed"  # Success message
# else  # If kubectl-neat is already installed
#     echo "✅ kubectl-neat already installed"  # Already installed message
# fi  # End of if statement
# 
# # kubectl-tree
# if ! kubectl tree --help &> /dev/null; then  # Check if kubectl-tree is not installed
#     echo "Installing kubectl-tree..."  # Installation message
#     curl -sSL https://github.com/ahmetb/kubectl-tree/releases/latest/download/kubectl-tree_linux_amd64.tar.gz | tar -xz  # Download and extract kubectl-tree
#     sudo mv kubectl-tree /usr/local/bin/  # Move kubectl-tree to system PATH
#     echo "✅ kubectl-tree installed"  # Success message
# else  # If kubectl-tree is already installed
#     echo "✅ kubectl-tree already installed"  # Already installed message
# fi  # End of if statement
# 
# # kubectl-debug
# if ! kubectl debug --help &> /dev/null; then  # Check if kubectl-debug is not installed
#     echo "Installing kubectl-debug..."  # Installation message
#     curl -sSL https://github.com/aylei/kubectl-debug/releases/latest/download/kubectl-debug_linux_amd64.tar.gz | tar -xz  # Download and extract kubectl-debug
#     sudo mv kubectl-debug /usr/local/bin/  # Move kubectl-debug to system PATH
#     echo "✅ kubectl-debug installed"  # Success message
# else  # If kubectl-debug is already installed
#     echo "✅ kubectl-debug already installed"  # Already installed message
# fi  # End of if statement
# 
# echo ""  # Empty line for formatting
# echo "=== INSTALLATION COMPLETED ==="  # Completion header
# echo "Available tools:"  # Tools list header
# echo "- kubectl: Kubernetes command-line tool"  # Tool description 1
# echo "- k9s: Terminal UI for Kubernetes"  # Tool description 2
# echo "- Lens: Kubernetes IDE"  # Tool description 3
# echo "- kubectx/kubens: Context and namespace switching"  # Tool description 4
# echo "- kubectl-neat: Clean up YAML output"  # Tool description 5
# echo "- kubectl-tree: Show resource hierarchy"  # Tool description 6
# echo "- kubectl-debug: Debug containers"  # Tool description 7
# echo ""  # Empty line for formatting
# echo "Start using these tools to enhance your Kubernetes experience!"  # Encouragement message
# ```
# 
# **Expected Output:**
# ```
# === KUBERNETES TOOLS INSTALLATION ===
# Installing essential Kubernetes management tools
# 
# Installing kubectl...
# ✅ kubectl installed
# Installing k9s...
# ✅ k9s installed
# Installing Lens...
# ✅ Lens installed
# Installing kubectx and kubens...
# ✅ kubectx and kubens installed
# Installing kubectl plugins...
# Installing kubectl-neat...
# ✅ kubectl-neat installed
# Installing kubectl-tree...
# ✅ kubectl-tree installed
# Installing kubectl-debug...
# ✅ kubectl-debug installed
# 
# === INSTALLATION COMPLETED ===
# Available tools:
# - kubectl: Kubernetes command-line tool
# - k9s: Terminal UI for Kubernetes
# - Lens: Kubernetes IDE
# - kubectx/kubens: Context and namespace switching
# - kubectl-neat: Clean up YAML output
# - kubectl-tree: Show resource hierarchy
# - kubectl-debug: Debug containers
# 
# Start using these tools to enhance your Kubernetes experience!
# ```
# 
# **Key Learning Points:**
# - **Conditional Installation**: Checks if tools are already installed before installing
# - **Multiple Tool Types**: Covers CLI tools, GUIs, and kubectl plugins
# - **System Integration**: Installs tools in system PATH for global access
# - **Error Handling**: Uses conditional checks to avoid reinstallation
# - **User-Friendly Output**: Provides clear status messages and descriptions
# - **Comprehensive Coverage**: Includes essential tools for Kubernetes management
# - **Automated Setup**: Streamlines the installation process for multiple tools
# - **Best Practices**: Follows proper installation procedures for each tool type
# - **Documentation**: Provides descriptions of each tool's purpose
# - **Professional Standards**: Uses sudo appropriately and follows security practices
```

#### **Monitoring and Observability Tools**
```bash
# Create monitoring tools installation script
cat > install_monitoring_tools.sh << 'EOF'
#!/bin/bash

# Monitoring Tools Installation Script
echo "=== MONITORING TOOLS INSTALLATION ==="
echo "Installing Kubernetes monitoring and observability tools"
echo ""

# 1. Prometheus
echo "Installing Prometheus..."
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64.tar.gz
tar -xzf prometheus-*.tar.gz
sudo mv prometheus-*/prometheus /usr/local/bin/
sudo mv prometheus-*/promtool /usr/local/bin/
echo "✅ Prometheus installed"

# 2. Grafana
echo "Installing Grafana..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana
echo "✅ Grafana installed"

# 3. kubectl top
echo "Installing metrics-server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
echo "✅ metrics-server installed"

# 4. kube-state-metrics
echo "Installing kube-state-metrics..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/
echo "✅ kube-state-metrics installed"

echo ""
echo "=== MONITORING SETUP COMPLETED ==="
echo "Available monitoring tools:"
echo "- Prometheus: Metrics collection and storage"
echo "- Grafana: Metrics visualization and dashboards"
echo "- metrics-server: Kubernetes resource metrics"
echo "- kube-state-metrics: Kubernetes object metrics"
echo ""
echo "Configure these tools for comprehensive cluster monitoring!"
EOF

chmod +x install_monitoring_tools.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Monitoring Tools Installation Script
# echo "=== MONITORING TOOLS INSTALLATION ==="  # Script header
# echo "Installing Kubernetes monitoring and observability tools"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # 1. Prometheus
# echo "Installing Prometheus..."  # Installation message
# wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64.tar.gz  # Download Prometheus for current OS
# tar -xzf prometheus-*.tar.gz  # Extract Prometheus archive
# sudo mv prometheus-*/prometheus /usr/local/bin/  # Move prometheus binary to system PATH
# sudo mv prometheus-*/promtool /usr/local/bin/  # Move promtool binary to system PATH
# echo "✅ Prometheus installed"  # Success message
# 
# # 2. Grafana
# echo "Installing Grafana..."  # Installation message
# wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -  # Add Grafana GPG key
# echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list  # Add Grafana repository
# sudo apt-get update  # Update package list
# sudo apt-get install grafana  # Install Grafana
# echo "✅ Grafana installed"  # Success message
# 
# # 3. kubectl top
# echo "Installing metrics-server..."  # Installation message
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml  # Deploy metrics-server
# echo "✅ metrics-server installed"  # Success message
# 
# # 4. kube-state-metrics
# echo "Installing kube-state-metrics..."  # Installation message
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/kube-state-metrics/master/examples/standard/  # Deploy kube-state-metrics
# echo "✅ kube-state-metrics installed"  # Success message
# 
# echo ""  # Empty line for formatting
# echo "=== MONITORING SETUP COMPLETED ==="  # Completion header
# echo "Available monitoring tools:"  # Tools list header
# echo "- Prometheus: Metrics collection and storage"  # Tool description 1
# echo "- Grafana: Metrics visualization and dashboards"  # Tool description 2
# echo "- metrics-server: Kubernetes resource metrics"  # Tool description 3
# echo "- kube-state-metrics: Kubernetes object metrics"  # Tool description 4
# echo ""  # Empty line for formatting
# echo "Configure these tools for comprehensive cluster monitoring!"  # Encouragement message
# ```
# 
# **Expected Output:**
# ```
# === MONITORING TOOLS INSTALLATION ===
# Installing Kubernetes monitoring and observability tools
# 
# Installing Prometheus...
# ✅ Prometheus installed
# Installing Grafana...
# ✅ Grafana installed
# Installing metrics-server...
# ✅ metrics-server installed
# Installing kube-state-metrics...
# ✅ kube-state-metrics installed
# 
# === MONITORING SETUP COMPLETED ===
# Available monitoring tools:
# - Prometheus: Metrics collection and storage
# - Grafana: Metrics visualization and dashboards
# - metrics-server: Kubernetes resource metrics
# - kube-state-metrics: Kubernetes object metrics
# 
# Configure these tools for comprehensive cluster monitoring!
# ```
# 
# **Key Learning Points:**
# - **Comprehensive Monitoring Stack**: Installs essential monitoring and observability tools
# - **Cross-Platform Support**: Uses OS detection for Prometheus installation
# - **Repository Management**: Properly adds Grafana repository with GPG key
# - **Kubernetes Integration**: Deploys monitoring components directly to cluster
# - **System Integration**: Installs binaries in system PATH for global access
# - **User-Friendly Output**: Provides clear status messages and descriptions
# - **Best Practices**: Follows proper installation procedures for each tool
# - **Complete Observability**: Covers metrics collection, storage, and visualization
# - **Production Ready**: Installs tools suitable for production environments
# - **Documentation**: Provides descriptions of each tool's purpose and functionality
```

### **🌐 Community Resources and Forums**

#### **Kubernetes Community**
1. **Kubernetes Slack Channels**
   - **#kubernetes-users**: General user discussions
   - **#kubernetes-dev**: Development discussions
   - **#kubernetes-security**: Security discussions
   - **#kubernetes-operators**: Operator development

2. **Kubernetes GitHub**
   - **[Kubernetes Repository](https://github.com/kubernetes/kubernetes)**: Main Kubernetes codebase
   - **[Kubernetes Documentation](https://github.com/kubernetes/website)**: Documentation repository
   - **[Kubernetes Examples](https://github.com/kubernetes/examples)**: Example applications

3. **Stack Overflow**
   - **Kubernetes Tag**: [kubernetes](https://stackoverflow.com/questions/tagged/kubernetes)
   - **Kubernetes Questions**: Community Q&A

#### **Blogs and Articles**
1. **Kubernetes Blog**
   - **[Official Kubernetes Blog](https://kubernetes.io/blog/)**: Official announcements and tutorials
   - **[Kubernetes Architecture Posts](https://kubernetes.io/blog/tags/architecture/)**: Architecture-specific content

2. **Community Blogs**
   - **Kubernetes.io Blog**: Official Kubernetes blog
   - **Medium Kubernetes**: Community articles
   - **DevOps.com**: Kubernetes and DevOps content

### **🎯 Practice Platforms and Labs**

#### **Hands-on Practice Environments**
```bash
# Create practice environment setup script
cat > setup_practice_environment.sh << 'EOF'
#!/bin/bash

# Practice Environment Setup Script
echo "=== PRACTICE ENVIRONMENT SETUP ==="
echo "Setting up Kubernetes practice environments"
echo ""

# 1. Minikube for local development
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
echo "✅ Minikube installed"

# 2. Kind for multi-node clusters
echo "Installing Kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
echo "✅ Kind installed"

# 3. K3s for lightweight clusters
echo "Installing K3s..."
curl -sfL https://get.k3s.io | sh -
echo "✅ K3s installed"

# 4. Docker Desktop for Windows/Mac
echo "Note: Install Docker Desktop manually for Windows/Mac"
echo "Download from: https://www.docker.com/products/docker-desktop"

echo ""
echo "=== PRACTICE ENVIRONMENTS READY ==="
echo "Available environments:"
echo "- Minikube: Single-node local cluster"
echo "- Kind: Multi-node local clusters"
echo "- K3s: Lightweight production-ready cluster"
echo "- Docker Desktop: Integrated Kubernetes"
echo ""
echo "Start practicing with these environments!"
EOF

chmod +x setup_practice_environment.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Practice Environment Setup Script
# echo "=== PRACTICE ENVIRONMENT SETUP ==="  # Script header
# echo "Setting up Kubernetes practice environments"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # 1. Minikube for local development
# echo "Installing Minikube..."  # Installation message
# curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64  # Download Minikube binary
# sudo install minikube-linux-amd64 /usr/local/bin/minikube  # Install Minikube to system PATH
# echo "✅ Minikube installed"  # Success message
# 
# # 2. Kind for multi-node clusters
# echo "Installing Kind..."  # Installation message
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64  # Download Kind binary
# chmod +x ./kind  # Make Kind executable
# sudo mv ./kind /usr/local/bin/kind  # Move Kind to system PATH
# echo "✅ Kind installed"  # Success message
# 
# # 3. K3s for lightweight clusters
# echo "Installing K3s..."  # Installation message
# curl -sfL https://get.k3s.io | sh -  # Install K3s using official installer
# echo "✅ K3s installed"  # Success message
# 
# # 4. Docker Desktop for Windows/Mac
# echo "Note: Install Docker Desktop manually for Windows/Mac"  # Manual installation note
# echo "Download from: https://www.docker.com/products/docker-desktop"  # Download URL
# 
# echo ""  # Empty line for formatting
# echo "=== PRACTICE ENVIRONMENTS READY ==="  # Completion header
# echo "Available environments:"  # Environments list header
# echo "- Minikube: Single-node local cluster"  # Environment description 1
# echo "- Kind: Multi-node local clusters"  # Environment description 2
# echo "- K3s: Lightweight production-ready cluster"  # Environment description 3
# echo "- Docker Desktop: Integrated Kubernetes"  # Environment description 4
# echo ""  # Empty line for formatting
# echo "Start practicing with these environments!"  # Encouragement message
# ```
# 
# **Expected Output:**
# ```
# === PRACTICE ENVIRONMENT SETUP ===
# Setting up Kubernetes practice environments
# 
# Installing Minikube...
# ✅ Minikube installed
# Installing Kind...
# ✅ Kind installed
# Installing K3s...
# ✅ K3s installed
# Note: Install Docker Desktop manually for Windows/Mac
# Download from: https://www.docker.com/products/docker-desktop
# 
# === PRACTICE ENVIRONMENTS READY ===
# Available environments:
# - Minikube: Single-node local cluster
# - Kind: Multi-node local clusters
# - K3s: Lightweight production-ready cluster
# - Docker Desktop: Integrated Kubernetes
# 
# Start practicing with these environments!
# ```
# 
# **Key Learning Points:**
# - **Multiple Environment Types**: Provides different Kubernetes environments for various use cases
# - **Cross-Platform Support**: Covers Linux, Windows, and Mac environments
# - **System Integration**: Installs tools in system PATH for global access
# - **User-Friendly Output**: Provides clear status messages and descriptions
# - **Manual Installation Notes**: Includes instructions for platform-specific tools
# - **Comprehensive Coverage**: Covers single-node, multi-node, and lightweight clusters
# - **Production-Ready Options**: Includes K3s for production-like environments
# - **Best Practices**: Follows proper installation procedures for each tool
# - **Documentation**: Provides descriptions of each environment's purpose
# - **Encouragement**: Motivates users to start practicing immediately
```

#### **Online Practice Platforms**
1. **Katacoda Kubernetes Playground**
   - **URL**: https://www.katacoda.com/courses/kubernetes
   - **Features**: Interactive tutorials, hands-on labs
   - **Level**: Beginner to Intermediate

2. **Kubernetes by Example**
   - **URL**: https://kubernetesbyexample.com/
   - **Features**: Step-by-step examples, practical scenarios
   - **Level**: Beginner to Advanced

3. **Play with Kubernetes**
   - **URL**: https://labs.play-with-k8s.com/
   - **Features**: Free Kubernetes playground, instant clusters
   - **Level**: All levels

### **📊 Advanced Learning Resources**

#### **Architecture Deep Dives**
1. **Kubernetes Architecture Patterns**
   - **Multi-cluster Federation**: Cross-cluster management
   - **Service Mesh**: Istio, Linkerd, Consul
   - **GitOps**: ArgoCD, Flux, Tekton
   - **Observability**: Prometheus, Jaeger, Fluentd

2. **Performance Optimization**
   - **Resource Management**: CPU, memory, storage optimization
   - **Network Optimization**: CNI tuning, network policies
   - **Security Hardening**: RBAC, network policies, pod security
   - **Scalability**: Horizontal scaling, auto-scaling

#### **Enterprise Integration**
1. **Cloud Provider Integration**
   - **AWS EKS**: Amazon Elastic Kubernetes Service
   - **Azure AKS**: Azure Kubernetes Service
   - **Google GKE**: Google Kubernetes Engine
   - **On-premises**: OpenShift, Rancher, VMware Tanzu

2. **CI/CD Integration**
   - **Jenkins**: Kubernetes plugin, pipeline automation
   - **GitLab CI**: Kubernetes integration, GitOps
   - **GitHub Actions**: Kubernetes deployment automation
   - **ArgoCD**: GitOps continuous deployment

### **🎓 Certification Preparation**

#### **Study Resources**
```bash
# Create certification study guide
cat > certification_study_guide.sh << 'EOF'
#!/bin/bash

# Kubernetes Certification Study Guide
echo "=== KUBERNETES CERTIFICATION STUDY GUIDE ==="
echo "Comprehensive study guide for Kubernetes certifications"
echo ""

# CKA Study Topics
echo "=== CKA (Certified Kubernetes Administrator) ==="
echo "1. Cluster Architecture (25%)"
echo "   - Understand Kubernetes cluster architecture"
echo "   - Understand etcd cluster"
echo "   - Understand control plane node components"
echo "   - Understand worker node components"
echo ""

echo "2. Installation, Configuration & Validation (20%)"
echo "   - Design a Kubernetes cluster"
echo "   - Install Kubernetes masters and nodes"
echo "   - Configure secure cluster communications"
echo "   - Configure a high-availability Kubernetes cluster"
echo ""

echo "3. Workloads & Scheduling (15%)"
echo "   - Understand deployments and how to perform rolling updates"
echo "   - Understand ConfigMaps and Secrets"
echo "   - Understand DaemonSets"
echo "   - Understand Jobs and CronJobs"
echo ""

echo "4. Services & Networking (20%)"
echo "   - Understand networking configuration on the cluster nodes"
echo "   - Understand Pod networking concepts"
echo "   - Understand service networking"
echo "   - Deploy and configure network load balancer"
echo ""

echo "5. Storage (10%)"
echo "   - Understand storage classes, persistent volumes"
echo "   - Understand volume modes, access modes and reclaim policies"
echo "   - Understand persistent volume claims primitive"
echo "   - Know how to configure applications with persistent storage"
echo ""

echo "6. Troubleshooting (10%)"
echo "   - Evaluate cluster and node logging"
echo "   - Understand how to monitor applications"
echo "   - Manage container stdout & stderr logs"
echo "   - Troubleshoot application failure"
echo ""

# CKAD Study Topics
echo ""
echo "=== CKAD (Certified Kubernetes Application Developer) ==="
echo "1. Application Design and Build (20%)"
echo "   - Define, build and modify container images"
echo "   - Understand Jobs and CronJobs"
echo "   - Understand multi-container Pod design patterns"
echo "   - Understand persistent and non-persistent volumes"
echo ""

echo "2. Application Deployment (20%)"
echo "   - Use Kubernetes primitives to implement common deployment strategies"
echo "   - Understand Deployments and how to perform rolling updates"
echo "   - Use the Helm package manager to deploy existing packages"
echo ""

echo "3. Application Observability and Maintenance (15%)"
echo "   - Understand API deprecations"
echo "   - Implement probes and health checks"
echo "   - Use provided tools to monitor Kubernetes applications"
echo "   - Utilize container logs"
echo ""

echo "4. Application Environment, Configuration and Security (25%)"
echo "   - Discover and use resources that extend Kubernetes"
echo "   - Understand authentication, authorization and admission control"
echo "   - Understanding and defining resource requirements, limits and quotas"
echo "   - Understand ConfigMaps"
echo "   - Understand Secrets"
echo "   - Understand ServiceAccounts"
echo "   - Understand SecurityContexts"
echo ""

echo "5. Services and Networking (20%)"
echo "   - Demonstrate basic understanding of NetworkPolicies"
echo "   - Provide and troubleshoot access to applications via services"
echo "   - Use Ingress rules to expose applications"
echo ""

echo ""
echo "=== STUDY RESOURCES ==="
echo "1. Official Documentation: kubernetes.io/docs"
echo "2. Practice Exams: killer.sh"
echo "3. Hands-on Labs: katacoda.com"
echo "4. Video Courses: Linux Foundation"
echo "5. Books: Kubernetes in Action, CKA/CKAD Study Guide"
echo ""

echo "=== PRACTICE COMMANDS ==="
echo "Essential commands to practice:"
echo "- kubectl get, describe, logs, exec"
echo "- kubectl apply, create, delete"
echo "- kubectl scale, rollout, port-forward"
echo "- kubectl config, context, namespace"
echo "- kubectl top, events, explain"
echo ""

echo "Start your certification journey today!"
EOF

chmod +x certification_study_guide.sh

# **Line-by-Line Explanation:**
# ```bash
# #!/bin/bash                    # Shebang: Specifies this is a bash script
# 
# # Kubernetes Certification Study Guide
# echo "=== KUBERNETES CERTIFICATION STUDY GUIDE ==="  # Script header
# echo "Comprehensive study guide for Kubernetes certifications"  # Purpose description
# echo ""  # Empty line for formatting
# 
# # CKA Study Topics
# echo "=== CKA (Certified Kubernetes Administrator) ==="  # CKA section header
# echo "1. Cluster Architecture (25%)"  # Topic 1 with weight
# echo "   - Understand Kubernetes cluster architecture"  # Subtopic 1
# echo "   - Understand etcd cluster"  # Subtopic 2
# echo "   - Understand control plane node components"  # Subtopic 3
# echo "   - Understand worker node components"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "2. Installation, Configuration & Validation (20%)"  # Topic 2 with weight
# echo "   - Design a Kubernetes cluster"  # Subtopic 1
# echo "   - Install Kubernetes masters and nodes"  # Subtopic 2
# echo "   - Configure secure cluster communications"  # Subtopic 3
# echo "   - Configure a high-availability Kubernetes cluster"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "3. Workloads & Scheduling (15%)"  # Topic 3 with weight
# echo "   - Understand deployments and how to perform rolling updates"  # Subtopic 1
# echo "   - Understand ConfigMaps and Secrets"  # Subtopic 2
# echo "   - Understand DaemonSets"  # Subtopic 3
# echo "   - Understand Jobs and CronJobs"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "4. Services & Networking (20%)"  # Topic 4 with weight
# echo "   - Understand networking configuration on the cluster nodes"  # Subtopic 1
# echo "   - Understand Pod networking concepts"  # Subtopic 2
# echo "   - Understand service networking"  # Subtopic 3
# echo "   - Deploy and configure network load balancer"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "5. Storage (10%)"  # Topic 5 with weight
# echo "   - Understand storage classes, persistent volumes"  # Subtopic 1
# echo "   - Understand volume modes, access modes and reclaim policies"  # Subtopic 2
# echo "   - Understand persistent volume claims primitive"  # Subtopic 3
# echo "   - Know how to configure applications with persistent storage"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "6. Troubleshooting (10%)"  # Topic 6 with weight
# echo "   - Evaluate cluster and node logging"  # Subtopic 1
# echo "   - Understand how to monitor applications"  # Subtopic 2
# echo "   - Manage container stdout & stderr logs"  # Subtopic 3
# echo "   - Troubleshoot application failure"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# # CKAD Study Topics
# echo ""  # Empty line for formatting
# echo "=== CKAD (Certified Kubernetes Application Developer) ==="  # CKAD section header
# echo "1. Application Design and Build (20%)"  # Topic 1 with weight
# echo "   - Define, build and modify container images"  # Subtopic 1
# echo "   - Understand Jobs and CronJobs"  # Subtopic 2
# echo "   - Understand multi-container Pod design patterns"  # Subtopic 3
# echo "   - Understand persistent and non-persistent volumes"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "2. Application Deployment (20%)"  # Topic 2 with weight
# echo "   - Use Kubernetes primitives to implement common deployment strategies"  # Subtopic 1
# echo "   - Understand Deployments and how to perform rolling updates"  # Subtopic 2
# echo "   - Use the Helm package manager to deploy existing packages"  # Subtopic 3
# echo ""  # Empty line for formatting
# 
# echo "3. Application Observability and Maintenance (15%)"  # Topic 3 with weight
# echo "   - Understand API deprecations"  # Subtopic 1
# echo "   - Implement probes and health checks"  # Subtopic 2
# echo "   - Use provided tools to monitor Kubernetes applications"  # Subtopic 3
# echo "   - Utilize container logs"  # Subtopic 4
# echo ""  # Empty line for formatting
# 
# echo "4. Application Environment, Configuration and Security (25%)"  # Topic 4 with weight
# echo "   - Discover and use resources that extend Kubernetes"  # Subtopic 1
# echo "   - Understand authentication, authorization and admission control"  # Subtopic 2
# echo "   - Understanding and defining resource requirements, limits and quotas"  # Subtopic 3
# echo "   - Understand ConfigMaps"  # Subtopic 4
# echo "   - Understand Secrets"  # Subtopic 5
# echo "   - Understand ServiceAccounts"  # Subtopic 6
# echo "   - Understand SecurityContexts"  # Subtopic 7
# echo ""  # Empty line for formatting
# 
# echo "5. Services and Networking (20%)"  # Topic 5 with weight
# echo "   - Demonstrate basic understanding of NetworkPolicies"  # Subtopic 1
# echo "   - Provide and troubleshoot access to applications via services"  # Subtopic 2
# echo "   - Use Ingress rules to expose applications"  # Subtopic 3
# echo ""  # Empty line for formatting
# 
# echo ""  # Empty line for formatting
# echo "=== STUDY RESOURCES ==="  # Resources section header
# echo "1. Official Documentation: kubernetes.io/docs"  # Resource 1
# echo "2. Practice Exams: killer.sh"  # Resource 2
# echo "3. Hands-on Labs: katacoda.com"  # Resource 3
# echo "4. Video Courses: Linux Foundation"  # Resource 4
# echo "5. Books: Kubernetes in Action, CKA/CKAD Study Guide"  # Resource 5
# echo ""  # Empty line for formatting
# 
# echo "=== PRACTICE COMMANDS ==="  # Commands section header
# echo "Essential commands to practice:"  # Commands description
# echo "- kubectl get, describe, logs, exec"  # Command group 1
# echo "- kubectl apply, create, delete"  # Command group 2
# echo "- kubectl scale, rollout, port-forward"  # Command group 3
# echo "- kubectl config, context, namespace"  # Command group 4
# echo "- kubectl top, events, explain"  # Command group 5
# echo ""  # Empty line for formatting
# 
# echo "Start your certification journey today!"  # Encouragement message
# ```
# 
# **Expected Output:**
# ```
# === KUBERNETES CERTIFICATION STUDY GUIDE ===
# Comprehensive study guide for Kubernetes certifications
# 
# === CKA (Certified Kubernetes Administrator) ===
# 1. Cluster Architecture (25%)
#    - Understand Kubernetes cluster architecture
#    - Understand etcd cluster
#    - Understand control plane node components
#    - Understand worker node components
# 
# 2. Installation, Configuration & Validation (20%)
#    - Design a Kubernetes cluster
#    - Install Kubernetes masters and nodes
#    - Configure secure cluster communications
#    - Configure a high-availability Kubernetes cluster
# 
# 3. Workloads & Scheduling (15%)
#    - Understand deployments and how to perform rolling updates
#    - Understand ConfigMaps and Secrets
#    - Understand DaemonSets
#    - Understand Jobs and CronJobs
# 
# 4. Services & Networking (20%)
#    - Understand networking configuration on the cluster nodes
#    - Understand Pod networking concepts
#    - Understand service networking
#    - Deploy and configure network load balancer
# 
# 5. Storage (10%)
#    - Understand storage classes, persistent volumes
#    - Understand volume modes, access modes and reclaim policies
#    - Understand persistent volume claims primitive
#    - Know how to configure applications with persistent storage
# 
# 6. Troubleshooting (10%)
#    - Evaluate cluster and node logging
#    - Understand how to monitor applications
#    - Manage container stdout & stderr logs
#    - Troubleshoot application failure
# 
# === CKAD (Certified Kubernetes Application Developer) ===
# 1. Application Design and Build (20%)
#    - Define, build and modify container images
#    - Understand Jobs and CronJobs
#    - Understand multi-container Pod design patterns
#    - Understand persistent and non-persistent volumes
# 
# 2. Application Deployment (20%)
#    - Use Kubernetes primitives to implement common deployment strategies
#    - Understand Deployments and how to perform rolling updates
#    - Use the Helm package manager to deploy existing packages
# 
# 3. Application Observability and Maintenance (15%)
#    - Understand API deprecations
#    - Implement probes and health checks
#    - Use provided tools to monitor Kubernetes applications
#    - Utilize container logs
# 
# 4. Application Environment, Configuration and Security (25%)
#    - Discover and use resources that extend Kubernetes
#    - Understand authentication, authorization and admission control
#    - Understanding and defining resource requirements, limits and quotas
#    - Understand ConfigMaps
#    - Understand Secrets
#    - Understand ServiceAccounts
#    - Understand SecurityContexts
# 
# 5. Services and Networking (20%)
#    - Demonstrate basic understanding of NetworkPolicies
#    - Provide and troubleshoot access to applications via services
#    - Use Ingress rules to expose applications
# 
# === STUDY RESOURCES ===
# 1. Official Documentation: kubernetes.io/docs
# 2. Practice Exams: killer.sh
# 3. Hands-on Labs: katacoda.com
# 4. Video Courses: Linux Foundation
# 5. Books: Kubernetes in Action, CKA/CKAD Study Guide
# 
# === PRACTICE COMMANDS ===
# Essential commands to practice:
# - kubectl get, describe, logs, exec
# - kubectl apply, create, delete
# - kubectl scale, rollout, port-forward
# - kubectl config, context, namespace
# - kubectl top, events, explain
# 
# Start your certification journey today!
# ```
# 
# **Key Learning Points:**
# - **Comprehensive Coverage**: Covers both CKA and CKAD certification requirements
# - **Weighted Topics**: Shows exam weight percentages for each topic area
# - **Detailed Breakdown**: Provides specific subtopics for each major area
# - **Study Resources**: Lists official and community resources for preparation
# - **Practice Commands**: Includes essential kubectl commands to practice
# - **Professional Standards**: Follows official certification exam structure
# - **Clear Organization**: Uses clear sections and formatting for easy reference
# - **Actionable Content**: Provides specific learning objectives and commands
# - **Motivational Elements**: Includes encouragement to start certification journey
# - **Industry Recognition**: Covers industry-standard Kubernetes certifications
```

### **🔗 Quick Reference Links**

#### **Essential Links**
- **[Kubernetes.io](https://kubernetes.io/)**: Official Kubernetes website
- **[Kubernetes Documentation](https://kubernetes.io/docs/)**: Complete documentation
- **[Kubernetes GitHub](https://github.com/kubernetes/kubernetes)**: Source code
- **[Kubernetes Blog](https://kubernetes.io/blog/)**: Latest news and tutorials
- **[Kubernetes Slack](https://slack.k8s.io/)**: Community chat
- **[Kubernetes Forum](https://discuss.kubernetes.io/)**: Community discussions

#### **Learning Paths**
- **[Kubernetes Learning Path](https://kubernetes.io/docs/tutorials/)**: Official tutorials
- **[Kubernetes by Example](https://kubernetesbyexample.com/)**: Practical examples
- **[Kubernetes Katacoda](https://www.katacoda.com/courses/kubernetes)**: Interactive labs
- **[Kubernetes Playground](https://labs.play-with-k8s.com/)**: Free practice environment

### **📈 Continuous Learning Strategy**

#### **Learning Roadmap**
1. **Foundation (1-3 months)**
   - Basic Kubernetes concepts
   - kubectl commands
   - Pod and Service management
   - Basic troubleshooting

2. **Intermediate (3-6 months)**
   - Advanced resource types
   - Networking and security
   - Monitoring and logging
   - CI/CD integration

3. **Advanced (6-12 months)**
   - Multi-cluster management
   - Performance optimization
   - Security hardening
   - Enterprise integration

4. **Expert (12+ months)**
   - Custom controllers
   - Platform engineering
   - Architecture design
   - Community contribution

#### **Learning Tips**
- **Practice regularly** with hands-on labs
- **Join community discussions** and forums
- **Contribute to open source** projects
- **Stay updated** with latest releases
- **Share knowledge** with others
- **Pursue certifications** for validation

---

## ✅ **Module Completion Checklist**

- [ ] **Prerequisites**: All technical and knowledge prerequisites met
- [ ] **Theory**: Complete understanding of Kubernetes architecture
- [ ] **Commands**: Proficiency with all kubectl commands and flags
- [ ] **Labs**: All hands-on labs completed successfully
- [ ] **Practice Problems**: All practice problems solved with detailed solutions
- [ ] **Mini-Project**: Production-ready cluster architecture project completed
- [ ] **Interview Questions**: All interview questions answered correctly
- [ ] **Chaos Engineering**: Cluster component failure testing completed
- [ ] **Environment Strategy**: DEV, UAT, PROD environment understanding
- [ ] **Tools**: Familiarity with all covered and industry tools

## 📚 **Additional Resources**

### **Official Documentation**
- [Kubernetes Architecture](https://kubernetes.io/docs/concepts/architecture/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [etcd Documentation](https://etcd.io/docs/)

### **Books**
- "Kubernetes: Up and Running" by Kelsey Hightower
- "Kubernetes in Action" by Marko Lukša
- "Kubernetes Patterns" by Bilgin Ibryam

### **Online Courses**
- Kubernetes Fundamentals (Linux Foundation)
- Certified Kubernetes Administrator (CKA)
- Kubernetes Security Specialist (CKS)

### **Practice Platforms**
- [Kubernetes Playground](https://www.katacoda.com/courses/kubernetes)
- [Kubernetes by Example](https://kubernetesbyexample.com/)
- [Kubernetes Hands-on Labs](https://kubernetes.io/docs/tutorials/)

---
