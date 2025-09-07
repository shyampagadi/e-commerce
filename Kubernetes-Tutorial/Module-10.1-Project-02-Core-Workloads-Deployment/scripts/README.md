# E-commerce Application Automation Scripts

## 📋 Overview

This directory contains comprehensive automation scripts for deploying, operating, monitoring, and maintaining the e-commerce application on Kubernetes. These scripts provide enterprise-grade automation capabilities for all aspects of the application lifecycle.

## 🚀 Available Scripts

### 1. `deploy.sh` - Deployment Automation
**Purpose**: Comprehensive deployment automation for the e-commerce application and monitoring stack.

**Features**:
- ✅ **Complete deployment orchestration** (core application + monitoring stack)
- ✅ **Dry-run support** for testing deployments without changes
- ✅ **Validation integration** with automated health checks
- ✅ **Rollback capabilities** for failed deployments
- ✅ **Force deployment** option for emergency situations
- ✅ **Deployment tracking** with unique IDs and logging
- ✅ **Prerequisites checking** (kubectl, cluster connectivity, namespace)
- ✅ **Resource cleanup** after deployment

**Usage**:
```bash
# Basic deployment
./deploy.sh

# Deploy with validation and monitoring
./deploy.sh production --validate --monitor

# Dry run deployment
./deploy.sh production --dry-run

# Force deployment (skip some checks)
./deploy.sh production --force

# Deploy to custom namespace
./deploy.sh production --namespace=ecommerce-prod
```

### 2. `operate.sh` - Operations Management
**Purpose**: Day-to-day operations management for the e-commerce application.

**Features**:
- ✅ **Status monitoring** (pods, services, deployments, resource usage)
- ✅ **Log management** (view logs for specific components)
- ✅ **Deployment operations** (restart, scale, update images)
- ✅ **Data management** (backup, restore)
- ✅ **Health monitoring** with comprehensive checks
- ✅ **Resource cleanup** for maintenance
- ✅ **Component-specific operations** (backend, frontend, database, monitoring)

**Usage**:
```bash
# Show status of all components
./operate.sh status

# Show logs for backend component
./operate.sh logs --component=backend

# Restart backend deployment
./operate.sh restart --component=backend

# Scale frontend to 3 replicas
./operate.sh scale --component=frontend --replicas=3

# Update backend image
./operate.sh update --component=backend --image=ecommerce-backend:v2.0.0

# Backup application data
./operate.sh backup

# Monitor application health
./operate.sh monitor

# Cleanup resources
./operate.sh cleanup
```

### 3. `monitor.sh` - Monitoring and Alerting
**Purpose**: Comprehensive monitoring and alerting for the e-commerce application.

**Features**:
- ✅ **Real-time monitoring** with configurable intervals
- ✅ **Health checks** (pods, services, resource usage, disk space)
- ✅ **Monitoring stack validation** (Prometheus, Grafana, AlertManager)
- ✅ **Automated alerting** with email notifications
- ✅ **Performance monitoring** (CPU, memory, disk usage)
- ✅ **Continuous monitoring** with duration control
- ✅ **Monitoring reports** (HTML and text formats)
- ✅ **Alert management** with status tracking

**Usage**:
```bash
# Show current status
./monitor.sh status

# Check application health
./monitor.sh health

# Show resource metrics
./monitor.sh metrics

# Monitor continuously for 10 minutes
./monitor.sh monitor --duration=600s

# Generate monitoring report
./monitor.sh report

# Check for active alerts
./monitor.sh alerts

# Monitor with custom interval
./monitor.sh monitor --interval=60s --duration=300s
```

### 4. `backup.sh` - Backup and Recovery
**Purpose**: Comprehensive backup and recovery for the e-commerce application.

**Features**:
- ✅ **Complete backup** (Kubernetes resources, database, persistent volumes)
- ✅ **Monitoring data backup** (Prometheus, Grafana data)
- ✅ **Database backup** (PostgreSQL dump with verification)
- ✅ **Persistent volume backup** (data from mounted volumes)
- ✅ **Backup compression** to save space
- ✅ **Backup verification** to ensure integrity
- ✅ **Restore capabilities** with full recovery
- ✅ **Backup management** (list, cleanup, retention)
- ✅ **Disaster recovery** support

**Usage**:
```bash
# Create a complete backup
./backup.sh backup

# Create backup with custom directory
./backup.sh backup --backup-dir=/backups/ecommerce-20241201

# Restore from backup
./backup.sh restore --restore-dir=/backups/ecommerce-20241201

# List available backups
./backup.sh list

# Cleanup old backups (keep 7 days)
./backup.sh cleanup --retention=7

# Verify backup integrity
./backup.sh verify --backup-dir=/backups/ecommerce-20241201

# Create uncompressed backup
./backup.sh backup --no-compress
```

## 🔧 Configuration

### Environment Variables
```bash
# Set default namespace
export DEFAULT_NAMESPACE=ecommerce

# Set default backup directory
export DEFAULT_BACKUP_DIR=/backups/ecommerce

# Set alert email
export ALERT_EMAIL=admin@ecommerce.local

# Set monitoring interval
export MONITORING_INTERVAL=30s
```

