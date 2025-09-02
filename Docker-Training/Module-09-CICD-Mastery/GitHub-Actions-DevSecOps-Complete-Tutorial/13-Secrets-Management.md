# 🔐 Secrets Management: Secure Configuration and Credentials

## 📋 Learning Objectives
- **Master** GitHub Secrets and environment variables
- **Implement** secure credential management patterns
- **Integrate** external secret management systems
- **Build** secure deployment workflows with proper secret rotation

---

## 🔑 GitHub Secrets Fundamentals

### **Types of Secrets**

| Secret Type | Scope | Use Case | Access Level |
|-------------|-------|----------|--------------|
| **Repository** | Single repo | App-specific secrets | Repo collaborators |
| **Environment** | Deployment target | Environment configs | Environment reviewers |
| **Organization** | All repos | Shared credentials | Org members |
| **Dependabot** | Dependency updates | Package registry access | Automated updates |

### **Basic Secrets Usage**

```yaml
# .github/workflows/basic-secrets-example.yml
# ↑ Workflow demonstrating basic secrets usage in GitHub Actions
# Shows fundamental patterns for secure credential handling

name: Basic Secrets Example
# ↑ Descriptive workflow name for secrets management demonstration

on:
  # ↑ Defines when this workflow executes
  push:
    # ↑ Runs when code is pushed to repository
    branches: [main]
    # ↑ Only runs for main branch (production deployments)
    # Limits secret exposure to production-ready code

jobs:
  # ↑ Section defining workflow jobs
  deploy:
    # ↑ Job name indicating deployment process
    runs-on: ubuntu-latest
    # ↑ Uses Ubuntu virtual machine for deployment
    
    steps:
      # ↑ Sequential tasks within the deployment job
      - uses: actions/checkout@v4
        # ↑ Downloads repository code to the runner
        # Required before any deployment operations
      
      - name: Deploy to Production
        # ↑ Step that performs actual deployment with secrets
        env:
          # ↑ Environment variables section - where secrets are accessed
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          # ↑ ${{ secrets.SECRET_NAME }} syntax accesses GitHub repository secrets
          # DATABASE_URL contains full database connection string
          # Format: postgresql://username:password@host:port/database
          API_KEY: ${{ secrets.API_KEY }}
          # ↑ API key for external service authentication
          # Could be for payment processors, email services, etc.
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
          # ↑ Secret key for JSON Web Token signing/verification
          # Critical for user authentication security
        run: |
          # ↑ Shell commands that use the secret environment variables
          echo "Deploying with secure credentials..."
          # ↑ Safe log message - doesn't expose actual secrets
          
          # Never echo secrets directly
          # ↑ CRITICAL SECURITY RULE: Never log secret values
          # This would expose secrets in workflow logs
          
          # Safe way to show non-sensitive parts of secrets
          echo "Database host: $(echo $DATABASE_URL | cut -d'@' -f2 | cut -d'/' -f1)"
          # ↑ Extracts only hostname from database URL for logging
          # cut -d'@' -f2: splits on '@' and takes second part (host:port/db)
          # cut -d'/' -f1: splits on '/' and takes first part (host:port)
          # This shows "localhost:5432" instead of full connection string
          
          # Example deployment commands (replace with actual deployment)
          # ./deploy.sh --database="$DATABASE_URL" --api-key="$API_KEY"
          # ↑ Deployment script receives secrets as parameters
          # Scripts should also avoid logging secret values
```

**Critical Security Concepts for Newbies:**

1. **Secret Access Pattern:**
   - **${{ secrets.NAME }}**: GitHub's secure way to access repository secrets
   - **Environment Variables**: Secrets become env vars within the job
   - **Scope Limitation**: Secrets only available within the specific job/step

2. **Secret Security Rules:**
   - **Never Echo Secrets**: `echo $SECRET` exposes values in logs
   - **No Direct Logging**: Avoid any command that might print secret values
   - **Safe Extraction**: Use shell commands to extract non-sensitive parts only

3. **Secret Types in E-commerce:**
   - **DATABASE_URL**: Database connection credentials
   - **API_KEY**: Third-party service authentication
   - **JWT_SECRET**: User session security
   - **Payment Keys**: Stripe, PayPal, etc. (most critical)

4. **GitHub Secrets Storage:**
   - **Encrypted at Rest**: GitHub encrypts secrets using AES-256
   - **Encrypted in Transit**: HTTPS/TLS for all secret transmission
   - **Access Control**: Only authorized workflows can access secrets
   - **Audit Trail**: GitHub logs secret access (but not values)

