# Exercise 01: Stream Processing System Design

## Objective
Design and implement a real-time stream processing system for an e-commerce platform that processes user events, generates real-time metrics, and triggers personalized recommendations.

## Business Context

### E-commerce Platform Requirements
```yaml
Scale:
  - 10M daily active users
  - 100M page views per day
  - 5M product interactions per hour
  - 500K orders per day

Events to Process:
  - Page views and product clicks
  - Add to cart and purchase events
  - Search queries and results
  - User session data
  - Inventory updates

Real-time Requirements:
  - Recommendation updates: < 100ms
  - Fraud detection: < 500ms
  - Inventory alerts: < 1 second
  - Dashboard metrics: < 5 seconds
```

## Exercise Tasks

### Task 1: Architecture Design (30 minutes)
Design a stream processing architecture that handles the following requirements:

**Input Sources:**
- Web application events (JSON via HTTP)
- Mobile app events (JSON via HTTP)
- Database change streams (CDC)
- External partner feeds (CSV files)

**Processing Requirements:**
- Real-time aggregations (5-minute windows)
- User session reconstruction
- Anomaly detection for fraud
- Personalization feature extraction

**Output Destinations:**
- Real-time dashboard (sub-second updates)
- Recommendation engine (feature store)
- Data warehouse (for historical analysis)
- Alert system (for operational issues)

**Deliverables:**
1. High-level architecture diagram
2. Technology selection with justification
3. Data flow documentation
4. Scalability and fault tolerance strategy

### Task 2: Kinesis Implementation (45 minutes)
Implement the core streaming infrastructure using AWS Kinesis:

**Requirements:**
```yaml
Kinesis Data Streams:
  - Handle 10K events/second peak load
  - Ensure ordered processing per user
  - 7-day retention for reprocessing
  - Auto-scaling based on throughput

Kinesis Analytics:
  - 5-minute tumbling windows for metrics
  - Real-time fraud score calculation
  - Session timeout detection (30 minutes)
  - Top products and categories tracking
```

**Implementation Steps:**
1. Create Kinesis Data Stream with appropriate sharding
2. Implement producer application (Python/Java)
3. Create Kinesis Analytics application with SQL queries
4. Set up CloudWatch monitoring and alarms

**Sample Event Schema:**
```json
{
  "eventId": "uuid",
  "userId": "user123",
  "sessionId": "session456",
  "eventType": "page_view|add_to_cart|purchase|search",
  "timestamp": "2024-01-15T10:30:00Z",
  "productId": "prod789",
  "category": "electronics",
  "price": 299.99,
  "quantity": 1,
  "deviceType": "mobile|desktop",
  "location": {
    "country": "US",
    "region": "CA"
  }
}
```

### Task 3: Real-time Analytics Queries (30 minutes)
Write Kinesis Analytics SQL queries for the following metrics:

**Query 1: Real-time Revenue Tracking**
```sql
-- Calculate revenue per 5-minute window by category
-- Include order count and average order value
-- Filter out cancelled orders
```

**Query 2: User Session Analysis**
```sql
-- Reconstruct user sessions from events
-- Calculate session duration and page views
-- Identify session conversion events
-- Detect session timeouts (30 minutes of inactivity)
```

**Query 3: Fraud Detection Scoring**
```sql
-- Calculate fraud risk score based on:
-- - Multiple orders from same IP in short time
-- - High-value orders from new users
-- - Unusual geographic patterns
-- - Velocity of transactions
```

**Query 4: Real-time Inventory Alerts**
```sql
-- Monitor inventory levels in real-time
-- Alert when stock falls below threshold
-- Track fast-moving products
-- Calculate reorder recommendations
```

### Task 4: Lambda Processing Functions (45 minutes)
Implement Lambda functions for event processing:

**Function 1: Event Enrichment**
```python
# Enrich events with user profile data
# Add product metadata and pricing
# Implement caching for performance
# Handle missing data gracefully
```

**Function 2: Recommendation Feature Extraction**
```python
# Extract features for ML models:
# - User behavior patterns
# - Product affinity scores
# - Contextual features (time, device, location)
# - Social signals (trending products)
```

**Function 3: Real-time Alerting**
```python
# Process fraud detection results
# Send alerts for high-risk transactions
# Update user risk profiles
# Log security events
```

### Task 5: Performance Optimization (30 minutes)
Optimize the stream processing system for performance and cost:

**Optimization Areas:**
1. **Throughput Optimization**
   - Shard count calculation and auto-scaling
   - Batch size optimization for Lambda
   - Parallel processing strategies
   - Bottleneck identification and resolution

2. **Latency Optimization**
   - End-to-end latency measurement
   - Caching strategies for enrichment data
   - Query optimization for analytics
   - Network and serialization optimization

3. **Cost Optimization**
   - Right-sizing Kinesis shards
   - Lambda memory and timeout optimization
   - Data retention policy optimization
   - Reserved capacity planning

