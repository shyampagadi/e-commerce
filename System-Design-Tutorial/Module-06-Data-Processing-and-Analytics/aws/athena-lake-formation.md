# Amazon Athena and Lake Formation

## Amazon Athena Overview
Amazon Athena is an interactive query service that makes it easy to analyze data in Amazon S3 using standard SQL. Athena is serverless, so there is no infrastructure to manage, and you pay only for the queries that you run.

## Core Capabilities

### Serverless Query Engine
```yaml
Architecture:
  - Serverless: No infrastructure to provision or manage
  - Presto-based: Uses distributed SQL query engine
  - S3 Integration: Queries data directly from S3
  - Glue Integration: Uses Glue Data Catalog for metadata

Key Features:
  - Standard SQL support (ANSI SQL)
  - Multiple data format support
  - Automatic scaling based on query complexity
  - Pay-per-query pricing model
  - Integration with BI tools

Supported Data Formats:
  - Parquet (recommended for analytics)
  - ORC (Optimized Row Columnar)
  - JSON (flexible but less efficient)
  - CSV (simple but limited optimization)
  - Avro (good for schema evolution)
  - Ion (Amazon's data interchange format)
```

### Query Performance Optimization
```yaml
Data Format Optimization:
  Columnar Formats:
    - Parquet: 5-10x faster queries, 70% less storage
    - ORC: Similar benefits, better for Hive compatibility
    - Compression: SNAPPY, GZIP, LZO support
  
  Partitioning:
    - Partition by frequently filtered columns
    - Common patterns: year/month/day, region, category
    - Partition projection for automatic partition discovery
    - Avoid over-partitioning (too many small files)
  
  File Size Optimization:
    - Optimal file size: 128MB - 1GB
    - Avoid small files (<128MB)
    - Use compaction for small file consolidation
    - Monitor file size distribution

Query Optimization Techniques:
  -- Use LIMIT for exploratory queries
  SELECT * FROM large_table LIMIT 100;
  
  -- Use column pruning
  SELECT customer_id, amount FROM sales; -- Not SELECT *
  
  -- Use partition pruning
  SELECT * FROM sales 
  WHERE year = 2023 AND month = 1; -- Partition columns
  
  -- Use appropriate data types
  SELECT customer_id::INTEGER, amount::DECIMAL(10,2) FROM sales;
  
  -- Use APPROXIMATE functions for large datasets
  SELECT APPROX_DISTINCT(customer_id) FROM sales;
```

### Cost Optimization
```yaml
Pricing Model:
  - $5.00 per TB of data scanned
  - No charges for failed queries
  - No charges for DDL operations
  - Compression reduces costs significantly

Cost Reduction Strategies:
  Columnar Formats:
    - Parquet: Scan only required columns
    - 5-10x cost reduction vs row formats
    - Built-in compression
    - Predicate pushdown support
  
  Partitioning:
    - Reduce data scanned by filtering partitions
    - 10-100x cost reduction for time-based queries
    - Automatic partition pruning
    - Partition projection for dynamic partitions
  
  Compression:
    - GZIP: 70-90% size reduction
    - SNAPPY: Fast compression/decompression
    - LZ4: Good balance of speed and compression
    - Choose based on query patterns

Query Result Caching:
  - Automatic caching of query results
  - 24-hour cache retention
  - No additional charges for cached results
  - Significant cost savings for repeated queries
```

## AWS Lake Formation

### Data Lake Management
```yaml
Purpose:
  - Centralized data lake governance
  - Fine-grained access control
  - Data discovery and cataloging
  - ETL workflow management
  - Security and compliance

Core Components:
  Data Catalog:
    - Centralized metadata repository
    - Integration with Glue Data Catalog
    - Automatic schema discovery
    - Data lineage tracking
  
  Security:
    - Fine-grained access control
    - Column and row-level security
    - Integration with IAM and Active Directory
    - Data masking and tokenization
  
  Data Ingestion:
    - Blueprints for common ingestion patterns
    - Workflow orchestration
    - Data validation and quality checks
    - Error handling and monitoring
```

