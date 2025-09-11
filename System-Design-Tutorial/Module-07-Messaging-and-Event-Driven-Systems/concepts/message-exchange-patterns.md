# Message Exchange Patterns

## Overview
Message exchange patterns define the communication protocols and interaction models between distributed system components. Understanding these patterns is crucial for designing robust, scalable messaging architectures.

## Request-Reply Pattern

### Synchronous Request-Reply
Direct communication where sender waits for response before continuing.

**Implementation:**
```python
import asyncio
import uuid
import json
from datetime import datetime, timedelta

class SynchronousRequestReply:
    def __init__(self, request_queue, response_queue, timeout=30):
        self.request_queue = request_queue
        self.response_queue = response_queue
        self.timeout = timeout
        self.pending_requests = {}
    
    async def send_request(self, message_body, correlation_id=None):
        """Send request and wait for response"""
        if correlation_id is None:
            correlation_id = str(uuid.uuid4())
        
        request_message = {
            'correlationId': correlation_id,
            'timestamp': datetime.utcnow().isoformat(),
            'body': message_body,
            'replyTo': self.response_queue
        }
        
        # Create future for response
        response_future = asyncio.Future()
        self.pending_requests[correlation_id] = response_future
        
        # Send request
        await self.send_message(self.request_queue, request_message)
        
        try:
            # Wait for response with timeout
            response = await asyncio.wait_for(response_future, timeout=self.timeout)
            return response
        except asyncio.TimeoutError:
            # Clean up pending request
            self.pending_requests.pop(correlation_id, None)
            raise TimeoutError(f"Request {correlation_id} timed out")
    
    async def handle_response(self, response_message):
        """Handle incoming response message"""
        correlation_id = response_message.get('correlationId')
        
        if correlation_id in self.pending_requests:
            future = self.pending_requests.pop(correlation_id)
            future.set_result(response_message)
```

### Asynchronous Request-Reply
Non-blocking communication with callback-based response handling.

**Implementation:**
```python
class AsynchronousRequestReply:
    def __init__(self, message_broker):
        self.broker = message_broker
        self.response_handlers = {}
    
    def send_request(self, destination, message_body, callback=None):
        """Send request with optional callback"""
        correlation_id = str(uuid.uuid4())
        
        request_message = {
            'correlationId': correlation_id,
            'timestamp': datetime.utcnow().isoformat(),
            'body': message_body,
            'replyTo': f"response-{self.broker.client_id}"
        }
        
        # Register callback if provided
        if callback:
            self.response_handlers[correlation_id] = callback
        
        # Send request asynchronously
        self.broker.send_message(destination, request_message)
        
        return correlation_id
    
    def handle_response(self, response_message):
        """Handle response with registered callback"""
        correlation_id = response_message.get('correlationId')
        
        if correlation_id in self.response_handlers:
            callback = self.response_handlers.pop(correlation_id)
            callback(response_message)
```

## Publish-Subscribe Pattern

### Topic-Based Pub/Sub
Messages published to topics and delivered to all subscribers.

**Implementation:**
```python
class TopicBasedPubSub:
    def __init__(self):
        self.topics = {}
        self.subscribers = {}
    
    def create_topic(self, topic_name):
        """Create new topic"""
        if topic_name not in self.topics:
            self.topics[topic_name] = {
                'subscribers': set(),
                'message_count': 0,
                'created_at': datetime.utcnow()
            }
    
    def subscribe(self, topic_name, subscriber_id, message_handler):
        """Subscribe to topic"""
        if topic_name not in self.topics:
            self.create_topic(topic_name)
        
        self.topics[topic_name]['subscribers'].add(subscriber_id)
        self.subscribers[subscriber_id] = {
            'handler': message_handler,
            'topics': self.subscribers.get(subscriber_id, {}).get('topics', set())
        }
        self.subscribers[subscriber_id]['topics'].add(topic_name)
    
    def publish(self, topic_name, message):
        """Publish message to topic"""
        if topic_name not in self.topics:
            raise ValueError(f"Topic {topic_name} does not exist")
        
        topic = self.topics[topic_name]
        topic['message_count'] += 1
        
        # Add publication metadata
        enriched_message = {
            'messageId': str(uuid.uuid4()),
            'topic': topic_name,
            'timestamp': datetime.utcnow().isoformat(),
            'body': message
        }
        
        # Deliver to all subscribers
        for subscriber_id in topic['subscribers']:
            try:
                handler = self.subscribers[subscriber_id]['handler']
                handler(enriched_message)
            except Exception as e:
                print(f"Error delivering to subscriber {subscriber_id}: {e}")
    
    def unsubscribe(self, topic_name, subscriber_id):
        """Unsubscribe from topic"""
        if topic_name in self.topics:
            self.topics[topic_name]['subscribers'].discard(subscriber_id)
        
        if subscriber_id in self.subscribers:
            self.subscribers[subscriber_id]['topics'].discard(topic_name)
```

