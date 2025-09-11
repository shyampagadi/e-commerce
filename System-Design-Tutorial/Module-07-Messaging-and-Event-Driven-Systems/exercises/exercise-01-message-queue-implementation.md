# Exercise 01: Message Queue Implementation with SQS and SNS

## Objective
Implement a comprehensive message queue system for an e-commerce order processing workflow using Amazon SQS and SNS, demonstrating various messaging patterns, error handling, and performance optimization techniques.

## Business Context

### E-commerce Order Processing System
```yaml
Business Requirements:
  - Process 10,000+ orders per day
  - Handle order validation, payment, inventory, and shipping
  - Ensure reliable message delivery and processing
  - Support priority-based order processing
  - Implement comprehensive error handling and monitoring

System Components:
  - Order Service: Receives and validates orders
  - Payment Service: Processes payments and refunds
  - Inventory Service: Manages stock levels and reservations
  - Shipping Service: Creates shipments and tracking
  - Notification Service: Sends customer notifications

Performance Requirements:
  - Message processing latency: <5 seconds P95
  - System availability: 99.9% uptime
  - Error recovery: <2 minutes MTTR
  - Throughput: 100+ messages/second peak
```

## Exercise Tasks

### Task 1: Queue Architecture Design (30 minutes)
Design a comprehensive queue architecture for the order processing system.

#### Requirements
```yaml
Queue Types Needed:
  - Order Processing Queue (Standard SQS)
  - Priority Order Queue (FIFO SQS)
  - Payment Processing Queue (Standard SQS)
  - Inventory Updates Queue (FIFO SQS)
  - Notification Queue (Standard SQS)
  - Dead Letter Queues for each processing queue

Notification Topics:
  - Order Status Updates (SNS)
  - Payment Notifications (SNS)
  - Inventory Alerts (SNS)
  - System Health Alerts (SNS)

Integration Points:
  - API Gateway for order submission
  - Lambda functions for processing
  - DynamoDB for state management
  - CloudWatch for monitoring
```

#### Deliverables
1. **Architecture Diagram**: Complete message flow design
2. **Queue Configuration**: Detailed settings for each queue
3. **Topic Structure**: SNS topic hierarchy and subscriptions
4. **Error Handling Strategy**: DLQ configuration and retry policies

### Task 2: SQS Queue Implementation (45 minutes)
Implement the core SQS queues with optimal configuration.

#### Implementation Requirements

**Queue Creation Script:**
```python
import boto3
import json
from datetime import datetime

class OrderProcessingQueues:
    def __init__(self, region='us-east-1'):
        self.sqs = boto3.client('sqs', region_name=region)
        self.queues = {}
    
    def create_all_queues(self):
        """Create all required queues for order processing"""
        
        # 1. Standard order processing queue
        self.queues['orders'] = self.create_order_queue()
        
        # 2. FIFO priority queue for VIP orders
        self.queues['priority_orders'] = self.create_priority_order_queue()
        
        # 3. Payment processing queue
        self.queues['payments'] = self.create_payment_queue()
        
        # 4. FIFO inventory queue for stock consistency
        self.queues['inventory'] = self.create_inventory_queue()
        
        # 5. Notification queue
        self.queues['notifications'] = self.create_notification_queue()
        
        # 6. Create dead letter queues
        self.create_dead_letter_queues()
        
        return self.queues
    
    def create_order_queue(self):
        """Create main order processing queue"""
        # TODO: Implement order queue creation
        # Requirements:
        # - Standard SQS queue
        # - 5-minute visibility timeout
        # - 14-day message retention
        # - Long polling enabled (20 seconds)
        # - Dead letter queue after 3 failures
        pass
    
    def create_priority_order_queue(self):
        """Create FIFO queue for priority orders"""
        # TODO: Implement priority order queue
        # Requirements:
        # - FIFO queue with .fifo suffix
        # - Content-based deduplication enabled
        # - Per-message-group-id throughput limit
        # - 2-minute visibility timeout for faster processing
        pass
    
    def create_payment_queue(self):
        """Create payment processing queue"""
        # TODO: Implement payment queue
        # Requirements:
        # - Standard SQS queue
        # - 10-minute visibility timeout (longer processing)
        # - Maximum 5 retry attempts
        # - Batch processing optimized
        pass
    
    def create_inventory_queue(self):
        """Create FIFO inventory queue"""
        # TODO: Implement inventory queue
        # Requirements:
        # - FIFO queue for stock consistency
        # - Message grouping by product ID
        # - Deduplication for idempotent updates
        pass
    
    def create_notification_queue(self):
        """Create notification delivery queue"""
        # TODO: Implement notification queue
        # Requirements:
        # - High throughput standard queue
        # - Short visibility timeout (1 minute)
        # - Minimal retry attempts (notifications are not critical)
        pass
    
    def create_dead_letter_queues(self):
        """Create dead letter queues for all main queues"""
        # TODO: Implement DLQ creation and configuration
        # Requirements:
        # - One DLQ per main queue
        # - Proper redrive policy configuration
        # - Extended message retention (14 days)
        pass
```

