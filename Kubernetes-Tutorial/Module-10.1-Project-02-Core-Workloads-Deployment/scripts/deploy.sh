#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION DEPLOYMENT SCRIPT
# =============================================================================
# This script provides comprehensive deployment automation for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# rolling updates, health checks, resource management, and monitoring stack.
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
# DEPLOYMENT CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent deployment configuration throughout the script.
# =============================================================================

ENVIRONMENT="${1:-production}"
# Purpose: Specifies the target deployment environment
# Why needed: Determines which configuration values to use for deployment
# Impact: Controls resource allocation, scaling, and environment-specific settings
# Value: Defaults to 'production' for safety, accepts 'development', 'staging', 'production'

DRY_RUN=false
# Purpose: Enables dry-run mode for deployment validation without actual changes
# Why needed: Allows testing deployment configuration without affecting cluster
# Impact: When true, shows what would be deployed without making changes
# Usage: Set via --dry-run command line argument

VALIDATE=false
# Purpose: Enables validation mode to check deployment prerequisites
# Why needed: Ensures all requirements are met before deployment
# Impact: When true, validates cluster state, resources, and configurations
# Usage: Set via --validate command line argument

MONITOR=false
# Purpose: Enables monitoring mode to track deployment progress
# Why needed: Provides real-time visibility into deployment status
# Impact: When true, continuously monitors deployment progress and health
# Usage: Set via --monitor command line argument

ROLLBACK=false
# Purpose: Enables rollback mode to revert to previous deployment
# Why needed: Provides quick recovery from failed deployments
# Impact: When true, reverts to the last known good deployment
# Usage: Set via --rollback command line argument

FORCE=false
# Purpose: Enables force mode to override safety checks
# Why needed: Allows deployment even when warnings or conflicts exist
# Impact: When true, bypasses validation warnings and forces deployment
# Usage: Set via --force command line argument

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for deployment
# Why needed: Provides consistent namespace reference for all resources
# Impact: All deployed resources are created in this namespace
# Value: 'ecommerce' matches the project's application namespace

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --validate)
            VALIDATE=true
            shift
            ;;
        --monitor)
            MONITOR=true
            shift
            ;;
        --rollback)
            ROLLBACK=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --namespace=*)
            NAMESPACE="${arg#*=}"
            shift
            ;;
    esac
done

# =============================================================================
# COLOR CODES FOR OUTPUT FORMATTING
# =============================================================================
# Define color codes for consistent output formatting throughout the script.
# =============================================================================

RED='\033[0;31m'
# Purpose: Red color code for error messages and failed deployments
# Why needed: Provides visual distinction for error output
# Impact: Error messages are displayed in red color
# Usage: Used in print_status() function for ERROR status messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages and successful deployments
# Why needed: Provides visual distinction for success output
# Impact: Success messages are displayed in green color
# Usage: Used in print_status() function for SUCCESS status messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages and deployment warnings
# Why needed: Provides visual distinction for warning output
# Impact: Warning messages are displayed in yellow color
# Usage: Used in print_status() function for WARNING status messages

BLUE='\033[0;34m'
# Purpose: Blue color code for informational messages and deployment progress
# Why needed: Provides visual distinction for informational output
# Impact: Info messages are displayed in blue color
# Usage: Used in print_status() function for INFO status messages

PURPLE='\033[0;35m'
# Purpose: Purple color code for header messages and section separators
# Why needed: Provides visual distinction for header output
# Impact: Header messages are displayed in purple color
# Usage: Used in print_status() function for HEADER status messages

NC='\033[0m'
# Purpose: No Color code to reset terminal color
# Why needed: Resets terminal color after colored output
# Impact: Prevents color bleeding to subsequent output
# Usage: Used at end of all colored message functions

# =============================================================================
# DEPLOYMENT TRACKING VARIABLES
# =============================================================================
# Variables to track deployment progress and maintain deployment history.
# =============================================================================

DEPLOYMENT_ID=$(date '+%Y%m%d_%H%M%S')
# Purpose: Generates unique deployment identifier based on timestamp
# Why needed: Provides unique identification for each deployment run
# Impact: Used for logging, rollback tracking, and deployment history
# Value: Format: YYYYMMDD_HHMMSS (e.g., 20241215_143022)

DEPLOYMENT_LOG="/tmp/deployment_${DEPLOYMENT_ID}.log"
# Purpose: Specifies the log file path for deployment tracking
# Why needed: Provides persistent record of deployment activities
# Impact: All deployment activities are logged to this file
# Value: Temporary directory with deployment ID for uniqueness

DEPLOYMENT_STATUS="IN_PROGRESS"
# Purpose: Tracks the current status of the deployment process
# Why needed: Provides status tracking for monitoring and error handling
# Impact: Used for status reporting and conditional logic
# Value: States: IN_PROGRESS, SUCCESS, FAILED, ROLLED_BACK

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
# Functions for consistent logging, validation, and deployment operations.
# =============================================================================

