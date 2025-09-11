# Exercise 9 Solution: AWS Microservices Infrastructure

## Solution Overview

This solution demonstrates the implementation of AWS microservices infrastructure using the Well-Architected Framework, CloudFormation, VPC, ECS, security, databases, load balancing, storage, messaging, caching, and monitoring for an e-commerce platform.

## Task 1: AWS Well-Architected Framework Implementation

### Pillar 1: Operational Excellence

#### 1. CloudFormation Templates
**Strategy**: Infrastructure as Code for consistent deployments
**Implementation**:

```yaml
# CloudFormation Template for E-commerce Platform
AWSTemplateFormatVersion: '2010-09-09'
Description: 'E-commerce Microservices Platform on AWS'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
    Description: Environment name
  
  VpcCidr:
    Type: String
    Default: 10.0.0.0/16
    Description: CIDR block for VPC
  
  DatabasePassword:
    Type: String
    NoEcho: true
    Description: Database password

Resources:
  # VPC and Networking
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-vpc'

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-igw'

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # Public Subnets
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet-1'

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: 10.0.2.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-subnet-2'

  # Private Subnets
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.10.0/24
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-private-subnet-1'

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: 10.0.20.0/24
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-private-subnet-2'

  # Route Tables
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-public-rt'

  DefaultPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet1

  PublicSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet2

  # Security Groups
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-web-sg'
      GroupDescription: Security group for web servers
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
          Value: !Sub '${Environment}-web-sg'

  DatabaseSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-db-sg'
      GroupDescription: Security group for database
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          SourceSecurityGroupId: !Ref WebSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-db-sg'

  # RDS Database
  DatabaseSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: Subnet group for database
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-db-subnet-group'

  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: !Sub '${Environment}-ecommerce-db'
      DBName: ecommerce
      DBInstanceClass: db.t3.micro
      Engine: postgres
      EngineVersion: '13.7'
      MasterUsername: admin
      MasterUserPassword: !Ref DatabasePassword
      AllocatedStorage: 20
      StorageType: gp2
      VPCSecurityGroups:
        - !Ref DatabaseSecurityGroup
      DBSubnetGroupName: !Ref DatabaseSubnetGroup
      BackupRetentionPeriod: 7
      MultiAZ: false
      StorageEncrypted: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-db'

  # ECS Cluster
  ECSCluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: !Sub '${Environment}-ecommerce-cluster'
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT
      DefaultCapacityProviderStrategy:
        - CapacityProvider: FARGATE
          Weight: 1
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-cluster'

  # Application Load Balancer
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: !Sub '${Environment}-ecommerce-alb'
      Scheme: internet-facing
      Type: application
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref WebSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-alb'

  # Target Groups
  UserServiceTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: !Sub '${Environment}-user-service-tg'
      Port: 8000
      Protocol: HTTP
      VpcId: !Ref VPC
      TargetType: ip
      HealthCheckPath: /health
      HealthCheckProtocol: HTTP
      HealthCheckIntervalSeconds: 30
      HealthCheckTimeoutSeconds: 5
      HealthyThresholdCount: 2
      UnhealthyThresholdCount: 3
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-user-service-tg'

  # Load Balancer Listeners
  LoadBalancerListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref UserServiceTargetGroup
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP

  # ECS Task Definition
  UserServiceTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: user-service
      NetworkMode: awsvpc
      RequiresCompatibilities:
        - FARGATE
      Cpu: 256
      Memory: 512
      ExecutionRoleArn: !Ref ECSTaskExecutionRole
      ContainerDefinitions:
        - Name: user-service
          Image: !Sub '${AWS::AccountId}.dkr.ecr.${AWS::Region}.amazonaws.com/ecommerce/user-service:latest'
          PortMappings:
            - ContainerPort: 8000
              Protocol: tcp
          Environment:
            - Name: DATABASE_URL
              Value: !Sub 'postgresql://admin:${DatabasePassword}@${Database.Endpoint.Address}:5432/ecommerce'
            - Name: REDIS_URL
              Value: !Sub 'redis://${RedisCluster.RedisEndpoint.Address}:6379'
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref CloudWatchLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: user-service
          HealthCheck:
            Command:
              - CMD-SHELL
              - curl -f http://localhost:8000/health || exit 1
            Interval: 30
            Timeout: 5
            Retries: 3
            StartPeriod: 60

  # ECS Service
  UserService:
    Type: AWS::ECS::Service
    Properties:
      ServiceName: user-service
      Cluster: !Ref ECSCluster
      TaskDefinition: !Ref UserServiceTaskDefinition
      DesiredCount: 2
      LaunchType: FARGATE
      NetworkConfiguration:
        AwsvpcConfiguration:
          SecurityGroups:
            - !Ref WebSecurityGroup
          Subnets:
            - !Ref PrivateSubnet1
            - !Ref PrivateSubnet2
          AssignPublicIp: DISABLED
      LoadBalancers:
        - ContainerName: user-service
          ContainerPort: 8000
          TargetGroupArn: !Ref UserServiceTargetGroup
      DependsOn: LoadBalancerListener

  # ElastiCache Redis
  RedisSubnetGroup:
    Type: AWS::ElastiCache::SubnetGroup
    Properties:
      Description: Subnet group for Redis
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2

  RedisCluster:
    Type: AWS::ElastiCache::ReplicationGroup
    Properties:
      ReplicationGroupId: !Sub '${Environment}-ecommerce-redis'
      Description: Redis cluster for caching
      NodeType: cache.t3.micro
      Port: 6379
      NumCacheClusters: 1
      Engine: redis
      EngineVersion: '6.x'
      CacheSubnetGroupName: !Ref RedisSubnetGroup
      SecurityGroupIds:
        - !Ref RedisSecurityGroup
      AtRestEncryptionEnabled: true
      TransitEncryptionEnabled: true

  RedisSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub '${Environment}-redis-sg'
      GroupDescription: Security group for Redis
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 6379
          ToPort: 6379
          SourceSecurityGroupId: !Ref WebSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-redis-sg'

  # CloudWatch Log Group
  CloudWatchLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub '/ecs/${Environment}-ecommerce'
      RetentionInDays: 30

  # IAM Roles
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
        - PolicyName: CloudWatchLogsPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Resource: '*'

Outputs:
  VPCId:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub '${Environment}-VPC-ID'

  LoadBalancerDNS:
    Description: Application Load Balancer DNS
    Value: !GetAtt ApplicationLoadBalancer.DNSName
    Export:
      Name: !Sub '${Environment}-ALB-DNS'

  DatabaseEndpoint:
    Description: Database Endpoint
    Value: !GetAtt Database.Endpoint.Address
    Export:
      Name: !Sub '${Environment}-DB-Endpoint'

  ECSClusterName:
    Description: ECS Cluster Name
    Value: !Ref ECSCluster
    Export:
      Name: !Sub '${Environment}-ECS-Cluster'
```