### Security and Access Control
```yaml
Lake Formation Permissions:
  Database Permissions:
    - CREATE_DATABASE
    - ALTER_DATABASE
    - DROP_DATABASE
    - DESCRIBE_DATABASE
  
  Table Permissions:
    - CREATE_TABLE
    - ALTER_TABLE
    - DROP_TABLE
    - SELECT
    - INSERT
    - DELETE
  
  Column-Level Permissions:
    - SELECT on specific columns
    - Exclude sensitive columns
    - Data masking for PII
    - Conditional access based on user attributes

Row-Level Security:
  -- Create data filter
  CREATE DATA FILTER customer_filter
  ON DATABASE sales_db TABLE customers
  WITH FILTER EXPRESSION 'region = current_user_region()'
  GRANT TO ROLE analyst_role;

Data Location Permissions:
  - S3 bucket and prefix access
  - Cross-account data sharing
  - External data source access
  - Temporary credential management

Implementation Example:
  # Grant table access with column filtering
  aws lakeformation grant-permissions \
    --principal DataLakePrincipalIdentifier=arn:aws:iam::account:role/AnalystRole \
    --resource '{"Table":{"DatabaseName":"sales_db","Name":"customers"}}' \
    --permissions SELECT \
    --permissions-with-grant-option SELECT \
    --resource-info '{"ResourceArn":"arn:aws:s3:::my-data-bucket/customers/"}'
```

### Data Discovery and Cataloging
```yaml
Automatic Discovery:
  - Crawlers for schema inference
  - Partition discovery and management
  - Schema evolution detection
  - Data classification and tagging

Blueprints:
  - Pre-built ingestion workflows
  - Common data source patterns
  - Customizable templates
  - Best practice implementations
  
  Available Blueprints:
    - Database ingestion (JDBC sources)
    - Log file processing
    - Incremental data loading
    - Change data capture (CDC)

Data Lineage:
  - Track data flow from source to consumption
  - Impact analysis for changes
  - Compliance and audit support
  - Visual lineage representation
```

## Integration Patterns

### Athena with Other AWS Services
```yaml
QuickSight Integration:
  - Direct connection to Athena
  - Automatic schema discovery
  - Interactive dashboards
  - Scheduled report generation
  
  Benefits:
    - Serverless BI solution
    - Cost-effective for variable usage
    - Easy setup and configuration
    - Automatic scaling

SageMaker Integration:
  - Data preparation for ML models
  - Feature engineering with SQL
  - Model training data extraction
  - Batch inference data processing
  
  Example:
    -- Prepare training data
    CREATE TABLE ml_training_data AS
    SELECT customer_id,
           age,
           income,
           purchase_frequency,
           avg_order_value,
           churn_flag
    FROM customer_analytics
    WHERE training_period = 'Q1_2023';

Lambda Integration:
  - Event-driven query execution
  - Automated report generation
  - Data quality monitoring
  - Custom notification systems
  
  Example Lambda Function:
    import boto3
    
    def lambda_handler(event, context):
        athena = boto3.client('athena')
        
        query = """
        SELECT COUNT(*) as daily_transactions
        FROM transactions
        WHERE date = CURRENT_DATE
        """
        
        response = athena.start_query_execution(
            QueryString=query,
            ResultConfiguration={
                'OutputLocation': 's3://query-results-bucket/'
            },
            WorkGroup='primary'
        )
        
        return response['QueryExecutionId']
```

### Lake Formation Integration Patterns
```yaml
Data Lake Setup:
  1. Register S3 locations with Lake Formation
  2. Create databases and tables in Data Catalog
  3. Set up fine-grained permissions
  4. Configure data filters and masking
  5. Enable cross-account sharing

Cross-Account Data Sharing:
  # Share database with another account
  aws lakeformation put-data-lake-settings \
    --data-lake-settings CreateDatabaseDefaultPermissions=[],CreateTableDefaultPermissions=[]
  
  aws lakeformation grant-permissions \
    --principal DataLakePrincipalIdentifier=123456789012 \
    --resource '{"Database":{"Name":"shared_database"}}' \
    --permissions DESCRIBE

Multi-Region Setup:
  - Replicate Data Catalog across regions
  - Cross-region S3 access configuration
  - Regional Lake Formation administrators
  - Consistent security policies
```

