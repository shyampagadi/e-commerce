# AWS Cost Optimization

## Overview
Strategies and tools for optimizing AWS costs while maintaining performance and reliability.

## Cost Analysis Tools

### AWS Cost Explorer
```bash
# Get cost and usage data
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

# Get rightsizing recommendations
aws ce get-rightsizing-recommendation \
    --service EC2-Instance \
    --configuration RecommendationTarget=SAME_INSTANCE_FAMILY
```

### Cost Budgets
```yaml
CostBudget:
  Type: AWS::Budgets::Budget
  Properties:
    Budget:
      BudgetName: Monthly-AWS-Budget
      BudgetLimit:
        Amount: 1000
        Unit: USD
      TimeUnit: MONTHLY
      BudgetType: COST
      CostFilters:
        Service:
          - Amazon Elastic Compute Cloud - Compute
          - Amazon Relational Database Service
    NotificationsWithSubscribers:
      - Notification:
          NotificationType: ACTUAL
          ComparisonOperator: GREATER_THAN
          Threshold: 80
        Subscribers:
          - SubscriptionType: EMAIL
            Address: admin@company.com
```

## EC2 Cost Optimization

### Instance Right-Sizing
```python
import boto3
from datetime import datetime, timedelta

def analyze_ec2_utilization():
    cloudwatch = boto3.client('cloudwatch')
    ec2 = boto3.client('ec2')
    
    # Get all running instances
    instances = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    
    recommendations = []
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            instance_type = instance['InstanceType']
            
            # Get CPU utilization for last 30 days
            end_time = datetime.utcnow()
            start_time = end_time - timedelta(days=30)
            
            cpu_metrics = cloudwatch.get_metric_statistics(
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=3600,
                Statistics=['Average']
            )
            
            if cpu_metrics['Datapoints']:
                avg_cpu = sum(dp['Average'] for dp in cpu_metrics['Datapoints']) / len(cpu_metrics['Datapoints'])
                
                if avg_cpu < 10:
                    recommendations.append({
                        'instance_id': instance_id,
                        'current_type': instance_type,
                        'avg_cpu': avg_cpu,
                        'recommendation': 'Consider downsizing or terminating'
                    })
    
    return recommendations
```

### Reserved Instances
```bash
# Purchase Reserved Instance
aws ec2 purchase-reserved-instances-offering \
    --reserved-instances-offering-id 12345678-1234-1234-1234-123456789012 \
    --instance-count 2

# Modify Reserved Instance
aws ec2 modify-reserved-instances \
    --reserved-instances-ids 12345678-1234-1234-1234-123456789012 \
    --target-configurations AvailabilityZone=us-east-1a,InstanceCount=1,InstanceType=t3.medium
```

### Spot Instances
```yaml
SpotFleetRequest:
  Type: AWS::EC2::SpotFleet
  Properties:
    SpotFleetRequestConfigData:
      IamFleetRole: !GetAtt SpotFleetRole.Arn
      AllocationStrategy: diversified
      TargetCapacity: 4
      SpotPrice: 0.05
      LaunchSpecifications:
        - ImageId: ami-12345678
          InstanceType: t3.medium
          KeyName: my-key
          SecurityGroups:
            - GroupId: !Ref SecurityGroup
          SubnetId: !Ref Subnet1
        - ImageId: ami-12345678
          InstanceType: t3.large
          KeyName: my-key
          SecurityGroups:
            - GroupId: !Ref SecurityGroup
          SubnetId: !Ref Subnet2
```

## Storage Cost Optimization

### S3 Lifecycle Policies
```json
{
    "Rules": [
        {
            "ID": "CostOptimization",
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                },
                {
                    "Days": 365,
                    "StorageClass": "DEEP_ARCHIVE"
                }
            ],
            "AbortIncompleteMultipartUpload": {
                "DaysAfterInitiation": 7
            }
        }
    ]
}
```

### EBS Optimization
```bash
# Find unattached volumes
aws ec2 describe-volumes \
    --filters Name=status,Values=available \
    --query 'Volumes[*].{VolumeId:VolumeId,Size:Size,VolumeType:VolumeType}'

# Modify volume type for cost savings
aws ec2 modify-volume \
    --volume-id vol-12345678 \
    --volume-type gp3 \
    --size 100 \
    --iops 3000
```

## Database Cost Optimization

### RDS Right-Sizing
```python
def analyze_rds_utilization():
    rds = boto3.client('rds')
    cloudwatch = boto3.client('cloudwatch')
    
    instances = rds.describe_db_instances()
    
    for db in instances['DBInstances']:
        db_id = db['DBInstanceIdentifier']
        
        # Get CPU and connection metrics
        cpu_metrics = cloudwatch.get_metric_statistics(
            Namespace='AWS/RDS',
            MetricName='CPUUtilization',
            Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_id}],
            StartTime=datetime.utcnow() - timedelta(days=30),
            EndTime=datetime.utcnow(),
            Period=3600,
            Statistics=['Average']
        )
        
        conn_metrics = cloudwatch.get_metric_statistics(
            Namespace='AWS/RDS',
            MetricName='DatabaseConnections',
            Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_id}],
            StartTime=datetime.utcnow() - timedelta(days=30),
            EndTime=datetime.utcnow(),
            Period=3600,
            Statistics=['Average']
        )
        
        if cpu_metrics['Datapoints'] and conn_metrics['Datapoints']:
            avg_cpu = sum(dp['Average'] for dp in cpu_metrics['Datapoints']) / len(cpu_metrics['Datapoints'])
            avg_conn = sum(dp['Average'] for dp in conn_metrics['Datapoints']) / len(conn_metrics['Datapoints'])
            
            print(f"DB: {db_id}, CPU: {avg_cpu:.2f}%, Connections: {avg_conn:.0f}")
```

