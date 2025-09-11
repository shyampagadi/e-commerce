# Module 07: Practical Implementation Assessment

## Overview
This hands-on assessment evaluates your ability to implement messaging and event-driven systems using AWS services. You'll build a complete order processing system with real-time notifications and event sourcing.

**Time Limit**: 120 minutes
**Format**: Individual hands-on implementation
**Tools Required**: AWS CLI, Python 3.8+, Code editor
**Submission**: Working code + AWS resources + documentation

## Assessment Scenario

### Business Context: OrderFlow System
You're building a messaging system for an e-commerce platform that processes customer orders through multiple stages with real-time notifications and complete audit trails.

### System Requirements
1. **Order Processing**: Handle order creation, confirmation, and fulfillment
2. **Real-time Notifications**: Notify customers and staff of order status changes
3. **Event Sourcing**: Maintain complete audit trail of all order events
4. **Error Handling**: Graceful handling of failures with retry mechanisms
5. **Monitoring**: Basic metrics and logging for operational visibility

## Implementation Tasks

### Task 1: AWS Infrastructure Setup (25 points)
**Time Allocation**: 20 minutes

#### 1.1 Create SQS Queues
```bash
# Create the required queues
aws sqs create-queue --queue-name order-processing-queue
aws sqs create-queue --queue-name order-notifications-queue
aws sqs create-queue --queue-name order-events-dlq
```

#### 1.2 Create SNS Topic
```bash
# Create SNS topic for order notifications
aws sns create-topic --name order-notifications
```

#### 1.3 Create EventBridge Custom Bus
```bash
# Create custom event bus
aws events create-event-bus --name order-events-bus
```

#### Requirements
- ✅ All AWS resources created successfully
- ✅ Proper naming conventions followed
- ✅ Basic security configurations applied
- ✅ Dead letter queue configured

#### Evaluation Criteria
- **Excellent (23-25)**: All resources created with optimal configurations
- **Good (18-22)**: Resources created with minor configuration issues
- **Satisfactory (13-17)**: Basic resources created meeting minimum requirements
- **Poor (0-12)**: Missing resources or significant configuration errors

### Task 2: Event Processing Implementation (30 points)
**Time Allocation**: 40 minutes

#### 2.1 Order Event Classes
```python
# Implement in order_events.py
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Any
import uuid

@dataclass
class OrderEvent:
    event_id: str
    order_id: str
    event_type: str
    event_data: Dict[str, Any]
    timestamp: datetime
    
    def to_dict(self) -> Dict[str, Any]:
        # TODO: Implement serialization
        pass
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'OrderEvent':
        # TODO: Implement deserialization
        pass

class OrderEventFactory:
    @staticmethod
    def create_order_placed_event(order_id: str, customer_id: str, 
                                 items: list, total_amount: float) -> OrderEvent:
        # TODO: Implement order placed event creation
        pass
    
    @staticmethod
    def create_order_confirmed_event(order_id: str, 
                                   confirmation_code: str) -> OrderEvent:
        # TODO: Implement order confirmed event creation
        pass
```

#### 2.2 Event Publisher
```python
# Implement in event_publisher.py
import boto3
import json
from typing import List
from order_events import OrderEvent

class EventPublisher:
    def __init__(self, event_bus_name: str):
        self.eventbridge = boto3.client('events')
        self.event_bus_name = event_bus_name
    
    def publish_event(self, event: OrderEvent) -> bool:
        # TODO: Implement event publishing to EventBridge
        # Requirements:
        # - Use custom event bus
        # - Include proper event source
        # - Handle errors gracefully
        # - Return success/failure status
        pass
    
    def publish_batch_events(self, events: List[OrderEvent]) -> Dict[str, int]:
        # TODO: Implement batch event publishing
        # Return: {'successful': count, 'failed': count}
        pass
```

#### 2.3 Event Consumer
```python
# Implement in event_consumer.py
import boto3
import json
from typing import Callable
from order_events import OrderEvent

class EventConsumer:
    def __init__(self, queue_url: str):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
    
    def consume_events(self, event_handler: Callable[[OrderEvent], None]):
        # TODO: Implement event consumption from SQS
        # Requirements:
        # - Long polling for efficiency
        # - Proper error handling
        # - Message deletion after successful processing
        # - Graceful shutdown handling
        pass
    
    def process_single_event(self, message: Dict) -> bool:
        # TODO: Process individual SQS message
        # Return: True if successful, False if failed
        pass
```

