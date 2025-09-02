# Environment Variables & Configuration - E-Commerce Multi-Environment Management

## 📋 Learning Objectives
- **Master** environment variable management across development, staging, and production
- **Understand** configuration strategies for multi-environment deployments
- **Apply** 12-factor app principles to e-commerce configuration
- **Build** secure and maintainable configuration management

---

## 🤔 The Configuration Challenge

### **The Problem: Hardcoded Configuration**
```javascript
// ❌ Bad: Hardcoded configuration
const config = {
  database: 'postgresql://admin:password123@localhost:5432/ecommerce',
  stripe: 'sk_live_real_stripe_key_exposed_in_code',
  jwt_secret: 'hardcoded_secret',
  redis: 'redis://localhost:6379'
};
```

### **The Solution: Environment-Based Configuration**
```javascript
// ✅ Good: Environment-based configuration
const config = {
  database: process.env.DATABASE_URL,
  stripe: process.env.STRIPE_SECRET_KEY,
  jwt_secret: process.env.JWT_SECRET,
  redis: process.env.REDIS_URL
};
```

---

## 🏗️ E-Commerce Multi-Environment Strategy

### **Environment Classification**
```yaml
# Development Environment
services:
  backend:
    environment:
      NODE_ENV: development
      DEBUG: "true"
      DATABASE_URL: postgresql://dev_user:dev_pass@database:5432/ecommerce_dev
      STRIPE_SECRET_KEY: sk_test_development_key
      LOG_LEVEL: debug

# Staging Environment  
services:
  backend:
    environment:
      NODE_ENV: staging
      DEBUG: "false"
      DATABASE_URL: postgresql://staging_user:staging_pass@database:5432/ecommerce_staging
      STRIPE_SECRET_KEY: sk_test_staging_key
      LOG_LEVEL: info

# Production Environment
services:
  backend:
    environment:
      NODE_ENV: production
      DEBUG: "false"
      DATABASE_URL: postgresql://prod_user:${PROD_DB_PASSWORD}@database:5432/ecommerce_prod
      STRIPE_SECRET_KEY: ${STRIPE_LIVE_SECRET_KEY}
      LOG_LEVEL: warn
```

### **Complete E-Commerce Configuration Management**

#### **Base Configuration (docker-compose.yml)**
```yaml
version: '3.8'

services:
  database:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-ecommerce}
      POSTGRES_USER: ${POSTGRES_USER:-ecommerce_admin}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data

  backend:
    build: ./backend
    environment:
      # Application Configuration
      NODE_ENV: ${NODE_ENV:-production}
      PORT: ${API_PORT:-8000}
      
      # Database Configuration
      DATABASE_URL: postgresql://${POSTGRES_USER:-ecommerce_admin}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB:-ecommerce}
      
      # Cache Configuration
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      
      # Security Configuration
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXPIRES_IN: ${JWT_EXPIRES_IN:-24h}
      BCRYPT_ROUNDS: ${BCRYPT_ROUNDS:-12}
      
      # Payment Configuration
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      STRIPE_WEBHOOK_SECRET: ${STRIPE_WEBHOOK_SECRET}
      
      # Email Configuration
      SENDGRID_API_KEY: ${SENDGRID_API_KEY}
      FROM_EMAIL: ${FROM_EMAIL:-noreply@ecommerce.com}
      
      # File Upload Configuration
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET_NAME: ${S3_BUCKET_NAME}
      S3_REGION: ${S3_REGION:-us-east-1}
      
      # Monitoring Configuration
      SENTRY_DSN: ${SENTRY_DSN}
      LOG_LEVEL: ${LOG_LEVEL:-info}
    
    env_file:
      - .env
      - .env.local
    
    depends_on:
      - database
      - redis

  frontend:
    build: ./frontend
    environment:
      # Build-time variables
      REACT_APP_API_URL: ${REACT_APP_API_URL:-http://localhost:8000}
      REACT_APP_STRIPE_PUBLISHABLE_KEY: ${STRIPE_PUBLISHABLE_KEY}
      REACT_APP_GOOGLE_ANALYTICS_ID: ${GOOGLE_ANALYTICS_ID}
      REACT_APP_SENTRY_DSN: ${FRONTEND_SENTRY_DSN}
      REACT_APP_ENV: ${NODE_ENV:-production}

volumes:
  postgres_data:
  redis_data:
```

