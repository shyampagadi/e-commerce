# 🏆 Industry Case Studies

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** real-world container implementations from industry leaders
- **Analyze** successful containerization strategies and patterns
- **Learn** from enterprise-scale deployment challenges and solutions
- **Apply** proven industry practices to e-commerce applications
- **Implement** battle-tested architectural patterns

## 🎯 Real-World Context
Learning from industry leaders provides invaluable insights into how containerization works at massive scale. This module examines real implementations from companies like Netflix, Spotify, Airbnb, and others, extracting practical lessons for e-commerce platforms.

---

## 📚 Part 1: Netflix - Microservices at Global Scale

### Netflix's Container Journey

**Scale and Challenges:**
- 200+ million subscribers globally
- 15,000+ microservices
- 1 million+ container deployments daily
- Multi-region active-active architecture

**Key Innovations:**
- Chaos Engineering for resilience testing
- Automated canary deployments
- Service mesh for inter-service communication
- Advanced monitoring and observability

### Netflix-Inspired E-Commerce Architecture

**Microservices Decomposition:**
```yaml
# docker-compose.netflix-style.yml - Netflix-inspired e-commerce architecture
version: '3.8'

services:
  # User Service (Authentication & Profiles)
  user-service:
    image: ecommerce/user-service:latest
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    environment:
      - SERVICE_NAME=user-service
      - EUREKA_SERVER=http://discovery-service:8761
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Product Catalog Service
  catalog-service:
    image: ecommerce/catalog-service:latest
    deploy:
      replicas: 8
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
    environment:
      - SERVICE_NAME=catalog-service
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - CACHE_URL=redis://cache:6379

  # Recommendation Service (Netflix's core competency)
  recommendation-service:
    image: ecommerce/recommendation-service:latest
    deploy:
      replicas: 10
      resources:
        limits:
          cpus: '4.0'
          memory: 4G
    environment:
      - SERVICE_NAME=recommendation-service
      - ML_MODEL_PATH=/models/recommendation-v2.pkl
      - KAFKA_BROKERS=kafka:9092
    volumes:
      - ml_models:/models

  # Order Processing Service
  order-service:
    image: ecommerce/order-service:latest
    deploy:
      replicas: 6
      resources:
        limits:
          cpus: '1.5'
          memory: 2G
    environment:
      - SERVICE_NAME=order-service
      - DATABASE_URL=postgresql://postgres:password@order-db:5432/orders
      - PAYMENT_SERVICE_URL=http://payment-service:8080

  # Payment Service (High Security)
  payment-service:
    image: ecommerce/payment-service:latest
    deploy:
      replicas: 4
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    environment:
      - SERVICE_NAME=payment-service
      - PCI_COMPLIANCE_MODE=true
      - ENCRYPTION_KEY_PATH=/secrets/payment-key
    secrets:
      - payment-encryption-key

  # API Gateway (Netflix Zuul-inspired)
  api-gateway:
    image: ecommerce/api-gateway:latest
    ports:
      - "80:8080"
      - "443:8443"
    deploy:
      replicas: 3
    environment:
      - GATEWAY_ROUTES_CONFIG=/config/routes.yml
    volumes:
      - ./gateway/routes.yml:/config/routes.yml

  # Service Discovery (Netflix Eureka-inspired)
  discovery-service:
    image: ecommerce/discovery-service:latest
    ports:
      - "8761:8761"
    environment:
      - EUREKA_INSTANCE_HOSTNAME=discovery-service

volumes:
  ml_models:

secrets:
  payment-encryption-key:
    external: true
```

**Netflix-Style Circuit Breaker Implementation:**
```javascript
// circuit-breaker.js - Netflix Hystrix-inspired circuit breaker
class CircuitBreaker {
    constructor(service, options = {}) {
        this.service = service;
        this.failureThreshold = options.failureThreshold || 5;
        this.resetTimeout = options.resetTimeout || 60000;
        this.monitoringPeriod = options.monitoringPeriod || 10000;
        
        this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
        this.failureCount = 0;
        this.successCount = 0;
        this.nextAttempt = Date.now();
        this.metrics = {
            requests: 0,
            successes: 0,
            failures: 0,
            timeouts: 0
        };
        
        // Start metrics collection
        this.startMetricsCollection();
    }
    
    async call(...args) {
        this.metrics.requests++;
        
        if (this.state === 'OPEN') {
            if (Date.now() < this.nextAttempt) {
                throw new Error('Circuit breaker is OPEN - service unavailable');
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
        this.metrics.successes++;
        this.failureCount = 0;
        
        if (this.state === 'HALF_OPEN') {
            this.successCount++;
            if (this.successCount >= 3) {
                this.state = 'CLOSED';
                this.successCount = 0;
            }
        }
    }
    
    onFailure() {
        this.metrics.failures++;
        this.failureCount++;
        
        if (this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
            this.nextAttempt = Date.now() + this.resetTimeout;
        }
    }
    
    startMetricsCollection() {
        setInterval(() => {
            const successRate = this.metrics.requests > 0 
                ? (this.metrics.successes / this.metrics.requests) * 100 
                : 100;
            
            console.log(`Circuit Breaker Metrics:`, {
                state: this.state,
                successRate: `${successRate.toFixed(2)}%`,
                totalRequests: this.metrics.requests,
                failures: this.metrics.failures
            });
            
            // Reset metrics for next period
            this.metrics = { requests: 0, successes: 0, failures: 0, timeouts: 0 };
        }, this.monitoringPeriod);
    }
}

module.exports = CircuitBreaker;
```

