#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION DEPLOYMENT SCRIPT
# =============================================================================
# This script deploys the complete e-commerce application stack to the
# Kubernetes cluster, including database, backend, and frontend components.
# =============================================================================

set -euo pipefail
# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================
# set -e: Exit immediately if any command fails
# set -u: Exit if any undefined variable is used
# set -o pipefail: Exit if any command in a pipeline fails
# =============================================================================

# =============================================================================
# COLOR CODES FOR OUTPUT FORMATTING
# =============================================================================
# Define color codes for consistent output formatting throughout the script.
# =============================================================================

RED='\033[0;31m'
# Purpose: Red color code for error messages
# Why needed: Provides visual distinction for error output
# Impact: Error messages are displayed in red color
# Usage: Used in error() function for critical messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages
# Why needed: Provides visual distinction for success output
# Impact: Success messages are displayed in green color
# Usage: Used in success() function for completion messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages
# Why needed: Provides visual distinction for warning output
# Impact: Warning messages are displayed in yellow color
# Usage: Used in warning() function for cautionary messages

BLUE='\033[0;34m'
# Purpose: Blue color code for informational messages
# Why needed: Provides visual distinction for informational output
# Impact: Info messages are displayed in blue color
# Usage: Used in log() function for general information

NC='\033[0m'
# Purpose: No Color code to reset terminal color
# Why needed: Resets terminal color after colored output
# Impact: Prevents color bleeding to subsequent output
# Usage: Used at end of all colored message functions

# =============================================================================
# APPLICATION CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent application deployment configuration.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for e-commerce application
# Why needed: Provides consistent namespace reference throughout script
# Impact: All Kubernetes resources are deployed to this namespace
# Value: 'ecommerce' matches the project's application namespace

DATABASE_APP="ecommerce-database"
# Purpose: Specifies the database application name
# Why needed: Provides consistent reference for database deployment
# Impact: Database resources use this name for identification
# Value: Matches the database deployment name in manifests

BACKEND_APP="ecommerce-backend"
# Purpose: Specifies the backend application name
# Why needed: Provides consistent reference for backend deployment
# Impact: Backend resources use this name for identification
# Value: Matches the backend deployment name in manifests

FRONTEND_APP="ecommerce-frontend"
# Purpose: Specifies the frontend application name
# Why needed: Provides consistent reference for frontend deployment
# Impact: Frontend resources use this name for identification
# Value: Matches the frontend deployment name in manifests

IMAGE_TAG="v1.0.0"
# Purpose: Specifies the container image tag for deployments
# Why needed: Ensures consistent image versioning across components
# Impact: All container images use this tag for deployment
# Value: Version tag matching the application release

REGISTRY="localhost:5000"
# Purpose: Specifies the container registry for image pulls
# Why needed: Defines where container images are stored
# Impact: Kubernetes pulls images from this registry
# Value: Local registry for development environment

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
# Functions for consistent logging and output formatting throughout the script.
# =============================================================================

log() {
    # =============================================================================
    # LOG FUNCTION
    # =============================================================================
    # Logs informational messages with timestamp and blue color formatting.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the message to log
    # Why needed: Provides the content to be logged
    # Impact: Message is displayed with timestamp and formatting
    # Parameter: $1 is the message string to display
    
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $message"
    # Purpose: Outputs formatted message with timestamp
    # Why needed: Provides consistent logging format with timestamp
    # Impact: Message appears with blue timestamp and normal text
    # Format: [YYYY-MM-DD HH:MM:SS] message
}

error() {
    # =============================================================================
    # ERROR FUNCTION
    # =============================================================================
    # Logs error messages with red color formatting and outputs to stderr.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the error message to display
    # Why needed: Provides the error content to be logged
    # Impact: Message is displayed in red color and sent to stderr
    # Parameter: $1 is the error message string
    
    echo -e "${RED}[ERROR]${NC} $message" >&2
    # Purpose: Outputs formatted error message in red to stderr
    # Why needed: Provides visual indication of errors and proper stream handling
    # Impact: Error message appears in red and goes to error stream
    # Format: [ERROR] message in red color to stderr
}

