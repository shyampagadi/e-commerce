#!/bin/bash

# Spring PetClinic Microservices Deployment Script
# This script deploys the complete Spring PetClinic microservices platform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="petclinic"
TIMEOUT="300s"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to wait for deployment
wait_for_deployment() {
    local app_name=$1
    local timeout=${2:-300s}
    
    print_info "Waiting for $app_name to be ready..."
    if kubectl wait --for=condition=ready pod -l app=$app_name -n $NAMESPACE --timeout=$timeout; then
        print_status "$app_name is ready"
    else
        print_error "$app_name failed to become ready within $timeout"
        return 1
    fi
}

# Function to check if kubectl is available
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Function to create namespace
create_namespace() {
    print_info "Creating namespace: $NAMESPACE"
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        print_warning "Namespace $NAMESPACE already exists"
    else
        kubectl apply -f k8s-manifests/namespaces/petclinic-namespace.yml
        print_status "Namespace $NAMESPACE created"
    fi
}

# Function to deploy secrets
deploy_secrets() {
    print_info "Deploying secrets..."
    kubectl apply -f security/secrets/mysql-credentials.yml
    print_status "Secrets deployed"
}

# Function to deploy databases
deploy_databases() {
    print_info "Deploying databases..."
    
    # Deploy MySQL databases
    kubectl apply -f k8s-manifests/databases/mysql-customer/mysql-customers-deployment.yml
    kubectl apply -f k8s-manifests/databases/mysql-vet/mysql-vets-deployment.yml
    kubectl apply -f k8s-manifests/databases/mysql-visit/mysql-visits-deployment.yml
    
    # Wait for databases to be ready
    wait_for_deployment "mysql-customers" "600s"
    wait_for_deployment "mysql-vets" "600s"
    wait_for_deployment "mysql-visits" "600s"
    
    print_status "All databases deployed and ready"
}

# Function to deploy infrastructure services
deploy_infrastructure() {
    print_info "Deploying infrastructure services..."
    
    # Deploy Config Server
    kubectl apply -f k8s-manifests/services/config-server/config-server-deployment.yml
    wait_for_deployment "config-server"
    
    # Deploy Discovery Server (Eureka)
    kubectl apply -f k8s-manifests/services/discovery-server/discovery-server-deployment.yml
    wait_for_deployment "discovery-server"
    
    print_status "Infrastructure services deployed and ready"
}

# Function to deploy microservices
deploy_microservices() {
    print_info "Deploying microservices..."
    
    # Deploy Customer Service
    kubectl apply -f k8s-manifests/services/customer-service/customers-service-deployment.yml
    wait_for_deployment "customers-service"
    
    # Deploy Vets Service
    kubectl apply -f k8s-manifests/services/vet-service/vets-service-deployment.yml
    wait_for_deployment "vets-service"
    
    # Deploy Visits Service
    kubectl apply -f k8s-manifests/services/visit-service/visits-service-deployment.yml
    wait_for_deployment "visits-service"
    
    print_status "All microservices deployed and ready"
}

# Function to deploy gateway and admin
deploy_gateway_admin() {
    print_info "Deploying API Gateway and Admin Server..."
    
    # Deploy API Gateway
    kubectl apply -f k8s-manifests/services/api-gateway/api-gateway-deployment.yml
    wait_for_deployment "api-gateway"
    
    # Deploy Admin Server
    kubectl apply -f k8s-manifests/services/admin-server/admin-server-deployment.yml
    wait_for_deployment "admin-server"
    
    print_status "API Gateway and Admin Server deployed and ready"
}

# Function to verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl get pods -n $NAMESPACE
    echo ""
    
    echo "=== Services ==="
    kubectl get services -n $NAMESPACE
    echo ""
    
    echo "=== Persistent Volume Claims ==="
    kubectl get pvc -n $NAMESPACE
    echo ""
    
    # Check if all pods are running
    local failed_pods=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
    
    if [ "$failed_pods" -eq 0 ]; then
        print_status "All pods are running successfully!"
    else
        print_warning "$failed_pods pods are not in Running state"
        kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running
    fi
}

# Function to display access information
display_access_info() {
    print_info "Access Information:"
    echo ""
    echo "To access the applications, use port-forwarding:"
    echo ""
    echo "# PetClinic Application (API Gateway)"
    echo "kubectl port-forward -n $NAMESPACE svc/api-gateway 8080:8080"
    echo "Then open: http://localhost:8080"
    echo ""
    echo "# Eureka Discovery Server"
    echo "kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761"
    echo "Then open: http://localhost:8761"
    echo ""
    echo "# Spring Boot Admin Server"
    echo "kubectl port-forward -n $NAMESPACE svc/admin-server 9090:9090"
    echo "Then open: http://localhost:9090"
    echo ""
}

# Main deployment function
main() {
    echo "🏥 Spring PetClinic Microservices Deployment"
    echo "=============================================="
    echo ""
    
    check_prerequisites
    create_namespace
    deploy_secrets
    deploy_databases
    deploy_infrastructure
    deploy_microservices
    deploy_gateway_admin
    verify_deployment
    display_access_info
    
    echo ""
    print_status "🎉 Spring PetClinic Microservices Platform deployed successfully!"
    echo ""
    print_info "Next steps:"
    echo "1. Run validation tests: ./validation/comprehensive-tests.sh"
    echo "2. Set up monitoring: ./scripts/deployment/deploy-monitoring.sh"
    echo "3. Access the application using the port-forward commands above"
    echo ""
}

# Run main function
main "$@"
