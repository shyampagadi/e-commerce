# 🏢 Enterprise Deployment Strategies

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** enterprise deployment patterns and strategies
- **Master** zero-downtime deployment techniques for production systems
- **Implement** advanced deployment automation for e-commerce platforms
- **Configure** multi-environment deployment pipelines
- **Deploy** production-ready enterprise deployment solutions

## 🎯 Real-World Context
E-commerce platforms require sophisticated deployment strategies to maintain high availability while continuously delivering new features. This module teaches you enterprise-grade deployment patterns used by Fortune 500 companies to achieve 99.99% uptime and seamless user experiences.

---

## 📚 Part 1: Enterprise Deployment Fundamentals

### Deployment Strategy Overview

**Key Deployment Patterns:**

**1. Blue-Green Deployment**
- Two identical production environments
- Instant traffic switching
- Easy rollback capability
- Zero downtime deployments

**2. Canary Deployment**
- Gradual traffic shifting
- Risk mitigation through limited exposure
- Real-time monitoring and validation
- Automated rollback on issues

**3. Rolling Deployment**
- Incremental instance replacement
- Continuous availability
- Resource-efficient approach
- Built-in health checking

**4. A/B Testing Deployment**
- Feature flag-driven releases
- User segment targeting
- Performance comparison
- Data-driven decision making

### Deployment Requirements for E-Commerce

**High Availability Requirements:**
- 99.99% uptime (52 minutes downtime/year)
- Zero-downtime deployments
- Instant rollback capability
- Multi-region deployment support

**Performance Requirements:**
- Sub-second response times
- Horizontal scaling capability
- Load balancing and traffic distribution
- Resource optimization

**Security Requirements:**
- Secure deployment pipelines
- Secret management
- Access control and auditing
- Compliance validation

---

## 🔧 Part 2: Blue-Green Deployment Implementation

### Blue-Green Deployment for E-Commerce

**Infrastructure Setup:**
```yaml
# docker-compose.blue-green.yml
version: '3.8'

services:
  # Blue environment
  ecommerce-api-blue:
    image: ecommerce/api:${BLUE_VERSION:-latest}
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@database:5432/ecommerce
      - REDIS_URL=redis://cache:6379
      - ENVIRONMENT_COLOR=blue
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    labels:
      - "environment=blue"
      - "app=ecommerce-api"

  # Green environment
  ecommerce-api-green:
    image: ecommerce/api:${GREEN_VERSION:-latest}
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@database:5432/ecommerce
      - REDIS_URL=redis://cache:6379
      - ENVIRONMENT_COLOR=green
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    labels:
      - "environment=green"
      - "app=ecommerce-api"

  # Load balancer
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - ecommerce-api-blue
      - ecommerce-api-green
    labels:
      - "app=load-balancer"

  # Shared services
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  cache:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

**Blue-Green Deployment Script:**
```bash
#!/bin/bash
# blue-green-deploy.sh - Automated blue-green deployment

set -e

# Configuration
CURRENT_ENV=""
NEW_ENV=""
NEW_VERSION=""
HEALTH_CHECK_URL="http://localhost/health"
HEALTH_CHECK_TIMEOUT=300

# Function to determine current active environment
get_current_environment() {
    # Check nginx configuration to see which environment is active
    if docker exec nginx-lb_nginx-lb_1 cat /etc/nginx/nginx.conf | grep -q "ecommerce-api-blue"; then
        echo "blue"
    else
        echo "green"
    fi
}

# Function to get inactive environment
get_inactive_environment() {
    local current=$1
    if [ "$current" = "blue" ]; then
        echo "green"
    else
        echo "blue"
    fi
}

# Function to wait for service health
wait_for_health() {
    local environment=$1
    local timeout=$2
    local start_time=$(date +%s)
    
    echo "⏳ Waiting for $environment environment to be healthy..."
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $timeout ]; then
            echo "❌ Health check timeout for $environment environment"
            return 1
        fi
        
        # Check if all containers are healthy
        local healthy_count=$(docker ps --filter "label=environment=$environment" --filter "health=healthy" --format "{{.Names}}" | wc -l)
        local total_count=$(docker ps --filter "label=environment=$environment" --format "{{.Names}}" | wc -l)
        
        if [ "$healthy_count" -eq "$total_count" ] && [ "$total_count" -gt 0 ]; then
            echo "✅ $environment environment is healthy ($healthy_count/$total_count containers)"
            return 0
        fi
        
        echo "⏳ Health check: $healthy_count/$total_count containers healthy"
        sleep 10
    done
}

