# 🛒 GitHub Marketplace Mastery: Action Discovery and Development

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** GitHub Marketplace action discovery and evaluation
- **Build** custom GitHub Actions for specific use cases
- **Publish** actions to the marketplace
- **Implement** action security and best practices
- **Create** reusable workflow components for teams

## 🎯 Real-World Context
GitHub Marketplace has 20,000+ actions used by millions of developers. Companies like Shopify and Atlassian have built custom actions that save thousands of developer hours monthly through automation.

---

## 🔍 Action Discovery and Evaluation

### **Action Categories**

| Category | Examples | Use Cases |
|----------|----------|-----------|
| **CI/CD** | setup-node, checkout | Build and deployment |
| **Security** | codeql-action, trivy | Vulnerability scanning |
| **Testing** | jest-action, cypress | Test automation |
| **Deployment** | deploy-to-aws, k8s-deploy | Infrastructure deployment |
| **Utilities** | cache, upload-artifact | Workflow optimization |

### **Action Evaluation Criteria**

```yaml
# Example: Evaluating actions for e-commerce pipeline
name: Action Evaluation

on:
  workflow_dispatch:

jobs:
  evaluate-actions:
    runs-on: ubuntu-latest
    
    steps:
      # ✅ Official GitHub action - high trust
      - uses: actions/checkout@v4
      
      # ✅ Verified creator - Docker official
      - uses: docker/setup-buildx-action@v3
      
      # ⚠️ Community action - check stars, maintenance
      - uses: aquasecurity/trivy-action@master
        # Check: 2000+ stars, recent commits, good docs
      
      # ❌ Avoid: Low stars, no recent updates, poor docs
      # - uses: unknown-user/suspicious-action@v1
```

### **Action Security Assessment**

```bash
# Action security checklist script
#!/bin/bash

ACTION_REPO="$1"
echo "🔍 Evaluating action: $ACTION_REPO"

# Check repository metrics
gh repo view "$ACTION_REPO" --json stargazerCount,pushedAt,securityAndAnalysis

# Check for security features
echo "Security features:"
gh api "repos/$ACTION_REPO" | jq '.security_and_analysis'

# Check recent activity
echo "Recent commits:"
gh api "repos/$ACTION_REPO/commits" --paginate | jq '.[0:5] | .[] | {date: .commit.author.date, message: .commit.message}'

# Check for vulnerabilities
echo "Checking for known vulnerabilities..."
gh api "repos/$ACTION_REPO/vulnerability-alerts" 2>/dev/null || echo "No vulnerability alerts API access"
```

---

## 🛠️ Custom Action Development

### **JavaScript Action Structure**

```javascript
// action.yml
name: 'E-commerce Deploy'
description: 'Deploy e-commerce application with health checks'
inputs:
  environment:
    description: 'Deployment environment'
    required: true
  api-key:
    description: 'API key for deployment'
    required: true
  health-check-url:
    description: 'Health check endpoint'
    required: false
    default: '/health'
outputs:
  deployment-url:
    description: 'Deployed application URL'
  deployment-id:
    description: 'Unique deployment identifier'
runs:
  using: 'node20'
  main: 'dist/index.js'
```

```javascript
// src/main.js
const core = require('@actions/core');
const github = require('@actions/github');
const exec = require('@actions/exec');

async function run() {
  try {
    // Get inputs
    const environment = core.getInput('environment');
    const apiKey = core.getInput('api-key');
    const healthCheckUrl = core.getInput('health-check-url');
    
    core.info(`Deploying to ${environment} environment`);
    
    // Deploy application
    const deploymentId = await deployApplication(environment, apiKey);
    
    // Health check
    const deploymentUrl = await performHealthCheck(deploymentId, healthCheckUrl);
    
    // Set outputs
    core.setOutput('deployment-url', deploymentUrl);
    core.setOutput('deployment-id', deploymentId);
    
    core.info('✅ Deployment completed successfully');
  } catch (error) {
    core.setFailed(error.message);
  }
}

async function deployApplication(environment, apiKey) {
  const deploymentId = `deploy-${Date.now()}`;
  
  // Deployment logic
  await exec.exec('kubectl', [
    'apply', '-f', `k8s/${environment}/`,
    '--namespace', environment
  ]);
  
  return deploymentId;
}

async function performHealthCheck(deploymentId, healthCheckPath) {
  const maxRetries = 30;
  const baseUrl = `https://${deploymentId}.example.com`;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(`${baseUrl}${healthCheckPath}`);
      if (response.ok) {
        return baseUrl;
      }
    } catch (error) {
      core.info(`Health check attempt ${i + 1}/${maxRetries} failed`);
    }
    
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  
  throw new Error('Health check failed after maximum retries');
}