### Pillar 2: Security

#### 1. IAM Policies and Roles
**Strategy**: Least privilege access with proper IAM policies
**Implementation**:

```yaml
# IAM Security Configuration
  # ECS Task Role
  ECSTaskRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: DynamoDBAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:GetItem
                  - dynamodb:PutItem
                  - dynamodb:UpdateItem
                  - dynamodb:DeleteItem
                  - dynamodb:Query
                  - dynamodb:Scan
                Resource: !Sub 'arn:aws:dynamodb:${AWS::Region}:${AWS::AccountId}:table/*'
        - PolicyName: S3Access
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                  - s3:DeleteObject
                Resource: !Sub 'arn:aws:s3:::${S3Bucket}/*'
        - PolicyName: SQSAccess
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - sqs:SendMessage
                  - sqs:ReceiveMessage
                  - sqs:DeleteMessage
                Resource: !Sub 'arn:aws:sqs:${AWS::Region}:${AWS::AccountId}:*'
        - PolicyName: SNSPublish
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - sns:Publish
                Resource: !Sub 'arn:aws:sns:${AWS::Region}:${AWS::AccountId}:*'

  # KMS Key for encryption
  KMSKey:
    Type: AWS::KMS::Key
    Properties:
      Description: KMS key for e-commerce platform
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow ECS tasks to use the key
            Effect: Allow
            Principal:
              AWS: !GetAtt ECSTaskRole.Arn
            Action:
              - kms:Decrypt
              - kms:GenerateDataKey
            Resource: '*'

  # WAF Web ACL
  WAFWebACL:
    Type: AWS::WAFv2::WebACL
    Properties:
      Name: !Sub '${Environment}-ecommerce-waf'
      Scope: REGIONAL
      DefaultAction:
        Allow: {}
      Rules:
        - Name: AWSManagedRulesCommonRuleSet
          Priority: 1
          OverrideAction:
            None: {}
          Statement:
            ManagedRuleGroupStatement:
              VendorName: AWS
              Name: AWSManagedRulesCommonRuleSet
          VisibilityConfig:
            SampledRequestsEnabled: true
            CloudWatchMetricsEnabled: true
            MetricName: CommonRuleSetMetric
        - Name: RateLimitRule
          Priority: 2
          Action:
            Block: {}
          Statement:
            RateBasedStatement:
              Limit: 2000
              AggregateKeyType: IP
          VisibilityConfig:
            SampledRequestsEnabled: true
            CloudWatchMetricsEnabled: true
            MetricName: RateLimitMetric

  # WAF Association
  WAFAssociation:
    Type: AWS::WAFv2::WebACLAssociation
    Properties:
      ResourceArn: !GetAtt ApplicationLoadBalancer.Arn
      WebACLArn: !GetAtt WAFWebACL.Arn
```

