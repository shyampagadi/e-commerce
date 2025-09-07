# 📊 **Performance Benchmarking Tools**
## *E-commerce Foundation Infrastructure Project*

**Document Version**: 1.0  
**Date**: $(date)  
**Project**: E-commerce Foundation Infrastructure  
**Dependencies**: Technical Design Document v1.0, Deployment Guide v1.0  

---

## 🎯 **Overview**

This directory contains comprehensive performance benchmarking tools and configurations for the E-commerce Foundation Infrastructure project. The performance suite provides automated testing, monitoring, and reporting capabilities to ensure optimal system performance.

### **Performance Testing Components**
- **K6 Load Testing**: Comprehensive API and frontend performance testing
- **Apache Bench**: HTTP server performance benchmarking
- **Resource Monitoring**: CPU, memory, and network utilization tracking
- **Grafana Dashboard**: Real-time performance visualization
- **Automated Reporting**: Performance metrics analysis and recommendations

---

## 🚀 **Quick Start Guide**

### **Prerequisites**

| Component | Version | Installation |
|-----------|---------|--------------|
| **K6** | v0.47.0+ | `curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -L \| tar xvz --strip-components 1` |
| **Apache Bench** | 2.4+ | `sudo apt-get install apache2-utils` |
| **kubectl** | 1.28+ | Required for cluster access |
| **curl** | 7.0+ | Required for API testing |

### **Run Complete Benchmark Suite**
```bash
# =============================================================================
# COMPLETE PERFORMANCE BENCHMARK EXECUTION
# =============================================================================
# Purpose: Execute comprehensive performance testing suite
# Duration: 10-15 minutes depending on cluster performance
# Output: Detailed performance report and metrics
# =============================================================================

# Make script executable
chmod +x performance/benchmark.sh

# Run full benchmark suite
./performance/benchmark.sh

# Results will be saved to: ./performance-results/YYYYMMDD-HHMMSS/
# - K6 load test results (JSON format)
# - Apache Bench results (detailed logs)
# - Resource utilization logs
# - Comprehensive performance report
```

### **Run Individual Test Components**

#### **K6 Load Testing**
```bash
# =============================================================================
# K6 LOAD TESTING EXECUTION
# =============================================================================
# Purpose: Execute comprehensive load testing scenarios
# Test Scenarios: 7 different application workflows
# Duration: 14 minutes (2+5+2+5+2 minute stages)
# =============================================================================

# Install K6 (if not already installed)
curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -L | tar xvz --strip-components 1
sudo mv k6 /usr/local/bin/

# Execute K6 load test
k6 run performance/k6-load-test.js

# Execute with custom output format
k6 run --out json=results.json performance/k6-load-test.js
```

#### **Apache Bench HTTP Testing**
```bash
# =============================================================================
# APACHE BENCH HTTP PERFORMANCE TESTING
# =============================================================================
# Purpose: Test HTTP server performance and throughput
# Test Configuration: 1000 requests with 10 concurrent connections
# Metrics: Response time, throughput, error rates
# =============================================================================

# Install Apache Bench
sudo apt-get update && sudo apt-get install -y apache2-utils

# Test frontend performance
ab -n 1000 -c 10 http://localhost:8080/

# Test backend API performance
ab -n 1000 -c 10 http://localhost:8081/health

# Generate detailed report with timing data
ab -n 1000 -c 10 -g frontend-timing.tsv http://localhost:8080/
```

---

## 📋 **Test Scenarios & Configuration**

### **K6 Load Test Scenarios**

| Scenario | Purpose | Endpoint | Expected Response Time |
|----------|---------|----------|----------------------|
| **Homepage Load** | Test main landing page | `/` | < 200ms |
| **Product List API** | Test catalog performance | `/api/v1/products` | < 300ms |
| **Product Detail** | Test individual product retrieval | `/api/v1/products/{id}` | < 250ms |
| **User Registration** | Test signup performance | `/api/v1/auth/register` | < 400ms |
| **User Login** | Test authentication | `/api/v1/auth/login` | < 300ms |
| **Add to Cart** | Test cart functionality | `/api/v1/cart/items` | < 350ms |
| **Checkout Process** | Test order processing | `/api/v1/cart/summary` | < 200ms |

### **Load Test Configuration**
```javascript
// =============================================================================
// K6 LOAD TEST CONFIGURATION
// =============================================================================
// Purpose: Define load testing stages and thresholds
// Pattern: Gradual ramp-up, sustained load, ramp-down
// Thresholds: Performance and error rate limits
// =============================================================================

export let options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up to 10 virtual users
    { duration: '5m', target: 10 },   // Stay at 10 users for 5 minutes
    { duration: '2m', target: 20 },   // Ramp up to 20 virtual users
    { duration: '5m', target: 20 },   // Stay at 20 users for 5 minutes
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
    errors: ['rate<0.1'],             // Custom error rate below 10%
  },
};
```

