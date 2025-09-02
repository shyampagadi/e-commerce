# 🔄 Advanced CI/CD Integration

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** advanced CI/CD concepts and container integration patterns
- **Master** automated build, test, and deployment pipelines for containers
- **Implement** comprehensive CI/CD workflows for e-commerce applications
- **Configure** multi-stage pipelines with quality gates and security scanning
- **Deploy** production-ready CI/CD automation solutions

## 🎯 Real-World Context
Modern e-commerce platforms require sophisticated CI/CD pipelines to deliver features rapidly while maintaining quality and security. This module teaches you to build enterprise-grade CI/CD systems that automate the entire software delivery lifecycle for containerized applications.

---

## 📚 Part 1: CI/CD Fundamentals for Containers

### Container CI/CD Pipeline Overview

**Key Pipeline Stages:**

**1. Source Control Integration**
- Git webhook triggers
- Branch-based workflows
- Pull request automation
- Code quality checks

**2. Build Stage**
- Multi-stage Docker builds
- Build optimization and caching
- Artifact generation
- Build metrics collection

**3. Test Stage**
- Unit and integration testing
- Security vulnerability scanning
- Performance testing
- Quality gate validation

**4. Deploy Stage**
- Environment-specific deployments
- Blue-green and canary strategies
- Rollback capabilities
- Production monitoring

### CI/CD Requirements for E-Commerce

**Speed Requirements:**
- Build times under 10 minutes
- Test execution under 15 minutes
- Deployment times under 5 minutes
- Feedback loops under 30 minutes

**Quality Requirements:**
- 90%+ test coverage
- Zero critical security vulnerabilities
- Performance regression detection
- Automated quality gates

**Reliability Requirements:**
- 99.9% pipeline success rate
- Automatic retry mechanisms
- Rollback capabilities
- Comprehensive logging and monitoring

---

## 🔧 Part 2: GitHub Actions CI/CD Pipeline

### Complete E-Commerce CI/CD Workflow

**GitHub Actions Workflow:**
```yaml
# .github/workflows/ecommerce-cicd.yml
name: E-Commerce CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ecommerce/api

jobs:
  # Code quality and security checks
  code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Prettier
        run: npm run format:check
      
      - name: Security audit
        run: npm audit --audit-level=high
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  # Unit and integration tests
  test:
    runs-on: ubuntu-latest
    needs: code-quality
    
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
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:unit
        env:
          NODE_ENV: test
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          NODE_ENV: test
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
          REDIS_URL: redis://localhost:6379
      
      - name: Generate test coverage
        run: npm run test:coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info

  # Build and push Docker images
  build:
    runs-on: ubuntu-latest
    needs: test
    outputs:
      image-digest: ${{ steps.build.outputs.digest }}
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push Docker image
        id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            NODE_ENV=production
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}

  # Security scanning
  security-scan:
    runs-on: ubuntu-latest
    needs: build
    
    steps:
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image-tag }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Check for critical vulnerabilities
        run: |
          CRITICAL_COUNT=$(cat trivy-results.sarif | jq '.runs[0].results | map(select(.level == "error")) | length')
          if [ "$CRITICAL_COUNT" -gt 0 ]; then
            echo "❌ Found $CRITICAL_COUNT critical vulnerabilities"
            exit 1
          fi
          echo "✅ No critical vulnerabilities found"

  # Deploy to staging
  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build, security-scan]
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        run: |
          echo "🚀 Deploying to staging environment"
          # Update staging deployment with new image
          sed -i "s|image: .*|image: ${{ needs.build.outputs.image-tag }}|" k8s/staging/deployment.yaml
          kubectl apply -f k8s/staging/
      
      - name: Wait for deployment
        run: |
          kubectl rollout status deployment/ecommerce-api -n staging --timeout=300s
      
      - name: Run smoke tests
        run: |
          npm run test:smoke -- --env=staging

  # Deploy to production
  deploy-production:
    runs-on: ubuntu-latest
    needs: [build, security-scan]
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Blue-Green Deployment
        run: |
          echo "🔄 Starting blue-green deployment to production"
          ./scripts/blue-green-deploy.sh ${{ needs.build.outputs.image-tag }}
      
      - name: Run production health checks
        run: |
          npm run test:health -- --env=production
      
      - name: Notify deployment success
        uses: 8398a7/action-slack@v3
        with:
          status: success
          text: "✅ Production deployment successful: ${{ needs.build.outputs.image-tag }}"
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

  # Performance testing
  performance-test:
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run load tests
        run: |
          docker run --rm \
            -v $(pwd)/tests:/tests \
            loadimpact/k6:latest \
            run --vus 100 --duration 5m /tests/load-test.js
      
      - name: Performance regression check
        run: |
          # Compare with baseline performance metrics
          python3 scripts/performance-check.py --baseline=main --current=develop
```

### Advanced Pipeline Configuration

