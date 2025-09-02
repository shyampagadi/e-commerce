# ECS Hands-On Implementation

## 🎯 Practical Objective

Build a production-ready, multi-tier application on ECS with advanced features: auto-scaling, service discovery, load balancing, and comprehensive monitoring.

## 🏗️ Architecture Overview

```
Production ECS Architecture
├── Internet Gateway
├── Application Load Balancer (Public Subnets)
├── ECS Services (Private Subnets)
│   ├── Web Tier (Nginx + React)
│   ├── API Tier (Node.js/Python)
│   └── Worker Tier (Background Jobs)
├── RDS Database (Private Subnets)
├── ElastiCache (Private Subnets)
└── Monitoring (CloudWatch + X-Ray)
```

## 🚀 Lab 1: Complete ECS Cluster Setup

### Step 1: Create VPC Infrastructure
```bash
# Create VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --enable-dns-hostnames \
    --enable-dns-support \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ecs-production-vpc}]'

# Store VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=ecs-production-vpc" --query 'Vpcs[0].VpcId' --output text)

# Create Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ecs-production-igw}]'

IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=ecs-production-igw" --query 'InternetGateways[0].InternetGatewayId' --output text)

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID

# Create Public Subnets (for ALB)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a \
    --map-public-ip-on-launch \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-public-1a}]'

aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-west-2b \
    --map-public-ip-on-launch \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-public-1b}]'

# Create Private Subnets (for ECS tasks)
aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.11.0/24 \
    --availability-zone us-west-2a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-private-1a}]'

aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.12.0/24 \
    --availability-zone us-west-2b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-private-1b}]'
```

### Step 2: Create ECS Cluster with Capacity Providers
```bash
# Create ECS cluster
aws ecs create-cluster \
    --cluster-name production-cluster \
    --capacity-providers FARGATE FARGATE_SPOT EC2 \
    --default-capacity-provider-strategy \
        capacityProvider=FARGATE,weight=1,base=2 \
        capacityProvider=FARGATE_SPOT,weight=4,base=0 \
    --configuration executeCommandConfiguration='{
        "kmsKeyId": "alias/ecs-execute-command",
        "logging": "OVERRIDE",
        "logConfiguration": {
            "cloudWatchLogGroupName": "/aws/ecs/execute-command/production-cluster",
            "cloudWatchEncryptionEnabled": true
        }
    }' \
    --tags key=Environment,value=production key=Project,value=ecs-demo
```

### Step 3: Create Task Execution and Task Roles
```bash
# Create task execution role
cat > task-execution-role-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document file://task-execution-role-trust-policy.json

aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Create application task role
cat > app-task-role-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::my-app-bucket/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:us-west-2:*:secret:app/*"
        }
    ]
}
EOF

aws iam create-policy \
    --policy-name AppTaskRolePolicy \
    --policy-document file://app-task-role-policy.json

aws iam create-role \
    --role-name AppTaskRole \
    --assume-role-policy-document file://task-execution-role-trust-policy.json

aws iam attach-role-policy \
    --role-name AppTaskRole \
    --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AppTaskRolePolicy
```

## 🚀 Lab 2: Multi-Tier Application Deployment

### Step 1: Create Task Definitions
```json
// web-tier-task-definition.json
{
    "family": "web-tier",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "512",
    "memory": "1024",
    "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::ACCOUNT:role/AppTaskRole",
    "containerDefinitions": [
        {
            "name": "nginx",
            "image": "nginx:alpine",
            "portMappings": [
                {
                    "containerPort": 80,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/web-tier",
                    "awslogs-region": "us-west-2",
                    "awslogs-stream-prefix": "ecs",
                    "awslogs-create-group": "true"
                }
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -f http://localhost/ || exit 1"
                ],
                "interval": 30,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 60
            },
            "mountPoints": [
                {
                    "sourceVolume": "nginx-config",
                    "containerPath": "/etc/nginx/conf.d",
                    "readOnly": true
                }
            ]
        }
    ],
    "volumes": [
        {
            "name": "nginx-config",
            "efsVolumeConfiguration": {
                "fileSystemId": "fs-12345678",
                "rootDirectory": "/nginx-config",
                "transitEncryption": "ENABLED"
            }
        }
    ]
}
```