# Function to switch traffic
switch_traffic() {
    local target_env=$1
    
    echo "🔄 Switching traffic to $target_env environment..."
    
    # Generate new nginx configuration
    cat > /tmp/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server ecommerce-api-$target_env:3000;
    }
    
    server {
        listen 80;
        
        location /health {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
        }
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF
    
    # Update nginx configuration
    docker cp /tmp/nginx.conf nginx-lb_nginx-lb_1:/etc/nginx/nginx.conf
    docker exec nginx-lb_nginx-lb_1 nginx -s reload
    
    echo "✅ Traffic switched to $target_env environment"
}

# Function to validate deployment
validate_deployment() {
    local environment=$1
    
    echo "🔍 Validating $environment deployment..."
    
    # Test health endpoint
    local response=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_CHECK_URL)
    
    if [ "$response" = "200" ]; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed (HTTP $response)"
        return 1
    fi
    
    # Test application functionality
    local api_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/products)
    
    if [ "$api_response" = "200" ]; then
        echo "✅ API functionality test passed"
    else
        echo "❌ API functionality test failed (HTTP $api_response)"
        return 1
    fi
    
    return 0
}

# Main deployment function
deploy() {
    local version=$1
    
    if [ -z "$version" ]; then
        echo "Usage: $0 <version>"
        exit 1
    fi
    
    echo "🚀 Starting blue-green deployment for version $version"
    echo "=================================================="
    
    # Determine current and target environments
    CURRENT_ENV=$(get_current_environment)
    NEW_ENV=$(get_inactive_environment $CURRENT_ENV)
    NEW_VERSION=$version
    
    echo "📊 Current environment: $CURRENT_ENV"
    echo "📊 Target environment: $NEW_ENV"
    echo "📊 New version: $NEW_VERSION"
    
    # Deploy to inactive environment
    echo "🔄 Deploying version $NEW_VERSION to $NEW_ENV environment..."
    
    if [ "$NEW_ENV" = "green" ]; then
        GREEN_VERSION=$NEW_VERSION docker-compose -f docker-compose.blue-green.yml up -d ecommerce-api-green
    else
        BLUE_VERSION=$NEW_VERSION docker-compose -f docker-compose.blue-green.yml up -d ecommerce-api-blue
    fi
    
    # Wait for new environment to be healthy
    if ! wait_for_health $NEW_ENV $HEALTH_CHECK_TIMEOUT; then
        echo "❌ Deployment failed - $NEW_ENV environment not healthy"
        exit 1
    fi
    
    # Switch traffic to new environment
    switch_traffic $NEW_ENV
    
    # Validate deployment
    sleep 30  # Allow time for traffic to stabilize
    
    if validate_deployment $NEW_ENV; then
        echo "✅ Deployment successful!"
        echo "🎯 Version $NEW_VERSION is now live on $NEW_ENV environment"
    else
        echo "❌ Deployment validation failed - rolling back..."
        switch_traffic $CURRENT_ENV
        echo "🔄 Rolled back to $CURRENT_ENV environment"
        exit 1
    fi
}

# Run deployment
deploy $1
```

---

## 🎯 Part 3: Canary Deployment Strategy

### Canary Deployment Implementation

**Canary Deployment Configuration:**
```yaml
# docker-compose.canary.yml
version: '3.8'

services:
  # Production environment (stable)
  ecommerce-api-stable:
    image: ecommerce/api:${STABLE_VERSION:-latest}
    deploy:
      replicas: 8  # 80% of traffic
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    environment:
      - NODE_ENV=production
      - DEPLOYMENT_TYPE=stable
    labels:
      - "deployment=stable"
      - "app=ecommerce-api"

  # Canary environment (new version)
  ecommerce-api-canary:
    image: ecommerce/api:${CANARY_VERSION:-latest}
    deploy:
      replicas: 2  # 20% of traffic
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    environment:
      - NODE_ENV=production
      - DEPLOYMENT_TYPE=canary
    labels:
      - "deployment=canary"
      - "app=ecommerce-api"

  # Intelligent load balancer
  nginx-canary:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/canary-nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - ecommerce-api-stable
      - ecommerce-api-canary
