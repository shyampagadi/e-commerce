# 🚀 First Workflow Creation

## 📋 Learning Objectives
By the end of this module, you will:
- **Create** your first production-ready GitHub Actions workflow
- **Master** YAML syntax and workflow structure
- **Implement** basic CI/CD pipeline for e-commerce applications
- **Configure** job dependencies and artifact management
- **Apply** best practices for workflow organization

## 🎯 Real-World Context
Your first workflow sets the foundation for all future automation. Companies like GitHub, Microsoft, and Shopify started with simple workflows and evolved them into sophisticated deployment pipelines. This module teaches you to build workflows that scale from simple to enterprise-level complexity.

---

## 📚 Part 1: Workflow Structure Fundamentals

### Understanding YAML for GitHub Actions

**YAML Basics for Workflows:**
```yaml
# Basic YAML structure for GitHub Actions
name: "Workflow Name"  # String values can be quoted or unquoted

# Triggers - when the workflow runs
on:
  push:                # Single trigger
    branches: [main]   # Array syntax
  pull_request:        # Multiple triggers
    branches:          # Multi-line array
      - main
      - develop

# Environment variables (global)
env:
  NODE_VERSION: '18'   # String that looks like number
  DEBUG: true          # Boolean
  PORT: 3000          # Number

# Jobs run in parallel by default
jobs:
  job-name:            # Job identifier (kebab-case)
    name: "Job Display Name"  # Human-readable name
    runs-on: ubuntu-latest    # Runner specification
    
    # Job-level environment variables
    env:
      JOB_SPECIFIC: "value"
    
    # Steps run sequentially
    steps:
      - name: "Step Name"     # Step display name
        uses: actions/checkout@v4  # Use an action
        with:                 # Action inputs
          fetch-depth: 0
      
      - name: "Run Command"
        run: |               # Multi-line command
          echo "Hello World"
          npm install
        env:                 # Step-level environment
          STEP_VAR: "value"
```

### Workflow Components Deep Dive

**1. Workflow Triggers (Events):**
```yaml
# Comprehensive trigger examples
on:
  # Code events
  push:
    branches: [main, develop, 'release/*']
    paths: ['src/**', 'package.json']
    tags: ['v*']
  
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
    branches: [main]
    paths-ignore: ['docs/**', '*.md']
  
  # Scheduled events
  schedule:
    - cron: '0 2 * * 1-5'  # Weekdays at 2 AM UTC
    - cron: '0 0 * * 0'    # Sundays at midnight
  
  # Manual triggers
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'
        type: choice
        options: ['development', 'staging', 'production']
      
      version:
        description: 'Version to deploy'
        required: false
        type: string
  
  # External triggers
  repository_dispatch:
    types: [deploy-command, test-command]
  
  # Issue/PR events
  issues:
    types: [opened, labeled]
  
  # Release events
  release:
    types: [published, prereleased]
```

**2. Job Configuration:**
```yaml
jobs:
  comprehensive-job:
    name: "Comprehensive Job Example"
    runs-on: ubuntu-latest
    
    # Job conditions
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    # Timeout (default is 6 hours)
    timeout-minutes: 30
    
    # Continue on error
    continue-on-error: false
    
    # Job outputs (for other jobs to use)
    outputs:
      build-version: ${{ steps.version.outputs.version }}
      artifact-url: ${{ steps.upload.outputs.artifact-url }}
    
    # Job-level permissions
    permissions:
      contents: read
      packages: write
      security-events: write
    
    # Strategy for matrix builds
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest]
      fail-fast: false
      max-parallel: 4
    
    # Services (databases, caches, etc.)
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      # Steps go here
      - name: Example Step
        run: echo "Job configuration complete"
```

---

## 🛠️ Part 2: Building Your First E-Commerce Workflow

### Simple E-Commerce CI Pipeline

