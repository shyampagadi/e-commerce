#!/bin/bash
# =============================================================================
# COMPREHENSIVE TEST SUITE RUNNER
# =============================================================================
# This script orchestrates all validation and testing activities for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# validation, health checks, performance testing, and comprehensive reporting.
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
# TEST SUITE CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent test suite configuration throughout the script.
# =============================================================================

NAMESPACE="${1:-ecommerce}"
# Purpose: Specifies the Kubernetes namespace for test execution
# Why needed: Provides consistent namespace reference for all test activities
# Impact: All tests target resources in this namespace
# Value: Defaults to 'ecommerce', accepts any valid namespace name

TEST_TYPE="all"
# Purpose: Specifies the type of tests to execute
# Why needed: Controls which test suites are run
# Impact: Determines the scope and duration of testing
# Value: Options: 'all', 'validation', 'health', 'performance'

VERBOSE=false
# Purpose: Enables verbose output mode for detailed test information
# Why needed: Provides detailed information for troubleshooting and monitoring
# Impact: When true, shows detailed test progress and results
# Usage: Set via --verbose command line argument

PARALLEL=false
# Purpose: Enables parallel execution of test suites
# Why needed: Reduces total test execution time
# Impact: When true, multiple test suites run simultaneously
# Usage: Set via --parallel command line argument

OUTPUT_DIR="./test-results"
# Purpose: Specifies the directory for test result storage
# Why needed: Provides consistent location for test output and reports
# Impact: All test results are stored in this directory
# Value: Defaults to './test-results', can be overridden

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
# Purpose: Generates unique timestamp for test run identification
# Why needed: Provides unique identification for each test run
# Impact: Used for result file naming and test run tracking
# Value: Format: YYYYMMDD_HHMMSS (e.g., 20241215_143022)

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --type=*)
            TEST_TYPE="${arg#*=}"
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --output-dir=*)
            OUTPUT_DIR="${arg#*=}"
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

# Test results
declare -A TEST_RESULTS
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Provides consistent colored output with timestamp for test execution.
    # Provides visual distinction and consistent formatting for test results.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps
    # Why needed: Provides visual feedback and consistent logging for test execution
    # Impact: Users can easily identify message types and test progress is logged
    # Parameters:
    #   $1: Status type (INFO, SUCCESS, WARNING, ERROR, HEADER)
    #   $2: Message to display
    # Usage: print_status "SUCCESS" "Test completed successfully"
    
    local status=$1
    # Purpose: Specifies the type of status message
    # Why needed: Determines color and formatting for the message
    # Impact: Different status types get different colors for easy identification
    # Parameter: $1 is the status type (INFO, SUCCESS, WARNING, ERROR, HEADER)
    
    local message=$2
    # Purpose: Contains the message text to display
    # Why needed: Provides the actual message content
    # Impact: Users see the specific message about the test
    # Parameter: $2 is the message text to display
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generates current timestamp for message identification
    # Why needed: Provides temporal context for test operations
    # Impact: All messages include timestamp for chronological tracking
    # Format: YYYY-MM-DD HH:MM:SS (e.g., 2024-12-15 14:30:22)
    
    case $status in
        "INFO")
            # Purpose: Displays informational messages in blue color
            # Why needed: Provides neutral information about test progress
            # Impact: Users see informational messages in blue
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            ;;
        "SUCCESS")
            # Purpose: Displays success messages in green color
            # Why needed: Confirms successful test execution
            # Impact: Users see success messages in green
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            ;;
        "WARNING")
            # Purpose: Displays warning messages in yellow color
            # Why needed: Alerts users to potential issues without failing tests
            # Impact: Users see warning messages in yellow
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            ;;
        "ERROR")
            # Purpose: Displays error messages in red color
            # Why needed: Reports test failures and errors
            # Impact: Users see error messages in red
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            ;;
        "HEADER")
            # Purpose: Displays header messages in purple color
            # Why needed: Provides section headers for test organization
            # Impact: Users see header messages in purple
            echo -e "${PURPLE}[HEADER]${NC} [${timestamp}] ${message}"
            ;;
    esac
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Checks if a specified command is available in the system PATH.
    # Provides prerequisite validation for test execution.
    # =============================================================================
    
    # Purpose: Check if a command is available in the system
    # Why needed: Validates prerequisites before running tests
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

