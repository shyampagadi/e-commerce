# 📝 **Module 4: YAML and Configuration Management**
## Essential Configuration Skills for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 2-3 hours  
**Prerequisites**: Basic understanding of text files and data formats  
**Learning Objectives**: Master YAML and configuration management for Kubernetes

### **🛠️ Tools Covered**
- **yq**: YAML processor and query tool
- **jq**: JSON processor and query tool
- **yaml-lint**: YAML syntax validator
- **jsonlint**: JSON syntax validator
- **kubeval**: Kubernetes manifest validator
- **kube-score**: Kubernetes manifest analyzer

### **🏭 Industry Tools**
- **Helm**: Kubernetes package manager and templating
- **Kustomize**: Kubernetes native configuration management
- **Skaffold**: Kubernetes development workflow tool
- **Tanka**: Kubernetes configuration using Jsonnet
- **Jsonnet**: Data templating language for Kubernetes

### **🌍 Environment Strategy**
This module prepares configuration management skills for all environments:
- **DEV**: Development configuration management and templating
- **UAT**: User Acceptance Testing configuration validation
- **PROD**: Production configuration management and deployment

### **💥 Chaos Engineering**
- **Configuration drift testing**: Testing behavior under configuration changes
- **Invalid configuration injection**: Testing error handling with malformed configs
- **Rollback scenarios**: Testing configuration rollback procedures
- **Environment promotion failures**: Testing configuration promotion between environments

### **Chaos Packages**
- **None (manual configuration corruption testing)**: Manual testing with invalid configurations

---

## 🎯 **Learning Objectives**

By the end of this module, you will:
- Master YAML syntax and structure for Kubernetes manifests
- Understand JSON configuration and data processing
- Learn configuration validation and linting techniques
- Master configuration templating and management
- Understand Infrastructure as Code principles
- Apply configuration management to Kubernetes deployments
- Implement chaos engineering scenarios for configuration resilience

---

## 📚 **Theory Section: Configuration Management**

### **Why Configuration Management for Kubernetes?**

Kubernetes is a declarative system that relies heavily on configuration files for:
- **Resource Definition**: Pods, Services, Deployments defined in YAML
- **Environment Management**: Different configurations for DEV/UAT/PROD
- **Version Control**: Configuration changes tracked in Git
- **Automation**: Infrastructure as Code principles
- **Consistency**: Standardized deployment across environments

### **YAML vs JSON vs Other Formats**

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Formats                    │
├─────────────────────────────────────────────────────────────┤
│  YAML (Human-readable, Kubernetes standard)                │
│  JSON (Machine-readable, API communication)                │
│  TOML (Simple, configuration files)                        │
│  INI (Basic, legacy systems)                               │
└─────────────────────────────────────────────────────────────┘
```

### **Essential Configuration Concepts**

#### **1. YAML Structure**
- **Indentation**: Spaces (not tabs) for structure
- **Key-Value Pairs**: Simple data mapping
- **Lists**: Ordered collections
- **Nested Objects**: Hierarchical data structures
- **Comments**: Documentation and notes

#### **2. Data Types**
- **Strings**: Text data with optional quoting
- **Numbers**: Integers and floating-point numbers
- **Booleans**: true/false values
- **Null**: Empty or undefined values
- **Dates**: ISO 8601 date format

#### **3. Advanced Features**
- **Anchors and Aliases**: Reusable configuration blocks
- **Multi-line Strings**: Preserve formatting
- **Environment Variables**: Dynamic value injection
- **Conditional Logic**: Template-based configuration

#### **4. Validation and Linting**
- **Syntax Validation**: Ensure valid YAML/JSON structure
- **Schema Validation**: Validate against Kubernetes schemas
- **Best Practices**: Follow configuration best practices
- **Security Scanning**: Check for security issues

---

## 🔧 **Hands-on Lab: YAML and Configuration Management**

### **Lab 1: YAML Fundamentals**

**📋 Overview**: Master YAML syntax and structure for Kubernetes manifests.

**🔍 Detailed YAML Analysis**:

```yaml
# Basic YAML structure for Kubernetes Pod
apiVersion: v1
kind: Pod
metadata:
  name: ecommerce-backend
  labels:
    app: ecommerce
    tier: backend
    environment: development
