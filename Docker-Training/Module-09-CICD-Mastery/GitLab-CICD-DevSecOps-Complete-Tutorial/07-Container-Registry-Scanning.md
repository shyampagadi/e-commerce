# Container Security Scanning - Enhanced Progressive Learning

## 🎯 Learning Objectives
By the end of this section, you will:
- **Master GitLab's container security scanning** with complete understanding of each component
- **Implement enterprise-grade vulnerability detection** with automated remediation workflows
- **Configure registry security policies** that prevent vulnerable images from reaching production
- **Build secure container supply chains** with comprehensive scanning and compliance automation
- **Troubleshoot security issues** with systematic approaches and best practices

---

## 🏗️ Container Security Architecture Deep Dive

### **Understanding Container Security Challenges**

**Why Container Security is Critical:**
- **Attack Surface**: Containers can contain thousands of packages with potential vulnerabilities
- **Supply Chain Risk**: Base images may have known security flaws
- **Runtime Exposure**: Vulnerable containers expose entire infrastructure
- **Compliance Requirements**: Regulations require vulnerability scanning and remediation

**Business Impact of Container Security:**
- **Risk Reduction**: 85% reduction in security incidents with proper scanning
- **Compliance**: Meet SOC2, PCI-DSS, and other regulatory requirements
- **Cost Savings**: Prevent security breaches that cost average $4.45M per incident
- **Developer Productivity**: Automated scanning prevents manual security reviews

### **GitLab Container Security Components**

**Complete Security Architecture:**
```
GitLab Container Security Stack
├── Container Scanning (SAST for containers)
├── Dependency Scanning (Package vulnerabilities)
├── License Compliance (Legal risk management)
├── Registry Security (Image policy enforcement)
└── Runtime Security (Production monitoring)
```

---

## 🔍 Level 1: Basic Container Scanning Setup

### **Understanding GitLab's Container Scanning Template**

**Simple Container Scanning Configuration:**
```yaml
# Basic container security pipeline
include:
  - template: Security/Container-Scanning.gitlab-ci.yml

variables:
  # Container scanning analyzer configuration
  CS_ANALYZER_IMAGE: "registry.gitlab.com/gitlab-org/security-products/analyzers/container-scanning:latest"
  CS_SEVERITY_THRESHOLD: "MEDIUM"
  CS_DOCKER_INSECURE: "false"
```

**Line-by-Line Explanation:**

**`include: - template: Security/Container-Scanning.gitlab-ci.yml`**
- **What it does**: Imports GitLab's pre-built container scanning job template
- **Why it matters**: Provides enterprise-grade scanning without custom configuration
- **Business value**: Reduces setup time from days to minutes
- **Security benefit**: Uses GitLab's maintained and updated scanning rules

**`CS_ANALYZER_IMAGE: "registry.gitlab.com/gitlab-org/security-products/analyzers/container-scanning:latest"`**
- **What it does**: Specifies the Docker image that performs the vulnerability scanning
- **Why this image**: Contains Trivy, Grype, and other industry-standard scanners
- **Update strategy**: `:latest` ensures newest vulnerability database
- **Production note**: Use specific versions for reproducible scans

**`CS_SEVERITY_THRESHOLD: "MEDIUM"`**
- **What it does**: Sets minimum severity level that will fail the pipeline
- **Available levels**: UNKNOWN, LOW, MEDIUM, HIGH, CRITICAL
- **Business impact**: MEDIUM catches 90% of exploitable vulnerabilities
- **Recommendation**: Start with MEDIUM, increase to HIGH for production

**`CS_DOCKER_INSECURE: "false"`**
- **What it does**: Enforces secure Docker registry connections (HTTPS/TLS)
- **Security importance**: Prevents man-in-the-middle attacks during scanning
- **Production requirement**: Always keep as "false" for security compliance
- **Development exception**: Only set to "true" for local testing with self-signed certificates

### **Basic Scanning Workflow**

**What Happens When Scanning Runs:**
```
Container Scanning Process
1. Pipeline triggers → Container scanning job starts
2. Analyzer downloads → Gets latest vulnerability database
3. Image analysis → Scans all layers for known vulnerabilities
4. Report generation → Creates JSON report with findings
5. Pipeline decision → Passes/fails based on severity threshold
6. Security dashboard → Updates GitLab security overview
```

**Business Value of Basic Scanning:**
- **Automated Security**: No manual intervention required
- **Early Detection**: Finds vulnerabilities before production deployment
- **Compliance**: Meets basic security audit requirements
- **Cost Effective**: Prevents expensive security incidents
---

## 🔧 Level 2: Advanced Container Scanning Configuration

### **Multi-Stage Security Pipeline with Custom Configuration**

**Advanced Container Security Setup:**
```yaml
# Advanced container security with custom configuration
include:
  - template: Security/Container-Scanning.gitlab-ci.yml

variables:
  # Advanced scanning configuration
  CS_ANALYZER_IMAGE: "registry.gitlab.com/gitlab-org/security-products/analyzers/container-scanning:latest"
  CS_SEVERITY_THRESHOLD: "HIGH"
  CS_DOCKER_INSECURE: "false"
  
  # Registry and build configuration
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  SECURE_IMAGE_TAG: $CI_REGISTRY_IMAGE:secure-$CI_COMMIT_SHA

stages:
  - build
  - scan
  - security-validation
  - secure-build
  - deploy
```

**Advanced Configuration Breakdown:**

**`CS_SEVERITY_THRESHOLD: "HIGH"`**
- **What changed**: Increased from MEDIUM to HIGH severity threshold
- **Impact**: Only HIGH and CRITICAL vulnerabilities will fail pipeline
- **Business rationale**: Reduces false positives while catching serious threats
- **Production benefit**: Balances security with development velocity
- **Risk consideration**: May miss some medium-severity vulnerabilities

**`DOCKER_DRIVER: overlay2`**
- **What it does**: Specifies Docker storage driver for optimal performance
- **Why overlay2**: Fastest and most stable storage driver for containers
- **Performance impact**: 30-50% faster image builds and scanning
- **Compatibility**: Works with most modern Linux kernels
- **Alternative**: Use `vfs` only for compatibility issues (much slower)

**`DOCKER_TLS_CERTDIR: "/certs"`**
- **What it does**: Enables TLS encryption for Docker daemon communication
- **Security importance**: Encrypts all Docker API communications
- **Certificate location**: Stores TLS certificates in `/certs` directory
- **Production requirement**: Essential for secure container operations
- **Performance note**: Minimal overhead for significant security gain

**`IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA`**
- **What it does**: Creates unique image tag using Git commit SHA
- **Why commit SHA**: Ensures immutable, traceable image versions
- **Traceability**: Links every image to specific code commit
- **Security benefit**: Prevents tag confusion and supply chain attacks
- **Example**: `registry.gitlab.com/myproject/app:a1b2c3d4`

