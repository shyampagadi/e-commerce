# AWS CloudFormation Design Patterns

## Overview
AWS CloudFormation enables Infrastructure as Code (IaC) by providing a declarative way to define and provision AWS infrastructure. Understanding CloudFormation design patterns is essential for building scalable, maintainable, and repeatable infrastructure deployments.

## Template Structure Patterns

### Modular Template Design
```yaml
# Master template pattern
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Master template for multi-tier application'

Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, test, prod]
    Default: dev
  
  VPCStackName:
    Type: String
    Description: Name of the VPC stack
  
  DatabaseStackName:
    Type: String
    Description: Name of the database stack

Resources:
  # Nested stack for compute resources
  ComputeStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub 'https://s3.amazonaws.com/templates/compute-${Environment}.yaml'
      Parameters:
        VPCId: !ImportValue 
          Fn::Sub: '${VPCStackName}-VPC-ID'
        PrivateSubnets: !ImportValue
          Fn::Sub: '${VPCStackName}-Private-Subnets'
        Environment: !Ref Environment

  # Nested stack for application resources
  ApplicationStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: ComputeStack
    Properties:
      TemplateURL: !Sub 'https://s3.amazonaws.com/templates/application-${Environment}.yaml'
      Parameters:
        ComputeStackName: !GetAtt ComputeStack.Outputs.StackName
        DatabaseEndpoint: !ImportValue
          Fn::Sub: '${DatabaseStackName}-Database-Endpoint'

Outputs:
  ApplicationURL:
    Description: Application Load Balancer URL
    Value: !GetAtt ApplicationStack.Outputs.LoadBalancerURL
    Export:
      Name: !Sub '${AWS::StackName}-Application-URL'
```

### Cross-Stack Reference Pattern
```python
class CloudFormationCrossStackReferences:
    def __init__(self):
        self.reference_patterns = {
            'export_import': 'Use Outputs/Exports and ImportValue',
            'parameter_passing': 'Pass values through nested stack parameters',
            'ssm_parameters': 'Store values in Systems Manager Parameter Store',
            'resource_lookup': 'Use custom resources for dynamic lookups'
        }
    
    def design_cross_stack_architecture(self, application_tiers):
        """Design cross-stack reference architecture"""
        
        stack_design = {
            'foundation_stack': {
                'purpose': 'VPC, subnets, security groups',
                'exports': [
                    'VPC-ID',
                    'Public-Subnets',
                    'Private-Subnets',
                    'Database-Subnets',
                    'Security-Groups'
                ],
                'dependencies': []
            },
            'security_stack': {
                'purpose': 'IAM roles, KMS keys, certificates',
                'exports': [
                    'Application-Role-ARN',
                    'Database-Role-ARN',
                    'KMS-Key-ID',
                    'SSL-Certificate-ARN'
                ],
                'dependencies': []
            },
            'database_stack': {
                'purpose': 'RDS, ElastiCache, DynamoDB',
                'exports': [
                    'Database-Endpoint',
                    'Database-Port',
                    'Cache-Endpoint',
                    'DynamoDB-Table-Name'
                ],
                'dependencies': ['foundation_stack', 'security_stack']
            },
            'compute_stack': {
                'purpose': 'EC2, Auto Scaling, Load Balancers',
                'exports': [
                    'Load-Balancer-ARN',
                    'Load-Balancer-DNS',
                    'Auto-Scaling-Group-Name'
                ],
                'dependencies': ['foundation_stack', 'security_stack']
            },
            'application_stack': {
                'purpose': 'Application-specific resources',
                'exports': [
                    'Application-URL',
                    'API-Gateway-URL',
                    'CloudFront-Distribution'
                ],
                'dependencies': ['compute_stack', 'database_stack']
            }
        }
        
        return stack_design
```

## Resource Organization Patterns

### Environment-Specific Templates
```yaml
# Environment configuration pattern
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, test, prod]
    Default: dev

Mappings:
  EnvironmentConfig:
    dev:
      InstanceType: t3.micro
      MinSize: 1
      MaxSize: 2
      DatabaseInstanceClass: db.t3.micro
      DatabaseAllocatedStorage: 20
    test:
      InstanceType: t3.small
      MinSize: 1
      MaxSize: 3
      DatabaseInstanceClass: db.t3.small
      DatabaseAllocatedStorage: 50
    prod:
      InstanceType: t3.medium
      MinSize: 2
      MaxSize: 10
      DatabaseInstanceClass: db.r5.large
      DatabaseAllocatedStorage: 100

Resources:
  WebServerLaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub '${AWS::StackName}-web-server'
      LaunchTemplateData:
        InstanceType: !FindInMap [EnvironmentConfig, !Ref Environment, InstanceType]
        ImageId: !Ref LatestAmiId
        SecurityGroupIds:
          - !Ref WebServerSecurityGroup
        IamInstanceProfile:
          Arn: !GetAtt WebServerInstanceProfile.Arn

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: !FindInMap [EnvironmentConfig, !Ref Environment, MinSize]
      MaxSize: !FindInMap [EnvironmentConfig, !Ref Environment, MaxSize]
      DesiredCapacity: !FindInMap [EnvironmentConfig, !Ref Environment, MinSize]
      LaunchTemplate:
        LaunchTemplateId: !Ref WebServerLaunchTemplate
        Version: !GetAtt WebServerLaunchTemplate.LatestVersionNumber
```

