# Step-by-Step AWS Storage Labs

## Lab 1: EBS Volume Optimization
**Duration**: 90 minutes | **Difficulty**: Intermediate

### Step 1: Create and Configure EBS Volumes
```bash
# Create different EBS volume types for comparison
aws ec2 create-volume --size 100 --volume-type gp3 --iops 3000 --throughput 125 --availability-zone us-east-1a --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=test-gp3}]'

aws ec2 create-volume --size 100 --volume-type io2 --iops 5000 --availability-zone us-east-1a --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=test-io2}]'

aws ec2 create-volume --size 500 --volume-type st1 --availability-zone us-east-1a --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=test-st1}]'
```

### Step 2: Attach Volumes to EC2 Instance
```bash
# Launch EC2 instance for testing
aws ec2 run-instances --image-id ami-0abcdef1234567890 --count 1 --instance-type m5.xlarge --key-name my-key --security-group-ids sg-12345678 --subnet-id subnet-12345678

# Attach volumes
aws ec2 attach-volume --volume-id vol-gp3-12345678 --instance-id i-12345678 --device /dev/sdf
aws ec2 attach-volume --volume-id vol-io2-12345678 --instance-id i-12345678 --device /dev/sdg
aws ec2 attach-volume --volume-id vol-st1-12345678 --instance-id i-12345678 --device /dev/sdh
```

### Step 3: Performance Testing and Optimization
```bash
# SSH into instance and install testing tools
sudo yum update -y
sudo yum install -y fio nvme-cli

# Test gp3 volume performance
sudo fio --name=random-read-gp3 --ioengine=libaio --rw=randread --bs=4k --numjobs=4 --iodepth=32 --runtime=60 --filename=/dev/nvme1n1 --direct=1

# Test io2 volume performance  
sudo fio --name=random-read-io2 --ioengine=libaio --rw=randread --bs=4k --numjobs=8 --iodepth=64 --runtime=60 --filename=/dev/nvme2n1 --direct=1

# Test st1 throughput
sudo fio --name=sequential-read-st1 --ioengine=libaio --rw=read --bs=1M --numjobs=4 --iodepth=16 --runtime=60 --filename=/dev/nvme3n1 --direct=1
```

### Step 4: Monitor and Analyze Performance
```bash
# Enable detailed monitoring
aws ec2 monitor-instances --instance-ids i-12345678

# Get CloudWatch metrics
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeReadOps --dimensions Name=VolumeId,Value=vol-gp3-12345678 --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T01:00:00Z --period 300 --statistics Sum,Average

# Analyze IOPS utilization
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeTotalReadTime --dimensions Name=VolumeId,Value=vol-io2-12345678 --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T01:00:00Z --period 300 --statistics Average
```

### Expected Results
- **gp3**: ~3,000 IOPS, 125 MB/s throughput
- **io2**: ~5,000 IOPS, sub-millisecond latency
- **st1**: ~500 MB/s sequential throughput

## Lab 2: S3 Storage Classes and Lifecycle Management
**Duration**: 75 minutes | **Difficulty**: Beginner-Intermediate

### Step 1: Create S3 Bucket with Different Storage Classes
```bash
# Create bucket
aws s3 mb s3://storage-lab-bucket-12345

# Upload files to different storage classes
aws s3 cp large-file.zip s3://storage-lab-bucket-12345/ --storage-class STANDARD
aws s3 cp archive-data.tar.gz s3://storage-lab-bucket-12345/ --storage-class STANDARD_IA
aws s3 cp old-logs.gz s3://storage-lab-bucket-12345/ --storage-class GLACIER
```

### Step 2: Configure Lifecycle Policies
```json
{
    "Rules": [
        {
            "ID": "LogDataLifecycle",
            "Status": "Enabled",
            "Filter": {
                "Prefix": "logs/"
            },
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                },
                {
                    "Days": 365,
                    "StorageClass": "DEEP_ARCHIVE"
                }
            ]
        }
    ]
}
```

