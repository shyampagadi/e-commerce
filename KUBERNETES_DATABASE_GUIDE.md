# Kubernetes Database Setup Guide

## Docker to Kubernetes Migration Issues & Solutions

### Issues Encountered in Docker Setup

#### Issue 1: Nginx Permission Problems
**Problem**: Frontend container kept restarting with permission denied errors
```
nginx: [emerg] open() "/var/run/nginx.pid" failed (13: Permission denied)
```

**Root Cause**: Dockerfile was trying to run nginx as non-root user (`nginx-user`) but nginx needs root privileges to:
- Write PID files to `/var/run/nginx.pid`
- Bind to port 80
- Access system directories

**Fix Applied**: 
- Removed `USER nginx-user` directive
- Removed unnecessary user creation commands
- Let nginx run as root (standard for containers)

#### Issue 2: Port Mapping Mismatch
**Problem**: `localhost:3000` returned `ERR_EMPTY_RESPONSE`

**Root Cause**: Docker Compose port mapping was incorrect:
- **Configured**: `3000:3000` (host:container)
- **Reality**: Nginx runs on port 80 inside container
- **Result**: Traffic to localhost:3000 went to container port 3000 (nothing listening)

**Fix Applied**: 
- Changed port mapping from `"3000:3000"` to `"3000:80"`
- Now localhost:3000 correctly routes to nginx on container port 80

### Key Lessons for Kubernetes:

1. **Container Ports vs Service Ports**: Always verify what port your application actually runs on inside the container

2. **Security vs Functionality**: Running as non-root is more secure but requires proper permission setup. For development, root is often simpler.

3. **Port Mapping**: In Kubernetes, you'll define:
   ```yaml
   ports:
   - containerPort: 80  # What nginx actually listens on
   - port: 3000         # What the service exposes
   ```

4. **Health Checks**: The health check was working (curl to port 80) but external access failed due to wrong port mapping

## Using Docker Images in Kubernetes

### Step 1: Tag and Push Images to Registry

```bash
# Tag your images
docker tag e-commerce-backend:latest your-registry/e-commerce-backend:latest
docker tag e-commerce-frontend:latest your-registry/e-commerce-frontend:latest

# Push to registry (Docker Hub, ECR, etc.)
docker push your-registry/e-commerce-backend:latest
docker push your-registry/e-commerce-frontend:latest
```

### Step 2: Create Kubernetes Manifests

**Frontend Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
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
        image: your-registry/e-commerce-frontend:latest
        ports:
        - containerPort: 80  # Nginx runs on port 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 3000      # External port
    targetPort: 80  # Container port (nginx)
  type: LoadBalancer
```

**Backend Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
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
        image: your-registry/e-commerce-backend:latest
        ports:
        - containerPort: 8000  # FastAPI runs on 8000
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:admin@postgres-service:5432/ecommerce_db"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
```

### Step 3: Deploy

```bash
kubectl apply -f frontend-deployment.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f postgres-deployment.yaml  # You'll need this too
```

### Key Differences from Docker Compose:

1. **Image Registry**: Must push images to accessible registry
2. **Port Mapping**: Use `port` (service) and `targetPort` (container)
3. **Environment Variables**: Define in deployment spec
4. **Networking**: Services handle internal communication
5. **Scaling**: Set `replicas` for horizontal scaling

## Database Setup in Kubernetes - NOOB Guide

### Step 1: Create PostgreSQL Database

Create `postgres.yaml`:
```yaml
# This creates the PostgreSQL database
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
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
        image: postgres:17.6-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "ecommerce_db"
        - name: POSTGRES_USER
          value: "postgres"
        - name: POSTGRES_PASSWORD
          value: "admin"
---
# This makes the database accessible to other pods
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

### Step 2: Create Database Setup Image (Recommended for Large Files)

**Option A: Build Custom Image with setup.py**

Create `Dockerfile.db-setup`:
```dockerfile
FROM python:3.11-alpine

# Install dependencies
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

# Copy your setup script
COPY database/setup.py /app/setup.py
COPY database/ /app/database/

# Set executable permissions
RUN chmod +x /app/setup.py

CMD ["python", "setup.py", "--all"]
```

Build and push the image:
```bash
# Build the database setup image
docker build -f Dockerfile.db-setup -t your-registry/db-setup:latest .