#### Requirements
- ✅ Complete event class implementation with serialization
- ✅ Working event publisher with error handling
- ✅ Functional event consumer with proper message handling
- ✅ Proper AWS service integration

#### Evaluation Criteria
- **Excellent (27-30)**: Complete, robust implementation with comprehensive error handling
- **Good (21-26)**: Good implementation with minor issues or missing edge cases
- **Satisfactory (15-20)**: Basic functionality working with limited error handling
- **Poor (0-14)**: Incomplete or non-functional implementation

### Task 3: Order Processing Logic (25 points)
**Time Allocation**: 35 minutes

#### 3.1 Order State Machine
```python
# Implement in order_processor.py
from enum import Enum
from typing import Dict, List, Optional
from order_events import OrderEvent, OrderEventFactory

class OrderStatus(Enum):
    CREATED = "created"
    CONFIRMED = "confirmed"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class OrderProcessor:
    def __init__(self, event_publisher):
        self.event_publisher = event_publisher
        self.orders: Dict[str, Dict] = {}  # In-memory storage for demo
    
    def create_order(self, order_id: str, customer_id: str, 
                    items: List[Dict], total_amount: float) -> bool:
        # TODO: Implement order creation logic
        # Requirements:
        # - Validate input parameters
        # - Create order record
        # - Publish OrderPlaced event
        # - Return success status
        pass
    
    def confirm_order(self, order_id: str, payment_method: str) -> bool:
        # TODO: Implement order confirmation logic
        # Requirements:
        # - Validate order exists and is in correct state
        # - Update order status
        # - Publish OrderConfirmed event
        # - Handle state transition errors
        pass
    
    def process_order_event(self, event: OrderEvent) -> bool:
        # TODO: Process incoming order events
        # Requirements:
        # - Route events based on type
        # - Update internal state
        # - Trigger downstream events if needed
        # - Handle unknown event types gracefully
        pass
    
    def get_order_status(self, order_id: str) -> Optional[Dict]:
        # TODO: Return current order status and details
        pass
```

#### 3.2 Notification Handler
```python
# Implement in notification_handler.py
import boto3
from order_events import OrderEvent

class NotificationHandler:
    def __init__(self, sns_topic_arn: str):
        self.sns = boto3.client('sns')
        self.topic_arn = sns_topic_arn
    
    def handle_order_event(self, event: OrderEvent):
        # TODO: Handle order events for notifications
        # Requirements:
        # - Generate appropriate notification message
        # - Send to SNS topic
        # - Handle different event types
        # - Include relevant order details
        pass
    
    def send_customer_notification(self, customer_id: str, 
                                 message: str, order_id: str):
        # TODO: Send notification to customer
        # Use SNS message attributes for routing
        pass
    
    def send_staff_notification(self, message: str, order_id: str, 
                              priority: str = "normal"):
        # TODO: Send notification to staff
        # Include priority level for routing
        pass
```

#### Requirements
- ✅ Complete order state machine with proper transitions
- ✅ Event-driven order processing logic
- ✅ Notification system integration
- ✅ Proper error handling and validation

#### Evaluation Criteria
- **Excellent (23-25)**: Complete business logic with comprehensive state management
- **Good (18-22)**: Good business logic with minor gaps in state handling
- **Satisfactory (13-17)**: Basic order processing with limited state management
- **Poor (0-12)**: Incomplete or incorrect business logic implementation

### Task 4: Error Handling and Monitoring (20 points)
**Time Allocation**: 25 minutes

#### 4.1 Error Handling Implementation
```python
# Implement in error_handler.py
import logging
import boto3
from typing import Dict, Any
from datetime import datetime

class MessageError(Exception):
    def __init__(self, message: str, error_code: str, retry_count: int = 0):
        self.message = message
        self.error_code = error_code
        self.retry_count = retry_count
        super().__init__(self.message)

class ErrorHandler:
    def __init__(self, dlq_url: str):
        self.sqs = boto3.client('sqs')
        self.dlq_url = dlq_url
        self.logger = logging.getLogger(__name__)
    
    def handle_processing_error(self, original_message: Dict, 
                              error: Exception, max_retries: int = 3) -> bool:
        # TODO: Implement error handling logic
        # Requirements:
        # - Check retry count
        # - Send to DLQ if max retries exceeded
        # - Log error details
        # - Return whether message should be retried
        pass
    
    def send_to_dlq(self, message: Dict, error_reason: str):
        # TODO: Send failed message to dead letter queue
        # Include error metadata and original message
        pass
    
    def create_error_report(self, error: Exception, 
                          context: Dict[str, Any]) -> Dict[str, Any]:
        # TODO: Create structured error report
        # Include timestamp, error details, context
        pass
```