### Content-Based Pub/Sub
Messages filtered and routed based on content attributes.

**Implementation:**
```python
class ContentBasedPubSub:
    def __init__(self):
        self.subscriptions = []
    
    def subscribe(self, subscriber_id, filter_expression, message_handler):
        """Subscribe with content filter"""
        subscription = {
            'subscriberId': subscriber_id,
            'filter': self.compile_filter(filter_expression),
            'handler': message_handler,
            'created_at': datetime.utcnow()
        }
        self.subscriptions.append(subscription)
    
    def publish(self, message):
        """Publish message with content filtering"""
        enriched_message = {
            'messageId': str(uuid.uuid4()),
            'timestamp': datetime.utcnow().isoformat(),
            'body': message
        }
        
        # Evaluate filters and deliver to matching subscribers
        for subscription in self.subscriptions:
            try:
                if self.evaluate_filter(subscription['filter'], message):
                    subscription['handler'](enriched_message)
            except Exception as e:
                print(f"Error in subscription {subscription['subscriberId']}: {e}")
    
    def compile_filter(self, filter_expression):
        """Compile filter expression for efficient evaluation"""
        # Simple implementation - in production use proper expression parser
        return {
            'expression': filter_expression,
            'compiled': compile(filter_expression, '<filter>', 'eval')
        }
    
    def evaluate_filter(self, compiled_filter, message):
        """Evaluate filter against message"""
        try:
            # Create evaluation context with message fields
            context = {
                'eventType': message.get('eventType'),
                'priority': message.get('priority'),
                'amount': message.get('amount', 0),
                'region': message.get('region'),
                'customerId': message.get('customerId')
            }
            
            return eval(compiled_filter['compiled'], {"__builtins__": {}}, context)
        except Exception:
            return False
```

## Message Routing Patterns

### Content-Based Router
Route messages based on message content and business rules.

**Implementation:**
```python
class ContentBasedRouter:
    def __init__(self):
        self.routing_rules = []
        self.destinations = {}
    
    def add_routing_rule(self, condition, destination, priority=0):
        """Add routing rule with condition and destination"""
        rule = {
            'condition': condition,
            'destination': destination,
            'priority': priority,
            'message_count': 0,
            'created_at': datetime.utcnow()
        }
        
        # Insert rule maintaining priority order
        inserted = False
        for i, existing_rule in enumerate(self.routing_rules):
            if priority > existing_rule['priority']:
                self.routing_rules.insert(i, rule)
                inserted = True
                break
        
        if not inserted:
            self.routing_rules.append(rule)
    
    def route_message(self, message):
        """Route message based on content"""
        routed_destinations = []
        
        for rule in self.routing_rules:
            try:
                if self.evaluate_condition(rule['condition'], message):
                    destination = rule['destination']
                    self.send_to_destination(destination, message)
                    routed_destinations.append(destination)
                    rule['message_count'] += 1
                    
                    # Stop at first match unless configured for multiple routing
                    if not rule.get('continue_routing', False):
                        break
                        
            except Exception as e:
                print(f"Error evaluating routing rule: {e}")
        
        if not routed_destinations:
            self.handle_unroutable_message(message)
        
        return routed_destinations
    
    def evaluate_condition(self, condition, message):
        """Evaluate routing condition"""
        # Support different condition types
        if isinstance(condition, dict):
            return self.evaluate_dict_condition(condition, message)
        elif callable(condition):
            return condition(message)
        elif isinstance(condition, str):
            return self.evaluate_expression_condition(condition, message)
        
        return False
    
    def evaluate_dict_condition(self, condition, message):
        """Evaluate dictionary-based condition"""
        for field, expected_value in condition.items():
            message_value = message.get(field)
            
            if isinstance(expected_value, dict):
                # Handle operators like {'gt': 100}, {'in': ['A', 'B']}
                for operator, value in expected_value.items():
                    if operator == 'gt' and message_value <= value:
                        return False
                    elif operator == 'lt' and message_value >= value:
                        return False
                    elif operator == 'in' and message_value not in value:
                        return False
                    elif operator == 'regex' and not re.match(value, str(message_value)):
                        return False
            else:
                # Direct value comparison
                if message_value != expected_value:
                    return False
        
        return True
```

