# AWS Glue for ETL Workloads

## Overview
AWS Glue is a fully managed extract, transform, and load (ETL) service that makes it easy to prepare and load data for analytics. It provides both visual and code-based interfaces for creating ETL jobs.

## Core Components

### Glue Data Catalog
```yaml
Purpose: Centralized metadata repository for all data assets
Components:
  - Databases: Logical groupings of tables
  - Tables: Metadata about data structure and location
  - Partitions: Subdivisions of tables for performance
  - Connections: Database and data store connection information

Benefits:
  - Single source of truth for metadata
  - Integration with analytics services (Athena, EMR, Redshift)
  - Automatic schema discovery and evolution
  - Version control for schema changes
```

### Glue Crawlers
```yaml
Purpose: Automatically discover and catalog data schemas
Capabilities:
  - Schema inference from various data formats
  - Partition discovery and management
  - Schema evolution detection
  - Incremental crawling for performance

Supported Data Sources:
  - S3 (JSON, CSV, Parquet, ORC, Avro)
  - JDBC databases (MySQL, PostgreSQL, Oracle, SQL Server)
  - DynamoDB tables
  - Kafka streams
  - MongoDB collections

Configuration:
  Schedule: On-demand, scheduled, or event-driven
  Classifiers: Custom logic for schema detection
  Include/Exclude patterns: Control what gets crawled
  Schema change policy: How to handle schema evolution
```

### Glue ETL Jobs
```yaml
Job Types:
  Spark ETL Jobs: For large-scale data processing
  Python Shell Jobs: For lightweight scripting tasks
  Streaming Jobs: For real-time data processing
  Ray Jobs: For distributed Python workloads

Execution Environment:
  - Serverless: Automatic resource provisioning
  - Standard workers: 4 vCPU, 16 GB memory
  - G.1X workers: 4 vCPU, 16 GB memory (cost-optimized)
  - G.2X workers: 8 vCPU, 32 GB memory (memory-optimized)

Features:
  - Auto-scaling based on workload
  - Job bookmarking for incremental processing
  - Error handling and retry logic
  - Integration with Glue Data Catalog
```

## ETL Development Approaches

### Visual ETL with Glue Studio
```yaml
Interface: Drag-and-drop visual editor
Components:
  - Data sources: S3, databases, streaming sources
  - Transforms: Join, filter, map, aggregate
  - Data targets: S3, databases, data warehouses

Benefits:
  - No coding required for basic ETL
  - Visual representation of data flow
  - Automatic code generation
  - Built-in data preview and validation

Limitations:
  - Limited to predefined transforms
  - Complex logic requires custom code
  - Less flexibility than code-based approach
```

### Code-Based ETL Development
```yaml
Languages: Python (PySpark) or Scala (Spark)
Framework: Apache Spark with Glue extensions

Glue DynamicFrame:
  - Schema-flexible data structure
  - Handles semi-structured data gracefully
  - Built-in error handling and data quality
  - Easy conversion to/from Spark DataFrames

Sample PySpark ETL Job:
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Initialize Glue context
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read data from Glue Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="sales_db",
    table_name="raw_transactions"
)

# Apply transformations
# Filter out invalid records
filtered_data = Filter.apply(
    frame=datasource,
    f=lambda x: x["amount"] > 0 and x["status"] == "completed"
)

# Map fields and apply business logic
mapped_data = Map.apply(
    frame=filtered_data,
    f=lambda x: {
        "transaction_id": x["id"],
        "customer_id": x["customer_id"],
        "amount": float(x["amount"]),
        "transaction_date": x["created_at"][:10],
        "category": x["product_category"].lower()
    }
)

# Resolve choice fields (handle schema inconsistencies)
resolved_data = ResolveChoice.apply(
    frame=mapped_data,
    choice="make_struct"
)

# Write to S3 in Parquet format
glueContext.write_dynamic_frame.from_options(
    frame=resolved_data,
    connection_type="s3",
    connection_options={
        "path": "s3://my-bucket/processed-data/",
        "partitionKeys": ["transaction_date"]
    },
    format="parquet"
)

job.commit()
```

