# Docker Compose Networks - From Basic Connectivity to E-Commerce Security

## 📋 Learning Objectives
- **Master** Docker Compose networking concepts and custom network creation
- **Understand** service discovery and inter-service communication patterns
- **Apply** network security and isolation strategies to e-commerce architecture
- **Build** production-ready network topologies for scalable applications

---

## 🤔 Understanding Docker Compose Networking

### **The Networking Challenge in Multi-Container Applications**

Without proper networking, your e-commerce services would be isolated islands:

```bash
# Without Docker Compose networking (manual approach)
docker run -d --name database postgres:13
docker run -d --name backend --link database my-backend
docker run -d --name frontend --link backend my-frontend

# Problems:
# - Manual linking is deprecated and fragile
# - No network isolation or security
# - Difficult to scale or modify
# - Hard to troubleshoot connectivity issues
```

### **Docker Compose Networking Solution**

```yaml
# With Docker Compose (automatic networking)
version: '3.8'
services:
  database:
    image: postgres:13
    # Automatically accessible as 'database' hostname
  
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://user:pass@database:5432/db
      # Uses service name as hostname - automatic service discovery!
  
  frontend:
    build: ./frontend
    environment:
      REACT_APP_API_URL: http://backend:8000
      # Frontend can reach backend by service name
```

**Key Benefits:**
- ✅ **Automatic service discovery** - services find each other by name
- ✅ **Network isolation** - your application is isolated from other Docker networks
- ✅ **DNS resolution** - service names resolve to container IP addresses
- ✅ **Load balancing** - traffic distributed across service replicas
- ✅ **Security** - internal communication doesn't require port exposure

---

## 🏗️ Docker Compose Network Architecture

### **Default Network Behavior**

When you run `docker-compose up`, Compose automatically:

1. **Creates a bridge network** named `{project-name}_default`
2. **Connects all services** to this network
3. **Enables DNS resolution** between services
4. **Provides network isolation** from other Docker networks

```yaml
# This simple compose file...
version: '3.8'
services:
  web:
    image: nginx
  api:
    image: node:16

# Automatically creates:
# - Network: myproject_default
# - web container connected to network
# - api container connected to network
# - web can reach api at http://api:port
# - api can reach web at http://web:port
```

### **Network Types in Docker Compose**

#### **1. Bridge Networks (Default)**
```yaml
# Default bridge network (automatic)
services:
  web:
    image: nginx
  # All services join the default bridge network

# Custom bridge network (explicit)
networks:
  frontend:
    driver: bridge

services:
  web:
    image: nginx
    networks:
      - frontend
```

#### **2. Host Networks**
```yaml
services:
  monitoring:
    image: prometheus
    network_mode: host  # Use host's network stack
    # Container shares host's IP and ports
```

#### **3. None Networks**
```yaml
services:
  batch-job:
    image: my-batch-processor
    network_mode: none  # No network access
    # Completely isolated container
```

---

## 🛒 E-Commerce Network Architecture: Progressive Security

### **Level 1: Basic E-Commerce Networking**

```yaml
version: '3.8'

services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure123
    # No ports exposed - internal access only

  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://admin:secure123@database:5432/ecommerce
    ports:
      - "8000:8000"  # Exposed for external access
    depends_on:
      - database

  frontend:
    build: ./frontend
    environment:
      REACT_APP_API_URL: http://backend:8000
    ports:
      - "3000:3000"  # Exposed for external access
    depends_on:
      - backend

# All services automatically join 'ecommerce_default' network
# Services can communicate using service names as hostnames
```

### **Level 2: Multi-Tier Network Security**

