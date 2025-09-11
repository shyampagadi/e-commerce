# Exercise 7: Cache Monitoring and Observability

## Overview

**Duration**: 3-4 hours  
**Difficulty**: Advanced  
**Prerequisites**: Exercise 1-6 completion, understanding of monitoring concepts

## Learning Objectives

By completing this exercise, you will:
- Implement comprehensive cache monitoring and observability
- Design cache performance metrics and alerting
- Create cache health monitoring and diagnostics
- Implement distributed tracing for cache operations

## Scenario

You are implementing monitoring for a large-scale distributed caching system with the following requirements:

### Monitoring Requirements
- **Performance Metrics**: Latency, throughput, hit ratio, error rate
- **Health Monitoring**: Cache node health, memory usage, CPU usage
- **Business Metrics**: User experience, cost optimization, SLA compliance
- **Security Metrics**: Access patterns, authentication failures, authorization violations

### Observability Requirements
- **Distributed Tracing**: Track requests across cache layers
- **Log Aggregation**: Centralized logging with structured logs
- **Metrics Collection**: Real-time metrics with historical data
- **Alerting**: Proactive alerting with escalation policies

### Scale Requirements
- **Cache Nodes**: 100+ Redis nodes across multiple regions
- **Requests**: 1M+ requests per second
- **Data Volume**: 100GB+ cached data
- **Retention**: 90 days of metrics, 30 days of logs

## Exercise Tasks

### Task 1: Cache Metrics Implementation (90 minutes)

Implement comprehensive cache metrics collection:

1. **Performance Metrics**
   - Cache hit/miss ratios by operation type
   - Response time percentiles (P50, P95, P99)
   - Throughput metrics (requests per second)
   - Error rates and failure patterns

2. **Resource Metrics**
   - Memory usage and utilization
   - CPU usage and load
   - Network I/O and bandwidth
   - Disk usage and I/O operations

**Implementation Requirements**:
```python
class CacheMetricsCollector:
    def __init__(self, cache_client, metrics_backend):
        self.cache = cache_client
        self.metrics = metrics_backend
        self.counters = {}
        self.histograms = {}
        self.gauges = {}
        self.start_collection()
    
    def record_cache_hit(self, operation, key, response_time):
        """Record cache hit metrics"""
        pass
    
    def record_cache_miss(self, operation, key, response_time):
        """Record cache miss metrics"""
        pass
    
    def record_error(self, operation, key, error_type, response_time):
        """Record error metrics"""
        pass
    
    def record_resource_usage(self, node_id, memory_usage, cpu_usage):
        """Record resource usage metrics"""
        pass
```

### Task 2: Distributed Tracing Implementation (75 minutes)

Implement distributed tracing for cache operations:

1. **Trace Context Propagation**
   - Propagate trace context across cache layers
   - Create span hierarchy for cache operations
   - Implement trace sampling strategies
   - Handle trace context in async operations

2. **Cache Operation Tracing**
   - Trace cache hits and misses
   - Trace cache invalidation operations
   - Trace cache warming operations
   - Trace error scenarios

**Implementation Requirements**:
```python
class CacheTracingService:
    def __init__(self, tracer, cache_client):
        self.tracer = tracer
        self.cache = cache_client
        self.trace_sampler = TraceSampler()
    
    def trace_cache_operation(self, operation, key, user_context):
        """Trace cache operation with context"""
        pass
    
    def trace_cache_hit(self, key, response_time, metadata):
        """Trace cache hit with performance data"""
        pass
    
    def trace_cache_miss(self, key, response_time, metadata):
        """Trace cache miss with performance data"""
        pass
    
    def trace_cache_error(self, key, error, response_time):
        """Trace cache error with error details"""
        pass
```

### Task 3: Cache Health Monitoring (60 minutes)

Implement comprehensive cache health monitoring:

1. **Health Checks**
   - Cache node availability and responsiveness
   - Memory usage and eviction rates
   - Connection pool health
   - Replication lag monitoring