# Function: Create output directory
create_output_dir() {
    # =============================================================================
    # CREATE OUTPUT DIRECTORY FUNCTION
    # =============================================================================
    # Creates the output directory for test results if it doesn't exist.
    # Provides directory structure for test result storage.
    # =============================================================================
    
    # Purpose: Create output directory for test results
    # Why needed: Ensures output directory exists for test result storage
    # Impact: Test results can be saved to the specified directory
    # Parameters: None (uses global OUTPUT_DIR variable)
    # Usage: create_output_dir
    # Returns: 0 if directory exists or created, 1 if creation fails
    
    if [ ! -d "$OUTPUT_DIR" ]; then
        # Purpose: Check if output directory exists
        # Why needed: Ensures directory exists before creating
        # Impact: Proceeds with creation if directory doesn't exist
        # [ ! -d "$OUTPUT_DIR" ]: Check if directory doesn't exist
        
        mkdir -p "$OUTPUT_DIR"
        # Purpose: Create output directory with parent directories
        # Why needed: Creates the directory structure for test results
        # Impact: Output directory is created
        # mkdir -p: Create directory and parent directories
        # "$OUTPUT_DIR": Directory path to create
        
        print_status "INFO" "Created output directory: $OUTPUT_DIR"
        # Purpose: Log directory creation
        # Why needed: Informs user that output directory was created
        # Impact: User knows output directory was created
    fi
}

