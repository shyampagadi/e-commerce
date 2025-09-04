# 📝 **Moderate Project: Full-Stack Todo Application**
## MERN Stack Todo App with Kubernetes Orchestration

---

## 📋 **Project Requirements Document**

### **🎯 Project Overview**

**Client Request**: Develop and deploy a full-stack todo application with user authentication, real-time updates, and cloud-native architecture using Kubernetes.

**Business Objective**: Create a scalable task management system that supports multiple users, real-time collaboration, and can handle growing user base with automatic scaling.

### **📊 Functional Requirements**

#### **Core Features**
1. **User Management**
   - User registration and authentication
   - JWT-based session management
   - Password reset functionality
   - User profile management

2. **Task Management**
   - Create, read, update, delete tasks
   - Task categories and priorities
   - Due dates and reminders
   - Task completion tracking

3. **Real-time Features**
   - Live task updates across sessions
   - Real-time notifications
   - Collaborative task sharing
   - WebSocket connections

4. **Data Persistence**
   - MongoDB database for task storage
   - Redis for session management
   - File uploads for task attachments
   - Data backup and recovery

#### **Technical Requirements**

1. **Frontend Requirements**
   - React.js with modern hooks
   - Responsive design (mobile-first)
   - Progressive Web App (PWA) features
   - Real-time UI updates

2. **Backend Requirements**
   - Node.js with Express framework
   - RESTful API design
   - WebSocket support for real-time features
   - JWT authentication middleware

3. **Database Requirements**
   - MongoDB for primary data storage
   - Redis for caching and sessions
   - Database indexing for performance
   - Automated backups

4. **Infrastructure Requirements**
   - Containerized microservices
   - Kubernetes orchestration
   - Auto-scaling capabilities
   - Load balancing and service discovery

### **🔧 Technical Specifications**

#### **Technology Stack**
- **Frontend**: React.js, Socket.io-client, Material-UI
- **Backend**: Node.js, Express.js, Socket.io
- **Database**: MongoDB, Redis
- **Authentication**: JWT, bcrypt
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Ingress**: Nginx Ingress Controller
- **Monitoring**: Prometheus, Grafana

#### **Architecture Requirements**
- **Microservices Pattern**: Separate services for auth, tasks, notifications
- **Event-Driven Architecture**: Real-time updates via WebSockets
- **Caching Strategy**: Redis for session and frequently accessed data
- **Security**: HTTPS, CORS, input validation, rate limiting

#### **Source Code References**
- **Primary**: https://github.com/mern-todo-app/mern-todo-app
- **Alternative 1**: https://github.com/bradtraversy/mern-tutorial
- **Alternative 2**: https://github.com/samaronybarros/todo-list-mern
- **Alternative 3**: https://github.com/bezkoder/react-node-express-mongodb-crud-example

---

## 🐳 **Docker Implementation**

### **Phase 1: Containerization Setup**

#### **Step 1: Project Structure**
```
todo-app/
├── frontend/
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── Dockerfile
├── backend/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── database/
│   └── init-scripts/
├── docker-compose.yml
├── docker-compose.prod.yml
└── k8s/
    ├── namespace.yaml
    ├── mongodb/
    ├── redis/
    ├── backend/
    ├── frontend/
    └── ingress/
```

#### **Step 2: Frontend Dockerfile**

```dockerfile
# frontend/Dockerfile
# Build stage
FROM node:16-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### **Step 3: Backend Dockerfile**

```dockerfile
# backend/Dockerfile
FROM node:16-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /usr/src/app
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

EXPOSE 5000

CMD ["node", "server.js"]
```

#### **Step 4: Docker Compose for Development**

```yaml
# docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:5.0
    container_name: todo-mongodb
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password123
      MONGO_INITDB_DATABASE: todoapp
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - ./database/init-scripts:/docker-entrypoint-initdb.d
    networks:
      - todo-network

  redis:
    image: redis:7-alpine
    container_name: todo-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - todo-network

  backend:
    build: ./backend
    container_name: todo-backend
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      NODE_ENV: development
      MONGODB_URI: mongodb://admin:password123@mongodb:27017/todoapp?authSource=admin
      REDIS_URL: redis://redis:6379
      JWT_SECRET: your-super-secret-jwt-key
      PORT: 5000
    depends_on:
      - mongodb
      - redis
    volumes:
      - ./backend:/usr/src/app
      - /usr/src/app/node_modules
    networks:
      - todo-network

  frontend:
    build: ./frontend
    container_name: todo-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    environment:
      REACT_APP_API_URL: http://localhost:5000
      REACT_APP_SOCKET_URL: http://localhost:5000
    depends_on:
      - backend
    networks:
      - todo-network

