#!/bin/bash
# =============================================================================
# HEALTH CHECKS VALIDATION SCRIPT
# =============================================================================
# This script performs comprehensive health checks on the e-commerce application
# and infrastructure components to ensure operational readiness and reliability.
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
# Purpose: Red color code for error messages and failed health checks
# Why needed: Provides visual distinction for failed health checks
# Impact: Failed checks are displayed in red color
# Usage: Used in error() function and failed health check results

GREEN='\033[0;32m'
# Purpose: Green color code for success messages and passed health checks
# Why needed: Provides visual distinction for successful health checks
# Impact: Passed checks are displayed in green color
# Usage: Used in success() function and passed health check results

YELLOW='\033[1;33m'
# Purpose: Yellow color code for warning messages and warning health checks
# Why needed: Provides visual distinction for warning health checks
# Impact: Warning checks are displayed in yellow color
# Usage: Used in warning() function and warning health check results

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
# HEALTH CHECK CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent health check configuration throughout the script.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for e-commerce application
# Why needed: Provides consistent namespace reference for health checks
# Impact: All health checks target resources in this namespace
# Value: 'ecommerce' matches the project's application namespace

APP_NAME="ecommerce-backend"
# Purpose: Specifies the backend application name for health checks
# Why needed: Provides consistent reference for backend health validation
# Impact: Backend health checks target this application
# Value: Matches the backend deployment name in manifests

SERVICE_NAME="ecommerce-backend-service"
# Purpose: Specifies the backend service name for connectivity checks
# Why needed: Provides consistent reference for service health validation
# Impact: Service connectivity checks target this service
# Value: Matches the backend service name in manifests

MONITORING_NAMESPACE="monitoring"
# Purpose: Specifies the monitoring components namespace
# Why needed: Provides consistent namespace reference for monitoring health checks
# Impact: Monitoring health checks target resources in this namespace
# Value: 'monitoring' matches the project's monitoring namespace

FRONTEND_APP="ecommerce-frontend"
# Purpose: Specifies the frontend application name for health checks
# Why needed: Provides consistent reference for frontend health validation
# Impact: Frontend health checks target this application
# Value: Matches the frontend deployment name in manifests

DATABASE_APP="ecommerce-database"
# Purpose: Specifies the database application name for health checks
# Why needed: Provides consistent reference for database health validation
# Impact: Database health checks target this application
# Value: Matches the database deployment name in manifests

# =============================================================================
# HEALTH CHECK TRACKING VARIABLES
# =============================================================================
# Variables to track health check results and statistics.
# =============================================================================

HEALTHY=0
# Purpose: Counter for successful health checks
# Why needed: Tracks number of passed health checks
# Impact: Used for health check summary and success rate calculation
# Initial: 0, incremented for each successful check

UNHEALTHY=0
# Purpose: Counter for failed health checks
# Why needed: Tracks number of failed health checks
# Impact: Used for health check summary and failure rate calculation
# Initial: 0, incremented for each failed check

TOTAL_CHECKS=0
# Purpose: Counter for total health checks performed
# Why needed: Tracks total number of health checks executed
# Impact: Used for health check summary and completion percentage
# Initial: 0, incremented for each health check performed

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
# HEALTH CHECK RESULT TRACKING FUNCTIONS
# =============================================================================
# Functions to track and report health check results consistently.
# =============================================================================