# Function: Run test and capture results
run_test() {
    # =============================================================================
    # RUN TEST FUNCTION
    # =============================================================================
    # Executes a test script and captures results with timing and logging.
    # Provides comprehensive test execution with result tracking.
    # =============================================================================
    
    # Purpose: Execute a test script and capture results
    # Why needed: Provides test execution with result tracking and logging
    # Impact: Tests are executed with comprehensive result capture
    # Parameters:
    #   $1: Test name for identification
    #   $2: Test script path to execute
    #   $3+: Additional arguments for the test script
    # Usage: run_test "health-check" "./health-check.sh" "--verbose"
    # Returns: Exit code of the test script
    
    local test_name=$1
    # Purpose: Specifies the test name for identification
    # Why needed: Provides unique identifier for test results
    # Impact: Test results are tracked by name
    # Parameter: $1 is the test name
    
    local test_script=$2
    # Purpose: Specifies the test script path to execute
    # Why needed: Identifies which script to run for the test
    # Impact: Function executes the specified script
    # Parameter: $2 is the test script path
    
    local test_args=("${@:3}")
    # Purpose: Captures additional arguments for the test script
    # Why needed: Provides arguments to pass to the test script
    # Impact: Test script receives additional arguments
    # Parameter: $3+ are additional arguments
    # "${@:3}": All arguments from position 3 onwards
    
    print_status "HEADER" "Running ${test_name} test"
    # Purpose: Log the start of test execution
    # Why needed: Informs user that test execution has begun
    # Impact: User knows test execution has started
    
    local start_time
    # Purpose: Variable to store test start time
    # Why needed: Provides reference point for timing calculation
    # Impact: Enables test duration calculation
    
    start_time=$(date +%s)
    # Purpose: Record the start time for timing calculation
    # Why needed: Provides reference point for test duration
    # Impact: Enables test duration calculation
    # date +%s: Get current time in seconds since epoch
    
    local test_output
    # Purpose: Variable to store test script output
    # Why needed: Captures test script output for logging
    # Impact: Will contain the test script output
    
    local test_exit_code
    # Purpose: Variable to store test script exit code
    # Why needed: Captures test script exit code for result tracking
    # Impact: Will contain the test script exit code
    
    if [ "$VERBOSE" = true ]; then
        # Purpose: Check if verbose mode is enabled
        # Why needed: Provides detailed execution information when requested
        # Impact: Proceeds with verbose logging if enabled
        
        print_status "INFO" "Executing: ${test_script} ${test_args[*]}"
        # Purpose: Log detailed test execution command
        # Why needed: Provides visibility into test execution details
        # Impact: User sees the exact command being executed
    fi
    
    # =============================================================================
    # EXECUTE TEST SCRIPT
    # =============================================================================
    # Purpose: Run the test script and capture output
    # Why needed: Executes the test and captures results
    
    if test_output=$(bash "$test_script" "${test_args[@]}" 2>&1); then
        # Purpose: Execute test script and capture output
        # Why needed: Runs the test script and captures results
        # Impact: Test script is executed and output is captured
        # bash "$test_script": Execute the test script
        # "${test_args[@]}": Pass all test arguments
        # 2>&1: Redirect stderr to stdout
        # test_output=: Capture output in variable
        
        test_exit_code=0
        # Purpose: Set exit code for successful test
        # Why needed: Indicates test execution was successful
        # Impact: Test result is marked as successful
        
        TEST_RESULTS["$test_name"]="PASS"
        # Purpose: Record test result as passed
        # Why needed: Tracks test results for reporting
        # Impact: Test result is recorded as passed
        
        ((PASSED_TESTS++))
        # Purpose: Increment passed tests counter
        # Why needed: Tracks number of passed tests
        # Impact: Passed tests counter increases
        
        print_status "SUCCESS" "${test_name} test passed"
        # Purpose: Log successful test completion
        # Why needed: Confirms test execution was successful
        # Impact: User knows test passed
    else
        # Purpose: Handle test execution failure
        # Why needed: Provides error handling for failed tests
        # Impact: Logs error message for test failure
        
        test_exit_code=$?
        # Purpose: Capture test script exit code
        # Why needed: Provides exit code for failed test
        # Impact: Test exit code is captured
        
        TEST_RESULTS["$test_name"]="FAIL"
        # Purpose: Record test result as failed
        # Why needed: Tracks test results for reporting
        # Impact: Test result is recorded as failed
        
        ((FAILED_TESTS++))
        # Purpose: Increment failed tests counter
        # Why needed: Tracks number of failed tests
        # Impact: Failed tests counter increases
        
        print_status "ERROR" "${test_name} test failed with exit code: $test_exit_code"
        # Purpose: Log test failure with exit code
        # Why needed: Informs user that test failed
        # Impact: User knows test failed and why
    fi
    
    local end_time
    # Purpose: Variable to store test end time
    # Why needed: Provides reference point for timing calculation
    # Impact: Enables test duration calculation
    
    end_time=$(date +%s)
    # Purpose: Record the end time for timing calculation
    # Why needed: Provides reference point for test duration
    # Impact: Enables test duration calculation
    # date +%s: Get current time in seconds since epoch
    
    local duration=$((end_time - start_time))
    # Purpose: Calculate test execution duration
    # Why needed: Provides timing information for test execution
    # Impact: Test duration is calculated
    # $((end_time - start_time)): Calculate duration in seconds
    
    # =============================================================================
    # SAVE TEST OUTPUT
    # =============================================================================
    # Purpose: Save test output to file for later analysis
    # Why needed: Provides persistent storage of test results
    
    echo "$test_output" > "${OUTPUT_DIR}/${test_name}_${TIMESTAMP}.log"
    # Purpose: Save test output to log file
    # Why needed: Provides persistent storage of test results
    # Impact: Test output is saved to file
    # echo "$test_output": Output test results
    # > "${OUTPUT_DIR}/${test_name}_${TIMESTAMP}.log": Redirect to log file
    
    print_status "INFO" "${test_name} test completed in ${duration} seconds"
    # Purpose: Log test completion with duration
    # Why needed: Provides timing information for test execution
    # Impact: User knows test completed and how long it took
    
    ((TOTAL_TESTS++))
    # Purpose: Increment total tests counter
    # Why needed: Tracks total number of tests executed
    # Impact: Total tests counter increases
    
    return $test_exit_code
    # Purpose: Return test script exit code
    # Why needed: Provides exit code for test execution
    # Impact: Function returns test script exit code
}