# Push to registry
docker push your-registry/db-setup:latest
```

**Option B: Use Init Container with Volume Mount**

Create `db-setup-pvc.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: setup-scripts-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: copy-setup-scripts
spec:
  template:
    spec:
      containers:
      - name: copy-scripts
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          # This would copy from a mounted source or download from git
          echo "Copy your setup.py and related files here"
          # Example: wget https://raw.githubusercontent.com/your-repo/main/database/setup.py
        volumeMounts:
        - name: setup-scripts
          mountPath: /scripts
      volumes:
      - name: setup-scripts
        persistentVolumeClaim:
          claimName: setup-scripts-pvc
      restartPolicy: OnFailure
```

**Option C: Use Git Clone in Init Container**

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup
spec:
  template:
    spec:
      initContainers:
      - name: git-clone
        image: alpine/git
        command:
        - /bin/sh
        - -c
        - |
          git clone https://github.com/your-username/e-commerce.git /repo
          cp -r /repo/database/* /app/
        volumeMounts:
        - name: setup-scripts
          mountPath: /app
      containers:
      - name: db-setup
        image: python:3.11-alpine
        command:
        - /bin/sh
        - -c
        - |
          cd /app
          pip install psycopg2-binary
          python setup.py --all
        volumeMounts:
        - name: setup-scripts
          mountPath: /app
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:admin@postgres-service:5432/ecommerce_db"
      volumes:
      - name: setup-scripts
        emptyDir: {}
      restartPolicy: OnFailure
```

### Step 3: Create Job to Run setup.py

**Using Custom Image (Recommended):**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup
spec:
  template:
    spec:
      containers:
      - name: db-setup
        image: your-registry/db-setup:latest  # Your custom image
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:admin@postgres-service:5432/ecommerce_db"
      restartPolicy: OnFailure
```

**Using Git Clone Approach:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup
spec:
  template:
    spec:
      initContainers:
      - name: git-clone
        image: alpine/git
        command:
        - /bin/sh
        - -c
        - |
          git clone https://github.com/your-username/e-commerce.git /repo
          cp -r /repo/database/* /app/
        volumeMounts:
        - name: setup-scripts
          mountPath: /app
      containers:
      - name: db-setup
        image: python:3.11-alpine
        command:
        - /bin/sh
        - -c
        - |
          cd /app
          pip install -r requirements.txt
          python setup.py --all
        volumeMounts:
        - name: setup-scripts
          mountPath: /app
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:admin@postgres-service:5432/ecommerce_db"
      volumes:
      - name: setup-scripts
        emptyDir: {}
      restartPolicy: OnFailure
```

### Step 4: Deploy Everything

**Using Custom Image Approach:**
```bash
# 1. Build and push your database setup image
docker build -f Dockerfile.db-setup -t your-registry/db-setup:latest .
docker push your-registry/db-setup:latest

# 2. Deploy PostgreSQL
kubectl apply -f postgres.yaml

# 3. Wait for postgres to be ready
kubectl wait --for=condition=ready pod -l app=postgres --timeout=60s

# 4. Run the database setup
kubectl apply -f db-setup-job.yaml

# 5. Check if setup completed
kubectl logs job/db-setup
```

**Using Git Clone Approach:**
```bash
# 1. Make sure your code is pushed to GitHub/GitLab
git push origin main

# 2. Deploy PostgreSQL
kubectl apply -f postgres.yaml

# 3. Wait for postgres to be ready
kubectl wait --for=condition=ready pod -l app=postgres --timeout=60s

# 4. Run the database setup (it will clone your repo)
kubectl apply -f db-setup-job.yaml

# 5. Check if setup completed
kubectl logs job/db-setup
```

### What Happens:

1. **PostgreSQL starts** → Empty database created
2. **ConfigMap created** → Your setup.py script stored in Kubernetes
3. **Job runs** → Downloads Python, installs dependencies, runs your setup.py
4. **Database initialized** → Tables, data, everything ready
5. **Your apps connect** → Backend connects to initialized database

### Recommended Approach for Large Files:

**Option 1: Custom Docker Image (Best for Production)**
- Build image with your setup.py included
- Version your database setup scripts
- Faster deployment (no file copying)

**Option 2: Git Clone (Best for Development)**
- Always uses latest code from your repository
- No need to rebuild images for script changes
- Requires public repo or proper git credentials

