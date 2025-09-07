#!/bin/bash
# =============================================================================
# PERFORMANCE BENCHMARKING SCRIPT
# =============================================================================
# This script performs comprehensive performance benchmarking of the e-commerce
# foundation infrastructure, including load testing, resource monitoring, and
# automated report generation.
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
# Purpose: Red color code for error messages
# Why needed: Provides visual distinction for error output
# Impact: Error messages are displayed in red color
# Usage: Used in error() function for critical messages

GREEN='\033[0;32m'
# Purpose: Green color code for success messages
# Why needed: Provides visual distinction for success output
# Impact: Success messages are displayed in green color
# Usage: Used in success() function for completion messages

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages
# Why needed: Provides visual distinction for warning output
# Impact: Warning messages are displayed in yellow color
# Usage: Used in warning() function for cautionary messages

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
# SCRIPT VARIABLES
# =============================================================================
# Define variables for consistent configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for e-commerce application
# Why needed: Provides consistent namespace reference throughout script
# Impact: All Kubernetes operations target this namespace
# Value: 'ecommerce' matches the project's application namespace

FRONTEND_SERVICE="ecommerce-frontend-service"
# Purpose: Specifies the frontend service name for testing
# Why needed: Provides consistent service reference for frontend testing
# Impact: Frontend performance tests target this service
# Value: Must match the actual frontend service name in Kubernetes

BACKEND_SERVICE="ecommerce-backend-service"
# Purpose: Specifies the backend service name for testing
# Why needed: Provides consistent service reference for backend testing
# Impact: Backend performance tests target this service
# Value: Must match the actual backend service name in Kubernetes

RESULTS_DIR="./performance-results/$(date +%Y%m%d-%H%M%S)"
# Purpose: Specifies the directory for storing performance test results
# Why needed: Provides organized storage for test artifacts
# Impact: All test results are stored in timestamped directory
# Format: YYYYMMDD-HHMMSS ensures unique directory names

FRONTEND_PORT=8080
# Purpose: Specifies the local port for frontend port forwarding
# Why needed: Provides consistent port reference for frontend testing
# Impact: Frontend tests connect to this local port
# Value: 8080 is standard HTTP alternate port

BACKEND_PORT=8081
# Purpose: Specifies the local port for backend port forwarding
# Why needed: Provides consistent port reference for backend testing
# Impact: Backend tests connect to this local port
# Value: 8081 avoids conflicts with frontend port

K6_VERSION="v0.47.0"
# Purpose: Specifies the K6 version to install if not present
# Why needed: Ensures consistent K6 version across environments
# Impact: K6 installation uses this specific version
# Value: Latest stable version with required features

TEST_DURATION=300
# Purpose: Specifies the duration for resource monitoring in seconds
# Why needed: Provides consistent monitoring period during tests
# Impact: Resource monitoring runs for this duration
# Value: 300 seconds (5 minutes) provides adequate monitoring data

# Create results directory with proper error handling
mkdir -p "$RESULTS_DIR"
# Purpose: Creates the results directory for storing test artifacts
# Why needed: Ensures directory exists before writing test results
# Impact: All subsequent file operations can write to this directory
# Command: mkdir -p creates directory and parent directories if needed

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
# PREREQUISITE CHECKING FUNCTIONS
# =============================================================================
# Functions to validate required tools and services before running benchmarks.
# =============================================================================

