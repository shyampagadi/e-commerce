# Message Ordering and Delivery Guarantees

## Overview
Message ordering and delivery guarantees are critical aspects of messaging systems that determine how messages are processed, delivered, and handled in distributed systems. Understanding these concepts is essential for building reliable event-driven architectures.

## Delivery Guarantees

### At-Most-Once Delivery
Messages are delivered zero or one time, but never more than once. Messages may be lost but never duplicated.

```python
import boto3
import logging

class AtMostOnceProducer:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.logger = logging.getLogger(__name__)
    
    def send_message(self, message_body):
        try:
            response = self.sqs.send_message(
                QueueUrl=self.queue_url,
                MessageBody=message_body
            )
            self.logger.info(f"Message sent: {response['MessageId']}")
            return response['MessageId']
        except Exception as e:
            self.logger.error(f"Failed to send message: {e}")
            # Don't retry - accept message loss
            return None

class AtMostOnceConsumer:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
    
    def process_messages(self):
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.queue_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20
            ).get('Messages', [])
            
            for message in messages:
                try:
                    # Process message
                    self.handle_message(message['Body'])
                    
                    # Delete immediately after processing
                    self.sqs.delete_message(
                        QueueUrl=self.queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                except Exception as e:
                    # If processing fails, message is lost
                    self.logger.error(f"Processing failed: {e}")
                    # Still delete to avoid reprocessing
                    self.sqs.delete_message(
                        QueueUrl=self.queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
```

### At-Least-Once Delivery
Messages are delivered one or more times. Messages are never lost but may be duplicated.

```python
class AtLeastOnceProducer:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.max_retries = 3
    
    def send_message_with_retry(self, message_body, message_id=None):
        for attempt in range(self.max_retries + 1):
            try:
                response = self.sqs.send_message(
                    QueueUrl=self.queue_url,
                    MessageBody=message_body,
                    MessageDeduplicationId=message_id,  # For FIFO queues
                    MessageGroupId='default'  # For FIFO queues
                )
                return response['MessageId']
            except Exception as e:
                if attempt == self.max_retries:
                    raise e
                time.sleep(2 ** attempt)  # Exponential backoff

class AtLeastOnceConsumer:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.processed_messages = set()  # Simple deduplication
    
    def process_messages(self):
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.queue_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20,
                VisibilityTimeout=300  # 5 minutes to process
            ).get('Messages', [])
            
            for message in messages:
                message_id = message.get('MessageId')
                
                # Simple deduplication check
                if message_id in self.processed_messages:
                    self.sqs.delete_message(
                        QueueUrl=self.queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                    continue
                
                try:
                    # Process message
                    self.handle_message(message['Body'])
                    
                    # Mark as processed
                    self.processed_messages.add(message_id)
                    
                    # Delete after successful processing
                    self.sqs.delete_message(
                        QueueUrl=self.queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                except Exception as e:
                    # Message will become visible again for retry
                    self.logger.error(f"Processing failed, will retry: {e}")
```

### Exactly-Once Delivery
Messages are delivered exactly once. This is the most complex guarantee to implement.