---

## 🎵 Part 2: Spotify - Event-Driven Architecture

### Spotify's Container Strategy

**Architecture Highlights:**
- Event-driven microservices
- Domain-driven design
- Autonomous teams (Squads, Tribes, Chapters)
- Continuous deployment culture

**Key Technologies:**
- Apache Kafka for event streaming
- Docker containers with Kubernetes
- Service mesh for communication
- Advanced monitoring and alerting

### Spotify-Inspired Event-Driven E-Commerce

**Event-Driven Architecture:**
```yaml
# docker-compose.spotify-style.yml - Event-driven e-commerce
version: '3.8'

services:
  # Event Streaming Platform (Kafka)
  kafka:
    image: confluentinc/cp-kafka:latest
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zookeeper

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  # User Events Service
  user-events-service:
    image: ecommerce/user-events:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - TOPICS=user.registered,user.updated,user.deleted
    depends_on:
      - kafka

  # Product Events Service
  product-events-service:
    image: ecommerce/product-events:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - TOPICS=product.created,product.updated,product.viewed
    depends_on:
      - kafka

  # Order Events Service
  order-events-service:
    image: ecommerce/order-events:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - TOPICS=order.created,order.paid,order.shipped,order.delivered
    depends_on:
      - kafka

  # Analytics Service (Event Consumer)
  analytics-service:
    image: ecommerce/analytics:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - CONSUMER_GROUP=analytics-group
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - kafka
      - elasticsearch

  # Recommendation Engine (Event Consumer)
  recommendation-engine:
    image: ecommerce/recommendation-engine:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - CONSUMER_GROUP=recommendation-group
      - ML_MODEL_UPDATE_INTERVAL=3600
    depends_on:
      - kafka

  # Search Index Service (Event Consumer)
  search-indexer:
    image: ecommerce/search-indexer:latest
    environment:
      - KAFKA_BROKERS=kafka:9092
      - CONSUMER_GROUP=search-group
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - kafka
      - elasticsearch

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms2g -Xmx2g
```

**Event-Driven Service Implementation:**
```javascript
// event-service.js - Spotify-inspired event service
const kafka = require('kafkajs');

class EventService {
    constructor(brokers, clientId) {
        this.kafka = kafka({
            clientId,
            brokers
        });
        
        this.producer = this.kafka.producer();
        this.consumers = new Map();
    }
    
    async publishEvent(topic, event) {
        try {
            await this.producer.send({
                topic,
                messages: [{
                    key: event.id || Date.now().toString(),
                    value: JSON.stringify({
                        ...event,
                        timestamp: new Date().toISOString(),
                        version: '1.0'
                    })
                }]
            });
            
            console.log(`📤 Event published to ${topic}:`, event.type);
        } catch (error) {
            console.error('Failed to publish event:', error);
            throw error;
        }
    }
    
    async subscribeToEvents(topic, groupId, handler) {
        const consumer = this.kafka.consumer({ groupId });
        
        await consumer.connect();
        await consumer.subscribe({ topic });
        
        await consumer.run({
            eachMessage: async ({ topic, partition, message }) => {
                try {
                    const event = JSON.parse(message.value.toString());
                    console.log(`📥 Event received from ${topic}:`, event.type);
                    
                    await handler(event);
                } catch (error) {
                    console.error('Error processing event:', error);
                    // Implement dead letter queue logic here
                }
            }
        });
        
        this.consumers.set(topic, consumer);
    }
    
    async disconnect() {
        await this.producer.disconnect();
        
        for (const consumer of this.consumers.values()) {
            await consumer.disconnect();
        }
    }
}

// Usage example for e-commerce events
class ECommerceEventService extends EventService {
    constructor(brokers) {
        super(brokers, 'ecommerce-service');
    }
    
    async publishUserRegistered(user) {
        await this.publishEvent('user.events', {
            type: 'USER_REGISTERED',
            id: user.id,
            data: {
                userId: user.id,
                email: user.email,
                registrationDate: user.createdAt
            }
        });
    }
    
    async publishProductViewed(userId, productId) {
        await this.publishEvent('product.events', {
            type: 'PRODUCT_VIEWED',
            data: {
                userId,
                productId,
                timestamp: new Date().toISOString()
            }
        });
    }
    
    async publishOrderCreated(order) {
        await this.publishEvent('order.events', {
            type: 'ORDER_CREATED',
            id: order.id,
            data: {
                orderId: order.id,
                userId: order.userId,
                items: order.items,
                total: order.total
            }
        });
    }
}

module.exports = { EventService, ECommerceEventService };
```

---

## 🏠 Part 3: Airbnb - Multi-Tenant Architecture

### Airbnb's Containerization Approach

**Architecture Principles:**
- Multi-tenant service architecture
- Geographic data distribution
- Advanced caching strategies
- Real-time data processing

**Key Challenges Solved:**
- Global scale with local performance
- Multi-currency and multi-language support
- Complex booking and availability logic
- High-volume search and filtering

### Airbnb-Inspired Multi-Tenant E-Commerce

