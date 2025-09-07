#!/bin/bash
# =============================================================================
# MONITORING STACK VALIDATION SCRIPT
# =============================================================================
# This script provides comprehensive validation of the e-commerce monitoring
# stack with advanced Kubernetes workload management capabilities including
# Prometheus, Grafana, AlertManager, and monitoring integration validation.
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
# MONITORING VALIDATION CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent monitoring validation configuration throughout the script.
# =============================================================================

NAMESPACE="${1:-ecommerce}"
# Purpose: Specifies the Kubernetes namespace for monitoring validation
# Why needed: Provides consistent namespace reference for all monitoring validations
# Impact: All monitoring validations target resources in this namespace
# Value: Defaults to 'ecommerce', accepts any valid namespace name

# =============================================================================
# COLOR CODES FOR OUTPUT FORMATTING
# =============================================================================
# Define color codes for consistent output formatting throughout the script.
# =============================================================================

RED='\033[0;31m'
# Purpose: Red color code for error messages and failed validations
# Why needed: Provides visual distinction for failed validations
# Impact: Failed validations are displayed in red color
# Usage: Used in print_status() function for ERROR status messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages and passed validations
# Why needed: Provides visual distinction for successful validations
# Impact: Passed validations are displayed in green color
# Usage: Used in print_status() function for SUCCESS status messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages and warning validations
# Why needed: Provides visual distinction for warning validations
# Impact: Warning validations are displayed in yellow color
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
# VALIDATION TRACKING VARIABLES
# =============================================================================
# Variables to track validation results and statistics.
# =============================================================================

TOTAL_TESTS=0
# Purpose: Counter for total number of validation tests performed
# Why needed: Provides statistics for validation coverage
# Impact: Tracks the total number of tests executed
# Usage: Incremented for each validation test performed

PASSED_TESTS=0
# Purpose: Counter for number of passed validation tests
# Why needed: Provides statistics for validation success rate
# Impact: Tracks the number of successful validations
# Usage: Incremented when validation tests pass

FAILED_TESTS=0
# Purpose: Counter for number of failed validation tests
# Why needed: Provides statistics for validation failure rate
# Impact: Tracks the number of failed validations
# Usage: Incremented when validation tests fail

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp and test counting for
    # monitoring stack validation with visual distinction and test tracking.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps and test counting
    # Why needed: Provides visual feedback and consistent logging for monitoring validation
    # Impact: Users can easily identify message types and test progress is tracked
    # Parameters:
    #   $1: Status type (INFO, SUCCESS, WARNING, ERROR)
    #   $2: Message to display
    # Usage: print_status "SUCCESS" "Prometheus is running"
    
    local status=$1
    # Purpose: Specifies the type of status message
    # Why needed: Determines color and formatting for the message
    # Impact: Different status types get different colors for easy identification
    # Parameter: $1 is the status type (INFO, SUCCESS, WARNING, ERROR)
    
    local message=$2
    # Purpose: Contains the message text to display
    # Why needed: Provides the actual message content
    # Impact: Users see the specific message about the validation
    # Parameter: $2 is the message text to display
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp for message identification
    # Why needed: Provides temporal context for validation operations
    # Impact: All messages include timestamp for chronological tracking
    # Format: YYYY-MM-DD HH:MM:SS (e.g., 2024-12-15 14:30:22)
    
    case $status in
        "INFO")
            # Purpose: Displays informational messages in blue color
            # Why needed: Provides neutral information about validation progress
            # Impact: Users see informational messages in blue
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            ;;
        "SUCCESS")
            # Purpose: Displays success messages in green color and increments passed tests
            # Why needed: Confirms successful validation and tracks test results
            # Impact: Users see success messages in green and test count increases
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            ((PASSED_TESTS++))
            ;;
        "WARNING")
            # Purpose: Displays warning messages in yellow color
            # Why needed: Alerts users to potential issues without failing validation
            # Impact: Users see warning messages in yellow
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            ;;
        "ERROR")
            # Purpose: Displays error messages in red color and increments failed tests
            # Why needed: Reports validation failures and tracks test results
            # Impact: Users see error messages in red and failure count increases
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            ((FAILED_TESTS++))
            ;;
    esac
    ((TOTAL_TESTS++))
    # Purpose: Increments total test counter for each status message
    # Why needed: Tracks total number of validation tests performed
    # Impact: Provides comprehensive test statistics
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Checks if a specified command is available in the system PATH.
    # Provides prerequisite validation for monitoring stack validation.
    # =============================================================================
    
    # Purpose: Check if a command is available in the system
    # Why needed: Validates prerequisites before running monitoring validation
    # Impact: Prevents errors from missing required commands
    # Parameters:
    #   $1: Command name to check (e.g., "kubectl", "curl")
    # Usage: command_exists "kubectl"
    # Returns: 0 if command exists, 1 if not found
    
    command -v "$1" >/dev/null 2>&1
    # Purpose: Check if command exists in PATH
    # Why needed: Validates that required commands are available
    # Impact: Returns exit code 0 if command exists, 1 if not found
    # command -v: Built-in command to find command location
    # "$1": Command name to check
    # >/dev/null: Suppress output
    # 2>&1: Redirect stderr to stdout
}

