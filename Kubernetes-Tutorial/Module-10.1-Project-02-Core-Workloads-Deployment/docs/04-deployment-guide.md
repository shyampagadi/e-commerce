# 🚀 **Deployment Guide: Core Workloads Deployment**

## **Document Information**
- **Document Type**: Deployment Guide
- **Version**: 1.0
- **Date**: December 2024
- **Author**: Senior Kubernetes Architect
- **Status**: Approved
- **Review Cycle**: Monthly

---

## **🎯 Executive Summary**

**Project**: E-commerce Core Workloads Deployment  
**Scope**: Production-Ready Kubernetes Platform  
**Timeline**: 8 weeks  
**Complexity**: Intermediate to Advanced  
**Target**: Zero-downtime deployments with auto-scaling  

### **Deployment Overview**
This guide provides step-by-step instructions for deploying a production-ready e-commerce platform with advanced Kubernetes workload management capabilities, building upon the foundation established in Project 1.

---

## **📋 Prerequisites**

### **Infrastructure Requirements**
- **Kubernetes Cluster**: 1.28+ with 6+ worker nodes
- **Storage**: 1TB+ for applications, logs, and backups
- **Network**: Calico CNI with network policies
- **Monitoring**: Prometheus, Grafana, AlertManager stack

### **Team Requirements**
- **Kubernetes Expertise**: Intermediate to advanced level
- **DevOps Experience**: CI/CD, automation, monitoring
- **Security Knowledge**: RBAC, network policies, secrets
- **Documentation Skills**: Technical writing and documentation

### **Tool Requirements**
- **kubectl**: Kubernetes command-line tool
- **helm**: Package manager for Kubernetes
- **yq**: YAML processor
- **jq**: JSON processor
- **git**: Version control system

---

## **🏗️ Phase 1: Architecture & Configuration (Weeks 1-2)**

### **Week 1: Kubernetes Architecture Setup**

#### **Day 1-2: Master Node Configuration**

**Objective**: Configure high-availability master node components.

**Step 1.1: API Server Setup**
```bash
# Create API server configuration
mkdir -p /etc/kubernetes/api-server
cd /etc/kubernetes/api-server

# Create API server configuration file
cat > kube-apiserver.yaml << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: https://kube-apiserver:6443
    certificate-authority: /etc/kubernetes/pki/ca.crt
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kube-apiserver
  name: kube-apiserver@kubernetes
current-context: kube-apiserver@kubernetes
users:
- name: kube-apiserver
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key: /etc/kubernetes/pki/apiserver.key
EOF
```

**Expected Output**:
```
Configuration file created successfully
API server configuration validated
```

**Verification**:
```bash
# Verify API server configuration
kubectl config view --kubeconfig=/etc/kubernetes/api-server/kube-apiserver.yaml
```

**Step 1.2: etcd Cluster Setup**
```bash
# Create etcd configuration for node 1
cat > /etc/kubernetes/etcd/etcd-node1.conf << EOF
name: etcd-node1
data-dir: /var/lib/etcd
initial-cluster: etcd-node1=https://10.0.1.10:2380,etcd-node2=https://10.0.1.11:2380,etcd-node3=https://10.0.1.12:2380
initial-cluster-state: new
initial-cluster-token: etcd-cluster-1
listen-peer-urls: https://10.0.1.10:2380
listen-client-urls: https://10.0.1.10:2379,https://127.0.0.1:2379
advertise-client-urls: https://10.0.1.10:2379
initial-advertise-peer-urls: https://10.0.1.10:2380
client-transport-security:
  cert-file: /etc/kubernetes/pki/etcd/etcd-server.crt
  key-file: /etc/kubernetes/pki/etcd/etcd-server.key
  trusted-ca-file: /etc/kubernetes/pki/etcd/etcd-ca.crt
peer-transport-security:
  cert-file: /etc/kubernetes/pki/etcd/etcd-peer.crt
  key-file: /etc/kubernetes/pki/etcd/etcd-peer.key
  trusted-ca-file: /etc/kubernetes/pki/etcd/etcd-ca.crt
EOF
```

**Expected Output**:
```
etcd configuration created for node 1
Configuration validated successfully
```

**Verification**:
```bash
# Start etcd cluster
systemctl start etcd
systemctl enable etcd

# Check etcd status
etcdctl --endpoints=https://10.0.1.10:2379 \
  --cacert=/etc/kubernetes/pki/etcd/etcd-ca.crt \
  --cert=/etc/kubernetes/pki/etcd/etcd-client.crt \
  --key=/etc/kubernetes/pki/etcd/etcd-client.key \
  endpoint health
```

#### **Day 3-4: Worker Node Configuration**

**Objective**: Configure worker node components for container management.