**Multi-Tenant Service Design:**
```yaml
# docker-compose.airbnb-style.yml - Multi-tenant e-commerce
version: '3.8'

services:
  # Tenant Management Service
  tenant-service:
    image: ecommerce/tenant-service:latest
    environment:
      - DATABASE_URL=postgresql://postgres:password@tenant-db:5432/tenants
      - REDIS_URL=redis://cache:6379
    deploy:
      replicas: 3

  # Multi-Tenant API Gateway
  multi-tenant-gateway:
    image: ecommerce/multi-tenant-gateway:latest
    ports:
      - "80:8080"
    environment:
      - TENANT_SERVICE_URL=http://tenant-service:8080
      - RATE_LIMIT_REDIS_URL=redis://cache:6379
    deploy:
      replicas: 5

  # Product Service (Multi-Tenant)
  product-service:
    image: ecommerce/product-service:latest
    environment:
      - DATABASE_URL=postgresql://postgres:password@product-db:5432/products
      - TENANT_ISOLATION_MODE=schema
      - SEARCH_SERVICE_URL=http://search-service:8080
    deploy:
      replicas: 8

  # Search Service (Elasticsearch per tenant)
  search-service:
    image: ecommerce/search-service:latest
    environment:
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - TENANT_INDEX_PATTERN=tenant-{tenant_id}-products
    deploy:
      replicas: 4

  # Booking/Order Service
  booking-service:
    image: ecommerce/booking-service:latest
    environment:
      - DATABASE_URL=postgresql://postgres:password@booking-db:5432/bookings
      - INVENTORY_SERVICE_URL=http://inventory-service:8080
      - PAYMENT_SERVICE_URL=http://payment-service:8080
    deploy:
      replicas: 6

  # Real-time Inventory Service
  inventory-service:
    image: ecommerce/inventory-service:latest
    environment:
      - REDIS_URL=redis://inventory-cache:6379
      - DATABASE_URL=postgresql://postgres:password@inventory-db:5432/inventory
      - KAFKA_BROKERS=kafka:9092
    deploy:
      replicas: 10

  # Geographic Data Service
  geo-service:
    image: ecommerce/geo-service:latest
    environment:
      - POSTGIS_URL=postgresql://postgres:password@geo-db:5432/geodata
      - REDIS_URL=redis://geo-cache:6379
    deploy:
      replicas: 4

  # Specialized caches
  inventory-cache:
    image: redis:7-alpine
    command: redis-server --maxmemory 2gb --maxmemory-policy allkeys-lru

  geo-cache:
    image: redis:7-alpine
    command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru
```

**Multi-Tenant Service Implementation:**
```javascript
// multi-tenant-service.js - Airbnb-inspired multi-tenancy
class MultiTenantService {
    constructor(dbPool, cacheClient) {
        this.dbPool = dbPool;
        this.cache = cacheClient;
        this.tenantConfigs = new Map();
    }
    
    async getTenantConfig(tenantId) {
        // Check cache first
        let config = await this.cache.get(`tenant:${tenantId}`);
        
        if (!config) {
            // Fetch from database
            const result = await this.dbPool.query(
                'SELECT * FROM tenants WHERE id = $1',
                [tenantId]
            );
            
            if (result.rows.length === 0) {
                throw new Error(`Tenant ${tenantId} not found`);
            }
            
            config = result.rows[0];
            
            // Cache for 5 minutes
            await this.cache.setex(`tenant:${tenantId}`, 300, JSON.stringify(config));
        } else {
            config = JSON.parse(config);
        }
        
        return config;
    }
    
    async executeWithTenantContext(tenantId, operation) {
        const tenantConfig = await this.getTenantConfig(tenantId);
        
        // Set tenant-specific database schema
        const client = await this.dbPool.connect();
        
        try {
            await client.query(`SET search_path TO tenant_${tenantId}, public`);
            
            // Execute operation with tenant context
            const result = await operation(client, tenantConfig);
            
            return result;
        } finally {
            client.release();
        }
    }
    
    async getProducts(tenantId, filters = {}) {
        return this.executeWithTenantContext(tenantId, async (client, config) => {
            const { page = 1, limit = 20, category, priceRange } = filters;
            const offset = (page - 1) * limit;
            
            let query = 'SELECT * FROM products WHERE active = true';
            const params = [];
            let paramIndex = 1;
            
            if (category) {
                query += ` AND category = $${paramIndex++}`;
                params.push(category);
            }
            
            if (priceRange) {
                query += ` AND price BETWEEN $${paramIndex++} AND $${paramIndex++}`;
                params.push(priceRange.min, priceRange.max);
            }
            
            // Apply tenant-specific customizations
            if (config.features.includes('premium_search')) {
                query += ' ORDER BY popularity_score DESC, created_at DESC';
            } else {
                query += ' ORDER BY created_at DESC';
            }
            
            query += ` LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
            params.push(limit, offset);
            
            const result = await client.query(query, params);
            return result.rows;
        });
    }
    
    async createBooking(tenantId, bookingData) {
        return this.executeWithTenantContext(tenantId, async (client, config) => {
            await client.query('BEGIN');
            
            try {
                // Check inventory availability
                const inventoryCheck = await client.query(
                    'SELECT available_quantity FROM inventory WHERE product_id = $1 FOR UPDATE',
                    [bookingData.productId]
                );
                
                if (inventoryCheck.rows[0].available_quantity < bookingData.quantity) {
                    throw new Error('Insufficient inventory');
                }
                
                // Create booking
                const bookingResult = await client.query(
                    `INSERT INTO bookings (user_id, product_id, quantity, total_price, status)
                     VALUES ($1, $2, $3, $4, 'pending') RETURNING *`,
                    [bookingData.userId, bookingData.productId, bookingData.quantity, bookingData.totalPrice]
                );
                
                // Update inventory
                await client.query(
                    'UPDATE inventory SET available_quantity = available_quantity - $1 WHERE product_id = $2',
                    [bookingData.quantity, bookingData.productId]
                );
                
                await client.query('COMMIT');
                
                // Publish booking event
                await this.publishBookingEvent(tenantId, bookingResult.rows[0]);
                
                return bookingResult.rows[0];
            } catch (error) {
                await client.query('ROLLBACK');
                throw error;
            }
        });
    }
    
    async publishBookingEvent(tenantId, booking) {
        // Publish to tenant-specific topic
        const eventTopic = `tenant-${tenantId}-bookings`;
        
        await this.eventService.publish(eventTopic, {
            type: 'BOOKING_CREATED',
            tenantId,
            bookingId: booking.id,
            data: booking
        });
    }
}

