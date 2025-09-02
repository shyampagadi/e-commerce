# 🔄 Microservices Pipelines: Multi-Service Orchestration

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** microservices deployment orchestration
- **Implement** service dependency management
- **Configure** cross-service testing strategies
- **Build** distributed system deployment pipelines
- **Manage** service mesh integration and monitoring

## 🎯 Real-World Context
Microservices architectures power platforms like Netflix (700+ services), Amazon (thousands of services), and Shopify (200+ services). Proper orchestration is critical for maintaining system reliability and deployment velocity.

---

## 🏗️ Microservices Architecture Overview

### **E-commerce Microservices Structure**

```
ecommerce-platform/
├── services/
│   ├── user-service/          # User management & auth
│   ├── product-service/       # Product catalog
│   ├── order-service/         # Order processing
│   ├── payment-service/       # Payment processing
│   ├── inventory-service/     # Stock management
│   ├── notification-service/  # Email/SMS notifications
│   └── api-gateway/          # API routing & aggregation
├── shared/
│   ├── common-lib/           # Shared utilities
│   └── proto-definitions/    # API contracts
└── infrastructure/
    ├── k8s/                  # Kubernetes manifests
    └── terraform/            # Infrastructure as code
```

### **Service Dependency Graph**

```yaml
# .github/service-dependencies.yml
dependencies:
  api-gateway:
    depends_on: []
    consumers: [frontend, mobile-app]
    
  user-service:
    depends_on: [database, redis]
    consumers: [api-gateway, order-service]
    
  product-service:
    depends_on: [database, elasticsearch]
    consumers: [api-gateway, order-service, inventory-service]
    
  order-service:
    depends_on: [user-service, product-service, payment-service, inventory-service]
    consumers: [api-gateway, notification-service]
    
  payment-service:
    depends_on: [user-service, external-payment-api]
    consumers: [order-service]
    
  inventory-service:
    depends_on: [product-service, database]
    consumers: [order-service, api-gateway]
    
  notification-service:
    depends_on: [user-service, email-service, sms-service]
    consumers: [order-service, user-service]
```

---

## 🚀 Service Detection and Build Strategy

### **Change Detection Workflow**