5. **Best Practices Demonstrated:**
   - **Branch Restriction**: Only main branch accesses production secrets
   - **Minimal Exposure**: Secrets only in environment variables, not parameters
   - **Safe Logging**: Extract non-sensitive information for debugging
   - **Descriptive Names**: Clear secret names indicate their purpose

---

## 🏗️ Environment-Specific Secrets

### **Environment Configuration**

```yaml
name: Multi-Environment Deployment

on:
  push:
    branches: [main, develop, staging]

jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: development
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Development
        env:
          DATABASE_URL: ${{ secrets.DEV_DATABASE_URL }}
          API_ENDPOINT: ${{ vars.DEV_API_ENDPOINT }}
          DEBUG_MODE: ${{ vars.DEV_DEBUG_MODE }}
        run: |
          ./scripts/deploy.sh development

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Staging
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
          API_ENDPOINT: ${{ vars.STAGING_API_ENDPOINT }}
          MONITORING_KEY: ${{ secrets.STAGING_MONITORING_KEY }}
        run: |
          ./scripts/deploy.sh staging

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Production
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
          API_ENDPOINT: ${{ vars.PROD_API_ENDPOINT }}
          ENCRYPTION_KEY: ${{ secrets.PROD_ENCRYPTION_KEY }}
          MONITORING_KEY: ${{ secrets.PROD_MONITORING_KEY }}
        run: |
          ./scripts/deploy.sh production
```

### **Environment Protection Rules**

```yaml
# .github/environments/production.yml
name: production
deployment_branch_policy:
  protected_branches: true
  custom_branch_policies: false

reviewers:
  - type: User
    id: senior-dev-1
  - type: User  
    id: security-team-lead
  - type: Team
    id: platform-team

wait_timer: 5  # 5 minute delay

secrets:
  - PROD_DATABASE_URL
  - PROD_ENCRYPTION_KEY
  - PROD_MONITORING_KEY
  - PROD_PAYMENT_API_KEY

variables:
  - PROD_API_ENDPOINT
  - PROD_CDN_URL
  - PROD_REGION
```

---

## 🔧 Advanced Secret Management

### **AWS Secrets Manager Integration**

```yaml
name: AWS Secrets Integration

on:
  push:
    branches: [main]

jobs:
  deploy-with-aws-secrets:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Retrieve Secrets from AWS
        id: secrets
        run: |
          # Get database credentials
          DB_SECRET=$(aws secretsmanager get-secret-value \
            --secret-id prod/ecommerce/database \
            --query SecretString --output text)
          
          # Parse JSON secret
          DB_HOST=$(echo $DB_SECRET | jq -r '.host')
          DB_USER=$(echo $DB_SECRET | jq -r '.username')
          DB_PASS=$(echo $DB_SECRET | jq -r '.password')
          
          # Set as masked outputs
          echo "::add-mask::$DB_PASS"
          echo "db-host=$DB_HOST" >> $GITHUB_OUTPUT
          echo "db-user=$DB_USER" >> $GITHUB_OUTPUT
          echo "db-pass=$DB_PASS" >> $GITHUB_OUTPUT
          
      - name: Deploy Application
        env:
          DATABASE_HOST: ${{ steps.secrets.outputs.db-host }}
          DATABASE_USER: ${{ steps.secrets.outputs.db-user }}
          DATABASE_PASS: ${{ steps.secrets.outputs.db-pass }}
        run: |
          ./scripts/deploy-with-db.sh
```

### **HashiCorp Vault Integration**

```yaml
name: Vault Secrets Integration

on:
  push:
    branches: [main]

jobs:
  deploy-with-vault:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Import Secrets from Vault
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_URL }}
          token: ${{ secrets.VAULT_TOKEN }}
          secrets: |
            secret/data/ecommerce database_url | DATABASE_URL ;
            secret/data/ecommerce api_key | API_KEY ;
            secret/data/ecommerce jwt_secret | JWT_SECRET ;
            secret/data/ecommerce stripe_key | STRIPE_SECRET_KEY
            
      - name: Deploy with Vault Secrets
        env:
          DATABASE_URL: ${{ env.DATABASE_URL }}
          API_KEY: ${{ env.API_KEY }}
          JWT_SECRET: ${{ env.JWT_SECRET }}
          STRIPE_SECRET_KEY: ${{ env.STRIPE_SECRET_KEY }}
        run: |
          ./scripts/deploy.sh
```

---