**Basic CI Workflow Structure:**
```yaml
# .github/workflows/ci.yml
name: E-Commerce CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  CACHE_VERSION: 'v1'

jobs:
  # Job 1: Code Quality and Linting
  code-quality:
    name: Code Quality Checks
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better analysis
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: 'package-lock.json'
      
      - name: Install Dependencies
        run: npm ci --prefer-offline
      
      - name: Run ESLint
        run: |
          npm run lint
          echo "✅ ESLint checks passed"
      
      - name: Run Prettier Check
        run: |
          npm run format:check
          echo "✅ Code formatting verified"
      
      - name: Type Checking (if TypeScript)
        run: |
          if [ -f "tsconfig.json" ]; then
            npm run type-check
            echo "✅ TypeScript type checking passed"
          else
            echo "ℹ️ No TypeScript configuration found, skipping type check"
          fi

  # Job 2: Unit and Integration Tests
  test:
    name: Test Suite
    runs-on: ubuntu-latest
    needs: code-quality  # Wait for code quality to pass
    
    strategy:
      matrix:
        test-type: [unit, integration]
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Unit Tests
        if: matrix.test-type == 'unit'
        run: |
          npm run test:unit -- --coverage --ci
          echo "✅ Unit tests completed"
        env:
          NODE_ENV: test
      
      - name: Run Integration Tests
        if: matrix.test-type == 'integration'
        run: |
          npm run test:integration -- --ci
          echo "✅ Integration tests completed"
        env:
          NODE_ENV: test
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
          REDIS_URL: redis://localhost:6379
      
      - name: Upload Test Coverage
        if: matrix.test-type == 'unit'
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false

  # Job 3: Build Application
  build:
    name: Build Application
    runs-on: ubuntu-latest
    needs: [code-quality, test]
    
    outputs:
      build-version: ${{ steps.version.outputs.version }}
      build-hash: ${{ steps.hash.outputs.hash }}
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci --prefer-offline
      
      - name: Generate Build Version
        id: version
        run: |
          if [ "${{ github.event_name }}" = "pull_request" ]; then
            VERSION="pr-${{ github.event.number }}-$(git rev-parse --short HEAD)"
          else
            VERSION="$(date +%Y%m%d)-$(git rev-parse --short HEAD)"
          fi
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "Generated version: $VERSION"
      
      - name: Build Application
        run: |
          npm run build
          echo "✅ Application build completed"
        env:
          NODE_ENV: production
          BUILD_VERSION: ${{ steps.version.outputs.version }}
      
      - name: Generate Build Hash
        id: hash
        run: |
          BUILD_HASH=$(find dist/ -type f -exec sha256sum {} \; | sha256sum | cut -d' ' -f1)
          echo "hash=$BUILD_HASH" >> $GITHUB_OUTPUT
          echo "Build hash: $BUILD_HASH"
      
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts-${{ steps.version.outputs.version }}
          path: |
            dist/
            package.json
            package-lock.json
          retention-days: 7
      
      - name: Create Build Summary
        run: |
          echo "## 🏗️ Build Summary" >> $GITHUB_STEP_SUMMARY
          echo "**Version:** ${{ steps.version.outputs.version }}" >> $GITHUB_STEP_SUMMARY
          echo "**Hash:** ${{ steps.hash.outputs.hash }}" >> $GITHUB_STEP_SUMMARY
          echo "**Size:** $(du -sh dist/ | cut -f1)" >> $GITHUB_STEP_SUMMARY
          echo "**Files:** $(find dist/ -type f | wc -l)" >> $GITHUB_STEP_SUMMARY

  # Job 4: Security Scan (Basic)
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: code-quality
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Security Audit
        run: |
          npm audit --audit-level=high
          echo "✅ Security audit completed"
      
      - name: Check for Secrets
        run: |
          # Simple secret detection (basic patterns)
          if grep -r -E "(password|secret|key|token)\s*=\s*['\"][^'\"]{8,}['\"]" src/ --exclude-dir=node_modules; then
            echo "❌ Potential secrets found in code"
            exit 1
          else
            echo "✅ No obvious secrets detected"
          fi

  # Job 5: Deployment (Development)
  deploy-dev:
    name: Deploy to Development
    runs-on: ubuntu-latest
    needs: [build, security]
    if: github.ref == 'refs/heads/develop'
    environment: development
    
    steps:
      - name: Download Build Artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts-${{ needs.build.outputs.build-version }}
      
      - name: Deploy to Development
        run: |
          echo "🚀 Deploying to development environment..."
          echo "Version: ${{ needs.build.outputs.build-version }}"
          echo "Hash: ${{ needs.build.outputs.build-hash }}"
          
          # Simulate deployment
          sleep 5
          
          echo "✅ Deployment to development completed"
      
      - name: Run Smoke Tests
        run: |
          echo "🧪 Running smoke tests..."
          
          # Simulate smoke tests
          sleep 3
          
          echo "✅ Smoke tests passed"
      
      - name: Notify Team
        if: always()
        run: |
          if [ "${{ job.status }}" = "success" ]; then
            echo "✅ Development deployment successful"
          else
            echo "❌ Development deployment failed"
          fi
```

---