```python
import hashlib
import json
from datetime import datetime, timedelta

class ExactlyOnceProcessor:
    def __init__(self, queue_url, dynamodb_table):
        self.sqs = boto3.client('sqs')
        self.dynamodb = boto3.resource('dynamodb')
        self.queue_url = queue_url
        self.idempotency_table = self.dynamodb.Table(dynamodb_table)
    
    def process_messages(self):
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.queue_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20
            ).get('Messages', [])
            
            for message in messages:
                # Create idempotency key
                idempotency_key = self._create_idempotency_key(message)
                
                try:
                    # Check if already processed
                    if self._is_already_processed(idempotency_key):
                        self._delete_message(message)
                        continue
                    
                    # Process with idempotency record
                    result = self._process_with_idempotency(
                        message, 
                        idempotency_key
                    )
                    
                    if result:
                        self._delete_message(message)
                
                except Exception as e:
                    self.logger.error(f"Processing failed: {e}")
    
    def _create_idempotency_key(self, message):
        """Create deterministic key for message"""
        content = {
            'messageId': message.get('MessageId'),
            'body': message.get('Body'),
            'md5': message.get('MD5OfBody')
        }
        return hashlib.sha256(
            json.dumps(content, sort_keys=True).encode()
        ).hexdigest()
    
    def _is_already_processed(self, idempotency_key):
        """Check if message was already processed"""
        try:
            response = self.idempotency_table.get_item(
                Key={'IdempotencyKey': idempotency_key}
            )
            
            if 'Item' in response:
                # Check if record is still valid (not expired)
                expiry = datetime.fromisoformat(response['Item']['ExpiresAt'])
                return datetime.now() < expiry
            
            return False
        except Exception:
            return False
    
    def _process_with_idempotency(self, message, idempotency_key):
        """Process message with idempotency guarantee"""
        try:
            # Create idempotency record first
            self.idempotency_table.put_item(
                Item={
                    'IdempotencyKey': idempotency_key,
                    'Status': 'PROCESSING',
                    'CreatedAt': datetime.now().isoformat(),
                    'ExpiresAt': (datetime.now() + timedelta(hours=24)).isoformat()
                },
                ConditionExpression='attribute_not_exists(IdempotencyKey)'
            )
            
            # Process the message
            result = self.handle_message(message['Body'])
            
            # Update idempotency record with result
            self.idempotency_table.update_item(
                Key={'IdempotencyKey': idempotency_key},
                UpdateExpression='SET #status = :status, #result = :result',
                ExpressionAttributeNames={
                    '#status': 'Status',
                    '#result': 'Result'
                },
                ExpressionAttributeValues={
                    ':status': 'COMPLETED',
                    ':result': json.dumps(result, default=str)
                }
            )
            
            return True
            
        except self.dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
            # Already being processed or completed
            return True
        except Exception as e:
            # Update idempotency record with error
            self.idempotency_table.update_item(
                Key={'IdempotencyKey': idempotency_key},
                UpdateExpression='SET #status = :status, #error = :error',
                ExpressionAttributeNames={
                    '#status': 'Status',
                    '#error': 'Error'
                },
                ExpressionAttributeValues={
                    ':status': 'FAILED',
                    ':error': str(e)
                }
            )
            raise e
```

## Message Ordering

### FIFO (First-In-First-Out) Ordering
Ensures messages are processed in the exact order they were sent.

```python
class FIFOProducer:
    def __init__(self, fifo_queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = fifo_queue_url  # Must end with .fifo
    
    def send_ordered_message(self, message_body, group_id, deduplication_id=None):
        """Send message with ordering guarantee within group"""
        if not deduplication_id:
            deduplication_id = hashlib.sha256(
                f"{message_body}{group_id}{int(time.time())}".encode()
            ).hexdigest()
        
        response = self.sqs.send_message(
            QueueUrl=self.queue_url,
            MessageBody=message_body,
            MessageGroupId=group_id,  # Messages in same group are ordered
            MessageDeduplicationId=deduplication_id
        )
        return response['MessageId']
    
    def send_batch_ordered_messages(self, messages, group_id):
        """Send multiple messages in order"""
        entries = []
        for i, message in enumerate(messages):
            entries.append({
                'Id': str(i),
                'MessageBody': message['body'],
                'MessageGroupId': group_id,
                'MessageDeduplicationId': message.get('dedup_id', str(uuid.uuid4()))
            })
        
        response = self.sqs.send_message_batch(
            QueueUrl=self.queue_url,
            Entries=entries
        )
        return response

class FIFOConsumer:
    def __init__(self, fifo_queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = fifo_queue_url
    
    def process_ordered_messages(self):
        """Process messages maintaining order within groups"""
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.queue_url,
                MaxNumberOfMessages=1,  # Process one at a time for strict ordering
                WaitTimeSeconds=20,
                VisibilityTimeout=300
            ).get('Messages', [])
            
            for message in messages:
                try:
                    # Process message
                    self.handle_message(message['Body'])
                    
                    # Delete only after successful processing
                    self.sqs.delete_message(
                        QueueUrl=self.queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                    
                except Exception as e:
                    self.logger.error(f"Processing failed: {e}")
                    # Message will become visible again
                    # This maintains ordering as subsequent messages wait
```

