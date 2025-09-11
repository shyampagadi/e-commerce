# Amazon FSx Design Patterns

## Overview
Amazon FSx provides fully managed file systems optimized for specific use cases including high-performance computing, Windows-based applications, and Lustre-based workloads. FSx offers multiple file system types with different performance and feature characteristics.

## FSx File System Types

### FSx for Windows File Server
```
Use Cases:
- Windows-based applications
- Active Directory integration
- SMB protocol requirements
- Microsoft SQL Server
- Content repositories

Features:
- Full Windows NTFS support
- Active Directory integration
- SMB 2.0/3.0 protocol
- Shadow copies (snapshots)
- Data deduplication
```

### FSx for Lustre
```
Use Cases:
- High Performance Computing (HPC)
- Machine learning training
- Media processing
- Financial modeling
- Scientific computing

Features:
- POSIX-compliant
- Parallel file system
- S3 integration
- Sub-millisecond latencies
- Hundreds of GB/s throughput
```

### FSx for NetApp ONTAP
```
Use Cases:
- Enterprise applications
- Multi-protocol access (NFS, SMB, iSCSI)
- Data management features
- Hybrid cloud deployments

Features:
- NetApp ONTAP features
- Storage efficiency
- Data protection
- Multi-protocol support
```

### FSx for OpenZFS
```
Use Cases:
- Linux-based workloads
- Database storage
- Analytics workloads
- Development environments

Features:
- OpenZFS file system
- Point-in-time snapshots
- Data compression
- High performance
```

## FSx for Lustre Design Patterns

### HPC Workload Pattern
```python
class FSxLustreHPC:
    def __init__(self):
        self.deployment_types = {
            'scratch_1': {
                'throughput_per_tib': 200,  # MB/s per TiB
                'storage_type': 'SSD',
                'use_case': 'temporary high-performance storage',
                'cost_per_month_per_tib': 140
            },
            'scratch_2': {
                'throughput_per_tib': 250,  # MB/s per TiB
                'storage_type': 'SSD',
                'use_case': 'higher performance temporary storage',
                'cost_per_month_per_tib': 150
            },
            'persistent_1': {
                'throughput_per_tib': 50,   # MB/s per TiB
                'storage_type': 'HDD',
                'use_case': 'long-term storage with moderate performance',
                'cost_per_month_per_tib': 140
            },
            'persistent_2': {
                'throughput_per_tib': 125,  # MB/s per TiB
                'storage_type': 'SSD',
                'use_case': 'long-term storage with high performance',
                'cost_per_month_per_tib': 245
            }
        }
    
    def design_for_workload(self, workload_requirements):
        """Design FSx for Lustre based on workload requirements"""
        
        required_capacity_tib = workload_requirements['capacity_gb'] / 1024
        required_throughput = workload_requirements['throughput_mb_s']
        duration_days = workload_requirements.get('duration_days', 30)
        data_persistence = workload_requirements.get('persistent', False)
        
        recommendations = []
        
        for deployment_type, specs in self.deployment_types.items():
            # Check if persistent requirement matches
            is_persistent = 'persistent' in deployment_type
            if data_persistence and not is_persistent:
                continue
            if not data_persistence and is_persistent and duration_days < 7:
                continue  # Scratch is better for short-term workloads
            
            # Calculate capacity needed for throughput requirement
            capacity_for_throughput = required_throughput / specs['throughput_per_tib']
            final_capacity = max(required_capacity_tib, capacity_for_throughput)
            
            # Calculate cost
            monthly_cost = final_capacity * specs['cost_per_month_per_tib']
            total_cost = monthly_cost * (duration_days / 30)
            
            recommendations.append({
                'deployment_type': deployment_type,
                'capacity_tib': final_capacity,
                'throughput_mb_s': final_capacity * specs['throughput_per_tib'],
                'monthly_cost': monthly_cost,
                'total_cost': total_cost,
                'storage_type': specs['storage_type'],
                'use_case': specs['use_case']
            })
        
        # Sort by cost efficiency
        recommendations.sort(key=lambda x: x['total_cost'])
        return recommendations
```

