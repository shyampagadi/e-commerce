#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION OPERATIONS SCRIPT
# =============================================================================
# This script provides comprehensive operations management for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# scaling, restarting, log management, and maintenance operations.
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
# OPERATIONS CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent operations configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for operations
# Why needed: Provides consistent namespace reference for all operations
# Impact: All operations target resources in this namespace
# Value: Defaults to 'ecommerce', can be overridden via --namespace argument

COMPONENT=""
# Purpose: Specifies the target component for component-specific operations
# Why needed: Allows operations on specific application components
# Impact: When set, operations are limited to the specified component
# Value: Can be 'backend', 'frontend', 'database', 'monitoring', or empty for all

ACTION=""
# Purpose: Specifies the operation to perform
# Why needed: Determines which operation function to execute
# Impact: Controls the type of operation performed
# Value: Actions like 'status', 'restart', 'scale', 'logs', 'backup', 'restore'

VERBOSE=false
# Purpose: Enables verbose output mode for detailed operation information
# Why needed: Provides detailed information for troubleshooting and monitoring
# Impact: When true, shows detailed operation progress and results
# Usage: Set via --verbose command line argument

DRY_RUN=false
# Purpose: Enables dry-run mode for operation validation without actual changes
# Why needed: Allows testing operations without affecting the cluster
# Impact: When true, shows what would be done without making changes
# Usage: Set via --dry-run command line argument

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --namespace=*)
            NAMESPACE="${1#*=}"
            shift
            ;;
        --component=*)
            COMPONENT="${1#*=}"
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [ -z "$ACTION" ]; then
                ACTION="$1"
            fi
            shift
            ;;
    esac
done

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp for all operations
    # with visual distinction and consistent formatting.
    # =============================================================================
    
    local status=$1
    # Purpose: Specifies the status level for message formatting
    # Why needed: Determines the color and prefix for the message display
    # Impact: Controls visual appearance and categorization of the message
    # Parameter: $1 is the status level (INFO, SUCCESS, WARNING, ERROR, HEADER)
    
    local message=$2
    # Purpose: Specifies the message content to display
    # Why needed: Provides the actual information to be communicated
    # Impact: Message content is displayed to user
    # Parameter: $2 is the message text string
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp for message identification
    # Why needed: Provides temporal context for operations
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
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Validates if a required command is available in the system PATH for
    # dependency checking and prerequisite validation during operations.
    # =============================================================================
    
    # Purpose: Validates if a required command is available in the system PATH
    # Why needed: Ensures all required tools are available before operations
    # Impact: Prevents operation failures due to missing dependencies
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

# Function: Check prerequisites
check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates all prerequisites for successful operations including tool
    # availability, cluster connectivity, and namespace existence.
    # =============================================================================
    
    # =============================================================================
    # KUBECTL COMMAND AVAILABILITY CHECK
    # =============================================================================
    # Purpose: Verify kubectl command is available in system PATH
    # Why needed: kubectl is required for all Kubernetes operations
    
    if ! command_exists kubectl; then
        # Purpose: Check if kubectl command exists using command_exists function
        # Why needed: Validates kubectl availability before attempting to use it
        # Impact: If kubectl not found, operations cannot proceed
        
        print_status "ERROR" "kubectl command not found"
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
    # Why needed: Ensures cluster is accessible before operations
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # Purpose: Test cluster connectivity using kubectl cluster-info
        # Why needed: Validates cluster accessibility and kubeconfig validity
        # Impact: If cluster unreachable, operations cannot proceed
        # Redirect: >/dev/null 2>&1 suppresses output, only checks exit code
        
        print_status "ERROR" "Cannot connect to Kubernetes cluster"
        # Purpose: Log error message about cluster connectivity
        # Why needed: Provides clear error message about connection issue
        # Impact: User knows to check their kubeconfig configuration
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Prevents further execution without cluster access
        # Impact: Script terminates immediately with error status
    fi
    
    # =============================================================================
    # NAMESPACE EXISTENCE CHECK
    # =============================================================================
    # Purpose: Verify target namespace exists
    # Why needed: Namespace is required for resource operations
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if target namespace exists
        # Why needed: Validates namespace availability before operations
        # Impact: If namespace doesn't exist, operations cannot proceed
        # Redirect: >/dev/null 2>&1 suppresses output, only checks exit code
        
        print_status "ERROR" "Namespace $NAMESPACE does not exist"
        # Purpose: Log error message about missing namespace
        # Why needed: Informs user that namespace is required
        # Impact: User knows they need to create the namespace first
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Indicates namespace requirement failure
        # Impact: Script terminates immediately with error status
    fi
}

# Function: Get pod status
get_pod_status() {
    # =============================================================================
    # GET POD STATUS FUNCTION
    # =============================================================================
    # Retrieves and displays pod status information with component filtering
    # and comprehensive output formatting for operations monitoring.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component for pod filtering
    # Why needed: Allows filtering pods by specific component (backend, frontend, etc.)
    # Impact: When specified, only pods for that component are shown
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application pods
    # Why needed: Provides default selector to find all e-commerce pods
    # Impact: All pods with app=ecommerce label will be included
    # Value: "app=ecommerce" matches the application label
    
    # =============================================================================
    # COMPONENT-SPECIFIC SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector if component is specified
    # Why needed: Allows filtering to specific component pods
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters pods to only those matching the specified component
        # Impact: Only pods with both app=ecommerce and component=<component> labels are shown
        # Format: "app=ecommerce,component=backend" for backend pods
    fi
    
    # =============================================================================
    # POD STATUS RETRIEVAL
    # =============================================================================
    # Purpose: Execute kubectl command to get pod status
    # Why needed: Retrieves current pod status and information
    
    kubectl get pods -n "$NAMESPACE" -l "$selector" -o wide
    # Purpose: Get pod status with wide output format
    # Why needed: Shows comprehensive pod information including IP and node
    # Impact: Displays pod status, IP addresses, node assignments, and readiness
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter pods
    # -o wide: Shows additional columns (IP, node, etc.)
}

# Function: Get service status
get_service_status() {
    # =============================================================================
    # GET SERVICE STATUS FUNCTION
    # =============================================================================
    # Retrieves and displays service status information with component filtering
    # and comprehensive output formatting for service discovery monitoring.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component for service filtering
    # Why needed: Allows filtering services by specific component (backend, frontend, etc.)
    # Impact: When specified, only services for that component are shown
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application services
    # Why needed: Provides default selector to find all e-commerce services
    # Impact: All services with app=ecommerce label will be included
    # Value: "app=ecommerce" matches the application label
    
    # =============================================================================
    # COMPONENT-SPECIFIC SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector if component is specified
    # Why needed: Allows filtering to specific component services
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters services to only those matching the specified component
        # Impact: Only services with both app=ecommerce and component=<component> labels are shown
        # Format: "app=ecommerce,component=backend" for backend services
    fi
    
    # =============================================================================
    # SERVICE STATUS RETRIEVAL
    # =============================================================================
    # Purpose: Execute kubectl command to get service status
    # Why needed: Retrieves current service status and information
    
    kubectl get services -n "$NAMESPACE" -l "$selector" -o wide
    # Purpose: Get service status with wide output format
    # Why needed: Shows comprehensive service information including endpoints and ports
    # Impact: Displays service status, cluster IPs, external IPs, ports, and selectors
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter services
    # -o wide: Shows additional columns (external IP, ports, etc.)
}

