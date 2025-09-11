# Module-01: Comprehensive Exercises

## Overview

This directory contains 5 progressive exercises designed to build your infrastructure and compute expertise from basic concepts to advanced implementations.

## Exercise Progression

### Exercise 1: Infrastructure Architecture Design
**Objective**: Design scalable infrastructure patterns
**Difficulty**: Beginner
**Duration**: 4-6 hours
**Prerequisites**: Module-00 completion

### Exercise 2: Auto Scaling Implementation
**Objective**: Implement and optimize auto scaling strategies
**Difficulty**: Intermediate
**Duration**: 6-8 hours
**Prerequisites**: Exercise 1 completion

### Exercise 3: Container Orchestration
**Objective**: Deploy and manage containerized applications
**Difficulty**: Intermediate-Advanced
**Duration**: 8-10 hours
**Prerequisites**: Docker basics, Exercise 2 completion

### Exercise 4: Serverless Architecture
**Objective**: Build event-driven serverless solutions
**Difficulty**: Advanced
**Duration**: 10-12 hours
**Prerequisites**: Lambda basics, Exercise 3 completion

### Exercise 5: Multi-Environment Infrastructure
**Objective**: Implement Infrastructure as Code across environments
**Difficulty**: Advanced
**Duration**: 12-15 hours
**Prerequisites**: All previous exercises

## Exercise 1: Infrastructure Architecture Design

### Scenario
Design infrastructure for a growing SaaS application that needs to scale from 1,000 to 100,000 users over 12 months.

### Requirements
```yaml
Current State:
  - Single EC2 instance
  - MySQL database
  - 1,000 active users
  - $500/month infrastructure cost

Target State:
  - 100,000 active users
  - 99.9% availability
  - Global user base
  - Cost-optimized scaling
```

### Tasks

#### 1.1 Architecture Design (2 hours)
Create comprehensive infrastructure architecture:

**Deliverables**:
- Current state assessment
- Target architecture diagram
- Component selection rationale
- Scaling strategy documentation

#### 1.2 Capacity Planning (1.5 hours)
Calculate resource requirements:

```python
class CapacityPlanner:
    def __init__(self):
        self.user_growth_rate = 0.2  # 20% monthly
        self.peak_concurrent_ratio = 0.1  # 10% of users online
        self.requests_per_user_hour = 50
        
    def calculate_requirements(self, months_ahead):
        current_users = 1000
        future_users = current_users * (1 + self.user_growth_rate) ** months_ahead
        
        peak_concurrent = future_users * self.peak_concurrent_ratio
        peak_requests_per_second = (peak_concurrent * self.requests_per_user_hour) / 3600
        
        return {
            'future_users': future_users,
            'peak_concurrent': peak_concurrent,
            'peak_rps': peak_requests_per_second,
            'recommended_instances': self.calculate_instance_count(peak_rps),
            'database_sizing': self.calculate_db_requirements(future_users)
        }
```

#### 1.3 Cost Analysis (0.5 hours)
Compare infrastructure costs:

**Cost Comparison Table**:
| Component | Current | Target | Monthly Cost |
|-----------|---------|--------|--------------|
| Compute | 1x t3.medium | 3x t3.large + ASG | $150 |
| Database | 1x db.t3.micro | 1x db.r5.large + replicas | $200 |
| Storage | 20GB EBS | 500GB + S3 | $75 |
| Network | Basic | ALB + CloudFront | $50 |
| **Total** | $500 | $475 | **5% savings** |

### Expected Outcomes
- Scalable infrastructure design
- Detailed capacity planning
- Cost-optimized solution
- Implementation roadmap

## Exercise 2: Auto Scaling Implementation

### Scenario
Implement intelligent auto scaling for an e-commerce platform with seasonal traffic patterns.

### Traffic Patterns
```yaml
Normal Traffic: 1,000 RPS
Black Friday: 10,000 RPS (24-hour spike)
Holiday Season: 3,000 RPS (sustained for 6 weeks)
Flash Sales: 5,000 RPS (2-hour spikes, weekly)
```

### Tasks

#### 2.1 Auto Scaling Configuration (3 hours)
Implement comprehensive auto scaling:

