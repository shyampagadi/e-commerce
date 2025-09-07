#!/bin/bash

# =============================================================================
# CHAOS ENGINEERING RECOVERY TEST SCRIPT
# =============================================================================
# Script for testing recovery procedures after chaos experiments.
# Provides comprehensive testing of system recovery and data integrity.
# =============================================================================

# Purpose: Test recovery procedures after chaos experiments
# Why needed: Ensures system can recover properly from chaos experiments
# Impact: Validates recovery procedures and system resilience
# Parameters: Various recovery test parameters and options
# Usage: ./chaos-recovery-test.sh --test=full-recovery --timeout=300
# Returns: 0 on success, 1 on failure

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Purpose: Define configuration constants and variables
# Why needed: Provides centralized configuration for recovery testing
# Impact: Ensures consistent recovery testing across all chaos experiments

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
# Purpose: Set the target namespace for recovery testing
# Why needed: Specifies which namespace to test recovery for
# Impact: Recovery testing will be conducted in the specified namespace
# Default: ecommerce-production

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
# Purpose: Set the monitoring namespace
# Why needed: Specifies which namespace contains monitoring components
# Impact: Monitoring recovery testing will target the specified namespace
# Default: monitoring

LOG_DIR="${LOG_DIR:-/tmp/chaos-logs}"
# Purpose: Set the log directory for recovery testing
# Why needed: Provides centralized logging location
# Impact: All recovery test logs will be stored in the specified directory
# Default: /tmp/chaos-logs

# Recovery test configuration
DEFAULT_TEST_TYPE="${DEFAULT_TEST_TYPE:-full-recovery}"
# Purpose: Set the default recovery test type
# Why needed: Provides default test type when not specified
# Impact: Recovery testing will use full recovery test by default
# Default: full-recovery

RECOVERY_TIMEOUT="${RECOVERY_TIMEOUT:-300}"
# Purpose: Set the recovery timeout in seconds
# Why needed: Prevents infinite recovery testing loops
# Impact: Recovery testing will timeout after specified time
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
    # Provides consistent logging format across all recovery test operations.
    # =============================================================================
    
    # Purpose: Print formatted status messages
    # Why needed: Provides consistent logging format for all operations
    # Impact: All operations are logged with consistent format
    # Parameters:
    #   $1: Log level (INFO, WARNING, ERROR, SUCCESS)
    #   $2: Message to print
    # Usage: print_status "INFO" "Starting recovery test"
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

