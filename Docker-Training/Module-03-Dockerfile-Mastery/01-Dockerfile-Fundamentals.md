# Dockerfile Fundamentals

## Learning Objectives
- Understand Dockerfile syntax and instructions
- Build custom Docker images
- Master layer optimization techniques
- Create production-ready images

## What is a Dockerfile?

A Dockerfile is a text file containing instructions to build a Docker image automatically. Think of it as a recipe for creating your custom image.

### Basic Structure
```dockerfile
# Comments start with #
FROM base-image
INSTRUCTION arguments
INSTRUCTION arguments
...
```

## Essential Dockerfile Instructions

### FROM - Base Image
```dockerfile
# Use official images when possible
FROM ubuntu:20.04
FROM node:16-alpine
FROM nginx:alpine

# Multi-stage builds (advanced)
FROM node:16 AS builder
FROM nginx:alpine AS production
```

### WORKDIR - Set Working Directory
```dockerfile
# Set working directory (creates if doesn't exist)
WORKDIR /app
WORKDIR /usr/src/app
WORKDIR /var/www/html
```

### COPY and ADD - Add Files
```dockerfile
# COPY (preferred for simple file copying)
COPY package.json .
COPY src/ ./src/
COPY . .

# ADD (has additional features like URL download and tar extraction)
ADD https://example.com/file.tar.gz /tmp/
ADD archive.tar.gz /opt/
```

### RUN - Execute Commands
```dockerfile
# Install packages
RUN apt-get update && apt-get install -y \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Multiple commands in one RUN (reduces layers)
RUN npm install && \
    npm run build && \
    npm cache clean --force
```

### ENV - Environment Variables
```dockerfile
# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV DATABASE_URL=postgresql://localhost:5432/mydb
```

### EXPOSE - Document Ports
```dockerfile
# Document which ports the container listens on
EXPOSE 80
EXPOSE 3000
EXPOSE 8080 8443
```

### CMD and ENTRYPOINT - Default Commands
```dockerfile
# CMD - default command (can be overridden)
CMD ["nginx", "-g", "daemon off;"]
CMD ["node", "server.js"]
CMD ["python", "app.py"]

# ENTRYPOINT - always executed (not overridden)
ENTRYPOINT ["docker-entrypoint.sh"]
ENTRYPOINT ["python", "app.py"]

# Combined usage
ENTRYPOINT ["python", "app.py"]
CMD ["--help"]  # default argument
```

## Hands-On Exercise 1: Your First Dockerfile

Let's create a simple Node.js application:

```bash
# 1. Create project directory
mkdir ~/my-first-dockerfile
cd ~/my-first-dockerfile

# 2. Create a simple Node.js app
cat > app.js << 'EOF'
const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        message: 'Hello from Docker!',
        hostname: os.hostname(),
        platform: os.platform(),
        nodeVersion: process.version,
        timestamp: new Date().toISOString()
    }, null, 2));
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
EOF

# 3. Create package.json
cat > package.json << 'EOF'
{
    "name": "my-docker-app",
    "version": "1.0.0",
    "description": "My first Docker application",
    "main": "app.js",
    "scripts": {
        "start": "node app.js"
    },
    "dependencies": {}
}
EOF

# 4. Create Dockerfile
cat > Dockerfile << 'EOF'
# Use official Node.js runtime as base image
FROM node:16-alpine

# Set working directory in container
WORKDIR /usr/src/app

# Copy package.json first (for better caching)
COPY package.json .

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Define default command
CMD ["npm", "start"]
EOF

# 5. Build the image
docker build -t my-first-app .

# 6. Run the container
docker run -d -p 3000:3000 --name my-app my-first-app

# 7. Test the application
curl http://localhost:3000

# 8. Clean up
docker stop my-app
docker rm my-app
```

## Understanding Build Context

### What is Build Context?
The build context is the set of files and directories sent to Docker daemon during build.

```bash
# Current directory is build context
docker build .

# Specific directory as build context
docker build /path/to/context

# URL as build context
docker build https://github.com/user/repo.git
```

### .dockerignore File
```bash
# Create .dockerignore to exclude files
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
*.md
EOF
```

## Layer Optimization Techniques

### Bad Example (Many Layers)
```dockerfile
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get install -y git
RUN rm -rf /var/lib/apt/lists/*
```

### Good Example (Fewer Layers)
```dockerfile
FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y \
        curl \
        vim \
        git && \
    rm -rf /var/lib/apt/lists/*
```

### Hands-On Exercise 2: Layer Optimization

```bash
# 1. Create inefficient Dockerfile
mkdir ~/layer-optimization
cd ~/layer-optimization

cat > Dockerfile.bad << 'EOF'
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get install -y git
RUN rm -rf /var/lib/apt/lists/*
COPY app.py .
RUN chmod +x app.py
EOF

# 2. Create optimized Dockerfile
cat > Dockerfile.good << 'EOF'
FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim \
        git && \
    rm -rf /var/lib/apt/lists/*
COPY app.py .
RUN chmod +x app.py
EOF

# 3. Create dummy app
echo 'print("Hello from Python!")' > app.py

# 4. Build both and compare
docker build -f Dockerfile.bad -t bad-layers .
docker build -f Dockerfile.good -t good-layers .

# 5. Compare layer count
docker history bad-layers
echo "---"
docker history good-layers

# 6. Compare sizes
docker images | grep -E "(bad-layers|good-layers)"

# 7. Clean up
docker rmi bad-layers good-layers
```