```bash
# Apply lifecycle policy
aws s3api put-bucket-lifecycle-configuration --bucket storage-lab-bucket-12345 --lifecycle-configuration file://lifecycle-policy.json

# Enable versioning for lifecycle testing
aws s3api put-bucket-versioning --bucket storage-lab-bucket-12345 --versioning-configuration Status=Enabled
```

### Step 3: Test Intelligent Tiering
```bash
# Enable Intelligent Tiering
aws s3api put-bucket-intelligent-tiering-configuration --bucket storage-lab-bucket-12345 --id EntireBucket --intelligent-tiering-configuration Id=EntireBucket,Status=Enabled,Filter={},Tierings=[{Days=1,AccessTier=ARCHIVE_ACCESS},{Days=90,AccessTier=DEEP_ARCHIVE_ACCESS}]

# Upload test files
for i in {1..100}; do
    echo "Test data $i" | aws s3 cp - s3://storage-lab-bucket-12345/intelligent-tiering/file-$i.txt
done
```

### Step 4: Cost Analysis and Monitoring
```bash
# Get storage metrics
aws cloudwatch get-metric-statistics --namespace AWS/S3 --metric-name BucketSizeBytes --dimensions Name=BucketName,Value=storage-lab-bucket-12345 Name=StorageType,Value=StandardStorage --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T23:59:59Z --period 86400 --statistics Average

# Analyze costs with Cost Explorer API
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

## Lab 3: EFS Performance Optimization
**Duration**: 60 minutes | **Difficulty**: Intermediate

### Step 1: Create EFS File System
```bash
# Create EFS file system
aws efs create-file-system --performance-mode generalPurpose --throughput-mode provisioned --provisioned-throughput-in-mibps 500 --tags Key=Name,Value=performance-test-efs

# Create mount targets in multiple AZs
aws efs create-mount-target --file-system-id fs-12345678 --subnet-id subnet-12345678 --security-groups sg-12345678
aws efs create-mount-target --file-system-id fs-12345678 --subnet-id subnet-87654321 --security-groups sg-12345678
```

### Step 2: Mount and Test Performance
```bash
# Install EFS utils on EC2 instances
sudo yum install -y amazon-efs-utils

# Mount EFS with different options
sudo mkdir /mnt/efs-general
sudo mkdir /mnt/efs-maxio

# General purpose mount
sudo mount -t efs -o tls fs-12345678:/ /mnt/efs-general

# Max I/O optimized mount
sudo mount -t efs -o tls,_netdev,iam fs-12345678:/ /mnt/efs-maxio
```

### Step 3: Performance Testing
```bash
# Test throughput performance
sudo fio --name=efs-throughput --ioengine=libaio --rw=write --bs=1M --numjobs=4 --size=1G --directory=/mnt/efs-general --direct=1

# Test IOPS performance
sudo fio --name=efs-iops --ioengine=libaio --rw=randwrite --bs=4k --numjobs=16 --size=100M --directory=/mnt/efs-general --direct=1

# Compare with local storage
sudo fio --name=local-comparison --ioengine=libaio --rw=write --bs=1M --numjobs=4 --size=1G --directory=/tmp --direct=1
```

### Expected Performance
- **General Purpose**: Up to 7,000 file operations per second
- **Provisioned Throughput**: Up to 500 MiB/s sustained throughput
- **Max I/O**: Higher levels of aggregate throughput and IOPS

## Lab 4: AWS Backup and Disaster Recovery
**Duration**: 85 minutes | **Difficulty**: Advanced

### Step 1: Configure AWS Backup
```bash
# Create backup vault
aws backup create-backup-vault --backup-vault-name production-backup-vault --encryption-key-arn arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012

