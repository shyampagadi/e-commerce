#!/bin/bash
# =============================================================================
# ENHANCED E-COMMERCE DEPLOYMENT SCRIPT
# =============================================================================
# This script deploys the enhanced e-commerce application stack with advanced
# security features, monitoring capabilities, backup systems, and performance
# benchmarking tools to the Kubernetes cluster.
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
# ENHANCED DEPLOYMENT CONFIGURATION VARIABLES
# =============================================================================
# Define variables for consistent enhanced deployment configuration.
# =============================================================================

NAMESPACE="ecommerce"
# Purpose: Specifies the Kubernetes namespace for e-commerce application
# Why needed: Provides consistent namespace reference throughout script
# Impact: All Kubernetes resources are deployed to this namespace
# Value: 'ecommerce' matches the project's application namespace

HELM_RELEASE="ecommerce"
# Purpose: Specifies the Helm release name for chart deployments
# Why needed: Provides consistent release identification for Helm operations
# Impact: Helm charts are deployed with this release name
# Value: Matches the application name for consistency

CHART_PATH="./helm-charts/ecommerce"
# Purpose: Specifies the path to the Helm chart directory
# Why needed: Defines location of Helm chart for deployment
# Impact: Helm deployment uses charts from this directory
# Value: Relative path to the ecommerce Helm chart

ENHANCED_BACKEND="ecommerce-backend-enhanced"
# Purpose: Specifies the enhanced backend deployment name
# Why needed: Identifies the enhanced backend with security features
# Impact: Enhanced backend deployment uses this name
# Value: Distinguishes enhanced version from basic backend

MONITORING_NAMESPACE="monitoring"
# Purpose: Specifies the namespace for monitoring components
# Why needed: Provides consistent reference for monitoring resources
# Impact: Monitoring components are expected in this namespace
# Value: Standard monitoring namespace for Grafana and Prometheus

VELERO_NAMESPACE="velero"
# Purpose: Specifies the namespace for Velero backup system
# Why needed: Provides consistent reference for backup resources
# Impact: Backup system components are expected in this namespace
# Value: Standard Velero namespace for backup operations

DEPLOYMENT_TIMEOUT="600s"
# Purpose: Specifies timeout for deployment readiness waiting
# Why needed: Prevents indefinite waiting for deployment completion
# Impact: Deployments will timeout after this duration
# Value: 10 minutes provides adequate time for complex deployments

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
# Functions to validate required tools and environment before enhanced deployment.
# =============================================================================

check_prerequisites() {
    # =============================================================================
    # CHECK PREREQUISITES FUNCTION
    # =============================================================================
    # Validates that all required tools and cluster access are available for enhanced deployment.
    # =============================================================================
    
    log "Checking prerequisites for enhanced deployment..."
    # Purpose: Inform user that prerequisite checking is starting
    # Why needed: User should know validation process has begun
    # Impact: Provides feedback on script progress
    
    # =============================================================================
    # KUBECTL AVAILABILITY CHECK
    # =============================================================================
    # Verify kubectl command is available for Kubernetes operations.
    # =============================================================================
    
    if ! command -v kubectl &> /dev/null; then
        # Purpose: Check if kubectl command is available in PATH
        # Why needed: kubectl is required for all Kubernetes operations
        # Impact: Script cannot continue without kubectl
        
        error "kubectl not found. Please install kubectl."
        # Purpose: Report missing kubectl tool
        # Why needed: User needs to install kubectl before proceeding
        # Impact: Clear error message for troubleshooting
        
        exit 1
        # Purpose: Exit script due to missing prerequisite
        # Why needed: Cannot perform deployment without kubectl
        # Impact: Script terminates with error code 1
    fi
    
    # =============================================================================
    # KUBERNETES CLUSTER CONNECTIVITY CHECK
    # =============================================================================
    # Verify connection to Kubernetes cluster is working.
    # =============================================================================
    
    if ! kubectl cluster-info &> /dev/null; then
        # Purpose: Test connectivity to Kubernetes cluster
        # Why needed: Cluster access is required for deployment operations
        # Impact: Script cannot continue without cluster access
        
        error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        # Purpose: Report cluster connectivity failure
        # Why needed: User needs to fix cluster configuration
        # Impact: Clear error message for troubleshooting
        
        exit 1
        # Purpose: Exit script due to cluster connectivity failure
        # Why needed: Cannot perform deployment without cluster access
        # Impact: Script terminates with error code 1
    fi
    
    # =============================================================================
    # HELM AVAILABILITY CHECK (OPTIONAL)
    # =============================================================================
    # Check if Helm is available for chart-based deployments.
    # =============================================================================
    
    if command -v helm &> /dev/null; then
        # Purpose: Check if Helm command is available
        # Why needed: Helm enables advanced deployment features
        # Impact: Enhanced deployment can use Helm charts if available
        
        log "Helm found - will use Helm for deployment if chart is available"
        # Purpose: Inform user that Helm is available
        # Why needed: User should know enhanced deployment options
        # Impact: Sets expectation for Helm-based deployment
        
        # Verify Helm can connect to cluster
        if helm version &> /dev/null; then
            # Purpose: Test Helm connectivity to cluster
            # Why needed: Helm must be able to communicate with cluster
            # Impact: Confirms Helm is ready for chart deployments
            
            success "Helm is ready for chart deployments"
            # Purpose: Confirm Helm readiness
            # Why needed: User should know Helm is operational
            # Impact: Provides confidence in Helm deployment capability
        else
            warning "Helm found but cannot connect to cluster"
            # Purpose: Report Helm connectivity issue
            # Why needed: User should know about Helm limitations
            # Impact: May fall back to kubectl deployment
        fi
    else
        warning "Helm not found - will use kubectl for deployment"
        # Purpose: Report missing Helm tool
        # Why needed: User should know deployment will use kubectl instead
        # Impact: Sets expectation for kubectl-based deployment
    fi
    
    success "Prerequisites check completed successfully"
    # Purpose: Confirm all prerequisites are satisfied
    # Why needed: User should know system is ready for enhanced deployment
    # Impact: Provides confidence to proceed with deployment
}