### Recipient List Pattern
Route message to multiple predetermined recipients.

**Implementation:**
```python
class RecipientListRouter:
    def __init__(self):
        self.recipient_lists = {}
    
    def create_recipient_list(self, list_name, recipients):
        """Create named recipient list"""
        self.recipient_lists[list_name] = {
            'recipients': recipients,
            'created_at': datetime.utcnow(),
            'message_count': 0
        }
    
    def route_to_list(self, list_name, message, delivery_options=None):
        """Route message to all recipients in list"""
        if list_name not in self.recipient_lists:
            raise ValueError(f"Recipient list {list_name} not found")
        
        recipient_list = self.recipient_lists[list_name]
        delivery_results = []
        
        for recipient in recipient_list['recipients']:
            try:
                # Add recipient-specific metadata
                recipient_message = {
                    **message,
                    'recipientId': recipient['id'],
                    'deliveryOptions': delivery_options or {}
                }
                
                # Send to recipient
                result = self.send_to_recipient(recipient, recipient_message)
                delivery_results.append({
                    'recipient': recipient['id'],
                    'status': 'success',
                    'result': result
                })
                
            except Exception as e:
                delivery_results.append({
                    'recipient': recipient['id'],
                    'status': 'failed',
                    'error': str(e)
                })
        
        recipient_list['message_count'] += 1
        return delivery_results
    
    def send_to_recipient(self, recipient, message):
        """Send message to individual recipient"""
        # Implementation depends on recipient type
        if recipient['type'] == 'queue':
            return self.send_to_queue(recipient['endpoint'], message)
        elif recipient['type'] == 'webhook':
            return self.send_to_webhook(recipient['endpoint'], message)
        elif recipient['type'] == 'email':
            return self.send_email(recipient['address'], message)
        else:
            raise ValueError(f"Unknown recipient type: {recipient['type']}")
```

## Message Transformation Patterns

### Message Translator
Transform message format between different systems.

**Implementation:**
```python
class MessageTranslator:
    def __init__(self):
        self.transformations = {}
    
    def register_transformation(self, source_format, target_format, transformer):
        """Register message transformation"""
        key = f"{source_format}->{target_format}"
        self.transformations[key] = {
            'transformer': transformer,
            'registered_at': datetime.utcnow(),
            'usage_count': 0
        }
    
    def transform_message(self, message, source_format, target_format):
        """Transform message between formats"""
        key = f"{source_format}->{target_format}"
        
        if key not in self.transformations:
            raise ValueError(f"No transformation found for {key}")
        
        transformation = self.transformations[key]
        
        try:
            transformed_message = transformation['transformer'](message)
            transformation['usage_count'] += 1
            
            # Add transformation metadata
            transformed_message['_transformation'] = {
                'sourceFormat': source_format,
                'targetFormat': target_format,
                'transformedAt': datetime.utcnow().isoformat(),
                'originalMessageId': message.get('messageId')
            }
            
            return transformed_message
            
        except Exception as e:
            raise TransformationError(f"Transformation failed: {str(e)}")

# Example transformations
def xml_to_json_transformer(xml_message):
    """Transform XML message to JSON"""
    import xml.etree.ElementTree as ET
    
    # Parse XML
    root = ET.fromstring(xml_message['body'])
    
    # Convert to dictionary
    def xml_to_dict(element):
        result = {}
        for child in element:
            if len(child) == 0:
                result[child.tag] = child.text
            else:
                result[child.tag] = xml_to_dict(child)
        return result
    
    json_body = xml_to_dict(root)
    
    return {
        'messageId': str(uuid.uuid4()),
        'format': 'json',
        'body': json_body,
        'timestamp': datetime.utcnow().isoformat()
    }

def legacy_to_modern_transformer(legacy_message):
    """Transform legacy message format to modern format"""
    legacy_body = legacy_message['body']
    
    # Map legacy fields to modern schema
    modern_body = {
        'orderId': legacy_body.get('order_id'),
        'customerId': legacy_body.get('cust_id'),
        'orderDate': legacy_body.get('order_dt'),
        'items': [
            {
                'productId': item.get('prod_id'),
                'quantity': item.get('qty'),
                'unitPrice': item.get('price')
            }
            for item in legacy_body.get('order_items', [])
        ],
        'totalAmount': legacy_body.get('total_amt'),
        'status': legacy_body.get('order_status', 'pending')
    }
    
    return {
        'messageId': str(uuid.uuid4()),
        'eventType': 'OrderCreated',
        'version': '2.0',
        'body': modern_body,
        'timestamp': datetime.utcnow().isoformat()
    }
```

