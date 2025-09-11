# AWS Microservices Infrastructure

## Overview

This document covers AWS-specific infrastructure patterns and services for building microservices architectures. It provides practical guidance on using AWS services to implement the microservices concepts covered in the general concepts section.

## AWS Well-Architected Framework for Microservices

### 1. Operational Excellence

#### CloudFormation Templates
Infrastructure as Code for microservices deployment.

```yaml
# microservices-infrastructure.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Microservices Infrastructure on AWS'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
  
  VpcCIDR:
    Type: String
    Default: 10.0.0.0/16
  
  AvailabilityZones:
    Type: CommaDelimitedList
    Default: us-west-2a,us-west-2b,us-west-2c

Resources:
  # VPC and Networking
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-microservices-vpc'

  # Public Subnets
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !Ref AvailabilityZones]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet-1'

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [1, !Ref AvailabilityZones]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet-2'

  # Private Subnets
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.10.0/24
      AvailabilityZone: !Select [0, !Ref AvailabilityZones]
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-private-subnet-1'

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.11.0/24
      AvailabilityZone: !Select [1, !Ref AvailabilityZones]
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-private-subnet-2'

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-igw'

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # NAT Gateway
  NatGateway1EIP:
    Type: AWS::EC2::EIP
    DependsOn: InternetGatewayAttachment
    Properties:
      Domain: vpc

  NatGateway1:
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt NatGateway1EIP.AllocationId
      SubnetId: !Ref PublicSubnet1
```

#### ECS Cluster Configuration
```yaml
  # ECS Cluster
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub '${Environment}-microservices-cluster'
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT
      DefaultCapacityProviderStrategy:
        - CapacityProvider: FARGATE
          Weight: 1
        - CapacityProvider: FARGATE_SPOT
          Weight: 1
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # ECS Task Execution Role
  ECSTaskExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
      Policies:
        - PolicyName: ECSSecretsManagerAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - secretsmanager:GetSecretValue
                Resource: !Sub 'arn:aws:secretsmanager:${AWS::Region}:${AWS::AccountId}:secret:${Environment}/*'
```

### 2. Security

#### IAM Roles and Policies
```yaml
  # Application Load Balancer Security Group
  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-alb-sg'
      GroupDescription: Security group for Application Load Balancer
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-alb-sg'

  # ECS Service Security Group
  ECSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-ecs-sg'
      GroupDescription: Security group for ECS services
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          SourceSecurityGroupId: !Ref ALBSecurityGroup
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          SourceSecurityGroupId: !Ref ECSSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecs-sg'

  # Database Security Group
  DatabaseSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-db-sg'
      GroupDescription: Security group for databases
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref ECSSecurityGroup
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          SourceSecurityGroupId: !Ref ECSSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-db-sg'
```

#### Secrets Management
```yaml
  # Secrets Manager Secrets
  DatabaseSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub '${Environment}/microservices/database'
      Description: Database credentials for microservices
      SecretString: !Sub |
        {
          "username": "microservices_user",
          "password": "{{resolve:secretsmanager:${Environment}/microservices/database:SecretString:password}}",
          "host": "${DatabaseCluster.Endpoint.Address}",
          "port": 5432,
          "dbname": "microservices"
        }
      GenerateSecretString:
        SecretStringTemplate: '{"username": "microservices_user"}'
        GenerateStringKey: 'password'
        PasswordLength: 32
        ExcludeCharacters: '"@/\'

  APIGatewaySecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub '${Environment}/microservices/api-gateway'
      Description: API Gateway configuration
      SecretString: !Sub |
        {
          "api_key": "{{resolve:secretsmanager:${Environment}/microservices/api-gateway:SecretString:api_key}}",
          "jwt_secret": "{{resolve:secretsmanager:${Environment}/microservices/api-gateway:SecretString:jwt_secret}}"
        }
      GenerateSecretString:
        SecretStringTemplate: '{"api_key": "microservices_api_key"}'
        GenerateStringKey: 'jwt_secret'
        PasswordLength: 64
```