health_result() {
    # =============================================================================
    # HEALTH RESULT FUNCTION
    # =============================================================================
    # Records and displays health check results with consistent formatting.
    # =============================================================================
    
    local check_name="$1"
    # Purpose: Specifies the name of the health check
    # Why needed: Provides identification for the health check being reported
    # Impact: Check name appears in result output for identification
    # Parameter: $1 is the health check name string
    
    local result="$2"
    # Purpose: Specifies the result of the health check (PASS/FAIL/WARN)
    # Why needed: Indicates whether the health check succeeded or failed
    # Impact: Determines color and counter updates for the result
    # Parameter: $2 is the result status string
    
    local message="$3"
    # Purpose: Specifies the detailed message for the health check result
    # Why needed: Provides context and details about the health check outcome
    # Impact: Message appears with the result for troubleshooting information
    # Parameter: $3 is the detailed message string
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    # Purpose: Increment total health checks counter
    # Why needed: Tracks total number of health checks performed
    # Impact: Used for summary statistics and completion tracking
    
    case "$result" in
        # Purpose: Handle different health check result types
        # Why needed: Different results require different formatting and counters
        # Impact: Determines output color and counter updates
        
        "PASS")
            # Purpose: Handle successful health check results
            # Why needed: Successful checks should be visually distinct and counted
            # Impact: Displays green success message and increments healthy counter
            
            HEALTHY=$((HEALTHY + 1))
            # Purpose: Increment successful health checks counter
            # Why needed: Tracks number of passed health checks
            # Impact: Used for success rate calculation in summary
            
            echo -e "${GREEN}[✓ PASS]${NC} $check_name: $message"
            # Purpose: Display successful health check result in green
            # Why needed: Provides visual confirmation of successful health check
            # Impact: User sees green checkmark and success message
            ;;
            
        "FAIL")
            # Purpose: Handle failed health check results
            # Why needed: Failed checks should be visually distinct and counted
            # Impact: Displays red failure message and increments unhealthy counter
            
            UNHEALTHY=$((UNHEALTHY + 1))
            # Purpose: Increment failed health checks counter
            # Why needed: Tracks number of failed health checks
            # Impact: Used for failure rate calculation in summary
            
            echo -e "${RED}[✗ FAIL]${NC} $check_name: $message"
            # Purpose: Display failed health check result in red
            # Why needed: Provides visual indication of failed health check
            # Impact: User sees red X mark and failure message
            ;;
            
        "WARN")
            # Purpose: Handle warning health check results
            # Why needed: Warning checks should be visually distinct but not counted as failures
            # Impact: Displays yellow warning message without affecting counters
            
            echo -e "${YELLOW}[⚠ WARN]${NC} $check_name: $message"
            # Purpose: Display warning health check result in yellow
            # Why needed: Provides visual indication of warning condition
            # Impact: User sees yellow warning symbol and warning message
            ;;
            
        *)
            # Purpose: Handle unknown health check result types
            # Why needed: Provides fallback for unexpected result values
            # Impact: Displays unknown result without specific formatting
            
            echo -e "[?] $check_name: $message (Unknown result: $result)"
            # Purpose: Display unknown health check result
            # Why needed: Provides feedback for unexpected result types
            # Impact: User sees question mark and unknown result indication
            ;;
    esac
}
    
    if [[ "$result" == "HEALTHY" ]]; then
        success "✓ $check_name: $message"
        HEALTHY=$((HEALTHY + 1))
    else
        error "✗ $check_name: $message"
        UNHEALTHY=$((UNHEALTHY + 1))
    fi
}

# Function to check cluster health
check_cluster_health() {
    log "Checking cluster health..."
    
    # Check if cluster is accessible
    if kubectl cluster-info &> /dev/null; then
        health_result "Cluster Connectivity" "HEALTHY" "Cluster is accessible"
    else
        health_result "Cluster Connectivity" "UNHEALTHY" "Cannot connect to cluster"
        return 1
    fi
    
    # Check node status
    local ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready" || true)
    local total_nodes=$(kubectl get nodes --no-headers | wc -l)
    
    if [[ $ready_nodes -eq $total_nodes && $total_nodes -gt 0 ]]; then
        health_result "Node Status" "HEALTHY" "All $total_nodes nodes are ready"
    else
        health_result "Node Status" "UNHEALTHY" "Only $ready_nodes out of $total_nodes nodes are ready"
    fi
    
    # Check system pods
    local system_pods=$(kubectl get pods -n kube-system --field-selector=status.phase=Running --no-headers | wc -l)
    local total_system_pods=$(kubectl get pods -n kube-system --no-headers | wc -l)
    
    if [[ $system_pods -eq $total_system_pods && $total_system_pods -gt 0 ]]; then
        health_result "System Pods" "HEALTHY" "All $total_system_pods system pods are running"
    else
        health_result "System Pods" "UNHEALTHY" "Only $system_pods out of $total_system_pods system pods are running"
    fi
}

# Function to check application health
check_application_health() {
    log "Checking application health..."
    
    # Check if namespace exists
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        health_result "Namespace" "HEALTHY" "Namespace $NAMESPACE exists"
    else
        health_result "Namespace" "UNHEALTHY" "Namespace $NAMESPACE does not exist"
        return 1
    fi
    
    # Check deployment status
    local deployment_ready=$(kubectl get deployment $APP_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    local deployment_desired=$(kubectl get deployment $APP_NAME -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    
    if [[ $deployment_ready -eq $deployment_desired && $deployment_desired -gt 0 ]]; then
        health_result "Deployment" "HEALTHY" "Deployment has $deployment_ready/$deployment_desired ready replicas"
    else
        health_result "Deployment" "UNHEALTHY" "Deployment has $deployment_ready/$deployment_desired ready replicas"
    fi
    
    # Check pod status
    local running_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l)
    local total_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --no-headers | wc -l)
    
    if [[ $running_pods -eq $total_pods && $total_pods -gt 0 ]]; then
        health_result "Application Pods" "HEALTHY" "All $total_pods application pods are running"
    else
        health_result "Application Pods" "UNHEALTHY" "Only $running_pods out of $total_pods application pods are running"
    fi
    
    # Check service status
    if kubectl get service $SERVICE_NAME -n $NAMESPACE &> /dev/null; then
        health_result "Service" "HEALTHY" "Service $SERVICE_NAME exists"
    else
        health_result "Service" "UNHEALTHY" "Service $SERVICE_NAME does not exist"
    fi
    
    # Check service endpoints
    local endpoint_count=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
    
    if [[ $endpoint_count -gt 0 ]]; then
        health_result "Service Endpoints" "HEALTHY" "Service has $endpoint_count endpoint(s)"
    else
        health_result "Service Endpoints" "UNHEALTHY" "Service has no endpoints"
    fi
}

