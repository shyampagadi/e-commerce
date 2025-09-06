#!/bin/bash

# E-commerce Foundation Infrastructure - Smoke Tests
# This script runs basic smoke tests to verify the application is working correctly

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
TEST_TIMEOUT=30

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

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

# Test result function
test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$result" == "PASS" ]]; then
        success "✓ $test_name: $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        error "✗ $test_name: $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        error "Namespace $NAMESPACE does not exist"
        exit 1
    fi
    
    success "Prerequisites check passed"
}

# Test 1: Check namespace exists
test_namespace_exists() {
    log "Test 1: Checking namespace exists..."
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        test_result "Namespace Exists" "PASS" "Namespace $NAMESPACE exists"
    else
        test_result "Namespace Exists" "FAIL" "Namespace $NAMESPACE does not exist"
    fi
}

# Test 2: Check deployment exists
test_deployment_exists() {
    log "Test 2: Checking deployment exists..."
    
    if kubectl get deployment $APP_NAME -n $NAMESPACE &> /dev/null; then
        test_result "Deployment Exists" "PASS" "Deployment $APP_NAME exists"
    else
        test_result "Deployment Exists" "FAIL" "Deployment $APP_NAME does not exist"
    fi
}

# Test 3: Check service exists
test_service_exists() {
    log "Test 3: Checking service exists..."
    
    if kubectl get service $SERVICE_NAME -n $NAMESPACE &> /dev/null; then
        test_result "Service Exists" "PASS" "Service $SERVICE_NAME exists"
    else
        test_result "Service Exists" "FAIL" "Service $SERVICE_NAME does not exist"
    fi
}

# Test 4: Check pods are running
test_pods_running() {
    log "Test 4: Checking pods are running..."
    
    local pod_count=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l)
    
    if [[ $pod_count -gt 0 ]]; then
        test_result "Pods Running" "PASS" "$pod_count pod(s) are running"
    else
        test_result "Pods Running" "FAIL" "No pods are running"
    fi
}

# Test 5: Check pods are ready
test_pods_ready() {
    log "Test 5: Checking pods are ready..."
    
    local ready_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | awk '{print $2}' | grep -c "1/1" || true)
    local total_pods=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --no-headers | wc -l)
    
    if [[ $ready_pods -eq $total_pods && $total_pods -gt 0 ]]; then
        test_result "Pods Ready" "PASS" "All $total_pods pod(s) are ready"
    else
        test_result "Pods Ready" "FAIL" "Only $ready_pods out of $total_pods pods are ready"
    fi
}

# Test 6: Check service endpoints
test_service_endpoints() {
    log "Test 6: Checking service endpoints..."
    
    local endpoint_count=$(kubectl get endpoints $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
    
    if [[ $endpoint_count -gt 0 ]]; then
        test_result "Service Endpoints" "PASS" "Service has $endpoint_count endpoint(s)"
    else
        test_result "Service Endpoints" "FAIL" "Service has no endpoints"
    fi
}

# Test 7: Check application health endpoint
test_health_endpoint() {
    log "Test 7: Checking application health endpoint..."
    
    # Start port forward in background
    kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE &
    local port_forward_pid=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test health endpoint
    local health_response
    if health_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/health --max-time $TEST_TIMEOUT 2>/dev/null); then
        if [[ "$health_response" == "200" ]]; then
            test_result "Health Endpoint" "PASS" "Health endpoint returns 200 OK"
        else
            test_result "Health Endpoint" "FAIL" "Health endpoint returns $health_response"
        fi
    else
        test_result "Health Endpoint" "FAIL" "Cannot connect to health endpoint"
    fi
    
    # Clean up port forward
    kill $port_forward_pid 2>/dev/null || true
}