### 3. Reliability

#### Multi-AZ Database Configuration
```yaml
  # RDS Database Subnet Group
  DatabaseSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupName: !Sub '${Environment}-microservices-db-subnet-group'
      DBSubnetGroupDescription: Subnet group for microservices database
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-db-subnet-group'

  # RDS Database Cluster
  DatabaseCluster:
    Type: AWS::RDS::DBCluster
    Properties:
      DBClusterIdentifier: !Sub '${Environment}-microservices-cluster'
      Engine: aurora-postgresql
      EngineVersion: '13.7'
      DatabaseName: microservices
      MasterUsername: !Sub '{{resolve:secretsmanager:${DatabaseSecret}:SecretString:username}}'
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DatabaseSecret}:SecretString:password}}'
      DBSubnetGroupName: !Ref DatabaseSubnetGroup
      VpcSecurityGroupIds:
        - !Ref DatabaseSecurityGroup
      BackupRetentionPeriod: 7
      PreferredBackupWindow: '03:00-04:00'
      PreferredMaintenanceWindow: 'sun:04:00-sun:05:00'
      StorageEncrypted: true
      DeletionProtection: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-microservices-cluster'
```

### 4. Performance Efficiency

#### Application Load Balancer
```yaml
  # Application Load Balancer
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub '${Environment}-microservices-alb'
      Scheme: internet-facing
      Type: application
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-microservices-alb'

  # Target Group for User Service
  UserServiceTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub '${Environment}-user-service-tg'
      Port: 8080
      Protocol: HTTP
      VpcId: !Ref VPC
      TargetType: ip
      HealthCheckPath: /health/ready
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-user-service-tg'

  # Target Group for Product Service
  ProductServiceTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub '${Environment}-product-service-tg'
      Port: 8080
      Protocol: HTTP
      VpcId: !Ref VPC
      TargetType: ip
      HealthCheckPath: /health/ready
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-product-service-tg'

  # ALB Listener
  ALBListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref UserServiceTargetGroup
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP

  # ALB Listener Rules
  UserServiceListenerRule:
    Type: AWS::ElasticLoadBalancingV2::ListenerRule
    Properties:
      Actions:
        - Type: forward
          TargetGroupArn: !Ref UserServiceTargetGroup
      Conditions:
        - Field: path-pattern
          Values:
            - '/api/users/*'
      ListenerArn: !Ref ALBListener
      Priority: 1

  ProductServiceListenerRule:
    Type: AWS::ElasticLoadBalancingV2::ListenerRule
    Properties:
      Actions:
        - Type: forward
          TargetGroupArn: !Ref ProductServiceTargetGroup
      Conditions:
        - Field: path-pattern
          Values:
            - '/api/products/*'
      ListenerArn: !Ref ALBListener
      Priority: 2
```

### 5. Cost Optimization

#### Auto Scaling Configuration
```yaml
  # Auto Scaling Target for User Service
  UserServiceAutoScalingTarget:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 2
      ResourceId: !Sub 'service/${ECSCluster}/${UserService}'
      RoleARN: !Sub 'arn:aws:iam::${AWS::AccountId}:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService'
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs

  # Auto Scaling Policy for User Service
  UserServiceScalingPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: !Sub '${Environment}-user-service-scaling-policy'
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref UserServiceAutoScalingTarget
      TargetTrackingScalingPolicyConfiguration:
        TargetValue: 70.0
        PredefinedMetricSpecification:
          PredefinedMetricType: ECSServiceAverageCPUUtilization

  # CloudWatch Alarms
  HighCPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-high-cpu-alarm'
      AlarmDescription: 'High CPU utilization alarm'
      MetricName: CPUUtilization
      Namespace: AWS/ECS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: ServiceName
          Value: !Ref UserService
        - Name: ClusterName
          Value: !Ref ECSCluster
```

## AWS Services for Microservices

### 1. Compute Services

