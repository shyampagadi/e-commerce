# 📝 **Module 4: YAML and Configuration Management**
## Essential Configuration Skills for Kubernetes

---

## 📋 **Module Overview**

**Duration**: 4-5 hours (enhanced with complete foundational knowledge)  
**Prerequisites**: See detailed prerequisites below  
**Learning Objectives**: Master YAML and configuration management for Kubernetes with complete foundational knowledge

---

## 🎯 **Detailed Prerequisites**

### **🔧 Technical Prerequisites**

#### **System Requirements**
- **OS**: Linux distribution (Ubuntu 20.04+ recommended), macOS 10.15+, or Windows 10+ with WSL2
- **RAM**: Minimum 2GB (4GB recommended for configuration processing)
- **CPU**: 2+ cores (4+ cores recommended for large configuration files)
- **Storage**: 10GB+ free space (20GB+ for configuration files and validation tools)
- **Network**: Internet connection for downloading tools and templates

#### **Software Requirements**
- **YAML Processor**: yq for YAML manipulation and querying
  ```bash
# =============================================================================
# YQ INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
# Purpose: Download yq YAML processor binary from GitHub releases
# Flags: -q (quiet), -O (output to file)
# Usage: sudo wget -qO /usr/local/bin/yq [URL]
# Output: Downloads yq binary to /usr/local/bin/yq
# Examples: Used for installing YAML processing tools
# Notes: Requires sudo for system-wide installation

# Command: sudo chmod +x /usr/local/bin/yq
# Purpose: Make yq binary executable
# Flags: +x (add execute permission)
# Usage: sudo chmod +x /usr/local/bin/yq
# Output: Makes yq executable for all users
# Examples: Required after downloading binaries
# Notes: Essential for running downloaded executables

# Command: yq --version
# Purpose: Display yq version information
# Flags: --version (show version)
# Usage: yq --version
# Output: yq version 4.x.x
# Examples: Used for tool verification
# Notes: Confirms successful installation

# Install yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq
# Verify installation
yq --version
```
- **JSON Processor**: jq for JSON manipulation and querying
  ```bash
# =============================================================================
# JQ INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo apt-get update && sudo apt-get install -y jq
# Purpose: Update package list and install jq JSON processor
# Flags: update (refresh package list), install -y (auto-confirm installation)
# Usage: sudo apt-get update && sudo apt-get install -y jq
# Output: Installs jq package from repositories
# Examples: Standard package installation command
# Notes: && ensures update runs before install

# Command: jq --version
# Purpose: Display jq version information
# Flags: --version (show version)
# Usage: jq --version
# Output: jq-1.6
# Examples: Used for tool verification
# Notes: Confirms successful installation

  # Install jq
  sudo apt-get update && sudo apt-get install -y jq
  # Verify installation
  jq --version
  ```
- **Python**: Version 3.6+ for YAML processing and validation
  ```bash
# =============================================================================
# PYTHON INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo apt-get install -y python3 python3-pip
# Purpose: Install Python 3 and pip package manager
# Flags: install -y (auto-confirm installation)
# Usage: sudo apt-get install -y python3 python3-pip
# Output: Installs Python 3 and pip from repositories
# Examples: Standard Python installation command
# Notes: pip3 is Python package installer

# Command: python3 --version
# Purpose: Display Python 3 version information
# Flags: --version (show version)
# Usage: python3 --version
# Output: Python 3.8.10
# Examples: Used for tool verification
# Notes: Confirms successful Python installation

# Command: pip3 --version
# Purpose: Display pip3 version information
# Flags: --version (show version)
# Usage: pip3 --version
# Output: pip 20.0.2 from /usr/lib/python3/dist-packages/pip
# Examples: Used for tool verification
# Notes: Confirms successful pip installation

  # Install Python and pip
  sudo apt-get install -y python3 python3-pip
  # Verify installation
  python3 --version
  pip3 --version
  ```

#### **Package Dependencies**
- **YAML Libraries**: PyYAML for Python YAML processing
  ```bash
# =============================================================================
# PYYAML INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: pip3 install PyYAML
# Purpose: Install PyYAML library for Python YAML processing
# Flags: install (install package)
# Usage: pip3 install PyYAML
# Output: Downloads and installs PyYAML package
# Examples: Standard pip package installation
# Notes: Required for Python YAML processing

# Command: python3 -c "import yaml; print('PyYAML installed successfully')"
# Purpose: Test PyYAML installation by importing and printing success message
# Flags: -c (execute command string)
# Usage: python3 -c "import yaml; print('PyYAML installed successfully')"
# Output: PyYAML installed successfully
# Examples: Used for library verification
# Notes: Confirms successful PyYAML installation

  # Install PyYAML
  pip3 install PyYAML
  # Verify installation
  python3 -c "import yaml; print('PyYAML installed successfully')"
  ```
- **Validation Tools**: yaml-lint, jsonlint for syntax validation
  ```bash
# =============================================================================
# VALIDATION TOOLS INSTALLATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: sudo apt-get install -y yamllint
# Purpose: Install yamllint YAML syntax validator
# Flags: install -y (auto-confirm installation)
# Usage: sudo apt-get install -y yamllint
# Output: Installs yamllint from repositories
# Examples: Standard package installation
# Notes: Essential for YAML validation

# Command: pip3 install jsonlint
# Purpose: Install jsonlint JSON syntax validator
# Flags: install (install package)
# Usage: pip3 install jsonlint
# Output: Downloads and installs jsonlint package
# Examples: Standard pip package installation
# Notes: Required for JSON validation

# Command: yamllint --version
# Purpose: Display yamllint version information
# Flags: --version (show version)
# Usage: yamllint --version
# Output: yamllint 1.26.3
# Examples: Used for tool verification
# Notes: Confirms successful yamllint installation

# Command: jsonlint --version
# Purpose: Display jsonlint version information
# Flags: --version (show version)
# Usage: jsonlint --version
# Output: jsonlint 1.6.3
# Examples: Used for tool verification
# Notes: Confirms successful jsonlint installation

  # Install validation tools
  sudo apt-get install -y yamllint
  pip3 install jsonlint
  # Verify installation
  yamllint --version
  jsonlint --version
  ```
- **Kubernetes Tools**: kubectl, kubeval, kube-score for Kubernetes manifest validation
  ```bash
# =============================================================================
# KUBECTL INSTALLATION COMMANDS - TIER 3 DOCUMENTATION
# =============================================================================

# Command: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# Purpose: Download latest stable kubectl binary from Kubernetes releases
# Flags: -L (follow redirects), -O (output to file)
# Usage: curl -LO [URL]
# Output: Downloads kubectl binary to current directory
# Examples: Used for installing Kubernetes CLI tools
# Notes: Nested curl command gets latest stable version URL

# Command: sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Purpose: Install kubectl binary with proper permissions
# Flags: -o root (set owner), -g root (set group), -m 0755 (set permissions)
# Usage: sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Output: Installs kubectl to /usr/local/bin/kubectl
# Examples: Standard binary installation with permissions
# Notes: 0755 gives owner read/write/execute, group/others read/execute

# Command: kubectl version --client
# Purpose: Display kubectl client version information
# Flags: --client (show only client version)
# Usage: kubectl version --client
# Output: Client Version: version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.0"}
# Examples: Used for tool verification
# Notes: Confirms successful kubectl installation

  # Install kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  # Verify installation
  kubectl version --client
  ```

