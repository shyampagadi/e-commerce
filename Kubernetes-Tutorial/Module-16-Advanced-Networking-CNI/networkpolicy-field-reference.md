# 🌐 **NetworkPolicy Complete Field Reference**
*Exhaustive list of all fields, options, and possible values*

## 🔧 **NetworkPolicy Manifest Structure**

```yaml
apiVersion: networking.k8s.io/v1           # FIXED VALUE: networking.k8s.io/v1
kind: NetworkPolicy                        # FIXED VALUE: NetworkPolicy
metadata:
  name: string                             # REQUIRED: DNS-1123 subdomain
  namespace: string                        # REQUIRED: target namespace
  labels:                                  # OPTIONAL: key-value pairs
    key: value                             # FORMAT: DNS-1123 label format
  annotations:                             # OPTIONAL: key-value pairs
    key: value                             # FORMAT: any string
spec:
  podSelector:                             # REQUIRED: pod selector
    matchLabels:                           # OPTIONAL: exact label matches
      key: value                           # FORMAT: label key-value pairs
    matchExpressions:                      # OPTIONAL: expression-based matching
      - key: string                        # REQUIRED: label key
        operator: string                   # REQUIRED: In|NotIn|Exists|DoesNotExist
        values:                            # OPTIONAL: array of strings (required for In|NotIn)
          - string
  policyTypes:                             # REQUIRED: array of policy types
    - Ingress                              # VALUES: Ingress|Egress (can have both)
    - Egress
  ingress:                                 # OPTIONAL: ingress rules (required if Ingress in policyTypes)
    - from:                                # OPTIONAL: source selectors (empty = allow all)
        - podSelector:                     # OPTIONAL: pod-based source selection
            matchLabels:                   # OPTIONAL: exact label matches
              key: value
            matchExpressions:              # OPTIONAL: expression-based matching
              - key: string                # REQUIRED: label key
                operator: string           # REQUIRED: In|NotIn|Exists|DoesNotExist
                values:                    # OPTIONAL: array of strings
                  - string
        - namespaceSelector:               # OPTIONAL: namespace-based source selection
            matchLabels:                   # OPTIONAL: exact label matches
              key: value
            matchExpressions:              # OPTIONAL: expression-based matching
              - key: string                # REQUIRED: label key
                operator: string           # REQUIRED: In|NotIn|Exists|DoesNotExist
                values:                    # OPTIONAL: array of strings
                  - string
        - ipBlock:                         # OPTIONAL: IP-based source selection
            cidr: string                   # REQUIRED: CIDR notation (e.g., 192.168.1.0/24)
            except:                        # OPTIONAL: array of CIDR blocks to exclude
              - string                     # FORMAT: CIDR notation
      ports:                               # OPTIONAL: port specifications (empty = all ports)
        - protocol: string                 # OPTIONAL: TCP|UDP|SCTP (default: TCP)
          port: int-or-string              # OPTIONAL: port number or name
          endPort: integer                 # OPTIONAL: end port for range (1.25+)
  egress:                                  # OPTIONAL: egress rules (required if Egress in policyTypes)
    - to:                                  # OPTIONAL: destination selectors (empty = allow all)
        - podSelector:                     # OPTIONAL: pod-based destination selection
            matchLabels:                   # OPTIONAL: exact label matches
              key: value
            matchExpressions:              # OPTIONAL: expression-based matching
              - key: string                # REQUIRED: label key
                operator: string           # REQUIRED: In|NotIn|Exists|DoesNotExist
                values:                    # OPTIONAL: array of strings
                  - string
        - namespaceSelector:               # OPTIONAL: namespace-based destination selection
            matchLabels:                   # OPTIONAL: exact label matches
              key: value
            matchExpressions:              # OPTIONAL: expression-based matching
              - key: string                # REQUIRED: label key
                operator: string           # REQUIRED: In|NotIn|Exists|DoesNotExist
                values:                    # OPTIONAL: array of strings
                  - string
        - ipBlock:                         # OPTIONAL: IP-based destination selection
            cidr: string                   # REQUIRED: CIDR notation
            except:                        # OPTIONAL: array of CIDR blocks to exclude
              - string                     # FORMAT: CIDR notation
      ports:                               # OPTIONAL: port specifications (empty = all ports)
        - protocol: string                 # OPTIONAL: TCP|UDP|SCTP (default: TCP)
          port: int-or-string              # OPTIONAL: port number or name
          endPort: integer                 # OPTIONAL: end port for range (1.25+)
```

## 📊 **Field Value Details**