**Expected Implementation:**
- Complete queue creation with proper attributes
- Error handling and validation
- Queue URL storage and retrieval
- Configuration verification

### Task 3: SNS Topic Implementation (30 minutes)
Implement SNS topics for event notifications and fan-out patterns.

#### Implementation Requirements

**Topic Creation and Subscription:**
```python
class OrderNotificationTopics:
    def __init__(self, region='us-east-1'):
        self.sns = boto3.client('sns', region_name=region)
        self.topics = {}
    
    def create_notification_topics(self):
        """Create all notification topics"""
        
        # 1. Order status updates topic
        self.topics['order_status'] = self.create_order_status_topic()
        
        # 2. Payment notifications topic
        self.topics['payment_notifications'] = self.create_payment_topic()
        
        # 3. Inventory alerts topic
        self.topics['inventory_alerts'] = self.create_inventory_alerts_topic()
        
        # 4. System health topic
        self.topics['system_health'] = self.create_system_health_topic()
        
        return self.topics
    
    def create_order_status_topic(self):
        """Create topic for order status updates"""
        # TODO: Implement order status topic
        # Requirements:
        # - Topic for order lifecycle events
        # - Email subscription for customer notifications
        # - SQS subscription for internal processing
        # - SMS subscription for critical updates
        pass
    
    def setup_topic_subscriptions(self, topic_arn, subscriptions):
        """Setup subscriptions for a topic"""
        # TODO: Implement subscription management
        # Support email, SMS, SQS, Lambda endpoints
        pass
    
    def publish_order_event(self, topic_arn, order_event):
        """Publish order event with proper formatting"""
        # TODO: Implement event publishing
        # Requirements:
        # - Structured message format
        # - Message attributes for filtering
        # - Error handling and retry logic
        pass
```

### Task 4: Message Producer Implementation (45 minutes)
Implement message producers for different services.

#### Producer Implementation

**Order Service Producer:**
```python
class OrderMessageProducer:
    def __init__(self, queue_urls, topic_arns):
        self.sqs = boto3.client('sqs')
        self.sns = boto3.client('sns')
        self.queue_urls = queue_urls
        self.topic_arns = topic_arns
    
    def process_new_order(self, order_data):
        """Process new order through messaging system"""
        try:
            # 1. Validate order data
            if not self.validate_order(order_data):
                raise ValueError("Invalid order data")
            
            # 2. Determine processing queue based on priority
            queue_url = self.select_processing_queue(order_data)
            
            # 3. Send order for processing
            message_id = self.send_order_message(queue_url, order_data)
            
            # 4. Publish order created event
            self.publish_order_created_event(order_data)
            
            # 5. Send confirmation notification
            self.send_order_confirmation(order_data)
            
            return {
                'success': True,
                'messageId': message_id,
                'orderId': order_data['orderId']
            }
            
        except Exception as e:
            # Handle errors and send to DLQ if needed
            self.handle_order_error(order_data, str(e))
            return {
                'success': False,
                'error': str(e)
            }
    
    def validate_order(self, order_data):
        """Validate order data structure and content"""
        # TODO: Implement order validation
        # Check required fields, data types, business rules
        required_fields = ['orderId', 'customerId', 'items', 'totalAmount']
        # Implement validation logic
        pass
    
    def select_processing_queue(self, order_data):
        """Select appropriate queue based on order characteristics"""
        # TODO: Implement queue selection logic
        # Priority customers -> FIFO priority queue
        # Regular orders -> Standard queue
        # Large orders -> Special handling queue
        pass
    
    def send_order_message(self, queue_url, order_data):
        """Send order message to processing queue"""
        # TODO: Implement message sending
        # Requirements:
        # - Proper message formatting
        # - Message attributes for routing
        # - Error handling and retry logic
        # - Batch sending for multiple orders
        pass
    
    def publish_order_created_event(self, order_data):
        """Publish order created event to SNS topic"""
        # TODO: Implement event publishing
        # Requirements:
        # - Structured event format
        # - Message attributes for filtering
        # - Fan-out to multiple subscribers
        pass
    
    def send_order_confirmation(self, order_data):
        """Send order confirmation notification"""
        # TODO: Implement confirmation sending
        # Requirements:
        # - Customer notification via email/SMS
        # - Internal notification for tracking
        # - Proper message formatting
        pass
```