#### ECS Fargate Service Definition
```yaml
  # User Service Task Definition
  UserServiceTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: !Sub '${Environment}-user-service'
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 512
      Memory: 1024
      ExecutionRoleArn: !Ref ECSTaskExecutionRole
      TaskRoleArn: !Ref ECSTaskRole
      ContainerDefinitions:
        - Name: user-service
          Image: !Sub '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/user-service:latest'
          PortMappings:
            - ContainerPort: 8080
              Protocol: tcp
          Environment:
            - Name: ENVIRONMENT
              Value: !Ref Environment
            - Name: DATABASE_URL
              Value: !Sub 'postgresql://{{resolve:secretsmanager:${DatabaseSecret}:SecretString:username}}:{{resolve:secretsmanager:${DatabaseSecret}:SecretString:password}}@${DatabaseCluster.Endpoint.Address}:5432/{{resolve:secretsmanager:${DatabaseSecret}:SecretString:dbname}}'
            - Name: REDIS_URL
              Value: !Sub 'redis://${RedisCluster.RedisEndpoint.Address}:6379'
          Secrets:
            - Name: JWT_SECRET
              ValueFrom: !Sub '${APIGatewaySecret}:jwt_secret::'
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref UserServiceLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: user-service
          HealthCheck:
            Command:
              - CMD-SHELL
              - 'curl -f http://localhost:8080/health/ready || exit 1'
            Interval: 30
            Timeout: 5
            Retries: 3
            StartPeriod: 60

  # User Service ECS Service
  UserService:
    Type: AWS::ECS::Service
    Properties:
      ServiceName: !Sub '${Environment}-user-service'
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref UserServiceTaskDefinition
      DesiredCount: 2
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          SecurityGroups:
            - !Ref ECSSecurityGroup
          Subnets:
            - !Ref PrivateSubnet1
            - !Ref PrivateSubnet2
          AssignPublicIp: DISABLED
      LoadBalancers:
        - ContainerName: user-service
          ContainerPort: 8080
          TargetGroupArn: !Ref UserServiceTargetGroup
      DependsOn: ALBListener
```

#### Lambda Functions for Serverless Microservices
```yaml
  # User Service Lambda Function
  UserServiceLambda:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${Environment}-user-service-lambda'
      Runtime: python3.9
      Handler: lambda_function.lambda_handler
      Code:
        S3Bucket: !Ref LambdaCodeBucket
        S3Key: user-service-lambda.zip
      Role: !GetAtt UserServiceLambdaRole.Arn
      Environment:
        Variables:
          DATABASE_URL: !Sub 'postgresql://{{resolve:secretsmanager:${DatabaseSecret}:SecretString:username}}:{{resolve:secretsmanager:${DatabaseSecret}:SecretString:password}}@${DatabaseCluster.Endpoint.Address}:5432/{{resolve:secretsmanager:${DatabaseSecret}:SecretString:dbname}}'
          REDIS_URL: !Sub 'redis://${RedisCluster.RedisEndpoint.Address}:6379'
      Timeout: 30
      MemorySize: 512
      Layers:
        - !Ref UserServiceLambdaLayer

  # User Service Lambda Role
  UserServiceLambdaRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
      Policies:
        - PolicyName: UserServiceLambdaPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - secretsmanager:GetSecretValue
                Resource: !Ref DatabaseSecret
              - Effect: Allow
                Action:
                  - dynamodb:*
                Resource: !Sub '${UserTable.Arn}/*'
              - Effect: Allow
                Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Resource: !Sub 'arn:aws:logs:${AWS::Region}:${AWS::AccountId}:*'
```

### 2. Storage Services

