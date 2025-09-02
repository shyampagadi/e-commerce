# 🛡️ Infrastructure Security Scanning: IaC Security Automation

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** Infrastructure as Code (IaC) security scanning
- **Implement** Terraform and Kubernetes security validation
- **Configure** cloud configuration compliance checks
- **Build** infrastructure vulnerability management
- **Secure** deployment pipelines with policy enforcement

## 🎯 Real-World Context
Infrastructure security is critical for e-commerce platforms. Companies like Shopify and Stripe use automated IaC scanning to prevent misconfigurations that could expose customer data or payment information to security breaches.

---

## 🏗️ IaC Security Fundamentals

### **Infrastructure Security Scope**

| Component | Security Concerns | Tools |
|-----------|------------------|-------|
| **Terraform** | Resource misconfigurations | Checkov, TFSec, Terrascan |
| **Kubernetes** | Pod security, RBAC | Polaris, Falco, OPA Gatekeeper |
| **Docker** | Image vulnerabilities | Trivy, Snyk, Clair |
| **Cloud Config** | Service permissions | Scout Suite, Prowler |

### **Basic IaC Security Workflow**

```yaml
name: Infrastructure Security Scan

on:
  push:
    branches: [main, develop]
    paths:
      - 'terraform/**'
      - 'k8s/**'
      - 'infrastructure/**'
  pull_request:
    branches: [main]
    paths:
      - 'terraform/**'
      - 'k8s/**'

jobs:
  terraform-security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
          
      - name: Terraform Security Scan with Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          output_format: sarif
          output_file_path: checkov-terraform.sarif
          
      - name: Run TFSec
        uses: aquasecurity/tfsec-action@v1.0.3
        with:
          working_directory: terraform/
          
      - name: Upload Security Results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: checkov-terraform.sarif

  kubernetes-security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Kubernetes Security with Polaris
        run: |
          # Install Polaris
          curl -L https://github.com/FairwindsOps/polaris/releases/latest/download/polaris_linux_amd64.tar.gz | tar xz
          
          # Scan Kubernetes manifests
          ./polaris audit --audit-path k8s/ --format json > polaris-results.json
          
      - name: Kubernetes Security with Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: k8s/
          framework: kubernetes
          
      - name: Upload K8s Security Results
        uses: actions/upload-artifact@v4
        with:
          name: k8s-security-results
          path: polaris-results.json
```

---

## 🔍 Advanced Terraform Security

### **Comprehensive Terraform Security Pipeline**

```yaml
name: Terraform Security Pipeline

on:
  push:
    branches: [main]
    paths: ['terraform/**']
  pull_request:
    branches: [main]
    paths: ['terraform/**']

jobs:
  terraform-validate:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        
      - name: Terraform Init
        working-directory: terraform/
        run: terraform init -backend=false
        
      - name: Terraform Validate
        working-directory: terraform/
        run: terraform validate
        
      - name: Terraform Format Check
        working-directory: terraform/
        run: terraform fmt -check -recursive

  security-scanning:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Multiple Security Scanners
        run: |
          # Checkov - Comprehensive policy checks
          pip install checkov
          checkov -d terraform/ --framework terraform --output sarif --output-file checkov.sarif
          
          # TFSec - Terraform-specific security
          curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
          tfsec terraform/ --format json --out tfsec.json
          
          # Terrascan - Multi-cloud security
          curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
          tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
          ./terrascan scan -d terraform/ -o json > terrascan.json
          
      - name: Process Security Results
        run: |
          python3 << 'EOF'
          import json
          
          # Process Checkov results
          try:
            with open('checkov.sarif') as f:
              checkov_data = json.load(f)
              checkov_issues = len(checkov_data.get('runs', [{}])[0].get('results', []))
          except:
            checkov_issues = 0
          
          # Process TFSec results
          try:
            with open('tfsec.json') as f:
              tfsec_data = json.load(f)
              tfsec_issues = len(tfsec_data.get('results', []))
          except:
            tfsec_issues = 0
          
          # Process Terrascan results
          try:
            with open('terrascan.json') as f:
              terrascan_data = json.load(f)
              terrascan_issues = len(terrascan_data.get('results', {}).get('violations', []))
          except:
            terrascan_issues = 0
          
          total_issues = checkov_issues + tfsec_issues + terrascan_issues
          
          print(f"🔍 Security Scan Results:")
          print(f"Checkov: {checkov_issues} issues")
          print(f"TFSec: {tfsec_issues} issues") 
          print(f"Terrascan: {terrascan_issues} issues")
          print(f"Total: {total_issues} issues")
          
          # Fail if critical issues found
          if total_issues > 0:
            print("❌ Security issues detected")
            exit(1)
          else:
            print("✅ No security issues found")
          EOF
          
      - name: Upload Security Reports
        uses: actions/upload-artifact@v4
        with:
          name: terraform-security-reports
          path: |
            checkov.sarif
            tfsec.json
            terrascan.json

  cost-analysis:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        
      - name: Terraform Plan
        working-directory: terraform/
        env:
          TF_VAR_environment: staging
        run: |
          terraform init
          terraform plan -out=tfplan
          
      - name: Cost Estimation with Infracost
        uses: infracost/actions/setup@v2
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
          
      - name: Generate Cost Report
        working-directory: terraform/
        run: |
          infracost breakdown --path tfplan --format json --out-file infracost.json
          infracost output --path infracost.json --format table
```

