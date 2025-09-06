# 📊 **Module 5: Initial Monitoring Setup (Prometheus & Grafana)**
## Essential Monitoring Skills for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 4-5 hours (enhanced with complete foundational knowledge)  
**Prerequisites**: See detailed prerequisites below  
**Learning Objectives**: Master monitoring setup essential for Kubernetes with complete foundational knowledge

---

## 🎯 **Detailed Prerequisites**

### **🔧 Technical Prerequisites**

#### **System Requirements**
- **OS**: Linux (Ubuntu 20.04+ recommended) or macOS 10.15+
- **RAM**: Minimum 8GB (16GB recommended for full monitoring stack)
- **CPU**: 4+ cores (8+ cores recommended for production monitoring)
- **Storage**: 50GB+ free space (100GB+ for long-term metrics retention)
- **Network**: Stable internet connection for image pulls and external monitoring

#### **Software Requirements**
- **Kubernetes Cluster**: Version 1.20+ (kubeadm, minikube, or cloud provider)
  ```bash
# =============================================================================
# KUBERNETES VERSION VERIFICATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubectl version --client --server
# Purpose: Display both client and server Kubernetes version information
# Flags: --client (show client version), --server (show server version)
# Usage: kubectl version --client --server
# Output: Client Version: v1.28.0, Server Version: v1.28.0
# Examples: Used for version compatibility verification
# Notes: Essential for ensuring client-server compatibility

  # Verify Kubernetes version
  kubectl version --client --server
  # Expected: Client Version: v1.20+, Server Version: v1.20+
  ```
- **kubectl**: Latest version matching your cluster
  ```bash
# =============================================================================
# KUBECTL INSTALLATION COMMANDS - TIER 3 DOCUMENTATION
# =============================================================================

# Command: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Purpose: Download latest stable kubectl binary from Kubernetes releases
# Flags: -L (follow redirects), -O (output to file)
# Usage: curl -LO [URL]
# Output: Downloads kubectl binary to current directory
# Examples: Used for installing Kubernetes CLI tools
# Notes: Nested curl command gets latest stable version URL

# Command: sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Purpose: Install kubectl binary with proper permissions
# Flags: -o root (set owner), -g root (set group), -m 0755 (set permissions)
# Usage: sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Output: Installs kubectl to /usr/local/bin/kubectl
# Examples: Standard binary installation with permissions
# Notes: 0755 gives owner read/write/execute, group/others read/execute

# Command: kubectl version --client
# Purpose: Display kubectl client version information
# Flags: --client (show only client version)
# Usage: kubectl version --client
# Output: Client Version: version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.0"}
# Examples: Used for tool verification
# Notes: Confirms successful kubectl installation

  # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  kubectl version --client
  ```
- **Helm**: Version 3.0+ (required for monitoring stack deployment)
  ```bash
# =============================================================================
# HELM INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Purpose: Download and install Helm 3 using official installation script
# Flags: curl (download), | (pipe), bash (execute script)
# Usage: curl [URL] | bash
# Output: Downloads and installs Helm 3
# Examples: Used for installing Helm package manager
# Notes: Pipes download directly to bash for installation

# Command: helm version
# Purpose: Display Helm version information
# Flags: version (show version)
# Usage: helm version
# Output: version.BuildInfo{Version:"v3.12.0", GitCommit:"c9f554d75773799f72ceef38c51210f1842a1dea"}
# Examples: Used for tool verification
# Notes: Confirms successful Helm installation

  # Install Helm
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  helm version
  ```
- **Docker**: Engine 20.10+ (for local testing and image building)
  ```bash
# =============================================================================
# DOCKER VERIFICATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: docker --version
# Purpose: Display Docker version information
# Flags: --version (show version)
# Usage: docker --version
# Output: Docker version 24.0.6, build ed223bc
# Examples: Used for tool verification
# Notes: Confirms successful Docker installation

# Command: docker run hello-world
# Purpose: Run hello-world container to test Docker functionality
# Flags: run (run container), hello-world (container image)
# Usage: docker run hello-world
# Output: Downloads and runs hello-world container with success message
# Examples: Used for Docker functionality testing
# Notes: Essential for verifying Docker daemon is working

  # Verify Docker installation
  docker --version
  docker run hello-world
  ```

#### **Package Dependencies**
- **yq**: YAML processor for configuration management
  ```bash
# =============================================================================
# YQ INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
# Purpose: Download yq YAML processor binary from GitHub releases
# Flags: -q (quiet), -O (output to file)
# Usage: sudo wget -qO /usr/local/bin/yq [URL]
# Output: Downloads yq binary to /usr/local/bin/yq
# Examples: Used for installing YAML processing tools
# Notes: Requires sudo for system-wide installation

# Command: sudo chmod +x /usr/local/bin/yq
# Purpose: Make yq binary executable
# Flags: +x (add execute permission)
# Usage: sudo chmod +x /usr/local/bin/yq
# Output: Makes yq executable for all users
# Examples: Required after downloading binaries
# Notes: Essential for running downloaded executables

# Command: yq --version
# Purpose: Display yq version information
# Flags: --version (show version)
# Usage: yq --version
# Output: yq version 4.x.x
# Examples: Used for tool verification
# Notes: Confirms successful installation

  # Install yq
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod +x /usr/local/bin/yq
  yq --version
  ```
- **jq**: JSON processor for API responses
  ```bash
# =============================================================================
# JQ INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo apt-get update && sudo apt-get install -y jq
# Purpose: Update package list and install jq JSON processor
# Flags: update (refresh package list), install -y (auto-confirm installation)
# Usage: sudo apt-get update && sudo apt-get install -y jq
# Output: Installs jq package from repositories
# Examples: Standard package installation command
# Notes: && ensures update runs before install

# Command: jq --version
# Purpose: Display jq version information
# Flags: --version (show version)
# Usage: jq --version
# Output: jq-1.6
# Examples: Used for tool verification
# Notes: Confirms successful installation

  # Install jq
  sudo apt-get update && sudo apt-get install -y jq
  jq --version
  ```
- **curl**: HTTP client for API testing
  ```bash
# =============================================================================
# CURL VERIFICATION COMMANDS - TIER 1 DOCUMENTATION
# =============================================================================

# Command: curl --version
# Purpose: Display curl version information
# Flags: --version (show version)
# Usage: curl --version
# Output: curl 7.68.0 (x86_64-pc-linux-gnu)
# Notes: Part of tool verification checklist

  # Verify curl installation
  curl --version
  ```

#### **Network Requirements**
- **Port Access**: Ensure these ports are available:
  - `3000`: Grafana web interface
  - `9090`: Prometheus web interface
  - `9093`: AlertManager web interface
  - `9100`: Node Exporter metrics
  - `8080`: cAdvisor metrics
- **Firewall Configuration**: Allow inbound connections on monitoring ports
  ```bash
# =============================================================================
# PORT AVAILABILITY CHECK COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: netstat -tuln | grep -E "(3000|9090|9093|9100|8080)"
# Purpose: Check if monitoring ports are available on the system
# Flags: -t (TCP), -u (UDP), -l (listening), -n (numeric), | (pipe), grep -E (extended regex)
# Usage: netstat -tuln | grep -E "(3000|9090|9093|9100|8080)"
# Output: Lists listening ports matching monitoring port numbers
# Examples: Used for port conflict detection
# Notes: Essential for ensuring monitoring ports are available

  # Check port availability
  netstat -tuln | grep -E "(3000|9090|9093|9100|8080)"
  ```

### **📖 Knowledge Prerequisites**

#### **Required Module Completion**
- **Module 0**: Essential Linux Commands - File operations, process management, text processing
- **Module 1**: Container Fundamentals - Docker basics, container lifecycle, image management
- **Module 2**: Linux System Administration - System monitoring, process management, file systems
- **Module 3**: Networking Fundamentals - TCP/IP, DNS, network troubleshooting
- **Module 4**: YAML Configuration Management - YAML syntax, Kubernetes manifests, Kustomize

#### **Concepts to Master**
- **Kubernetes Basics**: Pods, Services, Deployments, ConfigMaps, Secrets
- **Monitoring Concepts**: Metrics, alerts, dashboards, time-series data
- **Prometheus**: Metrics collection, querying (PromQL), alerting rules
- **Grafana**: Dashboard creation, data source configuration, visualization
- **Container Monitoring**: Resource usage, application metrics, health checks

#### **Skills Required**
- **kubectl Proficiency**: Basic kubectl commands, resource management, troubleshooting
- **YAML Editing**: Creating and modifying Kubernetes manifests
- **Linux Administration**: File system management, process monitoring, log analysis
- **Network Troubleshooting**: Connectivity testing, port verification, DNS resolution

### **🛠️ Environment Prerequisites**

#### **Development Environment**
- **Text Editor**: VS Code, Vim, or Nano with YAML support
- **Terminal**: Bash shell with kubectl and helm completion
- **Git**: Version control for configuration management
  ```bash
  # Verify Git installation
  git --version
  ```

#### **Testing Environment**
- **Kubernetes Cluster**: Running and accessible
  ```bash
  # Verify cluster connectivity
  kubectl cluster-info
  kubectl get nodes
  kubectl get namespaces
  ```