```

**Explanation**:
- `apiVersion: v1`: Kubernetes API version
- `kind: Pod`: Resource type (Pod, Service, Deployment, etc.)
- `metadata:`: Object metadata section
  - `name: ecommerce-backend`: Resource name
  - `labels:`: Key-value pairs for resource identification
- **Purpose**: Define a basic Kubernetes Pod resource

```yaml
# Advanced YAML with nested structures
spec:
  containers:
  - name: backend
    image: ecommerce-backend:latest
    ports:
    - containerPort: 8000
      protocol: TCP
    env:
    - name: DATABASE_URL
      value: "postgresql://postgres:admin@localhost:5432/ecommerce_db"
    - name: DEBUG
      value: "true"
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

**Explanation**:
- `spec:`: Specification section defining desired state
- `containers:`: List of containers in the pod
- `- name: backend`: Container name (list item)
- `image: ecommerce-backend:latest`: Container image
- `ports:`: Container port configuration
- `env:`: Environment variables
- `resources:`: Resource requests and limits
- **Purpose**: Define container specifications with resources and environment

### **Lab 2: JSON Configuration and Processing**

**📋 Overview**: Learn JSON configuration and data processing tools.

**🔍 Detailed JSON Analysis**:

```json
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "ecommerce-backend-service",
    "labels": {
      "app": "ecommerce",
      "tier": "backend"
    }
  },
  "spec": {
    "selector": {
      "app": "ecommerce",
      "tier": "backend"
    },
    "ports": [
      {
        "port": 80,
        "targetPort": 8000,
        "protocol": "TCP"
      }
    ],
    "type": "ClusterIP"
  }
}
```

**Explanation**:
- `{}`: JSON object structure
- `[]`: JSON array structure
- `"key": "value"`: Key-value pairs
- **Purpose**: Define Kubernetes Service in JSON format

```bash
# Process JSON with jq
echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.name'
echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.version'
```

**Explanation**:
- `jq '.name'`: Extract name field from JSON
- `jq '.version'`: Extract version field from JSON
- **Purpose**: Process and query JSON data

```bash
# Convert between YAML and JSON
yq eval -o=json ecommerce-pod.yaml
jq -r . ecommerce-service.json | yq eval -P -
```

**Explanation**:
- `yq eval -o=json`: Convert YAML to JSON
- `jq -r . | yq eval -P -`: Convert JSON to YAML
- **Purpose**: Convert between configuration formats

### **Lab 3: Configuration Validation and Linting**

**📋 Overview**: Master configuration validation and linting techniques.

**🔍 Detailed Validation Analysis**:

```bash
# Validate YAML syntax
yaml-lint ecommerce-pod.yaml
```

**Explanation**:
- `yaml-lint`: Validate YAML syntax
- **Purpose**: Check for YAML syntax errors

```bash
# Validate Kubernetes manifests
kubeval ecommerce-pod.yaml
kubeval ecommerce-service.yaml
```

**Explanation**:
- `kubeval`: Validate Kubernetes manifests against schemas
- **Purpose**: Ensure manifests conform to Kubernetes API

```bash
# Analyze Kubernetes manifests
kube-score score ecommerce-pod.yaml
kube-score score ecommerce-service.yaml
```

**Explanation**:
- `kube-score score`: Analyze manifests for best practices
- **Purpose**: Check for security and best practice issues

```bash
# Validate JSON syntax
jsonlint ecommerce-config.json
```

**Explanation**:
- `jsonlint`: Validate JSON syntax
- **Purpose**: Check for JSON syntax errors

### **Lab 4: Configuration Templating and Management**

**📋 Overview**: Learn configuration templating and management techniques.

**🔍 Detailed Templating Analysis**:

```yaml
# Template with environment variables
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend-${ENVIRONMENT}
  labels:
    app: ecommerce
    environment: ${ENVIRONMENT}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: ecommerce
      environment: ${ENVIRONMENT}
  template:
    metadata:
      labels:
        app: ecommerce
        environment: ${ENVIRONMENT}
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:${VERSION}
        env:
        - name: ENVIRONMENT
          value: ${ENVIRONMENT}
        - name: DATABASE_URL
          value: ${DATABASE_URL}
```

**Explanation**:
- `${ENVIRONMENT}`: Environment variable substitution
- `${REPLICAS}`: Dynamic replica count
- `${VERSION}`: Dynamic image version
- **Purpose**: Create reusable templates with variable substitution

```bash
# Process template with environment variables
export ENVIRONMENT=development
export REPLICAS=2
export VERSION=1.0.0
export DATABASE_URL="postgresql://postgres:admin@localhost:5432/ecommerce_db"

envsubst < ecommerce-deployment-template.yaml > ecommerce-deployment-dev.yaml
```

**Explanation**:
- `export ENVIRONMENT=development`: Set environment variable
- `envsubst`: Substitute environment variables in template
- **Purpose**: Generate environment-specific configurations