---

## 🚢 Kubernetes Security Scanning

### **K8s Security Pipeline**

```yaml
name: Kubernetes Security Pipeline

on:
  push:
    branches: [main]
    paths: ['k8s/**']
  pull_request:
    branches: [main]
    paths: ['k8s/**']

jobs:
  k8s-security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Kubernetes Lint with kubeval
        run: |
          # Install kubeval
          curl -L https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar xz
          
          # Validate all K8s manifests
          find k8s/ -name "*.yaml" -o -name "*.yml" | xargs ./kubeval
          
      - name: Security Scan with Polaris
        run: |
          # Install Polaris
          curl -L https://github.com/FairwindsOps/polaris/releases/latest/download/polaris_linux_amd64.tar.gz | tar xz
          
          # Run security audit
          ./polaris audit --audit-path k8s/ --format json > polaris-audit.json
          
          # Check for critical issues
          CRITICAL_ISSUES=$(jq '.Results[] | select(.Severity == "error") | length' polaris-audit.json | wc -l)
          
          if [ "$CRITICAL_ISSUES" -gt 0 ]; then
            echo "❌ Critical security issues found: $CRITICAL_ISSUES"
            jq '.Results[] | select(.Severity == "error")' polaris-audit.json
            exit 1
          fi
          
      - name: Network Policy Validation
        run: |
          # Check for network policies
          NETWORK_POLICIES=$(find k8s/ -name "*.yaml" -exec grep -l "kind: NetworkPolicy" {} \;)
          
          if [ -z "$NETWORK_POLICIES" ]; then
            echo "⚠️ No NetworkPolicy found - consider adding network segmentation"
          else
            echo "✅ NetworkPolicy configurations found"
          fi
          
      - name: RBAC Analysis
        run: |
          # Analyze RBAC configurations
          python3 << 'EOF'
          import yaml
          import glob
          import os
          
          rbac_files = []
          for file in glob.glob("k8s/**/*.yaml", recursive=True):
            try:
              with open(file) as f:
                docs = yaml.safe_load_all(f)
                for doc in docs:
                  if doc and doc.get('kind') in ['Role', 'ClusterRole', 'RoleBinding', 'ClusterRoleBinding']:
                    rbac_files.append(file)
                    break
            except:
              continue
          
          if rbac_files:
            print("✅ RBAC configurations found:")
            for file in rbac_files:
              print(f"  - {file}")
          else:
            print("⚠️ No RBAC configurations found - consider implementing least privilege access")
          EOF
          
      - name: Pod Security Standards Check
        run: |
          # Check for Pod Security Standards compliance
          python3 << 'EOF'
          import yaml
          import glob
          
          security_issues = []
          
          for file in glob.glob("k8s/**/*.yaml", recursive=True):
            try:
              with open(file) as f:
                docs = yaml.safe_load_all(f)
                for doc in docs:
                  if not doc or doc.get('kind') not in ['Deployment', 'Pod', 'DaemonSet', 'StatefulSet']:
                    continue
                  
                  spec = doc.get('spec', {})
                  if doc.get('kind') in ['Deployment', 'DaemonSet', 'StatefulSet']:
                    spec = spec.get('template', {}).get('spec', {})
                  
                  # Check security context
                  security_context = spec.get('securityContext', {})
                  containers = spec.get('containers', [])
                  
                  # Check for privileged containers
                  for container in containers:
                    container_security = container.get('securityContext', {})
                    if container_security.get('privileged'):
                      security_issues.append(f"{file}: Privileged container detected")
                    
                    if not container_security.get('runAsNonRoot'):
                      security_issues.append(f"{file}: Container may run as root")
                  
                  # Check for host network
                  if spec.get('hostNetwork'):
                    security_issues.append(f"{file}: Host network access enabled")
                  
                  # Check for host PID
                  if spec.get('hostPID'):
                    security_issues.append(f"{file}: Host PID namespace access enabled")
            except:
              continue
          
          if security_issues:
            print("❌ Pod Security Issues Found:")
            for issue in security_issues:
              print(f"  - {issue}")
            exit(1)
          else:
            print("✅ Pod Security Standards compliance verified")
          EOF
```

