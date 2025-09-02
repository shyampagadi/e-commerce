# 🤖 Scripting & Automation: Complete Guide for Docker

## 🎯 Learning Objectives
- Master bash scripting fundamentals
- Create automation scripts for Docker workflows
- Learn error handling and debugging techniques
- Build production-ready automation tools

---

## 📚 Bash Scripting Fundamentals

### Script Structure and Basics
```bash
#!/bin/bash
# Shebang line - specifies interpreter

# Script metadata
# Author: Your Name
# Date: 2024-01-15
# Purpose: Docker automation script
# Version: 1.0

# Exit on any error
set -e

# Exit on undefined variables
set -u

# Print commands as they execute (debugging)
# set -x

echo "Script starting..."
```

### Variables and Data Types
```bash
#!/bin/bash

# String variables
NAME="Docker Tutorial"
VERSION="1.0"
ENVIRONMENT="production"

# Numeric variables
PORT=8080
TIMEOUT=30
MAX_RETRIES=3

# Arrays
SERVICES=("frontend" "backend" "database")
PORTS=(3000 5000 5432)

# Environment variables
export DOCKER_HOST="unix:///var/run/docker.sock"
export COMPOSE_PROJECT_NAME="ecommerce"

# Command substitution
CURRENT_DATE=$(date +%Y-%m-%d)
CONTAINER_COUNT=$(docker ps -q | wc -l)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

echo "Project: $NAME v$VERSION"
echo "Running containers: $CONTAINER_COUNT"
echo "Disk usage: $DISK_USAGE"
```

### Conditional Statements
```bash
#!/bin/bash

# Simple if statement
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Running in production mode"
fi

# If-else statement
if [ $PORT -eq 80 ]; then
    echo "Using standard HTTP port"
else
    echo "Using custom port: $PORT"
fi

# Multiple conditions
if [ "$ENVIRONMENT" = "production" ] && [ $PORT -eq 80 ]; then
    echo "Production deployment on standard port"
elif [ "$ENVIRONMENT" = "staging" ]; then
    echo "Staging environment detected"
else
    echo "Development environment"
fi

# File/directory checks
if [ -f "docker-compose.yml" ]; then
    echo "Docker Compose file found"
fi

if [ -d "/var/lib/docker" ]; then
    echo "Docker is installed"
fi

# Numeric comparisons
if [ $CONTAINER_COUNT -gt 5 ]; then
    echo "Warning: Many containers running ($CONTAINER_COUNT)"
fi
```

### Loops and Iteration
```bash
#!/bin/bash

# For loop with array
SERVICES=("frontend" "backend" "database" "redis")

for service in "${SERVICES[@]}"; do
    echo "Processing service: $service"
    docker-compose logs --tail=10 "$service"
done

# For loop with range
for i in {1..5}; do
    echo "Attempt $i"
    if docker ps > /dev/null 2>&1; then
        echo "Docker is running"
        break
    fi
    sleep 2
done

# While loop
COUNTER=0
while [ $COUNTER -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:$PORT/health; then
        echo "Service is healthy"
        break
    fi
    echo "Waiting for service... ($((COUNTER + 1))/$MAX_RETRIES)"
    sleep 5
    COUNTER=$((COUNTER + 1))
done

# Read file line by line
while IFS= read -r line; do
    echo "Processing: $line"
done < "services.txt"
```

---

## 🔧 Functions and Modular Code

### Function Definition and Usage
```bash
#!/bin/bash

# Simple function
greet() {
    echo "Hello, $1!"
}

# Function with multiple parameters
deploy_service() {
    local service_name=$1
    local port=$2
    local environment=${3:-"development"}
    
    echo "Deploying $service_name on port $port in $environment"
    
    docker run -d \
        --name "$service_name" \
        -p "$port:$port" \
        -e "ENVIRONMENT=$environment" \
        "$service_name:latest"
}

# Function with return value
check_docker() {
    if command -v docker > /dev/null 2>&1; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Usage examples
greet "Docker User"
deploy_service "web-app" 3000 "production"

if check_docker; then
    echo "Docker is available"
else
    echo "Docker is not installed"
    exit 1
fi
```