### Partial Ordering with Message Groups
```python
class PartialOrderingProducer:
    def __init__(self, fifo_queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = fifo_queue_url
    
    def send_user_event(self, user_id, event_type, event_data):
        """Send events ordered per user, but parallel across users"""
        message_body = json.dumps({
            'eventType': event_type,
            'eventData': event_data,
            'timestamp': datetime.now().isoformat()
        })
        
        # Use user_id as group_id for per-user ordering
        group_id = f"user_{user_id}"
        deduplication_id = hashlib.sha256(
            f"{user_id}{event_type}{json.dumps(event_data, sort_keys=True)}".encode()
        ).hexdigest()
        
        return self.send_ordered_message(message_body, group_id, deduplication_id)
    
    def send_order_events(self, order_id, events):
        """Send all events for an order in sequence"""
        group_id = f"order_{order_id}"
        
        for sequence, event in enumerate(events):
            message_body = json.dumps({
                'orderId': order_id,
                'sequence': sequence,
                'eventType': event['type'],
                'eventData': event['data']
            })
            
            deduplication_id = f"{order_id}_{sequence}_{event['type']}"
            self.send_ordered_message(message_body, group_id, deduplication_id)

class PartialOrderingConsumer:
    def __init__(self, fifo_queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = fifo_queue_url
        self.group_processors = {}  # Track processors per group
    
    def process_with_parallel_groups(self):
        """Process messages with parallelism across groups"""
        import threading
        
        while True:
            messages = self.sqs.receive_message(
                QueueUrl=self.queue_url,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20
            ).get('Messages', [])
            
            # Group messages by MessageGroupId
            grouped_messages = {}
            for message in messages:
                group_id = message.get('Attributes', {}).get('MessageGroupId', 'default')
                if group_id not in grouped_messages:
                    grouped_messages[group_id] = []
                grouped_messages[group_id].append(message)
            
            # Process each group in parallel
            threads = []
            for group_id, group_messages in grouped_messages.items():
                thread = threading.Thread(
                    target=self._process_group_messages,
                    args=(group_id, group_messages)
                )
                threads.append(thread)
                thread.start()
            
            # Wait for all groups to complete
            for thread in threads:
                thread.join()
    
    def _process_group_messages(self, group_id, messages):
        """Process messages for a specific group in order"""
        for message in messages:
            try:
                self.handle_message(message['Body'])
                self.sqs.delete_message(
                    QueueUrl=self.queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
            except Exception as e:
                self.logger.error(f"Failed to process message in group {group_id}: {e}")
```

## Advanced Ordering Patterns

### Sequence Number Ordering
```python
class SequenceNumberProducer:
    def __init__(self, topic_arn):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
        self.sequence_counter = 0
        self.lock = threading.Lock()
    
    def send_with_sequence(self, message, partition_key):
        with self.lock:
            self.sequence_counter += 1
            sequence_number = self.sequence_counter
        
        message_with_sequence = {
            'sequenceNumber': sequence_number,
            'partitionKey': partition_key,
            'data': message,
            'timestamp': datetime.now().isoformat()
        }
        
        self.sns.publish(
            TopicArn=self.topic_arn,
            Message=json.dumps(message_with_sequence),
            MessageAttributes={
                'sequenceNumber': {
                    'DataType': 'Number',
                    'StringValue': str(sequence_number)
                },
                'partitionKey': {
                    'DataType': 'String',
                    'StringValue': partition_key
                }
            }
        )

class SequenceNumberConsumer:
    def __init__(self):
        self.expected_sequences = {}  # Track expected sequence per partition
        self.message_buffer = {}  # Buffer out-of-order messages
    
    def handle_message_with_sequence(self, message_data):
        sequence_number = message_data['sequenceNumber']
        partition_key = message_data['partitionKey']
        
        expected_seq = self.expected_sequences.get(partition_key, 1)
        
        if sequence_number == expected_seq:
            # Process in-order message
            self.process_message(message_data)
            self.expected_sequences[partition_key] = expected_seq + 1
            
            # Check buffer for next messages
            self._process_buffered_messages(partition_key)
        
        elif sequence_number > expected_seq:
            # Buffer out-of-order message
            if partition_key not in self.message_buffer:
                self.message_buffer[partition_key] = {}
            self.message_buffer[partition_key][sequence_number] = message_data
        
        else:
            # Duplicate or old message, ignore
            self.logger.warning(f"Ignoring old message: {sequence_number}")
    
    def _process_buffered_messages(self, partition_key):
        """Process any buffered messages that are now in order"""
        if partition_key not in self.message_buffer:
            return
        
        expected_seq = self.expected_sequences[partition_key]
        buffer = self.message_buffer[partition_key]
        
        while expected_seq in buffer:
            message = buffer.pop(expected_seq)
            self.process_message(message)
            expected_seq += 1
        
        self.expected_sequences[partition_key] = expected_seq
```

