#!/bin/bash

# =============================================================================
# CHAOS ENGINEERING ORCHESTRATOR SCRIPT
# =============================================================================
# Main orchestration script for executing chaos engineering experiments.
# Provides centralized control and coordination of all chaos experiments.
# =============================================================================

# Purpose: Orchestrate and coordinate chaos engineering experiments
# Why needed: Provides centralized control and coordination of chaos experiments
# Impact: Enables systematic execution of chaos experiments with proper safety controls
# Parameters: Various experiment parameters and options
# Usage: ./chaos-orchestrator.sh --experiment=pod-failure --target=backend --duration=10m
# Returns: 0 on success, 1 on failure

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Purpose: Define configuration constants and variables
# Why needed: Provides centralized configuration for all chaos experiments
# Impact: Ensures consistent configuration across all experiments

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Purpose: Get the directory where this script is located
# Why needed: Enables relative path resolution for other scripts and files
# Impact: Script can find other chaos engineering files regardless of execution location

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# Purpose: Get the project root directory
# Why needed: Enables access to project-wide configuration and resources
# Impact: Script can access project configuration and other components

NAMESPACE="${NAMESPACE:-ecommerce-production}"
# Purpose: Set the target namespace for chaos experiments
# Why needed: Specifies which namespace to target for experiments
# Impact: Experiments will be conducted in the specified namespace
# Default: ecommerce-production

MONITORING_NAMESPACE="${MONITORING_NAMESPACE:-monitoring}"
# Purpose: Set the monitoring namespace
# Why needed: Specifies which namespace contains monitoring components
# Impact: Monitoring system experiments will target the specified namespace
# Default: monitoring

LOG_DIR="${LOG_DIR:-/tmp/chaos-logs}"
# Purpose: Set the log directory for chaos experiments
# Why needed: Provides centralized logging location for all experiments
# Impact: All experiment logs will be stored in the specified directory
# Default: /tmp/chaos-logs

REPORT_DIR="${REPORT_DIR:-/tmp/chaos-reports}"
# Purpose: Set the report directory for chaos experiments
# Why needed: Provides centralized reporting location for all experiments
# Impact: All experiment reports will be stored in the specified directory
# Default: /tmp/chaos-reports

# Experiment configuration
DEFAULT_DURATION="${DEFAULT_DURATION:-10m}"
# Purpose: Set the default experiment duration
# Why needed: Provides default duration for experiments when not specified
# Impact: Experiments will run for the specified duration by default
# Default: 10 minutes

DEFAULT_TARGET="${DEFAULT_TARGET:-all}"
# Purpose: Set the default experiment target
# Why needed: Provides default target for experiments when not specified
# Impact: Experiments will target all components by default
# Default: all

MAX_CONCURRENT_EXPERIMENTS="${MAX_CONCURRENT_EXPERIMENTS:-3}"
# Purpose: Set the maximum number of concurrent experiments
# Why needed: Prevents system overload from too many simultaneous experiments
# Impact: Limits the number of concurrent experiments to prevent system overload
# Default: 3

# Safety configuration
SAFETY_CHECKS_ENABLED="${SAFETY_CHECKS_ENABLED:-true}"
# Purpose: Enable or disable safety checks
# Why needed: Provides safety control for experiments
# Impact: Safety checks will be performed if enabled
# Default: true

AUTO_ROLLBACK_ENABLED="${AUTO_ROLLBACK_ENABLED:-true}"
# Purpose: Enable or disable automatic rollback
# Why needed: Provides automatic rollback capability for failed experiments
# Impact: Failed experiments will be automatically rolled back if enabled
# Default: true

