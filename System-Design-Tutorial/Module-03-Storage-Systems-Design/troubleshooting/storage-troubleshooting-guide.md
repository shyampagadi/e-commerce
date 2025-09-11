# Storage Troubleshooting Guide

## Common Storage Issues & Solutions

### 1. EBS Performance Issues

#### Symptoms
- High I/O latency (>10ms)
- Low IOPS despite provisioned capacity
- Application timeouts during storage operations

#### Diagnostic Commands
```bash
# Check EBS optimization status
aws ec2 describe-instance-attribute --instance-id i-12345678 --attribute ebsOptimized

# Monitor EBS metrics
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeQueueLength --dimensions Name=VolumeId,Value=vol-12345678 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Average

# Check volume utilization
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeThroughputPercentage --dimensions Name=VolumeId,Value=vol-12345678 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Average
```

#### Solutions
1. **Enable EBS Optimization**
   ```bash
   aws ec2 modify-instance-attribute --instance-id i-12345678 --ebs-optimized
   ```

2. **Increase IOPS for io2 volumes**
   ```bash
   aws ec2 modify-volume --volume-id vol-12345678 --iops 10000
   ```

3. **Optimize I/O patterns**
   ```bash
   # Use larger block sizes for sequential workloads
   sudo fio --name=optimized-sequential --ioengine=libaio --rw=write --bs=1M --numjobs=4 --filename=/dev/nvme1n1
   ```

### 2. S3 Performance Bottlenecks

#### Symptoms
- Slow upload/download speeds
- High error rates (503, 500)
- Request rate limiting

#### Diagnostic Steps
```bash
# Check S3 request metrics
aws cloudwatch get-metric-statistics --namespace AWS/S3 --metric-name AllRequests --dimensions Name=BucketName,Value=my-bucket --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Sum

# Analyze error rates
aws cloudwatch get-metric-statistics --namespace AWS/S3 --metric-name 4xxErrors --dimensions Name=BucketName,Value=my-bucket --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Sum
```

#### Solutions
1. **Optimize Request Patterns**
   ```bash
   # Use random prefixes to avoid hot-spotting
   aws s3 cp file.txt s3://my-bucket/$(date +%s%N | sha256sum | head -c 8)/file.txt
   
   # Enable Transfer Acceleration
   aws s3api put-bucket-accelerate-configuration --bucket my-bucket --accelerate-configuration Status=Enabled
   ```

2. **Implement Multipart Upload**
   ```python
   import boto3
   from boto3.s3.transfer import TransferConfig
   
   # Configure multipart upload
   config = TransferConfig(
       multipart_threshold=1024 * 25,  # 25MB
       max_concurrency=10,
       multipart_chunksize=1024 * 25,
       use_threads=True
   )
   
   s3_client = boto3.client('s3')
   s3_client.upload_file('large-file.zip', 'my-bucket', 'large-file.zip', Config=config)
   ```

### 3. EFS Performance Issues

#### Symptoms
- Slow file operations
- High latency for small files
- Throughput below expectations

#### Diagnostic Commands
```bash
# Check EFS performance mode
aws efs describe-file-systems --file-system-id fs-12345678 --query 'FileSystems[0].PerformanceMode'

# Monitor EFS metrics
aws cloudwatch get-metric-statistics --namespace AWS/EFS --metric-name TotalIOTime --dimensions Name=FileSystemId,Value=fs-12345678 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Average
```

#### Solutions
1. **Switch to Max I/O Mode**
   ```bash
   # Create new EFS with Max I/O (cannot modify existing)
   aws efs create-file-system --performance-mode maxIO --throughput-mode provisioned --provisioned-throughput-in-mibps 1000
   ```

2. **Optimize Mount Options**
   ```bash
   # Use optimized mount options
   sudo mount -t efs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,intr,timeo=600 fs-12345678.efs.region.amazonaws.com:/ /mnt/efs
   ```

## Performance Optimization Flowchart

```
Storage Performance Issue
         |
    Identify Storage Type
    /        |        \
  EBS       S3        EFS
   |        |         |
Check      Check     Check
Volume     Request   Performance
Type       Pattern   Mode
   |        |         |
Optimize   Optimize  Optimize
IOPS/      Prefix/   Mount
Throughput Multipart Options
   |        |         |
Monitor    Monitor   Monitor
Results    Results   Results
```

