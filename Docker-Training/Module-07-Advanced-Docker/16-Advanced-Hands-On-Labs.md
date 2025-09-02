# 🧪 Advanced Hands-On Labs

## 📋 Learning Objectives
By the end of this module, you will:
- **Apply** advanced Docker concepts through practical exercises
- **Build** complex containerized systems from scratch
- **Implement** enterprise-grade solutions for real-world scenarios
- **Demonstrate** mastery of advanced container technologies
- **Create** production-ready e-commerce container solutions

## 🎯 Lab Overview
These advanced labs challenge you to implement complex containerization scenarios that mirror real-world enterprise requirements. Each lab builds upon previous knowledge and introduces new challenges.

---

## 🚀 Lab 1: Enterprise E-Commerce Platform Deployment

### Objective
Deploy a complete, production-ready e-commerce platform with advanced features including multi-region deployment, auto-scaling, and comprehensive monitoring.

### Requirements
- Multi-service architecture (10+ services)
- Blue-green deployment strategy
- Comprehensive monitoring and alerting
- Security hardening and compliance
- Performance optimization

### Implementation

**Step 1: Infrastructure Setup**
```bash
#!/bin/bash
# lab1-setup.sh - Enterprise e-commerce platform setup

echo "🚀 Setting up Enterprise E-Commerce Platform"
echo "============================================="

# Create project structure
mkdir -p ecommerce-enterprise/{services,infrastructure,monitoring,security,scripts}
cd ecommerce-enterprise

# Generate SSL certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout infrastructure/ssl/ecommerce.key \
    -out infrastructure/ssl/ecommerce.crt \
    -subj "/C=US/ST=CA/L=SF/O=ECommerce/CN=ecommerce.local"

echo "✅ Infrastructure setup completed"
```

**Step 2: Core Services Architecture**
```yaml
# docker-compose.enterprise.yml - Complete e-commerce platform
version: '3.8'

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  database:
    driver: bridge
    internal: true

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:
  prometheus_data:
  grafana_data:

services:
  # Load Balancer & Reverse Proxy
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./infrastructure/ssl:/etc/nginx/ssl
    networks:
      - frontend
    depends_on:
      - api-gateway
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

  # API Gateway
  api-gateway:
    build: ./services/api-gateway
    environment:
      - NODE_ENV=production
      - RATE_LIMIT_WINDOW=900000
      - RATE_LIMIT_MAX=1000
    networks:
      - frontend
      - backend
    depends_on:
      - user-service
      - product-service
      - order-service

  # User Management Service
  user-service:
    build: ./services/user-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@user-db:5432/users
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=redis://redis-cache:6379
    networks:
      - backend
      - database
    depends_on:
      - user-db
      - redis-cache

  # Product Catalog Service
  product-service:
    build: ./services/product-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@product-db:5432/products
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - REDIS_URL=redis://redis-cache:6379
    networks:
      - backend
      - database
    depends_on:
      - product-db
      - elasticsearch
      - redis-cache

  # Order Processing Service
  order-service:
    build: ./services/order-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@order-db:5432/orders
      - PAYMENT_SERVICE_URL=http://payment-service:3000
      - INVENTORY_SERVICE_URL=http://inventory-service:3000
      - KAFKA_BROKERS=kafka:9092
    networks:
      - backend
      - database
    depends_on:
      - order-db
      - payment-service
      - inventory-service
      - kafka

  # Payment Processing Service
  payment-service:
    build: ./services/payment-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@payment-db:5432/payments
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - ENCRYPTION_KEY=${PAYMENT_ENCRYPTION_KEY}
    networks:
      - backend
      - database
    depends_on:
      - payment-db

  # Inventory Management Service
  inventory-service:
    build: ./services/inventory-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@inventory-db:5432/inventory
      - REDIS_URL=redis://redis-cache:6379
      - KAFKA_BROKERS=kafka:9092
    networks:
      - backend
      - database
    depends_on:
      - inventory-db
      - redis-cache
      - kafka

  # Recommendation Engine
  recommendation-service:
    build: ./services/recommendation-service
    environment:
      - PYTHON_ENV=production
      - DATABASE_URL=postgresql://postgres:password@analytics-db:5432/analytics
      - REDIS_URL=redis://redis-cache:6379
      - ML_MODEL_PATH=/models/recommendation_model.pkl
    volumes:
      - ./models:/models
    networks:
      - backend
      - database
    depends_on:
      - analytics-db
      - redis-cache

  # Search Service
  search-service:
    build: ./services/search-service
    environment:
      - NODE_ENV=production
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - REDIS_URL=redis://redis-cache:6379
    networks:
      - backend
    depends_on:
      - elasticsearch
      - redis-cache

  # Notification Service
  notification-service:
    build: ./services/notification-service
    environment:
      - NODE_ENV=production
      - KAFKA_BROKERS=kafka:9092
      - EMAIL_SERVICE_API_KEY=${EMAIL_SERVICE_API_KEY}
      - SMS_SERVICE_API_KEY=${SMS_SERVICE_API_KEY}
    networks:
      - backend
    depends_on:
      - kafka

  # Analytics Service
  analytics-service:
    build: ./services/analytics-service
    environment:
      - PYTHON_ENV=production
      - DATABASE_URL=postgresql://postgres:password@analytics-db:5432/analytics
      - KAFKA_BROKERS=kafka:9092
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    networks:
      - backend
      - database
    depends_on:
      - analytics-db
      - kafka
      - elasticsearch

  # Databases
  user-db:
    image: postgres:15
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - database

  product-db:
    image: postgres:15
    environment:
      POSTGRES_DB: products
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    networks:
      - database

  order-db:
    image: postgres:15
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    networks:
      - database

  payment-db:
    image: postgres:15
    environment:
      POSTGRES_DB: payments
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    networks:
      - database

  inventory-db:
    image: postgres:15
    environment:
      POSTGRES_DB: inventory
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    networks:
      - database

  analytics-db:
    image: postgres:15
    environment:
      POSTGRES_DB: analytics
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    networks:
      - database

  # Cache and Search
  redis-cache:
    image: redis:7-alpine
    command: redis-server --appendonly yes --maxmemory 2gb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - backend

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms2g -Xmx2g
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - backend

  # Message Queue
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    networks:
      - backend

  kafka:
    image: confluentinc/cp-kafka:latest
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    networks:
      - backend
    depends_on:
      - zookeeper

  # Monitoring Stack
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - backend

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana:/etc/grafana/provisioning
    networks:
      - backend
    depends_on:
      - prometheus
```

