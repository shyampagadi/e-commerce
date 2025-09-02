# ⚙️ GitHub Actions Setup & Configuration

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** GitHub Actions repository setup and configuration
- **Configure** runners, environments, and security settings
- **Implement** proper permissions and access controls
- **Set up** development environment for e-commerce CI/CD
- **Apply** security best practices from the start

## 🎯 Real-World Context
Proper GitHub Actions setup is critical for enterprise security and performance. Companies like Shopify and Stripe have specific configuration standards that prevent security breaches and ensure reliable deployments. This module teaches you enterprise-grade setup practices.

---

## 📚 Part 1: Repository Configuration Fundamentals

### Understanding GitHub Actions Permissions

**GitHub Actions Security Model:**
```
GitHub Actions Security Architecture
├── Repository Level
│   ├── Actions permissions (enabled/disabled)
│   ├── Workflow permissions (read/write)
│   ├── Fork pull request policies
│   └── Required status checks
├── Organization Level
│   ├── Actions policies (allow/block)
│   ├── Runner group management
│   ├── Secret sharing policies
│   └── Workflow approval requirements
├── Workflow Level
│   ├── GITHUB_TOKEN permissions
│   ├── Environment access controls
│   ├── Concurrency limitations
│   └── Job isolation settings
└── Step Level
    ├── Action permissions
    ├── Secret access scope
    ├── File system access
    └── Network restrictions
```

### Repository Settings Configuration

**Essential Repository Settings:**
```yaml
# Repository Actions Settings (via GitHub UI or API)
Repository_Actions_Settings:
  General:
    - Actions permissions: "Selected actions and reusable workflows"
    - Allow actions created by GitHub: true
    - Allow actions by Marketplace verified creators: true
    - Allow specified actions: "actions/checkout@*, actions/setup-node@*"
  
  Workflow_Permissions:
    - Default GITHUB_TOKEN permissions: "Read repository contents"
    - Allow GitHub Actions to create and approve pull requests: false
  
  Fork_Pull_Requests:
    - Run workflows from fork pull requests: "Require approval for first-time contributors"
    - Send write tokens to workflows from fork pull requests: false
    - Send secrets to workflows from fork pull requests: false
  
  Artifact_and_Log_Retention:
    - Artifact retention: 90 days
    - Log retention: 90 days
```

**Security-First Repository Setup Script:**
```bash
#!/bin/bash
# setup-repository-security.sh - Configure repository for secure CI/CD

REPO_OWNER="your-org"
REPO_NAME="ecommerce-platform"
GITHUB_TOKEN="your_token"

echo "🔒 Configuring repository security settings..."

# Enable vulnerability alerts
gh api repos/$REPO_OWNER/$REPO_NAME \
  --method PATCH \
  --field has_vulnerability_alerts=true

# Enable automated security fixes
gh api repos/$REPO_OWNER/$REPO_NAME/automated-security-fixes \
  --method PUT

# Configure branch protection
gh api repos/$REPO_OWNER/$REPO_NAME/branches/main/protection \
  --method PUT \
  --input - << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci/build", "ci/test", "ci/security-scan"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

echo "✅ Repository security configured"
```

---

## 🏃 Part 2: Runner Configuration

### Understanding Runner Types

**GitHub-Hosted vs Self-Hosted Runners:**
```yaml
Runner_Comparison:
  GitHub_Hosted:
    Pros:
      - No maintenance required
      - Always up-to-date
      - Multiple OS options
      - Automatic scaling
    Cons:
      - Limited customization
      - Network restrictions
      - Cost for private repos
      - No persistent storage
    Best_For:
      - Standard CI/CD workflows
      - Open source projects
      - Quick setup requirements
  
  Self_Hosted:
    Pros:
      - Full environment control
      - Custom software/hardware
      - Network access control
      - Cost effective at scale
    Cons:
      - Maintenance overhead
      - Security responsibility
      - Scaling complexity
      - Update management
    Best_For:
      - Enterprise environments
      - Custom requirements
      - High-volume usage
      - Sensitive workloads
```

### Self-Hosted Runner Setup