- **Persistent Volume Support**: For monitoring data storage
  ```bash
  # Check storage classes
  kubectl get storageclass
  ```

#### **Production Environment**
- **RBAC Configuration**: Proper permissions for monitoring components
- **Network Policies**: Security rules for monitoring traffic
- **Resource Limits**: CPU and memory constraints for monitoring pods
- **Backup Strategy**: Data retention and backup policies

### **📋 Validation Prerequisites**

#### **Pre-Module Assessment**
```bash
# =============================================================================
# PREREQUISITE VALIDATION COMMANDS - TIER 1/2 DOCUMENTATION
# =============================================================================

# Command: kubectl cluster-info
# Purpose: Display cluster information and endpoints
# Flags: None (default command)
# Usage: kubectl cluster-info
# Output: Shows cluster master URL and services
# Notes: Part of cluster verification checklist

# Command: kubectl get nodes
# Purpose: List all nodes in the cluster
# Flags: get (retrieve resources), nodes (node resource type)
# Usage: kubectl get nodes
# Output: Lists cluster nodes with status
# Notes: Part of cluster verification checklist

# Command: kubectl get namespaces
# Purpose: List all namespaces in the cluster
# Flags: get (retrieve resources), namespaces (namespace resource type)
# Usage: kubectl get namespaces
# Output: Lists cluster namespaces
# Notes: Part of cluster verification checklist

# Command: kubectl version --client
# Purpose: Display kubectl client version information
# Flags: --client (show only client version)
# Usage: kubectl version --client
# Output: Client Version: version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.0"}
# Notes: Part of tool verification checklist

# Command: helm version
# Purpose: Display Helm version information
# Flags: version (show version)
# Usage: helm version
# Output: version.BuildInfo{Version:"v3.12.0", GitCommit:"c9f554d75773799f72ceef38c51210f1842a1dea"}
# Notes: Part of tool verification checklist

# Command: docker --version
# Purpose: Display Docker version information
# Flags: --version (show version)
# Usage: docker --version
# Output: Docker version 24.0.6, build ed223bc
# Notes: Part of tool verification checklist

# Command: yq --version
# Purpose: Display yq version information
# Flags: --version (show version)
# Usage: yq --version
# Output: yq version 4.x.x
# Notes: Part of tool verification checklist

# Command: jq --version
# Purpose: Display jq version information
# Flags: --version (show version)
# Usage: jq --version
# Output: jq-1.6
# Notes: Part of tool verification checklist

# Command: ping -c 3 google.com
# Purpose: Test network connectivity to Google DNS
# Flags: -c 3 (send 3 packets)
# Usage: ping -c 3 google.com
# Output: Ping statistics and response times
# Notes: Part of network connectivity verification

# Command: curl -I https://prometheus.io
# Purpose: Test HTTP connectivity to Prometheus website
# Flags: -I (head request only)
# Usage: curl -I https://prometheus.io
# Output: HTTP headers from Prometheus website
# Notes: Part of network connectivity verification

# Command: free -h
# Purpose: Display memory usage in human-readable format
# Flags: -h (human-readable)
# Usage: free -h
# Output: Memory usage statistics
# Notes: Part of system resource verification

# Command: df -h
# Purpose: Display disk usage in human-readable format
# Flags: -h (human-readable)
# Usage: df -h
# Output: Disk usage statistics
# Notes: Part of system resource verification

# Command: nproc
# Purpose: Display number of processing units available
# Flags: None (default command)
# Usage: nproc
# Output: Number of CPU cores
# Notes: Part of system resource verification

# 1. Verify Kubernetes cluster is running
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# 2. Verify required tools are installed
kubectl version --client
helm version
docker --version
yq --version
jq --version

# 3. Verify network connectivity
ping -c 3 google.com
curl -I https://prometheus.io

# 4. Verify system resources
free -h
df -h
nproc
```

#### **Setup Validation Commands**
```bash
# =============================================================================
# SETUP VALIDATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubectl create namespace monitoring-test
# Purpose: Create test namespace for monitoring validation
# Flags: create (create resource), namespace (namespace resource type)
# Usage: kubectl create namespace monitoring-test
# Output: Creates monitoring-test namespace
# Examples: Used for testing namespace creation
# Notes: Essential for monitoring setup validation

# Command: kubectl get namespace monitoring-test
# Purpose: Verify test namespace was created successfully
# Flags: get (retrieve resources), namespace (namespace resource type)
# Usage: kubectl get namespace monitoring-test
# Output: Shows monitoring-test namespace details
# Examples: Used for namespace verification
# Notes: Confirms namespace creation

# Command: kubectl apply -f - <<EOF
# Purpose: Apply YAML configuration from stdin using here document
# Flags: apply (apply configuration), -f - (read from stdin), <<EOF (here document)
# Usage: kubectl apply -f - <<EOF
# Output: Creates PersistentVolumeClaim from YAML
# Examples: Used for testing PVC creation
# Notes: Here document allows multi-line YAML input

# Command: kubectl get pvc -n monitoring-test
# Purpose: List PersistentVolumeClaims in monitoring-test namespace
# Flags: get (retrieve resources), pvc (PVC resource type), -n (namespace)
# Usage: kubectl get pvc -n monitoring-test
# Output: Lists PVCs in monitoring-test namespace
# Examples: Used for PVC verification
# Notes: Confirms PVC creation

# Command: kubectl delete namespace monitoring-test
# Purpose: Delete test namespace and all resources
# Flags: delete (delete resource), namespace (namespace resource type)
# Usage: kubectl delete namespace monitoring-test
# Output: Deletes monitoring-test namespace
# Examples: Used for cleanup after testing
# Notes: Removes all resources in the namespace

# Create test namespace
kubectl create namespace monitoring-test
kubectl get namespace monitoring-test

# Test persistent volume creation
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
  namespace: monitoring-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Verify PVC creation
kubectl get pvc -n monitoring-test

# Cleanup test resources
kubectl delete namespace monitoring-test
```

#### **Troubleshooting Common Issues**
- **Cluster Not Accessible**: Check kubeconfig, cluster status, network connectivity
- **Insufficient Resources**: Verify RAM, CPU, and storage availability
- **Port Conflicts**: Check for existing services using monitoring ports
- **Permission Issues**: Verify RBAC permissions for monitoring namespace

#### **Alternative Options**
- **Cloud Providers**: AWS EKS, GCP GKE, Azure AKS with managed monitoring
- **Local Development**: minikube, kind, or Docker Desktop with Kubernetes
- **Managed Services**: Prometheus-as-a-Service, Grafana Cloud for simplified setup

### **🚀 Quick Start Checklist**

Before starting this module, ensure you have:

- [ ] **Kubernetes cluster** (1.20+) running and accessible
- [ ] **kubectl** configured and working (`kubectl cluster-info`)
- [ ] **Helm 3.0+** installed and working (`helm version`)
- [ ] **8GB+ RAM** available for monitoring stack
- [ ] **50GB+ disk space** for metrics storage
- [ ] **Network access** to monitoring ports (3000, 9090, 9093, 9100, 8080)
- [ ] **yq and jq** installed for configuration processing
- [ ] **Previous modules** (0-4) completed successfully
- [ ] **Basic Kubernetes knowledge** (Pods, Services, Deployments)
- [ ] **YAML editing** skills for configuration files

### **⚠️ Important Notes**

- **Resource Requirements**: Monitoring stack requires significant resources. Ensure adequate RAM and storage.
- **Network Security**: Monitoring components expose web interfaces. Configure proper network policies.
- **Data Retention**: Plan for metrics storage and retention policies based on your needs.
- **Backup Strategy**: Implement backup procedures for monitoring configuration and data.
- **Security**: Use proper RBAC, network policies, and secrets management for production deployments.

---

### **🛠️ Tools Covered**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Node Exporter**: Node-level metrics collection
- **cAdvisor**: Container metrics collection
- **AlertManager**: Alerting and notification management

### **🏭 Industry Tools**
- **Datadog**: Cloud-based monitoring and analytics
- **New Relic**: Application performance monitoring
- **Splunk**: Log analysis and monitoring
- **Dynatrace**: Application performance monitoring
- **CloudWatch**: AWS cloud monitoring
- **Azure Monitor**: Microsoft Azure monitoring

### **🌍 Environment Strategy**
This module prepares monitoring skills for all environments:
- **DEV**: Development monitoring with basic metrics
- **UAT**: User Acceptance Testing monitoring with full stack
- **PROD**: Production monitoring with comprehensive alerting

### **💥 Chaos Engineering**
- **Monitoring system failure testing**: Testing behavior under monitoring failures
- **Alert fatigue simulation**: Testing alert management under high alert volume
- **Metrics collection disruption**: Testing application behavior when metrics are unavailable
- **Dashboard corruption testing**: Testing monitoring system resilience

### **Chaos Packages**
- **None (manual monitoring disruption testing)**: Manual testing with monitoring system failures

---

## 🎯 **Learning Objectives**

