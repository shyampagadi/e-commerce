# Batch Processing Systems

## Overview
Batch processing is a method of processing large volumes of data where groups of transactions are collected over a period of time and then processed together as a batch. This approach is ideal for scenarios where real-time processing is not required and efficiency is prioritized over latency.

## MapReduce Paradigm

### Core Concepts
```yaml
MapReduce Philosophy:
  - Divide large problems into smaller, parallelizable tasks
  - Process data where it resides (data locality)
  - Handle failures gracefully through redundancy
  - Scale horizontally by adding more machines

Programming Model:
  Map Phase:
    - Input: Key-value pairs from input data
    - Processing: Apply transformation function to each record
    - Output: Intermediate key-value pairs
    - Parallelism: Each mapper processes independent data splits
  
  Shuffle Phase:
    - Sorting: Group intermediate data by key
    - Partitioning: Distribute data to reducers
    - Network Transfer: Move data between nodes
    - Optimization: Combine operations to reduce network traffic
  
  Reduce Phase:
    - Input: Grouped intermediate key-value pairs
    - Processing: Apply aggregation function to grouped data
    - Output: Final results
    - Parallelism: Each reducer processes independent key groups
```

### MapReduce Example: Word Count
```java
// Mapper Class
public class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();
    
    @Override
    public void map(LongWritable key, Text value, Context context) 
            throws IOException, InterruptedException {
        
        // Convert to lowercase and split into words
        String[] words = value.toString().toLowerCase().split("\\s+");
        
        // Emit each word with count of 1
        for (String w : words) {
            word.set(w);
            context.write(word, one);
        }
    }
}

// Reducer Class
public class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    private IntWritable result = new IntWritable();
    
    @Override
    public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
        
        int sum = 0;
        // Sum up the counts for each word
        for (IntWritable value : values) {
            sum += value.get();
        }
        
        result.set(sum);
        context.write(key, result);
    }
}

// Driver Class
public class WordCount {
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");
        
        job.setJarByClass(WordCount.class);
        job.setMapperClass(WordCountMapper.class);
        job.setCombinerClass(WordCountReducer.class);  // Local aggregation
        job.setReducerClass(WordCountReducer.class);
        
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

### Advanced MapReduce Patterns
```yaml
Combiner Pattern:
  Purpose: Local aggregation to reduce network traffic
  Implementation: Same as reducer but runs on mapper nodes
  Benefits: Reduces shuffle data by 90%+ in many cases
  Use Cases: Sum, count, average calculations

Chain Pattern:
  Purpose: Sequence multiple MapReduce jobs
  Implementation: Output of one job becomes input of next
  Challenges: Intermediate data storage and management
  Optimization: In-memory chaining where possible

Join Pattern:
  Reduce-side Join:
    - All data goes through shuffle phase
    - Handles large datasets on both sides
    - Higher network overhead
    - Most flexible approach
  
  Map-side Join:
    - Smaller dataset distributed to all mappers
    - No shuffle phase required
    - Much faster execution
    - Limited by memory constraints
  
  Broadcast Join:
    - Small dataset cached on all nodes
    - Extremely fast execution
    - Minimal network overhead
    - Suitable for dimension tables
```

## Apache Spark Architecture

### Core Components
```yaml
Spark Driver:
  - Main program that coordinates the application
  - Creates SparkContext and manages job execution
  - Schedules tasks and monitors progress
  - Collects results and handles failures

Cluster Manager:
  - Allocates resources across the cluster
  - Options: Standalone, YARN, Mesos, Kubernetes
  - Manages worker nodes and resource allocation
  - Handles node failures and recovery

Executors:
  - Worker processes that run tasks
  - Store data in memory or disk for caching
  - Report status back to driver
  - Execute code sent by driver

Spark Context:
  - Entry point for Spark functionality
  - Coordinates with cluster manager
  - Creates RDDs and manages their lifecycle
  - Configures Spark application settings
```

### Resilient Distributed Datasets (RDDs)
```scala
// Creating RDDs
val textFile = spark.sparkContext.textFile("hdfs://path/to/file.txt")
val numbers = spark.sparkContext.parallelize(1 to 1000000)

