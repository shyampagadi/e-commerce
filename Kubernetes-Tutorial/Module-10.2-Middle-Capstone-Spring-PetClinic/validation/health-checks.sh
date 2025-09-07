#!/bin/bash

# Enhanced Health Checks for Spring PetClinic
set -euo pipefail

NAMESPACE="petclinic"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to run health check
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -n "🔍 $check_name... "
    
    if eval "$check_command" &>/dev/null; then
        echo -e "${GREEN}✅ PASSED${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

echo -e "${BLUE}🏥 Spring PetClinic Enhanced Health Checks${NC}"
echo "=============================================="

# Infrastructure Health Checks
echo -e "${YELLOW}📋 Infrastructure Health${NC}"
run_check "Namespace exists" "kubectl get namespace $NAMESPACE"
run_check "All pods running" "[ \$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l) -ge 7 ]"
run_check "All services available" "[ \$(kubectl get services -n $NAMESPACE --no-headers | wc -l) -ge 7 ]"
run_check "PVCs bound" "! kubectl get pvc -n $NAMESPACE | grep -v Bound | grep -q pvc"

# Service Health Checks
echo -e "${YELLOW}🔧 Service Health${NC}"
services=("config-server" "discovery-server" "customers-service" "vets-service" "visits-service" "api-gateway" "admin-server")

for service in "${services[@]}"; do
    run_check "$service pods ready" "kubectl get pods -n $NAMESPACE -l app=$service | grep -q Running"
done

# Database Health Checks
echo -e "${YELLOW}🗄️ Database Health${NC}"
databases=("mysql-customers" "mysql-vets" "mysql-visits")

for db in "${databases[@]}"; do
    run_check "$db running" "kubectl get pods -n $NAMESPACE -l app=$db | grep -q Running"
done

# Endpoint Health Checks
echo -e "${YELLOW}🌐 Endpoint Health${NC}"

# Test config server
kubectl port-forward -n $NAMESPACE svc/config-server 8888:8888 &
CONFIG_PF_PID=$!
sleep 2
run_check "Config server endpoint" "curl -f http://localhost:8888/actuator/health"
kill $CONFIG_PF_PID 2>/dev/null || true

# Test discovery server
kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761 &
DISCOVERY_PF_PID=$!
sleep 2
run_check "Discovery server endpoint" "curl -f http://localhost:8761/actuator/health"
run_check "Services registered" "curl -s http://localhost:8761/eureka/apps | grep -q application"
kill $DISCOVERY_PF_PID 2>/dev/null || true

# Test API gateway
kubectl port-forward -n $NAMESPACE svc/api-gateway 8080:8080 &
GATEWAY_PF_PID=$!
sleep 2
run_check "API Gateway endpoint" "curl -f http://localhost:8080/actuator/health"
kill $GATEWAY_PF_PID 2>/dev/null || true

# Resource Health Checks
echo -e "${YELLOW}📊 Resource Health${NC}"
run_check "CPU usage acceptable" "[ \$(kubectl top pods -n $NAMESPACE --no-headers | awk '{print \$3}' | sed 's/m//' | sort -n | tail -1) -lt 800 ]"
run_check "Memory usage acceptable" "[ \$(kubectl top pods -n $NAMESPACE --no-headers | awk '{print \$4}' | sed 's/Mi//' | sort -n | tail -1) -lt 1000 ]"

# Summary
echo ""
echo "=============================================="
echo -e "${BLUE}📊 Health Check Summary${NC}"
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"

success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo "Success Rate: $success_rate%"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🎉 All health checks passed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️ Some health checks failed. Please investigate.${NC}"
    exit 1
fi
