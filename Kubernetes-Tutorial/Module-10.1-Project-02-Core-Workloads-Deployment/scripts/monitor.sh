#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION MONITORING SCRIPT
# =============================================================================
# This script provides comprehensive monitoring and alerting for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# real-time monitoring, alerting, and observability features.
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
# MONITORING CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent monitoring configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for monitoring operations
# Why needed: Provides consistent namespace reference for all monitoring activities
# Impact: All monitoring operations target resources in this namespace
# Value: Defaults to 'ecommerce', can be overridden via --namespace argument

ACTION=""
# Purpose: Specifies the monitoring action to perform
# Why needed: Determines which monitoring function to execute
# Impact: Controls the type of monitoring operation performed
# Value: Actions like 'status', 'alerts', 'metrics', 'logs', 'dashboard'

DURATION="300s"
# Purpose: Specifies the duration for continuous monitoring operations
# Why needed: Controls how long monitoring operations run
# Impact: Determines the time window for monitoring data collection
# Value: Defaults to 5 minutes, accepts formats like '300s', '5m', '1h'

INTERVAL="30s"
# Purpose: Specifies the interval between monitoring checks
# Why needed: Controls the frequency of monitoring data collection
# Impact: Determines how often monitoring checks are performed
# Value: Defaults to 30 seconds, accepts formats like '30s', '1m', '5m'

ALERT_EMAIL="admin@ecommerce.local"
# Purpose: Specifies the email address for alert notifications
# Why needed: Provides contact information for critical alerts
# Impact: Alerts are sent to this email address when thresholds are exceeded
# Value: Defaults to admin email, can be overridden via --email argument

LOG_LEVEL="INFO"
# Purpose: Specifies the logging level for monitoring operations
# Why needed: Controls the verbosity of monitoring output
# Impact: Determines which log messages are displayed
# Value: Levels: DEBUG, INFO, WARN, ERROR (default: INFO)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --namespace=*)
            NAMESPACE="${1#*=}"
            shift
            ;;
        --duration=*)
            DURATION="${1#*=}"
            shift
            ;;
        --interval=*)
            INTERVAL="${1#*=}"
            shift
            ;;
        --email=*)
            ALERT_EMAIL="${1#*=}"
            shift
            ;;
        --log-level=*)
            LOG_LEVEL="${1#*=}"
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

# Monitoring data
declare -A METRICS
declare -A ALERTS

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp and status formatting for
    # monitoring operations with comprehensive status level support.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps
    # Why needed: Ensures uniform logging format across all monitoring operations
    # Impact: All monitoring messages are formatted consistently and color-coded
    # Parameters:
    #   $1: Status level (INFO, SUCCESS, WARNING, ERROR, ALERT, HEADER)
    #   $2: Message text to display
    # Usage: print_status "INFO" "Monitoring application health"
    
    local status=$1
    # Purpose: Specifies the status level for message formatting
    # Why needed: Determines the color and prefix for the message
    # Impact: Controls visual appearance and message categorization
    # Parameter: $1 is the status level (e.g., "INFO", "SUCCESS", "WARNING", "ERROR")
    
    local message=$2
    # Purpose: Specifies the message text to display
    # Why needed: Contains the actual information to be logged
    # Impact: Provides the content for the status message
    # Parameter: $2 is the message text (e.g., "Monitoring application health")
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generate current timestamp for message logging
    # Why needed: Provides temporal context for monitoring events
    # Impact: All messages include timestamp for chronological tracking
    # Format: YYYY-MM-DD HH:MM:SS (e.g., "2024-01-15 14:30:25")
    
    # =============================================================================
    # STATUS LEVEL PROCESSING
    # =============================================================================
    # Purpose: Process different status levels with appropriate colors and formatting
    # Why needed: Provides visual distinction between different message types
    
    case $status in
        "INFO")
            # Purpose: Handle informational messages
            # Why needed: Displays general information in blue color
            # Impact: Info messages are displayed in blue for easy identification
            
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            # Purpose: Display info message with blue color and timestamp
            # Why needed: Provides visual distinction for informational content
            # Impact: User can easily identify info messages
            # ${BLUE}: Blue color code for info messages
            # ${NC}: No color code to reset terminal color
            ;;
        "SUCCESS")
            # Purpose: Handle success messages
            # Why needed: Displays successful operations in green color
            # Impact: Success messages are displayed in green for positive feedback
            
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            # Purpose: Display success message with green color and timestamp
            # Why needed: Provides visual distinction for successful operations
            # Impact: User can easily identify success messages
            # ${GREEN}: Green color code for success messages
            # ${NC}: No color code to reset terminal color
            ;;
        "WARNING")
            # Purpose: Handle warning messages
            # Why needed: Displays warnings in yellow color
            # Impact: Warning messages are displayed in yellow for attention
            
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            # Purpose: Display warning message with yellow color and timestamp
            # Why needed: Provides visual distinction for warning conditions
            # Impact: User can easily identify warning messages
            # ${YELLOW}: Yellow color code for warning messages
            # ${NC}: No color code to reset terminal color
            ;;
        "ERROR")
            # Purpose: Handle error messages
            # Why needed: Displays errors in red color
            # Impact: Error messages are displayed in red for critical attention
            
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            # Purpose: Display error message with red color and timestamp
            # Why needed: Provides visual distinction for error conditions
            # Impact: User can easily identify error messages
            # ${RED}: Red color code for error messages
            # ${NC}: No color code to reset terminal color
            ;;
        "ALERT")
            # Purpose: Handle alert messages
            # Why needed: Displays alerts in red color for critical attention
            # Impact: Alert messages are displayed in red for immediate attention
            
            echo -e "${RED}[ALERT]${NC} [${timestamp}] ${message}"
            # Purpose: Display alert message with red color and timestamp
            # Why needed: Provides visual distinction for alert conditions
            # Impact: User can easily identify alert messages
            # ${RED}: Red color code for alert messages
            # ${NC}: No color code to reset terminal color
            ;;
        "HEADER")
            # Purpose: Handle header messages
            # Why needed: Displays headers in purple color for section identification
            # Impact: Header messages are displayed in purple for section breaks
            
            echo -e "${PURPLE}[HEADER]${NC} [${timestamp}] ${message}"
            # Purpose: Display header message with purple color and timestamp
            # Why needed: Provides visual distinction for header content
            # Impact: User can easily identify header messages
            # ${PURPLE}: Purple color code for header messages
            # ${NC}: No color code to reset terminal color
            ;;
    esac
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Validates if a required command is available in the system PATH for
    # dependency checking and prerequisite validation during monitoring operations.
    # =============================================================================
    
    # Purpose: Validates if a required command is available in the system PATH
    # Why needed: Ensures all required tools are available before monitoring
    # Impact: Prevents monitoring failures due to missing dependencies
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
    # Validates all prerequisites for successful monitoring operations including tool
    # availability, cluster connectivity, and namespace existence.
    # =============================================================================
    
    # Purpose: Validate all prerequisites for monitoring operations
    # Why needed: Ensures monitoring can proceed without failures
    # Impact: Prevents monitoring failures due to missing dependencies
    # Parameters: None (uses global NAMESPACE variable)
    # Usage: check_prerequisites
    
    # =============================================================================
    # KUBECTL COMMAND AVAILABILITY CHECK
    # =============================================================================
    # Purpose: Verify kubectl command is available in system PATH
    # Why needed: kubectl is required for all monitoring operations
    
    if ! command_exists kubectl; then
        # Purpose: Check if kubectl command exists using command_exists function
        # Why needed: Validates kubectl availability before attempting to use it
        # Impact: If kubectl not found, monitoring cannot proceed
        
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
    # Why needed: Ensures cluster is accessible before monitoring
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # Purpose: Test cluster connectivity using kubectl cluster-info
        # Why needed: Validates cluster accessibility and kubeconfig validity
        # Impact: If cluster unreachable, monitoring cannot proceed
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
    # Why needed: Namespace is required for monitoring operations
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if target namespace exists
        # Why needed: Validates namespace availability before monitoring
        # Impact: If namespace doesn't exist, monitoring cannot proceed
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

# Function: Get pod metrics
get_pod_metrics() {
    # =============================================================================
    # GET POD METRICS FUNCTION
    # =============================================================================
    # Retrieves real-time resource usage metrics for pods with component filtering
    # and comprehensive resource monitoring capabilities.
    # =============================================================================
    
    # Purpose: Retrieve real-time pod resource usage metrics
    # Why needed: Provides visibility into pod resource consumption and performance
    # Impact: Users can monitor CPU and memory usage for troubleshooting
    # Parameters:
    #   $1: Component name to filter by (optional)
    # Returns: Pod metrics or "No metrics available" if unavailable
    # Usage: get_pod_metrics "backend"
    
    local component=$1
    # Purpose: Specifies the target component for metrics filtering
    # Why needed: Allows filtering metrics by specific component (backend, frontend, etc.)
    # Impact: When specified, only metrics for that component are retrieved
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # LABEL SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector for metrics retrieval
    # Why needed: Allows filtering to specific component pods
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application pods
    # Why needed: Provides default selector to find all e-commerce pods
    # Impact: All pods with app=ecommerce label will be included
    # Value: "app=ecommerce" matches the application label
    
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
    # METRICS RETRIEVAL
    # =============================================================================
    # Purpose: Execute kubectl command to get pod metrics
    # Why needed: Retrieves current resource usage information
    
    kubectl top pods -n "$NAMESPACE" -l "$selector" --no-headers 2>/dev/null || echo "No metrics available"
    # Purpose: Get pod resource usage metrics with error handling
    # Why needed: Shows current CPU and memory usage for pods
    # Impact: Displays pod metrics or fallback message if unavailable
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter pods
    # --no-headers: Removes column headers for cleaner output
    # 2>/dev/null: Suppresses error messages
    # || echo "No metrics available": Fallback message if command fails
}

