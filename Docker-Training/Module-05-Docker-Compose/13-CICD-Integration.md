# CI/CD Integration with Docker Compose

## Table of Contents
1. [GitLab CI/CD Pipeline](#gitlab-cicd-pipeline)
2. [GitHub Actions Integration](#github-actions-integration)
3. [Jenkins Pipeline](#jenkins-pipeline)
4. [Automated Testing](#automated-testing)
5. [Multi-Environment Deployment](#multi-environment-deployment)
6. [Security Integration](#security-integration)

## GitLab CI/CD Pipeline

### Complete GitLab CI Configuration
```yaml
# .gitlab-ci.yml
stages:
  - validate
  - build
  - test
  - security
  - deploy-staging
  - deploy-production

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  COMPOSE_PROJECT_NAME: myapp

services:
  - docker:dind

before_script:
  - docker info
  - docker-compose --version

# Validate Compose files
validate:
  stage: validate
  script:
    - docker-compose config --quiet
    - docker-compose -f docker-compose.prod.yml config --quiet
  only:
    - merge_requests
    - main

# Build images
build:
  stage: build
  script:
    - docker-compose build
    - docker-compose push
  only:
    - main
    - develop

# Run tests
test:
  stage: test
  script:
    - docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    - docker-compose -f docker-compose.test.yml down -v
  coverage: '/Coverage: \d+\.\d+%/'
  artifacts:
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

# Security scanning
security:
  stage: security
  script:
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
      aquasec/trivy image --exit-code 1 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  allow_failure: false

# Deploy to staging
deploy-staging:
  stage: deploy-staging
  script:
    - docker-compose -f docker-compose.staging.yml up -d
    - ./scripts/health-check.sh staging
  environment:
    name: staging
    url: https://staging.myapp.com
  only:
    - develop

# Deploy to production
deploy-production:
  stage: deploy-production
  script:
    - docker-compose -f docker-compose.prod.yml up -d
    - ./scripts/health-check.sh production
  environment:
    name: production
    url: https://myapp.com
  when: manual
  only:
    - main
```

### Environment-Specific Compose Files
```yaml
# docker-compose.staging.yml
version: '3.8'

services:
  app:
    image: ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
    environment:
      - NODE_ENV=staging
      - DATABASE_URL=${STAGING_DATABASE_URL}
    networks:
      - staging-network

  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${STAGING_DB_NAME}
      POSTGRES_USER: ${STAGING_DB_USER}
      POSTGRES_PASSWORD: ${STAGING_DB_PASSWORD}
    volumes:
      - staging_db_data:/var/lib/postgresql/data
    networks:
      - staging-network

volumes:
  staging_db_data:

networks:
  staging-network:
    driver: bridge
```

## GitHub Actions Integration

### GitHub Actions Workflow
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate Docker Compose
        run: |
          docker-compose config --quiet
          docker-compose -f docker-compose.prod.yml config --quiet

  build:
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push images
        run: |
          docker-compose build
          docker-compose push

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
          docker-compose -f docker-compose.test.yml down -v
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test-results/

  security:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [test, security]
    if: github.ref == 'refs/heads/develop'
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          docker-compose -f docker-compose.staging.yml up -d
          ./scripts/health-check.sh staging

  deploy-production:
    runs-on: ubuntu-latest
    needs: [test, security]
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          docker-compose -f docker-compose.prod.yml up -d
          ./scripts/health-check.sh production
```

## Jenkins Pipeline

### Jenkinsfile for Docker Compose
```groovy
pipeline {
    agent any
    
    environment {
        COMPOSE_PROJECT_NAME = 'myapp'
        REGISTRY = 'your-registry.com'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Validate') {
            steps {
                script {
                    sh 'docker-compose config --quiet'
                    sh 'docker-compose -f docker-compose.prod.yml config --quiet'
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'docker-compose build'
                    sh 'docker-compose push'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    try {
                        sh 'docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit'
                    } finally {
                        sh 'docker-compose -f docker-compose.test.yml down -v'
                    }
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'test-results.xml'
                    publishCoverage adapters: [
                        coberturaAdapter('coverage.xml')
                    ]
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh '''
                        docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy image --exit-code 1 --severity HIGH,CRITICAL \
                        ${REGISTRY}/myapp:${IMAGE_TAG}
                    '''
                }
            }
        }
        
        stage('Deploy Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    sh 'docker-compose -f docker-compose.staging.yml up -d'
                    sh './scripts/health-check.sh staging'
                }
            }
        }
        
        stage('Deploy Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                script {
                    sh 'docker-compose -f docker-compose.prod.yml up -d'
                    sh './scripts/health-check.sh production'
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f'
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

## Automated Testing

### Test Compose Configuration
```yaml
# docker-compose.test.yml
version: '3.8'

services:
  # Unit tests
  unit-tests:
    build:
      context: .
      target: test
    command: npm run test:unit
    volumes:
      - ./test-results:/app/test-results
    environment:
      - NODE_ENV=test

  # Integration tests
  integration-tests:
    build: .
    command: npm run test:integration
    depends_on:
      - test-database
      - test-redis
    environment:
      - NODE_ENV=test
      - DATABASE_URL=postgresql://test:test@test-database:5432/testdb
      - REDIS_URL=redis://test-redis:6379

  # E2E tests
  e2e-tests:
    build: .
    command: npm run test:e2e
    depends_on:
      - app
      - test-database
    environment:
      - APP_URL=http://app:3000

  # Test database
  test-database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    tmpfs:
      - /var/lib/postgresql/data

  # Test Redis
  test-redis:
    image: redis:alpine
    tmpfs:
      - /data

  # Application for E2E tests
  app:
    build: .
    environment:
      - NODE_ENV=test
      - DATABASE_URL=postgresql://test:test@test-database:5432/testdb
      - REDIS_URL=redis://test-redis:6379
    depends_on:
      - test-database
      - test-redis
```

### Test Scripts
```bash
#!/bin/bash
# scripts/run-tests.sh

set -e

echo "Running unit tests..."
docker-compose -f docker-compose.test.yml run --rm unit-tests

echo "Running integration tests..."
docker-compose -f docker-compose.test.yml run --rm integration-tests

echo "Running E2E tests..."
docker-compose -f docker-compose.test.yml up -d app test-database test-redis
sleep 10  # Wait for services to be ready
docker-compose -f docker-compose.test.yml run --rm e2e-tests

echo "Cleaning up..."
docker-compose -f docker-compose.test.yml down -v

echo "All tests passed!"
```

## Multi-Environment Deployment

### Environment Management Strategy
```yaml
# docker-compose.yml (base)
version: '3.8'

x-app-common: &app-common
  build: .
  networks:
    - app-network
  restart: unless-stopped

services:
  app:
    <<: *app-common
    environment:
      - NODE_ENV=${NODE_ENV:-production}
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}

  database:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### Environment-Specific Overrides
```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  app:
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DEBUG=true

  database:
    ports:
      - "5432:5432"

# docker-compose.staging.yml
version: '3.8'

services:
  app:
    image: ${REGISTRY}/myapp:${VERSION}
    environment:
      - NODE_ENV=staging
    deploy:
      replicas: 2

# docker-compose.prod.yml
version: '3.8'

services:
  app:
    image: ${REGISTRY}/myapp:${VERSION}
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
```

### Deployment Scripts
```bash
#!/bin/bash
# scripts/deploy.sh

ENVIRONMENT=$1
VERSION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <environment> <version>"
    exit 1
fi

case $ENVIRONMENT in
    "dev")
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
        ;;
    "staging")
        export VERSION=$VERSION
        docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
        ;;
    "prod")
        export VERSION=$VERSION
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac

echo "Deployed to $ENVIRONMENT with version $VERSION"
```

## Security Integration

### Security Scanning Pipeline
```yaml
# Security scanning in CI/CD
security-scan:
  stage: security
  script:
    # Container vulnerability scanning
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
      aquasec/trivy image --exit-code 1 --severity HIGH,CRITICAL $IMAGE_NAME
    
    # Compose file security scanning
    - docker run --rm -v $(pwd):/app 
      securecodewarrior/docker-compose-security-scanner /app/docker-compose.yml
    
    # Secret detection
    - docker run --rm -v $(pwd):/code 
      trufflesecurity/trufflehog filesystem /code --fail
    
    # OWASP dependency check
    - docker run --rm -v $(pwd):/src 
      owasp/dependency-check --scan /src --format JSON --out /src/dependency-check-report.json

  artifacts:
    reports:
      dependency_scanning: dependency-check-report.json
```

### Secure Deployment Configuration
```yaml
version: '3.8'

services:
  app:
    image: myapp:${VERSION}
    user: "1001:1001"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    secrets:
      - db_password
      - api_key
    environment:
      - DATABASE_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key

secrets:
  db_password:
    external: true
    name: myapp_db_password_${ENVIRONMENT}
  api_key:
    external: true
    name: myapp_api_key_${ENVIRONMENT}
```

This comprehensive CI/CD integration guide provides complete automation for Docker Compose applications with testing, security, and multi-environment deployment capabilities.
