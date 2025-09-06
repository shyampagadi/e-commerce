# 🔧 **Advanced Networking Troubleshooting Guide**
*Comprehensive troubleshooting procedures for CNI and network policy issues*

## 🚨 **Common Network Issues and Solutions**

### **Issue 1: Pod-to-Pod Communication Failures**

#### **Symptoms**
- Pods cannot reach other pods in the same cluster
- Connection timeouts or "No route to host" errors
- Intermittent connectivity issues

#### **Diagnostic Commands**
```bash
# Check pod network configuration
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Verify CNI plugin status
kubectl get pods -n kube-system | grep -E "(calico|cilium|flannel)"
kubectl logs -n kube-system <cni-pod-name>
```

**Expected Results:**
```
NAME                          READY   STATUS    RESTARTS   AGE     IP           NODE
frontend-7d4b8c8f9d-abc12    1/1     Running   0          2h      10.244.1.5   worker-1
backend-6b9c7d8e9f-def34     1/1     Running   0          2h      10.244.2.8   worker-2

# CNI pods should be Running
calico-node-abc12            1/1     Running   0          1d
calico-node-def34            1/1     Running   0          1d

# CNI logs should show successful initialization
2024/09/05 17:00:00 [INFO] Calico node started successfully
2024/09/05 17:00:01 [INFO] BGP peering established with 192.168.1.10
```

#### **Resolution Steps**

**Step 1: Verify Network Policies**
```bash
# Check if network policies are blocking traffic
kubectl get networkpolicy -A
kubectl describe networkpolicy <policy-name> -n <namespace>
```

**Step 2: Test Direct Connectivity**
```bash
# Test without service abstraction
kubectl exec -it <source-pod> -- ping <destination-pod-ip>
kubectl exec -it <source-pod> -- telnet <destination-pod-ip> <port>
```

**Step 3: Check CNI Configuration**
```bash
# Verify CNI configuration on nodes
ssh <node> "cat /etc/cni/net.d/*.conf"
ssh <node> "ip route show"
```

### **Issue 2: Network Policy Not Working**

#### **Symptoms**
- Traffic is allowed despite deny policies
- Policies seem to have no effect
- Unexpected traffic blocking

#### **Diagnostic Commands**
```bash
# Verify policy application
kubectl get networkpolicy -o yaml
kubectl describe networkpolicy <policy-name>

# Check pod labels match policy selectors
kubectl get pods --show-labels
```

**Expected Results:**
```
NAME                        READY   STATUS    RESTARTS   AGE   LABELS
frontend-7d4b8c8f9d-abc12   1/1     Running   0          2h    app=frontend,pod-template-hash=7d4b8c8f9d,tier=web
backend-6b9c7d8e9f-def34    1/1     Running   0          2h    app=backend,pod-template-hash=6b9c7d8e9f,tier=api

# Network policies should show matching selectors
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-ingress-policy
spec:
  podSelector:
    matchLabels:
      app: frontend  # Must match pod labels exactly
```

**Expected Results:**
```yaml
spec:
  podSelector:
    matchLabels:
      app: frontend  # Must match pod labels exactly
  policyTypes:
  - Ingress
  - Egress
```

#### **Resolution Steps**

**Step 1: Validate Label Matching**
```bash
# Ensure pod labels match policy selectors exactly
kubectl label pod <pod-name> app=frontend --overwrite
kubectl get pods -l app=frontend --show-labels
```

**Step 2: Check Policy Order and Conflicts**
```bash
# List all policies affecting the pod
kubectl get networkpolicy -o json | jq '.items[] | select(.spec.podSelector.matchLabels.app=="frontend")'
```

**Step 3: Enable Policy Logging**
```bash
# For Calico CNI
kubectl patch felixconfiguration default --patch '
spec:
  logSeverityScreen: Debug
  logFilePath: /var/log/calico/felix.log
'

# For Cilium CNI
kubectl patch configmap cilium-config -n kube-system --patch '
data:
  debug: "true"
  enable-policy-debug: "true"
'
```