```yaml
# .github/workflows/microservices-change-detection.yml
# ↑ Workflow for detecting changes in microservices architecture
# Critical for efficiency: only build/test services that actually changed

name: Microservices Change Detection
# ↑ Descriptive name for change detection workflow

on:
  # ↑ Defines when change detection should run
  push:
    # ↑ Runs when code is pushed to repository
    branches: [main, develop]
    # ↑ Only runs for main and develop branches
  pull_request:
    # ↑ Runs on pull requests to detect changes before merge
    branches: [main]
    # ↑ Only for PRs targeting main branch

jobs:
  # ↑ Section defining workflow jobs
  detect-changes:
    # ↑ Job that analyzes which services have changed
    runs-on: ubuntu-latest
    # ↑ Uses Ubuntu virtual machine
    outputs:
      # ↑ Defines outputs that other workflows can consume
      # Each output indicates whether a specific service changed
      user-service: ${{ steps.changes.outputs.user-service }}
      # ↑ Boolean output: true if user-service files changed
      product-service: ${{ steps.changes.outputs.product-service }}
      # ↑ Boolean output: true if product-service files changed
      order-service: ${{ steps.changes.outputs.order-service }}
      # ↑ Boolean output: true if order-service files changed
      payment-service: ${{ steps.changes.outputs.payment-service }}
      # ↑ Boolean output: true if payment-service files changed
      inventory-service: ${{ steps.changes.outputs.inventory-service }}
      # ↑ Boolean output: true if inventory-service files changed
      notification-service: ${{ steps.changes.outputs.notification-service }}
      # ↑ Boolean output: true if notification-service files changed
      api-gateway: ${{ steps.changes.outputs.api-gateway }}
      # ↑ Boolean output: true if api-gateway files changed
      shared-lib: ${{ steps.changes.outputs.shared-lib }}
      # ↑ Boolean output: true if shared library files changed
      infrastructure: ${{ steps.changes.outputs.infrastructure }}
      # ↑ Boolean output: true if infrastructure files changed
    
    steps:
      # ↑ Sequential tasks within the change detection job
      - uses: actions/checkout@v4
        # ↑ Downloads repository source code for analysis
        with:
          # ↑ Additional parameters for checkout behavior
          fetch-depth: 0
          # ↑ Downloads complete git history (not just latest commit)
          # Required for path filtering to compare against previous commits
          # Allows detection of changes between commits
          
      - uses: dorny/paths-filter@v2
        # ↑ Third-party action for detecting file path changes
        # Compares current commit against base branch to find changed files
        id: changes
        # ↑ Assigns ID to reference outputs from this step
        with:
          # ↑ Parameters for path filtering configuration
          filters: |
            # ↑ Multi-line YAML defining change detection rules
            # Each service has specific file patterns to monitor
            
            user-service:
              # ↑ Filter name matching the output name
              - 'services/user-service/**'
              # ↑ Matches any file in user-service directory
              # ** means recursive (includes subdirectories)
              - 'shared/common-lib/**'
              # ↑ Also triggers if shared library changes
              # Shared libraries affect multiple services
              
            product-service:
              # ↑ Product service change detection rules
              - 'services/product-service/**'
              # ↑ Product service specific files
              - 'shared/common-lib/**'
              # ↑ Shared library dependency
              
            order-service:
              # ↑ Order service change detection rules
              - 'services/order-service/**'
              # ↑ Order service specific files
              - 'shared/common-lib/**'
              # ↑ Shared library dependency
              
            payment-service:
              # ↑ Payment service change detection rules
              - 'services/payment-service/**'
              # ↑ Payment service specific files
              - 'shared/common-lib/**'
              # ↑ Shared library dependency
              
            inventory-service:
              # ↑ Inventory service change detection rules
              - 'services/inventory-service/**'
              # ↑ Inventory service specific files
              - 'shared/common-lib/**'
              # ↑ Shared library dependency
              
            notification-service:
              # ↑ Notification service change detection rules
              - 'services/notification-service/**'
              # ↑ Notification service specific files
              - 'shared/common-lib/**'
              # ↑ Shared library dependency
              
            api-gateway:
              # ↑ API Gateway change detection rules
              - 'services/api-gateway/**'
              # ↑ API Gateway specific files
              - 'shared/proto-definitions/**'
              # ↑ Protocol buffer definitions (API contracts)
              # API Gateway depends on service contracts, not common library
              
            shared-lib:
              # ↑ Shared library change detection
              - 'shared/common-lib/**'
              # ↑ Any change to shared library affects multiple services
              
            infrastructure:
              # ↑ Infrastructure change detection rules
              - 'infrastructure/**'
              # ↑ Infrastructure as Code files (Terraform, etc.)
              - 'k8s/**'
              # ↑ Kubernetes manifests and configurations
              - 'docker-compose*.yml'
              # ↑ Docker Compose files for local development
```

**Detailed Microservices Change Detection Concepts for Newbies:**

1. **Path-Based Change Detection:**
   - **Efficiency**: Only build/test services that actually changed
   - **Resource Savings**: Avoids unnecessary CI/CD resource usage
   - **Faster Feedback**: Developers get results faster for their specific changes
   - **Parallel Processing**: Unchanged services can be skipped entirely

2. **Dependency Mapping:**
   - **Shared Libraries**: Changes affect multiple services that depend on them
   - **API Contracts**: Protocol definitions affect services that communicate
   - **Infrastructure**: Changes affect all services in the deployment
   - **Transitive Dependencies**: Understanding ripple effects of changes

3. **Git History Requirements:**
   - **fetch-depth: 0**: Downloads complete git history for comparison
   - **Base Comparison**: Compares current commit against target branch
   - **Change Detection**: Identifies which files modified between commits
   - **Path Matching**: Uses glob patterns to match file paths

4. **Output Strategy:**
   - **Boolean Outputs**: Each service gets true/false change indicator
   - **Downstream Consumption**: Other workflows use these outputs for conditional execution
   - **Matrix Generation**: Outputs can be used to create dynamic build matrices
   - **Dependency Chains**: Outputs help orchestrate service build order