```bash
# Use yq for advanced templating
yq eval '.spec.replicas = 3' ecommerce-deployment.yaml
yq eval '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"' ecommerce-deployment.yaml
```

**Explanation**:
- `yq eval '.spec.replicas = 3'`: Modify specific field
- `yq eval '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"'`: Update image version
- **Purpose**: Programmatically modify configuration files

### **Lab 5: Infrastructure as Code Principles**

**📋 Overview**: Apply Infrastructure as Code principles to configuration management.

**🔍 Detailed IaC Analysis**:

```yaml
# Infrastructure as Code structure
# ecommerce-infrastructure/
# ├── base/
# │   ├── namespace.yaml
# │   ├── configmap.yaml
# │   └── secret.yaml
# ├── overlays/
# │   ├── development/
# │   │   ├── kustomization.yaml
# │   │   └── deployment.yaml
# │   ├── staging/
# │   │   ├── kustomization.yaml
# │   │   └── deployment.yaml
# │   └── production/
# │       ├── kustomization.yaml
# │       └── deployment.yaml
```

**Explanation**:
- `base/`: Common configuration shared across environments
- `overlays/`: Environment-specific configurations
- `kustomization.yaml`: Kustomize configuration files
- **Purpose**: Organize configuration using Infrastructure as Code principles

```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- namespace.yaml
- configmap.yaml
- secret.yaml
- deployment.yaml
- service.yaml

commonLabels:
  app: ecommerce
  managed-by: kustomize
```

**Explanation**:
- `resources:`: List of base resources
- `commonLabels:`: Labels applied to all resources
- **Purpose**: Define base configuration for all environments

```yaml
# overlays/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- deployment.yaml

namePrefix: dev-
namespace: ecommerce-dev

commonLabels:
  environment: development
```

**Explanation**:
- `bases:`: Reference to base configuration
- `patchesStrategicMerge:`: Environment-specific patches
- `namePrefix: dev-`: Prefix for resource names
- `namespace: ecommerce-dev`: Target namespace
- **Purpose**: Customize base configuration for development environment

```bash
# Build configuration for specific environment
kustomize build overlays/development
kustomize build overlays/staging
kustomize build overlays/production
```

**Explanation**:
- `kustomize build`: Generate final configuration for environment
- **Purpose**: Create environment-specific configurations from base and overlays

---

## 🎯 **Practice Problems**

### **Problem 1: YAML Configuration Creation**

**Scenario**: Create Kubernetes manifests for your e-commerce application.

**Requirements**:
1. Create Pod manifest for backend service
2. Create Service manifest for backend
3. Create Deployment manifest with 3 replicas
4. Create ConfigMap for application configuration

**Expected Output**:
- Complete Kubernetes manifests in YAML format
- Validated configurations
- Environment-specific configurations

### **Problem 2: Configuration Validation and Linting**

**Scenario**: Validate and improve your Kubernetes configurations.

**Requirements**:
1. Validate YAML syntax
2. Check Kubernetes API compliance
3. Analyze for best practices
4. Fix security issues

**Expected Output**:
- Validation reports
- Best practice recommendations
- Security issue fixes
- Improved configurations

### **Problem 3: Configuration Templating**

**Scenario**: Create reusable configuration templates for multiple environments.

**Requirements**:
1. Create base configuration templates
2. Implement environment variable substitution
3. Generate environment-specific configurations
4. Test configuration generation

**Expected Output**:
- Configuration templates
- Environment-specific configurations
- Template processing scripts
- Validation of generated configurations

### **Problem 4: Chaos Engineering Scenarios**

**Scenario**: Test your e-commerce application's configuration resilience.

**Requirements**:
1. **Configuration Drift Testing**:
   - Simulate configuration changes
   - Test application behavior under configuration drift
   - Monitor recovery mechanisms

2. **Invalid Configuration Injection**:
   - Inject malformed configurations
   - Test error handling with invalid configs
   - Monitor application resilience

3. **Rollback Scenarios**:
   - Test configuration rollback procedures
   - Simulate rollback failures
   - Monitor recovery time

4. **Environment Promotion Failures**:
   - Test configuration promotion between environments
   - Simulate promotion failures
   - Monitor environment consistency

**Expected Output**:
- Configuration chaos engineering test results
- Failure mode analysis
- Recovery time measurements
- Configuration resilience recommendations

---

## 📝 **Assessment Quiz**

### **Multiple Choice Questions**

1. **What is the correct YAML indentation?**
   - A) Tabs
   - B) Spaces
   - C) Either tabs or spaces
   - D) No indentation needed