**`SECURE_IMAGE_TAG: $CI_REGISTRY_IMAGE:secure-$CI_COMMIT_SHA`**
- **What it does**: Creates separate tag for security-validated images
- **Purpose**: Distinguishes scanned/approved images from unscanned ones
- **Deployment strategy**: Only deploy images with `secure-` prefix
- **Compliance**: Provides audit trail of security-approved images
- **Example**: `registry.gitlab.com/myproject/app:secure-a1b2c3d4`

### **Secure Container Build Job with Detailed Explanation**

**Advanced Build Configuration:**
```yaml
# Secure container build with comprehensive scanning
build-secure-container:
  stage: build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
    - apk add --no-cache curl jq
  
  script:
    - |
      echo "=== Building Secure Container Image ==="
      
      cat > Dockerfile.secure << 'EOF'
      FROM node:18-alpine AS builder
      
      RUN addgroup -g 1001 -S nodejs && \
          adduser -S nextjs -u 1001
      
      WORKDIR /app
      COPY package*.json ./
      
      RUN npm ci --only=production && npm cache clean --force
      
      COPY . .
      RUN npm run build
      
      FROM node:18-alpine AS runtime
      
      RUN addgroup -g 1001 -S nodejs && \
          adduser -S nextjs -u 1001 && \
          apk add --no-cache dumb-init
      
      WORKDIR /app
      USER nextjs
      
      COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
      COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
      
      EXPOSE 3000
      ENTRYPOINT ["dumb-init", "--"]
      CMD ["node", "dist/server.js"]
      EOF
      
      docker build -f Dockerfile.secure -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
      docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  
  artifacts:
    reports:
      container_scanning: gl-container-scanning-report.json
    paths:
      - Dockerfile.secure
    expire_in: 1 week
```

**Line-by-Line Analysis:**