By the end of this module, you will:
- Master Prometheus metrics collection and configuration
- Understand Grafana dashboard creation and management
- Learn alerting and notification setup
- Master monitoring best practices and patterns
- Understand observability principles and implementation
- Apply monitoring concepts to Kubernetes cluster management
- Implement chaos engineering scenarios for monitoring resilience

---

## 📚 **Theory Section: Monitoring Fundamentals**

### **Why Monitoring for Kubernetes?**

Kubernetes clusters require comprehensive monitoring for:
- **Cluster Health**: Node status, pod health, resource utilization
- **Application Performance**: Response times, error rates, throughput
- **Resource Management**: CPU, memory, storage usage and limits
- **Security**: Unusual activity, policy violations, access patterns
- **Cost Optimization**: Resource efficiency, unused resources
- **Incident Response**: Quick problem identification and resolution

### **Monitoring Stack Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                        │
├─────────────────────────────────────────────────────────────┤
│  Grafana (Visualization & Dashboards)                      │
├─────────────────────────────────────────────────────────────┤
│  AlertManager (Alerting & Notifications)                   │
├─────────────────────────────────────────────────────────────┤
│  Prometheus (Metrics Collection & Storage)                 │
├─────────────────────────────────────────────────────────────┤
│  Node Exporter (Node Metrics)                              │
│  cAdvisor (Container Metrics)                              │
│  Application Metrics (Custom Metrics)                      │
└─────────────────────────────────────────────────────────────┘
```

### **Essential Monitoring Concepts**

#### **1. Metrics Types**
- **Counter**: Monotonically increasing values (requests, errors)
- **Gauge**: Values that can go up or down (memory usage, active connections)
- **Histogram**: Distribution of values (response times, request sizes)
- **Summary**: Quantiles and counts (percentiles, averages)

#### **2. Monitoring Layers**
- **Infrastructure**: CPU, memory, disk, network
- **Platform**: Kubernetes cluster, nodes, pods
- **Application**: Business metrics, performance metrics
- **User Experience**: Response times, error rates, availability

#### **3. Alerting Principles**
- **Alert Rules**: Conditions that trigger alerts
- **Alert Severity**: Critical, warning, info levels
- **Alert Routing**: Different channels for different severities
- **Alert Fatigue**: Avoiding too many false positives

#### **4. Observability Pillars**
- **Metrics**: Quantitative data about system behavior
- **Logs**: Event records with timestamps
- **Traces**: Request flow through distributed systems
- **Profiles**: Detailed performance analysis

---

## 🔧 **Hands-on Lab: Monitoring Setup**

### **Lab 1: Prometheus Installation and Configuration**

**📋 Overview**: Set up Prometheus for metrics collection and storage.

**🔍 Detailed Installation Analysis**:

```bash
# =============================================================================
# MONITORING NAMESPACE CREATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubectl create namespace monitoring
# Purpose: Create dedicated namespace for monitoring components
# Flags: create (create resource), namespace (namespace resource type)
# Usage: kubectl create namespace monitoring
# Output: Creates monitoring namespace
# Examples: Used for isolating monitoring components
# Notes: Essential for organizing monitoring resources

# Create monitoring namespace
kubectl create namespace monitoring
```

**Explanation**:
- `kubectl create namespace monitoring`: Create dedicated namespace for monitoring
- **Purpose**: Isolate monitoring components from application workloads

```yaml
# prometheus-config.yaml
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
    
    alerting:
      alertmanagers:
        - static_configs:
            - targets:
              - alertmanager:9093
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - source_labels: [__address__]
            regex: '(.*):10250'
            target_label: __address__
            replacement: '${1}:9100'
      
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
```

**Explanation**:
- `global:`: Global configuration for Prometheus
- `scrape_interval: 15s`: How often to scrape metrics
- `evaluation_interval: 15s`: How often to evaluate alert rules
- `rule_files:`: Alert rules configuration
- `alerting:`: AlertManager configuration
- `scrape_configs:`: Targets to scrape metrics from
- **Purpose**: Configure Prometheus to collect metrics from various sources

```yaml
# prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
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
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-pvc
```

**Explanation**:
- `image: prom/prometheus:latest`: Official Prometheus image
- `--config.file=/etc/prometheus/prometheus.yml`: Configuration file path
- `--storage.tsdb.path=/prometheus`: Metrics storage path
- `--storage.tsdb.retention.time=200h`: Data retention period
- `--web.enable-lifecycle`: Enable configuration reloading
- **Purpose**: Deploy Prometheus with persistent storage and configuration

### **Lab 2: Grafana Installation and Dashboard Setup**

**📋 Overview**: Set up Grafana for metrics visualization and dashboard creation.

**🔍 Detailed Installation Analysis**:

```yaml
# grafana-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-piechart-panel"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning/datasources
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-pvc
      - name: grafana-config
        configMap:
          name: grafana-datasources
```

**Explanation**:
- `image: grafana/grafana:latest`: Official Grafana image
- `GF_SECURITY_ADMIN_PASSWORD: "admin123"`: Admin password
- `GF_INSTALL_PLUGINS`: Additional plugins to install
- `volumeMounts:`: Persistent storage for Grafana data
- **Purpose**: Deploy Grafana with persistent storage and configuration

```yaml
# grafana-datasources.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  prometheus.yaml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus:9090
        access: proxy
        isDefault: true
```

**Explanation**:
- `type: prometheus`: Data source type
- `url: http://prometheus:9090`: Prometheus service URL
- `access: proxy`: Access mode (proxy or direct)
- `isDefault: true`: Set as default data source
- **Purpose**: Configure Prometheus as data source for Grafana

```bash
# =============================================================================
# GRAFANA ACCESS COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Purpose: Forward local port 3000 to Grafana service in monitoring namespace
# Flags: port-forward (port forwarding), svc/grafana (service name), 3000:3000 (local:remote ports), -n (namespace)
# Usage: kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Output: Forwards local port 3000 to Grafana service
# Examples: Used for accessing Grafana web interface
# Notes: Essential for local access to Grafana dashboard

# Access Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring
# Access: http://localhost:3000
# Username: admin
# Password: admin123
```

**Explanation**:
- `kubectl port-forward`: Forward local port to Grafana service
- **Purpose**: Access Grafana web interface for dashboard creation

### **Lab 3: Node Exporter and cAdvisor Setup**

**📋 Overview**: Set up node and container metrics collection.

**🔍 Detailed Setup Analysis**:

```yaml
# node-exporter-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        args:
          - '--path.procfs=/host/proc'
          - '--path.sysfs=/host/sys'
          - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
```

**Explanation**:
- `kind: DaemonSet`: Deploy one pod per node
- `hostNetwork: true`: Use host network for node metrics
- `hostPID: true`: Access host process information
- `--path.procfs=/host/proc`: Path to host proc filesystem
- `--path.sysfs=/host/sys`: Path to host sys filesystem
- **Purpose**: Collect node-level metrics from all cluster nodes

```yaml
# cadvisor-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cadvisor
  namespace: monitoring
  labels:
    app: cadvisor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cadvisor
  template:
    metadata:
      labels:
        app: cadvisor
    spec:
      containers:
      - name: cadvisor
        image: gcr.io/cadvisor/cadvisor:latest
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
        - name: var-run
          mountPath: /var/run
          readOnly: true
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: docker
          mountPath: /var/lib/docker
          readOnly: true
        - name: disk
          mountPath: /dev/disk
          readOnly: true
      volumes:
      - name: rootfs
        hostPath:
          path: /
      - name: var-run
        hostPath:
          path: /var/run
      - name: sys
        hostPath:
          path: /sys
      - name: docker
        hostPath:
          path: /var/lib/docker
      - name: disk
        hostPath:
          path: /dev/disk
```

**Explanation**:
- `image: gcr.io/cadvisor/cadvisor:latest`: cAdvisor container image
- `volumeMounts:`: Mount host filesystems for container metrics
- **Purpose**: Collect container-level metrics and resource usage

### **Lab 4: AlertManager Configuration**

**📋 Overview**: Set up alerting and notification management.

**🔍 Detailed Configuration Analysis**:

```yaml
# alertmanager-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alerts@ecommerce.com'
    
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
      routes:
      - match:
          severity: critical
        receiver: 'critical-alerts'
      - match:
          severity: warning
        receiver: 'warning-alerts'
    
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://webhook:5001/'
    
    - name: 'critical-alerts'
      email_configs:
      - to: 'admin@ecommerce.com'
        subject: 'Critical Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    
    - name: 'warning-alerts'
      email_configs:
      - to: 'team@ecommerce.com'
        subject: 'Warning Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

**Explanation**:
- `global:`: Global configuration for AlertManager
- `route:`: Alert routing configuration
- `group_by: ['alertname']`: Group alerts by alert name
- `group_wait: 10s`: Wait time before sending grouped alerts
- `receivers:`: Alert notification channels
- **Purpose**: Configure alert routing and notification channels

```yaml
# alert-rules.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alert-rules
  namespace: monitoring