// Transformations (lazy evaluation)
val words = textFile.flatMap(line => line.split(" "))
val wordPairs = words.map(word => (word, 1))
val wordCounts = wordPairs.reduceByKey(_ + _)

// Actions (trigger computation)
val results = wordCounts.collect()
val count = wordCounts.count()
wordCounts.saveAsTextFile("hdfs://path/to/output")

// Caching for performance
val cachedRDD = wordCounts.cache()  // Store in memory
val persistedRDD = wordCounts.persist(StorageLevel.MEMORY_AND_DISK_SER)
```

### Spark SQL and DataFrames
```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

val spark = SparkSession.builder()
  .appName("Batch Processing Example")
  .getOrCreate()

// Read data from various sources
val df = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv("s3://bucket/data/sales.csv")

// DataFrame transformations
val processedDF = df
  .filter(col("amount") > 0)
  .withColumn("year", year(col("date")))
  .withColumn("month", month(col("date")))
  .groupBy("year", "month", "category")
  .agg(
    sum("amount").alias("total_sales"),
    count("*").alias("transaction_count"),
    avg("amount").alias("avg_transaction")
  )

// Write results
processedDF.write
  .mode("overwrite")
  .partitionBy("year", "month")
  .parquet("s3://bucket/processed/sales_summary")

// SQL interface
df.createOrReplaceTempView("sales")
val sqlResult = spark.sql("""
  SELECT category, 
         SUM(amount) as total_sales,
         COUNT(*) as transaction_count
  FROM sales 
  WHERE date >= '2023-01-01'
  GROUP BY category
  ORDER BY total_sales DESC
""")
```

## Distributed Computing Frameworks

### Apache Hadoop Ecosystem
```yaml
HDFS (Hadoop Distributed File System):
  Architecture:
    - NameNode: Metadata management and coordination
    - DataNodes: Actual data storage and retrieval
    - Secondary NameNode: Backup and checkpointing
  
  Features:
    - Fault tolerance through replication (default 3x)
    - Data locality optimization
    - Large file optimization (64MB+ blocks)
    - Write-once, read-many access pattern
  
  Configuration:
    Block Size: 128MB (default), tune based on use case
    Replication Factor: 3 (default), adjust for durability needs
    Rack Awareness: Optimize placement across racks
    Compression: Enable to reduce storage and I/O

YARN (Yet Another Resource Negotiator):
  Components:
    - ResourceManager: Global resource allocation
    - NodeManager: Per-node resource management
    - ApplicationMaster: Per-application coordination
    - Container: Resource allocation unit
  
  Benefits:
    - Multi-tenancy support
    - Resource isolation and sharing
    - Support for multiple processing frameworks
    - Dynamic resource allocation

Hive (Data Warehouse):
  Purpose: SQL-like interface for Hadoop data
  Architecture:
    - Metastore: Schema and metadata storage
    - Query Engine: SQL to MapReduce/Spark translation
    - SerDe: Serialization/deserialization libraries
  
  Optimization:
    - Partitioning: Organize data by common filter columns
    - Bucketing: Distribute data evenly across files
    - Vectorization: Process multiple rows simultaneously
    - Cost-based Optimizer: Choose optimal execution plans
```

### Performance Optimization Strategies
```yaml
Data Format Optimization:
  Columnar Formats:
    Parquet:
      - Excellent compression (70-90% reduction)
      - Predicate pushdown support
      - Schema evolution capabilities
      - Industry standard for analytics
    
    ORC (Optimized Row Columnar):
      - Optimized for Hive workloads
      - Built-in indexing and statistics
      - ACID transaction support
      - Better for write-heavy workloads
  
  Row Formats:
    Avro:
      - Schema evolution support
      - Good for streaming and ETL
      - Compact binary format
      - Language-agnostic
    
    JSON:
      - Human readable and flexible
      - Schema-on-read capability
      - Inefficient for large datasets
      - Good for semi-structured data