**Step 3: Service Implementation Example**
```javascript
// services/product-service/src/app.js - Production-ready product service
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const { Client } = require('@elastic/elasticsearch');
const prometheus = require('prom-client');

// Metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const dbQueryDuration = new prometheus.Histogram({
  name: 'db_query_duration_seconds',
  help: 'Duration of database queries in seconds',
  labelNames: ['query_type']
});

class ProductService {
  constructor() {
    this.app = express();
    this.setupMiddleware();
    this.setupConnections();
    this.setupRoutes();
    this.setupErrorHandling();
  }

  setupMiddleware() {
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(this.metricsMiddleware);
    this.app.use(this.authMiddleware);
  }

  async setupConnections() {
    // Database connection
    this.db = new Pool({
      connectionString: process.env.DATABASE_URL,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    // Redis connection
    this.redis = redis.createClient({
      url: process.env.REDIS_URL,
      retry_strategy: (options) => Math.min(options.attempt * 100, 3000)
    });
    await this.redis.connect();

    // Elasticsearch connection
    this.elasticsearch = new Client({
      node: process.env.ELASTICSEARCH_URL
    });
  }

  metricsMiddleware(req, res, next) {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = (Date.now() - start) / 1000;
      httpRequestDuration
        .labels(req.method, req.route?.path || req.path, res.statusCode)
        .observe(duration);
    });
    
    next();
  }

  authMiddleware(req, res, next) {
    // Skip auth for health checks and metrics
    if (req.path === '/health' || req.path === '/metrics') {
      return next();
    }

    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    // Verify JWT token (simplified)
    try {
      // In production, verify with proper JWT library
      req.user = { id: 'user123' }; // Mock user
      next();
    } catch (error) {
      res.status(401).json({ error: 'Invalid token' });
    }
  }

  setupRoutes() {
    // Health check
    this.app.get('/health', (req, res) => {
      res.json({ status: 'healthy', timestamp: new Date().toISOString() });
    });

    // Metrics endpoint
    this.app.get('/metrics', async (req, res) => {
      res.set('Content-Type', prometheus.register.contentType);
      res.end(await prometheus.register.metrics());
    });

    // Get products with caching and search
    this.app.get('/products', async (req, res) => {
      try {
        const { page = 1, limit = 20, category, search } = req.query;
        const cacheKey = `products:${JSON.stringify(req.query)}`;

        // Check cache first
        const cached = await this.redis.get(cacheKey);
        if (cached) {
          return res.json(JSON.parse(cached));
        }

        let products;
        
        if (search) {
          // Use Elasticsearch for search
          products = await this.searchProducts(search, page, limit);
        } else {
          // Use database for regular queries
          products = await this.getProductsFromDB(category, page, limit);
        }

        // Cache results for 5 minutes
        await this.redis.setex(cacheKey, 300, JSON.stringify(products));

        res.json(products);
      } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });

    // Get single product
    this.app.get('/products/:id', async (req, res) => {
      try {
        const { id } = req.params;
        const cacheKey = `product:${id}`;

        // Check cache
        const cached = await this.redis.get(cacheKey);
        if (cached) {
          return res.json(JSON.parse(cached));
        }

        const start = Date.now();
        const result = await this.db.query(
          'SELECT * FROM products WHERE id = $1 AND active = true',
          [id]
        );
        dbQueryDuration.labels('select').observe((Date.now() - start) / 1000);

        if (result.rows.length === 0) {
          return res.status(404).json({ error: 'Product not found' });
        }

        const product = result.rows[0];
        
        // Cache for 10 minutes
        await this.redis.setex(cacheKey, 600, JSON.stringify(product));

        res.json(product);
      } catch (error) {
        console.error('Error fetching product:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });

    // Create product
    this.app.post('/products', async (req, res) => {
      try {
        const { name, description, price, category, inventory } = req.body;

        const start = Date.now();
        const result = await this.db.query(
          `INSERT INTO products (name, description, price, category, inventory, active, created_at)
           VALUES ($1, $2, $3, $4, $5, true, NOW()) RETURNING *`,
          [name, description, price, category, inventory]
        );
        dbQueryDuration.labels('insert').observe((Date.now() - start) / 1000);

        const product = result.rows[0];

        // Index in Elasticsearch
        await this.elasticsearch.index({
          index: 'products',
          id: product.id,
          body: product
        });

        // Invalidate cache
        await this.invalidateProductCache();

        res.status(201).json(product);
      } catch (error) {
        console.error('Error creating product:', error);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  }

  async getProductsFromDB(category, page, limit) {
    const offset = (page - 1) * limit;
    let query = 'SELECT * FROM products WHERE active = true';
    const params = [];

    if (category) {
      query += ' AND category = $1';
      params.push(category);
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const start = Date.now();
    const result = await this.db.query(query, params);
    dbQueryDuration.labels('select').observe((Date.now() - start) / 1000);

    return {
      products: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: result.rowCount
      }
    };
  }

  async searchProducts(searchTerm, page, limit) {
    const from = (page - 1) * limit;

    const result = await this.elasticsearch.search({
      index: 'products',
      body: {
        query: {
          multi_match: {
            query: searchTerm,
            fields: ['name^2', 'description', 'category']
          }
        },
        from,
        size: limit,
        sort: [{ _score: { order: 'desc' } }]
      }
    });

    return {
      products: result.body.hits.hits.map(hit => hit._source),
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: result.body.hits.total.value
      }
    };
  }

  async invalidateProductCache() {
    const keys = await this.redis.keys('products:*');
    if (keys.length > 0) {
      await this.redis.del(keys);
    }
  }

  setupErrorHandling() {
    this.app.use((error, req, res, next) => {
      console.error('Unhandled error:', error);
      res.status(500).json({ error: 'Internal server error' });
    });
  }

  start(port = 3000) {
    this.app.listen(port, () => {
      console.log(`Product service listening on port ${port}`);
    });
  }
}

// Start service
const service = new ProductService();
service.start(process.env.PORT || 3000);

module.exports = ProductService;
```