# Function: Get node metrics
get_node_metrics() {
    # =============================================================================
    # GET NODE METRICS FUNCTION
    # =============================================================================
    # Retrieves real-time resource usage metrics for all cluster nodes with
    # comprehensive resource monitoring capabilities and error handling.
    # =============================================================================
    
    # Purpose: Retrieve real-time node resource usage metrics
    # Why needed: Provides visibility into node resource consumption and performance
    # Impact: Users can monitor CPU and memory usage at the node level
    # Parameters: None
    # Returns: Node metrics or "No metrics available" if unavailable
    # Usage: get_node_metrics
    
    kubectl top nodes --no-headers 2>/dev/null || echo "No metrics available"
    # Purpose: Get node resource usage metrics with error handling
    # Why needed: Shows current CPU and memory usage for all cluster nodes
    # Impact: Displays node metrics or fallback message if unavailable
    # --no-headers: Removes column headers for cleaner output
    # 2>/dev/null: Suppresses error messages
    # || echo "No metrics available": Fallback message if command fails
}

# Function: Get resource usage
get_resource_usage() {
    # =============================================================================
    # GET RESOURCE USAGE FUNCTION
    # =============================================================================
    # Retrieves and displays comprehensive resource usage metrics for both pods
    # and nodes with component filtering and comprehensive monitoring capabilities.
    # =============================================================================
    
    # Purpose: Display comprehensive resource usage metrics for pods and nodes
    # Why needed: Provides complete visibility into resource consumption
    # Impact: Users can monitor resource usage across all components
    # Parameters:
    #   $1: Component name to filter by (optional)
    # Usage: get_resource_usage "backend"
    
    local component=$1
    # Purpose: Specifies the target component for resource usage filtering
    # Why needed: Allows filtering resource usage by specific component
    # Impact: When specified, only metrics for that component are shown
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # RESOURCE USAGE INITIATION
    # =============================================================================
    # Purpose: Display resource usage header and initiate monitoring
    # Why needed: Provides context for resource usage monitoring
    
    print_status "INFO" "Resource usage for component: ${component:-all}"
    # Purpose: Log informational message about resource usage monitoring
    # Why needed: Informs user which component is being monitored
    # Impact: User knows the scope of resource usage monitoring
    # ${component:-all}: Shows component name or "all" if not specified
    
    # =============================================================================
    # POD METRICS RETRIEVAL
    # =============================================================================
    # Purpose: Retrieve and display pod resource usage metrics
    # Why needed: Provides visibility into pod-level resource consumption
    
    local pod_metrics
    # Purpose: Variable to store pod metrics data
    # Why needed: Provides storage for pod metrics before processing
    # Impact: Used to determine if pod metrics are available
    
    pod_metrics=$(get_pod_metrics "$component")
    # Purpose: Retrieve pod metrics using get_pod_metrics function
    # Why needed: Gets current pod resource usage information
    # Impact: Provides pod metrics data for display
    # $component: Passes component filter to get_pod_metrics
    
    if [ "$pod_metrics" != "No metrics available" ]; then
        # Purpose: Check if pod metrics are available
        # Why needed: Validates that pod metrics were successfully retrieved
        # Impact: If metrics available, display them; otherwise show warning
        
        echo "POD METRICS:"
        # Purpose: Display pod metrics section header
        # Why needed: Identifies the pod metrics section
        # Impact: User knows the following data is pod metrics
        
        echo "$pod_metrics"
        # Purpose: Display the actual pod metrics data
        # Why needed: Shows current pod resource usage
        # Impact: User can see CPU and memory usage for pods
    else
        # Purpose: Handle case when pod metrics are not available
        # Why needed: Provides graceful handling when metrics unavailable
        # Impact: If metrics not available, show warning but continue
        
        print_status "WARNING" "Pod metrics not available"
        # Purpose: Log warning message about unavailable pod metrics
        # Why needed: Informs user that pod metrics could not be retrieved
        # Impact: User knows pod metrics are not available
    fi
    
    # =============================================================================
    # NODE METRICS RETRIEVAL
    # =============================================================================
    # Purpose: Retrieve and display node resource usage metrics
    # Why needed: Provides visibility into node-level resource consumption
    
    local node_metrics
    # Purpose: Variable to store node metrics data
    # Why needed: Provides storage for node metrics before processing
    # Impact: Used to determine if node metrics are available
    
    node_metrics=$(get_node_metrics)
    # Purpose: Retrieve node metrics using get_node_metrics function
    # Why needed: Gets current node resource usage information
    # Impact: Provides node metrics data for display
    
    if [ "$node_metrics" != "No metrics available" ]; then
        # Purpose: Check if node metrics are available
        # Why needed: Validates that node metrics were successfully retrieved
        # Impact: If metrics available, display them; otherwise show warning
        
        echo "NODE METRICS:"
        # Purpose: Display node metrics section header
        # Why needed: Identifies the node metrics section
        # Impact: User knows the following data is node metrics
        
        echo "$node_metrics"
        # Purpose: Display the actual node metrics data
        # Why needed: Shows current node resource usage
        # Impact: User can see CPU and memory usage for nodes
    else
        # Purpose: Handle case when node metrics are not available
        # Why needed: Provides graceful handling when metrics unavailable
        # Impact: If metrics not available, show warning but continue
        
        print_status "WARNING" "Node metrics not available"
        # Purpose: Log warning message about unavailable node metrics
        # Why needed: Informs user that node metrics could not be retrieved
        # Impact: User knows node metrics are not available
    fi
}

