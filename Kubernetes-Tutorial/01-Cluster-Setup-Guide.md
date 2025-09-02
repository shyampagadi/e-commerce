# 🖥️ **Production-Grade kubeadm Cluster Setup Guide**
## 3-Node Kubernetes Cluster for Real-World Learning

---

## 📋 **Overview**

This guide will help you set up a production-grade 3-node Kubernetes cluster using kubeadm. This setup closely mimics real production environments and provides maximum learning value for your Kubernetes journey.

## 🎯 **For Complete Beginners**

**Don't worry if you're new to Kubernetes!** This guide is designed to be beginner-friendly. Here's what you need to know:

### **What is Kubernetes?**
- **Think of it as**: A smart manager for your applications
- **What it does**: Automatically runs, scales, and manages your applications
- **Why we need it**: Modern applications are complex and need smart management

### **What is a Cluster?**
- **Think of it as**: A group of computers working together
- **Our setup**: 3 computers (VMs) working as one powerful system
- **Why 3 nodes**: Provides redundancy and high availability

### **What is kubeadm?**
- **Think of it as**: A tool that helps set up Kubernetes
- **What it does**: Installs and configures all the necessary components
- **Why we use it**: It's the standard way to set up production clusters

## 🚀 **Quick Start for Beginners**

**If you want to get started quickly:**

1. **Follow the "Quick Start" section below** - It's automated and beginner-friendly
2. **Don't worry about understanding everything** - You'll learn as you go
3. **The scripts do most of the work** - You just need to run them
4. **Ask questions** - This guide has troubleshooting sections

**If you want to understand everything:**

1. **Read the "Why kubeadm" section** - Understand the benefits
2. **Follow the "Manual Setup" section** - Learn each step
3. **Study the scripts** - See what each command does
4. **Experiment** - Try different configurations

---

## 🎯 **Why kubeadm for Learning?**

| Feature | kubeadm | k3s | kind |
|---------|---------|-----|------|
| **Production Similarity** | ⭐⭐⭐⭐⭐ Very High | ⭐⭐⭐⭐ High | ⭐⭐ Medium |
| **Learning Value** | ⭐⭐⭐⭐⭐ Maximum | ⭐⭐⭐⭐ High | ⭐⭐ Medium |
| **Component Visibility** | ⭐⭐⭐⭐⭐ Full | ⭐⭐⭐ Limited | ⭐⭐ Limited |
| **Troubleshooting Skills** | ⭐⭐⭐⭐⭐ Real | ⭐⭐⭐ Simplified | ⭐⭐ Limited |
| **Career Preparation** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐ Good | ⭐⭐ Basic |

### **Benefits of kubeadm:**
- **Real Kubernetes**: Uses exact same components as production clusters
- **Industry Standard**: What you'll see in 90% of production environments
- **Deep Learning**: Understand every component and how they interact
- **Troubleshooting**: Learn to debug real Kubernetes issues
- **Certification Ready**: Perfect preparation for CKA (Certified Kubernetes Administrator)

---

## 🏗️ **Production-Grade kubeadm Cluster Setup**

### **Hardware Requirements (Optimized for Learning)**

#### **Minimum Requirements:**
- **Master Node**: 4 CPU, 8GB RAM, 50GB SSD
- **Worker Node 1**: 4 CPU, 8GB RAM, 50GB SSD
- **Worker Node 2**: 4 CPU, 8GB RAM, 50GB SSD
- **Network**: Gigabit Ethernet between nodes

#### **Recommended for Production-Like Experience:**
- **Master Node**: 6 CPU, 16GB RAM, 100GB SSD
- **Worker Node 1**: 6 CPU, 16GB RAM, 100GB SSD
- **Worker Node 2**: 6 CPU, 16GB RAM, 100GB SSD
- **Network**: Gigabit Ethernet with low latency

