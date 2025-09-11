# Practical Implementation Assessment

## Overview
**Duration**: 120 minutes  
**Format**: Hands-on coding and configuration tasks  
**Environment**: AWS cloud environment with pre-configured access  
**Scoring**: 30% of total module assessment  
**Passing Score**: 70% (21/30 points)

## Assessment Structure

### Task Distribution
```yaml
Task 1: Stream Processing Implementation (8 points - 30 minutes)
Task 2: Batch Processing Optimization (8 points - 30 minutes)  
Task 3: Data Pipeline Design (7 points - 30 minutes)
Task 4: Performance Monitoring Setup (7 points - 30 minutes)

Total: 30 points across 4 practical tasks
```

## Task 1: Stream Processing Implementation (8 points)

### Scenario
Implement a real-time event processing system for an e-commerce platform that processes user clickstream data and generates real-time metrics.

### Requirements
```yaml
Data Source: 
  - Simulated clickstream events (JSON format)
  - 1,000 events/second sustained rate
  - Event types: page_view, add_to_cart, purchase, search

Processing Requirements:
  - Real-time aggregations (5-minute windows)
  - User session reconstruction
  - Anomaly detection for unusual patterns
  - Output to dashboard and alerts

Performance Targets:
  - End-to-end latency < 30 seconds
  - 99.9% processing success rate
  - Auto-scaling capability
```

### Implementation Tasks

#### Task 1.1: Kinesis Stream Setup (2 points)
Create and configure a Kinesis Data Stream with optimal settings.

**Required Configuration:**
```bash
# Create Kinesis stream with proper sharding
aws kinesis create-stream \
    --stream-name ecommerce-clickstream \
    --shard-count 5 \
    --stream-mode-details StreamMode=PROVISIONED

# Configure retention period
aws kinesis increase-stream-retention-period \
    --stream-name ecommerce-clickstream \
    --retention-period-hours 168
```

**Evaluation Criteria:**
- Correct shard count calculation (1 point)
- Proper retention and encryption settings (1 point)

#### Task 1.2: Lambda Event Processor (3 points)
Implement a Lambda function to process Kinesis events and generate metrics.

**Required Implementation:**
```python
import json
import boto3
from datetime import datetime
from collections import defaultdict

def lambda_handler(event, context):
    """
    Process Kinesis events and generate real-time metrics
    """
    cloudwatch = boto3.client('cloudwatch')
    metrics = defaultdict(int)
    
    for record in event['Records']:
        # Decode Kinesis data
        payload = json.loads(
            base64.b64decode(record['kinesis']['data']).decode('utf-8')
        )
        
        # Extract metrics
        event_type = payload['eventType']
        user_id = payload['userId']
        timestamp = payload['timestamp']
        
        # Aggregate metrics
        metrics[f'{event_type}_count'] += 1
        
        # Detect anomalies (implement your logic)
        if is_anomaly(payload):
            send_alert(payload)
    
    # Publish metrics to CloudWatch
    publish_metrics(cloudwatch, metrics)
    
    return {'statusCode': 200, 'processed': len(event['Records'])}

def is_anomaly(event):
    """Implement anomaly detection logic"""
    # TODO: Implement anomaly detection
    # Check for unusual patterns like:
    # - High-value purchases from new users
    # - Rapid successive events from same user
    # - Geographic anomalies
    pass

def send_alert(event):
    """Send alert for anomalous events"""
    # TODO: Implement alerting mechanism
    pass

def publish_metrics(cloudwatch, metrics):
    """Publish metrics to CloudWatch"""
    # TODO: Implement CloudWatch metrics publishing
    pass
```

**Evaluation Criteria:**
- Correct Kinesis record processing (1 point)
- Proper error handling and logging (1 point)
- Functional anomaly detection logic (1 point)

#### Task 1.3: Kinesis Analytics Application (3 points)
Create a Kinesis Analytics application for real-time SQL processing.

