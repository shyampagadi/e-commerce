# Project 02-A Solution: Network Architecture Design

## Executive Summary

This solution presents a comprehensive network architecture for a global e-commerce platform supporting 10 million users across multiple regions. The design emphasizes high availability, security, performance, and cost optimization while meeting strict compliance requirements.

## Architecture Overview

### Global Network Topology
```
                    ┌─────────────────────────────────────┐
                    │           Route 53 DNS             │
                    │     (Global Traffic Management)    │
                    └─────────────────┬───────────────────┘
                                      │
                    ┌─────────────────┴───────────────────┐
                    │          CloudFront CDN            │
                    │      (Global Edge Locations)       │
                    └─────────────────┬───────────────────┘
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
   ┌────▼────┐                  ┌────▼────┐                  ┌────▼────┐
   │US-EAST-1│                  │EU-WEST-1│                  │AP-SOUTH-1│
   │ Primary │                  │Secondary│                  │ Tertiary│
   └─────────┘                  └─────────┘                  └─────────┘
```

### Regional Architecture (US-EAST-1 Primary)
```
┌─────────────────────────────────────────────────────────────────────┐
│                            VPC (10.0.0.0/16)                       │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │   Public Subnet │    │   Public Subnet │    │   Public Subnet │  │
│  │   10.0.1.0/24   │    │   10.0.2.0/24   │    │   10.0.3.0/24   │  │
│  │      AZ-1a      │    │      AZ-1b      │    │      AZ-1c      │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
│           │                       │                       │         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  Private Subnet │    │  Private Subnet │    │  Private Subnet │  │
│  │   10.0.11.0/24  │    │   10.0.12.0/24  │    │   10.0.13.0/24  │  │
│  │   (App Tier)    │    │   (App Tier)    │    │   (App Tier)    │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
│           │                       │                       │         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  Private Subnet │    │  Private Subnet │    │  Private Subnet │  │
│  │   10.0.21.0/24  │    │   10.0.22.0/24  │    │   10.0.23.0/24  │  │
│  │   (Data Tier)   │    │   (Data Tier)   │    │   (Data Tier)   │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Detailed Component Design

### 1. DNS and Traffic Management

#### Route 53 Configuration
```python
class Route53Configuration:
    def __init__(self):
        self.hosted_zone = "ecommerce-global.com"
        self.routing_policies = {
            'primary': {
                'type': 'weighted',
                'regions': {
                    'us-east-1': {'weight': 60, 'health_check': True},
                    'eu-west-1': {'weight': 30, 'health_check': True},
                    'ap-south-1': {'weight': 10, 'health_check': True}
                }
            },
            'failover': {
                'type': 'failover',
                'primary': 'us-east-1',
                'secondary': 'eu-west-1'
            },
            'geolocation': {
                'type': 'geolocation',
                'mappings': {
                    'NA': 'us-east-1',
                    'EU': 'eu-west-1',
                    'AS': 'ap-south-1'
                }
            }
        }
    
    def create_health_checks(self):
        health_checks = []
        for region in ['us-east-1', 'eu-west-1', 'ap-south-1']:
            health_checks.append({
                'type': 'HTTPS',
                'fqdn': f'{region}.ecommerce-global.com',
                'path': '/health',
                'interval': 30,
                'failure_threshold': 3
            })
        return health_checks
```

#### Implementation Commands
```bash
# Create hosted zone
aws route53 create-hosted-zone \
    --name ecommerce-global.com \
    --caller-reference $(date +%s)

# Create health checks for each region
aws route53 create-health-check \
    --caller-reference us-east-1-$(date +%s) \
    --health-check-config '{
        "Type": "HTTPS",
        "ResourcePath": "/health",
        "FullyQualifiedDomainName": "us-east-1.ecommerce-global.com",
        "Port": 443,
        "RequestInterval": 30,
        "FailureThreshold": 3
    }'

# Create weighted routing records
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789 \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "api.ecommerce-global.com",
                "Type": "A",
                "SetIdentifier": "US-East-Primary",
                "Weight": 60,
                "AliasTarget": {
                    "DNSName": "us-east-alb-123456789.us-east-1.elb.amazonaws.com",
                    "EvaluateTargetHealth": true,
                    "HostedZoneId": "Z35SXDOTRQ7X7K"
                },
                "HealthCheckId": "health-check-us-east-1"
            }
        }]
    }'
