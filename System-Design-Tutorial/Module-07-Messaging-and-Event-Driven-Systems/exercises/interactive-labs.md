# Interactive Labs - Module 07

## Lab 1: Event-Driven Architecture Simulator
**Duration**: 60 minutes | **Difficulty**: Intermediate

### Setup
```bash
# Clone the event-driven simulator
git clone https://github.com/system-design-tutorial/event-simulator.git
cd event-simulator
docker-compose up -d

# Access simulator dashboard
open http://localhost:8080/simulator
```

### Exercise Steps

#### Part A: Message Ordering Simulation (20 min)
1. **Configure Producer**: Set up 3 producers sending to same topic
2. **Partition Strategy**: Test different partitioning strategies
3. **Observe Ordering**: Monitor message order in different partitions
4. **Failure Simulation**: Introduce producer failures and observe impact

```python
# Interactive Code Block - Students modify and run
def test_message_ordering():
    producers = [
        create_producer(partition_strategy='round_robin'),
        create_producer(partition_strategy='key_hash'),
        create_producer(partition_strategy='sticky')
    ]
    
    # Send 1000 messages and measure ordering
    for i in range(1000):
        message = create_test_message(i)
        producer = producers[i % 3]
        producer.send(message)
    
    # Analyze results
    analyze_message_order()
```

#### Part B: Delivery Guarantees Testing (25 min)
1. **At-Most-Once**: Configure and test message loss scenarios
2. **At-Least-Once**: Test duplicate message handling
3. **Exactly-Once**: Implement idempotency patterns
4. **Performance Impact**: Measure latency vs reliability trade-offs

#### Part C: Event Sourcing Patterns (15 min)
1. **Event Store**: Create events and rebuild aggregate state
2. **Snapshots**: Implement snapshot optimization
3. **Temporal Queries**: Query system state at specific points in time

### Expected Outcomes
- Understand message ordering guarantees in distributed systems
- Experience trade-offs between consistency and performance
- Implement idempotency patterns for exactly-once processing

### Success Criteria
- [ ] Achieve correct message ordering in 95%+ of test scenarios
- [ ] Implement working idempotency mechanism
- [ ] Demonstrate temporal query capability

## Lab 2: Kafka Performance Tuning Workshop
**Duration**: 75 minutes | **Difficulty**: Advanced

### Setup
```bash
# Deploy Kafka cluster with monitoring
cd kafka-performance-lab
./setup-cluster.sh --brokers 3 --monitoring enabled

# Install performance testing tools
pip install kafka-python confluent-kafka prometheus-client
```

### Exercise Steps

#### Part A: Baseline Performance Testing (25 min)
1. **Producer Benchmarking**: Test default configuration throughput
2. **Consumer Benchmarking**: Measure consumption rates
3. **Latency Measurement**: Record end-to-end message latency
4. **Resource Monitoring**: Track CPU, memory, and network usage

```bash
# Performance test commands
kafka-producer-perf-test.sh \
  --topic performance-test \
  --num-records 1000000 \
  --record-size 1024 \
  --throughput 50000 \
  --producer-props bootstrap.servers=localhost:9092

# Monitor results in real-time
watch -n 1 'kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group perf-test'
```

#### Part B: Configuration Optimization (30 min)
1. **Producer Tuning**: Optimize batch size, linger time, compression
2. **Broker Tuning**: Adjust log segment size, flush intervals
3. **Consumer Tuning**: Optimize fetch size, session timeouts
4. **Network Optimization**: Configure buffer sizes and TCP settings

```python
# Interactive tuning exercise
def optimize_producer_config():
    configs = {
        'batch.size': [16384, 32768, 65536],
        'linger.ms': [0, 5, 10, 20],
        'compression.type': ['none', 'gzip', 'snappy', 'lz4']
    }
    
    best_config = {}
    best_throughput = 0
    
    for batch_size in configs['batch.size']:
        for linger_ms in configs['linger.ms']:
            for compression in configs['compression.type']:
                throughput = test_configuration(batch_size, linger_ms, compression)
                if throughput > best_throughput:
                    best_throughput = throughput
                    best_config = {
                        'batch.size': batch_size,
                        'linger.ms': linger_ms,
                        'compression.type': compression
                    }
    
    return best_config, best_throughput
```

