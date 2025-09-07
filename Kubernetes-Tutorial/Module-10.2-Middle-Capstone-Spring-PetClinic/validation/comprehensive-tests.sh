#!/bin/bash

# Spring PetClinic Microservices Comprehensive Validation Script
# This script validates the complete deployment and functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="petclinic"
TIMEOUT=30

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing $test_name... "
    
    if eval "$test_command" &>/dev/null; then
        print_status "PASSED"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        print_error "FAILED"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Function to test HTTP endpoint
test_http_endpoint() {
    local service_name="$1"
    local port="$2"
    local path="$3"
    local expected_status="${4:-200}"
    
    # Start port-forward in background
    kubectl port-forward -n $NAMESPACE svc/$service_name $port:$port &
    local pf_pid=$!
    
    # Wait for port-forward to establish
    sleep 3
    
    # Test the endpoint
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port$path || echo "000")
    
    # Kill port-forward
    kill $pf_pid 2>/dev/null || true
    wait $pf_pid 2>/dev/null || true
    
    if [ "$status_code" = "$expected_status" ]; then
        return 0
    else
        echo "Expected $expected_status, got $status_code" >&2
        return 1
    fi
}

# Test 1: Prerequisites
test_prerequisites() {
    print_info "Testing Prerequisites..."
    
    run_test "kubectl availability" "command -v kubectl"
    run_test "cluster connectivity" "kubectl cluster-info"
    run_test "namespace exists" "kubectl get namespace $NAMESPACE"
}

# Test 2: Infrastructure Components
test_infrastructure() {
    print_info "Testing Infrastructure Components..."
    
    run_test "config-server pod running" "kubectl get pod -l app=config-server -n $NAMESPACE | grep Running"
    run_test "discovery-server pod running" "kubectl get pod -l app=discovery-server -n $NAMESPACE | grep Running"
    run_test "config-server service exists" "kubectl get service config-server -n $NAMESPACE"
    run_test "discovery-server service exists" "kubectl get service discovery-server -n $NAMESPACE"
}

# Test 3: Database Components
test_databases() {
    print_info "Testing Database Components..."
    
    run_test "mysql-customers pod running" "kubectl get pod -l app=mysql-customers -n $NAMESPACE | grep Running"
    run_test "mysql-vets pod running" "kubectl get pod -l app=mysql-vets -n $NAMESPACE | grep Running"
    run_test "mysql-visits pod running" "kubectl get pod -l app=mysql-visits -n $NAMESPACE | grep Running"
    run_test "mysql-customers PVC bound" "kubectl get pvc -l app=mysql-customers -n $NAMESPACE | grep Bound"
    run_test "mysql-vets PVC bound" "kubectl get pvc -l app=mysql-vets -n $NAMESPACE | grep Bound"
    run_test "mysql-visits PVC bound" "kubectl get pvc -l app=mysql-visits -n $NAMESPACE | grep Bound"
}

# Test 4: Microservices
test_microservices() {
    print_info "Testing Microservices..."
    
    run_test "customers-service pods running" "kubectl get pod -l app=customers-service -n $NAMESPACE | grep Running"
    run_test "vets-service pods running" "kubectl get pod -l app=vets-service -n $NAMESPACE | grep Running"
    run_test "visits-service pods running" "kubectl get pod -l app=visits-service -n $NAMESPACE | grep Running"
    run_test "customers-service service exists" "kubectl get service customers-service -n $NAMESPACE"
    run_test "vets-service service exists" "kubectl get service vets-service -n $NAMESPACE"
    run_test "visits-service service exists" "kubectl get service visits-service -n $NAMESPACE"
}

# Test 5: Gateway and Admin
test_gateway_admin() {
    print_info "Testing Gateway and Admin Components..."
    
    run_test "api-gateway pods running" "kubectl get pod -l app=api-gateway -n $NAMESPACE | grep Running"
    run_test "admin-server pod running" "kubectl get pod -l app=admin-server -n $NAMESPACE | grep Running"
    run_test "api-gateway service exists" "kubectl get service api-gateway -n $NAMESPACE"
    run_test "admin-server service exists" "kubectl get service admin-server -n $NAMESPACE"
}