# Function: Run tests in parallel
run_parallel_tests() {
    # =============================================================================
    # RUN PARALLEL TESTS FUNCTION
    # =============================================================================
    # Executes multiple tests in parallel for improved performance.
    # Provides concurrent test execution with process management.
    # =============================================================================
    
    # Purpose: Execute multiple tests in parallel
    # Why needed: Improves test execution performance by running tests concurrently
    # Impact: Tests are executed in parallel for faster completion
    # Parameters:
    #   $@: Array of test specifications in format "name:script:args"
    # Usage: run_parallel_tests "health:./health-check.sh:--verbose" "performance:./performance-test.sh"
    # Returns: None (waits for all tests to complete)
    
    local tests=("$@")
    # Purpose: Array of test specifications to execute
    # Why needed: Provides list of tests to run in parallel
    # Impact: Function executes all specified tests
    # Parameter: $@ is array of test specifications
    
    local pids=()
    # Purpose: Array to store process IDs of running tests
    # Why needed: Tracks running test processes for synchronization
    # Impact: Enables waiting for all tests to complete
    
    print_status "INFO" "Running ${#tests[@]} tests in parallel"
    # Purpose: Log the start of parallel test execution
    # Why needed: Informs user that parallel test execution has begun
    # Impact: User knows parallel test execution has started
    # ${#tests[@]}: Number of tests to run
    
    for test in "${tests[@]}"; do
        # Purpose: Loop through each test specification
        # Why needed: Processes each test specification for execution
        # Impact: Each test is prepared for parallel execution
        
        IFS=':' read -r test_name test_script test_args <<< "$test"
        # Purpose: Parse test specification into components
        # Why needed: Extracts test name, script, and arguments from specification
        # Impact: Test components are extracted for execution
        # IFS=':': Set field separator to colon
        # read -r: Read input with backslash escaping
        # test_name: Test name component
        # test_script: Test script path component
        # test_args: Test arguments component
        # <<< "$test": Use test specification as input
        
        run_test "$test_name" "$test_script" $test_args &
        # Purpose: Execute test in background
        # Why needed: Runs test in parallel with other tests
        # Impact: Test is executed in background process
        # run_test: Function to execute test
        # "$test_name": Test name
        # "$test_script": Test script path
        # $test_args: Test arguments
        # &: Run in background
        
        pids+=($!)
        # Purpose: Store process ID of background test
        # Why needed: Tracks running test process for synchronization
        # Impact: Process ID is added to tracking array
        # $!: Process ID of last background command
        # pids+=(): Add to pids array
    done
    
    # =============================================================================
    # WAIT FOR COMPLETION
    # =============================================================================
    # Purpose: Wait for all parallel tests to complete
    # Why needed: Ensures all tests finish before proceeding
    
    for pid in "${pids[@]}"; do
        # Purpose: Loop through each test process ID
        # Why needed: Waits for each test process to complete
        # Impact: Function waits for all tests to finish
        
        wait $pid
        # Purpose: Wait for specific test process to complete
        # Why needed: Ensures test process has finished
        # Impact: Function waits for test process completion
        # wait: Wait for process to complete
        # $pid: Process ID to wait for
    done
}

