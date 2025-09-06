# 🎯 **Resource Management Practice Problems**
*Comprehensive hands-on exercises with expected results and implementation rationale*

## **Practice Problem 1: E-commerce Resource Optimization**

### **Problem Statement**
Your e-commerce platform's backend API is experiencing performance issues during peak traffic, while the database is over-provisioned and wasting resources. Implement comprehensive resource management to reduce costs by 30% while improving performance.

**Detailed Problem Analysis:**
The e-commerce platform faces common resource allocation challenges where different components have varying resource needs. The backend API requires guaranteed resources during peak shopping periods (Black Friday, holiday sales) to maintain sub-200ms response times, while the database is currently allocated 4 CPU cores and 8GB RAM but only uses 40% during normal operations. The frontend can burst during traffic spikes but doesn't need guaranteed resources. This scenario requires implementing QoS classes, resource quotas, and VPA for automated optimization.

### **Implementation Rationale**
Resource optimization requires understanding actual usage patterns versus allocated resources. The backend API needs Guaranteed QoS to ensure consistent performance during peak loads, while the database can be right-sized based on historical usage patterns. The frontend can use Burstable QoS to handle traffic spikes efficiently. This involves analyzing metrics, setting appropriate requests/limits, implementing VPA for automated recommendations, and establishing resource quotas to prevent resource exhaustion. The goal is to reduce costs while maintaining or improving performance through intelligent resource allocation.

### **Step-by-Step Implementation**

#### **Step 1: Analyze Current Resource Usage**
```bash
# Check current resource usage across the cluster
kubectl top nodes
kubectl top pods -n ecommerce-prod --containers
```

**Expected Results:**
```
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
worker-node-1  2456m        61%    7892Mi          49%
worker-node-2  1834m        45%    6234Mi          39%
worker-node-3  3012m        75%    9456Mi          59%

NAME                              CPU(cores)   MEMORY(bytes)
ecommerce-backend-7d4b8c8f9d-abc12   450m         1200Mi
ecommerce-backend-7d4b8c8f9d-def34   380m         1100Mi
ecommerce-frontend-6b9c7d8e9f-ghi56  120m         300Mi
ecommerce-database-0                 1200m        3200Mi
```

**Detailed Explanation of Expected Results:**
This output shows current resource consumption across nodes and pods. The backend pods are consuming 380-450m CPU (close to their 500m limit) and 1100-1200Mi memory, indicating they're properly sized but may need guaranteed resources. The database is using 1200m CPU and 3200Mi memory, suggesting it's over-provisioned if allocated 4000m CPU and 8Gi memory. The frontend shows low usage (120m CPU, 300Mi memory) with potential for bursting during traffic spikes.

#### **Step 2: Implement Resource Quotas**
```bash
# Apply resource quota for production namespace
kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ecommerce-prod-quota
  namespace: ecommerce-prod
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
    pods: "50"
EOF
```

**Expected Results:**
```
resourcequota/ecommerce-prod-quota created
```

**Detailed Explanation of Expected Results:**
The ResourceQuota creation confirms that namespace-level resource limits are now enforced. This quota allows up to 10 CPU cores in requests (ensuring schedulability) and 20 CPU cores in limits (allowing bursting), with 20Gi memory requests and 40Gi memory limits. The quota prevents resource exhaustion and provides cost control by limiting total resource allocation within the namespace.

#### **Step 3: Configure Backend with Guaranteed QoS**
```bash
# Update backend deployment with guaranteed resources
kubectl patch deployment ecommerce-backend -n ecommerce-prod --patch '
spec:
  template:
    spec:
      containers:
      - name: fastapi-backend
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 500m
            memory: 1Gi
'
```

**Expected Results:**
```
deployment.apps/ecommerce-backend patched
```

#### **Step 4: Verify QoS Class Assignment**
```bash
# Check QoS class for backend pods
kubectl get pods -n ecommerce-prod -l app=backend -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

**Expected Results:**
```
NAME                                QOS
ecommerce-backend-7d4b8c8f9d-abc12  Guaranteed
ecommerce-backend-7d4b8c8f9d-def34  Guaranteed
```

**Detailed Explanation of Expected Results:**
The "Guaranteed" QoS class confirms that requests equal limits for both CPU and memory. This ensures the backend pods receive dedicated resources and are the last to be evicted during resource pressure, providing consistent performance during peak traffic periods.

### **Alternative Approaches**

#### **Approach 1: Vertical Pod Autoscaler (VPA)**
```bash
# Install VPA for automated resource recommendations
kubectl apply -f - <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: backend-vpa
  namespace: ecommerce-prod
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: fastapi-backend
      minAllowed:
        cpu: 100m
        memory: 256Mi
      maxAllowed:
        cpu: 2000m
        memory: 4Gi
