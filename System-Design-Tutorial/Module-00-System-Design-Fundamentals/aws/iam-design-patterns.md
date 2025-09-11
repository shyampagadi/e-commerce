# AWS IAM Design Patterns

## Overview
AWS Identity and Access Management (IAM) is fundamental to securing AWS resources and implementing proper access controls. Understanding IAM design patterns is crucial for building secure, scalable, and manageable access control systems that follow the principle of least privilege.

## Core IAM Concepts

### Identity Types and Use Cases
```python
class IAMIdentityTypes:
    def __init__(self):
        self.identity_types = {
            'users': {
                'use_case': 'Individual human users',
                'best_practice': 'Avoid for programmatic access',
                'authentication': 'Username/password + MFA',
                'max_recommended': 50  # Beyond this, consider federation
            },
            'groups': {
                'use_case': 'Logical grouping of users',
                'best_practice': 'Assign permissions to groups, not users',
                'management': 'Easier permission management',
                'inheritance': 'Users inherit group permissions'
            },
            'roles': {
                'use_case': 'AWS services and cross-account access',
                'best_practice': 'Preferred for programmatic access',
                'authentication': 'Temporary credentials via STS',
                'delegation': 'Can be assumed by trusted entities'
            },
            'policies': {
                'use_case': 'Define permissions',
                'types': ['managed', 'inline', 'resource_based'],
                'best_practice': 'Use managed policies for reusability'
            }
        }
    
    def design_identity_strategy(self, organization_size, access_patterns):
        """Design IAM identity strategy based on organization needs"""
        
        if organization_size == 'small':  # < 50 users
            strategy = {
                'user_management': 'Direct IAM users with groups',
                'authentication': 'IAM users with MFA',
                'role_usage': 'Service roles and cross-account access',
                'policy_management': 'AWS managed policies + custom groups'
            }
        
        elif organization_size == 'medium':  # 50-500 users
            strategy = {
                'user_management': 'IAM users + federation for some use cases',
                'authentication': 'Mix of IAM users and federated access',
                'role_usage': 'Extensive use of roles for applications',
                'policy_management': 'Custom managed policies + permission boundaries'
            }
        
        else:  # large organization > 500 users
            strategy = {
                'user_management': 'Federation with external identity provider',
                'authentication': 'SAML/OIDC federation + MFA',
                'role_usage': 'Role-based access for all programmatic access',
                'policy_management': 'Centralized policy management + automation'
            }
        
        return strategy
```

## Permission Design Patterns

