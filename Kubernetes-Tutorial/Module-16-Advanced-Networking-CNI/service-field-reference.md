# 🌐 **Service Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **Service Manifest Structure**

```yaml
apiVersion: v1                            # FIXED VALUE: v1
kind: Service                             # FIXED VALUE: Service
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  namespace: string                       # OPTIONAL: target namespace (default: default)
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs
    key: value                            # FORMAT: any string
    # COMMON ANNOTATIONS:
    service.beta.kubernetes.io/aws-load-balancer-type: string           # AWS LB type
    service.beta.kubernetes.io/azure-load-balancer-resource-group: string # Azure RG
    cloud.google.com/neg: string          # GCP NEG configuration
spec:
  type: string                            # OPTIONAL: ClusterIP|NodePort|LoadBalancer|ExternalName (default: ClusterIP)
  selector:                               # OPTIONAL: pod selector (not used for ExternalName)
    key: value                            # FORMAT: label key-value pairs
  ports:                                  # REQUIRED: array of port definitions (except ExternalName)
    - name: string                        # OPTIONAL: port name (required if multiple ports)
      protocol: string                    # OPTIONAL: TCP|UDP|SCTP (default: TCP)
      port: integer                       # REQUIRED: service port (1-65535)
      targetPort: int-or-string           # OPTIONAL: pod port (default: same as port)
      nodePort: integer                   # OPTIONAL: node port for NodePort/LoadBalancer (30000-32767)
      appProtocol: string                 # OPTIONAL: application protocol (1.20+)
  clusterIP: string                       # OPTIONAL: cluster IP address
  clusterIPs:                             # OPTIONAL: array of cluster IPs (dual-stack)
    - string
  externalIPs:                            # OPTIONAL: array of external IPs
    - string
  sessionAffinity: string                 # OPTIONAL: None|ClientIP (default: None)
  sessionAffinityConfig:                  # OPTIONAL: session affinity configuration
    clientIP:                             # OPTIONAL: client IP configuration
      timeoutSeconds: integer             # OPTIONAL: session timeout (default: 10800)
  externalName: string                    # REQUIRED for ExternalName type: external DNS name
  externalTrafficPolicy: string           # OPTIONAL: Cluster|Local (default: Cluster)
  healthCheckNodePort: integer            # OPTIONAL: health check node port
  internalTrafficPolicy: string           # OPTIONAL: Cluster|Local (default: Cluster, 1.22+)
  ipFamilies:                             # OPTIONAL: array of IP families (1.20+)
    - IPv4                                # VALUES: IPv4|IPv6
    - IPv6
  ipFamilyPolicy: string                  # OPTIONAL: SingleStack|PreferDualStack|RequireDualStack (1.20+)
  loadBalancerClass: string               # OPTIONAL: load balancer class (1.24+)
  loadBalancerIP: string                  # OPTIONAL: load balancer IP (deprecated)
  loadBalancerSourceRanges:               # OPTIONAL: array of CIDR blocks
    - string                              # FORMAT: CIDR notation
  publishNotReadyAddresses: boolean       # OPTIONAL: include not-ready endpoints (default: false)
  allocateLoadBalancerNodePorts: boolean  # OPTIONAL: allocate node ports for LB (default: true, 1.24+)
status:                                   # READ-ONLY: managed by system
  loadBalancer:                           # LoadBalancer status
    ingress:                              # Array of ingress points
      - ip: string                        # Load balancer IP
        hostname: string                  # Load balancer hostname
        ports:                            # Array of port status
          - port: integer                 # Port number
            protocol: string              # Protocol
            error: string                 # Error message
  conditions:                             # Array of service conditions
    - type: string                        # Condition type
      status: string                      # True|False|Unknown
      lastTransitionTime: string          # Last transition timestamp
      reason: string                      # Condition reason
      message: string                     # Human-readable message
```

## 📊 **Field Value Details**

