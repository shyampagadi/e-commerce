# Batch Processing Patterns

## Overview
Comprehensive collection of proven batch processing patterns for large-scale data processing systems, covering design patterns, optimization techniques, and operational best practices.

## Core Processing Patterns

### 1. Extract-Transform-Load (ETL) Pattern
**Intent**: Process data by extracting from sources, transforming according to business rules, and loading into target systems.

**Structure**:
```yaml
Components:
  - Data Extractors: Read from various source systems
  - Transformation Engine: Apply business logic and data quality rules
  - Data Loaders: Write to target systems with appropriate formatting
  
Flow:
  Source Systems → Extract → Transform → Load → Target Systems
```

**Implementation Example**:
```python
class ETLPipeline:
    def __init__(self, config):
        self.extractors = self._initialize_extractors(config)
        self.transformers = self._initialize_transformers(config)
        self.loaders = self._initialize_loaders(config)
    
    def execute(self, execution_date):
        # Extract phase
        raw_data = {}
        for source, extractor in self.extractors.items():
            raw_data[source] = extractor.extract(execution_date)
        
        # Transform phase
        transformed_data = {}
        for dataset, transformer in self.transformers.items():
            transformed_data[dataset] = transformer.transform(
                raw_data, execution_date
            )
        
        # Load phase
        for target, loader in self.loaders.items():
            loader.load(transformed_data, execution_date)
        
        return self._generate_execution_report()
```

**When to Use**:
- Traditional data warehousing scenarios
- Regulatory reporting requirements
- Data quality and validation needs
- Batch-oriented business processes

**Benefits**:
- Clear separation of concerns
- Easy to test and validate each phase
- Well-understood by most teams
- Good for complex transformations

**Drawbacks**:
- Higher latency than streaming approaches
- Resource intensive during processing windows
- Potential for data inconsistency during processing

### 2. Extract-Load-Transform (ELT) Pattern
**Intent**: Load raw data first, then transform within the target system using its native processing capabilities.

**Structure**:
```yaml
Components:
  - Data Extractors: Read from source systems
  - Raw Data Store: Store unprocessed data (data lake)
  - Transformation Engine: Process data within target system
  
Flow:
  Source Systems → Extract → Load → Transform → Processed Data
```

**Implementation Example**:
```python
class ELTPipeline:
    def __init__(self, data_lake_config, warehouse_config):
        self.data_lake = DataLakeConnector(data_lake_config)
        self.warehouse = WarehouseConnector(warehouse_config)
    
    def execute(self, execution_date):
        # Extract and Load raw data to data lake
        for source in self.sources:
            raw_data = source.extract(execution_date)
            self.data_lake.store_raw(
                data=raw_data,
                source=source.name,
                partition_date=execution_date
            )
        
        # Transform within warehouse using SQL/Spark
        transformation_jobs = [
            'customer_dimension_update',
            'sales_fact_processing', 
            'inventory_aggregation',
            'financial_reporting'
        ]
        
        for job in transformation_jobs:
            self.warehouse.execute_transformation(
                job_name=job,
                execution_date=execution_date
            )
```

**When to Use**:
- Cloud-native data platforms
- Big data scenarios with schema-on-read
- When target system has powerful processing capabilities
- Exploratory data analysis requirements

**Benefits**:
- Preserves raw data for future use
- Leverages target system's processing power
- More flexible for changing requirements
- Better for big data scenarios

**Drawbacks**:
- Requires powerful target system
- May have higher storage costs
- Complex error handling and recovery

### 3. Lambda Architecture Pattern
**Intent**: Combine batch and stream processing to provide both accurate historical views and low-latency real-time views.

**Structure**:
```yaml
Layers:
  Batch Layer: 
    - Processes complete datasets
    - Provides accurate, comprehensive views
    - Higher latency but complete accuracy
    
  Speed Layer:
    - Processes real-time streams
    - Provides low-latency approximate views
    - May sacrifice accuracy for speed
    
  Serving Layer:
    - Merges batch and speed layer outputs
    - Provides unified query interface
    - Handles view materialization
```

