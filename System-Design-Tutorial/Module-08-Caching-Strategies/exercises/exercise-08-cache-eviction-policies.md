# Exercise 8: Cache Eviction Policies

## Overview

**Duration**: 3-4 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1-7 completion, understanding of memory management

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive cache eviction policies
- Design intelligent eviction algorithms
- Create adaptive eviction strategies
- Optimize memory usage and cache performance

## Scenario

You are implementing cache eviction policies for a high-performance data processing system with the following requirements:

### Memory Constraints
- **Total Cache Memory**: 100GB across 10 nodes
- **Memory per Node**: 10GB per Redis node
- **Memory Pressure**: 80% utilization threshold
- **Eviction Trigger**: 90% memory utilization

### Data Characteristics
- **Data Types**: User sessions, product catalogs, search results, analytics data
- **Access Patterns**: Highly variable, some data accessed frequently, some rarely
- **Data Sizes**: 1KB to 10MB per item
- **Update Frequency**: Real-time to daily updates

### Performance Requirements
- **Eviction Latency**: < 1ms per eviction
- **Memory Efficiency**: > 85% memory utilization
- **Cache Hit Ratio**: > 90% after eviction
- **Throughput**: 1M+ operations per second

## Exercise Tasks

### Task 1: LRU Eviction Policy Implementation (90 minutes)

Implement Least Recently Used (LRU) eviction policy with optimizations:

1. **Basic LRU Implementation**
   - Implement doubly-linked list for O(1) operations
   - Create hash map for O(1) lookups
   - Handle cache hits and misses efficiently
   - Implement memory management

2. **LRU Optimizations**
   - Implement segmented LRU for better performance
   - Add probabilistic eviction for large datasets
   - Create adaptive TTL based on access patterns
   - Implement batch eviction for efficiency

**Implementation Requirements**:
```python
class LRUCache:
    def __init__(self, capacity, eviction_threshold=0.9):
        self.capacity = capacity
        self.eviction_threshold = eviction_threshold
        self.cache = {}
        self.head = Node()
        self.tail = Node()
        self.head.next = self.tail
        self.tail.prev = self.head
        self.size = 0
    
    def get(self, key):
        """Get value with LRU update"""
        pass
    
    def put(self, key, value):
        """Put value with LRU eviction"""
        pass
    
    def evict_lru(self):
        """Evict least recently used item"""
        pass
    
    def update_access_time(self, key):
        """Update access time for key"""
        pass
```

### Task 2: LFU Eviction Policy Implementation (75 minutes)

Implement Least Frequently Used (LFU) eviction policy with frequency tracking:

1. **Frequency Tracking**
   - Implement frequency counter for each key
   - Create frequency-based data structures
   - Handle frequency updates efficiently
   - Implement aging mechanism for frequency decay

2. **LFU Optimizations**
   - Implement probabilistic LFU for better performance
   - Add frequency-based segmentation
   - Create adaptive frequency thresholds
   - Implement frequency-based TTL

**Implementation Requirements**:
```python
class LFUCache:
    def __init__(self, capacity, min_frequency=1):
        self.capacity = capacity
        self.min_frequency = min_frequency
        self.cache = {}
        self.frequency_map = {}
        self.frequency_lists = {}
        self.min_freq = 0
    
    def get(self, key):
        """Get value with frequency update"""
        pass
    
    def put(self, key, value):
        """Put value with frequency tracking"""
        pass
    
    def evict_lfu(self):
        """Evict least frequently used item"""
        pass
    
    def update_frequency(self, key):
        """Update frequency for key"""
        pass
```

### Task 3: Adaptive Eviction Strategy (60 minutes)

Implement adaptive eviction strategy that combines multiple policies:

1. **Policy Selection**
   - Implement policy selection based on access patterns
   - Create hybrid eviction strategies
   - Add machine learning-based policy selection
   - Implement A/B testing for eviction policies

