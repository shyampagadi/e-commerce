# ADR-04-004: Caching Architecture

## Status
Accepted

## Date
2024-01-15

## Context

We need to implement a comprehensive caching architecture for our multi-tenant e-commerce platform that will serve millions of users globally. The platform requires multiple levels of caching to handle:

- **User Data**: 50M+ users with varying access patterns
- **Product Data**: 100M+ products with different access frequencies
- **Order Data**: 1M+ orders per day with time-based access patterns
- **Search Data**: Real-time search with high query volumes
- **Session Data**: User sessions and shopping carts
- **Analytics Data**: Real-time analytics and reporting

The platform must handle:
- 50M+ users globally
- 100M+ products
- 1M+ orders per day
- 10K+ transactions per second
- 99.99% availability
- Sub-second response times

## Decision

Implement a multi-layer caching architecture that uses different caching strategies for different data types and access patterns:

### Caching Architecture Overview
```
┌─────────────────────────────────────────────────────────────┐
│                MULTI-LAYER CACHING ARCHITECTURE           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Application Layer                    │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Web       │    │   API       │    │  Mobile │  │    │
│  │  │  Server     │    │  Server     │    │   App   │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Caching Layer                       │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   CDN       │    │   Redis     │    │  Local  │  │    │
│  │  │   Cache     │    │   Cluster   │    │  Cache  │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Static    │    │ - Session   │    │ - Query │  │    │
│  │  │ - Images    │    │ - User Data │    │ - Result│  │    │
│  │  │ - CSS/JS    │    │ - Product   │    │ - Temp  │  │    │
│  │  │ - API       │    │ - Search    │    │ - Data  │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Database Layer                       │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │PostgreSQL   │    │   MongoDB   │    │Elasticsearch│  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Users     │    │ - Products  │    │ - Search│  │    │
│  │  │ - Orders    │    │ - Content   │    │ - Logs  │  │    │
│  │  │ - Payments  │    │ - Metadata  │    │ - Analytics│  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Caching Strategy Matrix
| Data Type | Cache Layer | TTL | Strategy | Justification |
|-----------|-------------|-----|----------|---------------|
| User Sessions | Redis | 1 hour | Write-through | Real-time access, session management |
| User Profiles | Redis | 30 minutes | Write-behind | Frequently accessed, user experience |
| Product Data | Redis | 1 hour | Write-through | Product catalog, search performance |
| Search Results | Redis | 15 minutes | Write-behind | Search performance, query optimization |
| Static Content | CDN | 24 hours | Write-through | Global distribution, performance |
| API Responses | CDN | 5 minutes | Write-behind | API performance, global distribution |
| Query Results | Local | 5 minutes | Write-behind | Database performance, query optimization |
| Analytics Data | Redis | 1 hour | Write-behind | Real-time analytics, reporting |

### Caching Implementation

#### 1. CDN Caching (CloudFront)
```python
import boto3
from botocore.exceptions import ClientError

class CDNCacheManager:
    def __init__(self, cloudfront_client, s3_client):
        self.cloudfront = cloudfront_client
        self.s3 = s3_client
        self.distribution_id = 'E1234567890ABC'
    
    def cache_static_content(self, content_path, content_data, ttl=86400):
        """Cache static content in CDN"""
        try:
            # Upload to S3
            self.s3.put_object(
                Bucket='static-content-bucket',
                Key=content_path,
                Body=content_data,
                ContentType='text/html',
                CacheControl=f'max-age={ttl}'
            )
            
            # Invalidate CDN cache
            self.cloudfront.create_invalidation(
                DistributionId=self.distribution_id,
                InvalidationBatch={
                    'Paths': {
                        'Quantity': 1,
                        'Items': [f'/{content_path}']
                    },
                    'CallerReference': str(uuid.uuid4())
                }
            )
            
            return True
        except ClientError as e:
            print(f"Error caching static content: {e}")
            return False
    
    def cache_api_response(self, api_path, response_data, ttl=300):
        """Cache API response in CDN"""
        try:
            # Upload to S3
            self.s3.put_object(
                Bucket='api-cache-bucket',
                Key=api_path,
                Body=json.dumps(response_data),
                ContentType='application/json',
                CacheControl=f'max-age={ttl}'
            )
            
            return True
        except ClientError as e:
            print(f"Error caching API response: {e}")
            return False
    
    def get_cached_content(self, content_path):
        """Get cached content from CDN"""
        try:
            response = self.s3.get_object(
                Bucket='static-content-bucket',
                Key=content_path
            )
            return response['Body'].read()
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchKey':
                return None
            raise
