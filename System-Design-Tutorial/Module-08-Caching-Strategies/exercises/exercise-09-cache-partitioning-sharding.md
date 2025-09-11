# Exercise 9: Cache Partitioning and Sharding

## Overview

**Duration**: 4-5 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1-8 completion, understanding of distributed systems

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive cache partitioning strategies
- Design efficient cache sharding algorithms
- Create consistent hashing for cache distribution
- Optimize cache performance across multiple nodes

## Scenario

You are implementing cache partitioning for a distributed e-commerce platform with the following requirements:

### Scale Requirements
- **Cache Nodes**: 50+ Redis nodes across 5 regions
- **Data Volume**: 1TB+ cached data globally
- **Request Volume**: 10M+ requests per second
- **Data Types**: User sessions, product catalogs, shopping carts, recommendations

### Distribution Requirements
- **Geographic Distribution**: Data distributed across regions
- **Load Balancing**: Even distribution of load across nodes
- **Fault Tolerance**: Handle node failures gracefully
- **Consistency**: Maintain data consistency across partitions

### Performance Requirements
- **Partition Lookup**: < 1ms for partition resolution
- **Data Locality**: Minimize cross-region data access
- **Rebalancing**: < 5 minutes for partition rebalancing
- **Availability**: 99.99% uptime despite node failures

## Exercise Tasks

### Task 1: Consistent Hashing Implementation (90 minutes)

Implement consistent hashing for cache distribution:

1. **Hash Ring Implementation**
   - Create virtual nodes for better distribution
   - Implement hash ring with O(log n) lookup
   - Handle node addition and removal
   - Implement data migration during rebalancing

2. **Hash Ring Optimizations**
   - Implement weighted consistent hashing
   - Add replication for fault tolerance
   - Create hash ring visualization
   - Implement hash ring monitoring

**Implementation Requirements**:
```python
import hashlib
import bisect
from typing import List, Dict, Any, Optional

class ConsistentHashRing:
    def __init__(self, nodes: List[str], replicas: int = 3):
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        self.nodes = set()
        
        for node in nodes:
            self.add_node(node)
    
    def _hash(self, key: str) -> int:
        """Generate hash for key"""
        pass
    
    def add_node(self, node: str) -> None:
        """Add node to hash ring"""
        pass
    
    def remove_node(self, node: str) -> None:
        """Remove node from hash ring"""
        pass
    
    def get_node(self, key: str) -> str:
        """Get node for key"""
        pass
    
    def get_nodes(self, key: str, count: int = 1) -> List[str]:
        """Get multiple nodes for key (for replication)"""
        pass
```

### Task 2: Cache Sharding Strategy (75 minutes)

Implement comprehensive cache sharding strategies:

1. **Range-Based Sharding**
   - Implement range-based data distribution
   - Create range queries across shards
   - Handle range rebalancing
   - Implement range-based load balancing

2. **Hash-Based Sharding**
   - Implement hash-based data distribution
   - Create hash-based queries
   - Handle hash collision resolution
   - Implement hash-based load balancing

**Implementation Requirements**:
```python
class CacheShardingManager:
    def __init__(self, shard_count: int, sharding_strategy: str = 'consistent_hash'):
        self.shard_count = shard_count
        self.sharding_strategy = sharding_strategy
        self.shards = {}
        self.shard_metadata = {}
        self.load_balancer = LoadBalancer()
        
    def get_shard(self, key: str) -> str:
        """Get shard for key"""
        pass
    
    def set_data(self, key: str, value: Any, ttl: int = 3600) -> bool:
        """Set data in appropriate shard"""
        pass
    
    def get_data(self, key: str) -> Any:
        """Get data from appropriate shard"""
        pass
    
    def rebalance_shards(self) -> None:
        """Rebalance data across shards"""
        pass
```

### Task 3: Geographic Partitioning (60 minutes)

Implement geographic partitioning for global distribution:

1. **Region-Based Partitioning**
   - Implement region-based data distribution
   - Create cross-region data replication
   - Handle region failover
   - Implement region-based routing