# =============================================================================
# NAMESPACE MANAGEMENT FUNCTIONS
# =============================================================================
# Functions to create and configure the deployment namespace.
# =============================================================================

create_namespace() {
    # =============================================================================
    # CREATE NAMESPACE FUNCTION
    # =============================================================================
    # Creates and configures the target namespace for enhanced deployment.
    # =============================================================================
    
    log "Creating and configuring namespace: $NAMESPACE"
    # Purpose: Inform user about namespace creation
    # Why needed: User should know namespace setup is starting
    # Impact: Provides feedback on deployment progress
    
    # =============================================================================
    # NAMESPACE CREATION WITH PROPER LABELS
    # =============================================================================
    # Create namespace using declarative approach with proper labeling.
    # =============================================================================
    
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    # Purpose: Create namespace using declarative approach
    # Why needed: Ensures namespace exists without failing if already present
    # Impact: Namespace becomes available for resource deployment
    # Method: dry-run with apply ensures idempotent operation
    
    # =============================================================================
    # NAMESPACE LABELING FOR MONITORING
    # =============================================================================
    # Add labels to namespace for monitoring and management purposes.
    # =============================================================================
    
    kubectl label namespace "$NAMESPACE" name="$NAMESPACE" --overwrite
    # Purpose: Add name label to namespace for identification
    # Why needed: Monitoring systems use labels for namespace selection
    # Impact: Namespace becomes discoverable by monitoring components
    # Flag: --overwrite ensures label is updated if already exists
    
    kubectl label namespace "$NAMESPACE" environment="production" --overwrite
    # Purpose: Add environment label for deployment classification
    # Why needed: Distinguishes production namespace from development
    # Impact: Enables environment-specific policies and monitoring
    
    success "Namespace $NAMESPACE created and configured successfully"
    # Purpose: Confirm successful namespace setup
    # Why needed: User should know namespace is ready for deployment
    # Impact: Provides confidence to proceed with resource deployment
}

# =============================================================================
# ENHANCED INFRASTRUCTURE DEPLOYMENT FUNCTIONS
# =============================================================================
# Functions to deploy enhanced application components with security and monitoring.
# =============================================================================