### Conditional Resource Creation
```yaml
# Conditional resources pattern
Parameters:
  CreateDatabase:
    Type: String
    AllowedValues: ['true', 'false']
    Default: 'true'
    Description: Whether to create RDS database
  
  EnableMultiAZ:
    Type: String
    AllowedValues: ['true', 'false']
    Default: 'false'
    Description: Enable Multi-AZ for RDS

Conditions:
  ShouldCreateDatabase: !Equals [!Ref CreateDatabase, 'true']
  IsProduction: !Equals [!Ref Environment, 'prod']
  EnableMultiAZCondition: !And
    - !Condition ShouldCreateDatabase
    - !Or
      - !Condition IsProduction
      - !Equals [!Ref EnableMultiAZ, 'true']

Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Condition: ShouldCreateDatabase
    Properties:
      DBInstanceClass: !FindInMap [EnvironmentConfig, !Ref Environment, DatabaseInstanceClass]
      Engine: mysql
      MasterUsername: admin
      MasterUserPassword: !Ref DatabasePassword
      AllocatedStorage: !FindInMap [EnvironmentConfig, !Ref Environment, DatabaseAllocatedStorage]
      MultiAZ: !If [EnableMultiAZCondition, true, false]
      BackupRetentionPeriod: !If [IsProduction, 30, 7]
      DeletionProtection: !If [IsProduction, true, false]

Outputs:
  DatabaseEndpoint:
    Condition: ShouldCreateDatabase
    Description: RDS Database Endpoint
    Value: !GetAtt Database.Endpoint.Address
    Export:
      Name: !Sub '${AWS::StackName}-Database-Endpoint'
```

## Security Patterns

### IAM Role and Policy Management
```yaml
# IAM security pattern
Resources:
  # Application execution role
  ApplicationExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${AWS::StackName}-application-execution-role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
      Policies:
        - PolicyName: ApplicationSpecificPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                Resource: !Sub '${ApplicationBucket}/*'
              - Effect: Allow
                Action:
                  - dynamodb:GetItem
                  - dynamodb:PutItem
                  - dynamodb:UpdateItem
                  - dynamodb:DeleteItem
                Resource: !GetAtt ApplicationTable.Arn

  # Cross-account access role
  CrossAccountAccessRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${AWS::StackName}-cross-account-access'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${TrustedAccountId}:root'
            Action: sts:AssumeRole
            Condition:
              StringEquals:
                'sts:ExternalId': !Ref ExternalId
      Policies:
        - PolicyName: LimitedAccessPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:ListBucket
                  - s3:GetObject
                Resource:
                  - !GetAtt SharedBucket.Arn
                  - !Sub '${SharedBucket}/*'
```

### Encryption and Key Management
```yaml
# KMS encryption pattern
Resources:
  # Application-specific KMS key
  ApplicationKMSKey:
    Type: AWS::KMS::Key
    Properties:
      Description: !Sub 'KMS Key for ${AWS::StackName} application'
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow application role to use the key
            Effect: Allow
            Principal:
              AWS: !GetAtt ApplicationExecutionRole.Arn
            Action:
              - kms:Encrypt
              - kms:Decrypt
              - kms:ReEncrypt*
              - kms:GenerateDataKey*
              - kms:DescribeKey
            Resource: '*'

  ApplicationKMSKeyAlias:
    Type: AWS::KMS::Alias
    Properties:
      AliasName: !Sub 'alias/${AWS::StackName}-application-key'
      TargetKeyId: !Ref ApplicationKMSKey

  # Encrypted S3 bucket
  EncryptedBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-encrypted-bucket-${AWS::AccountId}'
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !Ref ApplicationKMSKey
            BucketKeyEnabled: true
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
```

## Automation and CI/CD Patterns