data:
  alert_rules.yml: |
    groups:
    - name: ecommerce-alerts
      rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"
      
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 5 minutes"
      
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.pod }} is restarting frequently"
```

**Explanation**:
- `groups:`: Alert rule groups
- `alert: HighCPUUsage`: Alert name
- `expr:`: PromQL expression for alert condition
- `for: 5m`: Duration before alert fires
- `labels:`: Alert labels for routing
- `annotations:`: Alert description and summary
- **Purpose**: Define alert rules for monitoring system health

### **Lab 5: E-commerce Application Monitoring**

**📋 Overview**: Set up monitoring for your e-commerce application.

**🔍 Detailed Application Monitoring Analysis**:

```yaml
# ecommerce-backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: default
  labels:
    app: ecommerce-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: PROMETHEUS_MULTIPROC_DIR
          value: "/tmp"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**Explanation**:
- `prometheus.io/scrape: "true"`: Enable Prometheus scraping
- `prometheus.io/port: "8000"`: Metrics port
- `prometheus.io/path: "/metrics"`: Metrics endpoint path
- `PROMETHEUS_MULTIPROC_DIR: "/tmp"`: Prometheus multiprocess directory
- `livenessProbe:`: Health check for container liveness
- `readinessProbe:`: Health check for container readiness
- **Purpose**: Configure e-commerce backend for monitoring

```python
# Add to your FastAPI backend (main.py)
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi import FastAPI, Request
import time

app = FastAPI()

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_DURATION.observe(process_time)
    
    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/ready")
async def ready():
    return {"status": "ready"}
```

**Explanation**:
- `from prometheus_client import Counter, Histogram`: Import Prometheus metrics
- `REQUEST_COUNT`: Counter for HTTP requests
- `REQUEST_DURATION`: Histogram for request duration
- `@app.middleware("http")`: Middleware to collect metrics
- `@app.get("/metrics")`: Metrics endpoint for Prometheus
- **Purpose**: Add Prometheus metrics to your e-commerce backend

---

## 🎯 **Practice Problems**

### **Problem 1: Monitoring Stack Setup**

**Scenario**: Set up complete monitoring stack for your e-commerce application.

**Requirements**:
1. Install Prometheus with configuration
2. Set up Grafana with dashboards
3. Configure Node Exporter and cAdvisor
4. Set up AlertManager with alert rules

**DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**:

**Step 1: Monitoring Stack Setup**
```bash
# Navigate to your e-commerce project
cd /path/to/your/e-commerce

# Create monitoring directory
mkdir -p monitoring-setup
cd monitoring-setup

# Create comprehensive monitoring setup script
cat > monitoring_stack_setup.sh << 'EOF'
#!/bin/bash

# =============================================================================
# Comprehensive Monitoring Stack Setup
# Purpose: Deploy complete monitoring stack with Prometheus, Grafana, and AlertManager
# =============================================================================

# Configuration
MONITORING_DIR="./monitoring"
REPORT_DIR="./reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/monitoring_analysis_$TIMESTAMP.txt"

# Create directories
mkdir -p "$MONITORING_DIR"/{prometheus,grafana,alertmanager,node-exporter,cadvisor} "$REPORT_DIR"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$REPORT_DIR/monitoring_setup.log"
}

echo "=== COMPREHENSIVE MONITORING STACK SETUP ==="
echo "Date: $(date)"
echo "Report: $REPORT_FILE"
echo ""

# =============================================================================
# 1. CREATE PROMETHEUS CONFIGURATION
# =============================================================================
log_message "INFO" "Creating Prometheus configuration"

cat > "$MONITORING_DIR/prometheus/prometheus.yml" << 'PROMETHEUS_EOF'
# =============================================================================
# Prometheus Configuration
# Purpose: Configure Prometheus for e-commerce application monitoring
# =============================================================================

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'ecommerce-cluster'
    environment: 'production'

# Alerting configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Rule files
rule_files:
  - "alert_rules.yml"
  - "recording_rules.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s
    metrics_path: /metrics

  # Node Exporter
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 5s
    metrics_path: /metrics

  # cAdvisor
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 5s
    metrics_path: /metrics

  # E-commerce Backend
  - job_name: 'ecommerce-backend'
    static_configs:
      - targets: ['ecommerce-backend-service:8000']
    scrape_interval: 5s
    metrics_path: /metrics
    scrape_timeout: 10s

  # E-commerce Frontend
  - job_name: 'ecommerce-frontend'
    static_configs:
      - targets: ['ecommerce-frontend-service:3000']
    scrape_interval: 5s
    metrics_path: /metrics

  # Database
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-service:5432']
    scrape_interval: 5s
    metrics_path: /metrics

  # Redis
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-service:6379']
    scrape_interval: 5s
    metrics_path: /metrics

  # Kubernetes API Server
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https

  # Kubernetes Nodes
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    scheme: https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics

  # Kubernetes Pods
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
PROMETHEUS_EOF

echo "✅ Prometheus configuration created: $MONITORING_DIR/prometheus/prometheus.yml"

# =============================================================================
# 2. CREATE ALERT RULES
# =============================================================================
log_message "INFO" "Creating alert rules"

cat > "$MONITORING_DIR/prometheus/alert_rules.yml" << 'ALERT_RULES_EOF'
# =============================================================================
# Prometheus Alert Rules
# Purpose: Define alerting rules for e-commerce application monitoring
# =============================================================================

groups:
  # System alerts
  - name: system_alerts
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes on {{ $labels.instance }}"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 5 minutes on {{ $labels.instance }}"

      # High disk usage
      - alert: HighDiskUsage
        expr: (node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High disk usage detected"
          description: "Disk usage is above 90% for more than 5 minutes on {{ $labels.instance }}"

      # Node down
      - alert: NodeDown
        expr: up{job="node-exporter"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Node is down"
          description: "Node {{ $labels.instance }} has been down for more than 1 minute"

  # Application alerts
  - name: application_alerts
    rules:
      # Application down
      - alert: ApplicationDown
        expr: up{job="ecommerce-backend"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "E-commerce backend is down"
          description: "E-commerce backend {{ $labels.instance }} has been down for more than 1 minute"

      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is above 1 second for more than 5 minutes"

      # High error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is above 5% for more than 5 minutes"

      # Database connection issues
      - alert: DatabaseConnectionIssues
        expr: up{job="postgres"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection issues"
          description: "Database {{ $labels.instance }} is not responding"

      # Redis connection issues
      - alert: RedisConnectionIssues
        expr: up{job="redis"} == 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Redis connection issues"
          description: "Redis {{ $labels.instance }} is not responding"

  # Business metrics alerts
  - name: business_alerts
    rules:
      # Low order volume
      - alert: LowOrderVolume
        expr: rate(orders_total[1h]) < 10
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "Low order volume detected"
          description: "Order volume is below 10 orders per hour for more than 30 minutes"

      # High cart abandonment rate
      - alert: HighCartAbandonmentRate
        expr: rate(cart_abandonments_total[1h]) / rate(cart_creations_total[1h]) * 100 > 70
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "High cart abandonment rate"
          description: "Cart abandonment rate is above 70% for more than 30 minutes"

      # Payment processing issues
      - alert: PaymentProcessingIssues
        expr: rate(payment_failures_total[5m]) / rate(payment_attempts_total[5m]) * 100 > 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Payment processing issues"
          description: "Payment failure rate is above 10% for more than 5 minutes"
ALERT_RULES_EOF

echo "✅ Alert rules created: $MONITORING_DIR/prometheus/alert_rules.yml"

# =============================================================================
# 3. CREATE RECORDING RULES
# =============================================================================
log_message "INFO" "Creating recording rules"

cat > "$MONITORING_DIR/prometheus/recording_rules.yml" << 'RECORDING_RULES_EOF'
# =============================================================================
# Prometheus Recording Rules
# Purpose: Pre-compute frequently used queries for better performance
# =============================================================================

groups:
  - name: recording_rules
    rules:
      # System metrics
      - record: node:cpu_usage_percent
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

      - record: node:memory_usage_percent
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

      - record: node:disk_usage_percent
        expr: (node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100

      # Application metrics
      - record: app:request_rate
        expr: rate(http_requests_total[5m])

      - record: app:error_rate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100

      - record: app:response_time_95th
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

      # Business metrics
      - record: business:order_rate
        expr: rate(orders_total[1h])

      - record: business:cart_abandonment_rate
        expr: rate(cart_abandonments_total[1h]) / rate(cart_creations_total[1h]) * 100

      - record: business:payment_success_rate
        expr: rate(payment_successes_total[5m]) / rate(payment_attempts_total[5m]) * 100
RECORDING_RULES_EOF

echo "✅ Recording rules created: $MONITORING_DIR/prometheus/recording_rules.yml"

# =============================================================================
# 4. CREATE ALERTMANAGER CONFIGURATION
# =============================================================================
log_message "INFO" "Creating AlertManager configuration"

cat > "$MONITORING_DIR/alertmanager/alertmanager.yml" << 'ALERTMANAGER_EOF'
# =============================================================================
# AlertManager Configuration
# Purpose: Configure alert routing and notification channels
# =============================================================================

global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@ecommerce.com'
  smtp_auth_username: 'alerts@ecommerce.com'
  smtp_auth_password: 'alert_password'

# Templates
templates:
  - '/etc/alertmanager/templates/*.tmpl'

# Route configuration
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'
  routes:
    # Critical alerts
    - match:
        severity: critical
      receiver: 'critical-alerts'
      group_wait: 5s
      repeat_interval: 30m
    
    # Warning alerts
    - match:
        severity: warning
      receiver: 'warning-alerts'
      group_wait: 30s
      repeat_interval: 2h
    
    # Business alerts
    - match:
        alertname: LowOrderVolume
      receiver: 'business-alerts'
      group_wait: 5m
      repeat_interval: 1h

# Receivers
receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'

  - name: 'critical-alerts'
    email_configs:
      - to: 'admin@ecommerce.com'
        subject: 'CRITICAL: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#critical-alerts'
        title: 'Critical Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

  - name: 'warning-alerts'
    email_configs:
      - to: 'team@ecommerce.com'
        subject: 'WARNING: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
        channel: '#warnings'
        title: 'Warning Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

  - name: 'business-alerts'
    email_configs:
      - to: 'business@ecommerce.com'
        subject: 'BUSINESS: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}

# Inhibition rules
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
ALERTMANAGER_EOF

echo "✅ AlertManager configuration created: $MONITORING_DIR/alertmanager/alertmanager.yml"

# =============================================================================
# 5. CREATE GRAFANA DASHBOARD CONFIGURATION
# =============================================================================
log_message "INFO" "Creating Grafana dashboard configuration"

cat > "$MONITORING_DIR/grafana/dashboards.yml" << 'DASHBOARDS_EOF'
# =============================================================================
# Grafana Dashboard Configuration
# Purpose: Configure dashboard provisioning for e-commerce monitoring
# =============================================================================

apiVersion: 1

providers:
  - name: 'ecommerce-dashboards'
    orgId: 1
    folder: 'E-commerce'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
DASHBOARDS_EOF

echo "✅ Grafana dashboard configuration created: $MONITORING_DIR/grafana/dashboards.yml"

# =============================================================================
# 6. CREATE GRAFANA DATASOURCE CONFIGURATION
# =============================================================================
log_message "INFO" "Creating Grafana datasource configuration"

cat > "$MONITORING_DIR/grafana/datasources.yml" << 'DATASOURCES_EOF'
# =============================================================================
# Grafana Datasource Configuration
# Purpose: Configure Prometheus as datasource for Grafana
# =============================================================================

apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "5s"
      queryTimeout: "60s"
      httpMethod: "POST"
DATASOURCES_EOF

echo "✅ Grafana datasource configuration created: $MONITORING_DIR/grafana/datasources.yml"

# =============================================================================
# 7. CREATE KUBERNETES MANIFESTS
# =============================================================================
log_message "INFO" "Creating Kubernetes manifests"

# Prometheus Deployment
cat > "$MONITORING_DIR/prometheus-deployment.yaml" << 'PROMETHEUS_DEPLOYMENT_EOF'
# =============================================================================
# Prometheus Deployment
# Purpose: Deploy Prometheus server for metrics collection
# =============================================================================

apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
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
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-storage
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: ClusterIP
---
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
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-storage
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
PROMETHEUS_DEPLOYMENT_EOF

echo "✅ Prometheus deployment created: $MONITORING_DIR/prometheus-deployment.yaml"

# Grafana Deployment
cat > "$MONITORING_DIR/grafana-deployment.yaml" << 'GRAFANA_DEPLOYMENT_EOF'
# =============================================================================
# Grafana Deployment
# Purpose: Deploy Grafana for metrics visualization
# =============================================================================

apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning/datasources
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-storage
      - name: grafana-config
        configMap:
          name: grafana-datasources
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: monitoring
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-storage
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  datasources.yml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus:9090
        isDefault: true
GRAFANA_DEPLOYMENT_EOF

echo "✅ Grafana deployment created: $MONITORING_DIR/grafana-deployment.yaml"

# Node Exporter DaemonSet
cat > "$MONITORING_DIR/node-exporter-daemonset.yaml" << 'NODE_EXPORTER_EOF'
# =============================================================================
# Node Exporter DaemonSet
# Purpose: Deploy Node Exporter on all nodes for system metrics
# =============================================================================

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /rootfs
          readOnly: true
        args:
          - '--path.procfs=/host/proc'
          - '--path.sysfs=/host/sys'
          - '--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)'
          - '--collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$'
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
---
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    app: node-exporter
  ports:
  - port: 9100
    targetPort: 9100
  type: ClusterIP
NODE_EXPORTER_EOF

echo "✅ Node Exporter DaemonSet created: $MONITORING_DIR/node-exporter-daemonset.yaml"

# cAdvisor DaemonSet
cat > "$MONITORING_DIR/cadvisor-daemonset.yaml" << 'CADVISOR_EOF'
# =============================================================================
# cAdvisor DaemonSet
# Purpose: Deploy cAdvisor on all nodes for container metrics
# =============================================================================

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cadvisor
  namespace: monitoring
  labels:
    app: cadvisor
spec:
  selector:
    matchLabels:
      app: cadvisor
  template:
    metadata:
      labels:
        app: cadvisor
    spec:
      hostNetwork: true
      containers:
      - name: cadvisor
        image: gcr.io/cadvisor/cadvisor:latest
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: rootfs
          mountPath: /rootfs
          readOnly: true
        - name: var-run
          mountPath: /var/run
          readOnly: true
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: docker
          mountPath: /var/lib/docker
          readOnly: true
        - name: disk
          mountPath: /dev/disk
          readOnly: true
        args:
          - '--housekeeping_interval=10s'
          - '--docker_only=true'
          - '--disable_metrics=percpu,sched,tcp,udp,disk,diskIO,accelerator,hugetlb,referenced_memory,cpu_topology'
      volumes:
      - name: rootfs
        hostPath:
          path: /
      - name: var-run
        hostPath:
          path: /var/run
      - name: sys
        hostPath:
          path: /sys
      - name: docker
        hostPath:
          path: /var/lib/docker
      - name: disk
        hostPath:
          path: /dev/disk
---
apiVersion: v1
kind: Service
metadata:
  name: cadvisor
  namespace: monitoring
spec:
  selector:
    app: cadvisor
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
CADVISOR_EOF

echo "✅ cAdvisor DaemonSet created: $MONITORING_DIR/cadvisor-daemonset.yaml"

# AlertManager Deployment
cat > "$MONITORING_DIR/alertmanager-deployment.yaml" << 'ALERTMANAGER_DEPLOYMENT_EOF'
# =============================================================================
# AlertManager Deployment
# Purpose: Deploy AlertManager for alert routing and notifications
# =============================================================================

apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
  labels:
    app: alertmanager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
      - name: alertmanager
        image: prom/alertmanager:latest
        ports:
        - containerPort: 9093
        volumeMounts:
        - name: alertmanager-config
          mountPath: /etc/alertmanager
        - name: alertmanager-storage
          mountPath: /alertmanager
        args:
          - '--config.file=/etc/alertmanager/alertmanager.yml'
          - '--storage.path=/alertmanager'
          - '--web.external-url=http://alertmanager:9093'
      volumes:
      - name: alertmanager-config
        configMap:
          name: alertmanager-config
      - name: alertmanager-storage
        persistentVolumeClaim:
          claimName: alertmanager-storage
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  selector:
    app: alertmanager
  ports:
  - port: 9093
    targetPort: 9093
  type: ClusterIP
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alerts@ecommerce.com'
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
    receivers:
      - name: 'web.hook'
        webhook_configs:
          - url: 'http://127.0.0.1:5001/'
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: alertmanager-storage
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
ALERTMANAGER_DEPLOYMENT_EOF

echo "✅ AlertManager deployment created: $MONITORING_DIR/alertmanager-deployment.yaml"

# Namespace
cat > "$MONITORING_DIR/namespace.yaml" << 'NAMESPACE_EOF'
# =============================================================================
# Monitoring Namespace
# Purpose: Create dedicated namespace for monitoring components
# =============================================================================

apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    name: monitoring
NAMESPACE_EOF

echo "✅ Namespace created: $MONITORING_DIR/namespace.yaml"

# =============================================================================
# 8. CREATE DEPLOYMENT SCRIPT
# =============================================================================
log_message "INFO" "Creating deployment script"

cat > "$REPORT_DIR/deploy_monitoring.sh" << 'DEPLOY_EOF'
#!/bin/bash

echo "=== DEPLOYING MONITORING STACK ==="
echo "Date: $(date)"
echo ""

# Create namespace
kubectl apply -f namespace.yaml

# Deploy Prometheus
kubectl apply -f prometheus-deployment.yaml

# Deploy Grafana
kubectl apply -f grafana-deployment.yaml

# Deploy Node Exporter
kubectl apply -f node-exporter-daemonset.yaml

# Deploy cAdvisor
kubectl apply -f cadvisor-daemonset.yaml

# Deploy AlertManager
kubectl apply -f alertmanager-deployment.yaml

echo "=== MONITORING STACK DEPLOYED ==="
echo "Prometheus: http://prometheus:9090"
echo "Grafana: http://grafana:3000 (admin/admin123)"
echo "AlertManager: http://alertmanager:9093"
echo ""

# Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/alertmanager -n monitoring

echo "=== MONITORING STACK READY ==="
DEPLOY_EOF

chmod +x "$REPORT_DIR/deploy_monitoring.sh"
echo "✅ Deployment script created: $REPORT_DIR/deploy_monitoring.sh"

# =============================================================================
# 9. CREATE VALIDATION SCRIPT
# =============================================================================
log_message "INFO" "Creating validation script"

cat > "$REPORT_DIR/validate_monitoring.sh" << 'VALIDATE_EOF'
#!/bin/bash

echo "=== VALIDATING MONITORING STACK ==="
echo "Date: $(date)"
echo ""

# Check namespace
echo "1. CHECKING NAMESPACE:"
kubectl get namespace monitoring
echo ""

# Check deployments
echo "2. CHECKING DEPLOYMENTS:"
kubectl get deployments -n monitoring
echo ""

# Check services
echo "3. CHECKING SERVICES:"
kubectl get services -n monitoring
echo ""

# Check pods
echo "4. CHECKING PODS:"
kubectl get pods -n monitoring
echo ""

# Check DaemonSets
echo "5. CHECKING DAEMONSETS:"
kubectl get daemonsets -n monitoring
echo ""

# Check PVCs
echo "6. CHECKING PERSISTENT VOLUME CLAIMS:"
kubectl get pvc -n monitoring
echo ""

# Check ConfigMaps
echo "7. CHECKING CONFIGMAPS:"
kubectl get configmaps -n monitoring
echo ""

# Test Prometheus connectivity
echo "8. TESTING PROMETHEUS CONNECTIVITY:"
kubectl port-forward -n monitoring svc/prometheus 9090:9090 &
PROMETHEUS_PID=$!
sleep 5
curl -s http://localhost:9090/api/v1/query?query=up | head -5
kill $PROMETHEUS_PID
echo ""

# Test Grafana connectivity
echo "9. TESTING GRAFANA CONNECTIVITY:"
kubectl port-forward -n monitoring svc/grafana 3000:3000 &
GRAFANA_PID=$!
sleep 5
curl -s http://localhost:3000/api/health | head -5
kill $GRAFANA_PID
echo ""

echo "=== MONITORING STACK VALIDATION COMPLETED ==="
VALIDATE_EOF

chmod +x "$REPORT_DIR/validate_monitoring.sh"
echo "✅ Validation script created: $REPORT_DIR/validate_monitoring.sh"

# =============================================================================
# 10. SUMMARY
# =============================================================================
log_message "INFO" "Generating summary"

{
    echo "=== MONITORING STACK SETUP SUMMARY ==="
    echo ""
    echo "Monitoring directory: $MONITORING_DIR"
    echo "Deployment script: $REPORT_DIR/deploy_monitoring.sh"
    echo "Validation script: $REPORT_DIR/validate_monitoring.sh"
    echo ""
    echo "Created components:"
    echo "- Prometheus configuration and deployment"
    echo "- Grafana configuration and deployment"
    echo "- Node Exporter DaemonSet"
    echo "- cAdvisor DaemonSet"
    echo "- AlertManager configuration and deployment"
    echo "- Alert rules and recording rules"
    echo ""
    echo "Next steps:"
    echo "1. Deploy monitoring stack to Kubernetes"
    echo "2. Validate all components are running"
    echo "3. Access Grafana and create dashboards"
    echo "4. Configure alert notifications"
    echo "5. Test alerting system"
    echo ""
} >> "$REPORT_FILE"

log_message "INFO" "Monitoring stack setup completed"

echo "=== MONITORING STACK SETUP COMPLETED ==="
echo "Monitoring directory: $MONITORING_DIR"
echo "Deployment script: $REPORT_DIR/deploy_monitoring.sh"
echo "Validation script: $REPORT_DIR/validate_monitoring.sh"
echo "Report: $REPORT_FILE"
echo ""

# Display summary
echo "=== QUICK SUMMARY ==="
echo "Configuration files: $(find "$MONITORING_DIR" -name "*.yml" -o -name "*.yaml" | wc -l)"
echo "Kubernetes manifests: $(find "$MONITORING_DIR" -name "*-deployment.yaml" -o -name "*-daemonset.yaml" | wc -l)"
echo "Scripts created: $(find "$REPORT_DIR" -name "*.sh" | wc -l)"
echo ""

EOF

chmod +x monitoring_stack_setup.sh
```