success() {
    # =============================================================================
    # SUCCESS FUNCTION
    # =============================================================================
    # Logs success messages with green color formatting for positive outcomes.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the success message to display
    # Why needed: Provides the success content to be logged
    # Impact: Message is displayed in green color for visual distinction
    # Parameter: $1 is the success message string
    
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    # Purpose: Outputs formatted success message in green
    # Why needed: Provides visual confirmation of successful operations
    # Impact: Success message appears in green for easy identification
    # Format: [SUCCESS] message in green color
}

warning() {
    # =============================================================================
    # WARNING FUNCTION
    # =============================================================================
    # Logs warning messages with yellow color formatting for cautionary information.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the warning message to display
    # Why needed: Provides the warning content to be logged
    # Impact: Message is displayed in yellow color for attention
    # Parameter: $1 is the warning message string
    
    echo -e "${YELLOW}[WARNING]${NC} $message"
    # Purpose: Outputs formatted warning message in yellow
    # Why needed: Provides visual indication of warnings and potential issues
    # Impact: Warning message appears in yellow for moderate attention
    # Format: [WARNING] message in yellow color
}

# =============================================================================
# PREREQUISITE CHECKING FUNCTIONS
# =============================================================================
# Functions to validate required tools and environment before deployment.
# =============================================================================

check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates that all required tools and cluster access are available.
    # =============================================================================
    
    log "Checking deployment prerequisites..."
    # Purpose: Inform user that prerequisite checking is starting
    # Why needed: User should know validation process has begun
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # KUBECTL AVAILABILITY CHECK
    # =============================================================================
    # Verify kubectl command is available for Kubernetes operations.
    # =============================================================================
    
    if ! command -v kubectl &> /dev/null; then
        # Purpose: Check if kubectl command is available in PATH
        # Why needed: kubectl is required for all Kubernetes operations
        # Impact: Script cannot continue without kubectl
        
        error "kubectl is not installed or not in PATH"
        # Purpose: Report missing kubectl tool
        # Why needed: User needs to install kubectl before proceeding
        # Impact: Clear error message for troubleshooting
        
        exit 1
        # Purpose: Exit script due to missing prerequisite
        # Why needed: Cannot perform deployment without kubectl
        # Impact: Script terminates with error code 1
    fi
    
    # =============================================================================
    # KUBERNETES CLUSTER CONNECTIVITY CHECK
    # =============================================================================
    # Verify connection to Kubernetes cluster is working.
    # =============================================================================
    
    if ! kubectl cluster-info &> /dev/null; then
        # Purpose: Test connectivity to Kubernetes cluster
        # Why needed: Cluster access is required for deployment operations
        # Impact: Script cannot continue without cluster access
        
        error "Cannot connect to Kubernetes cluster"
        # Purpose: Report cluster connectivity failure
        # Why needed: User needs to fix cluster configuration
        # Impact: Clear error message for troubleshooting
        
        exit 1
        # Purpose: Exit script due to cluster connectivity failure
        # Why needed: Cannot perform deployment without cluster access
        # Impact: Script terminates with error code 1
    fi
    
    # =============================================================================
    # NAMESPACE EXISTENCE CHECK
    # =============================================================================
    # Verify target namespace exists or create it if missing.
    # =============================================================================
    
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        # Purpose: Check if target namespace exists
        # Why needed: Namespace is required for resource deployment
        # Impact: Creates namespace if missing, exits if creation fails
        
        warning "Namespace $NAMESPACE does not exist. Creating it..."
        # Purpose: Inform user about namespace creation
        # Why needed: User should know about automatic namespace creation
        # Impact: Provides transparency about infrastructure changes
        
        kubectl create namespace "$NAMESPACE"
        # Purpose: Create the target namespace
        # Why needed: Provides isolated environment for application resources
        # Impact: Namespace becomes available for resource deployment
        
        if kubectl get namespace "$NAMESPACE" &> /dev/null; then
            # Purpose: Verify namespace creation was successful
            # Why needed: Confirms namespace is ready for use
            # Impact: Provides feedback on namespace creation success
            
            success "Namespace $NAMESPACE created successfully"
            # Purpose: Confirm successful namespace creation
            # Why needed: User should know namespace is ready
            # Impact: Provides confidence to proceed with deployment
        else
            error "Failed to create namespace $NAMESPACE"
            # Purpose: Report namespace creation failure
            # Why needed: User needs to know about creation problems
            # Impact: Script will exit due to missing namespace
            
            exit 1
            # Purpose: Exit script due to namespace creation failure
            # Why needed: Cannot deploy resources without namespace
            # Impact: Script terminates with error code 1
        fi
    else
        success "Namespace $NAMESPACE exists and is accessible"
        # Purpose: Confirm namespace availability
        # Why needed: User should know namespace is ready for deployment
        # Impact: Provides confidence in deployment environment
    fi
    
    success "Prerequisites check completed successfully"
    # Purpose: Confirm all prerequisites are satisfied
    # Why needed: User should know system is ready for deployment
    # Impact: Provides confidence to proceed with deployment
}