**Step 1.3: Kubelet Setup**
```bash
# Create kubelet configuration
cat > /var/lib/kubelet/config.yaml << EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
clusterDomain: cluster.local
clusterDNS:
  - 10.96.0.10
containerRuntimeEndpoint: unix:///run/containerd/containerd.sock
cgroupDriver: systemd
hairpinMode: promiscuous-bridge
maxPods: 110
podCIDR: 10.244.0.0/16
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m
serverTLSBootstrap: true
tlsCipherSuites:
  - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
  - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
  - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
  - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
EOF
```

**Expected Output**:
```
Kubelet configuration created
Configuration validated successfully
```

**Verification**:
```bash
# Start kubelet service
systemctl start kubelet
systemctl enable kubelet

# Check kubelet status
systemctl status kubelet
kubectl get nodes
```

#### **Day 5: Cluster Communication Setup**

**Objective**: Configure secure cluster communication and service discovery.

**Step 1.4: Service Discovery**
```bash
# Deploy CoreDNS
kubectl apply -f https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml

# Verify CoreDNS deployment
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

**Expected Output**:
```
CoreDNS deployed successfully
Service discovery configured
```

**Verification**:
```bash
# Test DNS resolution
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default
```

### **Week 2: Configuration Management**

#### **Day 6-7: ConfigMaps Setup**

**Objective**: Implement externalized configuration management.

**Step 2.1: Application Configuration**
```bash
# Create application ConfigMap
cat > app-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-app-config
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    component: configuration
    version: v1.0.0
data:
  # Database Configuration
  database.host: "postgresql-service"
  database.port: "5432"
  database.name: "ecommerce"
  database.pool.size: "20"
  database.pool.max: "100"
  
  # API Configuration
  api.host: "0.0.0.0"
  api.port: "8080"
  api.timeout: "30s"
  api.rate.limit: "1000"
  
  # Cache Configuration
  cache.host: "redis-service"
  cache.port: "6379"
  cache.ttl: "300s"
  cache.max.connections: "50"
  
  # Logging Configuration
  logging.level: "INFO"
  logging.format: "json"
  logging.output: "stdout"
  
  # Monitoring Configuration
  monitoring.enabled: "true"
  monitoring.port: "9090"
  monitoring.path: "/metrics"
EOF
```

**Expected Output**:
```
ConfigMap created successfully
Configuration validated
```

**Verification**:
```bash
# Apply ConfigMap
kubectl apply -f app-config.yaml

# Verify ConfigMap
kubectl get configmap ecommerce-app-config -n ecommerce -o yaml
```

#### **Day 8-9: Secrets Management**

**Objective**: Implement secure secret management.

**Step 2.2: Database Secrets**
```bash
# Create database secrets
cat > database-secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secrets
  namespace: ecommerce
  labels:
    app: postgresql
    component: secrets
    version: v1.0.0
type: Opaque
data:
  # Base64 encoded values
  username: cG9zdGdyZXM=  # postgres
  password: cG9zdGdyZXMxMjM=  # postgres123
  database: ZWNvbW1lcmNl  # ecommerce
  root-password: cm9vdDEyMw==  # root123
EOF
```

**Expected Output**:
```
Database secrets created successfully
Secrets validated
```

**Verification**:
```bash
# Apply database secrets
kubectl apply -f database-secrets.yaml

# Verify database secrets
kubectl get secret postgresql-secrets -n ecommerce -o yaml
```

#### **Day 10: Configuration Validation**

**Objective**: Validate configuration management setup.

**Step 2.3: Configuration Testing**
```bash
# Test configuration access
kubectl run config-test --image=busybox --rm -it --restart=Never -- \
  sh -c "echo 'Testing configuration access...' && \
         kubectl get configmap ecommerce-app-config -n ecommerce -o yaml"

# Test secret access
kubectl run secret-test --image=busybox --rm -it --restart=Never -- \
  sh -c "echo 'Testing secret access...' && \
         kubectl get secret postgresql-secrets -n ecommerce -o yaml"
```

**Expected Output**:
```
Configuration access working
Secret access working
Validation completed
```

---

## **🚀 Phase 2: Deployments & Scaling (Weeks 3-4)**

### **Week 3: Pod Management and Labeling**

#### **Day 11-12: Pod Lifecycle Management**

**Objective**: Implement comprehensive pod lifecycle management.

**Step 3.1: Pod Template Creation**
```bash
# Create pod template with health checks
cat > pod-template.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: ecommerce-backend-pod
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    component: api
    version: v1.0.0
    tier: backend