## Solution Guidelines

### Architecture Solution
```yaml
Recommended Architecture:
  Event Ingestion: API Gateway + Kinesis Data Streams
  Stream Processing: Kinesis Analytics + Lambda
  Feature Store: DynamoDB + ElastiCache
  Analytics: Kinesis Data Firehose + S3 + Athena
  Monitoring: CloudWatch + X-Ray
  
Sharding Strategy:
  Partition Key: userId (ensures ordered processing per user)
  Shard Count: Start with 10 shards (10MB/s, 10K records/s)
  Auto-scaling: CloudWatch metrics + Lambda function
  
Fault Tolerance:
  Multi-AZ deployment for all services
  Dead letter queues for failed processing
  Checkpointing for exactly-once processing
  Circuit breakers for external dependencies
```

### Performance Benchmarks
```yaml
Target Metrics:
  Event Ingestion: 10K events/second sustained
  Processing Latency: P95 < 500ms end-to-end
  Query Response: P95 < 2 seconds for analytics
  Availability: 99.9% uptime SLA
  
Cost Targets:
  Processing Cost: < $0.001 per event
  Storage Cost: < $0.10 per GB per month
  Total Monthly Cost: < $5,000 for baseline load
```

### Sample Implementation Code

**Kinesis Producer (Python):**
```python
import boto3
import json
import uuid
from datetime import datetime

class EventProducer:
    def __init__(self, stream_name):
        self.kinesis = boto3.client('kinesis')
        self.stream_name = stream_name
    
    def send_event(self, event_data):
        # Add metadata
        event_data['eventId'] = str(uuid.uuid4())
        event_data['timestamp'] = datetime.utcnow().isoformat()
        
        # Send to Kinesis
        response = self.kinesis.put_record(
            StreamName=self.stream_name,
            Data=json.dumps(event_data),
            PartitionKey=event_data['userId']
        )
        return response
```

**Lambda Event Processor:**
```python
import json
import boto3
from decimal import Decimal

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('user_features')
    
    for record in event['Records']:
        # Decode Kinesis data
        payload = json.loads(
            base64.b64decode(record['kinesis']['data']).decode('utf-8')
        )
        
        # Process event
        user_id = payload['userId']
        event_type = payload['eventType']
        
        # Update user features
        update_user_features(table, user_id, payload)
        
        # Generate recommendations if needed
        if event_type in ['purchase', 'add_to_cart']:
            trigger_recommendation_update(user_id)
    
    return {'statusCode': 200}
```

## Evaluation Criteria

### Technical Implementation (40%)
- Architecture design quality and scalability
- Proper use of AWS services and best practices
- Code quality and error handling
- Performance optimization techniques

### Business Requirements (30%)
- Meeting latency and throughput requirements
- Proper handling of business logic
- Data quality and consistency
- User experience considerations

### Operational Excellence (20%)
- Monitoring and alerting setup
- Fault tolerance and recovery
- Cost optimization strategies
- Documentation quality

### Innovation and Optimization (10%)
- Creative solutions to complex problems
- Advanced optimization techniques
- Use of cutting-edge technologies
- Scalability beyond current requirements

## Bonus Challenges

### Advanced Challenge 1: Multi-Region Deployment
Design and implement a multi-region stream processing system with:
- Cross-region replication for disaster recovery
- Global load balancing for event ingestion
- Consistent user experience across regions
- Cost-optimized data transfer strategies

### Advanced Challenge 2: Machine Learning Integration
Integrate real-time machine learning for:
- Dynamic fraud detection model updates
- Real-time recommendation model serving
- A/B testing framework for model experiments
- Feature drift detection and alerting

### Advanced Challenge 3: Complex Event Processing
Implement complex event processing for:
- Multi-step user journey tracking
- Correlation of events across different systems
- Pattern detection for business insights
- Temporal event relationships and causality

## Resources and References

### AWS Documentation
- [Kinesis Data Streams Developer Guide](https://docs.aws.amazon.com/kinesis/latest/dev/)
- [Kinesis Analytics SQL Reference](https://docs.aws.amazon.com/kinesisanalytics/latest/sqlref/)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

### Performance Optimization
- [Kinesis Scaling Guide](https://aws.amazon.com/kinesis/data-streams/faqs/)
- [Lambda Performance Tuning](https://docs.aws.amazon.com/lambda/latest/operatorguide/perf-optimize.html)
- [DynamoDB Performance Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)

### Monitoring and Observability
- [CloudWatch Metrics for Kinesis](https://docs.aws.amazon.com/kinesis/latest/dev/monitoring-with-cloudwatch.html)
- [X-Ray Tracing for Serverless](https://docs.aws.amazon.com/xray/latest/devguide/xray-services-lambda.html)
- [Custom Metrics and Dashboards](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html)