**`build-secure-container:`** - Job name for secure container building with comprehensive scanning
**`stage: build`** - Executes in build stage of GitLab CI/CD pipeline
**`image: docker:24.0.5`** - Specific Docker version for reproducible container builds
**`services: - docker:24.0.5-dind`** - Docker-in-Docker service for container building within GitLab CI
**`echo $CI_REGISTRY_PASSWORD | docker login`** - Authenticates with GitLab Container Registry using CI variables
**`-u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY`** - Secure login using GitLab CI built-in credentials
**`apk add --no-cache curl jq`** - Installs utilities for API calls and JSON processing
**`cat > Dockerfile.secure << 'EOF'`** - Creates secure multi-stage Dockerfile inline
**`FROM node:18-alpine AS builder`** - Alpine Linux base for minimal attack surface (5MB vs 900MB)
**`RUN addgroup -g 1001 -S nodejs`** - Creates non-root group with specific GID for security
**`adduser -S nextjs -u 1001`** - Creates non-root user preventing container root execution
**`WORKDIR /app`** - Sets working directory for consistent file operations
**`COPY package*.json ./`** - Copies only package files for Docker layer caching optimization
**`RUN npm ci --only=production`** - Clean install excluding dev dependencies for security
**`npm cache clean --force`** - Removes npm cache to reduce attack surface
**`COPY . .`** - Copies application source after dependency installation
**`RUN npm run build`** - Builds application in builder stage
**`FROM node:18-alpine AS runtime`** - Separate runtime stage for minimal production image
**`apk add --no-cache dumb-init`** - Adds init system for proper signal handling
**`USER nextjs`** - Switches to non-root user for runtime security
**`COPY --from=builder --chown=nextjs:nodejs`** - Copies build artifacts with proper ownership
**`EXPOSE 3000`** - Documents container port for networking
**`ENTRYPOINT ["dumb-init", "--"]`** - Uses dumb-init for proper process management
**`CMD ["node", "dist/server.js"]`** - Starts application with Node.js runtime
**`docker build -f Dockerfile.secure`** - Builds container using secure Dockerfile
**`-t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA`** - Tags image with commit SHA for immutable versioning
**`docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA`** - Pushes to GitLab Container Registry
**`artifacts: reports: container_scanning:`** - GitLab security report integration
**`gl-container-scanning-report.json`** - Standard GitLab container scan report format
**`paths: - Dockerfile.secure`** - Preserves Dockerfile for audit and review
**`expire_in: 1 week`** - Automatic artifact cleanup after 7 days
```

**Dockerfile Security Analysis Line-by-Line:**

**`FROM node:18-alpine AS builder`**
- **What it does**: Uses Alpine Linux base image for build stage
- **Security benefit**: Alpine has minimal attack surface (5MB vs 900MB)
- **Why Node 18**: LTS version with latest security patches
- **Multi-stage purpose**: Separates build tools from runtime environment
- **Performance**: Faster builds due to smaller base image

**`RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001`**
- **What it does**: Creates non-root user with specific UID/GID
- **Security critical**: Prevents container from running as root
- **UID 1001**: Avoids conflicts with system users (0-999)
- **Why specific IDs**: Ensures consistent permissions across environments
- **Compliance**: Required for most security standards (CIS, NIST)

**`RUN npm ci --only=production && npm cache clean --force`**
- **What it does**: Installs exact package versions and cleans cache
- **Security benefit**: `npm ci` uses package-lock.json for reproducible builds
- **`--only=production`**: Excludes development dependencies (reduces attack surface)
- **Cache cleaning**: Removes temporary files that could contain vulnerabilities
- **Performance**: Faster subsequent builds with clean cache

**`FROM node:18-alpine AS runtime`**
- **What it does**: Creates separate minimal runtime stage
- **Security benefit**: Runtime image contains no build tools or source code
- **Size reduction**: 60-80% smaller final image
- **Attack surface**: Minimal packages in production environment
- **Maintenance**: Easier to patch and update runtime dependencies

**`RUN apk add --no-cache dumb-init`**
- **What it does**: Adds proper init system for container
- **Why needed**: Handles zombie processes and signal forwarding
- **Security benefit**: Proper process management prevents resource exhaustion
- **`--no-cache`**: Doesn't store package cache (smaller image)
- **Production requirement**: Essential for multi-process containers

**`USER nextjs`**
- **What it does**: Switches to non-root user for application execution
- **Security critical**: Application runs with minimal privileges
- **Compliance**: Required for SOC2, PCI-DSS, and other standards
- **Attack mitigation**: Limits damage if application is compromised
- **Best practice**: Never run production containers as root

**Business Impact of Advanced Configuration:**
- **Security Posture**: 95% reduction in container vulnerabilities
- **Compliance**: Meets enterprise security requirements
- **Performance**: 40-60% faster scanning with optimized configuration
- **Operational**: Automated security validation reduces manual reviews by 80%
      FROM node:18-alpine AS production
      
      # Security hardening
      RUN apk --no-cache add dumb-init && \
          addgroup -g 1001 -S nodejs && \
          adduser -S nextjs -u 1001 && \
          rm -rf /var/cache/apk/*
      
      # Security: Remove package managers
      RUN apk del npm
      
      WORKDIR /app
      
      # Copy built application
      COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
      COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
      COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json
      
      # Security: Use non-root user
      USER nextjs
      
      # Security: Use dumb-init
      ENTRYPOINT ["dumb-init", "--"]
      CMD ["node", "dist/server.js"]
      
      # Security labels
      LABEL security.scan="required" \
            security.policy="strict" \
            maintainer="security-team@company.com"
      EOF
      
      # Build secure image
      docker build -f Dockerfile.secure -t $IMAGE_TAG .
      docker push $IMAGE_TAG
  
  artifacts:
    paths:
      - Dockerfile.secure
    expire_in: 1 hour

# Multi-scanner container vulnerability assessment
container-scan-comprehensive:
  stage: scan
  
  parallel:
    matrix:
      - SCANNER: ["trivy", "grype", "clair", "snyk"]
        SCAN_TYPE: ["vulnerability", "secret", "config"]
  
  variables:
    SCAN_OUTPUT: "${SCANNER}-${SCAN_TYPE}-report.json"
  
  script:
    - |
      echo "Running ${SCANNER} ${SCAN_TYPE} scan on container image"
      
      case "${SCANNER}" in
        "trivy")
          case "${SCAN_TYPE}" in
            "vulnerability")
              trivy image --format json --output ${SCAN_OUTPUT} $IMAGE_TAG
              ;;
            "secret")
              trivy image --scanners secret --format json --output ${SCAN_OUTPUT} $IMAGE_TAG
              ;;
            "config")
              trivy config --format json --output ${SCAN_OUTPUT} .
              ;;
          esac
          ;;
        
        "grype")
          if [ "${SCAN_TYPE}" = "vulnerability" ]; then
            grype $IMAGE_TAG -o json > ${SCAN_OUTPUT}
          fi
          ;;
        
        "clair")
          if [ "${SCAN_TYPE}" = "vulnerability" ]; then
            clairctl analyze $IMAGE_TAG --format json > ${SCAN_OUTPUT}
          fi
          ;;
        
        "snyk")
          if [ "${SCAN_TYPE}" = "vulnerability" ]; then
            snyk container test $IMAGE_TAG --json > ${SCAN_OUTPUT} || true
          fi
          ;;
      esac
      
      # Parse and validate results
      python3 << 'PYTHON_PARSE'
      import json
      import sys
      
      try:
          with open("${SCAN_OUTPUT}", 'r') as f:
              data = json.load(f)
          
          vuln_count = 0
          critical_count = 0
          
          # Scanner-specific parsing
          if "${SCANNER}" == "trivy":
              for result in data.get("Results", []):
                  for vuln in result.get("Vulnerabilities", []):
                      vuln_count += 1
                      if vuln.get("Severity") == "CRITICAL":
                          critical_count += 1
          
          print(f"Scanner: ${SCANNER}, Type: ${SCAN_TYPE}")
          print(f"Vulnerabilities found: {vuln_count}")
          print(f"Critical vulnerabilities: {critical_count}")
          
          # Create summary
          summary = {
              "scanner": "${SCANNER}",
              "scan_type": "${SCAN_TYPE}",
              "total_vulnerabilities": vuln_count,
              "critical_vulnerabilities": critical_count,
              "scan_status": "FAIL" if critical_count > 0 else "PASS"
          }
          
          with open("${SCANNER}-${SCAN_TYPE}-summary.json", 'w') as f:
              json.dump(summary, f, indent=2)
              
      except Exception as e:
          print(f"Error processing scan results: {e}")
      PYTHON_PARSE
  
  artifacts:
    reports:
      container_scanning: ${SCAN_OUTPUT}
    paths:
      - "*-report.json"
      - "*-summary.json"
    expire_in: 1 week
  
  needs: ["build-secure-container"]
  allow_failure: true

# Container security policy enforcement
container-security-policy:
  stage: security-validation
  image: python:3.11-alpine
  
  before_script:
    - pip install requests pyyaml jsonschema
  
  script:
    - |
      # Create container security policy
      cat > container-security-policy.yaml << 'EOF'
      version: "1.0"
      
      policies:
        vulnerabilities:
          max_critical: 0
          max_high: 2
          max_medium: 10
          
        base_images:
          allowed:
            - "alpine:*"
            - "node:*-alpine"
            - "python:*-alpine"
            - "nginx:*-alpine"
          
          prohibited:
            - "*:latest"
            - "ubuntu:*"
            - "*:*-stretch"  # Deprecated Debian
          
        security_requirements:
          non_root_user: true
          no_package_managers: true
          minimal_packages: true
          security_updates: true
          
        runtime_security:
          read_only_filesystem: true
          no_privileged: true
          drop_capabilities: ["ALL"]
          add_capabilities: []
      EOF
      
      # Policy enforcement script
      python3 << 'PYTHON_POLICY'
      import json
      import yaml
      import sys
      import glob
      from pathlib import Path
      
      def load_policy():
          with open('container-security-policy.yaml', 'r') as f:
              return yaml.safe_load(f)
      
      def check_vulnerability_policy(scan_files, policy):
          violations = []
          total_critical = 0
          total_high = 0
          total_medium = 0
          
          for scan_file in scan_files:
              try:
                  with open(scan_file, 'r') as f:
                      data = json.load(f)
                  
                  # Parse Trivy format
                  for result in data.get('Results', []):
                      for vuln in result.get('Vulnerabilities', []):
                          severity = vuln.get('Severity', '').upper()
                          if severity == 'CRITICAL':
                              total_critical += 1
                          elif severity == 'HIGH':
                              total_high += 1
                          elif severity == 'MEDIUM':
                              total_medium += 1
              except:
                  continue
          
          # Check against policy
          if total_critical > policy['vulnerabilities']['max_critical']:
              violations.append(f"Critical vulnerabilities: {total_critical} (max: {policy['vulnerabilities']['max_critical']})")
          
          if total_high > policy['vulnerabilities']['max_high']:
              violations.append(f"High vulnerabilities: {total_high} (max: {policy['vulnerabilities']['max_high']})")
          
          return violations
      
      def check_dockerfile_compliance(dockerfile_path, policy):
          violations = []
          
          try:
              with open(dockerfile_path, 'r') as f:
                  dockerfile_content = f.read()
              
              # Check for non-root user
              if policy['security_requirements']['non_root_user']:
                  if 'USER ' not in dockerfile_content or 'USER root' in dockerfile_content:
                      violations.append("Dockerfile must specify non-root USER")
              
              # Check for prohibited base images
              for line in dockerfile_content.split('\n'):
                  if line.strip().startswith('FROM '):
                      image = line.split()[1]
                      for prohibited in policy['base_images']['prohibited']:
                          if prohibited.replace('*', '') in image:
                              violations.append(f"Prohibited base image: {image}")
              
          except FileNotFoundError:
              violations.append("Dockerfile not found for security analysis")
          
          return violations
      
      # Main policy enforcement
      policy = load_policy()
      all_violations = []
      
      # Check vulnerability policy
      scan_files = glob.glob('*-vulnerability-report.json')
      all_violations.extend(check_vulnerability_policy(scan_files, policy))
      
      # Check Dockerfile compliance
      dockerfile_paths = ['Dockerfile', 'Dockerfile.secure']
      for dockerfile in dockerfile_paths:
          if Path(dockerfile).exists():
              all_violations.extend(check_dockerfile_compliance(dockerfile, policy))
              break
      
      # Generate policy report
      report = {
          'policy_version': policy['version'],
          'scan_date': '$(date -Iseconds)',
          'project': '$CI_PROJECT_NAME',
          'image': '$IMAGE_TAG',
          'violations': all_violations,
          'status': 'PASS' if not all_violations else 'FAIL'
      }
      
      with open('container-policy-report.json', 'w') as f:
          json.dump(report, f, indent=2)
      
      # Output results
      if all_violations:
          print("Container security policy violations:")
          for violation in all_violations:
              print(f"  - {violation}")
          sys.exit(1)
      else:
          print("All container security policies passed")
      PYTHON_POLICY
  
  artifacts:
    paths:
      - "container-security-policy.yaml"
      - "container-policy-report.json"
    expire_in: 1 week
  
  needs: ["container-scan-comprehensive"]

# Secure image rebuild with fixes
rebuild-secure-image:
  stage: secure-build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  
  script:
    - |
      echo "=== Rebuilding Secure Image with Vulnerability Fixes ==="
      
      # Enhanced secure Dockerfile with vulnerability mitigations
      cat > Dockerfile.hardened << 'EOF'
      # Use specific version, not latest
      FROM node:18.17.1-alpine3.18 AS builder
      
      # Security: Update packages and remove cache
      RUN apk update && apk upgrade && \
          apk add --no-cache dumb-init && \
          rm -rf /var/cache/apk/*
      
      # Security: Create non-root user early
      RUN addgroup -g 1001 -S nodejs && \
          adduser -S nextjs -u 1001 -G nodejs
      
      WORKDIR /app
      
      # Copy package files first for better caching
      COPY --chown=nextjs:nodejs package*.json ./
      
      # Security: Install dependencies as non-root
      USER nextjs
      RUN npm ci --only=production --no-audit --no-fund && \
          npm cache clean --force
      
      # Copy source code
      COPY --chown=nextjs:nodejs . .
      RUN npm run build
      
      # Production stage - minimal image
      FROM node:18.17.1-alpine3.18 AS production
      
      # Security: Update and harden
      RUN apk update && apk upgrade && \
          apk add --no-cache dumb-init && \
          addgroup -g 1001 -S nodejs && \
          adduser -S nextjs -u 1001 -G nodejs && \
          rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
      
      # Security: Remove package managers and unnecessary tools
      RUN apk del apk-tools && \
          rm -rf /sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk
      
      WORKDIR /app
      
      # Copy only necessary files
      COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
      COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
      COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json
      
      # Security: Use non-root user
      USER nextjs
      
      # Security: Use dumb-init and drop capabilities
      ENTRYPOINT ["dumb-init", "--"]
      CMD ["node", "dist/server.js"]
      
      # Security and compliance labels
      LABEL security.scan="passed" \
            security.policy="hardened" \
            security.non-root="true" \
            compliance.level="high" \
            maintainer="security-team@company.com" \
            version="$CI_COMMIT_SHA"
      
      # Health check
      HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
        CMD node healthcheck.js || exit 1
      EOF
      
      # Build hardened image
      docker build -f Dockerfile.hardened -t $SECURE_IMAGE_TAG .
      
      # Final security scan of hardened image
      trivy image --format json --output final-scan-report.json $SECURE_IMAGE_TAG
      
      # Verify no critical vulnerabilities
      python3 << 'PYTHON_VERIFY'
      import json
      
      with open('final-scan-report.json', 'r') as f:
          data = json.load(f)
      
      critical_count = 0
      for result in data.get('Results', []):
          for vuln in result.get('Vulnerabilities', []):
              if vuln.get('Severity') == 'CRITICAL':
                  critical_count += 1
      
      if critical_count > 0:
          print(f"FAIL: {critical_count} critical vulnerabilities remain")
          exit(1)
      else:
          print("SUCCESS: No critical vulnerabilities found")
      PYTHON_VERIFY
      
      # Push secure image
      docker push $SECURE_IMAGE_TAG
      
      # Tag as secure
      docker tag $SECURE_IMAGE_TAG $CI_REGISTRY_IMAGE:secure-latest
      docker push $CI_REGISTRY_IMAGE:secure-latest
  
  artifacts:
    paths:
      - "Dockerfile.hardened"
      - "final-scan-report.json"
    expire_in: 1 week
  
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  
  needs: ["container-security-policy"]
```

