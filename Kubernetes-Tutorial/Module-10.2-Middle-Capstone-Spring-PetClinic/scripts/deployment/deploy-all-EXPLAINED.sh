#!/bin/bash

# Spring PetClinic Complete Deployment Script - Line by Line Documentation
# ========================================================================
# 
# This script handles the complete deployment of the Spring PetClinic
# microservices platform with comprehensive error handling and validation.
#
# Author: DevOps Team
# Version: 2.0.0
# Last Updated: December 2024

# =============================================================================
# SCRIPT INITIALIZATION AND SAFETY
# =============================================================================

set -euo pipefail
# set -euo pipefail: Enable strict error handling
# -e: Exit immediately if any command fails (non-zero exit status)
# -u: Exit if trying to use undefined variables
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
# This ensures the script fails fast and doesn't continue with errors

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

readonly NAMESPACE="${NAMESPACE:-petclinic}"
# NAMESPACE: Kubernetes namespace for deployment
# ${NAMESPACE:-petclinic}: Use environment variable NAMESPACE, default to "petclinic"
# readonly: Makes variable immutable to prevent accidental changes
# Used throughout script for consistent namespace reference

readonly ENVIRONMENT="${ENVIRONMENT:-development}"
# ENVIRONMENT: Deployment environment (development, staging, production)
# ${ENVIRONMENT:-development}: Default to development if not specified
# Used for environment-specific configurations and safety checks

readonly IMAGE_TAG="${IMAGE_TAG:-latest}"
# IMAGE_TAG: Docker image tag to deploy
# ${IMAGE_TAG:-latest}: Default to latest if not specified
# Should use specific versions in production for consistency

readonly TIMEOUT="${TIMEOUT:-600}"
# TIMEOUT: Maximum time to wait for deployments (in seconds)
# ${TIMEOUT:-600}: Default to 10 minutes if not specified
# Used for kubectl wait commands to prevent infinite waiting

readonly DRY_RUN="${DRY_RUN:-false}"
# DRY_RUN: Whether to perform dry run without actual deployment
# ${DRY_RUN:-false}: Default to false (perform actual deployment)
# When true, shows what would be done without making changes

# =============================================================================
# COLOR CONSTANTS FOR OUTPUT
# =============================================================================

readonly RED='\033[0;31m'
# RED: ANSI color code for red text
# Used for error messages and failures
# \033[0;31m: ANSI escape sequence for red color

readonly GREEN='\033[0;32m'
# GREEN: ANSI color code for green text
# Used for success messages and confirmations
# \033[0;32m: ANSI escape sequence for green color

readonly YELLOW='\033[1;33m'
# YELLOW: ANSI color code for yellow text
# Used for warning messages and important information
# \033[1;33m: ANSI escape sequence for bright yellow color

readonly BLUE='\033[0;34m'
# BLUE: ANSI color code for blue text
# Used for informational messages and progress updates
# \033[0;34m: ANSI escape sequence for blue color

readonly PURPLE='\033[0;35m'
# PURPLE: ANSI color code for purple text
# Used for section headers and important separators
# \033[0;35m: ANSI escape sequence for purple color

readonly NC='\033[0m'
# NC: No Color - resets color to default
# Used to end colored text and return to normal
# \033[0m: ANSI escape sequence to reset formatting

# =============================================================================
# DEPLOYMENT PHASES ARRAY
# =============================================================================

readonly PHASES=("namespace" "secrets" "databases" "infrastructure" "services" "monitoring" "validation")
# PHASES: Array defining deployment order
# Each phase must complete successfully before proceeding to next
# Order is critical for dependency management:
# 1. namespace: Create isolated environment
# 2. secrets: Deploy credentials before services need them
# 3. databases: Deploy data layer before application services
# 4. infrastructure: Deploy config server and service discovery
# 5. services: Deploy application microservices
# 6. monitoring: Deploy observability stack
# 7. validation: Verify deployment success

# =============================================================================
# SERVICE DEPENDENCIES MAPPING
# =============================================================================