# Function: Print colored output with timestamp and logging
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp and file logging for all
    # deployment operations with visual distinction and persistent logging.
    # =============================================================================
    
    local status=$1
    # Purpose: Specifies the status level for message formatting
    # Why needed: Determines the color and prefix for the message display
    # Impact: Controls visual appearance and categorization of the message
    # Parameter: $1 is the status level (INFO, SUCCESS, WARNING, ERROR, HEADER)
    
    local message=$2
    # Purpose: Specifies the message content to display and log
    # Why needed: Provides the actual information to be communicated
    # Impact: Message content is displayed to user and written to log file
    # Parameter: $2 is the message text string
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp for message identification
    # Why needed: Provides temporal context for deployment operations
    # Impact: All messages include timestamp for chronological tracking
    # Format: YYYY-MM-DD HH:MM:SS (e.g., 2024-12-15 14:30:22)
    
    case $status in
        "INFO")
            # Purpose: Displays informational messages in blue color
            # Why needed: Provides visual distinction for general information
            # Impact: Info messages appear in blue with [INFO] prefix
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            ;;
        "SUCCESS")
            # Purpose: Displays success messages in green color
            # Why needed: Provides visual confirmation of successful operations
            # Impact: Success messages appear in green with [SUCCESS] prefix
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            ;;
        "WARNING")
            # Purpose: Displays warning messages in yellow color
            # Why needed: Provides visual attention for cautionary information
            # Impact: Warning messages appear in yellow with [WARNING] prefix
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            ;;
        "ERROR")
            # Purpose: Displays error messages in red color
            # Why needed: Provides visual indication of critical failures
            # Impact: Error messages appear in red with [ERROR] prefix
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            ;;
        "HEADER")
            # Purpose: Displays header messages in purple color
            # Why needed: Provides visual separation for section headers
            # Impact: Header messages appear in purple with [HEADER] prefix
            echo -e "${PURPLE}[HEADER]${NC} [${timestamp}] ${message}"
            ;;
    esac
    
    # Log to file
    # Purpose: Writes all messages to deployment log file for persistence
    # Why needed: Provides permanent record of all deployment activities
    # Impact: All messages are stored in timestamped log file
    # Format: [STATUS] [TIMESTAMP] MESSAGE
    echo "[${status}] [${timestamp}] ${message}" >> "$DEPLOYMENT_LOG"
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Validates if a required command is available in the system PATH for
    # dependency checking and prerequisite validation during deployment.
    # =============================================================================
    
    # Purpose: Validates if a required command is available in the system PATH
    # Why needed: Ensures all required tools are available before deployment
    # Impact: Prevents deployment failures due to missing dependencies
    # Parameters:
    #   $1: Command name to check (e.g., kubectl, helm, docker)
    # Returns: 0 if command exists, 1 if not found
    # Usage: command_exists kubectl
    
    command -v "$1" >/dev/null 2>&1
    # Purpose: Checks if the specified command exists in system PATH
    # Why needed: Validates command availability without displaying output
    # Impact: Returns exit code 0 if command found, 1 if not found
    # Redirect: >/dev/null 2>&1 suppresses both stdout and stderr output
}

# Function: Check deployment prerequisites
check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates all prerequisites for successful deployment including tool
    # availability, cluster connectivity, and namespace existence.
    # =============================================================================
    
    # Purpose: Validates all prerequisites for successful deployment
    # Why needed: Ensures cluster connectivity and required tools are available
    # Impact: Prevents deployment failures due to missing prerequisites
    # Validates: kubectl, cluster connectivity, namespace existence, resource availability
    # Usage: Called automatically at deployment start
    
    print_status "INFO" "Checking deployment prerequisites"
    # Purpose: Logs the start of prerequisite validation
    # Why needed: Provides user feedback about validation progress
    # Impact: User sees that prerequisite checking has begun
    
    # =============================================================================
    # KUBECTL COMMAND AVAILABILITY CHECK
    # =============================================================================
    # Purpose: Verify kubectl command is available in system PATH
    # Why needed: kubectl is required for all Kubernetes operations
    
    if ! command_exists kubectl; then
        # Purpose: Check if kubectl command exists using command_exists function
        # Why needed: Validates kubectl availability before attempting to use it
        # Impact: If kubectl not found, deployment cannot proceed
        
        print_status "ERROR" "kubectl command not found. Please install kubectl."
        # Purpose: Log error message about missing kubectl
        # Why needed: Provides clear error message to user
        # Impact: User knows they need to install kubectl
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Prevents further execution without kubectl
        # Impact: Script terminates immediately with error status
    fi
    
    # =============================================================================
    # KUBERNETES CLUSTER CONNECTIVITY CHECK
    # =============================================================================
    # Purpose: Verify connection to Kubernetes cluster
    # Why needed: Ensures cluster is accessible before deployment
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # Purpose: Test cluster connectivity using kubectl cluster-info
        # Why needed: Validates cluster accessibility and kubeconfig validity
        # Impact: If cluster unreachable, deployment cannot proceed
        # Redirect: >/dev/null 2>&1 suppresses output, only checks exit code
        
        print_status "ERROR" "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        # Purpose: Log error message about cluster connectivity
        # Why needed: Provides clear error message about connection issue
        # Impact: User knows to check their kubeconfig configuration
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Prevents further execution without cluster access
        # Impact: Script terminates immediately with error status
    fi
    
    # =============================================================================
    # NAMESPACE EXISTENCE CHECK AND CREATION
    # =============================================================================
    # Purpose: Verify target namespace exists, create if necessary
    # Why needed: Namespace is required for resource deployment
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if target namespace exists
        # Why needed: Validates namespace availability before deployment
        # Impact: If namespace doesn't exist, it needs to be created
        # Redirect: >/dev/null 2>&1 suppresses output, only checks exit code
        
        print_status "INFO" "Namespace $NAMESPACE does not exist. Creating..."
        # Purpose: Log information about namespace creation
        # Why needed: Provides user feedback about namespace creation
        # Impact: User knows namespace will be created
        
        if [ "$DRY_RUN" = false ]; then
            # Purpose: Check if this is not a dry run
            # Why needed: Only create namespace if actually deploying
            # Impact: Dry run mode shows what would be done without doing it
            
            kubectl create namespace "$NAMESPACE"
            # Purpose: Create the target namespace
            # Why needed: Namespace is required for resource deployment
            # Impact: Namespace is created and ready for resource deployment
            
            print_status "SUCCESS" "Namespace $NAMESPACE created"
            # Purpose: Log success message about namespace creation
            # Why needed: Confirms namespace was created successfully
            # Impact: User knows namespace creation succeeded
        else
            print_status "INFO" "DRY RUN: Would create namespace $NAMESPACE"
            # Purpose: Log dry run message about namespace creation
            # Why needed: Shows what would be done in dry run mode
            # Impact: User sees what would happen without actual creation
        fi
    else
        print_status "SUCCESS" "Namespace $NAMESPACE exists"
        # Purpose: Log success message about existing namespace
        # Why needed: Confirms namespace is available for deployment
        # Impact: User knows namespace is ready for resource deployment
    fi
    
    print_status "SUCCESS" "Prerequisites check passed"
    # Purpose: Log final success message for prerequisite validation
    # Why needed: Confirms all prerequisites are met
    # Impact: User knows deployment can proceed with prerequisites satisfied
}