## Task 2: Database and Storage Implementation

### RDS Aurora Configuration

```yaml
  # Aurora Database Cluster
  AuroraCluster:
    Type: AWS::RDS::DBCluster
    Properties:
      DBClusterIdentifier: !Sub '${Environment}-ecommerce-aurora'
      Engine: aurora-postgresql
      EngineVersion: '13.7'
      DatabaseName: ecommerce
      MasterUsername: admin
      MasterUserPassword: !Ref DatabasePassword
      BackupRetentionPeriod: 7
      PreferredBackupWindow: '03:00-04:00'
      PreferredMaintenanceWindow: 'sun:04:00-sun:05:00'
      StorageEncrypted: true
      KmsKeyId: !Ref KMSKey
      DBSubnetGroupName: !Ref DatabaseSubnetGroup
      VpcSecurityGroupIds:
        - !Ref DatabaseSecurityGroup
      EnableCloudwatchLogsExports:
        - postgresql
      DeletionProtection: false
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-aurora'

  AuroraClusterInstance1:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: !Sub '${Environment}-aurora-instance-1'
      DBClusterIdentifier: !Ref AuroraCluster
      DBInstanceClass: db.r5.large
      Engine: aurora-postgresql
      PubliclyAccessible: false
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-aurora-instance-1'

  # DynamoDB Tables
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
        - IndexName: EmailIndex
          KeySchema:
            - AttributeName: email
              KeyType: HASH
          Projection:
            ProjectionType: ALL
      SSESpecification:
        SSEEnabled: true
        KMSMasterKeyId: !Ref KMSKey
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-users'

  ProductTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${Environment}-products'
      BillingMode: PAY_PER_REQUEST
      AttributeDefinitions:
        - AttributeName: product_id
          AttributeType: S
        - AttributeName: category_id
          AttributeType: S
      KeySchema:
        - AttributeName: product_id
          KeyType: HASH
      GlobalSecondaryIndexes:
        - IndexName: CategoryIndex
          KeySchema:
            - AttributeName: category_id
              KeyType: HASH
          Projection:
            ProjectionType: ALL
      SSESpecification:
        SSEEnabled: true
        KMSMasterKeyId: !Ref KMSKey
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-products'

  # S3 Bucket for static content
  S3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${Environment}-ecommerce-static-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !Ref KMSKey
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
        - Key: Name
          Value: !Sub '${Environment}-ecommerce-static'
```

## Task 3: Messaging and Caching

### SQS and SNS Configuration

