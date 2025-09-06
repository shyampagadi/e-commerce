# 🧪 **Advanced Networking Lab Exercises**
*Hands-on labs for mastering CNI and network policies*

## 🎯 **Lab Overview**

These labs provide practical experience with:
- CNI plugin configuration and comparison
- Network policy implementation and testing
- Multi-cluster networking setup
- Performance optimization and troubleshooting

## 🚀 **Lab 1: CNI Plugin Performance Comparison**

### **Objective**
Compare the performance characteristics of Calico, Cilium, and Flannel CNI plugins in a controlled environment.

### **Prerequisites**
- 3 separate Kubernetes clusters (or ability to switch CNI plugins)
- Network performance testing tools
- Monitoring setup

### **Lab Steps**

#### **Step 1: Environment Setup**
```bash
# Create test namespace
kubectl create namespace cni-performance-test

# Deploy test applications
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iperf3-server
  namespace: cni-performance-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: iperf3-server
  template:
    metadata:
      labels:
        app: iperf3-server
    spec:
      containers:
      - name: iperf3-server
        image: networkstatic/iperf3:latest
        command: ["iperf3", "-s"]
        ports:
        - containerPort: 5201
---
apiVersion: v1
kind: Service
metadata:
  name: iperf3-server-service
  namespace: cni-performance-test
spec:
  selector:
    app: iperf3-server
  ports:
  - port: 5201
    targetPort: 5201
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iperf3-client
  namespace: cni-performance-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: iperf3-client
  template:
    metadata:
      labels:
        app: iperf3-client
    spec:
      containers:
      - name: iperf3-client
        image: networkstatic/iperf3:latest
        command: ["sleep", "3600"]
EOF
```

#### **Step 2: Calico Performance Test**
```bash
# Run bandwidth test with Calico
kubectl exec -n cni-performance-test deployment/iperf3-client -- iperf3 -c iperf3-server-service -t 60 -P 4

# Run latency test
kubectl exec -n cni-performance-test deployment/iperf3-client -- ping -c 100 iperf3-server-service
```

**Expected Results (Calico):**
```
Connecting to host iperf3-server-service, port 5201
[  5] local 10.244.1.5 port 54321 connected to 10.244.2.8 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   112 MBytes   941 Mbits/sec    0    256 KBytes
...
[SUM]   0.00-60.00  sec  6.58 GBytes   942 Mbits/sec    0             sender
[SUM]   0.00-60.00  sec  6.58 GBytes   942 Mbits/sec                  receiver

--- iperf3-server-service ping statistics ---
100 packets transmitted, 100 received, 0% packet loss
round-trip min/avg/max/stddev = 0.123/0.145/0.234/0.023 ms
```

#### **Step 3: Performance Metrics Collection**
```bash
# Create performance monitoring script
cat > collect-metrics.sh << 'EOF'
#!/bin/bash
CNI_TYPE=$1
DURATION=60

echo "Testing $CNI_TYPE CNI Performance"
echo "=================================="

# Bandwidth test
echo "Running bandwidth test..."
BANDWIDTH=$(kubectl exec -n cni-performance-test deployment/iperf3-client -- iperf3 -c iperf3-server-service -t $DURATION -f M | grep "sender" | awk '{print $7}')

# Latency test
echo "Running latency test..."
LATENCY=$(kubectl exec -n cni-performance-test deployment/iperf3-client -- ping -c 100 iperf3-server-service | tail -1 | awk -F'/' '{print $5}')

# CPU usage during test
echo "Measuring CPU usage..."
CPU_USAGE=$(kubectl top nodes | awk 'NR>1 {sum+=$3} END {print sum/NR}')

# Memory usage
MEMORY_USAGE=$(kubectl top nodes | awk 'NR>1 {sum+=$5} END {print sum/NR}')

echo "Results for $CNI_TYPE:"
echo "Bandwidth: ${BANDWIDTH} Mbits/sec"
echo "Average Latency: ${LATENCY} ms"
echo "Average CPU Usage: ${CPU_USAGE}%"
echo "Average Memory Usage: ${MEMORY_USAGE}%"
echo ""
EOF

chmod +x collect-metrics.sh
./collect-metrics.sh calico
```

### **Lab Deliverables**
- Performance comparison table
- Resource utilization analysis
- Recommendation report for CNI selection

---

