# 🔧 **Troubleshooting Guide: Core Workloads Deployment**

## **Document Information**
- **Document Type**: Troubleshooting Guide
- **Version**: 1.0
- **Date**: December 2024
- **Author**: Senior Kubernetes Architect
- **Status**: Approved
- **Review Cycle**: Monthly

---

## **🎯 Executive Summary**

**Project**: E-commerce Core Workloads Deployment  
**Scope**: Production Troubleshooting and Issue Resolution  
**Target**: < 5 minute Mean Time to Resolution (MTTR)  
**Team**: Platform Engineering, DevOps, SRE  

### **Troubleshooting Overview**
This guide provides comprehensive troubleshooting procedures for the production-ready e-commerce platform with advanced Kubernetes workload management capabilities. It covers common issues, root cause analysis, and resolution procedures.

---

## **🚨 Critical Issues (P0)**

### **Issue 1: Cluster Down**

#### **Symptoms**
- All nodes showing `NotReady` status
- API server not responding
- kubectl commands failing

#### **Root Cause Analysis**
```bash
# Check cluster status
kubectl get nodes
kubectl cluster-info
kubectl get pods --all-namespaces

# Check system resources
kubectl top nodes
kubectl describe nodes
```

#### **Common Causes**
1. **etcd Cluster Failure**: etcd nodes down or corrupted
2. **API Server Failure**: API server pods crashed
3. **Network Issues**: CNI plugin failure
4. **Resource Exhaustion**: Node resources exhausted

#### **Resolution Steps**

**Step 1: Check etcd Status**
```bash
# Check etcd cluster health
etcdctl --endpoints=https://10.0.1.10:2379,https://10.0.1.11:2379,https://10.0.1.12:2379 \
  --cacert=/etc/kubernetes/pki/etcd/etcd-ca.crt \
  --cert=/etc/kubernetes/pki/etcd/etcd-client.crt \
  --key=/etc/kubernetes/pki/etcd/etcd-client.key \
  endpoint health
```

**Expected Output**:
```
https://10.0.1.10:2379 is healthy: successfully committed proposal: took = 2.123456ms
https://10.0.1.11:2379 is healthy: successfully committed proposal: took = 1.987654ms
https://10.0.1.12:2379 is healthy: successfully committed proposal: took = 2.345678ms
```

**Action if etcd Down**:
```bash
# Restart etcd service
systemctl restart etcd
systemctl status etcd

# Check etcd logs
journalctl -u etcd -f
```

**Step 2: Check API Server Status**
```bash
# Check API server pods
kubectl get pods -n kube-system -l component=kube-apiserver

# Check API server logs
kubectl logs -n kube-system -l component=kube-apiserver --tail=100
```

**Action if API Server Down**:
```bash
# Restart API server
kubectl delete pod -n kube-system -l component=kube-apiserver

# Check API server configuration
kubectl get configmap -n kube-system kube-apiserver -o yaml
```

**Step 3: Check Network Status**
```bash
# Check CNI plugin status
kubectl get pods -n kube-system -l app=calico

# Check network policies
kubectl get networkpolicies --all-namespaces
```

**Action if Network Issues**:
```bash
# Restart CNI plugin
kubectl delete pod -n kube-system -l app=calico

# Check network configuration
kubectl get configmap -n kube-system calico-config -o yaml
```

#### **Verification**
```bash
# Verify cluster recovery
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```

**Expected Output**:
```
All nodes Ready
All pods Running
Cluster info accessible
```

---

### **Issue 2: Application Down**

#### **Symptoms**
- Application pods not running
- Service endpoints not available
- Health checks failing

#### **Root Cause Analysis**
```bash
# Check application status
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get deployments -n ecommerce

# Check pod logs
kubectl logs -l app=ecommerce-backend -n ecommerce --tail=100
kubectl logs -l app=ecommerce-frontend -n ecommerce --tail=100
```

#### **Common Causes**
1. **Image Pull Issues**: Container images not available
2. **Configuration Issues**: ConfigMaps or Secrets missing
3. **Resource Issues**: Insufficient resources
4. **Health Check Failures**: Application not responding

#### **Resolution Steps**

