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
#   --short: Print just the version number
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
#   --show-labels: Show node labels
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
