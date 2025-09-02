# AWS Troubleshooting Guide

## Overview
Comprehensive troubleshooting guide for common AWS infrastructure and deployment issues.

## EC2 Troubleshooting

### Instance Launch Issues
```bash
# Check instance status
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 \
    --query 'Reservations[0].Instances[0].{State:State.Name,Status:StatusChecks}'

# View system logs
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Check security groups
aws ec2 describe-security-groups --group-ids sg-12345678 \
    --query 'SecurityGroups[0].IpPermissions'
```

### Common EC2 Issues

#### Instance Won't Start
**Symptoms**: Instance stuck in "pending" state
**Causes & Solutions**:
```bash
# 1. Check service limits
aws service-quotas get-service-quota \
    --service-code ec2 \
    --quota-code L-1216C47A

# 2. Verify AMI availability
aws ec2 describe-images --image-ids ami-12345678 \
    --query 'Images[0].State'

# 3. Check subnet capacity
aws ec2 describe-subnets --subnet-ids subnet-12345678 \
    --query 'Subnets[0].AvailableIpAddressCount'

# 4. Review launch template
aws ec2 describe-launch-template-versions \
    --launch-template-id lt-12345678
```

#### SSH Connection Issues
**Symptoms**: Cannot connect via SSH
**Troubleshooting Steps**:
```bash
# 1. Verify security group rules
aws ec2 describe-security-groups --group-ids sg-12345678 \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]'

# 2. Check NACLs
aws ec2 describe-network-acls \
    --filters "Name=association.subnet-id,Values=subnet-12345678" \
    --query 'NetworkAcls[0].Entries[?RuleAction==`allow` && Protocol==`6`]'

# 3. Verify key pair
aws ec2 describe-key-pairs --key-names my-key-pair

# 4. Test connectivity
telnet <instance-ip> 22
```

### Performance Issues
```bash
# Monitor CPU and memory
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 300 \
    --statistics Average,Maximum

# Check disk I/O
aws cloudwatch get-metric-statistics \
    --namespace AWS/EC2 \
    --metric-name DiskReadOps \
    --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 300 \
    --statistics Sum
```

## Load Balancer Troubleshooting

### Target Health Issues
```bash
# Check target health
aws elbv2 describe-target-health \
    --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/my-targets/1234567890123456

# Common health check failures
# 1. Security group doesn't allow health check port
# 2. Application not responding on health check path
# 3. Health check timeout too short
```

### Load Balancer Configuration
```yaml
# Troubleshooting health checks
TargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    HealthCheckPath: /health
    HealthCheckProtocol: HTTP
    HealthCheckIntervalSeconds: 30
    HealthCheckTimeoutSeconds: 5
    HealthyThresholdCount: 2
    UnhealthyThresholdCount: 3
    Matcher:
      HttpCode: 200
```

### Common ALB Issues

#### 502 Bad Gateway
**Causes & Solutions**:
```bash
# 1. Check target health
aws elbv2 describe-target-health --target-group-arn <arn>

# 2. Verify security groups allow ALB to reach targets
aws ec2 describe-security-groups --group-ids sg-target-group \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`80`]'

# 3. Check application logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/myapp/application.log

# 4. Test direct connection to target
curl -v http://<target-ip>:80/health
```

#### SSL Certificate Issues
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn <certificate-arn>

# Verify domain validation
aws acm list-certificates --certificate-statuses ISSUED,PENDING_VALIDATION

# Check Route53 records for validation
aws route53 list-resource-record-sets --hosted-zone-id <zone-id> \
    --query 'ResourceRecordSets[?Type==`CNAME`]'
```

## RDS Troubleshooting

### Connection Issues
```bash
# Test database connectivity
telnet <rds-endpoint> 5432

# Check security groups
aws rds describe-db-instances --db-instance-identifier my-db \
    --query 'DBInstances[0].VpcSecurityGroups'

# Verify parameter group
aws rds describe-db-parameters \
    --db-parameter-group-name my-db-params \
    --query 'Parameters[?ParameterName==`max_connections`]'
```

### Performance Issues
```python
# Database connection testing script
import psycopg2
import time
import sys

def test_db_connection():
    try:
        # Test connection
        conn = psycopg2.connect(
            host="your-rds-endpoint.amazonaws.com",
            database="myapp",
            user="dbuser",
            password="password",
            port=5432,
            connect_timeout=10
        )
        
        # Test query performance
        cur = conn.cursor()
        start_time = time.time()
        cur.execute("SELECT 1")
        query_time = time.time() - start_time
        
        print(f"Connection successful. Query time: {query_time:.3f}s")
        
        # Check active connections
        cur.execute("""
            SELECT count(*) as active_connections 
            FROM pg_stat_activity 
            WHERE state = 'active'
        """)
        active_conn = cur.fetchone()[0]
        print(f"Active connections: {active_conn}")
        
        conn.close()
        return True
        
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False