## Advanced ETL Patterns

### Incremental Processing with Job Bookmarks
```yaml
Purpose: Process only new or changed data since last run
Implementation:
  - Glue automatically tracks processed data
  - Works with S3, JDBC sources, and streaming
  - Reduces processing time and costs
  - Handles schema evolution gracefully

Configuration:
  job.init(args['JOB_NAME'], args)
  # Enable job bookmarking
  job.commit()  # Save bookmark state

Benefits:
  - Automatic incremental processing
  - No manual state management required
  - Handles file-based and database sources
  - Reduces data processing costs
```

### Error Handling and Data Quality
```yaml
Error Record Handling:
  # Separate good and bad records
  good_records = datasource.filter(f=lambda x: validate_record(x))
  bad_records = datasource.filter(f=lambda x: not validate_record(x))
  
  # Write bad records to error bucket
  glueContext.write_dynamic_frame.from_options(
      frame=bad_records,
      connection_type="s3",
      connection_options={"path": "s3://error-bucket/"},
      format="json"
  )

Data Quality Checks:
  - Schema validation against expected structure
  - Business rule validation (ranges, formats)
  - Completeness checks for required fields
  - Referential integrity validation
  - Statistical anomaly detection
```

### Complex Transformations
```yaml
Joins Across Multiple Sources:
  # Read from multiple sources
  customers = glueContext.create_dynamic_frame.from_catalog(
      database="crm_db", table_name="customers"
  )
  orders = glueContext.create_dynamic_frame.from_catalog(
      database="sales_db", table_name="orders"
  )
  
  # Convert to DataFrames for complex operations
  customers_df = customers.toDF()
  orders_df = orders.toDF()
  
  # Perform join
  joined_df = orders_df.join(
      customers_df,
      orders_df.customer_id == customers_df.id,
      "left"
  )
  
  # Convert back to DynamicFrame
  result = DynamicFrame.fromDF(joined_df, glueContext, "joined_data")

Aggregations and Window Functions:
  from pyspark.sql.functions import *
  from pyspark.sql.window import Window
  
  # Calculate running totals
  window_spec = Window.partitionBy("customer_id").orderBy("order_date")
  df_with_running_total = df.withColumn(
      "running_total",
      sum("amount").over(window_spec)
  )
  
  # Calculate monthly aggregates
  monthly_summary = df.groupBy(
      "customer_id",
      date_format("order_date", "yyyy-MM").alias("month")
  ).agg(
      sum("amount").alias("total_amount"),
      count("*").alias("order_count"),
      avg("amount").alias("avg_order_value")
  )
```

## Streaming ETL with Glue

### Kinesis Integration
```yaml
Streaming Job Configuration:
  # Read from Kinesis Data Streams
  kinesis_options = {
      "streamName": "transaction-stream",
      "startingPosition": "TRIM_HORIZON",
      "inferSchema": "true"
  }
  
  streaming_data = glueContext.create_data_frame.from_options(
      connection_type="kinesis",
      connection_options=kinesis_options
  )

Real-time Processing:
  def process_batch(data_frame, batch_id):
      # Transform streaming data
      processed_df = data_frame.select(
          col("transaction_id"),
          col("amount").cast("double"),
          from_json(col("metadata"), schema).alias("parsed_metadata")
      )
      
      # Write to S3 with partitioning
      processed_df.write \
          .mode("append") \
          .partitionBy("year", "month", "day") \
          .parquet("s3://streaming-output/")
  
  # Start streaming query
  query = streaming_data.writeStream \
      .foreachBatch(process_batch) \
      .outputMode("append") \
      .start()
```

### Change Data Capture (CDC)
```yaml
Database CDC Processing:
  # Read CDC data from DMS
  cdc_data = glueContext.create_dynamic_frame.from_options(
      connection_type="s3",
      connection_options={
          "paths": ["s3://cdc-bucket/"],
          "recurse": True
      },
      format="json"
  )
  
  # Process different operation types
  inserts = cdc_data.filter(f=lambda x: x["Op"] == "I")
  updates = cdc_data.filter(f=lambda x: x["Op"] == "U")
  deletes = cdc_data.filter(f=lambda x: x["Op"] == "D")
  
  # Apply to target data store
  # Implementation depends on target system requirements
```