### **podSelector Values**
```yaml
# EMPTY SELECTOR (matches all pods in namespace):
podSelector: {}

# LABEL-BASED SELECTION:
podSelector:
  matchLabels:
    app: frontend                          # Exact match: app=frontend
    tier: web                             # Exact match: tier=web
    version: v1.0                         # Exact match: version=v1.0

# EXPRESSION-BASED SELECTION:
podSelector:
  matchExpressions:
    - key: app
      operator: In
      values: [frontend, backend]         # app in (frontend, backend)
    - key: tier
      operator: NotIn
      values: [database]                  # tier not in (database)
    - key: environment
      operator: Exists                    # environment label exists
    - key: deprecated
      operator: DoesNotExist              # deprecated label does not exist

# COMBINED SELECTION (AND logic):
podSelector:
  matchLabels:
    app: frontend
  matchExpressions:
    - key: version
      operator: In
      values: [v1.0, v1.1]
```

### **policyTypes Values**
```yaml
# INGRESS ONLY:
policyTypes:
  - Ingress                              # Control incoming traffic only

# EGRESS ONLY:
policyTypes:
  - Egress                               # Control outgoing traffic only

# BOTH INGRESS AND EGRESS:
policyTypes:
  - Ingress                              # Control both incoming and outgoing traffic
  - Egress

# EMPTY (invalid):
policyTypes: []                          # INVALID: must specify at least one type
```

### **Protocol Values**
```yaml
# SUPPORTED PROTOCOLS:
protocol: TCP                            # Transmission Control Protocol (default)
protocol: UDP                            # User Datagram Protocol
protocol: SCTP                           # Stream Control Transmission Protocol

# CASE SENSITIVITY:
protocol: tcp                            # INVALID: must be uppercase
protocol: Tcp                            # INVALID: must be uppercase
```

### **Port Values**
```yaml
# NUMERIC PORTS:
port: 80                                 # HTTP port
port: 443                                # HTTPS port
port: 3306                               # MySQL port
port: 5432                               # PostgreSQL port
port: 6379                               # Redis port
port: 8080                               # Alternative HTTP port

# NAMED PORTS (must match container port name):
port: http                               # Container port named "http"
port: https                              # Container port named "https"
port: api                                # Container port named "api"
port: metrics                            # Container port named "metrics"

# PORT RANGES (Kubernetes 1.25+):
port: 8000
endPort: 8999                            # Ports 8000-8999

# INVALID VALUES:
port: 0                                  # Port 0 not allowed
port: 65536                              # Port > 65535 not allowed
port: "80"                               # String numbers not recommended
```

### **CIDR Block Values**
```yaml
# IPv4 CIDR BLOCKS:
cidr: "0.0.0.0/0"                       # All IPv4 addresses (internet)
cidr: "10.0.0.0/8"                      # Private Class A network
cidr: "172.16.0.0/12"                   # Private Class B network
cidr: "192.168.0.0/16"                  # Private Class C network
cidr: "127.0.0.0/8"                     # Loopback network
cidr: "169.254.0.0/16"                  # Link-local network
cidr: "224.0.0.0/4"                     # Multicast network

# SPECIFIC SUBNETS:
cidr: "10.244.0.0/16"                   # Kubernetes pod network (common)
cidr: "10.96.0.0/12"                    # Kubernetes service network (common)
cidr: "192.168.1.0/24"                  # Local subnet
cidr: "203.0.113.0/24"                  # Documentation subnet (RFC 5737)

# SINGLE IP ADDRESSES:
cidr: "192.168.1.100/32"                # Single IPv4 address
cidr: "8.8.8.8/32"                      # Google DNS
cidr: "1.1.1.1/32"                      # Cloudflare DNS

# IPv6 CIDR BLOCKS:
cidr: "::/0"                             # All IPv6 addresses
cidr: "2001:db8::/32"                    # Documentation prefix (RFC 3849)
cidr: "fe80::/10"                        # Link-local IPv6
cidr: "::1/128"                          # IPv6 loopback

# INVALID CIDR BLOCKS:
cidr: "192.168.1.0"                     # Missing subnet mask
cidr: "192.168.1.0/33"                  # Invalid subnet mask (>32 for IPv4)
cidr: "256.1.1.1/24"                    # Invalid IP address
```

