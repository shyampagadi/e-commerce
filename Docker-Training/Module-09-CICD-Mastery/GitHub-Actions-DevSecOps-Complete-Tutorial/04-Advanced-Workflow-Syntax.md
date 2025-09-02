# ⚙️ Advanced Workflow Syntax

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** complex YAML expressions and conditional logic
- **Implement** dynamic workflows with matrix strategies
- **Configure** advanced job orchestration and dependencies
- **Apply** workflow optimization techniques for e-commerce applications
- **Build** reusable and maintainable workflow patterns

## 🎯 Real-World Context
Advanced workflow syntax enables sophisticated automation patterns used by companies like GitHub, Microsoft, and Shopify. These techniques allow you to build intelligent, self-adapting pipelines that handle complex deployment scenarios and optimize resource usage.

---

## 📚 Part 1: Advanced YAML and Expressions

### GitHub Actions Expression Syntax

**Expression Fundamentals:**
```yaml
# Expression syntax examples
name: Advanced Expression Examples

on:
  push:
    branches: [main, develop]

env:
  # Simple expressions
  NODE_VERSION: '18'
  BUILD_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
  
  # Complex expressions with functions
  BRANCH_NAME: ${{ github.head_ref || github.ref_name }}
  IS_MAIN_BRANCH: ${{ github.ref == 'refs/heads/main' }}
  COMMIT_MESSAGE: ${{ github.event.head_commit.message }}

jobs:
  advanced-expressions:
    runs-on: ubuntu-latest
    
    steps:
      - name: Context Information
        run: |
          echo "Branch: ${{ env.BRANCH_NAME }}"
          echo "Environment: ${{ env.BUILD_ENV }}"
          echo "Is Main: ${{ env.IS_MAIN_BRANCH }}"
          echo "Actor: ${{ github.actor }}"
          echo "Event: ${{ github.event_name }}"
      
      - name: Advanced String Functions
        run: |
          echo "Uppercase: ${{ upper(env.BRANCH_NAME) }}"
          echo "Lowercase: ${{ lower(github.actor) }}"
          echo "Contains check: ${{ contains(env.COMMIT_MESSAGE, 'feat') }}"
          echo "Starts with: ${{ startsWith(env.BRANCH_NAME, 'feature') }}"
          echo "Ends with: ${{ endsWith(env.BRANCH_NAME, 'main') }}"
          echo "Replace dots: ${{ replace(env.NODE_VERSION, '.', '-') }}"
          echo "Format string: ${{ format('Version: {0}, Branch: {1}', env.NODE_VERSION, env.BRANCH_NAME) }}"
```

**Comprehensive Line-by-Line Analysis:**

**`# Expression syntax examples`**
- **Purpose**: Comment explaining the focus on GitHub Actions expressions
- **Learning**: Demonstrates advanced expression capabilities
- **Context**: Shows real-world expression usage patterns
- **Foundation**: Builds understanding of dynamic workflow behavior
- **Complexity**: Progresses from simple to advanced expressions

**`name: Advanced Expression Examples`**
- **Workflow name**: Descriptive name for expression demonstration
- **Purpose**: Clearly identifies workflow as expression tutorial
- **Organization**: Easy identification in GitHub Actions UI
- **Learning**: Educational workflow for expression mastery
- **Context**: Focused on advanced expression techniques

**`on: push: branches: [main, develop]`**
- **Triggers**: Workflow runs on pushes to main and develop branches
- **Scope**: Limited to important branches for demonstration
- **Testing**: Enables testing of branch-specific expressions
- **Efficiency**: Prevents unnecessary runs on feature branches
- **Focus**: Concentrates on production-relevant scenarios

**`env:`**
- **Global variables**: Environment variables available throughout workflow
- **Expressions**: Demonstrates various expression types and complexity
- **Configuration**: Centralized variable management with dynamic values
- **Context**: Shows how expressions access GitHub context
- **Reusability**: Variables can be referenced in multiple jobs

**`NODE_VERSION: '18'`**
- **Static value**: Simple string value for Node.js version
- **Baseline**: Provides static value for expression comparisons
- **Configuration**: Standard version specification
- **Reference**: Used in other expressions for demonstration
- **Simplicity**: Contrasts with dynamic expression examples

**`BUILD_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}`**
- **Conditional expression**: Ternary operator for environment selection
- **Logic**: If main branch, use 'production', otherwise 'staging'
- **Context access**: Uses `github.ref` to determine current branch
- **Comparison**: `==` operator for exact string matching
- **Operators**: `&&` (AND) and `||` (OR) for conditional logic
- **Dynamic**: Environment changes based on branch context