### **VM Configuration**
- **OS**: Ubuntu 22.04 LTS (recommended)
- **Virtualization**: VMware, VirtualBox, or Proxmox
- **CPU**: Enable virtualization features
- **Memory**: Allocate at least 8GB per node
- **Storage**: Use SSD for better performance

## 🚀 **Automated Cluster Setup**

### **Quick Start (Recommended)**

I've created automated scripts that will set up your entire cluster. Here's how to use them:

#### **Step 1: Prepare Your VMs**

**🖥️ VM Creation (Choose Your Virtualization Software):**

**Option A: VMware Workstation/Player**
1. **Download**: Ubuntu 22.04 LTS ISO from ubuntu.com
2. **Create 3 VMs** with these settings:
   - **Master Node**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.100
   - **Worker Node 1**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.101
   - **Worker Node 2**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.102
3. **Network**: Set to "Bridged" or "NAT" mode
4. **Install Ubuntu**: Follow the installation wizard

**Option B: VirtualBox (Detailed Guide)**

## 🖥️ **Complete VirtualBox Setup Guide**

### **📥 Step 1: Download Required Software**

1. **Download VirtualBox**:
   - Go to: https://www.virtualbox.org/wiki/Downloads
   - Download: VirtualBox 7.0+ for your operating system
   - Install VirtualBox following the installation wizard

2. **Download Ubuntu 22.04 LTS**:
   - Go to: https://ubuntu.com/download/desktop
   - Download: Ubuntu 22.04.3 LTS Desktop (64-bit)
   - File size: ~4.7 GB

### **🔧 Step 2: VirtualBox Network Configuration**

**Before creating VMs, configure VirtualBox networking:**

1. **Open VirtualBox Manager**
2. **Go to File → Preferences → Network**
3. **Click "Adds new NAT network" button**
4. **Configure the NAT network**:
   - **Name**: `k8s-network`
   - **Network CIDR**: `192.168.1.0/24`
   - **Enable DHCP**: ✅ (checked)
   - **Click "OK"**

### **🖥️ Step 3: Create Master Node VM**

**Create the first VM (Master Node):**

1. **Click "New" in VirtualBox Manager**
2. **VM Configuration**:
   - **Name**: `k8s-master`
   - **Type**: Linux
   - **Version**: Ubuntu (64-bit)
   - **Memory**: 8192 MB (8 GB)
   - **Hard disk**: Create a virtual hard disk now
   - **Hard disk file type**: VDI (VirtualBox Disk Image)
   - **Storage on physical hard disk**: Dynamically allocated
   - **File location and size**: 50 GB

3. **After VM creation, configure settings**:
   - **Right-click VM → Settings**

4. **System Settings**:
   - **Motherboard tab**:
     - **Base Memory**: 8192 MB
     - **Boot Order**: Optical, Hard Disk
     - **Enable I/O APIC**: ✅
     - **Enable EFI**: ❌
   - **Processor tab**:
     - **Processor(s)**: 4
     - **Enable PAE/NX**: ✅
     - **Enable VT-x/AMD-V**: ✅
     - **Enable Nested Paging**: ✅

5. **Storage Settings**:
   - **Controller IDE**: Click the CD icon → Choose a disk file
   - **Select**: Ubuntu 22.04.3 LTS ISO file
   - **Controller SATA**: Should show the 50 GB hard disk

6. **Network Settings**:
   - **Adapter 1**:
     - **Enable Network Adapter**: ✅
     - **Attached to**: NAT Network
     - **Name**: k8s-network
     - **Advanced**:
       - **Adapter Type**: Intel PRO/1000 MT Desktop
       - **Promiscuous Mode**: Allow All
       - **MAC Address**: Generate new (note this down)

7. **Click "OK" to save settings**

### **🖥️ Step 4: Create Worker Node 1 VM**

**Create the second VM (Worker Node 1):**