# Create IAM role for AWS Backup
aws iam create-role --role-name AWSBackupDefaultServiceRole --assume-role-policy-document file://backup-trust-policy.json
aws iam attach-role-policy --role-name AWSBackupDefaultServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup
```

### Step 2: Create Backup Plan
```json
{
    "BackupPlanName": "ProductionBackupPlan",
    "Rules": [
        {
            "RuleName": "DailyBackups",
            "TargetBackupVaultName": "production-backup-vault",
            "ScheduleExpression": "cron(0 2 ? * * *)",
            "StartWindowMinutes": 60,
            "CompletionWindowMinutes": 120,
            "Lifecycle": {
                "MoveToColdStorageAfterDays": 30,
                "DeleteAfterDays": 365
            },
            "RecoveryPointTags": {
                "BackupType": "Daily"
            }
        }
    ]
}
```

```bash
# Create backup plan
aws backup create-backup-plan --backup-plan file://backup-plan.json

# Create backup selection
aws backup create-backup-selection --backup-plan-id backup-plan-12345678 --backup-selection file://backup-selection.json
```

### Step 3: Test Backup and Restore
```bash
# Trigger on-demand backup
aws backup start-backup-job --backup-vault-name production-backup-vault --resource-arn arn:aws:ec2:us-east-1:123456789012:volume/vol-12345678 --iam-role-arn arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole

# Monitor backup job
aws backup describe-backup-job --backup-job-id backup-job-12345678

# Test restore operation
aws backup start-restore-job --recovery-point-arn arn:aws:backup:us-east-1:123456789012:recovery-point:backup-vault-12345678/recovery-point-12345678 --metadata AvailabilityZone=us-east-1a,VolumeType=gp3 --iam-role-arn arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole
```

### Step 4: Cross-Region Replication
```bash
# Create backup vault in secondary region
aws backup create-backup-vault --backup-vault-name dr-backup-vault --region us-west-2

# Configure cross-region copy
aws backup create-backup-plan --backup-plan '{
    "BackupPlanName": "CrossRegionBackupPlan",
    "Rules": [{
        "RuleName": "CrossRegionRule",
        "TargetBackupVaultName": "production-backup-vault",
        "ScheduleExpression": "cron(0 3 ? * * *)",
        "CopyActions": [{
            "DestinationBackupVaultArn": "arn:aws:backup:us-west-2:123456789012:backup-vault:dr-backup-vault",
            "Lifecycle": {
                "DeleteAfterDays": 90
            }
        }]
    }]
}'
```

## Lab 5: Storage Gateway Hybrid Integration
**Duration**: 70 minutes | **Difficulty**: Advanced

### Step 1: Deploy Storage Gateway
```bash
# Create Storage Gateway (File Gateway)
aws storagegateway create-gateway --gateway-name hybrid-file-gateway --gateway-timezone GMT-5:00 --gateway-region us-east-1 --gateway-type FILE_S3

# Activate gateway (requires on-premises VM or EC2 instance)
aws storagegateway activate-gateway --activation-key ACTIVATION_KEY_FROM_VM --gateway-name hybrid-file-gateway --gateway-timezone GMT-5:00 --gateway-region us-east-1 --gateway-type FILE_S3
```

### Step 2: Configure NFS File Share
```bash
# Create NFS file share
aws storagegateway create-nfs-file-share --client-token unique-token --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678 --location-arn arn:aws:s3:::hybrid-storage-bucket --role arn:aws:iam::123456789012:role/StorageGatewayRole --default-storage-class S3_STANDARD --client-list 10.0.0.0/24
```

### Step 3: Test Hybrid Storage Performance
```bash
# Mount NFS share on client
sudo mkdir /mnt/hybrid-storage
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576 gateway-ip:/bucket-name /mnt/hybrid-storage

# Test file operations
dd if=/dev/zero of=/mnt/hybrid-storage/test-file-1gb bs=1M count=1024
time cp large-dataset.tar.gz /mnt/hybrid-storage/