2. **Latency-Based Partitioning**
   - Implement latency-based data placement
   - Create dynamic region selection
   - Handle latency monitoring
   - Implement adaptive partitioning

**Implementation Requirements**:
```python
class GeographicPartitioningManager:
    def __init__(self, regions: List[str], replication_factor: int = 2):
        self.regions = regions
        self.replication_factor = replication_factor
        self.region_nodes = {}
        self.latency_monitor = LatencyMonitor()
        self.routing_table = {}
        
    def get_region_for_key(self, key: str, user_location: str) -> str:
        """Get optimal region for key based on user location"""
        pass
    
    def replicate_data(self, key: str, value: Any, primary_region: str) -> None:
        """Replicate data to multiple regions"""
        pass
    
    def get_data_from_region(self, key: str, region: str) -> Any:
        """Get data from specific region"""
        pass
    
    def handle_region_failure(self, failed_region: str) -> None:
        """Handle region failure and failover"""
        pass
```

### Task 4: Partition Monitoring and Rebalancing (45 minutes)

Implement comprehensive partition monitoring and rebalancing:

1. **Partition Monitoring**
   - Monitor partition health and performance
   - Track data distribution across partitions
   - Monitor load balancing effectiveness
   - Implement partition analytics

2. **Automatic Rebalancing**
   - Implement automatic partition rebalancing
   - Create rebalancing strategies
   - Handle rebalancing without downtime
   - Implement rebalancing validation

**Implementation Requirements**:
```python
class PartitionMonitor:
    def __init__(self, sharding_manager: CacheShardingManager):
        self.sharding_manager = sharding_manager
        self.metrics_collector = MetricsCollector()
        self.alert_manager = AlertManager()
        
    def monitor_partition_health(self) -> Dict[str, Any]:
        """Monitor health of all partitions"""
        pass
    
    def monitor_data_distribution(self) -> Dict[str, Any]:
        """Monitor data distribution across partitions"""
        pass
    
    def monitor_load_balancing(self) -> Dict[str, Any]:
        """Monitor load balancing effectiveness"""
        pass
    
    def trigger_rebalancing(self, rebalancing_strategy: str = 'automatic') -> None:
        """Trigger partition rebalancing"""
        pass
```

## Performance Targets

### Partitioning Performance
- **Partition Lookup**: < 1ms for partition resolution
- **Data Distribution**: < 10% variance across partitions
- **Rebalancing Time**: < 5 minutes for full rebalancing
- **Cross-Region Latency**: < 100ms for data access

### Scalability Targets
- **Node Addition**: < 2 minutes for new node integration
- **Node Removal**: < 3 minutes for graceful node removal
- **Data Migration**: < 1GB/minute migration rate
- **Consistency**: 99.99% data consistency across partitions

### Fault Tolerance
- **Node Failure Recovery**: < 30 seconds
- **Region Failure Recovery**: < 2 minutes
- **Data Availability**: 99.99% despite failures
- **Replication Lag**: < 1 second

## Evaluation Criteria

### Technical Implementation (40%)
- **Consistent Hashing**: Proper implementation of consistent hashing
- **Sharding Strategy**: Effective sharding strategy implementation
- **Geographic Partitioning**: Proper geographic distribution
- **Monitoring**: Comprehensive partition monitoring

### Performance Achievement (30%)
- **Lookup Performance**: Meets partition lookup targets
- **Distribution Balance**: Achieves balanced data distribution
- **Rebalancing Efficiency**: Efficient partition rebalancing
- **Fault Tolerance**: Handles failures gracefully

### Scalability and Optimization (20%)
- **Scalability**: Handles required scale
- **Load Balancing**: Effective load distribution
- **Resource Utilization**: Efficient resource usage
- **Cost Optimization**: Cost-effective partitioning

### Monitoring and Operations (10%)
- **Monitoring**: Comprehensive monitoring implementation
- **Alerting**: Effective alerting for issues
- **Documentation**: Clear implementation documentation
- **Testing**: Thorough testing of partitioning

## Sample Implementation

### Consistent Hash Ring Implementation

