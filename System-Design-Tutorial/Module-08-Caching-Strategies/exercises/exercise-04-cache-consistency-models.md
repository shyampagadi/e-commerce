# Exercise 4: Cache Consistency Models

## Overview

**Duration**: 4-5 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1-3 completion, understanding of distributed systems

## Learning Objectives

By completing this exercise, you will:
- Implement different cache consistency models in distributed systems
- Design cache coherence protocols for multi-level caching
- Handle cache invalidation in complex distributed scenarios
- Optimize consistency vs. performance trade-offs

## Scenario

You are designing a distributed caching system for a financial trading platform with strict consistency requirements:

### System Requirements
- **Data Types**: Market data, user portfolios, trade orders, account balances
- **Consistency Requirements**: Strong consistency for financial data
- **Performance Requirements**: Sub-millisecond latency for critical operations
- **Scale**: 1M+ concurrent users, 10M+ operations per second
- **Geographic Distribution**: 5 data centers across different continents

### Data Consistency Levels
- **Critical Data**: Account balances, trade orders (Strong consistency)
- **Important Data**: Market data, portfolio positions (Eventual consistency)
- **Cacheable Data**: User preferences, historical data (Weak consistency)

### Cache Hierarchy
- **L1 Cache**: Application-level cache (Redis)
- **L2 Cache**: Regional cache (ElastiCache)
- **L3 Cache**: Global cache (CloudFront)
- **Database**: Primary data store (RDS/Aurora)

## Exercise Tasks

### Task 1: Strong Consistency Implementation (90 minutes)

Implement strong consistency for critical financial data:

1. **Cache Coherence Protocol**
   - Implement write-through caching with immediate invalidation
   - Design cache locking mechanisms for concurrent access
   - Create transaction-aware cache operations
   - Implement cache versioning for conflict resolution

2. **Distributed Locking**
   - Implement distributed locks using Redis
   - Create lock timeout and renewal mechanisms
   - Design deadlock detection and resolution
   - Implement lock escalation strategies

**Implementation Requirements**:
```python
class StrongConsistencyCache:
    def __init__(self, redis_client, db_client):
        self.redis = redis_client
        self.db = db_client
        self.lock_timeout = 30
        self.lock_renewal_interval = 10
    
    def get_with_strong_consistency(self, key, lock_key=None):
        """Get value with strong consistency guarantee"""
        pass
    
    def set_with_strong_consistency(self, key, value, lock_key=None):
        """Set value with strong consistency guarantee"""
        pass
    
    def acquire_lock(self, lock_key, timeout=None):
        """Acquire distributed lock"""
        pass
    
    def release_lock(self, lock_key):
        """Release distributed lock"""
        pass
    
    def renew_lock(self, lock_key):
        """Renew lock to prevent timeout"""
        pass
```

### Task 2: Eventual Consistency Implementation (75 minutes)

Implement eventual consistency for market data and portfolio information:

1. **Event-Driven Invalidation**
   - Implement event-based cache invalidation
   - Design conflict-free replicated data types (CRDTs)
   - Create vector clocks for ordering events
   - Implement gossip protocols for propagation

2. **Consistency Windows**
   - Design time-based consistency windows
   - Implement eventual consistency guarantees
   - Create consistency monitoring and alerting
   - Design rollback mechanisms for conflicts

**Implementation Requirements**:
```python
class EventualConsistencyCache:
    def __init__(self, redis_client, event_bus):
        self.redis = redis_client
        self.event_bus = event_bus
        self.vector_clock = {}
        self.consistency_window = 5  # seconds
    
    def get_with_eventual_consistency(self, key, max_age=None):
        """Get value with eventual consistency"""
        pass
    
    def set_with_eventual_consistency(self, key, value, version=None):
        """Set value with eventual consistency"""
        pass
    
    def propagate_update(self, key, value, version):
        """Propagate update to other caches"""
        pass
    
    def resolve_conflict(self, key, versions):
        """Resolve conflict between versions"""
        pass
```

### Task 3: Cache Coherence Protocols (90 minutes)

Implement cache coherence protocols for multi-level caching:

1. **MESI Protocol Implementation**
   - Implement Modified, Exclusive, Shared, Invalid states
   - Design state transition logic
   - Create coherence message handling
   - Implement cache line invalidation

2. **Write-Back vs Write-Through**
   - Implement write-back caching with dirty bit tracking
   - Design write-through caching with immediate updates
   - Create hybrid write strategies
   - Implement write buffer management

**Implementation Requirements**:
```python
class CacheCoherenceManager:
    def __init__(self, cache_levels):
        self.cache_levels = cache_levels
        self.coherence_protocol = 'MESI'
        self.state_tracker = {}
        self.message_queue = queue.Queue()
    
    def read_request(self, key, cache_level):
        """Handle read request with coherence protocol"""
        pass
    
    def write_request(self, key, value, cache_level):
        """Handle write request with coherence protocol"""
        pass
    
    def invalidate_request(self, key, cache_level):
        """Handle invalidation request"""
        pass
    
    def update_state(self, key, cache_level, new_state):
        """Update cache line state"""
        pass
    
    def send_coherence_message(self, message):
        """Send coherence protocol message"""
        pass
```

### Task 4: Consistency Monitoring and Testing (60 minutes)

Implement comprehensive consistency monitoring and testing:

1. **Consistency Testing**
   - Create consistency test suites
   - Implement race condition testing
   - Design stress testing for consistency
   - Create automated consistency validation

2. **Monitoring and Alerting**
   - Implement consistency metrics collection
   - Create consistency violation detection
   - Design alerting for consistency issues
   - Implement consistency reporting

**Implementation Requirements**:
```python
class ConsistencyMonitor:
    def __init__(self, cache_system):
        self.cache_system = cache_system
        self.metrics_collector = MetricsCollector()
        self.alert_manager = AlertManager()
        self.test_suite = ConsistencyTestSuite()
    
    def run_consistency_tests(self):
        """Run comprehensive consistency tests"""
        pass
    
    def monitor_consistency_metrics(self):
        """Monitor consistency metrics in real-time"""
        pass
    
    def detect_consistency_violations(self):
        """Detect and report consistency violations"""
        pass
    
    def generate_consistency_report(self):
        """Generate detailed consistency report"""
        pass
    
    def setup_consistency_alerts(self):
        """Setup alerts for consistency issues"""
        pass
```

## Performance Targets

### Consistency Targets
- **Strong Consistency**: 100% consistency for critical data
- **Eventual Consistency**: < 5 second convergence time
- **Weak Consistency**: < 1 second for non-critical data
- **Consistency Violations**: < 0.001% of operations

### Latency Targets
- **Strong Consistency Operations**: < 10ms
- **Eventual Consistency Operations**: < 5ms
- **Cache Coherence Messages**: < 1ms
- **Lock Acquisition**: < 2ms

### Throughput Targets
- **Read Operations**: 1M+ ops/sec
- **Write Operations**: 100K+ ops/sec
- **Coherence Messages**: 10M+ messages/sec
- **Lock Operations**: 1M+ ops/sec

## Evaluation Criteria

### Technical Implementation (40%)
- **Consistency Models**: Proper implementation of consistency models
- **Coherence Protocols**: Effective cache coherence protocols
- **Locking Mechanisms**: Robust distributed locking
- **Event Handling**: Proper event-driven invalidation

### Performance Achievement (30%)
- **Consistency**: Meets consistency requirements
- **Latency**: Achieves latency targets
- **Throughput**: Handles required throughput
- **Scalability**: Scales with system growth

### Testing and Monitoring (20%)
- **Test Coverage**: Comprehensive test coverage
- **Monitoring**: Effective monitoring and alerting
- **Validation**: Proper consistency validation
- **Reporting**: Detailed consistency reporting

### Documentation (10%)
- **Architecture Documentation**: Clear consistency architecture
- **Protocol Documentation**: Detailed protocol specifications
- **Testing Documentation**: Comprehensive testing procedures
- **Monitoring Documentation**: Clear monitoring setup

## Sample Implementation

### Strong Consistency Cache