### S3 Integration Pattern
```python
class FSxLustreS3Integration:
    def __init__(self, s3_bucket, s3_prefix=''):
        self.s3_bucket = s3_bucket
        self.s3_prefix = s3_prefix
        self.fsx_client = boto3.client('fsx')
    
    def create_s3_linked_filesystem(self, subnet_ids, security_group_ids):
        """Create FSx for Lustre with S3 integration"""
        
        filesystem_config = {
            'FileSystemType': 'LUSTRE',
            'StorageCapacity': 1200,  # Minimum for S3 integration
            'SubnetIds': subnet_ids,
            'SecurityGroupIds': security_group_ids,
            'LustreConfiguration': {
                'ImportPath': f's3://{self.s3_bucket}/{self.s3_prefix}',
                'ExportPath': f's3://{self.s3_bucket}/{self.s3_prefix}/results',
                'ImportedFileChunkSize': 1024,  # 1 GiB chunks
                'DeploymentType': 'SCRATCH_2',
                'DataCompressionType': 'LZ4'
            },
            'Tags': [
                {'Key': 'Purpose', 'Value': 'HPC-S3-Integration'},
                {'Key': 'DataSource', 'Value': self.s3_bucket}
            ]
        }
        
        response = self.fsx_client.create_file_system(**filesystem_config)
        return response['FileSystem']
    
    def setup_data_pipeline(self):
        """Set up data pipeline with S3 and FSx for Lustre"""
        
        pipeline_config = {
            'data_ingestion': {
                'source': f's3://{self.s3_bucket}/{self.s3_prefix}',
                'method': 'lazy_loading',  # Load data on first access
                'chunk_size': '1GiB'
            },
            'processing': {
                'filesystem': 'FSx for Lustre',
                'mount_point': '/fsx',
                'parallel_access': True
            },
            'data_export': {
                'destination': f's3://{self.s3_bucket}/{self.s3_prefix}/results',
                'method': 'hsm_archive',  # Hierarchical Storage Management
                'compression': 'LZ4'
            }
        }
        
        return pipeline_config
```

## FSx for Windows File Server Patterns

### Active Directory Integration
```python
class FSxWindowsADIntegration:
    def __init__(self, domain_name, ou_path=None):
        self.domain_name = domain_name
        self.ou_path = ou_path or f'CN=Computers,DC={domain_name.replace(".", ",DC=")}'
        self.fsx_client = boto3.client('fsx')
    
    def create_ad_integrated_filesystem(self, subnet_ids, security_group_ids, 
                                      admin_password, storage_capacity=32):
        """Create FSx for Windows with Active Directory integration"""
        
        filesystem_config = {
            'FileSystemType': 'WINDOWS',
            'StorageCapacity': storage_capacity,  # Minimum 32 GiB
            'SubnetIds': subnet_ids,
            'SecurityGroupIds': security_group_ids,
            'WindowsConfiguration': {
                'ActiveDirectoryId': self.get_directory_id(),
                'ThroughputCapacity': 8,  # MB/s
                'WeeklyMaintenanceStartTime': '7:02:00',  # Sunday 2 AM
                'DailyAutomaticBackupStartTime': '01:00',
                'AutomaticBackupRetentionDays': 7,
                'CopyTagsToBackups': True,
                'DeploymentType': 'MULTI_AZ_1'  # High availability
            },
            'Tags': [
                {'Key': 'Environment', 'Value': 'Production'},
                {'Key': 'Domain', 'Value': self.domain_name}
            ]
        }
        
        response = self.fsx_client.create_file_system(**filesystem_config)
        return response['FileSystem']
    
    def get_directory_id(self):
        """Get AWS Managed Microsoft AD directory ID"""
        ds_client = boto3.client('ds')
        
        response = ds_client.describe_directories()
        for directory in response['DirectoryDescriptions']:
            if directory['Name'] == self.domain_name:
                return directory['DirectoryId']
        
        raise ValueError(f"Directory {self.domain_name} not found")
    
    def configure_file_shares(self, filesystem_dns_name):
        """Configure file shares for different departments"""
        
        shares_config = {
            'shares': [
                {
                    'name': 'Finance',
                    'path': '\\\\' + filesystem_dns_name + '\\share\\Finance',
                    'permissions': ['DOMAIN\\Finance-Users:Full', 'DOMAIN\\Finance-Admins:Full'],
                    'description': 'Finance department shared files'
                },
                {
                    'name': 'HR',
                    'path': '\\\\' + filesystem_dns_name + '\\share\\HR',
                    'permissions': ['DOMAIN\\HR-Users:Modify', 'DOMAIN\\HR-Admins:Full'],
                    'description': 'Human Resources shared files'
                },
                {
                    'name': 'Common',
                    'path': '\\\\' + filesystem_dns_name + '\\share\\Common',
                    'permissions': ['DOMAIN\\Domain Users:Read', 'DOMAIN\\Admins:Full'],
                    'description': 'Company-wide shared resources'
                }
            ]
        }
        
        return shares_config
```