check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates that all required tools and services are available for testing.
    # =============================================================================
    
    log "Checking prerequisites for performance benchmarking..."
    # Purpose: Informs user that prerequisite checking is starting
    # Why needed: Provides feedback on script progress
    # Impact: User knows the validation process has begun
    
    # =============================================================================
    # K6 INSTALLATION CHECK AND SETUP
    # =============================================================================
    # Check if K6 load testing tool is installed, install if missing.
    # =============================================================================
    
    if ! command -v k6 &> /dev/null; then
        # Purpose: Check if K6 command is available in PATH
        # Why needed: K6 is required for load testing scenarios
        # Impact: If not found, automatic installation is attempted
        # Command: command -v checks if executable exists in PATH
        
        warning "K6 not found. Installing K6 version $K6_VERSION..."
        # Purpose: Inform user that K6 installation is starting
        # Why needed: User should know about automatic tool installation
        # Impact: User is aware of the installation process
        
        local k6_url="https://github.com/grafana/k6/releases/download/$K6_VERSION/k6-$K6_VERSION-linux-amd64.tar.gz"
        # Purpose: Specifies the download URL for K6 binary
        # Why needed: Provides the source for K6 installation
        # Impact: K6 will be downloaded from this official release URL
        # Format: GitHub releases URL with version and architecture
        
        curl -L "$k6_url" | tar xvz --strip-components 1
        # Purpose: Download and extract K6 binary
        # Why needed: Installs K6 tool for load testing
        # Impact: K6 binary is extracted to current directory
        # Command: curl downloads, tar extracts with path stripping
        
        sudo mv k6 /usr/local/bin/
        # Purpose: Move K6 binary to system PATH
        # Why needed: Makes K6 available system-wide
        # Impact: K6 command becomes available in PATH
        # Location: /usr/local/bin is standard for user-installed binaries
        
        if command -v k6 &> /dev/null; then
            # Purpose: Verify K6 installation was successful
            # Why needed: Confirms the installation completed properly
            # Impact: Provides feedback on installation success
            
            success "K6 $K6_VERSION installed successfully"
            # Purpose: Confirm successful K6 installation
            # Why needed: User needs confirmation of successful installation
            # Impact: User knows K6 is ready for use
        else
            error "Failed to install K6. Please install manually."
            # Purpose: Report K6 installation failure
            # Why needed: User needs to know about installation problems
            # Impact: Script will exit due to missing prerequisite
            
            exit 1
            # Purpose: Exit script due to failed prerequisite
            # Why needed: Cannot continue without required tools
            # Impact: Script terminates with error code 1
        fi
    else
        success "K6 found: $(k6 version)"
        # Purpose: Confirm K6 is already available
        # Why needed: User should know existing tools are detected
        # Impact: Shows K6 version for reference
    fi
    
    # =============================================================================
    # KUBECTL AVAILABILITY CHECK
    # =============================================================================
    # Verify kubectl is available for Kubernetes cluster operations.
    # =============================================================================
    
    if ! command -v kubectl &> /dev/null; then
        # Purpose: Check if kubectl command is available
        # Why needed: kubectl is required for Kubernetes operations
        # Impact: Script cannot continue without kubectl
        
        error "kubectl not found. Please install kubectl."
        # Purpose: Report missing kubectl tool
        # Why needed: User needs to install kubectl manually
        # Impact: Script will exit due to missing prerequisite
        
        exit 1
        # Purpose: Exit script due to missing kubectl
        # Why needed: Cannot perform Kubernetes operations without kubectl
        # Impact: Script terminates with error code 1
    else
        success "kubectl found: $(kubectl version --client --short 2>/dev/null || echo 'version check failed')"
        # Purpose: Confirm kubectl availability and show version
        # Why needed: User should know kubectl is available
        # Impact: Shows kubectl version or fallback message
    fi
    
    # =============================================================================
    # KUBERNETES CLUSTER CONNECTIVITY CHECK
    # =============================================================================
    # Verify connection to Kubernetes cluster and namespace existence.
    # =============================================================================
    
    if ! kubectl cluster-info &> /dev/null; then
        # Purpose: Test connectivity to Kubernetes cluster
        # Why needed: Cluster access is required for service operations
        # Impact: Script cannot continue without cluster access
        
        error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        # Purpose: Report cluster connectivity failure
        # Why needed: User needs to fix cluster configuration
        # Impact: Script will exit due to cluster access failure
        
        exit 1
        # Purpose: Exit script due to cluster connectivity failure
        # Why needed: Cannot perform operations without cluster access
        # Impact: Script terminates with error code 1
    else
        success "Kubernetes cluster connection verified"
        # Purpose: Confirm cluster connectivity
        # Why needed: User should know cluster is accessible
        # Impact: Provides confidence in cluster operations
    fi
    
    # =============================================================================
    # SERVICE EXISTENCE VERIFICATION
    # =============================================================================
    # Check that required services exist in the target namespace.
    # =============================================================================
    
    if ! kubectl get svc -n "$NAMESPACE" "$FRONTEND_SERVICE" &> /dev/null; then
        # Purpose: Verify frontend service exists in namespace
        # Why needed: Frontend service is required for frontend testing
        # Impact: Script cannot test frontend without the service
        
        error "Frontend service '$FRONTEND_SERVICE' not found in namespace '$NAMESPACE'"
        # Purpose: Report missing frontend service
        # Why needed: User needs to deploy frontend service first
        # Impact: Script will exit due to missing service
        
        exit 1
        # Purpose: Exit script due to missing frontend service
        # Why needed: Cannot test frontend without the service
        # Impact: Script terminates with error code 1
    else
        success "Frontend service '$FRONTEND_SERVICE' found in namespace '$NAMESPACE'"
        # Purpose: Confirm frontend service availability
        # Why needed: User should know required services are present
        # Impact: Provides confidence in frontend testing capability
    fi
    
    if ! kubectl get svc -n "$NAMESPACE" "$BACKEND_SERVICE" &> /dev/null; then
        # Purpose: Verify backend service exists in namespace
        # Why needed: Backend service is required for backend testing
        # Impact: Script cannot test backend without the service
        
        error "Backend service '$BACKEND_SERVICE' not found in namespace '$NAMESPACE'"
        # Purpose: Report missing backend service
        # Why needed: User needs to deploy backend service first
        # Impact: Script will exit due to missing service
        
        exit 1
        # Purpose: Exit script due to missing backend service
        # Why needed: Cannot test backend without the service
        # Impact: Script terminates with error code 1
    else
        success "Backend service '$BACKEND_SERVICE' found in namespace '$NAMESPACE'"
        # Purpose: Confirm backend service availability
        # Why needed: User should know required services are present
        # Impact: Provides confidence in backend testing capability
    fi
    
    success "Prerequisites check completed successfully"
    # Purpose: Confirm all prerequisites are satisfied
    # Why needed: User should know the system is ready for testing
    # Impact: Provides confidence to proceed with benchmarking
}

# =============================================================================
# PORT FORWARDING MANAGEMENT FUNCTIONS
# =============================================================================
# Functions to manage Kubernetes port forwarding for performance testing.
# =============================================================================

