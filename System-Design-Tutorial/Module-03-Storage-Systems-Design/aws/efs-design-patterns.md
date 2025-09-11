# Amazon EFS Design Patterns

## Overview
Amazon Elastic File System (EFS) provides scalable, fully managed NFS file systems for use with AWS compute services. EFS is designed for applications requiring shared file storage with POSIX semantics.

## Core EFS Concepts

### File System Architecture
```
EFS File System
├── Mount Targets (per AZ)
│   ├── Network Interface in VPC subnet
│   ├── Security Group controls
│   └── IP address for mounting
├── Performance Modes
│   ├── General Purpose: Lower latency
│   └── Max I/O: Higher aggregate throughput
└── Throughput Modes
    ├── Provisioned: Guaranteed throughput
    └── Bursting: Credit-based system
```

### Performance Characteristics
```
General Purpose Mode:
- Up to 7,000 file operations per second
- Lower latency per operation
- Suitable for most use cases

Max I/O Mode:
- Virtually unlimited file operations per second
- Higher latency per operation
- Better for highly parallel workloads
```

## Mount Target Design Patterns

### Multi-AZ Mount Strategy
```python
class EFSMountStrategy:
    def __init__(self, vpc_id, subnet_ids):
        self.vpc_id = vpc_id
        self.subnet_ids = subnet_ids
        self.efs_client = boto3.client('efs')
        self.ec2_client = boto3.client('ec2')
    
    def create_mount_targets(self, file_system_id, security_group_id):
        """Create mount targets in multiple AZs for high availability"""
        
        mount_targets = []
        
        for subnet_id in self.subnet_ids:
            # Get subnet AZ
            subnet_info = self.ec2_client.describe_subnets(SubnetIds=[subnet_id])
            az = subnet_info['Subnets'][0]['AvailabilityZone']
            
            try:
                response = self.efs_client.create_mount_target(
                    FileSystemId=file_system_id,
                    SubnetId=subnet_id,
                    SecurityGroups=[security_group_id]
                )
                
                mount_targets.append({
                    'mount_target_id': response['MountTargetId'],
                    'subnet_id': subnet_id,
                    'availability_zone': az,
                    'ip_address': response['IpAddress']
                })
                
            except Exception as e:
                print(f"Failed to create mount target in {az}: {e}")
        
        return mount_targets
    
    def get_optimal_mount_target(self, instance_az):
        """Get the optimal mount target for an instance's AZ"""
        
        # Prefer same-AZ mount target for lowest latency
        for mount_target in self.mount_targets:
            if mount_target['availability_zone'] == instance_az:
                return mount_target
        
        # Fallback to any available mount target
        return self.mount_targets[0] if self.mount_targets else None
```

## Performance Optimization Patterns

