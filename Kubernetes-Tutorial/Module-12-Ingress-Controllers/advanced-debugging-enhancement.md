# Module 12 Enhancement: Advanced Debugging Commands

## **🔧 Advanced Debugging Commands**

### **Deep Ingress Diagnostics**

```bash
# Complete ingress health check
kubectl get ingress,ingressclass,endpoints,services,pods -A | grep -E "(ingress|nginx|traefik)"

# Ingress controller pod diagnostics
kubectl get pods -n ingress-nginx -o wide
kubectl describe pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=50

# Traefik diagnostics
kubectl get pods -n traefik -o wide
kubectl describe pods -n traefik
kubectl logs -n traefik deployment/traefik --tail=50

# Check ingress controller configuration
kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml
kubectl get configmap -n traefik traefik -o yaml
```

### **Network Connectivity Debugging**

```bash
# Test service endpoints
kubectl get endpoints -A | grep -E "(frontend|api|payment|inventory)"

# Check service selectors match pods
kubectl get pods --show-labels | grep app=frontend
kubectl get service frontend-service -o yaml | grep selector -A 5

# Network policy debugging
kubectl get networkpolicies -A
kubectl describe networkpolicy -A

# DNS resolution testing
kubectl run debug-pod --image=busybox --rm -it -- nslookup frontend-service.ecommerce.svc.cluster.local
kubectl run debug-pod --image=busybox --rm -it -- wget -qO- http://frontend-service.ecommerce.svc.cluster.local
```

### **SSL/TLS Certificate Debugging**

```bash
# Check TLS secrets
kubectl get secrets -A | grep tls
kubectl describe secret ecommerce-tls-secret -n ecommerce

# Verify certificate validity
kubectl get secret ecommerce-tls-secret -n ecommerce -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# Check certificate expiration
kubectl get secret ecommerce-tls-secret -n ecommerce -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -enddate -noout

# Test SSL connection
openssl s_client -connect shop.example.com:443 -servername shop.example.com -verify_return_error

# Check cert-manager certificates
kubectl get certificates -A
kubectl describe certificate ecommerce-cert -n ecommerce
kubectl get certificaterequests -A
kubectl describe certificaterequest -A
```

### **Performance Debugging**

```bash
# Resource usage monitoring
kubectl top pods -n ingress-nginx
kubectl top pods -n traefik
kubectl top nodes

# Memory and CPU analysis
kubectl describe pod -n ingress-nginx | grep -A 5 -B 5 -E "(Requests|Limits)"
kubectl get pods -n ingress-nginx -o jsonpath='{.items[*].spec.containers[*].resources}'

# Connection and request metrics
kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- curl localhost:10254/metrics | grep nginx_ingress
kubectl port-forward -n traefik service/traefik 9000:9000 &
curl localhost:9000/metrics | grep traefik

# Check for resource constraints
kubectl get events -A --sort-by='.lastTimestamp' | grep -E "(OOMKilled|Evicted|FailedScheduling)"
```

### **Traffic Flow Analysis**

```bash
# Trace request path
kubectl get ingress ecommerce-ingress -o yaml | grep -A 10 -B 5 rules
kubectl get service frontend-service -o yaml | grep -A 5 -B 5 selector
kubectl get pods -l app=frontend --show-labels

# Check load balancer status
kubectl get service -n ingress-nginx ingress-nginx-controller -o wide
kubectl describe service -n ingress-nginx ingress-nginx-controller

# Analyze ingress annotations
kubectl get ingress ecommerce-ingress -o yaml | grep -A 20 annotations

# Check middleware configuration (Traefik)
kubectl get middleware -A
kubectl describe middleware rate-limit-middleware -n ecommerce
```

### **Event Stream Analysis**

```bash
# Real-time event monitoring
kubectl get events --watch --sort-by='.lastTimestamp'

# Filter events by resource type
kubectl get events --field-selector involvedObject.kind=Ingress --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.kind=Service --sort-by='.lastTimestamp'
kubectl get events --field-selector involvedObject.kind=Pod --sort-by='.lastTimestamp'

# Filter events by namespace
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
kubectl get events -n ingress-nginx --sort-by='.lastTimestamp'

# Filter events by reason
kubectl get events --field-selector reason=FailedMount --sort-by='.lastTimestamp'
kubectl get events --field-selector reason=Unhealthy --sort-by='.lastTimestamp'
```

### **Configuration Validation**

```bash
# Validate YAML syntax
kubectl apply --dry-run=client -f ingress.yaml
kubectl apply --dry-run=server -f ingress.yaml

# Check resource quotas and limits
kubectl describe resourcequota -A
kubectl describe limitrange -A

# Validate RBAC permissions
kubectl auth can-i create ingress --as=system:serviceaccount:ecommerce:default
kubectl auth can-i get services --as=system:serviceaccount:ingress-nginx:ingress-nginx

# Check admission controllers
kubectl get validatingadmissionwebhooks
kubectl get mutatingadmissionwebhooks
```