volumes:
  mongodb_data:
  redis_data:

networks:
  todo-network:
    driver: bridge
```

---

## ☸️ **Kubernetes Implementation**

### **Phase 2: Kubernetes Deployment**

#### **Step 1: Namespace and ConfigMaps**

```yaml
# k8s/01-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: todo-app
  labels:
    name: todo-app
    environment: production
---
# ConfigMap for backend configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: todo-app
data:
  NODE_ENV: "production"
  PORT: "5000"
  MONGODB_URI: "mongodb://mongodb-service:27017/todoapp"
  REDIS_URL: "redis://redis-service:6379"
---
# ConfigMap for frontend configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: todo-app
data:
  REACT_APP_API_URL: "https://api.todo-app.com"
  REACT_APP_SOCKET_URL: "wss://api.todo-app.com"
```

#### **Step 2: Secrets**

```yaml
# k8s/02-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: todo-app
type: Opaque
data:
  JWT_SECRET: eW91ci1zdXBlci1zZWNyZXQtand0LWtleQ== # base64 encoded
  MONGODB_ROOT_PASSWORD: cGFzc3dvcmQxMjM= # base64 encoded
  MONGODB_USERNAME: YWRtaW4= # base64 encoded
```

#### **Step 3: MongoDB Deployment**

```yaml
# k8s/mongodb/01-mongodb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-deployment
  namespace: todo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:5.0
        ports:
        - containerPort: 27017
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: MONGODB_USERNAME
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: MONGODB_ROOT_PASSWORD
        - name: MONGO_INITDB_DATABASE
          value: "todoapp"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: mongodb-storage
          mountPath: /data/db
        livenessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: mongodb-storage
        persistentVolumeClaim:
          claimName: mongodb-pvc
---
# MongoDB Service
apiVersion: v1
kind: Service
metadata:
  name: mongodb-service
  namespace: todo-app
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
  type: ClusterIP
---
# MongoDB PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc
  namespace: todo-app
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

#### **Step 4: Redis Deployment**

```yaml
# k8s/redis/01-redis-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
  namespace: todo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - redis-cli
            - ping
          initialDelaySeconds: 5
          periodSeconds: 5
---
# Redis Service
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: todo-app
spec:
  selector:
    app: redis
  ports:
  - port: 6379
    targetPort: 6379
  type: ClusterIP
```

#### **Step 5: Backend Deployment**

```yaml
# k8s/backend/01-backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: todo-app
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
        image: todo-backend:latest
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: backend-config
        env:
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: JWT_SECRET
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
---
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: todo-app
spec:
  selector:
    app: backend
  ports:
  - port: 5000
    targetPort: 5000
  type: ClusterIP
```

#### **Step 6: Frontend Deployment**

```yaml
# k8s/frontend/01-frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deployment
  namespace: todo-app
spec:
  replicas: 2
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
        image: todo-frontend:latest
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: frontend-config
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: todo-app
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

#### **Step 7: Ingress Configuration**

```yaml
# k8s/ingress/01-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todo-app-ingress
  namespace: todo-app
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/websocket-services: "backend-service"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
spec:
  tls:
  - hosts:
    - todo-app.com
    - api.todo-app.com
    secretName: todo-app-tls
  rules:
  - host: todo-app.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
  - host: api.todo-app.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 5000
```

---

## 🛠️ **Complete Solution Guide**

### **Solution 1: Docker Implementation**

#### **Step-by-Step Docker Solution**

**Step 1: Clone and Setup Project**
```bash
# Clone the MERN todo application
git clone https://github.com/mern-todo-app/mern-todo-app.git todo-app
cd todo-app

# Create Docker files
mkdir -p frontend backend database/init-scripts k8s
```

**Step 2: Create Frontend Dockerfile**
```bash
# Create frontend/Dockerfile
cat > frontend/Dockerfile << 'EOF'
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```

**Step 3: Create Backend Dockerfile**
```bash
# Create backend/Dockerfile
cat > backend/Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /usr/src/app
USER nodejs
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
EXPOSE 5000
CMD ["node", "server.js"]
EOF
```

**Step 4: Build and Test with Docker Compose**
```bash
# Build all services
docker-compose build

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Test the application
curl http://localhost:3000  # Frontend
curl http://localhost:5000/health  # Backend API

# Stop services
docker-compose down
```

### **Solution 2: Kubernetes Implementation**

#### **Step-by-Step Kubernetes Solution**

**Step 1: Prepare Kubernetes Environment**
```bash
# Create namespace
kubectl apply -f k8s/01-namespace.yaml

# Apply secrets
kubectl apply -f k8s/02-secrets.yaml