```yaml
version: '3.8'

services:
  # Database tier (most secure)
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure123
    networks:
      - database_tier  # Only accessible from database network
    # No external ports - completely internal

  # Cache tier
  redis:
    image: redis:alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    networks:
      - cache_tier
    # No external ports - internal only

  # Application tier
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://admin:secure123@database:5432/ecommerce
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
    networks:
      - database_tier  # Can access database
      - cache_tier     # Can access cache
      - api_tier       # Can be accessed by frontend
    # No external ports - accessed through nginx

  # Presentation tier
  frontend:
    build: ./frontend
    networks:
      - api_tier       # Can access backend
      - web_tier       # Can be accessed by nginx
    # No external ports - served by nginx

  # Proxy tier (only external access point)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"        # Only service with external access
      - "443:443"
    networks:
      - web_tier       # Can access frontend
      - api_tier       # Can access backend API
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf

networks:
  database_tier:
    driver: bridge
    internal: true     # No external internet access
  
  cache_tier:
    driver: bridge
    internal: true     # No external internet access
  
  api_tier:
    driver: bridge
  
  web_tier:
    driver: bridge
```

---

## 🔧 Advanced Networking Features

### **1. Custom Network Configuration**

#### **Network Driver Options**
```yaml
networks:
  frontend:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-frontend
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          ip_range: 172.20.240.0/20
          gateway: 172.20.0.1
    labels:
      environment: production
      tier: frontend
```

#### **Service Network Configuration**
```yaml
services:
  backend:
    image: my-backend
    networks:
      frontend:
        aliases:
          - api-server
          - backend-service
        ipv4_address: 172.20.0.10
      database:
        aliases:
          - app-server
```

### **2. External Networks**

#### **Connecting to Existing Networks**
```yaml
# Connect to pre-existing Docker network
networks:
  existing_network:
    external: true
    name: my-existing-network

services:
  web:
    image: nginx
    networks:
      - existing_network
```

### **3. Network Aliases and Service Discovery**

```yaml
services:
  database:
    image: postgres:13
    networks:
      backend:
        aliases:
          - db
          - postgres
          - primary-db
  
  backend:
    image: my-backend
    environment:
      # Can use any alias to connect
      DATABASE_URL: postgresql://user:pass@db:5432/mydb
      # or: postgresql://user:pass@postgres:5432/mydb
      # or: postgresql://user:pass@primary-db:5432/mydb
    networks:
      - backend
```

---

## 🧪 Hands-On Practice: Network Security Implementation

### **Exercise 1: Network Segmentation**

Create a secure e-commerce network topology:

```yaml
version: '3.8'

services:
  # Public-facing services
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    networks:
      - dmz
      - web_tier
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf

  # Application services
  frontend:
    build: ./frontend
    networks:
      - web_tier
      - api_tier

  backend:
    build: ./backend
    networks:
      - api_tier
      - data_tier
    environment:
      DATABASE_URL: postgresql://user:pass@database:5432/ecommerce

  # Data services (most protected)
  database:
    image: postgres:13
    networks:
      - data_tier
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure123

networks:
  dmz:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.1.0/24
  
  web_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.2.0/24
  
  api_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.3.0/24
  
  data_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.4.0/24
```

### **Exercise 2: Network Monitoring and Debugging**

```bash
# Inspect networks
docker network ls
docker network inspect ecommerce_dmz

# Test connectivity between services
docker-compose exec backend ping database
docker-compose exec frontend curl http://backend:8000/health

# Monitor network traffic
docker-compose exec nginx netstat -tulpn
docker-compose exec backend ss -tulpn

# Debug DNS resolution
docker-compose exec backend nslookup database
docker-compose exec backend dig database
```

---

## ✅ Knowledge Check: Network Mastery

### **Conceptual Understanding**
- [ ] Understands Docker Compose default networking behavior
- [ ] Knows how to create and configure custom networks
- [ ] Comprehends network security and isolation strategies
- [ ] Understands service discovery and DNS resolution
- [ ] Knows load balancing and traffic management concepts

### **Practical Skills**
- [ ] Can design secure network topologies
- [ ] Knows how to implement network segmentation
- [ ] Can configure service aliases and discovery
- [ ] Understands network troubleshooting techniques
- [ ] Can implement load balancing configurations