### **Issue 3: DNS Resolution Failures**

#### **Symptoms**
- Services cannot be reached by name
- "Name resolution failed" errors
- External DNS queries failing

#### **Diagnostic Commands**
```bash
# Test DNS resolution
kubectl exec -it <pod-name> -- nslookup kubernetes.default.svc.cluster.local
kubectl exec -it <pod-name> -- dig @10.96.0.10 kubernetes.default.svc.cluster.local

# Check CoreDNS status
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

**Expected Results:**
```
Server:    10.96.0.10
Address:   10.96.0.10:53

Name:      kubernetes.default.svc.cluster.local
Address:   10.96.0.1
```

#### **Resolution Steps**

**Step 1: Verify CoreDNS Configuration**
```bash
# Check CoreDNS ConfigMap
kubectl get configmap coredns -n kube-system -o yaml
```

**Step 2: Test DNS Egress Policies**
```bash
# Ensure DNS traffic is allowed in network policies
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: <namespace>
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to: []
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
EOF
```

### **Issue 4: External API Access Blocked**

#### **Symptoms**
- Cannot reach external APIs (payment, shipping, etc.)
- Egress traffic blocked unexpectedly
- SSL/TLS handshake failures

#### **Diagnostic Commands**
```bash
# Test external connectivity
kubectl exec -it <pod-name> -- curl -v https://api.stripe.com
kubectl exec -it <pod-name> -- openssl s_client -connect api.stripe.com:443