---

## 🎯 E-commerce Infrastructure Security

### **Complete E-commerce IaC Security Pipeline**

```yaml
name: E-commerce Infrastructure Security

on:
  push:
    branches: [main, develop]
    paths:
      - 'infrastructure/**'
      - 'terraform/**'
      - 'k8s/**'
  pull_request:
    branches: [main]

jobs:
  infrastructure-analysis:
    runs-on: ubuntu-latest
    outputs:
      terraform-changed: ${{ steps.changes.outputs.terraform }}
      k8s-changed: ${{ steps.changes.outputs.k8s }}
      docker-changed: ${{ steps.changes.outputs.docker }}
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            terraform:
              - 'terraform/**'
              - 'infrastructure/terraform/**'
            k8s:
              - 'k8s/**'
              - 'infrastructure/k8s/**'
            docker:
              - '**/Dockerfile*'
              - 'docker-compose*.yml'

  terraform-security:
    needs: infrastructure-analysis
    if: needs.infrastructure-analysis.outputs.terraform-changed == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Multi-Scanner Terraform Security
        run: |
          # Install security scanners
          pip install checkov
          curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
          
          # Create results directory
          mkdir -p security-results
          
          # Run Checkov
          checkov -d terraform/ --framework terraform \
            --check CKV_AWS_20,CKV_AWS_21,CKV_AWS_23,CKV_AWS_24 \
            --output json --output-file security-results/checkov.json
          
          # Run TFSec
          tfsec terraform/ --format json --out security-results/tfsec.json
          
      - name: Analyze E-commerce Security Requirements
        run: |
          python3 << 'EOF'
          import json
          import os
          
          # E-commerce specific security checks
          ecommerce_requirements = {
            'encryption_at_rest': False,
            'encryption_in_transit': False,
            'vpc_flow_logs': False,
            'cloudtrail_enabled': False,
            'waf_enabled': False,
            'backup_enabled': False
          }
          
          # Check Terraform files for e-commerce security requirements
          terraform_files = []
          for root, dirs, files in os.walk('terraform/'):
            for file in files:
              if file.endswith('.tf'):
                terraform_files.append(os.path.join(root, file))
          
          for tf_file in terraform_files:
            with open(tf_file, 'r') as f:
              content = f.read().lower()
              
              # Check for encryption
              if 'encrypted = true' in content or 'encryption' in content:
                ecommerce_requirements['encryption_at_rest'] = True
              
              # Check for SSL/TLS
              if 'ssl_policy' in content or 'certificate_arn' in content:
                ecommerce_requirements['encryption_in_transit'] = True
              
              # Check for VPC Flow Logs
              if 'aws_flow_log' in content:
                ecommerce_requirements['vpc_flow_logs'] = True
              
              # Check for CloudTrail
              if 'aws_cloudtrail' in content:
                ecommerce_requirements['cloudtrail_enabled'] = True
              
              # Check for WAF
              if 'aws_wafv2' in content or 'aws_waf' in content:
                ecommerce_requirements['waf_enabled'] = True
              
              # Check for backups
              if 'backup' in content or 'snapshot' in content:
                ecommerce_requirements['backup_enabled'] = True
          
          print("🛡️ E-commerce Security Requirements Check:")
          for req, status in ecommerce_requirements.items():
            status_icon = "✅" if status else "❌"
            print(f"{status_icon} {req.replace('_', ' ').title()}: {status}")
          
          # Fail if critical requirements not met
          critical_reqs = ['encryption_at_rest', 'encryption_in_transit', 'cloudtrail_enabled']
          missing_critical = [req for req in critical_reqs if not ecommerce_requirements[req]]
          
          if missing_critical:
            print(f"\n❌ Critical security requirements missing: {missing_critical}")
            exit(1)
          else:
            print("\n✅ All critical e-commerce security requirements met")
          EOF

  kubernetes-security:
    needs: infrastructure-analysis
    if: needs.infrastructure-analysis.outputs.k8s-changed == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: E-commerce K8s Security Scan
        run: |
          # Install security tools
          curl -L https://github.com/FairwindsOps/polaris/releases/latest/download/polaris_linux_amd64.tar.gz | tar xz
          
          # Run Polaris audit
          ./polaris audit --audit-path k8s/ --format json > polaris-results.json
          
          # E-commerce specific K8s security checks
          python3 << 'EOF'
          import yaml
          import json
          import glob
          
          security_score = 100
          issues = []
          
          # Load Polaris results
          with open('polaris-results.json') as f:
            polaris_data = json.load(f)
          
          # Check Polaris results
          for result in polaris_data.get('Results', []):
            if result.get('Severity') == 'error':
              security_score -= 10
              issues.append(f"Critical: {result.get('Message', 'Unknown issue')}")
            elif result.get('Severity') == 'warning':
              security_score -= 5
              issues.append(f"Warning: {result.get('Message', 'Unknown issue')}")
          
          # E-commerce specific checks
          ecommerce_checks = {
            'network_policies': False,
            'pod_security_policies': False,
            'resource_limits': False,
            'secrets_management': False,
            'service_mesh': False
          }
          
          for file in glob.glob("k8s/**/*.yaml", recursive=True):
            try:
              with open(file) as f:
                docs = yaml.safe_load_all(f)
                for doc in docs:
                  if not doc:
                    continue
                  
                  kind = doc.get('kind', '')
                  
                  # Check for NetworkPolicy
                  if kind == 'NetworkPolicy':
                    ecommerce_checks['network_policies'] = True
                  
                  # Check for PodSecurityPolicy
                  if kind == 'PodSecurityPolicy':
                    ecommerce_checks['pod_security_policies'] = True
                  
                  # Check for resource limits
                  if kind in ['Deployment', 'StatefulSet', 'DaemonSet']:
                    containers = doc.get('spec', {}).get('template', {}).get('spec', {}).get('containers', [])
                    for container in containers:
                      if container.get('resources', {}).get('limits'):
                        ecommerce_checks['resource_limits'] = True
                  
                  # Check for Secrets
                  if kind == 'Secret':
                    ecommerce_checks['secrets_management'] = True
                  
                  # Check for Istio/Service Mesh
                  if 'istio' in str(doc).lower() or kind in ['VirtualService', 'DestinationRule']:
                    ecommerce_checks['service_mesh'] = True
            except:
              continue
          
          print(f"🛡️ E-commerce Kubernetes Security Score: {security_score}/100")
          print("\n📊 Security Features:")
          for check, enabled in ecommerce_checks.items():
            status = "✅" if enabled else "❌"
            print(f"{status} {check.replace('_', ' ').title()}")
          
          if issues:
            print("\n⚠️ Security Issues:")
            for issue in issues[:10]:  # Show top 10 issues
              print(f"  - {issue}")
          
          # Fail if score too low
          if security_score < 70:
            print(f"\n❌ Security score too low: {security_score}/100 (minimum: 70)")
            exit(1)
          else:
            print(f"\n✅ Security score acceptable: {security_score}/100")
          EOF

  compliance-check:
    needs: [terraform-security, kubernetes-security]
    if: always() && (needs.terraform-security.result == 'success' || needs.kubernetes-security.result == 'success')
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: PCI DSS Compliance Check
        run: |
          # E-commerce PCI DSS compliance requirements
          python3 << 'EOF'
          import os
          import glob
          
          pci_requirements = {
            'network_segmentation': False,
            'encryption_at_rest': False,
            'encryption_in_transit': False,
            'access_control': False,
            'monitoring_logging': False,
            'vulnerability_management': False
          }
          
          # Check infrastructure files
          all_files = glob.glob("**/*.tf", recursive=True) + glob.glob("**/*.yaml", recursive=True)
          
          for file in all_files:
            try:
              with open(file, 'r') as f:
                content = f.read().lower()
                
                # Network segmentation
                if any(term in content for term in ['networkpolicy', 'security_group', 'firewall']):
                  pci_requirements['network_segmentation'] = True
                
                # Encryption at rest
                if any(term in content for term in ['encrypted = true', 'encryption', 'kms']):
                  pci_requirements['encryption_at_rest'] = True
                
                # Encryption in transit
                if any(term in content for term in ['tls', 'ssl', 'https', 'certificate']):
                  pci_requirements['encryption_in_transit'] = True
                
                # Access control
                if any(term in content for term in ['rbac', 'iam', 'role', 'policy']):
                  pci_requirements['access_control'] = True
                
                # Monitoring and logging
                if any(term in content for term in ['cloudtrail', 'logging', 'monitoring', 'audit']):
                  pci_requirements['monitoring_logging'] = True
                
                # Vulnerability management
                if any(term in content for term in ['security', 'scan', 'vulnerability']):
                  pci_requirements['vulnerability_management'] = True
            except:
              continue
          
          print("💳 PCI DSS Compliance Check:")
          compliance_score = 0
          for req, status in pci_requirements.items():
            status_icon = "✅" if status else "❌"
            print(f"{status_icon} {req.replace('_', ' ').title()}")
            if status:
              compliance_score += 1
          
          compliance_percentage = (compliance_score / len(pci_requirements)) * 100
          print(f"\n📊 PCI DSS Compliance Score: {compliance_percentage:.1f}%")
          
          if compliance_percentage < 80:
            print("❌ PCI DSS compliance requirements not met")
            exit(1)
          else:
            print("✅ PCI DSS compliance requirements satisfied")
          EOF

  security-report:
    needs: [terraform-security, kubernetes-security, compliance-check]
    if: always()
    runs-on: ubuntu-latest
    
    steps:
      - name: Generate Security Summary
        run: |
          cat > security-summary.md << 'EOF'
          # Infrastructure Security Report
          
          ## Scan Results
          - **Terraform Security**: ${{ needs.terraform-security.result }}
          - **Kubernetes Security**: ${{ needs.kubernetes-security.result }}
          - **Compliance Check**: ${{ needs.compliance-check.result }}
          
          ## E-commerce Security Requirements
          - Encryption at rest and in transit
          - Network segmentation and access controls
          - Audit logging and monitoring
          - PCI DSS compliance measures
          
          ## Recommendations
          - Review and address all security findings
          - Implement missing security controls
          - Regular security scanning in CI/CD
          - Continuous compliance monitoring
          EOF
          
      - name: Upload Security Report
        uses: actions/upload-artifact@v4
        with:
          name: infrastructure-security-report
          path: security-summary.md
```

