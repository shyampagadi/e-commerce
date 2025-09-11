# Route 53 DNS Strategies

## Overview
Amazon Route 53 is a highly available and scalable DNS web service that provides reliable routing to infrastructure running on AWS and on-premises.

## Core DNS Concepts

### DNS Record Types
```bash
# A Record - Maps domain to IPv4 address
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "www.example.com",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{"Value": "192.0.2.1"}]
        }
    }]
}'

# CNAME Record - Maps domain to another domain
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "blog.example.com",
            "Type": "CNAME",
            "TTL": 300,
            "ResourceRecords": [{"Value": "www.example.com"}]
        }
    }]
}'
```

## Traffic Routing Policies

### 1. Simple Routing
**Use Case**: Single resource serving content
```bash
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "simple.example.com",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{"Value": "203.0.113.1"}]
        }
    }]
}'
```

### 2. Weighted Routing
**Use Case**: A/B testing, gradual deployments
```bash
# 70% traffic to primary
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "weighted.example.com",
            "Type": "A",
            "SetIdentifier": "Primary",
            "Weight": 70,
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.1"}]
        }
    }]
}'

# 30% traffic to secondary
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "weighted.example.com",
            "Type": "A",
            "SetIdentifier": "Secondary",
            "Weight": 30,
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.2"}]
        }
    }]
}'
```

### 3. Latency-Based Routing
**Use Case**: Global applications requiring low latency
```bash
# US East region
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "global.example.com",
            "Type": "A",
            "SetIdentifier": "US-East",
            "Region": "us-east-1",
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.1"}]
        }
    }]
}'

# EU West region
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "global.example.com",
            "Type": "A",
            "SetIdentifier": "EU-West",
            "Region": "eu-west-1",
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.2"}]
        }
    }]
}'
```

### 4. Geolocation Routing
**Use Case**: Content localization, compliance requirements
```bash
# North America traffic
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "geo.example.com",
            "Type": "A",
            "SetIdentifier": "North-America",
            "GeoLocation": {"ContinentCode": "NA"},
            "TTL": 300,
            "ResourceRecords": [{"Value": "203.0.113.1"}]
        }
    }]
}'

# Europe traffic
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "geo.example.com",
            "Type": "A",
            "SetIdentifier": "Europe",
            "GeoLocation": {"ContinentCode": "EU"},
            "TTL": 300,
            "ResourceRecords": [{"Value": "203.0.113.2"}]
        }
    }]
}'
```

### 5. Failover Routing
**Use Case**: Active-passive disaster recovery
```bash
# Primary endpoint with health check
aws route53 create-health-check --caller-reference $(date +%s) --health-check-config '{
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "primary.example.com",
    "Port": 80,
    "RequestInterval": 30,
    "FailureThreshold": 3
}'

# Primary record
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "failover.example.com",
            "Type": "A",
            "SetIdentifier": "Primary",
            "Failover": "PRIMARY",
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.1"}],
            "HealthCheckId": "health-check-id"
        }
    }]
}'

# Secondary record
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "failover.example.com",
            "Type": "A",
            "SetIdentifier": "Secondary",
            "Failover": "SECONDARY",
            "TTL": 60,
            "ResourceRecords": [{"Value": "203.0.113.2"}]
        }
    }]
}'
```

## Health Checks

### HTTP Health Check
```bash
aws route53 create-health-check --caller-reference $(date +%s) --health-check-config '{
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "api.example.com",
    "Port": 80,
    "RequestInterval": 30,
    "FailureThreshold": 3,
    "SearchString": "OK"
}'
```

### HTTPS Health Check with SNI
```bash
aws route53 create-health-check --caller-reference $(date +%s) --health-check-config '{
    "Type": "HTTPS_STR_MATCH",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "secure.example.com",
    "Port": 443,
    "RequestInterval": 30,
    "FailureThreshold": 3,
    "SearchString": "healthy",
    "EnableSNI": true
}'
```

### Calculated Health Check
```bash
aws route53 create-health-check --caller-reference $(date +%s) --health-check-config '{
    "Type": "CALCULATED",
    "ChildHealthChecks": ["health-check-1", "health-check-2", "health-check-3"],
    "HealthThreshold": 2,
    "CloudWatchAlarmRegion": "us-east-1",
    "InsufficientDataHealthStatus": "Failure"
}'
```

## Advanced DNS Strategies