# Function: Deploy Kubernetes manifests
deploy_manifests() {
    # =============================================================================
    # DEPLOY MANIFESTS FUNCTION
    # =============================================================================
    # Deploys all Kubernetes manifest files from a specified directory with
    # comprehensive error handling, dry-run support, and progress tracking.
    # =============================================================================
    
    local manifest_dir=$1
    # Purpose: Specifies the directory containing Kubernetes manifest files
    # Why needed: Provides source location for manifest files to deploy
    # Impact: All YAML files in this directory will be deployed
    # Parameter: $1 is the directory path containing manifest files
    
    local description=$2
    # Purpose: Specifies a human-readable description of what is being deployed
    # Why needed: Provides context for logging and user feedback
    # Impact: Used in log messages to identify the deployment type
    # Parameter: $2 is the descriptive text (e.g., "Core Application", "Monitoring Stack")
    
    print_status "INFO" "Deploying $description"
    # Purpose: Log the start of manifest deployment process
    # Why needed: Provides user feedback about deployment progress
    # Impact: User sees that deployment of the specified component has begun
    
    # =============================================================================
    # MANIFEST DIRECTORY VALIDATION
    # =============================================================================
    # Purpose: Verify the manifest directory exists and is accessible
    # Why needed: Prevents deployment failures due to missing directories
    
    if [ ! -d "$manifest_dir" ]; then
        # Purpose: Check if the manifest directory exists and is a directory
        # Why needed: Validates directory existence before attempting to read files
        # Impact: If directory doesn't exist, deployment cannot proceed
        
        print_status "ERROR" "Manifest directory $manifest_dir not found"
        # Purpose: Log error message about missing directory
        # Why needed: Provides clear error message to user
        # Impact: User knows the directory path is incorrect or missing
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates deployment failure due to missing directory
        # Impact: Function terminates immediately with error status
    fi
    
    # =============================================================================
    # YAML FILE DISCOVERY
    # =============================================================================
    # Purpose: Find all YAML manifest files in the specified directory
    # Why needed: Identifies all files that need to be deployed
    
    local yaml_files
    # Purpose: Variable to store list of discovered YAML files
    # Why needed: Provides list of files to process for deployment
    # Impact: Used in loop to deploy each manifest file
    
    yaml_files=$(find "$manifest_dir" -name "*.yaml" -o -name "*.yml" | sort)
    # Purpose: Find all YAML files in directory and sort them alphabetically
    # Why needed: Discovers all manifest files and ensures consistent deployment order
    # Impact: All .yaml and .yml files are found and sorted for processing
    # Command: find searches directory, -o means OR, sort ensures consistent order
    
    if [ -z "$yaml_files" ]; then
        # Purpose: Check if any YAML files were found
        # Why needed: Validates that there are files to deploy
        # Impact: If no files found, deployment cannot proceed
        
        print_status "WARNING" "No YAML files found in $manifest_dir"
        # Purpose: Log warning message about missing YAML files
        # Why needed: Informs user that no files were found to deploy
        # Impact: User knows the directory is empty or contains no YAML files
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: No files to deploy is not an error, just a warning
        # Impact: Function completes successfully with no deployment actions
    fi
    
    # =============================================================================
    # MANIFEST DEPLOYMENT LOOP
    # =============================================================================
    # Purpose: Deploy each discovered YAML file with error handling
    # Why needed: Processes all manifest files in the correct order
    
    for manifest in $yaml_files; do
        # Purpose: Iterate through each discovered YAML file
        # Why needed: Processes all manifest files one by one
        # Impact: Each file is deployed individually with proper error handling
        
        print_status "INFO" "Deploying $(basename "$manifest")"
        # Purpose: Log the start of individual manifest deployment
        # Why needed: Provides progress feedback for each file
        # Impact: User sees which specific file is being deployed
        # basename: Extracts just the filename from the full path
        
        if [ "$DRY_RUN" = true ]; then
            # Purpose: Check if this is a dry run deployment
            # Why needed: Dry run mode shows what would be deployed without making changes
            # Impact: If dry run, only validate manifests without applying them
            
            print_status "INFO" "DRY RUN: Would deploy $manifest"
            # Purpose: Log dry run message for the manifest
            # Why needed: Shows what would be deployed in dry run mode
            # Impact: User sees what would happen without actual deployment
            
            kubectl apply --dry-run=client -f "$manifest" -n "$NAMESPACE"
            # Purpose: Validate manifest syntax without applying changes
            # Why needed: Ensures manifest is valid before actual deployment
            # Impact: Validates YAML syntax and Kubernetes resource definitions
            # --dry-run=client: Validates locally without contacting server
        else
            # Purpose: Execute actual deployment (not dry run)
            # Why needed: Performs the actual deployment of the manifest
            # Impact: Manifest is applied to the Kubernetes cluster
            
            if kubectl apply -f "$manifest" -n "$NAMESPACE"; then
                # Purpose: Apply the manifest to the Kubernetes cluster
                # Why needed: Deploys the Kubernetes resources defined in the manifest
                # Impact: Resources are created or updated in the cluster
                # -f: Specifies the manifest file to apply
                # -n: Specifies the target namespace
                
                print_status "SUCCESS" "Deployed $(basename "$manifest")"
                # Purpose: Log success message for manifest deployment
                # Why needed: Confirms successful deployment of the manifest
                # Impact: User knows the manifest was deployed successfully
            else
                # Purpose: Handle deployment failure
                # Why needed: Provides error handling for failed deployments
                # Impact: If deployment fails, function exits with error
                
                print_status "ERROR" "Failed to deploy $(basename "$manifest")"
                # Purpose: Log error message for failed deployment
                # Why needed: Informs user about deployment failure
                # Impact: User knows which manifest failed to deploy
                
                return 1
                # Purpose: Exit function with error code 1
                # Why needed: Indicates deployment failure
                # Impact: Function terminates immediately with error status
            fi
        fi
    done
    
    print_status "SUCCESS" "$description deployment completed"
    # Purpose: Log final success message for all manifest deployments
    # Why needed: Confirms completion of the entire deployment process
    # Impact: User knows all manifests in the directory were deployed successfully
}

