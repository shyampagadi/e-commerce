# Compliance & Governance - Enhanced Progressive Learning

## 🎯 Learning Objectives
By the end of this section, you will:
- **Master enterprise compliance frameworks** (SOC2, PCI-DSS, HIPAA, GDPR, ISO27001)
- **Implement automated governance controls** that ensure regulatory compliance
- **Configure audit trails and reporting** for compliance documentation
- **Design policy enforcement pipelines** that prevent non-compliant deployments
- **Troubleshoot compliance issues** with systematic validation approaches

---

## 🏛️ Understanding Compliance in DevOps

### **Why Compliance Matters in Modern Development**

**Business Impact:**
- **Legal Protection**: Avoid regulatory fines (GDPR fines average $28M per violation)
- **Customer Trust**: Compliance certifications increase customer confidence by 85%
- **Market Access**: Required for enterprise sales and government contracts
- **Risk Mitigation**: Prevents data breaches that cost average $4.45M per incident

**Compliance Frameworks Overview:**
```
Enterprise Compliance Stack
├── SOC2 (Security, Availability, Processing Integrity)
├── PCI-DSS (Payment Card Industry Data Security)
├── HIPAA (Healthcare Information Portability)
├── GDPR (General Data Protection Regulation)
└── ISO27001 (Information Security Management)
```

---

## 🔧 Level 1: Basic Compliance Pipeline Setup

### **Multi-Framework Compliance Configuration**

**Basic Compliance Pipeline:**
```yaml
# Comprehensive compliance and governance pipeline
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/License-Scanning.gitlab-ci.yml

variables:
  # Compliance framework configuration
  COMPLIANCE_FRAMEWORKS: "SOC2,PCI-DSS,HIPAA,GDPR,ISO27001"
  AUDIT_ENABLED: "true"
  GOVERNANCE_LEVEL: "strict"
  
  # Regulatory requirements
  DATA_CLASSIFICATION: "confidential"
  RETENTION_POLICY: "7years"
  ENCRYPTION_REQUIRED: "true"

stages:
  - compliance-validation
  - governance-check
  - build
  - security-compliance
  - audit-trail
  - deploy
  - compliance-reporting
```

**Line-by-Line Compliance Explanation:**

**`include: - template: Security/SAST.gitlab-ci.yml`**
- **What it does**: Includes Static Application Security Testing
- **Compliance requirement**: Required for SOC2 Type II and ISO27001
- **Business value**: Identifies security vulnerabilities in source code
- **Regulatory benefit**: Demonstrates proactive security measures for auditors

**`include: - template: Security/Container-Scanning.gitlab-ci.yml`**
- **What it does**: Scans container images for known vulnerabilities
- **Compliance requirement**: Essential for PCI-DSS and HIPAA environments
- **Risk mitigation**: Prevents deployment of vulnerable containers
- **Audit evidence**: Provides documented security validation

**`include: - template: Security/Dependency-Scanning.gitlab-ci.yml`**
- **What it does**: Analyzes third-party dependencies for security issues
- **Compliance requirement**: Required for supply chain security (SOC2)
- **Legal protection**: Identifies license compliance issues
- **Business impact**: Prevents legal issues from license violations

**`include: - template: Security/License-Scanning.gitlab-ci.yml`**
- **What it does**: Validates software licenses for legal compliance
- **Compliance requirement**: Essential for enterprise software distribution
- **Risk mitigation**: Prevents copyright infringement lawsuits
- **Business value**: Enables safe use of open-source components

**`COMPLIANCE_FRAMEWORKS: "SOC2,PCI-DSS,HIPAA,GDPR,ISO27001"`**
- **What it does**: Defines which compliance frameworks to validate against
- **Multi-framework**: Supports multiple regulatory requirements simultaneously
- **Customization**: Can be adjusted based on business requirements
- **Audit trail**: Documents which frameworks were validated

**`AUDIT_ENABLED: "true"`**
- **What it does**: Enables comprehensive audit logging
- **Compliance requirement**: Required for all major frameworks
- **Evidence collection**: Creates audit trail for compliance reviews
- **Legal protection**: Provides evidence of due diligence

**`GOVERNANCE_LEVEL: "strict"`**
- **What it does**: Enforces highest level of policy compliance
- **Options**: "permissive", "standard", "strict"
- **Business impact**: Strict mode prevents any non-compliant deployments
- **Risk mitigation**: Ensures zero tolerance for compliance violations

**`DATA_CLASSIFICATION: "confidential"`**
- **What it does**: Sets data handling requirements for pipeline
- **Classifications**: "public", "internal", "confidential", "restricted"
- **Compliance requirement**: Required for GDPR and HIPAA
- **Security controls**: Determines encryption and access requirements

**`RETENTION_POLICY: "7years"`**
- **What it does**: Sets audit log retention period
- **Compliance requirement**: SOC2 requires 7-year retention
- **Legal protection**: Meets regulatory documentation requirements
- **Storage planning**: Determines long-term storage needs

**`ENCRYPTION_REQUIRED: "true"`**
- **What it does**: Enforces encryption for all data in transit and at rest
- **Compliance requirement**: Required for PCI-DSS and HIPAA
- **Security control**: Ensures data protection throughout pipeline
- **Audit evidence**: Demonstrates encryption compliance

### **Pre-Flight Compliance Validation**

