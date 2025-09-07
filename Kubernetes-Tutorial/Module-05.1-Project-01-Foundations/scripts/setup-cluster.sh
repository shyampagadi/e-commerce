#!/bin/bash
# =============================================================================
# KUBERNETES CLUSTER SETUP SCRIPT
# =============================================================================
# This script sets up a production-ready 2-node Kubernetes cluster for the
# e-commerce foundation infrastructure project with proper networking and security.
# =============================================================================

set -euo pipefail
# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
# set -e: Exit immediately if any command fails
# set -u: Exit if any undefined variable is used
# set -o pipefail: Exit if any command in a pipeline fails
# =============================================================================

# =============================================================================
# COLOR CODES FOR OUTPUT FORMATTING
# =============================================================================
# Define color codes for consistent output formatting throughout the script.
# =============================================================================

RED='\033[0;31m'
# Purpose: Red color code for error messages
# Why needed: Provides visual distinction for error output
# Impact: Error messages are displayed in red color
# Usage: Used in error() function for critical messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages
# Why needed: Provides visual distinction for success output
# Impact: Success messages are displayed in green color
# Usage: Used in success() function for completion messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages
# Why needed: Provides visual distinction for warning output
# Impact: Warning messages are displayed in yellow color
# Usage: Used in warning() function for cautionary messages

BLUE='\033[0;34m'
# Purpose: Blue color code for informational messages
# Why needed: Provides visual distinction for informational output
# Impact: Info messages are displayed in blue color
# Usage: Used in log() function for general information

NC='\033[0m'
# Purpose: No Color code to reset terminal color
# Why needed: Resets terminal color after colored output
# Impact: Prevents color bleeding to subsequent output
# Usage: Used at end of all colored message functions

# =============================================================================
# CLUSTER CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent cluster configuration throughout the script.
# =============================================================================

CLUSTER_NAME="ecommerce-cluster"
# Purpose: Specifies the name of the Kubernetes cluster
# Why needed: Provides consistent cluster identification
# Impact: Cluster resources use this name for identification
# Value: Descriptive name matching the project purpose

MASTER_IP="192.168.1.100"
# Purpose: Specifies the IP address of the master node
# Why needed: Defines the control plane endpoint for cluster communication
# Impact: Worker nodes connect to this IP for cluster joining
# Value: Private network IP address for the master node

POD_NETWORK_CIDR="10.244.0.0/16"
# Purpose: Specifies the CIDR block for pod networking
# Why needed: Defines IP address range for pod-to-pod communication
# Impact: All pods receive IP addresses from this range
# Value: Standard Flannel network CIDR for compatibility

SERVICE_CIDR="10.96.0.0/12"
# Purpose: Specifies the CIDR block for service networking
# Why needed: Defines IP address range for Kubernetes services
# Impact: All services receive cluster IPs from this range
# Value: Default Kubernetes service CIDR for compatibility

KUBERNETES_VERSION="1.28.2"
# Purpose: Specifies the Kubernetes version to install
# Why needed: Ensures consistent Kubernetes version across nodes
# Impact: All cluster components use this specific version
# Value: Stable Kubernetes version with required features

CONTAINERD_VERSION="1.7.2"
# Purpose: Specifies the containerd runtime version
# Why needed: Ensures consistent container runtime across nodes
# Impact: All nodes use this containerd version for container execution
# Value: Compatible containerd version for the Kubernetes version

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
# Functions for consistent logging and output formatting throughout the script.
# =============================================================================

log() {
    # =============================================================================
    # LOG FUNCTION
    # =============================================================================
    # Logs informational messages with timestamp and blue color formatting.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the message to log
    # Why needed: Provides the content to be logged
    # Impact: Message is displayed with timestamp and formatting
    # Parameter: $1 is the message string to display
    
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $message"
    # Purpose: Outputs formatted message with timestamp
    # Why needed: Provides consistent logging format with timestamp
    # Impact: Message appears with blue timestamp and normal text
    # Format: [YYYY-MM-DD HH:MM:SS] message
}

error() {
    # =============================================================================
    # ERROR FUNCTION
    # =============================================================================
    # Logs error messages with red color formatting and outputs to stderr.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the error message to display
    # Why needed: Provides the error content to be logged
    # Impact: Message is displayed in red color and sent to stderr
    # Parameter: $1 is the error message string
    
    echo -e "${RED}[ERROR]${NC} $message" >&2
    # Purpose: Outputs formatted error message in red to stderr
    # Why needed: Provides visual indication of errors and proper stream handling
    # Impact: Error message appears in red and goes to error stream
    # Format: [ERROR] message in red color to stderr
}