```python
import hashlib
import bisect
from typing import List, Dict, Any, Optional
import time
import json

class ConsistentHashRing:
    def __init__(self, nodes: List[str], replicas: int = 3):
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        self.nodes = set()
        self.node_weights = {}
        self.performance_stats = {
            'lookups': 0,
            'hits': 0,
            'misses': 0,
            'rebalances': 0
        }
        
        for node in nodes:
            self.add_node(node)
    
    def _hash(self, key: str) -> int:
        """Generate hash for key using MD5"""
        return int(hashlib.md5(key.encode('utf-8')).hexdigest(), 16)
    
    def add_node(self, node: str, weight: int = 1) -> None:
        """Add node to hash ring with weight"""
        self.nodes.add(node)
        self.node_weights[node] = weight
        
        for i in range(self.replicas * weight):
            virtual_key = f"{node}:{i}"
            hash_value = self._hash(virtual_key)
            self.ring[hash_value] = node
            bisect.insort(self.sorted_keys, hash_value)
        
        self.performance_stats['rebalances'] += 1
    
    def remove_node(self, node: str) -> None:
        """Remove node from hash ring"""
        if node not in self.nodes:
            return
        
        self.nodes.remove(node)
        weight = self.node_weights.get(node, 1)
        
        for i in range(self.replicas * weight):
            virtual_key = f"{node}:{i}"
            hash_value = self._hash(virtual_key)
            if hash_value in self.ring:
                del self.ring[hash_value]
                self.sorted_keys.remove(hash_value)
        
        del self.node_weights[node]
        self.performance_stats['rebalances'] += 1
    
    def get_node(self, key: str) -> str:
        """Get node for key using consistent hashing"""
        self.performance_stats['lookups'] += 1
        
        if not self.ring:
            self.performance_stats['misses'] += 1
            return None
        
        hash_value = self._hash(key)
        index = bisect.bisect_right(self.sorted_keys, hash_value)
        
        if index == len(self.sorted_keys):
            index = 0
        
        node = self.ring[self.sorted_keys[index]]
        self.performance_stats['hits'] += 1
        return node
    
    def get_nodes(self, key: str, count: int = 1) -> List[str]:
        """Get multiple nodes for key (for replication)"""
        if not self.ring:
            return []
        
        hash_value = self._hash(key)
        index = bisect.bisect_right(self.sorted_keys, hash_value)
        
        if index == len(self.sorted_keys):
            index = 0
        
        nodes = []
        seen = set()
        
        for i in range(len(self.sorted_keys)):
            current_index = (index + i) % len(self.sorted_keys)
            node = self.ring[self.sorted_keys[current_index]]
            
            if node not in seen:
                nodes.append(node)
                seen.add(node)
                
                if len(nodes) >= count:
                    break
        
        return nodes
    
    def get_ring_distribution(self) -> Dict[str, int]:
        """Get distribution of keys across nodes"""
        distribution = {}
        for node in self.nodes:
            distribution[node] = 0
        
        # Simulate key distribution
        for i in range(10000):  # Sample 10k keys
            key = f"key_{i}"
            node = self.get_node(key)
            if node:
                distribution[node] += 1
        
        return distribution
    
    def get_performance_stats(self) -> Dict[str, Any]:
        """Get performance statistics"""
        hit_ratio = self.performance_stats['hits'] / max(self.performance_stats['lookups'], 1)
        return {
            'hit_ratio': hit_ratio,
            'total_lookups': self.performance_stats['lookups'],
            'hits': self.performance_stats['hits'],
            'misses': self.performance_stats['misses'],
            'rebalances': self.performance_stats['rebalances'],
            'node_count': len(self.nodes),
            'ring_size': len(self.ring)
        }
```

### Cache Sharding Manager Implementation

