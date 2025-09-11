# Enhanced Decision Trees and Failure Scenarios

## Compute Service Selection Decision Tree

```
Start: Need Compute Resources
│
├─ Workload Characteristics?
│  │
│  ├─ Event-driven, short-duration (<15 min)
│  │  │
│  │  ├─ Predictable traffic patterns?
│  │  │  ├─ Yes → Consider Provisioned Concurrency Lambda
│  │  │  └─ No → Standard Lambda
│  │  │
│  │  └─ Need custom runtime/libraries?
│  │     ├─ Yes → Container Lambda or Fargate
│  │     └─ No → Standard Lambda
│  │
│  ├─ Long-running services (>15 min)
│  │  │
│  │  ├─ Containerized application?
│  │  │  │
│  │  │  ├─ Need Kubernetes features?
│  │  │  │  ├─ Yes → EKS
│  │  │  │  └─ No → ECS Fargate
│  │  │  │
│  │  │  └─ Want infrastructure control?
│  │  │     ├─ Yes → ECS on EC2
│  │  │     └─ No → ECS Fargate
│  │  │
│  │  └─ Traditional application?
│  │     │
│  │     ├─ Predictable workload?
│  │     │  ├─ Yes → Reserved Instances
│  │     │  └─ No → On-Demand + Auto Scaling
│  │     │
│  │     └─ Fault-tolerant batch jobs?
│  │        ├─ Yes → Spot Instances
│  │        └─ No → On-Demand Instances
│  │
│  └─ Batch processing
│     │
│     ├─ Duration < 15 minutes?
│     │  ├─ Yes → Lambda
│     │  └─ No → AWS Batch with Spot
│     │
│     └─ Need GPU/specialized hardware?
│        ├─ Yes → EC2 with specific instance types
│        └─ No → AWS Batch
```

## Cost Optimization Decision Matrix

| Scenario | Traffic Pattern | Recommended Solution | Cost Savings | Trade-offs |
|----------|----------------|---------------------|--------------|------------|
| **Web API** | Predictable 24/7 | Reserved Instances + ALB | 60-75% | 1-3 year commitment |
| **Web API** | Variable traffic | Auto Scaling + Spot | 40-60% | Potential interruptions |
| **Web API** | Sporadic usage | Lambda + API Gateway | 80-95% | Cold start latency |
| **Batch Jobs** | Scheduled daily | Spot Instances | 70-90% | Job interruption risk |
| **Batch Jobs** | Event-triggered | Lambda (if <15min) | 85-95% | Runtime limitations |
| **Microservices** | Mixed patterns | ECS Fargate + Spot | 50-70% | Complexity increase |

## Failure Scenarios and Recovery Strategies

### Scenario 1: Auto Scaling Group Failure
**Failure Mode**: ASG fails to scale out during traffic spike

#### Root Cause Analysis Tree
```
ASG Not Scaling
│
├─ CloudWatch Metrics Issue?
│  ├─ Metrics not being published
│  │  └─ Solution: Check CloudWatch agent, custom metrics
│  └─ Incorrect metric thresholds
│     └─ Solution: Adjust scaling policies
│
├─ Launch Template Issue?
│  ├─ AMI not available
│  │  └─ Solution: Update launch template with valid AMI
│  ├─ Security group blocking traffic
│  │  └─ Solution: Fix security group rules
│  └─ Instance type not available
│     └─ Solution: Add multiple instance types
│
├─ Service Limits Reached?
│  ├─ EC2 instance limit
│  │  └─ Solution: Request limit increase
│  └─ EIP limit reached
│     └─ Solution: Use NAT Gateway instead
│
└─ Subnet Capacity?
   ├─ No available IP addresses
   │  └─ Solution: Add more subnets
   └─ AZ capacity constraints
      └─ Solution: Distribute across more AZs
```

#### Recovery Playbook
```bash
# 1. Immediate Response (0-5 minutes)
# Check current ASG status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names my-asg

# Check scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name my-asg --max-items 10

# 2. Quick Fix (5-15 minutes)
# Manually increase desired capacity
aws autoscaling set-desired-capacity --auto-scaling-group-name my-asg --desired-capacity 10 --honor-cooldown

# 3. Root Cause Analysis (15-30 minutes)
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=AutoScalingGroupName,Value=my-asg --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T01:00:00Z --period 300 --statistics Average

# Check service limits
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A
```

### Scenario 2: Lambda Cold Start Performance Issues
**Failure Mode**: API response times exceed SLA due to cold starts