### **type Values**
```yaml
type: ClusterIP                           # DEFAULT: internal cluster access only
type: NodePort                            # Expose on each node's IP at static port
type: LoadBalancer                        # Expose via cloud provider load balancer
type: ExternalName                        # Map to external DNS name (CNAME)

# TYPE CHARACTERISTICS:
# ClusterIP: 
#   - Accessible only within cluster
#   - Gets cluster IP from service CIDR
#   - Most common for internal services

# NodePort:
#   - Accessible from outside cluster via node IP:nodePort
#   - Automatically creates ClusterIP
#   - Port range: 30000-32767 (configurable)

# LoadBalancer:
#   - Cloud provider provisions external load balancer
#   - Automatically creates NodePort and ClusterIP
#   - Requires cloud controller manager

# ExternalName:
#   - Returns CNAME record for externalName
#   - No proxying, just DNS resolution
#   - No selector or ports needed
```

### **protocol Values**
```yaml
protocol: TCP                             # DEFAULT: Transmission Control Protocol
protocol: UDP                             # User Datagram Protocol
protocol: SCTP                            # Stream Control Transmission Protocol (1.20+)

# PROTOCOL SUPPORT:
# TCP: Fully supported, most common
# UDP: Supported, used for DNS, DHCP, etc.
# SCTP: Limited support, requires kernel support
```

### **port and targetPort Values**
```yaml
# NUMERIC PORTS:
port: 80                                  # Service port (required)
targetPort: 8080                          # Pod port (optional, defaults to port)

port: 443                                 # HTTPS service port
targetPort: 8443                          # Pod HTTPS port

# NAMED TARGET PORTS:
port: 80
targetPort: http                          # Must match container port name

port: 443
targetPort: https                         # Must match container port name

# PORT RANGES:
# Service ports: 1-65535
# Node ports: 30000-32767 (default range)
# Target ports: 1-65535 or named ports

# MULTIPLE PORTS:
ports:
  - name: http                            # Name required for multiple ports
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: https
    port: 443
    targetPort: 8443
    protocol: TCP
  - name: metrics
    port: 9090
    targetPort: metrics
    protocol: TCP
```

### **appProtocol Values (1.20+)**
```yaml
appProtocol: HTTP                         # HTTP protocol
appProtocol: HTTPS                        # HTTPS protocol
appProtocol: HTTP2                        # HTTP/2 protocol
appProtocol: GRPC                         # gRPC protocol
appProtocol: TCP                          # Generic TCP
appProtocol: UDP                          # Generic UDP

# CUSTOM PROTOCOLS:
appProtocol: mysql                        # MySQL protocol
appProtocol: postgres                     # PostgreSQL protocol
appProtocol: redis                        # Redis protocol
appProtocol: mongodb                      # MongoDB protocol
```

### **clusterIP Values**
```yaml
clusterIP: "10.96.1.100"                 # Specific IP from service CIDR
clusterIP: "None"                         # Headless service (no cluster IP)
clusterIP: ""                             # Auto-assign from service CIDR (default)

# DUAL-STACK (1.20+):
clusterIPs:
  - "10.96.1.100"                         # IPv4 cluster IP
  - "2001:db8::1"                         # IPv6 cluster IP

# HEADLESS SERVICE:
clusterIP: None                           # No load balancing, direct pod IPs
# Used for StatefulSets, service discovery
```

### **sessionAffinity Values**
```yaml
sessionAffinity: None                     # DEFAULT: no session affinity
sessionAffinity: ClientIP                 # Route requests from same client IP to same pod

# CLIENT IP CONFIGURATION:
sessionAffinity: ClientIP
sessionAffinityConfig:
  clientIP:
    timeoutSeconds: 10800                 # DEFAULT: 3 hours (10800 seconds)
    timeoutSeconds: 3600                  # 1 hour
    timeoutSeconds: 86400                 # 24 hours
```

