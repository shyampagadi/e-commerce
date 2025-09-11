# Error Handling and Recovery in Messaging Systems

## Overview
Robust error handling and recovery mechanisms are critical for building resilient messaging systems. This guide covers comprehensive strategies for handling failures, implementing retry mechanisms, and ensuring system reliability.

## Error Types and Classification

### Transient Errors
```python
class TransientError(Exception):
    """Errors that may resolve themselves with retry"""
    pass

class NetworkTimeoutError(TransientError):
    pass

class ServiceUnavailableError(TransientError):
    pass

class ThrottlingError(TransientError):
    pass
```

### Permanent Errors
```python
class PermanentError(Exception):
    """Errors that won't resolve with retry"""
    pass

class InvalidMessageFormatError(PermanentError):
    pass

class AuthenticationError(PermanentError):
    pass

class MessageTooLargeError(PermanentError):
    pass
```

## Retry Strategies

### Exponential Backoff
```python
import time
import random
from typing import Callable, Any

class ExponentialBackoffRetry:
    def __init__(self, max_retries=3, base_delay=1, max_delay=60, jitter=True):
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.jitter = jitter
    
    def execute(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with exponential backoff retry"""
        last_exception = None
        
        for attempt in range(self.max_retries + 1):
            try:
                return func(*args, **kwargs)
            except TransientError as e:
                last_exception = e
                if attempt == self.max_retries:
                    break
                
                # Calculate delay
                delay = min(self.base_delay * (2 ** attempt), self.max_delay)
                
                # Add jitter to prevent thundering herd
                if self.jitter:
                    delay *= (0.5 + random.random() * 0.5)
                
                time.sleep(delay)
            except PermanentError:
                # Don't retry permanent errors
                raise
        
        raise last_exception

# Usage example
retry_handler = ExponentialBackoffRetry(max_retries=3, base_delay=1)

def send_message_with_retry(message):
    return retry_handler.execute(sqs_client.send_message, message)
```

### Circuit Breaker Pattern
```python
import time
from enum import Enum
from threading import Lock

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
        self.lock = Lock()
    
    def call(self, func, *args, **kwargs):
        """Execute function with circuit breaker protection"""
        with self.lock:
            if self.state == CircuitState.OPEN:
                if self._should_attempt_reset():
                    self.state = CircuitState.HALF_OPEN
                else:
                    raise CircuitBreakerOpenException("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except self.expected_exception as e:
            self._on_failure()
            raise e
    
    def _should_attempt_reset(self):
        return (time.time() - self.last_failure_time) >= self.recovery_timeout
    
    def _on_success(self):
        with self.lock:
            self.failure_count = 0
            self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        with self.lock:
            self.failure_count += 1
            self.last_failure_time = time.time()
            
            if self.failure_count >= self.failure_threshold:
                self.state = CircuitState.OPEN

class CircuitBreakerOpenException(Exception):
    pass
```

## Dead Letter Queue Implementation

### SQS Dead Letter Queue
```python
import boto3
import json
from datetime import datetime

class DeadLetterQueueHandler:
    def __init__(self, main_queue_url, dlq_url):
        self.sqs = boto3.client('sqs')
        self.main_queue_url = main_queue_url
        self.dlq_url = dlq_url
        self.max_retries = 3
    
    def process_with_dlq(self, message_handler):
        """Process messages with DLQ fallback"""
        while True:
            try:
                messages = self.sqs.receive_message(
                    QueueUrl=self.main_queue_url,
                    MaxNumberOfMessages=10,
                    WaitTimeSeconds=20,
                    MessageAttributeNames=['All']
                ).get('Messages', [])
                
                for message in messages:
                    try:
                        # Track retry count
                        retry_count = int(message.get('Attributes', {}).get('ApproximateReceiveCount', 0))
                        
                        if retry_count > self.max_retries:
                            self._send_to_dlq(message, "Max retries exceeded")
                            self._delete_message(message)
                            continue
                        
                        # Process message
                        message_handler(message)
                        self._delete_message(message)
                        
                    except PermanentError as e:
                        # Send directly to DLQ for permanent errors
                        self._send_to_dlq(message, f"Permanent error: {str(e)}")
                        self._delete_message(message)
                    except Exception as e:
                        # Let transient errors retry naturally
                        print(f"Transient error, will retry: {e}")
                        
            except Exception as e:
                print(f"Error in message processing loop: {e}")
                time.sleep(5)
    
    def _send_to_dlq(self, original_message, error_reason):
        """Send message to dead letter queue with error context"""
        dlq_message = {
            'originalMessage': original_message['Body'],
            'originalAttributes': original_message.get('MessageAttributes', {}),
            'errorReason': error_reason,
            'failedAt': datetime.now().isoformat(),
            'originalMessageId': original_message['MessageId']
        }
        
        self.sqs.send_message(
            QueueUrl=self.dlq_url,
            MessageBody=json.dumps(dlq_message),
            MessageAttributes={
                'ErrorType': {
                    'StringValue': 'ProcessingFailure',
                    'DataType': 'String'
                },
                'OriginalQueue': {
                    'StringValue': self.main_queue_url,
                    'DataType': 'String'
                }
            }
        )
    
    def _delete_message(self, message):
        """Delete message from main queue"""
        self.sqs.delete_message(
            QueueUrl=self.main_queue_url,
            ReceiptHandle=message['ReceiptHandle']
        )
```