### Aurora Serverless
```yaml
AuroraServerlessCluster:
  Type: AWS::RDS::DBCluster
  Properties:
    Engine: aurora-mysql
    EngineMode: serverless
    ScalingConfiguration:
      AutoPause: true
      MinCapacity: 1
      MaxCapacity: 16
      SecondsUntilAutoPause: 300
    DatabaseName: myapp
    MasterUsername: admin
    MasterUserPassword: !Ref DBPassword
```

## Auto Scaling for Cost Control

### Predictive Scaling
```yaml
PredictiveScalingPolicy:
  Type: AWS::AutoScaling::ScalingPolicy
  Properties:
    AutoScalingGroupName: !Ref AutoScalingGroup
    PolicyType: PredictiveScaling
    PredictiveScalingConfiguration:
      MetricSpecifications:
        - TargetValue: 70
          PredefinedMetricSpecification:
            PredefinedMetricType: ASGAverageCPUUtilization
      Mode: ForecastAndScale
      SchedulingBufferTime: 300
      MaxCapacityBreachBehavior: HonorMaxCapacity
```

### Scheduled Scaling
```bash
# Scale down during off-hours
aws autoscaling put-scheduled-update-group-action \
    --auto-scaling-group-name my-asg \
    --scheduled-action-name scale-down-evening \
    --recurrence "0 18 * * MON-FRI" \
    --desired-capacity 1 \
    --min-size 1 \
    --max-size 3

# Scale up during business hours
aws autoscaling put-scheduled-update-group-action \
    --auto-scaling-group-name my-asg \
    --scheduled-action-name scale-up-morning \
    --recurrence "0 8 * * MON-FRI" \
    --desired-capacity 3 \
    --min-size 2 \
    --max-size 10
```

## Monitoring and Alerting

### Cost Anomaly Detection
```yaml
CostAnomalyDetector:
  Type: AWS::CE::AnomalyDetector
  Properties:
    AnomalyDetectorName: MyApp-Cost-Anomaly
    MonitorType: DIMENSIONAL
    MonitorSpecification: |
      {
        "Dimension": "SERVICE",
        "Key": "EC2-Instance",
        "Values": ["EC2-Instance"],
        "MatchOptions": ["EQUALS"]
      }

CostAnomalySubscription:
  Type: AWS::CE::AnomalySubscription
  Properties:
    SubscriptionName: MyApp-Cost-Alerts
    MonitorArnList:
      - !GetAtt CostAnomalyDetector.AnomalyDetectorArn
    Subscribers:
      - Type: EMAIL
        Address: finance@company.com
    Threshold: 100
```

### Custom Cost Metrics
```python
import boto3
from datetime import datetime, timedelta

def publish_cost_metrics():
    ce = boto3.client('ce')
    cloudwatch = boto3.client('cloudwatch')
    
    # Get yesterday's costs
    end_date = datetime.now().strftime('%Y-%m-%d')
    start_date = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    
    response = ce.get_cost_and_usage(
        TimePeriod={'Start': start_date, 'End': end_date},
        Granularity='DAILY',
        Metrics=['BlendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )
    
    for result in response['ResultsByTime']:
        for group in result['Groups']:
            service = group['Keys'][0]
            cost = float(group['Metrics']['BlendedCost']['Amount'])
            
            cloudwatch.put_metric_data(
                Namespace='AWS/Billing',
                MetricData=[{
                    'MetricName': 'DailyCost',
                    'Value': cost,
                    'Unit': 'None',
                    'Dimensions': [{'Name': 'Service', 'Value': service}]
                }]
            )
```

## Best Practices

### Tagging Strategy
```yaml
# Consistent tagging for cost allocation
Tags:
  - Key: Environment
    Value: !Ref Environment
  - Key: Project
    Value: MyApp
  - Key: Owner
    Value: DevOps
  - Key: CostCenter
    Value: Engineering
  - Key: AutoShutdown
    Value: "true"
```

### Resource Cleanup
```bash
#!/bin/bash
# cleanup-unused-resources.sh

# Delete unused EBS volumes
aws ec2 describe-volumes --filters Name=status,Values=available \
    --query 'Volumes[*].VolumeId' --output text | \
    xargs -I {} aws ec2 delete-volume --volume-id {}

# Delete unused snapshots older than 30 days
aws ec2 describe-snapshots --owner-ids self \
    --query "Snapshots[?StartTime<='$(date -d '30 days ago' --iso-8601)'].SnapshotId" \
    --output text | xargs -I {} aws ec2 delete-snapshot --snapshot-id {}

# Delete unused security groups
aws ec2 describe-security-groups \
    --query 'SecurityGroups[?GroupName!=`default`].[GroupId,GroupName]' \
    --output text | while read sg_id sg_name; do
    if ! aws ec2 describe-instances --filters Name=instance.group-id,Values=$sg_id \
        --query 'Reservations[*].Instances[*].InstanceId' --output text | grep -q .; then
        echo "Deleting unused security group: $sg_name ($sg_id)"
        aws ec2 delete-security-group --group-id $sg_id
    fi
done
```