## Automated Remediation Scripts

### EBS Performance Auto-Tuning
```bash
#!/bin/bash
# ebs-auto-tune.sh

VOLUME_ID=$1
INSTANCE_ID=$2

# Get current volume metrics
QUEUE_LENGTH=$(aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeQueueLength --dimensions Name=VolumeId,Value=$VOLUME_ID --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 300 --statistics Average --query 'Datapoints[0].Average')

if (( $(echo "$QUEUE_LENGTH > 32" | bc -l) )); then
    echo "High queue length detected ($QUEUE_LENGTH). Optimizing..."
    
    # Enable EBS optimization if not already enabled
    aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --ebs-optimized
    
    # Increase IOPS if io2 volume
    VOLUME_TYPE=$(aws ec2 describe-volumes --volume-ids $VOLUME_ID --query 'Volumes[0].VolumeType' --output text)
    if [ "$VOLUME_TYPE" = "io2" ]; then
        CURRENT_IOPS=$(aws ec2 describe-volumes --volume-ids $VOLUME_ID --query 'Volumes[0].Iops' --output text)
        NEW_IOPS=$((CURRENT_IOPS + 1000))
        aws ec2 modify-volume --volume-id $VOLUME_ID --iops $NEW_IOPS
        echo "Increased IOPS from $CURRENT_IOPS to $NEW_IOPS"
    fi
fi
```

### S3 Performance Optimizer
```python
#!/usr/bin/env python3
# s3-performance-optimizer.py

import boto3
import time
from concurrent.futures import ThreadPoolExecutor

class S3PerformanceOptimizer:
    def __init__(self, bucket_name):
        self.s3_client = boto3.client('s3')
        self.bucket_name = bucket_name
        
    def optimize_upload_performance(self, file_path, key):
        # Configure optimized transfer
        config = boto3.s3.transfer.TransferConfig(
            multipart_threshold=1024 * 25,  # 25MB
            max_concurrency=10,
            multipart_chunksize=1024 * 25,
            use_threads=True
        )
        
        start_time = time.time()
        self.s3_client.upload_file(file_path, self.bucket_name, key, Config=config)
        upload_time = time.time() - start_time
        
        return {
            'upload_time': upload_time,
            'optimization': 'multipart_upload',
            'recommendation': self.get_optimization_recommendation(upload_time)
        }
    
    def test_request_patterns(self):
        # Test different request patterns to avoid hot-spotting
        patterns = ['sequential', 'random_prefix', 'timestamp_prefix']
        results = {}
        
        for pattern in patterns:
            start_time = time.time()
            self.upload_with_pattern(pattern, 100)  # 100 files
            results[pattern] = time.time() - start_time
        
        return results
    
    def get_optimization_recommendation(self, upload_time):
        if upload_time > 60:
            return "Consider Transfer Acceleration or larger multipart chunks"
        elif upload_time > 30:
            return "Increase concurrency or use random prefixes"
        else:
            return "Performance is optimal"

if __name__ == "__main__":
    optimizer = S3PerformanceOptimizer('my-performance-test-bucket')
    results = optimizer.optimize_upload_performance('large-file.zip', 'test/large-file.zip')
    print(f"Upload completed in {results['upload_time']:.2f} seconds")
    print(f"Recommendation: {results['recommendation']}")
```

## Cost Optimization Troubleshooting

### High Storage Costs
```bash
# Analyze storage costs by service
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Simple Storage Service","Amazon Elastic Block Store","Amazon Elastic File System"]}}'

# Identify largest cost contributors
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=USAGE_TYPE --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Simple Storage Service"]}}'
```

