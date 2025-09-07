#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION HEALTH CHECK SCRIPT
# =============================================================================
# This script performs comprehensive health checks on the e-commerce application
# and monitoring stack to ensure operational readiness and reliability with
# advanced Kubernetes workload management validation.
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
# HEALTH CHECK CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent health check configuration throughout the script.
# =============================================================================

NAMESPACE="${1:-ecommerce}"
# Purpose: Specifies the Kubernetes namespace for health checks
# Why needed: Provides consistent namespace reference for all health validations
# Impact: All health checks target resources in this namespace
# Value: Defaults to 'ecommerce', accepts any valid namespace name

DETAILED=false
# Purpose: Enables detailed health check mode with verbose output
# Why needed: Provides comprehensive health information for troubleshooting
# Impact: When true, shows detailed component status and resource information
# Usage: Set via --detailed command line argument

JSON_OUTPUT=false
# Purpose: Enables JSON output format for programmatic consumption
# Why needed: Allows integration with monitoring systems and automated processing
# Impact: When true, outputs health status in structured JSON format
# Usage: Set via --json command line argument

for arg in "$@"; do
    case $arg in
        --detailed)
            DETAILED=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
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
# Purpose: Red color code for error messages and failed health checks
# Why needed: Provides visual distinction for failed health checks
# Impact: Failed checks are displayed in red color
# Usage: Used in print_status() function for ERROR status messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages and passed health checks
# Why needed: Provides visual distinction for successful health checks
# Impact: Passed checks are displayed in green color
# Usage: Used in print_status() function for SUCCESS status messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages and warning health checks
# Why needed: Provides visual distinction for warning health checks
# Impact: Warning checks are displayed in yellow color
# Usage: Used in print_status() function for WARNING status messages

BLUE='\033[0;34m'
# Purpose: Blue color code for informational messages
# Why needed: Provides visual distinction for informational output
# Impact: Info messages are displayed in blue color
# Usage: Used in print_status() function for INFO status messages

NC='\033[0m'
# Purpose: No Color code to reset terminal color
# Why needed: Resets terminal color after colored output
# Impact: Prevents color bleeding to subsequent output
# Usage: Used at end of all colored message functions

# =============================================================================
# HEALTH CHECK TRACKING VARIABLES
# =============================================================================
# Variables to track health check results and statistics.
# =============================================================================

declare -A HEALTH_STATUS
# Purpose: Associative array to store health status for each component
# Why needed: Provides centralized storage for health check results
# Impact: Enables status tracking and reporting across all components
# Usage: HEALTH_STATUS["component_name"]="PASS|FAIL|WARN"

declare -A HEALTH_DETAILS
# Purpose: Associative array to store detailed health information
# Why needed: Provides detailed information for troubleshooting and reporting
# Impact: Enables detailed health reporting and problem diagnosis
# Usage: HEALTH_DETAILS["component_name"]="Detailed status information"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================
# Functions for consistent logging, health checking, and status reporting.
# =============================================================================

# Function: Print colored output with conditional JSON support
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp and conditional JSON support.
    # Provides visual distinction and consistent formatting for health check operations.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps and conditional JSON support
    # Why needed: Provides visual feedback and consistent logging for health check operations
    # Impact: Users can easily identify message types and operations are logged consistently
    # Parameters:
    #   $1: Status type (INFO, SUCCESS, WARNING, ERROR)
    #   $2: Message to display
    # Usage: print_status "INFO" "Checking pod health"
    
    local status=$1
    # Purpose: Specifies the type of status message
    # Why needed: Determines color and formatting for the message
    # Impact: Different status types get different colors for easy identification
    # Parameter: $1 is the status type (INFO, SUCCESS, WARNING, ERROR)
    
    local message=$2
    # Purpose: Contains the message text to display
    # Why needed: Provides the actual message content
    # Impact: Users see the specific message about the health check
    # Parameter: $2 is the message text to display
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp for message identification
    # Why needed: Provides temporal context for health check operations
    # Impact: All messages include timestamp for chronological tracking
    # Format: YYYY-MM-DD HH:MM:SS (e.g., 2024-12-15 14:30:22)
    # date '+%Y-%m-%d %H:%M:%S': Get current date and time in specified format
    
    if [ "$JSON_OUTPUT" = true ]; then
        # Purpose: Check if JSON output mode is enabled
        # Why needed: Suppresses colored output when JSON mode is active
        # Impact: No output is displayed when JSON mode is enabled
        # "$JSON_OUTPUT": Global variable for JSON output mode
        
        return 0
        # Purpose: Exit function without output when JSON mode is enabled
        # Why needed: Prevents colored output from interfering with JSON output
        # Impact: Function returns without displaying message
    fi
    
    case $status in
        "INFO")
            # Purpose: Displays informational messages in blue color
            # Why needed: Provides neutral information about health check progress
            # Impact: Users see informational messages in blue
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            # Purpose: Output informational message with blue color
            # Why needed: Provides visual indication of informational content
            # Impact: Message is displayed in blue color
            # echo -e: Enable interpretation of backslash escapes
            # "${BLUE}[INFO]${NC}": Blue color for INFO prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        "SUCCESS")
            # Purpose: Displays success messages in green color
            # Why needed: Confirms successful health check operations
            # Impact: Users see success messages in green
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            # Purpose: Output success message with green color
            # Why needed: Provides visual indication of successful operations
            # Impact: Message is displayed in green color
            # echo -e: Enable interpretation of backslash escapes
            # "${GREEN}[SUCCESS]${NC}": Green color for SUCCESS prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        "WARNING")
            # Purpose: Displays warning messages in yellow color
            # Why needed: Alerts users to potential issues without failing health checks
            # Impact: Users see warning messages in yellow
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            # Purpose: Output warning message with yellow color
            # Why needed: Provides visual indication of warning conditions
            # Impact: Message is displayed in yellow color
            # echo -e: Enable interpretation of backslash escapes
            # "${YELLOW}[WARNING]${NC}": Yellow color for WARNING prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        "ERROR")
            # Purpose: Displays error messages in red color
            # Why needed: Reports health check failures and errors
            # Impact: Users see error messages in red
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            # Purpose: Output error message with red color
            # Why needed: Provides visual indication of error conditions
            # Impact: Message is displayed in red color
            # echo -e: Enable interpretation of backslash escapes
            # "${RED}[ERROR]${NC}": Red color for ERROR prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
    esac
}

