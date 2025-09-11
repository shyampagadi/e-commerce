# Exercise 02: Event-Driven Microservices with EventBridge

## Overview
Build a complete event-driven microservices architecture using Amazon EventBridge for service communication, implementing order processing, inventory management, and customer notifications.

## Learning Objectives
- Design event-driven microservice architectures
- Implement EventBridge custom buses and rules
- Create event schemas and routing patterns
- Build resilient inter-service communication
- Monitor and troubleshoot event flows

## Prerequisites
- Completion of Exercise 01
- AWS CLI configured with appropriate permissions
- Python 3.8+ with boto3 library
- Basic understanding of microservices patterns

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Order Service │    │Inventory Service│    │ Payment Service │
│                 │    │                 │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼──────────────┐
                    │     EventBridge Bus        │
                    │   (ecommerce-events)       │
                    └─────────────┬──────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
          ▼                      ▼                      ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Notification Svc │    │ Analytics Svc   │    │  Audit Service  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Exercise Tasks

### Task 1: Set Up EventBridge Infrastructure

#### 1.1 Create Custom Event Bus
```python
import boto3
import json
from datetime import datetime

class EventBridgeSetup:
    def __init__(self, region='us-east-1'):
        self.eventbridge = boto3.client('events', region_name=region)
        self.bus_name = 'ecommerce-events'
    
    def create_custom_bus(self):
        """Create custom event bus for e-commerce events"""
        try:
            response = self.eventbridge.create_event_bus(
                Name=self.bus_name,
                Tags=[
                    {'Key': 'Environment', 'Value': 'development'},
                    {'Key': 'Project', 'Value': 'ecommerce-microservices'},
                    {'Key': 'Owner', 'Value': 'platform-team'}
                ]
            )
            print(f"Created event bus: {response['EventBusArn']}")
            return response['EventBusArn']
        except Exception as e:
            print(f"Error creating event bus: {e}")
            return None
    
    def create_event_rules(self):
        """Create event routing rules"""
        rules = {
            'order-processing': {
                'pattern': {
                    'source': ['ecommerce.orders'],
                    'detail-type': ['Order Placed', 'Order Cancelled']
                },
                'description': 'Route order events to processing services'
            },
            'inventory-updates': {
                'pattern': {
                    'source': ['ecommerce.inventory'],
                    'detail-type': ['Stock Updated', 'Low Stock Alert']
                },
                'description': 'Route inventory events to relevant services'
            },
            'payment-events': {
                'pattern': {
                    'source': ['ecommerce.payments'],
                    'detail-type': ['Payment Processed', 'Payment Failed']
                },
                'description': 'Route payment events for order fulfillment'
            }
        }
        
        created_rules = {}
        for rule_name, rule_config in rules.items():
            try:
                self.eventbridge.put_rule(
                    Name=rule_name,
                    EventPattern=json.dumps(rule_config['pattern']),
                    State='ENABLED',
                    EventBusName=self.bus_name,
                    Description=rule_config['description']
                )
                created_rules[rule_name] = rule_config
                print(f"Created rule: {rule_name}")
            except Exception as e:
                print(f"Error creating rule {rule_name}: {e}")
        
        return created_rules

# Run the setup
setup = EventBridgeSetup()
bus_arn = setup.create_custom_bus()
rules = setup.create_event_rules()
```

#### 1.2 Create SQS Queues for Services
```python
class SQSSetup:
    def __init__(self, region='us-east-1'):
        self.sqs = boto3.client('sqs', region_name=region)
    
    def create_service_queues(self):
        """Create SQS queues for each microservice"""
        queues = {
            'order-processing-queue': {
                'VisibilityTimeoutSeconds': '300',
                'MessageRetentionPeriod': '1209600',  # 14 days
                'ReceiveMessageWaitTimeSeconds': '20'
            },
            'inventory-updates-queue': {
                'VisibilityTimeoutSeconds': '60',
                'MessageRetentionPeriod': '345600',  # 4 days
                'ReceiveMessageWaitTimeSeconds': '20'
            },
            'notification-queue': {
                'VisibilityTimeoutSeconds': '30',
                'MessageRetentionPeriod': '345600',
                'ReceiveMessageWaitTimeSeconds': '20'
            },
            'analytics-queue': {
                'VisibilityTimeoutSeconds': '120',
                'MessageRetentionPeriod': '1209600',
                'ReceiveMessageWaitTimeSeconds': '20'
            }
        }
        
        created_queues = {}
        for queue_name, attributes in queues.items():
            try:
                response = self.sqs.create_queue(
                    QueueName=queue_name,
                    Attributes=attributes
                )
                created_queues[queue_name] = response['QueueUrl']
                print(f"Created queue: {queue_name}")
            except Exception as e:
                print(f"Error creating queue {queue_name}: {e}")
        
        return created_queues

# Create queues
sqs_setup = SQSSetup()
queues = sqs_setup.create_service_queues()
```

