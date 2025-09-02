# 🐳 Docker Build Optimization: Advanced Container Strategies

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** multi-stage Docker builds and layer optimization
- **Implement** advanced caching strategies for faster builds
- **Configure** registry integration and image management
- **Build** optimized containers for production deployment
- **Optimize** build performance and reduce image sizes

## 🎯 Real-World Context
Docker build optimization is crucial for CI/CD performance. Companies like Netflix and Uber have reduced build times from 45 minutes to under 5 minutes using advanced optimization techniques, saving thousands of developer hours monthly.

---

## 🏗️ Multi-Stage Build Mastery

### **Basic Multi-Stage Pattern**

```dockerfile
# Dockerfile.optimized
# Stage 1: Build environment
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY src/ ./src/
COPY public/ ./public/
COPY tsconfig.json ./

# Build application
RUN npm run build

# Stage 2: Production environment
FROM node:18-alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# Switch to non-root user
USER nextjs

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

### **Advanced Multi-Stage with Dependencies**

```dockerfile
# Dockerfile.advanced
# Stage 1: Base dependencies
FROM node:18-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package*.json ./

# Stage 2: Development dependencies
FROM base AS deps
RUN npm ci

# Stage 3: Build stage
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 4: Production dependencies only
FROM base AS prod-deps
RUN npm ci --only=production && npm cache clean --force

# Stage 5: Runtime
FROM node:18-alpine AS runtime
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

WORKDIR /app

COPY --from=prod-deps --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

USER nextjs

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "dist/server.js"]
```

---

## ⚡ GitHub Actions Docker Optimization

### **Basic Docker Build Workflow**

```yaml
# .github/workflows/optimized-docker-build.yml
# ↑ Workflow for optimized Docker container builds
# Focuses on build speed, caching, and efficient image creation

name: Optimized Docker Build
# ↑ Descriptive name for Docker build optimization workflow

on:
  # ↑ Defines when Docker builds should execute
  push:
    # ↑ Runs when code is pushed to repository
    branches: [main, develop]
    # ↑ Only builds for main and develop branches
    # Avoids building containers for every feature branch
  pull_request:
    # ↑ Runs on pull requests for testing container builds
    branches: [main]
    # ↑ Only for PRs targeting main branch

env:
  # ↑ Environment variables available to all jobs
  REGISTRY: ghcr.io
  # ↑ GitHub Container Registry (ghcr.io) for storing images
  # Free for public repositories, integrated with GitHub
  IMAGE_NAME: ${{ github.repository }}
  # ↑ Uses repository name as image name (e.g., "owner/repo-name")
  # ${{ github.repository }} automatically provides this

jobs:
  # ↑ Section defining workflow jobs
  build:
    # ↑ Job name for Docker build process
    runs-on: ubuntu-latest
    # ↑ Uses Ubuntu virtual machine (good Docker support)
    
    steps:
      # ↑ Sequential tasks within the build job
      - name: Checkout
        # ↑ Downloads repository source code and Dockerfile
        uses: actions/checkout@v4
        # ↑ Official GitHub action for code checkout
        
      - name: Set up Docker Buildx
        # ↑ Enables advanced Docker build features
        uses: docker/setup-buildx-action@v3
        # ↑ Docker Buildx provides:
        # - Multi-platform builds (ARM, x86)
        # - Advanced caching mechanisms
        # - Build optimization features
        # - Remote builder support
        
      - name: Log in to Container Registry
        # ↑ Authenticates with GitHub Container Registry
        uses: docker/login-action@v3
        # ↑ Official Docker action for registry authentication
        with:
          # ↑ Parameters for registry login
          registry: ${{ env.REGISTRY }}
          # ↑ Registry URL (ghcr.io for GitHub Container Registry)
          username: ${{ github.actor }}
          # ↑ GitHub username of person who triggered workflow
          # ${{ github.actor }} automatically provides this
          password: ${{ secrets.GITHUB_TOKEN }}
          # ↑ GitHub token for authentication
          # ${{ secrets.GITHUB_TOKEN }} automatically provided by GitHub
          # Has permissions to push to GitHub Container Registry
          
      - name: Extract metadata
        # ↑ Generates Docker image tags and labels automatically
        id: meta
        # ↑ Assigns ID to this step for referencing outputs
        uses: docker/metadata-action@v5
        # ↑ Official Docker action for metadata generation
        with:
          # ↑ Parameters for metadata generation
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          # ↑ Full image name including registry
          # Results in: ghcr.io/owner/repo-name
          tags: |
            # ↑ Multi-line YAML for tag generation rules
            type=ref,event=branch
            # ↑ Creates tag from branch name (e.g., "main", "develop")
            type=ref,event=pr
            # ↑ Creates tag from PR number (e.g., "pr-123")
            type=sha,prefix={{branch}}-
            # ↑ Creates tag from git commit SHA with branch prefix
            # Results in: "main-abc123def456"
            type=raw,value=latest,enable={{is_default_branch}}
            # ↑ Creates "latest" tag only for default branch (main)
            # enable={{is_default_branch}} is conditional logic
            
      - name: Build and push
        # ↑ Builds Docker image and pushes to registry
        uses: docker/build-push-action@v5
        # ↑ Official Docker action for building and pushing images
        with:
          # ↑ Parameters for Docker build process
          context: .
          # ↑ Build context is current directory (where Dockerfile is located)
          file: ./Dockerfile.optimized
          # ↑ Specifies which Dockerfile to use
          # Could be Dockerfile, Dockerfile.prod, etc.
          push: true
          # ↑ Pushes built image to registry after successful build
          tags: ${{ steps.meta.outputs.tags }}
          # ↑ Uses tags generated by metadata action
          # References output from previous step using steps.meta.outputs
          labels: ${{ steps.meta.outputs.labels }}
          # ↑ Uses labels generated by metadata action
          # Labels provide metadata about the image (source, version, etc.)
          cache-from: type=gha
          # ↑ Uses GitHub Actions cache for Docker layers
          # type=gha enables GitHub Actions built-in caching
          # Dramatically speeds up subsequent builds
          cache-to: type=gha,mode=max
          # ↑ Saves Docker layers to GitHub Actions cache
          # mode=max caches all layers (not just final image)
          # Provides maximum caching benefit for future builds
