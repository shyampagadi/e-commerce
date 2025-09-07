# 🔧 **Comprehensive Operations Runbook**
## *Spring PetClinic Microservices Platform - Enterprise Edition*

**Document Version**: 2.0.0  
**Date**: December 2024  
**Classification**: Internal Operations  
**Owner**: DevOps Team  
**Review Cycle**: Monthly  

---

## 📖 **Table of Contents**

1. [Executive Summary](#executive-summary)
2. [System Architecture Overview](#system-architecture-overview)
3. [Daily Operations](#daily-operations)
4. [Weekly Operations](#weekly-operations)
5. [Monthly Operations](#monthly-operations)
6. [Incident Response Procedures](#incident-response-procedures)
7. [Monitoring & Alerting](#monitoring--alerting)
8. [Backup & Recovery](#backup--recovery)
9. [Performance Management](#performance-management)
10. [Security Operations](#security-operations)
11. [Capacity Planning](#capacity-planning)
12. [Change Management](#change-management)
13. [Emergency Procedures](#emergency-procedures)
14. [Troubleshooting Guide](#troubleshooting-guide)
15. [Contact Information](#contact-information)

---

## 🎯 **Executive Summary**

This operations runbook provides comprehensive procedures for managing the Spring PetClinic Microservices Platform in production. It covers daily operations, incident response, monitoring, backup procedures, and emergency protocols.

**Key Operational Metrics:**
- **Availability Target**: 99.9% uptime
- **Response Time Target**: < 200ms for 95% of requests
- **Recovery Time Objective (RTO)**: < 4 hours
- **Recovery Point Objective (RPO)**: < 1 hour

---

## 🏗️ **System Architecture Overview**

### **Service Topology**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │────│ Discovery Server│────│  Config Server  │
│   (Port 8080)   │    │   (Port 8761)   │    │   (Port 8888)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
    ┌────┴────┬────────────┬────────────┐
    │         │            │            │
┌───▼───┐ ┌──▼────┐ ┌─────▼──┐ ┌──────▼──┐
│Customer│ │  Vet  │ │ Visit  │ │  Admin  │
│Service │ │Service│ │Service │ │ Server  │
│(8081)  │ │(8082) │ │(8083)  │ │ (9090)  │
└───┬───┘ └──┬────┘ └─────┬──┘ └──────┬──┘
    │        │            │           │
┌───▼───┐ ┌──▼────┐ ┌─────▼──┐       │
│MySQL  │ │MySQL  │ │MySQL   │       │
│Customer│ │Vet DB │ │Visit DB│       │
│  DB   │ │       │ │        │       │
└───────┘ └───────┘ └────────┘       │
                                     │
    ┌────────────────────────────────┘
    │
┌───▼────────────────────────────────────┐
│         Monitoring Stack               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │Prometheus│ │ Grafana │ │ Jaeger  │  │
│  │ (9090)  │ │ (3000)  │ │ (16686) │  │
│  └─────────┘ └─────────┘ └─────────┘  │
└────────────────────────────────────────┘
```

### **Critical Dependencies**
- **Kubernetes Cluster**: Minimum 3 nodes, 16GB RAM each
- **Persistent Storage**: 500GB SSD storage for databases
- **Network**: Load balancer with SSL termination
- **DNS**: Internal DNS resolution for service discovery

---

## 🚀 **Daily Operations**

### **Morning Health Check Routine (8:00 AM)**

#### **1. System Status Verification**
```bash
#!/bin/bash
# Daily health check script
echo "🏥 Spring PetClinic Daily Health Check - $(date)"
echo "=================================================="

# Check namespace status
echo "📊 Namespace Status:"
kubectl get ns petclinic -o wide

# Check all pods status
echo "🔍 Pod Status:"
kubectl get pods -n petclinic -o wide

# Check services status
echo "🌐 Service Status:"
kubectl get svc -n petclinic -o wide

# Check persistent volumes
echo "💾 Storage Status:"
kubectl get pvc -n petclinic -o wide

# Check ingress status
echo "🚪 Ingress Status:"
kubectl get ingress -n petclinic -o wide
```

#### **2. Application Health Verification**
```bash
# Health endpoint checks
NAMESPACE="petclinic"
SERVICES=("config-server" "discovery-server" "api-gateway" "customer-service" "vet-service" "visit-service" "admin-server")

for service in "${SERVICES[@]}"; do
    echo "🔍 Checking $service health..."
    kubectl exec -n $NAMESPACE deployment/$service -- curl -s http://localhost:8080/actuator/health | jq .
done
```

#### **3. Database Connectivity Check**
```bash
# MySQL database connectivity
DATABASES=("mysql-customer" "mysql-vet" "mysql-visit")

for db in "${DATABASES[@]}"; do
    echo "🗄️ Checking $db connectivity..."
    kubectl exec -n petclinic deployment/$db -- mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT 1" 2>/dev/null && echo "✅ $db: Connected" || echo "❌ $db: Connection failed"
done
```

#### **4. Performance Metrics Review**
```bash
# Resource utilization check
echo "📈 Resource Utilization:"
kubectl top nodes
kubectl top pods -n petclinic --sort-by=cpu
kubectl top pods -n petclinic --sort-by=memory
```

### **Backup Verification (9:00 AM)**
```bash
#!/bin/bash
# Verify daily backups
BACKUP_DIR="/tmp/petclinic-backups"
TODAY=$(date +%Y-%m-%d)

echo "🔍 Verifying backups for $TODAY..."

# Check if backup files exist
for db in customer vet visit; do
    BACKUP_FILE="$BACKUP_DIR/mysql-${db}-${TODAY}.sql"
    if [[ -f "$BACKUP_FILE" ]]; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "✅ mysql-${db}: $SIZE"
    else
        echo "❌ mysql-${db}: Backup missing!"
        # Send alert
        ./scripts/alerts/send-alert.sh "BACKUP_MISSING" "mysql-${db} backup missing for $TODAY"
    fi
done
```

### **Log Analysis (10:00 AM)**
```bash
# Check for errors in the last 24 hours
echo "🔍 Error Analysis (Last 24 hours):"
kubectl logs -n petclinic --since=24h --selector=app=api-gateway | grep -i error | tail -20
kubectl logs -n petclinic --since=24h --selector=app=customer-service | grep -i error | tail -20
kubectl logs -n petclinic --since=24h --selector=app=vet-service | grep -i error | tail -20
kubectl logs -n petclinic --since=24h --selector=app=visit-service | grep -i error | tail -20
```

---

## 📅 **Weekly Operations**

### **Monday: System Maintenance**
```bash
#!/bin/bash
# Weekly system maintenance
echo "🔧 Weekly System Maintenance - $(date)"

# 1. Update system packages (if applicable)
echo "📦 Checking for system updates..."

# 2. Clean up old logs
echo "🧹 Cleaning up old logs..."
kubectl delete pods -n petclinic --field-selector=status.phase=Succeeded

# 3. Restart services with memory leaks (if identified)
echo "🔄 Restarting services if needed..."
# Add specific services that need weekly restart

# 4. Update SSL certificates (if needed)
echo "🔐 Checking SSL certificate expiry..."
kubectl get secrets -n petclinic -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | .metadata.name' | while read cert; do
    kubectl get secret $cert -n petclinic -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates
done
```

### **Wednesday: Performance Review**
```bash
#!/bin/bash
# Weekly performance analysis
echo "📊 Weekly Performance Review - $(date)"

# Generate performance report
./scripts/reports/generate-performance-report.sh

# Check for performance degradation
./scripts/monitoring/performance-analysis.sh

# Review resource utilization trends
./scripts/monitoring/resource-trend-analysis.sh
```

### **Friday: Security Scan**
```bash
#!/bin/bash
# Weekly security scan
echo "🔒 Weekly Security Scan - $(date)"

# Scan container images for vulnerabilities
./scripts/security/container-scan.sh

# Check for security updates
./scripts/security/security-update-check.sh

# Review access logs
./scripts/security/access-log-analysis.sh
```

---

## 📊 **Monthly Operations**

### **First Monday: Capacity Planning Review**
```bash
#!/bin/bash
# Monthly capacity planning
echo "📈 Monthly Capacity Planning Review - $(date)"

# Generate capacity report
./scripts/reports/generate-capacity-report.sh

# Analyze growth trends
./scripts/analysis/growth-trend-analysis.sh

# Update capacity forecasts
./scripts/planning/update-capacity-forecast.sh
```

### **Second Monday: Disaster Recovery Test**
```bash
#!/bin/bash
# Monthly DR test
echo "🚨 Monthly Disaster Recovery Test - $(date)"

# Test backup restoration
./scripts/dr/test-backup-restore.sh

# Test failover procedures
./scripts/dr/test-failover.sh

# Update DR documentation
./scripts/dr/update-dr-docs.sh
```

---

## 🚨 **Incident Response Procedures**

### **Severity Levels**

| Severity | Description | Response Time | Escalation |
|----------|-------------|---------------|------------|
| **P1 - Critical** | System down, data loss | 15 minutes | Immediate |
| **P2 - High** | Major functionality impacted | 1 hour | 2 hours |
| **P3 - Medium** | Minor functionality impacted | 4 hours | 8 hours |
| **P4 - Low** | Cosmetic issues | 24 hours | 48 hours |

### **P1 - Critical Incident Response**

#### **Immediate Actions (0-15 minutes)**
```bash
#!/bin/bash
# P1 Incident Response Script
echo "🚨 P1 CRITICAL INCIDENT RESPONSE ACTIVATED"
echo "Time: $(date)"
echo "Incident ID: $1"

# 1. Acknowledge incident
echo "✅ Incident acknowledged by: $(whoami)"

# 2. Quick system status check
echo "🔍 Quick system status:"
kubectl get pods -n petclinic | grep -v Running

# 3. Check recent deployments
echo "📋 Recent deployments:"
kubectl rollout history deployment -n petclinic

# 4. Notify stakeholders
./scripts/alerts/notify-stakeholders.sh "P1" "$1" "Critical incident in progress"

# 5. Start incident bridge
echo "📞 Starting incident bridge..."
# Add incident bridge setup commands
```

#### **Investigation Phase (15-60 minutes)**
```bash
# Detailed investigation
echo "🔍 Starting detailed investigation..."

# Check system resources
kubectl top nodes
kubectl top pods -n petclinic

# Check recent events
kubectl get events -n petclinic --sort-by='.lastTimestamp' | tail -20

# Check application logs
kubectl logs -n petclinic --selector=app=api-gateway --tail=100
kubectl logs -n petclinic --selector=app=customer-service --tail=100

# Check database status
kubectl exec -n petclinic deployment/mysql-customer -- mysqladmin status
kubectl exec -n petclinic deployment/mysql-vet -- mysqladmin status
kubectl exec -n petclinic deployment/mysql-visit -- mysqladmin status
```

### **Service-Specific Incident Response**

#### **API Gateway Down**
```bash
#!/bin/bash
echo "🚨 API Gateway Incident Response"

# 1. Check pod status
kubectl get pods -n petclinic -l app=api-gateway

# 2. Check service endpoints
kubectl get endpoints -n petclinic api-gateway

# 3. Check ingress configuration
kubectl describe ingress -n petclinic

# 4. Restart if needed
kubectl rollout restart deployment/api-gateway -n petclinic

# 5. Monitor recovery
kubectl rollout status deployment/api-gateway -n petclinic
```

#### **Database Connection Issues**
```bash
#!/bin/bash
echo "🗄️ Database Connection Issue Response"

# 1. Check database pods
kubectl get pods -n petclinic | grep mysql

# 2. Check persistent volumes
kubectl get pvc -n petclinic

# 3. Check database connectivity
for db in mysql-customer mysql-vet mysql-visit; do
    kubectl exec -n petclinic deployment/$db -- mysqladmin ping
done

# 4. Check database logs
kubectl logs -n petclinic deployment/mysql-customer --tail=50
kubectl logs -n petclinic deployment/mysql-vet --tail=50
kubectl logs -n petclinic deployment/mysql-visit --tail=50

# 5. Restart database if needed
# kubectl rollout restart deployment/mysql-customer -n petclinic
```

#### **High Memory Usage**
```bash
#!/bin/bash
echo "💾 High Memory Usage Response"

# 1. Identify memory-intensive pods
kubectl top pods -n petclinic --sort-by=memory

# 2. Check memory limits
kubectl describe pods -n petclinic | grep -A 5 -B 5 "memory"

# 3. Scale up if needed
kubectl scale deployment/customer-service --replicas=3 -n petclinic
kubectl scale deployment/vet-service --replicas=3 -n petclinic
kubectl scale deployment/visit-service --replicas=3 -n petclinic

# 4. Monitor memory usage
watch kubectl top pods -n petclinic
```

---

## 📊 **Monitoring & Alerting**

### **Prometheus Metrics**
```yaml
# Key metrics to monitor
groups:
  - name: petclinic.rules
    rules:
    - alert: ServiceDown
      expr: up{job="petclinic"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Service {{ $labels.instance }} is down"
        
    - alert: HighMemoryUsage
      expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage on {{ $labels.pod }}"
        
    - alert: HighCPUUsage
      expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.pod }}"
```

### **Grafana Dashboards**
```bash
# Access monitoring dashboards
echo "📊 Accessing Monitoring Dashboards"

# Grafana
kubectl port-forward -n petclinic svc/grafana 3000:3000 &
echo "Grafana: http://localhost:3000 (admin/admin)"

# Prometheus
kubectl port-forward -n petclinic svc/prometheus 9090:9090 &
echo "Prometheus: http://localhost:9090"

# Jaeger
kubectl port-forward -n petclinic svc/jaeger 16686:16686 &
echo "Jaeger: http://localhost:16686"
```

---

## 💾 **Backup & Recovery**

### **Automated Daily Backup**
```bash
#!/bin/bash
# Automated backup script (runs daily at 2 AM)
BACKUP_DIR="/tmp/petclinic-backups"
DATE=$(date +%Y-%m-%d)
RETENTION_DAYS=30

echo "🔄 Starting automated backup - $DATE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup each database
DATABASES=("customer" "vet" "visit")
for db in "${DATABASES[@]}"; do
    echo "📦 Backing up mysql-$db..."
    kubectl exec -n petclinic deployment/mysql-$db -- mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > "$BACKUP_DIR/mysql-${db}-${DATE}.sql"
    
    # Compress backup
    gzip "$BACKUP_DIR/mysql-${db}-${DATE}.sql"
    
    echo "✅ mysql-$db backup completed"
done

# Clean up old backups
echo "🧹 Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Upload to cloud storage (if configured)
# aws s3 sync "$BACKUP_DIR" s3://petclinic-backups/

echo "✅ Backup process completed"
```

### **Recovery Procedures**
```bash
#!/bin/bash
# Database recovery script
BACKUP_FILE="$1"
DATABASE="$2"

if [[ -z "$BACKUP_FILE" || -z "$DATABASE" ]]; then
    echo "Usage: $0 <backup_file> <database_name>"
    exit 1
fi

echo "🔄 Starting recovery for $DATABASE from $BACKUP_FILE"

# 1. Scale down application services
kubectl scale deployment/customer-service --replicas=0 -n petclinic
kubectl scale deployment/vet-service --replicas=0 -n petclinic
kubectl scale deployment/visit-service --replicas=0 -n petclinic

# 2. Restore database
kubectl exec -n petclinic deployment/mysql-$DATABASE -- mysql -u root -p$MYSQL_ROOT_PASSWORD < "$BACKUP_FILE"

# 3. Scale up application services
kubectl scale deployment/customer-service --replicas=2 -n petclinic
kubectl scale deployment/vet-service --replicas=2 -n petclinic
kubectl scale deployment/visit-service --replicas=2 -n petclinic

# 4. Verify recovery
./scripts/maintenance/health-check.sh

echo "✅ Recovery completed for $DATABASE"
```

---

## 📞 **Contact Information**

### **Escalation Matrix**

| Role | Primary | Secondary | Phone | Email |
|------|---------|-----------|-------|-------|
| **On-Call Engineer** | John Doe | Jane Smith | +1-555-0101 | oncall@petclinic.com |
| **DevOps Lead** | Mike Johnson | Sarah Wilson | +1-555-0102 | devops@petclinic.com |
| **Technical Lead** | David Brown | Lisa Davis | +1-555-0103 | tech-lead@petclinic.com |
| **Product Manager** | Emily Chen | Robert Taylor | +1-555-0104 | product@petclinic.com |

### **External Contacts**
- **Cloud Provider Support**: +1-800-AWS-HELP
- **Database Vendor**: +1-800-MYSQL-HELP
- **Security Team**: security@petclinic.com

---

## 📝 **Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2024-12-01 | DevOps Team | Initial version |
| 2.0.0 | 2024-12-07 | DevOps Team | Comprehensive operations update |

**Next Review Date**: 2024-12-21  
**Document Owner**: DevOps Lead  
**Approval**: Technical Lead, Operations Manager
