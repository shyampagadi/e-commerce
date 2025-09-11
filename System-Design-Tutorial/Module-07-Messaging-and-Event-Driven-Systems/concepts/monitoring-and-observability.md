# Messaging System Monitoring and Observability

## Overview
Comprehensive monitoring and observability are critical for maintaining reliable messaging systems at scale. This guide covers the three pillars of observability (metrics, logs, traces), alerting strategies, and performance optimization techniques for event-driven architectures.

## The Three Pillars of Observability

### 1. Metrics - What is Happening
Quantitative measurements that provide insights into system behavior and performance.

#### Core Messaging Metrics
```python
from dataclasses import dataclass
from typing import Dict, List
import time
from collections import defaultdict, deque

@dataclass
class MessageMetrics:
    timestamp: float
    queue_name: str
    messages_sent: int
    messages_received: int
    messages_failed: int
    processing_latency_ms: float
    queue_depth: int
    consumer_count: int

class MetricsCollector:
    def __init__(self):
        self.metrics_buffer = deque(maxlen=1000)
        self.counters = defaultdict(int)
        self.gauges = defaultdict(float)
        self.histograms = defaultdict(list)
        
    def record_message_sent(self, queue_name: str, message_size_bytes: int):
        """Record message sent metrics"""
        self.counters[f'{queue_name}.messages_sent'] += 1
        self.counters[f'{queue_name}.bytes_sent'] += message_size_bytes
        self.histograms[f'{queue_name}.message_size'].append(message_size_bytes)
        
    def record_message_processed(self, queue_name: str, processing_time_ms: float, success: bool):
        """Record message processing metrics"""
        if success:
            self.counters[f'{queue_name}.messages_processed'] += 1
        else:
            self.counters[f'{queue_name}.messages_failed'] += 1
            
        self.histograms[f'{queue_name}.processing_latency'].append(processing_time_ms)
        
    def record_queue_depth(self, queue_name: str, depth: int):
        """Record current queue depth"""
        self.gauges[f'{queue_name}.queue_depth'] = depth
        
    def get_throughput_metrics(self, queue_name: str, time_window_seconds: int = 60) -> Dict:
        """Calculate throughput metrics for time window"""
        
        current_time = time.time()
        window_start = current_time - time_window_seconds
        
        # Filter metrics within time window
        window_metrics = [
            m for m in self.metrics_buffer 
            if m.timestamp >= window_start and m.queue_name == queue_name
        ]
        
        if not window_metrics:
            return {'messages_per_second': 0, 'avg_latency_ms': 0}
        
        total_messages = sum(m.messages_received for m in window_metrics)
        total_latency = sum(m.processing_latency_ms for m in window_metrics)
        
        return {
            'messages_per_second': total_messages / time_window_seconds,
            'avg_latency_ms': total_latency / len(window_metrics) if window_metrics else 0,
            'error_rate': sum(m.messages_failed for m in window_metrics) / total_messages if total_messages > 0 else 0
        }
    
    def calculate_percentiles(self, metric_name: str, percentiles: List[float] = [50, 95, 99]) -> Dict:
        """Calculate percentile values for histogram metrics"""
        
        values = self.histograms.get(metric_name, [])
        if not values:
            return {f'p{p}': 0 for p in percentiles}
        
        sorted_values = sorted(values)
        result = {}
        
        for p in percentiles:
            index = int((p / 100) * len(sorted_values))
            index = min(index, len(sorted_values) - 1)
            result[f'p{p}'] = sorted_values[index]
        
        return result

# Usage Example
metrics = MetricsCollector()

# Record metrics during message processing
async def process_message_with_metrics(queue_name: str, message: Dict):
    start_time = time.time()
    
    try:
        # Process message
        await process_message(message)
        
        # Record success metrics
        processing_time = (time.time() - start_time) * 1000
        metrics.record_message_processed(queue_name, processing_time, True)
        
    except Exception as e:
        # Record failure metrics
        processing_time = (time.time() - start_time) * 1000
        metrics.record_message_processed(queue_name, processing_time, False)
        raise
```