2. **Adaptive Parameters**
   - Implement dynamic threshold adjustment
   - Create workload-based parameter tuning
   - Add performance-based policy switching
   - Implement cost-benefit analysis for eviction

**Implementation Requirements**:
```python
class AdaptiveEvictionCache:
    def __init__(self, capacity, policies=['lru', 'lfu', 'fifo']):
        self.capacity = capacity
        self.policies = policies
        self.current_policy = 'lru'
        self.policy_performance = {}
        self.workload_analyzer = WorkloadAnalyzer()
        self.performance_monitor = PerformanceMonitor()
    
    def select_optimal_policy(self):
        """Select optimal eviction policy based on workload"""
        pass
    
    def adapt_eviction_parameters(self):
        """Adapt eviction parameters based on performance"""
        pass
    
    def evaluate_policy_performance(self, policy):
        """Evaluate performance of specific policy"""
        pass
    
    def switch_policy(self, new_policy):
        """Switch to new eviction policy"""
        pass
```

### Task 4: Memory Management and Optimization (45 minutes)

Implement comprehensive memory management for cache eviction:

1. **Memory Monitoring**
   - Implement real-time memory usage tracking
   - Create memory pressure detection
   - Add memory fragmentation monitoring
   - Implement memory leak detection

2. **Memory Optimization**
   - Implement memory compaction strategies
   - Create memory pool management
   - Add memory-efficient data structures
   - Implement garbage collection optimization

**Implementation Requirements**:
```python
class MemoryManager:
    def __init__(self, total_memory, node_count):
        self.total_memory = total_memory
        self.node_count = node_count
        self.memory_per_node = total_memory // node_count
        self.memory_usage = {}
        self.fragmentation_tracker = FragmentationTracker()
    
    def monitor_memory_usage(self):
        """Monitor memory usage across all nodes"""
        pass
    
    def detect_memory_pressure(self):
        """Detect memory pressure conditions"""
        pass
    
    def optimize_memory_usage(self):
        """Optimize memory usage through compaction"""
        pass
    
    def handle_memory_fragmentation(self):
        """Handle memory fragmentation issues"""
        pass
```

## Performance Targets

### Eviction Performance
- **Eviction Latency**: < 1ms per eviction
- **Memory Utilization**: > 85% before eviction
- **Cache Hit Ratio**: > 90% after eviction
- **Throughput**: 1M+ evictions per second

### Memory Efficiency
- **Memory Fragmentation**: < 5%
- **Memory Leaks**: 0 memory leaks
- **Memory Overhead**: < 10% of total memory
- **Compaction Efficiency**: > 80% space recovery

### Adaptive Performance
- **Policy Switch Time**: < 100ms
- **Parameter Adaptation**: < 50ms
- **Performance Improvement**: > 20% vs. static policies
- **Cost Reduction**: > 15% vs. single policy

## Evaluation Criteria

### Technical Implementation (40%)
- **Eviction Policies**: Proper implementation of LRU, LFU, and adaptive policies
- **Memory Management**: Effective memory monitoring and optimization
- **Performance**: Meets all performance targets
- **Adaptability**: Intelligent policy selection and parameter tuning

### Algorithm Efficiency (30%)
- **Time Complexity**: O(1) for get/put operations
- **Space Complexity**: Efficient memory usage
- **Scalability**: Handles required scale
- **Optimization**: Effective optimization strategies

### Monitoring and Analytics (20%)
- **Performance Monitoring**: Comprehensive performance tracking
- **Memory Analytics**: Detailed memory usage analysis
- **Adaptive Analytics**: Policy performance analysis
- **Alerting**: Proactive alerting for issues

### Documentation and Testing (10%)
- **Code Documentation**: Clear and comprehensive documentation
- **Test Coverage**: Thorough testing of all scenarios
- **Performance Testing**: Load testing and optimization
- **Documentation**: Clear implementation documentation

## Sample Implementation

### LRU Cache Implementation