### Task 2: Implement Order Service

#### 2.1 Order Service Implementation
```python
import uuid
from decimal import Decimal
from typing import Dict, List

class OrderService:
    def __init__(self, eventbridge_bus_name='ecommerce-events'):
        self.eventbridge = boto3.client('events')
        self.bus_name = eventbridge_bus_name
        self.orders = {}  # In-memory storage for demo
    
    def place_order(self, customer_id: str, items: List[Dict], shipping_address: Dict) -> str:
        """Place a new order and publish event"""
        order_id = str(uuid.uuid4())
        
        # Calculate total
        total_amount = sum(Decimal(str(item['price'])) * item['quantity'] for item in items)
        
        # Create order
        order = {
            'orderId': order_id,
            'customerId': customer_id,
            'items': items,
            'totalAmount': float(total_amount),
            'shippingAddress': shipping_address,
            'status': 'PLACED',
            'timestamp': datetime.now().isoformat()
        }
        
        self.orders[order_id] = order
        
        # Publish order placed event
        self._publish_event(
            source='ecommerce.orders',
            detail_type='Order Placed',
            detail=order
        )
        
        print(f"Order placed: {order_id}")
        return order_id
    
    def cancel_order(self, order_id: str, reason: str) -> bool:
        """Cancel an existing order"""
        if order_id not in self.orders:
            return False
        
        order = self.orders[order_id]
        order['status'] = 'CANCELLED'
        order['cancellationReason'] = reason
        order['cancelledAt'] = datetime.now().isoformat()
        
        # Publish order cancelled event
        self._publish_event(
            source='ecommerce.orders',
            detail_type='Order Cancelled',
            detail=order
        )
        
        print(f"Order cancelled: {order_id}")
        return True
    
    def _publish_event(self, source: str, detail_type: str, detail: Dict):
        """Publish event to EventBridge"""
        try:
            response = self.eventbridge.put_events(
                Entries=[
                    {
                        'Source': source,
                        'DetailType': detail_type,
                        'Detail': json.dumps(detail, default=str),
                        'EventBusName': self.bus_name,
                        'Time': datetime.now()
                    }
                ]
            )
            
            if response['FailedEntryCount'] > 0:
                print(f"Failed to publish event: {response['Entries']}")
            else:
                print(f"Published event: {detail_type}")
                
        except Exception as e:
            print(f"Error publishing event: {e}")

# Test order service
order_service = OrderService()

# Place a test order
test_order_id = order_service.place_order(
    customer_id='customer-123',
    items=[
        {'productId': 'prod-1', 'name': 'Laptop', 'price': 999.99, 'quantity': 1},
        {'productId': 'prod-2', 'name': 'Mouse', 'price': 29.99, 'quantity': 2}
    ],
    shipping_address={
        'street': '123 Main St',
        'city': 'Seattle',
        'state': 'WA',
        'zipCode': '98101',
        'country': 'US'
    }
)
```

### Task 3: Implement Inventory Service

