#!/bin/bash

# 🚀 Production-Grade kubeadm Cluster Setup Script
# This script automates the setup of a 3-node Kubernetes cluster
# Author: Kubernetes Tutorial Team
# Version: 1.0

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KUBERNETES_VERSION="v1.28.0"
CALICO_VERSION="v3.26.1"
CLUSTER_NAME="ecommerce-cluster"
POD_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"

# Node configuration
MASTER_IP="192.168.1.100"
WORKER1_IP="192.168.1.101"
WORKER2_IP="192.168.1.102"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user with sudo privileges."
    fi
}

# Check if sudo is available
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        error "This script requires sudo privileges. Please ensure your user has sudo access."
    fi
}

# Detect node role based on hostname
detect_node_role() {
    HOSTNAME=$(hostname)
    if [[ $HOSTNAME == *"master"* ]]; then
        NODE_ROLE="master"
    elif [[ $HOSTNAME == *"worker"* ]]; then
        NODE_ROLE="worker"
    else
        error "Cannot determine node role from hostname: $HOSTNAME. Please ensure hostname contains 'master' or 'worker'"
    fi
    log "Detected node role: $NODE_ROLE"
}

# Update system packages
update_system() {
    log "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl wget git vim htop net-tools jq
}

# Configure hostname and hosts file
configure_hostname() {
    log "Configuring hostname and hosts file..."
    
    if [[ $NODE_ROLE == "master" ]]; then
        sudo hostnamectl set-hostname k8s-master
        echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts
        echo "$MASTER_IP k8s-master" | sudo tee -a /etc/hosts
        echo "$WORKER1_IP k8s-worker-1" | sudo tee -a /etc/hosts
        echo "$WORKER2_IP k8s-worker-2" | sudo tee -a /etc/hosts
    elif [[ $NODE_ROLE == "worker" ]]; then
        if [[ $HOSTNAME == *"1"* ]]; then
            sudo hostnamectl set-hostname k8s-worker-1
            echo "127.0.0.1 k8s-worker-1" | sudo tee -a /etc/hosts
        else
            sudo hostnamectl set-hostname k8s-worker-2
            echo "127.0.0.1 k8s-worker-2" | sudo tee -a /etc/hosts
        fi
        echo "$MASTER_IP k8s-master" | sudo tee -a /etc/hosts
    fi
}