**Multi-Environment Pipeline Script:**
```bash
#!/bin/bash
# advanced-pipeline.sh - Advanced CI/CD pipeline orchestrator

set -e

# Configuration
ENVIRONMENTS=("development" "staging" "production")
IMAGE_NAME="ecommerce/api"
REGISTRY="ghcr.io"
BUILD_CACHE_DIR="/tmp/docker-cache"

# Functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Build optimization with cache
optimized_build() {
    local tag=$1
    local dockerfile=${2:-"Dockerfile"}
    
    log "🔨 Starting optimized build for $tag"
    
    # Create cache directory
    mkdir -p "$BUILD_CACHE_DIR"
    
    # Build with advanced caching
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --cache-from type=local,src="$BUILD_CACHE_DIR" \
        --cache-to type=local,dest="$BUILD_CACHE_DIR",mode=max \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --build-arg NODE_ENV=production \
        --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg VCS_REF="$(git rev-parse HEAD)" \
        -t "$REGISTRY/$IMAGE_NAME:$tag" \
        -f "$dockerfile" \
        --push \
        .
    
    log "✅ Build completed for $tag"
}

# Comprehensive testing
run_tests() {
    local environment=$1
    
    log "🧪 Running comprehensive tests for $environment"
    
    # Unit tests
    log "Running unit tests..."
    npm run test:unit -- --coverage --ci
    
    # Integration tests
    log "Running integration tests..."
    docker-compose -f docker-compose.test.yml up -d
    npm run test:integration
    docker-compose -f docker-compose.test.yml down
    
    # Security tests
    log "Running security tests..."
    npm audit --audit-level=high
    
    # Performance tests (for staging and production)
    if [ "$environment" != "development" ]; then
        log "Running performance tests..."
        docker run --rm \
            -v $(pwd)/tests:/tests \
            loadimpact/k6:latest \
            run --vus 50 --duration 2m /tests/performance-test.js
    fi
    
    log "✅ All tests passed for $environment"
}

# Security scanning
security_scan() {
    local image_tag=$1
    
    log "🔒 Running security scan for $image_tag"
    
    # Vulnerability scanning with Trivy
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd):/workspace \
        aquasec/trivy:latest \
        image --exit-code 1 --severity HIGH,CRITICAL \
        "$REGISTRY/$IMAGE_NAME:$image_tag"
    
    # Container security best practices check
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(pwd):/workspace \
        aquasec/trivy:latest \
        config /workspace/Dockerfile
    
    log "✅ Security scan passed"
}

# Quality gates
quality_gates() {
    local environment=$1
    
    log "🚪 Checking quality gates for $environment"
    
    # Code coverage threshold
    local coverage=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    if (( $(echo "$coverage < 80" | bc -l) )); then
        log "❌ Code coverage below threshold: $coverage%"
        exit 1
    fi
    
    # Performance thresholds
    if [ "$environment" != "development" ]; then
        local response_time=$(cat performance-results.json | jq '.avg_response_time')
        if (( $(echo "$response_time > 500" | bc -l) )); then
            log "❌ Response time above threshold: ${response_time}ms"
            exit 1
        fi
    fi
    
    log "✅ Quality gates passed"
}

# Deployment with rollback capability
deploy_with_rollback() {
    local environment=$1
    local image_tag=$2
    
    log "🚀 Deploying $image_tag to $environment"
    
    # Store current deployment for rollback
    local current_image=$(kubectl get deployment ecommerce-api -n $environment -o jsonpath='{.spec.template.spec.containers[0].image}')
    
    # Deploy new version
    kubectl set image deployment/ecommerce-api \
        ecommerce-api="$REGISTRY/$IMAGE_NAME:$image_tag" \
        -n $environment
    
    # Wait for rollout
    if ! kubectl rollout status deployment/ecommerce-api -n $environment --timeout=300s; then
        log "❌ Deployment failed, rolling back..."
        kubectl set image deployment/ecommerce-api \
            ecommerce-api="$current_image" \
            -n $environment
        kubectl rollout status deployment/ecommerce-api -n $environment --timeout=300s
        exit 1
    fi
    
    # Health check
    sleep 30
    if ! curl -f "https://$environment.ecommerce.com/health"; then
        log "❌ Health check failed, rolling back..."
        kubectl set image deployment/ecommerce-api \
            ecommerce-api="$current_image" \
            -n $environment
        exit 1
    fi
    
    log "✅ Deployment successful to $environment"
}

# Main pipeline execution
main() {
    local branch=${1:-$(git branch --show-current)}
    local commit_sha=$(git rev-parse --short HEAD)
    local image_tag="${branch}-${commit_sha}"
    
    log "🚀 Starting CI/CD pipeline for branch: $branch"
    
    # Build stage
    optimized_build "$image_tag"
    
    # Security scan
    security_scan "$image_tag"
    
    # Test and deploy based on branch
    case $branch in
        "main")
            run_tests "production"
            quality_gates "production"
            deploy_with_rollback "production" "$image_tag"
            ;;
        "develop")
            run_tests "staging"
            quality_gates "staging"
            deploy_with_rollback "staging" "$image_tag"
            ;;
        *)
            run_tests "development"
            quality_gates "development"
            log "✅ Feature branch pipeline completed"
            ;;
    esac
    
    log "🎉 Pipeline completed successfully!"
}

# Execute main function
main "$@"
```

---

## 🏗️ Part 3: Jenkins Pipeline Integration

