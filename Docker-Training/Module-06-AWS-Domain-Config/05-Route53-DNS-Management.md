# Route 53 DNS Management

## Table of Contents
1. [Route 53 Overview](#route-53-overview)
2. [Hosted Zones](#hosted-zones)
3. [DNS Record Types](#dns-record-types)
4. [Routing Policies](#routing-policies)
5. [Health Checks](#health-checks)
6. [Advanced DNS Features](#advanced-dns-features)

## Route 53 Overview

### DNS Fundamentals
```bash
# DNS Resolution Process:
# 1. User enters domain name in browser
# 2. Browser queries local DNS resolver
# 3. Resolver queries root name servers
# 4. Root servers direct to TLD servers (.com, .org, etc.)
# 5. TLD servers direct to authoritative name servers
# 6. Authoritative servers return IP address
# 7. Browser connects to IP address

# Route 53 Components:
# - Hosted Zones: DNS namespace for a domain
# - Record Sets: DNS records within hosted zones
# - Health Checks: Monitor endpoint health
# - Traffic Policies: Advanced routing configurations
```

### Route 53 Service Features
```bash
# Domain Registration:
# - Register new domains
# - Transfer existing domains
# - Automatic DNS configuration

# DNS Hosting:
# - Authoritative DNS service
# - Global anycast network
# - 100% uptime SLA

# Health Checking:
# - Endpoint monitoring
# - Automatic failover
# - Integration with CloudWatch

# Traffic Management:
# - Multiple routing policies
# - Geolocation routing
# - Latency-based routing
```

## Hosted Zones

### Create Hosted Zone
```bash
# Create hosted zone for domain
aws route53 create-hosted-zone \
    --name example.com \
    --caller-reference $(date +%s) \
    --hosted-zone-config Comment="Production domain for containerized applications"

# Get hosted zone details
aws route53 list-hosted-zones \
    --query 'HostedZones[?Name==`example.com.`]'

# Get name servers for domain configuration
aws route53 get-hosted-zone \
    --id /hostedzone/Z1234567890123 \
    --query 'DelegationSet.NameServers'
```

### Hosted Zone Configuration
```json
{
  "HostedZone": {
    "Id": "/hostedzone/Z1234567890123",
    "Name": "example.com.",
    "CallerReference": "1640995200",
    "Config": {
      "Comment": "Production domain for containerized applications",
      "PrivateZone": false
    },
    "ResourceRecordSetCount": 2
  },
  "DelegationSet": {
    "NameServers": [
      "ns-1234.awsdns-12.org",
      "ns-5678.awsdns-34.net",
      "ns-9012.awsdns-56.com",
      "ns-3456.awsdns-78.co.uk"
    ]
  }
}
```

### Private Hosted Zones
```bash
# Create private hosted zone for internal DNS
aws route53 create-hosted-zone \
    --name internal.example.com \
    --caller-reference $(date +%s)-private \
    --vpc VPCRegion=us-east-1,VPCId=vpc-12345678 \
    --hosted-zone-config Comment="Internal DNS for VPC",PrivateZone=true

# Associate additional VPCs
aws route53 associate-vpc-with-hosted-zone \
    --hosted-zone-id /hostedzone/Z9876543210987 \
    --vpc VPCRegion=us-west-2,VPCId=vpc-87654321
```

## DNS Record Types

### A and AAAA Records
```bash
# Create A record pointing to IP address
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.example.com",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "203.0.113.1"}]
            }
        }]
    }'

# Create AAAA record for IPv6
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.example.com",
                "Type": "AAAA",
                "TTL": 300,
                "ResourceRecords": [{"Value": "2001:db8::1"}]
            }
        }]
    }'
```

### CNAME Records
```bash
# Create CNAME record for subdomain
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
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

# CNAME for CDN
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "cdn.example.com",
                "Type": "CNAME",
                "TTL": 86400,
                "ResourceRecords": [{"Value": "d1234567890123.cloudfront.net"}]
            }
        }]
    }'
```

### Alias Records
```bash
# Alias record pointing to Application Load Balancer
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "example.com",
                "Type": "A",
                "AliasTarget": {
                    "DNSName": "my-load-balancer-1234567890.us-east-1.elb.amazonaws.com",
                    "EvaluateTargetHealth": true,
                    "HostedZoneId": "Z35SXDOTRQ7X7K"
                }
            }
        }]
    }'

# Alias record for CloudFront distribution
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.example.com",
                "Type": "A",
                "AliasTarget": {
                    "DNSName": "d1234567890123.cloudfront.net",
                    "EvaluateTargetHealth": false,
                    "HostedZoneId": "Z2FDTNDATAQYW2"
                }
            }
        }]
    }'
```

### MX and TXT Records
```bash
# MX records for email
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "example.com",
                "Type": "MX",
                "TTL": 300,
                "ResourceRecords": [
                    {"Value": "10 mail.example.com"},
                    {"Value": "20 mail2.example.com"}
                ]
            }
        }]
    }'

# TXT records for verification and SPF
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "example.com",
                "Type": "TXT",
                "TTL": 300,
                "ResourceRecords": [
                    {"Value": "\"v=spf1 include:_spf.google.com ~all\""},
                    {"Value": "\"google-site-verification=abc123def456\""}
                ]
            }
        }]
    }'
```

## Routing Policies

### Simple Routing
```bash
# Simple routing - single resource
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
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

### Weighted Routing
```bash
# Weighted routing for A/B testing or gradual rollouts
# 80% traffic to primary server
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "app.example.com",
                "Type": "A",
                "SetIdentifier": "Primary-80",
                "Weight": 80,
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.1"}]
            }
        }]
    }'

# 20% traffic to secondary server
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "app.example.com",
                "Type": "A",
                "SetIdentifier": "Secondary-20",
                "Weight": 20,
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.2"}]
            }
        }]
    }'