**Step 1: Check Image Availability**
```bash
# Check image pull status
kubectl describe pod ecommerce-backend-pod -n ecommerce | grep -A 10 "Events"

# Check image tags
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}'
```

**Action if Image Issues**:
```bash
# Update image tag
kubectl set image deployment/ecommerce-backend-deployment \
  ecommerce-backend=ecommerce-backend:v1.0.0 -n ecommerce

# Check image registry
docker pull ecommerce-backend:v1.0.0
```

**Step 2: Check Configuration**
```bash
# Check ConfigMaps
kubectl get configmaps -n ecommerce
kubectl describe configmap ecommerce-app-config -n ecommerce

# Check Secrets
kubectl get secrets -n ecommerce
kubectl describe secret postgresql-secrets -n ecommerce
```

**Action if Configuration Issues**:
```bash
# Recreate ConfigMap
kubectl apply -f app-config.yaml

# Recreate Secret
kubectl apply -f database-secrets.yaml
```

**Step 3: Check Resources**
```bash
# Check resource usage
kubectl top pods -n ecommerce
kubectl describe nodes

# Check resource limits
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
```

**Action if Resource Issues**:
```bash
# Scale deployment
kubectl scale deployment ecommerce-backend-deployment --replicas=3 -n ecommerce

# Update resource limits
kubectl patch deployment ecommerce-backend-deployment -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"requests":{"memory":"512Mi","cpu":"200m"},"limits":{"memory":"1Gi","cpu":"500m"}}}]}}}}'
```

#### **Verification**
```bash
# Verify application recovery
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
curl -f http://ecommerce-backend-service:8080/health
```

**Expected Output**:
```
All pods Running
Services healthy
Health endpoints responding
```

---

## **⚠️ High Priority Issues (P1)**

### **Issue 3: Performance Degradation**

#### **Symptoms**
- High response times
- High resource utilization
- Slow deployments

#### **Root Cause Analysis**
```bash
# Check performance metrics
kubectl top nodes
kubectl top pods -n ecommerce
kubectl get hpa -n ecommerce

# Check resource utilization
kubectl describe nodes | grep -A 10 "Allocated resources"
```

#### **Common Causes**
1. **Resource Exhaustion**: CPU or memory limits reached
2. **Network Issues**: High latency or packet loss
3. **Storage Issues**: Slow disk I/O
4. **Application Issues**: Memory leaks or inefficient code

#### **Resolution Steps**

**Step 1: Check Resource Usage**
```bash
# Check node resources
kubectl top nodes --sort-by=cpu
kubectl top nodes --sort-by=memory

# Check pod resources
kubectl top pods -n ecommerce --sort-by=cpu
kubectl top pods -n ecommerce --sort-by=memory
```

**Action if Resource Exhaustion**:
```bash
# Scale cluster
kubectl get nodes
# Add new nodes to cluster

# Scale deployment
kubectl scale deployment ecommerce-backend-deployment --replicas=10 -n ecommerce
```

**Step 2: Check Network Performance**
```bash
# Check network policies
kubectl get networkpolicies -n ecommerce

# Check service endpoints
kubectl get endpoints -n ecommerce
kubectl describe service ecommerce-backend-service -n ecommerce
```

**Action if Network Issues**:
```bash
# Restart network plugin
kubectl delete pod -n kube-system -l app=calico

# Check network configuration
kubectl get configmap -n kube-system calico-config -o yaml
```

**Step 3: Check Storage Performance**
```bash
# Check storage classes
kubectl get storageclass

# Check persistent volumes
kubectl get pv
kubectl get pvc -n ecommerce
```

**Action if Storage Issues**:
```bash
# Check storage performance
kubectl exec -it ecommerce-backend-pod -n ecommerce -- df -h
kubectl exec -it ecommerce-backend-pod -n ecommerce -- iostat -x 1 5
```

#### **Verification**
```bash
# Verify performance improvement
kubectl top nodes
kubectl top pods -n ecommerce
curl -w "@curl-format.txt" -o /dev/null -s http://ecommerce-backend-service:8080/health
```

**Expected Output**:
```
Resource utilization normal
Response times improved
Performance metrics optimal
```

---

### **Issue 4: Configuration Issues**