```python
class Node:
    def __init__(self, key=None, value=None):
        self.key = key
        self.value = value
        self.prev = None
        self.next = None
        self.access_time = time.time()
        self.access_count = 0

class LRUCache:
    def __init__(self, capacity, eviction_threshold=0.9):
        self.capacity = capacity
        self.eviction_threshold = eviction_threshold
        self.cache = {}
        self.head = Node()
        self.tail = Node()
        self.head.next = self.tail
        self.tail.prev = self.head
        self.size = 0
        self.memory_usage = 0
        self.max_memory = capacity * 1024 * 1024  # Convert to bytes
        self.performance_stats = {
            'hits': 0,
            'misses': 0,
            'evictions': 0,
            'total_operations': 0
        }
    
    def get(self, key):
        """Get value with LRU update"""
        self.performance_stats['total_operations'] += 1
        
        if key in self.cache:
            node = self.cache[key]
            self._move_to_head(node)
            node.access_time = time.time()
            node.access_count += 1
            self.performance_stats['hits'] += 1
            return node.value
        
        self.performance_stats['misses'] += 1
        return None
    
    def put(self, key, value):
        """Put value with LRU eviction"""
        self.performance_stats['total_operations'] += 1
        
        if key in self.cache:
            # Update existing key
            node = self.cache[key]
            node.value = value
            node.access_time = time.time()
            node.access_count += 1
            self._move_to_head(node)
        else:
            # Add new key
            new_node = Node(key, value)
            self.cache[key] = new_node
            self._add_to_head(new_node)
            self.size += 1
            self.memory_usage += self._calculate_memory_usage(new_node)
            
            # Check if eviction is needed
            if self._should_evict():
                self._evict_lru()
    
    def _should_evict(self):
        """Check if eviction is needed"""
        memory_ratio = self.memory_usage / self.max_memory
        return memory_ratio > self.eviction_threshold or self.size > self.capacity
    
    def _evict_lru(self):
        """Evict least recently used item"""
        if self.size == 0:
            return
        
        # Remove tail node (least recently used)
        lru_node = self.tail.prev
        self._remove_node(lru_node)
        del self.cache[lru_node.key]
        self.size -= 1
        self.memory_usage -= self._calculate_memory_usage(lru_node)
        self.performance_stats['evictions'] += 1
    
    def _move_to_head(self, node):
        """Move node to head of list"""
        self._remove_node(node)
        self._add_to_head(node)
    
    def _add_to_head(self, node):
        """Add node to head of list"""
        node.prev = self.head
        node.next = self.head.next
        self.head.next.prev = node
        self.head.next = node
    
    def _remove_node(self, node):
        """Remove node from list"""
        node.prev.next = node.next
        node.next.prev = node.prev
    
    def _calculate_memory_usage(self, node):
        """Calculate memory usage for node"""
        key_size = len(str(node.key)) if node.key else 0
        value_size = len(str(node.value)) if node.value else 0
        return key_size + value_size + 64  # 64 bytes for node overhead
    
    def get_performance_stats(self):
        """Get performance statistics"""
        hit_ratio = self.performance_stats['hits'] / max(self.performance_stats['total_operations'], 1)
        return {
            'hit_ratio': hit_ratio,
            'memory_usage': self.memory_usage,
            'memory_utilization': self.memory_usage / self.max_memory,
            'size': self.size,
            'capacity': self.capacity,
            'stats': self.performance_stats
        }
```

### LFU Cache Implementation

