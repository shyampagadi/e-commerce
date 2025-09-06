# 🔧 **Troubleshooting Guide**
## *E-commerce Foundation Infrastructure Project*

**Document Version**: 1.0  
**Date**: $(date)  
**Project**: E-commerce Foundation Infrastructure  
**Dependencies**: Operations Runbook v1.0  

---

## 🎯 **Troubleshooting Overview**

This guide provides comprehensive troubleshooting procedures for common issues in the E-commerce Foundation Infrastructure. It covers diagnosis, resolution, and prevention strategies.

---

## 🚨 **Critical Issues**

### **Issue 1: Cluster Not Responding**

#### **Symptoms**
- `kubectl` commands hang or timeout
- API server not accessible
- Nodes showing `NotReady` status

#### **Diagnosis**

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -n kube-system

# Check API server logs
sudo journalctl -u kubelet -f

# Check network connectivity
ping <master-ip>
telnet <master-ip> 6443

# Check system resources
free -h
df -h
top
```

#### **Resolution**

```bash
# Restart kubelet
sudo systemctl restart kubelet

# Check and fix network issues
sudo systemctl restart docker
sudo systemctl restart containerd

# Verify cluster configuration
sudo kubeadm config print init-defaults
sudo kubeadm config print join-defaults

# Reinitialize cluster if necessary
sudo kubeadm reset --force
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<master-ip>
```

#### **Prevention**
- Monitor cluster health regularly
- Set up alerts for API server availability
- Maintain adequate system resources
- Keep cluster components updated

---

### **Issue 2: Pods Stuck in Pending State**

#### **Symptoms**
```
NAME                    READY   STATUS    RESTARTS   AGE
ecommerce-backend-xxx   0/1     Pending   0          5m
```

#### **Diagnosis**

```bash
# Check pod details
kubectl describe pod <pod-name> -n ecommerce

# Check node resources
kubectl top nodes
kubectl describe nodes

# Check for resource quotas
kubectl get resourcequota -n ecommerce
kubectl describe resourcequota ecommerce-quota -n ecommerce

# Check for node selectors
kubectl get pods -n ecommerce -o wide
```

#### **Resolution**

```bash
# Check resource availability
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory

# Adjust resource requests if needed
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'

# Check for node affinity issues
kubectl get nodes --show-labels
kubectl describe pod <pod-name> -n ecommerce | grep -A 10 "Node-Selectors"

# Remove problematic node selectors
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"nodeSelector":null}}}}'
```

#### **Prevention**
- Set appropriate resource requests and limits
- Monitor node resource usage
- Use node affinity carefully
- Regular cluster capacity planning

---

### **Issue 3: Service Not Accessible**

#### **Symptoms**
- Cannot access application via service IP
- Connection timeouts
- Service endpoints empty

#### **Diagnosis**

```bash
# Check service configuration
kubectl get svc -n ecommerce
kubectl describe svc ecommerce-backend-service -n ecommerce

# Check endpoints
kubectl get endpoints -n ecommerce
kubectl describe endpoints ecommerce-backend-service -n ecommerce

# Check pod labels
kubectl get pods -n ecommerce --show-labels
kubectl get svc ecommerce-backend-service -n ecommerce -o yaml | grep selector

# Test pod connectivity
kubectl exec -it <pod-name> -n ecommerce -- curl localhost:8000/health
```

#### **Resolution**

```bash
# Fix label selector mismatch
kubectl get pods -n ecommerce --show-labels
kubectl get svc ecommerce-backend-service -n ecommerce -o yaml

# Update service selector if needed
kubectl patch svc ecommerce-backend-service -n ecommerce -p '{"spec":{"selector":{"app":"ecommerce-backend"}}}'

# Check port configuration
kubectl get svc ecommerce-backend-service -n ecommerce -o yaml | grep -A 5 ports

