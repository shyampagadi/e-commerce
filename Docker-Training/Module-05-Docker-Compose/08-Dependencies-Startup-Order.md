# Dependencies & Startup Order - E-Commerce Service Orchestration

## 📋 Learning Objectives
- **Master** service dependency management and startup orchestration
- **Understand** health checks and readiness probes for reliable startup
- **Apply** graceful startup and shutdown procedures to e-commerce services
- **Build** resilient failure recovery and restart strategies

---

## 🤔 The Startup Order Challenge

### **The Problem: Race Conditions**
```yaml
# ❌ Problematic: Services start simultaneously
services:
  backend:
    build: ./backend
    # Tries to connect to database immediately
    # Fails if database isn't ready yet
  
  database:
    image: postgres:13
    # Takes time to initialize
    # Backend crashes waiting for connection
```

### **The Solution: Dependency Management**
```yaml
# ✅ Better: Basic dependency order
services:
  backend:
    build: ./backend
    depends_on:
      - database  # Start database first
  
  database:
    image: postgres:13
    # Starts before backend
```

### **The Complete Solution: Health-Based Dependencies**
```yaml
# ✅ Best: Wait for service health
services:
  backend:
    build: ./backend
    depends_on:
      database:
        condition: service_healthy  # Wait for healthy database
  
  database:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## 🏗️ E-Commerce Service Dependency Architecture

### **E-Commerce Service Dependency Graph**
```
Startup Order (Bottom to Top):
├── Infrastructure Layer
│   ├── database (PostgreSQL)
│   ├── redis (Cache)
│   ├── rabbitmq (Message Queue)
│   └── elasticsearch (Search)
├── Core Services Layer
│   ├── user-service (depends on: database, redis)
│   ├── product-service (depends on: database, elasticsearch)
│   ├── order-service (depends on: database, redis, rabbitmq)
│   └── payment-service (depends on: database, rabbitmq)
├── Application Layer
│   ├── backend (depends on: all core services)
│   └── worker (depends on: database, redis, rabbitmq)
├── Presentation Layer
│   └── frontend (depends on: backend)
└── Proxy Layer
    └── nginx (depends on: frontend, backend)
```

### **Complete E-Commerce Dependency Configuration**

```yaml
version: '3.8'

services:
  # Infrastructure Layer - No dependencies
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U admin -d ecommerce"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    restart: unless-stopped

  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    restart: unless-stopped

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=10s || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    restart: unless-stopped

  # Core Services Layer - Depend on infrastructure
  user-service:
    build: ./services/user-service
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  product-service:
    build: ./services/product-service
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      ELASTICSEARCH_URL: http://elasticsearch:9200
    depends_on:
      database:
        condition: service_healthy
      elasticsearch:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3002/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  order-service:
    build: ./services/order-service
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      RABBITMQ_URL: amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5672/
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3003/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  payment-service:
    build: ./services/payment-service
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      RABBITMQ_URL: amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5672/
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3004/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  # Application Layer - Depend on core services
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      USER_SERVICE_URL: http://user-service:3001
      PRODUCT_SERVICE_URL: http://product-service:3002
      ORDER_SERVICE_URL: http://order-service:3003
      PAYMENT_SERVICE_URL: http://payment-service:3004
    depends_on:
      user-service:
        condition: service_healthy
      product-service:
        condition: service_healthy
      order-service:
        condition: service_healthy
      payment-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped

  worker:
    build: ./worker
    environment:
      DATABASE_URL: postgresql://admin:${DB_PASSWORD}@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      RABBITMQ_URL: amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5672/
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3005/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  # Presentation Layer - Depend on application layer
  frontend:
    build: ./frontend
    environment:
      REACT_APP_API_URL: http://backend:8000
    depends_on:
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    restart: unless-stopped

  # Proxy Layer - Depend on presentation layer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      frontend:
        condition: service_healthy
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
  elasticsearch_data:
```

---

## 🔧 Advanced Dependency Management

### **1. Custom Health Check Scripts**

#### **Database Health Check with Migration Status**
```bash
#!/bin/bash
# scripts/db-health-check.sh

# Check if PostgreSQL is ready
pg_isready -h database -U admin -d ecommerce

if [ $? -ne 0 ]; then
  echo "Database not ready"
  exit 1
fi

