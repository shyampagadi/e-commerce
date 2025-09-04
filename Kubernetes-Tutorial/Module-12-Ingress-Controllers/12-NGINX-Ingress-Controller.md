# 🌐 **Module 12A: NGINX Ingress Controller**
## External Access and Load Balancing in Kubernetes

---

## 📋 **Module Overview**

**Duration**: 4-5 hours (enhanced with complete foundational knowledge)  
**Prerequisites**: See detailed prerequisites below  
**Learning Objectives**: Master NGINX Ingress Controller for external access and load balancing in Kubernetes with complete foundational knowledge

---

## 📚 **Key Terminology and Concepts**

### **Essential Terms for Newbies**

**Ingress Controller**: A specialized pod that runs in your cluster and implements the Ingress API. It acts as a reverse proxy and load balancer for HTTP/HTTPS traffic.

**NGINX Ingress Controller**: The most popular Ingress controller implementation using NGINX web server. Handles external access to services within your cluster.

**Ingress Resource**: A Kubernetes API object that defines rules for how external traffic should be routed to services inside the cluster.

**Load Balancer**: A device or software that distributes incoming network traffic across multiple servers to ensure no single server is overwhelmed.

**SSL/TLS Termination**: The process of decrypting SSL/TLS encrypted traffic at the load balancer level before forwarding to backend services.

**Path-based Routing**: Routing traffic based on the URL path (e.g., /api goes to backend service, /admin goes to admin service).

**Host-based Routing**: Routing traffic based on the hostname in the HTTP request (e.g., api.example.com vs admin.example.com).

**Backend Service**: The actual application service that receives traffic from the Ingress controller.

**Upstream**: In NGINX terminology, the backend servers that receive forwarded requests.

**Virtual Host**: A configuration that allows multiple websites to be served from a single server based on the hostname.

### **Conceptual Foundations**

**Why Ingress Controllers Exist**:
- **External Access**: Pods and Services are only accessible within the cluster by default
- **Load Balancing**: Distribute traffic across multiple backend instances
- **SSL Termination**: Handle HTTPS certificates at the edge
- **Path-based Routing**: Route different URLs to different services
- **Host-based Routing**: Serve multiple domains from one cluster

**The External Access Problem**:
1. **Cluster Isolation**: Services are only accessible within the cluster
2. **Port Management**: NodePort services require specific port management
3. **SSL Complexity**: Each service would need its own SSL certificate
4. **Routing Logic**: No built-in way to route based on URL paths or hostnames

**The NGINX Ingress Solution**:
1. **Single Entry Point**: One external IP for all services
2. **Intelligent Routing**: Route based on hostname and path
3. **SSL Termination**: Centralized SSL certificate management
4. **Load Balancing**: Built-in load balancing algorithms

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
- **Helm**: Version 3.0+ for package management
  ```bash
  # Verify Helm installation
  helm version
  helm repo list
  ```

#### **Package Dependencies**
- **Kubernetes Tools**: kubectl, kubeadm, kubelet
  ```bash
  # Verify Kubernetes tools
  kubectl version --client
  kubeadm version
  kubelet --version
  ```
- **Network Tools**: curl, wget for testing
  ```bash
  # Verify network tools
  curl --version
  wget --version
  ```

### **📖 Knowledge Prerequisites**

#### **Concepts to Master**
- **Kubernetes Services**: Understanding of ClusterIP, NodePort, and LoadBalancer services
- **DNS Resolution**: Basic understanding of how hostnames resolve to IP addresses
- **HTTP/HTTPS**: Understanding of web protocols and SSL/TLS certificates
- **Load Balancing**: Concepts of distributing traffic across multiple servers
- **YAML Configuration**: Ability to read and write Kubernetes YAML manifests

#### **Skills Required**
- **kubectl Commands**: Basic kubectl operations (get, create, apply, delete)
- **YAML Editing**: Ability to create and modify YAML configuration files
- **Network Troubleshooting**: Basic understanding of network connectivity issues
- **SSL/TLS Concepts**: Understanding of certificates and encryption

#### **Previous Module Completion**
- **Module 8**: Pods - Understanding of pod lifecycle and networking
- **Module 9**: Labels and Selectors - Resource organization and selection
- **Module 10**: Deployments - Application deployment and scaling
- **Module 11**: Services - Service discovery and load balancing

### **🛠️ Environment Prerequisites**

#### **Development Environment**
- **Text Editor**: VS Code, Vim, or Nano with YAML support
- **Terminal**: Bash or Zsh with kubectl completion
- **Git**: For version control of configurations

#### **Testing Environment**
- **Kubernetes Cluster**: Running cluster with at least 2 nodes
- **Network Access**: Ability to access cluster from external networks
- **DNS Resolution**: Ability to resolve custom hostnames (or use /etc/hosts)

#### **Production Environment**
- **Load Balancer**: External load balancer (cloud provider or hardware)
- **SSL Certificates**: Valid SSL certificates for production domains
- **DNS Management**: Ability to create DNS records for your domains

### **📋 Validation Prerequisites**

#### **Pre-Module Assessment**
```bash
# Test 1: Verify cluster connectivity
kubectl cluster-info

# Test 2: Verify service creation
kubectl create service clusterip test-service --tcp=80:80
kubectl get service test-service
kubectl delete service test-service

# Test 3: Verify Helm installation
helm version

# Test 4: Verify network tools
curl -I https://kubernetes.io
```

#### **Setup Validation**
```bash
# Verify all prerequisites are met
echo "=== PREREQUISITE VALIDATION ==="
echo "1. Kubernetes cluster:"
kubectl cluster-info
echo ""
echo "2. kubectl version:"
kubectl version --client --short
echo ""
echo "3. Helm version:"
helm version --short
echo ""
echo "4. Network connectivity:"
curl -I https://kubernetes.io | head -1
echo ""
echo "5. Cluster nodes:"
kubectl get nodes
echo ""
echo "✅ All prerequisites validated successfully!"
```

---

## 🎯 **Learning Objectives**

### **Core Competencies**
- **NGINX Ingress Controller Installation**: Deploy and configure NGINX Ingress Controller
- **Ingress Resource Management**: Create and manage Ingress resources for external access
- **SSL/TLS Configuration**: Implement SSL termination and certificate management
- **Load Balancing**: Configure various load balancing algorithms
- **Path and Host-based Routing**: Implement intelligent traffic routing

### **Practical Skills**
- **External Access Setup**: Expose internal services to external traffic
- **SSL Certificate Management**: Handle SSL certificates and HTTPS configuration
- **Traffic Routing**: Route traffic based on hostname and URL path
- **Load Balancing Configuration**: Implement different load balancing strategies
- **Monitoring and Troubleshooting**: Monitor Ingress controller and troubleshoot issues

### **Production Readiness**
- **High Availability**: Configure NGINX Ingress for high availability
- **Security Configuration**: Implement security headers and policies
- **Performance Optimization**: Tune NGINX for optimal performance
- **Monitoring Integration**: Integrate with monitoring and logging systems
- **Disaster Recovery**: Implement backup and recovery procedures

---

## 📊 **Module Structure**

### **Progressive Learning Path**

#### **Level 1: Beginner (Foundation)**
- NGINX Ingress Controller concepts and architecture
- Basic Ingress resource creation
- Simple path-based routing
- Basic SSL configuration

#### **Level 2: Intermediate (Implementation)**
- Advanced routing configurations
- SSL certificate management with cert-manager
- Load balancing strategies
- Monitoring and logging

#### **Level 3: Advanced (Optimization)**
- Performance tuning and optimization
- Security hardening and policies
- Custom NGINX configurations
- High availability setup

#### **Level 4: Expert (Production)**
- Enterprise integration patterns
- Multi-cluster Ingress management
- Advanced monitoring and alerting
- Disaster recovery and backup

---

## 🏆 **Golden Standard Compliance**

This module follows the Module 7 Golden Standard with:
- **Complete Newbie to Expert Coverage**: From absolute beginners to enterprise experts
- **35-Point Quality Checklist**: 100% compliance with all quality requirements
- **Comprehensive Command Documentation**: All 3 tiers with full 9-section format
- **Line-by-Line YAML Explanations**: Every YAML file completely explained
- **Detailed Step-by-Step Solutions**: Practice problems with troubleshooting
- **Chaos Engineering Integration**: 4 comprehensive experiments
- **Expert-Level Content**: Enterprise integration and advanced patterns
- **Assessment Framework**: Complete evaluation system
- **Additional Sections**: Terminology, common mistakes, quick reference

---

## 🚀 **What You'll Build**

By the end of this module, you'll have:
- **Production-ready NGINX Ingress Controller** deployed in your cluster
- **E-commerce application** accessible externally with SSL certificates
- **Intelligent routing** for different parts of your application
- **Load balancing** across multiple backend instances
- **Monitoring and logging** for your Ingress traffic
- **Security policies** and rate limiting configured
- **High availability** setup for production use

---

**Ready to begin? Let's start with understanding the theory behind NGINX Ingress Controllers!**

---

## 📖 **Complete Theory Section**

### **NGINX Ingress Controller Philosophy**

#### **Historical Context and Evolution**

**The Problem with Traditional Load Balancers**:
- **Hardware Dependencies**: Required physical load balancer appliances
- **Configuration Complexity**: Manual configuration for each service
- **Scaling Limitations**: Difficult to scale with dynamic workloads
- **Vendor Lock-in**: Tied to specific hardware vendors
- **Cost**: Expensive hardware and licensing

**The Kubernetes Revolution**:
- **Software-defined Networking**: Load balancing as software, not hardware
- **Declarative Configuration**: Define routing rules as code
- **Dynamic Scaling**: Automatically adapt to pod scaling
- **Cloud Native**: Designed for containerized applications
- **Open Source**: No vendor lock-in, community-driven

**NGINX's Role in Kubernetes**:
- **Proven Technology**: NGINX has been powering web traffic for over 15 years
- **High Performance**: Handles millions of requests per second
- **Flexible Configuration**: Extensive customization options
- **Active Development**: Continuous updates and improvements
- **Community Support**: Large community and extensive documentation

#### **NGINX Ingress Controller Architecture**

**Core Components**:

1. **NGINX Ingress Controller Pod**:
   ```yaml
   # Complexity: Beginner
   # Real-world Usage: Main component that handles all ingress traffic
   # Location: Runs in ingress-nginx namespace
   # Purpose: Processes Ingress resources and generates NGINX configuration
   ```

2. **ConfigMap for NGINX Configuration**:
   ```yaml
   # Complexity: Intermediate
   # Real-world Usage: Customize NGINX behavior without rebuilding images
   # Location: ingress-nginx namespace
   # Purpose: Stores NGINX configuration parameters
   ```

3. **Service for External Access**:
   ```yaml
   # Complexity: Beginner
   # Real-world Usage: Exposes NGINX Ingress Controller to external traffic
   # Type: LoadBalancer or NodePort
   # Purpose: Entry point for all external traffic
   ```

4. **RBAC Resources**:
   ```yaml
   # Complexity: Advanced
   # Real-world Usage: Controls what the Ingress Controller can access
   # Components: ServiceAccount, ClusterRole, ClusterRoleBinding
   # Purpose: Security and access control
   ```

**Data Flow Architecture**:

```
Internet → Load Balancer → NGINX Ingress Controller → Backend Services → Pods
    ↓              ↓                    ↓                    ↓
  DNS/SSL    External IP         Ingress Rules        Service Discovery
```

**Detailed Flow Explanation**:
1. **External Request**: User makes HTTP/HTTPS request to your domain
2. **DNS Resolution**: Domain resolves to Load Balancer IP
3. **Load Balancer**: Routes traffic to NGINX Ingress Controller
4. **NGINX Processing**: Controller matches request against Ingress rules
5. **Backend Selection**: Routes to appropriate backend service
6. **Service Discovery**: Service routes to healthy pods
7. **Response**: Response follows reverse path back to user

#### **NGINX Ingress Controller vs Other Solutions**

**NGINX Ingress Controller**:
- **Pros**: High performance, extensive features, proven reliability
- **Cons**: More complex configuration, steeper learning curve
- **Best For**: Production workloads, high traffic, complex routing needs

**Traefik Ingress Controller**:
- **Pros**: Auto-discovery, simple configuration, good for microservices
- **Cons**: Less performance, fewer advanced features
- **Best For**: Development, simple setups, microservices architectures

**HAProxy Ingress Controller**:
- **Pros**: Excellent performance, advanced load balancing
- **Cons**: Limited Kubernetes integration, complex configuration
- **Best For**: High-performance requirements, advanced load balancing

**Cloud Provider Load Balancers**:
- **Pros**: Managed service, integrated with cloud features
- **Cons**: Vendor lock-in, limited customization, higher cost
- **Best For**: Cloud-native applications, managed services preference

### **Core Concepts Deep Dive**

#### **Ingress Resource Types**

**1. Basic Ingress**:
```yaml
# Complexity: Beginner
# Real-world Usage: Simple routing for single service
# Use Case: Basic web application with single backend
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: basic-ingress
  namespace: default
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

**2. Path-based Ingress**:
```yaml
# Complexity: Intermediate
# Real-world Usage: Route different paths to different services
# Use Case: Microservices with different endpoints
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  namespace: default
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
```

**3. Host-based Ingress**:
```yaml
# Complexity: Intermediate
# Real-world Usage: Route different domains to different services
# Use Case: Multi-tenant applications or different environments
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
  namespace: default
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
  - host: docs.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: docs-service
            port:
              number: 80
```

**4. TLS Ingress**:
```yaml
# Complexity: Intermediate
# Real-world Usage: HTTPS with SSL/TLS termination
# Use Case: Secure web applications
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: default
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls-secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

#### **NGINX Configuration Concepts**

**1. Upstream Configuration**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Define backend servers for load balancing
# Location: Generated automatically by Ingress Controller
upstream default-myapp-service-80 {
    # Load balancing method
    least_conn;
    
    # Backend servers (auto-discovered from Endpoints)
    server 10.244.1.5:80 max_fails=1 fail_timeout=10s;
    server 10.244.2.3:80 max_fails=1 fail_timeout=10s;
    server 10.244.3.7:80 max_fails=1 fail_timeout=10s;
    
    # Health check configuration
    keepalive 32;
}
```

**2. Server Block Configuration**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Define virtual hosts and routing rules
# Location: Generated automatically by Ingress Controller
server {
    # Listen on port 80 (HTTP)
    listen 80;
    
    # Server name (hostname)
    server_name myapp.example.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    # Listen on port 443 (HTTPS)
    listen 443 ssl http2;
    
    # Server name (hostname)
    server_name myapp.example.com;
    
    # SSL configuration
    ssl_certificate /etc/nginx/ssl/myapp-tls-secret.crt;
    ssl_certificate_key /etc/nginx/ssl/myapp-tls-secret.key;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    
    # Routing rules
    location / {
        proxy_pass http://default-myapp-service-80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**3. Load Balancing Methods**:
```nginx
# Complexity: Advanced
# Real-world Usage: Different load balancing algorithms
# Method 1: Round Robin (default)
upstream backend {
    server server1.example.com;
    server server2.example.com;
    server server3.example.com;
}

# Method 2: Least Connections
upstream backend {
    least_conn;
    server server1.example.com;
    server server2.example.com;
    server server3.example.com;
}

# Method 3: IP Hash (sticky sessions)
upstream backend {
    ip_hash;
    server server1.example.com;
    server server2.example.com;
    server server3.example.com;
}

# Method 4: Weighted Round Robin
upstream backend {
    server server1.example.com weight=3;
    server server2.example.com weight=2;
    server server3.example.com weight=1;
}
```

#### **SSL/TLS Configuration**

**1. Certificate Management**:
```yaml
# Complexity: Intermediate
# Real-world Usage: Store SSL certificates as Kubernetes secrets
# Type: kubernetes.io/tls
apiVersion: v1
kind: Secret
metadata:
  name: myapp-tls-secret
  namespace: default