## Performance Optimization

### Job Configuration Tuning
```yaml
Worker Configuration:
  # Choose appropriate worker type
  Standard: General purpose (4 vCPU, 16 GB)
  G.1X: Cost-optimized (4 vCPU, 16 GB)
  G.2X: Memory-optimized (8 vCPU, 32 GB)
  
  # Set worker count based on data volume
  Small datasets (<1GB): 2-5 workers
  Medium datasets (1-100GB): 5-20 workers
  Large datasets (>100GB): 20+ workers

Spark Configuration:
  --conf spark.sql.adaptive.enabled=true
  --conf spark.sql.adaptive.coalescePartitions.enabled=true
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer
  --conf spark.sql.parquet.filterPushdown=true
  --conf spark.sql.parquet.mergeSchema=false
```

### Data Format Optimization
```yaml
File Formats:
  Parquet: Best for analytics (columnar, compressed)
  ORC: Good for Hive compatibility
  Avro: Good for schema evolution
  JSON: Flexible but inefficient for large datasets

Partitioning Strategy:
  # Partition by frequently filtered columns
  .partitionBy("year", "month", "day")
  
  # Avoid over-partitioning (too many small files)
  # Aim for 128MB-1GB per partition
  
  # Use bucketing for join optimization
  .bucketBy(10, "customer_id")

Compression:
  Snappy: Fast compression/decompression
  GZIP: Better compression ratio
  LZ4: Fastest compression
  ZSTD: Good balance of speed and compression
```

### Memory and Resource Management
```yaml
Memory Optimization:
  # Increase driver memory for large jobs
  --conf spark.driver.memory=4g
  
  # Optimize executor memory
  --conf spark.executor.memory=8g
  --conf spark.executor.memoryFraction=0.8
  
  # Handle large datasets
  --conf spark.sql.files.maxPartitionBytes=134217728  # 128MB
  --conf spark.sql.files.openCostInBytes=4194304      # 4MB

Caching Strategy:
  # Cache frequently accessed data
  df.cache()
  
  # Use appropriate storage levels
  df.persist(StorageLevel.MEMORY_AND_DISK_SER)
  
  # Unpersist when no longer needed
  df.unpersist()
```

## Monitoring and Troubleshooting

### CloudWatch Metrics
```yaml
Job Metrics:
  - glue.driver.aggregate.numCompletedTasks
  - glue.driver.aggregate.numFailedTasks
  - glue.driver.BlockManager.disk.diskSpaceUsed_MB
  - glue.driver.jvm.heap.usage
  - glue.executors.aggregate.memoryBytesSpilled

Custom Metrics:
  # Add custom metrics to jobs
  from awsglue.utils import getResolvedOptions
  import boto3
  
  cloudwatch = boto3.client('cloudwatch')
  
  def put_metric(metric_name, value, unit='Count'):
      cloudwatch.put_metric_data(
          Namespace='Glue/CustomMetrics',
          MetricData=[{
              'MetricName': metric_name,
              'Value': value,
              'Unit': unit
          }]
      )
  
  # Track processed records
  put_metric('ProcessedRecords', record_count)
```

### Logging and Debugging
```yaml
Logging Configuration:
  # Enable continuous logging
  --enable-continuous-cloudwatch-log true
  
  # Custom log group
  --continuous-log-logGroup /aws-glue/jobs/my-job
  
  # Log level configuration
  --conf spark.sql.adaptive.logLevel=INFO

Debug Techniques:
  # Print schema for debugging
  datasource.printSchema()
  
  # Show sample data
  datasource.show(5)
  
  # Count records at each step
  print(f"Records after filter: {filtered_data.count()}")
  
  # Write intermediate results for inspection
  glueContext.write_dynamic_frame.from_options(
      frame=intermediate_data,
      connection_type="s3",
      connection_options={"path": "s3://debug-bucket/"},
      format="json"
  )
```

