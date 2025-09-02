# Security Best Practices - E-Commerce Security Hardening

## 📋 Learning Objectives
- **Master** container security hardening and vulnerability management
- **Understand** network security and access controls for e-commerce
- **Apply** secret management and encryption best practices
- **Build** comprehensive security monitoring and incident response

---

## 🔒 E-Commerce Security Threat Landscape

### **Critical E-Commerce Assets to Protect**
```
High-Value Targets:
├── Customer Data (PII, payment info, addresses)
├── Payment Processing (credit cards, transactions)
├── Business Logic (pricing, inventory, promotions)
├── Authentication Systems (user accounts, admin access)
├── Database (customer records, order history)
└── Infrastructure (servers, networks, APIs)
```

### **Common Attack Vectors**
```
Container-Specific Threats:
├── Vulnerable base images
├── Exposed secrets in environment variables
├── Privileged container execution
├── Insecure network configurations
├── Unpatched dependencies
└── Container escape vulnerabilities

E-Commerce Specific Threats:
├── SQL injection attacks
├── Cross-site scripting (XSS)
├── Payment card data theft
├── Session hijacking
├── API abuse and rate limiting bypass
└── Admin panel unauthorized access
```

---

## 🛡️ Comprehensive Security Implementation

### **1. Container Security Hardening**

#### **Secure Base Images**
```yaml
version: '3.8'

services:
  # ✅ Use official, minimal, and specific versions
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.secure
    # Use distroless or alpine images
    # Pin specific versions
    # Scan for vulnerabilities

  # ❌ Avoid these patterns
  # image: node:latest              # Unpredictable updates
  # image: ubuntu:20.04             # Large attack surface
  # image: custom-image:dev         # Unknown security posture
```

#### **Secure Dockerfile Practices**
```dockerfile
# Dockerfile.secure
FROM node:16-alpine AS base

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Copy application code
COPY --chown=nodejs:nodejs . .

# Remove unnecessary files
RUN rm -rf .git .gitignore README.md docs/ tests/

# Switch to non-root user
USER nodejs

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["node", "server.js"]
```

#### **Security-Hardened Compose Configuration**
```yaml
version: '3.8'

services:
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: ecommerce_user
      # Use secrets instead of environment variables
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - database_network  # Isolated network
    # Security options
    security_opt:
      - no-new-privileges:true
    read_only: true  # Read-only root filesystem
    tmpfs:
      - /tmp
      - /var/run/postgresql
    # Resource limits prevent DoS
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'
    # No port exposure - internal only
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ecommerce_user -d ecommerce"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.secure
    environment:
      NODE_ENV: production
      # Use file-based secrets
      DATABASE_URL_FILE: /run/secrets/database_url
      JWT_SECRET_FILE: /run/secrets/jwt_secret
      STRIPE_SECRET_KEY_FILE: /run/secrets/stripe_secret
    secrets:
      - database_url
      - jwt_secret
      - stripe_secret
    volumes:
      # Read-only application code
      - ./backend:/app:ro
      # Writable directories
      - uploads:/app/uploads
      - logs:/app/logs
    networks:
      - api_network
      - database_network
    # Security hardening
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /app/tmp
    # Run as non-root user
    user: "1001:1001"
    # Capability restrictions
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if binding to port < 1024
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
    depends_on:
      database:
        condition: service_healthy

  # Web Application Firewall
  waf:
    image: owasp/modsecurity-crs:apache
    environment:
      BACKEND_HOST: backend
      BACKEND_PORT: 8000
      MODSEC_RULE_ENGINE: "On"
      MODSEC_AUDIT_ENGINE: "RelevantOnly"
    volumes:
      - ./waf/custom-rules:/etc/modsecurity.d/custom-rules:ro
      - waf_logs:/var/log/apache2
    networks:
      - web_network
      - api_network
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend

networks:
  web_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.1.0/24
  
  api_network:
    driver: bridge
    internal: true  # No internet access
    ipam:
      config:
        - subnet: 172.20.2.0/24
  
  database_network:
    driver: bridge
    internal: true  # Completely isolated
    ipam:
      config:
        - subnet: 172.20.3.0/24

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind,uid=999,gid=999  # PostgreSQL user
      device: /secure/postgres/data
  uploads:
    driver: local
    driver_opts:
      type: none
      o: bind,uid=1001,gid=1001  # Application user
      device: /secure/uploads
  logs:
    driver: local
  waf_logs:
    driver: local

secrets:
  db_password:
    external: true
  database_url:
    external: true
  jwt_secret:
    external: true
  stripe_secret:
    external: true
```

