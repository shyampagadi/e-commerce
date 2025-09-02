# Load Balancers and Auto Scaling

## Overview
Learn to implement AWS load balancing and auto-scaling for high availability and performance.

## Application Load Balancer (ALB)

### Creating an ALB
```bash
# Create ALB
aws elbv2 create-load-balancer \
    --name my-app-alb \
    --subnets subnet-12345678 subnet-87654321 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4

# Create target group
aws elbv2 create-target-group \
    --name my-app-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3
```

### ALB Configuration
```yaml
# alb-config.yml
Resources:
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: MyAppALB
      Scheme: internet-facing
      Type: application
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref ALBSecurityGroup
      
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: MyAppTargets
      Port: 80
      Protocol: HTTP
      VpcId: !Ref VPC
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      
  Listener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP
```

## Auto Scaling Groups

### Launch Template
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name my-app-template \
    --launch-template-data '{
        "ImageId": "ami-0abcdef1234567890",
        "InstanceType": "t3.micro",
        "KeyName": "my-key-pair",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "'$(base64 -w 0 user-data.sh)'",
        "IamInstanceProfile": {
            "Name": "EC2-SSM-Role"
        },
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [
                {"Key": "Name", "Value": "AutoScaled-Instance"},
                {"Key": "Environment", "Value": "Production"}
            ]
        }]
    }'
```

### Auto Scaling Group
```bash
# Create auto scaling group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-app-asg \
    --launch-template LaunchTemplateName=my-app-template,Version='$Latest' \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 3 \
    --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/my-app-targets/1234567890123456 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --default-cooldown 300
```

### Scaling Policies
```bash
# Scale up policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-asg \
    --policy-name scale-up-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

# Scale down policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-app-asg \
    --policy-name scale-down-policy \
    --policy-type StepScaling \
    --adjustment-type ChangeInCapacity \
    --step-adjustments MetricIntervalLowerBound=0,ScalingAdjustment=-1 \
    --cooldown 300
```

## Network Load Balancer (NLB)

### NLB for High Performance
```yaml
NetworkLoadBalancer:
  Type: AWS::ElasticLoadBalancingV2::LoadBalancer
  Properties:
    Name: MyAppNLB
    Scheme: internet-facing
    Type: network
    Subnets:
      - !Ref PublicSubnet1
      - !Ref PublicSubnet2
    
NLBTargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: MyAppNLBTargets
    Port: 80
    Protocol: TCP
    VpcId: !Ref VPC
    HealthCheckProtocol: HTTP
    HealthCheckPath: /health
    HealthCheckIntervalSeconds: 10
    HealthyThresholdCount: 2
    UnhealthyThresholdCount: 2
```

## CloudWatch Monitoring

### Custom Metrics
```bash
# Put custom metric
aws cloudwatch put-metric-data \
    --namespace "MyApp/Performance" \
    --metric-data MetricName=ResponseTime,Value=250,Unit=Milliseconds,Timestamp=$(date -u +%Y-%m-%dT%H:%M:%S)
```

### Alarms
```yaml
HighCPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: HighCPUUtilization
    AlarmDescription: Alarm when CPU exceeds 80%
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopic
```

## Best Practices

### Health Checks
- Configure appropriate health check paths
- Set reasonable timeout and interval values
- Use different health checks for different services

### Scaling Strategies
- Use target tracking for predictable workloads
- Implement step scaling for rapid changes
- Set appropriate cooldown periods

### Security
- Use security groups to restrict access
- Enable access logs for load balancers
- Implement SSL/TLS termination at load balancer

## Troubleshooting

### Common Issues
1. **Unhealthy targets**: Check security groups and health check configuration
2. **Scaling delays**: Review cooldown periods and scaling policies
3. **Connection timeouts**: Verify network ACLs and routing

### Monitoring Commands
```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:region:account:targetgroup/my-app-targets/1234567890123456

# View scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name my-app-asg

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value=app/my-app-alb/1234567890123456 \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 3600 \
    --statistics Sum
```