**Step 4: Deployment and Testing Script**
```bash
#!/bin/bash
# lab1-deploy.sh - Deploy and test enterprise platform

echo "🚀 Deploying Enterprise E-Commerce Platform"
echo "==========================================="

# Build all services
echo "📦 Building services..."
docker-compose -f docker-compose.enterprise.yml build

# Deploy with health checks
echo "🚀 Starting deployment..."
docker-compose -f docker-compose.enterprise.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 60

# Run health checks
echo "🔍 Running health checks..."
services=("api-gateway" "user-service" "product-service" "order-service" "payment-service")

for service in "${services[@]}"; do
    echo "Checking $service..."
    if curl -f -s "http://localhost/api/$service/health" > /dev/null; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is not healthy"
        exit 1
    fi
done

# Run integration tests
echo "🧪 Running integration tests..."
npm run test:integration

# Performance test
echo "⚡ Running performance tests..."
docker run --rm \
    --network ecommerce-enterprise_frontend \
    -v $(pwd)/tests:/tests \
    loadimpact/k6:latest \
    run --vus 100 --duration 2m /tests/load-test.js

echo "✅ Enterprise platform deployment completed successfully!"
echo "🌐 Access the platform at: http://localhost"
echo "📊 Monitoring dashboard: http://localhost:3001"
echo "📈 Metrics endpoint: http://localhost:9090"
```

