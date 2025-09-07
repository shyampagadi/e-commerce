#!/bin/bash

# =============================================================================
# SPRING PETCLINIC MICROSERVICES DEPLOYMENT SCRIPT - COMPREHENSIVE DOCUMENTATION
# =============================================================================
# This script orchestrates the complete deployment of the Spring PetClinic
# microservices platform on Kubernetes. It implements a sequential deployment
# strategy with dependency management, health checks, and comprehensive validation.
#
# DEPLOYMENT PHILOSOPHY: This script follows the principle of ordered deployment
# with dependency resolution, ensuring that infrastructure services are ready
# before deploying dependent microservices.
#
# OPERATIONAL IMPACT: This script is the primary deployment automation tool,
# directly controlling the reliability and consistency of platform deployments
# across different environments.
# =============================================================================

# -----------------------------------------------------------------------------
# BASH SCRIPT CONFIGURATION - SAFETY AND ERROR HANDLING
# -----------------------------------------------------------------------------
# Exit immediately if any command fails
set -e
# ERROR_HANDLING: Ensures script stops on first error, preventing cascading failures
# FAIL_FAST: Prevents deployment of broken configurations
# PRODUCTION_SAFETY: Critical for automated deployment pipelines

# Additional bash safety options (recommended for production)
# set -u  # Exit on undefined variables
# set -o pipefail  # Exit on pipe failures
# BASH_SAFETY: Uncomment these for stricter error handling in production

# -----------------------------------------------------------------------------
# COLOR DEFINITIONS - ENHANCED USER EXPERIENCE
# -----------------------------------------------------------------------------
# ANSI color codes for terminal output formatting
RED='\033[0;31m'      # Error messages and failures
GREEN='\033[0;32m'    # Success messages and confirmations
YELLOW='\033[1;33m'   # Warning messages and cautions
BLUE='\033[0;34m'     # Informational messages
NC='\033[0m'          # No Color - resets terminal color
# COLOR_STRATEGY: Improves script output readability and user experience
# ACCESSIBILITY: Consider colorblind-friendly alternatives for production

# -----------------------------------------------------------------------------
# GLOBAL CONFIGURATION VARIABLES - DEPLOYMENT PARAMETERS
# -----------------------------------------------------------------------------
# Kubernetes namespace for PetClinic deployment
NAMESPACE="petclinic"
# NAMESPACE_ISOLATION: Provides resource isolation and access control
# MULTI_TENANCY: Enables multiple deployments in same cluster
# CLEANUP_SCOPE: Simplifies environment cleanup and management

# Default timeout for Kubernetes operations
TIMEOUT="300s"
# TIMEOUT_STRATEGY: 5-minute timeout balances responsiveness with reliability
# PRODUCTION_CONSIDERATION: Adjust based on cluster performance and network conditions
# FAILURE_DETECTION: Prevents indefinite waiting for failed deployments

# -----------------------------------------------------------------------------
# UTILITY FUNCTIONS - STANDARDIZED OUTPUT AND LOGGING
# -----------------------------------------------------------------------------
# Function to print success messages with green checkmark
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
    # SUCCESS_INDICATION: Clear visual feedback for successful operations
    # LOGGING_CONSISTENCY: Standardized success message format
    # UNICODE_SYMBOLS: Checkmark provides immediate visual confirmation
}

# Function to print informational messages with blue info icon
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    # INFORMATION_DISPLAY: Neutral informational messages
    # PROCESS_VISIBILITY: Keeps users informed of current operations
    # DEBUGGING_AID: Helps troubleshoot deployment issues
}

# Function to print warning messages with yellow warning icon
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    # WARNING_INDICATION: Non-critical issues that need attention
    # OPERATIONAL_AWARENESS: Alerts to potential problems
    # PREVENTIVE_COMMUNICATION: Helps prevent future issues
}

# Function to print error messages with red X icon
print_error() {
    echo -e "${RED}❌ $1${NC}"
    # ERROR_INDICATION: Clear identification of failures
    # TROUBLESHOOTING_AID: Helps identify specific failure points
    # CRITICAL_COMMUNICATION: Ensures errors are noticed
}

