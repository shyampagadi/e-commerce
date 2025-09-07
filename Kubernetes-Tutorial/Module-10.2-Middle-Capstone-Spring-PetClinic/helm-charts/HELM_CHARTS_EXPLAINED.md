# ⚓ **Helm Charts Comprehensive Guide**
## *Spring PetClinic Microservices Platform*

**Document Version**: 1.0.0  
**Date**: December 2024  
**Purpose**: Complete explanation of Helm charts and package management  
**Audience**: DevOps Engineers, Kubernetes Administrators, Release Managers  

---

## 📖 **Table of Contents**

1. [Overview](#overview)
2. [Chart Structure](#chart-structure)
3. [Chart.yaml Explained](#chartyaml-explained)
4. [Values.yaml Configuration](#valuesyaml-configuration)
5. [Template System](#template-system)
6. [Deployment Strategies](#deployment-strategies)
7. [Environment Management](#environment-management)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 **Overview**

Helm is the package manager for Kubernetes, often called "the apt/yum for Kubernetes." This guide explains how Helm charts are used to manage the Spring PetClinic Microservices Platform deployment, configuration, and lifecycle management.

### **Why Helm for PetClinic?**
- ✅ **Templating**: Reusable Kubernetes manifests across environments
- ✅ **Package Management**: Versioned releases with rollback capability
- ✅ **Configuration Management**: Environment-specific values
- ✅ **Dependency Management**: Manage chart dependencies
- ✅ **Release Management**: Track deployment history and status

---

## 📁 **Chart Structure**

```
helm-charts/petclinic/
├── Chart.yaml              # Chart metadata and dependencies
├── values.yaml             # Default configuration values
├── values-dev.yaml         # Development environment values
├── values-staging.yaml     # Staging environment values
├── values-prod.yaml        # Production environment values
├── templates/              # Kubernetes manifest templates
│   ├── deployment.yaml     # Application deployments
│   ├── service.yaml        # Service definitions
│   ├── configmap.yaml      # Configuration maps
│   ├── secret.yaml         # Secret definitions
│   ├── ingress.yaml        # Ingress configuration
│   ├── hpa.yaml           # Horizontal Pod Autoscaler
│   ├── pdb.yaml           # Pod Disruption Budget
│   ├── networkpolicy.yaml # Network policies
│   ├── rbac.yaml          # RBAC configuration
│   └── _helpers.tpl       # Template helpers
├── charts/                 # Dependency charts (if any)
└── README.md              # Chart documentation
```

---

## 📋 **Chart.yaml Explained**

**File: `helm-charts/petclinic/Chart.yaml`**

```yaml
apiVersion: v2
name: petclinic
description: Spring PetClinic Microservices Platform Helm Chart
type: application
version: 1.0.0
appVersion: "2.7.3"
home: https://github.com/spring-projects/spring-petclinic-microservices
sources:
  - https://github.com/spring-projects/spring-petclinic-microservices
maintainers:
  - name: DevOps Team
    email: devops@petclinic.com
    url: https://petclinic.com
keywords:
  - spring-boot
  - microservices
  - java
  - mysql
  - kubernetes
  - monitoring
annotations:
  category: Application
  licenses: Apache-2.0
dependencies:
  - name: mysql
    version: "9.4.6"
    repository: "https://charts.bitnami.com/bitnami"
    condition: mysql.enabled
  - name: prometheus
    version: "15.18.0"
    repository: "https://prometheus-community.github.io/helm-charts"
    condition: monitoring.prometheus.enabled
  - name: grafana
    version: "6.50.7"
    repository: "https://grafana.github.io/helm-charts"
    condition: monitoring.grafana.enabled
```

### **Chart.yaml Fields Explained**

#### **Basic Metadata**
- **apiVersion**: `v2` - Helm 3 chart format
- **name**: `petclinic` - Chart name (must match directory name)
- **description**: Human-readable chart description
- **type**: `application` - Indicates this is an application chart (vs library)
- **version**: `1.0.0` - Chart version (SemVer format)
- **appVersion**: `2.7.3` - Version of the application being deployed

#### **Project Information**
- **home**: Project homepage URL
- **sources**: Source code repository URLs
- **maintainers**: Contact information for chart maintainers
- **keywords**: Search keywords for chart discovery
- **annotations**: Additional metadata for chart repositories

#### **Dependencies**
```yaml
dependencies:
  - name: mysql
    version: "9.4.6"
    repository: "https://charts.bitnami.com/bitnami"
    condition: mysql.enabled
```

**Dependency Explanation**:
- **name**: Name of the dependency chart
- **version**: Specific version to use (supports ranges)
- **repository**: Helm repository URL
- **condition**: Boolean value to enable/disable dependency

**Dependency Management Commands**:
```bash
# Update dependencies
helm dependency update

# Build dependency lock file
helm dependency build

# List dependencies
helm dependency list
```

---

## ⚙️ **Values.yaml Configuration**

**File: `helm-charts/petclinic/values.yaml`**

```yaml
# Global configuration
global:
  imageRegistry: ""
  imagePullSecrets: []
  storageClass: "fast-ssd"

# Application configuration
app:
  name: petclinic
  version: "2.7.3"
  environment: production

# Image configuration
image:
  registry: springcommunity
  repository: spring-petclinic
  tag: "latest"
  pullPolicy: IfNotPresent

# Replica configuration
replicaCount:
  configServer: 1
  discoveryServer: 1
  apiGateway: 2
  customerService: 2
  vetService: 2
  visitService: 2
  adminServer: 1

# Service configuration
service:
  type: ClusterIP
  ports:
    configServer: 8888
    discoveryServer: 8761
    apiGateway: 8080
    customerService: 8081
    vetService: 8082
    visitService: 8083
    adminServer: 9090

# Ingress configuration
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: petclinic.example.com
      paths:
        - path: /
          pathType: Prefix
          service: api-gateway
  tls:
    - secretName: petclinic-tls
      hosts:
        - petclinic.example.com

# Resource configuration
resources:
  configServer:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "250m"
  discoveryServer:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "250m"
  apiGateway:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
  customerService:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
  vetService:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
  visitService:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
  adminServer:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "250m"

# Autoscaling configuration
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL

# Network policies
networkPolicy:
  enabled: true
  ingress:
    enabled: true
  egress:
    enabled: true

# Database configuration
mysql:
  enabled: true
  auth:
    rootPassword: "petclinic-root-password"
    username: "petclinic"
    password: "petclinic-password"
    database: "petclinic"
  primary:
    persistence:
      enabled: true
      size: 10Gi
      storageClass: "fast-ssd"
  metrics:
    enabled: true

# Monitoring configuration
monitoring:
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
      interval: 30s
      path: /actuator/prometheus
  grafana:
    enabled: true
    adminPassword: "admin"
    dashboards:
      enabled: true
  jaeger:
    enabled: true

# Backup configuration
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: "30d"
  storage:
    size: "50Gi"
    storageClass: "standard"

# Configuration for different environments
environments:
  development:
    replicaCount: 1
    resources:
      requests:
        memory: "128Mi"
        cpu: "50m"
      limits:
        memory: "256Mi"
        cpu: "100m"
  staging:
    replicaCount: 1
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "250m"
  production:
    replicaCount: 2
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```

### **Values.yaml Structure Explained**

#### **Global Configuration**
```yaml
global:
  imageRegistry: ""           # Override default image registry
  imagePullSecrets: []        # Secrets for private registries
  storageClass: "fast-ssd"    # Default storage class
```

**Global values** are accessible by all templates and sub-charts, providing consistent configuration across the entire deployment.

#### **Application Configuration**
```yaml
app:
  name: petclinic
  version: "2.7.3"
  environment: production
```

**Application-level settings** that define the overall deployment characteristics.

#### **Resource Management**
```yaml
resources:
  apiGateway:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
```

**Resource allocation** ensures proper resource management and prevents resource starvation.

#### **Autoscaling Configuration**
```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

**Horizontal Pod Autoscaler** configuration for automatic scaling based on resource utilization.

---

## 📝 **Template System**

### **Template Helpers**

**File: `templates/_helpers.tpl`**

```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "petclinic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "petclinic.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "petclinic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "petclinic.labels" -}}
helm.sh/chart: {{ include "petclinic.chart" . }}
{{ include "petclinic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "petclinic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "petclinic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "petclinic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "petclinic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate database connection string
*/}}
{{- define "petclinic.databaseUrl" -}}
{{- if .Values.mysql.enabled }}
{{- printf "jdbc:mysql://%s-mysql:3306/%s" (include "petclinic.fullname" .) .Values.mysql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.url }}
{{- end }}
{{- end }}

{{/*
Generate image name
*/}}
{{- define "petclinic.image" -}}
{{- $registry := .Values.global.imageRegistry | default .Values.image.registry }}
{{- $repository := .Values.image.repository }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag }}
{{- else }}
{{- printf "%s:%s" $repository $tag }}
{{- end }}
{{- end }}
```

### **Template Functions Explained**

#### **Naming Functions**
- **petclinic.name**: Generates consistent resource names
- **petclinic.fullname**: Creates fully qualified names with release prefix
- **petclinic.chart**: Combines chart name and version for labels

#### **Label Functions**
- **petclinic.labels**: Standard Kubernetes labels for all resources
- **petclinic.selectorLabels**: Labels used for pod selection

#### **Utility Functions**
- **petclinic.serviceAccountName**: Determines service account name
- **petclinic.databaseUrl**: Generates database connection string
- **petclinic.image**: Constructs full image name with registry

### **Deployment Template Example**

**File: `templates/deployment.yaml`**

```yaml
{{- range $service := list "config-server" "discovery-server" "api-gateway" "customer-service" "vet-service" "visit-service" "admin-server" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "petclinic.fullname" $ }}-{{ $service }}
  labels:
    {{- include "petclinic.labels" $ | nindent 4 }}
    app.kubernetes.io/component: {{ $service }}
spec:
  {{- if not $.Values.autoscaling.enabled }}
  replicas: {{ index $.Values.replicaCount $service | default 1 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "petclinic.selectorLabels" $ | nindent 6 }}
      app.kubernetes.io/component: {{ $service }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") $ | sha256sum }}
      labels:
        {{- include "petclinic.selectorLabels" $ | nindent 8 }}
        app.kubernetes.io/component: {{ $service }}
    spec:
      {{- with $.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "petclinic.serviceAccountName" $ }}
      securityContext:
        {{- toYaml $.Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ $service }}
          securityContext:
            {{- toYaml $.Values.securityContext | nindent 12 }}
          image: "{{ $.Values.image.registry }}/spring-petclinic-{{ $service }}:{{ $.Values.image.tag | default $.Chart.AppVersion }}"
          imagePullPolicy: {{ $.Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ index $.Values.service.ports $service }}
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: http
            initialDelaySeconds: 60
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "kubernetes"
            {{- if eq $service "config-server" }}
            - name: CONFIG_SERVER_URL
              value: "http://{{ include "petclinic.fullname" $ }}-config-server:{{ $.Values.service.ports.configServer }}"
            {{- end }}
            {{- if ne $service "config-server" }}
            - name: CONFIG_SERVER_URL
              value: "http://{{ include "petclinic.fullname" $ }}-config-server:{{ $.Values.service.ports.configServer }}"
            - name: DISCOVERY_SERVER_URL
              value: "http://{{ include "petclinic.fullname" $ }}-discovery-server:{{ $.Values.service.ports.discoveryServer }}/eureka"
            {{- end }}
            {{- if has $service (list "customer-service" "vet-service" "visit-service") }}
            - name: DATABASE_URL
              value: {{ include "petclinic.databaseUrl" $ }}
            - name: DATABASE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: {{ include "petclinic.fullname" $ }}-mysql
                  key: username
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "petclinic.fullname" $ }}-mysql
                  key: password
            {{- end }}
          resources:
            {{- toYaml (index $.Values.resources $service) | nindent 12 }}
      {{- with $.Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
```

### **Template Features Explained**

#### **Range Loop**
```yaml
{{- range $service := list "config-server" "discovery-server" ... }}
```
Creates multiple deployments from a single template, reducing code duplication.

#### **Conditional Logic**
```yaml
{{- if eq $service "config-server" }}
# Config server specific configuration
{{- end }}
```
Applies service-specific configuration based on the current service being processed.

#### **Dynamic Value Access**
```yaml
replicas: {{ index $.Values.replicaCount $service | default 1 }}
```
Dynamically accesses values based on the service name with fallback defaults.

#### **Checksum Annotations**
```yaml
annotations:
  checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") $ | sha256sum }}
```
Forces pod restart when ConfigMap changes by including config checksum in pod annotations.

---

## 🚀 **Deployment Strategies**

### **Basic Deployment**
```bash
# Install chart
helm install petclinic ./helm-charts/petclinic

# Install with custom values
helm install petclinic ./helm-charts/petclinic -f values-prod.yaml

# Upgrade deployment
helm upgrade petclinic ./helm-charts/petclinic

# Rollback deployment
helm rollback petclinic 1
```

### **Environment-Specific Deployment**
```bash
# Development environment
helm install petclinic-dev ./helm-charts/petclinic \
  -f values-dev.yaml \
  --namespace petclinic-dev \
  --create-namespace

# Staging environment
helm install petclinic-staging ./helm-charts/petclinic \
  -f values-staging.yaml \
  --namespace petclinic-staging \
  --create-namespace

# Production environment
helm install petclinic-prod ./helm-charts/petclinic \
  -f values-prod.yaml \
  --namespace petclinic-prod \
  --create-namespace
```

### **Blue-Green Deployment**
```bash
# Deploy green version
helm install petclinic-green ./helm-charts/petclinic \
  -f values-prod.yaml \
  --set app.version=green \
  --namespace petclinic-prod

# Switch traffic (update ingress)
helm upgrade petclinic-green ./helm-charts/petclinic \
  -f values-prod.yaml \
  --set ingress.activeVersion=green \
  --namespace petclinic-prod

# Remove blue version
helm uninstall petclinic-blue --namespace petclinic-prod
```

### **Canary Deployment**
```bash
# Deploy canary version (10% traffic)
helm install petclinic-canary ./helm-charts/petclinic \
  -f values-prod.yaml \
  --set app.version=canary \
  --set ingress.canary.enabled=true \
  --set ingress.canary.weight=10 \
  --namespace petclinic-prod
```

---

## 🌍 **Environment Management**

### **Development Values**

**File: `values-dev.yaml`**

```yaml
# Development environment overrides
app:
  environment: development

replicaCount:
  configServer: 1
  discoveryServer: 1
  apiGateway: 1
  customerService: 1
  vetService: 1
  visitService: 1
  adminServer: 1

resources:
  configServer:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "100m"
  # ... similar for other services

ingress:
  enabled: true
  hosts:
    - host: petclinic-dev.example.com
      paths:
        - path: /
          pathType: Prefix
          service: api-gateway

mysql:
  primary:
    persistence:
      size: 5Gi

monitoring:
  prometheus:
    enabled: false
  grafana:
    enabled: false

autoscaling:
  enabled: false
```

### **Production Values**

**File: `values-prod.yaml`**

```yaml
# Production environment overrides
app:
  environment: production

replicaCount:
  configServer: 2
  discoveryServer: 2
  apiGateway: 3
  customerService: 3
  vetService: 2
  visitService: 3
  adminServer: 1

resources:
  apiGateway:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  # ... optimized for other services

ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
  hosts:
    - host: petclinic.example.com
      paths:
        - path: /
          pathType: Prefix
          service: api-gateway
  tls:
    - secretName: petclinic-prod-tls
      hosts:
        - petclinic.example.com

mysql:
  primary:
    persistence:
      size: 100Gi
  metrics:
    enabled: true

monitoring:
  prometheus:
    enabled: true
    retention: "30d"
  grafana:
    enabled: true
    persistence:
      enabled: true
      size: 10Gi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60

podDisruptionBudget:
  enabled: true
  minAvailable: 50%

backup:
  enabled: true
  schedule: "0 2 * * *"
  retention: "90d"
```

---

## 🎯 **Best Practices**

### **Chart Development**
1. **Use semantic versioning** for chart versions
2. **Provide comprehensive default values** in values.yaml
3. **Use template helpers** to reduce code duplication
4. **Include resource limits** for all containers
5. **Implement health checks** for all services
6. **Use ConfigMaps and Secrets** appropriately

### **Values Management**
1. **Separate values files** for different environments
2. **Use descriptive value names** with proper nesting
3. **Provide sensible defaults** for all configurable options
4. **Document all values** with comments
5. **Validate values** using JSON Schema (if available)

### **Security**
1. **Never hardcode secrets** in values files
2. **Use Kubernetes secrets** for sensitive data
3. **Implement RBAC** with minimal required permissions
4. **Enable network policies** for traffic control
5. **Use security contexts** for all pods

### **Testing**
1. **Test chart installation** in clean namespace
2. **Validate generated manifests** with `helm template`
3. **Test upgrades and rollbacks** thoroughly
4. **Use `helm test`** for post-deployment validation
5. **Implement CI/CD** for chart testing

### **Documentation**
1. **Maintain comprehensive README** for each chart
2. **Document all values** and their purposes
3. **Provide deployment examples** for different scenarios
4. **Keep changelog** for chart versions
5. **Include troubleshooting guide**

---

## 🔧 **Troubleshooting**

### **Common Issues and Solutions**

#### **Chart Installation Failures**
```bash
# Debug chart rendering
helm template petclinic ./helm-charts/petclinic --debug

# Validate chart syntax
helm lint ./helm-charts/petclinic

# Check chart dependencies
helm dependency list ./helm-charts/petclinic
```

#### **Value Override Issues**
```bash
# Check effective values
helm get values petclinic

# Debug value precedence
helm template petclinic ./helm-charts/petclinic \
  -f values-prod.yaml \
  --set replicaCount.apiGateway=5 \
  --debug
```

#### **Template Rendering Issues**
```bash
# Render specific template
helm template petclinic ./helm-charts/petclinic \
  --show-only templates/deployment.yaml

# Check for template errors
helm template petclinic ./helm-charts/petclinic --validate
```

#### **Dependency Issues**
```bash
# Update dependencies
helm dependency update ./helm-charts/petclinic

# Check dependency status
helm dependency list ./helm-charts/petclinic

# Build dependency lock
helm dependency build ./helm-charts/petclinic
```

### **Debugging Commands**

#### **Release Management**
```bash
# List releases
helm list -A

# Get release status
helm status petclinic

# Get release history
helm history petclinic

# Get release values
helm get values petclinic

# Get release manifest
helm get manifest petclinic
```

#### **Chart Validation**
```bash
# Lint chart
helm lint ./helm-charts/petclinic

# Test chart installation (dry-run)
helm install petclinic ./helm-charts/petclinic --dry-run

# Validate against Kubernetes API
helm template petclinic ./helm-charts/petclinic --validate
```

### **Performance Optimization**

#### **Chart Optimization**
1. **Minimize template complexity** - Use helpers for repeated logic
2. **Optimize value lookups** - Cache frequently accessed values
3. **Reduce manifest size** - Remove unnecessary fields
4. **Use efficient selectors** - Avoid complex label selectors

#### **Deployment Optimization**
1. **Parallel deployments** - Use `--wait` and `--timeout` appropriately
2. **Resource pre-allocation** - Set appropriate resource requests
3. **Image optimization** - Use specific image tags, not `latest`
4. **Dependency ordering** - Deploy dependencies first

---

## 📚 **Additional Resources**

### **Helm Documentation**
- [Helm Official Documentation](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)

### **Chart Repositories**
- [Artifact Hub](https://artifacthub.io/) - Public chart repository
- [Bitnami Charts](https://github.com/bitnami/charts) - Production-ready charts
- [Prometheus Community](https://github.com/prometheus-community/helm-charts) - Monitoring charts

### **Tools and Utilities**
- [Helmfile](https://github.com/roboll/helmfile) - Declarative Helm deployment
- [Chart Testing](https://github.com/helm/chart-testing) - Automated chart testing
- [Helm Secrets](https://github.com/jkroepke/helm-secrets) - Encrypted values management

---

**Document Maintenance**: This document should be updated whenever Helm charts are modified. All changes should be tested in development environment before production deployment.