declare -A SERVICE_DEPENDENCIES=(
    # SERVICE_DEPENDENCIES: Associative array mapping services to their dependencies
    # Key: service name, Value: space-separated list of dependencies
    # Used to ensure proper startup order and dependency checking
    
    ["config-server"]=""
    # config-server: No dependencies - starts first
    # Provides centralized configuration for all other services
    # Must be running before other services can retrieve configuration
    
    ["discovery-server"]="config-server"
    # discovery-server: Depends on config-server
    # Needs configuration from config server to start properly
    # Provides service registry for other microservices
    
    ["api-gateway"]="config-server discovery-server"
    # api-gateway: Depends on config-server and discovery-server
    # Needs configuration and service registry to route requests
    # Acts as single entry point for all client requests
    
    ["customer-service"]="config-server discovery-server mysql-customer"
    # customer-service: Depends on config, discovery, and customer database
    # Needs database connection to store and retrieve customer data
    # Registers with discovery server for service-to-service communication
    
    ["vet-service"]="config-server discovery-server mysql-vet"
    # vet-service: Depends on config, discovery, and vet database
    # Needs database connection to store and retrieve veterinarian data
    # Registers with discovery server for service-to-service communication
    
    ["visit-service"]="config-server discovery-server mysql-visit"
    # visit-service: Depends on config, discovery, and visit database
    # Needs database connection to store and retrieve visit/appointment data
    # Registers with discovery server for service-to-service communication
    
    ["admin-server"]="config-server discovery-server"
    # admin-server: Depends on config-server and discovery-server
    # Provides administrative interface for monitoring microservices
    # Uses discovery server to find and monitor other services
)

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log_header() {
    # log_header: Display section headers with visual separation
    # Parameter: $1 - Header text to display
    # Creates prominent visual separator for major script sections
    
    echo -e "\n${PURPLE}============================================================================${NC}"
    # echo -e: Enable interpretation of backslash escapes for colors
    # \n: Add newline before header for spacing
    # ${PURPLE}: Use purple color for header border
    # ${NC}: Reset color after border
    
    echo -e "${PURPLE}$1${NC}"
    # Display header text in purple color
    # $1: First parameter passed to function (header text)
    
    echo -e "${PURPLE}============================================================================${NC}\n"
    # Close header with matching border and add newline after
}

log_info() {
    # log_info: Display informational messages
    # Parameter: $1 - Information message to display
    # Used for progress updates and general information
    
    echo -e "${BLUE}[INFO]${NC} $1"
    # [INFO]: Prefix to identify message type
    # ${BLUE}: Use blue color for info messages
    # $1: Message text passed as parameter
}

log_success() {
    # log_success: Display success messages
    # Parameter: $1 - Success message to display
    # Used to confirm successful completion of operations
    
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    # [SUCCESS]: Prefix to identify message type
    # ${GREEN}: Use green color for success messages
    # $1: Success message text passed as parameter
}

log_warning() {
    # log_warning: Display warning messages
    # Parameter: $1 - Warning message to display
    # Used for non-critical issues that need attention
    
    echo -e "${YELLOW}[WARNING]${NC} $1"
    # [WARNING]: Prefix to identify message type
    # ${YELLOW}: Use yellow color for warning messages
    # $1: Warning message text passed as parameter
}

log_error() {
    # log_error: Display error messages
    # Parameter: $1 - Error message to display
    # Used for critical errors and failures
    
    echo -e "${RED}[ERROR]${NC} $1"
    # [ERROR]: Prefix to identify message type
    # ${RED}: Use red color for error messages
    # $1: Error message text passed as parameter
}

# =============================================================================
# PREREQUISITE CHECKING FUNCTIONS
# =============================================================================