5. **Microservices Architecture Benefits:**
   - **Service Isolation**: Changes in one service don't require rebuilding others
   - **Independent Deployment**: Services can be deployed independently
   - **Team Autonomy**: Teams can work on services without affecting others
   - **Scalable CI/CD**: Build pipeline scales with number of services
              - 'shared/common-lib/**'
            inventory-service:
              - 'services/inventory-service/**'
              - 'shared/common-lib/**'
            notification-service:
              - 'services/notification-service/**'
              - 'shared/common-lib/**'
            api-gateway:
              - 'services/api-gateway/**'
              - 'shared/proto-definitions/**'
            shared-lib:
              - 'shared/common-lib/**'
            infrastructure:
              - 'infrastructure/**'
              - 'k8s/**'
              - 'docker-compose*.yml'

  determine-build-order:
    needs: detect-changes
    runs-on: ubuntu-latest
    outputs:
      build-matrix: ${{ steps.matrix.outputs.services }}
      deploy-order: ${{ steps.order.outputs.sequence }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Calculate Build Matrix
        id: matrix
        run: |
          # Create build matrix based on changes
          SERVICES=()
          
          # Always build shared lib first if changed
          if [ "${{ needs.detect-changes.outputs.shared-lib }}" = "true" ]; then
            SERVICES+=("shared-lib")
          fi
          
          # Add changed services
          for service in user-service product-service order-service payment-service inventory-service notification-service api-gateway; do
            if [ "${{ needs.detect-changes.outputs[service] }}" = "true" ]; then
              SERVICES+=("$service")
            fi
          done
          
          # Convert to JSON array
          MATRIX=$(printf '%s\n' "${SERVICES[@]}" | jq -R . | jq -s .)
          echo "services=$MATRIX" >> $GITHUB_OUTPUT
          
      - name: Calculate Deployment Order
        id: order
        run: |
          # Define deployment order based on dependencies
          DEPLOY_ORDER=()
          
          # Infrastructure first
          if [ "${{ needs.detect-changes.outputs.infrastructure }}" = "true" ]; then
            DEPLOY_ORDER+=("infrastructure")
          fi
          
          # Core services (no dependencies)
          if [ "${{ needs.detect-changes.outputs.user-service }}" = "true" ]; then
            DEPLOY_ORDER+=("user-service")
          fi
          
          if [ "${{ needs.detect-changes.outputs.product-service }}" = "true" ]; then
            DEPLOY_ORDER+=("product-service")
          fi
          
          # Dependent services
          if [ "${{ needs.detect-changes.outputs.payment-service }}" = "true" ]; then
            DEPLOY_ORDER+=("payment-service")
          fi
          
          if [ "${{ needs.detect-changes.outputs.inventory-service }}" = "true" ]; then
            DEPLOY_ORDER+=("inventory-service")
          fi
          
          if [ "${{ needs.detect-changes.outputs.order-service }}" = "true" ]; then
            DEPLOY_ORDER+=("order-service")
          fi
          
          if [ "${{ needs.detect-changes.outputs.notification-service }}" = "true" ]; then
            DEPLOY_ORDER+=("notification-service")
          fi
          
          # API Gateway last
          if [ "${{ needs.detect-changes.outputs.api-gateway }}" = "true" ]; then
            DEPLOY_ORDER+=("api-gateway")
          fi
          
          SEQUENCE=$(printf '%s\n' "${DEPLOY_ORDER[@]}" | jq -R . | jq -s .)
          echo "sequence=$SEQUENCE" >> $GITHUB_OUTPUT
```

---

## 🔨 Parallel Service Building

### **Service Build Matrix**

```yaml
name: Microservices Build Pipeline

on:
  workflow_call:
    inputs:
      services:
        required: true
        type: string

jobs:
  build-services:
    runs-on: ubuntu-latest
    if: ${{ fromJson(inputs.services)[0] != null }}
    
    strategy:
      fail-fast: false
      matrix:
        service: ${{ fromJson(inputs.services) }}
        
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Service Environment
        run: |
          SERVICE_PATH="services/${{ matrix.service }}"
          if [ "${{ matrix.service }}" = "shared-lib" ]; then
            SERVICE_PATH="shared/common-lib"
          fi
          echo "SERVICE_PATH=$SERVICE_PATH" >> $GITHUB_ENV
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: '${{ env.SERVICE_PATH }}/package-lock.json'
          
      - name: Install Dependencies
        working-directory: ${{ env.SERVICE_PATH }}
        run: npm ci
        
      - name: Run Service Tests
        working-directory: ${{ env.SERVICE_PATH }}
        run: |
          npm run test:unit
          npm run test:integration
          
      - name: Build Service
        working-directory: ${{ env.SERVICE_PATH }}
        run: npm run build
        
      - name: Build Docker Image
        if: matrix.service != 'shared-lib'
        run: |
          docker build -t ${{ matrix.service }}:${{ github.sha }} ${{ env.SERVICE_PATH }}
          
      - name: Run Security Scan
        if: matrix.service != 'shared-lib'
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ matrix.service }}:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results-${{ matrix.service }}.sarif'
          
      - name: Upload Security Results
        if: matrix.service != 'shared-lib'
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results-${{ matrix.service }}.sarif'
          
      - name: Push Docker Image
        if: matrix.service != 'shared-lib' && github.ref == 'refs/heads/main'
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker tag ${{ matrix.service }}:${{ github.sha }} ghcr.io/${{ github.repository }}/${{ matrix.service }}:${{ github.sha }}
          docker push ghcr.io/${{ github.repository }}/${{ matrix.service }}:${{ github.sha }}
