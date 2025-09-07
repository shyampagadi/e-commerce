#!/bin/bash

# =============================================================================
# CHAOS ENGINEERING VALIDATION SCRIPT
# =============================================================================
# Script for validating chaos engineering experiments and system recovery.
# Provides comprehensive validation of experiment execution and system health.
# =============================================================================

# Purpose: Validate chaos engineering experiments and system recovery
# Why needed: Ensures experiments are executed correctly and system recovers properly
# Impact: Provides comprehensive validation of chaos experiments
# Parameters: Various validation parameters and options
# Usage: ./chaos-validation.sh --experiment=pod-failure --validate=recovery
# Returns: 0 on success, 1 on failure

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Purpose: Define configuration constants and variables
# Why needed: Provides centralized configuration for chaos validation
# Impact: Ensures consistent validation across all chaos experiments

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Purpose: Get the directory where this script is located
# Why needed: Enables relative path resolution for other files
# Impact: Script can find other chaos engineering files regardless of execution location

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# Purpose: Get the project root directory
# Why needed: Enables access to project-wide configuration
# Impact: Script can access project configuration

NAMESPACE="${NAMESPACE:-ecommerce-production}"
# Purpose: Set the target namespace for validation
# Why needed: Specifies which namespace to validate
# Impact: Validation will be conducted in the specified namespace
# Default: ecommerce-production

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
# Purpose: Set the monitoring namespace
# Why needed: Specifies which namespace contains monitoring components
# Impact: Monitoring validation will target the specified namespace
# Default: monitoring

LOG_DIR="${LOG_DIR:-/tmp/chaos-logs}"
# Purpose: Set the log directory for validation
# Why needed: Provides centralized logging location
# Impact: All validation logs will be stored in the specified directory
# Default: /tmp/chaos-logs

# Validation configuration
DEFAULT_VALIDATION_TYPE="${DEFAULT_VALIDATION_TYPE:-recovery}"
# Purpose: Set the default validation type
# Why needed: Provides default validation type when not specified
# Impact: Validation will use recovery validation by default
# Default: recovery

VALIDATION_TIMEOUT="${VALIDATION_TIMEOUT:-300}"
# Purpose: Set the validation timeout in seconds
# Why needed: Prevents infinite validation loops
# Impact: Validation will timeout after specified time
# Default: 300 seconds (5 minutes)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print status message
print_status() {
    # =============================================================================
    # PRINT STATUS MESSAGE FUNCTION
    # =============================================================================
    # Prints formatted status messages with timestamp and log level.
    # Provides consistent logging format across all validation operations.
    # =============================================================================
    
    # Purpose: Print formatted status messages
    # Why needed: Provides consistent logging format for all operations
    # Impact: All operations are logged with consistent format
    # Parameters:
    #   $1: Log level (INFO, WARNING, ERROR, SUCCESS)
    #   $2: Message to print
    # Usage: print_status "INFO" "Starting validation"
    # Returns: None
    
    local level=$1
    # Purpose: Specifies the log level for the message
    # Why needed: Provides log level classification for filtering and analysis
    # Impact: Message is classified with the specified log level
    # Parameter: $1 is the log level
    
    local message=$2
    # Purpose: Specifies the message to print
    # Why needed: Provides the actual message content
    # Impact: Message content is displayed to the user
    # Parameter: $2 is the message
    
    local timestamp
    # Purpose: Variable to store current timestamp
    # Why needed: Provides timestamp for log entries
    # Impact: All log entries include timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Get current timestamp in YYYY-MM-DD HH:MM:SS format
    # Why needed: Provides timestamp for log entries
    # Impact: Timestamp is included in all log entries
    # date: Get current date and time
    # '+%Y-%m-%d %H:%M:%S': Format timestamp as YYYY-MM-DD HH:MM:SS
    
    case $level in
        "INFO")
            echo -e "\033[0;34m[${timestamp}] [INFO] ${message}\033[0m"
            # Purpose: Print info message in blue color
            # Why needed: Provides visual distinction for info messages
            # Impact: Info messages are displayed in blue color
            ;;
        "WARNING")
            echo -e "\033[0;33m[${timestamp}] [WARNING] ${message}\033[0m"
            # Purpose: Print warning message in yellow color
            # Why needed: Provides visual distinction for warning messages
            # Impact: Warning messages are displayed in yellow color
            ;;
        "ERROR")
            echo -e "\033[0;31m[${timestamp}] [ERROR] ${message}\033[0m"
            # Purpose: Print error message in red color
            # Why needed: Provides visual distinction for error messages
            # Impact: Error messages are displayed in red color
            ;;
        "SUCCESS")
            echo -e "\033[0;32m[${timestamp}] [SUCCESS] ${message}\033[0m"
            # Purpose: Print success message in green color
            # Why needed: Provides visual distinction for success messages
            # Impact: Success messages are displayed in green color
            ;;
        *)
            echo -e "[${timestamp}] [${level}] ${message}"
            # Purpose: Print message with default formatting
            # Why needed: Handles unknown log levels gracefully
            # Impact: Unknown log levels are displayed with default formatting
            ;;
    esac
}