**Required SQL Queries:**
```sql
-- Create input stream
CREATE OR REPLACE STREAM "SOURCE_SQL_STREAM_001" (
    userId VARCHAR(32),
    sessionId VARCHAR(32), 
    eventType VARCHAR(32),
    productId VARCHAR(32),
    timestamp TIMESTAMP,
    value DECIMAL(10,2)
);

-- Real-time metrics (5-minute tumbling windows)
CREATE OR REPLACE STREAM "METRICS_STREAM" AS 
SELECT STREAM
    eventType,
    COUNT(*) as event_count,
    COUNT(DISTINCT userId) as unique_users,
    AVG(value) as avg_value,
    ROWTIME_TO_TIMESTAMP(ROWTIME) as window_start
FROM SOURCE_SQL_STREAM_001
GROUP BY 
    eventType,
    ROWTIME RANGE INTERVAL '5' MINUTE;

-- Session analysis
CREATE OR REPLACE STREAM "SESSION_STREAM" AS
SELECT STREAM
    sessionId,
    userId,
    COUNT(*) as events_in_session,
    MIN(ROWTIME_TO_TIMESTAMP(ROWTIME)) as session_start,
    MAX(ROWTIME_TO_TIMESTAMP(ROWTIME)) as session_end
FROM SOURCE_SQL_STREAM_001
GROUP BY 
    sessionId,
    userId,
    ROWTIME RANGE INTERVAL '30' MINUTE;
```

**Evaluation Criteria:**
- Correct stream definitions (1 point)
- Proper windowing implementation (1 point)
- Functional aggregation queries (1 point)

## Task 2: Batch Processing Optimization (8 points)

### Scenario
Optimize a Spark application for processing large-scale transaction data with performance and cost requirements.

### Requirements
```yaml
Data Volume: 500GB daily transaction data
Processing Window: 4 hours maximum
Cost Target: 50% reduction from baseline
Performance Target: 2x throughput improvement

Optimization Areas:
  - Spark configuration tuning
  - Data skew handling
  - Resource optimization
  - Cost reduction strategies
```

### Implementation Tasks

#### Task 2.1: Spark Configuration Optimization (3 points)
Optimize Spark configuration for the given workload.

**Baseline Configuration:**
```python
# Current inefficient configuration
spark_config = {
    "spark.executor.memory": "2g",
    "spark.executor.cores": "2", 
    "spark.sql.shuffle.partitions": "200",
    "spark.serializer": "org.apache.spark.serializer.JavaSerializer"
}
```

**Required Optimizations:**
```python
# Optimized configuration
optimized_config = {
    # Memory optimization
    "spark.executor.memory": "14g",
    "spark.executor.cores": "5",
    "spark.executor.memoryFraction": "0.8",
    
    # Shuffle optimization  
    "spark.sql.shuffle.partitions": "800",
    "spark.sql.adaptive.enabled": "true",
    "spark.sql.adaptive.coalescePartitions.enabled": "true",
    
    # Serialization optimization
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
    
    # I/O optimization
    "spark.sql.parquet.compression.codec": "snappy",
    "spark.io.compression.codec": "snappy",
    
    # Memory management
    "spark.memory.offHeap.enabled": "true",
    "spark.memory.offHeap.size": "4g"
}
```

**Evaluation Criteria:**
- Proper memory and core allocation (1 point)
- Correct shuffle optimization (1 point)
- Appropriate serialization and compression (1 point)

#### Task 2.2: Data Skew Handling (3 points)
Implement data skew handling for a transaction processing job.

**Problem Scenario:**
```python
# Skewed transaction data - some customers have 1000x more transactions
transactions_df = spark.read.parquet("s3://data/transactions/")
customer_profiles_df = spark.read.parquet("s3://data/customers/")

# This join will be skewed
result = transactions_df.join(customer_profiles_df, "customer_id")
```

**Required Solution:**
```python
def handle_skewed_join(transactions_df, customer_profiles_df, skew_threshold=100000):
    """
    Handle skewed join using salting technique
    """
    # Identify skewed customers
    customer_counts = transactions_df.groupBy("customer_id").count()
    skewed_customers = customer_counts.filter(col("count") > skew_threshold) \
        .select("customer_id").collect()
    
    if not skewed_customers:
        # No skew detected
        return transactions_df.join(customer_profiles_df, "customer_id")
    
    skewed_customer_ids = [row.customer_id for row in skewed_customers]
    
    # Split data
    skewed_transactions = transactions_df.filter(
        col("customer_id").isin(skewed_customer_ids)
    )
    normal_transactions = transactions_df.filter(
        ~col("customer_id").isin(skewed_customer_ids)
    )
    
    # Handle normal data with regular join
    normal_result = normal_transactions.join(customer_profiles_df, "customer_id")
    
    # Handle skewed data with salting
    salt_factor = 100
    
    # Add salt to skewed transactions
    salted_transactions = skewed_transactions.withColumn(
        "salt", (rand() * salt_factor).cast("int")
    ).withColumn(
        "salted_customer_id", 
        concat(col("customer_id"), lit("_"), col("salt"))
    )
    
    # Replicate customer profiles
    salt_range = spark.range(salt_factor).select(col("id").alias("salt"))
    salted_customers = customer_profiles_df.filter(
        col("customer_id").isin(skewed_customer_ids)
    ).crossJoin(salt_range).withColumn(
        "salted_customer_id",
        concat(col("customer_id"), lit("_"), col("salt"))
    )
    
    # Perform salted join
    skewed_result = salted_transactions.join(
        salted_customers, "salted_customer_id"
    ).drop("salt", "salted_customer_id")
    
    # Union results
    return normal_result.union(skewed_result)
```