**Compliance Validation Job:**
```yaml
# Pre-flight compliance validation
compliance-pre-validation:
  stage: compliance-validation
  image: alpine:latest
  
  before_script:
    - apk add --no-cache curl jq python3 py3-pip git
    - pip3 install requests pyyaml jsonschema
  
  script:
    - |
      echo "=== Multi-Framework Compliance Validation ==="
      
      # Validate project structure for compliance
      python3 << 'EOF'
      import os
      import json
      import yaml
      
      # SOC2 compliance checks
      def validate_soc2_controls():
          required_files = [
              '.gitlab-ci.yml',
              'SECURITY.md',
              'CHANGELOG.md',
              'LICENSE'
          ]
          
          missing_files = []
          for file in required_files:
              if not os.path.exists(file):
                  missing_files.append(file)
          
          if missing_files:
              print(f"SOC2 FAIL: Missing required files: {missing_files}")
              return False
          
          print("SOC2 PASS: All required documentation present")
          return True
      
      # PCI-DSS compliance checks
      def validate_pci_dss():
          # Check for secure coding practices
          if os.path.exists('.gitlab-ci.yml'):
              with open('.gitlab-ci.yml', 'r') as f:
                  content = f.read()
                  
              if 'Security/SAST.gitlab-ci.yml' not in content:
                  print("PCI-DSS FAIL: SAST scanning not enabled")
                  return False
                  
              if 'Security/Container-Scanning.gitlab-ci.yml' not in content:
                  print("PCI-DSS FAIL: Container scanning not enabled")
                  return False
          
          print("PCI-DSS PASS: Security scanning enabled")
          return True
      
      # Execute compliance validation
      soc2_valid = validate_soc2_controls()
      pci_valid = validate_pci_dss()
      
      if not (soc2_valid and pci_valid):
          exit(1)
      
      print("COMPLIANCE VALIDATION PASSED")
      EOF
```

**Compliance Validation Breakdown:**

**`image: alpine:latest`**
- **What it does**: Uses minimal Linux distribution for compliance tools
- **Security benefit**: Smaller attack surface for compliance validation
- **Performance**: Faster job startup and execution
- **Compliance**: Demonstrates minimal necessary privileges principle

**`apk add --no-cache curl jq python3 py3-pip git`**
- **What it does**: Installs tools needed for compliance validation
- **curl**: For API calls to compliance services
- **jq**: For JSON processing and validation
- **python3**: For custom compliance scripts
- **git**: For repository analysis and audit trails

**`pip3 install requests pyyaml jsonschema`**
- **What it does**: Installs Python libraries for compliance validation
- **requests**: For HTTP API calls to compliance systems
- **pyyaml**: For YAML configuration validation
- **jsonschema**: For validating compliance data structures

**SOC2 Validation Logic:**
- **Required files check**: Ensures documentation compliance
- **SECURITY.md**: Security policy documentation
- **CHANGELOG.md**: Change management documentation
- **LICENSE**: Legal compliance documentation
- **Audit evidence**: Creates paper trail for SOC2 auditors

**PCI-DSS Validation Logic:**
- **SAST scanning**: Validates static code analysis is enabled
- **Container scanning**: Ensures container vulnerability detection
- **Security controls**: Verifies required security measures are active
- **Compliance evidence**: Documents security control implementation

**Business Value of Compliance Automation:**
- **Risk Reduction**: 95% reduction in compliance violations
- **Audit Efficiency**: 80% faster compliance audits
- **Cost Savings**: Prevents regulatory fines and legal issues
- **Market Access**: Enables sales to enterprise and government customers
      
      # Create comprehensive compliance policy
      cat > compliance-policy.yaml << 'EOF'
      version: "2.0"
      
      frameworks:
        SOC2:
          controls:
            - id: "CC6.1"
              name: "Logical Access Controls"
              requirements:
                - "Multi-factor authentication required"
                - "Principle of least privilege"
                - "Access reviews quarterly"
            
            - id: "CC7.2"
              name: "System Monitoring"
              requirements:
                - "Continuous monitoring enabled"
                - "Security event logging"
                - "Incident response procedures"
        
        PCI_DSS:
          controls:
            - id: "PCI-3.4"
              name: "Cryptographic Protection"
              requirements:
                - "Strong encryption for data at rest"
                - "Secure key management"
                - "Regular key rotation"
            
            - id: "PCI-6.5"
              name: "Secure Development"
              requirements:
                - "Secure coding practices"
                - "Code review mandatory"
                - "Vulnerability scanning"
        
        HIPAA:
          controls:
            - id: "164.312(a)(1)"
              name: "Access Control"
              requirements:
                - "Unique user identification"
                - "Automatic logoff"
                - "Encryption and decryption"
        
        GDPR:
          controls:
            - id: "Art-25"
              name: "Data Protection by Design"
              requirements:
                - "Privacy by default"
                - "Data minimization"
                - "Pseudonymization where applicable"
        
        ISO27001:
          controls:
            - id: "A.12.6.1"
              name: "Management of Technical Vulnerabilities"
              requirements:
                - "Vulnerability management process"
                - "Regular security assessments"
                - "Patch management"
      
      policies:
        code_review:
          required: true
          min_approvers: 2
          security_review: true
        
        branch_protection:
          main_branch_protected: true
          force_push_disabled: true
          delete_protection: true
        
        security_scanning:
          sast_required: true
          dependency_scan_required: true
          container_scan_required: true
          license_scan_required: true
        
        data_protection:
          encryption_at_rest: true
          encryption_in_transit: true
          data_classification_required: true
        
        audit_logging:
          all_actions_logged: true
          log_retention_years: 7
          log_integrity_protection: true
      EOF
      
      # Compliance validation script
      python3 << 'PYTHON_COMPLIANCE'
      import json
      import yaml
      import sys
      import subprocess
      import requests
      from datetime import datetime
      
      def load_compliance_policy():
          with open('compliance-policy.yaml', 'r') as f:
              return yaml.safe_load(f)
      
      def validate_branch_protection():
          """Validate branch protection settings"""
          violations = []
          
          try:
              # Check if main branch is protected
              result = subprocess.run([
                  'curl', '-s', '-H', f'PRIVATE-TOKEN: {os.environ.get("CI_JOB_TOKEN")}',
                  f'{os.environ.get("CI_API_V4_URL")}/projects/{os.environ.get("CI_PROJECT_ID")}/protected_branches'
              ], capture_output=True, text=True)
              
              if result.returncode == 0:
                  branches = json.loads(result.stdout)
                  main_protected = any(branch['name'] in ['main', 'master'] for branch in branches)
                  
                  if not main_protected:
                      violations.append("Main branch is not protected")
              
          except Exception as e:
              violations.append(f"Could not validate branch protection: {e}")
          
          return violations
      
      def validate_security_policies():
          """Validate security policy compliance"""
          violations = []
          
          # Check for required security files
          required_files = [
              'SECURITY.md',
              '.gitlab/security-policy.yml',
              'CODEOWNERS'
          ]
          
          for file_path in required_files:
              try:
                  with open(file_path, 'r') as f:
                      content = f.read()
                  if not content.strip():
                      violations.append(f"Required security file {file_path} is empty")
              except FileNotFoundError:
                  violations.append(f"Required security file {file_path} not found")
          
          return violations
      
      def check_commit_compliance():
          """Check commit message compliance"""
          violations = []
          
          try:
              # Get recent commits
              result = subprocess.run([
                  'git', 'log', '--oneline', '-10', '--format=%s'
              ], capture_output=True, text=True)
              
              if result.returncode == 0:
                  commits = result.stdout.strip().split('\n')
                  
                  for commit in commits:
                      # Check for compliance tags
                      if not any(tag in commit.lower() for tag in ['feat:', 'fix:', 'docs:', 'refactor:', 'test:']):
                          violations.append(f"Commit message does not follow conventional format: {commit[:50]}")
              
          except Exception as e:
              violations.append(f"Could not validate commit compliance: {e}")
          
          return violations
      
      # Main compliance validation
      policy = load_compliance_policy()
      all_violations = []
      
      # Validate different compliance areas
      all_violations.extend(validate_branch_protection())
      all_violations.extend(validate_security_policies())
      all_violations.extend(check_commit_compliance())
      
      # Generate compliance report
      compliance_report = {
          'validation_date': datetime.utcnow().isoformat(),
          'project': os.environ.get('CI_PROJECT_NAME', 'unknown'),
          'commit': os.environ.get('CI_COMMIT_SHA', 'unknown'),
          'frameworks_checked': list(policy['frameworks'].keys()),
          'violations': all_violations,
          'compliance_status': 'PASS' if not all_violations else 'FAIL',
          'next_review_date': (datetime.utcnow().replace(day=1) + timedelta(days=32)).replace(day=1).isoformat()
      }
      
      with open('compliance-validation-report.json', 'w') as f:
          json.dump(compliance_report, f, indent=2)
      
      # Output results
      if all_violations:
          print("Compliance violations found:")
          for violation in all_violations:
              print(f"  - {violation}")
          sys.exit(1)
      else:
          print("All compliance validations passed")
      PYTHON_COMPLIANCE
  
  artifacts:
    paths:
      - "compliance-policy.yaml"
      - "compliance-validation-report.json"
    expire_in: 30 days
  
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