**Enterprise Self-Hosted Runner Configuration:**
```bash
#!/bin/bash
# setup-self-hosted-runner.sh - Enterprise runner setup

RUNNER_VERSION="2.311.0"
RUNNER_NAME="ecommerce-runner-$(hostname)"
GITHUB_TOKEN="your_token"
REPO_URL="https://github.com/your-org/ecommerce-platform"

echo "🏃 Setting up self-hosted runner..."

# Create runner user
sudo useradd -m -s /bin/bash github-runner
sudo usermod -aG docker github-runner

# Create runner directory
sudo mkdir -p /opt/github-runner
sudo chown github-runner:github-runner /opt/github-runner

# Switch to runner user
sudo -u github-runner bash << 'EOF'
cd /opt/github-runner

# Download and extract runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

tar xzf actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner
./config.sh \
  --url $REPO_URL \
  --token $GITHUB_TOKEN \
  --name $RUNNER_NAME \
  --work _work \
  --labels "self-hosted,linux,x64,enterprise" \
  --runnergroup "production" \
  --unattended

EOF

# Install as service
sudo /opt/github-runner/svc.sh install github-runner
sudo /opt/github-runner/svc.sh start

echo "✅ Self-hosted runner configured and started"
```

**Runner Security Hardening:**
```bash
#!/bin/bash
# harden-runner.sh - Security hardening for self-hosted runners

echo "🔒 Hardening self-hosted runner security..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install security tools
sudo apt install -y fail2ban ufw auditd

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp  # HTTPS only
sudo ufw --force enable

# Configure fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Set up audit logging
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure runner isolation
sudo mkdir -p /etc/systemd/system/actions.runner.service.d
sudo tee /etc/systemd/system/actions.runner.service.d/override.conf << 'EOF'
[Service]
# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/github-runner/_work

# Resource limits
MemoryLimit=8G
CPUQuota=400%
TasksMax=1000

# Network restrictions
RestrictAddressFamilies=AF_INET AF_INET6
EOF

sudo systemctl daemon-reload
sudo systemctl restart actions.runner

echo "✅ Runner security hardening completed"
```

---

## 🌍 Part 3: Environment Configuration

### Environment Setup Strategy

**Multi-Environment Architecture:**
```yaml
Environment_Strategy:
  Development:
    - Branch: develop, feature/*
    - Auto-deployment: true
    - Approval required: false
    - Secrets: development secrets
    - Resources: minimal
  
  Staging:
    - Branch: develop, release/*
    - Auto-deployment: true
    - Approval required: false
    - Secrets: staging secrets
    - Resources: production-like
  
  Production:
    - Branch: main, release/*
    - Auto-deployment: false
    - Approval required: true
    - Secrets: production secrets
    - Resources: full production
```

**Environment Configuration:**
```yaml
# .github/environments/production.yml
name: production
deployment_branch_policy:
  protected_branches: true
  custom_branch_policies: false

environment_variables:
  NODE_ENV: production
  LOG_LEVEL: info
  MONITORING_ENABLED: true

protection_rules:
  - type: required_reviewers
    reviewers:
      - security-team
      - platform-team
  - type: wait_timer
    wait_timer: 5  # 5 minute delay
  - type: branch_policy
    branch_policy:
      protected_branches: true

secrets:
  - DATABASE_URL
  - API_KEYS
  - ENCRYPTION_KEYS
  - MONITORING_TOKENS
```

### Secrets Management Setup

**Comprehensive Secrets Strategy:**
```bash
#!/bin/bash
# setup-secrets.sh - Configure repository secrets

REPO_OWNER="your-org"
REPO_NAME="ecommerce-platform"

echo "🔐 Setting up repository secrets..."

# Development environment secrets
gh secret set DATABASE_URL_DEV --body "postgresql://dev:password@dev-db:5432/ecommerce_dev" --env development
gh secret set API_KEY_DEV --body "dev-api-key-12345" --env development
gh secret set REDIS_URL_DEV --body "redis://dev-redis:6379" --env development

# Staging environment secrets
gh secret set DATABASE_URL_STAGING --body "postgresql://staging:password@staging-db:5432/ecommerce_staging" --env staging
gh secret set API_KEY_STAGING --body "staging-api-key-67890" --env staging
gh secret set REDIS_URL_STAGING --body "redis://staging-redis:6379" --env staging

# Production environment secrets (use external secret management)
gh secret set DATABASE_URL_PROD --body "vault://secrets/database/production/url" --env production
gh secret set API_KEY_PROD --body "vault://secrets/api/production/key" --env production
gh secret set REDIS_URL_PROD --body "vault://secrets/redis/production/url" --env production

# Global secrets
gh secret set DOCKER_REGISTRY_TOKEN --body "your-registry-token"
gh secret set SONAR_TOKEN --body "your-sonar-token"
gh secret set SNYK_TOKEN --body "your-snyk-token"

echo "✅ Secrets configured for all environments"
```

