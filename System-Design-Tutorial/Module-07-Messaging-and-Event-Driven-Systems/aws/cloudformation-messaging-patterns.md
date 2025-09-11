# CloudFormation Messaging Patterns

## Overview
This guide provides comprehensive CloudFormation templates and patterns for deploying production-ready messaging architectures on AWS, including infrastructure as code best practices, parameter management, and deployment automation.

## Template Architecture Patterns

### Pattern 1: Event-Driven Microservices Stack
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Complete event-driven microservices messaging infrastructure'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
    Description: Environment name
    
  MessageRetentionDays:
    Type: Number
    Default: 14
    MinValue: 1
    MaxValue: 14
    Description: Message retention period in days
    
  EnableEncryption:
    Type: String
    Default: 'true'
    AllowedValues: ['true', 'false']
    Description: Enable KMS encryption for messages

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  EncryptionEnabled: !Equals [!Ref EnableEncryption, 'true']

Resources:
  # KMS Key for Message Encryption
  MessageEncryptionKey:
    Type: AWS::KMS::Key
    Condition: EncryptionEnabled
    Properties:
      Description: !Sub 'Message encryption key for ${Environment}'
      KeyPolicy:
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow SQS and SNS
            Effect: Allow
            Principal:
              Service: 
                - sqs.amazonaws.com
                - sns.amazonaws.com
            Action:
              - kms:Decrypt
              - kms:GenerateDataKey
            Resource: '*'

  MessageEncryptionKeyAlias:
    Type: AWS::KMS::Alias
    Condition: EncryptionEnabled
    Properties:
      AliasName: !Sub 'alias/messaging-${Environment}'
      TargetKeyId: !Ref MessageEncryptionKey

  # EventBridge Custom Bus
  EventBus:
    Type: AWS::Events::EventBus
    Properties:
      Name: !Sub '${Environment}-microservices-events'
      Description: 'Custom event bus for microservices communication'

  # SNS Topics for Fan-out Messaging
  OrderEventsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-order-events'
      DisplayName: 'Order Events Topic'
      KmsMasterKeyId: !If 
        - EncryptionEnabled
        - !Ref MessageEncryptionKey
        - !Ref AWS::NoValue

  UserEventsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: !Sub '${Environment}-user-events'
      DisplayName: 'User Events Topic'
      KmsMasterKeyId: !If 
        - EncryptionEnabled
        - !Ref MessageEncryptionKey
        - !Ref AWS::NoValue

  # SQS Queues for Service-to-Service Communication
  OrderProcessingQueue:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing'
      VisibilityTimeoutSeconds: 300
      MessageRetentionPeriod: !Ref MessageRetentionDays
      KmsMasterKeyId: !If 
        - EncryptionEnabled
        - !Ref MessageEncryptionKey
        - !Ref AWS::NoValue
      RedrivePolicy:
        deadLetterTargetArn: !GetAtt OrderProcessingDLQ.Arn
        maxReceiveCount: 3

  OrderProcessingDLQ:
    Type: AWS::SQS::Queue
    Properties:
      QueueName: !Sub '${Environment}-order-processing-dlq'
      MessageRetentionPeriod: 1209600  # 14 days
      KmsMasterKeyId: !If 
        - EncryptionEnabled
        - !Ref MessageEncryptionKey
        - !Ref AWS::NoValue

  # EventBridge Rules for Event Routing
  OrderCreatedRule:
    Type: AWS::Events::Rule
    Properties:
      Name: !Sub '${Environment}-order-created-rule'
      Description: 'Route order created events'
      EventBusName: !Ref EventBus
      EventPattern:
        source: ['order-service']
        detail-type: ['Order Created']
      Targets:
        - Arn: !GetAtt OrderProcessingQueue.Arn
          Id: 'OrderProcessingTarget'
          SqsParameters:
            MessageGroupId: 'order-processing'

  # IAM Roles and Policies
  MessageProducerRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${Environment}-message-producer-role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: 
                - lambda.amazonaws.com
                - ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: MessageProducerPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - sqs:SendMessage
                  - sqs:SendMessageBatch
                  - sns:Publish
                  - events:PutEvents
                Resource:
                  - !GetAtt OrderProcessingQueue.Arn
                  - !Ref OrderEventsTopic
                  - !Ref UserEventsTopic
                  - !GetAtt EventBus.Arn
              - !If
                - EncryptionEnabled
                - Effect: Allow
                  Action:
                    - kms:Decrypt
                    - kms:GenerateDataKey
                  Resource: !GetAtt MessageEncryptionKey.Arn
                - !Ref AWS::NoValue