#### 3.1 Inventory Service with Event Handling
```python
class InventoryService:
    def __init__(self, eventbridge_bus_name='ecommerce-events'):
        self.eventbridge = boto3.client('events')
        self.sqs = boto3.client('sqs')
        self.bus_name = eventbridge_bus_name
        self.inventory = {
            'prod-1': {'name': 'Laptop', 'stock': 50, 'reserved': 0},
            'prod-2': {'name': 'Mouse', 'stock': 100, 'reserved': 0},
            'prod-3': {'name': 'Keyboard', 'stock': 5, 'reserved': 0}
        }
    
    def reserve_inventory(self, order_data: Dict) -> bool:
        """Reserve inventory for an order"""
        order_id = order_data['orderId']
        items = order_data['items']
        
        # Check availability
        for item in items:
            product_id = item['productId']
            quantity = item['quantity']
            
            if product_id not in self.inventory:
                self._publish_inventory_event('Reservation Failed', {
                    'orderId': order_id,
                    'productId': product_id,
                    'reason': 'Product not found'
                })
                return False
            
            available = self.inventory[product_id]['stock'] - self.inventory[product_id]['reserved']
            if available < quantity:
                self._publish_inventory_event('Reservation Failed', {
                    'orderId': order_id,
                    'productId': product_id,
                    'requested': quantity,
                    'available': available,
                    'reason': 'Insufficient stock'
                })
                return False
        
        # Reserve inventory
        for item in items:
            product_id = item['productId']
            quantity = item['quantity']
            self.inventory[product_id]['reserved'] += quantity
            
            # Check for low stock
            remaining = (self.inventory[product_id]['stock'] - 
                        self.inventory[product_id]['reserved'])
            
            if remaining <= 10:  # Low stock threshold
                self._publish_inventory_event('Low Stock Alert', {
                    'productId': product_id,
                    'productName': self.inventory[product_id]['name'],
                    'remainingStock': remaining,
                    'threshold': 10
                })
        
        # Publish successful reservation
        self._publish_inventory_event('Inventory Reserved', {
            'orderId': order_id,
            'items': items,
            'reservedAt': datetime.now().isoformat()
        })
        
        print(f"Inventory reserved for order: {order_id}")
        return True
    
    def release_inventory(self, order_data: Dict):
        """Release reserved inventory (for cancelled orders)"""
        order_id = order_data['orderId']
        items = order_data['items']
        
        for item in items:
            product_id = item['productId']
            quantity = item['quantity']
            
            if product_id in self.inventory:
                self.inventory[product_id]['reserved'] -= quantity
                self.inventory[product_id]['reserved'] = max(0, self.inventory[product_id]['reserved'])
        
        self._publish_inventory_event('Inventory Released', {
            'orderId': order_id,
            'items': items,
            'releasedAt': datetime.now().isoformat()
        })
        
        print(f"Inventory released for order: {order_id}")
    
    def _publish_inventory_event(self, event_type: str, detail: Dict):
        """Publish inventory event"""
        try:
            self.eventbridge.put_events(
                Entries=[
                    {
                        'Source': 'ecommerce.inventory',
                        'DetailType': event_type,
                        'Detail': json.dumps(detail, default=str),
                        'EventBusName': self.bus_name
                    }
                ]
            )
            print(f"Published inventory event: {event_type}")
        except Exception as e:
            print(f"Error publishing inventory event: {e}")
    
    def process_order_events(self, queue_url: str):
        """Process order events from SQS queue"""
        while True:
            try:
                messages = self.sqs.receive_message(
                    QueueUrl=queue_url,
                    MaxNumberOfMessages=10,
                    WaitTimeSeconds=20
                )
                
                for message in messages.get('Messages', []):
                    try:
                        # Parse EventBridge message
                        event_data = json.loads(message['Body'])
                        detail = json.loads(event_data['detail'])
                        detail_type = event_data['detail-type']
                        
                        if detail_type == 'Order Placed':
                            self.reserve_inventory(detail)
                        elif detail_type == 'Order Cancelled':
                            self.release_inventory(detail)
                        
                        # Delete processed message
                        self.sqs.delete_message(
                            QueueUrl=queue_url,
                            ReceiptHandle=message['ReceiptHandle']
                        )
                        
                    except Exception as e:
                        print(f"Error processing message: {e}")
                        
            except KeyboardInterrupt:
                print("Stopping inventory service...")
                break
            except Exception as e:
                print(f"Error receiving messages: {e}")

# Test inventory service
inventory_service = InventoryService()
```

### Task 4: Connect EventBridge Rules to SQS Targets