### Common Issues and Solutions
```yaml
Out of Memory Errors:
  Solutions:
    - Increase worker memory allocation
    - Reduce partition size
    - Use more workers for parallel processing
    - Optimize data types and schema
    - Implement data sampling for development

Slow Performance:
  Solutions:
    - Optimize file formats (use Parquet)
    - Implement proper partitioning
    - Reduce data shuffling operations
    - Use broadcast joins for small tables
    - Enable adaptive query execution

Schema Evolution Issues:
  Solutions:
    - Use ResolveChoice transformation
    - Implement schema validation
    - Handle missing columns gracefully
    - Use schema registry for consistency
    - Test with sample data first
```

## Security and Compliance

### IAM and Access Control
```yaml
Service Role Permissions:
  - AWSGlueServiceRole (managed policy)
  - S3 read/write permissions for data locations
  - CloudWatch logs permissions
  - KMS permissions for encrypted data

Fine-grained Access:
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::my-data-bucket/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "glue:GetTable",
          "glue:GetPartitions"
        ],
        "Resource": [
          "arn:aws:glue:region:account:catalog",
          "arn:aws:glue:region:account:database/my-database",
          "arn:aws:glue:region:account:table/my-database/*"
        ]
      }
    ]
  }
```

### Encryption and Data Protection
```yaml
Encryption at Rest:
  - S3 server-side encryption (SSE-S3, SSE-KMS)
  - Glue Data Catalog encryption
  - CloudWatch Logs encryption
  - Job bookmark encryption

Encryption in Transit:
  - TLS for all API communications
  - SSL for database connections
  - VPC endpoints for private connectivity

Data Masking:
  # Implement data masking in ETL jobs
  def mask_pii(record):
      if 'ssn' in record:
          record['ssn'] = 'XXX-XX-' + record['ssn'][-4:]
      if 'email' in record:
          record['email'] = hash_email(record['email'])
      return record
  
  masked_data = Map.apply(frame=source_data, f=mask_pii)
```

## Cost Optimization

### Pricing Model
```yaml
Job Execution:
  - Billed per second with 1-minute minimum
  - Different rates for worker types:
    * Standard: $0.44 per DPU-hour
    * G.1X: $0.35 per DPU-hour
    * G.2X: $0.88 per DPU-hour

Data Catalog:
  - First 1 million requests per month: Free
  - Additional requests: $1 per million

Crawlers:
  - First 100,000 table stores per month: Free
  - Additional stores: $1 per 100,000

Development Endpoints:
  - $0.44 per DPU-hour for development
  - Automatic shutdown after inactivity
```

### Cost Optimization Strategies
```yaml
Right-sizing:
  - Monitor job metrics to optimize worker count
  - Use G.1X workers for cost-sensitive workloads
  - Implement auto-scaling for variable workloads

Scheduling:
  - Run jobs during off-peak hours
  - Batch multiple small jobs together
  - Use job triggers to avoid unnecessary runs

Data Optimization:
  - Use efficient file formats (Parquet vs JSON)
  - Implement proper partitioning
  - Compress data to reduce I/O costs
  - Clean up temporary and intermediate data
```

## Best Practices

### Development Best Practices
```yaml
Code Organization:
  - Use version control for job scripts
  - Implement modular, reusable functions
  - Add comprehensive error handling
  - Include logging and monitoring

Testing Strategy:
  - Test with sample data first
  - Implement unit tests for transformations
  - Use development endpoints for interactive testing
  - Validate data quality at each step

Documentation:
  - Document data lineage and transformations
  - Maintain schema documentation
  - Create operational runbooks
  - Document performance tuning decisions
```

### Operational Best Practices
```yaml
Monitoring:
  - Set up CloudWatch alarms for job failures
  - Monitor job duration and resource usage
  - Track data quality metrics
  - Implement automated alerting

Data Management:
  - Implement data lifecycle policies
  - Regular cleanup of temporary data
  - Monitor and manage crawler schedules
  - Maintain data catalog hygiene

Performance:
  - Regular performance reviews and optimization
  - Monitor and tune Spark configurations
  - Implement caching for frequently accessed data
  - Use appropriate file formats and compression
```