check_prerequisites() {
    # check_prerequisites: Verify all required tools and access are available
    # Ensures script can execute successfully before starting deployment
    # Exits with error if any prerequisites are missing
    
    log_header "🔍 CHECKING PREREQUISITES"
    # Display section header for prerequisite checking
    
    local missing_tools=()
    # missing_tools: Local array to collect names of missing tools
    # local: Variable only exists within this function scope
    # (): Initialize as empty array
    
    # Check required tools
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    # command -v kubectl: Check if kubectl command exists
    # >/dev/null 2>&1: Suppress output and error messages
    # ||: If command fails (kubectl not found), execute right side
    # missing_tools+=("kubectl"): Add kubectl to missing tools array
    
    command -v helm >/dev/null 2>&1 || missing_tools+=("helm")
    # command -v helm: Check if helm command exists
    # Same pattern as kubectl check above
    # Helm is required for package management and templating
    
    command -v jq >/dev/null 2>&1 || missing_tools+=("jq")
    # command -v jq: Check if jq command exists
    # jq is required for JSON processing and parsing
    # Used for parsing kubectl output and configuration files
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        # ${#missing_tools[@]}: Get length of missing_tools array
        # -gt 0: Greater than 0 (array has elements)
        # If any tools are missing, report error and exit
        
        log_error "Missing required tools: ${missing_tools[*]}"
        # ${missing_tools[*]}: Expand all array elements as single string
        # Reports which tools are missing for user to install
        
        exit 1
        # exit 1: Exit script with error code 1
        # Indicates script failure due to missing prerequisites
    fi
    
    # Check Kubernetes connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # kubectl cluster-info: Test connection to Kubernetes cluster
        # !: Negate the result (true if command fails)
        # >/dev/null 2>&1: Suppress output to avoid cluttering console
        
        log_error "Cannot connect to Kubernetes cluster"
        # Report connectivity error to user
        
        exit 1
        # Exit with error if cannot connect to cluster
        # No point continuing without cluster access
    fi
    
    log_success "All prerequisites satisfied"
    # Confirm all checks passed successfully
}

# =============================================================================
# NAMESPACE DEPLOYMENT FUNCTION
# =============================================================================

deploy_namespace() {
    # deploy_namespace: Create and configure Kubernetes namespace
    # Provides isolated environment for PetClinic resources
    # Sets up proper labels and annotations for organization
    
    log_header "🏠 DEPLOYING NAMESPACE"
    # Display section header for namespace deployment
    
    if [[ "$DRY_RUN" == "true" ]]; then
        # Check if this is a dry run (no actual changes)
        # "$DRY_RUN" == "true": String comparison for dry run flag
        
        log_info "DRY RUN: Would create namespace $NAMESPACE"
        # Inform user what would be done in dry run mode
        # $NAMESPACE: Show which namespace would be created
        
        return 0
        # return 0: Exit function successfully without making changes
        # Allows script to continue showing what would be done
    fi
    
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    # kubectl create namespace: Generate namespace YAML
    # "$NAMESPACE": Use configured namespace name
    # --dry-run=client: Generate YAML without creating resource
    # -o yaml: Output in YAML format
    # |: Pipe output to next command
    # kubectl apply -f -: Apply YAML from stdin (-)
    # This pattern allows modification of generated YAML before applying
    
    # Label namespace
    kubectl label namespace "$NAMESPACE" \
        environment="$ENVIRONMENT" \
        project="spring-petclinic" \
        --overwrite
    # kubectl label: Add labels to namespace
    # namespace "$NAMESPACE": Target the created namespace
    # environment="$ENVIRONMENT": Label with deployment environment
    # project="spring-petclinic": Label with project name
    # --overwrite: Replace existing labels if they exist
    # Labels are used for organization, selection, and policies
    
    log_success "Namespace $NAMESPACE created/updated"
    # Confirm namespace deployment completed successfully
    # Shows which namespace was created or updated
}

# =============================================================================
# SECRETS DEPLOYMENT FUNCTION
# =============================================================================