```

**Canary Deployment Script:**
```python
#!/usr/bin/env python3
# canary-deploy.py - Intelligent canary deployment

import time
import requests
import docker
import json
from datetime import datetime, timedelta

class CanaryDeployment:
    def __init__(self):
        self.client = docker.from_env()
        self.metrics = {
            'stable': {'requests': 0, 'errors': 0, 'response_times': []},
            'canary': {'requests': 0, 'errors': 0, 'response_times': []}
        }
        
    def deploy_canary(self, version, traffic_percentage=10):
        """Deploy canary version with specified traffic percentage"""
        print(f"🚀 Deploying canary version {version} with {traffic_percentage}% traffic")
        
        # Calculate replica counts based on traffic percentage
        total_replicas = 10
        canary_replicas = max(1, int(total_replicas * traffic_percentage / 100))
        stable_replicas = total_replicas - canary_replicas
        
        # Update nginx configuration for traffic splitting
        self.update_nginx_config(stable_replicas, canary_replicas)
        
        # Deploy canary containers
        self.deploy_containers('canary', version, canary_replicas)
        
        # Wait for canary to be healthy
        if self.wait_for_health('canary'):
            print("✅ Canary deployment healthy")
            return True
        else:
            print("❌ Canary deployment failed health check")
            return False
    
    def monitor_canary(self, duration_minutes=30):
        """Monitor canary deployment performance"""
        print(f"📊 Monitoring canary for {duration_minutes} minutes...")
        
        start_time = datetime.now()
        end_time = start_time + timedelta(minutes=duration_minutes)
        
        while datetime.now() < end_time:
            # Collect metrics from both environments
            self.collect_metrics()
            
            # Analyze performance
            if self.should_rollback():
                print("⚠️ Performance degradation detected - initiating rollback")
                self.rollback_canary()
                return False
            
            # Check if canary is performing well
            if self.canary_performing_well():
                print("✅ Canary performing well - ready for full deployment")
                return True
            
            time.sleep(60)  # Check every minute
        
        print("⏰ Monitoring period completed")
        return self.canary_performing_well()
    
    def collect_metrics(self):
        """Collect performance metrics from both environments"""
        try:
            # Get metrics from monitoring endpoint
            stable_metrics = requests.get('http://localhost/metrics?env=stable', timeout=5).json()
            canary_metrics = requests.get('http://localhost/metrics?env=canary', timeout=5).json()
            
            self.metrics['stable'].update(stable_metrics)
            self.metrics['canary'].update(canary_metrics)
            
            print(f"📈 Stable: {stable_metrics.get('error_rate', 0):.2f}% errors, "
                  f"Canary: {canary_metrics.get('error_rate', 0):.2f}% errors")
            
        except Exception as e:
            print(f"❌ Error collecting metrics: {e}")
    
    def should_rollback(self):
        """Determine if canary should be rolled back"""
        stable_error_rate = self.metrics['stable'].get('error_rate', 0)
        canary_error_rate = self.metrics['canary'].get('error_rate', 0)
        
        # Rollback if canary error rate is significantly higher
        if canary_error_rate > stable_error_rate * 2 and canary_error_rate > 5:
            return True
        
        # Rollback if canary response time is significantly slower
        stable_response_time = self.metrics['stable'].get('avg_response_time', 0)
        canary_response_time = self.metrics['canary'].get('avg_response_time', 0)
        
        if canary_response_time > stable_response_time * 1.5 and canary_response_time > 1000:
            return True
        
        return False
    
    def canary_performing_well(self):
        """Check if canary is performing well enough for full deployment"""
        stable_error_rate = self.metrics['stable'].get('error_rate', 0)
        canary_error_rate = self.metrics['canary'].get('error_rate', 0)
        
        # Canary should have similar or better error rate
        if canary_error_rate <= stable_error_rate * 1.1:
            return True
        
        return False
    
    def promote_canary(self):
        """Promote canary to full production"""
        print("🎯 Promoting canary to full production...")
        
        # Gradually increase canary traffic
        traffic_levels = [20, 50, 80, 100]
        
        for traffic in traffic_levels:
            print(f"📈 Increasing canary traffic to {traffic}%")
            self.deploy_canary(self.canary_version, traffic)
            
            # Monitor for 5 minutes at each level
            time.sleep(300)
            
            if self.should_rollback():
                print("❌ Issues detected during promotion - rolling back")
                self.rollback_canary()
                return False
        
        print("✅ Canary successfully promoted to production")
        return True
    
    def rollback_canary(self):
        """Rollback canary deployment"""
        print("🔄 Rolling back canary deployment...")
        
        # Remove canary containers
        canary_containers = self.client.containers.list(
            filters={'label': 'deployment=canary'}
        )
        
        for container in canary_containers:
            container.stop()
            container.remove()
        
        # Update nginx to route all traffic to stable
        self.update_nginx_config(10, 0)
        
        print("✅ Canary rollback completed")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: python3 canary-deploy.py <version>")
        sys.exit(1)
    
    version = sys.argv[1]
    canary = CanaryDeployment()
    
    # Deploy canary
    if canary.deploy_canary(version):
        # Monitor canary
        if canary.monitor_canary():
            # Promote to production
            canary.promote_canary()
        else:
            canary.rollback_canary()