1. **Click "New" in VirtualBox Manager**
2. **VM Configuration**:
   - **Name**: `k8s-worker-1`
   - **Type**: Linux
   - **Version**: Ubuntu (64-bit)
   - **Memory**: 8192 MB (8 GB)
   - **Hard disk**: Create a virtual hard disk now
   - **Hard disk file type**: VDI
   - **Storage on physical hard disk**: Dynamically allocated
   - **File location and size**: 50 GB

3. **Configure settings** (same as master node):
   - **System**: 8 GB RAM, 4 CPUs
   - **Storage**: Attach Ubuntu ISO
   - **Network**: NAT Network (k8s-network)

### **🖥️ Step 5: Create Worker Node 2 VM**

**Create the third VM (Worker Node 2):**

1. **Click "New" in VirtualBox Manager**
2. **VM Configuration**:
   - **Name**: `k8s-worker-2`
   - **Type**: Linux
   - **Version**: Ubuntu (64-bit)
   - **Memory**: 8192 MB (8 GB)
   - **Hard disk**: Create a virtual hard disk now
   - **Hard disk file type**: VDI
   - **Storage on physical hard disk**: Dynamically allocated
   - **File location and size**: 50 GB

3. **Configure settings** (same as other nodes):
   - **System**: 8 GB RAM, 4 CPUs
   - **Storage**: Attach Ubuntu ISO
   - **Network**: NAT Network (k8s-network)

### **🚀 Step 6: Install Ubuntu on All VMs**

**For each VM (Master, Worker-1, Worker-2):**

1. **Start the VM**
2. **Ubuntu Installation**:
   - **Language**: English
   - **Installation type**: Erase disk and install Ubuntu
   - **User setup**:
     - **Your name**: `k8s-user`
     - **Username**: `k8s-user`
     - **Password**: Choose a strong password
     - **Confirm password**: Same password
   - **Complete installation**

3. **After installation, restart the VM**

### **🌐 Step 7: Configure Static IP Addresses**

**For each VM, configure static IP addresses:**

1. **Login to the VM**
2. **Open terminal** (Ctrl+Alt+T)
3. **Check current network configuration**:
   ```bash
   ip addr show
   ```
4. **Edit network configuration**:
   ```bash
   sudo nano /etc/netplan/00-installer-config.yaml
   ```

5. **Replace the content with** (adjust IP for each node):

**For Master Node (k8s-master)**:
```yaml
network:
  ethernets:
    enp0s3:  # Your network interface name
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

**For Worker Node 1 (k8s-worker-1)**:
```yaml
network:
  ethernets:
    enp0s3:  # Your network interface name
      dhcp4: false
      addresses:
        - 192.168.1.101/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

**For Worker Node 2 (k8s-worker-2)**:
```yaml
network:
  ethernets:
    enp0s3:  # Your network interface name
      dhcp4: false
      addresses:
        - 192.168.1.102/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
  version: 2
```

6. **Apply the configuration**:
   ```bash
   sudo netplan apply
   ```

7. **Verify the configuration**:
   ```bash
   ip addr show
   ping google.com
   ```

### **🔧 Step 8: Configure VirtualBox Port Forwarding**

**To access VMs from your host machine:**

1. **Open VirtualBox Manager**
2. **For each VM, go to Settings → Network**
3. **Adapter 1 → Advanced → Port Forwarding**
4. **Add these rules for each VM**:

**Master Node (k8s-master)**:
- **Name**: SSH, **Protocol**: TCP, **Host IP**: 127.0.0.1, **Host Port**: 22100, **Guest IP**: 192.168.1.100, **Guest Port**: 22
- **Name**: Kubernetes API, **Protocol**: TCP, **Host IP**: 127.0.0.1, **Host Port**: 6443, **Guest IP**: 192.168.1.100, **Guest Port**: 6443

**Worker Node 1 (k8s-worker-1)**:
- **Name**: SSH, **Protocol**: TCP, **Host IP**: 127.0.0.1, **Host Port**: 22101, **Guest IP**: 192.168.1.101, **Guest Port**: 22