## 🛡️ **Lab 2: Comprehensive Network Policy Implementation**

### **Objective**
Implement a complete network security model for an e-commerce application using network policies.

### **Lab Steps**

#### **Step 1: Deploy E-commerce Application**
```bash
# Create production namespace
kubectl create namespace ecommerce-prod

# Deploy frontend application
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: ecommerce-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
      tier: web
  template:
    metadata:
      labels:
        app: frontend
        tier: web
        security-zone: dmz
    spec:
      containers:
      - name: frontend
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: ecommerce-prod
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Deploy backend API
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: ecommerce-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
      tier: api
  template:
    metadata:
      labels:
        app: backend
        tier: api
        security-zone: internal
        external-access: "allowed"
    spec:
      containers:
      - name: backend
        image: python:3.9-slim
        command: ["python", "-m", "http.server", "8000"]
        ports:
        - containerPort: 8000
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: ecommerce-prod
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
EOF

# Deploy database
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: ecommerce-prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
      tier: data
  template:
    metadata:
      labels:
        app: database
        tier: data
        security-zone: restricted
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: ecommerce
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          value: password123
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: ecommerce-prod
spec:
  selector:
    app: database
  ports:
  - port: 5432
    targetPort: 5432
EOF
```

#### **Step 2: Test Initial Connectivity**
```bash
# Test frontend to backend connectivity
kubectl exec -n ecommerce-prod deployment/frontend -- curl -m 5 http://backend-service:8000

# Test backend to database connectivity
kubectl exec -n ecommerce-prod deployment/backend -- nc -zv database-service 5432

# Test external connectivity
kubectl exec -n ecommerce-prod deployment/backend -- curl -m 5 -I https://httpbin.org/get
```

**Expected Results (before policies):**
```
# All connections should succeed
HTTP/1.1 200 OK
Connection to database-service 5432 port [tcp/postgresql] succeeded!
HTTP/2 200
```

#### **Step 3: Implement Default Deny Policy**
```bash
# Apply default deny-all policy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ecommerce-prod
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test connectivity after deny-all policy
kubectl exec -n ecommerce-prod deployment/frontend -- timeout 5 curl http://backend-service:8000
```

**Expected Results (after deny-all):**
```
# All connections should fail
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 124
```

#### **Step 4: Implement Selective Allow Policies**
```bash
# Allow frontend to backend communication
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: ecommerce-prod
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8000
  - to: []  # DNS
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress
  namespace: ecommerce-prod
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8000
EOF

# Test frontend to backend connectivity
kubectl exec -n ecommerce-prod deployment/frontend -- curl -m 5 http://backend-service:8000
```

**Expected Results:**
```
# Frontend to backend should work
<!DOCTYPE html>
<html>
<head>
<title>Directory listing for /</title>
</head>
...
```

#### **Step 5: Implement Database Access Policy**
```bash
# Allow backend to database communication
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
  namespace: ecommerce-prod
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  - to: []  # DNS
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ingress
  namespace: ecommerce-prod
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
EOF
```

#### **Step 6: Implement External API Access**
```bash
# Allow backend to access external APIs
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-api-access
  namespace: ecommerce-prod
spec:
  podSelector:
    matchLabels:
      external-access: "allowed"
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
  - to: []  # DNS
    ports:
    - protocol: UDP
      port: 53
EOF

# Test external API access
kubectl exec -n ecommerce-prod deployment/backend -- curl -m 10 -I https://httpbin.org/get
```