#### Part C: Scaling and Partitioning (20 min)
1. **Partition Strategy**: Test different partition counts
2. **Consumer Groups**: Scale consumers and measure impact
3. **Replication Factor**: Balance durability vs performance
4. **Cross-AZ Performance**: Test multi-availability zone setup

### Performance Targets
- **Throughput**: Achieve 100K+ messages/second
- **Latency**: P95 < 50ms end-to-end
- **Resource Efficiency**: <70% CPU utilization at peak load

### Success Criteria
- [ ] Achieve target throughput with optimized configuration
- [ ] Demonstrate 3x performance improvement over baseline
- [ ] Successfully scale to handle traffic spikes

## Lab 3: Event Sourcing Implementation Lab
**Duration**: 90 minutes | **Difficulty**: Advanced

### Setup
```bash
# Clone event sourcing framework
git clone https://github.com/system-design-tutorial/event-sourcing-lab.git
cd event-sourcing-lab

# Start infrastructure
docker-compose up -d dynamodb elasticsearch redis

# Install dependencies
pip install boto3 elasticsearch redis pydantic
```

### Exercise Steps

#### Part A: Event Store Implementation (35 min)
1. **Design Event Schema**: Create Avro schemas for domain events
2. **Implement Event Store**: Build DynamoDB-based event storage
3. **Aggregate Root**: Create order aggregate with event sourcing
4. **Concurrency Control**: Implement optimistic locking

```python
# Interactive implementation exercise
class EventStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('event-store')
    
    def append_events(self, aggregate_id: str, expected_version: int, events: List[Event]):
        """
        Students implement this method with:
        - Optimistic concurrency control
        - Atomic batch writes
        - Event ordering guarantees
        """
        # TODO: Implement event appending logic
        pass
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[Event]:
        """
        Students implement event retrieval with:
        - Efficient pagination
        - Version filtering
        - Snapshot optimization
        """
        # TODO: Implement event retrieval logic
        pass

# Test your implementation
def test_event_store():
    store = EventStore()
    
    # Create test events
    events = [
        OrderCreated(order_id="123", customer_id="456"),
        ItemAdded(order_id="123", item_id="789", quantity=2),
        OrderConfirmed(order_id="123", total_amount=99.99)
    ]
    
    # Test concurrent writes
    store.append_events("order-123", 0, events)
    
    # Verify event retrieval
    retrieved_events = store.get_events("order-123")
    assert len(retrieved_events) == 3
```

#### Part B: CQRS Read Models (30 min)
1. **Event Projections**: Build read models from events
2. **Materialized Views**: Create optimized query structures
3. **Real-time Updates**: Implement event-driven view updates
4. **Query Optimization**: Index and cache frequently accessed data

#### Part C: Temporal Queries and Recovery (25 min)
1. **Point-in-Time Queries**: Query system state at any timestamp
2. **Event Replay**: Rebuild aggregates from historical events
3. **Snapshot Creation**: Optimize replay with periodic snapshots
4. **Schema Evolution**: Handle event schema changes over time

```python
# Temporal query implementation
class TemporalQueryService:
    def get_order_state_at_time(self, order_id: str, timestamp: datetime) -> OrderState:
        """
        Students implement temporal queries:
        - Filter events by timestamp
        - Replay events to rebuild state
        - Handle missing events gracefully
        """
        events = self.event_store.get_events_until(order_id, timestamp)
        
        order = Order()
        for event in events:
            order.apply_event(event)
        
        return order.get_state()
```