## 🛡️ Secret Security Best Practices

### **Secret Rotation Workflow**

```yaml
name: Secret Rotation

on:
  schedule:
    - cron: '0 2 1 * *'  # Monthly on 1st at 2 AM
  workflow_dispatch:

jobs:
  rotate-api-keys:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate New API Key
        id: new-key
        run: |
          # Generate new API key
          NEW_KEY=$(openssl rand -hex 32)
          echo "::add-mask::$NEW_KEY"
          echo "new-key=$NEW_KEY" >> $GITHUB_OUTPUT
          
      - name: Update External Service
        env:
          CURRENT_KEY: ${{ secrets.API_KEY }}
          NEW_KEY: ${{ steps.new-key.outputs.new-key }}
        run: |
          # Update API key in external service
          curl -X PUT "https://api.service.com/keys" \
            -H "Authorization: Bearer $CURRENT_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"new_key\": \"$NEW_KEY\"}"
            
      - name: Update GitHub Secret
        uses: gliech/create-github-secret-action@v1
        with:
          name: API_KEY
          value: ${{ steps.new-key.outputs.new-key }}
          pa_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          
      - name: Verify New Key
        env:
          NEW_KEY: ${{ steps.new-key.outputs.new-key }}
        run: |
          # Test new API key
          curl -f "https://api.service.com/test" \
            -H "Authorization: Bearer $NEW_KEY"
            
      - name: Notify Team
        if: success()
        uses: 8398a7/action-slack@v3
        with:
          status: success
          text: "API key rotation completed successfully"
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### **Secret Scanning and Validation**

```yaml
name: Secret Security Validation

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Run TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: main
          head: HEAD
          
      - name: Run GitLeaks Secret Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Validate Secret Patterns
        run: |
          # Check for common secret patterns
          if grep -r "password.*=" . --include="*.yml" --include="*.yaml"; then
            echo "❌ Found hardcoded passwords in YAML files"
            exit 1
          fi
          
          if grep -r "api[_-]key.*=" . --include="*.js" --include="*.ts"; then
            echo "❌ Found hardcoded API keys in source code"
            exit 1
          fi
          
          echo "✅ No hardcoded secrets detected"

  secret-usage-audit:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Audit Secret Usage
        run: |
          # Find all secret references
          echo "## Secret Usage Audit" > secret-audit.md
          echo "Generated: $(date)" >> secret-audit.md
          echo "" >> secret-audit.md
          
          # Search for secret references in workflows
          echo "### Workflow Secret References" >> secret-audit.md
          grep -r "secrets\." .github/workflows/ | \
            sed 's/.*secrets\.\([A-Z_]*\).*/- \1/' | \
            sort | uniq >> secret-audit.md
          
          # Search for environment variable usage
          echo "" >> secret-audit.md
          echo "### Environment Variable Usage" >> secret-audit.md
          grep -r "\${{ env\." .github/workflows/ | \
            sed 's/.*env\.\([A-Z_]*\).*/- \1/' | \
            sort | uniq >> secret-audit.md
            
      - name: Upload Audit Report
        uses: actions/upload-artifact@v4
        with:
          name: secret-audit-report
          path: secret-audit.md
