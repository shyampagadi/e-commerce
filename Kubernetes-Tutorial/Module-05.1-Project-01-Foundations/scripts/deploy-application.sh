#!/bin/bash

# E-commerce Foundation Infrastructure - Application Deployment Script
# This script deploys the e-commerce application to the Kubernetes cluster

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="ecommerce"
DATABASE_APP="ecommerce-database"
BACKEND_APP="ecommerce-backend"
FRONTEND_APP="ecommerce-frontend"
IMAGE_TAG="v1.0.0"
REGISTRY="localhost:5000"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        error "Namespace $NAMESPACE does not exist. Please create it first."
        exit 1
    fi
    
    success "Prerequisites check passed"
}

# Function to build and push container image
build_and_push_image() {
    log "Building and pushing container image..."
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        error "Docker is not running"
        exit 1
    fi
    
    # Build the image
    log "Building Docker image..."
    docker build -t $APP_NAME:$IMAGE_TAG ./backend
    
    # Tag for registry
    docker tag $APP_NAME:$IMAGE_TAG $REGISTRY/$APP_NAME:$IMAGE_TAG
    
    # Push to registry
    log "Pushing image to registry..."
    docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
    
    success "Image built and pushed successfully"
}

# Function to deploy application
deploy_application() {
    log "Deploying 3-tier e-commerce application..."
    
    # Apply namespace and resource quotas
    kubectl apply -f k8s-manifests/namespace.yaml
    
    # Deploy database
    log "Deploying database..."
    kubectl apply -f k8s-manifests/database-deployment.yaml
    kubectl apply -f k8s-manifests/database-service.yaml
    
    # Deploy backend
    log "Deploying backend..."
    kubectl apply -f k8s-manifests/backend-deployment.yaml
    kubectl apply -f k8s-manifests/backend-service.yaml
    
    # Deploy frontend
    log "Deploying frontend..."
    kubectl apply -f k8s-manifests/frontend-deployment.yaml
    kubectl apply -f k8s-manifests/frontend-service.yaml
    
    success "3-tier application deployed successfully"
}

# Function to wait for deployment
wait_for_deployment() {
    log "Waiting for all deployments to be ready..."
    
    # Wait for database deployment to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/$DATABASE_APP -n $NAMESPACE
    kubectl wait --for=condition=ready --timeout=300s pods -l app=$DATABASE_APP -n $NAMESPACE
    
    # Wait for backend deployment to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/$BACKEND_APP -n $NAMESPACE
    kubectl wait --for=condition=ready --timeout=300s pods -l app=$BACKEND_APP -n $NAMESPACE
    
    # Wait for frontend deployment to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/$FRONTEND_APP -n $NAMESPACE
    kubectl wait --for=condition=ready --timeout=300s pods -l app=$FRONTEND_APP -n $NAMESPACE
    
    success "All deployments are ready"
}

# Function to verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check pod status
    kubectl get pods -n $NAMESPACE
    
    # Check service status
    kubectl get svc -n $NAMESPACE
    
    # Check deployment status
    kubectl get deployment -n $NAMESPACE
    
    # Test application health
    log "Testing application health..."
    
    # Test database connectivity
    log "Testing database connectivity..."
    kubectl port-forward svc/$DATABASE_APP-service 5432:5432 -n $NAMESPACE &
    DB_PORT_FORWARD_PID=$!
    sleep 5
    
    # Test backend health
    log "Testing backend health..."
    kubectl port-forward svc/$BACKEND_APP-service 8080:80 -n $NAMESPACE &
    BACKEND_PORT_FORWARD_PID=$!
    sleep 5
    
    # Test frontend health
    log "Testing frontend health..."
    kubectl port-forward svc/$FRONTEND_APP-service 3000:80 -n $NAMESPACE &
    FRONTEND_PORT_FORWARD_PID=$!
    sleep 5
    
    # Test backend health endpoint
    if curl -f http://localhost:8080/health &> /dev/null; then
        success "Backend health check passed"
    else
        error "Backend health check failed"
        kill $DB_PORT_FORWARD_PID $BACKEND_PORT_FORWARD_PID $FRONTEND_PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    # Test frontend health endpoint
    if curl -f http://localhost:3000 &> /dev/null; then
        success "Frontend health check passed"
    else
        error "Frontend health check failed"
        kill $DB_PORT_FORWARD_PID $BACKEND_PORT_FORWARD_PID $FRONTEND_PORT_FORWARD_PID 2>/dev/null || true
        exit 1
    fi
    
    # Test API documentation
    if curl -f http://localhost:8080/docs &> /dev/null; then
        success "API documentation is accessible"
    else
        warning "API documentation is not accessible"
    fi
    
    # Clean up port forward
    kill $PORT_FORWARD_PID 2>/dev/null || true
    
    success "Deployment verification completed"
}