# Function: Get deployment status
get_deployment_status() {
    # =============================================================================
    # GET DEPLOYMENT STATUS FUNCTION
    # =============================================================================
    # Retrieves and displays deployment status information with component filtering
    # and comprehensive output formatting for deployment lifecycle monitoring.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component for deployment filtering
    # Why needed: Allows filtering deployments by specific component (backend, frontend, etc.)
    # Impact: When specified, only deployments for that component are shown
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application deployments
    # Why needed: Provides default selector to find all e-commerce deployments
    # Impact: All deployments with app=ecommerce label will be included
    # Value: "app=ecommerce" matches the application label
    
    # =============================================================================
    # COMPONENT-SPECIFIC SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector if component is specified
    # Why needed: Allows filtering to specific component deployments
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters deployments to only those matching the specified component
        # Impact: Only deployments with both app=ecommerce and component=<component> labels are shown
        # Format: "app=ecommerce,component=backend" for backend deployments
    fi
    
    # =============================================================================
    # DEPLOYMENT STATUS RETRIEVAL
    # =============================================================================
    # Purpose: Execute kubectl command to get deployment status
    # Why needed: Retrieves current deployment status and information
    
    kubectl get deployments -n "$NAMESPACE" -l "$selector" -o wide
    # Purpose: Get deployment status with wide output format
    # Why needed: Shows comprehensive deployment information including replicas and age
    # Impact: Displays deployment status, desired/ready/available replicas, and age
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter deployments
    # -o wide: Shows additional columns (age, etc.)
}

# Function: Get resource usage
get_resource_usage() {
    # =============================================================================
    # GET RESOURCE USAGE FUNCTION
    # =============================================================================
    # Retrieves and displays real-time resource usage metrics for pods with
    # component filtering and comprehensive resource monitoring capabilities.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component for resource usage filtering
    # Why needed: Allows filtering resource usage by specific component
    # Impact: When specified, only pods for that component are monitored
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # COMPONENT-SPECIFIC RESOURCE MONITORING
    # =============================================================================
    # Purpose: Monitor resource usage for specific component or all components
    # Why needed: Provides targeted resource monitoring based on component
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only filter by component if specified
        # Impact: If component provided, monitor only that component's pods
        
        kubectl top pods -n "$NAMESPACE" -l "app=ecommerce,component=$component" --no-headers
        # Purpose: Get resource usage for specific component pods
        # Why needed: Provides targeted resource monitoring for specific component
        # Impact: Shows CPU and memory usage for component-specific pods only
        # -n: Specifies the target namespace
        # -l: Uses label selector to filter pods by component
        # --no-headers: Removes column headers for cleaner output
    else
        # Purpose: Monitor all e-commerce application pods
        # Why needed: Provides comprehensive resource monitoring across all components
        # Impact: Shows resource usage for all application pods
        
        kubectl top pods -n "$NAMESPACE" -l "app=ecommerce" --no-headers
        # Purpose: Get resource usage for all e-commerce pods
        # Why needed: Provides complete resource overview across all components
        # Impact: Shows CPU and memory usage for all application pods
        # -n: Specifies the target namespace
        # -l: Uses label selector to filter pods by application
        # --no-headers: Removes column headers for cleaner output
    fi
}

# Function: Get logs
get_logs() {
    # =============================================================================
    # GET LOGS FUNCTION
    # =============================================================================
    # Retrieves and displays application logs from pods with component filtering
    # and configurable log line limits for comprehensive log analysis.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component for log retrieval
    # Why needed: Allows filtering logs by specific component (backend, frontend, etc.)
    # Impact: When specified, only logs from that component's pods are retrieved
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local lines=${2:-100}
    # Purpose: Specifies the number of log lines to retrieve
    # Why needed: Controls log output volume and performance
    # Impact: Limits log output to prevent overwhelming display
    # Default: 100 lines if not specified
    # Parameter: $2 is the number of lines to retrieve (default: 100)
    
    # =============================================================================
    # POD DISCOVERY FOR LOG RETRIEVAL
    # =============================================================================
    # Purpose: Find all pods for the specified component
    # Why needed: Identifies which pods to retrieve logs from
    
    local pods
    # Purpose: Variable to store list of pod names
    # Why needed: Provides list of pods to iterate through for log retrieval
    # Impact: Used to determine which pods to get logs from
    
    pods=$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce,component=$component" -o jsonpath='{.items[*].metadata.name}')
    # Purpose: Retrieve pod names for the specified component
    # Why needed: Identifies all pods belonging to the target component
    # Impact: Provides list of pod names for log retrieval
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter pods by component
    # -o jsonpath: Extracts only the pod names from JSON output
    # .items[*].metadata.name: JSONPath to extract pod names
    
    # =============================================================================
    # POD EXISTENCE VALIDATION
    # =============================================================================
    # Purpose: Verify pods exist before attempting log retrieval
    # Why needed: Prevents errors when no pods are found
    
    if [ -z "$pods" ]; then
        # Purpose: Check if any pods were found
        # Why needed: Validates pod existence before log retrieval
        # Impact: If no pods found, log retrieval cannot proceed
        
        print_status "ERROR" "No pods found for component $component"
        # Purpose: Log error message about missing pods
        # Why needed: Informs user that no pods exist for the component
        # Impact: User knows the component has no running pods
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates log retrieval failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # LOG RETRIEVAL AND DISPLAY
    # =============================================================================
    # Purpose: Retrieve and display logs from all component pods
    # Why needed: Provides comprehensive log information for troubleshooting
    
    for pod in $pods; do
        # Purpose: Iterate through each pod found for the component
        # Why needed: Retrieves logs from all pods belonging to the component
        # Impact: Processes each pod individually for log retrieval
        
        print_status "INFO" "Logs for pod $pod:"
        # Purpose: Log informational message about current pod
        # Why needed: Provides context about which pod's logs are being shown
        # Impact: User knows which pod the following logs belong to
        
        kubectl logs -n "$NAMESPACE" "$pod" --tail="$lines"
        # Purpose: Retrieve logs from the current pod
        # Why needed: Provides log information for troubleshooting and monitoring
        # Impact: Displays the specified number of log lines from the pod
        # -n: Specifies the target namespace
        # --tail: Limits output to the specified number of lines
        
        echo "---"
        # Purpose: Add separator between different pod logs
        # Why needed: Provides visual separation between pod logs
        # Impact: Makes it clear where one pod's logs end and another's begin
    done
}