```

**Detailed Docker Build Optimization Concepts for Newbies:**

1. **Docker Buildx Benefits:**
   - **Multi-Platform**: Build for different CPU architectures (ARM, x86)
   - **Advanced Caching**: More sophisticated layer caching mechanisms
   - **Remote Builders**: Can use remote build servers for better performance
   - **Build Secrets**: Secure handling of build-time secrets

2. **GitHub Container Registry (GHCR):**
   - **Integration**: Tightly integrated with GitHub repositories
   - **Permissions**: Uses GitHub's existing permission system
   - **Cost**: Free for public repositories, reasonable pricing for private
   - **Performance**: Fast pulls/pushes, global CDN distribution

3. **Metadata Action Benefits:**
   - **Automatic Tagging**: Generates consistent, meaningful image tags
   - **OCI Labels**: Adds standard metadata labels to images
   - **Conditional Logic**: Different tags for different scenarios
   - **Traceability**: Links images back to source code and commits

4. **Caching Strategy:**
   - **Layer Caching**: Docker layers cached between builds
   - **GitHub Actions Cache**: Uses GitHub's built-in caching infrastructure
   - **Cache Scope**: Shared across workflow runs in same repository
   - **Performance Impact**: Can reduce build times by 50-80%

5. **Security Considerations:**
   - **GITHUB_TOKEN**: Automatically provided, limited permissions
   - **Registry Authentication**: Secure token-based authentication
   - **Image Scanning**: Built images should be scanned for vulnerabilities
   - **Access Control**: Registry permissions controlled by GitHub settings
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
            
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile.optimized
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### **Advanced Build with Multi-Platform Support**
```yaml
name: Multi-Platform Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
        
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
            
      - name: Build and push multi-platform
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile.optimized
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILDKIT_INLINE_CACHE=1
```

**Line-by-Line Analysis:**

**`name: Multi-Platform Docker Build`** - Workflow for building containers supporting multiple CPU architectures
**`tags: ['v*']`** - Triggers on version tags for release builds with semantic versioning
**`env: REGISTRY: ghcr.io`** - GitHub Container Registry for multi-platform image storage
**`IMAGE_NAME: ${{ github.repository }}`** - Dynamic image naming based on repository name
**`runs-on: ubuntu-latest`** - Ubuntu runner with Docker and multi-platform build support
**`uses: actions/checkout@v4`** - Downloads source code and Dockerfile for building
**`uses: docker/setup-qemu-action@v3`** - Configures QEMU emulation for cross-platform builds
**`uses: docker/setup-buildx-action@v3`** - Sets up Docker Buildx for advanced build features
**`uses: docker/login-action@v3`** - Authenticates with GitHub Container Registry
**`registry: ${{ env.REGISTRY }}`** - Uses environment variable for registry URL
**`username: ${{ github.actor }}`** - GitHub username for registry authentication
**`password: ${{ secrets.GITHUB_TOKEN }}`** - GitHub token for secure registry access
**`uses: docker/metadata-action@v5`** - Generates image tags and labels automatically
**`images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}`** - Full image name with registry prefix
**`type=ref,event=branch`** - Creates tags based on branch names for development
**`type=semver,pattern={{version}}`** - Semantic version tags from Git tags
**`type=semver,pattern={{major}}.{{minor}}`** - Major.minor version tags for compatibility
**`type=sha,prefix={{branch}}-`** - Commit SHA tags with branch prefix for traceability
**`uses: docker/build-push-action@v5`** - Advanced Docker build and push action
**`context: .`** - Uses current directory as build context
**`file: ./Dockerfile.optimized`** - Specifies optimized Dockerfile for production builds
**`platforms: linux/amd64,linux/arm64`** - Builds for both x86_64 and ARM64 architectures
**`push: true`** - Pushes built images to container registry
**`tags: ${{ steps.meta.outputs.tags }}`** - Uses generated tags from metadata action
**`labels: ${{ steps.meta.outputs.labels }}`** - Applies generated labels for image metadata
**`cache-from: type=gha`** - Uses GitHub Actions cache for layer reuse
**`cache-to: type=gha,mode=max`** - Maximizes cache storage for build performance
**`BUILDKIT_INLINE_CACHE=1`** - Enables inline cache for faster subsequent builds

---

## 🚀 Advanced Caching Strategies

### **Registry Cache Configuration**

```yaml
name: Registry Cache Build

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Log in to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Build with Registry Cache
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: |
            type=registry,ref=ghcr.io/${{ github.repository }}:cache
            type=registry,ref=ghcr.io/${{ github.repository }}:latest
          cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:cache,mode=max