run();
```

### **Docker Action Example**

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

ENTRYPOINT ["node", "/app/entrypoint.js"]
```

```javascript
// entrypoint.js
const { execSync } = require('child_process');
const core = require('@actions/core');

async function main() {
  try {
    const environment = process.env.INPUT_ENVIRONMENT;
    const apiKey = process.env.INPUT_API_KEY;
    
    // Validate inputs
    if (!environment || !apiKey) {
      throw new Error('Missing required inputs');
    }
    
    // Execute deployment
    const result = execSync(`./deploy.sh ${environment}`, {
      encoding: 'utf8',
      env: { ...process.env, API_KEY: apiKey }
    });
    
    core.setOutput('result', result.trim());
  } catch (error) {
    core.setFailed(error.message);
  }
}

main();
```

---

## 🚀 Advanced Action Patterns

### **Composite Action**

### **Custom Action Development**
```yaml
# action.yml
name: 'E-commerce Test Suite'
description: 'Complete testing pipeline for e-commerce applications'
inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '18'
  test-command:
    description: 'Test command to run'
    required: false
    default: 'npm test'

runs:
  using: 'composite'
  steps:
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'
        
    - name: Install Dependencies
      shell: bash
      run: npm ci
      
    - name: Run Linting
      shell: bash
      run: npm run lint
      
    - name: Run Unit Tests
      shell: bash
      run: ${{ inputs.test-command }}
      
    - name: Run E2E Tests
      shell: bash
      run: npm run test:e2e
      
    - name: Generate Coverage Report
      shell: bash
      run: npm run coverage
      
    - name: Upload Coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

**Line-by-Line Analysis:**

**`# action.yml`** - GitHub Action metadata file defining custom action behavior
**`name: 'E-commerce Test Suite'`** - Action name displayed in GitHub Marketplace
**`description: 'Complete testing pipeline for e-commerce applications'`** - Action description for users
**`inputs:`** - Defines configurable parameters for action customization
**`node-version:`** - Input parameter for Node.js version selection
**`required: false`** - Makes input optional with fallback to default value
**`default: '18'`** - Default Node.js version if not specified by user
**`test-command:`** - Customizable test command input parameter
**`default: 'npm test'`** - Default test command for standard npm projects
**`runs:`** - Defines how the action executes (composite, Docker, or JavaScript)
**`using: 'composite'`** - Composite action type combining multiple steps
**`steps:`** - Sequential steps executed by the composite action
**`uses: actions/setup-node@v4`** - Official Node.js setup action
**`node-version: ${{ inputs.node-version }}`** - Uses input parameter for Node.js version
**`cache: 'npm'`** - Enables npm dependency caching for performance
**`shell: bash`** - Specifies bash shell for command execution
**`run: npm ci`** - Clean install of dependencies using package-lock.json
**`run: npm run lint`** - Executes linting for code quality validation
**`run: ${{ inputs.test-command }}`** - Executes user-specified test command
**`run: npm run test:e2e`** - Runs end-to-end tests for complete validation
**`run: npm run coverage`** - Generates code coverage reports
**`uses: codecov/codecov-action@v3`** - Uploads coverage to Codecov service
**`file: ./coverage/lcov.info`** - Specifies coverage file location for upload

### **Reusable Workflow**

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deployment

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      node-version:
        required: false
        type: string
        default: '18'
    secrets:
      deploy-token:
        required: true
      database-url:
        required: true
    outputs:
      deployment-url:
        description: "Deployment URL"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
          
      - name: Install and Build
        run: |
          npm ci
          npm run build
          
      - name: Deploy
        id: deploy
        env:
          DEPLOY_TOKEN: ${{ secrets.deploy-token }}
          DATABASE_URL: ${{ secrets.database-url }}
        run: |
          URL=$(./scripts/deploy.sh ${{ inputs.environment }})
          echo "url=$URL" >> $GITHUB_OUTPUT