# Fix port mismatch
kubectl patch svc ecommerce-backend-service -n ecommerce -p '{"spec":{"ports":[{"port":80,"targetPort":8000,"protocol":"TCP","name":"http"}]}}'
```

#### **Prevention**
- Ensure consistent labeling strategy
- Verify port configurations
- Test service connectivity regularly
- Use service discovery best practices

---

## ⚠️ **High Priority Issues**

### **Issue 4: High Resource Usage**

#### **Symptoms**
- Pods exceeding resource limits
- Node resource exhaustion
- System performance degradation

#### **Diagnosis**

```bash
# Check resource usage
kubectl top pods -n ecommerce --containers
kubectl top nodes

# Check resource limits
kubectl describe pod <pod-name> -n ecommerce | grep -A 10 "Limits:"

# Check for resource leaks
kubectl exec -it <pod-name> -n ecommerce -- ps aux
kubectl exec -it <pod-name> -n ecommerce -- free -h

# Check for memory leaks
kubectl exec -it <pod-name> -n ecommerce -- cat /proc/meminfo
```

#### **Resolution**

```bash
# Scale up if needed
kubectl scale deployment ecommerce-backend --replicas=3 -n ecommerce

# Adjust resource limits
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"limits":{"cpu":"1000m","memory":"1Gi"}}}]}}}}'

# Restart problematic pods
kubectl delete pod <pod-name> -n ecommerce

# Check for resource quotas
kubectl get resourcequota -n ecommerce
kubectl patch resourcequota ecommerce-quota -n ecommerce -p '{"spec":{"hard":{"requests.cpu":"4","requests.memory":"8Gi"}}}'
```

#### **Prevention**
- Set appropriate resource limits
- Monitor resource usage trends
- Implement horizontal pod autoscaling
- Regular performance testing

---

### **Issue 5: Container Image Pull Failures**

#### **Symptoms**
```
Failed to pull image "ecommerce-backend:v1.0.0"
```

#### **Diagnosis**

```bash
# Check image availability
docker images | grep ecommerce-backend
kubectl describe pod <pod-name> -n ecommerce | grep -A 10 "Events:"

# Check image pull secrets
kubectl get secrets -n ecommerce
kubectl describe secret <secret-name> -n ecommerce

# Check registry connectivity
docker pull ecommerce-backend:v1.0.0
```

#### **Resolution**

```bash
# Build and push image locally
docker build -t ecommerce-backend:v1.0.0 ./backend
docker tag ecommerce-backend:v1.0.0 localhost:5000/ecommerce-backend:v1.0.0
docker push localhost:5000/ecommerce-backend:v1.0.0

# Update deployment with correct image
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","image":"localhost:5000/ecommerce-backend:v1.0.0"}]}}}}'

# Create image pull secret if needed
kubectl create secret docker-registry regcred --docker-server=<registry> --docker-username=<username> --docker-password=<password> -n ecommerce
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"regcred"}]}}}}'
```

#### **Prevention**
- Use reliable container registry
- Implement image caching strategies
- Set up image pull secrets properly
- Test image pulls before deployment

---

## 🔍 **Medium Priority Issues**

### **Issue 6: Monitoring Not Working**

#### **Symptoms**
- No metrics in Prometheus
- Grafana dashboards empty
- Alerts not firing

#### **Diagnosis**

```bash
# Check monitoring pods
kubectl get pods -n monitoring
kubectl logs <prometheus-pod> -n monitoring

# Check Prometheus configuration
kubectl get configmap prometheus-config -n monitoring -o yaml

# Check service discovery
kubectl get endpoints -n ecommerce
kubectl get svc -n ecommerce

# Test metrics endpoint
kubectl exec -it <prometheus-pod> -n monitoring -- curl localhost:9090/api/v1/targets
```

#### **Resolution**

```bash
# Restart monitoring components
kubectl delete pod <prometheus-pod> -n monitoring
kubectl delete pod <grafana-pod> -n monitoring

# Check Prometheus configuration
kubectl apply -f monitoring/prometheus/prometheus-configmap.yaml

# Verify service discovery
kubectl get svc -n ecommerce
kubectl get endpoints -n ecommerce