**Implementation Example**:
```python
class LambdaArchitecture:
    def __init__(self, config):
        self.batch_processor = BatchProcessor(config['batch'])
        self.stream_processor = StreamProcessor(config['stream'])
        self.serving_layer = ServingLayer(config['serving'])
    
    def process_batch(self, start_date, end_date):
        """Process historical data in batch layer"""
        batch_views = self.batch_processor.compute_views(
            start_date=start_date,
            end_date=end_date
        )
        
        # Update serving layer with batch views
        self.serving_layer.update_batch_views(batch_views)
        
        return batch_views
    
    def process_stream(self, stream_data):
        """Process real-time data in speed layer"""
        real_time_views = self.stream_processor.compute_incremental_views(
            stream_data
        )
        
        # Update serving layer with real-time views
        self.serving_layer.update_real_time_views(real_time_views)
        
        return real_time_views
    
    def query(self, query_params):
        """Query unified view from serving layer"""
        return self.serving_layer.execute_query(query_params)
```

**When to Use**:
- Need both real-time and batch processing
- High accuracy requirements with low latency needs
- Complex analytical workloads
- Systems with varying SLA requirements

**Benefits**:
- Combines benefits of batch and stream processing
- Fault-tolerant and scalable
- Handles both historical and real-time data
- Provides multiple consistency models

**Drawbacks**:
- Complex architecture and operations
- Duplicate processing logic
- Higher infrastructure costs
- Challenging to maintain consistency

### 4. Kappa Architecture Pattern
**Intent**: Simplify Lambda architecture by using only stream processing for both real-time and batch workloads.

**Structure**:
```yaml
Components:
  Stream Processing Engine: Handles all data processing
  Immutable Log: Stores all events for reprocessing
  Serving Database: Materialized views for queries
  
Flow:
  All Data → Stream Processor → Materialized Views → Query Interface
```

**Implementation Example**:
```python
class KappaArchitecture:
    def __init__(self, config):
        self.stream_processor = UnifiedStreamProcessor(config)
        self.event_log = ImmutableEventLog(config['log'])
        self.view_store = MaterializedViewStore(config['views'])
    
    def process_events(self, events):
        """Process all events through unified stream processor"""
        for event in events:
            # Store in immutable log
            self.event_log.append(event)
            
            # Process through stream processor
            processed_data = self.stream_processor.process(event)
            
            # Update materialized views
            self.view_store.update_views(processed_data)
    
    def reprocess_historical_data(self, start_time, end_time):
        """Reprocess historical data by replaying events"""
        historical_events = self.event_log.get_events(
            start_time=start_time,
            end_time=end_time
        )
        
        # Create new version of views
        new_view_version = self.view_store.create_new_version()
        
        # Reprocess events
        for event in historical_events:
            processed_data = self.stream_processor.process(event)
            new_view_version.update(processed_data)
        
        # Atomically switch to new version
        self.view_store.activate_version(new_view_version)
```

**When to Use**:
- Unified processing requirements
- Need for reprocessing historical data
- Stream-first architectures
- Simplified operational model desired

**Benefits**:
- Simpler than Lambda architecture
- Single processing paradigm
- Easy to reprocess historical data
- Consistent processing logic

**Drawbacks**:
- Requires mature stream processing platform
- May not be suitable for all batch workloads
- Potential performance limitations
- Less mature tooling ecosystem

## Data Processing Optimization Patterns

### 5. Partitioning Pattern
**Intent**: Divide large datasets into smaller, manageable partitions to improve processing performance and enable parallel execution.