#### **Symptoms**
- Application not starting
- Configuration errors in logs
- Environment variables not set

#### **Root Cause Analysis**
```bash
# Check configuration status
kubectl get configmaps -n ecommerce
kubectl get secrets -n ecommerce

# Check pod environment
kubectl exec -it ecommerce-backend-pod -n ecommerce -- env | grep DATABASE
```

#### **Common Causes**
1. **ConfigMap Missing**: Configuration not created
2. **Secret Missing**: Credentials not available
3. **Volume Mount Issues**: Configuration not mounted
4. **Environment Variable Issues**: Variables not set correctly

#### **Resolution Steps**

**Step 1: Check ConfigMap Status**
```bash
# Check ConfigMap exists
kubectl get configmap ecommerce-app-config -n ecommerce

# Check ConfigMap content
kubectl get configmap ecommerce-app-config -n ecommerce -o yaml
```

**Action if ConfigMap Missing**:
```bash
# Create ConfigMap
kubectl apply -f app-config.yaml

# Verify ConfigMap
kubectl get configmap ecommerce-app-config -n ecommerce -o yaml
```

**Step 2: Check Secret Status**
```bash
# Check Secret exists
kubectl get secret postgresql-secrets -n ecommerce

# Check Secret content
kubectl get secret postgresql-secrets -n ecommerce -o yaml
```

**Action if Secret Missing**:
```bash
# Create Secret
kubectl apply -f database-secrets.yaml

# Verify Secret
kubectl get secret postgresql-secrets -n ecommerce -o yaml
```

**Step 3: Check Volume Mounts**
```bash
# Check pod volume mounts
kubectl describe pod ecommerce-backend-pod -n ecommerce | grep -A 10 "Mounts"

# Check volume status
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes}{"\n"}{end}'
```

**Action if Volume Mount Issues**:
```bash
# Restart pod to remount volumes
kubectl delete pod ecommerce-backend-pod -n ecommerce

# Check pod recreation
kubectl get pods -n ecommerce
```

#### **Verification**
```bash
# Verify configuration access
kubectl exec -it ecommerce-backend-pod -n ecommerce -- cat /etc/app/config/database.host
kubectl exec -it ecommerce-backend-pod -n ecommerce -- env | grep DATABASE
```

**Expected Output**:
```
Configuration files accessible
Environment variables set correctly
Application starting successfully
```

---

## **🔍 Medium Priority Issues (P2)**

### **Issue 5: Deployment Issues**

#### **Symptoms**
- Deployments stuck in progress
- Rollouts not completing
- Pods not updating

#### **Root Cause Analysis**
```bash
# Check deployment status
kubectl get deployments -n ecommerce
kubectl rollout status deployment/ecommerce-backend-deployment -n ecommerce

# Check rollout history
kubectl rollout history deployment/ecommerce-backend-deployment -n ecommerce
```

#### **Common Causes**
1. **Image Pull Issues**: New image not available
2. **Health Check Failures**: Pods not passing health checks
3. **Resource Issues**: Insufficient resources for new pods
4. **Configuration Issues**: New configuration invalid

#### **Resolution Steps**

**Step 1: Check Image Availability**
```bash
# Check image tags
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].image}{"\n"}{end}'

# Check image pull status
kubectl describe pod ecommerce-backend-pod -n ecommerce | grep -A 10 "Events"
```

**Action if Image Issues**:
```bash
# Update image tag
kubectl set image deployment/ecommerce-backend-deployment \
  ecommerce-backend=ecommerce-backend:v1.0.0 -n ecommerce

# Check image registry
docker pull ecommerce-backend:v1.0.0
```

**Step 2: Check Health Checks**
```bash
# Check pod health
kubectl get pods -n ecommerce
kubectl describe pod ecommerce-backend-pod -n ecommerce

# Check health endpoints
kubectl exec -it ecommerce-backend-pod -n ecommerce -- curl -f http://localhost:8080/health
```

**Action if Health Check Issues**:
```bash
# Check health check configuration
kubectl get deployment ecommerce-backend-deployment -n ecommerce -o yaml | grep -A 10 "livenessProbe"

# Update health check configuration
kubectl patch deployment ecommerce-backend-deployment -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","livenessProbe":{"httpGet":{"path":"/health","port":8080},"initialDelaySeconds":60,"periodSeconds":10}}]}}}}'
```

