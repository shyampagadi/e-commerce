#!/bin/bash
# =============================================================================
# E-COMMERCE APPLICATION BACKUP AND RECOVERY SCRIPT
# =============================================================================
# This script provides comprehensive backup and recovery for the e-commerce
# application with advanced Kubernetes workload management capabilities including
# data protection, disaster recovery, and backup verification features.
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
# BACKUP CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent backup configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for backup operations
# Why needed: Provides consistent namespace reference for all backup activities
# Impact: All backup operations target resources in this namespace
# Value: Defaults to 'ecommerce', can be overridden via --namespace argument

ACTION=""
# Purpose: Specifies the backup action to perform
# Why needed: Determines which backup function to execute
# Impact: Controls the type of backup operation performed
# Value: Actions like 'backup', 'restore', 'list', 'verify', 'cleanup'

BACKUP_DIR="/tmp/ecommerce-backup-$(date +%Y%m%d_%H%M%S)"
# Purpose: Specifies the directory for backup storage
# Why needed: Provides consistent location for backup data storage
# Impact: All backup data is stored in this directory
# Value: Defaults to timestamped directory in /tmp, can be overridden

RESTORE_DIR=""
# Purpose: Specifies the directory for restore operations
# Why needed: Provides source location for restore operations
# Impact: Restore operations read from this directory
# Value: Set via --restore-dir argument, empty for interactive selection

RETENTION_DAYS=30
# Purpose: Specifies the number of days to retain backup data
# Why needed: Controls backup storage usage and cleanup operations
# Impact: Backups older than this period are automatically cleaned up
# Value: Defaults to 30 days, can be overridden via --retention argument

COMPRESS=true
# Purpose: Enables compression for backup data
# Why needed: Reduces backup storage requirements and transfer time
# Impact: When true, backup data is compressed using gzip
# Usage: Can be disabled via --no-compress argument

VERIFY=true
# Purpose: Enables backup verification after creation
# Why needed: Ensures backup integrity and completeness
# Impact: When true, backup data is verified after creation
# Usage: Can be disabled via --no-verify argument

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --namespace=*)
            NAMESPACE="${1#*=}"
            shift
            ;;
        --backup-dir=*)
            BACKUP_DIR="${1#*=}"
            shift
            ;;
        --restore-dir=*)
            RESTORE_DIR="${1#*=}"
            shift
            ;;
        --retention=*)
            RETENTION_DAYS="${1#*=}"
            shift
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        --no-verify)
            VERIFY=false
            shift
            ;;
        *)
            if [ -z "$ACTION" ]; then
                ACTION="$1"
            fi
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

# Backup tracking
BACKUP_ID=$(date +%Y%m%d_%H%M%S)
BACKUP_LOG="/tmp/backup_${BACKUP_ID}.log"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function: Print colored output
print_status() {
    # =============================================================================
    # PRINT STATUS FUNCTION
    # =============================================================================
    # Displays colored status messages with timestamps and comprehensive logging
    # capabilities for backup operations with visual feedback and audit trails.
    # =============================================================================
    
    # Purpose: Display colored status messages with timestamps
    # Why needed: Provides visual feedback and consistent logging for backup operations
    # Impact: Users can easily identify message types and operations are logged
    # Parameters:
    #   $1: Status type (INFO, SUCCESS, WARNING, ERROR, HEADER)
    #   $2: Message to display
    # Usage: print_status "SUCCESS" "Backup completed successfully"
    
    local status=$1
    # Purpose: Specifies the type of status message
    # Why needed: Determines color and formatting for the message
    # Impact: Different status types get different colors for easy identification
    # Parameter: $1 is the status type (INFO, SUCCESS, WARNING, ERROR, HEADER)
    
    local message=$2
    # Purpose: Contains the message text to display
    # Why needed: Provides the actual message content
    # Impact: Users see the specific message about the operation
    # Parameter: $2 is the message text to display
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Purpose: Generate current timestamp for message
    # Why needed: Provides temporal context for all messages
    # Impact: Users can see when each message was generated
    # date '+%Y-%m-%d %H:%M:%S': Format timestamp as YYYY-MM-DD HH:MM:SS
    
    # =============================================================================
    # STATUS MESSAGE DISPLAY
    # =============================================================================
    # Purpose: Display colored status message based on type
    # Why needed: Provides visual feedback with appropriate colors
    
    case $status in
        # Purpose: Switch statement to handle different status types
        # Why needed: Provides different formatting for each status type
        # Impact: Each status type gets appropriate color and formatting
        
        "INFO")
            # Purpose: Handle informational messages
            # Why needed: Provides blue color for informational content
            # Impact: Users can easily identify informational messages
            
            echo -e "${BLUE}[INFO]${NC} [${timestamp}] ${message}"
            # Purpose: Display blue-colored INFO message
            # Why needed: Provides visual indication of informational content
            # Impact: User sees blue-colored informational message
            # echo -e: Enable interpretation of backslash escapes
            # ${BLUE}: Blue color code for INFO messages
            # [INFO]: Status type identifier
            # ${NC}: No color (reset to default)
            # [${timestamp}]: Timestamp in brackets
            # ${message}: The actual message content
            ;;
        "SUCCESS")
            # Purpose: Handle success messages
            # Why needed: Provides green color for successful operations
            # Impact: Users can easily identify successful operations
            
            echo -e "${GREEN}[SUCCESS]${NC} [${timestamp}] ${message}"
            # Purpose: Display green-colored SUCCESS message
            # Why needed: Provides visual indication of successful operations
            # Impact: User sees green-colored success message
            # ${GREEN}: Green color code for SUCCESS messages
            ;;
        "WARNING")
            # Purpose: Handle warning messages
            # Why needed: Provides yellow color for warning conditions
            # Impact: Users can easily identify warning conditions
            
            echo -e "${YELLOW}[WARNING]${NC} [${timestamp}] ${message}"
            # Purpose: Display yellow-colored WARNING message
            # Why needed: Provides visual indication of warning conditions
            # Impact: User sees yellow-colored warning message
            # ${YELLOW}: Yellow color code for WARNING messages
            ;;
        "ERROR")
            # Purpose: Handle error messages
            # Why needed: Provides red color for error conditions
            # Impact: Users can easily identify error conditions
            
            echo -e "${RED}[ERROR]${NC} [${timestamp}] ${message}"
            # Purpose: Display red-colored ERROR message
            # Why needed: Provides visual indication of error conditions
            # Impact: User sees red-colored error message
            # ${RED}: Red color code for ERROR messages
            ;;
        "HEADER")
            # Purpose: Handle header messages
            # Why needed: Provides purple color for section headers
            # Impact: Users can easily identify section headers
            
            echo -e "${PURPLE}[HEADER]${NC} [${timestamp}] ${message}"
            # Purpose: Display purple-colored HEADER message
            # Why needed: Provides visual indication of section headers
            # Impact: User sees purple-colored header message
            # ${PURPLE}: Purple color code for HEADER messages
            ;;
    esac
    
    # =============================================================================
    # LOG FILE WRITING
    # =============================================================================
    # Purpose: Write message to backup log file
    # Why needed: Provides persistent audit trail of all operations
    
    echo "[${status}] [${timestamp}] ${message}" >> "$BACKUP_LOG"
    # Purpose: Append message to backup log file
    # Why needed: Creates persistent record of all backup operations
    # Impact: All messages are logged for audit and troubleshooting
    # echo: Output message to log file
    # [${status}]: Status type in brackets
    # [${timestamp}]: Timestamp in brackets
    # ${message}: The actual message content
    # >>: Append to log file (don't overwrite)
    # "$BACKUP_LOG": Backup log file path
}

# Function: Check if command exists
command_exists() {
    # =============================================================================
    # COMMAND EXISTS FUNCTION
    # =============================================================================
    # Validates command availability with comprehensive error handling and
    # return value management for backup operation prerequisites.
    # =============================================================================
    
    # Purpose: Check if a command is available in the system PATH
    # Why needed: Validates command availability before attempting to use it
    # Impact: Prevents script failures due to missing commands
    # Parameters:
    #   $1: Command name to check
    # Returns: 0 if command exists, 1 if not found
    # Usage: command_exists "kubectl"
    
    command -v "$1" >/dev/null 2>&1
    # Purpose: Check if command exists in system PATH
    # Why needed: Validates command availability before execution
    # Impact: Returns success if command found, failure if not found
    # command -v: Built-in command to find command location
    # "$1": Command name to check (first parameter)
    # >/dev/null: Redirect stdout to null (suppress output)
    # 2>&1: Redirect stderr to stdout (suppress error messages)
    # Return value: 0 if command exists, 1 if not found
}

# Function: Check prerequisites
check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates all prerequisites for backup operations with comprehensive
    # error handling and system validation for reliable backup execution.
    # =============================================================================
    
    # Purpose: Validate all prerequisites for backup operations
    # Why needed: Ensures all required tools and access are available
    # Impact: Prevents backup failures due to missing prerequisites
    # Parameters: None
    # Usage: check_prerequisites
    
    # =============================================================================
    # KUBECTL COMMAND VALIDATION
    # =============================================================================
    # Purpose: Check if kubectl command is available
    # Why needed: kubectl is required for all Kubernetes operations
    
    if ! command_exists kubectl; then
        # Purpose: Check if kubectl command is not available
        # Why needed: kubectl is required for all backup operations
        # Impact: If kubectl not found, backup cannot proceed
        
        print_status "ERROR" "kubectl command not found"
        # Purpose: Log error message about missing kubectl
        # Why needed: Informs user that kubectl is required
        # Impact: User knows kubectl must be installed
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Cannot proceed without kubectl
        # Impact: Script terminates with error status
    fi
    
    # =============================================================================
    # KUBERNETES CLUSTER CONNECTION VALIDATION
    # =============================================================================
    # Purpose: Check if Kubernetes cluster is accessible
    # Why needed: Backup operations require cluster access
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        # Purpose: Check if Kubernetes cluster is not accessible
        # Why needed: Cluster access is required for backup operations
        # Impact: If cluster not accessible, backup cannot proceed
        
        print_status "ERROR" "Cannot connect to Kubernetes cluster"
        # Purpose: Log error message about cluster connection
        # Why needed: Informs user that cluster access is required
        # Impact: User knows cluster must be accessible
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Cannot proceed without cluster access
        # Impact: Script terminates with error status
    fi
    
    # =============================================================================
    # NAMESPACE VALIDATION
    # =============================================================================
    # Purpose: Check if target namespace exists
    # Why needed: Backup operations target specific namespace
    
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        # Purpose: Check if target namespace does not exist
        # Why needed: Namespace must exist for backup operations
        # Impact: If namespace not found, backup cannot proceed
        
        print_status "ERROR" "Namespace $NAMESPACE does not exist"
        # Purpose: Log error message about missing namespace
        # Why needed: Informs user that namespace must exist
        # Impact: User knows namespace must be created or specified correctly
        
        exit 1
        # Purpose: Exit script with error code 1
        # Why needed: Cannot proceed without target namespace
        # Impact: Script terminates with error status
    fi
}

# Function: Create backup directory
create_backup_dir() {
    # =============================================================================
    # CREATE BACKUP DIRECTORY FUNCTION
    # =============================================================================
    # Creates backup directory structure with comprehensive validation and
    # error handling for reliable backup storage management.
    # =============================================================================
    
    # Purpose: Create backup directory for storing backup data
    # Why needed: Provides organized storage location for backup files
    # Impact: Ensures backup data has proper storage location
    # Parameters:
    #   $1: Backup directory path to create
    # Usage: create_backup_dir "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory path
    # Why needed: Provides target location for backup directory creation
    # Impact: All backup data will be stored in this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # DIRECTORY CREATION VALIDATION
    # =============================================================================
    # Purpose: Check if directory exists and create if needed
    # Why needed: Ensures backup directory is available for use
    
    if [ ! -d "$backup_dir" ]; then
        # Purpose: Check if backup directory does not exist
        # Why needed: Only create directory if it doesn't already exist
        # Impact: If directory doesn't exist, create it; otherwise use existing
        
        mkdir -p "$backup_dir"
        # Purpose: Create backup directory with parent directories
        # Why needed: Ensures backup directory exists for data storage
        # Impact: Creates directory structure for backup operations
        # mkdir -p: Create directory and all parent directories as needed
        # "$backup_dir": Target directory path to create
        
        print_status "SUCCESS" "Created backup directory: $backup_dir"
        # Purpose: Log success message about directory creation
        # Why needed: Confirms that backup directory was created successfully
        # Impact: User knows backup directory is ready for use
        # $backup_dir: Shows the directory path that was created
    else
        # Purpose: Handle case when directory already exists
        # Why needed: Provides information about existing directory usage
        # Impact: If directory exists, inform user it will be used
        
        print_status "INFO" "Using existing backup directory: $backup_dir"
        # Purpose: Log informational message about existing directory
        # Why needed: Informs user that existing directory will be used
        # Impact: User knows backup directory is already available
        # $backup_dir: Shows the directory path that will be used
    fi
}