Partitioning Strategies:
  Time-based Partitioning:
    - Partition by year/month/day/hour
    - Enables efficient time range queries
    - Automatic partition pruning
    - Lifecycle management support
  
  Hash Partitioning:
    - Even distribution across partitions
    - Good for parallel processing
    - Avoids data skew issues
    - Enables efficient joins
  
  Range Partitioning:
    - Partition by value ranges
    - Enables range queries
    - May create uneven partitions
    - Good for sorted data access

Caching and Persistence:
  Memory Caching:
    - Store frequently accessed data in RAM
    - Significant performance improvement
    - Limited by available memory
    - Use for iterative algorithms
  
  Disk Persistence:
    - Spill to disk when memory full
    - Slower than memory but more capacity
    - Good for large datasets
    - Use appropriate storage levels
  
  Serialization:
    - Java serialization (default, slow)
    - Kryo serialization (faster, more compact)
    - Custom serialization for specific types
    - Balance between speed and size
```

## Job Scheduling and Orchestration

### Workflow Management
```yaml
Apache Airflow:
  Concepts:
    - DAG: Directed Acyclic Graph of tasks
    - Operator: Individual task implementation
    - Scheduler: Manages task execution timing
    - Executor: Runs tasks on workers
  
  Features:
    - Rich UI for monitoring and debugging
    - Extensive operator library
    - Dynamic DAG generation
    - Retry and error handling
    - SLA monitoring and alerting
  
  Example DAG:
    from airflow import DAG
    from airflow.operators.bash_operator import BashOperator
    from airflow.operators.python_operator import PythonOperator
    from datetime import datetime, timedelta
    
    default_args = {
        'owner': 'data-team',
        'depends_on_past': False,
        'start_date': datetime(2023, 1, 1),
        'email_on_failure': True,
        'email_on_retry': False,
        'retries': 2,
        'retry_delay': timedelta(minutes=5)
    }
    
    dag = DAG(
        'daily_batch_processing',
        default_args=default_args,
        description='Daily data processing pipeline',
        schedule_interval='0 2 * * *',  # Run at 2 AM daily
        catchup=False
    )
    
    extract_data = BashOperator(
        task_id='extract_data',
        bash_command='python /scripts/extract.py {{ ds }}',
        dag=dag
    )
    
    process_data = BashOperator(
        task_id='process_data',
        bash_command='spark-submit /scripts/process.py {{ ds }}',
        dag=dag
    )
    
    load_data = BashOperator(
        task_id='load_data',
        bash_command='python /scripts/load.py {{ ds }}',
        dag=dag
    )
    
    extract_data >> process_data >> load_data

Apache Oozie:
  Purpose: Hadoop-native workflow scheduler
  Features:
    - XML-based workflow definition
    - Coordinator for time-based scheduling
    - Bundle for grouping related workflows
    - Integration with Hadoop ecosystem
  
  Workflow Types:
    - Sequential: Linear task execution
    - Parallel: Concurrent task execution
    - Conditional: Decision-based branching
    - Loop: Iterative processing
```

### Resource Management
```yaml
Capacity Planning:
  CPU Requirements:
    - Estimate based on data volume and complexity
    - Consider peak vs average loads
    - Account for parallel processing capabilities
    - Monitor actual usage and adjust
  
  Memory Requirements:
    - Data size + processing overhead
    - Caching requirements for performance
    - JVM heap size considerations
    - Buffer space for I/O operations
  
  Storage Requirements:
    - Input data size
    - Intermediate data (2-3x input size)
    - Output data size
    - Temporary space for sorting/shuffling

Auto-scaling Strategies:
  Predictive Scaling:
    - Based on historical patterns
    - Pre-scale before expected load
    - Reduces startup latency
    - Requires good usage patterns
  
  Reactive Scaling:
    - Based on current metrics
    - Scale up when thresholds exceeded
    - Scale down when utilization low
    - May have lag in response
  
  Scheduled Scaling:
    - Based on known schedules
    - Good for batch processing windows
    - Predictable cost management
    - Requires stable schedules