# Function: Wait for pod to be ready
wait_for_pod() {
    # =============================================================================
    # WAIT FOR POD FUNCTION
    # =============================================================================
    # Waits for a pod to reach Running state and become ready.
    # Provides timeout-based waiting with status validation.
    # =============================================================================
    
    # Purpose: Wait for a pod to become ready with timeout
    # Why needed: Ensures pods are fully ready before validation
    # Impact: Prevents validation failures due to pods not being ready
    # Parameters:
    #   $1: Pod name to wait for
    #   $2: Timeout in seconds (default: 300)
    # Usage: wait_for_pod "prometheus-pod" 300
    # Returns: 0 if pod becomes ready, 1 if timeout
    
    local pod_name=$1
    # Purpose: Specifies the pod name to wait for
    # Why needed: Identifies which pod to monitor for readiness
    # Impact: Function waits for the specified pod
    # Parameter: $1 is the pod name
    
    local timeout=${2:-300}
    # Purpose: Sets the maximum wait time in seconds
    # Why needed: Prevents infinite waiting for pod readiness
    # Impact: Function will timeout after specified seconds
    # Parameter: $2 is timeout in seconds (default: 300)
    
    local count=0
    # Purpose: Tracks elapsed time in seconds
    # Why needed: Provides timeout counter for waiting loop
    # Impact: Enables timeout-based waiting logic
    
    print_status "INFO" "Waiting for pod ${pod_name} to be ready (timeout: ${timeout}s)"
    # Purpose: Log the start of pod waiting process
    # Why needed: Informs user that pod waiting has begun
    # Impact: User knows the function is waiting for pod readiness
    
    while [ $count -lt $timeout ]; do
        # Purpose: Loop while within timeout period
        # Why needed: Continues checking pod status until timeout
        # Impact: Function continues checking until timeout or success
        # $count: Current elapsed time in seconds
        # -lt $timeout: Check if elapsed time is less than timeout
        
        if kubectl get pod -n "$NAMESPACE" "$pod_name" -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Running"; then
            # Purpose: Check if pod is in Running phase
            # Why needed: Validates that pod has started successfully
            # Impact: Proceeds to readiness check if pod is running
            # kubectl get pod: Get pod information
            # -n "$NAMESPACE": Target namespace
            # "$pod_name": Pod name to check
            # -o jsonpath='{.status.phase}': Extract pod phase
            # 2>/dev/null: Suppress error messages
            # grep -q "Running": Check if phase is "Running"
            
            if kubectl get pod -n "$NAMESPACE" "$pod_name" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True"; then
                # Purpose: Check if pod is ready using conditions
                # Why needed: Validates that pod is fully ready for validation
                # Impact: Confirms pod is ready for validation
                # kubectl get pod: Get pod information
                # -n "$NAMESPACE": Target namespace
                # "$pod_name": Pod name to check
                # -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}': Extract ready condition status
                # 2>/dev/null: Suppress error messages
                # grep -q "True": Check if ready condition is "True"
                
                print_status "SUCCESS" "Pod ${pod_name} is ready"
                # Purpose: Log successful pod readiness
                # Why needed: Confirms pod is ready for validation
                # Impact: User knows pod is ready
                
                return 0
                # Purpose: Exit function with success status
                # Why needed: Indicates pod is ready
                # Impact: Function returns success
            fi
        fi
        sleep 5
        # Purpose: Wait 5 seconds before next check
        # Why needed: Prevents excessive resource usage during waiting
        # Impact: Function waits 5 seconds between checks
        
        ((count+=5))
        # Purpose: Increment timeout counter by 5 seconds
        # Why needed: Tracks elapsed time for timeout calculation
        # Impact: Counter increases by 5 seconds each iteration
    done
    
    print_status "ERROR" "Pod ${pod_name} failed to become ready within ${timeout}s"
    # Purpose: Log pod readiness timeout
    # Why needed: Informs user that pod failed to become ready
    # Impact: User knows pod readiness failed
    
    return 1
    # Purpose: Exit function with failure status
    # Why needed: Indicates pod readiness failed
    # Impact: Function returns failure
}

