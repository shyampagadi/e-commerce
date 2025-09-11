# Database Sharding and Partitioning Strategies

## Overview

Database sharding and partitioning are essential techniques for scaling databases horizontally to handle massive data volumes and high transaction rates. These strategies distribute data across multiple database instances or servers, enabling linear scalability and improved performance.

## 1. Database Sharding

### Definition
Sharding is the process of horizontally partitioning data across multiple database instances (shards), where each shard contains a subset of the total data and operates independently.

### Sharding Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    SHARDED DATABASE ARCHITECTURE           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Application Layer                    │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Shard     │    │   Shard     │    │  Shard  │  │    │
│  │  │  Router     │    │  Manager    │    │ Monitor │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Shard Layer                          │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Shard 1   │    │   Shard 2   │    │ Shard 3 │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Users 1-3M│    │ - Users 3-6M│    │ - Users │  │    │
│  │  │ - Orders 1-3M│   │ - Orders 3-6M│   │ 6-9M    │  │    │
│  │  │ - Products 1-3M│ │ - Products 3-6M│ │ - Orders│  │    │
│  │  └─────────────┘    └─────────────┘    │ 6-9M    │  │    │
│  │                                         │ - Products│  │    │
│  │                                         │ 6-9M    │  │    │
│  │                                         └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Sharding Strategies

#### 1. Horizontal Sharding
```sql
-- Shard by user_id range
-- Shard 1: user_id 1-1,000,000
-- Shard 2: user_id 1,000,001-2,000,000
-- Shard 3: user_id 2,000,001-3,000,000

-- Shard routing logic
SELECT shard_id FROM shard_mapping 
WHERE user_id BETWEEN shard_start AND shard_end;
```

#### 2. Vertical Sharding
```sql
-- Shard by table/feature
-- Shard 1: User data (users, profiles, preferences)
-- Shard 2: Order data (orders, order_items, payments)
-- Shard 3: Product data (products, categories, inventory)

-- Application routing
if (table_name in ['users', 'profiles', 'preferences']) {
    route_to_shard('user_shard');
} else if (table_name in ['orders', 'order_items', 'payments']) {
    route_to_shard('order_shard');
} else if (table_name in ['products', 'categories', 'inventory']) {
    route_to_shard('product_shard');
}
```

#### 3. Functional Sharding
```sql
-- Shard by business function
-- Shard 1: E-commerce (products, orders, payments)
-- Shard 2: User management (users, profiles, authentication)
-- Shard 3: Analytics (events, metrics, reports)

-- Service-based routing
if (service_name == 'ecommerce') {
    route_to_shard('ecommerce_shard');
} else if (service_name == 'user_management') {
    route_to_shard('user_shard');
} else if (service_name == 'analytics') {
    route_to_shard('analytics_shard');
}
```

#### 4. Directory-Based Sharding
```sql
-- Shard mapping table
CREATE TABLE shard_mapping (
    shard_key VARCHAR(100) PRIMARY KEY,
    shard_id INT NOT NULL,
    shard_host VARCHAR(100) NOT NULL,
    shard_port INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shard lookup
SELECT shard_id, shard_host, shard_port 
FROM shard_mapping 
WHERE shard_key = ?;
```

### Consistent Hashing
```python
import hashlib
import bisect

class ConsistentHash:
    def __init__(self, nodes, replicas=3):
        self.replicas = replicas
        self.ring = {}
        self.sorted_keys = []
        
        for node in nodes:
            self.add_node(node)
    
    def add_node(self, node):
        for i in range(self.replicas):
            key = self._hash(f"{node}:{i}")
            self.ring[key] = node
            self.sorted_keys.append(key)
        
        self.sorted_keys.sort()
    
    def remove_node(self, node):
        for i in range(self.replicas):
            key = self._hash(f"{node}:{i}")
            if key in self.ring:
                del self.ring[key]
                self.sorted_keys.remove(key)
    
    def get_node(self, key):
        if not self.ring:
            return None
        
        hash_key = self._hash(key)
        idx = bisect.bisect_right(self.sorted_keys, hash_key)
        if idx == len(self.sorted_keys):
            idx = 0
        
        return self.ring[self.sorted_keys[idx]]
    
    def _hash(self, key):
        return int(hashlib.md5(key.encode()).hexdigest(), 16)
```