```json
// api-tier-task-definition.json
{
    "family": "api-tier",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "1024",
    "memory": "2048",
    "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
    "taskRoleArn": "arn:aws:iam::ACCOUNT:role/AppTaskRole",
    "containerDefinitions": [
        {
            "name": "api-server",
            "image": "ACCOUNT.dkr.ecr.us-west-2.amazonaws.com/api-server:latest",
            "portMappings": [
                {
                    "containerPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "NODE_ENV",
                    "value": "production"
                },
                {
                    "name": "PORT",
                    "value": "8080"
                }
            ],
            "secrets": [
                {
                    "name": "DATABASE_URL",
                    "valueFrom": "arn:aws:secretsmanager:us-west-2:ACCOUNT:secret:app/database-url"
                },
                {
                    "name": "JWT_SECRET",
                    "valueFrom": "arn:aws:secretsmanager:us-west-2:ACCOUNT:secret:app/jwt-secret"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/api-tier",
                    "awslogs-region": "us-west-2",
                    "awslogs-stream-prefix": "ecs",
                    "awslogs-create-group": "true"
                }
            },
            "healthCheck": {
                "command": [
                    "CMD-SHELL",
                    "curl -f http://localhost:8080/health || exit 1"
                ],
                "interval": 30,
                "timeout": 5,
                "retries": 3,
                "startPeriod": 120
            }
        },
        {
            "name": "xray-daemon",
            "image": "amazon/aws-xray-daemon:latest",
            "portMappings": [
                {
                    "containerPort": 2000,
                    "protocol": "udp"
                }
            ],
            "essential": false,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/xray-daemon",
                    "awslogs-region": "us-west-2",
                    "awslogs-stream-prefix": "ecs",
                    "awslogs-create-group": "true"
                }
            }
        }
    ]
}
```

### Step 2: Register Task Definitions
```bash
# Register web tier task definition
aws ecs register-task-definition \
    --cli-input-json file://web-tier-task-definition.json

# Register API tier task definition
aws ecs register-task-definition \
    --cli-input-json file://api-tier-task-definition.json
```

### Step 3: Create Load Balancer and Target Groups
```bash
# Get subnet IDs
PUBLIC_SUBNET_1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ecs-public-1a" --query 'Subnets[0].SubnetId' --output text)
PUBLIC_SUBNET_2=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ecs-public-1b" --query 'Subnets[0].SubnetId' --output text)

# Create Application Load Balancer
aws elbv2 create-load-balancer \
    --name production-alb \
    --subnets $PUBLIC_SUBNET_1 $PUBLIC_SUBNET_2 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --tags Key=Environment,Value=production

# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers --names production-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Create target groups
aws elbv2 create-target-group \
    --name web-tier-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path / \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

aws elbv2 create-target-group \
    --name api-tier-tg \
    --protocol HTTP \
    --port 8080 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Create listener rules
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$(aws elbv2 describe-target-groups --names web-tier-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
```

## 🚀 Lab 3: Service Creation and Auto Scaling

### Step 1: Create ECS Services
```bash
# Get private subnet IDs
PRIVATE_SUBNET_1=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ecs-private-1a" --query 'Subnets[0].SubnetId' --output text)
PRIVATE_SUBNET_2=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=ecs-private-1b" --query 'Subnets[0].SubnetId' --output text)

# Create web tier service
cat > web-service.json << EOF
{
    "serviceName": "web-tier-service",
    "cluster": "production-cluster",
    "taskDefinition": "web-tier:1",
    "desiredCount": 2,
    "launchType": "FARGATE",
    "platformVersion": "LATEST",
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": ["$PRIVATE_SUBNET_1", "$PRIVATE_SUBNET_2"],
            "securityGroups": ["sg-web-tier"],
            "assignPublicIp": "DISABLED"
        }
    },
    "loadBalancers": [
        {
            "targetGroupArn": "$(aws elbv2 describe-target-groups --names web-tier-tg --query 'TargetGroups[0].TargetGroupArn' --output text)",
            "containerName": "nginx",
            "containerPort": 80
        }
    ],
    "deploymentConfiguration": {
        "maximumPercent": 200,
        "minimumHealthyPercent": 50,
        "deploymentCircuitBreaker": {
            "enable": true,
            "rollback": true
        }
    },
    "enableExecuteCommand": true
}
EOF

aws ecs create-service --cli-input-json file://web-service.json

# Create API tier service
cat > api-service.json << EOF
{
    "serviceName": "api-tier-service",
    "cluster": "production-cluster",
    "taskDefinition": "api-tier:1",
    "desiredCount": 3,
    "launchType": "FARGATE",
    "platformVersion": "LATEST",
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": ["$PRIVATE_SUBNET_1", "$PRIVATE_SUBNET_2"],
            "securityGroups": ["sg-api-tier"],
            "assignPublicIp": "DISABLED"
        }
    },
    "loadBalancers": [
        {
            "targetGroupArn": "$(aws elbv2 describe-target-groups --names api-tier-tg --query 'TargetGroups[0].TargetGroupArn' --output text)",
            "containerName": "api-server",
            "containerPort": 8080
        }
    ],
    "deploymentConfiguration": {
        "maximumPercent": 200,
        "minimumHealthyPercent": 100,
        "deploymentCircuitBreaker": {
            "enable": true,
            "rollback": true
        }
    },
    "enableExecuteCommand": true
}
EOF

aws ecs create-service --cli-input-json file://api-service.json
```

