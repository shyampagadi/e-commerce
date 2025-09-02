# 🎯 Container Image Optimization

## 📋 Learning Objectives
By the end of this module, you will:
- **Understand** container image architecture and optimization principles
- **Master** advanced multi-stage build techniques and layer optimization
- **Implement** ultra-efficient images for e-commerce applications
- **Apply** security hardening and vulnerability reduction strategies
- **Achieve** production-ready image optimization skills

## 🎯 Real-World Context
Container image size directly impacts deployment speed, storage costs, and security surface area. E-commerce platforms benefit significantly from optimized images - faster deployments mean quicker response to traffic spikes, reduced storage costs, and improved security posture through minimal attack surfaces.

---

## 📚 Part 1: Image Optimization Fundamentals

### Understanding Container Images

**Image Layer Architecture:**
```bash
# Examine image layers
docker history nginx:alpine
docker inspect nginx:alpine | jq '.[0].RootFS.Layers'

# Analyze layer sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

**Layer Optimization Principles:**

**1. Layer Caching**
- Order instructions from least to most frequently changing
- Combine related operations in single RUN commands
- Use .dockerignore to exclude unnecessary files

**2. Layer Minimization**
- Reduce the number of layers
- Clean up package caches and temporary files
- Use multi-stage builds to exclude build dependencies

**3. Base Image Selection**
- Choose minimal base images (Alpine, distroless)
- Consider security and maintenance implications
- Balance size vs. functionality requirements

### Image Size Analysis

**Before and After Comparison:**
```dockerfile
# Dockerfile.unoptimized - Typical unoptimized image
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]

# Result: ~1.2GB image
```

```dockerfile
# Dockerfile.optimized - Optimized version
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
CMD ["node", "server.js"]

# Result: ~150MB image (87% reduction)
```

---

## 🔧 Part 2: Advanced Multi-Stage Builds

### E-Commerce Application Optimization

**Frontend Application (React):**
```dockerfile
# Dockerfile.frontend - Optimized React application
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html
# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
# Create non-root user
RUN addgroup -g 1001 -S nginx && adduser -S nginx -u 1001 -G nginx
# Set ownership
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run /var/log/nginx
USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

# Final size: ~25MB (vs 1.5GB unoptimized)
```

**Backend API (Node.js):**
```dockerfile
# Dockerfile.api - Optimized Node.js API
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

FROM node:18-alpine AS runtime
# Install security updates
RUN apk update && apk upgrade && apk add --no-cache dumb-init
# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
# Copy production dependencies and built application
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
USER nodejs
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]

# Final size: ~85MB (vs 1.2GB unoptimized)
```

### Distroless Images for Maximum Security

**Ultra-Minimal Go Application:**
```dockerfile
# Dockerfile.go-distroless - Distroless Go application
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/main /
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/main"]

# Final size: ~15MB (vs 800MB with full Go image)
```

---

## 🏗️ Part 3: E-Commerce Stack Optimization

### Complete Optimized Stack

**Database Optimization:**
```dockerfile
# Dockerfile.postgres - Optimized PostgreSQL
FROM postgres:15-alpine AS base
# Install only necessary extensions
RUN apk add --no-cache postgresql-contrib

FROM postgres:15-alpine AS runtime
# Copy extensions from base
COPY --from=base /usr/local/lib/postgresql/ /usr/local/lib/postgresql/
COPY --from=base /usr/local/share/postgresql/ /usr/local/share/postgresql/
# Custom configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf
# Health check script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD ["/usr/local/bin/healthcheck.sh"]

# Final size: ~230MB (vs 350MB standard postgres)
```

**Redis Optimization:**
```dockerfile
# Dockerfile.redis - Optimized Redis
FROM redis:7-alpine AS runtime
# Remove unnecessary packages
RUN apk del --purge \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
# Custom configuration
COPY redis.conf /usr/local/etc/redis/redis.conf
# Create non-root user
RUN addgroup -g 1001 -S redis && adduser -S redis -u 1001 -G redis
# Set ownership
RUN chown -R redis:redis /data /usr/local/etc/redis
USER redis
EXPOSE 6379
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]

# Final size: ~32MB (vs 45MB standard redis)
```

### Optimized Docker Compose

**Production-Ready Optimized Stack:**
```yaml
# docker-compose.optimized.yml
version: '3.8'