module.exports = MultiTenantService;
```

---

## 🛒 Part 4: Amazon - Massive Scale E-Commerce

### Amazon's Container Innovations

**Scale Achievements:**
- Millions of products
- Global infrastructure
- Peak traffic handling (Prime Day, Black Friday)
- Advanced recommendation systems

**Key Technologies:**
- AWS container services (ECS, EKS, Fargate)
- Advanced caching strategies
- Machine learning integration
- Global content delivery

### Amazon-Inspired Scalable Architecture

**High-Scale E-Commerce Implementation:**
```bash
#!/bin/bash
# amazon-scale-deployment.sh - Amazon-inspired deployment

# Configuration for massive scale
REGIONS=("us-east-1" "us-west-2" "eu-west-1" "ap-southeast-1")
SERVICES=("product-catalog" "recommendation-engine" "order-processing" "payment-gateway")
PEAK_REPLICAS=1000
NORMAL_REPLICAS=100

deploy_global_infrastructure() {
    echo "🌍 Deploying global e-commerce infrastructure..."
    
    for region in "${REGIONS[@]}"; do
        echo "📍 Deploying to region: $region"
        
        # Deploy core services
        for service in "${SERVICES[@]}"; do
            echo "🚀 Deploying $service to $region"
            
            # Calculate regional replica count based on traffic patterns
            local replicas
            case $region in
                "us-east-1") replicas=$((NORMAL_REPLICAS * 2)) ;;  # Primary region
                "us-west-2") replicas=$((NORMAL_REPLICAS * 1.5)) ;; # Secondary US
                *) replicas=$NORMAL_REPLICAS ;;                     # International
            esac
            
            # Deploy with region-specific configuration
            kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $service
  namespace: ecommerce-$region
spec:
  replicas: $replicas
  selector:
    matchLabels:
      app: $service
      region: $region
  template:
    metadata:
      labels:
        app: $service
        region: $region
    spec:
      containers:
      - name: $service
        image: ecommerce/$service:latest
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
        env:
        - name: REGION
          value: $region
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials-$region
              key: url
EOF
        done
        
        # Deploy regional load balancer
        deploy_regional_lb $region
    done
}

deploy_regional_lb() {
    local region=$1
    
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-lb
  namespace: ecommerce-$region
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  - port: 443
    targetPort: 8443
    protocol: TCP
  selector:
    app: api-gateway
    region: $region
EOF
}

# Auto-scaling for peak events (Prime Day style)
setup_peak_autoscaling() {
    echo "📈 Setting up peak event auto-scaling..."
    
    for service in "${SERVICES[@]}"; do
        kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: $service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: $service
  minReplicas: $NORMAL_REPLICAS
  maxReplicas: $PEAK_REPLICAS
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
EOF
    done
}

# Deploy global infrastructure
deploy_global_infrastructure
setup_peak_autoscaling

echo "✅ Amazon-scale deployment completed!"
```

---

## 🎓 Module Summary

You've learned from industry leaders by studying:

**Netflix Lessons:**
- Microservices architecture at massive scale
- Circuit breaker patterns for resilience
- Chaos engineering principles
- Advanced monitoring and observability

**Spotify Insights:**
- Event-driven architecture patterns
- Domain-driven design implementation
- Autonomous team structures
- Continuous deployment culture

**Airbnb Strategies:**
- Multi-tenant architecture design
- Geographic data distribution
- Complex booking and inventory systems
- Real-time data processing

**Amazon Approaches:**
- Global scale infrastructure deployment
- Peak traffic handling strategies
- Advanced caching and CDN integration
- Machine learning-powered recommendations

**Next Steps:**
- Apply industry patterns to your e-commerce platform
- Implement proven architectural strategies
- Prepare for Module 15: Future of Containers

---

## 📚 Additional Resources

- [Netflix Technology Blog](https://netflixtechblog.com/)
- [Spotify Engineering Blog](https://engineering.atspotify.com/)
- [Airbnb Engineering Blog](https://medium.com/airbnb-engineering)
- [Amazon Architecture Center](https://aws.amazon.com/architecture/)
    metadata:
      labels:
        app: recommendation
        version: v2.1.0
    spec:
      containers:
      - name: recommendation-engine
        image: netflix/recommendation:v2.1.0
        ports:
        - containerPort: 8080
        env:
        - name: HYSTRIX_ENABLED
          value: "true"
        - name: EUREKA_CLIENT_ENABLED
          value: "true"
        - name: CHAOS_MONKEY_ENABLED
          value: "true"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Netflix's Chaos Engineering
```python
#!/usr/bin/env python3
# chaos-monkey.py - Netflix-style chaos engineering for containers

