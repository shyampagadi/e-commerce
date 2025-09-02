# Docker Compose Hands-On Labs

## Table of Contents
1. [Lab Setup](#lab-setup)
2. [Basic Labs (Beginner)](#basic-labs-beginner)
3. [Intermediate Labs](#intermediate-labs)
4. [Advanced Labs](#advanced-labs)
5. [Expert Labs](#expert-labs)
6. [Lab Solutions](#lab-solutions)

## Lab Setup

### Prerequisites
- Docker Desktop or Docker Engine installed
- Docker Compose v2.0+ installed
- Text editor (VS Code recommended)
- Git for version control
- Basic command line knowledge

### Lab Environment Setup
```bash
# Create lab directory
mkdir docker-compose-labs
cd docker-compose-labs

# Create lab structure
mkdir -p {lab01,lab02,lab03,lab04,lab05,lab06,lab07,lab08,lab09,lab10,lab11,lab12}/solution

# Verify Docker Compose installation
docker compose version
```

## Basic Labs (Beginner)

### Lab 1: First Multi-Container Application
**Objective**: Create a simple web application with database

**Requirements**:
- Nginx web server serving static content
- PostgreSQL database
- Custom network
- Named volume for database persistence

**Tasks**:
1. Create `docker-compose.yml` with nginx and postgres services
2. Configure nginx to serve static HTML from `./html` directory
3. Set up postgres with environment variables
4. Create custom network for service communication
5. Add named volume for postgres data persistence

**Expected Output**:
- Web server accessible on http://localhost:8080
- Database accessible internally
- Data persists after container restart

**Files to Create**:
```
lab01/
├── docker-compose.yml
├── html/
│   └── index.html
└── .env
```

---

### Lab 2: Environment Configuration
**Objective**: Master environment variables and configuration files

**Requirements**:
- Node.js application with configurable settings
- Redis cache
- Environment-specific configurations
- Secret management

**Tasks**:
1. Create Node.js app that reads environment variables
2. Configure Redis connection via environment variables
3. Create `.env` file with default values
4. Implement environment variable substitution
5. Add health checks for both services

**Expected Output**:
- Application displays environment configuration
- Redis connection status visible
- Health checks passing

---

### Lab 3: Service Dependencies
**Objective**: Implement proper service startup order

**Requirements**:
- Web application depending on database
- Database initialization scripts
- Health check-based dependencies
- Graceful failure handling

**Tasks**:
1. Create web app that connects to database
2. Implement database health checks
3. Configure `depends_on` with conditions
4. Add database initialization scripts
5. Test startup order and failure scenarios

**Expected Output**:
- Services start in correct order
- Application waits for database readiness
- Proper error handling for failed dependencies

---

### Lab 4: Volume Management
**Objective**: Implement comprehensive data persistence

**Requirements**:
- Multiple volume types (named, bind, tmpfs)
- Data sharing between services
- Backup and restore procedures
- Volume performance optimization

**Tasks**:
1. Create application with file upload functionality
2. Implement named volumes for persistent data
3. Use bind mounts for configuration files
4. Add tmpfs for temporary processing
5. Create backup service for data volumes

**Expected Output**:
- File uploads persist across restarts
- Configuration changes reflected immediately
- Backup service creates data snapshots

## Intermediate Labs

### Lab 5: Multi-Tier Architecture
**Objective**: Build a complete 3-tier application

**Requirements**:
- Frontend (React/Angular)
- Backend API (Node.js/Python)
- Database (PostgreSQL)
- Reverse proxy (Nginx)
- Caching layer (Redis)

**Tasks**:
1. Create frontend application build process
2. Implement REST API backend
3. Configure database with proper schema
4. Set up Nginx as reverse proxy
5. Add Redis for session storage and caching

**Expected Output**:
- Complete web application with API
- Proper tier separation and communication
- Caching improves performance

---

### Lab 6: Microservices Architecture
**Objective**: Implement microservices with service discovery

**Requirements**:
- User service (authentication)
- Product service (catalog)
- Order service (transactions)
- API Gateway (routing)
- Service mesh communication

**Tasks**:
1. Create independent microservices
2. Implement service-to-service communication
3. Configure API gateway routing
4. Add service discovery mechanism
5. Implement distributed logging

**Expected Output**:
- Services communicate via API calls
- Gateway routes requests correctly
- Centralized logging from all services

---

### Lab 7: Load Balancing and Scaling
**Objective**: Implement horizontal scaling with load balancing

**Requirements**:
- Multiple application instances
- Load balancer configuration
- Health check integration
- Auto-scaling simulation

**Tasks**:
1. Configure multiple app instances
2. Set up Nginx load balancer
3. Implement health checks
4. Test load distribution
5. Simulate scaling up/down

**Expected Output**:
- Traffic distributed across instances
- Failed instances automatically removed
- Scaling commands work correctly

---

### Lab 8: Security Implementation
**Objective**: Secure multi-container application

**Requirements**:
- Non-root containers
- Network segmentation
- Secrets management
- Security scanning

**Tasks**:
1. Configure containers to run as non-root
2. Implement network isolation
3. Use Docker secrets for sensitive data
4. Add security scanning to workflow
5. Implement TLS/SSL encryption

**Expected Output**:
- All containers run securely
- Networks properly segmented
- Secrets handled securely
- Security scans pass

## Advanced Labs

### Lab 9: Production Deployment
**Objective**: Deploy production-ready application

**Requirements**:
- Production configuration
- Resource limits and monitoring
- High availability setup
- Backup and recovery

**Tasks**:
1. Create production compose configuration
2. Implement resource limits and reservations
3. Set up monitoring and alerting
4. Configure automated backups
5. Test disaster recovery procedures

**Expected Output**:
- Production-grade deployment
- Comprehensive monitoring
- Automated backup system
- Tested recovery procedures

---

### Lab 10: CI/CD Integration
**Objective**: Integrate with CI/CD pipeline

**Requirements**:
- GitLab CI/CD pipeline
- Automated testing
- Security scanning
- Multi-environment deployment

**Tasks**:
1. Create GitLab CI/CD configuration
2. Implement automated testing stages
3. Add security scanning steps
4. Configure multi-environment deployment
5. Implement rollback procedures

**Expected Output**:
- Automated deployment pipeline
- All tests and scans passing
- Environment-specific deployments
- Working rollback mechanism

---

### Lab 11: Monitoring and Observability
**Objective**: Implement comprehensive monitoring

**Requirements**:
- Prometheus metrics collection
- Grafana dashboards
- Log aggregation (ELK stack)
- Alerting system

**Tasks**:
1. Configure Prometheus for metrics
2. Create Grafana dashboards
3. Set up ELK stack for logs
4. Implement alerting rules
5. Create custom application metrics

**Expected Output**:
- Real-time metrics and dashboards
- Centralized log analysis
- Automated alerting system
- Custom business metrics

---

### Lab 12: Advanced Networking
**Objective**: Implement complex network topologies

**Requirements**:
- Multiple custom networks
- Network policies
- Service mesh integration
- External service integration

**Tasks**:
1. Design multi-tier network architecture
2. Implement network policies
3. Configure service mesh (Istio/Linkerd)
4. Integrate external services
5. Test network security and performance

**Expected Output**:
- Complex network topology working
- Network policies enforced
- Service mesh operational
- External integrations functional

## Expert Labs

### Lab 13: Database Clustering
**Objective**: Implement database high availability

**Requirements**:
- PostgreSQL primary-replica setup
- Automatic failover
- Load balancing for reads
- Backup and point-in-time recovery

**Tasks**:
1. Configure PostgreSQL streaming replication
2. Implement automatic failover mechanism
3. Set up read load balancing
4. Configure continuous backup
5. Test failover and recovery scenarios

**Expected Output**:
- HA database cluster operational
- Automatic failover working
- Read queries load balanced
- Backup and recovery tested

---

### Lab 14: Multi-Cloud Deployment
**Objective**: Deploy across multiple cloud providers

**Requirements**:
- AWS and Azure deployment
- Cross-cloud networking
- Data synchronization
- Disaster recovery

**Tasks**:
1. Deploy application on AWS
2. Deploy replica on Azure
3. Configure cross-cloud networking
4. Implement data synchronization
5. Test cross-cloud failover

**Expected Output**:
- Multi-cloud deployment active
- Cross-cloud communication working
- Data synchronized between clouds
- Failover mechanism tested

---

### Lab 15: Performance Optimization
**Objective**: Optimize application performance

**Requirements**:
- Performance profiling
- Resource optimization
- Caching strategies
- Load testing

**Tasks**:
1. Profile application performance
2. Optimize resource allocation
3. Implement multi-level caching
4. Conduct load testing
5. Tune for maximum throughput

**Expected Output**:
- Performance bottlenecks identified
- Resources optimally allocated
- Caching improving performance
- Load test targets met

## Lab Solutions

### Lab 1 Solution: First Multi-Container Application

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    networks:
      - app-network
    depends_on:
      - database

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
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 30s
      timeout: 5s
      retries: 5

networks:
  app-network:
    driver: bridge

volumes:
  postgres_data:
```

**.env**:
```bash
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=secret123
```

**html/index.html**:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Lab 1 - Multi-Container App</title>
</head>
<body>
    <h1>Welcome to Docker Compose Lab 1!</h1>
    <p>This is served by Nginx with PostgreSQL backend.</p>
</body>
</html>
```

### Lab 2 Solution: Environment Configuration

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "${APP_PORT:-3000}:3000"
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - REDIS_URL=redis://redis:6379
      - APP_NAME=${APP_NAME:-MyApp}
    networks:
      - app-network
    depends_on:
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:alpine
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 3s
      retries: 3

networks:
  app-network:
    driver: bridge
```

**Dockerfile**:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**app.js**:
```javascript
const express = require('express');
const redis = require('redis');

const app = express();
const client = redis.createClient({ url: process.env.REDIS_URL });

app.get('/', (req, res) => {
  res.json({
    app: process.env.APP_NAME,
    environment: process.env.NODE_ENV,
    redis: process.env.REDIS_URL
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Lab Validation Commands

```bash
# Lab 1 Validation
docker compose up -d
curl http://localhost:8080
docker compose exec database psql -U postgres -d myapp -c "SELECT version();"

# Lab 2 Validation
docker compose up -d
curl http://localhost:3000
curl http://localhost:3000/health

# General validation commands
docker compose ps
docker compose logs
docker compose exec <service> <command>
```

### Lab Assessment Criteria

**Each lab is evaluated on**:
- **Functionality** (40%): Does it work as specified?
- **Configuration** (25%): Proper Docker Compose syntax and structure
- **Best Practices** (20%): Security, performance, maintainability
- **Documentation** (15%): Clear README and comments

**Scoring**:
- **Excellent** (90-100%): All requirements met, best practices followed
- **Good** (80-89%): Requirements met, minor issues
- **Satisfactory** (70-79%): Basic requirements met
- **Needs Improvement** (<70%): Major issues or missing requirements

This comprehensive lab series provides hands-on experience with Docker Compose from basic concepts to advanced production deployments.