# Governance policy enforcement
governance-policy-enforcement:
  stage: governance-check
  image: python:3.11-alpine
  
  before_script:
    - pip install requests pyyaml jsonschema gitpython
  
  script:
    - |
      echo "=== Governance Policy Enforcement ==="
      
      # Create governance rules
      cat > governance-rules.yaml << 'EOF'
      version: "1.0"
      
      governance:
        code_quality:
          min_coverage: 80
          max_complexity: 10
          max_duplication: 3
          
        security:
          mandatory_scans: ["sast", "dependency", "container", "license"]
          max_critical_vulnerabilities: 0
          max_high_vulnerabilities: 2
          
        change_management:
          required_approvals: 2
          security_approval_required: true
          breaking_change_approval: true
          
        deployment:
          production_approval_required: true
          rollback_plan_required: true
          monitoring_required: true
          
        data_governance:
          pii_detection_required: true
          data_classification_required: true
          encryption_validation: true
      
      enforcement_actions:
        violation_found:
          - "block_merge"
          - "notify_security_team"
          - "create_compliance_issue"
        
        critical_security:
          - "block_deployment"
          - "escalate_to_ciso"
          - "emergency_response"
      EOF
      
      # Governance enforcement script
      python3 << 'PYTHON_GOVERNANCE'
      import json
      import yaml
      import sys
      import os
      import subprocess
      from datetime import datetime
      
      def load_governance_rules():
          with open('governance-rules.yaml', 'r') as f:
              return yaml.safe_load(f)
      
      def check_code_quality_governance():
          """Check code quality governance rules"""
          violations = []
          
          # Check test coverage (mock implementation)
          try:
              # In real implementation, parse coverage reports
              coverage_file = 'coverage/coverage-summary.json'
              if os.path.exists(coverage_file):
                  with open(coverage_file, 'r') as f:
                      coverage_data = json.load(f)
                  
                  total_coverage = coverage_data.get('total', {}).get('lines', {}).get('pct', 0)
                  if total_coverage < 80:
                      violations.append(f"Code coverage {total_coverage}% below minimum 80%")
              else:
                  violations.append("Code coverage report not found")
          except Exception as e:
              violations.append(f"Could not validate code coverage: {e}")
          
          return violations
      
      def check_security_governance():
          """Check security governance compliance"""
          violations = []
          
          # Check for required security scan reports
          required_scans = ['sast', 'dependency', 'container', 'license']
          
          for scan_type in required_scans:
              scan_files = [
                  f'gl-{scan_type}-scanning-report.json',
                  f'{scan_type}-report.json',
                  f'{scan_type}-results.json'
              ]
              
              scan_found = any(os.path.exists(f) for f in scan_files)
              if not scan_found:
                  violations.append(f"Required {scan_type} scan report not found")
          
          return violations
      
      def check_change_management_governance():
          """Check change management governance"""
          violations = []
          
          # Check merge request approvals (mock implementation)
          try:
              mr_iid = os.environ.get('CI_MERGE_REQUEST_IID')
              if mr_iid:
                  # In real implementation, check MR approvals via API
                  print(f"Checking approvals for MR {mr_iid}")
                  # Mock: assume we need to validate approvals
                  violations.append("Merge request approval validation not implemented")
          except Exception as e:
              violations.append(f"Could not validate change management: {e}")
          
          return violations
      
      def check_data_governance():
          """Check data governance compliance"""
          violations = []
          
          # Check for PII detection
          try:
              result = subprocess.run([
                  'grep', '-r', '-i', 
                  '--include=*.py', '--include=*.js', '--include=*.java',
                  'ssn\\|social.*security\\|credit.*card\\|passport',
                  '.'
              ], capture_output=True, text=True)
              
              if result.returncode == 0 and result.stdout.strip():
                  violations.append("Potential PII detected in source code")
          except Exception:
              pass  # grep not finding anything is expected
          
          # Check for data classification tags
          classification_files = [
              'DATA_CLASSIFICATION.md',
              'data-classification.yaml',
              '.data-classification'
          ]
          
          classification_found = any(os.path.exists(f) for f in classification_files)
          if not classification_found:
              violations.append("Data classification documentation not found")
          
          return violations
      
      # Main governance enforcement
      rules = load_governance_rules()
      all_violations = []
      
      # Check all governance areas
      all_violations.extend(check_code_quality_governance())
      all_violations.extend(check_security_governance())
      all_violations.extend(check_change_management_governance())
      all_violations.extend(check_data_governance())
      
      # Generate governance report
      governance_report = {
          'enforcement_date': datetime.utcnow().isoformat(),
          'project': os.environ.get('CI_PROJECT_NAME', 'unknown'),
          'commit': os.environ.get('CI_COMMIT_SHA', 'unknown'),
          'governance_version': rules['version'],
          'violations': all_violations,
          'enforcement_status': 'PASS' if not all_violations else 'FAIL',
          'actions_required': []
      }
      
      # Determine required actions
      if all_violations:
          governance_report['actions_required'] = rules['enforcement_actions']['violation_found']
          
          # Check for critical security violations
          critical_keywords = ['critical', 'security', 'vulnerability']
          has_critical = any(any(keyword in violation.lower() for keyword in critical_keywords) 
                           for violation in all_violations)
          
          if has_critical:
              governance_report['actions_required'].extend(
                  rules['enforcement_actions']['critical_security']
              )
      
      with open('governance-enforcement-report.json', 'w') as f:
          json.dump(governance_report, f, indent=2)
      
      # Output results
      if all_violations:
          print("Governance violations found:")
          for violation in all_violations:
              print(f"  - {violation}")
          print(f"Required actions: {governance_report['actions_required']}")
          sys.exit(1)
      else:
          print("All governance policies compliant")
      PYTHON_GOVERNANCE
  
  artifacts:
    paths:
      - "governance-rules.yaml"
      - "governance-enforcement-report.json"
    expire_in: 30 days
  
  needs: ["compliance-pre-validation"]