#### 4.1 Add SQS Targets to EventBridge Rules
```python
class EventBridgeTargetSetup:
    def __init__(self, bus_name='ecommerce-events'):
        self.eventbridge = boto3.client('events')
        self.sqs = boto3.client('sqs')
        self.bus_name = bus_name
    
    def add_sqs_targets_to_rules(self, queues: Dict[str, str]):
        """Add SQS queues as targets for EventBridge rules"""
        
        # Get queue ARNs
        queue_arns = {}
        for queue_name, queue_url in queues.items():
            attributes = self.sqs.get_queue_attributes(
                QueueUrl=queue_url,
                AttributeNames=['QueueArn']
            )
            queue_arns[queue_name] = attributes['Attributes']['QueueArn']
        
        # Rule to target mappings
        rule_targets = {
            'order-processing': [
                {
                    'Id': '1',
                    'Arn': queue_arns['inventory-updates-queue'],
                    'SqsParameters': {
                        'MessageGroupId': 'inventory-updates'
                    }
                }
            ],
            'inventory-updates': [
                {
                    'Id': '1',
                    'Arn': queue_arns['notification-queue']
                },
                {
                    'Id': '2',
                    'Arn': queue_arns['analytics-queue']
                }
            ],
            'payment-events': [
                {
                    'Id': '1',
                    'Arn': queue_arns['order-processing-queue']
                },
                {
                    'Id': '2',
                    'Arn': queue_arns['notification-queue']
                }
            ]
        }
        
        # Add targets to rules
        for rule_name, targets in rule_targets.items():
            try:
                self.eventbridge.put_targets(
                    Rule=rule_name,
                    EventBusName=self.bus_name,
                    Targets=targets
                )
                print(f"Added targets to rule: {rule_name}")
            except Exception as e:
                print(f"Error adding targets to rule {rule_name}: {e}")
    
    def setup_queue_permissions(self, queues: Dict[str, str]):
        """Set up SQS queue permissions for EventBridge"""
        for queue_name, queue_url in queues.items():
            try:
                # Get queue ARN
                attributes = self.sqs.get_queue_attributes(
                    QueueUrl=queue_url,
                    AttributeNames=['QueueArn']
                )
                queue_arn = attributes['Attributes']['QueueArn']
                
                # Create policy allowing EventBridge to send messages
                policy = {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {
                                "Service": "events.amazonaws.com"
                            },
                            "Action": "sqs:SendMessage",
                            "Resource": queue_arn,
                            "Condition": {
                                "StringEquals": {
                                    "aws:SourceAccount": "123456789012"  # Replace with your account ID
                                }
                            }
                        }
                    ]
                }
                
                self.sqs.set_queue_attributes(
                    QueueUrl=queue_url,
                    Attributes={
                        'Policy': json.dumps(policy)
                    }
                )
                print(f"Set permissions for queue: {queue_name}")
                
            except Exception as e:
                print(f"Error setting permissions for queue {queue_name}: {e}")

# Set up targets and permissions
target_setup = EventBridgeTargetSetup()
target_setup.add_sqs_targets_to_rules(queues)
target_setup.setup_queue_permissions(queues)
```

### Task 5: Implement Event Monitoring

#### 5.1 Event Flow Monitoring
```python
class EventMonitoring:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.eventbridge = boto3.client('events')
    
    def put_custom_metric(self, metric_name: str, value: float, unit: str = 'Count', dimensions: Dict = None):
        """Put custom metric to CloudWatch"""
        metric_data = {
            'MetricName': metric_name,
            'Value': value,
            'Unit': unit,
            'Timestamp': datetime.now()
        }
        
        if dimensions:
            metric_data['Dimensions'] = [
                {'Name': k, 'Value': v} for k, v in dimensions.items()
            ]
        
        self.cloudwatch.put_metric_data(
            Namespace='ECommerce/EventDriven',
            MetricData=[metric_data]
        )
    
    def track_event_processing(self, service_name: str, event_type: str, processing_time: float, success: bool):
        """Track event processing metrics"""
        
        # Processing time
        self.put_custom_metric(
            'EventProcessingTime',
            processing_time,
            'Milliseconds',
            {
                'ServiceName': service_name,
                'EventType': event_type
            }
        )
        
        # Success/failure
        self.put_custom_metric(
            'EventProcessingResult',
            1 if success else 0,
            'Count',
            {
                'ServiceName': service_name,
                'EventType': event_type,
                'Result': 'Success' if success else 'Failure'
            }
        )
    
    def create_dashboard(self):
        """Create CloudWatch dashboard for event monitoring"""
        dashboard_body = {
            "widgets": [
                {
                    "type": "metric",
                    "properties": {
                        "metrics": [
                            ["ECommerce/EventDriven", "EventProcessingTime", "ServiceName", "OrderService"],
                            [".", ".", ".", "InventoryService"],
                            [".", ".", ".", "NotificationService"]
                        ],
                        "period": 300,
                        "stat": "Average",
                        "region": "us-east-1",
                        "title": "Event Processing Time"
                    }
                },
                {
                    "type": "metric",
                    "properties": {
                        "metrics": [
                            ["AWS/Events", "SuccessfulInvocations", "EventBusName", "ecommerce-events"],
                            [".", "FailedInvocations", ".", "."]
                        ],
                        "period": 300,
                        "stat": "Sum",
                        "region": "us-east-1",
                        "title": "EventBridge Invocations"
                    }
                }
            ]
        }
        
        self.cloudwatch.put_dashboard(
            DashboardName='ECommerce-EventDriven-Monitoring',
            DashboardBody=json.dumps(dashboard_body)
        )
        
        print("Created monitoring dashboard")

# Set up monitoring
monitoring = EventMonitoring()
monitoring.create_dashboard()
```