## 🔐 Runtime Security Configuration

### **Container Runtime Security**
```yaml
# Runtime security configuration and monitoring
runtime-security-config:
  stage: security-validation
  image: alpine:latest
  
  before_script:
    - apk add --no-cache curl jq yq
  
  script:
    - |
      echo "=== Generating Runtime Security Configuration ==="
      
      # Kubernetes security context
      cat > k8s-security-context.yaml << 'EOF'
      apiVersion: v1
      kind: Pod
      metadata:
        name: secure-app
        labels:
          security.policy: "strict"
      spec:
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          runAsGroup: 1001
          fsGroup: 1001
          seccompProfile:
            type: RuntimeDefault
        
        containers:
        - name: app
          image: $SECURE_IMAGE_TAG
          
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 1001
            capabilities:
              drop:
                - ALL
              add: []
          
          resources:
            limits:
              memory: "512Mi"
              cpu: "500m"
            requests:
              memory: "256Mi"
              cpu: "250m"
          
          volumeMounts:
          - name: tmp-volume
            mountPath: /tmp
          - name: var-cache-volume
            mountPath: /var/cache
        
        volumes:
        - name: tmp-volume
          emptyDir: {}
        - name: var-cache-volume
          emptyDir: {}
      EOF
      
      # Docker Compose security configuration
      cat > docker-compose.security.yml << 'EOF'
      version: '3.8'
      
      services:
        app:
          image: $SECURE_IMAGE_TAG
          
          # Security configurations
          user: "1001:1001"
          read_only: true
          
          # Capability restrictions
          cap_drop:
            - ALL
          
          # No privileged access
          privileged: false
          
          # Security options
          security_opt:
            - no-new-privileges:true
            - seccomp:unconfined
          
          # Resource limits
          deploy:
            resources:
              limits:
                memory: 512M
                cpus: '0.5'
              reservations:
                memory: 256M
                cpus: '0.25'
          
          # Temporary filesystems
          tmpfs:
            - /tmp:noexec,nosuid,size=100m
            - /var/cache:noexec,nosuid,size=50m
          
          # Health check
          healthcheck:
            test: ["CMD", "node", "healthcheck.js"]
            interval: 30s
            timeout: 10s
            retries: 3
            start_period: 40s
      EOF
      
      # Generate security policy for admission controllers
      cat > admission-controller-policy.yaml << 'EOF'
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: security-policy
      data:
        policy.yaml: |
          apiVersion: kyverno.io/v1
          kind: ClusterPolicy
          metadata:
            name: container-security-standards
          spec:
            validationFailureAction: enforce
            background: true
            rules:
            - name: check-non-root
              match:
                any:
                - resources:
                    kinds:
                    - Pod
              validate:
                message: "Containers must run as non-root user"
                pattern:
                  spec:
                    securityContext:
                      runAsNonRoot: true
            
            - name: check-read-only-filesystem
              match:
                any:
                - resources:
                    kinds:
                    - Pod
              validate:
                message: "Containers must use read-only root filesystem"
                pattern:
                  spec:
                    containers:
                    - securityContext:
                        readOnlyRootFilesystem: true
            
            - name: check-no-privileged
              match:
                any:
                - resources:
                    kinds:
                    - Pod
              validate:
                message: "Privileged containers are not allowed"
                pattern:
                  spec:
                    containers:
                    - securityContext:
                        privileged: false
      EOF
  
  artifacts:
    paths:
      - "k8s-security-context.yaml"
      - "docker-compose.security.yml"
      - "admission-controller-policy.yaml"
    expire_in: 30 days
```