```

---

## 🏗️ Part 4: Multi-Environment Pipeline

### Complete Deployment Pipeline

**Multi-Environment Configuration:**
```yaml
# docker-compose.pipeline.yml
version: '3.8'

services:
  # Development environment
  ecommerce-dev:
    image: ecommerce/api:${DEV_VERSION:-dev}
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@dev-db:5432/ecommerce_dev
    ports:
      - "3001:3000"
    labels:
      - "environment=development"

  # Staging environment
  ecommerce-staging:
    image: ecommerce/api:${STAGING_VERSION:-staging}
    environment:
      - NODE_ENV=staging
      - DATABASE_URL=postgresql://postgres:password@staging-db:5432/ecommerce_staging
    ports:
      - "3002:3000"
    labels:
      - "environment=staging"

  # Production environment
  ecommerce-prod:
    image: ecommerce/api:${PROD_VERSION:-latest}
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@prod-db:5432/ecommerce
    ports:
      - "3000:3000"
    deploy:
      replicas: 3
    labels:
      - "environment=production"

  # Environment-specific databases
  dev-db:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - dev_db_data:/var/lib/postgresql/data

  staging-db:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce_staging
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - staging_db_data:/var/lib/postgresql/data

  prod-db:
    image: postgres:15
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - prod_db_data:/var/lib/postgresql/data

volumes:
  dev_db_data:
  staging_db_data:
  prod_db_data:
```

**Automated Pipeline Script:**
```bash
#!/bin/bash
# deployment-pipeline.sh - Complete deployment pipeline

set -e

# Configuration
ENVIRONMENTS=("development" "staging" "production")
VERSION=""
SKIP_TESTS=false
AUTO_PROMOTE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --auto-promote)
            AUTO_PROMOTE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$VERSION" ]; then
    echo "Usage: $0 --version <version> [--skip-tests] [--auto-promote]"
    exit 1
fi

# Function to run tests
run_tests() {
    local environment=$1
    
    if [ "$SKIP_TESTS" = true ]; then
        echo "⏭️ Skipping tests for $environment"
        return 0
    fi
    
    echo "🧪 Running tests for $environment environment..."
    
    # Unit tests
    docker run --rm \
        -v $(pwd):/app \
        -w /app \
        node:18-alpine \
        npm test
    
    # Integration tests
    docker run --rm \
        --network container:ecommerce-${environment}_1 \
        -v $(pwd)/tests:/tests \
        node:18-alpine \
        npm run test:integration
    
    # Load tests for staging and production
    if [ "$environment" != "development" ]; then
        echo "⚡ Running load tests..."
        docker run --rm \
            --network container:ecommerce-${environment}_1 \
            -v $(pwd)/tests:/tests \
            loadimpact/k6:latest \
            run /tests/load-test.js
    fi
    
    echo "✅ Tests passed for $environment"
}