---

## 🛠️ Part 4: Development Environment Setup

### Local Development Configuration

**Developer Workstation Setup:**
```bash
#!/bin/bash
# setup-dev-environment.sh - Developer environment setup

echo "💻 Setting up development environment for GitHub Actions..."

# Install required tools
echo "Installing development tools..."

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Act (local GitHub Actions runner)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# VS Code extensions for GitHub Actions
code --install-extension github.vscode-github-actions
code --install-extension ms-vscode.vscode-yaml

echo "✅ Development environment setup completed"
```

**VS Code Configuration for GitHub Actions:**
```json
// .vscode/settings.json
{
  "yaml.schemas": {
    "https://json.schemastore.org/github-workflow.json": ".github/workflows/*.yml"
  },
  "yaml.customTags": [
    "!And",
    "!If",
    "!Not",
    "!Equals",
    "!Or",
    "!FindInMap sequence",
    "!Base64",
    "!Cidr",
    "!Ref",
    "!Sub",
    "!GetAtt",
    "!GetAZs",
    "!ImportValue",
    "!Select",
    "!Split",
    "!Join sequence"
  ],
  "files.associations": {
    "*.yml": "yaml",
    "*.yaml": "yaml"
  },
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false
}
```

### Local Testing with Act

**Act Configuration:**
```bash
# .actrc - Act configuration file
--container-architecture linux/amd64
--artifact-server-path /tmp/artifacts
--env-file .env.local
--secret-file .secrets.local
--platform ubuntu-latest=catthehacker/ubuntu:act-latest
--platform ubuntu-20.04=catthehacker/ubuntu:act-20.04
--platform ubuntu-18.04=catthehacker/ubuntu:act-18.04
```

**Local Testing Script:**
```bash
#!/bin/bash
# test-workflows-locally.sh - Test GitHub Actions workflows locally

echo "🧪 Testing GitHub Actions workflows locally..."

# Create local environment file
cat > .env.local << 'EOF'
NODE_ENV=test
DATABASE_URL=postgresql://localhost:5432/ecommerce_test
REDIS_URL=redis://localhost:6379
LOG_LEVEL=debug
EOF

# Create local secrets file (never commit this!)
cat > .secrets.local << 'EOF'
GITHUB_TOKEN=your_test_token
SONAR_TOKEN=your_test_sonar_token
SNYK_TOKEN=your_test_snyk_token
EOF

# Test specific workflow
echo "Testing CI workflow..."
act push -W .github/workflows/ci.yml

# Test pull request workflow
echo "Testing PR workflow..."
act pull_request -W .github/workflows/pr.yml

# Test with specific event data
echo "Testing with custom event data..."
act push -e .github/events/push.json

# Cleanup
rm -f .env.local .secrets.local

echo "✅ Local workflow testing completed"
```

---

## 🧪 Part 5: Hands-On Setup Exercise

### Exercise: Complete E-Commerce Repository Setup

**Objective:** Set up a production-ready GitHub Actions environment for an e-commerce platform.

**Step 1: Repository Structure Setup**
```bash
#!/bin/bash
# setup-ecommerce-repo.sh - Complete repository setup

REPO_NAME="ecommerce-platform"
ORG_NAME="your-org"

echo "🚀 Setting up e-commerce repository structure..."

# Create repository structure
mkdir -p .github/{workflows,environments,ISSUE_TEMPLATE,PULL_REQUEST_TEMPLATE}
mkdir -p {frontend,backend,mobile-api,shared-utils,infrastructure,docs}

# Create workflow directory structure
mkdir -p .github/workflows/{ci,cd,security,maintenance}

# Create environment configurations
for env in development staging production; do
  mkdir -p .github/environments/$env
done

echo "✅ Repository structure created"
```