### Vector Clock Ordering
```python
class VectorClock:
    def __init__(self, node_id, initial_clock=None):
        self.node_id = node_id
        self.clock = initial_clock or {}
        if node_id not in self.clock:
            self.clock[node_id] = 0
    
    def tick(self):
        """Increment local clock"""
        self.clock[self.node_id] += 1
        return self.copy()
    
    def update(self, other_clock):
        """Update clock with received clock"""
        for node, timestamp in other_clock.items():
            self.clock[node] = max(self.clock.get(node, 0), timestamp)
        self.clock[self.node_id] += 1
        return self.copy()
    
    def happens_before(self, other):
        """Check if this event happens before other"""
        return (all(self.clock.get(node, 0) <= other.clock.get(node, 0) 
                   for node in set(self.clock.keys()) | set(other.clock.keys())) and
                any(self.clock.get(node, 0) < other.clock.get(node, 0)
                   for node in set(self.clock.keys()) | set(other.clock.keys())))
    
    def concurrent_with(self, other):
        """Check if events are concurrent"""
        return not (self.happens_before(other) or other.happens_before(self))
    
    def copy(self):
        return VectorClock(self.node_id, self.clock.copy())

class VectorClockMessage:
    def __init__(self, content, vector_clock):
        self.content = content
        self.vector_clock = vector_clock
        self.timestamp = datetime.now()

class CausalOrderingSystem:
    def __init__(self, node_id):
        self.node_id = node_id
        self.vector_clock = VectorClock(node_id)
        self.message_buffer = []
        self.delivered_messages = []
    
    def send_message(self, content, recipients):
        """Send message with vector clock"""
        self.vector_clock.tick()
        message = VectorClockMessage(content, self.vector_clock.copy())
        
        # Send to recipients (implementation depends on transport)
        for recipient in recipients:
            self._transport_message(recipient, message)
        
        return message
    
    def receive_message(self, message):
        """Receive and potentially deliver message"""
        # Buffer the message
        self.message_buffer.append(message)
        
        # Try to deliver messages in causal order
        self._attempt_delivery()
    
    def _attempt_delivery(self):
        """Deliver messages that can be delivered in causal order"""
        delivered_any = True
        
        while delivered_any:
            delivered_any = False
            
            for i, message in enumerate(self.message_buffer):
                if self._can_deliver(message):
                    # Deliver message
                    self._deliver_message(message)
                    self.message_buffer.pop(i)
                    delivered_any = True
                    break
    
    def _can_deliver(self, message):
        """Check if message can be delivered based on causal ordering"""
        msg_clock = message.vector_clock.clock
        
        for node, timestamp in msg_clock.items():
            if node == message.vector_clock.node_id:
                # For sender, we need exactly the next message
                expected = self.vector_clock.clock.get(node, 0) + 1
                if timestamp != expected:
                    return False
            else:
                # For other nodes, we need to have seen all prior messages
                if timestamp > self.vector_clock.clock.get(node, 0):
                    return False
        
        return True
    
    def _deliver_message(self, message):
        """Deliver message and update vector clock"""
        self.vector_clock.update(message.vector_clock.clock)
        self.delivered_messages.append(message)
        
        # Process the message content
        self.process_message(message.content)
```

