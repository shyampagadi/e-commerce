# 🌐 **Ingress Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **Ingress Manifest Structure**

```yaml
apiVersion: networking.k8s.io/v1          # FIXED VALUE: networking.k8s.io/v1
kind: Ingress                             # FIXED VALUE: Ingress
metadata:
  name: string                            # REQUIRED: DNS-1123 subdomain
  namespace: string                       # OPTIONAL: target namespace (default: default)
  labels:                                 # OPTIONAL: key-value pairs
    key: value
  annotations:                            # OPTIONAL: key-value pairs (controller-specific)
    key: value                            # FORMAT: any string
    # COMMON ANNOTATIONS (controller-specific):
    kubernetes.io/ingress.class: string                    # Ingress class (deprecated)
    nginx.ingress.kubernetes.io/rewrite-target: string     # NGINX rewrite
    cert-manager.io/cluster-issuer: string                 # Cert-manager issuer
spec:
  ingressClassName: string                # OPTIONAL: ingress class name (1.18+)
  defaultBackend:                         # OPTIONAL: default backend service
    service:                              # SERVICE BACKEND
      name: string                        # REQUIRED: service name
      port:                               # REQUIRED: service port
        number: integer                   # OPTION 1: port number
        name: string                      # OPTION 2: port name
    resource:                             # RESOURCE BACKEND (alternative to service)
      apiGroup: string                    # REQUIRED: resource API group
      kind: string                        # REQUIRED: resource kind
      name: string                        # REQUIRED: resource name
  tls:                                    # OPTIONAL: TLS configuration
    - hosts:                              # OPTIONAL: array of hostnames
        - string                          # FORMAT: DNS hostname
      secretName: string                  # OPTIONAL: TLS secret name
  rules:                                  # OPTIONAL: array of ingress rules
    - host: string                        # OPTIONAL: hostname (if empty, applies to all)
      http:                               # REQUIRED: HTTP rule configuration
        paths:                            # REQUIRED: array of path rules
          - path: string                  # OPTIONAL: URL path (default: /)
            pathType: string              # REQUIRED: Exact|Prefix|ImplementationSpecific
            backend:                      # REQUIRED: backend configuration
              service:                    # SERVICE BACKEND
                name: string              # REQUIRED: service name
                port:                     # REQUIRED: service port
                  number: integer         # OPTION 1: port number
                  name: string            # OPTION 2: port name
              resource:                   # RESOURCE BACKEND (alternative)
                apiGroup: string          # REQUIRED: resource API group
                kind: string              # REQUIRED: resource kind
                name: string              # REQUIRED: resource name
status:                                   # READ-ONLY: managed by system
  loadBalancer:                           # Load balancer status
    ingress:                              # Array of ingress points
      - ip: string                        # Load balancer IP
        hostname: string                  # Load balancer hostname
        ports:                            # Array of port status
          - port: integer                 # Port number
            protocol: string              # Protocol
            error: string                 # Error message
```

## 📊 **Field Value Details**

### **ingressClassName Values**
```yaml
# COMMON INGRESS CLASSES:
ingressClassName: "nginx"                 # NGINX Ingress Controller
ingressClassName: "traefik"               # Traefik Ingress Controller
ingressClassName: "haproxy"               # HAProxy Ingress Controller
ingressClassName: "istio"                 # Istio Gateway
ingressClassName: "contour"               # Contour Ingress Controller
ingressClassName: "ambassador"            # Ambassador API Gateway

# CLOUD PROVIDER CLASSES:
ingressClassName: "alb"                   # AWS Application Load Balancer
ingressClassName: "gce"                   # Google Cloud Load Balancer
ingressClassName: "azure/application-gateway"  # Azure Application Gateway

# CUSTOM CLASSES:
ingressClassName: "internal-nginx"        # Custom internal class
ingressClassName: "external-nginx"        # Custom external class
```

### **pathType Values**
```yaml
pathType: Exact                           # Exact path match (case-sensitive)
pathType: Prefix                          # Path prefix match
pathType: ImplementationSpecific          # Controller-specific matching

# PATH TYPE EXAMPLES:
# Exact: "/api/v1" matches only "/api/v1"
# Prefix: "/api" matches "/api", "/api/", "/api/v1", "/api/v1/users"
# ImplementationSpecific: depends on ingress controller (often regex)
```