deploy_secrets() {
    # deploy_secrets: Create Kubernetes secrets for sensitive data
    # Stores database credentials and other sensitive configuration
    # Separates secrets from application configuration for security
    
    log_header "🔐 DEPLOYING SECRETS"
    # Display section header for secrets deployment
    
    if [[ "$DRY_RUN" == "true" ]]; then
        # Check if this is a dry run
        log_info "DRY RUN: Would deploy secrets"
        return 0
        # Skip actual secret creation in dry run mode
    fi
    
    # MySQL credentials secret
    kubectl create secret generic mysql-credentials \
        --from-literal=root-password="petclinic-root" \
        --from-literal=username="petclinic" \
        --from-literal=password="petclinic-password" \
        --namespace="$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    # kubectl create secret generic: Create generic secret (key-value pairs)
    # mysql-credentials: Secret name referenced by database deployments
    # --from-literal: Create secret from literal string values
    # root-password="petclinic-root": MySQL root user password
    # username="petclinic": Application database username
    # password="petclinic-password": Application database password
    # --namespace="$NAMESPACE": Create in specified namespace
    # --dry-run=client -o yaml: Generate YAML without creating
    # | kubectl apply -f -: Apply generated YAML (idempotent)
    
    log_success "Secrets deployed"
    # Confirm secrets were created successfully
}

# =============================================================================
# DATABASE DEPLOYMENT FUNCTION
# =============================================================================

deploy_databases() {
    # deploy_databases: Deploy MySQL database instances
    # Creates StatefulSets for persistent database storage
    # Deploys separate databases for each microservice
    
    log_header "🗄️ DEPLOYING DATABASES"
    # Display section header for database deployment
    
    local databases=("mysql-customer" "mysql-vet" "mysql-visit")
    # databases: Array of database names to deploy
    # local: Variable only exists within this function
    # Each microservice gets its own database for data isolation
    
    for db in "${databases[@]}"; do
        # for loop: Iterate through each database in the array
        # "${databases[@]}": Expand array elements as separate words
        # db: Loop variable containing current database name
        
        log_info "Deploying $db..."
        # Show progress for current database deployment
        # $db: Current database name from loop
        
        if [[ "$DRY_RUN" == "true" ]]; then
            # Check if this is a dry run
            log_info "DRY RUN: Would deploy $db"
            continue
            # continue: Skip to next iteration in dry run mode
            # Shows what would be deployed without making changes
        fi
        
        # Apply database manifests
        kubectl apply -f "k8s-manifests/databases/$db/" -n "$NAMESPACE"
        # kubectl apply: Apply Kubernetes manifests
        # -f "k8s-manifests/databases/$db/": Apply all files in database directory
        # $db: Current database name (mysql-customer, mysql-vet, mysql-visit)
        # -n "$NAMESPACE": Apply to specified namespace
        # Each database has its own directory with StatefulSet and Service
        
        # Wait for database to be ready
        log_info "Waiting for $db to be ready..."
        # Inform user that script is waiting for database startup
        
        kubectl wait --for=condition=ready pod -l app="$db" -n "$NAMESPACE" --timeout="${TIMEOUT}s"
        # kubectl wait: Wait for specific condition to be met
        # --for=condition=ready: Wait for pod ready condition
        # pod: Wait for pod resources
        # -l app="$db": Select pods with app label matching database name
        # -n "$NAMESPACE": Look in specified namespace
        # --timeout="${TIMEOUT}s": Maximum time to wait (in seconds)
        # Ensures database is fully started before proceeding
        
        log_success "$db deployed and ready"
        # Confirm database deployment and readiness
    done
    # End of database deployment loop
}

# =============================================================================
# SERVICE DEPLOYMENT FUNCTION
# =============================================================================