# Monitor cache performance
aws storagegateway describe-cache --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678
```

### Step 4: Optimize Cache and Bandwidth
```bash
# Add cache disk
aws storagegateway add-cache --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678 --disk-ids disk-12345678

# Configure bandwidth throttling
aws storagegateway update-bandwidth-rate-limit --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678 --average-upload-rate-limit-in-bits-per-sec 104857600 --average-download-rate-limit-in-bits-per-sec 104857600
```

## Performance Benchmarking and Analysis

### Automated Testing Script
```bash
#!/bin/bash
# storage-performance-test.sh

echo "Starting comprehensive storage performance testing..."

# Test EBS volumes
echo "Testing EBS gp3 performance..."
fio --name=ebs-gp3-test --ioengine=libaio --rw=randread --bs=4k --numjobs=4 --iodepth=32 --runtime=60 --filename=/dev/nvme1n1 --output=ebs-gp3-results.json --output-format=json

# Test S3 throughput
echo "Testing S3 upload performance..."
time aws s3 cp 1gb-test-file s3://test-bucket/performance-test/ --storage-class STANDARD

# Test EFS performance
echo "Testing EFS throughput..."
fio --name=efs-test --ioengine=libaio --rw=write --bs=1M --numjobs=4 --size=1G --directory=/mnt/efs --output=efs-results.json --output-format=json

echo "Performance testing complete. Results saved to *-results.json files."
```

### Cost Analysis Tool
```python
#!/usr/bin/env python3
# storage-cost-analyzer.py

import boto3
import json
from datetime import datetime, timedelta

class StorageCostAnalyzer:
    def __init__(self):
        self.ce_client = boto3.client('ce')
        self.s3_client = boto3.client('s3')
        
    def analyze_storage_costs(self, start_date, end_date):
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='MONTHLY',
            Metrics=['BlendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'},
                {'Type': 'DIMENSION', 'Key': 'USAGE_TYPE'}
            ],
            Filter={
                'Dimensions': {
                    'Key': 'SERVICE',
                    'Values': ['Amazon Simple Storage Service', 'Amazon Elastic Block Store', 'Amazon Elastic File System']
                }
            }
        )
        
        return self.format_cost_analysis(response)
    
    def get_optimization_recommendations(self, bucket_name):
        # Analyze S3 bucket for optimization opportunities
        objects = self.s3_client.list_objects_v2(Bucket=bucket_name)
        
        recommendations = []
        for obj in objects.get('Contents', []):
            age_days = (datetime.now() - obj['LastModified'].replace(tzinfo=None)).days
            
            if age_days > 30 and obj['StorageClass'] == 'STANDARD':
                recommendations.append({
                    'object': obj['Key'],
                    'current_class': obj['StorageClass'],
                    'recommended_class': 'STANDARD_IA',
                    'potential_savings': self.calculate_savings(obj['Size'], 'STANDARD', 'STANDARD_IA')
                })
        
        return recommendations

if __name__ == "__main__":
    analyzer = StorageCostAnalyzer()
    costs = analyzer.analyze_storage_costs('2023-01-01', '2023-01-31')
    print(json.dumps(costs, indent=2))
```

## Troubleshooting Common Issues

### EBS Performance Issues
```bash
# Check if EBS-optimized is enabled
aws ec2 describe-instance-attribute --instance-id i-12345678 --attribute ebsOptimized

# Monitor EBS metrics
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeQueueLength --dimensions Name=VolumeId,Value=vol-12345678 --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T01:00:00Z --period 300 --statistics Average
```

### S3 Performance Optimization
```bash
# Use multipart upload for large files
aws configure set default.s3.multipart_threshold 64MB
aws configure set default.s3.multipart_chunksize 16MB
aws configure set default.s3.max_concurrent_requests 10
```

### EFS Mount Issues
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678

# Test NFS connectivity
telnet efs-mount-target-ip 2049
```