2. **Which tool validates Kubernetes manifests?**
   - A) yaml-lint
   - B) kubeval
   - C) jsonlint
   - D) All of the above

3. **What is the purpose of Kustomize?**
   - A) YAML syntax validation
   - B) Kubernetes native configuration management
   - C) JSON processing
   - D) Template processing

### **Practical Questions**

4. **Explain the difference between YAML and JSON formats.**

5. **How would you create environment-specific configurations?**

6. **What are the benefits of Infrastructure as Code?**

---

## 🚀 **Mini-Project: E-commerce Configuration Management**

### **Project Requirements**

Implement comprehensive configuration management for your e-commerce application:

1. **Configuration Structure**
   - Design configuration hierarchy
   - Create base configurations
   - Implement environment overlays
   - Set up configuration validation

2. **Templating and Automation**
   - Create configuration templates
   - Implement environment variable substitution
   - Set up automated configuration generation
   - Test configuration deployment

3. **Validation and Quality**
   - Implement configuration validation
   - Set up linting and best practice checks
   - Create security scanning
   - Implement configuration testing

4. **Chaos Engineering Implementation**
   - Design configuration failure scenarios
   - Implement resilience testing
   - Create monitoring and alerting
   - Document failure modes and recovery procedures

### **Deliverables**

- **Configuration Structure**: Complete configuration hierarchy
- **Templating System**: Reusable configuration templates
- **Validation Pipeline**: Automated configuration validation
- **Chaos Engineering Report**: Configuration resilience testing results
- **Documentation**: Complete configuration management guide

---

## 🎤 **Interview Questions and Answers**

### **Q1: How would you manage configurations across multiple environments?**

**Answer**:
Comprehensive configuration management approach:

1. **Configuration Hierarchy**:
```yaml
# base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- namespace.yaml
- configmap.yaml
- deployment.yaml
- service.yaml

commonLabels:
  app: ecommerce
  managed-by: kustomize
```

2. **Environment Overlays**:
```yaml
# overlays/development/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
- ../../base

patchesStrategicMerge:
- deployment.yaml

namePrefix: dev-
namespace: ecommerce-dev

commonLabels:
  environment: development
```

3. **Configuration Generation**:
```bash
# Generate configurations for each environment
kustomize build overlays/development > dev-config.yaml
kustomize build overlays/staging > staging-config.yaml
kustomize build overlays/production > prod-config.yaml
```

4. **Validation and Deployment**:
```bash
# Validate configurations
kubeval dev-config.yaml
kube-score score dev-config.yaml

# Deploy configurations
kubectl apply -f dev-config.yaml
```

**Best Practices**:
- **Base Configuration**: Common settings shared across environments
- **Environment Overlays**: Environment-specific customizations
- **Validation**: Automated validation before deployment
- **Version Control**: Track configuration changes in Git
- **Secrets Management**: Use external secret management systems

### **Q2: How would you validate Kubernetes configurations?**

**Answer**:
Multi-layered validation approach:

1. **Syntax Validation**:
```bash
# Validate YAML syntax
yaml-lint ecommerce-pod.yaml
jsonlint ecommerce-config.json
```

2. **Kubernetes API Validation**:
```bash
# Validate against Kubernetes schemas
kubeval ecommerce-pod.yaml
kubectl apply --dry-run=client -f ecommerce-pod.yaml
```

3. **Best Practice Analysis**:
```bash
# Analyze for best practices
kube-score score ecommerce-pod.yaml
kube-score score ecommerce-service.yaml
```

4. **Security Scanning**:
```bash
# Check for security issues
kube-score score ecommerce-pod.yaml --ignore-container-cpu-limit
kube-score score ecommerce-pod.yaml --ignore-container-memory-limit
```

5. **Custom Validation**:
```bash
# Custom validation scripts
./validate-config.sh ecommerce-pod.yaml
./check-resources.sh ecommerce-deployment.yaml
```

**Validation Pipeline**:
- **Pre-commit Hooks**: Validate before committing
- **CI/CD Integration**: Automated validation in pipeline
- **Manual Review**: Human review for complex changes
- **Production Validation**: Final validation before production deployment

### **Q3: How would you implement configuration templating?**

**Answer**:
Comprehensive templating implementation:

1. **Environment Variable Substitution**:
```yaml
# Template with variables
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend-${ENVIRONMENT}
spec:
  replicas: ${REPLICAS}
  template:
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:${VERSION}
        env:
        - name: ENVIRONMENT
          value: ${ENVIRONMENT}
```