---

## 🎯 Hands-On Lab: Infrastructure Security Pipeline

### **Lab Objective**
Implement comprehensive infrastructure security scanning for an e-commerce platform with Terraform and Kubernetes configurations.

### **Lab Steps**

1. **Setup Infrastructure Code**
```bash
# Create infrastructure structure
mkdir -p terraform/{modules,environments}
mkdir -p k8s/{base,overlays}

# Add sample Terraform configuration
cat > terraform/main.tf << 'EOF'
resource "aws_s3_bucket" "ecommerce_data" {
  bucket = "ecommerce-customer-data"
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
EOF
```

2. **Implement Security Scanning**
```bash
# Create security workflow
cp examples/infrastructure-security.yml .github/workflows/

# Test security scanning
git add terraform/ k8s/
git commit -m "Add infrastructure security scanning"
git push
```

3. **Add Compliance Checks**
```bash
# Create compliance validation
mkdir -p scripts
cat > scripts/pci-compliance-check.py << 'EOF'
# PCI DSS compliance validation script
# Implementation from examples above
EOF
```

4. **Validate Security Pipeline**
```bash
# Check security scan results
gh run list --workflow="Infrastructure Security"
gh run view --log
```

### **Expected Results**
- Comprehensive IaC security scanning
- E-commerce specific compliance validation
- Automated security policy enforcement
- Detailed security reporting and remediation guidance