## Advanced Query Patterns

### Complex Analytical Queries
```sql
-- Customer Lifetime Value Calculation
WITH customer_metrics AS (
  SELECT 
    customer_id,
    MIN(order_date) as first_order_date,
    MAX(order_date) as last_order_date,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(order_amount) as total_spent,
    AVG(order_amount) as avg_order_value,
    DATEDIFF(day, MIN(order_date), MAX(order_date)) as customer_lifespan_days
  FROM orders
  WHERE order_status = 'completed'
  GROUP BY customer_id
),
customer_segments AS (
  SELECT *,
    CASE 
      WHEN total_spent > 10000 THEN 'High Value'
      WHEN total_spent > 1000 THEN 'Medium Value'
      ELSE 'Low Value'
    END as customer_segment,
    total_spent / NULLIF(customer_lifespan_days, 0) * 365 as annual_value
  FROM customer_metrics
)
SELECT 
  customer_segment,
  COUNT(*) as customer_count,
  AVG(total_spent) as avg_total_spent,
  AVG(annual_value) as avg_annual_value,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_spent) as median_spent
FROM customer_segments
GROUP BY customer_segment
ORDER BY avg_total_spent DESC;

-- Time Series Analysis with Window Functions
SELECT 
  date_trunc('month', order_date) as month,
  SUM(order_amount) as monthly_revenue,
  LAG(SUM(order_amount), 1) OVER (ORDER BY date_trunc('month', order_date)) as prev_month_revenue,
  (SUM(order_amount) - LAG(SUM(order_amount), 1) OVER (ORDER BY date_trunc('month', order_date))) 
    / LAG(SUM(order_amount), 1) OVER (ORDER BY date_trunc('month', order_date)) * 100 as growth_rate,
  AVG(SUM(order_amount)) OVER (
    ORDER BY date_trunc('month', order_date) 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) as three_month_avg
FROM orders
WHERE order_date >= DATE '2022-01-01'
GROUP BY date_trunc('month', order_date)
ORDER BY month;

-- Cohort Analysis
WITH cohorts AS (
  SELECT 
    customer_id,
    DATE_TRUNC('month', MIN(order_date)) as cohort_month,
    DATE_TRUNC('month', order_date) as order_month
  FROM orders
  GROUP BY customer_id, DATE_TRUNC('month', order_date)
),
cohort_data AS (
  SELECT 
    cohort_month,
    order_month,
    DATEDIFF(month, cohort_month, order_month) as period_number,
    COUNT(DISTINCT customer_id) as customers
  FROM cohorts
  GROUP BY cohort_month, order_month
),
cohort_sizes AS (
  SELECT 
    cohort_month,
    COUNT(DISTINCT customer_id) as cohort_size
  FROM cohorts
  WHERE cohort_month = order_month
  GROUP BY cohort_month
)
SELECT 
  c.cohort_month,
  c.period_number,
  c.customers,
  s.cohort_size,
  ROUND(c.customers * 100.0 / s.cohort_size, 2) as retention_rate
FROM cohort_data c
JOIN cohort_sizes s ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.period_number;
```

### Performance Tuning
```yaml
Query Optimization:
  Projection Pushdown:
    - Select only required columns
    - Reduces data scanned and costs
    - Automatic with columnar formats
    - Significant performance improvement
  
  Predicate Pushdown:
    - Apply filters early in processing
    - Reduces data processed
    - Works with partitioning
    - Automatic optimization
  
  Join Optimization:
    - Use broadcast joins for small tables
    - Optimize join order
    - Consider data distribution
    - Use appropriate join types

Workgroup Configuration:
  -- Create workgroup with settings
  CREATE WORKGROUP analytics_team
  WITH (
    result_configuration_location = 's3://athena-results-bucket/',
    bytes_scanned_cutoff_per_query = 1073741824, -- 1GB limit
    enforce_workgroup_configuration = true,
    publish_cloudwatch_metrics = true
  );

Query Result Optimization:
  - Use CTAS (CREATE TABLE AS SELECT) for reusable results
  - Implement result caching strategies
  - Optimize output formats
  - Use compression for result storage
  
  -- Create optimized table from query results
  CREATE TABLE optimized_sales
  WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    partitioned_by = ARRAY['year', 'month']
  ) AS
  SELECT customer_id, product_id, amount, 
         YEAR(order_date) as year,
         MONTH(order_date) as month
  FROM raw_sales
  WHERE order_date >= DATE '2023-01-01';
```