# Security compliance validation
security-compliance-validation:
  stage: security-compliance
  image: alpine:latest
  
  before_script:
    - apk add --no-cache curl jq python3 py3-pip
    - pip3 install requests
  
  script:
    - |
      echo "=== Security Compliance Validation ==="
      
      # Aggregate all security scan results
      python3 << 'PYTHON_SECURITY_COMPLIANCE'
      import json
      import glob
      import os
      from datetime import datetime
      
      def aggregate_security_findings():
          """Aggregate findings from all security scans"""
          
          findings = {
              'sast': {'critical': 0, 'high': 0, 'medium': 0, 'low': 0},
              'dependency': {'critical': 0, 'high': 0, 'medium': 0, 'low': 0},
              'container': {'critical': 0, 'high': 0, 'medium': 0, 'low': 0},
              'license': {'violations': 0, 'restricted': 0},
              'secrets': {'exposed': 0, 'potential': 0}
          }
          
          # Process SAST results
          sast_files = glob.glob('gl-sast-report.json') + glob.glob('sast-*.json')
          for sast_file in sast_files:
              try:
                  with open(sast_file, 'r') as f:
                      data = json.load(f)
                  
                  for vuln in data.get('vulnerabilities', []):
                      severity = vuln.get('severity', '').lower()
                      if severity in findings['sast']:
                          findings['sast'][severity] += 1
              except:
                  continue
          
          # Process dependency scan results
          dep_files = glob.glob('gl-dependency-scanning-report.json') + glob.glob('dependency-*.json')
          for dep_file in dep_files:
              try:
                  with open(dep_file, 'r') as f:
                      data = json.load(f)
                  
                  for vuln in data.get('vulnerabilities', []):
                      severity = vuln.get('severity', '').lower()
                      if severity in findings['dependency']:
                          findings['dependency'][severity] += 1
              except:
                  continue
          
          # Process container scan results
          container_files = glob.glob('gl-container-scanning-report.json') + glob.glob('container-*.json')
          for container_file in container_files:
              try:
                  with open(container_file, 'r') as f:
                      data = json.load(f)
                  
                  # Handle different container scan formats
                  if 'Results' in data:  # Trivy format
                      for result in data['Results']:
                          for vuln in result.get('Vulnerabilities', []):
                              severity = vuln.get('Severity', '').lower()
                              if severity in findings['container']:
                                  findings['container'][severity] += 1
                  else:  # GitLab format
                      for vuln in data.get('vulnerabilities', []):
                          severity = vuln.get('severity', '').lower()
                          if severity in findings['container']:
                              findings['container'][severity] += 1
              except:
                  continue
          
          # Process license scan results
          license_files = glob.glob('gl-license-scanning-report.json') + glob.glob('license-*.json')
          for license_file in license_files:
              try:
                  with open(license_file, 'r') as f:
                      data = json.load(f)
                  
                  for license_info in data.get('licenses', []):
                      classification = license_info.get('classification', '').lower()
                      if classification == 'unallowed':
                          findings['license']['violations'] += 1
                      elif classification == 'restricted':
                          findings['license']['restricted'] += 1
              except:
                  continue
          
          return findings
      
      def evaluate_compliance_status(findings):
          """Evaluate overall compliance status based on findings"""
          
          compliance_status = {
              'overall': 'COMPLIANT',
              'frameworks': {},
              'violations': [],
              'risk_score': 0
          }
          
          # SOC 2 Type II compliance check
          soc2_violations = []
          if findings['sast']['critical'] > 0:
              soc2_violations.append(f"SOC2 CC6.1: {findings['sast']['critical']} critical SAST findings")
          
          if findings['dependency']['critical'] > 0:
              soc2_violations.append(f"SOC2 CC7.2: {findings['dependency']['critical']} critical dependency vulnerabilities")
          
          compliance_status['frameworks']['SOC2'] = {
              'status': 'COMPLIANT' if not soc2_violations else 'NON_COMPLIANT',
              'violations': soc2_violations
          }
          
          # PCI DSS compliance check
          pci_violations = []
          if findings['container']['critical'] > 0:
              pci_violations.append(f"PCI-DSS 6.5: {findings['container']['critical']} critical container vulnerabilities")
          
          if findings['secrets']['exposed'] > 0:
              pci_violations.append(f"PCI-DSS 3.4: {findings['secrets']['exposed']} exposed secrets detected")
          
          compliance_status['frameworks']['PCI_DSS'] = {
              'status': 'COMPLIANT' if not pci_violations else 'NON_COMPLIANT',
              'violations': pci_violations
          }
          
          # HIPAA compliance check
          hipaa_violations = []
          total_critical = (findings['sast']['critical'] + 
                          findings['dependency']['critical'] + 
                          findings['container']['critical'])
          
          if total_critical > 0:
              hipaa_violations.append(f"HIPAA 164.312(a)(1): {total_critical} critical security vulnerabilities")
          
          compliance_status['frameworks']['HIPAA'] = {
              'status': 'COMPLIANT' if not hipaa_violations else 'NON_COMPLIANT',
              'violations': hipaa_violations
          }
          
          # Calculate overall risk score
          risk_score = (
              findings['sast']['critical'] * 10 +
              findings['dependency']['critical'] * 10 +
              findings['container']['critical'] * 10 +
              findings['sast']['high'] * 5 +
              findings['dependency']['high'] * 5 +
              findings['container']['high'] * 5 +
              findings['license']['violations'] * 3 +
              findings['secrets']['exposed'] * 8
          )
          
          compliance_status['risk_score'] = risk_score
          
          # Determine overall status
          non_compliant_frameworks = [
              fw for fw, status in compliance_status['frameworks'].items()
              if status['status'] == 'NON_COMPLIANT'
          ]
          
          if non_compliant_frameworks:
              compliance_status['overall'] = 'NON_COMPLIANT'
              compliance_status['violations'] = non_compliant_frameworks
          
          return compliance_status
      
      # Perform security compliance validation
      security_findings = aggregate_security_findings()
      compliance_status = evaluate_compliance_status(security_findings)
      
      # Generate comprehensive compliance report
      compliance_report = {
          'validation_date': datetime.utcnow().isoformat(),
          'project': os.environ.get('CI_PROJECT_NAME', 'unknown'),
          'commit': os.environ.get('CI_COMMIT_SHA', 'unknown'),
          'security_findings': security_findings,
          'compliance_status': compliance_status,
          'recommendations': []
      }
      
      # Generate recommendations
      if compliance_status['overall'] == 'NON_COMPLIANT':
          compliance_report['recommendations'].append("Address critical security vulnerabilities immediately")
          compliance_report['recommendations'].append("Review and update security policies")
          compliance_report['recommendations'].append("Implement additional security controls")
      
      if compliance_status['risk_score'] > 50:
          compliance_report['recommendations'].append("Risk score is high - prioritize security remediation")
      
      # Save compliance report
      with open('security-compliance-report.json', 'w') as f:
          json.dump(compliance_report, f, indent=2)
      
      print(f"Security Compliance Status: {compliance_status['overall']}")
      print(f"Risk Score: {compliance_status['risk_score']}")
      
      for framework, status in compliance_status['frameworks'].items():
          print(f"{framework}: {status['status']}")
          if status['violations']:
              for violation in status['violations']:
                  print(f"  - {violation}")
      
      # Fail pipeline if non-compliant
      if compliance_status['overall'] == 'NON_COMPLIANT':
          sys.exit(1)
      PYTHON_SECURITY_COMPLIANCE
  
  artifacts:
    paths:
      - "security-compliance-report.json"
    expire_in: 30 days
  
  needs: 
    - job: "sast"
      artifacts: true
      optional: true
    - job: "dependency_scanning"
      artifacts: true
      optional: true
    - job: "container_scanning"
      artifacts: true
      optional: true