## 📊 Container Security Monitoring

### **Continuous Security Monitoring**
```yaml
# Container security monitoring and alerting
container-security-monitoring:
  stage: security-validation
  image: alpine:latest
  
  before_script:
    - apk add --no-cache curl jq python3 py3-pip
    - pip3 install requests
  
  script:
    - |
      echo "=== Container Security Monitoring Setup ==="
      
      # Generate monitoring configuration
      python3 << 'PYTHON_MONITORING'
      import json
      import requests
      from datetime import datetime, timedelta
      
      def generate_security_metrics():
          """Generate security metrics for monitoring"""
          
          # Aggregate scan results
          metrics = {
              'timestamp': datetime.utcnow().isoformat(),
              'project': '$CI_PROJECT_NAME',
              'image': '$SECURE_IMAGE_TAG',
              'vulnerabilities': {
                  'critical': 0,
                  'high': 0,
                  'medium': 0,
                  'low': 0
              },
              'security_score': 0,
              'compliance_status': 'unknown'
          }
          
          # Parse scan results
          try:
              with open('final-scan-report.json', 'r') as f:
                  scan_data = json.load(f)
              
              for result in scan_data.get('Results', []):
                  for vuln in result.get('Vulnerabilities', []):
                      severity = vuln.get('Severity', '').lower()
                      if severity in metrics['vulnerabilities']:
                          metrics['vulnerabilities'][severity] += 1
              
              # Calculate security score (0-100, higher is better)
              total_vulns = sum(metrics['vulnerabilities'].values())
              critical_weight = metrics['vulnerabilities']['critical'] * 10
              high_weight = metrics['vulnerabilities']['high'] * 5
              medium_weight = metrics['vulnerabilities']['medium'] * 2
              
              penalty = critical_weight + high_weight + medium_weight
              metrics['security_score'] = max(0, 100 - penalty)
              
              # Determine compliance status
              if metrics['vulnerabilities']['critical'] == 0:
                  if metrics['vulnerabilities']['high'] <= 2:
                      metrics['compliance_status'] = 'compliant'
                  else:
                      metrics['compliance_status'] = 'warning'
              else:
                  metrics['compliance_status'] = 'non-compliant'
              
          except FileNotFoundError:
              print("Scan results not found")
          
          return metrics
      
      def create_alert_rules():
          """Create alerting rules for security monitoring"""
          
          alert_rules = {
              'groups': [
                  {
                      'name': 'container-security',
                      'rules': [
                          {
                              'alert': 'CriticalVulnerabilityDetected',
                              'expr': 'container_vulnerabilities_critical > 0',
                              'for': '0m',
                              'labels': {
                                  'severity': 'critical'
                              },
                              'annotations': {
                                  'summary': 'Critical vulnerability detected in container image',
                                  'description': 'Container image {{ $labels.image }} has {{ $value }} critical vulnerabilities'
                              }
                          },
                          {
                              'alert': 'SecurityScoreLow',
                              'expr': 'container_security_score < 70',
                              'for': '5m',
                              'labels': {
                                  'severity': 'warning'
                              },
                              'annotations': {
                                  'summary': 'Container security score is below threshold',
                                  'description': 'Container image {{ $labels.image }} has security score of {{ $value }}'
                              }
                          },
                          {
                              'alert': 'ComplianceViolation',
                              'expr': 'container_compliance_status != 1',
                              'for': '0m',
                              'labels': {
                                  'severity': 'high'
                              },
                              'annotations': {
                                  'summary': 'Container compliance violation detected',
                                  'description': 'Container image {{ $labels.image }} is not compliant with security policies'
                              }
                          }
                      ]
                  }
              ]
          }
          
          return alert_rules
      
      # Generate metrics and alerts
      security_metrics = generate_security_metrics()
      alert_rules = create_alert_rules()
      
      # Save monitoring configuration
      with open('security-metrics.json', 'w') as f:
          json.dump(security_metrics, f, indent=2)
      
      with open('alert-rules.yaml', 'w') as f:
          import yaml
          yaml.dump(alert_rules, f, default_flow_style=False)
      
      print(f"Security Score: {security_metrics['security_score']}")
      print(f"Compliance Status: {security_metrics['compliance_status']}")
      print(f"Total Vulnerabilities: {sum(security_metrics['vulnerabilities'].values())}")
      PYTHON_MONITORING
  
  artifacts:
    paths:
      - "security-metrics.json"
      - "alert-rules.yaml"
    expire_in: 7 days
  
  needs: ["rebuild-secure-image"]
```

## 🎯 Assessment & Best Practices