#### 4.2 Basic Monitoring
```python
# Implement in monitoring.py
import boto3
from datetime import datetime
from typing import Dict

class BasicMonitoring:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.metrics = {
            'orders_processed': 0,
            'events_published': 0,
            'processing_errors': 0,
            'notifications_sent': 0
        }
    
    def increment_metric(self, metric_name: str, value: int = 1):
        # TODO: Increment local metric counter
        pass
    
    def publish_metrics(self):
        # TODO: Publish metrics to CloudWatch
        # Requirements:
        # - Use custom namespace
        # - Include timestamp
        # - Reset local counters after publishing
        pass
    
    def log_processing_time(self, operation: str, duration_ms: float):
        # TODO: Log operation timing
        # Send to CloudWatch as custom metric
        pass
```

#### Requirements
- ✅ Comprehensive error handling with retry logic
- ✅ Dead letter queue integration
- ✅ Basic monitoring and metrics collection
- ✅ Proper logging throughout the system

#### Evaluation Criteria
- **Excellent (18-20)**: Robust error handling with comprehensive monitoring
- **Good (14-17)**: Good error handling with basic monitoring
- **Satisfactory (10-13)**: Basic error handling with minimal monitoring
- **Poor (0-9)**: Poor or missing error handling and monitoring

## Integration Testing

### Test Scenario Implementation
```python
# Implement in test_integration.py
import time
import uuid
from order_processor import OrderProcessor
from event_publisher import EventPublisher
from notification_handler import NotificationHandler

def test_complete_order_flow():
    """Test complete order processing flow"""
    # TODO: Implement integration test
    # Requirements:
    # 1. Create order
    # 2. Confirm order
    # 3. Verify events published
    # 4. Verify notifications sent
    # 5. Check final order status
    
    order_id = str(uuid.uuid4())
    customer_id = "customer-123"
    
    # Test steps:
    # 1. Initialize components
    # 2. Create order
    # 3. Wait for processing
    # 4. Confirm order
    # 5. Verify end-to-end flow
    
    print("Integration test completed successfully")

if __name__ == "__main__":
    test_complete_order_flow()
```

## Submission Requirements

### Code Submission
1. **Python Files**: All implementation files with complete code
2. **Requirements File**: `requirements.txt` with dependencies
3. **Configuration**: AWS resource configurations used
4. **Test Results**: Output from integration test execution

### Documentation
1. **Architecture Overview**: Brief description of your implementation approach
2. **AWS Resources**: List of created resources with their purposes
3. **Error Scenarios**: How your system handles different error conditions
4. **Monitoring Strategy**: What metrics you collect and why

### Demonstration
1. **Working System**: Demonstrate complete order flow
2. **Error Handling**: Show error scenarios and recovery
3. **Monitoring**: Display metrics and logging output
4. **Code Walkthrough**: Explain key implementation decisions

## Evaluation Summary

### Total Points: 100
- **AWS Infrastructure Setup**: 25 points
- **Event Processing Implementation**: 30 points
- **Order Processing Logic**: 25 points
- **Error Handling and Monitoring**: 20 points

### Success Criteria
- **90-100 points**: Exceptional implementation ready for production
- **80-89 points**: Strong implementation with minor improvements needed
- **70-79 points**: Functional implementation meeting basic requirements
- **60-69 points**: Partial implementation with significant gaps
- **Below 60 points**: Incomplete or non-functional implementation

### Common Pitfalls to Avoid
1. **Hardcoded Values**: Use configuration for AWS resource names
2. **No Error Handling**: Always handle AWS service errors
3. **Synchronous Processing**: Use asynchronous patterns where appropriate
4. **Missing Validation**: Validate all inputs and state transitions
5. **Poor Logging**: Include meaningful log messages for debugging

### Tips for Success
1. **Start Simple**: Get basic functionality working first
2. **Test Incrementally**: Test each component as you build it
3. **Use AWS Documentation**: Reference official AWS service documentation
4. **Handle Errors Gracefully**: Plan for failure scenarios
5. **Monitor Everything**: Add logging and metrics throughout your code

This practical assessment evaluates your ability to implement real-world messaging systems using AWS services while following best practices for error handling, monitoring, and system design.