### Declarative Jenkins Pipeline

**Jenkinsfile for E-Commerce:**
```groovy
// Jenkinsfile - Advanced Jenkins pipeline for e-commerce
pipeline {
    agent any
    
    environment {
        REGISTRY = 'ghcr.io'
        IMAGE_NAME = 'ecommerce/api'
        DOCKER_BUILDKIT = '1'
        COMPOSE_DOCKER_CLI_BUILD = '1'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        retry(3)
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.IMAGE_TAG = "${env.BRANCH_NAME}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Code Quality') {
            parallel {
                stage('Lint') {
                    steps {
                        sh 'npm ci'
                        sh 'npm run lint'
                    }
                }
                
                stage('Security Audit') {
                    steps {
                        sh 'npm audit --audit-level=high'
                    }
                }
                
                stage('SonarQube Analysis') {
                    steps {
                        withSonarQubeEnv('SonarQube') {
                            sh 'npm run sonar'
                        }
                    }
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit -- --coverage'
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'test-results.xml'
                            publishCoverage adapters: [
                                istanbulCoberturaAdapter('coverage/cobertura-coverage.xml')
                            ]
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'docker-compose -f docker-compose.test.yml up -d'
                        sh 'npm run test:integration'
                    }
                    post {
                        always {
                            sh 'docker-compose -f docker-compose.test.yml down'
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def image = docker.build(
                        "${env.REGISTRY}/${env.IMAGE_NAME}:${env.IMAGE_TAG}",
                        "--build-arg NODE_ENV=production ."
                    )
                    
                    docker.withRegistry("https://${env.REGISTRY}", 'github-registry') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh """
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest \
                        image --exit-code 1 --severity HIGH,CRITICAL \
                        ${env.REGISTRY}/${env.IMAGE_NAME}:${env.IMAGE_TAG}
                """
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    deployToEnvironment('staging', env.IMAGE_TAG)
                }
            }
        }
        
        stage('Performance Tests') {
            when {
                branch 'develop'
            }
            steps {
                sh """
                    docker run --rm \
                        -v \$(pwd)/tests:/tests \
                        loadimpact/k6:latest \
                        run --vus 100 --duration 5m /tests/load-test.js
                """
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                script {
                    deployToEnvironment('production', env.IMAGE_TAG)
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        
        success {
            slackSend(
                color: 'good',
                message: "✅ Pipeline succeeded: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
            )
        }
        
        failure {
            slackSend(
                color: 'danger',
                message: "❌ Pipeline failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
            )
        }
    }
}

def deployToEnvironment(environment, imageTag) {
    sh """
        helm upgrade --install ecommerce-api ./helm/ecommerce-api \
            --namespace ${environment} \
            --set image.tag=${imageTag} \
            --set environment=${environment} \
            --wait --timeout=300s
    """
    
    // Health check
    sh """
        sleep 30
        curl -f https://${environment}.ecommerce.com/health
    """
}
```

---

## 🧪 Part 4: Testing Automation

### Comprehensive Test Suite

**Test Configuration:**
```javascript
// jest.config.js - Comprehensive test configuration
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: [
    '**/__tests__/**/*.+(ts|tsx|js)',
    '**/*.(test|spec).+(ts|tsx|js)'
  ],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/index.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
  testTimeout: 30000
};
```

**Automated Test Suite:**
```javascript
// tests/integration/ecommerce.test.js
const request = require('supertest');
const app = require('../../src/app');

describe('E-Commerce API Integration Tests', () => {
  let server;
  
  beforeAll(async () => {
    server = app.listen(0);
    await setupTestDatabase();
  });
  
  afterAll(async () => {
    await cleanupTestDatabase();
    server.close();
  });
  
  describe('Product Management', () => {
    test('should create a new product', async () => {
      const productData = {
        name: 'Test Product',
        price: 99.99,
        category: 'electronics'
      };
      
      const response = await request(server)
        .post('/api/products')
        .send(productData)
        .expect(201);
      
      expect(response.body).toMatchObject(productData);
      expect(response.body.id).toBeDefined();
    });
    
    test('should retrieve products with pagination', async () => {
      const response = await request(server)
        .get('/api/products?page=1&limit=10')
        .expect(200);
      
      expect(response.body).toHaveProperty('products');
      expect(response.body).toHaveProperty('pagination');
      expect(Array.isArray(response.body.products)).toBe(true);
    });
  });
  
  describe('Order Processing', () => {
    test('should process a complete order flow', async () => {
      // Create user
      const user = await createTestUser();
      
      // Add product to cart
      const product = await createTestProduct();
      await request(server)
        .post('/api/cart/add')
        .set('Authorization', `Bearer ${user.token}`)
        .send({ productId: product.id, quantity: 2 })
        .expect(200);
      
      // Process order
      const orderResponse = await request(server)
        .post('/api/orders')
        .set('Authorization', `Bearer ${user.token}`)
        .send({
          paymentMethod: 'credit_card',
          shippingAddress: {
            street: '123 Test St',
            city: 'Test City',
            zipCode: '12345'
          }
        })
        .expect(201);
      
      expect(orderResponse.body.status).toBe('confirmed');
      expect(orderResponse.body.total).toBeGreaterThan(0);
    });
  });
});
```

