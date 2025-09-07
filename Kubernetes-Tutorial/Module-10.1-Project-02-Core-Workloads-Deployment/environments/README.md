# Environment Configurations

## 📋 Overview

This directory contains environment-specific configuration files for the e-commerce application. Each environment has its own `values.yaml` file that defines the specific settings, resource requirements, and configurations for that environment.

## 🏗️ Directory Structure

```
environments/
├── README.md                    # This file
├── development/
│   └── values.yaml             # Development environment configuration
├── staging/
│   └── values.yaml             # Staging environment configuration
└── production/
    └── values.yaml             # Production environment configuration
```

## 🌍 Environment Configurations

### 1. Development Environment (`development/values.yaml`)

**Purpose**: Configuration for local development and testing
**Characteristics**:
- ✅ **Minimal resources** (1 replica, low CPU/memory)
- ✅ **Debug logging** enabled
- ✅ **No ingress** (internal access only)
- ✅ **Standard storage** class
- ✅ **Development-specific** environment variables
- ✅ **Basic monitoring** stack

**Key Features**:
- **Backend**: 1 replica, 100m CPU, 128Mi memory
- **Frontend**: 1 replica, 50m CPU, 64Mi memory
- **Database**: 1 replica, 100m CPU, 256Mi memory
- **Monitoring**: Basic Prometheus and Grafana setup
- **Storage**: 5Gi for database, 10Gi for Prometheus, 5Gi for Grafana

**Usage**:
```bash
# Deploy to development
helm install ecommerce ./templates -f environments/development/values.yaml

# Or using the deploy script
./scripts/deploy.sh development
```

### 2. Staging Environment (`staging/values.yaml`)

**Purpose**: Configuration for staging and pre-production testing
**Characteristics**:
- ✅ **Moderate resources** (2 replicas, medium CPU/memory)
- ✅ **Info logging** level
- ✅ **Ingress enabled** for external testing
- ✅ **Standard storage** class
- ✅ **Staging-specific** environment variables
- ✅ **Full monitoring** stack

**Key Features**:
- **Backend**: 2 replicas, 200m CPU, 256Mi memory
- **Frontend**: 2 replicas, 75m CPU, 96Mi memory
- **Database**: 1 replica, 250m CPU, 512Mi memory
- **Monitoring**: Full Prometheus and Grafana setup
- **Storage**: 20Gi for database, 50Gi for Prometheus, 5Gi for Grafana

**Usage**:
```bash
# Deploy to staging
helm install ecommerce ./templates -f environments/staging/values.yaml

# Or using the deploy script
./scripts/deploy.sh staging
```

### 3. Production Environment (`production/values.yaml`)

**Purpose**: Configuration for production deployment
**Characteristics**:
- ✅ **High resources** (3+ replicas, high CPU/memory)
- ✅ **Info logging** level
- ✅ **Ingress enabled** with TLS
- ✅ **Fast storage** class
- ✅ **Production-specific** environment variables
- ✅ **Full monitoring** stack with alerting
- ✅ **HPA enabled** for auto-scaling
- ✅ **Backup enabled** for database

**Key Features**:
- **Backend**: 3 replicas, 500m CPU, 512Mi memory, HPA enabled
- **Frontend**: 2 replicas, 100m CPU, 128Mi memory
- **Database**: 1 replica, 500m CPU, 1Gi memory, backup enabled
- **Monitoring**: Full Prometheus and Grafana setup with alerting
- **Storage**: 100Gi for database, 100Gi for Prometheus, 10Gi for Grafana

**Usage**:
```bash
# Deploy to production
helm install ecommerce ./templates -f environments/production/values.yaml

# Or using the deploy script
./scripts/deploy.sh production
```

## 🔧 Configuration Parameters

### Global Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `environment` | `development` | `staging` | `production` | Environment identifier |
| `namespace` | `ecommerce-dev` | `ecommerce-staging` | `ecommerce` | Kubernetes namespace |
| `imageRegistry` | `registry.company.com` | `registry.company.com` | `registry.company.com` | Container image registry |
| `imageTag` | `dev-latest` | `staging-latest` | `v1.0.0` | Default image tag |
| `imagePullPolicy` | `IfNotPresent` | `Always` | `Always` | Image pull policy |

### Backend Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `replicas` | 1 | 2 | 3 | Number of backend replicas |
| `resources.requests.cpu` | 100m | 200m | 500m | CPU request |
| `resources.requests.memory` | 128Mi | 256Mi | 512Mi | Memory request |
| `resources.limits.cpu` | 500m | 1000m | 2000m | CPU limit |
| `resources.limits.memory` | 256Mi | 1Gi | 2Gi | Memory limit |
| `env.NODE_ENV` | `development` | `staging` | `production` | Node.js environment |
| `env.LOG_LEVEL` | `debug` | `info` | `info` | Logging level |
| `hpa.enabled` | false | false | true | Horizontal Pod Autoscaler |