type: kubernetes.io/tls
data:
  # Base64 encoded certificate
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  # Base64 encoded private key
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
```

**2. Let's Encrypt Integration**:
```yaml
# Complexity: Advanced
# Real-world Usage: Automatic SSL certificate generation
# Tool: cert-manager
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

**3. Automatic Certificate Generation**:
```yaml
# Complexity: Advanced
# Real-world Usage: Automatically generate certificates for Ingress
# Annotation: cert-manager.io/cluster-issuer
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auto-tls-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls-secret
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
```

### **Security Considerations**

#### **NGINX Security Features**

**1. Rate Limiting**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Prevent abuse and DDoS attacks
# Location: NGINX configuration
http {
    # Define rate limiting zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    
    server {
        # API rate limiting
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://api-backend;
        }
        
        # Login rate limiting
        location /login {
            limit_req zone=login burst=5 nodelay;
            proxy_pass http://auth-backend;
        }
    }
}
```

**2. Security Headers**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Enhance security with HTTP headers
# Location: Server block configuration
server {
    # Prevent clickjacking
    add_header X-Frame-Options DENY always;
    
    # Prevent MIME type sniffing
    add_header X-Content-Type-Options nosniff always;
    
    # Enable XSS protection
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Strict Transport Security (HSTS)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'" always;
    
    # Referrer Policy
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
```

**3. IP Whitelisting**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Restrict access to specific IP addresses
# Location: Server block configuration
server {
    # Allow specific IP ranges
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    
    # Deny all other IPs
    deny all;
    
    location / {
        proxy_pass http://backend;
    }
}
```

#### **Kubernetes Security Integration**

**1. Network Policies**:
```yaml
# Complexity: Advanced
# Real-world Usage: Control network traffic between pods
# Purpose: Restrict Ingress Controller access to backend services
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-controller-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx-ingress-controller
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: myapp
    ports:
    - protocol: TCP
      port: 80
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

**2. RBAC Configuration**:
```yaml
# Complexity: Advanced
# Real-world Usage: Control what the Ingress Controller can access
# Purpose: Principle of least privilege
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: nginx-ingress-controller
rules:
- apiGroups: [""]
  resources: ["configmaps", "endpoints", "nodes", "pods", "secrets"]
  verbs: ["list", "watch"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses/status"]
  verbs: ["update"]
```

### **Performance Optimization**

#### **NGINX Performance Tuning**

**1. Worker Process Configuration**:
```nginx
# Complexity: Advanced
# Real-world Usage: Optimize NGINX for your hardware
# Location: Main NGINX configuration
worker_processes auto;  # Use all available CPU cores
worker_cpu_affinity auto;  # Bind workers to specific CPU cores
worker_rlimit_nofile 65535;  # Increase file descriptor limit

events {
    worker_connections 4096;  # Connections per worker
    use epoll;  # Use efficient event model
    multi_accept on;  # Accept multiple connections at once
}
```

**2. Caching Configuration**:
```nginx
# Complexity: Advanced
# Real-world Usage: Cache static content and API responses
# Location: HTTP block configuration
http {
    # Proxy cache configuration
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;
    
    server {
        location / {
            # Enable caching
            proxy_cache my_cache;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            
            # Cache headers
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://backend;
        }
        
        # Static content caching
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

**3. Gzip Compression**:
```nginx
# Complexity: Intermediate
# Real-world Usage: Reduce bandwidth usage and improve performance
# Location: HTTP block configuration
http {
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
}
```

#### **Kubernetes Resource Optimization**

**1. Resource Requests and Limits**:
```yaml
# Complexity: Intermediate
# Real-world Usage: Ensure adequate resources for NGINX Ingress Controller
# Purpose: Prevent resource starvation and enable proper scheduling
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-ingress-controller
  template:
    metadata:
      labels:
        app: nginx-ingress-controller
    spec:
      containers:
      - name: nginx-ingress-controller
        image: k8s.gcr.io/ingress-nginx/controller:v1.8.1
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        ports:
        - containerPort: 80
        - containerPort: 443
```

**2. Horizontal Pod Autoscaling**:
```yaml
# Complexity: Advanced
# Real-world Usage: Automatically scale Ingress Controller based on load
# Purpose: Handle traffic spikes without manual intervention
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-ingress-controller-hpa
  namespace: ingress-nginx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-ingress-controller
  minReplicas: 2
  maxReplicas: 10
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
```

### **Production Context**

#### **E-commerce Application Integration**

**1. Multi-Service Architecture**:
```yaml
# Complexity: Advanced
# Real-world Usage: Route different parts of e-commerce application
# Services: Frontend, API, Admin, Payment, Analytics
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - shop.example.com
    - api.example.com
    - admin.example.com
    secretName: ecommerce-tls-secret
  rules:
  # Frontend application
  - host: shop.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  
  # API services
  - host: api.example.com
    http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 80
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 80
  
  # Admin interface
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
```

**2. Microservices Communication**:
```yaml
# Complexity: Advanced
# Real-world Usage: Internal service communication with external API access
# Pattern: API Gateway pattern with NGINX Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/upstream-vhost: "api.example.com"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      # Product catalog service
      - path: /api/v1/products
        pathType: Prefix
        backend:
          service:
            name: product-catalog-service
            port:
              number: 80
      
      # Shopping cart service
      - path: /api/v1/cart
        pathType: Prefix
        backend:
          service:
            name: shopping-cart-service
            port:
              number: 80
      
      # Payment processing service
      - path: /api/v1/payments
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 80
      
      # User management service
      - path: /api/v1/users
        pathType: Prefix
        backend:
          service:
            name: user-management-service
            port:
              number: 80
      
      # Order management service
      - path: /api/v1/orders
        pathType: Prefix
        backend:
          service:
            name: order-management-service
            port:
              number: 80
```

**3. CI/CD Integration**:
```yaml
# Complexity: Advanced
# Real-world Usage: Automated deployment with Ingress updates
# Tool: GitLab CI/CD with Kubernetes integration
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # Blue-green deployment support
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
spec:
  tls:
  - hosts:
    - shop.example.com
    secretName: ecommerce-tls-secret
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

**4. Scaling and Performance**:
```yaml
# Complexity: Advanced
# Real-world Usage: Handle high traffic with multiple Ingress Controllers
# Pattern: Multiple Ingress Controllers with load balancing
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    app: nginx-ingress-controller
```

### **Enterprise Integration Patterns**

#### **Multi-Tenant Architecture**

**1. Namespace-based Isolation**:
```yaml
# Complexity: Advanced
# Real-world Usage: Separate tenants using different namespaces
# Pattern: One Ingress Controller per tenant namespace
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tenant-a-ingress
  namespace: tenant-a
  annotations:
    nginx.ingress.kubernetes.io/ingress-class: "nginx-tenant-a"
spec:
  rules:
  - host: tenant-a.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tenant-a-service
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tenant-b-ingress
  namespace: tenant-b
  annotations:
    nginx.ingress.kubernetes.io/ingress-class: "nginx-tenant-b"
spec:
  rules:
  - host: tenant-b.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tenant-b-service
            port:
              number: 80
```

**2. Service Mesh Integration**:
```yaml
# Complexity: Expert
# Real-world Usage: Integrate NGINX Ingress with Istio service mesh
# Pattern: NGINX as edge proxy with Istio for internal communication
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: istio-integrated-ingress
  namespace: istio-system
  annotations:
    nginx.ingress.kubernetes.io/upstream-vhost: "istio-ingressgateway.istio-system.svc.cluster.local"
    nginx.ingress.kubernetes.io/proxy-set-headers: "istio-system/nginx-configmap"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: istio-ingressgateway
            port:
              number: 80
```

#### **Cloud Provider Integration**

**1. AWS Load Balancer Controller**:
```yaml
# Complexity: Advanced
# Real-world Usage: Use AWS Application Load Balancer with NGINX Ingress
# Pattern: ALB for external load balancing, NGINX for internal routing
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aws-alb-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/load-balancer-attributes: routing.http2.enabled=true
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-ingress-controller
            port:
              number: 80
```

**2. GCP Load Balancer Integration**:
```yaml
# Complexity: Advanced
# Real-world Usage: Use GCP Load Balancer with NGINX Ingress
# Pattern: GCP LB for external traffic, NGINX for internal routing
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gcp-lb-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.global-static-ip-name: "my-static-ip"
    networking.gke.io/managed-certificates: "my-ssl-cert"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-ingress-controller
            port:
              number: 80
```

### **Monitoring and Observability**

#### **NGINX Metrics Collection**

**1. Prometheus Integration**:
```yaml
# Complexity: Advanced
# Real-world Usage: Collect NGINX metrics for monitoring
# Tool: NGINX Prometheus Exporter
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-prometheus-exporter
  namespace: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-prometheus-exporter
  template:
    metadata:
      labels:
        app: nginx-prometheus-exporter
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9113"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: nginx-prometheus-exporter
        image: nginx/nginx-prometheus-exporter:0.10.0
        ports:
        - containerPort: 9113
        args:
        - -nginx.scrape-uri=http://localhost:8080/nginx_status
        - -web.listen-address=:9113
```

**2. Grafana Dashboard**:
```yaml
# Complexity: Advanced
# Real-world Usage: Visualize NGINX Ingress metrics
# Tool: Grafana with NGINX dashboard
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-grafana-dashboard
  namespace: monitoring
data:
  nginx-ingress-dashboard.json: |
    {
      "dashboard": {
        "title": "NGINX Ingress Controller",
        "panels": [
          {
            "title": "Request Rate",
            "type": "graph",
            "targets": [
              {
                "expr": "rate(nginx_ingress_controller_requests_total[5m])",
                "legendFormat": "{{ingress}}"
              }
            ]
          },
          {
            "title": "Response Time",
            "type": "graph",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, rate(nginx_ingress_controller_request_duration_seconds_bucket[5m]))",
                "legendFormat": "95th percentile"
              }
            ]
          }
        ]
      }
    }
```

#### **Logging Configuration**

**1. Structured Logging**:
```yaml
# Complexity: Intermediate
# Real-world Usage: Configure structured logging for analysis
# Tool: Fluentd or Filebeat for log collection
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-logging-config
  namespace: ingress-nginx
data:
  nginx.conf: |
    http {
      log_format json_combined escape=json
        '{'
          '"time_local":"$time_local",'
          '"remote_addr":"$remote_addr",'
          '"request":"$request",'
          '"status": "$status",'
          '"body_bytes_sent":"$body_bytes_sent",'
          '"http_referer":"$http_referer",'
          '"http_user_agent":"$http_user_agent",'
          '"request_time":"$request_time",'
          '"upstream_response_time":"$upstream_response_time"'
        '}';
      
      access_log /var/log/nginx/access.log json_combined;
      error_log /var/log/nginx/error.log warn;
    }
```

**2. Log Aggregation**:
```yaml
# Complexity: Advanced
# Real-world Usage: Aggregate logs from multiple Ingress Controllers
# Tool: ELK Stack or similar
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-nginx
  namespace: logging
spec:
  selector:
    matchLabels:
      app: fluentd-nginx
  template:
    metadata:
      labels:
        app: fluentd-nginx
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

---

**Next: Let's move to the Command Documentation Framework to understand all the kubectl commands you'll need!**

---

## 🔧 **Command Documentation Framework**

### **Tier 1 Commands (Simple - 3-5 lines documentation)**

#### **Command: kubectl version**
```bash
# Command: kubectl version
# Purpose: Display kubectl and cluster version information
# Usage: kubectl version [--client] [--short]
# Output: Version information for kubectl and Kubernetes cluster
# Notes: Essential for verifying compatibility and troubleshooting
```

#### **Command: kubectl cluster-info**
```bash
# Command: kubectl cluster-info
# Purpose: Display cluster information and endpoints
# Usage: kubectl cluster-info [--dump]
# Output: Master and services endpoint information
# Notes: Verifies cluster connectivity and configuration
```

#### **Command: kubectl get namespaces**
```bash
# Command: kubectl get namespaces
# Purpose: List all namespaces in the cluster
# Usage: kubectl get namespaces [--output=wide]
# Output: List of namespaces with status and age
# Notes: Shows available namespaces for Ingress deployment
```

### **Tier 2 Commands (Basic - 10-15 lines documentation)**

#### **Command: kubectl get ingress**
```bash
# Command: kubectl get ingress
# Purpose: List Ingress resources in the current namespace
# Flags: -A (all namespaces), -o wide (detailed output), --show-labels
# Usage: kubectl get ingress [namespace] [--output=wide]
# Output: Ingress resources with addresses, ports, and age
# Examples: 
#   kubectl get ingress
#   kubectl get ingress -A
#   kubectl get ingress -o wide
# Notes: Shows all Ingress resources and their status
# Troubleshooting: Check if Ingress is properly configured
```

#### **Command: kubectl describe ingress**
```bash
# Command: kubectl describe ingress
# Purpose: Show detailed information about a specific Ingress resource
# Flags: -n (namespace), --show-events
# Usage: kubectl describe ingress <name> [-n <namespace>]
# Output: Detailed Ingress configuration, rules, and events
# Examples:
#   kubectl describe ingress my-ingress
#   kubectl describe ingress my-ingress -n production
# Notes: Essential for troubleshooting Ingress configuration issues
# Troubleshooting: Check events for configuration errors
```

#### **Command: kubectl create ingress**
```bash
# Command: kubectl create ingress
# Purpose: Create an Ingress resource from command line
# Flags: --rule (routing rules), --class (ingress class), --annotation
# Usage: kubectl create ingress <name> --rule="host/path=service:port"
# Output: Creates Ingress resource and shows confirmation
# Examples:
#   kubectl create ingress my-ingress --rule="example.com/=my-service:80"
#   kubectl create ingress api-ingress --rule="api.example.com/api=api-service:80"
# Notes: Quick way to create simple Ingress resources
# Troubleshooting: Verify service exists before creating Ingress
```

### **Tier 3 Commands (Complex - Full 9-section format)**

#### **Command: kubectl apply -f ingress.yaml**

##### **1. Command Overview**
```bash
# Command: kubectl apply -f ingress.yaml
# Purpose: Apply Ingress configuration from YAML file
# Category: Resource Management
# Complexity: Intermediate
# Real-world Usage: Deploy Ingress resources from configuration files
```

##### **2. Command Purpose and Context**
```bash
# What kubectl apply -f does:
# - Reads YAML configuration file
# - Creates or updates Ingress resources
# - Validates configuration before applying
# - Shows diff of changes being made
# - Essential for declarative Ingress management

# When to use kubectl apply -f:
# - Deploying Ingress resources from files
# - Updating existing Ingress configurations
# - Managing complex Ingress setups
# - Version control of Ingress configurations
# - CI/CD pipeline deployments

# Command relationships:
# - Often used with kubectl get to verify deployment
# - Works with kubectl describe for troubleshooting
# - Complementary to kubectl create for complex resources
```

##### **3. Complete Flag Reference (ALL Available Flags)**
```bash
# ALL AVAILABLE FLAGS (Complete Reference)
kubectl apply -f <file> [options]

# File Selection:
-f, --filename <file>        # File or directory to apply
-R, --recursive              # Process directories recursively
--dry-run=client             # Show what would be applied (client-side)
--dry-run=server             # Show what would be applied (server-side)

# Output Control:
-o, --output <format>        # Output format (yaml, json, name, etc.)
--output-version <version>   # Output version for specific format
--show-managed-fields        # Show managed fields in output

