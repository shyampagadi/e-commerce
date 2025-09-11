# ADR-04-003: Database Sharding Strategy

## Status
Accepted

## Date
2024-01-15

## Context

We need to implement a database sharding strategy for our multi-tenant e-commerce platform that will serve millions of users globally. The platform requires horizontal scaling to handle:

- **User Data**: 50M+ users with varying data volumes
- **Product Data**: 100M+ products with different access patterns
- **Order Data**: 1M+ orders per day with time-based distribution
- **Analytics Data**: Petabytes of analytical data
- **Global Distribution**: Data needs to be close to users worldwide

The platform must handle:
- 50M+ users globally
- 100M+ products
- 1M+ orders per day
- 10K+ transactions per second
- 99.99% availability
- Sub-second response times

## Decision

Implement a hybrid sharding strategy that uses different sharding approaches for different data types:

### Sharding Strategy Matrix
| Data Type | Sharding Strategy | Justification | Implementation |
|-----------|-------------------|---------------|----------------|
| User Data | Hash-based Sharding | Even distribution, user isolation | Consistent hashing on user_id |
| Product Data | Range-based Sharding | Category-based access patterns | Range sharding on category_id |
| Order Data | Time-based Sharding | Time-based queries and archival | Date-based sharding on order_date |
| Analytics Data | Geographic Sharding | Regional data requirements | Geographic sharding on region |
| Search Data | Hash-based Sharding | Even distribution for search | Consistent hashing on search_key |

### Sharding Implementation

#### 1. Hash-based Sharding (Consistent Hashing)
```python
import hashlib
import bisect

class ConsistentHashSharding:
    def __init__(self, shards, replicas=3):
        self.shards = shards
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        
        for shard in shards:
            self.add_shard(shard)
    
    def add_shard(self, shard):
        """Add shard to the ring"""
        for i in range(self.replicas):
            key = self._hash(f"{shard}:{i}")
            self.ring[key] = shard
            self.sorted_keys.append(key)
        
        self.sorted_keys.sort()
    
    def remove_shard(self, shard):
        """Remove shard from the ring"""
        for i in range(self.replicas):
            key = self._hash(f"{shard}:{i}")
            if key in self.ring:
                del self.ring[key]
                self.sorted_keys.remove(key)
    
    def get_shard(self, key):
        """Get shard for a key"""
        if not self.ring:
            return None
        
        hash_key = self._hash(key)
        idx = bisect.bisect_right(self.sorted_keys, hash_key)
        if idx == len(self.sorted_keys):
            idx = 0
        
        return self.ring[self.sorted_keys[idx]]
    
    def _hash(self, key):
        """Hash function for consistent hashing"""
        return int(hashlib.md5(key.encode()).hexdigest(), 16)

# Usage for user data sharding
user_sharding = ConsistentHashSharding(['shard1', 'shard2', 'shard3', 'shard4'])

def get_user_shard(user_id):
    return user_sharding.get_shard(user_id)
```

#### 2. Range-based Sharding
```python
class RangeBasedSharding:
    def __init__(self, shard_ranges):
        self.shard_ranges = shard_ranges
        self.sorted_ranges = sorted(shard_ranges.items(), key=lambda x: x[1][0])
    
    def get_shard(self, key):
        """Get shard for a key based on range"""
        for shard_id, (start, end) in self.sorted_ranges:
            if start <= key <= end:
                return shard_id
        return None
    
    def add_shard(self, shard_id, start, end):
        """Add new shard range"""
        self.shard_ranges[shard_id] = (start, end)
        self.sorted_ranges = sorted(self.shard_ranges.items(), key=lambda x: x[1][0])
    
    def remove_shard(self, shard_id):
        """Remove shard range"""
        if shard_id in self.shard_ranges:
            del self.shard_ranges[shard_id]
            self.sorted_ranges = sorted(self.shard_ranges.items(), key=lambda x: x[1][0])

# Usage for product data sharding
product_sharding = RangeBasedSharding({
    'electronics': (1, 1000000),
    'clothing': (1000001, 2000000),
    'books': (2000001, 3000000),
    'home': (3000001, 4000000)
})

def get_product_shard(category_id):
    return product_sharding.get_shard(category_id)
```

