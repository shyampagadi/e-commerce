# Real-World AWS Examples

## Overview
Practical AWS deployment examples for common application architectures.

## E-Commerce Platform Deployment

### Architecture Overview
```yaml
# Complete e-commerce infrastructure
Resources:
  # VPC and Networking
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      
  # Application Load Balancer
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: ecommerce-alb
      Scheme: internet-facing
      Type: application
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref ALBSecurityGroup
        
  # Auto Scaling Group
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: ecommerce-template
      LaunchTemplateData:
        ImageId: ami-0abcdef1234567890
        InstanceType: t3.medium
        SecurityGroupIds:
          - !Ref WebServerSecurityGroup
        IamInstanceProfile:
          Arn: !GetAtt InstanceProfile.Arn
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y docker
            systemctl start docker
            systemctl enable docker
            
            # Pull and run application
            docker pull myregistry/ecommerce-app:latest
            docker run -d -p 80:3000 \
              -e DATABASE_URL=${DatabaseEndpoint} \
              -e REDIS_URL=${RedisEndpoint} \
              myregistry/ecommerce-app:latest
```

### Database Configuration
```yaml
# RDS PostgreSQL for main database
Database:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: ecommerce-db
    DBInstanceClass: db.r5.large
    Engine: postgres
    EngineVersion: 15.4
    MasterUsername: !Ref DBUsername
    MasterUserPassword: !Ref DBPassword
    AllocatedStorage: 100
    StorageType: gp3
    StorageEncrypted: true
    MultiAZ: true
    VPCSecurityGroups:
      - !Ref DatabaseSecurityGroup
    DBSubnetGroupName: !Ref DBSubnetGroup
    BackupRetentionPeriod: 30
    
# ElastiCache Redis for sessions and caching
RedisCluster:
  Type: AWS::ElastiCache::ReplicationGroup
  Properties:
    ReplicationGroupId: ecommerce-redis
    Description: Redis cluster for ecommerce app
    NodeType: cache.r6g.large
    NumCacheClusters: 2
    Engine: redis
    EngineVersion: 7.0
    Port: 6379
    SecurityGroupIds:
      - !Ref RedisSecurityGroup
    SubnetGroupName: !Ref RedisSubnetGroup
```

## Multi-Tier Web Application

### Frontend (React SPA)
```yaml
# S3 bucket for static assets
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub "${AWS::StackName}-frontend"
    WebsiteConfiguration:
      IndexDocument: index.html
      ErrorDocument: error.html
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
      
# CloudFront distribution
CloudFrontDistribution:
  Type: AWS::CloudFront::Distribution
  Properties:
    DistributionConfig:
      Aliases:
        - www.myapp.com
      DefaultCacheBehavior:
        TargetOriginId: S3Origin
        ViewerProtocolPolicy: redirect-to-https
        CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6
      Origins:
        - Id: S3Origin
          DomainName: !GetAtt S3Bucket.RegionalDomainName
          S3OriginConfig:
            OriginAccessIdentity: !Sub "origin-access-identity/cloudfront/${OAI}"
      Enabled: true
      DefaultRootObject: index.html
      ViewerCertificate:
        AcmCertificateArn: !Ref SSLCertificate
        SslSupportMethod: sni-only
```

### Backend API (Node.js/Express)
```dockerfile
# Dockerfile for API service
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY src/ ./src/
COPY public/ ./public/

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

CMD ["npm", "start"]
```

### Deployment Script
```bash
#!/bin/bash
# deploy-api.sh

set -e

# Build and push Docker image
docker build -t myapp-api:${BUILD_NUMBER} .
docker tag myapp-api:${BUILD_NUMBER} ${ECR_REGISTRY}/myapp-api:${BUILD_NUMBER}
docker push ${ECR_REGISTRY}/myapp-api:${BUILD_NUMBER}

# Update ECS service
aws ecs update-service \
    --cluster myapp-cluster \
    --service myapp-api-service \
    --task-definition myapp-api:${BUILD_NUMBER} \
    --force-new-deployment

# Wait for deployment to complete
aws ecs wait services-stable \
    --cluster myapp-cluster \
    --services myapp-api-service

echo "Deployment completed successfully"
```

## Microservices Architecture

