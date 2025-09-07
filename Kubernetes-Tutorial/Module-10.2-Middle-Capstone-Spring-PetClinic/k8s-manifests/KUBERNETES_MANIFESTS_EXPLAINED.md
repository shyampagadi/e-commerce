# 📋 **Kubernetes Manifests Comprehensive Guide**
## *Spring PetClinic Microservices Platform*

**Document Version**: 1.0.0  
**Date**: December 2024  
**Purpose**: Complete explanation of all Kubernetes manifests and configurations  
**Audience**: DevOps Engineers, Kubernetes Administrators, Developers  

---

## 📖 **Table of Contents**

1. [Overview](#overview)
2. [Namespace Configuration](#namespace-configuration)
3. [Database Deployments](#database-deployments)
4. [Service Deployments](#service-deployments)
5. [Networking Configuration](#networking-configuration)
6. [Security Configuration](#security-configuration)
7. [Storage Configuration](#storage-configuration)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 **Overview**

This document provides comprehensive documentation for all Kubernetes manifests used in the Spring PetClinic Microservices Platform. Each manifest is explained in detail with configuration options, security considerations, and operational best practices.

### **Manifest Structure**
```
k8s-manifests/
├── namespaces/           # Namespace definitions
├── databases/            # Database StatefulSets and services
├── services/             # Microservice deployments
├── networking/           # Network policies and ingress
├── security/             # RBAC and security policies
└── storage/              # Persistent volume configurations
```

---

## 🏠 **Namespace Configuration**

### **File: `namespaces/petclinic-namespace.yml`**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: petclinic
  labels:
    name: petclinic
    environment: production
    project: spring-petclinic
    version: v1.0.0
  annotations:
    description: "Spring PetClinic Microservices Platform"
    contact: "devops@petclinic.com"
    created-by: "DevOps Team"
spec:
  finalizers:
    - kubernetes
```

**Purpose**: Creates an isolated namespace for the PetClinic application

**Key Features**:
- ✅ **Isolation**: Separates PetClinic resources from other applications
- ✅ **Resource Management**: Enables namespace-level resource quotas
- ✅ **Security**: Provides security boundary for RBAC policies
- ✅ **Organization**: Groups related resources logically

**Labels Explained**:
- `name`: Primary identifier for the namespace
- `environment`: Deployment environment (dev/staging/production)
- `project`: Project identifier for resource grouping
- `version`: Application version for tracking

**Annotations Explained**:
- `description`: Human-readable description of the namespace
- `contact`: Contact information for the namespace owner
- `created-by`: Team or person responsible for the namespace

---

## 🗄️ **Database Deployments**

### **MySQL Customer Database**

**File: `databases/mysql-customer/mysql-customers-deployment.yml`**

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-customer
  namespace: petclinic
  labels:
    app: mysql-customer
    component: database
    tier: data
spec:
  serviceName: mysql-customer
  replicas: 1
  selector:
    matchLabels:
      app: mysql-customer
  template:
    metadata:
      labels:
        app: mysql-customer
        component: database
        tier: data
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: root-password
        - name: MYSQL_DATABASE
          value: "petclinic_customer"
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: password
        volumeMounts:
        - name: mysql-customer-storage
          mountPath: /var/lib/mysql
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - mysqladmin
            - ping
            - -h
            - localhost
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
            - mysql
            - -h
            - localhost
            - -u
            - root
            - -p$MYSQL_ROOT_PASSWORD
            - -e
            - "SELECT 1"
          initialDelaySeconds: 5
          periodSeconds: 2
          timeoutSeconds: 1
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
  volumeClaimTemplates:
  - metadata:
      name: mysql-customer-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
      storageClassName: fast-ssd
```

**StatefulSet vs Deployment Choice**:
- ✅ **StatefulSet**: Chosen for databases to ensure:
  - Stable, unique network identifiers
  - Stable, persistent storage
  - Ordered, graceful deployment and scaling
  - Ordered, automated rolling updates

**Key Configuration Sections**:

#### **Container Configuration**
- **Image**: `mysql:8.0` - Latest stable MySQL version
- **Port**: `3306` - Standard MySQL port
- **Environment Variables**: Configured via Kubernetes secrets for security

#### **Resource Management**
```yaml
resources:
  requests:
    memory: "512Mi"    # Minimum memory required
    cpu: "250m"        # Minimum CPU required (0.25 cores)
  limits:
    memory: "1Gi"      # Maximum memory allowed
    cpu: "500m"        # Maximum CPU allowed (0.5 cores)
```

**Resource Sizing Rationale**:
- **Requests**: Guaranteed resources for stable operation
- **Limits**: Prevents resource starvation of other pods
- **Memory**: Sized for typical small-to-medium database workloads
- **CPU**: Allows for burst capacity during peak operations

#### **Health Checks**
```yaml
livenessProbe:
  exec:
    command: ["mysqladmin", "ping", "-h", "localhost"]
  initialDelaySeconds: 30  # Wait 30s for MySQL to start
  periodSeconds: 10        # Check every 10 seconds
  timeoutSeconds: 5        # Timeout after 5 seconds

readinessProbe:
  exec:
    command: ["mysql", "-h", "localhost", "-u", "root", "-p$MYSQL_ROOT_PASSWORD", "-e", "SELECT 1"]
  initialDelaySeconds: 5   # Start checking after 5 seconds
  periodSeconds: 2         # Check every 2 seconds
  timeoutSeconds: 1        # Timeout after 1 second
```

**Health Check Strategy**:
- **Liveness Probe**: Ensures MySQL process is running
- **Readiness Probe**: Ensures MySQL is ready to accept connections
- **Different Commands**: Liveness uses `mysqladmin ping`, readiness uses actual SQL query

#### **Storage Configuration**
```yaml
volumeClaimTemplates:
- metadata:
    name: mysql-customer-storage
  spec:
    accessModes: ["ReadWriteOnce"]
    resources:
      requests:
        storage: 10Gi
    storageClassName: fast-ssd
```

**Storage Design**:
- **Volume Claim Templates**: Creates persistent storage per StatefulSet replica
- **Access Mode**: `ReadWriteOnce` - Single node access (appropriate for databases)
- **Storage Size**: `10Gi` - Adequate for small-to-medium datasets
- **Storage Class**: `fast-ssd` - High-performance storage for database workloads

---

## 🔧 **Service Deployments**

### **API Gateway Deployment**

**File: `services/api-gateway/api-gateway-deployment.yml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: petclinic
  labels:
    app: api-gateway
    component: gateway
    tier: frontend
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
        component: gateway
        tier: frontend
    spec:
      containers:
      - name: api-gateway
        image: springcommunity/spring-petclinic-api-gateway:latest
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: CONFIG_SERVER_URL
          value: "http://config-server:8888"
        - name: DISCOVERY_SERVER_URL
          value: "http://discovery-server:8761/eureka"
        - name: SPRING_PROFILES_ACTIVE
          value: "kubernetes"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: petclinic
  labels:
    app: api-gateway
    component: gateway
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: api-gateway
```

**Deployment vs StatefulSet Choice**:
- ✅ **Deployment**: Chosen for stateless services because:
  - No persistent storage requirements
  - Pods are interchangeable
  - Supports rolling updates easily
  - Better for horizontal scaling

**Key Configuration Sections**:

#### **Replica and Update Strategy**
```yaml
replicas: 2
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1    # Maximum pods unavailable during update
    maxSurge: 1          # Maximum extra pods during update
```

**Strategy Explanation**:
- **2 Replicas**: Provides high availability and load distribution
- **Rolling Update**: Zero-downtime deployments
- **maxUnavailable: 1**: Ensures at least 1 pod always available
- **maxSurge: 1**: Allows temporary scaling to 3 pods during updates

#### **Environment Configuration**
```yaml
env:
- name: CONFIG_SERVER_URL
  value: "http://config-server:8888"
- name: DISCOVERY_SERVER_URL
  value: "http://discovery-server:8761/eureka"
- name: SPRING_PROFILES_ACTIVE
  value: "kubernetes"
```

**Environment Variables Explained**:
- **CONFIG_SERVER_URL**: Points to centralized configuration service
- **DISCOVERY_SERVER_URL**: Eureka service registry endpoint
- **SPRING_PROFILES_ACTIVE**: Activates Kubernetes-specific configuration

#### **Security Context**
```yaml
securityContext:
  runAsNonRoot: true           # Don't run as root user
  runAsUser: 1000              # Run as specific non-root user
  allowPrivilegeEscalation: false  # Prevent privilege escalation
  readOnlyRootFilesystem: true     # Make root filesystem read-only
  capabilities:
    drop:
    - ALL                      # Drop all Linux capabilities
```

**Security Hardening**:
- **Non-root execution**: Reduces attack surface
- **Specific user ID**: Consistent user across environments
- **No privilege escalation**: Prevents container breakout attempts
- **Read-only filesystem**: Prevents runtime modifications
- **Dropped capabilities**: Minimal required permissions

#### **Service Configuration**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: api-gateway
```

**Service Type Explanation**:
- **ClusterIP**: Internal cluster access only
- **Port Mapping**: External port 8080 → Container port 8080
- **Selector**: Routes traffic to pods with `app: api-gateway` label

---

## 🌐 **Networking Configuration**

### **Network Policies**

**File: `networking/network-policies.yml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: petclinic-network-policy
  namespace: petclinic
spec:
  podSelector: {}  # Apply to all pods in namespace
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          component: gateway
    ports:
    - protocol: TCP
      port: 8080
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 8080
    - protocol: TCP
      port: 8761
    - protocol: TCP
      port: 8888
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: data
    ports:
    - protocol: TCP
      port: 3306
  - to: []  # Allow all egress for external dependencies
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
```

**Network Policy Explanation**:

#### **Policy Scope**
- **podSelector: {}**: Applies to all pods in the `petclinic` namespace
- **policyTypes**: Controls both ingress (incoming) and egress (outgoing) traffic

#### **Ingress Rules**
1. **External Access**: Allows ingress from nginx-ingress namespace
2. **Internal Communication**: Allows communication between application tiers
3. **Service Ports**: Permits access to standard service ports (8080, 8761, 8888)

#### **Egress Rules**
1. **Database Access**: Allows connection to database tier (port 3306)
2. **External Dependencies**: Permits DNS resolution and HTTPS/HTTP traffic
3. **DNS**: Allows both TCP and UDP DNS queries (port 53)

**Security Benefits**:
- ✅ **Micro-segmentation**: Restricts traffic between pods
- ✅ **Defense in Depth**: Additional security layer beyond RBAC
- ✅ **Compliance**: Meets security requirements for network isolation
- ✅ **Attack Surface Reduction**: Limits potential attack vectors

---

## 🔒 **Security Configuration**

### **RBAC Configuration**

**File: `security/rbac.yml`**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: petclinic-service-account
  namespace: petclinic
  labels:
    app: petclinic
    component: security
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: petclinic
  name: petclinic-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: petclinic-role-binding
  namespace: petclinic
subjects:
- kind: ServiceAccount
  name: petclinic-service-account
  namespace: petclinic
roleRef:
  kind: Role
  name: petclinic-role
  apiGroup: rbac.authorization.k8s.io
```

**RBAC Components Explained**:

#### **Service Account**
- **Purpose**: Provides identity for pods to access Kubernetes API
- **Scope**: Limited to `petclinic` namespace
- **Usage**: Assigned to pods that need Kubernetes API access

#### **Role Permissions**
```yaml
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
```

**Permission Breakdown**:
- **Resources**: Core Kubernetes resources needed by the application
- **Verbs**: Read-only operations (get, list, watch)
- **Principle of Least Privilege**: Only necessary permissions granted

#### **Role Binding**
- **Links**: Service account to role permissions
- **Scope**: Namespace-level binding
- **Security**: Prevents privilege escalation outside namespace

---

## 💾 **Storage Configuration**

### **Persistent Volume Claims**

**Storage Classes Used**:
```yaml
# Fast SSD Storage Class (for databases)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs  # AWS EBS example
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
```

**Storage Strategy**:
- ✅ **Performance**: SSD storage for database workloads
- ✅ **Scalability**: Volume expansion enabled
- ✅ **Data Protection**: Retain policy prevents accidental deletion
- ✅ **Efficiency**: WaitForFirstConsumer binding mode

---

## 🎯 **Best Practices**

### **Resource Management**
1. **Always set resource requests and limits**
2. **Use appropriate resource ratios** (CPU:Memory)
3. **Monitor resource usage** and adjust as needed
4. **Implement horizontal pod autoscaling** for stateless services

### **Security**
1. **Use non-root containers** whenever possible
2. **Implement network policies** for traffic control
3. **Store sensitive data in secrets**, not ConfigMaps
4. **Regular security scanning** of container images
5. **Apply security contexts** to all pods

### **High Availability**
1. **Run multiple replicas** for critical services
2. **Use anti-affinity rules** to spread pods across nodes
3. **Implement proper health checks** (liveness and readiness)
4. **Plan for rolling updates** with appropriate strategies

### **Monitoring**
1. **Expose metrics endpoints** (/actuator/prometheus)
2. **Implement structured logging** with correlation IDs
3. **Set up alerting** for critical metrics
4. **Use distributed tracing** for complex request flows

---

## 🔧 **Troubleshooting**

### **Common Issues and Solutions**

#### **Pod Startup Issues**
```bash
# Check pod status
kubectl get pods -n petclinic

# Describe pod for events
kubectl describe pod <pod-name> -n petclinic

# Check logs
kubectl logs <pod-name> -n petclinic
```

#### **Service Discovery Issues**
```bash
# Check service endpoints
kubectl get endpoints -n petclinic

# Test service connectivity
kubectl exec -it <pod-name> -n petclinic -- curl http://service-name:port/actuator/health
```

#### **Database Connection Issues**
```bash
# Check database pod status
kubectl get pods -n petclinic -l tier=data

# Test database connectivity
kubectl exec -it mysql-customer-0 -n petclinic -- mysql -u root -p -e "SELECT 1"

# Check persistent volume claims
kubectl get pvc -n petclinic
```

#### **Network Policy Issues**
```bash
# Check network policies
kubectl get networkpolicies -n petclinic

# Describe network policy
kubectl describe networkpolicy petclinic-network-policy -n petclinic

# Test connectivity between pods
kubectl exec -it <source-pod> -n petclinic -- nc -zv <target-service> <port>
```

### **Performance Optimization**

#### **Resource Tuning**
1. **Monitor actual resource usage**:
   ```bash
   kubectl top pods -n petclinic
   kubectl top nodes
   ```

2. **Adjust resource requests/limits** based on usage patterns

3. **Implement Horizontal Pod Autoscaler**:
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: api-gateway-hpa
     namespace: petclinic
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: api-gateway
     minReplicas: 2
     maxReplicas: 10
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
   ```

#### **Database Optimization**
1. **Monitor database performance**
2. **Optimize MySQL configuration** via ConfigMaps
3. **Consider read replicas** for read-heavy workloads
4. **Implement connection pooling** in applications

---

## 📚 **Additional Resources**

### **Documentation Links**
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Spring Boot Kubernetes Guide](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [MySQL on Kubernetes Best Practices](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/)

### **Monitoring and Observability**
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Jaeger Tracing](https://www.jaegertracing.io/)

### **Security Resources**
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)

---

**Document Maintenance**: This document should be updated whenever Kubernetes manifests are modified. All changes should be reviewed by the DevOps team and tested in staging before production deployment.