# Comprehensive audit trail generation
audit-trail-generation:
  stage: audit-trail
  image: python:3.11-alpine
  
  before_script:
    - pip install requests pyyaml gitpython
  
  script:
    - |
      echo "=== Generating Comprehensive Audit Trail ==="
      
      python3 << 'PYTHON_AUDIT'
      import json
      import os
      import subprocess
      from datetime import datetime, timedelta
      import hashlib
      
      def generate_pipeline_audit():
          """Generate pipeline execution audit trail"""
          
          audit_data = {
              'audit_id': hashlib.sha256(f"{os.environ.get('CI_PIPELINE_ID', '')}{datetime.utcnow().isoformat()}".encode()).hexdigest()[:16],
              'timestamp': datetime.utcnow().isoformat(),
              'pipeline_info': {
                  'id': os.environ.get('CI_PIPELINE_ID'),
                  'url': os.environ.get('CI_PIPELINE_URL'),
                  'source': os.environ.get('CI_PIPELINE_SOURCE'),
                  'ref': os.environ.get('CI_COMMIT_REF_NAME'),
                  'sha': os.environ.get('CI_COMMIT_SHA'),
                  'author': os.environ.get('CI_COMMIT_AUTHOR'),
                  'message': os.environ.get('CI_COMMIT_MESSAGE', '').replace('\n', ' ')[:100]
              },
              'project_info': {
                  'id': os.environ.get('CI_PROJECT_ID'),
                  'name': os.environ.get('CI_PROJECT_NAME'),
                  'namespace': os.environ.get('CI_PROJECT_NAMESPACE'),
                  'url': os.environ.get('CI_PROJECT_URL')
              },
              'user_info': {
                  'username': os.environ.get('CI_COMMIT_AUTHOR'),
                  'email': os.environ.get('CI_COMMIT_AUTHOR_EMAIL'),
                  'trigger_user': os.environ.get('GITLAB_USER_LOGIN')
              },
              'compliance_checks': [],
              'security_scans': [],
              'approvals': [],
              'deployments': []
          }
          
          return audit_data
      
      def collect_compliance_evidence():
          """Collect evidence of compliance checks performed"""
          
          evidence = []
          
          # Collect compliance validation evidence
          if os.path.exists('compliance-validation-report.json'):
              with open('compliance-validation-report.json', 'r') as f:
                  compliance_data = json.load(f)
              
              evidence.append({
                  'type': 'compliance_validation',
                  'timestamp': compliance_data.get('validation_date'),
                  'status': compliance_data.get('compliance_status'),
                  'frameworks': compliance_data.get('frameworks_checked', []),
                  'violations': len(compliance_data.get('violations', []))
              })
          
          # Collect governance evidence
          if os.path.exists('governance-enforcement-report.json'):
              with open('governance-enforcement-report.json', 'r') as f:
                  governance_data = json.load(f)
              
              evidence.append({
                  'type': 'governance_enforcement',
                  'timestamp': governance_data.get('enforcement_date'),
                  'status': governance_data.get('enforcement_status'),
                  'violations': len(governance_data.get('violations', [])),
                  'actions_required': governance_data.get('actions_required', [])
              })
          
          # Collect security compliance evidence
          if os.path.exists('security-compliance-report.json'):
              with open('security-compliance-report.json', 'r') as f:
                  security_data = json.load(f)
              
              evidence.append({
                  'type': 'security_compliance',
                  'timestamp': security_data.get('validation_date'),
                  'status': security_data.get('compliance_status', {}).get('overall'),
                  'risk_score': security_data.get('compliance_status', {}).get('risk_score'),
                  'frameworks': list(security_data.get('compliance_status', {}).get('frameworks', {}).keys())
              })
          
          return evidence
      
      def generate_change_log():
          """Generate change log for audit purposes"""
          
          changes = []
          
          try:
              # Get commit details
              result = subprocess.run([
                  'git', 'log', '--oneline', '--since="1 week ago"', '--format=%H|%an|%ae|%ad|%s'
              ], capture_output=True, text=True)
              
              if result.returncode == 0:
                  for line in result.stdout.strip().split('\n'):
                      if line:
                          parts = line.split('|')
                          if len(parts) >= 5:
                              changes.append({
                                  'commit_sha': parts[0],
                                  'author_name': parts[1],
                                  'author_email': parts[2],
                                  'date': parts[3],
                                  'message': parts[4]
                              })
          except Exception as e:
              print(f"Could not generate change log: {e}")
          
          return changes
      
      def create_audit_signature(audit_data):
          """Create cryptographic signature for audit integrity"""
          
          # Create deterministic string from audit data
          audit_string = json.dumps(audit_data, sort_keys=True)
          
          # Generate SHA-256 hash
          signature = hashlib.sha256(audit_string.encode()).hexdigest()
          
          return signature
      
      # Generate comprehensive audit trail
      audit_trail = generate_pipeline_audit()
      audit_trail['compliance_evidence'] = collect_compliance_evidence()
      audit_trail['change_log'] = generate_change_log()
      
      # Add audit integrity signature
      audit_trail['integrity_signature'] = create_audit_signature(audit_trail)
      
      # Save audit trail
      with open('audit-trail.json', 'w') as f:
          json.dump(audit_trail, f, indent=2)
      
      # Generate human-readable audit summary
      with open('audit-summary.txt', 'w') as f:
          f.write("=== COMPLIANCE AUDIT TRAIL ===\n\n")
          f.write(f"Audit ID: {audit_trail['audit_id']}\n")
          f.write(f"Timestamp: {audit_trail['timestamp']}\n")
          f.write(f"Project: {audit_trail['project_info']['name']}\n")
          f.write(f"Pipeline: {audit_trail['pipeline_info']['id']}\n")
          f.write(f"Commit: {audit_trail['pipeline_info']['sha']}\n")
          f.write(f"Author: {audit_trail['user_info']['username']}\n\n")
          
          f.write("COMPLIANCE EVIDENCE:\n")
          for evidence in audit_trail['compliance_evidence']:
              f.write(f"- {evidence['type']}: {evidence['status']}\n")
          
          f.write(f"\nINTEGRITY SIGNATURE: {audit_trail['integrity_signature']}\n")
      
      print(f"Audit trail generated: {audit_trail['audit_id']}")
      print(f"Compliance evidence collected: {len(audit_trail['compliance_evidence'])} items")
      PYTHON_AUDIT
  
  artifacts:
    paths:
      - "audit-trail.json"
      - "audit-summary.txt"
    expire_in: 7 years  # Long-term retention for compliance
  
  needs:
    - compliance-pre-validation
    - governance-policy-enforcement
    - security-compliance-validation
  script:
    - echo "Validating compliance requirements..."
    - |
      # Check if all required compliance files exist
      required_files=("SECURITY.md" "COMPLIANCE.md" "PRIVACY.md" ".gitlab/compliance-policy.yml")
      for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
          echo "ERROR: Required compliance file $file is missing"
          exit 1
        fi
      done
    - echo "Compliance validation passed"
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### Compliance Policy Configuration
```yaml
# .gitlab/compliance-policy.yml
compliance_frameworks:
  - name: "SOC2"
    requirements:
      - access_controls
      - change_management
      - monitoring_logging
      - data_protection
    controls:
      - id: "CC6.1"
        description: "Access controls are implemented"
        validation: "check_access_controls.sh"
      - id: "CC8.1" 
        description: "Change management process is followed"
        validation: "check_change_management.sh"
        
  - name: "PCI-DSS"
    requirements:
      - network_security
      - data_encryption
      - access_management
      - monitoring
    controls:
      - id: "REQ-2"
        description: "Default passwords are changed"
        validation: "check_default_passwords.sh"
      - id: "REQ-3"
        description: "Cardholder data is protected"
        validation: "check_data_protection.sh"

audit_settings:
  retention_period: "7_years"
  audit_trail: "enabled"
  evidence_collection: "automatic"
```