```

#### 2. Redis Caching
```python
import redis
import json
import time
from functools import wraps

class RedisCacheManager:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def cache_user_session(self, session_id, session_data, ttl=3600):
        """Cache user session data"""
        key = f"session:{session_id}"
        self.redis.setex(key, ttl, json.dumps(session_data))
    
    def get_user_session(self, session_id):
        """Get user session data"""
        key = f"session:{session_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def cache_user_profile(self, user_id, profile_data, ttl=1800):
        """Cache user profile data"""
        key = f"user_profile:{user_id}"
        self.redis.setex(key, ttl, json.dumps(profile_data))
    
    def get_user_profile(self, user_id):
        """Get user profile data"""
        key = f"user_profile:{user_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def cache_product_data(self, product_id, product_data, ttl=3600):
        """Cache product data"""
        key = f"product:{product_id}"
        self.redis.setex(key, ttl, json.dumps(product_data))
    
    def get_product_data(self, product_id):
        """Get product data"""
        key = f"product:{product_id}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def cache_search_results(self, search_query, results, ttl=900):
        """Cache search results"""
        key = f"search:{hash(search_query)}"
        self.redis.setex(key, ttl, json.dumps(results))
    
    def get_search_results(self, search_query):
        """Get search results"""
        key = f"search:{hash(search_query)}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
    
    def cache_analytics_data(self, metric_name, data, ttl=3600):
        """Cache analytics data"""
        key = f"analytics:{metric_name}"
        self.redis.setex(key, ttl, json.dumps(data))
    
    def get_analytics_data(self, metric_name):
        """Get analytics data"""
        key = f"analytics:{metric_name}"
        data = self.redis.get(key)
        if data:
            return json.loads(data)
        return None
```

#### 3. Local Caching
```python
from functools import lru_cache
import time

class LocalCacheManager:
    def __init__(self, max_size=1000, default_ttl=300):
        self.cache = {}
        self.max_size = max_size
        self.default_ttl = default_ttl
    
    def get(self, key):
        """Get value from local cache"""
        if key in self.cache:
            value, timestamp = self.cache[key]
            if time.time() - timestamp < self.default_ttl:
                return value
            else:
                del self.cache[key]
        return None
    
    def set(self, key, value, ttl=None):
        """Set value in local cache"""
        if len(self.cache) >= self.max_size:
            # Remove oldest entry
            oldest_key = min(self.cache.keys(), key=lambda k: self.cache[k][1])
            del self.cache[oldest_key]
        
        ttl = ttl or self.default_ttl
        self.cache[key] = (value, time.time() + ttl)
    
    def delete(self, key):
        """Delete value from local cache"""
        if key in self.cache:
            del self.cache[key]
    
    def clear(self):
        """Clear all values from local cache"""
        self.cache.clear()
    
    def size(self):
        """Get cache size"""
        return len(self.cache)

# Decorator for local caching
def local_cache(ttl=300):
    def decorator(func):
        cache = LocalCacheManager(default_ttl=ttl)
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            key = f"{func.__name__}:{hash(str(args) + str(kwargs))}"
            result = cache.get(key)
            if result is None:
                result = func(*args, **kwargs)
                cache.set(key, result, ttl)
            return result
        return wrapper
    return decorator
