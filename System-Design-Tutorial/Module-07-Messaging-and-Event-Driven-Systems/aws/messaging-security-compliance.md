# AWS Messaging Security and Compliance

## Overview
This guide covers comprehensive security and compliance strategies for AWS messaging services, including encryption, access control, audit logging, and regulatory compliance requirements for enterprise messaging architectures.

## Security Architecture Framework

### Defense in Depth Strategy
```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                         │
├─────────────────────────────────────────────────────────────┤
│  Network Security (VPC, Security Groups, NACLs)           │
│  ├─ Identity & Access (IAM, Cognito, SSO)                 │
│  │  ├─ Data Encryption (KMS, CloudHSM, TLS)              │
│  │  │  ├─ Message Security (Signing, Validation)         │
│  │  │  │  ├─ Audit & Monitoring (CloudTrail, Config)    │
│  │  │  │  │  └─ Compliance (SOC, PCI, HIPAA)            │
└─────────────────────────────────────────────────────────────┘
```

## Encryption and Key Management

### Message Encryption Strategies
```python
import boto3
import json
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

class MessageEncryptionService:
    def __init__(self, kms_key_id: str):
        self.kms = boto3.client('kms')
        self.kms_key_id = kms_key_id
        
    def encrypt_message_payload(self, message_data: dict) -> dict:
        """Encrypt sensitive message payload using KMS"""
        
        # Generate data encryption key
        response = self.kms.generate_data_key(
            KeyId=self.kms_key_id,
            KeySpec='AES_256'
        )
        
        plaintext_key = response['Plaintext']
        encrypted_key = response['CiphertextBlob']
        
        # Encrypt message with data key
        fernet = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
        encrypted_payload = fernet.encrypt(
            json.dumps(message_data).encode()
        )
        
        return {
            'encrypted_payload': base64.b64encode(encrypted_payload).decode(),
            'encrypted_key': base64.b64encode(encrypted_key).decode(),
            'encryption_algorithm': 'AES-256-GCM',
            'key_id': self.kms_key_id
        }
    
    def decrypt_message_payload(self, encrypted_message: dict) -> dict:
        """Decrypt message payload using KMS"""
        
        # Decrypt data encryption key
        encrypted_key = base64.b64decode(encrypted_message['encrypted_key'])
        response = self.kms.decrypt(CiphertextBlob=encrypted_key)
        plaintext_key = response['Plaintext']
        
        # Decrypt message payload
        fernet = Fernet(base64.urlsafe_b64encode(plaintext_key[:32]))
        encrypted_payload = base64.b64decode(encrypted_message['encrypted_payload'])
        decrypted_data = fernet.decrypt(encrypted_payload)
        
        return json.loads(decrypted_data.decode())
```

### SQS Encryption Configuration
```yaml
# CloudFormation template for encrypted SQS
SecureMessageQueue:
  Type: AWS::SQS::Queue
  Properties:
    QueueName: secure-message-queue
    KmsMasterKeyId: !Ref MessageEncryptionKey
    KmsDataKeyReusePeriodSeconds: 300
    MessageRetentionPeriod: 1209600
    VisibilityTimeoutSeconds: 300
    RedrivePolicy:
      deadLetterTargetArn: !GetAtt SecureMessageDLQ.Arn
      maxReceiveCount: 3

MessageEncryptionKey:
  Type: AWS::KMS::Key
  Properties:
    Description: "KMS key for message encryption"
    KeyPolicy:
      Statement:
        - Sid: Enable IAM User Permissions
          Effect: Allow
          Principal:
            AWS: !Sub "arn:aws:iam::${AWS::AccountId}:root"
          Action: "kms:*"
          Resource: "*"
        - Sid: Allow SQS Service
          Effect: Allow
          Principal:
            Service: sqs.amazonaws.com
          Action:
            - kms:Decrypt
            - kms:GenerateDataKey
          Resource: "*"
```

