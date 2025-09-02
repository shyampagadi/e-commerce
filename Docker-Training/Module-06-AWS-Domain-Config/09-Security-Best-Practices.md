# Security Best Practices

## Overview
Comprehensive AWS security practices for production deployments.

## IAM Security

### Principle of Least Privilege
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2ReadOnlyAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeSecurityGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3BucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::my-app-bucket/*"
        }
    ]
}
```

### Role-Based Access
```yaml
# Application role for EC2 instances
ApplicationRole:
  Type: AWS::IAM::Role
  Properties:
    RoleName: MyApp-EC2-Role
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
      - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    Policies:
      - PolicyName: ApplicationPolicy
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:PutObject
              Resource: !Sub "${S3Bucket}/*"
            - Effect: Allow
              Action:
                - secretsmanager:GetSecretValue
              Resource: !Ref DatabaseSecret

ApplicationInstanceProfile:
  Type: AWS::IAM::InstanceProfile
  Properties:
    Roles:
      - !Ref ApplicationRole
```

### MFA Enforcement
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowViewAccountInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountPasswordPolicy",
                "iam:ListVirtualMFADevices"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowManageOwnPasswords",
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:GetUser"
            ],
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        },
        {
            "Sid": "AllowManageOwnMFA",
            "Effect": "Allow",
            "Action": [
                "iam:CreateVirtualMFADevice",
                "iam:DeleteVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:ListMFADevices",
                "iam:ResyncMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/${aws:username}",
                "arn:aws:iam::*:user/${aws:username}"
            ]
        },
        {
            "Sid": "DenyAllExceptUnlessSignedInWithMFA",
            "Effect": "Deny",
            "NotAction": [
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:GetUser",
                "iam:ListMFADevices",
                "iam:ListVirtualMFADevices",
                "iam:ResyncMFADevice",
                "sts:GetSessionToken"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
```

## Network Security

### VPC Security Groups
```yaml
WebServerSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for web servers
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        SourceSecurityGroupId: !Ref LoadBalancerSecurityGroup
        Description: HTTP from load balancer
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        SourceSecurityGroupId: !Ref LoadBalancerSecurityGroup
        Description: HTTPS from load balancer
      - IpProtocol: tcp
        FromPort: 22
        ToPort: 22
        SourceSecurityGroupId: !Ref BastionSecurityGroup
        Description: SSH from bastion host
    SecurityGroupEgress:
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 0.0.0.0/0
        Description: HTTPS outbound
      - IpProtocol: tcp
        FromPort: 5432
        ToPort: 5432
        DestinationSecurityGroupId: !Ref DatabaseSecurityGroup
        Description: PostgreSQL to database

DatabaseSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for database
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 5432
        ToPort: 5432
        SourceSecurityGroupId: !Ref WebServerSecurityGroup
        Description: PostgreSQL from web servers
    Tags:
      - Key: Name
        Value: Database-SG
```

### Network ACLs
```yaml
PrivateNetworkAcl:
  Type: AWS::EC2::NetworkAcl
  Properties:
    VpcId: !Ref VPC
    Tags:
      - Key: Name
        Value: Private-NACL

PrivateInboundRule:
  Type: AWS::EC2::NetworkAclEntry
  Properties:
    NetworkAclId: !Ref PrivateNetworkAcl
    RuleNumber: 100
    Protocol: 6
    RuleAction: allow
    CidrBlock: 10.0.0.0/16
    PortRange:
      From: 1024
      To: 65535

PrivateOutboundRule:
  Type: AWS::EC2::NetworkAclEntry
  Properties:
    NetworkAclId: !Ref PrivateNetworkAcl
    RuleNumber: 100
    Protocol: 6
    Egress: true
    RuleAction: allow
    CidrBlock: 0.0.0.0/0
    PortRange:
      From: 443
      To: 443
```

## Data Encryption

### Encryption at Rest
```yaml
# S3 Bucket Encryption
S3Bucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: aws:kms
            KMSMasterKeyID: !Ref S3KMSKey
          BucketKeyEnabled: true
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true

# EBS Volume Encryption
LaunchTemplate:
  Type: AWS::EC2::LaunchTemplate
  Properties:
    LaunchTemplateData:
      BlockDeviceMappings:
        - DeviceName: /dev/xvda
          Ebs:
            VolumeSize: 20
            VolumeType: gp3
            Encrypted: true
            KmsKeyId: !Ref EBSKMSKey
            DeleteOnTermination: true
```

### Encryption in Transit
```yaml
# ALB with SSL/TLS
ALBListener:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    DefaultActions:
      - Type: forward
        TargetGroupArn: !Ref TargetGroup
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 443
    Protocol: HTTPS
    Certificates:
      - CertificateArn: !Ref SSLCertificate
    SslPolicy: ELBSecurityPolicy-TLS-1-2-2017-01

# Redirect HTTP to HTTPS
HTTPListener:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    DefaultActions:
      - Type: redirect
        RedirectConfig:
          Protocol: HTTPS
          Port: 443
          StatusCode: HTTP_301
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 80
    Protocol: HTTP
```

## Secrets Management

### AWS Secrets Manager
```yaml
DatabaseSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: MyApp/Database/Credentials
    Description: Database credentials for MyApp
    GenerateSecretString:
      SecretStringTemplate: '{"username": "dbadmin"}'
      GenerateStringKey: 'password'
      PasswordLength: 32
      ExcludeCharacters: '"@/\'

SecretRotation:
  Type: AWS::SecretsManager::RotationSchedule
  Properties:
    SecretId: !Ref DatabaseSecret
    RotationLambdaArn: !GetAtt RotationLambda.Arn
    RotationRules:
      AutomaticallyAfterDays: 30
```

### Parameter Store
```bash
# Store application configuration
aws ssm put-parameter \
    --name "/myapp/config/database_url" \
    --value "postgresql://user:pass@host:5432/db" \
    --type "SecureString" \
    --key-id "alias/parameter-store-key"

# Store API keys
aws ssm put-parameter \
    --name "/myapp/api/stripe_key" \
    --value "sk_live_..." \
    --type "SecureString" \
    --description "Stripe API key for payments"
```

### Application Integration
```python
import boto3
import json
from botocore.exceptions import ClientError

class SecretsManager:
    def __init__(self, region='us-east-1'):
        self.client = boto3.client('secretsmanager', region_name=region)
        self.ssm = boto3.client('ssm', region_name=region)
    
    def get_secret(self, secret_name):
        try:
            response = self.client.get_secret_value(SecretId=secret_name)
            return json.loads(response['SecretString'])
        except ClientError as e:
            raise e
    
    def get_parameter(self, parameter_name, decrypt=True):
        try:
            response = self.ssm.get_parameter(
                Name=parameter_name,
                WithDecryption=decrypt
            )
            return response['Parameter']['Value']
        except ClientError as e:
            raise e

# Usage
secrets = SecretsManager()
db_creds = secrets.get_secret('MyApp/Database/Credentials')
api_key = secrets.get_parameter('/myapp/api/stripe_key')
```

## Monitoring and Logging

### CloudTrail Configuration
```yaml
CloudTrail:
  Type: AWS::CloudTrail::Trail
  Properties:
    TrailName: MyApp-CloudTrail
    S3BucketName: !Ref CloudTrailBucket
    S3KeyPrefix: cloudtrail-logs/
    IncludeGlobalServiceEvents: true
    IsMultiRegionTrail: true
    EnableLogFileValidation: true
    EventSelectors:
      - ReadWriteType: All
        IncludeManagementEvents: true
        DataResources:
          - Type: AWS::S3::Object
            Values:
              - !Sub "${S3Bucket}/*"
          - Type: AWS::S3::Bucket
            Values:
              - !Ref S3Bucket
    InsightSelectors:
      - InsightType: ApiCallRateInsight
```

### VPC Flow Logs
```yaml
VPCFlowLog:
  Type: AWS::EC2::FlowLog
  Properties:
    ResourceType: VPC
    ResourceId: !Ref VPC
    TrafficType: ALL
    LogDestinationType: cloud-watch-logs
    LogGroupName: !Ref VPCFlowLogGroup
    DeliverLogsPermissionArn: !GetAtt FlowLogRole.Arn
    LogFormat: '${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${windowstart} ${windowend} ${action}'

VPCFlowLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: /aws/vpc/flowlogs
    RetentionInDays: 30
```

### Security Monitoring
```yaml
GuardDutyDetector:
  Type: AWS::GuardDuty::Detector
  Properties:
    Enable: true
    FindingPublishingFrequency: FIFTEEN_MINUTES

ConfigurationRecorder:
  Type: AWS::Config::ConfigurationRecorder
  Properties:
    Name: MyApp-Config-Recorder
    RoleARN: !GetAtt ConfigRole.Arn
    RecordingGroup:
      AllSupported: true
      IncludeGlobalResourceTypes: true
```

## Compliance and Governance

### Resource Tagging Strategy
```yaml
TaggingPolicy:
  Environment: !Ref Environment
  Application: MyApp
  Owner: DevOps-Team
  CostCenter: Engineering
  Backup: Required
  Compliance: SOC2
```

### AWS Config Rules
```yaml
S3BucketPublicAccessProhibited:
  Type: AWS::Config::ConfigRule
  Properties:
    ConfigRuleName: s3-bucket-public-access-prohibited
    Source:
      Owner: AWS
      SourceIdentifier: S3_BUCKET_PUBLIC_ACCESS_PROHIBITED

RootAccessKeyCheck:
  Type: AWS::Config::ConfigRule
  Properties:
    ConfigRuleName: root-access-key-check
    Source:
      Owner: AWS
      SourceIdentifier: ROOT_ACCESS_KEY_CHECK

MFAEnabledForIAMConsoleAccess:
  Type: AWS::Config::ConfigRule
  Properties:
    ConfigRuleName: mfa-enabled-for-iam-console-access
    Source:
      Owner: AWS
      SourceIdentifier: MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS
```

## Incident Response

### Automated Response
```python
import boto3
import json

def lambda_handler(event, context):
    """
    Automated incident response for security events
    """
    # Parse GuardDuty finding
    detail = event['detail']
    finding_type = detail['type']
    severity = detail['severity']
    
    if severity >= 7.0:  # High severity
        # Isolate compromised instance
        if 'UnauthorizedAPICall' in finding_type:
            isolate_instance(detail['service']['remoteIpDetails']['ipAddressV4'])
        
        # Notify security team
        send_alert(detail)
    
    return {'statusCode': 200}

def isolate_instance(ip_address):
    ec2 = boto3.client('ec2')
    
    # Find instance by IP
    response = ec2.describe_instances(
        Filters=[
            {'Name': 'private-ip-address', 'Values': [ip_address]}
        ]
    )
    
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            
            # Create isolation security group
            sg_response = ec2.create_security_group(
                GroupName=f'isolation-{instance_id}',
                Description='Isolation security group for compromised instance'
            )
            
            # Modify instance security group
            ec2.modify_instance_attribute(
                InstanceId=instance_id,
                Groups=[sg_response['GroupId']]
            )

def send_alert(finding_details):
    sns = boto3.client('sns')
    
    message = {
        'alert': 'Security Incident Detected',
        'severity': finding_details['severity'],
        'type': finding_details['type'],
        'description': finding_details['description']
    }
    
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:security-alerts',
        Message=json.dumps(message),
        Subject='URGENT: Security Incident Detected'
    )
```

## Security Automation

### Compliance Scanning
```bash
#!/bin/bash
# security-scan.sh

echo "Running security compliance scan..."

# Check for unencrypted S3 buckets
aws s3api list-buckets --query 'Buckets[].Name' --output text | while read bucket; do
    encryption=$(aws s3api get-bucket-encryption --bucket "$bucket" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "WARNING: Bucket $bucket is not encrypted"
    fi
done

# Check for public security groups
aws ec2 describe-security-groups --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].[GroupId,GroupName]' --output table

# Check for root access keys
aws iam get-account-summary --query 'SummaryMap.AccountAccessKeysPresent' --output text

# Check MFA status for users
aws iam list-users --query 'Users[].UserName' --output text | while read user; do
    mfa=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text)
    if [ -z "$mfa" ]; then
        echo "WARNING: User $user does not have MFA enabled"
    fi
done

echo "Security scan completed."
```

## Best Practices Checklist

### Infrastructure Security
- [ ] Enable MFA for all IAM users
- [ ] Use IAM roles instead of access keys
- [ ] Implement least privilege access
- [ ] Enable CloudTrail in all regions
- [ ] Configure VPC Flow Logs
- [ ] Use private subnets for databases
- [ ] Enable GuardDuty
- [ ] Configure AWS Config

### Data Protection
- [ ] Encrypt data at rest (S3, EBS, RDS)
- [ ] Encrypt data in transit (HTTPS, TLS)
- [ ] Use AWS KMS for key management
- [ ] Implement backup strategies
- [ ] Configure cross-region replication
- [ ] Use Secrets Manager for credentials

### Network Security
- [ ] Use security groups as firewalls
- [ ] Implement NACLs for additional protection
- [ ] Use VPC endpoints for AWS services
- [ ] Configure WAF for web applications
- [ ] Implement DDoS protection with Shield

### Monitoring and Response
- [ ] Set up CloudWatch alarms
- [ ] Configure SNS notifications
- [ ] Implement automated responses
- [ ] Regular security assessments
- [ ] Incident response procedures
- [ ] Security training for team