### **Advanced Log Analysis**

```bash
# Structured log parsing for NGINX
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller | jq -r 'select(.level=="error")'
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller | grep -E "(error|ERROR|Error)" | tail -20

# Traefik log analysis
kubectl logs -n traefik deployment/traefik | jq -r 'select(.level=="error")'
kubectl logs -n traefik deployment/traefik | grep -E "(error|ERROR|Error)" | tail -20

# Application log correlation
kubectl logs deployment/frontend-service -n ecommerce --since=1h | grep -E "(error|ERROR|5xx)"
kubectl logs deployment/api-service -n ecommerce --since=1h | grep -E "(error|ERROR|5xx)"

# Log aggregation across pods
kubectl logs -l app=frontend -n ecommerce --since=1h --prefix=true
kubectl logs -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx --since=1h --prefix=true
```

### **Comprehensive Debugging Script**

```bash
#!/bin/bash
# ingress-debug.sh - Comprehensive Ingress debugging script

echo "=== INGRESS DEBUGGING REPORT ==="
echo "Generated: $(date)"
echo ""

# Basic cluster info
echo "=== CLUSTER INFO ==="
kubectl cluster-info
kubectl get nodes -o wide
echo ""

# Ingress resources
echo "=== INGRESS RESOURCES ==="
kubectl get ingress -A -o wide
kubectl get ingressclass
echo ""

# Ingress controllers
echo "=== INGRESS CONTROLLERS ==="
kubectl get pods -n ingress-nginx -o wide
kubectl get pods -n traefik -o wide
echo ""

# Services and endpoints
echo "=== SERVICES AND ENDPOINTS ==="
kubectl get services -A | grep -E "(frontend|api|payment|inventory|nginx|traefik)"
kubectl get endpoints -A | grep -E "(frontend|api|payment|inventory|nginx|traefik)"
echo ""

# Recent events
echo "=== RECENT EVENTS ==="
kubectl get events --sort-by='.lastTimestamp' | tail -20
echo ""

# TLS secrets
echo "=== TLS SECRETS ==="
kubectl get secrets -A | grep tls
echo ""

# Resource usage
echo "=== RESOURCE USAGE ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
kubectl top pods -n ingress-nginx 2>/dev/null || echo "Metrics server not available"
kubectl top pods -n traefik 2>/dev/null || echo "Metrics server not available"
echo ""

# Configuration issues
echo "=== CONFIGURATION VALIDATION ==="
kubectl get ingress -A -o yaml | kubectl apply --dry-run=client -f - 2>&1 | grep -E "(error|Error|ERROR)" || echo "No validation errors found"
echo ""

echo "=== DEBUG REPORT COMPLETE ==="
```

### **Interactive Debugging Functions**

```bash
# Add to ~/.kubectl_aliases

# Interactive ingress troubleshooting
debug_ingress() {
    local ingress_name=$1
    local namespace=${2:-default}
    
    echo "Debugging ingress: $ingress_name in namespace: $namespace"
    
    # Check ingress exists
    if ! kubectl get ingress $ingress_name -n $namespace >/dev/null 2>&1; then
        echo "ERROR: Ingress $ingress_name not found in namespace $namespace"
        return 1
    fi
    
    # Get ingress details
    echo "=== Ingress Configuration ==="
    kubectl get ingress $ingress_name -n $namespace -o yaml
    
    # Check backend services
    echo "=== Backend Services ==="
    kubectl get ingress $ingress_name -n $namespace -o jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}' | tr ' ' '\n' | sort -u | while read service; do
        echo "Checking service: $service"
        kubectl get service $service -n $namespace -o wide
        kubectl get endpoints $service -n $namespace
    done
    
    # Check events
    echo "=== Related Events ==="
    kubectl get events -n $namespace --field-selector involvedObject.name=$ingress_name
}

# Test connectivity to service
test_service_connectivity() {
    local service_name=$1
    local namespace=${2:-default}
    local port=${3:-80}
    
    echo "Testing connectivity to $service_name:$port in namespace $namespace"
    
    kubectl run connectivity-test --image=busybox --rm -it --restart=Never -- \
        wget -qO- --timeout=10 http://$service_name.$namespace.svc.cluster.local:$port
}

# Check ingress controller health
check_ingress_controller() {
    local controller=${1:-nginx}
    
    if [[ $controller == "nginx" ]]; then
        echo "=== NGINX Ingress Controller Health ==="
        kubectl get pods -n ingress-nginx
        kubectl get service -n ingress-nginx
        kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=10
    elif [[ $controller == "traefik" ]]; then
        echo "=== Traefik Ingress Controller Health ==="
        kubectl get pods -n traefik
        kubectl get service -n traefik
        kubectl logs -n traefik deployment/traefik --tail=10
    fi
}
```

This enhancement provides comprehensive advanced debugging capabilities that will help users troubleshoot complex Ingress Controller issues in production environments.
