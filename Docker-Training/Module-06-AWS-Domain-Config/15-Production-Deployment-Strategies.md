# Production Deployment Strategies

## Overview
Enterprise-grade deployment strategies for AWS production environments.

## Blue-Green Deployment

### ECS Blue-Green with CodeDeploy
```yaml
# Blue-Green deployment configuration
BlueGreenDeployment:
  Type: AWS::CodeDeploy::Application
  Properties:
    ApplicationName: myapp-bluegreen
    ComputePlatform: ECS

DeploymentGroup:
  Type: AWS::CodeDeploy::DeploymentGroup
  Properties:
    ApplicationName: !Ref BlueGreenDeployment
    DeploymentGroupName: myapp-deployment-group
    ServiceRoleArn: !GetAtt CodeDeployRole.Arn
    BlueGreenDeploymentConfiguration:
      TerminateBlueInstancesOnDeploymentSuccess:
        Action: TERMINATE
        TerminationWaitTimeInMinutes: 5
      DeploymentReadyOption:
        ActionOnTimeout: CONTINUE_DEPLOYMENT
      GreenFleetProvisioningOption:
        Action: COPY_AUTO_SCALING_GROUP
    LoadBalancerInfo:
      TargetGroupInfoList:
        - Name: !Ref TargetGroup
    ECSServices:
      - ServiceName: !Ref ECSService
        ClusterName: !Ref ECSCluster
```

### Lambda Blue-Green
```python
import boto3
import json

def lambda_handler(event, context):
    """Blue-Green deployment for Lambda functions"""
    
    lambda_client = boto3.client('lambda')
    codedeploy = boto3.client('codedeploy')
    
    function_name = event['function_name']
    new_version = event['new_version']
    
    try:
        # Update alias to point to new version gradually
        response = codedeploy.create_deployment(
            applicationName=f'{function_name}-app',
            deploymentGroupName=f'{function_name}-dg',
            revision={
                'revisionType': 'S3',
                's3Location': {
                    'bucket': event['s3_bucket'],
                    'key': event['s3_key'],
                    'version': event['s3_version']
                }
            },
            deploymentConfigName='CodeDeployDefault.Lambda10PercentEvery5Minutes',
            description='Automated blue-green deployment'
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'deploymentId': response['deploymentId'],
                'message': 'Blue-green deployment initiated'
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

## Canary Deployment

### API Gateway Canary
```yaml
CanaryDeployment:
  Type: AWS::ApiGateway::Deployment
  Properties:
    RestApiId: !Ref MyAPI
    StageName: prod
    CanarySettings:
      PercentTraffic: 10
      StageVariableOverrides:
        lambdaAlias: canary
      UseStageCache: false
    DeploymentCanarySettings:
      PercentTraffic: 10
      StageVariableOverrides:
        lambdaAlias: canary
```

### ECS Canary with Target Groups
```yaml
# Primary target group (90% traffic)
PrimaryTargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: myapp-primary
    Port: 80
    Protocol: HTTP
    VpcId: !Ref VPC
    HealthCheckPath: /health

# Canary target group (10% traffic)
CanaryTargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: myapp-canary
    Port: 80
    Protocol: HTTP
    VpcId: !Ref VPC
    HealthCheckPath: /health

# Weighted routing
ListenerRule:
  Type: AWS::ElasticLoadBalancingV2::ListenerRule
  Properties:
    Actions:
      - Type: forward
        ForwardConfig:
          TargetGroups:
            - TargetGroupArn: !Ref PrimaryTargetGroup
              Weight: 90
            - TargetGroupArn: !Ref CanaryTargetGroup
              Weight: 10
    Conditions:
      - Field: path-pattern
        Values: ["/*"]
    ListenerArn: !Ref ALBListener
    Priority: 100