# Function: Validate pod health
validate_pod_health() {
    # =============================================================================
    # VALIDATE POD HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of pods in the target namespace.
    # Provides comprehensive pod health validation including status and readiness.
    # =============================================================================
    
    # Purpose: Validate pod health in the target namespace
    # Why needed: Ensures all pods are healthy and running
    # Impact: Provides comprehensive pod health validation
    # Parameters: None (uses global variables)
    # Usage: validate_pod_health
    # Returns: 0 if all pods healthy, 1 if unhealthy
    
    print_status "INFO" "Validating pod health in namespace: $NAMESPACE"
    # Purpose: Log the start of pod health validation
    # Why needed: Informs user that pod health validation has begun
    # Impact: User knows pod health validation has started
    
    local unhealthy_pods=()
    # Purpose: Array to store unhealthy pod names
    # Why needed: Tracks which pods are unhealthy
    # Impact: Will contain unhealthy pod names
    
    # =============================================================================
    # CHECK POD STATUS
    # =============================================================================
    # Purpose: Check status of all pods in namespace
    # Why needed: Validates that all pods are running and ready
    
    local pods
    # Purpose: Variable to store pod information
    # Why needed: Collects pod status information
    # Impact: Will contain pod status data
    
    pods=$(kubectl get pods -n "$NAMESPACE" -o json)
    # Purpose: Get pod information from Kubernetes
    # Why needed: Provides pod status data for validation
    # Impact: Pod information is retrieved
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Target namespace
    # -o json: Output in JSON format
    
    if [ $? -ne 0 ]; then
        # Purpose: Check if pod retrieval failed
        # Why needed: Validates that pod information was retrieved successfully
        # Impact: Proceeds with error handling if retrieval failed
        # $?: Exit code of last command
        # -ne 0: Not equal to zero (failure)
        
        print_status "ERROR" "Failed to retrieve pod information"
        # Purpose: Log pod retrieval failure
        # Why needed: Informs user about pod retrieval issues
        # Impact: User knows pod retrieval failed
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates pod health validation failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # VALIDATE EACH POD
    # =============================================================================
    # Purpose: Validate each pod individually
    # Why needed: Ensures each pod meets health criteria
    
    local pod_count
    # Purpose: Variable to store total pod count
    # Why needed: Provides pod count for validation
    # Impact: Will contain total pod count
    
    pod_count=$(echo "$pods" | jq '.items | length')
    # Purpose: Count total number of pods
    # Why needed: Provides pod count for validation
    # Impact: Total pod count is calculated
    # echo "$pods": Output pod JSON data
    # jq '.items | length': Count items in JSON array
    
    for ((i=0; i<pod_count; i++)); do
        # Purpose: Loop through each pod
        # Why needed: Validates each pod individually
        # Impact: Each pod is validated
        # i=0: Start from index 0
        # i<pod_count: Continue until all pods processed
        # i++: Increment index
        
        local pod_name
        # Purpose: Variable to store pod name
        # Why needed: Identifies which pod is being validated
        # Impact: Will contain pod name
        
        local pod_status
        # Purpose: Variable to store pod status
        # Why needed: Provides pod status for validation
        # Impact: Will contain pod status
        
        local pod_ready
        # Purpose: Variable to store pod readiness
        # Why needed: Provides pod readiness for validation
        # Impact: Will contain pod readiness status
        
        pod_name=$(echo "$pods" | jq -r ".items[$i].metadata.name")
        # Purpose: Extract pod name from JSON
        # Why needed: Identifies the pod being validated
        # Impact: Pod name is extracted
        # echo "$pods": Output pod JSON data
        # jq -r ".items[$i].metadata.name": Extract pod name from JSON
        
        pod_status=$(echo "$pods" | jq -r ".items[$i].status.phase")
        # Purpose: Extract pod status from JSON
        # Why needed: Provides pod status for validation
        # Impact: Pod status is extracted
        # echo "$pods": Output pod JSON data
        # jq -r ".items[$i].status.phase": Extract pod phase from JSON
        
        pod_ready=$(echo "$pods" | jq -r ".items[$i].status.conditions[] | select(.type==\"Ready\") | .status")
        # Purpose: Extract pod readiness from JSON
        # Why needed: Provides pod readiness for validation
        # Impact: Pod readiness is extracted
        # echo "$pods": Output pod JSON data
        # jq -r ".items[$i].status.conditions[] | select(.type==\"Ready\") | .status": Extract ready condition status
        
        if [ "$pod_status" != "Running" ]; then
            # Purpose: Check if pod is not running
            # Why needed: Validates that pod is in running state
            # Impact: Proceeds with error handling if pod not running
            
            print_status "WARNING" "Pod $pod_name is not running (status: $pod_status)"
            # Purpose: Log pod status warning
            # Why needed: Informs user about pod status issues
            # Impact: User knows pod is not running
            
            unhealthy_pods+=("$pod_name")
            # Purpose: Add pod to unhealthy list
            # Why needed: Tracks unhealthy pods
            # Impact: Pod is added to unhealthy list
        elif [ "$pod_ready" != "True" ]; then
            # Purpose: Check if pod is not ready
            # Why needed: Validates that pod is ready to serve traffic
            # Impact: Proceeds with error handling if pod not ready
            
            print_status "WARNING" "Pod $pod_name is not ready"
            # Purpose: Log pod readiness warning
            # Why needed: Informs user about pod readiness issues
            # Impact: User knows pod is not ready
            
            unhealthy_pods+=("$pod_name")
            # Purpose: Add pod to unhealthy list
            # Why needed: Tracks unhealthy pods
            # Impact: Pod is added to unhealthy list
        else
            # Purpose: Handle healthy pod case
            # Why needed: Confirms pod is healthy
            # Impact: Proceeds with success handling
            
            print_status "SUCCESS" "Pod $pod_name is healthy (status: $pod_status, ready: $pod_ready)"
            # Purpose: Log pod health success
            # Why needed: Confirms pod is healthy
            # Impact: User knows pod is healthy
        fi
    done
    
    # =============================================================================
    # VALIDATE RESULTS
    # =============================================================================
    # Purpose: Validate overall pod health results
    # Why needed: Provides overall validation result
    
    if [ ${#unhealthy_pods[@]} -eq 0 ]; then
        # Purpose: Check if no unhealthy pods found
        # Why needed: Validates that all pods are healthy
        # Impact: Proceeds with success handling if all pods healthy
        # ${#unhealthy_pods[@]}: Length of unhealthy pods array
        # -eq 0: Equal to zero
        
        print_status "SUCCESS" "All pods are healthy"
        # Purpose: Log successful pod health validation
        # Why needed: Confirms all pods are healthy
        # Impact: User knows all pods are healthy
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates pod health validation succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle unhealthy pods case
        # Why needed: Provides error handling for unhealthy pods
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Found ${#unhealthy_pods[@]} unhealthy pods: ${unhealthy_pods[*]}"
        # Purpose: Log unhealthy pods error
        # Why needed: Informs user about unhealthy pods
        # Impact: User knows which pods are unhealthy
        # ${#unhealthy_pods[@]}: Number of unhealthy pods
        # ${unhealthy_pods[*]}: List of unhealthy pod names
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates pod health validation failed
        # Impact: Function returns failure
    fi
}

# Function: Validate service health
validate_service_health() {
    # =============================================================================
    # VALIDATE SERVICE HEALTH FUNCTION
    # =============================================================================
    # Validates the health status of services in the target namespace.
    # Provides comprehensive service health validation including endpoints and connectivity.
    # =============================================================================
    
    # Purpose: Validate service health in the target namespace
    # Why needed: Ensures all services are healthy and accessible
    # Impact: Provides comprehensive service health validation
    # Parameters: None (uses global variables)
    # Usage: validate_service_health
    # Returns: 0 if all services healthy, 1 if unhealthy
    
    print_status "INFO" "Validating service health in namespace: $NAMESPACE"
    # Purpose: Log the start of service health validation
    # Why needed: Informs user that service health validation has begun
    # Impact: User knows service health validation has started
    
    local unhealthy_services=()
    # Purpose: Array to store unhealthy service names
    # Why needed: Tracks which services are unhealthy
    # Impact: Will contain unhealthy service names
    
    # =============================================================================
    # CHECK SERVICE STATUS
    # =============================================================================
    # Purpose: Check status of all services in namespace
    # Why needed: Validates that all services have endpoints
    
    local services
    # Purpose: Variable to store service information
    # Why needed: Collects service status information
    # Impact: Will contain service status data
    
    services=$(kubectl get services -n "$NAMESPACE" -o json)
    # Purpose: Get service information from Kubernetes
    # Why needed: Provides service status data for validation
    # Impact: Service information is retrieved
    # kubectl get services: Get service information
    # -n "$NAMESPACE": Target namespace
    # -o json: Output in JSON format
    
    if [ $? -ne 0 ]; then
        # Purpose: Check if service retrieval failed
        # Why needed: Validates that service information was retrieved successfully
        # Impact: Proceeds with error handling if retrieval failed
        # $?: Exit code of last command
        # -ne 0: Not equal to zero (failure)
        
        print_status "ERROR" "Failed to retrieve service information"
        # Purpose: Log service retrieval failure
        # Why needed: Informs user about service retrieval issues
        # Impact: User knows service retrieval failed
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates service health validation failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # VALIDATE EACH SERVICE
    # =============================================================================
    # Purpose: Validate each service individually
    # Why needed: Ensures each service meets health criteria
    
    local service_count
    # Purpose: Variable to store total service count
    # Why needed: Provides service count for validation
    # Impact: Will contain total service count
    
    service_count=$(echo "$services" | jq '.items | length')
    # Purpose: Count total number of services
    # Why needed: Provides service count for validation
    # Impact: Total service count is calculated
    # echo "$services": Output service JSON data
    # jq '.items | length': Count items in JSON array
    
    for ((i=0; i<service_count; i++)); do
        # Purpose: Loop through each service
        # Why needed: Validates each service individually
        # Impact: Each service is validated
        # i=0: Start from index 0
        # i<service_count: Continue until all services processed
        # i++: Increment index
        
        local service_name
        # Purpose: Variable to store service name
        # Why needed: Identifies which service is being validated
        # Impact: Will contain service name
        
        local service_type
        # Purpose: Variable to store service type
        # Why needed: Provides service type for validation
        # Impact: Will contain service type
        
        service_name=$(echo "$services" | jq -r ".items[$i].metadata.name")
        # Purpose: Extract service name from JSON
        # Why needed: Identifies the service being validated
        # Impact: Service name is extracted
        # echo "$services": Output service JSON data
        # jq -r ".items[$i].metadata.name": Extract service name from JSON
        
        service_type=$(echo "$services" | jq -r ".items[$i].spec.type")
        # Purpose: Extract service type from JSON
        # Why needed: Provides service type for validation
        # Impact: Service type is extracted
        # echo "$services": Output service JSON data
        # jq -r ".items[$i].spec.type": Extract service type from JSON
        
        # =============================================================================
        # CHECK SERVICE ENDPOINTS
        # =============================================================================
        # Purpose: Check if service has endpoints
        # Why needed: Validates that service has active endpoints
        
        local endpoint_count
        # Purpose: Variable to store endpoint count
        # Why needed: Provides endpoint count for validation
        # Impact: Will contain endpoint count
        
        endpoint_count=$(kubectl get endpoints "$service_name" -n "$NAMESPACE" -o json | jq '.subsets[0].addresses | length')
        # Purpose: Get endpoint count for service
        # Why needed: Validates that service has active endpoints
        # Impact: Endpoint count is retrieved
        # kubectl get endpoints: Get endpoint information
        # "$service_name": Service name to check
        # -n "$NAMESPACE": Target namespace
        # -o json: Output in JSON format
        # jq '.subsets[0].addresses | length': Count addresses in first subset
        
        if [ "$endpoint_count" = "null" ] || [ "$endpoint_count" -eq 0 ]; then
            # Purpose: Check if service has no endpoints
            # Why needed: Validates that service has active endpoints
            # Impact: Proceeds with error handling if no endpoints
            # = "null": Check if endpoint count is null
            # -eq 0: Equal to zero
            
            print_status "WARNING" "Service $service_name has no endpoints"
            # Purpose: Log service endpoint warning
            # Why needed: Informs user about service endpoint issues
            # Impact: User knows service has no endpoints
            
            unhealthy_services+=("$service_name")
            # Purpose: Add service to unhealthy list
            # Why needed: Tracks unhealthy services
            # Impact: Service is added to unhealthy list
        else
            # Purpose: Handle healthy service case
            # Why needed: Confirms service is healthy
            # Impact: Proceeds with success handling
            
            print_status "SUCCESS" "Service $service_name is healthy (endpoints: $endpoint_count, type: $service_type)"
            # Purpose: Log service health success
            # Why needed: Confirms service is healthy
            # Impact: User knows service is healthy
        fi
    done
    
    # =============================================================================
    # VALIDATE RESULTS
    # =============================================================================
    # Purpose: Validate overall service health results
    # Why needed: Provides overall validation result
    
    if [ ${#unhealthy_services[@]} -eq 0 ]; then
        # Purpose: Check if no unhealthy services found
        # Why needed: Validates that all services are healthy
        # Impact: Proceeds with success handling if all services healthy
        # ${#unhealthy_services[@]}: Length of unhealthy services array
        # -eq 0: Equal to zero
        
        print_status "SUCCESS" "All services are healthy"
        # Purpose: Log successful service health validation
        # Why needed: Confirms all services are healthy
        # Impact: User knows all services are healthy
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates service health validation succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle unhealthy services case
        # Why needed: Provides error handling for unhealthy services
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Found ${#unhealthy_services[@]} unhealthy services: ${unhealthy_services[*]}"
        # Purpose: Log unhealthy services error
        # Why needed: Informs user about unhealthy services
        # Impact: User knows which services are unhealthy
        # ${#unhealthy_services[@]}: Number of unhealthy services
        # ${unhealthy_services[*]}: List of unhealthy service names
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates service health validation failed
        # Impact: Function returns failure
    fi
}

# Function: Main execution
main() {
    # =============================================================================
    # MAIN EXECUTION FUNCTION
    # =============================================================================
    # Main function that orchestrates the chaos validation execution.
    # Provides the main entry point and execution flow for the validation script.
    # =============================================================================
    
    # Purpose: Main execution function for chaos validation script
    # Why needed: Provides main entry point and execution flow
    # Impact: Orchestrates the entire chaos validation process
    # Parameters: Command-line arguments
    # Usage: main "$@"
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting Chaos Engineering Validation Script"
    # Purpose: Log the start of validation script execution
    # Why needed: Informs user that validation script has started
    # Impact: User knows validation script has started
    
    # =============================================================================
    # VALIDATE POD HEALTH
    # =============================================================================
    # Purpose: Validate pod health
    # Why needed: Ensures all pods are healthy
    
    if ! validate_pod_health; then
        # Purpose: Validate pod health
        # Why needed: Ensures all pods are healthy
        # Impact: Proceeds with error handling if pod validation failed
        # validate_pod_health: Function to validate pod health
        
        print_status "ERROR" "Pod health validation failed"
        # Purpose: Log pod validation failure
        # Why needed: Informs user about pod validation issues
        # Impact: User knows pod validation failed
        
        exit 1
        # Purpose: Exit with failure status
        # Why needed: Indicates validation failed
        # Impact: Script exits with failure
    fi
    
    # =============================================================================
    # VALIDATE SERVICE HEALTH
    # =============================================================================
    # Purpose: Validate service health
    # Why needed: Ensures all services are healthy
    
    if ! validate_service_health; then
        # Purpose: Validate service health
        # Why needed: Ensures all services are healthy
        # Impact: Proceeds with error handling if service validation failed
        # validate_service_health: Function to validate service health
        
        print_status "ERROR" "Service health validation failed"
        # Purpose: Log service validation failure
        # Why needed: Informs user about service validation issues
        # Impact: User knows service validation failed
        
        exit 1
        # Purpose: Exit with failure status
        # Why needed: Indicates validation failed
        # Impact: Script exits with failure
    fi
    
    print_status "SUCCESS" "Chaos Engineering Validation Script completed successfully"
    # Purpose: Log successful validation completion
    # Why needed: Confirms validation completed successfully
    # Impact: User knows validation completed successfully
    
    exit 0
    # Purpose: Exit with success status
    # Why needed: Indicates validation completed successfully
    # Impact: Script exits successfully
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Purpose: Execute main function with all arguments
# Why needed: Provides script entry point
# Impact: Script execution begins

main "$@"
# Purpose: Call main function with all command-line arguments
# Why needed: Starts script execution
# Impact: Script execution begins
# "$@": All command-line arguments