# Check egress policies
kubectl get networkpolicy -o yaml | grep -A 20 -B 5 egress
```

**Expected Results (if working):**
```
* Connected to api.stripe.com (54.187.216.72) port 443 (#0)
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* Server certificate:
*  subject: CN=*.stripe.com
*  start date: 2024-01-01 00:00:00 GMT
*  expire date: 2025-01-01 00:00:00 GMT
```

#### **Resolution Steps**

**Step 1: Add Specific Egress Rules**
```bash
# Allow egress to specific external services
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-api-egress
  namespace: <namespace>
spec:
  podSelector:
    matchLabels:
      external-access: "allowed"
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 54.187.216.0/24  # Stripe API IP range
    ports:
    - protocol: TCP
      port: 443
EOF
```

**Step 2: Verify IP Ranges**
```bash
# Get current IP addresses for external services
nslookup api.stripe.com
dig api.stripe.com +short
```

## 🔍 **Advanced Troubleshooting Techniques**

### **Network Traffic Analysis**

#### **Using tcpdump on Nodes**
```bash
# Capture traffic on specific interface
ssh <node> "sudo tcpdump -i cali+ -n host <pod-ip>"
ssh <node> "sudo tcpdump -i any -n port 443"
```

**Expected Output:**
```
14:30:15.123456 IP 10.244.1.5.54321 > 54.187.216.72.443: Flags [S], seq 123456789
14:30:15.145678 IP 54.187.216.72.443 > 10.244.1.5.54321: Flags [S.], seq 987654321
```

#### **Using Wireshark for Detailed Analysis**
```bash
# Generate pcap file for analysis
ssh <node> "sudo tcpdump -i any -w /tmp/network-debug.pcap host <pod-ip>"
scp <node>:/tmp/network-debug.pcap ./
```

### **CNI-Specific Troubleshooting**

#### **Calico Troubleshooting**
```bash
# Check Calico node status
kubectl exec -n kube-system <calico-node-pod> -- calicoctl node status
kubectl exec -n kube-system <calico-node-pod> -- calicoctl get ippool -o wide

# Verify BGP peering
kubectl exec -n kube-system <calico-node-pod> -- calicoctl node status
```

**Expected Results:**
```
Calico process is running.

IPv4 BGP status
+---------------+-------------------+-------+----------+-------------+
| PEER ADDRESS  |     PEER TYPE     | STATE |  SINCE   |    INFO     |
+---------------+-------------------+-------+----------+-------------+
| 192.168.1.10  | node-to-node mesh | up    | 14:25:47 | Established |
| 192.168.1.11  | node-to-node mesh | up    | 14:25:47 | Established |
+---------------+-------------------+-------+----------+-------------+
```

#### **Cilium Troubleshooting**
```bash
# Check Cilium connectivity
kubectl exec -n kube-system <cilium-pod> -- cilium status
kubectl exec -n kube-system <cilium-pod> -- cilium connectivity test

# Verify eBPF maps
kubectl exec -n kube-system <cilium-pod> -- cilium bpf policy get
```

**Expected Results:**
```
KVStore:                Ok   etcd: 1/1 connected, lease-ID=29c6732d5a870c96, lock lease-ID=29c6732d5a870c97, has-quorum=true: https://127.0.0.1:2379 - 3.5.4 (Leader)
Kubernetes:             Ok   1.28 (v1.28.2) [linux/amd64]
Kubernetes APIs:        ["cilium/v2::CiliumClusterwideNetworkPolicy", "cilium/v2::CiliumEndpoint"]
KubeProxyReplacement:   Strict   [eth0 192.168.1.10 (Direct Routing)]
Host firewall:          Disabled
CNI Chaining:           none
Cilium:                 Ok   1.14.0 (v1.14.0-snapshot.1)
NodeMonitor:            Listening for events on 2 CPUs with 64x4096 of shared memory
Cilium health daemon:   Ok
IPAM:                   IPv4: 3/254 allocated from 10.244.0.0/24
BandwidthManager:       Enabled
Host Routing:           Legacy
Masquerading:           IPTables [IPv4: Enabled, IPv6: Disabled]
Controller Status:      27/27 healthy
Proxy Status:           OK, ip 10.244.0.1, 0 redirects active on ports 10000-20000
Global Identity Range:  min 256, max 65535
Hubble:                 Ok   Current/Max Flows: 4095/4095 (100.00%), Flows/s: 164.86   Metrics: Disabled
Encryption:             Disabled
Cluster health:         2/2 reachable   (2024-09-05T17:00:00Z)
```

#### **Flannel Troubleshooting**
```bash
# Check Flannel configuration
kubectl get configmap kube-flannel-cfg -n kube-system -o yaml
kubectl logs -n kube-system -l app=flannel

# Verify VXLAN interfaces
ssh <node> "ip link show flannel.1"
ssh <node> "bridge fdb show dev flannel.1"
```

## 📊 **Performance Troubleshooting**

### **Network Latency Issues**

#### **Measuring Latency**
```bash
# Test pod-to-pod latency
kubectl exec -it <source-pod> -- ping -c 10 <destination-pod-ip>
kubectl exec -it <source-pod> -- hping3 -S -p 80 -c 10 <destination-ip>
```

**Expected Results:**
```
PING 10.244.2.8 (10.244.2.8) 56(84) bytes of data.
64 bytes from 10.244.2.8: icmp_seq=1 time=0.123 ms
64 bytes from 10.244.2.8: icmp_seq=2 time=0.145 ms
...
--- 10.244.2.8 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss
round-trip min/avg/max/stddev = 0.123/0.134/0.156/0.012 ms
```

#### **Bandwidth Testing**
```bash
# Install iperf3 in test pods
kubectl exec -it <server-pod> -- iperf3 -s
kubectl exec -it <client-pod> -- iperf3 -c <server-pod-ip> -t 30
```

### **Throughput Optimization**

#### **CNI Performance Tuning**
```bash
# Calico performance tuning
kubectl patch felixconfiguration default --patch '
spec:
  bpfLogLevel: "Off"
  bpfDataIfacePattern: "^(en|eth|ens|eno|bond|team).*"
  bpfConnectTimeLoadBalancingEnabled: true
'

# Cilium performance tuning
kubectl patch configmap cilium-config -n kube-system --patch '
data:
  enable-bandwidth-manager: "true"
  enable-local-redirect-policy: "true"
  kube-proxy-replacement: "strict"
'
```

## 🛡️ **Security Troubleshooting**

### **Policy Bypass Detection**

#### **Monitoring Unexpected Traffic**
```bash
# Enable audit logging for network policies
kubectl patch felixconfiguration default --patch '
spec:
  logSeverityScreen: Info
  logFilePath: /var/log/calico/felix.log
  policyAuditMode: true
'

# Monitor logs for policy violations
kubectl logs -n kube-system -l k8s-app=calico-node | grep -i "policy"
```

### **Certificate and TLS Issues**

#### **Debugging TLS Connections**
```bash
# Test TLS handshake
kubectl exec -it <pod-name> -- openssl s_client -connect api.stripe.com:443 -servername api.stripe.com

# Check certificate chain
kubectl exec -it <pod-name> -- curl -vvv https://api.stripe.com 2>&1 | grep -E "(certificate|SSL|TLS)"
```

**Expected Results:**
```
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* Server certificate:
*  subject: CN=*.stripe.com
*  start date: Jan  1 00:00:00 2024 GMT
*  expire date: Jan  1 00:00:00 2025 GMT
*  issuer: C=US; O=Let's Encrypt; CN=R3
*  SSL certificate verify ok.
```

## 🔄 **Recovery Procedures**

### **CNI Plugin Recovery**

#### **Calico Recovery**
```bash
# Restart Calico components
kubectl delete pods -n kube-system -l k8s-app=calico-node
kubectl delete pods -n kube-system -l k8s-app=calico-kube-controllers

# Verify recovery
kubectl get pods -n kube-system -l k8s-app=calico-node
```

#### **Network Policy Recovery**
```bash
# Backup current policies
kubectl get networkpolicy -A -o yaml > networkpolicy-backup.yaml

# Remove problematic policies
kubectl delete networkpolicy <problematic-policy> -n <namespace>

# Apply corrected policies
kubectl apply -f corrected-networkpolicy.yaml
```

### **Emergency Access Procedures**

#### **Temporary Policy Bypass**
```bash
# Create emergency access policy (use with caution)
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: emergency-access
  namespace: <namespace>
  labels:
    emergency: "true"
spec:
  podSelector:
    matchLabels:
      emergency-access: "true"
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}  # Allow all ingress
  egress:
  - {}  # Allow all egress