## AWS Lake Formation

### Data Lake Governance
```yaml
Core Capabilities:
  - Centralized permissions management
  - Fine-grained access control
  - Data discovery and classification
  - ETL workflow management
  - Cross-account data sharing

Permission Model:
  Lake Formation Permissions:
    - Database-level permissions
    - Table-level permissions
    - Column-level permissions
    - Row-level security filters
  
  IAM Integration:
    - Lake Formation principals
    - Cross-account access
    - Temporary credentials
    - Service-linked roles

Data Filters:
  -- Create row-level security filter
  CREATE DATA FILTER sales_filter
  ON DATABASE retail_db TABLE sales
  WITH FILTER EXPRESSION 'region = get_current_user_region()'
  GRANT TO ROLE regional_analyst;
  
  -- Column-level access control
  GRANT SELECT (customer_id, order_date, amount)
  ON TABLE sales TO ROLE basic_analyst;
  
  REVOKE SELECT (customer_ssn, customer_phone)
  ON TABLE sales FROM ROLE basic_analyst;
```

### Data Discovery and Classification
```yaml
Automatic Discovery:
  - ML-powered data classification
  - PII detection and tagging
  - Sensitive data identification
  - Compliance risk assessment

Classification Categories:
  - Personal Information (PII)
  - Financial Information
  - Healthcare Information (PHI)
  - Intellectual Property
  - Public Information

Tagging Strategy:
  Data Sensitivity:
    - Public: No restrictions
    - Internal: Employee access only
    - Confidential: Role-based access
    - Restricted: Explicit approval required
  
  Data Quality:
    - Verified: Passed quality checks
    - Unverified: Raw or untested data
    - Quarantined: Failed quality checks
    - Archived: Historical data
  
  Business Context:
    - Customer Data
    - Financial Data
    - Operational Data
    - Marketing Data
```

### ETL Blueprints and Workflows
```yaml
Blueprint Types:
  Database Ingestion:
    - JDBC source connections
    - Incremental data loading
    - Schema evolution handling
    - Data validation and quality checks
  
  Log Processing:
    - CloudTrail log analysis
    - VPC Flow Log processing
    - Application log parsing
    - Security event correlation
  
  Streaming Data:
    - Kinesis stream processing
    - Real-time data transformation
    - Stream-to-batch conversion
    - Event-driven workflows

Workflow Orchestration:
  -- Create workflow
  aws lakeformation create-lf-tag \
    --tag-key "Environment" \
    --tag-values "Production,Development,Testing"
  
  -- Apply tags to resources
  aws lakeformation add-lf-tags-to-resource \
    --resource '{"Database":{"Name":"sales_db"}}' \
    --lf-tags Key=Environment,Values=Production
  
  -- Create tag-based permissions
  aws lakeformation grant-permissions \
    --principal DataLakePrincipalIdentifier=arn:aws:iam::account:role/DataAnalyst \
    --resource '{"LFTagPolicy":{"ResourceType":"DATABASE","Expression":[{"TagKey":"Environment","TagValues":["Production"]}]}}' \
    --permissions DESCRIBE,SELECT
```

## Advanced Analytics Patterns