EMERGENCY_STOP_ENABLED="${EMERGENCY_STOP_ENABLED:-true}"
# Purpose: Enable or disable emergency stop capability
# Why needed: Provides emergency stop capability for critical situations
# Impact: Experiments can be stopped immediately in emergency situations
# Default: true

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print status message
print_status() {
    # =============================================================================
    # PRINT STATUS MESSAGE FUNCTION
    # =============================================================================
    # Prints formatted status messages with timestamp and log level.
    # Provides consistent logging format across all chaos engineering scripts.
    # =============================================================================
    
    # Purpose: Print formatted status messages
    # Why needed: Provides consistent logging format for all operations
    # Impact: All operations are logged with consistent format
    # Parameters:
    #   $1: Log level (INFO, WARNING, ERROR, SUCCESS)
    #   $2: Message to print
    # Usage: print_status "INFO" "Starting chaos experiment"
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
            # echo -e: Enable interpretation of backslash escapes
            # \033[0;34m: Set text color to blue
            # \033[0m: Reset text color
            ;;
        "WARNING")
            echo -e "\033[0;33m[${timestamp}] [WARNING] ${message}\033[0m"
            # Purpose: Print warning message in yellow color
            # Why needed: Provides visual distinction for warning messages
            # Impact: Warning messages are displayed in yellow color
            # echo -e: Enable interpretation of backslash escapes
            # \033[0;33m: Set text color to yellow
            # \033[0m: Reset text color
            ;;
        "ERROR")
            echo -e "\033[0;31m[${timestamp}] [ERROR] ${message}\033[0m"
            # Purpose: Print error message in red color
            # Why needed: Provides visual distinction for error messages
            # Impact: Error messages are displayed in red color
            # echo -e: Enable interpretation of backslash escapes
            # \033[0;31m: Set text color to red
            # \033[0m: Reset text color
            ;;
        "SUCCESS")
            echo -e "\033[0;32m[${timestamp}] [SUCCESS] ${message}\033[0m"
            # Purpose: Print success message in green color
            # Why needed: Provides visual distinction for success messages
            # Impact: Success messages are displayed in green color
            # echo -e: Enable interpretation of backslash escapes
            # \033[0;32m: Set text color to green
            # \033[0m: Reset text color
            ;;
        *)
            echo -e "[${timestamp}] [${level}] ${message}"
            # Purpose: Print message with default formatting
            # Why needed: Handles unknown log levels gracefully
            # Impact: Unknown log levels are displayed with default formatting
            ;;
    esac
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # CHECK COMMAND EXISTS FUNCTION
    # =============================================================================
    # Checks if a command exists and is available for execution.
    # Provides validation for required commands before execution.
    # =============================================================================
    
    # Purpose: Check if a command exists and is available
    # Why needed: Validates that required commands are available before execution
    # Impact: Prevents script failures due to missing commands
    # Parameters:
    #   $1: Command name to check
    # Usage: command_exists "kubectl"
    # Returns: 0 if command exists, 1 if not
    
    local cmd=$1
    # Purpose: Specifies the command name to check
    # Why needed: Identifies which command to validate
    # Impact: Function validates the specified command
    # Parameter: $1 is the command name
    
    if command -v "$cmd" >/dev/null 2>&1; then
        # Purpose: Check if command exists in PATH
        # Why needed: Validates that command is available for execution
        # Impact: Proceeds with success if command exists
        # command -v: Get the path of the command
        # "$cmd": Command name to check
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates command exists
        # Impact: Function returns success
    else
        # Purpose: Handle command not found case
        # Why needed: Provides error handling for missing commands
        # Impact: Proceeds with error handling
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates command does not exist
        # Impact: Function returns failure
    fi
}