### **2. Secret Management**

#### **Docker Secrets (Production)**
```bash
#!/bin/bash
# scripts/create-secrets.sh

# Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 64)

# Create secrets
echo "$DB_PASSWORD" | docker secret create db_password -
echo "$JWT_SECRET" | docker secret create jwt_secret -

# Create composite secrets
DATABASE_URL="postgresql://ecommerce_user:${DB_PASSWORD}@database:5432/ecommerce"
echo "$DATABASE_URL" | docker secret create database_url -

# Stripe secrets (from environment)
echo "$STRIPE_SECRET_KEY" | docker secret create stripe_secret -

echo "Secrets created successfully"
```

#### **Secret Loading in Application**
```javascript
// backend/config/secrets.js
const fs = require('fs');
const path = require('path');

class SecretManager {
  constructor() {
    this.secretsPath = '/run/secrets';
  }

  loadSecret(secretName) {
    // Try to load from Docker secret file
    const secretFile = process.env[`${secretName.toUpperCase()}_FILE`];
    if (secretFile && fs.existsSync(secretFile)) {
      return fs.readFileSync(secretFile, 'utf8').trim();
    }

    // Fallback to environment variable (development)
    const envValue = process.env[secretName.toUpperCase()];
    if (envValue) {
      return envValue;
    }

    throw new Error(`Secret ${secretName} not found`);
  }

  getConfig() {
    return {
      database: {
        url: this.loadSecret('database_url')
      },
      jwt: {
        secret: this.loadSecret('jwt_secret'),
        expiresIn: process.env.JWT_EXPIRES_IN || '24h'
      },
      stripe: {
        secretKey: this.loadSecret('stripe_secret_key')
      },
      sendgrid: {
        apiKey: this.loadSecret('sendgrid_api_key')
      }
    };
  }
}

module.exports = new SecretManager();
```

### **3. Network Security**

#### **Network Segmentation Strategy**
```yaml
# Network security architecture
networks:
  # DMZ - Public facing services
  dmz:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.1.0/24

  # Web tier - Frontend services
  web_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.2.0/24

  # API tier - Backend services
  api_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.3.0/24

  # Data tier - Database services
  data_tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.30.4.0/24

services:
  # Load balancer in DMZ (only service with internet access)
  loadbalancer:
    networks:
      - dmz
      - web_tier

  # Frontend in web tier
  frontend:
    networks:
      - web_tier
      - api_tier

  # Backend in API tier
  backend:
    networks:
      - api_tier
      - data_tier

  # Database in data tier (most isolated)
  database:
    networks:
      - data_tier
```

#### **Firewall Rules with iptables**
```bash
#!/bin/bash
# scripts/setup-firewall.sh

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (change port as needed)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow Docker daemon (if needed)
iptables -A INPUT -p tcp --dport 2376 -s 127.0.0.1 -j ACCEPT

# Docker network rules
iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Rate limiting for API endpoints
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

### **4. Application Security**

#### **Input Validation and Sanitization**
```javascript
// backend/middleware/validation.js
const joi = require('joi');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'"],
      connectSrc: ["'self'", "https://api.stripe.com"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // limit each IP to 5 login attempts per windowMs
  skipSuccessfulRequests: true
});

app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);