#### DynamoDB Tables
```yaml
  # User Table
  UserTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${Environment}-users'
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: user_id
          AttributeType: S
        - AttributeName: email
          AttributeType: S
      KeySchema:
        - AttributeName: user_id
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: email-index
          KeySchema:
            - AttributeName: email
              KeyType: HASH
          Projection:
            ProjectionType: ALL
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Product Table
  ProductTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${Environment}-products'
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: product_id
          AttributeType: S
        - AttributeName: category
          AttributeType: S
        - AttributeName: created_at
          AttributeType: S
      KeySchema:
        - AttributeName: product_id
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: category-created_at-index
          KeySchema:
            - AttributeName: category
              KeyType: HASH
            - AttributeName: created_at
              KeyType: RANGE
          Projection:
            ProjectionType: ALL
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
      Tags:
        - Key: Environment
          Value: !Ref Environment
```

#### S3 Buckets for Object Storage
```yaml
  # S3 Bucket for User Avatars
  UserAvatarsBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${Environment}-user-avatars-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      LifecycleConfiguration:
        Rules:
          - Id: DeleteIncompleteMultipartUploads
            Status: Enabled
            AbortIncompleteMultipartUpload:
              DaysAfterInitiation: 7
          - Id: TransitionToIA
            Status: Enabled
            Transitions:
              - StorageClass: STANDARD_IA
                TransitionInDays: 30
          - Id: TransitionToGlacier
            Status: Enabled
            Transitions:
              - StorageClass: GLACIER
                TransitionInDays: 90
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # S3 Bucket for Product Images
  ProductImagesBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${Environment}-product-images-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      CorsConfiguration:
        CorsRules:
          - AllowedHeaders:
              - '*'
            AllowedMethods:
              - GET
              - PUT
              - POST
              - DELETE
            AllowedOrigins:
              - '*'
            MaxAge: 3000
      Tags:
        - Key: Environment
          Value: !Ref Environment
```

### 3. Messaging Services

#### SQS Queues
```yaml
  # User Events Queue
  UserEventsQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-user-events'
      VisibilityTimeoutSeconds: 300
      MessageRetentionPeriod: 1209600
      ReceiveMessageWaitTimeSeconds: 20
      RedrivePolicy:
        deadLetterTargetArn: !GetAtt UserEventsDLQ.Arn
        maxReceiveCount: 3
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # User Events DLQ
  UserEventsDLQ:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-user-events-dlq'
      MessageRetentionPeriod: 1209600
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Order Processing Queue
  OrderProcessingQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing'
      VisibilityTimeoutSeconds: 600
      MessageRetentionPeriod: 1209600
      ReceiveMessageWaitTimeSeconds: 20
      RedrivePolicy:
        deadLetterTargetArn: !GetAtt OrderProcessingDLQ.Arn
        maxReceiveCount: 3
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Order Processing DLQ
  OrderProcessingDLQ:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing-dlq'
      MessageRetentionPeriod: 1209600
      Tags:
        - Key: Environment
          Value: !Ref Environment
```

#### SNS Topics
```yaml
  # User Events Topic
  UserEventsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-user-events'
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Order Events Topic
  OrderEventsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-order-events'
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # SNS Subscription for User Events
  UserEventsSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: sqs
      TopicArn: !Ref UserEventsTopic
      Endpoint: !GetAtt UserEventsQueue.Arn
      FilterPolicy:
        event_type:
          - user_created
          - user_updated
          - user_deleted
```

### 4. Caching Services

#### ElastiCache Redis Cluster
```yaml
  # ElastiCache Subnet Group
  ElastiCacheSubnetGroup:
    Type: AWS::ElastiCache::SubnetGroup
    Properties:
      Description: Subnet group for ElastiCache Redis cluster
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2

  # ElastiCache Redis Cluster
  RedisCluster:
    Type: AWS::ElastiCache::ReplicationGroup
    Properties:
      ReplicationGroupId: !Sub '${Environment}-microservices-redis'
      Description: Redis cluster for microservices caching
      NodeType: cache.r5.large
      Port: 6379
      NumCacheClusters: 2
      Engine: redis
      EngineVersion: 6.x
      CacheSubnetGroupName: !Ref ElastiCacheSubnetGroup
      SecurityGroupIds:
        - !Ref RedisSecurityGroup
      AtRestEncryptionEnabled: true
      TransitEncryptionEnabled: true
      AuthToken: !Sub '{{resolve:secretsmanager:${RedisSecret}:SecretString:auth_token}}'
      SnapshotRetentionLimit: 7
      SnapshotWindow: '03:00-05:00'
      MaintenanceWindow: 'sun:05:00-sun:07:00'
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Redis Security Group
  RedisSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-redis-sg'
      GroupDescription: Security group for Redis cluster
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 6379
          ToPort: 6379
          SourceSecurityGroupId: !Ref ECSSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-redis-sg'

  # Redis Secret
  RedisSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub '${Environment}/microservices/redis'
      Description: Redis authentication token
      GenerateSecretString:
        SecretStringTemplate: '{"auth_token": "redis_auth_token"}'
        GenerateStringKey: 'auth_token'
        PasswordLength: 32
```