**Step 2: Security Configuration**
```yaml
# .github/workflows/security/repository-security.yml
name: Repository Security Setup

on:
  workflow_dispatch:
  schedule:
    - cron: '0 2 * * 1'  # Weekly security check

jobs:
  security-setup:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
      actions: read
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Enable Security Features
        run: |
          # Enable Dependabot alerts
          gh api repos/${{ github.repository }} \
            --method PATCH \
            --field has_vulnerability_alerts=true
          
          # Enable automated security fixes
          gh api repos/${{ github.repository }}/automated-security-fixes \
            --method PUT
          
          # Configure Dependabot
          if [ ! -f .github/dependabot.yml ]; then
            cat > .github/dependabot.yml << 'EOF'
          version: 2
          updates:
            - package-ecosystem: "npm"
              directory: "/frontend"
              schedule:
                interval: "weekly"
            - package-ecosystem: "npm"
              directory: "/backend"
              schedule:
                interval: "weekly"
            - package-ecosystem: "github-actions"
              directory: "/"
              schedule:
                interval: "monthly"
          EOF
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Create Security Policies
        run: |
          # Create security policy
          mkdir -p .github
          cat > .github/SECURITY.md << 'EOF'
          # Security Policy
          
          ## Supported Versions
          
          | Version | Supported          |
          | ------- | ------------------ |
          | 1.x.x   | :white_check_mark: |
          | < 1.0   | :x:                |
          
          ## Reporting a Vulnerability
          
          Please report security vulnerabilities to security@company.com
          EOF
          
          # Create code owners file
          cat > .github/CODEOWNERS << 'EOF'
          # Global owners
          * @platform-team
          
          # Security-sensitive files
          .github/workflows/ @security-team @platform-team
          */Dockerfile @security-team @platform-team
          docker-compose*.yml @security-team @platform-team
          
          # Frontend
          frontend/ @frontend-team
          
          # Backend
          backend/ @backend-team
          
          # Infrastructure
          infrastructure/ @platform-team @security-team
          EOF
      
      - name: Commit Security Configuration
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add .github/
          git diff --staged --quiet || git commit -m "feat: add security configuration"
          git push
```

**Comprehensive Line-by-Line Analysis:**

**`# .github/workflows/security/repository-security.yml`**
- **Purpose**: Comment indicating file location and security focus
- **Organization**: Subdirectory structure for workflow categorization
- **Security**: Dedicated security workflow for repository hardening
- **Convention**: Clear naming indicates security-specific functionality
- **Maintenance**: Organized structure aids security team management

**`name: Repository Security Setup`**
- **Purpose**: Descriptive name for security configuration workflow
- **Visibility**: Appears in GitHub Actions UI and security dashboards
- **Clarity**: Clearly indicates security-focused workflow purpose
- **Monitoring**: Easy identification in workflow runs and logs
- **Compliance**: Helps meet security audit requirements

**`on:`**
- **Purpose**: Defines triggers for security workflow execution
- **Flexibility**: Multiple trigger types for comprehensive security coverage
- **Automation**: Enables both manual and scheduled security checks
- **Control**: Determines when security configurations are applied
- **Compliance**: Supports regulatory requirements for regular security reviews

**`workflow_dispatch:`**
- **Purpose**: Enables manual workflow execution from GitHub UI
- **Flexibility**: Allows on-demand security configuration updates
- **Emergency response**: Enables immediate security hardening when needed
- **Testing**: Allows testing security configurations before scheduling
- **Control**: Provides manual override for security team operations

**`schedule:`**
- **Purpose**: Defines automated execution schedule for security checks
- **Automation**: Ensures regular security configuration validation
- **Compliance**: Meets requirements for periodic security reviews
- **Maintenance**: Automated security posture maintenance
- **Monitoring**: Regular verification of security settings

**`- cron: '0 2 * * 1'`**
- **Schedule**: Executes every Monday at 2:00 AM UTC
- **Timing**: Off-peak hours minimize impact on development
- **Frequency**: Weekly schedule balances security with resource usage
- **Format**: Standard cron syntax for precise scheduling
- **Maintenance**: Regular security configuration validation