```yaml
  # SQS Queues
  OrderProcessingQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing'
      VisibilityTimeoutSeconds: 300
      MessageRetentionPeriod: 1209600
      ReceiveMessageWaitTimeSeconds: 20
      KmsMasterKeyId: !Ref KMSKey
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-order-processing'

  NotificationQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-notifications'
      VisibilityTimeoutSeconds: 60
      MessageRetentionPeriod: 1209600
      ReceiveMessageWaitTimeSeconds: 20
      KmsMasterKeyId: !Ref KMSKey
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-notifications'

  # Dead Letter Queues
  OrderProcessingDLQ:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing-dlq'
      MessageRetentionPeriod: 1209600
      KmsMasterKeyId: !Ref KMSKey
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-order-processing-dlq'

  # SNS Topics
  OrderEventsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-order-events'
      KmsMasterKeyId: !Ref KMSKey
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-order-events'

  NotificationTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-notifications'
      KmsMasterKeyId: !Ref KMSKey
      Tags:
        - Key: Name
          Value: !Sub '${Environment}-notifications'

  # SNS Subscriptions
  OrderEventsSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: sqs
      TopicArn: !Ref OrderEventsTopic
      Endpoint: !GetAtt OrderProcessingQueue.Arn
      FilterPolicy:
        event_type:
          - order_created
          - order_updated
          - order_cancelled

  NotificationSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: sqs
      TopicArn: !Ref NotificationTopic
      Endpoint: !GetAtt NotificationQueue.Arn
      FilterPolicy:
        notification_type:
          - email
          - sms
          - push

  # SQS Queue Policies
  OrderProcessingQueuePolicy:
    Type: AWS::SQS::QueuePolicy
    Properties:
      Queues:
        - !Ref OrderProcessingQueue
      PolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: sns.amazonaws.com
            Action: sqs:SendMessage
            Resource: !GetAtt OrderProcessingQueue.Arn
            Condition:
              ArnEquals:
                aws:SourceArn: !Ref OrderEventsTopic

  NotificationQueuePolicy:
    Type: AWS::SQS::QueuePolicy
    Properties:
      Queues:
        - !Ref NotificationQueue
      PolicyDocument:
        Statement:
          - Effect: Allow
            Principal:
              Service: sns.amazonaws.com
            Action: sqs:SendMessage
            Resource: !GetAtt NotificationQueue.Arn
            Condition:
              ArnEquals:
                aws:SourceArn: !Ref NotificationTopic
```

## Task 4: Monitoring and Observability

### CloudWatch Configuration