### **E-Commerce Application**
- [ ] Has implemented secure network architecture
- [ ] Created proper network segmentation for different tiers
- [ ] Configured service discovery for all components
- [ ] Implemented load balancing for scalability
- [ ] Set up network monitoring and debugging

---

## 🚀 Next Steps: Volume Management

### **What You've Mastered**
- ✅ **Docker Compose networking** concepts and architecture
- ✅ **Custom network creation** and configuration
- ✅ **Network security** and isolation strategies
- ✅ **Service discovery** and inter-service communication
- ✅ **Load balancing** and traffic management

### **Coming Next: Docker Compose Volumes**
In **05-Docker-Compose-Volumes.md**, you'll learn:
- **Data persistence strategies** for stateful services
- **Volume types and configurations** for different use cases
- **Backup and recovery** procedures for production data
- **Performance optimization** for storage-intensive applications

**Continue to Volume Management when you're comfortable with networking concepts and have implemented secure network architecture for your e-commerce platform.**
    
  database:
    image: postgres:alpine
    # Completely isolated from external access
    # Only accessible from other services in this stack
```

## Default Networking

### Automatic Network Creation
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
  
  app:
    image: node:alpine
    environment:
      - DATABASE_URL=postgresql://user:pass@database:5432/myapp
  
  database:
    image: postgres:alpine

# Docker Compose automatically creates:
# - Network named: {project_name}_default
# - All services join this network
# - Services can communicate using service names as hostnames
```

### Service Name Resolution
```yaml
services:
  web:
    image: nginx:alpine
    # Can reach app service at: http://app:3000
    # Can reach database at: postgresql://database:5432
    
  app:
    image: node:alpine
    environment:
      # Use service names as hostnames
      - API_URL=http://api:8080
      - DATABASE_HOST=database
      - REDIS_HOST=redis
      - CACHE_URL=redis://redis:6379
    
  api:
    image: myapi:latest
    
  database:
    image: postgres:alpine
    
  redis:
    image: redis:alpine
```

### Network Aliases
```yaml
services:
  web:
    image: nginx:alpine
    networks:
      default:
        aliases:
          - webserver
          - www
          - frontend
    # Now accessible as: web, webserver, www, or frontend
    
  database:
    image: postgres:alpine
    networks:
      default:
        aliases:
          - db
          - postgres
          - primary-db
    # Accessible as: database, db, postgres, or primary-db
```

## Custom Networks

### Creating Custom Networks
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - frontend
      - backend
    
  app:
    image: node:alpine
    networks:
      - backend
      - database
    
  database:
    image: postgres:alpine
    networks:
      - database

# Define custom networks
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  database:
    driver: bridge
    internal: true  # No external access
```

### Multi-Tier Architecture
```yaml
version: '3.8'

services:
  # Load balancer (public-facing)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    networks:
      - frontend
    
  # Web application (middle tier)
  webapp:
    build: .
    networks:
      - frontend
      - backend
    depends_on:
      - api
    
  # API services (application tier)
  api:
    build: ./api
    networks:
      - backend
      - database
    depends_on:
      - postgres
      - redis
    
  # Databases (data tier)
  postgres:
    image: postgres:15-alpine
    networks:
      - database
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    
  redis:
    image: redis:alpine
    networks:
      - database

networks:
  # Public-facing network
  frontend:
    driver: bridge
    
  # Application network
  backend:
    driver: bridge
    
  # Database network (internal only)
  database:
    driver: bridge
    internal: true
```

### Network with Custom Configuration
```yaml
networks:
  # Custom bridge network with subnet
  custom_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
    
  # Network with custom options
  app_network:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: "app_bridge"
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
    
  # External network (created outside Compose)
  external_network:
    external: true
    name: my_external_network

services:
  app:
    image: myapp:latest
    networks:
      custom_network:
        ipv4_address: 172.20.0.10
      app_network:
        aliases:
          - api-server
      external_network:
```

## Network Drivers

### Bridge Networks (Default)
```yaml
networks:
  # Default bridge network
  default:
    driver: bridge
    
  # Custom bridge with configuration
  custom_bridge:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.100.0/24
          gateway: 192.168.100.1
    driver_opts:
      com.docker.network.bridge.name: "custom_bridge"
      com.docker.network.mtu: "1500"

services:
  web:
    image: nginx:alpine
    networks:
      - custom_bridge
```

### Host Networks
```yaml
services:
  # Use host networking (no isolation)
  monitoring:
    image: prom/node-exporter
    network_mode: host
    # Service uses host's network stack directly
    # No port mapping needed
    # Can access host services directly
    
  # Alternative syntax
  app:
    image: myapp:latest
    networks:
      - host_network

networks:
  host_network:
    driver: host
```

### Overlay Networks (Swarm Mode)
```yaml
# For Docker Swarm deployments
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - overlay_net
    deploy:
      replicas: 3
      
  app:
    image: myapp:latest
    networks:
      - overlay_net
    deploy:
      replicas: 5

networks:
  overlay_net:
    driver: overlay
    attachable: true
    encrypted: true  # Encrypt network traffic
```

### None Network (Isolated)
```yaml
services:
  # Completely isolated container
  isolated_task:
    image: alpine:latest
    network_mode: none
    # No network access at all
    # Useful for batch processing, file operations
    command: ["sh", "-c", "echo 'Processing files...' && sleep 60"]
```

## Service Discovery

### Automatic Service Discovery
```yaml
services:
  web:
    image: nginx:alpine
    # Nginx configuration can reference services by name
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    
  app1:
    image: myapp:latest
    
  app2:
    image: myapp:latest
    
  app3:
    image: myapp:latest

# nginx.conf can use:
# upstream backend {
#     server app1:3000;
#     server app2:3000;
#     server app3:3000;
# }
```

### Service Discovery with Health Checks
```yaml
services:
  load_balancer:
    image: nginx:alpine
    depends_on:
      app1:
        condition: service_healthy
      app2:
        condition: service_healthy
    
  app1:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
  app2:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### External Service Discovery
```yaml
services:
  app:
    image: myapp:latest
    environment:
      # Connect to external services
      - EXTERNAL_API=https://api.external.com
      - EXTERNAL_DB=postgresql://external-db:5432/myapp
    extra_hosts:
      # Map external hostnames to IPs
      - "external-db:192.168.1.100"
      - "api.internal:10.0.0.50"
    
  # Connect to services in other Compose projects
  external_service:
    image: alpine:latest
    networks:
      - default
      - other_project_network

networks:
  other_project_network:
    external: true
    name: other_project_default
```

## Advanced Network Configuration

### Network Segmentation
```yaml
version: '3.8'

services:
  # Public services
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - public
      - web_tier
    
  # Web tier
  frontend:
    build: ./frontend
    networks:
      - web_tier
      - app_tier
    
  # Application tier
  api:
    build: ./api
    networks:
      - app_tier
      - data_tier
    
  # Data tier
  database:
    image: postgres:15-alpine
    networks:
      - data_tier
    
  # Monitoring (access to all tiers)
  monitoring:
    image: prom/prometheus
    networks:
      - web_tier
      - app_tier
      - data_tier
      - monitoring

networks:
  public:
    driver: bridge
    
  web_tier:
    driver: bridge
    internal: false
    
  app_tier:
    driver: bridge
    internal: true
    
  data_tier:
    driver: bridge
    internal: true
    
  monitoring:
    driver: bridge
    internal: true
```

### Network with Static IPs
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      app_network:
        ipv4_address: 172.20.0.10
    
  app:
    image: myapp:latest
    networks:
      app_network:
        ipv4_address: 172.20.0.20
    
  database:
    image: postgres:alpine
    networks:
      app_network:
        ipv4_address: 172.20.0.30