### Advanced Function Examples
```bash
#!/bin/bash

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)  echo "[$timestamp] INFO: $message" ;;
        WARN)  echo "[$timestamp] WARN: $message" >&2 ;;
        ERROR) echo "[$timestamp] ERROR: $message" >&2 ;;
        DEBUG) [ "$DEBUG" = "true" ] && echo "[$timestamp] DEBUG: $message" ;;
    esac
}

# Docker container management
manage_container() {
    local action=$1
    local container_name=$2
    
    case $action in
        start)
            log INFO "Starting container: $container_name"
            docker start "$container_name"
            ;;
        stop)
            log INFO "Stopping container: $container_name"
            docker stop "$container_name"
            ;;
        restart)
            log INFO "Restarting container: $container_name"
            docker restart "$container_name"
            ;;
        status)
            if docker ps --format "{{.Names}}" | grep -q "^$container_name$"; then
                log INFO "Container $container_name is running"
                return 0
            else
                log WARN "Container $container_name is not running"
                return 1
            fi
            ;;
        *)
            log ERROR "Unknown action: $action"
            return 1
            ;;
    esac
}

# Health check function
health_check() {
    local service_url=$1
    local max_attempts=${2:-5}
    local delay=${3:-10}
    
    for attempt in $(seq 1 $max_attempts); do
        log INFO "Health check attempt $attempt/$max_attempts"
        
        if curl -f -s "$service_url/health" > /dev/null; then
            log INFO "Service is healthy"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log WARN "Service not ready, waiting ${delay}s..."
            sleep $delay
        fi
    done
    
    log ERROR "Service failed health check after $max_attempts attempts"
    return 1
}
```

---

## 🐳 Docker Automation Scripts

### Container Management Script
```bash
#!/bin/bash
# docker-manager.sh - Comprehensive Docker container management

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/docker-manager.log"
CONFIG_FILE="$SCRIPT_DIR/docker-config.conf"

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Default values
DEFAULT_TIMEOUT=${DEFAULT_TIMEOUT:-30}
DEFAULT_RETRIES=${DEFAULT_RETRIES:-3}
DEBUG=${DEBUG:-false}

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $level: $message" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log ERROR "$1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    command -v docker >/dev/null 2>&1 || error_exit "Docker is not installed"
    command -v docker-compose >/dev/null 2>&1 || error_exit "Docker Compose is not installed"
    
    if ! docker info >/dev/null 2>&1; then
        error_exit "Docker daemon is not running"
    fi
    
    log INFO "Prerequisites check passed"
}

# List containers with detailed information
list_containers() {
    local filter=${1:-""}
    
    log INFO "Listing containers${filter:+ with filter: $filter}"
    
    if [ -n "$filter" ]; then
        docker ps -a --filter "$filter" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
    else
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
    fi
}

# Start containers with health checks
start_containers() {
    local compose_file=${1:-"docker-compose.yml"}
    
    if [ ! -f "$compose_file" ]; then
        error_exit "Compose file not found: $compose_file"
    fi
    
    log INFO "Starting containers from $compose_file"
    docker-compose -f "$compose_file" up -d
    
    # Wait for containers to be healthy
    local services=$(docker-compose -f "$compose_file" config --services)
    for service in $services; do
        wait_for_container "$service"
    done
    
    log INFO "All containers started successfully"
}

# Wait for container to be healthy
wait_for_container() {
    local container_name=$1
    local timeout=${2:-$DEFAULT_TIMEOUT}
    local interval=5
    local elapsed=0
    
    log INFO "Waiting for container $container_name to be healthy"
    
    while [ $elapsed -lt $timeout ]; do
        if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
            # Check if container has health check
            if docker inspect "$container_name" | grep -q '"Health"'; then
                local health_status=$(docker inspect "$container_name" --format='{{.State.Health.Status}}')
                if [ "$health_status" = "healthy" ]; then
                    log INFO "Container $container_name is healthy"
                    return 0
                fi
            else
                log INFO "Container $container_name is running (no health check)"
                return 0
            fi
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
        log DEBUG "Waiting for $container_name... (${elapsed}s/${timeout}s)"
    done
    
    error_exit "Container $container_name failed to become healthy within ${timeout}s"
}

# Clean up resources
cleanup() {
    local force=${1:-false}
    
    log INFO "Cleaning up Docker resources"
    
    # Remove stopped containers
    docker container prune -f
    
    # Remove unused images
    if [ "$force" = "true" ]; then
        docker image prune -a -f
    else
        docker image prune -f
    fi
    
    # Remove unused volumes
    docker volume prune -f
    
    # Remove unused networks
    docker network prune -f
    
    log INFO "Cleanup completed"
}

# Main function
main() {
    case "${1:-help}" in
        start)
            check_prerequisites
            start_containers "${2:-docker-compose.yml}"
            ;;
        stop)
            docker-compose -f "${2:-docker-compose.yml}" down
            ;;
        restart)
            docker-compose -f "${2:-docker-compose.yml}" restart
            ;;
        list)
            list_containers "$2"
            ;;
        cleanup)
            cleanup "${2:-false}"
            ;;
        logs)
            docker-compose -f "${2:-docker-compose.yml}" logs -f "${3:-}"
            ;;
        help|*)
            cat << EOF
Usage: $0 {start|stop|restart|list|cleanup|logs} [options]

Commands:
  start [compose-file]     Start containers from compose file
  stop [compose-file]      Stop containers
  restart [compose-file]   Restart containers
  list [filter]           List containers with optional filter
  cleanup [force]         Clean up unused Docker resources
  logs [compose-file] [service]  Show logs

Examples:
  $0 start docker-compose.prod.yml
  $0 list "status=running"
  $0 cleanup force
  $0 logs docker-compose.yml frontend
EOF
            ;;
    esac
}

# Run main function with all arguments
main "$@"
```