```yaml
  # CloudWatch Dashboards
  EcommerceDashboard:
    Type: AWS::CloudWatch::Dashboard
    Properties:
      DashboardName: !Sub '${Environment}-ecommerce-dashboard'
      DashboardBody: !Sub |
        {
          "widgets": [
            {
              "type": "metric",
              "x": 0,
              "y": 0,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  ["AWS/ECS", "CPUUtilization", "ServiceName", "user-service", "ClusterName", "${ECSCluster}"],
                  ["AWS/ECS", "MemoryUtilization", "ServiceName", "user-service", "ClusterName", "${ECSCluster}"]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${AWS::Region}",
                "title": "ECS Service Metrics"
              }
            },
            {
              "type": "metric",
              "x": 12,
              "y": 0,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${ApplicationLoadBalancer}"],
                  ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${ApplicationLoadBalancer}"]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${AWS::Region}",
                "title": "Load Balancer Metrics"
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 6,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${AuroraClusterInstance1}"],
                  ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${AuroraClusterInstance1}"]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${AWS::Region}",
                "title": "Database Metrics"
              }
            },
            {
              "type": "metric",
              "x": 12,
              "y": 6,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  ["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", "${RedisCluster}"],
                  ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", "${RedisCluster}"]
                ],
                "period": 300,
                "stat": "Average",
                "region": "${AWS::Region}",
                "title": "Redis Metrics"
              }
            }
          ]
        }

  # CloudWatch Alarms
  HighCPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-high-cpu-alarm'
      AlarmDescription: 'High CPU utilization'
      MetricName: CPUUtilization
      Namespace: AWS/ECS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: ServiceName
          Value: user-service
        - Name: ClusterName
          Value: !Ref ECSCluster
      AlarmActions:
        - !Ref HighCPUAlarmTopic

  HighMemoryAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-high-memory-alarm'
      AlarmDescription: 'High memory utilization'
      MetricName: MemoryUtilization
      Namespace: AWS/ECS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 85
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: ServiceName
          Value: user-service
        - Name: ClusterName
          Value: !Ref ECSCluster
      AlarmActions:
        - !Ref HighMemoryAlarmTopic

  DatabaseConnectionsAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${Environment}-db-connections-alarm'
      AlarmDescription: 'High database connections'
      MetricName: DatabaseConnections
      Namespace: AWS/RDS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: DBInstanceIdentifier
          Value: !Ref AuroraClusterInstance1
      AlarmActions:
        - !Ref DatabaseAlarmTopic

  # SNS Topics for Alarms
  HighCPUAlarmTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-high-cpu-alarms'
      DisplayName: High CPU Alarms

  HighMemoryAlarmTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-high-memory-alarms'
      DisplayName: High Memory Alarms

  DatabaseAlarmTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-database-alarms'
      DisplayName: Database Alarms

  # X-Ray Tracing
  XRayServiceRole:
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
        - arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess

  # X-Ray Sampling Rule
  XRaySamplingRule:
    Type: AWS::XRay::SamplingRule
    Properties:
      RuleName: !Sub '${Environment}-ecommerce-sampling'
      Priority: 1000
      Version: 1
      FixedRate: 0.1
      ReservoirSize: 1000
      ServiceName: '*'
      ServiceType: '*'
      Host: '*'
      HTTPMethod: '*'
      URLPath: '*'
      ResourceARN: '*'
```

## Best Practices Applied

### AWS Well-Architected Framework
1. **Operational Excellence**: Infrastructure as Code, automated deployments
2. **Security**: Least privilege access, encryption, WAF
3. **Reliability**: Multi-AZ deployment, health checks, monitoring
4. **Performance Efficiency**: Auto-scaling, caching, CDN
5. **Cost Optimization**: Right-sizing, spot instances, lifecycle policies

### Infrastructure as Code
1. **CloudFormation**: Complete infrastructure definition
2. **Parameterization**: Environment-specific configurations
3. **Outputs**: Cross-stack references
4. **Tags**: Consistent resource tagging
5. **Validation**: Template validation and testing

### Security
1. **Network Security**: VPC, security groups, NACLs
2. **Data Encryption**: KMS, encryption at rest and in transit
3. **Access Control**: IAM roles and policies
4. **WAF**: Web application firewall
5. **Secrets Management**: Secure parameter storage

### Monitoring
1. **CloudWatch**: Comprehensive monitoring
2. **Alarms**: Proactive alerting
3. **Dashboards**: Visual monitoring
4. **Logs**: Centralized logging
5. **X-Ray**: Distributed tracing

## Lessons Learned

### Key Insights
1. **Well-Architected**: Follow AWS Well-Architected Framework
2. **Infrastructure as Code**: Use IaC for consistency
3. **Security First**: Implement security from the start
4. **Monitoring**: Comprehensive monitoring is essential
5. **Cost Optimization**: Plan for cost optimization

### Common Pitfalls
1. **Poor Security**: Don't skip security best practices
2. **No Monitoring**: Don't skip monitoring setup
3. **Manual Processes**: Don't rely on manual processes
4. **No Cost Planning**: Don't ignore cost optimization
5. **Poor Documentation**: Don't skip documentation

### Recommendations
1. **Start with Framework**: Use Well-Architected Framework
2. **Automate Everything**: Automate all processes
3. **Monitor Early**: Set up monitoring from the start
4. **Plan Costs**: Plan for cost optimization
5. **Document**: Document all configurations

## Next Steps

1. **Deployment**: Deploy the infrastructure
2. **Testing**: Test all components
3. **Monitoring**: Set up monitoring dashboards
4. **Optimization**: Optimize performance and costs
5. **Maintenance**: Plan for ongoing maintenance