# -----------------------------------------------------------------------------
# DEPLOYMENT ORCHESTRATION FUNCTIONS - CORE DEPLOYMENT LOGIC
# -----------------------------------------------------------------------------
# Function to wait for Kubernetes deployment readiness
wait_for_deployment() {
    local app_name=$1          # Application name to wait for
    local timeout=${2:-300s}   # Timeout with default fallback
    # PARAMETER_HANDLING: Flexible timeout with sensible default
    # LOCAL_VARIABLES: Prevents variable pollution in global scope
    
    print_info "Waiting for $app_name to be ready..."
    # PROGRESS_INDICATION: Informs user of current waiting operation
    
    # Kubernetes wait command with pod readiness condition
    if kubectl wait --for=condition=ready pod -l app=$app_name -n $NAMESPACE --timeout=$timeout; then
        print_status "$app_name is ready"
        # SUCCESS_PATH: Confirms successful deployment readiness
    else
        print_error "$app_name failed to become ready within $timeout"
        return 1
        # FAILURE_PATH: Returns error code for calling function handling
        # TIMEOUT_HANDLING: Prevents indefinite waiting
    fi
    # KUBECTL_INTEGRATION: Uses native Kubernetes readiness checks
    # LABEL_SELECTOR: Targets pods by application label
}

# Function to validate deployment prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    # PREREQUISITE_VALIDATION: Ensures required tools and access are available
    
    # Check if kubectl command is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
        # TOOL_VALIDATION: Ensures kubectl is available for Kubernetes operations
        # EARLY_FAILURE: Fails fast if essential tools are missing
    fi
    
    # Check if kubectl can connect to Kubernetes cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
        # CONNECTIVITY_CHECK: Validates cluster access before deployment
        # AUTHENTICATION_VALIDATION: Ensures proper cluster credentials
    fi
    
    print_status "Prerequisites check passed"
    # VALIDATION_CONFIRMATION: Confirms all prerequisites are met
}

# Function to create or verify Kubernetes namespace
create_namespace() {
    print_info "Creating namespace: $NAMESPACE"
    # NAMESPACE_MANAGEMENT: Ensures deployment target namespace exists
    
    # Check if namespace already exists
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        print_warning "Namespace $NAMESPACE already exists"
        # IDEMPOTENT_OPERATION: Handles existing namespace gracefully
        # STATE_AWARENESS: Acknowledges existing infrastructure
    else
        # Create namespace using manifest file
        kubectl apply -f k8s-manifests/namespaces/petclinic-namespace.yml
        print_status "Namespace $NAMESPACE created"
        # MANIFEST_BASED: Uses declarative configuration for consistency
        # RESOURCE_CREATION: Establishes deployment boundary
    fi
}

# Function to deploy security credentials
deploy_secrets() {
    print_info "Deploying secrets..."
    # SECRET_MANAGEMENT: Deploys sensitive configuration data
    
    kubectl apply -f security/secrets/mysql-credentials.yml
    # CREDENTIAL_DEPLOYMENT: Applies database credentials to cluster
    # SECURITY_FOUNDATION: Establishes secure credential access for services
    
    print_status "Secrets deployed"
    # CONFIRMATION: Confirms successful secret deployment
}

# Function to deploy database infrastructure
deploy_databases() {
    print_info "Deploying databases..."
    # DATABASE_DEPLOYMENT: Establishes persistent data layer
    
    # Deploy MySQL databases for each microservice
    kubectl apply -f k8s-manifests/databases/mysql-customer/mysql-customers-deployment.yml
    kubectl apply -f k8s-manifests/databases/mysql-vet/mysql-vets-deployment.yml
    kubectl apply -f k8s-manifests/databases/mysql-visit/mysql-visits-deployment.yml
    # DATABASE_PER_SERVICE: Implements microservice data isolation pattern
    # PARALLEL_DEPLOYMENT: Deploys all databases simultaneously for efficiency
    
    # Wait for all databases to be ready with extended timeout
    wait_for_deployment "mysql-customers" "600s"
    wait_for_deployment "mysql-vets" "600s"
    wait_for_deployment "mysql-visits" "600s"
    # EXTENDED_TIMEOUT: Databases need more time for initialization
    # SEQUENTIAL_VALIDATION: Ensures each database is ready before proceeding
    # DEPENDENCY_FOUNDATION: Databases must be ready for microservice deployment
    
    print_status "All databases deployed and ready"
    # COMPLETION_CONFIRMATION: Confirms all database deployments successful
}