#### **Network Requirements**
- **Internet Access**: For downloading tools, templates, and validation resources
- **Kubernetes API Access**: For kubectl validation and testing (optional)
  ```bash
# =============================================================================
# KUBECTL CONNECTIVITY TEST COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubectl cluster-info
# Purpose: Display cluster information and endpoints
# Flags: None (default command)
# Usage: kubectl cluster-info
# Output: Shows cluster master URL and services
# Examples: Used for cluster connectivity testing
# Notes: Requires active cluster connection

# Command: kubectl get nodes
# Purpose: List all nodes in the cluster
# Flags: get (retrieve resources), nodes (node resource type)
# Usage: kubectl get nodes
# Output: Lists cluster nodes with status
# Examples: Used for cluster verification
# Notes: Confirms cluster is accessible and nodes are running

  # Test kubectl connectivity (if cluster available)
  kubectl cluster-info
  kubectl get nodes
  ```

### **📖 Knowledge Prerequisites**

#### **Required Module Completion**
- **Module 0**: Essential Linux Commands - File operations, process management, text processing, system navigation
- **Module 1**: Container Fundamentals - Docker basics, container lifecycle, virtualization concepts
- **Module 2**: Linux System Administration - System monitoring, process management, file systems, network configuration
- **Module 3**: Networking Fundamentals - Network protocols, DNS, firewall configuration, network troubleshooting

#### **Concepts to Master**
- **Data Formats**: Understanding of JSON, XML, and other structured data formats
- **Configuration Management**: Understanding of infrastructure as code and configuration management
- **YAML Syntax**: Understanding of YAML structure, indentation, and data types
- **Kubernetes Basics**: Basic understanding of Kubernetes resources and manifests
- **Version Control**: Understanding of Git and version control concepts

#### **Skills Required**
- **Linux Command Line**: Advanced proficiency with Linux commands from previous modules
- **Text Editing**: Proficiency with text editors for creating and editing configuration files
- **File System Navigation**: Understanding of file system operations and directory structures
- **Data Processing**: Basic understanding of data manipulation and processing
- **Validation**: Understanding of configuration validation and error checking

#### **Industry Knowledge**
- **Infrastructure as Code**: Understanding of IaC principles and practices
- **Configuration Management**: Understanding of configuration management tools and practices
- **DevOps Practices**: Understanding of DevOps workflows and automation
- **Cloud Computing**: Basic understanding of cloud services and configurations

### **🛠️ Environment Prerequisites**

#### **Development Environment**
- **Text Editor**: VS Code, Vim, or Nano with YAML and JSON support
- **Terminal**: Bash shell with configuration management tools
- **IDE Extensions**: YAML and JSON extensions for VS Code (recommended)
  ```bash
  # Install VS Code extensions (if using VS Code)
  code --install-extension redhat.vscode-yaml
  code --install-extension ms-vscode.vscode-json
  code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
  ```

#### **Testing Environment**
- **Configuration Files**: Access to sample configuration files for practice
  ```bash
  # Create test configuration files
  mkdir -p ~/config-practice
  cd ~/config-practice
  echo "test: value" > test.yaml
  echo '{"test": "value"}' > test.json
  ```
- **Validation Tools**: Access to configuration validation and testing tools
  ```bash
  # Test YAML validation
  yamllint test.yaml
  yq eval test.yaml
  ```
- **Kubernetes Environment**: Access to Kubernetes cluster for manifest testing (optional)
  ```bash
  # Test Kubernetes manifest validation
  kubectl apply --dry-run=client -f test.yaml
  ```

#### **Production Environment**
- **Version Control**: Understanding of Git and version control best practices
- **Configuration Management**: Understanding of configuration management workflows
- **Validation Pipelines**: Understanding of automated validation and testing
- **Security**: Understanding of configuration security and secrets management

### **📋 Validation Prerequisites**

#### **Pre-Module Assessment**
```bash
# =============================================================================
# PREREQUISITE VALIDATION COMMANDS - TIER 1/2 DOCUMENTATION
# =============================================================================

# Command: yq --version
# Purpose: Display yq version information
# Flags: --version (show version)
# Usage: yq --version
# Output: yq version 4.x.x
# Notes: Part of tool verification checklist

# Command: jq --version
# Purpose: Display jq version information
# Flags: --version (show version)
# Usage: jq --version
# Output: jq-1.6
# Notes: Part of tool verification checklist

# Command: yamllint --version
# Purpose: Display yamllint version information
# Flags: --version (show version)
# Usage: yamllint --version
# Output: yamllint 1.26.3
# Notes: Part of tool verification checklist

# Command: jsonlint --version
# Purpose: Display jsonlint version information
# Flags: --version (show version)
# Usage: jsonlint --version
# Output: jsonlint 1.6.3
# Notes: Part of tool verification checklist

# Command: python3 --version
# Purpose: Display Python 3 version information
# Flags: --version (show version)
# Usage: python3 --version
# Output: Python 3.8.10
# Notes: Part of tool verification checklist

# Command: pip3 --version
# Purpose: Display pip3 version information
# Flags: --version (show version)
# Usage: pip3 --version
# Output: pip 20.0.2 from /usr/lib/python3/dist-packages/pip
# Notes: Part of tool verification checklist

# Command: python3 -c "import yaml; print('PyYAML available')"
# Purpose: Test PyYAML library availability
# Flags: -c (execute command string)
# Usage: python3 -c "import yaml; print('PyYAML available')"
# Output: PyYAML available
# Notes: Confirms PyYAML library is installed

# Command: python3 -c "import json; print('JSON available')"
# Purpose: Test JSON library availability
# Flags: -c (execute command string)
# Usage: python3 -c "import json; print('JSON available')"
# Output: JSON available
# Notes: Confirms JSON library is available

# Command: kubectl version --client
# Purpose: Display kubectl client version information
# Flags: --client (show only client version)
# Usage: kubectl version --client
# Output: Client Version: version.Info{Major:"1", Minor:"28", GitVersion:"v1.28.0"}
# Notes: Part of tool verification checklist

# Command: kubeval --version 2>/dev/null || echo "kubeval not installed"
# Purpose: Check kubeval availability with fallback message
# Flags: --version (show version), 2>/dev/null (suppress errors), || (fallback)
# Usage: kubeval --version 2>/dev/null || echo "kubeval not installed"
# Output: kubeval version or "kubeval not installed"
# Notes: Graceful handling of optional tool

# Command: kube-score version 2>/dev/null || echo "kube-score not installed"
# Purpose: Check kube-score availability with fallback message
# Flags: version (show version), 2>/dev/null (suppress errors), || (fallback)
# Usage: kube-score version 2>/dev/null || echo "kube-score not installed"
# Output: kube-score version or "kube-score not installed"
# Notes: Graceful handling of optional tool

# Command: which nano vim code
# Purpose: Check availability of text editors
# Flags: which (locate command)
# Usage: which nano vim code
# Output: Paths to available editors
# Notes: At least one should be available

# Command: ls -la
# Purpose: List files with detailed information
# Flags: -l (long format), -a (all files including hidden)
# Usage: ls -la
# Output: Detailed file listing with permissions
# Notes: Part of file system verification

# Command: mkdir test-dir
# Purpose: Create test directory
# Flags: mkdir (create directory)
# Usage: mkdir test-dir
# Output: Creates test-dir directory
# Notes: Part of file system verification

# Command: rmdir test-dir
# Purpose: Remove empty test directory
# Flags: rmdir (remove directory)
# Usage: rmdir test-dir
# Output: Removes test-dir directory
# Notes: Part of file system verification

# 1. Verify YAML and JSON tools
yq --version
jq --version
yamllint --version
jsonlint --version

# 2. Verify Python and libraries
python3 --version
pip3 --version
python3 -c "import yaml; print('PyYAML available')"
python3 -c "import json; print('JSON available')"

# 3. Verify Kubernetes tools
kubectl version --client
kubeval --version 2>/dev/null || echo "kubeval not installed"
kube-score version 2>/dev/null || echo "kube-score not installed"

# 4. Verify text editing capabilities
which nano vim code
# At least one should be available

# 5. Verify file system operations
ls -la
mkdir test-dir
rmdir test-dir
```

