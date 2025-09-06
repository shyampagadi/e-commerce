# 📚 **Kubectl Networking Command Reference**
*Comprehensive guide to all networking-related kubectl commands and options*

## 🌐 **Network Policy Commands**

### **Create Network Policy**
```bash
# Basic syntax
kubectl create networkpolicy <policy-name> [options]

# All available options
kubectl create networkpolicy --help
```

**Complete Options:**
```bash
kubectl create networkpolicy my-policy \
  --namespace=production \                    # Target namespace
  --dry-run=client \                         # Validate without creating
  --output=yaml \                            # Output format (yaml|json)
  --save-config \                            # Save config in annotation
  --validate=true                            # Validate the resource
```

### **Apply Network Policy**
```bash
# Apply from file
kubectl apply -f networkpolicy.yaml [options]

# All apply options
--cascade=background|orphan|foreground       # Deletion cascade strategy
--dry-run=none|client|server                # Dry run mode
--field-manager=kubectl-client-side-apply   # Field manager name
--force=false                               # Force apply
--grace-period=-1                           # Grace period for deletion
--overwrite=true                            # Overwrite existing annotations
--prune=false                               # Prune resources
--record=false                              # Record command in annotations
--recursive=false                           # Process directory recursively
--server-side=false                         # Server-side apply
--timeout=0s                                # Timeout for operation
--validate=true                             # Validate resources
--wait=false                                # Wait for completion
```

### **Get Network Policies**
```bash
# List all network policies
kubectl get networkpolicy [options]

# Complete get options
kubectl get networkpolicy \
  --all-namespaces \                         # Show all namespaces
  --field-selector=metadata.name=my-policy \ # Field selector
  --label-selector=app=frontend \            # Label selector
  --no-headers \                             # Skip headers
  --output=wide \                            # Wide output format
  --output=yaml \                            # YAML output
  --output=json \                            # JSON output
  --output=jsonpath='{.items[*].metadata.name}' \ # JSONPath output
  --show-kind \                              # Show resource kind
  --show-labels \                            # Show labels
  --sort-by=.metadata.name \                 # Sort by field
  --watch \                                  # Watch for changes
  --watch-only                               # Watch without initial list
```

### **Describe Network Policy**
```bash
# Describe specific policy
kubectl describe networkpolicy <policy-name> [options]

# Describe options
kubectl describe networkpolicy my-policy \
  --namespace=production \                   # Target namespace
  --show-events=true                         # Show related events
```

### **Delete Network Policy**
```bash
# Delete specific policy
kubectl delete networkpolicy <policy-name> [options]

# Delete options
kubectl delete networkpolicy my-policy \
  --cascade=background \                     # Cascade deletion
  --dry-run=none \                          # Dry run mode
  --force \                                 # Force deletion
  --grace-period=30 \                       # Grace period seconds
  --ignore-not-found \                      # Ignore if not found
  --now \                                   # Delete immediately
  --timeout=30s \                           # Timeout for deletion
  --wait=true                               # Wait for completion
```

## 🔧 **CNI Management Commands**

### **CNI Plugin Status**
```bash
# Check CNI pods
kubectl get pods -n kube-system -l k8s-app=calico-node [options]
kubectl get pods -n kube-system -l k8s-app=cilium [options]
kubectl get pods -n kube-system -l app=flannel [options]

# CNI configuration
kubectl get configmap -n kube-system calico-config -o yaml
kubectl get configmap -n kube-system cilium-config -o yaml
kubectl get configmap -n kube-system kube-flannel-cfg -o yaml
```

### **Network Troubleshooting Commands**
```bash
# Pod network information
kubectl get pods -o wide [options]
kubectl describe pod <pod-name> [options]

# Network connectivity testing
kubectl exec -it <pod-name> -- ping <target-ip> [options]
kubectl exec -it <pod-name> -- nslookup <service-name> [options]
kubectl exec -it <pod-name> -- curl <url> [options]

# Exec command options
kubectl exec <pod-name> \
  --container=<container-name> \             # Target container
  --namespace=<namespace> \                  # Target namespace
  --stdin \                                  # Pass stdin to container
  --tty \                                    # Allocate TTY
  -- <command>                               # Command to execute
```

## 📊 **Service and Ingress Commands**

### **Create Service**
```bash
# Create service
kubectl create service <type> <name> [options]

# Service types and options
kubectl create service clusterip my-service \
  --tcp=80:8080 \                           # Port mapping
  --dry-run=client \                        # Dry run
  --output=yaml                             # Output format

kubectl create service nodeport my-service \
  --tcp=80:8080 \                           # Port mapping
  --node-port=30080                         # NodePort number

kubectl create service loadbalancer my-service \
  --tcp=80:8080                             # Port mapping

kubectl create service externalname my-service \
  --external-name=example.com               # External DNS name
```