```

---

## 🎯 E-commerce Secrets Implementation

### **Complete E-commerce Secrets Workflow**

```yaml
name: E-commerce Secure Deployment

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  validate-secrets:
    runs-on: ubuntu-latest
    outputs:
      secrets-valid: ${{ steps.validation.outputs.valid }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Required Secrets
        id: validation
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
          REDIS_URL: ${{ secrets.REDIS_URL }}
          EMAIL_API_KEY: ${{ secrets.EMAIL_API_KEY }}
        run: |
          # Check if all required secrets are present
          MISSING_SECRETS=()
          
          [ -z "$DATABASE_URL" ] && MISSING_SECRETS+=("DATABASE_URL")
          [ -z "$STRIPE_SECRET_KEY" ] && MISSING_SECRETS+=("STRIPE_SECRET_KEY")
          [ -z "$JWT_SECRET" ] && MISSING_SECRETS+=("JWT_SECRET")
          [ -z "$REDIS_URL" ] && MISSING_SECRETS+=("REDIS_URL")
          [ -z "$EMAIL_API_KEY" ] && MISSING_SECRETS+=("EMAIL_API_KEY")
          
          if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
            echo "❌ Missing required secrets: ${MISSING_SECRETS[*]}"
            echo "valid=false" >> $GITHUB_OUTPUT
            exit 1
          fi
          
          echo "✅ All required secrets are present"
          echo "valid=true" >> $GITHUB_OUTPUT

  test-secret-connectivity:
    needs: validate-secrets
    if: needs.validate-secrets.outputs.secrets-valid == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test Database Connection
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          # Test database connectivity without exposing credentials
          if node scripts/test-db-connection.js; then
            echo "✅ Database connection successful"
          else
            echo "❌ Database connection failed"
            exit 1
          fi
          
      - name: Test Redis Connection
        env:
          REDIS_URL: ${{ secrets.REDIS_URL }}
        run: |
          if node scripts/test-redis-connection.js; then
            echo "✅ Redis connection successful"
          else
            echo "❌ Redis connection failed"
            exit 1
          fi
          
      - name: Validate Stripe API Key
        env:
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
        run: |
          # Test Stripe API without making actual charges
          if curl -f "https://api.stripe.com/v1/account" \
               -u "$STRIPE_SECRET_KEY:" > /dev/null 2>&1; then
            echo "✅ Stripe API key valid"
          else
            echo "❌ Stripe API key invalid"
            exit 1
          fi

  deploy:
    needs: [validate-secrets, test-secret-connectivity]
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install Dependencies
        run: npm ci
        
      - name: Build Application
        env:
          NODE_ENV: production
        run: npm run build
        
      - name: Deploy with Secrets
        env:
          # Database
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          
          # Authentication
          JWT_SECRET: ${{ secrets.JWT_SECRET }}
          SESSION_SECRET: ${{ secrets.SESSION_SECRET }}
          
          # Payment Processing
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
          STRIPE_WEBHOOK_SECRET: ${{ secrets.STRIPE_WEBHOOK_SECRET }}
          
          # External Services
          REDIS_URL: ${{ secrets.REDIS_URL }}
          EMAIL_API_KEY: ${{ secrets.EMAIL_API_KEY }}
          S3_ACCESS_KEY: ${{ secrets.S3_ACCESS_KEY }}
          S3_SECRET_KEY: ${{ secrets.S3_SECRET_KEY }}
          
          # Monitoring
          SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
          DATADOG_API_KEY: ${{ secrets.DATADOG_API_KEY }}
          
          # Configuration Variables
          API_BASE_URL: ${{ vars.API_BASE_URL }}
          CDN_URL: ${{ vars.CDN_URL }}
          ENVIRONMENT: ${{ vars.ENVIRONMENT }}
        run: |
          ./scripts/deploy-ecommerce.sh
          
      - name: Verify Deployment
        env:
          HEALTH_CHECK_URL: ${{ vars.API_BASE_URL }}/health
          API_KEY: ${{ secrets.HEALTH_CHECK_API_KEY }}
        run: |
          # Wait for deployment to be ready
          for i in {1..30}; do
            if curl -f "$HEALTH_CHECK_URL" \
                 -H "Authorization: Bearer $API_KEY"; then
              echo "✅ Deployment verification successful"
              exit 0
            fi
            echo "Waiting for deployment... ($i/30)"
            sleep 10
          done
          
          echo "❌ Deployment verification failed"
          exit 1
```

---

## 🔧 Secret Management Scripts

### **Database Connection Test**

Create `scripts/test-db-connection.js`:
```javascript
const { Pool } = require('pg');

async function testDatabaseConnection() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
  });

  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();
    
    console.log('✅ Database connection successful');
    console.log(`Server time: ${result.rows[0].now}`);
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  } finally {
    await pool.end();
  }
}

testDatabaseConnection()
  .then(success => process.exit(success ? 0 : 1))
  .catch(error => {
    console.error('Connection test error:', error);
    process.exit(1);
  });
```

### **Secret Rotation Script**

Create `scripts/rotate-secrets.sh`:
```bash
#!/bin/bash
set -e

# Secret rotation script for e-commerce application
ENVIRONMENT=${1:-staging}
ROTATION_TYPE=${2:-api-keys}

echo "🔄 Starting secret rotation for $ENVIRONMENT environment"