2. **Diagnostic Tools**
   - Cache performance analysis
   - Memory usage analysis
   - Network connectivity tests
   - Configuration validation

**Implementation Requirements**:
```python
class CacheHealthMonitor:
    def __init__(self, cache_client, health_checker, alert_manager):
        self.cache = cache_client
        self.health_checker = health_checker
        self.alerts = alert_manager
        self.health_checks = {}
        self.start_monitoring()
    
    def check_cache_health(self, node_id):
        """Check health of specific cache node"""
        pass
    
    def check_memory_health(self, node_id):
        """Check memory usage and eviction rates"""
        pass
    
    def check_replication_health(self, node_id):
        """Check replication lag and consistency"""
        pass
    
    def run_diagnostic_tests(self, node_id):
        """Run comprehensive diagnostic tests"""
        pass
```

### Task 4: Alerting and Notification System (45 minutes)

Implement intelligent alerting and notification system:

1. **Alert Rules Engine**
   - Define alert conditions and thresholds
   - Implement alert escalation policies
   - Create alert suppression and grouping
   - Design alert correlation and deduplication

2. **Notification System**
   - Multi-channel notifications (email, Slack, PagerDuty)
   - Alert routing based on severity and team
   - Alert acknowledgment and resolution tracking
   - Alert history and analytics

**Implementation Requirements**:
```python
class CacheAlertingSystem:
    def __init__(self, alert_rules, notification_channels, alert_manager):
        self.rules = alert_rules
        self.channels = notification_channels
        self.manager = alert_manager
        self.alert_state = {}
        self.start_alerting()
    
    def evaluate_alert_conditions(self, metrics):
        """Evaluate metrics against alert conditions"""
        pass
    
    def send_alert(self, alert, severity, channels):
        """Send alert through specified channels"""
        pass
    
    def acknowledge_alert(self, alert_id, user):
        """Acknowledge alert and update state"""
        pass
    
    def resolve_alert(self, alert_id, user, resolution_notes):
        """Resolve alert with resolution notes"""
        pass
```

## Performance Targets

### Monitoring Performance
- **Metrics Collection Latency**: < 1ms per metric
- **Trace Overhead**: < 5% performance impact
- **Health Check Frequency**: Every 30 seconds
- **Alert Response Time**: < 1 minute

### Observability Metrics
- **Trace Coverage**: > 95% of cache operations
- **Log Completeness**: 100% of operations logged
- **Metrics Accuracy**: 99.9% accuracy
- **Alert Accuracy**: < 1% false positive rate

### System Metrics
- **Cache Hit Ratio**: > 90% for read operations
- **Response Time**: < 10ms P95 for cache operations
- **Error Rate**: < 0.1% for cache operations
- **Availability**: > 99.9% uptime

## Evaluation Criteria

### Technical Implementation (40%)
- **Metrics Collection**: Comprehensive metrics implementation
- **Distributed Tracing**: Effective tracing implementation
- **Health Monitoring**: Robust health monitoring system
- **Alerting**: Intelligent alerting and notification system

### Observability Achievement (30%)
- **Visibility**: Complete visibility into cache operations
- **Performance**: Meets performance targets
- **Reliability**: Reliable monitoring and alerting
- **Usability**: User-friendly monitoring interfaces

### Monitoring and Alerting (20%)
- **Alert Accuracy**: Low false positive rate
- **Response Time**: Fast alert response times
- **Coverage**: Comprehensive monitoring coverage
- **Documentation**: Clear monitoring documentation

### Innovation and Best Practices (10%)
- **Monitoring Innovation**: Innovative monitoring approaches
- **Best Practices**: Following monitoring best practices
- **Industry Standards**: Adherence to industry standards
- **Continuous Improvement**: Plans for monitoring improvement

## Sample Implementation

### Cache Metrics Collector