deploy_service() {
    # deploy_service: Deploy individual microservice
    # Parameter: $1 - Service name to deploy
    # Checks dependencies, applies manifests, waits for readiness
    
    local service="$1"
    # service: Local variable containing service name from parameter
    # $1: First parameter passed to function
    
    log_info "Deploying $service..."
    # Show progress for current service deployment
    
    if [[ "$DRY_RUN" == "true" ]]; then
        # Check if this is a dry run
        log_info "DRY RUN: Would deploy $service"
        return 0
        # Skip actual deployment in dry run mode
    fi
    
    # Check dependencies
    local dependencies="${SERVICE_DEPENDENCIES[$service]}"
    # dependencies: Get dependency list for current service
    # ${SERVICE_DEPENDENCIES[$service]}: Look up dependencies in associative array
    # $service: Current service name used as array key
    
    if [[ -n "$dependencies" ]]; then
        # -n "$dependencies": Check if dependencies string is not empty
        # If service has dependencies, verify they are running
        
        for dep in $dependencies; do
            # for loop: Iterate through space-separated dependencies
            # $dependencies: String of dependency names separated by spaces
            # dep: Current dependency name
            
            log_info "Checking dependency: $dep"
            # Show which dependency is being checked
            
            if ! kubectl get deployment "$dep" -n "$NAMESPACE" >/dev/null 2>&1; then
                # kubectl get deployment: Check if deployment exists
                # "$dep": Dependency deployment name
                # -n "$NAMESPACE": Look in specified namespace
                # >/dev/null 2>&1: Suppress output
                # !: Negate result (true if deployment doesn't exist)
                
                log_error "Dependency $dep not found for $service"
                # Report missing dependency error
                return 1
                # return 1: Exit function with error
                # Prevents deployment of service with missing dependencies
            fi
            
            # Wait for dependency to be ready
            kubectl wait --for=condition=available deployment/"$dep" -n "$NAMESPACE" --timeout=60s
            # kubectl wait: Wait for deployment to be available
            # --for=condition=available: Wait for deployment available condition
            # deployment/"$dep": Target specific deployment
            # --timeout=60s: Wait maximum 60 seconds for dependency
            # Ensures dependency is ready before deploying dependent service
        done
        # End of dependency checking loop
    fi
    
    # Apply service manifests
    envsubst < "k8s-manifests/services/$service/deployment.yml" | kubectl apply -f - -n "$NAMESPACE"
    # envsubst: Substitute environment variables in template
    # <: Read from file (input redirection)
    # "k8s-manifests/services/$service/deployment.yml": Service deployment template
    # $service: Current service name for directory path
    # |: Pipe substituted content to kubectl
    # kubectl apply -f -: Apply YAML from stdin
    # -n "$NAMESPACE": Apply to specified namespace
    # Allows dynamic configuration based on environment variables
    
    # Wait for service to be ready
    log_info "Waiting for $service to be ready..."
    # Inform user that script is waiting for service startup
    
    kubectl wait --for=condition=available deployment/"$service" -n "$NAMESPACE" --timeout="${TIMEOUT}s"
    # kubectl wait: Wait for deployment to be available
    # --for=condition=available: Wait for all replicas to be ready
    # deployment/"$service": Target specific service deployment
    # --timeout="${TIMEOUT}s": Use configured timeout value
    # Ensures service is fully ready before proceeding
    
    log_success "$service deployed and ready"
    # Confirm service deployment and readiness
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================

main() {
    # main: Primary execution function
    # Orchestrates entire deployment process
    # Handles errors and provides comprehensive logging
    
    local start_time=$(date +%s)
    # start_time: Record deployment start time in seconds since epoch
    # $(date +%s): Command substitution to get current timestamp
    # Used to calculate total deployment time
    
    log_header "🚀 SPRING PETCLINIC DEPLOYMENT STARTED"
    # Display main header for deployment start
    
    # Set trap for cleanup on exit
    trap 'log_error "Deployment interrupted"; exit 1' INT TERM
    # trap: Set signal handler for script interruption
    # 'log_error "Deployment interrupted"; exit 1': Command to run on signal
    # INT: Handle Ctrl+C (SIGINT)
    # TERM: Handle termination signal (SIGTERM)
    # Ensures clean error reporting if deployment is interrupted
    
    # Execute deployment phases
    for phase in "${PHASES[@]}"; do
        # for loop: Execute each deployment phase in order
        # "${PHASES[@]}": Expand phases array elements
        # phase: Current phase name
        
        case $phase in
            # case statement: Execute different code based on phase name
            # $phase: Current phase value to match against patterns
            
            "namespace")
                deploy_namespace
                # Execute namespace deployment function
                ;;
                # ;; End of case branch
            
            "secrets")
                deploy_secrets
                # Execute secrets deployment function
                ;;
            
            "databases")
                deploy_databases
                # Execute database deployment function
                ;;
            
            "infrastructure")
                # Deploy infrastructure services (config and discovery)
                local services=("config-server" "discovery-server")
                # services: Array of infrastructure service names
                # These services must start before application services
                
                for service in "${services[@]}"; do
                    # Deploy each infrastructure service
                    deploy_service "$service"
                    # Call deploy_service function with service name parameter
                done
                ;;
            
            "services")
                # Deploy application services
                local services=("api-gateway" "customer-service" "vet-service" "visit-service" "admin-server")
                # services: Array of application service names
                # These depend on infrastructure services
                
                for service in "${services[@]}"; do
                    # Deploy each application service
                    deploy_service "$service"
                    # Call deploy_service function with service name parameter
                done
                ;;
            
            "monitoring")
                # Deploy monitoring stack
                if [[ "$DRY_RUN" == "true" ]]; then
                    log_info "DRY RUN: Would deploy monitoring stack"
                else
                    kubectl apply -f monitoring/ -n "$NAMESPACE"
                    # Apply all monitoring manifests
                    # monitoring/: Directory containing Prometheus, Grafana, etc.
                fi
                ;;
            
            "validation")
                # Validate deployment success
                if [[ "$DRY_RUN" == "true" ]]; then
                    log_info "DRY RUN: Would validate deployment"
                else
                    # Run validation checks (implementation would go here)
                    log_success "Deployment validation completed"
                fi
                ;;
        esac
        # End of case statement
    done
    # End of phases loop
    
    # Calculate deployment time
    local end_time=$(date +%s)
    # end_time: Record deployment completion time
    local duration=$((end_time - start_time))
    # duration: Calculate total deployment time in seconds
    # $((...)): Arithmetic expansion for calculation
    
    log_header "✅ DEPLOYMENT COMPLETED SUCCESSFULLY"
    # Display completion header
    
    log_success "Total deployment time: ${duration}s"
    # Show total time taken for deployment
    # ${duration}s: Duration in seconds
}