# Function: Wait for deployment to be ready
wait_for_deployment() {
    # =============================================================================
    # WAIT FOR DEPLOYMENT FUNCTION
    # =============================================================================
    # Waits for a Kubernetes deployment to become available with timeout
    # handling and comprehensive status reporting.
    # =============================================================================
    
    local deployment_name=$1
    # Purpose: Specifies the name of the deployment to wait for
    # Why needed: Identifies which deployment to monitor for readiness
    # Impact: Function waits for this specific deployment to become available
    # Parameter: $1 is the deployment name (e.g., "ecommerce-backend-deployment")
    
    local timeout=${2:-300}
    # Purpose: Specifies the maximum time to wait for deployment readiness
    # Why needed: Prevents infinite waiting if deployment fails to become ready
    # Impact: Function will timeout after specified seconds if deployment not ready
    # Parameter: $2 is timeout in seconds, defaults to 300 (5 minutes)
    
    print_status "INFO" "Waiting for deployment $deployment_name to be ready (timeout: ${timeout}s)"
    # Purpose: Log the start of deployment waiting process
    # Why needed: Provides user feedback about waiting status
    # Impact: User sees that the script is waiting for deployment readiness
    
    # =============================================================================
    # DRY RUN HANDLING
    # =============================================================================
    # Purpose: Handle dry run mode for deployment waiting
    # Why needed: Dry run mode should not actually wait for deployments
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual waiting
        # Impact: If dry run, skip actual waiting and return success
        
        print_status "INFO" "DRY RUN: Would wait for deployment $deployment_name"
        # Purpose: Log dry run message for deployment waiting
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual waiting
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without waiting
    fi
    
    # =============================================================================
    # DEPLOYMENT READINESS WAIT
    # =============================================================================
    # Purpose: Wait for deployment to become available with timeout
    # Why needed: Ensures deployment is fully ready before proceeding
    
    if kubectl wait --for=condition=available --timeout="${timeout}s" deployment/"$deployment_name" -n "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Wait for deployment to become available using kubectl wait
        # Why needed: Ensures deployment is fully ready and available
        # Impact: Function waits until deployment is available or timeout occurs
        # --for=condition=available: Waits for deployment to be available
        # --timeout: Specifies maximum wait time
        # >/dev/null 2>&1: Suppresses output, only checks exit code
        
        print_status "SUCCESS" "Deployment $deployment_name is ready"
        # Purpose: Log success message for deployment readiness
        # Why needed: Confirms deployment is ready and available
        # Impact: User knows deployment is ready for use
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful deployment readiness
        # Impact: Function completes successfully with deployment ready
    else
        # Purpose: Handle deployment readiness timeout or failure
        # Why needed: Provides error handling for failed readiness
        # Impact: If deployment doesn't become ready, function fails
        
        print_status "ERROR" "Deployment $deployment_name failed to become ready within ${timeout}s"
        # Purpose: Log error message for deployment readiness failure
        # Why needed: Informs user about deployment readiness failure
        # Impact: User knows deployment failed to become ready within timeout
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates deployment readiness failure
        # Impact: Function terminates with error status
    fi
}

# Function: Wait for pods to be ready
wait_for_pods() {
    # =============================================================================
    # WAIT FOR PODS FUNCTION
    # =============================================================================
    # Waits for pods matching a selector to become ready with timeout
    # handling and comprehensive status reporting.
    # =============================================================================
    
    local selector=$1
    # Purpose: Specifies the label selector to match pods
    # Why needed: Identifies which pods to wait for readiness
    # Impact: Function waits for all pods matching this selector
    # Parameter: $1 is the label selector (e.g., "app=ecommerce,component=backend")
    
    local timeout=${2:-300}
    # Purpose: Specifies the maximum time to wait for pod readiness
    # Why needed: Prevents infinite waiting if pods fail to become ready
    # Impact: Function will timeout after specified seconds if pods not ready
    # Parameter: $2 is timeout in seconds, defaults to 300 (5 minutes)
    
    print_status "INFO" "Waiting for pods with selector $selector to be ready (timeout: ${timeout}s)"
    # Purpose: Log the start of pod waiting process
    # Why needed: Provides user feedback about waiting status
    # Impact: User sees that the script is waiting for pod readiness
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual waiting
        # Impact: If dry run, skip actual waiting and return success
        
        print_status "INFO" "DRY RUN: Would wait for pods with selector $selector"
        # Purpose: Log dry run message for pod waiting
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual waiting
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without waiting
    fi
    
    if kubectl wait --for=condition=ready --timeout="${timeout}s" pod -l "$selector" -n "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Wait for pods to become ready using kubectl wait
        # Why needed: Ensures all matching pods are ready and available
        # Impact: Function waits until all pods are ready or timeout occurs
        # --for=condition=ready: Waits for pods to be ready
        # -l: Specifies label selector for pod matching
        # >/dev/null 2>&1: Suppresses output, only checks exit code
        
        print_status "SUCCESS" "Pods with selector $selector are ready"
        # Purpose: Log success message for pod readiness
        # Why needed: Confirms all matching pods are ready
        # Impact: User knows all pods are ready for use
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful pod readiness
        # Impact: Function completes successfully with pods ready
    else
        # Purpose: Handle pod readiness timeout or failure
        # Why needed: Provides error handling for failed readiness
        # Impact: If pods don't become ready, function fails
        
        print_status "ERROR" "Pods with selector $selector failed to become ready within ${timeout}s"
        # Purpose: Log error message for pod readiness failure
        # Why needed: Informs user about pod readiness failure
        # Impact: User knows pods failed to become ready within timeout
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates pod readiness failure
        # Impact: Function terminates with error status
    fi
}