# =============================================================================
# APPLICATION DEPLOYMENT FUNCTIONS
# =============================================================================
# Functions to deploy individual application components.
# =============================================================================

deploy_database() {
    # =============================================================================
    # DEPLOY DATABASE FUNCTION
    # =============================================================================
    # Deploys PostgreSQL database component with persistent storage.
    # =============================================================================
    
    log "Deploying database component: $DATABASE_APP"
    # Purpose: Inform user that database deployment is starting
    # Why needed: User should know which component is being deployed
    # Impact: Provides context for deployment progress
    
    # =============================================================================
    # DATABASE MANIFEST APPLICATION
    # =============================================================================
    # Apply database deployment and service manifests.
    # =============================================================================
    
    if [[ -f "k8s-manifests/database-deployment.yaml" ]]; then
        # Purpose: Check if database deployment manifest exists
        # Why needed: Prevents errors when applying non-existent manifests
        # Impact: Only applies manifest if file is available
        
        kubectl apply -f k8s-manifests/database-deployment.yaml -n "$NAMESPACE"
        # Purpose: Apply database deployment manifest to cluster
        # Why needed: Creates database pods and associated resources
        # Impact: Database deployment becomes available in cluster
        
        success "Database deployment manifest applied"
        # Purpose: Confirm database deployment application
        # Why needed: User should know deployment was successful
        # Impact: Provides feedback on deployment progress
    else
        error "Database deployment manifest not found: k8s-manifests/database-deployment.yaml"
        # Purpose: Report missing database manifest
        # Why needed: User needs to know about missing files
        # Impact: Deployment cannot proceed without manifest
        
        exit 1
        # Purpose: Exit script due to missing manifest
        # Why needed: Cannot deploy database without manifest
        # Impact: Script terminates with error code 1
    fi
    
    if [[ -f "k8s-manifests/database-service.yaml" ]]; then
        # Purpose: Check if database service manifest exists
        # Why needed: Service is required for database connectivity
        # Impact: Only applies service if manifest is available
        
        kubectl apply -f k8s-manifests/database-service.yaml -n "$NAMESPACE"
        # Purpose: Apply database service manifest to cluster
        # Why needed: Creates service for database connectivity
        # Impact: Database becomes accessible via service
        
        success "Database service manifest applied"
        # Purpose: Confirm database service application
        # Why needed: User should know service was created
        # Impact: Provides feedback on service creation
    else
        warning "Database service manifest not found: k8s-manifests/database-service.yaml"
        # Purpose: Report missing database service manifest
        # Why needed: User should know about missing service
        # Impact: Database may not be accessible without service
    fi
    
    # =============================================================================
    # DATABASE READINESS VERIFICATION
    # =============================================================================
    # Wait for database pods to become ready before proceeding.
    # =============================================================================
    
    log "Waiting for database pods to become ready..."
    # Purpose: Inform user about database readiness wait
    # Why needed: User should know why there's a delay
    # Impact: Sets expectation for deployment time
    
    kubectl wait --for=condition=ready pod -l app="$DATABASE_APP" -n "$NAMESPACE" --timeout=300s
    # Purpose: Wait for database pods to reach ready state
    # Why needed: Ensures database is operational before deploying dependent services
    # Impact: Prevents backend deployment failures due to database unavailability
    # Timeout: 300 seconds provides adequate time for database startup
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if database readiness wait was successful
        # Why needed: Verifies database is ready for connections
        # Impact: Provides confidence in database availability
        
        success "Database deployment completed and pods are ready"
        # Purpose: Confirm database deployment success
        # Why needed: User should know database is operational
        # Impact: Provides confidence to proceed with dependent services
    else
        error "Database pods failed to become ready within timeout"
        # Purpose: Report database readiness failure
        # Why needed: User needs to know about deployment problems
        # Impact: May indicate resource or configuration issues
        
        exit 1
        # Purpose: Exit script due to database readiness failure
        # Why needed: Cannot proceed with dependent services if database is not ready
        # Impact: Script terminates with error code 1
    fi
}

