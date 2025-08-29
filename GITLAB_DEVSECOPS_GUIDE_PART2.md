# 🚀 GitLab CI/CD DevSecOps Implementation Guide - Part 2

## 🔐 Security Integration (DevSecOps)

### **Security Tools Configuration**

#### **SonarQube Integration**
```yaml
# sonar-project.properties
sonar.projectKey=ecommerce-app
sonar.projectName=E-Commerce Application
sonar.projectVersion=1.0
sonar.sources=.
sonar.exclusions=**/node_modules/**,**/venv/**,**/*.test.js,**/*.spec.js
sonar.coverage.exclusions=**/tests/**,**/test/**
sonar.javascript.lcov.reportPaths=frontend/coverage/lcov.info
sonar.python.coverage.reportPaths=backend/coverage.xml
sonar.qualitygate.wait=true
```

#### **OWASP ZAP Configuration**
```yaml
# .zap/zap-baseline.conf
# ZAP Baseline Configuration
-config globalexcludeurl.url_list.url(0).regex=.*logout.*
-config globalexcludeurl.url_list.url(1).regex=.*\.js$
-config globalexcludeurl.url_list.url(2).regex=.*\.css$
-config spider.maxDuration=10
-config spider.maxDepth=5
```

#### **Trivy Configuration**
```yaml
# .trivyignore
# Ignore specific vulnerabilities
CVE-2021-44228  # Log4j (if not applicable)
CVE-2022-12345  # Example ignored CVE

# trivy.yaml
format: json
exit-code: 1
severity: HIGH,CRITICAL
ignore-unfixed: true
```

### **Security Policies**

#### **Branch Protection Rules**
```yaml
# GitLab Push Rules (Premium feature)
push_rules:
  commit_message_regex: "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}"
  deny_delete_tag: true
  member_check: true
  prevent_secrets: true
  author_email_regex: "@company\.com$"
  file_name_regex: "^[a-zA-Z0-9._/-]+$"
  max_file_size: 50  # MB
```

#### **Security Scanning Rules**
```yaml
# Security scanning configuration
security_scanning:
  sast:
    enabled: true
    rules:
      - if: $CI_COMMIT_BRANCH == "main"
      - if: $CI_MERGE_REQUEST_ID
  dependency_scanning:
    enabled: true
    rules:
      - if: $CI_COMMIT_BRANCH == "main"
      - if: $CI_MERGE_REQUEST_ID
  container_scanning:
    enabled: true
    rules:
      - if: $CI_COMMIT_BRANCH == "main"
  dast:
    enabled: true
    rules:
      - if: $CI_COMMIT_BRANCH == "main"
        when: manual
```

---

## 🏗️ Infrastructure as Code

### **Terraform Configuration**

#### **Main Infrastructure (terraform/main.tf)**
```hcl
# Provider configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
  
  backend "s3" {
    bucket = "ecommerce-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}

# VPC Configuration
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "ecommerce-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = true
  
  tags = {
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "ecommerce-${var.environment}"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  node_groups = {
    main = {
      desired_capacity = 3
      max_capacity     = 10
      min_capacity     = 1
      
      instance_types = ["t3.medium"]
      
      k8s_labels = {
        Environment = var.environment
        Application = "ecommerce"
      }
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# RDS Database
resource "aws_db_instance" "main" {
  identifier = "ecommerce-${var.environment}"
  
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  db_name  = "ecommerce"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = var.environment != "production"
  
  tags = {
    Environment = var.environment
    Project     = "ecommerce"
  }
}
```

#### **Kubernetes Manifests**

**Namespace Configuration (k8s/namespace.yml)**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-prod
  labels:
    name: ecommerce-prod
    environment: production
---
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-staging
  labels:
    name: ecommerce-staging
    environment: staging