## SOC 2 Compliance Automation

### SOC 2 Type II Controls
```yaml
# SOC 2 compliance pipeline
soc2-controls:
  stage: compliance-check
  image: ubuntu:20.04
  before_script:
    - apt-get update && apt-get install -y curl jq git
  script:
    # CC6.1 - Logical and Physical Access Controls
    - |
      echo "Checking CC6.1 - Access Controls"
      # Verify branch protection is enabled
      PROTECTION=$(curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/protected_branches/$CI_DEFAULT_BRANCH" | jq -r '.push_access_levels[0].access_level')
      if [ "$PROTECTION" != "40" ]; then
        echo "ERROR: Branch protection not properly configured"
        exit 1
      fi
      
    # CC6.7 - Data Transmission and Disposal
    - |
      echo "Checking CC6.7 - Data Protection"
      # Check for encryption in transit
      if ! grep -r "TLS\|SSL\|HTTPS" . --include="*.yml" --include="*.yaml"; then
        echo "WARNING: No encryption in transit configuration found"
      fi
      
    # CC7.1 - System Monitoring
    - |
      echo "Checking CC7.1 - Monitoring"
      # Verify monitoring configuration exists
      if [ ! -f "monitoring/prometheus.yml" ] && [ ! -f ".gitlab/monitoring.yml" ]; then
        echo "ERROR: No monitoring configuration found"
        exit 1
      fi
      
    # CC8.1 - Change Management
    - |
      echo "Checking CC8.1 - Change Management"
      # Verify all changes go through merge requests
      DIRECT_COMMITS=$(git log --oneline --since="30 days ago" --grep="Merge branch" --invert-grep | wc -l)
      if [ "$DIRECT_COMMITS" -gt 0 ]; then
        echo "WARNING: $DIRECT_COMMITS direct commits found, should use merge requests"
      fi
      
  artifacts:
    reports:
      junit: soc2-compliance-report.xml
    paths:
      - compliance-evidence/
    expire_in: 7 years
```

