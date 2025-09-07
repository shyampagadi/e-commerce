#!/bin/bash

# 🚀 Comprehensive Performance Benchmarking Script for Spring PetClinic
# =====================================================================
# 
# This script provides comprehensive performance testing and benchmarking
# for the Spring PetClinic Microservices Platform including:
# - Load testing with K6
# - JMeter performance tests  
# - Resource utilization monitoring
# - Database performance analysis
# - Network latency testing
# - Stress testing scenarios
# - Performance report generation
#
# Author: DevOps Team
# Version: 2.0.0
# Last Updated: December 2024

set -euo pipefail

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Configuration
readonly NAMESPACE="petclinic"
readonly RESULTS_DIR="/tmp/petclinic-benchmark-$(date +%Y%m%d_%H%M%S)"
readonly REPORT_DIR="/tmp/petclinic-reports"
readonly LOG_FILE="$RESULTS_DIR/benchmark.log"

# Test Configuration
readonly LOAD_TEST_DURATION="5m"
readonly STRESS_TEST_DURATION="10m"
readonly CONCURRENT_USERS="100"
readonly MAX_STRESS_USERS="500"
readonly RAMP_UP_TIME="30s"

# Service Endpoints
readonly API_GATEWAY_PORT="8080"
readonly PROMETHEUS_PORT="9090"
readonly GRAFANA_PORT="3000"

# Performance Thresholds
readonly MAX_RESPONSE_TIME="200"  # milliseconds
readonly MIN_THROUGHPUT="100"     # requests per second
readonly MAX_ERROR_RATE="1"       # percentage

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "${BLUE}$*${NC}"
}

log_success() {
    log "SUCCESS" "${GREEN}$*${NC}"
}

log_warning() {
    log "WARNING" "${YELLOW}$*${NC}"
}

log_error() {
    log "ERROR" "${RED}$*${NC}"
}

log_header() {
    echo -e "\n${PURPLE}============================================================================${NC}"
    echo -e "${WHITE}$*${NC}"
    echo -e "${PURPLE}============================================================================${NC}\n"
}

check_prerequisites() {
    log_header "🔍 CHECKING PREREQUISITES"
    
    local missing_tools=()
    
    # Check required tools
    command -v kubectl >/dev/null 2>&1 || missing_tools+=("kubectl")
    command -v k6 >/dev/null 2>&1 || missing_tools+=("k6")
    command -v jq >/dev/null 2>&1 || missing_tools+=("jq")
    command -v curl >/dev/null 2>&1 || missing_tools+=("curl")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and try again"
        exit 1
    fi
    
    # Check Kubernetes connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check namespace exists
    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        log_error "Namespace '$NAMESPACE' does not exist"
        exit 1
    fi
    
    log_success "All prerequisites satisfied"
}

setup_directories() {
    log_info "📁 Setting up directories..."
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$REPORT_DIR"
    mkdir -p "$RESULTS_DIR/k6"
    mkdir -p "$RESULTS_DIR/jmeter"
    mkdir -p "$RESULTS_DIR/monitoring"
    mkdir -p "$RESULTS_DIR/logs"
    log_success "Directories created: $RESULTS_DIR"
}