### Automated Cost Optimization
```python
class StorageCostOptimizer:
    def __init__(self):
        self.s3_client = boto3.client('s3')
        self.ce_client = boto3.client('ce')
    
    def identify_optimization_opportunities(self, bucket_name):
        opportunities = []
        
        # Analyze object age and access patterns
        paginator = self.s3_client.get_paginator('list_objects_v2')
        
        for page in paginator.paginate(Bucket=bucket_name):
            for obj in page.get('Contents', []):
                age_days = (datetime.now() - obj['LastModified'].replace(tzinfo=None)).days
                
                if age_days > 30 and obj.get('StorageClass', 'STANDARD') == 'STANDARD':
                    potential_savings = self.calculate_savings(obj['Size'], age_days)
                    opportunities.append({
                        'key': obj['Key'],
                        'age_days': age_days,
                        'size': obj['Size'],
                        'current_class': obj.get('StorageClass', 'STANDARD'),
                        'recommended_class': self.recommend_storage_class(age_days),
                        'potential_savings': potential_savings
                    })
        
        return sorted(opportunities, key=lambda x: x['potential_savings'], reverse=True)
    
    def implement_lifecycle_policy(self, bucket_name, opportunities):
        # Create lifecycle policy based on analysis
        lifecycle_rules = self.generate_lifecycle_rules(opportunities)
        
        self.s3_client.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration={'Rules': lifecycle_rules}
        )
        
        return lifecycle_rules
```

## Disaster Recovery Testing

### Automated DR Testing Framework
```bash
#!/bin/bash
# dr-test-framework.sh

echo "Starting Disaster Recovery Test..."

# Test 1: EBS Snapshot Recovery
echo "Testing EBS snapshot recovery..."
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id vol-12345678 --description "DR Test Snapshot" --query 'SnapshotId' --output text)

# Wait for snapshot completion
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID

# Create volume from snapshot
RESTORED_VOLUME=$(aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --availability-zone us-east-1a --query 'VolumeId' --output text)

echo "EBS recovery test completed. Restored volume: $RESTORED_VOLUME"

# Test 2: S3 Cross-Region Replication
echo "Testing S3 cross-region replication..."
aws s3 cp test-dr-file.txt s3://primary-bucket/dr-test/
sleep 30
aws s3 ls s3://replica-bucket/dr-test/ --region us-west-2

# Test 3: EFS Backup Recovery
echo "Testing EFS backup recovery..."
BACKUP_JOB=$(aws backup start-backup-job --backup-vault-name efs-backup-vault --resource-arn arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678 --iam-role-arn arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole --query 'BackupJobId' --output text)

echo "DR testing completed. Results logged to dr-test-results.log"
```

### Recovery Time Objective (RTO) Testing
```python
class RTOTester:
    def __init__(self):
        self.ec2_client = boto3.client('ec2')
        self.backup_client = boto3.client('backup')
        
    def test_ebs_recovery_time(self, snapshot_id, availability_zone):
        start_time = time.time()
        
        # Create volume from snapshot
        response = self.ec2_client.create_volume(
            SnapshotId=snapshot_id,
            AvailabilityZone=availability_zone,
            VolumeType='gp3'
        )
        
        volume_id = response['VolumeId']
        
        # Wait for volume to be available
        waiter = self.ec2_client.get_waiter('volume_available')
        waiter.wait(VolumeIds=[volume_id])
        
        recovery_time = time.time() - start_time
        
        return {
            'volume_id': volume_id,
            'recovery_time_seconds': recovery_time,
            'rto_met': recovery_time < 300,  # 5 minute RTO
            'recommendation': self.get_rto_recommendation(recovery_time)
        }
    
    def test_s3_restore_time(self, bucket, key, restore_tier='Standard'):
        start_time = time.time()
        
        # Initiate restore from Glacier
        self.s3_client.restore_object(
            Bucket=bucket,
            Key=key,
            RestoreRequest={
                'Days': 1,
                'GlacierJobParameters': {
                    'Tier': restore_tier
                }
            }
        )
        
        # Monitor restore status
        while True:
            response = self.s3_client.head_object(Bucket=bucket, Key=key)
            if 'Restore' not in response:
                break
            time.sleep(60)  # Check every minute
        
        restore_time = time.time() - start_time
        
        return {
            'restore_time_seconds': restore_time,
            'restore_tier': restore_tier,
            'rto_met': restore_time < self.get_rto_target(restore_tier)
        }
```

## Storage Security Issues

### Encryption Problems
```bash
# Check EBS encryption status
aws ec2 describe-volumes --volume-ids vol-12345678 --query 'Volumes[0].Encrypted'

# Enable encryption for new volumes
aws ec2 modify-ebs-default-kms-key-id --kms-key-id arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012

# Check S3 bucket encryption
aws s3api get-bucket-encryption --bucket my-bucket
```