### Pipeline Integration
```python
class CloudFormationCICD:
    def __init__(self):
        self.pipeline_stages = {
            'validate': 'Template syntax and policy validation',
            'test': 'Deploy to test environment',
            'security_scan': 'Security and compliance scanning',
            'approve': 'Manual approval for production',
            'deploy': 'Production deployment',
            'monitor': 'Post-deployment monitoring'
        }
    
    def create_pipeline_template(self, application_config):
        """Create CI/CD pipeline template for CloudFormation"""
        
        pipeline_template = {
            'AWSTemplateFormatVersion': '2010-09-09',
            'Description': 'CI/CD Pipeline for CloudFormation deployments',
            'Parameters': {
                'GitHubRepo': {'Type': 'String'},
                'GitHubBranch': {'Type': 'String', 'Default': 'main'},
                'GitHubToken': {'Type': 'String', 'NoEcho': True}
            },
            'Resources': {
                'CodePipeline': {
                    'Type': 'AWS::CodePipeline::Pipeline',
                    'Properties': {
                        'RoleArn': {'Fn::GetAtt': ['CodePipelineRole', 'Arn']},
                        'Stages': [
                            {
                                'Name': 'Source',
                                'Actions': [{
                                    'Name': 'SourceAction',
                                    'ActionTypeId': {
                                        'Category': 'Source',
                                        'Owner': 'ThirdParty',
                                        'Provider': 'GitHub',
                                        'Version': '1'
                                    },
                                    'Configuration': {
                                        'Owner': {'Ref': 'GitHubOwner'},
                                        'Repo': {'Ref': 'GitHubRepo'},
                                        'Branch': {'Ref': 'GitHubBranch'},
                                        'OAuthToken': {'Ref': 'GitHubToken'}
                                    },
                                    'OutputArtifacts': [{'Name': 'SourceOutput'}]
                                }]
                            },
                            {
                                'Name': 'Validate',
                                'Actions': [{
                                    'Name': 'ValidateTemplate',
                                    'ActionTypeId': {
                                        'Category': 'Build',
                                        'Owner': 'AWS',
                                        'Provider': 'CodeBuild',
                                        'Version': '1'
                                    },
                                    'Configuration': {
                                        'ProjectName': {'Ref': 'ValidationProject'}
                                    },
                                    'InputArtifacts': [{'Name': 'SourceOutput'}]
                                }]
                            },
                            {
                                'Name': 'Deploy-Test',
                                'Actions': [{
                                    'Name': 'DeployToTest',
                                    'ActionTypeId': {
                                        'Category': 'Deploy',
                                        'Owner': 'AWS',
                                        'Provider': 'CloudFormation',
                                        'Version': '1'
                                    },
                                    'Configuration': {
                                        'ActionMode': 'CREATE_UPDATE',
                                        'StackName': f"{application_config['name']}-test",
                                        'TemplatePath': 'SourceOutput::template.yaml',
                                        'Capabilities': 'CAPABILITY_IAM',
                                        'RoleArn': {'Fn::GetAtt': ['CloudFormationRole', 'Arn']},
                                        'ParameterOverrides': '{"Environment": "test"}'
                                    },
                                    'InputArtifacts': [{'Name': 'SourceOutput'}]
                                }]
                            }
                        ]
                    }
                }
            }
        }
        
        return pipeline_template
```

### Change Set Management
```yaml
# Change set pattern for safe deployments
Resources:
  ProductionChangeSet:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub 'https://s3.amazonaws.com/templates/${TemplateName}'
      Parameters:
        Environment: prod
        ChangeSetName: !Sub '${AWS::StackName}-changeset-${BuildNumber}'
      Tags:
        - Key: Environment
          Value: prod
        - Key: ChangeSet
          Value: !Sub '${BuildNumber}'

  # Custom resource for change set approval
  ChangeSetApproval:
    Type: AWS::CloudFormation::CustomResource
    Properties:
      ServiceToken: !GetAtt ChangeSetApprovalFunction.Arn
      StackName: !Ref ProductionChangeSet
      ChangeSetName: !Sub '${AWS::StackName}-changeset-${BuildNumber}'
      ApprovalRequired: true

  ChangeSetApprovalFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub '${AWS::StackName}-changeset-approval'
      Runtime: python3.9
      Handler: index.handler
      Role: !GetAtt ChangeSetApprovalRole.Arn
      Code:
        ZipFile: |
          import boto3
          import json
          
          def handler(event, context):
              cf = boto3.client('cloudformation')
              
              if event['RequestType'] == 'Create':
                  # Create change set
                  response = cf.create_change_set(
                      StackName=event['ResourceProperties']['StackName'],
                      ChangeSetName=event['ResourceProperties']['ChangeSetName'],
                      TemplateURL=event['ResourceProperties']['TemplateURL'],
                      Parameters=event['ResourceProperties']['Parameters']
                  )
                  
                  # Send approval notification
                  sns = boto3.client('sns')
                  sns.publish(
                      TopicArn=event['ResourceProperties']['ApprovalTopic'],
                      Subject='CloudFormation Change Set Approval Required',
                      Message=f"Change set {response['Id']} is ready for review"
                  )
              
              return {'Status': 'SUCCESS', 'PhysicalResourceId': 'changeset-approval'}
```