**Step 3: Check Resources**
```bash
# Check resource usage
kubectl top pods -n ecommerce
kubectl describe nodes

# Check resource limits
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
```

**Action if Resource Issues**:
```bash
# Scale deployment
kubectl scale deployment ecommerce-backend-deployment --replicas=3 -n ecommerce

# Update resource limits
kubectl patch deployment ecommerce-backend-deployment -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"requests":{"memory":"512Mi","cpu":"200m"},"limits":{"memory":"1Gi","cpu":"500m"}}}]}}}}'
```

#### **Verification**
```bash
# Verify deployment completion
kubectl rollout status deployment/ecommerce-backend-deployment -n ecommerce
kubectl get pods -n ecommerce
```

**Expected Output**:
```
Deployment completed successfully
All pods updated
Rollout successful
```

---

### **Issue 6: Scaling Issues**

#### **Symptoms**
- HPA not scaling
- Pods not scaling up/down
- Resource utilization not optimal

#### **Root Cause Analysis**
```bash
# Check HPA status
kubectl get hpa -n ecommerce
kubectl describe hpa ecommerce-backend-hpa -n ecommerce

# Check metrics
kubectl top pods -n ecommerce
kubectl get pods -n ecommerce
```

#### **Common Causes**
1. **Metrics Issues**: Metrics not available
2. **HPA Configuration**: Incorrect HPA settings
3. **Resource Limits**: Pods at resource limits
4. **Scaling Policies**: Incorrect scaling policies

#### **Resolution Steps**

**Step 1: Check Metrics Availability**
```bash
# Check metrics server
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Check metrics API
kubectl top nodes
kubectl top pods -n ecommerce
```

**Action if Metrics Issues**:
```bash
# Restart metrics server
kubectl delete pod -n kube-system -l k8s-app=metrics-server

# Check metrics server logs
kubectl logs -n kube-system -l k8s-app=metrics-server --tail=100
```

**Step 2: Check HPA Configuration**
```bash
# Check HPA configuration
kubectl get hpa ecommerce-backend-hpa -n ecommerce -o yaml

# Check HPA events
kubectl describe hpa ecommerce-backend-hpa -n ecommerce
```

**Action if HPA Configuration Issues**:
```bash
# Update HPA configuration
kubectl patch hpa ecommerce-backend-hpa -n ecommerce -p '{"spec":{"minReplicas":3,"maxReplicas":20,"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":70}}}]}}'
```

**Step 3: Check Resource Limits**
```bash
# Check pod resource limits
kubectl get pods -n ecommerce -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'

# Check resource usage
kubectl top pods -n ecommerce
```

**Action if Resource Limit Issues**:
```bash
# Update resource limits
kubectl patch deployment ecommerce-backend-deployment -n ecommerce -p '{"spec":{"template":{"spec":{"containers":[{"name":"ecommerce-backend","resources":{"requests":{"memory":"256Mi","cpu":"100m"},"limits":{"memory":"512Mi","cpu":"500m"}}}]}}}}'
```

#### **Verification**
```bash
# Verify HPA scaling
kubectl get hpa -n ecommerce
kubectl get pods -n ecommerce
kubectl top pods -n ecommerce
```

**Expected Output**:
```
HPA scaling correctly
Pods scaling up/down
Resource utilization optimal
```

---

## **📊 Low Priority Issues (P3)**

### **Issue 7: Monitoring Issues**

#### **Symptoms**
- Metrics not collecting
- Dashboards not updating
- Alerts not firing

#### **Root Cause Analysis**
```bash
# Check monitoring stack
kubectl get pods -n monitoring
kubectl get services -n monitoring

# Check Prometheus targets
curl -s http://prometheus-service:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

#### **Common Causes**
1. **Prometheus Down**: Prometheus pod crashed
2. **Target Issues**: Monitoring targets not accessible
3. **Configuration Issues**: Prometheus configuration invalid
4. **Resource Issues**: Insufficient resources for monitoring

#### **Resolution Steps**

**Step 1: Check Prometheus Status**
```bash
# Check Prometheus pods
kubectl get pods -n monitoring -l app=prometheus