services:
  ecommerce-frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.optimized
    image: ecommerce/frontend:optimized
    ports:
      - "80:8080"
    deploy:
      resources:
        limits:
          memory: 64M
          cpus: '0.25'
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  ecommerce-api:
    build:
      context: ./api
      dockerfile: Dockerfile.optimized
    image: ecommerce/api:optimized
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://postgres:password@database:5432/ecommerce
      REDIS_URL: redis://cache:6379
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 15s
      timeout: 5s
      retries: 3

  database:
    build:
      context: ./database
      dockerfile: Dockerfile.postgres
    image: ecommerce/postgres:optimized
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  cache:
    build:
      context: ./cache
      dockerfile: Dockerfile.redis
    image: ecommerce/redis:optimized
    volumes:
      - redis_data:/data
    deploy:
      resources:
        limits:
          memory: 128M
          cpus: '0.25'

volumes:
  postgres_data:
  redis_data:
```

---

## 🔒 Part 4: Security Optimization

### Vulnerability Scanning and Hardening

**Security Scanning Pipeline:**
```bash
#!/bin/bash
# security-scan.sh - Comprehensive security scanning

echo "🔍 Starting security scan for e-commerce images..."

IMAGES=(
    "ecommerce/frontend:optimized"
    "ecommerce/api:optimized"
    "ecommerce/postgres:optimized"
    "ecommerce/redis:optimized"
)

# Install security scanning tools
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy scanner..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

# Scan each image
for image in "${IMAGES[@]}"; do
    echo "🔍 Scanning $image..."
    
    # Vulnerability scan
    trivy image --severity HIGH,CRITICAL --format table $image
    
    # Generate JSON report
    trivy image --severity HIGH,CRITICAL --format json --output "${image//\//_}-scan.json" $image
    
    # Check for secrets
    trivy image --scanners secret $image
    
    echo "✅ Scan completed for $image"
    echo "----------------------------------------"
done

echo "🎯 Security scan completed. Review reports for vulnerabilities."
```

**Hardened Base Images:**
```dockerfile
# Dockerfile.hardened - Security-hardened base
FROM alpine:3.18 AS hardened-base