# Check if migrations are complete
MIGRATION_COUNT=$(psql -h database -U admin -d ecommerce -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'migrations';" 2>/dev/null | xargs)

if [ "$MIGRATION_COUNT" = "0" ]; then
  echo "Migrations table not found - database not initialized"
  exit 1
fi

PENDING_MIGRATIONS=$(psql -h database -U admin -d ecommerce -t -c "SELECT COUNT(*) FROM migrations WHERE executed_at IS NULL;" 2>/dev/null | xargs)

if [ "$PENDING_MIGRATIONS" != "0" ]; then
  echo "Pending migrations found"
  exit 1
fi

echo "Database healthy and migrations complete"
exit 0
```

#### **Service Health Check with Dependency Verification**
```javascript
// backend/health-check.js
const http = require('http');
const { Pool } = require('pg');
const redis = require('redis');

async function checkDatabase() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  try {
    const result = await pool.query('SELECT 1');
    return result.rows.length === 1;
  } catch (error) {
    return false;
  } finally {
    await pool.end();
  }
}

async function checkRedis() {
  const client = redis.createClient({ url: process.env.REDIS_URL });
  try {
    await client.connect();
    const result = await client.ping();
    return result === 'PONG';
  } catch (error) {
    return false;
  } finally {
    await client.quit();
  }
}

async function checkMicroservices() {
  const services = [
    'http://user-service:3001/health',
    'http://product-service:3002/health',
    'http://order-service:3003/health',
    'http://payment-service:3004/health'
  ];

  const checks = services.map(url => 
    new Promise((resolve) => {
      const req = http.get(url, (res) => {
        resolve(res.statusCode === 200);
      });
      req.on('error', () => resolve(false));
      req.setTimeout(5000, () => {
        req.destroy();
        resolve(false);
      });
    })
  );

  const results = await Promise.all(checks);
  return results.every(result => result === true);
}

async function healthCheck() {
  try {
    const [dbHealthy, redisHealthy, servicesHealthy] = await Promise.all([
      checkDatabase(),
      checkRedis(),
      checkMicroservices()
    ]);

    if (dbHealthy && redisHealthy && servicesHealthy) {
      console.log('All dependencies healthy');
      process.exit(0);
    } else {
      console.log('Some dependencies unhealthy:', {
        database: dbHealthy,
        redis: redisHealthy,
        microservices: servicesHealthy
      });
      process.exit(1);
    }
  } catch (error) {
    console.error('Health check failed:', error.message);
    process.exit(1);
  }
}

healthCheck();
```

### **2. Graceful Startup and Shutdown**

#### **Application Startup Script**
```javascript
// backend/startup.js
const express = require('express');
const { Pool } = require('pg');

class GracefulStartup {
  constructor() {
    this.app = express();
    this.server = null;
    this.isShuttingDown = false;
  }

  async waitForDependencies() {
    console.log('Waiting for dependencies...');
    
    // Wait for database
    await this.waitForDatabase();
    
    // Wait for Redis
    await this.waitForRedis();
    
    // Wait for microservices
    await this.waitForMicroservices();
    
    console.log('All dependencies ready');
  }

  async waitForDatabase(maxRetries = 30) {
    const pool = new Pool({ connectionString: process.env.DATABASE_URL });
    
    for (let i = 0; i < maxRetries; i++) {
      try {
        await pool.query('SELECT 1');
        console.log('Database connection established');
        await pool.end();
        return;
      } catch (error) {
        console.log(`Database not ready, attempt ${i + 1}/${maxRetries}`);
        await this.sleep(2000);
      }
    }
    
    throw new Error('Database connection timeout');
  }

  async waitForMicroservices() {
    const services = [
      'http://user-service:3001/health',
      'http://product-service:3002/health'
    ];

    for (const serviceUrl of services) {
      await this.waitForService(serviceUrl);
    }
  }