### Script Parameters
| Script | Parameter | Default | Description |
|--------|-----------|---------|-------------|
| `deploy.sh` | `environment` | `production` | Target environment |
| `deploy.sh` | `--namespace` | `ecommerce` | Kubernetes namespace |
| `deploy.sh` | `--dry-run` | `false` | Test mode without changes |
| `operate.sh` | `--component` | `all` | Specific component |
| `operate.sh` | `--namespace` | `ecommerce` | Kubernetes namespace |
| `monitor.sh` | `--duration` | `300s` | Monitoring duration |
| `monitor.sh` | `--interval` | `30s` | Monitoring interval |
| `backup.sh` | `--retention` | `30` | Backup retention days |
| `backup.sh` | `--compress` | `true` | Enable compression |

## 📊 Monitoring and Alerting

### Health Checks
- **Pod Health**: Status, readiness, restarts, resource usage
- **Service Health**: Endpoints, connectivity, accessibility
- **Resource Health**: CPU, memory, disk usage, limits
- **Database Health**: Connection, performance, data integrity
- **Monitoring Health**: Prometheus targets, Grafana access, AlertManager

### Alert Types
- **Critical**: Pod failures, service outages, resource exhaustion
- **Warning**: High resource usage, degraded performance
- **Info**: Status changes, maintenance activities

### Alert Channels
- **Email**: Automated email notifications
- **Logs**: Alert logging for monitoring systems
- **Console**: Real-time console output

## 🛠️ Operations Workflows

### Daily Operations
```bash
# Morning health check
./monitor.sh health

# Check resource usage
./operate.sh status

# Review logs for issues
./operate.sh logs --component=backend
```

### Weekly Maintenance
```bash
# Create backup
./backup.sh backup

# Cleanup old backups
./backup.sh cleanup --retention=7

# Monitor performance
./monitor.sh monitor --duration=600s
```

### Deployment Workflow
```bash
# Test deployment
./deploy.sh production --dry-run

# Deploy with validation
./deploy.sh production --validate --monitor

# Verify deployment
./operate.sh status
```

### Emergency Procedures
```bash
# Force deployment
./deploy.sh production --force

# Rollback deployment
./deploy.sh production --rollback

# Restore from backup
./backup.sh restore --restore-dir=/backups/ecommerce-20241201
```

## 🔒 Security Considerations

### Access Control
- Scripts require `kubectl` access to the cluster
- Use RBAC to limit script permissions
- Consider using service accounts for automation

### Data Protection
- Backup scripts handle sensitive data (secrets, database)
- Use encrypted storage for backup data
- Implement proper access controls for backup files

### Audit Logging
- All scripts generate detailed logs
- Logs include timestamps and user information
- Consider centralized logging for audit trails

## 📈 Performance Optimization

### Resource Management
- Scripts include resource usage monitoring
- Automatic cleanup of temporary resources
- Efficient backup compression

### Monitoring Efficiency
- Configurable monitoring intervals
- Selective component monitoring
- Optimized health check procedures

### Backup Optimization
- Incremental backup capabilities
- Compression to reduce storage requirements
- Parallel backup operations

## 🚨 Troubleshooting

### Common Issues

#### 1. "kubectl command not found"
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

#### 2. "Cannot connect to Kubernetes cluster"
```bash
# Check kubeconfig
kubectl config current-context

# Test connectivity
kubectl cluster-info
```

#### 3. "Namespace does not exist"
```bash
# Create namespace
kubectl create namespace ecommerce

# Or check existing namespaces
kubectl get namespaces
```

#### 4. "Backup failed"
```bash
# Check disk space
df -h

# Check permissions
ls -la /backups/

# Verify backup directory
./backup.sh verify --backup-dir=/backups/ecommerce-20241201
```

### Debug Mode
```bash
# Enable verbose output
./operate.sh status --verbose

# Check script logs
tail -f /tmp/deployment_*.log
tail -f /tmp/backup_*.log
```

## 🔄 Integration

### CI/CD Pipeline Integration
```yaml
# Example GitHub Actions workflow
- name: Deploy E-commerce Application
  run: |
    cd scripts/
    ./deploy.sh production --validate --monitor

- name: Run Health Checks
  run: |
    cd scripts/
    ./monitor.sh health
```

### Monitoring System Integration
```bash
# Export metrics to monitoring system
./monitor.sh metrics | jq '.cpu_usage'

# Send alerts to external systems
./monitor.sh alerts | mail -s "E-commerce Alerts" admin@company.com
```

### Backup System Integration
```bash
# Schedule automated backups
0 2 * * * /path/to/scripts/backup.sh backup

# Integrate with cloud storage
./backup.sh backup --backup-dir=/cloud-storage/ecommerce-backup-$(date +%Y%m%d)
```

## 📚 Best Practices

### 1. Regular Operations
- Run health checks every 15 minutes
- Create daily backups
- Monitor resource usage continuously
- Review logs weekly

### 2. Deployment Practices
- Always test with `--dry-run` first
- Use validation and monitoring for production deployments
- Keep deployment logs for audit trails
- Implement proper rollback procedures

### 3. Backup Practices
- Create backups before major changes
- Test restore procedures regularly
- Implement proper retention policies
- Store backups in secure locations

### 4. Monitoring Practices
- Set up appropriate alert thresholds
- Monitor all critical components
- Use continuous monitoring for production
- Generate regular monitoring reports

## 📞 Support

For issues or questions regarding the automation scripts:

- **Documentation**: Check this README and inline script comments
- **Logs**: Review script output and log files
- **Debugging**: Use `--verbose` flag for detailed output
- **Issues**: Report bugs or feature requests through the project repository

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Platform Engineering Team