### SNS Encryption and Message Signing
```python
class SecureSNSPublisher:
    def __init__(self, topic_arn: str, kms_key_id: str):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
        self.kms_key_id = kms_key_id
        
    def publish_secure_message(self, message: dict, message_attributes: dict = None):
        """Publish encrypted and signed message to SNS"""
        
        # Add message signature
        signed_message = self._sign_message(message)
        
        # Publish with encryption
        response = self.sns.publish(
            TopicArn=self.topic_arn,
            Message=json.dumps(signed_message),
            MessageAttributes={
                'encryption': {
                    'DataType': 'String',
                    'StringValue': 'KMS'
                },
                'signature_algorithm': {
                    'DataType': 'String', 
                    'StringValue': 'SHA256-RSA'
                },
                **(message_attributes or {})
            }
        )
        
        return response
    
    def _sign_message(self, message: dict) -> dict:
        """Add cryptographic signature to message"""
        
        message_hash = hashes.Hash(hashes.SHA256())
        message_hash.update(json.dumps(message, sort_keys=True).encode())
        digest = message_hash.finalize()
        
        # In production, use proper digital signatures
        signature = base64.b64encode(digest).decode()
        
        return {
            'payload': message,
            'signature': signature,
            'timestamp': datetime.utcnow().isoformat(),
            'version': '1.0'
        }
```

## Identity and Access Management

### IAM Policies for Messaging Services
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SQSProducerAccess",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:SendMessageBatch",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:*:*:order-processing-*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        },
        "DateGreaterThan": {
          "aws:CurrentTime": "2024-01-01T00:00:00Z"
        }
      }
    },
    {
      "Sid": "SQSConsumerAccess", 
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility"
      ],
      "Resource": "arn:aws:sqs:*:*:order-processing-*",
      "Condition": {
        "StringLike": {
          "aws:userid": "AIDACKCEVSQ6C2EXAMPLE:${aws:username}"
        }
      }
    },
    {
      "Sid": "KMSAccess",
      "Effect": "Allow", 
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "arn:aws:kms:*:*:key/messaging-encryption-key",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": [
            "sqs.us-east-1.amazonaws.com",
            "sns.us-east-1.amazonaws.com"
          ]
        }
      }
    }
  ]
}
```

### Cross-Account Access Patterns
```python
class CrossAccountMessagingSetup:
    def __init__(self):
        self.sts = boto3.client('sts')
        
    def setup_cross_account_sns_access(self, topic_arn: str, 
                                     trusted_account_id: str):
        """Configure cross-account SNS topic access"""
        
        policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "CrossAccountPublish",
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": f"arn:aws:iam::{trusted_account_id}:root"
                    },
                    "Action": [
                        "sns:Publish",
                        "sns:GetTopicAttributes"
                    ],
                    "Resource": topic_arn,
                    "Condition": {
                        "StringEquals": {
                            "sns:Protocol": ["sqs", "lambda"]
                        }
                    }
                }
            ]
        }
        
        sns = boto3.client('sns')
        sns.set_topic_attributes(
            TopicArn=topic_arn,
            AttributeName='Policy',
            AttributeValue=json.dumps(policy)
        )
```

## Network Security

### VPC Configuration for Messaging
```yaml
# Secure VPC setup for messaging services
MessagingVPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 10.0.0.0/16
    EnableDnsHostnames: true
    EnableDnsSupport: true

PrivateSubnet1:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref MessagingVPC
    CidrBlock: 10.0.1.0/24
    AvailabilityZone: !Select [0, !GetAZs '']

PrivateSubnet2:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref MessagingVPC
    CidrBlock: 10.0.2.0/24
    AvailabilityZone: !Select [1, !GetAZs '']

# VPC Endpoints for AWS services
SQSVPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref MessagingVPC
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.sqs'
    VpcEndpointType: Interface
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    SecurityGroupIds:
      - !Ref MessagingSecurityGroup
    PolicyDocument:
      Statement:
        - Effect: Allow
          Principal: '*'
          Action:
            - sqs:SendMessage
            - sqs:ReceiveMessage
            - sqs:DeleteMessage
          Resource: '*'