## Testing and Validation

### Test Scenario 1: Complete Order Flow
```python
def test_complete_order_flow():
    """Test complete order processing flow"""
    print("=== Testing Complete Order Flow ===")
    
    # 1. Place order
    order_id = order_service.place_order(
        customer_id='test-customer-001',
        items=[
            {'productId': 'prod-1', 'name': 'Laptop', 'price': 999.99, 'quantity': 1}
        ],
        shipping_address={
            'street': '456 Test Ave',
            'city': 'Portland',
            'state': 'OR',
            'zipCode': '97201',
            'country': 'US'
        }
    )
    
    # 2. Wait for event processing
    time.sleep(5)
    
    # 3. Check inventory reservation
    print(f"Inventory after order: {inventory_service.inventory}")
    
    # 4. Cancel order
    order_service.cancel_order(order_id, "Customer requested cancellation")
    
    # 5. Wait for cancellation processing
    time.sleep(5)
    
    # 6. Check inventory release
    print(f"Inventory after cancellation: {inventory_service.inventory}")

# Run test
test_complete_order_flow()
```

## Deliverables

### 1. Architecture Documentation
Create a document describing:
- Event flow diagrams
- Service responsibilities
- Event schema definitions
- Error handling strategies

### 2. Implementation Code
Submit working code for:
- EventBridge setup and configuration
- Order service with event publishing
- Inventory service with event processing
- Monitoring and metrics collection

### 3. Testing Results
Provide evidence of:
- Successful event routing
- Service communication
- Error handling
- Performance metrics

### 4. Monitoring Dashboard
Create CloudWatch dashboard showing:
- Event processing rates
- Service health metrics
- Error rates and patterns
- End-to-end latency

## Success Criteria

✅ **EventBridge Setup**: Custom bus and rules created successfully
✅ **Service Communication**: Events flow between services correctly
✅ **Error Handling**: Failed events are handled gracefully
✅ **Monitoring**: Metrics and dashboards provide visibility
✅ **Performance**: System handles expected load with acceptable latency
✅ **Documentation**: Clear documentation of architecture and flows

## Extension Challenges

### Challenge 1: Add Payment Service
Implement a payment service that:
- Processes payment events
- Publishes payment success/failure events
- Integrates with order fulfillment flow

### Challenge 2: Implement Saga Pattern
Create a distributed transaction coordinator using:
- AWS Step Functions
- EventBridge for event coordination
- Compensation logic for failures

### Challenge 3: Add Event Replay
Implement event replay capability using:
- EventBridge Archive
- Replay functionality
- Testing and recovery scenarios

## Troubleshooting Guide

### Common Issues
1. **Events not routing**: Check EventBridge rule patterns and targets
2. **Permission errors**: Verify IAM roles and SQS queue policies
3. **Message processing failures**: Check SQS dead letter queues
4. **Performance issues**: Monitor CloudWatch metrics and adjust scaling

### Debugging Tips
- Use EventBridge test events to verify rule patterns
- Check CloudWatch Logs for service errors
- Monitor SQS queue metrics for processing delays
- Use AWS X-Ray for distributed tracing

This exercise provides hands-on experience with building event-driven microservices using AWS EventBridge, demonstrating real-world patterns and best practices for scalable distributed systems.