EOF
```

**Benefits**: Automated optimization, adapts to usage patterns, reduces manual effort
**Drawbacks**: May cause pod restarts, requires careful tuning, potential over-optimization

#### **Approach 2: Horizontal Pod Autoscaler (HPA) with Custom Metrics**
```bash
# Configure HPA based on custom application metrics
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: ecommerce-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
EOF
```

**Benefits**: Scales based on actual demand, handles traffic spikes automatically
**Drawbacks**: Requires metrics infrastructure, scaling delays, potential cost increases

### **Risk Assessment**

| Risk Level | Risk Factor | Mitigation Strategy |
|------------|-------------|-------------------|
| **High** | Resource starvation during traffic spikes | Implement HPA with appropriate metrics and buffer resources |
| **Medium** | VPA causing excessive pod restarts | Use "Off" mode initially, gradual rollout with monitoring |
| **Low** | Cost optimization reducing performance | Comprehensive testing in staging, gradual implementation |

---

## **Practice Problem 2: Database Right-Sizing and Cost Optimization**

### **Problem Statement**
The PostgreSQL database is over-provisioned with 4 CPU cores and 8GB RAM but only uses 40% during normal operations. Implement right-sizing while ensuring performance during peak loads.

**Detailed Problem Analysis:**
Database right-sizing requires careful analysis of usage patterns, query performance, and peak load requirements. The current allocation of 4000m CPU and 8Gi memory with only 40% utilization (1600m CPU, 3.2Gi memory) suggests significant over-provisioning. However, databases require careful handling as under-provisioning can severely impact application performance. The solution involves analyzing historical usage, implementing monitoring, and gradually reducing resources while maintaining performance SLAs.

### **Implementation Rationale**
Database optimization requires balancing cost reduction with performance guarantees. PostgreSQL performance depends on available memory for caching and CPU for query processing. The approach involves implementing comprehensive monitoring, analyzing query performance metrics, setting up alerts for resource pressure, and gradually reducing allocated resources while monitoring performance indicators. VPA can provide recommendations, but database changes should be implemented cautiously with thorough testing.

### **Step-by-Step Implementation**

#### **Step 1: Analyze Database Performance Metrics**
```bash
# Check database resource usage over time
kubectl exec -n ecommerce-prod ecommerce-database-0 -- psql -U postgres -d ecommerce -c "
SELECT 
  datname,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  temp_files,
  temp_bytes
FROM pg_stat_database 
WHERE datname = 'ecommerce';"
```

**Expected Results:**
```
 datname   | numbackends | xact_commit | xact_rollback | blks_read | blks_hit  | temp_files | temp_bytes 
-----------+-------------+-------------+---------------+-----------+-----------+------------+------------
 ecommerce |           5 |      156789 |           234 |    45678  |  2345678  |         12 |    1048576
```

**Detailed Explanation of Expected Results:**
This PostgreSQL statistics output shows database activity metrics. The high blks_hit to blks_read ratio (2345678:45678 ≈ 51:1) indicates good buffer cache efficiency, suggesting memory is being used effectively. The low temp_files and temp_bytes indicate queries aren't spilling to disk frequently, which means current memory allocation might be sufficient for workload requirements.

#### **Step 2: Implement Database Resource Monitoring**
```bash
# Deploy PostgreSQL Exporter for detailed metrics
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-exporter
  namespace: ecommerce-prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-exporter
  template:
    metadata:
      labels:
        app: postgres-exporter
    spec:
      containers:
      - name: postgres-exporter
        image: prometheuscommunity/postgres-exporter:latest
        ports:
        - containerPort: 9187
        env:
        - name: DATA_SOURCE_NAME
          value: "postgresql://postgres:password@ecommerce-database:5432/ecommerce?sslmode=disable"
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi
EOF
```

**Expected Results:**
```
deployment.apps/postgres-exporter created
```

#### **Step 3: Right-Size Database Resources**
```bash
# Update database StatefulSet with optimized resources
kubectl patch statefulset ecommerce-database -n ecommerce-prod --patch '
spec:
  template:
    spec:
      containers:
      - name: postgresql
        resources:
          requests:
            cpu: 1000m
            memory: 4Gi
          limits:
            cpu: 2000m
            memory: 6Gi