setup_port_forwarding() {
    # =============================================================================
    # SETUP PORT FORWARDING FUNCTION
    # =============================================================================
    # Establishes port forwarding connections to Kubernetes services for testing.
    # =============================================================================
    
    log "Setting up port forwarding for performance testing..."
    # Purpose: Inform user that port forwarding setup is starting
    # Why needed: User should know about network setup progress
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # CLEANUP EXISTING PORT FORWARDS
    # =============================================================================
    # Kill any existing port forwarding processes to avoid conflicts.
    # =============================================================================
    
    pkill -f "kubectl port-forward" || true
    # Purpose: Kill existing kubectl port-forward processes
    # Why needed: Prevents port conflicts from previous runs
    # Impact: Cleans up any leftover port forwarding processes
    # Command: pkill with pattern matching, || true prevents script exit on no matches
    
    sleep 2
    # Purpose: Wait for process cleanup to complete
    # Why needed: Ensures processes are fully terminated before starting new ones
    # Impact: Prevents race conditions in port binding
    # Duration: 2 seconds is sufficient for process cleanup
    
    # =============================================================================
    # START FRONTEND PORT FORWARDING
    # =============================================================================
    # Establish port forwarding for frontend service testing.
    # =============================================================================
    
    log "Starting frontend port forwarding: $FRONTEND_SERVICE:80 -> localhost:$FRONTEND_PORT"
    # Purpose: Inform user about frontend port forwarding setup
    # Why needed: User should know which ports are being forwarded
    # Impact: Provides visibility into network configuration
    
    kubectl port-forward -n "$NAMESPACE" "svc/$FRONTEND_SERVICE" "$FRONTEND_PORT:80" &
    # Purpose: Start port forwarding for frontend service
    # Why needed: Enables local access to frontend service for testing
    # Impact: Frontend becomes accessible at localhost:FRONTEND_PORT
    # Command: kubectl port-forward runs in background with &
    
    FRONTEND_PID=$!
    # Purpose: Capture process ID of frontend port forwarding
    # Why needed: Allows cleanup of specific port forwarding process
    # Impact: Enables targeted process management
    # Variable: $! contains PID of last background process
    
    # =============================================================================
    # START BACKEND PORT FORWARDING
    # =============================================================================
    # Establish port forwarding for backend service testing.
    # =============================================================================
    
    log "Starting backend port forwarding: $BACKEND_SERVICE:80 -> localhost:$BACKEND_PORT"
    # Purpose: Inform user about backend port forwarding setup
    # Why needed: User should know which ports are being forwarded
    # Impact: Provides visibility into network configuration
    
    kubectl port-forward -n "$NAMESPACE" "svc/$BACKEND_SERVICE" "$BACKEND_PORT:80" &
    # Purpose: Start port forwarding for backend service
    # Why needed: Enables local access to backend service for testing
    # Impact: Backend becomes accessible at localhost:BACKEND_PORT
    # Command: kubectl port-forward runs in background with &
    
    BACKEND_PID=$!
    # Purpose: Capture process ID of backend port forwarding
    # Why needed: Allows cleanup of specific port forwarding process
    # Impact: Enables targeted process management
    # Variable: $! contains PID of last background process
    
    # =============================================================================
    # WAIT FOR PORT FORWARDS TO BE READY
    # =============================================================================
    # Allow time for port forwarding connections to establish.
    # =============================================================================
    
    log "Waiting for port forwarding connections to establish..."
    # Purpose: Inform user about connection establishment wait
    # Why needed: User should know why there's a delay
    # Impact: Sets expectation for setup time
    
    sleep 5
    # Purpose: Wait for port forwarding to become active
    # Why needed: Port forwarding needs time to establish connections
    # Impact: Ensures services are accessible before testing
    # Duration: 5 seconds is typically sufficient for connection establishment
    
    # =============================================================================
    # VERIFY FRONTEND CONNECTIVITY
    # =============================================================================
    # Test that frontend service is accessible through port forwarding.
    # =============================================================================
    
    if curl -s "http://localhost:$FRONTEND_PORT" > /dev/null; then
        # Purpose: Test frontend service connectivity
        # Why needed: Verifies port forwarding is working correctly
        # Impact: Confirms frontend is ready for testing
        # Command: curl -s makes silent request, > /dev/null discards output
        
        success "Frontend port forwarding ready at localhost:$FRONTEND_PORT"
        # Purpose: Confirm frontend accessibility
        # Why needed: User should know frontend is ready for testing
        # Impact: Provides confidence in frontend test capability
    else
        error "Frontend port forwarding failed - service not accessible"
        # Purpose: Report frontend connectivity failure
        # Why needed: User needs to know about connection problems
        # Impact: May indicate service or networking issues
        
        exit 1
        # Purpose: Exit script due to frontend connectivity failure
        # Why needed: Cannot perform frontend testing without connectivity
        # Impact: Script terminates with error code 1
    fi
    
    # =============================================================================
    # VERIFY BACKEND CONNECTIVITY
    # =============================================================================
    # Test that backend service is accessible through port forwarding.
    # =============================================================================
    
    if curl -s "http://localhost:$BACKEND_PORT/health" > /dev/null; then
        # Purpose: Test backend service connectivity via health endpoint
        # Why needed: Verifies port forwarding and service health
        # Impact: Confirms backend is ready for testing
        # Endpoint: /health is standard health check endpoint
        
        success "Backend port forwarding ready at localhost:$BACKEND_PORT"
        # Purpose: Confirm backend accessibility
        # Why needed: User should know backend is ready for testing
        # Impact: Provides confidence in backend test capability
    else
        warning "Backend health check failed, continuing anyway..."
        # Purpose: Report backend health check failure but continue
        # Why needed: Health endpoint might not exist, but service might work
        # Impact: Script continues but user is warned about potential issues
        
        log "Backend may not have /health endpoint, will attempt testing anyway"
        # Purpose: Explain why health check failed
        # Why needed: User should understand the warning context
        # Impact: Provides context for the warning message
    fi
}

cleanup_port_forwarding() {
    # =============================================================================
    # CLEANUP PORT FORWARDING FUNCTION
    # =============================================================================
    # Terminates port forwarding processes and cleans up network connections.
    # =============================================================================
    
    log "Cleaning up port forwarding connections..."
    # Purpose: Inform user that cleanup is starting
    # Why needed: User should know about cleanup process
    # Impact: Provides feedback on script cleanup
    
    # =============================================================================
    # TERMINATE SPECIFIC PORT FORWARDING PROCESSES
    # =============================================================================
    # Kill the specific port forwarding processes by PID.
    # =============================================================================
    
    if [[ -n "${FRONTEND_PID:-}" ]]; then
        # Purpose: Check if frontend PID variable exists and is not empty
        # Why needed: Prevents errors when trying to kill non-existent process
        # Impact: Safely handles cases where port forwarding wasn't started
        # Syntax: ${FRONTEND_PID:-} provides empty string if variable is unset
        
        kill "$FRONTEND_PID" 2>/dev/null || true
        # Purpose: Terminate frontend port forwarding process
        # Why needed: Cleans up network resources and processes
        # Impact: Stops frontend port forwarding
        # Command: kill with PID, 2>/dev/null suppresses errors, || true prevents script exit
        
        log "Frontend port forwarding (PID: $FRONTEND_PID) terminated"
        # Purpose: Confirm frontend port forwarding cleanup
        # Why needed: User should know cleanup was successful
        # Impact: Provides feedback on cleanup progress
    fi
    
    if [[ -n "${BACKEND_PID:-}" ]]; then
        # Purpose: Check if backend PID variable exists and is not empty
        # Why needed: Prevents errors when trying to kill non-existent process
        # Impact: Safely handles cases where port forwarding wasn't started
        
        kill "$BACKEND_PID" 2>/dev/null || true
        # Purpose: Terminate backend port forwarding process
        # Why needed: Cleans up network resources and processes
        # Impact: Stops backend port forwarding
        # Command: kill with PID, 2>/dev/null suppresses errors, || true prevents script exit
        
        log "Backend port forwarding (PID: $BACKEND_PID) terminated"
        # Purpose: Confirm backend port forwarding cleanup
        # Why needed: User should know cleanup was successful
        # Impact: Provides feedback on cleanup progress
    fi
    
    # =============================================================================
    # CLEANUP ANY REMAINING PORT FORWARDING PROCESSES
    # =============================================================================
    # Kill any remaining kubectl port-forward processes as safety measure.
    # =============================================================================
    
    pkill -f "kubectl port-forward" || true
    # Purpose: Kill any remaining kubectl port-forward processes
    # Why needed: Ensures complete cleanup of port forwarding
    # Impact: Prevents leftover processes from consuming resources
    # Command: pkill with pattern matching, || true prevents script exit
    
    success "Port forwarding cleanup completed"
    # Purpose: Confirm complete port forwarding cleanup
    # Why needed: User should know cleanup was successful
    # Impact: Provides confidence that resources are cleaned up
}

