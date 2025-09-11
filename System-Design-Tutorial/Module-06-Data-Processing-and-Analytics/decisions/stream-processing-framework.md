# ADR-003: Stream Processing Framework Selection

## Status
Accepted

## Context
Need to select optimal stream processing framework for real-time data processing, supporting high throughput, low latency, and exactly-once processing guarantees.

## Decision
**Primary**: Amazon Kinesis Data Streams + Kinesis Analytics
**Secondary**: Apache Kafka + Kafka Streams (for hybrid/multi-cloud)

## Comparison Matrix

| Criteria | Kinesis | Kafka | Pulsar | Flink |
|----------|---------|-------|--------|-------|
| **Throughput** | 1MB/s per shard | 100MB/s+ | 100MB/s+ | Unlimited |
| **Latency** | <200ms | <10ms | <5ms | <1ms |
| **Exactly-once** | ✅ | ✅ | ✅ | ✅ |
| **AWS Integration** | Native | Manual | Manual | EMR only |
| **Operational Overhead** | Low | High | Medium | High |
| **Cost (1TB/day)** | $876/month | $200/month* | $300/month* | $400/month* |

*Self-managed on EC2

## Rationale

### Kinesis Advantages
```yaml
Native AWS Integration:
  - Seamless IAM integration
  - CloudWatch monitoring
  - Auto-scaling capabilities
  - Managed service (no ops overhead)

Performance Characteristics:
  - Guaranteed ordering per partition key
  - Automatic data retention (1-365 days)
  - Built-in encryption at rest/transit
  - Multi-AZ durability

Developer Experience:
  - Kinesis Client Library (KCL)
  - Native Lambda integration
  - SQL-based stream processing
  - Real-time dashboards
```

### Use Case Mapping
```yaml
Real-time Analytics:
  - Kinesis Data Streams → Kinesis Analytics
  - SQL transformations for business metrics
  - Real-time dashboards via QuickSight

Event Processing:
  - Kinesis → Lambda functions
  - Serverless event-driven architecture
  - Automatic scaling based on throughput

Data Pipeline:
  - Kinesis → Kinesis Firehose → S3/Redshift
  - Automatic format conversion (JSON → Parquet)
  - Compression and partitioning
```

## Architecture Decision

### Primary Architecture (AWS-Native)
```
Data Sources → Kinesis Data Streams → Kinesis Analytics → Outputs
                     ↓
               Kinesis Firehose → S3 → Athena/Redshift
```

### Hybrid Architecture (Multi-Cloud Ready)
```
Data Sources → Kafka → Kafka Streams → Multiple Sinks
                 ↓
            Kafka Connect → Various Destinations
```

## Implementation Strategy

### Phase 1: Kinesis Foundation
```yaml
Kinesis Data Streams:
  - Start with 10 shards (10MB/s capacity)
  - Enable server-side encryption
  - 7-day retention for reprocessing
  - CloudWatch monitoring enabled

Kinesis Analytics:
  - SQL-based stream processing
  - Tumbling windows for aggregations
  - Reference data from S3
  - Output to multiple destinations
```

### Phase 2: Advanced Processing
```yaml
Kinesis Firehose:
  - Buffer size: 128MB or 60 seconds
  - Compression: GZIP for S3
  - Format conversion: JSON to Parquet
  - Error record handling to separate bucket

Lambda Integration:
  - Event-driven processing
  - Parallel execution per shard
  - Dead letter queues for failures
  - Custom metrics and alarms
```

### Phase 3: Optimization
```yaml
Performance Tuning:
  - Shard-level metrics monitoring
  - Auto-scaling based on utilization
  - Partition key optimization
  - Consumer lag monitoring

Cost Optimization:
  - Right-sizing shard count
  - Data retention optimization
  - Reserved capacity where applicable
  - Cross-region replication strategy
```

## Consequences

### Positive
- Fully managed service reduces operational overhead
- Native AWS integration simplifies architecture
- Built-in monitoring and alerting
- Automatic scaling capabilities
- Strong consistency and durability guarantees

### Negative
- Higher cost compared to self-managed solutions
- AWS vendor lock-in
- Limited customization options
- Shard-based scaling model complexity

## Monitoring and Alerting

### Key Metrics
```yaml
Throughput Metrics:
  - IncomingRecords per shard
  - OutgoingRecords per consumer
  - WriteProvisionedThroughputExceeded
  - ReadProvisionedThroughputExceeded

Latency Metrics:
  - End-to-end processing latency
  - Consumer lag per shard
  - GetRecords latency
  - PutRecord success rate

Error Metrics:
  - Failed record processing
  - Consumer application errors
  - Shard iterator age
  - Throttling events
```

### Alerting Thresholds
```yaml
Critical:
  - Consumer lag > 1 minute
  - Error rate > 1%
  - Shard utilization > 80%

Warning:
  - Consumer lag > 30 seconds
  - Error rate > 0.1%
  - Shard utilization > 60%
```