# Function: Test application functionality
test_application_functionality() {
    # =============================================================================
    # TEST APPLICATION FUNCTIONALITY FUNCTION
    # =============================================================================
    # Tests the functionality of the e-commerce application after recovery.
    # Provides comprehensive testing of application features and data integrity.
    # =============================================================================
    
    # Purpose: Test e-commerce application functionality after recovery
    # Why needed: Ensures application is fully functional after recovery
    # Impact: Validates application functionality and data integrity
    # Parameters: None (uses global variables)
    # Usage: test_application_functionality
    # Returns: 0 if application functional, 1 if not
    
    print_status "INFO" "Testing application functionality after recovery"
    # Purpose: Log the start of application functionality testing
    # Why needed: Informs user that application testing has begun
    # Impact: User knows application testing has started
    
    local test_failures=()
    # Purpose: Array to store test failure information
    # Why needed: Tracks which tests failed
    # Impact: Will contain test failure information
    
    # =============================================================================
    # TEST FRONTEND CONNECTIVITY
    # =============================================================================
    # Purpose: Test frontend service connectivity
    # Why needed: Validates that frontend is accessible
    
    print_status "INFO" "Testing frontend connectivity"
    # Purpose: Log frontend connectivity test start
    # Why needed: Informs user about frontend testing
    # Impact: User knows frontend testing has started
    
    local frontend_response
    # Purpose: Variable to store frontend response
    # Why needed: Collects frontend response for validation
    # Impact: Will contain frontend response
    
    frontend_response=$(curl -s -o /dev/null -w "%{http_code}" http://ecommerce-frontend-service:3000/health)
    # Purpose: Test frontend health endpoint
    # Why needed: Validates frontend service health
    # Impact: Frontend health is tested
    # curl: HTTP client for testing
    # -s: Silent mode
    # -o /dev/null: Discard response body
    # -w "%{http_code}": Output HTTP status code
    # http://ecommerce-frontend-service:3000/health: Frontend health endpoint
    
    if [ "$frontend_response" = "200" ]; then
        # Purpose: Check if frontend is healthy
        # Why needed: Validates frontend service health
        # Impact: Proceeds with success handling if frontend healthy
        # = "200": Check if HTTP status is 200 OK
        
        print_status "SUCCESS" "Frontend service is healthy (HTTP $frontend_response)"
        # Purpose: Log frontend health success
        # Why needed: Confirms frontend is healthy
        # Impact: User knows frontend is healthy
    else
        # Purpose: Handle frontend health failure
        # Why needed: Provides error handling for frontend issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Frontend service is unhealthy (HTTP $frontend_response)"
        # Purpose: Log frontend health error
        # Why needed: Informs user about frontend issues
        # Impact: User knows frontend is unhealthy
        
        test_failures+=("frontend-connectivity")
        # Purpose: Add frontend test to failure list
        # Why needed: Tracks frontend test failure
        # Impact: Frontend test failure is recorded
    fi
    
    # =============================================================================
    # TEST BACKEND CONNECTIVITY
    # =============================================================================
    # Purpose: Test backend service connectivity
    # Why needed: Validates that backend is accessible
    
    print_status "INFO" "Testing backend connectivity"
    # Purpose: Log backend connectivity test start
    # Why needed: Informs user about backend testing
    # Impact: User knows backend testing has started
    
    local backend_response
    # Purpose: Variable to store backend response
    # Why needed: Collects backend response for validation
    # Impact: Will contain backend response
    
    backend_response=$(curl -s -o /dev/null -w "%{http_code}" http://ecommerce-backend-service:8000/health)
    # Purpose: Test backend health endpoint
    # Why needed: Validates backend service health
    # Impact: Backend health is tested
    # curl: HTTP client for testing
    # -s: Silent mode
    # -o /dev/null: Discard response body
    # -w "%{http_code}": Output HTTP status code
    # http://ecommerce-backend-service:8000/health: Backend health endpoint
    
    if [ "$backend_response" = "200" ]; then
        # Purpose: Check if backend is healthy
        # Why needed: Validates backend service health
        # Impact: Proceeds with success handling if backend healthy
        # = "200": Check if HTTP status is 200 OK
        
        print_status "SUCCESS" "Backend service is healthy (HTTP $backend_response)"
        # Purpose: Log backend health success
        # Why needed: Confirms backend is healthy
        # Impact: User knows backend is healthy
    else
        # Purpose: Handle backend health failure
        # Why needed: Provides error handling for backend issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Backend service is unhealthy (HTTP $backend_response)"
        # Purpose: Log backend health error
        # Why needed: Informs user about backend issues
        # Impact: User knows backend is unhealthy
        
        test_failures+=("backend-connectivity")
        # Purpose: Add backend test to failure list
        # Why needed: Tracks backend test failure
        # Impact: Backend test failure is recorded
    fi
    
    # =============================================================================
    # TEST DATABASE CONNECTIVITY
    # =============================================================================
    # Purpose: Test database connectivity
    # Why needed: Validates that database is accessible
    
    print_status "INFO" "Testing database connectivity"
    # Purpose: Log database connectivity test start
    # Why needed: Informs user about database testing
    # Impact: User knows database testing has started
    
    local db_response
    # Purpose: Variable to store database response
    # Why needed: Collects database response for validation
    # Impact: Will contain database response
    
    db_response=$(kubectl exec -n "$NAMESPACE" deployment/ecommerce-database-deployment -- psql -c "SELECT 1" 2>/dev/null | grep -c "1 row")
    # Purpose: Test database connectivity
    # Why needed: Validates database service health
    # Impact: Database health is tested
    # kubectl exec: Execute command in pod
    # -n "$NAMESPACE": Target namespace
    # deployment/ecommerce-database-deployment: Database deployment
    # -- psql -c "SELECT 1": Execute simple SQL query
    # 2>/dev/null: Suppress error output
    # grep -c "1 row": Count successful query results
    
    if [ "$db_response" -eq 1 ]; then
        # Purpose: Check if database is healthy
        # Why needed: Validates database service health
        # Impact: Proceeds with success handling if database healthy
        # -eq 1: Equal to 1 (successful query)
        
        print_status "SUCCESS" "Database service is healthy (query returned 1 row)"
        # Purpose: Log database health success
        # Why needed: Confirms database is healthy
        # Impact: User knows database is healthy
    else
        # Purpose: Handle database health failure
        # Why needed: Provides error handling for database issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Database service is unhealthy (query failed)"
        # Purpose: Log database health error
        # Why needed: Informs user about database issues
        # Impact: User knows database is unhealthy
        
        test_failures+=("database-connectivity")
        # Purpose: Add database test to failure list
        # Why needed: Tracks database test failure
        # Impact: Database test failure is recorded
    fi
    
    # =============================================================================
    # TEST DATA INTEGRITY
    # =============================================================================
    # Purpose: Test data integrity
    # Why needed: Validates that data is intact after recovery
    
    print_status "INFO" "Testing data integrity"
    # Purpose: Log data integrity test start
    # Why needed: Informs user about data integrity testing
    # Impact: User knows data integrity testing has started
    
    local user_count
    # Purpose: Variable to store user count
    # Why needed: Provides user count for validation
    # Impact: Will contain user count
    
    local product_count
    # Purpose: Variable to store product count
    # Why needed: Provides product count for validation
    # Impact: Will contain product count
    
    user_count=$(kubectl exec -n "$NAMESPACE" deployment/ecommerce-database-deployment -- psql -c "SELECT COUNT(*) FROM users" 2>/dev/null | grep -o '[0-9]\+' | tail -1)
    # Purpose: Get user count from database
    # Why needed: Validates user data integrity
    # Impact: User count is retrieved
    # kubectl exec: Execute command in pod
    # -n "$NAMESPACE": Target namespace
    # deployment/ecommerce-database-deployment: Database deployment
    # -- psql -c "SELECT COUNT(*) FROM users": Count users
    # 2>/dev/null: Suppress error output
    # grep -o '[0-9]\+': Extract numbers
    # tail -1: Get last line
    
    product_count=$(kubectl exec -n "$NAMESPACE" deployment/ecommerce-database-deployment -- psql -c "SELECT COUNT(*) FROM products" 2>/dev/null | grep -o '[0-9]\+' | tail -1)
    # Purpose: Get product count from database
    # Why needed: Validates product data integrity
    # Impact: Product count is retrieved
    # kubectl exec: Execute command in pod
    # -n "$NAMESPACE": Target namespace
    # deployment/ecommerce-database-deployment: Database deployment
    # -- psql -c "SELECT COUNT(*) FROM products": Count products
    # 2>/dev/null: Suppress error output
    # grep -o '[0-9]\+': Extract numbers
    # tail -1: Get last line
    
    if [ "$user_count" -gt 0 ] && [ "$product_count" -gt 0 ]; then
        # Purpose: Check if data exists
        # Why needed: Validates data integrity
        # Impact: Proceeds with success handling if data exists
        # -gt 0: Greater than zero
        
        print_status "SUCCESS" "Data integrity verified (users: $user_count, products: $product_count)"
        # Purpose: Log data integrity success
        # Why needed: Confirms data integrity
        # Impact: User knows data is intact
    else
        # Purpose: Handle data integrity failure
        # Why needed: Provides error handling for data issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Data integrity check failed (users: $user_count, products: $product_count)"
        # Purpose: Log data integrity error
        # Why needed: Informs user about data issues
        # Impact: User knows data integrity failed
        
        test_failures+=("data-integrity")
        # Purpose: Add data integrity test to failure list
        # Why needed: Tracks data integrity test failure
        # Impact: Data integrity test failure is recorded
    fi
    
    # =============================================================================
    # VALIDATE RESULTS
    # =============================================================================
    # Purpose: Validate overall application functionality results
    # Why needed: Provides overall validation result
    
    if [ ${#test_failures[@]} -eq 0 ]; then
        # Purpose: Check if no test failures found
        # Why needed: Validates that all tests passed
        # Impact: Proceeds with success handling if all tests passed
        # ${#test_failures[@]}: Length of test failures array
        # -eq 0: Equal to zero
        
        print_status "SUCCESS" "All application functionality tests passed"
        # Purpose: Log successful application testing
        # Why needed: Confirms all tests passed
        # Impact: User knows all tests passed
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates application testing succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle test failures case
        # Why needed: Provides error handling for test failures
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Application functionality tests failed: ${test_failures[*]}"
        # Purpose: Log test failures error
        # Why needed: Informs user about test failures
        # Impact: User knows which tests failed
        # ${test_failures[*]}: List of failed test names
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates application testing failed
        # Impact: Function returns failure
    fi
}

# Function: Test monitoring system recovery
test_monitoring_recovery() {
    # =============================================================================
    # TEST MONITORING SYSTEM RECOVERY FUNCTION
    # =============================================================================
    # Tests the recovery of monitoring systems after chaos experiments.
    # Provides comprehensive testing of monitoring system functionality.
    # =============================================================================
    
    # Purpose: Test monitoring system recovery after chaos experiments
    # Why needed: Ensures monitoring systems are functional after recovery
    # Impact: Validates monitoring system functionality and data collection
    # Parameters: None (uses global variables)
    # Usage: test_monitoring_recovery
    # Returns: 0 if monitoring functional, 1 if not
    
    print_status "INFO" "Testing monitoring system recovery"
    # Purpose: Log the start of monitoring recovery testing
    # Why needed: Informs user that monitoring testing has begun
    # Impact: User knows monitoring testing has started
    
    local monitoring_failures=()
    # Purpose: Array to store monitoring test failure information
    # Why needed: Tracks which monitoring tests failed
    # Impact: Will contain monitoring test failure information
    
    # =============================================================================
    # TEST PROMETHEUS RECOVERY
    # =============================================================================
    # Purpose: Test Prometheus recovery
    # Why needed: Validates that Prometheus is functional
    
    print_status "INFO" "Testing Prometheus recovery"
    # Purpose: Log Prometheus recovery test start
    # Why needed: Informs user about Prometheus testing
    # Impact: User knows Prometheus testing has started
    
    local prometheus_response
    # Purpose: Variable to store Prometheus response
    # Why needed: Collects Prometheus response for validation
    # Impact: Will contain Prometheus response
    
    prometheus_response=$(curl -s -o /dev/null -w "%{http_code}" http://prometheus-service:9090/api/v1/query?query=up)
    # Purpose: Test Prometheus API endpoint
    # Why needed: Validates Prometheus service health
    # Impact: Prometheus health is tested
    # curl: HTTP client for testing
    # -s: Silent mode
    # -o /dev/null: Discard response body
    # -w "%{http_code}": Output HTTP status code
    # http://prometheus-service:9090/api/v1/query?query=up: Prometheus API endpoint
    
    if [ "$prometheus_response" = "200" ]; then
        # Purpose: Check if Prometheus is healthy
        # Why needed: Validates Prometheus service health
        # Impact: Proceeds with success handling if Prometheus healthy
        # = "200": Check if HTTP status is 200 OK
        
        print_status "SUCCESS" "Prometheus service is healthy (HTTP $prometheus_response)"
        # Purpose: Log Prometheus health success
        # Why needed: Confirms Prometheus is healthy
        # Impact: User knows Prometheus is healthy
    else
        # Purpose: Handle Prometheus health failure
        # Why needed: Provides error handling for Prometheus issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Prometheus service is unhealthy (HTTP $prometheus_response)"
        # Purpose: Log Prometheus health error
        # Why needed: Informs user about Prometheus issues
        # Impact: User knows Prometheus is unhealthy
        
        monitoring_failures+=("prometheus-recovery")
        # Purpose: Add Prometheus test to failure list
        # Why needed: Tracks Prometheus test failure
        # Impact: Prometheus test failure is recorded
    fi
    
    # =============================================================================
    # TEST GRAFANA RECOVERY
    # =============================================================================
    # Purpose: Test Grafana recovery
    # Why needed: Validates that Grafana is functional
    
    print_status "INFO" "Testing Grafana recovery"
    # Purpose: Log Grafana recovery test start
    # Why needed: Informs user about Grafana testing
    # Impact: User knows Grafana testing has started
    
    local grafana_response
    # Purpose: Variable to store Grafana response
    # Why needed: Collects Grafana response for validation
    # Impact: Will contain Grafana response
    
    grafana_response=$(curl -s -o /dev/null -w "%{http_code}" http://grafana-service:3000/api/health)
    # Purpose: Test Grafana API endpoint
    # Why needed: Validates Grafana service health
    # Impact: Grafana health is tested
    # curl: HTTP client for testing
    # -s: Silent mode
    # -o /dev/null: Discard response body
    # -w "%{http_code}": Output HTTP status code
    # http://grafana-service:3000/api/health: Grafana API endpoint
    
    if [ "$grafana_response" = "200" ]; then
        # Purpose: Check if Grafana is healthy
        # Why needed: Validates Grafana service health
        # Impact: Proceeds with success handling if Grafana healthy
        # = "200": Check if HTTP status is 200 OK
        
        print_status "SUCCESS" "Grafana service is healthy (HTTP $grafana_response)"
        # Purpose: Log Grafana health success
        # Why needed: Confirms Grafana is healthy
        # Impact: User knows Grafana is healthy
    else
        # Purpose: Handle Grafana health failure
        # Why needed: Provides error handling for Grafana issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Grafana service is unhealthy (HTTP $grafana_response)"
        # Purpose: Log Grafana health error
        # Why needed: Informs user about Grafana issues
        # Impact: User knows Grafana is unhealthy
        
        monitoring_failures+=("grafana-recovery")
        # Purpose: Add Grafana test to failure list
        # Why needed: Tracks Grafana test failure
        # Impact: Grafana test failure is recorded
    fi
    
    # =============================================================================
    # TEST ALERTMANAGER RECOVERY
    # =============================================================================
    # Purpose: Test AlertManager recovery
    # Why needed: Validates that AlertManager is functional
    
    print_status "INFO" "Testing AlertManager recovery"
    # Purpose: Log AlertManager recovery test start
    # Why needed: Informs user about AlertManager testing
    # Impact: User knows AlertManager testing has started
    
    local alertmanager_response
    # Purpose: Variable to store AlertManager response
    # Why needed: Collects AlertManager response for validation
    # Impact: Will contain AlertManager response
    
    alertmanager_response=$(curl -s -o /dev/null -w "%{http_code}" http://alertmanager-service:9093/api/v1/status)
    # Purpose: Test AlertManager API endpoint
    # Why needed: Validates AlertManager service health
    # Impact: AlertManager health is tested
    # curl: HTTP client for testing
    # -s: Silent mode
    # -o /dev/null: Discard response body
    # -w "%{http_code}": Output HTTP status code
    # http://alertmanager-service:9093/api/v1/status: AlertManager API endpoint
    
    if [ "$alertmanager_response" = "200" ]; then
        # Purpose: Check if AlertManager is healthy
        # Why needed: Validates AlertManager service health
        # Impact: Proceeds with success handling if AlertManager healthy
        # = "200": Check if HTTP status is 200 OK
        
        print_status "SUCCESS" "AlertManager service is healthy (HTTP $alertmanager_response)"
        # Purpose: Log AlertManager health success
        # Why needed: Confirms AlertManager is healthy
        # Impact: User knows AlertManager is healthy
    else
        # Purpose: Handle AlertManager health failure
        # Why needed: Provides error handling for AlertManager issues
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "AlertManager service is unhealthy (HTTP $alertmanager_response)"
        # Purpose: Log AlertManager health error
        # Why needed: Informs user about AlertManager issues
        # Impact: User knows AlertManager is unhealthy
        
        monitoring_failures+=("alertmanager-recovery")
        # Purpose: Add AlertManager test to failure list
        # Why needed: Tracks AlertManager test failure
        # Impact: AlertManager test failure is recorded
    fi
    
    # =============================================================================
    # VALIDATE RESULTS
    # =============================================================================
    # Purpose: Validate overall monitoring recovery results
    # Why needed: Provides overall validation result
    
    if [ ${#monitoring_failures[@]} -eq 0 ]; then
        # Purpose: Check if no monitoring test failures found
        # Why needed: Validates that all monitoring tests passed
        # Impact: Proceeds with success handling if all tests passed
        # ${#monitoring_failures[@]}: Length of monitoring failures array
        # -eq 0: Equal to zero
        
        print_status "SUCCESS" "All monitoring system recovery tests passed"
        # Purpose: Log successful monitoring testing
        # Why needed: Confirms all monitoring tests passed
        # Impact: User knows all monitoring tests passed
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates monitoring testing succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle monitoring test failures case
        # Why needed: Provides error handling for monitoring test failures
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Monitoring system recovery tests failed: ${monitoring_failures[*]}"
        # Purpose: Log monitoring test failures error
        # Why needed: Informs user about monitoring test failures
        # Impact: User knows which monitoring tests failed
        # ${monitoring_failures[*]}: List of failed monitoring test names
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates monitoring testing failed
        # Impact: Function returns failure
    fi
}

# Function: Main execution
main() {
    # =============================================================================
    # MAIN EXECUTION FUNCTION
    # =============================================================================
    # Main function that orchestrates the chaos recovery test execution.
    # Provides the main entry point and execution flow for the recovery test script.
    # =============================================================================
    
    # Purpose: Main execution function for chaos recovery test script
    # Why needed: Provides main entry point and execution flow
    # Impact: Orchestrates the entire chaos recovery test process
    # Parameters: Command-line arguments
    # Usage: main "$@"
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting Chaos Engineering Recovery Test Script"
    # Purpose: Log the start of recovery test script execution
    # Why needed: Informs user that recovery test script has started
    # Impact: User knows recovery test script has started
    
    # =============================================================================
    # TEST APPLICATION FUNCTIONALITY
    # =============================================================================
    # Purpose: Test application functionality
    # Why needed: Ensures application is functional after recovery
    
    if ! test_application_functionality; then
        # Purpose: Test application functionality
        # Why needed: Ensures application is functional after recovery
        # Impact: Proceeds with error handling if application testing failed
        # test_application_functionality: Function to test application functionality
        
        print_status "ERROR" "Application functionality test failed"
        # Purpose: Log application test failure
        # Why needed: Informs user about application test issues
        # Impact: User knows application test failed
        
        exit 1
        # Purpose: Exit with failure status
        # Why needed: Indicates recovery test failed
        # Impact: Script exits with failure
    fi
    
    # =============================================================================
    # TEST MONITORING SYSTEM RECOVERY
    # =============================================================================
    # Purpose: Test monitoring system recovery
    # Why needed: Ensures monitoring systems are functional after recovery
    
    if ! test_monitoring_recovery; then
        # Purpose: Test monitoring system recovery
        # Why needed: Ensures monitoring systems are functional after recovery
        # Impact: Proceeds with error handling if monitoring testing failed
        # test_monitoring_recovery: Function to test monitoring recovery
        
        print_status "ERROR" "Monitoring system recovery test failed"
        # Purpose: Log monitoring test failure
        # Why needed: Informs user about monitoring test issues
        # Impact: User knows monitoring test failed
        
        exit 1
        # Purpose: Exit with failure status
        # Why needed: Indicates recovery test failed
        # Impact: Script exits with failure
    fi
    
    print_status "SUCCESS" "Chaos Engineering Recovery Test Script completed successfully"
    # Purpose: Log successful recovery test completion
    # Why needed: Confirms recovery test completed successfully
    # Impact: User knows recovery test completed successfully
    
    exit 0
    # Purpose: Exit with success status
    # Why needed: Indicates recovery test completed successfully
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
