# Stream Processing Design Patterns

## Event Sourcing Pattern
**Problem**: Need to capture all changes to application state as events
**Solution**: Store events as the source of truth, derive current state from events

```yaml
Implementation:
  Event Store: Kafka topics with infinite retention
  Event Schema: Immutable event records with metadata
  State Reconstruction: Replay events to rebuild current state
  Snapshots: Periodic state snapshots for performance

Use Cases:
  - Financial transaction processing
  - Audit trail requirements
  - Time travel queries
  - Debugging and replay scenarios

Benefits:
  - Complete audit trail
  - Temporal queries
  - Easy debugging and testing
  - Natural event-driven architecture

Challenges:
  - Storage overhead
  - Event schema evolution
  - Snapshot management
  - Query complexity
```

## CQRS (Command Query Responsibility Segregation)
**Problem**: Different requirements for read and write operations
**Solution**: Separate read and write models with eventual consistency

```yaml
Architecture:
  Command Side: Optimized for writes, event sourcing
  Query Side: Optimized for reads, materialized views
  Event Bus: Connects command and query sides
  Projections: Transform events into read models

Implementation:
  Commands: User actions that change state
  Events: Results of command processing
  Read Models: Denormalized views for queries
  Synchronization: Eventual consistency between sides

Benefits:
  - Independent scaling of reads/writes
  - Optimized data models for each use case
  - Better performance and scalability
  - Clear separation of concerns

Trade-offs:
  - Increased complexity
  - Eventual consistency
  - Data synchronization challenges
  - More infrastructure components
```

## Saga Pattern for Distributed Transactions
**Problem**: Need transactions across multiple microservices
**Solution**: Coordinate distributed transactions using compensating actions

```yaml
Choreography-Based Saga:
  - Each service publishes events after local transaction
  - Other services listen and react to events
  - No central coordinator
  - Compensating actions for rollback

Orchestration-Based Saga:
  - Central orchestrator manages transaction flow
  - Orchestrator sends commands to services
  - Handles compensation logic centrally
  - Better visibility and control

Implementation Example:
  Order Processing Saga:
    1. Create Order → OrderCreated event
    2. Reserve Inventory → InventoryReserved event
    3. Process Payment → PaymentProcessed event
    4. Ship Order → OrderShipped event
    
  Compensation Flow:
    - Payment fails → Release inventory reservation
    - Shipping fails → Refund payment, release inventory
```

## Windowing Patterns

### Tumbling Windows
```yaml
Definition: Fixed-size, non-overlapping time intervals
Use Cases: Periodic aggregations, regular reporting
Implementation:
  - Window size: 5 minutes, 1 hour, 1 day
  - Trigger: Time-based, automatic
  - State: Accumulate data within window
  - Output: Single result per window

Example: Hourly sales aggregation
  Window 1: [00:00-01:00) → Total sales: $10,000
  Window 2: [01:00-02:00) → Total sales: $8,500
  Window 3: [02:00-03:00) → Total sales: $12,300
```

### Sliding Windows
```yaml
Definition: Fixed-size, overlapping time intervals
Use Cases: Moving averages, trend analysis
Implementation:
  - Window size: 10 minutes
  - Slide interval: 1 minute
  - Overlap: 9 minutes between windows
  - State: Maintain data for full window duration

Example: 10-minute moving average of response time
  Window 1: [00:00-00:10) → Avg: 150ms
  Window 2: [00:01-00:11) → Avg: 145ms
  Window 3: [00:02-00:12) → Avg: 160ms
```

### Session Windows
```yaml
Definition: Variable-size windows based on activity gaps
Use Cases: User session analysis, device activity tracking
Implementation:
  - Gap timeout: 30 minutes of inactivity
  - Dynamic window size based on user behavior
  - State: Track last activity timestamp
  - Trigger: Gap timeout or explicit session end

Example: Web user session analysis
  User A: [Login 09:00 ... Activity 09:45] [Gap] [Activity 10:30 ... Logout 11:15]
          ←---- Session 1 (45 min) ----→        ←--- Session 2 (45 min) ---→
```

## State Management Patterns

### Keyed State Pattern
```yaml
Problem: Need to maintain state per key (user, device, etc.)
Solution: Partition state by key for parallel processing

Implementation:
  State Types:
    - ValueState: Single value per key
    - ListState: List of values per key
    - MapState: Key-value map per key
    - ReducingState: Aggregated value per key
  
  State Backend:
    - Memory: Fast but not durable
    - RocksDB: Durable and scalable
    - Custom: Application-specific storage

Example: User session state
  Key: user_id
  State: {
    session_start: timestamp,
    page_views: count,
    last_activity: timestamp,
    cart_items: list
  }
```

### Broadcast State Pattern
```yaml
Problem: Need to share configuration or rules across all parallel instances
Solution: Broadcast state to all operators

Use Cases:
  - Dynamic configuration updates
  - Rule engines and pattern matching
  - Feature flags and A/B test configurations
  - Reference data distribution

Implementation:
  Broadcast Stream: Configuration updates
  Main Stream: Data to be processed
  Processing: Join main stream with broadcast state
  Updates: Broadcast state updates to all instances

Example: Dynamic pricing rules
  Broadcast: Pricing rules and discounts
  Main Stream: Product view events
  Processing: Apply current pricing rules to each event
```

## Error Handling Patterns

