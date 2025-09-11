# Cache Invalidation Strategies

## Overview

Cache invalidation is one of the most critical aspects of caching systems, determining when and how cached data should be removed or updated to maintain data consistency. This document explores comprehensive invalidation strategies used in enterprise systems.

## Table of Contents

1. [Fundamental Invalidation Concepts](#fundamental-invalidation-concepts)
2. [Time-Based Invalidation](#time-based-invalidation)
3. [Event-Based Invalidation](#event-based-invalidation)
4. [Manual Invalidation](#manual-invalidation)
5. [Distributed Invalidation](#distributed-invalidation)
6. [Advanced Invalidation Patterns](#advanced-invalidation-patterns)
7. [Performance Considerations](#performance-considerations)
8. [Real-World Implementation Examples](#real-world-implementation-examples)

## Fundamental Invalidation Concepts

### What is Cache Invalidation?

Cache invalidation is the process of removing or updating cached data to ensure consistency between the cache and the underlying data source. It's essential for maintaining data integrity in systems where data can change.

### Invalidation Triggers

**Data Changes**: When the underlying data is modified
**Time Expiration**: When cached data reaches its time-to-live (TTL)
**Manual Intervention**: When administrators manually clear cache
**System Events**: When specific system events occur
**Capacity Limits**: When cache reaches capacity limits

### Invalidation Challenges

**Consistency**: Ensuring all cache instances are invalidated consistently
**Performance**: Minimizing the performance impact of invalidation
**Complexity**: Managing invalidation in distributed systems
**Race Conditions**: Handling concurrent access during invalidation
**Partial Invalidation**: Invalidating only relevant cache entries

## Time-Based Invalidation

### TTL (Time-To-Live) Strategy

**Description**: Cache entries expire after a predetermined time period

**Advantages**:
- **Simplicity**: Easy to implement and understand
- **Automatic**: No manual intervention required
- **Predictable**: Known expiration behavior
- **Memory Management**: Automatic cleanup of expired data

**Disadvantages**:
- **Stale Data**: Data may be stale before expiration
- **Inefficient**: May cache data that's never accessed again
- **Inconsistent**: Different cache entries may have different ages
- **Performance**: Periodic cleanup may impact performance

**Implementation**:
```python
import time
import threading
from collections import OrderedDict

class TTLCache:
    def __init__(self, default_ttl=3600, cleanup_interval=300):
        self.cache = {}
        self.timestamps = {}
        self.default_ttl = default_ttl
        self.cleanup_interval = cleanup_interval
        self.lock = threading.RLock()
        self.start_cleanup_thread()
    
    def get(self, key):
        with self.lock:
            if key in self.cache:
                # Check if expired
                if time.time() - self.timestamps[key] < self.default_ttl:
                    return self.cache[key]
                else:
                    # Expired - remove
                    del self.cache[key]
                    del self.timestamps[key]
            return None
    
    def set(self, key, value, ttl=None):
        with self.lock:
            self.cache[key] = value
            self.timestamps[key] = time.time()
            if ttl:
                # Store custom TTL
                self.timestamps[f"{key}_ttl"] = ttl
    
    def start_cleanup_thread(self):
        def cleanup():
            while True:
                time.sleep(self.cleanup_interval)
                self._cleanup_expired()
        
        threading.Thread(target=cleanup, daemon=True).start()
    
    def _cleanup_expired(self):
        with self.lock:
            current_time = time.time()
            expired_keys = []
            
            for key, timestamp in self.timestamps.items():
                if key.endswith('_ttl'):
                    continue
                
                ttl = self.timestamps.get(f"{key}_ttl", self.default_ttl)
                if current_time - timestamp >= ttl:
                    expired_keys.append(key)
            
            for key in expired_keys:
                self.cache.pop(key, None)
                self.timestamps.pop(key, None)
                self.timestamps.pop(f"{key}_ttl", None)
```

### Sliding TTL Strategy

**Description**: TTL is reset each time the cache entry is accessed

**Advantages**:
- **Frequently Used Data**: Keeps frequently accessed data in cache longer
- **Memory Efficiency**: Automatically removes unused data
- **Adaptive**: Adapts to access patterns

**Disadvantages**:
- **Complexity**: More complex implementation
- **Memory Usage**: May keep data longer than necessary
- **Performance**: Additional overhead for TTL updates

**Implementation**:
```python
class SlidingTTLCache:
    def __init__(self, default_ttl=3600, cleanup_interval=300):
        self.cache = {}
        self.timestamps = {}
        self.default_ttl = default_ttl
        self.cleanup_interval = cleanup_interval
        self.lock = threading.RLock()
        self.start_cleanup_thread()
    
    def get(self, key):
        with self.lock:
            if key in self.cache:
                # Check if expired
                if time.time() - self.timestamps[key] < self.default_ttl:
                    # Reset TTL on access
                    self.timestamps[key] = time.time()
                    return self.cache[key]
                else:
                    # Expired - remove
                    del self.cache[key]
                    del self.timestamps[key]
            return None
    
    def set(self, key, value, ttl=None):
        with self.lock:
            self.cache[key] = value
            self.timestamps[key] = time.time()
            if ttl:
                self.timestamps[f"{key}_ttl"] = ttl
    
    def start_cleanup_thread(self):
        def cleanup():
            while True:
                time.sleep(self.cleanup_interval)
                self._cleanup_expired()
        
        threading.Thread(target=cleanup, daemon=True).start()
    
    def _cleanup_expired(self):
        with self.lock:
            current_time = time.time()
            expired_keys = []
            
            for key, timestamp in self.timestamps.items():
                if key.endswith('_ttl'):
                    continue
                
                ttl = self.timestamps.get(f"{key}_ttl", self.default_ttl)
                if current_time - timestamp >= ttl:
                    expired_keys.append(key)
            
            for key in expired_keys:
                self.cache.pop(key, None)
                self.timestamps.pop(key, None)
                self.timestamps.pop(f"{key}_ttl", None)
```

### Probabilistic TTL Strategy

**Description**: Randomly expires cache entries before their TTL to prevent cache stampede

**Advantages**:
- **Cache Stampede Prevention**: Prevents simultaneous cache refreshes
- **Load Distribution**: Distributes refresh load over time
- **Performance**: Reduces peak load on data sources

**Disadvantages**:
- **Complexity**: More complex implementation
- **Unpredictable**: Expiration time is not deterministic
- **Memory Usage**: May use more memory than necessary

**Implementation**:
```python
import random

class ProbabilisticTTLCache:
    def __init__(self, default_ttl=3600, early_expiry_factor=0.1, cleanup_interval=300):
        self.cache = {}
        self.timestamps = {}
        self.default_ttl = default_ttl
        self.early_expiry_factor = early_expiry_factor
        self.cleanup_interval = cleanup_interval
        self.lock = threading.RLock()
        self.start_cleanup_thread()
    
    def get(self, key):
        with self.lock:
            if key in self.cache:
                # Check if expired (with probabilistic early expiry)
                age = time.time() - self.timestamps[key]
                ttl = self.timestamps.get(f"{key}_ttl", self.default_ttl)
                
                # Calculate probabilistic expiry
                early_expiry_threshold = ttl * (1 - self.early_expiry_factor)
                if age > early_expiry_threshold:
                    # Randomly expire early
                    expiry_probability = (age - early_expiry_threshold) / (ttl - early_expiry_threshold)
                    if random.random() < expiry_probability:
                        del self.cache[key]
                        del self.timestamps[key]
                        del self.timestamps[f"{key}_ttl"]
                        return None
                
                if age < ttl:
                    return self.cache[key]
                else:
                    # Expired - remove
                    del self.cache[key]
                    del self.timestamps[key]
                    del self.timestamps[f"{key}_ttl"]
            return None
    
    def set(self, key, value, ttl=None):
        with self.lock:
            self.cache[key] = value
            self.timestamps[key] = time.time()
            if ttl:
                self.timestamps[f"{key}_ttl"] = ttl
    
    def start_cleanup_thread(self):
        def cleanup():
            while True:
                time.sleep(self.cleanup_interval)
                self._cleanup_expired()
        
        threading.Thread(target=cleanup, daemon=True).start()
    
    def _cleanup_expired(self):
        with self.lock:
            current_time = time.time()
            expired_keys = []
            
            for key, timestamp in self.timestamps.items():
                if key.endswith('_ttl'):
                    continue
                
                ttl = self.timestamps.get(f"{key}_ttl", self.default_ttl)
                if current_time - timestamp >= ttl:
                    expired_keys.append(key)
            
            for key in expired_keys:
                self.cache.pop(key, None)
                self.timestamps.pop(key, None)
                self.timestamps.pop(f"{key}_ttl", None)
```

## Event-Based Invalidation

### Database Change Events

**Description**: Invalidate cache when database changes are detected

**Implementation**:
```python
class DatabaseChangeInvalidation:
    def __init__(self, cache, database):
        self.cache = cache
        self.database = database
        self.change_listeners = []
        self.start_change_monitoring()
    
    def add_change_listener(self, table, callback):
        self.change_listeners.append({
            'table': table,
            'callback': callback
        })
    
    def start_change_monitoring(self):
        def monitor_changes():
            # Monitor database changes (using triggers, CDC, or polling)
            while True:
                changes = self.database.get_recent_changes()
                for change in changes:
                    self._handle_change(change)
                time.sleep(1)  # Check every second
        
        threading.Thread(target=monitor_changes, daemon=True).start()
    
    def _handle_change(self, change):
        # Notify listeners
        for listener in self.change_listeners:
            if listener['table'] == change['table']:
                listener['callback'](change)
    
    def invalidate_by_table(self, table):
        # Invalidate all cache entries for a table
        pattern = f"{table}:*"
        self.cache.delete_pattern(pattern)
    
    def invalidate_by_key(self, key):
        # Invalidate specific cache entry
        self.cache.delete(key)
```

### Message Queue Events

**Description**: Invalidate cache based on messages from a message queue

**Implementation**:
```python
class MessageQueueInvalidation:
    def __init__(self, cache, message_queue):
        self.cache = cache
        self.message_queue = message_queue
        self.start_message_processing()
    
    def start_message_processing(self):
        def process_messages():
            while True:
                try:
                    message = self.message_queue.receive(timeout=1)
                    if message:
                        self._handle_invalidation_message(message)
                except Exception as e:
                    print(f"Error processing message: {e}")
        
        threading.Thread(target=process_messages, daemon=True).start()
    
    def _handle_invalidation_message(self, message):
        message_type = message.get('type')
        
        if message_type == 'invalidate_key':
            key = message.get('key')
            self.cache.delete(key)
        
        elif message_type == 'invalidate_pattern':
            pattern = message.get('pattern')
            self.cache.delete_pattern(pattern)
        
        elif message_type == 'invalidate_table':
            table = message.get('table')
            pattern = f"{table}:*"
            self.cache.delete_pattern(pattern)
        
        elif message_type == 'clear_all':
            self.cache.clear()
    
    def publish_invalidation(self, invalidation_type, **kwargs):
        message = {
            'type': invalidation_type,
            'timestamp': time.time(),
            **kwargs
        }
        self.message_queue.publish(message)
```

### Webhook Events

**Description**: Invalidate cache based on webhook notifications

**Implementation**:
```python
from flask import Flask, request, jsonify

class WebhookInvalidation:
    def __init__(self, cache):
        self.cache = cache
        self.app = Flask(__name__)
        self.setup_routes()
    
    def setup_routes(self):
        @self.app.route('/webhook/invalidate', methods=['POST'])
        def handle_invalidation():
            data = request.get_json()
            
            if data['type'] == 'invalidate_key':
                self.cache.delete(data['key'])
                return jsonify({'status': 'success'})
            
            elif data['type'] == 'invalidate_pattern':
                self.cache.delete_pattern(data['pattern'])
                return jsonify({'status': 'success'})
            
            elif data['type'] == 'invalidate_table':
                pattern = f"{data['table']}:*"
                self.cache.delete_pattern(pattern)
                return jsonify({'status': 'success'})
            
            return jsonify({'status': 'error', 'message': 'Invalid invalidation type'})
    
    def run(self, host='0.0.0.0', port=5000):
        self.app.run(host=host, port=port)
```

## Manual Invalidation

### Administrative Interface

**Description**: Provide administrators with tools to manually invalidate cache

**Implementation**:
```python
class AdministrativeInvalidation:
    def __init__(self, cache):
        self.cache = cache
        self.app = Flask(__name__)
        self.setup_routes()
    
    def setup_routes(self):
        @self.app.route('/admin/cache/invalidate/<key>', methods=['DELETE'])
        def invalidate_key(key):
            success = self.cache.delete(key)
            return jsonify({'status': 'success' if success else 'error'})
        
        @self.app.route('/admin/cache/invalidate-pattern', methods=['POST'])
        def invalidate_pattern():
            data = request.get_json()
            pattern = data.get('pattern')
            if pattern:
                count = self.cache.delete_pattern(pattern)
                return jsonify({'status': 'success', 'count': count})
            return jsonify({'status': 'error', 'message': 'Pattern required'})
        
        @self.app.route('/admin/cache/clear', methods=['DELETE'])
        def clear_all():
            self.cache.clear()
            return jsonify({'status': 'success'})
        
        @self.app.route('/admin/cache/stats', methods=['GET'])
        def get_stats():
            stats = self.cache.get_stats()
            return jsonify(stats)
    
    def run(self, host='0.0.0.0', port=5000):
        self.app.run(host=host, port=port)
```

### API-Based Invalidation

**Description**: Provide API endpoints for programmatic cache invalidation

**Implementation**:
```python
class APIInvalidation:
    def __init__(self, cache):
        self.cache = cache
        self.app = Flask(__name__)
        self.setup_routes()
    
    def setup_routes(self):
        @self.app.route('/api/cache/invalidate', methods=['POST'])
        def invalidate():
            data = request.get_json()
            invalidation_type = data.get('type')
            
            if invalidation_type == 'key':
                key = data.get('key')
                if key:
                    success = self.cache.delete(key)
                    return jsonify({'status': 'success' if success else 'error'})
            
            elif invalidation_type == 'pattern':
                pattern = data.get('pattern')
                if pattern:
                    count = self.cache.delete_pattern(pattern)
                    return jsonify({'status': 'success', 'count': count})
            
            elif invalidation_type == 'table':
                table = data.get('table')
                if table:
                    pattern = f"{table}:*"
                    count = self.cache.delete_pattern(pattern)
                    return jsonify({'status': 'success', 'count': count})
            
            return jsonify({'status': 'error', 'message': 'Invalid invalidation type'})
    
    def run(self, host='0.0.0.0', port=5000):
        self.app.run(host=host, port=port)
```

## Distributed Invalidation

### Broadcast Invalidation

**Description**: Broadcast invalidation messages to all cache instances

**Implementation**:
```python
class BroadcastInvalidation:
    def __init__(self, cache, message_broadcaster):
        self.cache = cache
        self.message_broadcaster = message_broadcaster
        self.start_message_listening()
    
    def start_message_listening(self):
        def listen_for_messages():
            while True:
                try:
                    message = self.message_broadcaster.receive()
                    if message and message.get('type') == 'invalidation':
                        self._handle_invalidation(message)
                except Exception as e:
                    print(f"Error receiving message: {e}")
        
        threading.Thread(target=listen_for_messages, daemon=True).start()
    
    def _handle_invalidation(self, message):
        invalidation_type = message.get('invalidation_type')
        
        if invalidation_type == 'key':
            key = message.get('key')
            self.cache.delete(key)
        
        elif invalidation_type == 'pattern':
            pattern = message.get('pattern')
            self.cache.delete_pattern(pattern)
        
        elif invalidation_type == 'table':
            table = message.get('table')
            pattern = f"{table}:*"
            self.cache.delete_pattern(pattern)
    
    def broadcast_invalidation(self, invalidation_type, **kwargs):
        message = {
            'type': 'invalidation',
            'invalidation_type': invalidation_type,
            'timestamp': time.time(),
            **kwargs
        }
        self.message_broadcaster.broadcast(message)
```

### Consistent Hashing Invalidation

**Description**: Use consistent hashing to determine which cache instances to invalidate

**Implementation**:
```python
import hashlib

class ConsistentHashInvalidation:
    def __init__(self, cache, cache_nodes):
        self.cache = cache
        self.cache_nodes = cache_nodes
        self.consistent_hash = ConsistentHash(cache_nodes)
    
    def invalidate_key(self, key):
        # Determine which node should handle this key
        target_node = self.consistent_hash.get_node(key)
        
        if target_node == self.cache:
            # This node should handle the invalidation
            self.cache.delete(key)
        else:
            # Forward to the target node
            target_node.invalidate_key(key)
    
    def invalidate_pattern(self, pattern):
        # Invalidate pattern on all nodes
        for node in self.cache_nodes:
            node.invalidate_pattern(pattern)
    
    def invalidate_table(self, table):
        # Invalidate table on all nodes
        pattern = f"{table}:*"
        for node in self.cache_nodes:
            node.invalidate_pattern(pattern)

class ConsistentHash:
    def __init__(self, nodes, replicas=3):
        self.nodes = nodes
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        
        for node in nodes:
            for i in range(replicas):
                key = self._hash(f"{node}:{i}")
                self.ring[key] = node
                self.sorted_keys.append(key)
        
        self.sorted_keys.sort()
    
    def _hash(self, key):
        return int(hashlib.md5(key.encode()).hexdigest(), 16)
    
    def get_node(self, key):
        if not self.ring:
            return None
        
        hash_key = self._hash(key)
        
        for ring_key in self.sorted_keys:
            if hash_key <= ring_key:
                return self.ring[ring_key]
        
        return self.ring[self.sorted_keys[0]]
```

## Advanced Invalidation Patterns

### Lazy Invalidation

**Description**: Invalidate cache entries only when they are accessed

**Implementation**:
```python
class LazyInvalidation:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
        self.invalidated_keys = set()
        self.lock = threading.RLock()
    
    def get(self, key):
        with self.lock:
            # Check if key is marked for invalidation
            if key in self.invalidated_keys:
                # Remove from invalidated set
                self.invalidated_keys.remove(key)
                # Fetch fresh data
                data = self.data_source.fetch(key)
                if data is not None:
                    self.cache.set(key, data)
                return data
            
            # Try cache first
            data = self.cache.get(key)
            if data is not None:
                return data
            
            # Cache miss - fetch from data source
            data = self.data_source.fetch(key)
            if data is not None:
                self.cache.set(key, data)
            
            return data
    
    def mark_for_invalidation(self, key):
        with self.lock:
            self.invalidated_keys.add(key)
    
    def mark_pattern_for_invalidation(self, pattern):
        with self.lock:
            # Find all keys matching pattern
            matching_keys = self.cache.get_keys_matching_pattern(pattern)
            for key in matching_keys:
                self.invalidated_keys.add(key)
```

### Write-Through Invalidation

**Description**: Invalidate cache entries when data is written

**Implementation**:
```python
class WriteThroughInvalidation:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
    
    def write(self, key, value):
        # Write to data source first
        success = self.data_source.write(key, value)
        if success:
            # Update cache
            self.cache.set(key, value)
            return True
        return False
    
    def update(self, key, value):
        # Update data source
        success = self.data_source.update(key, value)
        if success:
            # Update cache
            self.cache.set(key, value)
            return True
        return False
    
    def delete(self, key):
        # Delete from data source
        success = self.data_source.delete(key)
        if success:
            # Remove from cache
            self.cache.delete(key)
            return True
        return False
```

### Version-Based Invalidation

**Description**: Use version numbers to determine if cache entries are stale

**Implementation**:
```python
class VersionBasedInvalidation:
    def __init__(self, cache, data_source):
        self.cache = cache
        self.data_source = data_source
        self.version_store = {}
        self.lock = threading.RLock()
    
    def get(self, key):
        with self.lock:
            # Get current version from data source
            current_version = self.data_source.get_version(key)
            
            # Check if we have cached data
            cached_data = self.cache.get(key)
            if cached_data is not None:
                cached_version = cached_data.get('version', 0)
                
                # Check if cached version is current
                if cached_version >= current_version:
                    return cached_data.get('data')
            
            # Cache miss or stale - fetch fresh data
            data = self.data_source.fetch(key)
            if data is not None:
                # Store with version
                self.cache.set(key, {
                    'data': data,
                    'version': current_version
                })
                return data
            
            return None
    
    def invalidate_by_version(self, key, new_version):
        with self.lock:
            # Update version
            self.version_store[key] = new_version
            
            # Check if cached data is stale
            cached_data = self.cache.get(key)
            if cached_data is not None:
                cached_version = cached_data.get('version', 0)
                if cached_version < new_version:
                    # Remove stale data
                    self.cache.delete(key)
```

## Performance Considerations

### Invalidation Performance Metrics

**Latency**: Time taken to complete invalidation
**Throughput**: Number of invalidations per second
**Memory Usage**: Memory overhead of invalidation tracking
**Network Overhead**: Network traffic for distributed invalidation

### Optimization Strategies

**Batching**: Batch multiple invalidations together
**Asynchronous Processing**: Process invalidations asynchronously
**Selective Invalidation**: Only invalidate affected cache entries
**Compression**: Compress invalidation messages
**Caching**: Cache invalidation metadata

**Implementation**:
```python
class OptimizedInvalidation:
    def __init__(self, cache, batch_size=100, batch_timeout=1.0):
        self.cache = cache
        self.batch_size = batch_size
        self.batch_timeout = batch_timeout
        self.invalidation_queue = queue.Queue()
        self.start_batch_processing()
    
    def start_batch_processing(self):
        def process_batches():
            batch = []
            last_batch_time = time.time()
            
            while True:
                try:
                    # Try to get invalidation from queue
                    invalidation = self.invalidation_queue.get(timeout=0.1)
                    batch.append(invalidation)
                    
                    # Process batch if full or timeout reached
                    if (len(batch) >= self.batch_size or 
                        time.time() - last_batch_time >= self.batch_timeout):
                        self._process_batch(batch)
                        batch = []
                        last_batch_time = time.time()
                
                except queue.Empty:
                    # Process batch if timeout reached
                    if batch and time.time() - last_batch_time >= self.batch_timeout:
                        self._process_batch(batch)
                        batch = []
                        last_batch_time = time.time()
        
        threading.Thread(target=process_batches, daemon=True).start()
    
    def _process_batch(self, batch):
        # Group invalidations by type
        key_invalidations = []
        pattern_invalidations = []
        
        for invalidation in batch:
            if invalidation['type'] == 'key':
                key_invalidations.append(invalidation['key'])
            elif invalidation['type'] == 'pattern':
                pattern_invalidations.append(invalidation['pattern'])
        
        # Process key invalidations
        for key in key_invalidations:
            self.cache.delete(key)
        
        # Process pattern invalidations
        for pattern in pattern_invalidations:
            self.cache.delete_pattern(pattern)
    
    def invalidate_key(self, key):
        self.invalidation_queue.put({
            'type': 'key',
            'key': key,
            'timestamp': time.time()
        })
    
    def invalidate_pattern(self, pattern):
        self.invalidation_queue.put({
            'type': 'pattern',
            'pattern': pattern,
            'timestamp': time.time()
        })
```

## Real-World Implementation Examples

### Example 1: E-commerce Product Cache Invalidation

**Scenario**: E-commerce site with product catalog updates

**Implementation**:
```python
class EcommerceCacheInvalidation:
    def __init__(self, cache, database, message_queue):
        self.cache = cache
        self.database = database
        self.message_queue = message_queue
        self.start_invalidation_processing()
    
    def start_invalidation_processing(self):
        def process_invalidations():
            while True:
                try:
                    message = self.message_queue.receive(timeout=1)
                    if message and message.get('type') == 'product_update':
                        self._handle_product_update(message)
                except Exception as e:
                    print(f"Error processing invalidation: {e}")
        
        threading.Thread(target=process_invalidations, daemon=True).start()
    
    def _handle_product_update(self, message):
        product_id = message.get('product_id')
        update_type = message.get('update_type')
        
        if update_type == 'price_change':
            # Invalidate product price cache
            self.cache.delete(f"product:{product_id}:price")
            self.cache.delete(f"product:{product_id}:details")
        
        elif update_type == 'inventory_change':
            # Invalidate inventory cache
            self.cache.delete(f"product:{product_id}:inventory")
            self.cache.delete(f"product:{product_id}:availability")
        
        elif update_type == 'description_change':
            # Invalidate product details cache
            self.cache.delete(f"product:{product_id}:details")
            self.cache.delete(f"product:{product_id}:description")
        
        elif update_type == 'category_change':
            # Invalidate category-related caches
            old_category = message.get('old_category')
            new_category = message.get('new_category')
            
            if old_category:
                self.cache.delete_pattern(f"category:{old_category}:*")
            if new_category:
                self.cache.delete_pattern(f"category:{new_category}:*")
        
        # Invalidate search indexes
        self.cache.delete_pattern("search:*")
        
        # Invalidate recommendation caches
        self.cache.delete_pattern("recommendations:*")
    
    def invalidate_product(self, product_id):
        # Invalidate all product-related caches
        patterns = [
            f"product:{product_id}:*",
            f"search:*",
            f"recommendations:*",
            f"category:*"
        ]
        
        for pattern in patterns:
            self.cache.delete_pattern(pattern)
    
    def invalidate_category(self, category_id):
        # Invalidate all category-related caches
        patterns = [
            f"category:{category_id}:*",
            f"search:*",
            f"recommendations:*"
        ]
        
        for pattern in patterns:
            self.cache.delete_pattern(pattern)
```

### Example 2: Social Media Feed Cache Invalidation

**Scenario**: Social media platform with real-time feed updates

**Implementation**:
```python
class SocialMediaCacheInvalidation:
    def __init__(self, cache, database, message_queue):
        self.cache = cache
        self.database = database
        self.message_queue = message_queue
        self.start_invalidation_processing()
    
    def start_invalidation_processing(self):
        def process_invalidations():
            while True:
                try:
                    message = self.message_queue.receive(timeout=1)
                    if message and message.get('type') == 'feed_update':
                        self._handle_feed_update(message)
                except Exception as e:
                    print(f"Error processing invalidation: {e}")
        
        threading.Thread(target=process_invalidations, daemon=True).start()
    
    def _handle_feed_update(self, message):
        user_id = message.get('user_id')
        post_id = message.get('post_id')
        update_type = message.get('update_type')
        
        if update_type == 'new_post':
            # Invalidate user's timeline cache
            self.cache.delete_pattern(f"timeline:{user_id}:*")
            
            # Invalidate followers' timeline caches
            followers = self.database.get_followers(user_id)
            for follower_id in followers:
                self.cache.delete_pattern(f"timeline:{follower_id}:*")
        
        elif update_type == 'post_update':
            # Invalidate post cache
            self.cache.delete(f"post:{post_id}")
            
            # Invalidate timeline caches that might contain this post
            self.cache.delete_pattern(f"timeline:*")
        
        elif update_type == 'post_delete':
            # Invalidate post cache
            self.cache.delete(f"post:{post_id}")
            
            # Invalidate timeline caches
            self.cache.delete_pattern(f"timeline:*")
        
        elif update_type == 'user_follow':
            follower_id = message.get('follower_id')
            following_id = message.get('following_id')
            
            # Invalidate follower's timeline cache
            self.cache.delete_pattern(f"timeline:{follower_id}:*")
        
        elif update_type == 'user_unfollow':
            follower_id = message.get('follower_id')
            following_id = message.get('following_id')
            
            # Invalidate follower's timeline cache
            self.cache.delete_pattern(f"timeline:{follower_id}:*")
    
    def invalidate_user_timeline(self, user_id):
        # Invalidate all timeline caches for user
        self.cache.delete_pattern(f"timeline:{user_id}:*")
    
    def invalidate_post(self, post_id):
        # Invalidate post cache
        self.cache.delete(f"post:{post_id}")
        
        # Invalidate timeline caches that might contain this post
        self.cache.delete_pattern(f"timeline:*")
```

### Example 3: Real-time Analytics Cache Invalidation

**Scenario**: Real-time analytics dashboard with high-frequency data updates

**Implementation**:
```python
class AnalyticsCacheInvalidation:
    def __init__(self, cache, time_series_db, message_queue):
        self.cache = cache
        self.time_series_db = time_series_db
        self.message_queue = message_queue
        self.start_invalidation_processing()
    
    def start_invalidation_processing(self):
        def process_invalidations():
            while True:
                try:
                    message = self.message_queue.receive(timeout=1)
                    if message and message.get('type') == 'metric_update':
                        self._handle_metric_update(message)
                except Exception as e:
                    print(f"Error processing invalidation: {e}")
        
        threading.Thread(target=process_invalidation, daemon=True).start()
    
    def _handle_metric_update(self, message):
        metric_name = message.get('metric_name')
        time_range = message.get('time_range')
        aggregation_type = message.get('aggregation_type')
        
        # Invalidate metric cache
        self.cache.delete(f"metric:{metric_name}:{time_range}")
        
        # Invalidate aggregation caches
        if aggregation_type:
            self.cache.delete(f"agg:{metric_name}:{aggregation_type}:{time_range}")
        else:
            # Invalidate all aggregations for this metric
            self.cache.delete_pattern(f"agg:{metric_name}:*:{time_range}")
        
        # Invalidate dashboard caches that might use this metric
        self.cache.delete_pattern(f"dashboard:*")
    
    def invalidate_metric(self, metric_name, time_range=None):
        if time_range:
            # Invalidate specific time range
            self.cache.delete(f"metric:{metric_name}:{time_range}")
            self.cache.delete_pattern(f"agg:{metric_name}:*:{time_range}")
        else:
            # Invalidate all time ranges for this metric
            self.cache.delete_pattern(f"metric:{metric_name}:*")
            self.cache.delete_pattern(f"agg:{metric_name}:*")
        
        # Invalidate dashboard caches
        self.cache.delete_pattern(f"dashboard:*")
    
    def invalidate_dashboard(self, dashboard_id):
        # Invalidate dashboard cache
        self.cache.delete(f"dashboard:{dashboard_id}")
        
        # Invalidate related metric caches
        metrics = self.database.get_dashboard_metrics(dashboard_id)
        for metric in metrics:
            self.cache.delete_pattern(f"metric:{metric}:*")
            self.cache.delete_pattern(f"agg:{metric}:*")
```

## Best Practices and Recommendations

### 1. Invalidation Strategy Selection
- **TTL**: Use for data that changes infrequently
- **Event-Based**: Use for data that changes frequently
- **Manual**: Use for administrative control
- **Hybrid**: Combine multiple strategies for optimal results

### 2. Performance Optimization
- **Batch Invalidations**: Group multiple invalidations together
- **Asynchronous Processing**: Process invalidations asynchronously
- **Selective Invalidation**: Only invalidate affected entries
- **Compression**: Compress invalidation messages

### 3. Consistency Management
- **Strong Consistency**: Use for critical data
- **Eventual Consistency**: Use for non-critical data
- **Version-Based**: Use for data with version information
- **Lazy Invalidation**: Use for performance optimization

### 4. Monitoring and Alerting
- **Invalidation Metrics**: Track invalidation performance
- **Error Handling**: Handle invalidation failures gracefully
- **Alerting**: Alert on invalidation failures
- **Logging**: Log invalidation events for debugging

### 5. Testing and Validation
- **Unit Testing**: Test invalidation logic
- **Integration Testing**: Test invalidation with real systems
- **Performance Testing**: Test invalidation performance
- **Chaos Testing**: Test invalidation under failure conditions

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