```python
class CacheMetricsCollector:
    def __init__(self, cache_client, metrics_backend):
        self.cache = cache_client
        self.metrics = metrics_backend
        self.counters = {}
        self.histograms = {}
        self.gauges = {}
        self.start_collection()
    
    def record_cache_hit(self, operation, key, response_time):
        """Record cache hit metrics"""
        # Increment hit counter
        self.metrics.increment_counter('cache_hits_total', {
            'operation': operation,
            'cache_type': 'redis',
            'node': self._get_node_id()
        })
        
        # Record response time
        self.metrics.record_histogram('cache_response_time_seconds', response_time, {
            'operation': operation,
            'result': 'hit',
            'cache_type': 'redis'
        })
        
        # Record hit ratio
        self._update_hit_ratio(operation)
    
    def record_cache_miss(self, operation, key, response_time):
        """Record cache miss metrics"""
        # Increment miss counter
        self.metrics.increment_counter('cache_misses_total', {
            'operation': operation,
            'cache_type': 'redis',
            'node': self._get_node_id()
        })
        
        # Record response time
        self.metrics.record_histogram('cache_response_time_seconds', response_time, {
            'operation': operation,
            'result': 'miss',
            'cache_type': 'redis'
        })
        
        # Record miss ratio
        self._update_miss_ratio(operation)
    
    def record_error(self, operation, key, error_type, response_time):
        """Record error metrics"""
        # Increment error counter
        self.metrics.increment_counter('cache_errors_total', {
            'operation': operation,
            'error_type': error_type,
            'cache_type': 'redis',
            'node': self._get_node_id()
        })
        
        # Record error response time
        self.metrics.record_histogram('cache_error_response_time_seconds', response_time, {
            'operation': operation,
            'error_type': error_type,
            'cache_type': 'redis'
        })
    
    def record_resource_usage(self, node_id, memory_usage, cpu_usage):
        """Record resource usage metrics"""
        # Record memory usage
        self.metrics.record_gauge('cache_memory_usage_bytes', memory_usage, {
            'node': node_id,
            'cache_type': 'redis'
        })
        
        # Record CPU usage
        self.metrics.record_gauge('cache_cpu_usage_percent', cpu_usage, {
            'node': node_id,
            'cache_type': 'redis'
        })
        
        # Record memory utilization percentage
        memory_utilization = (memory_usage / self._get_total_memory()) * 100
        self.metrics.record_gauge('cache_memory_utilization_percent', memory_utilization, {
            'node': node_id,
            'cache_type': 'redis'
        })
    
    def _update_hit_ratio(self, operation):
        """Update hit ratio for operation"""
        hits = self.metrics.get_counter_value('cache_hits_total', {'operation': operation})
        misses = self.metrics.get_counter_value('cache_misses_total', {'operation': operation})
        
        if hits + misses > 0:
            hit_ratio = hits / (hits + misses)
            self.metrics.record_gauge('cache_hit_ratio', hit_ratio, {
                'operation': operation,
                'cache_type': 'redis'
            })
    
    def _update_miss_ratio(self, operation):
        """Update miss ratio for operation"""
        hits = self.metrics.get_counter_value('cache_hits_total', {'operation': operation})
        misses = self.metrics.get_counter_value('cache_misses_total', {'operation': operation})
        
        if hits + misses > 0:
            miss_ratio = misses / (hits + misses)
            self.metrics.record_gauge('cache_miss_ratio', miss_ratio, {
                'operation': operation,
                'cache_type': 'redis'
            })
    
    def start_collection(self):
        """Start background metrics collection"""
        def collect_metrics():
            while True:
                try:
                    # Collect system metrics
                    self._collect_system_metrics()
                    
                    # Collect cache-specific metrics
                    self._collect_cache_metrics()
                    
                    # Collect business metrics
                    self._collect_business_metrics()
                    
                    time.sleep(30)  # Collect every 30 seconds
                except Exception as e:
                    print(f"Error collecting metrics: {e}")
                    time.sleep(30)
        
        threading.Thread(target=collect_metrics, daemon=True).start()
    
    def _collect_system_metrics(self):
        """Collect system-level metrics"""
        # Memory usage
        memory_info = psutil.virtual_memory()
        self.metrics.record_gauge('system_memory_usage_bytes', memory_info.used)
        self.metrics.record_gauge('system_memory_available_bytes', memory_info.available)
        
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        self.metrics.record_gauge('system_cpu_usage_percent', cpu_percent)
        
        # Disk usage
        disk_info = psutil.disk_usage('/')
        self.metrics.record_gauge('system_disk_usage_bytes', disk_info.used)
        self.metrics.record_gauge('system_disk_available_bytes', disk_info.free)
    
    def _collect_cache_metrics(self):
        """Collect cache-specific metrics"""
        # Get cache info
        info = self.cache.info()
        
        # Record cache statistics
        self.metrics.record_gauge('cache_connected_clients', info.get('connected_clients', 0))
        self.metrics.record_gauge('cache_used_memory', info.get('used_memory', 0))
        self.metrics.record_gauge('cache_keyspace_hits', info.get('keyspace_hits', 0))
        self.metrics.record_gauge('cache_keyspace_misses', info.get('keyspace_misses', 0))
        
        # Calculate hit ratio
        hits = info.get('keyspace_hits', 0)
        misses = info.get('keyspace_misses', 0)
        if hits + misses > 0:
            hit_ratio = hits / (hits + misses)
            self.metrics.record_gauge('cache_overall_hit_ratio', hit_ratio)
    
    def _collect_business_metrics(self):
        """Collect business-specific metrics"""
        # User experience metrics
        self.metrics.record_gauge('cache_user_satisfaction_score', self._calculate_user_satisfaction())
        
        # Cost metrics
        self.metrics.record_gauge('cache_cost_per_request', self._calculate_cost_per_request())
        
        # SLA metrics
        self.metrics.record_gauge('cache_sla_compliance_percent', self._calculate_sla_compliance())
```