### Dead Letter Queue Pattern
```yaml
Problem: Handle messages that cannot be processed successfully
Solution: Route failed messages to separate queue for analysis

Implementation:
  Primary Processing: Normal message processing
  Retry Logic: Exponential backoff with max attempts
  Dead Letter Queue: Failed messages after max retries
  Monitoring: Alert on DLQ message accumulation
  
  Recovery Options:
    - Manual inspection and reprocessing
    - Automated retry with fixes
    - Data correction and replay
    - Discard after analysis

Configuration:
  max_retries: 3
  retry_delay: [1s, 5s, 15s]
  dlq_retention: 7 days
  alert_threshold: 100 messages
```

### Circuit Breaker Pattern
```yaml
Problem: Prevent cascading failures in distributed systems
Solution: Monitor failures and temporarily stop calling failing services

States:
  Closed: Normal operation, requests pass through
  Open: Failure threshold exceeded, requests fail fast
  Half-Open: Test if service has recovered

Implementation:
  Failure Threshold: 50% error rate over 1 minute
  Timeout: 30 seconds in open state
  Success Threshold: 5 consecutive successes to close
  Fallback: Default response or cached data

Benefits:
  - Prevents resource exhaustion
  - Faster failure detection
  - Automatic recovery testing
  - System stability improvement
```

## Performance Optimization Patterns

### Backpressure Handling
```yaml
Problem: Downstream systems cannot keep up with upstream data rate
Solutions:

1. Rate Limiting:
   - Token bucket algorithm
   - Sliding window rate limiting
   - Adaptive rate adjustment
   
2. Buffering:
   - In-memory buffers with size limits
   - Persistent queues for durability
   - Overflow handling strategies
   
3. Load Shedding:
   - Drop low-priority messages
   - Sample data when overloaded
   - Prioritize critical events
   
4. Auto-Scaling:
   - Scale processing resources dynamically
   - Predictive scaling based on patterns
   - Cost-aware scaling policies

Implementation:
  Monitor: Queue depth, processing latency, error rates
  Trigger: Threshold-based or ML-based detection
  Action: Scale out, rate limit, or load shed
  Recovery: Gradual return to normal operation
```

### Caching Patterns
```yaml
Cache-Aside Pattern:
  Application: Manages cache explicitly
  Read: Check cache first, then database
  Write: Update database, invalidate cache
  Use Case: Read-heavy workloads with complex queries

Write-Through Pattern:
  Application: Writes to cache and database simultaneously
  Consistency: Strong consistency between cache and database
  Performance: Write latency includes cache update
  Use Case: Write-heavy workloads requiring consistency

Write-Behind Pattern:
  Application: Writes to cache immediately
  Background: Asynchronous write to database
  Performance: Low write latency
  Risk: Potential data loss if cache fails
  Use Case: High-throughput write workloads

Refresh-Ahead Pattern:
  Cache: Proactively refreshes data before expiration
  Prediction: Based on access patterns
  Performance: Eliminates cache miss latency
  Complexity: Requires access pattern analysis
  Use Case: Predictable access patterns
```

## Data Pipeline Patterns

### Lambda Architecture Pattern
```yaml
Components:
  Batch Layer: Historical data processing for accuracy
  Speed Layer: Real-time processing for low latency
  Serving Layer: Unified query interface

Data Flow:
  Raw Data → Batch Layer → Batch Views → Serving Layer
           → Speed Layer → Real-time Views → Serving Layer

Benefits:
  - Combines batch accuracy with real-time speed
  - Fault tolerant with immutable data
  - Handles both historical and real-time queries
  - Proven at scale (Netflix, LinkedIn)

Challenges:
  - Complexity of maintaining two systems
  - Data synchronization between layers
  - Higher operational overhead
  - Potential consistency issues
```

### Kappa Architecture Pattern
```yaml
Components:
  Stream Processing: Single processing layer for all data
  Serving Layer: Query interface for processed data
  Reprocessing: Historical data replay capability

Data Flow:
  Raw Data → Stream Processing → Serving Layer
           → Reprocessing (when needed) → Serving Layer

Benefits:
  - Simpler architecture with single processing model
  - Consistent processing logic for all data
  - Lower operational complexity
  - Better for real-time focused systems

Challenges:
  - Stream processor must handle all use cases
  - Reprocessing can be resource intensive
  - May not suit complex batch analytics
  - Requires mature streaming infrastructure
```

## Monitoring and Observability Patterns

### Three Pillars of Observability
```yaml
Metrics:
  - Quantitative measurements over time
  - Aggregated data for trends and alerting
  - Examples: Throughput, latency, error rates
  - Tools: Prometheus, CloudWatch, InfluxDB

Logs:
  - Discrete events with context
  - Detailed information for debugging
  - Structured logging for analysis
  - Tools: ELK stack, Splunk, CloudWatch Logs

Traces:
  - Request flow through distributed system
  - End-to-end latency breakdown
  - Dependency mapping and bottleneck identification
  - Tools: Jaeger, Zipkin, AWS X-Ray

Integration:
  - Correlation IDs across all three pillars
  - Unified dashboards and alerting
  - Automated anomaly detection
  - Root cause analysis workflows
```

### Health Check Patterns
```yaml
Shallow Health Check:
  - Basic service availability
  - Fast response (<100ms)
  - Minimal resource usage
  - Used by load balancers

Deep Health Check:
  - Full dependency validation
  - Database connectivity
  - External service availability
  - Used for detailed monitoring

Startup/Readiness Probes:
  - Kubernetes-style health checks
  - Startup: Service initialization complete
  - Readiness: Ready to handle traffic
  - Liveness: Service is healthy and responsive

Implementation:
  GET /health/shallow → 200 OK (service up)
  GET /health/deep → 200 OK (all dependencies healthy)
  GET /health/ready → 200 OK (ready for traffic)
```