#### **Development Override (docker-compose.override.yml)**
```yaml
version: '3.8'

services:
  database:
    ports:
      - "5432:5432"  # Expose for development tools
    environment:
      POSTGRES_PASSWORD: dev_password_123

  redis:
    ports:
      - "6379:6379"  # Expose for development tools
    command: redis-server --requirepass dev_redis_123

  backend:
    volumes:
      - ./backend:/app:cached
      - /app/node_modules
    environment:
      NODE_ENV: development
      DEBUG: "true"
      LOG_LEVEL: debug
      HOT_RELOAD: "true"
    ports:
      - "8000:8000"
      - "9229:9229"  # Debug port

  frontend:
    volumes:
      - ./frontend:/app:cached
      - /app/node_modules
    environment:
      REACT_APP_API_URL: http://localhost:8000
      FAST_REFRESH: "true"
    ports:
      - "3000:3000"
```

#### **Production Configuration (docker-compose.prod.yml)**
```yaml
version: '3.8'

services:
  database:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2.0'

  redis:
    command: redis-server --requirepass-file /run/secrets/redis_password --appendonly yes
    secrets:
      - redis_password
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  backend:
    environment:
      NODE_ENV: production
      DEBUG: "false"
      LOG_LEVEL: warn
    secrets:
      - jwt_secret
      - stripe_secret_key
      - sendgrid_api_key
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '1.0'

  frontend:
    environment:
      REACT_APP_ENV: production
    deploy:
      replicas: 2

secrets:
  db_password:
    external: true
  redis_password:
    external: true
  jwt_secret:
    external: true
  stripe_secret_key:
    external: true
  sendgrid_api_key:
    external: true
```

---

## 🔧 Advanced Configuration Patterns

### **1. Environment File Hierarchy**

#### **File Structure**
```
project/
├── .env                    # Default values (committed)
├── .env.local             # Local overrides (not committed)
├── .env.development       # Development specific
├── .env.staging          # Staging specific
├── .env.production       # Production specific (not committed)
└── .env.example          # Template file (committed)
```

#### **.env (Default Values)**
```bash
# .env - Default configuration (safe to commit)
NODE_ENV=development
API_PORT=8000
FRONTEND_PORT=3000

# Database defaults
POSTGRES_DB=ecommerce
POSTGRES_USER=ecommerce_admin

# Redis defaults
REDIS_PORT=6379

# Application defaults
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=12
LOG_LEVEL=info

# AWS defaults
S3_REGION=us-east-1

# Email defaults
FROM_EMAIL=noreply@ecommerce.com
```

#### **.env.local (Local Development)**
```bash
# .env.local - Local development overrides (not committed)
POSTGRES_PASSWORD=local_dev_password_123
REDIS_PASSWORD=local_redis_password_123
JWT_SECRET=local_jwt_secret_for_development_only
STRIPE_SECRET_KEY=sk_test_local_development_key
SENDGRID_API_KEY=SG.local_development_key
```

#### **.env.production (Production Secrets)**
```bash
# .env.production - Production secrets (not committed)
POSTGRES_PASSWORD=super_secure_production_password
REDIS_PASSWORD=super_secure_redis_password
JWT_SECRET=super_long_and_secure_jwt_secret_for_production
STRIPE_SECRET_KEY=sk_live_real_production_stripe_key
SENDGRID_API_KEY=SG.real_production_sendgrid_key
AWS_ACCESS_KEY_ID=AKIA_real_production_key
AWS_SECRET_ACCESS_KEY=real_production_secret_key
```

### **2. Configuration Validation**