### Success Criteria
- [ ] All 10+ services deployed and healthy
- [ ] Load balancer routing traffic correctly
- [ ] Database connections established
- [ ] Caching layer functional
- [ ] Search functionality working
- [ ] Monitoring and metrics collecting
- [ ] Performance tests passing
- [ ] Security measures implemented

---

## 🔧 Lab 2: Custom Container Runtime Implementation

### Objective
Build a simplified container runtime that demonstrates understanding of low-level container technologies.

### Requirements
- Implement basic namespace isolation
- Add cgroup resource limits
- Support container lifecycle management
- Include security features

### Implementation
```go
// lab2-runtime/main.go - Custom container runtime
package main

import (
    "fmt"
    "os"
    "os/exec"
    "syscall"
    "path/filepath"
)

type Container struct {
    ID       string
    Image    string
    Command  []string
    RootFS   string
    Hostname string
}

func main() {
    if len(os.Args) < 2 {
        fmt.Println("Usage: custom-runtime <command>")
        os.Exit(1)
    }

    switch os.Args[1] {
    case "run":
        runContainer()
    case "child":
        runChild()
    default:
        fmt.Printf("Unknown command: %s\n", os.Args[1])
        os.Exit(1)
    }
}

func runContainer() {
    fmt.Println("🚀 Starting container...")
    
    // Create container
    container := &Container{
        ID:       "test-container",
        Image:    "alpine:latest",
        Command:  []string{"/bin/sh"},
        RootFS:   "/tmp/container-root",
        Hostname: "container-host",
    }
    
    // Setup container filesystem
    if err := setupRootFS(container); err != nil {
        panic(err)
    }
    
    // Create namespaces and run
    cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
    cmd.SysProcAttr = &syscall.SysProcAttr{
        Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | 
                   syscall.CLONE_NEWNS | syscall.CLONE_NEWNET,
    }
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    if err := cmd.Run(); err != nil {
        panic(err)
    }
}

func runChild() {
    fmt.Println("🔧 Setting up container environment...")
    
    // Set hostname
    if err := syscall.Sethostname([]byte("container-host")); err != nil {
        panic(err)
    }
    
    // Change root
    if err := syscall.Chroot("/tmp/container-root"); err != nil {
        panic(err)
    }
    
    if err := os.Chdir("/"); err != nil {
        panic(err)
    }
    
    // Mount proc
    if err := syscall.Mount("proc", "/proc", "proc", 0, ""); err != nil {
        panic(err)
    }
    
    // Execute command
    cmd := exec.Command("/bin/sh")
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    if err := cmd.Run(); err != nil {
        panic(err)
    }
}

func setupRootFS(container *Container) error {
    // Create root filesystem
    if err := os.MkdirAll(container.RootFS, 0755); err != nil {
        return err
    }
    
    // Create basic directory structure
    dirs := []string{"bin", "etc", "proc", "sys", "tmp", "var", "dev"}
    for _, dir := range dirs {
        if err := os.MkdirAll(filepath.Join(container.RootFS, dir), 0755); err != nil {
            return err
        }
    }
    
    // Copy essential binaries (simplified)
    binaries := []string{"/bin/sh", "/bin/ls", "/bin/cat", "/bin/echo"}
    for _, binary := range binaries {
        if err := copyFile(binary, filepath.Join(container.RootFS, binary)); err != nil {
            fmt.Printf("Warning: Could not copy %s: %v\n", binary, err)
        }
    }
    
    return nil
}

func copyFile(src, dst string) error {
    // Simplified file copy
    cmd := exec.Command("cp", src, dst)
    return cmd.Run()
}
```

### Success Criteria
- [ ] Container starts with isolated namespaces
- [ ] Filesystem isolation working
- [ ] Process isolation functional
- [ ] Network isolation implemented
- [ ] Basic security measures in place

---

## 🎓 Lab Completion

### Final Assessment
Complete all labs and demonstrate:

1. **Enterprise Platform Deployment**
   - All services running and healthy
   - Monitoring and alerting functional
   - Performance requirements met
   - Security measures implemented