**Worker Node 2 (k8s-worker-2)**:
- **Name**: SSH, **Protocol**: TCP, **Host IP**: 127.0.0.1, **Host Port**: 22102, **Guest IP**: 192.168.1.102, **Guest Port**: 22

### **✅ Step 9: Verify VM Setup**

**Test connectivity between VMs:**

1. **From Master Node**:
   ```bash
   ping 192.168.1.101  # Should reach Worker-1
   ping 192.168.1.102  # Should reach Worker-2
   ping google.com     # Should reach internet
   ```

2. **From Worker Node 1**:
   ```bash
   ping 192.168.1.100  # Should reach Master
   ping 192.168.1.102  # Should reach Worker-2
   ping google.com     # Should reach internet
   ```

3. **From Worker Node 2**:
   ```bash
   ping 192.168.1.100  # Should reach Master
   ping 192.168.1.101  # Should reach Worker-1
   ping google.com     # Should reach internet
   ```

### **🔑 Step 10: Enable SSH Access**

**On each VM, enable SSH:**

1. **Install SSH server**:
   ```bash
   sudo apt update
   sudo apt install openssh-server -y
   ```

2. **Enable SSH service**:
   ```bash
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

3. **Test SSH from host machine**:
   ```bash
   ssh k8s-user@127.0.0.1 -p 22100  # Master node
   ssh k8s-user@127.0.0.1 -p 22101  # Worker-1
   ssh k8s-user@127.0.0.1 -p 22102  # Worker-2
   ```

### **📋 VirtualBox Configuration Summary**

| VM Name | IP Address | Host Port | Guest Port | Purpose |
|---------|------------|-----------|------------|---------|
| k8s-master | 192.168.1.100 | 22100 | 22 | SSH Access |
| k8s-master | 192.168.1.100 | 6443 | 6443 | Kubernetes API |
| k8s-worker-1 | 192.168.1.101 | 22101 | 22 | SSH Access |
| k8s-worker-2 | 192.168.1.102 | 22102 | 22 | SSH Access |

### **🎯 Next Steps**

After completing the VirtualBox setup:

1. **All VMs are ready** with Ubuntu 22.04 LTS
2. **Network connectivity** is configured
3. **SSH access** is enabled
4. **Proceed to Step 2** in the main guide to download and run setup scripts

**Your VirtualBox VMs are now ready for Kubernetes cluster setup!** 🚀

**Option C: Proxmox (Advanced)**
1. **Download**: Proxmox VE and Ubuntu 22.04 LTS ISO
2. **Create 3 VMs** with the same specifications
3. **Network**: Configure bridge networking
4. **Install Ubuntu**: Follow the installation wizard

**🔧 VM Configuration:**

**For Each VM:**
1. **Install Ubuntu 22.04 LTS** (choose "Minimal Installation")
2. **Create a user** with sudo privileges:
   ```bash
   # During installation, create user: k8s-user
   # Or after installation:
   sudo adduser k8s-user
   sudo usermod -aG sudo k8s-user
   ```
3. **Set static IP addresses**:
   ```bash
   # Edit network configuration
   sudo nano /etc/netplan/00-installer-config.yaml
   
   # Add this configuration (adjust for each node):
   network:
     ethernets:
       enp0s3:  # Your network interface name
         dhcp4: false
         addresses:
           - 192.168.1.100/24  # Master node IP
         gateway4: 192.168.1.1
         nameservers:
           addresses: [8.8.8.8, 8.8.4.4]
     version: 2
   
   # Apply configuration
   sudo netplan apply
   ```
4. **Test connectivity**:
   ```bash
   # Test internet connection
   ping google.com
   
   # Test connectivity between nodes
   ping 192.168.1.101  # From master to worker 1
   ping 192.168.1.102  # From master to worker 2
   ```

**✅ Verification Checklist:**
- [ ] All 3 VMs are running Ubuntu 22.04 LTS
- [ ] Each VM has the correct IP address
- [ ] All VMs can ping each other
- [ ] All VMs have internet access
- [ ] User has sudo privileges on all nodes
- [ ] VMs have sufficient resources (4 CPU, 8GB RAM, 50GB SSD)

#### **Step 2: Download and Run Setup Scripts**

**📁 First, Download the Scripts to Your Local Machine:**

1. **Download the setup scripts** from this tutorial to your local computer
2. **Transfer them to your VMs** using one of these methods:

**Method A: Using SCP (Recommended for VirtualBox)**
```bash
# From your local machine, copy scripts to all VMs using port forwarding
scp -P 22100 Kubernetes-Tutorial/setup-cluster.sh k8s-user@127.0.0.1:~/
scp -P 22101 Kubernetes-Tutorial/setup-cluster.sh k8s-user@127.0.0.1:~/
scp -P 22102 Kubernetes-Tutorial/setup-cluster.sh k8s-user@127.0.0.1:~/
scp -P 22101 Kubernetes-Tutorial/join-worker.sh k8s-user@127.0.0.1:~/
scp -P 22102 Kubernetes-Tutorial/join-worker.sh k8s-user@127.0.0.1:~/
```

**Method A1: Using SCP with Direct IPs (If using Bridged Network)**
```bash
# From your local machine, copy scripts to all VMs
scp Kubernetes-Tutorial/setup-cluster.sh k8s-user@192.168.1.100:~/
scp Kubernetes-Tutorial/setup-cluster.sh k8s-user@192.168.1.101:~/
scp Kubernetes-Tutorial/setup-cluster.sh k8s-user@192.168.1.102:~/
scp Kubernetes-Tutorial/join-worker.sh k8s-user@192.168.1.101:~/
scp Kubernetes-Tutorial/join-worker.sh k8s-user@192.168.1.102:~/
```

**Method B: Using USB Drive**
1. Copy the scripts to a USB drive
2. Insert USB into each VM
3. Copy scripts to home directory

**Method C: Manual Download (If you have internet)**
```bash
# On each VM, download from GitHub (replace with actual repo URL)
wget https://raw.githubusercontent.com/your-username/k8s-tutorial/main/setup-cluster.sh
wget https://raw.githubusercontent.com/your-username/k8s-tutorial/main/join-worker.sh
```

**🚀 Then Run the Setup Scripts:**

**On Master Node (192.168.1.100):**
```bash
# Make script executable
chmod +x setup-cluster.sh