### Task 5: Message Consumer Implementation (60 minutes)
Implement message consumers for each service.

#### Consumer Implementation

**Payment Service Consumer:**
```python
class PaymentMessageConsumer:
    def __init__(self, queue_url, dlq_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.dlq_url = dlq_url
        self.running = False
    
    def start_processing(self):
        """Start processing payment messages"""
        self.running = True
        
        while self.running:
            try:
                # Receive messages with long polling
                response = self.sqs.receive_message(
                    QueueUrl=self.queue_url,
                    MaxNumberOfMessages=10,
                    WaitTimeSeconds=20,
                    MessageAttributeNames=['All'],
                    AttributeNames=['All']
                )
                
                messages = response.get('Messages', [])
                
                # Process messages in batch
                if messages:
                    self.process_message_batch(messages)
                    
            except KeyboardInterrupt:
                self.running = False
            except Exception as e:
                print(f"Consumer error: {e}")
                time.sleep(5)
    
    def process_message_batch(self, messages):
        """Process batch of payment messages"""
        successful_deletes = []
        
        for message in messages:
            try:
                # Parse message
                message_body = json.loads(message['Body'])
                
                # Process payment
                result = self.process_payment(message_body)
                
                if result['success']:
                    # Mark for deletion
                    successful_deletes.append({
                        'Id': message['MessageId'],
                        'ReceiptHandle': message['ReceiptHandle']
                    })
                    
                    # Publish payment success event
                    self.publish_payment_success(message_body, result)
                else:
                    # Handle payment failure
                    self.handle_payment_failure(message_body, result)
                    
            except Exception as e:
                print(f"Message processing error: {e}")
                # Message will be retried or sent to DLQ
        
        # Batch delete successful messages
        if successful_deletes:
            self.sqs.delete_message_batch(
                QueueUrl=self.queue_url,
                Entries=successful_deletes
            )
    
    def process_payment(self, order_data):
        """Process payment for order"""
        # TODO: Implement payment processing logic
        # Requirements:
        # - Validate payment information
        # - Call payment gateway API
        # - Handle different payment methods
        # - Implement retry logic for transient failures
        # - Return structured result
        pass
    
    def handle_payment_failure(self, order_data, failure_result):
        """Handle payment processing failure"""
        # TODO: Implement failure handling
        # Requirements:
        # - Determine if failure is retryable
        # - Send to DLQ for non-retryable failures
        # - Publish payment failure event
        # - Update order status
        pass
    
    def publish_payment_success(self, order_data, payment_result):
        """Publish payment success event"""
        # TODO: Implement success event publishing
        # Requirements:
        # - Structured event format
        # - Include payment details
        # - Trigger downstream processing
        pass
```

**Inventory Service Consumer:**
```python
class InventoryMessageConsumer:
    def __init__(self, fifo_queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = fifo_queue_url
        self.inventory_store = {}  # Simulated inventory database
    
    def start_processing(self):
        """Start processing inventory messages"""
        # TODO: Implement FIFO message processing
        # Requirements:
        # - Maintain message order per product
        # - Handle inventory updates atomically
        # - Implement optimistic locking
        # - Publish inventory events
        pass
    
    def process_inventory_update(self, message_body):
        """Process inventory update message"""
        # TODO: Implement inventory update logic
        # Requirements:
        # - Validate inventory operation
        # - Update stock levels atomically
        # - Handle concurrent updates
        # - Generate inventory events
        pass
    
    def reserve_inventory(self, order_items):
        """Reserve inventory for order items"""
        # TODO: Implement inventory reservation
        # Requirements:
        # - Check availability for all items
        # - Reserve items atomically
        # - Handle partial availability
        # - Set reservation expiration
        pass
```

### Task 6: Error Handling and Monitoring (30 minutes)
Implement comprehensive error handling and monitoring.

#### Error Handling Implementation