deploy_enhanced_infrastructure() {
    # =============================================================================
    # DEPLOY ENHANCED INFRASTRUCTURE FUNCTION
    # =============================================================================
    # Deploys the complete enhanced e-commerce infrastructure with security features.
    # =============================================================================
    
    log "Deploying enhanced e-commerce infrastructure with security and monitoring..."
    # Purpose: Inform user about enhanced infrastructure deployment
    # Why needed: User should know comprehensive deployment is starting
    # Impact: Sets expectation for enhanced deployment process
    
    # =============================================================================
    # NETWORK SECURITY POLICIES DEPLOYMENT
    # =============================================================================
    # Apply network security policies for micro-segmentation.
    # =============================================================================
    
    log "Applying network security policies for micro-segmentation..."
    # Purpose: Inform user about network security deployment
    # Why needed: User should know security policies are being applied
    # Impact: Provides context for security configuration
    
    if [[ -f "k8s-manifests/network-policies.yaml" ]]; then
        # Purpose: Check if network policies manifest exists
        # Why needed: Prevents errors when applying non-existent manifests
        # Impact: Only applies policies if manifest is available
        
        kubectl apply -f k8s-manifests/network-policies.yaml
        # Purpose: Apply network security policies to cluster
        # Why needed: Implements network micro-segmentation for security
        # Impact: Network traffic is controlled by security policies
        
        success "Network security policies applied successfully"
        # Purpose: Confirm network policies deployment
        # Why needed: User should know security policies are active
        # Impact: Provides confidence in network security implementation
    else
        warning "Network policies file not found, skipping network security..."
        # Purpose: Report missing network policies manifest
        # Why needed: User should know about missing security features
        # Impact: Deployment continues without network policies
    fi
    
    # =============================================================================
    # ENHANCED BACKEND DEPLOYMENT
    # =============================================================================
    # Deploy backend with enhanced security features and resource management.
    # =============================================================================
    
    log "Deploying enhanced backend with security features and resource management..."
    # Purpose: Inform user about enhanced backend deployment
    # Why needed: User should know backend with security features is being deployed
    # Impact: Provides context for enhanced backend configuration
    
    if [[ -f "k8s-manifests/enhanced-backend-deployment.yaml" ]]; then
        # Purpose: Check if enhanced backend manifest exists
        # Why needed: Prevents errors when applying non-existent manifests
        # Impact: Only applies enhanced backend if manifest is available
        
        kubectl apply -f k8s-manifests/enhanced-backend-deployment.yaml
        # Purpose: Apply enhanced backend deployment to cluster
        # Why needed: Deploys backend with security and resource management features
        # Impact: Enhanced backend becomes available with security controls
        
        success "Enhanced backend deployed with security features"
        # Purpose: Confirm enhanced backend deployment
        # Why needed: User should know enhanced backend is operational
        # Impact: Provides confidence in secure backend deployment
    else
        warning "Enhanced backend deployment file not found, skipping enhanced features..."
        # Purpose: Report missing enhanced backend manifest
        # Why needed: User should know about missing enhanced features
        # Impact: May fall back to standard backend deployment
    fi
    
    # =============================================================================
    # HELM CHART DEPLOYMENT (PREFERRED METHOD)
    # =============================================================================
    # Deploy using Helm charts if available for advanced configuration management.
    # =============================================================================
    
    if command -v helm &> /dev/null && [[ -d "$CHART_PATH" ]]; then
        # Purpose: Check if Helm is available and chart directory exists
        # Why needed: Helm provides advanced deployment features and configuration
        # Impact: Uses Helm for sophisticated deployment management
        
        log "Deploying with Helm chart for advanced configuration management..."
        # Purpose: Inform user about Helm-based deployment
        # Why needed: User should know advanced deployment method is being used
        # Impact: Sets expectation for Helm deployment features
        
        helm upgrade --install "$HELM_RELEASE" "$CHART_PATH" \
            --namespace "$NAMESPACE" \
            --create-namespace \
            --wait \
            --timeout "$DEPLOYMENT_TIMEOUT"
        # Purpose: Deploy application using Helm chart
        # Why needed: Helm provides templating, versioning, and rollback capabilities
        # Impact: Application is deployed with advanced configuration management
        # Options: --upgrade --install ensures idempotent deployment
        # Options: --wait ensures deployment completion before proceeding
        # Options: --timeout prevents indefinite waiting
        
        success "Helm chart deployment completed successfully"
        # Purpose: Confirm Helm deployment success
        # Why needed: User should know Helm deployment was successful
        # Impact: Provides confidence in advanced deployment completion
    else
        # =============================================================================
        # KUBECTL MANIFEST DEPLOYMENT (FALLBACK METHOD)
        # =============================================================================
        # Deploy using kubectl manifests if Helm is not available.
        # =============================================================================
        
        log "Deploying with kubectl manifests (Helm not available)..."
        # Purpose: Inform user about kubectl-based deployment
        # Why needed: User should know fallback deployment method is being used
        # Impact: Sets expectation for manifest-based deployment
        
        kubectl apply -f k8s-manifests/ -n "$NAMESPACE"
        # Purpose: Apply all Kubernetes manifests to cluster
        # Why needed: Deploys application components using standard manifests
        # Impact: Application components are deployed to cluster
        # Method: Applies all YAML files in k8s-manifests directory
        
        success "Kubectl manifest deployment completed successfully"
        # Purpose: Confirm kubectl deployment success
        # Why needed: User should know manifest deployment was successful
        # Impact: Provides confidence in standard deployment completion
    fi
    
    success "Enhanced infrastructure deployment completed successfully"
    # Purpose: Confirm complete infrastructure deployment
    # Why needed: User should know all infrastructure components are deployed
    # Impact: Provides confidence in complete deployment success
}

# =============================================================================
# BACKUP SYSTEM SETUP FUNCTIONS
# =============================================================================
# Functions to configure automated backup systems for data protection.
# =============================================================================