# Function to check application connectivity
check_application_connectivity() {
    log "Checking application connectivity..."
    
    # Start port forward in background
    kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE &
    local port_forward_pid=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Check health endpoint
    local health_response
    if health_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/health --max-time 10 2>/dev/null); then
        if [[ "$health_response" == "200" ]]; then
            health_result "Health Endpoint" "HEALTHY" "Health endpoint returns 200 OK"
        else
            health_result "Health Endpoint" "UNHEALTHY" "Health endpoint returns $health_response"
        fi
    else
        health_result "Health Endpoint" "UNHEALTHY" "Cannot connect to health endpoint"
    fi
    
    # Check API docs endpoint
    local docs_response
    if docs_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/docs --max-time 10 2>/dev/null); then
        if [[ "$docs_response" == "200" ]]; then
            health_result "API Docs Endpoint" "HEALTHY" "API docs endpoint returns 200 OK"
        else
            health_result "API Docs Endpoint" "UNHEALTHY" "API docs endpoint returns $docs_response"
        fi
    else
        health_result "API Docs Endpoint" "UNHEALTHY" "Cannot connect to API docs endpoint"
    fi
    
    # Clean up port forward
    kill $port_forward_pid 2>/dev/null || true
}

# Function to check resource health
check_resource_health() {
    log "Checking resource health..."
    
    # Check if metrics are available
    if kubectl top pods -n $NAMESPACE &> /dev/null; then
        # Check CPU usage
        local cpu_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $2}' | head -1 | sed 's/m//' || echo "0")
        local memory_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $3}' | head -1 | sed 's/Mi//' || echo "0")
        
        if [[ -n "$cpu_usage" && -n "$memory_usage" ]]; then
            health_result "Resource Metrics" "HEALTHY" "CPU: ${cpu_usage}m, Memory: ${memory_usage}Mi"
        else
            health_result "Resource Metrics" "UNHEALTHY" "Cannot get resource usage metrics"
        fi
        
        # Check for resource limits
        local cpu_limit=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[0].spec.containers[0].resources.limits.cpu}' 2>/dev/null || echo "unknown")
        local memory_limit=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[0].spec.containers[0].resources.limits.memory}' 2>/dev/null || echo "unknown")
        
        if [[ "$cpu_limit" != "unknown" && "$memory_limit" != "unknown" ]]; then
            health_result "Resource Limits" "HEALTHY" "CPU limit: $cpu_limit, Memory limit: $memory_limit"
        else
            health_result "Resource Limits" "UNHEALTHY" "Resource limits not configured"
        fi
    else
        health_result "Resource Metrics" "UNHEALTHY" "Metrics server not available"
    fi
}

# Function to check monitoring health
check_monitoring_health() {
    log "Checking monitoring health..."
    
    # Check if monitoring namespace exists
    if kubectl get namespace $MONITORING_NAMESPACE &> /dev/null; then
        health_result "Monitoring Namespace" "HEALTHY" "Monitoring namespace exists"
        
        # Check Prometheus
        local prometheus_pods=$(kubectl get pods -n $MONITORING_NAMESPACE -l app=prometheus --field-selector=status.phase=Running --no-headers | wc -l)
        if [[ $prometheus_pods -gt 0 ]]; then
            health_result "Prometheus" "HEALTHY" "Prometheus is running"
        else
            health_result "Prometheus" "UNHEALTHY" "Prometheus is not running"
        fi
        
        # Check Grafana
        local grafana_pods=$(kubectl get pods -n $MONITORING_NAMESPACE -l app=grafana --field-selector=status.phase=Running --no-headers | wc -l)
        if [[ $grafana_pods -gt 0 ]]; then
            health_result "Grafana" "HEALTHY" "Grafana is running"
        else
            health_result "Grafana" "UNHEALTHY" "Grafana is not running"
        fi
    else
        health_result "Monitoring Namespace" "UNHEALTHY" "Monitoring namespace does not exist"
    fi
}