**Option 3: ConfigMap (Only for Small Scripts)**
- Good for simple, small setup scripts
- Not recommended for large files (1MB limit)
- Difficult to maintain large scripts in YAML

## Production-Grade Database Solution

### What You DON'T Do in Production:
❌ Run PostgreSQL as a container in Kubernetes  
❌ Store data inside pods (data loss when pod restarts)  
❌ Use plain text passwords  
❌ Single database instance (no backup/failover)  

### What You DO in Production:

### 1. Managed Database Service
```yaml
# Instead of PostgreSQL container, use:
# - AWS RDS PostgreSQL
# - Google Cloud SQL
# - Azure Database for PostgreSQL
# - DigitalOcean Managed Database

# Your backend connects to external managed DB:
env:
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: connection-string
```

### 2. Secrets Management
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  connection-string: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0BkYi5hd3MuY29tOjU0MzIvZGI=  # base64 encoded
  username: dXNlcg==  # base64 encoded
  password: cGFzcw==  # base64 encoded
```

### 3. Database Migration Strategy
```yaml
# Use Helm hooks or init containers for DB setup
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migrate
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-1"
spec:
  template:
    spec:
      initContainers:
      - name: wait-for-db
        image: postgres:alpine
        command: ['sh', '-c', 'until pg_isready -h $DB_HOST; do sleep 1; done']
      containers:
      - name: migrate
        image: your-registry/db-migrator:latest
        command: ["python", "migrate.py"]
```

### 4. High Availability Setup
```yaml
# Multiple replicas with proper resource limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3  # Multiple instances
  template:
    spec:
      containers:
      - name: backend
        image: your-registry/backend:v1.2.3  # Versioned images
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
```

### 5. Infrastructure as Code
```yaml
# Use Helm Charts or Terraform
# helm/values.yaml
database:
  host: "prod-db.cluster-xyz.us-east-1.rds.amazonaws.com"
  port: 5432
  name: "ecommerce_prod"
  
image:
  repository: "your-registry/backend"
  tag: "v1.2.3"
  
resources:
  requests:
    memory: 256Mi
    cpu: 200m
  limits:
    memory: 512Mi
    cpu: 500m
```

### 6. Monitoring & Observability
```yaml
# Prometheus monitoring
apiVersion: v1
kind: Service
metadata:
  name: backend
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8000"
    prometheus.io/path: "/metrics"
```

### Key Production Principles:

1. **Externalize Data**: Database runs outside Kubernetes
2. **Zero Downtime**: Rolling updates, health checks
3. **Security**: Secrets, RBAC, network policies
4. **Observability**: Logging, metrics, tracing
5. **Automation**: CI/CD, infrastructure as code
6. **Disaster Recovery**: Backups, multi-region

### Your Learning Path:
1. **Now**: Container PostgreSQL (learning)
2. **Next**: Managed database + proper secrets
3. **Advanced**: Full production setup with monitoring

The managed database handles backups, updates, scaling, and high availability for you!

## Database Options for Kubernetes

### Option 1: Use Existing PostgreSQL Image (Recommended for Learning)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
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
        image: postgres:17.6-alpine  # Same as docker-compose
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "ecommerce_db"
        - name: POSTGRES_USER
          value: "postgres"
        - name: POSTGRES_PASSWORD
          value: "admin"
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Option 2: Database Initialization Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup
spec:
  template:
    spec:
      containers:
      - name: db-setup
        image: python:3.11-alpine
        command: ["python", "/app/setup.py", "--all"]
        volumeMounts:
        - name: setup-script
          mountPath: /app
        env:
        - name: DATABASE_URL
          value: "postgresql://postgres:admin@postgres-service:5432/ecommerce_db"
      volumes:
      - name: setup-script
        configMap:
          name: db-setup-script
      restartPolicy: OnFailure
```

### Option 3: Use Managed Database (Production)

For production, use cloud managed databases:
- **AWS**: RDS PostgreSQL
- **GCP**: Cloud SQL
- **Azure**: Database for PostgreSQL

Then just update your backend environment:
```yaml
env:
- name: DATABASE_URL
  value: "postgresql://user:pass@your-managed-db:5432/ecommerce_db"
```

### Recommended Approach:
1. Start with **Option 1** (PostgreSQL container) for learning
2. Use **Option 2** for database initialization
3. Move to **Option 3** for production

The key difference from Docker Compose: you need **PersistentVolumes** for data persistence in Kubernetes!