**Evaluation Criteria:**
- Correct skew detection logic (1 point)
- Proper salting implementation (1 point)
- Functional union of results (1 point)

#### Task 2.3: Cost Optimization Implementation (2 points)
Implement cost optimization strategies for EMR cluster.

**Required Implementation:**
```python
import boto3

def create_cost_optimized_cluster():
    """
    Create EMR cluster with cost optimization
    """
    emr = boto3.client('emr')
    
    cluster_config = {
        'Name': 'cost-optimized-processing',
        'ReleaseLabel': 'emr-6.4.0',
        'Instances': {
            'InstanceFleets': [
                {
                    'Name': 'MasterFleet',
                    'InstanceFleetType': 'MASTER',
                    'TargetOnDemandCapacity': 1,
                    'InstanceTypeConfigs': [
                        {
                            'InstanceType': 'm5.xlarge',
                            'WeightedCapacity': 1
                        }
                    ]
                },
                {
                    'Name': 'CoreFleet',
                    'InstanceFleetType': 'CORE', 
                    'TargetOnDemandCapacity': 2,
                    'TargetSpotCapacity': 8,
                    'InstanceTypeConfigs': [
                        {
                            'InstanceType': 'r5.2xlarge',
                            'WeightedCapacity': 2,
                            'BidPriceAsPercentageOfOnDemandPrice': 60
                        },
                        {
                            'InstanceType': 'r5.xlarge', 
                            'WeightedCapacity': 1,
                            'BidPriceAsPercentageOfOnDemandPrice': 60
                        }
                    ]
                }
            ]
        },
        'Applications': [{'Name': 'Spark'}],
        'AutoTerminationPolicy': {
            'IdleTimeout': 3600  # 1 hour idle timeout
        }
    }
    
    return emr.run_job_flow(**cluster_config)
```

**Evaluation Criteria:**
- Proper spot instance configuration (1 point)
- Auto-termination and cost controls (1 point)

## Task 3: Data Pipeline Design (7 points)

### Scenario
Design and implement an ETL pipeline for customer analytics with data quality validation.

### Requirements
```yaml
Source Systems:
  - Customer database (PostgreSQL)
  - Transaction logs (S3)
  - Web analytics (Kinesis)

Target System:
  - Data warehouse (Redshift)
  - Analytics dashboard (QuickSight)

Quality Requirements:
  - 99.9% data accuracy
  - Comprehensive validation
  - Error handling and recovery
```

### Implementation Tasks

#### Task 3.1: AWS Glue ETL Job (4 points)
Create a Glue ETL job for customer data processing.

**Required Implementation:**
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def process_customer_data():
    """
    Process customer data with quality validation
    """
    # Read customer data
    customers_df = glueContext.create_dynamic_frame.from_catalog(
        database="customer_db",
        table_name="customers"
    ).toDF()
    
    # Read transaction data
    transactions_df = glueContext.create_dynamic_frame.from_options(
        connection_type="s3",
        connection_options={"paths": ["s3://data-lake/transactions/"]},
        format="parquet"
    ).toDF()
    
    # Data quality validation
    validated_customers = validate_customer_data(customers_df)
    validated_transactions = validate_transaction_data(transactions_df)
    
    # Join and aggregate
    customer_metrics = calculate_customer_metrics(
        validated_customers, validated_transactions
    )
    
    # Write to data warehouse
    write_to_redshift(customer_metrics)
    
    return customer_metrics

def validate_customer_data(df):
    """Validate customer data quality"""
    # Remove duplicates
    df = df.dropDuplicates(["customer_id"])
    
    # Validate required fields
    df = df.filter(
        col("customer_id").isNotNull() &
        col("email").isNotNull() &
        col("registration_date").isNotNull()
    )
    
    # Validate email format
    df = df.filter(col("email").rlike("^[^@]+@[^@]+\\.[^@]+$"))
    
    # Add data quality flags
    df = df.withColumn("data_quality_score", lit(100))
    
    return df