# Function: Backup Kubernetes resources
backup_kubernetes_resources() {
    # =============================================================================
    # BACKUP KUBERNETES RESOURCES FUNCTION
    # =============================================================================
    # Performs comprehensive backup of all Kubernetes resources in the target
    # namespace with detailed resource capture and error handling.
    # =============================================================================
    
    # Purpose: Backup all Kubernetes resources in the target namespace
    # Why needed: Preserves complete application configuration and state
    # Impact: Enables full application restoration from backup
    # Parameters:
    #   $1: Backup directory path for storing resource files
    # Usage: backup_kubernetes_resources "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory for storing resource files
    # Why needed: Provides target location for Kubernetes resource backups
    # Impact: All Kubernetes resources will be saved to this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup initiation and begin resource backup
    # Why needed: Provides visibility into backup process
    
    print_status "INFO" "Backing up Kubernetes resources"
    # Purpose: Log backup initiation message
    # Why needed: Informs user that Kubernetes resource backup is starting
    # Impact: User knows backup process has begun
    
    # =============================================================================
    # NAMESPACE BACKUP
    # =============================================================================
    # Purpose: Backup namespace configuration
    # Why needed: Preserves namespace settings and metadata
    
    kubectl get namespace "$NAMESPACE" -o yaml > "$backup_dir/namespace.yaml"
    # Purpose: Export namespace configuration to YAML file
    # Why needed: Preserves namespace settings for restoration
    # Impact: Namespace configuration is saved for backup
    # kubectl get namespace: Get namespace information
    # "$NAMESPACE": Target namespace to backup
    # -o yaml: Output in YAML format
    # > "$backup_dir/namespace.yaml": Save to namespace.yaml file
    
    print_status "SUCCESS" "Namespace backed up"
    # Purpose: Log success message for namespace backup
    # Why needed: Confirms namespace backup completed successfully
    # Impact: User knows namespace backup succeeded
    
    # =============================================================================
    # CONFIGMAPS BACKUP
    # =============================================================================
    # Purpose: Backup ConfigMaps
    # Why needed: Preserves application configuration data
    
    kubectl get configmaps -n "$NAMESPACE" -o yaml > "$backup_dir/configmaps.yaml"
    # Purpose: Export ConfigMaps to YAML file
    # Why needed: Preserves application configuration for restoration
    # Impact: ConfigMaps are saved for backup
    # kubectl get configmaps: Get all ConfigMaps in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/configmaps.yaml": Save to configmaps.yaml file
    
    print_status "SUCCESS" "ConfigMaps backed up"
    # Purpose: Log success message for ConfigMaps backup
    # Why needed: Confirms ConfigMaps backup completed successfully
    # Impact: User knows ConfigMaps backup succeeded
    
    # =============================================================================
    # SECRETS BACKUP
    # =============================================================================
    # Purpose: Backup Secrets
    # Why needed: Preserves sensitive configuration data
    
    kubectl get secrets -n "$NAMESPACE" -o yaml > "$backup_dir/secrets.yaml"
    # Purpose: Export Secrets to YAML file
    # Why needed: Preserves sensitive data for restoration
    # Impact: Secrets are saved for backup
    # kubectl get secrets: Get all Secrets in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/secrets.yaml": Save to secrets.yaml file
    
    print_status "SUCCESS" "Secrets backed up"
    # Purpose: Log success message for Secrets backup
    # Why needed: Confirms Secrets backup completed successfully
    # Impact: User knows Secrets backup succeeded
    
    # =============================================================================
    # DEPLOYMENTS BACKUP
    # =============================================================================
    # Purpose: Backup Deployments
    # Why needed: Preserves application deployment configuration
    
    kubectl get deployments -n "$NAMESPACE" -o yaml > "$backup_dir/deployments.yaml"
    # Purpose: Export Deployments to YAML file
    # Why needed: Preserves deployment configuration for restoration
    # Impact: Deployments are saved for backup
    # kubectl get deployments: Get all Deployments in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/deployments.yaml": Save to deployments.yaml file
    
    print_status "SUCCESS" "Deployments backed up"
    # Purpose: Log success message for Deployments backup
    # Why needed: Confirms Deployments backup completed successfully
    # Impact: User knows Deployments backup succeeded
    
    # =============================================================================
    # SERVICES BACKUP
    # =============================================================================
    # Purpose: Backup Services
    # Why needed: Preserves service configuration and networking
    
    kubectl get services -n "$NAMESPACE" -o yaml > "$backup_dir/services.yaml"
    # Purpose: Export Services to YAML file
    # Why needed: Preserves service configuration for restoration
    # Impact: Services are saved for backup
    # kubectl get services: Get all Services in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/services.yaml": Save to services.yaml file
    
    print_status "SUCCESS" "Services backed up"
    # Purpose: Log success message for Services backup
    # Why needed: Confirms Services backup completed successfully
    # Impact: User knows Services backup succeeded
    
    # =============================================================================
    # PERSISTENT VOLUME CLAIMS BACKUP
    # =============================================================================
    # Purpose: Backup Persistent Volume Claims
    # Why needed: Preserves storage configuration
    
    kubectl get pvc -n "$NAMESPACE" -o yaml > "$backup_dir/pvcs.yaml"
    # Purpose: Export PVCs to YAML file
    # Why needed: Preserves storage configuration for restoration
    # Impact: PVCs are saved for backup
    # kubectl get pvc: Get all PVCs in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/pvcs.yaml": Save to pvcs.yaml file
    
    print_status "SUCCESS" "PVCs backed up"
    # Purpose: Log success message for PVCs backup
    # Why needed: Confirms PVCs backup completed successfully
    # Impact: User knows PVCs backup succeeded
    
    # =============================================================================
    # INGRESS BACKUP
    # =============================================================================
    # Purpose: Backup Ingress resources
    # Why needed: Preserves external access configuration
    
    kubectl get ingress -n "$NAMESPACE" -o yaml > "$backup_dir/ingress.yaml" 2>/dev/null || true
    # Purpose: Export Ingress to YAML file with error handling
    # Why needed: Preserves external access configuration for restoration
    # Impact: Ingress resources are saved for backup
    # kubectl get ingress: Get all Ingress in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/ingress.yaml": Save to ingress.yaml file
    # 2>/dev/null: Suppress error messages
    # || true: Don't fail if no Ingress resources exist
    
    print_status "SUCCESS" "Ingress backed up"
    # Purpose: Log success message for Ingress backup
    # Why needed: Confirms Ingress backup completed successfully
    # Impact: User knows Ingress backup succeeded
    
    # =============================================================================
    # NETWORK POLICIES BACKUP
    # =============================================================================
    # Purpose: Backup NetworkPolicies
    # Why needed: Preserves network security configuration
    
    kubectl get networkpolicies -n "$NAMESPACE" -o yaml > "$backup_dir/networkpolicies.yaml" 2>/dev/null || true
    # Purpose: Export NetworkPolicies to YAML file with error handling
    # Why needed: Preserves network security configuration for restoration
    # Impact: NetworkPolicies are saved for backup
    # kubectl get networkpolicies: Get all NetworkPolicies in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/networkpolicies.yaml": Save to networkpolicies.yaml file
    # 2>/dev/null: Suppress error messages
    # || true: Don't fail if no NetworkPolicies exist
    
    print_status "SUCCESS" "NetworkPolicies backed up"
    # Purpose: Log success message for NetworkPolicies backup
    # Why needed: Confirms NetworkPolicies backup completed successfully
    # Impact: User knows NetworkPolicies backup succeeded
    
    # =============================================================================
    # RESOURCE QUOTAS BACKUP
    # =============================================================================
    # Purpose: Backup ResourceQuotas
    # Why needed: Preserves resource limit configuration
    
    kubectl get resourcequotas -n "$NAMESPACE" -o yaml > "$backup_dir/resourcequotas.yaml" 2>/dev/null || true
    # Purpose: Export ResourceQuotas to YAML file with error handling
    # Why needed: Preserves resource limit configuration for restoration
    # Impact: ResourceQuotas are saved for backup
    # kubectl get resourcequotas: Get all ResourceQuotas in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/resourcequotas.yaml": Save to resourcequotas.yaml file
    # 2>/dev/null: Suppress error messages
    # || true: Don't fail if no ResourceQuotas exist
    
    print_status "SUCCESS" "ResourceQuotas backed up"
    # Purpose: Log success message for ResourceQuotas backup
    # Why needed: Confirms ResourceQuotas backup completed successfully
    # Impact: User knows ResourceQuotas backup succeeded
    
    # =============================================================================
    # LIMIT RANGES BACKUP
    # =============================================================================
    # Purpose: Backup LimitRanges
    # Why needed: Preserves resource limit configuration
    
    kubectl get limitranges -n "$NAMESPACE" -o yaml > "$backup_dir/limitranges.yaml" 2>/dev/null || true
    # Purpose: Export LimitRanges to YAML file with error handling
    # Why needed: Preserves resource limit configuration for restoration
    # Impact: LimitRanges are saved for backup
    # kubectl get limitranges: Get all LimitRanges in namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o yaml: Output in YAML format
    # > "$backup_dir/limitranges.yaml": Save to limitranges.yaml file
    # 2>/dev/null: Suppress error messages
    # || true: Don't fail if no LimitRanges exist
    
    print_status "SUCCESS" "LimitRanges backed up"
    # Purpose: Log success message for LimitRanges backup
    # Why needed: Confirms LimitRanges backup completed successfully
    # Impact: User knows LimitRanges backup succeeded
}

# Function: Backup database
backup_database() {
    # =============================================================================
    # BACKUP DATABASE FUNCTION
    # =============================================================================
    # Performs comprehensive database backup with pod validation, status checking,
    # and error handling for reliable data protection and recovery.
    # =============================================================================
    
    # Purpose: Backup database data from PostgreSQL pod
    # Why needed: Preserves application data for disaster recovery
    # Impact: Enables complete data restoration from backup
    # Parameters:
    #   $1: Backup directory path for storing database backup
    # Usage: backup_database "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory for storing database backup
    # Why needed: Provides target location for database backup file
    # Impact: Database backup will be saved to this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup initiation and begin database backup
    # Why needed: Provides visibility into backup process
    
    print_status "INFO" "Backing up database"
    # Purpose: Log backup initiation message
    # Why needed: Informs user that database backup is starting
    # Impact: User knows database backup process has begun
    
    # =============================================================================
    # DATABASE POD DISCOVERY
    # =============================================================================
    # Purpose: Find the database pod for backup operations
    # Why needed: Identifies which pod contains the database
    
    local db_pod
    # Purpose: Variable to store database pod name
    # Why needed: Provides pod name for database backup operations
    # Impact: Used to identify which pod to backup from
    
    db_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce,component=database" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first database pod
    # Why needed: Identifies database pod for backup operations
    # Impact: Provides pod name for database backup
    # kubectl get pods: Lists pods in the namespace
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=ecommerce,component=database": Filter for database pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # DATABASE POD VALIDATION
    # =============================================================================
    # Purpose: Validate database pod availability
    # Why needed: Ensures database pod exists before attempting backup
    
    if [ -z "$db_pod" ]; then
        # Purpose: Check if database pod was not found
        # Why needed: Cannot backup database if pod doesn't exist
        # Impact: If pod not found, skip database backup
        
        print_status "WARNING" "Database pod not found, skipping database backup"
        # Purpose: Log warning message about missing database pod
        # Why needed: Informs user that database backup is being skipped
        # Impact: User knows database backup was skipped due to missing pod
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates function completed successfully (no error)
        # Impact: Function terminates without error, backup continues
    fi
    
    # =============================================================================
    # POD STATUS VALIDATION
    # =============================================================================
    # Purpose: Check if database pod is running
    # Why needed: Database backup requires pod to be in Running state
    
    local pod_status
    # Purpose: Variable to store pod status
    # Why needed: Provides pod status for validation
    # Impact: Used to determine if pod is ready for backup
    
    pod_status=$(kubectl get pod -n "$NAMESPACE" "$db_pod" -o jsonpath='{.status.phase}' 2>/dev/null)
    # Purpose: Get current status of the database pod
    # Why needed: Validates that pod is ready for backup operations
    # Impact: Provides pod status for validation
    # kubectl get pod: Get specific pod information
    # -n "$NAMESPACE": Specify target namespace
    # "$db_pod": Target pod name
    # -o jsonpath: Extracts only the status phase from JSON output
    # .status.phase: JSONPath to extract pod phase
    # 2>/dev/null: Suppress error messages
    
    if [ "$pod_status" != "Running" ]; then
        # Purpose: Check if pod is not in Running state
        # Why needed: Database backup requires pod to be running
        # Impact: If pod not running, skip database backup
        
        print_status "WARNING" "Database pod is not running (status: $pod_status), skipping database backup"
        # Purpose: Log warning message about pod status
        # Why needed: Informs user that database backup is being skipped
        # Impact: User knows database backup was skipped due to pod status
        # $pod_status: Shows the current pod status
        
        return 0
        # Purpose: Exit function with success code 0
        # Why needed: Indicates function completed successfully (no error)
        # Impact: Function terminates without error, backup continues
    fi
    
    # =============================================================================
    # DATABASE BACKUP EXECUTION
    # =============================================================================
    # Purpose: Perform actual database backup
    # Why needed: Creates database backup file for restoration
    
    local db_backup_file="$backup_dir/database.sql"
    # Purpose: Variable to store database backup file path
    # Why needed: Provides target file path for database backup
    # Impact: Database backup will be saved to this file
    # "$backup_dir/database.sql": Backup file path with .sql extension
    
    if kubectl exec -n "$NAMESPACE" "$db_pod" -- pg_dump -U postgres ecommerce > "$db_backup_file" 2>/dev/null; then
        # Purpose: Execute database backup command
        # Why needed: Creates database backup file
        # Impact: If successful, database is backed up; otherwise handle error
        # kubectl exec: Execute command in pod
        # -n "$NAMESPACE": Specify target namespace
        # "$db_pod": Target pod for command execution
        # -- pg_dump: PostgreSQL backup command
        # -U postgres: Use postgres user for backup
        # ecommerce: Database name to backup
        # > "$db_backup_file": Redirect output to backup file
        # 2>/dev/null: Suppress error messages
        
        print_status "SUCCESS" "Database backed up to $db_backup_file"
        # Purpose: Log success message for database backup
        # Why needed: Confirms database backup completed successfully
        # Impact: User knows database backup succeeded
        # $db_backup_file: Shows the backup file path
        
        # =============================================================================
        # BACKUP SIZE REPORTING
        # =============================================================================
        # Purpose: Report backup file size
        # Why needed: Provides information about backup size
        
        local backup_size
        # Purpose: Variable to store backup file size
        # Why needed: Provides backup size information
        # Impact: Used to display backup size to user
        
        backup_size=$(du -h "$db_backup_file" | awk '{print $1}')
        # Purpose: Get human-readable size of backup file
        # Why needed: Provides backup size information for user
        # Impact: User can see how much space the backup uses
        # du -h: Get disk usage in human-readable format
        # "$db_backup_file": Target file for size calculation
        # awk '{print $1}': Extract only the size value
        
        print_status "INFO" "Database backup size: $backup_size"
        # Purpose: Log backup size information
        # Why needed: Informs user about backup file size
        # Impact: User knows the size of the database backup
        # $backup_size: Shows the backup file size
    else
        # Purpose: Handle case when database backup fails
        # Why needed: Provides error handling for backup failures
        # Impact: If backup fails, log error and return failure
        
        print_status "ERROR" "Failed to backup database"
        # Purpose: Log error message for database backup failure
        # Why needed: Informs user that database backup failed
        # Impact: User knows database backup failed
        
        return 1
        # Purpose: Exit function with error code 1
        # Why needed: Indicates database backup failure
        # Impact: Function terminates with error status
    fi
}