#### Key Performance Indicators (KPIs)
| Metric Category | Key Metrics | Target Values | Alert Thresholds |
|-----------------|-------------|---------------|------------------|
| **Throughput** | Messages/second, Bytes/second | Baseline + 20% | >80% capacity |
| **Latency** | P50, P95, P99 processing time | <100ms P95 | >SLA limits |
| **Reliability** | Error rate, Success rate | >99.9% success | >1% error rate |
| **Capacity** | Queue depth, Consumer lag | <1000 messages | >5000 messages |
| **Resource** | CPU, Memory, Network I/O | <70% utilization | >85% utilization |

### 2. Logs - What Happened
Structured logs provide detailed context about system events and errors.

```python
import json
import logging
from datetime import datetime
from typing import Any, Dict, Optional

class StructuredLogger:
    def __init__(self, service_name: str):
        self.service_name = service_name
        self.logger = logging.getLogger(service_name)
        
        # Configure structured logging
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
        
    def log_message_event(self, event_type: str, message_id: str, 
                         queue_name: str, additional_data: Optional[Dict] = None):
        """Log structured message processing event"""
        
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'service': self.service_name,
            'event_type': event_type,
            'message_id': message_id,
            'queue_name': queue_name,
            'correlation_id': self._get_correlation_id(),
            **additional_data or {}
        }
        
        self.logger.info(json.dumps(log_entry))
    
    def log_error(self, error: Exception, context: Dict[str, Any]):
        """Log error with full context"""
        
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'service': self.service_name,
            'level': 'ERROR',
            'error_type': type(error).__name__,
            'error_message': str(error),
            'correlation_id': self._get_correlation_id(),
            'context': context
        }
        
        self.logger.error(json.dumps(log_entry))
    
    def log_performance_metrics(self, operation: str, duration_ms: float, 
                              success: bool, metadata: Optional[Dict] = None):
        """Log performance metrics"""
        
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'service': self.service_name,
            'event_type': 'performance_metric',
            'operation': operation,
            'duration_ms': duration_ms,
            'success': success,
            'correlation_id': self._get_correlation_id(),
            **(metadata or {})
        }
        
        self.logger.info(json.dumps(log_entry))
    
    def _get_correlation_id(self) -> str:
        """Get correlation ID from context (implementation specific)"""
        # In real implementation, this would extract from thread-local storage
        # or request context
        return "correlation-id-placeholder"

# Usage Example
logger = StructuredLogger('order-processing-service')

async def process_order_message(message: Dict):
    message_id = message.get('message_id')
    start_time = time.time()
    
    try:
        logger.log_message_event('message_received', message_id, 'order-queue', {
            'customer_id': message.get('customer_id'),
            'order_value': message.get('total_amount')
        })
        
        # Process order
        result = await process_order(message)
        
        # Log success
        duration = (time.time() - start_time) * 1000
        logger.log_performance_metrics('process_order', duration, True, {
            'message_id': message_id,
            'result_status': result.get('status')
        })
        
    except Exception as e:
        # Log error with context
        duration = (time.time() - start_time) * 1000
        logger.log_error(e, {
            'message_id': message_id,
            'operation': 'process_order',
            'duration_ms': duration,
            'message_data': message
        })
        
        logger.log_performance_metrics('process_order', duration, False, {
            'message_id': message_id,
            'error_type': type(e).__name__
        })
        
        raise
```

### 3. Traces - How Things are Connected
Distributed tracing shows request flow across multiple services.