```

---

## 📦 Action Publishing and Distribution

### **Publishing Workflow**

```yaml
# .github/workflows/publish-action.yml
name: Publish Action

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install Dependencies
        run: npm ci
        
      - name: Run Tests
        run: npm test
        
      - name: Build Action
        run: |
          npm run build
          npm run package
          
      - name: Verify Action
        uses: ./
        with:
          environment: 'test'
          api-key: 'test-key'
          
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```

### **Action Marketplace Optimization**

```yaml
# action.yml - Marketplace optimized
name: 'E-commerce Security Scanner'
description: 'Comprehensive security scanning for e-commerce applications including SAST, DAST, and dependency checks'
author: 'YourOrganization'

branding:
  icon: 'shield'
  color: 'blue'

inputs:
  scan-type:
    description: 'Type of scan to perform (sast, dast, dependencies, all)'
    required: false
    default: 'all'
  severity-threshold:
    description: 'Minimum severity level to report (low, medium, high, critical)'
    required: false
    default: 'medium'
  fail-on-findings:
    description: 'Fail the action if vulnerabilities are found'
    required: false
    default: 'true'

outputs:
  vulnerabilities-found:
    description: 'Number of vulnerabilities found'
  report-url:
    description: 'URL to detailed security report'
  scan-status:
    description: 'Overall scan status (passed, failed, warning)'

runs:
  using: 'docker'
  image: 'Dockerfile'
```

---

## 🎯 E-commerce Action Suite

### **Complete E-commerce Workflow**

```yaml
name: E-commerce CI/CD with Custom Actions

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      # Custom composite action
      - name: Run Test Suite
        uses: ./.github/actions/ecommerce-test-suite
        with:
          node-version: '18'
          test-command: 'npm run test:ci'
          
  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      # Custom security action
      - name: Security Scan
        uses: your-org/ecommerce-security-scanner@v2
        with:
          scan-type: 'all'
          severity-threshold: 'medium'
          fail-on-findings: 'true'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
  deploy-staging:
    needs: [test, security]
    if: github.ref == 'refs/heads/main'
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: 'staging'
      node-version: '18'
    secrets:
      deploy-token: ${{ secrets.STAGING_DEPLOY_TOKEN }}
      database-url: ${{ secrets.STAGING_DATABASE_URL }}
      
  deploy-production:
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: 'production'
      node-version: '18'
    secrets:
      deploy-token: ${{ secrets.PROD_DEPLOY_TOKEN }}
      database-url: ${{ secrets.PROD_DATABASE_URL }}
```

### **Action Testing Framework**

```javascript
// tests/action.test.js
const process = require('process');
const cp = require('child_process');
const path = require('path');

test('test runs', () => {
  process.env['INPUT_ENVIRONMENT'] = 'test';
  process.env['INPUT_API-KEY'] = 'test-key';
  
  const np = process.execPath;
  const ip = path.join(__dirname, '..', 'lib', 'main.js');
  const options = {
    env: process.env
  };
  
  console.log(cp.execFileSync(np, [ip], options).toString());
});

test('test fails with missing inputs', () => {
  delete process.env['INPUT_ENVIRONMENT'];
  
  const np = process.execPath;
  const ip = path.join(__dirname, '..', 'lib', 'main.js');
  
  expect(() => {
    cp.execFileSync(np, [ip], { env: process.env });
  }).toThrow();
});
```

---

## 🔧 Action Development Tools

### **Development Setup**

```json
{
  "name": "ecommerce-deploy-action",
  "version": "1.0.0",
  "description": "Deploy e-commerce applications",
  "main": "lib/main.js",
  "scripts": {
    "build": "tsc",
    "format": "prettier --write '**/*.ts'",
    "format-check": "prettier --check '**/*.ts'",
    "lint": "eslint src/**/*.ts",
    "package": "ncc build --source-map --license licenses.txt",
    "test": "jest",
    "all": "npm run build && npm run format && npm run lint && npm run package && npm test"
  },
  "dependencies": {
    "@actions/core": "^1.10.0",
    "@actions/github": "^5.1.1",
    "@actions/exec": "^1.1.1"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vercel/ncc": "^0.38.0",
    "eslint": "^8.0.0",
    "jest": "^29.0.0",
    "prettier": "^3.0.0",
    "typescript": "^5.0.0"
  }
}
```

### **Action Validation Script**

```bash
#!/bin/bash
# validate-action.sh