```

### 2. Content Delivery Network

#### CloudFront Distribution Configuration
```json
{
    "DistributionConfig": {
        "CallerReference": "ecommerce-cdn-2023",
        "Comment": "Global e-commerce CDN",
        "DefaultRootObject": "index.html",
        "Origins": [
            {
                "Id": "primary-origin",
                "DomainName": "api.ecommerce-global.com",
                "CustomOriginConfig": {
                    "HTTPPort": 80,
                    "HTTPSPort": 443,
                    "OriginProtocolPolicy": "https-only",
                    "OriginSslProtocols": {
                        "Quantity": 1,
                        "Items": ["TLSv1.2"]
                    }
                }
            }
        ],
        "DefaultCacheBehavior": {
            "TargetOriginId": "primary-origin",
            "ViewerProtocolPolicy": "redirect-to-https",
            "CachePolicyId": "4135ea2d-6df8-44a3-9df3-4b5a84be39ad",
            "Compress": true,
            "TrustedSigners": {
                "Enabled": false,
                "Quantity": 0
            }
        },
        "CacheBehaviors": [
            {
                "PathPattern": "/api/*",
                "TargetOriginId": "primary-origin",
                "ViewerProtocolPolicy": "https-only",
                "CachePolicyId": "4135ea2d-6df8-44a3-9df3-4b5a84be39ad",
                "TTL": 0
            },
            {
                "PathPattern": "/static/*",
                "TargetOriginId": "primary-origin",
                "ViewerProtocolPolicy": "https-only",
                "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
                "TTL": 86400
            }
        ],
        "Enabled": true,
        "PriceClass": "PriceClass_All"
    }
}
```

### 3. Load Balancing Architecture

#### Application Load Balancer Configuration
```python
class LoadBalancerConfiguration:
    def __init__(self):
        self.alb_config = {
            'name': 'ecommerce-alb',
            'scheme': 'internet-facing',
            'type': 'application',
            'ip_address_type': 'ipv4',
            'subnets': ['subnet-12345678', 'subnet-87654321', 'subnet-13579246'],
            'security_groups': ['sg-alb-12345678']
        }
        
        self.target_groups = {
            'web-servers': {
                'name': 'web-servers-tg',
                'port': 80,
                'protocol': 'HTTP',
                'health_check': {
                    'path': '/health',
                    'interval': 30,
                    'timeout': 5,
                    'healthy_threshold': 2,
                    'unhealthy_threshold': 3
                }
            },
            'api-servers': {
                'name': 'api-servers-tg',
                'port': 8080,
                'protocol': 'HTTP',
                'health_check': {
                    'path': '/api/health',
                    'interval': 30,
                    'timeout': 5,
                    'healthy_threshold': 2,
                    'unhealthy_threshold': 3
                }
            }
        }
    
    def create_listener_rules(self):
        return [
            {
                'priority': 100,
                'conditions': [{'field': 'path-pattern', 'values': ['/api/*']}],
                'actions': [{'type': 'forward', 'target_group_arn': 'api-servers-tg'}]
            },
            {
                'priority': 200,
                'conditions': [{'field': 'path-pattern', 'values': ['/*']}],
                'actions': [{'type': 'forward', 'target_group_arn': 'web-servers-tg'}]
            }
        ]
```

#### Implementation Commands
```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
    --name ecommerce-alb \
    --subnets subnet-12345678 subnet-87654321 subnet-13579246 \
    --security-groups sg-alb-12345678 \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4

# Create target groups
aws elbv2 create-target-group \
    --name web-servers-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Create listeners with rules
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/ecommerce-alb/1234567890123456 \
    --protocol HTTPS \
    --port 443 \
    --certificates CertificateArn=arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/web-servers-tg/1234567890123456
