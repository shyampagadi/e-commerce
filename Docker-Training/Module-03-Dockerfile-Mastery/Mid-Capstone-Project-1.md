# Mid-Capstone Project 1: Multi-Tier Web Application
**Modules Combined**: 1 (Foundation) + 2 (Docker Fundamentals) + 3 (Dockerfile Mastery)

## Project Overview
Build a complete 3-tier web application using Docker containers with custom Dockerfiles, demonstrating mastery of Linux fundamentals, Docker operations, and Dockerfile optimization.

## Project Requirements

### Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   Database      │
│   (React/Nginx) │◄──►│   (Node.js)     │◄──►│   (PostgreSQL)  │
│   Port: 80      │    │   Port: 3000    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Technical Stack
- **Frontend**: React application served by Nginx
- **Backend**: Node.js Express API
- **Database**: PostgreSQL with initialization scripts
- **OS**: Linux containers (Alpine/Ubuntu)

## Module Integration Tasks

### Module 1 (Foundation) - 25 points
**Linux System Administration**
```bash
# 1. Container OS Management (5 points)
- Configure timezone and locale in containers
- Set up proper user management (non-root users)
- Implement file permissions and ownership
- Configure system logging

# 2. Network Configuration (5 points)
- Set up custom bridge networks
- Configure DNS resolution between containers
- Implement port mapping and firewall rules
- Test network connectivity

# 3. Process Management (5 points)
- Configure proper init systems in containers
- Implement graceful shutdown handling
- Monitor container processes
- Set up process limits and controls

# 4. File System Management (5 points)
- Configure volume mounts and permissions
- Implement log rotation
- Set up backup procedures
- Monitor disk usage

# 5. Security Hardening (5 points)
- Configure SSH access (if needed)
- Implement firewall rules
- Set up SSL/TLS certificates
- Configure security policies
```

### Module 2 (Docker Fundamentals) - 35 points
**Container Operations**
```bash
# 1. Image Management (10 points)
- Pull and manage base images
- Tag images with proper versioning
- Implement image cleanup procedures
- Use multi-architecture images

# 2. Container Lifecycle (10 points)
- Start/stop containers with proper commands
- Implement container restart policies
- Monitor container health and status
- Handle container logs and debugging

# 3. Volume Management (5 points)
- Create and manage named volumes
- Implement bind mounts for development
- Set up volume backups
- Monitor volume usage

# 4. Network Management (5 points)
- Create custom Docker networks
- Configure container communication
- Implement network isolation
- Test network connectivity

# 5. Docker Commands Mastery (5 points)
- Use advanced Docker CLI commands
- Implement container inspection
- Configure resource limits
- Use Docker system commands
```

### Module 3 (Dockerfile Mastery) - 40 points
**Custom Image Creation**
```dockerfile
# 1. Frontend Dockerfile (15 points)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine AS production
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
RUN adduser -D -s /bin/sh appuser
USER appuser
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# 2. Backend Dockerfile (15 points)
FROM node:18-alpine AS base
RUN apk add --no-cache dumb-init
WORKDIR /app
RUN adduser -D -s /bin/sh appuser

FROM base AS dependencies
COPY package*.json ./
RUN npm ci --only=production

FROM base AS production
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]

# 3. Database Dockerfile (10 points)
FROM postgres:15-alpine
COPY init-scripts/ /docker-entrypoint-initdb.d/
COPY postgresql.conf /etc/postgresql/postgresql.conf
RUN mkdir -p /var/lib/postgresql/backup
VOLUME ["/var/lib/postgresql/data", "/var/lib/postgresql/backup"]
EXPOSE 5432
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

## Implementation Tasks

### Phase 1: Environment Setup (20 points)
```bash
# 1. Linux Environment Preparation
- Set up development environment
- Configure Docker installation
- Set up project directory structure
- Configure development tools

# 2. Project Structure Creation
project/
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── src/
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── database/
│   ├── Dockerfile
│   ├── init-scripts/
│   └── postgresql.conf
└── scripts/
    ├── build.sh
    ├── deploy.sh
    └── test.sh
```

### Phase 2: Application Development (30 points)
```javascript
// Backend API (15 points)
const express = require('express');
const { Pool } = require('pg');

const app = express();
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'healthy', timestamp: new Date() });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

// CRUD endpoints
app.get('/api/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users');
  res.json(result.rows);
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});

// Frontend React App (15 points)
import React, { useState, useEffect } from 'react';

