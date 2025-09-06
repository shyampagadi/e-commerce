# 🚀 **Project Execution Guide**
## *E-commerce Foundation Infrastructure Project*

**Document Version**: 1.0  
**Date**: $(date)  
**Project**: E-commerce Foundation Infrastructure  
**Execution Time**: 4 weeks (20 working days)  
**Prerequisites**: Modules 0-5 completion  

---

## 🎯 **Execution Guide Overview**

This comprehensive guide provides a step-by-step execution path for the E-commerce Foundation Infrastructure Project. It consolidates all project activities into a clear, sequential workflow that students can follow from start to finish.

### **Guide Structure**
- **Phase 1**: Foundation Setup (Week 1)
- **Phase 2**: Application Deployment (Week 2)  
- **Phase 3**: Monitoring & Security (Week 3)
- **Phase 4**: Documentation & Validation (Week 4)

### **How to Use This Guide**
1. **Follow steps sequentially** - Each step builds on the previous
2. **Complete verification** - Verify each step before proceeding
3. **Document progress** - Track completion and issues
4. **Reference detailed docs** - Use specific files for detailed information

---

## 📋 **Pre-Execution Checklist**

### **Prerequisites Verification**
- [ ] **Linux System**: Ubuntu 20.04+ with 4 CPU, 8GB RAM minimum
- [ ] **Docker**: Installed and running (version 20.10+)
- [ ] **Kubernetes**: kubectl installed and configured
- [ ] **Network**: Internet access for package downloads
- [ ] **Storage**: 100GB+ free disk space
- [ ] **Access**: Root/sudo access for system configuration

### **Required Knowledge**
- [ ] **Linux Fundamentals**: File system, processes, networking
- [ ] **Container Concepts**: Docker, images, containers
- [ ] **Kubernetes Basics**: Pods, Deployments, Services
- [ ] **YAML Syntax**: Configuration file structure
- [ ] **Monitoring Concepts**: Metrics, dashboards, alerting

---

## 🏗️ **PHASE 1: FOUNDATION SETUP (Week 1)**

### **Day 1: System Preparation**

#### **Step 1.1: System Configuration**
**Objective**: Prepare the Linux system for Kubernetes installation

**Detailed Steps**:
1. **Update system packages**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   - **Purpose**: Ensure system is up-to-date and secure
   - **Expected Output**: Package list updated, upgrades installed
   - **Verification**: `lsb_release -a` shows Ubuntu 20.04+

2. **Disable swap memory**
   ```bash
   sudo swapoff -a
   sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
   ```
   - **Purpose**: Kubernetes requires swap to be disabled
   - **Expected Output**: No swap devices listed in `free -h`
   - **Verification**: `free -h` shows 0 swap usage

3. **Configure kernel modules**
   ```bash
   cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
   br_netfilter
   EOF
   
   cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   net.ipv4.ip_forward = 1
   EOF
   
   sudo sysctl --system
   ```
   - **Purpose**: Enable required kernel modules for networking
   - **Expected Output**: Modules loaded, sysctl settings applied
   - **Verification**: `lsmod | grep br_netfilter` shows module loaded

**Reference Document**: `docs/04-deployment-guide.md` (Section 2.1)

#### **Step 1.2: Docker Installation**
**Objective**: Install and configure Docker container runtime

**Detailed Steps**:
1. **Install Docker dependencies**
   ```bash
   sudo apt-get update
   sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
   ```
   - **Purpose**: Install packages required for Docker installation
   - **Expected Output**: Dependencies installed successfully
   - **Verification**: All packages available

2. **Add Docker GPG key**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```
   - **Purpose**: Add Docker's official GPG key for package verification
   - **Expected Output**: GPG key added successfully
   - **Verification**: Key file exists in `/usr/share/keyrings/`

3. **Add Docker repository**
   ```bash
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
   - **Purpose**: Add Docker's official repository
   - **Expected Output**: Repository added to sources list
   - **Verification**: Repository listed in `/etc/apt/sources.list.d/docker.list`