### SQL Server Integration Pattern
```python
class FSxSQLServerIntegration:
    def __init__(self):
        self.sql_server_requirements = {
            'database_files': {
                'throughput_mb_s': 16,  # Minimum for SQL Server
                'iops': 3000,
                'latency_ms': 10
            },
            'log_files': {
                'throughput_mb_s': 8,
                'iops': 1000,
                'latency_ms': 5
            },
            'backup_files': {
                'throughput_mb_s': 32,
                'iops': 500,
                'latency_ms': 20
            }
        }
    
    def design_for_sql_server(self, database_size_gb, expected_users):
        """Design FSx for Windows for SQL Server workloads"""
        
        # Calculate storage requirements
        database_storage = database_size_gb * 1.2  # 20% growth buffer
        log_storage = database_size_gb * 0.25      # 25% for transaction logs
        backup_storage = database_size_gb * 2      # Full + differential backups
        
        total_storage = database_storage + log_storage + backup_storage
        
        # Calculate throughput requirements based on users
        base_throughput = 8  # MB/s
        user_throughput = expected_users * 0.1  # 0.1 MB/s per user
        required_throughput = max(base_throughput, user_throughput)
        
        # FSx for Windows throughput options
        throughput_options = [8, 16, 32, 64, 128, 256, 512, 1024, 2048]
        selected_throughput = min(opt for opt in throughput_options if opt >= required_throughput)
        
        config = {
            'storage_capacity_gb': max(32, int(total_storage)),  # Minimum 32 GB
            'throughput_capacity_mb_s': selected_throughput,
            'deployment_type': 'MULTI_AZ_1' if expected_users > 50 else 'SINGLE_AZ_2',
            'backup_retention_days': 30,  # Extended retention for databases
            'maintenance_window': '7:02:00',  # Sunday 2 AM
            'estimated_monthly_cost': self.calculate_cost(total_storage, selected_throughput)
        }
        
        return config
    
    def calculate_cost(self, storage_gb, throughput_mb_s):
        """Calculate estimated monthly cost"""
        
        # FSx for Windows pricing (example rates)
        storage_cost_per_gb = 0.13
        throughput_cost_per_mb_s = 2.20
        
        monthly_cost = (storage_gb * storage_cost_per_gb) + (throughput_mb_s * throughput_cost_per_mb_s)
        return monthly_cost
```

## Performance Optimization Patterns

### Multi-Mount Target Strategy
```python
class FSxPerformanceOptimization:
    def __init__(self, filesystem_type):
        self.filesystem_type = filesystem_type
        self.performance_characteristics = {
            'lustre_scratch_2': {
                'max_throughput_per_tib': 250,
                'max_iops_per_tib': 500000,
                'latency_ms': 0.2
            },
            'windows_multi_az': {
                'max_throughput_mb_s': 2048,
                'max_iops': 100000,
                'latency_ms': 1.0
            }
        }
    
    def optimize_client_connections(self, client_count, workload_type):
        """Optimize client connections for performance"""
        
        if self.filesystem_type == 'lustre':
            return self.optimize_lustre_clients(client_count, workload_type)
        elif self.filesystem_type == 'windows':
            return self.optimize_windows_clients(client_count, workload_type)
    
    def optimize_lustre_clients(self, client_count, workload_type):
        """Optimize Lustre client configuration"""
        
        mount_options = ['flock', 'user_xattr', 'lazystatfs']
        
        if workload_type == 'read_intensive':
            mount_options.extend(['ro', 'noatime'])
        elif workload_type == 'write_intensive':
            mount_options.extend(['rw', 'relatime'])
        
        # Optimize for client count
        if client_count > 100:
            mount_options.append('flock')  # Enable file locking
        
        client_config = {
            'mount_options': ','.join(mount_options),
            'stripe_count': min(8, client_count // 10),  # Lustre striping
            'stripe_size': '1M',  # 1 MB stripe size
            'max_read_ahead_mb': 64,
            'max_write_behind_mb': 64
        }
        
        return client_config
    
    def optimize_windows_clients(self, client_count, workload_type):
        """Optimize Windows client configuration"""
        
        client_config = {
            'smb_version': '3.1.1',
            'smb_multichannel': True if client_count < 50 else False,
            'cache_mode': 'read_write' if workload_type == 'mixed' else 'read_only',
            'buffer_size_kb': 64,
            'timeout_seconds': 60
        }
        
        return client_config
```