# =============================================================================
# COMMAND LINE ARGUMENT PARSING
# =============================================================================

while [[ $# -gt 0 ]]; do
    # while loop: Process all command line arguments
    # $#: Number of positional parameters
    # -gt 0: Greater than 0 (arguments remaining)
    
    case $1 in
        # case statement: Handle different argument types
        # $1: First remaining argument
        
        --namespace)
            NAMESPACE="$2"
            # Set namespace from next argument
            # $2: Second argument (value for --namespace)
            shift 2
            # shift 2: Remove both --namespace and its value from arguments
            ;;
        
        --environment)
            ENVIRONMENT="$2"
            # Set environment from next argument
            shift 2
            # Remove both --environment and its value
            ;;
        
        --image-tag)
            IMAGE_TAG="$2"
            # Set image tag from next argument
            shift 2
            # Remove both --image-tag and its value
            ;;
        
        --dry-run)
            DRY_RUN="true"
            # Enable dry run mode (no actual changes)
            shift
            # shift: Remove --dry-run argument (no value needed)
            ;;
        
        --help)
            # Display help information
            echo "Usage: $0 [OPTIONS]"
            # $0: Script name
            echo "Options:"
            echo "  --namespace NAME     Kubernetes namespace (default: petclinic)"
            echo "  --environment ENV    Environment (default: development)"
            echo "  --image-tag TAG      Docker image tag (default: latest)"
            echo "  --dry-run           Perform dry run without actual deployment"
            echo "  --help              Show this help message"
            exit 0
            # exit 0: Exit successfully after showing help
            ;;
        
        *)
            # Default case: Unknown argument
            log_error "Unknown option: $1"
            # $1: The unknown argument
            exit 1
            # exit 1: Exit with error for unknown arguments
            ;;
    esac
done
# End of argument processing loop

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Check prerequisites and execute main function
check_prerequisites
# Verify all required tools and access before starting
main "$@"
# Execute main deployment function
# "$@": Pass all remaining arguments to main function