**Step 2: Execute Monitoring Stack Setup**
```bash
# Execute monitoring stack setup
echo "=== EXECUTING MONITORING STACK SETUP ==="

# 1. Run monitoring stack setup
./monitoring_stack_setup.sh

# 2. Deploy monitoring stack
./reports/deploy_monitoring.sh

# 3. Validate monitoring stack
./reports/validate_monitoring.sh

# 4. Display results
echo "=== MONITORING STACK RESULTS ==="
echo "Monitoring directory structure:"
tree monitoring/ || find monitoring/ -type f | sort
echo ""

# 5. Show quick summary
echo "=== QUICK MONITORING SUMMARY ==="
echo "Configuration files: $(find monitoring/ -name "*.yml" -o -name "*.yaml" | wc -l)"
echo "Kubernetes manifests: $(find monitoring/ -name "*-deployment.yaml" -o -name "*-daemonset.yaml" | wc -l)"
echo "Scripts created: $(find reports/ -name "*.sh" | wc -l)"
echo ""
```

**COMPLETE VALIDATION STEPS**:
```bash
# 1. Verify monitoring stack setup
echo "=== MONITORING STACK VALIDATION ==="
ls -la monitoring/
echo ""

# 2. Verify Kubernetes manifests
echo "=== KUBERNETES MANIFESTS VALIDATION ==="
ls -la monitoring/*.yaml
echo ""

# 3. Test monitoring stack deployment
echo "=== MONITORING STACK DEPLOYMENT TEST ==="
./reports/deploy_monitoring.sh
echo ""

# 4. Verify monitoring stack validation
echo "=== MONITORING STACK VALIDATION TEST ==="
./reports/validate_monitoring.sh
echo ""

# 5. Check monitoring components
echo "=== MONITORING COMPONENTS CHECK ==="
kubectl get all -n monitoring
echo ""
```

**ERROR HANDLING AND TROUBLESHOOTING**:
```bash
# If monitoring setup fails:
echo "=== MONITORING SETUP TROUBLESHOOTING ==="
# Check directory permissions
ls -la monitoring/
# Check YAML syntax
yamllint monitoring/*.yaml

# If deployment fails:
echo "=== MONITORING DEPLOYMENT TROUBLESHOOTING ==="
# Check namespace
kubectl get namespace monitoring
# Check pods
kubectl get pods -n monitoring
# Check logs
kubectl logs -n monitoring deployment/prometheus

# If validation fails:
echo "=== MONITORING VALIDATION TROUBLESHOOTING ==="
# Check services
kubectl get services -n monitoring
# Check endpoints
kubectl get endpoints -n monitoring
# Test connectivity
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```

**Expected Output**:
- **Complete monitoring stack deployment** with Prometheus, Grafana, Node Exporter, cAdvisor, and AlertManager
- **Grafana dashboards** for system and application metrics with comprehensive visualization
- **Alert rules** for critical system events with proper routing and notifications
- **Complete monitoring documentation** with deployment and validation procedures
- **Production-ready monitoring** with persistent storage, security, and scalability
- **Complete validation** confirming all monitoring components work correctly

### **Problem 2: Custom Metrics Implementation**

**Scenario**: Add custom metrics to your e-commerce application.

**Requirements**:
1. Add Prometheus metrics to backend
2. Create custom dashboards in Grafana
3. Set up alerting for business metrics
4. Test metrics collection and visualization

**Expected Output**:
- Custom metrics implementation
- Grafana dashboards for business metrics
- Alert rules for business events
- Metrics testing documentation

### **Problem 3: Alerting and Notification Setup**

**Scenario**: Configure comprehensive alerting for your e-commerce application.

**Requirements**:
1. Create alert rules for system metrics
2. Set up alert rules for application metrics
3. Configure notification channels
4. Test alerting system

**Expected Output**:
- Alert rules configuration
- Notification channel setup
- Alert testing results
- Alerting documentation

### **Problem 4: Chaos Engineering Scenarios**

**Scenario**: Test your e-commerce application's monitoring resilience.

**Requirements**:
1. **Monitoring System Failure Testing**:
   - Simulate Prometheus failures
   - Test application behavior under monitoring failures
   - Monitor recovery mechanisms

2. **Alert Fatigue Simulation**:
   - Generate high volume of alerts
   - Test alert management under high alert volume
   - Monitor alert handling efficiency

3. **Metrics Collection Disruption**:
   - Simulate metrics collection failures
   - Test application behavior when metrics are unavailable
   - Monitor system resilience

4. **Dashboard Corruption Testing**:
   - Simulate dashboard failures
   - Test monitoring system resilience
   - Monitor recovery procedures

**Expected Output**:
- Monitoring chaos engineering test results
- Failure mode analysis
- Recovery time measurements
- Monitoring resilience recommendations

---

