# AWS Account Setup and Security (Module-00)

## Overview

Foundational guidance to set up AWS accounts securely with least-privilege IAM, guardrails, logging, and multi-account structure.

## Recommended Multi-Account Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    ORGANIZATION (Root)                      │
├───────────────┬──────────────────────┬──────────────────────┤
│ Security OU   │ Sandbox OU           │ Workloads OU         │
├───────────────┼──────────────────────┼──────────────────────┤
│ Audit         │ Dev                  │ Prod (per env/team)  │
│ Log Archive   │ Test                 │ Shared Services      │
│                 │ Stage               │ Data/Analytics       │
└─────────────────────────────────────────────────────────────┘
```

## Identity and Access Management (IAM)
- Use IAM Identity Center (SSO) for workforce access
- Enforce MFA and strong password policies
- Use roles with least privilege; avoid long-lived keys
- Adopt permission boundaries and scoped-down policies
- Separate administrative from workload roles

## Guardrails and Governance
- Service Control Policies (SCP) at OU level
- Tagging standards: cost-center, env, owner, data-classification
- Config rules for resource compliance
- Budgets and alerts per account/project

## Logging and Audit
- Centralized CloudTrail org trail to Log Archive
- Enable CloudWatch/CloudWatch Logs for services
- S3 access logs; ALB/NLB logs; VPC Flow Logs
- GuardDuty, Security Hub enabled org-wide

## Network Baseline
- Per-account VPCs, no default VPC in prod
- Egress controls via NAT, egress-only IGW, VPC endpoints
- Private subnets for data plane; public only for edges
- DNS via Route 53; private hosted zones for internal

## Encryption and Secrets
- KMS CMKs with proper key policies; rotation where applicable
- Encrypt data at rest (S3, EBS, RDS, DynamoDB)
- TLS everywhere in transit; ACM for certs
- Secrets Manager/Parameter Store; no secrets in code

## Backup and DR
- AWS Backup policies per OU/account
- RPO/RTO defined and tested; cross-region where needed
- Lifecycle policies for snapshots/archives

## Monitoring and Incident Response
- CloudWatch alarms for golden signals; Synthetics for probes
- Central dashboards; log aggregation
- Automated incident runbooks (SSM Automation)
- Pager/notification integration (SNS/Slack)

## Cost Controls
- Budgets, anomaly detection, cost categories
- Rightsizing, Savings Plans/RI strategy, Spot policies
- Chargeback/showback tagging and reports

## Checklists
- Accounts: SSO/MFA, SCP, tagging, budgets
- IAM: roles-only, boundaries, key rotation, admin separation
- Network: VPC baseline, endpoints, egress controls
- Security: GuardDuty, Security Hub, CloudTrail, encryption
- Ops: backups, alarms, dashboards, runbooks

## Sample Service Control Policies (SCPs)

### SCP 1: Prevent Root Account Usage
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootAccountUsage",
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::*:root"
      },
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalType": "AssumedRole"
        }
      }
    }
  ]
}
```

### SCP 2: Restrict Regions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnapprovedRegions",
      "Effect": "Deny",
      "NotAction": [
        "iam:*",
        "organizations:*",
        "route53:*",
        "cloudfront:*",
        "waf:*",
        "wafv2:*",
        "waf-regional:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    }
  ]
}
```

### SCP 3: Require MFA for Sensitive Operations
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenySensitiveOperationsWithoutMFA",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy",
        "iam:DeleteUserPolicy",
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:UpdateAccessKey",
        "kms:CreateKey",
        "kms:DeleteKey",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
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

## Tagging Standards and Policy

### Required Tags
All resources must have the following tags:

| Tag Key | Description | Example Values | Required |
|---------|-------------|----------------|----------|
| `Environment` | Environment name | `dev`, `test`, `staging`, `prod` | Yes |
| `Project` | Project or application name | `ecommerce-platform`, `data-analytics` | Yes |
| `Owner` | Team or individual responsible | `platform-team`, `data-team` | Yes |
| `CostCenter` | Cost center for billing | `engineering`, `marketing`, `operations` | Yes |
| `DataClassification` | Data sensitivity level | `public`, `internal`, `confidential`, `restricted` | Yes |
| `BackupRequired` | Whether backup is required | `true`, `false` | Yes |
| `RetentionDays` | Data retention period | `30`, `90`, `365`, `2555` | Yes |

### Optional Tags
Additional tags for better organization:

| Tag Key | Description | Example Values |
|---------|-------------|----------------|
| `Application` | Specific application component | `web-server`, `api-gateway`, `database` |
| `Version` | Application or infrastructure version | `v1.0`, `v2.1` |
| `MaintenanceWindow` | Preferred maintenance time | `sunday-2am`, `saturday-4am` |
| `Compliance` | Compliance requirements | `pci-dss`, `hipaa`, `sox` |
| `AutoShutdown` | Whether resource can be auto-shutdown | `true`, `false` |

### Tagging Policy Example
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceRequiredTags",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "rds:CreateDBInstance",
        "s3:CreateBucket",
        "lambda:CreateFunction"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestedRegion": "false"
        },
        "ForAnyValue:StringNotEquals": {
          "aws:TagKeys": [
            "Environment",
            "Project",
            "Owner",
            "CostCenter",
            "DataClassification",
            "BackupRequired",
            "RetentionDays"
          ]
        }
      }
    }
  ]
}
```

### Tag Validation Script
```bash
#!/bin/bash
# Validate required tags on EC2 instances

REQUIRED_TAGS=("Environment" "Project" "Owner" "CostCenter" "DataClassification" "BackupRequired" "RetentionDays")

for instance in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text); do
  echo "Checking instance: $instance"
  
  for tag in "${REQUIRED_TAGS[@]}"; do
    if ! aws ec2 describe-tags --filters "Name=resource-id,Values=$instance" "Name=key,Values=$tag" --query 'Tags[0].Value' --output text | grep -q "."; then
      echo "  MISSING: $tag"
    else
      echo "  OK: $tag"
    fi
  done
done
```

## Cost Control Policies

### Budget Alerts
```json
{
  "Budgets": [
    {
      "BudgetName": "Monthly-Dev-Environment",
      "BudgetLimit": {
        "Amount": "1000",
        "Unit": "USD"
      },
      "TimeUnit": "MONTHLY",
      "BudgetType": "COST",
      "CostFilters": {
        "TagKey": [
          "Environment"
        ],
        "TagValue": [
          "dev"
        ]
      },
      "AlertsWithSubscribers": [
        {
          "Threshold": 80,
          "ThresholdType": "PERCENTAGE",
          "Subscribers": [
            {
              "SubscriptionType": "EMAIL",
              "Address": "dev-team@company.com"
            }
          ]
        }
      ]
    }
  ]
}
```

### Resource Cleanup Automation
```python
import boto3
import datetime

def cleanup_old_resources():
    """Clean up resources older than specified retention period"""
    
    # Clean up old snapshots
    ec2 = boto3.client('ec2')
    snapshots = ec2.describe_snapshots(
        OwnerIds=['self'],
        Filters=[
            {'Name': 'tag:RetentionDays', 'Values': ['30']}
        ]
    )
    
    cutoff_date = datetime.datetime.now() - datetime.timedelta(days=30)
    
    for snapshot in snapshots['Snapshots']:
        if snapshot['StartTime'].replace(tzinfo=None) < cutoff_date:
            print(f"Deleting snapshot: {snapshot['SnapshotId']}")
            ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
```