Outputs:
  EventBusArn:
    Description: 'EventBridge custom bus ARN'
    Value: !GetAtt EventBus.Arn
    Export:
      Name: !Sub '${Environment}-EventBusArn'
      
  OrderProcessingQueueUrl:
    Description: 'Order processing queue URL'
    Value: !Ref OrderProcessingQueue
    Export:
      Name: !Sub '${Environment}-OrderProcessingQueueUrl'
      
  MessageEncryptionKeyId:
    Condition: EncryptionEnabled
    Description: 'KMS key ID for message encryption'
    Value: !Ref MessageEncryptionKey
    Export:
      Name: !Sub '${Environment}-MessageEncryptionKeyId'
```

### Pattern 2: High-Throughput Streaming Stack
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'High-throughput streaming infrastructure with Kinesis and MSK'

Parameters:
  StreamShardCount:
    Type: Number
    Default: 10
    MinValue: 1
    MaxValue: 1000
    Description: Number of shards for Kinesis stream
    
  KafkaInstanceType:
    Type: String
    Default: kafka.m5.large
    AllowedValues: 
      - kafka.t3.small
      - kafka.m5.large
      - kafka.m5.xlarge
      - kafka.m5.2xlarge
    Description: MSK broker instance type

Resources:
  # Kinesis Data Stream
  EventStream:
    Type: AWS::Kinesis::Stream
    Properties:
      Name: !Sub '${AWS::StackName}-event-stream'
      ShardCount: !Ref StreamShardCount
      RetentionPeriodHours: 168  # 7 days
      StreamEncryption:
        EncryptionType: KMS
        KeyId: alias/aws/kinesis

  # MSK Cluster Configuration
  MSKClusterConfig:
    Type: AWS::MSK::Configuration
    Properties:
      Name: !Sub '${AWS::StackName}-msk-config'
      Description: 'Optimized MSK configuration for high throughput'
      ServerProperties: |
        auto.create.topics.enable=false
        default.replication.factor=3
        min.insync.replicas=2
        num.partitions=12
        log.retention.hours=168
        log.segment.bytes=1073741824
        compression.type=snappy
        batch.size=65536
        linger.ms=10

  # MSK Cluster
  MSKCluster:
    Type: AWS::MSK::Cluster
    Properties:
      ClusterName: !Sub '${AWS::StackName}-msk-cluster'
      KafkaVersion: '2.8.1'
      NumberOfBrokerNodes: 3
      BrokerNodeGroupInfo:
        InstanceType: !Ref KafkaInstanceType
        ClientSubnets:
          - !Ref PrivateSubnet1
          - !Ref PrivateSubnet2
          - !Ref PrivateSubnet3
        SecurityGroups:
          - !Ref MSKSecurityGroup
        StorageInfo:
          EBSStorageInfo:
            VolumeSize: 1000
      ConfigurationInfo:
        Arn: !Ref MSKClusterConfig
        Revision: 1
      EncryptionInfo:
        EncryptionInTransit:
          ClientBroker: TLS
          InCluster: true
        EncryptionAtRest:
          DataVolumeKMSKeyId: !Ref MSKEncryptionKey

  # Kinesis Analytics Application
  AnalyticsApplication:
    Type: AWS::KinesisAnalytics::Application
    Properties:
      ApplicationName: !Sub '${AWS::StackName}-analytics'
      ApplicationDescription: 'Real-time stream analytics'
      ApplicationCode: |
        CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
          event_type VARCHAR(50),
          event_count INTEGER,
          window_start TIMESTAMP,
          window_end TIMESTAMP
        );
        
        CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
        SELECT STREAM 
          event_type,
          COUNT(*) as event_count,
          ROWTIME_TO_TIMESTAMP(RANGE_START) as window_start,
          ROWTIME_TO_TIMESTAMP(RANGE_END) as window_end
        FROM SOURCE_SQL_STREAM_001
        WINDOW RANGE INTERVAL '1' MINUTE
        GROUP BY event_type;
      Inputs:
        - NamePrefix: 'SOURCE_SQL_STREAM'
          KinesisStreamsInput:
            ResourceARN: !GetAtt EventStream.Arn
            RoleARN: !GetAtt AnalyticsRole.Arn
          InputSchema:
            RecordColumns:
              - Name: 'event_type'
                SqlType: 'VARCHAR(50)'
                Mapping: '$.eventType'
              - Name: 'timestamp'
                SqlType: 'TIMESTAMP'
                Mapping: '$.timestamp'
            RecordFormat:
              RecordFormatType: 'JSON'
```