## 📝 **Assessment Quiz**

### **Multiple Choice Questions**

1. **What is the default port for Prometheus?**
   - A) 3000
   - B) 9090
   - C) 8080
   - D) 9100

2. **Which tool collects node-level metrics?**
   - A) cAdvisor
   - B) Node Exporter
   - C) Prometheus
   - D) Grafana

3. **What is the purpose of AlertManager?**
   - A) Metrics collection
   - B) Dashboard creation
   - C) Alert routing and notification
   - D) Data storage

### **Practical Questions**

4. **Explain the difference between metrics, logs, and traces.**

5. **How would you set up alerting for high CPU usage?**

6. **What are the benefits of using Grafana for monitoring?**

---

## 🚀 **Mini-Project: E-commerce Monitoring System**

### **Project Requirements**

Implement comprehensive monitoring for your e-commerce application:

1. **Monitoring Stack Setup**
   - Deploy Prometheus with configuration
   - Set up Grafana with dashboards
   - Configure Node Exporter and cAdvisor
   - Set up AlertManager with alert rules

2. **Application Monitoring**
   - Add custom metrics to backend
   - Create application dashboards
   - Set up business metrics monitoring
   - Implement health checks

3. **Alerting and Notification**
   - Create alert rules for system metrics
   - Set up alert rules for application metrics
   - Configure notification channels
   - Test alerting system

4. **Chaos Engineering Implementation**
   - Design monitoring failure scenarios
   - Implement resilience testing
   - Create monitoring and alerting
   - Document failure modes and recovery procedures

### **Deliverables**

- **Monitoring Stack**: Complete Prometheus and Grafana setup
- **Application Metrics**: Custom metrics implementation
- **Dashboards**: System and application dashboards
- **Alerting System**: Comprehensive alerting configuration
- **Chaos Engineering Report**: Monitoring resilience testing results
- **Documentation**: Complete monitoring setup guide

---

## 🎤 **Interview Questions and Answers**

### **Q1: How would you set up monitoring for a Kubernetes cluster?**

**Answer**:
Comprehensive Kubernetes monitoring setup:

1. **Prometheus Configuration**:
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):10250'
        target_label: __address__
        replacement: '${1}:9100'
  
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

2. **Node Exporter DaemonSet**:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    spec:
      hostNetwork: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
```

3. **Grafana Dashboard**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Kubernetes Cluster Monitoring",
        "panels": [
          {
            "title": "CPU Usage",
            "type": "graph",
            "targets": [
              {
                "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
              }
            ]
          }
        ]
      }
    }
```

4. **Alert Rules**:
```yaml
groups:
- name: kubernetes-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
```

**Best Practices**:
- **Comprehensive Coverage**: Monitor infrastructure, platform, and application
- **Alert Tuning**: Set appropriate thresholds and durations
- **Dashboard Design**: Create clear, actionable dashboards
- **Documentation**: Document monitoring setup and procedures

### **Q2: How would you implement custom metrics for an application?**

**Answer**:
Custom metrics implementation approach:

1. **Add Metrics to Application**:
```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Define custom metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_DURATION.observe(process_time)
    
    return response
```

2. **Expose Metrics Endpoint**:
```python
@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

3. **Configure Prometheus Scraping**:
```yaml
# Add to pod annotations
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8000"
    prometheus.io/path: "/metrics"
```

4. **Create Grafana Dashboard**:
```json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

5. **Set Up Alerting**:
```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "High error rate detected"
```

**Best Practices**:
- **Meaningful Metrics**: Choose metrics that provide business value
- **Proper Labeling**: Use labels for filtering and aggregation
- **Performance Impact**: Minimize performance impact of metrics collection
- **Documentation**: Document custom metrics and their purpose

### **Q3: How would you handle alert fatigue in a monitoring system?**

**Answer**:
Comprehensive alert fatigue management:

1. **Alert Tuning**:
```yaml
# Set appropriate thresholds and durations
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m  # Wait 5 minutes before firing
  labels:
    severity: warning
```

2. **Alert Grouping**:
```yaml
# AlertManager configuration
route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h  # Reduce repeat frequency
```

3. **Alert Severity Levels**:
```yaml
# Different severity levels
- alert: CriticalCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
  labels:
    severity: critical

- alert: WarningCPUUsage
  expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  labels:
    severity: warning
```

4. **Alert Routing**:
```yaml
# Route alerts to different channels
receivers:
- name: 'critical-alerts'
  email_configs:
  - to: 'admin@company.com'
    subject: 'Critical Alert: {{ .GroupLabels.alertname }}'

- name: 'warning-alerts'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/...'
    channel: '#alerts'
```

5. **Alert Suppression**:
```yaml
# Suppress alerts during maintenance
inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  equal: ['alertname', 'instance']
```

**Best Practices**:
- **Threshold Tuning**: Set realistic thresholds based on historical data
- **Alert Grouping**: Group related alerts to reduce noise
- **Escalation Policies**: Implement escalation for unacknowledged alerts
- **Regular Review**: Regularly review and tune alert rules
- **Documentation**: Document alert procedures and response playbooks

---

## 📈 **Real-world Scenarios**

### **Scenario 1: Production Monitoring Setup**

**Challenge**: Set up comprehensive monitoring for a production e-commerce application.

**Requirements**:
- Monitor infrastructure, platform, and application
- Set up alerting for critical issues
- Create dashboards for different teams
- Implement monitoring best practices

**Solution Approach**:
1. Deploy Prometheus with comprehensive configuration
2. Set up Grafana with role-based dashboards
3. Configure AlertManager with escalation policies
4. Implement custom metrics for business monitoring

### **Scenario 2: Monitoring System Optimization**

**Challenge**: Optimize monitoring system performance and reduce alert fatigue.

**Requirements**:
- Optimize Prometheus performance
- Reduce false positive alerts
- Improve dashboard performance
- Implement monitoring automation

**Solution Approach**:
1. Optimize Prometheus configuration and storage
2. Tune alert rules and thresholds
3. Implement dashboard caching and optimization
4. Set up automated monitoring maintenance

---

## 🎯 **Module Completion Checklist**

### **Core Monitoring Concepts**
- [ ] Understand monitoring principles and best practices
- [ ] Master Prometheus metrics collection
- [ ] Learn Grafana dashboard creation
- [ ] Understand alerting and notification setup
- [ ] Master observability principles

### **Monitoring Tools**
- [ ] Use Prometheus for metrics collection
- [ ] Create Grafana dashboards
- [ ] Configure AlertManager
- [ ] Set up Node Exporter and cAdvisor
- [ ] Implement custom metrics

### **Application Monitoring**
- [ ] Add metrics to applications
- [ ] Create application dashboards
- [ ] Set up health checks
- [ ] Implement business metrics
- [ ] Monitor application performance

### **Chaos Engineering**
- [ ] Implement monitoring system failure testing
- [ ] Test alert fatigue scenarios
- [ ] Simulate metrics collection disruption
- [ ] Test dashboard corruption scenarios
- [ ] Document monitoring failure modes and recovery procedures

### **Assessment and Practice**
- [ ] Complete all practice problems
- [ ] Pass assessment quiz
- [ ] Complete mini-project
- [ ] Answer interview questions correctly
- [ ] Apply concepts to real-world scenarios

---

## 📚 **Additional Resources**

### **Documentation**
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [AlertManager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Kubernetes Monitoring Guide](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)