```

### **Local Cache with Persistence**

```yaml
name: Persistent Cache Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Cache Docker layers
        uses: actions/cache@v3
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-
            
      - name: Build with Local Cache
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: myapp:latest
          cache-from: type=local,src=/tmp/.buildx-cache
          cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max
          
      - name: Move cache
        run: |
          rm -rf /tmp/.buildx-cache
          mv /tmp/.buildx-cache-new /tmp/.buildx-cache
```

---

## 🎯 E-commerce Optimization Workflow

### **Complete E-commerce Docker Pipeline**

```yaml
name: E-commerce Docker Optimization

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ecommerce-app

jobs:
  analyze-changes:
    runs-on: ubuntu-latest
    outputs:
      frontend-changed: ${{ steps.changes.outputs.frontend }}
      backend-changed: ${{ steps.changes.outputs.backend }}
      docker-changed: ${{ steps.changes.outputs.docker }}
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
              - 'package.json'
              - 'package-lock.json'
            backend:
              - 'backend/**'
              - 'api/**'
            docker:
              - 'Dockerfile*'
              - 'docker-compose*.yml'
              - '.dockerignore'

  build-frontend:
    needs: analyze-changes
    if: needs.analyze-changes.outputs.frontend-changed == 'true' || needs.analyze-changes.outputs.docker-changed == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Log in to Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Build Frontend
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          file: ./frontend/Dockerfile.optimized
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-frontend:${{ github.sha }}
          cache-from: type=gha,scope=frontend
          cache-to: type=gha,scope=frontend,mode=max
          build-args: |
            NODE_ENV=production
            BUILD_VERSION=${{ github.sha }}

  build-backend:
    needs: analyze-changes
    if: needs.analyze-changes.outputs.backend-changed == 'true' || needs.analyze-changes.outputs.docker-changed == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Log in to Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Build Backend
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          file: ./backend/Dockerfile.optimized
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-backend:${{ github.sha }}
          cache-from: type=gha,scope=backend
          cache-to: type=gha,scope=backend,mode=max
          build-args: |
            NODE_ENV=production
            BUILD_VERSION=${{ github.sha }}

  security-scan:
    needs: [build-frontend, build-backend]
    if: always() && (needs.build-frontend.result == 'success' || needs.build-backend.result == 'success')
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        component: [frontend, backend]
        
    steps:
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-${{ matrix.component }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results-${{ matrix.component }}.sarif'
          
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results-${{ matrix.component }}.sarif'

  performance-test:
    needs: [build-frontend, build-backend]
    if: always() && needs.build-frontend.result == 'success' && needs.build-backend.result == 'success'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Test Environment
        run: |
          # Create docker-compose for testing
          cat > docker-compose.test.yml << 'EOF'
          version: '3.8'
          services:
            frontend:
              image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-frontend:${{ github.sha }}
              ports:
                - "3000:3000"
              environment:
                - API_URL=http://backend:4000
            backend:
              image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-backend:${{ github.sha }}
              ports:
                - "4000:4000"
              environment:
                - NODE_ENV=test
                - DATABASE_URL=postgresql://test:test@db:5432/testdb
            db:
              image: postgres:15-alpine
              environment:
                - POSTGRES_USER=test
                - POSTGRES_PASSWORD=test
                - POSTGRES_DB=testdb
          EOF
          
          docker-compose -f docker-compose.test.yml up -d
          
      - name: Wait for Services
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:3000/health; do sleep 2; done'
          timeout 60 bash -c 'until curl -f http://localhost:4000/health; do sleep 2; done'
          
      - name: Run Performance Tests
        run: |
          # Install k6 for load testing
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6
          
          # Run load test
          k6 run --vus 10 --duration 30s tests/load-test.js
          
      - name: Cleanup
        if: always()
        run: docker-compose -f docker-compose.test.yml down -v
```

---

## 🔧 Dockerfile Optimization Techniques

### **Layer Optimization Example**

```dockerfile
# Dockerfile.layer-optimized
FROM node:18-alpine AS base

# Install system dependencies (rarely changes)
RUN apk add --no-cache \
    libc6-compat \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Create app directory and user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 && \
    mkdir -p /app && \
    chown nextjs:nodejs /app

WORKDIR /app

# Copy package files (changes less frequently than source)
COPY --chown=nextjs:nodejs package*.json ./

# Install dependencies
FROM base AS deps
RUN npm ci --only=production && \
    npm cache clean --force

# Development dependencies for building
FROM base AS build-deps
RUN npm ci

# Build stage
FROM build-deps AS builder
COPY --chown=nextjs:nodejs . .
RUN npm run build && \
    npm prune --production

# Final production image
FROM base AS production

# Copy production dependencies
COPY --from=deps --chown=nextjs:nodejs /app/node_modules ./node_modules

# Copy built application
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# Switch to non-root user
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
```

### **Size Optimization Techniques**

```dockerfile
# Dockerfile.size-optimized
# Use distroless for minimal attack surface
FROM node:18-alpine AS builder

WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source and build
COPY . .
RUN npm run build

# Production stage with distroless
FROM gcr.io/distroless/nodejs18-debian11

WORKDIR /app

# Copy only necessary files
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./

# Distroless images run as non-root by default
EXPOSE 3000

CMD ["dist/server.js"]
```

---

## 📊 Build Performance Monitoring

### **Build Metrics Collection**

```yaml
name: Build Performance Monitoring

on:
  push:
    branches: [main]

jobs:
  build-with-metrics:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Build with Timing
        id: build
        run: |
          START_TIME=$(date +%s)
          
          docker buildx build \
            --tag myapp:latest \
            --cache-from type=gha \
            --cache-to type=gha,mode=max \
            --metadata-file metadata.json \
            .
            
          END_TIME=$(date +%s)
          BUILD_TIME=$((END_TIME - START_TIME))
          
          echo "build-time=$BUILD_TIME" >> $GITHUB_OUTPUT
          
      - name: Analyze Build Metrics
        run: |
          # Extract image size
          IMAGE_SIZE=$(docker images myapp:latest --format "{{.Size}}")
          
          # Extract layer information
          docker history myapp:latest --format "table {{.CreatedBy}}\t{{.Size}}" > layer-analysis.txt
          
          # Create metrics report
          cat > build-metrics.json << EOF
          {
            "build_time": "${{ steps.build.outputs.build-time }}",
            "image_size": "$IMAGE_SIZE",
            "commit_sha": "${{ github.sha }}",
            "branch": "${{ github.ref_name }}",
            "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
          }
          EOF
          
      - name: Upload Metrics
        uses: actions/upload-artifact@v4
        with:
          name: build-metrics
          path: |
            build-metrics.json
            layer-analysis.txt
            metadata.json
```

### **Performance Comparison Workflow**

```yaml
name: Build Performance Comparison

on:
  pull_request:
    branches: [main]

jobs:
  compare-build-performance:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Build Current Branch
        id: current
        run: |
          START_TIME=$(date +%s)
          docker buildx build --tag current:latest .
          END_TIME=$(date +%s)
          CURRENT_TIME=$((END_TIME - START_TIME))
          CURRENT_SIZE=$(docker images current:latest --format "{{.Size}}")
          
          echo "time=$CURRENT_TIME" >> $GITHUB_OUTPUT
          echo "size=$CURRENT_SIZE" >> $GITHUB_OUTPUT
          
      - name: Checkout Main Branch
        run: |
          git checkout origin/main
          
      - name: Build Main Branch
        id: main
        run: |
          START_TIME=$(date +%s)
          docker buildx build --tag main:latest .
          END_TIME=$(date +%s)
          MAIN_TIME=$((END_TIME - START_TIME))
          MAIN_SIZE=$(docker images main:latest --format "{{.Size}}")
          
          echo "time=$MAIN_TIME" >> $GITHUB_OUTPUT
          echo "size=$MAIN_SIZE" >> $GITHUB_OUTPUT
          
      - name: Generate Comparison Report
        run: |
          cat > performance-comparison.md << EOF
          # Build Performance Comparison
          
          ## Build Times
          - **Main Branch**: ${{ steps.main.outputs.time }} seconds
          - **Current Branch**: ${{ steps.current.outputs.time }} seconds
          - **Difference**: $((${{ steps.current.outputs.time }} - ${{ steps.main.outputs.time }})) seconds
          
          ## Image Sizes
          - **Main Branch**: ${{ steps.main.outputs.size }}
          - **Current Branch**: ${{ steps.current.outputs.size }}
          
          ## Analysis
          EOF
          
          # Add performance analysis
          if [ ${{ steps.current.outputs.time }} -gt ${{ steps.main.outputs.time }} ]; then
            echo "⚠️ Build time increased by $((${{ steps.current.outputs.time }} - ${{ steps.main.outputs.time }})) seconds" >> performance-comparison.md
          else
            echo "✅ Build time improved by $((${{ steps.main.outputs.time }} - ${{ steps.current.outputs.time }})) seconds" >> performance-comparison.md
          fi
          
      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('performance-comparison.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

---

## 🎯 Hands-On Lab: Complete Docker Optimization

### **Lab Objective**
Optimize Docker builds for an e-commerce application, reducing build time by 50% and image size by 30%.

### **Lab Steps**

1. **Analyze Current Build**
```bash
# Time current build
time docker build -t ecommerce:current .

# Check image size
docker images ecommerce:current
```

2. **Implement Multi-Stage Build**
```bash
# Create optimized Dockerfile
cp examples/Dockerfile.optimized ./Dockerfile.new

# Build with new Dockerfile
time docker build -f Dockerfile.new -t ecommerce:optimized .
```

3. **Add Build Caching**
```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache
docker build --cache-from ecommerce:optimized -t ecommerce:cached .
```

4. **Measure Improvements**
```bash
# Compare sizes
docker images | grep ecommerce

# Compare build times
./scripts/benchmark-builds.sh
```

### **Expected Results**
- 50%+ reduction in build time
- 30%+ reduction in image size
- Improved layer caching efficiency
- Faster CI/CD pipeline execution

---

## 📚 Additional Resources

### **Optimization Tools**

| Tool | Purpose | Usage |
|------|---------|-------|
| **dive** | Layer analysis | `dive myimage:latest` |
| **docker-slim** | Image minification | `docker-slim build myimage` |
| **hadolint** | Dockerfile linting | `hadolint Dockerfile` |
| **container-diff** | Image comparison | `container-diff diff image1 image2` |

### **Best Practices Summary**
- **Layer Ordering**: Place frequently changing layers last
- **Multi-Stage Builds**: Separate build and runtime environments
- **Cache Optimization**: Use BuildKit cache mounts and registry cache
- **Base Image Selection**: Choose minimal, security-focused base images
- **Dependency Management**: Install only production dependencies in final stage

---

## 🎯 Module Assessment

### **Knowledge Check**
1. How do multi-stage builds improve Docker image optimization?
2. What are the different types of Docker build caching strategies?
3. How do you implement cross-platform Docker builds?
4. What tools can help analyze and optimize Docker images?

### **Practical Exercise**
Optimize a Docker build pipeline that includes:
- Multi-stage Dockerfile with proper layer ordering
- Advanced caching configuration
- Security scanning integration
- Performance monitoring and comparison

### **Success Criteria**
- [ ] Significant reduction in build time (>30%)
- [ ] Smaller final image size (>20%)
- [ ] Proper caching implementation
- [ ] Security scanning integration
- [ ] Performance monitoring setup

---

**Next Module**: [GitHub Marketplace Mastery](./15-GitHub-Marketplace.md) - Learn action discovery and custom development