**Types of Partitioning**:
```yaml
Temporal Partitioning:
  - Partition by date/time (year/month/day/hour)
  - Enables time-based query optimization
  - Supports data lifecycle management
  
Functional Partitioning:
  - Partition by business dimension (region, product category)
  - Enables domain-specific processing
  - Supports organizational data ownership
  
Hash Partitioning:
  - Partition by hash of key field
  - Ensures even distribution
  - Good for parallel processing
  
Range Partitioning:
  - Partition by value ranges
  - Enables range-based queries
  - Supports ordered processing
```

**Implementation Example**:
```python
class PartitioningStrategy:
    def __init__(self, partition_type, partition_key):
        self.partition_type = partition_type
        self.partition_key = partition_key
    
    def get_partition_path(self, record, base_path):
        if self.partition_type == 'temporal':
            date_str = record[self.partition_key].strftime('%Y/%m/%d')
            return f"{base_path}/date={date_str}"
        
        elif self.partition_type == 'functional':
            category = record[self.partition_key]
            return f"{base_path}/category={category}"
        
        elif self.partition_type == 'hash':
            hash_value = hash(record[self.partition_key]) % 100
            return f"{base_path}/hash_bucket={hash_value:02d}"
        
        elif self.partition_type == 'range':
            value = record[self.partition_key]
            range_bucket = self._get_range_bucket(value)
            return f"{base_path}/range={range_bucket}"
    
    def optimize_query(self, query_filters):
        """Optimize query by pruning unnecessary partitions"""
        relevant_partitions = []
        
        for partition in self.get_all_partitions():
            if self._partition_matches_filters(partition, query_filters):
                relevant_partitions.append(partition)
        
        return relevant_partitions
```

### 6. Incremental Processing Pattern
**Intent**: Process only new or changed data since the last processing run to improve efficiency and reduce resource usage.

**Implementation Strategies**:
```yaml
Timestamp-Based:
  - Track last processed timestamp
  - Process records with timestamp > last_processed
  - Handle late-arriving data appropriately
  
Change Data Capture (CDC):
  - Capture database changes (inserts, updates, deletes)
  - Process only changed records
  - Maintain data consistency
  
Watermark-Based:
  - Use high-water mark to track progress
  - Handle out-of-order data
  - Provide exactly-once processing guarantees
```

**Implementation Example**:
```python
class IncrementalProcessor:
    def __init__(self, checkpoint_store):
        self.checkpoint_store = checkpoint_store
    
    def process_incremental_data(self, source, target, processing_date):
        # Get last processed checkpoint
        last_checkpoint = self.checkpoint_store.get_checkpoint(
            source=source.name,
            target=target.name
        )
        
        # Extract incremental data
        incremental_data = source.extract_incremental(
            since=last_checkpoint.timestamp,
            until=processing_date
        )
        
        if not incremental_data:
            return ProcessingResult(status='NO_NEW_DATA')
        
        # Process incremental data
        processed_data = self.transform_incremental(
            data=incremental_data,
            last_state=last_checkpoint.state
        )
        
        # Load to target
        load_result = target.load_incremental(processed_data)
        
        # Update checkpoint
        new_checkpoint = Checkpoint(
            timestamp=processing_date,
            state=processed_data.final_state,
            records_processed=len(processed_data)
        )
        
        self.checkpoint_store.save_checkpoint(
            source=source.name,
            target=target.name,
            checkpoint=new_checkpoint
        )
        
        return ProcessingResult(
            status='SUCCESS',
            records_processed=len(processed_data),
            checkpoint=new_checkpoint
        )
```

### 7. Idempotent Processing Pattern
**Intent**: Ensure that processing the same data multiple times produces the same result, enabling safe retries and reprocessing.

**Implementation Techniques**:
```yaml
Upsert Operations:
  - Use MERGE or INSERT...ON DUPLICATE KEY UPDATE
  - Overwrite existing records with same key
  - Maintain data consistency during retries
  
Deterministic Transformations:
  - Ensure transformations produce same output for same input
  - Avoid using current timestamp or random values
  - Use deterministic algorithms and functions
  
Idempotency Keys:
  - Generate unique keys for each processing operation
  - Track completed operations to avoid duplicates
  - Enable safe retry mechanisms
```