#### Performance Analysis Framework
```javascript
// Cold start monitoring
const coldStartMetrics = {
    measureColdStart: function(event, context) {
        const start = Date.now();
        const isWarmStart = global.isWarm;
        global.isWarm = true;
        
        return {
            isColdStart: !isWarmStart,
            initDuration: context.getRemainingTimeInMillis(),
            timestamp: start
        };
    },
    
    optimizationStrategies: {
        provisionedConcurrency: {
            when: "Predictable traffic patterns",
            cost: "Higher base cost",
            benefit: "Eliminates cold starts"
        },
        connectionPooling: {
            when: "Database connections",
            implementation: "Reuse connections across invocations",
            benefit: "Faster subsequent calls"
        },
        codeOptimization: {
            when: "Large dependencies",
            implementation: "Lazy loading, smaller packages",
            benefit: "Faster initialization"
        }
    }
};
```

#### Mitigation Strategies
```yaml
# CloudFormation template for optimized Lambda
Resources:
  OptimizedLambda:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: nodejs18.x
      MemorySize: 1024  # Higher memory = faster CPU
      ReservedConcurrencyConfiguration:
        ReservedConcurrency: 100
      ProvisionedConcurrencyConfig:
        ProvisionedConcurrency: 10  # For predictable workloads
      Environment:
        Variables:
          NODE_OPTIONS: "--enable-source-maps"
```

### Scenario 3: ECS Service Deployment Failure
**Failure Mode**: New task definition fails to deploy

#### Deployment Failure Decision Tree
```
ECS Deployment Failed
│
├─ Task Definition Issues?
│  ├─ Invalid container image
│  │  └─ Check ECR repository and image tags
│  ├─ Insufficient memory/CPU
│  │  └─ Increase task resources
│  └─ Missing environment variables
│     └─ Update task definition
│
├─ Service Configuration?
│  ├─ Target group health checks failing
│  │  └─ Fix health check endpoint
│  ├─ Security group blocking traffic
│  │  └─ Update security group rules
│  └─ Subnet has no available IPs
│     └─ Add more subnets or increase CIDR
│
└─ Cluster Capacity?
   ├─ Insufficient cluster capacity
   │  └─ Scale cluster or use Fargate
   └─ Service limits reached
      └─ Request limit increase
```

#### Automated Recovery Script
```bash
#!/bin/bash
# ECS deployment recovery script

SERVICE_NAME="my-service"
CLUSTER_NAME="my-cluster"

# Check service status
SERVICE_STATUS=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --query 'services[0].deployments[0].status' --output text)

if [ "$SERVICE_STATUS" != "PRIMARY" ]; then
    echo "Deployment failed, initiating rollback..."
    
    # Get previous stable task definition
    PREVIOUS_TASK_DEF=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --query 'services[0].deployments[1].taskDefinition' --output text)
    
    # Rollback to previous version
    aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $PREVIOUS_TASK_DEF
    
    echo "Rollback initiated to $PREVIOUS_TASK_DEF"
fi
```

## Chaos Engineering Scenarios

### 1. Instance Termination Testing
```bash
# Randomly terminate instances to test resilience
aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=test" --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text | shuf -n 1)
```

### 2. Network Partition Simulation
```bash
# Block traffic between subnets
aws ec2 create-network-acl-entry --network-acl-id acl-12345678 --rule-number 100 --protocol -1 --rule-action deny --cidr-block 10.0.2.0/24
```

### 3. Resource Exhaustion Testing
```bash
# Consume CPU to trigger scaling
stress --cpu 4 --timeout 300s
```

## Monitoring and Alerting for Failures

### CloudWatch Alarms for Common Failures
```bash
# ASG scaling failure alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "ASG-Scaling-Failed" \
    --alarm-description "Auto Scaling Group failed to scale" \
    --metric-name "GroupDesiredCapacity" \
    --namespace "AWS/AutoScaling" \
    --statistic "Average" \
    --period 300 \
    --threshold 5 \
    --comparison-operator "LessThanThreshold" \
    --dimensions Name=AutoScalingGroupName,Value=my-asg

# Lambda error rate alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "Lambda-High-Error-Rate" \
    --alarm-description "Lambda function error rate too high" \
    --metric-name "Errors" \
    --namespace "AWS/Lambda" \
    --statistic "Sum" \
    --period 300 \
    --threshold 10 \
    --comparison-operator "GreaterThanThreshold" \
    --dimensions Name=FunctionName,Value=my-function
```

### Automated Remediation
```python
# Lambda function for automated remediation
import boto3
import json

def lambda_handler(event, context):
    # Parse CloudWatch alarm
    message = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = message['AlarmName']
    
    if alarm_name == 'ASG-Scaling-Failed':
        # Trigger manual scaling
        autoscaling = boto3.client('autoscaling')
        autoscaling.set_desired_capacity(
            AutoScalingGroupName='my-asg',
            DesiredCapacity=10,
            HonorCooldown=False
        )
    
    elif alarm_name == 'Lambda-High-Error-Rate':
        # Rollback to previous version
        lambda_client = boto3.client('lambda')
        lambda_client.update_alias(
            FunctionName='my-function',
            Name='LIVE',
            FunctionVersion='$LATEST-1'
        )
    
    return {'statusCode': 200}
```