```python
import uuid
from contextlib import contextmanager
from typing import Optional, Dict, Any
import time

class TraceContext:
    def __init__(self, trace_id: str, span_id: str, parent_span_id: Optional[str] = None):
        self.trace_id = trace_id
        self.span_id = span_id
        self.parent_span_id = parent_span_id
        self.baggage: Dict[str, str] = {}

class Span:
    def __init__(self, operation_name: str, trace_context: TraceContext):
        self.operation_name = operation_name
        self.trace_context = trace_context
        self.start_time = time.time()
        self.end_time: Optional[float] = None
        self.tags: Dict[str, Any] = {}
        self.logs: List[Dict[str, Any]] = []
        self.status = 'ok'
        
    def set_tag(self, key: str, value: Any):
        """Set span tag"""
        self.tags[key] = value
        
    def log_event(self, event: str, payload: Optional[Dict] = None):
        """Log event within span"""
        self.logs.append({
            'timestamp': time.time(),
            'event': event,
            'payload': payload or {}
        })
        
    def set_error(self, error: Exception):
        """Mark span as error"""
        self.status = 'error'
        self.set_tag('error', True)
        self.set_tag('error.type', type(error).__name__)
        self.set_tag('error.message', str(error))
        
    def finish(self):
        """Finish span"""
        self.end_time = time.time()
        
    def duration_ms(self) -> float:
        """Get span duration in milliseconds"""
        end = self.end_time or time.time()
        return (end - self.start_time) * 1000

class DistributedTracer:
    def __init__(self):
        self.active_spans: Dict[str, Span] = {}
        
    def start_span(self, operation_name: str, 
                   parent_context: Optional[TraceContext] = None) -> Span:
        """Start new span"""
        
        if parent_context:
            trace_id = parent_context.trace_id
            parent_span_id = parent_context.span_id
        else:
            trace_id = str(uuid.uuid4())
            parent_span_id = None
            
        span_id = str(uuid.uuid4())
        trace_context = TraceContext(trace_id, span_id, parent_span_id)
        
        span = Span(operation_name, trace_context)
        self.active_spans[span_id] = span
        
        return span
    
    def finish_span(self, span: Span):
        """Finish and record span"""
        span.finish()
        
        # In real implementation, send to tracing backend (Jaeger, X-Ray, etc.)
        self._send_span_to_backend(span)
        
        # Clean up
        self.active_spans.pop(span.trace_context.span_id, None)
    
    def _send_span_to_backend(self, span: Span):
        """Send span to tracing backend"""
        span_data = {
            'trace_id': span.trace_context.trace_id,
            'span_id': span.trace_context.span_id,
            'parent_span_id': span.trace_context.parent_span_id,
            'operation_name': span.operation_name,
            'start_time': span.start_time,
            'end_time': span.end_time,
            'duration_ms': span.duration_ms(),
            'tags': span.tags,
            'logs': span.logs,
            'status': span.status
        }
        
        # Send to backend (implementation specific)
        print(f"Sending span to backend: {json.dumps(span_data, indent=2)}")

# Usage Example with Message Processing
tracer = DistributedTracer()

async def process_message_with_tracing(message: Dict, parent_context: Optional[TraceContext] = None):
    """Process message with distributed tracing"""
    
    # Start span for message processing
    span = tracer.start_span('process_message', parent_context)
    
    try:
        # Add tags
        span.set_tag('message.id', message.get('message_id'))
        span.set_tag('message.type', message.get('message_type'))
        span.set_tag('queue.name', message.get('queue_name'))
        
        # Log processing start
        span.log_event('processing_started', {'message_size': len(str(message))})
        
        # Simulate processing steps with child spans
        await validate_message_with_tracing(message, span.trace_context)
        await store_message_with_tracing(message, span.trace_context)
        await notify_downstream_with_tracing(message, span.trace_context)
        
        # Log success
        span.log_event('processing_completed')
        
    except Exception as e:
        span.set_error(e)
        span.log_event('processing_failed', {'error': str(e)})
        raise
    finally:
        tracer.finish_span(span)

async def validate_message_with_tracing(message: Dict, parent_context: TraceContext):
    """Validate message with child span"""
    
    span = tracer.start_span('validate_message', parent_context)
    
    try:
        span.set_tag('validation.schema_version', '1.0')
        
        # Simulate validation
        await asyncio.sleep(0.01)
        
        span.log_event('validation_completed', {'valid': True})
        
    except Exception as e:
        span.set_error(e)
        raise
    finally:
        tracer.finish_span(span)
```

## Alerting and Monitoring Strategies