success() {
    # =============================================================================
    # SUCCESS FUNCTION
    # =============================================================================
    # Logs success messages with green color formatting for positive outcomes.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the success message to display
    # Why needed: Provides the success content to be logged
    # Impact: Message is displayed in green color for visual distinction
    # Parameter: $1 is the success message string
    
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    # Purpose: Outputs formatted success message in green
    # Why needed: Provides visual confirmation of successful operations
    # Impact: Success message appears in green for easy identification
    # Format: [SUCCESS] message in green color
}

warning() {
    # =============================================================================
    # WARNING FUNCTION
    # =============================================================================
    # Logs warning messages with yellow color formatting for cautionary information.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the warning message to display
    # Why needed: Provides the warning content to be logged
    # Impact: Message is displayed in yellow color for attention
    # Parameter: $1 is the warning message string
    
    echo -e "${YELLOW}[WARNING]${NC} $message"
    # Purpose: Outputs formatted warning message in yellow
    # Why needed: Provides visual indication of warnings and potential issues
    # Impact: Warning message appears in yellow for moderate attention
    # Format: [WARNING] message in yellow color
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # =============================================================================
    # OPERATING SYSTEM CHECK
    # =============================================================================
    # Purpose: Verify the system is running a supported Linux distribution
    # Why needed: Kubernetes has specific OS requirements for proper operation
    
    # Check if running on supported OS
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot determine OS version"
        exit 1
    fi
    # Command: [[ ! -f /etc/os-release ]]
    # Explanation: Tests if the /etc/os-release file exists
    # Expected: File should exist on modern Linux distributions
    # Impact: If missing, we cannot determine the OS type and version
    
    source /etc/os-release
    # Command: source /etc/os-release
    # Explanation: Loads OS identification variables into the current shell
    # Variables loaded: ID (distribution), VERSION_ID (version), etc.
    # Expected: Variables like ID="ubuntu", VERSION_ID="20.04" should be set
    
    if [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]; then
        error "This script only supports Ubuntu/Debian"
        exit 1
    fi
    # Command: [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]
    # Explanation: Checks if the distribution is Ubuntu or Debian
    # Expected: ID should be "ubuntu" or "debian"
    # Impact: Other distributions may have different package managers or configurations
    
    # Check if running on supported Ubuntu version
    if [[ "$VERSION_ID" != "20.04" ]] && [[ "$VERSION_ID" != "22.04" ]]; then
        warning "This script is tested on Ubuntu 20.04/22.04. Current version: $VERSION_ID"
    fi
    # Command: [[ "$VERSION_ID" != "20.04" ]] && [[ "$VERSION_ID" != "22.04" ]]
    # Explanation: Checks if the version is a supported Ubuntu release
    # Expected: VERSION_ID should be "20.04" or "22.04"
    # Impact: Other versions may have different package availability or configurations
    
    # =============================================================================
    # MEMORY CHECK
    # =============================================================================
    # Purpose: Verify sufficient RAM is available for Kubernetes cluster
    # Why needed: Kubernetes requires minimum memory for proper operation
    
    # Check available memory
    local mem_gb=$(free -g | awk '/^Mem:/{print $2}')
    # Command: free -g | awk '/^Mem:/{print $2}'
    # Explanation: 
    #   - free -g: Shows memory usage in gigabytes
    #   - awk '/^Mem:/{print $2}': Extracts the total memory value
    # Expected: Returns total RAM in GB (e.g., "8" for 8GB)
    # Impact: Used to verify minimum memory requirements
    
    if [[ $mem_gb -lt 2 ]]; then
        error "Minimum 2GB RAM required. Available: ${mem_gb}GB"
        exit 1
    fi
    # Command: [[ $mem_gb -lt 2 ]]
    # Explanation: Tests if available memory is less than 2GB
    # Expected: Should be false (sufficient memory available)
    # Impact: Insufficient memory will cause Kubernetes components to fail
    
    # =============================================================================
    # DISK SPACE CHECK
    # =============================================================================
    # Purpose: Verify sufficient disk space is available for Kubernetes data
    # Why needed: Kubernetes stores cluster data, container images, and logs
    
    # Check available disk space
    local disk_gb=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    # Command: df -BG / | awk 'NR==2{print $4}' | sed 's/G//'
    # Explanation:
    #   - df -BG /: Shows disk usage in gigabytes for root filesystem
    #   - awk 'NR==2{print $4}': Extracts the available space value (4th column, 2nd row)
    #   - sed 's/G//': Removes the 'G' suffix to get numeric value
    # Expected: Returns available disk space in GB (e.g., "50" for 50GB)
    # Impact: Used to verify minimum disk space requirements
    
    if [[ $disk_gb -lt 20 ]]; then
        error "Minimum 20GB disk space required. Available: ${disk_gb}GB"
        exit 1
    fi
    # Command: [[ $disk_gb -lt 20 ]]
    # Explanation: Tests if available disk space is less than 20GB
    # Expected: Should be false (sufficient disk space available)
    # Impact: Insufficient disk space will cause container image pulls and data storage to fail
    
    success "Prerequisites check passed"
    # Command: success "Prerequisites check passed"
    # Explanation: Logs success message if all checks pass
    # Expected: Green success message displayed
    # Impact: Indicates system is ready for Kubernetes installation
}