### Frontend Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `replicas` | 1 | 2 | 2 | Number of frontend replicas |
| `resources.requests.cpu` | 50m | 75m | 100m | CPU request |
| `resources.requests.memory` | 64Mi | 96Mi | 128Mi | Memory request |
| `resources.limits.cpu` | 200m | 300m | 500m | CPU limit |
| `resources.limits.memory` | 128Mi | 192Mi | 256Mi | Memory limit |
| `env.NODE_ENV` | `development` | `staging` | `production` | Node.js environment |
| `env.REACT_APP_API_BASE_URL` | Internal | Internal | External | Backend API URL |

### Database Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `replicas` | 1 | 1 | 1 | Number of database replicas |
| `resources.requests.cpu` | 100m | 250m | 500m | CPU request |
| `resources.requests.memory` | 256Mi | 512Mi | 1Gi | Memory request |
| `resources.limits.cpu` | 500m | 1000m | 2000m | CPU limit |
| `resources.limits.memory` | 512Mi | 2Gi | 4Gi | Memory limit |
| `persistence.size` | 5Gi | 20Gi | 100Gi | Storage size |
| `persistence.storageClass` | `standard` | `standard` | `fast-ssd` | Storage class |
| `backup.enabled` | false | false | true | Database backup |

### Monitoring Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `prometheus.resources.requests.cpu` | 200m | 300m | 500m | CPU request |
| `prometheus.resources.requests.memory` | 512Mi | 1Gi | 2Gi | Memory request |
| `prometheus.resources.limits.cpu` | 1000m | 1500m | 2000m | CPU limit |
| `prometheus.resources.limits.memory` | 2Gi | 4Gi | 8Gi | Memory limit |
| `prometheus.persistence.size` | 10Gi | 50Gi | 100Gi | Storage size |
| `grafana.resources.requests.cpu` | 100m | 150m | 200m | CPU request |
| `grafana.resources.requests.memory` | 128Mi | 192Mi | 256Mi | Memory request |
| `grafana.resources.limits.cpu` | 500m | 750m | 1000m | CPU limit |
| `grafana.resources.limits.memory` | 512Mi | 768Mi | 1Gi | Memory limit |

### Security Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `networkPolicies.enabled` | true | true | true | Network policies |
| `podSecurityPolicies.enabled` | true | true | true | Pod security policies |
| `resourceQuotas.enabled` | true | true | true | Resource quotas |
| `limitRanges.enabled` | true | true | true | Limit ranges |

### Ingress Configuration

| Parameter | Development | Staging | Production | Description |
|-----------|-------------|---------|------------|-------------|
| `enabled` | false | true | true | Ingress enabled |
| `className` | `nginx` | `nginx` | `nginx` | Ingress class |
| `hosts` | N/A | `ecommerce-staging.company.com` | `ecommerce.company.com` | Ingress hosts |
| `tls` | N/A | Enabled | Enabled | TLS configuration |

## 🚀 Deployment Commands

### Using Helm

```bash
# Development
helm install ecommerce-dev ./templates \
  --namespace ecommerce-dev \
  --create-namespace \
  -f environments/development/values.yaml

# Staging
helm install ecommerce-staging ./templates \
  --namespace ecommerce-staging \
  --create-namespace \
  -f environments/staging/values.yaml

# Production
helm install ecommerce-prod ./templates \
  --namespace ecommerce \
  --create-namespace \
  -f environments/production/values.yaml
```

### Using Deploy Scripts

```bash
# Development
./scripts/deploy.sh development

# Staging
./scripts/deploy.sh staging

# Production
./scripts/deploy.sh production
```

### Using Environment Variables

```bash
# Set environment
export ENVIRONMENT=production

# Deploy with environment-specific values
helm install ecommerce ./templates \
  --namespace ecommerce \
  --create-namespace \
  -f environments/${ENVIRONMENT}/values.yaml
```

## 🔄 Environment Promotion

### Development → Staging

```bash
# 1. Deploy to staging
helm install ecommerce-staging ./templates \
  --namespace ecommerce-staging \
  --create-namespace \
  -f environments/staging/values.yaml

# 2. Run tests
./scripts/operate.sh monitor --namespace=ecommerce-staging

# 3. Validate deployment
./scripts/validation/run-tests.sh --namespace=ecommerce-staging
```

### Staging → Production

```bash
# 1. Deploy to production
helm install ecommerce-prod ./templates \
  --namespace ecommerce \
  --create-namespace \
  -f environments/production/values.yaml

# 2. Run production tests
./scripts/operate.sh monitor --namespace=ecommerce

# 3. Validate production deployment
./scripts/validation/run-tests.sh --namespace=ecommerce
```

## 🔧 Customization

### Adding New Environments

1. **Create environment directory**:
   ```bash
   mkdir -p environments/new-environment
   ```

2. **Create values.yaml**:
   ```bash
   cp environments/development/values.yaml environments/new-environment/values.yaml
   ```