```

---

## 🧪 Cross-Service Testing

### **Contract Testing Pipeline**

```yaml
name: Contract Testing

on:
  workflow_call:
    inputs:
      services:
        required: true
        type: string

jobs:
  contract-tests:
    runs-on: ubuntu-latest
    
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
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install Dependencies
        run: |
          npm ci
          # Install contract testing tools
          npm install -g @pact-foundation/pact-cli
          
      - name: Start Test Services
        run: |
          # Start services in test mode
          docker-compose -f docker-compose.test.yml up -d
          
          # Wait for services to be ready
          ./scripts/wait-for-services.sh
          
      - name: Run Pact Contract Tests
        run: |
          # Run consumer contract tests
          npm run test:contracts:consumer
          
          # Run provider contract tests
          npm run test:contracts:provider
          
      - name: Publish Pact Contracts
        if: github.ref == 'refs/heads/main'
        env:
          PACT_BROKER_BASE_URL: ${{ secrets.PACT_BROKER_URL }}
          PACT_BROKER_TOKEN: ${{ secrets.PACT_BROKER_TOKEN }}
        run: |
          # Publish contracts to Pact Broker
          pact-broker publish pacts --consumer-app-version=${{ github.sha }}
          
      - name: Run Integration Tests
        run: |
          # Test service interactions
          npm run test:integration:cross-service
          
      - name: Cleanup
        if: always()
        run: |
          docker-compose -f docker-compose.test.yml down -v
```

### **End-to-End Testing**

```yaml
name: E2E Testing

on:
  workflow_call:

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Test Environment
        run: |
          # Deploy full microservices stack
          docker-compose -f docker-compose.e2e.yml up -d
          
          # Wait for all services
          timeout 300 bash -c '
            until curl -f http://localhost:8080/health && \
                  curl -f http://localhost:8081/health && \
                  curl -f http://localhost:8082/health; do
              echo "Waiting for services..."
              sleep 5
            done
          '
          
      - name: Setup E2E Test Framework
        run: |
          npm install -g @playwright/test
          npx playwright install
          
      - name: Run E2E Test Suite
        run: |
          # Run comprehensive e2e tests
          npx playwright test --config=e2e.config.js
          
      - name: Generate Test Report
        if: always()
        run: |
          npx playwright show-report
          
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-test-results
          path: |
            test-results/
            playwright-report/
            
      - name: Cleanup E2E Environment
        if: always()
        run: |
          docker-compose -f docker-compose.e2e.yml down -v