if __name__ == "__main__":
    test_db_connection()
```

### Common RDS Issues

#### High CPU Usage
```sql
-- Find slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

-- Check for blocking queries
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS current_statement_in_blocking_process
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

## VPC and Networking

### Connectivity Issues
```bash
# Check route tables
aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=vpc-12345678" \
    --query 'RouteTables[*].{RouteTableId:RouteTableId,Routes:Routes}'

# Verify NAT Gateway
aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=vpc-12345678" \
    --query 'NatGateways[*].{NatGatewayId:NatGatewayId,State:State,SubnetId:SubnetId}'

# Check Internet Gateway
aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=vpc-12345678"
```

### Network Troubleshooting Script
```bash
#!/bin/bash
# network-debug.sh

VPC_ID="vpc-12345678"
INSTANCE_ID="i-1234567890abcdef0"

echo "=== VPC Network Troubleshooting ==="

# Get instance details
echo "1. Instance Details:"
aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].{SubnetId:SubnetId,SecurityGroups:SecurityGroups,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress}'

# Check security groups
echo "2. Security Group Rules:"
SG_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)
aws ec2 describe-security-groups --group-ids $SG_ID

# Check subnet route table
echo "3. Route Table:"
SUBNET_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].SubnetId' --output text)
aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
    --query 'RouteTables[0].Routes'

# Check NACLs
echo "4. Network ACLs:"
aws ec2 describe-network-acls \
    --filters "Name=association.subnet-id,Values=$SUBNET_ID" \
    --query 'NetworkAcls[0].Entries'

echo "=== Troubleshooting Complete ==="
```

## S3 and CloudFront Issues

### S3 Access Issues
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket my-app-bucket

# Verify public access block
aws s3api get-public-access-block --bucket my-app-bucket

# Test object access
aws s3api head-object --bucket my-app-bucket --key index.html

# Check CORS configuration
aws s3api get-bucket-cors --bucket my-app-bucket
```

### CloudFront Troubleshooting
```bash
# Check distribution status
aws cloudfront get-distribution --id E1234567890123

# View cache statistics
aws cloudfront get-distribution-config --id E1234567890123 \
    --query 'DistributionConfig.DefaultCacheBehavior'

# Create invalidation
aws cloudfront create-invalidation \
    --distribution-id E1234567890123 \
    --paths "/*"

# Check origin access identity
aws cloudfront list-cloud-front-origin-access-identities
```

## Auto Scaling Issues

### Scaling Problems
```bash
# Check scaling activities
aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name my-app-asg \
    --max-items 10

# View scaling policies
aws autoscaling describe-policies \
    --auto-scaling-group-name my-app-asg

# Check CloudWatch alarms
aws cloudwatch describe-alarms \
    --alarm-names "my-app-cpu-high"

# Manual scaling test
aws autoscaling set-desired-capacity \
    --auto-scaling-group-name my-app-asg \
    --desired-capacity 3
```

## IAM and Security Issues

### Permission Troubleshooting
```bash
# Simulate policy
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::123456789012:role/MyRole \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::my-bucket/file.txt

# Check role trust policy
aws iam get-role --role-name MyRole \
    --query 'Role.AssumeRolePolicyDocument'

# View attached policies
aws iam list-attached-role-policies --role-name MyRole
aws iam list-role-policies --role-name MyRole
```

### Security Group Analysis
```python
#!/usr/bin/env python3
import boto3
import json

def analyze_security_groups():
    ec2 = boto3.client('ec2')
    
    # Get all security groups
    response = ec2.describe_security_groups()
    
    risky_rules = []
    
    for sg in response['SecurityGroups']:
        sg_id = sg['GroupId']
        sg_name = sg['GroupName']
        
        # Check for overly permissive rules
        for rule in sg['IpPermissions']:
            for ip_range in rule.get('IpRanges', []):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    risky_rules.append({
                        'SecurityGroupId': sg_id,
                        'SecurityGroupName': sg_name,
                        'Protocol': rule.get('IpProtocol'),
                        'FromPort': rule.get('FromPort'),
                        'ToPort': rule.get('ToPort'),
                        'Risk': 'Open to internet'
                    })
    
    return risky_rules

if __name__ == "__main__":
    risks = analyze_security_groups()
    print(json.dumps(risks, indent=2))
```

## Monitoring and Alerting Issues

### CloudWatch Troubleshooting
```bash
# Check metric availability
aws cloudwatch list-metrics \
    --namespace AWS/EC2 \
    --metric-name CPUUtilization

# Test alarm
aws cloudwatch set-alarm-state \
    --alarm-name "my-app-cpu-high" \
    --state-value ALARM \
    --state-reason "Testing alarm"

# View alarm history
aws cloudwatch describe-alarm-history \
    --alarm-name "my-app-cpu-high" \
    --max-records 5
