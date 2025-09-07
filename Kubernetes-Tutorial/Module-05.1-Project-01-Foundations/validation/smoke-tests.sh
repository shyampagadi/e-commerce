#!/bin/bash
# =============================================================================
# SMOKE TESTS VALIDATION SCRIPT
# =============================================================================
# This script runs basic smoke tests to verify the e-commerce application is
# working correctly and all critical functionality is operational.
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
# Purpose: Red color code for error messages and failed tests
# Why needed: Provides visual distinction for failed test results
# Impact: Failed tests are displayed in red color
# Usage: Used in error() function and failed test results

GREEN='\033[0;32m'
# Purpose: Green color code for success messages and passed tests
# Why needed: Provides visual distinction for successful test results
# Impact: Passed tests are displayed in green color
# Usage: Used in success() function and passed test results

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages and skipped tests
# Why needed: Provides visual distinction for warning test results
# Impact: Warning tests are displayed in yellow color
# Usage: Used in warning() function and warning test results

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
# SMOKE TEST CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent smoke test configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for e-commerce application
# Why needed: Provides consistent namespace reference for smoke tests
# Impact: All smoke tests target resources in this namespace
# Value: 'ecommerce' matches the project's application namespace

APP_NAME="ecommerce-backend"
# Purpose: Specifies the backend application name for smoke tests
# Why needed: Provides consistent reference for backend test validation
# Impact: Backend smoke tests target this application
# Value: Matches the backend deployment name in manifests

SERVICE_NAME="ecommerce-backend-service"
# Purpose: Specifies the backend service name for connectivity tests
# Why needed: Provides consistent reference for service test validation
# Impact: Service connectivity tests target this service
# Value: Matches the backend service name in manifests

TEST_TIMEOUT=30
# Purpose: Specifies the timeout for individual test operations in seconds
# Why needed: Prevents tests from hanging indefinitely
# Impact: Tests will timeout after this duration if not completed
# Value: 30 seconds provides reasonable time for test operations

FRONTEND_SERVICE="ecommerce-frontend-service"
# Purpose: Specifies the frontend service name for web interface tests
# Why needed: Provides consistent reference for frontend test validation
# Impact: Frontend smoke tests target this service
# Value: Matches the frontend service name in manifests

DATABASE_SERVICE="ecommerce-database-service"
# Purpose: Specifies the database service name for database connectivity tests
# Why needed: Provides consistent reference for database test validation
# Impact: Database connectivity tests target this service
# Value: Matches the database service name in manifests

# =============================================================================
# SMOKE TEST TRACKING VARIABLES
# =============================================================================
# Variables to track smoke test results and statistics.
# =============================================================================

TESTS_PASSED=0
# Purpose: Counter for successful smoke tests
# Why needed: Tracks number of passed smoke tests
# Impact: Used for test summary and success rate calculation
# Initial: 0, incremented for each successful test

TESTS_FAILED=0
# Purpose: Counter for failed smoke tests
# Why needed: Tracks number of failed smoke tests
# Impact: Used for test summary and failure rate calculation
# Initial: 0, incremented for each failed test

TOTAL_TESTS=0
# Purpose: Counter for total smoke tests performed
# Why needed: Tracks total number of smoke tests executed
# Impact: Used for test summary and completion percentage
# Initial: 0, incremented for each smoke test performed

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
# SMOKE TEST RESULT TRACKING FUNCTIONS
# =============================================================================
# Functions to track and report smoke test results consistently.
# =============================================================================

