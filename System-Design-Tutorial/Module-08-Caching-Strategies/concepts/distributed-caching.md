# Distributed Caching

## Overview

Distributed caching enables multiple application instances to share cached data across a network, providing scalability, high availability, and performance benefits. This document covers comprehensive distributed caching strategies and implementations.

## Table of Contents

1. [Distributed Cache Architecture](#distributed-cache-architecture)
2. [Consistency Models](#consistency-models)
3. [Partitioning Strategies](#partitioning-strategies)
4. [Replication Strategies](#replication-strategies)
5. [Cache Coherence Protocols](#cache-coherence-protocols)
6. [Performance Optimization](#performance-optimization)
7. [Real-World Examples](#real-world-examples)

## Distributed Cache Architecture

### Client-Server Architecture
**Description**: Centralized cache server accessed by multiple clients

**Advantages**:
- Simple implementation
- Centralized management
- Consistent data access

**Disadvantages**:
- Single point of failure
- Limited scalability
- Network bottleneck

**Implementation**:
```python
class DistributedCacheClient:
    def __init__(self, cache_servers):
        self.cache_servers = cache_servers
        self.current_server = 0
        self.consistent_hash = ConsistentHash(cache_servers)
    
    def get(self, key):
        server = self.consistent_hash.get_node(key)
        return server.get(key)
    
    def set(self, key, value):
        server = self.consistent_hash.get_node(key)
        return server.set(key, value)
```

### Peer-to-Peer Architecture
**Description**: All nodes participate in caching and routing

**Advantages**:
- No single point of failure
- High scalability
- Decentralized management

**Disadvantages**:
- Complex implementation
- Consistency challenges
- Network overhead

**Implementation**:
```python
class PeerToPeerCache:
    def __init__(self, node_id, nodes):
        self.node_id = node_id
        self.nodes = nodes
        self.local_cache = {}
        self.consistent_hash = ConsistentHash(nodes)
    
    def get(self, key):
        # Check local cache first
        if key in self.local_cache:
            return self.local_cache[key]
        
        # Route to appropriate node
        target_node = self.consistent_hash.get_node(key)
        if target_node == self.node_id:
            return None
        
        return target_node.get(key)
    
    def set(self, key, value):
        # Store locally
        self.local_cache[key] = value
        
        # Replicate to other nodes
        replicas = self._get_replica_nodes(key)
        for replica in replicas:
            replica.set(key, value)
```

## Consistency Models

### Strong Consistency
**Description**: All nodes see the same data at the same time

**Implementation**:
```python
class StrongConsistentCache:
    def __init__(self, nodes):
        self.nodes = nodes
        self.locks = {}
    
    def get(self, key):
        # Read from all nodes and compare
        values = []
        for node in self.nodes:
            value = node.get(key)
            if value is not None:
                values.append(value)
        
        # Return value if all nodes agree
        if values and all(v == values[0] for v in values):
            return values[0]
        
        return None
    
    def set(self, key, value):
        # Acquire lock
        with self._get_lock(key):
            # Write to all nodes
            success = True
            for node in self.nodes:
                if not node.set(key, value):
                    success = False
            
            return success
```

### Eventual Consistency
**Description**: All nodes will eventually have the same data

**Implementation**:
```python
class EventuallyConsistentCache:
    def __init__(self, nodes, sync_interval=60):
        self.nodes = nodes
        self.sync_interval = sync_interval
        self.start_sync_thread()
    
    def get(self, key):
        # Try local node first
        local_value = self.nodes[0].get(key)
        if local_value is not None:
            return local_value
        
        # Try other nodes
        for node in self.nodes[1:]:
            value = node.get(key)
            if value is not None:
                return value
        
        return None
    
    def set(self, key, value):
        # Write to local node
        self.nodes[0].set(key, value)
        
        # Asynchronously replicate to other nodes
        self._async_replicate(key, value)
    
    def _async_replicate(self, key, value):
        def replicate():
            for node in self.nodes[1:]:
                try:
                    node.set(key, value)
                except Exception as e:
                    print(f"Replication failed: {e}")
        
        threading.Thread(target=replicate, daemon=True).start()
```

## Partitioning Strategies

### Hash-Based Partitioning
**Description**: Distribute data based on hash of key

**Implementation**:
```python
class HashPartitionedCache:
    def __init__(self, nodes):
        self.nodes = nodes
        self.consistent_hash = ConsistentHash(nodes)
    
    def get(self, key):
        node = self.consistent_hash.get_node(key)
        return node.get(key)
    
    def set(self, key, value):
        node = self.consistent_hash.get_node(key)
        return node.set(key, value)
```

### Range-Based Partitioning
**Description**: Distribute data based on key ranges

**Implementation**:
```python
class RangePartitionedCache:
    def __init__(self, nodes, ranges):
        self.nodes = nodes
        self.ranges = ranges
    
    def get(self, key):
        node = self._get_node_for_key(key)
        return node.get(key)
    
    def set(self, key, value):
        node = self._get_node_for_key(key)
        return node.set(key, value)
    
    def _get_node_for_key(self, key):
        for i, (start, end) in enumerate(self.ranges):
            if start <= key <= end:
                return self.nodes[i]
        return self.nodes[-1]  # Default to last node
```

## Replication Strategies

### Master-Slave Replication
**Description**: One master node, multiple slave nodes

**Implementation**:
```python
class MasterSlaveCache:
    def __init__(self, master, slaves):
        self.master = master
        self.slaves = slaves
    
    def get(self, key):
        # Try master first
        value = self.master.get(key)
        if value is not None:
            return value
        
        # Try slaves
        for slave in self.slaves:
            value = slave.get(key)
            if value is not None:
                return value
        
        return None
    
    def set(self, key, value):
        # Write to master
        success = self.master.set(key, value)
        if success:
            # Replicate to slaves
            self._replicate_to_slaves(key, value)
        
        return success
    
    def _replicate_to_slaves(self, key, value):
        for slave in self.slaves:
            try:
                slave.set(key, value)
            except Exception as e:
                print(f"Slave replication failed: {e}")
```

### Multi-Master Replication
**Description**: Multiple master nodes with conflict resolution

**Implementation**:
```python
class MultiMasterCache:
    def __init__(self, masters, conflict_resolver):
        self.masters = masters
        self.conflict_resolver = conflict_resolver
    
    def get(self, key):
        # Get from all masters
        values = []
        for master in self.masters:
            value = master.get(key)
            if value is not None:
                values.append(value)
        
        # Resolve conflicts
        if values:
            return self.conflict_resolver.resolve(values)
        
        return None
    
    def set(self, key, value):
        # Write to all masters
        success = True
        for master in self.masters:
            if not master.set(key, value):
                success = False
        
        return success
```

## Cache Coherence Protocols

### MESI Protocol
**Description**: Modified, Exclusive, Shared, Invalid states

**Implementation**:
```python
class MESICache:
    def __init__(self, node_id, nodes):
        self.node_id = node_id
        self.nodes = nodes
        self.cache = {}
        self.states = {}  # key -> state
    
    def get(self, key):
        if key in self.cache:
            state = self.states[key]
            if state in ['M', 'E', 'S']:
                return self.cache[key]
        
        # Cache miss - request from other nodes
        return self._handle_cache_miss(key)
    
    def set(self, key, value):
        # Invalidate other caches
        self._invalidate_other_caches(key)
        
        # Set local cache
        self.cache[key] = value
        self.states[key] = 'M'  # Modified
    
    def _invalidate_other_caches(self, key):
        for node in self.nodes:
            if node != self.node_id:
                node.invalidate(key)
```

## Performance Optimization

### Connection Pooling
**Description**: Reuse connections to cache servers

**Implementation**:
```python
class ConnectionPool:
    def __init__(self, max_connections=10):
        self.max_connections = max_connections
        self.connections = queue.Queue(maxsize=max_connections)
        self.active_connections = 0
        self.lock = threading.Lock()
    
    def get_connection(self):
        with self.lock:
            if not self.connections.empty():
                return self.connections.get()
            elif self.active_connections < self.max_connections:
                self.active_connections += 1
                return self._create_connection()
            else:
                return None
    
    def return_connection(self, connection):
        with self.lock:
            if self.connections.qsize() < self.max_connections:
                self.connections.put(connection)
            else:
                self.active_connections -= 1
                connection.close()
```

### Compression
**Description**: Compress data before storing in cache

**Implementation**:
```python
import gzip
import json

class CompressedCache:
    def __init__(self, cache, compression_threshold=1024):
        self.cache = cache
        self.compression_threshold = compression_threshold
    
    def get(self, key):
        data = self.cache.get(key)
        if data is None:
            return None
        
        # Check if data is compressed
        if data.startswith(b'COMPRESSED:'):
            compressed_data = data[11:]  # Remove 'COMPRESSED:' prefix
            decompressed_data = gzip.decompress(compressed_data)
            return json.loads(decompressed_data.decode())
        
        return json.loads(data.decode())
    
    def set(self, key, value):
        data = json.dumps(value).encode()
        
        # Compress if data is large enough
        if len(data) > self.compression_threshold:
            compressed_data = gzip.compress(data)
            self.cache.set(key, b'COMPRESSED:' + compressed_data)
        else:
            self.cache.set(key, data)
```

## Real-World Examples

### Example 1: Redis Cluster
**Description**: Distributed Redis implementation

**Features**:
- Hash-based partitioning
- Master-slave replication
- Automatic failover
- Consistent hashing

### Example 2: Memcached Cluster
**Description**: Distributed Memcached implementation

**Features**:
- Client-side partitioning
- No replication
- Simple protocol
- High performance

### Example 3: Hazelcast
**Description**: In-memory data grid

**Features**:
- Peer-to-peer architecture
- Automatic partitioning
- Built-in replication
- Java-based

## Best Practices

### 1. Partitioning Strategy
- Use consistent hashing for even distribution
- Consider data access patterns
- Plan for node failures
- Monitor partition balance

### 2. Replication Strategy
- Choose appropriate replication factor
- Consider consistency requirements
- Plan for network partitions
- Monitor replication lag

### 3. Performance Optimization
- Use connection pooling
- Implement compression
- Monitor cache hit ratios
- Optimize network usage

### 4. Monitoring and Alerting
- Track cache performance metrics
- Monitor node health
- Alert on failures
- Log cache operations

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