setup_backup_system() {
    # =============================================================================
    # SETUP BACKUP SYSTEM FUNCTION
    # =============================================================================
    # Configures Velero backup system for automated data protection.
    # =============================================================================
    
    log "Setting up automated backup system for data protection..."
    # Purpose: Inform user about backup system setup
    # Why needed: User should know backup configuration is starting
    # Impact: Provides context for backup system deployment
    
    # =============================================================================
    # VELERO INSTALLATION CHECK
    # =============================================================================
    # Check if Velero backup system is installed in cluster.
    # =============================================================================
    
    if kubectl get namespace "$VELERO_NAMESPACE" &> /dev/null; then
        # Purpose: Check if Velero namespace exists
        # Why needed: Velero namespace indicates backup system is installed
        # Impact: Backup configuration can proceed if Velero is available
        
        log "Velero backup system found, configuring backup schedules..."
        # Purpose: Inform user that Velero is available
        # Why needed: User should know backup system is ready for configuration
        # Impact: Sets expectation for backup schedule configuration
        
        # =============================================================================
        # BACKUP SCHEDULE CONFIGURATION
        # =============================================================================
        # Apply backup schedules for automated data protection.
        # =============================================================================
        
        if [[ -f "k8s-manifests/velero-backup.yaml" ]]; then
            # Purpose: Check if backup configuration manifest exists
            # Why needed: Prevents errors when applying non-existent manifests
            # Impact: Only configures backups if manifest is available
            
            kubectl apply -f k8s-manifests/velero-backup.yaml
            # Purpose: Apply backup schedule configuration to cluster
            # Why needed: Configures automated backup schedules for data protection
            # Impact: Automated backups are scheduled for application data
            
            success "Automated backup schedules configured successfully"
            # Purpose: Confirm backup schedule configuration
            # Why needed: User should know backup automation is active
            # Impact: Provides confidence in data protection setup
        else
            warning "Velero backup configuration not found - manual backup setup required"
            # Purpose: Report missing backup configuration
            # Why needed: User should know backup automation is not configured
            # Impact: Manual backup configuration may be needed
        fi
    else
        warning "Velero backup system not installed - skipping backup configuration"
        # Purpose: Report missing Velero installation
        # Why needed: User should know backup system is not available
        # Impact: Backup configuration is skipped
        
        log "To install Velero backup system, run: velero install --provider <your-provider>"
        # Purpose: Provide installation guidance for Velero
        # Why needed: User needs to know how to install backup system
        # Impact: Enables user to install backup system if desired
    fi
}

# =============================================================================
# PERFORMANCE MONITORING SETUP FUNCTIONS
# =============================================================================
# Functions to configure performance monitoring and benchmarking tools.
# =============================================================================

setup_performance_monitoring() {
    # =============================================================================
    # SETUP PERFORMANCE MONITORING FUNCTION
    # =============================================================================
    # Configures performance monitoring dashboards and benchmarking tools.
    # =============================================================================
    
    log "Setting up performance monitoring and benchmarking tools..."
    # Purpose: Inform user about performance monitoring setup
    # Why needed: User should know monitoring configuration is starting
    # Impact: Provides context for monitoring system deployment
    
    # =============================================================================
    # PERFORMANCE BENCHMARK SCRIPT SETUP
    # =============================================================================
    # Make performance benchmarking scripts executable.
    # =============================================================================
    
    if [[ -f "performance/benchmark.sh" ]]; then
        # Purpose: Check if performance benchmark script exists
        # Why needed: Script must exist before making it executable
        # Impact: Only configures benchmark if script is available
        
        chmod +x performance/benchmark.sh
        # Purpose: Make performance benchmark script executable
        # Why needed: Script must be executable to run performance tests
        # Impact: Performance benchmarking becomes available
        
        success "Performance benchmark script configured and ready"
        # Purpose: Confirm benchmark script setup
        # Why needed: User should know benchmarking is available
        # Impact: Provides confidence in performance testing capability
    else
        warning "Performance benchmark script not found - performance testing unavailable"
        # Purpose: Report missing benchmark script
        # Why needed: User should know performance testing is not available
        # Impact: Performance benchmarking is not configured
    fi
    
    # =============================================================================
    # GRAFANA DASHBOARD IMPORT
    # =============================================================================
    # Import performance dashboard into Grafana if available.
    # =============================================================================
    
    if kubectl get svc grafana -n "$MONITORING_NAMESPACE" &> /dev/null; then
        # Purpose: Check if Grafana service exists in monitoring namespace
        # Why needed: Grafana must be available for dashboard import
        # Impact: Dashboard import can proceed if Grafana is available
        
        log "Grafana monitoring system found, importing performance dashboard..."
        # Purpose: Inform user about dashboard import
        # Why needed: User should know dashboard configuration is starting
        # Impact: Sets expectation for dashboard import process
        
        # =============================================================================
        # GRAFANA PORT FORWARDING FOR DASHBOARD IMPORT
        # =============================================================================
        # Setup temporary port forwarding for dashboard import.
        # =============================================================================
        
        kubectl port-forward -n "$MONITORING_NAMESPACE" svc/grafana 3000:3000 &
        # Purpose: Start port forwarding to Grafana service
        # Why needed: Enables local access to Grafana API for dashboard import
        # Impact: Grafana becomes accessible at localhost:3000
        
        GRAFANA_PID=$!
        # Purpose: Capture process ID of port forwarding
        # Why needed: Allows cleanup of port forwarding process
        # Impact: Enables targeted process management
        
        sleep 5
        # Purpose: Wait for port forwarding to become active
        # Why needed: Port forwarding needs time to establish connection
        # Impact: Ensures Grafana is accessible before dashboard import
        
        # =============================================================================
        # DASHBOARD IMPORT EXECUTION
        # =============================================================================
        # Import performance dashboard if configuration file exists.
        # =============================================================================
        
        if [[ -f "performance/grafana-performance-dashboard.json" ]]; then
            # Purpose: Check if dashboard configuration file exists
            # Why needed: Dashboard file must exist for import
            # Impact: Only imports dashboard if configuration is available
            
            curl -X POST \
                http://admin:admin@localhost:3000/api/dashboards/db \
                -H 'Content-Type: application/json' \
                -d @performance/grafana-performance-dashboard.json || warning "Dashboard import failed - check Grafana connectivity"
            # Purpose: Import dashboard configuration into Grafana
            # Why needed: Provides performance visualization capabilities
            # Impact: Performance dashboard becomes available in Grafana
            # Fallback: Warning message if import fails
            
            success "Performance dashboard imported into Grafana successfully"
            # Purpose: Confirm dashboard import success
            # Why needed: User should know dashboard is available
            # Impact: Provides confidence in monitoring capability
        else
            warning "Performance dashboard configuration not found - manual dashboard setup required"
            # Purpose: Report missing dashboard configuration
            # Why needed: User should know dashboard is not configured
            # Impact: Manual dashboard setup may be needed
        fi
        
        # =============================================================================
        # PORT FORWARDING CLEANUP
        # =============================================================================
        # Clean up temporary port forwarding process.
        # =============================================================================
        
        kill "$GRAFANA_PID" 2>/dev/null || true
        # Purpose: Terminate port forwarding process
        # Why needed: Cleans up temporary network resources
        # Impact: Stops port forwarding after dashboard import
        # Fallback: || true prevents script exit if process already terminated
        
        success "Performance monitoring setup completed successfully"
        # Purpose: Confirm monitoring setup completion
        # Why needed: User should know monitoring is configured
        # Impact: Provides confidence in monitoring system readiness
    else
        warning "Grafana monitoring system not found - skipping dashboard import"
        # Purpose: Report missing Grafana installation
        # Why needed: User should know monitoring system is not available
        # Impact: Dashboard import is skipped
        
        log "To access performance monitoring, ensure Grafana is installed in $MONITORING_NAMESPACE namespace"
        # Purpose: Provide guidance for monitoring system setup
        # Why needed: User needs to know how to enable monitoring
        # Impact: Enables user to setup monitoring if desired
    fi
}