# Function: Restart deployment
restart_deployment() {
    # =============================================================================
    # RESTART DEPLOYMENT FUNCTION
    # =============================================================================
    # Restarts a specific deployment component with validation, dry-run support,
    # and comprehensive rollout monitoring for safe deployment restarts.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component to restart
    # Why needed: Identifies which deployment to restart (backend, frontend, etc.)
    # Impact: When specified, only that component's deployment is restarted
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # COMPONENT VALIDATION
    # =============================================================================
    # Purpose: Validate that component parameter is provided
    # Why needed: Prevents accidental restarts of all deployments
    
    if [ -z "$component" ]; then
        # Purpose: Check if component parameter is empty or not provided
        # Why needed: Validates that a specific component is targeted
        # Impact: If no component specified, restart operation cannot proceed
        
        print_status "ERROR" "Component must be specified for restart"
        # Purpose: Log error message about missing component
        # Why needed: Informs user that component parameter is required
        # Impact: User knows they need to specify a component
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates component validation failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # RESTART INITIATION
    # =============================================================================
    # Purpose: Log restart operation and check for dry-run mode
    # Why needed: Provides user feedback and supports dry-run testing
    
    print_status "INFO" "Restarting deployment for component $component"
    # Purpose: Log informational message about restart operation
    # Why needed: Informs user that restart is being initiated
    # Impact: User knows which component is being restarted
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing restart operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual restart when in dry-run mode
        # Impact: If dry-run enabled, only simulate the restart operation
        
        print_status "INFO" "DRY RUN: Would restart deployment $component-deployment"
        # Purpose: Log dry-run message about restart operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the restart would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual restart
    fi
    
    # =============================================================================
    # DEPLOYMENT RESTART EXECUTION
    # =============================================================================
    # Purpose: Execute the actual deployment restart
    # Why needed: Performs the restart operation on the specified deployment
    
    if kubectl rollout restart deployment/"$component-deployment" -n "$NAMESPACE"; then
        # Purpose: Execute kubectl rollout restart command
        # Why needed: Restarts the specified deployment to refresh pods
        # Impact: Triggers rolling restart of all pods in the deployment
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Deployment $component-deployment restarted"
        # Purpose: Log success message about restart completion
        # Why needed: Confirms that restart was initiated successfully
        # Impact: User knows the restart operation completed
        
        # =============================================================================
        # ROLLOUT COMPLETION MONITORING
        # =============================================================================
        # Purpose: Wait for rollout to complete and monitor progress
        # Why needed: Ensures restart completes successfully before continuing
        
        print_status "INFO" "Waiting for rollout to complete..."
        # Purpose: Log informational message about rollout monitoring
        # Why needed: Informs user that rollout completion is being monitored
        # Impact: User knows the system is waiting for restart to complete
        
        kubectl rollout status deployment/"$component-deployment" -n "$NAMESPACE"
        # Purpose: Monitor rollout status until completion
        # Why needed: Ensures all pods are successfully restarted and ready
        # Impact: Blocks until rollout is complete or fails
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Rollout completed for $component-deployment"
        # Purpose: Log success message about rollout completion
        # Why needed: Confirms that restart completed successfully
        # Impact: User knows the restart operation finished successfully
    else
        # Purpose: Handle restart command failure
        # Why needed: Provides error handling for failed restart operations
        # Impact: If restart fails, error is logged and function exits with error
        
        print_status "ERROR" "Failed to restart deployment $component-deployment"
        # Purpose: Log error message about restart failure
        # Why needed: Informs user that restart operation failed
        # Impact: User knows the restart did not complete successfully
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates restart operation failure
        # Impact: Function terminates with error status
    fi
}

# Function: Scale deployment
scale_deployment() {
    # =============================================================================
    # SCALE DEPLOYMENT FUNCTION
    # =============================================================================
    # Scales a specific deployment component to the specified number of replicas
    # with validation, dry-run support, and comprehensive scaling monitoring.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component to scale
    # Why needed: Identifies which deployment to scale (backend, frontend, etc.)
    # Impact: When specified, only that component's deployment is scaled
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local replicas=$2
    # Purpose: Specifies the target number of replicas
    # Why needed: Defines how many pod instances should be running
    # Impact: Determines the final scale of the deployment
    # Parameter: $2 is the number of replicas (e.g., 3, 5, 10)
    
    # =============================================================================
    # COMPONENT VALIDATION
    # =============================================================================
    # Purpose: Validate that component parameter is provided
    # Why needed: Prevents accidental scaling of all deployments
    
    if [ -z "$component" ]; then
        # Purpose: Check if component parameter is empty or not provided
        # Why needed: Validates that a specific component is targeted
        # Impact: If no component specified, scaling operation cannot proceed
        
        print_status "ERROR" "Component must be specified for scaling"
        # Purpose: Log error message about missing component
        # Why needed: Informs user that component parameter is required
        # Impact: User knows they need to specify a component
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates component validation failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # SCALING INITIATION
    # =============================================================================
    # Purpose: Log scaling operation and check for dry-run mode
    # Why needed: Provides user feedback and supports dry-run testing
    
    print_status "INFO" "Scaling deployment $component-deployment to $replicas replicas"
    # Purpose: Log informational message about scaling operation
    # Why needed: Informs user that scaling is being initiated
    # Impact: User knows which component and target replicas
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing scaling operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual scaling when in dry-run mode
        # Impact: If dry-run enabled, only simulate the scaling operation
        
        print_status "INFO" "DRY RUN: Would scale deployment $component-deployment to $replicas replicas"
        # Purpose: Log dry-run message about scaling operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the scaling would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual scaling
    fi
    
    # =============================================================================
    # DEPLOYMENT SCALING EXECUTION
    # =============================================================================
    # Purpose: Execute the actual deployment scaling
    # Why needed: Performs the scaling operation on the specified deployment
    
    if kubectl scale deployment/"$component-deployment" --replicas="$replicas" -n "$NAMESPACE"; then
        # Purpose: Execute kubectl scale command
        # Why needed: Changes the number of replicas for the deployment
        # Impact: Triggers scaling up or down of pods in the deployment
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # --replicas: Specifies the target number of replicas
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Deployment $component-deployment scaled to $replicas replicas"
        # Purpose: Log success message about scaling completion
        # Why needed: Confirms that scaling was initiated successfully
        # Impact: User knows the scaling operation completed
        
        # =============================================================================
        # SCALING COMPLETION MONITORING
        # =============================================================================
        # Purpose: Wait for scaling to complete and monitor progress
        # Why needed: Ensures scaling completes successfully before continuing
        
        print_status "INFO" "Waiting for scaling to complete..."
        # Purpose: Log informational message about scaling monitoring
        # Why needed: Informs user that scaling completion is being monitored
        # Impact: User knows the system is waiting for scaling to complete
        
        kubectl rollout status deployment/"$component-deployment" -n "$NAMESPACE"
        # Purpose: Monitor rollout status until scaling completion
        # Why needed: Ensures all pods are successfully scaled and ready
        # Impact: Blocks until scaling is complete or fails
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Scaling completed for $component-deployment"
        # Purpose: Log success message about scaling completion
        # Why needed: Confirms that scaling completed successfully
        # Impact: User knows the scaling operation finished successfully
    else
        # Purpose: Handle scaling command failure
        # Why needed: Provides error handling for failed scaling operations
        # Impact: If scaling fails, error is logged and function exits with error
        
        print_status "ERROR" "Failed to scale deployment $component-deployment"
        # Purpose: Log error message about scaling failure
        # Why needed: Informs user that scaling operation failed
        # Impact: User knows the scaling did not complete successfully
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates scaling operation failure
        # Impact: Function terminates with error status
    fi
}

