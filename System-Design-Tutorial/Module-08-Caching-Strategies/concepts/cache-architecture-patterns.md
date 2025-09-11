# Cache Architecture Patterns

## Overview

Cache architecture patterns form the foundation of high-performance systems by strategically placing caches at different layers to optimize data access, reduce latency, and improve overall system performance. This document explores comprehensive caching patterns used in enterprise systems.

## Table of Contents

1. [Cache Hierarchy Fundamentals](#cache-hierarchy-fundamentals)
2. [Multi-Level Caching Patterns](#multi-level-caching-patterns)
3. [Cache Placement Strategies](#cache-placement-strategies)
4. [Distributed Caching Architectures](#distributed-caching-architectures)
5. [Cache Coordination Patterns](#cache-coordination-patterns)
6. [Performance Optimization Patterns](#performance-optimization-patterns)
7. [Real-World Implementation Examples](#real-world-implementation-examples)

## Cache Hierarchy Fundamentals

### L1 Cache (CPU Cache)
**Purpose**: Fastest access to frequently used data
**Characteristics**:
- **Size**: 32KB - 1MB
- **Latency**: 1-3 CPU cycles
- **Access Pattern**: Hardware-managed
- **Use Cases**: CPU instructions, frequently accessed variables

**Implementation Details**:
```
CPU Core
├── L1 Instruction Cache (32KB)
├── L1 Data Cache (32KB)
└── L2 Cache (256KB - 1MB)
```

### L2 Cache (Application Memory Cache)
**Purpose**: Application-level caching for frequently accessed data
**Characteristics**:
- **Size**: 1MB - 1GB
- **Latency**: 10-100 nanoseconds
- **Access Pattern**: Software-managed
- **Use Cases**: Database query results, computed values, session data

**Implementation Example**:
```python
class L2Cache:
    def __init__(self, max_size=1000):
        self.cache = {}
        self.max_size = max_size
        self.access_order = []
    
    def get(self, key):
        if key in self.cache:
            # Move to end (most recently used)
            self.access_order.remove(key)
            self.access_order.append(key)
            return self.cache[key]
        return None
    
    def put(self, key, value):
        if len(self.cache) >= self.max_size:
            # Remove least recently used
            lru_key = self.access_order.pop(0)
            del self.cache[lru_key]
        
        self.cache[key] = value
        self.access_order.append(key)
```

### L3 Cache (Distributed Cache)
**Purpose**: Shared caching across multiple application instances
**Characteristics**:
- **Size**: 1GB - 100GB
- **Latency**: 1-10 milliseconds
- **Access Pattern**: Network-based
- **Use Cases**: Shared session data, frequently accessed database records

### L4 Cache (CDN/Edge Cache)
**Purpose**: Global content delivery and edge computing
**Characteristics**:
- **Size**: 100GB - 10TB
- **Latency**: 10-100 milliseconds
- **Access Pattern**: HTTP-based
- **Use Cases**: Static content, API responses, media files

## Multi-Level Caching Patterns

### Pattern 1: Write-Through Caching
**Description**: Data is written to both cache and underlying storage simultaneously

**Advantages**:
- **Data Consistency**: Cache and storage are always in sync
- **Reliability**: No data loss if cache fails
- **Simplicity**: Straightforward implementation

**Disadvantages**:
- **Write Latency**: Higher write latency due to dual writes
- **Write Throughput**: Reduced write throughput
- **Resource Usage**: Higher resource consumption

**Implementation**:
```python
class WriteThroughCache:
    def __init__(self, cache, storage):
        self.cache = cache
        self.storage = storage
    
    def write(self, key, value):
        # Write to both cache and storage
        self.cache.set(key, value)
        self.storage.write(key, value)
    
    def read(self, key):
        # Try cache first
        value = self.cache.get(key)
        if value is None:
            # Cache miss - read from storage
            value = self.storage.read(key)
            if value is not None:
                self.cache.set(key, value)
        return value
```

### Pattern 2: Write-Back Caching
**Description**: Data is written to cache immediately and to storage asynchronously

**Advantages**:
- **Write Performance**: Fast write operations
- **Write Throughput**: High write throughput
- **Resource Efficiency**: Reduced storage I/O

**Disadvantages**:
- **Data Loss Risk**: Potential data loss if cache fails
- **Complexity**: More complex implementation
- **Consistency**: Eventual consistency model

**Implementation**:
```python
class WriteBackCache:
    def __init__(self, cache, storage, flush_interval=60):
        self.cache = cache
        self.storage = storage
        self.dirty_keys = set()
        self.flush_interval = flush_interval
        self.start_flush_thread()
    
    def write(self, key, value):
        # Write to cache immediately
        self.cache.set(key, value)
        self.dirty_keys.add(key)
    
    def read(self, key):
        return self.cache.get(key)
    
    def start_flush_thread(self):
        def flush_dirty_data():
            while True:
                time.sleep(self.flush_interval)
                for key in list(self.dirty_keys):
                    value = self.cache.get(key)
                    if value is not None:
                        self.storage.write(key, value)
                        self.dirty_keys.remove(key)
        
        threading.Thread(target=flush_dirty_data, daemon=True).start()
```

### Pattern 3: Write-Around Caching
**Description**: Data is written directly to storage, bypassing cache

**Advantages**:
- **Cache Efficiency**: Prevents cache pollution with infrequently accessed data
- **Write Performance**: Direct write to storage
- **Memory Usage**: Optimal memory utilization

**Disadvantages**:
- **Read Latency**: Higher read latency for recently written data
- **Cache Miss Rate**: Higher cache miss rate
- **Complexity**: Requires careful cache management

**Implementation**:
```python
class WriteAroundCache:
    def __init__(self, cache, storage):
        self.cache = cache
        self.storage = storage
    
    def write(self, key, value):
        # Write directly to storage, bypass cache
        self.storage.write(key, value)
        # Optionally invalidate cache entry
        self.cache.delete(key)
    
    def read(self, key):
        # Try cache first
        value = self.cache.get(key)
        if value is None:
            # Cache miss - read from storage
            value = self.storage.read(key)
            if value is not None:
                self.cache.set(key, value)
        return value
```

## Cache Placement Strategies

### Strategy 1: Cache-Aside Pattern
**Description**: Application manages cache explicitly

**Implementation Flow**:
1. Application checks cache for data
2. If cache hit, return data
3. If cache miss, fetch from data source
4. Store data in cache for future requests

**Advantages**:
- **Control**: Full control over cache behavior
- **Flexibility**: Custom cache logic
- **Debugging**: Easy to debug and monitor

**Disadvantages**:
- **Complexity**: More complex application code
- **Consistency**: Manual consistency management
- **Performance**: Additional application overhead

**Implementation**:
```python
class CacheAsidePattern:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
    
    def get_data(self, key):
        # Check cache first
        data = self.cache.get(key)
        if data is not None:
            return data
        
        # Cache miss - fetch from data source
        data = self.data_source.fetch(key)
        if data is not None:
            # Store in cache for future requests
            self.cache.set(key, data)
        
        return data
    
    def update_data(self, key, value):
        # Update data source
        self.data_source.update(key, value)
        # Update cache
        self.cache.set(key, value)
    
    def delete_data(self, key):
        # Delete from data source
        self.data_source.delete(key)
        # Remove from cache
        self.cache.delete(key)
```

### Strategy 2: Read-Through Pattern
**Description**: Cache automatically loads data from data source on miss

**Implementation Flow**:
1. Application requests data from cache
2. Cache checks for data
3. If cache miss, cache loads from data source
4. Cache returns data to application

**Advantages**:
- **Simplicity**: Simple application code
- **Transparency**: Transparent to application
- **Consistency**: Automatic consistency management

**Disadvantages**:
- **Latency**: Higher latency on cache miss
- **Control**: Less control over cache behavior
- **Complexity**: More complex cache implementation

**Implementation**:
```python
class ReadThroughCache:
    def __init__(self, data_source, ttl=3600):
        self.data_source = data_source
        self.cache = {}
        self.ttl = ttl
        self.timestamps = {}
    
    def get(self, key):
        # Check if data exists and is not expired
        if key in self.cache:
            if time.time() - self.timestamps[key] < self.ttl:
                return self.cache[key]
            else:
                # Expired - remove from cache
                del self.cache[key]
                del self.timestamps[key]
        
        # Cache miss - load from data source
        data = self.data_source.fetch(key)
        if data is not None:
            self.cache[key] = data
            self.timestamps[key] = time.time()
        
        return data
```

### Strategy 3: Write-Through Pattern
**Description**: Cache automatically writes to data source on update

**Implementation Flow**:
1. Application writes data to cache
2. Cache immediately writes to data source
3. Cache confirms write completion
4. Application receives confirmation

**Advantages**:
- **Consistency**: Strong consistency guarantee
- **Reliability**: No data loss risk
- **Simplicity**: Simple application code

**Disadvantages**:
- **Latency**: Higher write latency
- **Throughput**: Reduced write throughput
- **Resource Usage**: Higher resource consumption

**Implementation**:
```python
class WriteThroughCache:
    def __init__(self, data_source, ttl=3600):
        self.data_source = data_source
        self.cache = {}
        self.ttl = ttl
        self.timestamps = {}
    
    def set(self, key, value):
        # Write to data source first
        success = self.data_source.write(key, value)
        if success:
            # Write to cache
            self.cache[key] = value
            self.timestamps[key] = time.time()
            return True
        return False
    
    def get(self, key):
        # Check if data exists and is not expired
        if key in self.cache:
            if time.time() - self.timestamps[key] < self.ttl:
                return self.cache[key]
            else:
                # Expired - remove from cache
                del self.cache[key]
                del self.timestamps[key]
        
        # Cache miss - load from data source
        data = self.data_source.fetch(key)
        if data is not None:
            self.cache[key] = data
            self.timestamps[key] = time.time()
        
        return data
```

## Distributed Caching Architectures

### Architecture 1: Client-Side Caching
**Description**: Cache is located on the client side

**Characteristics**:
- **Latency**: Lowest latency (local access)
- **Consistency**: Eventual consistency
- **Scalability**: Limited by client resources
- **Use Cases**: Browser caching, mobile app caching

**Implementation**:
```javascript
class ClientSideCache {
    constructor(maxSize = 100, ttl = 300000) { // 5 minutes default TTL
        this.cache = new Map();
        this.maxSize = maxSize;
        this.ttl = ttl;
    }
    
    get(key) {
        const item = this.cache.get(key);
        if (!item) return null;
        
        // Check if expired
        if (Date.now() - item.timestamp > this.ttl) {
            this.cache.delete(key);
            return null;
        }
        
        return item.value;
    }
    
    set(key, value) {
        // Remove oldest items if at capacity
        if (this.cache.size >= this.maxSize) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        
        this.cache.set(key, {
            value: value,
            timestamp: Date.now()
        });
    }
}
```

### Architecture 2: Server-Side Caching
**Description**: Cache is located on the server side

**Characteristics**:
- **Latency**: Low latency (local network)
- **Consistency**: Strong consistency possible
- **Scalability**: Limited by server resources
- **Use Cases**: Application server caching, database caching

**Implementation**:
```python
class ServerSideCache:
    def __init__(self, max_size=10000, ttl=3600):
        self.cache = {}
        self.max_size = max_size
        self.ttl = ttl
        self.access_times = {}
        self.cleanup_interval = 300  # 5 minutes
        self.start_cleanup_thread()
    
    def get(self, key):
        if key in self.cache:
            # Check if expired
            if time.time() - self.access_times[key] < self.ttl:
                self.access_times[key] = time.time()
                return self.cache[key]
            else:
                # Expired - remove
                del self.cache[key]
                del self.access_times[key]
        
        return None
    
    def set(self, key, value):
        # Remove oldest items if at capacity
        if len(self.cache) >= self.max_size:
            self._evict_oldest()
        
        self.cache[key] = value
        self.access_times[key] = time.time()
    
    def _evict_oldest(self):
        if not self.access_times:
            return
        
        oldest_key = min(self.access_times.keys(), 
                        key=lambda k: self.access_times[k])
        del self.cache[oldest_key]
        del self.access_times[oldest_key]
    
    def start_cleanup_thread(self):
        def cleanup():
            while True:
                time.sleep(self.cleanup_interval)
                current_time = time.time()
                expired_keys = [
                    key for key, timestamp in self.access_times.items()
                    if current_time - timestamp >= self.ttl
                ]
                for key in expired_keys:
                    self.cache.pop(key, None)
                    self.access_times.pop(key, None)
        
        threading.Thread(target=cleanup, daemon=True).start()
```

### Architecture 3: Distributed Caching
**Description**: Cache is distributed across multiple nodes

**Characteristics**:
- **Latency**: Medium latency (network access)
- **Consistency**: Eventual consistency
- **Scalability**: High scalability
- **Use Cases**: Microservices caching, shared session storage

**Implementation**:
```python
class DistributedCache:
    def __init__(self, nodes, replication_factor=2):
        self.nodes = nodes
        self.replication_factor = replication_factor
        self.consistent_hash = ConsistentHash(nodes)
    
    def get(self, key):
        # Determine primary node
        primary_node = self.consistent_hash.get_node(key)
        
        # Try primary node first
        value = primary_node.get(key)
        if value is not None:
            return value
        
        # Try replica nodes
        replica_nodes = self._get_replica_nodes(key)
        for node in replica_nodes:
            value = node.get(key)
            if value is not None:
                # Repair primary node
                primary_node.set(key, value)
                return value
        
        return None
    
    def set(self, key, value):
        # Determine primary and replica nodes
        primary_node = self.consistent_hash.get_node(key)
        replica_nodes = self._get_replica_nodes(key)
        
        # Write to primary and replicas
        primary_node.set(key, value)
        for node in replica_nodes:
            node.set(key, value)
    
    def _get_replica_nodes(self, key):
        primary_node = self.consistent_hash.get_node(key)
        all_nodes = [node for node in self.nodes if node != primary_node]
        return all_nodes[:self.replication_factor - 1]
```

## Cache Coordination Patterns

### Pattern 1: Cache Invalidation
**Description**: Coordinated invalidation of cache entries across multiple caches

**Implementation**:
```python
class CacheInvalidation:
    def __init__(self, caches):
        self.caches = caches
        self.invalidation_queue = queue.Queue()
        self.start_invalidation_thread()
    
    def invalidate(self, key):
        # Add to invalidation queue
        self.invalidation_queue.put(key)
    
    def start_invalidation_thread(self):
        def process_invalidations():
            while True:
                try:
                    key = self.invalidation_queue.get(timeout=1)
                    # Invalidate in all caches
                    for cache in self.caches:
                        cache.delete(key)
                    self.invalidation_queue.task_done()
                except queue.Empty:
                    continue
        
        threading.Thread(target=process_invalidations, daemon=True).start()
```

### Pattern 2: Cache Warming
**Description**: Proactive loading of data into cache

**Implementation**:
```python
class CacheWarming:
    def __init__(self, cache, data_source, warming_strategies):
        self.cache = cache
        self.data_source = data_source
        self.warming_strategies = warming_strategies
        self.start_warming_thread()
    
    def start_warming_thread(self):
        def warm_cache():
            while True:
                for strategy in self.warming_strategies:
                    keys_to_warm = strategy.get_keys_to_warm()
                    for key in keys_to_warm:
                        if not self.cache.exists(key):
                            data = self.data_source.fetch(key)
                            if data is not None:
                                self.cache.set(key, data)
                
                time.sleep(300)  # Warm every 5 minutes
        
        threading.Thread(target=warm_cache, daemon=True).start()

class PopularContentStrategy:
    def get_keys_to_warm(self):
        # Return keys for popular content
        return ["popular_item_1", "popular_item_2", "trending_item_1"]

class TimeBasedStrategy:
    def get_keys_to_warm(self):
        # Return keys based on time patterns
        current_hour = datetime.now().hour
        if 9 <= current_hour <= 17:  # Business hours
            return ["business_data_1", "business_data_2"]
        else:
            return ["evening_data_1", "evening_data_2"]
```

### Pattern 3: Cache Synchronization
**Description**: Synchronization of cache data across multiple cache instances

**Implementation**:
```python
class CacheSynchronization:
    def __init__(self, caches, sync_interval=60):
        self.caches = caches
        self.sync_interval = sync_interval
        self.start_sync_thread()
    
    def start_sync_thread(self):
        def sync_caches():
            while True:
                time.sleep(self.sync_interval)
                self._sync_all_caches()
        
        threading.Thread(target=sync_caches, daemon=True).start()
    
    def _sync_all_caches(self):
        # Get all keys from all caches
        all_keys = set()
        for cache in self.caches:
            all_keys.update(cache.get_all_keys())
        
        # Sync each key across all caches
        for key in all_keys:
            values = {}
            for cache in self.caches:
                value = cache.get(key)
                if value is not None:
                    values[cache] = value
            
            if values:
                # Find the most recent value (assuming timestamp in value)
                most_recent_value = max(values.values(), 
                                      key=lambda v: v.get('timestamp', 0))
                
                # Update all caches with most recent value
                for cache in self.caches:
                    if cache not in values or values[cache] != most_recent_value:
                        cache.set(key, most_recent_value)
```

## Performance Optimization Patterns

### Pattern 1: Cache Hit Ratio Optimization
**Description**: Strategies to maximize cache hit ratio

**Techniques**:
1. **Predictive Caching**: Pre-load data based on usage patterns
2. **Cache Warming**: Proactive loading of frequently accessed data
3. **Smart Eviction**: Intelligent eviction policies based on access patterns
4. **Cache Partitioning**: Separate caches for different data types

**Implementation**:
```python
class CacheHitRatioOptimizer:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
        self.access_patterns = {}
        self.start_optimization_thread()
    
    def track_access(self, key):
        # Track access patterns
        if key not in self.access_patterns:
            self.access_patterns[key] = {
                'count': 0,
                'last_access': time.time(),
                'frequency': 0
            }
        
        self.access_patterns[key]['count'] += 1
        self.access_patterns[key]['last_access'] = time.time()
        self.access_patterns[key]['frequency'] = (
            self.access_patterns[key]['count'] / 
            (time.time() - self.access_patterns[key]['last_access'] + 1)
        )
    
    def start_optimization_thread(self):
        def optimize():
            while True:
                time.sleep(300)  # Optimize every 5 minutes
                self._optimize_cache()
        
        threading.Thread(target=optimize, daemon=True).start()
    
    def _optimize_cache(self):
        # Pre-load frequently accessed data
        frequent_keys = [
            key for key, pattern in self.access_patterns.items()
            if pattern['frequency'] > 0.1  # Access more than once per 10 seconds
        ]
        
        for key in frequent_keys:
            if not self.cache.exists(key):
                data = self.data_source.fetch(key)
                if data is not None:
                    self.cache.set(key, data)
```

### Pattern 2: Hot Key Mitigation
**Description**: Strategies to handle hot keys that cause performance bottlenecks

**Techniques**:
1. **Key Sharding**: Distribute hot keys across multiple cache instances
2. **Local Caching**: Cache hot keys locally to reduce network traffic
3. **Rate Limiting**: Limit access to hot keys
4. **Data Replication**: Replicate hot key data across multiple nodes

**Implementation**:
```python
class HotKeyMitigation:
    def __init__(self, cache, local_cache, threshold=100):
        self.cache = cache
        self.local_cache = local_cache
        self.threshold = threshold
        self.key_access_count = {}
        self.hot_keys = set()
        self.start_monitoring_thread()
    
    def get(self, key):
        # Track access count
        self.key_access_count[key] = self.key_access_count.get(key, 0) + 1
        
        # Check if key is hot
        if self.key_access_count[key] > self.threshold:
            self.hot_keys.add(key)
        
        # Try local cache first for hot keys
        if key in self.hot_keys:
            value = self.local_cache.get(key)
            if value is not None:
                return value
        
        # Try distributed cache
        value = self.cache.get(key)
        if value is not None:
            # Store in local cache for hot keys
            if key in self.hot_keys:
                self.local_cache.set(key, value)
            return value
        
        return None
    
    def start_monitoring_thread(self):
        def monitor():
            while True:
                time.sleep(60)  # Monitor every minute
                self._update_hot_keys()
        
        threading.Thread(target=monitor, daemon=True).start()
    
    def _update_hot_keys(self):
        # Reset access counts and update hot keys
        self.key_access_count = {}
        self.hot_keys = set()
```

### Pattern 3: Cache Stampede Prevention
**Description**: Strategies to prevent cache stampede when multiple requests try to refresh the same cache entry

**Techniques**:
1. **Lock-based Prevention**: Use locks to prevent concurrent refreshes
2. **Probabilistic Early Expiration**: Randomly expire cache entries before TTL
3. **Background Refresh**: Refresh cache entries in background
4. **Circuit Breaker**: Stop refreshing if too many failures occur

**Implementation**:
```python
class CacheStampedePrevention:
    def __init__(self, cache, data_source, ttl=3600, early_expiry_factor=0.1):
        self.cache = cache
        self.data_source = data_source
        self.ttl = ttl
        self.early_expiry_factor = early_expiry_factor
        self.refresh_locks = {}
        self.circuit_breaker = CircuitBreaker()
    
    def get(self, key):
        # Check if data exists and is not expired
        data = self.cache.get(key)
        if data is not None:
            # Check if data is close to expiration
            if self._should_refresh(data):
                # Start background refresh
                self._background_refresh(key)
            return data['value']
        
        # Cache miss - refresh with lock
        return self._refresh_with_lock(key)
    
    def _should_refresh(self, data):
        # Check if data is close to expiration
        age = time.time() - data['timestamp']
        return age > (self.ttl * (1 - self.early_expiry_factor))
    
    def _background_refresh(self, key):
        def refresh():
            try:
                if self.circuit_breaker.can_execute():
                    new_data = self.data_source.fetch(key)
                    if new_data is not None:
                        self.cache.set(key, {
                            'value': new_data,
                            'timestamp': time.time()
                        })
            except Exception as e:
                self.circuit_breaker.record_failure()
        
        threading.Thread(target=refresh, daemon=True).start()
    
    def _refresh_with_lock(self, key):
        # Check if another thread is already refreshing
        if key in self.refresh_locks:
            # Wait for other thread to finish
            while key in self.refresh_locks:
                time.sleep(0.01)
            
            # Try to get data from cache
            data = self.cache.get(key)
            if data is not None:
                return data['value']
        
        # Acquire lock
        self.refresh_locks[key] = True
        
        try:
            # Double-check cache
            data = self.cache.get(key)
            if data is not None:
                return data['value']
            
            # Fetch from data source
            if self.circuit_breaker.can_execute():
                new_data = self.data_source.fetch(key)
                if new_data is not None:
                    self.cache.set(key, {
                        'value': new_data,
                        'timestamp': time.time()
                    })
                    return new_data
                else:
                    self.circuit_breaker.record_failure()
            
            return None
        finally:
            # Release lock
            self.refresh_locks.pop(key, None)

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def can_execute(self):
        if self.state == 'CLOSED':
            return True
        elif self.state == 'OPEN':
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = 'HALF_OPEN'
                return True
            return False
        else:  # HALF_OPEN
            return True
    
    def record_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = 'OPEN'
    
    def record_success(self):
        self.failure_count = 0
        self.state = 'CLOSED'
```

## Real-World Implementation Examples

### Example 1: E-commerce Product Catalog Caching
**Scenario**: High-traffic e-commerce site with millions of products

**Architecture**:
```
Client Browser
├── CDN Cache (CloudFront) - Static content, images
├── API Gateway Cache - API responses
└── Application Server
    ├── L1 Cache (Redis) - Product details, pricing
    ├── L2 Cache (ElastiCache) - User sessions, cart data
    └── Database
        ├── Read Replicas - Product queries
        └── Master - Product updates
```

**Implementation**:
```python
class EcommerceCacheManager:
    def __init__(self):
        self.cdn_cache = CloudFrontCache()
        self.api_cache = APIGatewayCache()
        self.l1_cache = RedisCache()
        self.l2_cache = ElastiCache()
        self.database = Database()
    
    def get_product(self, product_id):
        # Try L1 cache first
        product = self.l1_cache.get(f"product:{product_id}")
        if product:
            return product
        
        # Try L2 cache
        product = self.l2_cache.get(f"product:{product_id}")
        if product:
            # Promote to L1 cache
            self.l1_cache.set(f"product:{product_id}", product)
            return product
        
        # Cache miss - fetch from database
        product = self.database.get_product(product_id)
        if product:
            # Store in both caches
            self.l1_cache.set(f"product:{product_id}", product)
            self.l2_cache.set(f"product:{product_id}", product)
        
        return product
    
    def update_product(self, product_id, product_data):
        # Update database
        self.database.update_product(product_id, product_data)
        
        # Invalidate caches
        self.l1_cache.delete(f"product:{product_id}")
        self.l2_cache.delete(f"product:{product_id}")
        self.api_cache.purge(f"/products/{product_id}")
        self.cdn_cache.purge(f"/products/{product_id}")
```

### Example 2: Social Media Feed Caching
**Scenario**: Social media platform with real-time feeds

**Architecture**:
```
Client App
├── CDN Cache - Media content, static assets
├── API Gateway - Rate limiting, authentication
└── Feed Service
    ├── Timeline Cache (Redis) - User timelines
    ├── Content Cache (Redis) - Posts, comments
    └── Database
        ├── Read Replicas - Feed queries
        └── Master - Content updates
```

**Implementation**:
```python
class SocialMediaCacheManager:
    def __init__(self):
        self.timeline_cache = RedisCache()
        self.content_cache = RedisCache()
        self.database = Database()
        self.feed_generator = FeedGenerator()
    
    def get_user_timeline(self, user_id, page=1, limit=20):
        cache_key = f"timeline:{user_id}:{page}:{limit}"
        
        # Try cache first
        timeline = self.timeline_cache.get(cache_key)
        if timeline:
            return timeline
        
        # Generate timeline
        timeline = self.feed_generator.generate_timeline(user_id, page, limit)
        
        # Cache timeline
        self.timeline_cache.set(cache_key, timeline, ttl=300)  # 5 minutes
        
        return timeline
    
    def get_post(self, post_id):
        cache_key = f"post:{post_id}"
        
        # Try cache first
        post = self.content_cache.get(cache_key)
        if post:
            return post
        
        # Fetch from database
        post = self.database.get_post(post_id)
        if post:
            # Cache post
            self.content_cache.set(cache_key, post, ttl=3600)  # 1 hour
        
        return post
    
    def invalidate_user_timeline(self, user_id):
        # Invalidate all timeline pages for user
        pattern = f"timeline:{user_id}:*"
        self.timeline_cache.delete_pattern(pattern)
```

### Example 3: Real-time Analytics Caching
**Scenario**: Real-time analytics dashboard with high-frequency data updates

**Architecture**:
```
Analytics Dashboard
├── CDN Cache - Static dashboard assets
├── API Gateway - Authentication, rate limiting
└── Analytics Service
    ├── Metrics Cache (Redis) - Real-time metrics
    ├── Aggregation Cache (Redis) - Pre-computed aggregations
    └── Time Series Database - Raw metrics data
```

**Implementation**:
```python
class AnalyticsCacheManager:
    def __init__(self):
        self.metrics_cache = RedisCache()
        self.aggregation_cache = RedisCache()
        self.time_series_db = TimeSeriesDB()
        self.aggregator = MetricsAggregator()
    
    def get_real_time_metrics(self, metric_name, time_range):
        cache_key = f"metrics:{metric_name}:{time_range}"
        
        # Try cache first
        metrics = self.metrics_cache.get(cache_key)
        if metrics:
            return metrics
        
        # Fetch from time series database
        metrics = self.time_series_db.get_metrics(metric_name, time_range)
        
        # Cache with short TTL for real-time data
        self.metrics_cache.set(cache_key, metrics, ttl=60)  # 1 minute
        
        return metrics
    
    def get_aggregated_metrics(self, metric_name, aggregation_type, time_range):
        cache_key = f"agg:{metric_name}:{aggregation_type}:{time_range}"
        
        # Try cache first
        aggregated = self.aggregation_cache.get(cache_key)
        if aggregated:
            return aggregated
        
        # Compute aggregation
        raw_metrics = self.time_series_db.get_metrics(metric_name, time_range)
        aggregated = self.aggregator.aggregate(raw_metrics, aggregation_type)
        
        # Cache aggregated data
        self.aggregation_cache.set(cache_key, aggregated, ttl=300)  # 5 minutes
        
        return aggregated
    
    def update_metrics(self, metric_name, value, timestamp):
        # Update time series database
        self.time_series_db.insert_metric(metric_name, value, timestamp)
        
        # Invalidate related caches
        self.metrics_cache.delete_pattern(f"metrics:{metric_name}:*")
        self.aggregation_cache.delete_pattern(f"agg:{metric_name}:*")
```

## Best Practices and Recommendations

### 1. Cache Design Principles
- **Single Responsibility**: Each cache should have a clear, single purpose
- **Separation of Concerns**: Separate caches for different data types
- **Consistency**: Choose appropriate consistency models for your use case
- **Performance**: Optimize for the most common access patterns

### 2. Cache Sizing and Configuration
- **Memory Allocation**: Allocate appropriate memory for each cache tier
- **TTL Configuration**: Set appropriate TTL values based on data freshness requirements
- **Eviction Policies**: Choose eviction policies that match your access patterns
- **Monitoring**: Implement comprehensive monitoring and alerting

### 3. Cache Security
- **Access Control**: Implement proper access control for cache data
- **Encryption**: Encrypt sensitive data in cache
- **Network Security**: Secure cache communication channels
- **Audit Logging**: Log cache access and modifications

### 4. Cache Maintenance
- **Regular Cleanup**: Implement regular cleanup of expired data
- **Health Monitoring**: Monitor cache health and performance
- **Capacity Planning**: Plan for cache capacity growth
- **Backup and Recovery**: Implement cache backup and recovery procedures

### 5. Performance Optimization
- **Hit Ratio Monitoring**: Monitor and optimize cache hit ratios
- **Latency Optimization**: Optimize cache access latency
- **Throughput Optimization**: Optimize cache throughput
- **Resource Utilization**: Monitor and optimize resource utilization

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