## Message Aggregation Patterns

### Message Aggregator
Combine related messages into single composite message.

**Implementation:**
```python
class MessageAggregator:
    def __init__(self, aggregation_strategy, completion_criteria):
        self.strategy = aggregation_strategy
        self.completion_criteria = completion_criteria
        self.aggregation_groups = {}
    
    def add_message(self, message, correlation_key):
        """Add message to aggregation group"""
        if correlation_key not in self.aggregation_groups:
            self.aggregation_groups[correlation_key] = {
                'messages': [],
                'started_at': datetime.utcnow(),
                'correlation_key': correlation_key
            }
        
        group = self.aggregation_groups[correlation_key]
        group['messages'].append(message)
        
        # Check if aggregation is complete
        if self.is_aggregation_complete(group):
            aggregated_message = self.aggregate_messages(group)
            del self.aggregation_groups[correlation_key]
            return aggregated_message
        
        return None
    
    def is_aggregation_complete(self, group):
        """Check if aggregation group is complete"""
        criteria = self.completion_criteria
        
        # Count-based completion
        if 'message_count' in criteria:
            if len(group['messages']) >= criteria['message_count']:
                return True
        
        # Time-based completion
        if 'timeout_seconds' in criteria:
            elapsed = (datetime.utcnow() - group['started_at']).total_seconds()
            if elapsed >= criteria['timeout_seconds']:
                return True
        
        # Content-based completion
        if 'completion_condition' in criteria:
            condition = criteria['completion_condition']
            if callable(condition) and condition(group['messages']):
                return True
        
        return False
    
    def aggregate_messages(self, group):
        """Aggregate messages using configured strategy"""
        if self.strategy == 'merge':
            return self.merge_messages(group['messages'])
        elif self.strategy == 'collect':
            return self.collect_messages(group['messages'])
        elif callable(self.strategy):
            return self.strategy(group['messages'])
        else:
            raise ValueError(f"Unknown aggregation strategy: {self.strategy}")
    
    def merge_messages(self, messages):
        """Merge message contents"""
        merged_body = {}
        
        for message in messages:
            if isinstance(message.get('body'), dict):
                merged_body.update(message['body'])
        
        return {
            'messageId': str(uuid.uuid4()),
            'eventType': 'AggregatedMessage',
            'aggregatedCount': len(messages),
            'body': merged_body,
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def collect_messages(self, messages):
        """Collect messages into array"""
        return {
            'messageId': str(uuid.uuid4()),
            'eventType': 'MessageCollection',
            'messageCount': len(messages),
            'messages': messages,
            'timestamp': datetime.utcnow().isoformat()
        }
```

## Message Sequencing Patterns

### Message Sequencer
Ensure messages are processed in correct order.

**Implementation:**
```python
class MessageSequencer:
    def __init__(self):
        self.sequences = {}
        self.pending_messages = {}
    
    def process_message(self, message, sequence_key):
        """Process message maintaining sequence order"""
        sequence_number = message.get('sequenceNumber')
        
        if sequence_key not in self.sequences:
            self.sequences[sequence_key] = {
                'next_expected': 1,
                'processed_count': 0
            }
            self.pending_messages[sequence_key] = {}
        
        sequence_info = self.sequences[sequence_key]
        pending = self.pending_messages[sequence_key]
        
        if sequence_number == sequence_info['next_expected']:
            # Process message immediately
            self.deliver_message(message)
            sequence_info['next_expected'] += 1
            sequence_info['processed_count'] += 1
            
            # Check for pending messages that can now be processed
            while sequence_info['next_expected'] in pending:
                next_message = pending.pop(sequence_info['next_expected'])
                self.deliver_message(next_message)
                sequence_info['next_expected'] += 1
                sequence_info['processed_count'] += 1
        
        elif sequence_number > sequence_info['next_expected']:
            # Store message for later processing
            pending[sequence_number] = message
        
        else:
            # Duplicate or out-of-order message
            print(f"Ignoring duplicate/old message {sequence_number}")
    
    def deliver_message(self, message):
        """Deliver message to next processing stage"""
        print(f"Processing message {message.get('sequenceNumber')}: {message.get('body')}")
```

This comprehensive guide covers the essential message exchange patterns needed for building robust distributed messaging systems.
