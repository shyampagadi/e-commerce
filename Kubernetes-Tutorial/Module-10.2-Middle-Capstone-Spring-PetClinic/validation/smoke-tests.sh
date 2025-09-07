#!/bin/bash

# Spring PetClinic Smoke Tests
# Quick validation of basic functionality

set -e

NAMESPACE="petclinic"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔥 Running Spring PetClinic Smoke Tests..."

# Test 1: Check if namespace exists
if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo -e "${GREEN}✅ Namespace exists${NC}"
else
    echo -e "${RED}❌ Namespace missing${NC}"
    exit 1
fi

# Test 2: Check if all pods are running
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --field-selector=status.phase=Running --no-headers | wc -l)
if [ "$RUNNING_PODS" -ge 7 ]; then
    echo -e "${GREEN}✅ All pods running ($RUNNING_PODS pods)${NC}"
else
    echo -e "${RED}❌ Not all pods running${NC}"
    exit 1
fi

# Test 3: Check services
SERVICES=$(kubectl get services -n $NAMESPACE --no-headers | wc -l)
if [ "$SERVICES" -ge 7 ]; then
    echo -e "${GREEN}✅ All services created ($SERVICES services)${NC}"
else
    echo -e "${RED}❌ Missing services${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Smoke tests passed!${NC}"