EOF

# Label pods that need emergency access
kubectl label pod <pod-name> emergency-access=true
```

## 📋 **Troubleshooting Checklist**

### **Pre-Troubleshooting Checklist**
- [ ] Gather pod names, namespaces, and IP addresses
- [ ] Document expected vs. actual behavior
- [ ] Check recent changes to network policies or CNI configuration
- [ ] Verify cluster and node health status

### **During Troubleshooting**
- [ ] Start with basic connectivity tests
- [ ] Check network policies and label matching
- [ ] Verify CNI plugin status and logs
- [ ] Test DNS resolution
- [ ] Analyze network traffic if needed

### **Post-Resolution**
- [ ] Document root cause and resolution steps
- [ ] Update monitoring and alerting if needed
- [ ] Review and update network policies
- [ ] Conduct post-incident review

## 🚨 **Emergency Contacts and Escalation**

### **Escalation Matrix**
| Issue Severity | Response Time | Escalation Path |
|----------------|---------------|-----------------|
| **Critical** (Production down) | 15 minutes | On-call engineer → Team lead → Manager |
| **High** (Degraded performance) | 1 hour | Team lead → Senior engineer |
| **Medium** (Non-critical issues) | 4 hours | Assigned engineer |
| **Low** (Documentation/improvement) | Next business day | Team backlog |

### **Key Commands for Emergency Response**
```bash
# Quick cluster health check
kubectl get nodes
kubectl get pods -A | grep -v Running
kubectl get networkpolicy -A

# Emergency policy removal (if needed)
kubectl delete networkpolicy --all -n <namespace>

# CNI plugin restart
kubectl delete pods -n kube-system -l k8s-app=<cni-plugin>
```