```

### Security Groups and NACLs
```python
def create_messaging_security_groups():
    """Create security groups for messaging infrastructure"""
    
    ec2 = boto3.client('ec2')
    
    # Producer security group
    producer_sg = ec2.create_security_group(
        GroupName='messaging-producers',
        Description='Security group for message producers',
        VpcId='vpc-12345678'
    )
    
    # Allow HTTPS outbound for AWS API calls
    ec2.authorize_security_group_egress(
        GroupId=producer_sg['GroupId'],
        IpPermissions=[
            {
                'IpProtocol': 'tcp',
                'FromPort': 443,
                'ToPort': 443,
                'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
            }
        ]
    )
    
    # Consumer security group  
    consumer_sg = ec2.create_security_group(
        GroupName='messaging-consumers',
        Description='Security group for message consumers',
        VpcId='vpc-12345678'
    )
    
    # Allow inbound from ALB
    ec2.authorize_security_group_ingress(
        GroupId=consumer_sg['GroupId'],
        IpPermissions=[
            {
                'IpProtocol': 'tcp',
                'FromPort': 8080,
                'ToPort': 8080,
                'UserIdGroupPairs': [
                    {'GroupId': 'sg-alb-12345678'}
                ]
            }
        ]
    )
```

## Audit and Compliance

### CloudTrail Configuration for Messaging
```json
{
  "Trail": {
    "Name": "messaging-audit-trail",
    "S3BucketName": "messaging-audit-logs-bucket",
    "S3KeyPrefix": "cloudtrail-logs/",
    "IncludeGlobalServiceEvents": true,
    "IsMultiRegionTrail": true,
    "EnableLogFileValidation": true,
    "EventSelectors": [
      {
        "ReadWriteType": "All",
        "IncludeManagementEvents": true,
        "DataResources": [
          {
            "Type": "AWS::SQS::Queue",
            "Values": ["arn:aws:sqs:*:*:*"]
          },
          {
            "Type": "AWS::SNS::Topic", 
            "Values": ["arn:aws:sns:*:*:*"]
          }
        ]
      }
    ],
    "InsightSelectors": [
      {
        "InsightType": "ApiCallRateInsight"
      }
    ]
  }
}
```

### Compliance Monitoring
```python
class ComplianceMonitor:
    def __init__(self):
        self.config = boto3.client('config')
        self.cloudwatch = boto3.client('cloudwatch')
        
    def setup_compliance_rules(self):
        """Set up AWS Config rules for messaging compliance"""
        
        # SQS encryption rule
        self.config.put_config_rule(
            ConfigRule={
                'ConfigRuleName': 'sqs-encrypted-at-rest',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'SQS_ENCRYPTED_AT_REST'
                },
                'Scope': {
                    'ComplianceResourceTypes': ['AWS::SQS::Queue']
                }
            }
        )
        
        # SNS encryption rule
        self.config.put_config_rule(
            ConfigRule={
                'ConfigRuleName': 'sns-encrypted-kms',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'SNS_ENCRYPTED_KMS'
                },
                'Scope': {
                    'ComplianceResourceTypes': ['AWS::SNS::Topic']
                }
            }
        )
    
    def monitor_message_retention(self):
        """Monitor message retention compliance"""
        
        # Custom metric for retention compliance
        self.cloudwatch.put_metric_data(
            Namespace='Messaging/Compliance',
            MetricData=[
                {
                    'MetricName': 'RetentionCompliance',
                    'Value': self._calculate_retention_compliance(),
                    'Unit': 'Percent',
                    'Timestamp': datetime.utcnow()
                }
            ]
        )
```

## Regulatory Compliance

### GDPR Compliance for Messaging
```python
class GDPRComplianceHandler:
    def __init__(self):
        self.sqs = boto3.client('sqs')
        self.dynamodb = boto3.resource('dynamodb')
        
    def handle_data_deletion_request(self, user_id: str):
        """Handle GDPR right to be forgotten request"""
        
        # 1. Purge messages containing user data
        self._purge_user_messages(user_id)
        
        # 2. Update message retention policies
        self._update_retention_policies(user_id)
        
        # 3. Log compliance action
        self._log_compliance_action('data_deletion', user_id)
    
    def _purge_user_messages(self, user_id: str):
        """Purge messages containing user data"""
        
        # This is complex in practice - messages may need to be 
        # processed to remove PII while preserving business logic
        
        queues_to_check = [
            'user-notifications-queue',
            'user-activity-queue', 
            'user-preferences-queue'
        ]
        
        for queue_name in queues_to_check:
            queue_url = self.sqs.get_queue_url(QueueName=queue_name)['QueueUrl']
            
            # In practice, you'd need sophisticated message filtering
            # This is a simplified example
            self.sqs.purge_queue(QueueUrl=queue_url)