**`BRANCH_NAME: ${{ github.head_ref || github.ref_name }}`**
- **Fallback expression**: Uses OR operator for fallback value
- **Context**: `github.head_ref` available in pull requests
- **Fallback**: `github.ref_name` used when head_ref not available
- **Flexibility**: Handles both push and pull request events
- **Robustness**: Ensures branch name always available

**`IS_MAIN_BRANCH: ${{ github.ref == 'refs/heads/main' }}`**
- **Boolean expression**: Evaluates to true or false
- **Comparison**: Checks if current ref is main branch
- **Usage**: Can be used in conditional steps or jobs
- **Clarity**: Clear boolean for main branch detection
- **Reusability**: Boolean can be used in multiple conditions

**`COMMIT_MESSAGE: ${{ github.event.head_commit.message }}`**
- **Event data**: Accesses commit message from push event
- **Context**: Uses `github.event` to access event-specific data
- **Navigation**: Dot notation to access nested properties
- **Information**: Provides commit message for conditional logic
- **Flexibility**: Enables commit message-based workflow behavior

**`jobs:`**
- **Job collection**: Defines jobs that demonstrate expressions
- **Organization**: Groups expression examples logically
- **Execution**: Jobs can use the defined environment variables
- **Learning**: Practical demonstration of expression usage
- **Structure**: Standard workflow job structure

**`advanced-expressions:`**
- **Job identifier**: Descriptive name for expression demonstration job
- **Purpose**: Contains steps that showcase expression capabilities
- **Learning**: Educational job for expression mastery
- **Examples**: Practical expression usage examples
- **Reference**: Can be referenced by other jobs if needed

**`runs-on: ubuntu-latest`**
- **Runner**: Ubuntu Linux environment for job execution
- **Compatibility**: Supports all expression evaluation and commands
- **Standard**: Common runner choice for demonstration workflows
- **Reliability**: Stable environment for expression testing
- **Performance**: Efficient execution for educational examples

**`steps:`**
- **Step collection**: Sequential steps demonstrating expressions
- **Learning**: Each step shows different expression capabilities
- **Progression**: Steps build from simple to complex expressions
- **Examples**: Practical expression usage in real scenarios
- **Education**: Comprehensive expression learning progression

**`- name: Context Information`**
- **Step purpose**: Displays basic context information using expressions
- **Foundation**: Shows fundamental expression usage
- **Information**: Demonstrates accessing GitHub context data
- **Learning**: Basic expression evaluation and output
- **Reference**: Provides context for understanding expressions

**`run: |`**
- **Multi-line script**: Enables multiple echo commands
- **Demonstration**: Shows various expression evaluations
- **Output**: Displays expression results for learning
- **Format**: Multi-line YAML string for readability
- **Learning**: Clear demonstration of expression results

**`echo "Branch: ${{ env.BRANCH_NAME }}"`**
- **Variable access**: Displays the dynamically determined branch name
- **Context**: Shows how environment variables work in expressions
- **Output**: Provides visible result of expression evaluation
- **Learning**: Demonstrates environment variable usage
- **Reference**: Shows fallback expression result

**`echo "Environment: ${{ env.BUILD_ENV }}"`**
- **Conditional result**: Displays result of conditional expression
- **Logic**: Shows outcome of ternary operator evaluation
- **Context**: Demonstrates branch-based environment selection
- **Learning**: Practical conditional expression usage
- **Validation**: Confirms conditional logic works correctly

**`echo "Is Main: ${{ env.IS_MAIN_BRANCH }}"`**
- **Boolean display**: Shows boolean expression evaluation result
- **Logic**: Displays true/false based on branch comparison
- **Learning**: Demonstrates boolean expression usage
- **Validation**: Confirms branch detection logic
- **Reference**: Shows boolean expression in action

**`echo "Actor: ${{ github.actor }}"`**
- **Context access**: Displays GitHub user who triggered workflow
- **Information**: Shows direct context property access
- **Learning**: Demonstrates simple context property usage
- **Reference**: Provides user information for workflow context
- **Simplicity**: Contrasts with complex expressions above

**`echo "Event: ${{ github.event_name }}"`**
- **Event information**: Displays the type of event that triggered workflow
- **Context**: Shows event-specific information access
- **Learning**: Demonstrates event context usage
- **Information**: Provides trigger event for workflow understanding
- **Reference**: Shows event-based workflow behavior