// Input validation schemas
const schemas = {
  user: joi.object({
    email: joi.string().email().required(),
    password: joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/).required(),
    firstName: joi.string().min(2).max(50).pattern(/^[a-zA-Z\s]+$/).required(),
    lastName: joi.string().min(2).max(50).pattern(/^[a-zA-Z\s]+$/).required()
  }),
  
  product: joi.object({
    name: joi.string().min(1).max(200).required(),
    price: joi.number().positive().precision(2).required(),
    description: joi.string().max(2000).optional(),
    category: joi.string().valid('electronics', 'clothing', 'books', 'home').required()
  })
};

// Validation middleware
function validate(schema) {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation failed',
        details: error.details.map(d => d.message)
      });
    }
    next();
  };
}

module.exports = { validate, schemas };
```

#### **SQL Injection Prevention**
```javascript
// backend/models/user.js
const { Pool } = require('pg');

class UserModel {
  constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
    });
  }

  // ✅ Safe: Using parameterized queries
  async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await this.pool.query(query, [email]);
    return result.rows[0];
  }

  // ✅ Safe: Using parameterized queries with multiple parameters
  async createUser(userData) {
    const query = `
      INSERT INTO users (email, password_hash, first_name, last_name, created_at)
      VALUES ($1, $2, $3, $4, NOW())
      RETURNING id, email, first_name, last_name, created_at
    `;
    const values = [userData.email, userData.passwordHash, userData.firstName, userData.lastName];
    const result = await this.pool.query(query, values);
    return result.rows[0];
  }

  // ❌ Dangerous: String concatenation (never do this)
  // async findByEmailUnsafe(email) {
  //   const query = `SELECT * FROM users WHERE email = '${email}'`;
  //   const result = await this.pool.query(query);
  //   return result.rows[0];
  // }
}

module.exports = UserModel;
```

---

## 🔍 Security Monitoring and Scanning

### **1. Vulnerability Scanning**

#### **Automated Image Scanning**
```bash
#!/bin/bash
# scripts/security-scan.sh

echo "Starting security scan..."

# Scan Docker images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce_backend:latest

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ecommerce_frontend:latest

# Scan for secrets in code
docker run --rm -v $(pwd):/app \
  trufflesecurity/trufflehog filesystem /app --only-verified

# Container runtime security scan
docker run --rm --pid=host --userns=host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /etc:/etc:ro \
  docker/docker-bench-security

echo "Security scan completed"
```

### **2. Runtime Security Monitoring**

#### **Falco Security Monitoring**
```yaml
# security/falco.yml
version: '3.8'

services:
  falco:
    image: falcosecurity/falco:latest
    privileged: true
    volumes:
      - /var/run/docker.sock:/host/var/run/docker.sock
      - /dev:/host/dev
      - /proc:/host/proc:ro
      - /boot:/host/boot:ro
      - /lib/modules:/host/lib/modules:ro
      - /usr:/host/usr:ro
      - /etc:/host/etc:ro
      - ./falco/falco.yaml:/etc/falco/falco.yaml:ro
      - ./falco/rules:/etc/falco/rules:ro
    environment:
      - FALCO_GRPC_ENABLED=true
      - FALCO_GRPC_BIND_ADDRESS=0.0.0.0:5060
    ports:
      - "5060:5060"
    networks:
      - monitoring_network
```

#### **Custom Falco Rules for E-Commerce**
```yaml
# falco/rules/ecommerce-rules.yaml
- rule: Unauthorized Database Access
  desc: Detect unauthorized access to database
  condition: >
    spawned_process and
    proc.name in (psql, mysql, mongo) and
    not user.name in (postgres, mysql, mongodb)
  output: >
    Unauthorized database access attempt
    (user=%user.name command=%proc.cmdline container=%container.name)
  priority: HIGH

- rule: Suspicious Payment Processing
  desc: Detect suspicious payment processing activity
  condition: >
    spawned_process and
    proc.cmdline contains "stripe" and
    not container.name contains "payment-service"
  output: >
    Suspicious payment processing outside designated service
    (command=%proc.cmdline container=%container.name)
  priority: CRITICAL