### Pattern 3: Event Sourcing Infrastructure
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Event sourcing infrastructure with DynamoDB and Lambda'

Resources:
  # Event Store Table
  EventStoreTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${AWS::StackName}-event-store'
      BillingMode: ON_DEMAND
      AttributeDefinitions:
        - AttributeName: aggregate_id
          AttributeType: S
        - AttributeName: version
          AttributeType: N
        - AttributeName: event_type
          AttributeType: S
        - AttributeName: timestamp
          AttributeType: S
      KeySchema:
        - AttributeName: aggregate_id
          KeyType: HASH
        - AttributeName: version
          KeyType: RANGE
      GlobalSecondaryIndexes:
        - IndexName: event-type-timestamp-index
          KeySchema:
            - AttributeName: event_type
              KeyType: HASH
            - AttributeName: timestamp
              KeyType: RANGE
          Projection:
            ProjectionType: ALL
      StreamSpecification:
        StreamViewType: NEW_AND_OLD_IMAGES
      PointInTimeRecoverySpecification:
        PointInTimeRecoveryEnabled: true
      SSESpecification:
        SSEEnabled: true

  # Snapshots Table
  SnapshotsTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${AWS::StackName}-snapshots'
      BillingMode: ON_DEMAND
      AttributeDefinitions:
        - AttributeName: aggregate_id
          AttributeType: S
        - AttributeName: version
          AttributeType: N
      KeySchema:
        - AttributeName: aggregate_id
          KeyType: HASH
        - AttributeName: version
          KeyType: RANGE
      SSESpecification:
        SSEEnabled: true

  # Read Models Table
  ReadModelsTable:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Sub '${AWS::StackName}-read-models'
      BillingMode: ON_DEMAND
      AttributeDefinitions:
        - AttributeName: model_id
          AttributeType: S
        - AttributeName: entity_id
          AttributeType: S
      KeySchema:
        - AttributeName: model_id
          KeyType: HASH
        - AttributeName: entity_id
          KeyType: RANGE
      SSESpecification:
        SSEEnabled: true

  # Event Processor Lambda
  EventProcessor:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${AWS::StackName}-event-processor'
      Runtime: python3.9
      Handler: index.handler
      Code:
        ZipFile: |
          import json
          import boto3
          
          def handler(event, context):
              dynamodb = boto3.resource('dynamodb')
              read_models_table = dynamodb.Table(os.environ['READ_MODELS_TABLE'])
              
              for record in event['Records']:
                  if record['eventName'] in ['INSERT', 'MODIFY']:
                      process_event(record['dynamodb'], read_models_table)
              
              return {'statusCode': 200}
          
          def process_event(event_data, table):
              # Process DynamoDB stream event and update read models
              pass
      Environment:
        Variables:
          READ_MODELS_TABLE: !Ref ReadModelsTable
      Role: !GetAtt EventProcessorRole.Arn

  # DynamoDB Stream Event Source Mapping
  EventSourceMapping:
    Type: AWS::Lambda::EventSourceMapping
    Properties:
      EventSourceArn: !GetAtt EventStoreTable.StreamArn
      FunctionName: !Ref EventProcessor
      StartingPosition: LATEST
      BatchSize: 100
      MaximumBatchingWindowInSeconds: 5
```

## Deployment Automation

### Multi-Environment Deployment Pipeline
```yaml
# CodePipeline for automated deployment
DeploymentPipeline:
  Type: AWS::CodePipeline::Pipeline
  Properties:
    Name: !Sub '${AWS::StackName}-messaging-pipeline'
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
              Owner: AWS
              Provider: S3
              Version: '1'
            Configuration:
              S3Bucket: !Ref SourceBucket
              S3ObjectKey: messaging-templates.zip
            OutputArtifacts:
              - Name: SourceOutput

      - Name: ValidateTemplates
        Actions:
          - Name: ValidateAction
            ActionTypeId:
              Category: Invoke
              Owner: AWS
              Provider: Lambda
              Version: '1'
            Configuration:
              FunctionName: !Ref TemplateValidatorFunction
            InputArtifacts:
              - Name: SourceOutput

      - Name: DeployDev
        Actions:
          - Name: DeployDevAction
            ActionTypeId:
              Category: Deploy
              Owner: AWS
              Provider: CloudFormation
              Version: '1'
            Configuration:
              ActionMode: CREATE_UPDATE
              StackName: messaging-dev
              TemplatePath: SourceOutput::messaging-stack.yaml
              Capabilities: CAPABILITY_IAM
              ParameterOverrides: |
                {
                  "Environment": "dev",
                  "MessageRetentionDays": "7"
                }
            InputArtifacts:
              - Name: SourceOutput

      - Name: DeployProd
        Actions:
          - Name: ApprovalAction
            ActionTypeId:
              Category: Approval
              Owner: AWS
              Provider: Manual
              Version: '1'
            Configuration:
              CustomData: 'Please review and approve production deployment'
          
          - Name: DeployProdAction
            ActionTypeId:
              Category: Deploy
              Owner: AWS
              Provider: CloudFormation
              Version: '1'
            Configuration:
              ActionMode: CREATE_UPDATE
              StackName: messaging-prod
              TemplatePath: SourceOutput::messaging-stack.yaml
              Capabilities: CAPABILITY_IAM
              ParameterOverrides: |
                {
                  "Environment": "prod",
                  "MessageRetentionDays": "14",
                  "EnableEncryption": "true"
                }
            InputArtifacts:
              - Name: SourceOutput
            RunOrder: 2