# Function to deploy to environment
deploy_to_environment() {
    local environment=$1
    local version=$2
    
    echo "🚀 Deploying version $version to $environment..."
    
    # Set environment-specific version
    case $environment in
        "development")
            DEV_VERSION=$version docker-compose -f docker-compose.pipeline.yml up -d ecommerce-dev
            ;;
        "staging")
            STAGING_VERSION=$version docker-compose -f docker-compose.pipeline.yml up -d ecommerce-staging
            ;;
        "production")
            PROD_VERSION=$version docker-compose -f docker-compose.pipeline.yml up -d ecommerce-prod
            ;;
    esac
    
    # Wait for deployment to be healthy
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local port
        case $environment in
            "development") port=3001 ;;
            "staging") port=3002 ;;
            "production") port=3000 ;;
        esac
        
        if curl -f -s http://localhost:$port/health > /dev/null; then
            echo "✅ $environment deployment healthy"
            return 0
        fi
        
        echo "⏳ Waiting for $environment to be healthy (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    echo "❌ $environment deployment failed health check"
    return 1
}

# Function to promote between environments
promote_version() {
    local from_env=$1
    local to_env=$2
    local version=$3
    
    echo "📈 Promoting version $version from $from_env to $to_env"
    
    # Deploy to target environment
    if deploy_to_environment $to_env $version; then
        # Run tests
        if run_tests $to_env; then
            echo "✅ Successfully promoted to $to_env"
            return 0
        else
            echo "❌ Tests failed in $to_env - rolling back"
            return 1
        fi
    else
        echo "❌ Deployment failed in $to_env"
        return 1
    fi
}

