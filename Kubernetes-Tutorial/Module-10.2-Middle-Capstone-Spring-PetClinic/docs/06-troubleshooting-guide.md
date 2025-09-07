# 🔧 **Troubleshooting Guide**
## *Spring PetClinic Microservices Platform*

**Document Version**: 1.0.0  
**Date**: December 2024  

---

## 🚨 **Common Issues**

### **Pods Not Starting**
**Symptoms**: Pods stuck in Pending/CrashLoopBackOff
**Diagnosis**:
```bash
kubectl describe pod <pod-name> -n petclinic
kubectl logs <pod-name> -n petclinic --previous
```
**Solutions**:
- Check resource limits and requests
- Verify image availability
- Check secrets and configmaps

### **Service Discovery Issues**
**Symptoms**: Services not registering with Eureka
**Diagnosis**:
```bash
kubectl port-forward -n petclinic svc/discovery-server 8761:8761
curl http://localhost:8761/eureka/apps
```
**Solutions**:
- Restart discovery server
- Check service configurations
- Verify network connectivity

### **Database Connection Issues**
**Symptoms**: Services can't connect to MySQL
**Diagnosis**:
```bash
kubectl exec -it -n petclinic mysql-customers-0 -- mysql -u root -p
kubectl get secrets mysql-credentials -n petclinic -o yaml
```
**Solutions**:
- Verify database credentials
- Check database pod status
- Test network connectivity

### **Performance Issues**
**Symptoms**: Slow response times
**Diagnosis**:
```bash
kubectl top pods -n petclinic
kubectl top nodes
```
**Solutions**:
- Scale services horizontally
- Optimize JVM settings
- Check resource allocation