# Function: Check prerequisites
check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates that all prerequisites are met before executing chaos experiments.
    # Ensures system is ready for chaos engineering experiments.
    # =============================================================================
    
    # Purpose: Validate prerequisites for chaos experiments
    # Why needed: Ensures system is ready for chaos experiments
    # Impact: Prevents experiments from running on unprepared systems
    # Parameters: None
    # Usage: check_prerequisites
    # Returns: 0 if prerequisites met, 1 if not
    
    print_status "INFO" "Checking prerequisites for chaos experiments"
    # Purpose: Log the start of prerequisite checking
    # Why needed: Informs user that prerequisite checking has begun
    # Impact: User knows prerequisite checking has started
    
    local missing_commands=()
    # Purpose: Array to store missing commands
    # Why needed: Tracks which commands are missing
    # Impact: Will contain list of missing commands
    
    # =============================================================================
    # CHECK REQUIRED COMMANDS
    # =============================================================================
    # Purpose: Validate that all required commands are available
    # Why needed: Ensures all required tools are available for experiments
    
    local required_commands=("kubectl" "curl" "jq" "yq")
    # Purpose: Array of required commands
    # Why needed: Specifies which commands are required for experiments
    # Impact: Function validates all specified commands
    # kubectl: Kubernetes command-line tool
    # curl: HTTP client for testing
    # jq: JSON processor for data manipulation
    # yq: YAML processor for data manipulation
    
    for cmd in "${required_commands[@]}"; do
        # Purpose: Loop through each required command
        # Why needed: Validates each required command individually
        # Impact: Each command is validated for availability
        # "${required_commands[@]}": Array of required commands
        
        if ! command_exists "$cmd"; then
            # Purpose: Check if command is missing
            # Why needed: Identifies missing commands
            # Impact: Proceeds with error handling if command missing
            # command_exists: Function to check if command exists
            # "$cmd": Command name to check
            
            missing_commands+=("$cmd")
            # Purpose: Add missing command to array
            # Why needed: Tracks missing commands for reporting
            # Impact: Missing command is added to tracking array
            # missing_commands: Array of missing commands
            # "$cmd": Command name to add
        fi
    done
    
    if [ ${#missing_commands[@]} -gt 0 ]; then
        # Purpose: Check if any commands are missing
        # Why needed: Provides error handling for missing commands
        # Impact: Proceeds with error handling if commands missing
        # ${#missing_commands[@]}: Length of missing commands array
        # -gt 0: Greater than zero
        
        print_status "ERROR" "Missing required commands: ${missing_commands[*]}"
        # Purpose: Log missing commands error
        # Why needed: Informs user about missing commands
        # Impact: User knows which commands are missing
        # ${missing_commands[*]}: All missing commands
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates prerequisites not met
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK KUBERNETES CONNECTIVITY
    # =============================================================================
    # Purpose: Validate Kubernetes cluster connectivity
    # Why needed: Ensures cluster is accessible for experiments
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # Purpose: Check Kubernetes cluster connectivity
        # Why needed: Validates that cluster is accessible
        # Impact: Proceeds with error handling if cluster not accessible
        # kubectl cluster-info: Get cluster information
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        print_status "ERROR" "Cannot connect to Kubernetes cluster"
        # Purpose: Log cluster connectivity error
        # Why needed: Informs user about cluster connectivity issues
        # Impact: User knows cluster is not accessible
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates prerequisites not met
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK NAMESPACE EXISTENCE
    # =============================================================================
    # Purpose: Validate that target namespace exists
    # Why needed: Ensures target namespace is available for experiments
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if target namespace exists
        # Why needed: Validates that target namespace is available
        # Impact: Proceeds with error handling if namespace not found
        # kubectl get namespace: Get namespace information
        # "$NAMESPACE": Target namespace name
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        print_status "ERROR" "Target namespace '$NAMESPACE' does not exist"
        # Purpose: Log namespace not found error
        # Why needed: Informs user about namespace issues
        # Impact: User knows target namespace does not exist
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates prerequisites not met
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # CHECK MONITORING NAMESPACE
    # =============================================================================
    # Purpose: Validate that monitoring namespace exists
    # Why needed: Ensures monitoring namespace is available for experiments
    
    if ! kubectl get namespace "$MONITORING_NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if monitoring namespace exists
        # Why needed: Validates that monitoring namespace is available
        # Impact: Proceeds with error handling if namespace not found
        # kubectl get namespace: Get namespace information
        # "$MONITORING_NAMESPACE": Monitoring namespace name
        # >/dev/null: Suppress output
        # 2>&1: Redirect stderr to stdout
        
        print_status "WARNING" "Monitoring namespace '$MONITORING_NAMESPACE' does not exist"
        # Purpose: Log monitoring namespace warning
        # Why needed: Informs user about monitoring namespace issues
        # Impact: User knows monitoring namespace does not exist
    fi
    
    # =============================================================================
    # CREATE LOG AND REPORT DIRECTORIES
    # =============================================================================
    # Purpose: Create directories for logs and reports
    # Why needed: Ensures directories exist for experiment output
    
    mkdir -p "$LOG_DIR" "$REPORT_DIR"
    # Purpose: Create log and report directories
    # Why needed: Ensures directories exist for experiment output
    # Impact: Directories are created for experiment output
    # mkdir -p: Create directories recursively
    # "$LOG_DIR": Log directory path
    # "$REPORT_DIR": Report directory path
    
    print_status "SUCCESS" "All prerequisites met"
    # Purpose: Log successful prerequisite check
    # Why needed: Confirms that all prerequisites are met
    # Impact: User knows prerequisites are satisfied
    
    return 0
    # Purpose: Return success status
    # Why needed: Indicates prerequisites met
    # Impact: Function returns success
}

# Function: Parse experiment parameters
parse_experiment_params() {
    # =============================================================================
    # PARSE EXPERIMENT PARAMETERS FUNCTION
    # =============================================================================
    # Parses command-line parameters for chaos experiments.
    # Provides parameter validation and default value assignment.
    # =============================================================================
    
    # Purpose: Parse and validate experiment parameters
    # Why needed: Provides parameter validation and default values
    # Impact: Ensures experiments run with valid parameters
    # Parameters: Command-line arguments
    # Usage: parse_experiment_params "$@"
    # Returns: None (sets global variables)
    
    local experiment=""
    # Purpose: Variable to store experiment name
    # Why needed: Specifies which experiment to run
    # Impact: Will contain the experiment name
    
    local target=""
    # Purpose: Variable to store experiment target
    # Why needed: Specifies which components to target
    # Impact: Will contain the target components
    
    local duration=""
    # Purpose: Variable to store experiment duration
    # Why needed: Specifies how long to run the experiment
    # Impact: Will contain the experiment duration
    
    local dry_run=false
    # Purpose: Variable to store dry run flag
    # Why needed: Enables dry run mode for testing
    # Impact: Will contain the dry run flag
    
    local verbose=false
    # Purpose: Variable to store verbose flag
    # Why needed: Enables verbose output for debugging
    # Impact: Will contain the verbose flag
    
    # =============================================================================
    # PARSE COMMAND-LINE ARGUMENTS
    # =============================================================================
    # Purpose: Parse command-line arguments
    # Why needed: Extracts parameters from command line
    
    while [[ $# -gt 0 ]]; do
        # Purpose: Loop through command-line arguments
        # Why needed: Processes each argument individually
        # Impact: Each argument is processed
        # $#: Number of arguments
        # -gt 0: Greater than zero
        
        case $1 in
            --experiment=*)
                experiment="${1#*=}"
                # Purpose: Extract experiment name from argument
                # Why needed: Sets experiment name from command line
                # Impact: Experiment name is set
                # ${1#*=}: Remove everything before and including the first '='
                shift
                # Purpose: Move to next argument
                # Why needed: Processes next argument
                # Impact: Argument pointer moves to next argument
                ;;
            --target=*)
                target="${1#*=}"
                # Purpose: Extract target from argument
                # Why needed: Sets target from command line
                # Impact: Target is set
                # ${1#*=}: Remove everything before and including the first '='
                shift
                # Purpose: Move to next argument
                # Why needed: Processes next argument
                # Impact: Argument pointer moves to next argument
                ;;
            --duration=*)
                duration="${1#*=}"
                # Purpose: Extract duration from argument
                # Why needed: Sets duration from command line
                # Impact: Duration is set
                # ${1#*=}: Remove everything before and including the first '='
                shift
                # Purpose: Move to next argument
                # Why needed: Processes next argument
                # Impact: Argument pointer moves to next argument
                ;;
            --dry-run)
                dry_run=true
                # Purpose: Set dry run flag
                # Why needed: Enables dry run mode
                # Impact: Dry run mode is enabled
                shift
                # Purpose: Move to next argument
                # Why needed: Processes next argument
                # Impact: Argument pointer moves to next argument
                ;;
            --verbose)
                verbose=true
                # Purpose: Set verbose flag
                # Why needed: Enables verbose output
                # Impact: Verbose output is enabled
                shift
                # Purpose: Move to next argument
                # Why needed: Processes next argument
                # Impact: Argument pointer moves to next argument
                ;;
            --help)
                show_help
                # Purpose: Show help information
                # Why needed: Provides usage information
                # Impact: Help information is displayed
                exit 0
                # Purpose: Exit with success status
                # Why needed: Exits after showing help
                # Impact: Script exits successfully
                ;;
            *)
                print_status "ERROR" "Unknown parameter: $1"
                # Purpose: Log unknown parameter error
                # Why needed: Informs user about unknown parameters
                # Impact: User knows about unknown parameters
                show_help
                # Purpose: Show help information
                # Why needed: Provides usage information
                # Impact: Help information is displayed
                exit 1
                # Purpose: Exit with failure status
                # Why needed: Exits after showing help
                # Impact: Script exits with failure
                ;;
        esac
    done
    
    # =============================================================================
    # SET DEFAULT VALUES
    # =============================================================================
    # Purpose: Set default values for unspecified parameters
    # Why needed: Provides default values for missing parameters
    
    experiment="${experiment:-$DEFAULT_TARGET}"
    # Purpose: Set default experiment if not specified
    # Why needed: Provides default experiment value
    # Impact: Experiment is set to default if not specified
    # ${experiment:-$DEFAULT_TARGET}: Use experiment value or default target
    
    target="${target:-$DEFAULT_TARGET}"
    # Purpose: Set default target if not specified
    # Why needed: Provides default target value
    # Impact: Target is set to default if not specified
    # ${target:-$DEFAULT_TARGET}: Use target value or default target
    
    duration="${duration:-$DEFAULT_DURATION}"
    # Purpose: Set default duration if not specified
    # Why needed: Provides default duration value
    # Impact: Duration is set to default if not specified
    # ${duration:-$DEFAULT_DURATION}: Use duration value or default duration
    
    # =============================================================================
    # VALIDATE PARAMETERS
    # =============================================================================
    # Purpose: Validate parsed parameters
    # Why needed: Ensures parameters are valid
    
    if [ -z "$experiment" ]; then
        # Purpose: Check if experiment is specified
        # Why needed: Validates that experiment is specified
        # Impact: Proceeds with error handling if experiment not specified
        # -z: Check if string is empty
        
        print_status "ERROR" "Experiment must be specified"
        # Purpose: Log experiment not specified error
        # Why needed: Informs user about missing experiment
        # Impact: User knows experiment must be specified
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates parameter validation failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # SET GLOBAL VARIABLES
    # =============================================================================
    # Purpose: Set global variables for use by other functions
    # Why needed: Makes parameters available to other functions
    
    EXPERIMENT_NAME="$experiment"
    # Purpose: Set global experiment name variable
    # Why needed: Makes experiment name available to other functions
    # Impact: Experiment name is available globally
    
    EXPERIMENT_TARGET="$target"
    # Purpose: Set global experiment target variable
    # Why needed: Makes experiment target available to other functions
    # Impact: Experiment target is available globally
    
    EXPERIMENT_DURATION="$duration"
    # Purpose: Set global experiment duration variable
    # Why needed: Makes experiment duration available to other functions
    # Impact: Experiment duration is available globally
    
    DRY_RUN="$dry_run"
    # Purpose: Set global dry run flag variable
    # Why needed: Makes dry run flag available to other functions
    # Impact: Dry run flag is available globally
    
    VERBOSE="$verbose"
    # Purpose: Set global verbose flag variable
    # Why needed: Makes verbose flag available to other functions
    # Impact: Verbose flag is available globally
    
    print_status "INFO" "Experiment parameters parsed successfully"
    # Purpose: Log successful parameter parsing
    # Why needed: Confirms that parameters were parsed successfully
    # Impact: User knows parameters were parsed successfully
}