set -e

echo "🔍 Validating GitHub Action..."

# Check required files
required_files=("action.yml" "README.md" "LICENSE")
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ Missing required file: $file"
    exit 1
  fi
done

# Validate action.yml syntax
echo "Validating action.yml syntax..."
if ! yq eval . action.yml > /dev/null 2>&1; then
  echo "❌ Invalid YAML syntax in action.yml"
  exit 1
fi

# Check for required metadata
required_fields=("name" "description" "runs")
for field in "${required_fields[@]}"; do
  if ! yq eval ".$field" action.yml > /dev/null 2>&1; then
    echo "❌ Missing required field in action.yml: $field"
    exit 1
  fi
done

# Validate branding (if present)
if yq eval '.branding' action.yml > /dev/null 2>&1; then
  icon=$(yq eval '.branding.icon' action.yml)
  color=$(yq eval '.branding.color' action.yml)
  
  if [[ "$icon" == "null" || "$color" == "null" ]]; then
    echo "⚠️  Incomplete branding information"
  fi
fi

# Check README structure
if ! grep -q "## Usage" README.md; then
  echo "⚠️  README missing Usage section"
fi

if ! grep -q "## Inputs" README.md; then
  echo "⚠️  README missing Inputs section"
fi

echo "✅ Action validation completed"
```

---

## 🎯 Hands-On Lab: Custom Action Development

### **Lab Objective**
Create and publish a custom GitHub Action for e-commerce deployment with health checks and rollback capabilities.

### **Lab Steps**

1. **Initialize Action Project**
```bash
mkdir ecommerce-deploy-action
cd ecommerce-deploy-action

# Initialize package.json
npm init -y

# Install dependencies
npm install @actions/core @actions/github @actions/exec
npm install -D typescript @types/node @vercel/ncc
```

2. **Create Action Metadata**
```bash
# Create action.yml
cat > action.yml << 'EOF'
name: 'E-commerce Deploy'
description: 'Deploy e-commerce application with health checks'
inputs:
  environment:
    description: 'Deployment environment'
    required: true
outputs:
  deployment-url:
    description: 'Deployed application URL'
runs:
  using: 'node20'
  main: 'dist/index.js'
EOF
```

3. **Implement Action Logic**
```bash
# Create src/main.ts with deployment logic
mkdir src
# Copy implementation from examples above
```

4. **Test and Package**
```bash
# Build and package
npm run build
npm run package

# Test locally
node dist/index.js
```

### **Expected Results**
- Functional custom GitHub Action
- Proper error handling and logging
- Published to GitHub Marketplace
- Integration with existing workflows

---

## 📚 Best Practices Summary

### **Action Development**
- **Security First**: Validate all inputs, use secrets properly
- **Error Handling**: Provide clear error messages and exit codes
- **Documentation**: Comprehensive README with examples
- **Testing**: Unit tests and integration tests
- **Versioning**: Semantic versioning with proper releases

### **Marketplace Success**
- **Clear Naming**: Descriptive, searchable action names
- **Good Branding**: Appropriate icons and colors
- **Quality Documentation**: Usage examples and troubleshooting
- **Regular Updates**: Maintain and update actions
- **Community Engagement**: Respond to issues and PRs

---

## 🎯 Module Assessment

### **Knowledge Check**
1. How do you evaluate the security and quality of marketplace actions?
2. What are the differences between JavaScript, Docker, and composite actions?
3. How do you properly version and release GitHub Actions?
4. What are the key elements of a successful marketplace action?

### **Practical Exercise**
Create a custom GitHub Action that:
- Performs e-commerce specific deployment tasks
- Includes proper input validation and error handling
- Has comprehensive documentation
- Includes automated testing
- Is ready for marketplace publication

### **Success Criteria**
- [ ] Action executes successfully in workflows
- [ ] Proper input/output handling
- [ ] Comprehensive error handling
- [ ] Quality documentation and examples
- [ ] Automated testing coverage

---

**Next Module**: [Performance Optimization](./16-Performance-Optimization.md) - Learn pipeline performance tuning
