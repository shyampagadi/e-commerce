# RDS Database Setup

## Overview
Learn to set up and manage AWS RDS databases for production applications.

## RDS Instance Creation

### PostgreSQL Setup
```bash
# Create DB subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name my-app-db-subnet-group \
    --db-subnet-group-description "Subnet group for my app database" \
    --subnet-ids subnet-12345678 subnet-87654321

# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier my-app-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username dbadmin \
    --master-user-password MySecurePassword123! \
    --allocated-storage 20 \
    --storage-type gp2 \
    --storage-encrypted \
    --vpc-security-group-ids sg-12345678 \
    --db-subnet-group-name my-app-db-subnet-group \
    --backup-retention-period 7 \
    --multi-az \
    --auto-minor-version-upgrade \
    --deletion-protection
```

### MySQL Setup
```yaml
# mysql-rds.yml
Resources:
  DBInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: my-app-mysql-db
      DBInstanceClass: db.t3.micro
      Engine: mysql
      EngineVersion: 8.0.35
      MasterUsername: admin
      MasterUserPassword: !Ref DBPassword
      AllocatedStorage: 20
      StorageType: gp2
      StorageEncrypted: true
      VPCSecurityGroups:
        - !Ref DatabaseSecurityGroup
      DBSubnetGroupName: !Ref DBSubnetGroup
      BackupRetentionPeriod: 7
      MultiAZ: true
      AutoMinorVersionUpgrade: true
      DeletionProtection: true
      EnablePerformanceInsights: true
      PerformanceInsightsRetentionPeriod: 7
      
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: Subnet group for RDS database
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      Tags:
        - Key: Name
          Value: MyApp-DB-SubnetGroup
```

## Security Configuration

### Security Groups
```yaml
DatabaseSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for RDS database
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 5432
        ToPort: 5432
        SourceSecurityGroupId: !Ref ApplicationSecurityGroup
        Description: PostgreSQL access from application servers
      - IpProtocol: tcp
        FromPort: 3306
        ToPort: 3306
        SourceSecurityGroupId: !Ref ApplicationSecurityGroup
        Description: MySQL access from application servers
    Tags:
      - Key: Name
        Value: Database-SG
```

### Parameter Groups
```bash
# Create custom parameter group
aws rds create-db-parameter-group \
    --db-parameter-group-name my-app-postgres-params \
    --db-parameter-group-family postgres15 \
    --description "Custom parameters for my app"

# Modify parameters
aws rds modify-db-parameter-group \
    --db-parameter-group-name my-app-postgres-params \
    --parameters ParameterName=shared_preload_libraries,ParameterValue=pg_stat_statements,ApplyMethod=pending-reboot \
    --parameters ParameterName=log_statement,ParameterValue=all,ApplyMethod=immediate \
    --parameters ParameterName=log_min_duration_statement,ParameterValue=1000,ApplyMethod=immediate
```

## High Availability Setup

### Multi-AZ Deployment
```yaml
ProductionDatabase:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: prod-app-db
    DBInstanceClass: db.r5.large
    Engine: postgres
    EngineVersion: 15.4
    MasterUsername: !Ref DBUsername
    MasterUserPassword: !Ref DBPassword
    AllocatedStorage: 100
    StorageType: gp3
    StorageEncrypted: true
    KmsKeyId: !Ref DatabaseKMSKey
    MultiAZ: true
    BackupRetentionPeriod: 30
    PreferredBackupWindow: "03:00-04:00"
    PreferredMaintenanceWindow: "sun:04:00-sun:05:00"
    DeletionProtection: true
    EnablePerformanceInsights: true
    PerformanceInsightsKMSKeyId: !Ref DatabaseKMSKey
    PerformanceInsightsRetentionPeriod: 31
    MonitoringInterval: 60
    MonitoringRoleArn: !GetAtt RDSEnhancedMonitoringRole.Arn
```