```python
class StrongConsistencyCache:
    def __init__(self, redis_client, db_client):
        self.redis = redis_client
        self.db = db_client
        self.lock_timeout = 30
        self.lock_renewal_interval = 10
        self.active_locks = {}
        self.start_lock_renewal()
    
    def get_with_strong_consistency(self, key, lock_key=None):
        """Get value with strong consistency guarantee"""
        if lock_key:
            self.acquire_lock(lock_key)
        
        try:
            # Check cache first
            cached_value = self.redis.get(key)
            if cached_value:
                return json.loads(cached_value)
            
            # If not in cache, get from database
            db_value = self.db.get(key)
            if db_value:
                # Update cache with database value
                self.redis.setex(key, 3600, json.dumps(db_value))
                return db_value
            
            return None
        finally:
            if lock_key:
                self.release_lock(lock_key)
    
    def set_with_strong_consistency(self, key, value, lock_key=None):
        """Set value with strong consistency guarantee"""
        if lock_key:
            self.acquire_lock(lock_key)
        
        try:
            # Update database first (write-through)
            self.db.set(key, value)
            
            # Update cache
            self.redis.setex(key, 3600, json.dumps(value))
            
            # Invalidate other caches
            self.invalidate_other_caches(key)
            
            return True
        except Exception as e:
            # Rollback database changes
            self.db.rollback()
            raise e
        finally:
            if lock_key:
                self.release_lock(lock_key)
    
    def acquire_lock(self, lock_key, timeout=None):
        """Acquire distributed lock"""
        if timeout is None:
            timeout = self.lock_timeout
        
        lock_value = str(uuid.uuid4())
        lock_acquired = self.redis.set(
            f"lock:{lock_key}", 
            lock_value, 
            nx=True, 
            ex=timeout
        )
        
        if lock_acquired:
            self.active_locks[lock_key] = {
                'value': lock_value,
                'acquired_at': time.time(),
                'timeout': timeout
            }
            return True
        
        return False
    
    def release_lock(self, lock_key):
        """Release distributed lock"""
        if lock_key not in self.active_locks:
            return False
        
        lock_value = self.active_locks[lock_key]['value']
        
        # Use Lua script to ensure atomic release
        lua_script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """
        
        result = self.redis.eval(lua_script, 1, f"lock:{lock_key}", lock_value)
        
        if result:
            del self.active_locks[lock_key]
            return True
        
        return False
    
    def renew_lock(self, lock_key):
        """Renew lock to prevent timeout"""
        if lock_key not in self.active_locks:
            return False
        
        lock_value = self.active_locks[lock_key]['value']
        new_timeout = self.active_locks[lock_key]['timeout']
        
        # Use Lua script to ensure atomic renewal
        lua_script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("expire", KEYS[1], ARGV[2])
        else
            return 0
        end
        """
        
        result = self.redis.eval(lua_script, 1, f"lock:{lock_key}", lock_value, new_timeout)
        
        if result:
            self.active_locks[lock_key]['acquired_at'] = time.time()
            return True
        
        return False
    
    def start_lock_renewal(self):
        """Start background lock renewal process"""
        def renew_locks():
            while True:
                try:
                    current_time = time.time()
                    for lock_key, lock_info in self.active_locks.items():
                        if current_time - lock_info['acquired_at'] > self.lock_renewal_interval:
                            self.renew_lock(lock_key)
                    time.sleep(1)
                except Exception as e:
                    print(f"Error in lock renewal: {e}")
                    time.sleep(1)
        
        threading.Thread(target=renew_locks, daemon=True).start()
    
    def invalidate_other_caches(self, key):
        """Invalidate key in other cache instances"""
        # This would typically involve:
        # 1. Publishing invalidation event to message queue
        # 2. Other cache instances listening and invalidating
        # For this example, we'll simulate the invalidation
        pass
```

### Eventual Consistency Cache