### Shard Rebalancing
```python
class ShardRebalancer:
    def __init__(self, shards):
        self.shards = shards
        self.rebalance_threshold = 0.1  # 10% imbalance threshold
    
    def check_rebalance_needed(self):
        sizes = [shard.get_size() for shard in self.shards]
        avg_size = sum(sizes) / len(sizes)
        
        for size in sizes:
            if abs(size - avg_size) / avg_size > self.rebalance_threshold:
                return True
        return False
    
    def rebalance(self):
        if not self.check_rebalance_needed():
            return
        
        # Calculate target sizes
        total_size = sum(shard.get_size() for shard in self.shards)
        target_size = total_size // len(self.shards)
        
        # Move data between shards
        for shard in self.shards:
            if shard.get_size() > target_size:
                excess = shard.get_size() - target_size
                self._move_data(shard, excess)
    
    def _move_data(self, source_shard, amount):
        # Implementation for moving data between shards
        pass
```

## 2. Database Partitioning

### Definition
Partitioning is the process of dividing a large table into smaller, more manageable pieces (partitions) within the same database instance, improving query performance and maintenance.

### Partitioning Types

#### 1. Range Partitioning
```sql
-- Partition by date range
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    customer_id INT,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

-- Create partitions
CREATE TABLE sales_2023_q1 PARTITION OF sales
    FOR VALUES FROM ('2023-01-01') TO ('2023-04-01');

CREATE TABLE sales_2023_q2 PARTITION OF sales
    FOR VALUES FROM ('2023-04-01') TO ('2023-07-01');

CREATE TABLE sales_2023_q3 PARTITION OF sales
    FOR VALUES FROM ('2023-07-01') TO ('2023-10-01');

CREATE TABLE sales_2023_q4 PARTITION OF sales
    FOR VALUES FROM ('2023-10-01') TO ('2024-01-01');
```

#### 2. Hash Partitioning
```sql
-- Partition by hash of user_id
CREATE TABLE user_events (
    event_id INT,
    user_id INT,
    event_type VARCHAR(50),
    event_data JSONB,
    created_at TIMESTAMP
) PARTITION BY HASH (user_id);

-- Create hash partitions
CREATE TABLE user_events_0 PARTITION OF user_events
    FOR VALUES WITH (modulus 4, remainder 0);

CREATE TABLE user_events_1 PARTITION OF user_events
    FOR VALUES WITH (modulus 4, remainder 1);

CREATE TABLE user_events_2 PARTITION OF user_events
    FOR VALUES WITH (modulus 4, remainder 2);

CREATE TABLE user_events_3 PARTITION OF user_events
    FOR VALUES WITH (modulus 4, remainder 3);
```

#### 3. List Partitioning
```sql
-- Partition by region
CREATE TABLE customers (
    customer_id INT,
    customer_name VARCHAR(100),
    region VARCHAR(50),
    country VARCHAR(50)
) PARTITION BY LIST (region);

-- Create list partitions
CREATE TABLE customers_north_america PARTITION OF customers
    FOR VALUES IN ('US', 'Canada', 'Mexico');

CREATE TABLE customers_europe PARTITION OF customers
    FOR VALUES IN ('UK', 'Germany', 'France', 'Italy');

CREATE TABLE customers_asia PARTITION OF customers
    FOR VALUES IN ('Japan', 'China', 'India', 'South Korea');
```

#### 4. Composite Partitioning
```sql
-- Composite partitioning: range + hash
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    quantity INT,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

-- Create range partitions
CREATE TABLE orders_2023 PARTITION OF orders
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01')
    PARTITION BY HASH (customer_id);

-- Create hash sub-partitions
CREATE TABLE orders_2023_0 PARTITION OF orders_2023
    FOR VALUES WITH (modulus 4, remainder 0);

CREATE TABLE orders_2023_1 PARTITION OF orders_2023
    FOR VALUES WITH (modulus 4, remainder 1);

CREATE TABLE orders_2023_2 PARTITION OF orders_2023
    FOR VALUES WITH (modulus 4, remainder 2);

CREATE TABLE orders_2023_3 PARTITION OF orders_2023
    FOR VALUES WITH (modulus 4, remainder 3);
```

