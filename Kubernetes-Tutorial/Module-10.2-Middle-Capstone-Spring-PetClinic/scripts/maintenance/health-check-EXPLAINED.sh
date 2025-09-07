#!/bin/bash

# =============================================================================
# SPRING PETCLINIC HEALTH CHECK SCRIPT - COMPREHENSIVE MONITORING DOCUMENTATION
# =============================================================================
# This script implements automated health monitoring for the Spring PetClinic
# microservices platform. It provides rapid assessment of all critical services
# and databases, enabling quick identification of system issues and operational
# status verification for maintenance and troubleshooting activities.
#
# MONITORING PHILOSOPHY: This script implements "at-a-glance" health monitoring,
# providing immediate visibility into system status without requiring detailed
# knowledge of individual service configurations or complex monitoring tools.
#
# OPERATIONAL IMPACT: Health checks are essential for proactive monitoring,
# incident response, and maintenance procedures, providing the first line of
# defense in identifying system issues before they impact users.
# =============================================================================

# -----------------------------------------------------------------------------
# HEALTH CHECK CONFIGURATION - MONITORING PARAMETERS
# -----------------------------------------------------------------------------
# Target Kubernetes namespace for health monitoring
NAMESPACE="petclinic"
# NAMESPACE_SCOPE: Defines the boundary for health check operations
# MULTI_ENVIRONMENT_SUPPORT: Enables health checks across different deployments

# Color definitions for visual status indication
GREEN='\033[0;32m'    # Healthy/Running status indication
RED='\033[0;31m'      # Unhealthy/Failed status indication
NC='\033[0m'          # No Color - resets terminal formatting
# VISUAL_FEEDBACK: Color coding provides immediate status recognition
# ACCESSIBILITY: Clear visual distinction between healthy and unhealthy states

# -----------------------------------------------------------------------------
# HEALTH CHECK EXECUTION - SYSTEM STATUS ASSESSMENT
# -----------------------------------------------------------------------------
echo "🏥 Spring PetClinic Health Check"
echo "================================"
# HEADER_DISPLAY: Clear identification of health check operation
# VISUAL_SEPARATION: Improves output readability and professional appearance

# Define array of microservices to monitor
services=("config-server" "discovery-server" "customers-service" "vets-service" "visits-service" "api-gateway" "admin-server")
# SERVICE_INVENTORY: Comprehensive list of all critical microservices
# ARRAY_STRUCTURE: Enables efficient iteration through all services
# COMPLETE_COVERAGE: Includes infrastructure, business, and gateway services

# Iterate through each service for health assessment
for service in "${services[@]}"; do
    echo -n "Checking $service... "
    # PROGRESS_INDICATION: Shows current service being checked
    # INLINE_OUTPUT: Keeps status on same line for compact display
    
    # Check if service pods are in Running state
    if kubectl get pods -n $NAMESPACE -l app=$service | grep -q Running; then
        echo -e "${GREEN}✅ Healthy${NC}"
        # SUCCESS_INDICATION: Green checkmark for healthy services
        # POSITIVE_FEEDBACK: Clear indication of operational status
    else
        echo -e "${RED}❌ Unhealthy${NC}"
        # FAILURE_INDICATION: Red X for unhealthy or missing services
        # PROBLEM_IDENTIFICATION: Immediate visibility of issues
    fi
    # KUBECTL_INTEGRATION: Uses native Kubernetes pod status checking
    # LABEL_SELECTOR: Targets pods by application label for accurate identification
done

echo ""
echo "Database Status:"
# SECTION_SEPARATION: Clear distinction between service and database checks
# CATEGORY_ORGANIZATION: Groups related components for better understanding

# Define array of database services to monitor
databases=("mysql-customers" "mysql-vets" "mysql-visits")
# DATABASE_INVENTORY: Complete list of all database instances
# MICROSERVICE_PATTERN: Each microservice has dedicated database
# DATA_LAYER_MONITORING: Ensures persistent storage layer is operational

# Iterate through each database for health assessment
for db in "${databases[@]}"; do
    echo -n "Checking $db... "
    # DATABASE_PROGRESS: Shows current database being checked
    
    # Check if database pods are in Running state
    if kubectl get pods -n $NAMESPACE -l app=$db | grep -q Running; then
        echo -e "${GREEN}✅ Running${NC}"
        # DATABASE_SUCCESS: Indicates database is operational
        # PERSISTENCE_CONFIRMATION: Confirms data layer availability
    else
        echo -e "${RED}❌ Down${NC}"
        # DATABASE_FAILURE: Indicates database issues or unavailability
        # CRITICAL_ALERT: Database failures require immediate attention
    fi
done