**`- name: Advanced String Functions`**
- **Step purpose**: Demonstrates GitHub Actions string manipulation functions
- **Learning**: Shows built-in function capabilities
- **Complexity**: Advanced expression usage with functions
- **Practical**: Real-world string manipulation examples
- **Reference**: Comprehensive function demonstration

**`echo "Uppercase: ${{ upper(env.BRANCH_NAME) }}"`**
- **String function**: Converts branch name to uppercase
- **Function**: `upper()` built-in GitHub Actions function
- **Usage**: Practical string transformation example
- **Learning**: Demonstrates function syntax and usage
- **Application**: Useful for case-insensitive comparisons

**`echo "Lowercase: ${{ lower(github.actor) }}"`**
- **String function**: Converts actor name to lowercase
- **Function**: `lower()` built-in string transformation
- **Context**: Combines function with context property
- **Learning**: Shows function applied to context data
- **Practical**: Useful for consistent naming conventions

**`echo "Contains check: ${{ contains(env.COMMIT_MESSAGE, 'feat') }}"`**
- **Search function**: Checks if commit message contains 'feat'
- **Function**: `contains()` for substring detection
- **Boolean result**: Returns true/false based on search
- **Learning**: Demonstrates search functionality
- **Application**: Useful for commit message-based conditions

**`echo "Starts with: ${{ startsWith(env.BRANCH_NAME, 'feature') }}"`**
- **Prefix function**: Checks if branch name starts with 'feature'
- **Function**: `startsWith()` for prefix detection
- **Boolean**: Returns true/false based on prefix match
- **Learning**: Demonstrates prefix checking capability
- **Application**: Useful for branch naming convention validation

**`echo "Ends with: ${{ endsWith(env.BRANCH_NAME, 'main') }}"`**
- **Suffix function**: Checks if branch name ends with 'main'
- **Function**: `endsWith()` for suffix detection
- **Boolean**: Returns true/false based on suffix match
- **Learning**: Demonstrates suffix checking capability
- **Application**: Useful for branch type identification

**`echo "Replace dots: ${{ replace(env.NODE_VERSION, '.', '-') }}"`**
- **Replace function**: Replaces dots with dashes in version string
- **Function**: `replace()` for string substitution
- **Parameters**: Original string, search pattern, replacement
- **Learning**: Demonstrates string manipulation capability
- **Application**: Useful for creating valid identifiers from versions

**`echo "Format string: ${{ format('Version: {0}, Branch: {1}', env.NODE_VERSION, env.BRANCH_NAME) }}"`**
- **Format function**: Creates formatted string with placeholders
- **Function**: `format()` for string templating
- **Placeholders**: `{0}`, `{1}` for positional arguments
- **Parameters**: Template string followed by values
- **Learning**: Demonstrates advanced string formatting
- **Application**: Useful for creating consistent output messages
          echo "Repository: ${{ github.repository }}"
          echo "SHA: ${{ github.sha }}"
          echo "Run ID: ${{ github.run_id }}"
          echo "Run Number: ${{ github.run_number }}"
      
      - name: Conditional Step
        if: ${{ contains(github.event.head_commit.message, '[deploy]') }}
        run: echo "Deploy flag detected in commit message"
      
      - name: Complex Conditional
        if: |
          github.event_name == 'push' && 
          (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/heads/release/'))
        run: echo "Running on main or release branch"
      
      - name: String Manipulation
        run: |
          echo "Uppercase branch: ${{ upper(env.BRANCH_NAME) }}"
          echo "Lowercase repository: ${{ lower(github.repository) }}"
          echo "Replace dots: ${{ replace(env.NODE_VERSION, '.', '-') }}"
          echo "Format string: ${{ format('Version: {0}, Branch: {1}', env.NODE_VERSION, env.BRANCH_NAME) }}"
```

### Advanced Conditional Logic

**Complex Conditional Patterns:**
```yaml
name: Complex Conditional Logic

on:
  push:
  pull_request:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [development, staging, production]
      force_deploy:
        type: boolean
        default: false

jobs:
  conditional-deployment:
    runs-on: ubuntu-latest
    
    # Complex job-level condition
    if: |
      (github.event_name == 'push' && github.ref == 'refs/heads/main') ||
      (github.event_name == 'workflow_dispatch' && github.event.inputs.force_deploy == 'true') ||
      (github.event_name == 'pull_request' && contains(github.event.pull_request.labels.*.name, 'deploy'))
    
    steps:
      - name: Determine Environment
        id: env
        run: |
          if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
            echo "environment=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" = "refs/heads/main" ]; then
            echo "environment=production" >> $GITHUB_OUTPUT
          elif [ "${{ github.ref }}" = "refs/heads/develop" ]; then
            echo "environment=staging" >> $GITHUB_OUTPUT
          else
            echo "environment=development" >> $GITHUB_OUTPUT
          fi
      
      - name: Production Deployment
        if: steps.env.outputs.environment == 'production'
        run: echo "Deploying to production"
      
      - name: Staging Deployment
        if: steps.env.outputs.environment == 'staging'
        run: echo "Deploying to staging"
      
      - name: Development Deployment
        if: steps.env.outputs.environment == 'development'
        run: echo "Deploying to development"
      
      - name: Multi-condition Step
        if: |
          steps.env.outputs.environment == 'production' && 
          github.actor != 'dependabot[bot]' &&
          !contains(github.event.head_commit.message, '[skip-deploy]')
        run: echo "Production deployment with all conditions met"