'
```

**Expected Results:**
```
statefulset.apps/ecommerce-database patched
```

#### **Step 4: Monitor Performance After Right-Sizing**
```bash
# Check database performance metrics after optimization
kubectl exec -n ecommerce-prod ecommerce-database-0 -- psql -U postgres -d ecommerce -c "
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  rows
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 5;"
```

**Expected Results:**
```
                    query                     | calls | total_time | mean_time | rows 
----------------------------------------------+-------+------------+-----------+------
 SELECT * FROM products WHERE category_id = ? |  1234 |   45678.90 |     37.01 | 5678
 UPDATE cart_items SET quantity = ? WHERE ... |   567 |   23456.78 |     41.38 |  567
 INSERT INTO orders (user_id, total, ...) ... |   234 |   12345.67 |     52.76 |  234
```

**Detailed Explanation of Expected Results:**
The pg_stat_statements output shows query performance after right-sizing. Mean execution times under 60ms for common queries indicate good performance is maintained. If mean_time values increase significantly compared to baseline measurements, it may indicate resource constraints requiring adjustment.

### **Alternative Approaches**

#### **Approach 1: Connection Pooling Optimization**
```bash
# Deploy PgBouncer for connection pooling
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgbouncer
  namespace: ecommerce-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pgbouncer
  template:
    metadata:
      labels:
        app: pgbouncer
    spec:
      containers:
      - name: pgbouncer
        image: pgbouncer/pgbouncer:latest
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF
```

**Benefits**: Reduces database connection overhead, improves resource efficiency
**Drawbacks**: Additional complexity, potential single point of failure

### **Risk Assessment**

| Risk Level | Risk Factor | Mitigation Strategy |
|------------|-------------|-------------------|
| **High** | Database performance degradation | Gradual resource reduction with continuous monitoring |
| **Medium** | Query timeout during peak loads | Implement query performance monitoring and alerts |
| **Low** | Connection pool exhaustion | Configure appropriate pool sizes and monitoring |

---

## **Practice Problem 3: Implementing Cost Monitoring with Kubecost**

### **Problem Statement**
Implement comprehensive cost monitoring and optimization recommendations for the e-commerce platform using Kubecost to track spending by team, application, and environment.

**Detailed Problem Analysis:**
Cost visibility is crucial for optimizing cloud spending and making informed resource allocation decisions. The e-commerce platform spans multiple teams (engineering, marketing, operations) with different cost centers and budget requirements. Without proper cost attribution and monitoring, it's impossible to identify optimization opportunities or enforce budget controls. The solution involves deploying Kubecost for cost allocation, setting up budget alerts, and implementing cost optimization recommendations.

### **Implementation Rationale**
Kubecost provides detailed cost allocation and optimization recommendations by analyzing actual resource usage and cloud provider pricing. It enables cost attribution by namespace, deployment, service, and custom labels, allowing teams to understand their spending patterns. The implementation involves deploying Kubecost with Prometheus integration, configuring cost allocation rules, setting up budget alerts, and establishing regular cost optimization reviews. This enables data-driven decisions for resource optimization and budget management.

### **Step-by-Step Implementation**

#### **Step 1: Deploy Kubecost**
```bash
# Add Kubecost Helm repository
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
```

**Expected Results:**
```
"kubecost" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubecost" chart repository
Update Complete. ⎈Happy Helming!⎈
```

#### **Step 2: Install Kubecost with Custom Configuration**
```bash
# Install Kubecost with production configuration
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --create-namespace \
  --set prometheus.server.persistentVolume.size=32Gi \
  --set prometheus.server.retention=30d \
  --set kubecostToken="your-kubecost-token"
```

**Expected Results:**
```
NAME: kubecost
LAST DEPLOYED: Thu Sep  5 12:00:00 2024
NAMESPACE: kubecost
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
--------------------------------------------------Kubecost has been successfully installed!