### Access Control Issues
```bash
# Check S3 bucket policy
aws s3api get-bucket-policy --bucket my-bucket

# Verify IAM permissions
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::123456789012:user/storage-user --action-names s3:GetObject --resource-arns arn:aws:s3:::my-bucket/test-file.txt
```

## Monitoring and Alerting Setup

### Essential CloudWatch Alarms
```bash
# EBS high latency alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "EBS-High-Latency" \
    --alarm-description "EBS volume latency too high" \
    --metric-name "VolumeTotalReadTime" \
    --namespace "AWS/EBS" \
    --statistic "Average" \
    --period 300 \
    --threshold 100 \
    --comparison-operator "GreaterThanThreshold" \
    --dimensions Name=VolumeId,Value=vol-12345678

# S3 error rate alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "S3-High-Error-Rate" \
    --alarm-description "S3 error rate too high" \
    --metric-name "4xxErrors" \
    --namespace "AWS/S3" \
    --statistic "Sum" \
    --period 300 \
    --threshold 10 \
    --comparison-operator "GreaterThanThreshold" \
    --dimensions Name=BucketName,Value=my-bucket

# EFS throughput alarm
aws cloudwatch put-metric-alarm \
    --alarm-name "EFS-Low-Throughput" \
    --alarm-description "EFS throughput below expected" \
    --metric-name "DataReadIOBytes" \
    --namespace "AWS/EFS" \
    --statistic "Sum" \
    --period 300 \
    --threshold 1048576 \
    --comparison-operator "LessThanThreshold" \
    --dimensions Name=FileSystemId,Value=fs-12345678
```

### Automated Response Actions
```python
import boto3
import json

def lambda_handler(event, context):
    """
    Automated response to storage performance alarms
    """
    # Parse CloudWatch alarm
    message = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = message['AlarmName']
    
    if alarm_name == 'EBS-High-Latency':
        # Auto-optimize EBS volume
        volume_id = extract_volume_id(message)
        optimize_ebs_volume(volume_id)
        
    elif alarm_name == 'S3-High-Error-Rate':
        # Enable Transfer Acceleration
        bucket_name = extract_bucket_name(message)
        enable_transfer_acceleration(bucket_name)
        
    elif alarm_name == 'EFS-Low-Throughput':
        # Switch to provisioned throughput mode
        file_system_id = extract_efs_id(message)
        increase_efs_throughput(file_system_id)
    
    return {'statusCode': 200, 'body': 'Remediation completed'}

def optimize_ebs_volume(volume_id):
    ec2 = boto3.client('ec2')
    
    # Get volume details
    volume = ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]
    
    if volume['VolumeType'] == 'gp3':
        # Increase IOPS for gp3
        current_iops = volume.get('Iops', 3000)
        new_iops = min(current_iops + 1000, 16000)
        
        ec2.modify_volume(VolumeId=volume_id, Iops=new_iops)
        
    elif volume['VolumeType'] == 'io2':
        # Increase IOPS for io2
        current_iops = volume['Iops']
        new_iops = min(current_iops + 2000, 64000)
        
        ec2.modify_volume(VolumeId=volume_id, Iops=new_iops)
```

## Storage Migration Troubleshooting

### DataSync Issues
```bash
# Check DataSync task status
aws datasync describe-task --task-arn arn:aws:datasync:us-east-1:123456789012:task/task-12345678

# Monitor transfer progress
aws datasync describe-task-execution --task-execution-arn arn:aws:datasync:us-east-1:123456789012:task/task-12345678/execution/exec-12345678

# Troubleshoot connectivity
aws datasync describe-location-s3 --location-arn arn:aws:datasync:us-east-1:123456789012:location/loc-12345678
```

### Storage Gateway Troubleshooting
```bash
# Check gateway status
aws storagegateway describe-gateway-information --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678

# Monitor cache utilization
aws storagegateway describe-cache --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678

# Check bandwidth utilization
aws storagegateway describe-bandwidth-rate-limit --gateway-arn arn:aws:storagegateway:us-east-1:123456789012:gateway/sgw-12345678
```