### Throughput Mode Selection
```python
class EFSPerformanceOptimizer:
    def __init__(self):
        self.throughput_modes = {
            'bursting': {
                'baseline_throughput_mb_per_tb': 50,
                'burst_throughput_mb_per_tb': 100,
                'burst_credit_balance_mb': 2147483648,  # 2 TiB
                'cost_multiplier': 1.0
            },
            'provisioned': {
                'min_throughput_mb': 1,
                'max_throughput_mb': 1024,
                'cost_per_mb_per_month': 6.00,
                'cost_multiplier': 1.0
            }
        }
    
    def calculate_bursting_performance(self, file_system_size_gb):
        """Calculate bursting mode performance characteristics"""
        
        size_tb = file_system_size_gb / 1024
        baseline_mb_s = size_tb * self.throughput_modes['bursting']['baseline_throughput_mb_per_tb']
        burst_mb_s = size_tb * self.throughput_modes['bursting']['burst_throughput_mb_per_tb']
        
        # Credit accumulation rate (baseline throughput when not in use)
        credit_rate_mb_s = baseline_mb_s
        
        # Burst duration calculation
        burst_duration_hours = (
            self.throughput_modes['bursting']['burst_credit_balance_mb'] / 
            (burst_mb_s - baseline_mb_s) / 3600
        ) if burst_mb_s > baseline_mb_s else float('inf')
        
        return {
            'baseline_throughput_mb_s': baseline_mb_s,
            'burst_throughput_mb_s': burst_mb_s,
            'burst_duration_hours': burst_duration_hours,
            'credit_accumulation_rate': credit_rate_mb_s
        }
    
    def recommend_throughput_mode(self, workload_profile):
        """Recommend throughput mode based on workload characteristics"""
        
        required_throughput = workload_profile['peak_throughput_mb_s']
        file_system_size_gb = workload_profile['file_system_size_gb']
        sustained_duration_hours = workload_profile.get('sustained_duration_hours', 1)
        
        # Calculate bursting mode performance
        bursting_perf = self.calculate_bursting_performance(file_system_size_gb)
        
        # Check if bursting mode can handle the workload
        if required_throughput <= bursting_perf['baseline_throughput_mb_s']:
            return {
                'recommended_mode': 'bursting',
                'rationale': 'Workload fits within baseline throughput',
                'estimated_cost_factor': 1.0
            }
        
        elif (required_throughput <= bursting_perf['burst_throughput_mb_s'] and 
              sustained_duration_hours <= bursting_perf['burst_duration_hours']):
            return {
                'recommended_mode': 'bursting',
                'rationale': 'Workload can use burst credits',
                'estimated_cost_factor': 1.0
            }
        
        else:
            # Need provisioned throughput
            provisioned_cost = required_throughput * self.throughput_modes['provisioned']['cost_per_mb_per_month']
            return {
                'recommended_mode': 'provisioned',
                'provisioned_throughput_mb_s': required_throughput,
                'rationale': 'Sustained high throughput required',
                'additional_monthly_cost': provisioned_cost
            }
```

### Client-Side Caching
```bash
#!/bin/bash
# EFS Intelligent Tiering and Caching Setup

# Install EFS utilities
sudo yum install -y amazon-efs-utils

# Mount with caching enabled
sudo mount -t efs -o tls,_netdev,iam,cache=rw fs-12345678:/ /mnt/efs

# Configure local cache settings
echo "fs-12345678.efs.region.amazonaws.com:/ /mnt/efs efs tls,_netdev,iam,cache=rw 0 0" >> /etc/fstab

# Optimize cache settings for workload
# For read-heavy workloads
echo 'cache=ro' # Read-only cache
# For write-heavy workloads  
echo 'cache=rw' # Read-write cache
# For mixed workloads
echo 'cache=rw,regional' # Regional caching
```

## Security and Access Control Patterns

### EFS Access Points
```python
class EFSAccessPointManager:
    def __init__(self, file_system_id):
        self.file_system_id = file_system_id
        self.efs_client = boto3.client('efs')
    
    def create_application_access_point(self, app_name, uid, gid, path):
        """Create access point for application isolation"""
        
        access_point_config = {
            'FileSystemId': self.file_system_id,
            'PosixUser': {
                'Uid': uid,
                'Gid': gid
            },
            'RootDirectory': {
                'Path': f'/{app_name}',
                'CreationInfo': {
                    'OwnerUid': uid,
                    'OwnerGid': gid,
                    'Permissions': '755'
                }
            },
            'Tags': [
                {'Key': 'Application', 'Value': app_name},
                {'Key': 'Environment', 'Value': 'production'}
            ]
        }
        
        response = self.efs_client.create_access_point(**access_point_config)
        return response['AccessPointArn']
    
    def create_user_access_point(self, username, user_id, group_id):
        """Create access point for user-specific access"""
        
        access_point_config = {
            'FileSystemId': self.file_system_id,
            'PosixUser': {
                'Uid': user_id,
                'Gid': group_id
            },
            'RootDirectory': {
                'Path': f'/users/{username}',
                'CreationInfo': {
                    'OwnerUid': user_id,
                    'OwnerGid': group_id,
                    'Permissions': '700'  # User-only access
                }
            }
        }
        
        response = self.efs_client.create_access_point(**access_point_config)
        return response['AccessPointArn']
```

## Use Case Patterns