**Dead Letter Queue Processor:**
```python
class DeadLetterQueueProcessor:
    def __init__(self, dlq_urls):
        self.sqs = boto3.client('sqs')
        self.dlq_urls = dlq_urls
        self.cloudwatch = boto3.client('cloudwatch')
    
    def monitor_dead_letter_queues(self):
        """Monitor and process messages in dead letter queues"""
        for queue_name, dlq_url in self.dlq_urls.items():
            try:
                # Check for messages in DLQ
                response = self.sqs.receive_message(
                    QueueUrl=dlq_url,
                    MaxNumberOfMessages=10,
                    WaitTimeSeconds=5,
                    MessageAttributeNames=['All'],
                    AttributeNames=['All']
                )
                
                messages = response.get('Messages', [])
                
                for message in messages:
                    self.analyze_failed_message(queue_name, message)
                    
            except Exception as e:
                print(f"DLQ monitoring error for {queue_name}: {e}")
    
    def analyze_failed_message(self, queue_name, message):
        """Analyze failed message and determine action"""
        # TODO: Implement failure analysis
        # Requirements:
        # - Parse failure reason from message attributes
        # - Determine if message should be retried
        # - Log failure details for investigation
        # - Send alerts for critical failures
        # - Archive messages for audit
        pass
    
    def publish_failure_metrics(self, queue_name, failure_count, failure_types):
        """Publish failure metrics to CloudWatch"""
        # TODO: Implement metrics publishing
        # Requirements:
        # - Custom CloudWatch metrics
        # - Failure categorization
        # - Trend analysis data
        # - Alerting thresholds
        pass
```

**Monitoring and Alerting:**
```python
class MessageQueueMonitoring:
    def __init__(self, queue_urls, topic_arns):
        self.cloudwatch = boto3.client('cloudwatch')
        self.queue_urls = queue_urls
        self.topic_arns = topic_arns
    
    def setup_cloudwatch_alarms(self):
        """Setup CloudWatch alarms for queue monitoring"""
        # TODO: Implement alarm creation
        # Requirements:
        # - Queue depth alarms
        # - Message age alarms
        # - DLQ message alarms
        # - Processing rate alarms
        # - Error rate alarms
        pass
    
    def create_monitoring_dashboard(self):
        """Create CloudWatch dashboard for queue metrics"""
        # TODO: Implement dashboard creation
        # Requirements:
        # - Queue metrics visualization
        # - Processing throughput graphs
        # - Error rate trends
        # - System health overview
        pass
    
    def publish_custom_metrics(self, metrics_data):
        """Publish custom application metrics"""
        # TODO: Implement custom metrics
        # Requirements:
        # - Business metrics (orders processed, revenue)
        # - Performance metrics (processing time, success rate)
        # - Operational metrics (queue utilization, error rates)
        pass
```

## Performance Targets

### Throughput Requirements
```yaml
Message Processing:
  - Orders: 100 messages/second sustained
  - Payments: 50 messages/second sustained
  - Inventory: 200 updates/second sustained
  - Notifications: 500 messages/second sustained

Latency Requirements:
  - Order processing: <5 seconds P95
  - Payment processing: <10 seconds P95
  - Inventory updates: <2 seconds P95
  - Notifications: <1 second P95

Reliability Requirements:
  - Message delivery: 99.9% success rate
  - System availability: 99.9% uptime
  - Error recovery: <2 minutes MTTR
  - Data consistency: 100% for financial transactions
```

### Cost Optimization
```yaml
SQS Optimization:
  - Use long polling to reduce empty receives
  - Batch message operations where possible
  - Optimize visibility timeouts for processing patterns
  - Use FIFO queues only when ordering is required

SNS Optimization:
  - Filter messages at subscription level
  - Use message attributes for efficient routing
  - Optimize delivery retry policies
  - Monitor and optimize subscription endpoints
```

## Evaluation Criteria

### Technical Implementation (40%)
- Correct SQS and SNS configuration
- Proper message handling and error recovery
- Efficient batch processing implementation
- Comprehensive monitoring and alerting

### Performance Achievement (25%)
- Meeting throughput and latency targets
- Efficient resource utilization
- Proper scaling and optimization
- Cost-effective implementation

### Error Handling (20%)
- Robust error handling and recovery
- Proper DLQ implementation and monitoring
- Comprehensive failure analysis
- Effective retry and backoff strategies

### Code Quality (15%)
- Clean, maintainable code structure
- Proper error handling and logging
- Comprehensive documentation
- Following AWS best practices

## Bonus Challenges

### Advanced Challenge 1: Multi-Region Setup
Implement cross-region message replication for disaster recovery:
- Cross-region SQS queue replication
- SNS topic fan-out across regions
- Conflict resolution for distributed processing
- Regional failover mechanisms

### Advanced Challenge 2: Message Encryption
Implement end-to-end message encryption:
- Client-side encryption for sensitive data
- Key management with AWS KMS
- Encrypted message routing and processing
- Compliance with security standards

### Advanced Challenge 3: Advanced Monitoring
Implement comprehensive observability:
- Distributed tracing across message flows
- Custom business metrics and KPIs
- Predictive alerting based on trends
- Automated remediation for common issues

This exercise provides hands-on experience with production-grade messaging systems, covering the full spectrum from basic queue operations to advanced error handling and monitoring.