# Function to deploy core infrastructure services
deploy_infrastructure() {
    print_info "Deploying infrastructure services..."
    # INFRASTRUCTURE_DEPLOYMENT: Establishes core platform services
    
    # Deploy Config Server first (other services depend on it)
    kubectl apply -f k8s-manifests/services/config-server/config-server-deployment.yml
    wait_for_deployment "config-server"
    # CONFIG_SERVER_PRIORITY: Must be ready before other services start
    # CENTRALIZED_CONFIGURATION: Provides configuration to all microservices
    
    # Deploy Discovery Server (Eureka) after Config Server
    kubectl apply -f k8s-manifests/services/discovery-server/discovery-server-deployment.yml
    wait_for_deployment "discovery-server"
    # SERVICE_DISCOVERY: Enables microservice communication
    # DEPENDENCY_ORDER: Requires Config Server for its own configuration
    
    print_status "Infrastructure services deployed and ready"
    # INFRASTRUCTURE_CONFIRMATION: Core platform services are operational
}

# Function to deploy business microservices
deploy_microservices() {
    print_info "Deploying microservices..."
    # MICROSERVICE_DEPLOYMENT: Deploys business logic services
    
    # Deploy Customer Service
    kubectl apply -f k8s-manifests/services/customer-service/customers-service-deployment.yml
    wait_for_deployment "customers-service"
    # CUSTOMER_DOMAIN: Core business capability for customer management
    
    # Deploy Vets Service
    kubectl apply -f k8s-manifests/services/vet-service/vets-service-deployment.yml
    wait_for_deployment "vets-service"
    # VETERINARY_DOMAIN: Professional services management capability
    
    # Deploy Visits Service
    kubectl apply -f k8s-manifests/services/visit-service/visits-service-deployment.yml
    wait_for_deployment "visits-service"
    # APPOINTMENT_DOMAIN: Medical appointment and visit management
    
    print_status "All microservices deployed and ready"
    # BUSINESS_LOGIC_CONFIRMATION: All domain services are operational
}

# Function to deploy gateway and administrative services
deploy_gateway_admin() {
    print_info "Deploying API Gateway and Admin Server..."
    # GATEWAY_DEPLOYMENT: Establishes external access and monitoring
    
    # Deploy API Gateway (external access point)
    kubectl apply -f k8s-manifests/services/api-gateway/api-gateway-deployment.yml
    wait_for_deployment "api-gateway"
    # API_GATEWAY: Single entry point for external client access
    # TRAFFIC_ROUTING: Routes requests to appropriate microservices
    
    # Deploy Admin Server (monitoring and management)
    kubectl apply -f k8s-manifests/services/admin-server/admin-server-deployment.yml
    wait_for_deployment "admin-server"
    # ADMIN_SERVER: Centralized monitoring and management interface
    # OPERATIONAL_VISIBILITY: Provides system health and metrics
    
    print_status "API Gateway and Admin Server deployed and ready"
    # ACCESS_LAYER_CONFIRMATION: External access and monitoring ready
}

# Function to verify complete deployment status
verify_deployment() {
    print_info "Verifying deployment..."
    # DEPLOYMENT_VERIFICATION: Comprehensive status check of all components
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl get pods -n $NAMESPACE
    # POD_STATUS: Shows running status of all deployed pods
    # VISUAL_CONFIRMATION: Provides immediate deployment overview
    echo ""
    
    echo "=== Services ==="
    kubectl get services -n $NAMESPACE
    # SERVICE_STATUS: Shows network access configuration
    # CONNECTIVITY_VERIFICATION: Confirms service discovery setup
    echo ""
    
    echo "=== Persistent Volume Claims ==="
    kubectl get pvc -n $NAMESPACE
    # STORAGE_STATUS: Shows persistent storage allocation
    # DATA_PERSISTENCE: Confirms database storage configuration
    echo ""
    
    # Count pods not in Running state
    local failed_pods=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l)
    # FAILURE_DETECTION: Identifies pods that failed to start properly
    # AUTOMATED_VALIDATION: Programmatic health check
    
    if [ "$failed_pods" -eq 0 ]; then
        print_status "All pods are running successfully!"
        # SUCCESS_CONFIRMATION: All components deployed successfully
    else
        print_warning "$failed_pods pods are not in Running state"
        kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running
        # FAILURE_REPORTING: Shows specific failed pods for troubleshooting
        # DIAGNOSTIC_INFORMATION: Helps identify deployment issues
    fi
}