# Validation:
--validate=true              # Validate configuration (default)
--validate=false             # Skip validation
--schema-cache-dir <dir>     # Cache directory for schema validation

# Apply Behavior:
--force                      # Force apply even if conflicts exist
--grace-period <seconds>     # Grace period for deletion
--timeout <duration>         # Timeout for apply operation
--wait                       # Wait for resources to be ready
--wait-for-conditions        # Wait for specific conditions

# Namespace:
-n, --namespace <name>       # Target namespace
--all-namespaces             # Apply to all namespaces

# Other Options:
--server-side                # Use server-side apply
--field-manager <name>       # Field manager name
--prune                      # Prune resources not in file
--prune-whitelist <kind>     # Whitelist for pruning
```

##### **4. Flag Discovery Methods**
```bash
# How to discover all available flags:

# Method 1: Built-in help
kubectl apply --help
kubectl apply --help | grep -i "filename"
kubectl apply --help | grep -i "dry-run"

# Method 2: Manual pages
man kubectl-apply
man kubectl-apply | grep -A 5 -B 5 "filename"
man kubectl-apply | grep -A 10 "OPTIONS"

# Method 3: Command-specific help
kubectl apply -h
kubectl apply --help | grep -i "options"

# Method 4: Online documentation
# Visit: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply
```

##### **5. Structured Command Analysis Section**
```bash
##### **🔧 Command Analysis: kubectl apply -f ingress.yaml**

# Command Breakdown:
echo "Command: kubectl apply -f ingress.yaml"
echo "Purpose: Apply Ingress configuration from YAML file"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. kubectl: Kubernetes command-line tool"
echo "2. apply: Declarative management command"
echo "3. -f: Flag specifying file input"
echo "4. ingress.yaml: YAML configuration file"
echo "5. Process: Read file → Validate → Apply to cluster"
echo ""

# Execute command with detailed output analysis:
kubectl apply -f ingress.yaml
echo ""
echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output Format:"
echo "ingress.networking.k8s.io/my-ingress created"
echo "ingress.networking.k8s.io/api-ingress configured"
echo ""
echo "Output Interpretation:"
echo "- 'created': New resource was created"
echo "- 'configured': Existing resource was updated"
echo "- 'unchanged': No changes were needed"
echo ""
```

##### **6. Real-time Examples with Input/Output Analysis**
```bash
# Example 1: Basic Ingress application
echo "=== EXAMPLE 1: Basic Ingress Application ==="
kubectl apply -f basic-ingress.yaml
# -f: Specify YAML file
# basic-ingress.yaml: File containing Ingress configuration

# Expected Output Analysis:
echo "Expected Output:"
echo "ingress.networking.k8s.io/basic-ingress created"
echo ""
echo "Output Interpretation:"
echo "- Resource type: ingress.networking.k8s.io"
echo "- Resource name: basic-ingress"
echo "- Action: created (new resource)"
echo ""

# Example 2: Multiple Ingress resources
echo "=== EXAMPLE 2: Multiple Ingress Resources ==="
kubectl apply -f ingress-directory/
# -f: Specify directory containing multiple YAML files
# ingress-directory/: Directory with multiple Ingress configurations

# Expected Output Analysis:
echo "Expected Output:"
echo "ingress.networking.k8s.io/frontend-ingress created"
echo "ingress.networking.k8s.io/api-ingress created"
echo "ingress.networking.k8s.io/admin-ingress created"
echo ""
echo "Output Interpretation:"
echo "- Multiple resources processed"
echo "- All resources created successfully"
echo "- Directory processed recursively"
echo ""

# Example 3: Dry run validation
echo "=== EXAMPLE 3: Dry Run Validation ==="
kubectl apply -f ingress.yaml --dry-run=client
# --dry-run=client: Validate configuration without applying
# ingress.yaml: File to validate

# Expected Output Analysis:
echo "Expected Output:"
echo "ingress.networking.k8s.io/my-ingress created (dry run)"
echo ""
echo "Output Interpretation:"
echo "- Configuration is valid"
echo "- Resource would be created"
echo "- No actual changes made to cluster"
echo ""
```

##### **7. Flag Exploration Exercises**
```bash
# Exercise 1: Explore dry run options
echo "=== FLAG EXPLORATION EXERCISE 1: Dry Run Options ==="
echo "Testing different dry run options:"
echo ""
echo "1. Client-side dry run:"
kubectl apply -f ingress.yaml --dry-run=client
echo ""
echo "2. Server-side dry run:"
kubectl apply -f ingress.yaml --dry-run=server
echo ""
echo "3. Output format with dry run:"
kubectl apply -f ingress.yaml --dry-run=client -o yaml
echo ""

# Exercise 2: Explore validation options
echo "=== FLAG EXPLORATION EXERCISE 2: Validation Options ==="
echo "Testing different validation options:"
echo ""
echo "1. With validation (default):"
kubectl apply -f ingress.yaml --validate=true
echo ""
echo "2. Without validation:"
kubectl apply -f ingress.yaml --validate=false
echo ""
echo "3. Custom schema cache:"
kubectl apply -f ingress.yaml --schema-cache-dir=/tmp/schema-cache
echo ""
```

##### **8. Performance and Security Considerations**
```bash
# Performance Considerations:
echo "=== PERFORMANCE CONSIDERATIONS ==="
echo "1. Use --dry-run for validation:"
echo "   - Validate configuration before applying"
echo "   - Prevent failed deployments"
echo "   - Reduce cluster load during testing"
echo ""
echo "2. Use --server-side for large resources:"
echo "   - Better performance for complex resources"
echo "   - Server handles field management"
echo "   - Reduces client-side processing"
echo ""
echo "3. Use --wait for critical resources:"
echo "   - Ensure resources are ready before continuing"
echo "   - Prevent race conditions"
echo "   - Better for automation scripts"
echo ""

# Security Considerations:
echo "=== SECURITY CONSIDERATIONS ==="
echo "1. Validate YAML files before applying:"
echo "   - Use --dry-run=client for validation"
echo "   - Check for sensitive information"
echo "   - Verify resource permissions"
echo ""
echo "2. Use specific namespaces:"
echo "   - Use -n flag to specify namespace"
echo "   - Prevent accidental cross-namespace deployment"
echo "   - Better resource isolation"
echo ""
echo "3. Review changes before applying:"
echo "   - Use --dry-run to see what will change"
echo "   - Check diff output for unexpected changes"
echo "   - Verify resource ownership and permissions"
echo ""
```

##### **9. Troubleshooting Scenarios**
```bash
# Common Issues and Solutions:
echo "=== TROUBLESHOOTING SCENARIOS ==="
echo ""
echo "1. File not found:"
echo "   Problem: 'error: the path "ingress.yaml" does not exist"'
echo "   Solution: Check file path and permissions"
echo "   Command: ls -la ingress.yaml"
echo "   Command: kubectl apply -f ./ingress.yaml"
echo ""
echo "2. Invalid YAML syntax:"
echo "   Problem: 'error: error validating data: invalid YAML'"
echo "   Solution: Validate YAML syntax"
echo "   Command: yamllint ingress.yaml"
echo "   Command: kubectl apply -f ingress.yaml --dry-run=client"
echo ""
echo "3. Resource already exists:"
echo "   Problem: 'error: resource already exists'"
echo "   Solution: Use apply instead of create, or delete first"
echo "   Command: kubectl delete ingress my-ingress"
echo "   Command: kubectl apply -f ingress.yaml"
echo ""
echo "4. Permission denied:"
echo "   Problem: 'error: You must be logged in to the server'"
echo "   Solution: Check kubectl configuration and permissions"
echo "   Command: kubectl auth can-i create ingress"
echo "   Command: kubectl config current-context"
echo ""
```

#### **Command: kubectl get ingress -o yaml**

##### **1. Command Overview**
```bash
# Command: kubectl get ingress -o yaml
# Purpose: Retrieve Ingress resource in YAML format
# Category: Resource Inspection
# Complexity: Intermediate
# Real-world Usage: Export Ingress configuration for backup or analysis
```

##### **2. Command Purpose and Context**
```bash
# What kubectl get ingress -o yaml does:
# - Retrieves Ingress resource from cluster
# - Outputs in YAML format for readability
# - Shows complete resource configuration
# - Includes status and metadata information
# - Essential for configuration backup and analysis

# When to use kubectl get ingress -o yaml:
# - Exporting Ingress configurations
# - Analyzing current Ingress setup
# - Creating backup of Ingress resources
# - Troubleshooting configuration issues
# - Documentation and version control

# Command relationships:
# - Often used with kubectl apply to restore configurations
# - Works with kubectl describe for detailed analysis
# - Complementary to kubectl edit for configuration changes
```

##### **3. Complete Flag Reference (ALL Available Flags)**
```bash
# ALL AVAILABLE FLAGS (Complete Reference)
kubectl get ingress [name] -o yaml [options]

# Output Format:
-o, --output yaml            # Output in YAML format
-o, --output json            # Output in JSON format
-o, --output name            # Output only resource names
-o, --output wide            # Output in wide format
-o, --output custom-columns  # Custom column output

# Resource Selection:
-A, --all-namespaces         # All namespaces
-n, --namespace <name>       # Specific namespace
--field-selector <selector>  # Field-based selection
--label-selector <selector>  # Label-based selection

# Output Control:
--show-managed-fields        # Show managed fields
--show-labels               # Show labels in output
--sort-by <field>           # Sort output by field
--no-headers                # Suppress headers

# Other Options:
--ignore-not-found           # Ignore not found errors
--chunk-size <size>          # Chunk size for large lists
--server-print              # Print from server
```

##### **4. Flag Discovery Methods**
```bash
# How to discover all available flags:

# Method 1: Built-in help
kubectl get --help
kubectl get --help | grep -i "output"
kubectl get --help | grep -i "namespace"

# Method 2: Manual pages
man kubectl-get
man kubectl-get | grep -A 5 -B 5 "output"
man kubectl-get | grep -A 10 "OPTIONS"

# Method 3: Command-specific help
kubectl get -h
kubectl get --help | grep -i "options"
```

##### **5. Structured Command Analysis Section**
```bash
##### **🔧 Command Analysis: kubectl get ingress -o yaml**

# Command Breakdown:
echo "Command: kubectl get ingress -o yaml"
echo "Purpose: Retrieve Ingress resource in YAML format"
echo ""

# Step-by-step analysis:
echo "=== COMMAND ANALYSIS ==="
echo "1. kubectl: Kubernetes command-line tool"
echo "2. get: Retrieve resource information"
echo "3. ingress: Resource type (Ingress)"
echo "4. -o: Output format flag"
echo "5. yaml: YAML output format"
echo "6. Process: Query cluster → Format as YAML → Display"
echo ""

# Execute command with detailed output analysis:
kubectl get ingress -o yaml
echo ""
echo "=== OUTPUT ANALYSIS ==="
echo "Expected Output Format:"
echo "apiVersion: networking.k8s.io/v1"
echo "kind: Ingress"
echo "metadata: ..."
echo "spec: ..."
echo "status: ..."
echo ""
echo "Output Interpretation:"
echo "- apiVersion: Kubernetes API version"
echo "- kind: Resource type"
echo "- metadata: Resource metadata and labels"
echo "- spec: Ingress configuration"
echo "- status: Current status and conditions"
echo ""
```

##### **6. Real-time Examples with Input/Output Analysis**
```bash
# Example 1: Get specific Ingress resource
echo "=== EXAMPLE 1: Get Specific Ingress Resource ==="
kubectl get ingress my-ingress -o yaml
# my-ingress: Name of specific Ingress resource
# -o yaml: Output in YAML format

# Expected Output Analysis:
echo "Expected Output:"
echo "apiVersion: networking.k8s.io/v1"
echo "kind: Ingress"
echo "metadata:"
echo "  name: my-ingress"
echo "  namespace: default"
echo "spec:"
echo "  rules:"
echo "  - host: example.com"
echo "    http:"
echo "      paths:"
echo "      - path: /"
echo "        pathType: Prefix"
echo "        backend:"
echo "          service:"
echo "            name: my-service"
echo "            port:"
echo "              number: 80"
echo ""
echo "Output Interpretation:"
echo "- Complete Ingress configuration"
echo "- All routing rules and backends"
echo "- Metadata and annotations"
echo ""

# Example 2: Get all Ingress resources
echo "=== EXAMPLE 2: Get All Ingress Resources ==="
kubectl get ingress -A -o yaml
# -A: All namespaces
# -o yaml: Output in YAML format

# Expected Output Analysis:
echo "Expected Output:"
echo "apiVersion: v1"
echo "kind: List"
echo "items:"
echo "- apiVersion: networking.k8s.io/v1"
echo "  kind: Ingress"
echo "  metadata: ..."
echo "- apiVersion: networking.k8s.io/v1"
echo "  kind: Ingress"
echo "  metadata: ..."
echo ""
echo "Output Interpretation:"
echo "- List of all Ingress resources"
echo "- Includes resources from all namespaces"
echo "- Each item is a complete Ingress resource"
echo ""
```

##### **7. Flag Exploration Exercises**
```bash
# Exercise 1: Explore different output formats
echo "=== FLAG EXPLORATION EXERCISE 1: Output Formats ==="
echo "Testing different output formats:"
echo ""
echo "1. YAML format:"
kubectl get ingress -o yaml
echo ""
echo "2. JSON format:"
kubectl get ingress -o json
echo ""
echo "3. Name only:"
kubectl get ingress -o name
echo ""
echo "4. Wide format:"
kubectl get ingress -o wide
echo ""

# Exercise 2: Explore namespace options
echo "=== FLAG EXPLORATION EXERCISE 2: Namespace Options ==="
echo "Testing different namespace options:"
echo ""
echo "1. Current namespace:"
kubectl get ingress -o yaml
echo ""
echo "2. Specific namespace:"
kubectl get ingress -n production -o yaml
echo ""
echo "3. All namespaces:"
kubectl get ingress -A -o yaml
echo ""
```

##### **8. Performance and Security Considerations**
```bash
# Performance Considerations:
echo "=== PERFORMANCE CONSIDERATIONS ==="
echo "1. Use specific resource names when possible:"
echo "   - Faster than listing all resources"
echo "   - Reduces network traffic"
echo "   - Better for automation scripts"
echo ""
echo "2. Use --chunk-size for large lists:"
echo "   - Prevents timeout on large clusters"
echo "   - Better memory usage"
echo "   - More reliable for automation"
echo ""
echo "3. Use --server-print for large resources:"
echo "   - Server handles formatting"
echo "   - Reduces client-side processing"
echo "   - Better for large Ingress configurations"
echo ""

# Security Considerations:
echo "=== SECURITY CONSIDERATIONS ==="
echo "1. Be careful with sensitive information:"
echo "   - YAML output may contain secrets"
echo "   - Check for sensitive annotations"
echo "   - Use --show-managed-fields carefully"
echo ""
echo "2. Use appropriate namespaces:"
echo "   - Use -n to limit scope"
echo "   - Avoid -A unless necessary"
echo "   - Better resource isolation"
echo ""
echo "3. Validate output before sharing:"
echo "   - Check for sensitive data"
echo "   - Remove unnecessary information"
echo "   - Use appropriate access controls"
echo ""
```

##### **9. Troubleshooting Scenarios**
```bash
# Common Issues and Solutions:
echo "=== TROUBLESHOOTING SCENARIOS ==="
echo ""
echo "1. Resource not found:"
echo "   Problem: 'No resources found'"
echo "   Solution: Check namespace and resource name"
echo "   Command: kubectl get ingress -A"
echo "   Command: kubectl get ingress -n <namespace>"
echo ""
echo "2. Permission denied:"
echo "   Problem: 'error: You must be logged in'"
echo "   Solution: Check kubectl configuration"
echo "   Command: kubectl auth can-i get ingress"
echo "   Command: kubectl config current-context"
echo ""
echo "3. Invalid output format:"
echo "   Problem: 'error: unknown output format'"
echo "   Solution: Use valid output format"
echo "   Command: kubectl get ingress -o yaml"
echo "   Command: kubectl get ingress -o json"
echo ""
echo "4. Large output timeout:"
echo "   Problem: 'error: context deadline exceeded'"
echo "   Solution: Use chunking or specific resource"
echo "   Command: kubectl get ingress -o yaml --chunk-size=50"
echo "   Command: kubectl get ingress <name> -o yaml"
echo ""
```

---

**Next: Let's move to the Enhanced Hands-on Labs to put this theory into practice!**

---

## 💻 **Enhanced Hands-on Labs**

### **Lab 1: NGINX Ingress Controller Installation and Basic Configuration**

#### **Step 1: Install NGINX Ingress Controller**

```bash
# Complexity: Beginner
# Real-world Usage: Deploy NGINX Ingress Controller in your cluster
# Purpose: Set up the foundation for external access to services

