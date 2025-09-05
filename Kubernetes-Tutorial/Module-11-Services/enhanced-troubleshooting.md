# Enhanced E-commerce Troubleshooting Scenarios for Module 11

## 🔧 **Enhanced E-commerce Troubleshooting Scenarios**

### **Troubleshooting Scenario 1: Payment Service Connection Failures**

#### **Business Impact**
During Black Friday sales, customers report payment failures with error "Payment service unavailable". Revenue loss: $50,000/hour.

#### **E-commerce Debugging Commands**
```bash
# Check payment service status and endpoints
kubectl get service ecommerce-payment-service -n ecommerce-prod -o wide
kubectl get endpoints ecommerce-payment-service -n ecommerce-prod

# Test service connectivity from order service
kubectl exec -it deployment/ecommerce-order-service -n ecommerce-prod -- curl -v http://ecommerce-payment-service:80/health

# Check service selector matching
kubectl get service ecommerce-payment-service -n ecommerce-prod -o jsonpath='{.spec.selector}'
kubectl get pods -l app=ecommerce-payment -n ecommerce-prod --show-labels

# Verify DNS resolution
kubectl exec -it deployment/ecommerce-order-service -n ecommerce-prod -- nslookup ecommerce-payment-service

# Check kube-proxy logs for service routing issues
kubectl logs -n kube-system -l k8s-app=kube-proxy | grep payment
```

### **Troubleshooting Scenario 2: Inventory Service Load Balancing Issues**

#### **Business Impact**
Product stock levels showing inconsistently across the website. Some customers see "out of stock" while others can purchase the same item.

#### **E-commerce Debugging Process**
```bash
# Check inventory service load balancing configuration
kubectl get service ecommerce-inventory-service -n ecommerce-prod -o jsonpath='{.spec.sessionAffinity}'

# Test load distribution across pods
for i in {1..20}; do 
  kubectl exec -it deployment/ecommerce-frontend -n ecommerce-prod -- curl -s http://ecommerce-inventory-service/api/v1/products/12345/stock | jq '.pod_name'
done | sort | uniq -c

# Verify database connectivity from all inventory pods
kubectl get pods -l app=ecommerce-inventory -n ecommerce-prod -o name | xargs -I {} kubectl exec {} -n ecommerce-prod -- pg_isready -h ecommerce-inventory-db -p 5432

# Check inventory pod synchronization
kubectl exec -it <inventory-pod-1> -n ecommerce-prod -- curl localhost:8080/api/v1/products/12345/stock
kubectl exec -it <inventory-pod-2> -n ecommerce-prod -- curl localhost:8080/api/v1/products/12345/stock
```

### **E-commerce Service Monitoring Commands**

#### **Payment Service Monitoring**
```bash
# Monitor payment transaction metrics
kubectl exec -it deployment/ecommerce-payment-service -n ecommerce-prod -- curl -s http://localhost:8080/metrics | grep payment_transactions_total

# Check payment service error rates
kubectl logs -f deployment/ecommerce-payment-service -n ecommerce-prod | grep -E "(ERROR|FAILED|TIMEOUT)" | tail -20

# Monitor payment service response times
kubectl exec -it deployment/ecommerce-payment-service -n ecommerce-prod -- curl -s http://localhost:8080/metrics | grep payment_response_time

# Check payment service database connections
kubectl exec -it deployment/ecommerce-payment-service -n ecommerce-prod -- netstat -an | grep :5432 | wc -l
```

#### **Inventory Service Monitoring**
```bash
# Monitor inventory stock levels
kubectl exec -it deployment/ecommerce-inventory-service -n ecommerce-prod -- curl -s http://localhost:8080/api/v1/inventory/summary

# Check inventory service cache hit rates
kubectl exec -it deployment/ecommerce-inventory-service -n ecommerce-prod -- curl -s http://localhost:8080/metrics | grep cache_hit_rate

# Monitor inventory update frequency
kubectl logs -f deployment/ecommerce-inventory-service -n ecommerce-prod | grep "inventory_updated" | tail -10

# Check inventory service load balancing
kubectl get endpoints ecommerce-inventory-service -n ecommerce-prod -o jsonpath='{.subsets[0].addresses[*].ip}' | tr ' ' '\n' | wc -l
```

## Enhanced E-commerce Labs

### **Lab 1: E-commerce Payment Service Setup**

#### **Business Scenario**
You're setting up a secure payment processing service for the e-commerce platform that requires:
- **PCI DSS Compliance**: Strict security requirements
- **High Availability**: 99.99% uptime for payment processing
- **Load Balancing**: Handle payment spikes during sales events
- **Service Discovery**: Integration with order and inventory services

#### **E-commerce-Specific Requirements**
```yaml
# Payment Service with Security Annotations
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-payment-service
  namespace: ecommerce-prod
  labels:
    app: ecommerce-payment
    tier: backend
    security-level: high
    compliance: pci-dss
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "https"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
spec:
  type: ClusterIP
  selector:
    app: ecommerce-payment
    tier: backend
  ports:
  - name: https
    port: 443
    targetPort: 8443
    protocol: TCP
  - name: metrics
    port: 8080
    targetPort: 8080
    protocol: TCP
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

#### **E-commerce kubectl Commands**
```bash
# Create payment service with security context
kubectl apply -f payment-service.yaml -n ecommerce-prod

# Verify payment service endpoints
kubectl get endpoints ecommerce-payment-service -n ecommerce-prod -o wide

# Check payment service security annotations
kubectl describe service ecommerce-payment-service -n ecommerce-prod | grep -A 10 "Annotations"

# Test payment service connectivity from order service
kubectl exec -it deployment/ecommerce-order-service -n ecommerce-prod -- curl -k https://ecommerce-payment-service:443/health

# Monitor payment service metrics
kubectl port-forward service/ecommerce-payment-service 8080:8080 -n ecommerce-prod &
curl http://localhost:8080/metrics | grep payment_

# Check payment service session affinity
kubectl get service ecommerce-payment-service -n ecommerce-prod -o jsonpath='{.spec.sessionAffinity}'
```