#### 3. Time-based Sharding
```python
from datetime import datetime, timedelta

class TimeBasedSharding:
    def __init__(self, shard_interval_days=30):
        self.shard_interval_days = shard_interval_days
    
    def get_shard(self, timestamp):
        """Get shard for a timestamp"""
        if isinstance(timestamp, str):
            timestamp = datetime.fromisoformat(timestamp)
        
        # Calculate shard based on date
        shard_date = timestamp.replace(day=1)  # First day of month
        shard_id = f"shard_{shard_date.strftime('%Y_%m')}"
        return shard_id
    
    def get_shard_range(self, start_date, end_date):
        """Get all shards for a date range"""
        shards = set()
        current_date = start_date.replace(day=1)
        
        while current_date <= end_date:
            shard_id = f"shard_{current_date.strftime('%Y_%m')}"
            shards.add(shard_id)
            current_date = current_date + timedelta(days=32)
            current_date = current_date.replace(day=1)
        
        return list(shards)

# Usage for order data sharding
order_sharding = TimeBasedSharding(shard_interval_days=30)

def get_order_shard(order_date):
    return order_sharding.get_shard(order_date)
```

#### 4. Geographic Sharding
```python
class GeographicSharding:
    def __init__(self, region_shards):
        self.region_shards = region_shards
    
    def get_shard(self, region):
        """Get shard for a region"""
        return self.region_shards.get(region)
    
    def add_region(self, region, shard_id):
        """Add new region shard mapping"""
        self.region_shards[region] = shard_id
    
    def remove_region(self, region):
        """Remove region shard mapping"""
        if region in self.region_shards:
            del self.region_shards[region]

# Usage for analytics data sharding
analytics_sharding = GeographicSharding({
    'us-east': 'analytics_shard_1',
    'us-west': 'analytics_shard_2',
    'eu-west': 'analytics_shard_3',
    'ap-southeast': 'analytics_shard_4'
})

def get_analytics_shard(region):
    return analytics_sharding.get_shard(region)
```

### Shard Management

#### Shard Router
```python
class ShardRouter:
    def __init__(self, sharding_strategies):
        self.strategies = sharding_strategies
        self.shard_connections = {}
    
    def get_shard_connection(self, data_type, key):
        """Get database connection for a shard"""
        strategy = self.strategies.get(data_type)
        if not strategy:
            raise ValueError(f"No sharding strategy for data type: {data_type}")
        
        shard_id = strategy.get_shard(key)
        if not shard_id:
            raise ValueError(f"No shard found for key: {key}")
        
        if shard_id not in self.shard_connections:
            self.shard_connections[shard_id] = self._create_connection(shard_id)
        
        return self.shard_connections[shard_id]
    
    def execute_query(self, data_type, key, query, params=None):
        """Execute query on appropriate shard"""
        connection = self.get_shard_connection(data_type, key)
        return connection.execute(query, params)
    
    def execute_cross_shard_query(self, data_type, query, params=None):
        """Execute query across all shards"""
        results = []
        for shard_id, connection in self.shard_connections.items():
            if data_type in shard_id:  # Simple filtering
                result = connection.execute(query, params)
                results.extend(result)
        return results
    
    def _create_connection(self, shard_id):
        """Create database connection for shard"""
        # Implementation for creating database connections
        pass
```

