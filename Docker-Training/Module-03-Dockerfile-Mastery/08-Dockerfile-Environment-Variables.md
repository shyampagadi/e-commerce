# Dockerfile Environment Variables Mastery

## Table of Contents
1. [Environment Variable Fundamentals](#environment-variable-fundamentals)
2. [ENV vs ARG Instructions](#env-vs-arg-instructions)
3. [Build-Time Variables](#build-time-variables)
4. [Runtime Configuration](#runtime-configuration)
5. [Security Considerations](#security-considerations)
6. [Advanced Patterns](#advanced-patterns)

## Environment Variable Fundamentals

### Basic ENV Usage
```dockerfile
FROM alpine:3.18

# Set environment variables
ENV APP_NAME=myapp
ENV APP_VERSION=1.0.0
ENV NODE_ENV=production
ENV PORT=3000

# Multi-line format
ENV APP_NAME=myapp \
    APP_VERSION=1.0.0 \
    NODE_ENV=production \
    PORT=3000

# Use in subsequent instructions
RUN echo "Building $APP_NAME version $APP_VERSION"
WORKDIR /app
EXPOSE $PORT
```

### Environment Variable Inheritance
```dockerfile
FROM node:18-alpine

# Base environment
ENV NODE_ENV=production
ENV LOG_LEVEL=info

# Application-specific environment
ENV APP_NAME=myapp
ENV APP_PORT=3000
ENV DATABASE_URL=postgresql://localhost:5432/myapp

# Derived variables
ENV APP_URL=http://localhost:$APP_PORT
ENV LOG_FILE=/var/log/$APP_NAME.log
```

## ENV vs ARG Instructions

### ARG - Build-Time Variables
```dockerfile
# ARG values are available only during build
ARG NODE_VERSION=18
ARG ALPINE_VERSION=3.18
ARG BUILD_DATE
ARG VERSION

FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

# ARG can be used in FROM instruction
ARG BASE_IMAGE=alpine:3.18
FROM $BASE_IMAGE

# ARG values don't persist in final image
RUN echo "Building version $VERSION on $BUILD_DATE"
```

### ENV - Runtime Variables
```dockerfile
FROM alpine:3.18

# ENV values persist in final image
ENV APP_ENV=production
ENV DEBUG=false
ENV LOG_LEVEL=info

# ENV can reference other ENV variables
ENV APP_HOME=/app
ENV APP_CONFIG=$APP_HOME/config
ENV APP_LOGS=$APP_HOME/logs

# Available at runtime
CMD echo "Running in $APP_ENV mode with log level $LOG_LEVEL"
```

### ARG to ENV Pattern
```dockerfile
# Accept build argument
ARG APP_VERSION=1.0.0
ARG NODE_ENV=production

# Convert to environment variable for runtime
ENV APP_VERSION=$APP_VERSION
ENV NODE_ENV=$NODE_ENV

# Now available at both build and runtime
RUN echo "Building version $APP_VERSION"
CMD echo "Running version $APP_VERSION in $NODE_ENV"
```

## Build-Time Variables

### 1. Version and Metadata
```dockerfile
ARG BUILD_DATE
ARG VERSION
ARG COMMIT_SHA
ARG BRANCH

FROM alpine:3.18

# Add build metadata
LABEL build.date=$BUILD_DATE
LABEL build.version=$VERSION
LABEL build.commit=$COMMIT_SHA
LABEL build.branch=$BRANCH

# Use in build process
RUN echo "Building $VERSION from commit $COMMIT_SHA"
```

### 2. Conditional Builds
```dockerfile
ARG BUILD_ENV=production
ARG INCLUDE_DEV_TOOLS=false

FROM node:18-alpine

# Conditional package installation
RUN if [ "$BUILD_ENV" = "development" ]; then \
        npm install -g nodemon; \
    fi

# Conditional dev tools
RUN if [ "$INCLUDE_DEV_TOOLS" = "true" ]; then \
        apk add --no-cache curl vim; \
    fi
```

### 3. Multi-Architecture Builds
```dockerfile
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

FROM alpine:3.18

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"
RUN echo "Target OS: $TARGETOS, Target Arch: $TARGETARCH"

# Architecture-specific logic
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        echo "ARM64 specific setup"; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        echo "AMD64 specific setup"; \
    fi
```

## Runtime Configuration

### 1. Application Configuration
```dockerfile
FROM node:18-alpine

# Server configuration
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production

# Database configuration
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=myapp
ENV DB_USER=postgres
ENV DB_PASSWORD_FILE=/run/secrets/db_password

# Logging configuration
ENV LOG_LEVEL=info
ENV LOG_FORMAT=json
ENV LOG_FILE=/var/log/app.log

# Feature flags
ENV FEATURE_NEW_UI=true
ENV FEATURE_ANALYTICS=false
ENV FEATURE_CACHE=true

EXPOSE $PORT
CMD ["npm", "start"]
```

### 2. Service Discovery
```dockerfile
FROM alpine:3.18

# Service endpoints
ENV REDIS_URL=redis://localhost:6379
ENV ELASTICSEARCH_URL=http://localhost:9200
ENV RABBITMQ_URL=amqp://localhost:5672

# API endpoints
ENV AUTH_SERVICE_URL=http://auth-service:8080
ENV USER_SERVICE_URL=http://user-service:8080
ENV PAYMENT_SERVICE_URL=http://payment-service:8080

# Timeout configurations
ENV HTTP_TIMEOUT=30s
ENV DB_TIMEOUT=10s
ENV CACHE_TIMEOUT=5s
```

### 3. Performance Tuning
```dockerfile
FROM openjdk:17-jre-slim

# JVM configuration
ENV JAVA_OPTS="-Xms512m -Xmx1024m"
ENV GC_OPTS="-XX:+UseG1GC -XX:+UseStringDeduplication"
ENV JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999"

# Application performance
ENV THREAD_POOL_SIZE=10
ENV CONNECTION_POOL_SIZE=20
ENV CACHE_SIZE=1000

# Combined JVM options
ENV JAVA_TOOL_OPTIONS="$JAVA_OPTS $GC_OPTS $JMX_OPTS"
```

## Security Considerations

### 1. Secrets Management
```dockerfile
FROM alpine:3.18

# ❌ Don't embed secrets in ENV
# ENV API_KEY=secret123
# ENV DATABASE_PASSWORD=password

# ✅ Use file-based secrets
ENV API_KEY_FILE=/run/secrets/api_key
ENV DATABASE_PASSWORD_FILE=/run/secrets/db_password
ENV JWT_SECRET_FILE=/run/secrets/jwt_secret

# ✅ Use external secret management
ENV VAULT_ADDR=https://vault.company.com
ENV VAULT_ROLE=myapp
ENV AWS_SECRETS_REGION=us-west-2
```

### 2. Environment Validation
```dockerfile
FROM alpine:3.18

# Required environment variables
ENV REQUIRED_VARS="DATABASE_URL,API_KEY_FILE,JWT_SECRET_FILE"

# Validation script
COPY validate-env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/validate-env.sh

# Validate on startup
CMD ["/usr/local/bin/validate-env.sh", "&&", "./app"]
```

### 3. Sensitive Data Handling
```dockerfile
FROM alpine:3.18

# Non-sensitive configuration
ENV APP_NAME=myapp
ENV LOG_LEVEL=info
ENV FEATURE_FLAGS=analytics,monitoring

# Sensitive data references (not values)
ENV DATABASE_URL_FILE=/run/secrets/database_url
ENV ENCRYPTION_KEY_FILE=/run/secrets/encryption_key

# Security labels
LABEL security.secrets="database_url,encryption_key"
LABEL security.env-validation="required"
```

## Advanced Patterns

### 1. Dynamic Environment Variables
```dockerfile
FROM alpine:3.18

# Base configuration
ENV CONFIG_DIR=/app/config
ENV ENVIRONMENT=production

# Dynamic configuration loading
ENV CONFIG_FILE=$CONFIG_DIR/$ENVIRONMENT.json
ENV LOG_CONFIG=$CONFIG_DIR/logging-$ENVIRONMENT.json

# Template-based configuration
ENV TEMPLATE_DIR=/app/templates
ENV RENDERED_CONFIG=/tmp/config.rendered
```

### 2. Environment Inheritance Chain
```dockerfile
# Base image with common environment
FROM alpine:3.18 AS base
ENV COMMON_VAR=value
ENV SHARED_CONFIG=/app/shared

# Development variant
FROM base AS development
ENV NODE_ENV=development
ENV DEBUG=true
ENV LOG_LEVEL=debug

# Production variant
FROM base AS production
ENV NODE_ENV=production
ENV DEBUG=false
ENV LOG_LEVEL=info

# Final stage selection
ARG BUILD_TARGET=production
FROM ${BUILD_TARGET} AS final
```

### 3. Configuration Templates
```dockerfile
FROM alpine:3.18

# Template variables
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=myapp

# Template processing
COPY config.template /app/
RUN envsubst < /app/config.template > /app/config.json

# Verification
RUN cat /app/config.json
```

### 4. Environment Variable Expansion
```dockerfile
FROM alpine:3.18

# Base paths
ENV APP_HOME=/app
ENV DATA_HOME=/data

# Expanded paths
ENV APP_CONFIG=${APP_HOME}/config
ENV APP_LOGS=${APP_HOME}/logs
ENV APP_CACHE=${DATA_HOME}/cache
ENV APP_UPLOADS=${DATA_HOME}/uploads

# Create directory structure
RUN mkdir -p $APP_CONFIG $APP_LOGS $APP_CACHE $APP_UPLOADS
```

## Environment Variable Best Practices

### 1. Naming Conventions
```dockerfile
FROM alpine:3.18

# Use consistent naming patterns
ENV APP_NAME=myapp
ENV APP_VERSION=1.0.0
ENV APP_ENVIRONMENT=production

# Group related variables
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_NAME=myapp
ENV DB_USER=postgres

# Use prefixes for namespacing
ENV MYAPP_LOG_LEVEL=info
ENV MYAPP_CACHE_TTL=3600
ENV MYAPP_FEATURE_X=true
```

### 2. Default Values and Documentation
```dockerfile
FROM alpine:3.18

# Documented environment variables with defaults
ENV PORT=3000 \
    # Port number for the web server
    LOG_LEVEL=info \
    # Logging level: debug, info, warn, error
    CACHE_TTL=3600 \
    # Cache time-to-live in seconds
    MAX_CONNECTIONS=100
    # Maximum number of concurrent connections

# Required variables (no defaults)
ENV DATABASE_URL="" \
    API_KEY_FILE="" \
    JWT_SECRET_FILE=""

LABEL env.port="Web server port (default: 3000)"
LABEL env.log_level="Logging level (default: info)"
LABEL env.database_url="Database connection string (required)"
```

### 3. Environment Validation Script
```dockerfile
FROM alpine:3.18

COPY validate-env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/validate-env.sh

# validate-env.sh content:
# #!/bin/sh
# required_vars="DATABASE_URL API_KEY_FILE"
# for var in $required_vars; do
#   if [ -z "$(eval echo \$$var)" ]; then
#     echo "Error: $var is required but not set"
#     exit 1
#   fi
# done

ENTRYPOINT ["/usr/local/bin/validate-env.sh"]
CMD ["./app"]
```

## Real-World Examples

### 1. Web Application Configuration
```dockerfile
FROM node:18-alpine

# Application metadata
ENV APP_NAME=ecommerce-api
ENV APP_VERSION=2.1.0
ENV NODE_ENV=production

# Server configuration
ENV HOST=0.0.0.0
ENV PORT=3000
ENV CORS_ORIGIN=https://myapp.com

# Database configuration
ENV DB_HOST=postgres
ENV DB_PORT=5432
ENV DB_NAME=ecommerce
ENV DB_POOL_MIN=2
ENV DB_POOL_MAX=10

# Redis configuration
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV REDIS_DB=0

# Authentication
ENV JWT_EXPIRES_IN=24h
ENV SESSION_TIMEOUT=1800

# Feature flags
ENV FEATURE_PAYMENTS=true
ENV FEATURE_ANALYTICS=true
ENV FEATURE_RECOMMENDATIONS=false

# Monitoring
ENV METRICS_PORT=9090
ENV HEALTH_CHECK_PATH=/health

EXPOSE $PORT $METRICS_PORT
```

### 2. Microservice Configuration
```dockerfile
FROM openjdk:17-jre-slim

# Service identification
ENV SERVICE_NAME=user-service
ENV SERVICE_VERSION=1.5.2
ENV SERVICE_PORT=8080

# Service discovery
ENV EUREKA_URL=http://eureka:8761/eureka
ENV CONFIG_SERVER_URL=http://config-server:8888

# Database
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/users
ENV SPRING_DATASOURCE_USERNAME=userservice
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=validate

# Message queue
ENV SPRING_RABBITMQ_HOST=rabbitmq
ENV SPRING_RABBITMQ_PORT=5672
ENV SPRING_RABBITMQ_USERNAME=guest

# Observability
ENV MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,metrics,prometheus
ENV LOGGING_LEVEL_COM_COMPANY=INFO

# Performance
ENV SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
ENV SPRING_CACHE_TYPE=redis

EXPOSE $SERVICE_PORT
```

### 3. Multi-Environment Configuration
```dockerfile
ARG ENVIRONMENT=production

FROM node:18-alpine

# Environment-specific configuration
ENV ENVIRONMENT=$ENVIRONMENT

# Base configuration
ENV APP_NAME=myapp
ENV LOG_FORMAT=json

# Environment-specific values
RUN if [ "$ENVIRONMENT" = "development" ]; then \
        echo "LOG_LEVEL=debug" >> /app/.env && \
        echo "DEBUG=true" >> /app/.env; \
    elif [ "$ENVIRONMENT" = "staging" ]; then \
        echo "LOG_LEVEL=info" >> /app/.env && \
        echo "DEBUG=false" >> /app/.env; \
    else \
        echo "LOG_LEVEL=warn" >> /app/.env && \
        echo "DEBUG=false" >> /app/.env; \
    fi

# Load environment-specific configuration
COPY config/${ENVIRONMENT}.env /app/
```

This comprehensive guide covers all aspects of environment variable management in Dockerfiles, from basic usage to advanced security and configuration patterns.