# Function: Record health status for components
record_health() {
    # =============================================================================
    # RECORD HEALTH FUNCTION
    # =============================================================================
    # Stores health status and details for each component in tracking arrays.
    # Provides centralized health status tracking for comprehensive reporting.
    # =============================================================================
    
    # Purpose: Store health status and details for components in tracking arrays
    # Why needed: Provides centralized health status tracking for reporting
    # Impact: Enables comprehensive health reporting and status aggregation
    # Parameters:
    #   $1: Component name (e.g., "backend", "frontend", "database")
    #   $2: Health status (PASS, FAIL, WARN, ERROR)
    #   $3: Detailed status information
    # Usage: record_health "backend" "PASS" "All pods running and healthy"
    # Returns: None (stores data in global arrays)
    
    local component=$1
    # Purpose: Specifies the component name for health tracking
    # Why needed: Identifies which component the health status applies to
    # Impact: Health status is associated with the specific component
    # Parameter: $1 is the component name (e.g., "backend", "frontend", "database")
    
    local status=$2
    # Purpose: Specifies the health status of the component
    # Why needed: Provides the health status for tracking and reporting
    # Impact: Health status is recorded for the component
    # Parameter: $2 is the health status (PASS, FAIL, WARN, ERROR)
    
    local details=$3
    # Purpose: Contains detailed status information about the component
    # Why needed: Provides additional context about the health status
    # Impact: Detailed information is recorded for comprehensive reporting
    # Parameter: $3 is the detailed status information
    
    HEALTH_STATUS["$component"]="$status"
    # Purpose: Store component health status in global array
    # Why needed: Provides centralized storage for health status tracking
    # Impact: Component health status is stored for later retrieval
    # HEALTH_STATUS: Global associative array for health statuses
    # ["$component"]: Component name as array key
    # "$status": Health status as array value
    
    HEALTH_DETAILS["$component"]="$details"
    # Purpose: Store component health details in global array
    # Why needed: Provides centralized storage for health details tracking
    # Impact: Component health details are stored for later retrieval
    # HEALTH_DETAILS: Global associative array for health details
    # ["$component"]: Component name as array key
    # "$details": Health details as array value
}