# Function: Update image
update_image() {
    # =============================================================================
    # UPDATE IMAGE FUNCTION
    # =============================================================================
    # Updates the container image for a specific deployment component with
    # validation, dry-run support, and comprehensive rollout monitoring.
    # =============================================================================
    
    local component=$1
    # Purpose: Specifies the target component to update
    # Why needed: Identifies which deployment to update (backend, frontend, etc.)
    # Impact: When specified, only that component's deployment is updated
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local image=$2
    # Purpose: Specifies the new container image to use
    # Why needed: Defines which image version the deployment should use
    # Impact: Determines the container image for the updated deployment
    # Parameter: $2 is the image name (e.g., "backend:v2.0", "frontend:latest")
    
    # =============================================================================
    # PARAMETER VALIDATION
    # =============================================================================
    # Purpose: Validate that both component and image parameters are provided
    # Why needed: Prevents incomplete update operations
    
    if [ -z "$component" ] || [ -z "$image" ]; then
        # Purpose: Check if either component or image parameter is missing
        # Why needed: Validates that both required parameters are provided
        # Impact: If either parameter missing, update operation cannot proceed
        
        print_status "ERROR" "Component and image must be specified for update"
        # Purpose: Log error message about missing parameters
        # Why needed: Informs user that both parameters are required
        # Impact: User knows they need to specify both component and image
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates parameter validation failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # IMAGE UPDATE INITIATION
    # =============================================================================
    # Purpose: Log update operation and check for dry-run mode
    # Why needed: Provides user feedback and supports dry-run testing
    
    print_status "INFO" "Updating image for component $component to $image"
    # Purpose: Log informational message about image update operation
    # Why needed: Informs user that image update is being initiated
    # Impact: User knows which component and image are being updated
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing image update operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual update when in dry-run mode
        # Impact: If dry-run enabled, only simulate the image update operation
        
        print_status "INFO" "DRY RUN: Would update image for $component-deployment to $image"
        # Purpose: Log dry-run message about image update operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the image update would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual update
    fi
    
    # =============================================================================
    # IMAGE UPDATE EXECUTION
    # =============================================================================
    # Purpose: Execute the actual image update
    # Why needed: Performs the image update operation on the specified deployment
    
    if kubectl set image deployment/"$component-deployment" "$component=$image" -n "$NAMESPACE"; then
        # Purpose: Execute kubectl set image command
        # Why needed: Updates the container image for the deployment
        # Impact: Triggers rolling update with the new image
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # $component=$image: Sets the container image for the component
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Image updated for $component-deployment to $image"
        # Purpose: Log success message about image update completion
        # Why needed: Confirms that image update was initiated successfully
        # Impact: User knows the image update operation completed
        
        # =============================================================================
        # ROLLOUT COMPLETION MONITORING
        # =============================================================================
        # Purpose: Wait for rollout to complete and monitor progress
        # Why needed: Ensures image update completes successfully before continuing
        
        print_status "INFO" "Waiting for rollout to complete..."
        # Purpose: Log informational message about rollout monitoring
        # Why needed: Informs user that rollout completion is being monitored
        # Impact: User knows the system is waiting for image update to complete
        
        kubectl rollout status deployment/"$component-deployment" -n "$NAMESPACE"
        # Purpose: Monitor rollout status until image update completion
        # Why needed: Ensures all pods are successfully updated with new image
        # Impact: Blocks until image update is complete or fails
        # deployment/: Specifies the deployment resource type
        # $component-deployment: Constructs deployment name from component
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Image update completed for $component-deployment"
        # Purpose: Log success message about image update completion
        # Why needed: Confirms that image update completed successfully
        # Impact: User knows the image update operation finished successfully
    else
        # Purpose: Handle image update command failure
        # Why needed: Provides error handling for failed image update operations
        # Impact: If image update fails, error is logged and function exits with error
        
        print_status "ERROR" "Failed to update image for $component-deployment"
        # Purpose: Log error message about image update failure
        # Why needed: Informs user that image update operation failed
        # Impact: User knows the image update did not complete successfully
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates image update operation failure
        # Impact: Function terminates with error status
    fi
}