#### **Setup Validation Commands**
```bash
# =============================================================================
# SETUP VALIDATION COMMANDS - TIER 2/3 DOCUMENTATION
# =============================================================================

# Command: mkdir -p ~/config-practice
# Purpose: Create configuration practice directory with parent directories
# Flags: -p (create parent directories as needed)
# Usage: mkdir -p ~/config-practice
# Output: Creates ~/config-practice directory
# Examples: Used for setting up practice environment
# Notes: -p flag creates directory structure if it doesn't exist

# Command: cd ~/config-practice
# Purpose: Change to configuration practice directory
# Flags: cd (change directory)
# Usage: cd ~/config-practice
# Output: Changes current directory to ~/config-practice
# Examples: Used for navigating to practice directory
# Notes: Essential for working in practice environment

# Command: cat > test.yaml <<EOF
# Purpose: Create test YAML file using here document
# Flags: > (redirect output), <<EOF (here document)
# Usage: cat > test.yaml <<EOF
# Output: Creates test.yaml file with YAML content
# Examples: Used for creating test configuration files
# Notes: Here document allows multi-line input

# Command: yamllint test.yaml
# Purpose: Validate YAML syntax in test file
# Flags: yamllint (YAML linter)
# Usage: yamllint test.yaml
# Output: YAML validation results or no output if valid
# Examples: Used for YAML syntax validation
# Notes: Essential for YAML quality assurance

# Command: yq eval test.yaml
# Purpose: Process and display YAML file content
# Flags: eval (evaluate YAML)
# Usage: yq eval test.yaml
# Output: Displays processed YAML content
# Examples: Used for YAML processing verification
# Notes: Confirms yq can process the YAML file

# Command: cat > test.json <<EOF
# Purpose: Create test JSON file using here document
# Flags: > (redirect output), <<EOF (here document)
# Usage: cat > test.json <<EOF
# Output: Creates test.json file with JSON content
# Examples: Used for creating test configuration files
# Notes: Here document allows multi-line input

# Command: jsonlint test.json
# Purpose: Validate JSON syntax in test file
# Flags: jsonlint (JSON linter)
# Usage: jsonlint test.json
# Output: JSON validation results or no output if valid
# Examples: Used for JSON syntax validation
# Notes: Essential for JSON quality assurance

# Command: jq . test.json
# Purpose: Process and display JSON file content
# Flags: . (process entire JSON), jq (JSON processor)
# Usage: jq . test.json
# Output: Displays processed JSON content
# Examples: Used for JSON processing verification
# Notes: Confirms jq can process the JSON file

# Command: kubectl apply --dry-run=client -f test.yaml
# Purpose: Validate Kubernetes manifest without applying
# Flags: apply (apply configuration), --dry-run=client (simulate), -f (file)
# Usage: kubectl apply --dry-run=client -f test.yaml
# Output: Validation results or error messages
# Examples: Used for Kubernetes manifest validation
# Notes: --dry-run prevents actual resource creation

# Command: cd ~
# Purpose: Change to home directory
# Flags: cd (change directory)
# Usage: cd ~
# Output: Changes current directory to home directory
# Examples: Used for returning to home directory
# Notes: Essential for cleanup navigation

# Command: rm -rf ~/config-practice
# Purpose: Remove configuration practice directory and contents
# Flags: -r (recursive), -f (force)
# Usage: rm -rf ~/config-practice
# Output: Removes directory and all contents
# Examples: Used for cleanup after testing
# Notes: -rf removes directory tree without confirmation

# Create configuration management practice environment
mkdir -p ~/config-practice
cd ~/config-practice

# Test YAML creation and validation
cat > test.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
  namespace: default
data:
  key1: value1
  key2: value2
EOF

# Test YAML validation
yamllint test.yaml
yq eval test.yaml

# Test JSON creation and validation
cat > test.json <<EOF
{
  "apiVersion": "v1",
  "kind": "ConfigMap",
  "metadata": {
    "name": "test-config",
    "namespace": "default"
  },
  "data": {
    "key1": "value1",
    "key2": "value2"
  }
}
EOF

# Test JSON validation
jsonlint test.json
jq . test.json

# Test Kubernetes manifest validation
kubectl apply --dry-run=client -f test.yaml

# Cleanup
cd ~
rm -rf ~/config-practice
```

#### **Troubleshooting Common Issues**
- **YAML Syntax Errors**: Check indentation, quotes, and special characters
- **JSON Syntax Errors**: Check brackets, quotes, and comma placement
- **Tool Installation Issues**: Verify package manager and internet connectivity
- **Permission Issues**: Check file permissions and sudo access
- **Validation Failures**: Check configuration syntax and Kubernetes API versions

#### **Alternative Options**
- **Online Tools**: Use online YAML/JSON validators for testing
- **Cloud IDEs**: Use cloud-based development environments
- **Container Environments**: Use Docker containers for isolated testing
- **Remote Systems**: Use SSH to access remote development systems

### **🚀 Quick Start Checklist**

Before starting this module, ensure you have:

- [ ] **Linux system** with package manager (Ubuntu 20.04+ recommended)
- [ ] **yq** installed and working (`yq --version`)
- [ ] **jq** installed and working (`jq --version`)
- [ ] **Python 3.6+** installed (`python3 --version`)
- [ ] **PyYAML** installed (`python3 -c "import yaml"`)
- [ ] **yamllint** installed (`yamllint --version`)
- [ ] **kubectl** installed (`kubectl version --client`)
- [ ] **2GB+ RAM** for configuration processing
- [ ] **10GB+ disk space** for configuration files and tools
- [ ] **Internet connection** for downloading tools and templates
- [ ] **Linux command proficiency** from Module 0 completion
- [ ] **Container fundamentals** from Module 1 completion
- [ ] **System administration** from Module 2 completion
- [ ] **Networking fundamentals** from Module 3 completion
- [ ] **Text editor** with YAML and JSON support

### **⚠️ Important Notes**

- **YAML Indentation**: YAML is sensitive to indentation. Use consistent spacing (2 or 4 spaces).
- **JSON Syntax**: JSON requires proper bracket and quote placement. Validate frequently.
- **Configuration Validation**: Always validate configurations before applying to production.
- **Version Control**: Use Git for configuration file version control and collaboration.
- **Security**: Be careful with sensitive data in configuration files. Use secrets management.

### **🎯 Success Criteria**

By the end of this module, you should be able to:
- Create and edit YAML and JSON configuration files
- Validate configuration file syntax and structure
- Process and manipulate configuration data using yq and jq
- Create Kubernetes manifests and validate them
- Implement configuration management best practices
- Use configuration management tools and workflows
- Troubleshoot configuration issues and errors
- Implement infrastructure as code principles

---

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
# =============================================================================
# JSON PROCESSING COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.name'
# Purpose: Extract name field from JSON using jq
# Flags: echo (output text), | (pipe), jq (JSON processor), '.name' (field selector)
# Usage: echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.name'
# Output: "ecommerce"
# Examples: Used for JSON field extraction
# Notes: jq processes JSON and extracts specific fields

# Command: echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.version'
# Purpose: Extract version field from JSON using jq
# Flags: echo (output text), | (pipe), jq (JSON processor), '.version' (field selector)
# Usage: echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.version'
# Output: "1.0.0"
# Examples: Used for JSON field extraction
# Notes: jq processes JSON and extracts specific fields

