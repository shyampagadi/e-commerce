# Exercise 02: Batch Processing Optimization

## Objective
Design and optimize a large-scale batch processing system for a financial services company that processes daily transaction data, generates regulatory reports, and performs risk analysis on petabyte-scale datasets.

## Business Context

### Financial Services Requirements
```yaml
Data Volume:
  - Daily transactions: 500M records (2TB)
  - Historical data: 5 years (3.6PB total)
  - Real-time feeds: 50K transactions/second peak
  - Regulatory reports: 100+ different formats

Processing Requirements:
  - Daily batch window: 6 hours (midnight to 6 AM)
  - Regulatory deadline: 9 AM same day
  - Risk calculations: Complex multi-table joins
  - Audit trail: Complete lineage tracking

Compliance Requirements:
  - Data retention: 7 years minimum
  - Encryption: At rest and in transit
  - Access control: Role-based permissions
  - Audit logging: All data access tracked
```

## Exercise Tasks

### Task 1: Architecture Design (45 minutes)
Design a batch processing architecture for the following workloads:

**Daily Processing Jobs:**
1. **Transaction Validation and Enrichment**
   - Validate 500M daily transactions
   - Enrich with customer and account data
   - Detect and flag anomalies
   - Output: Clean transaction dataset

2. **Risk Calculation Engine**
   - Calculate Value at Risk (VaR) for portfolios
   - Perform stress testing scenarios
   - Generate credit risk scores
   - Output: Risk metrics and alerts

3. **Regulatory Reporting**
   - Generate Basel III capital reports
   - Create anti-money laundering (AML) reports
   - Produce trade surveillance reports
   - Output: Formatted regulatory files

4. **Customer Analytics**
   - Calculate customer lifetime value
   - Generate behavioral segmentation
   - Produce recommendation scores
   - Output: Customer insights database

**Deliverables:**
1. End-to-end architecture diagram
2. Technology stack selection and justification
3. Data flow and dependency mapping
4. Resource sizing and cost estimation

### Task 2: EMR Cluster Optimization (60 minutes)
Implement and optimize an EMR cluster for the batch processing workloads:

**Cluster Configuration Requirements:**
```yaml
Performance Targets:
  - Process 2TB data in < 4 hours
  - Support 100+ concurrent Spark jobs
  - Achieve 90%+ resource utilization
  - Maintain < 1% job failure rate

Cost Targets:
  - Reduce compute costs by 60% using spot instances
  - Optimize storage costs with lifecycle policies
  - Achieve < $0.10 per GB processed
  - Minimize idle resource costs
```

**Implementation Steps:**

**Step 1: Cluster Design**
```yaml
Master Node Configuration:
  Instance Type: m5.2xlarge
  Count: 1 (or 3 for HA)
  Storage: 100GB EBS GP3
  
Core Node Configuration:
  Instance Type: r5.4xlarge
  Count: 10-50 (auto-scaling)
  Storage: 500GB EBS GP3 + 2x NVMe SSD
  
Task Node Configuration:
  Instance Type: r5.2xlarge, r5.4xlarge, r5.8xlarge
  Count: 0-100 (spot instances, auto-scaling)
  Storage: Local NVMe SSD only
```

**Step 2: Spark Optimization**
Configure Spark for optimal performance:

```python
# Spark configuration for large-scale processing
spark_config = {
    # Driver configuration
    "spark.driver.memory": "16g",
    "spark.driver.cores": "4",
    "spark.driver.maxResultSize": "4g",
    
    # Executor configuration
    "spark.executor.memory": "28g",
    "spark.executor.cores": "5",
    "spark.executor.memoryFraction": "0.8",
    "spark.executor.instances": "dynamic",
    
    # Dynamic allocation
    "spark.dynamicAllocation.enabled": "true",
    "spark.dynamicAllocation.minExecutors": "10",
    "spark.dynamicAllocation.maxExecutors": "200",
    "spark.dynamicAllocation.initialExecutors": "20",
    
    # Shuffle optimization
    "spark.sql.shuffle.partitions": "800",
    "spark.sql.adaptive.enabled": "true",
    "spark.sql.adaptive.coalescePartitions.enabled": "true",
    "spark.sql.adaptive.skewJoin.enabled": "true",
    
    # Serialization and compression
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
    "spark.sql.parquet.compression.codec": "snappy",
    "spark.io.compression.codec": "snappy"
}
```