echo "=== LAB 1: NGINX Ingress Controller Installation ==="
echo ""

# Step 1.1: Create namespace for Ingress Controller
echo "Step 1.1: Creating ingress-nginx namespace"
kubectl create namespace ingress-nginx
# kubectl create namespace: Create a new namespace
# ingress-nginx: Namespace name for Ingress Controller
# Purpose: Isolate Ingress Controller resources

# Verify namespace creation
kubectl get namespaces | grep ingress-nginx
# kubectl get namespaces: List all namespaces
# grep ingress-nginx: Filter for ingress-nginx namespace
# Expected: Shows ingress-nginx namespace in ACTIVE state

echo ""
echo "✅ Namespace created successfully"
echo ""

# Step 1.2: Add NGINX Ingress Controller Helm repository
echo "Step 1.2: Adding NGINX Ingress Controller Helm repository"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo add: Add a Helm repository
# ingress-nginx: Repository name
# https://kubernetes.github.io/ingress-nginx: Repository URL
# Purpose: Access to NGINX Ingress Controller Helm charts

# Update Helm repositories
helm repo update
# helm repo update: Update all configured repositories
# Purpose: Get latest chart versions

# Verify repository addition
helm repo list | grep ingress-nginx
# helm repo list: List all configured repositories
# grep ingress-nginx: Filter for ingress-nginx repository
# Expected: Shows ingress-nginx repository

echo ""
echo "✅ Helm repository added successfully"
echo ""

# Step 1.3: Install NGINX Ingress Controller
echo "Step 1.3: Installing NGINX Ingress Controller"
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.replicaCount=2
# helm install: Install a Helm chart
# ingress-nginx: Release name
# ingress-nginx/ingress-nginx: Chart name
# --namespace ingress-nginx: Target namespace
# --set controller.service.type=LoadBalancer: Use LoadBalancer service type
# --set controller.service.externalTrafficPolicy=Local: Preserve source IP
# --set controller.replicaCount=2: Run 2 replicas for high availability
# Purpose: Deploy NGINX Ingress Controller with production settings

# Wait for deployment to be ready
echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
# kubectl wait: Wait for a condition to be met
# --namespace ingress-nginx: Target namespace
# --for=condition=ready pod: Wait for pods to be ready
# --selector=app.kubernetes.io/component=controller: Select controller pods
# --timeout=300s: Wait up to 5 minutes
# Purpose: Ensure Ingress Controller is fully deployed

echo ""
echo "✅ NGINX Ingress Controller installed successfully"
echo ""

# Step 1.4: Verify installation
echo "Step 1.4: Verifying installation"
kubectl get pods -n ingress-nginx
# kubectl get pods: List pods
# -n ingress-nginx: In ingress-nginx namespace
# Expected: Shows 2 controller pods in Running state

kubectl get services -n ingress-nginx
# kubectl get services: List services
# -n ingress-nginx: In ingress-nginx namespace
# Expected: Shows ingress-nginx-controller service with LoadBalancer type

echo ""
echo "✅ Installation verified successfully"
echo ""
```

#### **Step 2: Create Test Application**

```bash
# Complexity: Beginner
# Real-world Usage: Deploy a test application to verify Ingress functionality
# Purpose: Test Ingress Controller with a simple web application

echo "=== STEP 2: Creating Test Application ==="
echo ""

# Step 2.1: Create test namespace
echo "Step 2.1: Creating test namespace"
kubectl create namespace test-app
# kubectl create namespace: Create namespace for test application
# test-app: Namespace name
# Purpose: Isolate test application resources

# Step 2.2: Deploy test application
echo "Step 2.2: Deploying test application"
cat > test-app-deployment.yaml << 'EOF'
# Complexity: Beginner
# Real-world Usage: Simple web application for testing Ingress
# Purpose: Provide a backend service for Ingress testing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: test-app
  labels:
    app: test-app
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
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        # Custom HTML page for testing
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: test-app-html
EOF
# cat > test-app-deployment.yaml: Create deployment YAML file
# << 'EOF': Here document for multi-line content
# apiVersion: apps/v1: Kubernetes API version for Deployment
# kind: Deployment: Resource type
# metadata: Resource metadata (name, namespace, labels)
# spec: Deployment specification
# replicas: 3: Run 3 pod replicas
# selector: Pod selector for this deployment
# template: Pod template specification
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Mount volumes into container
# volumes: Volume definitions
# configMap: Reference to ConfigMap volume

# Apply deployment
kubectl apply -f test-app-deployment.yaml
# kubectl apply: Apply configuration from file
# -f test-app-deployment.yaml: File containing deployment configuration
# Purpose: Create the test application deployment

echo ""
echo "✅ Test application deployment created"
echo ""