## 🔄 Part 3: Advanced Workflow Patterns

### Conditional Execution and Job Dependencies

**Complex Job Dependencies:**
```yaml
name: Advanced Job Dependencies

on:
  push:
    branches: [main]

jobs:
  # Parallel jobs that can run simultaneously
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Linting code..."
  
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running unit tests..."
  
  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running integration tests..."
  
  # Job that waits for multiple jobs
  build:
    runs-on: ubuntu-latest
    needs: [lint, unit-tests, integration-tests]
    steps:
      - run: echo "Building application..."
  
  # Conditional deployment jobs
  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    steps:
      - run: echo "Deploying to staging..."
  
  deploy-production:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    steps:
      - run: echo "Deploying to production..."
  
  # Job that runs regardless of previous job status
  cleanup:
    runs-on: ubuntu-latest
    needs: [deploy-staging, deploy-production]
    if: always()  # Run even if previous jobs fail
    steps:
      - run: echo "Cleaning up resources..."
```

### Matrix Builds for Multi-Environment Testing

**Comprehensive Matrix Strategy:**
```yaml
name: Matrix Build Strategy

on:
  push:
    branches: [main, develop]

jobs:
  test-matrix:
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        # Basic matrix
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
        
        # Include specific combinations
        include:
          - os: ubuntu-latest
            node-version: 18
            experimental: true
          - os: windows-latest
            node-version: 20
            experimental: false
        
        # Exclude specific combinations
        exclude:
          - os: macos-latest
            node-version: 16
      
      # Strategy options
      fail-fast: false      # Don't cancel other jobs if one fails
      max-parallel: 6       # Limit concurrent jobs
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Run Tests
        run: npm test
        continue-on-error: ${{ matrix.experimental }}
      
      - name: Platform-specific Steps
        run: |
          if [ "${{ matrix.os }}" = "ubuntu-latest" ]; then
            echo "Running Linux-specific commands"
          elif [ "${{ matrix.os }}" = "windows-latest" ]; then
            echo "Running Windows-specific commands"
          elif [ "${{ matrix.os }}" = "macos-latest" ]; then
            echo "Running macOS-specific commands"
          fi
        shell: bash
```

---

## 🧪 Part 4: Hands-On Workshop

### Exercise: Build Complete E-Commerce Workflow

**Objective:** Create a comprehensive workflow for an e-commerce application with frontend, backend, and database components.

**Step 1: Project Structure Setup**
```bash
#!/bin/bash
# setup-ecommerce-project.sh

echo "🏗️ Setting up e-commerce project structure..."

# Create project directories
mkdir -p {frontend,backend,database,shared}
mkdir -p .github/workflows

# Create package.json files
cat > frontend/package.json << 'EOF'
{
  "name": "ecommerce-frontend",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "test:coverage": "jest --coverage"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "eslint": "^8.0.0"
  }
}
EOF

cat > backend/package.json << 'EOF'
{
  "name": "ecommerce-backend",
  "version": "1.0.0",
  "scripts": {
    "dev": "nodemon server.js",
    "start": "node server.js",
    "test": "jest",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:coverage": "jest --coverage",
    "lint": "eslint .",
    "security-audit": "npm audit"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0",
    "eslint": "^8.0.0"
  }
}
EOF

echo "✅ Project structure created"
```