# Function: Backup data
backup_data() {
    # =============================================================================
    # BACKUP DATA FUNCTION
    # =============================================================================
    # Creates comprehensive backup of e-commerce application data including
    # ConfigMaps, Secrets, PVCs, and database data with timestamped directories.
    # =============================================================================
    
    local backup_dir="/tmp/ecommerce-backup-$(date +%Y%m%d_%H%M%S)"
    # Purpose: Creates timestamped backup directory path
    # Why needed: Ensures unique backup directories for each backup operation
    # Impact: Prevents backup conflicts and enables multiple backups
    # Format: /tmp/ecommerce-backup-YYYYMMDD_HHMMSS
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup operation and check for dry-run mode
    # Why needed: Provides user feedback and supports dry-run testing
    
    print_status "INFO" "Creating backup in $backup_dir"
    # Purpose: Log informational message about backup operation
    # Why needed: Informs user that backup is being created
    # Impact: User knows the backup location and operation status
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing backup operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual backup when in dry-run mode
        # Impact: If dry-run enabled, only simulate the backup operation
        
        print_status "INFO" "DRY RUN: Would create backup in $backup_dir"
        # Purpose: Log dry-run message about backup operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the backup would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual backup
    fi
    
    # =============================================================================
    # BACKUP DIRECTORY CREATION
    # =============================================================================
    # Purpose: Create backup directory for storing backup files
    # Why needed: Provides location for storing backup data
    
    mkdir -p "$backup_dir"
    # Purpose: Create backup directory with parent directories if needed
    # Why needed: Ensures backup directory exists before storing files
    # Impact: Creates the backup directory structure
    # -p: Creates parent directories if they don't exist
    
    # =============================================================================
    # CONFIGMAPS BACKUP
    # =============================================================================
    # Purpose: Backup all ConfigMaps from the namespace
    # Why needed: Preserves application configuration data
    
    kubectl get configmaps -n "$NAMESPACE" -o yaml > "$backup_dir/configmaps.yaml"
    # Purpose: Export all ConfigMaps to YAML file
    # Why needed: Preserves configuration data for restoration
    # Impact: Creates configmaps.yaml with all ConfigMap definitions
    # -n: Specifies the target namespace
    # -o yaml: Outputs in YAML format
    # >: Redirects output to file
    
    print_status "SUCCESS" "ConfigMaps backed up"
    # Purpose: Log success message about ConfigMaps backup
    # Why needed: Confirms ConfigMaps backup completed successfully
    # Impact: User knows ConfigMaps are backed up
    
    # =============================================================================
    # SECRETS BACKUP
    # =============================================================================
    # Purpose: Backup all Secrets from the namespace
    # Why needed: Preserves sensitive configuration data
    
    kubectl get secrets -n "$NAMESPACE" -o yaml > "$backup_dir/secrets.yaml"
    # Purpose: Export all Secrets to YAML file
    # Why needed: Preserves sensitive data for restoration
    # Impact: Creates secrets.yaml with all Secret definitions
    # -n: Specifies the target namespace
    # -o yaml: Outputs in YAML format
    # >: Redirects output to file
    
    print_status "SUCCESS" "Secrets backed up"
    # Purpose: Log success message about Secrets backup
    # Why needed: Confirms Secrets backup completed successfully
    # Impact: User knows Secrets are backed up
    
    # =============================================================================
    # PVCs BACKUP
    # =============================================================================
    # Purpose: Backup all PersistentVolumeClaims from the namespace
    # Why needed: Preserves storage configuration data
    
    kubectl get pvc -n "$NAMESPACE" -o yaml > "$backup_dir/pvcs.yaml"
    # Purpose: Export all PVCs to YAML file
    # Why needed: Preserves storage configuration for restoration
    # Impact: Creates pvcs.yaml with all PVC definitions
    # -n: Specifies the target namespace
    # -o yaml: Outputs in YAML format
    # >: Redirects output to file
    
    print_status "SUCCESS" "PVCs backed up"
    # Purpose: Log success message about PVCs backup
    # Why needed: Confirms PVCs backup completed successfully
    # Impact: User knows PVCs are backed up
    
    # =============================================================================
    # DATABASE DATA BACKUP
    # =============================================================================
    # Purpose: Backup database data from the database pod
    # Why needed: Preserves application data for restoration
    
    local db_pod
    # Purpose: Variable to store database pod name
    # Why needed: Identifies which pod to backup database from
    # Impact: Used to determine the target pod for database backup
    
    db_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce,component=database" -o jsonpath='{.items[0].metadata.name}')
    # Purpose: Get the first database pod name
    # Why needed: Identifies the database pod for data backup
    # Impact: Provides pod name for database backup operations
    # -n: Specifies the target namespace
    # -l: Uses label selector to find database pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to get first pod's name
    
    if [ -n "$db_pod" ]; then
        # Purpose: Check if database pod was found
        # Why needed: Validates database pod existence before backup
        # Impact: If pod found, proceed with database backup
        kubectl exec -n "$NAMESPACE" "$db_pod" -- pg_dump -U postgres ecommerce > "$backup_dir/database.sql"
        # Purpose: Execute database dump command inside the database pod
        # Why needed: Creates SQL dump of the database for backup
        # Impact: Generates database.sql file with complete database schema and data
        # kubectl exec: Execute command inside pod
        # -n: Specifies the target namespace
        # $db_pod: Target pod for command execution
        # --: Separates kubectl exec from the command to execute
        # pg_dump: PostgreSQL database dump utility
        # -U postgres: Connect as postgres user
        # ecommerce: Database name to dump
        # >: Redirects output to file
        
        print_status "SUCCESS" "Database backed up"
        # Purpose: Log success message about database backup
        # Why needed: Confirms database backup completed successfully
        # Impact: User knows database data is backed up
    else
        # Purpose: Handle case when database pod is not found
        # Why needed: Provides graceful handling when database pod is unavailable
        # Impact: If no database pod found, skip database backup but continue
        
        print_status "WARNING" "Database pod not found, skipping database backup"
        # Purpose: Log warning message about missing database pod
        # Why needed: Informs user that database backup was skipped
        # Impact: User knows database backup was not performed
    fi
    
    # =============================================================================
    # BACKUP COMPLETION
    # =============================================================================
    # Purpose: Log final backup completion message
    # Why needed: Confirms that entire backup process completed
    
    print_status "SUCCESS" "Backup completed: $backup_dir"
    # Purpose: Log success message about overall backup completion
    # Why needed: Confirms that backup process finished successfully
    # Impact: User knows backup is complete and where files are stored
}