spec:
  # Security Context
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  
  # Init Containers
  initContainers:
  - name: database-init
    image: postgres:15-alpine
    command: ['sh', '-c']
    args:
    - |
      until pg_isready -h postgresql-service -p 5432; do
        echo "Waiting for database..."
        sleep 2
      done
      echo "Database is ready!"
    env:
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: postgresql-secrets
          key: password
  
  # Main Container
  containers:
  - name: ecommerce-backend
    image: ecommerce-backend:v1.0.0
    ports:
    - containerPort: 8080
      name: http
    - containerPort: 9090
      name: metrics
    
    # Environment Variables
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: ecommerce-app-config
          key: database.host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: ecommerce-app-config
          key: database.port
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgresql-secrets
          key: password
    
    # Resource Limits
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    
    # Health Checks
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
      successThreshold: 1
    
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 3
      successThreshold: 1
    
    # Lifecycle Hooks
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "sleep 15"]
    
    # Volume Mounts
    volumeMounts:
    - name: app-config
      mountPath: /etc/app/config
      readOnly: true
    - name: app-logs
      mountPath: /var/log/app
  
  # Volumes
  volumes:
  - name: app-config
    configMap:
      name: ecommerce-app-config
  - name: app-logs
    emptyDir: {}
  
  # Restart Policy
  restartPolicy: Always
  
  # Termination Grace Period
  terminationGracePeriodSeconds: 30
EOF
```

**Expected Output**:
```
Pod template created successfully
Configuration validated
```

**Verification**:
```bash
# Apply pod template
kubectl apply -f pod-template.yaml

# Verify pod status
kubectl get pods -n ecommerce

# Check pod health
kubectl describe pod ecommerce-backend-pod -n ecommerce
```

#### **Day 13-14: Labeling Strategy**

**Objective**: Implement consistent labeling strategy.

**Step 3.2: Apply Labels**
```bash
# Apply comprehensive labels to resources
kubectl label pods ecommerce-backend-pod -n ecommerce \
  app=ecommerce-backend \
  version=v1.0.0 \
  environment=production \
  component=api \
  tier=backend \
  role=api-server \
  owner=platform-team \
  cost-center=engineering \
  monitoring=enabled \
  logging=enabled \
  backup=enabled \
  security=high \
  business-unit=ecommerce \
  project=core-workloads \
  region=us-east-1 \
  datacenter=dc1

# Verify labels
kubectl get pods ecommerce-backend-pod -n ecommerce --show-labels
```

**Expected Output**:
```
pod/ecommerce-backend-pod labeled
Labels applied successfully
```

**Verification**:
```bash
# Verify all labels are applied
kubectl get pods ecommerce-backend-pod -n ecommerce --show-labels
```

### **Week 4: Deployment Strategies**

#### **Day 15-16: Rolling Update Deployment**

**Objective**: Implement zero-downtime rolling update deployment.

**Step 4.1: Rolling Update Deployment**
```bash
# Create rolling update deployment
cat > rolling-update-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend-deployment
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    component: api
    version: v1.0.0
    tier: backend
spec:
  # Replica Configuration
  replicas: 5
  minReadySeconds: 30
  
  # Rolling Update Strategy
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  
  # Selector
  selector:
    matchLabels:
      app: ecommerce-backend
      component: api
  
  # Pod Template
  template:
    metadata:
      labels:
        app: ecommerce-backend
        component: api
        version: v1.0.0
        tier: backend
    spec:
      # Security Context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        seccompProfile:
          type: RuntimeDefault
      
      # Init Containers
      initContainers:
      - name: database-init
        image: postgres:15-alpine
        command: ['sh', '-c']
        args:
        - |
          until pg_isready -h postgresql-service -p 5432; do
            echo "Waiting for database..."
            sleep 2
          done
          echo "Database is ready!"
        env:
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secrets
              key: password
      
      # Main Container
      containers:
      - name: ecommerce-backend
        image: ecommerce-backend:v1.0.0
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 9090
          name: metrics
        
        # Environment Variables
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: ecommerce-app-config
              key: database.host
        - name: DATABASE_PORT
          valueFrom:
            configMapKeyRef:
              name: ecommerce-app-config
              key: database.port
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-secrets
              key: password
        
        # Resource Limits
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Health Checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
        
        # Lifecycle Hooks
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
        
        # Volume Mounts
        volumeMounts:
        - name: app-config
          mountPath: /etc/app/config
          readOnly: true
        - name: app-logs
          mountPath: /var/log/app
      
      # Volumes
      volumes:
      - name: app-config
        configMap:
          name: ecommerce-app-config
      - name: app-logs
        emptyDir: {}
      
      # Termination Grace Period
      terminationGracePeriodSeconds: 30
EOF
```

**Expected Output**:
```
Rolling update deployment created successfully
Configuration validated
```

**Verification**:
```bash
# Apply rolling update deployment
kubectl apply -f rolling-update-deployment.yaml

# Verify deployment status
kubectl get deployments -n ecommerce