---

## 📊 Part 5: Pipeline Monitoring and Optimization

### Pipeline Analytics

**Pipeline Metrics Collection:**
```python
#!/usr/bin/env python3
# pipeline-analytics.py - CI/CD pipeline analytics

import json
import time
import requests
from datetime import datetime, timedelta
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class PipelineMetrics:
    build_time: float
    test_time: float
    deploy_time: float
    success_rate: float
    failure_reasons: List[str]

class PipelineAnalytics:
    def __init__(self):
        self.metrics_history = []
        
    def collect_build_metrics(self, build_id: str) -> PipelineMetrics:
        """Collect metrics for a specific build"""
        # This would integrate with your CI/CD system API
        # Example for GitHub Actions
        
        build_data = self.get_build_data(build_id)
        
        return PipelineMetrics(
            build_time=build_data.get('build_duration', 0),
            test_time=build_data.get('test_duration', 0),
            deploy_time=build_data.get('deploy_duration', 0),
            success_rate=build_data.get('success_rate', 0),
            failure_reasons=build_data.get('failure_reasons', [])
        )
    
    def analyze_trends(self, days: int = 30) -> Dict:
        """Analyze pipeline trends over time"""
        cutoff_date = datetime.now() - timedelta(days=days)
        recent_metrics = [
            m for m in self.metrics_history 
            if m.timestamp > cutoff_date
        ]
        
        if not recent_metrics:
            return {}
        
        avg_build_time = sum(m.build_time for m in recent_metrics) / len(recent_metrics)
        avg_success_rate = sum(m.success_rate for m in recent_metrics) / len(recent_metrics)
        
        # Identify bottlenecks
        bottlenecks = []
        if avg_build_time > 600:  # 10 minutes
            bottlenecks.append("Build time exceeds threshold")
        
        return {
            'average_build_time': avg_build_time,
            'average_success_rate': avg_success_rate,
            'total_builds': len(recent_metrics),
            'bottlenecks': bottlenecks,
            'recommendations': self.generate_recommendations(recent_metrics)
        }
    
    def generate_recommendations(self, metrics: List[PipelineMetrics]) -> List[str]:
        """Generate optimization recommendations"""
        recommendations = []
        
        avg_build_time = sum(m.build_time for m in metrics) / len(metrics)
        if avg_build_time > 600:
            recommendations.append("Consider implementing build caching")
            recommendations.append("Optimize Docker layer caching")
        
        failure_rate = 1 - (sum(m.success_rate for m in metrics) / len(metrics))
        if failure_rate > 0.1:  # 10% failure rate
            recommendations.append("Review and stabilize flaky tests")
            recommendations.append("Implement better error handling")
        
        return recommendations

if __name__ == "__main__":
    analytics = PipelineAnalytics()
    trends = analytics.analyze_trends(30)
    print(json.dumps(trends, indent=2))
```

---

## 🎓 Module Summary

You've mastered advanced CI/CD integration by learning:

**Core Concepts:**
- Container CI/CD pipeline architecture and best practices
- Multi-stage pipeline design with quality gates
- Advanced testing and security integration

**Practical Skills:**
- Implementing GitHub Actions and Jenkins pipelines
- Building comprehensive test automation suites
- Creating deployment strategies with rollback capabilities

**Enterprise Techniques:**
- Pipeline optimization and performance monitoring
- Advanced caching and build acceleration
- Analytics-driven pipeline improvements