  async waitForService(url, maxRetries = 30) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        const response = await fetch(url);
        if (response.ok) {
          console.log(`Service ${url} is ready`);
          return;
        }
      } catch (error) {
        console.log(`Service ${url} not ready, attempt ${i + 1}/${maxRetries}`);
      }
      await this.sleep(2000);
    }
    
    throw new Error(`Service ${url} connection timeout`);
  }

  async start() {
    try {
      await this.waitForDependencies();
      
      // Setup routes
      this.setupRoutes();
      
      // Start server
      this.server = this.app.listen(process.env.PORT || 8000, () => {
        console.log(`Server started on port ${process.env.PORT || 8000}`);
      });

      // Setup graceful shutdown
      this.setupGracefulShutdown();
      
    } catch (error) {
      console.error('Startup failed:', error.message);
      process.exit(1);
    }
  }

  setupGracefulShutdown() {
    const shutdown = async (signal) => {
      if (this.isShuttingDown) return;
      
      console.log(`Received ${signal}, starting graceful shutdown...`);
      this.isShuttingDown = true;

      // Stop accepting new connections
      this.server.close(async () => {
        console.log('HTTP server closed');
        
        // Close database connections, cleanup resources
        // ... cleanup code ...
        
        console.log('Graceful shutdown complete');
        process.exit(0);
      });

      // Force shutdown after 30 seconds
      setTimeout(() => {
        console.log('Force shutdown');
        process.exit(1);
      }, 30000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

const startup = new GracefulStartup();
startup.start();
```

### **3. Failure Recovery Strategies**

#### **Restart Policies**
```yaml
services:
  # Critical services - always restart
  database:
    image: postgres:13
    restart: unless-stopped
    
  # Application services - restart on failure
  backend:
    build: ./backend
    restart: on-failure:3  # Retry 3 times
    
  # Worker services - restart unless stopped
  worker:
    build: ./worker
    restart: unless-stopped
    
  # Temporary services - don't restart
  migration:
    build: ./migration
    restart: "no"
```

#### **Circuit Breaker Pattern**
```javascript
// backend/utils/circuit-breaker.js
class CircuitBreaker {
  constructor(service, options = {}) {
    this.service = service;
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failureCount = 0;
    this.nextAttempt = Date.now();
  }

  async call(...args) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await this.service(...args);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.resetTimeout;
    }
  }
}

module.exports = CircuitBreaker;
```

---

## 🧪 Hands-On Practice: Dependency Management

### **Exercise 1: Test Startup Order**

```bash
# Test startup without dependencies
docker-compose up backend
# Should fail - dependencies not available

# Test with proper dependency order
docker-compose up -d
# Should start in correct order

# Monitor startup sequence
docker-compose logs -f --tail=0
```

### **Exercise 2: Simulate Dependency Failures**

```bash
# Stop database while services are running
docker-compose stop database

# Watch services handle the failure
docker-compose logs backend
docker-compose logs user-service

# Restart database and watch recovery
docker-compose start database
```

### **Exercise 3: Health Check Validation**

```bash
# Check individual service health
docker-compose exec database pg_isready -U admin -d ecommerce
docker-compose exec redis redis-cli ping
docker-compose exec backend curl -f http://localhost:8000/health

# Check dependency chain
docker-compose exec backend node health-check.js
```

---

## ✅ Knowledge Check: Dependency Mastery

### **Conceptual Understanding**
- [ ] Understands service dependency graphs and startup order
- [ ] Knows health check strategies and implementation
- [ ] Comprehends graceful startup and shutdown procedures
- [ ] Understands failure recovery and restart strategies
- [ ] Knows circuit breaker and resilience patterns

### **Practical Skills**
- [ ] Can design and implement service dependency chains
- [ ] Knows how to create effective health checks
- [ ] Can implement graceful startup and shutdown
- [ ] Understands how to handle dependency failures
- [ ] Can troubleshoot startup and dependency issues

### **E-Commerce Application**
- [ ] Has implemented complete dependency management
- [ ] Created comprehensive health checks for all services
- [ ] Set up graceful startup and shutdown procedures
- [ ] Implemented failure recovery strategies
- [ ] Tested dependency failure scenarios

---

## 🚀 Next Steps: Production Deployment

### **What You've Mastered**
- ✅ **Service dependency management** and startup orchestration
- ✅ **Health checks** and readiness probes for reliable startup
- ✅ **Graceful startup and shutdown** procedures
- ✅ **Failure recovery** and restart strategies
- ✅ **Resilience patterns** for production reliability

### **Coming Next: Production Deployment**
In **09-Production-Deployment.md**, you'll learn:
- **Production-ready configurations** and optimizations
- **Security hardening** for production environments
- **Performance tuning** and resource optimization
- **Deployment strategies** and rollback procedures

**Continue when you have successfully implemented comprehensive dependency management and tested failure scenarios for your e-commerce platform.**