## Monitoring and Observability Patterns

### CloudWatch Integration
```yaml
# Monitoring pattern
Resources:
  # Custom metrics for application
  ApplicationMetricFilter:
    Type: AWS::Logs::MetricFilter
    Properties:
      LogGroupName: !Ref ApplicationLogGroup
      FilterPattern: '[timestamp, request_id, level="ERROR", ...]'
      MetricTransformations:
        - MetricNamespace: !Sub '${AWS::StackName}/Application'
          MetricName: ErrorCount
          MetricValue: '1'
          DefaultValue: 0

  # CloudWatch Dashboard
  ApplicationDashboard:
    Type: AWS::CloudWatch::Dashboard
    Properties:
      DashboardName: !Sub '${AWS::StackName}-dashboard'
      DashboardBody: !Sub |
        {
          "widgets": [
            {
              "type": "metric",
              "properties": {
                "metrics": [
                  ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${LoadBalancer.LoadBalancerFullName}"],
                  ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${LoadBalancer.LoadBalancerFullName}"],
                  ["${AWS::StackName}/Application", "ErrorCount"]
                ],
                "period": 300,
                "stat": "Sum",
                "region": "${AWS::Region}",
                "title": "Application Metrics"
              }
            }
          ]
        }

  # CloudWatch Alarms
  HighErrorRateAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: !Sub '${AWS::StackName}-high-error-rate'
      AlarmDescription: 'High error rate detected'
      MetricName: ErrorCount
      Namespace: !Sub '${AWS::StackName}/Application'
      Statistic: Sum
      Period: 300
      EvaluationPeriods: 2
      Threshold: 10
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref AlertTopic
```

## Best Practices

### Template Organization
```python
class CloudFormationBestPractices:
    def __init__(self):
        self.organization_principles = {
            'single_responsibility': 'Each template should have a single purpose',
            'reusability': 'Design templates for reuse across environments',
            'modularity': 'Break complex infrastructure into smaller templates',
            'parameterization': 'Use parameters for environment-specific values',
            'documentation': 'Include comprehensive descriptions and metadata'
        }
    
    def template_validation_checklist(self):
        """Provide template validation checklist"""
        
        checklist = {
            'structure': [
                'Valid JSON/YAML syntax',
                'Required sections present (Resources)',
                'Proper parameter types and constraints',
                'Meaningful resource names and descriptions'
            ],
            'security': [
                'No hardcoded credentials',
                'Least privilege IAM policies',
                'Encryption enabled where appropriate',
                'Secure parameter handling (NoEcho)'
            ],
            'reliability': [
                'Proper error handling',
                'Resource dependencies defined',
                'Rollback configuration',
                'Health checks and monitoring'
            ],
            'maintainability': [
                'Clear naming conventions',
                'Comprehensive documentation',
                'Version control integration',
                'Change management process'
            ],
            'cost_optimization': [
                'Appropriate resource sizing',
                'Lifecycle policies configured',
                'Unused resources cleaned up',
                'Cost allocation tags applied'
            ]
        }
        
        return checklist
    
    def generate_template_metadata(self, template_info):
        """Generate comprehensive template metadata"""
        
        metadata = {
            'AWS::CloudFormation::Interface': {
                'ParameterGroups': [
                    {
                        'Label': {'default': 'Network Configuration'},
                        'Parameters': ['VPCId', 'SubnetIds', 'SecurityGroupIds']
                    },
                    {
                        'Label': {'default': 'Application Configuration'},
                        'Parameters': ['Environment', 'InstanceType', 'KeyPairName']
                    }
                ],
                'ParameterLabels': {
                    'VPCId': {'default': 'VPC ID'},
                    'SubnetIds': {'default': 'Subnet IDs'},
                    'Environment': {'default': 'Environment Name'}
                }
            },
            'AWS::CloudFormation::Designer': {
                'ApplicationServer': {'id': 'app-server-id'},
                'Database': {'id': 'database-id'}
            }
        }
        
        return metadata
```

## Conclusion

AWS CloudFormation design patterns provide the foundation for building robust, scalable, and maintainable Infrastructure as Code solutions. Success requires understanding template organization, implementing proper security measures, integrating with CI/CD pipelines, and following best practices for resource management. The key is to design templates that are modular, reusable, and aligned with operational requirements while maintaining security and compliance standards.