---

## 📊 **Performance Metrics & Targets**

### **Response Time Targets**

| Service Tier | Endpoint Type | Target (95th percentile) | Critical Threshold |
|--------------|---------------|--------------------------|-------------------|
| **Frontend** | Static Pages | < 200ms | < 500ms |
| **Frontend** | Dynamic Content | < 300ms | < 800ms |
| **Backend API** | Product Queries | < 250ms | < 600ms |
| **Backend API** | User Operations | < 300ms | < 1000ms |
| **Backend API** | Cart Operations | < 350ms | < 1000ms |
| **Database** | Simple Queries | < 100ms | < 300ms |
| **Database** | Complex Queries | < 500ms | < 1500ms |

### **Throughput Targets**

| Service Component | Normal Load (RPS) | Peak Load (RPS) | Maximum Capacity |
|-------------------|-------------------|-----------------|------------------|
| **Frontend Server** | 100 RPS | 500 RPS | 1000 RPS |
| **Backend API** | 200 RPS | 1000 RPS | 2000 RPS |
| **Database Queries** | 150 RPS | 750 RPS | 1500 RPS |
| **Static Assets** | 500 RPS | 2000 RPS | 5000 RPS |

### **Resource Utilization Targets**

| Resource Type | Normal Usage | Warning Threshold | Critical Threshold |
|---------------|--------------|-------------------|-------------------|
| **CPU Usage** | < 70% | 70-85% | > 85% |
| **Memory Usage** | < 80% | 80-90% | > 90% |
| **Disk I/O** | < 70% | 70-85% | > 85% |
| **Network I/O** | < 60% | 60-80% | > 80% |

---

## 🔧 **Configuration Files**

### **K6 Test Script**
- **File**: `k6-load-test.js`
- **Purpose**: Comprehensive load testing scenarios with error tracking
- **Configuration**: Customizable stages, thresholds, and test scenarios
- **Output**: JSON results with detailed metrics and timing data

### **Benchmark Automation Script**
- **File**: `benchmark.sh`
- **Purpose**: Automated performance testing suite execution
- **Features**: Port forwarding management, multiple test tools, comprehensive reporting
- **Output**: Structured results directory with all test artifacts

### **Grafana Performance Dashboard**
- **File**: `grafana-performance-dashboard.json`
- **Purpose**: Real-time performance visualization and monitoring
- **Metrics**: Response times, throughput, error rates, resource utilization
- **Panels**: 6 comprehensive visualization panels

---

## 📈 **Performance Monitoring & Analysis**

### **Setup Grafana Dashboard**
```bash
# =============================================================================
# GRAFANA DASHBOARD IMPORT PROCEDURE
# =============================================================================
# Purpose: Import performance dashboard into Grafana
# Prerequisites: Grafana running and accessible
# Dashboard: Comprehensive performance metrics visualization
# =============================================================================

# Import dashboard to Grafana instance
curl -X POST \
  http://admin:admin@localhost:3000/api/dashboards/db \
  -H 'Content-Type: application/json' \
  -d @performance/grafana-performance-dashboard.json

# Verify dashboard import
curl -s http://admin:admin@localhost:3000/api/dashboards/uid/ecommerce-performance
```

### **Real-time Monitoring Commands**
```bash
# =============================================================================
# REAL-TIME MONITORING COMMANDS
# =============================================================================
# Purpose: Monitor system performance during testing
# Usage: Run in separate terminals during performance tests
# =============================================================================

# Monitor pod resource usage
watch kubectl top pods -n ecommerce

# Monitor node resource usage
watch kubectl top nodes

# Monitor service endpoint response times
watch curl -s -o /dev/null -w "%{http_code} %{time_total}s" http://localhost:8080

# Monitor application logs
kubectl logs -f deployment/ecommerce-backend -n ecommerce
```

---

## 📊 **Results Analysis & Reporting**

### **K6 Results Analysis**
```bash
# =============================================================================
# K6 RESULTS ANALYSIS COMMANDS
# =============================================================================
# Purpose: Analyze K6 test results and extract key metrics
# Input: K6 JSON output file
# Output: Formatted performance metrics
# =============================================================================

# Export summary results
k6 run --summary-export=summary.json performance/k6-load-test.js

# Analyze response time percentiles
jq '.metrics.http_req_duration.values' k6-results.json

# Extract error rates
jq '.metrics.http_req_failed.values' k6-results.json

# Generate custom report
jq '.metrics | to_entries | map({metric: .key, values: .value.values})' k6-results.json
```

### **Apache Bench Results Analysis**
```bash
# =============================================================================
# APACHE BENCH RESULTS ANALYSIS
# =============================================================================
# Purpose: Extract key performance metrics from Apache Bench output
# Metrics: RPS, response times, connection times, error rates
# =============================================================================

# Key metrics extraction from AB output:
grep "Requests per second" ab-results.log
grep "Time per request" ab-results.log
grep "Transfer rate" ab-results.log
grep "Failed requests" ab-results.log

# Connection time analysis
grep -A 5 "Connection Times" ab-results.log

# Response time distribution
grep -A 10 "Percentage of the requests served within" ab-results.log
```