### Cache Health Monitor

```python
class CacheHealthMonitor:
    def __init__(self, cache_client, health_checker, alert_manager):
        self.cache = cache_client
        self.health_checker = health_checker
        self.alerts = alert_manager
        self.health_checks = {}
        self.start_monitoring()
    
    def check_cache_health(self, node_id):
        """Check health of specific cache node"""
        health_status = {
            'node_id': node_id,
            'timestamp': time.time(),
            'overall_status': 'healthy',
            'checks': {}
        }
        
        try:
            # Check connectivity
            connectivity_status = self._check_connectivity(node_id)
            health_status['checks']['connectivity'] = connectivity_status
            
            # Check memory usage
            memory_status = self._check_memory_usage(node_id)
            health_status['checks']['memory'] = memory_status
            
            # Check response time
            response_time_status = self._check_response_time(node_id)
            health_status['checks']['response_time'] = response_time_status
            
            # Check replication
            replication_status = self._check_replication(node_id)
            health_status['checks']['replication'] = replication_status
            
            # Determine overall status
            if any(check['status'] == 'unhealthy' for check in health_status['checks'].values()):
                health_status['overall_status'] = 'unhealthy'
            elif any(check['status'] == 'degraded' for check in health_status['checks'].values()):
                health_status['overall_status'] = 'degraded'
            
            # Store health status
            self.health_checks[node_id] = health_status
            
            # Send alerts if needed
            self._evaluate_health_alerts(health_status)
            
            return health_status
            
        except Exception as e:
            health_status['overall_status'] = 'error'
            health_status['error'] = str(e)
            return health_status
    
    def _check_connectivity(self, node_id):
        """Check cache node connectivity"""
        try:
            start_time = time.time()
            self.cache.ping()
            response_time = time.time() - start_time
            
            if response_time < 1.0:
                return {'status': 'healthy', 'response_time': response_time}
            elif response_time < 5.0:
                return {'status': 'degraded', 'response_time': response_time}
            else:
                return {'status': 'unhealthy', 'response_time': response_time}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}
    
    def _check_memory_usage(self, node_id):
        """Check memory usage and eviction rates"""
        try:
            info = self.cache.info()
            used_memory = info.get('used_memory', 0)
            max_memory = info.get('maxmemory', 0)
            
            if max_memory > 0:
                memory_usage_percent = (used_memory / max_memory) * 100
                
                if memory_usage_percent < 80:
                    return {'status': 'healthy', 'usage_percent': memory_usage_percent}
                elif memory_usage_percent < 95:
                    return {'status': 'degraded', 'usage_percent': memory_usage_percent}
                else:
                    return {'status': 'unhealthy', 'usage_percent': memory_usage_percent}
            else:
                return {'status': 'healthy', 'usage_percent': 0}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}
    
    def _check_response_time(self, node_id):
        """Check cache response time"""
        try:
            start_time = time.time()
            self.cache.get('health_check_key')
            response_time = time.time() - start_time
            
            if response_time < 0.01:  # 10ms
                return {'status': 'healthy', 'response_time': response_time}
            elif response_time < 0.1:  # 100ms
                return {'status': 'degraded', 'response_time': response_time}
            else:
                return {'status': 'unhealthy', 'response_time': response_time}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}
    
    def _check_replication(self, node_id):
        """Check replication lag and consistency"""
        try:
            info = self.cache.info()
            replication_lag = info.get('master_repl_offset', 0) - info.get('slave_repl_offset', 0)
            
            if replication_lag < 1000:  # 1KB
                return {'status': 'healthy', 'lag': replication_lag}
            elif replication_lag < 10000:  # 10KB
                return {'status': 'degraded', 'lag': replication_lag}
            else:
                return {'status': 'unhealthy', 'lag': replication_lag}
        except Exception as e:
            return {'status': 'unhealthy', 'error': str(e)}
    
    def _evaluate_health_alerts(self, health_status):
        """Evaluate health status and send alerts if needed"""
        if health_status['overall_status'] == 'unhealthy':
            self.alerts.send_alert({
                'type': 'cache_node_unhealthy',
                'node_id': health_status['node_id'],
                'status': health_status['overall_status'],
                'checks': health_status['checks'],
                'timestamp': health_status['timestamp']
            })
        elif health_status['overall_status'] == 'degraded':
            self.alerts.send_alert({
                'type': 'cache_node_degraded',
                'node_id': health_status['node_id'],
                'status': health_status['overall_status'],
                'checks': health_status['checks'],
                'timestamp': health_status['timestamp']
            })
    
    def start_monitoring(self):
        """Start background health monitoring"""
        def monitor_health():
            while True:
                try:
                    # Check all cache nodes
                    for node_id in self._get_cache_nodes():
                        self.check_cache_health(node_id)
                    
                    time.sleep(30)  # Check every 30 seconds
                except Exception as e:
                    print(f"Error in health monitoring: {e}")
                    time.sleep(30)
        
        threading.Thread(target=monitor_health, daemon=True).start()
```

## Additional Resources

### Monitoring Tools
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Metrics visualization and dashboards
- **Jaeger**: Distributed tracing
- **ELK Stack**: Log aggregation and analysis

### Observability Standards
- [OpenTelemetry](https://opentelemetry.io/)
- [OpenTracing](https://opentracing.io/)
- [Prometheus Metrics](https://prometheus.io/docs/concepts/metric_types/)
- [Grafana Dashboards](https://grafana.com/docs/)

### Best Practices
- Implement comprehensive monitoring
- Use structured logging
- Set up proactive alerting
- Monitor business metrics
- Regular monitoring review and optimization

## Next Steps

After completing this exercise:
1. **Deploy**: Deploy monitoring system to production
2. **Monitor**: Set up comprehensive monitoring dashboards
3. **Alert**: Configure intelligent alerting
4. **Optimize**: Continuously optimize monitoring
5. **Improve**: Enhance monitoring based on insights

---

**Last Updated**: 2024-01-15  
**Version**: 1.0  
**Next Review**: 2024-02-15