import random
import time
import asyncio
from typing import List, Dict
import docker
import logging

class ChaosMonkey:
    def __init__(self):
        self.client = docker.from_env()
        self.chaos_config = {
            'kill_probability': 0.001,  # 0.1% chance per check
            'network_delay_probability': 0.005,  # 0.5% chance
            'memory_pressure_probability': 0.002,  # 0.2% chance
            'cpu_spike_probability': 0.003,  # 0.3% chance
        }
        
    async def start_chaos_engineering(self):
        """Start chaos engineering experiments"""
        
        logging.info("Starting Chaos Monkey...")
        
        while True:
            try:
                # Get all running containers
                containers = self.client.containers.list(
                    filters={'label': 'chaos.enabled=true'}
                )
                
                for container in containers:
                    await self.apply_chaos_experiments(container)
                    
                # Wait before next chaos round
                await asyncio.sleep(60)  # Check every minute
                
            except Exception as e:
                logging.error(f"Chaos engineering error: {e}")
                await asyncio.sleep(60)
                
    async def apply_chaos_experiments(self, container):
        """Apply various chaos experiments to container"""
        
        container_name = container.name
        
        # Random container termination
        if random.random() < self.chaos_config['kill_probability']:
            await self.chaos_kill_container(container)
            
        # Network latency injection
        elif random.random() < self.chaos_config['network_delay_probability']:
            await self.chaos_network_delay(container)
            
        # Memory pressure
        elif random.random() < self.chaos_config['memory_pressure_probability']:
            await self.chaos_memory_pressure(container)
            
        # CPU spike
        elif random.random() < self.chaos_config['cpu_spike_probability']:
            await self.chaos_cpu_spike(container)
            
    async def chaos_kill_container(self, container):
        """Randomly kill container to test resilience"""
        
        logging.info(f"Chaos: Killing container {container.name}")
        
        try:
            container.kill()
            
            # Log chaos event
            self.log_chaos_event({
                'type': 'container_kill',
                'target': container.name,
                'timestamp': time.time()
            })
            
        except Exception as e:
            logging.error(f"Failed to kill container {container.name}: {e}")
            
    async def chaos_network_delay(self, container):
        """Inject network latency"""
        
        logging.info(f"Chaos: Injecting network delay in {container.name}")
        
        try:
            # Use tc (traffic control) to add latency
            container.exec_run(
                "tc qdisc add dev eth0 root netem delay 100ms 20ms",
                privileged=True
            )
            
            # Remove delay after 30 seconds
            await asyncio.sleep(30)
            container.exec_run(
                "tc qdisc del dev eth0 root",
                privileged=True
            )
            
            self.log_chaos_event({
                'type': 'network_delay',
                'target': container.name,
                'duration': 30,
                'timestamp': time.time()
            })
            
        except Exception as e:
            logging.error(f"Failed to inject network delay: {e}")
            
    async def chaos_memory_pressure(self, container):
        """Create memory pressure"""
        
        logging.info(f"Chaos: Creating memory pressure in {container.name}")
        
        try:
            # Allocate memory to create pressure
            container.exec_run(
                "stress --vm 1 --vm-bytes 256M --timeout 60s",
                detach=True
            )
            
            self.log_chaos_event({
                'type': 'memory_pressure',
                'target': container.name,
                'duration': 60,
                'timestamp': time.time()
            })
            
        except Exception as e:
            logging.error(f"Failed to create memory pressure: {e}")
            
    async def chaos_cpu_spike(self, container):
        """Create CPU spike"""
        
        logging.info(f"Chaos: Creating CPU spike in {container.name}")
        
        try:
            # Create CPU load
            container.exec_run(
                "stress --cpu 2 --timeout 30s",
                detach=True
            )
            
            self.log_chaos_event({
                'type': 'cpu_spike',
                'target': container.name,
                'duration': 30,
                'timestamp': time.time()
            })
            
        except Exception as e:
            logging.error(f"Failed to create CPU spike: {e}")
            
    def log_chaos_event(self, event: Dict):
        """Log chaos engineering events"""
        
        # In production, would send to monitoring system
        logging.info(f"Chaos Event: {event}")
```

## 🔍 Google: Container Security at Scale

### Google's Security Model
```bash
#!/bin/bash
# google-security-model.sh - Implement Google-style container security

setup_google_security_model() {
    local container_name=$1
    
    echo "Implementing Google-style security model for $container_name"
    
    # 1. Least Privilege Principle
    setup_minimal_privileges "$container_name"
    
    # 2. Defense in Depth
    setup_defense_layers "$container_name"
    
    # 3. Zero Trust Network
    setup_zero_trust_network "$container_name"
    
    # 4. Continuous Monitoring
    setup_continuous_monitoring "$container_name"
}