### Read Replicas
```bash
# Create read replica
aws rds create-db-instance-read-replica \
    --db-instance-identifier my-app-db-replica \
    --source-db-instance-identifier my-app-db \
    --db-instance-class db.t3.micro \
    --publicly-accessible false \
    --auto-minor-version-upgrade true \
    --enable-performance-insights \
    --performance-insights-retention-period 7
```

## Database Migration

### Schema Migration
```sql
-- Create application database
CREATE DATABASE ecommerce_app;

-- Create application user
CREATE USER app_user WITH PASSWORD 'secure_password_here';

-- Grant permissions
GRANT CONNECT ON DATABASE ecommerce_app TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT CREATE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Set default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO app_user;
```

### Data Migration Script
```python
#!/usr/bin/env python3
import psycopg2
import os
import sys
from datetime import datetime

def migrate_data():
    # Source database connection
    source_conn = psycopg2.connect(
        host=os.getenv('SOURCE_DB_HOST'),
        database=os.getenv('SOURCE_DB_NAME'),
        user=os.getenv('SOURCE_DB_USER'),
        password=os.getenv('SOURCE_DB_PASSWORD')
    )
    
    # Target RDS connection
    target_conn = psycopg2.connect(
        host=os.getenv('RDS_ENDPOINT'),
        database=os.getenv('RDS_DB_NAME'),
        user=os.getenv('RDS_USER'),
        password=os.getenv('RDS_PASSWORD')
    )
    
    try:
        source_cur = source_conn.cursor()
        target_cur = target_conn.cursor()
        
        # Get table list
        source_cur.execute("""
            SELECT tablename FROM pg_tables 
            WHERE schemaname = 'public'
        """)
        tables = source_cur.fetchall()
        
        for table in tables:
            table_name = table[0]
            print(f"Migrating table: {table_name}")
            
            # Copy data
            source_cur.execute(f"SELECT * FROM {table_name}")
            rows = source_cur.fetchall()
            
            if rows:
                # Get column names
                source_cur.execute(f"""
                    SELECT column_name FROM information_schema.columns 
                    WHERE table_name = '{table_name}' 
                    ORDER BY ordinal_position
                """)
                columns = [col[0] for col in source_cur.fetchall()]
                
                # Insert data
                placeholders = ','.join(['%s'] * len(columns))
                insert_query = f"INSERT INTO {table_name} ({','.join(columns)}) VALUES ({placeholders})"
                
                target_cur.executemany(insert_query, rows)
                target_conn.commit()
                print(f"Migrated {len(rows)} rows to {table_name}")
        
        print("Migration completed successfully!")
        
    except Exception as e:
        print(f"Migration failed: {e}")
        target_conn.rollback()
        sys.exit(1)
    finally:
        source_conn.close()
        target_conn.close()

if __name__ == "__main__":
    migrate_data()
```

## Backup and Recovery

### Automated Backups
```yaml
BackupConfiguration:
  BackupRetentionPeriod: 30
  PreferredBackupWindow: "03:00-04:00"
  PreferredMaintenanceWindow: "sun:04:00-sun:05:00"
  DeleteAutomatedBackups: false
  DeletionProtection: true
```

### Manual Snapshots
```bash
# Create manual snapshot
aws rds create-db-snapshot \
    --db-instance-identifier my-app-db \
    --db-snapshot-identifier my-app-db-snapshot-$(date +%Y%m%d-%H%M%S)

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier my-app-db-restored \
    --db-snapshot-identifier my-app-db-snapshot-20240101-120000 \
    --db-instance-class db.t3.micro
```

### Point-in-Time Recovery
```bash
# Restore to specific time
aws rds restore-db-instance-to-point-in-time \
    --source-db-instance-identifier my-app-db \
    --target-db-instance-identifier my-app-db-pitr \
    --restore-time 2024-01-01T12:00:00.000Z \
    --db-instance-class db.t3.micro
```

## Performance Optimization

