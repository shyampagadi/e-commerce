# Exercise 05: Circuit Breaker and Resilience Patterns

## Overview
Design and implement comprehensive resilience patterns for a distributed messaging system, including circuit breakers, bulkheads, timeouts, and graceful degradation strategies.

## Learning Objectives
- Implement circuit breaker patterns for messaging systems
- Design bulkhead isolation for fault tolerance
- Create graceful degradation strategies
- Build comprehensive monitoring and alerting
- Test system resilience under various failure conditions

## Scenario
You're building a critical payment processing system that handles 50,000+ transactions per minute. The system must maintain 99.99% availability even when downstream services fail. Implement resilience patterns to ensure the system degrades gracefully under various failure conditions.

## System Requirements

### Functional Requirements
- Process payment transactions with multiple payment providers
- Handle inventory checks with external inventory service
- Send notifications via multiple channels (email, SMS, push)
- Generate real-time fraud detection scores
- Maintain audit logs for all transactions

### Non-Functional Requirements
- **Availability**: 99.99% uptime (52 minutes downtime/year)
- **Throughput**: 50,000 transactions/minute sustained
- **Latency**: <200ms P95 for payment processing
- **Recovery Time**: <30 seconds for service recovery
- **Data Consistency**: Strong consistency for payments, eventual for notifications

## Architecture Requirements

### System Components
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Payment API   │───▶│  Circuit Breaker │───▶│ Payment Provider│
│   Gateway       │    │     Layer        │    │   Services      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Bulkhead      │    │   Timeout        │    │   Fallback      │
│   Isolation     │    │   Management     │    │   Services      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Tasks

### Task 1: Circuit Breaker Implementation (2 hours)
Implement a sophisticated circuit breaker with multiple states and configurable thresholds.

**Requirements**:
- Three states: CLOSED, OPEN, HALF_OPEN
- Configurable failure thresholds and timeouts
- Exponential backoff for recovery attempts
- Metrics collection and monitoring
- Thread-safe implementation

**Deliverables**:
- Circuit breaker class with state management
- Configuration system for thresholds
- Metrics collection integration
- Unit tests with failure scenarios

### Task 2: Bulkhead Pattern Implementation (2 hours)
Implement bulkhead isolation to prevent cascade failures between system components.

**Requirements**:
- Separate thread pools for different service types
- Resource isolation (CPU, memory, connections)
- Independent failure domains
- Resource monitoring and alerting
- Dynamic resource allocation

**Deliverables**:
- Bulkhead isolation framework
- Resource pool management
- Monitoring dashboard
- Load testing results

### Task 3: Timeout and Retry Strategy (1.5 hours)
Implement comprehensive timeout and retry mechanisms with exponential backoff.

**Requirements**:
- Configurable timeout values per service
- Exponential backoff with jitter
- Maximum retry limits
- Dead letter queue for failed messages
- Retry metrics and monitoring

**Deliverables**:
- Timeout management system
- Retry policy configuration
- Dead letter queue implementation
- Performance analysis

### Task 4: Graceful Degradation (2 hours)
Design graceful degradation strategies for various failure scenarios.

**Requirements**:
- Fallback payment providers
- Cached responses for read operations
- Simplified processing modes
- User experience preservation
- Automatic recovery detection

**Deliverables**:
- Degradation strategy framework
- Fallback service implementations
- Cache management system
- Recovery automation

### Task 5: Chaos Engineering Tests (1.5 hours)
Implement chaos engineering tests to validate system resilience.

**Requirements**:
- Service failure injection
- Network partition simulation
- Resource exhaustion tests
- Latency injection
- Recovery validation

**Deliverables**:
- Chaos testing framework
- Failure scenario scripts
- Recovery time measurements
- Resilience report

## Implementation Guidelines

