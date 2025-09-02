# 🐳 Nginx Docker & Kubernetes Integration

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Performance Optimization completed  

Master Nginx deployment in containerized environments, including Docker containers, Kubernetes clusters, and cloud-native architectures.

## 🎯 Learning Objectives

- Deploy Nginx in Docker containers with optimal configurations
- Configure Nginx as Kubernetes Ingress Controller
- Implement service mesh integration with Nginx
- Optimize Nginx for cloud-native environments
- Manage configuration and secrets in containerized deployments

## 🐳 Nginx Docker Deployment

### Production Nginx Dockerfile
```dockerfile
# Multi-stage Nginx build for production
FROM nginx:alpine AS base

# Install additional tools
RUN apk add --no-cache \
    curl \
    openssl \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx

FROM base AS production

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

# Copy SSL certificates
COPY ssl/ /etc/nginx/ssl/

# Copy static content
COPY --chown=nginx:nginx html/ /usr/share/nginx/html/

# Create necessary directories
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Switch to non-root user
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080 8443

CMD ["nginx", "-g", "daemon off;"]
```

### Optimized Nginx Configuration for Containers
```nginx
# /etc/nginx/nginx.conf - Container-optimized configuration

# Run as non-root user
user nginx;

# Auto-detect worker processes (container-aware)
worker_processes auto;

# PID file location
pid /tmp/nginx.pid;

# Error log
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # Basic settings
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # Performance settings for containers
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Client settings
    client_max_body_size 100m;
    client_body_buffer_size 128k;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Include server configurations
    include /etc/nginx/conf.d/*.conf;
}
```

### Docker Compose for Nginx Stack
```yaml
# docker-compose.yml - Complete Nginx stack
version: '3.8'

services:
  nginx:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: nginx-prod
    ports:
      - "80:8080"
      - "443:8443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./html:/usr/share/nginx/html:ro
      - nginx_cache:/var/cache/nginx
      - nginx_logs:/var/log/nginx
    environment:
      - NGINX_WORKER_PROCESSES=auto
      - NGINX_WORKER_CONNECTIONS=1024
    networks:
      - nginx_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'

  # Backend application
  backend:
    image: ecommerce-backend:latest
    container_name: backend-app
    expose:
      - "8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/ecommerce
    networks:
      - nginx_network
    depends_on:
      - db
    restart: unless-stopped

  # Database
  db:
    image: postgres:13-alpine
    container_name: postgres-db
    environment:
      - POSTGRES_DB=ecommerce
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - nginx_network
    restart: unless-stopped

volumes:
  nginx_cache:
  nginx_logs:
  postgres_data:

networks:
  nginx_network:
    driver: bridge
```

## ☸️ Kubernetes Nginx Deployment

### Nginx Deployment Manifest
```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        - containerPort: 443
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: nginx-conf-d
          mountPath: /etc/nginx/conf.d
        - name: ssl-certs
          mountPath: /etc/nginx/ssl
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
      - name: nginx-conf-d
        configMap:
          name: nginx-conf-d
      - name: ssl-certs
        secret:
          secretName: nginx-ssl-certs
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
spec:
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
  type: LoadBalancer
```

### Nginx ConfigMap
```yaml
# nginx-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: default
data:
  nginx.conf: |
    user nginx;
    worker_processes auto;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;
    
    events {
        worker_connections 1024;
    }
    
    http {
        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
        
        access_log /var/log/nginx/access.log main;
        
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        
        include /etc/nginx/conf.d/*.conf;
    }
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf-d
  namespace: default
data:
  default.conf: |
    upstream backend {
        server backend-service:8000;
    }
    
    server {
        listen 80;
        server_name _;
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
```

### Nginx Ingress Controller
```yaml
# nginx-ingress-controller.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - shop.example.com
    - api.shop.example.com
    secretName: ecommerce-tls
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
  - host: api.shop.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
```

## 🎯 E-Commerce Kubernetes Deployment