# =============================================================================
# PERFORMANCE TESTING FUNCTIONS
# =============================================================================
# Functions to execute various performance testing tools and collect results.
# =============================================================================

run_k6_tests() {
    # =============================================================================
    # RUN K6 LOAD TESTS FUNCTION
    # =============================================================================
    # Executes K6 load testing scenarios and saves results to files.
    # =============================================================================
    
    log "Running K6 load testing scenarios..."
    # Purpose: Inform user that K6 testing is starting
    # Why needed: User should know about test execution progress
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # UPDATE K6 SCRIPT CONFIGURATION
    # =============================================================================
    # Modify K6 script to use correct backend URL for testing.
    # =============================================================================
    
    local k6_script="performance/k6-load-test.js"
    # Purpose: Define path to K6 test script
    # Why needed: Provides consistent reference to test script location
    # Impact: Script operations target this specific file
    # Path: Relative path from project root directory
    
    if [[ -f "$k6_script" ]]; then
        # Purpose: Check if K6 test script exists
        # Why needed: Prevents errors when trying to modify non-existent file
        # Impact: Only modifies script if it exists
        
        log "Updating K6 script configuration for backend URL..."
        # Purpose: Inform user about script configuration update
        # Why needed: User should know about automatic configuration
        # Impact: Provides transparency about script modifications
        
        sed -i "s|const BASE_URL = '.*'|const BASE_URL = 'http://localhost:$BACKEND_PORT'|" "$k6_script"
        # Purpose: Update BASE_URL in K6 script to use correct backend port
        # Why needed: K6 script needs to target the correct backend endpoint
        # Impact: K6 tests will connect to the port-forwarded backend service
        # Command: sed -i modifies file in-place with pattern replacement
        
        success "K6 script configured for backend URL: http://localhost:$BACKEND_PORT"
        # Purpose: Confirm K6 script configuration update
        # Why needed: User should know configuration was successful
        # Impact: Provides confidence in test configuration
    else
        warning "K6 script not found at $k6_script, using default configuration"
        # Purpose: Report missing K6 script file
        # Why needed: User should know about missing test script
        # Impact: Tests may not run or may use incorrect configuration
    fi
    
    # =============================================================================
    # EXECUTE K6 LOAD TEST
    # =============================================================================
    # Run K6 load test with JSON output for analysis.
    # =============================================================================
    
    log "Executing K6 load test with comprehensive scenarios..."
    # Purpose: Inform user that K6 execution is starting
    # Why needed: User should know about test execution
    # Impact: Sets expectation for test duration
    
    k6 run --out json="$RESULTS_DIR/k6-results.json" "$k6_script" | tee "$RESULTS_DIR/k6-output.log"
    # Purpose: Execute K6 load test with JSON output and console logging
    # Why needed: Provides both structured results and human-readable output
    # Impact: Creates JSON results file and console output log
    # Command: k6 run with JSON output, tee saves console output to file
    
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        # Purpose: Check if K6 command executed successfully
        # Why needed: Verifies test execution completed without errors
        # Impact: Provides feedback on test success
        # Variable: PIPESTATUS[0] contains exit code of first command in pipeline
        
        success "K6 load tests completed successfully"
        # Purpose: Confirm successful K6 test execution
        # Why needed: User should know tests completed successfully
        # Impact: Provides confidence in test results
        
        log "K6 results saved to: $RESULTS_DIR/k6-results.json"
        # Purpose: Inform user about results file location
        # Why needed: User needs to know where to find detailed results
        # Impact: Enables user to access and analyze test results
    else
        error "K6 load tests failed"
        # Purpose: Report K6 test execution failure
        # Why needed: User needs to know about test failures
        # Impact: Indicates problems with test execution or configuration
    fi
}