### Circuit Breaker States
```python
from enum import Enum
from dataclasses import dataclass
from typing import Callable, Any
import time
import threading

class CircuitState(Enum):
    CLOSED = "CLOSED"
    OPEN = "OPEN"
    HALF_OPEN = "HALF_OPEN"

@dataclass
class CircuitBreakerConfig:
    failure_threshold: int = 5
    recovery_timeout: int = 60
    success_threshold: int = 3
    timeout: float = 30.0
    expected_exception: type = Exception

class CircuitBreaker:
    def __init__(self, config: CircuitBreakerConfig):
        self.config = config
        self.state = CircuitState.CLOSED
        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.lock = threading.RLock()
        
    def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker protection"""
        with self.lock:
            if self.state == CircuitState.OPEN:
                if self._should_attempt_reset():
                    self.state = CircuitState.HALF_OPEN
                    self.success_count = 0
                else:
                    raise CircuitBreakerOpenException("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                self._on_success()
                return result
            except self.config.expected_exception as e:
                self._on_failure()
                raise e
    
    def _should_attempt_reset(self) -> bool:
        """Check if circuit breaker should attempt reset"""
        return (time.time() - self.last_failure_time) >= self.config.recovery_timeout
    
    def _on_success(self):
        """Handle successful call"""
        if self.state == CircuitState.HALF_OPEN:
            self.success_count += 1
            if self.success_count >= self.config.success_threshold:
                self.state = CircuitState.CLOSED
                self.failure_count = 0
        elif self.state == CircuitState.CLOSED:
            self.failure_count = 0
    
    def _on_failure(self):
        """Handle failed call"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.config.failure_threshold:
            self.state = CircuitState.OPEN

class CircuitBreakerOpenException(Exception):
    pass
```

### Bulkhead Pattern
```python
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, Any
import queue

class BulkheadManager:
    def __init__(self):
        self.thread_pools: Dict[str, ThreadPoolExecutor] = {}
        self.resource_limits: Dict[str, Dict[str, int]] = {}
        
    def create_bulkhead(self, name: str, max_workers: int, 
                       queue_size: int = 1000):
        """Create isolated bulkhead for service"""
        self.thread_pools[name] = ThreadPoolExecutor(
            max_workers=max_workers,
            thread_name_prefix=f"bulkhead-{name}"
        )
        
        self.resource_limits[name] = {
            'max_workers': max_workers,
            'queue_size': queue_size,
            'active_tasks': 0
        }
    
    def submit_task(self, bulkhead_name: str, func: Callable, 
                   *args, **kwargs):
        """Submit task to specific bulkhead"""
        if bulkhead_name not in self.thread_pools:
            raise ValueError(f"Bulkhead {bulkhead_name} not found")
        
        pool = self.thread_pools[bulkhead_name]
        
        try:
            future = pool.submit(func, *args, **kwargs)
            self.resource_limits[bulkhead_name]['active_tasks'] += 1
            return future
        except Exception as e:
            raise BulkheadOverloadException(f"Bulkhead {bulkhead_name} overloaded")

class BulkheadOverloadException(Exception):
    pass
```

## Success Criteria

### Functional Success
- [ ] Circuit breaker correctly transitions between all states
- [ ] Bulkhead isolation prevents cascade failures
- [ ] Timeout and retry mechanisms work under load
- [ ] Graceful degradation maintains user experience
- [ ] Chaos tests validate system resilience

### Performance Success
- [ ] System maintains 99.9%+ availability during failures
- [ ] Recovery time <30 seconds for all failure scenarios
- [ ] Throughput degradation <20% during partial failures
- [ ] Latency increase <50% during degraded mode
- [ ] Zero data loss during failure scenarios

### Operational Success
- [ ] Comprehensive monitoring and alerting
- [ ] Automated recovery mechanisms
- [ ] Clear operational runbooks
- [ ] Effective chaos engineering test suite
- [ ] Performance baselines established

## Evaluation Criteria

### Implementation Quality (40%)
- Code quality and architecture
- Error handling and edge cases
- Thread safety and concurrency
- Configuration management
- Testing coverage

### Resilience Design (30%)
- Failure scenario coverage
- Recovery mechanisms
- Graceful degradation
- Monitoring and observability
- Operational procedures

### Performance (20%)
- Throughput under load
- Latency characteristics
- Resource utilization
- Scalability demonstration
- Chaos test results

### Documentation (10%)
- Architecture documentation
- Configuration guides
- Operational runbooks
- Performance analysis
- Lessons learned

## Bonus Challenges

### Advanced Resilience Patterns
- Implement adaptive circuit breakers with machine learning
- Create self-healing systems with automatic recovery
- Design multi-region failover strategies
- Build predictive failure detection

### Performance Optimization
- Achieve 99.99% availability under chaos testing
- Minimize recovery time to <10 seconds
- Maintain <5% performance degradation during failures
- Implement zero-downtime deployments

This exercise provides hands-on experience with critical resilience patterns essential for building production-grade distributed systems.