# Run the setup script
./setup-cluster.sh
```

**On Worker Nodes (192.168.1.101 and 192.168.1.102):**
```bash
# Make script executable
chmod +x setup-cluster.sh

# Run the setup script
./setup-cluster.sh
```

#### **Step 3: Join Worker Nodes**

After the master node setup completes, you'll get a join command. Use it on worker nodes:

```bash
# Download the join script
wget https://raw.githubusercontent.com/your-repo/k8s-cluster-setup/main/join-worker.sh
chmod +x join-worker.sh

# Join the cluster (replace with actual join command from master)
./join-worker.sh "kubeadm join 192.168.1.100:6443 --token abc123... --discovery-token-ca-cert-hash sha256:..."
```

### **What the Scripts Do Automatically:**

**🔧 System Preparation (All Nodes)**
- **Updates packages**: Ensures all software is up-to-date
- **Configures hostnames**: Sets proper names for each node
- **Disables swap**: Required for Kubernetes to work properly
- **Configures firewall**: Opens necessary ports for communication

**🐳 Container Runtime Setup (All Nodes)**
- **Installs containerd**: The container runtime that runs your applications
- **Configures systemd**: Ensures proper integration with Linux system

**☸️ Kubernetes Installation (All Nodes)**
- **Installs kubelet**: The agent that runs on each node
- **Installs kubeadm**: The tool that sets up the cluster
- **Installs kubectl**: The command-line tool to manage the cluster

**🎯 Cluster Initialization (Master Node Only)**
- **Initializes cluster**: Sets up the control plane
- **Configures kubectl**: Allows you to manage the cluster
- **Sets up audit logging**: Records all cluster activities
- **Creates certificates**: Secures cluster communication

**🌐 Networking Setup (Master Node Only)**
- **Installs Calico**: Provides networking between pods
- **Configures DNS**: Allows services to find each other
- **Waits for readiness**: Ensures everything is working

**📊 Monitoring Setup (Master Node Only)**
- **Installs Prometheus**: Collects metrics from the cluster
- **Installs Grafana**: Creates beautiful dashboards
- **Sets up alerting**: Notifies you of problems

**📦 Package Management (Master Node Only)**
- **Installs Helm**: Makes it easy to install applications
- **Creates storage class**: Allows applications to store data
- **Generates join commands**: Helps worker nodes join the cluster

**✅ Verification (All Nodes)**
- **Checks cluster status**: Ensures everything is working
- **Verifies components**: Confirms all parts are running
- **Tests connectivity**: Ensures nodes can communicate

### **Manual Setup (For Learning)**

If you prefer to understand each step, follow the manual setup below.

---

## 📋 **Manual Setup Process**

### **Phase 1: Node Preparation**

#### **1. Prepare All Nodes**

```bash
# Update system on all nodes
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget git vim htop net-tools