```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name ecommerce-template \
    --launch-template-data '{
        "ImageId": "ami-0abcdef1234567890",
        "InstanceType": "t3.medium",
        "SecurityGroupIds": ["sg-12345678"],
        "UserData": "base64-encoded-startup-script",
        "TagSpecifications": [{
            "ResourceType": "instance",
            "Tags": [{"Key": "Environment", "Value": "production"}]
        }]
    }'

# Create Auto Scaling Group with multiple policies
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name ecommerce-asg \
    --launch-template LaunchTemplateName=ecommerce-template,Version=1 \
    --min-size 2 \
    --max-size 50 \
    --desired-capacity 3 \
    --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/ecommerce/1234567890123456 \
    --vpc-zone-identifier "subnet-12345678,subnet-87654321,subnet-13579246"
```

#### 2.2 Predictive Scaling (2 hours)
Implement predictive scaling for known patterns:

```python
class PredictiveScaling:
    def __init__(self):
        self.historical_patterns = {
            'black_friday': {'start': '2023-11-24 00:00', 'peak_multiplier': 10},
            'cyber_monday': {'start': '2023-11-27 00:00', 'peak_multiplier': 8},
            'flash_sales': {'weekly_pattern': 'friday_18:00', 'peak_multiplier': 5}
        }
    
    def create_scheduled_actions(self):
        scheduled_actions = []
        
        for event, config in self.historical_patterns.items():
            if 'start' in config:
                # Pre-scale for known events
                scheduled_actions.append({
                    'scheduled_action_name': f'pre-scale-{event}',
                    'start_time': config['start'],
                    'desired_capacity': self.calculate_capacity(config['peak_multiplier']),
                    'min_size': 5,
                    'max_size': 100
                })
        
        return scheduled_actions
```

#### 2.3 Performance Testing (1 hour)
Test scaling behavior under load:

```bash
# Load testing with Apache Bench
ab -n 100000 -c 100 -t 300 http://your-alb-dns-name/

# Monitor scaling activity
aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name ecommerce-asg \
    --max-items 20

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name RequestCount \
    --dimensions Name=LoadBalancer,Value=app/ecommerce-alb/1234567890123456 \
    --start-time 2023-01-01T00:00:00Z \
    --end-time 2023-01-01T01:00:00Z \
    --period 300 \
    --statistics Sum
```

### Expected Outcomes
- Responsive auto scaling configuration
- Predictive scaling for known events
- Performance validation under load
- Cost optimization through right-sizing

## Exercise 3: Container Orchestration

### Scenario
Migrate a monolithic application to microservices using container orchestration.

### Application Architecture
```yaml
Monolithic App Components:
  - User Service (Authentication, Profiles)
  - Product Service (Catalog, Inventory)
  - Order Service (Cart, Checkout, Payment)
  - Notification Service (Email, SMS)

Target Microservices:
  - 4 separate containerized services
  - Service mesh for communication
  - Centralized logging and monitoring
  - Blue/green deployment capability
```

### Tasks

#### 3.1 Containerization (3 hours)
Create Docker containers for each service:

```dockerfile
# User Service Dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1
CMD ["npm", "start"]
```

#### 3.2 ECS Deployment (3 hours)
Deploy services using Amazon ECS:

```json
{
    "family": "user-service",
    "networkMode": "awsvpc",
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512",
    "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "user-service",
            "image": "account.dkr.ecr.region.amazonaws.com/user-service:latest",
            "portMappings": [
                {
                    "containerPort": 3000,
                    "protocol": "tcp"
                }
            ],
            "healthCheck": {
                "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
                "interval": 30,
                "timeout": 5,
                "retries": 3
            },
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/user-service",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ]
}
```

#### 3.3 Service Mesh Implementation (2 hours)
Configure AWS App Mesh for service communication:

```bash
# Create mesh
aws appmesh create-mesh --mesh-name microservices-mesh

# Create virtual services
aws appmesh create-virtual-service \
    --mesh-name microservices-mesh \
    --virtual-service-name user-service.local \
    --spec provider='{virtualNode={virtualNodeName=user-service-node}}'
```

### Expected Outcomes
- Fully containerized microservices
- Production-ready ECS deployment
- Service mesh communication
- Monitoring and logging integration

## Exercise 4: Serverless Architecture

### Scenario
Build a serverless data processing pipeline for real-time analytics.

### Pipeline Requirements
```yaml
Data Sources:
  - API Gateway (user events)
  - S3 (batch file uploads)
  - DynamoDB Streams (data changes)

Processing Stages:
  - Data validation and enrichment
  - Real-time aggregation
  - Machine learning inference
  - Result storage and notification

Output Destinations:
  - DynamoDB (processed data)
  - S3 (data lake)
  - SNS (notifications)
  - ElasticSearch (search index)
```