### Dynamic Partitioning
```sql
-- Automatic partition creation
CREATE OR REPLACE FUNCTION create_monthly_partition(table_name text, start_date date)
RETURNS void AS $$
DECLARE
    partition_name text;
    end_date date;
BEGIN
    partition_name := table_name || '_' || to_char(start_date, 'YYYY_MM');
    end_date := start_date + interval '1 month';
    
    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF %I
                    FOR VALUES FROM (%L) TO (%L)',
                   partition_name, table_name, start_date, end_date);
END;
$$ LANGUAGE plpgsql;

-- Create partitions for the next 12 months
DO $$
DECLARE
    i integer;
    start_date date;
BEGIN
    FOR i IN 0..11 LOOP
        start_date := date_trunc('month', CURRENT_DATE) + (i || ' months')::interval;
        PERFORM create_monthly_partition('sales', start_date);
    END LOOP;
END $$;
```

## 3. Sharding vs Partitioning

### Comparison Table
| Aspect | Sharding | Partitioning |
|--------|----------|--------------|
| **Scope** | Multiple database instances | Single database instance |
| **Complexity** | High | Medium |
| **Scalability** | Linear (horizontal) | Limited (vertical) |
| **Query Performance** | Depends on shard distribution | Generally better |
| **Cross-Shard Queries** | Complex | Not applicable |
| **Data Consistency** | Eventual consistency | ACID properties |
| **Maintenance** | Complex | Simpler |
| **Cost** | Higher (multiple instances) | Lower (single instance) |

### When to Use Sharding
- **Massive Data Volume**: When single database can't handle data size
- **High Transaction Rate**: When single database can't handle load
- **Geographic Distribution**: When data needs to be close to users
- **Independent Scaling**: When different data types scale differently

### When to Use Partitioning
- **Large Tables**: When single table becomes too large
- **Query Performance**: When queries can be optimized with partitioning
- **Maintenance**: When table maintenance becomes difficult
- **Data Lifecycle**: When data has natural time-based boundaries

## 4. Implementation Patterns

### Shard Router Pattern
```python
class ShardRouter:
    def __init__(self, shards):
        self.shards = shards
        self.consistent_hash = ConsistentHash(shards)
    
    def get_shard(self, key):
        return self.consistent_hash.get_node(key)
    
    def execute_query(self, query, params):
        shard = self.get_shard(params.get('shard_key'))
        return shard.execute(query, params)
    
    def execute_cross_shard_query(self, query, params):
        results = []
        for shard in self.shards:
            result = shard.execute(query, params)
            results.extend(result)
        return results
```

### Shard Manager Pattern
```python
class ShardManager:
    def __init__(self):
        self.shards = {}
        self.shard_health = {}
    
    def add_shard(self, shard_id, shard_config):
        self.shards[shard_id] = shard_config
        self.shard_health[shard_id] = 'healthy'
    
    def remove_shard(self, shard_id):
        if shard_id in self.shards:
            del self.shards[shard_id]
            del self.shard_health[shard_id]
    
    def get_healthy_shards(self):
        return [shard_id for shard_id, health in self.shard_health.items() 
                if health == 'healthy']
    
    def mark_shard_unhealthy(self, shard_id):
        if shard_id in self.shard_health:
            self.shard_health[shard_id] = 'unhealthy'
    
    def rebalance_data(self):
        # Implementation for data rebalancing
        pass
```