# Function to display application access instructions
display_access_info() {
    print_info "Access Information:"
    # ACCESS_GUIDANCE: Provides clear instructions for accessing deployed services
    echo ""
    echo "To access the applications, use port-forwarding:"
    echo ""
    echo "# PetClinic Application (API Gateway)"
    echo "kubectl port-forward -n $NAMESPACE svc/api-gateway 8080:8080"
    echo "Then open: http://localhost:8080"
    # APPLICATION_ACCESS: Primary user interface access
    echo ""
    echo "# Eureka Discovery Server"
    echo "kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761"
    echo "Then open: http://localhost:8761"
    # SERVICE_DISCOVERY_UI: Service registry visualization
    echo ""
    echo "# Spring Boot Admin Server"
    echo "kubectl port-forward -n $NAMESPACE svc/admin-server 9090:9090"
    echo "Then open: http://localhost:9090"
    # MONITORING_ACCESS: Administrative and monitoring interface
    echo ""
    # PORT_FORWARDING_STRATEGY: Provides local access without ingress configuration
    # DEVELOPMENT_FRIENDLY: Simple access method for development environments
}

# -----------------------------------------------------------------------------
# MAIN ORCHESTRATION FUNCTION - DEPLOYMENT WORKFLOW COORDINATION
# -----------------------------------------------------------------------------
# Main deployment orchestration function
main() {
    echo "🏥 Spring PetClinic Microservices Deployment"
    echo "=============================================="
    echo ""
    # DEPLOYMENT_HEADER: Clear identification of deployment process
    # VISUAL_SEPARATION: Improves script output readability
    
    # Execute deployment phases in dependency order
    check_prerequisites      # Validate environment and tools
    create_namespace        # Establish deployment boundary
    deploy_secrets         # Deploy security credentials
    deploy_databases       # Deploy data persistence layer
    deploy_infrastructure  # Deploy core platform services
    deploy_microservices   # Deploy business logic services
    deploy_gateway_admin   # Deploy access and monitoring layer
    verify_deployment      # Validate complete deployment
    display_access_info    # Provide access instructions
    # SEQUENTIAL_DEPLOYMENT: Each phase depends on previous phases
    # DEPENDENCY_MANAGEMENT: Ensures proper startup order
    # COMPREHENSIVE_DEPLOYMENT: Covers all platform components
    
    echo ""
    print_status "🎉 Spring PetClinic Microservices Platform deployed successfully!"
    echo ""
    print_info "Next steps:"
    echo "1. Run validation tests: ./validation/comprehensive-tests.sh"
    echo "2. Set up monitoring: ./scripts/deployment/deploy-monitoring.sh"
    echo "3. Access the application using the port-forward commands above"
    echo ""
    # POST_DEPLOYMENT_GUIDANCE: Clear next steps for users
    # OPERATIONAL_WORKFLOW: Guides users through complete setup process
}

# -----------------------------------------------------------------------------
# SCRIPT EXECUTION - ENTRY POINT AND PARAMETER HANDLING
# -----------------------------------------------------------------------------
# Execute main function with all script arguments
main "$@"
# PARAMETER_FORWARDING: Passes all command-line arguments to main function
# SCRIPT_ENTRY_POINT: Single point of execution for the entire deployment