# Function: Restore data
restore_data() {
    # =============================================================================
    # RESTORE DATA FUNCTION
    # =============================================================================
    # Restores e-commerce application data from backup directory including
    # ConfigMaps, Secrets, PVCs, and database data with validation and dry-run support.
    # =============================================================================
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory to restore from
    # Why needed: Identifies which backup to restore data from
    # Impact: When specified, data is restored from this directory
    # Parameter: $1 is the backup directory path (e.g., "/tmp/ecommerce-backup-20231201_120000")
    
    # =============================================================================
    # BACKUP DIRECTORY VALIDATION
    # =============================================================================
    # Purpose: Validate that backup directory exists and is accessible
    # Why needed: Prevents restore operations from non-existent directories
    
    if [ -z "$backup_dir" ] || [ ! -d "$backup_dir" ]; then
        # Purpose: Check if backup directory is empty or doesn't exist
        # Why needed: Validates that backup directory is valid and accessible
        # Impact: If directory invalid, restore operation cannot proceed
        
        print_status "ERROR" "Backup directory $backup_dir not found"
        # Purpose: Log error message about missing backup directory
        # Why needed: Informs user that backup directory is invalid
        # Impact: User knows they need to provide a valid backup directory
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates backup directory validation failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # RESTORE INITIATION
    # =============================================================================
    # Purpose: Log restore operation and check for dry-run mode
    # Why needed: Provides user feedback and supports dry-run testing
    
    print_status "INFO" "Restoring data from $backup_dir"
    # Purpose: Log informational message about restore operation
    # Why needed: Informs user that restore is being initiated
    # Impact: User knows the restore source and operation status
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing restore operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual restore when in dry-run mode
        # Impact: If dry-run enabled, only simulate the restore operation
        
        print_status "INFO" "DRY RUN: Would restore data from $backup_dir"
        # Purpose: Log dry-run message about restore operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the restore would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual restore
    fi
    
    # =============================================================================
    # CONFIGMAPS RESTORATION
    # =============================================================================
    # Purpose: Restore ConfigMaps from backup file
    # Why needed: Restores application configuration data
    
    if [ -f "$backup_dir/configmaps.yaml" ]; then
        # Purpose: Check if ConfigMaps backup file exists
        # Why needed: Validates that ConfigMaps backup file is available
        # Impact: If file exists, proceed with ConfigMaps restoration
        
        kubectl apply -f "$backup_dir/configmaps.yaml" -n "$NAMESPACE"
        # Purpose: Apply ConfigMaps from backup file
        # Why needed: Restores configuration data to the cluster
        # Impact: Creates or updates ConfigMaps in the namespace
        # -f: Specifies the file to apply
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "ConfigMaps restored"
        # Purpose: Log success message about ConfigMaps restoration
        # Why needed: Confirms ConfigMaps restoration completed successfully
        # Impact: User knows ConfigMaps are restored
    fi
    
    # =============================================================================
    # SECRETS RESTORATION
    # =============================================================================
    # Purpose: Restore Secrets from backup file
    # Why needed: Restores sensitive configuration data
    
    if [ -f "$backup_dir/secrets.yaml" ]; then
        # Purpose: Check if Secrets backup file exists
        # Why needed: Validates that Secrets backup file is available
        # Impact: If file exists, proceed with Secrets restoration
        
        kubectl apply -f "$backup_dir/secrets.yaml" -n "$NAMESPACE"
        # Purpose: Apply Secrets from backup file
        # Why needed: Restores sensitive data to the cluster
        # Impact: Creates or updates Secrets in the namespace
        # -f: Specifies the file to apply
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "Secrets restored"
        # Purpose: Log success message about Secrets restoration
        # Why needed: Confirms Secrets restoration completed successfully
        # Impact: User knows Secrets are restored
    fi
    
    # =============================================================================
    # PVCs RESTORATION
    # =============================================================================
    # Purpose: Restore PVCs from backup file
    # Why needed: Restores storage configuration data
    
    if [ -f "$backup_dir/pvcs.yaml" ]; then
        # Purpose: Check if PVCs backup file exists
        # Why needed: Validates that PVCs backup file is available
        # Impact: If file exists, proceed with PVCs restoration
        kubectl apply -f "$backup_dir/pvcs.yaml" -n "$NAMESPACE"
        # Purpose: Apply PVCs from backup file
        # Why needed: Restores storage configuration to the cluster
        # Impact: Creates or updates PVCs in the namespace
        # -f: Specifies the file to apply
        # -n: Specifies the target namespace
        
        print_status "SUCCESS" "PVCs restored"
        # Purpose: Log success message about PVCs restoration
        # Why needed: Confirms PVCs restoration completed successfully
        # Impact: User knows PVCs are restored
    fi
    
    # =============================================================================
    # DATABASE RESTORATION
    # =============================================================================
    # Purpose: Restore database data from backup file
    # Why needed: Restores application data to the database
    
    if [ -f "$backup_dir/database.sql" ]; then
        # Purpose: Check if database backup file exists
        # Why needed: Validates that database backup file is available
        # Impact: If file exists, proceed with database restoration
        
        local db_pod
        # Purpose: Variable to store database pod name
        # Why needed: Identifies which pod to restore database to
        # Impact: Used to determine the target pod for database restoration
        
        db_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce,component=database" -o jsonpath='{.items[0].metadata.name}')
        # Purpose: Get the first database pod name
        # Why needed: Identifies the database pod for data restoration
        # Impact: Provides pod name for database restoration operations
        # -n: Specifies the target namespace
        # -l: Uses label selector to find database pods
        # -o jsonpath: Extracts only the pod name from JSON output
        # .items[0].metadata.name: JSONPath to get first pod's name
        
        if [ -n "$db_pod" ]; then
            # Purpose: Check if database pod was found
            # Why needed: Validates database pod existence before restoration
            # Impact: If pod found, proceed with database restoration
            
            kubectl exec -i -n "$NAMESPACE" "$db_pod" -- psql -U postgres ecommerce < "$backup_dir/database.sql"
            # Purpose: Execute database restore command inside the database pod
            # Why needed: Restores database data from SQL dump
            # Impact: Loads database.sql file into the database
            # kubectl exec: Execute command inside pod
            # -i: Interactive mode for input redirection
            # -n: Specifies the target namespace
            # $db_pod: Target pod for command execution
            # --: Separates kubectl exec from the command to execute
            # psql: PostgreSQL command-line client
            # -U postgres: Connect as postgres user
            # ecommerce: Database name to restore to
            # <: Redirects input from file
            
            print_status "SUCCESS" "Database restored"
            # Purpose: Log success message about database restoration
            # Why needed: Confirms database restoration completed successfully
            # Impact: User knows database data is restored
        else
            # Purpose: Handle case when database pod is not found
            # Why needed: Provides graceful handling when database pod is unavailable
            # Impact: If no database pod found, skip database restoration but continue
            
            print_status "WARNING" "Database pod not found, skipping database restore"
            # Purpose: Log warning message about missing database pod
            # Why needed: Informs user that database restoration was skipped
            # Impact: User knows database restoration was not performed
        fi
    fi
    
    # =============================================================================
    # RESTORE COMPLETION
    # =============================================================================
    # Purpose: Log final restore completion message
    # Why needed: Confirms that entire restore process completed
    
    print_status "SUCCESS" "Data restore completed"
    # Purpose: Log success message about overall restore completion
    # Why needed: Confirms that restore process finished successfully
    # Impact: User knows restore is complete
}

# Function: Show help
show_help() {
    # =============================================================================
    # SHOW HELP FUNCTION
    # =============================================================================
    # Displays comprehensive help information for the operations script including
    # usage instructions, available actions, options, and practical examples.
    # =============================================================================
    
    # Purpose: Display help information for the operations script
    # Why needed: Provides users with usage instructions and examples
    # Impact: Users understand how to use the script effectively
    # Parameters: None
    # Usage: show_help
    
    cat << EOF
    # Purpose: Display help information using heredoc syntax
    # Why needed: Provides formatted help text with examples
    # Impact: Shows comprehensive usage information to users
    # EOF: Marks the end of the heredoc content

E-commerce Application Operations Script

USAGE:
    ./operate.sh [ACTION] [OPTIONS]

ACTIONS:
    status          Show status of all components
    logs            Show logs for components
    restart         Restart a component
    scale           Scale a component
    update          Update image for a component
    backup          Backup application data
    restore         Restore application data
    monitor         Monitor application health
    cleanup         Cleanup resources

OPTIONS:
    --namespace=NAMESPACE    Kubernetes namespace (default: ecommerce)
    --component=COMPONENT   Specific component (backend, frontend, database, monitoring)
    --verbose               Enable verbose output
    --dry-run              Show what would be done without executing

EXAMPLES:
    # Show status of all components
    ./operate.sh status

    # Show logs for backend component
    ./operate.sh logs --component=backend

    # Restart backend deployment
    ./operate.sh restart --component=backend

    # Scale frontend to 3 replicas
    ./operate.sh scale --component=frontend --replicas=3

    # Update backend image
    ./operate.sh update --component=backend --image=ecommerce-backend:v2.0.0

    # Backup application data
    ./operate.sh backup

    # Restore application data
    ./operate.sh restore --backup-dir=/tmp/ecommerce-backup-20241201_120000

    # Monitor application health
    ./operate.sh monitor

    # Cleanup resources
    ./operate.sh cleanup

COMPONENTS:
    backend         E-commerce backend API
    frontend        E-commerce frontend application
    database        PostgreSQL database
    monitoring      Monitoring stack (Prometheus, Grafana, AlertManager)

EOF
}

# =============================================================================
# MAIN OPERATIONS FUNCTIONS
# =============================================================================

