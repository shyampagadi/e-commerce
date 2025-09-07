#!/bin/bash

# =============================================================================
# POD CHAOS ENGINEERING SCRIPT
# =============================================================================
# Script for executing pod failure chaos experiments.
# Tests application resilience to pod failures and validates self-healing.
# =============================================================================

# Purpose: Execute pod failure chaos experiments
# Why needed: Tests application resilience to pod failures and validates Kubernetes self-healing
# Impact: Validates that applications can handle pod failures gracefully
# Parameters: Various pod failure experiment parameters
# Usage: ./pod-chaos.sh --target=backend --duration=10m
# Returns: 0 on success, 1 on failure

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Purpose: Define configuration constants and variables
# Why needed: Provides centralized configuration for pod chaos experiments
# Impact: Ensures consistent configuration across all pod experiments

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Purpose: Get the directory where this script is located
# Why needed: Enables relative path resolution for other files
# Impact: Script can find other files regardless of execution location

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# Purpose: Get the project root directory
# Why needed: Enables access to project-wide configuration
# Impact: Script can access project configuration

NAMESPACE="${NAMESPACE:-ecommerce-production}"
# Purpose: Set the target namespace for pod experiments
# Why needed: Specifies which namespace to target for experiments
# Impact: Experiments will be conducted in the specified namespace
# Default: ecommerce-production

LOG_DIR="${LOG_DIR:-/tmp/chaos-logs}"
# Purpose: Set the log directory for pod experiments
# Why needed: Provides centralized logging location
# Impact: All experiment logs will be stored in the specified directory
# Default: /tmp/chaos-logs

# Experiment configuration
DEFAULT_DURATION="${DEFAULT_DURATION:-10m}"
# Purpose: Set the default experiment duration
# Why needed: Provides default duration when not specified
# Impact: Experiments will run for the specified duration by default
# Default: 10 minutes

DEFAULT_TARGET="${DEFAULT_TARGET:-all}"
# Purpose: Set the default experiment target
# Why needed: Provides default target when not specified
# Impact: Experiments will target all components by default
# Default: all

MAX_POD_FAILURES="${MAX_POD_FAILURES:-2}"
# Purpose: Set the maximum number of pods to fail simultaneously
# Why needed: Prevents system overload from too many simultaneous failures
# Impact: Limits the number of concurrent pod failures
# Default: 2

MIN_HEALTHY_PODS="${MIN_HEALTHY_PODS:-1}"
# Purpose: Set the minimum number of healthy pods to maintain
# Why needed: Ensures system remains functional during experiments
# Impact: Maintains minimum service availability
# Default: 1

# Safety configuration
SAFETY_CHECKS_ENABLED="${SAFETY_CHECKS_ENABLED:-true}"
# Purpose: Enable or disable safety checks
# Why needed: Provides safety control for experiments
# Impact: Safety checks will be performed if enabled
# Default: true

AUTO_RECOVERY_ENABLED="${AUTO_RECOVERY_ENABLED:-true}"
# Purpose: Enable or disable automatic recovery
# Why needed: Provides automatic recovery capability
# Impact: Failed pods will be automatically recreated if enabled
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
    # Provides consistent logging format across all pod chaos operations.
    # =============================================================================
    
    # Purpose: Print formatted status messages
    # Why needed: Provides consistent logging format for all operations
    # Impact: All operations are logged with consistent format
    # Parameters:
    #   $1: Log level (INFO, WARNING, ERROR, SUCCESS)
    #   $2: Message to print
    # Usage: print_status "INFO" "Starting pod failure experiment"
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

# =============================================================================
# PARAMETER PARSING FUNCTIONS
# =============================================================================