### **path Values**
```yaml
# ROOT PATH:
path: "/"                                 # Root path (matches all)

# EXACT PATHS:
path: "/api"                              # Exact API path
path: "/health"                           # Health check endpoint
path: "/metrics"                          # Metrics endpoint

# PREFIX PATHS:
path: "/api/"                             # API prefix with trailing slash
path: "/static"                           # Static content prefix
path: "/uploads"                          # File upload prefix

# IMPLEMENTATION-SPECIFIC (controller dependent):
path: "/api/v[0-9]+"                      # Regex pattern (some controllers)
path: "/*"                                # Wildcard (some controllers)
path: "/api/.*"                           # Regex wildcard

# SPECIAL CHARACTERS (URL encoded):
path: "/api%20v1"                         # Space encoded as %20
path: "/caf%C3%A9"                        # Unicode characters
```

### **host Values**
```yaml
# EXACT HOSTNAMES:
host: "example.com"                       # Exact hostname
host: "api.example.com"                   # Subdomain
host: "www.example.com"                   # WWW subdomain

# WILDCARD HOSTNAMES (controller dependent):
host: "*.example.com"                     # Wildcard subdomain (some controllers)

# IP ADDRESSES (not recommended):
host: "192.168.1.100"                     # IP address (avoid if possible)

# INTERNATIONALIZED DOMAIN NAMES:
host: "café.example.com"                  # Unicode domain (punycode encoded)
host: "xn--caf-dma.example.com"          # Punycode encoded

# INVALID HOSTS:
host: ""                                  # Empty string (use no host field instead)
host: "example.com:8080"                  # Port not allowed in host field
```

### **TLS Configuration**
```yaml
# SINGLE DOMAIN TLS:
tls:
  - hosts:
      - "example.com"
    secretName: "example-com-tls"

# MULTIPLE DOMAINS (SAN certificate):
tls:
  - hosts:
      - "example.com"
      - "www.example.com"
      - "api.example.com"
    secretName: "example-com-wildcard-tls"

# WILDCARD CERTIFICATE:
tls:
  - hosts:
      - "*.example.com"
    secretName: "wildcard-example-com-tls"

# MULTIPLE TLS CONFIGURATIONS:
tls:
  - hosts:
      - "example.com"
    secretName: "example-com-tls"
  - hosts:
      - "api.example.com"
    secretName: "api-example-com-tls"

# DEFAULT TLS (no hosts specified):
tls:
  - secretName: "default-tls"              # Applies to all hosts
```

## 🎯 **Controller-Specific Annotations**

### **NGINX Ingress Controller**
```yaml
annotations:
  # BASIC CONFIGURATION:
  nginx.ingress.kubernetes.io/rewrite-target: "/"                       # Rewrite URL path
  nginx.ingress.kubernetes.io/ssl-redirect: "true"                      # Force HTTPS redirect
  nginx.ingress.kubernetes.io/force-ssl-redirect: "true"                # Force SSL redirect
  
  # PATH REWRITING:
  nginx.ingress.kubernetes.io/rewrite-target: "/$2"                     # Capture group rewrite
  nginx.ingress.kubernetes.io/use-regex: "true"                         # Enable regex in paths
  
  # BACKEND CONFIGURATION:
  nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"                 # Backend protocol
  nginx.ingress.kubernetes.io/upstream-vhost: "internal.example.com"    # Upstream host header
  
  # LOAD BALANCING:
  nginx.ingress.kubernetes.io/load-balance: "round_robin"               # round_robin|least_conn|ip_hash
  nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"          # Consistent hashing
  
  # RATE LIMITING:
  nginx.ingress.kubernetes.io/rate-limit-connections: "10"              # Connection limit
  nginx.ingress.kubernetes.io/rate-limit-requests-per-minute: "60"      # Request rate limit
  nginx.ingress.kubernetes.io/rate-limit-window-size: "1m"              # Rate limit window
  
  # AUTHENTICATION:
  nginx.ingress.kubernetes.io/auth-type: "basic"                        # Authentication type
  nginx.ingress.kubernetes.io/auth-secret: "basic-auth-secret"          # Auth secret name
  nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"     # Auth realm
  
  # CORS:
  nginx.ingress.kubernetes.io/enable-cors: "true"                       # Enable CORS
  nginx.ingress.kubernetes.io/cors-allow-origin: "*"                    # Allowed origins
  nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT"      # Allowed methods
  nginx.ingress.kubernetes.io/cors-allow-headers: "Authorization"       # Allowed headers
  
  # CUSTOM HEADERS:
  nginx.ingress.kubernetes.io/configuration-snippet: |                  # Custom NGINX config
    more_set_headers "X-Custom-Header: value";
  
  # TIMEOUTS:
  nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"               # Connect timeout
  nginx.ingress.kubernetes.io/proxy-send-timeout: "60"                  # Send timeout
  nginx.ingress.kubernetes.io/proxy-read-timeout: "60"                  # Read timeout
  
  # BODY SIZE:
  nginx.ingress.kubernetes.io/proxy-body-size: "100m"                   # Max body size
  
  # WEBSOCKETS:
  nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"                # WebSocket timeout
  nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"                # WebSocket timeout
```