# Function: Validate deployment
validate_deployment() {
    # =============================================================================
    # VALIDATE DEPLOYMENT FUNCTION
    # =============================================================================
    # Validates the deployment by running comprehensive validation scripts
    # to ensure all components are working correctly.
    # =============================================================================
    
    print_status "INFO" "Validating deployment"
    # Purpose: Log the start of deployment validation process
    # Why needed: Provides user feedback about validation progress
    # Impact: User sees that deployment validation has begun
    
    # =============================================================================
    # DRY RUN HANDLING
    # =============================================================================
    # Purpose: Handle dry run mode for deployment validation
    # Why needed: Dry run mode should not perform actual validation
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual validation
        # Impact: If dry run, skip actual validation and return success
        
        print_status "INFO" "DRY RUN: Would validate deployment"
        # Purpose: Log dry run message for deployment validation
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual validation
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without validation
    fi
    
    # =============================================================================
    # VALIDATION SCRIPT EXECUTION
    # =============================================================================
    # Purpose: Run validation script to verify deployment correctness
    # Why needed: Ensures all deployed components are working properly
    
    if [ -f "validation/validate-monitoring-stack.sh" ]; then
        # Purpose: Check if validation script exists
        # Why needed: Validates script availability before execution
        # Impact: If script exists, run validation; if not, skip with warning
        
        if ./validation/validate-monitoring-stack.sh "$NAMESPACE"; then
            # Purpose: Execute validation script with namespace parameter
            # Why needed: Runs comprehensive validation of all deployed components
            # Impact: Validates pods, services, deployments, and monitoring stack
            # ./validation/validate-monitoring-stack.sh: Executes validation script
            # "$NAMESPACE": Passes namespace as parameter to validation script
            
            print_status "SUCCESS" "Deployment validation passed"
            # Purpose: Log success message for validation
            # Why needed: Confirms all validation checks passed
            # Impact: User knows deployment is working correctly
            
            return 0
            # Purpose: Exit function with success code 0
            # Why needed: Indicates successful validation
            # Impact: Function completes successfully with validation passed
        else
            # Purpose: Handle validation failure
            # Why needed: Provides error handling for failed validation
            # Impact: If validation fails, function fails
            
            print_status "ERROR" "Deployment validation failed"
            # Purpose: Log error message for validation failure
            # Why needed: Informs user about validation failure
            # Impact: User knows deployment has issues that need attention
            
            return 1
            # Purpose: Exit function with error code 1
            # Why needed: Indicates validation failure
            # Impact: Function terminates with error status
        fi
    else
        # Purpose: Handle missing validation script
        # Why needed: Provides graceful handling when validation script is missing
        # Impact: If script missing, skip validation with warning
        
        print_status "WARNING" "Validation script not found, skipping validation"
        # Purpose: Log warning message about missing validation script
        # Why needed: Informs user that validation was skipped
        # Impact: User knows validation was not performed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Missing script is not a critical error
        # Impact: Function completes successfully without validation
    fi
}

# Function: Monitor deployment
monitor_deployment() {
    # =============================================================================
    # MONITOR DEPLOYMENT FUNCTION
    # =============================================================================
    # Monitors deployment status continuously for a specified duration with
    # comprehensive status reporting and resource monitoring.
    # =============================================================================
    
    print_status "INFO" "Starting deployment monitoring"
    # Purpose: Log the start of deployment monitoring process
    # Why needed: Provides user feedback about monitoring initiation
    # Impact: User sees that deployment monitoring has begun
    
    # =============================================================================
    # DRY RUN HANDLING
    # =============================================================================
    # Purpose: Handle dry run mode for deployment monitoring
    # Why needed: Dry run mode should not perform actual monitoring
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual monitoring
        # Impact: If dry run, skip actual monitoring and return success
        
        print_status "INFO" "DRY RUN: Would monitor deployment"
        # Purpose: Log dry run message for deployment monitoring
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual monitoring
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without monitoring
    fi
    
    # =============================================================================
    # MONITORING DURATION SETUP
    # =============================================================================
    # Purpose: Set up monitoring duration and timing
    # Why needed: Defines how long to monitor the deployment
    
    local end_time
    # Purpose: Variable to store the end time for monitoring
    # Why needed: Provides time boundary for monitoring loop
    # Impact: Used to determine when to stop monitoring
    
    end_time=$(date -d '+5 minutes' +%s)
    # Purpose: Calculate end time as 5 minutes from now
    # Why needed: Sets monitoring duration to 5 minutes
    # Impact: Monitoring will run for exactly 5 minutes
    # date -d '+5 minutes': Adds 5 minutes to current time
    # +%s: Converts to Unix timestamp for comparison
    
    # =============================================================================
    # MONITORING LOOP
    # =============================================================================
    # Purpose: Continuously monitor deployment status
    # Why needed: Provides real-time visibility into deployment health
    
    while [ $(date +%s) -lt $end_time ]; do
        # Purpose: Continue monitoring while current time is less than end time
        # Why needed: Creates a time-bounded monitoring loop
        # Impact: Loop runs for exactly 5 minutes
        # $(date +%s): Gets current Unix timestamp
        
        print_status "INFO" "Checking deployment status..."
        # Purpose: Log status check iteration
        # Why needed: Provides progress feedback during monitoring
        # Impact: User sees that status checks are being performed
        
        # =============================================================================
        # POD STATUS CHECK
        # =============================================================================
        # Purpose: Display pod status with detailed information
        # Why needed: Shows pod health and resource allocation
        
        kubectl get pods -n "$NAMESPACE" -o wide
        # Purpose: Get pod status with wide output format
        # Why needed: Shows pod status, IP addresses, and node assignments
        # Impact: User can see pod health and distribution
        # -n: Specifies namespace
        # -o wide: Shows additional columns (IP, node, etc.)
        
        # =============================================================================
        # SERVICE STATUS CHECK
        # =============================================================================
        # Purpose: Display service status and endpoints
        # Why needed: Shows service connectivity and load balancing
        
        kubectl get services -n "$NAMESPACE"
        # Purpose: Get service status and configuration
        # Why needed: Shows service IPs, ports, and selectors
        # Impact: User can see service connectivity status
        # -n: Specifies namespace
        
        # =============================================================================
        # DEPLOYMENT STATUS CHECK
        # =============================================================================
        # Purpose: Display deployment status and replica information
        # Why needed: Shows deployment health and scaling status
        
        kubectl get deployments -n "$NAMESPACE"
        # Purpose: Get deployment status and replica counts
        # Why needed: Shows deployment readiness and scaling
        # Impact: User can see deployment health and replica status
        # -n: Specifies namespace
        
        sleep 30
        # Purpose: Wait 30 seconds before next status check
        # Why needed: Prevents excessive resource usage and provides readable output
        # Impact: Status checks occur every 30 seconds
    done
    
    print_status "SUCCESS" "Deployment monitoring completed"
    # Purpose: Log completion of monitoring process
    # Why needed: Confirms monitoring has finished successfully
    # Impact: User knows monitoring period has ended
}