## Monitoring and Observability

### 1. CloudWatch Logs
```yaml
  # User Service Log Group
  UserServiceLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/aws/ecs/${Environment}-user-service'
      RetentionInDays: 30
      Tags:
        - Key: Environment
          Value: !Ref Environment

  # Product Service Log Group
  ProductServiceLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/aws/ecs/${Environment}-product-service'
      RetentionInDays: 30
      Tags:
        - Key: Environment
          Value: !Ref Environment
```

### 2. CloudWatch Alarms
```yaml
  # High Error Rate Alarm
  HighErrorRateAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-high-error-rate'
      AlarmDescription: 'High error rate alarm for microservices'
      MetricName: ErrorCount
      Namespace: AWS/ApplicationELB
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 2
      Threshold: 10
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: LoadBalancer
          Value: !GetAtt ApplicationLoadBalancer.LoadBalancerFullName

  # High Response Time Alarm
  HighResponseTimeAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-high-response-time'
      AlarmDescription: 'High response time alarm for microservices'
      MetricName: TargetResponseTime
      Namespace: AWS/ApplicationELB
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 2
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: LoadBalancer
          Value: !GetAtt ApplicationLoadBalancer.LoadBalancerFullName
```

## Best Practices

### 1. Infrastructure as Code
- **CloudFormation**: Use CloudFormation for infrastructure management
- **Templates**: Create reusable templates for different environments
- **Versioning**: Version control all infrastructure templates
- **Testing**: Test infrastructure changes in development environment

### 2. Security
- **Least Privilege**: Apply least privilege principle to all IAM roles
- **Secrets Management**: Use AWS Secrets Manager for sensitive data
- **Network Security**: Implement proper security groups and NACLs
- **Encryption**: Enable encryption at rest and in transit

### 3. Monitoring
- **Comprehensive Logging**: Implement structured logging across all services
- **Metrics Collection**: Collect both business and technical metrics
- **Alerting**: Set up appropriate alerts for critical issues
- **Dashboards**: Create dashboards for monitoring system health

### 4. Cost Optimization
- **Right Sizing**: Choose appropriate instance types and sizes
- **Auto Scaling**: Implement auto scaling for dynamic workloads
- **Reserved Instances**: Use reserved instances for predictable workloads
- **Spot Instances**: Use spot instances for fault-tolerant workloads

## Conclusion

AWS provides comprehensive services for building microservices architectures. By leveraging AWS services like ECS, Lambda, DynamoDB, S3, SQS, SNS, and ElastiCache, you can build scalable, reliable, and cost-effective microservices systems.

The key to successful AWS microservices implementation is:
- **Service Selection**: Choose appropriate AWS services for each microservice
- **Infrastructure as Code**: Use CloudFormation for infrastructure management
- **Security**: Implement proper security controls and best practices
- **Monitoring**: Set up comprehensive monitoring and observability

## Next Steps

- **AWS Service Mesh**: Learn about AWS App Mesh for service-to-service communication
- **AWS API Gateway**: Learn about API Gateway for microservices API management
- **AWS X-Ray**: Learn about distributed tracing with AWS X-Ray
- **AWS Step Functions**: Learn about workflow orchestration for microservices