# Configure hostnames
# On master node:
sudo hostnamectl set-hostname k8s-master
echo "127.0.0.1 k8s-master" | sudo tee -a /etc/hosts

# On worker node 1:
sudo hostnamectl set-hostname k8s-worker-1
echo "127.0.0.1 k8s-worker-1" | sudo tee -a /etc/hosts

# On worker node 2:
sudo hostnamectl set-hostname k8s-worker-2
echo "127.0.0.1 k8s-worker-2" | sudo tee -a /etc/hosts
```

#### **2. Configure Network (All Nodes)**

```bash
# Disable swap (required for Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Configure firewall
sudo ufw allow 6443/tcp    # Kubernetes API server
sudo ufw allow 2379:2380/tcp  # etcd server client API
sudo ufw allow 10250/tcp   # Kubelet API
sudo ufw allow 10251/tcp   # kube-scheduler
sudo ufw allow 10252/tcp   # kube-controller-manager
sudo ufw allow 10255/tcp   # Read-only Kubelet API
sudo ufw allow 30000:32767/tcp  # NodePort services
sudo ufw allow 179/tcp     # Calico BGP
sudo ufw allow 4789/udp    # Calico VXLAN
```

#### **3. Install Container Runtime (All Nodes)**

```bash
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
```

#### **4. Install Kubernetes Components (All Nodes)**

```bash
# Add Kubernetes GPG key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

# Add Kubernetes repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### **Phase 2: Cluster Initialization**

#### **5. Initialize Master Node**

```bash
# Create kubeadm configuration
sudo tee /tmp/kubeadm-config.yaml > /dev/null <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.28.0
controlPlaneEndpoint: "192.168.1.100:6443"
clusterName: "ecommerce-cluster"
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
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
  advertiseAddress: "192.168.1.100"
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

# Initialize cluster
sudo kubeadm init --config=/tmp/kubeadm-config.yaml

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### **6. Install CNI (Calico)**

```bash
# Install Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

# Wait for nodes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s
```

#### **7. Join Worker Nodes**

```bash
# Get join command from master
sudo kubeadm token create --print-join-command

# Run the join command on each worker node
# Example: sudo kubeadm join 192.168.1.100:6443 --token abc123... --discovery-token-ca-cert-hash sha256:...
```

#### **8. Verify Cluster**

```bash
# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -A

