#!/bin/bash

# 🐳 Docker Compose Management Script for E-Commerce Application
# Comprehensive management tool for all Docker Compose operations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="ecommerce"
DEFAULT_COMPOSE_FILE="docker-compose.yml"
DEV_COMPOSE_FILE="docker-compose.dev.yml"
PROD_COMPOSE_FILE="docker-compose.prod.yml"

# Function to print colored output
print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Function to select compose file
select_compose_file() {
    case "${ENVIRONMENT:-dev}" in
        "dev"|"development")
            COMPOSE_FILE=$DEV_COMPOSE_FILE
            ;;
        "prod"|"production")
            COMPOSE_FILE=$PROD_COMPOSE_FILE
            ;;
        *)
            COMPOSE_FILE=$DEFAULT_COMPOSE_FILE
            ;;
    esac
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_warning "Compose file $COMPOSE_FILE not found, using default"
        COMPOSE_FILE=$DEFAULT_COMPOSE_FILE
    fi
    
    print_info "Using compose file: $COMPOSE_FILE"
}

# Function to create necessary directories
setup_directories() {
    print_step "Creating necessary directories..."
    
    directories=(
        "data/postgres"
        "data/redis"
        "data/uploads"
        "logs/backend"
        "logs/nginx"
        "nginx/ssl"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        print_info "Created directory: $dir"
    done
    
    print_success "All directories created"
}

# Function to setup environment
setup_environment() {
    if [ ! -f .env ]; then
        print_step "Creating .env file from template..."
        if [ -f .env.example ]; then
            cp .env.example .env
            print_success "Environment file created from template"
            print_warning "Please review and update .env file with your settings"
        else
            print_error ".env.example not found. Please create .env file manually"
            exit 1
        fi
    else
        print_info ".env file already exists"
    fi
}

# Function to start services
start_services() {
    print_header "Starting E-Commerce Services"
    
    check_docker
    select_compose_file
    setup_directories
    setup_environment
    
    print_step "Starting services with $COMPOSE_FILE..."
    
    if [ "$1" = "--build" ]; then
        docker-compose -f "$COMPOSE_FILE" up --build -d
    else
        docker-compose -f "$COMPOSE_FILE" up -d
    fi
    
    print_success "Services started successfully"
    show_status
}

# Function to stop services
stop_services() {
    print_header "Stopping E-Commerce Services"
    
    select_compose_file
    
    print_step "Stopping services..."
    docker-compose -f "$COMPOSE_FILE" down
    
    print_success "Services stopped successfully"
}

# Function to restart services
restart_services() {
    print_header "Restarting E-Commerce Services"
    
    select_compose_file
    
    if [ -n "$1" ]; then
        print_step "Restarting service: $1"
        docker-compose -f "$COMPOSE_FILE" restart "$1"
        print_success "Service $1 restarted"
    else
        print_step "Restarting all services..."
        docker-compose -f "$COMPOSE_FILE" restart
        print_success "All services restarted"
    fi
}

# Function to show service status
show_status() {
    print_header "Service Status"
    
    select_compose_file
    
    echo -e "${CYAN}Container Status:${NC}"
    docker-compose -f "$COMPOSE_FILE" ps
    
    echo -e "\n${CYAN}Resource Usage:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    
    echo -e "\n${CYAN}Service Health:${NC}"
    check_service_health
}

# Function to check service health
check_service_health() {
    services=("database" "backend" "frontend")
    
    for service in "${services[@]}"; do
        container_name="${PROJECT_NAME}-${service}"
        if docker ps --format "{{.Names}}" | grep -q "$container_name"; then
            health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
            case $health in
                "healthy")
                    echo -e "${service}: ${GREEN}✓ Healthy${NC}"
                    ;;
                "unhealthy")
                    echo -e "${service}: ${RED}✗ Unhealthy${NC}"
                    ;;
                "starting")
                    echo -e "${service}: ${YELLOW}⚠ Starting${NC}"
                    ;;
                *)
                    echo -e "${service}: ${BLUE}- Running${NC}"
                    ;;
            esac
        else
            echo -e "${service}: ${RED}✗ Not Running${NC}"
        fi
    done
}

# Function to show logs
show_logs() {
    select_compose_file
    
    if [ -n "$1" ]; then
        print_info "Showing logs for service: $1"
        docker-compose -f "$COMPOSE_FILE" logs -f "$1"
    else
        print_info "Showing logs for all services"
        docker-compose -f "$COMPOSE_FILE" logs -f
    fi
}