3. **Customize values**:
   - Update environment-specific settings
   - Adjust resource requirements
   - Configure environment variables
   - Set appropriate storage classes

4. **Deploy new environment**:
   ```bash
   helm install ecommerce-new ./templates \
     --namespace ecommerce-new \
     --create-namespace \
     -f environments/new-environment/values.yaml
   ```

### Modifying Existing Environments

1. **Edit values file**:
   ```bash
   vim environments/production/values.yaml
   ```

2. **Update deployment**:
   ```bash
   helm upgrade ecommerce-prod ./templates \
     --namespace ecommerce \
     -f environments/production/values.yaml
   ```

3. **Validate changes**:
   ```bash
   ./scripts/operate.sh status --namespace=ecommerce
   ```

## 📊 Environment Comparison

| Feature | Development | Staging | Production |
|---------|-------------|---------|------------|
| **Replicas** | 1 | 2 | 3+ |
| **Resources** | Low | Medium | High |
| **Storage** | Standard | Standard | Fast SSD |
| **Monitoring** | Basic | Full | Full + Alerting |
| **Ingress** | Disabled | Enabled | Enabled + TLS |
| **Backup** | Disabled | Disabled | Enabled |
| **HPA** | Disabled | Disabled | Enabled |
| **Logging** | Debug | Info | Info |
| **Security** | Basic | Full | Full + Enhanced |

## 🔒 Security Considerations

### Development
- ✅ **Basic security** policies enabled
- ✅ **Internal access** only
- ✅ **Debug logging** for troubleshooting
- ✅ **Minimal resource** limits

### Staging
- ✅ **Full security** policies enabled
- ✅ **External access** for testing
- ✅ **Info logging** for monitoring
- ✅ **Moderate resource** limits

### Production
- ✅ **Enhanced security** policies enabled
- ✅ **External access** with TLS
- ✅ **Info logging** with alerting
- ✅ **High resource** limits
- ✅ **Backup and recovery** enabled
- ✅ **Auto-scaling** enabled

## 📈 Performance Considerations

### Development
- **CPU**: 250m total (100m + 50m + 100m)
- **Memory**: 448Mi total (128Mi + 64Mi + 256Mi)
- **Storage**: 20Gi total (5Gi + 10Gi + 5Gi)
- **Replicas**: 3 total (1 + 1 + 1)

### Staging
- **CPU**: 525m total (200m + 75m + 250m)
- **Memory**: 944Mi total (256Mi + 96Mi + 512Mi)
- **Storage**: 75Gi total (20Gi + 50Gi + 5Gi)
- **Replicas**: 5 total (2 + 2 + 1)

### Production
- **CPU**: 1100m total (500m + 100m + 500m)
- **Memory**: 1664Mi total (512Mi + 128Mi + 1024Mi)
- **Storage**: 210Gi total (100Gi + 100Gi + 10Gi)
- **Replicas**: 6 total (3 + 2 + 1)

## 🚨 Troubleshooting

### Common Issues

#### 1. Resource Limits Too Low
```bash
# Check resource usage
kubectl top pods -n ecommerce

# Adjust resource limits in values.yaml
vim environments/production/values.yaml

# Upgrade deployment
helm upgrade ecommerce ./templates -f environments/production/values.yaml
```

#### 2. Storage Class Not Available
```bash
# Check available storage classes
kubectl get storageclass

# Update storage class in values.yaml
vim environments/production/values.yaml

# Upgrade deployment
helm upgrade ecommerce ./templates -f environments/production/values.yaml
```

#### 3. Ingress Not Working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress status
kubectl get ingress -n ecommerce

# Check ingress logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Debug Commands

```bash
# Check pod status
kubectl get pods -n ecommerce

# Check service status
kubectl get services -n ecommerce

# Check ingress status
kubectl get ingress -n ecommerce

# Check resource usage
kubectl top pods -n ecommerce

# Check events
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

## 📚 Best Practices

### 1. Environment Isolation
- ✅ Use separate namespaces for each environment
- ✅ Use different resource quotas and limits
- ✅ Use different storage classes when appropriate
- ✅ Use different ingress hosts and TLS certificates

### 2. Resource Management
- ✅ Start with conservative resource requests
- ✅ Monitor actual usage and adjust accordingly
- ✅ Use HPA for auto-scaling in production
- ✅ Set appropriate resource limits to prevent resource exhaustion

### 3. Security
- ✅ Enable all security features in all environments
- ✅ Use different passwords and secrets for each environment
- ✅ Use appropriate network policies
- ✅ Enable TLS in staging and production

### 4. Monitoring
- ✅ Enable monitoring in all environments
- ✅ Use appropriate alerting thresholds
- ✅ Monitor resource usage and performance
- ✅ Set up proper logging and log aggregation

### 5. Backup and Recovery
- ✅ Enable backup in production
- ✅ Test restore procedures regularly
- ✅ Use appropriate retention policies
- ✅ Store backups in secure locations

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintainer**: Platform Engineering Team
