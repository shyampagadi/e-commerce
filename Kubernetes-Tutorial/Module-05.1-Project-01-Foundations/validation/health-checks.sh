#!/bin/bash

# E-commerce Foundation Infrastructure - Health Checks
# This script performs comprehensive health checks on the application and infrastructure

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="ecommerce"
APP_NAME="ecommerce-backend"
SERVICE_NAME="ecommerce-backend-service"
MONITORING_NAMESPACE="monitoring"

# Health check results
HEALTHY=0
UNHEALTHY=0
TOTAL_CHECKS=0

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Health check result function
health_result() {
    local check_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
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