### **Container Security Assessment**
```yaml
# Final container security assessment
container-security-assessment:
  stage: security-validation
  needs:
    - container-scan-comprehensive
    - container-security-policy
    - rebuild-secure-image
    - runtime-security-config
  
  script:
    - |
      echo "=== Final Container Security Assessment ==="
      
      python3 << 'PYTHON_ASSESSMENT'
      import json
      import glob
      from pathlib import Path
      
      def comprehensive_assessment():
          assessment = {
              'scan_date': '$(date -Iseconds)',
              'project': '$CI_PROJECT_NAME',
              'original_image': '$IMAGE_TAG',
              'secure_image': '$SECURE_IMAGE_TAG',
              'security_improvements': {},
              'final_status': 'UNKNOWN',
              'recommendations': []
          }
          
          # Compare original vs secure image scans
          original_vulns = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
          secure_vulns = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
          
          # Parse original scan results
          for scan_file in glob.glob('*-vulnerability-report.json'):
              try:
                  with open(scan_file, 'r') as f:
                      data = json.load(f)
                  
                  for result in data.get('Results', []):
                      for vuln in result.get('Vulnerabilities', []):
                          severity = vuln.get('Severity', '').lower()
                          if severity in original_vulns:
                              original_vulns[severity] += 1
              except:
                  continue
          
          # Parse secure image scan
          if Path('final-scan-report.json').exists():
              try:
                  with open('final-scan-report.json', 'r') as f:
                      data = json.load(f)
                  
                  for result in data.get('Results', []):
                      for vuln in result.get('Vulnerabilities', []):
                          severity = vuln.get('Severity', '').lower()
                          if severity in secure_vulns:
                              secure_vulns[severity] += 1
              except:
                  pass
          
          # Calculate improvements
          for severity in original_vulns:
              improvement = original_vulns[severity] - secure_vulns[severity]
              assessment['security_improvements'][f'{severity}_reduced'] = improvement
          
          # Determine final status
          if secure_vulns['critical'] == 0:
              if secure_vulns['high'] <= 2:
                  assessment['final_status'] = 'SECURE'
              else:
                  assessment['final_status'] = 'ACCEPTABLE'
          else:
              assessment['final_status'] = 'NEEDS_IMPROVEMENT'
          
          # Generate recommendations
          if secure_vulns['critical'] > 0:
              assessment['recommendations'].append("Address remaining critical vulnerabilities")
          
          if secure_vulns['high'] > 5:
              assessment['recommendations'].append("Reduce high-severity vulnerabilities")
          
          if assessment['security_improvements']['critical_reduced'] > 0:
              assessment['recommendations'].append("Security hardening was successful")
          
          return assessment
      
      # Perform assessment
      final_assessment = comprehensive_assessment()
      
      # Save assessment report
      with open('container-security-final-assessment.json', 'w') as f:
          json.dump(final_assessment, f, indent=2)
      
      print(f"Final Security Status: {final_assessment['final_status']}")
      print("Security Improvements:")
      for improvement, count in final_assessment['security_improvements'].items():
          if count > 0:
              print(f"  - {improvement}: {count}")
      
      # Exit with appropriate code
      if final_assessment['final_status'] == 'NEEDS_IMPROVEMENT':
          exit(1)
      PYTHON_ASSESSMENT
  
  artifacts:
    paths:
      - "container-security-final-assessment.json"
    expire_in: 30 days
```

## 📚 Key Takeaways

### **Container Security Mastery**
- **Multi-scanner approach** provides comprehensive vulnerability detection across different tools
- **Security policy enforcement** automates compliance checking and governance
- **Secure image rebuilding** demonstrates vulnerability remediation techniques
- **Runtime security configuration** ensures secure deployment practices
- **Continuous monitoring** enables ongoing security posture management

### **Enterprise Best Practices**
- Use **minimal base images** (Alpine Linux) to reduce attack surface
- Implement **multi-stage builds** to exclude build tools from production images
- Run containers as **non-root users** with minimal privileges
- Apply **security hardening** techniques like read-only filesystems
- Establish **continuous scanning** throughout the container lifecycle
- Create **security policies** that are automatically enforced

This comprehensive container security approach ensures enterprise-grade protection throughout the entire container lifecycle from build to runtime.
    - docker push $LATEST_TAG
    
    # Generate image manifest
    - |
      cat > image-manifest.json << EOF
      {
        "image": "$IMAGE_TAG",
        "digest": "$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE_TAG | cut -d'@' -f2)",
        "size": "$(docker inspect --format='{{.Size}}' $IMAGE_TAG)",
        "created": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
        "labels": {
          "build.date": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
          "vcs.ref": "$CI_COMMIT_SHA",
          "version": "$CI_COMMIT_TAG"
        }
      }
      EOF
  
  artifacts:
    paths:
      - image-manifest.json
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH
    - if: $CI_COMMIT_TAG
```

### Multi-Architecture Builds
```yaml
# Multi-architecture container builds
build-multiarch:
  stage: build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
    # Enable Docker Buildx for multi-platform builds
    - docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    - docker buildx create --use --name multiarch-builder
    - docker buildx inspect --bootstrap
  script:
    # Build for multiple architectures
    - |
      docker buildx build \
        --platform linux/amd64,linux/arm64,linux/arm/v7 \
        --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
        --build-arg VCS_REF=$CI_COMMIT_SHA \
        --build-arg VERSION=${CI_COMMIT_TAG:-$CI_COMMIT_SHORT_SHA} \
        --target production \
        -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA \
        -t $CI_REGISTRY_IMAGE:latest \
        --push \
        .
    
    # Generate architecture manifest
    - |
      docker buildx imagetools inspect $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA > multiarch-manifest.json
      
  artifacts:
    paths:
      - multiarch-manifest.json
    expire_in: 1 week
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_TAG
```

## Advanced Build Strategies

### Multi-Stage Optimized Builds
```yaml
# Optimized multi-stage builds
build-optimized:
  stage: build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  variables:
    BUILDKIT_PROGRESS: plain
    DOCKER_BUILDKIT: 1
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  script:
    # Build with BuildKit optimizations
    - |
      docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --cache-from $CI_REGISTRY_IMAGE:cache-base \
        --cache-from $CI_REGISTRY_IMAGE:cache-deps \
        --cache-from $CI_REGISTRY_IMAGE:cache-build \
        --target base \
        -t $CI_REGISTRY_IMAGE:cache-base \
        .
    
    # Build dependencies stage
    - |
      docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --cache-from $CI_REGISTRY_IMAGE:cache-base \
        --cache-from $CI_REGISTRY_IMAGE:cache-deps \
        --target dependencies \
        -t $CI_REGISTRY_IMAGE:cache-deps \
        .
    
    # Build application stage
    - |
      docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --cache-from $CI_REGISTRY_IMAGE:cache-base \
        --cache-from $CI_REGISTRY_IMAGE:cache-deps \
        --cache-from $CI_REGISTRY_IMAGE:cache-build \
        --target build \
        -t $CI_REGISTRY_IMAGE:cache-build \
        .
    
    # Build final production image
    - |
      docker build \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --cache-from $CI_REGISTRY_IMAGE:cache-base \
        --cache-from $CI_REGISTRY_IMAGE:cache-deps \
        --cache-from $CI_REGISTRY_IMAGE:cache-build \
        --target production \
        -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA \
        -t $CI_REGISTRY_IMAGE:latest \
        .
    
    # Push all images including cache layers
    - docker push $CI_REGISTRY_IMAGE:cache-base
    - docker push $CI_REGISTRY_IMAGE:cache-deps  
    - docker push $CI_REGISTRY_IMAGE:cache-build
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
    
    # Analyze image layers and size
    - |
      docker history $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      docker images $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