### Tasks

#### 4.1 Lambda Function Development (4 hours)
Create specialized Lambda functions:

```python
# Data validation function
import json
import boto3
from jsonschema import validate, ValidationError

def lambda_handler(event, context):
    """Validate incoming data against schema"""
    
    schema = {
        "type": "object",
        "properties": {
            "userId": {"type": "string"},
            "eventType": {"type": "string"},
            "timestamp": {"type": "number"},
            "data": {"type": "object"}
        },
        "required": ["userId", "eventType", "timestamp"]
    }
    
    try:
        # Validate each record
        for record in event['Records']:
            data = json.loads(record['body'])
            validate(instance=data, schema=schema)
            
            # Enrich data
            enriched_data = enrich_user_data(data)
            
            # Send to next stage
            send_to_processing_queue(enriched_data)
            
        return {
            'statusCode': 200,
            'body': json.dumps(f'Processed {len(event["Records"])} records')
        }
        
    except ValidationError as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Validation error: {str(e)}')
        }
```

#### 4.2 Step Functions Orchestration (3 hours)
Create workflow orchestration:

```json
{
    "Comment": "Data processing pipeline",
    "StartAt": "ValidateData",
    "States": {
        "ValidateData": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:validate-data",
            "Next": "ProcessData",
            "Catch": [
                {
                    "ErrorEquals": ["ValidationError"],
                    "Next": "HandleValidationError"
                }
            ]
        },
        "ProcessData": {
            "Type": "Parallel",
            "Branches": [
                {
                    "StartAt": "RealTimeAggregation",
                    "States": {
                        "RealTimeAggregation": {
                            "Type": "Task",
                            "Resource": "arn:aws:lambda:region:account:function:aggregate-data",
                            "End": true
                        }
                    }
                },
                {
                    "StartAt": "MLInference",
                    "States": {
                        "MLInference": {
                            "Type": "Task",
                            "Resource": "arn:aws:lambda:region:account:function:ml-inference",
                            "End": true
                        }
                    }
                }
            ],
            "Next": "StoreResults"
        },
        "StoreResults": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:store-results",
            "End": true
        }
    }
}
```

#### 4.3 Performance Optimization (3 hours)
Optimize for cost and performance:

**Optimization Strategies**:
- Provisioned concurrency for predictable workloads
- Memory optimization based on profiling
- Connection pooling for database access
- Batch processing for efficiency

### Expected Outcomes
- Fully functional serverless pipeline
- Cost-optimized Lambda configurations
- Robust error handling and monitoring
- Scalable event-driven architecture

## Exercise 5: Multi-Environment Infrastructure

### Scenario
Implement Infrastructure as Code for dev, staging, and production environments with proper CI/CD integration.

### Environment Requirements
```yaml
Development:
  - Single AZ deployment
  - Smaller instance sizes
  - Shared resources where possible
  - Cost optimization priority

Staging:
  - Production-like configuration
  - Automated testing integration
  - Blue/green deployment testing
  - Performance testing capability

Production:
  - Multi-AZ high availability
  - Auto scaling and load balancing
  - Comprehensive monitoring
  - Disaster recovery capability
```

### Tasks

#### 5.1 CloudFormation Templates (5 hours)
Create parameterized infrastructure templates:

```yaml
# infrastructure-template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Multi-environment infrastructure template'

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]
    Description: Environment name
  
  InstanceType:
    Type: String
    Default: t3.medium
    Description: EC2 instance type
  
  MinSize:
    Type: Number
    Default: 1
    Description: Minimum instances in ASG
  
  MaxSize:
    Type: Number
    Default: 10
    Description: Maximum instances in ASG

Mappings:
  EnvironmentConfig:
    dev:
      InstanceType: t3.small
      MinSize: 1
      MaxSize: 3
      MultiAZ: false
    staging:
      InstanceType: t3.medium
      MinSize: 2
      MaxSize: 6
      MultiAZ: true
    prod:
      InstanceType: t3.large
      MinSize: 3
      MaxSize: 20
      MultiAZ: true

Resources:
  # VPC, Subnets, Security Groups
  # Auto Scaling Groups
  # Load Balancers
  # RDS Instances
  # Monitoring and Alerting
```