# Check cluster info
kubectl cluster-info
```

---

## 🛠️ **Post-Installation Setup**

### **Access Your Cluster**

#### **From Master Node:**
```bash
# Check cluster status
kubectl get nodes -o wide
kubectl get pods -A

# Access Grafana dashboard
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Access: http://localhost:3000 (admin/admin123)

# Access Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Access: http://localhost:9090
```

#### **From Your Local Machine:**
```bash
# Copy kubeconfig from master node
scp user@192.168.1.100:~/.kube/config ~/.kube/config

# Test cluster access
kubectl get nodes
kubectl cluster-info
```

### **Deploy Your E-commerce Application**

#### **Create Namespaces:**
```bash
# Create environment namespaces
kubectl create namespace ecommerce-dev
kubectl create namespace ecommerce-uat
kubectl create namespace ecommerce-prod
```

#### **Deploy Test Application:**
```bash
# Deploy a simple test application
kubectl create deployment nginx --image=nginx --namespace=ecommerce-dev
kubectl expose deployment nginx --port=80 --type=NodePort --namespace=ecommerce-dev

# Check deployment
kubectl get pods -n ecommerce-dev
kubectl get services -n ecommerce-dev
```

### **Cluster Management Commands**

#### **Useful kubectl Commands:**
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A

# Check system resources
kubectl top nodes
kubectl top pods -A

# Check cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs -f deployment/nginx -n ecommerce-dev
```

#### **Helm Commands:**
```bash
# List installed charts
helm list -A

# Check monitoring stack
helm list -n monitoring

# Upgrade monitoring stack
helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring
```

---

## 🔧 **Troubleshooting Common Issues**

### **🚨 Before You Start - Common Beginner Mistakes**

**❌ Wrong IP Addresses**
- **Problem**: VMs can't communicate with each other
- **Solution**: Double-check IP addresses in network configuration
- **Test**: `ping 192.168.1.101` from master node

**❌ Insufficient Resources**
- **Problem**: Cluster setup fails or runs slowly
- **Solution**: Ensure each VM has at least 4 CPU, 8GB RAM, 50GB SSD
- **Check**: `free -h` and `df -h` on each node

**❌ Wrong User Permissions**
- **Problem**: Scripts fail with permission errors
- **Solution**: Ensure user has sudo privileges
- **Test**: `sudo -v` should not ask for password

**❌ Network Issues**
- **Problem**: VMs can't reach internet or each other
- **Solution**: Check network configuration and firewall
- **Test**: `ping google.com` and `ping <other-node-ip>`

**❌ VirtualBox-Specific Issues**
- **Problem**: VMs can't start or run slowly
- **Solution**: Enable virtualization in BIOS, allocate sufficient resources
- **Check**: VirtualBox settings, host machine resources

**❌ Port Forwarding Issues**
- **Problem**: Can't SSH to VMs from host machine
- **Solution**: Check VirtualBox port forwarding rules
- **Test**: `ssh k8s-user@127.0.0.1 -p 22100`

### **🔍 Step-by-Step Troubleshooting**

### **1. Node Not Ready**

**Symptoms**: Node shows "NotReady" status
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check container runtime
sudo systemctl status containerd

# Check if swap is disabled
free -h
```

**Common Fixes**:
- **Swap not disabled**: Run `sudo swapoff -a`
- **Container runtime not running**: Run `sudo systemctl restart containerd`
- **Network issues**: Check firewall and network configuration

### **2. Pod Stuck in Pending**

**Symptoms**: Pods don't start or stay in "Pending" state
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check resource availability
kubectl describe nodes
kubectl top nodes

# Check taints and tolerations
kubectl describe nodes | grep -i taint
```

**Common Fixes**:
- **Insufficient resources**: Increase VM resources
- **Node taints**: Remove taints or add tolerations
- **Storage issues**: Check storage classes and persistent volumes

### **3. Network Issues**