```python
class EventualConsistencyCache:
    def __init__(self, redis_client, event_bus):
        self.redis = redis_client
        self.event_bus = event_bus
        self.vector_clock = {}
        self.consistency_window = 5  # seconds
        self.start_event_processing()
    
    def get_with_eventual_consistency(self, key, max_age=None):
        """Get value with eventual consistency"""
        cached_data = self.redis.get(key)
        if not cached_data:
            return None
        
        data = json.loads(cached_data)
        
        # Check if data is within consistency window
        if max_age and time.time() - data['timestamp'] > max_age:
            return None
        
        return data['value']
    
    def set_with_eventual_consistency(self, key, value, version=None):
        """Set value with eventual consistency"""
        if version is None:
            version = self._generate_version(key)
        
        # Update vector clock
        self._update_vector_clock(key, version)
        
        # Store with version and timestamp
        data = {
            'value': value,
            'version': version,
            'timestamp': time.time(),
            'vector_clock': self.vector_clock.get(key, {})
        }
        
        self.redis.setex(key, 3600, json.dumps(data))
        
        # Propagate update to other caches
        self.propagate_update(key, value, version)
        
        return version
    
    def propagate_update(self, key, value, version):
        """Propagate update to other caches"""
        event = {
            'type': 'cache_update',
            'key': key,
            'value': value,
            'version': version,
            'timestamp': time.time(),
            'vector_clock': self.vector_clock.get(key, {})
        }
        
        self.event_bus.publish('cache_updates', event)
    
    def resolve_conflict(self, key, versions):
        """Resolve conflict between versions"""
        if not versions:
            return None
        
        # Use vector clock to determine latest version
        latest_version = max(versions, key=lambda v: v['vector_clock'])
        
        # Update cache with latest version
        self.redis.setex(key, 3600, json.dumps(latest_version))
        
        return latest_version
    
    def _generate_version(self, key):
        """Generate version for key"""
        return f"{key}_{int(time.time() * 1000)}"
    
    def _update_vector_clock(self, key, version):
        """Update vector clock for key"""
        if key not in self.vector_clock:
            self.vector_clock[key] = {}
        
        self.vector_clock[key][version] = time.time()
    
    def start_event_processing(self):
        """Start processing cache update events"""
        def process_events():
            while True:
                try:
                    event = self.event_bus.consume('cache_updates', timeout=1)
                    if event:
                        self._handle_cache_update(event)
                except Exception as e:
                    print(f"Error processing event: {e}")
                    time.sleep(1)
        
        threading.Thread(target=process_events, daemon=True).start()
    
    def _handle_cache_update(self, event):
        """Handle cache update event"""
        key = event['key']
        value = event['value']
        version = event['version']
        vector_clock = event['vector_clock']
        
        # Check if we have a conflict
        existing_data = self.redis.get(key)
        if existing_data:
            existing = json.loads(existing_data)
            if existing['version'] != version:
                # Resolve conflict
                self.resolve_conflict(key, [existing, {
                    'value': value,
                    'version': version,
                    'vector_clock': vector_clock
                }])
        else:
            # No conflict, update directly
            data = {
                'value': value,
                'version': version,
                'timestamp': time.time(),
                'vector_clock': vector_clock
            }
            self.redis.setex(key, 3600, json.dumps(data))
```

## Additional Resources

### Consistency Models
- [CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem)
- [PACELC Theorem](https://en.wikipedia.org/wiki/PACELC_theorem)
- [Consistency Models](https://en.wikipedia.org/wiki/Consistency_model)

### Cache Coherence
- [MESI Protocol](https://en.wikipedia.org/wiki/MESI_protocol)
- [Cache Coherence](https://en.wikipedia.org/wiki/Cache_coherence)
- [Distributed Caching](https://en.wikipedia.org/wiki/Distributed_cache)

### Tools and Libraries
- **Redis**: Distributed cache with locking support
- **Apache Kafka**: Event streaming for cache updates
- **Zookeeper**: Distributed coordination
- **Consul**: Service discovery and configuration

### Best Practices
- Use appropriate consistency models for different data types
- Implement proper locking mechanisms
- Design effective conflict resolution strategies
- Monitor consistency metrics continuously

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy consistency system to production
2. **Test**: Perform comprehensive consistency testing
3. **Monitor**: Set up consistency monitoring
4. **Optimize**: Continuously optimize consistency vs. performance
5. **Scale**: Plan for future scaling requirements

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