deploy_backend() {
    # =============================================================================
    # DEPLOY BACKEND FUNCTION
    # =============================================================================
    # Deploys backend API component with database connectivity.
    # =============================================================================
    
    log "Deploying backend component: $BACKEND_APP"
    # Purpose: Inform user that backend deployment is starting
    # Why needed: User should know which component is being deployed
    # Impact: Provides context for deployment progress
    
    # =============================================================================
    # BACKEND MANIFEST APPLICATION
    # =============================================================================
    # Apply backend deployment and service manifests.
    # =============================================================================
    
    if [[ -f "k8s-manifests/backend-deployment.yaml" ]]; then
        # Purpose: Check if backend deployment manifest exists
        # Why needed: Prevents errors when applying non-existent manifests
        # Impact: Only applies manifest if file is available
        
        kubectl apply -f k8s-manifests/backend-deployment.yaml -n "$NAMESPACE"
        # Purpose: Apply backend deployment manifest to cluster
        # Why needed: Creates backend pods and associated resources
        # Impact: Backend API becomes available in cluster
        
        success "Backend deployment manifest applied"
        # Purpose: Confirm backend deployment application
        # Why needed: User should know deployment was successful
        # Impact: Provides feedback on deployment progress
    else
        error "Backend deployment manifest not found: k8s-manifests/backend-deployment.yaml"
        # Purpose: Report missing backend manifest
        # Why needed: User needs to know about missing files
        # Impact: Deployment cannot proceed without manifest
        
        exit 1
        # Purpose: Exit script due to missing manifest
        # Why needed: Cannot deploy backend without manifest
        # Impact: Script terminates with error code 1
    fi
    
    if [[ -f "k8s-manifests/backend-service.yaml" ]]; then
        # Purpose: Check if backend service manifest exists
        # Why needed: Service is required for backend API access
        # Impact: Only applies service if manifest is available
        
        kubectl apply -f k8s-manifests/backend-service.yaml -n "$NAMESPACE"
        # Purpose: Apply backend service manifest to cluster
        # Why needed: Creates service for backend API access
        # Impact: Backend API becomes accessible via service
        
        success "Backend service manifest applied"
        # Purpose: Confirm backend service application
        # Why needed: User should know service was created
        # Impact: Provides feedback on service creation
    else
        warning "Backend service manifest not found: k8s-manifests/backend-service.yaml"
        # Purpose: Report missing backend service manifest
        # Why needed: User should know about missing service
        # Impact: Backend API may not be accessible without service
    fi
    
    # =============================================================================
    # BACKEND READINESS VERIFICATION
    # =============================================================================
    # Wait for backend pods to become ready before proceeding.
    # =============================================================================
    
    log "Waiting for backend pods to become ready..."
    # Purpose: Inform user about backend readiness wait
    # Why needed: User should know why there's a delay
    # Impact: Sets expectation for deployment time
    
    kubectl wait --for=condition=ready pod -l app="$BACKEND_APP" -n "$NAMESPACE" --timeout=300s
    # Purpose: Wait for backend pods to reach ready state
    # Why needed: Ensures backend API is operational before deploying frontend
    # Impact: Prevents frontend deployment issues due to backend unavailability
    # Timeout: 300 seconds provides adequate time for backend startup
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if backend readiness wait was successful
        # Why needed: Verifies backend API is ready for requests
        # Impact: Provides confidence in backend availability
        
        success "Backend deployment completed and pods are ready"
        # Purpose: Confirm backend deployment success
        # Why needed: User should know backend API is operational
        # Impact: Provides confidence to proceed with frontend deployment
    else
        error "Backend pods failed to become ready within timeout"
        # Purpose: Report backend readiness failure
        # Why needed: User needs to know about deployment problems
        # Impact: May indicate resource, configuration, or database connectivity issues
        
        exit 1
        # Purpose: Exit script due to backend readiness failure
        # Why needed: Cannot proceed with frontend if backend is not ready
        # Impact: Script terminates with error code 1
    fi
}