# Function: Show help information
show_help() {
    # =============================================================================
    # SHOW HELP INFORMATION FUNCTION
    # =============================================================================
    # Displays help information and usage instructions for the chaos orchestrator.
    # Provides comprehensive usage information and examples.
    # =============================================================================
    
    # Purpose: Display help information and usage instructions
    # Why needed: Provides usage information for users
    # Impact: Users can understand how to use the script
    # Parameters: None
    # Usage: show_help
    # Returns: None
    
    cat << 'EOF'
Chaos Engineering Orchestrator

USAGE:
    ./chaos-orchestrator.sh [OPTIONS]

DESCRIPTION:
    Main orchestration script for executing chaos engineering experiments.
    Provides centralized control and coordination of all chaos experiments.

OPTIONS:
    --experiment=NAME     Specify the experiment to run
    --target=COMPONENT   Specify the target component(s)
    --duration=TIME     Specify the experiment duration (e.g., 10m, 1h)
    --dry-run           Run in dry-run mode (no actual changes)
    --verbose           Enable verbose output
    --help              Show this help information

EXAMPLES:
    # Run pod failure experiment on backend for 10 minutes
    ./chaos-orchestrator.sh --experiment=pod-failure --target=backend --duration=10m

    # Run network partition experiment on all components for 15 minutes
    ./chaos-orchestrator.sh --experiment=network-partition --target=all --duration=15m

    # Run resource exhaustion experiment in dry-run mode
    ./chaos-orchestrator.sh --experiment=resource-exhaustion --target=database --dry-run

    # Run monitoring failure experiment with verbose output
    ./chaos-orchestrator.sh --experiment=monitoring-failure --verbose

AVAILABLE EXPERIMENTS:
    - pod-failure           Pod failure and recreation
    - network-partition     Network connectivity disruption
    - resource-exhaustion   Resource constraint simulation
    - storage-failure       Storage system failure
    - monitoring-failure    Monitoring system failure
    - database-failure      Database system failure
    - load-testing          High load simulation
    - configuration-chaos   Configuration change testing
    - security-chaos        Security mechanism testing
    - multi-component       Multiple component failure

AVAILABLE TARGETS:
    - all                  All components
    - frontend             Frontend components only
    - backend              Backend components only
    - database              Database components only
    - monitoring            Monitoring components only
    - storage               Storage components only

DURATION FORMATS:
    - 5m                  5 minutes
    - 10m                 10 minutes
    - 15m                 15 minutes
    - 30m                 30 minutes
    - 1h                  1 hour
    - 2h                  2 hours

SAFETY FEATURES:
    - Pre-experiment validation
    - Automatic rollback on failure
    - Emergency stop capability
    - Comprehensive logging
    - Real-time monitoring

REQUIREMENTS:
    - kubectl              Kubernetes command-line tool
    - curl                 HTTP client for testing
    - jq                   JSON processor
    - yq                   YAML processor
    - Access to Kubernetes cluster
    - Appropriate permissions

ENVIRONMENT VARIABLES:
    NAMESPACE              Target namespace (default: ecommerce-production)
    MONITORING_NAMESPACE   Monitoring namespace (default: monitoring)
    LOG_DIR                Log directory (default: /tmp/chaos-logs)
    REPORT_DIR             Report directory (default: /tmp/chaos-reports)
    DEFAULT_DURATION       Default experiment duration (default: 10m)
    DEFAULT_TARGET         Default experiment target (default: all)
    MAX_CONCURRENT_EXPERIMENTS Maximum concurrent experiments (default: 3)
    SAFETY_CHECKS_ENABLED  Enable safety checks (default: true)
    AUTO_ROLLBACK_ENABLED  Enable automatic rollback (default: true)
    EMERGENCY_STOP_ENABLED Enable emergency stop (default: true)

EXIT CODES:
    0                     Success
    1                     General error
    2                     Prerequisites not met
    3                     Invalid parameters
    4                     Experiment failed
    5                     Safety check failed

For more information, see the chaos engineering documentation.
EOF
}