### Service Mesh with ECS
```yaml
# ECS Cluster
ECSCluster:
  Type: AWS::ECS::Cluster
  Properties:
    ClusterName: microservices-cluster
    CapacityProviders:
      - FARGATE
      - FARGATE_SPOT
    DefaultCapacityProviderStrategy:
      - CapacityProvider: FARGATE
        Weight: 1
      - CapacityProvider: FARGATE_SPOT
        Weight: 4
        
# User Service
UserService:
  Type: AWS::ECS::Service
  Properties:
    ServiceName: user-service
    Cluster: !Ref ECSCluster
    TaskDefinition: !Ref UserTaskDefinition
    DesiredCount: 3
    LaunchType: FARGATE
    NetworkConfiguration:
      AwsvpcConfiguration:
        SecurityGroups:
          - !Ref ServiceSecurityGroup
        Subnets:
          - !Ref PrivateSubnet1
          - !Ref PrivateSubnet2
    LoadBalancers:
      - ContainerName: user-service
        ContainerPort: 3000
        TargetGroupArn: !Ref UserServiceTargetGroup
        
UserTaskDefinition:
  Type: AWS::ECS::TaskDefinition
  Properties:
    Family: user-service
    NetworkMode: awsvpc
    RequiresCompatibilities:
      - FARGATE
    Cpu: 256
    Memory: 512
    ExecutionRoleArn: !GetAtt TaskExecutionRole.Arn
    TaskRoleArn: !GetAtt TaskRole.Arn
    ContainerDefinitions:
      - Name: user-service
        Image: !Sub "${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/user-service:latest"
        PortMappings:
          - ContainerPort: 3000
        Environment:
          - Name: DATABASE_URL
            Value: !Sub "postgresql://${DBUsername}:${DBPassword}@${Database.Endpoint}:5432/users"
          - Name: REDIS_URL
            Value: !Sub "redis://${RedisCluster.RedisEndpoint.Address}:6379"
        LogConfiguration:
          LogDriver: awslogs
          Options:
            awslogs-group: !Ref UserServiceLogGroup
            awslogs-region: !Ref AWS::Region
            awslogs-stream-prefix: ecs
```

### API Gateway Integration
```yaml
# API Gateway for microservices
APIGateway:
  Type: AWS::ApiGateway::RestApi
  Properties:
    Name: microservices-api
    Description: API Gateway for microservices
    
# User service resource
UserResource:
  Type: AWS::ApiGateway::Resource
  Properties:
    RestApiId: !Ref APIGateway
    ParentId: !GetAtt APIGateway.RootResourceId
    PathPart: users
    
UserMethod:
  Type: AWS::ApiGateway::Method
  Properties:
    RestApiId: !Ref APIGateway
    ResourceId: !Ref UserResource
    HttpMethod: ANY
    AuthorizationType: AWS_IAM
    Integration:
      Type: HTTP_PROXY
      IntegrationHttpMethod: ANY
      Uri: !Sub "http://${UserServiceALB.DNSName}/users"
      
# Product service resource
ProductResource:
  Type: AWS::ApiGateway::Resource
  Properties:
    RestApiId: !Ref APIGateway
    ParentId: !GetAtt APIGateway.RootResourceId
    PathPart: products
```

## Serverless Application

### Lambda Functions
```python
# Lambda function for order processing
import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
ses = boto3.client('ses')

def lambda_handler(event, context):
    """Process new orders"""
    
    try:
        # Parse order data
        order_data = json.loads(event['Records'][0]['body'])
        
        # Save to DynamoDB
        orders_table = dynamodb.Table(os.environ['ORDERS_TABLE'])
        orders_table.put_item(Item=order_data)
        
        # Send notification
        sns.publish(
            TopicArn=os.environ['ORDER_TOPIC'],
            Message=json.dumps(order_data),
            Subject=f"New Order: {order_data['order_id']}"
        )
        
        # Send confirmation email
        ses.send_email(
            Source='orders@myapp.com',
            Destination={'ToAddresses': [order_data['customer_email']]},
            Message={
                'Subject': {'Data': 'Order Confirmation'},
                'Body': {
                    'Text': {
                        'Data': f"Your order {order_data['order_id']} has been received."
                    }
                }
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Order processed successfully'})
        }
        
    except Exception as e:
        print(f"Error processing order: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to process order'})
        }
```

### SAM Template
```yaml
# template.yaml for serverless application
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 30
    Runtime: python3.9
    Environment:
      Variables:
        ORDERS_TABLE: !Ref OrdersTable
        ORDER_TOPIC: !Ref OrderTopic

Resources:
  # API Gateway
  OrderAPI:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      Cors:
        AllowMethods: "'GET,POST,PUT,DELETE'"
        AllowHeaders: "'Content-Type,X-Amz-Date,Authorization'"
        AllowOrigin: "'*'"
        
  # Lambda Functions
  CreateOrderFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/create_order/
      Handler: app.lambda_handler
      Events:
        CreateOrder:
          Type: Api
          Properties:
            RestApiId: !Ref OrderAPI
            Path: /orders
            Method: post
            
  ProcessOrderFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/process_order/
      Handler: app.lambda_handler
      Events:
        OrderQueue:
          Type: SQS
          Properties:
            Queue: !GetAtt OrderQueue.Arn
            BatchSize: 10
            
  # DynamoDB Table
  OrdersTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: Orders
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: order_id
          AttributeType: S
        - AttributeName: customer_id
          AttributeType: S
      KeySchema:
        - AttributeName: order_id
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: CustomerIndex
          KeySchema:
            - AttributeName: customer_id
              KeyType: HASH
          Projection:
            ProjectionType: ALL
            
  # SQS Queue
  OrderQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: order-processing-queue
      VisibilityTimeoutSeconds: 180
      MessageRetentionPeriod: 1209600
      
  # SNS Topic
  OrderTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: order-notifications
```