```

### 4. Security Architecture

#### Security Groups Configuration
```python
class SecurityGroupsConfiguration:
    def __init__(self):
        self.security_groups = {
            'alb-sg': {
                'description': 'Security group for Application Load Balancer',
                'ingress_rules': [
                    {'protocol': 'tcp', 'port': 80, 'source': '0.0.0.0/0'},
                    {'protocol': 'tcp', 'port': 443, 'source': '0.0.0.0/0'}
                ],
                'egress_rules': [
                    {'protocol': 'tcp', 'port': 80, 'destination': 'sg-web-servers'},
                    {'protocol': 'tcp', 'port': 8080, 'destination': 'sg-api-servers'}
                ]
            },
            'web-servers-sg': {
                'description': 'Security group for web servers',
                'ingress_rules': [
                    {'protocol': 'tcp', 'port': 80, 'source': 'sg-alb'},
                    {'protocol': 'tcp', 'port': 22, 'source': 'sg-bastion'}
                ],
                'egress_rules': [
                    {'protocol': 'tcp', 'port': 8080, 'destination': 'sg-api-servers'},
                    {'protocol': 'tcp', 'port': 443, 'destination': '0.0.0.0/0'}
                ]
            },
            'api-servers-sg': {
                'description': 'Security group for API servers',
                'ingress_rules': [
                    {'protocol': 'tcp', 'port': 8080, 'source': 'sg-web-servers'},
                    {'protocol': 'tcp', 'port': 8080, 'source': 'sg-alb'},
                    {'protocol': 'tcp', 'port': 22, 'source': 'sg-bastion'}
                ],
                'egress_rules': [
                    {'protocol': 'tcp', 'port': 3306, 'destination': 'sg-database'},
                    {'protocol': 'tcp', 'port': 6379, 'destination': 'sg-cache'},
                    {'protocol': 'tcp', 'port': 443, 'destination': '0.0.0.0/0'}
                ]
            },
            'database-sg': {
                'description': 'Security group for database servers',
                'ingress_rules': [
                    {'protocol': 'tcp', 'port': 3306, 'source': 'sg-api-servers'}
                ],
                'egress_rules': []
            }
        }
```

#### Network ACLs Configuration
```python
class NetworkACLConfiguration:
    def __init__(self):
        self.nacl_rules = {
            'public-nacl': {
                'inbound_rules': [
                    {'rule_number': 100, 'protocol': 'tcp', 'port_range': '80-80', 'source': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 110, 'protocol': 'tcp', 'port_range': '443-443', 'source': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 120, 'protocol': 'tcp', 'port_range': '1024-65535', 'source': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 130, 'protocol': 'tcp', 'port_range': '22-22', 'source': '10.0.100.0/24', 'action': 'allow'}
                ],
                'outbound_rules': [
                    {'rule_number': 100, 'protocol': 'tcp', 'port_range': '80-80', 'destination': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 110, 'protocol': 'tcp', 'port_range': '443-443', 'destination': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 120, 'protocol': 'tcp', 'port_range': '1024-65535', 'destination': '0.0.0.0/0', 'action': 'allow'}
                ]
            },
            'private-nacl': {
                'inbound_rules': [
                    {'rule_number': 100, 'protocol': 'tcp', 'port_range': '8080-8080', 'source': '10.0.0.0/16', 'action': 'allow'},
                    {'rule_number': 110, 'protocol': 'tcp', 'port_range': '1024-65535', 'source': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 120, 'protocol': 'tcp', 'port_range': '22-22', 'source': '10.0.100.0/24', 'action': 'allow'}
                ],
                'outbound_rules': [
                    {'rule_number': 100, 'protocol': 'tcp', 'port_range': '443-443', 'destination': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 110, 'protocol': 'tcp', 'port_range': '80-80', 'destination': '0.0.0.0/0', 'action': 'allow'},
                    {'rule_number': 120, 'protocol': 'tcp', 'port_range': '3306-3306', 'destination': '10.0.20.0/24', 'action': 'allow'}
                ]
            }
        }
```

## Performance Optimization

### 1. Latency Optimization
```python
class LatencyOptimization:
    def __init__(self):
        self.optimization_strategies = {
            'dns_optimization': {
                'ttl_values': {
                    'apex_domain': 300,  # 5 minutes
                    'api_endpoints': 60,  # 1 minute
                    'static_content': 3600  # 1 hour
                }
            },
            'cdn_optimization': {
                'cache_behaviors': {
                    'static_assets': {'ttl': 86400, 'compress': True},
                    'api_responses': {'ttl': 0, 'compress': False},
                    'images': {'ttl': 604800, 'compress': True}
                }
            },
            'connection_optimization': {
                'keep_alive': True,
                'connection_pooling': True,
                'http2_enabled': True
            }
        }
    
    def calculate_expected_latency(self, user_location, content_type):
        base_latencies = {
            'us-east': {'static': 20, 'dynamic': 50, 'api': 30},
            'eu-west': {'static': 15, 'dynamic': 45, 'api': 25},
            'ap-south': {'static': 25, 'dynamic': 60, 'api': 35}
        }
        
        cdn_improvement = 0.7  # 30% improvement with CDN
        optimization_factor = 0.8  # 20% improvement with optimizations
        
        base_latency = base_latencies[user_location][content_type]
        optimized_latency = base_latency * cdn_improvement * optimization_factor
        
        return {
            'base_latency_ms': base_latency,
            'optimized_latency_ms': optimized_latency,
            'improvement_percentage': ((base_latency - optimized_latency) / base_latency) * 100
        }