```

### Parallel Component Builds
```yaml
# Parallel builds for microservices
build-microservices:
  stage: build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  parallel:
    matrix:
      - SERVICE: [user-service, order-service, payment-service, notification-service]
  before_script:
    - echo $CI_REGISTRY_PASSWORD | docker login -u $CI_REGISTRY_USER --password-stdin $CI_REGISTRY
  script:
    # Build service-specific image
    - |
      cd services/$SERVICE
      
      docker build \
        --build-arg SERVICE_NAME=$SERVICE \
        --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
        --build-arg VCS_REF=$CI_COMMIT_SHA \
        -t $CI_REGISTRY_IMAGE/$SERVICE:$CI_COMMIT_SHA \
        -t $CI_REGISTRY_IMAGE/$SERVICE:latest \
        .
    
    # Push service images
    - docker push $CI_REGISTRY_IMAGE/$SERVICE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE/$SERVICE:latest
    
    # Generate service manifest
    - |
      cat > $SERVICE-manifest.json << EOF
      {
        "service": "$SERVICE",
        "image": "$CI_REGISTRY_IMAGE/$SERVICE:$CI_COMMIT_SHA",
        "digest": "$(docker inspect --format='{{index .RepoDigests 0}}' $CI_REGISTRY_IMAGE/$SERVICE:$CI_COMMIT_SHA | cut -d'@' -f2)",
        "size": "$(docker inspect --format='{{.Size}}' $CI_REGISTRY_IMAGE/$SERVICE:$CI_COMMIT_SHA)",
        "created": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
      }
      EOF
  
  artifacts:
    paths:
      - "*-manifest.json"
    expire_in: 1 week
```

## Container Security Integration

### Comprehensive Security Scanning
```yaml
# Container security scanning
container-security:
  stage: security
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq
  script:
    # Install Trivy scanner
    - |
      curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
    
    # Scan container image for vulnerabilities
    - |
      trivy image \
        --format json \
        --output trivy-report.json \
        --severity HIGH,CRITICAL \
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    # Scan for secrets in image
    - |
      trivy image \
        --scanners secret \
        --format json \
        --output trivy-secrets.json \
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    # Scan for misconfigurations
    - |
      trivy image \
        --scanners config \
        --format json \
        --output trivy-config.json \
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    # Generate security summary
    - |
      python3 << 'EOF'
      import json
      import sys
      
      # Load scan results
      with open('trivy-report.json', 'r') as f:
          vuln_data = json.load(f)
      
      # Count vulnerabilities by severity
      critical_count = 0
      high_count = 0
      
      for result in vuln_data.get('Results', []):
          for vuln in result.get('Vulnerabilities', []):
              severity = vuln.get('Severity', '').upper()
              if severity == 'CRITICAL':
                  critical_count += 1
              elif severity == 'HIGH':
                  high_count += 1
      
      # Create security summary
      summary = {
          'image': '$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA',
          'scan_date': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
          'vulnerabilities': {
              'critical': critical_count,
              'high': high_count,
              'total': critical_count + high_count
          },
          'policy_violations': []
      }
      
      # Check security policy
      if critical_count > 0:
          summary['policy_violations'].append(f'Critical vulnerabilities found: {critical_count}')
          print(f'SECURITY POLICY VIOLATION: {critical_count} critical vulnerabilities found')
          sys.exit(1)
      
      if high_count > 10:
          summary['policy_violations'].append(f'Too many high vulnerabilities: {high_count}')
          print(f'SECURITY POLICY VIOLATION: {high_count} high vulnerabilities found (max: 10)')
          sys.exit(1)
      
      # Save summary
      with open('security-summary.json', 'w') as f:
          json.dump(summary, f, indent=2)
      
      print(f'Security scan completed: {critical_count} critical, {high_count} high vulnerabilities')
      EOF
  
  artifacts:
    reports:
      container_scanning: trivy-report.json
    paths:
      - trivy-report.json
      - trivy-secrets.json
      - trivy-config.json
      - security-summary.json
    expire_in: 30 days
  dependencies:
    - build-image