#### Shard Rebalancing
```python
class ShardRebalancer:
    def __init__(self, sharding_strategies, shard_connections):
        self.strategies = sharding_strategies
        self.connections = shard_connections
        self.rebalance_threshold = 0.1  # 10% imbalance threshold
    
    def check_rebalance_needed(self, data_type):
        """Check if rebalancing is needed"""
        strategy = self.strategies.get(data_type)
        if not strategy:
            return False
        
        # Get shard sizes
        shard_sizes = {}
        for shard_id, connection in self.connections.items():
            if data_type in shard_id:
                size = self._get_shard_size(connection)
                shard_sizes[shard_id] = size
        
        if not shard_sizes:
            return False
        
        # Check for imbalance
        sizes = list(shard_sizes.values())
        avg_size = sum(sizes) / len(sizes)
        
        for size in sizes:
            if abs(size - avg_size) / avg_size > self.rebalance_threshold:
                return True
        
        return False
    
    def rebalance_shards(self, data_type):
        """Rebalance shards for a data type"""
        if not self.check_rebalance_needed(data_type):
            return
        
        strategy = self.strategies.get(data_type)
        if not strategy:
            return
        
        # Get current shard sizes
        shard_sizes = {}
        for shard_id, connection in self.connections.items():
            if data_type in shard_id:
                size = self._get_shard_size(connection)
                shard_sizes[shard_id] = size
        
        # Calculate target sizes
        total_size = sum(shard_sizes.values())
        target_size = total_size // len(shard_sizes)
        
        # Move data between shards
        for shard_id, size in shard_sizes.items():
            if size > target_size:
                excess = size - target_size
                self._move_data(shard_id, excess, data_type)
    
    def _get_shard_size(self, connection):
        """Get shard size"""
        result = connection.execute("SELECT COUNT(*) FROM data")
        return result.fetchone()[0]
    
    def _move_data(self, source_shard_id, amount, data_type):
        """Move data between shards"""
        # Implementation for moving data between shards
        pass
```

### Shard Monitoring

#### Shard Health Monitoring
```python
class ShardMonitor:
    def __init__(self, shard_connections):
        self.connections = shard_connections
        self.metrics = {}
    
    def collect_metrics(self):
        """Collect metrics from all shards"""
        for shard_id, connection in self.connections.items():
            metrics = {
                'connection_count': self._get_connection_count(connection),
                'query_performance': self._get_avg_query_time(connection),
                'disk_usage': self._get_disk_usage(connection),
                'cpu_usage': self._get_cpu_usage(connection),
                'memory_usage': self._get_memory_usage(connection)
            }
            self.metrics[shard_id] = metrics
    
    def check_health(self):
        """Check health of all shards"""
        unhealthy_shards = []
        for shard_id, metrics in self.metrics.items():
            if (metrics['connection_count'] > 1000 or
                metrics['query_performance'] > 1000 or
                metrics['disk_usage'] > 0.9):
                unhealthy_shards.append(shard_id)
        return unhealthy_shards
    
    def generate_report(self):
        """Generate shard health report"""
        report = {
            'total_shards': len(self.connections),
            'healthy_shards': len(self.connections) - len(self.check_health()),
            'metrics': self.metrics
        }
        return report
    
    def _get_connection_count(self, connection):
        """Get connection count for shard"""
        result = connection.execute("SELECT count(*) FROM pg_stat_activity")
        return result.fetchone()[0]
    
    def _get_avg_query_time(self, connection):
        """Get average query time for shard"""
        result = connection.execute("SELECT avg(total_time) FROM pg_stat_statements")
        return result.fetchone()[0] or 0
    
    def _get_disk_usage(self, connection):
        """Get disk usage for shard"""
        result = connection.execute("SELECT pg_database_size(current_database())")
        return result.fetchone()[0]
    
    def _get_cpu_usage(self, connection):
        """Get CPU usage for shard"""
        # Implementation for getting CPU usage
        return 0
    
    def _get_memory_usage(self, connection):
        """Get memory usage for shard"""
        # Implementation for getting memory usage
        return 0
```

## Rationale

### Why Hybrid Sharding Strategy?
1. **Optimized for Use Cases**: Different sharding strategies for different data types
2. **Performance**: Each strategy optimized for specific access patterns
3. **Scalability**: Better scalability through appropriate sharding
4. **Maintenance**: Easier maintenance with specialized strategies
5. **Cost Efficiency**: Optimized resource usage

### Sharding Strategy Justifications

#### Hash-based Sharding for User Data
- **Even Distribution**: Consistent hashing ensures even distribution
- **User Isolation**: Each user's data is isolated to a specific shard
- **Scalability**: Easy to add/remove shards
- **Performance**: Direct shard lookup for user operations

#### Range-based Sharding for Product Data
- **Category-based Access**: Products accessed by category
- **Query Optimization**: Range queries are efficient
- **Data Locality**: Related products stored together
- **Maintenance**: Easier to maintain category-specific data