# Verify namespace and secrets
kubectl get namespaces
kubectl get secrets -n todo-app
```

**Step 2: Deploy Database Layer**
```bash
# Deploy MongoDB
kubectl apply -f k8s/mongodb/

# Deploy Redis
kubectl apply -f k8s/redis/

# Verify database deployments
kubectl get pods -n todo-app
kubectl get services -n todo-app
kubectl get pvc -n todo-app
```

**Step 3: Deploy Application Layer**
```bash
# Deploy backend
kubectl apply -f k8s/backend/

# Deploy frontend
kubectl apply -f k8s/frontend/

# Verify application deployments
kubectl get deployments -n todo-app
kubectl get pods -n todo-app -o wide
```

**Step 4: Setup Ingress**
```bash
# Deploy ingress
kubectl apply -f k8s/ingress/

# Verify ingress
kubectl get ingress -n todo-app
kubectl describe ingress todo-app-ingress -n todo-app
```

**Step 5: Test the Complete Application**
```bash
# Port forward for testing
kubectl port-forward service/frontend-service 8080:80 -n todo-app
kubectl port-forward service/backend-service 8081:5000 -n todo-app

# Test frontend
curl http://localhost:8080

# Test backend API
curl http://localhost:8081/health
curl http://localhost:8081/api/todos

# Check all pods are healthy
kubectl get pods -n todo-app
kubectl top pods -n todo-app
```

### **🔍 Advanced Features Implementation**

#### **Horizontal Pod Autoscaler**
```bash
# Create HPA for backend
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: todo-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF

# Monitor scaling
kubectl get hpa -n todo-app -w
```

#### **Network Policies**
```bash
# Create network policy for security
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: todo-app-network-policy
  namespace: todo-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  - from:
    - podSelector: {}
  egress:
  - to:
    - podSelector: {}
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF
```

### **🔧 Troubleshooting Guide**

#### **Common Issues and Solutions**

**Issue 1: Database Connection Problems**
```bash
# Check MongoDB pod logs
kubectl logs -l app=mongodb -n todo-app

# Test MongoDB connectivity
kubectl exec -it deployment/mongodb-deployment -n todo-app -- mongo --eval "db.adminCommand('ping')"

# Check service endpoints
kubectl get endpoints -n todo-app
```

**Issue 2: Backend API Not Responding**
```bash
# Check backend pod logs
kubectl logs -l app=backend -n todo-app

# Check environment variables
kubectl exec -it deployment/backend-deployment -n todo-app -- env

# Test backend health
kubectl exec -it deployment/backend-deployment -n todo-app -- curl http://localhost:5000/health
```

**Issue 3: Frontend Not Loading**
```bash
# Check frontend pod logs
kubectl logs -l app=frontend -n todo-app

# Check nginx configuration
kubectl exec -it deployment/frontend-deployment -n todo-app -- cat /etc/nginx/nginx.conf

# Test frontend directly
kubectl exec -it deployment/frontend-deployment -n todo-app -- curl http://localhost/
```

### **📊 Monitoring and Observability**

#### **Health Monitoring**
```bash
# Check overall application health
kubectl get pods -n todo-app
kubectl top pods -n todo-app
kubectl top nodes

# Monitor resource usage
kubectl describe node <node-name>

# Check service mesh (if using Istio)
kubectl get virtualservices -n todo-app
kubectl get destinationrules -n todo-app
```

#### **Performance Testing**
```bash
# Load test the application
kubectl run load-test --image=busybox -it --rm -- /bin/sh

# Inside the pod, install curl and run tests
apk add --no-cache curl
for i in $(seq 1 100); do
  curl -s http://backend-service.todo-app.svc.cluster.local:5000/health
done
```

### **🎯 Success Criteria**

**Project Completion Checklist:**
- ✅ All Docker images build successfully
- ✅ Docker Compose runs complete stack
- ✅ MongoDB stores and retrieves data
- ✅ Redis caching works correctly
- ✅ Backend API responds to requests
- ✅ Frontend loads and connects to API
- ✅ Real-time features work via WebSockets
- ✅ User authentication functions properly
- ✅ Kubernetes deployments are healthy
- ✅ Services route traffic correctly
- ✅ Ingress provides external access
- ✅ Auto-scaling responds to load
- ✅ Monitoring shows green status

**Performance Targets:**
- API response time <200ms
- Frontend load time <3 seconds
- Support 500+ concurrent users
- 99.5% uptime achieved
- Auto-scales based on CPU/memory usage
- Zero-downtime deployments

This moderate project demonstrates full-stack application deployment with microservices architecture, real-time features, and production-ready Kubernetes orchestration.