### Step 2: Configure Auto Scaling
```bash
# Register scalable targets
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/production-cluster/web-tier-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 2 \
    --max-capacity 10

aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/production-cluster/api-tier-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 3 \
    --max-capacity 20

# Create scaling policies
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/production-cluster/api-tier-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name api-tier-cpu-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'

# Create custom metric scaling policy
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/production-cluster/api-tier-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name api-tier-request-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 1000.0,
        "CustomizedMetricSpecification": {
            "MetricName": "RequestCountPerTarget",
            "Namespace": "AWS/ApplicationELB",
            "Dimensions": [
                {
                    "Name": "TargetGroup",
                    "Value": "targetgroup/api-tier-tg/1234567890123456"
                }
            ],
            "Statistic": "Sum"
        },
        "ScaleOutCooldown": 300,
        "ScaleInCooldown": 300
    }'
```

## 🚀 Lab 4: Service Discovery and Monitoring

### Step 1: Set Up Service Discovery
```bash
# Create Cloud Map namespace
aws servicediscovery create-private-dns-namespace \
    --name production.local \
    --vpc $VPC_ID \
    --description "Service discovery for production ECS cluster"

NAMESPACE_ID=$(aws servicediscovery list-namespaces --filters Name=TYPE,Values=DNS_PRIVATE --query 'Namespaces[?Name==`production.local`].Id' --output text)

# Create service discovery services
aws servicediscovery create-service \
    --name api-service \
    --namespace-id $NAMESPACE_ID \
    --dns-config NamespaceId=$NAMESPACE_ID,DnsRecords=[{Type=A,TTL=60},{Type=SRV,TTL=60}] \
    --health-check-config Type=HTTP,ResourcePath=/health,FailureThreshold=3

# Update ECS service with service registry
aws ecs update-service \
    --cluster production-cluster \
    --service api-tier-service \
    --service-registries registryArn=$(aws servicediscovery list-services --query 'Services[?Name==`api-service`].Arn' --output text),containerName=api-server,containerPort=8080
```

### Step 2: Configure Comprehensive Monitoring
```bash
# Enable Container Insights
aws ecs put-account-setting \
    --name containerInsights \
    --value enabled

# Create CloudWatch dashboard
cat > dashboard.json << EOF
{
    "widgets": [
        {
            "type": "metric",
            "properties": {
                "metrics": [
                    ["AWS/ECS", "CPUUtilization", "ServiceName", "api-tier-service", "ClusterName", "production-cluster"],
                    [".", "MemoryUtilization", ".", ".", ".", "."],
                    ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/production-alb/1234567890123456"]
                ],
                "period": 300,
                "stat": "Average",
                "region": "us-west-2",
                "title": "ECS Service Metrics"
            }
        }
    ]
}
EOF

aws cloudwatch put-dashboard \
    --dashboard-name "ECS-Production-Dashboard" \
    --dashboard-body file://dashboard.json

# Create CloudWatch alarms
aws cloudwatch put-metric-alarm \
    --alarm-name "ECS-API-High-CPU" \
    --alarm-description "API tier high CPU utilization" \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-west-2:ACCOUNT:ecs-alerts \
    --dimensions Name=ServiceName,Value=api-tier-service Name=ClusterName,Value=production-cluster
```

## 🚀 Lab 5: Blue-Green Deployment