**Next Steps:**
- Implement CI/CD pipelines for your e-commerce platform
- Set up comprehensive monitoring and analytics
- Prepare for Module 14: Industry Case Studies

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Build Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [CI/CD Security Best Practices](https://owasp.org/www-project-devsecops-guideline/)
    performance_score: float
    success_rate: float
    resource_usage: Dict[str, float]

@dataclass
class PipelineConfig:
    project_name: str
    dockerfile_path: str
    test_commands: List[str]
    security_scans: List[str]
    deployment_targets: List[str]
    optimization_level: str = "balanced"  # fast, balanced, thorough

class IntelligentPipeline:
    def __init__(self):
        self.client = docker.from_env()
        self.build_history: List[BuildMetrics] = []
        self.ml_model = None
        self.optimization_cache = {}
        
    async def execute_pipeline(self, config: PipelineConfig, 
                             git_commit: str, branch: str) -> Dict[str, Any]:
        """Execute intelligent CI/CD pipeline"""
        
        pipeline_id = f"{config.project_name}-{int(time.time())}"
        print(f"Starting intelligent pipeline: {pipeline_id}")
        
        start_time = time.time()
        
        try:
            # Phase 1: Pre-build optimization
            optimizations = await self.predict_optimizations(config)
            
            # Phase 2: Intelligent build
            build_result = await self.intelligent_build(config, optimizations)
            
            # Phase 3: Parallel testing
            test_results = await self.parallel_testing(config, build_result['image'])
            
            # Phase 4: Security analysis
            security_results = await self.advanced_security_scan(build_result['image'])
            
            # Phase 5: Performance benchmarking
            perf_results = await self.performance_benchmark(build_result['image'])
            
            # Phase 6: Deployment decision
            deploy_decision = await self.make_deployment_decision(
                build_result, test_results, security_results, perf_results
            )
            
            # Phase 7: Conditional deployment
            deployment_results = {}
            if deploy_decision['should_deploy']:
                deployment_results = await self.intelligent_deployment(
                    config, build_result['image'], deploy_decision
                )
            
            # Phase 8: Learn from results
            await self.update_ml_model(config, {
                'build': build_result,
                'tests': test_results,
                'security': security_results,
                'performance': perf_results,
                'deployment': deployment_results
            })
            
            total_time = time.time() - start_time
            
            return {
                'pipeline_id': pipeline_id,
                'status': 'success',
                'total_time': total_time,
                'build': build_result,
                'tests': test_results,
                'security': security_results,
                'performance': perf_results,
                'deployment': deployment_results,
                'optimizations_applied': optimizations
            }
            
        except Exception as e:
            return {
                'pipeline_id': pipeline_id,
                'status': 'failed',
                'error': str(e),
                'total_time': time.time() - start_time
            }
            
    async def predict_optimizations(self, config: PipelineConfig) -> Dict[str, Any]:
        """Use ML to predict optimal build configuration"""
        
        print("Predicting optimal build configuration...")
        
        # Generate feature vector from config and history
        features = self.extract_features(config)
        
        if self.ml_model and len(self.build_history) > 10:
            # Use trained model for predictions
            predictions = self.ml_model.predict([features])
            
            optimizations = {
                'parallel_builds': predictions[0] > 0.7,
                'cache_strategy': 'aggressive' if predictions[0] > 0.8 else 'conservative',
                'build_args': self.optimize_build_args(features),
                'resource_allocation': self.optimize_resources(features)
            }
        else:
            # Use heuristics for cold start
            optimizations = {
                'parallel_builds': True,
                'cache_strategy': 'balanced',
                'build_args': {'BUILDKIT_INLINE_CACHE': '1'},
                'resource_allocation': {'cpu': 2, 'memory': '4g'}
            }
            
        return optimizations
        
    def extract_features(self, config: PipelineConfig) -> List[float]:
        """Extract features for ML model"""
        
        features = [
            len(config.test_commands),
            len(config.security_scans),
            len(config.deployment_targets),
            hash(config.dockerfile_path) % 1000 / 1000.0,  # Normalized hash
            1.0 if config.optimization_level == 'fast' else 0.0,
            1.0 if config.optimization_level == 'thorough' else 0.0,
        ]
        
        # Add historical performance features
        if self.build_history:
            recent_builds = self.build_history[-10:]
            features.extend([
                np.mean([b.build_time for b in recent_builds]),
                np.mean([b.success_rate for b in recent_builds]),
                np.mean([b.security_score for b in recent_builds])
            ])
        else:
            features.extend([0.0, 0.0, 0.0])
            
        return features
        
    def optimize_build_args(self, features: List[float]) -> Dict[str, str]:
        """Optimize Docker build arguments based on features"""
        
        build_args = {
            'BUILDKIT_INLINE_CACHE': '1',
            'DOCKER_BUILDKIT': '1'
        }
        
        # Add optimization based on project characteristics
        if features[0] > 5:  # Many tests
            build_args['PARALLEL_JOBS'] = '4'
            
        if features[1] > 3:  # Many security scans
            build_args['SECURITY_OPTIMIZED'] = '1'
            
        return build_args
        
    def optimize_resources(self, features: List[float]) -> Dict[str, Any]:
        """Optimize resource allocation"""
        
        base_resources = {'cpu': 2, 'memory': '4g'}
        
        # Scale resources based on complexity
        complexity_score = sum(features[:3]) / 10.0
        
        if complexity_score > 0.7:
            base_resources['cpu'] = 4
            base_resources['memory'] = '8g'
        elif complexity_score < 0.3:
            base_resources['cpu'] = 1
            base_resources['memory'] = '2g'
            
        return base_resources
        
    async def intelligent_build(self, config: PipelineConfig, 
                              optimizations: Dict[str, Any]) -> Dict[str, Any]:
        """Execute optimized Docker build"""
        
        print("Starting intelligent build...")
        
        start_time = time.time()
        
        # Prepare build context
        build_args = optimizations.get('build_args', {})
        
        # Check build cache
        cache_key = self.generate_cache_key(config, build_args)
        if cache_key in self.optimization_cache:
            print("Using cached build result")
            return self.optimization_cache[cache_key]
            
        try:
            # Build with optimizations
            image, build_logs = self.client.images.build(
                path=config.dockerfile_path,
                tag=f"{config.project_name}:latest",
                buildargs=build_args,
                rm=True,
                forcerm=True,
                pull=True,
                nocache=False,
                squash=True if optimizations.get('cache_strategy') == 'aggressive' else False
            )
            
            build_time = time.time() - start_time
            image_size = image.attrs['Size']
            
            result = {
                'image': image,
                'image_id': image.id,
                'build_time': build_time,
                'image_size': image_size,
                'build_logs': list(build_logs),
                'optimizations_used': optimizations
            }
            
            # Cache successful builds
            self.optimization_cache[cache_key] = result
            
            print(f"Build completed in {build_time:.2f}s, size: {image_size / 1024 / 1024:.1f}MB")
            
            return result
            
        except Exception as e:
            raise Exception(f"Build failed: {str(e)}")
            
    def generate_cache_key(self, config: PipelineConfig, build_args: Dict) -> str:
        """Generate cache key for build"""
        
        cache_data = {
            'dockerfile': config.dockerfile_path,
            'build_args': build_args,
            'project': config.project_name
        }
        
        return hashlib.sha256(json.dumps(cache_data, sort_keys=True).encode()).hexdigest()
        
    async def parallel_testing(self, config: PipelineConfig, image) -> Dict[str, Any]:
        """Execute tests in parallel with intelligent scheduling"""
        
        print("Starting parallel testing...")
        
        start_time = time.time()
        
        # Categorize tests by type and estimated duration
        test_categories = self.categorize_tests(config.test_commands)
        
        # Execute tests in parallel batches
        results = {}
        
        # Fast tests first
        if test_categories['fast']:
            fast_results = await self.run_test_batch(image, test_categories['fast'], 'fast')
            results.update(fast_results)
            
        # Medium tests in parallel
        if test_categories['medium']:
            medium_results = await self.run_test_batch(image, test_categories['medium'], 'medium')
            results.update(medium_results)
            
        # Slow tests last (if fast tests passed)
        if test_categories['slow'] and all(r['passed'] for r in results.values()):
            slow_results = await self.run_test_batch(image, test_categories['slow'], 'slow')
            results.update(slow_results)
        elif test_categories['slow']:
            print("Skipping slow tests due to fast test failures")
            
        total_time = time.time() - start_time
        
        return {
            'results': results,
            'total_time': total_time,
            'passed': all(r['passed'] for r in results.values()),
            'coverage': self.calculate_coverage(results)
        }
        
    def categorize_tests(self, test_commands: List[str]) -> Dict[str, List[str]]:
        """Categorize tests by estimated execution time"""
        
        categories = {'fast': [], 'medium': [], 'slow': []}
        
        for cmd in test_commands:
            if any(keyword in cmd.lower() for keyword in ['unit', 'lint', 'format']):
                categories['fast'].append(cmd)
            elif any(keyword in cmd.lower() for keyword in ['integration', 'api']):
                categories['medium'].append(cmd)
            else:
                categories['slow'].append(cmd)
                
        return categories
        
    async def run_test_batch(self, image, commands: List[str], 
                           category: str) -> Dict[str, Any]:
        """Run a batch of tests"""
        
        print(f"Running {category} tests...")
        
        results = {}
        
        # Run tests in parallel (limited concurrency)
        semaphore = asyncio.Semaphore(3)  # Max 3 concurrent tests
        
        async def run_single_test(cmd: str):
            async with semaphore:
                return await self.execute_test(image, cmd)
                
        tasks = [run_single_test(cmd) for cmd in commands]
        test_results = await asyncio.gather(*tasks, return_exceptions=True)
        
        for i, result in enumerate(test_results):
            if isinstance(result, Exception):
                results[f"{category}_test_{i}"] = {
                    'command': commands[i],
                    'passed': False,
                    'error': str(result),
                    'duration': 0
                }
            else:
                results[f"{category}_test_{i}"] = result
                
        return results
        
    async def execute_test(self, image, command: str) -> Dict[str, Any]:
        """Execute individual test"""
        
        start_time = time.time()
        
        try:
            container = self.client.containers.run(
                image,
                command=command,
                detach=True,
                remove=True
            )
            
            # Wait for completion
            result = container.wait()
            logs = container.logs().decode('utf-8')
            
            duration = time.time() - start_time
            
            return {
                'command': command,
                'passed': result['StatusCode'] == 0,
                'duration': duration,
                'logs': logs,
                'exit_code': result['StatusCode']
            }
            
        except Exception as e:
            return {
                'command': command,
                'passed': False,
                'duration': time.time() - start_time,
                'error': str(e)
            }
            
    def calculate_coverage(self, test_results: Dict) -> float:
        """Calculate test coverage score"""
        
        if not test_results:
            return 0.0
            
        passed_tests = sum(1 for r in test_results.values() if r['passed'])
        total_tests = len(test_results)
        
        return passed_tests / total_tests
        
    async def advanced_security_scan(self, image) -> Dict[str, Any]:
        """Perform comprehensive security scanning"""
        
        print("Starting advanced security scan...")
        
        start_time = time.time()
        
        security_results = {
            'vulnerability_scan': await self.vulnerability_scan(image),
            'secrets_scan': await self.secrets_scan(image),
            'compliance_check': await self.compliance_check(image),
            'malware_scan': await self.malware_scan(image)
        }
        
        # Calculate overall security score
        security_score = self.calculate_security_score(security_results)
        
        return {
            'results': security_results,
            'security_score': security_score,
            'scan_time': time.time() - start_time,
            'passed': security_score > 0.7
        }
        
    async def vulnerability_scan(self, image) -> Dict[str, Any]:
        """Scan for vulnerabilities using Trivy"""
        
        try:
            # Run Trivy scan
            container = self.client.containers.run(
                'aquasec/trivy:latest',
                command=f'image --format json {image.id}',
                volumes={'/var/run/docker.sock': {'bind': '/var/run/docker.sock', 'mode': 'ro'}},
                detach=True,
                remove=True
            )
            
            result = container.wait()
            scan_output = container.logs().decode('utf-8')
            
            if result['StatusCode'] == 0:
                vulnerabilities = json.loads(scan_output)
                return {
                    'vulnerabilities': vulnerabilities,
                    'critical_count': len([v for v in vulnerabilities.get('Results', []) 
                                         if v.get('Severity') == 'CRITICAL']),
                    'high_count': len([v for v in vulnerabilities.get('Results', []) 
                                     if v.get('Severity') == 'HIGH'])
                }
            else:
                return {'error': 'Vulnerability scan failed', 'output': scan_output}
                
        except Exception as e:
            return {'error': str(e)}
            
    async def secrets_scan(self, image) -> Dict[str, Any]:
        """Scan for secrets and sensitive data"""
        
        # Mock implementation - would use tools like truffleHog
        return {
            'secrets_found': 0,
            'patterns_checked': ['api_key', 'password', 'token', 'private_key'],
            'clean': True
        }
        
    async def compliance_check(self, image) -> Dict[str, Any]:
        """Check compliance with security standards"""
        
        # Mock implementation - would check CIS benchmarks, etc.
        return {
            'cis_score': 0.85,
            'pci_compliant': True,
            'gdpr_compliant': True,
            'issues': []
        }
        
    async def malware_scan(self, image) -> Dict[str, Any]:
        """Scan for malware"""
        
        # Mock implementation - would use ClamAV or similar
        return {
            'threats_found': 0,
            'scan_complete': True,
            'clean': True
        }
        
    def calculate_security_score(self, results: Dict) -> float:
        """Calculate overall security score"""
        
        score = 1.0
        
        # Vulnerability penalties
        vuln_results = results.get('vulnerability_scan', {})
        critical_vulns = vuln_results.get('critical_count', 0)
        high_vulns = vuln_results.get('high_count', 0)
        
        score -= (critical_vulns * 0.2 + high_vulns * 0.1)
        
        # Secrets penalties
        secrets_results = results.get('secrets_scan', {})
        if not secrets_results.get('clean', True):
            score -= 0.3
            
        # Compliance bonus
        compliance_results = results.get('compliance_check', {})
        score *= compliance_results.get('cis_score', 1.0)
        
        return max(0.0, min(1.0, score))
        
    async def performance_benchmark(self, image) -> Dict[str, Any]:
        """Benchmark container performance"""
        
        print("Starting performance benchmark...")
        
        start_time = time.time()
        
        benchmarks = {
            'startup_time': await self.benchmark_startup_time(image),
            'memory_usage': await self.benchmark_memory_usage(image),
            'cpu_performance': await self.benchmark_cpu_performance(image),
            'io_performance': await self.benchmark_io_performance(image)
        }
        
        performance_score = self.calculate_performance_score(benchmarks)
        
        return {
            'benchmarks': benchmarks,
            'performance_score': performance_score,
            'benchmark_time': time.time() - start_time
        }
        
    async def benchmark_startup_time(self, image) -> Dict[str, float]:
        """Benchmark container startup time"""
        
        startup_times = []
        
        for _ in range(5):  # 5 iterations
            start_time = time.time()
            
            container = self.client.containers.run(
                image,
                command='echo "ready"',
                detach=True,
                remove=True
            )
            
            container.wait()
            startup_time = time.time() - start_time
            startup_times.append(startup_time)
            
        return {
            'avg_startup_time': np.mean(startup_times),
            'min_startup_time': np.min(startup_times),
            'max_startup_time': np.max(startup_times)
        }
        
    async def benchmark_memory_usage(self, image) -> Dict[str, float]:
        """Benchmark memory usage"""
        
        container = self.client.containers.run(
            image,
            command='sleep 30',
            detach=True,
            remove=True
        )
        
        try:
            # Collect memory stats
            stats = container.stats(stream=False)
            memory_usage = stats['memory_stats']['usage']
            memory_limit = stats['memory_stats']['limit']
            
            return {
                'memory_usage_mb': memory_usage / 1024 / 1024,
                'memory_percentage': (memory_usage / memory_limit) * 100
            }
        finally:
            container.stop()
            
    async def benchmark_cpu_performance(self, image) -> Dict[str, float]:
        """Benchmark CPU performance"""
        
        # Mock implementation
        return {
            'cpu_score': 85.5,
            'single_core_score': 92.3,
            'multi_core_score': 78.7
        }
        
    async def benchmark_io_performance(self, image) -> Dict[str, float]:
        """Benchmark I/O performance"""
        
        # Mock implementation
        return {
            'read_iops': 1500,
            'write_iops': 1200,
            'read_bandwidth_mbps': 150,
            'write_bandwidth_mbps': 120
        }
        
    def calculate_performance_score(self, benchmarks: Dict) -> float:
        """Calculate overall performance score"""
        
        startup_score = max(0, 1.0 - benchmarks['startup_time']['avg_startup_time'] / 10.0)
        memory_score = max(0, 1.0 - benchmarks['memory_usage']['memory_percentage'] / 100.0)
        cpu_score = benchmarks['cpu_performance']['cpu_score'] / 100.0
        io_score = min(1.0, benchmarks['io_performance']['read_iops'] / 2000.0)
        
        return (startup_score + memory_score + cpu_score + io_score) / 4.0
        
    async def make_deployment_decision(self, build_result: Dict, test_results: Dict,
                                     security_results: Dict, perf_results: Dict) -> Dict[str, Any]:
        """Make intelligent deployment decision"""
        
        print("Making deployment decision...")
        
        # Decision factors
        factors = {
            'tests_passed': test_results['passed'],
            'security_score': security_results['security_score'],
            'performance_score': perf_results['performance_score'],
            'build_success': build_result.get('image') is not None
        }
        
        # Decision logic
        should_deploy = (
            factors['tests_passed'] and
            factors['security_score'] > 0.7 and
            factors['performance_score'] > 0.6 and
            factors['build_success']
        )
        
        # Determine deployment strategy
        if should_deploy:
            if factors['security_score'] > 0.9 and factors['performance_score'] > 0.8:
                strategy = 'blue_green'
            elif factors['security_score'] > 0.8:
                strategy = 'canary'
            else:
                strategy = 'rolling'
        else:
            strategy = 'none'
            
        return {
            'should_deploy': should_deploy,
            'strategy': strategy,
            'factors': factors,
            'confidence': min(factors['security_score'], factors['performance_score'])
        }
        
    async def intelligent_deployment(self, config: PipelineConfig, image,
                                   decision: Dict[str, Any]) -> Dict[str, Any]:
        """Execute intelligent deployment"""
        
        print(f"Deploying using {decision['strategy']} strategy...")
        
        deployment_results = {}
        
        for target in config.deployment_targets:
            try:
                if decision['strategy'] == 'blue_green':
                    result = await self.blue_green_deploy(image, target)
                elif decision['strategy'] == 'canary':
                    result = await self.canary_deploy(image, target)
                else:
                    result = await self.rolling_deploy(image, target)
                    
                deployment_results[target] = result
                
            except Exception as e:
                deployment_results[target] = {'success': False, 'error': str(e)}
                
        return deployment_results
        
    async def blue_green_deploy(self, image, target: str) -> Dict[str, Any]:
        """Blue-green deployment"""
        # Implementation would integrate with orchestrator
        return {'success': True, 'strategy': 'blue_green', 'target': target}
        
    async def canary_deploy(self, image, target: str) -> Dict[str, Any]:
        """Canary deployment"""
        # Implementation would integrate with orchestrator
        return {'success': True, 'strategy': 'canary', 'target': target}
        
    async def rolling_deploy(self, image, target: str) -> Dict[str, Any]:
        """Rolling deployment"""
        # Implementation would integrate with orchestrator
        return {'success': True, 'strategy': 'rolling', 'target': target}
        
    async def update_ml_model(self, config: PipelineConfig, results: Dict[str, Any]):
        """Update ML model with new data"""
        
        # Extract metrics for training
        metrics = BuildMetrics(
            build_time=results['build']['build_time'],
            image_size=results['build']['image_size'],
            test_duration=results['tests']['total_time'],
            security_score=results['security']['security_score'],
            performance_score=results['performance']['performance_score'],
            success_rate=1.0 if results['tests']['passed'] else 0.0,
            resource_usage={'cpu': 2.0, 'memory': 4.0}  # Mock data
        )
        
        self.build_history.append(metrics)
        
        # Retrain model if we have enough data
        if len(self.build_history) > 20:
            await self.retrain_model()
            
    async def retrain_model(self):
        """Retrain ML model with historical data"""
        
        print("Retraining ML model...")
        
        # Prepare training data
        X = []
        y = []
        
        for metrics in self.build_history[-100:]:  # Use last 100 builds
            features = [
                metrics.build_time,
                metrics.image_size / 1024 / 1024,  # MB
                metrics.test_duration,
                metrics.security_score,
                metrics.performance_score
            ]
            X.append(features)
            y.append(metrics.success_rate)
            
        # Train model
        self.ml_model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.ml_model.fit(X, y)
        
        # Save model
        joblib.dump(self.ml_model, 'pipeline_model.pkl')
        
        print("ML model retrained and saved")

async def main():
    # Example usage
    config = PipelineConfig(
        project_name="my-web-app",
        dockerfile_path="./Dockerfile",
        test_commands=[
            "npm test",
            "npm run lint",
            "npm run integration-test"
        ],
        security_scans=[
            "trivy",
            "secrets-scan"
        ],
        deployment_targets=[
            "staging",
            "production"
        ],
        optimization_level="balanced"
    )
    
    pipeline = IntelligentPipeline()
    
    result = await pipeline.execute_pipeline(config, "abc123", "main")
    
    print(json.dumps(result, indent=2, default=str))

if __name__ == "__main__":
    asyncio.run(main())
```