4. **Install Docker Engine**
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io
   ```
   - **Purpose**: Install Docker container runtime
   - **Expected Output**: Docker installed successfully
   - **Verification**: `docker --version` shows Docker 20.10+

5. **Configure Docker for Kubernetes**
   ```bash
   sudo mkdir -p /etc/docker
   cat <<EOF | sudo tee /etc/docker/daemon.json
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "overlay2"
   }
   EOF
   
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   sudo systemctl enable docker
   ```
   - **Purpose**: Configure Docker with systemd cgroup driver
   - **Expected Output**: Docker configured and running
   - **Verification**: `docker info` shows systemd cgroup driver

**Reference Document**: `docs/04-deployment-guide.md` (Section 2.2)

### **Day 2: Kubernetes Cluster Setup**

#### **Step 2.1: Install Kubernetes Components**
**Objective**: Install kubeadm, kubelet, and kubectl

**Detailed Steps**:
1. **Add Kubernetes repository**
   ```bash
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   ```
   - **Purpose**: Add Kubernetes package repository
   - **Expected Output**: Repository added successfully
   - **Verification**: Repository listed in sources

2. **Install Kubernetes components**
   ```bash
   sudo apt-get update
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   ```
   - **Purpose**: Install Kubernetes command-line tools
   - **Expected Output**: kubelet, kubeadm, kubectl installed
   - **Verification**: `kubectl version --client` shows version info

**Reference Document**: `scripts/setup-cluster.sh`

#### **Step 2.2: Initialize Kubernetes Cluster**
**Objective**: Create a 2-node Kubernetes cluster

**Detailed Steps**:
1. **Initialize master node**
   ```bash
   sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.100
   ```
   - **Purpose**: Initialize the Kubernetes control plane
   - **Expected Output**: Cluster initialized, join command provided
   - **Verification**: `kubectl get nodes` shows master node

2. **Configure kubectl for non-root user**
   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```
   - **Purpose**: Allow non-root user to use kubectl
   - **Expected Output**: kubectl configuration copied
   - **Verification**: `kubectl get nodes` works without sudo