# Function: Show status
show_status() {
    # =============================================================================
    # SHOW STATUS FUNCTION
    # =============================================================================
    # Displays comprehensive status information for all e-commerce application
    # components including pods, services, deployments, and resource usage.
    # =============================================================================
    
    # Purpose: Display comprehensive status information for all components
    # Why needed: Provides overview of application health and resource usage
    # Impact: Users can quickly assess application status and performance
    # Parameters: None
    # Usage: show_status
    
    # =============================================================================
    # STATUS HEADER
    # =============================================================================
    # Purpose: Display application status header and namespace information
    # Why needed: Provides context for the status information
    
    print_status "HEADER" "E-commerce Application Status"
    # Purpose: Display main status header
    # Why needed: Identifies the status report for the e-commerce application
    # Impact: User knows this is the application status report
    
    print_status "INFO" "Namespace: $NAMESPACE"
    # Purpose: Display current namespace information
    # Why needed: Shows which namespace the status is being checked for
    # Impact: User knows the target namespace for all status checks
    
    # =============================================================================
    # PODS STATUS
    # =============================================================================
    # Purpose: Display pod status information
    # Why needed: Shows the current state of all application pods
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between status sections
    
    print_status "INFO" "=== PODS ==="
    # Purpose: Display pods section header
    # Why needed: Identifies the pods status section
    # Impact: User knows the following information is about pods
    
    get_pod_status "$COMPONENT"
    # Purpose: Retrieve and display pod status information
    # Why needed: Shows current pod status, IP addresses, and readiness
    # Impact: User can see which pods are running and their status
    # $COMPONENT: Filters pods by specific component if specified
    
    # =============================================================================
    # SERVICES STATUS
    # =============================================================================
    # Purpose: Display service status information
    # Why needed: Shows the current state of all application services
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between status sections
    
    print_status "INFO" "=== SERVICES ==="
    # Purpose: Display services section header
    # Why needed: Identifies the services status section
    # Impact: User knows the following information is about services
    
    get_service_status "$COMPONENT"
    # Purpose: Retrieve and display service status information
    # Why needed: Shows current service status, IPs, and ports
    # Impact: User can see which services are available and their endpoints
    # $COMPONENT: Filters services by specific component if specified
    
    # =============================================================================
    # DEPLOYMENTS STATUS
    # =============================================================================
    # Purpose: Display deployment status information
    # Why needed: Shows the current state of all application deployments
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between status sections
    
    print_status "INFO" "=== DEPLOYMENTS ==="
    # Purpose: Display deployments section header
    # Why needed: Identifies the deployments status section
    # Impact: User knows the following information is about deployments
    
    get_deployment_status "$COMPONENT"
    # Purpose: Retrieve and display deployment status information
    # Why needed: Shows current deployment status, replicas, and age
    # Impact: User can see which deployments are running and their scale
    # $COMPONENT: Filters deployments by specific component if specified
    
    # =============================================================================
    # RESOURCE USAGE STATUS
    # =============================================================================
    # Purpose: Display resource usage information
    # Why needed: Shows current CPU and memory usage for all pods
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between status sections
    
    print_status "INFO" "=== RESOURCE USAGE ==="
    # Purpose: Display resource usage section header
    # Why needed: Identifies the resource usage section
    # Impact: User knows the following information is about resource usage
    
    get_resource_usage "$COMPONENT"
    # Purpose: Retrieve and display resource usage information
    # Why needed: Shows current CPU and memory usage for pods
    # Impact: User can see resource consumption and identify performance issues
    # $COMPONENT: Filters resource usage by specific component if specified
}

# Function: Show logs
show_logs() {
    # =============================================================================
    # SHOW LOGS FUNCTION
    # =============================================================================
    # Displays application logs for a specific component with validation
    # and comprehensive log retrieval capabilities.
    # =============================================================================
    
    # Purpose: Display application logs for a specific component
    # Why needed: Provides log information for troubleshooting and monitoring
    # Impact: Users can view application logs to diagnose issues
    # Parameters: None (uses global COMPONENT variable)
    # Usage: show_logs
    
    # =============================================================================
    # COMPONENT VALIDATION
    # =============================================================================
    # Purpose: Validate that component is specified for log retrieval
    # Why needed: Prevents log retrieval without specifying target component
    
    if [ -z "$COMPONENT" ]; then
        # Purpose: Check if component parameter is empty or not provided
        # Why needed: Validates that a specific component is targeted
        # Impact: If no component specified, log retrieval cannot proceed
        
        print_status "ERROR" "Component must be specified for logs"
        # Purpose: Log error message about missing component
        # Why needed: Informs user that component parameter is required
        # Impact: User knows they need to specify a component
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates component validation failure
        # Impact: Function terminates with error status
    fi
    
    # =============================================================================
    # LOG DISPLAY
    # =============================================================================
    # Purpose: Display logs for the specified component
    # Why needed: Provides log information for troubleshooting
    
    print_status "HEADER" "Logs for component: $COMPONENT"
    # Purpose: Display log header with component information
    # Why needed: Identifies which component's logs are being shown
    # Impact: User knows which component the logs belong to
    
    get_logs "$COMPONENT" 100
    # Purpose: Retrieve and display logs for the specified component
    # Why needed: Shows application logs for troubleshooting and monitoring
    # Impact: User can view the last 100 lines of logs for the component
    # $COMPONENT: Specifies which component to get logs from
    # 100: Number of log lines to retrieve
}

# Function: Monitor application
monitor_application() {
    # =============================================================================
    # MONITOR APPLICATION FUNCTION
    # =============================================================================
    # Performs comprehensive monitoring of the e-commerce application including
    # health checks, resource usage monitoring, and event analysis for operational
    # visibility and troubleshooting capabilities.
    # =============================================================================
    
    # Purpose: Monitor e-commerce application health and performance
    # Why needed: Provides comprehensive monitoring for operational visibility
    # Impact: Users can assess application health and identify issues
    # Parameters: None (uses global NAMESPACE and COMPONENT variables)
    # Usage: monitor_application
    
    # =============================================================================
    # MONITORING INITIATION
    # =============================================================================
    # Purpose: Display monitoring header and initiate monitoring process
    # Why needed: Provides context for monitoring operations
    
    print_status "HEADER" "Monitoring E-commerce Application"
    # Purpose: Display monitoring header
    # Why needed: Identifies the monitoring operation for the e-commerce application
    # Impact: User knows this is the application monitoring report
    
    # =============================================================================
    # HEALTH CHECK EXECUTION
    # =============================================================================
    # Purpose: Run comprehensive health checks if available
    # Why needed: Validates application health and component status
    
    if [ -f "validation/health-check.sh" ]; then
        # Purpose: Check if health check script exists
        # Why needed: Validates that health check script is available
        # Impact: If script exists, proceed with health check execution
        
        print_status "INFO" "Running health check..."
        # Purpose: Log informational message about health check execution
        # Why needed: Informs user that health check is being performed
        # Impact: User knows health check is in progress
        
        ./validation/health-check.sh "$NAMESPACE"
        # Purpose: Execute health check script for the specified namespace
        # Why needed: Performs comprehensive health validation of all components
        # Impact: Validates pod health, service health, deployment health, and PVCs
        # ./validation/health-check.sh: Path to health check script
        # $NAMESPACE: Specifies the target namespace for health checks
    else
        # Purpose: Handle case when health check script is not found
        # Why needed: Provides graceful handling when health check script is unavailable
        # Impact: If script not found, skip health check but continue monitoring
        
        print_status "WARNING" "Health check script not found"
        # Purpose: Log warning message about missing health check script
        # Why needed: Informs user that health check was skipped
        # Impact: User knows health check was not performed
    fi
    
    # =============================================================================
    # RESOURCE USAGE MONITORING
    # =============================================================================
    # Purpose: Display current resource usage for all components
    # Why needed: Provides visibility into resource consumption and performance
    
    print_status "INFO" "Resource usage:"
    # Purpose: Log informational message about resource usage section
    # Why needed: Identifies the resource usage monitoring section
    # Impact: User knows the following information is about resource usage
    
    get_resource_usage "$COMPONENT"
    # Purpose: Retrieve and display resource usage information
    # Why needed: Shows current CPU and memory usage for pods
    # Impact: User can see resource consumption and identify performance issues
    # $COMPONENT: Filters resource usage by specific component if specified
    
    # =============================================================================
    # RECENT EVENTS MONITORING
    # =============================================================================
    # Purpose: Display recent Kubernetes events for troubleshooting
    # Why needed: Provides visibility into recent cluster events and issues
    
    print_status "INFO" "Recent events:"
    # Purpose: Log informational message about recent events section
    # Why needed: Identifies the recent events monitoring section
    # Impact: User knows the following information is about recent events
    
    kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -10
    # Purpose: Retrieve and display the 10 most recent events
    # Why needed: Shows recent cluster events for troubleshooting and monitoring
    # Impact: User can see recent events that may indicate issues or changes
    # -n: Specifies the target namespace
    # --sort-by='.lastTimestamp': Sorts events by timestamp (newest first)
    # | tail -10: Limits output to the 10 most recent events
}