setup_minimal_privileges() {
    local container_name=$1
    
    echo "Setting up minimal privileges..."
    
    # Create minimal user
    docker exec "$container_name" adduser --disabled-password --gecos "" appuser
    
    # Drop all capabilities
    docker update --cap-drop=ALL "$container_name"
    
    # Add only required capabilities
    docker update --cap-add=NET_BIND_SERVICE "$container_name"
    
    # Set read-only root filesystem
    docker update --read-only "$container_name"
    
    # Create tmpfs for writable areas
    docker exec "$container_name" mount -t tmpfs tmpfs /tmp
    docker exec "$container_name" mount -t tmpfs tmpfs /var/run
}

setup_defense_layers() {
    local container_name=$1
    
    echo "Setting up defense layers..."
    
    # Layer 1: AppArmor profile
    cat > "/etc/apparmor.d/docker-$container_name" << 'EOF'
#include <tunables/global>

profile docker-container flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  # Deny dangerous capabilities
  deny capability sys_admin,
  deny capability sys_module,
  deny capability sys_rawio,
  
  # Allow only necessary file access
  /usr/bin/** ix,
  /lib/** mr,
  /etc/passwd r,
  /tmp/** rw,
  
  # Network restrictions
  network inet tcp,
  network inet udp,
  deny network raw,
}
EOF
    
    apparmor_parser -r "/etc/apparmor.d/docker-$container_name"
    
    # Layer 2: Seccomp profile
    cat > "/tmp/$container_name-seccomp.json" << 'EOF'
{
    "defaultAction": "SCMP_ACT_ERRNO",
    "architectures": ["SCMP_ARCH_X86_64"],
    "syscalls": [
        {
            "names": [
                "read", "write", "open", "close", "stat", "fstat",
                "mmap", "munmap", "brk", "rt_sigaction", "rt_sigprocmask",
                "ioctl", "access", "exit", "exit_group"
            ],
            "action": "SCMP_ACT_ALLOW"
        }
    ]
}
EOF
    
    # Layer 3: SELinux context
    if command -v semanage &> /dev/null; then
        semanage fcontext -a -t container_file_t "/var/lib/docker/containers/$container_name"
        restorecon -R "/var/lib/docker/containers/$container_name"
    fi
}

setup_zero_trust_network() {
    local container_name=$1
    
    echo "Setting up zero trust network..."
    
    # Create isolated network
    docker network create --driver bridge \
        --subnet=172.20.0.0/16 \
        --opt com.docker.network.bridge.enable_icc=false \
        "zerotrust-$container_name"
    
    # Connect container to isolated network
    docker network connect "zerotrust-$container_name" "$container_name"
    
    # Setup network policies with iptables
    iptables -A DOCKER-USER -i docker0 -j DROP
    iptables -I DOCKER-USER -i docker0 -s 172.20.0.0/16 -d 172.20.0.0/16 -j ACCEPT
    iptables -I DOCKER-USER -i docker0 -p tcp --dport 443 -j ACCEPT
    iptables -I DOCKER-USER -i docker0 -p tcp --dport 80 -j ACCEPT
}

setup_continuous_monitoring() {
    local container_name=$1
    
    echo "Setting up continuous monitoring..."
    
    # Install Falco for runtime security monitoring
    if ! command -v falco &> /dev/null; then
        curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
        echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
        apt-get update -qq
        apt-get install -y falco
    fi
    
    # Configure Falco rules for container
    cat >> /etc/falco/falco_rules.local.yaml << EOF
- rule: Suspicious Container Activity
  desc: Detect suspicious activity in specific container
  condition: >
    container.name = "$container_name" and
    (spawned_process or
     file_access and fd.name contains "/etc/passwd" or
     network_connection and fd.sport > 1024)
  output: >
    Suspicious activity in container $container_name
    (user=%user.name command=%proc.cmdline file=%fd.name)
  priority: WARNING
EOF
    
    # Start Falco
    systemctl enable falco
    systemctl start falco
}
```

## 🚀 Amazon: Auto-Scaling Architecture

### Amazon's Auto-Scaling Strategy
```python
#!/usr/bin/env python3
# amazon-autoscaling.py - Amazon-style intelligent auto-scaling

import asyncio
import time
import json
from dataclasses import dataclass
from typing import Dict, List, Optional
import boto3
import docker

@dataclass
class ScalingMetrics:
    cpu_utilization: float
    memory_utilization: float
    request_rate: float
    response_time: float
    error_rate: float
    queue_depth: int

@dataclass
class ScalingPolicy:
    metric_name: str
    threshold_up: float
    threshold_down: float
    scale_up_adjustment: int
    scale_down_adjustment: int
    cooldown_period: int

class AmazonStyleAutoScaler:
    def __init__(self):
        self.client = docker.from_env()
        self.scaling_policies: List[ScalingPolicy] = []
        self.scaling_history: List[Dict] = []
        self.cooldown_timers: Dict[str, float] = {}
        
    def add_scaling_policy(self, policy: ScalingPolicy):
        """Add scaling policy"""
        self.scaling_policies.append(policy)
        
    async def start_autoscaling(self, service_name: str):
        """Start auto-scaling for service"""
        
        print(f"Starting auto-scaling for {service_name}")
        
        while True:
            try:
                # Collect metrics
                metrics = await self.collect_metrics(service_name)
                
                # Make scaling decisions
                scaling_decision = await self.make_scaling_decision(
                    service_name, metrics
                )
                
                # Execute scaling if needed
                if scaling_decision['action'] != 'none':
                    await self.execute_scaling(service_name, scaling_decision)
                    
                # Wait before next evaluation
                await asyncio.sleep(60)  # Check every minute
                
            except Exception as e:
                print(f"Auto-scaling error: {e}")
                await asyncio.sleep(60)
                
    async def collect_metrics(self, service_name: str) -> ScalingMetrics:
        """Collect comprehensive metrics"""
        
        containers = self.client.containers.list(
            filters={'label': f'service={service_name}'}
        )
        
        if not containers:
            return ScalingMetrics(0, 0, 0, 0, 0, 0)
            
        # Aggregate metrics from all containers
        total_cpu = 0
        total_memory = 0
        total_requests = 0
        total_response_time = 0
        total_errors = 0
        
        for container in containers:
            stats = container.stats(stream=False)
            
            # CPU utilization
            cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                       stats['precpu_stats']['cpu_usage']['total_usage']
            system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                          stats['precpu_stats']['system_cpu_usage']
            
            if system_delta > 0:
                cpu_percent = (cpu_delta / system_delta) * 100.0
                total_cpu += cpu_percent
                
            # Memory utilization
            memory_usage = stats['memory_stats']['usage']
            memory_limit = stats['memory_stats']['limit']
            memory_percent = (memory_usage / memory_limit) * 100.0
            total_memory += memory_percent
            
            # Application metrics (would come from monitoring system)
            total_requests += self.get_request_rate(container)
            total_response_time += self.get_response_time(container)
            total_errors += self.get_error_rate(container)
            
        container_count = len(containers)
        
        return ScalingMetrics(
            cpu_utilization=total_cpu / container_count,
            memory_utilization=total_memory / container_count,
            request_rate=total_requests,
            response_time=total_response_time / container_count,
            error_rate=total_errors / container_count,
            queue_depth=self.get_queue_depth(service_name)
        )
        
    def get_request_rate(self, container) -> float:
        """Get request rate from container metrics"""
        # Mock implementation - would integrate with monitoring
        return 100.0
        
    def get_response_time(self, container) -> float:
        """Get response time from container metrics"""
        # Mock implementation
        return 150.0  # ms
        
    def get_error_rate(self, container) -> float:
        """Get error rate from container metrics"""
        # Mock implementation
        return 0.5  # %
        
    def get_queue_depth(self, service_name: str) -> int:
        """Get queue depth from message queue"""
        # Mock implementation
        return 10
        
    async def make_scaling_decision(self, service_name: str, 
                                  metrics: ScalingMetrics) -> Dict:
        """Make intelligent scaling decision"""
        
        current_time = time.time()
        
        # Check cooldown periods
        if service_name in self.cooldown_timers:
            if current_time - self.cooldown_timers[service_name] < 300:  # 5 min cooldown
                return {'action': 'none', 'reason': 'cooldown_active'}
                
        # Evaluate each scaling policy
        scale_up_votes = 0
        scale_down_votes = 0
        scale_adjustments = []
        
        for policy in self.scaling_policies:
            metric_value = getattr(metrics, policy.metric_name.replace('-', '_'))
            
            if metric_value > policy.threshold_up:
                scale_up_votes += 1
                scale_adjustments.append(policy.scale_up_adjustment)
            elif metric_value < policy.threshold_down:
                scale_down_votes += 1
                scale_adjustments.append(-policy.scale_down_adjustment)
                
        # Make decision based on votes
        if scale_up_votes > scale_down_votes:
            adjustment = max(scale_adjustments) if scale_adjustments else 1
            return {
                'action': 'scale_up',
                'adjustment': adjustment,
                'reason': f'scale_up_votes={scale_up_votes}',
                'metrics': metrics
            }
        elif scale_down_votes > scale_up_votes:
            adjustment = min(scale_adjustments) if scale_adjustments else -1
            return {
                'action': 'scale_down',
                'adjustment': abs(adjustment),
                'reason': f'scale_down_votes={scale_down_votes}',
                'metrics': metrics
            }
        else:
            return {'action': 'none', 'reason': 'no_consensus'}
            
    async def execute_scaling(self, service_name: str, decision: Dict):
        """Execute scaling decision"""
        
        print(f"Executing scaling: {decision['action']} by {decision['adjustment']}")
        
        containers = self.client.containers.list(
            filters={'label': f'service={service_name}'}
        )
        
        current_count = len(containers)
        
        if decision['action'] == 'scale_up':
            target_count = current_count + decision['adjustment']
            await self.scale_up(service_name, target_count, current_count)
            
        elif decision['action'] == 'scale_down':
            target_count = max(1, current_count - decision['adjustment'])
            await self.scale_down(service_name, target_count, current_count)
            
        # Record scaling event
        self.scaling_history.append({
            'timestamp': time.time(),
            'service': service_name,
            'action': decision['action'],
            'from_count': current_count,
            'to_count': target_count,
            'reason': decision['reason'],
            'metrics': decision.get('metrics')
        })
        
        # Set cooldown timer
        self.cooldown_timers[service_name] = time.time()
        
    async def scale_up(self, service_name: str, target_count: int, current_count: int):
        """Scale up service"""
        
        containers_to_add = target_count - current_count
        
        for i in range(containers_to_add):
            container_name = f"{service_name}-{current_count + i + 1}"
            
            container = self.client.containers.run(
                f"{service_name}:latest",
                name=container_name,
                labels={'service': service_name},
                detach=True,
                restart_policy={'Name': 'unless-stopped'}
            )
            
            print(f"Started container: {container_name}")
            
        print(f"Scaled up {service_name} from {current_count} to {target_count}")
        
    async def scale_down(self, service_name: str, target_count: int, current_count: int):
        """Scale down service"""
        
        containers = self.client.containers.list(
            filters={'label': f'service={service_name}'}
        )
        
        containers_to_remove = current_count - target_count
        
        # Remove oldest containers first
        containers_to_stop = containers[-containers_to_remove:]
        
        for container in containers_to_stop:
            print(f"Stopping container: {container.name}")
            container.stop(timeout=30)
            container.remove()
            
        print(f"Scaled down {service_name} from {current_count} to {target_count}")
        
    def get_scaling_history(self) -> List[Dict]:
        """Get scaling history"""
        return self.scaling_history
        
    def get_current_metrics(self, service_name: str) -> Optional[ScalingMetrics]:
        """Get current metrics for service"""
        # This would be implemented to return real-time metrics
        pass

# Example usage
async def main():
    scaler = AmazonStyleAutoScaler()
    
    # Add scaling policies
    scaler.add_scaling_policy(ScalingPolicy(
        metric_name='cpu_utilization',
        threshold_up=70.0,
        threshold_down=30.0,
        scale_up_adjustment=2,
        scale_down_adjustment=1,
        cooldown_period=300
    ))
    
    scaler.add_scaling_policy(ScalingPolicy(
        metric_name='memory_utilization',
        threshold_up=80.0,
        threshold_down=40.0,
        scale_up_adjustment=1,
        scale_down_adjustment=1,
        cooldown_period=300
    ))
    
    scaler.add_scaling_policy(ScalingPolicy(
        metric_name='response_time',
        threshold_up=500.0,  # 500ms
        threshold_down=100.0,  # 100ms
        scale_up_adjustment=3,
        scale_down_adjustment=1,
        cooldown_period=180
    ))
    
    # Start auto-scaling
    await scaler.start_autoscaling('web-service')

if __name__ == "__main__":
    asyncio.run(main())
```

## 📊 Performance Comparison

### Industry Benchmarks
```python
#!/usr/bin/env python3
# industry-benchmarks.py - Compare with industry standards

class IndustryBenchmarks:
    
    NETFLIX_BENCHMARKS = {
        'container_startup_time': 2.5,  # seconds
        'request_latency_p99': 100,     # milliseconds
        'availability': 99.99,          # percentage
        'containers_per_host': 50,
        'deployment_frequency': 1000,   # per day
        'mttr': 5                       # minutes
    }
    
    GOOGLE_BENCHMARKS = {
        'container_startup_time': 1.8,
        'request_latency_p99': 50,
        'availability': 99.999,
        'containers_per_host': 100,
        'deployment_frequency': 5000,
        'mttr': 2
    }
    
    AMAZON_BENCHMARKS = {
        'container_startup_time': 3.0,
        'request_latency_p99': 150,
        'availability': 99.95,
        'containers_per_host': 30,
        'deployment_frequency': 2000,
        'mttr': 8
    }
    
    @classmethod
    def compare_performance(cls, your_metrics: dict) -> dict:
        """Compare your metrics with industry leaders"""
        
        comparison = {}
        
        for company, benchmarks in [
            ('Netflix', cls.NETFLIX_BENCHMARKS),
            ('Google', cls.GOOGLE_BENCHMARKS),
            ('Amazon', cls.AMAZON_BENCHMARKS)
        ]:
            comparison[company] = {}
            
            for metric, industry_value in benchmarks.items():
                your_value = your_metrics.get(metric, 0)
                
                if metric in ['availability']:
                    # Higher is better
                    performance_ratio = your_value / industry_value
                elif metric in ['container_startup_time', 'request_latency_p99', 'mttr']:
                    # Lower is better
                    performance_ratio = industry_value / your_value if your_value > 0 else 0
                else:
                    # Higher is better (containers_per_host, deployment_frequency)
                    performance_ratio = your_value / industry_value
                    
                comparison[company][metric] = {
                    'your_value': your_value,
                    'industry_value': industry_value,
                    'performance_ratio': performance_ratio,
                    'status': 'better' if performance_ratio > 1.0 else 'needs_improvement'
                }
                
        return comparison

# Example usage
your_metrics = {
    'container_startup_time': 4.2,
    'request_latency_p99': 200,
    'availability': 99.9,
    'containers_per_host': 25,
    'deployment_frequency': 100,
    'mttr': 15
}

comparison = IndustryBenchmarks.compare_performance(your_metrics)
print(json.dumps(comparison, indent=2))
```

## 🎯 Key Takeaways

### Netflix Lessons
- **Chaos Engineering**: Proactively test failure scenarios
- **Circuit Breakers**: Prevent cascade failures
- **Microservices**: Independent, scalable services
- **Continuous Deployment**: Multiple deployments per day

### Google Lessons  
- **Security First**: Multi-layered security approach
- **Zero Trust**: Never trust, always verify
- **Automation**: Eliminate manual processes
- **Observability**: Deep monitoring and tracing

### Amazon Lessons
- **Auto-Scaling**: Intelligent, predictive scaling
- **Cost Optimization**: Efficient resource utilization
- **High Availability**: Multi-region deployments
- **Customer Focus**: Performance and reliability

These case studies reveal the advanced techniques used by industry leaders to achieve unprecedented scale and reliability.