deploy_frontend() {
    # =============================================================================
    # DEPLOY FRONTEND FUNCTION
    # =============================================================================
    # Deploys frontend web application component.
    # =============================================================================
    
    log "Deploying frontend component: $FRONTEND_APP"
    # Purpose: Inform user that frontend deployment is starting
    # Why needed: User should know which component is being deployed
    # Impact: Provides context for deployment progress
    
    # =============================================================================
    # FRONTEND MANIFEST APPLICATION
    # =============================================================================
    # Apply frontend deployment and service manifests.
    # =============================================================================
    
    if [[ -f "k8s-manifests/frontend-deployment.yaml" ]]; then
        # Purpose: Check if frontend deployment manifest exists
        # Why needed: Prevents errors when applying non-existent manifests
        # Impact: Only applies manifest if file is available
        
        kubectl apply -f k8s-manifests/frontend-deployment.yaml -n "$NAMESPACE"
        # Purpose: Apply frontend deployment manifest to cluster
        # Why needed: Creates frontend pods and associated resources
        # Impact: Frontend web application becomes available in cluster
        
        success "Frontend deployment manifest applied"
        # Purpose: Confirm frontend deployment application
        # Why needed: User should know deployment was successful
        # Impact: Provides feedback on deployment progress
    else
        error "Frontend deployment manifest not found: k8s-manifests/frontend-deployment.yaml"
        # Purpose: Report missing frontend manifest
        # Why needed: User needs to know about missing files
        # Impact: Deployment cannot proceed without manifest
        
        exit 1
        # Purpose: Exit script due to missing manifest
        # Why needed: Cannot deploy frontend without manifest
        # Impact: Script terminates with error code 1
    fi
    
    if [[ -f "k8s-manifests/frontend-service.yaml" ]]; then
        # Purpose: Check if frontend service manifest exists
        # Why needed: Service is required for frontend web access
        # Impact: Only applies service if manifest is available
        
        kubectl apply -f k8s-manifests/frontend-service.yaml -n "$NAMESPACE"
        # Purpose: Apply frontend service manifest to cluster
        # Why needed: Creates service for frontend web access
        # Impact: Frontend becomes accessible via service
        
        success "Frontend service manifest applied"
        # Purpose: Confirm frontend service application
        # Why needed: User should know service was created
        # Impact: Provides feedback on service creation
    else
        warning "Frontend service manifest not found: k8s-manifests/frontend-service.yaml"
        # Purpose: Report missing frontend service manifest
        # Why needed: User should know about missing service
        # Impact: Frontend may not be accessible without service
    fi
    
    # =============================================================================
    # FRONTEND READINESS VERIFICATION
    # =============================================================================
    # Wait for frontend pods to become ready.
    # =============================================================================
    
    log "Waiting for frontend pods to become ready..."
    # Purpose: Inform user about frontend readiness wait
    # Why needed: User should know why there's a delay
    # Impact: Sets expectation for deployment time
    
    kubectl wait --for=condition=ready pod -l app="$FRONTEND_APP" -n "$NAMESPACE" --timeout=300s
    # Purpose: Wait for frontend pods to reach ready state
    # Why needed: Ensures frontend web application is operational
    # Impact: Confirms complete application stack is ready
    # Timeout: 300 seconds provides adequate time for frontend startup
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if frontend readiness wait was successful
        # Why needed: Verifies frontend is ready to serve requests
        # Impact: Provides confidence in complete application availability
        
        success "Frontend deployment completed and pods are ready"
        # Purpose: Confirm frontend deployment success
        # Why needed: User should know frontend is operational
        # Impact: Indicates complete application stack is ready
    else
        error "Frontend pods failed to become ready within timeout"
        # Purpose: Report frontend readiness failure
        # Why needed: User needs to know about deployment problems
        # Impact: May indicate resource or configuration issues
        
        exit 1
        # Purpose: Exit script due to frontend readiness failure
        # Why needed: Application stack is incomplete without frontend
        # Impact: Script terminates with error code 1
    fi
}