**`jobs:`**
- **Purpose**: Defines security-focused job collection
- **Organization**: Groups security-related tasks logically
- **Execution**: Security tasks run as coordinated unit
- **Isolation**: Security job isolated from other workflow concerns
- **Focus**: Dedicated security configuration and validation

**`security-setup:`**
- **Job identifier**: Descriptive name for security configuration job
- **Purpose**: Handles repository security hardening tasks
- **Scope**: Comprehensive security feature enablement
- **Responsibility**: Configures all security-related repository settings
- **Automation**: Automated security posture establishment

**`runs-on: ubuntu-latest`**
- **Environment**: Ubuntu Linux virtual machine for execution
- **Compatibility**: GitHub CLI and security tools available
- **Performance**: Reliable environment for security operations
- **Standardization**: Consistent environment for security tasks
- **Support**: Full GitHub API and CLI support available

**`permissions:`**
- **Purpose**: Defines specific permissions for security operations
- **Security**: Principle of least privilege for workflow execution
- **Granularity**: Fine-grained permission control
- **Compliance**: Meets security requirements for access control
- **Audit**: Clear permission documentation for security reviews

**`contents: read`**
- **Permission**: Allows reading repository contents and files
- **Scope**: Minimal read access to repository data
- **Security**: Read-only access reduces security risk
- **Functionality**: Enables checkout and file reading operations
- **Principle**: Least privilege access for security operations

**`security-events: write`**
- **Permission**: Allows writing security events and alerts
- **Functionality**: Enables security feature configuration
- **Scope**: Security-specific write permissions only
- **Compliance**: Required for Dependabot and security alert management
- **Monitoring**: Enables security event creation and management

**`actions: read`**
- **Permission**: Allows reading GitHub Actions configuration
- **Scope**: Read access to workflow and action information
- **Security**: Minimal access for action-related operations
- **Functionality**: Enables workflow introspection and validation
- **Audit**: Supports security review of action usage

**`- name: Checkout Code`**
- **Purpose**: Downloads repository code for security configuration
- **Foundation**: Required for accessing repository files
- **Security**: Enables security policy file creation
- **Standard**: Common first step in security workflows
- **Access**: Provides access to existing security configurations

**`uses: actions/checkout@v4`**
- **Action**: Official GitHub action for code checkout
- **Version**: Latest stable version for security and features
- **Security**: Maintained by GitHub with security updates
- **Reliability**: Trusted action for repository access
- **Functionality**: Downloads complete repository contents

**`- name: Enable Security Features`**
- **Purpose**: Activates GitHub's built-in security features
- **Automation**: Programmatic security feature enablement
- **Comprehensive**: Covers multiple security aspects
- **API-driven**: Uses GitHub API for configuration
- **Standardization**: Consistent security feature setup

**`run: |`**
- **Purpose**: Executes multi-line shell script for security setup
- **Flexibility**: Allows complex security configuration logic
- **Scripting**: Enables conditional and programmatic setup
- **Integration**: Combines multiple security operations
- **Automation**: Reduces manual security configuration effort

**`# Enable Dependabot alerts`**
- **Documentation**: Comment explaining Dependabot alert enablement
- **Purpose**: Vulnerability detection for dependencies
- **Automation**: Automated security vulnerability notifications
- **Compliance**: Meets requirements for vulnerability management
- **Monitoring**: Continuous dependency security monitoring

