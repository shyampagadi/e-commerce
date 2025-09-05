# Module 12 Enhancement: Command Aliases and Shortcuts

## **📋 kubectl Aliases and Shortcuts**

### **Essential kubectl Aliases**

```bash
# Basic kubectl aliases
alias k=kubectl
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kdes='kubectl describe'
alias ked='kubectl edit'
alias kex='kubectl exec -it'
alias klog='kubectl logs'
alias kpf='kubectl port-forward'

# Resource-specific aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgi='kubectl get ingress'
alias kgir='kubectl get ingressroute'  # Traefik
alias kgm='kubectl get middleware'     # Traefik
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kge='kubectl get events'

# Detailed output aliases
alias kgpw='kubectl get pods -o wide'
alias kgsw='kubectl get services -o wide'
alias kgiw='kubectl get ingress -o wide'
alias kgpall='kubectl get pods --all-namespaces'
alias kgsall='kubectl get services --all-namespaces'
alias kgiall='kubectl get ingress --all-namespaces'

# Describe aliases
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdi='kubectl describe ingress'
alias kdir='kubectl describe ingressroute'  # Traefik
alias kdm='kubectl describe middleware'     # Traefik

# Logs aliases
alias klf='kubectl logs -f'
alias klp='kubectl logs --previous'
alias kl1h='kubectl logs --since=1h'
alias kl1d='kubectl logs --since=24h'

# Context and namespace aliases
alias kcc='kubectl config current-context'
alias kgc='kubectl config get-contexts'
alias ksc='kubectl config set-context'
alias kns='kubectl config set-context --current --namespace'
```

### **Ingress-Specific Aliases**

```bash
# NGINX Ingress aliases
alias kgi-nginx='kubectl get ingress -l kubernetes.io/ingress.class=nginx'
alias kdi-nginx='kubectl describe ingress -l kubernetes.io/ingress.class=nginx'
alias klog-nginx='kubectl logs -n ingress-nginx deployment/ingress-nginx-controller'
alias kpf-nginx='kubectl port-forward -n ingress-nginx service/ingress-nginx-controller'

# Traefik Ingress aliases
alias kgi-traefik='kubectl get ingressroute'
alias kdi-traefik='kubectl describe ingressroute'
alias kgm-traefik='kubectl get middleware'
alias kdm-traefik='kubectl describe middleware'
alias klog-traefik='kubectl logs -n traefik deployment/traefik'
alias kpf-traefik='kubectl port-forward -n traefik service/traefik'

# SSL/TLS aliases
alias kgs-tls='kubectl get secrets -o custom-columns=NAME:.metadata.name,TYPE:.type | grep tls'
alias kdi-tls='kubectl describe secret'
alias kgc-tls='kubectl get certificates'  # cert-manager
alias kdc-tls='kubectl describe certificate'  # cert-manager
```

### **Advanced Troubleshooting Aliases**

```bash
# Event monitoring
alias kge-sorted='kubectl get events --sort-by=.lastTimestamp'
alias kge-ingress='kubectl get events --field-selector involvedObject.kind=Ingress'
alias kge-service='kubectl get events --field-selector involvedObject.kind=Service'
alias kge-pod='kubectl get events --field-selector involvedObject.kind=Pod'

# Resource monitoring
alias ktp='kubectl top pods'
alias ktn='kubectl top nodes'
alias kwp='kubectl get pods --watch'
alias kws='kubectl get services --watch'
alias kwi='kubectl get ingress --watch'

# Quick diagnostics
alias kcheck='kubectl get pods,services,ingress'
alias kstatus='kubectl get nodes,pods,services,ingress --all-namespaces'
alias khealth='kubectl get componentstatuses'
```

### **E-commerce Specific Aliases**

```bash
# E-commerce namespace shortcuts
alias k-shop='kubectl --namespace=ecommerce'
alias k-prod='kubectl --namespace=production'
alias k-stage='kubectl --namespace=staging'
alias k-dev='kubectl --namespace=development'

# E-commerce service aliases
alias kgs-frontend='kubectl get service frontend-service'
alias kgs-api='kubectl get service api-service'
alias kgs-payment='kubectl get service payment-service'
alias kgs-inventory='kubectl get service inventory-service'

# E-commerce ingress aliases
alias kgi-shop='kubectl get ingress shop-ingress'
alias kgi-api='kubectl get ingress api-ingress'
alias kgi-admin='kubectl get ingress admin-ingress'
```

### **One-liner Shortcuts**

