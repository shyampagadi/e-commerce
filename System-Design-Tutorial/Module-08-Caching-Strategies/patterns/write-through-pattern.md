# Write-Through Pattern

## Pattern Information
- **Category**: Cache Architecture Patterns
- **Intent**: Write data to both cache and data store simultaneously
- **Also Known As**: Write-Through Caching, Synchronous Write-Through

## Problem

### Context
When building applications that require immediate consistency between cache and data store, you need a write strategy that ensures both systems are updated atomically.

### Problem
- Need to keep cache and data store in perfect sync
- Write operations must be consistent across both systems
- Cannot tolerate stale data in cache
- Need immediate consistency for critical operations
- Want to ensure data is always available after write

### Forces
- Consistency requirements demand immediate updates
- Cache and database must always be synchronized
- Write operations must be atomic
- Performance may be impacted by synchronous writes
- Error handling must be comprehensive

## Solution

### Structure
The Write-Through pattern updates both cache and data store in the same operation:

```
Client Write Request
         ↓
    Update Database
         ↓
    Update Cache
         ↓
    Return Success
```

### Implementation
The application follows these steps:
1. **Write to Database**: Update the primary data store first
2. **Write to Cache**: Update the cache with the same data
3. **Handle Errors**: Rollback if either operation fails
4. **Return Success**: Confirm successful update to client

### Key Components
- **Database Client**: Interface to primary data store
- **Cache Client**: Interface to cache system
- **Transaction Manager**: Handles rollback operations
- **Error Handler**: Manages failure scenarios
- **Consistency Checker**: Validates data consistency

## Examples

### Basic Implementation
```python
class WriteThroughService:
    def __init__(self, cache_client, database_client):
        self.cache = cache_client
        self.db = database_client
        self.default_ttl = 3600
    
    def update_user(self, user_id, user_data):
        try:
            # Step 1: Update database
            self.db.update_user(user_id, user_data)
            
            # Step 2: Update cache
            cache_key = f"user:{user_id}"
            self.cache.setex(cache_key, self.default_ttl, json.dumps(user_data))
            
            return True
        except Exception as e:
            # Rollback database if cache update fails
            self.db.rollback_user_update(user_id)
            raise e
    
    def create_user(self, user_data):
        try:
            # Step 1: Create in database
            user_id = self.db.create_user(user_data)
            
            # Step 2: Update cache
            cache_key = f"user:{user_id}"
            self.cache.setex(cache_key, self.default_ttl, json.dumps(user_data))
            
            return user_id
        except Exception as e:
            # Rollback database if cache update fails
            self.db.rollback_user_creation(user_id)
            raise e
```

### Advanced Implementation with Transaction Support
```python
class TransactionalWriteThroughService:
    def __init__(self, cache_client, database_client, transaction_manager):
        self.cache = cache_client
        self.db = database_client
        self.transaction_manager = transaction_manager
        self.default_ttl = 3600
    
    def update_user_with_transaction(self, user_id, user_data):
        transaction_id = self.transaction_manager.begin_transaction()
        
        try:
            # Step 1: Update database
            self.db.update_user(user_id, user_data, transaction_id)
            
            # Step 2: Update cache
            cache_key = f"user:{user_id}"
            self.cache.setex(cache_key, self.default_ttl, json.dumps(user_data))
            
            # Commit transaction
            self.transaction_manager.commit_transaction(transaction_id)
            return True
            
        except Exception as e:
            # Rollback transaction
            self.transaction_manager.rollback_transaction(transaction_id)
            raise e
    
    def batch_update_users(self, user_updates):
        transaction_id = self.transaction_manager.begin_transaction()
        
        try:
            # Step 1: Batch update database
            self.db.batch_update_users(user_updates, transaction_id)
            
            # Step 2: Batch update cache
            cache_updates = {}
            for user_id, user_data in user_updates.items():
                cache_key = f"user:{user_id}"
                cache_updates[cache_key] = json.dumps(user_data)
            
            if cache_updates:
                self.cache.mset(cache_updates)
                # Set TTL for all keys
                for key in cache_updates.keys():
                    self.cache.expire(key, self.default_ttl)
            
            # Commit transaction
            self.transaction_manager.commit_transaction(transaction_id)
            return True
            
        except Exception as e:
            # Rollback transaction
            self.transaction_manager.rollback_transaction(transaction_id)
            raise e
```