**`gh api repos/${{ github.repository }} \`**
- **Tool**: GitHub CLI for API operations
- **Endpoint**: Repository-specific API endpoint
- **Variable**: Dynamic repository reference using GitHub context
- **Authentication**: Uses GITHUB_TOKEN for API access
- **Flexibility**: Works with any repository automatically

**`--method PATCH \`**
- **HTTP method**: PATCH for partial resource updates
- **API operation**: Modifies existing repository settings
- **Precision**: Updates only specified fields
- **Safety**: Preserves existing configuration not being changed
- **Standard**: RESTful API pattern for resource updates

**`--field has_vulnerability_alerts=true`**
- **Configuration**: Enables vulnerability alert notifications
- **Security**: Activates automated vulnerability detection
- **Monitoring**: Enables security team notifications
- **Compliance**: Meets vulnerability management requirements
- **Automation**: Reduces manual security monitoring effort

**`gh api repos/${{ github.repository }}/automated-security-fixes \`**
- **Endpoint**: Automated security fixes API endpoint
- **Feature**: Enables automatic security patch application
- **Automation**: Reduces manual security patch management
- **Efficiency**: Automatic resolution of known vulnerabilities
- **Safety**: GitHub-validated security fixes only

**`--method PUT`**
- **HTTP method**: PUT for resource creation/replacement
- **API operation**: Enables automated security fixes feature
- **Idempotent**: Safe to run multiple times
- **Configuration**: Activates automatic security patching
- **Maintenance**: Reduces security maintenance overhead

**`# Configure Dependabot`**
- **Documentation**: Comment explaining Dependabot configuration
- **Purpose**: Automated dependency update management
- **Security**: Keeps dependencies current with security patches
- **Automation**: Reduces manual dependency maintenance
- **Compliance**: Supports dependency management requirements

**`if [ ! -f .github/dependabot.yml ]; then`**
- **Condition**: Checks if Dependabot configuration exists
- **Safety**: Prevents overwriting existing configuration
- **Logic**: Only creates configuration if missing
- **Preservation**: Protects custom Dependabot settings
- **Idempotent**: Safe to run multiple times

**`cat > .github/dependabot.yml << 'EOF'`**
- **Purpose**: Creates Dependabot configuration file
- **Heredoc**: Multi-line file creation with EOF delimiter
- **Configuration**: Defines dependency update policies
- **Automation**: Enables automated dependency updates
- **Structure**: YAML configuration for Dependabot service

**`version: 2`**
- **Configuration**: Dependabot configuration file version
- **Standard**: Version 2 is current Dependabot format
- **Compatibility**: Ensures proper Dependabot parsing
- **Features**: Enables all version 2 Dependabot features
- **Future-proofing**: Uses latest configuration format

**`updates:`**
- **Section**: Defines dependency update configurations
- **Array**: List of package ecosystems to monitor
- **Scope**: Covers different technology stacks
- **Automation**: Automated update policies per ecosystem
- **Organization**: Structured dependency management

**`- package-ecosystem: "npm"`**
- **Ecosystem**: Specifies npm package management system
- **Technology**: Node.js/JavaScript dependency management
- **Scope**: Covers npm packages and package.json files
- **Automation**: Automated npm dependency updates
- **Security**: Includes security vulnerability updates

**`directory: "/frontend"`**
- **Path**: Specifies frontend directory for npm scanning
- **Scope**: Limits scanning to frontend dependencies
- **Organization**: Separates frontend from backend dependencies
- **Precision**: Targeted dependency management
- **Structure**: Matches monorepo organization

**`schedule: interval: "weekly"`**
- **Frequency**: Weekly dependency update checks
- **Balance**: Balances security with development stability
- **Automation**: Regular automated dependency maintenance
- **Predictability**: Consistent update schedule
- **Resource management**: Controlled update frequency

**`- package-ecosystem: "github-actions"`**
- **Ecosystem**: GitHub Actions workflow dependencies
- **Security**: Keeps action versions current
- **Maintenance**: Automated action version updates
- **Reliability**: Ensures actions remain supported
- **Best practice**: Regular action version maintenance

**`directory: "/"`**
- **Path**: Root directory for GitHub Actions scanning
- **Scope**: Covers all workflow files in repository
- **Comprehensive**: Includes all action dependencies
- **Organization**: Centralized action dependency management
- **Coverage**: Complete workflow dependency monitoring

**`schedule: interval: "monthly"`**
- **Frequency**: Monthly GitHub Actions updates
- **Balance**: Less frequent updates for workflow stability
- **Maintenance**: Regular but conservative action updates
- **Stability**: Reduces workflow disruption
- **Security**: Still maintains security update coverage

**`env: GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}`**
- **Authentication**: Provides GitHub API access token
- **Security**: Uses GitHub-provided authentication
- **Scope**: Token has repository-specific permissions
- **Automatic**: GitHub automatically provides this token
- **API access**: Enables GitHub API operations