# Test 8: Check API documentation endpoint
test_api_docs_endpoint() {
    log "Test 8: Checking API documentation endpoint..."
    
    # Start port forward in background
    kubectl port-forward svc/$SERVICE_NAME 8080:80 -n $NAMESPACE &
    local port_forward_pid=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test API docs endpoint
    local docs_response
    if docs_response=$(curl -s -w "%{http_code}" -o /dev/null http://localhost:8080/docs --max-time $TEST_TIMEOUT 2>/dev/null); then
        if [[ "$docs_response" == "200" ]]; then
            test_result "API Docs Endpoint" "PASS" "API docs endpoint returns 200 OK"
        else
            test_result "API Docs Endpoint" "FAIL" "API docs endpoint returns $docs_response"
        fi
    else
        test_result "API Docs Endpoint" "FAIL" "Cannot connect to API docs endpoint"
    fi
    
    # Clean up port forward
    kill $port_forward_pid 2>/dev/null || true
}

# Test 9: Check resource usage
test_resource_usage() {
    log "Test 9: Checking resource usage..."
    
    # Check if metrics are available
    if kubectl top pods -n $NAMESPACE &> /dev/null; then
        local cpu_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $2}' | head -1 | sed 's/m//')
        local memory_usage=$(kubectl top pods -l app=$APP_NAME -n $NAMESPACE --no-headers | awk '{print $3}' | head -1 | sed 's/Mi//')
        
        if [[ -n "$cpu_usage" && -n "$memory_usage" ]]; then
            test_result "Resource Usage" "PASS" "CPU: ${cpu_usage}m, Memory: ${memory_usage}Mi"
        else
            test_result "Resource Usage" "FAIL" "Cannot get resource usage metrics"
        fi
    else
        test_result "Resource Usage" "WARN" "Metrics server not available"
    fi
}

# Test 10: Check pod logs
test_pod_logs() {
    log "Test 10: Checking pod logs..."
    
    local pod_name=$(kubectl get pods -l app=$APP_NAME -n $NAMESPACE --field-selector=status.phase=Running --no-headers | head -1 | awk '{print $1}')
    
    if [[ -n "$pod_name" ]]; then
        local log_output=$(kubectl logs $pod_name -n $NAMESPACE --tail=10 2>&1)
        
        if [[ -n "$log_output" ]]; then
            test_result "Pod Logs" "PASS" "Pod logs are accessible"
        else
            test_result "Pod Logs" "FAIL" "Pod logs are empty or not accessible"
        fi
    else
        test_result "Pod Logs" "FAIL" "No running pods found"
    fi
}

# Function to run all tests
run_tests() {
    log "Starting smoke tests..."
    echo ""
    
    test_namespace_exists
    test_deployment_exists
    test_service_exists
    test_pods_running
    test_pods_ready
    test_service_endpoints
    test_health_endpoint
    test_api_docs_endpoint
    test_resource_usage
    test_pod_logs
    
    echo ""
    log "Smoke tests completed"
}

# Function to show test results
show_results() {
    echo ""
    echo "=========================================="
    echo "SMOKE TEST RESULTS"
    echo "=========================================="
    echo ""
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        success "All tests passed! Application is healthy."
        exit 0
    else
        error "$TESTS_FAILED test(s) failed. Please check the issues above."
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help                 Show this help message"
    echo "  --namespace NAMESPACE  Override default namespace (default: ecommerce)"
    echo "  --timeout SECONDS      Override test timeout (default: 30)"
    echo ""
    echo "Examples:"
    echo "  $0                     Run smoke tests with default settings"
    echo "  $0 --namespace prod    Run smoke tests in prod namespace"
    echo "  $0 --timeout 60        Run smoke tests with 60 second timeout"
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
            --timeout)
                TEST_TIMEOUT="$2"
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
    echo "E-commerce Application Smoke Tests"
    echo "=========================================="
    echo ""
    echo "Configuration:"
    echo "- Namespace: $NAMESPACE"
    echo "- Application: $APP_NAME"
    echo "- Service: $SERVICE_NAME"
    echo "- Timeout: ${TEST_TIMEOUT}s"
    echo ""
    
    check_prerequisites
    run_tests
    show_results
}

# Run main function
main "$@"