# =============================================================================
# DEPLOYMENT SCRIPT ANALYSIS AND PRODUCTION ENHANCEMENTS
# =============================================================================
#
# SCRIPT STRENGTHS:
# ✅ DEPENDENCY_MANAGEMENT: Proper deployment order with dependency resolution
# ✅ ERROR_HANDLING: Fail-fast approach with comprehensive error checking
# ✅ USER_EXPERIENCE: Clear output with color coding and progress indicators
# ✅ IDEMPOTENT_OPERATIONS: Handles existing resources gracefully
# ✅ COMPREHENSIVE_VALIDATION: Thorough verification of deployment status
# ✅ OPERATIONAL_GUIDANCE: Clear access instructions and next steps
#
# PRODUCTION ENHANCEMENTS NEEDED:
#
# 1. ENHANCED ERROR HANDLING AND RECOVERY:
#    # Add rollback functionality
#    rollback_deployment() {
#        print_warning "Rolling back deployment..."
#        kubectl delete namespace $NAMESPACE --ignore-not-found=true
#        print_status "Rollback completed"
#    }
#    
#    # Trap errors and offer rollback
#    trap 'print_error "Deployment failed. Run with --rollback to clean up."; exit 1' ERR
#
# 2. CONFIGURATION MANAGEMENT:
#    # Support for different environments
#    ENVIRONMENT=${1:-development}
#    CONFIG_FILE="config/${ENVIRONMENT}.env"
#    
#    if [[ -f "$CONFIG_FILE" ]]; then
#        source "$CONFIG_FILE"
#        print_info "Loaded configuration for $ENVIRONMENT environment"
#    fi
#
# 3. ADVANCED DEPLOYMENT STRATEGIES:
#    # Blue-green deployment support
#    deploy_blue_green() {
#        local current_color=$(kubectl get deployment -n $NAMESPACE -o jsonpath='{.items[0].metadata.labels.color}' 2>/dev/null || echo "blue")
#        local new_color=$([ "$current_color" = "blue" ] && echo "green" || echo "blue")
#        
#        print_info "Deploying to $new_color environment..."
#        # Deploy to new color
#        # Switch traffic after validation
#        # Clean up old color
#    }
#
# 4. MONITORING AND OBSERVABILITY INTEGRATION:
#    # Deploy monitoring stack
#    deploy_monitoring() {
#        print_info "Deploying monitoring stack..."
#        kubectl apply -f monitoring/prometheus/
#        kubectl apply -f monitoring/grafana/
#        kubectl apply -f monitoring/jaeger/
#        wait_for_deployment "prometheus"
#        wait_for_deployment "grafana"
#        wait_for_deployment "jaeger"
#    }
#
# 5. SECURITY ENHANCEMENTS:
#    # Validate security configurations
#    validate_security() {
#        print_info "Validating security configurations..."
#        
#        # Check for default passwords
#        if kubectl get secret mysql-credentials -n $NAMESPACE -o jsonpath='{.data.password}' | base64 -d | grep -q "default"; then
#            print_error "Default passwords detected. Please update credentials."
#            exit 1
#        fi
#        
#        # Validate RBAC configurations
#        kubectl auth can-i --list --as=system:serviceaccount:$NAMESPACE:default
#    }
#
# 6. PERFORMANCE OPTIMIZATION:
#    # Parallel deployment where possible
#    deploy_microservices_parallel() {
#        print_info "Deploying microservices in parallel..."
#        
#        kubectl apply -f k8s-manifests/services/customer-service/ &
#        kubectl apply -f k8s-manifests/services/vet-service/ &
#        kubectl apply -f k8s-manifests/services/visit-service/ &
#        
#        wait  # Wait for all background jobs
#        
#        # Then wait for readiness
#        wait_for_deployment "customers-service" &
#        wait_for_deployment "vets-service" &
#        wait_for_deployment "visits-service" &
#        wait
#    }
#
# 7. COMPREHENSIVE LOGGING:
#    # Add deployment logging
#    LOGFILE="/tmp/petclinic-deployment-$(date +%Y%m%d-%H%M%S).log"
#    exec 1> >(tee -a "$LOGFILE")
#    exec 2> >(tee -a "$LOGFILE" >&2)
#    
#    print_info "Deployment log: $LOGFILE"
#
# OPERATIONAL PROCEDURES:
#
# 1. PRE_DEPLOYMENT_CHECKLIST:
#    # Verify cluster resources
#    # Check storage availability
#    # Validate network policies
#    # Confirm backup procedures
#
# 2. POST_DEPLOYMENT_VALIDATION:
#    # Run comprehensive test suite
#    # Verify monitoring and alerting
#    # Test disaster recovery procedures
#    # Document deployment artifacts
#
# 3. MAINTENANCE_PROCEDURES:
#    # Regular health checks
#    # Performance monitoring
#    # Security updates
#    # Capacity planning
#
# TROUBLESHOOTING GUIDE:
#
# 1. COMMON_DEPLOYMENT_ISSUES:
#    # Pod stuck in Pending: Check resource quotas and node capacity
#    # Pod stuck in ContainerCreating: Check image pull and storage
#    # Pod CrashLoopBackOff: Check application logs and configuration
#    # Service not accessible: Check service and ingress configuration
#
# 2. DEBUGGING_COMMANDS:
#    # kubectl describe pod <pod-name> -n $NAMESPACE
#    # kubectl logs <pod-name> -n $NAMESPACE --previous
#    # kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'
#    # kubectl top pods -n $NAMESPACE
#
# =============================================================================