### Multi-Region Failover with Health Checks
```bash
#!/bin/bash
# Create multi-region failover setup

# Primary region health check
PRIMARY_HC=$(aws route53 create-health-check --caller-reference "primary-$(date +%s)" --health-check-config '{
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "us-east-1.example.com",
    "Port": 80,
    "RequestInterval": 30,
    "FailureThreshold": 3
}' --query 'HealthCheck.Id' --output text)

# Secondary region health check
SECONDARY_HC=$(aws route53 create-health-check --caller-reference "secondary-$(date +%s)" --health-check-config '{
    "Type": "HTTP",
    "ResourcePath": "/health",
    "FullyQualifiedDomainName": "us-west-2.example.com",
    "Port": 80,
    "RequestInterval": 30,
    "FailureThreshold": 3
}' --query 'HealthCheck.Id' --output text)

# Primary record
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch "{
    \"Changes\": [{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"app.example.com\",
            \"Type\": \"A\",
            \"SetIdentifier\": \"Primary-US-East\",
            \"Failover\": \"PRIMARY\",
            \"TTL\": 60,
            \"ResourceRecords\": [{\"Value\": \"203.0.113.1\"}],
            \"HealthCheckId\": \"$PRIMARY_HC\"
        }
    }]
}"

# Secondary record
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch "{
    \"Changes\": [{
        \"Action\": \"CREATE\",
        \"ResourceRecordSet\": {
            \"Name\": \"app.example.com\",
            \"Type\": \"A\",
            \"SetIdentifier\": \"Secondary-US-West\",
            \"Failover\": \"SECONDARY\",
            \"TTL\": 60,
            \"ResourceRecords\": [{\"Value\": \"203.0.113.2\"}],
            \"HealthCheckId\": \"$SECONDARY_HC\"
        }
    }]
}"
```

### Geolocation with Failover
```bash
# US users - primary
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "service.example.com",
            "Type": "A",
            "SetIdentifier": "US-Primary",
            "GeoLocation": {"CountryCode": "US"},
            "TTL": 300,
            "ResourceRecords": [{"Value": "203.0.113.1"}],
            "HealthCheckId": "us-health-check"
        }
    }]
}'

# Default location - failover
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
    "Changes": [{
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": "service.example.com",
            "Type": "A",
            "SetIdentifier": "Default",
            "GeoLocation": {"CountryCode": "*"},
            "TTL": 300,
            "ResourceRecords": [{"Value": "203.0.113.3"}]
        }
    }]
}'
```

## Performance Optimization

### TTL Optimization Strategy
```python
# TTL optimization based on record type and usage
ttl_strategy = {
    'static_content': 86400,      # 24 hours
    'api_endpoints': 300,         # 5 minutes
    'load_balancer': 60,          # 1 minute
    'failover_records': 30,       # 30 seconds
    'maintenance_mode': 10        # 10 seconds
}
```

### DNS Query Monitoring
```bash
# Enable query logging
aws route53 create-query-logging-config --hosted-zone-id Z123456789 --cloud-watch-logs-log-group-arn arn:aws:logs:us-east-1:123456789012:log-group:route53-queries

# Monitor query patterns
aws logs filter-log-events --log-group-name route53-queries --filter-pattern "[timestamp, hosted_zone_id, query_name=\"example.com\", query_type, response_code, protocol, edge_location]"
```

## Cost Optimization

### Query Cost Analysis
```bash
# Get query metrics
aws cloudwatch get-metric-statistics --namespace AWS/Route53 --metric-name QueryCount --dimensions Name=HostedZoneId,Value=Z123456789 --start-time 2023-01-01T00:00:00Z --end-time 2023-01-31T23:59:59Z --period 86400 --statistics Sum

# Health check costs
aws route53 list-health-checks --query 'HealthChecks[?Type==`HTTP`].[Id,Type,FullyQualifiedDomainName]' --output table
```

### Optimization Strategies
1. **Consolidate Health Checks**: Use calculated health checks to reduce costs
2. **Optimize TTL Values**: Balance performance vs query costs
3. **Regional Health Checks**: Use CloudWatch alarms for cost-effective monitoring
4. **Query Pattern Analysis**: Identify and optimize high-volume queries

## Troubleshooting

### Common DNS Issues
```bash
# Test DNS resolution
dig @8.8.8.8 example.com
nslookup example.com 8.8.8.8

# Check Route 53 resolver
dig @169.254.169.253 example.com

# Verify health check status
aws route53 get-health-check-status --health-check-id health-check-id

# Check query logs
aws logs filter-log-events --log-group-name route53-queries --start-time $(date -d '1 hour ago' +%s)000
```

### Performance Testing
```bash
# DNS response time testing
for i in {1..10}; do
    time dig example.com @8.8.8.8 +short
done

# Global DNS propagation check
dig @1.1.1.1 example.com
dig @8.8.8.8 example.com
dig @208.67.222.222 example.com
```

## Best Practices

### Security
- Use DNSSEC for domain validation
- Implement DNS filtering for malicious domains
- Monitor for DNS hijacking attempts
- Use private hosted zones for internal resources

### Performance
- Optimize TTL values based on change frequency
- Use alias records for AWS resources
- Implement geographic routing for global applications
- Monitor and optimize health check intervals

### Cost Management
- Regularly review and consolidate health checks
- Use calculated health checks for complex scenarios
- Monitor query patterns and optimize high-volume queries
- Consider Route 53 Resolver for hybrid architectures