### **externalTrafficPolicy Values**
```yaml
externalTrafficPolicy: Cluster            # DEFAULT: distribute to all nodes
externalTrafficPolicy: Local              # Only route to local node pods

# CLUSTER POLICY:
# - Traffic distributed across all cluster nodes
# - Source IP may be changed (SNAT)
# - Better load distribution
# - Extra network hop possible

# LOCAL POLICY:
# - Traffic only to pods on receiving node
# - Preserves source IP
# - Reduces network hops
# - May cause uneven load distribution
```

### **internalTrafficPolicy Values (1.22+)**
```yaml
internalTrafficPolicy: Cluster            # DEFAULT: distribute to all pods
internalTrafficPolicy: Local              # Only route to local node pods

# Similar to externalTrafficPolicy but for cluster-internal traffic
```

### **ipFamilyPolicy Values (1.20+)**
```yaml
ipFamilyPolicy: SingleStack               # DEFAULT: single IP family
ipFamilyPolicy: PreferDualStack           # Prefer dual-stack, fallback to single
ipFamilyPolicy: RequireDualStack          # Require dual-stack support

# SINGLE STACK:
ipFamilies: [IPv4]                        # IPv4 only
ipFamilies: [IPv6]                        # IPv6 only

# DUAL STACK:
ipFamilies: [IPv4, IPv6]                  # IPv4 primary, IPv6 secondary
ipFamilies: [IPv6, IPv4]                  # IPv6 primary, IPv4 secondary
```

### **Cloud Provider Annotations**

#### **AWS Load Balancer Annotations**
```yaml
annotations:
  # LOAD BALANCER TYPE:
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"              # Network Load Balancer
  service.beta.kubernetes.io/aws-load-balancer-type: "external"         # Classic/ALB (default)
  
  # NLB SPECIFIC:
  service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"    # Target type: ip|instance
  service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" # internet-facing|internal
  
  # ALB SPECIFIC:
  service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http" # Backend protocol
  service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..." # SSL certificate
  
  # SUBNETS:
  service.beta.kubernetes.io/aws-load-balancer-subnets: "subnet-12345,subnet-67890"
  
  # SECURITY GROUPS:
  service.beta.kubernetes.io/aws-load-balancer-security-groups: "sg-12345,sg-67890"
  
  # ACCESS LOGS:
  service.beta.kubernetes.io/aws-load-balancer-access-log-enabled: "true"
  service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-name: "my-logs-bucket"
  
  # CROSS-ZONE LOAD BALANCING:
  service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
  
  # CONNECTION DRAINING:
  service.beta.kubernetes.io/aws-load-balancer-connection-draining-enabled: "true"
  service.beta.kubernetes.io/aws-load-balancer-connection-draining-timeout: "300"
  
  # HEALTH CHECK:
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "2"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "2"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout: "5"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: "30"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/health"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "8080"
  service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol: "HTTP"
```

#### **GCP Load Balancer Annotations**
```yaml
annotations:
  # LOAD BALANCER TYPE:
  cloud.google.com/load-balancer-type: "External"                       # External|Internal
  
  # NEG (Network Endpoint Groups):
  cloud.google.com/neg: '{"ingress": true}'                            # Enable NEG for Ingress
  cloud.google.com/neg: '{"exposed_ports": {"80":{},"443":{}}}'        # Specific ports
  
  # BACKEND CONFIG:
  cloud.google.com/backend-config: '{"default": "my-backend-config"}'   # Backend configuration
  
  # FIREWALL:
  cloud.google.com/firewall-rule: "allow-health-checks"                # Firewall rule name
  
  # GLOBAL ACCESS:
  networking.gke.io/load-balancer-type: "Internal"                     # Internal LB
  networking.gke.io/internal-load-balancer-allow-global-access: "true" # Global access
```