**Implementation Example**:
```python
class IdempotentProcessor:
    def __init__(self, operation_store):
        self.operation_store = operation_store
    
    def process_with_idempotency(self, operation_id, data, processor_func):
        # Check if operation already completed
        existing_result = self.operation_store.get_result(operation_id)
        if existing_result:
            return existing_result
        
        # Mark operation as started
        self.operation_store.mark_started(
            operation_id=operation_id,
            started_at=datetime.utcnow()
        )
        
        try:
            # Execute processing function
            result = processor_func(data)
            
            # Store successful result
            self.operation_store.store_result(
                operation_id=operation_id,
                result=result,
                status='SUCCESS',
                completed_at=datetime.utcnow()
            )
            
            return result
            
        except Exception as e:
            # Store failure result
            self.operation_store.store_result(
                operation_id=operation_id,
                result=None,
                status='FAILED',
                error=str(e),
                completed_at=datetime.utcnow()
            )
            raise
    
    def generate_operation_id(self, input_data, processing_date):
        """Generate deterministic operation ID"""
        content_hash = hashlib.sha256(
            json.dumps(input_data, sort_keys=True).encode()
        ).hexdigest()
        
        return f"{processing_date.isoformat()}_{content_hash[:16]}"
```

## Error Handling and Recovery Patterns

### 8. Circuit Breaker Pattern
**Intent**: Prevent cascading failures by temporarily stopping calls to failing external services and allowing them to recover.

**Implementation Example**:
```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'  # CLOSED, OPEN, HALF_OPEN
    
    def call(self, func, *args, **kwargs):
        if self.state == 'OPEN':
            if self._should_attempt_reset():
                self.state = 'HALF_OPEN'
            else:
                raise CircuitBreakerOpenException("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
            
        except self.expected_exception as e:
            self._on_failure()
            raise
    
    def _on_success(self):
        self.failure_count = 0
        self.state = 'CLOSED'
    
    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = 'OPEN'
    
    def _should_attempt_reset(self):
        return (time.time() - self.last_failure_time) >= self.recovery_timeout
```

### 9. Retry with Exponential Backoff Pattern
**Intent**: Automatically retry failed operations with increasing delays to handle transient failures gracefully.

**Implementation Example**:
```python
class ExponentialBackoffRetry:
    def __init__(self, max_retries=3, base_delay=1, max_delay=60, backoff_factor=2):
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.backoff_factor = backoff_factor
    
    def execute_with_retry(self, func, *args, **kwargs):
        last_exception = None
        
        for attempt in range(self.max_retries + 1):
            try:
                return func(*args, **kwargs)
                
            except Exception as e:
                last_exception = e
                
                if attempt == self.max_retries:
                    break
                
                # Calculate delay with exponential backoff
                delay = min(
                    self.base_delay * (self.backoff_factor ** attempt),
                    self.max_delay
                )
                
                # Add jitter to prevent thundering herd
                jittered_delay = delay * (0.5 + random.random() * 0.5)
                
                time.sleep(jittered_delay)
        
        raise last_exception
```

## Performance Optimization Patterns

### 10. Data Locality Pattern
**Intent**: Optimize processing performance by ensuring data and compute resources are co-located to minimize network overhead.

**Implementation Strategies**:
```yaml
Compute-to-Data:
  - Move processing logic to where data resides
  - Use distributed computing frameworks
  - Minimize data movement across network
  
Data-to-Compute:
  - Cache frequently accessed data near compute
  - Use content delivery networks (CDNs)
  - Implement intelligent data placement
  
Hybrid Approach:
  - Balance between data movement and compute distribution
  - Use cost-benefit analysis for optimization
  - Implement adaptive strategies based on workload
```