# Function to check security health
check_security_health() {
    log "Checking security health..."
    
    # Check if pods are running as non-root
    local non_root_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[0].spec.securityContext.runAsNonRoot}' 2>/dev/null || echo "false")
    
    if [[ "$non_root_pods" == "true" ]]; then
        health_result "Non-Root Pods" "HEALTHY" "Pods are running as non-root"
    else
        health_result "Non-Root Pods" "UNHEALTHY" "Pods are not configured to run as non-root"
    fi
    
    # Check if read-only root filesystem is enabled
    local read_only_fs=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE -o jsonpath='{.items[0].spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || echo "false")
    
    if [[ "$read_only_fs" == "true" ]]; then
        health_result "Read-Only Root FS" "HEALTHY" "Pods have read-only root filesystem"
    else
        health_result "Read-Only Root FS" "UNHEALTHY" "Pods do not have read-only root filesystem"
    fi
    
    # Check if RBAC is configured
    local roles=$(kubectl get roles -n $NAMESPACE --no-headers | wc -l)
    local rolebindings=$(kubectl get rolebindings -n $NAMESPACE --no-headers | wc -l)
    
    if [[ $roles -gt 0 && $rolebindings -gt 0 ]]; then
        health_result "RBAC Configuration" "HEALTHY" "RBAC is configured with $roles roles and $rolebindings role bindings"
    else
        health_result "RBAC Configuration" "UNHEALTHY" "RBAC is not properly configured"
    fi
}

# Function to check network health
check_network_health() {
    log "Checking network health..."
    
    # Check if CNI is working
    local cni_pods=$(kubectl get pods -n kube-system -l app=flannel --field-selector=status.phase=Running --no-headers | wc -l)
    
    if [[ $cni_pods -gt 0 ]]; then
        health_result "CNI Plugin" "HEALTHY" "Flannel CNI is running"
    else
        health_result "CNI Plugin" "UNHEALTHY" "Flannel CNI is not running"
    fi
    
    # Check pod-to-pod communication
    local pod1=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | head -1 | awk '{print $1}')
    
    if [[ -n "$pod1" ]]; then
        if kubectl exec $pod1 -n $NAMESPACE -- ping -c 1 8.8.8.8 &> /dev/null; then
            health_result "External Connectivity" "HEALTHY" "Pods can reach external networks"
        else
            health_result "External Connectivity" "UNHEALTHY" "Pods cannot reach external networks"
        fi
    else
        health_result "External Connectivity" "UNHEALTHY" "No running pods found for connectivity test"
    fi
}

# Function to run all health checks
run_health_checks() {
    log "Starting comprehensive health checks..."
    echo ""
    
    check_cluster_health
    check_application_health
    check_application_connectivity
    check_resource_health
    check_monitoring_health
    check_security_health
    check_network_health
    
    echo ""
    log "Health checks completed"
}

# Function to show health check results
show_results() {
    echo ""
    echo "=========================================="
    echo "HEALTH CHECK RESULTS"
    echo "=========================================="
    echo ""
    echo "Total Checks: $TOTAL_CHECKS"
    echo "Healthy: $HEALTHY"
    echo "Unhealthy: $UNHEALTHY"
    echo ""
    
    local health_percentage=$((HEALTHY * 100 / TOTAL_CHECKS))
    
    if [[ $UNHEALTHY -eq 0 ]]; then
        success "All health checks passed! System is 100% healthy."
        exit 0
    elif [[ $health_percentage -ge 80 ]]; then
        warning "System is mostly healthy ($health_percentage%). $UNHEALTHY issue(s) need attention."
        exit 1
    else
        error "System is unhealthy ($health_percentage%). $UNHEALTHY critical issue(s) found."
        exit 2
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help                 Show this help message"
    echo "  --namespace NAMESPACE  Override default namespace (default: ecommerce)"
    echo "  --monitoring-namespace NAMESPACE  Override monitoring namespace (default: monitoring)"
    echo ""
    echo "Examples:"
    echo "  $0                     Run health checks with default settings"
    echo "  $0 --namespace prod    Run health checks in prod namespace"
    echo "  $0 --monitoring-namespace observability  Use observability namespace for monitoring"
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
            --monitoring-namespace)
                MONITORING_NAMESPACE="$2"
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
    echo "E-commerce Application Health Checks"
    echo "=========================================="
    echo ""
    echo "Configuration:"
    echo "- Application Namespace: $NAMESPACE"
    echo "- Monitoring Namespace: $MONITORING_NAMESPACE"
    echo "- Application: $APP_NAME"
    echo "- Service: $SERVICE_NAME"
    echo ""
    
    run_health_checks
    show_results
}

# Run main function
main "$@"