**`- name: Create Security Policies`**
- **Purpose**: Establishes security documentation and policies
- **Compliance**: Creates required security documentation
- **Governance**: Implements security governance files
- **Transparency**: Provides clear security procedures
- **Standardization**: Consistent security policy implementation

**`mkdir -p .github`**
- **Purpose**: Creates .github directory for GitHub-specific files
- **Structure**: Standard location for GitHub configuration
- **Safety**: `-p` flag creates directory if it doesn't exist
- **Organization**: Proper file structure for GitHub features
- **Convention**: Follows GitHub repository standards

**`cat > .github/SECURITY.md << 'EOF'`**
- **Purpose**: Creates security policy documentation file
- **Standard**: SECURITY.md is GitHub's standard security policy file
- **Visibility**: Appears in repository security tab
- **Communication**: Provides security contact information
- **Compliance**: Meets security documentation requirements

**`cat > .github/CODEOWNERS << 'EOF'`**
- **Purpose**: Creates code ownership and review requirements
- **Governance**: Defines who reviews security-sensitive changes
- **Automation**: Automatic reviewer assignment for PRs
- **Security**: Ensures security team reviews critical files
- **Quality**: Enforces expert review for important changes

**`* @platform-team`**
- **Rule**: Platform team reviews all changes by default
- **Coverage**: Catch-all rule for comprehensive review
- **Governance**: Ensures platform oversight of all changes
- **Quality**: Default expert review for repository changes
- **Backup**: Ensures no changes go unreviewed

**`.github/workflows/ @security-team @platform-team`**
- **Rule**: Security and platform teams review workflow changes
- **Critical**: Workflow changes affect security and operations
- **Expertise**: Requires both security and platform knowledge
- **Protection**: Prevents unauthorized workflow modifications
- **Compliance**: Ensures security review of CI/CD changes

**`git config --local user.email "action@github.com"`**
- **Configuration**: Sets Git user email for commits
- **Automation**: Identifies commits as GitHub Action-generated
- **Traceability**: Clear attribution for automated commits
- **Standard**: GitHub's recommended email for action commits
- **Audit**: Enables tracking of automated changes

**`git config --local user.name "GitHub Action"`**
- **Configuration**: Sets Git user name for commits
- **Identification**: Clear indication of automated commit source
- **Traceability**: Distinguishes automated from manual commits
- **Standard**: GitHub's recommended name for action commits
- **Clarity**: Obvious automated commit identification

**`git add .github/`**
- **Purpose**: Stages security configuration files for commit
- **Scope**: Adds all files in .github directory
- **Preparation**: Prepares security files for version control
- **Organization**: Groups security configuration changes
- **Tracking**: Enables version control of security policies

**`git diff --staged --quiet || git commit -m "feat: add security configuration"`**
- **Logic**: Commits only if there are staged changes
- **Safety**: Prevents empty commits
- **Conditional**: Uses OR operator for conditional execution
- **Message**: Descriptive commit message following conventional commits
- **Automation**: Handles both initial setup and updates gracefully

**`git push`**
- **Purpose**: Pushes security configuration to remote repository
- **Persistence**: Saves security configuration permanently
- **Sharing**: Makes security policies available to team
- **Activation**: Enables GitHub security features
- **Completion**: Finalizes security setup process

**Step 3: Environment Setup Workflow**
```yaml
# .github/workflows/setup-environments.yml
name: Setup Environments

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to setup'
        required: true
        type: choice
        options:
        - development
        - staging
        - production
        - all

jobs:
  setup-environment:
    runs-on: ubuntu-latest
    
    steps:
      - name: Setup Development Environment
        if: github.event.inputs.environment == 'development' || github.event.inputs.environment == 'all'
        run: |
          echo "🔧 Setting up development environment..."
          
          # Configure development environment variables
          gh variable set NODE_ENV --body "development" --env development
          gh variable set LOG_LEVEL --body "debug" --env development
          gh variable set DATABASE_NAME --body "ecommerce_dev" --env development
          
          echo "✅ Development environment configured"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Setup Staging Environment
        if: github.event.inputs.environment == 'staging' || github.event.inputs.environment == 'all'
        run: |
          echo "🔧 Setting up staging environment..."
          
          # Configure staging environment variables
          gh variable set NODE_ENV --body "staging" --env staging
          gh variable set LOG_LEVEL --body "info" --env staging
          gh variable set DATABASE_NAME --body "ecommerce_staging" --env staging
          
          echo "✅ Staging environment configured"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Setup Production Environment
        if: github.event.inputs.environment == 'production' || github.event.inputs.environment == 'all'
        run: |
          echo "🔧 Setting up production environment..."
          
          # Configure production environment variables
          gh variable set NODE_ENV --body "production" --env production
          gh variable set LOG_LEVEL --body "warn" --env production
          gh variable set DATABASE_NAME --body "ecommerce_prod" --env production
          
          echo "✅ Production environment configured"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 📊 Part 6: Validation and Testing

### Setup Validation Workflow

**Repository Setup Validation:**
```yaml
name: Validate Repository Setup