### Content Management System
```python
class EFSContentManagement:
    def __init__(self, mount_point='/mnt/efs'):
        self.mount_point = mount_point
        self.content_structure = {
            'uploads': 'user-generated content',
            'media': 'processed media files',
            'cache': 'application cache',
            'logs': 'application logs'
        }
    
    def setup_content_structure(self):
        """Set up directory structure for CMS"""
        
        import os
        
        for directory, purpose in self.content_structure.items():
            dir_path = os.path.join(self.mount_point, directory)
            os.makedirs(dir_path, exist_ok=True)
            
            # Set appropriate permissions
            if directory == 'uploads':
                os.chmod(dir_path, 0o755)  # Read/write for web server
            elif directory == 'cache':
                os.chmod(dir_path, 0o777)  # Full access for caching
            elif directory == 'logs':
                os.chmod(dir_path, 0o644)  # Read-only for most users
        
        return self.content_structure
    
    def implement_backup_strategy(self):
        """Implement backup strategy for content"""
        
        backup_config = {
            'backup_vault': 'efs-content-backup',
            'backup_plan': {
                'daily': {
                    'schedule': 'cron(0 2 * * ? *)',  # 2 AM daily
                    'retention_days': 30
                },
                'weekly': {
                    'schedule': 'cron(0 3 ? * SUN *)',  # 3 AM Sunday
                    'retention_days': 90
                },
                'monthly': {
                    'schedule': 'cron(0 4 1 * ? *)',  # 4 AM 1st of month
                    'retention_days': 365
                }
            }
        }
        
        return backup_config
```

### High Performance Computing (HPC)
```python
class EFSHPCPattern:
    def __init__(self):
        self.hpc_requirements = {
            'performance_mode': 'Max I/O',
            'throughput_mode': 'Provisioned',
            'encryption': True,
            'backup': False  # HPC data often regenerable
        }
    
    def configure_for_hpc(self, expected_nodes, io_pattern):
        """Configure EFS for HPC workloads"""
        
        # Calculate required throughput
        if io_pattern == 'read_intensive':
            throughput_per_node = 50  # MB/s
        elif io_pattern == 'write_intensive':
            throughput_per_node = 25  # MB/s
        else:  # mixed
            throughput_per_node = 35  # MB/s
        
        total_throughput = expected_nodes * throughput_per_node
        
        config = {
            'performance_mode': 'maxIO',
            'throughput_mode': 'provisioned',
            'provisioned_throughput_mb_s': min(total_throughput, 1024),  # EFS limit
            'mount_options': [
                'nfsvers=4.1',
                'rsize=1048576',  # 1MB read size
                'wsize=1048576',  # 1MB write size
                'hard',
                'intr',
                'timeo=600'
            ]
        }
        
        return config
```

## Cost Optimization Patterns

### EFS Intelligent Tiering
```python
class EFSCostOptimizer:
    def __init__(self, file_system_id):
        self.file_system_id = file_system_id
        self.storage_classes = {
            'standard': {'cost_per_gb': 0.30, 'access_cost': 0},
            'infrequent_access': {'cost_per_gb': 0.025, 'access_cost': 0.01}
        }
    
    def enable_intelligent_tiering(self):
        """Enable EFS Intelligent Tiering"""
        
        lifecycle_policy = {
            'TransitionToIA': 'AFTER_30_DAYS',
            'TransitionToPrimaryStorageClass': 'AFTER_1_ACCESS'
        }
        
        return lifecycle_policy
    
    def calculate_cost_savings(self, file_system_size_gb, access_pattern):
        """Calculate potential cost savings with Intelligent Tiering"""
        
        # Assume 80% of data becomes infrequently accessed after 30 days
        ia_percentage = 0.8
        standard_percentage = 0.2
        
        # Standard storage cost
        standard_cost = file_system_size_gb * self.storage_classes['standard']['cost_per_gb']
        
        # Intelligent Tiering cost
        standard_portion = file_system_size_gb * standard_percentage
        ia_portion = file_system_size_gb * ia_percentage
        
        it_storage_cost = (
            standard_portion * self.storage_classes['standard']['cost_per_gb'] +
            ia_portion * self.storage_classes['infrequent_access']['cost_per_gb']
        )
        
        # Add access costs for IA data
        monthly_ia_accesses = access_pattern.get('ia_accesses_per_month', 0)
        it_access_cost = monthly_ia_accesses * self.storage_classes['infrequent_access']['access_cost']
        
        total_it_cost = it_storage_cost + it_access_cost
        savings = standard_cost - total_it_cost
        
        return {
            'standard_cost': standard_cost,
            'intelligent_tiering_cost': total_it_cost,
            'monthly_savings': savings,
            'savings_percentage': (savings / standard_cost) * 100
        }
```