- rule: File System Modification in Read-Only Container
  desc: Detect file modifications in containers that should be read-only
  condition: >
    open_write and
    container.name in (ecommerce_backend, ecommerce_frontend) and
    not fd.directory in (/tmp, /app/logs, /app/uploads)
  output: >
    Unexpected file modification in read-only container
    (file=%fd.name container=%container.name)
  priority: HIGH
```

### **3. Log Security Analysis**

#### **ELK Stack for Security Logging**
```yaml
# security/elk-stack.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
      - xpack.security.enabled=true
      - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - elk_network

  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
      - ./logstash/config:/usr/share/logstash/config:ro
    environment:
      - "LS_JAVA_OPTS=-Xmx512m -Xms512m"
    networks:
      - elk_network
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - ELASTICSEARCH_USERNAME=elastic
      - ELASTICSEARCH_PASSWORD=${ELASTIC_PASSWORD}
    ports:
      - "5601:5601"
    networks:
      - elk_network
    depends_on:
      - elasticsearch

networks:
  elk_network:
    driver: bridge
```

---

## 🧪 Hands-On Practice: Security Implementation

### **Exercise 1: Security Hardening**

```bash
# Create secure secrets
./scripts/create-secrets.sh

# Deploy with security hardening
docker-compose -f docker-compose.yml -f docker-compose.security.yml up -d

# Verify security settings
docker-compose exec backend id  # Should show non-root user
docker-compose exec backend ls -la /  # Should show read-only filesystem
docker-compose exec database pg_isready  # Should work without exposed ports
```

### **Exercise 2: Vulnerability Scanning**

```bash
# Run comprehensive security scan
./scripts/security-scan.sh

# Check for exposed secrets
docker run --rm -v $(pwd):/app trufflesecurity/trufflehog filesystem /app

# Audit Docker configuration
docker run --rm -it --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
```

### **Exercise 3: Penetration Testing**

```bash
# Install OWASP ZAP for web application security testing
docker run -t owasp/zap2docker-stable zap-baseline.py -t https://your-ecommerce-site.com

# Test for common vulnerabilities
docker run --rm -it -v $(pwd):/zap/wrk/:rw \
  owasp/zap2docker-stable zap-full-scan.py \
  -t https://your-ecommerce-site.com \
  -g gen.conf -r testreport.html
```

---

## ✅ Knowledge Check: Security Mastery

### **Conceptual Understanding**
- [ ] Understands container security threats and mitigation strategies
- [ ] Knows secret management best practices
- [ ] Comprehends network security and segmentation
- [ ] Understands application security principles
- [ ] Knows security monitoring and incident response

### **Practical Skills**
- [ ] Can implement container security hardening
- [ ] Knows how to manage secrets securely
- [ ] Can configure network security and firewalls
- [ ] Understands vulnerability scanning and remediation
- [ ] Can set up security monitoring and alerting

### **E-Commerce Application**
- [ ] Has implemented comprehensive security hardening
- [ ] Set up secure secret management
- [ ] Configured network segmentation and access controls
- [ ] Implemented security monitoring and scanning
- [ ] Created incident response procedures

---

## 🚀 Next Steps: Monitoring & Logging

### **What You've Mastered**
- ✅ **Container security** hardening and vulnerability management
- ✅ **Network security** and access controls
- ✅ **Secret management** and encryption
- ✅ **Security monitoring** and incident response
- ✅ **Application security** best practices

### **Coming Next: Monitoring & Logging**
In **12-Monitoring-Logging.md**, you'll learn:
- **Comprehensive monitoring** strategies and metrics
- **Centralized logging** and log analysis
- **Alerting and notification** systems
- **Performance monitoring** and optimization

**Continue when you have successfully implemented comprehensive security hardening for your e-commerce platform.**