# =============================================================================
# HEALTH CHECK SCRIPT ANALYSIS AND PRODUCTION ENHANCEMENTS
# =============================================================================
#
# CURRENT HEALTH CHECK STRENGTHS:
# ✅ COMPREHENSIVE_COVERAGE: Monitors all critical services and databases
# ✅ VISUAL_FEEDBACK: Clear color-coded status indication
# ✅ RAPID_ASSESSMENT: Quick overview of entire platform health
# ✅ SIMPLE_EXECUTION: Easy to run manually or in automation
# ✅ KUBERNETES_INTEGRATION: Native kubectl commands for accurate status
# ✅ ORGANIZED_OUTPUT: Logical grouping of services and databases
#
# PRODUCTION ENHANCEMENTS NEEDED:
#
# 1. DETAILED HEALTH METRICS AND REPORTING:
#    #!/bin/bash
#    # Enhanced health check with detailed metrics
#    
#    check_service_health() {
#        local service=$1
#        local healthy_pods=0
#        local total_pods=0
#        local ready_pods=0
#        
#        # Get pod status details
#        local pod_info=$(kubectl get pods -n $NAMESPACE -l app=$service -o jsonpath='{range .items[*]}{.status.phase},{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}')
#        
#        while IFS=',' read -r phase ready; do
#            total_pods=$((total_pods + 1))
#            [[ "$phase" == "Running" ]] && healthy_pods=$((healthy_pods + 1))
#            [[ "$ready" == "True" ]] && ready_pods=$((ready_pods + 1))
#        done <<< "$pod_info"
#        
#        echo -n "Checking $service... "
#        if [[ $healthy_pods -eq $total_pods && $ready_pods -eq $total_pods ]]; then
#            echo -e "${GREEN}✅ Healthy ($healthy_pods/$total_pods running, $ready_pods/$total_pods ready)${NC}"
#            return 0
#        else
#            echo -e "${RED}❌ Unhealthy ($healthy_pods/$total_pods running, $ready_pods/$total_pods ready)${NC}"
#            return 1
#        fi
#    }
#
# 2. HTTP ENDPOINT HEALTH VALIDATION:
#    check_endpoint_health() {
#        local service=$1
#        local port=$2
#        local path=${3:-/actuator/health}
#        
#        echo -n "Testing $service endpoint... "
#        
#        # Start port-forward in background
#        kubectl port-forward -n $NAMESPACE svc/$service $port:$port &>/dev/null &
#        local pf_pid=$!
#        sleep 2
#        
#        # Test HTTP endpoint
#        local status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port$path 2>/dev/null || echo "000")
#        
#        # Cleanup port-forward
#        kill $pf_pid 2>/dev/null || true
#        wait $pf_pid 2>/dev/null || true
#        
#        if [[ "$status_code" == "200" ]]; then
#            echo -e "${GREEN}✅ Responsive (HTTP $status_code)${NC}"
#            return 0
#        else
#            echo -e "${RED}❌ Unresponsive (HTTP $status_code)${NC}"
#            return 1
#        fi
#    }
#
# 3. DATABASE CONNECTIVITY TESTING:
#    check_database_connectivity() {
#        local db_service=$1
#        local db_pod="${db_service}-0"  # StatefulSet pod naming
#        
#        echo -n "Testing $db_service connectivity... "
#        
#        # Test database connection
#        if kubectl exec -n $NAMESPACE $db_pod -- \
#            mysql -u root -p"$DB_ROOT_PASSWORD" -e "SELECT 1" &>/dev/null; then
#            echo -e "${GREEN}✅ Connected${NC}"
#            return 0
#        else
#            echo -e "${RED}❌ Connection Failed${NC}"
#            return 1
#        fi
#    }
#
# 4. RESOURCE UTILIZATION MONITORING:
#    check_resource_usage() {
#        echo ""
#        echo "Resource Utilization:"
#        echo "===================="
#        
#        # Check CPU and memory usage
#        kubectl top pods -n $NAMESPACE --no-headers | while read -r pod cpu memory; do
#            # Parse CPU (remove 'm' suffix)
#            cpu_num=${cpu%m}
#            # Parse memory (remove 'Mi' suffix)
#            memory_num=${memory%Mi}
#            
#            # Color code based on usage thresholds
#            if [[ $cpu_num -gt 500 || $memory_num -gt 1000 ]]; then
#                echo -e "$pod: CPU: ${RED}${cpu}${NC}, Memory: ${RED}${memory}${NC}"
#            elif [[ $cpu_num -gt 250 || $memory_num -gt 500 ]]; then
#                echo -e "$pod: CPU: ${YELLOW}${cpu}${NC}, Memory: ${YELLOW}${memory}${NC}"
#            else
#                echo -e "$pod: CPU: ${GREEN}${cpu}${NC}, Memory: ${GREEN}${memory}${NC}"
#            fi
#        done
#    }
#
# 5. SERVICE DISCOVERY VALIDATION:
#    check_service_discovery() {
#        echo ""
#        echo "Service Discovery Status:"
#        echo "========================"
#        
#        # Check Eureka registration
#        kubectl port-forward -n $NAMESPACE svc/discovery-server 8761:8761 &>/dev/null &
#        local pf_pid=$!
#        sleep 3
#        
#        local registered_services=$(curl -s http://localhost:8761/eureka/apps | \
#            grep -o '<name>[^<]*</name>' | sed 's/<[^>]*>//g' | sort -u)
#        
#        kill $pf_pid 2>/dev/null || true
#        wait $pf_pid 2>/dev/null || true
#        
#        if [[ -n "$registered_services" ]]; then
#            echo -e "${GREEN}✅ Service Discovery Active${NC}"
#            echo "Registered Services:"
#            echo "$registered_services" | sed 's/^/  - /'
#        else
#            echo -e "${RED}❌ Service Discovery Issues${NC}"
#        fi
#    }
#
# 6. COMPREHENSIVE HEALTH SUMMARY AND ALERTING:
#    generate_health_summary() {
#        local total_checks=$1
#        local failed_checks=$2
#        local success_rate=$(( (total_checks - failed_checks) * 100 / total_checks ))
#        
#        echo ""
#        echo "=========================================="
#        echo "           HEALTH CHECK SUMMARY"
#        echo "=========================================="
#        echo "Total Checks: $total_checks"
#        echo -e "Passed: ${GREEN}$((total_checks - failed_checks))${NC}"
#        echo -e "Failed: ${RED}$failed_checks${NC}"
#        echo "Success Rate: $success_rate%"
#        echo ""
#        
#        if [[ $failed_checks -eq 0 ]]; then
#            echo -e "${GREEN}🎉 All systems operational!${NC}"
#            return 0
#        else
#            echo -e "${RED}⚠️ $failed_checks issues detected. Investigation required.${NC}"
#            return 1
#        fi
#    }
#
# 7. INTEGRATION WITH MONITORING SYSTEMS:
#    send_health_metrics() {
#        local service=$1
#        local status=$2  # 1 for healthy, 0 for unhealthy
#        
#        # Send metrics to Prometheus Pushgateway
#        if [[ -n "$PUSHGATEWAY_URL" ]]; then
#            echo "petclinic_service_health{service=\"$service\",namespace=\"$NAMESPACE\"} $status" | \
#                curl --data-binary @- "$PUSHGATEWAY_URL/metrics/job/health_check"
#        fi
#        
#        # Send to InfluxDB
#        if [[ -n "$INFLUXDB_URL" ]]; then
#            curl -XPOST "$INFLUXDB_URL/write?db=petclinic" \
#                --data-binary "service_health,service=$service,namespace=$NAMESPACE value=$status"
#        fi
#    }
#
# 8. AUTOMATED REMEDIATION ACTIONS:
#    attempt_service_recovery() {
#        local service=$1
#        
#        echo "Attempting to recover $service..."
#        
#        # Restart deployment
#        kubectl rollout restart deployment/$service -n $NAMESPACE
#        
#        # Wait for rollout to complete
#        kubectl rollout status deployment/$service -n $NAMESPACE --timeout=300s
#        
#        # Verify recovery
#        sleep 30
#        if check_service_health $service; then
#            echo -e "${GREEN}✅ $service recovered successfully${NC}"
#            return 0
#        else
#            echo -e "${RED}❌ $service recovery failed${NC}"
#            return 1
#        fi
#    }
#
# OPERATIONAL INTEGRATION:
#
# 1. CRON JOB SCHEDULING:
#    # Add to crontab for regular health monitoring
#    # */5 * * * * /path/to/health-check.sh >> /var/log/petclinic-health.log 2>&1
#
# 2. NAGIOS/ICINGA INTEGRATION:
#    # Create Nagios plugin wrapper
#    # Exit codes: 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN
#
# 3. KUBERNETES CRONJOB:
#    apiVersion: batch/v1
#    kind: CronJob
#    metadata:
#      name: petclinic-health-check
#    spec:
#      schedule: "*/5 * * * *"  # Every 5 minutes
#      jobTemplate:
#        spec:
#          template:
#            spec:
#              containers:
#              - name: health-check
#                image: kubectl:latest
#                command: ["/bin/bash", "/scripts/health-check.sh"]
#
# ALERTING AND NOTIFICATION:
#
# 1. SLACK INTEGRATION:
#    send_slack_alert() {
#        local message=$1
#        local webhook_url="$SLACK_WEBHOOK_URL"
#        
#        if [[ -n "$webhook_url" ]]; then
#            curl -X POST -H 'Content-type: application/json' \
#                --data "{\"text\":\"🏥 PetClinic Health Alert: $message\"}" \
#                "$webhook_url"
#        fi
#    }
#
# 2. EMAIL NOTIFICATIONS:
#    send_email_alert() {
#        local subject=$1
#        local body=$2
#        
#        if command -v mail &> /dev/null; then
#            echo "$body" | mail -s "$subject" "$ADMIN_EMAIL"
#        fi
#    }
#
# COMPLIANCE AND GOVERNANCE:
# - Health check logging for audit trails
# - SLA monitoring and reporting
# - Incident response integration
# - Change management correlation
# - Performance baseline establishment
#
# =============================================================================