```

**Application Deployment (k8s/deployment.yml)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: ecommerce-prod
  labels:
    app: backend
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
      - name: backend
        image: registry.gitlab.com/your-org/ecommerce/backend:IMAGE_TAG
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: secret-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: ecommerce-prod
  labels:
    app: frontend
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        version: v1
    spec:
      containers:
      - name: frontend
        image: registry.gitlab.com/your-org/ecommerce/frontend:IMAGE_TAG
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        securityContext:
          runAsNonRoot: true
          runAsUser: 1000
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
```

---

## 📊 Monitoring & Observability

### **Prometheus Configuration**
```yaml
# monitoring/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - ecommerce-prod
            - ecommerce-staging
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: backend
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

  - job_name: 'frontend'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - ecommerce-prod
            - ecommerce-staging
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: frontend

  - job_name: 'node-exporter'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
```

### **Alert Rules**
```yaml
# monitoring/prometheus/alert_rules.yml
groups:
  - name: ecommerce.rules
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      - alert: DatabaseConnectionFailure
        expr: up{job="postgres"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection failure"
          description: "PostgreSQL database is down"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is crash looping"
```

### **Grafana Dashboards**
```json
{
  "dashboard": {
    "title": "E-Commerce Application Dashboard",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{ method }} {{ status }}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "Error Rate"
          }
        ]
      }
    ]
  }
}
```

---

## 🚀 Deployment Strategies

### **Blue-Green Deployment**
```bash
#!/bin/bash
# Blue-Green deployment script

NAMESPACE="ecommerce-prod"
NEW_VERSION=$1
CURRENT_COLOR=$(kubectl get service frontend -n $NAMESPACE -o jsonpath='{.spec.selector.color}' || echo "blue")
NEW_COLOR=$([ "$CURRENT_COLOR" = "blue" ] && echo "green" || echo "blue")

echo "Deploying version $NEW_VERSION to $NEW_COLOR environment"

# Deploy new version
kubectl set image deployment/backend-$NEW_COLOR backend=registry.gitlab.com/your-org/ecommerce/backend:$NEW_VERSION -n $NAMESPACE
kubectl set image deployment/frontend-$NEW_COLOR frontend=registry.gitlab.com/your-org/ecommerce/frontend:$NEW_VERSION -n $NAMESPACE

# Wait for deployment
kubectl rollout status deployment/backend-$NEW_COLOR -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/frontend-$NEW_COLOR -n $NAMESPACE --timeout=300s

# Health check
kubectl exec -n $NAMESPACE deployment/backend-$NEW_COLOR -- curl -f http://localhost:8000/health

# Switch traffic
kubectl patch service backend -n $NAMESPACE -p '{"spec":{"selector":{"color":"'$NEW_COLOR'"}}}'
kubectl patch service frontend -n $NAMESPACE -p '{"spec":{"selector":{"color":"'$NEW_COLOR'"}}}'

echo "Traffic switched to $NEW_COLOR environment"
```

### **Canary Deployment with Istio**
```yaml
# k8s/canary/virtual-service.yml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-canary
  namespace: ecommerce-prod
spec:
  hosts:
  - ecommerce.example.com
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: frontend
        subset: canary
  - route:
    - destination:
        host: frontend
        subset: stable
      weight: 90
    - destination:
        host: frontend
        subset: canary
      weight: 10
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: frontend-destination
  namespace: ecommerce-prod
spec:
  host: frontend
  subsets:
  - name: stable
    labels:
      version: stable
  - name: canary
    labels:
      version: canary
```

---

## 📋 Best Practices & Troubleshooting

### **Security Best Practices**

#### **Container Security**
```dockerfile
# Security-hardened Dockerfile practices
FROM node:18-alpine as base

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Use specific versions
RUN apk add --no-cache \
    dumb-init=1.2.5-r1 \
    curl=7.80.0-r4

# Set security headers
COPY --chown=nextjs:nodejs . .
USER nextjs

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
```

#### **Kubernetes Security**
```yaml
# Security contexts and policies
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### **Performance Optimization**

#### **Database Optimization**
```sql
-- Database performance tuning
CREATE INDEX CONCURRENTLY idx_products_category_active 
ON products(category_id, is_active) 
WHERE is_active = true;