```

### PCI DSS Compliance
```yaml
# PCI DSS compliant messaging configuration
PCICompliantQueue:
  Type: AWS::SQS::Queue
  Properties:
    QueueName: payment-processing-queue
    KmsMasterKeyId: !Ref PCIEncryptionKey
    MessageRetentionPeriod: 345600  # 4 days max for PCI
    VisibilityTimeoutSeconds: 300
    RedrivePolicy:
      deadLetterTargetArn: !GetAtt PCIDeadLetterQueue.Arn
      maxReceiveCount: 1  # Minimal retries for sensitive data

PCIEncryptionKey:
  Type: AWS::KMS::Key
  Properties:
    Description: "PCI DSS compliant encryption key"
    KeyUsage: ENCRYPT_DECRYPT
    KeySpec: SYMMETRIC_DEFAULT
    KeyRotationStatus: true  # Annual rotation required
    KeyPolicy:
      Statement:
        - Sid: Enable PCI compliant access
          Effect: Allow
          Principal:
            AWS: !Sub "arn:aws:iam::${AWS::AccountId}:role/PCIComplianceRole"
          Action: "kms:*"
          Resource: "*"
```

## Security Monitoring and Alerting

### Real-time Security Monitoring
```python
class SecurityMonitor:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.sns = boto3.client('sns')
        
    def setup_security_alarms(self):
        """Set up CloudWatch alarms for security events"""
        
        # Unusual message volume alarm
        self.cloudwatch.put_metric_alarm(
            AlarmName='UnusualMessageVolume',
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=2,
            MetricName='NumberOfMessagesSent',
            Namespace='AWS/SQS',
            Period=300,
            Statistic='Sum',
            Threshold=10000.0,
            ActionsEnabled=True,
            AlarmActions=[
                'arn:aws:sns:us-east-1:123456789012:security-alerts'
            ],
            AlarmDescription='Alert on unusual message volume'
        )
        
        # Failed authentication attempts
        self.cloudwatch.put_metric_alarm(
            AlarmName='FailedAuthAttempts',
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=1,
            MetricName='ErrorCount',
            Namespace='AWS/ApiGateway',
            Period=300,
            Statistic='Sum',
            Threshold=50.0,
            ActionsEnabled=True,
            AlarmActions=[
                'arn:aws:sns:us-east-1:123456789012:security-alerts'
            ]
        )
```

## Best Practices Summary

### Security Checklist
- [ ] Enable encryption at rest for all queues and topics
- [ ] Use KMS customer-managed keys with rotation
- [ ] Implement least privilege IAM policies
- [ ] Enable VPC endpoints for private communication
- [ ] Configure CloudTrail for comprehensive audit logging
- [ ] Set up Config rules for compliance monitoring
- [ ] Implement message signing for integrity
- [ ] Use secure transport (TLS 1.2+) for all communications
- [ ] Regular security assessments and penetration testing
- [ ] Incident response procedures for security events

### Compliance Requirements by Industry
| Industry | Key Requirements | Implementation |
|----------|------------------|----------------|
| **Financial** | PCI DSS, SOX | Encryption, audit trails, access controls |
| **Healthcare** | HIPAA | Data encryption, access logging, retention policies |
| **Government** | FedRAMP | Enhanced security controls, continuous monitoring |
| **EU Operations** | GDPR | Data residency, right to deletion, consent management |

This comprehensive security and compliance guide ensures messaging systems meet enterprise security requirements while maintaining regulatory compliance across multiple jurisdictions.