### **Expose Deployment as Service**
```bash
# Expose deployment
kubectl expose deployment <deployment-name> [options]

# Expose options
kubectl expose deployment my-app \
  --port=80 \                               # Service port
  --target-port=8080 \                      # Container port
  --type=ClusterIP \                        # Service type
  --name=my-service \                       # Service name
  --protocol=TCP \                          # Protocol
  --session-affinity=None \                 # Session affinity
  --external-ip=192.168.1.100              # External IP
```

### **Ingress Management**
```bash
# Create ingress
kubectl create ingress <name> [options]

# Ingress options
kubectl create ingress my-ingress \
  --rule="host/path=service:port" \         # Routing rule
  --annotation=key=value \                  # Annotations
  --class=nginx \                           # Ingress class
  --default-backend=service:port            # Default backend
```

## 🔍 **Network Debugging Commands**

### **Port Forwarding**
```bash
# Port forward to pod
kubectl port-forward <pod-name> <local-port>:<pod-port> [options]

# Port forward options
kubectl port-forward my-pod 8080:80 \
  --address=0.0.0.0 \                       # Bind address
  --namespace=production                     # Target namespace

# Port forward to service
kubectl port-forward service/<service-name> <local-port>:<service-port>
```

### **Logs and Events**
```bash
# Get pod logs
kubectl logs <pod-name> [options]

# Log options
kubectl logs my-pod \
  --container=<container-name> \            # Specific container
  --follow \                                # Follow log output
  --previous \                              # Previous container logs
  --since=1h \                              # Since duration
  --since-time=2024-01-01T00:00:00Z \      # Since timestamp
  --tail=100 \                              # Last N lines
  --timestamps                              # Include timestamps

# Get events
kubectl get events [options]
kubectl get events \
  --field-selector=involvedObject.name=my-pod \ # Filter by object
  --sort-by=.metadata.creationTimestamp \   # Sort by time
  --watch                                   # Watch for new events
```

## 📋 **Resource Management Commands**

### **Scale Resources**
```bash
# Scale deployment
kubectl scale deployment <name> --replicas=<count> [options]

# Scale options
kubectl scale deployment my-app \
  --replicas=5 \                            # Target replica count
  --current-replicas=3 \                    # Current replica condition
  --resource-version=12345 \                # Resource version condition
  --timeout=60s                             # Timeout for scaling
```

### **Patch Resources**
```bash
# Patch resource
kubectl patch <resource-type> <name> --patch '<patch>' [options]

# Patch types and options
kubectl patch networkpolicy my-policy \
  --type=merge \                            # Patch type (merge|strategic|json)
  --patch='{"spec":{"podSelector":{}}}' \   # JSON patch
  --namespace=production                     # Target namespace

# Strategic merge patch
kubectl patch deployment my-app \
  --type=strategic \
  --patch-file=patch.yaml

# JSON patch
kubectl patch pod my-pod \
  --type=json \
  --patch='[{"op": "replace", "path": "/spec/containers/0/image", "value": "nginx:1.20"}]'
```

## 🎯 **Advanced Networking Commands**

### **Network Policy Testing**
```bash
# Test network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh

# Network policy validation
kubectl auth can-i create networkpolicies --as=system:serviceaccount:default:default
kubectl auth can-i get networkpolicies --as=system:serviceaccount:default:default

# CNI plugin specific commands
# Calico
kubectl exec -n kube-system <calico-pod> -- calicoctl get nodes
kubectl exec -n kube-system <calico-pod> -- calicoctl get ippool

# Cilium
kubectl exec -n kube-system <cilium-pod> -- cilium status
kubectl exec -n kube-system <cilium-pod> -- cilium connectivity test
```

### **Multi-Cluster Networking**
```bash
# Submariner commands
subctl deploy-broker [options]
subctl join broker-info.subm [options]
subctl verify [options]
subctl show all [options]

# Cross-cluster service export
kubectl label service <service-name> submariner.io/exported=true
kubectl annotate service <service-name> submariner.io/exported=true
```

## 📖 **Command Syntax Patterns**

### **Common Option Patterns**
```bash
# Resource selection
--namespace=<namespace>                     # Target namespace
--all-namespaces                           # All namespaces
--field-selector=<selector>                # Field-based selection
--label-selector=<selector>                # Label-based selection

# Output formatting
--output=yaml|json|wide|name|jsonpath      # Output format
--no-headers                               # Skip column headers
--show-labels                              # Show resource labels
--show-kind                                # Show resource kind

# Operation control
--dry-run=none|client|server               # Dry run mode
--force                                    # Force operation
--grace-period=<seconds>                   # Graceful deletion period
--timeout=<duration>                       # Operation timeout
--wait                                     # Wait for completion

# Debugging
--v=<level>                                # Verbosity level (0-10)
--vmodule=<pattern>=<level>                # Module-specific verbosity
```

### **JSONPath Examples**
```bash
# Extract specific fields
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'
kubectl get networkpolicy -o jsonpath='{.items[*].spec.podSelector}'

# Complex JSONPath queries
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'
```