# Disable swap
disable_swap() {
    log "Disabling swap..."
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

# Configure firewall
configure_firewall() {
    log "Configuring firewall..."
    
    # Common ports for all nodes
    sudo ufw allow 6443/tcp    # Kubernetes API server
    sudo ufw allow 2379:2380/tcp  # etcd server client API
    sudo ufw allow 10250/tcp   # Kubelet API
    sudo ufw allow 10251/tcp   # kube-scheduler
    sudo ufw allow 10252/tcp   # kube-controller-manager
    sudo ufw allow 10255/tcp   # Read-only Kubelet API
    sudo ufw allow 30000:32767/tcp  # NodePort services
    sudo ufw allow 179/tcp     # Calico BGP
    sudo ufw allow 4789/udp    # Calico VXLAN
    
    # Master node specific ports
    if [[ $NODE_ROLE == "master" ]]; then
        sudo ufw allow 22/tcp   # SSH
        sudo ufw allow 80/tcp   # HTTP
        sudo ufw allow 443/tcp  # HTTPS
    fi
    
    # Enable firewall
    sudo ufw --force enable
}

# Install containerd
install_containerd() {
    log "Installing containerd..."
    
    # Install containerd
    sudo apt install -y containerd
    
    # Configure containerd
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    
    # Enable systemd cgroup driver
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    
    # Restart containerd
    sudo systemctl restart containerd
    sudo systemctl enable containerd
    
    log "Containerd installed and configured"
}

# Install Kubernetes components
install_kubernetes() {
    log "Installing Kubernetes components..."
    
    # Add Kubernetes GPG key
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
    
    # Add Kubernetes repository
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
    # Install Kubernetes components
    sudo apt update
    sudo apt install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    
    log "Kubernetes components installed"
}

# Initialize master node
init_master() {
    log "Initializing master node..."
    
    # Create kubeadm configuration
    sudo tee /tmp/kubeadm-config.yaml > /dev/null <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: $KUBERNETES_VERSION
controlPlaneEndpoint: "$MASTER_IP:6443"
clusterName: "$CLUSTER_NAME"
networking:
  podSubnet: "$POD_CIDR"
  serviceSubnet: "$SERVICE_CIDR"
  dnsDomain: "cluster.local"
etcd:
  local:
    dataDir: /var/lib/etcd
apiServer:
  extraArgs:
    audit-log-path: /var/log/audit.log
    audit-policy-file: /etc/kubernetes/audit-policy.yaml
  extraVolumes:
  - name: audit-log
    hostPath: /var/log/audit.log
    mountPath: /var/log/audit.log
    pathType: FileOrCreate
  - name: audit-policy
    hostPath: /etc/kubernetes/audit-policy.yaml
    mountPath: /etc/kubernetes/audit-policy.yaml
    readOnly: true
    pathType: File
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "$MASTER_IP"
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

    # Create audit policy
    sudo tee /etc/kubernetes/audit-policy.yaml > /dev/null <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF

    # Initialize cluster
    sudo kubeadm init --config=/tmp/kubeadm-config.yaml
    
    # Configure kubectl
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    log "Master node initialized successfully"
}

# Install CNI (Calico)
install_cni() {
    log "Installing Calico CNI..."
    
    # Install Calico
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/tigera-operator.yaml
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/custom-resources.yaml
    
    # Wait for nodes to be ready
    log "Waiting for nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    log "Calico CNI installed successfully"
}

# Install Helm
install_helm() {
    log "Installing Helm..."
    
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    log "Helm installed successfully"
}

# Install monitoring stack
install_monitoring() {
    log "Installing monitoring stack..."
    
    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus and Grafana
    helm install monitoring prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi
    
    log "Monitoring stack installed successfully"
}

# Create storage class
create_storage_class() {
    log "Creating storage class..."
    
    kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
EOF
    
    log "Storage class created successfully"
}

# Generate join command
generate_join_command() {
    log "Generating join command for worker nodes..."
    
    JOIN_COMMAND=$(sudo kubeadm token create --print-join-command)
    
    echo ""
    echo "=========================================="
    echo "🔗 JOIN COMMAND FOR WORKER NODES:"
    echo "=========================================="
    echo "$JOIN_COMMAND"
    echo "=========================================="
    echo ""
    echo "Run this command on each worker node to join the cluster."
    echo ""
    
    # Save join command to file
    echo "$JOIN_COMMAND" > /tmp/k8s-join-command.txt
    log "Join command saved to /tmp/k8s-join-command.txt"
}

# Verify cluster
verify_cluster() {
    log "Verifying cluster..."
    
    echo ""
    echo "=========================================="
    echo "📊 CLUSTER STATUS:"
    echo "=========================================="
    
    # Check nodes
    echo "Nodes:"
    kubectl get nodes -o wide
    
    echo ""
    echo "System Pods:"
    kubectl get pods -A
    
    echo ""
    echo "Cluster Info:"
    kubectl cluster-info
    
    echo ""
    echo "=========================================="
    echo "✅ Cluster setup completed successfully!"
    echo "=========================================="
}

# Main execution
main() {
    echo ""
    echo "🚀 Starting Production-Grade kubeadm Cluster Setup"
    echo "=================================================="
    echo ""
    
    # Pre-flight checks
    check_root
    check_sudo
    detect_node_role
    
    # Common setup for all nodes
    update_system
    configure_hostname
    disable_swap
    configure_firewall
    install_containerd
    install_kubernetes
    
    # Master node specific setup
    if [[ $NODE_ROLE == "master" ]]; then
        init_master
        install_cni
        install_helm
        install_monitoring
        create_storage_class
        generate_join_command
        verify_cluster
        
        echo ""
        echo "🎉 Master node setup completed!"
        echo "Next steps:"
        echo "1. Run the join command on worker nodes"
        echo "2. Wait for all nodes to be ready"
        echo "3. Start deploying your applications!"
        echo ""
    else
        echo ""
        echo "✅ Worker node setup completed!"
        echo "Next steps:"
        echo "1. Run the join command from the master node"
        echo "2. Wait for the node to join the cluster"
        echo ""
    fi
}

# Run main function
main "$@"