# Function: Cleanup resources
cleanup_resources() {
    # =============================================================================
    # CLEANUP RESOURCES FUNCTION
    # =============================================================================
    # Performs comprehensive cleanup of Kubernetes resources including completed
    # pods, failed pods, and old replicasets to maintain cluster hygiene and
    # resource efficiency with dry-run support.
    # =============================================================================
    
    # Purpose: Clean up unnecessary Kubernetes resources
    # Why needed: Maintains cluster hygiene and frees up resources
    # Impact: Removes completed, failed, and unused resources
    # Parameters: None (uses global NAMESPACE and DRY_RUN variables)
    # Usage: cleanup_resources
    
    # =============================================================================
    # CLEANUP INITIATION
    # =============================================================================
    # Purpose: Display cleanup header and check for dry-run mode
    # Why needed: Provides context for cleanup operations
    
    print_status "HEADER" "Cleaning up resources"
    # Purpose: Display cleanup header
    # Why needed: Identifies the resource cleanup operation
    # Impact: User knows this is the resource cleanup process
    
    # =============================================================================
    # DRY RUN VALIDATION
    # =============================================================================
    # Purpose: Check if operation is in dry-run mode
    # Why needed: Allows testing cleanup operations without actual execution
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry-run mode is enabled
        # Why needed: Prevents actual cleanup when in dry-run mode
        # Impact: If dry-run enabled, only simulate the cleanup operation
        
        print_status "INFO" "DRY RUN: Would cleanup resources"
        # Purpose: Log dry-run message about cleanup operation
        # Why needed: Informs user what would happen in dry-run mode
        # Impact: User knows the cleanup would occur but is not executed
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful dry-run simulation
        # Impact: Function completes successfully without actual cleanup
    fi
    
    # =============================================================================
    # COMPLETED PODS CLEANUP
    # =============================================================================
    # Purpose: Remove pods that have completed successfully
    # Why needed: Frees up resources and maintains cluster hygiene
    
    kubectl delete pod --field-selector=status.phase=Succeeded -n "$NAMESPACE" >/dev/null 2>&1 || true
    # Purpose: Delete all pods with Succeeded status
    # Why needed: Removes completed pods that are no longer needed
    # Impact: Frees up resources and reduces cluster clutter
    # --field-selector=status.phase=Succeeded: Selects only succeeded pods
    # -n: Specifies the target namespace
    # >/dev/null 2>&1: Suppresses output and errors
    # || true: Ensures command doesn't fail if no pods found
    
    print_status "SUCCESS" "Cleaned up completed pods"
    # Purpose: Log success message about completed pods cleanup
    # Why needed: Confirms that completed pods were cleaned up
    # Impact: User knows completed pods were removed
    
    # =============================================================================
    # FAILED PODS CLEANUP
    # =============================================================================
    # Purpose: Remove pods that have failed
    # Why needed: Frees up resources and maintains cluster hygiene
    
    kubectl delete pod --field-selector=status.phase=Failed -n "$NAMESPACE" >/dev/null 2>&1 || true
    # Purpose: Delete all pods with Failed status
    # Why needed: Removes failed pods that are no longer needed
    # Impact: Frees up resources and reduces cluster clutter
    # --field-selector=status.phase=Failed: Selects only failed pods
    # -n: Specifies the target namespace
    # >/dev/null 2>&1: Suppresses output and errors
    # || true: Ensures command doesn't fail if no pods found
    
    print_status "SUCCESS" "Cleaned up failed pods"
    # Purpose: Log success message about failed pods cleanup
    # Why needed: Confirms that failed pods were cleaned up
    # Impact: User knows failed pods were removed
    
    # =============================================================================
    # OLD REPLICASETS CLEANUP
    # =============================================================================
    # Purpose: Remove replicasets with zero replicas
    # Why needed: Frees up resources and maintains cluster hygiene
    
    kubectl delete replicaset --field-selector=status.replicas=0 -n "$NAMESPACE" >/dev/null 2>&1 || true
    # Purpose: Delete all replicasets with zero replicas
    # Why needed: Removes old replicasets that are no longer needed
    # Impact: Frees up resources and reduces cluster clutter
    # --field-selector=status.replicas=0: Selects only replicasets with zero replicas
    # -n: Specifies the target namespace
    # >/dev/null 2>&1: Suppresses output and errors
    # || true: Ensures command doesn't fail if no replicasets found
    
    print_status "SUCCESS" "Cleaned up old replicasets"
    # Purpose: Log success message about old replicasets cleanup
    # Why needed: Confirms that old replicasets were cleaned up
    # Impact: User knows old replicasets were removed
    
    # =============================================================================
    # CLEANUP COMPLETION
    # =============================================================================
    # Purpose: Log final cleanup completion message
    # Why needed: Confirms that entire cleanup process completed
    
    print_status "SUCCESS" "Resource cleanup completed"
    # Purpose: Log success message about overall cleanup completion
    # Why needed: Confirms that cleanup process finished successfully
    # Impact: User knows cleanup is complete
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Check prerequisites
check_prerequisites

# Handle actions
case $ACTION in
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "restart")
        restart_deployment "$COMPONENT"
        ;;
    "scale")
        if [ -z "$2" ]; then
            print_status "ERROR" "Replicas must be specified for scaling"
            exit 1
        fi
        scale_deployment "$COMPONENT" "$2"
        ;;
    "update")
        if [ -z "$2" ]; then
            print_status "ERROR" "Image must be specified for update"
            exit 1
        fi
        update_image "$COMPONENT" "$2"
        ;;
    "backup")
        backup_data
        ;;
    "restore")
        if [ -z "$2" ]; then
            print_status "ERROR" "Backup directory must be specified for restore"
            exit 1
        fi
        restore_data "$2"
        ;;
    "monitor")
        monitor_application
        ;;
    "cleanup")
        cleanup_resources
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "")
        print_status "ERROR" "No action specified"
        show_help
        exit 1
        ;;
    *)
        print_status "ERROR" "Unknown action: $ACTION"
        show_help
        exit 1
        ;;
esac