**Step 3: Data Processing Pipeline**
Implement the transaction processing pipeline:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

def process_daily_transactions(spark, input_path, output_path, date):
    """
    Process daily transaction data with validation and enrichment
    """
    
    # Read raw transaction data
    transactions = spark.read.parquet(f"{input_path}/transactions/date={date}")
    
    # Data validation
    valid_transactions = transactions.filter(
        (col("amount") > 0) & 
        (col("account_id").isNotNull()) &
        (col("transaction_type").isin(["DEBIT", "CREDIT"]))
    )
    
    # Enrich with customer data
    customers = spark.read.parquet(f"{input_path}/customers/")
    enriched = valid_transactions.join(
        broadcast(customers), 
        "customer_id", 
        "left"
    )
    
    # Calculate derived fields
    processed = enriched.withColumn(
        "risk_score", 
        calculate_risk_score(col("amount"), col("customer_tier"))
    ).withColumn(
        "processing_date", 
        lit(date)
    )
    
    # Write partitioned output
    processed.write.mode("overwrite").partitionBy("processing_date").parquet(output_path)
    
    return processed.count()
```

### Task 3: Performance Optimization (45 minutes)
Optimize the batch processing system for performance:

**Optimization Areas:**

**1. Data Skew Handling**
```python
def handle_data_skew(df, skew_column, salt_factor=100):
    """
    Handle data skew using salting technique
    """
    # Add salt to skewed keys
    salted_df = df.withColumn(
        "salted_key",
        concat(col(skew_column), lit("_"), (rand() * salt_factor).cast("int"))
    )
    
    # Perform operations on salted data
    result = salted_df.groupBy("salted_key").agg(
        sum("amount").alias("total_amount"),
        count("*").alias("transaction_count")
    )
    
    # Remove salt and re-aggregate
    final_result = result.withColumn(
        "original_key",
        regexp_extract(col("salted_key"), "(.*)_\\d+", 1)
    ).groupBy("original_key").agg(
        sum("total_amount").alias("final_amount"),
        sum("transaction_count").alias("final_count")
    )
    
    return final_result
```

**2. Memory Management**
```python
def optimize_memory_usage(spark):
    """
    Optimize Spark memory configuration
    """
    # Configure garbage collection
    spark.conf.set("spark.executor.extraJavaOptions", 
                   "-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:G1HeapRegionSize=16m")
    
    # Enable off-heap storage
    spark.conf.set("spark.memory.offHeap.enabled", "true")
    spark.conf.set("spark.memory.offHeap.size", "4g")
    
    # Optimize storage level
    spark.conf.set("spark.sql.columnVector.offheap.enabled", "true")
    
    return spark