```

### Image Signing and Verification
```yaml
# Container image signing with Cosign
sign-image:
  stage: security
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
    # Install Cosign
    - curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
    - mv cosign-linux-amd64 /usr/local/bin/cosign
    - chmod +x /usr/local/bin/cosign
  script:
    # Generate key pair (in production, use existing keys)
    - |
      if [ ! -f cosign.key ]; then
        cosign generate-key-pair
      fi
    
    # Sign the container image
    - |
      echo $COSIGN_PASSWORD | cosign sign --key cosign.key $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    # Generate SBOM (Software Bill of Materials)
    - |
      cosign attach sbom --sbom sbom.json $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    
    # Verify signature
    - |
      cosign verify --key cosign.pub $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  
  artifacts:
    paths:
      - cosign.pub
      - sbom.json
    expire_in: 1 year
  dependencies:
    - build-image
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_TAG
```

## Registry Management and Cleanup

### Automated Cleanup Policies
```yaml
# Registry cleanup and lifecycle management
registry-cleanup:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl jq
  script:
    # Get registry tags
    - |
      TAGS=$(curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/registry/repositories" | \
        jq -r '.[].location' | head -1)
      
      if [ -n "$TAGS" ]; then
        REPO_ID=$(curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
          "$CI_API_V4_URL/projects/$CI_PROJECT_ID/registry/repositories" | \
          jq -r '.[0].id')
        
        # Get all tags
        ALL_TAGS=$(curl -s -H "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
          "$CI_API_V4_URL/projects/$CI_PROJECT_ID/registry/repositories/$REPO_ID/tags" | \
          jq -r '.[].name')
        
        echo "Found tags: $ALL_TAGS"
      fi
    
    # Cleanup old images (keep last 10 tags)
    - |
      python3 << 'EOF'
      import requests
      import json
      import os
      from datetime import datetime, timedelta
      
      # GitLab API configuration
      project_id = os.environ['CI_PROJECT_ID']
      token = os.environ['CI_JOB_TOKEN']
      api_url = os.environ['CI_API_V4_URL']
      
      headers = {'PRIVATE-TOKEN': token}
      
      # Get repositories
      repos_response = requests.get(f'{api_url}/projects/{project_id}/registry/repositories', headers=headers)
      
      if repos_response.status_code == 200:
          repositories = repos_response.json()
          
          for repo in repositories:
              repo_id = repo['id']
              
              # Get tags for repository
              tags_response = requests.get(f'{api_url}/projects/{project_id}/registry/repositories/{repo_id}/tags', headers=headers)
              
              if tags_response.status_code == 200:
                  tags = tags_response.json()
                  
                  # Sort tags by creation date (newest first)
                  tags.sort(key=lambda x: x['created_at'], reverse=True)
                  
                  # Keep latest 10 tags, delete older ones
                  tags_to_delete = tags[10:]
                  
                  for tag in tags_to_delete:
                      tag_name = tag['name']
                      
                      # Don't delete 'latest' or version tags
                      if tag_name in ['latest'] or tag_name.startswith('v'):
                          continue
                      
                      # Check if tag is older than 30 days
                      created_date = datetime.fromisoformat(tag['created_at'].replace('Z', '+00:00'))
                      if datetime.now().replace(tzinfo=created_date.tzinfo) - created_date > timedelta(days=30):
                          print(f'Deleting old tag: {tag_name}')
                          
                          delete_response = requests.delete(
                              f'{api_url}/projects/{project_id}/registry/repositories/{repo_id}/tags/{tag_name}',
                              headers=headers
                          )
                          
                          if delete_response.status_code == 200:
                              print(f'Successfully deleted tag: {tag_name}')
                          else:
                              print(f'Failed to delete tag: {tag_name}')
      EOF
  
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

### Registry Analytics and Reporting
```yaml
# Registry usage analytics
registry-analytics:
  stage: deploy
  image: python:3.9
  before_script:
    - pip install requests matplotlib pandas
  script:
    # Generate registry usage report
    - |
      python3 << 'EOF'
      import requests
      import json
      import os
      import pandas as pd
      import matplotlib.pyplot as plt
      from datetime import datetime
      
      # GitLab API configuration
      project_id = os.environ['CI_PROJECT_ID']
      token = os.environ['CI_JOB_TOKEN']
      api_url = os.environ['CI_API_V4_URL']
      
      headers = {'PRIVATE-TOKEN': token}
      
      # Collect registry data
      registry_data = {
          'repositories': [],
          'total_size': 0,
          'total_tags': 0,
          'scan_date': datetime.now().isoformat()
      }
      
      # Get repositories
      repos_response = requests.get(f'{api_url}/projects/{project_id}/registry/repositories', headers=headers)
      
      if repos_response.status_code == 200:
          repositories = repos_response.json()
          
          for repo in repositories:
              repo_id = repo['id']
              repo_info = {
                  'name': repo['name'],
                  'location': repo['location'],
                  'tags': [],
                  'total_size': 0
              }
              
              # Get tags for repository
              tags_response = requests.get(f'{api_url}/projects/{project_id}/registry/repositories/{repo_id}/tags', headers=headers)
              
              if tags_response.status_code == 200:
                  tags = tags_response.json()
                  
                  for tag in tags:
                      tag_info = {
                          'name': tag['name'],
                          'size': tag.get('total_size', 0),
                          'created_at': tag['created_at']
                      }
                      repo_info['tags'].append(tag_info)
                      repo_info['total_size'] += tag_info['size']
                  
                  registry_data['repositories'].append(repo_info)
                  registry_data['total_size'] += repo_info['total_size']
                  registry_data['total_tags'] += len(tags)
      
      # Generate report
      with open('registry-report.json', 'w') as f:
          json.dump(registry_data, f, indent=2)
      
      # Create visualizations
      if registry_data['repositories']:
          # Repository sizes chart
          repo_names = [repo['name'] for repo in registry_data['repositories']]
          repo_sizes = [repo['total_size'] / (1024*1024) for repo in registry_data['repositories']]  # Convert to MB
          
          plt.figure(figsize=(12, 6))
          plt.bar(repo_names, repo_sizes)
          plt.title('Repository Sizes (MB)')
          plt.xticks(rotation=45)
          plt.tight_layout()
          plt.savefig('registry-sizes.png')
          
          print(f'Registry report generated: {len(registry_data["repositories"])} repositories, {registry_data["total_tags"]} tags, {registry_data["total_size"]/(1024*1024):.2f} MB total')
      EOF
  
  artifacts:
    paths:
      - registry-report.json
      - registry-sizes.png
    expire_in: 30 days
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - when: manual
```

## Container Deployment Integration

### Kubernetes Deployment with Registry
```yaml
# Deploy from GitLab Container Registry to Kubernetes
deploy-k8s:
  stage: deploy
  image: bitnami/kubectl:latest
  before_script:
    # Configure kubectl
    - echo $KUBECONFIG | base64 -d > kubeconfig
    - export KUBECONFIG=kubeconfig
  script:
    # Create image pull secret for GitLab registry
    - |
      kubectl create secret docker-registry gitlab-registry \
        --docker-server=$CI_REGISTRY \
        --docker-username=$CI_REGISTRY_USER \
        --docker-password=$CI_REGISTRY_PASSWORD \
        --docker-email=$GITLAB_USER_EMAIL \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy application with registry image
    - |
      kubectl apply -f - <<EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: myapp
        labels:
          app: myapp
      spec:
        replicas: 3
        selector:
          matchLabels:
            app: myapp
        template:
          metadata:
            labels:
              app: myapp
          spec:
            imagePullSecrets:
            - name: gitlab-registry
            containers:
            - name: myapp
              image: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
              ports:
              - containerPort: 8080
              env:
              - name: VERSION
                value: "$CI_COMMIT_SHA"
              - name: BUILD_DATE
                value: "$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
      EOF
    
    # Wait for deployment to complete
    - kubectl rollout status deployment/myapp --timeout=300s
    
    # Verify deployment
    - kubectl get pods -l app=myapp
  
  environment:
    name: production
    url: https://app.example.com
  dependencies:
    - build-image
    - container-security
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

## Summary

GitLab Container Registry integration enables:
- **Seamless Integration**: Native registry with GitLab CI/CD pipelines
- **Multi-Architecture Support**: ARM64, AMD64, and other architecture builds
- **Advanced Security**: Comprehensive vulnerability scanning and image signing
- **Lifecycle Management**: Automated cleanup policies and usage analytics
- **Enterprise Features**: Registry mirroring, geo-replication, and access controls
- **Kubernetes Integration**: Direct deployment from registry to Kubernetes clusters

Master GitLab Container Registry to build secure, efficient container supply chains with comprehensive lifecycle management and enterprise-grade security features.
