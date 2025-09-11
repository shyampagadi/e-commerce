# Knowledge Check Quiz: Data Processing and Analytics

## Instructions
- **Duration**: 60 minutes
- **Questions**: 50 questions
- **Passing Score**: 70% (35 correct answers)
- **Format**: Multiple choice, scenario-based, and calculation problems
- **Resources**: No external resources allowed during assessment

## Section A: Fundamental Concepts (12 questions)

### Question 1
Which architecture pattern is most suitable for a system requiring both real-time processing and historical batch analysis with different consistency requirements?

A) Kappa Architecture - single stream processing layer
B) Lambda Architecture - separate batch and speed layers  
C) Microservices Architecture - distributed service approach
D) Event Sourcing - immutable event log pattern

**Answer: B**
**Explanation**: Lambda Architecture specifically addresses the need for both real-time (speed layer) and batch processing (batch layer) with different consistency guarantees.

### Question 2
In the CAP theorem context, which consistency model does Amazon DynamoDB primarily implement?

A) Strong consistency for all operations
B) Eventual consistency with strong consistency options
C) Causal consistency with vector clocks
D) Sequential consistency with global ordering

**Answer: B**
**Explanation**: DynamoDB uses eventual consistency by default but offers strong consistency as an option for read operations.

### Question 3
Calculate the required Kinesis shard count for the following requirements:
- Peak throughput: 50,000 records/second
- Average record size: 2KB
- Each shard supports: 1,000 records/second or 1MB/second

A) 50 shards
B) 100 shards  
C) 150 shards
D) 200 shards

**Answer: B**
**Explanation**: 
- Records limit: 50,000 ÷ 1,000 = 50 shards
- Throughput limit: (50,000 × 2KB) ÷ 1MB = 100 shards
- Take the maximum: 100 shards required

### Question 4
Which data processing pattern is most appropriate for handling late-arriving data in stream processing?

A) Tumbling windows with fixed boundaries
B) Sliding windows with overlapping intervals
C) Session windows with dynamic gaps
D) Watermarks with allowed lateness

**Answer: D**
**Explanation**: Watermarks with allowed lateness specifically handle late-arriving data by defining how long to wait for delayed events.

### Question 5
In a Lambda architecture, what is the primary purpose of the serving layer?

A) Process real-time streaming data
B) Execute batch processing jobs
C) Merge and serve results from batch and speed layers
D) Store raw data for reprocessing

**Answer: C**
**Explanation**: The serving layer in Lambda architecture merges results from both batch and speed layers to provide a unified query interface.

### Question 6
Which statement about exactly-once processing semantics is correct?

A) It guarantees no duplicate processing under any circumstances
B) It ensures idempotent processing with proper deduplication
C) It requires distributed transactions across all components
D) It's impossible to achieve in distributed systems

**Answer: B**
**Explanation**: Exactly-once semantics is achieved through idempotent processing and deduplication mechanisms, not absolute guarantees.

### Question 7
What is the main advantage of columnar storage formats like Parquet for analytical workloads?

A) Faster random access to individual records
B) Better compression and query performance for analytics
C) Simpler schema evolution and versioning
D) Native support for real-time updates

**Answer: B**
**Explanation**: Columnar formats optimize for analytical queries by storing similar data together, enabling better compression and faster aggregations.

### Question 8
In stream processing, what does "backpressure" refer to?

A) The delay between event occurrence and processing
B) The mechanism to handle downstream processing bottlenecks
C) The pressure to maintain low latency requirements
D) The backup strategy for failed processing

**Answer: B**
**Explanation**: Backpressure is a flow control mechanism that handles situations where downstream components can't keep up with upstream data rates.

### Question 9
Which data modeling approach is most suitable for a data warehouse supporting OLAP queries?

A) Third Normal Form (3NF) for minimal redundancy
B) Star schema with denormalized fact and dimension tables
C) Document-based flexible schema design
D) Graph-based relationship modeling

**Answer: B**
**Explanation**: Star schema is optimized for OLAP queries with denormalized structures that enable fast aggregations and joins.

### Question 10
What is the primary difference between ETL and ELT approaches?

A) ETL processes data in real-time, ELT processes in batches
B) ETL transforms before loading, ELT loads then transforms
C) ETL uses SQL, ELT uses programming languages
D) ETL is for structured data, ELT is for unstructured data