### **Traefik Ingress Controller**
```yaml
annotations:
  # BASIC CONFIGURATION:
  traefik.ingress.kubernetes.io/router.entrypoints: "web,websecure"     # Entry points
  traefik.ingress.kubernetes.io/router.middlewares: "default-auth@kubernetescrd"  # Middlewares
  
  # TLS:
  traefik.ingress.kubernetes.io/router.tls: "true"                      # Enable TLS
  traefik.ingress.kubernetes.io/router.tls.certresolver: "letsencrypt"  # Cert resolver
  
  # LOAD BALANCING:
  traefik.ingress.kubernetes.io/service.loadbalancer.method: "wrr"      # Weighted round robin
  traefik.ingress.kubernetes.io/service.loadbalancer.sticky: "true"     # Sticky sessions
  
  # RATE LIMITING:
  traefik.ingress.kubernetes.io/router.middlewares: "default-ratelimit@kubernetescrd"
```

### **AWS ALB Ingress Controller**
```yaml
annotations:
  # BASIC CONFIGURATION:
  kubernetes.io/ingress.class: "alb"                                    # ALB ingress class
  alb.ingress.kubernetes.io/scheme: "internet-facing"                   # internet-facing|internal
  alb.ingress.kubernetes.io/target-type: "ip"                           # ip|instance
  
  # LOAD BALANCER:
  alb.ingress.kubernetes.io/load-balancer-name: "my-alb"                # ALB name
  alb.ingress.kubernetes.io/group.name: "my-group"                      # ALB group
  
  # SUBNETS:
  alb.ingress.kubernetes.io/subnets: "subnet-12345,subnet-67890"        # Subnet IDs
  
  # SECURITY GROUPS:
  alb.ingress.kubernetes.io/security-groups: "sg-12345,sg-67890"        # Security group IDs
  
  # SSL:
  alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:..."          # ACM certificate ARN
  alb.ingress.kubernetes.io/ssl-policy: "ELBSecurityPolicy-TLS-1-2-2017-01"  # SSL policy
  alb.ingress.kubernetes.io/ssl-redirect: "443"                         # SSL redirect port
  
  # HEALTH CHECK:
  alb.ingress.kubernetes.io/healthcheck-path: "/health"                 # Health check path
  alb.ingress.kubernetes.io/healthcheck-interval-seconds: "30"          # Health check interval
  alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "5"            # Health check timeout
  alb.ingress.kubernetes.io/healthy-threshold-count: "2"                # Healthy threshold
  alb.ingress.kubernetes.io/unhealthy-threshold-count: "2"              # Unhealthy threshold
  
  # BACKEND PROTOCOL:
  alb.ingress.kubernetes.io/backend-protocol: "HTTP"                    # HTTP|HTTPS
  alb.ingress.kubernetes.io/backend-protocol-version: "HTTP1"           # HTTP1|HTTP2|GRPC
  
  # TAGS:
  alb.ingress.kubernetes.io/tags: "Environment=Production,Team=Backend"  # ALB tags
```

### **Cert-Manager Integration**
```yaml
annotations:
  # CERTIFICATE ISSUER:
  cert-manager.io/cluster-issuer: "letsencrypt-prod"                    # ClusterIssuer name
  cert-manager.io/issuer: "letsencrypt-staging"                        # Issuer name (namespace-scoped)
  
  # ACME CHALLENGE:
  cert-manager.io/acme-challenge-type: "http01"                        # http01|dns01
  cert-manager.io/acme-http01-edit-in-place: "true"                    # Edit ingress in place
  
  # DNS CHALLENGE:
  cert-manager.io/acme-dns01-provider: "route53"                       # DNS provider
  
  # CERTIFICATE CONFIGURATION:
  cert-manager.io/common-name: "example.com"                           # Certificate common name
  cert-manager.io/subject-organizations: "My Company"                   # Certificate organization
  cert-manager.io/duration: "2160h"                                    # Certificate duration (90 days)
  cert-manager.io/renew-before: "360h"                                 # Renew before expiry (15 days)
```