test_result() {
    # =============================================================================
    # TEST RESULT FUNCTION
    # =============================================================================
    # Records and displays smoke test results with consistent formatting.
    # =============================================================================
    
    local test_name="$1"
    # Purpose: Specifies the name of the smoke test
    # Why needed: Provides identification for the test being reported
    # Impact: Test name appears in result output for identification
    # Parameter: $1 is the smoke test name string
    
    local result="$2"
    # Purpose: Specifies the result of the smoke test (PASS/FAIL)
    # Why needed: Indicates whether the smoke test succeeded or failed
    # Impact: Determines color and counter updates for the result
    # Parameter: $2 is the result status string
    
    local message="$3"
    # Purpose: Specifies the detailed message for the smoke test result
    # Why needed: Provides context and details about the test outcome
    # Impact: Message appears with the result for troubleshooting information
    # Parameter: $3 is the detailed message string
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    # Purpose: Increment total smoke tests counter
    # Why needed: Tracks total number of smoke tests performed
    # Impact: Used for summary statistics and completion tracking
    
    case "$result" in
        # Purpose: Handle different smoke test result types
        # Why needed: Different results require different formatting and counters
        # Impact: Determines output color and counter updates
        
        "PASS")
            # Purpose: Handle successful smoke test results
            # Why needed: Successful tests should be visually distinct and counted
            # Impact: Displays green success message and increments passed counter
            
            TESTS_PASSED=$((TESTS_PASSED + 1))
            # Purpose: Increment successful smoke tests counter
            # Why needed: Tracks number of passed smoke tests
            # Impact: Used for success rate calculation in summary
            
            echo -e "${GREEN}[✓ PASS]${NC} $test_name: $message"
            # Purpose: Display successful smoke test result in green
            # Why needed: Provides visual confirmation of successful test
            # Impact: User sees green checkmark and success message
            ;;
            
        "FAIL")
            # Purpose: Handle failed smoke test results
            # Why needed: Failed tests should be visually distinct and counted
            # Impact: Displays red failure message and increments failed counter
            
            TESTS_FAILED=$((TESTS_FAILED + 1))
            # Purpose: Increment failed smoke tests counter
            # Why needed: Tracks number of failed smoke tests
            # Impact: Used for failure rate calculation in summary
            
            echo -e "${RED}[✗ FAIL]${NC} $test_name: $message"
            # Purpose: Display failed smoke test result in red
            # Why needed: Provides visual indication of failed test
            # Impact: User sees red X mark and failure message
            ;;
            
        *)
            # Purpose: Handle unknown smoke test result types
            # Why needed: Provides fallback for unexpected result values
            # Impact: Displays unknown result without specific formatting
            
            echo -e "[?] $test_name: $message (Unknown result: $result)"
            # Purpose: Display unknown smoke test result
            # Why needed: Provides feedback for unexpected result types
            # Impact: User sees question mark and unknown result indication
            ;;
    esac
}
    
    if [[ "$result" == "PASS" ]]; then
        success "✓ $test_name: $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        error "✗ $test_name: $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        error "Namespace $NAMESPACE does not exist"
        exit 1
    fi
    
    success "Prerequisites check passed"
}

# Test 1: Check namespace exists
test_namespace_exists() {
    log "Test 1: Checking namespace exists..."
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        test_result "Namespace Exists" "PASS" "Namespace $NAMESPACE exists"
    else
        test_result "Namespace Exists" "FAIL" "Namespace $NAMESPACE does not exist"
    fi
}

# Test 2: Check deployment exists
test_deployment_exists() {
    log "Test 2: Checking deployment exists..."
    
    if kubectl get deployment $APP_NAME -n $NAMESPACE &> /dev/null; then
        test_result "Deployment Exists" "PASS" "Deployment $APP_NAME exists"
    else
        test_result "Deployment Exists" "FAIL" "Deployment $APP_NAME does not exist"
    fi
}

# Test 3: Check service exists
test_service_exists() {
    log "Test 3: Checking service exists..."
    
    if kubectl get service $SERVICE_NAME -n $NAMESPACE &> /dev/null; then
        test_result "Service Exists" "PASS" "Service $SERVICE_NAME exists"
    else
        test_result "Service Exists" "FAIL" "Service $SERVICE_NAME does not exist"
    fi
}

# Test 4: Check pods are running
test_pods_running() {
    log "Test 4: Checking pods are running..."
    
    local pod_count=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l)
    
    if [[ $pod_count -gt 0 ]]; then
        test_result "Pods Running" "PASS" "$pod_count pod(s) are running"
    else
        test_result "Pods Running" "FAIL" "No pods are running"
    fi
}

# Test 5: Check pods are ready
test_pods_ready() {
    log "Test 5: Checking pods are ready..."
    
    local ready_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | awk '{print $2}' | grep -c "1/1" || true)
    local total_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --no-headers | wc -l)
    
    if [[ $ready_pods -eq $total_pods && $total_pods -gt 0 ]]; then
        test_result "Pods Ready" "PASS" "All $total_pods pod(s) are ready"
    else
        test_result "Pods Ready" "FAIL" "Only $ready_pods out of $total_pods pods are ready"
    fi
}

# Test 6: Check service endpoints
test_service_endpoints() {
    log "Test 6: Checking service endpoints..."
    
    local endpoint_count=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
    
    if [[ $endpoint_count -gt 0 ]]; then
        test_result "Service Endpoints" "PASS" "Service has $endpoint_count endpoint(s)"
    else
        test_result "Service Endpoints" "FAIL" "Service has no endpoints"
    fi
}