### 11. Caching Pattern
**Intent**: Improve performance by storing frequently accessed data in fast-access storage layers.

**Caching Strategies**:
```yaml
Read-Through Cache:
  - Cache loads data on cache miss
  - Transparent to application
  - Ensures cache consistency
  
Write-Through Cache:
  - Writes go to cache and backing store
  - Ensures data consistency
  - Higher write latency
  
Write-Behind Cache:
  - Writes go to cache first
  - Asynchronous write to backing store
  - Better write performance, eventual consistency
```

**Implementation Example**:
```python
class MultiLevelCache:
    def __init__(self, l1_cache, l2_cache, backing_store):
        self.l1_cache = l1_cache  # Fast, small cache (Redis)
        self.l2_cache = l2_cache  # Medium speed, larger cache (S3)
        self.backing_store = backing_store  # Slow, persistent store
    
    def get(self, key):
        # Try L1 cache first
        value = self.l1_cache.get(key)
        if value is not None:
            return value
        
        # Try L2 cache
        value = self.l2_cache.get(key)
        if value is not None:
            # Promote to L1 cache
            self.l1_cache.set(key, value, ttl=3600)
            return value
        
        # Load from backing store
        value = self.backing_store.get(key)
        if value is not None:
            # Cache in both levels
            self.l1_cache.set(key, value, ttl=3600)
            self.l2_cache.set(key, value, ttl=86400)
        
        return value
    
    def set(self, key, value):
        # Write-through to all levels
        self.backing_store.set(key, value)
        self.l2_cache.set(key, value, ttl=86400)
        self.l1_cache.set(key, value, ttl=3600)
```

## Monitoring and Observability Patterns

### 12. Health Check Pattern
**Intent**: Provide standardized health monitoring for batch processing systems to enable automated monitoring and alerting.

**Implementation Example**:
```python
class BatchProcessHealthCheck:
    def __init__(self, processors, data_sources, targets):
        self.processors = processors
        self.data_sources = data_sources
        self.targets = targets
    
    def check_health(self):
        health_status = {
            'overall_status': 'HEALTHY',
            'timestamp': datetime.utcnow().isoformat(),
            'components': {}
        }
        
        # Check data source health
        for source in self.data_sources:
            source_health = self._check_data_source_health(source)
            health_status['components'][f'source_{source.name}'] = source_health
            
            if source_health['status'] != 'HEALTHY':
                health_status['overall_status'] = 'UNHEALTHY'
        
        # Check processor health
        for processor in self.processors:
            processor_health = self._check_processor_health(processor)
            health_status['components'][f'processor_{processor.name}'] = processor_health
            
            if processor_health['status'] != 'HEALTHY':
                health_status['overall_status'] = 'UNHEALTHY'
        
        # Check target health
        for target in self.targets:
            target_health = self._check_target_health(target)
            health_status['components'][f'target_{target.name}'] = target_health
            
            if target_health['status'] != 'HEALTHY':
                health_status['overall_status'] = 'UNHEALTHY'
        
        return health_status
    
    def _check_data_source_health(self, source):
        try:
            # Check connectivity and data freshness
            latest_data = source.get_latest_timestamp()
            data_age = datetime.utcnow() - latest_data
            
            if data_age > timedelta(hours=6):
                return {
                    'status': 'UNHEALTHY',
                    'message': f'Data is {data_age} old',
                    'last_update': latest_data.isoformat()
                }
            
            return {
                'status': 'HEALTHY',
                'message': 'Data source is current',
                'last_update': latest_data.isoformat()
            }
            
        except Exception as e:
            return {
                'status': 'UNHEALTHY',
                'message': f'Health check failed: {str(e)}',
                'error': str(e)
            }
```

These patterns provide a comprehensive foundation for building robust, scalable, and maintainable batch processing systems. Each pattern addresses specific challenges and can be combined to create sophisticated data processing architectures.