## Advanced Dockerfile Techniques

### Multi-Stage Builds
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:16-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Build Arguments
```dockerfile
# Define build arguments
ARG NODE_VERSION=16
ARG APP_ENV=production

FROM node:${NODE_VERSION}-alpine
ENV NODE_ENV=${APP_ENV}

# Use during build
RUN echo "Building for environment: ${APP_ENV}"
```

### Health Checks
```dockerfile
# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1
```

## Hands-On Exercise 3: Production-Ready Dockerfile

Let's create a production-ready web application:

```bash
# 1. Create project structure
mkdir ~/production-dockerfile
cd ~/production-dockerfile
mkdir src public

# 2. Create Express.js application
cat > package.json << 'EOF'
{
    "name": "production-app",
    "version": "1.0.0",
    "description": "Production-ready Docker app",
    "main": "src/server.js",
    "scripts": {
        "start": "node src/server.js",
        "dev": "nodemon src/server.js"
    },
    "dependencies": {
        "express": "^4.18.0"
    },
    "devDependencies": {
        "nodemon": "^2.0.0"
    }
}
EOF

# 3. Create server
cat > src/server.js << 'EOF'
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files
app.use(express.static('public'));

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API endpoint
app.get('/api/info', (req, res) => {
    res.json({
        app: 'Production Docker App',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        hostname: require('os').hostname()
    });
});

// Serve index.html for root
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF

# 4. Create HTML file
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Production Docker App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { background: #e8f5e8; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Production Docker Application</h1>
        <div class="status">
            <h3>Application Status</h3>
            <p>✅ Application is running successfully</p>
            <p>🐳 Containerized with Docker</p>
            <p>🚀 Production-ready configuration</p>
        </div>
        <h3>API Endpoints</h3>
        <ul>
            <li><a href="/health">/health</a> - Health check</li>
            <li><a href="/api/info">/api/info</a> - Application info</li>
        </ul>
    </div>
</body>
</html>
EOF

# 5. Create production Dockerfile
cat > Dockerfile << 'EOF'
# Multi-stage build for production
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm ci

# Copy source code
COPY . .

# Production stage
FROM node:16-alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/src ./src
COPY --from=builder --chown=nodejs:nodejs /app/public ./public

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
EOF

# 6. Create .dockerignore
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log*
.git
.gitignore
README.md
.env
.nyc_output
coverage
.DS_Store
*.md
EOF

# 7. Build and run
docker build -t production-app .
docker run -d -p 3000:3000 --name prod-app production-app

# 8. Test the application
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/api/info

# 9. Check health status
docker ps  # should show healthy status

# 10. Clean up
docker stop prod-app
docker rm prod-app
```

## Dockerfile Best Practices

### Security Best Practices
```dockerfile
# 1. Use specific base image versions
FROM node:16.14.2-alpine

# 2. Create and use non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# 3. Use COPY instead of ADD
COPY package.json .

# 4. Don't store secrets in images
# Use environment variables or secrets management
```

### Performance Best Practices
```dockerfile
# 1. Order layers by change frequency
FROM node:16-alpine
WORKDIR /app

# Dependencies change less frequently
COPY package*.json ./
RUN npm ci --only=production

# Source code changes more frequently
COPY . .

# 2. Minimize layer count
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    rm -rf /var/lib/apt/lists/*

# 3. Use .dockerignore
# Exclude unnecessary files from build context
```

### Maintainability Best Practices
```dockerfile
# 1. Use meaningful labels
LABEL maintainer="your-email@example.com"
LABEL version="1.0.0"
LABEL description="Production web application"

# 2. Document exposed ports
EXPOSE 3000

# 3. Use environment variables for configuration
ENV NODE_ENV=production
ENV PORT=3000

# 4. Add health checks
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:3000/health || exit 1
```

## Common Dockerfile Patterns

### Node.js Application
```dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
USER node
CMD ["npm", "start"]
```

### Python Application
```dockerfile
FROM python:3.9-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
USER 1000
CMD ["python", "app.py"]
```

### Static Website
```dockerfile
FROM nginx:alpine
COPY public/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Troubleshooting Dockerfile Builds

### Common Issues and Solutions

#### Build Fails at RUN Command
```bash
# Debug by running intermediate container
docker run -it <intermediate-image-id> bash

# Or build with --no-cache
docker build --no-cache -t myapp .
```

#### Large Image Size
```bash
# Check layer sizes
docker history myapp

# Use multi-stage builds
# Use alpine base images
# Clean up in same RUN command
```

#### Permission Issues
```bash
# Check file ownership
docker run -it myapp ls -la

# Fix with proper COPY --chown
COPY --chown=user:group . .
```

## Practice Challenges

### Challenge 1: Optimize an Image
Take a large, inefficient Dockerfile and optimize it for size and build speed.

### Challenge 2: Multi-Stage Build
Create a multi-stage build for a compiled language (Go, Java, etc.).

### Challenge 3: Security Hardening
Create a Dockerfile following all security best practices.

### Challenge 4: Build Arguments
Create a flexible Dockerfile that can build different variants using build arguments.

## Next Steps

You now understand Dockerfile fundamentals:
- ✅ Dockerfile syntax and instructions
- ✅ Layer optimization techniques
- ✅ Multi-stage builds
- ✅ Security and performance best practices
- ✅ Common patterns and troubleshooting

**Ready for the next part: Nginx Configuration** where you'll learn to configure web servers in containers!