# Main pipeline execution
main() {
    echo "🚀 Starting deployment pipeline for version $VERSION"
    echo "=================================================="
    
    # Deploy to development
    if deploy_to_environment "development" $VERSION; then
        run_tests "development"
    else
        echo "❌ Development deployment failed"
        exit 1
    fi
    
    # Promote to staging
    if [ "$AUTO_PROMOTE" = true ] || read -p "Promote to staging? (y/N): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        if promote_version "development" "staging" $VERSION; then
            echo "✅ Staging deployment successful"
        else
            echo "❌ Staging deployment failed"
            exit 1
        fi
    fi
    
    # Promote to production
    if [ "$AUTO_PROMOTE" = true ] || read -p "Promote to production? (y/N): " -n 1 -r && [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        if promote_version "staging" "production" $VERSION; then
            echo "🎯 Production deployment successful!"
            echo "Version $VERSION is now live in production"
        else
            echo "❌ Production deployment failed"
            exit 1
        fi
    fi
    
    echo "🎉 Deployment pipeline completed successfully!"
}

# Run main function
main
```

---

## 🎓 Module Summary

You've mastered enterprise deployment strategies by learning:

**Core Concepts:**
- Enterprise deployment patterns (blue-green, canary, rolling)
- Zero-downtime deployment techniques
- Multi-environment pipeline strategies

**Practical Skills:**
- Implementing automated deployment workflows
- Building intelligent traffic routing and monitoring
- Creating comprehensive validation and rollback mechanisms

**Enterprise Techniques:**
- Production-ready deployment automation
- Advanced monitoring and alerting during deployments
- Risk mitigation through gradual rollout strategies

**Next Steps:**
- Implement deployment strategies for your e-commerce platform
- Set up automated deployment pipelines
- Prepare for Module 13: Advanced CI/CD Integration

---

## 📚 Additional Resources

- [Blue-Green Deployment Guide](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Canary Deployment Patterns](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)
- [Docker Swarm Deployment](https://docs.docker.com/engine/swarm/services/)
- [Enterprise Deployment Best Practices](https://cloud.google.com/architecture/application-deployment-and-testing-strategies)

class BlueGreenOrchestrator:
    def __init__(self):
        self.client = docker.from_env()
        self.deployments: Dict[str, dict] = {}
        
    async def deploy(self, config: DeploymentConfig) -> bool:
        """Execute blue-green deployment"""
        
        print(f"Starting blue-green deployment for {config.service_name}")
        
        # Step 1: Identify current environment
        current_env = await self.get_current_environment(config.service_name)
        target_env = "green" if current_env == "blue" else "blue"
        
        print(f"Current environment: {current_env}, Target: {target_env}")
        
        try:
            # Step 2: Deploy to target environment
            await self.deploy_to_environment(config, target_env)
            
            # Step 3: Health checks
            if not await self.wait_for_health(config, target_env):
                raise Exception("Health checks failed")
                
            # Step 4: Smoke tests
            if not await self.run_smoke_tests(config, target_env):
                raise Exception("Smoke tests failed")
                
            # Step 5: Gradual traffic shift
            await self.gradual_traffic_shift(config, current_env, target_env)
            
            # Step 6: Monitor and validate
            if not await self.monitor_deployment(config, target_env):
                # Rollback if issues detected
                await self.rollback(config, current_env, target_env)
                return False
                
            # Step 7: Cleanup old environment
            await self.cleanup_environment(config, current_env)
            
            print(f"Blue-green deployment completed successfully")
            return True
            
        except Exception as e:
            print(f"Deployment failed: {e}")
            await self.rollback(config, current_env, target_env)
            return False
            
    async def get_current_environment(self, service_name: str) -> str:
        """Determine current active environment"""
        
        try:
            # Check which environment is receiving traffic
            blue_containers = self.client.containers.list(
                filters={'label': f'service={service_name}', 'label': 'environment=blue'}
            )
            green_containers = self.client.containers.list(
                filters={'label': f'service={service_name}', 'label': 'environment=green'}
            )
            
            # Simple logic: environment with more running containers is current
            if len(blue_containers) >= len(green_containers):
                return "blue"
            else:
                return "green"
                
        except Exception:
            return "blue"  # Default to blue
            
    async def deploy_to_environment(self, config: DeploymentConfig, environment: str):
        """Deploy containers to specific environment"""
        
        print(f"Deploying {config.replicas} replicas to {environment} environment")
        
        # Remove existing containers in target environment
        existing_containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': f'environment={environment}'}
        )
        
        for container in existing_containers:
            container.stop(timeout=10)
            container.remove()
            
        # Deploy new containers
        for i in range(config.replicas):
            container_name = f"{config.service_name}-{environment}-{i}"
            
            container = self.client.containers.run(
                config.image,
                name=container_name,
                labels={
                    'service': config.service_name,
                    'environment': environment,
                    'replica': str(i),
                    'deployment_time': str(int(time.time()))
                },
                network_mode='bridge',
                detach=True,
                restart_policy={'Name': 'unless-stopped'}
            )
            
            print(f"Started container: {container_name}")
            
        # Wait for containers to start
        await asyncio.sleep(10)
        
    async def wait_for_health(self, config: DeploymentConfig, environment: str) -> bool:
        """Wait for all containers to pass health checks"""
        
        print(f"Waiting for health checks in {environment} environment")
        
        containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': f'environment={environment}'}
        )
        
        start_time = time.time()
        
        while time.time() - start_time < config.health_check_timeout:
            healthy_count = 0
            
            for container in containers:
                if await self.check_container_health(container, config.health_check_url):
                    healthy_count += 1
                    
            if healthy_count == len(containers):
                print(f"All {len(containers)} containers are healthy")
                return True
                
            print(f"Health check: {healthy_count}/{len(containers)} containers healthy")
            await asyncio.sleep(5)
            
        print("Health check timeout")
        return False
        
    async def check_container_health(self, container, health_url: str) -> bool:
        """Check individual container health"""
        
        try:
            # Get container IP
            container.reload()
            networks = container.attrs['NetworkSettings']['Networks']
            
            if not networks:
                return False
                
            # Get first available IP
            container_ip = list(networks.values())[0]['IPAddress']
            
            if not container_ip:
                return False
                
            # Make health check request
            url = f"http://{container_ip}:8080{health_url}"
            response = requests.get(url, timeout=5)
            
            return response.status_code == 200
            
        except Exception as e:
            return False
            
    async def run_smoke_tests(self, config: DeploymentConfig, environment: str) -> bool:
        """Run smoke tests against new deployment"""
        
        print(f"Running smoke tests for {environment} environment")
        
        containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': f'environment={environment}'}
        )
        
        # Test each container
        for container in containers:
            if not await self.run_container_smoke_tests(container):
                return False
                
        print("All smoke tests passed")
        return True
        
    async def run_container_smoke_tests(self, container) -> bool:
        """Run smoke tests for individual container"""
        
        try:
            # Get container IP
            container.reload()
            networks = container.attrs['NetworkSettings']['Networks']
            container_ip = list(networks.values())[0]['IPAddress']
            
            # Basic connectivity test
            response = requests.get(f"http://{container_ip}:8080/health", timeout=10)
            if response.status_code != 200:
                return False
                
            # Functional test
            response = requests.get(f"http://{container_ip}:8080/api/status", timeout=10)
            if response.status_code != 200:
                return False
                
            return True
            
        except Exception:
            return False
            
    async def gradual_traffic_shift(self, config: DeploymentConfig, 
                                  current_env: str, target_env: str):
        """Gradually shift traffic from current to target environment"""
        
        print(f"Starting gradual traffic shift from {current_env} to {target_env}")
        
        # Traffic shift percentages
        shift_steps = [10, 25, 50, 75, 100]
        
        for target_percentage in shift_steps:
            current_percentage = 100 - target_percentage
            
            print(f"Shifting traffic: {current_percentage}% {current_env}, {target_percentage}% {target_env}")
            
            # Update load balancer configuration
            await self.update_load_balancer(
                config.service_name, 
                current_env, current_percentage,
                target_env, target_percentage
            )
            
            # Wait and monitor
            await asyncio.sleep(config.traffic_shift_delay)
            
            # Check error rates
            error_rate = await self.get_error_rate(config.service_name)
            if error_rate > config.rollback_threshold:
                raise Exception(f"High error rate detected: {error_rate}")
                
        print("Traffic shift completed")
        
    async def update_load_balancer(self, service_name: str, 
                                 env1: str, weight1: int,
                                 env2: str, weight2: int):
        """Update load balancer weights"""
        
        # This would integrate with your load balancer (nginx, HAProxy, etc.)
        print(f"Load balancer updated: {env1}={weight1}%, {env2}={weight2}%")
        
        # Example nginx configuration update
        nginx_config = f"""
        upstream {service_name} {{
            server {service_name}-{env1}:8080 weight={weight1};
            server {service_name}-{env2}:8080 weight={weight2};
        }}
        """
        
        # Write configuration and reload nginx
        # Implementation depends on your load balancer setup
        
    async def get_error_rate(self, service_name: str) -> float:
        """Get current error rate from monitoring system"""
        
        # This would integrate with your monitoring system
        # Mock implementation
        return 0.01  # 1% error rate
        
    async def monitor_deployment(self, config: DeploymentConfig, environment: str) -> bool:
        """Monitor deployment for issues"""
        
        print(f"Monitoring {environment} environment for 5 minutes")
        
        monitor_duration = 300  # 5 minutes
        check_interval = 30     # 30 seconds
        
        start_time = time.time()
        
        while time.time() - start_time < monitor_duration:
            # Check error rate
            error_rate = await self.get_error_rate(config.service_name)
            if error_rate > config.rollback_threshold:
                print(f"High error rate detected: {error_rate}")
                return False
                
            # Check container health
            containers = self.client.containers.list(
                filters={'label': f'service={config.service_name}', 'label': f'environment={environment}'}
            )
            
            healthy_containers = 0
            for container in containers:
                if await self.check_container_health(container, config.health_check_url):
                    healthy_containers += 1
                    
            health_percentage = healthy_containers / len(containers)
            if health_percentage < 0.8:  # Less than 80% healthy
                print(f"Low container health: {health_percentage}")
                return False
                
            print(f"Monitoring: Error rate={error_rate}, Health={health_percentage}")
            await asyncio.sleep(check_interval)
            
        print("Monitoring completed successfully")
        return True
        
    async def rollback(self, config: DeploymentConfig, current_env: str, target_env: str):
        """Rollback to previous environment"""
        
        print(f"Rolling back from {target_env} to {current_env}")
        
        # Shift all traffic back to current environment
        await self.update_load_balancer(
            config.service_name,
            current_env, 100,
            target_env, 0
        )
        
        # Stop containers in target environment
        containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': f'environment={target_env}'}
        )
        
        for container in containers:
            container.stop(timeout=10)
            
        print("Rollback completed")
        
    async def cleanup_environment(self, config: DeploymentConfig, environment: str):
        """Cleanup old environment after successful deployment"""
        
        print(f"Cleaning up {environment} environment")
        
        containers = self.client.containers.list(
            all=True,
            filters={'label': f'service={config.service_name}', 'label': f'environment={environment}'}
        )
        
        for container in containers:
            container.remove(force=True)
            
        print(f"Cleanup completed for {environment} environment")

class CanaryDeploymentOrchestrator:
    def __init__(self):
        self.client = docker.from_env()
        
    async def deploy_canary(self, config: DeploymentConfig, canary_percentage: int = 5) -> bool:
        """Deploy canary version with specified traffic percentage"""
        
        print(f"Starting canary deployment for {config.service_name} ({canary_percentage}% traffic)")
        
        try:
            # Deploy canary containers
            canary_replicas = max(1, int(config.replicas * canary_percentage / 100))
            await self.deploy_canary_containers(config, canary_replicas)
            
            # Health checks
            if not await self.wait_for_canary_health(config):
                raise Exception("Canary health checks failed")
                
            # Route canary traffic
            await self.route_canary_traffic(config.service_name, canary_percentage)
            
            # Monitor canary
            if not await self.monitor_canary(config):
                await self.rollback_canary(config)
                return False
                
            # Promote canary
            await self.promote_canary(config)
            
            print("Canary deployment completed successfully")
            return True
            
        except Exception as e:
            print(f"Canary deployment failed: {e}")
            await self.rollback_canary(config)
            return False
            
    async def deploy_canary_containers(self, config: DeploymentConfig, replicas: int):
        """Deploy canary containers"""
        
        for i in range(replicas):
            container_name = f"{config.service_name}-canary-{i}"
            
            container = self.client.containers.run(
                config.image,
                name=container_name,
                labels={
                    'service': config.service_name,
                    'environment': 'canary',
                    'replica': str(i)
                },
                detach=True,
                restart_policy={'Name': 'unless-stopped'}
            )
            
            print(f"Started canary container: {container_name}")
            
    async def wait_for_canary_health(self, config: DeploymentConfig) -> bool:
        """Wait for canary containers to be healthy"""
        
        containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': 'environment=canary'}
        )
        
        for _ in range(config.health_check_timeout):
            healthy_count = 0
            
            for container in containers:
                # Check container health
                container.reload()
                if container.status == 'running':
                    healthy_count += 1
                    
            if healthy_count == len(containers):
                return True
                
            await asyncio.sleep(1)
            
        return False
        
    async def route_canary_traffic(self, service_name: str, percentage: int):
        """Route specified percentage of traffic to canary"""
        
        print(f"Routing {percentage}% traffic to canary")
        
        # Update load balancer for canary routing
        # Implementation depends on your load balancer
        
    async def monitor_canary(self, config: DeploymentConfig) -> bool:
        """Monitor canary deployment"""
        
        print("Monitoring canary deployment")
        
        # Monitor for 10 minutes
        for _ in range(20):  # 20 * 30 seconds = 10 minutes
            error_rate = await self.get_canary_error_rate(config.service_name)
            
            if error_rate > config.rollback_threshold:
                print(f"Canary error rate too high: {error_rate}")
                return False
                
            await asyncio.sleep(30)
            
        return True
        
    async def get_canary_error_rate(self, service_name: str) -> float:
        """Get error rate for canary deployment"""
        # Mock implementation
        return 0.005  # 0.5% error rate
        
    async def promote_canary(self, config: DeploymentConfig):
        """Promote canary to full deployment"""
        
        print("Promoting canary to full deployment")
        
        # Scale up canary to full replicas
        # Scale down production
        # Update load balancer to route all traffic to canary
        
    async def rollback_canary(self, config: DeploymentConfig):
        """Rollback canary deployment"""
        
        print("Rolling back canary deployment")
        
        containers = self.client.containers.list(
            filters={'label': f'service={config.service_name}', 'label': 'environment=canary'}
        )
        
        for container in containers:
            container.stop(timeout=10)
            container.remove()

async def main():
    # Example usage
    config = DeploymentConfig(
        service_name="web-app",
        image="myapp:v2.0",
        replicas=5,
        health_check_url="/health",
        health_check_timeout=60,
        traffic_shift_delay=30,
        rollback_threshold=0.05
    )
    
    # Blue-Green Deployment
    bg_orchestrator = BlueGreenOrchestrator()
    success = await bg_orchestrator.deploy(config)
    
    if success:
        print("Blue-green deployment successful")
    else:
        print("Blue-green deployment failed")
        
    # Canary Deployment
    canary_orchestrator = CanaryDeploymentOrchestrator()
    success = await canary_orchestrator.deploy_canary(config, canary_percentage=10)
    
    if success:
        print("Canary deployment successful")
    else:
        print("Canary deployment failed")

if __name__ == "__main__":
    asyncio.run(main())
```
