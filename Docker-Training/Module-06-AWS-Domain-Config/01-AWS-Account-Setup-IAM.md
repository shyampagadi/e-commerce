# AWS Account Setup and IAM Configuration

## Table of Contents
1. [AWS Account Creation](#aws-account-creation)
2. [Initial Security Setup](#initial-security-setup)
3. [IAM Fundamentals](#iam-fundamentals)
4. [User and Role Management](#user-and-role-management)
5. [Security Best Practices](#security-best-practices)
6. [AWS CLI Configuration](#aws-cli-configuration)

## AWS Account Creation

### Step 1: Create AWS Account
```bash
# Visit AWS Console
https://aws.amazon.com/console/

# Account Creation Process:
1. Click "Create an AWS Account"
2. Enter email address and account name
3. Choose "Personal" account type
4. Provide contact information
5. Enter payment method (credit card required)
6. Verify phone number
7. Select support plan (Basic - Free)
```

### Step 2: Root Account Security
```bash
# Immediately after account creation:

# 1. Enable MFA for root account
AWS Console → Security Credentials → Multi-factor authentication (MFA)
- Choose "Virtual MFA device"
- Use Google Authenticator or AWS Authenticator
- Scan QR code and enter two consecutive codes

# 2. Create strong root password
- Minimum 12 characters
- Include uppercase, lowercase, numbers, symbols
- Store securely (password manager recommended)

# 3. Set up account recovery
- Add alternate email
- Verify phone number
- Set security questions
```

### Step 3: Billing and Cost Management
```bash
# Set up billing alerts and budgets

# Enable billing alerts
AWS Console → Billing → Preferences
- Check "Receive Billing Alerts"
- Check "Receive Free Tier Usage Alerts"

# Create budget
AWS Console → Billing → Budgets → Create budget
- Budget type: Cost budget
- Budget amount: $10-50 (recommended for learning)
- Alert threshold: 80% of budget
- Email notification: your-email@domain.com
```

## Initial Security Setup

### Account-Level Security Configuration
```json
{
  "AccountSecuritySettings": {
    "PasswordPolicy": {
      "MinimumPasswordLength": 12,
      "RequireUppercaseCharacters": true,
      "RequireLowercaseCharacters": true,
      "RequireNumbers": true,
      "RequireSymbols": true,
      "MaxPasswordAge": 90,
      "PasswordReusePrevention": 5
    },
    "MFARequired": true,
    "RootAccessKeys": "Disabled",
    "CloudTrailEnabled": true
  }
}
```

### Enable CloudTrail
```bash
# Enable CloudTrail for audit logging
AWS Console → CloudTrail → Create trail

Trail Configuration:
- Trail name: "account-audit-trail"
- Apply trail to all regions: Yes
- Read/Write events: All
- Data events: Disabled (to avoid costs)
- S3 bucket: Create new bucket
- Log file encryption: Enabled
- Log file validation: Enabled
```

## IAM Fundamentals

### IAM Core Concepts
```bash
# IAM Components:
# 1. Users - Individual people or applications
# 2. Groups - Collections of users with similar permissions
# 3. Roles - Temporary credentials for services/applications
# 4. Policies - JSON documents defining permissions

# IAM Best Practices:
# - Never use root account for daily tasks
# - Follow principle of least privilege
# - Use groups to assign permissions
# - Enable MFA for all users
# - Rotate access keys regularly
```

### IAM Policy Structure
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

## User and Role Management

### Create Administrative User
```bash
# Step 1: Create IAM User
AWS Console → IAM → Users → Add user

User Configuration:
- Username: "admin-user"
- Access type: 
  ✓ Programmatic access (for CLI/API)
  ✓ AWS Management Console access
- Console password: Auto-generated or custom
- Require password reset: Yes (first login)

# Step 2: Attach Policies
- Attach existing policies directly
- Policy: "AdministratorAccess" (for learning environment)
- Production: Use more restrictive policies

# Step 3: Configure MFA
- Enable MFA for the new user
- Use virtual MFA device
- Test login with MFA
```

### Create Developer Group and Users
```bash
# Create Developer Group
AWS Console → IAM → Groups → Create New Group

Group Configuration:
- Group name: "Developers"
- Attach policies:
  - AmazonEC2FullAccess
  - AmazonS3FullAccess
  - AmazonRoute53FullAccess
  - CloudWatchFullAccess
  - IAMReadOnlyAccess

# Create Developer Users
Users to create:
1. "docker-developer" - For container development
2. "devops-engineer" - For deployment tasks
3. "monitoring-user" - For monitoring setup

# Add users to Developers group
```

### Create Service Roles
```json
// EC2 Instance Role for Docker Applications
{
  "RoleName": "EC2-Docker-Role",
  "AssumeRolePolicyDocument": {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  },
  "AttachedPolicies": [
    "AmazonEC2ContainerRegistryReadOnly",
    "CloudWatchAgentServerPolicy",
    "AmazonSSMManagedInstanceCore"
  ]
}
```

### Custom Policies for Container Management
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECSAccess",
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:CreateService",
        "ecs:UpdateService",
        "ecs:DeleteService",
        "ecs:DescribeClusters",
        "ecs:DescribeServices",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:RunTask",
        "ecs:StopTask"
      ],
      "Resource": "*"
    }
  ]
}
```

## Security Best Practices

### Password and Access Key Management
```bash
# Password Policy Configuration
AWS Console → IAM → Account settings → Password policy

Recommended Settings:
- Minimum password length: 12 characters
- Require at least one uppercase letter: Yes
- Require at least one lowercase letter: Yes
- Require at least one number: Yes
- Require at least one non-alphanumeric character: Yes
- Allow users to change their own password: Yes
- Password expiration: 90 days
- Prevent password reuse: 5 previous passwords
- Require administrator reset: No
```

### Access Key Rotation
```bash
#!/bin/bash
# access-key-rotation.sh

# Step 1: Create new access key
aws iam create-access-key --user-name docker-developer

# Step 2: Update applications with new key
# Update ~/.aws/credentials or environment variables

# Step 3: Test new key
aws sts get-caller-identity

# Step 4: Delete old access key (after verification)
aws iam delete-access-key --user-name docker-developer --access-key-id AKIAIOSFODNN7EXAMPLE
```

### MFA Enforcement Policy
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
      "Sid": "DenyAllExceptUnlessMFAAuthenticated",
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

## AWS CLI Configuration

### Install AWS CLI
```bash
# Linux/macOS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows (PowerShell)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify installation
aws --version
```

### Configure AWS CLI
```bash
# Configure default profile
aws configure

# Input required information:
AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name: us-east-1
Default output format: json

# Configure additional profiles
aws configure --profile docker-dev
aws configure --profile production
```

### AWS CLI Configuration Files
```bash
# ~/.aws/credentials
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[docker-dev]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY

# ~/.aws/config
[default]
region = us-east-1
output = json

[profile docker-dev]
region = us-west-2
output = table

[profile production]
region = us-east-1
output = json
mfa_serial = arn:aws:iam::123456789012:mfa/user
```

### Test AWS CLI Configuration
```bash
# Test basic connectivity
aws sts get-caller-identity

# Test with specific profile
aws sts get-caller-identity --profile docker-dev

# List available regions
aws ec2 describe-regions --output table

# Test IAM permissions
aws iam list-users
aws ec2 describe-instances
aws s3 ls
```

### AWS CLI with MFA
```bash
# Get session token with MFA
aws sts get-session-token \
    --serial-number arn:aws:iam::123456789012:mfa/user \
    --token-code 123456 \
    --duration-seconds 3600

# Use temporary credentials
export AWS_ACCESS_KEY_ID=ASIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_SESSION_TOKEN=AQoDYXdzEJr...<remainder of session token>

# Verify MFA session
aws sts get-caller-identity
```

## IAM Monitoring and Auditing

### CloudTrail for IAM Events
```json
{
  "CloudTrailConfiguration": {
    "TrailName": "iam-audit-trail",
    "S3BucketName": "iam-audit-logs-bucket",
    "IncludeGlobalServiceEvents": true,
    "IsMultiRegionTrail": true,
    "EnableLogFileValidation": true,
    "EventSelectors": [
      {
        "ReadWriteType": "All",
        "IncludeManagementEvents": true,
        "DataResources": [
          {
            "Type": "AWS::IAM::User",
            "Values": ["*"]
          },
          {
            "Type": "AWS::IAM::Role",
            "Values": ["*"]
          }
        ]
      }
    ]
  }
}
```

### IAM Access Analyzer
```bash
# Enable IAM Access Analyzer
AWS Console → IAM → Access analyzer → Create analyzer

Configuration:
- Analyzer name: "account-access-analyzer"
- Zone of trust: Current account
- Tags: Environment=Learning, Purpose=Security

# Review findings regularly
AWS Console → IAM → Access analyzer → Findings
```

### Security Monitoring Script
```bash
#!/bin/bash
# iam-security-check.sh

echo "=== IAM Security Check ==="

# Check for users without MFA
echo "Users without MFA:"
aws iam list-users --query 'Users[?not_null(PasswordLastUsed)].[UserName]' --output table

# Check for unused access keys
echo "Access keys older than 90 days:"
aws iam list-access-keys --query 'AccessKeyMetadata[?CreateDate<=`2023-01-01`].[UserName,AccessKeyId,CreateDate]' --output table

# Check for overly permissive policies
echo "Users with AdministratorAccess:"
aws iam list-entities-for-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --query 'PolicyUsers[].UserName' --output table

# Check root account usage
echo "Root account access key usage (should be empty):"
aws iam get-account-summary --query 'SummaryMap.AccountAccessKeysPresent'

echo "=== Security Check Complete ==="
```

This comprehensive guide covers AWS account setup and IAM configuration, providing the foundation for secure cloud operations and container deployment.