### DLQ Analysis and Recovery
```python
class DLQAnalyzer:
    def __init__(self, dlq_url):
        self.sqs = boto3.client('sqs')
        self.dlq_url = dlq_url
    
    def analyze_failed_messages(self):
        """Analyze patterns in failed messages"""
        error_patterns = {}
        message_count = 0
        
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.dlq_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=1
            ).get('Messages', [])
            
            if not messages:
                break
            
            for message in messages:
                message_count += 1
                try:
                    dlq_data = json.loads(message['Body'])
                    error_reason = dlq_data.get('errorReason', 'Unknown')
                    
                    # Categorize errors
                    error_category = self._categorize_error(error_reason)
                    if error_category not in error_patterns:
                        error_patterns[error_category] = 0
                    error_patterns[error_category] += 1
                    
                except Exception as e:
                    print(f"Error analyzing DLQ message: {e}")
        
        return {
            'total_messages': message_count,
            'error_patterns': error_patterns,
            'analysis_timestamp': datetime.now().isoformat()
        }
    
    def _categorize_error(self, error_reason):
        """Categorize error for pattern analysis"""
        if 'timeout' in error_reason.lower():
            return 'timeout'
        elif 'format' in error_reason.lower():
            return 'format_error'
        elif 'authentication' in error_reason.lower():
            return 'auth_error'
        elif 'validation' in error_reason.lower():
            return 'validation_error'
        else:
            return 'other'
    
    def replay_messages(self, target_queue_url, filter_func=None):
        """Replay messages from DLQ to target queue"""
        replayed_count = 0
        
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.dlq_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=1
            ).get('Messages', [])
            
            if not messages:
                break
            
            for message in messages:
                try:
                    dlq_data = json.loads(message['Body'])
                    
                    # Apply filter if provided
                    if filter_func and not filter_func(dlq_data):
                        continue
                    
                    # Send original message to target queue
                    self.sqs.send_message(
                        QueueUrl=target_queue_url,
                        MessageBody=dlq_data['originalMessage'],
                        MessageAttributes=dlq_data.get('originalAttributes', {})
                    )
                    
                    # Delete from DLQ
                    self.sqs.delete_message(
                        QueueUrl=self.dlq_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                    
                    replayed_count += 1
                    
                except Exception as e:
                    print(f"Error replaying message: {e}")
        
        return replayed_count
```

## Poison Message Detection

### Poison Message Handler
```python
class PoisonMessageDetector:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.poison_threshold = 5
        self.time_window = 3600  # 1 hour
    
    def is_poison_message(self, message_id):
        """Check if message is poison based on failure history"""
        key = f"message_failures:{message_id}"
        failure_count = self.redis.get(key)
        
        if failure_count and int(failure_count) >= self.poison_threshold:
            return True
        return False
    
    def record_failure(self, message_id):
        """Record message processing failure"""
        key = f"message_failures:{message_id}"
        pipe = self.redis.pipeline()
        pipe.incr(key)
        pipe.expire(key, self.time_window)
        pipe.execute()
    
    def quarantine_poison_message(self, message, reason):
        """Quarantine poison message for manual review"""
        quarantine_data = {
            'messageId': message.get('MessageId'),
            'messageBody': message.get('Body'),
            'quarantineReason': reason,
            'quarantineTime': datetime.now().isoformat(),
            'failureCount': self.redis.get(f"message_failures:{message.get('MessageId')}")
        }
        
        # Store in quarantine queue or database
        self.redis.lpush('poison_messages', json.dumps(quarantine_data))
```

## Graceful Degradation