2. **Custom Runtime Understanding**
   - Container isolation working
   - Resource management functional
   - Security features implemented
   - Code quality and documentation

### Next Steps
- Document your implementations
- Prepare for the Master-Level Assessment
- Review all advanced concepts covered
- Practice troubleshooting scenarios

---

## 📚 Additional Resources

- [Container Runtime Specification](https://github.com/opencontainers/runtime-spec)
- [Linux Namespaces Documentation](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Cgroups Documentation](https://www.kernel.org/doc/Documentation/cgroup-v1/cgroups.txt)
- [Docker Engine Architecture](https://docs.docker.com/get-started/overview/)
    switch os.Args[1] {
    case "run":
        run()
    case "child":
        child()
    default:
        panic("Invalid command")
    }
}

func run() {
    fmt.Printf("Running %v as PID %d\n", os.Args[2:], os.Getpid())
    
    cmd := exec.Command("/proc/self/exe", append([]string{"child"}, os.Args[2:]...)...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    cmd.SysProcAttr = &syscall.SysProcAttr{
        Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | syscall.CLONE_NEWNS,
    }
    
    must(cmd.Run())
}

func child() {
    fmt.Printf("Running %v as PID %d\n", os.Args[2:], os.Getpid())
    
    must(syscall.Sethostname([]byte("container")))
    must(syscall.Chroot("/alpine-minirootfs"))
    must(os.Chdir("/"))
    must(syscall.Mount("proc", "proc", "proc", 0, ""))
    
    cmd := exec.Command(os.Args[2], os.Args[3:]...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    must(cmd.Run())
    must(syscall.Unmount("proc", 0))
}

func must(err error) {
    if err != nil {
        panic(err)
    }
}
```

### Validation
```bash
# Test your runtime
go build lab1-custom-runtime.go
sudo ./lab1-custom-runtime run /bin/sh
```

## Lab 2: Implement CNI Plugin

### Objective
Create a custom CNI plugin for advanced networking.

### Requirements
- Support bridge networking
- Implement IP allocation
- Add firewall rules
- Include bandwidth limiting

### Implementation
```go
// lab2-cni-plugin.go
package main

import (
    "encoding/json"
    "fmt"
    "net"
    "os"
    
    "github.com/containernetworking/cni/pkg/skel"
    "github.com/containernetworking/cni/pkg/types"
    "github.com/containernetworking/cni/pkg/version"
    "github.com/vishvananda/netlink"
)

type NetConf struct {
    types.NetConf
    Bridge   string `json:"bridge"`
    Subnet   string `json:"subnet"`
    Gateway  string `json:"gateway"`
}

func main() {
    skel.PluginMain(cmdAdd, cmdCheck, cmdDel, version.All, "Advanced CNI Plugin")
}

func cmdAdd(args *skel.CmdArgs) error {
    conf := NetConf{}
    if err := json.Unmarshal(args.StdinData, &conf); err != nil {
        return err
    }
    
    // Create bridge if not exists
    br, err := ensureBridge(conf.Bridge)
    if err != nil {
        return err
    }
    
    // Create veth pair
    hostVeth, containerVeth, err := createVethPair(args.IfName)
    if err != nil {
        return err
    }
    
    // Attach host veth to bridge
    if err := netlink.LinkSetMaster(hostVeth, br); err != nil {
        return err
    }
    
    // Move container veth to namespace
    // Implementation details...
    
    return nil
}

func ensureBridge(name string) (netlink.Link, error) {
    br, err := netlink.LinkByName(name)
    if err != nil {
        bridge := &netlink.Bridge{LinkAttrs: netlink.LinkAttrs{Name: name}}
        if err := netlink.LinkAdd(bridge); err != nil {
            return nil, err
        }
        br = bridge
    }
    return br, netlink.LinkSetUp(br)
}

func createVethPair(name string) (netlink.Link, netlink.Link, error) {
    // Implementation for veth pair creation
    return nil, nil, nil
}

func cmdDel(args *skel.CmdArgs) error {
    // Cleanup implementation
    return nil
}

func cmdCheck(args *skel.CmdArgs) error {
    // Validation implementation
    return nil
}
```

### Validation
```bash
# Test CNI plugin
sudo CNI_COMMAND=ADD CNI_CONTAINERID=test CNI_NETNS=/var/run/netns/test \
    CNI_IFNAME=eth0 CNI_PATH=/opt/cni/bin \
    ./lab2-cni-plugin < config.json
```

## Lab 3: Security Hardening Implementation

### Objective
Implement comprehensive container security hardening.

### Requirements
- Create AppArmor profiles
- Implement seccomp filters
- Add runtime monitoring
- Include vulnerability scanning

### Implementation
```bash
#!/bin/bash
# lab3-security-hardening.sh

create_apparmor_profile() {
    local container_name=$1
    
    cat > "/etc/apparmor.d/docker-$container_name" << 'EOF'
#include <tunables/global>

profile docker-container flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  # Deny dangerous capabilities
  deny capability sys_admin,
  deny capability sys_module,
  
  # File access restrictions
  /usr/bin/** ix,
  /lib/** mr,
  /etc/passwd r,
  deny /etc/shadow r,
  
  # Network restrictions
  network inet tcp,
  network inet udp,
  deny network raw,
}
EOF
    
    apparmor_parser -r "/etc/apparmor.d/docker-$container_name"
}

create_seccomp_profile() {
    local container_name=$1
    
    cat > "/tmp/$container_name-seccomp.json" << 'EOF'
{
    "defaultAction": "SCMP_ACT_ERRNO",
    "architectures": ["SCMP_ARCH_X86_64"],
    "syscalls": [
        {
            "names": ["read", "write", "open", "close"],
            "action": "SCMP_ACT_ALLOW"
        }
    ]
}
EOF
}

setup_runtime_monitoring() {
    local container_name=$1
    
    # Install Falco rules
    cat >> /etc/falco/falco_rules.local.yaml << EOF
- rule: Suspicious Container Activity
  desc: Detect suspicious activity
  condition: container.name = "$container_name" and spawned_process
  output: Suspicious activity (user=%user.name command=%proc.cmdline)
  priority: WARNING
EOF
    
    systemctl restart falco
}

vulnerability_scan() {
    local image=$1
    
    # Run Trivy scan
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image --format json $image > scan-results.json
        
    # Parse results
    python3 << 'EOF'
import json
with open('scan-results.json') as f:
    results = json.load(f)
    
critical = sum(1 for r in results.get('Results', []) 
              for v in r.get('Vulnerabilities', []) 
              if v.get('Severity') == 'CRITICAL')
              
print(f"Critical vulnerabilities: {critical}")
if critical > 0:
    exit(1)
EOF
}

# Main hardening function
harden_container() {
    local container_name=$1
    local image=$2
    
    echo "Hardening container: $container_name"
    
    # Security scanning
    vulnerability_scan "$image"
    
    # Create security profiles
    create_apparmor_profile "$container_name"
    create_seccomp_profile "$container_name"
    
    # Setup monitoring
    setup_runtime_monitoring "$container_name"
    
    # Run container with security
    docker run -d \
        --name "$container_name" \
        --security-opt apparmor="docker-$container_name" \
        --security-opt seccomp="/tmp/$container_name-seccomp.json" \
        --read-only \
        --tmpfs /tmp \
        --cap-drop=ALL \
        --cap-add=NET_BIND_SERVICE \
        "$image"
}

# Usage
harden_container "secure-web" "nginx:alpine"
```

### Validation
```bash
# Test security hardening
./lab3-security-hardening.sh
docker exec secure-web ls /etc/shadow  # Should fail
```

## Lab 4: Performance Optimization Challenge

### Objective
Optimize container performance to achieve specific benchmarks.

### Requirements
- Container startup < 1 second
- Memory usage < 50MB
- Image size < 10MB
- CPU efficiency > 90%

### Implementation
```dockerfile
# lab4-optimized.dockerfile
FROM scratch AS final

# Copy minimal binary
COPY --from=builder /app/main /main

# Copy minimal CA certificates
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Create minimal user structure
COPY --from=alpine:latest /etc/passwd /etc/passwd

USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/main"]
```

```python
#!/usr/bin/env python3
# lab4-performance-test.py

import time
import docker
import statistics

def benchmark_container(image, iterations=10):
    client = docker.from_env()
    startup_times = []
    
    for i in range(iterations):
        start_time = time.time()
        
        container = client.containers.run(
            image,
            command="echo ready",
            detach=True,
            remove=True
        )
        
        container.wait()
        end_time = time.time()
        
        startup_time = (end_time - start_time) * 1000  # ms
        startup_times.append(startup_time)
        
    return {
        'avg_startup_time': statistics.mean(startup_times),
        'min_startup_time': min(startup_times),
        'max_startup_time': max(startup_times)
    }

def check_image_size(image):
    client = docker.from_env()
    img = client.images.get(image)
    size_mb = img.attrs['Size'] / 1024 / 1024
    return size_mb

def check_memory_usage(image):
    client = docker.from_env()
    
    container = client.containers.run(
        image,
        command="sleep 30",
        detach=True,
        remove=True
    )
    
    try:
        stats = container.stats(stream=False)
        memory_usage = stats['memory_stats']['usage'] / 1024 / 1024  # MB
        return memory_usage
    finally:
        container.stop()

# Run benchmarks
image = "lab4-optimized:latest"

print("Performance Benchmarks:")
print("=" * 40)

# Startup time
startup_stats = benchmark_container(image)
print(f"Startup time: {startup_stats['avg_startup_time']:.2f}ms")
print(f"Target: < 1000ms - {'✓ PASS' if startup_stats['avg_startup_time'] < 1000 else '✗ FAIL'}")

# Image size
image_size = check_image_size(image)
print(f"Image size: {image_size:.2f}MB")
print(f"Target: < 10MB - {'✓ PASS' if image_size < 10 else '✗ FAIL'}")

# Memory usage
memory_usage = check_memory_usage(image)
print(f"Memory usage: {memory_usage:.2f}MB")
print(f"Target: < 50MB - {'✓ PASS' if memory_usage < 50 else '✗ FAIL'}")
```

### Validation
```bash
# Build optimized image
docker build -f lab4-optimized.dockerfile -t lab4-optimized:latest .

# Run performance tests
python3 lab4-performance-test.py
```

## Lab 5: Multi-Host Orchestration

### Objective
Build a custom multi-host container orchestrator.

### Requirements
- Support multiple nodes
- Implement service discovery
- Add load balancing
- Include health monitoring

### Implementation
```python
#!/usr/bin/env python3
# lab5-orchestrator.py

import asyncio
import json
import time
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
import docker
import aiohttp

@dataclass
class Node:
    id: str
    address: str
    capacity: Dict[str, float]
    usage: Dict[str, float]
    status: str

@dataclass
class Service:
    name: str
    image: str
    replicas: int
    ports: List[int]
    health_check: str

class MultiHostOrchestrator:
    def __init__(self):
        self.nodes: Dict[str, Node] = {}
        self.services: Dict[str, Service] = {}
        self.deployments: Dict[str, List[str]] = {}
        
    async def register_node(self, node: Node):
        """Register a new node"""
        self.nodes[node.id] = node
        print(f"Registered node: {node.id}")
        
    async def deploy_service(self, service: Service) -> bool:
        """Deploy service across nodes"""
        
        print(f"Deploying service: {service.name}")
        
        # Select nodes for deployment
        selected_nodes = await self.select_nodes(service)
        
        if len(selected_nodes) < service.replicas:
            print(f"Insufficient nodes for {service.name}")
            return False
            
        # Deploy containers
        deployed_containers = []
        
        for i in range(service.replicas):
            node = selected_nodes[i % len(selected_nodes)]
            container_id = await self.deploy_container(node, service, i)
            
            if container_id:
                deployed_containers.append(container_id)
                
        self.services[service.name] = service
        self.deployments[service.name] = deployed_containers
        
        # Setup service discovery
        await self.setup_service_discovery(service, deployed_containers)
        
        return len(deployed_containers) == service.replicas
        
    async def select_nodes(self, service: Service) -> List[Node]:
        """Select optimal nodes for service"""
        
        available_nodes = []
        
        for node in self.nodes.values():
            if (node.status == 'healthy' and 
                node.capacity['cpu'] - node.usage['cpu'] > 0.1 and
                node.capacity['memory'] - node.usage['memory'] > 0.1):
                available_nodes.append(node)
                
        # Sort by available resources
        available_nodes.sort(
            key=lambda n: (n.capacity['cpu'] - n.usage['cpu']) + 
                         (n.capacity['memory'] - n.usage['memory']),
            reverse=True
        )
        
        return available_nodes
        
    async def deploy_container(self, node: Node, service: Service, replica_id: int) -> Optional[str]:
        """Deploy container to specific node"""
        
        try:
            # Connect to node's Docker daemon
            async with aiohttp.ClientSession() as session:
                deploy_request = {
                    'image': service.image,
                    'name': f"{service.name}-{replica_id}",
                    'ports': service.ports,
                    'labels': {
                        'service': service.name,
                        'replica': str(replica_id)
                    }
                }
                
                async with session.post(
                    f"http://{node.address}:2376/containers/create",
                    json=deploy_request
                ) as response:
                    if response.status == 201:
                        result = await response.json()
                        container_id = result['Id']
                        
                        # Start container
                        async with session.post(
                            f"http://{node.address}:2376/containers/{container_id}/start"
                        ) as start_response:
                            if start_response.status == 204:
                                return container_id
                                
        except Exception as e:
            print(f"Failed to deploy to node {node.id}: {e}")
            
        return None
        
    async def setup_service_discovery(self, service: Service, containers: List[str]):
        """Setup service discovery for deployed containers"""
        
        # Register service in discovery backend
        service_info = {
            'name': service.name,
            'containers': containers,
            'ports': service.ports,
            'health_check': service.health_check
        }
        
        # Store in etcd or consul (mock implementation)
        print(f"Registered service discovery for {service.name}")
        
    async def monitor_services(self):
        """Monitor service health"""
        
        while True:
            for service_name, containers in self.deployments.items():
                service = self.services[service_name]
                
                healthy_containers = 0
                
                for container_id in containers:
                    if await self.check_container_health(container_id, service):
                        healthy_containers += 1
                        
                health_ratio = healthy_containers / len(containers)
                
                if health_ratio < 0.5:  # Less than 50% healthy
                    print(f"Service {service_name} is unhealthy: {health_ratio}")
                    await self.heal_service(service_name)
                    
            await asyncio.sleep(30)
            
    async def check_container_health(self, container_id: str, service: Service) -> bool:
        """Check individual container health"""
        
        # Find node containing this container
        for node in self.nodes.values():
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(
                        f"http://{node.address}:2376/containers/{container_id}/json"
                    ) as response:
                        if response.status == 200:
                            container_info = await response.json()
                            
                            if container_info['State']['Running']:
                                # Perform health check
                                return await self.perform_health_check(
                                    node.address, service.health_check
                                )
                                
            except Exception:
                continue
                
        return False
        
    async def perform_health_check(self, node_address: str, health_check: str) -> bool:
        """Perform health check on container"""
        
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f"http://{node_address}:8080{health_check}",
                    timeout=aiohttp.ClientTimeout(total=5)
                ) as response:
                    return response.status == 200
        except:
            return False
            
    async def heal_service(self, service_name: str):
        """Heal unhealthy service"""
        
        print(f"Healing service: {service_name}")
        
        service = self.services[service_name]
        
        # Redeploy service
        await self.deploy_service(service)

# Usage example
async def main():
    orchestrator = MultiHostOrchestrator()
    
    # Register nodes
    await orchestrator.register_node(Node(
        id="node1",
        address="192.168.1.10",
        capacity={"cpu": 4.0, "memory": 8.0},
        usage={"cpu": 1.0, "memory": 2.0},
        status="healthy"
    ))
    
    await orchestrator.register_node(Node(
        id="node2", 
        address="192.168.1.11",
        capacity={"cpu": 4.0, "memory": 8.0},
        usage={"cpu": 0.5, "memory": 1.0},
        status="healthy"
    ))
    
    # Deploy service
    service = Service(
        name="web-app",
        image="nginx:alpine",
        replicas=3,
        ports=[80],
        health_check="/health"
    )
    
    success = await orchestrator.deploy_service(service)
    print(f"Deployment success: {success}")
    
    # Start monitoring
    await orchestrator.monitor_services()

if __name__ == "__main__":
    asyncio.run(main())
```

### Validation
```bash
# Test orchestrator
python3 lab5-orchestrator.py

# Verify service deployment
curl http://node1:8080/health
curl http://node2:8080/health
```

## 🏆 Completion Criteria

### Lab Assessment Rubric

| Lab | Criteria | Points | Status |
|-----|----------|--------|--------|
| Lab 1 | Custom runtime works with namespaces | 20 | ⬜ |
| Lab 2 | CNI plugin handles networking | 20 | ⬜ |
| Lab 3 | Security hardening implemented | 20 | ⬜ |
| Lab 4 | Performance targets achieved | 20 | ⬜ |
| Lab 5 | Multi-host orchestration works | 20 | ⬜ |

**Total: 100 points**

### Mastery Requirements
- Complete all 5 labs successfully
- Achieve 90+ points total
- Demonstrate understanding in code review
- Present solutions to peers

### Advanced Challenges (Bonus)
- Integrate WebAssembly runtime
- Add AI-powered scheduling
- Implement chaos engineering
- Create custom monitoring solution

**Congratulations on completing the Advanced Docker Labs!** 🎉

You now possess master-level Docker skills that put you in the top 1% of container experts worldwide.
