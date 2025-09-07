#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION PERFORMANCE TEST SCRIPT
# =============================================================================
# This script performs comprehensive performance testing for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# load testing, stress testing, and performance validation.
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
# PERFORMANCE TEST CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent performance test configuration throughout the script.
# =============================================================================

NAMESPACE="${1:-ecommerce}"
# Purpose: Specifies the Kubernetes namespace for performance testing
# Why needed: Provides consistent namespace reference for all performance tests
# Impact: All performance tests target resources in this namespace
# Value: Defaults to 'ecommerce', accepts any valid namespace name

DURATION="300s"
# Purpose: Specifies the duration for performance test execution
# Why needed: Controls how long performance tests run
# Impact: Determines the time window for performance data collection
# Value: Defaults to 5 minutes, accepts formats like '300s', '5m', '1h'

CONCURRENT_USERS=10
# Purpose: Specifies the number of concurrent users for load testing
# Why needed: Simulates realistic user load on the application
# Impact: Determines the concurrent load applied during testing
# Value: Defaults to 10 users, can be increased for stress testing

REQUEST_RATE=100
# Purpose: Specifies the request rate per second for performance testing
# Why needed: Controls the rate of requests sent to the application
# Impact: Determines the request throughput during testing
# Value: Defaults to 100 requests per second

TEST_TYPE="load"
# Purpose: Specifies the type of performance test to execute
# Why needed: Determines the testing methodology and metrics collected
# Impact: Controls the testing approach and validation criteria
# Value: Options: 'load', 'stress', 'spike', 'volume', 'endurance'

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --duration=*)
            DURATION="${arg#*=}"
            shift
            ;;
        --concurrent=*)
            CONCURRENT_USERS="${arg#*=}"
            shift
            ;;
        --rate=*)
            REQUEST_RATE="${arg#*=}"
            shift
            ;;
        --type=*)
            TEST_TYPE="${arg#*=}"
            shift
            ;;
    esac
done

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Performance metrics
declare -A PERFORMANCE_METRICS

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Displays colored status messages with timestamps for performance test logging.
    # Provides consistent formatting and visual feedback during test execution.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps
    # Why needed: Provides consistent logging format with visual feedback
    # Impact: Enhances readability and debugging capabilities
    # Parameters:
    #   $1: Status type (INFO, SUCCESS, WARNING, ERROR)
    #   $2: Message to display
    # Usage: print_status "INFO" "Starting performance test"
    
    local status=$1
    # Purpose: Specifies the status type for message formatting
    # Why needed: Determines the color and prefix for the message
    # Impact: Message will be displayed with appropriate color and prefix
    # Parameter: $1 is the status type
    
    local message=$2
    # Purpose: Specifies the message content to display
    # Why needed: Provides the actual message content
    # Impact: This message will be displayed with formatting
    # Parameter: $2 is the message content
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generate current timestamp for message logging
    # Why needed: Provides temporal context for performance test events
    # Impact: Each message will include a timestamp
    # date '+%Y-%m-%d %H:%M:%S': Format timestamp as YYYY-MM-DD HH:MM:SS
    
    # =============================================================================
    # STATUS MESSAGE FORMATTING
    # =============================================================================
    # Purpose: Format and display message based on status type
    # Why needed: Provides consistent visual feedback for different message types
    
    case $status in
        # Purpose: Handle INFO status messages
        # Why needed: Provides informational feedback during test execution
        # Impact: INFO messages are displayed in blue
        
        "INFO")
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            # Purpose: Display INFO message in blue color
            # Why needed: Provides informational feedback
            # Impact: User sees informational message in blue
            # echo -e: Enable interpretation of backslash escapes
            # "${BLUE}[INFO]${NC}": Blue colored INFO prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        
        # Purpose: Handle SUCCESS status messages
        # Why needed: Provides positive feedback for successful operations
        # Impact: SUCCESS messages are displayed in green
        
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            # Purpose: Display SUCCESS message in green color
            # Why needed: Provides positive feedback
            # Impact: User sees success message in green
            # echo -e: Enable interpretation of backslash escapes
            # "${GREEN}[SUCCESS]${NC}": Green colored SUCCESS prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        
        # Purpose: Handle WARNING status messages
        # Why needed: Provides cautionary feedback for potential issues
        # Impact: WARNING messages are displayed in yellow
        
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            # Purpose: Display WARNING message in yellow color
            # Why needed: Provides cautionary feedback
            # Impact: User sees warning message in yellow
            # echo -e: Enable interpretation of backslash escapes
            # "${YELLOW}[WARNING]${NC}": Yellow colored WARNING prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
        
        # Purpose: Handle ERROR status messages
        # Why needed: Provides error feedback for failed operations
        # Impact: ERROR messages are displayed in red
        
        "ERROR")
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            # Purpose: Display ERROR message in red color
            # Why needed: Provides error feedback
            # Impact: User sees error message in red
            # echo -e: Enable interpretation of backslash escapes
            # "${RED}[ERROR]${NC}": Red colored ERROR prefix
            # "[${timestamp}]": Timestamp in brackets
            # "${message}": The actual message content
            ;;
    esac
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Validates if a command is available in the system PATH.
    # Provides prerequisite checking for performance testing tools.
    # =============================================================================
    
    # Purpose: Check if a command exists in the system PATH
    # Why needed: Validates prerequisite tools before performance testing
    # Impact: Prevents test failures due to missing tools
    # Parameters:
    #   $1: Command name to check
    # Usage: command_exists "hey"
    
    command -v "$1" >/dev/null 2>&1
    # Purpose: Check if command exists in PATH
    # Why needed: Validates tool availability before testing
    # Impact: Returns 0 if command exists, 1 if not found
    # command -v: Display command path or return error if not found
    # "$1": Command name to check
    # >/dev/null: Suppress output
    # 2>&1: Redirect stderr to stdout
}