### Deployment Automation Script
```bash
#!/bin/bash
# deploy.sh - Automated deployment script

set -euo pipefail

# Configuration
DEPLOY_ENV=${DEPLOY_ENV:-"staging"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
HEALTH_CHECK_URL=${HEALTH_CHECK_URL:-"http://localhost/health"}
BACKUP_ENABLED=${BACKUP_ENABLED:-"true"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging with colors
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."
    
    # Check Docker
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        return 1
    fi
    
    # Check disk space
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log_error "Disk usage is at ${disk_usage}% - deployment aborted"
        return 1
    fi
    
    # Check compose file
    if [ ! -f "docker-compose.${DEPLOY_ENV}.yml" ]; then
        log_error "Compose file not found: docker-compose.${DEPLOY_ENV}.yml"
        return 1
    fi
    
    # Validate compose file
    if ! docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" config >/dev/null; then
        log_error "Invalid compose file"
        return 1
    fi
    
    log_info "Pre-deployment checks passed"
}

# Backup current deployment
backup_deployment() {
    if [ "$BACKUP_ENABLED" != "true" ]; then
        log_info "Backup disabled, skipping..."
        return 0
    fi
    
    log_info "Creating deployment backup..."
    
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup compose file
    cp "docker-compose.${DEPLOY_ENV}.yml" "$backup_dir/"
    
    # Backup environment file
    if [ -f ".env.${DEPLOY_ENV}" ]; then
        cp ".env.${DEPLOY_ENV}" "$backup_dir/"
    fi
    
    # Export current container images
    local services=$(docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" config --services)
    for service in $services; do
        local image=$(docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" config | grep -A 5 "$service:" | grep "image:" | awk '{print $2}')
        if [ -n "$image" ]; then
            log_info "Backing up image: $image"
            docker save "$image" | gzip > "$backup_dir/${service}-image.tar.gz"
        fi
    done
    
    log_info "Backup created: $backup_dir"
    echo "$backup_dir" > .last_backup
}

# Deploy application
deploy_application() {
    log_info "Deploying application (Environment: $DEPLOY_ENV, Tag: $IMAGE_TAG)..."
    
    # Set image tag
    export IMAGE_TAG
    
    # Pull latest images
    log_info "Pulling latest images..."
    docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" pull
    
    # Start services
    log_info "Starting services..."
    docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" up -d
    
    # Wait for services to be ready
    log_info "Waiting for services to be ready..."
    sleep 10
    
    # Health check
    if ! health_check; then
        log_error "Health check failed - rolling back..."
        rollback_deployment
        return 1
    fi
    
    log_info "Deployment completed successfully"
}

# Health check
health_check() {
    local max_attempts=10
    local delay=10
    
    for attempt in $(seq 1 $max_attempts); do
        log_info "Health check attempt $attempt/$max_attempts"
        
        if curl -f -s "$HEALTH_CHECK_URL" >/dev/null; then
            log_info "Health check passed"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log_warn "Health check failed, retrying in ${delay}s..."
            sleep $delay
        fi
    done
    
    log_error "Health check failed after $max_attempts attempts"
    return 1
}

# Rollback deployment
rollback_deployment() {
    log_warn "Rolling back deployment..."
    
    if [ ! -f ".last_backup" ]; then
        log_error "No backup found for rollback"
        return 1
    fi
    
    local backup_dir=$(cat .last_backup)
    if [ ! -d "$backup_dir" ]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    # Stop current services
    docker-compose -f "docker-compose.${DEPLOY_ENV}.yml" down
    
    # Restore images
    for image_file in "$backup_dir"/*-image.tar.gz; do
        if [ -f "$image_file" ]; then
            log_info "Restoring image: $(basename "$image_file")"
            gunzip -c "$image_file" | docker load
        fi
    done
    
    # Start services with backup compose file
    if [ -f "$backup_dir/docker-compose.${DEPLOY_ENV}.yml" ]; then
        docker-compose -f "$backup_dir/docker-compose.${DEPLOY_ENV}.yml" up -d
    fi
    
    log_info "Rollback completed"
}

# Cleanup old backups
cleanup_backups() {
    log_info "Cleaning up old backups..."
    
    # Keep only last 5 backups
    if [ -d "backups" ]; then
        ls -t backups/ | tail -n +6 | while read -r old_backup; do
            log_info "Removing old backup: $old_backup"
            rm -rf "backups/$old_backup"
        done
    fi
}

# Main deployment function
main() {
    local action=${1:-deploy}
    
    case $action in
        deploy)
            pre_deployment_checks || exit 1
            backup_deployment || exit 1
            deploy_application || exit 1
            cleanup_backups
            ;;
        rollback)
            rollback_deployment || exit 1
            ;;
        health)
            health_check && log_info "Service is healthy" || log_error "Service is unhealthy"
            ;;
        *)
            cat << EOF
Usage: $0 {deploy|rollback|health}

Commands:
  deploy    Full deployment with backup and health checks
  rollback  Rollback to previous deployment
  health    Run health check only

Environment Variables:
  DEPLOY_ENV         Deployment environment (default: staging)
  IMAGE_TAG          Docker image tag (default: latest)
  HEALTH_CHECK_URL   Health check endpoint (default: http://localhost/health)
  BACKUP_ENABLED     Enable backup (default: true)

Examples:
  DEPLOY_ENV=production IMAGE_TAG=v1.2.3 $0 deploy
  $0 rollback
  $0 health
EOF
            ;;
    esac
}

# Run main function
main "$@"
```

---

## 🚀 Next Steps

You now have comprehensive scripting and automation knowledge:

- ✅ **Bash Scripting**: Variables, conditionals, loops, functions
- ✅ **Error Handling**: Robust error checking and logging
- ✅ **Docker Automation**: Container management and deployment scripts
- ✅ **Production Scripts**: Backup, rollback, and health checking
- ✅ **Best Practices**: Modular code, configuration management

**Module 1 Complete!** Ready for **Module 2: Docker Fundamentals** where you'll apply these skills to master Docker!