**Answer: B**
**Explanation**: ETL transforms data before loading into the target system, while ELT loads raw data first and transforms within the target system.

### Question 11
In the context of data lakes, what does "schema-on-read" mean?

A) Schema is defined when data is written to storage
B) Schema is applied when data is queried or read
C) Schema changes are automatically detected
D) Schema validation happens during data ingestion

**Answer: B**
**Explanation**: Schema-on-read means the data structure is interpreted and applied when the data is accessed for analysis, not when stored.

### Question 12
Which consistency model provides the strongest guarantees in distributed systems?

A) Eventual consistency
B) Causal consistency
C) Strong consistency (linearizability)
D) Session consistency

**Answer: C**
**Explanation**: Strong consistency (linearizability) provides the strongest guarantees, making the system appear as if all operations occur atomically.

## Section B: AWS Services and Implementation (15 questions)

### Question 13
What is the maximum retention period for Amazon Kinesis Data Streams?

A) 24 hours
B) 7 days
C) 30 days
D) 365 days

**Answer: D**
**Explanation**: Kinesis Data Streams supports retention periods from 24 hours up to 365 days.

### Question 14
Which EMR instance type is most cost-effective for fault-tolerant batch processing workloads?

A) On-Demand instances for all nodes
B) Reserved instances for all nodes
C) Spot instances for task nodes only
D) Spot instances for all node types

**Answer: C**
**Explanation**: Spot instances for task nodes provide significant cost savings while maintaining reliability through core nodes on more stable instance types.

### Question 15
Calculate the monthly cost for a Redshift cluster with the following configuration:
- Node type: ra3.xlplus ($3.26/hour)
- Number of nodes: 4
- Usage: 24/7 operation
- Monthly hours: 730

A) $9,520
B) $9,520.80
C) $9,538.40
D) $10,000

**Answer: C**
**Explanation**: 4 nodes × $3.26/hour × 730 hours = $9,538.40

### Question 16
Which Kinesis Analytics window type is best for calculating rolling averages over the last 5 minutes?

A) Tumbling window (5 minutes)
B) Sliding window (5 minutes, 1 minute slide)
C) Session window (5 minute timeout)
D) Hopping window (5 minutes, 30 second hop)

**Answer: B**
**Explanation**: Sliding windows continuously update the calculation as new data arrives, perfect for rolling averages.

### Question 17
What is the primary benefit of using Amazon Redshift Spectrum?

A) Faster loading of data into Redshift tables
B) Querying data directly in S3 without loading
C) Automatic scaling of Redshift clusters
D) Real-time streaming data processing

**Answer: B**
**Explanation**: Redshift Spectrum allows querying data stored in S3 directly without needing to load it into Redshift tables.

### Question 18
Which AWS service provides the most cost-effective solution for infrequent analytical queries on petabyte-scale data?

A) Amazon Redshift with reserved instances
B) Amazon Athena with S3 storage
C) Amazon EMR with spot instances
D) Amazon RDS with read replicas

**Answer: B**
**Explanation**: Athena's serverless, pay-per-query model is most cost-effective for infrequent queries on large datasets stored in S3.

### Question 19
What is the maximum number of shards supported by a single Kinesis Data Stream?

A) 1,000 shards
B) 10,000 shards
C) No hard limit (service quotas apply)
D) 100,000 shards

**Answer: C**
**Explanation**: Kinesis doesn't have a hard limit on shards, but service quotas can be increased through AWS support requests.

### Question 20
Which DynamoDB feature is most appropriate for implementing time-series data with automatic expiration?

A) Global Secondary Indexes (GSI)
B) Time To Live (TTL)
C) DynamoDB Streams
D) Point-in-time Recovery

**Answer: B**
**Explanation**: TTL automatically deletes items after a specified time, perfect for time-series data with expiration requirements.

### Question 21
What is the recommended approach for handling schema evolution in AWS Glue Data Catalog?

A) Create new tables for each schema version
B) Use schema versioning with backward compatibility
C) Manually update all dependent jobs
D) Recreate the entire catalog

**Answer: B**
**Explanation**: Schema versioning with backward compatibility allows evolution while maintaining compatibility with existing jobs.

### Question 22
Which S3 storage class provides the lowest cost for data accessed once per quarter?

A) S3 Standard
B) S3 Standard-IA
C) S3 Glacier
D) S3 Glacier Deep Archive