```

### 2. Throughput Optimization
```python
class ThroughputOptimization:
    def __init__(self):
        self.load_balancer_config = {
            'connection_draining': 300,  # seconds
            'idle_timeout': 60,  # seconds
            'cross_zone_load_balancing': True,
            'deletion_protection': True
        }
        
        self.target_group_config = {
            'deregistration_delay': 30,  # seconds
            'health_check_grace_period': 300,  # seconds
            'stickiness': {
                'enabled': True,
                'duration': 86400  # 24 hours
            }
        }
    
    def calculate_capacity_requirements(self, peak_rps, avg_response_time_ms):
        # Calculate required capacity based on Little's Law
        concurrent_requests = (peak_rps * avg_response_time_ms) / 1000
        
        # Add 50% buffer for spikes
        required_capacity = concurrent_requests * 1.5
        
        # Calculate instance requirements (assuming 100 concurrent requests per instance)
        instances_per_az = max(2, int(required_capacity / 100 / 3))  # 3 AZs
        
        return {
            'peak_rps': peak_rps,
            'concurrent_requests': concurrent_requests,
            'required_capacity': required_capacity,
            'instances_per_az': instances_per_az,
            'total_instances': instances_per_az * 3
        }
```

## Cost Analysis

### Infrastructure Cost Breakdown
```python
class CostAnalysis:
    def __init__(self):
        self.monthly_costs = {
            'compute': {
                'ec2_instances': {
                    'web_servers': {'count': 6, 'type': 't3.medium', 'cost_per_hour': 0.0416, 'hours': 730},
                    'api_servers': {'count': 6, 'type': 't3.large', 'cost_per_hour': 0.0832, 'hours': 730}
                },
                'auto_scaling': {'additional_capacity': 0.2}  # 20% additional for scaling
            },
            'networking': {
                'alb': {'count': 3, 'cost_per_hour': 0.0225, 'hours': 730},
                'nat_gateway': {'count': 3, 'cost_per_hour': 0.045, 'hours': 730},
                'data_transfer': {'gb_per_month': 10000, 'cost_per_gb': 0.09}
            },
            'dns_and_cdn': {
                'route53': {'hosted_zones': 1, 'queries_millions': 100, 'health_checks': 9},
                'cloudfront': {'requests_millions': 1000, 'data_transfer_gb': 5000}
            },
            'security': {
                'waf': {'web_acls': 3, 'rules': 20, 'requests_millions': 100},
                'certificate_manager': 0  # Free for AWS resources
            }
        }
    
    def calculate_total_monthly_cost(self):
        total_cost = 0
        cost_breakdown = {}
        
        # Compute costs
        compute_cost = 0
        for service, config in self.monthly_costs['compute']['ec2_instances'].items():
            service_cost = config['count'] * config['cost_per_hour'] * config['hours']
            compute_cost += service_cost
        
        # Add auto-scaling buffer
        compute_cost *= (1 + self.monthly_costs['compute']['auto_scaling']['additional_capacity'])
        cost_breakdown['compute'] = compute_cost
        
        # Networking costs
        networking_cost = 0
        networking_cost += 3 * 0.0225 * 730  # ALB
        networking_cost += 3 * 0.045 * 730   # NAT Gateway
        networking_cost += 10000 * 0.09      # Data transfer
        cost_breakdown['networking'] = networking_cost
        
        # DNS and CDN costs
        dns_cdn_cost = 0
        dns_cdn_cost += 0.50 * 1              # Hosted zone
        dns_cdn_cost += 0.75 * 9              # Health checks
        dns_cdn_cost += 0.40 * 100            # Route53 queries (per million)
        dns_cdn_cost += 0.0075 * 1000         # CloudFront requests (per 10,000)
        dns_cdn_cost += 0.085 * 5000          # CloudFront data transfer
        cost_breakdown['dns_cdn'] = dns_cdn_cost
        
        # Security costs
        security_cost = 0
        security_cost += 1.00 * 3             # WAF Web ACLs
        security_cost += 1.00 * 20            # WAF Rules
        security_cost += 0.60 * 100           # WAF Requests (per million)
        cost_breakdown['security'] = security_cost
        
        total_cost = sum(cost_breakdown.values())
        
        return {
            'total_monthly_cost': total_cost,
            'cost_breakdown': cost_breakdown,
            'cost_per_user': total_cost / 10000000,  # 10M users
            'annual_cost': total_cost * 12
        }