#### **Backend Configuration Validation**
```javascript
// backend/config/index.js
const Joi = require('joi');

const configSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'staging', 'production').required(),
  PORT: Joi.number().port().default(8000),
  
  // Database
  DATABASE_URL: Joi.string().uri().required(),
  
  // Cache
  REDIS_URL: Joi.string().uri().required(),
  
  // Security
  JWT_SECRET: Joi.string().min(32).required(),
  JWT_EXPIRES_IN: Joi.string().default('24h'),
  BCRYPT_ROUNDS: Joi.number().min(10).max(15).default(12),
  
  // Payment
  STRIPE_SECRET_KEY: Joi.string().pattern(/^sk_(test_|live_)/).required(),
  STRIPE_WEBHOOK_SECRET: Joi.string().required(),
  
  // Email
  SENDGRID_API_KEY: Joi.string().pattern(/^SG\./).required(),
  FROM_EMAIL: Joi.string().email().required(),
  
  // File Upload
  AWS_ACCESS_KEY_ID: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional()
  }),
  AWS_SECRET_ACCESS_KEY: Joi.string().when('NODE_ENV', {
    is: 'production', 
    then: Joi.required(),
    otherwise: Joi.optional()
  }),
  S3_BUCKET_NAME: Joi.string().required(),
  S3_REGION: Joi.string().default('us-east-1'),
  
  // Monitoring
  SENTRY_DSN: Joi.string().uri().optional(),
  LOG_LEVEL: Joi.string().valid('error', 'warn', 'info', 'debug').default('info')
});

const { error, value: config } = configSchema.validate(process.env, {
  allowUnknown: true,
  stripUnknown: true
});

if (error) {
  throw new Error(`Configuration validation error: ${error.message}`);
}

module.exports = config;
```

### **3. Dynamic Configuration Loading**

#### **Environment-Specific Compose Files**
```bash
#!/bin/bash
# scripts/deploy.sh

ENVIRONMENT=${1:-development}

case $ENVIRONMENT in
  development)
    docker-compose \
      -f docker-compose.yml \
      -f docker-compose.override.yml \
      up -d
    ;;
  staging)
    docker-compose \
      -f docker-compose.yml \
      -f docker-compose.staging.yml \
      --env-file .env.staging \
      up -d
    ;;
  production)
    docker-compose \
      -f docker-compose.yml \
      -f docker-compose.prod.yml \
      --env-file .env.production \
      up -d
    ;;
  *)
    echo "Usage: $0 {development|staging|production}"
    exit 1
    ;;
esac
```

---

## 🧪 Hands-On Practice: Multi-Environment Setup

### **Exercise 1: Create Environment Files**

```bash
# Create environment file structure
mkdir -p config/environments

# Base configuration
cat > .env << 'EOF'
# Application
NODE_ENV=development
API_PORT=8000
FRONTEND_PORT=3000

# Database
POSTGRES_DB=ecommerce
POSTGRES_USER=ecommerce_admin

# Cache
REDIS_PORT=6379

# Security
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=12

# Email
FROM_EMAIL=noreply@ecommerce.local

# AWS
S3_REGION=us-east-1
S3_BUCKET_NAME=ecommerce-uploads-dev

# Monitoring
LOG_LEVEL=info
EOF

# Development environment
cat > .env.development << 'EOF'
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug

POSTGRES_PASSWORD=dev_password_123
REDIS_PASSWORD=dev_redis_123
JWT_SECRET=dev_jwt_secret_not_for_production
STRIPE_SECRET_KEY=sk_test_development_key
STRIPE_PUBLISHABLE_KEY=pk_test_development_key
SENDGRID_API_KEY=SG.development_key
EOF

# Production template
cat > .env.production.example << 'EOF'
NODE_ENV=production
DEBUG=false
LOG_LEVEL=warn

POSTGRES_PASSWORD=CHANGE_ME_SECURE_PASSWORD
REDIS_PASSWORD=CHANGE_ME_SECURE_REDIS_PASSWORD
JWT_SECRET=CHANGE_ME_VERY_LONG_SECURE_JWT_SECRET
STRIPE_SECRET_KEY=sk_live_CHANGE_ME
STRIPE_PUBLISHABLE_KEY=pk_live_CHANGE_ME
SENDGRID_API_KEY=SG.CHANGE_ME
AWS_ACCESS_KEY_ID=CHANGE_ME
AWS_SECRET_ACCESS_KEY=CHANGE_ME
S3_BUCKET_NAME=ecommerce-uploads-prod
SENTRY_DSN=https://CHANGE_ME@sentry.io/project
EOF
```

### **Exercise 2: Configuration Validation Script**