### Least Privilege Implementation
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificS3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-application-bucket/user-uploads/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "AllowListBucketForSpecificPrefix",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-application-bucket",
      "Condition": {
        "StringLike": {
          "s3:prefix": "user-uploads/*"
        }
      }
    },
    {
      "Sid": "DenyUnencryptedUploads",
      "Effect": "Deny",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-application-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

### Permission Boundaries Pattern
```python
class IAMPermissionBoundaries:
    def __init__(self):
        self.boundary_use_cases = {
            'developer_sandbox': 'Limit developer permissions in sandbox accounts',
            'service_limits': 'Prevent services from exceeding allowed permissions',
            'compliance_controls': 'Enforce regulatory compliance requirements',
            'cost_controls': 'Prevent expensive resource creation'
        }
    
    def create_developer_boundary(self, allowed_services, cost_limit):
        """Create permission boundary for developers"""
        
        boundary_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AllowedServices",
                    "Effect": "Allow",
                    "Action": [
                        f"{service}:*" for service in allowed_services
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "DenyExpensiveInstances",
                    "Effect": "Deny",
                    "Action": [
                        "ec2:RunInstances",
                        "ec2:StartInstances"
                    ],
                    "Resource": "arn:aws:ec2:*:*:instance/*",
                    "Condition": {
                        "ForAnyValue:StringNotEquals": {
                            "ec2:InstanceType": [
                                "t3.micro",
                                "t3.small",
                                "t3.medium"
                            ]
                        }
                    }
                },
                {
                    "Sid": "DenyProductionAccess",
                    "Effect": "Deny",
                    "Action": "*",
                    "Resource": "*",
                    "Condition": {
                        "StringEquals": {
                            "aws:RequestedRegion": "us-east-1"  # Production region
                        }
                    }
                },
                {
                    "Sid": "RequireMFAForSensitiveActions",
                    "Effect": "Deny",
                    "Action": [
                        "iam:*",
                        "ec2:TerminateInstances",
                        "rds:DeleteDBInstance"
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
        
        return boundary_policy
```

## Role-Based Access Patterns

### Service Role Pattern
```yaml
# CloudFormation template for service roles
Resources:
  # EC2 instance role for application servers
  ApplicationServerRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${AWS::StackName}-application-server-role'
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
        - PolicyName: ApplicationSpecificPermissions
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
                  - dynamodb:Query
                Resource: !Sub '${ApplicationTable}/*'
              - Effect: Allow
                Action:
                  - kms:Decrypt
                  - kms:GenerateDataKey
                Resource: !Ref ApplicationKMSKey

  ApplicationServerInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: !Sub '${AWS::StackName}-application-server-profile'
      Roles:
        - !Ref ApplicationServerRole

  # Lambda execution role
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${AWS::StackName}-lambda-execution-role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: LambdaSpecificPermissions
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:GetItem
                  - dynamodb:PutItem
                  - dynamodb:UpdateItem
                  - dynamodb:DeleteItem
                Resource: !GetAtt ApplicationTable.Arn
              - Effect: Allow
                Action:
                  - sns:Publish
                Resource: !Ref NotificationTopic
```

### Cross-Account Access Pattern
```python
class CrossAccountAccess:
    def __init__(self):
        self.access_patterns = {
            'centralized_logging': 'Central logging account accesses application accounts',
            'security_audit': 'Security account has read-only access to all accounts',
            'shared_services': 'Shared services account provides common resources',
            'backup_recovery': 'Backup account has access to create and restore backups'
        }
    
    def create_cross_account_role(self, trusted_account_id, access_type, external_id=None):
        """Create cross-account access role"""
        
        assume_role_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": f"arn:aws:iam::{trusted_account_id}:root"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
        
        # Add external ID condition for enhanced security
        if external_id:
            assume_role_policy["Statement"][0]["Condition"] = {
                "StringEquals": {
                    "sts:ExternalId": external_id
                }
            }
        
        # Add MFA requirement for sensitive access
        if access_type in ['security_audit', 'admin_access']:
            if "Condition" not in assume_role_policy["Statement"][0]:
                assume_role_policy["Statement"][0]["Condition"] = {}
            assume_role_policy["Statement"][0]["Condition"]["Bool"] = {
                "aws:MultiFactorAuthPresent": "true"
            }
        
        # Define permissions based on access type
        if access_type == 'security_audit':
            permissions = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "iam:Get*",
                            "iam:List*",
                            "ec2:Describe*",
                            "s3:GetBucketPolicy",
                            "s3:GetBucketAcl",
                            "cloudtrail:DescribeTrails",
                            "cloudtrail:GetTrailStatus"
                        ],
                        "Resource": "*"
                    }
                ]
            }
        
        elif access_type == 'centralized_logging':
            permissions = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "logs:CreateLogGroup",
                            "logs:CreateLogStream",
                            "logs:PutLogEvents",
                            "logs:DescribeLogGroups",
                            "logs:DescribeLogStreams"
                        ],
                        "Resource": "*"
                    },
                    {
                        "Effect": "Allow",
                        "Action": [
                            "s3:PutObject",
                            "s3:GetObject"
                        ],
                        "Resource": "arn:aws:s3:::central-logging-bucket/*"
                    }
                ]
            }
        
        return {
            'assume_role_policy': assume_role_policy,
            'permissions_policy': permissions
        }
```

## Federation Patterns

### SAML Federation
```python
class SAMLFederation:
    def __init__(self):
        self.federation_benefits = {
            'centralized_authentication': 'Single sign-on experience',
            'reduced_user_management': 'Users managed in corporate directory',
            'enhanced_security': 'Corporate security policies applied',
            'audit_compliance': 'Centralized audit trails'
        }
    
    def configure_saml_provider(self, identity_provider_metadata):
        """Configure SAML identity provider"""
        
        saml_config = {
            'identity_provider': {
                'metadata_document': identity_provider_metadata,
                'provider_name': 'CorporateAD',
                'provider_arn': 'arn:aws:iam::123456789012:saml-provider/CorporateAD'
            },
            'role_mapping': {
                'administrators': {
                    'saml_attribute': 'https://aws.amazon.com/SAML/Attributes/Role',
                    'attribute_value': 'arn:aws:iam::123456789012:role/AdminRole,arn:aws:iam::123456789012:saml-provider/CorporateAD',
                    'session_duration': 3600  # 1 hour
                },
                'developers': {
                    'saml_attribute': 'https://aws.amazon.com/SAML/Attributes/Role',
                    'attribute_value': 'arn:aws:iam::123456789012:role/DeveloperRole,arn:aws:iam::123456789012:saml-provider/CorporateAD',
                    'session_duration': 28800  # 8 hours
                },
                'read_only_users': {
                    'saml_attribute': 'https://aws.amazon.com/SAML/Attributes/Role',
                    'attribute_value': 'arn:aws:iam::123456789012:role/ReadOnlyRole,arn:aws:iam::123456789012:saml-provider/CorporateAD',
                    'session_duration': 14400  # 4 hours
                }
            }
        }
        
        return saml_config
    
    def create_federated_role(self, role_name, saml_provider_arn, permissions):
        """Create role for SAML federated users"""
        
        federated_role = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": saml_provider_arn
                    },
                    "Action": "sts:AssumeRoleWithSAML",
                    "Condition": {
                        "StringEquals": {
                            "SAML:aud": "https://signin.aws.amazon.com/saml"
                        }
                    }
                }
            ]
        }
        
        return {
            'role_name': role_name,
            'assume_role_policy': federated_role,
            'permissions': permissions
        }
```

### Web Identity Federation
```python
class WebIdentityFederation:
    def __init__(self):
        self.supported_providers = {
            'cognito': 'AWS Cognito User Pools',
            'google': 'Google OAuth 2.0',
            'facebook': 'Facebook Login',
            'amazon': 'Login with Amazon',
            'oidc': 'OpenID Connect providers'
        }
    
    def configure_web_identity_role(self, provider_type, provider_config):
        """Configure role for web identity federation"""
        
        if provider_type == 'cognito':
            assume_role_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Federated": "cognito-identity.amazonaws.com"
                        },
                        "Action": "sts:AssumeRoleWithWebIdentity",
                        "Condition": {
                            "StringEquals": {
                                "cognito-identity.amazonaws.com:aud": provider_config['identity_pool_id']
                            },
                            "ForAnyValue:StringLike": {
                                "cognito-identity.amazonaws.com:amr": "authenticated"
                            }
                        }
                    }
                ]
            }
        
        elif provider_type == 'oidc':
            assume_role_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {
                            "Federated": provider_config['provider_arn']
                        },
                        "Action": "sts:AssumeRoleWithWebIdentity",
                        "Condition": {
                            "StringEquals": {
                                f"{provider_config['provider_url']}:aud": provider_config['client_id']
                            }
                        }
                    }
                ]
            }
        
        return assume_role_policy
```

## Security Best Practices

### MFA Enforcement Patterns
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowViewAccountInfo",
      "Effect": "Allow",
      "Action": [
        "iam:GetAccountPasswordPolicy",
        "iam:GetAccountSummary",
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

### Access Logging and Monitoring
```python
class IAMMonitoring:
    def __init__(self):
        self.monitoring_events = {
            'authentication': ['ConsoleLogin', 'AssumeRole', 'GetSessionToken'],
            'authorization': ['AccessDenied', 'UnauthorizedOperation'],
            'privilege_escalation': ['AttachUserPolicy', 'PutUserPolicy', 'CreateRole'],
            'suspicious_activity': ['MultipleFailedLogins', 'UnusualLocation', 'OffHoursAccess']
        }
    
    def create_cloudwatch_alarms(self, cloudtrail_log_group):
        """Create CloudWatch alarms for IAM security events"""
        
        alarms = {
            'root_account_usage': {
                'filter_pattern': '{ $.userIdentity.type = "Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != "AwsServiceEvent" }',
                'alarm_description': 'Root account usage detected',
                'threshold': 1,
                'evaluation_periods': 1
            },
            'unauthorized_api_calls': {
                'filter_pattern': '{ ($.errorCode = "*UnauthorizedOperation") || ($.errorCode = "AccessDenied*") }',
                'alarm_description': 'Unauthorized API calls detected',
                'threshold': 10,
                'evaluation_periods': 2
            },
            'console_signin_failures': {
                'filter_pattern': '{ ($.eventName = ConsoleLogin) && ($.errorMessage = "Failed authentication") }',
                'alarm_description': 'Multiple console signin failures',
                'threshold': 5,
                'evaluation_periods': 1
            },
            'iam_policy_changes': {
                'filter_pattern': '{ ($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy) }',
                'alarm_description': 'IAM policy changes detected',
                'threshold': 1,
                'evaluation_periods': 1
            }
        }
        
        return alarms
```

## Automation and Governance

### Policy Validation and Testing
```python
class IAMPolicyValidation:
    def __init__(self):
        self.validation_tools = {
            'policy_simulator': 'Test policies before deployment',
            'access_analyzer': 'Identify unintended access',
            'cloudformation_guard': 'Policy-as-code validation',
            'custom_validation': 'Organization-specific rules'
        }
    
    def validate_policy(self, policy_document):
        """Validate IAM policy for common issues"""
        
        validation_results = {
            'syntax_errors': [],
            'security_issues': [],
            'best_practice_violations': [],
            'recommendations': []
        }
        
        # Check for overly permissive policies
        for statement in policy_document.get('Statement', []):
            if statement.get('Effect') == 'Allow':
                actions = statement.get('Action', [])
                resources = statement.get('Resource', [])
                
                # Check for wildcard permissions
                if '*' in actions:
                    validation_results['security_issues'].append(
                        'Wildcard action (*) grants excessive permissions'
                    )
                
                if '*' in resources:
                    validation_results['security_issues'].append(
                        'Wildcard resource (*) grants access to all resources'
                    )
                
                # Check for missing conditions on sensitive actions
                sensitive_actions = ['iam:*', 'ec2:TerminateInstances', 'rds:DeleteDBInstance']
                if any(action in actions for action in sensitive_actions):
                    if 'Condition' not in statement:
                        validation_results['best_practice_violations'].append(
                            'Sensitive actions should include conditions (e.g., MFA)'
                        )
        
        return validation_results
    
    def generate_policy_recommendations(self, access_patterns):
        """Generate policy recommendations based on access patterns"""
        
        recommendations = []
        
        for service, usage_data in access_patterns.items():
            if usage_data['frequency'] == 'high':
                recommendations.append({
                    'service': service,
                    'recommendation': 'Consider using managed policies for frequently used services',
                    'rationale': 'Managed policies are maintained by AWS and follow best practices'
                })
            
            if usage_data['error_rate'] > 0.1:  # 10% error rate
                recommendations.append({
                    'service': service,
                    'recommendation': 'Review permissions - high error rate indicates insufficient access',
                    'rationale': 'High error rates may indicate missing permissions'
                })
        
        return recommendations
```

## Best Practices Summary

### IAM Implementation Checklist
```python
class IAMBestPracticesChecklist:
    def __init__(self):
        self.checklist = {
            'identity_management': [
                'Use IAM roles for applications and services',
                'Implement MFA for all human users',
                'Use federation for large organizations',
                'Regularly review and remove unused identities'
            ],
            'permission_management': [
                'Follow principle of least privilege',
                'Use managed policies when possible',
                'Implement permission boundaries for delegation',
                'Regular access reviews and cleanup'
            ],
            'security_controls': [
                'Enable CloudTrail for all API calls',
                'Monitor IAM events with CloudWatch',
                'Use AWS Config for compliance monitoring',
                'Implement automated policy validation'
            ],
            'operational_excellence': [
                'Document IAM architecture and procedures',
                'Automate IAM resource provisioning',
                'Implement policy testing in CI/CD',
                'Regular security assessments and audits'
            ]
        }
    
    def generate_security_scorecard(self, current_implementation):
        """Generate security scorecard for IAM implementation"""
        
        scorecard = {}
        total_score = 0
        max_score = 0
        
        for category, practices in self.checklist.items():
            category_score = 0
            category_max = len(practices)
            
            for practice in practices:
                if practice in current_implementation.get(category, []):
                    category_score += 1
            
            scorecard[category] = {
                'score': category_score,
                'max_score': category_max,
                'percentage': (category_score / category_max) * 100
            }
            
            total_score += category_score
            max_score += category_max
        
        scorecard['overall'] = {
            'score': total_score,
            'max_score': max_score,
            'percentage': (total_score / max_score) * 100
        }
        
        return scorecard
```

## Conclusion

AWS IAM design patterns provide the foundation for building secure, scalable access control systems. Success requires understanding identity types, implementing least privilege principles, using appropriate federation methods, and maintaining strong security controls. The key is to design IAM architectures that balance security, usability, and operational efficiency while following AWS best practices and organizational requirements.