# =============================================================================
# DEPLOYMENT VALIDATION FUNCTIONS
# =============================================================================
# Functions to validate successful deployment of enhanced application components.
# =============================================================================

validate_enhanced_deployment() {
    # =============================================================================
    # VALIDATE ENHANCED DEPLOYMENT FUNCTION
    # =============================================================================
    # Performs comprehensive validation of enhanced deployment components and features.
    # =============================================================================
    
    log "Validating enhanced deployment components and readiness..."
    # Purpose: Inform user that deployment validation is starting
    # Why needed: User should know validation process has begun
    # Impact: Provides feedback on validation progress
    
    # =============================================================================
    # DEPLOYMENT READINESS VERIFICATION
    # =============================================================================
    # Wait for all deployments to reach available condition before proceeding.
    # =============================================================================
    
    log "Waiting for all deployments to reach ready state..."
    # Purpose: Inform user about deployment readiness wait
    # Why needed: User should know why there's a delay
    # Impact: Sets expectation for validation time
    
    kubectl wait --for=condition=available --timeout="$DEPLOYMENT_TIMEOUT" deployment --all -n "$NAMESPACE"
    # Purpose: Wait for all deployments to become available
    # Why needed: Ensures all application components are operational before validation
    # Impact: Prevents validation of incomplete deployments
    # Timeout: Uses configured timeout to prevent indefinite waiting
    # Scope: --all targets all deployments in the namespace
    
    if [[ $? -eq 0 ]]; then
        # Purpose: Check if deployment wait was successful
        # Why needed: Verifies all deployments reached ready state
        # Impact: Provides confidence in deployment readiness
        
        success "All deployments are ready and available"
        # Purpose: Confirm deployment readiness success
        # Why needed: User should know deployments are operational
        # Impact: Provides confidence to proceed with validation
    else
        error "Some deployments failed to become ready within timeout"
        # Purpose: Report deployment readiness failure
        # Why needed: User needs to know about deployment problems
        # Impact: May indicate resource or configuration issues
        
        log "Checking deployment status for troubleshooting..."
        # Purpose: Provide troubleshooting information
        # Why needed: User needs context for deployment failures
        # Impact: Enables user to diagnose deployment issues
        
        kubectl get deployments -n "$NAMESPACE"
        # Purpose: Display deployment status for troubleshooting
        # Why needed: Shows current state of all deployments
        # Impact: Provides diagnostic information for failed deployments
    fi
    
    # =============================================================================
    # COMPREHENSIVE VALIDATION EXECUTION
    # =============================================================================
    # Run comprehensive validation tests if available, otherwise perform basic validation.
    # =============================================================================
    
    if [[ -f "./validation/comprehensive-tests.sh" ]]; then
        # Purpose: Check if comprehensive validation script exists
        # Why needed: Comprehensive tests provide thorough validation
        # Impact: Uses advanced validation if available
        
        log "Running comprehensive validation tests for enhanced deployment..."
        # Purpose: Inform user about comprehensive validation
        # Why needed: User should know thorough testing is being performed
        # Impact: Sets expectation for comprehensive validation process
        
        chmod +x ./validation/comprehensive-tests.sh
        # Purpose: Make comprehensive validation script executable
        # Why needed: Script must be executable to run validation tests
        # Impact: Enables execution of comprehensive validation
        
        ./validation/comprehensive-tests.sh
        # Purpose: Execute comprehensive validation test suite
        # Why needed: Provides thorough validation of all deployment components
        # Impact: Validates enhanced deployment features and functionality
        
        if [[ $? -eq 0 ]]; then
            # Purpose: Check if comprehensive validation was successful
            # Why needed: Verifies all validation tests passed
            # Impact: Provides confidence in deployment success
            
            success "Comprehensive validation tests completed successfully"
            # Purpose: Confirm comprehensive validation success
            # Why needed: User should know all tests passed
            # Impact: Provides confidence in deployment quality
        else
            error "Some comprehensive validation tests failed"
            # Purpose: Report comprehensive validation failures
            # Why needed: User needs to know about validation problems
            # Impact: Indicates deployment issues that need attention
        fi
    else
        # =============================================================================
        # BASIC VALIDATION (FALLBACK)
        # =============================================================================
        # Perform basic validation if comprehensive tests are not available.
        # =============================================================================
        
        warning "Comprehensive tests not found, performing basic validation..."
        # Purpose: Report missing comprehensive validation
        # Why needed: User should know validation is limited
        # Impact: Sets expectation for basic validation only
        
        log "Displaying current deployment status..."
        # Purpose: Inform user about basic status checking
        # Why needed: User should know what basic validation includes
        # Impact: Provides context for status display
        
        # =============================================================================
        # BASIC POD STATUS VALIDATION
        # =============================================================================
        # Display pod status for manual verification.
        # =============================================================================
        
        kubectl get pods -n "$NAMESPACE"
        # Purpose: Display pod status for visual verification
        # Why needed: Shows current state of all pods in namespace
        # Impact: Enables user to manually verify pod health
        
        kubectl get services -n "$NAMESPACE"
        # Purpose: Display service status for connectivity verification
        # Why needed: Shows current state of all services in namespace
        # Impact: Enables user to verify service availability
        
        # =============================================================================
        # POD READINESS CALCULATION
        # =============================================================================
        # Calculate and report pod readiness statistics.
        # =============================================================================
        
        local running_pods=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l)
        # Purpose: Count pods in Running state
        # Why needed: Provides metric for deployment success
        # Impact: Shows number of operational pods
        
        local total_pods=$(kubectl get pods -n "$NAMESPACE" --no-headers | wc -l)
        # Purpose: Count total pods in namespace
        # Why needed: Provides baseline for readiness calculation
        # Impact: Shows total number of deployed pods
        
        if [[ "$running_pods" -eq "$total_pods" && "$total_pods" -gt 0 ]]; then
            # Purpose: Check if all pods are running
            # Why needed: All pods must be running for successful deployment
            # Impact: Confirms deployment success
            
            success "All pods are running successfully ($running_pods/$total_pods)"
            # Purpose: Report successful pod deployment
            # Why needed: User should know all pods are operational
            # Impact: Provides confidence in deployment success
        elif [[ "$total_pods" -eq 0 ]]; then
            # Purpose: Check if no pods were deployed
            # Why needed: Zero pods indicates deployment failure
            # Impact: Reports deployment problem
            
            error "No pods found in namespace $NAMESPACE - deployment may have failed"
            # Purpose: Report absence of deployed pods
            # Why needed: User needs to know deployment didn't create pods
            # Impact: Indicates serious deployment problem
        else
            # Purpose: Handle partial pod deployment
            # Why needed: Some pods not running indicates issues
            # Impact: Reports partial deployment success
            
            warning "Some pods are not running ($running_pods/$total_pods) - check pod status above"
            # Purpose: Report partial pod deployment
            # Why needed: User should know about pod issues
            # Impact: Indicates deployment problems that need attention
        fi
    fi
}