### Implementation with Retry Logic
```python
class RetryWriteThroughService:
    def __init__(self, cache_client, database_client, max_retries=3):
        self.cache = cache_client
        self.db = database_client
        self.max_retries = max_retries
        self.default_ttl = 3600
    
    def update_user_with_retry(self, user_id, user_data):
        for attempt in range(self.max_retries):
            try:
                # Step 1: Update database
                self.db.update_user(user_id, user_data)
                
                # Step 2: Update cache
                cache_key = f"user:{user_id}"
                self.cache.setex(cache_key, self.default_ttl, json.dumps(user_data))
                
                return True
                
            except Exception as e:
                if attempt == self.max_retries - 1:
                    # Final attempt failed, rollback
                    self._rollback_update(user_id, user_data)
                    raise e
                
                # Wait before retry
                time.sleep(0.1 * (2 ** attempt))
                continue
    
    def _rollback_update(self, user_id, user_data):
        try:
            # Rollback database
            self.db.rollback_user_update(user_id)
            
            # Invalidate cache
            cache_key = f"user:{user_id}"
            self.cache.delete(cache_key)
            
        except Exception as rollback_error:
            # Log rollback error but don't raise
            print(f"Rollback failed: {rollback_error}")
```

## Consequences

### Benefits
1. **Immediate Consistency**: Cache and database are always in sync
2. **Data Integrity**: No risk of stale data in cache
3. **Simple Logic**: Straightforward implementation
4. **Predictable Behavior**: Consistent behavior across operations
5. **Easy Debugging**: Clear data flow and state
6. **Reliable Reads**: Cache always has latest data

### Drawbacks
1. **Higher Latency**: Write operations take longer due to dual updates
2. **Performance Impact**: Synchronous writes can be slow
3. **Resource Usage**: More resources consumed per write operation
4. **Failure Risk**: Either system failure can cause write failure
5. **Complexity**: Error handling and rollback logic required
6. **Bottleneck**: Cache can become a write bottleneck

### Trade-offs
- **Consistency vs. Performance**: Immediate consistency vs. write performance
- **Reliability vs. Speed**: Data integrity vs. operation speed
- **Simplicity vs. Complexity**: Simple logic vs. error handling complexity
- **Resource Usage vs. Consistency**: Resource consumption vs. data consistency

## Related Patterns

### Complementary Patterns
- **Read-Through Pattern**: For automatic cache loading on reads
- **Cache-Aside Pattern**: For read operations
- **Write-Behind Pattern**: Alternative for better write performance
- **Circuit Breaker**: For handling cache failures gracefully

### Variations
- **Write-Through with Validation**: Validate data before writing
- **Write-Through with Compression**: Compress data before caching
- **Write-Through with Encryption**: Encrypt data before caching

### Anti-patterns
- **Write-Through without Error Handling**: Can cause data inconsistency
- **Write-Through without Rollback**: Can leave systems in inconsistent state
- **Write-Through for All Operations**: May be overkill for some use cases

## Implementation Guidelines

### Best Practices
1. **Error Handling**: Implement comprehensive error handling
2. **Rollback Strategy**: Always implement rollback mechanisms
3. **Transaction Support**: Use transactions when available
4. **Retry Logic**: Implement retry logic for transient failures
5. **Monitoring**: Monitor write performance and error rates
6. **Testing**: Test both success and failure scenarios

### Common Pitfalls
1. **Incomplete Rollback**: Not rolling back all changes on failure
2. **Race Conditions**: Concurrent writes causing data inconsistency
3. **Performance Issues**: Not considering write performance impact
4. **Error Propagation**: Not handling errors properly
5. **Resource Exhaustion**: Not managing resource usage

### Performance Considerations
1. **Write Latency**: Monitor and optimize write latency
2. **Resource Usage**: Monitor resource consumption
3. **Batch Operations**: Use batch operations when possible
4. **Connection Pooling**: Reuse database and cache connections
5. **Monitoring**: Monitor performance metrics continuously

## Real-World Examples