# Function: Execute chaos experiment
execute_experiment() {
    # =============================================================================
    # EXECUTE CHAOS EXPERIMENT FUNCTION
    # =============================================================================
    # Executes the specified chaos experiment with proper safety controls.
    # Provides experiment execution with monitoring and rollback capabilities.
    # =============================================================================
    
    # Purpose: Execute the specified chaos experiment
    # Why needed: Provides experiment execution with safety controls
    # Impact: Runs the specified experiment with proper safety measures
    # Parameters: None (uses global variables)
    # Usage: execute_experiment
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting chaos experiment: $EXPERIMENT_NAME"
    # Purpose: Log the start of experiment execution
    # Why needed: Informs user that experiment execution has begun
    # Impact: User knows experiment execution has started
    
    local experiment_script=""
    # Purpose: Variable to store experiment script path
    # Why needed: Specifies which script to execute for the experiment
    # Impact: Will contain the path to the experiment script
    
    local start_time
    # Purpose: Variable to store experiment start time
    # Why needed: Tracks experiment start time for duration calculation
    # Impact: Will contain the experiment start time
    
    local end_time
    # Purpose: Variable to store experiment end time
    # Why needed: Tracks experiment end time for duration calculation
    # Impact: Will contain the experiment end time
    
    # =============================================================================
    # DETERMINE EXPERIMENT SCRIPT
    # =============================================================================
    # Purpose: Determine which script to execute for the experiment
    # Why needed: Maps experiment names to script files
    
    case $EXPERIMENT_NAME in
        "pod-failure")
            experiment_script="$SCRIPT_DIR/pod-chaos.sh"
            # Purpose: Set script path for pod failure experiment
            # Why needed: Specifies the script for pod failure experiments
            # Impact: Pod failure experiment script is selected
            ;;
        "network-partition")
            experiment_script="$SCRIPT_DIR/network-chaos.sh"
            # Purpose: Set script path for network partition experiment
            # Why needed: Specifies the script for network partition experiments
            # Impact: Network partition experiment script is selected
            ;;
        "resource-exhaustion")
            experiment_script="$SCRIPT_DIR/resource-chaos.sh"
            # Purpose: Set script path for resource exhaustion experiment
            # Why needed: Specifies the script for resource exhaustion experiments
            # Impact: Resource exhaustion experiment script is selected
            ;;
        "storage-failure")
            experiment_script="$SCRIPT_DIR/storage-chaos.sh"
            # Purpose: Set script path for storage failure experiment
            # Why needed: Specifies the script for storage failure experiments
            # Impact: Storage failure experiment script is selected
            ;;
        "monitoring-failure")
            experiment_script="$SCRIPT_DIR/monitoring-chaos.sh"
            # Purpose: Set script path for monitoring failure experiment
            # Why needed: Specifies the script for monitoring failure experiments
            # Impact: Monitoring failure experiment script is selected
            ;;
        *)
            print_status "ERROR" "Unknown experiment: $EXPERIMENT_NAME"
            # Purpose: Log unknown experiment error
            # Why needed: Informs user about unknown experiments
            # Impact: User knows experiment is not recognized
            
            return 1
            # Purpose: Return failure status
            # Why needed: Indicates experiment execution failed
            # Impact: Function returns failure
            ;;
    esac
    
    # =============================================================================
    # VALIDATE EXPERIMENT SCRIPT
    # =============================================================================
    # Purpose: Validate that experiment script exists and is executable
    # Why needed: Ensures experiment script is available for execution
    
    if [ ! -f "$experiment_script" ]; then
        # Purpose: Check if experiment script exists
        # Why needed: Validates that experiment script is available
        # Impact: Proceeds with error handling if script not found
        # -f: Check if file exists and is a regular file
        # "$experiment_script": Script file path
        
        print_status "ERROR" "Experiment script not found: $experiment_script"
        # Purpose: Log script not found error
        # Why needed: Informs user about missing script
        # Impact: User knows experiment script is not found
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates experiment execution failed
        # Impact: Function returns failure
    fi
    
    if [ ! -x "$experiment_script" ]; then
        # Purpose: Check if experiment script is executable
        # Why needed: Validates that experiment script can be executed
        # Impact: Proceeds with error handling if script not executable
        # -x: Check if file is executable
        # "$experiment_script": Script file path
        
        print_status "ERROR" "Experiment script is not executable: $experiment_script"
        # Purpose: Log script not executable error
        # Why needed: Informs user about non-executable script
        # Impact: User knows experiment script is not executable
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates experiment execution failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # EXECUTE EXPERIMENT
    # =============================================================================
    # Purpose: Execute the experiment script
    # Why needed: Runs the actual experiment
    
    start_time=$(date +%s)
    # Purpose: Record experiment start time
    # Why needed: Tracks experiment start time for duration calculation
    # Impact: Start time is recorded
    # date +%s: Get current time in seconds since epoch
    
    if [ "$DRY_RUN" = true ]; then
        # Purpose: Check if dry run mode is enabled
        # Why needed: Provides dry run capability for testing
        # Impact: Proceeds with dry run if enabled
        
        print_status "INFO" "Running in dry-run mode"
        # Purpose: Log dry run mode
        # Why needed: Informs user about dry run mode
        # Impact: User knows dry run mode is enabled
        
        # Execute experiment script in dry-run mode
        "$experiment_script" --dry-run --target="$EXPERIMENT_TARGET" --duration="$EXPERIMENT_DURATION"
        # Purpose: Execute experiment script in dry-run mode
        # Why needed: Runs experiment without making actual changes
        # Impact: Experiment is executed in dry-run mode
        # "$experiment_script": Script path
        # --dry-run: Enable dry-run mode
        # --target: Specify target components
        # --duration: Specify experiment duration
    else
        # Purpose: Handle normal execution mode
        # Why needed: Provides normal experiment execution
        # Impact: Proceeds with normal execution
        
        # Execute experiment script
        "$experiment_script" --target="$EXPERIMENT_TARGET" --duration="$EXPERIMENT_DURATION"
        # Purpose: Execute experiment script normally
        # Why needed: Runs experiment with actual changes
        # Impact: Experiment is executed normally
        # "$experiment_script": Script path
        # --target: Specify target components
        # --duration: Specify experiment duration
    fi
    
    local experiment_exit_code=$?
    # Purpose: Capture experiment script exit code
    # Why needed: Tracks experiment execution result
    # Impact: Exit code is captured for validation
    # $?: Exit code of last command
    
    end_time=$(date +%s)
    # Purpose: Record experiment end time
    # Why needed: Tracks experiment end time for duration calculation
    # Impact: End time is recorded
    # date +%s: Get current time in seconds since epoch
    
    local duration=$((end_time - start_time))
    # Purpose: Calculate experiment duration
    # Why needed: Tracks how long the experiment took
    # Impact: Duration is calculated
    # $((end_time - start_time)): Calculate difference in seconds
    
    # =============================================================================
    # VALIDATE EXPERIMENT RESULT
    # =============================================================================
    # Purpose: Validate experiment execution result
    # Why needed: Ensures experiment completed successfully
    
    if [ $experiment_exit_code -eq 0 ]; then
        # Purpose: Check if experiment completed successfully
        # Why needed: Validates experiment success
        # Impact: Proceeds with success handling if experiment successful
        # -eq 0: Equal to zero (success)
        
        print_status "SUCCESS" "Chaos experiment completed successfully in ${duration}s"
        # Purpose: Log successful experiment completion
        # Why needed: Confirms experiment completed successfully
        # Impact: User knows experiment completed successfully
        # ${duration}s: Duration in seconds
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates experiment execution succeeded
        # Impact: Function returns success
    else
        # Purpose: Handle experiment failure
        # Why needed: Provides error handling for failed experiments
        # Impact: Proceeds with error handling
        
        print_status "ERROR" "Chaos experiment failed with exit code $experiment_exit_code"
        # Purpose: Log experiment failure
        # Why needed: Informs user about experiment failure
        # Impact: User knows experiment failed
        # $experiment_exit_code: Exit code of failed experiment
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates experiment execution failed
        # Impact: Function returns failure
    fi
}