def validate_transaction_data(df):
    """Validate transaction data quality"""
    # Filter valid transactions
    df = df.filter(
        col("amount") > 0 &
        col("customer_id").isNotNull() &
        col("transaction_date").isNotNull()
    )
    
    # Remove outliers (transactions > $10,000)
    df = df.filter(col("amount") <= 10000)
    
    return df

def calculate_customer_metrics(customers_df, transactions_df):
    """Calculate customer analytics metrics"""
    # Join customers with transactions
    customer_transactions = customers_df.join(
        transactions_df, "customer_id", "left"
    )
    
    # Calculate metrics
    customer_metrics = customer_transactions.groupBy(
        "customer_id", "email", "registration_date"
    ).agg(
        count("transaction_id").alias("total_transactions"),
        sum("amount").alias("total_spent"),
        avg("amount").alias("avg_transaction_value"),
        max("transaction_date").alias("last_transaction_date"),
        datediff(current_date(), max("transaction_date")).alias("days_since_last_transaction")
    )
    
    # Add customer segments
    customer_metrics = customer_metrics.withColumn(
        "customer_segment",
        when(col("total_spent") > 5000, "VIP")
        .when(col("total_spent") > 1000, "Premium")
        .otherwise("Standard")
    )
    
    return customer_metrics

def write_to_redshift(df):
    """Write data to Redshift"""
    df.write \
        .format("com.databricks.spark.redshift") \
        .option("url", "jdbc:redshift://cluster.region.redshift.amazonaws.com:5439/dev") \
        .option("dbtable", "customer_analytics") \
        .option("tempdir", "s3://temp-bucket/redshift-temp/") \
        .mode("overwrite") \
        .save()

# Execute pipeline
result = process_customer_data()
job.commit()
```

**Evaluation Criteria:**
- Correct data source integration (1 point)
- Proper data validation logic (1 point)
- Functional aggregation and metrics (1 point)
- Correct Redshift integration (1 point)

#### Task 3.2: Error Handling and Monitoring (3 points)
Implement comprehensive error handling and monitoring.

**Required Implementation:**
```python
import boto3
import logging
from datetime import datetime

def setup_monitoring():
    """Setup CloudWatch monitoring for pipeline"""
    cloudwatch = boto3.client('cloudwatch')
    
    # Custom metrics
    metrics = [
        {
            'MetricName': 'RecordsProcessed',
            'Value': 0,
            'Unit': 'Count'
        },
        {
            'MetricName': 'DataQualityScore', 
            'Value': 0,
            'Unit': 'Percent'
        },
        {
            'MetricName': 'ProcessingLatency',
            'Value': 0,
            'Unit': 'Seconds'
        }
    ]
    
    cloudwatch.put_metric_data(
        Namespace='DataPipeline/CustomerAnalytics',
        MetricData=metrics
    )

def handle_pipeline_errors(func):
    """Decorator for pipeline error handling"""
    def wrapper(*args, **kwargs):
        try:
            start_time = datetime.now()
            result = func(*args, **kwargs)
            
            # Log success metrics
            processing_time = (datetime.now() - start_time).total_seconds()
            log_success_metrics(processing_time, len(result))
            
            return result
            
        except Exception as e:
            # Log error
            logging.error(f"Pipeline failed: {str(e)}")
            
            # Send alert
            send_failure_alert(str(e))
            
            # Attempt recovery
            if should_retry(e):
                return retry_with_backoff(func, *args, **kwargs)
            else:
                raise
    
    return wrapper

def send_failure_alert(error_message):
    """Send failure alert via SNS"""
    sns = boto3.client('sns')
    
    message = {
        'timestamp': datetime.now().isoformat(),
        'error': error_message,
        'pipeline': 'customer-analytics',
        'severity': 'HIGH'
    }
    
    sns.publish(
        TopicArn='arn:aws:sns:region:account:pipeline-alerts',
        Message=json.dumps(message),
        Subject='Data Pipeline Failure Alert'
    )
```

**Evaluation Criteria:**
- Proper error handling implementation (1 point)
- CloudWatch metrics integration (1 point)
- Alerting and recovery mechanisms (1 point)

## Task 4: Performance Monitoring Setup (7 points)

### Scenario
Set up comprehensive monitoring and alerting for a data processing platform.

### Requirements
```yaml
Monitoring Scope:
  - Stream processing performance
  - Batch job execution
  - Data quality metrics
  - Cost tracking

Alerting Requirements:
  - Real-time performance alerts
  - Data quality violations
  - Cost threshold breaches
  - System health monitoring
```

### Implementation Tasks

#### Task 4.1: CloudWatch Dashboard (3 points)
Create a comprehensive monitoring dashboard.

**Required Implementation:**
```python
import boto3
import json