```

#### 4. Write-Through Caching
```python
class WriteThroughCache:
    def __init__(self, cache_manager, database_client):
        self.cache = cache_manager
        self.db = database_client
    
    def write(self, key, value, ttl=3600):
        """Write to cache and database"""
        # Write to database first
        self.db.write(key, value)
        
        # Write to cache
        self.cache.set(key, value, ttl)
    
    def read(self, key):
        """Read from cache or database"""
        # Try cache first
        result = self.cache.get(key)
        if result is not None:
            return result
        
        # Read from database
        result = self.db.read(key)
        if result is not None:
            # Update cache
            self.cache.set(key, result)
        
        return result
    
    def delete(self, key):
        """Delete from cache and database"""
        # Delete from database
        self.db.delete(key)
        
        # Delete from cache
        self.cache.delete(key)
```

#### 5. Write-Behind Caching
```python
import threading
import queue
import time

class WriteBehindCache:
    def __init__(self, cache_manager, database_client, batch_size=100, flush_interval=60):
        self.cache = cache_manager
        self.db = database_client
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.write_queue = queue.Queue()
        self.running = True
        
        # Start background thread
        self.worker_thread = threading.Thread(target=self._worker)
        self.worker_thread.daemon = True
        self.worker_thread.start()
    
    def write(self, key, value, ttl=3600):
        """Write to cache immediately, queue for database"""
        # Write to cache immediately
        self.cache.set(key, value, ttl)
        
        # Queue for database write
        self.write_queue.put((key, value))
    
    def read(self, key):
        """Read from cache or database"""
        # Try cache first
        result = self.cache.get(key)
        if result is not None:
            return result
        
        # Read from database
        result = self.db.read(key)
        if result is not None:
            # Update cache
            self.cache.set(key, result)
        
        return result
    
    def delete(self, key):
        """Delete from cache and database"""
        # Delete from cache immediately
        self.cache.delete(key)
        
        # Queue for database delete
        self.write_queue.put(('DELETE', key))
    
    def _worker(self):
        """Background worker for database writes"""
        batch = []
        last_flush = time.time()
        
        while self.running:
            try:
                # Get item from queue with timeout
                item = self.write_queue.get(timeout=1)
                batch.append(item)
                
                # Flush if batch is full or time interval passed
                if (len(batch) >= self.batch_size or 
                    time.time() - last_flush >= self.flush_interval):
                    self._flush_batch(batch)
                    batch = []
                    last_flush = time.time()
                    
            except queue.Empty:
                # Flush any remaining items
                if batch:
                    self._flush_batch(batch)
                    batch = []
                    last_flush = time.time()
    
    def _flush_batch(self, batch):
        """Flush batch to database"""
        for item in batch:
            if item[0] == 'DELETE':
                self.db.delete(item[1])
            else:
                key, value = item
                self.db.write(key, value)
    
    def stop(self):
        """Stop the worker thread"""
        self.running = False
        self.worker_thread.join()
```

### Cache Invalidation Strategy

#### Cache Invalidation Manager
```python
class CacheInvalidationManager:
    def __init__(self, cache_managers):
        self.cache_managers = cache_managers
    
    def invalidate_user_data(self, user_id):
        """Invalidate all user-related cache"""
        patterns = [
            f"user_profile:{user_id}",
            f"user_session:{user_id}",
            f"user_preferences:{user_id}",
            f"user_orders:{user_id}"
        ]
        
        for pattern in patterns:
            for cache_manager in self.cache_managers:
                cache_manager.delete(pattern)
    
    def invalidate_product_data(self, product_id):
        """Invalidate all product-related cache"""
        patterns = [
            f"product:{product_id}",
            f"product_reviews:{product_id}",
            f"product_recommendations:{product_id}",
            f"search:*"  # Invalidate all search results
        ]
        
        for pattern in patterns:
            for cache_manager in self.cache_managers:
                if pattern.endswith('*'):
                    cache_manager.delete_pattern(pattern)
                else:
                    cache_manager.delete(pattern)
    
    def invalidate_category_data(self, category_id):
        """Invalidate all category-related cache"""
        patterns = [
            f"category:{category_id}",
            f"category_products:{category_id}",
            f"search:*"  # Invalidate all search results
        ]
        
        for pattern in patterns:
            for cache_manager in self.cache_managers:
                if pattern.endswith('*'):
                    cache_manager.delete_pattern(pattern)
                else:
                    cache_manager.delete(pattern)
    
    def invalidate_all_cache(self):
        """Invalidate all cache"""
        for cache_manager in self.cache_managers:
            cache_manager.clear()