### Alert Severity Levels
```python
from enum import Enum
from dataclasses import dataclass
from typing import List, Dict, Callable

class AlertSeverity(Enum):
    CRITICAL = "critical"    # Immediate action required
    HIGH = "high"           # Action required within 1 hour
    MEDIUM = "medium"       # Action required within 4 hours
    LOW = "low"            # Action required within 24 hours
    INFO = "info"          # Informational only

@dataclass
class AlertRule:
    name: str
    description: str
    severity: AlertSeverity
    metric_name: str
    threshold: float
    comparison: str  # 'gt', 'lt', 'eq'
    duration_minutes: int
    notification_channels: List[str]

class AlertManager:
    def __init__(self):
        self.rules: List[AlertRule] = []
        self.active_alerts: Dict[str, Dict] = {}
        
    def add_rule(self, rule: AlertRule):
        """Add alerting rule"""
        self.rules.append(rule)
    
    def evaluate_rules(self, metrics: Dict[str, float]):
        """Evaluate all alerting rules against current metrics"""
        
        for rule in self.rules:
            if rule.metric_name in metrics:
                current_value = metrics[rule.metric_name]
                
                if self._evaluate_condition(current_value, rule.threshold, rule.comparison):
                    self._trigger_alert(rule, current_value)
                else:
                    self._resolve_alert(rule.name)
    
    def _evaluate_condition(self, value: float, threshold: float, comparison: str) -> bool:
        """Evaluate alert condition"""
        if comparison == 'gt':
            return value > threshold
        elif comparison == 'lt':
            return value < threshold
        elif comparison == 'eq':
            return value == threshold
        return False
    
    def _trigger_alert(self, rule: AlertRule, current_value: float):
        """Trigger alert if not already active"""
        
        if rule.name not in self.active_alerts:
            alert = {
                'rule_name': rule.name,
                'severity': rule.severity.value,
                'description': rule.description,
                'current_value': current_value,
                'threshold': rule.threshold,
                'triggered_at': datetime.utcnow().isoformat()
            }
            
            self.active_alerts[rule.name] = alert
            self._send_notifications(rule, alert)
    
    def _resolve_alert(self, rule_name: str):
        """Resolve alert if active"""
        
        if rule_name in self.active_alerts:
            alert = self.active_alerts.pop(rule_name)
            alert['resolved_at'] = datetime.utcnow().isoformat()
            
            # Send resolution notification
            print(f"Alert resolved: {rule_name}")
    
    def _send_notifications(self, rule: AlertRule, alert: Dict):
        """Send alert notifications"""
        
        for channel in rule.notification_channels:
            if channel == 'slack':
                self._send_slack_notification(alert)
            elif channel == 'email':
                self._send_email_notification(alert)
            elif channel == 'pagerduty':
                self._send_pagerduty_notification(alert)

# Example: Setting up messaging system alerts
alert_manager = AlertManager()

# Critical alerts
alert_manager.add_rule(AlertRule(
    name="high_message_processing_latency",
    description="Message processing latency is above SLA",
    severity=AlertSeverity.CRITICAL,
    metric_name="processing_latency_p95_ms",
    threshold=1000.0,  # 1 second
    comparison="gt",
    duration_minutes=5,
    notification_channels=["pagerduty", "slack"]
))

alert_manager.add_rule(AlertRule(
    name="message_processing_error_rate",
    description="High message processing error rate",
    severity=AlertSeverity.HIGH,
    metric_name="error_rate_percentage",
    threshold=5.0,  # 5%
    comparison="gt",
    duration_minutes=10,
    notification_channels=["slack", "email"]
))

# Capacity alerts
alert_manager.add_rule(AlertRule(
    name="queue_depth_high",
    description="Queue depth is growing rapidly",
    severity=AlertSeverity.MEDIUM,
    metric_name="queue_depth",
    threshold=10000,
    comparison="gt",
    duration_minutes=15,
    notification_channels=["slack"]
))
```

## Performance Monitoring and Optimization