```

---

## 🚀 Orchestrated Deployment Pipeline

### **Complete Microservices Deployment**

```yaml
name: Microservices Deployment Pipeline

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
  # Step 1: Detect changes and plan deployment
  plan-deployment:
    uses: ./.github/workflows/change-detection.yml
    
  # Step 2: Build changed services in parallel
  build-services:
    needs: plan-deployment
    if: needs.plan-deployment.outputs.build-matrix != '[]'
    uses: ./.github/workflows/build-services.yml
    with:
      services: ${{ needs.plan-deployment.outputs.build-matrix }}
    secrets: inherit
    
  # Step 3: Run contract tests
  contract-testing:
    needs: [plan-deployment, build-services]
    if: needs.plan-deployment.outputs.build-matrix != '[]'
    uses: ./.github/workflows/contract-tests.yml
    with:
      services: ${{ needs.plan-deployment.outputs.build-matrix }}
    secrets: inherit
    
  # Step 4: Deploy services in dependency order
  deploy-services:
    needs: [plan-deployment, build-services, contract-testing]
    if: needs.plan-deployment.outputs.deploy-order != '[]'
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}
    
    strategy:
      matrix:
        service: ${{ fromJson(needs.plan-deployment.outputs.deploy-order) }}
      max-parallel: 1  # Deploy one service at a time
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Kubernetes
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'
          
      - name: Configure kubectl
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
        run: |
          echo "$KUBE_CONFIG" | base64 -d > ~/.kube/config
          
      - name: Deploy ${{ matrix.service }}
        env:
          SERVICE: ${{ matrix.service }}
          IMAGE_TAG: ${{ github.sha }}
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Update deployment manifest
          envsubst < k8s/$SERVICE/deployment.yml | kubectl apply -f -
          
          # Wait for rollout to complete
          kubectl rollout status deployment/$SERVICE -n $ENVIRONMENT --timeout=300s
          
      - name: Health Check ${{ matrix.service }}
        env:
          SERVICE: ${{ matrix.service }}
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Get service endpoint
          SERVICE_URL=$(kubectl get service $SERVICE -n $ENVIRONMENT -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
          
          # Health check with retry
          for i in {1..30}; do
            if curl -f "http://$SERVICE_URL/health"; then
              echo "✅ $SERVICE health check passed"
              break
            fi
            
            if [ $i -eq 30 ]; then
              echo "❌ $SERVICE health check failed"
              exit 1
            fi
            
            sleep 10
          done
          
      - name: Run Service Smoke Tests
        env:
          SERVICE: ${{ matrix.service }}
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Run service-specific smoke tests
          npm run test:smoke:$SERVICE -- --env=$ENVIRONMENT
          
  # Step 5: Run full E2E tests
  e2e-testing:
    needs: deploy-services
    uses: ./.github/workflows/e2e-tests.yml
    secrets: inherit
    
  # Step 6: Update service mesh configuration
  update-service-mesh:
    needs: [deploy-services, e2e-testing]
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Update Istio Configuration
        env:
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Update virtual services and destination rules
          kubectl apply -f istio/$ENVIRONMENT/ -n $ENVIRONMENT
          
          # Verify mesh configuration
          istioctl analyze -n $ENVIRONMENT
          
      - name: Configure Traffic Routing
        env:
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Gradual traffic shift for production
          if [ "$ENVIRONMENT" = "production" ]; then
            ./scripts/gradual-traffic-shift.sh
          fi
          
  # Step 7: Monitor deployment
  monitor-deployment:
    needs: update-service-mesh
    runs-on: ubuntu-latest
    
    steps:
      - name: Monitor System Health
        env:
          ENVIRONMENT: ${{ github.event.inputs.environment || 'staging' }}
        run: |
          # Monitor for 10 minutes
          for i in {1..60}; do
            # Check overall system health
            HEALTH_STATUS=$(curl -s "https://$ENVIRONMENT.ecommerce.com/api/health/system")
            
            if echo "$HEALTH_STATUS" | jq -e '.status == "healthy"' > /dev/null; then
              echo "✅ System health check passed ($i/60)"
            else
              echo "❌ System health check failed"
              echo "$HEALTH_STATUS"
              
              # Trigger rollback if in production
              if [ "$ENVIRONMENT" = "production" ]; then
                ./scripts/emergency-rollback.sh
              fi
              exit 1
            fi
            
            sleep 10
          done
          
          echo "🎉 Deployment monitoring completed successfully"
```

---

## 🔧 Service Mesh Integration

### **Istio Configuration**

```yaml
# istio/virtual-service.yml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ecommerce-services
spec:
  hosts:
  - ecommerce.com
  http:
  - match:
    - uri:
        prefix: /api/users
    route:
    - destination:
        host: user-service
        port:
          number: 8080
    fault:
      delay:
        percentage:
          value: 0.1
        fixedDelay: 5s
    retries:
      attempts: 3
      perTryTimeout: 2s
      
  - match:
    - uri:
        prefix: /api/products
    route:
    - destination:
        host: product-service
        port:
          number: 8080
    timeout: 10s
    
  - match:
    - uri:
        prefix: /api/orders
    route:
    - destination:
        host: order-service
        port:
          number: 8080
    retries:
      attempts: 5
      perTryTimeout: 3s
```

### **Circuit Breaker Configuration**

```yaml
# istio/destination-rule.yml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: ecommerce-circuit-breaker
spec:
  host: order-service
  trafficPolicy:
    outlierDetection:
      consecutiveErrors: 3
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 10
```

---

## 🎯 Hands-On Lab: Microservices Pipeline

### **Lab Objective**
Build a complete microservices deployment pipeline with service orchestration, contract testing, and monitoring.

### **Lab Steps**

1. **Setup Microservices Structure**
```bash
# Create service structure
mkdir -p services/{user,product,order,payment}-service
mkdir -p shared/{common-lib,proto-definitions}
mkdir -p infrastructure/{k8s,terraform}

# Initialize each service
for service in user product order payment; do
  cd services/${service}-service
  npm init -y
  # Add service-specific code
  cd ../..
done
```

2. **Implement Change Detection**
```bash
# Create change detection workflow
cp examples/change-detection.yml .github/workflows/

# Test change detection
git add services/user-service/
git commit -m "Update user service"
```

3. **Setup Contract Testing**
```bash
# Install Pact
npm install --save-dev @pact-foundation/pact

# Create contract tests
mkdir -p tests/contracts
# Add consumer and provider tests
```

4. **Deploy Pipeline**
```bash
# Create complete pipeline
cp examples/microservices-pipeline.yml .github/workflows/

# Test deployment
git push origin main
```

### **Expected Results**
- Automated service change detection
- Parallel service building and testing
- Orchestrated deployment with dependency management
- Contract testing and E2E validation
- Service mesh integration and monitoring

---

## 📚 Best Practices Summary

### **Microservices CI/CD**
- **Service Independence**: Each service should be deployable independently
- **Contract Testing**: Ensure API compatibility between services
- **Gradual Rollouts**: Use canary deployments for production changes
- **Monitoring**: Comprehensive observability across all services
- **Rollback Strategy**: Quick rollback capabilities for failed deployments

### **Orchestration Patterns**
- **Dependency Management**: Deploy services in correct dependency order
- **Circuit Breakers**: Prevent cascade failures
- **Service Discovery**: Dynamic service registration and discovery
- **Load Balancing**: Distribute traffic across service instances
- **Security**: Service-to-service authentication and authorization

---

## 🎯 Module Assessment

### **Knowledge Check**
1. How do you manage dependencies between microservices in CI/CD pipelines?
2. What are the key components of contract testing in microservices?
3. How do you implement zero-downtime deployments for microservices?
4. What monitoring strategies are essential for microservices architectures?

### **Practical Exercise**
Implement a complete microservices pipeline that includes:
- Service change detection and parallel building
- Contract testing between services
- Orchestrated deployment with dependency management
- Service mesh integration and monitoring

### **Success Criteria**
- [ ] Independent service deployment capability
- [ ] Contract testing implementation
- [ ] Proper dependency management
- [ ] Service mesh integration
- [ ] Comprehensive monitoring and alerting

---

**Next Module**: [Infrastructure Security Scanning](./19-Infrastructure-Security.md) - Learn IaC security automation