# Process JSON with jq
echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.name'
echo '{"name": "ecommerce", "version": "1.0.0"}' | jq '.version'
```

**Explanation**:
- `jq '.name'`: Extract name field from JSON
- `jq '.version'`: Extract version field from JSON
- **Purpose**: Process and query JSON data

```bash
# =============================================================================
# YAML/JSON CONVERSION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: yq eval -o=json ecommerce-pod.yaml
# Purpose: Convert YAML file to JSON format using yq
# Flags: eval (evaluate), -o=json (output format JSON)
# Usage: yq eval -o=json ecommerce-pod.yaml
# Output: JSON representation of YAML content
# Examples: Used for format conversion
# Notes: -o=json specifies output format

# Command: jq -r . ecommerce-service.json | yq eval -P -
# Purpose: Convert JSON to YAML using jq and yq pipeline
# Flags: -r (raw output), . (process entire JSON), | (pipe), -P (pretty print)
# Usage: jq -r . ecommerce-service.json | yq eval -P -
# Output: YAML representation of JSON content
# Examples: Used for format conversion
# Notes: Pipeline processes JSON through jq then yq

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
# =============================================================================
# YAML VALIDATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: yaml-lint ecommerce-pod.yaml
# Purpose: Validate YAML syntax in ecommerce-pod.yaml file
# Flags: yaml-lint (YAML linter)
# Usage: yaml-lint ecommerce-pod.yaml
# Output: YAML validation results or no output if valid
# Examples: Used for YAML syntax validation
# Notes: Essential for YAML quality assurance

# Validate YAML syntax
yaml-lint ecommerce-pod.yaml
```

**Explanation**:
- `yaml-lint`: Validate YAML syntax
- **Purpose**: Check for YAML syntax errors

```bash
# =============================================================================
# KUBERNETES MANIFEST VALIDATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kubeval ecommerce-pod.yaml
# Purpose: Validate Kubernetes Pod manifest against API schemas
# Flags: kubeval (Kubernetes validator)
# Usage: kubeval ecommerce-pod.yaml
# Output: Validation results or error messages
# Examples: Used for Kubernetes manifest validation
# Notes: Validates against Kubernetes API schemas

# Command: kubeval ecommerce-service.yaml
# Purpose: Validate Kubernetes Service manifest against API schemas
# Flags: kubeval (Kubernetes validator)
# Usage: kubeval ecommerce-service.yaml
# Output: Validation results or error messages
# Examples: Used for Kubernetes manifest validation
# Notes: Validates against Kubernetes API schemas

# Validate Kubernetes manifests
kubeval ecommerce-pod.yaml
kubeval ecommerce-service.yaml
```

**Explanation**:
- `kubeval`: Validate Kubernetes manifests against schemas
- **Purpose**: Ensure manifests conform to Kubernetes API

```bash
# =============================================================================
# KUBERNETES MANIFEST ANALYSIS COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kube-score score ecommerce-pod.yaml
# Purpose: Analyze Kubernetes Pod manifest for best practices
# Flags: score (analyze), kube-score (Kubernetes analyzer)
# Usage: kube-score score ecommerce-pod.yaml
# Output: Best practice analysis and recommendations
# Examples: Used for Kubernetes manifest analysis
# Notes: Analyzes for security and best practice issues

# Command: kube-score score ecommerce-service.yaml
# Purpose: Analyze Kubernetes Service manifest for best practices
# Flags: score (analyze), kube-score (Kubernetes analyzer)
# Usage: kube-score score ecommerce-service.yaml
# Output: Best practice analysis and recommendations
# Examples: Used for Kubernetes manifest analysis
# Notes: Analyzes for security and best practice issues

# Analyze Kubernetes manifests
kube-score score ecommerce-pod.yaml
kube-score score ecommerce-service.yaml
```

**Explanation**:
- `kube-score score`: Analyze manifests for best practices
- **Purpose**: Check for security and best practice issues

```bash
# =============================================================================
# JSON VALIDATION COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: jsonlint ecommerce-config.json
# Purpose: Validate JSON syntax in ecommerce-config.json file
# Flags: jsonlint (JSON linter)
# Usage: jsonlint ecommerce-config.json
# Output: JSON validation results or no output if valid
# Examples: Used for JSON syntax validation
# Notes: Essential for JSON quality assurance

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
# =============================================================================
# TEMPLATE PROCESSING COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: export ENVIRONMENT=development
# Purpose: Set environment variable for template processing
# Flags: export (set environment variable)
# Usage: export ENVIRONMENT=development
# Output: Sets ENVIRONMENT variable to development
# Examples: Used for template variable substitution
# Notes: Environment variables used in template processing

# Command: export REPLICAS=2
# Purpose: Set replicas variable for template processing
# Flags: export (set environment variable)
# Usage: export REPLICAS=2
# Output: Sets REPLICAS variable to 2
# Examples: Used for template variable substitution
# Notes: Environment variables used in template processing

# Command: export VERSION=1.0.0
# Purpose: Set version variable for template processing
# Flags: export (set environment variable)
# Usage: export VERSION=1.0.0
# Output: Sets VERSION variable to 1.0.0
# Examples: Used for template variable substitution
# Notes: Environment variables used in template processing

# Command: export DATABASE_URL="postgresql://postgres:admin@localhost:5432/ecommerce_db"
# Purpose: Set database URL variable for template processing
# Flags: export (set environment variable)
# Usage: export DATABASE_URL="postgresql://postgres:admin@localhost:5432/ecommerce_db"
# Output: Sets DATABASE_URL variable to database connection string
# Examples: Used for template variable substitution
# Notes: Environment variables used in template processing

# Command: envsubst < ecommerce-deployment-template.yaml > ecommerce-deployment-dev.yaml
# Purpose: Process template with environment variable substitution
# Flags: envsubst (environment substitution), < (input redirection), > (output redirection)
# Usage: envsubst < ecommerce-deployment-template.yaml > ecommerce-deployment-dev.yaml
# Output: Creates ecommerce-deployment-dev.yaml with substituted variables
# Examples: Used for template processing
# Notes: envsubst substitutes environment variables in template

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
# =============================================================================
# ADVANCED YQ TEMPLATING COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: yq eval '.spec.replicas = 3' ecommerce-deployment.yaml
# Purpose: Modify replicas field in deployment using yq
# Flags: eval (evaluate), '.spec.replicas = 3' (field modification)
# Usage: yq eval '.spec.replicas = 3' ecommerce-deployment.yaml
# Output: Modified YAML with replicas set to 3
# Examples: Used for programmatic YAML modification
# Notes: yq allows field-level modifications

# Command: yq eval '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"' ecommerce-deployment.yaml
# Purpose: Modify container image in deployment using yq
# Flags: eval (evaluate), '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"' (field modification)
# Usage: yq eval '.spec.template.spec.containers[0].image = "ecommerce-backend:1.1.0"' ecommerce-deployment.yaml
# Output: Modified YAML with container image updated
# Examples: Used for programmatic YAML modification
# Notes: yq allows nested field modifications

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
# =============================================================================
# KUSTOMIZE BUILD COMMANDS - TIER 2 DOCUMENTATION
# =============================================================================

# Command: kustomize build overlays/development
# Purpose: Build configuration for development environment using Kustomize
# Flags: build (build configuration), overlays/development (overlay path)
# Usage: kustomize build overlays/development
# Output: Generated YAML configuration for development environment
# Examples: Used for environment-specific configuration generation
# Notes: Kustomize builds final configuration from base and overlays

# Command: kustomize build overlays/staging
# Purpose: Build configuration for staging environment using Kustomize
# Flags: build (build configuration), overlays/staging (overlay path)
# Usage: kustomize build overlays/staging
# Output: Generated YAML configuration for staging environment
# Examples: Used for environment-specific configuration generation
# Notes: Kustomize builds final configuration from base and overlays

# Command: kustomize build overlays/production
# Purpose: Build configuration for production environment using Kustomize
# Flags: build (build configuration), overlays/production (overlay path)
# Usage: kustomize build overlays/production
# Output: Generated YAML configuration for production environment
# Examples: Used for environment-specific configuration generation
# Notes: Kustomize builds final configuration from base and overlays

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