## 🎯 **Complete Ingress Examples**

### **Basic HTTP Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: basic-ingress
  namespace: web
  labels:
    app: web
spec:
  ingressClassName: nginx
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
```

### **Multi-Path Ingress with TLS**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-path-ingress
  namespace: production
  labels:
    app: ecommerce
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.example.com
      secretName: api-example-com-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /api/v1
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /health
            pathType: Exact
            backend:
              service:
                name: health-service
                port:
                  name: health
          - path: /metrics
            pathType: Exact
            backend:
              service:
                name: metrics-service
                port:
                  number: 9090
```

### **Advanced NGINX Ingress with Authentication**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-admin-ingress
  namespace: admin
  annotations:
    nginx.ingress.kubernetes.io/auth-type: "basic"
    nginx.ingress.kubernetes.io/auth-secret: "admin-auth"
    nginx.ingress.kubernetes.io/auth-realm: "Admin Area"
    nginx.ingress.kubernetes.io/rate-limit-connections: "5"
    nginx.ingress.kubernetes.io/rate-limit-requests-per-minute: "30"
    nginx.ingress.kubernetes.io/whitelist-source-range: "203.0.113.0/24,198.51.100.0/24"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Frame-Options: DENY";
      more_set_headers "X-Content-Type-Options: nosniff";
      more_set_headers "X-XSS-Protection: 1; mode=block";
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - admin.example.com
      secretName: admin-example-com-tls
  rules:
    - host: admin.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: admin-dashboard
                port:
                  number: 3000
```

### **AWS ALB Ingress with Multiple Services**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aws-alb-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/target-type: "ip"
    alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    alb.ingress.kubernetes.io/ssl-policy: "ELBSecurityPolicy-TLS-1-2-2017-01"
    alb.ingress.kubernetes.io/backend-protocol: "HTTP"
    alb.ingress.kubernetes.io/healthcheck-path: "/health"
    alb.ingress.kubernetes.io/tags: "Environment=Production,Application=ECommerce"
spec:
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
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: backend-service
                port:
                  number: 8080
```

### **Fanout Ingress (Multiple Hosts)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fanout-ingress
  namespace: multi-tenant
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - "*.example.com"
      secretName: wildcard-example-com-tls
  rules:
    - host: app1.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app1-service
                port:
                  number: 80
    - host: app2.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app2-service
                port:
                  number: 80
    - host: api.example.com
      http:
        paths:
          - path: /v1
            pathType: Prefix
            backend:
              service:
                name: api-v1-service
                port:
                  number: 8080
          - path: /v2
            pathType: Prefix
            backend:
              service:
                name: api-v2-service
                port:
                  number: 8080
```

## 🔍 **Validation Rules**

### **Path Validation**
```yaml
# VALID PATHS:
path: "/"                                 # Root path
path: "/api"                              # Simple path
path: "/api/v1"                           # Nested path
path: "/static/*"                         # Wildcard (controller dependent)

# INVALID PATHS:
path: ""                                  # Empty string (use "/" instead)
path: "api"                               # Must start with "/"
path: "/api/"                             # Trailing slash may cause issues
```

### **Host Validation**
```yaml
# VALID HOSTS:
host: "example.com"                       # Valid DNS name
host: "api.example.com"                   # Subdomain
host: "app-1.example.com"                 # Hyphenated subdomain

# INVALID HOSTS:
host: "example.com:8080"                  # Port not allowed
host: "example..com"                      # Double dots not allowed
host: "-example.com"                      # Cannot start with hyphen
```

### **Backend Validation**
```yaml
# VALID BACKENDS:
backend:
  service:
    name: "existing-service"              # Service must exist in same namespace
    port:
      number: 80                          # Port must exist on service

# INVALID BACKENDS:
backend:
  service:
    name: ""                              # Empty service name not allowed
    port:
      number: 0                           # Port 0 not allowed
```