# Test 7: Check application health endpoint
test_health_endpoint() {
    log "Test 7: Checking application health endpoint..."
    
    # Start port forward in background
    kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE &
    local port_forward_pid=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test health endpoint
    local health_response
    if health_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/health --max-time $TEST_TIMEOUT 2>/dev/null); then
        if [[ "$health_response" == "200" ]]; then
            test_result "Health Endpoint" "PASS" "Health endpoint returns 200 OK"
        else
            test_result "Health Endpoint" "FAIL" "Health endpoint returns $health_response"
        fi
    else
        test_result "Health Endpoint" "FAIL" "Cannot connect to health endpoint"
    fi
    
    # Clean up port forward
    kill $port_forward_pid 2>/dev/null || true
}

# Test 8: Check API documentation endpoint
test_api_docs_endpoint() {
    log "Test 8: Checking API documentation endpoint..."
    
    # Start port forward in background
    kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE &
    local port_forward_pid=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test API docs endpoint
    local docs_response
    if docs_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/docs --max-time $TEST_TIMEOUT 2>/dev/null); then
        if [[ "$docs_response" == "200" ]]; then
            test_result "API Docs Endpoint" "PASS" "API docs endpoint returns 200 OK"
        else
            test_result "API Docs Endpoint" "FAIL" "API docs endpoint returns $docs_response"
        fi
    else
        test_result "API Docs Endpoint" "FAIL" "Cannot connect to API docs endpoint"
    fi
    
    # Clean up port forward
    kill $port_forward_pid 2>/dev/null || true
}

# Test 9: Check resource usage
test_resource_usage() {
    log "Test 9: Checking resource usage..."
    
    # Check if metrics are available
    if kubectl top pods -n $NAMESPACE &> /dev/null; then
        local cpu_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $2}' | head -1 | sed 's/m//')
        local memory_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $3}' | head -1 | sed 's/Mi//')
        
        if [[ -n "$cpu_usage" && -n "$memory_usage" ]]; then
            test_result "Resource Usage" "PASS" "CPU: ${cpu_usage}m, Memory: ${memory_usage}Mi"
        else
            test_result "Resource Usage" "FAIL" "Cannot get resource usage metrics"
        fi
    else
        test_result "Resource Usage" "WARN" "Metrics server not available"
    fi
}

# Test 10: Check pod logs
test_pod_logs() {
    log "Test 10: Checking pod logs..."
    
    local pod_name=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | head -1 | awk '{print $1}')
    
    if [[ -n "$pod_name" ]]; then
        local log_output=$(kubectl logs $pod_name -n $NAMESPACE --tail=10 2>&1)
        
        if [[ -n "$log_output" ]]; then
            test_result "Pod Logs" "PASS" "Pod logs are accessible"
        else
            test_result "Pod Logs" "FAIL" "Pod logs are empty or not accessible"
        fi
    else
        test_result "Pod Logs" "FAIL" "No running pods found"
    fi
}

# Function to run all tests
run_tests() {
    log "Starting smoke tests..."
    echo ""
    
    test_namespace_exists
    test_deployment_exists
    test_service_exists
    test_pods_running
    test_pods_ready
    test_service_endpoints
    test_health_endpoint
    test_api_docs_endpoint
    test_resource_usage
    test_pod_logs
    
    echo ""
    log "Smoke tests completed"
}

# Function to show test results
show_results() {
    echo ""
    echo "=========================================="
    echo "SMOKE TEST RESULTS"
    echo "=========================================="
    echo ""
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        success "All tests passed! Application is healthy."
        exit 0
    else
        error "$TESTS_FAILED test(s) failed. Please check the issues above."
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help                 Show this help message"
    echo "  --namespace NAMESPACE  Override default namespace (default: ecommerce)"
    echo "  --timeout SECONDS      Override test timeout (default: 30)"
    echo ""
    echo "Examples:"
    echo "  $0                     Run smoke tests with default settings"
    echo "  $0 --namespace prod    Run smoke tests in prod namespace"
    echo "  $0 --timeout 60        Run smoke tests with 60 second timeout"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            --timeout)
                TEST_TIMEOUT="$2"
                shift 2
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo "=========================================="
    echo "E-commerce Application Smoke Tests"
    echo "=========================================="
    echo ""
    echo "Configuration:"
    echo "- Namespace: $NAMESPACE"
    echo "- Application: $APP_NAME"
    echo "- Service: $SERVICE_NAME"
    echo "- Timeout: ${TEST_TIMEOUT}s"
    echo ""
    
    check_prerequisites
    run_tests
    show_results
}

# Run main function
main "$@"