### Federated Queries
```yaml
Purpose: Query data across multiple sources without data movement
Supported Sources:
  - Amazon RDS (MySQL, PostgreSQL)
  - Amazon Aurora
  - Amazon Redshift
  - On-premises databases via VPN/Direct Connect

Setup:
  -- Create data source connector
  CREATE EXTERNAL DATA SOURCE mysql_connector
  TYPE MYSQL
  LOCATION 'mysql://rds-endpoint:3306/production_db'
  CREDENTIAL_NAME 'mysql-credentials';
  
  -- Query across federated sources
  SELECT 
    a.customer_id,
    a.total_orders,
    b.customer_name,
    b.customer_segment
  FROM athena_table a
  JOIN mysql_connector.customers b
    ON a.customer_id = b.customer_id
  WHERE a.order_date >= DATE '2023-01-01';

Benefits:
  - No data movement required
  - Real-time data access
  - Reduced storage costs
  - Simplified architecture

Considerations:
  - Network latency impact
  - Source system performance
  - Data consistency challenges
  - Security and access control
```

### Machine Learning Integration
```yaml
SageMaker Integration:
  Data Preparation:
    -- Create training dataset
    CREATE TABLE ml_training_data AS
    SELECT 
      customer_id,
      age,
      income,
      purchase_frequency,
      avg_order_value,
      days_since_last_order,
      churn_flag
    FROM customer_features
    WHERE training_period = 'Q1_2023';
  
  Feature Engineering:
    -- Create features for ML model
    SELECT 
      customer_id,
      CASE 
        WHEN age < 25 THEN 'Young'
        WHEN age < 45 THEN 'Middle'
        ELSE 'Senior'
      END as age_group,
      CASE
        WHEN purchase_frequency > 10 THEN 'High'
        WHEN purchase_frequency > 5 THEN 'Medium'
        ELSE 'Low'
      END as purchase_segment,
      LOG(income + 1) as log_income,
      SQRT(days_since_last_order) as sqrt_recency
    FROM customer_data;

Model Inference:
  -- Batch prediction using SageMaker
  SELECT 
    customer_id,
    sagemaker_invoke_endpoint(
      'churn-prediction-endpoint',
      age, income, purchase_frequency
    ) as churn_probability
  FROM customer_features
  WHERE prediction_date = CURRENT_DATE;
```

### Real-Time Analytics
```yaml
Near Real-Time Queries:
  - Query recent data in S3
  - Combine with streaming data
  - Use partition projection for performance
  - Implement caching strategies

Streaming Integration:
  -- Query Kinesis Data Firehose output
  SELECT 
    DATE_TRUNC('hour', event_time) as hour,
    event_type,
    COUNT(*) as event_count
  FROM kinesis_output
  WHERE event_time >= CURRENT_TIMESTAMP - INTERVAL '1' HOUR
  GROUP BY DATE_TRUNC('hour', event_time), event_type
  ORDER BY hour DESC;

Dashboard Integration:
  - Real-time dashboard updates
  - Scheduled query execution
  - Automated report generation
  - Alert-based query triggers
```

## Best Practices

### Query Design
```yaml
Performance Best Practices:
  - Use columnar formats (Parquet, ORC)
  - Implement proper partitioning
  - Optimize file sizes (128MB-1GB)
  - Use compression (SNAPPY, GZIP)
  - Avoid SELECT * queries
  - Use LIMIT for exploratory queries
  - Leverage partition pruning
  - Use approximate functions for large datasets

Cost Optimization:
  - Monitor query costs with CloudWatch
  - Set up cost alerts and budgets
  - Use workgroups for cost control
  - Implement query result caching
  - Optimize data formats and compression
  - Use partition projection to reduce metadata calls

Security Best Practices:
  - Use IAM roles instead of users
  - Implement least privilege access
  - Enable CloudTrail logging
  - Use VPC endpoints for private access
  - Encrypt data at rest and in transit
  - Regular access reviews and audits
```

### Operational Excellence
```yaml
Monitoring:
  - Query performance metrics
  - Cost tracking and optimization
  - Data freshness monitoring
  - Error rate tracking
  - User activity monitoring

Automation:
  - Automated table creation and updates
  - Scheduled query execution
  - Data quality monitoring
  - Cost optimization recommendations
  - Security compliance checks

Documentation:
  - Data dictionary and catalog
  - Query examples and templates
  - Performance tuning guides
  - Security procedures
  - Troubleshooting runbooks
```