### **Selector Operators**
```yaml
# LABEL OPERATORS:
operator: In                             # Label value must be in values array
operator: NotIn                          # Label value must not be in values array
operator: Exists                         # Label key must exist (values ignored)
operator: DoesNotExist                   # Label key must not exist (values ignored)

# EXAMPLES WITH VALUES:
matchExpressions:
  - key: environment
    operator: In
    values: [production, staging]        # environment in (production, staging)
  
  - key: tier
    operator: NotIn
    values: [cache, queue]               # tier not in (cache, queue)
  
  - key: app
    operator: Exists                     # app label exists (any value)
    # values: []                         # values ignored for Exists
  
  - key: deprecated
    operator: DoesNotExist               # deprecated label does not exist
    # values: []                         # values ignored for DoesNotExist

# INVALID COMBINATIONS:
matchExpressions:
  - key: app
    operator: In                         # INVALID: In requires values
    # values: []                         # Missing required values
  
  - key: app
    operator: Exists
    values: [frontend]                   # INVALID: Exists ignores values (but not error)
```

## 🎯 **Common Patterns and Examples**

### **Default Deny All Pattern**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}                        # Apply to all pods in namespace
  policyTypes:
  - Ingress                              # Deny all ingress
  - Egress                               # Deny all egress
  # No ingress/egress rules = deny all
```

### **Allow All Pattern**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
  namespace: development
spec:
  podSelector: {}                        # Apply to all pods
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}                                   # Allow all ingress
  egress:
  - {}                                   # Allow all egress
```

### **Namespace Isolation Pattern**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: namespace-isolation
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production               # Only from same namespace
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: production               # Only to same namespace
  - to: []                               # Allow DNS (all destinations)
    ports:
    - protocol: UDP
      port: 53
```

### **Database Access Pattern**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-access
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: database                     # Apply to database pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend                  # Only backend pods
    - podSelector:
        matchLabels:
          tier: api                      # Only API pods
    ports:
    - protocol: TCP
      port: 5432                         # PostgreSQL
    - protocol: TCP
      port: 3306                         # MySQL
```

### **External API Access Pattern**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-api-access
  namespace: production
spec:
  podSelector:
    matchLabels:
      external-access: allowed           # Only labeled pods
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0                  # All external IPs
        except:
        - 10.0.0.0/8                     # Except internal networks
        - 172.16.0.0/12
        - 192.168.0.0/16
        - 127.0.0.0/8
    ports:
    - protocol: TCP
      port: 443                          # HTTPS only
  - to: []                               # DNS resolution
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

## 🔍 **Validation Rules**

### **Name Validation**
```yaml
# DNS-1123 SUBDOMAIN FORMAT:
# - Lowercase letters, numbers, hyphens
# - Start and end with alphanumeric
# - Maximum 253 characters

# VALID NAMES:
name: frontend-policy
name: allow-database-access
name: deny-all-egress
name: ns-isolation-prod

# INVALID NAMES:
name: Frontend-Policy           # Uppercase not allowed
name: -frontend-policy          # Cannot start with hyphen
name: frontend-policy-          # Cannot end with hyphen
name: frontend..policy          # Double dots not allowed
```

### **Namespace Requirements**
```yaml
# NAMESPACE IS REQUIRED:
metadata:
  namespace: production          # Must specify target namespace

# NETWORK POLICIES ARE NAMESPACED:
# - Policy only affects pods in same namespace
# - Cannot create cluster-wide network policies
# - Each namespace needs its own policies
```

### **Selector Logic**
```yaml
# EMPTY SELECTORS:
podSelector: {}                  # Matches ALL pods in namespace
namespaceSelector: {}            # Matches ALL namespaces
from: []                         # Matches ALL sources
to: []                           # Matches ALL destinations

# MULTIPLE SELECTORS (OR logic):
from:
  - podSelector:
      matchLabels:
        app: frontend            # Pods with app=frontend
  - namespaceSelector:
      matchLabels:
        name: monitoring         # OR pods from monitoring namespace

# COMBINED SELECTORS (AND logic):
from:
  - podSelector:
      matchLabels:
        app: frontend
    namespaceSelector:
      matchLabels:
        environment: production  # Pods with app=frontend AND from production namespace
```

### **Port Validation**
```yaml
# VALID PORT RANGES:
port: 1                          # Minimum port number
port: 65535                      # Maximum port number

# WELL-KNOWN PORTS:
port: 22                         # SSH
port: 53                         # DNS
port: 80                         # HTTP
port: 443                        # HTTPS
port: 993                        # IMAPS
port: 995                        # POP3S

# REGISTERED PORTS:
port: 1024                       # Start of registered range
port: 49151                      # End of registered range

# DYNAMIC/PRIVATE PORTS:
port: 49152                      # Start of dynamic range
port: 65535                      # End of dynamic range
```