case $ROTATION_TYPE in
  "api-keys")
    echo "Rotating API keys..."
    
    # Generate new JWT secret
    NEW_JWT_SECRET=$(openssl rand -base64 64)
    
    # Generate new session secret
    NEW_SESSION_SECRET=$(openssl rand -base64 32)
    
    # Update secrets in GitHub (requires gh CLI with proper permissions)
    gh secret set JWT_SECRET --body "$NEW_JWT_SECRET" --env $ENVIRONMENT
    gh secret set SESSION_SECRET --body "$NEW_SESSION_SECRET" --env $ENVIRONMENT
    
    echo "✅ API keys rotated successfully"
    ;;
    
  "database")
    echo "Rotating database credentials..."
    
    # This would typically involve:
    # 1. Creating new database user
    # 2. Granting permissions
    # 3. Updating connection string
    # 4. Testing connectivity
    # 5. Removing old user
    
    echo "⚠️  Database rotation requires manual intervention"
    ;;
    
  "payment")
    echo "Rotating payment provider keys..."
    
    # This would involve coordinating with Stripe/payment provider
    echo "⚠️  Payment key rotation requires coordination with provider"
    ;;
    
  *)
    echo "❌ Unknown rotation type: $ROTATION_TYPE"
    echo "Available types: api-keys, database, payment"
    exit 1
    ;;
esac

echo "🎉 Secret rotation completed for $ENVIRONMENT"
```

---

## 📚 Security Best Practices

### **Secret Management Checklist**

- [ ] **Never commit secrets** to version control
- [ ] **Use environment-specific secrets** for different deployment targets
- [ ] **Implement secret rotation** on a regular schedule
- [ ] **Audit secret usage** regularly
- [ ] **Use least privilege access** for secret permissions
- [ ] **Monitor secret access** and usage patterns
- [ ] **Validate secrets** before deployment
- [ ] **Use external secret managers** for enterprise environments

### **Common Security Mistakes**

| Mistake | Risk | Solution |
|---------|------|----------|
| Hardcoded secrets | High | Use GitHub Secrets |
| Shared secrets across environments | Medium | Environment-specific secrets |
| No secret rotation | Medium | Automated rotation workflows |
| Overprivileged access | Medium | Least privilege principles |
| No secret validation | Low | Pre-deployment validation |

---

## 🎯 Hands-On Lab: Complete Secrets Management

### **Lab Objective**
Implement comprehensive secrets management for an e-commerce application with multiple environments and external integrations.

### **Lab Steps**

1. **Setup Repository Secrets**
```bash
# Add repository secrets via GitHub UI or CLI
gh secret set DATABASE_URL --body "postgresql://user:pass@host:5432/db"
gh secret set STRIPE_SECRET_KEY --body "sk_test_..."
gh secret set JWT_SECRET --body "$(openssl rand -base64 64)"
```

2. **Configure Environment Protection**
```bash
# Create environment-specific secrets
gh secret set PROD_DATABASE_URL --env production
gh secret set STAGING_DATABASE_URL --env staging
```

3. **Implement Secret Validation**
```bash
# Create validation scripts
mkdir -p scripts
cp examples/test-db-connection.js scripts/
cp examples/validate-secrets.sh scripts/
```

4. **Test Secret Rotation**
```bash
# Test rotation workflow
./scripts/rotate-secrets.sh staging api-keys
```

### **Expected Results**
- All secrets properly configured and validated
- Environment-specific secret isolation
- Successful secret rotation workflow
- Secure deployment with proper credential handling

---

## 📚 Additional Resources

### **External Secret Management Tools**

| Tool | Type | Best For | Integration |
|------|------|----------|-------------|
| **AWS Secrets Manager** | Cloud | AWS environments | Native GitHub Action |
| **HashiCorp Vault** | Self-hosted | Enterprise | Community actions |
| **Azure Key Vault** | Cloud | Azure environments | Official action |
| **Google Secret Manager** | Cloud | GCP environments | Official action |

### **Security Standards**
- **NIST Cybersecurity Framework**: Secret management guidelines
- **OWASP ASVS**: Application security verification standards
- **SOC 2**: Compliance requirements for secret handling
- **PCI DSS**: Payment card industry security standards

---

## 🎯 Module Assessment

### **Knowledge Check**
1. What are the different types of GitHub Secrets and their scopes?
2. How do you implement secure secret rotation workflows?
3. What are the best practices for environment-specific secret management?
4. How do you integrate external secret management systems?

### **Practical Exercise**
Implement a complete secrets management system for an e-commerce application that includes:
- Environment-specific secret configuration
- External secret manager integration
- Automated secret rotation
- Secret validation and testing

### **Success Criteria**
- [ ] All secrets properly configured and secured
- [ ] Environment isolation implemented
- [ ] Secret rotation workflow functional
- [ ] External integrations working correctly
- [ ] Security best practices followed

---

**Next Module**: [Docker Build Optimization](./14-Docker-Optimization.md) - Learn advanced container build techniques