### Complete E-Commerce Stack
```yaml
# ecommerce-stack.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
---
# Frontend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: ecommerce
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ecommerce-frontend:latest
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
# Backend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: ecommerce
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
# Services
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: ecommerce
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: ecommerce
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
---
# Nginx Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ingress
  namespace: ecommerce
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Frame-Options: DENY";
      more_set_headers "X-Content-Type-Options: nosniff";
      more_set_headers "X-XSS-Protection: 1; mode=block";
spec:
  tls:
  - hosts:
    - shop.example.com
    secretName: ecommerce-tls
  rules:
  - host: shop.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

### Horizontal Pod Autoscaler
```yaml
# hpa.yaml - Auto-scaling configuration
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: ecommerce
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  minReplicas: 3
  maxReplicas: 10
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
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: ecommerce
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🔧 Advanced Kubernetes Integration

### Custom Nginx Configuration with Helm
```yaml
# values.yaml - Helm chart values
nginx:
  replicaCount: 3
  
  image:
    repository: nginx
    tag: alpine
    pullPolicy: IfNotPresent
  
  service:
    type: LoadBalancer
    port: 80
    httpsPort: 443
  
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    hosts:
      - host: shop.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ecommerce-tls
        hosts:
          - shop.example.com
  
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi
  
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
  
  config:
    worker_processes: "auto"
    worker_connections: 1024
    keepalive_timeout: 65
    client_max_body_size: "100m"
```

### Service Mesh Integration (Istio)
```yaml
# istio-gateway.yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ecommerce-gateway
  namespace: ecommerce
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - shop.example.com
    tls:
      httpsRedirect: true
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: ecommerce-tls
    hosts:
    - shop.example.com
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ecommerce-vs
  namespace: ecommerce
spec:
  hosts:
  - shop.example.com
  gateways:
  - ecommerce-gateway
  http:
  - match:
    - uri:
        prefix: /api
    route:
    - destination:
        host: backend-service
        port:
          number: 8000
    timeout: 30s
    retries:
      attempts: 3
      perTryTimeout: 10s
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: frontend-service
        port:
          number: 80
```

## 📊 Monitoring and Observability

### Prometheus Monitoring
```yaml
# nginx-monitoring.yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: nginx-metrics
  namespace: ecommerce
spec:
  selector:
    matchLabels:
      app: nginx
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-prometheus-config
  namespace: ecommerce
data:
  nginx.conf: |
    server {
        listen 9113;
        location /metrics {
            stub_status on;
            access_log off;
            allow 10.0.0.0/8;
            deny all;
        }
    }
```

### Deployment Commands
```bash
# Deploy Nginx stack to Kubernetes
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-configmap.yaml
kubectl apply -f ecommerce-stack.yaml

# Check deployment status
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get ingress -n ecommerce

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5 -n ecommerce

# Update configuration
kubectl rollout restart deployment/nginx-deployment -n ecommerce

# Check logs
kubectl logs -f deployment/nginx-deployment -n ecommerce

# Port forward for testing
kubectl port-forward service/nginx-service 8080:80 -n ecommerce
```

## 🎯 Practical Exercises

### Exercise 1: Docker Nginx Deployment
Deploy Nginx in Docker with:
- Multi-stage Dockerfile
- Non-root user configuration
- Health checks and monitoring
- Volume mounts for configuration

### Exercise 2: Kubernetes Ingress Setup
Configure Nginx Ingress Controller:
- SSL termination
- Path-based routing
- Rate limiting
- Security headers

### Exercise 3: Auto-scaling Configuration
Implement auto-scaling:
- Horizontal Pod Autoscaler
- Resource limits and requests
- Performance monitoring
- Load testing validation

---

**🎯 Next**: Module 4 comprehensive assessment  
**📚 Resources**: [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)  
**🔧 Tools**: Use `kubectl`, `helm`, and `docker` for deployment and management
