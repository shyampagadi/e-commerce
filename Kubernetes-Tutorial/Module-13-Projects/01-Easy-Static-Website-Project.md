# 🌐 **Easy Project: Static Website Deployment**
## Professional Portfolio Website with Kubernetes

---

## 📋 **Project Requirements Document**

### **🎯 Project Overview**

**Client Request**: Deploy a professional portfolio website using modern DevOps practices with Docker containerization and Kubernetes orchestration.

**Business Objective**: Create a scalable, highly available static website that showcases professional skills and can handle traffic spikes during portfolio reviews.

### **📊 Functional Requirements**

#### **Core Features**
1. **Static Website Hosting**
   - Professional portfolio with HTML, CSS, JavaScript
   - Responsive design for mobile and desktop
   - Fast loading times (<2 seconds)
   - SEO optimized content

2. **Content Management**
   - About page with professional background
   - Projects showcase with screenshots
   - Skills and technologies section
   - Contact information and social links

3. **Performance Requirements**
   - 99.9% uptime availability
   - Support for 1000+ concurrent users
   - Global content delivery
   - Automatic SSL/TLS encryption

#### **Technical Requirements**

1. **Infrastructure**
   - Containerized deployment using Docker
   - Kubernetes orchestration for scalability
   - Load balancing for high availability
   - Health checks and monitoring

2. **Security**
   - HTTPS enforcement
   - Security headers implementation
   - Container security best practices
   - Network policies for isolation

3. **DevOps Integration**
   - CI/CD pipeline for automated deployment
   - Infrastructure as Code (IaC)
   - Monitoring and logging
   - Backup and disaster recovery

### **🔧 Technical Specifications**

#### **Technology Stack**
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla or Framework)
- **Web Server**: Nginx (Alpine Linux)
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Ingress**: Nginx Ingress Controller
- **SSL/TLS**: Let's Encrypt or cert-manager

#### **Architecture Requirements**
- **Deployment Pattern**: Rolling updates with zero downtime
- **Scaling**: Horizontal Pod Autoscaler (HPA)
- **Storage**: ConfigMaps for configuration
- **Networking**: ClusterIP services with Ingress
- **Monitoring**: Liveness and readiness probes

#### **Source Code References**
- **Primary**: https://github.com/startbootstrap/startbootstrap-resume
- **Alternative 1**: https://github.com/BlackrockDigital/startbootstrap-creative
- **Alternative 2**: https://github.com/cobidev/gatsby-simplefolio
- **Alternative 3**: https://github.com/RyanFitzgerald/devportfolio

---

## 🐳 **Docker Implementation**

### **Phase 1: Containerization Setup**

#### **Step 1: Project Structure**
```
portfolio-website/
├── src/
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── main.js
│   └── images/
├── nginx/
│   └── nginx.conf
├── Dockerfile
├── docker-compose.yml
└── README.md
```

#### **Step 2: Dockerfile Creation**

```dockerfile
# Multi-stage build for optimized production image
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy website files
COPY src/ /usr/share/nginx/html/

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

#### **Step 3: Nginx Configuration**

```nginx
# nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Performance optimizations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        
        # Main location
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        # Cache static assets
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

---

## ☸️ **Kubernetes Implementation**

### **Phase 2: Kubernetes Deployment**

#### **Step 1: Namespace and ConfigMap**

```yaml
# k8s/01-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: portfolio
  labels:
    name: portfolio
    environment: production
---
# ConfigMap for nginx configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: portfolio
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;
        
        sendfile on;
        keepalive_timeout 65;
        gzip on;
        
        server {
            listen 80;
            server_name _;
            root /usr/share/nginx/html;
            index index.html;
            
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-XSS-Protection "1; mode=block" always;
            
            location / {
                try_files $uri $uri/ /index.html;
            }
            
            location /health {
                access_log off;
                return 200 "healthy\n";
                add_header Content-Type text/plain;
            }
        }
    }
```

#### **Step 2: Deployment Configuration**

```yaml
# k8s/02-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portfolio-deployment
  namespace: portfolio
  labels:
    app: portfolio
    version: v1.0.0
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: portfolio
  template:
    metadata:
      labels:
        app: portfolio
        version: v1.0.0
    spec:
      containers:
      - name: portfolio
        image: portfolio-website:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
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
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
```

---

## 🛠️ **Complete Solution Guide**

### **Solution 1: Docker Implementation**

#### **Step-by-Step Docker Solution**

**Step 1: Download Source Code**
```bash
# Clone the portfolio template
git clone https://github.com/startbootstrap/startbootstrap-resume.git portfolio-website
cd portfolio-website

# Create necessary directories
mkdir -p nginx k8s
```

**Step 2: Create Dockerfile**
```bash
# Create optimized Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy website files
COPY . /usr/share/nginx/html/

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF
```

**Step 3: Build and Test**
```bash
# Build the image
docker build -t portfolio-website:v1.0.0 .

# Run the container
docker run -d -p 8080:80 --name portfolio-test portfolio-website:v1.0.0

# Test the application
curl http://localhost:8080
curl http://localhost:8080/health

# Clean up
docker stop portfolio-test && docker rm portfolio-test
```

### **Solution 2: Kubernetes Implementation**

#### **Step-by-Step Kubernetes Solution**

**Step 1: Deploy to Kubernetes**
```bash
# Create namespace
kubectl create namespace portfolio

# Deploy ConfigMap
kubectl apply -f k8s/01-namespace.yaml

# Deploy application
kubectl apply -f k8s/02-deployment.yaml

# Create service
kubectl expose deployment portfolio-deployment --port=80 --target-port=80 -n portfolio

# Test with port-forward
kubectl port-forward service/portfolio-deployment 8080:80 -n portfolio
```

### **🎯 Success Criteria**

**Project Completion Checklist:**
- ✅ Docker image builds successfully
- ✅ Container runs and serves website
- ✅ Kubernetes deployment is healthy
- ✅ Service routes traffic correctly
- ✅ Health checks are working
- ✅ Website loads in browser

This easy project provides a solid foundation for understanding Docker containerization and Kubernetes orchestration with a real-world static website deployment scenario.