```

## Rolling Deployment

### Auto Scaling Rolling Update
```yaml
AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    LaunchTemplate:
      LaunchTemplateId: !Ref LaunchTemplate
      Version: !GetAtt LaunchTemplate.LatestVersionNumber
    MinSize: 3
    MaxSize: 9
    DesiredCapacity: 6
    VPCZoneIdentifier:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
  UpdatePolicy:
    AutoScalingRollingUpdate:
      MinInstancesInService: 3
      MaxBatchSize: 2
      PauseTime: PT5M
      WaitOnResourceSignals: true
      SuspendProcesses:
        - HealthCheck
        - ReplaceUnhealthy
        - AZRebalance
        - AlarmNotification
        - ScheduledActions
```

### ECS Rolling Update
```yaml
ECSService:
  Type: AWS::ECS::Service
  Properties:
    Cluster: !Ref ECSCluster
    TaskDefinition: !Ref TaskDefinition
    DesiredCount: 4
    DeploymentConfiguration:
      MaximumPercent: 200
      MinimumHealthyPercent: 50
      DeploymentCircuitBreaker:
        Enable: true
        Rollback: true
    ServiceRegistries:
      - RegistryArn: !GetAtt ServiceDiscovery.Arn
```

## Immutable Infrastructure

### AMI-Based Deployment
```bash
#!/bin/bash
# build-ami.sh

set -e

# Build application
docker build -t myapp:${BUILD_NUMBER} .
docker save myapp:${BUILD_NUMBER} > myapp.tar

# Create AMI with Packer
packer build \
    -var "source_ami=${BASE_AMI}" \
    -var "app_version=${BUILD_NUMBER}" \
    -var "app_artifact=myapp.tar" \
    packer-template.json

# Get new AMI ID
NEW_AMI=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=myapp-${BUILD_NUMBER}" \
    --query 'Images[0].ImageId' \
    --output text)

# Update launch template
aws ec2 create-launch-template-version \
    --launch-template-id ${LAUNCH_TEMPLATE_ID} \
    --source-version '$Latest' \
    --launch-template-data "{\"ImageId\":\"${NEW_AMI}\"}"

# Update Auto Scaling Group
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --launch-template LaunchTemplateId=${LAUNCH_TEMPLATE_ID},Version='$Latest'

# Trigger instance refresh
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name ${ASG_NAME} \
    --preferences MinHealthyPercentage=50,InstanceWarmup=300
```

### Container-Based Immutable Deployment
```python
import boto3
import json
from datetime import datetime

class ImmutableDeployment:
    def __init__(self):
        self.ecs = boto3.client('ecs')
        self.elbv2 = boto3.client('elbv2')
        
    def deploy_new_version(self, cluster_name, service_name, new_image):
        """Deploy new version using immutable infrastructure"""
        
        # Get current task definition
        current_service = self.ecs.describe_services(
            cluster=cluster_name,
            services=[service_name]
        )['services'][0]
        
        current_task_def_arn = current_service['taskDefinition']
        current_task_def = self.ecs.describe_task_definition(
            taskDefinition=current_task_def_arn
        )['taskDefinition']
        
        # Create new task definition with new image
        new_task_def = current_task_def.copy()
        new_task_def['containerDefinitions'][0]['image'] = new_image
        
        # Remove fields that shouldn't be in registration
        for field in ['taskDefinitionArn', 'revision', 'status', 'registeredAt', 'registeredBy']:
            new_task_def.pop(field, None)
        
        # Register new task definition
        response = self.ecs.register_task_definition(**new_task_def)
        new_task_def_arn = response['taskDefinition']['taskDefinitionArn']
        
        # Update service with new task definition
        self.ecs.update_service(
            cluster=cluster_name,
            service=service_name,
            taskDefinition=new_task_def_arn,
            deploymentConfiguration={
                'maximumPercent': 200,
                'minimumHealthyPercent': 50,
                'deploymentCircuitBreaker': {
                    'enable': True,
                    'rollback': True
                }
            }
        )
        
        return new_task_def_arn
    
    def wait_for_deployment(self, cluster_name, service_name):
        """Wait for deployment to complete"""
        waiter = self.ecs.get_waiter('services_stable')
        waiter.wait(
            cluster=cluster_name,
            services=[service_name],
            WaiterConfig={
                'Delay': 15,
                'MaxAttempts': 40
            }
        )
