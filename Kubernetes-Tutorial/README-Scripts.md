# 🚀 **Kubernetes Cluster Setup Scripts**

This directory contains automated scripts to set up a production-grade 3-node Kubernetes cluster using kubeadm.

## 📁 **Files Overview**

### **`setup-cluster.sh`**
- **Purpose**: Main setup script for both master and worker nodes
- **Usage**: Run on all nodes (master and workers)
- **Features**: 
  - Detects node role automatically
  - Installs all required components
  - Configures production-grade settings
  - Sets up monitoring stack (master only)

### **`join-worker.sh`**
- **Purpose**: Helper script to join worker nodes to the cluster
- **Usage**: Run on worker nodes after master setup
- **Features**:
  - Validates node preparation
  - Executes join command
  - Verifies successful join

## 🎯 **Quick Start**

### **Step 1: Prepare VMs**
Create 3 Ubuntu 22.04 LTS VMs:
- **Master**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.100
- **Worker 1**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.101  
- **Worker 2**: 4 CPU, 8GB RAM, 50GB SSD, IP: 192.168.1.102

### **Step 2: Run Setup Script**
```bash
# On all nodes (master and workers)
./setup-cluster.sh
```

### **Step 3: Join Worker Nodes**
```bash
# On worker nodes only
./join-worker.sh "kubeadm join 192.168.1.100:6443 --token abc123... --discovery-token-ca-cert-hash sha256:..."
```

## 🔧 **Configuration**

### **Network Configuration**
- **Pod CIDR**: 10.244.0.0/16
- **Service CIDR**: 10.96.0.0/12
- **Cluster Name**: ecommerce-cluster

### **Components Installed**
- **Container Runtime**: containerd
- **CNI**: Calico
- **Package Manager**: Helm
- **Monitoring**: Prometheus + Grafana
- **Storage**: Local storage class

## 📊 **What You Get**

After running the scripts, you'll have:

✅ **Production-Grade Cluster**: Real Kubernetes components  
✅ **Monitoring Stack**: Prometheus + Grafana  
✅ **Package Management**: Helm installed  
✅ **Storage**: Local storage class  
✅ **Security**: Audit logging enabled  
✅ **Networking**: Calico CNI with network policies  

## 🛠️ **Access Your Cluster**

### **Grafana Dashboard**
```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Access: http://localhost:3000 (admin/admin123)
```

### **Prometheus**
```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Access: http://localhost:9090
```

### **Cluster Status**
```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info
```

## 🔍 **Troubleshooting**

### **Common Issues**
1. **Node not ready**: Check containerd status and swap
2. **Pod stuck pending**: Check resource availability
3. **Network issues**: Verify Calico pods are running
4. **Monitoring issues**: Check Prometheus targets

### **Useful Commands**
```bash
# Check node status
kubectl describe node <node-name>

# Check pod events
kubectl describe pod <pod-name>

# Check system logs
sudo journalctl -u kubelet -f

# Check container runtime
sudo systemctl status containerd
```

## 📚 **Next Steps**

1. **Verify cluster**: Run `kubectl get nodes` to ensure all nodes are ready
2. **Deploy test app**: Create a simple nginx deployment
3. **Start learning**: Begin with Prerequisites Module 1 (Container Fundamentals Review)
4. **Deploy e-commerce**: Use your e-commerce application for hands-on learning

## 🎯 **Support**

If you encounter issues:
1. Check the troubleshooting section in `01-Cluster-Setup-Guide.md`
2. Verify all prerequisites are met
3. Check system logs for specific error messages
4. Ensure network connectivity between nodes

---

**Happy Learning! 🚀**