# Test metrics collection
kubectl exec -it <prometheus-pod> -n monitoring -- promtool query instant 'up'
```

#### **Prevention**
- Regular monitoring system health checks
- Validate configuration changes
- Test metrics collection after deployments
- Monitor monitoring system itself

---

### **Issue 7: Network Connectivity Issues**

#### **Symptoms**
- Pods cannot communicate with each other
- External access not working
- DNS resolution failures

#### **Diagnosis**

```bash
# Check network policies
kubectl get networkpolicies -n ecommerce
kubectl describe networkpolicy <policy-name> -n ecommerce

# Test pod-to-pod communication
kubectl exec -it <pod1> -n ecommerce -- ping <pod2-ip>
kubectl exec -it <pod1> -n ecommerce -- nslookup <service-name>

# Check CNI plugin
kubectl get pods -n kube-system | grep flannel
kubectl logs <flannel-pod> -n kube-system

# Check node network
ip route show
iptables -L
```

#### **Resolution**

```bash
# Restart CNI plugin
kubectl delete pod <flannel-pod> -n kube-system

# Check network policies
kubectl delete networkpolicy <policy-name> -n ecommerce

# Verify DNS configuration
kubectl get svc -n kube-system | grep dns
kubectl get endpoints -n kube-system | grep dns

# Test network connectivity
kubectl exec -it <pod> -n ecommerce -- curl <service-name>.<namespace>.svc.cluster.local
```

#### **Prevention**
- Test network policies before applying
- Monitor CNI plugin health
- Regular network connectivity tests
- Document network requirements

---

## 🔧 **Low Priority Issues**

### **Issue 8: Log Collection Problems**

#### **Symptoms**
- Logs not appearing in centralized system
- Log rotation issues
- High disk usage from logs

#### **Diagnosis**

```bash
# Check log volumes
kubectl exec -it <pod> -n ecommerce -- df -h
kubectl exec -it <pod> -n ecommerce -- du -sh /var/log

# Check log configuration
kubectl exec -it <pod> -n ecommerce -- cat /etc/logrotate.conf
kubectl exec -it <pod> -n ecommerce -- ls -la /var/log

# Check log collection
kubectl logs <pod> -n ecommerce --tail=100
```

#### **Resolution**

```bash
# Clean up old logs
kubectl exec -it <pod> -n ecommerce -- find /var/log -name "*.log" -mtime +7 -delete

# Configure log rotation
kubectl exec -it <pod> -n ecommerce -- logrotate -f /etc/logrotate.conf

# Set up log collection
kubectl apply -f monitoring/fluentd/fluentd-configmap.yaml
kubectl apply -f monitoring/fluentd/fluentd-daemonset.yaml
```

#### **Prevention**
- Implement log rotation policies
- Monitor disk usage
- Use centralized logging
- Regular log cleanup

---

### **Issue 9: Security Policy Violations**

#### **Symptoms**
- Pods failing security checks
- RBAC permission errors
- Network policy violations

#### **Diagnosis**

```bash
# Check security contexts
kubectl get pods -n ecommerce -o yaml | grep -A 10 securityContext

# Check RBAC
kubectl get roles -n ecommerce
kubectl get rolebindings -n ecommerce
kubectl auth can-i <verb> <resource> -n ecommerce

# Check network policies
kubectl get networkpolicies -n ecommerce
kubectl describe networkpolicy <policy-name> -n ecommerce
```

#### **Resolution**

```bash
# Fix security context
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":1000}}}}}}'

# Fix RBAC permissions
kubectl create rolebinding <user>-binding --role=developer --serviceaccount=ecommerce:<user> -n ecommerce

# Fix network policies
kubectl apply -f k8s-manifests/network-policies.yaml
```

#### **Prevention**
- Regular security audits
- Implement security policies
- Test security configurations
- Monitor security violations

---

## 🛠️ **Diagnostic Tools**

### **Cluster Health Check Script**

```bash
#!/bin/bash
# cluster-health-check.sh

echo "=== Cluster Health Check ==="
echo "Date: $(date)"
echo ""