```

### Latency-Based Routing
```bash
# US East region
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
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

# Europe region
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "global.example.com",
                "Type": "A",
                "SetIdentifier": "Europe",
                "Region": "eu-west-1",
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.10"}]
            }
        }]
    }'
```

### Geolocation Routing
```bash
# Default location (fallback)
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "geo.example.com",
                "Type": "A",
                "SetIdentifier": "Default",
                "GeoLocation": {"CountryCode": "*"},
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.1"}]
            }
        }]
    }'

# US-specific routing
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "geo.example.com",
                "Type": "A",
                "SetIdentifier": "US",
                "GeoLocation": {"CountryCode": "US"},
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.2"}]
            }
        }]
    }'

# Europe-specific routing
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "geo.example.com",
                "Type": "A",
                "SetIdentifier": "Europe",
                "GeoLocation": {"ContinentCode": "EU"},
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.10"}]
            }
        }]
    }'
```

### Failover Routing
```bash
# Primary record with health check
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "failover.example.com",
                "Type": "A",
                "SetIdentifier": "Primary",
                "Failover": "PRIMARY",
                "TTL": 60,
                "ResourceRecords": [{"Value": "203.0.113.1"}],
                "HealthCheckId": "12345678-1234-1234-1234-123456789012"
            }
        }]
    }'

# Secondary record (failover target)
aws route53 change-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --change-batch '{
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
# Create HTTP health check
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config '{
        "Type": "HTTP",
        "ResourcePath": "/health",
        "FullyQualifiedDomainName": "example.com",
        "Port": 80,
        "RequestInterval": 30,
        "FailureThreshold": 3
    }' \
    --cloud-watch-alarm-region us-east-1

# HTTPS health check with SNI
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config '{
        "Type": "HTTPS_STR_MATCH",
        "ResourcePath": "/api/health",
        "FullyQualifiedDomainName": "api.example.com",
        "Port": 443,
        "RequestInterval": 30,
        "FailureThreshold": 3,
        "SearchString": "\"status\":\"healthy\"",
        "EnableSNI": true
    }'
```

### Calculated Health Check
```bash
# Create calculated health check (monitors multiple endpoints)
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config '{
        "Type": "CALCULATED",
        "ChildHealthChecks": [
            "12345678-1234-1234-1234-123456789012",
            "87654321-4321-4321-4321-210987654321"
        ],
        "HealthThreshold": 1,
        "CloudWatchAlarmRegion": "us-east-1",
        "InsufficientDataHealthStatus": "Failure"
    }'
```

### Health Check Monitoring
```bash
# Get health check status
aws route53 get-health-check-status \
    --health-check-id 12345678-1234-1234-1234-123456789012

# List health checks
aws route53 list-health-checks \
    --query 'HealthChecks[*].[Id,Config.Type,Config.FullyQualifiedDomainName]' \
    --output table