### Success Criteria
- [ ] Implement working event store with concurrency control
- [ ] Create real-time read models with <1 second update lag
- [ ] Demonstrate temporal queries across 1-year event history
- [ ] Handle 10K+ events/second write throughput

## Lab 4: Circuit Breaker and Resilience Testing
**Duration**: 45 minutes | **Difficulty**: Intermediate

### Setup
```bash
# Deploy microservices test environment
cd resilience-lab
./deploy-services.sh --chaos-enabled

# Install chaos engineering tools
pip install chaostoolkit locust
```

### Exercise Steps

#### Part A: Circuit Breaker Implementation (20 min)
1. **Basic Circuit Breaker**: Implement three-state circuit breaker
2. **Failure Detection**: Configure failure thresholds and timeouts
3. **Recovery Testing**: Test automatic recovery mechanisms
4. **Fallback Strategies**: Implement graceful degradation

```python
# Interactive circuit breaker implementation
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func, *args, **kwargs):
        """
        Students implement circuit breaker logic:
        - State management (CLOSED/OPEN/HALF_OPEN)
        - Failure counting and thresholds
        - Recovery timeout handling
        - Fallback execution
        """
        if self.state == 'OPEN':
            if self._should_attempt_reset():
                self.state = 'HALF_OPEN'
            else:
                return self._fallback()
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e
    
    def _should_attempt_reset(self):
        # TODO: Implement reset logic
        pass
    
    def _on_success(self):
        # TODO: Handle successful calls
        pass
    
    def _on_failure(self):
        # TODO: Handle failed calls
        pass
    
    def _fallback(self):
        # TODO: Implement fallback response
        pass
```

#### Part B: Chaos Engineering (15 min)
1. **Service Failure**: Simulate downstream service failures
2. **Network Partitions**: Test behavior during network splits
3. **Resource Exhaustion**: Simulate memory and CPU pressure
4. **Latency Injection**: Add artificial delays to test timeouts

#### Part C: Monitoring and Alerting (10 min)
1. **Circuit Breaker Metrics**: Track state changes and failure rates
2. **System Health Dashboard**: Visualize service dependencies
3. **Automated Alerts**: Configure alerts for circuit breaker trips
4. **Recovery Verification**: Validate system recovery after failures

### Chaos Experiments
```yaml
# Chaos experiment configuration
version: 1.0.0
title: "Message Service Resilience Test"
description: "Test circuit breaker behavior under various failure conditions"

steady-state-hypothesis:
  title: "System processes messages successfully"
  probes:
    - name: "message-processing-rate"
      type: "probe"
      tolerance: ">= 1000"  # messages per second

method:
  - type: "action"
    name: "simulate-downstream-failure"
    provider:
      type: "process"
      path: "chaos-toolkit"
      arguments: ["kill-service", "--name", "payment-service"]
  
  - type: "probe"
    name: "verify-circuit-breaker-open"
    tolerance: "circuit_breaker_state == 'OPEN'"
```

### Success Criteria
- [ ] Circuit breaker correctly transitions between states
- [ ] System maintains 80%+ availability during failures
- [ ] Recovery time < 60 seconds after failure resolution
- [ ] Fallback responses provide acceptable user experience

## 🎯 Lab Completion Tracking

### Progress Dashboard
Students can track their progress through an interactive dashboard showing:
- Lab completion status
- Performance benchmarks achieved
- Code quality scores
- Peer review ratings

### Certification Requirements
To earn the Module 07 Interactive Labs Certificate:
- [ ] Complete all 4 labs with passing scores
- [ ] Achieve performance targets in Labs 2 and 3
- [ ] Submit working code implementations
- [ ] Participate in peer code reviews
- [ ] Present one lab solution to the class

### Advanced Challenges
For students seeking additional challenges:
- **Performance Optimization**: Achieve 500K+ msg/sec in Kafka lab
- **Resilience Engineering**: Design system surviving 99% service failures
- **Event Sourcing Mastery**: Implement complex temporal business rules
- **Innovation Project**: Create novel messaging pattern or optimization
