# Network Troubleshooting Guide

## Common Network Issues & Solutions

### 1. High Latency Issues

#### Symptoms
- Response times > 500ms
- Timeouts on API calls
- Poor user experience

#### Diagnostic Commands
```bash
# Test latency to specific endpoints
ping api.example.com
traceroute api.example.com
curl -w "@curl-format.txt" https://api.example.com/health

# AWS-specific diagnostics
aws ec2 describe-vpc-peering-connections
aws logs filter-log-events --log-group-name /aws/apigateway/access-logs
```

#### Solutions
1. **Enable CloudFront CDN**
   ```bash
   aws cloudfront create-distribution --distribution-config file://cdn-config.json
   ```

2. **Optimize Load Balancer**
   ```bash
   # Enable connection draining
   aws elbv2 modify-target-group-attributes --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/name/id --attributes Key=deregistration_delay.timeout_seconds,Value=30
   ```

### 2. Connection Timeouts

#### Symptoms
- 504 Gateway Timeout errors
- Connection refused errors
- Intermittent connectivity

#### Diagnostic Steps
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678

# Verify NACL rules
aws ec2 describe-network-acls --network-acl-ids acl-12345678

# Test connectivity
telnet target-host 80
nmap -p 80,443 target-host
```

#### Solutions
1. **Fix Security Group Rules**
   ```bash
   aws ec2 authorize-security-group-ingress --group-id sg-12345678 --protocol tcp --port 80 --cidr 0.0.0.0/0
   ```

2. **Adjust Load Balancer Timeouts**
   ```bash
   aws elbv2 modify-load-balancer-attributes --load-balancer-arn arn:aws:elasticloadbalancing:region:account:loadbalancer/app/name/id --attributes Key=idle_timeout.timeout_seconds,Value=60
   ```

### 3. DNS Resolution Issues

#### Symptoms
- Domain not resolving
- Intermittent DNS failures
- Wrong IP addresses returned

#### Diagnostic Commands
```bash
# Test DNS resolution
nslookup example.com
dig example.com
host example.com

# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id Z123456789
```

#### Solutions
1. **Fix Route 53 Records**
   ```bash
   aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch file://dns-change.json
   ```

2. **Implement Health Checks**
   ```bash
   aws route53 create-health-check --caller-reference unique-string --health-check-config file://health-check.json
   ```

## Performance Optimization Scenarios

### Scenario 1: API Gateway Latency
**Problem**: API Gateway responses taking 2+ seconds

**Investigation**:
```bash
# Check API Gateway metrics
aws logs filter-log-events --log-group-name API-Gateway-Execution-Logs_abcdef123/prod --filter-pattern "Duration"

# Analyze X-Ray traces
aws xray get-trace-summaries --time-range-type TimeRangeByStartTime --start-time 2023-01-01T00:00:00 --end-time 2023-01-01T23:59:59
```

**Solutions**:
1. Enable caching
2. Optimize Lambda cold starts
3. Use VPC endpoints for AWS services

### Scenario 2: Load Balancer Bottleneck
**Problem**: Load balancer becoming bottleneck at 10k RPS

**Investigation**:
```bash
# Check ALB metrics
aws cloudwatch get-metric-statistics --namespace AWS/ApplicationELB --metric-name RequestCount --dimensions Name=LoadBalancer,Value=app/my-lb/1234567890123456 --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T01:00:00Z --period 300 --statistics Sum
```

**Solutions**:
1. Scale to multiple AZs
2. Use Network Load Balancer for TCP traffic
3. Implement connection pooling

## Interactive Troubleshooting Flowchart

```
Network Issue Detected
         |
    Is it DNS?
    /        \
  Yes         No
   |           |
Fix DNS    Check Connectivity
Records         |
              Can connect?
              /         \
            Yes          No
             |            |
        Check Latency  Fix Security
             |         Groups/NACLs
        High Latency?      |
        /          \       |
      Yes           No     |
       |            |     |
   Optimize      Check    |
   Network       App      |
   Path         Logic     |
                          |
                    Test Again
```

## Monitoring Setup

### Essential CloudWatch Alarms
```bash
# High latency alarm
aws cloudwatch put-metric-alarm --alarm-name "High-API-Latency" --alarm-description "API latency too high" --metric-name Duration --namespace AWS/ApiGateway --statistic Average --period 300 --threshold 1000 --comparison-operator GreaterThanThreshold

# Connection errors alarm
aws cloudwatch put-metric-alarm --alarm-name "High-4XX-Errors" --alarm-description "Too many 4XX errors" --metric-name 4XXError --namespace AWS/ApiGateway --statistic Sum --period 300 --threshold 10 --comparison-operator GreaterThanThreshold
```

### VPC Flow Logs Analysis
```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs --resource-type VPC --resource-ids vpc-12345678 --traffic-type ALL --log-destination-type cloud-watch-logs --log-group-name VPCFlowLogs

# Query flow logs for troubleshooting
aws logs filter-log-events --log-group-name VPCFlowLogs --filter-pattern "[version, account, eni, source, destination, srcport, destport=\"80\", protocol=\"6\", packets, bytes, windowstart, windowend, action=\"REJECT\"]"
```