run_ab_tests() {
    # =============================================================================
    # RUN APACHE BENCH TESTS FUNCTION
    # =============================================================================
    # Executes Apache Bench HTTP performance tests for frontend and backend.
    # =============================================================================
    
    log "Running Apache Bench HTTP performance tests..."
    # Purpose: Inform user that Apache Bench testing is starting
    # Why needed: User should know about test execution progress
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # INSTALL APACHE BENCH IF NOT AVAILABLE
    # =============================================================================
    # Check for Apache Bench availability and install if missing.
    # =============================================================================
    
    if ! command -v ab &> /dev/null; then
        # Purpose: Check if Apache Bench command is available
        # Why needed: Apache Bench is required for HTTP performance testing
        # Impact: Automatic installation if tool is missing
        
        log "Apache Bench not found, installing apache2-utils package..."
        # Purpose: Inform user about Apache Bench installation
        # Why needed: User should know about automatic tool installation
        # Impact: Provides transparency about system modifications
        
        sudo apt-get update && sudo apt-get install -y apache2-utils
        # Purpose: Install Apache Bench via package manager
        # Why needed: Provides the 'ab' command for HTTP testing
        # Impact: Apache Bench becomes available for testing
        # Command: apt-get update refreshes package list, install adds apache2-utils
        
        if command -v ab &> /dev/null; then
            # Purpose: Verify Apache Bench installation was successful
            # Why needed: Confirms installation completed properly
            # Impact: Provides feedback on installation success
            
            success "Apache Bench installed successfully"
            # Purpose: Confirm successful Apache Bench installation
            # Why needed: User needs confirmation of successful installation
            # Impact: User knows Apache Bench is ready for use
        else
            error "Failed to install Apache Bench"
            # Purpose: Report Apache Bench installation failure
            # Why needed: User needs to know about installation problems
            # Impact: HTTP testing cannot proceed without Apache Bench
            
            return 1
            # Purpose: Return error code from function
            # Why needed: Indicates function failure to calling code
            # Impact: Allows main script to handle installation failure
        fi
    else
        success "Apache Bench found: $(ab -V 2>&1 | head -1)"
        # Purpose: Confirm Apache Bench availability and show version
        # Why needed: User should know existing tools are detected
        # Impact: Shows Apache Bench version for reference
    fi
    
    # =============================================================================
    # TEST FRONTEND PERFORMANCE
    # =============================================================================
    # Execute Apache Bench test against frontend service.
    # =============================================================================
    
    log "Testing frontend performance with Apache Bench..."
    # Purpose: Inform user about frontend testing
    # Why needed: User should know which component is being tested
    # Impact: Provides context for test execution
    
    ab -n 1000 -c 10 -g "$RESULTS_DIR/ab-frontend.tsv" "http://localhost:$FRONTEND_PORT/" > "$RESULTS_DIR/ab-frontend.log" 2>&1
    # Purpose: Execute Apache Bench test against frontend
    # Why needed: Measures frontend HTTP performance characteristics
    # Impact: Creates performance data and detailed log file
    # Parameters: -n 1000 requests, -c 10 concurrent, -g TSV output file
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if Apache Bench frontend test succeeded
        # Why needed: Verifies test execution completed successfully
        # Impact: Provides feedback on test success
        
        success "Frontend Apache Bench test completed"
        # Purpose: Confirm successful frontend test execution
        # Why needed: User should know frontend testing completed
        # Impact: Provides confidence in frontend test results
        
        log "Frontend results saved to: $RESULTS_DIR/ab-frontend.log"
        # Purpose: Inform user about frontend results file location
        # Why needed: User needs to know where to find detailed results
        # Impact: Enables user to access and analyze frontend test results
    else
        error "Frontend Apache Bench test failed"
        # Purpose: Report frontend test execution failure
        # Why needed: User needs to know about test failures
        # Impact: Indicates problems with frontend service or connectivity
    fi
    
    # =============================================================================
    # TEST BACKEND API PERFORMANCE
    # =============================================================================
    # Execute Apache Bench test against backend API health endpoint.
    # =============================================================================
    
    log "Testing backend API performance with Apache Bench..."
    # Purpose: Inform user about backend testing
    # Why needed: User should know which component is being tested
    # Impact: Provides context for test execution
    
    ab -n 1000 -c 10 -g "$RESULTS_DIR/ab-backend.tsv" "http://localhost:$BACKEND_PORT/health" > "$RESULTS_DIR/ab-backend.log" 2>&1
    # Purpose: Execute Apache Bench test against backend API
    # Why needed: Measures backend API performance characteristics
    # Impact: Creates performance data and detailed log file
    # Endpoint: /health is lightweight endpoint suitable for performance testing
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if Apache Bench backend test succeeded
        # Why needed: Verifies test execution completed successfully
        # Impact: Provides feedback on test success
        
        success "Backend Apache Bench test completed"
        # Purpose: Confirm successful backend test execution
        # Why needed: User should know backend testing completed
        # Impact: Provides confidence in backend test results
        
        log "Backend results saved to: $RESULTS_DIR/ab-backend.log"
        # Purpose: Inform user about backend results file location
        # Why needed: User needs to know where to find detailed results
        # Impact: Enables user to access and analyze backend test results
    else
        error "Backend Apache Bench test failed"
        # Purpose: Report backend test execution failure
        # Why needed: User needs to know about test failures
        # Impact: Indicates problems with backend service or connectivity
    fi
}

monitor_resources() {
    # =============================================================================
    # MONITOR RESOURCES FUNCTION
    # =============================================================================
    # Monitors Kubernetes cluster resource utilization during performance tests.
    # =============================================================================
    
    log "Starting resource utilization monitoring for $TEST_DURATION seconds..."
    # Purpose: Inform user about resource monitoring start
    # Why needed: User should know monitoring is active
    # Impact: Sets expectation for monitoring duration
    
    # =============================================================================
    # START BACKGROUND RESOURCE MONITORING
    # =============================================================================
    # Launch resource monitoring in background process.
    # =============================================================================
    
    timeout "$TEST_DURATION" bash -c "
        # =============================================================================
        # RESOURCE MONITORING LOOP
        # =============================================================================
        # Continuous monitoring loop that runs for specified duration.
        # =============================================================================
        
        while true; do
            # =============================================================================
            # LOG MONITORING TIMESTAMP
            # =============================================================================
            # Add timestamp header for each monitoring cycle.
            # =============================================================================
            
            echo \"=== \$(date) ===\" >> \"$RESULTS_DIR/resource-usage.log\"
            # Purpose: Add timestamp header to resource log
            # Why needed: Provides time context for resource measurements
            # Impact: Enables correlation of resource usage with test phases
            
            # =============================================================================
            # MONITOR NODE RESOURCE USAGE
            # =============================================================================
            # Collect cluster node resource utilization metrics.
            # =============================================================================
            
            kubectl top nodes >> \"$RESULTS_DIR/resource-usage.log\" 2>&1 || echo \"Node metrics unavailable\" >> \"$RESULTS_DIR/resource-usage.log\"
            # Purpose: Collect node-level CPU and memory usage
            # Why needed: Provides cluster-wide resource utilization view
            # Impact: Shows overall cluster resource consumption
            # Fallback: Error message if metrics server is unavailable
            
            # =============================================================================
            # MONITOR POD RESOURCE USAGE
            # =============================================================================
            # Collect pod-level resource utilization in target namespace.
            # =============================================================================
            
            kubectl top pods -n \"$NAMESPACE\" >> \"$RESULTS_DIR/resource-usage.log\" 2>&1 || echo \"Pod metrics unavailable\" >> \"$RESULTS_DIR/resource-usage.log\"
            # Purpose: Collect pod-level CPU and memory usage
            # Why needed: Provides application-specific resource utilization
            # Impact: Shows resource consumption of e-commerce components
            # Scope: Limited to target namespace for relevant metrics
            
            echo \"\" >> \"$RESULTS_DIR/resource-usage.log\"
            # Purpose: Add blank line for readability
            # Why needed: Separates monitoring cycles in log file
            # Impact: Improves log file readability and parsing
            
            sleep 30
            # Purpose: Wait 30 seconds between monitoring cycles
            # Why needed: Provides reasonable monitoring frequency
            # Impact: Balances monitoring detail with log file size
        done
    " &
    # Purpose: Run monitoring loop in background with timeout
    # Why needed: Allows monitoring to run parallel with performance tests
    # Impact: Resource monitoring runs for specified duration then stops
    
    MONITOR_PID=$!
    # Purpose: Capture process ID of monitoring process
    # Why needed: Allows cleanup of monitoring process if needed
    # Impact: Enables targeted process management
    
    success "Resource monitoring started (PID: $MONITOR_PID) for $TEST_DURATION seconds"
    # Purpose: Confirm resource monitoring startup
    # Why needed: User should know monitoring is active
    # Impact: Provides confidence in resource data collection
}