# Function: Check pod health
check_pod_health() {
    # =============================================================================
    # CHECK POD HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of pods with component filtering and comprehensive
    # health monitoring capabilities including alert generation for unhealthy pods.
    # =============================================================================
    
    # Purpose: Check health status of pods for a specific component
    # Why needed: Ensures all pods are running and healthy
    # Impact: Identifies unhealthy pods and generates alerts
    # Parameters:
    #   $1: Component name to filter by (optional)
    # Returns: 0 if all pods healthy, 1 if unhealthy pods found
    # Usage: check_pod_health "backend"
    
    local component=$1
    # Purpose: Specifies the target component for pod health checking
    # Why needed: Allows filtering pod health checks by specific component
    # Impact: When specified, only pods for that component are checked
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # LABEL SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector for pod health checking
    # Why needed: Allows filtering to specific component pods
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application pods
    # Why needed: Provides default selector to find all e-commerce pods
    # Impact: All pods with app=ecommerce label will be checked
    # Value: "app=ecommerce" matches the application label
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters pods to only those matching the specified component
        # Impact: Only pods with both app=ecommerce and component=<component> labels are checked
        # Format: "app=ecommerce,component=backend" for backend pods
    fi
    
    # =============================================================================
    # UNHEALTHY POD DETECTION
    # =============================================================================
    # Purpose: Identify pods that are not in Running state
    # Why needed: Detects unhealthy pods for alerting and troubleshooting
    
    local unhealthy_pods
    # Purpose: Variable to store list of unhealthy pod names
    # Why needed: Provides list of unhealthy pods for alerting
    # Impact: Used to determine if any pods are unhealthy
    
    unhealthy_pods=$(kubectl get pods -n "$NAMESPACE" -l "$selector" --field-selector=status.phase!=Running -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get names of pods that are not in Running state
    # Why needed: Identifies unhealthy pods for alerting and troubleshooting
    # Impact: Provides list of pod names that need attention
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter pods
    # --field-selector=status.phase!=Running: Selects only non-running pods
    # -o jsonpath: Extracts only the pod names from JSON output
    # .items[*].metadata.name: JSONPath to extract pod names
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # HEALTH STATUS EVALUATION
    # =============================================================================
    # Purpose: Evaluate pod health and generate appropriate alerts
    # Why needed: Provides health status feedback and alerting
    
    if [ -n "$unhealthy_pods" ]; then
        # Purpose: Check if any unhealthy pods were found
        # Why needed: Determines if alerting is required
        # Impact: If unhealthy pods found, generate alert and return error
        
        print_status "ALERT" "Unhealthy pods found: $unhealthy_pods"
        # Purpose: Log alert message about unhealthy pods
        # Why needed: Informs user about unhealthy pod status
        # Impact: User knows which pods are unhealthy and need attention
        
        ALERTS["unhealthy_pods"]="$unhealthy_pods"
        # Purpose: Store unhealthy pod names in alerts array
        # Why needed: Provides persistent storage for alert information
        # Impact: Enables alert tracking and reporting
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates pod health check failure
        # Impact: Function terminates with error status
    else
        # Purpose: Handle case when all pods are healthy
        # Why needed: Provides positive feedback when no issues found
        # Impact: If no unhealthy pods found, log success and return success
        
        print_status "SUCCESS" "All pods are healthy"
        # Purpose: Log success message about pod health
        # Why needed: Confirms that all pods are running properly
        # Impact: User knows all pods are healthy
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates successful pod health check
        # Impact: Function completes successfully with healthy pods
    fi
}

# Function: Check service health
check_service_health() {
    # =============================================================================
    # CHECK SERVICE HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of services with component filtering and comprehensive
    # endpoint validation including alert generation for services without endpoints.
    # =============================================================================
    
    # Purpose: Check health status of services for a specific component
    # Why needed: Ensures all services have healthy endpoints
    # Impact: Identifies services without endpoints and generates alerts
    # Parameters:
    #   $1: Component name to filter by (optional)
    # Returns: 0 if all services healthy, 1 if unhealthy services found
    # Usage: check_service_health "backend"
    
    local component=$1
    # Purpose: Specifies the target component for service health checking
    # Why needed: Allows filtering service health checks by specific component
    # Impact: When specified, only services for that component are checked
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # LABEL SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector for service health checking
    # Why needed: Allows filtering to specific component services
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application services
    # Why needed: Provides default selector to find all e-commerce services
    # Impact: All services with app=ecommerce label will be checked
    # Value: "app=ecommerce" matches the application label
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters services to only those matching the specified component
        # Impact: Only services with both app=ecommerce and component=<component> labels are checked
        # Format: "app=ecommerce,component=backend" for backend services
    fi
    
    # =============================================================================
    # SERVICE DISCOVERY
    # =============================================================================
    # Purpose: Get list of services to check
    # Why needed: Identifies which services need health validation
    
    local services
    # Purpose: Variable to store list of service names
    # Why needed: Provides list of services to iterate through
    # Impact: Used to determine which services to check
    
    services=$(kubectl get services -n "$NAMESPACE" -l "$selector" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get names of services matching the selector
    # Why needed: Identifies services that need health checking
    # Impact: Provides list of service names for validation
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter services
    # -o jsonpath: Extracts only the service names from JSON output
    # .items[*].metadata.name: JSONPath to extract service names
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # ENDPOINT VALIDATION
    # =============================================================================
    # Purpose: Check each service for healthy endpoints
    # Why needed: Ensures services can route traffic to pods
    
    for service in $services; do
        # Purpose: Iterate through each service found
        # Why needed: Validates endpoint health for each service
        # Impact: Processes each service individually for health checking
        
        local endpoints
        # Purpose: Variable to store endpoint IPs for current service
        # Why needed: Provides endpoint information for validation
        # Impact: Used to determine if service has healthy endpoints
        
        endpoints=$(kubectl get endpoints -n "$NAMESPACE" "$service" -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
        # Purpose: Get endpoint IPs for the current service
        # Why needed: Validates that service has healthy endpoints
        # Impact: Provides list of endpoint IPs for the service
        # -n: Specifies the target namespace
        # $service: Target service for endpoint checking
        # -o jsonpath: Extracts only the IP addresses from JSON output
        # .subsets[0].addresses[*].ip: JSONPath to extract IP addresses
        # 2>/dev/null: Suppresses error messages
        
        if [ -z "$endpoints" ]; then
            # Purpose: Check if service has no endpoints
            # Why needed: Identifies services that cannot route traffic
            # Impact: If no endpoints found, generate alert and return error
            
            print_status "ALERT" "Service $service has no endpoints"
            # Purpose: Log alert message about service without endpoints
            # Why needed: Informs user about service endpoint issue
            # Impact: User knows which service has no endpoints
            
            ALERTS["no_endpoints"]="$service"
            # Purpose: Store service name in alerts array
            # Why needed: Provides persistent storage for alert information
            # Impact: Enables alert tracking and reporting
            
            return 1
            # Purpose: Exit function with error code 1
            # Why needed: Indicates service health check failure
            # Impact: Function terminates with error status
        fi
    done
    
    # =============================================================================
    # HEALTH STATUS CONFIRMATION
    # =============================================================================
    # Purpose: Confirm all services have healthy endpoints
    # Why needed: Provides positive feedback when no issues found
    
    print_status "SUCCESS" "All services have endpoints"
    # Purpose: Log success message about service health
    # Why needed: Confirms that all services have healthy endpoints
    # Impact: User knows all services are healthy
    
    return 0
    # Purpose: Exit function with success code 0
    # Why needed: Indicates successful service health check
    # Impact: Function completes successfully with healthy services
}

# Function: Check resource limits
check_resource_limits() {
    # =============================================================================
    # CHECK RESOURCE LIMITS FUNCTION
    # =============================================================================
    # Monitors resource usage against configured limits with component filtering and
    # comprehensive resource monitoring capabilities including alert generation.
    # =============================================================================
    
    # Purpose: Check resource usage against configured limits for pods
    # Why needed: Ensures pods don't exceed resource limits
    # Impact: Identifies pods with high resource usage and generates alerts
    # Parameters:
    #   $1: Component name to filter by (optional)
    # Usage: check_resource_limits "backend"
    
    local component=$1
    # Purpose: Specifies the target component for resource limit checking
    # Why needed: Allows filtering resource limit checks by specific component
    # Impact: When specified, only pods for that component are checked
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    # =============================================================================
    # LABEL SELECTOR CONSTRUCTION
    # =============================================================================
    # Purpose: Build component-specific selector for resource limit checking
    # Why needed: Allows filtering to specific component pods
    
    local selector="app=ecommerce"
    # Purpose: Base label selector for e-commerce application pods
    # Why needed: Provides default selector to find all e-commerce pods
    # Impact: All pods with app=ecommerce label will be checked
    # Value: "app=ecommerce" matches the application label
    
    if [ -n "$component" ]; then
        # Purpose: Check if component parameter is provided
        # Why needed: Only modify selector if component is specified
        # Impact: If component provided, filter to that specific component
        
        selector="app=ecommerce,component=$component"
        # Purpose: Create component-specific label selector
        # Why needed: Filters pods to only those matching the specified component
        # Impact: Only pods with both app=ecommerce and component=<component> labels are checked
        # Format: "app=ecommerce,component=backend" for backend pods
    fi
    
    # =============================================================================
    # POD DISCOVERY
    # =============================================================================
    # Purpose: Get list of pods to check for resource limits
    # Why needed: Identifies which pods need resource limit validation
    
    local pods
    # Purpose: Variable to store list of pod names
    # Why needed: Provides list of pods to iterate through
    # Impact: Used to determine which pods to check for resource limits
    
    pods=$(kubectl get pods -n "$NAMESPACE" -l "$selector" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get names of pods matching the selector
    # Why needed: Identifies pods that need resource limit checking
    # Impact: Provides list of pod names for resource validation
    # -n: Specifies the target namespace
    # -l: Uses label selector to filter pods
    # -o jsonpath: Extracts only the pod names from JSON output
    # .items[*].metadata.name: JSONPath to extract pod names
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # RESOURCE USAGE MONITORING
    # =============================================================================
    # Purpose: Check each pod for resource usage against limits
    # Why needed: Ensures pods don't exceed configured resource limits
    
    for pod in $pods; do
        # Purpose: Iterate through each pod found
        # Why needed: Validates resource usage for each pod
        # Impact: Processes each pod individually for resource limit checking
        
        local cpu_usage
        # Purpose: Variable to store CPU usage for current pod
        # Why needed: Provides CPU usage data for limit validation
        # Impact: Used to determine if pod exceeds CPU limits
        
        local memory_usage
        # Purpose: Variable to store memory usage for current pod
        # Why needed: Provides memory usage data for limit validation
        # Impact: Used to determine if pod exceeds memory limits
        
        cpu_usage=$(kubectl top pod -n "$NAMESPACE" "$pod" --no-headers 2>/dev/null | awk '{print $2}' | sed 's/m//' || echo "0")
        # Purpose: Get CPU usage for the current pod
        # Why needed: Validates CPU usage against configured limits
        # Impact: Provides CPU usage data for limit checking
        # kubectl top pod: Gets resource usage for specific pod
        # -n: Specifies the target namespace
        # $pod: Target pod for resource checking
        # --no-headers: Removes column headers for cleaner output
        # awk '{print $2}': Extracts CPU usage column
        # sed 's/m//': Removes 'm' suffix from CPU usage
        # || echo "0": Fallback to 0 if command fails
        # 2>/dev/null: Suppresses error messages
        
        memory_usage=$(kubectl top pod -n "$NAMESPACE" "$pod" --no-headers 2>/dev/null | awk '{print $3}' | sed 's/Mi//' || echo "0")
        # Purpose: Get memory usage for the current pod
        # Why needed: Validates memory usage against configured limits
        # Impact: Provides memory usage data for limit checking
        # kubectl top pod: Gets resource usage for specific pod
        # -n: Specifies the target namespace
        # $pod: Target pod for resource checking
        # --no-headers: Removes column headers for cleaner output
        # awk '{print $3}': Extracts memory usage column
        # sed 's/Mi//': Removes 'Mi' suffix from memory usage
        # || echo "0": Fallback to 0 if command fails
        # 2>/dev/null: Suppresses error messages
        
        # =============================================================================
        # CPU LIMIT VALIDATION
        # =============================================================================
        # Purpose: Check CPU usage against configured limits
        # Why needed: Ensures pods don't exceed CPU resource limits
        
        if [ "$cpu_usage" -gt 400 ]; then
            # Purpose: Check if CPU usage exceeds threshold (400m)
            # Why needed: Identifies pods with high CPU usage
            # Impact: If CPU usage high, generate alert
            # Threshold: 400m (80% of assumed 500m limit)
            
            print_status "ALERT" "Pod $pod has high CPU usage: ${cpu_usage}m"
            # Purpose: Log alert message about high CPU usage
            # Why needed: Informs user about high CPU usage
            # Impact: User knows which pod has high CPU usage
            
            ALERTS["high_cpu"]="$pod:${cpu_usage}m"
            # Purpose: Store high CPU usage information in alerts array
            # Why needed: Provides persistent storage for alert information
            # Impact: Enables alert tracking and reporting
        fi
        
        # =============================================================================
        # MEMORY LIMIT VALIDATION
        # =============================================================================
        # Purpose: Check memory usage against configured limits
        # Why needed: Ensures pods don't exceed memory resource limits
        
        if [ "$memory_usage" -gt 400 ]; then
            # Purpose: Check if memory usage exceeds threshold (400Mi)
            # Why needed: Identifies pods with high memory usage
            # Impact: If memory usage high, generate alert
            # Threshold: 400Mi (78% of assumed 512Mi limit)
            
            print_status "ALERT" "Pod $pod has high memory usage: ${memory_usage}Mi"
            # Purpose: Log alert message about high memory usage
            # Why needed: Informs user about high memory usage
            # Impact: User knows which pod has high memory usage
            
            ALERTS["high_memory"]="$pod:${memory_usage}Mi"
            # Purpose: Store high memory usage information in alerts array
            # Why needed: Provides persistent storage for alert information
            # Impact: Enables alert tracking and reporting
        fi
    done
}

# Function: Check disk space
check_disk_space() {
    # =============================================================================
    # CHECK DISK SPACE FUNCTION
    # =============================================================================
    # Monitors disk space usage across all cluster nodes with comprehensive
    # disk monitoring capabilities and alert generation for high usage.
    # =============================================================================
    
    # Purpose: Check disk space usage on all cluster nodes
    # Why needed: Ensures nodes have sufficient disk space for operations
    # Impact: Identifies nodes with high disk usage and generates alerts
    # Parameters: None
    # Usage: check_disk_space
    
    # =============================================================================
    # NODE DISCOVERY
    # =============================================================================
    # Purpose: Get list of all cluster nodes
    # Why needed: Identifies which nodes need disk space checking
    
    local nodes
    # Purpose: Variable to store list of node names
    # Why needed: Provides list of nodes to iterate through
    # Impact: Used to determine which nodes to check for disk space
    
    nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get names of all cluster nodes
    # Why needed: Identifies nodes that need disk space checking
    # Impact: Provides list of node names for disk space validation
    # kubectl get nodes: Lists all cluster nodes
    # -o jsonpath: Extracts only the node names from JSON output
    # .items[*].metadata.name: JSONPath to extract node names
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # DISK SPACE MONITORING
    # =============================================================================
    # Purpose: Check disk space usage on each node
    # Why needed: Ensures nodes have sufficient disk space for operations
    
    for node in $nodes; do
        # Purpose: Iterate through each node found
        # Why needed: Validates disk space for each node
        # Impact: Processes each node individually for disk space checking
        
        local disk_usage
        # Purpose: Variable to store disk usage percentage for current node
        # Why needed: Provides disk usage data for threshold validation
        # Impact: Used to determine if node exceeds disk space threshold
        
        disk_usage=$(kubectl describe node "$node" 2>/dev/null | grep -A 5 "Allocated resources" | grep "ephemeral-storage" | awk '{print $2}' | sed 's/%//' || echo "0")
        # Purpose: Get disk usage percentage for the current node
        # Why needed: Validates disk usage against configured threshold
        # Impact: Provides disk usage data for threshold checking
        # kubectl describe node: Gets detailed information about specific node
        # $node: Target node for disk space checking
        # grep -A 5 "Allocated resources": Gets 5 lines after "Allocated resources"
        # grep "ephemeral-storage": Filters for ephemeral storage information
        # awk '{print $2}': Extracts the usage percentage column
        # sed 's/%//': Removes '%' suffix from usage percentage
        # || echo "0": Fallback to 0 if command fails
        # 2>/dev/null: Suppresses error messages
        
        if [ "$disk_usage" -gt 80 ]; then
            # Purpose: Check if disk usage exceeds threshold (80%)
            # Why needed: Identifies nodes with high disk usage
            # Impact: If disk usage high, generate alert
            # Threshold: 80% (warning level for disk space)
            
            print_status "ALERT" "Node $node has high disk usage: ${disk_usage}%"
            # Purpose: Log alert message about high disk usage
            # Why needed: Informs user about high disk usage
            # Impact: User knows which node has high disk usage
            
            ALERTS["high_disk"]="$node:${disk_usage}%"
            # Purpose: Store high disk usage information in alerts array
            # Why needed: Provides persistent storage for alert information
            # Impact: Enables alert tracking and reporting
        fi
    done
}

# Function: Check Prometheus targets
check_prometheus_targets() {
    # =============================================================================
    # CHECK PROMETHEUS TARGETS FUNCTION
    # =============================================================================
    # Validates Prometheus target health status with comprehensive monitoring
    # capabilities and alert generation for down targets.
    # =============================================================================
    
    # Purpose: Check health status of Prometheus monitoring targets
    # Why needed: Ensures all monitoring targets are healthy and collecting metrics
    # Impact: Identifies down targets and generates alerts
    # Parameters: None
    # Usage: check_prometheus_targets
    
    # =============================================================================
    # PROMETHEUS POD DISCOVERY
    # =============================================================================
    # Purpose: Find the Prometheus pod for target checking
    # Why needed: Identifies which Prometheus pod to query for target status
    
    local prometheus_pod
    # Purpose: Variable to store Prometheus pod name
    # Why needed: Provides pod name for executing commands
    # Impact: Used to determine which pod to query for target status
    
    prometheus_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=prometheus" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first Prometheus pod
    # Why needed: Identifies Prometheus pod for target status checking
    # Impact: Provides pod name for target health validation
    # kubectl get pods: Lists pods in the namespace
    # -n: Specifies the target namespace
    # -l "app=prometheus": Filters for Prometheus pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # TARGET HEALTH VALIDATION
    # =============================================================================
    # Purpose: Check Prometheus target health status
    # Why needed: Ensures all monitoring targets are healthy
    
    if [ -n "$prometheus_pod" ]; then
        # Purpose: Check if Prometheus pod was found
        # Why needed: Only proceed if Prometheus pod is available
        # Impact: If pod found, check targets; otherwise show warning
        
        local targets
        # Purpose: Variable to store list of down targets
        # Why needed: Provides list of unhealthy targets for alerting
        # Impact: Used to determine if any targets are down
        
        targets=$(kubectl exec -n "$NAMESPACE" "$prometheus_pod" -- wget -qO- "http://localhost:9090/api/v1/targets" 2>/dev/null | jq -r '.data.activeTargets[] | select(.health != "up") | .labels.job' 2>/dev/null || echo "")
        # Purpose: Get list of down Prometheus targets
        # Why needed: Identifies targets that are not healthy
        # Impact: Provides list of down targets for alerting
        # kubectl exec: Execute command in Prometheus pod
        # -n: Specifies the target namespace
        # $prometheus_pod: Target pod for command execution
        # -- wget -qO-: Download content quietly to stdout
        # "http://localhost:9090/api/v1/targets": Prometheus targets API endpoint
        # jq -r: Parse JSON and extract raw strings
        # '.data.activeTargets[] | select(.health != "up") | .labels.job': JSONPath to get job names of down targets
        # || echo "": Fallback to empty string if command fails
        # 2>/dev/null: Suppresses error messages
        
        if [ -n "$targets" ]; then
            # Purpose: Check if any targets are down
            # Why needed: Determines if alerting is required
            # Impact: If targets down, generate alert; otherwise show success
            
            print_status "ALERT" "Prometheus targets down: $targets"
            # Purpose: Log alert message about down targets
            # Why needed: Informs user about unhealthy targets
            # Impact: User knows which targets are down
            
            ALERTS["prometheus_targets"]="$targets"
            # Purpose: Store down targets information in alerts array
            # Why needed: Provides persistent storage for alert information
            # Impact: Enables alert tracking and reporting
        else
            # Purpose: Handle case when all targets are healthy
            # Why needed: Provides positive feedback when no issues found
            # Impact: If no targets down, log success message
            
            print_status "SUCCESS" "All Prometheus targets are up"
            # Purpose: Log success message about target health
            # Why needed: Confirms that all targets are healthy
            # Impact: User knows all Prometheus targets are working
        fi
    else
        # Purpose: Handle case when Prometheus pod is not found
        # Why needed: Provides graceful handling when Prometheus unavailable
        # Impact: If pod not found, show warning but continue
        
        print_status "WARNING" "Prometheus pod not found"
        # Purpose: Log warning message about missing Prometheus pod
        # Why needed: Informs user that Prometheus pod could not be found
        # Impact: User knows Prometheus pod is not available
    fi
}

# Function: Check Grafana health
check_grafana_health() {
    # =============================================================================
    # CHECK GRAFANA HEALTH FUNCTION
    # =============================================================================
    # Validates Grafana service health and accessibility with comprehensive
    # monitoring capabilities and alert generation for service unavailability.
    # =============================================================================
    
    # Purpose: Check health and accessibility of Grafana service
    # Why needed: Ensures Grafana dashboard is accessible for monitoring
    # Impact: Identifies Grafana service issues and generates alerts
    # Parameters: None
    # Usage: check_grafana_health
    
    # =============================================================================
    # GRAFANA POD DISCOVERY
    # =============================================================================
    # Purpose: Find the Grafana pod for health checking
    # Why needed: Identifies which Grafana pod to check for health status
    
    local grafana_pod
    # Purpose: Variable to store Grafana pod name
    # Why needed: Provides pod name for health checking
    # Impact: Used to determine which pod to check for health
    
    grafana_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=grafana" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first Grafana pod
    # Why needed: Identifies Grafana pod for health checking
    # Impact: Provides pod name for health validation
    # kubectl get pods: Lists pods in the namespace
    # -n: Specifies the target namespace
    # -l "app=grafana": Filters for Grafana pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # GRAFANA SERVICE VALIDATION
    # =============================================================================
    # Purpose: Check Grafana service health and accessibility
    # Why needed: Ensures Grafana service is accessible
    
    if [ -n "$grafana_pod" ]; then
        # Purpose: Check if Grafana pod was found
        # Why needed: Only proceed if Grafana pod is available
        # Impact: If pod found, check service; otherwise show warning
        
        local grafana_url
        # Purpose: Variable to store Grafana service ClusterIP
        # Why needed: Provides service URL for accessibility testing
        # Impact: Used to determine Grafana service endpoint
        
        grafana_url=$(kubectl get service -n "$NAMESPACE" grafana-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
        # Purpose: Get ClusterIP of Grafana service
        # Why needed: Provides service endpoint for accessibility testing
        # Impact: Provides service URL for health checking
        # kubectl get service: Gets service information
        # -n: Specifies the target namespace
        # grafana-service: Target service name
        # -o jsonpath: Extracts only the ClusterIP from JSON output
        # .spec.clusterIP: JSONPath to extract ClusterIP
        # 2>/dev/null: Suppresses error messages
        
        if [ -n "$grafana_url" ]; then
            # Purpose: Check if Grafana service URL was found
            # Why needed: Only proceed if service URL is available
            # Impact: If URL found, test accessibility; otherwise skip
            
            if kubectl run grafana-check --rm -i --restart=Never --image=curlimages/curl:latest -- \
                curl -f -s --max-time 10 "http://${grafana_url}:3000" >/dev/null 2>&1; then
                # Purpose: Test Grafana service accessibility using temporary pod
                # Why needed: Validates that Grafana service is accessible
                # Impact: If accessible, log success; otherwise generate alert
                # kubectl run: Create temporary pod for testing
                # grafana-check: Name of temporary pod
                # --rm: Remove pod after completion
                # -i: Interactive mode
                # --restart=Never: Don't restart pod
                # --image=curlimages/curl:latest: Use curl image for testing
                # curl -f: Fail on HTTP error codes
                # -s: Silent mode
                # --max-time 10: Maximum time for request (10 seconds)
                # "http://${grafana_url}:3000": Grafana service endpoint
                # >/dev/null 2>&1: Suppress all output
                
                print_status "SUCCESS" "Grafana is accessible"
                # Purpose: Log success message about Grafana accessibility
                # Why needed: Confirms that Grafana service is working
                # Impact: User knows Grafana is accessible
            else
                # Purpose: Handle case when Grafana is not accessible
                # Why needed: Provides alert when service is unavailable
                # Impact: If not accessible, generate alert
                
                print_status "ALERT" "Grafana is not accessible"
                # Purpose: Log alert message about Grafana inaccessibility
                # Why needed: Informs user about Grafana service issue
                # Impact: User knows Grafana is not accessible
                
                ALERTS["grafana_down"]="true"
                # Purpose: Store Grafana down status in alerts array
                # Why needed: Provides persistent storage for alert information
                # Impact: Enables alert tracking and reporting
            fi
        fi
    else
        # Purpose: Handle case when Grafana pod is not found
        # Why needed: Provides graceful handling when Grafana unavailable
        # Impact: If pod not found, show warning but continue
        
        print_status "WARNING" "Grafana pod not found"
        # Purpose: Log warning message about missing Grafana pod
        # Why needed: Informs user that Grafana pod could not be found
        # Impact: User knows Grafana pod is not available
    fi
}

# Function: Check AlertManager health
check_alertmanager_health() {
    # =============================================================================
    # CHECK ALERTMANAGER HEALTH FUNCTION
    # =============================================================================
    # Validates AlertManager service health and accessibility with comprehensive
    # monitoring capabilities and alert generation for service unavailability.
    # =============================================================================
    
    # Purpose: Check health and accessibility of AlertManager service
    # Why needed: Ensures AlertManager is accessible for alert processing
    # Impact: Identifies AlertManager service issues and generates alerts
    # Parameters: None
    # Usage: check_alertmanager_health
    
    # =============================================================================
    # ALERTMANAGER POD DISCOVERY
    # =============================================================================
    # Purpose: Find the AlertManager pod for health checking
    # Why needed: Identifies which AlertManager pod to check for health status
    
    local alertmanager_pod
    # Purpose: Variable to store AlertManager pod name
    # Why needed: Provides pod name for health checking
    # Impact: Used to determine which pod to check for health
    
    alertmanager_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=alertmanager" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first AlertManager pod
    # Why needed: Identifies AlertManager pod for health checking
    # Impact: Provides pod name for health validation
    # kubectl get pods: Lists pods in the namespace
    # -n: Specifies the target namespace
    # -l "app=alertmanager": Filters for AlertManager pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppresses error messages
    
    # =============================================================================
    # ALERTMANAGER SERVICE VALIDATION
    # =============================================================================
    # Purpose: Check AlertManager service health and accessibility
    # Why needed: Ensures AlertManager service is accessible
    
    if [ -n "$alertmanager_pod" ]; then
        # Purpose: Check if AlertManager pod was found
        # Why needed: Only proceed if AlertManager pod is available
        # Impact: If pod found, check service; otherwise show warning
        
        local alertmanager_url
        # Purpose: Variable to store AlertManager service ClusterIP
        # Why needed: Provides service URL for accessibility testing
        # Impact: Used to determine AlertManager service endpoint
        
        alertmanager_url=$(kubectl get service -n "$NAMESPACE" alertmanager-service -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
        # Purpose: Get ClusterIP of AlertManager service
        # Why needed: Provides service endpoint for accessibility testing
        # Impact: Provides service URL for health checking
        # kubectl get service: Gets service information
        # -n: Specifies the target namespace
        # alertmanager-service: Target service name
        # -o jsonpath: Extracts only the ClusterIP from JSON output
        # .spec.clusterIP: JSONPath to extract ClusterIP
        # 2>/dev/null: Suppresses error messages
        
        if [ -n "$alertmanager_url" ]; then
            # Purpose: Check if AlertManager service URL was found
            # Why needed: Only proceed if service URL is available
            # Impact: If URL found, test accessibility; otherwise skip
            
            if kubectl run alertmanager-check --rm -i --restart=Never --image=curlimages/curl:latest -- \
                curl -f -s --max-time 10 "http://${alertmanager_url}:9093" >/dev/null 2>&1; then
                # Purpose: Test AlertManager service accessibility using temporary pod
                # Why needed: Validates that AlertManager service is accessible
                # Impact: If accessible, log success; otherwise generate alert
                # kubectl run: Create temporary pod for testing
                # alertmanager-check: Name of temporary pod
                # --rm: Remove pod after completion
                # -i: Interactive mode
                # --restart=Never: Don't restart pod
                # --image=curlimages/curl:latest: Use curl image for testing
                # curl -f: Fail on HTTP error codes
                # -s: Silent mode
                # --max-time 10: Maximum time for request (10 seconds)
                # "http://${alertmanager_url}:9093": AlertManager service endpoint
                # >/dev/null 2>&1: Suppress all output
                
                print_status "SUCCESS" "AlertManager is accessible"
                # Purpose: Log success message about AlertManager accessibility
                # Why needed: Confirms that AlertManager service is working
                # Impact: User knows AlertManager is accessible
            else
                # Purpose: Handle case when AlertManager is not accessible
                # Why needed: Provides alert when service is unavailable
                # Impact: If not accessible, generate alert
                
                print_status "ALERT" "AlertManager is not accessible"
                # Purpose: Log alert message about AlertManager inaccessibility
                # Why needed: Informs user about AlertManager service issue
                # Impact: User knows AlertManager is not accessible
                
                ALERTS["alertmanager_down"]="true"
                # Purpose: Store AlertManager down status in alerts array
                # Why needed: Provides persistent storage for alert information
                # Impact: Enables alert tracking and reporting
            fi
        fi
    else
        # Purpose: Handle case when AlertManager pod is not found
        # Why needed: Provides graceful handling when AlertManager unavailable
        # Impact: If pod not found, show warning but continue
        
        print_status "WARNING" "AlertManager pod not found"
        # Purpose: Log warning message about missing AlertManager pod
        # Why needed: Informs user that AlertManager pod could not be found
        # Impact: User knows AlertManager pod is not available
    fi
}

# Function: Send alert
send_alert() {
    # =============================================================================
    # SEND ALERT FUNCTION
    # =============================================================================
    # Sends alerts through multiple channels with comprehensive alerting
    # capabilities including logging and email notifications.
    # =============================================================================
    
    # Purpose: Send alerts through multiple notification channels
    # Why needed: Ensures alerts reach administrators through various means
    # Impact: Provides multiple alert delivery methods for reliability
    # Parameters:
    #   $1: Alert type (e.g., "HIGH_CPU", "POD_DOWN")
    #   $2: Alert message describing the issue
    # Usage: send_alert "HIGH_CPU" "Pod backend-1 has high CPU usage"
    
    local alert_type=$1
    # Purpose: Specifies the type/category of alert
    # Why needed: Categorizes alerts for better organization and filtering
    # Impact: Helps administrators understand the nature of the alert
    # Parameter: $1 is the alert type (e.g., "HIGH_CPU", "POD_DOWN", "SERVICE_UNAVAILABLE")
    
    local message=$2
    # Purpose: Contains the detailed alert message
    # Why needed: Provides specific information about the alert
    # Impact: Gives administrators actionable information about the issue
    # Parameter: $2 is the alert message describing the specific issue
    
    # =============================================================================
    # ALERT INITIATION
    # =============================================================================
    # Purpose: Log alert initiation and begin alert processing
    # Why needed: Provides visibility into alert sending process
    
    print_status "ALERT" "Sending alert: $message"
    # Purpose: Log alert initiation message
    # Why needed: Informs user that alert is being sent
    # Impact: User knows alert is being processed
    # $message: Shows the alert message being sent
    
    # =============================================================================
    # ALERT LOGGING
    # =============================================================================
    # Purpose: Log alerts to file for audit and debugging
    # Why needed: Provides persistent record of all alerts
    
    echo "ALERT: $alert_type - $message" >> "/tmp/alerts_$(date +%Y%m%d).log"
    # Purpose: Log alert to daily log file
    # Why needed: Creates persistent record of alerts for audit trail
    # Impact: Provides historical record of all alerts sent
    # echo: Output alert information
    # "ALERT: $alert_type - $message": Alert format with type and message
    # >>: Append to file (don't overwrite)
    # "/tmp/alerts_$(date +%Y%m%d).log": Daily log file with date stamp
    # $(date +%Y%m%d): Current date in YYYYMMDD format
    
    # =============================================================================
    # EMAIL ALERT NOTIFICATION
    # =============================================================================
    # Purpose: Send email alerts if mail command is available
    # Why needed: Provides immediate notification to administrators
    
    if command_exists mail; then
        # Purpose: Check if mail command is available
        # Why needed: Only send email if mail system is available
        # Impact: If mail available, send email; otherwise skip
        
        echo "$message" | mail -s "E-commerce Alert: $alert_type" "$ALERT_EMAIL" 2>/dev/null || true
        # Purpose: Send email alert to configured email address
        # Why needed: Provides immediate email notification to administrators
        # Impact: Administrators receive email alerts for critical issues
        # echo "$message": Send alert message as email body
        # |: Pipe message to mail command
        # mail: Email sending command
        # -s "E-commerce Alert: $alert_type": Email subject with alert type
        # "$ALERT_EMAIL": Recipient email address from configuration
        # 2>/dev/null: Suppress error messages
        # || true: Don't fail if email sending fails
    fi
}

# Function: Monitor continuously
monitor_continuously() {
    # =============================================================================
    # MONITOR CONTINUOUSLY FUNCTION
    # =============================================================================
    # Performs continuous monitoring with comprehensive health checks and
    # alerting capabilities over a specified duration with configurable intervals.
    # =============================================================================
    
    # Purpose: Perform continuous monitoring of all system components
    # Why needed: Provides ongoing health monitoring and alerting
    # Impact: Ensures continuous visibility into system health
    # Parameters: None
    # Usage: monitor_continuously
    
    # =============================================================================
    # MONITORING DURATION CALCULATION
    # =============================================================================
    # Purpose: Calculate end time for monitoring session
    # Why needed: Determines when to stop continuous monitoring
    
    local end_time
    # Purpose: Variable to store monitoring end time in Unix timestamp
    # Why needed: Provides end time for monitoring loop termination
    # Impact: Used to determine when to stop monitoring
    
    end_time=$(date -d "+$DURATION" +%s)
    # Purpose: Calculate end time by adding duration to current time
    # Why needed: Determines when continuous monitoring should stop
    # Impact: Provides Unix timestamp for monitoring termination
    # date -d "+$DURATION": Add duration to current date
    # +%s: Output as Unix timestamp (seconds since epoch)
    # $DURATION: Duration from configuration (e.g., "1h", "30m")
    
    # =============================================================================
    # MONITORING INITIALIZATION
    # =============================================================================
    # Purpose: Display monitoring configuration and start information
    # Why needed: Provides visibility into monitoring parameters
    
    print_status "HEADER" "Starting continuous monitoring for $DURATION"
    # Purpose: Log monitoring start message with duration
    # Why needed: Informs user that continuous monitoring is starting
    # Impact: User knows monitoring duration and start time
    # $DURATION: Shows how long monitoring will run
    
    print_status "INFO" "Monitoring interval: $INTERVAL"
    # Purpose: Log monitoring interval information
    # Why needed: Informs user about monitoring frequency
    # Impact: User knows how often health checks will run
    # $INTERVAL: Shows time between monitoring cycles
    
    print_status "INFO" "Alert email: $ALERT_EMAIL"
    # Purpose: Log alert email configuration
    # Why needed: Informs user about alert notification settings
    # Impact: User knows where alerts will be sent
    # $ALERT_EMAIL: Shows configured alert email address
    
    # =============================================================================
    # CONTINUOUS MONITORING LOOP
    # =============================================================================
    # Purpose: Perform health checks in continuous loop
    # Why needed: Provides ongoing monitoring until duration expires
    
    while [ $(date +%s) -lt $end_time ]; do
        # Purpose: Continue monitoring while current time is less than end time
        # Why needed: Ensures monitoring continues for specified duration
        # Impact: Loop continues until monitoring duration expires
        # $(date +%s): Current time in Unix timestamp
        # -lt: Less than comparison
        # $end_time: Calculated end time for monitoring
        
        print_status "INFO" "=== Monitoring Cycle $(date) ==="
        # Purpose: Log monitoring cycle start with timestamp
        # Why needed: Provides visibility into monitoring cycle timing
        # Impact: User knows when each monitoring cycle starts
        # $(date): Current date and time for cycle identification
        
        # =============================================================================
        # ALERT CLEARING
        # =============================================================================
        # Purpose: Clear previous cycle alerts before new checks
        # Why needed: Ensures fresh alert state for each cycle
        
        ALERTS=()
        # Purpose: Clear alerts array for new monitoring cycle
        # Why needed: Resets alert state before performing new health checks
        # Impact: Ensures alerts are fresh for each monitoring cycle
        
        # =============================================================================
        # HEALTH CHECK EXECUTION
        # =============================================================================
        # Purpose: Perform comprehensive health checks
        # Why needed: Validates health of all system components
        
        check_pod_health
        # Purpose: Check health status of all pods
        # Why needed: Ensures all pods are running and healthy
        # Impact: Identifies unhealthy pods and generates alerts
        
        check_service_health
        # Purpose: Check health status of all services
        # Why needed: Ensures all services have healthy endpoints
        # Impact: Identifies services without endpoints and generates alerts
        
        check_resource_limits
        # Purpose: Check resource usage against limits
        # Why needed: Ensures pods don't exceed resource limits
        # Impact: Identifies high resource usage and generates alerts
        
        check_disk_space
        # Purpose: Check disk space usage on all nodes
        # Why needed: Ensures nodes have sufficient disk space
        # Impact: Identifies nodes with high disk usage and generates alerts
        
        check_prometheus_targets
        # Purpose: Check Prometheus monitoring targets
        # Why needed: Ensures all monitoring targets are healthy
        # Impact: Identifies down targets and generates alerts
        
        check_grafana_health
        # Purpose: Check Grafana service health and accessibility
        # Why needed: Ensures Grafana dashboard is accessible
        # Impact: Identifies Grafana service issues and generates alerts
        
        check_alertmanager_health
        # Purpose: Check AlertManager service health and accessibility
        # Why needed: Ensures AlertManager is accessible for alert processing
        # Impact: Identifies AlertManager service issues and generates alerts
        
        # =============================================================================
        # ALERT PROCESSING
        # =============================================================================
        # Purpose: Send alerts for any issues found during health checks
        # Why needed: Ensures administrators are notified of issues
        
        for alert_type in "${!ALERTS[@]}"; do
            # Purpose: Iterate through all alert types found
            # Why needed: Processes all alerts generated during health checks
            # Impact: Sends alerts for each type of issue found
            # "${!ALERTS[@]}": Get all keys from ALERTS associative array
            
            send_alert "$alert_type" "${ALERTS[$alert_type]}"
            # Purpose: Send alert for specific alert type
            # Why needed: Notifies administrators about specific issues
            # Impact: Administrators receive alerts for each issue type
            # $alert_type: Type of alert (e.g., "unhealthy_pods", "high_cpu")
            # "${ALERTS[$alert_type]}": Alert message for this alert type
        done
        
        # =============================================================================
        # RESOURCE USAGE DISPLAY
        # =============================================================================
        # Purpose: Display current resource usage information
        # Why needed: Provides visibility into current resource consumption
        
        get_resource_usage
        # Purpose: Display comprehensive resource usage metrics
        # Why needed: Shows current resource usage for pods and nodes
        # Impact: User can see current resource consumption
        
        # =============================================================================
        # MONITORING INTERVAL WAIT
        # =============================================================================
        # Purpose: Wait for specified interval before next monitoring cycle
        # Why needed: Controls monitoring frequency and prevents excessive resource usage
        
        sleep "$INTERVAL"
        # Purpose: Wait for configured interval before next cycle
        # Why needed: Controls monitoring frequency and system load
        # Impact: Prevents excessive monitoring and allows system to stabilize
        # $INTERVAL: Time to wait between monitoring cycles
    done
    
    # =============================================================================
    # MONITORING COMPLETION
    # =============================================================================
    # Purpose: Log monitoring completion message
    # Why needed: Provides confirmation that monitoring has finished
    
    print_status "SUCCESS" "Monitoring completed"
    # Purpose: Log monitoring completion message
    # Why needed: Confirms that continuous monitoring has finished
    # Impact: User knows monitoring session has completed successfully
}

# Function: Generate monitoring report
generate_report() {
    # =============================================================================
    # GENERATE MONITORING REPORT FUNCTION
    # =============================================================================
    # Generates comprehensive monitoring reports with system status, resource usage,
    # events, and alerts in a structured text format for analysis and documentation.
    # =============================================================================
    
    # Purpose: Generate comprehensive monitoring report
    # Why needed: Provides detailed system status and health information
    # Impact: Creates detailed report for analysis and documentation
    # Parameters: None
    # Usage: generate_report
    
    # =============================================================================
    # REPORT FILE INITIALIZATION
    # =============================================================================
    # Purpose: Create timestamped report file
    # Why needed: Provides unique filename for each report
    
    local report_file="/tmp/monitoring_report_$(date +%Y%m%d_%H%M%S).txt"
    # Purpose: Variable to store report file path with timestamp
    # Why needed: Provides unique filename for each report generation
    # Impact: Each report has unique filename preventing overwrites
    # "/tmp/monitoring_report_": Base filename for monitoring reports
    # $(date +%Y%m%d_%H%M%S): Timestamp in YYYYMMDD_HHMMSS format
    # .txt: Text file extension
    
    # =============================================================================
    # REPORT GENERATION INITIATION
    # =============================================================================
    # Purpose: Log report generation start
    # Why needed: Provides visibility into report generation process
    
    print_status "INFO" "Generating monitoring report: $report_file"
    # Purpose: Log report generation start message
    # Why needed: Informs user that report is being generated
    # Impact: User knows report filename and generation status
    # $report_file: Shows the report file path being created
    
    # =============================================================================
    # REPORT CONTENT GENERATION
    # =============================================================================
    # Purpose: Generate comprehensive report content
    # Why needed: Provides detailed system status information
    
    cat > "$report_file" << EOF
    # Purpose: Create report file with comprehensive content
    # Why needed: Generates structured report with all system information
    # Impact: Creates detailed report file for analysis
    # cat >: Create new file with content
    # "$report_file": Target report file path
    # << EOF: Here document for multi-line content
    
E-commerce Application Monitoring Report
Generated: $(date)
Namespace: $NAMESPACE

=== POD STATUS ===
$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce" -o wide)

=== SERVICE STATUS ===
$(kubectl get services -n "$NAMESPACE" -l "app=ecommerce" -o wide)

=== DEPLOYMENT STATUS ===
$(kubectl get deployments -n "$NAMESPACE" -l "app=ecommerce" -o wide)

=== RESOURCE USAGE ===
$(get_resource_usage)

=== NODE STATUS ===
$(kubectl get nodes -o wide)

=== RECENT EVENTS ===
$(kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -20)

=== ALERTS ===
EOF
    # Purpose: Generate comprehensive report content with system information
    # Why needed: Provides detailed system status for analysis
    # Impact: Creates structured report with all relevant information
    # E-commerce Application Monitoring Report: Report title
    # Generated: $(date): Report generation timestamp
    # Namespace: $NAMESPACE: Target namespace information
    # === POD STATUS ===: Pod status section header
    # kubectl get pods: Get pod information with wide output
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=ecommerce": Filter for e-commerce application pods
    # -o wide: Wide output format with additional columns
    # === SERVICE STATUS ===: Service status section header
    # kubectl get services: Get service information with wide output
    # === DEPLOYMENT STATUS ===: Deployment status section header
    # kubectl get deployments: Get deployment information with wide output
    # === RESOURCE USAGE ===: Resource usage section header
    # $(get_resource_usage): Call function to get resource usage data
    # === NODE STATUS ===: Node status section header
    # kubectl get nodes: Get node information with wide output
    # -o wide: Wide output format with additional columns
    # === RECENT EVENTS ===: Recent events section header
    # kubectl get events: Get recent events from namespace
    # --sort-by='.lastTimestamp': Sort events by timestamp
    # tail -20: Show last 20 events
    # === ALERTS ===: Alerts section header
    
    # =============================================================================
    # ALERT INFORMATION PROCESSING
    # =============================================================================
    # Purpose: Add alert information to report
    # Why needed: Includes current alert status in report
    
    if [ ${#ALERTS[@]} -gt 0 ]; then
        # Purpose: Check if any alerts exist
        # Why needed: Only add alerts section if alerts are present
        # Impact: If alerts exist, add them to report; otherwise add "No alerts"
        # ${#ALERTS[@]}: Get number of elements in ALERTS array
        # -gt 0: Greater than 0 (check if alerts exist)
        
        for alert_type in "${!ALERTS[@]}"; do
            # Purpose: Iterate through all alert types
            # Why needed: Adds each alert type to the report
            # Impact: Includes all current alerts in the report
            # "${!ALERTS[@]}": Get all keys from ALERTS associative array
            
            echo "$alert_type: ${ALERTS[$alert_type]}" >> "$report_file"
            # Purpose: Add alert information to report file
            # Why needed: Includes specific alert details in report
            # Impact: Report contains detailed alert information
            # echo: Output alert information
            # "$alert_type: ${ALERTS[$alert_type]}": Alert format with type and message
            # >>: Append to report file
            # "$report_file": Target report file
        done
    else
        # Purpose: Handle case when no alerts exist
        # Why needed: Provides clear indication when no alerts are present
        # Impact: If no alerts, add "No alerts" message to report
        
        echo "No alerts" >> "$report_file"
        # Purpose: Add "No alerts" message to report
        # Why needed: Indicates that no alerts are currently active
        # Impact: Report clearly shows no alerts are present
        # >>: Append to report file
        # "$report_file": Target report file
    fi
    
    # =============================================================================
    # REPORT COMPLETION
    # =============================================================================
    # Purpose: Log report generation completion
    # Why needed: Confirms report generation was successful
    
    print_status "SUCCESS" "Monitoring report generated: $report_file"
    # Purpose: Log report generation completion message
    # Why needed: Confirms that report was generated successfully
    # Impact: User knows report generation completed and file location
    # $report_file: Shows the report file path that was created
}

# Function: Show help
show_help() {
    # =============================================================================
    # SHOW HELP FUNCTION
    # =============================================================================
    # Displays comprehensive help information with usage instructions, available
    # actions, options, examples, and monitoring features for the monitoring script.
    # =============================================================================
    
    # Purpose: Display comprehensive help information for the monitoring script
    # Why needed: Provides users with complete usage instructions and options
    # Impact: Users can understand how to use the monitoring script effectively
    # Parameters: None
    # Usage: show_help
    
    # =============================================================================
    # HELP CONTENT DISPLAY
    # =============================================================================
    # Purpose: Display comprehensive help information
    # Why needed: Provides complete usage guide for the monitoring script
    
    cat << EOF
    # Purpose: Display help content using here document
    # Why needed: Provides structured help information
    # Impact: Users receive comprehensive usage instructions
    # cat << EOF: Here document for multi-line content display
    
E-commerce Application Monitoring Script

USAGE:
    ./monitor.sh [ACTION] [OPTIONS]

ACTIONS:
    status          Show current status
    health          Check application health
    metrics         Show resource metrics
    monitor         Monitor continuously
    report          Generate monitoring report
    alerts          Check for active alerts

OPTIONS:
    --namespace=NAMESPACE    Kubernetes namespace (default: ecommerce)
    --duration=DURATION      Monitoring duration (default: 300s)
    --interval=INTERVAL      Monitoring interval (default: 30s)
    --email=EMAIL           Alert email address (default: admin@ecommerce.local)
    --log-level=LEVEL       Log level (default: INFO)

EXAMPLES:
    # Show current status
    ./monitor.sh status

    # Check application health
    ./monitor.sh health

    # Show resource metrics
    ./monitor.sh metrics

    # Monitor for 10 minutes
    ./monitor.sh monitor --duration=600s

    # Generate monitoring report
    ./monitor.sh report

    # Check for alerts
    ./monitor.sh alerts

MONITORING FEATURES:
    - Pod health monitoring
    - Service endpoint monitoring
    - Resource usage monitoring
    - Disk space monitoring
    - Prometheus target monitoring
    - Grafana health monitoring
    - AlertManager health monitoring
    - Automated alerting

EOF
    # Purpose: Display comprehensive help content with usage information
    # Why needed: Provides complete usage guide for monitoring script
    # Impact: Users understand all available actions, options, and features
    # E-commerce Application Monitoring Script: Script title
    # USAGE: Usage section header
    # ./monitor.sh [ACTION] [OPTIONS]: Basic usage syntax
    # ACTIONS: Available actions section header
    # status: Show current application status
    # health: Check application health
    # metrics: Show resource metrics
    # monitor: Monitor continuously
    # report: Generate monitoring report
    # alerts: Check for active alerts
    # OPTIONS: Available options section header
    # --namespace=NAMESPACE: Kubernetes namespace option
    # --duration=DURATION: Monitoring duration option
    # --interval=INTERVAL: Monitoring interval option
    # --email=EMAIL: Alert email address option
    # --log-level=LEVEL: Log level option
    # EXAMPLES: Usage examples section header
    # Various example commands showing script usage
    # MONITORING FEATURES: Features section header
    # List of monitoring capabilities provided by the script
}

# =============================================================================
# MAIN MONITORING FUNCTIONS
# =============================================================================

# Function: Show status
show_status() {
    # =============================================================================
    # SHOW STATUS FUNCTION
    # =============================================================================
    # Displays comprehensive status information for the e-commerce application
    # including pods, services, and deployments with detailed output formatting.
    # =============================================================================
    
    # Purpose: Display comprehensive status of e-commerce application components
    # Why needed: Provides overview of application deployment status
    # Impact: Users can see current state of all application components
    # Parameters: None
    # Usage: show_status
    
    # =============================================================================
    # STATUS HEADER DISPLAY
    # =============================================================================
    # Purpose: Display status header and namespace information
    # Why needed: Provides context for status information
    
    print_status "HEADER" "E-commerce Application Status"
    # Purpose: Display status header message
    # Why needed: Identifies the status display section
    # Impact: User knows this is the application status section
    
    print_status "INFO" "Namespace: $NAMESPACE"
    # Purpose: Display target namespace information
    # Why needed: Shows which namespace is being monitored
    # Impact: User knows the target namespace for status information
    # $NAMESPACE: Shows the configured namespace
    
    # =============================================================================
    # POD STATUS DISPLAY
    # =============================================================================
    # Purpose: Display pod status information
    # Why needed: Shows current state of application pods
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between sections
    
    print_status "INFO" "=== PODS ==="
    # Purpose: Display pods section header
    # Why needed: Identifies the pods status section
    # Impact: User knows the following information is about pods
    
    kubectl get pods -n "$NAMESPACE" -l "app=ecommerce" -o wide
    # Purpose: Get and display pod information with wide output
    # Why needed: Shows detailed pod status information
    # Impact: User can see pod names, status, restarts, age, and node information
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=ecommerce": Filter for e-commerce application pods
    # -o wide: Wide output format with additional columns (IP, node, etc.)
    
    # =============================================================================
    # SERVICE STATUS DISPLAY
    # =============================================================================
    # Purpose: Display service status information
    # Why needed: Shows current state of application services
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between sections
    
    print_status "INFO" "=== SERVICES ==="
    # Purpose: Display services section header
    # Why needed: Identifies the services status section
    # Impact: User knows the following information is about services
    
    kubectl get services -n "$NAMESPACE" -l "app=ecommerce" -o wide
    # Purpose: Get and display service information with wide output
    # Why needed: Shows detailed service status information
    # Impact: User can see service names, types, cluster IPs, external IPs, and ports
    # kubectl get services: Get service information
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=ecommerce": Filter for e-commerce application services
    # -o wide: Wide output format with additional columns
    
    # =============================================================================
    # DEPLOYMENT STATUS DISPLAY
    # =============================================================================
    # Purpose: Display deployment status information
    # Why needed: Shows current state of application deployments
    
    echo ""
    # Purpose: Add blank line for visual separation
    # Why needed: Improves readability of status output
    # Impact: Creates visual separation between sections
    
    print_status "INFO" "=== DEPLOYMENTS ==="
    # Purpose: Display deployments section header
    # Why needed: Identifies the deployments status section
    # Impact: User knows the following information is about deployments
    
    kubectl get deployments -n "$NAMESPACE" -l "app=ecommerce" -o wide
    # Purpose: Get and display deployment information with wide output
    # Why needed: Shows detailed deployment status information
    # Impact: User can see deployment names, replicas, available, age, and container images
    # kubectl get deployments: Get deployment information
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=ecommerce": Filter for e-commerce application deployments
    # -o wide: Wide output format with additional columns
}

# Function: Check health
check_health() {
    # =============================================================================
    # CHECK HEALTH FUNCTION
    # =============================================================================
    # Performs comprehensive health checks across all system components with
    # detailed validation and summary reporting of health status.
    # =============================================================================
    
    # Purpose: Perform comprehensive health checks for all system components
    # Why needed: Validates overall system health and identifies issues
    # Impact: Provides complete health assessment and identifies problems
    # Parameters: None
    # Usage: check_health
    
    # =============================================================================
    # HEALTH CHECK INITIATION
    # =============================================================================
    # Purpose: Display health check header and initiate comprehensive checks
    # Why needed: Provides context for health check process
    
    print_status "HEADER" "E-commerce Application Health Check"
    # Purpose: Display health check header message
    # Why needed: Identifies the health check section
    # Impact: User knows this is the comprehensive health check section
    
    # =============================================================================
    # COMPREHENSIVE HEALTH CHECKS
    # =============================================================================
    # Purpose: Perform all health checks across system components
    # Why needed: Validates health of all critical system components
    
    check_pod_health
    # Purpose: Check health status of all pods
    # Why needed: Ensures all pods are running and healthy
    # Impact: Identifies unhealthy pods and generates alerts
    
    check_service_health
    # Purpose: Check health status of all services
    # Why needed: Ensures all services have healthy endpoints
    # Impact: Identifies services without endpoints and generates alerts
    
    check_resource_limits
    # Purpose: Check resource usage against limits
    # Why needed: Ensures pods don't exceed resource limits
    # Impact: Identifies high resource usage and generates alerts
    
    check_disk_space
    # Purpose: Check disk space usage on all nodes
    # Why needed: Ensures nodes have sufficient disk space
    # Impact: Identifies nodes with high disk usage and generates alerts
    
    check_prometheus_targets
    # Purpose: Check Prometheus monitoring targets
    # Why needed: Ensures all monitoring targets are healthy
    # Impact: Identifies down targets and generates alerts
    
    check_grafana_health
    # Purpose: Check Grafana service health and accessibility
    # Why needed: Ensures Grafana dashboard is accessible
    # Impact: Identifies Grafana service issues and generates alerts
    
    check_alertmanager_health
    # Purpose: Check AlertManager service health and accessibility
    # Why needed: Ensures AlertManager is accessible for alert processing
    # Impact: Identifies AlertManager service issues and generates alerts
    
    # =============================================================================
    # HEALTH CHECK SUMMARY
    # =============================================================================
    # Purpose: Provide summary of health check results
    # Why needed: Gives overall assessment of system health
    
    if [ ${#ALERTS[@]} -eq 0 ]; then
        # Purpose: Check if no alerts were generated during health checks
        # Why needed: Determines if all health checks passed
        # Impact: If no alerts, system is healthy; otherwise issues were found
        # ${#ALERTS[@]}: Get number of elements in ALERTS array
        # -eq 0: Equal to 0 (check if no alerts)
        
        print_status "SUCCESS" "All health checks passed"
        # Purpose: Log success message when no issues found
        # Why needed: Confirms that all health checks passed
        # Impact: User knows system is healthy
    else
        # Purpose: Handle case when alerts were generated
        # Why needed: Provides warning when issues are found
        # Impact: If alerts exist, show warning with count
        
        print_status "WARNING" "Health checks completed with ${#ALERTS[@]} alerts"
        # Purpose: Log warning message with alert count
        # Why needed: Informs user about issues found during health checks
        # Impact: User knows how many issues were identified
        # ${#ALERTS[@]}: Shows number of alerts generated
    fi
}

# Function: Show metrics
show_metrics() {
    # =============================================================================
    # SHOW METRICS FUNCTION
    # =============================================================================
    # Displays comprehensive resource usage metrics for the e-commerce application
    # including pod and node metrics with detailed resource consumption information.
    # =============================================================================
    
    # Purpose: Display comprehensive resource usage metrics
    # Why needed: Provides visibility into current resource consumption
    # Impact: Users can monitor resource usage across all components
    # Parameters: None
    # Usage: show_metrics
    
    # =============================================================================
    # METRICS HEADER DISPLAY
    # =============================================================================
    # Purpose: Display metrics header and initiate metrics collection
    # Why needed: Provides context for metrics display
    
    print_status "HEADER" "E-commerce Application Metrics"
    # Purpose: Display metrics header message
    # Why needed: Identifies the metrics display section
    # Impact: User knows this is the resource metrics section
    
    # =============================================================================
    # RESOURCE USAGE DISPLAY
    # =============================================================================
    # Purpose: Display comprehensive resource usage information
    # Why needed: Shows current resource consumption for all components
    
    get_resource_usage
    # Purpose: Get and display comprehensive resource usage metrics
    # Why needed: Shows current resource usage for pods and nodes
    # Impact: User can see CPU and memory usage across all components
    # Function call to get_resource_usage which displays:
    # - Pod metrics (CPU and memory usage)
    # - Node metrics (CPU and memory usage)
    # - Component filtering capabilities
    # - Error handling for unavailable metrics
}

# Function: Check alerts
check_alerts() {
    # =============================================================================
    # CHECK ALERTS FUNCTION
    # =============================================================================
    # Performs comprehensive health checks and displays active alerts with
    # detailed alert information and status reporting.
    # =============================================================================
    
    # Purpose: Check for active alerts across all system components
    # Why needed: Identifies current issues and provides alert status
    # Impact: Users can see all active alerts and their details
    # Parameters: None
    # Usage: check_alerts
    
    # =============================================================================
    # ALERT CHECK INITIATION
    # =============================================================================
    # Purpose: Display alert check header and initiate comprehensive checks
    # Why needed: Provides context for alert checking process
    
    print_status "HEADER" "Checking for Active Alerts"
    # Purpose: Display alert check header message
    # Why needed: Identifies the alert checking section
    # Impact: User knows this is the active alerts checking section
    
    # =============================================================================
    # COMPREHENSIVE HEALTH CHECKS
    # =============================================================================
    # Purpose: Perform all health checks to identify potential alerts
    # Why needed: Validates all system components for issues
    
    check_pod_health
    # Purpose: Check health status of all pods
    # Why needed: Identifies unhealthy pods that may generate alerts
    # Impact: Detects pod-related issues and generates alerts
    
    check_service_health
    # Purpose: Check health status of all services
    # Why needed: Identifies services without endpoints that may generate alerts
    # Impact: Detects service-related issues and generates alerts
    
    check_resource_limits
    # Purpose: Check resource usage against limits
    # Why needed: Identifies high resource usage that may generate alerts
    # Impact: Detects resource-related issues and generates alerts
    
    check_disk_space
    # Purpose: Check disk space usage on all nodes
    # Why needed: Identifies high disk usage that may generate alerts
    # Impact: Detects disk-related issues and generates alerts
    
    check_prometheus_targets
    # Purpose: Check Prometheus monitoring targets
    # Why needed: Identifies down targets that may generate alerts
    # Impact: Detects monitoring-related issues and generates alerts
    
    check_grafana_health
    # Purpose: Check Grafana service health and accessibility
    # Why needed: Identifies Grafana issues that may generate alerts
    # Impact: Detects Grafana-related issues and generates alerts
    
    check_alertmanager_health
    # Purpose: Check AlertManager service health and accessibility
    # Why needed: Identifies AlertManager issues that may generate alerts
    # Impact: Detects AlertManager-related issues and generates alerts
    
    # =============================================================================
    # ALERT STATUS DISPLAY
    # =============================================================================
    # Purpose: Display active alerts or confirm no alerts
    # Why needed: Provides clear status of current alerts
    
    if [ ${#ALERTS[@]} -eq 0 ]; then
        # Purpose: Check if no alerts were generated during health checks
        # Why needed: Determines if system is healthy or has issues
        # Impact: If no alerts, system is healthy; otherwise show alerts
        # ${#ALERTS[@]}: Get number of elements in ALERTS array
        # -eq 0: Equal to 0 (check if no alerts)
        
        print_status "SUCCESS" "No active alerts"
        # Purpose: Log success message when no alerts found
        # Why needed: Confirms that no issues were detected
        # Impact: User knows system is healthy with no active alerts
    else
        # Purpose: Handle case when alerts were generated
        # Why needed: Provides detailed information about active alerts
        # Impact: If alerts exist, show detailed alert information
        
        print_status "WARNING" "Active alerts:"
        # Purpose: Log warning message about active alerts
        # Why needed: Informs user that alerts are present
        # Impact: User knows there are active alerts to review
        
        for alert_type in "${!ALERTS[@]}"; do
            # Purpose: Iterate through all alert types found
            # Why needed: Displays each active alert with details
            # Impact: User can see all active alerts and their information
            # "${!ALERTS[@]}": Get all keys from ALERTS associative array
            
            print_status "ALERT" "$alert_type: ${ALERTS[$alert_type]}"
            # Purpose: Display individual alert information
            # Why needed: Shows specific alert type and message
            # Impact: User can see detailed information about each alert
            # $alert_type: Type of alert (e.g., "unhealthy_pods", "high_cpu")
            # ${ALERTS[$alert_type]}: Alert message for this alert type
        done
    fi
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
    "health")
        check_health
        ;;
    "metrics")
        show_metrics
        ;;
    "monitor")
        monitor_continuously
        ;;
    "report")
        generate_report
        ;;
    "alerts")
        check_alerts
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