# Create CloudWatch alarm for health check
aws cloudwatch put-metric-alarm \
    --alarm-name "Route53-HealthCheck-Failed" \
    --alarm-description "Route53 health check failed" \
    --metric-name HealthCheckStatus \
    --namespace AWS/Route53 \
    --statistic Minimum \
    --period 60 \
    --threshold 1 \
    --comparison-operator LessThanThreshold \
    --dimensions Name=HealthCheckId,Value=12345678-1234-1234-1234-123456789012 \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:route53-alerts
```

## Advanced DNS Features

### DNS Query Logging
```bash
# Create CloudWatch log group
aws logs create-log-group --log-group-name /aws/route53/queries

# Configure query logging
aws route53 create-query-logging-config \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --cloud-watch-logs-log-group-arn arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/queries
```

### Traffic Policies
```bash
# Create traffic policy for complex routing
aws route53 create-traffic-policy \
    --name "Multi-Region-Failover" \
    --document '{
        "AWSPolicyFormatVersion": "2015-10-01",
        "RecordType": "A",
        "Endpoints": {
            "primary": {
                "Type": "value",
                "Value": "203.0.113.1"
            },
            "secondary": {
                "Type": "value", 
                "Value": "203.0.113.2"
            }
        },
        "Rules": {
            "rule1": {
                "RuleType": "failover",
                "Primary": {
                    "EndpointReference": "primary",
                    "HealthCheck": "12345678-1234-1234-1234-123456789012"
                },
                "Secondary": {
                    "EndpointReference": "secondary"
                }
            }
        },
        "StartRule": "rule1"
    }'

# Create traffic policy instance
aws route53 create-traffic-policy-instance \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --name "app.example.com" \
    --ttl 60 \
    --traffic-policy-id 12345678-1234-1234-1234-123456789012 \
    --traffic-policy-version 1
```

### DNS Management Script
```bash
#!/bin/bash
# dns-management.sh

HOSTED_ZONE_ID="/hostedzone/Z1234567890123"
DOMAIN="example.com"

# Function to create or update DNS record
update_dns_record() {
    local name=$1
    local type=$2
    local value=$3
    local ttl=${4:-300}
    
    echo "Updating DNS record: $name ($type) -> $value"
    
    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch '{
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$name'",
                    "Type": "'$type'",
                    "TTL": '$ttl',
                    "ResourceRecords": [{"Value": "'$value'"}]
                }
            }]
        }'
}

# Function to create alias record
create_alias_record() {
    local name=$1
    local target_dns=$2
    local target_zone=$3
    local health_check=${4:-false}
    
    echo "Creating alias record: $name -> $target_dns"
    
    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch '{
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$name'",
                    "Type": "A",
                    "AliasTarget": {
                        "DNSName": "'$target_dns'",
                        "EvaluateTargetHealth": '$health_check',
                        "HostedZoneId": "'$target_zone'"
                    }
                }
            }]
        }'
}

# Function to validate DNS propagation
validate_dns() {
    local name=$1
    local expected_ip=$2
    
    echo "Validating DNS propagation for $name..."
    
    # Check multiple DNS servers
    local dns_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222")
    
    for dns in "${dns_servers[@]}"; do
        echo "Checking $dns..."
        result=$(dig @$dns +short $name A)
        if [[ "$result" == "$expected_ip" ]]; then
            echo "✓ $dns: $result"
        else
            echo "✗ $dns: $result (expected: $expected_ip)"
        fi
    done
}

# Example usage
case "${1:-help}" in
    "setup")
        # Setup basic DNS records
        update_dns_record "$DOMAIN" "A" "203.0.113.1"
        update_dns_record "www.$DOMAIN" "CNAME" "$DOMAIN"
        update_dns_record "api.$DOMAIN" "A" "203.0.113.2"
        ;;
    "validate")
        validate_dns "$DOMAIN" "203.0.113.1"
        validate_dns "www.$DOMAIN" "203.0.113.1"
        ;;
    "help"|*)
        echo "Usage: $0 {setup|validate}"
        echo "  setup    - Create basic DNS records"
        echo "  validate - Validate DNS propagation"
        ;;
esac
```

This comprehensive guide covers Route 53 DNS management from basic record creation to advanced traffic policies and health checks for production containerized applications.