CREATE INDEX CONCURRENTLY idx_orders_user_created 
ON orders(user_id, created_at DESC);

-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM products 
WHERE category_id = 1 AND is_active = true 
ORDER BY created_at DESC LIMIT 20;
```

#### **Caching Strategy**
```python
# Redis caching implementation
import redis
from functools import wraps

redis_client = redis.Redis(host='redis', port=6379, db=0)

def cache_result(expiration=300):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache_key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
            
            # Try to get from cache
            cached_result = redis_client.get(cache_key)
            if cached_result:
                return json.loads(cached_result)
            
            # Execute function and cache result
            result = await func(*args, **kwargs)
            redis_client.setex(cache_key, expiration, json.dumps(result))
            return result
        return wrapper
    return decorator
```

### **Troubleshooting Guide**

#### **Common Pipeline Issues**

**1. Build Failures**
```bash
# Debug build issues
docker build --no-cache -f Dockerfile.backend .
docker run -it --rm <image-id> /bin/bash

# Check logs
kubectl logs -f deployment/backend -n ecommerce-prod
```

**2. Test Failures**
```bash
# Run tests locally
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
docker-compose -f docker-compose.test.yml logs backend

# Debug E2E tests
npx playwright test --debug
npx playwright show-report
```

**3. Deployment Issues**
```bash
# Check deployment status
kubectl get pods -n ecommerce-prod
kubectl describe pod <pod-name> -n ecommerce-prod
kubectl logs <pod-name> -n ecommerce-prod

# Check service connectivity
kubectl port-forward service/backend 8000:8000 -n ecommerce-prod
curl http://localhost:8000/health
```

#### **Performance Issues**
```bash
# Monitor resource usage
kubectl top pods -n ecommerce-prod
kubectl top nodes

# Check database performance
kubectl exec -it <postgres-pod> -- psql -U postgres -d ecommerce
\x
SELECT * FROM pg_stat_activity WHERE state = 'active';
```

### **Maintenance Tasks**

#### **Regular Maintenance Script**
```bash
#!/bin/bash
# maintenance.sh - Regular maintenance tasks

echo "🔧 Starting maintenance tasks..."

# Clean up old Docker images
docker image prune -f --filter "until=168h"

# Clean up old GitLab CI artifacts
gitlab-rake gitlab:cleanup:project_uploads
gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# Update dependencies
cd frontend && npm audit fix
cd ../backend && pip-audit --fix

# Database maintenance
kubectl exec -it postgres-pod -- psql -U postgres -d ecommerce -c "VACUUM ANALYZE;"

# Security updates
kubectl patch deployment backend -p '{"spec":{"template":{"metadata":{"annotations":{"security-scan":"'$(date +%s)'"}}}}}'

echo "✅ Maintenance tasks completed"
```

---

## 📞 Support & Documentation

### **Team Contacts**
- **DevOps Team**: devops@company.com
- **Security Team**: security@company.com
- **Development Team**: dev@company.com

### **Documentation Links**
- **GitLab CI/CD**: https://docs.gitlab.com/ee/ci/
- **Kubernetes**: https://kubernetes.io/docs/
- **Terraform**: https://www.terraform.io/docs/
- **Prometheus**: https://prometheus.io/docs/

### **Emergency Procedures**
1. **Production Issues**: Contact on-call engineer via PagerDuty
2. **Security Incidents**: Immediately notify security team
3. **Data Breaches**: Follow incident response plan

---

## 🎯 Conclusion

This comprehensive GitLab CI/CD DevSecOps implementation provides:

- **🔒 Security-first approach** with comprehensive scanning
- **🚀 Automated deployment** with multiple strategies
- **📊 Complete observability** and monitoring
- **🏗️ Infrastructure as Code** for consistency
- **🧪 Comprehensive testing** at all levels
- **📋 Compliance** and governance controls

The pipeline ensures that every code change goes through rigorous security, quality, and performance checks before reaching production, while maintaining the agility needed for modern software development.

**Your e-commerce application is now equipped with enterprise-grade DevSecOps practices!** 🛒✨