# Function: Check individual pod health
check_pod_health() {
    # =============================================================================
    # CHECK POD HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of a specific pod with comprehensive checks.
    # Provides detailed pod-level health validation including status, readiness, and resource usage.
    # =============================================================================
    
    # Purpose: Validate the health status of a specific pod
    # Why needed: Ensures individual pods are running and responding correctly
    # Impact: Provides detailed pod-level health validation
    # Parameters:
    #   $1: Pod name to check
    #   $2: Component name for reporting
    # Usage: check_pod_health "backend-pod-123" "backend"
    # Returns: 0 if pod is healthy, 1 if unhealthy
    
    local pod_name=$1
    # Purpose: Specifies the pod name to check
    # Why needed: Identifies which pod to validate for health
    # Impact: Function validates the specified pod
    # Parameter: $1 is the pod name
    
    local component=$2
    # Purpose: Specifies the component name for reporting
    # Why needed: Provides component context for health reporting
    # Impact: Health status is associated with the component
    # Parameter: $2 is the component name
    
    print_status "INFO" "Checking health of pod: ${pod_name}"
    # Purpose: Log the start of pod health check
    # Why needed: Informs user that pod health check has begun
    # Impact: User knows pod health check has started
    
    # =============================================================================
    # GET POD STATUS
    # =============================================================================
    # Purpose: Retrieve pod status from Kubernetes
    # Why needed: Provides current pod status for validation
    
    local pod_status
    # Purpose: Variable to store pod status
    # Why needed: Provides pod status for validation
    # Impact: Will contain the pod status
    
    pod_status=$(kubectl get pod -n "$NAMESPACE" "$pod_name" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
    # Purpose: Get pod status from Kubernetes
    # Why needed: Provides current pod status for validation
    # Impact: Pod status is retrieved
    # kubectl get pod: Get pod information
    # -n "$NAMESPACE": Target namespace
    # "$pod_name": Pod name to check
    # -o jsonpath='{.status.phase}': Extract pod phase from JSON
    # 2>/dev/null: Suppress error messages
    # || echo "NotFound": Default to "NotFound" if command fails
    
    if [ "$pod_status" = "NotFound" ]; then
        # Purpose: Check if pod was not found
        # Why needed: Handles case where pod doesn't exist
        # Impact: Proceeds with error handling if pod not found
        
        record_health "$component" "ERROR" "Pod not found"
        # Purpose: Record pod not found error
        # Why needed: Tracks pod not found error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Pod ${pod_name} not found"
        # Purpose: Log pod not found error
        # Why needed: Informs user that pod was not found
        # Impact: User knows pod was not found
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates pod health check failed
        # Impact: Function returns failure
    fi
    
    if [ "$pod_status" != "Running" ]; then
        # Purpose: Check if pod is not in Running state
        # Why needed: Validates that pod is in proper running state
        # Impact: Proceeds with error handling if pod not running
        
        record_health "$component" "ERROR" "Pod status: ${pod_status}"
        # Purpose: Record pod status error
        # Why needed: Tracks pod status error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Pod ${pod_name} is not running (status: ${pod_status})"
        # Purpose: Log pod status error
        # Why needed: Informs user that pod is not running
        # Impact: User knows pod is not running
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates pod health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK POD READINESS
    # =============================================================================
    # Purpose: Validate that pod is ready to serve traffic
    # Why needed: Ensures pod is fully ready for service
    
    local ready_status
    # Purpose: Variable to store pod readiness status
    # Why needed: Provides pod readiness status for validation
    # Impact: Will contain the pod readiness status
    
    ready_status=$(kubectl get pod -n "$NAMESPACE" "$pod_name" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
    # Purpose: Get pod readiness status from Kubernetes
    # Why needed: Provides pod readiness status for validation
    # Impact: Pod readiness status is retrieved
    # kubectl get pod: Get pod information
    # -n "$NAMESPACE": Target namespace
    # "$pod_name": Pod name to check
    # -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}': Extract ready condition status
    # 2>/dev/null: Suppress error messages
    # || echo "Unknown": Default to "Unknown" if command fails
    
    if [ "$ready_status" != "True" ]; then
        # Purpose: Check if pod is not ready
        # Why needed: Validates that pod is ready to serve traffic
        # Impact: Proceeds with warning if pod not ready
        
        record_health "$component" "WARNING" "Pod not ready (status: ${ready_status})"
        # Purpose: Record pod not ready warning
        # Why needed: Tracks pod readiness warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "Pod ${pod_name} is not ready (status: ${ready_status})"
        # Purpose: Log pod not ready warning
        # Why needed: Informs user that pod is not ready
        # Impact: User knows pod is not ready
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates pod health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK CONTAINER RESTARTS
    # =============================================================================
    # Purpose: Check if pod has restarted containers
    # Why needed: Identifies potential stability issues
    
    local restart_count
    # Purpose: Variable to store container restart count
    # Why needed: Provides restart count for validation
    # Impact: Will contain the restart count
    
    restart_count=$(kubectl get pod -n "$NAMESPACE" "$pod_name" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo "0")
    # Purpose: Get container restart count from Kubernetes
    # Why needed: Provides restart count for validation
    # Impact: Restart count is retrieved
    # kubectl get pod: Get pod information
    # -n "$NAMESPACE": Target namespace
    # "$pod_name": Pod name to check
    # -o jsonpath='{.status.containerStatuses[0].restartCount}': Extract restart count
    # 2>/dev/null: Suppress error messages
    # || echo "0": Default to "0" if command fails
    
    if [ "$restart_count" -gt 0 ]; then
        # Purpose: Check if pod has restarted containers
        # Why needed: Identifies potential stability issues
        # Impact: Proceeds with warning if restarts occurred
        
        record_health "$component" "WARNING" "Pod has restarted ${restart_count} times"
        # Purpose: Record pod restart warning
        # Why needed: Tracks pod restart warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "Pod ${pod_name} has restarted ${restart_count} times"
        # Purpose: Log pod restart warning
        # Why needed: Informs user that pod has restarted
        # Impact: User knows pod has restarted
    fi
    
    # =============================================================================
    # CHECK RESOURCE USAGE (DETAILED MODE)
    # =============================================================================
    # Purpose: Check resource usage if detailed mode is enabled
    # Why needed: Provides additional resource information for detailed analysis
    
    if [ "$DETAILED" = true ]; then
        # Purpose: Check if detailed mode is enabled
        # Why needed: Provides additional resource information when requested
        # Impact: Proceeds with resource usage check if detailed mode enabled
        
        local cpu_usage
        # Purpose: Variable to store CPU usage
        # Why needed: Provides CPU usage information
        # Impact: Will contain the CPU usage
        
        local memory_usage
        # Purpose: Variable to store memory usage
        # Why needed: Provides memory usage information
        # Impact: Will contain the memory usage
        
        cpu_usage=$(kubectl top pod -n "$NAMESPACE" "$pod_name" --no-headers 2>/dev/null | awk '{print $2}' || echo "N/A")
        # Purpose: Get pod CPU usage from Kubernetes
        # Why needed: Provides CPU usage information for detailed analysis
        # Impact: CPU usage is retrieved
        # kubectl top pod: Get pod resource usage
        # -n "$NAMESPACE": Target namespace
        # "$pod_name": Pod name to check
        # --no-headers: Suppress header output
        # 2>/dev/null: Suppress error messages
        # | awk '{print $2}': Extract CPU usage column
        # || echo "N/A": Default to "N/A" if command fails
        
        memory_usage=$(kubectl top pod -n "$NAMESPACE" "$pod_name" --no-headers 2>/dev/null | awk '{print $3}' || echo "N/A")
        # Purpose: Get pod memory usage from Kubernetes
        # Why needed: Provides memory usage information for detailed analysis
        # Impact: Memory usage is retrieved
        # kubectl top pod: Get pod resource usage
        # -n "$NAMESPACE": Target namespace
        # "$pod_name": Pod name to check
        # --no-headers: Suppress header output
        # 2>/dev/null: Suppress error messages
        # | awk '{print $3}': Extract memory usage column
        # || echo "N/A": Default to "N/A" if command fails
        
        print_status "INFO" "Pod ${pod_name} resource usage - CPU: ${cpu_usage}, Memory: ${memory_usage}"
        # Purpose: Log pod resource usage information
        # Why needed: Provides resource usage information to user
        # Impact: User sees pod resource usage
    fi
    
    record_health "$component" "SUCCESS" "Pod is healthy and ready"
    # Purpose: Record successful pod health check
    # Why needed: Tracks successful pod health for reporting
    # Impact: Success is recorded in health tracking
    
    print_status "SUCCESS" "Pod ${pod_name} is healthy"
    # Purpose: Log successful pod health check
    # Why needed: Confirms pod health check was successful
    # Impact: User knows pod is healthy
    
    return 0
    # Purpose: Exit function with success status
    # Why needed: Indicates pod health check succeeded
    # Impact: Function returns success
}

# Function: Check service health
check_service_health() {
    # =============================================================================
    # CHECK SERVICE HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of a Kubernetes service with comprehensive checks.
    # Provides detailed service-level health validation including existence, endpoints, and connectivity.
    # =============================================================================
    
    # Purpose: Validate the health status of a Kubernetes service
    # Why needed: Ensures services are properly configured and accessible
    # Impact: Provides detailed service-level health validation
    # Parameters:
    #   $1: Service name to check
    #   $2: Component name for reporting
    #   $3: Port number to test
    #   $4: Path to test (default: /)
    # Usage: check_service_health "backend-service" "backend" "8000" "/health"
    # Returns: 0 if service is healthy, 1 if unhealthy
    
    local service_name=$1
    # Purpose: Specifies the service name to check
    # Why needed: Identifies which service to validate for health
    # Impact: Function validates the specified service
    # Parameter: $1 is the service name
    
    local component=$2
    # Purpose: Specifies the component name for reporting
    # Why needed: Provides component context for health reporting
    # Impact: Health status is associated with the component
    # Parameter: $2 is the component name
    
    local port=$3
    # Purpose: Specifies the port number to test
    # Why needed: Identifies which port to test for connectivity
    # Impact: Function tests the specified port
    # Parameter: $3 is the port number
    
    local path=${4:-/}
    # Purpose: Specifies the path to test (default: /)
    # Why needed: Identifies which endpoint to test for accessibility
    # Impact: Function tests the specified path
    # Parameter: $4 is the path (default: /)
    
    print_status "INFO" "Checking health of service: ${service_name}"
    # Purpose: Log the start of service health check
    # Why needed: Informs user that service health check has begun
    # Impact: User knows service health check has started
    
    # =============================================================================
    # CHECK SERVICE EXISTENCE
    # =============================================================================
    # Purpose: Verify that the service exists in Kubernetes
    # Why needed: Ensures service exists before performing health checks
    
    if ! kubectl get service -n "$NAMESPACE" "$service_name" >/dev/null 2>&1; then
        # Purpose: Check if service exists in Kubernetes
        # Why needed: Validates that service exists before health checks
        # Impact: Proceeds with error handling if service not found
        # kubectl get service: Get service information
        # -n "$NAMESPACE": Target namespace
        # "$service_name": Service name to check
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "$component" "ERROR" "Service not found"
        # Purpose: Record service not found error
        # Why needed: Tracks service not found error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Service ${service_name} not found"
        # Purpose: Log service not found error
        # Why needed: Informs user that service was not found
        # Impact: User knows service was not found
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates service health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK SERVICE ENDPOINTS
    # =============================================================================
    # Purpose: Verify that the service has available endpoints
    # Why needed: Ensures service has backing pods for traffic
    
    local endpoint_count
    # Purpose: Variable to store endpoint count
    # Why needed: Provides endpoint count for validation
    # Impact: Will contain the endpoint count
    
    endpoint_count=$(kubectl get endpoints -n "$NAMESPACE" "$service_name" -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null | wc -w)
    # Purpose: Get service endpoint count from Kubernetes
    # Why needed: Provides endpoint count for validation
    # Impact: Endpoint count is retrieved
    # kubectl get endpoints: Get endpoint information
    # -n "$NAMESPACE": Target namespace
    # "$service_name": Service name to check
    # -o jsonpath='{.subsets[0].addresses[*].ip}': Extract endpoint IPs from JSON
    # 2>/dev/null: Suppress error messages
    # | wc -w: Count words (IP addresses)
    
    if [ "$endpoint_count" -eq 0 ]; then
        # Purpose: Check if service has no endpoints
        # Why needed: Validates that service has backing pods
        # Impact: Proceeds with error handling if no endpoints
        
        record_health "$component" "ERROR" "No endpoints available"
        # Purpose: Record no endpoints error
        # Why needed: Tracks no endpoints error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Service ${service_name} has no endpoints"
        # Purpose: Log no endpoints error
        # Why needed: Informs user that service has no endpoints
        # Impact: User knows service has no endpoints
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates service health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # TEST SERVICE CONNECTIVITY
    # =============================================================================
    # Purpose: Test service connectivity using curl
    # Why needed: Validates that service is actually accessible
    
    local service_ip
    # Purpose: Variable to store service ClusterIP
    # Why needed: Provides service IP for connectivity testing
    # Impact: Will contain the service ClusterIP
    
    service_ip=$(kubectl get service -n "$NAMESPACE" "$service_name" -o jsonpath='{.spec.clusterIP}')
    # Purpose: Get service ClusterIP from Kubernetes
    # Why needed: Provides service IP for connectivity testing
    # Impact: Service IP is retrieved
    # kubectl get service: Get service information
    # -n "$NAMESPACE": Target namespace
    # "$service_name": Service name to check
    # -o jsonpath='{.spec.clusterIP}': Extract ClusterIP from JSON
    
    if kubectl run health-check-pod --rm -i --restart=Never --image=curlimages/curl:latest -- \
        curl -f -s --max-time 10 "http://${service_ip}:${port}${path}" >/dev/null 2>&1; then
        # Purpose: Test service connectivity using curl
        # Why needed: Validates that service is actually accessible
        # Impact: Service connectivity is tested
        # kubectl run: Create and run a pod
        # health-check-pod: Pod name for testing
        # --rm: Remove pod after completion
        # -i: Interactive mode
        # --restart=Never: Don't restart pod
        # --image=curlimages/curl:latest: Use curl image
        # curl: HTTP client
        # -f: Fail silently on HTTP errors
        # -s: Silent mode
        # --max-time 10: Maximum time for request (10 seconds)
        # "http://${service_ip}:${port}${path}": Target service URL
        # >/dev/null 2>&1: Suppress output
        
        record_health "$component" "SUCCESS" "Service is accessible"
        # Purpose: Record successful service health check
        # Why needed: Tracks successful service health for reporting
        # Impact: Success is recorded in health tracking
        
        print_status "SUCCESS" "Service ${service_name} is accessible on port ${port}"
        # Purpose: Log successful service health check
        # Why needed: Confirms service health check was successful
        # Impact: User knows service is accessible
        
        return 0
        # Purpose: Exit function with success status
        # Why needed: Indicates service health check succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle service connectivity failure
        # Why needed: Provides error feedback for service issues
        # Impact: Logs error message for service connectivity
        
        record_health "$component" "ERROR" "Service not accessible"
        # Purpose: Record service connectivity error
        # Why needed: Tracks service connectivity error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Service ${service_name} is not accessible on port ${port}"
        # Purpose: Log service connectivity error
        # Why needed: Informs user that service is not accessible
        # Impact: User knows service is not accessible
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates service health check failed
        # Impact: Function returns failure
    fi
}

# Function: Check deployment health
check_deployment_health() {
    # =============================================================================
    # CHECK DEPLOYMENT HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of a Kubernetes deployment with comprehensive checks.
    # Provides detailed deployment-level health validation including replica status and availability.
    # =============================================================================
    
    # Purpose: Validate the health status of a Kubernetes deployment
    # Why needed: Ensures deployments are properly configured and all replicas are healthy
    # Impact: Provides detailed deployment-level health validation
    # Parameters:
    #   $1: Deployment name to check
    #   $2: Component name for reporting
    # Usage: check_deployment_health "backend-deployment" "backend"
    # Returns: 0 if deployment is healthy, 1 if unhealthy
    
    local deployment_name=$1
    # Purpose: Specifies the deployment name to check
    # Why needed: Identifies which deployment to validate for health
    # Impact: Function validates the specified deployment
    # Parameter: $1 is the deployment name
    
    local component=$2
    # Purpose: Specifies the component name for reporting
    # Why needed: Provides component context for health reporting
    # Impact: Health status is associated with the component
    # Parameter: $2 is the component name
    
    print_status "INFO" "Checking health of deployment: ${deployment_name}"
    # Purpose: Log the start of deployment health check
    # Why needed: Informs user that deployment health check has begun
    # Impact: User knows deployment health check has started
    
    # =============================================================================
    # CHECK DEPLOYMENT EXISTENCE
    # =============================================================================
    # Purpose: Verify that the deployment exists in Kubernetes
    # Why needed: Ensures deployment exists before performing health checks
    
    if ! kubectl get deployment -n "$NAMESPACE" "$deployment_name" >/dev/null 2>&1; then
        # Purpose: Check if deployment exists in Kubernetes
        # Why needed: Validates that deployment exists before health checks
        # Impact: Proceeds with error handling if deployment not found
        # kubectl get deployment: Get deployment information
        # -n "$NAMESPACE": Target namespace
        # "$deployment_name": Deployment name to check
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "$component" "ERROR" "Deployment not found"
        # Purpose: Record deployment not found error
        # Why needed: Tracks deployment not found error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Deployment ${deployment_name} not found"
        # Purpose: Log deployment not found error
        # Why needed: Informs user that deployment was not found
        # Impact: User knows deployment was not found
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates deployment health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # GET DEPLOYMENT STATUS
    # =============================================================================
    # Purpose: Retrieve deployment replica status from Kubernetes
    # Why needed: Provides replica status for validation
    
    local desired_replicas
    # Purpose: Variable to store desired replica count
    # Why needed: Provides desired replica count for validation
    # Impact: Will contain the desired replica count
    
    local ready_replicas
    # Purpose: Variable to store ready replica count
    # Why needed: Provides ready replica count for validation
    # Impact: Will contain the ready replica count
    
    local available_replicas
    # Purpose: Variable to store available replica count
    # Why needed: Provides available replica count for validation
    # Impact: Will contain the available replica count
    
    local updated_replicas
    # Purpose: Variable to store updated replica count
    # Why needed: Provides updated replica count for validation
    # Impact: Will contain the updated replica count
    
    desired_replicas=$(kubectl get deployment -n "$NAMESPACE" "$deployment_name" -o jsonpath='{.spec.replicas}')
    # Purpose: Get desired replica count from Kubernetes
    # Why needed: Provides desired replica count for validation
    # Impact: Desired replica count is retrieved
    # kubectl get deployment: Get deployment information
    # -n "$NAMESPACE": Target namespace
    # "$deployment_name": Deployment name to check
    # -o jsonpath='{.spec.replicas}': Extract desired replica count from JSON
    
    ready_replicas=$(kubectl get deployment -n "$NAMESPACE" "$deployment_name" -o jsonpath='{.status.readyReplicas}')
    # Purpose: Get ready replica count from Kubernetes
    # Why needed: Provides ready replica count for validation
    # Impact: Ready replica count is retrieved
    # kubectl get deployment: Get deployment information
    # -n "$NAMESPACE": Target namespace
    # "$deployment_name": Deployment name to check
    # -o jsonpath='{.status.readyReplicas}': Extract ready replica count from JSON
    
    available_replicas=$(kubectl get deployment -n "$NAMESPACE" "$deployment_name" -o jsonpath='{.status.availableReplicas}')
    # Purpose: Get available replica count from Kubernetes
    # Why needed: Provides available replica count for validation
    # Impact: Available replica count is retrieved
    # kubectl get deployment: Get deployment information
    # -n "$NAMESPACE": Target namespace
    # "$deployment_name": Deployment name to check
    # -o jsonpath='{.status.availableReplicas}': Extract available replica count from JSON
    
    updated_replicas=$(kubectl get deployment -n "$NAMESPACE" "$deployment_name" -o jsonpath='{.status.updatedReplicas}')
    # Purpose: Get updated replica count from Kubernetes
    # Why needed: Provides updated replica count for validation
    # Impact: Updated replica count is retrieved
    # kubectl get deployment: Get deployment information
    # -n "$NAMESPACE": Target namespace
    # "$deployment_name": Deployment name to check
    # -o jsonpath='{.status.updatedReplicas}': Extract updated replica count from JSON
    
    # =============================================================================
    # CHECK REPLICA STATUS
    # =============================================================================
    # Purpose: Validate that all replicas are in proper state
    # Why needed: Ensures deployment is fully healthy
    
    if [ "$ready_replicas" != "$desired_replicas" ]; then
        # Purpose: Check if all replicas are ready
        # Why needed: Validates that all replicas are ready to serve traffic
        # Impact: Proceeds with warning if not all replicas ready
        
        record_health "$component" "WARNING" "Not all replicas ready (${ready_replicas}/${desired_replicas})"
        # Purpose: Record replica readiness warning
        # Why needed: Tracks replica readiness warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "Deployment ${deployment_name} not all replicas ready (${ready_replicas}/${desired_replicas})"
        # Purpose: Log replica readiness warning
        # Why needed: Informs user that not all replicas are ready
        # Impact: User knows not all replicas are ready
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates deployment health check failed
        # Impact: Function returns failure
    fi
    
    if [ "$available_replicas" != "$desired_replicas" ]; then
        # Purpose: Check if all replicas are available
        # Why needed: Validates that all replicas are available for service
        # Impact: Proceeds with warning if not all replicas available
        
        record_health "$component" "WARNING" "Not all replicas available (${available_replicas}/${desired_replicas})"
        # Purpose: Record replica availability warning
        # Why needed: Tracks replica availability warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "Deployment ${deployment_name} not all replicas available (${available_replicas}/${desired_replicas})"
        # Purpose: Log replica availability warning
        # Why needed: Informs user that not all replicas are available
        # Impact: User knows not all replicas are available
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates deployment health check failed
        # Impact: Function returns failure
    fi
    
    if [ "$updated_replicas" != "$desired_replicas" ]; then
        # Purpose: Check if all replicas are updated
        # Why needed: Validates that all replicas are running the latest version
        # Impact: Proceeds with warning if not all replicas updated
        
        record_health "$component" "WARNING" "Not all replicas updated (${updated_replicas}/${desired_replicas})"
        # Purpose: Record replica update warning
        # Why needed: Tracks replica update warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "Deployment ${deployment_name} not all replicas updated (${updated_replicas}/${desired_replicas})"
        # Purpose: Log replica update warning
        # Why needed: Informs user that not all replicas are updated
        # Impact: User knows not all replicas are updated
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates deployment health check failed
        # Impact: Function returns failure
    fi
    
    record_health "$component" "SUCCESS" "All replicas healthy (${ready_replicas}/${desired_replicas})"
    # Purpose: Record successful deployment health check
    # Why needed: Tracks successful deployment health for reporting
    # Impact: Success is recorded in health tracking
    
    print_status "SUCCESS" "Deployment ${deployment_name} is healthy (${ready_replicas}/${desired_replicas} replicas)"
    # Purpose: Log successful deployment health check
    # Why needed: Confirms deployment health check was successful
    # Impact: User knows deployment is healthy
    
    return 0
    # Purpose: Exit function with success status
    # Why needed: Indicates deployment health check succeeded
    # Impact: Function returns success
}

# Function: Check PVC health
check_pvc_health() {
    # =============================================================================
    # CHECK PVC HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of a PersistentVolumeClaim with comprehensive checks.
    # Provides detailed PVC-level health validation including existence, binding status, and capacity.
    # =============================================================================
    
    # Purpose: Validate the health status of a PersistentVolumeClaim
    # Why needed: Ensures PVCs are properly bound and have storage capacity
    # Impact: Provides detailed PVC-level health validation
    # Parameters:
    #   $1: PVC name to check
    #   $2: Component name for reporting
    # Usage: check_pvc_health "database-pvc" "database"
    # Returns: 0 if PVC is healthy, 1 if unhealthy
    
    local pvc_name=$1
    # Purpose: Specifies the PVC name to check
    # Why needed: Identifies which PVC to validate for health
    # Impact: Function validates the specified PVC
    # Parameter: $1 is the PVC name
    
    local component=$2
    # Purpose: Specifies the component name for reporting
    # Why needed: Provides component context for health reporting
    # Impact: Health status is associated with the component
    # Parameter: $2 is the component name
    
    print_status "INFO" "Checking health of PVC: ${pvc_name}"
    # Purpose: Log the start of PVC health check
    # Why needed: Informs user that PVC health check has begun
    # Impact: User knows PVC health check has started
    
    # =============================================================================
    # CHECK PVC EXISTENCE
    # =============================================================================
    # Purpose: Verify that the PVC exists in Kubernetes
    # Why needed: Ensures PVC exists before performing health checks
    
    if ! kubectl get pvc -n "$NAMESPACE" "$pvc_name" >/dev/null 2>&1; then
        # Purpose: Check if PVC exists in Kubernetes
        # Why needed: Validates that PVC exists before health checks
        # Impact: Proceeds with error handling if PVC not found
        # kubectl get pvc: Get PVC information
        # -n "$NAMESPACE": Target namespace
        # "$pvc_name": PVC name to check
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "$component" "ERROR" "PVC not found"
        # Purpose: Record PVC not found error
        # Why needed: Tracks PVC not found error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "PVC ${pvc_name} not found"
        # Purpose: Log PVC not found error
        # Why needed: Informs user that PVC was not found
        # Impact: User knows PVC was not found
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates PVC health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # GET PVC STATUS
    # =============================================================================
    # Purpose: Retrieve PVC binding status from Kubernetes
    # Why needed: Provides PVC binding status for validation
    
    local pvc_status
    # Purpose: Variable to store PVC status
    # Why needed: Provides PVC status for validation
    # Impact: Will contain the PVC status
    
    pvc_status=$(kubectl get pvc -n "$NAMESPACE" "$pvc_name" -o jsonpath='{.status.phase}')
    # Purpose: Get PVC status from Kubernetes
    # Why needed: Provides PVC binding status for validation
    # Impact: PVC status is retrieved
    # kubectl get pvc: Get PVC information
    # -n "$NAMESPACE": Target namespace
    # "$pvc_name": PVC name to check
    # -o jsonpath='{.status.phase}': Extract PVC phase from JSON
    
    if [ "$pvc_status" != "Bound" ]; then
        # Purpose: Check if PVC is not bound
        # Why needed: Validates that PVC is properly bound to a PersistentVolume
        # Impact: Proceeds with error handling if PVC not bound
        
        record_health "$component" "ERROR" "PVC not bound (status: ${pvc_status})"
        # Purpose: Record PVC binding error
        # Why needed: Tracks PVC binding error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "PVC ${pvc_name} is not bound (status: ${pvc_status})"
        # Purpose: Log PVC binding error
        # Why needed: Informs user that PVC is not bound
        # Impact: User knows PVC is not bound
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates PVC health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # GET PVC CAPACITY
    # =============================================================================
    # Purpose: Retrieve PVC storage capacity from Kubernetes
    # Why needed: Provides storage capacity information for validation
    
    local pvc_capacity
    # Purpose: Variable to store PVC capacity
    # Why needed: Provides PVC capacity for validation
    # Impact: Will contain the PVC capacity
    
    pvc_capacity=$(kubectl get pvc -n "$NAMESPACE" "$pvc_name" -o jsonpath='{.status.capacity.storage}')
    # Purpose: Get PVC capacity from Kubernetes
    # Why needed: Provides PVC storage capacity for validation
    # Impact: PVC capacity is retrieved
    # kubectl get pvc: Get PVC information
    # -n "$NAMESPACE": Target namespace
    # "$pvc_name": PVC name to check
    # -o jsonpath='{.status.capacity.storage}': Extract storage capacity from JSON
    
    record_health "$component" "SUCCESS" "PVC is bound (capacity: ${pvc_capacity})"
    # Purpose: Record successful PVC health check
    # Why needed: Tracks successful PVC health for reporting
    # Impact: Success is recorded in health tracking
    
    print_status "SUCCESS" "PVC ${pvc_name} is bound (capacity: ${pvc_capacity})"
    # Purpose: Log successful PVC health check
    # Why needed: Confirms PVC health check was successful
    # Impact: User knows PVC is healthy
    
    return 0
    # Purpose: Exit function with success status
    # Why needed: Indicates PVC health check succeeded
    # Impact: Function returns success
}

# =============================================================================
# MAIN HEALTH CHECK FUNCTIONS
# =============================================================================

# Function: Check e-commerce application health
check_ecommerce_health() {
    # =============================================================================
    # CHECK E-COMMERCE APPLICATION HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of the entire e-commerce application stack.
    # Provides comprehensive health validation for all e-commerce components including deployments and services.
    # =============================================================================
    
    # Purpose: Validate the health status of the entire e-commerce application
    # Why needed: Ensures all e-commerce components are healthy and functioning properly
    # Impact: Provides comprehensive e-commerce application health validation
    # Parameters: None (uses predefined component lists)
    # Usage: check_ecommerce_health
    # Returns: None (calls other health check functions)
    
    print_status "INFO" "Checking e-commerce application health"
    # Purpose: Log the start of e-commerce application health check
    # Why needed: Informs user that e-commerce application health check has begun
    # Impact: User knows e-commerce application health check has started
    
    # =============================================================================
    # CHECK E-COMMERCE DEPLOYMENTS
    # =============================================================================
    # Purpose: Validate health of all e-commerce deployments
    # Why needed: Ensures all e-commerce deployments are healthy
    
    local ecommerce_deployments=(
        "ecommerce-backend-deployment:backend"
        "ecommerce-frontend-deployment:frontend"
        "ecommerce-database-deployment:database"
    )
    # Purpose: Array of e-commerce deployment specifications
    # Why needed: Provides list of deployments to check for health
    # Impact: Function validates all specified deployments
    # Format: "deployment-name:component-name"
    # ecommerce-backend-deployment:backend: Backend deployment and component
    # ecommerce-frontend-deployment:frontend: Frontend deployment and component
    # ecommerce-database-deployment:database: Database deployment and component
    
    for deployment_info in "${ecommerce_deployments[@]}"; do
        # Purpose: Loop through each e-commerce deployment
        # Why needed: Processes each deployment for health validation
        # Impact: Each deployment is validated for health
        # "${ecommerce_deployments[@]}": Array of deployment specifications
        
        IFS=':' read -r deployment_name component <<< "$deployment_info"
        # Purpose: Parse deployment specification into components
        # Why needed: Extracts deployment name and component name from specification
        # Impact: Deployment components are extracted for health checking
        # IFS=':': Set field separator to colon
        # read -r: Read input with backslash escaping
        # deployment_name: Deployment name component
        # component: Component name component
        # <<< "$deployment_info": Use deployment specification as input
        
        check_deployment_health "$deployment_name" "$component"
        # Purpose: Check health of specific deployment
        # Why needed: Validates individual deployment health
        # Impact: Deployment health is validated
        # check_deployment_health: Function to check deployment health
        # "$deployment_name": Deployment name to check
        # "$component": Component name for reporting
    done
    
    # =============================================================================
    # CHECK E-COMMERCE SERVICES
    # =============================================================================
    # Purpose: Validate health of all e-commerce services
    # Why needed: Ensures all e-commerce services are healthy and accessible
    
    local ecommerce_services=(
        "ecommerce-backend-service:backend:8000"
        "ecommerce-frontend-service:frontend:3000"
        "ecommerce-database-service:database:5432"
    )
    # Purpose: Array of e-commerce service specifications
    # Why needed: Provides list of services to check for health
    # Impact: Function validates all specified services
    # Format: "service-name:component-name:port"
    # ecommerce-backend-service:backend:8000: Backend service, component, and port
    # ecommerce-frontend-service:frontend:3000: Frontend service, component, and port
    # ecommerce-database-service:database:5432: Database service, component, and port
    
    for service_info in "${ecommerce_services[@]}"; do
        # Purpose: Loop through each e-commerce service
        # Why needed: Processes each service for health validation
        # Impact: Each service is validated for health
        # "${ecommerce_services[@]}": Array of service specifications
        
        IFS=':' read -r service_name component port <<< "$service_info"
        # Purpose: Parse service specification into components
        # Why needed: Extracts service name, component name, and port from specification
        # Impact: Service components are extracted for health checking
        # IFS=':': Set field separator to colon
        # read -r: Read input with backslash escaping
        # service_name: Service name component
        # component: Component name component
        # port: Port number component
        # <<< "$service_info": Use service specification as input
        
        check_service_health "$service_name" "$component" "$port"
        # Purpose: Check health of specific service
        # Why needed: Validates individual service health
        # Impact: Service health is validated
        # check_service_health: Function to check service health
        # "$service_name": Service name to check
        # "$component": Component name for reporting
        # "$port": Port number to test
    done
}

# Function: Check monitoring stack health
check_monitoring_health() {
    # =============================================================================
    # CHECK MONITORING STACK HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of the entire monitoring stack.
    # Provides comprehensive health validation for all monitoring components including Prometheus, Grafana, and AlertManager.
    # =============================================================================
    
    # Purpose: Validate the health status of the entire monitoring stack
    # Why needed: Ensures all monitoring components are healthy and functioning properly
    # Impact: Provides comprehensive monitoring stack health validation
    # Parameters: None (uses predefined component names)
    # Usage: check_monitoring_health
    # Returns: None (calls other health check functions)
    
    print_status "INFO" "Checking monitoring stack health"
    # Purpose: Log the start of monitoring stack health check
    # Why needed: Informs user that monitoring stack health check has begun
    # Impact: User knows monitoring stack health check has started
    
    # =============================================================================
    # CHECK PROMETHEUS COMPONENTS
    # =============================================================================
    # Purpose: Validate health of Prometheus monitoring components
    # Why needed: Ensures Prometheus is healthy for metrics collection
    
    check_deployment_health "prometheus-deployment" "prometheus"
    # Purpose: Check health of Prometheus deployment
    # Why needed: Validates that Prometheus deployment is healthy
    # Impact: Prometheus deployment health is validated
    # check_deployment_health: Function to check deployment health
    # "prometheus-deployment": Prometheus deployment name
    # "prometheus": Component name for reporting
    
    check_service_health "prometheus-service" "prometheus" "9090" "/"
    # Purpose: Check health of Prometheus service
    # Why needed: Validates that Prometheus service is accessible
    # Impact: Prometheus service health is validated
    # check_service_health: Function to check service health
    # "prometheus-service": Prometheus service name
    # "prometheus": Component name for reporting
    # "9090": Prometheus service port
    # "/": Prometheus service path
    
    check_pvc_health "prometheus-pvc" "prometheus"
    # Purpose: Check health of Prometheus PVC
    # Why needed: Validates that Prometheus has persistent storage
    # Impact: Prometheus PVC health is validated
    # check_pvc_health: Function to check PVC health
    # "prometheus-pvc": Prometheus PVC name
    # "prometheus": Component name for reporting
    
    # =============================================================================
    # CHECK GRAFANA COMPONENTS
    # =============================================================================
    # Purpose: Validate health of Grafana monitoring components
    # Why needed: Ensures Grafana is healthy for visualization
    
    check_deployment_health "grafana-deployment" "grafana"
    # Purpose: Check health of Grafana deployment
    # Why needed: Validates that Grafana deployment is healthy
    # Impact: Grafana deployment health is validated
    # check_deployment_health: Function to check deployment health
    # "grafana-deployment": Grafana deployment name
    # "grafana": Component name for reporting
    
    check_service_health "grafana-service" "grafana" "3000" "/"
    # Purpose: Check health of Grafana service
    # Why needed: Validates that Grafana service is accessible
    # Impact: Grafana service health is validated
    # check_service_health: Function to check service health
    # "grafana-service": Grafana service name
    # "grafana": Component name for reporting
    # "3000": Grafana service port
    # "/": Grafana service path
    
    check_pvc_health "grafana-pvc" "grafana"
    # Purpose: Check health of Grafana PVC
    # Why needed: Validates that Grafana has persistent storage
    # Impact: Grafana PVC health is validated
    # check_pvc_health: Function to check PVC health
    # "grafana-pvc": Grafana PVC name
    # "grafana": Component name for reporting
    
    # =============================================================================
    # CHECK ALERTMANAGER COMPONENTS
    # =============================================================================
    # Purpose: Validate health of AlertManager monitoring components
    # Why needed: Ensures AlertManager is healthy for alerting
    
    check_deployment_health "alertmanager-deployment" "alertmanager"
    # Purpose: Check health of AlertManager deployment
    # Why needed: Validates that AlertManager deployment is healthy
    # Impact: AlertManager deployment health is validated
    # check_deployment_health: Function to check deployment health
    # "alertmanager-deployment": AlertManager deployment name
    # "alertmanager": Component name for reporting
    
    check_service_health "alertmanager-service" "alertmanager" "9093" "/"
    # Purpose: Check health of AlertManager service
    # Why needed: Validates that AlertManager service is accessible
    # Impact: AlertManager service health is validated
    # check_service_health: Function to check service health
    # "alertmanager-service": AlertManager service name
    # "alertmanager": Component name for reporting
    # "9093": AlertManager service port
    # "/": AlertManager service path
    
    check_pvc_health "alertmanager-pvc" "alertmanager"
    # Purpose: Check health of AlertManager PVC
    # Why needed: Validates that AlertManager has persistent storage
    # Impact: AlertManager PVC health is validated
    # check_pvc_health: Function to check PVC health
    # "alertmanager-pvc": AlertManager PVC name
    # "alertmanager": Component name for reporting
}

# Function: Check namespace health
check_namespace_health() {
    # =============================================================================
    # CHECK NAMESPACE HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of the Kubernetes namespace with comprehensive checks.
    # Provides detailed namespace-level health validation including existence, ResourceQuota, and LimitRange.
    # =============================================================================
    
    # Purpose: Validate the health status of the Kubernetes namespace
    # Why needed: Ensures namespace exists and has proper resource management configured
    # Impact: Provides detailed namespace-level health validation
    # Parameters: None (uses global NAMESPACE variable)
    # Usage: check_namespace_health
    # Returns: 0 if namespace is healthy, 1 if unhealthy
    
    print_status "INFO" "Checking namespace health"
    # Purpose: Log the start of namespace health check
    # Why needed: Informs user that namespace health check has begun
    # Impact: User knows namespace health check has started
    
    # =============================================================================
    # CHECK NAMESPACE EXISTENCE
    # =============================================================================
    # Purpose: Verify that the namespace exists in Kubernetes
    # Why needed: Ensures namespace exists before performing health checks
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if namespace exists in Kubernetes
        # Why needed: Validates that namespace exists before health checks
        # Impact: Proceeds with error handling if namespace not found
        # kubectl get namespace: Get namespace information
        # "$NAMESPACE": Namespace name to check
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "namespace" "ERROR" "Namespace not found"
        # Purpose: Record namespace not found error
        # Why needed: Tracks namespace not found error for reporting
        # Impact: Error is recorded in health tracking
        
        print_status "ERROR" "Namespace ${NAMESPACE} not found"
        # Purpose: Log namespace not found error
        # Why needed: Informs user that namespace was not found
        # Impact: User knows namespace was not found
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates namespace health check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK RESOURCEQUOTA
    # =============================================================================
    # Purpose: Verify that ResourceQuota is configured for the namespace
    # Why needed: Ensures proper resource management and limits are in place
    
    if kubectl get resourcequota -n "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if ResourceQuota exists in namespace
        # Why needed: Validates that resource quotas are configured
        # Impact: Proceeds with success if ResourceQuota found
        # kubectl get resourcequota: Get ResourceQuota information
        # -n "$NAMESPACE": Target namespace
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "namespace" "SUCCESS" "ResourceQuota configured"
        # Purpose: Record ResourceQuota success
        # Why needed: Tracks ResourceQuota success for reporting
        # Impact: Success is recorded in health tracking
        
        print_status "SUCCESS" "ResourceQuota is configured"
        # Purpose: Log ResourceQuota success
        # Why needed: Confirms ResourceQuota is configured
        # Impact: User knows ResourceQuota is configured
    else
        # Purpose: Handle ResourceQuota not found case
        # Why needed: Provides warning when ResourceQuota is missing
        # Impact: Logs warning message for missing ResourceQuota
        
        record_health "namespace" "WARNING" "No ResourceQuota found"
        # Purpose: Record ResourceQuota warning
        # Why needed: Tracks ResourceQuota warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "No ResourceQuota found"
        # Purpose: Log ResourceQuota warning
        # Why needed: Informs user that ResourceQuota is missing
        # Impact: User knows ResourceQuota is missing
    fi
    
    # =============================================================================
    # CHECK LIMITRANGE
    # =============================================================================
    # Purpose: Verify that LimitRange is configured for the namespace
    # Why needed: Ensures proper resource limits are in place for pods and containers
    
    if kubectl get limitrange -n "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if LimitRange exists in namespace
        # Why needed: Validates that resource limits are configured
        # Impact: Proceeds with success if LimitRange found
        # kubectl get limitrange: Get LimitRange information
        # -n "$NAMESPACE": Target namespace
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        record_health "namespace" "SUCCESS" "LimitRange configured"
        # Purpose: Record LimitRange success
        # Why needed: Tracks LimitRange success for reporting
        # Impact: Success is recorded in health tracking
        
        print_status "SUCCESS" "LimitRange is configured"
        # Purpose: Log LimitRange success
        # Why needed: Confirms LimitRange is configured
        # Impact: User knows LimitRange is configured
    else
        # Purpose: Handle LimitRange not found case
        # Why needed: Provides warning when LimitRange is missing
        # Impact: Logs warning message for missing LimitRange
        
        record_health "namespace" "WARNING" "No LimitRange found"
        # Purpose: Record LimitRange warning
        # Why needed: Tracks LimitRange warning for reporting
        # Impact: Warning is recorded in health tracking
        
        print_status "WARNING" "No LimitRange found"
        # Purpose: Log LimitRange warning
        # Why needed: Informs user that LimitRange is missing
        # Impact: User knows LimitRange is missing
    fi
}

# =============================================================================
# JSON OUTPUT FUNCTION
# =============================================================================

output_json() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "{"
    echo "  \"timestamp\": \"${timestamp}\","
    echo "  \"namespace\": \"${NAMESPACE}\","
    echo "  \"overall_status\": \"$([ $FAILED_TESTS -eq 0 ] && echo "healthy" || echo "unhealthy")\","
    echo "  \"components\": {"
    
    local first=true
    for component in "${!HEALTH_STATUS[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        echo "    \"${component}\": {"
        echo "      \"status\": \"${HEALTH_STATUS[$component]}\","
        echo "      \"details\": \"${HEALTH_DETAILS[$component]}\""
        echo -n "    }"
    done
    
    echo ""
    echo "  }"
    echo "}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_status "INFO" "Starting comprehensive health check for namespace: ${NAMESPACE}"

# Check prerequisites
if ! command -v kubectl >/dev/null 2>&1; then
    print_status "ERROR" "kubectl command not found"
    exit 1
fi

# Perform health checks
check_namespace_health
check_ecommerce_health
check_monitoring_health

# Count results
for status in "${HEALTH_STATUS[@]}"; do
    ((TOTAL_TESTS++))
    case $status in
        "SUCCESS")
            ((PASSED_TESTS++))
            ;;
        "ERROR")
            ((FAILED_TESTS++))
            ;;
    esac
done

# Output results
if [ "$JSON_OUTPUT" = true ]; then
    output_json
else
    echo ""
    echo "============================================================================="
    echo "HEALTH CHECK SUMMARY"
    echo "============================================================================="
    echo "Total Components: ${TOTAL_TESTS}"
    echo -e "Healthy: ${GREEN}${PASSED_TESTS}${NC}"
    echo -e "Unhealthy: ${RED}${FAILED_TESTS}${NC}"
    echo -e "Warnings: ${YELLOW}$((TOTAL_TESTS - PASSED_TESTS - FAILED_TESTS))${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        print_status "SUCCESS" "All components are healthy!"
        exit 0
    else
        print_status "ERROR" "Some components are unhealthy. Please check the details above."
        exit 1
    fi
fi