```

### Cost Optimization Strategies
```python
class CostOptimization:
    def __init__(self):
        self.optimization_strategies = {
            'reserved_instances': {
                'savings_percentage': 0.4,  # 40% savings
                'applicable_to': ['ec2_instances'],
                'commitment_years': 1
            },
            'spot_instances': {
                'savings_percentage': 0.7,  # 70% savings
                'applicable_to': ['batch_processing', 'dev_environments'],
                'availability_risk': 'medium'
            },
            'right_sizing': {
                'savings_percentage': 0.2,  # 20% savings
                'applicable_to': ['all_compute'],
                'monitoring_required': True
            },
            'data_transfer_optimization': {
                'cloudfront_savings': 0.3,  # 30% reduction in origin requests
                'compression_savings': 0.4,  # 40% bandwidth reduction
                'regional_optimization': 0.2  # 20% cross-region transfer reduction
            }
        }
    
    def calculate_optimized_costs(self, current_costs):
        optimized_costs = current_costs.copy()
        savings_summary = {}
        
        # Apply Reserved Instance savings
        ri_savings = current_costs['compute'] * self.optimization_strategies['reserved_instances']['savings_percentage']
        optimized_costs['compute'] -= ri_savings
        savings_summary['reserved_instances'] = ri_savings
        
        # Apply right-sizing savings
        rightsizing_savings = current_costs['compute'] * self.optimization_strategies['right_sizing']['savings_percentage']
        optimized_costs['compute'] -= rightsizing_savings
        savings_summary['right_sizing'] = rightsizing_savings
        
        # Apply data transfer optimizations
        dt_savings = current_costs['networking'] * 0.25  # Combined data transfer savings
        optimized_costs['networking'] -= dt_savings
        savings_summary['data_transfer'] = dt_savings
        
        total_savings = sum(savings_summary.values())
        total_optimized = sum(optimized_costs.values())
        
        return {
            'original_cost': sum(current_costs.values()),
            'optimized_cost': total_optimized,
            'total_savings': total_savings,
            'savings_percentage': (total_savings / sum(current_costs.values())) * 100,
            'savings_breakdown': savings_summary
        }
```

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-4)
```yaml
Week 1: VPC and Networking Setup
  - Create VPC with subnets across 3 AZs
  - Configure Internet Gateway and NAT Gateways
  - Set up Route Tables and Network ACLs
  - Implement Security Groups

Week 2: Load Balancing and DNS
  - Deploy Application Load Balancers
  - Configure Target Groups and Health Checks
  - Set up Route 53 hosted zones
  - Implement health checks and failover

Week 3: Content Delivery
  - Configure CloudFront distributions
  - Set up origin behaviors and caching rules
  - Implement SSL certificates
  - Test global content delivery

Week 4: Security Implementation
  - Deploy WAF rules and rate limiting
  - Configure DDoS protection
  - Implement monitoring and alerting
  - Security testing and validation
```

### Phase 2: Optimization (Weeks 5-8)
```yaml
Week 5: Performance Optimization
  - Implement connection pooling
  - Optimize cache configurations
  - Fine-tune load balancer settings
  - Performance testing and validation

Week 6: Multi-Region Deployment
  - Deploy secondary regions
  - Configure cross-region replication
  - Implement global traffic management
  - Test failover scenarios

Week 7: Monitoring and Alerting
  - Set up comprehensive monitoring
  - Configure alerting and notifications
  - Implement automated responses
  - Create operational dashboards

Week 8: Documentation and Training
  - Complete operational documentation
  - Conduct team training sessions
  - Perform final testing and validation
  - Go-live preparation
```

## Success Metrics

### Performance Metrics
- **Global Latency**: < 100ms for 95% of requests
- **Availability**: 99.99% uptime across all regions
- **Throughput**: Support 100,000 concurrent users
- **Failover Time**: < 30 seconds for regional failover

### Cost Metrics
- **Monthly Infrastructure Cost**: $15,000 (optimized from $25,000)
- **Cost per User**: $0.0015 per month
- **ROI**: 40% cost reduction through optimization
- **Scaling Efficiency**: Linear cost scaling with user growth

### Security Metrics
- **DDoS Protection**: 99.9% attack mitigation success
- **SSL/TLS**: 100% encrypted traffic
- **Compliance**: Full PCI DSS and GDPR compliance
- **Security Incidents**: Zero successful breaches

This comprehensive solution demonstrates enterprise-grade network architecture design with detailed implementation guidance, cost optimization, and measurable success criteria.