def create_monitoring_dashboard():
    """Create CloudWatch dashboard for data platform"""
    cloudwatch = boto3.client('cloudwatch')
    
    dashboard_body = {
        "widgets": [
            {
                "type": "metric",
                "properties": {
                    "metrics": [
                        ["AWS/Kinesis", "IncomingRecords", "StreamName", "ecommerce-clickstream"],
                        [".", "OutgoingRecords", ".", "."],
                        [".", "WriteProvisionedThroughputExceeded", ".", "."]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "us-east-1",
                    "title": "Kinesis Stream Metrics"
                }
            },
            {
                "type": "metric", 
                "properties": {
                    "metrics": [
                        ["AWS/Lambda", "Duration", "FunctionName", "stream-processor"],
                        [".", "Errors", ".", "."],
                        [".", "Throttles", ".", "."]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "us-east-1", 
                    "title": "Lambda Performance"
                }
            },
            {
                "type": "log",
                "properties": {
                    "query": "SOURCE '/aws/lambda/stream-processor'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 100",
                    "region": "us-east-1",
                    "title": "Recent Errors"
                }
            }
        ]
    }
    
    cloudwatch.put_dashboard(
        DashboardName='DataProcessingPlatform',
        DashboardBody=json.dumps(dashboard_body)
    )
```

**Evaluation Criteria:**
- Comprehensive metric coverage (1 point)
- Proper widget configuration (1 point)
- Functional dashboard creation (1 point)

#### Task 4.2: Automated Alerting (4 points)
Implement automated alerting for critical metrics.

**Required Implementation:**
```python
def setup_critical_alerts():
    """Setup critical performance and quality alerts"""
    cloudwatch = boto3.client('cloudwatch')
    
    alerts = [
        {
            'AlarmName': 'HighStreamProcessingLatency',
            'MetricName': 'Duration',
            'Namespace': 'AWS/Lambda',
            'Statistic': 'Average',
            'Threshold': 30000,  # 30 seconds
            'ComparisonOperator': 'GreaterThanThreshold'
        },
        {
            'AlarmName': 'DataQualityBreach',
            'MetricName': 'DataQualityScore',
            'Namespace': 'DataPipeline/CustomerAnalytics',
            'Statistic': 'Average', 
            'Threshold': 95,  # 95%
            'ComparisonOperator': 'LessThanThreshold'
        },
        {
            'AlarmName': 'HighErrorRate',
            'MetricName': 'Errors',
            'Namespace': 'AWS/Lambda',
            'Statistic': 'Sum',
            'Threshold': 10,
            'ComparisonOperator': 'GreaterThanThreshold'
        }
    ]
    
    for alert in alerts:
        cloudwatch.put_metric_alarm(
            AlarmName=alert['AlarmName'],
            ComparisonOperator=alert['ComparisonOperator'],
            EvaluationPeriods=2,
            MetricName=alert['MetricName'],
            Namespace=alert['Namespace'],
            Period=300,
            Statistic=alert['Statistic'],
            Threshold=alert['Threshold'],
            ActionsEnabled=True,
            AlarmActions=[
                'arn:aws:sns:us-east-1:123456789012:critical-alerts'
            ],
            AlarmDescription=f'Alert for {alert["AlarmName"]}'
        )
```

**Evaluation Criteria:**
- Appropriate alert thresholds (1 point)
- Comprehensive metric coverage (1 point)
- Proper SNS integration (1 point)
- Functional alarm creation (1 point)

## Scoring Rubric

### Overall Performance Levels
```yaml
Excellent (26-30 points):
  - All tasks completed successfully
  - Demonstrates advanced optimization techniques
  - Implements comprehensive error handling
  - Shows deep understanding of concepts

Good (21-25 points):
  - Most tasks completed correctly
  - Shows solid practical skills
  - Basic error handling implemented
  - Good understanding demonstrated

Satisfactory (16-20 points):
  - Basic requirements met
  - Functional implementations
  - Limited optimization
  - Adequate understanding

Needs Improvement (<16 points):
  - Incomplete or incorrect implementations
  - Missing critical components
  - Poor error handling
  - Limited understanding demonstrated
```

### Individual Task Scoring
Each task is scored based on:
- **Functionality (50%)**: Does the implementation work correctly?
- **Best Practices (25%)**: Are industry best practices followed?
- **Optimization (15%)**: Are performance optimizations implemented?
- **Error Handling (10%)**: Is proper error handling included?

This practical assessment validates hands-on skills essential for real-world data processing and analytics implementations.