---

## 🎯 **Performance Optimization Recommendations**

### **Application-Level Optimizations**

| Optimization Area | Recommendation | Expected Improvement |
|-------------------|----------------|---------------------|
| **Database Indexing** | Add indexes for frequently queried fields | 30-50% query performance |
| **Connection Pooling** | Optimize database connection pools | 20-30% throughput increase |
| **Caching Strategy** | Implement Redis for frequently accessed data | 40-60% response time reduction |
| **Resource Limits** | Adjust CPU/memory limits based on usage patterns | 15-25% resource efficiency |
| **Code Optimization** | Optimize slow API endpoints | 25-40% response time improvement |

### **Infrastructure-Level Optimizations**
```yaml
# =============================================================================
# KUBERNETES RESOURCE OPTIMIZATION EXAMPLE
# =============================================================================
# Purpose: Optimize resource allocation based on performance testing results
# Configuration: Adjusted based on actual usage patterns
# =============================================================================

# Optimized resource configuration
resources:
  requests:
    memory: "256Mi"    # Based on baseline memory usage
    cpu: "250m"        # Based on average CPU requirements
  limits:
    memory: "512Mi"    # 2x requests for burst capacity
    cpu: "500m"        # 2x requests for peak load handling

# Horizontal Pod Autoscaler configuration
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: ecommerce
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend
  minReplicas: 2          # Minimum for high availability
  maxReplicas: 10         # Maximum based on cluster capacity
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70    # Scale when CPU > 70%
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80    # Scale when memory > 80%
```

---

## 🔄 **Continuous Performance Testing**

### **CI/CD Integration Example**
```yaml
# =============================================================================
# CI/CD PIPELINE PERFORMANCE TESTING INTEGRATION
# =============================================================================
# Purpose: Integrate performance testing into deployment pipeline
# Trigger: After successful deployment to staging environment
# Action: Fail pipeline if performance thresholds are not met
# =============================================================================

performance-test:
  stage: test
  image: grafana/k6:latest
  script:
    - ./performance/benchmark.sh
    - k6 run --quiet performance/k6-load-test.js
  artifacts:
    reports:
      performance: performance-results/*/performance-report.md
    paths:
      - performance-results/
    expire_in: 1 week
  only:
    - main
    - staging
```

### **Scheduled Performance Testing**
```bash
# =============================================================================
# SCHEDULED PERFORMANCE TESTING CRON CONFIGURATION
# =============================================================================
# Purpose: Regular performance testing to detect performance regressions
# Schedule: Weekly performance testing during low-traffic periods
# Notification: Email results to development team
# =============================================================================

# Add to crontab for regular performance testing
# Weekly performance test on Monday at 2 AM
0 2 * * 1 /path/to/performance/benchmark.sh && mail -s "Weekly Performance Report" dev-team@company.com < performance-results/latest/performance-report.md
```

---

## 📞 **Support & Troubleshooting**

### **Common Issues & Solutions**

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Port forwarding fails** | Connection refused errors | Check if services are running: `kubectl get svc -n ecommerce` |
| **K6 not found** | Command not found error | Install K6 using provided installation commands |
| **High error rates** | > 10% failed requests | Check application logs and resource usage |
| **Slow response times** | Response times > thresholds | Analyze database queries and resource limits |
| **Resource exhaustion** | Pods being killed/restarted | Increase resource limits or scale horizontally |

### **Debug Commands**
```bash
# =============================================================================
# PERFORMANCE TROUBLESHOOTING COMMANDS
# =============================================================================
# Purpose: Diagnose performance issues and system bottlenecks
# Usage: Run when performance tests show degraded performance
# =============================================================================

# Check service status and health
kubectl get pods -n ecommerce -o wide
kubectl describe pods -n ecommerce

# View application logs for errors
kubectl logs -f deployment/ecommerce-backend -n ecommerce --tail=100

# Check resource usage and limits
kubectl top pods -n ecommerce
kubectl describe nodes

# Test individual service endpoints
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/health

# Check network connectivity
kubectl exec -it <pod-name> -n ecommerce -- ping ecommerce-database
```

### **Performance Tuning Checklist**
- [ ] Database queries optimized with proper indexes
- [ ] Connection pooling configured appropriately
- [ ] Resource limits set based on actual usage
- [ ] Horizontal Pod Autoscaler configured
- [ ] Caching strategy implemented
- [ ] Network policies not blocking required traffic
- [ ] Monitoring and alerting configured
- [ ] Regular performance testing scheduled

---

**Document Status**: Active  
**Last Updated**: $(date)  
**Next Review**: $(date -d '+1 month')  
**Maintainer**: Platform Engineering Team