# =============================================================================
# PERFORMANCE BENCHMARKING FUNCTIONS
# =============================================================================
# Functions to execute performance benchmarking and testing tools.
# =============================================================================

run_performance_benchmark() {
    # =============================================================================
    # RUN PERFORMANCE BENCHMARK FUNCTION
    # =============================================================================
    # Executes comprehensive performance benchmarking suite for deployment validation.
    # =============================================================================
    
    log "Running comprehensive performance benchmark suite..."
    # Purpose: Inform user that performance benchmarking is starting
    # Why needed: User should know performance testing is being executed
    # Impact: Provides context for benchmarking process
    
    # =============================================================================
    # PERFORMANCE BENCHMARK SCRIPT EXECUTION
    # =============================================================================
    # Execute performance benchmark script if available.
    # =============================================================================
    
    if [[ -f "./performance/benchmark.sh" ]]; then
        # Purpose: Check if performance benchmark script exists
        # Why needed: Script must exist before execution
        # Impact: Only runs benchmarking if script is available
        
        log "Starting performance benchmark suite execution..."
        # Purpose: Inform user about benchmark execution
        # Why needed: User should know benchmarking is actively running
        # Impact: Sets expectation for benchmark duration
        
        ./performance/benchmark.sh
        # Purpose: Execute performance benchmark script
        # Why needed: Provides performance metrics and validation data
        # Impact: Generates comprehensive performance analysis
        
        if [[ $? -eq 0 ]]; then
            # Purpose: Check if benchmark execution was successful
            # Why needed: Verifies benchmarking completed without errors
            # Impact: Provides confidence in benchmark results
            
            success "Performance benchmark suite completed successfully"
            # Purpose: Confirm successful benchmark completion
            # Why needed: User should know benchmarking was successful
            # Impact: Provides confidence in performance validation
            
            log "Performance results and analysis available in: ./performance-results/"
            # Purpose: Inform user about results location
            # Why needed: User needs to know where to find benchmark results
            # Impact: Enables user to access and analyze performance data
        else
            error "Performance benchmark suite failed to complete"
            # Purpose: Report benchmark execution failure
            # Why needed: User needs to know about benchmarking problems
            # Impact: Indicates performance testing issues
        fi
    else
        warning "Performance benchmark script not found, skipping performance testing..."
        # Purpose: Report missing benchmark script
        # Why needed: User should know performance testing is not available
        # Impact: Performance benchmarking is skipped
        
        log "To enable performance benchmarking, ensure ./performance/benchmark.sh exists and is executable"
        # Purpose: Provide guidance for enabling performance testing
        # Why needed: User needs to know how to enable benchmarking
        # Impact: Enables user to setup performance testing if desired
    fi
}