**Step 2: Complete Multi-Component Workflow**
```yaml
# .github/workflows/ecommerce-ci-cd.yml
name: E-Commerce Platform CI/CD

on:
  push:
    branches: [main, develop, 'feature/*']
  pull_request:
    branches: [main, develop]

env:
  NODE_VERSION: '18'
  POSTGRES_VERSION: '15'

jobs:
  # Job 1: Changes Detection
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      database: ${{ steps.changes.outputs.database }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
            backend:
              - 'backend/**'
            database:
              - 'database/**'

  # Job 2: Frontend Pipeline
  frontend:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    
    defaults:
      run:
        working-directory: frontend
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Lint Frontend Code
        run: npm run lint
      
      - name: Run Frontend Tests
        run: npm run test:coverage
      
      - name: Build Frontend
        run: npm run build
        env:
          NODE_ENV: production
      
      - name: Upload Frontend Build
        uses: actions/upload-artifact@v3
        with:
          name: frontend-build
          path: frontend/.next/

  # Job 3: Backend Pipeline
  backend:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    
    defaults:
      run:
        working-directory: backend
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Lint Backend Code
        run: npm run lint
      
      - name: Run Unit Tests
        run: npm run test:unit
      
      - name: Run Integration Tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
      
      - name: Security Audit
        run: npm run security-audit
      
      - name: Upload Backend Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: backend-build
          path: |
            backend/
            !backend/node_modules/

  # Job 4: Database Migration Tests
  database:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.database == 'true'
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Test Database Migrations
        run: |
          echo "🗄️ Testing database migrations..."
          
          # Install PostgreSQL client
          sudo apt-get update
          sudo apt-get install -y postgresql-client
          
          # Run migrations (simulate)
          for migration in database/migrations/*.sql; do
            if [ -f "$migration" ]; then
              echo "Running migration: $migration"
              psql -h localhost -U postgres -d ecommerce_test -f "$migration"
            fi
          done
          
          echo "✅ Database migrations completed"
        env:
          PGPASSWORD: postgres

  # Job 5: Integration Testing
  integration:
    runs-on: ubuntu-latest
    needs: [frontend, backend, database]
    if: always() && (needs.frontend.result == 'success' || needs.backend.result == 'success')
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Download Artifacts
        uses: actions/download-artifact@v3
      
      - name: Setup Test Environment
        run: |
          echo "🔧 Setting up integration test environment..."
          
          # Setup database
          PGPASSWORD=postgres psql -h localhost -U postgres -d ecommerce_test -c "
            CREATE TABLE IF NOT EXISTS products (
              id SERIAL PRIMARY KEY,
              name VARCHAR(255) NOT NULL,
              price DECIMAL(10,2) NOT NULL
            );
          "
          
          echo "✅ Test environment ready"
        env:
          PGPASSWORD: postgres
      
      - name: Run End-to-End Tests
        run: |
          echo "🧪 Running end-to-end tests..."
          
          # Simulate E2E tests
          sleep 5
          
          echo "✅ End-to-end tests completed"

  # Job 6: Security Scan
  security:
    runs-on: ubuntu-latest
    needs: [frontend, backend]
    if: always()
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Run Security Scan
        run: |
          echo "🔒 Running comprehensive security scan..."
          
          # Check for common security issues
          echo "Checking for hardcoded secrets..."
          if grep -r -E "(password|secret|key|token)\s*=\s*['\"][^'\"]{8,}['\"]" . --exclude-dir=node_modules --exclude-dir=.git; then
            echo "❌ Potential secrets found"
            exit 1
          fi
          
          echo "✅ Security scan completed"

  # Job 7: Deploy to Development
  deploy-dev:
    runs-on: ubuntu-latest
    needs: [integration, security]
    if: github.ref == 'refs/heads/develop' && needs.integration.result == 'success'
    environment: development
    
    steps:
      - name: Deploy to Development
        run: |
          echo "🚀 Deploying to development environment..."
          echo "Frontend: ${{ needs.frontend.result }}"
          echo "Backend: ${{ needs.backend.result }}"
          echo "Database: ${{ needs.database.result }}"
          
          # Simulate deployment
          sleep 10
          
          echo "✅ Development deployment completed"
      
      - name: Run Smoke Tests
        run: |
          echo "🧪 Running smoke tests..."
          sleep 3
          echo "✅ Smoke tests passed"

  # Job 8: Notification
  notify:
    runs-on: ubuntu-latest
    needs: [deploy-dev]
    if: always()
    
    steps:
      - name: Notify Team
        run: |
          echo "📢 Notifying team of deployment status..."
          
          if [ "${{ needs.deploy-dev.result }}" = "success" ]; then
            echo "✅ Deployment successful!"
          else
            echo "❌ Deployment failed!"
          fi
```

---

## 🎓 Module Summary

You've mastered first workflow creation by learning:

**Core Concepts:**
- YAML syntax and workflow structure
- Job dependencies and execution flow
- Conditional logic and matrix builds
- Artifact management and sharing

**Practical Skills:**
- Building multi-component CI/CD pipelines
- Implementing proper testing strategies
- Managing complex job dependencies
- Creating reusable workflow patterns

**Enterprise Applications:**
- Production-ready workflow organization
- Multi-environment deployment strategies
- Comprehensive testing and validation
- Security integration from the start

**Next Steps:**
- Create your first workflow for your e-commerce project
- Experiment with different trigger conditions
- Implement proper artifact management
- Prepare for Module 4: Advanced Workflow Syntax

---

## 📚 Additional Resources

- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [YAML Syntax Guide](https://yaml.org/spec/1.2/spec.html)
- [GitHub Actions Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)
- [Workflow Examples Repository](https://github.com/actions/starter-workflows)