```python
class CacheShardingManager:
    def __init__(self, shard_count: int, sharding_strategy: str = 'consistent_hash'):
        self.shard_count = shard_count
        self.sharding_strategy = sharding_strategy
        self.shards = {}
        self.shard_metadata = {}
        self.load_balancer = LoadBalancer()
        self.consistent_hash = None
        
        if sharding_strategy == 'consistent_hash':
            self.consistent_hash = ConsistentHashRing([f"shard_{i}" for i in range(shard_count)])
        
        self.performance_stats = {
            'operations': 0,
            'hits': 0,
            'misses': 0,
            'rebalances': 0
        }
    
    def get_shard(self, key: str) -> str:
        """Get shard for key based on sharding strategy"""
        if self.sharding_strategy == 'consistent_hash':
            return self.consistent_hash.get_node(key)
        elif self.sharding_strategy == 'range_based':
            return self._get_range_shard(key)
        elif self.sharding_strategy == 'hash_based':
            return self._get_hash_shard(key)
        else:
            raise ValueError(f"Unknown sharding strategy: {self.sharding_strategy}")
    
    def _get_range_shard(self, key: str) -> str:
        """Get shard for key using range-based sharding"""
        # Simple range-based sharding
        key_hash = hash(key)
        shard_index = key_hash % self.shard_count
        return f"shard_{shard_index}"
    
    def _get_hash_shard(self, key: str) -> str:
        """Get shard for key using hash-based sharding"""
        key_hash = hash(key)
        shard_index = key_hash % self.shard_count
        return f"shard_{shard_index}"
    
    def set_data(self, key: str, value: Any, ttl: int = 3600) -> bool:
        """Set data in appropriate shard"""
        self.performance_stats['operations'] += 1
        
        shard = self.get_shard(key)
        
        if shard not in self.shards:
            self.shards[shard] = {}
            self.shard_metadata[shard] = {
                'created_at': time.time(),
                'key_count': 0,
                'memory_usage': 0
            }
        
        # Store data in shard
        self.shards[shard][key] = {
            'value': value,
            'ttl': ttl,
            'created_at': time.time()
        }
        
        # Update metadata
        self.shard_metadata[shard]['key_count'] += 1
        self.shard_metadata[shard]['memory_usage'] += self._calculate_memory_usage(key, value)
        
        return True
    
    def get_data(self, key: str) -> Any:
        """Get data from appropriate shard"""
        self.performance_stats['operations'] += 1
        
        shard = self.get_shard(key)
        
        if shard not in self.shards or key not in self.shards[shard]:
            self.performance_stats['misses'] += 1
            return None
        
        data = self.shards[shard][key]
        
        # Check TTL
        if time.time() - data['created_at'] > data['ttl']:
            del self.shards[shard][key]
            self.shard_metadata[shard]['key_count'] -= 1
            self.performance_stats['misses'] += 1
            return None
        
        self.performance_stats['hits'] += 1
        return data['value']
    
    def rebalance_shards(self) -> None:
        """Rebalance data across shards"""
        self.performance_stats['rebalances'] += 1
        
        # Calculate current distribution
        current_distribution = self._get_distribution()
        
        # Calculate target distribution
        target_distribution = self._calculate_target_distribution()
        
        # Plan rebalancing
        rebalance_plan = self._create_rebalance_plan(current_distribution, target_distribution)
        
        # Execute rebalancing
        self._execute_rebalance_plan(rebalance_plan)
    
    def _get_distribution(self) -> Dict[str, int]:
        """Get current data distribution across shards"""
        distribution = {}
        for shard, data in self.shards.items():
            distribution[shard] = len(data)
        return distribution
    
    def _calculate_target_distribution(self) -> Dict[str, int]:
        """Calculate target distribution for rebalancing"""
        total_keys = sum(len(data) for data in self.shards.values())
        keys_per_shard = total_keys // self.shard_count
        
        target_distribution = {}
        for i in range(self.shard_count):
            shard = f"shard_{i}"
            target_distribution[shard] = keys_per_shard
        
        return target_distribution
    
    def _create_rebalance_plan(self, current: Dict[str, int], target: Dict[str, int]) -> List[Dict]:
        """Create rebalancing plan"""
        plan = []
        
        for shard in current:
            current_count = current.get(shard, 0)
            target_count = target.get(shard, 0)
            
            if current_count > target_count:
                # Need to move data out
                excess = current_count - target_count
                plan.append({
                    'action': 'move_out',
                    'shard': shard,
                    'count': excess
                })
            elif current_count < target_count:
                # Need to move data in
                deficit = target_count - current_count
                plan.append({
                    'action': 'move_in',
                    'shard': shard,
                    'count': deficit
                })
        
        return plan
    
    def _execute_rebalance_plan(self, plan: List[Dict]) -> None:
        """Execute rebalancing plan"""
        for action in plan:
            if action['action'] == 'move_out':
                self._move_data_out(action['shard'], action['count'])
            elif action['action'] == 'move_in':
                self._move_data_in(action['shard'], action['count'])
    
    def _move_data_out(self, shard: str, count: int) -> None:
        """Move data out of shard"""
        if shard not in self.shards:
            return
        
        keys_to_move = list(self.shards[shard].keys())[:count]
        
        for key in keys_to_move:
            value = self.shards[shard][key]
            del self.shards[shard][key]
            
            # Move to another shard
            new_shard = self._find_least_loaded_shard()
            if new_shard != shard:
                self.set_data(key, value['value'], value['ttl'])
    
    def _move_data_in(self, shard: str, count: int) -> None:
        """Move data into shard"""
        # Find data to move from other shards
        other_shards = [s for s in self.shards.keys() if s != shard]
        
        for other_shard in other_shards:
            if count <= 0:
                break
            
            keys_to_move = list(self.shards[other_shard].keys())[:count]
            
            for key in keys_to_move:
                value = self.shards[other_shard][key]
                del self.shards[other_shard][key]
                
                # Move to target shard
                self.set_data(key, value['value'], value['ttl'])
                count -= 1
    
    def _find_least_loaded_shard(self) -> str:
        """Find least loaded shard"""
        if not self.shards:
            return f"shard_{0}"
        
        min_load = min(len(data) for data in self.shards.values())
        for shard, data in self.shards.items():
            if len(data) == min_load:
                return shard
        
        return list(self.shards.keys())[0]
    
    def _calculate_memory_usage(self, key: str, value: Any) -> int:
        """Calculate memory usage for key-value pair"""
        key_size = len(str(key))
        value_size = len(str(value))
        return key_size + value_size + 64  # 64 bytes overhead
    
    def get_shard_stats(self) -> Dict[str, Any]:
        """Get statistics for all shards"""
        stats = {}
        for shard, data in self.shards.items():
            stats[shard] = {
                'key_count': len(data),
                'memory_usage': self.shard_metadata.get(shard, {}).get('memory_usage', 0),
                'created_at': self.shard_metadata.get(shard, {}).get('created_at', 0)
            }
        return stats
    
    def get_performance_stats(self) -> Dict[str, Any]:
        """Get performance statistics"""
        hit_ratio = self.performance_stats['hits'] / max(self.performance_stats['operations'], 1)
        return {
            'hit_ratio': hit_ratio,
            'total_operations': self.performance_stats['operations'],
            'hits': self.performance_stats['hits'],
            'misses': self.performance_stats['misses'],
            'rebalances': self.performance_stats['rebalances'],
            'shard_count': len(self.shards)
        }
```

## Additional Resources

### Partitioning Strategies
- [Consistent Hashing](https://en.wikipedia.org/wiki/Consistent_hashing)
- [Database Sharding](https://en.wikipedia.org/wiki/Shard_(database_architecture))
- [Load Balancing](https://en.wikipedia.org/wiki/Load_balancing_(computing))

### Distributed Systems
- [Distributed Caching](https://en.wikipedia.org/wiki/Distributed_cache)
- [CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem)
- [Consistency Models](https://en.wikipedia.org/wiki/Consistency_model)

### Tools and Libraries
- **Redis Cluster**: Distributed Redis implementation
- **Hazelcast**: Distributed in-memory data grid
- **Apache Ignite**: Distributed caching platform
- **Consul**: Service discovery and configuration

### Best Practices
- Use consistent hashing for even distribution
- Implement proper replication for fault tolerance
- Monitor partition health continuously
- Plan for rebalancing and scaling

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy partitioning system to production
2. **Monitor**: Set up comprehensive partition monitoring
3. **Scale**: Plan for future scaling requirements
4. **Optimize**: Continuously optimize partitioning strategies
5. **Test**: Regular testing of partitioning performance

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