### Real-time Performance Dashboard
```python
class PerformanceDashboard:
    def __init__(self):
        self.metrics_collector = MetricsCollector()
        self.time_series_data = defaultdict(deque)
        
    def update_dashboard_metrics(self):
        """Update real-time dashboard metrics"""
        
        current_time = time.time()
        
        # Collect current metrics
        dashboard_data = {
            'timestamp': current_time,
            'throughput': {
                'messages_per_second': self._calculate_current_throughput(),
                'bytes_per_second': self._calculate_current_bandwidth()
            },
            'latency': {
                'p50_ms': self._get_latency_percentile(50),
                'p95_ms': self._get_latency_percentile(95),
                'p99_ms': self._get_latency_percentile(99)
            },
            'reliability': {
                'success_rate': self._calculate_success_rate(),
                'error_rate': self._calculate_error_rate()
            },
            'capacity': {
                'queue_depths': self._get_queue_depths(),
                'consumer_counts': self._get_consumer_counts(),
                'cpu_utilization': self._get_cpu_utilization(),
                'memory_utilization': self._get_memory_utilization()
            }
        }
        
        # Store time series data (keep last 24 hours)
        max_points = 24 * 60  # 1 point per minute for 24 hours
        for metric_category, metrics in dashboard_data.items():
            if metric_category != 'timestamp':
                for metric_name, value in metrics.items():
                    key = f"{metric_category}.{metric_name}"
                    self.time_series_data[key].append((current_time, value))
                    
                    # Trim old data
                    while len(self.time_series_data[key]) > max_points:
                        self.time_series_data[key].popleft()
        
        return dashboard_data
    
    def get_performance_trends(self, metric_name: str, hours: int = 1) -> Dict:
        """Get performance trends for specified time period"""
        
        current_time = time.time()
        start_time = current_time - (hours * 3600)
        
        # Filter data points within time range
        data_points = [
            (timestamp, value) for timestamp, value in self.time_series_data[metric_name]
            if timestamp >= start_time
        ]
        
        if len(data_points) < 2:
            return {'trend': 'insufficient_data'}
        
        # Calculate trend
        values = [point[1] for point in data_points]
        
        # Simple linear trend calculation
        n = len(values)
        sum_x = sum(range(n))
        sum_y = sum(values)
        sum_xy = sum(i * values[i] for i in range(n))
        sum_x2 = sum(i * i for i in range(n))
        
        slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
        
        return {
            'trend': 'increasing' if slope > 0 else 'decreasing' if slope < 0 else 'stable',
            'slope': slope,
            'current_value': values[-1],
            'min_value': min(values),
            'max_value': max(values),
            'avg_value': sum(values) / len(values)
        }
```

### Automated Performance Optimization
```python
class AutoOptimizer:
    def __init__(self, metrics_collector: MetricsCollector):
        self.metrics = metrics_collector
        self.optimization_history = []
        
    async def optimize_consumer_scaling(self, queue_name: str):
        """Automatically optimize consumer scaling based on metrics"""
        
        # Get current metrics
        throughput_metrics = self.metrics.get_throughput_metrics(queue_name)
        queue_depth = self.metrics.gauges.get(f'{queue_name}.queue_depth', 0)
        
        current_consumers = self.metrics.gauges.get(f'{queue_name}.consumer_count', 1)
        messages_per_second = throughput_metrics['messages_per_second']
        avg_latency = throughput_metrics['avg_latency_ms']
        
        # Optimization logic
        optimization_action = None
        
        if queue_depth > 1000 and avg_latency > 500:
            # Scale up consumers
            new_consumer_count = min(current_consumers * 2, 50)  # Max 50 consumers
            optimization_action = {
                'action': 'scale_up',
                'from_consumers': current_consumers,
                'to_consumers': new_consumer_count,
                'reason': 'high_queue_depth_and_latency'
            }
            
        elif queue_depth < 100 and avg_latency < 100 and current_consumers > 1:
            # Scale down consumers
            new_consumer_count = max(current_consumers // 2, 1)  # Min 1 consumer
            optimization_action = {
                'action': 'scale_down',
                'from_consumers': current_consumers,
                'to_consumers': new_consumer_count,
                'reason': 'low_queue_depth_and_latency'
            }
        
        if optimization_action:
            # Execute optimization
            await self._execute_scaling_action(queue_name, optimization_action)
            
            # Record optimization
            self.optimization_history.append({
                'timestamp': time.time(),
                'queue_name': queue_name,
                **optimization_action
            })
    
    async def _execute_scaling_action(self, queue_name: str, action: Dict):
        """Execute scaling action"""
        
        # In real implementation, this would call container orchestration APIs
        # (ECS, Kubernetes, etc.) to scale consumer instances
        
        print(f"Executing scaling action for {queue_name}: {action}")
        
        # Update metrics to reflect new consumer count
        self.metrics.gauges[f'{queue_name}.consumer_count'] = action['to_consumers']
```

This comprehensive monitoring and observability framework provides the foundation for maintaining reliable, high-performance messaging systems with proactive optimization and alerting capabilities.