**DETAILED SOLUTION WITH COMPLETE IMPLEMENTATION STEPS**:

**Step 1: YAML Configuration Setup**
```bash
# Navigate to your e-commerce project
cd /path/to/your/e-commerce

# Create YAML configuration directory
mkdir -p yaml-configuration
cd yaml-configuration

# Create comprehensive YAML configuration script
cat > yaml_config_creator.sh << 'EOF'
#!/bin/bash

# =============================================================================
# Comprehensive YAML Configuration Creator
# Purpose: Create and validate Kubernetes manifests for e-commerce application
# =============================================================================

# Configuration
CONFIG_DIR="./k8s-manifests"
REPORT_DIR="./reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/yaml_analysis_$TIMESTAMP.txt"

# Create directories
mkdir -p "$CONFIG_DIR"/{base,overlays/{dev,uat,prod}} "$REPORT_DIR"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$REPORT_DIR/yaml_creation.log"
}

echo "=== COMPREHENSIVE YAML CONFIGURATION CREATION ==="
echo "Date: $(date)"
echo "Report: $REPORT_FILE"
echo ""

# =============================================================================
# 1. CREATE POD MANIFEST
# =============================================================================
log_message "INFO" "Creating Pod manifest for backend service"

cat > "$CONFIG_DIR/base/backend-pod.yaml" << 'POD_EOF'
# =============================================================================
# E-commerce Backend Pod Manifest
# Purpose: Define a single instance of the backend service
# =============================================================================

apiVersion: v1
kind: Pod
metadata:
  name: ecommerce-backend-pod
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    version: v1.0.0
    component: backend
    tier: application
  annotations:
    description: "E-commerce backend service pod"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
spec:
  # Pod security context
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 1001
    seccompProfile:
      type: RuntimeDefault
  
  # Container specifications
  containers:
  - name: ecommerce-backend
    image: ecommerce-backend:latest
    imagePullPolicy: IfNotPresent
    
    # Resource requirements
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    
    # Environment variables
    env:
    - name: NODE_ENV
      value: "production"
    - name: PORT
      value: "8000"
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: ecommerce-secrets
          key: database-url
    - name: REDIS_URL
      valueFrom:
        secretKeyRef:
          name: ecommerce-secrets
          key: redis-url
    
    # Port configuration
    ports:
    - name: http
      containerPort: 8000
      protocol: TCP
    
    # Health checks
    livenessProbe:
      httpGet:
        path: /health
        port: http
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
      successThreshold: 1
    
    readinessProbe:
      httpGet:
        path: /ready
        port: http
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 3
      successThreshold: 1
    
    # Volume mounts
    volumeMounts:
    - name: config-volume
      mountPath: /app/config
      readOnly: true
    - name: logs-volume
      mountPath: /app/logs
    
    # Security context for container
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
  
  # Volumes
  volumes:
  - name: config-volume
    configMap:
      name: ecommerce-config
  - name: logs-volume
    emptyDir: {}
  
  # Restart policy
  restartPolicy: Always
  
  # DNS configuration
  dnsPolicy: ClusterFirst
  
  # Node selection
  nodeSelector:
    kubernetes.io/os: linux
  
  # Tolerations
  tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"
POD_EOF

echo "✅ Pod manifest created: $CONFIG_DIR/base/backend-pod.yaml"

# =============================================================================
# 2. CREATE SERVICE MANIFEST
# =============================================================================
log_message "INFO" "Creating Service manifest for backend"

cat > "$CONFIG_DIR/base/backend-service.yaml" << 'SERVICE_EOF'
# =============================================================================
# E-commerce Backend Service Manifest
# Purpose: Expose backend pods as a network service
# =============================================================================

apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend-service
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    version: v1.0.0
    component: backend
    tier: application
  annotations:
    description: "E-commerce backend service"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
spec:
  # Service type
  type: ClusterIP
  
  # Port configuration
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  - name: https
    port: 443
    targetPort: https
    protocol: TCP
  
  # Selector for pods
  selector:
    app: ecommerce-backend
    component: backend
  
  # Session affinity
  sessionAffinity: None
  
  # External traffic policy
  externalTrafficPolicy: Cluster
SERVICE_EOF

echo "✅ Service manifest created: $CONFIG_DIR/base/backend-service.yaml"

# =============================================================================
# 3. CREATE DEPLOYMENT MANIFEST
# =============================================================================
log_message "INFO" "Creating Deployment manifest with 3 replicas"

cat > "$CONFIG_DIR/base/backend-deployment.yaml" << 'DEPLOYMENT_EOF'
# =============================================================================
# E-commerce Backend Deployment Manifest
# Purpose: Manage backend pods with rolling updates and scaling
# =============================================================================

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend-deployment
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    version: v1.0.0
    component: backend
    tier: application
  annotations:
    description: "E-commerce backend deployment"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
spec:
  # Replica configuration
  replicas: 3
  
  # Deployment strategy
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  
  # Selector for pods
  selector:
    matchLabels:
      app: ecommerce-backend
      component: backend
  
  # Pod template
  template:
    metadata:
      labels:
        app: ecommerce-backend
        version: v1.0.0
        component: backend
        tier: application
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    
    spec:
      # Pod security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
        seccompProfile:
          type: RuntimeDefault
      
      # Container specifications
      containers:
      - name: ecommerce-backend
        image: ecommerce-backend:latest
        imagePullPolicy: IfNotPresent
        
        # Resource requirements
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # Environment variables
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "8000"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: ecommerce-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: ecommerce-secrets
              key: redis-url
        
        # Port configuration
        ports:
        - name: http
          containerPort: 8000
          protocol: TCP
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
          successThreshold: 1
        
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
        
        # Volume mounts
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
          readOnly: true
        - name: logs-volume
          mountPath: /app/logs
        
        # Security context for container
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
      
      # Volumes
      volumes:
      - name: config-volume
        configMap:
          name: ecommerce-config
      - name: logs-volume
        emptyDir: {}
      
      # Restart policy
      restartPolicy: Always
      
      # DNS configuration
      dnsPolicy: ClusterFirst
      
      # Node selection
      nodeSelector:
        kubernetes.io/os: linux
      
      # Tolerations
      tolerations:
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
DEPLOYMENT_EOF

echo "✅ Deployment manifest created: $CONFIG_DIR/base/backend-deployment.yaml"

# =============================================================================
# 4. CREATE CONFIGMAP MANIFEST
# =============================================================================
log_message "INFO" "Creating ConfigMap for application configuration"

cat > "$CONFIG_DIR/base/backend-configmap.yaml" << 'CONFIGMAP_EOF'
# =============================================================================
# E-commerce Backend ConfigMap Manifest
# Purpose: Store application configuration data
# =============================================================================

apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    version: v1.0.0
    component: backend
    tier: application
  annotations:
    description: "E-commerce backend configuration"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
data:
  # Application configuration
  app.properties: |
    # E-commerce Application Configuration
    app.name=E-commerce Backend
    app.version=1.0.0
    app.environment=production
    
    # Server configuration
    server.port=8000
    server.host=0.0.0.0
    server.timeout=30000
    
    # Database configuration
    database.pool.size=10
    database.pool.max=20
    database.pool.min=5
    database.pool.timeout=30000
    
    # Redis configuration
    redis.pool.size=5
    redis.pool.max=10
    redis.pool.min=2
    redis.pool.timeout=5000
    
    # Logging configuration
    logging.level=INFO
    logging.file=/app/logs/application.log
    logging.max.size=100MB
    logging.max.files=10
    
    # Security configuration
    security.jwt.secret=your-jwt-secret
    security.jwt.expiration=3600
    security.cors.origins=*
    security.cors.methods=GET,POST,PUT,DELETE,OPTIONS
    
    # Feature flags
    feature.payment.enabled=true
    feature.inventory.enabled=true
    feature.notifications.enabled=true
    feature.analytics.enabled=true
  
  # Environment-specific configuration
  environment.properties: |
    # Environment Configuration
    env.name=production
    env.debug=false
    env.profiling=false
    
    # External services
    external.payment.service.url=https://api.stripe.com
    external.inventory.service.url=https://api.inventory.com
    external.notification.service.url=https://api.notifications.com
    
    # Monitoring
    monitoring.enabled=true
    monitoring.metrics.enabled=true
    monitoring.tracing.enabled=true
    monitoring.logging.enabled=true
  
  # Database configuration
  database.properties: |
    # Database Configuration
    db.driver=org.postgresql.Driver
    db.dialect=org.hibernate.dialect.PostgreSQLDialect
    db.hibernate.ddl.auto=validate
    db.hibernate.show.sql=false
    db.hibernate.format.sql=true
    
    # Connection pool
    db.hikari.maximum.pool.size=20
    db.hikari.minimum.idle=5
    db.hikari.connection.timeout=30000
    db.hikari.idle.timeout=600000
    db.hikari.max.lifetime=1800000
  
  # Redis configuration
  redis.properties: |
    # Redis Configuration
    redis.host=redis-service
    redis.port=6379
    redis.database=0
    redis.timeout=5000
    redis.pool.max.active=10
    redis.pool.max.idle=5
    redis.pool.min.idle=2
    redis.pool.max.wait=3000
  
  # Logging configuration
  logging.properties: |
    # Logging Configuration
    logging.level.root=INFO
    logging.level.com.ecommerce=DEBUG
    logging.level.org.springframework=INFO
    logging.level.org.hibernate=WARN
    
    # Log file configuration
    logging.file.name=/app/logs/application.log
    logging.file.max.size=100MB
    logging.file.max.history=10
    logging.file.total.size.cap=1GB
    
    # Log pattern
    logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
    logging.pattern.file=%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n
CONFIGMAP_EOF

echo "✅ ConfigMap manifest created: $CONFIG_DIR/base/backend-configmap.yaml"

# =============================================================================
# 5. CREATE SECRET MANIFEST
# =============================================================================
log_message "INFO" "Creating Secret manifest for sensitive data"

cat > "$CONFIG_DIR/base/backend-secret.yaml" << 'SECRET_EOF'
# =============================================================================
# E-commerce Backend Secret Manifest
# Purpose: Store sensitive configuration data
# =============================================================================

apiVersion: v1
kind: Secret
metadata:
  name: ecommerce-secrets
  namespace: ecommerce
  labels:
    app: ecommerce-backend
    version: v1.0.0
    component: backend
    tier: application
  annotations:
    description: "E-commerce backend secrets"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
type: Opaque
data:
  # Database credentials (base64 encoded)
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0BkYi1zZXJ2aWNlOjU0MzIvZWNvbW1lcmNl
  database-username: dXNlcg==
  database-password: cGFzcw==
  
  # Redis credentials
  redis-url: cmVkaXM6Ly9yZWRpcy1zZXJ2aWNlOjYzNzkvMA==
  redis-password: cmVkaXMtcGFzcw==
  
  # JWT secret
  jwt-secret: eW91ci1qd3Qtc2VjcmV0LWtleQ==
  
  # API keys
  stripe-api-key: c2tfdGVzdF9zdHJpcGVfYXBpX2tleQ==
  paypal-api-key: cGF5cGFsX2FwaV9rZXk=
  
  # External service credentials
  payment-service-key: cGF5bWVudF9zZXJ2aWNlX2tleQ==
  inventory-service-key: aW52ZW50b3J5X3NlcnZpY2Vfa2V5
  notification-service-key: bm90aWZpY2F0aW9uX3NlcnZpY2Vfa2V5
SECRET_EOF

echo "✅ Secret manifest created: $CONFIG_DIR/base/backend-secret.yaml"

# =============================================================================
# 6. CREATE NAMESPACE MANIFEST
# =============================================================================
log_message "INFO" "Creating Namespace manifest"

cat > "$CONFIG_DIR/base/namespace.yaml" << 'NAMESPACE_EOF'
# =============================================================================
# E-commerce Namespace Manifest
# Purpose: Create dedicated namespace for e-commerce application
# =============================================================================

apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    name: ecommerce
    app: ecommerce-backend
    version: v1.0.0
  annotations:
    description: "E-commerce application namespace"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"
spec: {}
NAMESPACE_EOF

echo "✅ Namespace manifest created: $CONFIG_DIR/base/namespace.yaml"

# =============================================================================
# 7. CREATE KUSTOMIZATION FILE
# =============================================================================
log_message "INFO" "Creating Kustomization file"

cat > "$CONFIG_DIR/base/kustomization.yaml" << 'KUSTOMIZATION_EOF'
# =============================================================================
# E-commerce Base Kustomization
# Purpose: Define base resources for e-commerce application
# =============================================================================

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-base
  annotations:
    description: "Base configuration for e-commerce application"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"

# Resources to include
resources:
- namespace.yaml
- backend-configmap.yaml
- backend-secret.yaml
- backend-pod.yaml
- backend-service.yaml
- backend-deployment.yaml

# Common labels
commonLabels:
  app: ecommerce-backend
  version: v1.0.0
  component: backend
  tier: application

# Common annotations
commonAnnotations:
  created-by: "yaml-config-creator"
  created-at: "2024-01-01T00:00:00Z"

# Namespace
namespace: ecommerce

# Images
images:
- name: ecommerce-backend
  newTag: latest

# Replicas
replicas:
- name: ecommerce-backend-deployment
  count: 3
KUSTOMIZATION_EOF

echo "✅ Kustomization file created: $CONFIG_DIR/base/kustomization.yaml"

# =============================================================================
# 8. CREATE ENVIRONMENT-SPECIFIC OVERLAYS
# =============================================================================
log_message "INFO" "Creating environment-specific overlays"

# Development environment
cat > "$CONFIG_DIR/overlays/dev/kustomization.yaml" << 'DEV_KUSTOMIZATION_EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-dev
  annotations:
    description: "Development environment configuration"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"

# Base configuration
bases:
- ../../base

# Environment-specific patches
patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

# Environment-specific resources
resources:
- dev-configmap.yaml

# Common labels
commonLabels:
  environment: development

# Common annotations
commonAnnotations:
  environment: development

# Namespace
namespace: ecommerce-dev

# Images
images:
- name: ecommerce-backend
  newTag: dev

# Replicas
replicas:
- name: ecommerce-backend-deployment
  count: 1
DEV_KUSTOMIZATION_EOF

# UAT environment
cat > "$CONFIG_DIR/overlays/uat/kustomization.yaml" << 'UAT_KUSTOMIZATION_EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-uat
  annotations:
    description: "UAT environment configuration"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"

# Base configuration
bases:
- ../../base

# Environment-specific patches
patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

# Environment-specific resources
resources:
- uat-configmap.yaml

# Common labels
commonLabels:
  environment: uat

# Common annotations
commonAnnotations:
  environment: uat

# Namespace
namespace: ecommerce-uat

# Images
images:
- name: ecommerce-backend
  newTag: uat

# Replicas
replicas:
- name: ecommerce-backend-deployment
  count: 2
UAT_KUSTOMIZATION_EOF

# Production environment
cat > "$CONFIG_DIR/overlays/prod/kustomization.yaml" << 'PROD_KUSTOMIZATION_EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: ecommerce-prod
  annotations:
    description: "Production environment configuration"
    created-by: "yaml-config-creator"
    created-at: "2024-01-01T00:00:00Z"

# Base configuration
bases:
- ../../base

# Environment-specific patches
patchesStrategicMerge:
- deployment-patch.yaml
- configmap-patch.yaml

# Environment-specific resources
resources:
- prod-configmap.yaml

# Common labels
commonLabels:
  environment: production

# Common annotations
commonAnnotations:
  environment: production

# Namespace
namespace: ecommerce-prod

# Images
images:
- name: ecommerce-backend
  newTag: prod

# Replicas
replicas:
- name: ecommerce-backend-deployment
  count: 5
PROD_KUSTOMIZATION_EOF

echo "✅ Environment-specific overlays created"

# =============================================================================
# 9. CREATE VALIDATION SCRIPT
# =============================================================================
log_message "INFO" "Creating validation script"

cat > "$REPORT_DIR/validate_yaml.sh" << 'VALIDATION_EOF'
#!/bin/bash

echo "=== YAML VALIDATION SCRIPT ==="
echo "Date: $(date)"
echo ""

# Function to validate YAML syntax
validate_yaml_syntax() {
    local file="$1"
    echo "Validating YAML syntax for: $file"
    
    if command -v yamllint &> /dev/null; then
        yamllint "$file" || echo "YAML syntax validation failed for $file"
    else
        echo "yamllint not available, using basic validation"
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null || echo "YAML syntax validation failed for $file"
    fi
}

# Function to validate Kubernetes manifests
validate_k8s_manifest() {
    local file="$1"
    echo "Validating Kubernetes manifest for: $file"
    
    if command -v kubeval &> /dev/null; then
        kubeval "$file" || echo "Kubernetes validation failed for $file"
    else
        echo "kubeval not available, using basic validation"
        kubectl apply --dry-run=client -f "$file" 2>/dev/null || echo "Kubernetes validation failed for $file"
    fi
}

# Validate all YAML files
echo "1. VALIDATING YAML SYNTAX:"
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    validate_yaml_syntax "$file"
done

echo ""
echo "2. VALIDATING KUBERNETES MANIFESTS:"
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    validate_k8s_manifest "$file"
done

echo ""
echo "3. VALIDATING KUSTOMIZATION:"
if command -v kustomize &> /dev/null; then
    echo "Validating base kustomization..."
    kustomize build "$CONFIG_DIR/base" --dry-run || echo "Base kustomization validation failed"
    
    echo "Validating dev overlay..."
    kustomize build "$CONFIG_DIR/overlays/dev" --dry-run || echo "Dev overlay validation failed"
    
    echo "Validating uat overlay..."
    kustomize build "$CONFIG_DIR/overlays/uat" --dry-run || echo "UAT overlay validation failed"
    
    echo "Validating prod overlay..."
    kustomize build "$CONFIG_DIR/overlays/prod" --dry-run || echo "Prod overlay validation failed"
else
    echo "kustomize not available for validation"
fi

echo ""
echo "=== YAML VALIDATION COMPLETED ==="
VALIDATION_EOF

chmod +x "$REPORT_DIR/validate_yaml.sh"
echo "✅ Validation script created: $REPORT_DIR/validate_yaml.sh"

# =============================================================================
# 10. SUMMARY
# =============================================================================
log_message "INFO" "Generating summary"

{
    echo "=== YAML CONFIGURATION CREATION SUMMARY ==="
    echo ""
    echo "Configuration directory: $CONFIG_DIR"
    echo "Base manifests: $CONFIG_DIR/base/"
    echo "Environment overlays: $CONFIG_DIR/overlays/"
    echo "Validation script: $REPORT_DIR/validate_yaml.sh"
    echo ""
    echo "Created manifests:"
    echo "- namespace.yaml"
    echo "- backend-configmap.yaml"
    echo "- backend-secret.yaml"
    echo "- backend-pod.yaml"
    echo "- backend-service.yaml"
    echo "- backend-deployment.yaml"
    echo "- kustomization.yaml"
    echo ""
    echo "Environment overlays:"
    echo "- dev/kustomization.yaml"
    echo "- uat/kustomization.yaml"
    echo "- prod/kustomization.yaml"
    echo ""
    echo "Next steps:"
    echo "1. Validate YAML syntax and Kubernetes manifests"
    echo "2. Test configuration generation with Kustomize"
    echo "3. Deploy to development environment"
    echo "4. Test application functionality"
    echo "5. Promote to UAT and production environments"
    echo ""
} >> "$REPORT_FILE"

log_message "INFO" "YAML configuration creation completed"

echo "=== YAML CONFIGURATION CREATION COMPLETED ==="
echo "Configuration directory: $CONFIG_DIR"
echo "Validation script: $REPORT_DIR/validate_yaml.sh"
echo "Report: $REPORT_FILE"
echo ""

# Display summary
echo "=== QUICK SUMMARY ==="
echo "Manifests created: $(find "$CONFIG_DIR" -name "*.yaml" | wc -l)"
echo "Base resources: $(find "$CONFIG_DIR/base" -name "*.yaml" | wc -l)"
echo "Environment overlays: $(find "$CONFIG_DIR/overlays" -name "*.yaml" | wc -l)"
echo ""

EOF

chmod +x yaml_config_creator.sh
```