```

### Cache Monitoring

#### Cache Performance Monitoring
```python
class CacheMonitoring:
    def __init__(self, cache_managers):
        self.cache_managers = cache_managers
        self.metrics = {}
    
    def collect_metrics(self):
        """Collect cache performance metrics"""
        for i, cache_manager in enumerate(self.cache_managers):
            metrics = {
                'hit_rate': cache_manager.get_hit_rate(),
                'miss_rate': cache_manager.get_miss_rate(),
                'memory_usage': cache_manager.get_memory_usage(),
                'connection_count': cache_manager.get_connection_count(),
                'response_time': cache_manager.get_avg_response_time()
            }
            self.metrics[f'cache_{i}'] = metrics
    
    def get_hit_rate(self, cache_name):
        """Get hit rate for specific cache"""
        return self.metrics.get(cache_name, {}).get('hit_rate', 0)
    
    def get_miss_rate(self, cache_name):
        """Get miss rate for specific cache"""
        return self.metrics.get(cache_name, {}).get('miss_rate', 0)
    
    def get_memory_usage(self, cache_name):
        """Get memory usage for specific cache"""
        return self.metrics.get(cache_name, {}).get('memory_usage', 0)
    
    def generate_report(self):
        """Generate cache performance report"""
        report = {
            'total_caches': len(self.cache_managers),
            'metrics': self.metrics,
            'overall_hit_rate': self._calculate_overall_hit_rate(),
            'overall_memory_usage': self._calculate_overall_memory_usage()
        }
        return report
    
    def _calculate_overall_hit_rate(self):
        """Calculate overall hit rate across all caches"""
        total_hits = sum(metrics.get('hit_rate', 0) for metrics in self.metrics.values())
        total_requests = sum(metrics.get('hit_rate', 0) + metrics.get('miss_rate', 0) 
                           for metrics in self.metrics.values())
        return total_hits / total_requests if total_requests > 0 else 0
    
    def _calculate_overall_memory_usage(self):
        """Calculate overall memory usage across all caches"""
        return sum(metrics.get('memory_usage', 0) for metrics in self.metrics.values())