# Check Prometheus logs
kubectl logs -n monitoring -l app=prometheus --tail=100
```

**Action if Prometheus Down**:
```bash
# Restart Prometheus
kubectl delete pod -n monitoring -l app=prometheus

# Check Prometheus configuration
kubectl get configmap -n monitoring prometheus-config -o yaml
```

**Step 2: Check Target Status**
```bash
# Check Prometheus targets
curl -s http://prometheus-service:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'

# Check target configuration
kubectl get configmap -n monitoring prometheus-config -o yaml | grep -A 10 "scrape_configs"
```

**Action if Target Issues**:
```bash
# Check target accessibility
kubectl exec -it prometheus-pod -n monitoring -- curl -f http://ecommerce-backend-service:9090/metrics

# Update target configuration
kubectl apply -f prometheus-config.yaml
```

**Step 3: Check Resource Usage**
```bash
# Check monitoring resource usage
kubectl top pods -n monitoring
kubectl describe pods -n monitoring
```

**Action if Resource Issues**:
```bash
# Update resource limits
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"containers":[{"name":"prometheus","resources":{"requests":{"memory":"512Mi","cpu":"200m"},"limits":{"memory":"1Gi","cpu":"500m"}}}]}}}}'
```

#### **Verification**
```bash
# Verify monitoring recovery
kubectl get pods -n monitoring
curl -s http://prometheus-service:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

**Expected Output**:
```
Monitoring stack healthy
All targets up
Metrics collecting correctly
```

---

## **🔧 Diagnostic Commands**

### **Cluster Health Check**
```bash
# Complete cluster health check
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
kubectl cluster-info
kubectl top nodes
kubectl top pods --all-namespaces
```

### **Application Health Check**
```bash
# Application health check
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get deployments -n ecommerce
kubectl logs -l app=ecommerce-backend -n ecommerce --tail=100
curl -f http://ecommerce-backend-service:8080/health
```

### **Resource Usage Check**
```bash
# Resource usage check
kubectl top nodes
kubectl top pods -n ecommerce
kubectl describe nodes | grep -A 10 "Allocated resources"
kubectl get hpa -n ecommerce
```

### **Configuration Check**
```bash
# Configuration check
kubectl get configmaps -n ecommerce
kubectl get secrets -n ecommerce
kubectl exec -it ecommerce-backend-pod -n ecommerce -- env | grep DATABASE
kubectl describe pod ecommerce-backend-pod -n ecommerce
```

---

## **📞 Escalation Procedures**

### **Level 1: On-Call Engineer**
- **Response Time**: 15 minutes
- **Actions**: Basic troubleshooting, log analysis, service restart
- **Escalation**: If issue not resolved in 30 minutes

### **Level 2: Senior Engineer**
- **Response Time**: 30 minutes
- **Actions**: Advanced troubleshooting, configuration changes, cluster restart
- **Escalation**: If issue not resolved in 1 hour

### **Level 3: Technical Lead**
- **Response Time**: 1 hour
- **Actions**: Architecture changes, major configuration updates, vendor escalation
- **Escalation**: If issue not resolved in 2 hours

### **Level 4: Project Manager**
- **Response Time**: 2 hours
- **Actions**: Business impact assessment, stakeholder communication, vendor escalation
- **Escalation**: If issue not resolved in 4 hours

---

## **📋 Troubleshooting Checklist**

### **Before Escalation**
- [ ] Check cluster status
- [ ] Check application logs
- [ ] Check resource usage
- [ ] Check configuration
- [ ] Check network connectivity
- [ ] Check storage status
- [ ] Check monitoring status
- [ ] Check security policies

### **Documentation Required**
- [ ] Issue description
- [ ] Symptoms observed
- [ ] Steps taken
- [ ] Logs collected
- [ ] Configuration checked
- [ ] Impact assessment
- [ ] Resolution attempted

---

**Document Control**: This document is controlled and maintained by the Project Management Office. Any changes require approval from the Project Sponsor and Technical Lead.

**Last Updated**: December 2024  
**Next Review**: January 2025  
**Document Owner**: Senior Kubernetes Architect