```

## Multi-Region Deployment

### Cross-Region Replication
```yaml
# Primary region resources
PrimaryRegionStack:
  Type: AWS::CloudFormation::Stack
  Properties:
    TemplateURL: !Sub 'https://s3.amazonaws.com/${TemplateBucket}/primary-region.yaml'
    Parameters:
      Environment: !Ref Environment
      
# Secondary region stack
SecondaryRegionStack:
  Type: AWS::CloudFormation::Stack
  Properties:
    TemplateURL: !Sub 'https://s3.amazonaws.com/${TemplateBucket}/secondary-region.yaml'
    Parameters:
      Environment: !Ref Environment
      PrimaryRegion: !Ref AWS::Region
      
# Route 53 health checks and failover
HealthCheck:
  Type: AWS::Route53::HealthCheck
  Properties:
    Type: HTTPS
    ResourcePath: /health
    FullyQualifiedDomainName: !GetAtt PrimaryALB.DNSName
    RequestInterval: 30
    FailureThreshold: 3

PrimaryRecord:
  Type: AWS::Route53::RecordSet
  Properties:
    HostedZoneId: !Ref HostedZone
    Name: !Ref DomainName
    Type: A
    SetIdentifier: Primary
    Failover: PRIMARY
    AliasTarget:
      DNSName: !GetAtt PrimaryALB.DNSName
      HostedZoneId: !GetAtt PrimaryALB.CanonicalHostedZoneID
    HealthCheckId: !Ref HealthCheck

SecondaryRecord:
  Type: AWS::Route53::RecordSet
  Properties:
    HostedZoneId: !Ref HostedZone
    Name: !Ref DomainName
    Type: A
    SetIdentifier: Secondary
    Failover: SECONDARY
    AliasTarget:
      DNSName: !GetAtt SecondaryALB.DNSName
      HostedZoneId: !GetAtt SecondaryALB.CanonicalHostedZoneID
```

## Deployment Monitoring

### CloudWatch Deployment Metrics
```python
import boto3
from datetime import datetime, timedelta

class DeploymentMonitor:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.elbv2 = boto3.client('elbv2')
        
    def monitor_deployment_health(self, target_group_arn, deployment_id):
        """Monitor deployment health metrics"""
        
        metrics_to_monitor = [
            'TargetResponseTime',
            'HTTPCode_Target_2XX_Count',
            'HTTPCode_Target_5XX_Count',
            'HealthyHostCount',
            'UnHealthyHostCount'
        ]
        
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(minutes=30)
        
        deployment_health = {}
        
        for metric in metrics_to_monitor:
            response = self.cloudwatch.get_metric_statistics(
                Namespace='AWS/ApplicationELB',
                MetricName=metric,
                Dimensions=[
                    {
                        'Name': 'TargetGroup',
                        'Value': target_group_arn.split('/')[-1]
                    }
                ],
                StartTime=start_time,
                EndTime=end_time,
                Period=300,
                Statistics=['Average', 'Sum']
            )
            
            if response['Datapoints']:
                latest_datapoint = max(response['Datapoints'], key=lambda x: x['Timestamp'])
                deployment_health[metric] = latest_datapoint
        
        # Evaluate deployment health
        is_healthy = self.evaluate_deployment_health(deployment_health)
        
        # Send custom metric
        self.cloudwatch.put_metric_data(
            Namespace='Deployment/Health',
            MetricData=[
                {
                    'MetricName': 'DeploymentHealth',
                    'Value': 1 if is_healthy else 0,
                    'Unit': 'None',
                    'Dimensions': [
                        {
                            'Name': 'DeploymentId',
                            'Value': deployment_id
                        }
                    ]
                }
            ]
        )
        
        return is_healthy, deployment_health
    
    def evaluate_deployment_health(self, metrics):
        """Evaluate if deployment is healthy based on metrics"""
        
        # Check error rate
        if 'HTTPCode_Target_5XX_Count' in metrics:
            error_count = metrics['HTTPCode_Target_5XX_Count'].get('Sum', 0)
            if error_count > 10:  # More than 10 errors in 5 minutes
                return False
        
        # Check response time
        if 'TargetResponseTime' in metrics:
            response_time = metrics['TargetResponseTime'].get('Average', 0)
            if response_time > 2.0:  # More than 2 seconds average
                return False
        
        # Check healthy hosts
        if 'HealthyHostCount' in metrics:
            healthy_hosts = metrics['HealthyHostCount'].get('Average', 0)
            if healthy_hosts < 1:  # No healthy hosts
                return False
        
        return True
