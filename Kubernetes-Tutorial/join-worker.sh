#!/bin/bash

# 🔗 Worker Node Join Script
# This script helps worker nodes join the Kubernetes cluster
# Usage: ./join-worker.sh <join-command>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if join command is provided
if [ $# -eq 0 ]; then
    error "Please provide the join command from the master node."
    echo "Usage: $0 '<join-command>'"
    echo "Example: $0 'kubeadm join 192.168.1.100:6443 --token abc123...'"
    exit 1
fi

JOIN_COMMAND="$1"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Please run as a regular user with sudo privileges."
fi

# Check if sudo is available
if ! sudo -n true 2>/dev/null; then
    error "This script requires sudo privileges. Please ensure your user has sudo access."
fi

log "Starting worker node join process..."

# Verify the node is prepared
log "Verifying node preparation..."

# Check if containerd is running
if ! systemctl is-active --quiet containerd; then
    error "Containerd is not running. Please run the setup script first."
fi

# Check if kubelet is installed
if ! command -v kubelet &> /dev/null; then
    error "kubelet is not installed. Please run the setup script first."
fi

# Check if kubeadm is installed
if ! command -v kubeadm &> /dev/null; then
    error "kubeadm is not installed. Please run the setup script first."
fi

log "Node preparation verified. Proceeding with cluster join..."

# Execute join command
log "Joining the cluster..."
sudo $JOIN_COMMAND

# Wait for node to be ready
log "Waiting for node to be ready..."
sleep 30

# Check node status
log "Checking node status..."
if kubectl get nodes 2>/dev/null | grep -q "$(hostname)"; then
    log "Node successfully joined the cluster!"
    
    # Show node status
    echo ""
    echo "=========================================="
    echo "📊 NODE STATUS:"
    echo "=========================================="
    kubectl get nodes -o wide | grep "$(hostname)"
    echo "=========================================="
    echo ""
    
    log "Worker node setup completed successfully!"
else
    warn "Node join completed, but node status could not be verified."
    warn "Please check the cluster status from the master node."
fi

echo ""
echo "✅ Worker node join process completed!"
echo ""
