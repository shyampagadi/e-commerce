# 🏢 Enterprise Patterns: Organization-Wide CI/CD Strategies

## 📋 Learning Objectives
- **Master** organization-wide workflow templates and governance
- **Implement** enterprise-grade approval and compliance workflows
- **Configure** centralized security and policy enforcement
- **Build** scalable CI/CD architectures for large teams

---

## 🏗️ Enterprise Architecture Patterns

### **Organization Structure**

```
enterprise-org/
├── .github/
│   ├── workflows/
│   │   ├── reusable-security.yml      # Centralized security
│   │   ├── reusable-deployment.yml    # Standard deployment
│   │   └── reusable-compliance.yml    # Compliance checks
│   ├── actions/
│   │   ├── security-scan/             # Custom security action
│   │   ├── deploy-service/            # Deployment action
│   │   └── compliance-check/          # Compliance action
│   └── templates/
│       ├── service-template/          # Service repository template
│       └── library-template/          # Library repository template
├── teams/
│   ├── ecommerce-platform/           # Product team repos
│   ├── payment-services/             # Payment team repos
│   └── infrastructure/               # Platform team repos
└── policies/
    ├── security-policies.yml         # Security requirements
    ├── deployment-policies.yml       # Deployment rules
    └── compliance-policies.yml       # Compliance standards
```

### **Centralized Workflow Templates**

```yaml
# .github/workflows/reusable-security.yml
name: Enterprise Security Pipeline

on:
  workflow_call:
    inputs:
      language:
        required: true
        type: string
      security-level:
        required: false
        type: string
        default: 'standard'
      compliance-framework:
        required: false
        type: string
        default: 'pci-dss'
    secrets:
      security-token:
        required: true
      compliance-api-key:
        required: true

jobs:
  security-gate:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Load Security Policies
        run: |
          # Download organization security policies
          curl -H "Authorization: token ${{ secrets.security-token }}" \
            https://api.github.com/repos/${{ github.repository_owner }}/.github/contents/policies/security-policies.yml \
            | jq -r '.content' | base64 -d > security-policies.yml
            
      - name: Language-Specific Security Scan
        run: |
          case "${{ inputs.language }}" in
            "node")
              npm audit --audit-level=moderate
              npx eslint . --ext .js,.ts --format json > eslint-results.json
              ;;
            "python")
              pip install safety bandit
              safety check --json > safety-results.json
              bandit -r . -f json -o bandit-results.json
              ;;
            "java")
              ./gradlew dependencyCheckAnalyze
              ./gradlew spotbugsMain
              ;;
            "go")
              go mod download
              gosec -fmt json -out gosec-results.json ./...
              ;;
          esac
          
      - name: Enterprise Security Validation
        env:
          SECURITY_LEVEL: ${{ inputs.security-level }}
        run: |
          python3 << 'EOF'
          import yaml
          import json
          import os
          
          # Load security policies
          with open('security-policies.yml') as f:
            policies = yaml.safe_load(f)
          
          security_level = os.environ.get('SECURITY_LEVEL', 'standard')
          required_checks = policies.get('security_levels', {}).get(security_level, [])
          
          print(f"🔒 Enterprise Security Level: {security_level}")
          print(f"📋 Required Checks: {required_checks}")
          
          # Validate security requirements
          for check in required_checks:
            print(f"✅ {check} - Validated")
          
          # Check for critical vulnerabilities
          critical_found = False
          
          # Process language-specific results
          language = "${{ inputs.language }}"
          if language == "node" and os.path.exists('eslint-results.json'):
            with open('eslint-results.json') as f:
              eslint_data = json.load(f)
              for result in eslint_data:
                for message in result.get('messages', []):
                  if message.get('severity') == 2:  # Error level
                    critical_found = True
          
          if critical_found:
            print("❌ Critical security issues found")
            exit(1)
          else:
            print("✅ Security validation passed")
          EOF
          
      - name: Compliance Check
        env:
          COMPLIANCE_FRAMEWORK: ${{ inputs.compliance-framework }}
          COMPLIANCE_API_KEY: ${{ secrets.compliance-api-key }}
        run: |
          # Run compliance validation based on framework
          case "${{ inputs.compliance-framework }}" in
            "pci-dss")
              ./scripts/pci-dss-check.sh
              ;;
            "sox")
              ./scripts/sox-compliance-check.sh
              ;;
            "gdpr")
              ./scripts/gdpr-compliance-check.sh
              ;;
          esac
```