## Idempotency Patterns

### Idempotent Message Processing
```python
class IdempotentProcessor:
    def __init__(self, dynamodb_table):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(dynamodb_table)
    
    def process_idempotent(self, message_id, handler_func, *args, **kwargs):
        """Process message idempotently"""
        try:
            # Try to create processing record
            self.table.put_item(
                Item={
                    'MessageId': message_id,
                    'Status': 'PROCESSING',
                    'StartTime': datetime.now().isoformat(),
                    'TTL': int((datetime.now() + timedelta(days=7)).timestamp())
                },
                ConditionExpression='attribute_not_exists(MessageId)'
            )
            
            try:
                # Process the message
                result = handler_func(*args, **kwargs)
                
                # Update with success
                self.table.update_item(
                    Key={'MessageId': message_id},
                    UpdateExpression='SET #status = :status, #result = :result, #endTime = :endTime',
                    ExpressionAttributeNames={
                        '#status': 'Status',
                        '#result': 'Result',
                        '#endTime': 'EndTime'
                    },
                    ExpressionAttributeValues={
                        ':status': 'COMPLETED',
                        ':result': json.dumps(result, default=str),
                        ':endTime': datetime.now().isoformat()
                    }
                )
                
                return result
                
            except Exception as e:
                # Update with failure
                self.table.update_item(
                    Key={'MessageId': message_id},
                    UpdateExpression='SET #status = :status, #error = :error, #endTime = :endTime',
                    ExpressionAttributeNames={
                        '#status': 'Status',
                        '#error': 'Error',
                        '#endTime': 'EndTime'
                    },
                    ExpressionAttributeValues={
                        ':status': 'FAILED',
                        ':error': str(e),
                        ':endTime': datetime.now().isoformat()
                    }
                )
                raise
                
        except self.dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
            # Already processed or being processed
            item = self.table.get_item(Key={'MessageId': message_id})['Item']
            
            if item['Status'] == 'COMPLETED':
                return json.loads(item['Result'])
            elif item['Status'] == 'FAILED':
                raise Exception(f"Previous processing failed: {item['Error']}")
            else:
                # Still processing, wait and retry
                time.sleep(1)
                return self.process_idempotent(message_id, handler_func, *args, **kwargs)
```

## Best Practices

### Delivery Guarantee Selection
- **At-Most-Once**: Use for non-critical data where loss is acceptable (metrics, logs)
- **At-Least-Once**: Use for important data where duplicates can be handled (most business events)
- **Exactly-Once**: Use for critical operations where duplicates cause issues (financial transactions)

### Ordering Considerations
- **Full Ordering**: Only when absolutely necessary (high cost, low throughput)
- **Partial Ordering**: Group related messages for better performance
- **No Ordering**: Best performance, use when order doesn't matter

### Performance Optimization
- **Batch Processing**: Process multiple messages together
- **Parallel Processing**: Use multiple consumers for different partitions/groups
- **Async Processing**: Don't block on downstream operations
- **Circuit Breakers**: Prevent cascade failures

### Error Handling
- **Dead Letter Queues**: Handle messages that can't be processed
- **Exponential Backoff**: Retry with increasing delays
- **Poison Message Detection**: Identify and isolate problematic messages
- **Monitoring**: Track processing rates, errors, and latencies

## Conclusion

Message ordering and delivery guarantees are fundamental to building reliable distributed systems. The choice of guarantees depends on your specific requirements:

- **Performance vs Reliability**: Stronger guarantees typically mean lower performance
- **Complexity vs Correctness**: Exactly-once processing adds significant complexity
- **Cost vs Consistency**: FIFO queues and stronger guarantees cost more

Understanding these trade-offs helps you make informed decisions about your messaging architecture and ensures your system meets its reliability and performance requirements.