```

### Log Analysis Script
```python
#!/usr/bin/env python3
import boto3
from datetime import datetime, timedelta

def analyze_logs():
    logs = boto3.client('logs')
    
    # Query recent errors
    query = """
    fields @timestamp, @message
    | filter @message like /ERROR/
    | stats count() by bin(5m)
    | sort @timestamp desc
    """
    
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(hours=1)
    
    response = logs.start_query(
        logGroupName='/aws/ec2/myapp/application',
        startTime=int(start_time.timestamp()),
        endTime=int(end_time.timestamp()),
        queryString=query
    )
    
    query_id = response['queryId']
    
    # Wait for query completion
    import time
    while True:
        result = logs.get_query_results(queryId=query_id)
        if result['status'] == 'Complete':
            break
        time.sleep(1)
    
    return result['results']

if __name__ == "__main__":
    results = analyze_logs()
    for result in results:
        print(result)
```

## Disaster Recovery Testing

### Backup Verification
```bash
#!/bin/bash
# verify-backups.sh

echo "=== Backup Verification ==="

# Check RDS snapshots
echo "1. RDS Snapshots:"
aws rds describe-db-snapshots \
    --db-instance-identifier my-app-db \
    --snapshot-type manual \
    --query 'DBSnapshots[0:3].{SnapshotId:DBSnapshotIdentifier,Status:Status,Created:SnapshotCreateTime}'

# Check S3 backup objects
echo "2. S3 Backups:"
aws s3 ls s3://my-app-backups/ --recursive --human-readable

# Verify EBS snapshots
echo "3. EBS Snapshots:"
aws ec2 describe-snapshots \
    --owner-ids self \
    --query 'Snapshots[0:3].{SnapshotId:SnapshotId,State:State,StartTime:StartTime}'

echo "=== Verification Complete ==="
```

### Recovery Testing
```bash
#!/bin/bash
# test-recovery.sh

# Test RDS restore
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier test-restore-db \
    --db-snapshot-identifier my-app-db-snapshot-20240101 \
    --db-instance-class db.t3.micro \
    --no-multi-az \
    --no-publicly-accessible

# Test EC2 restore from snapshot
aws ec2 create-image \
    --instance-id i-1234567890abcdef0 \
    --name "test-recovery-$(date +%Y%m%d)" \
    --description "Recovery test image"

echo "Recovery test initiated. Monitor AWS console for completion."
```

## Performance Optimization

### Resource Utilization Analysis
```python
#!/usr/bin/env python3
import boto3
from datetime import datetime, timedelta

def analyze_resource_utilization():
    cloudwatch = boto3.client('cloudwatch')
    
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=7)
    
    metrics = [
        ('AWS/EC2', 'CPUUtilization'),
        ('AWS/RDS', 'CPUUtilization'),
        ('AWS/ApplicationELB', 'RequestCount')
    ]
    
    results = {}
    
    for namespace, metric_name in metrics:
        response = cloudwatch.get_metric_statistics(
            Namespace=namespace,
            MetricName=metric_name,
            StartTime=start_time,
            EndTime=end_time,
            Period=3600,
            Statistics=['Average', 'Maximum']
        )
        
        if response['Datapoints']:
            avg_utilization = sum(dp['Average'] for dp in response['Datapoints']) / len(response['Datapoints'])
            max_utilization = max(dp['Maximum'] for dp in response['Datapoints'])
            
            results[f"{namespace}/{metric_name}"] = {
                'average': avg_utilization,
                'maximum': max_utilization
            }
    
    return results

if __name__ == "__main__":
    utilization = analyze_resource_utilization()
    for metric, stats in utilization.items():
        print(f"{metric}: Avg={stats['average']:.2f}, Max={stats['maximum']:.2f}")
```

## Emergency Response Procedures

### Incident Response Checklist
1. **Immediate Actions**
   - Assess impact and scope
   - Notify stakeholders
   - Implement temporary fixes

2. **Investigation**
   - Collect logs and metrics
   - Identify root cause
   - Document findings

3. **Resolution**
   - Implement permanent fix
   - Test thoroughly
   - Monitor for recurrence

4. **Post-Incident**
   - Conduct retrospective
   - Update procedures
   - Implement preventive measures

### Emergency Scripts
```bash
#!/bin/bash
# emergency-response.sh

case "$1" in
    "scale-up")
        aws autoscaling set-desired-capacity \
            --auto-scaling-group-name my-app-asg \
            --desired-capacity 10
        ;;
    "isolate-instance")
        aws ec2 modify-instance-attribute \
            --instance-id "$2" \
            --groups sg-isolation
        ;;
    "failover-db")
        aws rds reboot-db-instance \
            --db-instance-identifier my-app-db \
            --force-failover
        ;;
    *)
        echo "Usage: $0 {scale-up|isolate-instance|failover-db}"
        exit 1
        ;;
esac
```