```

## Fault Tolerance and Recovery

### Failure Modes
```yaml
Hardware Failures:
  Node Failures:
    - Detection: Heartbeat monitoring
    - Recovery: Task redistribution
    - Prevention: Redundancy and replication
    - Impact: Temporary performance degradation
  
  Disk Failures:
    - Detection: I/O error monitoring
    - Recovery: Data replication and reconstruction
    - Prevention: RAID and distributed storage
    - Impact: Data loss if replication insufficient
  
  Network Failures:
    - Detection: Connection timeout monitoring
    - Recovery: Alternative routing and retry
    - Prevention: Redundant network paths
    - Impact: Temporary connectivity loss

Software Failures:
  Application Bugs:
    - Detection: Exception monitoring and logging
    - Recovery: Task restart and retry
    - Prevention: Testing and code review
    - Impact: Job failure or incorrect results
  
  Resource Exhaustion:
    - Detection: Memory and disk monitoring
    - Recovery: Resource cleanup and reallocation
    - Prevention: Resource limits and monitoring
    - Impact: Performance degradation or failure
  
  Configuration Errors:
    - Detection: Validation and health checks
    - Recovery: Configuration rollback
    - Prevention: Configuration management
    - Impact: Service unavailability
```

### Recovery Strategies
```yaml
Checkpointing:
  Purpose: Save intermediate state for recovery
  Implementation:
    - Periodic state snapshots
    - Write to persistent storage
    - Coordinate across distributed components
    - Balance frequency vs overhead
  
  Types:
    - Application-level: Custom checkpointing logic
    - Framework-level: Built-in checkpointing
    - System-level: VM or container snapshots
    - Data-level: Intermediate data persistence

Retry Mechanisms:
  Exponential Backoff:
    - Increase delay between retries
    - Prevents overwhelming failed systems
    - Includes jitter to avoid thundering herd
    - Configurable maximum delay and attempts
  
  Circuit Breaker:
    - Stop retrying after threshold failures
    - Periodic health checks for recovery
    - Fail fast to prevent cascading failures
    - Gradual recovery when service restored

Data Recovery:
  Replication:
    - Multiple copies of data
    - Automatic failover to replicas
    - Consistency considerations
    - Storage overhead trade-off
  
  Backup and Restore:
    - Regular data backups
    - Point-in-time recovery capability
    - Cross-region backup for disaster recovery
    - Recovery time vs cost trade-off
```

## Performance Monitoring and Tuning

### Key Metrics
```yaml
Throughput Metrics:
  - Records processed per second
  - Data volume processed per hour
  - Jobs completed per day
  - Resource utilization efficiency

Latency Metrics:
  - Job completion time
  - Task execution time
  - Data loading time
  - Queue waiting time

Resource Metrics:
  - CPU utilization per node
  - Memory usage and garbage collection
  - Disk I/O and network bandwidth
  - Storage utilization and growth

Quality Metrics:
  - Job success rate
  - Data quality scores
  - Error rates and types
  - SLA compliance metrics
```

### Optimization Techniques
```yaml
Code Optimization:
  Algorithm Selection:
    - Choose appropriate algorithms for data size
    - Consider time vs space complexity
    - Use parallel algorithms where possible
    - Optimize for common case scenarios
  
  Data Structure Optimization:
    - Use efficient data structures
    - Minimize object creation and GC pressure
    - Optimize serialization formats
    - Cache frequently accessed data
  
  I/O Optimization:
    - Minimize disk I/O operations
    - Use appropriate buffer sizes
    - Implement compression where beneficial
    - Optimize file formats for access patterns

Cluster Optimization:
  Resource Allocation:
    - Right-size cluster for workload
    - Balance CPU, memory, and I/O resources
    - Use appropriate instance types
    - Implement resource isolation
  
  Data Locality:
    - Process data where it's stored
    - Minimize network data movement
    - Use rack-aware scheduling
    - Implement intelligent data placement
  
  Parallelism Tuning:
    - Optimize number of parallel tasks
    - Balance parallelism vs overhead
    - Avoid resource contention
    - Consider data skew issues
```