### **Lab Validation**
```bash
# Create validation script
cat > validate-policies.sh << 'EOF'
#!/bin/bash

echo "Network Policy Validation"
echo "========================"

# Test 1: Frontend to Backend (should work)
echo "Test 1: Frontend to Backend"
if kubectl exec -n ecommerce-prod deployment/frontend -- timeout 5 curl -s http://backend-service:8000 > /dev/null; then
    echo "✅ PASS: Frontend can reach backend"
else
    echo "❌ FAIL: Frontend cannot reach backend"
fi

# Test 2: Frontend to Database (should fail)
echo "Test 2: Frontend to Database (should be blocked)"
if kubectl exec -n ecommerce-prod deployment/frontend -- timeout 5 nc -zv database-service 5432 2>/dev/null; then
    echo "❌ FAIL: Frontend can reach database (security violation)"
else
    echo "✅ PASS: Frontend blocked from database"
fi

# Test 3: Backend to Database (should work)
echo "Test 3: Backend to Database"
if kubectl exec -n ecommerce-prod deployment/backend -- timeout 5 nc -zv database-service 5432 2>/dev/null; then
    echo "✅ PASS: Backend can reach database"
else
    echo "❌ FAIL: Backend cannot reach database"
fi

# Test 4: Backend to External API (should work)
echo "Test 4: Backend to External API"
if kubectl exec -n ecommerce-prod deployment/backend -- timeout 10 curl -s -I https://httpbin.org/get > /dev/null; then
    echo "✅ PASS: Backend can reach external APIs"
else
    echo "❌ FAIL: Backend cannot reach external APIs"
fi

# Test 5: Database External Access (should fail)
echo "Test 5: Database External Access (should be blocked)"
if kubectl exec -n ecommerce-prod deployment/database -- timeout 5 curl -s -I https://httpbin.org/get 2>/dev/null; then
    echo "❌ FAIL: Database can reach external APIs (security violation)"
else
    echo "✅ PASS: Database blocked from external access"
fi

echo ""
echo "Validation Complete"
EOF

chmod +x validate-policies.sh
./validate-policies.sh
```

**Expected Results:**
```
Network Policy Validation
========================
Test 1: Frontend to Backend
✅ PASS: Frontend can reach backend
Test 2: Frontend to Database (should be blocked)
✅ PASS: Frontend blocked from database
Test 3: Backend to Database
✅ PASS: Backend can reach database
Test 4: Backend to External API
✅ PASS: Backend can reach external APIs
Test 5: Database External Access (should be blocked)
✅ PASS: Database blocked from external access

Validation Complete
```

---

## 🌐 **Lab 3: Multi-Cluster Networking with Submariner**

### **Objective**
Set up secure multi-cluster networking between three Kubernetes clusters representing different geographic regions.

### **Prerequisites**
- 3 Kubernetes clusters (can be local clusters using kind)
- Submariner CLI installed
- Network connectivity between cluster nodes

### **Lab Steps**

#### **Step 1: Create Test Clusters**
```bash
# Create three kind clusters for multi-cluster testing
cat > cluster-us.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: us-east-1
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/16"
nodes:
- role: control-plane
- role: worker
EOF

cat > cluster-eu.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: eu-west-1
networking:
  podSubnet: "10.245.0.0/16"
  serviceSubnet: "10.97.0.0/16"
nodes:
- role: control-plane
- role: worker
EOF

cat > cluster-asia.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: asia-southeast-1
networking:
  podSubnet: "10.246.0.0/16"
  serviceSubnet: "10.98.0.0/16"
nodes:
- role: control-plane
- role: worker
EOF

# Create clusters
kind create cluster --config cluster-us.yaml
kind create cluster --config cluster-eu.yaml
kind create cluster --config cluster-asia.yaml
```

#### **Step 2: Install Submariner**
```bash
# Install subctl
curl -Ls https://get.submariner.io | bash
export PATH=$PATH:~/.local/bin

# Deploy broker on US cluster
kubectl config use-context kind-us-east-1
subctl deploy-broker

# Join clusters to broker
subctl join broker-info.subm --kubeconfig ~/.kube/config --context kind-us-east-1 --clusterid us-east-1
subctl join broker-info.subm --kubeconfig ~/.kube/config --context kind-eu-west-1 --clusterid eu-west-1
subctl join broker-info.subm --kubeconfig ~/.kube/config --context kind-asia-southeast-1 --clusterid asia-southeast-1
```

#### **Step 3: Deploy Test Applications**
```bash
# Deploy application in US cluster
kubectl config use-context kind-us-east-1
kubectl create namespace multi-cluster-test
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: us-service
  namespace: multi-cluster-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: us-service
  template:
    metadata:
      labels:
        app: us-service
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: us-service
  namespace: multi-cluster-test
spec:
  selector:
    app: us-service
  ports:
  - port: 80
    targetPort: 80
EOF

# Export service for cross-cluster access
subctl export service us-service -n multi-cluster-test

# Deploy application in EU cluster
kubectl config use-context kind-eu-west-1
kubectl create namespace multi-cluster-test
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: eu-service
  namespace: multi-cluster-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eu-service
  template:
    metadata:
      labels:
        app: eu-service
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: eu-service
  namespace: multi-cluster-test
spec:
  selector:
    app: eu-service
  ports:
  - port: 80
    targetPort: 80
EOF

subctl export service eu-service -n multi-cluster-test
```

