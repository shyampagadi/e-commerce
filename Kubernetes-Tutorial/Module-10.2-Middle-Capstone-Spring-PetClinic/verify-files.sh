#!/bin/bash

# File verification script for Spring PetClinic project
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Spring PetClinic Project File Verification"
echo "=============================================="

# Essential files to check (updated list)
files=(
    "README.md"
    "PROJECT-COMPLETION-SUMMARY.md"
    "docs/00-business-case.md"
    "docs/00-project-charter.md"
    "docs/01-client-requirements.md"
    "docs/02-functional-requirements.md"
    "docs/03-technical-design.md"
    "docs/03-technical-implementation-guide.md"
    "docs/04-deployment-guide.md"
    "docs/05-operations-runbook.md"
    "docs/06-troubleshooting-guide.md"
    "k8s-manifests/namespaces/petclinic-namespace.yml"
    "k8s-manifests/services/config-server/config-server-deployment.yml"
    "k8s-manifests/services/discovery-server/discovery-server-deployment.yml"
    "k8s-manifests/services/customer-service/customers-service-deployment.yml"
    "k8s-manifests/services/vet-service/vets-service-deployment.yml"
    "k8s-manifests/services/visit-service/visits-service-deployment.yml"
    "k8s-manifests/services/api-gateway/api-gateway-deployment.yml"
    "k8s-manifests/services/admin-server/admin-server-deployment.yml"
    "k8s-manifests/databases/mysql-customer/mysql-customers-deployment.yml"
    "k8s-manifests/databases/mysql-vet/mysql-vets-deployment.yml"
    "k8s-manifests/databases/mysql-visit/mysql-visits-deployment.yml"
    "k8s-manifests/networking/network-policies.yml"
    "k8s-manifests/security/rbac.yml"
    "security/secrets/mysql-credentials.yml"
    "scripts/deployment/deploy-all.sh"
    "scripts/backup/database-backup.sh"
    "scripts/maintenance/health-check.sh"
    "validation/comprehensive-tests.sh"
    "validation/smoke-tests.sh"
    "validation/health-checks.sh"
    "monitoring/prometheus/prometheus-deployment.yml"
    "monitoring/grafana/grafana-deployment.yml"
    "monitoring/jaeger/jaeger-deployment.yml"
    "monitoring/alertmanager/alertmanager.yml"
    "helm-charts/petclinic/Chart.yaml"
    "helm-charts/petclinic/values.yaml"
    "performance/k6/load-test.js"
    "performance/benchmark.sh"
    "chaos-engineering/experiments/service-failure.yml"
    "ci-cd/gitlab-ci.yml"
    "backup-recovery/velero-backup.yml"
    "source-code/spring-petclinic-microservices/README.md"
)

total_files=${#files[@]}
found_files=0
missing_files=0

echo "Checking $total_files essential files..."
echo ""

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
        ((found_files++))
    else
        echo -e "${RED}❌ $file${NC}"
        ((missing_files++))
    fi
done

echo ""
echo "=============================================="
echo "Summary:"
echo -e "Found: ${GREEN}$found_files${NC} files"
echo -e "Missing: ${RED}$missing_files${NC} files"
echo -e "Total: $total_files files"

completion_rate=$((found_files * 100 / total_files))
echo -e "Completion Rate: ${YELLOW}$completion_rate%${NC}"

if [ $missing_files -eq 0 ]; then
    echo -e "${GREEN}🎉 All essential files are present!${NC}"
    echo ""
    echo "Project is ready for deployment:"
    echo "1. Run: ./scripts/deployment/deploy-all.sh"
    echo "2. Validate: ./validation/comprehensive-tests.sh"
    echo "3. Access: kubectl port-forward -n petclinic svc/api-gateway 8080:8080"
else
    echo -e "${RED}⚠️  Some files are missing. Please create them before deployment.${NC}"
fi