# Function to install required packages
install_packages() {
    log "Installing required packages..."
    
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        wget \
        git \
        jq \
        vim \
        htop
    
    success "Required packages installed"
}

# Function to install Docker
install_docker() {
    log "Installing Docker..."
    
    # Remove old Docker installations
    sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    # Configure containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    
    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    success "Docker installed and configured"
}

# Function to install Kubernetes
install_kubernetes() {
    log "Installing Kubernetes..."
    
    # Add Kubernetes repository
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    
    # Install Kubernetes components
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    
    # Enable kubelet
    sudo systemctl enable kubelet
    
    success "Kubernetes installed"
}

# Function to configure system for Kubernetes
configure_system() {
    log "Configuring system for Kubernetes..."
    
    # Disable swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-ip6tables = 1' | sudo tee -a /etc/sysctl.conf
    
    # Apply sysctl settings
    sudo sysctl --system
    
    # Load required kernel modules
    sudo modprobe br_netfilter
    echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/k8s.conf
    
    success "System configured for Kubernetes"
}

# Function to initialize master node
init_master() {
    log "Initializing master node..."
    
    # Initialize cluster
    sudo kubeadm init \
        --pod-network-cidr=$POD_NETWORK_CIDR \
        --service-cidr=$SERVICE_CIDR \
        --apiserver-advertise-address=$MASTER_IP \
        --control-plane-endpoint=$MASTER_IP \
        --upload-certs \
        --certificate-key=$(kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -1)
    
    # Configure kubectl for non-root user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    # Install CNI plugin (Flannel)
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    
    # Wait for nodes to be ready
    log "Waiting for nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    success "Master node initialized"
}

# Function to generate join command
generate_join_command() {
    log "Generating join command for worker nodes..."
    
    # Generate join command
    local join_command=$(kubeadm token create --print-join-command)
    
    echo "=========================================="
    echo "WORKER NODE JOIN COMMAND:"
    echo "=========================================="
    echo "sudo $join_command"
    echo "=========================================="
    echo ""
    echo "Run this command on each worker node to join the cluster"
    echo ""
    
    # Save join command to file
    echo "sudo $join_command" > join-worker.sh
    chmod +x join-worker.sh
    
    success "Join command generated and saved to join-worker.sh"
}

# Function to verify cluster
verify_cluster() {
    log "Verifying cluster status..."
    
    # Check node status
    kubectl get nodes
    
    # Check pod status
    kubectl get pods -n kube-system
    
    # Check cluster info
    kubectl cluster-info
    
    # Check system pods
    kubectl get pods -n kube-system -o wide
    
    success "Cluster verification completed"
}

# Function to install additional tools
install_tools() {
    log "Installing additional tools..."
    
    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    # Install k9s
    wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
    tar -xzf k9s_Linux_amd64.tar.gz
    sudo mv k9s /usr/local/bin/
    rm k9s_Linux_amd64.tar.gz
    
    success "Additional tools installed"
}

# Function to create namespace
create_namespace() {
    log "Creating ecommerce namespace..."
    
    kubectl apply -f k8s-manifests/namespace.yaml
    
    success "Ecommerce namespace created"
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "=========================================="
    echo "CLUSTER SETUP COMPLETED SUCCESSFULLY!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Join worker nodes using the join command above"
    echo "2. Deploy the e-commerce application:"
    echo "   ./scripts/deploy-application.sh"
    echo "3. Set up monitoring:"
    echo "   ./scripts/setup-monitoring.sh"
    echo "4. Run validation tests:"
    echo "   ./validation/smoke-tests.sh"
    echo ""
    echo "Useful commands:"
    echo "- Check cluster status: kubectl get nodes"
    echo "- Check pods: kubectl get pods -A"
    echo "- Access cluster: kubectl cluster-info"
    echo "- Use k9s: k9s"
    echo ""
}

# Main function
main() {
    echo "=========================================="
    echo "E-commerce Foundation Infrastructure Setup"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    check_root
    
    # Check prerequisites
    if [[ "${1:-}" == "--check-prerequisites" ]]; then
        check_prerequisites
        exit 0
    fi
    
    # Run setup steps
    check_prerequisites
    install_packages
    install_docker
    install_kubernetes
    configure_system
    init_master
    generate_join_command
    verify_cluster
    install_tools
    create_namespace
    show_next_steps
    
    success "Cluster setup completed successfully!"
}

# Run main function
main "$@"