```

---

## 🔄 Part 2: Matrix Strategies and Dynamic Workflows

### Advanced Matrix Configurations

**Complex Matrix Strategies:**
```yaml
name: Advanced Matrix Strategies

on:
  push:
    branches: [main, develop]

jobs:
  # Basic matrix
  basic-matrix:
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]
        include:
          # Add specific combinations
          - os: ubuntu-latest
            node-version: 18
            experimental: true
            coverage: true
          - os: windows-latest
            node-version: 20
            experimental: false
        exclude:
          # Remove specific combinations
          - os: macos-latest
            node-version: 16
      
      fail-fast: false
      max-parallel: 6
    
    steps:
      - name: Matrix Information
        run: |
          echo "OS: ${{ matrix.os }}"
          echo "Node: ${{ matrix.node-version }}"
          echo "Experimental: ${{ matrix.experimental }}"
          echo "Coverage: ${{ matrix.coverage }}"

  # Dynamic matrix from JSON
  dynamic-matrix:
    runs-on: ubuntu-latest
    
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Generate Dynamic Matrix
        id: set-matrix
        run: |
          # Generate matrix based on changed files or configuration
          if git diff --name-only HEAD~1 | grep -q "frontend/"; then
            FRONTEND_TESTS='{"component": "frontend", "test-type": ["unit", "integration", "e2e"]}'
          else
            FRONTEND_TESTS='{"component": "frontend", "test-type": ["unit"]}'
          fi
          
          if git diff --name-only HEAD~1 | grep -q "backend/"; then
            BACKEND_TESTS='{"component": "backend", "test-type": ["unit", "integration"]}'
          else
            BACKEND_TESTS='{"component": "backend", "test-type": ["unit"]}'
          fi
          
          MATRIX=$(echo "{\"include\": [$FRONTEND_TESTS, $BACKEND_TESTS]}" | jq -c .)
          echo "matrix=$MATRIX" >> $GITHUB_OUTPUT
          echo "Generated matrix: $MATRIX"

  # Use dynamic matrix
  test-dynamic:
    runs-on: ubuntu-latest
    needs: dynamic-matrix
    
    strategy:
      matrix: ${{ fromJson(needs.dynamic-matrix.outputs.matrix) }}
    
    steps:
      - name: Run Tests
        run: |
          echo "Testing ${{ matrix.component }} with ${{ matrix.test-type }}"

  # E-commerce specific matrix
  ecommerce-matrix:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        service: [frontend, backend, mobile-api, admin-panel]
        environment: [development, staging]
        include:
          # Production only for stable services
          - service: frontend
            environment: production
            deploy-strategy: blue-green
          - service: backend
            environment: production
            deploy-strategy: canary
        exclude:
          # Mobile API not in development
          - service: mobile-api
            environment: development
    
    steps:
      - name: Deploy Service
        run: |
          echo "Deploying ${{ matrix.service }} to ${{ matrix.environment }}"
          if [ -n "${{ matrix.deploy-strategy }}" ]; then
            echo "Using ${{ matrix.deploy-strategy }} deployment strategy"
          fi