check_services_health() {
    log_header "🏥 HEALTH CHECK"
    
    local services=("config-server" "discovery-server" "api-gateway" "customer-service" "vet-service" "visit-service")
    local healthy_services=0
    
    for service in "${services[@]}"; do
        log_info "Checking $service..."
        if kubectl get deployment "$service" -n "$NAMESPACE" >/dev/null 2>&1; then
            local ready_replicas=$(kubectl get deployment "$service" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
            local desired_replicas=$(kubectl get deployment "$service" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
            
            if [[ "$ready_replicas" == "$desired_replicas" && "$ready_replicas" -gt 0 ]]; then
                log_success "✅ $service: $ready_replicas/$desired_replicas replicas ready"
                ((healthy_services++))
            else
                log_warning "⚠️  $service: $ready_replicas/$desired_replicas replicas ready"
            fi
        else
            log_warning "⚠️  $service: Deployment not found"
        fi
    done
    
    if [[ $healthy_services -lt ${#services[@]} ]]; then
        log_warning "Not all services are healthy. Continuing with available services..."
    else
        log_success "All services are healthy"
    fi
}

start_port_forwards() {
    log_info "🔌 Starting port forwards..."
    
    # Kill existing port forwards
    pkill -f "kubectl port-forward" 2>/dev/null || true
    sleep 2
    
    # Start API Gateway port forward
    kubectl port-forward -n "$NAMESPACE" svc/api-gateway "$API_GATEWAY_PORT:$API_GATEWAY_PORT" >/dev/null 2>&1 &
    local api_gateway_pid=$!
    
    # Start Prometheus port forward (if available)
    if kubectl get svc prometheus -n "$NAMESPACE" >/dev/null 2>&1; then
        kubectl port-forward -n "$NAMESPACE" svc/prometheus "$PROMETHEUS_PORT:$PROMETHEUS_PORT" >/dev/null 2>&1 &
        local prometheus_pid=$!
    fi
    
    # Wait for port forwards to be ready
    sleep 5
    
    # Test connectivity
    if curl -s "http://localhost:$API_GATEWAY_PORT/actuator/health" >/dev/null; then
        log_success "API Gateway accessible at http://localhost:$API_GATEWAY_PORT"
    else
        log_error "Cannot access API Gateway"
        return 1
    fi
    
    # Store PIDs for cleanup
    echo "$api_gateway_pid" > "$RESULTS_DIR/port_forward_pids.txt"
    [[ -n "${prometheus_pid:-}" ]] && echo "$prometheus_pid" >> "$RESULTS_DIR/port_forward_pids.txt"
}

# ============================================================================
# MONITORING FUNCTIONS
# ============================================================================

start_monitoring() {
    log_info "📊 Starting system monitoring..."
    
    # Monitor resource usage
    {
        while true; do
            echo "$(date '+%Y-%m-%d %H:%M:%S'),$(kubectl top nodes --no-headers | awk '{print $2","$3}' | tr '\n' ';')"
            sleep 10
        done
    } > "$RESULTS_DIR/monitoring/node_usage.csv" &
    local node_monitor_pid=$!
    
    # Monitor pod usage
    {
        while true; do
            echo "$(date '+%Y-%m-%d %H:%M:%S'),$(kubectl top pods -n "$NAMESPACE" --no-headers | awk '{print $1","$2","$3}' | tr '\n' ';')"
            sleep 10
        done
    } > "$RESULTS_DIR/monitoring/pod_usage.csv" &
    local pod_monitor_pid=$!
    
    # Store monitoring PIDs
    echo "$node_monitor_pid" > "$RESULTS_DIR/monitoring_pids.txt"
    echo "$pod_monitor_pid" >> "$RESULTS_DIR/monitoring_pids.txt"
    
    log_success "Monitoring started"
}

stop_monitoring() {
    log_info "🛑 Stopping monitoring..."
    
    if [[ -f "$RESULTS_DIR/monitoring_pids.txt" ]]; then
        while read -r pid; do
            kill "$pid" 2>/dev/null || true
        done < "$RESULTS_DIR/monitoring_pids.txt"
        rm -f "$RESULTS_DIR/monitoring_pids.txt"
    fi
    
    log_success "Monitoring stopped"
}

# ============================================================================
# LOAD TESTING FUNCTIONS
# ============================================================================

run_k6_load_test() {
    log_header "🚀 K6 LOAD TESTING"
    
    log_info "Running K6 load test with $CONCURRENT_USERS users for $LOAD_TEST_DURATION..."
    
    # Create K6 test script
    cat > "$RESULTS_DIR/k6/load-test.js" << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export let errorRate = new Rate('errors');

export let options = {
    stages: [
        { duration: '30s', target: 20 },   // Ramp up
        { duration: '2m', target: 50 },    // Stay at 50 users
        { duration: '2m', target: 100 },   // Ramp to 100 users
        { duration: '30s', target: 0 },    // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(95)<200'],  // 95% of requests under 200ms
        http_req_failed: ['rate<0.01'],    // Error rate under 1%
        errors: ['rate<0.01'],
    },
};

const BASE_URL = 'http://localhost:8080';

export default function() {
    // Test API Gateway health
    let healthResponse = http.get(`${BASE_URL}/actuator/health`);
    check(healthResponse, {
        'health check status is 200': (r) => r.status === 200,
    }) || errorRate.add(1);
    
    // Test customer service endpoints
    let customersResponse = http.get(`${BASE_URL}/api/customer/owners`);
    check(customersResponse, {
        'customers endpoint status is 200': (r) => r.status === 200,
        'customers response time < 200ms': (r) => r.timings.duration < 200,
    }) || errorRate.add(1);
    
    // Test vet service endpoints
    let vetsResponse = http.get(`${BASE_URL}/api/vet/vets`);
    check(vetsResponse, {
        'vets endpoint status is 200': (r) => r.status === 200,
        'vets response time < 200ms': (r) => r.timings.duration < 200,
    }) || errorRate.add(1);
    
    // Test visit service endpoints
    let visitsResponse = http.get(`${BASE_URL}/api/visit/owners/1/pets/1/visits`);
    check(visitsResponse, {
        'visits response time < 200ms': (r) => r.timings.duration < 200,
    }) || errorRate.add(1);
    
    sleep(1);
}
EOF
    
    # Run K6 test
    k6 run \
        --out json="$RESULTS_DIR/k6/results.json" \
        --out csv="$RESULTS_DIR/k6/results.csv" \
        "$RESULTS_DIR/k6/load-test.js" \
        2>&1 | tee "$RESULTS_DIR/k6/output.log"
    
    local k6_exit_code=${PIPESTATUS[0]}
    
    if [[ $k6_exit_code -eq 0 ]]; then
        log_success "K6 load test completed successfully"
    else
        log_warning "K6 load test completed with warnings (exit code: $k6_exit_code)"
    fi
    
    # Parse results
    parse_k6_results
}

parse_k6_results() {
    log_info "📊 Parsing K6 results..."
    
    if [[ -f "$RESULTS_DIR/k6/results.json" ]]; then
        # Extract key metrics
        local avg_response_time=$(jq -r 'select(.type=="Point" and .metric=="http_req_duration") | .data.value' "$RESULTS_DIR/k6/results.json" | awk '{sum+=$1; count++} END {print sum/count}')
        local max_response_time=$(jq -r 'select(.type=="Point" and .metric=="http_req_duration") | .data.value' "$RESULTS_DIR/k6/results.json" | sort -n | tail -1)
        local error_rate=$(jq -r 'select(.type=="Point" and .metric=="http_req_failed") | .data.value' "$RESULTS_DIR/k6/results.json" | awk '{sum+=$1; count++} END {print (sum/count)*100}')
        
        # Create summary
        cat > "$RESULTS_DIR/k6/summary.txt" << EOF
K6 Load Test Summary
===================
Average Response Time: ${avg_response_time:-N/A} ms
Maximum Response Time: ${max_response_time:-N/A} ms
Error Rate: ${error_rate:-N/A}%
Test Duration: $LOAD_TEST_DURATION
Concurrent Users: $CONCURRENT_USERS
EOF
        
        log_success "K6 results parsed and saved"
    else
        log_warning "K6 results file not found"
    fi
}

run_stress_test() {
    log_header "💪 STRESS TESTING"
    
    log_info "Running stress test with up to $MAX_STRESS_USERS users..."
    
    # Create stress test script
    cat > "$RESULTS_DIR/k6/stress-test.js" << 'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export let errorRate = new Rate('errors');

export let options = {
    stages: [
        { duration: '1m', target: 100 },   // Ramp up to 100 users
        { duration: '2m', target: 200 },   // Ramp up to 200 users
        { duration: '2m', target: 300 },   // Ramp up to 300 users
        { duration: '2m', target: 400 },   // Ramp up to 400 users
        { duration: '2m', target: 500 },   // Ramp up to 500 users
        { duration: '1m', target: 0 },     // Ramp down
    ],
};

const BASE_URL = 'http://localhost:8080';

export default function() {
    let response = http.get(`${BASE_URL}/actuator/health`);
    check(response, {
        'status is 200': (r) => r.status === 200,
    }) || errorRate.add(1);
    
    sleep(0.5);
}
EOF
    
    # Run stress test
    k6 run \
        --out json="$RESULTS_DIR/k6/stress-results.json" \
        "$RESULTS_DIR/k6/stress-test.js" \
        2>&1 | tee "$RESULTS_DIR/k6/stress-output.log"
    
    log_success "Stress test completed"
}

# ============================================================================
# DATABASE PERFORMANCE TESTING
# ============================================================================

test_database_performance() {
    log_header "🗄️ DATABASE PERFORMANCE TESTING"
    
    local databases=("mysql-customer" "mysql-vet" "mysql-visit")
    
    for db in "${databases[@]}"; do
        log_info "Testing $db performance..."
        
        # Test database connectivity and basic performance
        kubectl exec -n "$NAMESPACE" deployment/"$db" -- mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
            SELECT 'Connection Test' as Test, NOW() as Timestamp;
            SHOW PROCESSLIST;
            SHOW ENGINE INNODB STATUS\G
        " > "$RESULTS_DIR/monitoring/${db}_performance.txt" 2>/dev/null || log_warning "Could not test $db performance"
    done
    
    log_success "Database performance testing completed"
}

# ============================================================================
# NETWORK LATENCY TESTING
# ============================================================================

test_network_latency() {
    log_header "🌐 NETWORK LATENCY TESTING"
    
    local services=("config-server" "discovery-server" "api-gateway" "customer-service" "vet-service" "visit-service")
    
    for service in "${services[@]}"; do
        log_info "Testing network latency to $service..."
        
        # Get service IP
        local service_ip=$(kubectl get svc "$service" -n "$NAMESPACE" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
        
        if [[ -n "$service_ip" ]]; then
            # Test latency from within cluster
            kubectl run latency-test-"$service" --rm -i --restart=Never --image=busybox -- sh -c "
                echo 'Testing latency to $service ($service_ip):'
                for i in \$(seq 1 10); do
                    time nc -z $service_ip 8080 2>&1 | grep real
                done
            " > "$RESULTS_DIR/monitoring/${service}_latency.txt" 2>/dev/null || log_warning "Could not test latency to $service"
        fi
    done
    
    log_success "Network latency testing completed"
}

# ============================================================================
# REPORT GENERATION
# ============================================================================

generate_performance_report() {
    log_header "📋 GENERATING PERFORMANCE REPORT"
    
    local report_file="$REPORT_DIR/performance-report-$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Spring PetClinic Performance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        pre { background-color: #f5f5f5; padding: 10px; border-radius: 3px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Spring PetClinic Performance Report</h1>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Test Duration:</strong> $LOAD_TEST_DURATION</p>
        <p><strong>Concurrent Users:</strong> $CONCURRENT_USERS</p>
    </div>
    
    <div class="section">
        <h2>📊 Executive Summary</h2>
        <p>This report provides comprehensive performance analysis of the Spring PetClinic Microservices Platform.</p>
    </div>
    
    <div class="section">
        <h2>🏥 System Health</h2>
        <pre>$(kubectl get pods -n "$NAMESPACE" -o wide)</pre>
    </div>
    
    <div class="section">
        <h2>📈 Resource Utilization</h2>
        <h3>Node Usage</h3>
        <pre>$(kubectl top nodes 2>/dev/null || echo "Node metrics not available")</pre>
        
        <h3>Pod Usage</h3>
        <pre>$(kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Pod metrics not available")</pre>
    </div>
EOF
    
    # Add K6 results if available
    if [[ -f "$RESULTS_DIR/k6/summary.txt" ]]; then
        cat >> "$report_file" << EOF
    <div class="section">
        <h2>🚀 Load Test Results</h2>
        <pre>$(cat "$RESULTS_DIR/k6/summary.txt")</pre>
    </div>
EOF
    fi
    
    # Close HTML
    cat >> "$report_file" << EOF
    <div class="section">
        <h2>📁 Test Artifacts</h2>
        <p>Detailed test results and logs are available in: <code>$RESULTS_DIR</code></p>
    </div>
    
    <div class="section">
        <h2>🔍 Recommendations</h2>
        <ul>
            <li>Monitor response times and scale services if they exceed 200ms consistently</li>
            <li>Review error rates and investigate any failures</li>
            <li>Consider implementing caching for frequently accessed data</li>
            <li>Monitor database performance and optimize queries if needed</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    log_success "Performance report generated: $report_file"
    
    # Also create a text summary
    create_text_summary
}

create_text_summary() {
    local summary_file="$RESULTS_DIR/performance_summary.txt"
    
    cat > "$summary_file" << EOF
Spring PetClinic Performance Test Summary
========================================
Date: $(date)
Test Duration: $LOAD_TEST_DURATION
Concurrent Users: $CONCURRENT_USERS

System Status:
$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '{print $1 ": " $3}')

Resource Usage:
$(kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null | head -10 || echo "Metrics not available")

Test Results Location: $RESULTS_DIR
Report Location: $REPORT_DIR

EOF
    
    log_success "Text summary created: $summary_file"
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

cleanup() {
    log_info "🧹 Cleaning up..."
    
    # Stop monitoring
    stop_monitoring
    
    # Kill port forwards
    if [[ -f "$RESULTS_DIR/port_forward_pids.txt" ]]; then
        while read -r pid; do
            kill "$pid" 2>/dev/null || true
        done < "$RESULTS_DIR/port_forward_pids.txt"
        rm -f "$RESULTS_DIR/port_forward_pids.txt"
    fi
    
    # Clean up test pods
    kubectl delete pods -n "$NAMESPACE" -l "run=latency-test" --ignore-not-found=true
    
    log_success "Cleanup completed"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log_header "🚀 SPRING PETCLINIC PERFORMANCE BENCHMARK SUITE"
    log_info "Starting comprehensive performance testing..."
    log_info "Results will be saved to: $RESULTS_DIR"
    
    # Setup trap for cleanup
    trap cleanup EXIT
    
    # Execute test suite
    check_prerequisites
    setup_directories
    check_services_health
    start_port_forwards
    start_monitoring
    
    # Run performance tests
    run_k6_load_test
    run_stress_test
    test_database_performance
    test_network_latency
    
    # Generate reports
    generate_performance_report
    
    log_header "✅ PERFORMANCE TESTING COMPLETED"
    log_success "Results available in: $RESULTS_DIR"
    log_success "Report available in: $REPORT_DIR"
    
    # Display summary
    echo -e "\n${CYAN}📊 Quick Summary:${NC}"
    echo -e "${WHITE}Results Directory:${NC} $RESULTS_DIR"
    echo -e "${WHITE}Report Directory:${NC} $REPORT_DIR"
    echo -e "${WHITE}Test Duration:${NC} $LOAD_TEST_DURATION"
    echo -e "${WHITE}Concurrent Users:${NC} $CONCURRENT_USERS"
    
    if [[ -f "$RESULTS_DIR/k6/summary.txt" ]]; then
        echo -e "\n${CYAN}K6 Test Results:${NC}"
        cat "$RESULTS_DIR/k6/summary.txt"
    fi
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
    
    # Kill port-forward
    kill $PF_PID 2>/dev/null || true
    
    echo -e "${GREEN}✅ Load test completed${NC}"
}

# Function to collect resource metrics
collect_metrics() {
    echo -e "${YELLOW}📈 Collecting Resource Metrics...${NC}"
    
    # Pod resource usage
    kubectl top pods -n $NAMESPACE > "$RESULTS_DIR/pod-resources.txt"
    
    # Node resource usage
    kubectl top nodes > "$RESULTS_DIR/node-resources.txt"
    
    # Service endpoints
    kubectl get endpoints -n $NAMESPACE > "$RESULTS_DIR/endpoints.txt"
    
    echo -e "${GREEN}✅ Metrics collected${NC}"
}

# Function to test service response times
test_response_times() {
    echo -e "${YELLOW}⏱️ Testing Service Response Times...${NC}"
    
    kubectl port-forward -n $NAMESPACE svc/api-gateway 8080:8080 &
    PF_PID=$!
    sleep 3
    
    # Test various endpoints
    endpoints=("/actuator/health" "/api/customer/owners" "/api/vet/vets" "/api/visit/visits")
    
    for endpoint in "${endpoints[@]}"; do
        echo "Testing $endpoint..."
        curl -w "@curl-format.txt" -o /dev/null -s "http://localhost:8080$endpoint" >> "$RESULTS_DIR/response-times.txt" || true
    done
    
    kill $PF_PID 2>/dev/null || true
    echo -e "${GREEN}✅ Response time tests completed${NC}"
}

# Create curl format file
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Function to generate report
generate_report() {
    echo -e "${YELLOW}📋 Generating Performance Report...${NC}"
    
    cat > "$RESULTS_DIR/performance-report.md" << EOF
# Spring PetClinic Performance Report
**Date**: $(date)
**Namespace**: $NAMESPACE

## Summary
- Load test results: See k6-results.json
- Resource usage: See pod-resources.txt and node-resources.txt
- Response times: See response-times.txt
- Service endpoints: See endpoints.txt

## Recommendations
- Monitor resource usage trends
- Scale services if CPU/Memory > 70%
- Optimize slow endpoints (>100ms response time)
EOF

    echo -e "${GREEN}✅ Report generated: $RESULTS_DIR/performance-report.md${NC}"
}

# Main execution
main() {
    collect_metrics
    test_response_times
    
    # Run K6 test if available
    if command -v k6 &> /dev/null; then
        run_load_test
    else
        echo -e "${YELLOW}⚠️ K6 not found, skipping load test${NC}"
    fi
    
    generate_report
    
    echo -e "${GREEN}🎉 Benchmark completed successfully!${NC}"
    echo "Results available in: $RESULTS_DIR"
}

# Cleanup function
cleanup() {
    rm -f curl-format.txt
    # Kill any remaining port-forwards
    pkill -f "kubectl port-forward" 2>/dev/null || true
}

trap cleanup EXIT
main "$@"
