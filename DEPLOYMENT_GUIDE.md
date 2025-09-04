# 🚀 Complete E-Commerce Application Deployment Guide
## From Docker to Production with GitSecOps CI/CD

### 📋 Table of Contents
1. [Prerequisites & Setup](#prerequisites--setup)
2. [Docker Deployment (3-Tier Architecture)](#docker-deployment-3-tier-architecture)
3. [GitHub Actions CI Setup](#github-actions-ci-setup)
4. [GitLab CD Setup](#gitlab-cd-setup)
5. [Production Deployment](#production-deployment)
6. [Monitoring & Troubleshooting](#monitoring--troubleshooting)

---

## 🎯 What We're Building

**3-Tier Architecture:**
- **Tier 1**: Frontend (React) - User Interface
- **Tier 2**: Backend (FastAPI) - Business Logic & API
- **Tier 3**: Database (PostgreSQL) - Data Storage

**CI/CD Pipeline:**
- **GitHub Actions**: Continuous Integration (Build, Test, Security Scan)
- **GitLab**: Continuous Deployment (Deploy to environments)

---

## 📚 Prerequisites & Setup

### **What You Need Before Starting**

#### **1. Software Installation**
```bash
# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop/

# Install Git
# Download from: https://git-scm.com/downloads

# Install Node.js (v18+)
# Download from: https://nodejs.org/

# Install Python (3.11+)
# Download from: https://www.python.org/downloads/
```

#### **2. Account Setup**
- **GitHub Account**: For source code and CI
- **GitLab Account**: For CD pipeline
- **Docker Hub Account**: For container registry

#### **3. Verify Installation**
```bash
# Check versions
docker --version          # Should show Docker version
git --version            # Should show Git version
node --version           # Should show Node.js version
python --version         # Should show Python version
```

---

## 🐳 Docker Deployment (3-Tier Architecture)

### **Step 1: Project Structure Setup**

First, let's organize your project:

```
e-commerce/
├── frontend/           # React application
├── backend/           # FastAPI application
├── database/          # Database scripts
├── docker/           # Docker configurations
├── .github/          # GitHub Actions
├── .gitlab/          # GitLab CI/CD
└── docker-compose.yml # Multi-container setup
```

### **Step 2: Create Docker Files**

#### **A. Frontend Dockerfile**
Create `frontend/Dockerfile`:

```dockerfile
# Multi-stage build for React frontend
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production stage with Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### **B. Backend Dockerfile**
Create `backend/Dockerfile`:

```dockerfile
FROM python:3.11-slim

# Security: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### **C. Database Setup**
We'll use the official PostgreSQL image with custom initialization.

### **Step 3: Create Docker Compose Configuration**

Create `docker-compose.yml` in your project root:

```yaml
version: '3.8'

services:
  # Database Tier
  database:
    image: postgres:15-alpine
    container_name: ecommerce-db
    environment:
      POSTGRES_DB: ecommerce_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend Tier
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ecommerce-backend
    environment:
      DATABASE_URL: postgresql://postgres:admin@database:5432/ecommerce_db
      SECRET_KEY: your-secret-key-here
    ports:
      - "8000:8000"
    depends_on:
      database:
        condition: service_healthy
    networks:
      - ecommerce-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Frontend Tier
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ecommerce-frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - ecommerce-network

volumes:
  postgres_data:

networks:
  ecommerce-network:
    driver: bridge
```

### **Step 4: Create Nginx Configuration**

Create `frontend/nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Handle React Router
        location / {
            try_files $uri $uri/ /index.html;
        }

        # API proxy to backend
        location /api/ {
            proxy_pass http://backend:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
### **Step 5: Deploy with Docker Compose**

#### **A. First-Time Setup**
```bash
# 1. Navigate to your project directory
cd /path/to/your/e-commerce

# 2. Create environment file
cp .env.example .env
# Edit .env with your actual values

# 3. Build and start all services
docker-compose up --build -d

# 4. Check if all services are running
docker-compose ps

# 5. View logs if needed
docker-compose logs -f
```

#### **B. Verify Deployment**
```bash
# Check each tier
curl http://localhost:8000/health    # Backend health
curl http://localhost:3000           # Frontend
docker exec -it ecommerce-db psql -U postgres -d ecommerce_db -c "\dt"  # Database tables
```

#### **C. Common Docker Commands**
```bash
# Stop all services
docker-compose down

# Rebuild specific service
docker-compose up --build backend

# View service logs
docker-compose logs backend

# Execute commands in container
docker exec -it ecommerce-backend bash

# Clean up everything
docker-compose down -v --rmi all
```

---

## 🔄 GitHub Actions CI Setup

### **Step 1: Create GitHub Actions Workflow**

Create `.github/workflows/ci.yml`:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Job 1: Code Quality & Security
  code-quality:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install frontend dependencies
        run: |
          cd frontend
          npm ci

      - name: Install backend dependencies
        run: |
          cd backend
          pip install -r requirements.txt

      - name: Lint frontend
        run: |
          cd frontend
          npm run lint

      - name: Lint backend
        run: |
          cd backend
          pylint app/ --disable=all --enable=E,F

      - name: Security scan - Frontend
        run: |
          cd frontend
          npm audit --audit-level moderate

      - name: Security scan - Backend
        run: |
          cd backend
          pip install safety
          safety check

  # Job 2: Testing
  test:
    runs-on: ubuntu-latest
    needs: code-quality
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: admin
          POSTGRES_USER: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          cd frontend && npm ci
          cd ../backend && pip install -r requirements.txt

      - name: Run backend tests
        env:
          DATABASE_URL: postgresql://postgres:admin@localhost:5432/ecommerce_test
        run: |
          cd backend
          pytest tests/ -v --cov=app

      - name: Run frontend tests
        run: |
          cd frontend
          npm test -- --coverage --watchAll=false

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage.xml,./frontend/coverage/lcov.info

  # Job 3: Build & Push Images
  build:
    runs-on: ubuntu-latest
    needs: test
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta-backend
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-backend

      - name: Build and push backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ steps.meta-backend.outputs.tags }}
          labels: ${{ steps.meta-backend.outputs.labels }}

      - name: Extract metadata
        id: meta-frontend
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-frontend

      - name: Build and push frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ steps.meta-frontend.outputs.tags }}
          labels: ${{ steps.meta-frontend.outputs.labels }}

  # Job 4: Security Scanning
  security:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-backend:main
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
### **Step 2: Setup GitHub Secrets**

Go to your GitHub repository → Settings → Secrets and variables → Actions:

```bash
# Required secrets:
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password
DATABASE_URL=postgresql://user:pass@host:5432/db
SECRET_KEY=your-super-secret-key
```

---

## 🦊 GitLab CD Setup

### **Step 1: Create GitLab CI/CD Configuration**

Create `.gitlab-ci.yml`:

```yaml
stages:
  - deploy-staging
  - security-test
  - deploy-production
  - monitor

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  KUBE_NAMESPACE: ecommerce

# Deploy to Staging Environment
deploy-staging:
  stage: deploy-staging
  image: bitnami/kubectl:latest
  environment:
    name: staging
    url: https://staging.yourdomain.com
  script:
    - echo "Deploying to staging environment..."
    - kubectl config use-context staging-cluster
    - envsubst < k8s/staging/deployment.yaml | kubectl apply -f -
    - kubectl rollout status deployment/ecommerce-backend -n $KUBE_NAMESPACE
    - kubectl rollout status deployment/ecommerce-frontend -n $KUBE_NAMESPACE
  only:
    - main
  when: manual

# Security Testing in Staging
security-test:
  stage: security-test
  image: owasp/zap2docker-stable
  script:
    - echo "Running DAST security tests..."
    - zap-baseline.py -t https://staging.yourdomain.com -r security-report.html
  artifacts:
    reports:
      junit: security-report.xml
    paths:
      - security-report.html
    expire_in: 1 week
  dependencies:
    - deploy-staging
  only:
    - main

# Deploy to Production
deploy-production:
  stage: deploy-production
  image: bitnami/kubectl:latest
  environment:
    name: production
    url: https://yourdomain.com
  script:
    - echo "Deploying to production environment..."
    - kubectl config use-context production-cluster
    - envsubst < k8s/production/deployment.yaml | kubectl apply -f -
    - kubectl rollout status deployment/ecommerce-backend -n $KUBE_NAMESPACE
    - kubectl rollout status deployment/ecommerce-frontend -n $KUBE_NAMESPACE
    - echo "Production deployment completed successfully!"
  only:
    - main
  when: manual
  dependencies:
    - security-test

# Post-deployment Monitoring
monitor:
  stage: monitor
  image: curlimages/curl:latest
  script:
    - echo "Running post-deployment health checks..."
    - curl -f https://yourdomain.com/health || exit 1
    - curl -f https://yourdomain.com/api/v1/health || exit 1
    - echo "All health checks passed!"
  dependencies:
    - deploy-production
  only:
    - main
```

### **Step 2: Create Kubernetes Deployment Files**

#### **A. Staging Deployment**
Create `k8s/staging/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/yourusername/ecommerce-backend:main
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: ecommerce-secrets
              key: database-url
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: ecommerce-secrets
              key: secret-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-frontend
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-frontend
  template:
    metadata:
      labels:
        app: ecommerce-frontend
    spec:
      containers:
      - name: frontend
        image: ghcr.io/yourusername/ecommerce-frontend:main
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"

---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend-service
  namespace: ecommerce
spec:
  selector:
    app: ecommerce-backend
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-frontend-service
  namespace: ecommerce
spec:
  selector:
    app: ecommerce-frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - staging.yourdomain.com
    secretName: ecommerce-tls
  rules:
  - host: staging.yourdomain.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: ecommerce-backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ecommerce-frontend-service
            port:
              number: 80
```

### **Step 3: Setup GitLab Variables**

Go to GitLab → Project → Settings → CI/CD → Variables:

```bash
# Kubernetes Configuration
KUBE_CONFIG=<base64-encoded-kubeconfig>
KUBE_NAMESPACE=ecommerce

# Database Configuration
DATABASE_URL=postgresql://user:pass@host:5432/db
SECRET_KEY=your-production-secret-key

# Docker Registry
DOCKER_REGISTRY=ghcr.io
DOCKER_USERNAME=your-username
---

## 🚀 Production Deployment

### **Step 1: Environment Preparation**

#### **A. Create Production Namespace**
```bash
# Create Kubernetes namespace
kubectl create namespace ecommerce

# Create secrets
kubectl create secret generic ecommerce-secrets \
  --from-literal=database-url="postgresql://user:pass@host:5432/db" \
  --from-literal=secret-key="your-production-secret-key" \
  -n ecommerce
```

#### **B. Setup Database (Production)**
```bash
# Option 1: Managed Database (Recommended)
# Use AWS RDS, Google Cloud SQL, or Azure Database

# Option 2: Self-hosted PostgreSQL
kubectl apply -f k8s/production/postgres.yaml
```

Create `k8s/production/postgres.yaml`:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: ecommerce
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: ecommerce_db
        - name: POSTGRES_USER
          value: postgres
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 20Gi
```

### **Step 2: Production Deployment Process**

#### **A. Manual Deployment Steps**
```bash
# 1. Build and push images (done by GitHub Actions)
# 2. Update image tags in deployment files
# 3. Apply Kubernetes manifests

# Deploy to production
kubectl apply -f k8s/production/

# Verify deployment
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get ingress -n ecommerce
```

#### **B. Blue-Green Deployment Strategy**
```yaml
# k8s/production/blue-green-deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: ecommerce-backend-rollout
  namespace: ecommerce
spec:
  replicas: 5
  strategy:
    blueGreen:
      activeService: ecommerce-backend-active
      previewService: ecommerce-backend-preview
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 30
      prePromotionAnalysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: ecommerce-backend-preview
      postPromotionAnalysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: ecommerce-backend-active
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
      - name: backend
        image: ghcr.io/yourusername/ecommerce-backend:latest
        ports:
        - containerPort: 8000
```

### **Step 3: SSL/TLS Setup**

#### **A. Install Cert-Manager**
```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@domain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

---

## 📊 Monitoring & Troubleshooting

### **Step 1: Setup Monitoring Stack**

#### **A. Prometheus & Grafana**
```bash
# Install monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123
```

#### **B. Application Metrics**
Add to your FastAPI backend:
```python
# backend/app/monitoring.py
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import Response

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency')

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path
    ).inc()
    
    REQUEST_LATENCY.observe(time.time() - start_time)
    return response

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

### **Step 2: Logging Setup**

#### **A. Centralized Logging with ELK Stack**
```yaml
# k8s/monitoring/elasticsearch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
        env:
        - name: discovery.type
          value: single-node
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        ports:
        - containerPort: 9200
```

#### **B. Structured Logging in Application**
```python
# backend/app/logging_config.py
import structlog
import logging

structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()
```

### **Step 3: Health Checks & Alerts**

#### **A. Advanced Health Checks**
```python
# backend/app/health.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db

router = APIRouter()

@router.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

@router.get("/health/detailed")
async def detailed_health_check(db: Session = Depends(get_db)):
    checks = {
        "database": False,
        "redis": False,
        "external_apis": False
    }
    
    try:
        # Database check
        db.execute("SELECT 1")
        checks["database"] = True
    except Exception as e:
        logger.error("Database health check failed", error=str(e))
    
    # Add more checks...
    
    status = "healthy" if all(checks.values()) else "unhealthy"
    return {"status": status, "checks": checks}
```

#### **B. Alerting Rules**
```yaml
# k8s/monitoring/alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ecommerce-alerts
  namespace: monitoring
spec:
  groups:
  - name: ecommerce.rules
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
        description: "Error rate is above 10% for 5 minutes"
    
    - alert: HighLatency
      expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High latency detected"
        description: "95th percentile latency is above 1 second"
```

### **Step 4: Troubleshooting Guide**

#### **A. Common Issues & Solutions**

**1. Pod Not Starting**
```bash
# Check pod status
kubectl describe pod <pod-name> -n ecommerce

# Check logs
kubectl logs <pod-name> -n ecommerce

# Common fixes:
# - Check resource limits
# - Verify secrets exist
# - Check image pull policy
```

**2. Database Connection Issues**
```bash
# Test database connectivity
kubectl exec -it <backend-pod> -n ecommerce -- python -c "
import psycopg2
conn = psycopg2.connect('postgresql://user:pass@host:5432/db')
print('Database connection successful')
"
```

**3. SSL Certificate Issues**
```bash
# Check certificate status
kubectl describe certificate ecommerce-tls -n ecommerce

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

#### **B. Performance Optimization**

**1. Database Optimization**
```sql
-- Add indexes for better performance
CREATE INDEX CONCURRENTLY idx_products_category ON products(category_id);
CREATE INDEX CONCURRENTLY idx_orders_user ON orders(user_id);
CREATE INDEX CONCURRENTLY idx_products_search ON products USING gin(to_tsvector('english', name || ' ' || description));
```

**2. Application Caching**
```python
# Add Redis caching
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend

@app.on_event("startup")
async def startup():
    redis = aioredis.from_url("redis://redis:6379")
    FastAPICache.init(RedisBackend(redis), prefix="ecommerce")

@cache(expire=300)
async def get_products():
    # Cached for 5 minutes
    return products
```

**3. Frontend Optimization**
```javascript
// Code splitting and lazy loading
const ProductDetail = lazy(() => import('./pages/ProductDetail'));
const AdminDashboard = lazy(() => import('./pages/Admin/Dashboard'));

// Image optimization
const OptimizedImage = ({ src, alt, ...props }) => (
  <img
    src={src}
    alt={alt}
    loading="lazy"
    decoding="async"
    {...props}
  />
);
```

---

## 🎯 Complete Deployment Checklist

### **Pre-Deployment**
- [ ] All tests passing in CI
- [ ] Security scans completed
- [ ] Database migrations ready
- [ ] Environment variables configured
- [ ] SSL certificates configured

### **Deployment**
- [ ] Images built and pushed
- [ ] Kubernetes manifests applied
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Alerts configured

### **Post-Deployment**
- [ ] Smoke tests completed
- [ ] Performance benchmarks met
- [ ] Security validation passed
- [ ] Backup procedures tested
- [ ] Rollback plan verified

---

## 🚀 **Congratulations!**

You now have a complete production-ready deployment with:
- ✅ 3-tier Docker architecture
- ✅ GitHub Actions CI pipeline
- ✅ GitLab CD pipeline
- ✅ Kubernetes orchestration
- ✅ Monitoring & alerting
- ✅ Security scanning
- ✅ SSL/TLS encryption

Your e-commerce application is ready for production! 🎉
```
```
```