# Function: Rollback deployment
rollback_deployment() {
    # =============================================================================
    # ROLLBACK DEPLOYMENT FUNCTION
    # =============================================================================
    # Rolls back all deployments to their previous versions with comprehensive
    # error handling and status reporting.
    # =============================================================================
    
    print_status "INFO" "Rolling back deployment"
    # Purpose: Log the start of rollback process
    # Why needed: Provides user feedback about rollback initiation
    # Impact: User sees that deployment rollback has begun
    
    # =============================================================================
    # DRY RUN HANDLING
    # =============================================================================
    # Purpose: Handle dry run mode for deployment rollback
    # Why needed: Dry run mode should not perform actual rollback
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual rollback
        # Impact: If dry run, skip actual rollback and return success
        
        print_status "INFO" "DRY RUN: Would rollback deployment"
        # Purpose: Log dry run message for deployment rollback
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual rollback
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without rollback
    fi
    
    # =============================================================================
    # PREVIOUS DEPLOYMENT IDENTIFICATION
    # =============================================================================
    # Purpose: Identify the previous deployment version for rollback
    # Why needed: Determines which version to rollback to
    
    local previous_deployment
    # Purpose: Variable to store the previous deployment revision
    # Why needed: Identifies the target revision for rollback
    # Impact: Used to specify which version to rollback to
    
    previous_deployment=$(kubectl rollout history deployment -n "$NAMESPACE" --no-headers | tail -2 | head -1 | awk '{print $1}')
    # Purpose: Get the second-to-last deployment revision from history
    # Why needed: Identifies the previous stable version for rollback
    # Impact: Extracts the revision number of the previous deployment
    # kubectl rollout history: Shows deployment revision history
    # --no-headers: Removes header row from output
    # tail -2 | head -1: Gets the second-to-last line (previous revision)
    # awk '{print $1}': Extracts the first column (revision number)
    
    if [ -z "$previous_deployment" ]; then
        # Purpose: Check if previous deployment revision was found
        # Why needed: Validates that rollback target exists
        # Impact: If no previous deployment found, rollback cannot proceed
        
        print_status "ERROR" "No previous deployment found for rollback"
        # Purpose: Log error message about missing previous deployment
        # Why needed: Informs user that rollback is not possible
        # Impact: User knows there's no previous version to rollback to
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates rollback failure due to missing history
        # Impact: Function terminates with error status
    fi
    
    print_status "INFO" "Rolling back to $previous_deployment"
    # Purpose: Log the target revision for rollback
    # Why needed: Confirms which revision will be used for rollback
    # Impact: User knows which version the rollback will target
    
    # =============================================================================
    # DEPLOYMENT ROLLBACK EXECUTION
    # =============================================================================
    # Purpose: Execute rollback for all deployments in the namespace
    # Why needed: Ensures all components are rolled back consistently
    
    local deployments
    # Purpose: Variable to store list of all deployments
    # Why needed: Provides list of deployments to rollback
    # Impact: Used in loop to rollback each deployment
    
    deployments=$(kubectl get deployments -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')
    # Purpose: Get all deployment names in the namespace
    # Why needed: Identifies all deployments that need rollback
    # Impact: Creates list of all deployments to process
    # kubectl get deployments: Lists all deployments
    # -o jsonpath: Uses JSON path to extract specific fields
    # '{.items[*].metadata.name}': Extracts name field from each deployment
    
    for deployment in $deployments; do
        # Purpose: Iterate through each deployment for rollback
        # Why needed: Processes all deployments one by one
        # Impact: Each deployment is rolled back individually
        
        if kubectl rollout undo deployment/"$deployment" -n "$NAMESPACE"; then
            # Purpose: Execute rollback for the specific deployment
            # Why needed: Reverts deployment to previous version
            # Impact: Deployment is rolled back to previous revision
            # kubectl rollout undo: Initiates rollback process
            # deployment/"$deployment": Specifies the deployment to rollback
            # -n: Specifies the namespace
            
            print_status "SUCCESS" "Rolled back deployment $deployment"
            # Purpose: Log success message for deployment rollback
            # Why needed: Confirms successful rollback of the deployment
            # Impact: User knows the deployment was rolled back successfully
        else
            # Purpose: Handle rollback failure for specific deployment
            # Why needed: Provides error handling for failed rollbacks
            # Impact: If rollback fails, log error but continue with others
            
            print_status "ERROR" "Failed to rollback deployment $deployment"
            # Purpose: Log error message for failed rollback
            # Why needed: Informs user about rollback failure
            # Impact: User knows which deployment failed to rollback
        fi
    done
    
    print_status "SUCCESS" "Rollback completed"
    # Purpose: Log final success message for rollback process
    # Why needed: Confirms completion of rollback operations
    # Impact: User knows rollback process has finished
}

# Function: Cleanup resources
cleanup_resources() {
    # =============================================================================
    # CLEANUP RESOURCES FUNCTION
    # =============================================================================
    # Cleans up temporary and completed resources to maintain cluster
    # cleanliness and free up resources.
    # =============================================================================
    
    print_status "INFO" "Cleaning up resources"
    # Purpose: Log the start of resource cleanup process
    # Why needed: Provides user feedback about cleanup initiation
    # Impact: User sees that resource cleanup has begun
    
    # =============================================================================
    # DRY RUN HANDLING
    # =============================================================================
    # Purpose: Handle dry run mode for resource cleanup
    # Why needed: Dry run mode should not perform actual cleanup
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if this is a dry run operation
        # Why needed: Dry run mode should not perform actual cleanup
        # Impact: If dry run, skip actual cleanup and return success
        
        print_status "INFO" "DRY RUN: Would cleanup resources"
        # Purpose: Log dry run message for resource cleanup
        # Why needed: Shows what would be done in dry run mode
        # Impact: User sees what would happen without actual cleanup
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Dry run mode should not fail
        # Impact: Function completes successfully without cleanup
    fi
    
    # =============================================================================
    # TEMPORARY RESOURCE CLEANUP
    # =============================================================================
    # Purpose: Remove completed and failed pods to free up resources
    # Why needed: Prevents resource accumulation and maintains cluster health
    
    kubectl delete pod --field-selector=status.phase=Succeeded -n "$NAMESPACE" >/dev/null 2>&1 || true
    # Purpose: Delete pods that have completed successfully
    # Why needed: Removes completed pods to free up resources
    # Impact: Cleans up successful pods that are no longer needed
    # --field-selector=status.phase=Succeeded: Selects only succeeded pods
    # >/dev/null 2>&1: Suppresses output and errors
    # || true: Ensures command doesn't fail if no pods found
    
    kubectl delete pod --field-selector=status.phase=Failed -n "$NAMESPACE" >/dev/null 2>&1 || true
    # Purpose: Delete pods that have failed
    # Why needed: Removes failed pods to free up resources and clean logs
    # Impact: Cleans up failed pods that are no longer needed
    # --field-selector=status.phase=Failed: Selects only failed pods
    # >/dev/null 2>&1: Suppresses output and errors
    # || true: Ensures command doesn't fail if no pods found
    
    print_status "SUCCESS" "Resource cleanup completed"
    # Purpose: Log completion of resource cleanup process
    # Why needed: Confirms cleanup has finished successfully
    # Impact: User knows resource cleanup has completed
}

# =============================================================================
# MAIN DEPLOYMENT FUNCTIONS
# =============================================================================

# Function: Deploy core application
deploy_core_application() {
    # =============================================================================
    # DEPLOY CORE APPLICATION FUNCTION
    # =============================================================================
    # Deploys the core e-commerce application components including backend,
    # frontend, and database with comprehensive validation and monitoring.
    # =============================================================================
    
    print_status "HEADER" "Deploying core e-commerce application"
    # Purpose: Log the start of core application deployment
    # Why needed: Provides clear section header for core application deployment
    # Impact: User sees that core application deployment has begun
    
    # =============================================================================
    # CORE APPLICATION MANIFEST DEPLOYMENT
    # =============================================================================
    # Purpose: Deploy all core application Kubernetes manifests
    # Why needed: Creates the foundational infrastructure for the e-commerce app
    
    deploy_manifests "k8s-manifests" "Core application manifests"
    # Purpose: Deploy all manifests from the k8s-manifests directory
    # Why needed: Creates all core application resources (deployments, services, etc.)
    # Impact: All core application components are deployed to the cluster
    # "k8s-manifests": Directory containing core application manifests
    # "Core application manifests": Description for logging purposes
    
    # =============================================================================
    # CORE DEPLOYMENT READINESS WAIT
    # =============================================================================
    # Purpose: Wait for all core deployments to become ready
    # Why needed: Ensures all components are fully operational before proceeding
    
    wait_for_deployment "ecommerce-backend-deployment" 300
    # Purpose: Wait for backend deployment to become ready
    # Why needed: Ensures backend API is available for frontend and external access
    # Impact: Backend service is ready to handle requests
    # "ecommerce-backend-deployment": Name of the backend deployment
    # 300: Timeout in seconds (5 minutes)
    
    wait_for_deployment "ecommerce-frontend-deployment" 300
    # Purpose: Wait for frontend deployment to become ready
    # Why needed: Ensures frontend UI is available for user access
    # Impact: Frontend service is ready to serve web pages
    # "ecommerce-frontend-deployment": Name of the frontend deployment
    # 300: Timeout in seconds (5 minutes)
    
    wait_for_deployment "ecommerce-database-deployment" 300
    # Purpose: Wait for database deployment to become ready
    # Why needed: Ensures database is available for data storage and retrieval
    # Impact: Database service is ready to handle data operations
    # "ecommerce-database-deployment": Name of the database deployment
    # 300: Timeout in seconds (5 minutes)
    
    print_status "SUCCESS" "Core application deployment completed"
    # Purpose: Log completion of core application deployment
    # Why needed: Confirms all core components are deployed and ready
    # Impact: User knows core application deployment has finished successfully
}

# Function: Deploy monitoring stack
deploy_monitoring_stack() {
    # =============================================================================
    # DEPLOY MONITORING STACK FUNCTION
    # =============================================================================
    # Deploys the complete monitoring stack including Prometheus, Grafana,
    # and AlertManager with comprehensive validation and readiness checks.
    # =============================================================================
    
    print_status "HEADER" "Deploying monitoring stack"
    # Purpose: Log the start of monitoring stack deployment
    # Why needed: Provides clear section header for monitoring deployment
    # Impact: User sees that monitoring stack deployment has begun
    
    # =============================================================================
    # MONITORING STACK MANIFEST DEPLOYMENT
    # =============================================================================
    # Purpose: Deploy all monitoring stack Kubernetes manifests
    # Why needed: Creates the observability infrastructure for the e-commerce app
    
    deploy_manifests "monitoring" "Monitoring stack manifests"
    # Purpose: Deploy all manifests from the monitoring directory
    # Why needed: Creates all monitoring resources (Prometheus, Grafana, AlertManager)
    # Impact: All monitoring components are deployed to the cluster
    # "monitoring": Directory containing monitoring stack manifests
    # "Monitoring stack manifests": Description for logging purposes
    
    # =============================================================================
    # MONITORING DEPLOYMENT READINESS WAIT
    # =============================================================================
    # Purpose: Wait for all monitoring deployments to become ready
    # Why needed: Ensures all monitoring components are fully operational
    
    wait_for_deployment "prometheus-deployment" 300
    # Purpose: Wait for Prometheus deployment to become ready
    # Why needed: Ensures metrics collection system is available
    # Impact: Prometheus service is ready to collect and store metrics
    # "prometheus-deployment": Name of the Prometheus deployment
    # 300: Timeout in seconds (5 minutes)
    
    wait_for_deployment "grafana-deployment" 300
    # Purpose: Wait for Grafana deployment to become ready
    # Why needed: Ensures visualization dashboard is available
    # Impact: Grafana service is ready to display metrics and dashboards
    # "grafana-deployment": Name of the Grafana deployment
    # 300: Timeout in seconds (5 minutes)
    
    wait_for_deployment "alertmanager-deployment" 300
    # Purpose: Wait for AlertManager deployment to become ready
    # Why needed: Ensures alerting system is available for notifications
    # Impact: AlertManager service is ready to handle alert routing
    # "alertmanager-deployment": Name of the AlertManager deployment
    # 300: Timeout in seconds (5 minutes)
    
    print_status "SUCCESS" "Monitoring stack deployment completed"
    # Purpose: Log completion of monitoring stack deployment
    # Why needed: Confirms all monitoring components are deployed and ready
    # Impact: User knows monitoring stack deployment has finished successfully
}

# Function: Deploy all components
deploy_all() {
    # =============================================================================
    # DEPLOY ALL COMPONENTS FUNCTION
    # =============================================================================
    # Orchestrates the complete deployment of all e-commerce application
    # components with comprehensive validation, monitoring, and cleanup.
    # =============================================================================
    
    print_status "HEADER" "Starting complete deployment for environment: $ENVIRONMENT"
    # Purpose: Log the start of complete deployment process
    # Why needed: Provides clear section header for full deployment
    # Impact: User sees that complete deployment has begun
    # $ENVIRONMENT: Shows which environment is being deployed
    
    print_status "INFO" "Deployment ID: $DEPLOYMENT_ID"
    # Purpose: Log the unique deployment identifier
    # Why needed: Provides tracking information for this deployment
    # Impact: User can reference this ID for troubleshooting
    # $DEPLOYMENT_ID: Unique timestamp-based identifier
    
    print_status "INFO" "Namespace: $NAMESPACE"
    # Purpose: Log the target namespace for deployment
    # Why needed: Confirms where resources will be deployed
    # Impact: User knows which namespace will contain the resources
    # $NAMESPACE: Target Kubernetes namespace
    
    print_status "INFO" "Dry run: $DRY_RUN"
    # Purpose: Log whether this is a dry run deployment
    # Why needed: Confirms deployment mode for user awareness
    # Impact: User knows if this is a test run or actual deployment
    # $DRY_RUN: Boolean flag for dry run mode
    
    print_status "INFO" "Validate: $VALIDATE"
    # Purpose: Log whether validation will be performed
    # Why needed: Confirms validation mode for user awareness
    # Impact: User knows if validation checks will be run
    # $VALIDATE: Boolean flag for validation mode
    
    print_status "INFO" "Monitor: $MONITOR"
    # Purpose: Log whether monitoring will be performed
    # Why needed: Confirms monitoring mode for user awareness
    # Impact: User knows if monitoring will be active
    # $MONITOR: Boolean flag for monitoring mode
    
    # =============================================================================
    # PREREQUISITE VALIDATION
    # =============================================================================
    # Purpose: Validate all prerequisites before deployment
    # Why needed: Ensures all requirements are met before proceeding
    
    check_prerequisites
    # Purpose: Execute prerequisite validation
    # Why needed: Validates cluster connectivity, tools, and namespace
    # Impact: Ensures deployment can proceed successfully
    
    # =============================================================================
    # CORE APPLICATION DEPLOYMENT
    # =============================================================================
    # Purpose: Deploy the core e-commerce application components
    # Why needed: Creates the main application infrastructure
    
    deploy_core_application
    # Purpose: Deploy backend, frontend, and database components
    # Why needed: Creates the core e-commerce application infrastructure
    # Impact: Main application components are deployed and ready
    
    # =============================================================================
    # MONITORING STACK DEPLOYMENT
    # =============================================================================
    # Purpose: Deploy the monitoring and observability stack
    # Why needed: Provides monitoring capabilities for the application
    
    deploy_monitoring_stack
    # Purpose: Deploy Prometheus, Grafana, and AlertManager
    # Why needed: Creates observability infrastructure for monitoring
    # Impact: Monitoring stack is deployed and ready for metrics collection
    
    # =============================================================================
    # DEPLOYMENT VALIDATION
    # =============================================================================
    # Purpose: Validate deployment if requested
    # Why needed: Ensures all components are working correctly
    
    if [ "$VALIDATE" = true ]; then
        # Purpose: Check if validation is enabled
        # Why needed: Only run validation if explicitly requested
        # Impact: If validation enabled, run comprehensive checks
        
        validate_deployment
        # Purpose: Execute deployment validation
        # Why needed: Verifies all components are working correctly
        # Impact: Confirms deployment health and functionality
    fi
    
    # =============================================================================
    # DEPLOYMENT MONITORING
    # =============================================================================
    # Purpose: Monitor deployment if requested
    # Why needed: Provides real-time visibility into deployment status
    
    if [ "$MONITOR" = true ]; then
        # Purpose: Check if monitoring is enabled
        # Why needed: Only run monitoring if explicitly requested
        # Impact: If monitoring enabled, provide real-time status updates
        
        monitor_deployment
        # Purpose: Execute deployment monitoring
        # Why needed: Provides real-time visibility into deployment health
        # Impact: User can see deployment status and resource utilization
    fi
    
    # =============================================================================
    # RESOURCE CLEANUP
    # =============================================================================
    # Purpose: Clean up temporary resources
    # Why needed: Maintains cluster cleanliness and frees up resources
    
    cleanup_resources
    # Purpose: Execute resource cleanup
    # Why needed: Removes completed and failed pods
    # Impact: Cluster is cleaned up and resources are freed
    
    # =============================================================================
    # DEPLOYMENT COMPLETION
    # =============================================================================
    # Purpose: Mark deployment as successful and log completion
    # Why needed: Confirms successful deployment completion
    
    DEPLOYMENT_STATUS="SUCCESS"
    # Purpose: Update deployment status to success
    # Why needed: Tracks deployment completion status
    # Impact: Deployment is marked as successfully completed
    
    print_status "SUCCESS" "Deployment completed successfully"
    # Purpose: Log final success message
    # Why needed: Confirms deployment has finished successfully
    # Impact: User knows deployment completed without errors
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Handle rollback
if [ "$ROLLBACK" = true ]; then
    rollback_deployment
    exit $?
fi

# Handle force deployment
if [ "$FORCE" = true ]; then
    print_status "WARNING" "Force deployment enabled - skipping some checks"
fi

# Start deployment
deploy_all

# Final status
if [ "$DEPLOYMENT_STATUS" = "SUCCESS" ]; then
    print_status "SUCCESS" "Deployment completed successfully"
    print_status "INFO" "Deployment log: $DEPLOYMENT_LOG"
    exit 0
else
    print_status "ERROR" "Deployment failed"
    print_status "INFO" "Deployment log: $DEPLOYMENT_LOG"
    exit 1
fi