**Answer: C**
**Explanation**: S3 Glacier is optimized for data accessed a few times per year, making it cost-effective for quarterly access patterns.

### Question 23
What is the primary advantage of using AWS Glue over traditional ETL tools?

A) Lower cost for all workloads
B) Serverless and fully managed service
C) Better performance for all data types
D) Native support for real-time processing

**Answer: B**
**Explanation**: Glue's serverless nature eliminates infrastructure management while providing automatic scaling and resource optimization.

### Question 24
Which Redshift distribution style is most appropriate for large fact tables in a star schema?

A) EVEN distribution
B) KEY distribution on foreign key
C) ALL distribution (broadcast)
D) AUTO distribution (let Redshift decide)

**Answer: D**
**Explanation**: AUTO distribution allows Redshift to automatically optimize distribution based on table size and query patterns.

### Question 25
What is the maximum file size that can be processed by a single AWS Lambda function?

A) 250 MB (deployment package)
B) 512 MB (temporary storage)
C) 3 GB (memory limit)
D) 10 GB (container image)

**Answer: D**
**Explanation**: Lambda supports container images up to 10 GB, though the deployment package limit is 250 MB for zip files.

### Question 26
Which AWS service combination provides the most cost-effective solution for real-time fraud detection on credit card transactions?

A) Kinesis Data Streams + Lambda + DynamoDB
B) Kinesis Analytics + SageMaker + RDS
C) MSK + EMR + Redshift
D) SQS + EC2 + Aurora

**Answer: A**
**Explanation**: This serverless combination provides low latency, automatic scaling, and cost-effective processing for real-time fraud detection.

### Question 27
What is the recommended partition key strategy for a DynamoDB table storing IoT sensor data?

A) Timestamp for chronological access
B) Device ID for device-specific queries
C) Composite key (Device ID + Timestamp)
D) Random UUID for even distribution

**Answer: C**
**Explanation**: Composite keys provide both even distribution and support for common query patterns (device-specific time ranges).

## Section C: Performance and Optimization (12 questions)

### Question 28
Calculate the theoretical maximum throughput for a Kinesis Data Stream with 100 shards:

A) 100,000 records/second, 100 MB/second
B) 1,000,000 records/second, 1 GB/second
C) 100,000 records/second, 1 GB/second
D) 1,000,000 records/second, 100 MB/second

**Answer: A**
**Explanation**: Each shard supports 1,000 records/second and 1 MB/second. 100 shards = 100,000 records/second and 100 MB/second.

### Question 29
Which Spark configuration parameter has the most impact on memory-intensive workloads?

A) spark.executor.cores
B) spark.executor.memory
C) spark.sql.shuffle.partitions
D) spark.serializer

**Answer: B**
**Explanation**: Executor memory directly determines how much data can be processed in memory, critical for memory-intensive operations.

### Question 30
What is the optimal file size range for Parquet files in S3 for analytical queries?

A) 1-10 MB
B) 128 MB - 1 GB
C) 1-5 GB
D) 10+ GB

**Answer: B**
**Explanation**: 128 MB to 1 GB provides optimal balance between parallelism and overhead for most analytical engines.

### Question 31
Which technique provides the most significant performance improvement for skewed data in Spark?

A) Increasing the number of partitions
B) Using broadcast joins for small tables
C) Salting the skewed keys
D) Caching intermediate results

**Answer: C**
**Explanation**: Salting distributes skewed keys across multiple partitions, directly addressing the root cause of skew-related performance issues.

### Question 32
Calculate the required bandwidth for streaming 50,000 events/second with average event size of 1.5 KB:

A) 75 MB/second
B) 600 Mbps
C) 75 Mbps
D) 600 MB/second

**Answer: B**
**Explanation**: 50,000 × 1.5 KB = 75 MB/second = 75 × 8 = 600 Mbps

### Question 33
Which caching strategy provides the best performance for frequently accessed dimension data in a data warehouse?

A) Database-level caching
B) Application-level caching with Redis
C) CDN caching at edge locations
D) In-memory columnar caching

**Answer: D**
**Explanation**: In-memory columnar caching provides the fastest access for analytical queries on dimension data.

### Question 34
What is the primary factor limiting query performance in Amazon Athena?

A) Number of concurrent queries
B) Amount of data scanned
C) Complexity of SQL queries
D) Number of partitions

**Answer: B**
**Explanation**: Athena charges and performance are primarily based on the amount of data scanned, making partition pruning crucial.