```

### Dynamic Workflow Generation

**Workflow Generation Based on Changes:**
```yaml
name: Dynamic Workflow Based on Changes

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  # Detect changes
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.changes.outputs.frontend }}
      backend: ${{ steps.changes.outputs.backend }}
      database: ${{ steps.changes.outputs.database }}
      infrastructure: ${{ steps.changes.outputs.infrastructure }}
      docs: ${{ steps.changes.outputs.docs }}
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Detect Changes
        id: changes
        uses: dorny/paths-filter@v2
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'shared/ui/**'
            backend:
              - 'backend/**'
              - 'shared/api/**'
            database:
              - 'database/**'
              - '**/*.sql'
            infrastructure:
              - 'infrastructure/**'
              - 'docker-compose*.yml'
              - 'Dockerfile*'
            docs:
              - 'docs/**'
              - '*.md'

  # Frontend pipeline (only if frontend changed)
  frontend-pipeline:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.frontend == 'true'
    
    strategy:
      matrix:
        task: [lint, test, build, security-scan]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install Dependencies
        working-directory: frontend
        run: npm ci
      
      - name: Run Task
        working-directory: frontend
        run: |
          case "${{ matrix.task }}" in
            "lint")
              npm run lint
              ;;
            "test")
              npm run test:ci
              ;;
            "build")
              npm run build
              ;;
            "security-scan")
              npm audit --audit-level=high
              ;;
          esac

  # Backend pipeline (only if backend changed)
  backend-pipeline:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.backend == 'true'
    
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
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install Dependencies
        working-directory: backend
        run: npm ci
      
      - name: Run Backend Tests
        working-directory: backend
        run: npm run test:all
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

  # Database migration (only if database changed)
  database-migration:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.database == 'true'
    
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
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Test Database Migrations
        run: |
          echo "Testing database migrations..."
          # Run migration tests
          for migration in database/migrations/*.sql; do
            echo "Testing migration: $migration"
            # Test migration logic here
          done

  # Documentation (only if docs changed)
  documentation:
    runs-on: ubuntu-latest
    needs: changes
    if: needs.changes.outputs.docs == 'true'
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Build Documentation
        run: |
          echo "Building documentation..."
          # Documentation build logic
      
      - name: Deploy Documentation
        if: github.ref == 'refs/heads/main'
        run: |
          echo "Deploying documentation to GitHub Pages..."
          # Documentation deployment logic
```

---

## 🔗 Part 3: Advanced Job Orchestration

### Complex Job Dependencies

**Advanced Job Dependency Patterns:**
```yaml
name: Complex Job Dependencies

on:
  push:
    branches: [main]

jobs:
  # Parallel preparation jobs
  setup-frontend:
    runs-on: ubuntu-latest
    outputs:
      cache-key: ${{ steps.cache.outputs.cache-key }}
      build-needed: ${{ steps.check.outputs.build-needed }}
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Generate Cache Key
        id: cache
        run: echo "cache-key=frontend-${{ hashFiles('frontend/package-lock.json') }}" >> $GITHUB_OUTPUT
      - name: Check if Build Needed
        id: check
        run: echo "build-needed=true" >> $GITHUB_OUTPUT

  setup-backend:
    runs-on: ubuntu-latest
    outputs:
      cache-key: ${{ steps.cache.outputs.cache-key }}
      build-needed: ${{ steps.check.outputs.build-needed }}
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Generate Cache Key
        id: cache
        run: echo "cache-key=backend-${{ hashFiles('backend/package-lock.json') }}" >> $GITHUB_OUTPUT
      - name: Check if Build Needed
        id: check
        run: echo "build-needed=true" >> $GITHUB_OUTPUT

  # Conditional builds based on setup
  build-frontend:
    runs-on: ubuntu-latest
    needs: setup-frontend
    if: needs.setup-frontend.outputs.build-needed == 'true'
    steps:
      - name: Build Frontend
        run: echo "Building frontend with cache key ${{ needs.setup-frontend.outputs.cache-key }}"

  build-backend:
    runs-on: ubuntu-latest
    needs: setup-backend
    if: needs.setup-backend.outputs.build-needed == 'true'
    steps:
      - name: Build Backend
        run: echo "Building backend with cache key ${{ needs.setup-backend.outputs.cache-key }}"

  # Integration tests (wait for both builds)
  integration-tests:
    runs-on: ubuntu-latest
    needs: [build-frontend, build-backend]
    if: always() && (needs.build-frontend.result == 'success' || needs.build-backend.result == 'success')
    steps:
      - name: Run Integration Tests
        run: echo "Running integration tests"

  # Deployment (wait for integration tests)
  deploy:
    runs-on: ubuntu-latest
    needs: [integration-tests]
    if: needs.integration-tests.result == 'success'
    environment: production
    steps:
      - name: Deploy Application
        run: echo "Deploying application"

  # Cleanup (always run, regardless of other job status)
  cleanup:
    runs-on: ubuntu-latest
    needs: [deploy, integration-tests]
    if: always()
    steps:
      - name: Cleanup Resources
        run: echo "Cleaning up resources"
```

### Workflow Reusability

**Reusable Workflow Definition:**
```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deployment Workflow

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      service-name:
        required: true
        type: string
      image-tag:
        required: true
        type: string
      health-check-url:
        required: false
        type: string
        default: '/health'
      deployment-strategy:
        required: false
        type: string
        default: 'rolling'
    secrets:
      deployment-token:
        required: true
      registry-password:
        required: true
    outputs:
      deployment-url:
        description: "URL of the deployed application"
        value: ${{ jobs.deploy.outputs.url }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Login to Registry
        run: |
          echo "${{ secrets.registry-password }}" | docker login -u github --password-stdin ghcr.io
      
      - name: Deploy Service
        id: deploy
        run: |
          echo "Deploying ${{ inputs.service-name }} to ${{ inputs.environment }}"
          echo "Image: ${{ inputs.image-tag }}"
          echo "Strategy: ${{ inputs.deployment-strategy }}"
          
          # Deployment logic here
          DEPLOYMENT_URL="https://${{ inputs.environment }}.example.com"
          echo "url=$DEPLOYMENT_URL" >> $GITHUB_OUTPUT
      
      - name: Health Check
        run: |
          echo "Checking health at ${{ steps.deploy.outputs.url }}${{ inputs.health-check-url }}"
          # Health check logic here
      
      - name: Deployment Summary
        run: |
          echo "## 🚀 Deployment Summary" >> $GITHUB_STEP_SUMMARY
          echo "**Service:** ${{ inputs.service-name }}" >> $GITHUB_STEP_SUMMARY
          echo "**Environment:** ${{ inputs.environment }}" >> $GITHUB_STEP_SUMMARY
          echo "**Image:** ${{ inputs.image-tag }}" >> $GITHUB_STEP_SUMMARY
          echo "**URL:** ${{ steps.deploy.outputs.url }}" >> $GITHUB_STEP_SUMMARY
```

**Using Reusable Workflows:**
```yaml
# .github/workflows/main-deployment.yml
name: Main Deployment Pipeline

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.build.outputs.tag }}
    steps:
      - name: Build and Push
        id: build
        run: |
          TAG="v1.0.0-${{ github.sha }}"
          echo "tag=$TAG" >> $GITHUB_OUTPUT
          echo "Built image with tag: $TAG"

  deploy-staging:
    needs: build
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      service-name: ecommerce-api
      image-tag: ${{ needs.build.outputs.image-tag }}
      deployment-strategy: rolling
    secrets:
      deployment-token: ${{ secrets.STAGING_DEPLOY_TOKEN }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}

  deploy-production:
    needs: [build, deploy-staging]
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
      service-name: ecommerce-api
      image-tag: ${{ needs.build.outputs.image-tag }}
      deployment-strategy: blue-green
    secrets:
      deployment-token: ${{ secrets.PROD_DEPLOY_TOKEN }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}

  notify:
    needs: [deploy-production]
    runs-on: ubuntu-latest
    steps:
      - name: Notify Team
        run: |
          echo "Deployment completed!"
          echo "Staging URL: ${{ needs.deploy-staging.outputs.deployment-url }}"
          echo "Production URL: ${{ needs.deploy-production.outputs.deployment-url }}"
```

---

## 🎓 Module Summary

You've mastered advanced workflow syntax by learning:

**Core Concepts:**
- Complex YAML expressions and conditional logic
- Dynamic matrix strategies and workflow generation
- Advanced job orchestration and dependencies
- Reusable workflow patterns

**Practical Skills:**
- Building intelligent, self-adapting workflows
- Implementing complex conditional deployment logic
- Creating dynamic workflows based on code changes
- Designing reusable workflow components

**Enterprise Applications:**
- Sophisticated deployment strategies
- Resource-optimized workflow execution
- Maintainable and scalable automation patterns
- Advanced error handling and recovery

**Next Steps:**
- Apply advanced syntax to your e-commerce workflows
- Implement dynamic workflow generation
- Create reusable workflow components
- Prepare for Module 5: Testing Strategies

---

## 📚 Additional Resources

- [GitHub Actions Expressions](https://docs.github.com/en/actions/learn-github-actions/expressions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Matrix Strategy Documentation](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