#### **Azure Load Balancer Annotations**
```yaml
annotations:
  # LOAD BALANCER TYPE:
  service.beta.kubernetes.io/azure-load-balancer-internal: "true"      # Internal LB
  
  # RESOURCE GROUP:
  service.beta.kubernetes.io/azure-load-balancer-resource-group: "my-rg"
  
  # SUBNET:
  service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "my-subnet"
  
  # SKU:
  service.beta.kubernetes.io/azure-load-balancer-sku: "Standard"       # Basic|Standard
  
  # HEALTH PROBE:
  service.beta.kubernetes.io/azure-load-balancer-health-probe-num-of-probe: "3"
  service.beta.kubernetes.io/azure-load-balancer-health-probe-interval: "5"
  
  # PIP (Public IP):
  service.beta.kubernetes.io/azure-pip-name: "my-public-ip"
  service.beta.kubernetes.io/azure-pip-resource-group: "my-pip-rg"
```

## 🎯 **Complete Service Examples**

### **ClusterIP Service (Internal)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: production
  labels:
    app: backend
    tier: api
spec:
  type: ClusterIP
  selector:
    app: backend
    tier: api
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: metrics
      port: 9090
      targetPort: metrics
      protocol: TCP
  sessionAffinity: None
```

### **NodePort Service (External Access)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
  namespace: web
  labels:
    app: frontend
    exposure: external
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - name: http
      port: 80
      targetPort: 3000
      nodePort: 30080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 3443
      nodePort: 30443
      protocol: TCP
  externalTrafficPolicy: Local
```

### **LoadBalancer Service (Cloud Provider)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
  namespace: production
  labels:
    app: web
    tier: frontend
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  selector:
    app: web
    tier: frontend
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 8443
      protocol: TCP
  externalTrafficPolicy: Local
  loadBalancerSourceRanges:
    - "203.0.113.0/24"                    # Restrict access to specific CIDR
    - "198.51.100.0/24"
```

### **Headless Service (StatefulSet)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: database-headless
  namespace: data
  labels:
    app: postgres
    service-type: headless
spec:
  type: ClusterIP
  clusterIP: None                         # Headless service
  selector:
    app: postgres
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
      protocol: TCP
  publishNotReadyAddresses: true          # Include not-ready pods
```

### **ExternalName Service (External DNS)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-database
  namespace: production
  labels:
    service-type: external
spec:
  type: ExternalName
  externalName: database.example.com      # External DNS name
  ports:
    - name: postgres
      port: 5432
      protocol: TCP
```

### **Dual-Stack Service (IPv4/IPv6)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: dual-stack-service
  namespace: network-test
spec:
  type: ClusterIP
  ipFamilyPolicy: RequireDualStack
  ipFamilies:
    - IPv4
    - IPv6
  selector:
    app: dual-stack-app
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
```

## 🔍 **Validation Rules**

### **Port Validation**
```yaml
# VALID PORT RANGES:
port: 1                                   # Minimum service port
port: 65535                               # Maximum service port
nodePort: 30000                           # Minimum node port (default)
nodePort: 32767                           # Maximum node port (default)

# INVALID PORTS:
port: 0                                   # Port 0 not allowed
port: 65536                               # Port > 65535 not allowed
nodePort: 29999                           # Below minimum node port range
nodePort: 32768                           # Above maximum node port range
```

### **Selector Validation**
```yaml
# VALID SELECTORS:
selector:
  app: frontend                           # Simple label match
  tier: web
  version: v1.0

selector: {}                              # Empty selector (matches all pods)

# INVALID FOR EXTERNALNAME:
spec:
  type: ExternalName
  selector:                               # INVALID: ExternalName doesn't use selector
    app: frontend
```

### **ExternalName Validation**
```yaml
# VALID EXTERNAL NAMES:
externalName: database.example.com        # FQDN
externalName: api.service.consul          # Consul service
externalName: redis.cache.local           # Local domain

# INVALID EXTERNAL NAMES:
externalName: ""                          # Empty string not allowed
externalName: "192.168.1.100"            # IP addresses not recommended
```