# Function: Get service URL
get_service_url() {
    # =============================================================================
    # GET SERVICE URL FUNCTION
    # =============================================================================
    # Retrieves the ClusterIP URL for a Kubernetes service for performance testing.
    # Provides service discovery for load testing endpoints.
    # =============================================================================
    
    # Purpose: Get ClusterIP URL for a Kubernetes service
    # Why needed: Provides service endpoint for performance testing
    # Impact: Enables load testing against service endpoints
    # Parameters:
    #   $1: Service name
    #   $2: Service port
    #   $3: URL path (optional, defaults to /)
    # Usage: get_service_url "ecommerce-backend" "8000" "/api/health"
    
    local service_name=$1
    # Purpose: Specifies the Kubernetes service name
    # Why needed: Identifies the target service for URL generation
    # Impact: URL will be generated for this service
    # Parameter: $1 is the service name
    
    local port=$2
    # Purpose: Specifies the service port
    # Why needed: Defines the port for the service URL
    # Impact: URL will include this port
    # Parameter: $2 is the service port
    
    local path=${3:-/}
    # Purpose: Specifies the URL path (optional)
    # Why needed: Defines the path component of the URL
    # Impact: URL will include this path
    # Parameter: $3 is the URL path, defaults to "/" if not provided
    # ${3:-/}: Use $3 if set, otherwise use "/"
    
    # =============================================================================
    # SERVICE IP DISCOVERY
    # =============================================================================
    # Purpose: Get ClusterIP for the service
    # Why needed: Provides the internal IP for service access
    
    local service_ip
    # Purpose: Variable to store service ClusterIP
    # Why needed: Provides storage for service IP
    # Impact: Will contain the service ClusterIP
    
    service_ip=$(kubectl get service -n "$NAMESPACE" "$service_name" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    # Purpose: Get service ClusterIP from Kubernetes
    # Why needed: Provides internal IP for service access
    # Impact: Service IP is retrieved
    # kubectl get service: Get service information
    # -n "$NAMESPACE": Target namespace
    # "$service_name": Target service name
    # -o jsonpath='{.spec.clusterIP}': Extract ClusterIP from JSON
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # SERVICE IP VALIDATION
    # =============================================================================
    # Purpose: Validate service IP was retrieved
    # Why needed: Ensures service exists and has ClusterIP
    
    if [ -z "$service_ip" ]; then
        # Purpose: Check if service IP is empty
        # Why needed: Ensures service exists and has ClusterIP
        # Impact: Proceeds with URL generation if IP exists
        
        print_status "ERROR" "Service ${service_name} not found or has no ClusterIP"
        # Purpose: Log error message for missing service
        # Why needed: Informs user that service is not available
        # Impact: User knows service is not available
        # ${service_name}: Shows the service name that was not found
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates that service URL could not be generated
        # Impact: Calling function knows service URL generation failed
    fi
    
    # =============================================================================
    # URL GENERATION
    # =============================================================================
    # Purpose: Generate service URL
    # Why needed: Provides complete URL for performance testing
    
    echo "http://${service_ip}:${port}${path}"
    # Purpose: Generate and return service URL
    # Why needed: Provides complete URL for performance testing
    # Impact: Service URL is returned
    # "http://": HTTP protocol prefix
    # "${service_ip}": Service ClusterIP
    # ":${port}": Service port
    # "${path}": URL path
}

# Function: Run load test with hey
run_hey_test() {
    # =============================================================================
    # RUN HEY TEST FUNCTION
    # =============================================================================
    # Executes load testing using the hey tool in a Kubernetes pod.
    # Provides comprehensive performance metrics collection and analysis.
    # =============================================================================
    
    # Purpose: Execute load test using hey tool
    # Why needed: Provides comprehensive load testing capabilities
    # Impact: Generates performance metrics and validates application performance
    # Parameters:
    #   $1: Target URL for testing
    #   $2: Test name for identification
    #   $3: Test duration
    #   $4: Concurrent users
    #   $5: Request rate per second
    # Usage: run_hey_test "http://service:port" "backend" "300s" "10" "100"
    
    local url=$1
    # Purpose: Specifies the target URL for load testing
    # Why needed: Defines the endpoint to test
    # Impact: Load test will target this URL
    # Parameter: $1 is the target URL
    
    local test_name=$2
    # Purpose: Specifies the test name for identification
    # Why needed: Provides unique identifier for test results
    # Impact: Test results will be tagged with this name
    # Parameter: $2 is the test name
    
    local duration=$3
    # Purpose: Specifies the test duration
    # Why needed: Controls how long the load test runs
    # Impact: Determines the time window for performance data collection
    # Parameter: $3 is the test duration
    
    local concurrent=$4
    # Purpose: Specifies the number of concurrent users
    # Why needed: Simulates realistic user load
    # Impact: Determines the concurrent load applied during testing
    # Parameter: $4 is the number of concurrent users
    
    local rate=$5
    # Purpose: Specifies the request rate per second
    # Why needed: Controls the rate of requests sent
    # Impact: Determines the request throughput during testing
    # Parameter: $5 is the request rate per second
    
    # =============================================================================
    # TEST INITIATION
    # =============================================================================
    # Purpose: Log test initiation and parameters
    # Why needed: Provides visibility into test execution
    
    print_status "INFO" "Running ${test_name} test on ${url}"
    # Purpose: Log test initiation message
    # Why needed: Informs user that load test is starting
    # Impact: User knows load test has begun
    # ${test_name}: Shows the test name
    # ${url}: Shows the target URL
    
    print_status "INFO" "Parameters: duration=${duration}, concurrent=${concurrent}, rate=${rate}"
    # Purpose: Log test parameters
    # Why needed: Shows test configuration
    # Impact: User knows test parameters
    # ${duration}: Shows test duration
    # ${concurrent}: Shows concurrent users
    # ${rate}: Shows request rate
    
    # =============================================================================
    # HEY TEST EXECUTION
    # =============================================================================
    # Purpose: Execute hey load test in Kubernetes pod
    # Why needed: Provides load testing capabilities
    
    kubectl run hey-test-${test_name,,} --rm -i --restart=Never --image=rakyll/hey:latest -- \
        hey -n 1000 -c "$concurrent" -q "$rate" -t 30 -z "$duration" "$url" 2>/dev/null | tee "/tmp/hey-${test_name,,}-results.txt"
    # Purpose: Execute hey load test in Kubernetes pod
    # Why needed: Provides load testing capabilities
    # Impact: Load test is executed and results are captured
    # kubectl run: Create and run a pod
    # hey-test-${test_name,,}: Pod name with lowercase test name
    # --rm: Remove pod after completion
    # -i: Interactive mode
    # --restart=Never: Don't restart pod
    # --image=rakyll/hey:latest: Use hey tool image
    # hey: Load testing tool
    # -n 1000: Number of requests (minimum)
    # -c "$concurrent": Concurrent users
    # -q "$rate": Request rate per second
    # -t 30: Timeout in seconds
    # -z "$duration": Test duration
    # "$url": Target URL
    # 2>/dev/null: Suppress error messages
    # | tee: Save output to file and display
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    
    # =============================================================================
    # RESULTS PARSING
    # =============================================================================
    # Purpose: Parse hey test results
    # Why needed: Extracts performance metrics from test output
    
    local total_requests
    # Purpose: Variable to store total requests
    # Why needed: Provides storage for total requests metric
    # Impact: Will contain the total number of requests
    
    local requests_per_second
    # Purpose: Variable to store requests per second
    # Why needed: Provides storage for RPS metric
    # Impact: Will contain the requests per second value
    
    local avg_response_time
    # Purpose: Variable to store average response time
    # Why needed: Provides storage for average response time metric
    # Impact: Will contain the average response time value
    
    local p95_response_time
    # Purpose: Variable to store 95th percentile response time
    # Why needed: Provides storage for P95 response time metric
    # Impact: Will contain the 95th percentile response time value
    
    local p99_response_time
    # Purpose: Variable to store 99th percentile response time
    # Why needed: Provides storage for P99 response time metric
    # Impact: Will contain the 99th percentile response time value
    
    local error_rate
    # Purpose: Variable to store error rate
    # Why needed: Provides storage for error rate metric
    # Impact: Will contain the error rate value
    
    total_requests=$(grep "Total:" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $2}' || echo "0")
    # Purpose: Extract total requests from results
    # Why needed: Provides total requests metric
    # Impact: Total requests value is extracted
    # grep "Total:": Find line containing "Total:"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $2}': Extract second field
    # || echo "0": Default to "0" if not found
    
    requests_per_second=$(grep "Requests/sec:" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $2}' || echo "0")
    # Purpose: Extract requests per second from results
    # Why needed: Provides RPS metric
    # Impact: RPS value is extracted
    # grep "Requests/sec:": Find line containing "Requests/sec:"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $2}': Extract second field
    # || echo "0": Default to "0" if not found
    
    avg_response_time=$(grep "Average:" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $2}' || echo "0")
    # Purpose: Extract average response time from results
    # Why needed: Provides average response time metric
    # Impact: Average response time value is extracted
    # grep "Average:": Find line containing "Average:"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $2}': Extract second field
    # || echo "0": Default to "0" if not found
    
    p95_response_time=$(grep "95%" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $2}' || echo "0")
    # Purpose: Extract 95th percentile response time from results
    # Why needed: Provides P95 response time metric
    # Impact: P95 response time value is extracted
    # grep "95%": Find line containing "95%"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $2}': Extract second field
    # || echo "0": Default to "0" if not found
    
    p99_response_time=$(grep "99%" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $2}' || echo "0")
    # Purpose: Extract 99th percentile response time from results
    # Why needed: Provides P99 response time metric
    # Impact: P99 response time value is extracted
    # grep "99%": Find line containing "99%"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $2}': Extract second field
    # || echo "0": Default to "0" if not found
    
    error_rate=$(grep "Error rate:" "/tmp/hey-${test_name,,}-results.txt" | awk '{print $3}' || echo "0")
    # Purpose: Extract error rate from results
    # Why needed: Provides error rate metric
    # Impact: Error rate value is extracted
    # grep "Error rate:": Find line containing "Error rate:"
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
    # | awk '{print $3}': Extract third field
    # || echo "0": Default to "0" if not found
    
    # =============================================================================
    # METRICS STORAGE
    # =============================================================================
    # Purpose: Store performance metrics
    # Why needed: Provides centralized metrics storage
    
    PERFORMANCE_METRICS["${test_name}_total_requests"]="$total_requests"
    # Purpose: Store total requests metric
    # Why needed: Provides centralized metrics storage
    # Impact: Total requests metric is stored
    # "${test_name}_total_requests": Metric key with test name
    # "$total_requests": Metric value
    
    PERFORMANCE_METRICS["${test_name}_rps"]="$requests_per_second"
    # Purpose: Store RPS metric
    # Why needed: Provides centralized metrics storage
    # Impact: RPS metric is stored
    # "${test_name}_rps": Metric key with test name
    # "$requests_per_second": Metric value
    
    PERFORMANCE_METRICS["${test_name}_avg_response"]="$avg_response_time"
    # Purpose: Store average response time metric
    # Why needed: Provides centralized metrics storage
    # Impact: Average response time metric is stored
    # "${test_name}_avg_response": Metric key with test name
    # "$avg_response_time": Metric value
    
    PERFORMANCE_METRICS["${test_name}_p95_response"]="$p95_response_time"
    # Purpose: Store P95 response time metric
    # Why needed: Provides centralized metrics storage
    # Impact: P95 response time metric is stored
    # "${test_name}_p95_response": Metric key with test name
    # "$p95_response_time": Metric value
    
    PERFORMANCE_METRICS["${test_name}_p99_response"]="$p99_response_time"
    # Purpose: Store P99 response time metric
    # Why needed: Provides centralized metrics storage
    # Impact: P99 response time metric is stored
    # "${test_name}_p99_response": Metric key with test name
    # "$p99_response_time": Metric value
    
    PERFORMANCE_METRICS["${test_name}_error_rate"]="$error_rate"
    # Purpose: Store error rate metric
    # Why needed: Provides centralized metrics storage
    # Impact: Error rate metric is stored
    # "${test_name}_error_rate": Metric key with test name
    # "$error_rate": Metric value
    
    # =============================================================================
    # TEST COMPLETION
    # =============================================================================
    # Purpose: Log test completion and results
    # Why needed: Provides test completion feedback
    
    print_status "SUCCESS" "${test_name} test completed"
    # Purpose: Log test completion message
    # Why needed: Confirms that test completed successfully
    # Impact: User knows test completed
    # ${test_name}: Shows the test name that completed
    
    print_status "INFO" "Results: ${total_requests} requests, ${requests_per_second} RPS, ${avg_response_time}ms avg response time"
    # Purpose: Log test results summary
    # Why needed: Provides key performance metrics
    # Impact: User sees test results summary
    # ${total_requests}: Shows total requests
    # ${requests_per_second}: Shows RPS
    # ${avg_response_time}: Shows average response time
    
    # =============================================================================
    # CLEANUP
    # =============================================================================
    # Purpose: Clean up temporary files
    # Why needed: Prevents accumulation of temporary files
    
    rm -f "/tmp/hey-${test_name,,}-results.txt"
    # Purpose: Remove temporary results file
    # Why needed: Prevents accumulation of temporary files
    # Impact: Temporary file is removed
    # rm -f: Remove file forcefully
    # "/tmp/hey-${test_name,,}-results.txt": Results file path
}

# Function: Run stress test
run_stress_test() {
    # =============================================================================
    # RUN STRESS TEST FUNCTION
    # =============================================================================
    # Executes stress testing with gradually increasing load levels.
    # Provides comprehensive stress testing capabilities with automatic failure detection.
    # =============================================================================
    
    # Purpose: Execute stress test with gradually increasing load
    # Why needed: Identifies application breaking points and performance limits
    # Impact: Determines maximum sustainable load and failure thresholds
    # Parameters:
    #   $1: Target URL for testing
    #   $2: Test name for identification
    # Usage: run_stress_test "http://service:port" "backend"
    
    local url=$1
    # Purpose: Specifies the target URL for stress testing
    # Why needed: Defines the endpoint to test
    # Impact: Stress test will target this URL
    # Parameter: $1 is the target URL
    
    local test_name=$2
    # Purpose: Specifies the test name for identification
    # Why needed: Provides unique identifier for test results
    # Impact: Test results will be tagged with this name
    # Parameter: $2 is the test name
    
    # =============================================================================
    # STRESS TEST INITIATION
    # =============================================================================
    # Purpose: Log stress test initiation
    # Why needed: Provides visibility into stress test execution
    
    print_status "INFO" "Running ${test_name} stress test on ${url}"
    # Purpose: Log stress test initiation message
    # Why needed: Informs user that stress test is starting
    # Impact: User knows stress test has begun
    # ${test_name}: Shows the test name
    # ${url}: Shows the target URL
    
    # =============================================================================
    # STRESS LEVELS CONFIGURATION
    # =============================================================================
    # Purpose: Define stress levels for gradual load increase
    # Why needed: Provides progressive load testing approach
    
    local stress_levels=(5 10 20 50 100)
    # Purpose: Array of stress levels (concurrent users)
    # Why needed: Defines progressive load levels for testing
    # Impact: Stress test will use these load levels
    # Array contains: 5, 10, 20, 50, 100 concurrent users
    
    # =============================================================================
    # STRESS LEVEL ITERATION
    # =============================================================================
    # Purpose: Test each stress level progressively
    # Why needed: Identifies breaking points and performance degradation
    
    for level in "${stress_levels[@]}"; do
        # Purpose: Iterate through each stress level
        # Why needed: Tests each load level progressively
        # Impact: Each stress level is tested
        
        print_status "INFO" "Testing with ${level} concurrent users"
        # Purpose: Log current stress level
        # Why needed: Informs user of current test level
        # Impact: User knows current stress level
        # ${level}: Shows the current stress level
        
        # =============================================================================
        # STRESS TEST EXECUTION
        # =============================================================================
        # Purpose: Execute stress test at current level
        # Why needed: Provides stress testing capabilities
        
        kubectl run hey-stress-${test_name,,}-${level} --rm -i --restart=Never --image=rakyll/hey:latest -- \
            hey -n 1000 -c "$level" -q 50 -t 30 -z "60s" "$url" 2>/dev/null | tee "/tmp/hey-stress-${test_name,,}-${level}-results.txt"
        # Purpose: Execute stress test at current level
        # Why needed: Provides stress testing capabilities
        # Impact: Stress test is executed and results are captured
        # kubectl run: Create and run a pod
        # hey-stress-${test_name,,}-${level}: Pod name with test name and level
        # --rm: Remove pod after completion
        # -i: Interactive mode
        # --restart=Never: Don't restart pod
        # --image=rakyll/hey:latest: Use hey tool image
        # hey: Load testing tool
        # -n 1000: Number of requests (minimum)
        # -c "$level": Concurrent users (current stress level)
        # -q 50: Request rate per second (fixed)
        # -t 30: Timeout in seconds
        # -z "60s": Test duration (1 minute per level)
        # "$url": Target URL
        # 2>/dev/null: Suppress error messages
        # | tee: Save output to file and display
        # "/tmp/hey-stress-${test_name,,}-${level}-results.txt": Results file path
        
        # =============================================================================
        # RESULTS PARSING
        # =============================================================================
        # Purpose: Parse stress test results
        # Why needed: Extracts performance metrics from test output
        
        local rps
        # Purpose: Variable to store requests per second
        # Why needed: Provides storage for RPS metric
        # Impact: Will contain the requests per second value
        
        local avg_response
        # Purpose: Variable to store average response time
        # Why needed: Provides storage for average response time metric
        # Impact: Will contain the average response time value
        
        local error_rate
        # Purpose: Variable to store error rate
        # Why needed: Provides storage for error rate metric
        # Impact: Will contain the error rate value
        
        rps=$(grep "Requests/sec:" "/tmp/hey-stress-${test_name,,}-${level}-results.txt" | awk '{print $2}' || echo "0")
        # Purpose: Extract requests per second from results
        # Why needed: Provides RPS metric
        # Impact: RPS value is extracted
        # grep "Requests/sec:": Find line containing "Requests/sec:"
        # "/tmp/hey-stress-${test_name,,}-${level}-results.txt": Results file path
        # | awk '{print $2}': Extract second field
        # || echo "0": Default to "0" if not found
        
        avg_response=$(grep "Average:" "/tmp/hey-stress-${test_name,,}-${level}-results.txt" | awk '{print $2}' || echo "0")
        # Purpose: Extract average response time from results
        # Why needed: Provides average response time metric
        # Impact: Average response time value is extracted
        # grep "Average:": Find line containing "Average:"
        # "/tmp/hey-stress-${test_name,,}-${level}-results.txt": Results file path
        # | awk '{print $2}': Extract second field
        # || echo "0": Default to "0" if not found
        
        error_rate=$(grep "Error rate:" "/tmp/hey-stress-${test_name,,}-${level}-results.txt" | awk '{print $3}' || echo "0")
        # Purpose: Extract error rate from results
        # Why needed: Provides error rate metric
        # Impact: Error rate value is extracted
        # grep "Error rate:": Find line containing "Error rate:"
        # "/tmp/hey-stress-${test_name,,}-${level}-results.txt": Results file path
        # | awk '{print $3}': Extract third field
        # || echo "0": Default to "0" if not found
        
        # =============================================================================
        # RESULTS DISPLAY
        # =============================================================================
        # Purpose: Display stress test results
        # Why needed: Provides visibility into test results
        
        print_status "INFO" "Level ${level}: ${rps} RPS, ${avg_response}ms avg response, ${error_rate}% errors"
        # Purpose: Log stress test results
        # Why needed: Shows performance metrics for current level
        # Impact: User sees stress test results
        # ${level}: Shows the stress level
        # ${rps}: Shows RPS
        # ${avg_response}: Shows average response time
        # ${error_rate}: Shows error rate
        
        # =============================================================================
        # ERROR RATE VALIDATION
        # =============================================================================
        # Purpose: Check if error rate is too high
        # Why needed: Prevents continued testing if application is failing
        
        if (( $(echo "$error_rate > 5" | bc -l) )); then
            # Purpose: Check if error rate exceeds threshold
            # Why needed: Prevents continued testing if application is failing
            # Impact: Stops testing if error rate is too high
            # $(echo "$error_rate > 5" | bc -l): Compare error rate with 5% threshold
            
            print_status "WARNING" "High error rate detected at level ${level}: ${error_rate}%"
            # Purpose: Log high error rate warning
            # Why needed: Informs user of high error rate
            # Impact: User knows error rate is too high
            # ${level}: Shows the stress level with high error rate
            # ${error_rate}: Shows the error rate percentage
            
            break
            # Purpose: Exit stress test loop
            # Why needed: Stops testing when error rate is too high
            # Impact: Stress test stops at current level
        fi
        
        # =============================================================================
        # CLEANUP
        # =============================================================================
        # Purpose: Clean up temporary files
        # Why needed: Prevents accumulation of temporary files
        
        rm -f "/tmp/hey-stress-${test_name,,}-${level}-results.txt"
        # Purpose: Remove temporary results file
        # Why needed: Prevents accumulation of temporary files
        # Impact: Temporary file is removed
        # rm -f: Remove file forcefully
        # "/tmp/hey-stress-${test_name,,}-${level}-results.txt": Results file path
    done
}

# Function: Monitor resource usage
monitor_resources() {
    # =============================================================================
    # MONITOR RESOURCES FUNCTION
    # =============================================================================
    # Monitors resource usage of pods during performance testing.
    # Provides comprehensive resource monitoring with CSV output.
    # =============================================================================
    
    # Purpose: Monitor resource usage of pods during testing
    # Why needed: Provides visibility into resource consumption during tests
    # Impact: Enables resource analysis and capacity planning
    # Parameters:
    #   $1: Monitoring duration
    # Usage: monitor_resources "300s"
    
    local duration=$1
    # Purpose: Specifies the monitoring duration
    # Why needed: Controls how long resource monitoring runs
    # Impact: Determines the time window for resource data collection
    # Parameter: $1 is the monitoring duration
    
    # =============================================================================
    # MONITORING INITIATION
    # =============================================================================
    # Purpose: Log monitoring initiation
    # Why needed: Provides visibility into monitoring process
    
    print_status "INFO" "Monitoring resource usage for ${duration}"
    # Purpose: Log monitoring initiation message
    # Why needed: Informs user that resource monitoring is starting
    # Impact: User knows resource monitoring has begun
    # ${duration}: Shows the monitoring duration
    
    # =============================================================================
    # MONITORING POD CREATION
    # =============================================================================
    # Purpose: Create monitoring pod for resource collection
    # Why needed: Provides resource monitoring capabilities
    
    kubectl run resource-monitor --rm -i --restart=Never --image=bitnami/kubectl:latest -- \
        sh -c "
        echo 'Timestamp,Pod,CPU,Memory' > /tmp/resource-usage.csv
        end_time=\$(date -d '+${duration}' +%s)
        while [ \$(date +%s) -lt \$end_time ]; do
            timestamp=\$(date '+%Y-%m-%d %H:%M:%S')
            kubectl top pods -n ${NAMESPACE} --no-headers | while read line; do
                pod=\$(echo \$line | awk '{print \$1}')
                cpu=\$(echo \$line | awk '{print \$2}')
                memory=\$(echo \$line | awk '{print \$3}')
                echo \"\$timestamp,\$pod,\$cpu,\$memory\" >> /tmp/resource-usage.csv
            done
            sleep 10
        done
        cat /tmp/resource-usage.csv
        " 2>/dev/null | tee "/tmp/resource-usage-${NAMESPACE}.csv"
    # Purpose: Create monitoring pod for resource collection
    # Why needed: Provides resource monitoring capabilities
    # Impact: Resource monitoring is executed and results are captured
    # kubectl run: Create and run a pod
    # resource-monitor: Pod name for monitoring
    # --rm: Remove pod after completion
    # -i: Interactive mode
    # --restart=Never: Don't restart pod
    # --image=bitnami/kubectl:latest: Use kubectl image
    # sh -c: Execute shell commands
    # echo 'Timestamp,Pod,CPU,Memory' > /tmp/resource-usage.csv: Create CSV header
    # end_time=\$(date -d '+${duration}' +%s): Calculate end time
    # while [ \$(date +%s) -lt \$end_time ]; do: Loop until end time
    # timestamp=\$(date '+%Y-%m-%d %H:%M:%S'): Get current timestamp
    # kubectl top pods -n ${NAMESPACE} --no-headers: Get pod resource usage
    # pod=\$(echo \$line | awk '{print \$1}'): Extract pod name
    # cpu=\$(echo \$line | awk '{print \$2}'): Extract CPU usage
    # memory=\$(echo \$line | awk '{print \$3}'): Extract memory usage
    # echo \"\$timestamp,\$pod,\$cpu,\$memory\" >> /tmp/resource-usage.csv: Append to CSV
    # sleep 10: Wait 10 seconds between measurements
    # cat /tmp/resource-usage.csv: Display CSV content
    # 2>/dev/null: Suppress error messages
    # | tee: Save output to file and display
    # "/tmp/resource-usage-${NAMESPACE}.csv": Results file path
    
    # =============================================================================
    # MONITORING COMPLETION
    # =============================================================================
    # Purpose: Log monitoring completion
    # Why needed: Confirms monitoring was successful
    
    print_status "SUCCESS" "Resource monitoring completed"
    # Purpose: Log success message for monitoring completion
    # Why needed: Confirms that resource monitoring completed successfully
    # Impact: User knows resource monitoring completed
}

# Function: Test database performance
test_database_performance() {
    # =============================================================================
    # TEST DATABASE PERFORMANCE FUNCTION
    # =============================================================================
    # Tests database performance with comprehensive SQL operations.
    # Provides database performance validation and optimization insights.
    # =============================================================================
    
    # Purpose: Test database performance with SQL operations
    # Why needed: Validates database performance and optimization
    # Impact: Provides database performance metrics and optimization insights
    # Parameters: None (uses global variables)
    # Usage: test_database_performance
    
    # =============================================================================
    # DATABASE TEST INITIATION
    # =============================================================================
    # Purpose: Log database test initiation
    # Why needed: Provides visibility into database testing process
    
    print_status "INFO" "Testing database performance"
    # Purpose: Log database test initiation message
    # Why needed: Informs user that database performance testing is starting
    # Impact: User knows database performance testing has begun
    
    # =============================================================================
    # DATABASE POD DISCOVERY
    # =============================================================================
    # Purpose: Get database pod for testing
    # Why needed: Provides database pod for performance testing
    
    local db_pod
    # Purpose: Variable to store database pod name
    # Why needed: Provides database pod for performance testing
    # Impact: Will contain the database pod name
    
    db_pod=$(kubectl get pods -n "$NAMESPACE" -l app=ecommerce,component=database -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get database pod name
    # Why needed: Provides database pod for performance testing
    # Impact: Database pod name is retrieved
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Target namespace
    # -l app=ecommerce,component=database: Label selector for database pod
    # -o jsonpath='{.items[0].metadata.name}': Extract pod name from JSON
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # DATABASE POD VALIDATION
    # =============================================================================
    # Purpose: Validate database pod exists
    # Why needed: Ensures database pod is available for testing
    
    if [ -z "$db_pod" ]; then
        # Purpose: Check if database pod name is empty
        # Why needed: Ensures database pod is available
        # Impact: Proceeds with testing if pod exists
        
        print_status "ERROR" "Database pod not found"
        # Purpose: Log error message for missing database pod
        # Why needed: Informs user that database pod is missing
        # Impact: User knows database pod is missing
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates that database testing cannot proceed
        # Impact: Calling function knows database testing failed
    fi
    
    # =============================================================================
    # DATABASE PERFORMANCE TEST EXECUTION
    # =============================================================================
    # Purpose: Execute database performance test
    # Why needed: Provides database performance validation
    
    kubectl exec -n "$NAMESPACE" "$db_pod" -- psql -U postgres -d ecommerce -c "
        -- Create test table
        CREATE TABLE IF NOT EXISTS performance_test (
            id SERIAL PRIMARY KEY,
            data TEXT,
            created_at TIMESTAMP DEFAULT NOW()
        );
        
        -- Insert test data
        INSERT INTO performance_test (data) 
        SELECT 'test_data_' || generate_series(1, 1000);
        
        -- Test query performance
        EXPLAIN ANALYZE SELECT * FROM performance_test WHERE id > 500;
        
        -- Test index performance
        CREATE INDEX IF NOT EXISTS idx_performance_test_id ON performance_test(id);
        EXPLAIN ANALYZE SELECT * FROM performance_test WHERE id > 500;
        
        -- Clean up
        DROP TABLE performance_test;
    " 2>/dev/null | tee "/tmp/db-performance-${NAMESPACE}.txt"
    # Purpose: Execute database performance test
    # Why needed: Provides database performance validation
    # Impact: Database performance test is executed and results are captured
    # kubectl exec: Execute command in pod
    # -n "$NAMESPACE": Target namespace
    # "$db_pod": Database pod name
    # -- psql: PostgreSQL command-line client
    # -U postgres: Database user
    # -d ecommerce: Database name
    # -c: Execute command
    # CREATE TABLE IF NOT EXISTS performance_test: Create test table
    # INSERT INTO performance_test: Insert test data
    # EXPLAIN ANALYZE: Analyze query performance
    # CREATE INDEX: Create index for performance testing
    # DROP TABLE: Clean up test table
    # 2>/dev/null: Suppress error messages
    # | tee: Save output to file and display
    # "/tmp/db-performance-${NAMESPACE}.txt": Results file path
    
    # =============================================================================
    # DATABASE TEST COMPLETION
    # =============================================================================
    # Purpose: Log database test completion
    # Why needed: Confirms database testing was successful
    
    print_status "SUCCESS" "Database performance test completed"
    # Purpose: Log success message for database test completion
    # Why needed: Confirms that database performance testing completed successfully
    # Impact: User knows database performance testing completed
}

# Function: Test monitoring stack performance
test_monitoring_performance() {
    # =============================================================================
    # TEST MONITORING STACK PERFORMANCE FUNCTION
    # =============================================================================
    # Tests monitoring stack performance including Prometheus and Grafana.
    # Provides comprehensive monitoring system validation.
    # =============================================================================
    
    # Purpose: Test monitoring stack performance
    # Why needed: Validates monitoring system performance and accessibility
    # Impact: Ensures monitoring systems are functioning properly
    # Parameters: None (uses global variables)
    # Usage: test_monitoring_performance
    
    # =============================================================================
    # MONITORING TEST INITIATION
    # =============================================================================
    # Purpose: Log monitoring test initiation
    # Why needed: Provides visibility into monitoring testing process
    
    print_status "INFO" "Testing monitoring stack performance"
    # Purpose: Log monitoring test initiation message
    # Why needed: Informs user that monitoring performance testing is starting
    # Impact: User knows monitoring performance testing has begun
    
    # =============================================================================
    # PROMETHEUS PERFORMANCE TESTING
    # =============================================================================
    # Purpose: Test Prometheus query performance
    # Why needed: Validates Prometheus functionality and performance
    
    local prometheus_pod
    # Purpose: Variable to store Prometheus pod name
    # Why needed: Provides Prometheus pod for performance testing
    # Impact: Will contain the Prometheus pod name
    
    prometheus_pod=$(kubectl get pods -n "$NAMESPACE" -l app=prometheus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get Prometheus pod name
    # Why needed: Provides Prometheus pod for performance testing
    # Impact: Prometheus pod name is retrieved
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Target namespace
    # -l app=prometheus: Label selector for Prometheus pod
    # -o jsonpath='{.items[0].metadata.name}': Extract pod name from JSON
    # 2>/dev/null: Suppress error messages
    
    if [ -n "$prometheus_pod" ]; then
        # Purpose: Check if Prometheus pod exists
        # Why needed: Ensures Prometheus pod is available for testing
        # Impact: Proceeds with Prometheus testing if pod exists
        
        print_status "INFO" "Testing Prometheus query performance"
        # Purpose: Log Prometheus test initiation
        # Why needed: Informs user that Prometheus testing is starting
        # Impact: User knows Prometheus testing has begun
        
        # =============================================================================
        # PROMETHEUS BASIC QUERY TEST
        # =============================================================================
        # Purpose: Test Prometheus basic query performance
        # Why needed: Validates Prometheus query functionality
        
        kubectl exec -n "$NAMESPACE" "$prometheus_pod" -- wget -qO- "http://localhost:9090/api/v1/query?query=up" 2>/dev/null | \
            jq '.data.result | length' 2>/dev/null || echo "0"
        # Purpose: Test Prometheus basic query performance
        # Why needed: Validates Prometheus query functionality
        # Impact: Prometheus basic query is tested
        # kubectl exec: Execute command in pod
        # -n "$NAMESPACE": Target namespace
        # "$prometheus_pod": Prometheus pod name
        # -- wget: Download web content
        # -qO-: Quiet output to stdout
        # "http://localhost:9090/api/v1/query?query=up": Prometheus query API
        # 2>/dev/null: Suppress error messages
        # | jq '.data.result | length': Extract result count from JSON
        # || echo "0": Default to "0" if command fails
        
        # =============================================================================
        # PROMETHEUS RANGE QUERY TEST
        # =============================================================================
        # Purpose: Test Prometheus range query performance
        # Why needed: Validates Prometheus range query functionality
        
        kubectl exec -n "$NAMESPACE" "$prometheus_pod" -- wget -qO- "http://localhost:9090/api/v1/query_range?query=up&start=$(date -d '5 minutes ago' +%s)&end=$(date +%s)&step=15s" 2>/dev/null | \
            jq '.data.result | length' 2>/dev/null || echo "0"
        # Purpose: Test Prometheus range query performance
        # Why needed: Validates Prometheus range query functionality
        # Impact: Prometheus range query is tested
        # kubectl exec: Execute command in pod
        # -n "$NAMESPACE": Target namespace
        # "$prometheus_pod": Prometheus pod name
        # -- wget: Download web content
        # -qO-: Quiet output to stdout
        # "http://localhost:9090/api/v1/query_range": Prometheus range query API
        # query=up: Query for up metric
        # start=$(date -d '5 minutes ago' +%s): Start time (5 minutes ago)
        # end=$(date +%s): End time (now)
        # step=15s: Step size (15 seconds)
        # 2>/dev/null: Suppress error messages
        # | jq '.data.result | length': Extract result count from JSON
        # || echo "0": Default to "0" if command fails
        
        print_status "SUCCESS" "Prometheus performance test completed"
        # Purpose: Log Prometheus test completion
        # Why needed: Confirms Prometheus testing was successful
        # Impact: User knows Prometheus testing completed
    fi
    
    # =============================================================================
    # GRAFANA PERFORMANCE TESTING
    # =============================================================================
    # Purpose: Test Grafana performance
    # Why needed: Validates Grafana functionality and accessibility
    
    local grafana_pod
    # Purpose: Variable to store Grafana pod name
    # Why needed: Provides Grafana pod for performance testing
    # Impact: Will contain the Grafana pod name
    
    grafana_pod=$(kubectl get pods -n "$NAMESPACE" -l app=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get Grafana pod name
    # Why needed: Provides Grafana pod for performance testing
    # Impact: Grafana pod name is retrieved
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Target namespace
    # -l app=grafana: Label selector for Grafana pod
    # -o jsonpath='{.items[0].metadata.name}': Extract pod name from JSON
    # 2>/dev/null: Suppress error messages
    
    if [ -n "$grafana_pod" ]; then
        # Purpose: Check if Grafana pod exists
        # Why needed: Ensures Grafana pod is available for testing
        # Impact: Proceeds with Grafana testing if pod exists
        
        print_status "INFO" "Testing Grafana performance"
        # Purpose: Log Grafana test initiation
        # Why needed: Informs user that Grafana testing is starting
        # Impact: User knows Grafana testing has begun
        
        # =============================================================================
        # GRAFANA ACCESSIBILITY TEST
        # =============================================================================
        # Purpose: Test Grafana dashboard loading
        # Why needed: Validates Grafana accessibility and performance
        
        local grafana_url
        # Purpose: Variable to store Grafana URL
        # Why needed: Provides Grafana URL for testing
        # Impact: Will contain the Grafana URL
        
        grafana_url=$(get_service_url "grafana-service" "3000" "/")
        # Purpose: Get Grafana service URL
        # Why needed: Provides Grafana URL for testing
        # Impact: Grafana URL is retrieved
        # get_service_url: Function to get service URL
        # "grafana-service": Grafana service name
        # "3000": Grafana service port
        # "/": Grafana URL path
        
        if [ -n "$grafana_url" ]; then
            # Purpose: Check if Grafana URL was retrieved
            # Why needed: Ensures Grafana URL is available for testing
            # Impact: Proceeds with Grafana testing if URL exists
            
            kubectl run grafana-test --rm -i --restart=Never --image=curlimages/curl:latest -- \
                curl -f -s --max-time 10 "$grafana_url" >/dev/null 2>&1
            # Purpose: Test Grafana accessibility
            # Why needed: Validates Grafana accessibility and performance
            # Impact: Grafana accessibility is tested
            # kubectl run: Create and run a pod
            # grafana-test: Pod name for testing
            # --rm: Remove pod after completion
            # -i: Interactive mode
            # --restart=Never: Don't restart pod
            # --image=curlimages/curl:latest: Use curl image
            # curl: HTTP client
            # -f: Fail silently on HTTP errors
            # -s: Silent mode
            # --max-time 10: Maximum time for request (10 seconds)
            # "$grafana_url": Target Grafana URL
            # >/dev/null 2>&1: Suppress output
            
            if [ $? -eq 0 ]; then
                # Purpose: Check if Grafana test was successful
                # Why needed: Determines Grafana accessibility status
                # Impact: Proceeds with success message if accessible
                
                print_status "SUCCESS" "Grafana is accessible"
                # Purpose: Log Grafana accessibility success
                # Why needed: Confirms Grafana is accessible
                # Impact: User knows Grafana is accessible
            else
                # Purpose: Handle Grafana accessibility failure
                # Why needed: Provides error feedback for Grafana issues
                # Impact: Logs error message for Grafana accessibility
                
                print_status "ERROR" "Grafana is not accessible"
                # Purpose: Log Grafana accessibility error
                # Why needed: Informs user that Grafana is not accessible
                # Impact: User knows Grafana is not accessible
            fi
        fi
    fi
}

# =============================================================================
# MAIN PERFORMANCE TESTING
# =============================================================================

print_status "INFO" "Starting performance testing for namespace: ${NAMESPACE}"
print_status "INFO" "Test parameters: duration=${DURATION}, concurrent=${CONCURRENT_USERS}, rate=${REQUEST_RATE}, type=${TEST_TYPE}"

# Check prerequisites
if ! command_exists kubectl; then
    print_status "ERROR" "kubectl command not found"
    exit 1
fi

if ! command_exists bc; then
    print_status "ERROR" "bc command not found (required for calculations)"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    print_status "ERROR" "Namespace ${NAMESPACE} does not exist"
    exit 1
fi

# Get service URLs
local backend_url
local frontend_url
local database_url

backend_url=$(get_service_url "ecommerce-backend-service" "8000" "/")
frontend_url=$(get_service_url "ecommerce-frontend-service" "3000" "/")
database_url=$(get_service_url "ecommerce-database-service" "5432" "/")

if [ -z "$backend_url" ] || [ -z "$frontend_url" ]; then
    print_status "ERROR" "Required services not found"
    exit 1
fi

# Run performance tests based on type
case $TEST_TYPE in
    "load")
        print_status "INFO" "Running load tests"
        
        # Test backend API
        run_hey_test "$backend_url" "BackendAPI" "$DURATION" "$CONCURRENT_USERS" "$REQUEST_RATE"
        
        # Test frontend
        run_hey_test "$frontend_url" "Frontend" "$DURATION" "$CONCURRENT_USERS" "$REQUEST_RATE"
        
        # Monitor resources during test
        monitor_resources "$DURATION" &
        MONITOR_PID=$!
        
        # Wait for load test to complete
        wait $MONITOR_PID 2>/dev/null || true
        
        ;;
    "stress")
        print_status "INFO" "Running stress tests"
        
        # Stress test backend
        run_stress_test "$backend_url" "BackendAPI"
        
        # Stress test frontend
        run_stress_test "$frontend_url" "Frontend"
        
        ;;
    "database")
        print_status "INFO" "Running database performance tests"
        test_database_performance
        ;;
    "monitoring")
        print_status "INFO" "Running monitoring stack performance tests"
        test_monitoring_performance
        ;;
    "full")
        print_status "INFO" "Running full performance test suite"
        
        # Run all tests
        run_hey_test "$backend_url" "BackendAPI" "$DURATION" "$CONCURRENT_USERS" "$REQUEST_RATE"
        run_hey_test "$frontend_url" "Frontend" "$DURATION" "$CONCURRENT_USERS" "$REQUEST_RATE"
        test_database_performance
        test_monitoring_performance
        
        # Monitor resources
        monitor_resources "$DURATION" &
        MONITOR_PID=$!
        wait $MONITOR_PID 2>/dev/null || true
        
        ;;
    *)
        print_status "ERROR" "Unknown test type: ${TEST_TYPE}"
        print_status "INFO" "Available types: load, stress, database, monitoring, full"
        exit 1
        ;;