### Service Degradation Manager
```python
class ServiceDegradationManager:
    def __init__(self):
        self.degradation_levels = {
            'normal': 0,
            'light_degradation': 1,
            'moderate_degradation': 2,
            'severe_degradation': 3,
            'emergency_mode': 4
        }
        self.current_level = 0
    
    def assess_system_health(self, metrics):
        """Assess system health and determine degradation level"""
        error_rate = metrics.get('error_rate', 0)
        queue_depth = metrics.get('queue_depth', 0)
        processing_latency = metrics.get('processing_latency', 0)
        
        if error_rate > 0.5 or queue_depth > 100000:
            return self.degradation_levels['emergency_mode']
        elif error_rate > 0.2 or queue_depth > 50000:
            return self.degradation_levels['severe_degradation']
        elif error_rate > 0.1 or queue_depth > 20000:
            return self.degradation_levels['moderate_degradation']
        elif error_rate > 0.05 or queue_depth > 10000:
            return self.degradation_levels['light_degradation']
        else:
            return self.degradation_levels['normal']
    
    def apply_degradation(self, level):
        """Apply degradation measures based on level"""
        if level >= self.degradation_levels['light_degradation']:
            self._reduce_message_processing_rate()
        
        if level >= self.degradation_levels['moderate_degradation']:
            self._disable_non_critical_features()
        
        if level >= self.degradation_levels['severe_degradation']:
            self._enable_circuit_breakers()
        
        if level >= self.degradation_levels['emergency_mode']:
            self._activate_emergency_protocols()
    
    def _reduce_message_processing_rate(self):
        """Reduce message processing rate to prevent overload"""
        # Implement rate limiting logic
        pass
    
    def _disable_non_critical_features(self):
        """Disable non-critical features to preserve resources"""
        # Implement feature toggling logic
        pass
    
    def _enable_circuit_breakers(self):
        """Enable circuit breakers for downstream services"""
        # Implement circuit breaker activation
        pass
    
    def _activate_emergency_protocols(self):
        """Activate emergency protocols"""
        # Implement emergency response logic
        pass
```

## Monitoring and Alerting

### Error Monitoring
```python
class ErrorMonitoring:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
    
    def track_error_metrics(self, error_type, service_name, additional_dimensions=None):
        """Track error metrics in CloudWatch"""
        dimensions = [
            {'Name': 'ServiceName', 'Value': service_name},
            {'Name': 'ErrorType', 'Value': error_type}
        ]
        
        if additional_dimensions:
            dimensions.extend(additional_dimensions)
        
        self.cloudwatch.put_metric_data(
            Namespace='Messaging/Errors',
            MetricData=[
                {
                    'MetricName': 'ErrorCount',
                    'Value': 1,
                    'Unit': 'Count',
                    'Dimensions': dimensions,
                    'Timestamp': datetime.now()
                }
            ]
        )
    
    def create_error_alarms(self):
        """Create CloudWatch alarms for error conditions"""
        alarms = [
            {
                'AlarmName': 'HighErrorRate',
                'MetricName': 'ErrorCount',
                'Threshold': 100,
                'ComparisonOperator': 'GreaterThanThreshold',
                'EvaluationPeriods': 2,
                'Period': 300
            },
            {
                'AlarmName': 'DLQDepthHigh',
                'MetricName': 'ApproximateNumberOfMessages',
                'Threshold': 1000,
                'ComparisonOperator': 'GreaterThanThreshold',
                'EvaluationPeriods': 1,
                'Period': 300
            }
        ]
        
        for alarm in alarms:
            self.cloudwatch.put_metric_alarm(**alarm)
```

## Best Practices

### Error Handling Guidelines
1. **Classify Errors**: Distinguish between transient and permanent errors
2. **Implement Retries**: Use exponential backoff with jitter
3. **Use Circuit Breakers**: Prevent cascading failures
4. **Monitor Error Patterns**: Track and analyze error trends
5. **Implement DLQs**: Handle messages that can't be processed
6. **Plan for Degradation**: Design graceful degradation strategies

### Recovery Strategies
1. **Automated Recovery**: Implement self-healing mechanisms
2. **Manual Intervention**: Provide tools for manual recovery
3. **Data Consistency**: Ensure data consistency during recovery
4. **Testing**: Regularly test recovery procedures
5. **Documentation**: Document recovery procedures and runbooks

## Conclusion

Robust error handling and recovery mechanisms are essential for building resilient messaging systems. Key strategies include:

- **Comprehensive Error Classification**: Understanding different error types
- **Intelligent Retry Logic**: Implementing appropriate retry strategies
- **Circuit Breaker Protection**: Preventing cascading failures
- **Dead Letter Queue Management**: Handling unprocessable messages
- **Graceful Degradation**: Maintaining service during failures
- **Comprehensive Monitoring**: Tracking errors and system health

These patterns ensure your messaging systems can handle failures gracefully and recover quickly from adverse conditions.