# Update packages and remove package manager
RUN apk update && apk upgrade && apk add --no-cache ca-certificates tzdata \
    && rm -rf /var/cache/apk/* \
    && rm -rf /etc/apk

# Create non-root user
RUN addgroup -g 1001 -S appuser && adduser -S appuser -u 1001 -G appuser

# Remove unnecessary files and directories
RUN rm -rf /tmp/* /var/tmp/* \
    && rm -rf /usr/share/man/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /var/log/* \
    && rm -rf /root/.cache

# Set secure permissions
RUN chmod 755 /usr/bin/* \
    && chmod 755 /bin/* \
    && chmod 700 /root

FROM hardened-base AS application
WORKDIR /app
COPY --chown=appuser:appuser . .
USER appuser
```

### Secrets Management

**Secure Secrets Handling:**
```dockerfile
# Dockerfile.secrets - Secure secrets management
FROM node:18-alpine AS runtime

# Install secret management tools
RUN apk add --no-cache gnupg

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

WORKDIR /app

# Copy application files (excluding secrets)
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs src/ ./src/

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Switch to non-root user
USER nodejs

# Use secrets from Docker secrets or environment
EXPOSE 3000
CMD ["node", "src/server.js"]

# Secrets are mounted at runtime:
# docker run --secret source=db_password,target=/run/secrets/db_password app
```

---

## 📊 Part 5: Build Optimization

### Efficient Build Strategies

**Optimized Build Context:**
```bash
# .dockerignore - Exclude unnecessary files
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.git
.gitignore
README.md
.env
.nyc_output
coverage
.nyc_output
.coverage
.vscode
.idea
*.swp
*.swo
*~
.DS_Store
Thumbs.db
```

**Build Cache Optimization:**
```dockerfile
# Dockerfile.cache-optimized - Maximize build cache efficiency
FROM node:18-alpine AS dependencies

# Copy package files first (changes less frequently)
WORKDIR /app
COPY package*.json ./

# Install dependencies (cached if package.json unchanged)
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS development-dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM development-dependencies AS builder
# Copy source code (changes more frequently)
COPY . .
RUN npm run build

FROM dependencies AS runtime
# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Parallel Build Optimization

**Multi-Architecture Builds:**
```bash
#!/bin/bash
# build-multi-arch.sh - Build for multiple architectures

# Enable Docker buildx
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ecommerce/api:optimized \
  --push \
  .

# Build with cache optimization
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ecommerce/api:optimized \
  --cache-from type=registry,ref=ecommerce/api:cache \
  --cache-to type=registry,ref=ecommerce/api:cache,mode=max \
  --push \
  .
```

---

## 🧪 Part 6: Hands-On Optimization Labs

### Lab 1: Image Size Reduction Challenge

**Objective:** Reduce a Node.js application image by 80%

```dockerfile
# Before: Unoptimized Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
# Size: ~1.2GB

# After: Optimized Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs src/ ./src/
COPY --chown=nodejs:nodejs package*.json ./
USER nodejs
EXPOSE 3000
CMD ["node", "src/server.js"]
# Size: ~150MB (87% reduction)
```

### Lab 2: Security Hardening

**Objective:** Create a security-hardened container image

```dockerfile
# Dockerfile.secure - Security-hardened image
FROM alpine:3.18 AS base
RUN apk update && apk upgrade && apk add --no-cache ca-certificates
RUN addgroup -g 1001 -S appuser && adduser -S appuser -u 1001 -G appuser

FROM scratch AS runtime
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /etc/group /etc/group
COPY --chown=1001:1001 app /app
USER 1001:1001
ENTRYPOINT ["/app"]
# Final size: ~10MB with minimal attack surface
```

---

## 🎓 Module Summary

You've mastered container image optimization by learning:

**Core Concepts:**
- Image layer architecture and optimization principles
- Advanced multi-stage build techniques
- Security hardening and vulnerability reduction

**Practical Skills:**
- Creating ultra-efficient images for e-commerce applications
- Implementing comprehensive security scanning pipelines
- Optimizing build processes and caching strategies

**Enterprise Techniques:**
- Production-ready image optimization workflows
- Multi-architecture build strategies
- Automated security and compliance checking

**Next Steps:**
- Apply optimization techniques to your e-commerce images
- Implement automated security scanning in CI/CD
- Prepare for Module 9: Kernel-Level Container Tuning

---

## 📚 Additional Resources

- [Docker Multi-Stage Builds](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/)
- [Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [Trivy Security Scanner](https://trivy.dev/)
- [Container Security Best Practices](https://kubernetes.io/docs/concepts/security/)
FROM node:18-alpine AS node-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --no-audit --no-fund \
    && npm cache clean --force

# Stage 4: Frontend build
FROM node-builder AS frontend-build
COPY frontend/ ./frontend/
RUN cd frontend \
    && npm run build:production \
    && npm run optimize \
    && find dist -name "*.js" -exec gzip -9 {} \; -exec mv {}.gz {} \; \
    && find dist -name "*.css" -exec gzip -9 {} \; -exec mv {}.gz {} \;

# Stage 5: Backend build
FROM golang:1.21-alpine AS backend-build
WORKDIR /app
RUN apk add --no-cache git ca-certificates tzdata
COPY go.mod go.sum ./
RUN go mod download
COPY backend/ ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main ./cmd/server

# Stage 6: Security scanning and optimization
FROM alpine:3.18 AS security-scan
RUN apk add --no-cache trivy
COPY --from=backend-build /app/main /tmp/main
RUN trivy filesystem --exit-code 1 --no-progress /tmp/

# Stage 7: Final optimized image
FROM scratch AS final
# Copy CA certificates for HTTPS
COPY --from=backend-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Copy timezone data
COPY --from=backend-build /usr/share/zoneinfo /usr/share/zoneinfo
# Copy optimized binary
COPY --from=backend-build /app/main /main
# Copy optimized frontend assets
COPY --from=frontend-build /app/frontend/dist /static
# Create non-root user structure
COPY --from=alpine:3.18 /etc/passwd /etc/passwd
COPY --from=alpine:3.18 /etc/group /etc/group

USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/main"]
```

### Dynamic Layer Optimization
```python
#!/usr/bin/env python3
# image-optimizer.py - Advanced image optimization tool

import docker
import json
import hashlib
import os
import tempfile
import subprocess
from collections import defaultdict

class ImageOptimizer:
    def __init__(self):
        self.client = docker.from_env()
        self.layer_cache = {}
        self.optimization_stats = defaultdict(int)
        
    def analyze_image_layers(self, image_name):
        """Analyze image layers for optimization opportunities"""
        
        try:
            image = self.client.images.get(image_name)
            history = image.history()
            
            analysis = {
                'total_size': image.attrs['Size'],
                'layer_count': len(history),
                'layers': [],
                'optimization_opportunities': []
            }
            
            for i, layer in enumerate(history):
                layer_info = {
                    'id': layer.get('Id', 'missing'),
                    'size': layer.get('Size', 0),
                    'created_by': layer.get('CreatedBy', ''),
                    'comment': layer.get('Comment', ''),
                    'optimization_potential': 0
                }
                
                # Analyze layer for optimization opportunities
                layer_info['optimization_potential'] = self.analyze_layer_optimization(layer_info)
                analysis['layers'].append(layer_info)
                
            # Generate optimization recommendations
            analysis['optimization_opportunities'] = self.generate_optimization_recommendations(analysis)
            
            return analysis
            
        except Exception as e:
            print(f"Error analyzing image {image_name}: {e}")
            return None
            
    def analyze_layer_optimization(self, layer_info):
        """Analyze individual layer for optimization potential"""
        
        potential = 0
        created_by = layer_info['created_by'].lower()
        
        # Check for common optimization opportunities
        if 'apt-get update' in created_by and 'rm -rf /var/lib/apt/lists/*' not in created_by:
            potential += 30  # Missing apt cache cleanup
            
        if 'yum install' in created_by and 'yum clean all' not in created_by:
            potential += 25  # Missing yum cache cleanup
            
        if 'npm install' in created_by and 'npm cache clean' not in created_by:
            potential += 20  # Missing npm cache cleanup
            
        if 'wget' in created_by or 'curl' in created_by:
            if 'rm' not in created_by:
                potential += 15  # Downloaded files not cleaned up
                
        if layer_info['size'] > 100 * 1024 * 1024:  # > 100MB
            potential += 40  # Large layer that could be optimized
            
        return min(potential, 100)  # Cap at 100%
        
    def generate_optimization_recommendations(self, analysis):
        """Generate specific optimization recommendations"""
        
        recommendations = []
        
        # Check for large layers
        large_layers = [l for l in analysis['layers'] if l['size'] > 50 * 1024 * 1024]
        if large_layers:
            recommendations.append({
                'type': 'large_layers',
                'description': f"Found {len(large_layers)} layers > 50MB. Consider combining RUN commands.",
                'potential_savings': sum(l['size'] * 0.3 for l in large_layers),
                'priority': 'high'
            })
            
        # Check for cache cleanup opportunities
        cache_layers = [l for l in analysis['layers'] if l['optimization_potential'] > 20]
        if cache_layers:
            recommendations.append({
                'type': 'cache_cleanup',
                'description': f"Found {len(cache_layers)} layers with missing cache cleanup.",
                'potential_savings': sum(l['size'] * 0.4 for l in cache_layers),
                'priority': 'medium'
            })
            
        # Check layer count
        if analysis['layer_count'] > 20:
            recommendations.append({
                'type': 'layer_count',
                'description': f"Image has {analysis['layer_count']} layers. Consider reducing to < 15.",
                'potential_savings': analysis['total_size'] * 0.1,
                'priority': 'low'
            })
            
        return recommendations
        
    def optimize_image(self, image_name, optimization_config=None):
        """Optimize image using various techniques"""
        
        if not optimization_config:
            optimization_config = {
                'compress_layers': True,
                'remove_cache': True,
                'minimize_layers': True,
                'strip_binaries': True,
                'use_distroless': False
            }
            
        print(f"Optimizing image: {image_name}")
        
        # Analyze current image
        analysis = self.analyze_image_layers(image_name)
        if not analysis:
            return None
            
        # Generate optimized Dockerfile
        optimized_dockerfile = self.generate_optimized_dockerfile(image_name, analysis, optimization_config)
        
        # Build optimized image
        optimized_image_name = f"{image_name}-optimized"
        optimized_image = self.build_optimized_image(optimized_dockerfile, optimized_image_name)
        
        # Compare results
        comparison = self.compare_images(image_name, optimized_image_name)
        
        return {
            'original_image': image_name,
            'optimized_image': optimized_image_name,
            'optimization_config': optimization_config,
            'comparison': comparison,
            'dockerfile': optimized_dockerfile
        }
        
    def generate_optimized_dockerfile(self, image_name, analysis, config):
        """Generate optimized Dockerfile based on analysis"""
        
        # Extract base image and commands from original image
        original_image = self.client.images.get(image_name)
        
        dockerfile_lines = [
            "# Auto-generated optimized Dockerfile",
            f"FROM {self.get_base_image(original_image)} AS base",
            ""
        ]
        
        if config.get('use_distroless'):
            dockerfile_lines.extend([
                "# Multi-stage build for distroless optimization",
                "FROM base AS builder",
                ""
            ])
            
        # Add optimized RUN commands
        dockerfile_lines.extend(self.generate_optimized_run_commands(analysis, config))
        
        if config.get('use_distroless'):
            dockerfile_lines.extend([
                "",
                "# Final distroless stage",
                "FROM gcr.io/distroless/base-debian11",
                "COPY --from=builder /app /app",
                "WORKDIR /app",
                "ENTRYPOINT [\"/app/main\"]"
            ])
            
        return "\n".join(dockerfile_lines)
        
    def generate_optimized_run_commands(self, analysis, config):
        """Generate optimized RUN commands"""
        
        commands = []
        
        if config.get('remove_cache'):
            commands.append("# Optimized package installation with cache cleanup")
            commands.append("RUN apt-get update && apt-get install -y --no-install-recommends \\")
            commands.append("    package1 package2 package3 \\")
            commands.append("    && apt-get clean \\")
            commands.append("    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*")
            commands.append("")
            
        if config.get('compress_layers'):
            commands.append("# Compressed layer operations")
            commands.append("RUN set -ex \\")
            commands.append("    && operation1 \\")
            commands.append("    && operation2 \\")
            commands.append("    && cleanup_operation")
            commands.append("")
            
        if config.get('strip_binaries'):
            commands.append("# Strip binaries to reduce size")
            commands.append("RUN find /usr/local/bin -type f -executable -exec strip {} \\;")
            commands.append("")
            
        return commands
        
    def build_optimized_image(self, dockerfile_content, image_name):
        """Build optimized image from generated Dockerfile"""
        
        with tempfile.TemporaryDirectory() as temp_dir:
            dockerfile_path = os.path.join(temp_dir, 'Dockerfile')
            
            with open(dockerfile_path, 'w') as f:
                f.write(dockerfile_content)
                
            try:
                image, build_logs = self.client.images.build(
                    path=temp_dir,
                    tag=image_name,
                    rm=True,
                    forcerm=True,
                    pull=True
                )
                
                print(f"Successfully built optimized image: {image_name}")
                return image
                
            except Exception as e:
                print(f"Error building optimized image: {e}")
                return None
                
    def compare_images(self, original_name, optimized_name):
        """Compare original and optimized images"""
        
        try:
            original = self.client.images.get(original_name)
            optimized = self.client.images.get(optimized_name)
            
            original_size = original.attrs['Size']
            optimized_size = optimized.attrs['Size']
            
            size_reduction = original_size - optimized_size
            size_reduction_percent = (size_reduction / original_size) * 100
            
            comparison = {
                'original_size': original_size,
                'optimized_size': optimized_size,
                'size_reduction': size_reduction,
                'size_reduction_percent': size_reduction_percent,
                'original_layers': len(original.history()),
                'optimized_layers': len(optimized.history())
            }
            
            return comparison
            
        except Exception as e:
            print(f"Error comparing images: {e}")
            return None
            
    def get_base_image(self, image):
        """Extract base image from image history"""
        
        history = image.history()
        if history:
            # Get the last layer which should be the base
            base_layer = history[-1]
            created_by = base_layer.get('CreatedBy', '')
            
            # Try to extract FROM command
            if 'FROM' in created_by:
                parts = created_by.split()
                for i, part in enumerate(parts):
                    if part == 'FROM' and i + 1 < len(parts):
                        return parts[i + 1]
                        
        return "alpine:3.18"  # Default fallback
        
    def benchmark_image_performance(self, image_name, test_config=None):
        """Benchmark image performance metrics"""
        
        if not test_config:
            test_config = {
                'startup_iterations': 10,
                'memory_test_duration': 60,
                'io_test_size': '100M'
            }
            
        results = {
            'startup_times': [],
            'memory_usage': [],
            'io_performance': {},
            'image_name': image_name
        }
        
        # Test startup time
        print(f"Testing startup time for {image_name}...")
        for i in range(test_config['startup_iterations']):
            start_time = time.time()
            
            container = self.client.containers.run(
                image_name,
                command="echo 'ready'",
                detach=True,
                remove=True
            )
            
            container.wait()
            end_time = time.time()
            
            startup_time = (end_time - start_time) * 1000  # Convert to ms
            results['startup_times'].append(startup_time)
            
        # Calculate startup statistics
        results['startup_stats'] = {
            'mean': sum(results['startup_times']) / len(results['startup_times']),
            'min': min(results['startup_times']),
            'max': max(results['startup_times'])
        }
        
        # Test memory usage
        print(f"Testing memory usage for {image_name}...")
        container = self.client.containers.run(
            image_name,
            command="sleep 60",
            detach=True,
            remove=True
        )
        
        try:
            for i in range(test_config['memory_test_duration']):
                stats = container.stats(stream=False)
                memory_usage = stats['memory_stats']['usage']
                results['memory_usage'].append(memory_usage)
                time.sleep(1)
                
        finally:
            container.stop()
            
        # Calculate memory statistics
        if results['memory_usage']:
            results['memory_stats'] = {
                'mean': sum(results['memory_usage']) / len(results['memory_usage']),
                'peak': max(results['memory_usage']),
                'baseline': min(results['memory_usage'])
            }
            
        return results
        
    def create_optimization_report(self, image_name):
        """Create comprehensive optimization report"""
        
        print(f"Creating optimization report for {image_name}...")
        
        # Analyze image
        analysis = self.analyze_image_layers(image_name)
        
        # Optimize image
        optimization_result = self.optimize_image(image_name)
        
        # Benchmark performance
        original_benchmark = self.benchmark_image_performance(image_name)
        optimized_benchmark = None
        
        if optimization_result:
            optimized_benchmark = self.benchmark_image_performance(
                optimization_result['optimized_image']
            )
            
        report = {
            'image_name': image_name,
            'timestamp': time.time(),
            'analysis': analysis,
            'optimization_result': optimization_result,
            'performance_comparison': {
                'original': original_benchmark,
                'optimized': optimized_benchmark
            },
            'recommendations': self.generate_final_recommendations(
                analysis, optimization_result, original_benchmark, optimized_benchmark
            )
        }
        
        return report
        
    def generate_final_recommendations(self, analysis, optimization_result, 
                                     original_benchmark, optimized_benchmark):
        """Generate final optimization recommendations"""
        
        recommendations = []
        
        if optimization_result and optimization_result['comparison']:
            size_reduction = optimization_result['comparison']['size_reduction_percent']
            
            if size_reduction > 50:
                recommendations.append({
                    'type': 'excellent_optimization',
                    'message': f"Excellent optimization achieved: {size_reduction:.1f}% size reduction"
                })
            elif size_reduction > 20:
                recommendations.append({
                    'type': 'good_optimization',
                    'message': f"Good optimization achieved: {size_reduction:.1f}% size reduction"
                })
            else:
                recommendations.append({
                    'type': 'limited_optimization',
                    'message': f"Limited optimization: {size_reduction:.1f}% size reduction. Consider advanced techniques."
                })
                
        if optimized_benchmark and original_benchmark:
            startup_improvement = (
                (original_benchmark['startup_stats']['mean'] - 
                 optimized_benchmark['startup_stats']['mean']) /
                original_benchmark['startup_stats']['mean'] * 100
            )
            
            if startup_improvement > 0:
                recommendations.append({
                    'type': 'performance_improvement',
                    'message': f"Startup time improved by {startup_improvement:.1f}%"
                })
                
        return recommendations

def main():
    optimizer = ImageOptimizer()
    
    # Example usage
    image_name = "nginx:latest"  # Replace with your image
    
    # Create comprehensive optimization report
    report = optimizer.create_optimization_report(image_name)
    
    # Save report
    with open(f'optimization_report_{image_name.replace(":", "_")}.json', 'w') as f:
        json.dump(report, f, indent=2, default=str)
        
    print("Optimization report generated successfully!")
    
    # Print summary
    if report['optimization_result']:
        comparison = report['optimization_result']['comparison']
        print(f"\nOptimization Summary:")
        print(f"Original size: {comparison['original_size'] / 1024 / 1024:.1f} MB")
        print(f"Optimized size: {comparison['optimized_size'] / 1024 / 1024:.1f} MB")
        print(f"Size reduction: {comparison['size_reduction_percent']:.1f}%")

if __name__ == "__main__":
    main()
```