esac

# =============================================================================
# PERFORMANCE SUMMARY
# =============================================================================

print_status "INFO" "Performance testing completed"

echo ""
echo "============================================================================="
echo "PERFORMANCE TEST SUMMARY"
echo "============================================================================="
echo "Test Type: ${TEST_TYPE}"
echo "Duration: ${DURATION}"
echo "Concurrent Users: ${CONCURRENT_USERS}"
echo "Request Rate: ${REQUEST_RATE}"
echo ""

# Display metrics
for metric in "${!PERFORMANCE_METRICS[@]}"; do
    echo "${metric}: ${PERFORMANCE_METRICS[$metric]}"
done

# Performance thresholds
print_status "INFO" "Performance thresholds:"
print_status "INFO" "- Response time < 200ms (good), < 500ms (acceptable), > 1000ms (poor)"
print_status "INFO" "- Error rate < 1% (good), < 5% (acceptable), > 10% (poor)"
print_status "INFO" "- RPS > 100 (good), > 50 (acceptable), < 10 (poor)"

# Check if results meet thresholds
local overall_status="PASS"
for metric in "${!PERFORMANCE_METRICS[@]}"; do
    if [[ "$metric" == *"_error_rate" ]]; then
        local error_rate="${PERFORMANCE_METRICS[$metric]}"
        if (( $(echo "$error_rate > 5" | bc -l) )); then
            print_status "WARNING" "High error rate in ${metric}: ${error_rate}%"
            overall_status="WARN"
        fi
    fi
done

if [ "$overall_status" = "PASS" ]; then
    print_status "SUCCESS" "Performance tests passed!"
else
    print_status "WARNING" "Performance tests completed with warnings"
fi

# Clean up temporary files
rm -f /tmp/hey-*-results.txt /tmp/resource-usage-*.csv /tmp/db-performance-*.txt

exit 0