# =============================================================================
# REPORT GENERATION FUNCTIONS
# =============================================================================
# Functions to generate comprehensive performance reports from test results.
# =============================================================================

generate_report() {
    # =============================================================================
    # GENERATE PERFORMANCE REPORT FUNCTION
    # =============================================================================
    # Creates comprehensive performance report with analysis and recommendations.
    # =============================================================================
    
    log "Generating comprehensive performance report..."
    # Purpose: Inform user that report generation is starting
    # Why needed: User should know about report creation progress
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # EXTRACT PERFORMANCE METRICS FROM TEST RESULTS
    # =============================================================================
    # Parse test result files to extract key performance metrics.
    # =============================================================================
    
    local frontend_avg_time="N/A"
    # Purpose: Initialize frontend average response time variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    local backend_avg_time="N/A"
    # Purpose: Initialize backend average response time variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    local frontend_rps="N/A"
    # Purpose: Initialize frontend requests per second variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    local backend_rps="N/A"
    # Purpose: Initialize backend requests per second variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    local frontend_errors="N/A"
    # Purpose: Initialize frontend error count variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    local backend_errors="N/A"
    # Purpose: Initialize backend error count variable
    # Why needed: Provides default value if metric extraction fails
    # Impact: Report will show N/A if data is unavailable
    
    # =============================================================================
    # EXTRACT FRONTEND METRICS FROM APACHE BENCH RESULTS
    # =============================================================================
    # Parse frontend Apache Bench log file for performance metrics.
    # =============================================================================
    
    if [[ -f "$RESULTS_DIR/ab-frontend.log" ]]; then
        # Purpose: Check if frontend Apache Bench results file exists
        # Why needed: Prevents errors when parsing non-existent files
        # Impact: Only extracts metrics if results are available
        
        frontend_avg_time=$(grep "Time per request" "$RESULTS_DIR/ab-frontend.log" | head -1 | awk '{print $4}' 2>/dev/null || echo "N/A")
        # Purpose: Extract average response time from Apache Bench results
        # Why needed: Provides key performance metric for frontend
        # Impact: Shows frontend response time performance in report
        # Command: grep finds line, head gets first match, awk extracts 4th field
        
        frontend_rps=$(grep "Requests per second" "$RESULTS_DIR/ab-frontend.log" | awk '{print $4}' 2>/dev/null || echo "N/A")
        # Purpose: Extract requests per second from Apache Bench results
        # Why needed: Provides throughput metric for frontend
        # Impact: Shows frontend throughput performance in report
        
        frontend_errors=$(grep "Failed requests" "$RESULTS_DIR/ab-frontend.log" | awk '{print $3}' 2>/dev/null || echo "N/A")
        # Purpose: Extract failed request count from Apache Bench results
        # Why needed: Provides error rate metric for frontend
        # Impact: Shows frontend reliability in report
    fi
    
    # =============================================================================
    # EXTRACT BACKEND METRICS FROM APACHE BENCH RESULTS
    # =============================================================================
    # Parse backend Apache Bench log file for performance metrics.
    # =============================================================================
    
    if [[ -f "$RESULTS_DIR/ab-backend.log" ]]; then
        # Purpose: Check if backend Apache Bench results file exists
        # Why needed: Prevents errors when parsing non-existent files
        # Impact: Only extracts metrics if results are available
        
        backend_avg_time=$(grep "Time per request" "$RESULTS_DIR/ab-backend.log" | head -1 | awk '{print $4}' 2>/dev/null || echo "N/A")
        # Purpose: Extract average response time from backend Apache Bench results
        # Why needed: Provides key performance metric for backend
        # Impact: Shows backend response time performance in report
        
        backend_rps=$(grep "Requests per second" "$RESULTS_DIR/ab-backend.log" | awk '{print $4}' 2>/dev/null || echo "N/A")
        # Purpose: Extract requests per second from backend Apache Bench results
        # Why needed: Provides throughput metric for backend
        # Impact: Shows backend throughput performance in report
        
        backend_errors=$(grep "Failed requests" "$RESULTS_DIR/ab-backend.log" | awk '{print $3}' 2>/dev/null || echo "N/A")
        # Purpose: Extract failed request count from backend Apache Bench results
        # Why needed: Provides error rate metric for backend
        # Impact: Shows backend reliability in report
    fi
    
    # =============================================================================
    # GENERATE COMPREHENSIVE PERFORMANCE REPORT
    # =============================================================================
    # Create detailed markdown report with all performance metrics and analysis.
    # =============================================================================
    
    cat > "$RESULTS_DIR/performance-report.md" << EOF
# Performance Benchmark Report
## E-commerce Foundation Infrastructure

**Test Date**: $(date)
**Test Duration**: Performance testing with resource monitoring
**Target Namespace**: $NAMESPACE
**Results Directory**: $RESULTS_DIR

---

## Executive Summary

This report provides comprehensive performance analysis of the e-commerce foundation infrastructure, including load testing results, HTTP performance metrics, and resource utilization patterns.

---

## Test Configuration

### Test Environment
- **Frontend Service**: $FRONTEND_SERVICE (Port: $FRONTEND_PORT)
- **Backend Service**: $BACKEND_SERVICE (Port: $BACKEND_PORT)
- **Kubernetes Namespace**: $NAMESPACE
- **Monitoring Duration**: $TEST_DURATION seconds

### Test Tools Used
- **K6 Load Testing**: Comprehensive application workflow testing
- **Apache Bench**: HTTP server performance testing
- **Kubernetes Metrics**: Resource utilization monitoring

---

## Performance Test Results

### K6 Load Test Results
- **Test Configuration**: Multi-stage load testing with realistic user scenarios
- **Results File**: k6-results.json
- **Execution Log**: k6-output.log
- **Test Scenarios**: Homepage, Product API, Authentication, Shopping Cart

### Apache Bench HTTP Performance Results

#### Frontend Performance
- **Average Response Time**: $frontend_avg_time ms
- **Requests Per Second**: $frontend_rps RPS
- **Failed Requests**: $frontend_errors
- **Test Configuration**: 1000 requests, 10 concurrent connections
- **Detailed Results**: ab-frontend.log

#### Backend API Performance
- **Average Response Time**: $backend_avg_time ms
- **Requests Per Second**: $backend_rps RPS
- **Failed Requests**: $backend_errors
- **Test Configuration**: 1000 requests, 10 concurrent connections
- **Detailed Results**: ab-backend.log

---

## Resource Utilization Analysis

### Monitoring Data
- **Resource Usage Log**: resource-usage.log
- **Monitoring Duration**: $TEST_DURATION seconds
- **Monitoring Frequency**: Every 30 seconds
- **Scope**: Cluster nodes and namespace pods

### Key Metrics Tracked
- **Node CPU and Memory Usage**: Cluster-wide resource consumption
- **Pod CPU and Memory Usage**: Application-specific resource utilization
- **Resource Trends**: Usage patterns during performance testing

---

## Performance Analysis

### Response Time Analysis
- **Frontend Response Time**: $frontend_avg_time ms
  - Target: < 200ms for optimal user experience
  - Status: $(if [[ "$frontend_avg_time" != "N/A" && $(echo "$frontend_avg_time < 200" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

- **Backend Response Time**: $backend_avg_time ms
  - Target: < 300ms for API endpoints
  - Status: $(if [[ "$backend_avg_time" != "N/A" && $(echo "$backend_avg_time < 300" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

### Throughput Analysis
- **Frontend Throughput**: $frontend_rps RPS
  - Target: > 100 RPS for adequate capacity
  - Status: $(if [[ "$frontend_rps" != "N/A" && $(echo "$frontend_rps > 100" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

- **Backend Throughput**: $backend_rps RPS
  - Target: > 200 RPS for API capacity
  - Status: $(if [[ "$backend_rps" != "N/A" && $(echo "$backend_rps > 200" | bc -l 2>/dev/null || echo 0) -eq 1 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

### Error Rate Analysis
- **Frontend Errors**: $frontend_errors failed requests
  - Target: < 1% error rate (< 10 failures out of 1000 requests)
  - Status: $(if [[ "$frontend_errors" != "N/A" && "$frontend_errors" -lt 10 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

- **Backend Errors**: $backend_errors failed requests
  - Target: < 1% error rate (< 10 failures out of 1000 requests)
  - Status: $(if [[ "$backend_errors" != "N/A" && "$backend_errors" -lt 10 ]]; then echo "✅ Within target"; else echo "⚠️ Review required"; fi)

---

## Recommendations

### Performance Optimization
1. **Response Time Optimization**: Review slow endpoints and optimize database queries
2. **Throughput Enhancement**: Consider horizontal scaling if throughput is below targets
3. **Error Investigation**: Investigate any failed requests for root cause analysis
4. **Resource Optimization**: Analyze resource usage patterns for scaling decisions

### Infrastructure Improvements
1. **Resource Scaling**: Adjust CPU/memory limits based on observed usage patterns
2. **Load Balancing**: Implement proper load balancing for high availability
3. **Caching Strategy**: Consider implementing caching for frequently accessed data
4. **Database Optimization**: Review database performance and indexing strategies

### Monitoring Enhancements
1. **Continuous Monitoring**: Implement ongoing performance monitoring
2. **Alerting Setup**: Configure alerts for performance threshold violations
3. **Capacity Planning**: Use performance data for future capacity planning
4. **Regular Testing**: Schedule regular performance testing to detect regressions

---

## Test Artifacts

### Generated Files
- **Performance Report**: performance-report.md (this file)
- **K6 Results**: k6-results.json (structured load test results)
- **K6 Execution Log**: k6-output.log (detailed test execution log)
- **Frontend AB Results**: ab-frontend.log (Apache Bench frontend results)
- **Backend AB Results**: ab-backend.log (Apache Bench backend results)
- **Frontend Timing Data**: ab-frontend.tsv (detailed timing data)
- **Backend Timing Data**: ab-backend.tsv (detailed timing data)
- **Resource Usage Log**: resource-usage.log (resource monitoring data)

### Analysis Tools
- **K6 JSON Analysis**: Use jq to analyze k6-results.json for detailed metrics
- **Apache Bench Analysis**: Review .log files for detailed performance statistics
- **Resource Analysis**: Parse resource-usage.log for utilization trends

---

## Next Steps

1. **Review Results**: Analyze all generated test artifacts for detailed insights
2. **Address Issues**: Investigate and resolve any performance issues identified
3. **Optimize Configuration**: Adjust resource limits and scaling based on results
4. **Schedule Regular Testing**: Implement regular performance testing schedule
5. **Monitor Production**: Apply learnings to production monitoring and alerting

---

**Report Generated**: $(date)
**Test Environment**: Kubernetes cluster with e-commerce foundation infrastructure
**Report Location**: $RESULTS_DIR/performance-report.md
EOF

    success "Comprehensive performance report generated: $RESULTS_DIR/performance-report.md"
    # Purpose: Confirm successful report generation
    # Why needed: User should know report creation completed
    # Impact: Provides location of comprehensive performance analysis
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================
# Main function that orchestrates the complete performance benchmarking process.
# =============================================================================

main() {
    # =============================================================================
    # MAIN FUNCTION
    # =============================================================================
    # Orchestrates complete performance benchmarking workflow with proper cleanup.
    # =============================================================================
    
    log "Starting comprehensive performance benchmarking suite..."
    # Purpose: Inform user that benchmarking process is beginning
    # Why needed: User should know the complete process is starting
    # Impact: Sets expectation for full benchmarking workflow
    
    echo ""
    log "Performance benchmarking will include:"
    log "  - Prerequisites validation"
    log "  - Port forwarding setup"
    log "  - K6 load testing"
    log "  - Apache Bench HTTP testing"
    log "  - Resource utilization monitoring"
    log "  - Comprehensive report generation"
    echo ""
    # Purpose: Inform user about all benchmarking components
    # Why needed: User should understand the complete scope of testing
    # Impact: Sets clear expectations for the benchmarking process
    
    # =============================================================================
    # SETUP CLEANUP TRAP
    # =============================================================================
    # Ensure port forwarding cleanup happens even if script exits unexpectedly.
    # =============================================================================
    
    trap cleanup_port_forwarding EXIT
    # Purpose: Register cleanup function to run on script exit
    # Why needed: Ensures port forwarding is cleaned up even on unexpected exit
    # Impact: Prevents leftover port forwarding processes
    # Signal: EXIT trap runs on normal exit, SIGINT, SIGTERM
    
    # =============================================================================
    # EXECUTE BENCHMARKING WORKFLOW
    # =============================================================================
    # Run all benchmarking components in proper sequence.
    # =============================================================================
    
    check_prerequisites
    # Purpose: Validate all required tools and services are available
    # Why needed: Ensures benchmarking can proceed successfully
    # Impact: Prevents failures due to missing dependencies
    
    setup_port_forwarding
    # Purpose: Establish network connections to Kubernetes services
    # Why needed: Enables local access to services for testing
    # Impact: Services become accessible for performance testing
    
    monitor_resources
    # Purpose: Start background resource monitoring
    # Why needed: Collects resource utilization data during tests
    # Impact: Provides resource usage context for performance analysis
    
    # =============================================================================
    # EXECUTE PERFORMANCE TESTS
    # =============================================================================
    # Run all performance testing tools in sequence.
    # =============================================================================
    
    run_k6_tests
    # Purpose: Execute comprehensive load testing scenarios
    # Why needed: Provides realistic application performance testing
    # Impact: Generates detailed load testing results and metrics
    
    run_ab_tests
    # Purpose: Execute HTTP server performance testing
    # Why needed: Provides HTTP-specific performance metrics
    # Impact: Generates server performance data for analysis
    
    # =============================================================================
    # FINALIZE BENCHMARKING PROCESS
    # =============================================================================
    # Complete monitoring and generate final report.
    # =============================================================================
    
    # Stop resource monitoring if still running
    if [[ -n "${MONITOR_PID:-}" ]]; then
        # Purpose: Check if monitoring process is still running
        # Why needed: Ensures monitoring process is properly terminated
        # Impact: Prevents orphaned monitoring processes
        
        kill "$MONITOR_PID" 2>/dev/null || true
        # Purpose: Terminate resource monitoring process
        # Why needed: Stops background monitoring after tests complete
        # Impact: Cleans up monitoring process resources
        
        log "Resource monitoring stopped"
        # Purpose: Confirm monitoring process termination
        # Why needed: User should know monitoring has stopped
        # Impact: Provides feedback on process cleanup
    fi
    
    generate_report
    # Purpose: Create comprehensive performance analysis report
    # Why needed: Provides actionable insights from all test results
    # Impact: Generates detailed performance report with recommendations
    
    # =============================================================================
    # DISPLAY COMPLETION SUMMARY
    # =============================================================================
    # Provide final summary and next steps for user.
    # =============================================================================
    
    echo ""
    echo "=================================================================="
    echo "           PERFORMANCE BENCHMARKING COMPLETED"
    echo "=================================================================="
    echo ""
    success "Performance benchmarking suite completed successfully!"
    echo ""
    log "Results and analysis available in: $RESULTS_DIR"
    echo ""
    log "Generated files:"
    log "  📊 Performance Report: $RESULTS_DIR/performance-report.md"
    log "  📈 K6 Results: $RESULTS_DIR/k6-results.json"
    log "  📋 K6 Execution Log: $RESULTS_DIR/k6-output.log"
    log "  🌐 Frontend AB Results: $RESULTS_DIR/ab-frontend.log"
    log "  ⚙️  Backend AB Results: $RESULTS_DIR/ab-backend.log"
    log "  📊 Resource Usage: $RESULTS_DIR/resource-usage.log"
    echo ""
    log "Next steps:"
    log "  1. Review the comprehensive performance report"
    log "  2. Analyze detailed test results for optimization opportunities"
    log "  3. Implement recommended performance improvements"
    log "  4. Schedule regular performance testing"
    echo ""
    echo "=================================================================="
    # Purpose: Provide comprehensive completion summary
    # Why needed: User should know what was accomplished and next steps
    # Impact: Provides clear guidance on using the results
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
# Execute main function with all command line arguments.
# =============================================================================

main "$@"
# Purpose: Execute main function with all script arguments
# Why needed: Starts the complete benchmarking process
# Impact: Runs the entire performance benchmarking suite
# Arguments: "$@" passes all command line arguments to main function