# Test 6: Health Endpoints
test_health_endpoints() {
    print_info "Testing Health Endpoints..."
    
    # Note: These tests require port-forwarding and may take longer
    print_warning "Health endpoint tests require port-forwarding and may take 30-60 seconds..."
    
    run_test "config-server health" "test_http_endpoint config-server 8888 /actuator/health"
    run_test "discovery-server health" "test_http_endpoint discovery-server 8761 /actuator/health"
    run_test "api-gateway health" "test_http_endpoint api-gateway 8080 /actuator/health"
    run_test "admin-server health" "test_http_endpoint admin-server 9090 /actuator/health"
}

# Test 7: Service Discovery
test_service_discovery() {
    print_info "Testing Service Discovery..."
    
    # Check if services are registered with Eureka
    run_test "eureka apps endpoint" "test_http_endpoint discovery-server 8761 /eureka/apps 200"
    
    # Wait a bit for services to register
    sleep 10
    
    # Test if we can get the eureka apps XML (should contain registered services)
    kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761 &
    local pf_pid=$!
    sleep 3
    
    local registered_services=$(curl -s http://localhost:8761/eureka/apps | grep -o '<name>[^<]*</name>' | wc -l || echo "0")
    kill $pf_pid 2>/dev/null || true
    wait $pf_pid 2>/dev/null || true
    
    if [ "$registered_services" -gt 0 ]; then
        print_status "Service discovery working - $registered_services services registered"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_error "No services registered with Eureka"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Test 8: Resource Usage
test_resource_usage() {
    print_info "Testing Resource Usage..."
    
    # Check if pods are within resource limits
    run_test "pods not in CrashLoopBackOff" "! kubectl get pods -n $NAMESPACE | grep CrashLoopBackOff"
    run_test "pods not in Error state" "! kubectl get pods -n $NAMESPACE | grep Error"
    run_test "pods not in ImagePullBackOff" "! kubectl get pods -n $NAMESPACE | grep ImagePullBackOff"
    
    # Check resource quotas
    run_test "resource quota exists" "kubectl get resourcequota -n $NAMESPACE"
    run_test "limit range exists" "kubectl get limitrange -n $NAMESPACE"
}

# Test 9: Secrets and ConfigMaps
test_secrets_configs() {
    print_info "Testing Secrets and Configuration..."
    
    run_test "mysql-credentials secret exists" "kubectl get secret mysql-credentials -n $NAMESPACE"
    run_test "secret has required keys" "kubectl get secret mysql-credentials -n $NAMESPACE -o jsonpath='{.data.username}' | base64 -d"
}

# Test 10: Networking
test_networking() {
    print_info "Testing Networking..."
    
    # Test internal service connectivity
    run_test "config-server DNS resolution" "kubectl exec -n $NAMESPACE deployment/discovery-server -- nslookup config-server"
    run_test "discovery-server DNS resolution" "kubectl exec -n $NAMESPACE deployment/customers-service -- nslookup discovery-server"
    
    # Test service endpoints
    run_test "config-server endpoints" "kubectl get endpoints config-server -n $NAMESPACE"
    run_test "discovery-server endpoints" "kubectl get endpoints discovery-server -n $NAMESPACE"
}

# Function to display summary
display_summary() {
    echo ""
    echo "=========================================="
    echo "           VALIDATION SUMMARY"
    echo "=========================================="
    echo ""
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Success Rate: $success_rate%"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        print_status "🎉 All tests passed! Spring PetClinic platform is fully operational."
        echo ""
        echo "You can now access the applications:"
        echo "• PetClinic App: kubectl port-forward -n $NAMESPACE svc/api-gateway 8080:8080"
        echo "• Eureka Dashboard: kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761"
        echo "• Admin Dashboard: kubectl port-forward -n $NAMESPACE svc/admin-server 9090:9090"
        return 0
    else
        print_error "Some tests failed. Please check the deployment and fix issues."
        echo ""
        echo "Common troubleshooting steps:"
        echo "1. Check pod logs: kubectl logs -n $NAMESPACE <pod-name>"
        echo "2. Describe failed pods: kubectl describe pod -n $NAMESPACE <pod-name>"
        echo "3. Check events: kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
        return 1
    fi
}

# Main function
main() {
    echo "🏥 Spring PetClinic Microservices Validation"
    echo "============================================="
    echo ""
    
    test_prerequisites
    test_infrastructure
    test_databases
    test_microservices
    test_gateway_admin
    test_health_endpoints
    test_service_discovery
    test_resource_usage
    test_secrets_configs
    test_networking
    
    display_summary
}

# Run main function
main "$@"