---

## 📚 Best Practices Summary

### **IaC Security**
- **Scan early and often** in the development lifecycle
- **Use multiple tools** for comprehensive coverage
- **Implement policy as code** for consistent enforcement
- **Monitor compliance** continuously
- **Automate remediation** where possible

### **E-commerce Specific**
- **PCI DSS compliance** for payment processing
- **Data encryption** at rest and in transit
- **Network segmentation** for sensitive workloads
- **Access controls** with least privilege
- **Audit logging** for compliance and forensics

---

## 🎯 Module Assessment

### **Knowledge Check**
1. What are the key components of infrastructure security scanning?
2. How do you implement PCI DSS compliance in IaC?
3. What tools are most effective for Terraform and Kubernetes security?
4. How do you integrate security scanning into CI/CD pipelines?

### **Practical Exercise**
Implement a complete infrastructure security pipeline that includes:
- Multi-tool security scanning for Terraform and Kubernetes
- E-commerce compliance validation (PCI DSS)
- Automated policy enforcement
- Security reporting and remediation workflows

### **Success Criteria**
- [ ] Comprehensive security scanning implementation
- [ ] E-commerce compliance validation
- [ ] Automated policy enforcement
- [ ] Clear security reporting
- [ ] Integration with existing CI/CD pipelines

---

**Next Module**: [Enterprise Patterns](./20-Enterprise-Patterns.md) - Learn organization-wide CI/CD strategies