# Check rollout status
kubectl rollout status deployment/ecommerce-backend-deployment -n ecommerce
```

#### **Day 17-18: Auto-Scaling Configuration**

**Objective**: Implement horizontal pod autoscaling.

**Step 4.2: HPA Configuration**
```bash
# Create Horizontal Pod Autoscaler
cat > hpa-config.yaml << EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecommerce-backend-hpa
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    component: autoscaler
    version: v1.0.0
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend-deployment
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Pods
        value: 2
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
EOF
```

**Expected Output**:
```
HPA configuration created successfully
Configuration validated
```

**Verification**:
```bash
# Apply HPA configuration
kubectl apply -f hpa-config.yaml

# Verify HPA status
kubectl get hpa -n ecommerce

# Check HPA metrics
kubectl describe hpa ecommerce-backend-hpa -n ecommerce
```

#### **Day 19-20: Deployment Validation**

**Objective**: Validate deployment strategies and auto-scaling.

**Step 4.3: Deployment Testing**
```bash
# Test rolling update
kubectl set image deployment/ecommerce-backend-deployment \
  ecommerce-backend=ecommerce-backend:v1.1.0 -n ecommerce

# Monitor rollout
kubectl rollout status deployment/ecommerce-backend-deployment -n ecommerce

# Test rollback
kubectl rollout undo deployment/ecommerce-backend-deployment -n ecommerce

# Test auto-scaling
kubectl run load-test --image=busybox --rm -it --restart=Never -- \
  sh -c "while true; do wget -q -O- http://ecommerce-backend-service:8080/health; sleep 1; done"
```

**Expected Output**:
```
Rolling update completed successfully
Rollback completed successfully
Auto-scaling working correctly
```

**Verification**:
```bash
# Verify deployment status
kubectl get deployments -n ecommerce

# Check pod replicas
kubectl get pods -n ecommerce

# Verify HPA scaling
kubectl get hpa -n ecommerce
```

---

## **✅ Deployment Validation**

### **Validation Checklist**

#### **Phase 1: Architecture & Configuration**
- [ ] Kubernetes cluster configured with high availability
- [ ] etcd cluster deployed with 3 nodes
- [ ] Worker nodes configured with kubelet
- [ ] ConfigMaps created for application configuration
- [ ] Secrets created for sensitive data
- [ ] Service discovery working with CoreDNS

#### **Phase 2: Deployments & Scaling**
- [ ] Pod lifecycle management implemented
- [ ] Health checks working correctly
- [ ] Labeling strategy applied consistently
- [ ] Rolling update deployment working
- [ ] Auto-scaling configured and functional
- [ ] Performance targets met

### **Performance Validation**

#### **Response Time Targets**
| Component | Target | Current | Status |
|-----------|--------|---------|--------|
| **API Endpoints** | < 100ms | TBD | ⏳ |
| **Database Queries** | < 50ms | TBD | ⏳ |
| **Cache Operations** | < 10ms | TBD | ⏳ |
| **Deployment Time** | < 5 minutes | TBD | ⏳ |
| **Rollback Time** | < 2 minutes | TBD | ⏳ |

#### **Availability Targets**
| Component | Target | Current | Status |
|-----------|--------|---------|--------|
| **Overall Platform** | 99.95% | TBD | ⏳ |
| **Critical Services** | 99.9% | TBD | ⏳ |
| **Database** | 99.99% | TBD | ⏳ |
| **Monitoring** | 99.9% | TBD | ⏳ |

---

## **📞 Support and Troubleshooting**

### **Common Issues**

#### **1. Pod Startup Issues**
```bash
# Check pod status
kubectl get pods -n ecommerce

# Check pod logs
kubectl logs ecommerce-backend-pod -n ecommerce

# Check pod events
kubectl describe pod ecommerce-backend-pod -n ecommerce
```

#### **2. Configuration Issues**
```bash
# Check ConfigMap
kubectl get configmap ecommerce-app-config -n ecommerce -o yaml

# Check Secrets
kubectl get secret postgresql-secrets -n ecommerce -o yaml

# Test configuration access
kubectl exec -it ecommerce-backend-pod -n ecommerce -- env | grep DATABASE
```

#### **3. Deployment Issues**
```bash
# Check deployment status
kubectl get deployments -n ecommerce

# Check rollout history
kubectl rollout history deployment/ecommerce-backend-deployment -n ecommerce

# Check HPA status
kubectl get hpa -n ecommerce
```

### **Escalation Path**
1. **Level 1**: Check logs and basic troubleshooting
2. **Level 2**: Contact platform engineering team
3. **Level 3**: Escalate to technical lead
4. **Level 4**: Escalate to project manager

---

**Document Control**: This document is controlled and maintained by the Project Management Office. Any changes require approval from the Project Sponsor and Technical Lead.

**Last Updated**: December 2024  
**Next Review**: January 2025  
**Document Owner**: Senior Kubernetes Architect