# Function: Check if service is accessible
check_service_access() {
    # =============================================================================
    # CHECK SERVICE ACCESS FUNCTION
    # =============================================================================
    # Checks if a Kubernetes service is accessible by testing connectivity.
    # Provides comprehensive service accessibility validation.
    # =============================================================================
    
    # Purpose: Check if a Kubernetes service is accessible
    # Why needed: Validates service connectivity for monitoring stack
    # Impact: Ensures services are reachable for monitoring validation
    # Parameters:
    #   $1: Service name to check
    #   $2: Port number to test
    #   $3: Path to test (default: /)
    #   $4: Timeout in seconds (default: 30)
    # Usage: check_service_access "prometheus-service" "9090" "/" 30
    # Returns: 0 if accessible, 1 if not accessible
    
    local service_name=$1
    # Purpose: Specifies the service name to check
    # Why needed: Identifies which service to test for accessibility
    # Impact: Function tests the specified service
    # Parameter: $1 is the service name
    
    local port=$2
    # Purpose: Specifies the port number to test
    # Why needed: Identifies which port to test for connectivity
    # Impact: Function tests the specified port
    # Parameter: $2 is the port number
    
    local path=${3:-/}
    # Purpose: Specifies the path to test (default: /)
    # Why needed: Identifies which endpoint to test for accessibility
    # Impact: Function tests the specified path
    # Parameter: $3 is the path (default: /)
    
    local timeout=${4:-30}
    # Purpose: Sets the maximum wait time in seconds
    # Why needed: Prevents infinite waiting for service response
    # Impact: Function will timeout after specified seconds
    # Parameter: $4 is timeout in seconds (default: 30)
    
    print_status "INFO" "Checking service ${service_name} accessibility on port ${port}"
    # Purpose: Log the start of service accessibility check
    # Why needed: Informs user that service accessibility check has begun
    # Impact: User knows the function is checking service accessibility
    
    # =============================================================================
    # GET SERVICE IP
    # =============================================================================
    # Purpose: Retrieve the ClusterIP of the service
    # Why needed: Provides the IP address for connectivity testing
    
    local service_ip
    # Purpose: Variable to store service ClusterIP
    # Why needed: Provides service IP for connectivity testing
    # Impact: Will contain the service ClusterIP
    
    service_ip=$(kubectl get service -n "$NAMESPACE" "$service_name" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    # Purpose: Get service ClusterIP
    # Why needed: Provides service IP for connectivity testing
    # Impact: Service IP is retrieved
    # kubectl get service: Get service information
    # -n "$NAMESPACE": Target namespace
    # "$service_name": Service name to check
    # -o jsonpath='{.spec.clusterIP}': Extract ClusterIP from JSON
    # 2>/dev/null: Suppress error messages
    
    if [ -z "$service_ip" ]; then
        # Purpose: Check if service IP was retrieved
        # Why needed: Ensures service exists and has ClusterIP
        # Impact: Proceeds with error if service not found
        
        print_status "ERROR" "Service ${service_name} not found or has no ClusterIP"
        # Purpose: Log service not found error
        # Why needed: Informs user that service is not available
        # Impact: User knows service is not accessible
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates service accessibility check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # TEST SERVICE CONNECTIVITY
    # =============================================================================
    # Purpose: Test service connectivity using curl
    # Why needed: Validates that service is actually accessible
    
    if kubectl run test-pod --rm -i --restart=Never --image=curlimages/curl:latest -- \
        curl -f -s --max-time "$timeout" "http://${service_ip}:${port}${path}" >/dev/null 2>&1; then
        # Purpose: Test service connectivity using curl
        # Why needed: Validates that service is actually accessible
        # Impact: Service connectivity is tested
        # kubectl run: Create and run a pod
        # test-pod: Pod name for testing
        # --rm: Remove pod after completion
        # -i: Interactive mode
        # --restart=Never: Don't restart pod
        # --image=curlimages/curl:latest: Use curl image
        # curl: HTTP client
        # -f: Fail silently on HTTP errors
        # -s: Silent mode
        # --max-time "$timeout": Maximum time for request
        # "http://${service_ip}:${port}${path}": Target service URL
        # >/dev/null 2>&1: Suppress output
        
        print_status "SUCCESS" "Service ${service_name} is accessible on port ${port}"
        # Purpose: Log successful service accessibility
        # Why needed: Confirms service is accessible
        # Impact: User knows service is accessible
        
        return 0
        # Purpose: Exit function with success status
        # Why needed: Indicates service accessibility check succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle service accessibility failure
        # Why needed: Provides error feedback for service issues
        # Impact: Logs error message for service accessibility
        
        print_status "ERROR" "Service ${service_name} is not accessible on port ${port}"
        # Purpose: Log service accessibility error
        # Why needed: Informs user that service is not accessible
        # Impact: User knows service is not accessible
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates service accessibility check failed
        # Impact: Function returns failure
    fi
}

# Function: Check metrics endpoint
check_metrics_endpoint() {
    # =============================================================================
    # CHECK METRICS ENDPOINT FUNCTION
    # =============================================================================
    # Checks if a metrics endpoint is accessible and contains expected metrics.
    # Provides comprehensive metrics endpoint validation.
    # =============================================================================
    
    # Purpose: Check if a metrics endpoint is accessible and contains expected metrics
    # Why needed: Validates metrics endpoints for monitoring stack
    # Impact: Ensures metrics endpoints are working for monitoring validation
    # Parameters:
    #   $1: Service name to check
    #   $2: Port number to test
    #   $3: Path to test (default: /metrics)
    # Usage: check_metrics_endpoint "prometheus-service" "9090" "/metrics"
    # Returns: 0 if accessible and contains metrics, 1 if not accessible
    
    local service_name=$1
    # Purpose: Specifies the service name to check
    # Why needed: Identifies which service to test for metrics endpoint
    # Impact: Function tests the specified service
    # Parameter: $1 is the service name
    
    local port=$2
    # Purpose: Specifies the port number to test
    # Why needed: Identifies which port to test for metrics endpoint
    # Impact: Function tests the specified port
    # Parameter: $2 is the port number
    
    local path=${3:-/metrics}
    # Purpose: Specifies the path to test (default: /metrics)
    # Why needed: Identifies which endpoint to test for metrics
    # Impact: Function tests the specified path
    # Parameter: $3 is the path (default: /metrics)
    
    print_status "INFO" "Checking metrics endpoint for ${service_name}"
    # Purpose: Log the start of metrics endpoint check
    # Why needed: Informs user that metrics endpoint check has begun
    # Impact: User knows the function is checking metrics endpoint
    
    # =============================================================================
    # GET SERVICE IP
    # =============================================================================
    # Purpose: Retrieve the ClusterIP of the service
    # Why needed: Provides the IP address for metrics endpoint testing
    
    local service_ip
    # Purpose: Variable to store service ClusterIP
    # Why needed: Provides service IP for metrics endpoint testing
    # Impact: Will contain the service ClusterIP
    
    service_ip=$(kubectl get service -n "$NAMESPACE" "$service_name" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    # Purpose: Get service ClusterIP
    # Why needed: Provides service IP for metrics endpoint testing
    # Impact: Service IP is retrieved
    # kubectl get service: Get service information
    # -n "$NAMESPACE": Target namespace
    # "$service_name": Service name to check
    # -o jsonpath='{.spec.clusterIP}': Extract ClusterIP from JSON
    # 2>/dev/null: Suppress error messages
    
    if [ -z "$service_ip" ]; then
        # Purpose: Check if service IP was retrieved
        # Why needed: Ensures service exists and has ClusterIP
        # Impact: Proceeds with error if service not found
        
        print_status "ERROR" "Service ${service_name} not found"
        # Purpose: Log service not found error
        # Why needed: Informs user that service is not available
        # Impact: User knows service is not accessible
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates metrics endpoint check failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # TEST METRICS ENDPOINT
    # =============================================================================
    # Purpose: Test metrics endpoint accessibility and content
    # Why needed: Validates that metrics endpoint is working and contains metrics
    
    local metrics_output
    # Purpose: Variable to store metrics endpoint output
    # Why needed: Provides metrics content for validation
    # Impact: Will contain the metrics endpoint response
    
    if metrics_output=$(kubectl run test-pod --rm -i --restart=Never --image=curlimages/curl:latest -- \
        curl -f -s --max-time 30 "http://${service_ip}:${port}${path}" 2>/dev/null); then
        # Purpose: Test metrics endpoint accessibility using curl
        # Why needed: Validates that metrics endpoint is accessible
        # Impact: Metrics endpoint accessibility is tested
        # kubectl run: Create and run a pod
        # test-pod: Pod name for testing
        # --rm: Remove pod after completion
        # -i: Interactive mode
        # --restart=Never: Don't restart pod
        # --image=curlimages/curl:latest: Use curl image
        # curl: HTTP client
        # -f: Fail silently on HTTP errors
        # -s: Silent mode
        # --max-time 30: Maximum time for request (30 seconds)
        # "http://${service_ip}:${port}${path}": Target metrics endpoint URL
        # 2>/dev/null: Suppress error messages
        
        # =============================================================================
        # CHECK METRICS CONTENT
        # =============================================================================
        # Purpose: Validate that metrics endpoint contains expected content
        # Why needed: Ensures metrics endpoint is actually providing metrics
        
        if echo "$metrics_output" | grep -q "prometheus_"; then
            # Purpose: Check if metrics contain Prometheus metrics
            # Why needed: Validates that metrics endpoint contains expected metrics
            # Impact: Confirms metrics endpoint is working properly
            # echo "$metrics_output": Output metrics content
            # grep -q "prometheus_": Check if content contains Prometheus metrics
            
            print_status "SUCCESS" "Metrics endpoint for ${service_name} is working and contains Prometheus metrics"
            # Purpose: Log successful metrics endpoint validation
            # Why needed: Confirms metrics endpoint is working
            # Impact: User knows metrics endpoint is working
            
            return 0
            # Purpose: Exit function with success status
            # Why needed: Indicates metrics endpoint check succeeded
            # Impact: Function returns success
        else
            # Purpose: Handle metrics endpoint with unexpected content
            # Why needed: Provides warning for metrics endpoint issues
            # Impact: Logs warning message for metrics endpoint
            
            print_status "WARNING" "Metrics endpoint for ${service_name} is accessible but may not contain expected metrics"
            # Purpose: Log metrics endpoint warning
            # Why needed: Informs user that metrics endpoint may not contain expected metrics
            # Impact: User knows metrics endpoint may have issues
            
            return 0
            # Purpose: Exit function with success status
            # Why needed: Indicates metrics endpoint is accessible
            # Impact: Function returns success
        fi
    else
        # Purpose: Handle metrics endpoint accessibility failure
        # Why needed: Provides error feedback for metrics endpoint issues
        # Impact: Logs error message for metrics endpoint accessibility
        
        print_status "ERROR" "Metrics endpoint for ${service_name} is not accessible"
        # Purpose: Log metrics endpoint accessibility error
        # Why needed: Informs user that metrics endpoint is not accessible
        # Impact: User knows metrics endpoint is not accessible
        
        return 1
        # Purpose: Exit function with failure status
        # Why needed: Indicates metrics endpoint check failed
        # Impact: Function returns failure
    fi
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

print_status "INFO" "Starting monitoring stack validation for namespace: ${NAMESPACE}"

# Check if kubectl is available
if ! command_exists kubectl; then
    print_status "ERROR" "kubectl command not found. Please install kubectl and ensure it's in your PATH"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    print_status "ERROR" "Namespace ${NAMESPACE} does not exist"
    exit 1
fi

print_status "SUCCESS" "Prerequisites check passed"

# =============================================================================
# NAMESPACE VALIDATION
# =============================================================================

print_status "INFO" "Validating namespace configuration"

# Check namespace labels
if kubectl get namespace "$NAMESPACE" -o jsonpath='{.metadata.labels.app}' | grep -q "ecommerce"; then
    print_status "SUCCESS" "Namespace has correct app label"
else
    print_status "WARNING" "Namespace may not have correct app label"
fi

# Check ResourceQuota
if kubectl get resourcequota -n "$NAMESPACE" >/dev/null 2>&1; then
    print_status "SUCCESS" "ResourceQuota found in namespace"
else
    print_status "WARNING" "No ResourceQuota found in namespace"
fi

# Check LimitRange
if kubectl get limitrange -n "$NAMESPACE" >/dev/null 2>&1; then
    print_status "SUCCESS" "LimitRange found in namespace"
else
    print_status "WARNING" "No LimitRange found in namespace"
fi

# =============================================================================
# PROMETHEUS VALIDATION
# =============================================================================

print_status "INFO" "Validating Prometheus deployment"

# Check Prometheus deployment
if kubectl get deployment -n "$NAMESPACE" prometheus-deployment >/dev/null 2>&1; then
    print_status "SUCCESS" "Prometheus deployment exists"
    
    # Check deployment status
    local prometheus_ready
    prometheus_ready=$(kubectl get deployment -n "$NAMESPACE" prometheus-deployment -o jsonpath='{.status.readyReplicas}')
    if [ "$prometheus_ready" = "1" ]; then
        print_status "SUCCESS" "Prometheus deployment is ready"
    else
        print_status "ERROR" "Prometheus deployment is not ready (ready replicas: ${prometheus_ready})"
    fi
else
    print_status "ERROR" "Prometheus deployment not found"
fi

# Check Prometheus service
if kubectl get service -n "$NAMESPACE" prometheus-service >/dev/null 2>&1; then
    print_status "SUCCESS" "Prometheus service exists"
    
    # Check service accessibility
    check_service_access "prometheus-service" "9090" "/"
    
    # Check metrics endpoint
    check_metrics_endpoint "prometheus-service" "9090" "/metrics"
else
    print_status "ERROR" "Prometheus service not found"
fi

# Check Prometheus ConfigMap
if kubectl get configmap -n "$NAMESPACE" prometheus-config >/dev/null 2>&1; then
    print_status "SUCCESS" "Prometheus ConfigMap exists"
else
    print_status "ERROR" "Prometheus ConfigMap not found"
fi

# Check Prometheus PVC
if kubectl get pvc -n "$NAMESPACE" prometheus-pvc >/dev/null 2>&1; then
    print_status "SUCCESS" "Prometheus PVC exists"
    
    # Check PVC status
    local pvc_status
    pvc_status=$(kubectl get pvc -n "$NAMESPACE" prometheus-pvc -o jsonpath='{.status.phase}')
    if [ "$pvc_status" = "Bound" ]; then
        print_status "SUCCESS" "Prometheus PVC is bound"
    else
        print_status "WARNING" "Prometheus PVC is not bound (status: ${pvc_status})"
    fi
else
    print_status "ERROR" "Prometheus PVC not found"
fi

# =============================================================================
# GRAFANA VALIDATION
# =============================================================================

print_status "INFO" "Validating Grafana deployment"

# Check Grafana deployment
if kubectl get deployment -n "$NAMESPACE" grafana-deployment >/dev/null 2>&1; then
    print_status "SUCCESS" "Grafana deployment exists"
    
    # Check deployment status
    local grafana_ready
    grafana_ready=$(kubectl get deployment -n "$NAMESPACE" grafana-deployment -o jsonpath='{.status.readyReplicas}')
    if [ "$grafana_ready" = "1" ]; then
        print_status "SUCCESS" "Grafana deployment is ready"
    else
        print_status "ERROR" "Grafana deployment is not ready (ready replicas: ${grafana_ready})"
    fi
else
    print_status "ERROR" "Grafana deployment not found"
fi

# Check Grafana service
if kubectl get service -n "$NAMESPACE" grafana-service >/dev/null 2>&1; then
    print_status "SUCCESS" "Grafana service exists"
    
    # Check service accessibility
    check_service_access "grafana-service" "3000" "/"
else
    print_status "ERROR" "Grafana service not found"
fi

# Check Grafana PVC
if kubectl get pvc -n "$NAMESPACE" grafana-pvc >/dev/null 2>&1; then
    print_status "SUCCESS" "Grafana PVC exists"
    
    # Check PVC status
    local pvc_status
    pvc_status=$(kubectl get pvc -n "$NAMESPACE" grafana-pvc -o jsonpath='{.status.phase}')
    if [ "$pvc_status" = "Bound" ]; then
        print_status "SUCCESS" "Grafana PVC is bound"
    else
        print_status "WARNING" "Grafana PVC is not bound (status: ${pvc_status})"
    fi
else
    print_status "ERROR" "Grafana PVC not found"
fi

# =============================================================================
# ALERTMANAGER VALIDATION
# =============================================================================

print_status "INFO" "Validating AlertManager deployment"

# Check AlertManager deployment
if kubectl get deployment -n "$NAMESPACE" alertmanager-deployment >/dev/null 2>&1; then
    print_status "SUCCESS" "AlertManager deployment exists"
    
    # Check deployment status
    local alertmanager_ready
    alertmanager_ready=$(kubectl get deployment -n "$NAMESPACE" alertmanager-deployment -o jsonpath='{.status.readyReplicas}')
    if [ "$alertmanager_ready" = "1" ]; then
        print_status "SUCCESS" "AlertManager deployment is ready"
    else
        print_status "ERROR" "AlertManager deployment is not ready (ready replicas: ${alertmanager_ready})"
    fi
else
    print_status "ERROR" "AlertManager deployment not found"
fi

# Check AlertManager service
if kubectl get service -n "$NAMESPACE" alertmanager-service >/dev/null 2>&1; then
    print_status "SUCCESS" "AlertManager service exists"
    
    # Check service accessibility
    check_service_access "alertmanager-service" "9093" "/"
    
    # Check metrics endpoint
    check_metrics_endpoint "alertmanager-service" "9093" "/metrics"
else
    print_status "ERROR" "AlertManager service not found"
fi

# Check AlertManager ConfigMap
if kubectl get configmap -n "$NAMESPACE" alertmanager-config >/dev/null 2>&1; then
    print_status "SUCCESS" "AlertManager ConfigMap exists"
else
    print_status "ERROR" "AlertManager ConfigMap not found"
fi

# Check AlertManager PVC
if kubectl get pvc -n "$NAMESPACE" alertmanager-pvc >/dev/null 2>&1; then
    print_status "SUCCESS" "AlertManager PVC exists"
    
    # Check PVC status
    local pvc_status
    pvc_status=$(kubectl get pvc -n "$NAMESPACE" alertmanager-pvc -o jsonpath='{.status.phase}')
    if [ "$pvc_status" = "Bound" ]; then
        print_status "SUCCESS" "AlertManager PVC is bound"
    else
        print_status "WARNING" "AlertManager PVC is not bound (status: ${pvc_status})"
    fi
else
    print_status "ERROR" "AlertManager PVC not found"
fi

# =============================================================================
# E-COMMERCE APPLICATION VALIDATION
# =============================================================================

print_status "INFO" "Validating e-commerce application components"

# Check e-commerce deployments
local ecommerce_components=("ecommerce-backend-deployment" "ecommerce-frontend-deployment" "ecommerce-database-deployment")

for component in "${ecommerce_components[@]}"; do
    if kubectl get deployment -n "$NAMESPACE" "$component" >/dev/null 2>&1; then
        print_status "SUCCESS" "${component} exists"
        
        # Check deployment status
        local ready_replicas
        ready_replicas=$(kubectl get deployment -n "$NAMESPACE" "$component" -o jsonpath='{.status.readyReplicas}')
        local desired_replicas
        desired_replicas=$(kubectl get deployment -n "$NAMESPACE" "$component" -o jsonpath='{.spec.replicas}')
        
        if [ "$ready_replicas" = "$desired_replicas" ]; then
            print_status "SUCCESS" "${component} is ready (${ready_replicas}/${desired_replicas} replicas)"
        else
            print_status "WARNING" "${component} is not fully ready (${ready_replicas}/${desired_replicas} replicas)"
        fi
    else
        print_status "ERROR" "${component} not found"
    fi
done

# Check e-commerce services
local ecommerce_services=("ecommerce-backend-service" "ecommerce-frontend-service" "ecommerce-database-service")

for service in "${ecommerce_services[@]}"; do
    if kubectl get service -n "$NAMESPACE" "$service" >/dev/null 2>&1; then
        print_status "SUCCESS" "${service} exists"
    else
        print_status "ERROR" "${service} not found"
    fi
done

# =============================================================================
# MONITORING INTEGRATION VALIDATION
# =============================================================================

print_status "INFO" "Validating monitoring integration"

# Check if Prometheus can scrape e-commerce services
print_status "INFO" "Checking Prometheus target discovery"

# Get Prometheus pod name
local prometheus_pod
prometheus_pod=$(kubectl get pods -n "$NAMESPACE" -l app=prometheus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$prometheus_pod" ]; then
    print_status "SUCCESS" "Prometheus pod found: ${prometheus_pod}"
    
    # Check Prometheus targets
    if kubectl exec -n "$NAMESPACE" "$prometheus_pod" -- wget -qO- "http://localhost:9090/api/v1/targets" 2>/dev/null | grep -q "ecommerce"; then
        print_status "SUCCESS" "Prometheus is discovering e-commerce targets"
    else
        print_status "WARNING" "Prometheus may not be discovering e-commerce targets"
    fi
else
    print_status "ERROR" "Prometheus pod not found"
fi

# =============================================================================
# FINAL VALIDATION SUMMARY
# =============================================================================

print_status "INFO" "Validation completed"

echo ""
echo "============================================================================="
echo "VALIDATION SUMMARY"
echo "============================================================================="
echo "Total Tests: ${TOTAL_TESTS}"
echo -e "Passed: ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed: ${RED}${FAILED_TESTS}${NC}"
echo -e "Warnings: ${YELLOW}$((TOTAL_TESTS - PASSED_TESTS - FAILED_TESTS))${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    print_status "SUCCESS" "All critical validations passed! Monitoring stack is ready."
    exit 0
else
    print_status "ERROR" "Some validations failed. Please check the errors above."
    exit 1
fi