```

## Rationale

### Why Multi-Layer Caching Architecture?
1. **Performance Optimization**: Different cache layers for different data types
2. **Scalability**: Better scalability through distributed caching
3. **Cost Efficiency**: Optimized resource usage across layers
4. **User Experience**: Improved user experience through faster responses
5. **Global Distribution**: CDN caching for global performance

### Caching Strategy Justifications

#### CDN Caching for Static Content
- **Global Distribution**: Content served from edge locations
- **Performance**: Reduced latency for static content
- **Cost Efficiency**: Reduced bandwidth costs
- **Scalability**: Handles high traffic volumes

#### Redis Caching for Dynamic Data
- **High Performance**: Sub-millisecond response times
- **Data Structures**: Rich data types for complex caching
- **Persistence**: Optional persistence for critical data
- **Clustering**: High availability and scaling

#### Local Caching for Query Results
- **Ultra-fast Access**: In-memory access for frequently used data
- **Reduced Network**: No network overhead for local data
- **Cost Efficiency**: Reduced external cache usage
- **Simplicity**: Simple implementation and management

### Cache Strategy Justifications

#### Write-Through for Critical Data
- **Data Consistency**: Immediate consistency with database
- **Data Safety**: No data loss on cache failures
- **Simple Implementation**: Easy to understand and implement
- **Reliability**: Guaranteed data persistence

#### Write-Behind for Non-Critical Data
- **High Performance**: Fast cache writes
- **Batch Processing**: Efficient database writes
- **Scalability**: Better scalability for high write volumes
- **Cost Efficiency**: Reduced database load

## Consequences

### Positive Consequences
- **Performance**: Significant performance improvements
- **Scalability**: Better scalability through distributed caching
- **User Experience**: Improved user experience through faster responses
- **Cost Efficiency**: Optimized resource usage
- **Global Performance**: CDN caching for global performance

### Negative Consequences
- **Complexity**: More complex caching management
- **Data Consistency**: Potential consistency issues
- **Cache Invalidation**: Complex cache invalidation logic
- **Monitoring Complexity**: More complex monitoring and alerting
- **Team Learning**: Steeper learning curve for developers

### Risks and Mitigations
- **Risk**: Cache inconsistency
  - **Mitigation**: Implement proper cache invalidation and synchronization
- **Risk**: Cache failures
  - **Mitigation**: Implement cache failover and fallback mechanisms
- **Risk**: Memory usage
  - **Mitigation**: Implement cache eviction policies and monitoring
- **Risk**: Cache invalidation complexity
  - **Mitigation**: Implement automated cache invalidation strategies

## Alternatives Considered

### Alternative 1: Single Cache Layer
**Pros**: Simple implementation, easy to understand
**Cons**: Not optimized for different use cases
**Decision**: Rejected due to performance implications

### Alternative 2: No Caching
**Pros**: Simple implementation, no complexity
**Cons**: Poor performance, high costs
**Decision**: Rejected due to performance requirements

### Alternative 3: Database Caching Only
**Pros**: Simple implementation, database-managed
**Cons**: Limited performance improvements
**Decision**: Rejected due to performance requirements

### Alternative 4: Custom Caching Solution
**Pros**: Tailored to specific requirements
**Cons**: Complex implementation, maintenance overhead
**Decision**: Considered but decided on multi-layer approach for simplicity

## Implementation Notes

### Phase 1: Core Caching (Months 1-2)
1. **Redis Caching**: Implement for user and product data
2. **Local Caching**: Implement for query results
3. **Basic Monitoring**: Implement basic cache monitoring
4. **Testing**: Comprehensive testing of caching

### Phase 2: Advanced Caching (Months 3-4)
1. **CDN Caching**: Implement for static content and API responses
2. **Write-Behind Caching**: Implement for non-critical data
3. **Cache Invalidation**: Implement automated cache invalidation
4. **Advanced Monitoring**: Implement comprehensive monitoring

### Phase 3: Optimization and Monitoring (Months 5-6)
1. **Performance Tuning**: Optimize cache performance
2. **Monitoring**: Implement comprehensive monitoring
3. **Alerting**: Implement cache alerting
4. **Documentation**: Complete documentation and training

### Cache Management Strategy
1. **Automated Invalidation**: Implement automated cache invalidation
2. **Health Monitoring**: Monitor cache health and performance
3. **Failover**: Implement cache failover mechanisms
4. **Backup**: Implement cache backup and recovery

### Monitoring and Alerting
1. **Cache Metrics**: Monitor cache performance and health
2. **Hit Rate Alerts**: Alert on low hit rates
3. **Memory Usage Alerts**: Alert on high memory usage
4. **Performance Metrics**: Track cache performance

## Related ADRs

- [ADR-04-001: Database Technology Selection](./database-technology-selection.md)
- [ADR-04-002: Data Consistency Model](./data-consistency-model.md)
- [ADR-04-003: Database Sharding Strategy](./database-sharding-strategy.md)
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