# Function: Generate test report
generate_report() {
    # =============================================================================
    # GENERATE TEST REPORT FUNCTION
    # =============================================================================
    # Generates an HTML test report with comprehensive test results and styling.
    # Provides visual test report with summary statistics and detailed results.
    # =============================================================================
    
    # Purpose: Generate HTML test report with comprehensive results
    # Why needed: Provides visual test report for analysis and documentation
    # Impact: Test results are presented in an organized HTML format
    # Parameters: None (uses global variables for test results)
    # Usage: generate_report
    # Returns: None (creates HTML file)
    
    local report_file="${OUTPUT_DIR}/test_report_${TIMESTAMP}.html"
    # Purpose: Specifies the output file path for the test report
    # Why needed: Provides file path for HTML report generation
    # Impact: Report is saved to the specified file
    # "${OUTPUT_DIR}/test_report_${TIMESTAMP}.html": Report file path with timestamp
    
    print_status "INFO" "Generating test report: $report_file"
    # Purpose: Log the start of report generation
    # Why needed: Informs user that report generation has begun
    # Impact: User knows report generation has started
    
    # =============================================================================
    # GENERATE HTML REPORT HEADER
    # =============================================================================
    # Purpose: Create HTML document structure with styling
    # Why needed: Provides professional appearance for test report
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>E-commerce Application Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { margin: 20px 0; }
        .test-results { margin: 20px 0; }
        .pass { color: green; }
        .fail { color: red; }
        .warning { color: orange; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>E-commerce Application Test Report</h1>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Namespace:</strong> $NAMESPACE</p>
        <p><strong>Test Type:</strong> $TEST_TYPE</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p><strong>Total Tests:</strong> $TOTAL_TESTS</p>
        <p class="pass"><strong>Passed:</strong> $PASSED_TESTS</p>
        <p class="fail"><strong>Failed:</strong> $FAILED_TESTS</p>
        <p><strong>Success Rate:</strong> $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%</p>
    </div>
    
    <div class="test-results">
        <h2>Test Results</h2>
        <table>
            <tr>
                <th>Test Name</th>
                <th>Status</th>
                <th>Log File</th>
            </tr>
EOF
    # Purpose: Generate HTML report header with styling and summary
    # Why needed: Creates professional HTML report structure
    # Impact: HTML report is created with styling and summary information
    # cat > "$report_file": Create HTML file
    # << EOF: Here document for HTML content
    # HTML structure: Document structure with CSS styling
    # Header section: Report title and metadata
    # Summary section: Test statistics and success rate
    # Table header: Test results table structure
    
    # =============================================================================
    # GENERATE TEST RESULTS TABLE
    # =============================================================================
    # Purpose: Add individual test results to the HTML report
    # Why needed: Provides detailed test results in tabular format
    
    for test_name in "${!TEST_RESULTS[@]}"; do
        # Purpose: Loop through each test result
        # Why needed: Processes each test result for report generation
        # Impact: Each test result is added to the report
        # "${!TEST_RESULTS[@]}": Array of test names
        
        local status="${TEST_RESULTS[$test_name]}"
        # Purpose: Get test status from results array
        # Why needed: Provides test status for report generation
        # Impact: Test status is retrieved for display
        # "${TEST_RESULTS[$test_name]}": Test status value
        
        local status_class
        # Purpose: Variable to store CSS class for status styling
        # Why needed: Provides appropriate styling for test status
        # Impact: Test status gets appropriate color styling
        
        case $status in
            "PASS")
                # Purpose: Handle passed test status
                # Why needed: Provides green styling for passed tests
                # Impact: Passed tests are displayed in green
                status_class="pass"
                ;;
            "FAIL")
                # Purpose: Handle failed test status
                # Why needed: Provides red styling for failed tests
                # Impact: Failed tests are displayed in red
                status_class="fail"
                ;;
            *)
                # Purpose: Handle other test statuses
                # Why needed: Provides orange styling for other statuses
                # Impact: Other statuses are displayed in orange
                status_class="warning"
                ;;
        esac
        
        cat >> "$report_file" << EOF
            <tr>
                <td>$test_name</td>
                <td class="$status_class">$status</td>
                <td><a href="${test_name}_${TIMESTAMP}.log">View Log</a></td>
            </tr>
EOF
        # Purpose: Add test result row to HTML report
        # Why needed: Provides individual test result in table format
        # Impact: Test result is added to the report table
        # cat >> "$report_file": Append to HTML file
        # << EOF: Here document for table row
        # Table row: Test name, status with styling, and log file link
    done
    
    # =============================================================================
    # GENERATE HTML REPORT FOOTER
    # =============================================================================
    # Purpose: Complete HTML document structure
    # Why needed: Closes HTML document properly
    
    cat >> "$report_file" << EOF
        </table>
    </div>
</body>
</html>
EOF
    # Purpose: Complete HTML report structure
    # Why needed: Closes HTML document properly
    # Impact: HTML report is completed
    # cat >> "$report_file": Append to HTML file
    # << EOF: Here document for HTML footer
    # HTML footer: Closes table, div, body, and html tags
    
    print_status "SUCCESS" "Test report generated: $report_file"
    # Purpose: Log successful report generation
    # Why needed: Confirms report generation was successful
    # Impact: User knows report was generated successfully
}

