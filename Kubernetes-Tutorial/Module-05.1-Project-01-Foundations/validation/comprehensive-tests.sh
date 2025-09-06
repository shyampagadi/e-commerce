#!/bin/bash
# =============================================================================
# COMPREHENSIVE VALIDATION SCRIPT
# =============================================================================
# This script performs comprehensive validation of the e-commerce foundation
# infrastructure project, testing all components and requirements.
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
# SCRIPT VARIABLES
# =============================================================================
# Define variables for consistent configuration throughout the script.
# =============================================================================

NAMESPACE_ECOMMERCE="ecommerce"
# Purpose: Specifies the e-commerce application namespace
# Why needed: Provides consistent namespace reference throughout script
# Impact: All e-commerce resources are validated in this namespace
# Value: 'ecommerce' matches the project's application namespace

NAMESPACE_MONITORING="monitoring"
# Purpose: Specifies the monitoring components namespace
# Why needed: Provides consistent namespace reference for monitoring resources
# Impact: All monitoring resources are validated in this namespace
# Value: 'monitoring' matches the project's monitoring namespace

TIMEOUT=300
# Purpose: Specifies the timeout for waiting operations in seconds
# Why needed: Prevents infinite waiting for resource readiness
# Impact: Operations will timeout after 5 minutes if not ready
# Value: 300 seconds (5 minutes) provides reasonable wait time

LOG_FILE="/tmp/validation-$(date +%Y%m%d-%H%M%S).log"
# Purpose: Specifies the log file for validation output
# Why needed: Provides persistent record of validation results
# Impact: All validation output is logged to this file
# Value: Timestamped filename ensures unique log files

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================
# Functions for consistent logging throughout the validation script.
# =============================================================================

log() {
    # =============================================================================
    # LOG FUNCTION
    # =============================================================================
    # Logs messages with timestamp to both console and log file.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the message to log
    # Why needed: Provides the content to be logged
    # Impact: Message is logged with timestamp
    # Parameter: $1 is the message string
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp
    # Why needed: Provides timestamp for log entries
    # Impact: Each log entry includes precise timestamp
    # Format: YYYY-MM-DD HH:MM:SS format for readability
    
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
    # Purpose: Outputs message to console and log file
    # Why needed: Provides both immediate feedback and persistent logging
    # Impact: Message appears on console and is saved to log file
    # Command: tee -a appends to log file while displaying on console
}

log_success() {
    # =============================================================================
    # SUCCESS LOG FUNCTION
    # =============================================================================
    # Logs success messages with green color formatting.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the success message to log
    # Why needed: Provides the success content to be logged
    # Impact: Success message is logged with green formatting
    # Parameter: $1 is the success message string
    
    log "✅ SUCCESS: $message"
    # Purpose: Logs success message with checkmark
    # Why needed: Clearly identifies successful operations
    # Impact: Success messages are clearly marked and logged
    # Format: ✅ SUCCESS: prefix for easy identification
}

log_error() {
    # =============================================================================
    # ERROR LOG FUNCTION
    # =============================================================================
    # Logs error messages with red color formatting.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the error message to log
    # Why needed: Provides the error content to be logged
    # Impact: Error message is logged with red formatting
    # Parameter: $1 is the error message string
    
    log "❌ ERROR: $message"
    # Purpose: Logs error message with X mark
    # Why needed: Clearly identifies failed operations
    # Impact: Error messages are clearly marked and logged
    # Format: ❌ ERROR: prefix for easy identification
}