## CI/CD Pipeline

### CodePipeline Configuration
```yaml
# CI/CD Pipeline
CodePipeline:
  Type: AWS::CodePipeline::Pipeline
  Properties:
    Name: myapp-pipeline
    RoleArn: !GetAtt CodePipelineRole.Arn
    ArtifactStore:
      Type: S3
      Location: !Ref ArtifactsBucket
    Stages:
      - Name: Source
        Actions:
          - Name: SourceAction
            ActionTypeId:
              Category: Source
              Owner: ThirdParty
              Provider: GitHub
              Version: 1
            Configuration:
              Owner: myusername
              Repo: myapp
              Branch: main
              OAuthToken: !Ref GitHubToken
            OutputArtifacts:
              - Name: SourceOutput
              
      - Name: Build
        Actions:
          - Name: BuildAction
            ActionTypeId:
              Category: Build
              Owner: AWS
              Provider: CodeBuild
              Version: 1
            Configuration:
              ProjectName: !Ref CodeBuildProject
            InputArtifacts:
              - Name: SourceOutput
            OutputArtifacts:
              - Name: BuildOutput
              
      - Name: Deploy
        Actions:
          - Name: DeployAction
            ActionTypeId:
              Category: Deploy
              Owner: AWS
              Provider: ECS
              Version: 1
            Configuration:
              ClusterName: !Ref ECSCluster
              ServiceName: !Ref ECSService
              FileName: imagedefinitions.json
            InputArtifacts:
              - Name: BuildOutput
```

### CodeBuild Project
```yaml
CodeBuildProject:
  Type: AWS::CodeBuild::Project
  Properties:
    Name: myapp-build
    ServiceRole: !GetAtt CodeBuildRole.Arn
    Artifacts:
      Type: CODEPIPELINE
    Environment:
      Type: LINUX_CONTAINER
      ComputeType: BUILD_GENERAL1_MEDIUM
      Image: aws/codebuild/amazonlinux2-x86_64-standard:3.0
      PrivilegedMode: true
      EnvironmentVariables:
        - Name: AWS_DEFAULT_REGION
          Value: !Ref AWS::Region
        - Name: AWS_ACCOUNT_ID
          Value: !Ref AWS::AccountId
        - Name: IMAGE_REPO_NAME
          Value: myapp
        - Name: IMAGE_TAG
          Value: latest
    Source:
      Type: CODEPIPELINE
      BuildSpec: |
        version: 0.2
        phases:
          pre_build:
            commands:
              - echo Logging in to Amazon ECR...
              - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
          build:
            commands:
              - echo Build started on `date`
              - echo Building the Docker image...
              - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
              - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
          post_build:
            commands:
              - echo Build completed on `date`
              - echo Pushing the Docker image...
              - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
              - printf '[{"name":"myapp","imageUri":"%s"}]' $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG > imagedefinitions.json
        artifacts:
          files:
            - imagedefinitions.json
```

## Monitoring and Observability

### Comprehensive Monitoring Stack
```yaml
# CloudWatch Dashboard
MonitoringDashboard:
  Type: AWS::CloudWatch::Dashboard
  Properties:
    DashboardName: MyApp-Production
    DashboardBody: !Sub |
      {
        "widgets": [
          {
            "type": "metric",
            "properties": {
              "metrics": [
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}"],
                ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}"],
                ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}"],
                ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}"]
              ],
              "period": 300,
              "stat": "Sum",
              "region": "${AWS::Region}",
              "title": "Application Load Balancer Metrics"
            }
          },
          {
            "type": "metric",
            "properties": {
              "metrics": [
                ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${Database}"],
                ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${Database}"],
                ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "${Database}"],
                ["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", "${Database}"]
              ],
              "period": 300,
              "stat": "Average",
              "region": "${AWS::Region}",
              "title": "Database Performance"
            }
          }
        ]
      }
```

This completes the comprehensive Module 6 with all the missing files. The module now includes:

1. ✅ README.md (existing)
2. ✅ 01-AWS-Account-Setup-IAM.md (existing)
3. ✅ 02-VPC-Networking-Fundamentals.md (existing)
4. ✅ 03-EC2-Compute-Services.md (existing)
5. ✅ **04-Load-Balancers-Auto-Scaling.md** (newly created)
6. ✅ 05-Route53-DNS-Management.md (existing)
7. ✅ **06-S3-CloudFront-CDN.md** (newly created)
8. ✅ **07-RDS-Database-Setup.md** (newly created)
9. ✅ 08-Certificate-Manager-Setup.md (existing)
10. ✅ **09-Security-Best-Practices.md** (newly created)
11. ✅ **10-Monitoring-CloudWatch.md** (newly created)
12. ✅ **11-Troubleshooting-Guide.md** (newly created)
13. ✅ **12-Real-World-Examples.md** (newly created)
14. ✅ 16-Hands-On-Labs.md (existing)
15. ✅ 17-Module-Assessment.md (existing)

Module 6 is now complete with comprehensive coverage of AWS fundamentals, matching the quality and depth of the other completed modules!