# Function: Generate JSON report
generate_json_report() {
    # =============================================================================
    # GENERATE JSON REPORT FUNCTION
    # =============================================================================
    # Generates a JSON test report with comprehensive test results.
    # Provides machine-readable test report for automated processing.
    # =============================================================================
    
    # Purpose: Generate JSON test report with comprehensive results
    # Why needed: Provides machine-readable test report for automated processing
    # Impact: Test results are presented in structured JSON format
    # Parameters: None (uses global variables for test results)
    # Usage: generate_json_report
    # Returns: None (creates JSON file)
    
    local json_file="${OUTPUT_DIR}/test_report_${TIMESTAMP}.json"
    # Purpose: Specifies the output file path for the JSON report
    # Why needed: Provides file path for JSON report generation
    # Impact: Report is saved to the specified file
    # "${OUTPUT_DIR}/test_report_${TIMESTAMP}.json": Report file path with timestamp
    
    print_status "INFO" "Generating JSON report: $json_file"
    # Purpose: Log the start of JSON report generation
    # Why needed: Informs user that JSON report generation has begun
    # Impact: User knows JSON report generation has started
    
    # =============================================================================
    # GENERATE JSON REPORT HEADER
    # =============================================================================
    # Purpose: Create JSON document structure with metadata and summary
    # Why needed: Provides structured JSON report with test summary
    
    cat > "$json_file" << EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "namespace": "$NAMESPACE",
    "test_type": "$TEST_TYPE",
    "summary": {
        "total_tests": $TOTAL_TESTS,
        "passed_tests": $PASSED_TESTS,
        "failed_tests": $FAILED_TESTS,
        "success_rate": $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    },
    "results": {
EOF
    # Purpose: Generate JSON report header with metadata and summary
    # Why needed: Creates structured JSON report with test summary
    # Impact: JSON report is created with metadata and summary information
    # cat > "$json_file": Create JSON file
    # << EOF: Here document for JSON content
    # JSON structure: Document structure with metadata and summary
    # timestamp: UTC timestamp for report generation
    # namespace: Kubernetes namespace for tests
    # test_type: Type of tests executed
    # summary: Test statistics and success rate
    # results: Placeholder for individual test results
    
    local first=true
    # Purpose: Flag to track first test result for JSON formatting
    # Why needed: Ensures proper JSON comma placement
    # Impact: JSON formatting is correct without trailing commas
    
    for test_name in "${!TEST_RESULTS[@]}"; do
        # Purpose: Loop through each test result
        # Why needed: Processes each test result for JSON report generation
        # Impact: Each test result is added to the JSON report
        # "${!TEST_RESULTS[@]}": Array of test names
        
        if [ "$first" = true ]; then
            # Purpose: Check if this is the first test result
            # Why needed: Ensures proper JSON comma placement
            # Impact: First test result doesn't have leading comma
            
            first=false
            # Purpose: Mark that first test result has been processed
            # Why needed: Ensures subsequent test results have commas
            # Impact: First test flag is cleared
        else
            # Purpose: Handle subsequent test results
            # Why needed: Adds comma before test result for proper JSON formatting
            # Impact: JSON formatting is correct
            
            echo "," >> "$json_file"
            # Purpose: Add comma before test result
            # Why needed: Ensures proper JSON comma placement
            # Impact: JSON formatting is correct
            # echo ",": Output comma
            # >> "$json_file": Append to JSON file
        fi
        
        cat >> "$json_file" << EOF
        "$test_name": {
            "status": "${TEST_RESULTS[$test_name]}",
            "log_file": "${test_name}_${TIMESTAMP}.log"
        }
EOF
        # Purpose: Add test result to JSON report
        # Why needed: Provides individual test result in JSON format
        # Impact: Test result is added to the JSON report
        # cat >> "$json_file": Append to JSON file
        # << EOF: Here document for test result
        # JSON structure: Test name with status and log file reference
    done
    
    # =============================================================================
    # GENERATE JSON REPORT FOOTER
    # =============================================================================
    # Purpose: Complete JSON document structure
    # Why needed: Closes JSON document properly
    
    cat >> "$json_file" << EOF
    }
}
EOF
    # Purpose: Complete JSON report structure
    # Why needed: Closes JSON document properly
    # Impact: JSON report is completed
    # cat >> "$json_file": Append to JSON file
    # << EOF: Here document for JSON footer
    # JSON footer: Closes results object and root object
    
    print_status "SUCCESS" "JSON report generated: $json_file"
    # Purpose: Log successful JSON report generation
    # Why needed: Confirms JSON report generation was successful
    # Impact: User knows JSON report was generated successfully
}