### Step 1: Prepare Blue-Green Deployment
```python
#!/usr/bin/env python3
import boto3
import time
import json

class BlueGreenDeployment:
    def __init__(self, cluster_name, service_name):
        self.ecs = boto3.client('ecs')
        self.elbv2 = boto3.client('elbv2')
        self.cluster_name = cluster_name
        self.service_name = service_name
    
    def deploy_new_version(self, new_task_definition):
        print(f"Starting blue-green deployment for {self.service_name}")
        
        # Get current service configuration
        current_service = self.ecs.describe_services(
            cluster=self.cluster_name,
            services=[self.service_name]
        )['services'][0]
        
        # Create new service with green environment
        green_service_name = f"{self.service_name}-green"
        
        green_service_config = {
            'serviceName': green_service_name,
            'cluster': self.cluster_name,
            'taskDefinition': new_task_definition,
            'desiredCount': current_service['desiredCount'],
            'launchType': current_service['launchType'],
            'networkConfiguration': current_service['networkConfiguration'],
            'loadBalancers': current_service['loadBalancers']
        }
        
        # Deploy green environment
        print("Deploying green environment...")
        self.ecs.create_service(**green_service_config)
        
        # Wait for green environment to be stable
        self.wait_for_service_stable(green_service_name)
        
        # Perform health checks
        if self.validate_green_environment(green_service_name):
            print("Green environment validation successful")
            
            # Switch traffic to green
            self.switch_traffic_to_green(green_service_name)
            
            # Clean up blue environment
            self.cleanup_blue_environment()
            
            print("Blue-green deployment completed successfully")
        else:
            print("Green environment validation failed, rolling back")
            self.cleanup_green_environment(green_service_name)
    
    def wait_for_service_stable(self, service_name):
        waiter = self.ecs.get_waiter('services_stable')
        waiter.wait(
            cluster=self.cluster_name,
            services=[service_name],
            WaiterConfig={'delay': 30, 'maxAttempts': 20}
        )
    
    def validate_green_environment(self, green_service_name):
        # Implement health check validation
        # This could include HTTP health checks, custom validation logic, etc.
        time.sleep(60)  # Wait for warm-up
        return True  # Simplified for demo
    
    def switch_traffic_to_green(self, green_service_name):
        print("Switching traffic to green environment...")
        # Implementation would update load balancer target groups
        pass
    
    def cleanup_blue_environment(self):
        print("Cleaning up blue environment...")
        # Scale down and delete old service
        pass

# Usage
if __name__ == "__main__":
    deployment = BlueGreenDeployment("production-cluster", "api-tier-service")
    deployment.deploy_new_version("api-tier:2")
```

## 🔍 Lab 6: Troubleshooting and Debugging

### Step 1: ECS Exec for Container Debugging
```bash
# Enable ECS Exec on service (already done in service creation)
# Connect to running container
aws ecs execute-command \
    --cluster production-cluster \
    --task $(aws ecs list-tasks --cluster production-cluster --service-name api-tier-service --query 'taskArns[0]' --output text) \
    --container api-server \
    --interactive \
    --command "/bin/bash"

# Debug common issues
# Inside container:
ps aux                    # Check running processes
netstat -tlnp            # Check listening ports
curl localhost:8080/health  # Test health endpoint
env | grep -i database   # Check environment variables
```

### Step 2: Log Analysis and Monitoring
```bash
# Query CloudWatch Logs
aws logs filter-log-events \
    --log-group-name /ecs/api-tier \
    --start-time $(date -d '1 hour ago' +%s)000 \
    --filter-pattern "ERROR"

# Create log insights queries
aws logs start-query \
    --log-group-name /ecs/api-tier \
    --start-time $(date -d '1 hour ago' +%s) \
    --end-time $(date +%s) \
    --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20'
```

## 🎯 Production Readiness Checklist

```yaml
ECS_Production_Checklist:
  Security:
    ✅ Tasks run in private subnets
    ✅ Security groups follow least privilege
    ✅ Task roles have minimal permissions
    ✅ Secrets stored in AWS Secrets Manager
    ✅ Container images scanned for vulnerabilities
    
  Reliability:
    ✅ Multi-AZ deployment configured
    ✅ Health checks properly configured
    ✅ Auto scaling policies in place
    ✅ Circuit breaker enabled
    ✅ Blue-green deployment process tested
    
  Observability:
    ✅ CloudWatch logs configured
    ✅ Container Insights enabled
    ✅ Custom metrics defined
    ✅ Alarms and notifications set up
    ✅ Distributed tracing with X-Ray
    
  Performance:
    ✅ Resource allocation optimized
    ✅ Load balancer configured properly
    ✅ Auto scaling tested under load
    ✅ Database connection pooling
    ✅ CDN configured for static assets
```

## 🔗 Next Steps

Ready to master Fargate serverless deployments? Let's implement advanced Fargate patterns in **Module 8.8: Fargate Implementation**.

---

**Congratulations! You've built a production-ready ECS application. Time for Fargate mastery!** 🚀