When pods are Ready, you can enable port-forwarding with the following command:

    kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090

Next, navigate to http://localhost:9090 in a web browser.
```

#### **Step 3: Configure Cost Allocation Labels**
```bash
# Apply cost center labels to existing deployments
kubectl label deployment ecommerce-backend -n ecommerce-prod cost-center=engineering
kubectl label deployment ecommerce-frontend -n ecommerce-prod cost-center=marketing
kubectl label statefulset ecommerce-database -n ecommerce-prod cost-center=infrastructure
```

**Expected Results:**
```
deployment.apps/ecommerce-backend labeled
deployment.apps/ecommerce-frontend labeled
statefulset.apps/ecommerce-database labeled
```

#### **Step 4: Access Kubecost Dashboard**
```bash
# Port forward to access Kubecost UI
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090:9090
```

**Expected Results:**
```
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
```

**Detailed Explanation of Expected Results:**
The port-forward command creates a local tunnel to the Kubecost dashboard. Accessing http://localhost:9090 will show the Kubecost interface with cost allocation data, including breakdown by namespace, deployment, and cost-center labels. The dashboard provides real-time cost monitoring, historical trends, and optimization recommendations.

#### **Step 5: Query Cost Allocation API**
```bash
# Get cost allocation data via API
curl -s "http://localhost:9090/model/allocation" \
  -d window=7d \
  -d aggregate=deployment \
  -d accumulate=false \
  -G | jq '.data[] | {name: .name, totalCost: .totalCost, cpuCost: .cpuCost, ramCost: .ramCost}'
```

**Expected Results:**
```json
{
  "name": "ecommerce-backend",
  "totalCost": 45.67,
  "cpuCost": 28.34,
  "ramCost": 17.33
}
{
  "name": "ecommerce-frontend", 
  "totalCost": 12.45,
  "cpuCost": 7.89,
  "ramCost": 4.56
}
{
  "name": "ecommerce-database",
  "totalCost": 89.23,
  "cpuCost": 34.56,
  "ramCost": 54.67
}
```

**Detailed Explanation of Expected Results:**
This JSON output shows 7-day cost allocation by deployment. The backend costs $45.67 with CPU representing 62% of costs, the frontend costs $12.45 (lowest cost due to efficient resource usage), and the database costs $89.23 with memory representing 61% of costs (indicating potential for memory optimization). These metrics enable data-driven optimization decisions.

### **Alternative Approaches**

#### **Approach 1: Cloud Provider Native Cost Tools**
```bash
# Configure AWS Cost Explorer integration
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: aws-cost-credentials
  namespace: kubecost
type: Opaque
data:
  aws-access-key-id: $(echo -n "YOUR_ACCESS_KEY" | base64)
  aws-secret-access-key: $(echo -n "YOUR_SECRET_KEY" | base64)
EOF
```

**Benefits**: Native cloud integration, detailed billing data, no additional infrastructure
**Drawbacks**: Cloud-specific, limited Kubernetes context, delayed data availability

### **Risk Assessment**

| Risk Level | Risk Factor | Mitigation Strategy |
|------------|-------------|-------------------|
| **High** | Cost data accuracy issues | Regular validation against cloud provider bills |
| **Medium** | Budget alert fatigue | Implement tiered alerting with appropriate thresholds |
| **Low** | Dashboard performance with large datasets | Implement data retention policies and aggregation |

---

## **Summary and Best Practices**

### **Key Takeaways**
1. **Resource Requests vs Limits**: Understand the difference and impact on QoS classes
2. **Gradual Optimization**: Implement changes incrementally with monitoring
3. **Cost Visibility**: Implement comprehensive cost tracking and attribution
4. **Automated Optimization**: Use VPA and HPA for dynamic resource management
5. **Performance Monitoring**: Maintain application performance during optimization

### **Production Readiness Checklist**
- [ ] Resource quotas implemented for all namespaces
- [ ] LimitRanges configured with appropriate defaults
- [ ] QoS classes properly assigned based on workload requirements
- [ ] VPA deployed for automated resource recommendations
- [ ] Cost monitoring and alerting configured
- [ ] Performance baselines established and monitored
- [ ] Resource optimization procedures documented and tested