**Step 2: Execute YAML Configuration Creation**
```bash
# Execute YAML configuration creation
echo "=== EXECUTING YAML CONFIGURATION CREATION ==="

# 1. Run YAML configuration creator
./yaml_config_creator.sh

# 2. Validate created configurations
./reports/validate_yaml.sh

# 3. Display results
echo "=== YAML CONFIGURATION RESULTS ==="
echo "Configuration directory structure:"
tree k8s-manifests/ || find k8s-manifests/ -type f | sort
echo ""

# 4. Show quick summary
echo "=== QUICK YAML SUMMARY ==="
echo "Manifests created: $(find k8s-manifests/ -name "*.yaml" | wc -l)"
echo "Base resources: $(find k8s-manifests/base/ -name "*.yaml" | wc -l)"
echo "Environment overlays: $(find k8s-manifests/overlays/ -name "*.yaml" | wc -l)"
echo ""
```

**Step 3: Create Advanced YAML Processing Scripts**
```bash
# Create advanced YAML processing script
cat > advanced_yaml_processor.sh << 'EOF'
#!/bin/bash

echo "=== ADVANCED YAML PROCESSING ==="
echo "Date: $(date)"
echo ""

CONFIG_DIR="./k8s-manifests"

# 1. YAML syntax validation
echo "1. YAML SYNTAX VALIDATION:"
echo "=== Validating YAML Syntax ==="
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Validating: $file"
    if command -v yamllint &> /dev/null; then
        yamllint "$file" 2>&1 | head -5
    else
        echo "yamllint not available, using basic validation"
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null && echo "✅ Valid" || echo "❌ Invalid"
    fi
    echo ""
done

# 2. Kubernetes manifest validation
echo "2. KUBERNETES MANIFEST VALIDATION:"
echo "=== Validating Kubernetes Manifests ==="
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Validating: $file"
    if command -v kubeval &> /dev/null; then
        kubeval "$file" 2>&1 | head -5
    else
        echo "kubeval not available, using basic validation"
        kubectl apply --dry-run=client -f "$file" 2>/dev/null && echo "✅ Valid" || echo "❌ Invalid"
    fi
    echo ""
done

# 3. YAML processing with yq
echo "3. YAML PROCESSING WITH YQ:"
echo "=== Processing YAML with yq ==="
if command -v yq &> /dev/null; then
    echo "Extracting metadata from manifests:"
    find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
        echo "Processing: $file"
        yq eval '.metadata.name' "$file" 2>/dev/null || echo "No metadata.name found"
        yq eval '.metadata.namespace' "$file" 2>/dev/null || echo "No metadata.namespace found"
        echo ""
    done
else
    echo "yq not available for YAML processing"
fi

# 4. Configuration analysis
echo "4. CONFIGURATION ANALYSIS:"
echo "=== Analyzing Configuration ==="
echo "Resource types:"
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    yq eval '.kind' "$file" 2>/dev/null || echo "Unknown"
done | sort | uniq -c | sort -nr

echo ""
echo "Namespaces:"
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    yq eval '.metadata.namespace' "$file" 2>/dev/null || echo "default"
done | sort | uniq -c | sort -nr

echo ""
echo "=== ADVANCED YAML PROCESSING COMPLETED ==="
EOF

chmod +x advanced_yaml_processor.sh
```