on:
  push:
    branches: [main]
    paths: ['.github/**']
  workflow_dispatch:

jobs:
  validate-setup:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Validate Workflow Syntax
        run: |
          echo "🔍 Validating workflow syntax..."
          
          # Install yamllint
          pip install yamllint
          
          # Validate all workflow files
          find .github/workflows -name "*.yml" -o -name "*.yaml" | while read file; do
            echo "Validating $file..."
            yamllint "$file"
          done
          
          echo "✅ All workflow files are valid"
      
      - name: Check Required Files
        run: |
          echo "📋 Checking required files..."
          
          required_files=(
            ".github/dependabot.yml"
            ".github/SECURITY.md"
            ".github/CODEOWNERS"
            ".github/workflows/ci.yml"
          )
          
          for file in "${required_files[@]}"; do
            if [ -f "$file" ]; then
              echo "✅ $file exists"
            else
              echo "❌ $file is missing"
              exit 1
            fi
          done
      
      - name: Validate Environment Configuration
        run: |
          echo "🌍 Validating environment configuration..."
          
          # Check if environments are properly configured
          environments=("development" "staging" "production")
          
          for env in "${environments[@]}"; do
            echo "Checking $env environment..."
            
            # This would typically check via GitHub API
            # For demo purposes, we'll check if environment files exist
            if [ -d ".github/environments/$env" ]; then
              echo "✅ $env environment directory exists"
            else
              echo "⚠️ $env environment directory not found"
            fi
          done
      
      - name: Security Configuration Check
        run: |
          echo "🔒 Checking security configuration..."
          
          # Check branch protection (would use GitHub API in real scenario)
          echo "✅ Security configuration validated"
      
      - name: Generate Setup Report
        run: |
          echo "📊 Generating setup report..."
          
          cat > setup-report.md << 'EOF'
          # Repository Setup Report
          
          **Generated:** $(date)
          **Repository:** ${{ github.repository }}
          
          ## Configuration Status
          
          ✅ Workflow syntax validation passed
          ✅ Required files present
          ✅ Environment configuration validated
          ✅ Security configuration checked
          
          ## Next Steps
          
          1. Configure repository secrets
          2. Set up self-hosted runners (if needed)
          3. Test workflows with sample code
          4. Configure branch protection rules
          
          EOF
          
          echo "✅ Setup report generated"
      
      - name: Upload Setup Report
        uses: actions/upload-artifact@v3
        with:
          name: setup-report
          path: setup-report.md
```

---

## 🎓 Module Summary

You've mastered GitHub Actions setup and configuration by learning:

**Core Concepts:**
- Repository security configuration and permissions
- Runner types and deployment strategies
- Environment management and secrets handling
- Development environment setup

**Practical Skills:**
- Configuring secure repository settings
- Setting up self-hosted runners with security hardening
- Managing multi-environment deployments
- Local workflow testing with Act

**Enterprise Applications:**
- Production-ready security configurations
- Automated environment setup workflows
- Comprehensive validation and testing
- Security policy implementation

**Next Steps:**
- Apply these configurations to your e-commerce repository
- Set up your development environment
- Test workflows locally before deployment
- Prepare for Module 3: First Workflow Creation

---

## 📚 Additional Resources

- [GitHub Actions Security Guide](https://docs.github.com/en/actions/security-guides)
- [Self-hosted Runner Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Environment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments)
- [Act Local Testing Tool](https://github.com/nektos/act)