---

## 🔐 Enterprise Governance and Approval

### **Multi-Stage Approval Workflow**

```yaml
# .github/workflows/enterprise-deployment.yml
name: Enterprise Deployment Pipeline

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
      approval-override:
        description: 'Emergency deployment (requires justification)'
        required: false
        type: boolean
        default: false

jobs:
  # Security and compliance validation
  security-compliance:
    uses: ./.github/workflows/reusable-security.yml
    with:
      language: 'node'
      security-level: 'high'
      compliance-framework: 'pci-dss'
    secrets:
      security-token: ${{ secrets.ENTERPRISE_SECURITY_TOKEN }}
      compliance-api-key: ${{ secrets.COMPLIANCE_API_KEY }}

  # Development environment (auto-deploy)
  deploy-development:
    needs: security-compliance
    if: github.ref == 'refs/heads/develop' || github.event.inputs.environment == 'development'
    runs-on: ubuntu-latest
    environment: development
    
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Development
        run: ./scripts/deploy.sh development

  # Staging environment (team lead approval)
  deploy-staging:
    needs: security-compliance
    if: github.ref == 'refs/heads/main' || github.event.inputs.environment == 'staging'
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Staging Pre-deployment Checks
        run: |
          # Validate staging readiness
          ./scripts/pre-deployment-checks.sh staging
          
      - name: Deploy to Staging
        run: ./scripts/deploy.sh staging
        
      - name: Post-deployment Validation
        run: |
          # Run smoke tests
          ./scripts/smoke-tests.sh staging

  # Production environment (multi-level approval)
  production-approval:
    needs: deploy-staging
    if: github.event.inputs.environment == 'production' || (github.ref == 'refs/heads/main' && github.event.inputs.approval-override != true)
    runs-on: ubuntu-latest
    environment: production-approval
    
    steps:
      - name: Request Production Approval
        uses: actions/github-script@v7
        with:
          script: |
            // Create approval issue
            const { data: issue } = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Production Deployment Approval - ${context.sha.substring(0, 7)}`,
              body: `
              ## Production Deployment Request
              
              **Commit**: ${context.sha}
              **Branch**: ${context.ref}
              **Requested by**: @${context.actor}
              **Timestamp**: ${new Date().toISOString()}
              
              ### Changes
              ${context.payload.head_commit?.message || 'Manual deployment request'}
              
              ### Approval Requirements
              - [ ] Technical Lead Approval (@tech-lead)
              - [ ] Security Team Approval (@security-team)
              - [ ] Product Owner Approval (@product-owner)
              
              ### Pre-deployment Checklist
              - [ ] Security scan passed
              - [ ] Compliance validation completed
              - [ ] Staging deployment successful
              - [ ] Rollback plan prepared
              
              **Approve by commenting**: \`/approve production\`
              **Reject by commenting**: \`/reject [reason]\`
              `,
              labels: ['deployment', 'production', 'approval-required']
            });
            
            console.log(`Approval issue created: #${issue.number}`);

  deploy-production:
    needs: [production-approval, deploy-staging]
    if: github.event.inputs.approval-override == true || contains(github.event.comment.body, '/approve production')
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Production Deployment Gate
        env:
          EMERGENCY_DEPLOYMENT: ${{ github.event.inputs.approval-override }}
        run: |
          if [ "$EMERGENCY_DEPLOYMENT" = "true" ]; then
            echo "🚨 EMERGENCY DEPLOYMENT INITIATED"
            echo "Justification required in deployment logs"
            
            # Log emergency deployment
            curl -X POST "${{ secrets.AUDIT_WEBHOOK_URL }}" \
              -H "Content-Type: application/json" \
              -d '{
                "event": "emergency_deployment",
                "repository": "${{ github.repository }}",
                "actor": "${{ github.actor }}",
                "commit": "${{ github.sha }}",
                "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
              }'
          fi
          
      - name: Create Deployment Snapshot
        run: |
          # Create deployment artifact
          tar -czf deployment-${{ github.sha }}.tar.gz \
            --exclude='.git' \
            --exclude='node_modules' \
            --exclude='*.log' .
          
          # Upload to artifact store
          aws s3 cp deployment-${{ github.sha }}.tar.gz \
            s3://enterprise-deployments/production/
            
      - name: Deploy to Production
        run: |
          # Blue-green deployment
          ./scripts/deploy-blue-green.sh production
          
      - name: Post-deployment Monitoring
        run: |
          # Monitor for 15 minutes
          ./scripts/monitor-deployment.sh production 900
          
      - name: Notify Stakeholders
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Production deployment ${{ job.status }}
            Repository: ${{ github.repository }}
            Commit: ${{ github.sha }}
            Actor: ${{ github.actor }}
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_PRODUCTION }}
```

---

## 🎯 Multi-Repository Management

### **Organization-Wide Policy Enforcement**

```yaml
# .github/workflows/policy-enforcement.yml
name: Organization Policy Enforcement

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM
  workflow_dispatch:

jobs:
  audit-repositories:
    runs-on: ubuntu-latest
    
    steps:
      - name: Get Organization Repositories
        id: repos
        uses: actions/github-script@v7
        with:
          script: |
            const repos = await github.paginate(github.rest.repos.listForOrg, {
              org: context.repo.owner,
              type: 'all',
              per_page: 100
            });
            
            const repoNames = repos
              .filter(repo => !repo.archived && !repo.disabled)
              .map(repo => repo.name);
            
            core.setOutput('repositories', JSON.stringify(repoNames));
            
      - name: Audit Repository Compliance
        env:
          REPOSITORIES: ${{ steps.repos.outputs.repositories }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          python3 << 'EOF'
          import json
          import os
          import requests
          
          repos = json.loads(os.environ['REPOSITORIES'])
          token = os.environ['GITHUB_TOKEN']
          org = "${{ github.repository_owner }}"
          
          headers = {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json'
          }
          
          compliance_report = {
            'compliant': [],
            'non_compliant': [],
            'issues': []
          }
          
          required_files = [
            '.github/workflows/security.yml',
            'README.md',
            'LICENSE',
            '.gitignore'
          ]
          
          for repo in repos:
            print(f"🔍 Auditing {repo}...")
            
            repo_compliant = True
            repo_issues = []
            
            # Check required files
            for file in required_files:
              url = f"https://api.github.com/repos/{org}/{repo}/contents/{file}"
              response = requests.get(url, headers=headers)
              
              if response.status_code == 404:
                repo_compliant = False
                repo_issues.append(f"Missing required file: {file}")
            
            # Check branch protection
            url = f"https://api.github.com/repos/{org}/{repo}/branches/main/protection"
            response = requests.get(url, headers=headers)
            
            if response.status_code == 404:
              repo_compliant = False
              repo_issues.append("Branch protection not enabled on main branch")
            
            # Check security features
            url = f"https://api.github.com/repos/{org}/{repo}"
            response = requests.get(url, headers=headers)
            
            if response.status_code == 200:
              repo_data = response.json()
              security_features = repo_data.get('security_and_analysis', {})
              
              if not security_features.get('secret_scanning', {}).get('status') == 'enabled':
                repo_compliant = False
                repo_issues.append("Secret scanning not enabled")
              
              if not security_features.get('dependency_graph', {}).get('status') == 'enabled':
                repo_compliant = False
                repo_issues.append("Dependency graph not enabled")
            
            if repo_compliant:
              compliance_report['compliant'].append(repo)
            else:
              compliance_report['non_compliant'].append(repo)
              compliance_report['issues'].extend([f"{repo}: {issue}" for issue in repo_issues])
          
          # Generate report
          total_repos = len(repos)
          compliant_count = len(compliance_report['compliant'])
          compliance_percentage = (compliant_count / total_repos) * 100
          
          print(f"\n📊 Organization Compliance Report")
          print(f"Total Repositories: {total_repos}")
          print(f"Compliant: {compliant_count} ({compliance_percentage:.1f}%)")
          print(f"Non-compliant: {len(compliance_report['non_compliant'])}")
          
          if compliance_report['issues']:
            print(f"\n❌ Compliance Issues:")
            for issue in compliance_report['issues'][:20]:  # Show top 20
              print(f"  - {issue}")
          
          # Save report
          with open('compliance-report.json', 'w') as f:
            json.dump(compliance_report, f, indent=2)
          
          # Fail if compliance too low
          if compliance_percentage < 80:
            print(f"\n❌ Organization compliance below threshold: {compliance_percentage:.1f}% < 80%")
            exit(1)
          EOF
          
      - name: Create Compliance Issues
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            
            try {
              const report = JSON.parse(fs.readFileSync('compliance-report.json', 'utf8'));
              
              // Create issues for non-compliant repositories
              for (const repo of report.non_compliant.slice(0, 10)) { // Limit to 10 issues
                const repoIssues = report.issues.filter(issue => issue.startsWith(`${repo}:`));
                
                const issueBody = `
                ## Repository Compliance Issues
                
                This repository is not compliant with organization policies.
                
                ### Issues Found:
                ${repoIssues.map(issue => `- ${issue.replace(`${repo}: `, '')}`).join('\n')}
                
                ### Required Actions:
                1. Review and implement missing security features
                2. Add required files and configurations
                3. Enable branch protection rules
                4. Ensure CI/CD workflows are in place
                
                **Deadline**: 30 days from issue creation
                **Priority**: High
                
                For assistance, contact the Platform Team.
                `;
                
                await github.rest.issues.create({
                  owner: context.repo.owner,
                  repo: repo,
                  title: 'Repository Compliance Issues - Action Required',
                  body: issueBody,
                  labels: ['compliance', 'security', 'high-priority']
                });
              }
            } catch (error) {
              console.log('No compliance report found or error processing:', error);
            }
```

---

## 🔄 Enterprise Deployment Strategies

### **Multi-Environment Pipeline**

```yaml
# .github/workflows/enterprise-multi-env.yml
name: Enterprise Multi-Environment Pipeline

on:
  push:
    branches: [main, develop, release/*]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  determine-environments:
    runs-on: ubuntu-latest
    outputs:
      environments: ${{ steps.envs.outputs.environments }}
      
    steps:
      - name: Determine Target Environments
        id: envs
        run: |
          ENVIRONMENTS=()
          
          if [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
            ENVIRONMENTS+=("development")
          elif [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            ENVIRONMENTS+=("staging" "production")
          elif [[ "${{ github.ref }}" == refs/heads/release/* ]]; then
            ENVIRONMENTS+=("staging")
          elif [[ "${{ github.event_name }}" == "pull_request" ]]; then
            ENVIRONMENTS+=("preview")
          fi
          
          ENV_JSON=$(printf '%s\n' "${ENVIRONMENTS[@]}" | jq -R . | jq -s .)
          echo "environments=$ENV_JSON" >> $GITHUB_OUTPUT

  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Enterprise Security Scan
        uses: ./.github/workflows/reusable-security.yml
        with:
          language: 'node'
          security-level: 'enterprise'
        secrets:
          security-token: ${{ secrets.ENTERPRISE_SECURITY_TOKEN }}
          compliance-api-key: ${{ secrets.COMPLIANCE_API_KEY }}
          
      - name: Build Application
        run: |
          docker build -t ${{ env.IMAGE_NAME }}:${{ github.sha }} .
          
      - name: Push to Registry
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ${{ env.REGISTRY }} -u ${{ github.actor }} --password-stdin
          docker push ${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy-environments:
    needs: [determine-environments, build-and-test]
    if: needs.determine-environments.outputs.environments != '[]'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: ${{ fromJson(needs.determine-environments.outputs.environments) }}
      max-parallel: 1
      
    environment: ${{ matrix.environment }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Environment-Specific Configuration
        env:
          ENVIRONMENT: ${{ matrix.environment }}
        run: |
          # Load environment-specific configuration
          case "$ENVIRONMENT" in
            "development")
              echo "REPLICAS=1" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_CPU=500m" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_MEMORY=512Mi" >> $GITHUB_ENV
              ;;
            "staging")
              echo "REPLICAS=2" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_CPU=1000m" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_MEMORY=1Gi" >> $GITHUB_ENV
              ;;
            "production")
              echo "REPLICAS=5" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_CPU=2000m" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_MEMORY=2Gi" >> $GITHUB_ENV
              ;;
            "preview")
              echo "REPLICAS=1" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_CPU=250m" >> $GITHUB_ENV
              echo "RESOURCES_LIMIT_MEMORY=256Mi" >> $GITHUB_ENV
              ;;
          esac
          
      - name: Deploy to ${{ matrix.environment }}
        env:
          ENVIRONMENT: ${{ matrix.environment }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          # Deploy using environment-specific configuration
          envsubst < k8s/deployment-template.yml | kubectl apply -f - -n $ENVIRONMENT
          
          # Wait for rollout
          kubectl rollout status deployment/ecommerce-app -n $ENVIRONMENT --timeout=300s
          
      - name: Environment Health Check
        env:
          ENVIRONMENT: ${{ matrix.environment }}
        run: |
          # Get service endpoint
          if [ "$ENVIRONMENT" = "preview" ]; then
            ENDPOINT="https://pr-${{ github.event.number }}.preview.ecommerce.com"
          else
            ENDPOINT="https://$ENVIRONMENT.ecommerce.com"
          fi
          
          # Health check with retry
          for i in {1..30}; do
            if curl -f "$ENDPOINT/health"; then
              echo "✅ $ENVIRONMENT health check passed"
              break
            fi
            sleep 10
          done

  cleanup-preview:
    needs: deploy-environments
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    
    steps:
      - name: Cleanup Preview Environment
        run: |
          # Delete preview environment resources
          kubectl delete namespace pr-${{ github.event.number }} --ignore-not-found=true
          
          # Clean up DNS records
          ./scripts/cleanup-preview-dns.sh pr-${{ github.event.number }}
```

---

## 🎯 Hands-On Lab: Enterprise CI/CD Implementation

### **Lab Objective**
Implement enterprise-grade CI/CD patterns with centralized governance, multi-level approvals, and organization-wide policy enforcement.

### **Lab Steps**

1. **Setup Organization Structure**
```bash
# Create organization-wide templates
mkdir -p .github/{workflows,actions,templates}

# Create reusable workflows
cp examples/reusable-security.yml .github/workflows/
cp examples/enterprise-deployment.yml .github/workflows/

# Setup policy files
mkdir -p policies
cat > policies/security-policies.yml << 'EOF'
security_levels:
  standard:
    - dependency_scan
    - secret_scan
    - license_check
  high:
    - dependency_scan
    - secret_scan
    - license_check
    - sast_scan
    - container_scan
  enterprise:
    - dependency_scan
    - secret_scan
    - license_check
    - sast_scan
    - container_scan
    - dast_scan
    - compliance_check
EOF
```

2. **Implement Approval Workflows**
```bash
# Create environment protection rules
gh api repos/$GITHUB_REPOSITORY/environments/production \
  --method PUT \
  --field protection_rules='[{"type":"required_reviewers","reviewers":[{"type":"User","id":"tech-lead"}]}]'

# Setup approval automation
cp examples/approval-automation.yml .github/workflows/
```

3. **Deploy Policy Enforcement**
```bash
# Create policy enforcement workflow
cp examples/policy-enforcement.yml .github/workflows/

# Test policy compliance
git add .
git commit -m "Add enterprise CI/CD patterns"
git push
```

4. **Validate Enterprise Pipeline**
```bash
# Test multi-environment deployment
gh workflow run enterprise-deployment.yml

# Check compliance status
gh run list --workflow="Organization Policy Enforcement"
```

### **Expected Results**
- Centralized security and compliance workflows
- Multi-level approval processes
- Organization-wide policy enforcement
- Scalable multi-environment deployment
- Comprehensive audit and reporting

---

## 📚 Enterprise Best Practices

### **Governance**
- **Centralized policies** with local customization
- **Multi-level approvals** for production changes
- **Audit trails** for all deployments
- **Compliance automation** for regulatory requirements
- **Security by default** in all workflows

### **Scalability**
- **Reusable workflow templates** across repositories
- **Standardized deployment patterns** for consistency
- **Resource optimization** based on environment
- **Automated policy enforcement** at scale
- **Self-service capabilities** for development teams

---

## 🎯 Module Assessment

### **Knowledge Check**
1. How do you implement organization-wide CI/CD governance?
2. What are the key components of enterprise approval workflows?
3. How do you enforce security policies across multiple repositories?
4. What strategies enable scalable multi-environment deployments?

### **Practical Exercise**
Implement an enterprise CI/CD system that includes:
- Centralized workflow templates and policies
- Multi-level approval processes
- Organization-wide compliance enforcement
- Scalable multi-environment deployment strategies

### **Success Criteria**
- [ ] Centralized governance implementation
- [ ] Multi-level approval workflows
- [ ] Organization-wide policy enforcement
- [ ] Scalable deployment architecture
- [ ] Comprehensive audit and compliance reporting

---

**Next Module**: [Chaos Engineering](./21-Chaos-Engineering.md) - Learn resilience testing automation