**Step 4: Create YAML Testing and Validation Suite**
```bash
# Create comprehensive YAML testing suite
cat > yaml_testing_suite.sh << 'EOF'
#!/bin/bash

echo "=== YAML TESTING SUITE ==="
echo "Date: $(date)"
echo ""

CONFIG_DIR="./k8s-manifests"
TEST_RESULTS="./test-results"

# Create test results directory
mkdir -p "$TEST_RESULTS"

# 1. YAML syntax testing
echo "1. YAML SYNTAX TESTING:"
echo "=== Testing YAML Syntax ==="
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Testing: $file"
    if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo "✅ YAML syntax valid"
    else
        echo "❌ YAML syntax invalid"
        echo "Error details:"
        python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>&1 | head -3
    fi
    echo ""
done > "$TEST_RESULTS/yaml_syntax_test.txt"

# 2. Kubernetes manifest testing
echo "2. KUBERNETES MANIFEST TESTING:"
echo "=== Testing Kubernetes Manifests ==="
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Testing: $file"
    if kubectl apply --dry-run=client -f "$file" 2>/dev/null; then
        echo "✅ Kubernetes manifest valid"
    else
        echo "❌ Kubernetes manifest invalid"
        echo "Error details:"
        kubectl apply --dry-run=client -f "$file" 2>&1 | head -3
    fi
    echo ""
done > "$TEST_RESULTS/k8s_manifest_test.txt"

# 3. Kustomize testing
echo "3. KUSTOMIZE TESTING:"
echo "=== Testing Kustomize Builds ==="
if command -v kustomize &> /dev/null; then
    echo "Testing base kustomization..."
    if kustomize build "$CONFIG_DIR/base" --dry-run 2>/dev/null; then
        echo "✅ Base kustomization valid"
    else
        echo "❌ Base kustomization invalid"
    fi
    
    echo "Testing dev overlay..."
    if kustomize build "$CONFIG_DIR/overlays/dev" --dry-run 2>/dev/null; then
        echo "✅ Dev overlay valid"
    else
        echo "❌ Dev overlay invalid"
    fi
    
    echo "Testing uat overlay..."
    if kustomize build "$CONFIG_DIR/overlays/uat" --dry-run 2>/dev/null; then
        echo "✅ UAT overlay valid"
    else
        echo "❌ UAT overlay invalid"
    fi
    
    echo "Testing prod overlay..."
    if kustomize build "$CONFIG_DIR/overlays/prod" --dry-run 2>/dev/null; then
        echo "✅ Prod overlay valid"
    else
        echo "❌ Prod overlay invalid"
    fi
else
    echo "kustomize not available for testing"
fi

# 4. Configuration consistency testing
echo "4. CONFIGURATION CONSISTENCY TESTING:"
echo "=== Testing Configuration Consistency ==="
echo "Checking for consistent labels..."
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Checking: $file"
    yq eval '.metadata.labels' "$file" 2>/dev/null || echo "No labels found"
    echo ""
done

echo "Checking for consistent annotations..."
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Checking: $file"
    yq eval '.metadata.annotations' "$file" 2>/dev/null || echo "No annotations found"
    echo ""
done

# 5. Security testing
echo "5. SECURITY TESTING:"
echo "=== Testing Security Configurations ==="
echo "Checking for security contexts..."
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Checking: $file"
    yq eval '.spec.securityContext' "$file" 2>/dev/null || echo "No security context found"
    yq eval '.spec.template.spec.securityContext' "$file" 2>/dev/null || echo "No pod security context found"
    echo ""
done

echo "Checking for resource limits..."
find "$CONFIG_DIR" -name "*.yaml" -type f | while read file; do
    echo "Checking: $file"
    yq eval '.spec.template.spec.containers[].resources' "$file" 2>/dev/null || echo "No resource limits found"
    echo ""
done

echo "=== YAML TESTING SUITE COMPLETED ==="
echo "Test results saved to: $TEST_RESULTS/"
EOF

chmod +x yaml_testing_suite.sh
```