# Function: Backup persistent volumes
backup_persistent_volumes() {
    # =============================================================================
    # BACKUP PERSISTENT VOLUMES FUNCTION
    # =============================================================================
    # Performs comprehensive backup of persistent volume claims and their data
    # with pod discovery, data copying, and error handling for complete storage protection.
    # =============================================================================
    
    # Purpose: Backup persistent volume claims and their data
    # Why needed: Preserves application data stored in persistent volumes
    # Impact: Enables complete data restoration including persistent storage
    # Parameters:
    #   $1: Backup directory path for storing PVC backups
    # Usage: backup_persistent_volumes "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory for storing PVC backups
    # Why needed: Provides target location for PVC backup files
    # Impact: All PVC backups will be saved to this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup initiation and begin PVC backup
    # Why needed: Provides visibility into backup process
    
    print_status "INFO" "Backing up persistent volumes"
    # Purpose: Log backup initiation message
    # Why needed: Informs user that PVC backup is starting
    # Impact: User knows PVC backup process has begun
    
    # =============================================================================
    # PVC DISCOVERY
    # =============================================================================
    # Purpose: Get list of all PVCs in the namespace
    # Why needed: Identifies which PVCs need backup
    
    local pvcs
    # Purpose: Variable to store list of PVC names
    # Why needed: Provides list of PVCs to iterate through
    # Impact: Used to determine which PVCs to backup
    
    pvcs=$(kubectl get pvc -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get names of all PVCs in the namespace
    # Why needed: Identifies PVCs that need backup
    # Impact: Provides list of PVC names for backup
    # kubectl get pvc: Lists PVCs in the namespace
    # -n "$NAMESPACE": Specify target namespace
    # -o jsonpath: Extracts only the PVC names from JSON output
    # .items[*].metadata.name: JSONPath to extract PVC names
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # PVC BACKUP PROCESSING
    # =============================================================================
    # Purpose: Process each PVC for backup
    # Why needed: Ensures all PVCs are backed up individually
    
    for pvc in $pvcs; do
        # Purpose: Iterate through each PVC found
        # Why needed: Processes each PVC individually for backup
        # Impact: Each PVC gets individual backup treatment
        
        print_status "INFO" "Backing up PVC: $pvc"
        # Purpose: Log PVC backup initiation message
        # Why needed: Informs user which PVC is being backed up
        # Impact: User knows which PVC is being processed
        # $pvc: Shows the PVC name being backed up
        
        # =============================================================================
        # PVC CONFIGURATION BACKUP
        # =============================================================================
        # Purpose: Backup PVC configuration
        # Why needed: Preserves PVC settings and metadata
        
        kubectl get pvc -n "$NAMESPACE" "$pvc" -o yaml > "$backup_dir/pvc_${pvc}.yaml"
        # Purpose: Export PVC configuration to YAML file
        # Why needed: Preserves PVC settings for restoration
        # Impact: PVC configuration is saved for backup
        # kubectl get pvc: Get specific PVC information
        # -n "$NAMESPACE": Specify target namespace
        # "$pvc": Target PVC name
        # -o yaml: Output in YAML format
        # > "$backup_dir/pvc_${pvc}.yaml": Save to PVC-specific YAML file
        
        # =============================================================================
        # POD DISCOVERY FOR PVC
        # =============================================================================
        # Purpose: Find pod using this PVC
        # Why needed: Identifies which pod contains the PVC data
        
        local pod
        # Purpose: Variable to store pod name using the PVC
        # Why needed: Provides pod name for data backup operations
        # Impact: Used to identify which pod to copy data from
        
        pod=$(kubectl get pods -n "$NAMESPACE" -o jsonpath="{.items[?(@.spec.volumes[?(@.persistentVolumeClaim.claimName=='$pvc')])].metadata.name}" 2>/dev/null)
        # Purpose: Get name of pod using the PVC
        # Why needed: Identifies pod for data backup operations
        # Impact: Provides pod name for data copying
        # kubectl get pods: Lists pods in the namespace
        # -n "$NAMESPACE": Specify target namespace
        # -o jsonpath: Extracts pod name from JSON output
        # Complex JSONPath to find pod with PVC: .items[?(@.spec.volumes[?(@.persistentVolumeClaim.claimName=='$pvc')])].metadata.name
        # 2>/dev/null: Suppress error messages
        
        # =============================================================================
        # PVC DATA BACKUP
        # =============================================================================
        # Purpose: Backup PVC data from pod
        # Why needed: Preserves actual data stored in PVC
        
        if [ -n "$pod" ]; then
            # Purpose: Check if pod using PVC was found
            # Why needed: Only backup data if pod exists
            # Impact: If pod found, backup data; otherwise skip data backup
            
            print_status "INFO" "Backing up data from pod $pod for PVC $pvc"
            # Purpose: Log data backup initiation message
            # Why needed: Informs user about data backup process
            # Impact: User knows data backup is starting
            # $pod: Shows the pod name
            # $pvc: Shows the PVC name
            
            # =============================================================================
            # PVC DATA DIRECTORY CREATION
            # =============================================================================
            # Purpose: Create directory for PVC data backup
            # Why needed: Provides organized storage for PVC data
            
            local pvc_backup_dir="$backup_dir/pvc_${pvc}_data"
            # Purpose: Variable to store PVC data backup directory path
            # Why needed: Provides target location for PVC data backup
            # Impact: PVC data will be stored in this directory
            # "$backup_dir/pvc_${pvc}_data": PVC-specific data directory
            
            mkdir -p "$pvc_backup_dir"
            # Purpose: Create PVC data backup directory
            # Why needed: Ensures directory exists for data backup
            # Impact: Creates directory structure for PVC data backup
            # mkdir -p: Create directory and all parent directories as needed
            # "$pvc_backup_dir": Target directory path
            
            # =============================================================================
            # PVC DATA COPYING
            # =============================================================================
            # Purpose: Copy data from pod to backup directory
            # Why needed: Preserves actual data stored in PVC
            
            if kubectl cp "$NAMESPACE/$pod:/var/lib/postgresql/data" "$pvc_backup_dir/" 2>/dev/null; then
                # Purpose: Copy data from pod to backup directory
                # Why needed: Preserves PVC data for restoration
                # Impact: If successful, PVC data is backed up; otherwise handle error
                # kubectl cp: Copy files between pod and local filesystem
                # "$NAMESPACE/$pod": Source pod in namespace
                # ":/var/lib/postgresql/data": Source path in pod (PostgreSQL data directory)
                # "$pvc_backup_dir/": Target directory for data backup
                # 2>/dev/null: Suppress error messages
                
                print_status "SUCCESS" "PVC $pvc data backed up"
                # Purpose: Log success message for PVC data backup
                # Why needed: Confirms PVC data backup completed successfully
                # Impact: User knows PVC data backup succeeded
                # $pvc: Shows the PVC name that was backed up
            else
                # Purpose: Handle case when PVC data backup fails
                # Why needed: Provides error handling for data backup failures
                # Impact: If data backup fails, log warning but continue
                
                print_status "WARNING" "Failed to backup PVC $pvc data"
                # Purpose: Log warning message for PVC data backup failure
                # Why needed: Informs user that PVC data backup failed
                # Impact: User knows PVC data backup failed
                # $pvc: Shows the PVC name that failed to backup
            fi
        else
            # Purpose: Handle case when no pod uses the PVC
            # Why needed: Provides information about unused PVCs
            # Impact: If no pod found, log warning but continue
            
            print_status "WARNING" "No pod found using PVC $pvc"
            # Purpose: Log warning message about unused PVC
            # Why needed: Informs user that PVC is not in use
            # Impact: User knows PVC is not currently used by any pod
            # $pvc: Shows the PVC name that is not in use
        fi
    done
}

# Function: Backup monitoring data
backup_monitoring_data() {
    # =============================================================================
    # BACKUP MONITORING DATA FUNCTION
    # =============================================================================
    # Performs comprehensive backup of monitoring system data including
    # Prometheus and Grafana data with pod discovery and error handling.
    # =============================================================================
    
    # Purpose: Backup monitoring system data (Prometheus and Grafana)
    # Why needed: Preserves monitoring data and dashboards for restoration
    # Impact: Enables complete monitoring system restoration from backup
    # Parameters:
    #   $1: Backup directory path for storing monitoring data
    # Usage: backup_monitoring_data "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory for storing monitoring data
    # Why needed: Provides target location for monitoring data backups
    # Impact: All monitoring data will be saved to this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup initiation and begin monitoring data backup
    # Why needed: Provides visibility into backup process
    
    print_status "INFO" "Backing up monitoring data"
    # Purpose: Log backup initiation message
    # Why needed: Informs user that monitoring data backup is starting
    # Impact: User knows monitoring data backup process has begun
    
    # =============================================================================
    # PROMETHEUS DATA BACKUP
    # =============================================================================
    # Purpose: Backup Prometheus monitoring data
    # Why needed: Preserves metrics and monitoring configuration
    
    local prometheus_pod
    # Purpose: Variable to store Prometheus pod name
    # Why needed: Provides pod name for Prometheus data backup
    # Impact: Used to identify which pod to backup Prometheus data from
    
    prometheus_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=prometheus" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first Prometheus pod
    # Why needed: Identifies Prometheus pod for data backup
    # Impact: Provides pod name for Prometheus data backup
    # kubectl get pods: Lists pods in the namespace
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=prometheus": Filter for Prometheus pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppress error messages
    
    if [ -n "$prometheus_pod" ]; then
        # Purpose: Check if Prometheus pod was found
        # Why needed: Only backup Prometheus data if pod exists
        # Impact: If pod found, backup data; otherwise skip Prometheus backup
        
        print_status "INFO" "Backing up Prometheus data"
        # Purpose: Log Prometheus data backup initiation message
        # Why needed: Informs user about Prometheus data backup process
        # Impact: User knows Prometheus data backup is starting
        
        # =============================================================================
        # PROMETHEUS DATA DIRECTORY CREATION
        # =============================================================================
        # Purpose: Create directory for Prometheus data backup
        # Why needed: Provides organized storage for Prometheus data
        
        local prometheus_backup_dir="$backup_dir/prometheus_data"
        # Purpose: Variable to store Prometheus data backup directory path
        # Why needed: Provides target location for Prometheus data backup
        # Impact: Prometheus data will be stored in this directory
        # "$backup_dir/prometheus_data": Prometheus-specific data directory
        
        mkdir -p "$prometheus_backup_dir"
        # Purpose: Create Prometheus data backup directory
        # Why needed: Ensures directory exists for Prometheus data backup
        # Impact: Creates directory structure for Prometheus data backup
        # mkdir -p: Create directory and all parent directories as needed
        # "$prometheus_backup_dir": Target directory path
        
        # =============================================================================
        # PROMETHEUS DATA COPYING
        # =============================================================================
        # Purpose: Copy Prometheus data from pod to backup directory
        # Why needed: Preserves Prometheus metrics and configuration
        
        if kubectl cp "$NAMESPACE/$prometheus_pod:/prometheus" "$prometheus_backup_dir/" 2>/dev/null; then
            # Purpose: Copy Prometheus data from pod to backup directory
            # Why needed: Preserves Prometheus data for restoration
            # Impact: If successful, Prometheus data is backed up; otherwise handle error
            # kubectl cp: Copy files between pod and local filesystem
            # "$NAMESPACE/$prometheus_pod": Source Prometheus pod in namespace
            # ":/prometheus": Source path in pod (Prometheus data directory)
            # "$prometheus_backup_dir/": Target directory for Prometheus data backup
            # 2>/dev/null: Suppress error messages
            
            print_status "SUCCESS" "Prometheus data backed up"
            # Purpose: Log success message for Prometheus data backup
            # Why needed: Confirms Prometheus data backup completed successfully
            # Impact: User knows Prometheus data backup succeeded
        else
            # Purpose: Handle case when Prometheus data backup fails
            # Why needed: Provides error handling for Prometheus data backup failures
            # Impact: If data backup fails, log warning but continue
            
            print_status "WARNING" "Failed to backup Prometheus data"
            # Purpose: Log warning message for Prometheus data backup failure
            # Why needed: Informs user that Prometheus data backup failed
            # Impact: User knows Prometheus data backup failed
        fi
    fi
    
    # =============================================================================
    # GRAFANA DATA BACKUP
    # =============================================================================
    # Purpose: Backup Grafana monitoring data
    # Why needed: Preserves dashboards and Grafana configuration
    
    local grafana_pod
    # Purpose: Variable to store Grafana pod name
    # Why needed: Provides pod name for Grafana data backup
    # Impact: Used to identify which pod to backup Grafana data from
    
    grafana_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=grafana" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get name of the first Grafana pod
    # Why needed: Identifies Grafana pod for data backup
    # Impact: Provides pod name for Grafana data backup
    # kubectl get pods: Lists pods in the namespace
    # -n "$NAMESPACE": Specify target namespace
    # -l "app=grafana": Filter for Grafana pods
    # -o jsonpath: Extracts only the pod name from JSON output
    # .items[0].metadata.name: JSONPath to extract first pod name
    # 2>/dev/null: Suppress error messages
    
    if [ -n "$grafana_pod" ]; then
        # Purpose: Check if Grafana pod was found
        # Why needed: Only backup Grafana data if pod exists
        # Impact: If pod found, backup data; otherwise skip Grafana backup
        
        print_status "INFO" "Backing up Grafana data"
        # Purpose: Log Grafana data backup initiation message
        # Why needed: Informs user about Grafana data backup process
        # Impact: User knows Grafana data backup is starting
        
        # =============================================================================
        # GRAFANA DATA DIRECTORY CREATION
        # =============================================================================
        # Purpose: Create directory for Grafana data backup
        # Why needed: Provides organized storage for Grafana data
        
        local grafana_backup_dir="$backup_dir/grafana_data"
        # Purpose: Variable to store Grafana data backup directory path
        # Why needed: Provides target location for Grafana data backup
        # Impact: Grafana data will be stored in this directory
        # "$backup_dir/grafana_data": Grafana-specific data directory
        
        mkdir -p "$grafana_backup_dir"
        # Purpose: Create Grafana data backup directory
        # Why needed: Ensures directory exists for Grafana data backup
        # Impact: Creates directory structure for Grafana data backup
        # mkdir -p: Create directory and all parent directories as needed
        # "$grafana_backup_dir": Target directory path
        
        # =============================================================================
        # GRAFANA DATA COPYING
        # =============================================================================
        # Purpose: Copy Grafana data from pod to backup directory
        # Why needed: Preserves Grafana dashboards and configuration
        
        if kubectl cp "$NAMESPACE/$grafana_pod:/var/lib/grafana" "$grafana_backup_dir/" 2>/dev/null; then
            # Purpose: Copy Grafana data from pod to backup directory
            # Why needed: Preserves Grafana data for restoration
            # Impact: If successful, Grafana data is backed up; otherwise handle error
            # kubectl cp: Copy files between pod and local filesystem
            # "$NAMESPACE/$grafana_pod": Source Grafana pod in namespace
            # ":/var/lib/grafana": Source path in pod (Grafana data directory)
            # "$grafana_backup_dir/": Target directory for Grafana data backup
            # 2>/dev/null: Suppress error messages
            
            print_status "SUCCESS" "Grafana data backed up"
            # Purpose: Log success message for Grafana data backup
            # Why needed: Confirms Grafana data backup completed successfully
            # Impact: User knows Grafana data backup succeeded
        else
            # Purpose: Handle case when Grafana data backup fails
            # Why needed: Provides error handling for Grafana data backup failures
            # Impact: If data backup fails, log warning but continue
            
            print_status "WARNING" "Failed to backup Grafana data"
            # Purpose: Log warning message for Grafana data backup failure
            # Why needed: Informs user that Grafana data backup failed
            # Impact: User knows Grafana data backup failed
        fi
    fi
}

# Function: Create backup manifest
create_backup_manifest() {
    # =============================================================================
    # CREATE BACKUP MANIFEST FUNCTION
    # =============================================================================
    # Creates comprehensive backup manifest with metadata, component information,
    # and file listings for backup verification and restoration guidance.
    # =============================================================================
    
    # Purpose: Create backup manifest file with metadata and file listings
    # Why needed: Provides backup metadata and file inventory for verification
    # Impact: Enables backup verification and restoration guidance
    # Parameters:
    #   $1: Backup directory path for storing manifest file
    # Usage: create_backup_manifest "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory for storing manifest file
    # Why needed: Provides target location for manifest file
    # Impact: Manifest file will be saved to this directory
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # MANIFEST CREATION INITIATION
    # =============================================================================
    # Purpose: Log manifest creation initiation
    # Why needed: Provides visibility into manifest creation process
    
    print_status "INFO" "Creating backup manifest"
    # Purpose: Log manifest creation initiation message
    # Why needed: Informs user that backup manifest is being created
    # Impact: User knows manifest creation process has begun
    
    # =============================================================================
    # MANIFEST FILE INITIALIZATION
    # =============================================================================
    # Purpose: Define manifest file path and create manifest content
    # Why needed: Provides structured backup metadata
    
    local manifest_file="$backup_dir/backup_manifest.json"
    # Purpose: Variable to store manifest file path
    # Why needed: Provides target file path for manifest
    # Impact: Manifest will be saved to this file
    # "$backup_dir/backup_manifest.json": Manifest file path with .json extension
    
    # =============================================================================
    # MANIFEST CONTENT GENERATION
    # =============================================================================
    # Purpose: Generate comprehensive backup manifest content
    # Why needed: Provides complete backup metadata and file inventory
    
    cat > "$manifest_file" << EOF
    # Purpose: Create manifest file with comprehensive backup information
    # Why needed: Generates structured backup metadata for verification
    # Impact: Creates detailed backup manifest file
    # cat >: Create new file with content
    # "$manifest_file": Target manifest file path
    # << EOF: Here document for multi-line content
    
{
    "backup_id": "$BACKUP_ID",
    "namespace": "$NAMESPACE",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "backup_dir": "$backup_dir",
    "components": {
        "kubernetes_resources": true,
        "database": true,
        "persistent_volumes": true,
        "monitoring_data": true
    },
    "files": [
        "namespace.yaml",
        "configmaps.yaml",
        "secrets.yaml",
        "deployments.yaml",
        "services.yaml",
        "pvcs.yaml",
        "ingress.yaml",
        "networkpolicies.yaml",
        "resourcequotas.yaml",
        "limitranges.yaml",
        "database.sql"
    ]
}
EOF
    # Purpose: Generate comprehensive backup manifest content
    # Why needed: Provides complete backup metadata for verification and restoration
    # Impact: Creates detailed backup manifest with all necessary information
    # JSON structure with backup metadata:
    # "backup_id": "$BACKUP_ID": Unique backup identifier
    # "namespace": "$NAMESPACE": Target namespace for backup
    # "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")": Backup creation timestamp in UTC
    # "backup_dir": "$backup_dir": Backup directory path
    # "components": Object indicating which components were backed up
    # "kubernetes_resources": true: Kubernetes resources were backed up
    # "database": true: Database was backed up
    # "persistent_volumes": true: Persistent volumes were backed up
    # "monitoring_data": true: Monitoring data was backed up
    # "files": Array listing all backup files
    # Various YAML files: Kubernetes resource files
    # "database.sql": Database backup file
    
    # =============================================================================
    # MANIFEST CREATION COMPLETION
    # =============================================================================
    # Purpose: Log manifest creation completion
    # Why needed: Confirms manifest creation was successful
    
    print_status "SUCCESS" "Backup manifest created: $manifest_file"
    # Purpose: Log success message for manifest creation
    # Why needed: Confirms that backup manifest was created successfully
    # Impact: User knows manifest creation completed and file location
    # $manifest_file: Shows the manifest file path that was created
}

# Function: Compress backup
compress_backup() {
    # =============================================================================
    # COMPRESS BACKUP FUNCTION
    # =============================================================================
    # Compresses backup directory into tar.gz archive and removes temporary files.
    # Provides efficient storage and cleanup of backup data.
    # =============================================================================
    
    # Purpose: Compress backup directory into tar.gz archive
    # Why needed: Reduces storage space and provides efficient backup storage
    # Impact: Creates compressed archive and removes temporary files
    # Parameters:
    #   $1: Backup directory path to compress
    # Usage: compress_backup "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory to compress
    # Why needed: Provides source directory for compression
    # Impact: This directory will be compressed into archive
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # COMPRESSION CHECK
    # =============================================================================
    # Purpose: Check if compression is enabled
    # Why needed: Only compress if compression is requested
    
    if [ "$COMPRESS" = true ]; then
        # Purpose: Check if compression is enabled
        # Why needed: Only compress if compression is requested
        # Impact: Proceeds with compression if enabled
        
        # =============================================================================
        # COMPRESSION INITIATION
        # =============================================================================
        # Purpose: Log compression initiation
        # Why needed: Provides visibility into compression process
        
        print_status "INFO" "Compressing backup"
        # Purpose: Log compression initiation message
        # Why needed: Informs user that backup compression is starting
        # Impact: User knows compression process has begun
        
        # =============================================================================
        # ARCHIVE CONFIGURATION
        # =============================================================================
        # Purpose: Define archive filename
        # Why needed: Provides target archive file information
        
        local compressed_file="${backup_dir}.tar.gz"
        # Purpose: Variable to store archive filename
        # Why needed: Provides archive filename with .tar.gz extension
        # Impact: Archive will be named with backup directory name
        # "${backup_dir}.tar.gz": Archive filename with .tar.gz extension
        
        # =============================================================================
        # BACKUP COMPRESSION
        # =============================================================================
        # Purpose: Compress backup directory into tar.gz archive
        # Why needed: Reduces storage space and provides efficient backup storage
        
        if tar -czf "$compressed_file" -C "$(dirname "$backup_dir")" "$(basename "$backup_dir")" 2>/dev/null; then
            # Purpose: Compress backup directory into tar.gz archive
            # Why needed: Creates compressed archive for efficient storage
            # Impact: Backup directory is compressed into tar.gz file
            # tar: Archive creation command
            # -c: Create new archive
            # -z: Compress with gzip
            # -f: Specify archive file
            # "$compressed_file": Target archive file path
            # -C "$(dirname "$backup_dir")": Change to parent directory of backup
            # "$(basename "$backup_dir")": Archive only the directory name (not full path)
            # 2>/dev/null: Suppress error messages
            
            # =============================================================================
            # COMPRESSION SUCCESS HANDLING
            # =============================================================================
            # Purpose: Handle successful compression
            # Why needed: Provides success feedback and cleanup
            
            print_status "SUCCESS" "Backup compressed to $compressed_file"
            # Purpose: Log success message for compression
            # Why needed: Confirms that backup was compressed successfully
            # Impact: User knows compression completed and archive location
            # $compressed_file: Shows the archive file path that was created
            
            # =============================================================================
            # COMPRESSED SIZE CALCULATION
            # =============================================================================
            # Purpose: Calculate and display compressed archive size
            # Why needed: Provides information about compression efficiency
            
            local compressed_size
            # Purpose: Variable to store compressed archive size
            # Why needed: Provides storage for size calculation
            # Impact: Will contain human-readable size of compressed archive
            
            compressed_size=$(du -h "$compressed_file" | awk '{print $1}')
            # Purpose: Calculate compressed archive size
            # Why needed: Provides information about compression efficiency
            # Impact: Shows how much space the compressed archive uses
            # du -h: Display disk usage in human-readable format
            # "$compressed_file": Target file for size calculation
            # | awk '{print $1}': Extract only the size value
            
            print_status "INFO" "Compressed backup size: $compressed_size"
            # Purpose: Log compressed archive size
            # Why needed: Provides information about compression efficiency
            # Impact: User knows the size of the compressed archive
            # $compressed_size: Shows the compressed archive size
            
            # =============================================================================
            # CLEANUP OF ORIGINAL DIRECTORY
            # =============================================================================
            # Purpose: Remove original backup directory
            # Why needed: Cleans up temporary files after successful compression
            
            rm -rf "$backup_dir"
            # Purpose: Remove original backup directory
            # Why needed: Cleans up temporary files after successful compression
            # Impact: Frees up disk space by removing uncompressed backup
            # rm -rf: Remove directory and all contents recursively
            # "$backup_dir": Directory to remove
            
            print_status "INFO" "Original backup directory removed"
            # Purpose: Log cleanup completion message
            # Why needed: Confirms that temporary files were cleaned up
            # Impact: User knows cleanup was completed successfully
        else
            # Purpose: Handle compression failure
            # Why needed: Provides error handling for failed compression
            # Impact: Logs error and returns failure status
            
            print_status "ERROR" "Failed to compress backup"
            # Purpose: Log error message for compression failure
            # Why needed: Informs user that compression failed
            # Impact: User knows compression failed and can investigate
            
            return 1
            # Purpose: Return failure status
            # Why needed: Indicates that compression operation failed
            # Impact: Calling function knows compression failed
        fi
    fi
}

# Function: Verify backup
verify_backup() {
    # =============================================================================
    # VERIFY BACKUP FUNCTION
    # =============================================================================
    # Verifies backup integrity by checking directory existence and essential files.
    # Provides comprehensive backup validation for restoration confidence.
    # =============================================================================
    
    # Purpose: Verify backup integrity and completeness
    # Why needed: Ensures backup is complete and can be restored successfully
    # Impact: Validates backup quality and provides restoration confidence
    # Parameters:
    #   $1: Backup directory path to verify
    # Usage: verify_backup "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory to verify
    # Why needed: Provides source directory for verification
    # Impact: This directory will be verified for completeness
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # VERIFICATION CHECK
    # =============================================================================
    # Purpose: Check if verification is enabled
    # Why needed: Only verify if verification is requested
    
    if [ "$VERIFY" = true ]; then
        # Purpose: Check if verification is enabled
        # Why needed: Only verify if verification is requested
        # Impact: Proceeds with verification if enabled
        
        # =============================================================================
        # VERIFICATION INITIATION
        # =============================================================================
        # Purpose: Log verification initiation
        # Why needed: Provides visibility into verification process
        
        print_status "INFO" "Verifying backup"
        # Purpose: Log verification initiation message
        # Why needed: Informs user that backup verification is starting
        # Impact: User knows verification process has begun
        
        # =============================================================================
        # BACKUP DIRECTORY VERIFICATION
        # =============================================================================
        # Purpose: Check if backup directory exists
        # Why needed: Ensures backup directory is accessible
        
        if [ ! -d "$backup_dir" ]; then
            # Purpose: Check if backup directory exists
            # Why needed: Ensures backup directory is accessible
            # Impact: Proceeds with verification if directory exists
            
            print_status "ERROR" "Backup directory not found: $backup_dir"
            # Purpose: Log error message for missing backup directory
            # Why needed: Informs user that backup directory is missing
            # Impact: User knows verification failed due to missing directory
            # $backup_dir: Shows the missing directory path
            
            return 1
            # Purpose: Return failure status
            # Why needed: Indicates that verification failed
            # Impact: Calling function knows verification failed
        fi
        
        # =============================================================================
        # ESSENTIAL FILES VERIFICATION
        # =============================================================================
        # Purpose: Check for essential backup files
        # Why needed: Ensures all critical files are present
        
        local essential_files=("namespace.yaml" "configmaps.yaml" "secrets.yaml" "deployments.yaml" "services.yaml" "pvcs.yaml")
        # Purpose: Array of essential backup files
        # Why needed: Defines which files are required for successful restoration
        # Impact: Verification will check for these files
        # Array contains: namespace.yaml, configmaps.yaml, secrets.yaml, deployments.yaml, services.yaml, pvcs.yaml
        
        for file in "${essential_files[@]}"; do
            # Purpose: Iterate through essential files
            # Why needed: Checks each essential file for existence
            # Impact: Validates that all essential files are present
            
            if [ ! -f "$backup_dir/$file" ]; then
                # Purpose: Check if essential file exists
                # Why needed: Ensures essential file is present
                # Impact: Proceeds with verification if file exists
                
                print_status "ERROR" "Essential file missing: $file"
                # Purpose: Log error message for missing essential file
                # Why needed: Informs user that essential file is missing
                # Impact: User knows verification failed due to missing file
                # $file: Shows the missing file name
                
                return 1
                # Purpose: Return failure status
                # Why needed: Indicates that verification failed
                # Impact: Calling function knows verification failed
            fi
        done
        
        # =============================================================================
        # DATABASE BACKUP VERIFICATION
        # =============================================================================
        # Purpose: Check for database backup file
        # Why needed: Ensures database backup is present (optional)
        
        if [ ! -f "$backup_dir/database.sql" ]; then
            # Purpose: Check if database backup exists
            # Why needed: Ensures database backup is present
            # Impact: Proceeds with verification if database backup exists
            
            print_status "WARNING" "Database backup not found"
            # Purpose: Log warning message for missing database backup
            # Why needed: Informs user that database backup is missing
            # Impact: User knows database backup is missing but verification continues
        fi
        
        # =============================================================================
        # VERIFICATION COMPLETION
        # =============================================================================
        # Purpose: Log verification completion
        # Why needed: Confirms verification was successful
        
        print_status "SUCCESS" "Backup verification completed"
        # Purpose: Log success message for verification
        # Why needed: Confirms that backup verification was successful
        # Impact: User knows verification completed successfully
    fi
}

# Function: Restore Kubernetes resources
restore_kubernetes_resources() {
    # =============================================================================
    # RESTORE KUBERNETES RESOURCES FUNCTION
    # =============================================================================
    # Restores Kubernetes resources from backup files using kubectl apply.
    # Provides comprehensive restoration of all backed-up resources.
    # =============================================================================
    
    # Purpose: Restore Kubernetes resources from backup files
    # Why needed: Enables restoration of backed-up Kubernetes resources
    # Impact: Restores all backed-up resources to the cluster
    # Parameters:
    #   $1: Restore directory path containing backup files
    # Usage: restore_kubernetes_resources "/tmp/backup-20231201"
    
    local restore_dir=$1
    # Purpose: Specifies the restore directory containing backup files
    # Why needed: Provides source directory for restoration
    # Impact: This directory will be used to restore resources
    # Parameter: $1 is the restore directory path
    
    # =============================================================================
    # RESTORATION INITIATION
    # =============================================================================
    # Purpose: Log restoration initiation
    # Why needed: Provides visibility into restoration process
    
    print_status "INFO" "Restoring Kubernetes resources"
    # Purpose: Log restoration initiation message
    # Why needed: Informs user that Kubernetes resource restoration is starting
    # Impact: User knows restoration process has begun
    
    # =============================================================================
    # NAMESPACE RESTORATION
    # =============================================================================
    # Purpose: Restore namespace from backup
    # Why needed: Ensures namespace exists before restoring other resources
    
    if [ -f "$restore_dir/namespace.yaml" ]; then
        # Purpose: Check if namespace backup file exists
        # Why needed: Ensures namespace backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/namespace.yaml"
        # Purpose: Apply namespace configuration from backup
        # Why needed: Restores namespace configuration
        # Impact: Namespace is restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/namespace.yaml": Namespace backup file path
        
        print_status "SUCCESS" "Namespace restored"
        # Purpose: Log success message for namespace restoration
        # Why needed: Confirms that namespace was restored successfully
        # Impact: User knows namespace restoration completed
    fi
    
    # =============================================================================
    # CONFIGMAPS RESTORATION
    # =============================================================================
    # Purpose: Restore ConfigMaps from backup
    # Why needed: Ensures configuration data is restored
    
    if [ -f "$restore_dir/configmaps.yaml" ]; then
        # Purpose: Check if ConfigMaps backup file exists
        # Why needed: Ensures ConfigMaps backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/configmaps.yaml"
        # Purpose: Apply ConfigMaps configuration from backup
        # Why needed: Restores ConfigMaps configuration
        # Impact: ConfigMaps are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/configmaps.yaml": ConfigMaps backup file path
        
        print_status "SUCCESS" "ConfigMaps restored"
        # Purpose: Log success message for ConfigMaps restoration
        # Why needed: Confirms that ConfigMaps were restored successfully
        # Impact: User knows ConfigMaps restoration completed
    fi
    
    # =============================================================================
    # SECRETS RESTORATION
    # =============================================================================
    # Purpose: Restore Secrets from backup
    # Why needed: Ensures sensitive data is restored
    
    if [ -f "$restore_dir/secrets.yaml" ]; then
        # Purpose: Check if Secrets backup file exists
        # Why needed: Ensures Secrets backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/secrets.yaml"
        # Purpose: Apply Secrets configuration from backup
        # Why needed: Restores Secrets configuration
        # Impact: Secrets are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/secrets.yaml": Secrets backup file path
        
        print_status "SUCCESS" "Secrets restored"
        # Purpose: Log success message for Secrets restoration
        # Why needed: Confirms that Secrets were restored successfully
        # Impact: User knows Secrets restoration completed
    fi
    
    # =============================================================================
    # PVCs RESTORATION
    # =============================================================================
    # Purpose: Restore Persistent Volume Claims from backup
    # Why needed: Ensures persistent storage is restored
    
    if [ -f "$restore_dir/pvcs.yaml" ]; then
        # Purpose: Check if PVCs backup file exists
        # Why needed: Ensures PVCs backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/pvcs.yaml"
        # Purpose: Apply PVCs configuration from backup
        # Why needed: Restores PVCs configuration
        # Impact: PVCs are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/pvcs.yaml": PVCs backup file path
        
        print_status "SUCCESS" "PVCs restored"
        # Purpose: Log success message for PVCs restoration
        # Why needed: Confirms that PVCs were restored successfully
        # Impact: User knows PVCs restoration completed
    fi
    
    # =============================================================================
    # DEPLOYMENTS RESTORATION
    # =============================================================================
    # Purpose: Restore Deployments from backup
    # Why needed: Ensures application workloads are restored
    
    if [ -f "$restore_dir/deployments.yaml" ]; then
        # Purpose: Check if Deployments backup file exists
        # Why needed: Ensures Deployments backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/deployments.yaml"
        # Purpose: Apply Deployments configuration from backup
        # Why needed: Restores Deployments configuration
        # Impact: Deployments are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/deployments.yaml": Deployments backup file path
        
        print_status "SUCCESS" "Deployments restored"
        # Purpose: Log success message for Deployments restoration
        # Why needed: Confirms that Deployments were restored successfully
        # Impact: User knows Deployments restoration completed
    fi
    
    # =============================================================================
    # SERVICES RESTORATION
    # =============================================================================
    # Purpose: Restore Services from backup
    # Why needed: Ensures service networking is restored
    
    if [ -f "$restore_dir/services.yaml" ]; then
        # Purpose: Check if Services backup file exists
        # Why needed: Ensures Services backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/services.yaml"
        # Purpose: Apply Services configuration from backup
        # Why needed: Restores Services configuration
        # Impact: Services are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/services.yaml": Services backup file path
        
        print_status "SUCCESS" "Services restored"
        # Purpose: Log success message for Services restoration
        # Why needed: Confirms that Services were restored successfully
        # Impact: User knows Services restoration completed
    fi
    
    # =============================================================================
    # INGRESS RESTORATION
    # =============================================================================
    # Purpose: Restore Ingress from backup
    # Why needed: Ensures external access is restored
    
    if [ -f "$restore_dir/ingress.yaml" ]; then
        # Purpose: Check if Ingress backup file exists
        # Why needed: Ensures Ingress backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/ingress.yaml"
        # Purpose: Apply Ingress configuration from backup
        # Why needed: Restores Ingress configuration
        # Impact: Ingress is restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/ingress.yaml": Ingress backup file path
        
        print_status "SUCCESS" "Ingress restored"
        # Purpose: Log success message for Ingress restoration
        # Why needed: Confirms that Ingress was restored successfully
        # Impact: User knows Ingress restoration completed
    fi
    
    # =============================================================================
    # NETWORKPOLICIES RESTORATION
    # =============================================================================
    # Purpose: Restore NetworkPolicies from backup
    # Why needed: Ensures network security is restored
    
    if [ -f "$restore_dir/networkpolicies.yaml" ]; then
        # Purpose: Check if NetworkPolicies backup file exists
        # Why needed: Ensures NetworkPolicies backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/networkpolicies.yaml"
        # Purpose: Apply NetworkPolicies configuration from backup
        # Why needed: Restores NetworkPolicies configuration
        # Impact: NetworkPolicies are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/networkpolicies.yaml": NetworkPolicies backup file path
        
        print_status "SUCCESS" "NetworkPolicies restored"
        # Purpose: Log success message for NetworkPolicies restoration
        # Why needed: Confirms that NetworkPolicies were restored successfully
        # Impact: User knows NetworkPolicies restoration completed
    fi
    
    # =============================================================================
    # RESOURCEQUOTAS RESTORATION
    # =============================================================================
    # Purpose: Restore ResourceQuotas from backup
    # Why needed: Ensures resource limits are restored
    
    if [ -f "$restore_dir/resourcequotas.yaml" ]; then
        # Purpose: Check if ResourceQuotas backup file exists
        # Why needed: Ensures ResourceQuotas backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/resourcequotas.yaml"
        # Purpose: Apply ResourceQuotas configuration from backup
        # Why needed: Restores ResourceQuotas configuration
        # Impact: ResourceQuotas are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/resourcequotas.yaml": ResourceQuotas backup file path
        
        print_status "SUCCESS" "ResourceQuotas restored"
        # Purpose: Log success message for ResourceQuotas restoration
        # Why needed: Confirms that ResourceQuotas were restored successfully
        # Impact: User knows ResourceQuotas restoration completed
    fi
    
    # =============================================================================
    # LIMITRANGES RESTORATION
    # =============================================================================
    # Purpose: Restore LimitRanges from backup
    # Why needed: Ensures resource limits are restored
    
    if [ -f "$restore_dir/limitranges.yaml" ]; then
        # Purpose: Check if LimitRanges backup file exists
        # Why needed: Ensures LimitRanges backup file is present
        # Impact: Proceeds with restoration if file exists
        
        kubectl apply -f "$restore_dir/limitranges.yaml"
        # Purpose: Apply LimitRanges configuration from backup
        # Why needed: Restores LimitRanges configuration
        # Impact: LimitRanges are restored to the cluster
        # kubectl apply: Apply configuration to cluster
        # -f: Specify file to apply
        # "$restore_dir/limitranges.yaml": LimitRanges backup file path
        
        print_status "SUCCESS" "LimitRanges restored"
        # Purpose: Log success message for LimitRanges restoration
        # Why needed: Confirms that LimitRanges were restored successfully
        # Impact: User knows LimitRanges restoration completed
    fi
}

# Function: Restore database
restore_database() {
    # =============================================================================
    # RESTORE DATABASE FUNCTION
    # =============================================================================
    # Restores database from backup SQL file using kubectl exec and psql.
    # Provides comprehensive database restoration with validation.
    # =============================================================================
    
    # Purpose: Restore database from backup SQL file
    # Why needed: Enables restoration of backed-up database data
    # Impact: Restores database data to the cluster
    # Parameters:
    #   $1: Restore directory path containing database backup
    # Usage: restore_database "/tmp/backup-20231201"
    
    local restore_dir=$1
    # Purpose: Specifies the restore directory containing database backup
    # Why needed: Provides source directory for database restoration
    # Impact: This directory will be used to restore database
    # Parameter: $1 is the restore directory path
    
    # =============================================================================
    # RESTORATION INITIATION
    # =============================================================================
    # Purpose: Log restoration initiation
    # Why needed: Provides visibility into restoration process
    
    print_status "INFO" "Restoring database"
    # Purpose: Log restoration initiation message
    # Why needed: Informs user that database restoration is starting
    # Impact: User knows restoration process has begun
    
    # =============================================================================
    # DATABASE BACKUP VERIFICATION
    # =============================================================================
    # Purpose: Check if database backup file exists
    # Why needed: Ensures database backup file is present
    
    if [ ! -f "$restore_dir/database.sql" ]; then
        # Purpose: Check if database backup file exists
        # Why needed: Ensures database backup file is present
        # Impact: Proceeds with restoration if file exists
        
        print_status "WARNING" "Database backup not found, skipping database restore"
        # Purpose: Log warning message for missing database backup
        # Why needed: Informs user that database backup is missing
        # Impact: User knows database restoration was skipped
        
        return 0
        # Purpose: Return success status
        # Why needed: Indicates that restoration was skipped (not failed)
        # Impact: Calling function knows restoration was skipped
    fi
    
    # =============================================================================
    # DATABASE POD READINESS
    # =============================================================================
    # Purpose: Wait for database pod to be ready
    # Why needed: Ensures database pod is ready before restoration
    
    print_status "INFO" "Waiting for database pod to be ready"
    # Purpose: Log readiness check initiation
    # Why needed: Informs user that database pod readiness is being checked
    # Impact: User knows readiness check has begun
    
    kubectl wait --for=condition=ready pod -l "app=ecommerce,component=database" -n "$NAMESPACE" --timeout=300s
    # Purpose: Wait for database pod to be ready
    # Why needed: Ensures database pod is ready before restoration
    # Impact: Database pod is ready for restoration
    # kubectl wait: Wait for condition
    # --for=condition=ready: Wait for pod to be ready
    # pod: Resource type to wait for
    # -l "app=ecommerce,component=database": Label selector for database pod
    # -n "$NAMESPACE": Target namespace
    # --timeout=300s: Maximum wait time (5 minutes)
    
    # =============================================================================
    # DATABASE POD DISCOVERY
    # =============================================================================
    # Purpose: Get database pod name
    # Why needed: Provides pod name for database restoration
    
    local db_pod
    # Purpose: Variable to store database pod name
    # Why needed: Provides pod name for database restoration
    # Impact: Will contain the database pod name
    
    db_pod=$(kubectl get pods -n "$NAMESPACE" -l "app=ecommerce,component=database" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    # Purpose: Get database pod name
    # Why needed: Provides pod name for database restoration
    # Impact: Database pod name is retrieved
    # kubectl get pods: Get pod information
    # -n "$NAMESPACE": Target namespace
    # -l "app=ecommerce,component=database": Label selector for database pod
    # -o jsonpath='{.items[0].metadata.name}': Extract pod name from JSON
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # DATABASE POD VALIDATION
    # =============================================================================
    # Purpose: Validate database pod exists
    # Why needed: Ensures database pod is available for restoration
    
    if [ -z "$db_pod" ]; then
        # Purpose: Check if database pod name is empty
        # Why needed: Ensures database pod is available
        # Impact: Proceeds with restoration if pod exists
        
        print_status "ERROR" "Database pod not found"
        # Purpose: Log error message for missing database pod
        # Why needed: Informs user that database pod is missing
        # Impact: User knows restoration failed due to missing pod
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates that restoration failed
        # Impact: Calling function knows restoration failed
    fi
    
    # =============================================================================
    # DATABASE RESTORATION
    # =============================================================================
    # Purpose: Restore database from backup SQL file
    # Why needed: Restores database data to the cluster
    
    if kubectl exec -i -n "$NAMESPACE" "$db_pod" -- psql -U postgres ecommerce < "$restore_dir/database.sql" 2>/dev/null; then
        # Purpose: Restore database from backup SQL file
        # Why needed: Restores database data to the cluster
        # Impact: Database data is restored from backup
        # kubectl exec: Execute command in pod
        # -i: Interactive mode for input
        # -n "$NAMESPACE": Target namespace
        # "$db_pod": Database pod name
        # -- psql: PostgreSQL command-line client
        # -U postgres: Database user
        # ecommerce: Database name
        # < "$restore_dir/database.sql": Input from backup file
        # 2>/dev/null: Suppress error messages
        
        print_status "SUCCESS" "Database restored"
        # Purpose: Log success message for database restoration
        # Why needed: Confirms that database was restored successfully
        # Impact: User knows database restoration completed
    else
        # Purpose: Handle database restoration failure
        # Why needed: Provides error handling for failed restoration
        # Impact: Logs error and returns failure status
        
        print_status "ERROR" "Failed to restore database"
        # Purpose: Log error message for database restoration failure
        # Why needed: Informs user that database restoration failed
        # Impact: User knows database restoration failed
        
        return 1
        # Purpose: Return failure status
        # Why needed: Indicates that restoration failed
        # Impact: Calling function knows restoration failed
    fi
}

# Function: Restore persistent volumes
restore_persistent_volumes() {
    # =============================================================================
    # RESTORE PERSISTENT VOLUMES FUNCTION
    # =============================================================================
    # Restores persistent volume data from backup files using kubectl exec.
    # Provides comprehensive restoration of persistent volume data.
    # =============================================================================
    
    # Purpose: Restore persistent volume data from backup files
    # Why needed: Enables restoration of backed-up persistent volume data
    # Impact: Restores persistent volume data to the cluster
    # Parameters:
    #   $1: Restore directory path containing persistent volume backups
    # Usage: restore_persistent_volumes "/tmp/backup-20231201"
    
    local restore_dir=$1
    # Purpose: Specifies the restore directory containing persistent volume backups
    # Why needed: Provides source directory for persistent volume restoration
    # Impact: This directory will be used to restore persistent volume data
    # Parameter: $1 is the restore directory path
    
    # =============================================================================
    # RESTORATION INITIATION
    # =============================================================================
    # Purpose: Log restoration initiation
    # Why needed: Provides visibility into restoration process
    
    print_status "INFO" "Restoring persistent volumes"
    # Purpose: Log restoration initiation message
    # Why needed: Informs user that persistent volume restoration is starting
    # Impact: User knows restoration process has begun
    
    # =============================================================================
    # PVC DISCOVERY
    # =============================================================================
    # Purpose: Get list of PVCs to restore
    # Why needed: Provides list of PVCs for restoration
    
    local pvcs
    # Purpose: Variable to store list of PVCs
    # Why needed: Provides list of PVCs for restoration
    # Impact: Will contain the list of PVCs to restore
    
    pvcs=$(kubectl get pvc -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    # Purpose: Get list of PVCs in the namespace
    # Why needed: Provides list of PVCs for restoration
    # Impact: List of PVCs is retrieved
    # kubectl get pvc: Get PVC information
    # -n "$NAMESPACE": Target namespace
    # -o jsonpath='{.items[*].metadata.name}': Extract PVC names from JSON
    # 2>/dev/null: Suppress error messages
    
    # =============================================================================
    # PVC RESTORATION LOOP
    # =============================================================================
    # Purpose: Restore each PVC
    # Why needed: Ensures all PVCs are restored
    
    for pvc in $pvcs; do
        # Purpose: Iterate through each PVC
        # Why needed: Restores each PVC individually
        # Impact: Each PVC is restored
        
        print_status "INFO" "Restoring PVC: $pvc"
        # Purpose: Log PVC restoration initiation
        # Why needed: Informs user which PVC is being restored
        # Impact: User knows which PVC is being restored
        # $pvc: Shows the PVC name being restored
        
        # =============================================================================
        # POD DISCOVERY FOR PVC
        # =============================================================================
        # Purpose: Get pod using this PVC
        # Why needed: Provides pod name for data restoration
        
        local pod
        # Purpose: Variable to store pod name
        # Why needed: Provides pod name for data restoration
        # Impact: Will contain the pod name using this PVC
        
        pod=$(kubectl get pods -n "$NAMESPACE" -o jsonpath="{.items[?(@.spec.volumes[?(@.persistentVolumeClaim.claimName=='$pvc')])].metadata.name}" 2>/dev/null)
        # Purpose: Get pod using this PVC
        # Why needed: Provides pod name for data restoration
        # Impact: Pod name is retrieved
        # kubectl get pods: Get pod information
        # -n "$NAMESPACE": Target namespace
        # -o jsonpath: Extract pod name from JSON
        # Complex JSONPath query to find pod using specific PVC
        # 2>/dev/null: Suppress error messages
        
        # =============================================================================
        # POD VALIDATION AND DATA RESTORATION
        # =============================================================================
        # Purpose: Validate pod exists and restore data
        # Why needed: Ensures pod exists before restoring data
        
        if [ -n "$pod" ]; then
            # Purpose: Check if pod name is not empty
            # Why needed: Ensures pod exists before restoring data
            # Impact: Proceeds with restoration if pod exists
            
            print_status "INFO" "Restoring data to pod $pod for PVC $pvc"
            # Purpose: Log data restoration initiation
            # Why needed: Informs user which pod is being restored
            # Impact: User knows which pod is being restored
            # $pod: Shows the pod name
            # $pvc: Shows the PVC name
            
            # =============================================================================
            # BACKUP DATA VERIFICATION
            # =============================================================================
            # Purpose: Check if backup data exists
            # Why needed: Ensures backup data is present before restoration
            local pvc_backup_dir="$restore_dir/pvc_${pvc}_data"
            # Purpose: Variable to store PVC backup directory path
            # Why needed: Provides path to PVC backup data
            # Impact: Will contain the PVC backup directory path
            # "$restore_dir/pvc_${pvc}_data": PVC backup directory path
            
            if [ -d "$pvc_backup_dir" ]; then
                # Purpose: Check if PVC backup directory exists
                # Why needed: Ensures PVC backup data is present
                # Impact: Proceeds with restoration if directory exists
                
                if kubectl cp "$pvc_backup_dir/" "$NAMESPACE/$pod:/var/lib/postgresql/data" 2>/dev/null; then
                    # Purpose: Copy PVC backup data to pod
                    # Why needed: Restores PVC data to the pod
                    # Impact: PVC data is restored to the pod
                    # kubectl cp: Copy files to/from pod
                    # "$pvc_backup_dir/": Source directory (PVC backup data)
                    # "$NAMESPACE/$pod:/var/lib/postgresql/data": Target pod and path
                    # 2>/dev/null: Suppress error messages
                    
                    print_status "SUCCESS" "PVC $pvc data restored"
                    # Purpose: Log success message for PVC data restoration
                    # Why needed: Confirms that PVC data was restored successfully
                    # Impact: User knows PVC data restoration completed
                    # $pvc: Shows the PVC name that was restored
                else
                    # Purpose: Handle PVC data restoration failure
                    # Why needed: Provides error handling for failed restoration
                    # Impact: Logs warning for failed restoration
                    
                    print_status "WARNING" "Failed to restore PVC $pvc data"
                    # Purpose: Log warning message for PVC data restoration failure
                    # Why needed: Informs user that PVC data restoration failed
                    # Impact: User knows PVC data restoration failed
                    # $pvc: Shows the PVC name that failed to restore
                fi
            else
                # Purpose: Handle missing PVC backup data
                # Why needed: Provides warning for missing backup data
                # Impact: Logs warning for missing backup data
                
                print_status "WARNING" "Backup data not found for PVC $pvc"
                # Purpose: Log warning message for missing PVC backup data
                # Why needed: Informs user that PVC backup data is missing
                # Impact: User knows PVC backup data is missing
                # $pvc: Shows the PVC name with missing backup data
            fi
        else
            # Purpose: Handle missing pod for PVC
            # Why needed: Provides warning for missing pod
            # Impact: Logs warning for missing pod
            
            print_status "WARNING" "No pod found using PVC $pvc"
            # Purpose: Log warning message for missing pod
            # Why needed: Informs user that no pod is using this PVC
            # Impact: User knows no pod is using this PVC
            # $pvc: Shows the PVC name with no associated pod
        fi
    done
}

# Function: Cleanup old backups
cleanup_old_backups() {
    # =============================================================================
    # CLEANUP OLD BACKUPS FUNCTION
    # =============================================================================
    # Removes old backup files and directories based on retention policy.
    # Provides automated cleanup of old backup data.
    # =============================================================================
    
    # Purpose: Remove old backup files and directories based on retention policy
    # Why needed: Prevents disk space issues by removing old backups
    # Impact: Frees up disk space by removing old backup data
    # Parameters:
    #   $1: Backup base directory path
    #   $2: Retention days for backups
    # Usage: cleanup_old_backups "/tmp/backups" 30
    
    local backup_base_dir=$1
    # Purpose: Specifies the backup base directory
    # Why needed: Provides base directory for backup cleanup
    # Impact: This directory will be cleaned up
    # Parameter: $1 is the backup base directory path
    
    local retention_days=$2
    # Purpose: Specifies the retention days for backups
    # Why needed: Defines how many days to keep backups
    # Impact: Backups older than this will be removed
    # Parameter: $2 is the retention days
    
    # =============================================================================
    # CLEANUP INITIATION
    # =============================================================================
    # Purpose: Log cleanup initiation
    # Why needed: Provides visibility into cleanup process
    
    print_status "INFO" "Cleaning up old backups (retention: $retention_days days)"
    # Purpose: Log cleanup initiation message
    # Why needed: Informs user that backup cleanup is starting
    # Impact: User knows cleanup process has begun
    # $retention_days: Shows the retention days for backups
    
    # =============================================================================
    # BACKUP DIRECTORY VERIFICATION
    # =============================================================================
    # Purpose: Check if backup base directory exists
    # Why needed: Ensures backup directory is accessible
    
    if [ -d "$backup_base_dir" ]; then
        # Purpose: Check if backup base directory exists
        # Why needed: Ensures backup directory is accessible
        # Impact: Proceeds with cleanup if directory exists
        
        # =============================================================================
        # OLD BACKUP DIRECTORIES CLEANUP
        # =============================================================================
        # Purpose: Remove old backup directories
        # Why needed: Frees up disk space by removing old backup directories
        
        find "$backup_base_dir" -name "ecommerce-backup-*" -type d -mtime +$retention_days -exec rm -rf {} \; 2>/dev/null || true
        # Purpose: Remove old backup directories
        # Why needed: Frees up disk space by removing old backup directories
        # Impact: Old backup directories are removed
        # find: Search for files and directories
        # "$backup_base_dir": Base directory to search
        # -name "ecommerce-backup-*": Match backup directory names
        # -type d: Only directories
        # -mtime +$retention_days: Files older than retention days
        # -exec rm -rf {} \;: Remove found directories
        # 2>/dev/null: Suppress error messages
        # || true: Continue even if command fails
        
        # =============================================================================
        # OLD BACKUP ARCHIVES CLEANUP
        # =============================================================================
        # Purpose: Remove old backup archives
        # Why needed: Frees up disk space by removing old backup archives
        
        find "$backup_base_dir" -name "ecommerce-backup-*.tar.gz" -type f -mtime +$retention_days -delete 2>/dev/null || true
        # Purpose: Remove old backup archives
        # Why needed: Frees up disk space by removing old backup archives
        # Impact: Old backup archives are removed
        # find: Search for files and directories
        # "$backup_base_dir": Base directory to search
        # -name "ecommerce-backup-*.tar.gz": Match backup archive names
        # -type f: Only files
        # -mtime +$retention_days: Files older than retention days
        # -delete: Delete found files
        # 2>/dev/null: Suppress error messages
        # || true: Continue even if command fails
        
        # =============================================================================
        # CLEANUP COMPLETION
        # =============================================================================
        # Purpose: Log cleanup completion
        # Why needed: Confirms cleanup was successful
        
        print_status "SUCCESS" "Old backups cleaned up"
        # Purpose: Log success message for cleanup
        # Why needed: Confirms that old backups were cleaned up successfully
        # Impact: User knows cleanup completed successfully
    fi
}

# Function: Show help
show_help() {
    # =============================================================================
    # SHOW HELP FUNCTION
    # =============================================================================
    # Displays comprehensive help information for the backup script.
    # Provides usage instructions, options, and examples.
    # =============================================================================
    
    # Purpose: Display help information for the backup script
    # Why needed: Provides users with usage instructions and options
    # Impact: Users can understand how to use the script
    # Parameters: None
    # Usage: show_help
    
    cat << EOF
    # Purpose: Display help information
    # Why needed: Provides users with usage instructions
    # Impact: Users can understand how to use the script
    # cat << EOF: Here document for multi-line content
    
E-commerce Application Backup and Recovery Script

USAGE:
    ./backup.sh [ACTION] [OPTIONS]

ACTIONS:
    backup          Create a complete backup
    restore         Restore from backup
    list            List available backups
    cleanup         Cleanup old backups
    verify          Verify backup integrity

OPTIONS:
    --namespace=NAMESPACE        Kubernetes namespace (default: ecommerce)
    --backup-dir=DIRECTORY       Backup directory (default: /tmp/ecommerce-backup-TIMESTAMP)
    --restore-dir=DIRECTORY      Restore directory (required for restore)
    --retention=DAYS             Backup retention days (default: 30)
    --no-compress                Disable backup compression
    --no-verify                  Disable backup verification

EXAMPLES:
    # Create a backup
    ./backup.sh backup

    # Create a backup with custom directory
    ./backup.sh backup --backup-dir=/backups/ecommerce-20241201

    # Restore from backup
    ./backup.sh restore --restore-dir=/backups/ecommerce-20241201

    # List available backups
    ./backup.sh list

    # Cleanup old backups
    ./backup.sh cleanup --retention=7

    # Verify backup integrity
    ./backup.sh verify --backup-dir=/backups/ecommerce-20241201

BACKUP COMPONENTS:
    - Kubernetes resources (ConfigMaps, Secrets, Deployments, Services, PVCs)
    - Database data (PostgreSQL dump)
    - Persistent volume data
    - Monitoring data (Prometheus, Grafana)
    - Application configuration

EOF
    # Purpose: End of help information
    # Why needed: Closes the here document
    # Impact: Help information is displayed to user
}

# =============================================================================
# MAIN BACKUP FUNCTIONS
# =============================================================================

# Function: Create backup
create_backup() {
    # =============================================================================
    # CREATE BACKUP FUNCTION
    # =============================================================================
    # Orchestrates the complete backup process for the e-commerce application.
    # Provides comprehensive backup of all application components.
    # =============================================================================
    
    # Purpose: Create comprehensive backup of e-commerce application
    # Why needed: Enables complete backup of all application components
    # Impact: Creates backup of all application data and configurations
    # Parameters: None (uses global variables)
    # Usage: create_backup
    
    # =============================================================================
    # BACKUP INITIATION
    # =============================================================================
    # Purpose: Log backup initiation and parameters
    # Why needed: Provides visibility into backup process
    
    print_status "HEADER" "Creating E-commerce Application Backup"
    # Purpose: Log backup initiation header
    # Why needed: Informs user that backup process is starting
    # Impact: User knows backup process has begun
    
    print_status "INFO" "Backup ID: $BACKUP_ID"
    # Purpose: Log backup ID
    # Why needed: Provides unique identifier for backup
    # Impact: User knows the backup ID
    # $BACKUP_ID: Shows the unique backup identifier
    
    print_status "INFO" "Namespace: $NAMESPACE"
    # Purpose: Log target namespace
    # Why needed: Shows which namespace is being backed up
    # Impact: User knows the target namespace
    # $NAMESPACE: Shows the target namespace
    
    print_status "INFO" "Backup Directory: $BACKUP_DIR"
    # Purpose: Log backup directory
    # Why needed: Shows where backup will be stored
    # Impact: User knows the backup directory
    # $BACKUP_DIR: Shows the backup directory path
    
    # =============================================================================
    # BACKUP DIRECTORY CREATION
    # =============================================================================
    # Purpose: Create backup directory structure
    # Why needed: Ensures backup directory exists before backup
    
    create_backup_dir "$BACKUP_DIR"
    # Purpose: Create backup directory structure
    # Why needed: Ensures backup directory exists before backup
    # Impact: Backup directory is created and validated
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # KUBERNETES RESOURCES BACKUP
    # =============================================================================
    # Purpose: Backup Kubernetes resources
    # Why needed: Ensures all Kubernetes resources are backed up
    
    backup_kubernetes_resources "$BACKUP_DIR"
    # Purpose: Backup Kubernetes resources
    # Why needed: Ensures all Kubernetes resources are backed up
    # Impact: Kubernetes resources are backed up
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # DATABASE BACKUP
    # =============================================================================
    # Purpose: Backup database data
    # Why needed: Ensures database data is backed up
    
    backup_database "$BACKUP_DIR"
    # Purpose: Backup database data
    # Why needed: Ensures database data is backed up
    # Impact: Database data is backed up
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # PERSISTENT VOLUMES BACKUP
    # =============================================================================
    # Purpose: Backup persistent volume data
    # Why needed: Ensures persistent volume data is backed up
    
    backup_persistent_volumes "$BACKUP_DIR"
    # Purpose: Backup persistent volume data
    # Why needed: Ensures persistent volume data is backed up
    # Impact: Persistent volume data is backed up
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # MONITORING DATA BACKUP
    # =============================================================================
    # Purpose: Backup monitoring data
    # Why needed: Ensures monitoring data is backed up
    
    backup_monitoring_data "$BACKUP_DIR"
    # Purpose: Backup monitoring data
    # Why needed: Ensures monitoring data is backed up
    # Impact: Monitoring data is backed up
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # BACKUP MANIFEST CREATION
    # =============================================================================
    # Purpose: Create backup manifest
    # Why needed: Provides backup metadata and file inventory
    
    create_backup_manifest "$BACKUP_DIR"
    # Purpose: Create backup manifest
    # Why needed: Provides backup metadata and file inventory
    # Impact: Backup manifest is created
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # BACKUP VERIFICATION
    # =============================================================================
    # Purpose: Verify backup integrity
    # Why needed: Ensures backup is complete and valid
    
    verify_backup "$BACKUP_DIR"
    # Purpose: Verify backup integrity
    # Why needed: Ensures backup is complete and valid
    # Impact: Backup is verified for completeness
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # BACKUP COMPRESSION
    # =============================================================================
    # Purpose: Compress backup for efficient storage
    # Why needed: Reduces storage space and provides efficient backup storage
    
    compress_backup "$BACKUP_DIR"
    # Purpose: Compress backup for efficient storage
    # Why needed: Reduces storage space and provides efficient backup storage
    # Impact: Backup is compressed into archive
    # "$BACKUP_DIR": Target backup directory path
    
    # =============================================================================
    # BACKUP COMPLETION
    # =============================================================================
    # Purpose: Log backup completion and information
    # Why needed: Confirms backup was successful and provides information
    
    print_status "SUCCESS" "Backup completed successfully"
    # Purpose: Log success message for backup completion
    # Why needed: Confirms that backup was completed successfully
    # Impact: User knows backup completed successfully
    
    print_status "INFO" "Backup location: $BACKUP_DIR"
    # Purpose: Log backup location
    # Why needed: Shows where backup is stored
    # Impact: User knows backup location
    # $BACKUP_DIR: Shows the backup directory path
    
    print_status "INFO" "Backup log: $BACKUP_LOG"
    # Purpose: Log backup log location
    # Why needed: Shows where backup log is stored
    # Impact: User knows backup log location
    # $BACKUP_LOG: Shows the backup log file path
}

# Function: Restore from backup
restore_from_backup() {
    # =============================================================================
    # RESTORE FROM BACKUP FUNCTION
    # =============================================================================
    # Orchestrates the complete restoration process from backup.
    # Provides comprehensive restoration of all application components.
    # =============================================================================
    
    # Purpose: Restore e-commerce application from backup
    # Why needed: Enables complete restoration of all application components
    # Impact: Restores all application data and configurations
    # Parameters: None (uses global variables)
    # Usage: restore_from_backup
    
    # =============================================================================
    # RESTORE DIRECTORY VALIDATION
    # =============================================================================
    # Purpose: Validate restore directory is specified
    # Why needed: Ensures restore directory is provided
    
    if [ -z "$RESTORE_DIR" ]; then
        # Purpose: Check if restore directory is specified
        # Why needed: Ensures restore directory is provided
        # Impact: Proceeds with restoration if directory is specified
        
        print_status "ERROR" "Restore directory must be specified"
        # Purpose: Log error message for missing restore directory
        # Why needed: Informs user that restore directory is required
        # Impact: User knows restore directory is required
        
        exit 1
        # Purpose: Exit with error status
        # Why needed: Indicates that restoration cannot proceed
        # Impact: Script exits with error status
    fi
    
    # =============================================================================
    # RESTORE DIRECTORY EXISTENCE CHECK
    # =============================================================================
    # Purpose: Check if restore directory exists
    # Why needed: Ensures restore directory is accessible
    
    if [ ! -d "$RESTORE_DIR" ]; then
        # Purpose: Check if restore directory exists
        # Why needed: Ensures restore directory is accessible
        # Impact: Proceeds with restoration if directory exists
        
        print_status "ERROR" "Restore directory not found: $RESTORE_DIR"
        # Purpose: Log error message for missing restore directory
        # Why needed: Informs user that restore directory is missing
        # Impact: User knows restore directory is missing
        # $RESTORE_DIR: Shows the missing restore directory path
        
        exit 1
        # Purpose: Exit with error status
        # Why needed: Indicates that restoration cannot proceed
        # Impact: Script exits with error status
    fi
    
    # =============================================================================
    # RESTORATION INITIATION
    # =============================================================================
    # Purpose: Log restoration initiation and parameters
    # Why needed: Provides visibility into restoration process
    
    print_status "HEADER" "Restoring E-commerce Application from Backup"
    # Purpose: Log restoration initiation header
    # Why needed: Informs user that restoration process is starting
    # Impact: User knows restoration process has begun
    
    print_status "INFO" "Restore Directory: $RESTORE_DIR"
    # Purpose: Log restore directory
    # Why needed: Shows where backup is located
    # Impact: User knows the restore directory
    # $RESTORE_DIR: Shows the restore directory path
    
    # =============================================================================
    # KUBERNETES RESOURCES RESTORATION
    # =============================================================================
    # Purpose: Restore Kubernetes resources
    # Why needed: Ensures all Kubernetes resources are restored
    
    restore_kubernetes_resources "$RESTORE_DIR"
    # Purpose: Restore Kubernetes resources
    # Why needed: Ensures all Kubernetes resources are restored
    # Impact: Kubernetes resources are restored
    # "$RESTORE_DIR": Source restore directory path
    
    # =============================================================================
    # DEPLOYMENT READINESS WAIT
    # =============================================================================
    # Purpose: Wait for deployments to be ready
    # Why needed: Ensures deployments are ready before proceeding
    
    print_status "INFO" "Waiting for deployments to be ready"
    # Purpose: Log readiness wait initiation
    # Why needed: Informs user that deployments are being waited for
    # Impact: User knows readiness wait has begun
    
    kubectl wait --for=condition=available --timeout=300s deployment -l "app=ecommerce" -n "$NAMESPACE"
    # Purpose: Wait for deployments to be ready
    # Why needed: Ensures deployments are ready before proceeding
    # Impact: Deployments are ready for restoration
    # kubectl wait: Wait for condition
    # --for=condition=available: Wait for deployment to be available
    # --timeout=300s: Maximum wait time (5 minutes)
    # deployment: Resource type to wait for
    # -l "app=ecommerce": Label selector for e-commerce deployments
    # -n "$NAMESPACE": Target namespace
    
    # =============================================================================
    # DATABASE RESTORATION
    # =============================================================================
    # Purpose: Restore database data
    # Why needed: Ensures database data is restored
    
    restore_database "$RESTORE_DIR"
    # Purpose: Restore database data
    # Why needed: Ensures database data is restored
    # Impact: Database data is restored
    # "$RESTORE_DIR": Source restore directory path
    
    # =============================================================================
    # PERSISTENT VOLUMES RESTORATION
    # =============================================================================
    # Purpose: Restore persistent volume data
    # Why needed: Ensures persistent volume data is restored
    
    restore_persistent_volumes "$RESTORE_DIR"
    # Purpose: Restore persistent volume data
    # Why needed: Ensures persistent volume data is restored
    # Impact: Persistent volume data is restored
    # "$RESTORE_DIR": Source restore directory path
    
    # =============================================================================
    # RESTORATION COMPLETION
    # =============================================================================
    # Purpose: Log restoration completion
    # Why needed: Confirms restoration was successful
    
    print_status "SUCCESS" "Restore completed successfully"
    # Purpose: Log success message for restoration completion
    # Why needed: Confirms that restoration was completed successfully
    # Impact: User knows restoration completed successfully
}

# Function: List backups
list_backups() {
    # =============================================================================
    # LIST BACKUPS FUNCTION
    # =============================================================================
    # Lists all available backups with metadata.
    # Provides comprehensive backup inventory information.
    # =============================================================================
    
    # Purpose: List all available backups with metadata
    # Why needed: Provides users with backup inventory information
    # Impact: Users can see available backups and their details
    # Parameters: None
    # Usage: list_backups
    
    # =============================================================================
    # LIST INITIATION
    # =============================================================================
    # Purpose: Log list initiation
    # Why needed: Provides visibility into list process
    
    print_status "HEADER" "Available Backups"
    # Purpose: Log list initiation header
    # Why needed: Informs user that backup list is being displayed
    # Impact: User knows backup list is being displayed
    
    # =============================================================================
    # BACKUP DISCOVERY
    # =============================================================================
    # Purpose: Discover available backups
    # Why needed: Provides list of available backups
    
    local backup_base_dir="/tmp"
    # Purpose: Variable to store backup base directory
    # Why needed: Provides base directory for backup search
    # Impact: Will contain the backup base directory path
    # "/tmp": Default backup base directory
    
    local backups
    # Purpose: Variable to store list of backups
    # Why needed: Provides list of available backups
    # Impact: Will contain the list of available backups
    
    backups=$(find "$backup_base_dir" -name "ecommerce-backup-*" -type d -o -name "ecommerce-backup-*.tar.gz" -type f 2>/dev/null | sort -r)
    # Purpose: Find all available backups
    # Why needed: Provides list of available backups
    # Impact: List of backups is retrieved
    # find: Search for files and directories
    # "$backup_base_dir": Base directory to search
    # -name "ecommerce-backup-*": Match backup directory names
    # -type d: Only directories
    # -o: OR operator
    # -name "ecommerce-backup-*.tar.gz": Match backup archive names
    # -type f: Only files
    # 2>/dev/null: Suppress error messages
    # | sort -r: Sort in reverse order (newest first)
    
    # =============================================================================
    # BACKUP LIST DISPLAY
    # =============================================================================
    # Purpose: Display backup list or no backups message
    # Why needed: Provides users with backup information
    
    if [ -z "$backups" ]; then
        # Purpose: Check if no backups found
        # Why needed: Handles case when no backups exist
        # Impact: Proceeds with no backups message if no backups found
        
        print_status "INFO" "No backups found"
        # Purpose: Log no backups message
        # Why needed: Informs user that no backups exist
        # Impact: User knows no backups are available
    else
        # Purpose: Display backup list
        # Why needed: Shows available backups with metadata
        # Impact: User can see available backups
        
        for backup in $backups; do
            # Purpose: Iterate through each backup
            # Why needed: Displays each backup with metadata
            # Impact: Each backup is displayed
            
            local backup_name
            # Purpose: Variable to store backup name
            # Why needed: Provides backup name for display
            # Impact: Will contain the backup name
            
            backup_name=$(basename "$backup")
            # Purpose: Extract backup name from path
            # Why needed: Provides backup name for display
            # Impact: Backup name is extracted
            # basename: Extract filename from path
            # "$backup": Backup path
            
            local backup_size
            # Purpose: Variable to store backup size
            # Why needed: Provides backup size for display
            # Impact: Will contain the backup size
            
            backup_size=$(du -h "$backup" | awk '{print $1}')
            # Purpose: Calculate backup size
            # Why needed: Provides backup size for display
            # Impact: Backup size is calculated
            # du -h: Display disk usage in human-readable format
            # "$backup": Target backup for size calculation
            # | awk '{print $1}': Extract only the size value
            
            local backup_date
            # Purpose: Variable to store backup date
            # Why needed: Provides backup date for display
            # Impact: Will contain the backup date
            
            backup_date=$(stat -c %y "$backup" 2>/dev/null || echo "Unknown")
            # Purpose: Get backup modification date
            # Why needed: Provides backup date for display
            # Impact: Backup date is retrieved
            # stat -c %y: Get modification time
            # "$backup": Target backup for date
            # 2>/dev/null: Suppress error messages
            # || echo "Unknown": Default to "Unknown" if stat fails
            
            print_status "INFO" "$backup_name - $backup_size - $backup_date"
            # Purpose: Log backup information
            # Why needed: Displays backup metadata
            # Impact: User can see backup information
            # $backup_name: Shows the backup name
            # $backup_size: Shows the backup size
            # $backup_date: Shows the backup date
        done
    fi
}

# Function: Cleanup backups
cleanup_backups() {
    # =============================================================================
    # CLEANUP BACKUPS FUNCTION
    # =============================================================================
    # Orchestrates the cleanup of old backups based on retention policy.
    # Provides automated cleanup of old backup data.
    # =============================================================================
    
    # Purpose: Cleanup old backups based on retention policy
    # Why needed: Prevents disk space issues by removing old backups
    # Impact: Frees up disk space by removing old backup data
    # Parameters: None (uses global variables)
    # Usage: cleanup_backups
    
    # =============================================================================
    # CLEANUP INITIATION
    # =============================================================================
    # Purpose: Log cleanup initiation
    # Why needed: Provides visibility into cleanup process
    
    print_status "HEADER" "Cleaning up old backups"
    # Purpose: Log cleanup initiation header
    # Why needed: Informs user that backup cleanup is starting
    # Impact: User knows cleanup process has begun
    
    # =============================================================================
    # CLEANUP EXECUTION
    # =============================================================================
    # Purpose: Execute cleanup of old backups
    # Why needed: Removes old backups based on retention policy
    
    cleanup_old_backups "/tmp" "$RETENTION_DAYS"
    # Purpose: Cleanup old backups
    # Why needed: Removes old backups based on retention policy
    # Impact: Old backups are removed
    # "/tmp": Backup base directory
    # "$RETENTION_DAYS": Retention days for backups
    
    # =============================================================================
    # CLEANUP COMPLETION
    # =============================================================================
    # Purpose: Log cleanup completion
    # Why needed: Confirms cleanup was successful
    
    print_status "SUCCESS" "Backup cleanup completed"
    # Purpose: Log success message for cleanup completion
    # Why needed: Confirms that cleanup was completed successfully
    # Impact: User knows cleanup completed successfully
}

# Function: Verify backup
verify_backup() {
    # =============================================================================
    # VERIFY BACKUP FUNCTION
    # =============================================================================
    # Orchestrates the verification of backup integrity.
    # Provides comprehensive backup validation.
    # =============================================================================
    
    # Purpose: Verify backup integrity and completeness
    # Why needed: Ensures backup is complete and can be restored successfully
    # Impact: Validates backup quality and provides restoration confidence
    # Parameters:
    #   $1: Backup directory path to verify
    # Usage: verify_backup "/tmp/backup-20231201"
    
    local backup_dir=$1
    # Purpose: Specifies the backup directory to verify
    # Why needed: Provides source directory for verification
    # Impact: This directory will be verified for completeness
    # Parameter: $1 is the backup directory path
    
    # =============================================================================
    # BACKUP DIRECTORY VALIDATION
    # =============================================================================
    # Purpose: Validate backup directory is specified
    # Why needed: Ensures backup directory is provided
    
    if [ -z "$backup_dir" ]; then
        # Purpose: Check if backup directory is specified
        # Why needed: Ensures backup directory is provided
        # Impact: Proceeds with verification if directory is specified
        
        print_status "ERROR" "Backup directory must be specified"
        # Purpose: Log error message for missing backup directory
        # Why needed: Informs user that backup directory is required
        # Impact: User knows backup directory is required
        
        exit 1
        # Purpose: Exit with error status
        # Why needed: Indicates that verification cannot proceed
        # Impact: Script exits with error status
    fi
    
    # =============================================================================
    # VERIFICATION INITIATION
    # =============================================================================
    # Purpose: Log verification initiation and parameters
    # Why needed: Provides visibility into verification process
    
    print_status "HEADER" "Verifying Backup"
    # Purpose: Log verification initiation header
    # Why needed: Informs user that backup verification is starting
    # Impact: User knows verification process has begun
    
    print_status "INFO" "Backup Directory: $backup_dir"
    # Purpose: Log backup directory
    # Why needed: Shows which backup is being verified
    # Impact: User knows the backup directory
    # $backup_dir: Shows the backup directory path
    
    # =============================================================================
    # BACKUP VERIFICATION EXECUTION
    # =============================================================================
    # Purpose: Execute backup verification
    # Why needed: Validates backup integrity and completeness
    
    verify_backup "$backup_dir"
    # Purpose: Execute backup verification
    # Why needed: Validates backup integrity and completeness
    # Impact: Backup is verified for completeness
    # "$backup_dir": Target backup directory path
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
# Main execution section that orchestrates the backup script.
# Provides command-line interface and action handling.
# =============================================================================

# =============================================================================
# PREREQUISITES CHECK
# =============================================================================
# Purpose: Check prerequisites before execution
# Why needed: Ensures all required tools and access are available

check_prerequisites
# Purpose: Check prerequisites before execution
# Why needed: Ensures all required tools and access are available
# Impact: Script proceeds only if prerequisites are met

# =============================================================================
# ACTION HANDLING
# =============================================================================
# Purpose: Handle different script actions
# Why needed: Provides command-line interface for different operations

case $ACTION in
    # Purpose: Handle backup action
    # Why needed: Provides backup functionality
    # Impact: Creates comprehensive backup
    
    "backup")
        create_backup
        # Purpose: Execute backup creation
        # Why needed: Creates comprehensive backup
        # Impact: Backup is created
        ;;
    
    # Purpose: Handle restore action
    # Why needed: Provides restore functionality
    # Impact: Restores from backup
    
    "restore")
        restore_from_backup
        # Purpose: Execute restoration from backup
        # Why needed: Restores from backup
        # Impact: Application is restored from backup
        ;;
    
    # Purpose: Handle list action
    # Why needed: Provides backup listing functionality
    # Impact: Lists available backups
    
    "list")
        list_backups
        # Purpose: Execute backup listing
        # Why needed: Lists available backups
        # Impact: Available backups are listed
        ;;
    
    # Purpose: Handle cleanup action
    # Why needed: Provides cleanup functionality
    # Impact: Cleans up old backups
    
    "cleanup")
        cleanup_backups
        # Purpose: Execute backup cleanup
        # Why needed: Cleans up old backups
        # Impact: Old backups are cleaned up
        ;;
    
    # Purpose: Handle verify action
    # Why needed: Provides backup verification functionality
    # Impact: Verifies backup integrity
    
    "verify")
        verify_backup "$BACKUP_DIR"
        # Purpose: Execute backup verification
        # Why needed: Verifies backup integrity
        # Impact: Backup is verified
        # "$BACKUP_DIR": Target backup directory path
        ;;
    
    # Purpose: Handle help action
    # Why needed: Provides help information
    # Impact: Help information is displayed
    
    "help"|"--help"|"-h")
        show_help
        # Purpose: Display help information
        # Why needed: Provides help information
        # Impact: Help information is displayed
        ;;
    
    # Purpose: Handle no action specified
    # Why needed: Provides error handling for missing action
    # Impact: Error message and help are displayed
    
    "")
        print_status "ERROR" "No action specified"
        # Purpose: Log error message for missing action
        # Why needed: Informs user that action is required
        # Impact: User knows action is required
        
        show_help
        # Purpose: Display help information
        # Why needed: Provides help information
        # Impact: Help information is displayed
        exit 1
        # Purpose: Exit with error status
        # Why needed: Indicates that no action was specified
        # Impact: Script exits with error status
        ;;
    
    # Purpose: Handle unknown action
    # Why needed: Provides error handling for unknown actions
    # Impact: Error message and help are displayed
    
    *)
        print_status "ERROR" "Unknown action: $ACTION"
        # Purpose: Log error message for unknown action
        # Why needed: Informs user that action is unknown
        # Impact: User knows action is unknown
        # $ACTION: Shows the unknown action
        
        show_help
        # Purpose: Display help information
        # Why needed: Provides help information
        # Impact: Help information is displayed
        
        exit 1
        # Purpose: Exit with error status
        # Why needed: Indicates that unknown action was specified
        # Impact: Script exits with error status
        ;;
esac
# Purpose: End of case statement
# Why needed: Closes the case statement
# Impact: Action handling is complete