```

### Template Validation Function
```python
import boto3
import json

def lambda_handler(event, context):
    """Validate CloudFormation templates before deployment"""
    
    codepipeline = boto3.client('codepipeline')
    cloudformation = boto3.client('cloudformation')
    
    job_id = event['CodePipeline.job']['id']
    
    try:
        # Get input artifacts
        input_artifacts = event['CodePipeline.job']['data']['inputArtifacts']
        location = input_artifacts[0]['location']['s3Location']
        
        # Download and validate template
        s3 = boto3.client('s3')
        template_obj = s3.get_object(
            Bucket=location['bucketName'],
            Key=location['objectKey']
        )
        
        template_body = template_obj['Body'].read().decode('utf-8')
        
        # Validate template syntax
        response = cloudformation.validate_template(
            TemplateBody=template_body
        )
        
        # Additional custom validations
        template_data = json.loads(template_body) if template_body.strip().startswith('{') else None
        
        if template_data:
            validate_security_requirements(template_data)
            validate_naming_conventions(template_data)
            validate_resource_limits(template_data)
        
        # Signal success
        codepipeline.put_job_success_result(jobId=job_id)
        
    except Exception as e:
        # Signal failure
        codepipeline.put_job_failure_result(
            jobId=job_id,
            failureDetails={'message': str(e)}
        )
    
    return {'statusCode': 200}

def validate_security_requirements(template):
    """Validate security requirements in template"""
    
    resources = template.get('Resources', {})
    
    # Check SQS queues have encryption
    for resource_name, resource in resources.items():
        if resource.get('Type') == 'AWS::SQS::Queue':
            properties = resource.get('Properties', {})
            if 'KmsMasterKeyId' not in properties:
                raise ValueError(f"SQS Queue {resource_name} must have encryption enabled")
    
    # Check SNS topics have encryption
    for resource_name, resource in resources.items():
        if resource.get('Type') == 'AWS::SNS::Topic':
            properties = resource.get('Properties', {})
            if 'KmsMasterKeyId' not in properties:
                raise ValueError(f"SNS Topic {resource_name} must have encryption enabled")
```

## Monitoring and Observability Templates

### CloudWatch Dashboard Template
```yaml
MessagingDashboard:
  Type: AWS::CloudWatch::Dashboard
  Properties:
    DashboardName: !Sub '${Environment}-messaging-dashboard'
    DashboardBody: !Sub |
      {
        "widgets": [
          {
            "type": "metric",
            "properties": {
              "metrics": [
                ["AWS/SQS", "NumberOfMessagesSent", "QueueName", "${OrderProcessingQueue}"],
                [".", "NumberOfMessagesReceived", ".", "."],
                [".", "ApproximateNumberOfVisibleMessages", ".", "."]
              ],
              "period": 300,
              "stat": "Sum",
              "region": "${AWS::Region}",
              "title": "SQS Metrics"
            }
          },
          {
            "type": "metric", 
            "properties": {
              "metrics": [
                ["AWS/SNS", "NumberOfMessagesPublished", "TopicName", "${OrderEventsTopic}"],
                [".", "NumberOfNotificationsFailed", ".", "."]
              ],
              "period": 300,
              "stat": "Sum",
              "region": "${AWS::Region}",
              "title": "SNS Metrics"
            }
          }
        ]
      }
```

This comprehensive CloudFormation guide provides production-ready templates for deploying scalable, secure messaging infrastructure with proper automation and monitoring capabilities.