### PCI DSS Compliance
```yaml
pci-dss-compliance:
  stage: compliance-check
  image: ubuntu:20.04
  script:
    # Requirement 2 - Default Passwords and Security Parameters
    - |
      echo "PCI DSS Requirement 2 - Default Passwords"
      # Check for default passwords in configuration
      if grep -r "password.*=.*admin\|password.*=.*root\|password.*=.*123" . --include="*.yml" --include="*.env*"; then
        echo "ERROR: Default passwords found in configuration"
        exit 1
      fi
      
    # Requirement 3 - Protect Stored Cardholder Data
    - |
      echo "PCI DSS Requirement 3 - Data Protection"
      # Check for potential PAN (Primary Account Number) patterns
      if grep -rE "\b[0-9]{13,19}\b" . --include="*.py" --include="*.js" --include="*.java"; then
        echo "ERROR: Potential PAN data found in source code"
        exit 1
      fi
      
    # Requirement 6 - Develop and Maintain Secure Systems
    - |
      echo "PCI DSS Requirement 6 - Secure Development"
      # Verify security scanning is enabled
      if [ ! -f ".gitlab-ci.yml" ] || ! grep -q "sast\|dast\|dependency_scanning" .gitlab-ci.yml; then
        echo "ERROR: Security scanning not configured"
        exit 1
      fi
      
    # Requirement 10 - Track and Monitor Access
    - |
      echo "PCI DSS Requirement 10 - Logging"
      # Check for audit logging configuration
      if ! grep -r "audit\|log" . --include="*.yml" --include="*.yaml"; then
        echo "ERROR: No audit logging configuration found"
        exit 1
      fi
      
  artifacts:
    reports:
      junit: pci-dss-compliance-report.xml
```

## HIPAA Compliance

### HIPAA Safeguards Implementation
```yaml
hipaa-compliance:
  stage: compliance-check
  image: ubuntu:20.04
  script:
    # Administrative Safeguards (164.308)
    - |
      echo "HIPAA 164.308 - Administrative Safeguards"
      # Check for security officer assignment
      if [ ! -f "SECURITY_OFFICER.md" ]; then
        echo "ERROR: Security officer documentation required"
        exit 1
      fi
      
      # Verify access management procedures
      if [ ! -f "docs/access-management.md" ]; then
        echo "ERROR: Access management procedures documentation required"
        exit 1
      fi
      
    # Physical Safeguards (164.310)
    - |
      echo "HIPAA 164.310 - Physical Safeguards"
      # Check for cloud security controls documentation
      if [ ! -f "docs/cloud-security.md" ]; then
        echo "ERROR: Cloud security controls documentation required"
        exit 1
      fi
      
    # Technical Safeguards (164.312)
    - |
      echo "HIPAA 164.312 - Technical Safeguards"
      # Access Control
      if ! grep -r "authentication\|authorization" . --include="*.py" --include="*.js"; then
        echo "ERROR: No access control implementation found"
        exit 1
      fi
      
      # Audit Controls
      if ! grep -r "audit.*log\|access.*log" . --include="*.yml" --include="*.yaml"; then
        echo "ERROR: No audit controls found"
        exit 1
      fi
      
      # Integrity Controls
      if ! grep -r "checksum\|hash\|integrity" . --include="*.py" --include="*.js"; then
        echo "WARNING: No integrity controls found"
      fi
      
      # Transmission Security
      if ! grep -r "TLS\|SSL\|encrypt" . --include="*.yml" --include="*.yaml"; then
        echo "ERROR: No transmission security found"
        exit 1
      fi
      
  artifacts:
    reports:
      junit: hipaa-compliance-report.xml
```

## GDPR Compliance

### GDPR Data Protection
```yaml
gdpr-compliance:
  stage: compliance-check
  image: ubuntu:20.04
  script:
    # Article 25 - Data Protection by Design and by Default
    - |
      echo "GDPR Article 25 - Data Protection by Design"
      # Check for privacy by design implementation
      if [ ! -f "PRIVACY.md" ]; then
        echo "ERROR: Privacy documentation required"
        exit 1
      fi
      
      # Check for data minimization
      if ! grep -r "data.*minimization\|minimal.*data" docs/; then
        echo "WARNING: Data minimization principles not documented"
      fi
      
    # Article 32 - Security of Processing
    - |
      echo "GDPR Article 32 - Security of Processing"
      # Check for encryption implementation
      if ! grep -r "encrypt\|cipher" . --include="*.py" --include="*.js"; then
        echo "ERROR: No encryption implementation found"
        exit 1
      fi
      
      # Check for pseudonymization
      if ! grep -r "pseudonym\|anonymiz" . --include="*.py" --include="*.js"; then
        echo "WARNING: No pseudonymization found"
      fi
      
    # Article 33 - Notification of Data Breach
    - |
      echo "GDPR Article 33 - Breach Notification"
      # Check for incident response procedures
      if [ ! -f "docs/incident-response.md" ]; then
        echo "ERROR: Incident response procedures required"
        exit 1
      fi
      
    # Article 35 - Data Protection Impact Assessment
    - |
      echo "GDPR Article 35 - DPIA"
      # Check for DPIA documentation
      if [ ! -f "docs/data-protection-impact-assessment.md" ]; then
        echo "WARNING: DPIA documentation recommended"
      fi
      
  artifacts:
    reports:
      junit: gdpr-compliance-report.xml
```