### Question 35
Which Redshift feature provides the most significant performance improvement for repetitive analytical queries?

A) Materialized views
B) Result caching
C) Columnar compression
D) Zone maps

**Answer: A**
**Explanation**: Materialized views pre-compute and store query results, providing the most significant improvement for repetitive analytical queries.

### Question 36
Calculate the storage savings from using Snappy compression on a 1 TB dataset with typical 70% compression ratio:

A) 300 GB saved, 700 GB total
B) 700 GB saved, 300 GB total
C) 300 GB saved, 1.3 TB total
D) 700 GB saved, 1.7 TB total

**Answer: B**
**Explanation**: 70% compression means 30% of original size remains. 1 TB × 0.3 = 300 GB total, 700 GB saved.

### Question 37
Which partitioning strategy provides the best query performance for time-series data in S3?

A) Hash partitioning by record ID
B) Range partitioning by timestamp (year/month/day)
C) Random partitioning for even distribution
D) Composite partitioning by user and timestamp

**Answer: B**
**Explanation**: Time-based partitioning enables efficient partition pruning for time-range queries, the most common pattern for time-series data.

### Question 38
What is the recommended approach for optimizing Spark applications with large shuffles?

A) Increase executor memory only
B) Reduce the number of partitions
C) Tune shuffle partitions and enable adaptive query execution
D) Use only broadcast joins

**Answer: C**
**Explanation**: Proper shuffle partition tuning and adaptive query execution provide the most comprehensive optimization for shuffle-heavy workloads.

### Question 39
Which metric is most important for monitoring stream processing performance?

A) CPU utilization
B) Memory usage
C) End-to-end latency
D) Network throughput

**Answer: C**
**Explanation**: End-to-end latency directly measures the system's ability to meet real-time processing requirements.

## Section D: Real-World Scenarios (11 questions)

### Question 40
A financial services company needs to process 1 million transactions per second for real-time fraud detection with <100ms latency. Which architecture is most appropriate?

A) Kinesis Data Streams + Lambda + DynamoDB
B) MSK + Kafka Streams + Cassandra
C) SQS + EC2 + RDS
D) EventBridge + Step Functions + Aurora

**Answer: B**
**Explanation**: MSK with Kafka Streams provides the ultra-low latency and high throughput required for this demanding real-time scenario.

### Question 41
An e-commerce company wants to implement real-time personalization for 10 million users with <50ms recommendation latency. What is the most critical component?

A) Real-time feature store with sub-10ms access
B) High-throughput model serving infrastructure
C) Distributed caching layer for recommendations
D) All of the above are equally critical

**Answer: D**
**Explanation**: Real-time personalization at this scale requires optimization across all components - feature access, model serving, and caching.

### Question 42
A media company needs to analyze 100TB of video metadata daily while supporting real-time content recommendations. Which architecture pattern is most suitable?

A) Pure batch processing with daily updates
B) Pure stream processing for all workloads
C) Lambda architecture with batch and stream layers
D) Microservices with event-driven communication

**Answer: C**
**Explanation**: Lambda architecture handles both the large-scale batch analysis and real-time recommendation requirements effectively.

### Question 43
Calculate the estimated monthly AWS cost for processing 1TB of data daily through the following pipeline:
- Kinesis Data Streams: $0.014 per million records
- Lambda: $0.20 per million requests
- S3 storage: $0.023 per GB
- Assume 1KB average record size

Daily records: 1TB ÷ 1KB = 1 billion records
Monthly records: 1 billion × 30 = 30 billion records

A) $420 (Kinesis) + $6,000 (Lambda) + $690 (S3) = $7,110
B) $420 (Kinesis) + $600 (Lambda) + $69 (S3) = $1,089
C) $42 (Kinesis) + $600 (Lambda) + $690 (S3) = $1,332
D) $420 (Kinesis) + $6,000 (Lambda) + $69 (S3) = $6,489

**Answer: A**
**Explanation**: 
- Kinesis: 30 billion ÷ 1 million × $0.014 = $420
- Lambda: 30 billion ÷ 1 million × $0.20 = $6,000  
- S3: 30TB × $0.023 = $690
- Total: $7,110

### Question 44
A healthcare organization must ensure HIPAA compliance while processing patient data in real-time. Which security measures are most critical?