3. **Install CNI plugin (Flannel)**
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```
   - **Purpose**: Enable pod-to-pod communication
   - **Expected Output**: Flannel pods running
   - **Verification**: `kubectl get pods -n kube-system` shows flannel pods

4. **Remove master node taint**
   ```bash
   kubectl taint nodes --all node-role.kubernetes.io/control-plane-
   ```
   - **Purpose**: Allow pods to run on master node
   - **Expected Output**: Taint removed successfully
   - **Verification**: `kubectl describe node` shows no taints

**Reference Document**: `scripts/setup-cluster.sh`

### **Day 3: Namespace and Resource Setup**

#### **Step 3.1: Create E-commerce Namespace**
**Objective**: Create dedicated namespace for e-commerce application

**Detailed Steps**:
1. **Apply namespace manifest**
   ```bash
   kubectl apply -f k8s-manifests/namespace.yaml
   ```
   - **Purpose**: Create ecommerce namespace with resource quotas
   - **Expected Output**: Namespace created successfully
   - **Verification**: `kubectl get namespace ecommerce` shows namespace

2. **Verify namespace configuration**
   ```bash
   kubectl describe namespace ecommerce
   kubectl get resourcequota -n ecommerce
   ```
   - **Purpose**: Confirm namespace and resource quotas are configured
   - **Expected Output**: Namespace details and resource quotas displayed
   - **Verification**: Resource quotas are active

**Reference Document**: `k8s-manifests/namespace.yaml`

#### **Step 3.2: Create Monitoring Namespace**
**Objective**: Create dedicated namespace for monitoring components

**Detailed Steps**:
1. **Create monitoring namespace**
   ```bash
   kubectl create namespace monitoring
   kubectl label namespace monitoring name=monitoring
   ```
   - **Purpose**: Isolate monitoring components
   - **Expected Output**: Monitoring namespace created
   - **Verification**: `kubectl get namespace monitoring` shows namespace

**Reference Document**: `docs/03-technical-design.md`

### **Day 4: Database Deployment**

#### **Step 4.1: Deploy PostgreSQL Database**
**Objective**: Deploy the e-commerce database with persistent storage

**Detailed Steps**:
1. **Apply database deployment**
   ```bash
   kubectl apply -f k8s-manifests/database-deployment.yaml
   ```
   - **Purpose**: Deploy PostgreSQL database for e-commerce application
   - **Expected Output**: Database deployment created
   - **Verification**: `kubectl get deployment -n ecommerce` shows database deployment

2. **Apply database service**
   ```bash
   kubectl apply -f k8s-manifests/database-service.yaml
   ```
   - **Purpose**: Expose database internally within cluster
   - **Expected Output**: Database service created
   - **Verification**: `kubectl get service -n ecommerce` shows database service

3. **Verify database deployment**
   ```bash
   kubectl get pods -n ecommerce -l app=ecommerce-database
   kubectl logs -n ecommerce deployment/ecommerce-database
   ```
   - **Purpose**: Confirm database is running and healthy
   - **Expected Output**: Database pod running, logs show successful startup
   - **Verification**: Pod status is Running, logs show PostgreSQL ready

**Reference Document**: `k8s-manifests/database-deployment.yaml`, `k8s-manifests/database-service.yaml`

#### **Step 4.2: Initialize Database Schema**
**Objective**: Create database tables and initial data

**Detailed Steps**:
1. **Connect to database**
   ```bash
   kubectl exec -it -n ecommerce deployment/ecommerce-database -- psql -U postgres -d ecommerce
   ```
   - **Purpose**: Access database for schema creation
   - **Expected Output**: PostgreSQL command prompt
   - **Verification**: Connected to ecommerce database

2. **Create database schema**
   ```sql
   CREATE TABLE products (
       id SERIAL PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       description TEXT,
       price DECIMAL(10,2) NOT NULL,
       category VARCHAR(100),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   
   CREATE TABLE orders (
       id SERIAL PRIMARY KEY,
       customer_email VARCHAR(255) NOT NULL,
       total_amount DECIMAL(10,2) NOT NULL,
       status VARCHAR(50) DEFAULT 'pending',
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   
   INSERT INTO products (name, description, price, category) VALUES
   ('Laptop', 'High-performance laptop', 999.99, 'Electronics'),
   ('Mouse', 'Wireless mouse', 29.99, 'Electronics'),
   ('Keyboard', 'Mechanical keyboard', 79.99, 'Electronics');
   ```
   - **Purpose**: Create database tables and sample data
   - **Expected Output**: Tables created, data inserted
   - **Verification**: `\dt` shows tables, `SELECT * FROM products;` shows data

**Reference Document**: `docs/04-deployment-guide.md`

### **Day 5: Backend Application Deployment**

#### **Step 5.1: Deploy Backend API**
**Objective**: Deploy the e-commerce backend application

**Detailed Steps**:
1. **Apply backend deployment**
   ```bash
   kubectl apply -f k8s-manifests/backend-deployment.yaml
   ```
   - **Purpose**: Deploy Node.js backend API
   - **Expected Output**: Backend deployment created
   - **Verification**: `kubectl get deployment -n ecommerce` shows backend deployment

2. **Apply backend service**
   ```bash
   kubectl apply -f k8s-manifests/backend-service.yaml
   ```
   - **Purpose**: Expose backend API internally
   - **Expected Output**: Backend service created
   - **Verification**: `kubectl get service -n ecommerce` shows backend service

3. **Verify backend deployment**
   ```bash
   kubectl get pods -n ecommerce -l app=ecommerce-backend
   kubectl logs -n ecommerce deployment/ecommerce-backend
   ```
   - **Purpose**: Confirm backend is running and healthy
   - **Expected Output**: Backend pod running, logs show successful startup
   - **Verification**: Pod status is Running, logs show API server started

**Reference Document**: `k8s-manifests/backend-deployment.yaml`, `k8s-manifests/backend-service.yaml`

#### **Step 5.2: Test Backend API**
**Objective**: Verify backend API functionality

**Detailed Steps**:
1. **Port forward to backend service**
   ```bash
   kubectl port-forward -n ecommerce service/ecommerce-backend-service 8080:80
   ```
   - **Purpose**: Access backend API from local machine
   - **Expected Output**: Port forwarding active
   - **Verification**: `curl http://localhost:8080/health` returns 200 OK

2. **Test API endpoints**
   ```bash
   curl http://localhost:8080/api/products
   curl http://localhost:8080/api/orders
   ```
   - **Purpose**: Verify API endpoints are working
   - **Expected Output**: JSON responses with product and order data
   - **Verification**: API returns expected data

**Reference Document**: `validation/smoke-tests.sh`

---

## 🎨 **PHASE 2: APPLICATION DEPLOYMENT (Week 2)**

### **Day 6: Frontend Application Deployment**

#### **Step 6.1: Deploy Frontend Application**
**Objective**: Deploy the React frontend application

**Detailed Steps**:
1. **Apply frontend deployment**
   ```bash
   kubectl apply -f k8s-manifests/frontend-deployment.yaml
   ```
   - **Purpose**: Deploy React frontend application
   - **Expected Output**: Frontend deployment created
   - **Verification**: `kubectl get deployment -n ecommerce` shows frontend deployment

2. **Apply frontend service**
   ```bash
   kubectl apply -f k8s-manifests/frontend-service.yaml
   ```
   - **Purpose**: Expose frontend application internally
   - **Expected Output**: Frontend service created
   - **Verification**: `kubectl get service -n ecommerce` shows frontend service

3. **Verify frontend deployment**
   ```bash
   kubectl get pods -n ecommerce -l app=ecommerce-frontend
   kubectl logs -n ecommerce deployment/ecommerce-frontend
   ```
   - **Purpose**: Confirm frontend is running and healthy
   - **Expected Output**: Frontend pod running, logs show successful startup
   - **Verification**: Pod status is Running, logs show React app started

**Reference Document**: `k8s-manifests/frontend-deployment.yaml`, `k8s-manifests/frontend-service.yaml`

#### **Step 6.2: Test Frontend Application**
**Objective**: Verify frontend application functionality

**Detailed Steps**:
1. **Port forward to frontend service**
   ```bash
   kubectl port-forward -n ecommerce service/ecommerce-frontend-service 3000:80
   ```
   - **Purpose**: Access frontend application from local machine
   - **Expected Output**: Port forwarding active
   - **Verification**: Browser shows React application

2. **Test application functionality**
   - Open browser to `http://localhost:3000`
   - Navigate through product listings
   - Test cart functionality
   - Verify API communication
   - **Purpose**: Confirm end-to-end application functionality
   - **Expected Output**: Application loads and functions correctly
   - **Verification**: All features work as expected

**Reference Document**: `validation/smoke-tests.sh`

### **Day 7: Application Integration Testing**

#### **Step 7.1: End-to-End Testing**
**Objective**: Verify complete application workflow

**Detailed Steps**:
1. **Run comprehensive tests**
   ```bash
   ./validation/comprehensive-tests.sh
   ```
   - **Purpose**: Execute all validation tests
   - **Expected Output**: All tests pass
   - **Verification**: Test script reports success

2. **Run health checks**
   ```bash
   ./validation/health-checks.sh
   ```
   - **Purpose**: Verify application health
   - **Expected Output**: All health checks pass
   - **Verification**: Health check script reports success

3. **Run smoke tests**
   ```bash
   ./validation/smoke-tests.sh
   ```
   - **Purpose**: Verify basic functionality
   - **Expected Output**: All smoke tests pass
   - **Verification**: Smoke test script reports success

**Reference Document**: `validation/` directory

#### **Step 7.2: Performance Testing**
**Objective**: Verify application performance under load

**Detailed Steps**:
1. **Test response times**
   ```bash
   time curl http://localhost:8080/api/products
   time curl http://localhost:3000
   ```
   - **Purpose**: Measure API and frontend response times
   - **Expected Output**: Response times < 1 second
   - **Verification**: Times are within acceptable limits

2. **Test concurrent requests**
   ```bash
   for i in {1..10}; do curl http://localhost:8080/api/products & done
   wait
   ```
   - **Purpose**: Test application under concurrent load
   - **Expected Output**: All requests complete successfully
   - **Verification**: No errors or timeouts

**Reference Document**: `docs/08-test-plan.md`

---

## 📊 **PHASE 3: MONITORING & SECURITY (Week 3)**

### **Day 8: Prometheus Setup**

#### **Step 8.1: Deploy Prometheus**
**Objective**: Set up metrics collection and storage

**Detailed Steps**:
1. **Create Prometheus ConfigMap**
   ```bash
   kubectl create configmap prometheus-config -n monitoring --from-file=monitoring/prometheus/prometheus.yml
   ```
   - **Purpose**: Store Prometheus configuration
   - **Expected Output**: ConfigMap created successfully
   - **Verification**: `kubectl get configmap -n monitoring` shows prometheus-config

2. **Deploy Prometheus**
   ```bash
   kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml
   kubectl apply -f monitoring/prometheus/prometheus-service.yaml
   ```
   - **Purpose**: Deploy Prometheus server
   - **Expected Output**: Prometheus deployment and service created
   - **Verification**: `kubectl get pods -n monitoring` shows Prometheus running

3. **Verify Prometheus functionality**
   ```bash
   kubectl port-forward -n monitoring service/prometheus 9090:9090
   ```
   - **Purpose**: Access Prometheus web interface
   - **Expected Output**: Prometheus UI accessible at http://localhost:9090
   - **Verification**: Prometheus targets show as UP

**Reference Document**: `monitoring/prometheus/prometheus.yml`

#### **Step 8.2: Configure Service Discovery**
**Objective**: Enable automatic discovery of Kubernetes resources

**Detailed Steps**:
1. **Verify Kubernetes API server monitoring**
   - Check Prometheus targets for `kubernetes-apiservers`
   - **Purpose**: Monitor Kubernetes API server metrics
   - **Expected Output**: Target shows as UP
   - **Verification**: Metrics are being collected

2. **Verify node monitoring**
   - Check Prometheus targets for `kubernetes-nodes`
   - **Purpose**: Monitor Kubernetes node metrics
   - **Expected Output**: Target shows as UP
   - **Verification**: Node metrics are being collected

3. **Verify pod monitoring**
   - Check Prometheus targets for `kubernetes-pods`
   - **Purpose**: Monitor Kubernetes pod metrics
   - **Expected Output**: Target shows as UP
   - **Verification**: Pod metrics are being collected

**Reference Document**: `monitoring/prometheus/prometheus.yml`

### **Day 9: Node Exporter Setup**

#### **Step 9.1: Deploy Node Exporter**
**Objective**: Collect system-level metrics from all nodes

**Detailed Steps**:
1. **Deploy Node Exporter DaemonSet**
   ```bash
   kubectl apply -f monitoring/node-exporter/node-exporter-deployment.yaml
   kubectl apply -f monitoring/node-exporter/node-exporter-service.yaml
   ```
   - **Purpose**: Deploy Node Exporter on all nodes
   - **Expected Output**: Node Exporter DaemonSet and service created
   - **Verification**: `kubectl get pods -n monitoring` shows node-exporter pods

2. **Verify Node Exporter metrics**
   ```bash
   kubectl port-forward -n monitoring service/node-exporter 9100:9100
   curl http://localhost:9100/metrics
   ```
   - **Purpose**: Verify Node Exporter is collecting metrics
   - **Expected Output**: Metrics endpoint returns system metrics
   - **Verification**: Metrics include CPU, memory, disk, network data

**Reference Document**: `monitoring/node-exporter/node-exporter-deployment.yaml`

#### **Step 9.2: Configure Prometheus to Scrape Node Exporter**
**Objective**: Enable Prometheus to collect Node Exporter metrics

**Detailed Steps**:
1. **Verify Node Exporter service discovery**
   - Check Prometheus targets for `kubernetes-services`
   - Look for node-exporter service
   - **Purpose**: Ensure Prometheus discovers Node Exporter
   - **Expected Output**: Node Exporter target shows as UP
   - **Verification**: Metrics are being collected

2. **Test Node Exporter queries**
   ```bash
   # In Prometheus UI, test these queries:
   node_cpu_seconds_total
   node_memory_MemTotal_bytes
   node_filesystem_size_bytes
   ```
   - **Purpose**: Verify Node Exporter metrics are queryable
   - **Expected Output**: Queries return data
   - **Verification**: All queries return expected metrics

**Reference Document**: `monitoring/prometheus/prometheus.yml`

### **Day 10: Grafana Setup**

#### **Step 10.1: Deploy Grafana**
**Objective**: Set up visualization and dashboards

**Detailed Steps**:
1. **Deploy Grafana**
   ```bash
   kubectl apply -f monitoring/grafana/grafana-deployment.yaml
   kubectl apply -f monitoring/grafana/grafana-service.yaml
   ```
   - **Purpose**: Deploy Grafana for visualization
   - **Expected Output**: Grafana deployment and service created
   - **Verification**: `kubectl get pods -n monitoring` shows Grafana running

2. **Access Grafana**
   ```bash
   kubectl port-forward -n monitoring service/grafana 3000:3000
   ```
   - **Purpose**: Access Grafana web interface
   - **Expected Output**: Grafana accessible at http://localhost:3000
   - **Verification**: Grafana login page loads

3. **Login to Grafana**
   - Username: `admin`
   - Password: `admin123`
   - **Purpose**: Access Grafana dashboard
   - **Expected Output**: Grafana dashboard loads
   - **Verification**: Dashboard is accessible

**Reference Document**: `monitoring/grafana/grafana-deployment.yaml`

#### **Step 10.2: Configure Prometheus Data Source**
**Objective**: Connect Grafana to Prometheus

**Detailed Steps**:
1. **Add Prometheus data source**
   - Go to Configuration > Data Sources
   - Add Prometheus data source
   - URL: `http://prometheus:9090`
   - **Purpose**: Connect Grafana to Prometheus
   - **Expected Output**: Data source added successfully
   - **Verification**: Test connection shows success

2. **Import dashboard**
   - Go to Dashboards > Import
   - Upload `monitoring/grafana/grafana-dashboard.json`
   - **Purpose**: Import pre-configured dashboard
   - **Expected Output**: Dashboard imported successfully
   - **Verification**: Dashboard shows metrics

**Reference Document**: `monitoring/grafana/grafana-dashboard.json`

### **Day 11: AlertManager Setup**

#### **Step 11.1: Deploy AlertManager**
**Objective**: Set up alerting and notification system

**Detailed Steps**:
1. **Deploy AlertManager**
   ```bash
   kubectl create configmap alertmanager-config -n monitoring --from-file=monitoring/alertmanager/alertmanager.yml
   kubectl apply -f monitoring/alertmanager/alertmanager-deployment.yaml
   kubectl apply -f monitoring/alertmanager/alertmanager-service.yaml
   ```
   - **Purpose**: Deploy AlertManager for alerting
   - **Expected Output**: AlertManager deployment and service created
   - **Verification**: `kubectl get pods -n monitoring` shows AlertManager running

2. **Access AlertManager**
   ```bash
   kubectl port-forward -n monitoring service/alertmanager 9093:9093
   ```
   - **Purpose**: Access AlertManager web interface
   - **Expected Output**: AlertManager accessible at http://localhost:9093
   - **Verification**: AlertManager UI loads

**Reference Document**: `monitoring/alertmanager/alertmanager.yml`

#### **Step 11.2: Configure Alerting Rules**
**Objective**: Set up alerting rules for critical metrics

**Detailed Steps**:
1. **Create alerting rules**
   ```bash
   kubectl create configmap prometheus-rules -n monitoring --from-file=monitoring/prometheus/alerting-rules.yml
   ```
   - **Purpose**: Define alerting rules for critical conditions
   - **Expected Output**: Alerting rules ConfigMap created
   - **Verification**: `kubectl get configmap -n monitoring` shows prometheus-rules

2. **Verify alerting rules**
   - Check Prometheus > Alerts page
   - **Purpose**: Verify alerting rules are active
   - **Expected Output**: Alerting rules are loaded
   - **Verification**: Rules show in Prometheus UI

**Reference Document**: `monitoring/prometheus/alerting-rules.yml`

### **Day 12: Security Configuration**

#### **Step 12.1: Configure RBAC**
**Objective**: Set up role-based access control

**Detailed Steps**:
1. **Create service accounts**
   ```bash
   kubectl create serviceaccount prometheus -n monitoring
   kubectl create serviceaccount grafana -n monitoring
   ```
   - **Purpose**: Create dedicated service accounts for monitoring
   - **Expected Output**: Service accounts created
   - **Verification**: `kubectl get serviceaccounts -n monitoring` shows accounts

2. **Create RBAC roles**
   ```bash
   kubectl apply -f monitoring/rbac/prometheus-rbac.yaml
   kubectl apply -f monitoring/rbac/grafana-rbac.yaml
   ```
   - **Purpose**: Define permissions for monitoring components
   - **Expected Output**: RBAC roles and bindings created
   - **Verification**: `kubectl get roles -n monitoring` shows roles

**Reference Document**: `monitoring/rbac/` directory

#### **Step 12.2: Configure Network Policies**
**Objective**: Implement network segmentation

**Detailed Steps**:
1. **Create network policies**
   ```bash
   kubectl apply -f k8s-manifests/network-policies.yaml
   ```
   - **Purpose**: Restrict network traffic between components
   - **Expected Output**: Network policies created
   - **Verification**: `kubectl get networkpolicies -n ecommerce` shows policies

2. **Test network policies**
   ```bash
   kubectl exec -it -n ecommerce deployment/ecommerce-frontend -- curl ecommerce-backend-service
   kubectl exec -it -n ecommerce deployment/ecommerce-frontend -- curl ecommerce-database-service
   ```
   - **Purpose**: Verify network policies allow required traffic
   - **Expected Output**: Internal communication works
   - **Verification**: API calls succeed

**Reference Document**: `k8s-manifests/network-policies.yaml`

---

## 📚 **PHASE 4: DOCUMENTATION & VALIDATION (Week 4)**

### **Day 13: Documentation Review**

#### **Step 13.1: Technical Documentation Review**
**Objective**: Ensure all technical documentation is complete and accurate

**Detailed Steps**:
1. **Review deployment guide**
   - Verify all steps are documented
   - Test each command and procedure
   - Update any outdated information
   - **Purpose**: Ensure deployment guide is accurate
   - **Expected Output**: All steps verified and working
   - **Verification**: Documentation matches actual implementation

2. **Review operations runbook**
   - Test all operational procedures
   - Verify troubleshooting steps
   - Update contact information
   - **Purpose**: Ensure operations guide is complete
   - **Expected Output**: All procedures tested and working
   - **Verification**: Operations team can follow procedures

**Reference Document**: `docs/04-deployment-guide.md`, `docs/05-operations-runbook.md`

#### **Step 13.2: Architecture Documentation Review**
**Objective**: Ensure architecture documentation is complete

**Detailed Steps**:
1. **Review technical design**
   - Verify architecture diagrams
   - Update component descriptions
   - Validate configuration details
   - **Purpose**: Ensure technical design is accurate
   - **Expected Output**: Architecture documentation is complete
   - **Verification**: Diagrams match actual implementation

2. **Review monitoring documentation**
   - Verify monitoring setup procedures
   - Update dashboard configurations
   - Validate alerting rules
   - **Purpose**: Ensure monitoring documentation is complete
   - **Expected Output**: Monitoring documentation is accurate
   - **Verification**: Monitoring setup matches documentation

**Reference Document**: `docs/03-technical-design.md`

### **Day 14: Final Testing and Validation**

#### **Step 14.1: Comprehensive System Testing**
**Objective**: Perform final validation of entire system

**Detailed Steps**:
1. **Run complete test suite**
   ```bash
   ./validation/comprehensive-tests.sh
   ./validation/health-checks.sh
   ./validation/smoke-tests.sh
   ```
   - **Purpose**: Validate all system components
   - **Expected Output**: All tests pass
   - **Verification**: Test reports show success

2. **Performance testing**
   ```bash
   # Load test the application
   for i in {1..100}; do curl http://localhost:8080/api/products & done
   wait
   ```
   - **Purpose**: Verify system performance under load
   - **Expected Output**: System handles load without errors
   - **Verification**: No timeouts or errors

3. **Monitoring validation**
   - Check all Prometheus targets are UP
   - Verify Grafana dashboards show data
   - Test AlertManager notifications
   - **Purpose**: Ensure monitoring is working correctly
   - **Expected Output**: All monitoring components functional
   - **Verification**: Metrics, dashboards, and alerts working

**Reference Document**: `validation/` directory

#### **Step 14.2: Security Validation**
**Objective**: Verify security controls are working

**Detailed Steps**:
1. **Test RBAC policies**
   ```bash
   kubectl auth can-i get pods --as=system:serviceaccount:monitoring:prometheus
   kubectl auth can-i get secrets --as=system:serviceaccount:monitoring:prometheus
   ```
   - **Purpose**: Verify RBAC permissions are correct
   - **Expected Output**: Appropriate permissions granted/denied
   - **Verification**: RBAC policies working as expected

2. **Test network policies**
   ```bash
   kubectl exec -it -n ecommerce deployment/ecommerce-frontend -- curl ecommerce-backend-service
   kubectl exec -it -n ecommerce deployment/ecommerce-frontend -- curl prometheus
   ```
   - **Purpose**: Verify network segmentation is working
   - **Expected Output**: Internal traffic allowed, external traffic blocked
   - **Verification**: Network policies enforced correctly

**Reference Document**: `docs/06-troubleshooting-guide.md`

### **Day 15: Knowledge Transfer and Handoff**

#### **Step 15.1: Team Training Session**
**Objective**: Transfer knowledge to operations team

**Detailed Steps**:
1. **Conduct training session**
   - Present system architecture
   - Demonstrate operational procedures
   - Walk through troubleshooting guide
   - **Purpose**: Ensure team understands the system
   - **Expected Output**: Team is confident in operations
   - **Verification**: Team can perform basic operations

2. **Handoff documentation**
   - Provide access to all documentation
   - Share monitoring credentials
   - Explain escalation procedures
   - **Purpose**: Ensure team has all necessary information
   - **Expected Output**: Team has complete access
   - **Verification**: Team can access all resources

**Reference Document**: `docs/09-communication-plan.md`

#### **Step 15.2: Project Closure**
**Objective**: Complete project closure activities

**Detailed Steps**:
1. **Update project closure report**
   - Document final status
   - Record lessons learned
   - Update success metrics
   - **Purpose**: Complete project documentation
   - **Expected Output**: Project closure report updated
   - **Verification**: All project activities documented

2. **Conduct project review**
   - Review project objectives
   - Assess success criteria
   - Identify improvements
   - **Purpose**: Evaluate project success
   - **Expected Output**: Project review completed
   - **Verification**: All stakeholders satisfied

**Reference Document**: `docs/10-project-closure-report.md`

---

## 📊 **Execution Checklist**

### **Phase 1: Foundation Setup (Week 1)**
- [ ] **Day 1**: System preparation and Docker installation
- [ ] **Day 2**: Kubernetes cluster setup and configuration
- [ ] **Day 3**: Namespace and resource setup
- [ ] **Day 4**: Database deployment and initialization
- [ ] **Day 5**: Backend application deployment and testing

### **Phase 2: Application Deployment (Week 2)**
- [ ] **Day 6**: Frontend application deployment
- [ ] **Day 7**: Application integration testing and performance testing

### **Phase 3: Monitoring & Security (Week 3)**
- [ ] **Day 8**: Prometheus setup and configuration
- [ ] **Day 9**: Node Exporter deployment and configuration
- [ ] **Day 10**: Grafana setup and dashboard configuration
- [ ] **Day 11**: AlertManager setup and alerting configuration
- [ ] **Day 12**: Security configuration (RBAC, network policies)

### **Phase 4: Documentation & Validation (Week 4)**
- [ ] **Day 13**: Documentation review and updates
- [ ] **Day 14**: Final testing and validation
- [ ] **Day 15**: Knowledge transfer and project closure

---

## 🚨 **Troubleshooting Quick Reference**

### **Common Issues and Solutions**

#### **Issue 1: Pod Stuck in Pending State**
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace>
```
- **Cause**: Usually resource constraints or scheduling issues
- **Solution**: Check resource requests, node capacity, or taints

#### **Issue 2: Service Not Accessible**
```bash
kubectl get endpoints -n <namespace>
kubectl describe service <service-name> -n <namespace>
```
- **Cause**: Usually pod selector mismatch or pod not ready
- **Solution**: Check pod labels and service selector

#### **Issue 3: Monitoring Not Working**
```bash
kubectl get pods -n monitoring
kubectl logs -n monitoring deployment/prometheus
```
- **Cause**: Usually configuration issues or service discovery problems
- **Solution**: Check Prometheus configuration and service discovery

**Reference Document**: `docs/06-troubleshooting-guide.md`

---

## 📞 **Support and Escalation**

### **Technical Support**
- **Email**: tech-support@company.com
- **Phone**: (555) 123-9999
- **Hours**: 24/7

### **Project Support**
- **Email**: project-support@company.com
- **Phone**: (555) 123-8888
- **Hours**: Business hours

### **Emergency Escalation**
- **Phone**: (555) 123-7777
- **Email**: emergency@company.com
- **Hours**: 24/7

---

**Document Status**: Active  
**Review Date**: $(date + 7 days)  
**Next Update**: $(date + 14 days)  
**Approval Required**: Project Manager, Technical Lead, CTO