echo "1. Node Status:"
kubectl get nodes
echo ""

echo "2. Pod Status:"
kubectl get pods -A
echo ""

echo "3. Resource Usage:"
kubectl top nodes
kubectl top pods -A
echo ""

echo "4. Service Status:"
kubectl get svc -A
echo ""

echo "5. Recent Events:"
kubectl get events --sort-by='.lastTimestamp' -A --field-selector=type!=Normal
echo ""

echo "6. Storage Status:"
kubectl get pv
kubectl get pvc -A
echo ""

echo "7. Network Status:"
kubectl get networkpolicies -A
echo ""

echo "=== Health Check Complete ==="
```

### **Application Health Check Script**

```bash
#!/bin/bash
# app-health-check.sh

echo "=== Application Health Check ==="
echo "Date: $(date)"
echo ""

echo "1. E-commerce Pods:"
kubectl get pods -n ecommerce
echo ""

echo "2. E-commerce Services:"
kubectl get svc -n ecommerce
echo ""

echo "3. Application Logs:"
kubectl logs -l app=ecommerce-backend -n ecommerce --tail=10
echo ""

echo "4. Health Endpoint:"
kubectl port-forward svc/ecommerce-backend-service 8080:80 -n ecommerce &
sleep 5
curl -s http://localhost:8080/health || echo "Health check failed"
kill %1
echo ""

echo "5. Resource Usage:"
kubectl top pods -n ecommerce
echo ""

echo "=== Application Health Check Complete ==="
```

---

## 📊 **Performance Troubleshooting**

### **Slow Application Response**

#### **Diagnosis**
```bash
# Check application performance
kubectl exec -it <pod> -n ecommerce -- curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8000/health

# Check resource usage
kubectl top pods -n ecommerce --containers

# Check for bottlenecks
kubectl exec -it <pod> -n ecommerce -- iostat -x 1 5
kubectl exec -it <pod> -n ecommerce -- netstat -i
```

#### **Resolution**
```bash
# Scale up application
kubectl scale deployment ecommerce-backend --replicas=3 -n ecommerce

# Optimize resource allocation
kubectl patch deployment ecommerce-backend -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"requests":{"cpu":"500m","memory":"512Mi"}}}]}}}}'

# Check for memory leaks
kubectl exec -it <pod> -n ecommerce -- ps aux --sort=-%mem
```

---

## 🔍 **Log Analysis**

### **Common Log Patterns**

| Pattern | Meaning | Action |
|---------|---------|--------|
| `OutOfMemory` | Memory limit exceeded | Increase memory limits or fix memory leak |
| `ImagePullBackOff` | Cannot pull container image | Check image availability and credentials |
| `CrashLoopBackOff` | Pod keeps crashing | Check application logs and fix bugs |
| `Pending` | Pod cannot be scheduled | Check resource availability and constraints |
| `Failed` | Pod failed to start | Check pod events and configuration |

### **Log Analysis Commands**

```bash
# Search for errors
kubectl logs <pod> -n ecommerce | grep -i error

# Search for specific patterns
kubectl logs <pod> -n ecommerce | grep -E "(timeout|connection|refused)"

# Follow logs in real-time
kubectl logs -f <pod> -n ecommerce

# Get logs from all pods
kubectl logs -l app=ecommerce-backend -n ecommerce

# Get logs from previous container
kubectl logs <pod> -n ecommerce --previous
```

---

## 📞 **Escalation Procedures**

### **When to Escalate**

- **P1 Issues**: Escalate immediately if not resolved in 15 minutes
- **P2 Issues**: Escalate if not resolved in 1 hour
- **P3 Issues**: Escalate if not resolved in 4 hours
- **P4 Issues**: Escalate if not resolved in 24 hours

### **Information to Include**

- Issue description and symptoms
- Steps taken to diagnose
- Error messages and logs
- Current system state
- Impact assessment
- Proposed resolution

---

**Document Status**: Active  
**Last Updated**: $(date)  
**Next Review**: $(date + 30 days)  
**Maintainer**: Platform Engineering Team