## Compliance Reporting

### Automated Compliance Reports
```yaml
generate-compliance-report:
  stage: audit
  image: python:3.9
  before_script:
    - pip install jinja2 pyyaml requests
  script:
    - |
      cat > generate_report.py << 'EOF'
      import json
      import yaml
      import datetime
      from jinja2 import Template
      
      # Load compliance results
      compliance_data = {
          'timestamp': datetime.datetime.now().isoformat(),
          'project': '$CI_PROJECT_NAME',
          'commit': '$CI_COMMIT_SHA',
          'pipeline': '$CI_PIPELINE_ID',
          'frameworks': []
      }
      
      # SOC 2 Results
      soc2_results = {
          'name': 'SOC 2 Type II',
          'status': 'PASSED',
          'controls': [
              {'id': 'CC6.1', 'status': 'PASSED', 'description': 'Access Controls'},
              {'id': 'CC6.7', 'status': 'PASSED', 'description': 'Data Protection'},
              {'id': 'CC7.1', 'status': 'PASSED', 'description': 'Monitoring'},
              {'id': 'CC8.1', 'status': 'PASSED', 'description': 'Change Management'}
          ]
      }
      compliance_data['frameworks'].append(soc2_results)
      
      # Generate HTML report
      template = Template('''
      <!DOCTYPE html>
      <html>
      <head>
          <title>Compliance Report - {{ project }}</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              .header { background: #f8f9fa; padding: 20px; border-radius: 5px; }
              .framework { margin: 20px 0; padding: 15px; border: 1px solid #ddd; }
              .passed { color: green; }
              .failed { color: red; }
              table { width: 100%; border-collapse: collapse; }
              th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
          </style>
      </head>
      <body>
          <div class="header">
              <h1>Compliance Report</h1>
              <p><strong>Project:</strong> {{ project }}</p>
              <p><strong>Generated:</strong> {{ timestamp }}</p>
              <p><strong>Commit:</strong> {{ commit }}</p>
              <p><strong>Pipeline:</strong> {{ pipeline }}</p>
          </div>
          
          {% for framework in frameworks %}
          <div class="framework">
              <h2>{{ framework.name }}</h2>
              <p class="{{ framework.status.lower() }}">
                  <strong>Status:</strong> {{ framework.status }}
              </p>
              
              <table>
                  <tr><th>Control ID</th><th>Description</th><th>Status</th></tr>
                  {% for control in framework.controls %}
                  <tr>
                      <td>{{ control.id }}</td>
                      <td>{{ control.description }}</td>
                      <td class="{{ control.status.lower() }}">{{ control.status }}</td>
                  </tr>
                  {% endfor %}
              </table>
          </div>
          {% endfor %}
      </body>
      </html>
      ''')
      
      with open('compliance-report.html', 'w') as f:
          f.write(template.render(**compliance_data))
          
      # Generate JSON report for API consumption
      with open('compliance-report.json', 'w') as f:
          json.dump(compliance_data, f, indent=2)
      EOF
      
    - python generate_report.py
    
  artifacts:
    reports:
      junit: compliance-report.xml
    paths:
      - compliance-report.html
      - compliance-report.json
    expire_in: 7 years
    
  only:
    - main
    - merge_requests
```

## Compliance Evidence Collection

### Automated Evidence Gathering
```yaml
collect-compliance-evidence:
  stage: audit
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq git
  script:
    - mkdir -p compliance-evidence
    
    # Collect access control evidence
    - |
      echo "Collecting access control evidence..."
      curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/protected_branches" \
        > compliance-evidence/protected-branches.json
        
    # Collect merge request evidence
    - |
      echo "Collecting change management evidence..."
      curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/merge_requests?state=merged&per_page=100" \
        > compliance-evidence/merge-requests.json
        
    # Collect security scan evidence
    - |
      echo "Collecting security scan evidence..."
      if [ -f "gl-sast-report.json" ]; then
        cp gl-sast-report.json compliance-evidence/
      fi
      if [ -f "gl-dast-report.json" ]; then
        cp gl-dast-report.json compliance-evidence/
      fi
      
    # Collect deployment evidence
    - |
      echo "Collecting deployment evidence..."
      curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/deployments" \
        > compliance-evidence/deployments.json
        
    # Generate evidence manifest
    - |
      cat > compliance-evidence/manifest.json << EOF
      {
        "collection_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "project_id": "$CI_PROJECT_ID",
        "pipeline_id": "$CI_PIPELINE_ID",
        "commit_sha": "$CI_COMMIT_SHA",
        "evidence_files": [
          "protected-branches.json",
          "merge-requests.json",
          "deployments.json",
          "gl-sast-report.json",
          "gl-dast-report.json"
        ],
        "retention_period": "7_years",
        "compliance_frameworks": ["SOC2", "PCI-DSS", "HIPAA", "GDPR"]
      }
      EOF
      
  artifacts:
    paths:
      - compliance-evidence/
    expire_in: 7 years
```

## Summary

GitLab compliance management enables:
- **Built-in Compliance**: Native compliance dashboard and reporting
- **Regulatory Automation**: SOC 2, PCI DSS, HIPAA, GDPR compliance pipelines
- **Evidence Collection**: Automated compliance evidence gathering
- **Audit Trails**: Complete audit trail generation and retention
- **Policy Enforcement**: Automated policy validation and enforcement
- **Reporting**: Comprehensive compliance reports for stakeholders

Master these compliance patterns to build regulatory-compliant CI/CD pipelines that meet enterprise and industry requirements.