```

### Automated Rollback
```python
def automated_rollback(deployment_id, service_name, cluster_name, previous_task_def):
    """Automatically rollback deployment if health checks fail"""
    
    monitor = DeploymentMonitor()
    ecs = boto3.client('ecs')
    
    # Monitor for 10 minutes
    for i in range(20):  # 20 checks, 30 seconds apart
        is_healthy, metrics = monitor.monitor_deployment_health(
            target_group_arn, deployment_id
        )
        
        if not is_healthy:
            print(f"Deployment {deployment_id} is unhealthy. Initiating rollback...")
            
            # Rollback to previous task definition
            ecs.update_service(
                cluster=cluster_name,
                service=service_name,
                taskDefinition=previous_task_def
            )
            
            # Send alert
            sns = boto3.client('sns')
            sns.publish(
                TopicArn='arn:aws:sns:us-east-1:123456789012:deployment-alerts',
                Message=f'Deployment {deployment_id} failed health checks and was rolled back.',
                Subject='Deployment Rollback Initiated'
            )
            
            return False
        
        time.sleep(30)
    
    print(f"Deployment {deployment_id} completed successfully")
    return True
```

## Best Practices

### Deployment Checklist
```yaml
# Pre-deployment checks
PreDeploymentChecks:
  - Validate infrastructure templates
  - Run security scans
  - Verify backup procedures
  - Check rollback plan
  - Validate monitoring setup
  
# During deployment
DeploymentMonitoring:
  - Monitor application metrics
  - Check error rates
  - Verify health checks
  - Monitor resource utilization
  - Track deployment progress
  
# Post-deployment
PostDeploymentValidation:
  - Run smoke tests
  - Verify functionality
  - Check performance metrics
  - Validate security controls
  - Update documentation
```

### Deployment Pipeline
```bash
#!/bin/bash
# production-deploy.sh

set -e

ENVIRONMENT="prod"
DEPLOYMENT_ID=$(date +%Y%m%d-%H%M%S)

echo "Starting production deployment: $DEPLOYMENT_ID"

# Pre-deployment validation
echo "Running pre-deployment checks..."
./scripts/validate-infrastructure.sh
./scripts/security-scan.sh
./scripts/backup-verification.sh

# Deploy infrastructure changes
echo "Deploying infrastructure..."
terraform plan -var-file="environments/prod.tfvars"
terraform apply -auto-approve -var-file="environments/prod.tfvars"

# Deploy application
echo "Deploying application..."
./scripts/deploy-application.sh $ENVIRONMENT $DEPLOYMENT_ID

# Post-deployment validation
echo "Running post-deployment validation..."
./scripts/smoke-tests.sh
./scripts/performance-tests.sh

# Monitor deployment
echo "Monitoring deployment health..."
python scripts/monitor-deployment.py --deployment-id $DEPLOYMENT_ID --duration 600

echo "Production deployment completed successfully: $DEPLOYMENT_ID"
```