```python
class LFUCache:
    def __init__(self, capacity, min_frequency=1):
        self.capacity = capacity
        self.min_frequency = min_frequency
        self.cache = {}
        self.frequency_map = {}
        self.frequency_lists = {}
        self.min_freq = 0
        self.memory_usage = 0
        self.max_memory = capacity * 1024 * 1024
        self.performance_stats = {
            'hits': 0,
            'misses': 0,
            'evictions': 0,
            'total_operations': 0
        }
    
    def get(self, key):
        """Get value with frequency update"""
        self.performance_stats['total_operations'] += 1
        
        if key in self.cache:
            node = self.cache[key]
            self._update_frequency(key)
            self.performance_stats['hits'] += 1
            return node.value
        
        self.performance_stats['misses'] += 1
        return None
    
    def put(self, key, value):
        """Put value with frequency tracking"""
        self.performance_stats['total_operations'] += 1
        
        if key in self.cache:
            # Update existing key
            node = self.cache[key]
            node.value = value
            self._update_frequency(key)
        else:
            # Add new key
            if len(self.cache) >= self.capacity:
                self._evict_lfu()
            
            new_node = Node(key, value)
            self.cache[key] = new_node
            self.frequency_map[key] = 1
            self._add_to_frequency_list(key, 1)
            self.min_freq = 1
            self.memory_usage += self._calculate_memory_usage(new_node)
    
    def _update_frequency(self, key):
        """Update frequency for key"""
        if key not in self.frequency_map:
            return
        
        old_freq = self.frequency_map[key]
        new_freq = old_freq + 1
        self.frequency_map[key] = new_freq
        
        # Remove from old frequency list
        self._remove_from_frequency_list(key, old_freq)
        
        # Add to new frequency list
        self._add_to_frequency_list(key, new_freq)
        
        # Update min_freq if necessary
        if old_freq == self.min_freq and not self.frequency_lists.get(old_freq):
            self.min_freq = new_freq
    
    def _add_to_frequency_list(self, key, freq):
        """Add key to frequency list"""
        if freq not in self.frequency_lists:
            self.frequency_lists[freq] = []
        self.frequency_lists[freq].append(key)
    
    def _remove_from_frequency_list(self, key, freq):
        """Remove key from frequency list"""
        if freq in self.frequency_lists:
            if key in self.frequency_lists[freq]:
                self.frequency_lists[freq].remove(key)
            if not self.frequency_lists[freq]:
                del self.frequency_lists[freq]
    
    def _evict_lfu(self):
        """Evict least frequently used item"""
        if not self.frequency_lists.get(self.min_freq):
            return
        
        # Remove first item from min frequency list
        lfu_key = self.frequency_lists[self.min_freq].pop(0)
        lfu_node = self.cache[lfu_key]
        
        del self.cache[lfu_key]
        del self.frequency_map[lfu_key]
        self.memory_usage -= self._calculate_memory_usage(lfu_node)
        self.performance_stats['evictions'] += 1
        
        # Clean up empty frequency list
        if not self.frequency_lists[self.min_freq]:
            del self.frequency_lists[self.min_freq]
    
    def _calculate_memory_usage(self, node):
        """Calculate memory usage for node"""
        key_size = len(str(node.key)) if node.key else 0
        value_size = len(str(node.value)) if node.value else 0
        return key_size + value_size + 64  # 64 bytes for node overhead
```

## Additional Resources

### Eviction Algorithms
- [LRU Algorithm](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_recently_used_(LRU))
- [LFU Algorithm](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least-frequently_used_(LFU))
- [Adaptive Replacement Cache](https://en.wikipedia.org/wiki/Adaptive_replacement_cache)

### Memory Management
- [Memory Management](https://en.wikipedia.org/wiki/Memory_management)
- [Garbage Collection](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
- [Memory Fragmentation](https://en.wikipedia.org/wiki/Fragmentation_(computing))

### Tools and Libraries
- **Redis**: In-memory data structure store
- **Memcached**: Distributed memory caching system
- **Hazelcast**: In-memory data grid
- **Caffeine**: High-performance Java caching library

### Best Practices
- Choose eviction policy based on access patterns
- Monitor memory usage continuously
- Implement adaptive strategies for changing workloads
- Test eviction policies under realistic conditions

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy eviction system to production
2. **Monitor**: Set up comprehensive eviction monitoring
3. **Optimize**: Continuously optimize eviction strategies
4. **Test**: Regular testing of eviction performance
5. **Improve**: Enhance eviction algorithms based on data

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