## Backup and Disaster Recovery Patterns

### Automated Backup Strategy
```python
class FSxBackupStrategy:
    def __init__(self, filesystem_id, filesystem_type):
        self.filesystem_id = filesystem_id
        self.filesystem_type = filesystem_type
        self.fsx_client = boto3.client('fsx')
    
    def create_backup_schedule(self, retention_requirements):
        """Create automated backup schedule"""
        
        if self.filesystem_type == 'WINDOWS':
            # Windows File Server supports automatic backups
            backup_config = {
                'DailyAutomaticBackupStartTime': '02:00',
                'AutomaticBackupRetentionDays': retention_requirements.get('daily', 7),
                'CopyTagsToBackups': True
            }
        else:
            # Manual backup schedule for other types
            backup_config = {
                'schedule_expression': 'cron(0 2 * * ? *)',  # Daily at 2 AM
                'retention_days': retention_requirements.get('daily', 7),
                'backup_type': 'USER_INITIATED'
            }
        
        return backup_config
    
    def create_manual_backup(self, backup_name=None):
        """Create manual backup"""
        
        if not backup_name:
            backup_name = f"manual-backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        
        response = self.fsx_client.create_backup(
            FileSystemId=self.filesystem_id,
            Tags=[
                {'Key': 'BackupType', 'Value': 'Manual'},
                {'Key': 'CreatedBy', 'Value': 'BackupStrategy'}
            ]
        )
        
        return response['Backup']
    
    def implement_cross_region_backup(self, target_region):
        """Implement cross-region backup strategy"""
        
        cross_region_config = {
            'source_region': boto3.Session().region_name,
            'target_region': target_region,
            'backup_frequency': 'weekly',
            'retention_weeks': 12,
            'encryption': True,
            'cost_optimization': {
                'use_ia_storage': True,
                'lifecycle_days': 30
            }
        }
        
        return cross_region_config
```

## Cost Optimization Patterns