**Symptoms**: Pods can't communicate with each other
```bash
# Check CNI pods
kubectl get pods -n kube-system

# Check network policies
kubectl get networkpolicies -A

# Test connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh
```

**Common Fixes**:
- **CNI not installed**: Reinstall Calico
- **Firewall blocking**: Check firewall rules
- **Network policies**: Review network policy configuration

### **4. Storage Issues**

**Symptoms**: Applications can't store data
```bash
# Check storage classes
kubectl get storageclass

# Check persistent volumes
kubectl get pv

# Check persistent volume claims
kubectl get pvc -A
```

**Common Fixes**:
- **No storage class**: Create local storage class
- **Storage not available**: Check disk space and permissions
- **PVC stuck**: Check storage class and node resources

### **5. Monitoring Issues**

**Symptoms**: Prometheus or Grafana not working
```bash
# Check monitoring pods
kubectl get pods -n monitoring

# Check Prometheus targets
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Access http://localhost:9090/targets
```

**Common Fixes**:
- **Pods not running**: Check resource limits and node capacity
- **Port forwarding issues**: Check if ports are available
- **Configuration errors**: Review Prometheus and Grafana configuration

### **🆘 Getting Help**

**If you're still stuck:**

1. **Check the logs**: Most errors are in the logs
2. **Google the error**: Someone else has probably had the same issue
3. **Ask for help**: Post your error message and what you've tried
4. **Start over**: Sometimes it's faster to start fresh

**Useful Commands for Debugging**:
```bash
# Check cluster status
kubectl cluster-info

# Check all pods
kubectl get pods -A

# Check node resources
kubectl top nodes

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs -f <pod-name> -n <namespace>
```

---

## 📝 **Next Steps**

1. **✅ Cluster Setup Complete**: Your production-grade cluster is ready
2. **📚 Begin Learning**: Start with Prerequisites Module 1 (Container Fundamentals Review)
3. **🚀 Deploy Applications**: Use your e-commerce application for hands-on learning
4. **📊 Monitor Everything**: Use Grafana and Prometheus for observability
5. **🔧 Practice Troubleshooting**: Break things intentionally to learn debugging

---

## 🎯 **Summary**

You now have a **production-grade Kubernetes cluster** that includes:

✅ **Real Kubernetes Components**: etcd, kube-apiserver, kube-scheduler, kube-controller-manager  
✅ **Production Networking**: Calico CNI with network policies support  
✅ **Monitoring Stack**: Prometheus + Grafana for observability  
✅ **Package Management**: Helm for application deployment  
✅ **Storage**: Local storage class for persistent volumes  
✅ **Security**: Audit logging and proper RBAC setup  
✅ **Multi-Environment**: Ready for DEV/UAT/PROD deployments  

**This cluster provides the perfect foundation for your Kubernetes learning journey! 🚀**

---

## 📋 **Quick Reference for Beginners**

### **🎯 What You'll Have After Setup:**
- ✅ **3-node Kubernetes cluster** running on VMs
- ✅ **Production-grade configuration** with monitoring
- ✅ **Prometheus + Grafana** for observability
- ✅ **Helm package manager** for easy app deployment
- ✅ **Local storage** for persistent data
- ✅ **Security features** with audit logging

### **🚀 What You Can Do Next:**
1. **Deploy your e-commerce app** using the tutorial modules
2. **Learn Kubernetes concepts** with hands-on practice
3. **Experiment with chaos engineering** to test resilience
4. **Build production skills** with real-world scenarios

### **📚 Learning Path:**
1. **Start with Module 1**: Container Fundamentals Review
2. **Follow the tutorial modules** in order
3. **Practice with your cluster** as you learn
4. **Build confidence** with real-world experience

### **🆘 Need Help?**
- **Check troubleshooting section** above
- **Read the error messages** carefully
- **Google specific error codes**
- **Ask for help** with specific details

**Remember**: Every expert was once a beginner. Take your time, follow the steps, and don't be afraid to experiment! 🎉
