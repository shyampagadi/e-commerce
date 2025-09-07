#!/bin/bash

# Health check script for Spring PetClinic services
NAMESPACE="petclinic"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🏥 Spring PetClinic Health Check"
echo "================================"

services=("config-server" "discovery-server" "customers-service" "vets-service" "visits-service" "api-gateway" "admin-server")

for service in "${services[@]}"; do
    echo -n "Checking $service... "
    if kubectl get pods -n $NAMESPACE -l app=$service | grep -q Running; then
        echo -e "${GREEN}✅ Healthy${NC}"
    else
        echo -e "${RED}❌ Unhealthy${NC}"
    fi
done

echo ""
echo "Database Status:"
databases=("mysql-customers" "mysql-vets" "mysql-visits")

for db in "${databases[@]}"; do
    echo -n "Checking $db... "
    if kubectl get pods -n $NAMESPACE -l app=$db | grep -q Running; then
        echo -e "${GREEN}✅ Running${NC}"
    else
        echo -e "${RED}❌ Down${NC}"
    fi
done