# =============================================================================
# DEPLOYMENT VALIDATION FUNCTIONS
# =============================================================================
# Functions to validate successful deployment of all components.
# =============================================================================

validate_deployment() {
    # =============================================================================
    # VALIDATE DEPLOYMENT FUNCTION
    # =============================================================================
    # Performs comprehensive validation of deployed application components.
    # =============================================================================
    
    log "Validating complete application deployment..."
    # Purpose: Inform user that deployment validation is starting
    # Why needed: User should know validation process has begun
    # Impact: Provides feedback on validation progress
    
    # =============================================================================
    # POD STATUS VALIDATION
    # =============================================================================
    # Check that all application pods are running successfully.
    # =============================================================================
    
    log "Checking pod status for all components..."
    # Purpose: Inform user about pod status checking
    # Why needed: User should know what validation is being performed
    # Impact: Provides context for validation steps
    
    local all_pods_ready=true
    # Purpose: Track overall pod readiness status
    # Why needed: Determines if validation passes or fails
    # Impact: Controls validation success reporting
    
    # Check database pods
    local db_pods=$(kubectl get pods -l app="$DATABASE_APP" -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    # Purpose: Count database pods in the namespace
    # Why needed: Verifies database pods were created
    # Impact: Indicates database deployment success
    
    local db_ready=$(kubectl get pods -l app="$DATABASE_APP" -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    # Purpose: Count running database pods
    # Why needed: Verifies database pods are operational
    # Impact: Indicates database readiness
    
    if [[ "$db_pods" -gt 0 && "$db_ready" -eq "$db_pods" ]]; then
        # Purpose: Check if all database pods are running
        # Why needed: Database must be operational for application to work
        # Impact: Confirms database component is healthy
        
        success "Database pods: $db_ready/$db_pods running"
        # Purpose: Report database pod status
        # Why needed: User should know database status
        # Impact: Provides confidence in database availability
    else
        error "Database pods: $db_ready/$db_pods running (some pods not ready)"
        # Purpose: Report database pod issues
        # Why needed: User needs to know about database problems
        # Impact: Indicates deployment validation failure
        
        all_pods_ready=false
        # Purpose: Mark validation as failed
        # Why needed: Overall validation should fail if any component fails
        # Impact: Will cause validation function to report failure
    fi
    
    # Check backend pods
    local backend_pods=$(kubectl get pods -l app="$BACKEND_APP" -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    # Purpose: Count backend pods in the namespace
    # Why needed: Verifies backend pods were created
    # Impact: Indicates backend deployment success
    
    local backend_ready=$(kubectl get pods -l app="$BACKEND_APP" -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    # Purpose: Count running backend pods
    # Why needed: Verifies backend pods are operational
    # Impact: Indicates backend API readiness
    
    if [[ "$backend_pods" -gt 0 && "$backend_ready" -eq "$backend_pods" ]]; then
        # Purpose: Check if all backend pods are running
        # Why needed: Backend API must be operational for frontend to work
        # Impact: Confirms backend component is healthy
        
        success "Backend pods: $backend_ready/$backend_pods running"
        # Purpose: Report backend pod status
        # Why needed: User should know backend API status
        # Impact: Provides confidence in backend availability
    else
        error "Backend pods: $backend_ready/$backend_pods running (some pods not ready)"
        # Purpose: Report backend pod issues
        # Why needed: User needs to know about backend problems
        # Impact: Indicates deployment validation failure
        
        all_pods_ready=false
        # Purpose: Mark validation as failed
        # Why needed: Overall validation should fail if any component fails
        # Impact: Will cause validation function to report failure
    fi
    
    # Check frontend pods
    local frontend_pods=$(kubectl get pods -l app="$FRONTEND_APP" -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    # Purpose: Count frontend pods in the namespace
    # Why needed: Verifies frontend pods were created
    # Impact: Indicates frontend deployment success
    
    local frontend_ready=$(kubectl get pods -l app="$FRONTEND_APP" -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
    # Purpose: Count running frontend pods
    # Why needed: Verifies frontend pods are operational
    # Impact: Indicates frontend web application readiness
    
    if [[ "$frontend_pods" -gt 0 && "$frontend_ready" -eq "$frontend_pods" ]]; then
        # Purpose: Check if all frontend pods are running
        # Why needed: Frontend must be operational for user access
        # Impact: Confirms frontend component is healthy
        
        success "Frontend pods: $frontend_ready/$frontend_pods running"
        # Purpose: Report frontend pod status
        # Why needed: User should know frontend status
        # Impact: Provides confidence in frontend availability
    else
        error "Frontend pods: $frontend_ready/$frontend_pods running (some pods not ready)"
        # Purpose: Report frontend pod issues
        # Why needed: User needs to know about frontend problems
        # Impact: Indicates deployment validation failure
        
        all_pods_ready=false
        # Purpose: Mark validation as failed
        # Why needed: Overall validation should fail if any component fails
        # Impact: Will cause validation function to report failure
    fi
    
    # =============================================================================
    # SERVICE VALIDATION
    # =============================================================================
    # Check that all required services are created and accessible.
    # =============================================================================
    
    log "Checking service availability..."
    # Purpose: Inform user about service validation
    # Why needed: Services are required for component connectivity
    # Impact: Provides context for service checking
    
    local services=("$DATABASE_APP-service" "$BACKEND_APP-service" "$FRONTEND_APP-service")
    # Purpose: Define list of expected services
    # Why needed: Provides consistent service names for validation
    # Impact: Ensures all required services are checked
    
    for service in "${services[@]}"; do
        # Purpose: Iterate through all expected services
        # Why needed: Each service must be validated individually
        # Impact: Comprehensive service validation
        
        if kubectl get service "$service" -n "$NAMESPACE" &> /dev/null; then
            # Purpose: Check if service exists in namespace
            # Why needed: Services are required for component connectivity
            # Impact: Confirms service availability
            
            success "Service $service is available"
            # Purpose: Report service availability
            # Why needed: User should know service status
            # Impact: Provides confidence in service connectivity
        else
            warning "Service $service not found (may be optional)"
            # Purpose: Report missing service
            # Why needed: User should know about missing services
            # Impact: May indicate incomplete deployment
        fi
    done
    
    # =============================================================================
    # OVERALL VALIDATION RESULT
    # =============================================================================
    # Report overall deployment validation status.
    # =============================================================================
    
    if [[ "$all_pods_ready" == true ]]; then
        # Purpose: Check if all validation checks passed
        # Why needed: Determines overall deployment success
        # Impact: Reports successful deployment validation
        
        success "Deployment validation completed successfully - all components are ready"
        # Purpose: Report successful deployment validation
        # Why needed: User should know deployment was successful
        # Impact: Provides confidence in complete application availability
    else
        error "Deployment validation failed - some components are not ready"
        # Purpose: Report deployment validation failure
        # Why needed: User needs to know about deployment problems
        # Impact: Indicates need for troubleshooting
        
        exit 1
        # Purpose: Exit script due to validation failure
        # Why needed: Deployment is not successful if validation fails
        # Impact: Script terminates with error code 1
    fi
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================
# Main function that orchestrates the complete deployment process.
# =============================================================================

main() {
    # =============================================================================
    # MAIN FUNCTION
    # =============================================================================
    # Orchestrates complete e-commerce application deployment workflow.
    # =============================================================================
    
    log "Starting e-commerce application deployment..."
    # Purpose: Inform user that deployment process is beginning
    # Why needed: User should know the deployment workflow is starting
    # Impact: Sets expectation for complete deployment process
    
    echo ""
    log "Deployment will include:"
    log "  - Prerequisites validation"
    log "  - Database deployment and readiness verification"
    log "  - Backend API deployment and readiness verification"
    log "  - Frontend deployment and readiness verification"
    log "  - Complete deployment validation"
    echo ""
    # Purpose: Inform user about all deployment components
    # Why needed: User should understand the complete scope of deployment
    # Impact: Sets clear expectations for the deployment process
    
    # =============================================================================
    # EXECUTE DEPLOYMENT WORKFLOW
    # =============================================================================
    # Run all deployment components in proper sequence.
    # =============================================================================
    
    check_prerequisites
    # Purpose: Validate environment and tools before deployment
    # Why needed: Ensures deployment can proceed successfully
    # Impact: Prevents failures due to missing dependencies
    
    deploy_database
    # Purpose: Deploy database component first
    # Why needed: Backend depends on database availability
    # Impact: Database becomes available for backend connections
    
    deploy_backend
    # Purpose: Deploy backend API component
    # Why needed: Frontend depends on backend API availability
    # Impact: Backend API becomes available for frontend requests
    
    deploy_frontend
    # Purpose: Deploy frontend web application component
    # Why needed: Completes the application stack
    # Impact: Frontend becomes available for user access
    
    validate_deployment
    # Purpose: Validate complete deployment success
    # Why needed: Confirms all components are operational
    # Impact: Provides confidence in deployment success
    
    # =============================================================================
    # DISPLAY COMPLETION SUMMARY
    # =============================================================================
    # Provide final summary and access information for user.
    # =============================================================================
    
    echo ""
    echo "=================================================================="
    echo "           E-COMMERCE APPLICATION DEPLOYMENT COMPLETED"
    echo "=================================================================="
    echo ""
    success "E-commerce application deployed successfully!"
    echo ""
    log "Application components deployed in namespace: $NAMESPACE"
    echo ""
    log "To access the application:"
    echo ""
    log "Frontend (Web UI):"
    log "  kubectl port-forward -n $NAMESPACE svc/$FRONTEND_APP-service 8080:80"
    log "  Then visit: http://localhost:8080"
    echo ""
    log "Backend API:"
    log "  kubectl port-forward -n $NAMESPACE svc/$BACKEND_APP-service 8081:80"
    log "  Then visit: http://localhost:8081"
    echo ""
    log "Database (for admin access):"
    log "  kubectl port-forward -n $NAMESPACE svc/$DATABASE_APP-service 5432:5432"
    log "  Then connect: psql -h localhost -p 5432 -U postgres -d ecommerce"
    echo ""
    log "To check application status:"
    log "  kubectl get pods -n $NAMESPACE"
    log "  kubectl get services -n $NAMESPACE"
    echo ""
    echo "=================================================================="
    # Purpose: Provide comprehensive completion summary and access instructions
    # Why needed: User needs to know how to access and manage the deployed application
    # Impact: Enables user to use the deployed application effectively
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
# Execute main function with all command line arguments.
# =============================================================================

main "$@"
# Purpose: Execute main function with all script arguments
# Why needed: Starts the complete deployment process
# Impact: Runs the entire e-commerce application deployment
# Arguments: "$@" passes all command line arguments to main function
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