#### Time-based Sharding for Order Data
- **Time-based Queries**: Orders queried by date ranges
- **Archival**: Easy to archive old data
- **Performance**: Recent data in fast shards
- **Maintenance**: Easier to maintain time-based data

#### Geographic Sharding for Analytics Data
- **Regional Requirements**: Data must be in specific regions
- **Compliance**: Meet data residency requirements
- **Performance**: Data close to users
- **Scalability**: Scale by region

## Consequences

### Positive Consequences
- **Performance**: Optimized performance for different data types
- **Scalability**: Better scalability through appropriate sharding
- **Maintenance**: Easier maintenance with specialized strategies
- **Cost Efficiency**: Optimized resource usage
- **Flexibility**: Flexible sharding for different requirements

### Negative Consequences
- **Complexity**: More complex sharding management
- **Cross-shard Queries**: Complex queries across shards
- **Data Migration**: Complex data migration between shards
- **Monitoring Complexity**: More complex monitoring and alerting
- **Team Learning**: Steeper learning curve for developers

### Risks and Mitigations
- **Risk**: Data imbalance across shards
  - **Mitigation**: Implement shard rebalancing and monitoring
- **Risk**: Complex cross-shard queries
  - **Mitigation**: Design queries to work within single shards
- **Risk**: Data migration complexity
  - **Mitigation**: Implement automated migration tools
- **Risk**: Shard failure
  - **Mitigation**: Implement shard replication and failover

## Alternatives Considered

### Alternative 1: Single Sharding Strategy
**Pros**: Simple implementation, easy to understand
**Cons**: Not optimized for different use cases
**Decision**: Rejected due to performance implications

### Alternative 2: No Sharding
**Pros**: Simple implementation, no complexity
**Cons**: Limited scalability, performance issues
**Decision**: Rejected due to scalability requirements

### Alternative 3: Vertical Sharding Only
**Pros**: Simple implementation, easy to understand
**Cons**: Limited scalability, performance issues
**Decision**: Rejected due to scalability requirements

### Alternative 4: Custom Sharding Strategy
**Pros**: Tailored to specific requirements
**Cons**: Complex implementation, maintenance overhead
**Decision**: Considered but decided on hybrid approach for simplicity

## Implementation Notes

### Phase 1: Core Sharding (Months 1-2)
1. **Hash-based Sharding**: Implement for user data
2. **Range-based Sharding**: Implement for product data
3. **Basic Monitoring**: Implement basic shard monitoring
4. **Testing**: Comprehensive testing of sharding

### Phase 2: Advanced Sharding (Months 3-4)
1. **Time-based Sharding**: Implement for order data
2. **Geographic Sharding**: Implement for analytics data
3. **Shard Rebalancing**: Implement automatic rebalancing
4. **Advanced Monitoring**: Implement comprehensive monitoring

### Phase 3: Optimization and Monitoring (Months 5-6)
1. **Performance Tuning**: Optimize sharding performance
2. **Monitoring**: Implement comprehensive monitoring
3. **Alerting**: Implement shard alerting
4. **Documentation**: Complete documentation and training

### Shard Management Strategy
1. **Automated Rebalancing**: Implement automatic shard rebalancing
2. **Health Monitoring**: Monitor shard health and performance
3. **Failover**: Implement shard failover mechanisms
4. **Backup**: Implement shard backup and recovery

### Monitoring and Alerting
1. **Shard Metrics**: Monitor shard performance and health
2. **Rebalancing Alerts**: Alert on shard imbalance
3. **Failure Detection**: Detect and alert on shard failures
4. **Performance Metrics**: Track sharding performance

## Related ADRs

- [ADR-04-001: Database Technology Selection](./database-technology-selection.md)
- [ADR-04-002: Data Consistency Model](./data-consistency-model.md)
- [ADR-04-004: Caching Architecture](./caching-architecture.md)
- [ADR-04-005: Data Migration Strategy](./data-migration-strategy.md)

## Review History

- **2024-01-15**: Initial decision made
- **2024-01-20**: Added implementation notes
- **2024-01-25**: Added risk mitigation strategies
- **2024-02-01**: Updated with monitoring considerations

---

**Next Review Date**: 2024-04-15
**Owner**: Database Architecture Team
**Stakeholders**: Development Team, Operations Team, Product Team