log_warning() {
    # =============================================================================
    # WARNING LOG FUNCTION
    # =============================================================================
    # Logs warning messages with yellow color formatting.
    # =============================================================================
    
    local message="$1"
    # Purpose: Specifies the warning message to log
    # Why needed: Provides the warning content to be logged
    # Impact: Warning message is logged with yellow formatting
    # Parameter: $1 is the warning message string
    
    log "⚠️  WARNING: $message"
    # Purpose: Logs warning message with warning symbol
    # Why needed: Clearly identifies operations that need attention
    # Impact: Warning messages are clearly marked and logged
    # Format: ⚠️  WARNING: prefix for easy identification
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================
# Functions for validating different aspects of the infrastructure.
# =============================================================================

validate_prerequisites() {
    # =============================================================================
    # PREREQUISITES VALIDATION FUNCTION
    # =============================================================================
    # Validates that all required tools and access are available.
    # =============================================================================
    
    log "🔍 Validating prerequisites..."
    # Purpose: Logs the start of prerequisites validation
    # Why needed: Provides clear indication of validation progress
    # Impact: Users can see that prerequisites are being checked
    # Message: Clear indication of current validation step
    
    # Check kubectl availability
    if ! command -v kubectl &> /dev/null; then
        # Purpose: Checks if kubectl command is available
        # Why needed: kubectl is required for Kubernetes operations
        # Impact: Script will fail if kubectl is not available
        # Command: command -v checks if kubectl is in PATH
        
        log_error "kubectl is not installed or not in PATH"
        # Purpose: Logs error if kubectl is not available
        # Why needed: Provides clear error message for missing tool
        # Impact: User knows exactly what is missing
        # Message: Clear indication of missing kubectl
        
        exit 1
        # Purpose: Exits script with error code 1
        # Why needed: Cannot continue without kubectl
        # Impact: Script stops execution immediately
        # Code: 1 indicates general error
    else
        log_success "kubectl is available"
        # Purpose: Logs success if kubectl is available
        # Why needed: Confirms that kubectl requirement is met
        # Impact: User knows kubectl is working
        # Message: Clear indication of successful check
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        # Purpose: Checks if kubectl can connect to cluster
        # Why needed: Cluster access is required for validation
        # Impact: Script will fail if cluster is not accessible
        # Command: kubectl cluster-info tests cluster connectivity
        
        log_error "Cannot connect to Kubernetes cluster"
        # Purpose: Logs error if cluster is not accessible
        # Why needed: Provides clear error message for connectivity issue
        # Impact: User knows cluster connection failed
        # Message: Clear indication of connectivity problem
        
        exit 1
        # Purpose: Exits script with error code 1
        # Why needed: Cannot continue without cluster access
        # Impact: Script stops execution immediately
        # Code: 1 indicates general error
    else
        log_success "Kubernetes cluster is accessible"
        # Purpose: Logs success if cluster is accessible
        # Why needed: Confirms that cluster requirement is met
        # Impact: User knows cluster connection is working
        # Message: Clear indication of successful check
    fi
    
    # Check jq availability
    if ! command -v jq &> /dev/null; then
        # Purpose: Checks if jq command is available
        # Why needed: jq is required for JSON processing
        # Impact: Some validations will fail without jq
        # Command: command -v checks if jq is in PATH
        
        log_warning "jq is not installed - some validations may be limited"
        # Purpose: Logs warning if jq is not available
        # Why needed: Provides warning but allows script to continue
        # Impact: User knows jq is missing but script continues
        # Message: Clear indication of missing jq with impact
    else
        log_success "jq is available"
        # Purpose: Logs success if jq is available
        # Why needed: Confirms that jq requirement is met
        # Impact: User knows jq is working
        # Message: Clear indication of successful check
    fi
}

validate_namespaces() {
    # =============================================================================
    # NAMESPACES VALIDATION FUNCTION
    # =============================================================================
    # Validates that required namespaces exist and are properly configured.
    # =============================================================================
    
    log "🔍 Validating namespaces..."
    # Purpose: Logs the start of namespaces validation
    # Why needed: Provides clear indication of validation progress
    # Impact: Users can see that namespaces are being checked
    # Message: Clear indication of current validation step
    
    # Check ecommerce namespace
    if kubectl get namespace "$NAMESPACE_ECOMMERCE" &> /dev/null; then
        # Purpose: Checks if ecommerce namespace exists
        # Why needed: E-commerce application requires this namespace
        # Impact: Validation will fail if namespace is missing
        # Command: kubectl get namespace checks namespace existence
        
        log_success "E-commerce namespace exists"
        # Purpose: Logs success if ecommerce namespace exists
        # Why needed: Confirms that ecommerce namespace requirement is met
        # Impact: User knows ecommerce namespace is available
        # Message: Clear indication of successful check
        
        # Check namespace labels
        local labels=$(kubectl get namespace "$NAMESPACE_ECOMMERCE" -o jsonpath='{.metadata.labels}' 2>/dev/null || echo '{}')
        # Purpose: Gets namespace labels for validation
        # Why needed: Namespace should have proper labels
        # Impact: Validates namespace configuration
        # Command: kubectl get namespace with jsonpath extracts labels
        
        if echo "$labels" | jq -e '.name' &> /dev/null; then
            # Purpose: Checks if namespace has name label
            # Why needed: Namespace should be properly labeled
            # Impact: Validates namespace labeling
            # Command: jq -e checks if name label exists
            
            log_success "E-commerce namespace has proper labels"
            # Purpose: Logs success if namespace has labels
            # Why needed: Confirms that namespace labeling is correct
            # Impact: User knows namespace is properly configured
            # Message: Clear indication of successful check
        else
            log_warning "E-commerce namespace missing labels"
            # Purpose: Logs warning if namespace lacks labels
            # Why needed: Provides warning about missing labels
            # Impact: User knows namespace needs better labeling
            # Message: Clear indication of labeling issue
        fi
    else
        log_error "E-commerce namespace does not exist"
        # Purpose: Logs error if ecommerce namespace is missing
        # Why needed: Provides clear error message for missing namespace
        # Impact: User knows ecommerce namespace is missing
        # Message: Clear indication of missing namespace
        
        return 1
        # Purpose: Returns error code 1
        # Why needed: Indicates namespace validation failed
        # Impact: Function returns error status
        # Code: 1 indicates error condition
    fi
    
    # Check monitoring namespace
    if kubectl get namespace "$NAMESPACE_MONITORING" &> /dev/null; then
        # Purpose: Checks if monitoring namespace exists
        # Why needed: Monitoring components require this namespace
        # Impact: Validation will fail if namespace is missing
        # Command: kubectl get namespace checks namespace existence
        
        log_success "Monitoring namespace exists"
        # Purpose: Logs success if monitoring namespace exists
        # Why needed: Confirms that monitoring namespace requirement is met
        # Impact: User knows monitoring namespace is available
        # Message: Clear indication of successful check
    else
        log_error "Monitoring namespace does not exist"
        # Purpose: Logs error if monitoring namespace is missing
        # Why needed: Provides clear error message for missing namespace
        # Impact: User knows monitoring namespace is missing
        # Message: Clear indication of missing namespace
        
        return 1
        # Purpose: Returns error code 1
        # Why needed: Indicates namespace validation failed
        # Impact: Function returns error status
        # Code: 1 indicates error condition
    fi
}

validate_ecommerce_application() {
    # =============================================================================
    # E-COMMERCE APPLICATION VALIDATION FUNCTION
    # =============================================================================
    # Validates that the e-commerce application is deployed and running.
    # =============================================================================
    
    log "🔍 Validating e-commerce application..."
    # Purpose: Logs the start of e-commerce application validation
    # Why needed: Provides clear indication of validation progress
    # Impact: Users can see that e-commerce application is being checked
    # Message: Clear indication of current validation step
    
    # Check database deployment
    if kubectl get deployment ecommerce-database -n "$NAMESPACE_ECOMMERCE" &> /dev/null; then
        # Purpose: Checks if database deployment exists
        # Why needed: Database is required for e-commerce application
        # Impact: Validation will fail if deployment is missing
        # Command: kubectl get deployment checks deployment existence
        
        local db_ready=$(kubectl get deployment ecommerce-database -n "$NAMESPACE_ECOMMERCE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        # Purpose: Gets the number of ready replicas
        # Why needed: Validates that deployment is actually running
        # Impact: Confirms deployment is healthy
        # Command: kubectl get deployment with jsonpath extracts ready replicas
        
        if [ "$db_ready" -gt 0 ]; then
            # Purpose: Checks if at least one replica is ready
            # Why needed: Database should have at least one running pod
            # Impact: Validates database is operational
            # Condition: db_ready > 0 means database is running
            
            log_success "Database deployment is running ($db_ready replicas ready)"
            # Purpose: Logs success if database is running
            # Why needed: Confirms that database requirement is met
            # Impact: User knows database is operational
            # Message: Clear indication of successful check with replica count
        else
            log_error "Database deployment is not ready"
            # Purpose: Logs error if database is not ready
            # Why needed: Provides clear error message for database issue
            # Impact: User knows database is not working
            # Message: Clear indication of database problem
            
            return 1
            # Purpose: Returns error code 1
            # Why needed: Indicates database validation failed
            # Impact: Function returns error status
            # Code: 1 indicates error condition
        fi
    else
        log_error "Database deployment does not exist"
        # Purpose: Logs error if database deployment is missing
        # Why needed: Provides clear error message for missing deployment
        # Impact: User knows database deployment is missing
        # Message: Clear indication of missing deployment
        
        return 1
        # Purpose: Returns error code 1
        # Why needed: Indicates database validation failed
        # Impact: Function returns error status
        # Code: 1 indicates error condition
    fi
    
    # Check backend deployment
    if kubectl get deployment ecommerce-backend -n "$NAMESPACE_ECOMMERCE" &> /dev/null; then
        # Purpose: Checks if backend deployment exists
        # Why needed: Backend is required for e-commerce application
        # Impact: Validation will fail if deployment is missing
        # Command: kubectl get deployment checks deployment existence
        
        local backend_ready=$(kubectl get deployment ecommerce-backend -n "$NAMESPACE_ECOMMERCE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        # Purpose: Gets the number of ready replicas
        # Why needed: Validates that deployment is actually running
        # Impact: Confirms deployment is healthy
        # Command: kubectl get deployment with jsonpath extracts ready replicas
        
        if [ "$backend_ready" -gt 0 ]; then
            # Purpose: Checks if at least one replica is ready
            # Why needed: Backend should have at least one running pod
            # Impact: Validates backend is operational
            # Condition: backend_ready > 0 means backend is running
            
            log_success "Backend deployment is running ($backend_ready replicas ready)"
            # Purpose: Logs success if backend is running
            # Why needed: Confirms that backend requirement is met
            # Impact: User knows backend is operational
            # Message: Clear indication of successful check with replica count
        else
            log_error "Backend deployment is not ready"
            # Purpose: Logs error if backend is not ready
            # Why needed: Provides clear error message for backend issue
            # Impact: User knows backend is not working
            # Message: Clear indication of backend problem
            
            return 1
            # Purpose: Returns error code 1
            # Why needed: Indicates backend validation failed
            # Impact: Function returns error status
            # Code: 1 indicates error condition
        fi
    else
        log_error "Backend deployment does not exist"
        # Purpose: Logs error if backend deployment is missing
        # Why needed: Provides clear error message for missing deployment
        # Impact: User knows backend deployment is missing
        # Message: Clear indication of missing deployment
        
        return 1
        # Purpose: Returns error code 1
        # Why needed: Indicates backend validation failed
        # Impact: Function returns error status
        # Code: 1 indicates error condition
    fi
    
    # Check frontend deployment
    if kubectl get deployment ecommerce-frontend -n "$NAMESPACE_ECOMMERCE" &> /dev/null; then
        # Purpose: Checks if frontend deployment exists
        # Why needed: Frontend is required for e-commerce application
        # Impact: Validation will fail if deployment is missing
        # Command: kubectl get deployment checks deployment existence
        
        local frontend_ready=$(kubectl get deployment ecommerce-frontend -n "$NAMESPACE_ECOMMERCE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        # Purpose: Gets the number of ready replicas
        # Why needed: Validates that deployment is actually running
        # Impact: Confirms deployment is healthy
        # Command: kubectl get deployment with jsonpath extracts ready replicas
        
        if [ "$frontend_ready" -gt 0 ]; then
            # Purpose: Checks if at least one replica is ready
            # Why needed: Frontend should have at least one running pod
            # Impact: Validates frontend is operational
            # Condition: frontend_ready > 0 means frontend is running
            
            log_success "Frontend deployment is running ($frontend_ready replicas ready)"
            # Purpose: Logs success if frontend is running
            # Why needed: Confirms that frontend requirement is met
            # Impact: User knows frontend is operational
            # Message: Clear indication of successful check with replica count
        else
            log_error "Frontend deployment is not ready"
            # Purpose: Logs error if frontend is not ready
            # Why needed: Provides clear error message for frontend issue
            # Impact: User knows frontend is not working
            # Message: Clear indication of frontend problem
            
            return 1
            # Purpose: Returns error code 1
            # Why needed: Indicates frontend validation failed
            # Impact: Function returns error status
            # Code: 1 indicates error condition
        fi
    else
        log_error "Frontend deployment does not exist"
        # Purpose: Logs error if frontend deployment is missing
        # Why needed: Provides clear error message for missing deployment
        # Impact: User knows frontend deployment is missing
        # Message: Clear indication of missing deployment
        
        return 1
        # Purpose: Returns error code 1
        # Why needed: Indicates frontend validation failed
        # Impact: Function returns error status
        # Code: 1 indicates error condition
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
# Main script execution that runs all validation functions.
# =============================================================================

main() {
    # =============================================================================
    # MAIN FUNCTION
    # =============================================================================
    # Main function that orchestrates all validation steps.
    # =============================================================================
    
    log "🚀 Starting comprehensive validation of e-commerce foundation infrastructure..."
    # Purpose: Logs the start of validation process
    # Why needed: Provides clear indication that validation is beginning
    # Impact: Users can see that validation is starting
    # Message: Clear indication of validation start with project name
    
    # Run validation functions
    validate_prerequisites
    # Purpose: Validates that all prerequisites are met
    # Why needed: Ensures script can run successfully
    # Impact: Script will exit if prerequisites are not met
    # Function: validate_prerequisites checks tools and access
    
    validate_namespaces
    # Purpose: Validates that required namespaces exist
    # Why needed: Ensures namespaces are properly configured
    # Impact: Script will fail if namespaces are missing
    # Function: validate_namespaces checks namespace existence and configuration
    
    validate_ecommerce_application
    # Purpose: Validates that e-commerce application is running
    # Why needed: Ensures application is deployed and operational
    # Impact: Script will fail if application is not working
    # Function: validate_ecommerce_application checks all application components
    
    log_success "✅ All validations completed successfully!"
    # Purpose: Logs successful completion of all validations
    # Why needed: Provides clear indication that all checks passed
    # Impact: User knows that validation was successful
    # Message: Clear indication of successful completion
    
    log "📋 Validation log saved to: $LOG_FILE"
    # Purpose: Logs the location of the validation log file
    # Why needed: Provides reference to detailed validation results
    # Impact: User knows where to find detailed logs
    # Message: Clear indication of log file location
}

# Run main function
main "$@"
# Purpose: Executes the main function with all command line arguments
# Why needed: Starts the validation process
# Impact: Script begins execution
# Arguments: $@ passes all command line arguments to main function