### Partition Manager Pattern
```python
class PartitionManager:
    def __init__(self, connection):
        self.connection = connection
    
    def create_partition(self, table_name, partition_name, partition_condition):
        query = f"""
        CREATE TABLE {partition_name} PARTITION OF {table_name}
        FOR VALUES {partition_condition}
        """
        self.connection.execute(query)
    
    def drop_partition(self, partition_name):
        query = f"DROP TABLE {partition_name}"
        self.connection.execute(query)
    
    def get_partition_info(self, table_name):
        query = """
        SELECT schemaname, tablename, partitionbounddef
        FROM pg_partitions
        WHERE tablename = %s
        """
        return self.connection.fetch_all(query, (table_name,))
    
    def auto_create_partitions(self, table_name, partition_type, interval):
        # Implementation for automatic partition creation
        pass
```

## 5. Best Practices

### Sharding Best Practices
1. **Choose the Right Shard Key**: Select a key that distributes data evenly
2. **Avoid Cross-Shard Queries**: Design queries to work within single shards
3. **Implement Shard Monitoring**: Monitor shard health and performance
4. **Plan for Rebalancing**: Design for data movement between shards
5. **Handle Shard Failures**: Implement failover and recovery mechanisms

### Partitioning Best Practices
1. **Choose the Right Partition Key**: Select a key that matches query patterns
2. **Size Partitions Appropriately**: Balance partition size for performance
3. **Use Partition Pruning**: Design queries to leverage partition elimination
4. **Monitor Partition Performance**: Track partition-level metrics
5. **Plan for Partition Maintenance**: Implement partition lifecycle management

### Common Pitfalls
1. **Hot Spots**: Uneven data distribution causing performance issues
2. **Cross-Shard Dependencies**: Complex relationships between shards
3. **Data Skew**: Uneven partition sizes affecting performance
4. **Query Complexity**: Overly complex queries that don't leverage partitioning
5. **Maintenance Overhead**: High operational complexity

## 6. Monitoring and Maintenance

### Shard Monitoring
```python
class ShardMonitor:
    def __init__(self, shards):
        self.shards = shards
        self.metrics = {}
    
    def collect_metrics(self):
        for shard_id, shard in self.shards.items():
            metrics = {
                'connection_count': shard.get_connection_count(),
                'query_performance': shard.get_avg_query_time(),
                'disk_usage': shard.get_disk_usage(),
                'cpu_usage': shard.get_cpu_usage(),
                'memory_usage': shard.get_memory_usage()
            }
            self.metrics[shard_id] = metrics
    
    def check_health(self):
        unhealthy_shards = []
        for shard_id, metrics in self.metrics.items():
            if (metrics['connection_count'] > 1000 or
                metrics['query_performance'] > 1000 or
                metrics['disk_usage'] > 0.9):
                unhealthy_shards.append(shard_id)
        return unhealthy_shards
    
    def generate_report(self):
        report = {
            'total_shards': len(self.shards),
            'healthy_shards': len(self.shards) - len(self.check_health()),
            'metrics': self.metrics
        }
        return report
```

### Partition Maintenance
```python
class PartitionMaintenance:
    def __init__(self, connection):
        self.connection = connection
    
    def archive_old_partitions(self, table_name, retention_days):
        query = """
        SELECT schemaname, tablename
        FROM pg_partitions
        WHERE tablename LIKE %s
        AND partitionbounddef LIKE %s
        """
        old_partitions = self.connection.fetch_all(
            query, (f"{table_name}_%", f"%< '{retention_days} days ago'%")
        )
        
        for partition in old_partitions:
            self.archive_partition(partition['tablename'])
    
    def archive_partition(self, partition_name):
        # Move partition to archive storage
        archive_query = f"ALTER TABLE {partition_name} SET TABLESPACE archive_tablespace"
        self.connection.execute(archive_query)
    
    def vacuum_partitions(self, table_name):
        query = f"VACUUM ANALYZE {table_name}"
        self.connection.execute(query)
```

## Conclusion

Database sharding and partitioning are essential techniques for scaling databases to handle massive data volumes and high transaction rates. The choice between sharding and partitioning depends on your specific requirements:

- **Use Sharding** when you need horizontal scalability across multiple database instances
- **Use Partitioning** when you need to optimize performance within a single database instance

Both techniques require careful planning, monitoring, and maintenance to ensure optimal performance and reliability. The key is to choose the right strategy based on your data patterns, query requirements, and scalability needs.

