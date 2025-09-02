# Multi-Container Applications - Complete E-Commerce Architecture

## 📋 Learning Objectives
- **Master** multi-tier application architecture patterns
- **Understand** service coordination and dependency management
- **Apply** microservices principles to e-commerce platform
- **Build** production-ready multi-container orchestration

---

## 🏗️ Complete E-Commerce Multi-Container Architecture

### **Production-Ready E-Commerce Stack**

```yaml
version: '3.8'

services:
  # Load Balancer & SSL Termination
  traefik:
    image: traefik:v2.9
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.myresolver.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "letsencrypt:/letsencrypt"
    networks:
      - web_network
    labels:
      - "traefik.enable=true"

  # Frontend Application
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    environment:
      REACT_APP_API_URL: https://api.${DOMAIN_NAME}
      REACT_APP_STRIPE_KEY: ${STRIPE_PUBLISHABLE_KEY}
    volumes:
      - frontend_build:/app/build
    networks:
      - web_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`${DOMAIN_NAME}`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=myresolver"
    depends_on:
      - backend

  # Backend API Gateway
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      JWT_SECRET: ${JWT_SECRET}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
    volumes:
      - uploads:/app/uploads
      - logs:/app/logs
    networks:
      - web_network
      - api_network
      - database_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.${DOMAIN_NAME}`)"
      - "traefik.http.routers.backend.entrypoints=websecure"
      - "traefik.http.routers.backend.tls.certresolver=myresolver"
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  # User Service (Microservice)
  user-service:
    build:
      context: ./services/user-service
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      JWT_SECRET: ${JWT_SECRET}
    networks:
      - api_network
      - database_network
    depends_on:
      database:
        condition: service_healthy
    deploy:
      replicas: 2

  # Product Service (Microservice)
  product-service:
    build:
      context: ./services/product-service
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      ELASTICSEARCH_URL: http://elasticsearch:9200
    networks:
      - api_network
      - database_network
      - search_network
    depends_on:
      database:
        condition: service_healthy
      elasticsearch:
        condition: service_healthy
    deploy:
      replicas: 2

  # Order Service (Microservice)
  order-service:
    build:
      context: ./services/order-service
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672/
    networks:
      - api_network
      - database_network
      - message_network
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    deploy:
      replicas: 2

  # Payment Service (Microservice)
  payment-service:
    build:
      context: ./services/payment-service
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672/
    networks:
      - api_network
      - database_network
      - message_network
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    deploy:
      replicas: 1  # Single instance for payment consistency

  # Background Worker
  worker:
    build:
      context: ./worker
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@database:5432/${DB_NAME}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      RABBITMQ_URL: amqp://guest:guest@rabbitmq:5672/
      SENDGRID_API_KEY: ${SENDGRID_API_KEY}
    networks:
      - database_network
      - message_network
    depends_on:
      database:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    deploy:
      replicas: 2

  # Database (PostgreSQL)
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d:ro
    networks:
      - database_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'

  # Cache (Redis)
  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - database_network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Search Engine (Elasticsearch)
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - search_network
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Message Queue (RabbitMQ)
  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: ${RABBITMQ_USER}
      RABBITMQ_DEFAULT_PASS: ${RABBITMQ_PASSWORD}
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - message_network
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring (Prometheus)
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring_network
      - api_network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

  # Metrics Visualization (Grafana)
  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources:ro
    networks:
      - monitoring_network
      - web_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.grafana.rule=Host(`monitoring.${DOMAIN_NAME}`)"
      - "traefik.http.routers.grafana.entrypoints=websecure"
      - "traefik.http.routers.grafana.tls.certresolver=myresolver"
    depends_on:
      - prometheus

networks:
  web_network:
    driver: bridge
  api_network:
    driver: bridge
    internal: true
  database_network:
    driver: bridge
    internal: true
  search_network:
    driver: bridge
    internal: true
  message_network:
    driver: bridge
    internal: true
  monitoring_network:
    driver: bridge
    internal: true

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:
  rabbitmq_data:
  prometheus_data:
  grafana_data:
  uploads:
  logs:
  frontend_build:
  letsencrypt:
```

---

## 🧪 Hands-On Practice: Complete E-Commerce Deployment

### **Exercise 1: Deploy Complete Stack**

```bash
# Create environment file
cat > .env << 'EOF'
DOMAIN_NAME=ecommerce.local
ACME_EMAIL=admin@ecommerce.local

DB_NAME=ecommerce
DB_USER=ecommerce_admin
DB_PASSWORD=secure_db_password_123

REDIS_PASSWORD=secure_redis_password_123
RABBITMQ_USER=ecommerce
RABBITMQ_PASSWORD=secure_rabbitmq_password_123

JWT_SECRET=your_jwt_secret_here_make_it_very_long_and_secure
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key

SENDGRID_API_KEY=your_sendgrid_api_key
GRAFANA_PASSWORD=secure_grafana_password_123
EOF

# Deploy the complete stack
docker-compose up -d

# Verify all services are running
docker-compose ps

# Check service health
docker-compose exec backend curl -f http://localhost:8000/health
docker-compose exec user-service curl -f http://localhost:3001/health
docker-compose exec product-service curl -f http://localhost:3002/health
```

### **Exercise 2: Test Service Communication**

```bash
# Test API Gateway to Microservices
docker-compose exec backend curl http://user-service:3001/api/users
docker-compose exec backend curl http://product-service:3002/api/products
docker-compose exec backend curl http://order-service:3003/api/orders

# Test Database Connectivity
docker-compose exec user-service pg_isready -h database -U ecommerce_admin
docker-compose exec product-service pg_isready -h database -U ecommerce_admin

# Test Message Queue
docker-compose exec order-service curl http://rabbitmq:15672/api/overview
```

---

## ✅ Knowledge Check: Multi-Container Mastery

### **Conceptual Understanding**
- [ ] Understands microservices architecture patterns
- [ ] Knows service coordination and dependency management
- [ ] Comprehends inter-service communication strategies
- [ ] Understands load balancing and scaling patterns
- [ ] Knows monitoring and observability for distributed systems

### **Practical Skills**
- [ ] Can design and implement multi-tier applications
- [ ] Knows how to coordinate service dependencies
- [ ] Can implement service discovery and communication
- [ ] Understands how to scale individual services
- [ ] Can monitor and troubleshoot distributed applications

### **E-Commerce Application**
- [ ] Has deployed complete multi-container e-commerce platform
- [ ] Implemented microservices architecture with proper separation
- [ ] Set up service communication and coordination
- [ ] Configured load balancing and scaling
- [ ] Implemented monitoring and observability

---

## 🚀 Next Steps: Environment Configuration

**Continue to Environment Variables and Configuration when you have successfully deployed and tested your complete multi-container e-commerce platform.**