```

**3. I/O Optimization**
```python
def optimize_io_operations(df, output_path):
    """
    Optimize I/O operations for large datasets
    """
    # Optimal partition size (128MB-1GB per partition)
    optimal_partitions = max(1, df.rdd.getNumPartitions() // 4)
    
    # Coalesce for output optimization
    optimized_df = df.coalesce(optimal_partitions)
    
    # Use optimal file format and compression
    optimized_df.write \
        .mode("overwrite") \
        .option("compression", "snappy") \
        .option("parquet.block.size", "268435456") \
        .parquet(output_path)
```

### Task 4: Cost Optimization Strategy (30 minutes)
Implement comprehensive cost optimization:

**1. Spot Instance Strategy**
```yaml
Spot Configuration:
  Task Nodes: 100% spot instances
  Core Nodes: 50% spot instances (mixed with on-demand)
  Allocation Strategy: Diversified across instance types
  
Instance Mix:
  - r5.2xlarge (baseline)
  - r5.4xlarge (compute intensive)
  - r5.8xlarge (memory intensive)
  - m5.4xlarge (balanced workloads)
  
Timeout Handling:
  - Graceful shutdown on spot interruption
  - Automatic failover to on-demand instances
  - Checkpoint and resume capability
```

**2. Storage Optimization**
```yaml
S3 Storage Strategy:
  Active Data (0-30 days): S3 Standard
  Frequent Access (30-90 days): S3 Standard-IA
  Archive Data (90+ days): S3 Glacier
  Compliance Data (1+ years): S3 Deep Archive
  
Lifecycle Policies:
  - Automatic transition based on access patterns
  - Intelligent tiering for unpredictable access
  - Deletion policies for temporary data
  - Cross-region replication for DR
```

**3. Resource Scheduling**
```python
def optimize_job_scheduling():
    """
    Implement intelligent job scheduling for cost optimization
    """
    schedule = {
        "critical_jobs": {
            "time_window": "00:00-02:00",
            "instance_type": "on_demand",
            "priority": "high"
        },
        "regular_jobs": {
            "time_window": "02:00-05:00", 
            "instance_type": "spot_preferred",
            "priority": "medium"
        },
        "low_priority_jobs": {
            "time_window": "05:00-06:00",
            "instance_type": "spot_only",
            "priority": "low"
        }
    }
    return schedule
```

### Task 5: Monitoring and Alerting (30 minutes)
Implement comprehensive monitoring for the batch processing system:

**Key Metrics to Monitor:**
```yaml
Performance Metrics:
  - Job execution time and success rate
  - Resource utilization (CPU, memory, disk)
  - Data processing throughput (GB/hour)
  - Queue wait times and backlog

Cost Metrics:
  - Hourly compute costs by job type
  - Storage costs by data tier
  - Spot instance savings and interruption rate
  - Resource efficiency ratios

Quality Metrics:
  - Data validation error rates
  - Processing accuracy and completeness
  - SLA compliance (on-time delivery)
  - Audit trail completeness
```

**Alerting Configuration:**
```python
def setup_monitoring_alerts():
    """
    Configure CloudWatch alarms for batch processing
    """
    alerts = {
        "critical": {
            "job_failure_rate": "> 5%",
            "processing_delay": "> 30 minutes",
            "data_quality_issues": "> 1%",
            "cost_overrun": "> 20% of budget"
        },
        "warning": {
            "resource_utilization": "< 70% or > 90%",
            "processing_time": "> 150% of baseline",
            "spot_interruption_rate": "> 10%",
            "storage_growth": "> 25% month-over-month"
        }
    }
    return alerts
```

## Solution Guidelines

### Architecture Solution
```yaml
Recommended Architecture:
  Orchestration: Apache Airflow on ECS
  Processing: EMR with Spark (auto-scaling)
  Storage: S3 with intelligent tiering
  Metadata: Glue Data Catalog
  Monitoring: CloudWatch + Custom dashboards
  
Data Pipeline:
  Raw Data → S3 → EMR Processing → Validated Data → S3
                     ↓
  Regulatory Reports → Compliance Systems
                     ↓
  Risk Metrics → Risk Management Systems
                     ↓
  Customer Analytics → CRM and Marketing Systems
```

### Performance Benchmarks
```yaml
Target Performance:
  Data Processing Rate: 500GB/hour sustained
  Job Success Rate: 99.5%
  Resource Utilization: 85% average
  End-to-end Latency: < 4 hours for daily batch
  
Cost Targets:
  Compute Cost: < $0.08 per GB processed
  Storage Cost: < $0.02 per GB per month
  Total Daily Cost: < $2,000 for baseline workload
  Spot Instance Savings: 60%+ of compute costs
```

### Sample Implementation

**Airflow DAG for Orchestration:**
```python
from airflow import DAG
from airflow.providers.amazon.aws.operators.emr_create_job_flow import EmrCreateJobFlowOperator
from airflow.providers.amazon.aws.operators.emr_add_steps import EmrAddStepsOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 2,
    'retry_delay': timedelta(minutes=15)
}