#### 5.2 CI/CD Pipeline (4 hours)
Implement automated deployment pipeline:

```yaml
# .github/workflows/infrastructure.yml
name: Infrastructure Deployment

on:
  push:
    branches: [main, develop]
    paths: ['infrastructure/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate CloudFormation
        run: |
          aws cloudformation validate-template \
            --template-body file://infrastructure/template.yaml

  deploy-dev:
    needs: validate
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Development
        run: |
          aws cloudformation deploy \
            --template-file infrastructure/template.yaml \
            --stack-name app-dev \
            --parameter-overrides Environment=dev \
            --capabilities CAPABILITY_IAM

  deploy-prod:
    needs: validate
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: |
          aws cloudformation deploy \
            --template-file infrastructure/template.yaml \
            --stack-name app-prod \
            --parameter-overrides Environment=prod \
            --capabilities CAPABILITY_IAM
```

#### 5.3 Environment Management (3 hours)
Create environment management scripts:

```python
#!/usr/bin/env python3
"""Environment management utility"""

import boto3
import json
import sys
from datetime import datetime

class EnvironmentManager:
    def __init__(self, environment):
        self.environment = environment
        self.cf_client = boto3.client('cloudformation')
        self.ec2_client = boto3.client('ec2')
    
    def deploy_environment(self, template_path, parameters):
        """Deploy or update environment stack"""
        stack_name = f'app-{self.environment}'
        
        try:
            # Check if stack exists
            self.cf_client.describe_stacks(StackName=stack_name)
            operation = 'update'
        except:
            operation = 'create'
        
        print(f'{operation.title()}ing stack {stack_name}...')
        
        if operation == 'create':
            response = self.cf_client.create_stack(
                StackName=stack_name,
                TemplateBody=open(template_path).read(),
                Parameters=parameters,
                Capabilities=['CAPABILITY_IAM']
            )
        else:
            response = self.cf_client.update_stack(
                StackName=stack_name,
                TemplateBody=open(template_path).read(),
                Parameters=parameters,
                Capabilities=['CAPABILITY_IAM']
            )
        
        return response
    
    def destroy_environment(self):
        """Safely destroy environment"""
        stack_name = f'app-{self.environment}'
        
        if self.environment == 'prod':
            confirmation = input('Are you sure you want to destroy PRODUCTION? (yes/no): ')
            if confirmation.lower() != 'yes':
                print('Aborted.')
                return
        
        self.cf_client.delete_stack(StackName=stack_name)
        print(f'Destroying {stack_name}...')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: python env_manager.py <environment> <action>')
        sys.exit(1)
    
    env = sys.argv[1]
    action = sys.argv[2]
    
    manager = EnvironmentManager(env)
    
    if action == 'deploy':
        parameters = [
            {'ParameterKey': 'Environment', 'ParameterValue': env}
        ]
        manager.deploy_environment('infrastructure/template.yaml', parameters)
    elif action == 'destroy':
        manager.destroy_environment()
```

### Expected Outcomes
- Complete Infrastructure as Code implementation
- Automated CI/CD pipeline
- Environment-specific configurations
- Disaster recovery and rollback capabilities

## Solutions Directory Structure

```
exercises/
├── solutions/
│   ├── exercise-01-infrastructure-design/
│   │   ├── architecture-diagrams/
│   │   ├── capacity-planning.xlsx
│   │   ├── cost-analysis.md
│   │   └── implementation-guide.md
│   ├── exercise-02-auto-scaling/
│   │   ├── cloudformation-templates/
│   │   ├── scaling-policies.json
│   │   ├── load-testing-results/
│   │   └── optimization-report.md
│   ├── exercise-03-containers/
│   │   ├── dockerfiles/
│   │   ├── ecs-task-definitions/
│   │   ├── service-mesh-config/
│   │   └── deployment-guide.md
│   ├── exercise-04-serverless/
│   │   ├── lambda-functions/
│   │   ├── step-functions-definition.json
│   │   ├── performance-optimization/
│   │   └── monitoring-setup.md
│   └── exercise-05-multi-environment/
│       ├── cloudformation-templates/
│       ├── ci-cd-pipelines/
│       ├── environment-scripts/
│       └── deployment-guide.md
```

This comprehensive exercise structure provides hands-on experience with progressive difficulty levels, matching Module 4's gold standard approach.