# Function to show deployment information
show_deployment_info() {
    echo ""
    echo "=========================================="
    echo "DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "=========================================="
    echo ""
    echo "Application Information:"
    echo "- Namespace: $NAMESPACE"
    echo "- Database: $DATABASE_APP"
    echo "- Backend: $BACKEND_APP"
    echo "- Frontend: $FRONTEND_APP"
    echo ""
    echo "Access Information:"
    echo "- Database: kubectl port-forward svc/$DATABASE_APP-service 5432:5432 -n $NAMESPACE"
    echo "- Backend API: kubectl port-forward svc/$BACKEND_APP-service 8080:80 -n $NAMESPACE"
    echo "- Frontend: kubectl port-forward svc/$FRONTEND_APP-service 3000:80 -n $NAMESPACE"
    echo ""
    echo "Health Checks:"
    echo "- Backend Health: curl http://localhost:8080/health"
    echo "- Frontend: curl http://localhost:3000"
    echo "- API Docs: curl http://localhost:8080/docs"
    echo ""
    echo "Useful Commands:"
    echo "- Check pods: kubectl get pods -n $NAMESPACE"
    echo "- Check services: kubectl get svc -n $NAMESPACE"
    echo "- Check database logs: kubectl logs -l app=$DATABASE_APP -n $NAMESPACE"
    echo "- Check backend logs: kubectl logs -l app=$BACKEND_APP -n $NAMESPACE"
    echo "- Check frontend logs: kubectl logs -l app=$FRONTEND_APP -n $NAMESPACE"
    echo "- Scale frontend: kubectl scale deployment $FRONTEND_APP --replicas=3 -n $NAMESPACE"
    echo ""
}

# Function to cleanup on failure
cleanup() {
    error "Deployment failed. Cleaning up..."
    
    # Delete database deployment and service
    kubectl delete deployment $DATABASE_APP -n $NAMESPACE --ignore-not-found=true
    kubectl delete service $DATABASE_APP-service -n $NAMESPACE --ignore-not-found=true
    
    # Delete backend deployment and service
    kubectl delete deployment $BACKEND_APP -n $NAMESPACE --ignore-not-found=true
    kubectl delete service $BACKEND_APP-service -n $NAMESPACE --ignore-not-found=true
    
    # Delete frontend deployment and service
    kubectl delete deployment $FRONTEND_APP -n $NAMESPACE --ignore-not-found=true
    kubectl delete service $FRONTEND_APP-service -n $NAMESPACE --ignore-not-found=true
    
    error "Cleanup completed"
}

# Set trap for cleanup on failure
trap cleanup EXIT

# Main function
main() {
    echo "=========================================="
    echo "3-Tier E-commerce Application Deployment"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-prerequisites)
                check_prerequisites
                exit 0
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --check-prerequisites    Check prerequisites only"
                echo "  --skip-build            Skip image build and push"
                echo "  --help                 Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Run deployment steps
    check_prerequisites
    
    if [[ "${SKIP_BUILD:-false}" != "true" ]]; then
        build_and_push_image
    fi
    
    deploy_application
    wait_for_deployment
    verify_deployment
    show_deployment_info
    
    # Clear trap on success
    trap - EXIT
    
    success "Application deployment completed successfully!"
}

# Run main function
main "$@"