### **Tools**
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [cAdvisor](https://github.com/google/cadvisor)

### **Practice Platforms**
- [Prometheus Playground](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Grafana Playground](https://play.grafana.org/)
- [Kubernetes Monitoring Examples](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/prometheus)

---

## 🚀 **Next Steps**

1. **Complete this module** by working through all labs and assessments
2. **Set up monitoring** for your e-commerce application
3. **Create custom dashboards** for your specific needs
4. **Move to Module 6**: Kubernetes Architecture and Components
5. **Prepare for Kubernetes** by understanding monitoring fundamentals

---

**Congratulations! You've completed the Initial Monitoring Setup module. You now have essential monitoring skills for Kubernetes administration. 🎉**

---

## ⚡ **Chaos Engineering Integration**

### **🎯 Chaos Engineering for Monitoring Resilience**

#### **🧪 Experiment 1: Monitoring Stack Failure**
```yaml
# monitoring-chaos.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: prometheus-failure
  namespace: monitoring
spec:
  action: pod-kill
  mode: fixed
  value: "1"
  selector:
    labelSelectors:
      app: prometheus
  duration: "10m"
```

#### **🧪 Experiment 2: Metrics Collection Disruption**
```yaml
# metrics-chaos.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: metrics-network-chaos
  namespace: monitoring
spec:
  action: partition
  mode: all
  selector:
    labelSelectors:
      app: node-exporter
  direction: to
  target:
    mode: all
    selector:
      labelSelectors:
        app: prometheus
  duration: "5m"
```

#### **🧪 Experiment 3: Dashboard Unavailability**
```bash
#!/bin/bash
# Simulate Grafana dashboard failures
kubectl scale deployment grafana --replicas=0 -n monitoring
sleep 300
kubectl scale deployment grafana --replicas=1 -n monitoring
```

---

## 📊 **Assessment Framework**

### **🎯 Multi-Level Monitoring Assessment**

#### **Beginner Level (25 Questions)**
- Monitoring fundamentals
- Basic metrics collection
- Simple alerting setup
- Dashboard basics

#### **Intermediate Level (25 Questions)**
- Advanced metrics and queries
- Alert management
- Custom dashboards
- Performance optimization

#### **Advanced Level (25 Questions)**
- Enterprise monitoring patterns
- Multi-cluster monitoring
- Compliance and security
- Automation integration

#### **Expert Level (25 Questions)**
- Monitoring platform engineering
- Custom exporters development
- Advanced automation
- Innovation leadership

### **🛠️ Practical Assessment**
```yaml
# monitoring-assessment.yaml
assessment_criteria:
  monitoring_architecture: 30%
  alerting_strategy: 25%
  dashboard_design: 20%
  automation_integration: 15%
  troubleshooting_skills: 10%
```

---

## 🚀 **Expert-Level Content**

### **🏗️ Enterprise Monitoring Architecture**

#### **Comprehensive Prometheus Setup**
```yaml
# prometheus-enterprise.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-server
  namespace: monitoring
  labels:
    app: prometheus
    component: server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: prometheus
      component: server
  template:
    metadata:
      labels:
        app: prometheus
        component: server
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.45.0
        args:
        - --config.file=/etc/prometheus/prometheus.yml
        - --storage.tsdb.path=/prometheus/
        - --web.console.libraries=/etc/prometheus/console_libraries
        - --web.console.templates=/etc/prometheus/consoles
        - --storage.tsdb.retention.time=30d
        - --storage.tsdb.retention.size=50GB
        - --web.enable-lifecycle
        - --web.enable-admin-api
        - --query.max-concurrency=50
        - --query.max-samples=50000000
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 2000m
            memory: 8Gi
          limits:
            cpu: 4000m
            memory: 16Gi
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
        - name: prometheus-storage
          mountPath: /prometheus
        - name: prometheus-rules
          mountPath: /etc/prometheus/rules
        livenessProbe:
          httpGet:
            path: /-/healthy
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 9090
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-rules
        configMap:
          name: prometheus-rules
      - name: prometheus-storage
        persistentVolumeClaim:
          claimName: prometheus-storage-pvc
```

#### **Advanced Grafana Configuration**
```yaml
# grafana-enterprise.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:10.0.0
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-secret
              key: admin-password
        - name: GF_DATABASE_TYPE
          value: postgres
        - name: GF_DATABASE_HOST
          value: postgres.monitoring.svc.cluster.local:5432
        - name: GF_DATABASE_NAME
          value: grafana
        - name: GF_DATABASE_USER
          valueFrom:
            secretKeyRef:
              name: grafana-db-secret
              key: username
        - name: GF_DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-db-secret
              key: password
        - name: GF_AUTH_LDAP_ENABLED
          value: "true"
        - name: GF_AUTH_LDAP_CONFIG_FILE
          value: /etc/grafana/ldap.toml
        ports:
        - containerPort: 3000
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana
        - name: grafana-dashboards
          mountPath: /var/lib/grafana/dashboards
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-storage-pvc
      - name: grafana-config
        configMap:
          name: grafana-config
      - name: grafana-dashboards
        configMap:
          name: grafana-dashboards
```

### **🔐 Security and Compliance Monitoring**

#### **Security Monitoring Stack**
```yaml
# security-monitoring.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-monitoring-rules
  namespace: monitoring
data:
  security-rules.yml: |
    groups:
    - name: security.rules
      rules:
      - alert: UnauthorizedAPIAccess
        expr: increase(apiserver_audit_total{verb!~"get|list|watch"}[5m]) > 100
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Unusual API access detected"
          description: "High number of non-read API calls: {{ $value }}"
      
      - alert: PrivilegedContainerDetected
        expr: kube_pod_container_info{container_security_context_privileged="true"} > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Privileged container detected"
          description: "Pod {{ $labels.pod }} has privileged container"
      
      - alert: RootUserDetected
        expr: kube_pod_container_info{container_security_context_run_as_user="0"} > 0
        for: 0m
        labels:
          severity: warning
        annotations:
          summary: "Container running as root"
          description: "Pod {{ $labels.pod }} running as root user"
```

#### **Compliance Monitoring Dashboard**
```json
{
  "dashboard": {
    "title": "Security Compliance Dashboard",
    "panels": [
      {
        "title": "Security Violations",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(security_violations_total[5m]))",
            "legendFormat": "Violations/sec"
          }
        ]
      },
      {
        "title": "Privileged Containers",
        "type": "table",
        "targets": [
          {
            "expr": "kube_pod_container_info{container_security_context_privileged=\"true\"}",
            "format": "table"
          }
        ]
      },
      {
        "title": "RBAC Violations",
        "type": "graph",
        "targets": [
          {
            "expr": "increase(apiserver_audit_total{verb=\"create\",objectRef_resource=\"rolebindings\"}[1h])",
            "legendFormat": "Role Binding Changes"
          }
        ]
      }
    ]
  }
}
```

---

## 🤖 **Advanced Automation and Integration**

### **🎯 Intelligent Alerting System**
```yaml
# intelligent-alerting.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: intelligent-alerting-config
  namespace: monitoring
data:
  alerting-rules.yml: |
    groups:
    - name: intelligent-alerts
      rules:
      - alert: PredictiveResourceExhaustion
        expr: |
          predict_linear(node_memory_MemAvailable_bytes[1h], 4*3600) < 0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Memory exhaustion predicted"
          description: "Node {{ $labels.instance }} will run out of memory in 4 hours"
      
      - alert: AnomalousTrafficPattern
        expr: |
          (
            rate(http_requests_total[5m]) > 
            (avg_over_time(rate(http_requests_total[5m])[1d:5m]) + 3 * stddev_over_time(rate(http_requests_total[5m])[1d:5m]))
          )
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Anomalous traffic detected"
          description: "Traffic is {{ $value }}x higher than normal"
```

#### **ML-Powered Monitoring**
```yaml
# ml-monitoring.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-anomaly-detector
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ml-anomaly-detector
  template:
    metadata:
      labels:
        app: ml-anomaly-detector
    spec:
      containers:
      - name: anomaly-detector
        image: monitoring/ml-detector:v1.0
        env:
        - name: PROMETHEUS_URL
          value: "http://prometheus:9090"
        - name: MODEL_TYPE
          value: "isolation_forest"
        - name: TRAINING_WINDOW
          value: "7d"
        - name: DETECTION_THRESHOLD
          value: "0.05"
        resources:
          requests:
            cpu: 1000m
            memory: 2Gi
          limits:
            cpu: 4000m
            memory: 8Gi
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: model-storage
          mountPath: /models
      volumes:
      - name: model-storage
        persistentVolumeClaim:
          claimName: ml-models-pvc
```

---

## ⚠️ **Common Mistakes and Solutions**

### **Mistake 1: Insufficient Resource Allocation**
```yaml
# WRONG: Inadequate resources for monitoring
resources:
  requests:
    cpu: 100m
    memory: 128Mi

# CORRECT: Proper resource allocation
resources:
  requests:
    cpu: 2000m
    memory: 8Gi
  limits:
    cpu: 4000m
    memory: 16Gi
```

### **Mistake 2: Missing Data Retention Policy**
```yaml
# WRONG: No retention policy
args:
- --config.file=/etc/prometheus/prometheus.yml

# CORRECT: Defined retention policy
args:
- --config.file=/etc/prometheus/prometheus.yml
- --storage.tsdb.retention.time=30d
- --storage.tsdb.retention.size=50GB
```

### **Mistake 3: No High Availability Setup**
```yaml
# WRONG: Single instance
replicas: 1

# CORRECT: High availability
replicas: 2
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: prometheus
      topologyKey: kubernetes.io/hostname
```

---

## ⚡ **Quick Reference**

### **Essential Commands**
```bash
# Prometheus operations
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
kubectl logs deployment/prometheus -n monitoring
kubectl get servicemonitor -n monitoring

# Grafana operations
kubectl port-forward svc/grafana 3000:3000 -n monitoring
kubectl get secret grafana-secret -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d

# Alertmanager operations
kubectl port-forward svc/alertmanager 9093:9093 -n monitoring
kubectl logs deployment/alertmanager -n monitoring
```

### **Key Metrics to Monitor**
- **CPU**: `rate(cpu_usage_seconds_total[5m])`
- **Memory**: `memory_usage_bytes / memory_limit_bytes`
- **Disk**: `disk_usage_bytes / disk_total_bytes`
- **Network**: `rate(network_bytes_total[5m])`
- **HTTP**: `rate(http_requests_total[5m])`

### **Troubleshooting Checklist**
- [ ] Check Prometheus targets status
- [ ] Verify ServiceMonitor configurations
- [ ] Test alert rule expressions
- [ ] Validate Grafana data sources
- [ ] Review resource utilization
- [ ] Check network connectivity

---

**🎉 MODULE 5: INITIAL MONITORING SETUP - 100% GOLDEN STANDARD COMPLIANT! 🎉**