### Connection Pooling
```python
# connection_pool.py
import psycopg2.pool
import os

class DatabasePool:
    def __init__(self):
        self.pool = psycopg2.pool.ThreadedConnectionPool(
            minconn=1,
            maxconn=20,
            host=os.getenv('RDS_ENDPOINT'),
            database=os.getenv('RDS_DB_NAME'),
            user=os.getenv('RDS_USER'),
            password=os.getenv('RDS_PASSWORD'),
            port=5432
        )
    
    def get_connection(self):
        return self.pool.getconn()
    
    def put_connection(self, conn):
        self.pool.putconn(conn)
    
    def close_all(self):
        self.pool.closeall()

# Usage
db_pool = DatabasePool()

def execute_query(query, params=None):
    conn = db_pool.get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(query, params)
            return cur.fetchall()
    finally:
        db_pool.put_connection(conn)
```

### Query Optimization
```sql
-- Create indexes for better performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);
CREATE INDEX CONCURRENTLY idx_products_category_id ON products(category_id);
CREATE INDEX CONCURRENTLY idx_order_items_order_id ON order_items(order_id);

-- Analyze query performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT p.name, p.price, c.name as category 
FROM products p 
JOIN categories c ON p.category_id = c.id 
WHERE p.price > 100;
```

## Monitoring and Alerting

### CloudWatch Metrics
```yaml
DatabaseAlarms:
  CPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: RDS-HighCPU
      AlarmDescription: RDS CPU utilization is too high
      MetricName: CPUUtilization
      Namespace: AWS/RDS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: DBInstanceIdentifier
          Value: !Ref DBInstance
      AlarmActions:
        - !Ref SNSTopic
        
  ConnectionAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: RDS-HighConnections
      AlarmDescription: RDS connection count is too high
      MetricName: DatabaseConnections
      Namespace: AWS/RDS
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      Dimensions:
        - Name: DBInstanceIdentifier
          Value: !Ref DBInstance
```

### Performance Insights
```bash
# Get Performance Insights metrics
aws pi get-resource-metrics \
    --service-type RDS \
    --identifier db-ABCDEFGHIJKLMNOPQRSTUVWXYZ \
    --metric-queries '[{
        "Metric": "db.SQL.Innodb_rows_read.avg",
        "GroupBy": {"Group": "db.sql_tokenized.statement"}
    }]' \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period-in-seconds 3600
```

## Security Best Practices

### Encryption
```yaml
DatabaseEncryption:
  StorageEncrypted: true
  KmsKeyId: !Ref DatabaseKMSKey
  
DatabaseKMSKey:
  Type: AWS::KMS::Key
  Properties:
    Description: KMS key for RDS encryption
    KeyPolicy:
      Statement:
        - Sid: Enable IAM User Permissions
          Effect: Allow
          Principal:
            AWS: !Sub "arn:aws:iam::${AWS::AccountId}:root"
          Action: "kms:*"
          Resource: "*"
```

### Network Security
```yaml
DatabaseSubnetGroup:
  Type: AWS::RDS::DBSubnetGroup
  Properties:
    DBSubnetGroupDescription: Private subnets for RDS
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    Tags:
      - Key: Name
        Value: Database-SubnetGroup
```

## Troubleshooting

### Common Issues
1. **Connection timeouts**: Check security groups and network ACLs
2. **High CPU usage**: Review slow queries and add indexes
3. **Storage full**: Monitor storage metrics and enable auto-scaling

### Diagnostic Commands
```bash
# Check RDS status
aws rds describe-db-instances --db-instance-identifier my-app-db

# View recent events
aws rds describe-events --source-identifier my-app-db --source-type db-instance

# Check parameter group
aws rds describe-db-parameters --db-parameter-group-name my-app-postgres-params

# Monitor connections
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier,Value=my-app-db \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T23:59:59Z \
    --period 300 \
    --statistics Average,Maximum
```