# =============================================================================
# TEST DEFINITIONS
# =============================================================================

# Define validation tests
define_validation_tests() {
    local tests=()
    
    tests+=("NamespaceValidation:./validate-monitoring-stack.sh:$NAMESPACE")
    tests+=("MonitoringStackValidation:./validate-monitoring-stack.sh:$NAMESPACE")
    
    echo "${tests[@]}"
}

# Define health check tests
define_health_tests() {
    local tests=()
    
    tests+=("HealthCheck:./health-check.sh:$NAMESPACE")
    tests+=("HealthCheckJSON:./health-check.sh:$NAMESPACE --json")
    
    echo "${tests[@]}"
}

# Define performance tests
define_performance_tests() {
    local tests=()
    
    tests+=("LoadTest:./performance-test.sh:$NAMESPACE --type=load --duration=60s --concurrent=5 --rate=50")
    tests+=("StressTest:./performance-test.sh:$NAMESPACE --type=stress")
    tests+=("DatabaseTest:./performance-test.sh:$NAMESPACE --type=database")
    tests+=("MonitoringTest:./performance-test.sh:$NAMESPACE --type=monitoring")
    
    echo "${tests[@]}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

print_status "HEADER" "Starting comprehensive test suite for namespace: $NAMESPACE"
print_status "INFO" "Test type: $TEST_TYPE"
print_status "INFO" "Verbose mode: $VERBOSE"
print_status "INFO" "Parallel execution: $PARALLEL"
print_status "INFO" "Output directory: $OUTPUT_DIR"

# Check prerequisites
if ! command_exists kubectl; then
    print_status "ERROR" "kubectl command not found"
    exit 1
fi

if ! command_exists bash; then
    print_status "ERROR" "bash command not found"
    exit 1
fi

# Create output directory
create_output_dir

# Change to script directory
cd "$(dirname "$0")"

# Make scripts executable
chmod +x *.sh

# Run tests based on type
case $TEST_TYPE in
    "validation")
        print_status "INFO" "Running validation tests only"
        tests=($(define_validation_tests))
        ;;
    "health")
        print_status "INFO" "Running health check tests only"
        tests=($(define_health_tests))
        ;;
    "performance")
        print_status "INFO" "Running performance tests only"
        tests=($(define_performance_tests))
        ;;
    "all")
        print_status "INFO" "Running all tests"
        tests=($(define_validation_tests))
        tests+=($(define_health_tests))
        tests+=($(define_performance_tests))
        ;;
    *)
        print_status "ERROR" "Unknown test type: $TEST_TYPE"
        print_status "INFO" "Available types: all, validation, health, performance"
        exit 1
        ;;
esac

# Run tests
if [ "$PARALLEL" = true ]; then
    run_parallel_tests "${tests[@]}"
else
    for test in "${tests[@]}"; do
        IFS=':' read -r test_name test_script test_args <<< "$test"
        run_test "$test_name" "$test_script" $test_args
    done
fi

# Generate reports
generate_report
generate_json_report

# =============================================================================
# FINAL SUMMARY
# =============================================================================

print_status "HEADER" "Test suite completed"

echo ""
echo "============================================================================="
echo "TEST SUITE SUMMARY"
echo "============================================================================="
echo "Total Tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo -e "Success Rate: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"
echo ""
echo "Output Directory: $OUTPUT_DIR"
echo "HTML Report: ${OUTPUT_DIR}/test_report_${TIMESTAMP}.html"
echo "JSON Report: ${OUTPUT_DIR}/test_report_${TIMESTAMP}.json"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    print_status "SUCCESS" "All tests passed! Application is ready for production."
    exit 0
else
    print_status "ERROR" "Some tests failed. Please check the logs and fix the issues."
    exit 1
fi