function App() {
  const [users, setUsers] = useState([]);
  const [health, setHealth] = useState(null);

  useEffect(() => {
    // Fetch health status
    fetch('/api/health')
      .then(res => res.json())
      .then(data => setHealth(data));

    // Fetch users
    fetch('/api/users')
      .then(res => res.json())
      .then(data => setUsers(data));
  }, []);

  return (
    <div>
      <h1>Multi-Tier Application</h1>
      <div>Health: {health?.status}</div>
      <div>Users: {users.length}</div>
    </div>
  );
}
```

### Phase 3: Container Orchestration (25 points)
```bash
#!/bin/bash
# build.sh - Build all containers

echo "Building multi-tier application..."

# Build frontend
docker build -t myapp-frontend:latest ./frontend

# Build backend
docker build -t myapp-backend:latest ./backend

# Build database
docker build -t myapp-database:latest ./database

echo "All images built successfully!"

# deploy.sh - Deploy application
#!/bin/bash
echo "Deploying application..."

# Create network
docker network create myapp-network

# Start database
docker run -d --name myapp-db \
  --network myapp-network \
  -e POSTGRES_DB=myapp \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=secret \
  -v myapp-db-data:/var/lib/postgresql/data \
  myapp-database:latest

# Wait for database
sleep 10

# Start backend
docker run -d --name myapp-api \
  --network myapp-network \
  -e DATABASE_URL=postgresql://appuser:secret@myapp-db:5432/myapp \
  myapp-backend:latest

# Start frontend
docker run -d --name myapp-web \
  --network myapp-network \
  -p 80:80 \
  myapp-frontend:latest

echo "Application deployed successfully!"
```

### Phase 4: Testing and Validation (25 points)
```bash
#!/bin/bash
# test.sh - Comprehensive testing

echo "Running application tests..."

# 1. Container Health Tests
echo "Testing container health..."
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Network Connectivity Tests
echo "Testing network connectivity..."
docker exec myapp-web ping -c 3 myapp-api
docker exec myapp-api ping -c 3 myapp-db

# 3. Application Functionality Tests
echo "Testing application endpoints..."
curl -f http://localhost/api/health || exit 1
curl -f http://localhost/api/users || exit 1

# 4. Database Connectivity Tests
echo "Testing database connectivity..."
docker exec myapp-db psql -U appuser -d myapp -c "SELECT version();"

# 5. Performance Tests
echo "Running performance tests..."
ab -n 100 -c 10 http://localhost/api/health

echo "All tests passed!"
```

## Deliverables

### 1. Source Code (40 points)
- Complete React frontend application
- Node.js Express backend API
- PostgreSQL database with initialization
- All source code properly organized

### 2. Dockerfiles (30 points)
- Optimized multi-stage Dockerfiles
- Security best practices implemented
- Non-root user configuration
- Proper layer caching

### 3. Scripts and Configuration (20 points)
- Build and deployment scripts
- Testing and validation scripts
- Configuration files (nginx.conf, postgresql.conf)
- Documentation and README

### 4. Documentation (10 points)
- Architecture documentation
- Setup and deployment instructions
- API documentation
- Troubleshooting guide

## Assessment Criteria

### Technical Implementation (60%)
- **Dockerfile Quality** (20%): Multi-stage builds, optimization, security
- **Application Architecture** (20%): Proper 3-tier separation, API design
- **Container Configuration** (20%): Networks, volumes, environment variables

### Integration Mastery (25%)
- **Module 1 Integration** (8%): Linux fundamentals in containers
- **Module 2 Integration** (8%): Docker operations and management
- **Module 3 Integration** (9%): Advanced Dockerfile techniques

### Professional Practices (15%)
- **Documentation** (5%): Clear, comprehensive documentation
- **Testing** (5%): Automated testing and validation
- **Code Quality** (5%): Clean, maintainable code

## Success Metrics
- All containers start successfully
- Application accessible via web browser
- API endpoints respond correctly
- Database connectivity working
- Health checks passing
- Performance benchmarks met

## Timeline: 5 Days
- **Day 1**: Environment setup and project structure
- **Day 2**: Frontend and backend development
- **Day 3**: Dockerfile creation and optimization
- **Day 4**: Container orchestration and deployment
- **Day 5**: Testing, documentation, and presentation

This capstone project demonstrates practical integration of the first three modules, combining Linux fundamentals, Docker operations, and Dockerfile mastery in a real-world application scenario.