### Right-Sizing Strategy
```python
class FSxCostOptimization:
    def __init__(self):
        self.pricing = {
            'lustre_scratch_1': {'storage_per_tib': 140, 'throughput_included': True},
            'lustre_scratch_2': {'storage_per_tib': 150, 'throughput_included': True},
            'lustre_persistent_1': {'storage_per_tib': 140, 'throughput_included': True},
            'lustre_persistent_2': {'storage_per_tib': 245, 'throughput_included': True},
            'windows_ssd': {'storage_per_gb': 0.13, 'throughput_per_mb_s': 2.20},
            'windows_hdd': {'storage_per_gb': 0.08, 'throughput_per_mb_s': 2.20}
        }
    
    def analyze_usage_patterns(self, filesystem_id, days=30):
        """Analyze filesystem usage patterns for optimization"""
        
        cloudwatch = boto3.client('cloudwatch')
        
        # Get storage utilization
        storage_metrics = cloudwatch.get_metric_statistics(
            Namespace='AWS/FSx',
            MetricName='StorageUtilization',
            Dimensions=[{'Name': 'FileSystemId', 'Value': filesystem_id}],
            StartTime=datetime.utcnow() - timedelta(days=days),
            EndTime=datetime.utcnow(),
            Period=86400,  # Daily
            Statistics=['Average', 'Maximum']
        )
        
        # Get throughput utilization
        throughput_metrics = cloudwatch.get_metric_statistics(
            Namespace='AWS/FSx',
            MetricName='ThroughputUtilization',
            Dimensions=[{'Name': 'FileSystemId', 'Value': filesystem_id}],
            StartTime=datetime.utcnow() - timedelta(days=days),
            EndTime=datetime.utcnow(),
            Period=3600,  # Hourly
            Statistics=['Average', 'Maximum']
        )
        
        analysis = {
            'storage_utilization': {
                'average': sum(dp['Average'] for dp in storage_metrics['Datapoints']) / len(storage_metrics['Datapoints']) if storage_metrics['Datapoints'] else 0,
                'peak': max(dp['Maximum'] for dp in storage_metrics['Datapoints']) if storage_metrics['Datapoints'] else 0
            },
            'throughput_utilization': {
                'average': sum(dp['Average'] for dp in throughput_metrics['Datapoints']) / len(throughput_metrics['Datapoints']) if throughput_metrics['Datapoints'] else 0,
                'peak': max(dp['Maximum'] for dp in throughput_metrics['Datapoints']) if throughput_metrics['Datapoints'] else 0
            }
        }
        
        return analysis
    
    def recommend_optimizations(self, usage_analysis, current_config):
        """Recommend cost optimizations based on usage patterns"""
        
        recommendations = []
        
        # Storage optimization
        if usage_analysis['storage_utilization']['average'] < 50:
            recommendations.append({
                'type': 'storage_reduction',
                'description': 'Consider reducing storage capacity',
                'potential_savings': '20-40%',
                'risk': 'Monitor growth trends'
            })
        
        # Throughput optimization
        if usage_analysis['throughput_utilization']['peak'] < 60:
            recommendations.append({
                'type': 'throughput_reduction',
                'description': 'Consider reducing provisioned throughput',
                'potential_savings': '15-30%',
                'risk': 'May impact peak performance'
            })
        
        # Deployment type optimization
        if current_config.get('deployment_type') == 'MULTI_AZ_1':
            if usage_analysis['throughput_utilization']['average'] < 30:
                recommendations.append({
                    'type': 'deployment_type_change',
                    'description': 'Consider SINGLE_AZ_2 for cost savings',
                    'potential_savings': '20%',
                    'risk': 'Reduced availability'
                })
        
        return recommendations
```

## Best Practices

### Security Best Practices
```json
{
  "fsx_security_checklist": [
    "Enable encryption at rest and in transit",
    "Use VPC security groups for network access control",
    "Implement least privilege access with IAM",
    "Enable AWS CloudTrail for API logging",
    "Regular backup and recovery testing",
    "Monitor file system access patterns",
    "Use AWS Config for compliance monitoring"
  ],
  "network_security": {
    "security_group_rules": {
      "lustre": [
        {"protocol": "TCP", "port": 988, "description": "Lustre client access"},
        {"protocol": "TCP", "port": "1018-1023", "description": "Lustre management"}
      ],
      "windows": [
        {"protocol": "TCP", "port": 445, "description": "SMB file sharing"},
        {"protocol": "TCP", "port": 135, "description": "RPC endpoint mapper"}
      ]
    }
  }
}
```

### Performance Best Practices
```yaml
performance_optimization:
  lustre:
    - Use appropriate deployment type for workload
    - Optimize stripe count and size
    - Enable data compression when appropriate
    - Use S3 integration for data lifecycle
    - Monitor and tune client configurations
  
  windows:
    - Right-size throughput capacity
    - Use Multi-AZ for high availability
    - Enable deduplication for space efficiency
    - Optimize SMB client settings
    - Regular maintenance windows
  
  general:
    - Monitor CloudWatch metrics
    - Implement automated backups
    - Test disaster recovery procedures
    - Regular performance reviews
    - Cost optimization analysis
```

## Conclusion

Amazon FSx design patterns provide the foundation for building high-performance, scalable file systems for various workloads. Success requires understanding the specific characteristics of each FSx file system type, implementing appropriate performance optimizations, and following security and cost optimization best practices. The key is matching FSx capabilities to specific application requirements and operational needs.