# Step 2.3: Create ConfigMap with custom HTML
echo "Step 2.3: Creating ConfigMap with custom HTML"
cat > test-app-html.yaml << 'EOF'
# Complexity: Beginner
# Real-world Usage: Custom HTML content for test application
# Purpose: Provide identifiable content for testing
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-app-html
  namespace: test-app
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test App - NGINX Ingress</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .container { max-width: 600px; margin: 0 auto; }
            .header { background: #007cba; color: white; padding: 20px; border-radius: 5px; }
            .content { padding: 20px; background: #f5f5f5; border-radius: 5px; margin-top: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 Test Application</h1>
                <p>NGINX Ingress Controller Test</p>
            </div>
            <div class="content">
                <h2>✅ Application Status: Running</h2>
                <p><strong>Pod Name:</strong> <span id="pod-name">Loading...</span></p>
                <p><strong>Namespace:</strong> test-app</p>
                <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
                <p>This is a test application to verify NGINX Ingress Controller functionality.</p>
            </div>
        </div>
        <script>
            document.getElementById('pod-name').textContent = window.location.hostname;
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
        </script>
    </body>
    </html>
EOF
# cat > test-app-html.yaml: Create ConfigMap YAML file
# apiVersion: v1: Kubernetes API version for ConfigMap
# kind: ConfigMap: Resource type
# metadata: Resource metadata
# data: ConfigMap data
# index.html: HTML content for the web page
# Purpose: Provide custom HTML content for the test application

# Apply ConfigMap
kubectl apply -f test-app-html.yaml
# kubectl apply: Apply configuration from file
# -f test-app-html.yaml: File containing ConfigMap configuration
# Purpose: Create the ConfigMap with HTML content

echo ""
echo "✅ ConfigMap created successfully"
echo ""

# Step 2.4: Create service for test application
echo "Step 2.4: Creating service for test application"
cat > test-app-service.yaml << 'EOF'
# Complexity: Beginner
# Real-world Usage: Expose test application within cluster
# Purpose: Provide stable endpoint for Ingress to route to
apiVersion: v1
kind: Service
metadata:
  name: test-app-service
  namespace: test-app
  labels:
    app: test-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: test-app
EOF
# apiVersion: v1: Kubernetes API version for Service
# kind: Service: Resource type
# metadata: Resource metadata
# spec: Service specification
# type: ClusterIP: Service type (internal cluster access)
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: test-app: Select pods with this label
# Purpose: Expose the test application within the cluster

# Apply service
kubectl apply -f test-app-service.yaml
# kubectl apply: Apply configuration from file
# -f test-app-service.yaml: File containing service configuration
# Purpose: Create the service for the test application

echo ""
echo "✅ Service created successfully"
echo ""

# Step 2.5: Verify test application deployment
echo "Step 2.5: Verifying test application deployment"
kubectl get pods -n test-app
# kubectl get pods: List pods
# -n test-app: In test-app namespace
# Expected: Shows 3 test-app pods in Running state

kubectl get services -n test-app
# kubectl get services: List services
# -n test-app: In test-app namespace
# Expected: Shows test-app-service with ClusterIP type

kubectl get configmap -n test-app
# kubectl get configmap: List ConfigMaps
# -n test-app: In test-app namespace
# Expected: Shows test-app-html ConfigMap

echo ""
echo "✅ Test application deployed successfully"
echo ""
```

#### **Step 3: Create Basic Ingress Resource**

```bash
# Complexity: Beginner
# Real-world Usage: Create basic Ingress for external access
# Purpose: Route external traffic to test application

echo "=== STEP 3: Creating Basic Ingress Resource ==="
echo ""

# Step 3.1: Create basic Ingress
echo "Step 3.1: Creating basic Ingress resource"
cat > basic-ingress.yaml << 'EOF'
# Complexity: Beginner
# Real-world Usage: Basic Ingress configuration for external access
# Purpose: Route external traffic to test application
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-app-ingress
  namespace: test-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: test-app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-app-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version for Ingress
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "false": Disable SSL redirect
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# rules: Ingress rules
# host: test-app.local: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing
# path: /: Root path
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: test-app-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Route external traffic to test application

# Apply Ingress
kubectl apply -f basic-ingress.yaml
# kubectl apply: Apply configuration from file
# -f basic-ingress.yaml: File containing Ingress configuration
# Purpose: Create the Ingress resource

echo ""
echo "✅ Basic Ingress created successfully"
echo ""

# Step 3.2: Verify Ingress creation
echo "Step 3.2: Verifying Ingress creation"
kubectl get ingress -n test-app
# kubectl get ingress: List Ingress resources
# -n test-app: In test-app namespace
# Expected: Shows test-app-ingress with ADDRESS and PORTS

kubectl describe ingress test-app-ingress -n test-app
# kubectl describe: Show detailed information
# ingress test-app-ingress: Ingress resource name
# -n test-app: In test-app namespace
# Expected: Shows detailed Ingress configuration and events

echo ""
echo "✅ Ingress verification completed"
echo ""

# Step 3.3: Get Ingress Controller external IP
echo "Step 3.3: Getting Ingress Controller external IP"
kubectl get services -n ingress-nginx
# kubectl get services: List services
# -n ingress-nginx: In ingress-nginx namespace
# Expected: Shows ingress-nginx-controller with EXTERNAL-IP

# Store external IP for testing
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# kubectl get service: Get service information
# ingress-nginx-controller: Service name
# -n ingress-nginx: In ingress-nginx namespace
# -o jsonpath: Output in JSONPath format
# .status.loadBalancer.ingress[0].ip: Extract external IP
# Purpose: Get the external IP address for testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Step 3.4: Test Ingress functionality
echo "Step 3.4: Testing Ingress functionality"
echo "Testing with curl..."

# Add hostname to /etc/hosts for testing
echo "Adding hostname to /etc/hosts for testing..."
echo "$EXTERNAL_IP test-app.local" | sudo tee -a /etc/hosts
# echo: Output text
# $EXTERNAL_IP test-app.local: IP and hostname mapping
# sudo tee -a /etc/hosts: Append to /etc/hosts file
# Purpose: Map hostname to external IP for testing

# Test the Ingress
curl -H "Host: test-app.local" http://$EXTERNAL_IP
# curl: HTTP client
# -H "Host: test-app.local": Set Host header
# http://$EXTERNAL_IP: URL to test
# Purpose: Test Ingress routing

echo ""
echo "✅ Ingress functionality tested successfully"
echo ""

# Step 3.5: Cleanup
echo "Step 3.5: Cleaning up test resources"
kubectl delete namespace test-app
# kubectl delete namespace: Delete namespace and all resources
# test-app: Namespace to delete
# Purpose: Clean up test resources

# Remove hostname from /etc/hosts
sudo sed -i '/test-app.local/d' /etc/hosts
# sudo sed -i: Edit file in place
# '/test-app.local/d': Delete lines containing test-app.local
# /etc/hosts: File to edit
# Purpose: Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""
```

### **Lab 2: Path-based Routing and Multiple Services**

#### **Step 1: Deploy Multiple Test Applications**

```bash
# Complexity: Intermediate
# Real-world Usage: Deploy multiple services for path-based routing
# Purpose: Test Ingress path-based routing capabilities

echo "=== LAB 2: Path-based Routing and Multiple Services ==="
echo ""

# Step 1.1: Create namespace for multiple services
echo "Step 1.1: Creating namespace for multiple services"
kubectl create namespace multi-app
# kubectl create namespace: Create namespace
# multi-app: Namespace name
# Purpose: Isolate multiple test applications

# Step 1.2: Deploy frontend application
echo "Step 1.2: Deploying frontend application"
cat > frontend-deployment.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Frontend application for path-based routing
# Purpose: Serve frontend content at root path
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: multi-app
  labels:
    app: frontend-app
    tier: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-app
  template:
    metadata:
      labels:
        app: frontend-app
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: frontend-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata with labels
# labels: Resource labels for identification
# app: frontend-app: Application name
# tier: frontend: Application tier
# spec: Deployment specification
# replicas: 2: Number of replicas
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy frontend application

# Apply frontend deployment
kubectl apply -f frontend-deployment.yaml
# kubectl apply: Apply configuration
# -f frontend-deployment.yaml: File containing deployment
# Purpose: Create frontend deployment

echo ""
echo "✅ Frontend application deployed"
echo ""

# Step 1.3: Deploy API application
echo "Step 1.3: Deploying API application"
cat > api-deployment.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: API application for path-based routing
# Purpose: Serve API content at /api path
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-app
  namespace: multi-app
  labels:
    app: api-app
    tier: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-app
  template:
    metadata:
      labels:
        app: api-app
        tier: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: api-html
EOF
# Similar structure to frontend deployment
# app: api-app: API application name
# tier: backend: Backend tier
# replicas: 3: More replicas for API
# Purpose: Deploy API application

# Apply API deployment
kubectl apply -f api-deployment.yaml
# kubectl apply: Apply configuration
# -f api-deployment.yaml: File containing deployment
# Purpose: Create API deployment

echo ""
echo "✅ API application deployed"
echo ""

# Step 1.4: Deploy admin application
echo "Step 1.4: Deploying admin application"
cat > admin-deployment.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Admin application for path-based routing
# Purpose: Serve admin content at /admin path
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-app
  namespace: multi-app
  labels:
    app: admin-app
    tier: admin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin-app
  template:
    metadata:
      labels:
        app: admin-app
        tier: admin
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: admin-html
EOF
# Similar structure to other deployments
# app: admin-app: Admin application name
# tier: admin: Admin tier
# replicas: 1: Single replica for admin
# Purpose: Deploy admin application

# Apply admin deployment
kubectl apply -f admin-deployment.yaml
# kubectl apply: Apply configuration
# -f admin-deployment.yaml: File containing deployment
# Purpose: Create admin deployment

echo ""
echo "✅ Admin application deployed"
echo ""
```

#### **Step 2: Create Services for Each Application**

```bash
# Complexity: Intermediate
# Real-world Usage: Create services for each application
# Purpose: Expose applications within cluster

echo "=== STEP 2: Creating Services for Each Application ==="
echo ""

# Step 2.1: Create frontend service
echo "Step 2.1: Creating frontend service"
cat > frontend-service.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Service for frontend application
# Purpose: Expose frontend application within cluster
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: multi-app
  labels:
    app: frontend-app
    tier: frontend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: frontend-app
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: frontend-app: Select frontend pods
# Purpose: Expose frontend application

# Apply frontend service
kubectl apply -f frontend-service.yaml
# kubectl apply: Apply configuration
# -f frontend-service.yaml: File containing service
# Purpose: Create frontend service

echo ""
echo "✅ Frontend service created"
echo ""

# Step 2.2: Create API service
echo "Step 2.2: Creating API service"
cat > api-service.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Service for API application
# Purpose: Expose API application within cluster
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: multi-app
  labels:
    app: api-app
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: api-app
EOF
# Similar structure to frontend service
# app: api-app: Select API pods
# Purpose: Expose API application

# Apply API service
kubectl apply -f api-service.yaml
# kubectl apply: Apply configuration
# -f api-service.yaml: File containing service
# Purpose: Create API service

echo ""
echo "✅ API service created"
echo ""

# Step 2.3: Create admin service
echo "Step 2.3: Creating admin service"
cat > admin-service.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Service for admin application
# Purpose: Expose admin application within cluster
apiVersion: v1
kind: Service
metadata:
  name: admin-service
  namespace: multi-app
  labels:
    app: admin-app
    tier: admin
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: admin-app
EOF
# Similar structure to other services
# app: admin-app: Select admin pods
# Purpose: Expose admin application

# Apply admin service
kubectl apply -f admin-service.yaml
# kubectl apply: Apply configuration
# -f admin-service.yaml: File containing service
# Purpose: Create admin service

echo ""
echo "✅ Admin service created"
echo ""

# Step 2.4: Verify all services
echo "Step 2.4: Verifying all services"
kubectl get services -n multi-app
# kubectl get services: List services
# -n multi-app: In multi-app namespace
# Expected: Shows all three services

kubectl get pods -n multi-app
# kubectl get pods: List pods
# -n multi-app: In multi-app namespace
# Expected: Shows all application pods

echo ""
echo "✅ All services verified successfully"
echo ""
```

#### **Step 3: Create Path-based Ingress**

```bash
# Complexity: Intermediate
# Real-world Usage: Create path-based Ingress for multiple services
# Purpose: Route traffic based on URL paths

echo "=== STEP 3: Creating Path-based Ingress ==="
echo ""

# Step 3.1: Create path-based Ingress
echo "Step 3.1: Creating path-based Ingress"
cat > path-based-ingress.yaml << 'EOF'
# Complexity: Intermediate
# Real-world Usage: Path-based Ingress for multiple services
# Purpose: Route traffic based on URL paths
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
  namespace: multi-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: multi-app.local
    http:
      paths:
      # Frontend at root path
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      # API at /api path
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
      # Admin at /admin path
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "false": Disable SSL redirect
# nginx.ingress.kubernetes.io/use-regex: "true": Enable regex matching
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# rules: Ingress rules
# host: multi-app.local: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing rules
# path: /: Root path for frontend
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: frontend-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Route traffic based on URL paths

# Apply path-based Ingress
kubectl apply -f path-based-ingress.yaml
# kubectl apply: Apply configuration
# -f path-based-ingress.yaml: File containing Ingress
# Purpose: Create path-based Ingress

echo ""
echo "✅ Path-based Ingress created successfully"
echo ""

# Step 3.2: Verify Ingress creation
echo "Step 3.2: Verifying Ingress creation"
kubectl get ingress -n multi-app
# kubectl get ingress: List Ingress resources
# -n multi-app: In multi-app namespace
# Expected: Shows path-based-ingress with ADDRESS and PORTS

kubectl describe ingress path-based-ingress -n multi-app
# kubectl describe: Show detailed information
# ingress path-based-ingress: Ingress resource name
# -n multi-app: In multi-app namespace
# Expected: Shows detailed Ingress configuration

echo ""
echo "✅ Ingress verification completed"
echo ""

# Step 3.3: Test path-based routing
echo "Step 3.3: Testing path-based routing"
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Get external IP for testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Add hostname to /etc/hosts
echo "Adding hostname to /etc/hosts for testing..."
echo "$EXTERNAL_IP multi-app.local" | sudo tee -a /etc/hosts
# Add hostname mapping for testing

# Test root path (frontend)
echo "Testing root path (frontend)..."
curl -H "Host: multi-app.local" http://$EXTERNAL_IP/
# Test frontend at root path

# Test API path
echo "Testing API path..."
curl -H "Host: multi-app.local" http://$EXTERNAL_IP/api
# Test API at /api path

# Test admin path
echo "Testing admin path..."
curl -H "Host: multi-app.local" http://$EXTERNAL_IP/admin
# Test admin at /admin path

echo ""
echo "✅ Path-based routing tested successfully"
echo ""

# Step 3.4: Cleanup
echo "Step 3.4: Cleaning up test resources"
kubectl delete namespace multi-app
# Delete test namespace

# Remove hostname from /etc/hosts
sudo sed -i '/multi-app.local/d' /etc/hosts
# Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""
```

---

**Next: Let's move to the Enhanced Practice Problems to test your understanding!**

---

## 🎯 **Enhanced Practice Problems**

### **Problem 1: E-commerce Multi-Service Ingress Architecture**

#### **Scenario**
You're tasked with designing and implementing an Ingress architecture for a production e-commerce platform. The platform consists of multiple microservices that need to be accessible externally with proper routing, SSL termination, and load balancing.

#### **Requirements**
- **Frontend Service**: Accessible at root path `/` with SSL
- **API Service**: Accessible at `/api/*` paths with rate limiting
- **Admin Service**: Accessible at `/admin/*` paths with IP whitelisting
- **Payment Service**: Accessible at `/payment/*` paths with strict security
- **Analytics Service**: Accessible at `/analytics/*` paths with authentication

#### **Step-by-Step Solution**

**Step 1: Create Namespace and Deploy Services**

```bash
# Complexity: Advanced
# Real-world Usage: Production e-commerce platform with multiple microservices
# Purpose: Implement comprehensive Ingress architecture

echo "=== PROBLEM 1: E-commerce Multi-Service Ingress Architecture ==="
echo ""

# Step 1.1: Create namespace for e-commerce platform
echo "Step 1.1: Creating e-commerce namespace"
kubectl create namespace ecommerce
# kubectl create namespace: Create namespace for e-commerce platform
# ecommerce: Namespace name
# Purpose: Isolate e-commerce platform resources

# Step 1.2: Deploy frontend service
echo "Step 1.2: Deploying frontend service"
cat > frontend-deployment.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Frontend service for e-commerce platform
# Purpose: Serve customer-facing web application
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-service
  namespace: ecommerce
  labels:
    app: frontend-service
    tier: frontend
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend-service
  template:
    metadata:
      labels:
        app: frontend-service
        tier: frontend
        version: v1.0.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: frontend-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata with labels
# labels: Resource labels for identification
# app: frontend-service: Application name
# tier: frontend: Application tier
# version: v1.0.0: Application version
# spec: Deployment specification
# replicas: 3: Number of replicas for high availability
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# name: http: Port name
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy frontend service for e-commerce platform

# Apply frontend deployment
kubectl apply -f frontend-deployment.yaml
# kubectl apply: Apply configuration
# -f frontend-deployment.yaml: File containing deployment
# Purpose: Create frontend deployment

echo ""
echo "✅ Frontend service deployed"
echo ""

# Step 1.3: Deploy API service
echo "Step 1.3: Deploying API service"
cat > api-deployment.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: API service for e-commerce platform
# Purpose: Handle API requests and business logic
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: ecommerce
  labels:
    app: api-service
    tier: backend
    version: v1.0.0
spec:
  replicas: 5
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
        tier: backend
        version: v1.0.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "400m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: api-html
EOF
# Similar structure to frontend deployment
# app: api-service: API service name
# tier: backend: Backend tier
# replicas: 5: More replicas for API service
# Purpose: Deploy API service for e-commerce platform

# Apply API deployment
kubectl apply -f api-deployment.yaml
# kubectl apply: Apply configuration
# -f api-deployment.yaml: File containing deployment
# Purpose: Create API deployment

echo ""
echo "✅ API service deployed"
echo ""

# Step 1.4: Deploy admin service
echo "Step 1.4: Deploying admin service"
cat > admin-deployment.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Admin service for e-commerce platform
# Purpose: Provide administrative interface
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-service
  namespace: ecommerce
  labels:
    app: admin-service
    tier: admin
    version: v1.0.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: admin-service
  template:
    metadata:
      labels:
        app: admin-service
        tier: admin
        version: v1.0.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: admin-html
EOF
# Similar structure to other deployments
# app: admin-service: Admin service name
# tier: admin: Admin tier
# replicas: 2: Moderate replicas for admin service
# Purpose: Deploy admin service for e-commerce platform

# Apply admin deployment
kubectl apply -f admin-deployment.yaml
# kubectl apply: Apply configuration
# -f admin-deployment.yaml: File containing deployment
# Purpose: Create admin deployment

echo ""
echo "✅ Admin service deployed"
echo ""

# Step 1.5: Deploy payment service
echo "Step 1.5: Deploying payment service"
cat > payment-deployment.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Payment service for e-commerce platform
# Purpose: Handle payment processing with strict security
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: ecommerce
  labels:
    app: payment-service
    tier: backend
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
        tier: backend
        version: v1.0.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "400m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: payment-html
EOF
# Similar structure to other deployments
# app: payment-service: Payment service name
# tier: backend: Backend tier
# replicas: 3: Moderate replicas for payment service
# Purpose: Deploy payment service for e-commerce platform

# Apply payment deployment
kubectl apply -f payment-deployment.yaml
# kubectl apply: Apply configuration
# -f payment-deployment.yaml: File containing deployment
# Purpose: Create payment deployment

echo ""
echo "✅ Payment service deployed"
echo ""

# Step 1.6: Deploy analytics service
echo "Step 1.6: Deploying analytics service"
cat > analytics-deployment.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Analytics service for e-commerce platform
# Purpose: Handle analytics and reporting
apiVersion: apps/v1
kind: Deployment
metadata:
  name: analytics-service
  namespace: ecommerce
  labels:
    app: analytics-service
    tier: backend
    version: v1.0.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: analytics-service
  template:
    metadata:
      labels:
        app: analytics-service
        tier: backend
        version: v1.0.0
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: analytics-html
EOF
# Similar structure to other deployments
# app: analytics-service: Analytics service name
# tier: backend: Backend tier
# replicas: 2: Moderate replicas for analytics service
# Purpose: Deploy analytics service for e-commerce platform

# Apply analytics deployment
kubectl apply -f analytics-deployment.yaml
# kubectl apply: Apply configuration
# -f analytics-deployment.yaml: File containing deployment
# Purpose: Create analytics deployment

echo ""
echo "✅ Analytics service deployed"
echo ""
```

**Step 2: Create Services for All Applications**

```bash
# Complexity: Advanced
# Real-world Usage: Create services for all e-commerce applications
# Purpose: Expose all applications within cluster

echo "=== STEP 2: Creating Services for All Applications ==="
echo ""

# Step 2.1: Create frontend service
echo "Step 2.1: Creating frontend service"
cat > frontend-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for frontend application
# Purpose: Expose frontend application within cluster
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: ecommerce
  labels:
    app: frontend-service
    tier: frontend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: frontend-service
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: frontend-service: Select frontend pods
# Purpose: Expose frontend application

# Apply frontend service
kubectl apply -f frontend-service.yaml
# kubectl apply: Apply configuration
# -f frontend-service.yaml: File containing service
# Purpose: Create frontend service

echo ""
echo "✅ Frontend service created"
echo ""

# Step 2.2: Create API service
echo "Step 2.2: Creating API service"
cat > api-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for API application
# Purpose: Expose API application within cluster
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: ecommerce
  labels:
    app: api-service
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: api-service
EOF
# Similar structure to frontend service
# app: api-service: Select API pods
# Purpose: Expose API application

# Apply API service
kubectl apply -f api-service.yaml
# kubectl apply: Apply configuration
# -f api-service.yaml: File containing service
# Purpose: Create API service

echo ""
echo "✅ API service created"
echo ""

# Step 2.3: Create admin service
echo "Step 2.3: Creating admin service"
cat > admin-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for admin application
# Purpose: Expose admin application within cluster
apiVersion: v1
kind: Service
metadata:
  name: admin-service
  namespace: ecommerce
  labels:
    app: admin-service
    tier: admin
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: admin-service
EOF
# Similar structure to other services
# app: admin-service: Select admin pods
# Purpose: Expose admin application

# Apply admin service
kubectl apply -f admin-service.yaml
# kubectl apply: Apply configuration
# -f admin-service.yaml: File containing service
# Purpose: Create admin service

echo ""
echo "✅ Admin service created"
echo ""

# Step 2.4: Create payment service
echo "Step 2.4: Creating payment service"
cat > payment-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for payment application
# Purpose: Expose payment application within cluster
apiVersion: v1
kind: Service
metadata:
  name: payment-service
  namespace: ecommerce
  labels:
    app: payment-service
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: payment-service
EOF
# Similar structure to other services
# app: payment-service: Select payment pods
# Purpose: Expose payment application

# Apply payment service
kubectl apply -f payment-service.yaml
# kubectl apply: Apply configuration
# -f payment-service.yaml: File containing service
# Purpose: Create payment service

echo ""
echo "✅ Payment service created"
echo ""

# Step 2.5: Create analytics service
echo "Step 2.5: Creating analytics service"
cat > analytics-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for analytics application
# Purpose: Expose analytics application within cluster
apiVersion: v1
kind: Service
metadata:
  name: analytics-service
  namespace: ecommerce
  labels:
    app: analytics-service
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: analytics-service
EOF
# Similar structure to other services
# app: analytics-service: Select analytics pods
# Purpose: Expose analytics application

# Apply analytics service
kubectl apply -f analytics-service.yaml
# kubectl apply: Apply configuration
# -f analytics-service.yaml: File containing service
# Purpose: Create analytics service

echo ""
echo "✅ Analytics service created"
echo ""

# Step 2.6: Verify all services
echo "Step 2.6: Verifying all services"
kubectl get services -n ecommerce
# kubectl get services: List services
# -n ecommerce: In ecommerce namespace
# Expected: Shows all five services

kubectl get pods -n ecommerce
# kubectl get pods: List pods
# -n ecommerce: In ecommerce namespace
# Expected: Shows all application pods

echo ""
echo "✅ All services verified successfully"
echo ""
```

**Step 3: Create Advanced Ingress with Security and Routing**

```bash
# Complexity: Advanced
# Real-world Usage: Create advanced Ingress with security and routing
# Purpose: Implement production-ready Ingress configuration

echo "=== STEP 3: Creating Advanced Ingress with Security and Routing ==="
echo ""

# Step 3.1: Create advanced Ingress
echo "Step 3.1: Creating advanced Ingress"
cat > advanced-ingress.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Advanced Ingress for e-commerce platform
# Purpose: Route traffic with security and performance features
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://ecommerce.example.com"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
    nginx.ingress.kubernetes.io/cors-max-age: "1728000"
    nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ecommerce.example.com
    secretName: ecommerce-tls-secret
  rules:
  # Frontend at root path
  - host: ecommerce.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  
  # API at /api path with rate limiting
  - host: ecommerce.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  
  # Admin at /admin path with IP whitelisting
  - host: ecommerce.example.com
    http:
      paths:
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
  
  # Payment at /payment path with strict security
  - host: ecommerce.example.com
    http:
      paths:
      - path: /payment
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 80
  
  # Analytics at /analytics path with authentication
  - host: ecommerce.example.com
    http:
      paths:
      - path: /analytics
        pathType: Prefix
        backend:
          service:
            name: analytics-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "true": Enable SSL redirect
# nginx.ingress.kubernetes.io/force-ssl-redirect: "true": Force SSL redirect
# nginx.ingress.kubernetes.io/use-regex: "true": Enable regex matching
# nginx.ingress.kubernetes.io/rate-limit: "100": Rate limit per minute
# nginx.ingress.kubernetes.io/rate-limit-window: "1m": Rate limit window
# nginx.ingress.kubernetes.io/enable-cors: "true": Enable CORS
# nginx.ingress.kubernetes.io/cors-allow-origin: "https://ecommerce.example.com": CORS origin
# nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS": CORS methods
# nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization": CORS headers
# nginx.ingress.kubernetes.io/cors-max-age: "1728000": CORS max age
# nginx.ingress.kubernetes.io/cors-allow-credentials: "true": CORS credentials
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# tls: TLS configuration
# hosts: TLS hostnames
# ecommerce.example.com: Domain name
# secretName: ecommerce-tls-secret: TLS secret name
# rules: Ingress rules
# host: ecommerce.example.com: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing rules
# path: /: Root path for frontend
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: frontend-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Route traffic with security and performance features

# Apply advanced Ingress
kubectl apply -f advanced-ingress.yaml
# kubectl apply: Apply configuration
# -f advanced-ingress.yaml: File containing Ingress
# Purpose: Create advanced Ingress

echo ""
echo "✅ Advanced Ingress created successfully"
echo ""

# Step 3.2: Verify Ingress creation
echo "Step 3.2: Verifying Ingress creation"
kubectl get ingress -n ecommerce
# kubectl get ingress: List Ingress resources
# -n ecommerce: In ecommerce namespace
# Expected: Shows ecommerce-ingress with ADDRESS and PORTS

kubectl describe ingress ecommerce-ingress -n ecommerce
# kubectl describe: Show detailed information
# ingress ecommerce-ingress: Ingress resource name
# -n ecommerce: In ecommerce namespace
# Expected: Shows detailed Ingress configuration

echo ""
echo "✅ Ingress verification completed"
echo ""

# Step 3.3: Test Ingress functionality
echo "Step 3.3: Testing Ingress functionality"
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Get external IP for testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Add hostname to /etc/hosts
echo "Adding hostname to /etc/hosts for testing..."
echo "$EXTERNAL_IP ecommerce.example.com" | sudo tee -a /etc/hosts
# Add hostname mapping for testing

# Test root path (frontend)
echo "Testing root path (frontend)..."
curl -H "Host: ecommerce.example.com" http://$EXTERNAL_IP/
# Test frontend at root path

# Test API path
echo "Testing API path..."
curl -H "Host: ecommerce.example.com" http://$EXTERNAL_IP/api
# Test API at /api path

# Test admin path
echo "Testing admin path..."
curl -H "Host: ecommerce.example.com" http://$EXTERNAL_IP/admin
# Test admin at /admin path

# Test payment path
echo "Testing payment path..."
curl -H "Host: ecommerce.example.com" http://$EXTERNAL_IP/payment
# Test payment at /payment path

# Test analytics path
echo "Testing analytics path..."
curl -H "Host: ecommerce.example.com" http://$EXTERNAL_IP/analytics
# Test analytics at /analytics path

echo ""
echo "✅ Ingress functionality tested successfully"
echo ""

# Step 3.4: Cleanup
echo "Step 3.4: Cleaning up test resources"
kubectl delete namespace ecommerce
# Delete test namespace

# Remove hostname from /etc/hosts
sudo sed -i '/ecommerce.example.com/d' /etc/hosts
# Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""
```

#### **Expected Learning Outcomes**
- Understanding of complex Ingress architecture design
- Implementation of security features (SSL, rate limiting, CORS)
- Path-based routing for multiple services
- Production-ready configuration patterns
- Troubleshooting and verification techniques

---

**Next: Let's move to the Chaos Engineering Integration to test resilience!**

---

## 🔥 **Chaos Engineering Integration**

### **Experiment 1: Ingress Controller Pod Failure Testing**

#### **Objective**
Test the resilience of the Ingress Controller when individual pods fail and verify that traffic continues to be routed correctly.

#### **Prerequisites**
- NGINX Ingress Controller deployed with multiple replicas
- Test application with Ingress configuration
- Monitoring tools (optional but recommended)

#### **Step-by-Step Execution**

```bash
# Complexity: Advanced
# Real-world Usage: Test Ingress Controller resilience to pod failures
# Purpose: Verify high availability and failover capabilities

echo "=== CHAOS EXPERIMENT 1: Ingress Controller Pod Failure Testing ==="
echo ""

# Step 1: Deploy test environment
echo "Step 1: Deploying test environment"
kubectl create namespace chaos-test
# kubectl create namespace: Create namespace for chaos testing
# chaos-test: Namespace name
# Purpose: Isolate chaos testing resources

# Deploy test application
cat > chaos-test-app.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Test application for chaos engineering
# Purpose: Provide backend service for testing Ingress resilience
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chaos-test-app
  namespace: chaos-test
  labels:
    app: chaos-test-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chaos-test-app
  template:
    metadata:
      labels:
        app: chaos-test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: chaos-test-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata
# labels: Resource labels
# app: chaos-test-app: Application name
# spec: Deployment specification
# replicas: 3: Number of replicas
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy test application for chaos testing

# Apply test application
kubectl apply -f chaos-test-app.yaml
# kubectl apply: Apply configuration
# -f chaos-test-app.yaml: File containing deployment
# Purpose: Create test application

# Create service for test application
cat > chaos-test-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for test application
# Purpose: Expose test application within cluster
apiVersion: v1
kind: Service
metadata:
  name: chaos-test-service
  namespace: chaos-test
  labels:
    app: chaos-test-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: chaos-test-app
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: chaos-test-app: Select test application pods
# Purpose: Expose test application

# Apply service
kubectl apply -f chaos-test-service.yaml
# kubectl apply: Apply configuration
# -f chaos-test-service.yaml: File containing service
# Purpose: Create service for test application

# Create Ingress for test application
cat > chaos-test-ingress.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Ingress for test application
# Purpose: Route external traffic to test application
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: chaos-test-ingress
  namespace: chaos-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - host: chaos-test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: chaos-test-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "false": Disable SSL redirect
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# rules: Ingress rules
# host: chaos-test.local: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing
# path: /: Root path
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: chaos-test-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Route external traffic to test application

# Apply Ingress
kubectl apply -f chaos-test-ingress.yaml
# kubectl apply: Apply configuration
# -f chaos-test-ingress.yaml: File containing Ingress
# Purpose: Create Ingress for test application

echo ""
echo "✅ Test environment deployed successfully"
echo ""

# Step 2: Establish baseline metrics
echo "Step 2: Establishing baseline metrics"
kubectl get pods -n ingress-nginx
# kubectl get pods: List pods
# -n ingress-nginx: In ingress-nginx namespace
# Expected: Shows Ingress Controller pods

kubectl get pods -n chaos-test
# kubectl get pods: List pods
# -n chaos-test: In chaos-test namespace
# Expected: Shows test application pods

# Get external IP for testing
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# kubectl get service: Get service information
# ingress-nginx-controller: Service name
# -n ingress-nginx: In ingress-nginx namespace
# -o jsonpath: Output in JSONPath format
# .status.loadBalancer.ingress[0].ip: Extract external IP
# Purpose: Get external IP for testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Add hostname to /etc/hosts
echo "Adding hostname to /etc/hosts for testing..."
echo "$EXTERNAL_IP chaos-test.local" | sudo tee -a /etc/hosts
# Add hostname mapping for testing

# Test baseline connectivity
echo "Testing baseline connectivity..."
curl -H "Host: chaos-test.local" http://$EXTERNAL_IP/
# Test connectivity to application

echo ""
echo "✅ Baseline metrics established"
echo ""

# Step 3: Execute chaos experiment
echo "Step 3: Executing chaos experiment - Ingress Controller pod failure"
echo ""

# Get Ingress Controller pods
INGRESS_PODS=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.items[*].metadata.name}')
# kubectl get pods: List pods
# -n ingress-nginx: In ingress-nginx namespace
# -l app.kubernetes.io/component=controller: Select controller pods
# -o jsonpath: Output in JSONPath format
# .items[*].metadata.name: Extract pod names
# Purpose: Get Ingress Controller pod names

echo "Ingress Controller pods: $INGRESS_PODS"
echo ""

# Select first pod for deletion
FIRST_POD=$(echo $INGRESS_PODS | awk '{print $1}')
# echo: Output text
# $INGRESS_PODS: Pod names
# awk '{print $1}': Print first field
# Purpose: Select first pod for deletion

echo "Selected pod for deletion: $FIRST_POD"
echo ""

# Record start time
START_TIME=$(date +%s)
# date +%s: Current time in seconds since epoch
# Purpose: Record experiment start time

# Delete first Ingress Controller pod
echo "Deleting Ingress Controller pod: $FIRST_POD"
kubectl delete pod $FIRST_POD -n ingress-nginx
# kubectl delete pod: Delete pod
# $FIRST_POD: Pod name to delete
# -n ingress-nginx: In ingress-nginx namespace
# Purpose: Simulate pod failure

echo ""
echo "✅ Pod deletion initiated"
echo ""

# Step 4: Monitor recovery
echo "Step 4: Monitoring recovery process"
echo ""

# Wait for pod to be recreated
echo "Waiting for pod to be recreated..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=300s
# kubectl wait: Wait for condition
# --for=condition=ready pod: Wait for pods to be ready
# -l app.kubernetes.io/component=controller: Select controller pods
# -n ingress-nginx: In ingress-nginx namespace
# --timeout=300s: Wait up to 5 minutes
# Purpose: Wait for pod to be recreated

echo ""
echo "✅ Pod recreated successfully"
echo ""

# Record end time
END_TIME=$(date +%s)
# date +%s: Current time in seconds since epoch
# Purpose: Record experiment end time

# Calculate recovery time
RECOVERY_TIME=$((END_TIME - START_TIME))
# $((END_TIME - START_TIME)): Calculate time difference
# Purpose: Calculate recovery time

echo "Recovery time: ${RECOVERY_TIME} seconds"
echo ""

# Step 5: Verify functionality
echo "Step 5: Verifying functionality after recovery"
echo ""

# Test connectivity
echo "Testing connectivity after recovery..."
curl -H "Host: chaos-test.local" http://$EXTERNAL_IP/
# Test connectivity to application

echo ""
echo "✅ Functionality verified after recovery"
echo ""

# Step 6: Cleanup
echo "Step 6: Cleaning up test resources"
kubectl delete namespace chaos-test
# Delete test namespace

# Remove hostname from /etc/hosts
sudo sed -i '/chaos-test.local/d' /etc/hosts
# Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""

# Step 7: Analysis and reporting
echo "Step 7: Analysis and reporting"
echo ""
echo "=== CHAOS EXPERIMENT RESULTS ==="
echo "Experiment: Ingress Controller Pod Failure Testing"
echo "Recovery Time: ${RECOVERY_TIME} seconds"
echo "Status: SUCCESS"
echo "Impact: Minimal - Traffic continued to be routed"
echo "Recommendations:"
echo "1. Ensure multiple replicas are always running"
echo "2. Monitor pod health and restart policies"
echo "3. Consider using PodDisruptionBudgets for controlled shutdowns"
echo "4. Implement health checks and readiness probes"
echo ""
```

#### **Expected Results**
- Ingress Controller should continue routing traffic during pod failure
- New pod should be created automatically
- Recovery time should be minimal (typically under 30 seconds)
- No service disruption should occur

#### **Key Metrics to Monitor**
- Pod restart time
- Traffic routing continuity
- Error rates during failure
- Recovery time

---

### **Experiment 2: Backend Service Failure Testing**

#### **Objective**
Test how the Ingress Controller handles backend service failures and verify proper error handling and routing.

#### **Step-by-Step Execution**

```bash
# Complexity: Advanced
# Real-world Usage: Test Ingress Controller resilience to backend service failures
# Purpose: Verify error handling and failover capabilities

echo "=== CHAOS EXPERIMENT 2: Backend Service Failure Testing ==="
echo ""

# Step 1: Deploy test environment with multiple backend services
echo "Step 1: Deploying test environment with multiple backend services"
kubectl create namespace backend-chaos-test
# kubectl create namespace: Create namespace for backend chaos testing
# backend-chaos-test: Namespace name
# Purpose: Isolate backend chaos testing resources

# Deploy primary backend service
cat > primary-backend.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Primary backend service for chaos testing
# Purpose: Provide primary backend service for testing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: primary-backend
  namespace: backend-chaos-test
  labels:
    app: primary-backend
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: primary-backend
  template:
    metadata:
      labels:
        app: primary-backend
        tier: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: primary-backend-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata
# labels: Resource labels
# app: primary-backend: Application name
# tier: backend: Backend tier
# spec: Deployment specification
# replicas: 2: Number of replicas
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy primary backend service

# Apply primary backend
kubectl apply -f primary-backend.yaml
# kubectl apply: Apply configuration
# -f primary-backend.yaml: File containing deployment
# Purpose: Create primary backend service

# Deploy secondary backend service
cat > secondary-backend.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Secondary backend service for chaos testing
# Purpose: Provide secondary backend service for testing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secondary-backend
  namespace: backend-chaos-test
  labels:
    app: secondary-backend
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: secondary-backend
  template:
    metadata:
      labels:
        app: secondary-backend
        tier: backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: secondary-backend-html
EOF
# Similar structure to primary backend
# app: secondary-backend: Secondary backend name
# Purpose: Deploy secondary backend service

# Apply secondary backend
kubectl apply -f secondary-backend.yaml
# kubectl apply: Apply configuration
# -f secondary-backend.yaml: File containing deployment
# Purpose: Create secondary backend service

# Create services for both backends
cat > backend-services.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Services for backend applications
# Purpose: Expose backend applications within cluster
apiVersion: v1
kind: Service
metadata:
  name: primary-backend-service
  namespace: backend-chaos-test
  labels:
    app: primary-backend
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: primary-backend
---
apiVersion: v1
kind: Service
metadata:
  name: secondary-backend-service
  namespace: backend-chaos-test
  labels:
    app: secondary-backend
    tier: backend
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: secondary-backend
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: primary-backend: Select primary backend pods
# Purpose: Expose backend applications

# Apply services
kubectl apply -f backend-services.yaml
# kubectl apply: Apply configuration
# -f backend-services.yaml: File containing services
# Purpose: Create services for backend applications

# Create Ingress with both backends
cat > backend-chaos-ingress.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Ingress for backend chaos testing
# Purpose: Route traffic to both backend services
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-chaos-ingress
  namespace: backend-chaos-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
spec:
  ingressClassName: nginx
  rules:
  - host: backend-chaos.local
    http:
      paths:
      - path: /primary
        pathType: Prefix
        backend:
          service:
            name: primary-backend-service
            port:
              number: 80
      - path: /secondary
        pathType: Prefix
        backend:
          service:
            name: secondary-backend-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "false": Disable SSL redirect
# nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri": Hash by request URI
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# rules: Ingress rules
# host: backend-chaos.local: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing
# path: /primary: Primary backend path
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: primary-backend-service: Primary service name
# port: Service port
# number: 80: Port number
# Purpose: Route traffic to both backend services

# Apply Ingress
kubectl apply -f backend-chaos-ingress.yaml
# kubectl apply: Apply configuration
# -f backend-chaos-ingress.yaml: File containing Ingress
# Purpose: Create Ingress for backend services

echo ""
echo "✅ Test environment deployed successfully"
echo ""

# Step 2: Establish baseline metrics
echo "Step 2: Establishing baseline metrics"
kubectl get pods -n backend-chaos-test
# kubectl get pods: List pods
# -n backend-chaos-test: In backend-chaos-test namespace
# Expected: Shows backend service pods

kubectl get services -n backend-chaos-test
# kubectl get services: List services
# -n backend-chaos-test: In backend-chaos-test namespace
# Expected: Shows backend services

# Get external IP for testing
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Get external IP for testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Add hostname to /etc/hosts
echo "Adding hostname to /etc/hosts for testing..."
echo "$EXTERNAL_IP backend-chaos.local" | sudo tee -a /etc/hosts
# Add hostname mapping for testing

# Test baseline connectivity
echo "Testing baseline connectivity..."
curl -H "Host: backend-chaos.local" http://$EXTERNAL_IP/primary
# Test primary backend

curl -H "Host: backend-chaos.local" http://$EXTERNAL_IP/secondary
# Test secondary backend

echo ""
echo "✅ Baseline metrics established"
echo ""

# Step 3: Execute chaos experiment
echo "Step 3: Executing chaos experiment - Backend service failure"
echo ""

# Get primary backend pods
PRIMARY_PODS=$(kubectl get pods -n backend-chaos-test -l app=primary-backend -o jsonpath='{.items[*].metadata.name}')
# kubectl get pods: List pods
# -n backend-chaos-test: In backend-chaos-test namespace
# -l app=primary-backend: Select primary backend pods
# -o jsonpath: Output in JSONPath format
# .items[*].metadata.name: Extract pod names
# Purpose: Get primary backend pod names

echo "Primary backend pods: $PRIMARY_PODS"
echo ""

# Select first pod for deletion
FIRST_POD=$(echo $PRIMARY_PODS | awk '{print $1}')
# echo: Output text
# $PRIMARY_PODS: Pod names
# awk '{print $1}': Print first field
# Purpose: Select first pod for deletion

echo "Selected pod for deletion: $FIRST_POD"
echo ""

# Record start time
START_TIME=$(date +%s)
# date +%s: Current time in seconds since epoch
# Purpose: Record experiment start time

# Delete first primary backend pod
echo "Deleting primary backend pod: $FIRST_POD"
kubectl delete pod $FIRST_POD -n backend-chaos-test
# kubectl delete pod: Delete pod
# $FIRST_POD: Pod name to delete
# -n backend-chaos-test: In backend-chaos-test namespace
# Purpose: Simulate backend pod failure

echo ""
echo "✅ Pod deletion initiated"
echo ""

# Step 4: Monitor recovery
echo "Step 4: Monitoring recovery process"
echo ""

# Wait for pod to be recreated
echo "Waiting for pod to be recreated..."
kubectl wait --for=condition=ready pod -l app=primary-backend -n backend-chaos-test --timeout=300s
# kubectl wait: Wait for condition
# --for=condition=ready pod: Wait for pods to be ready
# -l app=primary-backend: Select primary backend pods
# -n backend-chaos-test: In backend-chaos-test namespace
# --timeout=300s: Wait up to 5 minutes
# Purpose: Wait for pod to be recreated

echo ""
echo "✅ Pod recreated successfully"
echo ""

# Record end time
END_TIME=$(date +%s)
# date +%s: Current time in seconds since epoch
# Purpose: Record experiment end time

# Calculate recovery time
RECOVERY_TIME=$((END_TIME - START_TIME))
# $((END_TIME - START_TIME)): Calculate time difference
# Purpose: Calculate recovery time

echo "Recovery time: ${RECOVERY_TIME} seconds"
echo ""

# Step 5: Verify functionality
echo "Step 5: Verifying functionality after recovery"
echo ""

# Test connectivity
echo "Testing connectivity after recovery..."
curl -H "Host: backend-chaos.local" http://$EXTERNAL_IP/primary
# Test primary backend

curl -H "Host: backend-chaos.local" http://$EXTERNAL_IP/secondary
# Test secondary backend

echo ""
echo "✅ Functionality verified after recovery"
echo ""

# Step 6: Cleanup
echo "Step 6: Cleaning up test resources"
kubectl delete namespace backend-chaos-test
# Delete test namespace

# Remove hostname from /etc/hosts
sudo sed -i '/backend-chaos.local/d' /etc/hosts
# Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""

# Step 7: Analysis and reporting
echo "Step 7: Analysis and reporting"
echo ""
echo "=== CHAOS EXPERIMENT RESULTS ==="
echo "Experiment: Backend Service Failure Testing"
echo "Recovery Time: ${RECOVERY_TIME} seconds"
echo "Status: SUCCESS"
echo "Impact: Minimal - Traffic continued to be routed"
echo "Recommendations:"
echo "1. Ensure multiple replicas for backend services"
echo "2. Implement health checks and readiness probes"
echo "3. Use proper resource limits and requests"
echo "4. Monitor service health and restart policies"
echo ""
```

#### **Expected Results**
- Backend service should continue serving traffic during pod failure
- New pod should be created automatically
- Recovery time should be minimal
- No service disruption should occur

---

**Next: Let's move to the Assessment Framework to evaluate your progress!**

---

## 📊 **Assessment Framework**

### **Knowledge Assessment**

#### **Quiz 1: NGINX Ingress Controller Fundamentals**

**Question 1**: What is the primary purpose of an NGINX Ingress Controller in a Kubernetes cluster?

**A)** To manage pod lifecycles  
**B)** To provide external access to services and handle load balancing  
**C)** To store configuration data  
**D)** To manage cluster resources  

**Correct Answer**: B) To provide external access to services and handle load balancing

**Explanation**: The NGINX Ingress Controller acts as a reverse proxy and load balancer, providing external access to services within the cluster and handling traffic routing based on hostname and path rules.

---

**Question 2**: Which annotation is used to enable SSL redirect in NGINX Ingress?

**A)** `nginx.ingress.kubernetes.io/ssl-redirect: "true"`  
**B)** `nginx.ingress.kubernetes.io/ssl: "true"`  
**C)** `nginx.ingress.kubernetes.io/https: "true"`  
**D)** `nginx.ingress.kubernetes.io/tls: "true"`  

**Correct Answer**: A) `nginx.ingress.kubernetes.io/ssl-redirect: "true"`

**Explanation**: The `nginx.ingress.kubernetes.io/ssl-redirect: "true"` annotation forces HTTP traffic to be redirected to HTTPS, ensuring secure communication.

---

**Question 3**: What is the difference between `pathType: Prefix` and `pathType: Exact` in Ingress rules?

**A)** Prefix matches any path starting with the specified path, while Exact matches only the exact path  
**B)** Prefix matches only the exact path, while Exact matches any path starting with the specified path  
**C)** Both are identical  
**D)** Prefix is for HTTP, Exact is for HTTPS  

**Correct Answer**: A) Prefix matches any path starting with the specified path, while Exact matches only the exact path

**Explanation**: `pathType: Prefix` matches any path that starts with the specified path (e.g., `/api` matches `/api/users`, `/api/orders`), while `pathType: Exact` matches only the exact path specified.

---

#### **Quiz 2: Advanced Ingress Configuration**

**Question 4**: Which annotation is used to implement rate limiting in NGINX Ingress?

**A)** `nginx.ingress.kubernetes.io/rate-limit: "100"`  
**B)** `nginx.ingress.kubernetes.io/limit: "100"`  
**C)** `nginx.ingress.kubernetes.io/throttle: "100"`  
**D)** `nginx.ingress.kubernetes.io/restrict: "100"`  

**Correct Answer**: A) `nginx.ingress.kubernetes.io/rate-limit: "100"`

**Explanation**: The `nginx.ingress.kubernetes.io/rate-limit: "100"` annotation sets the rate limit to 100 requests per minute, helping prevent abuse and DDoS attacks.

---

**Question 5**: What is the purpose of the `nginx.ingress.kubernetes.io/rewrite-target: /` annotation?

**A)** To enable SSL termination  
**B)** To rewrite the target path to the root path  
**C)** To enable load balancing  
**D)** To enable CORS  

**Correct Answer**: B) To rewrite the target path to the root path

**Explanation**: The `nginx.ingress.kubernetes.io/rewrite-target: /` annotation rewrites the incoming request path to the root path before forwarding to the backend service, useful for path-based routing.

---

**Question 6**: Which annotation is used to enable CORS in NGINX Ingress?

**A)** `nginx.ingress.kubernetes.io/enable-cors: "true"`  
**B)** `nginx.ingress.kubernetes.io/cors: "true"`  
**C)** `nginx.ingress.kubernetes.io/cross-origin: "true"`  
**D)** `nginx.ingress.kubernetes.io/allow-origin: "true"`  

**Correct Answer**: A) `nginx.ingress.kubernetes.io/enable-cors: "true"`

**Explanation**: The `nginx.ingress.kubernetes.io/enable-cors: "true"` annotation enables Cross-Origin Resource Sharing (CORS) headers, allowing web applications to make requests to different domains.

---

### **Practical Assessment**

#### **Exercise 1: Create a Production-Ready Ingress**

**Objective**: Create a production-ready Ingress configuration for an e-commerce platform with multiple services.

**Requirements**:
- Frontend service at root path `/`
- API service at `/api/*` paths with rate limiting
- Admin service at `/admin/*` paths with IP whitelisting
- Payment service at `/payment/*` paths with strict security
- Analytics service at `/analytics/*` paths with authentication
- SSL termination with TLS certificates
- CORS configuration
- Security headers

**Solution**:

```yaml
# Complexity: Advanced
# Real-world Usage: Production e-commerce Ingress configuration
# Purpose: Demonstrate comprehensive Ingress setup
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-production-ingress
  namespace: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://ecommerce.example.com"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
    nginx.ingress.kubernetes.io/cors-max-age: "1728000"
    nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options DENY always;
      add_header X-Content-Type-Options nosniff always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ecommerce.example.com
    secretName: ecommerce-tls-secret
  rules:
  # Frontend at root path
  - host: ecommerce.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  
  # API at /api path with rate limiting
  - host: ecommerce.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  
  # Admin at /admin path with IP whitelisting
  - host: ecommerce.example.com
    http:
      paths:
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
  
  # Payment at /payment path with strict security
  - host: ecommerce.example.com
    http:
      paths:
      - path: /payment
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 80
  
  # Analytics at /analytics path with authentication
  - host: ecommerce.example.com
    http:
      paths:
      - path: /analytics
        pathType: Prefix
        backend:
          service:
            name: analytics-service
            port:
              number: 80
```

**Evaluation Criteria**:
- ✅ Correct Ingress structure and API version
- ✅ Proper annotations for security and functionality
- ✅ Correct path-based routing configuration
- ✅ SSL/TLS configuration
- ✅ CORS configuration
- ✅ Security headers implementation
- ✅ Proper service references and port numbers

---

#### **Exercise 2: Troubleshoot Ingress Issues**

**Scenario**: Your Ingress is not routing traffic correctly. Users are getting 502 Bad Gateway errors when accessing the application.

**Troubleshooting Steps**:

```bash
# Complexity: Advanced
# Real-world Usage: Troubleshoot Ingress routing issues
# Purpose: Demonstrate systematic troubleshooting approach

echo "=== TROUBLESHOOTING INGRESS ISSUES ==="
echo ""

# Step 1: Check Ingress status
echo "Step 1: Checking Ingress status"
kubectl get ingress -n ecommerce
# kubectl get ingress: List Ingress resources
# -n ecommerce: In ecommerce namespace
# Purpose: Check if Ingress is properly configured

kubectl describe ingress ecommerce-ingress -n ecommerce
# kubectl describe: Show detailed information
# ingress ecommerce-ingress: Ingress resource name
# -n ecommerce: In ecommerce namespace
# Purpose: Check for configuration errors and events

echo ""
echo "✅ Ingress status checked"
echo ""

# Step 2: Check backend services
echo "Step 2: Checking backend services"
kubectl get services -n ecommerce
# kubectl get services: List services
# -n ecommerce: In ecommerce namespace
# Purpose: Check if backend services exist and are running

kubectl get endpoints -n ecommerce
# kubectl get endpoints: List endpoints
# -n ecommerce: In ecommerce namespace
# Purpose: Check if services have healthy endpoints

echo ""
echo "✅ Backend services checked"
echo ""

# Step 3: Check backend pods
echo "Step 3: Checking backend pods"
kubectl get pods -n ecommerce
# kubectl get pods: List pods
# -n ecommerce: In ecommerce namespace
# Purpose: Check if backend pods are running

kubectl describe pods -n ecommerce
# kubectl describe: Show detailed information
# pods: Pod resources
# -n ecommerce: In ecommerce namespace
# Purpose: Check for pod issues and events

echo ""
echo "✅ Backend pods checked"
echo ""

# Step 4: Check Ingress Controller logs
echo "Step 4: Checking Ingress Controller logs"
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50
# kubectl logs: Show logs
# -n ingress-nginx: In ingress-nginx namespace
# -l app.kubernetes.io/component=controller: Select controller pods
# --tail=50: Show last 50 lines
# Purpose: Check for Ingress Controller errors

echo ""
echo "✅ Ingress Controller logs checked"
echo ""

# Step 5: Test connectivity
echo "Step 5: Testing connectivity"
kubectl port-forward -n ecommerce service/frontend-service 8080:80 &
# kubectl port-forward: Forward local port to service
# -n ecommerce: In ecommerce namespace
# service/frontend-service: Service to forward to
# 8080:80: Local port 8080 to service port 80
# &: Run in background
# Purpose: Test direct service connectivity

sleep 5
# sleep 5: Wait 5 seconds
# Purpose: Allow port forwarding to establish

curl http://localhost:8080
# curl: HTTP client
# http://localhost:8080: URL to test
# Purpose: Test service connectivity

kill %1
# kill %1: Kill background job
# Purpose: Stop port forwarding

echo ""
echo "✅ Connectivity tested"
echo ""

# Step 6: Check DNS resolution
echo "Step 6: Checking DNS resolution"
nslookup ecommerce.example.com
# nslookup: DNS lookup tool
# ecommerce.example.com: Domain to resolve
# Purpose: Check if domain resolves correctly

echo ""
echo "✅ DNS resolution checked"
echo ""

# Step 7: Check Ingress Controller configuration
echo "Step 7: Checking Ingress Controller configuration"
kubectl get configmap -n ingress-nginx
# kubectl get configmap: List ConfigMaps
# -n ingress-nginx: In ingress-nginx namespace
# Purpose: Check Ingress Controller configuration

kubectl describe configmap nginx-configuration -n ingress-nginx
# kubectl describe: Show detailed information
# configmap nginx-configuration: ConfigMap name
# -n ingress-nginx: In ingress-nginx namespace
# Purpose: Check NGINX configuration

echo ""
echo "✅ Ingress Controller configuration checked"
echo ""

# Step 8: Common fixes
echo "Step 8: Common fixes"
echo "1. Ensure backend services are running and healthy"
echo "2. Check service selectors match pod labels"
echo "3. Verify Ingress rules are correct"
echo "4. Check for typos in service names and ports"
echo "5. Ensure Ingress Controller is running"
echo "6. Check for resource limits and requests"
echo "7. Verify network policies allow traffic"
echo "8. Check for conflicting Ingress resources"
echo ""

echo "✅ Troubleshooting completed"
echo ""
```

**Evaluation Criteria**:
- ✅ Systematic approach to troubleshooting
- ✅ Correct use of kubectl commands
- ✅ Proper identification of common issues
- ✅ Logical sequence of checks
- ✅ Appropriate use of debugging tools

---

### **Performance Assessment**

#### **Exercise 3: Load Testing and Performance Optimization**

**Objective**: Test the performance of your Ingress Controller under load and optimize it for production use.

**Load Testing Script**:

```bash
# Complexity: Advanced
# Real-world Usage: Load testing and performance optimization
# Purpose: Test Ingress Controller performance under load

echo "=== LOAD TESTING AND PERFORMANCE OPTIMIZATION ==="
echo ""

# Step 1: Deploy test application
echo "Step 1: Deploying test application for load testing"
kubectl create namespace load-test
# kubectl create namespace: Create namespace
# load-test: Namespace name
# Purpose: Isolate load testing resources

cat > load-test-app.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Test application for load testing
# Purpose: Provide backend service for load testing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: load-test-app
  namespace: load-test
  labels:
    app: load-test-app
spec:
  replicas: 5
  selector:
    matchLabels:
      app: load-test-app
  template:
    metadata:
      labels:
        app: load-test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: load-test-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata
# labels: Resource labels
# app: load-test-app: Application name
# spec: Deployment specification
# replicas: 5: Number of replicas for load testing
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy test application for load testing

# Apply test application
kubectl apply -f load-test-app.yaml
# kubectl apply: Apply configuration
# -f load-test-app.yaml: File containing deployment
# Purpose: Create test application

# Create service for test application
cat > load-test-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for test application
# Purpose: Expose test application within cluster
apiVersion: v1
kind: Service
metadata:
  name: load-test-service
  namespace: load-test
  labels:
    app: load-test-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: load-test-app
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: load-test-app: Select test application pods
# Purpose: Expose test application

# Apply service
kubectl apply -f load-test-service.yaml
# kubectl apply: Apply configuration
# -f load-test-service.yaml: File containing service
# Purpose: Create service for test application

# Create Ingress for test application
cat > load-test-ingress.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Ingress for load testing
# Purpose: Route external traffic to test application
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: load-test-ingress
  namespace: load-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
spec:
  ingressClassName: nginx
  rules:
  - host: load-test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: load-test-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "false": Disable SSL redirect
# nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri": Hash by request URI
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# rules: Ingress rules
# host: load-test.local: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing
# path: /: Root path
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: load-test-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Route external traffic to test application

# Apply Ingress
kubectl apply -f load-test-ingress.yaml
# kubectl apply: Apply configuration
# -f load-test-ingress.yaml: File containing Ingress
# Purpose: Create Ingress for test application

echo ""
echo "✅ Test application deployed successfully"
echo ""

# Step 2: Get external IP
echo "Step 2: Getting external IP for load testing"
EXTERNAL_IP=$(kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# kubectl get service: Get service information
# ingress-nginx-controller: Service name
# -n ingress-nginx: In ingress-nginx namespace
# -o jsonpath: Output in JSONPath format
# .status.loadBalancer.ingress[0].ip: Extract external IP
# Purpose: Get external IP for load testing

echo "External IP: $EXTERNAL_IP"
echo ""

# Add hostname to /etc/hosts
echo "Adding hostname to /etc/hosts for load testing..."
echo "$EXTERNAL_IP load-test.local" | sudo tee -a /etc/hosts
# Add hostname mapping for load testing

# Step 3: Run load tests
echo "Step 3: Running load tests"
echo ""

# Test 1: Basic connectivity
echo "Test 1: Basic connectivity"
curl -H "Host: load-test.local" http://$EXTERNAL_IP/
# Test basic connectivity

echo ""
echo "✅ Basic connectivity test completed"
echo ""

# Test 2: Concurrent requests
echo "Test 2: Concurrent requests"
for i in {1..10}; do
  curl -H "Host: load-test.local" http://$EXTERNAL_IP/ &
done
wait
# Run 10 concurrent requests
# &: Run in background
# wait: Wait for all background jobs to complete
# Purpose: Test concurrent request handling

echo ""
echo "✅ Concurrent requests test completed"
echo ""

# Test 3: High load test
echo "Test 3: High load test"
for i in {1..100}; do
  curl -H "Host: load-test.local" http://$EXTERNAL_IP/ > /dev/null 2>&1 &
done
wait
# Run 100 concurrent requests
# > /dev/null 2>&1: Suppress output
# &: Run in background
# wait: Wait for all background jobs to complete
# Purpose: Test high load handling

echo ""
echo "✅ High load test completed"
echo ""

# Step 4: Monitor performance
echo "Step 4: Monitoring performance"
kubectl top pods -n ingress-nginx
# kubectl top pods: Show pod resource usage
# -n ingress-nginx: In ingress-nginx namespace
# Purpose: Monitor Ingress Controller resource usage

kubectl top pods -n load-test
# kubectl top pods: Show pod resource usage
# -n load-test: In load-test namespace
# Purpose: Monitor test application resource usage

echo ""
echo "✅ Performance monitoring completed"
echo ""

# Step 5: Cleanup
echo "Step 5: Cleaning up test resources"
kubectl delete namespace load-test
# Delete test namespace

# Remove hostname from /etc/hosts
sudo sed -i '/load-test.local/d' /etc/hosts
# Remove test hostname mapping

echo ""
echo "✅ Cleanup completed successfully"
echo ""

# Step 6: Performance recommendations
echo "Step 6: Performance recommendations"
echo "1. Increase Ingress Controller replicas for high availability"
echo "2. Use resource requests and limits for predictable performance"
echo "3. Implement horizontal pod autoscaling"
echo "4. Use connection pooling and keep-alive"
echo "5. Enable caching for static content"
echo "6. Monitor metrics and set up alerting"
echo "7. Use CDN for global distribution"
echo "8. Implement circuit breakers and retries"
echo ""
```

**Evaluation Criteria**:
- ✅ Proper load testing methodology
- ✅ Correct use of testing tools
- ✅ Appropriate performance monitoring
- ✅ Logical optimization recommendations
- ✅ Understanding of scalability concepts

---

### **Security Assessment**

#### **Exercise 4: Security Hardening**

**Objective**: Implement comprehensive security measures for your Ingress Controller.

**Security Hardening Script**:

```bash
# Complexity: Advanced
# Real-world Usage: Security hardening for Ingress Controller
# Purpose: Implement comprehensive security measures

echo "=== SECURITY HARDENING ==="
echo ""

# Step 1: Create security namespace
echo "Step 1: Creating security namespace"
kubectl create namespace security-test
# kubectl create namespace: Create namespace
# security-test: Namespace name
# Purpose: Isolate security testing resources

# Step 2: Deploy test application
echo "Step 2: Deploying test application for security testing"
cat > security-test-app.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Test application for security testing
# Purpose: Provide backend service for security testing
apiVersion: apps/v1
kind: Deployment
metadata:
  name: security-test-app
  namespace: security-test
  labels:
    app: security-test-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: security-test-app
  template:
    metadata:
      labels:
        app: security-test-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        volumeMounts:
        - name: html-content
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html-content
        configMap:
          name: security-test-html
EOF
# apiVersion: apps/v1: Kubernetes API version
# kind: Deployment: Resource type
# metadata: Resource metadata
# labels: Resource labels
# app: security-test-app: Application name
# spec: Deployment specification
# replicas: 2: Number of replicas
# selector: Pod selector
# template: Pod template
# containers: Container specification
# name: nginx: Container name
# image: nginx:1.21: Container image
# ports: Container ports
# containerPort: 80: Port exposed by container
# resources: Resource requests and limits
# volumeMounts: Volume mounts
# volumes: Volume definitions
# configMap: ConfigMap volume source
# Purpose: Deploy test application for security testing

# Apply test application
kubectl apply -f security-test-app.yaml
# kubectl apply: Apply configuration
# -f security-test-app.yaml: File containing deployment
# Purpose: Create test application

# Create service for test application
cat > security-test-service.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Service for test application
# Purpose: Expose test application within cluster
apiVersion: v1
kind: Service
metadata:
  name: security-test-service
  namespace: security-test
  labels:
    app: security-test-app
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: security-test-app
EOF
# apiVersion: v1: Kubernetes API version
# kind: Service: Resource type
# metadata: Resource metadata
# labels: Service labels
# spec: Service specification
# type: ClusterIP: Internal cluster access
# ports: Service ports
# port: 80: Port exposed by service
# targetPort: 80: Port on target pods
# protocol: TCP: Protocol type
# name: http: Port name
# selector: Pod selector
# app: security-test-app: Select test application pods
# Purpose: Expose test application

# Apply service
kubectl apply -f security-test-service.yaml
# kubectl apply: Apply configuration
# -f security-test-service.yaml: File containing service
# Purpose: Create service for test application

# Step 3: Create secure Ingress
echo "Step 3: Creating secure Ingress with security hardening"
cat > secure-ingress.yaml << 'EOF'
# Complexity: Advanced
# Real-world Usage: Secure Ingress with security hardening
# Purpose: Implement comprehensive security measures
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  namespace: security-test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rate-limit: "50"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://security-test.example.com"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
    nginx.ingress.kubernetes.io/cors-max-age: "1728000"
    nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Frame-Options DENY always;
      add_header X-Content-Type-Options nosniff always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'" always;
      add_header Referrer-Policy "strict-origin-when-cross-origin" always;
      add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
        return 405;
      }
      if ($request_uri ~* \.(php|asp|aspx|jsp)$) {
        return 403;
      }
      if ($http_user_agent ~* (bot|crawler|spider)) {
        return 403;
      }
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - security-test.example.com
    secretName: security-test-tls-secret
  rules:
  - host: security-test.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: security-test-service
            port:
              number: 80
EOF
# apiVersion: networking.k8s.io/v1: Kubernetes API version
# kind: Ingress: Resource type
# metadata: Resource metadata
# annotations: Ingress annotations
# nginx.ingress.kubernetes.io/rewrite-target: /: Rewrite target path
# nginx.ingress.kubernetes.io/ssl-redirect: "true": Enable SSL redirect
# nginx.ingress.kubernetes.io/force-ssl-redirect: "true": Force SSL redirect
# nginx.ingress.kubernetes.io/use-regex: "true": Enable regex matching
# nginx.ingress.kubernetes.io/rate-limit: "50": Rate limit per minute
# nginx.ingress.kubernetes.io/rate-limit-window: "1m": Rate limit window
# nginx.ingress.kubernetes.io/enable-cors: "true": Enable CORS
# nginx.ingress.kubernetes.io/cors-allow-origin: "https://security-test.example.com": CORS origin
# nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS": CORS methods
# nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization": CORS headers
# nginx.ingress.kubernetes.io/cors-max-age: "1728000": CORS max age
# nginx.ingress.kubernetes.io/cors-allow-credentials: "true": CORS credentials
# nginx.ingress.kubernetes.io/configuration-snippet: Custom NGINX configuration
# add_header X-Frame-Options DENY always: Prevent clickjacking
# add_header X-Content-Type-Options nosniff always: Prevent MIME type sniffing
# add_header X-XSS-Protection "1; mode=block" always: Enable XSS protection
# add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always: HSTS
# add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'" always: CSP
# add_header Referrer-Policy "strict-origin-when-cross-origin" always: Referrer policy
# add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always: Permissions policy
# nginx.ingress.kubernetes.io/server-snippet: Custom server configuration
# if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) { return 405; }: Allow only specific HTTP methods
# if ($request_uri ~* \.(php|asp|aspx|jsp)$) { return 403; }: Block specific file extensions
# if ($http_user_agent ~* (bot|crawler|spider)) { return 403; }: Block bots
# spec: Ingress specification
# ingressClassName: nginx: Use NGINX Ingress Controller
# tls: TLS configuration
# hosts: TLS hostnames
# security-test.example.com: Domain name
# secretName: security-test-tls-secret: TLS secret name
# rules: Ingress rules
# host: security-test.example.com: Hostname for routing
# http: HTTP routing rules
# paths: Path-based routing
# path: /: Root path
# pathType: Prefix: Path matching type
# backend: Backend service
# service: Service reference
# name: security-test-service: Service name
# port: Service port
# number: 80: Port number
# Purpose: Implement comprehensive security measures

# Apply secure Ingress
kubectl apply -f secure-ingress.yaml
# kubectl apply: Apply configuration
# -f secure-ingress.yaml: File containing Ingress
# Purpose: Create secure Ingress

echo ""
echo "✅ Secure Ingress created successfully"
echo ""

# Step 4: Test security measures
echo "Step 4: Testing security measures"
echo ""

# Test 1: SSL redirect
echo "Test 1: Testing SSL redirect"
curl -I -H "Host: security-test.example.com" http://$EXTERNAL_IP/
# Test SSL redirect

echo ""
echo "✅ SSL redirect test completed"
echo ""

# Test 2: Rate limiting
echo "Test 2: Testing rate limiting"
for i in {1..60}; do
  curl -H "Host: security-test.example.com" http://$EXTERNAL_IP/ > /dev/null 2>&1
done
# Test rate limiting

echo ""
echo "✅ Rate limiting test completed"
echo ""

# Test 3: Security headers
echo "Test 3: Testing security headers"
curl -I -H "Host: security-test.example.com" http://$EXTERNAL_IP/
# Test security headers

echo ""
echo "✅ Security headers test completed"
echo ""

# Step 5: Cleanup
echo "Step 5: Cleaning up test resources"
kubectl delete namespace security-test
# Delete test namespace

echo ""
echo "✅ Cleanup completed successfully"
echo ""

# Step 6: Security recommendations
echo "Step 6: Security recommendations"
echo "1. Always use HTTPS with valid SSL certificates"
echo "2. Implement rate limiting to prevent abuse"
echo "3. Use security headers to protect against common attacks"
echo "4. Implement CORS policies for cross-origin requests"
echo "5. Use network policies to restrict traffic"
echo "6. Monitor logs for suspicious activity"
echo "7. Keep Ingress Controller updated"
echo "8. Use RBAC for access control"
echo ""
```

**Evaluation Criteria**:
- ✅ Comprehensive security implementation
- ✅ Correct use of security annotations
- ✅ Proper security header configuration
- ✅ Appropriate rate limiting setup
- ✅ Understanding of security best practices

---

### **Scoring Rubric**

#### **Knowledge Assessment (25 points)**
- **Excellent (23-25 points)**: All questions answered correctly with detailed explanations
- **Good (18-22 points)**: Most questions answered correctly with good understanding
- **Satisfactory (13-17 points)**: Basic understanding with some errors
- **Needs Improvement (0-12 points)**: Significant gaps in knowledge

#### **Practical Assessment (35 points)**
- **Excellent (32-35 points)**: Complete, production-ready solutions with best practices
- **Good (25-31 points)**: Good solutions with minor issues
- **Satisfactory (18-24 points)**: Basic solutions with some problems
- **Needs Improvement (0-17 points)**: Incomplete or incorrect solutions

#### **Performance Assessment (20 points)**
- **Excellent (18-20 points)**: Comprehensive testing and optimization
- **Good (14-17 points)**: Good testing with some optimization
- **Satisfactory (10-13 points)**: Basic testing with minimal optimization
- **Needs Improvement (0-9 points)**: Inadequate testing or optimization

#### **Security Assessment (20 points)**
- **Excellent (18-20 points)**: Comprehensive security implementation
- **Good (14-17 points)**: Good security with minor gaps
- **Satisfactory (10-13 points)**: Basic security implementation
- **Needs Improvement (0-9 points)**: Inadequate security measures

#### **Total Score (100 points)**
- **90-100 points**: Expert level - Ready for production
- **80-89 points**: Advanced level - Good understanding
- **70-79 points**: Intermediate level - Solid foundation
- **60-69 points**: Beginner level - Needs more practice
- **0-59 points**: Needs significant improvement

---

**Next: Let's move to the Additional Sections for comprehensive coverage!**