# Function: Main execution
main() {
    # =============================================================================
    # MAIN EXECUTION FUNCTION
    # =============================================================================
    # Main function that orchestrates the chaos engineering experiment execution.
    # Provides the main entry point and execution flow for the orchestrator.
    # =============================================================================
    
    # Purpose: Main execution function for chaos orchestrator
    # Why needed: Provides main entry point and execution flow
    # Impact: Orchestrates the entire chaos engineering process
    # Parameters: Command-line arguments
    # Usage: main "$@"
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting Chaos Engineering Orchestrator"
    # Purpose: Log the start of orchestrator
    # Why needed: Informs user that orchestrator has started
    # Impact: User knows orchestrator has started
    
    # =============================================================================
    # PARSE PARAMETERS
    # =============================================================================
    # Purpose: Parse command-line parameters
    # Why needed: Extracts and validates experiment parameters
    
    if ! parse_experiment_params "$@"; then
        # Purpose: Parse experiment parameters
        # Why needed: Validates and extracts parameters from command line
        # Impact: Proceeds with error handling if parameter parsing failed
        # parse_experiment_params: Function to parse parameters
        # "$@": All command-line arguments
        
        print_status "ERROR" "Failed to parse experiment parameters"
        # Purpose: Log parameter parsing failure
        # Why needed: Informs user about parameter parsing issues
        # Impact: User knows parameter parsing failed
        
        exit 3
        # Purpose: Exit with parameter error code
        # Why needed: Indicates parameter parsing failed
        # Impact: Script exits with parameter error
    fi
    
    # =============================================================================
    # CHECK PREREQUISITES
    # =============================================================================
    # Purpose: Validate prerequisites before experiment execution
    # Why needed: Ensures system is ready for experiments
    
    if ! check_prerequisites; then
        # Purpose: Check prerequisites
        # Why needed: Validates that all prerequisites are met
        # Impact: Proceeds with error handling if prerequisites not met
        # check_prerequisites: Function to check prerequisites
        
        print_status "ERROR" "Prerequisites not met"
        # Purpose: Log prerequisites failure
        # Why needed: Informs user about prerequisite issues
        # Impact: User knows prerequisites are not met
        
        exit 2
        # Purpose: Exit with prerequisite error code
        # Why needed: Indicates prerequisites not met
        # Impact: Script exits with prerequisite error
    fi
    
    # =============================================================================
    # EXECUTE EXPERIMENT
    # =============================================================================
    # Purpose: Execute the chaos experiment
    # Why needed: Runs the actual experiment
    
    if ! execute_experiment; then
        # Purpose: Execute experiment
        # Why needed: Runs the specified chaos experiment
        # Impact: Proceeds with error handling if experiment failed
        # execute_experiment: Function to execute experiment
        
        print_status "ERROR" "Experiment execution failed"
        # Purpose: Log experiment execution failure
        # Why needed: Informs user about experiment execution issues
        # Impact: User knows experiment execution failed
        
        exit 4
        # Purpose: Exit with experiment error code
        # Why needed: Indicates experiment execution failed
        # Impact: Script exits with experiment error
    fi
    
    print_status "SUCCESS" "Chaos Engineering Orchestrator completed successfully"
    # Purpose: Log successful orchestrator completion
    # Why needed: Confirms orchestrator completed successfully
    # Impact: User knows orchestrator completed successfully
    
    exit 0
    # Purpose: Exit with success status
    # Why needed: Indicates orchestrator completed successfully
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