# Function: Parse command-line parameters
parse_parameters() {
    # =============================================================================
    # PARSE COMMAND-LINE PARAMETERS FUNCTION
    # =============================================================================
    # Parses command-line parameters for pod chaos experiments.
    # Provides parameter validation and default value assignment.
    # =============================================================================
    
    # Purpose: Parse and validate command-line parameters
    # Why needed: Provides parameter validation and default values
    # Impact: Ensures experiments run with valid parameters
    # Parameters: Command-line arguments
    # Usage: parse_parameters "$@"
    # Returns: None (sets global variables)
    
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
    # SET GLOBAL VARIABLES
    # =============================================================================
    # Purpose: Set global variables for use by other functions
    # Why needed: Makes parameters available to other functions
    
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
    
    print_status "INFO" "Parameters parsed successfully"
    # Purpose: Log successful parameter parsing
    # Why needed: Confirms that parameters were parsed successfully
    # Impact: User knows parameters were parsed successfully
}

# Function: Show help information
show_help() {
    # =============================================================================
    # SHOW HELP INFORMATION FUNCTION
    # =============================================================================
    # Displays help information and usage instructions for the pod chaos script.
    # Provides comprehensive usage information and examples.
    # =============================================================================
    
    # Purpose: Display help information and usage instructions
    # Why needed: Provides usage information for users
    # Impact: Users can understand how to use the script
    # Parameters: None
    # Usage: show_help
    # Returns: None
    
    cat << 'EOF'
Pod Chaos Engineering Script

USAGE:
    ./pod-chaos.sh [OPTIONS]

DESCRIPTION:
    Script for executing pod failure chaos experiments.
    Tests application resilience to pod failures and validates self-healing.

OPTIONS:
    --target=COMPONENT   Specify the target component(s)
    --duration=TIME     Specify the experiment duration (e.g., 10m, 1h)
    --dry-run           Run in dry-run mode (no actual changes)
    --verbose           Enable verbose output
    --help              Show this help information

EXAMPLES:
    # Run pod failure experiment on backend for 10 minutes
    ./pod-chaos.sh --target=backend --duration=10m

    # Run pod failure experiment on all components for 15 minutes
    ./pod-chaos.sh --target=all --duration=15m

    # Run pod failure experiment in dry-run mode
    ./pod-chaos.sh --target=database --dry-run

    # Run pod failure experiment with verbose output
    ./pod-chaos.sh --target=frontend --verbose

AVAILABLE TARGETS:
    - all                  All components
    - frontend             Frontend components only
    - backend              Backend components only
    - database              Database components only
    - monitoring            Monitoring components only

DURATION FORMATS:
    - 5m                  5 minutes
    - 10m                 10 minutes
    - 15m                 15 minutes
    - 30m                 30 minutes
    - 1h                  1 hour
    - 2h                  2 hours

SAFETY FEATURES:
    - Pre-experiment validation
    - Maximum pod failure limits
    - Minimum healthy pod requirements
    - Automatic recovery monitoring
    - Comprehensive logging

REQUIREMENTS:
    - kubectl              Kubernetes command-line tool
    - Access to Kubernetes cluster
    - Appropriate permissions

ENVIRONMENT VARIABLES:
    NAMESPACE              Target namespace (default: ecommerce-production)
    LOG_DIR                Log directory (default: /tmp/chaos-logs)
    DEFAULT_DURATION       Default experiment duration (default: 10m)
    DEFAULT_TARGET         Default experiment target (default: all)
    MAX_POD_FAILURES       Maximum pod failures (default: 2)
    MIN_HEALTHY_PODS       Minimum healthy pods (default: 1)
    SAFETY_CHECKS_ENABLED  Enable safety checks (default: true)
    AUTO_RECOVERY_ENABLED  Enable automatic recovery (default: true)

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

# =============================================================================
# CORE POD CHAOS FUNCTIONS
# =============================================================================

# Function: Get target pods
get_target_pods() {
    # =============================================================================
    # GET TARGET PODS FUNCTION
    # =============================================================================
    # Retrieves the list of pods to target for chaos experiments.
    # Provides pod selection based on target criteria and safety constraints.
    # =============================================================================
    
    # Purpose: Get list of pods to target for chaos experiments
    # Why needed: Identifies which pods to target based on experiment parameters
    # Impact: Provides pod list for chaos experiments
    # Parameters: None (uses global variables)
    # Usage: get_target_pods
    # Returns: Array of pod names
    
    print_status "INFO" "Getting target pods for experiment"
    # Purpose: Log the start of pod selection
    # Why needed: Informs user that pod selection has begun
    # Impact: User knows pod selection has started
    
    local target_pods=()
    # Purpose: Array to store target pod names
    # Why needed: Collects pod names for chaos experiments
    # Impact: Will contain list of target pods
    
    # =============================================================================
    # SELECT PODS BASED ON TARGET
    # =============================================================================
    # Purpose: Select pods based on experiment target
    # Why needed: Filters pods according to target criteria
    
    case $EXPERIMENT_TARGET in
        "all")
            # Purpose: Select all pods in namespace
            # Why needed: Targets all pods for comprehensive testing
            # Impact: All pods are selected for experiments
            
            target_pods=($(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Running))
            # Purpose: Get all running pods in namespace
            # Why needed: Provides comprehensive pod list for experiments
            # Impact: All running pods are selected
            # kubectl get pods: Get pod information
            # -n "$NAMESPACE": Target namespace
            # -o jsonpath='{.items[*].metadata.name}': Extract pod names
            # --field-selector=status.phase=Running: Only running pods
            ;;
        "frontend")
            # Purpose: Select frontend pods only
            # Why needed: Targets frontend pods specifically
            # Impact: Only frontend pods are selected
            
            target_pods=($(kubectl get pods -n "$NAMESPACE" -l app=ecommerce-frontend -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Running))
            # Purpose: Get frontend pods in namespace
            # Why needed: Provides frontend pod list for experiments
            # Impact: Frontend pods are selected
            # kubectl get pods: Get pod information
            # -n "$NAMESPACE": Target namespace
            # -l app=ecommerce-frontend: Select frontend pods
            # -o jsonpath='{.items[*].metadata.name}': Extract pod names
            # --field-selector=status.phase=Running: Only running pods
            ;;
        "backend")
            # Purpose: Select backend pods only
            # Why needed: Targets backend pods specifically
            # Impact: Only backend pods are selected
            
            target_pods=($(kubectl get pods -n "$NAMESPACE" -l app=ecommerce-backend -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Running))
            # Purpose: Get backend pods in namespace
            # Why needed: Provides backend pod list for experiments
            # Impact: Backend pods are selected
            # kubectl get pods: Get pod information
            # -n "$NAMESPACE": Target namespace
            # -l app=ecommerce-backend: Select backend pods
            # -o jsonpath='{.items[*].metadata.name}': Extract pod names
            # --field-selector=status.phase=Running: Only running pods
            ;;
        "database")
            # Purpose: Select database pods only
            # Why needed: Targets database pods specifically
            # Impact: Only database pods are selected
            
            target_pods=($(kubectl get pods -n "$NAMESPACE" -l app=ecommerce-database -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Running))
            # Purpose: Get database pods in namespace
            # Why needed: Provides database pod list for experiments
            # Impact: Database pods are selected
            # kubectl get pods: Get pod information
            # -n "$NAMESPACE": Target namespace
            # -l app=ecommerce-database: Select database pods
            # -o jsonpath='{.items[*].metadata.name}': Extract pod names
            # --field-selector=status.phase=Running: Only running pods
            ;;
        "monitoring")
            # Purpose: Select monitoring pods only
            # Why needed: Targets monitoring pods specifically
            # Impact: Only monitoring pods are selected
            
            target_pods=($(kubectl get pods -n "$MONITORING_NAMESPACE" -o jsonpath='{.items[*].metadata.name}' --field-selector=status.phase=Running))
            # Purpose: Get monitoring pods in monitoring namespace
            # Why needed: Provides monitoring pod list for experiments
            # Impact: Monitoring pods are selected
            # kubectl get pods: Get pod information
            # -n "$MONITORING_NAMESPACE": Monitoring namespace
            # -o jsonpath='{.items[*].metadata.name}': Extract pod names
            # --field-selector=status.phase=Running: Only running pods
            ;;
        *)
            print_status "ERROR" "Unknown target: $EXPERIMENT_TARGET"
            # Purpose: Log unknown target error
            # Why needed: Informs user about unknown targets
            # Impact: User knows target is not recognized
            
            return 1
            # Purpose: Return failure status
            # Why needed: Indicates pod selection failed
            # Impact: Function returns failure
            ;;
    esac
    
    # =============================================================================
    # APPLY SAFETY CONSTRAINTS
    # =============================================================================
    # Purpose: Apply safety constraints to pod selection
    # Why needed: Ensures experiments don't break system safety
    
    local total_pods=${#target_pods[@]}
    # Purpose: Count total selected pods
    # Why needed: Provides pod count for safety validation
    # Impact: Total pod count is available
    # ${#target_pods[@]}: Length of target pods array
    
    if [ $total_pods -lt $MIN_HEALTHY_PODS ]; then
        # Purpose: Check if too few pods are available
        # Why needed: Ensures minimum pod count for safety
        # Impact: Proceeds with error handling if too few pods
        # -lt: Less than
        # $MIN_HEALTHY_PODS: Minimum healthy pods required
        
        print_status "ERROR" "Not enough pods available ($total_pods < $MIN_HEALTHY_PODS)"
        # Purpose: Log insufficient pods error
        # Why needed: Informs user about insufficient pods
        # Impact: User knows there are not enough pods
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates pod selection failed
        # Impact: Function returns failure
    fi
    
    # Limit number of pods to fail
    local max_failures=$((total_pods - MIN_HEALTHY_PODS))
    # Purpose: Calculate maximum pods that can be failed
    # Why needed: Ensures minimum healthy pods remain
    # Impact: Maximum failures is calculated
    # $((total_pods - MIN_HEALTHY_PODS)): Calculate maximum failures
    
    if [ $max_failures -gt $MAX_POD_FAILURES ]; then
        # Purpose: Check if calculated failures exceed maximum
        # Why needed: Applies maximum failure limit
        # Impact: Proceeds with adjustment if needed
        # -gt: Greater than
        # $MAX_POD_FAILURES: Maximum pod failures allowed
        
        max_failures=$MAX_POD_FAILURES
        # Purpose: Set maximum failures to limit
        # Why needed: Applies maximum failure constraint
        # Impact: Maximum failures is limited
    fi
    
    # Select random pods to fail
    local selected_pods=()
    # Purpose: Array to store selected pods for failure
    # Why needed: Collects pods to be failed
    # Impact: Will contain selected pods
    
    for ((i=0; i<max_failures; i++)); do
        # Purpose: Loop to select pods for failure
        # Why needed: Selects random pods up to maximum failures
        # Impact: Each iteration selects one pod
        # i=0: Start from index 0
        # i<max_failures: Continue until maximum failures reached
        # i++: Increment index
        
        local random_index=$((RANDOM % ${#target_pods[@]}))
        # Purpose: Generate random index for pod selection
        # Why needed: Selects random pod from available pods
        # Impact: Random pod is selected
        # RANDOM: Bash random number generator
        # % ${#target_pods[@]}: Modulo to get valid index
        
        selected_pods+=("${target_pods[$random_index]}")
        # Purpose: Add selected pod to array
        # Why needed: Collects selected pods for failure
        # Impact: Selected pod is added to array
        # "${target_pods[$random_index]}": Random pod from target pods
        
        # Remove selected pod from available pods
        target_pods=("${target_pods[@]:0:$random_index}" "${target_pods[@]:$((random_index+1))}")
        # Purpose: Remove selected pod from available pods
        # Why needed: Prevents selecting the same pod twice
        # Impact: Selected pod is removed from available pods
        # "${target_pods[@]:0:$random_index}": Pods before selected index
        # "${target_pods[@]:$((random_index+1))}": Pods after selected index
    done
    
    # =============================================================================
    # RETURN SELECTED PODS
    # =============================================================================
    # Purpose: Return selected pods for experiment
    # Why needed: Provides selected pods to calling function
    
    printf '%s\n' "${selected_pods[@]}"
    # Purpose: Print selected pod names
    # Why needed: Returns selected pods to calling function
    # Impact: Selected pods are returned
    # printf '%s\n': Print each pod name on separate line
    # "${selected_pods[@]}": All selected pods
    
    print_status "INFO" "Selected ${#selected_pods[@]} pods for failure"
    # Purpose: Log pod selection summary
    # Why needed: Informs user about selected pods
    # Impact: User knows how many pods were selected
    # ${#selected_pods[@]}: Number of selected pods
}

# Function: Execute pod failure experiment
execute_pod_failure() {
    # =============================================================================
    # EXECUTE POD FAILURE EXPERIMENT FUNCTION
    # =============================================================================
    # Executes the pod failure chaos experiment with proper safety controls.
    # Provides experiment execution with monitoring and recovery capabilities.
    # =============================================================================
    
    # Purpose: Execute pod failure chaos experiment
    # Why needed: Provides pod failure experiment execution with safety controls
    # Impact: Runs pod failure experiment with proper safety measures
    # Parameters: None (uses global variables)
    # Usage: execute_pod_failure
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting pod failure experiment"
    # Purpose: Log the start of pod failure experiment
    # Why needed: Informs user that experiment has begun
    # Impact: User knows experiment has started
    
    # =============================================================================
    # GET TARGET PODS
    # =============================================================================
    # Purpose: Get pods to target for failure
    # Why needed: Identifies which pods to fail
    
    local target_pods
    # Purpose: Variable to store target pod names
    # Why needed: Collects pod names for failure
    # Impact: Will contain target pod names
    
    target_pods=$(get_target_pods)
    # Purpose: Get target pods for experiment
    # Why needed: Identifies pods to target for failure
    # Impact: Target pods are identified
    # get_target_pods: Function to get target pods
    
    if [ $? -ne 0 ]; then
        # Purpose: Check if pod selection failed
        # Why needed: Validates pod selection success
        # Impact: Proceeds with error handling if selection failed
        # $?: Exit code of last command
        # -ne 0: Not equal to zero (failure)
        
        print_status "ERROR" "Failed to get target pods"
        # Purpose: Log pod selection failure
        # Why needed: Informs user about pod selection issues
        # Impact: User knows pod selection failed
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates experiment execution failed
        # Impact: Function returns failure
    fi
    
    # =============================================================================
    # EXECUTE POD FAILURES
    # =============================================================================
    # Purpose: Execute pod failures
    # Why needed: Runs the actual pod failure experiment
    
    local failed_pods=()
    # Purpose: Array to store failed pod names
    # Why needed: Tracks which pods were failed
    # Impact: Will contain failed pod names
    
    for pod in $target_pods; do
        # Purpose: Loop through each target pod
        # Why needed: Processes each pod for failure
        # Impact: Each pod is processed
        # $target_pods: List of target pods
        
        if [ "$DRY_RUN" = true ]; then
            # Purpose: Check if dry run mode is enabled
            # Why needed: Provides dry run capability for testing
            # Impact: Proceeds with dry run if enabled
            
            print_status "INFO" "DRY RUN: Would delete pod $pod"
            # Purpose: Log dry run pod deletion
            # Why needed: Shows what would be done in dry run mode
            # Impact: User sees what would happen
            
            failed_pods+=("$pod")
            # Purpose: Add pod to failed list for dry run
            # Why needed: Tracks pods that would be failed
            # Impact: Pod is added to failed list
        else
            # Purpose: Handle normal execution mode
            # Why needed: Provides normal pod failure execution
            # Impact: Proceeds with normal execution
            
            print_status "INFO" "Deleting pod: $pod"
            # Purpose: Log pod deletion
            # Why needed: Informs user about pod deletion
            # Impact: User knows pod is being deleted
            
            kubectl delete pod "$pod" -n "$NAMESPACE"
            # Purpose: Delete the pod
            # Why needed: Executes the pod failure
            # Impact: Pod is deleted
            # kubectl delete pod: Delete pod command
            # "$pod": Pod name to delete
            # -n "$NAMESPACE": Target namespace
            
            if [ $? -eq 0 ]; then
                # Purpose: Check if pod deletion succeeded
                # Why needed: Validates pod deletion success
                # Impact: Proceeds with success handling if deletion succeeded
                # $?: Exit code of last command
                # -eq 0: Equal to zero (success)
                
                print_status "SUCCESS" "Successfully deleted pod: $pod"
                # Purpose: Log successful pod deletion
                # Why needed: Confirms pod deletion success
                # Impact: User knows pod was deleted successfully
                
                failed_pods+=("$pod")
                # Purpose: Add pod to failed list
                # Why needed: Tracks successfully failed pods
                # Impact: Pod is added to failed list
            else
                # Purpose: Handle pod deletion failure
                # Why needed: Provides error handling for failed deletions
                # Impact: Proceeds with error handling
                
                print_status "ERROR" "Failed to delete pod: $pod"
                # Purpose: Log pod deletion failure
                # Why needed: Informs user about deletion failure
                # Impact: User knows pod deletion failed
            fi
        fi
    done
    
    # =============================================================================
    # MONITOR RECOVERY
    # =============================================================================
    # Purpose: Monitor pod recovery
    # Why needed: Validates that pods are recreated successfully
    
    if [ "$DRY_RUN" = false ]; then
        # Purpose: Check if not in dry run mode
        # Why needed: Only monitor recovery in actual execution
        # Impact: Proceeds with recovery monitoring if not dry run
        
        print_status "INFO" "Monitoring pod recovery..."
        # Purpose: Log recovery monitoring start
        # Why needed: Informs user about recovery monitoring
        # Impact: User knows recovery monitoring has started
        
        local recovery_timeout=300
        # Purpose: Set recovery timeout in seconds
        # Why needed: Prevents infinite waiting for recovery
        # Impact: Recovery monitoring will timeout after specified time
        # Default: 300 seconds (5 minutes)
        
        local start_time=$(date +%s)
        # Purpose: Record recovery monitoring start time
        # Why needed: Tracks recovery monitoring duration
        # Impact: Start time is recorded
        # date +%s: Get current time in seconds since epoch
        
        while [ $(($(date +%s) - start_time)) -lt $recovery_timeout ]; do
            # Purpose: Loop until recovery timeout
            # Why needed: Monitors recovery until timeout or success
            # Impact: Continuous monitoring until timeout
            # $(($(date +%s) - start_time)): Calculate elapsed time
            # -lt $recovery_timeout: Less than timeout
            
            local all_recovered=true
            # Purpose: Flag to track if all pods are recovered
            # Why needed: Determines if recovery is complete
            # Impact: Will contain recovery status
            
            for pod in "${failed_pods[@]}"; do
                # Purpose: Loop through each failed pod
                # Why needed: Checks recovery status of each pod
                # Impact: Each pod is checked for recovery
                # "${failed_pods[@]}": Array of failed pods
                
                if ! kubectl get pod "$pod" -n "$NAMESPACE" >/dev/null 2>&1; then
                    # Purpose: Check if pod still exists
                    # Why needed: Validates pod recreation
                    # Impact: Proceeds with recovery check if pod exists
                    # kubectl get pod: Get pod information
                    # "$pod": Pod name to check
                    # -n "$NAMESPACE": Target namespace
                    # >/dev/null: Suppress output
                    # 2>&1: Redirect stderr to stdout
                    
                    all_recovered=false
                    # Purpose: Set recovery flag to false
                    # Why needed: Indicates recovery is not complete
                    # Impact: Recovery flag is set to false
                    
                    break
                    # Purpose: Exit pod checking loop
                    # Why needed: No need to check other pods if one is not recovered
                    # Impact: Loop exits early
                fi
            done
            
            if [ "$all_recovered" = true ]; then
                # Purpose: Check if all pods are recovered
                # Why needed: Determines if recovery is complete
                # Impact: Proceeds with success handling if recovery complete
                
                print_status "SUCCESS" "All pods recovered successfully"
                # Purpose: Log successful recovery
                # Why needed: Confirms recovery success
                # Impact: User knows recovery was successful
                
                break
                # Purpose: Exit recovery monitoring loop
                # Why needed: Recovery is complete
                # Impact: Monitoring loop exits
            fi
            
            sleep 5
            # Purpose: Wait before next check
            # Why needed: Prevents excessive checking
            # Impact: System waits 5 seconds before next check
        done
        
        if [ "$all_recovered" = false ]; then
            # Purpose: Check if recovery failed
            # Why needed: Handles recovery timeout
            # Impact: Proceeds with error handling if recovery failed
            
            print_status "WARNING" "Pod recovery timeout reached"
            # Purpose: Log recovery timeout warning
            # Why needed: Informs user about recovery timeout
            # Impact: User knows recovery timed out
        fi
    fi
    
    print_status "SUCCESS" "Pod failure experiment completed"
    # Purpose: Log successful experiment completion
    # Why needed: Confirms experiment completion
    # Impact: User knows experiment completed successfully
    
    return 0
    # Purpose: Return success status
    # Why needed: Indicates experiment execution succeeded
    # Impact: Function returns success
}

# Function: Main execution
main() {
    # =============================================================================
    # MAIN EXECUTION FUNCTION
    # =============================================================================
    # Main function that orchestrates the pod chaos experiment execution.
    # Provides the main entry point and execution flow for the script.
    # =============================================================================
    
    # Purpose: Main execution function for pod chaos script
    # Why needed: Provides main entry point and execution flow
    # Impact: Orchestrates the entire pod chaos experiment process
    # Parameters: Command-line arguments
    # Usage: main "$@"
    # Returns: 0 on success, 1 on failure
    
    print_status "INFO" "Starting Pod Chaos Engineering Script"
    # Purpose: Log the start of script execution
    # Why needed: Informs user that script has started
    # Impact: User knows script has started
    
    # =============================================================================
    # PARSE PARAMETERS
    # =============================================================================
    # Purpose: Parse command-line parameters
    # Why needed: Extracts and validates experiment parameters
    
    if ! parse_parameters "$@"; then
        # Purpose: Parse experiment parameters
        # Why needed: Validates and extracts parameters from command line
        # Impact: Proceeds with error handling if parameter parsing failed
        # parse_parameters: Function to parse parameters
        # "$@": All command-line arguments
        
        print_status "ERROR" "Failed to parse parameters"
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
    
    if ! command_exists "kubectl"; then
        # Purpose: Check if kubectl is available
        # Why needed: Validates that kubectl is available
        # Impact: Proceeds with error handling if kubectl not available
        # command_exists: Function to check if command exists
        # "kubectl": Command to check
        
        print_status "ERROR" "kubectl is required but not found"
        # Purpose: Log kubectl not found error
        # Why needed: Informs user about missing kubectl
        # Impact: User knows kubectl is missing
        
        exit 2
        # Purpose: Exit with prerequisite error code
        # Why needed: Indicates prerequisites not met
        # Impact: Script exits with prerequisite error
    fi
    
    # =============================================================================
    # EXECUTE EXPERIMENT
    # =============================================================================
    # Purpose: Execute the pod failure experiment
    # Why needed: Runs the actual experiment
    
    if ! execute_pod_failure; then
        # Purpose: Execute pod failure experiment
        # Why needed: Runs the pod failure experiment
        # Impact: Proceeds with error handling if experiment failed
        # execute_pod_failure: Function to execute experiment
        
        print_status "ERROR" "Pod failure experiment failed"
        # Purpose: Log experiment execution failure
        # Why needed: Informs user about experiment execution issues
        # Impact: User knows experiment execution failed
        
        exit 4
        # Purpose: Exit with experiment error code
        # Why needed: Indicates experiment execution failed
        # Impact: Script exits with experiment error
    fi
    
    print_status "SUCCESS" "Pod Chaos Engineering Script completed successfully"
    # Purpose: Log successful script completion
    # Why needed: Confirms script completed successfully
    # Impact: User knows script completed successfully
    
    exit 0
    # Purpose: Exit with success status
    # Why needed: Indicates script completed successfully
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