## Monitoring and Troubleshooting

### EFS Performance Monitoring
```python
class EFSMonitoring:
    def __init__(self, file_system_id):
        self.file_system_id = file_system_id
        self.cloudwatch = boto3.client('cloudwatch')
    
    def get_performance_metrics(self, hours=24):
        """Get EFS performance metrics from CloudWatch"""
        
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(hours=hours)
        
        metrics = {}
        
        # Throughput metrics
        for metric_name in ['TotalIOBytes', 'DataReadIOBytes', 'DataWriteIOBytes']:
            response = self.cloudwatch.get_metric_statistics(
                Namespace='AWS/EFS',
                MetricName=metric_name,
                Dimensions=[{'Name': 'FileSystemId', 'Value': self.file_system_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=3600,  # 1 hour
                Statistics=['Sum', 'Average']
            )
            metrics[metric_name] = response['Datapoints']
        
        return metrics
    
    def analyze_performance_bottlenecks(self, metrics):
        """Analyze metrics to identify performance bottlenecks"""
        
        issues = []
        
        # Check for throughput limitations
        total_io = metrics.get('TotalIOBytes', [])
        if total_io:
            avg_throughput_mb_s = sum(dp['Average'] for dp in total_io) / len(total_io) / 1024 / 1024
            
            if avg_throughput_mb_s < 10:
                issues.append({
                    'type': 'low_throughput',
                    'description': f'Average throughput ({avg_throughput_mb_s:.1f} MB/s) is low',
                    'recommendation': 'Consider provisioned throughput mode'
                })
        
        # Check read/write balance
        read_io = metrics.get('DataReadIOBytes', [])
        write_io = metrics.get('DataWriteIOBytes', [])
        
        if read_io and write_io:
            total_read = sum(dp['Sum'] for dp in read_io)
            total_write = sum(dp['Sum'] for dp in write_io)
            
            if total_write > total_read * 3:
                issues.append({
                    'type': 'write_heavy',
                    'description': 'Workload is write-heavy',
                    'recommendation': 'Consider optimizing write patterns or caching'
                })
        
        return issues
```

## Best Practices

### Mount Optimization
```bash
#!/bin/bash
# Optimized EFS mount options for different use cases

# General purpose (balanced performance)
mount -t efs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,intr,timeo=600 \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs

# Read-heavy workloads
mount -t efs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,intr,timeo=600,cache=strict \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs

# Write-heavy workloads  
mount -t efs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,intr,timeo=600,sync \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs

# High availability (with stunnel for encryption)
mount -t efs -o tls,_netdev,iam \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs
```

### Security Best Practices
```json
{
  "efs_security_checklist": [
    "Enable encryption at rest and in transit",
    "Use IAM policies for access control",
    "Implement VPC security groups",
    "Use EFS Access Points for application isolation",
    "Enable AWS CloudTrail for API logging",
    "Regular security assessments",
    "Backup and disaster recovery planning"
  ],
  "security_group_rules": {
    "inbound": [
      {
        "protocol": "TCP",
        "port": 2049,
        "source": "application-security-group",
        "description": "NFS access from application servers"
      }
    ],
    "outbound": [
      {
        "protocol": "TCP",
        "port": 2049,
        "destination": "0.0.0.0/0",
        "description": "NFS outbound access"
      }
    ]
  }
}
```

## Conclusion

Amazon EFS design patterns enable building scalable, high-performance shared file systems for various use cases. Success requires understanding performance characteristics, implementing appropriate security measures, optimizing costs through Intelligent Tiering, and following best practices for mounting and access control. The key is matching EFS configuration to specific application requirements and access patterns.