**Step 5: Execute Complete YAML Configuration Creation**
```bash
# Execute complete YAML configuration creation
echo "=== EXECUTING COMPLETE YAML CONFIGURATION CREATION ==="

# 1. Run YAML configuration creator
./yaml_config_creator.sh

# 2. Run advanced YAML processing
./advanced_yaml_processor.sh

# 3. Run YAML testing suite
./yaml_testing_suite.sh

# 4. Display results
echo "=== YAML CONFIGURATION RESULTS ==="
echo "Configuration directory structure:"
tree k8s-manifests/ || find k8s-manifests/ -type f | sort
echo ""

echo "Test results:"
ls -la test-results/
echo ""

# 5. Show quick summary
echo "=== QUICK YAML SUMMARY ==="
echo "Manifests created: $(find k8s-manifests/ -name "*.yaml" | wc -l)"
echo "Base resources: $(find k8s-manifests/base/ -name "*.yaml" | wc -l)"
echo "Environment overlays: $(find k8s-manifests/overlays/ -name "*.yaml" | wc -l)"
echo "Test results: $(find test-results/ -name "*.txt" | wc -l)"
echo ""
```

**COMPLETE VALIDATION STEPS**:
```bash
# 1. Verify YAML configuration creation
echo "=== YAML CONFIGURATION VALIDATION ==="
ls -la k8s-manifests/
echo ""

# 2. Verify base manifests
echo "=== BASE MANIFESTS VALIDATION ==="
ls -la k8s-manifests/base/
echo ""

# 3. Verify environment overlays
echo "=== ENVIRONMENT OVERLAYS VALIDATION ==="
ls -la k8s-manifests/overlays/*/
echo ""

# 4. Test YAML validation
echo "=== YAML VALIDATION TEST ==="
./reports/validate_yaml.sh
echo ""

# 5. Verify test results
echo "=== TEST RESULTS VALIDATION ==="
ls -la test-results/
echo ""
```

**ERROR HANDLING AND TROUBLESHOOTING**:
```bash
# If YAML creation fails:
echo "=== YAML CREATION TROUBLESHOOTING ==="
# Check directory permissions
ls -la k8s-manifests/
# Check YAML syntax
yamllint k8s-manifests/base/*.yaml

# If validation fails:
echo "=== YAML VALIDATION TROUBLESHOOTING ==="
# Check YAML syntax
python3 -c "import yaml; yaml.safe_load(open('k8s-manifests/base/backend-pod.yaml'))"
# Check Kubernetes manifests
kubectl apply --dry-run=client -f k8s-manifests/base/backend-pod.yaml

# If Kustomize fails:
echo "=== KUSTOMIZE TROUBLESHOOTING ==="
# Check Kustomize installation
kustomize version
# Check kustomization files
cat k8s-manifests/base/kustomization.yaml
```

**Expected Output**:
- **Complete Kubernetes manifests** in YAML format with proper structure and annotations
- **Validated configurations** with syntax and Kubernetes API compliance
- **Environment-specific configurations** with overlays for DEV, UAT, and PROD
- **Comprehensive validation** with testing suite and error handling
- **Production-ready configurations** with security, resource limits, and best practices
- **Complete validation** confirming all YAML configurations work correctly

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