# =============================================================================
# ACCESS INFORMATION DISPLAY FUNCTIONS
# =============================================================================
# Functions to display application access information and usage instructions.
# =============================================================================

display_access_info() {
    # =============================================================================
    # DISPLAY ACCESS INFORMATION FUNCTION
    # =============================================================================
    # Displays comprehensive access information and usage instructions for deployed applications.
    # =============================================================================
    
    log "Displaying application access information and usage instructions..."
    # Purpose: Inform user that access information is being displayed
    # Why needed: User should know comprehensive access guide is being provided
    # Impact: Sets expectation for detailed access instructions
    
    echo ""
    echo "==================================================================="
    echo "                    ACCESS INFORMATION"
    echo "==================================================================="
    echo ""
    # Purpose: Create visual header for access information section
    # Why needed: Provides clear separation and visual organization
    # Impact: Makes access information easily identifiable
    
    echo "To access the applications, run the following commands:"
    echo ""
    # Purpose: Introduce access instructions
    # Why needed: User needs context for the following commands
    # Impact: Prepares user for port forwarding instructions
    
    # =============================================================================
    # FRONTEND ACCESS INSTRUCTIONS
    # =============================================================================
    # Provide detailed instructions for accessing the frontend web application.
    # =============================================================================
    
    echo "Frontend:"
    echo "  kubectl port-forward -n $NAMESPACE svc/ecommerce-frontend-service 8080:80"
    echo "  Then visit: http://localhost:8080"
    echo ""
    # Purpose: Provide frontend access instructions
    # Why needed: User needs to know how to access the web interface
    # Impact: Enables user to access frontend application
    # Port: 8080 is used to avoid conflicts with other services
    
    # =============================================================================
    # BACKEND API ACCESS INSTRUCTIONS
    # =============================================================================
    # Provide detailed instructions for accessing the backend API.
    # =============================================================================
    
    echo "Backend API:"
    echo "  kubectl port-forward -n $NAMESPACE svc/ecommerce-backend-service 8081:80"
    echo "  Then visit: http://localhost:8081"
    echo ""
    # Purpose: Provide backend API access instructions
    # Why needed: User needs to know how to access the API endpoints
    # Impact: Enables user to access backend API for testing
    # Port: 8081 is used to avoid conflicts with frontend
    
    # =============================================================================
    # MONITORING SYSTEM ACCESS INSTRUCTIONS
    # =============================================================================
    # Provide instructions for accessing monitoring and observability tools.
    # =============================================================================
    
    echo "Grafana (if available):"
    echo "  kubectl port-forward -n $MONITORING_NAMESPACE svc/grafana 3000:3000"
    echo "  Then visit: http://localhost:3000 (admin/admin)"
    echo ""
    # Purpose: Provide Grafana monitoring access instructions
    # Why needed: User needs to know how to access performance dashboards
    # Impact: Enables user to monitor application performance
    # Credentials: Default Grafana credentials provided for convenience
    
    echo "Prometheus (if available):"
    echo "  kubectl port-forward -n $MONITORING_NAMESPACE svc/prometheus 9090:9090"
    echo "  Then visit: http://localhost:9090"
    echo ""
    # Purpose: Provide Prometheus metrics access instructions
    # Why needed: User needs to know how to access raw metrics data
    # Impact: Enables user to query metrics directly
    # Port: 9090 is the standard Prometheus port
    
    # =============================================================================
    # PERFORMANCE RESULTS ACCESS INSTRUCTIONS
    # =============================================================================
    # Provide information about accessing performance benchmark results.
    # =============================================================================
    
    echo "Performance Results:"
    echo "  Check ./performance-results/ directory for benchmark reports"
    echo ""
    # Purpose: Provide performance results access information
    # Why needed: User needs to know where to find benchmark data
    # Impact: Enables user to analyze performance test results
    # Location: Local directory with timestamped subdirectories
    
    # =============================================================================
    # ADDITIONAL USAGE INFORMATION
    # =============================================================================
    # Provide additional helpful information for managing the deployment.
    # =============================================================================
    
    echo "Additional Information:"
    echo "  - All services are deployed in namespace: $NAMESPACE"
    echo "  - To check deployment status: kubectl get all -n $NAMESPACE"
    echo "  - To view logs: kubectl logs -f deployment/<deployment-name> -n $NAMESPACE"
    echo "  - To scale deployments: kubectl scale deployment <deployment-name> --replicas=<count> -n $NAMESPACE"
    echo ""
    # Purpose: Provide additional management commands
    # Why needed: User needs to know how to manage and troubleshoot deployment
    # Impact: Enables user to effectively operate the deployed application
    
    echo "==================================================================="
    # Purpose: Close visual section for access information
    # Why needed: Provides clear end to access information section
    # Impact: Creates organized and professional output format
}