### E-commerce Order Processing
```python
class OrderWriteThroughService:
    def __init__(self, cache, database):
        self.cache = cache
        self.db = database
        self.order_ttl = 1800  # 30 minutes
    
    def create_order(self, order_data):
        try:
            # Step 1: Create order in database
            order_id = self.db.create_order(order_data)
            
            # Step 2: Update cache
            cache_key = f"order:{order_id}"
            self.cache.setex(cache_key, self.order_ttl, json.dumps(order_data))
            
            # Step 3: Update user's order list cache
            user_cache_key = f"user_orders:{order_data['user_id']}"
            self.cache.delete(user_cache_key)  # Invalidate user's order list
            
            return order_id
            
        except Exception as e:
            # Rollback order creation
            if 'order_id' in locals():
                self.db.rollback_order_creation(order_id)
            raise e
    
    def update_order_status(self, order_id, status):
        try:
            # Step 1: Update database
            self.db.update_order_status(order_id, status)
            
            # Step 2: Update cache
            cache_key = f"order:{order_id}"
            cached_order = self.cache.get(cache_key)
            if cached_order:
                order_data = json.loads(cached_order)
                order_data['status'] = status
                self.cache.setex(cache_key, self.order_ttl, json.dumps(order_data))
            
            return True
            
        except Exception as e:
            # Rollback status update
            self.db.rollback_order_status_update(order_id)
            raise e
```

### User Profile Management
```python
class UserProfileWriteThroughService:
    def __init__(self, cache, database):
        self.cache = cache
        self.db = database
        self.profile_ttl = 3600  # 1 hour
    
    def update_user_profile(self, user_id, profile_data):
        try:
            # Step 1: Update database
            self.db.update_user_profile(user_id, profile_data)
            
            # Step 2: Update cache
            cache_key = f"user_profile:{user_id}"
            self.cache.setex(cache_key, self.profile_ttl, json.dumps(profile_data))
            
            # Step 3: Invalidate related caches
            self._invalidate_related_caches(user_id)
            
            return True
            
        except Exception as e:
            # Rollback profile update
            self.db.rollback_user_profile_update(user_id)
            raise e
    
    def _invalidate_related_caches(self, user_id):
        # Invalidate user's session cache
        session_cache_key = f"user_session:{user_id}"
        self.cache.delete(session_cache_key)
        
        # Invalidate user's preferences cache
        preferences_cache_key = f"user_preferences:{user_id}"
        self.cache.delete(preferences_cache_key)
```

## Monitoring and Metrics

### Key Metrics
- **Write Latency**: Time to complete write operations
- **Write Success Rate**: Percentage of successful writes
- **Cache Update Success Rate**: Percentage of successful cache updates
- **Database Update Success Rate**: Percentage of successful database updates
- **Rollback Rate**: Percentage of operations requiring rollback
- **Error Rate**: Percentage of failed operations

### Monitoring Implementation
```python
class MonitoredWriteThroughService:
    def __init__(self, cache, database, metrics_collector):
        self.cache = cache
        self.db = database
        self.metrics = metrics_collector
        self.default_ttl = 3600
    
    def update_user(self, user_id, user_data):
        start_time = time.time()
        
        try:
            # Update database
            db_start = time.time()
            self.db.update_user(user_id, user_data)
            self.metrics.timing('database.write_time', time.time() - db_start)
            self.metrics.increment('database.write_success')
            
            # Update cache
            cache_start = time.time()
            cache_key = f"user:{user_id}"
            self.cache.setex(cache_key, self.default_ttl, json.dumps(user_data))
            self.metrics.timing('cache.write_time', time.time() - cache_start)
            self.metrics.increment('cache.write_success')
            
            # Overall success
            self.metrics.timing('write_through.total_time', time.time() - start_time)
            self.metrics.increment('write_through.success')
            
            return True
            
        except Exception as e:
            self.metrics.increment('write_through.error')
            self.metrics.increment('write_through.rollback')
            raise e
```

## Use Cases

### When to Use Write-Through
1. **Critical Data**: When data consistency is more important than performance
2. **Financial Systems**: Where data integrity is paramount
3. **User Sessions**: Where session data must be immediately consistent
4. **Configuration Data**: Where configuration changes must be immediate
5. **Real-time Systems**: Where data must be immediately available

### When Not to Use Write-Through
1. **High-Volume Writes**: When write performance is critical
2. **Temporary Data**: When data doesn't need to be immediately consistent
3. **Batch Operations**: When processing large volumes of data
4. **Analytics Data**: When eventual consistency is acceptable
5. **Logging Systems**: When data can be eventually consistent

This pattern provides a reliable foundation for maintaining consistency between cache and data store, making it ideal for applications where data integrity is more important than write performance.