# Function to execute commands in containers
exec_command() {
    select_compose_file
    
    service="$1"
    shift
    command="$@"
    
    if [ -z "$service" ]; then
        print_error "Please specify a service name"
        exit 1
    fi
    
    print_info "Executing command in $service: $command"
    docker-compose -f "$COMPOSE_FILE" exec "$service" $command
}

# Function to scale services
scale_services() {
    select_compose_file
    
    service="$1"
    replicas="$2"
    
    if [ -z "$service" ] || [ -z "$replicas" ]; then
        print_error "Usage: scale <service> <replicas>"
        exit 1
    fi
    
    print_step "Scaling $service to $replicas replicas..."
    docker-compose -f "$COMPOSE_FILE" up -d --scale "$service=$replicas"
    print_success "Service $service scaled to $replicas replicas"
}

# Function to backup database
backup_database() {
    print_header "Database Backup"
    
    select_compose_file
    
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="backup_${timestamp}.sql"
    
    print_step "Creating database backup..."
    docker-compose -f "$COMPOSE_FILE" exec -T database pg_dump -U postgres ecommerce_db > "data/backup/$backup_file"
    
    print_success "Database backup created: data/backup/$backup_file"
}

# Function to restore database
restore_database() {
    backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "Please specify backup file path"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_header "Database Restore"
    print_warning "This will overwrite the current database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        select_compose_file
        print_step "Restoring database from $backup_file..."
        docker-compose -f "$COMPOSE_FILE" exec -T database psql -U postgres ecommerce_db < "$backup_file"
        print_success "Database restored successfully"
    else
        print_info "Database restore cancelled"
    fi
}

# Function to clean up Docker resources
cleanup() {
    print_header "Docker Cleanup"
    
    select_compose_file
    
    print_warning "This will remove containers, networks, and optionally volumes and images"
    echo "Options:"
    echo "1. Remove containers and networks only"
    echo "2. Remove containers, networks, and volumes"
    echo "3. Remove everything (containers, networks, volumes, images)"
    echo "4. Cancel"
    
    read -p "Select option (1-4): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            docker-compose -f "$COMPOSE_FILE" down
            print_success "Containers and networks removed"
            ;;
        2)
            docker-compose -f "$COMPOSE_FILE" down -v
            print_success "Containers, networks, and volumes removed"
            ;;
        3)
            docker-compose -f "$COMPOSE_FILE" down -v --rmi all
            print_success "Everything removed"
            ;;
        4)
            print_info "Cleanup cancelled"
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
}

# Function to update services
update_services() {
    print_header "Updating Services"
    
    select_compose_file
    
    print_step "Pulling latest images..."
    docker-compose -f "$COMPOSE_FILE" pull
    
    print_step "Recreating services..."
    docker-compose -f "$COMPOSE_FILE" up -d --force-recreate
    
    print_success "Services updated successfully"
}

# Function to show help
show_help() {
    echo "🐳 Docker Compose Management Script for E-Commerce Application"
    echo ""
    echo "Usage: $0 [ENVIRONMENT=dev|prod] <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [--build]     Start all services (optionally rebuild)"
    echo "  stop               Stop all services"
    echo "  restart [service]  Restart all services or specific service"
    echo "  status             Show service status and health"
    echo "  logs [service]     Show logs for all services or specific service"
    echo "  exec <service> <command>  Execute command in service container"
    echo "  scale <service> <replicas>  Scale service to specified replicas"
    echo "  backup             Create database backup"
    echo "  restore <file>     Restore database from backup file"
    echo "  update             Update services to latest images"
    echo "  cleanup            Clean up Docker resources"
    echo "  help               Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  ENVIRONMENT        Set to 'dev', 'prod', or leave empty for default"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start with default compose file"
    echo "  ENVIRONMENT=dev $0 start    # Start with development compose file"
    echo "  $0 logs backend            # Show backend logs"
    echo "  $0 exec backend bash       # Open bash in backend container"
    echo "  $0 scale backend 3         # Scale backend to 3 replicas"
}

# Main script logic
case "${1:-}" in
    "start")
        start_services "$2"
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services "$2"
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "exec")
        shift
        exec_command "$@"
        ;;
    "scale")
        scale_services "$2" "$3"
        ;;
    "backup")
        backup_database
        ;;
    "restore")
        restore_database "$2"
        ;;
    "update")
        update_services
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "")
        print_error "No command specified"
        show_help
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