```bash
# Quick deployment check
alias kcheck-deploy='kubectl get deployments,services,ingress -o wide'

# Quick pod restart
alias krestart='kubectl rollout restart deployment'

# Quick scale
alias kscale='kubectl scale deployment'

# Quick exec into pod
alias kshell='kubectl exec -it'

# Quick port forward common ports
alias kpf-80='kubectl port-forward service'
alias kpf-443='kubectl port-forward service'
alias kpf-8080='kubectl port-forward service'

# Quick apply and delete
alias kapply='kubectl apply -f'
alias kdelete='kubectl delete -f'
alias kdry='kubectl apply --dry-run=client -o yaml'
```

### **Installation Script**

```bash
#!/bin/bash
# kubectl-aliases-install.sh
# Install kubectl aliases for Ingress Controllers

echo "Installing kubectl aliases..."

# Create aliases file
cat > ~/.kubectl_aliases << 'EOF'
# kubectl Aliases for Ingress Controllers
alias k=kubectl
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kdes='kubectl describe'
alias ked='kubectl edit'
alias kex='kubectl exec -it'
alias klog='kubectl logs'
alias kpf='kubectl port-forward'

# Resource aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgi='kubectl get ingress'
alias kgir='kubectl get ingressroute'
alias kgm='kubectl get middleware'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'

# Wide output
alias kgpw='kubectl get pods -o wide'
alias kgsw='kubectl get services -o wide'
alias kgiw='kubectl get ingress -o wide'

# All namespaces
alias kgpall='kubectl get pods --all-namespaces'
alias kgsall='kubectl get services --all-namespaces'
alias kgiall='kubectl get ingress --all-namespaces'

# Describe shortcuts
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdi='kubectl describe ingress'

# Logs shortcuts
alias klf='kubectl logs -f'
alias klp='kubectl logs --previous'

# Context shortcuts
alias kcc='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# Ingress-specific
alias kgi-nginx='kubectl get ingress -l kubernetes.io/ingress.class=nginx'
alias klog-nginx='kubectl logs -n ingress-nginx deployment/ingress-nginx-controller'
alias klog-traefik='kubectl logs -n traefik deployment/traefik'

# Troubleshooting
alias kge-sorted='kubectl get events --sort-by=.lastTimestamp'
alias kcheck='kubectl get pods,services,ingress'
alias kstatus='kubectl get nodes,pods,services,ingress --all-namespaces'
EOF

# Add to shell profile
if [[ -f ~/.bashrc ]]; then
    echo "source ~/.kubectl_aliases" >> ~/.bashrc
    echo "Added aliases to ~/.bashrc"
fi

if [[ -f ~/.zshrc ]]; then
    echo "source ~/.kubectl_aliases" >> ~/.zshrc
    echo "Added aliases to ~/.zshrc"
fi

echo "kubectl aliases installed successfully!"
echo "Run 'source ~/.bashrc' or restart your terminal to use aliases"
```

### **Usage Examples**

```bash
# Instead of: kubectl get pods
k get pods
# Or even shorter:
kgp

# Instead of: kubectl describe ingress my-ingress
kdi my-ingress

# Instead of: kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx
klog-nginx -f

# Instead of: kubectl get ingress --all-namespaces -o wide
kgiall -o wide

# Instead of: kubectl apply -f ingress.yaml
kaf ingress.yaml

# Instead of: kubectl config set-context --current --namespace=ecommerce
kns ecommerce

# Quick health check
kcheck

# Quick troubleshooting
kge-sorted | tail -10
```

### **Advanced Alias Functions**

```bash
# Add to ~/.kubectl_aliases

# Function to quickly create and test ingress
kingresstest() {
    local name=$1
    local host=$2
    local service=$3
    local port=${4:-80}
    
    kubectl create ingress $name \
        --rule="$host/=$service:$port" \
        --class=nginx \
        --dry-run=client -o yaml
}

# Function to check ingress status
kingressstatus() {
    local ingress=$1
    echo "=== Ingress Status ==="
    kubectl get ingress $ingress -o wide
    echo ""
    echo "=== Ingress Details ==="
    kubectl describe ingress $ingress
    echo ""
    echo "=== Backend Service ==="
    kubectl get service $(kubectl get ingress $ingress -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}')
}

# Function to tail ingress controller logs
kingresslogs() {
    local controller=${1:-nginx}
    if [[ $controller == "nginx" ]]; then
        kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f
    elif [[ $controller == "traefik" ]]; then
        kubectl logs -n traefik deployment/traefik -f
    fi
}

# Function to port-forward to ingress controller
kingresspf() {
    local controller=${1:-nginx}
    local port=${2:-8080}
    if [[ $controller == "nginx" ]]; then
        kubectl port-forward -n ingress-nginx service/ingress-nginx-controller $port:80
    elif [[ $controller == "traefik" ]]; then
        kubectl port-forward -n traefik service/traefik $port:80
    fi
}
```

This enhancement adds comprehensive command aliases and shortcuts that will significantly improve productivity when working with Ingress Controllers in Module 12.