2. **Template Processing**:
```bash
# Set environment variables
export ENVIRONMENT=development
export REPLICAS=2
export VERSION=1.0.0

# Process template
envsubst < deployment-template.yaml > deployment-dev.yaml
```

3. **Advanced Templating with yq**:
```bash
# Modify specific fields
yq eval '.spec.replicas = 3' deployment.yaml
yq eval '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"' deployment.yaml
```

4. **Helm Templating**:
```yaml
# Helm template
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}-{{ .Values.environment }}
spec:
  replicas: {{ .Values.replicas }}
  template:
    spec:
      containers:
      - name: backend
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
```

5. **Template Validation**:
```bash
# Validate generated configurations
kubeval deployment-dev.yaml
kube-score score deployment-dev.yaml
```

**Templating Best Practices**:
- **Variable Naming**: Use clear, descriptive variable names
- **Default Values**: Provide sensible defaults
- **Validation**: Validate generated configurations
- **Documentation**: Document template variables and usage
- **Testing**: Test templates with different variable values

---

## 📈 **Real-world Scenarios**

### **Scenario 1: Multi-Environment Configuration Management**

**Challenge**: Manage configurations for DEV, UAT, and PROD environments with different requirements.

**Requirements**:
- Create base configuration
- Implement environment-specific overlays
- Set up automated validation
- Implement configuration promotion

**Solution Approach**:
1. Design configuration hierarchy with base and overlays
2. Implement Kustomize for configuration management
3. Set up automated validation pipeline
4. Create configuration promotion workflow

### **Scenario 2: Configuration Security and Compliance**

**Challenge**: Implement secure configuration management with compliance requirements.

**Requirements**:
- Secure secret management
- Configuration encryption
- Audit trail for changes
- Compliance validation

**Solution Approach**:
1. Implement external secret management
2. Use encrypted configuration storage
3. Set up configuration change tracking
4. Implement compliance validation checks

---

## 🎯 **Module Completion Checklist**

### **Core Configuration Concepts**
- [ ] Master YAML syntax and structure
- [ ] Understand JSON configuration
- [ ] Learn configuration validation
- [ ] Master configuration templating
- [ ] Understand Infrastructure as Code principles

### **Configuration Tools**
- [ ] Use YAML processing tools (yq)
- [ ] Master JSON processing tools (jq)
- [ ] Configure validation tools (kubeval, kube-score)
- [ ] Use linting tools (yaml-lint, jsonlint)
- [ ] Implement templating systems

### **Configuration Management**
- [ ] Design configuration hierarchy
- [ ] Implement environment management
- [ ] Set up configuration validation
- [ ] Create templating systems
- [ ] Implement Infrastructure as Code

### **Chaos Engineering**
- [ ] Implement configuration drift testing
- [ ] Test invalid configuration injection
- [ ] Simulate rollback scenarios
- [ ] Test environment promotion failures
- [ ] Document configuration failure modes and recovery procedures

### **Assessment and Practice**
- [ ] Complete all practice problems
- [ ] Pass assessment quiz
- [ ] Complete mini-project
- [ ] Answer interview questions correctly
- [ ] Apply concepts to real-world scenarios

---

## 📚 **Additional Resources**

### **Documentation**
- [YAML Specification](https://yaml.org/spec/1.2/spec.html)
- [JSON Specification](https://www.json.org/json-en.html)
- [Kustomize Documentation](https://kustomize.io/)
- [Helm Documentation](https://helm.sh/docs/)

### **Tools**
- [yq YAML Processor](https://github.com/mikefarah/yq)
- [jq JSON Processor](https://stedolan.github.io/jq/)
- [kubeval Validator](https://github.com/instrumenta/kubeval)
- [kube-score Analyzer](https://github.com/zegl/kube-score)

### **Practice Platforms**
- [Kubernetes Configuration Examples](https://kubernetes.io/docs/concepts/configuration/)
- [Kustomize Examples](https://github.com/kubernetes-sigs/kustomize/tree/master/examples)
- [Helm Charts](https://helm.sh/docs/topics/charts/)

---

## 🚀 **Next Steps**

1. **Complete this module** by working through all labs and assessments
2. **Practice YAML and JSON** configuration creation
3. **Set up configuration validation** for your e-commerce application
4. **Move to Module 5**: Initial Monitoring Setup (Prometheus & Grafana)
5. **Prepare for Kubernetes** by understanding configuration management

---

**Congratulations! You've completed the YAML and Configuration Management module. You now have essential configuration skills for Kubernetes administration. 🎉**