A) Encryption at rest and in transit only
B) Access logging and audit trails only
C) Data anonymization and pseudonymization only
D) All security measures plus data governance framework

**Answer: D**
**Explanation**: HIPAA compliance requires comprehensive security including encryption, access controls, audit trails, data governance, and anonymization.

### Question 45
An IoT platform receives data from 1 million devices every 30 seconds. Each device sends 500 bytes. What is the minimum required Kinesis shard count?

Device data rate: 1M devices × 500 bytes ÷ 30 seconds = 16.67 MB/second
Records per second: 1M ÷ 30 = 33,333 records/second

A) 17 shards (based on throughput limit)
B) 34 shards (based on record limit)
C) 50 shards (with safety margin)
D) 100 shards (for future growth)

**Answer: B**
**Explanation**: 
- Throughput: 16.67 MB/s ÷ 1 MB/s = 17 shards
- Records: 33,333 ÷ 1,000 = 34 shards
- Take maximum: 34 shards required

### Question 46
A retail company wants to implement real-time inventory management across 1,000 stores. Which data consistency model is most appropriate?

A) Strong consistency for all operations
B) Eventual consistency with conflict resolution
C) Causal consistency for related updates
D) Session consistency per store

**Answer: B**
**Explanation**: Eventual consistency with conflict resolution handles network partitions while ensuring inventory accuracy through reconciliation mechanisms.

### Question 47
A social media platform needs to generate trending topics from 100 million posts per day. Which processing approach is most efficient?

A) Batch processing every hour with MapReduce
B) Stream processing with sliding windows
C) Hybrid approach with stream processing and batch validation
D) Real-time processing with in-memory databases

**Answer: C**
**Explanation**: Hybrid approach provides real-time trending detection while ensuring accuracy through batch validation and correction.

### Question 48
Calculate the required EMR cluster size for processing 10TB of data in 2 hours with the following constraints:
- Processing rate: 1GB per core per hour
- Instance type: r5.2xlarge (8 cores)
- Target utilization: 80%

Required processing power: 10TB ÷ 2 hours = 5TB/hour = 5,000 GB/hour
Cores needed: 5,000 GB/hour ÷ 1 GB/core/hour = 5,000 cores
Effective cores per instance: 8 × 0.8 = 6.4 cores
Instances needed: 5,000 ÷ 6.4 = 781.25 ≈ 782 instances

A) 625 instances
B) 782 instances
C) 1,000 instances
D) 1,250 instances

**Answer: B**
**Explanation**: 782 instances required to meet the 2-hour processing target with 80% utilization.

### Question 49
A gaming company needs to process player events for real-time leaderboards and anti-cheat detection. Which architecture provides the best balance of performance and cost?

A) Kinesis + Lambda + DynamoDB + ElastiCache
B) MSK + Kafka Streams + Cassandra + Redis
C) EventBridge + Step Functions + RDS + CloudFront
D) SQS + ECS + Aurora + CloudWatch

**Answer: A**
**Explanation**: This serverless architecture provides excellent performance for gaming workloads while optimizing costs through automatic scaling.

### Question 50
An analytics platform must support both SQL queries from business users and machine learning workloads from data scientists. Which data architecture is most appropriate?

A) Single data warehouse optimized for SQL
B) Separate systems for SQL and ML workloads
C) Data lake with multiple processing engines
D) NoSQL database with flexible schema

**Answer: C**
**Explanation**: Data lake architecture with multiple engines (Athena for SQL, EMR for ML) provides flexibility while maintaining a single source of truth.

## Answer Key Summary
1. B  2. B  3. B  4. D  5. C  6. B  7. B  8. B  9. B  10. B
11. B  12. C  13. D  14. C  15. C  16. B  17. B  18. B  19. C  20. B
21. B  22. C  23. B  24. D  25. D  26. A  27. C  28. A  29. B  30. B
31. C  32. B  33. D  34. B  35. A  36. B  37. B  38. C  39. C  40. B
41. D  42. C  43. A  44. D  45. B  46. B  47. C  48. B  49. A  50. C

## Scoring Guide
- **90-100% (45-50 correct)**: Expert level - Ready for senior roles
- **80-89% (40-44 correct)**: Advanced level - Strong practical knowledge
- **70-79% (35-39 correct)**: Intermediate level - Solid foundation
- **60-69% (30-34 correct)**: Beginner level - Needs additional study
- **Below 60% (<30 correct)**: Requires comprehensive review