dag = DAG(
    'financial_batch_processing',
    default_args=default_args,
    description='Daily financial data processing pipeline',
    schedule_interval='0 0 * * *',  # Daily at midnight
    catchup=False,
    max_active_runs=1
)

# EMR cluster configuration
emr_config = {
    'Name': 'financial-processing-cluster',
    'ReleaseLabel': 'emr-6.4.0',
    'Applications': [{'Name': 'Spark'}, {'Name': 'Hadoop'}],
    'Instances': {
        'InstanceGroups': [
            {
                'Name': 'Master',
                'Market': 'ON_DEMAND',
                'InstanceRole': 'MASTER',
                'InstanceType': 'm5.2xlarge',
                'InstanceCount': 1
            },
            {
                'Name': 'Core',
                'Market': 'ON_DEMAND', 
                'InstanceRole': 'CORE',
                'InstanceType': 'r5.4xlarge',
                'InstanceCount': 10
            },
            {
                'Name': 'Task',
                'Market': 'SPOT',
                'InstanceRole': 'TASK', 
                'InstanceType': 'r5.2xlarge',
                'InstanceCount': 20,
                'BidPrice': '0.20'
            }
        ],
        'Ec2KeyName': 'emr-key-pair',
        'KeepJobFlowAliveWhenNoSteps': False
    },
    'JobFlowRole': 'EMR_EC2_DefaultRole',
    'ServiceRole': 'EMR_DefaultRole'
}

# Create EMR cluster
create_cluster = EmrCreateJobFlowOperator(
    task_id='create_emr_cluster',
    job_flow_overrides=emr_config,
    dag=dag
)

# Processing steps
processing_steps = [
    {
        'Name': 'Transaction Validation',
        'ActionOnFailure': 'TERMINATE_CLUSTER',
        'HadoopJarStep': {
            'Jar': 'command-runner.jar',
            'Args': [
                'spark-submit',
                '--class', 'com.company.TransactionProcessor',
                's3://scripts/transaction-processor.jar',
                '--input', 's3://raw-data/{{ ds }}/',
                '--output', 's3://processed-data/{{ ds }}/'
            ]
        }
    }
]

add_steps = EmrAddStepsOperator(
    task_id='add_processing_steps',
    job_flow_id="{{ task_instance.xcom_pull(task_ids='create_emr_cluster', key='return_value') }}",
    steps=processing_steps,
    dag=dag
)

create_cluster >> add_steps
```

## Evaluation Criteria

### Technical Implementation (40%)
- Architecture design scalability and fault tolerance
- Proper EMR and Spark optimization techniques
- Code quality and best practices
- Performance monitoring and alerting

### Cost Optimization (25%)
- Effective use of spot instances and reserved capacity
- Storage lifecycle management
- Resource right-sizing and auto-scaling
- ROI analysis and cost projections

### Performance Achievement (25%)
- Meeting processing time and throughput targets
- Resource utilization optimization
- Data quality and accuracy maintenance
- SLA compliance and reliability

### Operational Excellence (10%)
- Monitoring and observability implementation
- Error handling and recovery procedures
- Documentation and runbook quality
- Security and compliance considerations

## Bonus Challenges

### Advanced Challenge 1: Multi-Region Processing
Design a multi-region batch processing system with:
- Cross-region data replication and synchronization
- Disaster recovery and failover procedures
- Compliance with data residency requirements
- Cost-optimized cross-region data transfer

### Advanced Challenge 2: Machine Learning Integration
Integrate ML capabilities for:
- Automated anomaly detection in transaction data
- Dynamic resource allocation based on workload prediction
- Intelligent data partitioning and optimization
- Real-time model scoring within batch jobs

### Advanced Challenge 3: Advanced Optimization
Implement advanced optimization techniques:
- Custom Spark catalyst rules for domain-specific optimization
- Dynamic partition pruning and predicate pushdown
- Adaptive query execution with runtime statistics
- Custom data source connectors for proprietary systems