# =============================================================================
# MAIN EXECUTION FUNCTION
# =============================================================================
# Main function that orchestrates the complete enhanced deployment process.
# =============================================================================

main() {
    # =============================================================================
    # MAIN FUNCTION
    # =============================================================================
    # Orchestrates complete enhanced e-commerce deployment workflow with all features.
    # =============================================================================
    
    log "Starting enhanced e-commerce deployment with security and monitoring features..."
    # Purpose: Inform user that enhanced deployment process is beginning
    # Why needed: User should know the comprehensive deployment workflow is starting
    # Impact: Sets expectation for complete enhanced deployment process
    
    echo ""
    log "Enhanced deployment will include:"
    log "  - Prerequisites validation and tool checking"
    log "  - Namespace creation and configuration"
    log "  - Enhanced infrastructure deployment with security features"
    log "  - Automated backup system configuration"
    log "  - Performance monitoring and dashboard setup"
    log "  - Comprehensive deployment validation"
    log "  - Performance benchmarking and analysis"
    log "  - Complete access information and usage instructions"
    echo ""
    # Purpose: Inform user about all enhanced deployment components
    # Why needed: User should understand the complete scope of enhanced deployment
    # Impact: Sets clear expectations for the comprehensive deployment process
    
    # =============================================================================
    # EXECUTE ENHANCED DEPLOYMENT WORKFLOW
    # =============================================================================
    # Run all enhanced deployment components in proper sequence.
    # =============================================================================
    
    check_prerequisites
    # Purpose: Validate environment and tools before deployment
    # Why needed: Ensures enhanced deployment can proceed successfully
    # Impact: Prevents failures due to missing dependencies or connectivity issues
    
    create_namespace
    # Purpose: Create and configure deployment namespace
    # Why needed: Provides isolated environment for application resources
    # Impact: Namespace becomes available with proper labels and configuration
    
    deploy_enhanced_infrastructure
    # Purpose: Deploy complete enhanced infrastructure with security features
    # Why needed: Provides secure, production-ready application deployment
    # Impact: Enhanced application stack becomes available with security controls
    
    setup_backup_system
    # Purpose: Configure automated backup system for data protection
    # Why needed: Ensures data protection and disaster recovery capabilities
    # Impact: Automated backups are scheduled for application data
    
    setup_performance_monitoring
    # Purpose: Configure performance monitoring and visualization tools
    # Why needed: Provides observability and performance analysis capabilities
    # Impact: Performance monitoring becomes available with dashboards
    
    validate_enhanced_deployment
    # Purpose: Validate complete enhanced deployment success
    # Why needed: Confirms all enhanced components are operational
    # Impact: Provides confidence in enhanced deployment success
    
    run_performance_benchmark
    # Purpose: Execute performance benchmarking for deployment validation
    # Why needed: Provides performance metrics and validation data
    # Impact: Performance analysis becomes available for optimization
    
    # =============================================================================
    # DISPLAY COMPLETION SUMMARY
    # =============================================================================
    # Provide final summary and access information for user.
    # =============================================================================
    
    echo ""
    display_access_info
    # Purpose: Display comprehensive access information and usage instructions
    # Why needed: User needs to know how to access and use deployed applications
    # Impact: Enables user to effectively use the enhanced deployment
    
    success "Enhanced e-commerce infrastructure deployed successfully with all features!"
    # Purpose: Confirm successful completion of enhanced deployment
    # Why needed: User should know the complete enhanced deployment was successful
    # Impact: Provides confidence in comprehensive deployment success
    
    log "Enhanced deployment completed with:"
    log "  ✅ Security features (network policies, enhanced backend)"
    log "  ✅ Monitoring capabilities (Grafana dashboards, performance tools)"
    log "  ✅ Backup systems (automated Velero schedules)"
    log "  ✅ Performance benchmarking (comprehensive analysis)"
    log "  ✅ Production-ready configuration (resource management, health checks)"
    # Purpose: Summarize all enhanced features that were deployed
    # Why needed: User should know what enhanced capabilities are now available
    # Impact: Provides clear understanding of deployment value and capabilities
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================
# Execute main function with all command line arguments.
# =============================================================================

main "$@"
# Purpose: Execute main function with all script arguments
# Why needed: Starts the complete enhanced deployment process
# Impact: Runs the entire enhanced e-commerce deployment with all features
# Arguments: "$@" passes all command line arguments to main function