#### **Step 4: Test Cross-Cluster Connectivity**
```bash
# Test from US to EU service
kubectl config use-context kind-us-east-1
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -m 10 http://eu-service.multi-cluster-test.svc.clusterset.local

# Test from EU to US service
kubectl config use-context kind-eu-west-1
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -m 10 http://us-service.multi-cluster-test.svc.clusterset.local
```

**Expected Results:**
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

#### **Step 5: Verify Submariner Status**
```bash
# Check Submariner connectivity
subctl verify --context kind-us-east-1 --tocontext kind-eu-west-1 --verbose
subctl show all
```

**Expected Results:**
```
✓ Checking Submariner support for the given version
✓ Retrieving Submariner resource versions  
✓ Validating tunnel connections
✓ Cross-cluster connectivity test successful
✓ All gateways are connected
✓ Service discovery is working
```

### **Lab Deliverables**
- Multi-cluster architecture diagram
- Cross-cluster service discovery documentation
- Performance metrics for cross-cluster communication
- Disaster recovery procedures

---

## 📊 **Lab 4: Network Performance Optimization**

### **Objective**
Optimize network performance for high-throughput e-commerce workloads using advanced CNI features and tuning.

### **Lab Steps**

#### **Step 1: Baseline Performance Measurement**
```bash
# Deploy performance testing infrastructure
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: network-performance-monitor
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: network-performance-monitor
  template:
    metadata:
      labels:
        app: network-performance-monitor
    spec:
      hostNetwork: true
      containers:
      - name: monitor
        image: nicolaka/netshoot:latest
        command: ["sleep", "3600"]
        securityContext:
          privileged: true
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
EOF

# Run baseline performance tests
kubectl exec -n kube-system ds/network-performance-monitor -- iperf3 -s &
kubectl exec -n kube-system ds/network-performance-monitor -- iperf3 -c <target-node-ip> -t 60 -P 4
```

#### **Step 2: Enable CNI Performance Features**
```bash
# Enable Cilium bandwidth manager
kubectl patch configmap cilium-config -n kube-system --patch '
data:
  enable-bandwidth-manager: "true"
  enable-local-redirect-policy: "true"
  kube-proxy-replacement: "strict"
  enable-host-routing: "true"
'

# Restart Cilium pods
kubectl delete pods -n kube-system -l k8s-app=cilium

# For Calico, enable eBPF mode
kubectl patch installation.operator.tigera.io default --type merge -p '
spec:
  calicoNetwork:
    linuxDataplane: BPF
'
```

#### **Step 3: Implement Traffic Shaping**
```bash
# Apply bandwidth limits to specific workloads
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: bandwidth-limited-pod
  annotations:
    kubernetes.io/ingress-bandwidth: 10M
    kubernetes.io/egress-bandwidth: 10M
spec:
  containers:
  - name: test
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Test bandwidth limiting
kubectl exec bandwidth-limited-pod -- wget -O /dev/null http://speedtest.tele2.net/10MB.zip
```

### **Lab Deliverables**
- Performance optimization report
- Before/after performance metrics
- Tuning recommendations for production

---

## 🎓 **Lab Assessment and Certification**

### **Assessment Criteria**
Each lab will be evaluated on:
- **Technical Implementation** (40%): Correct configuration and deployment
- **Performance Results** (30%): Meeting performance benchmarks
- **Documentation** (20%): Clear documentation of procedures and results
- **Troubleshooting** (10%): Ability to identify and resolve issues

### **Certification Requirements**
To receive certification for Module 16:
- [ ] Complete all 4 labs successfully
- [ ] Achieve minimum performance benchmarks
- [ ] Submit comprehensive lab reports
- [ ] Pass practical troubleshooting assessment
- [ ] Demonstrate understanding of security implications

### **Final Project: Enterprise Network Architecture**
Design and implement a complete network architecture for a global e-commerce platform including:
- Multi-region cluster deployment
- Comprehensive network policies
- Performance optimization
- Security compliance (PCI DSS)
- Disaster recovery procedures
- Monitoring and alerting

**Deliverables:**
- Architecture design document
- Implementation code and configurations
- Performance test results
- Security assessment report
- Operational runbook