```bash
#!/bin/bash
# scripts/validate-config.sh

echo "Validating configuration..."

# Check required environment variables
REQUIRED_VARS=(
  "POSTGRES_PASSWORD"
  "REDIS_PASSWORD" 
  "JWT_SECRET"
  "STRIPE_SECRET_KEY"
  "SENDGRID_API_KEY"
)

MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    MISSING_VARS+=("$var")
  fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  printf '   %s\n' "${MISSING_VARS[@]}"
  exit 1
fi

# Validate JWT secret length
if [ ${#JWT_SECRET} -lt 32 ]; then
  echo "❌ JWT_SECRET must be at least 32 characters long"
  exit 1
fi

# Validate Stripe key format
if [[ ! $STRIPE_SECRET_KEY =~ ^sk_(test_|live_) ]]; then
  echo "❌ STRIPE_SECRET_KEY format is invalid"
  exit 1
fi

echo "✅ Configuration validation passed"
```

### **Exercise 3: Multi-Environment Deployment**

```bash
# Development deployment
./scripts/deploy.sh development

# Verify development environment
docker-compose exec backend node -e "console.log('Environment:', process.env.NODE_ENV)"
docker-compose exec backend node -e "console.log('Debug mode:', process.env.DEBUG)"

# Staging deployment
cp .env.production.example .env.staging
# Edit .env.staging with staging values
./scripts/deploy.sh staging

# Production deployment (with secrets)
docker secret create db_password ./secrets/db_password.txt
docker secret create jwt_secret ./secrets/jwt_secret.txt
./scripts/deploy.sh production
```

---

## 🔒 Security Best Practices

### **1. Secret Management**

#### **Docker Secrets (Production)**
```yaml
version: '3.8'

services:
  backend:
    environment:
      DATABASE_URL_FILE: /run/secrets/database_url
      JWT_SECRET_FILE: /run/secrets/jwt_secret
      STRIPE_SECRET_KEY_FILE: /run/secrets/stripe_secret
    secrets:
      - database_url
      - jwt_secret
      - stripe_secret

secrets:
  database_url:
    external: true
  jwt_secret:
    external: true
  stripe_secret:
    external: true
```

#### **Secret Loading in Application**
```javascript
// backend/utils/secrets.js
const fs = require('fs');

function loadSecret(secretName) {
  const secretFile = process.env[`${secretName.toUpperCase()}_FILE`];
  if (secretFile && fs.existsSync(secretFile)) {
    return fs.readFileSync(secretFile, 'utf8').trim();
  }
  return process.env[secretName.toUpperCase()];
}

module.exports = {
  database: {
    url: loadSecret('database_url')
  },
  jwt: {
    secret: loadSecret('jwt_secret')
  },
  stripe: {
    secretKey: loadSecret('stripe_secret_key')
  }
};
```

### **2. Environment Variable Security**

```bash
# .gitignore - Never commit secrets
.env.local
.env.production
.env.staging
secrets/
*.key
*.pem
```

---

## ✅ Knowledge Check: Configuration Mastery

### **Conceptual Understanding**
- [ ] Understands 12-factor app configuration principles
- [ ] Knows environment variable hierarchy and precedence
- [ ] Comprehends multi-environment deployment strategies
- [ ] Understands secret management and security practices
- [ ] Knows configuration validation and error handling

### **Practical Skills**
- [ ] Can create environment-specific configurations
- [ ] Knows how to manage secrets securely
- [ ] Can implement configuration validation
- [ ] Understands deployment automation for different environments
- [ ] Can troubleshoot configuration issues

### **E-Commerce Application**
- [ ] Has implemented multi-environment configuration
- [ ] Created secure secret management system
- [ ] Set up configuration validation
- [ ] Implemented environment-specific deployments
- [ ] Documented configuration management procedures

---

## 🚀 Next Steps: Dependencies & Startup Order

### **What You've Mastered**
- ✅ **Environment variable management** across multiple environments
- ✅ **Configuration strategies** for development, staging, and production
- ✅ **Secret management** and security best practices
- ✅ **Configuration validation** and error handling
- ✅ **Multi-environment deployment** automation

### **Coming Next: Dependencies & Startup Order**
In **08-Dependencies-Startup-Order.md**, you'll learn:
- **Service dependency management** and startup orchestration
- **Health checks** and readiness probes
- **Graceful startup and shutdown** procedures
- **Failure recovery** and restart strategies

**Continue when you have successfully implemented multi-environment configuration management for your e-commerce platform.**