networks:
  app_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
          gateway: 172.20.0.1
```

### Network Policies and Firewall Rules
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - dmz
    labels:
      # Network policy labels (for external tools)
      - "network.policy=web-only"
      - "firewall.ingress=80,443"
      - "firewall.egress=app_tier"
    
  app:
    image: myapp:latest
    networks:
      - app_tier
    labels:
      - "network.policy=app-tier"
      - "firewall.ingress=app_tier"
      - "firewall.egress=database"
    
  database:
    image: postgres:alpine
    networks:
      - database
    labels:
      - "network.policy=database-only"
      - "firewall.ingress=app_tier"
      - "firewall.egress=none"

networks:
  dmz:
    driver: bridge
    labels:
      - "zone=dmz"
      - "security.level=medium"
    
  app_tier:
    driver: bridge
    internal: true
    labels:
      - "zone=application"
      - "security.level=high"
    
  database:
    driver: bridge
    internal: true
    labels:
      - "zone=data"
      - "security.level=critical"
```

## Network Troubleshooting

### Network Inspection Commands
```bash
# List networks
docker network ls

# Inspect network details
docker network inspect myproject_default

# Check service connectivity
docker compose exec web ping app
docker compose exec app nslookup database

# View network configuration
docker compose config

# Debug network issues
docker compose exec web netstat -tlnp
docker compose exec app ss -tlnp
```

### Network Testing Service
```yaml
services:
  network_test:
    image: alpine:latest
    command: >
      sh -c "
        apk add --no-cache curl netcat-openbsd &&
        echo 'Testing network connectivity...' &&
        ping -c 3 web &&
        ping -c 3 app &&
        nc -zv database 5432 &&
        curl -I http://web:80 &&
        echo 'Network tests completed'
      "
    networks:
      - default
    depends_on:
      - web
      - app
      - database
```

### Network Monitoring
```yaml
services:
  # Network monitoring with Prometheus
  network_monitor:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - monitoring
    ports:
      - "9090:9090"
    
  # Network exporter
  node_exporter:
    image: prom/node-exporter
    network_mode: host
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro

networks:
  monitoring:
    driver: bridge
```

## Network Best Practices

### 1. Security-First Networking
```yaml
# Principle of least privilege
networks:
  # Public-facing (minimal exposure)
  public:
    driver: bridge
    
  # Internal application networks
  backend:
    driver: bridge
    internal: true
    
  # Database network (most restricted)
  database:
    driver: bridge
    internal: true

services:
  web:
    networks: [public, backend]  # Bridge between public and internal
  app:
    networks: [backend, database]  # No direct public access
  db:
    networks: [database]  # Most isolated
```

### 2. Environment-Specific Networks
```yaml
# docker-compose.yml (base)
version: '3.8'
services:
  app:
    image: myapp:latest
    networks:
      - app_network

networks:
  app_network:

# docker-compose.override.yml (development)
version: '3.8'
services:
  app:
    ports:
      - "3000:3000"  # Expose for development

# docker-compose.prod.yml (production)
version: '3.8'
networks:
  app_network:
    driver: bridge
    internal: true  # No external access in production
```

### 3. Scalable Network Architecture
```yaml
version: '3.8'

x-network-config: &network-config
  driver: bridge
  ipam:
    config:
      - subnet: 172.20.0.0/16

services:
  load_balancer:
    image: nginx:alpine
    networks:
      - frontend
    ports:
      - "80:80"
    
  web:
    image: myapp:latest
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
    
  api:
    image: myapi:latest
    networks:
      - backend
      - database
    deploy:
      replicas: 5

networks:
  frontend:
    <<: *network-config
  backend:
    <<: *network-config
  database:
    <<: *network-config
    internal: true
```

This comprehensive guide covers Docker Compose networking from basic concepts to advanced enterprise patterns, ensuring secure and scalable multi-container communication.
