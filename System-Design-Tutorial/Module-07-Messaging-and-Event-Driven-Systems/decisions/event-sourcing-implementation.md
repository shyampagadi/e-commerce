# ADR-002: Event Sourcing Implementation Strategy

## Status
Accepted

## Context
We need to implement event sourcing for critical business domains that require:
- Complete audit trails for compliance and debugging
- Temporal queries to understand system state at any point in time
- Complex business workflows with multiple state transitions
- High availability and disaster recovery capabilities
- Integration with existing systems and future scalability

### Current Challenges
- **Data Consistency**: Ensuring consistency across distributed services
- **Audit Requirements**: Regulatory compliance requiring complete transaction history
- **Complex Workflows**: Order processing, payment flows, and inventory management
- **Debugging Complexity**: Difficulty tracing issues in distributed systems
- **Scalability**: Need to scale read and write operations independently

### Business Requirements
- **Financial Transactions**: Complete audit trail for all monetary operations
- **Order Processing**: Track all state changes in order lifecycle
- **Inventory Management**: Maintain accurate inventory with full history
- **Customer Support**: Ability to reconstruct customer interaction history
- **Regulatory Compliance**: Meet SOX, PCI DSS, and GDPR requirements

## Decision
We will implement event sourcing using a hybrid approach that combines:

1. **Event Store**: DynamoDB-based event store for persistence
2. **CQRS**: Separate read and write models for optimal performance
3. **Event Bus**: EventBridge for event distribution and integration
4. **Snapshots**: Periodic snapshots for performance optimization
5. **Schema Evolution**: Versioned events with upgrade strategies

## Implementation Architecture

### Event Store Design
```python
# Event store schema design
class EventStoreSchema:
    def __init__(self):
        self.table_design = {
            'TableName': 'EventStore',
            'KeySchema': [
                {'AttributeName': 'AggregateId', 'KeyType': 'HASH'},
                {'AttributeName': 'Version', 'KeyType': 'RANGE'}
            ],
            'AttributeDefinitions': [
                {'AttributeName': 'AggregateId', 'AttributeType': 'S'},
                {'AttributeName': 'Version', 'AttributeType': 'N'},
                {'AttributeName': 'EventType', 'AttributeType': 'S'},
                {'AttributeName': 'Timestamp', 'AttributeType': 'S'}
            ],
            'GlobalSecondaryIndexes': [
                {
                    'IndexName': 'EventTypeIndex',
                    'KeySchema': [
                        {'AttributeName': 'EventType', 'KeyType': 'HASH'},
                        {'AttributeName': 'Timestamp', 'KeyType': 'RANGE'}
                    ]
                }
            ]
        }
```

### Aggregate Design Patterns
```python
class EventSourcedAggregate:
    """Base class for event-sourced aggregates"""
    
    def __init__(self, aggregate_id: str):
        self.aggregate_id = aggregate_id
        self.version = 0
        self.uncommitted_events = []
        self.created_at = None
        self.last_modified_at = None
    
    def apply_event(self, event):
        """Apply event to aggregate state"""
        method_name = f"_apply_{event.event_type.lower()}"
        if hasattr(self, method_name):
            getattr(self, method_name)(event)
        
        self.version += 1
        self.last_modified_at = event.timestamp
        
        if not self.created_at:
            self.created_at = event.timestamp
    
    def raise_event(self, event_type: str, event_data: dict):
        """Raise new domain event"""
        event = DomainEvent(
            aggregate_id=self.aggregate_id,
            event_type=event_type,
            event_data=event_data,
            version=self.version + 1
        )
        
        self.apply_event(event)
        self.uncommitted_events.append(event)
    
    def load_from_history(self, events):
        """Rebuild aggregate from event history"""
        for event in events:
            self.apply_event(event)
    
    def mark_events_as_committed(self):
        """Clear uncommitted events after persistence"""
        self.uncommitted_events.clear()
```

### Command and Query Separation
```python
# Command Side (Write Model)
class OrderCommandHandler:
    def __init__(self, event_store, event_bus):
        self.event_store = event_store
        self.event_bus = event_bus
    
    def handle_create_order(self, command):
        """Handle create order command"""
        order = OrderAggregate(command.order_id)
        
        # Execute business logic
        order.create_order(
            customer_id=command.customer_id,
            items=command.items,
            shipping_address=command.shipping_address
        )
        
        # Persist events
        self.event_store.save_events(
            order.aggregate_id,
            order.uncommitted_events,
            expected_version=0
        )
        
        # Publish events
        for event in order.uncommitted_events:
            self.event_bus.publish(event)
        
        order.mark_events_as_committed()
        return order.aggregate_id

# Query Side (Read Model)
class OrderQueryHandler:
    def __init__(self, read_model_store):
        self.read_model_store = read_model_store
    
    def get_order_details(self, order_id):
        """Get order details from read model"""
        return self.read_model_store.get_order(order_id)
    
    def get_customer_orders(self, customer_id):
        """Get all orders for customer"""
        return self.read_model_store.get_orders_by_customer(customer_id)
```

## Domain Implementation Strategy

### Order Domain Events
```python
class OrderEvents:
    """Order domain events definition"""
    
    ORDER_CREATED = "OrderCreated"
    ORDER_CONFIRMED = "OrderConfirmed"
    ORDER_SHIPPED = "OrderShipped"
    ORDER_DELIVERED = "OrderDelivered"
    ORDER_CANCELLED = "OrderCancelled"
    ORDER_RETURNED = "OrderReturned"
    
    PAYMENT_REQUESTED = "PaymentRequested"
    PAYMENT_PROCESSED = "PaymentProcessed"
    PAYMENT_FAILED = "PaymentFailed"
    PAYMENT_REFUNDED = "PaymentRefunded"
    
    INVENTORY_RESERVED = "InventoryReserved"
    INVENTORY_RELEASED = "InventoryReleased"
    INVENTORY_ALLOCATED = "InventoryAllocated"

class OrderAggregate(EventSourcedAggregate):
    def __init__(self, order_id):
        super().__init__(order_id)
        self.status = None
        self.customer_id = None
        self.items = []
        self.total_amount = 0
        self.shipping_address = None
        self.payment_status = None
    
    def create_order(self, customer_id, items, shipping_address):
        """Create new order"""
        if self.status is not None:
            raise DomainException("Order already exists")
        
        # Business rule validation
        if not items:
            raise DomainException("Order must have at least one item")
        
        total_amount = sum(item['price'] * item['quantity'] for item in items)
        
        self.raise_event(OrderEvents.ORDER_CREATED, {
            'customerId': customer_id,
            'items': items,
            'totalAmount': total_amount,
            'shippingAddress': shipping_address,
            'createdAt': datetime.now().isoformat()
        })
    
    def confirm_order(self, payment_method_id):
        """Confirm order after payment validation"""
        if self.status != 'CREATED':
            raise DomainException(f"Cannot confirm order in status: {self.status}")
        
        self.raise_event(OrderEvents.ORDER_CONFIRMED, {
            'paymentMethodId': payment_method_id,
            'confirmedAt': datetime.now().isoformat()
        })
    
    def _apply_ordercreated(self, event):
        """Apply OrderCreated event"""
        self.status = 'CREATED'
        self.customer_id = event.event_data['customerId']
        self.items = event.event_data['items']
        self.total_amount = event.event_data['totalAmount']
        self.shipping_address = event.event_data['shippingAddress']
    
    def _apply_orderconfirmed(self, event):
        """Apply OrderConfirmed event"""
        self.status = 'CONFIRMED'
        self.payment_status = 'PENDING'
```

### Payment Domain Events
```python
class PaymentAggregate(EventSourcedAggregate):
    def __init__(self, payment_id):
        super().__init__(payment_id)
        self.order_id = None
        self.amount = 0
        self.currency = None
        self.status = None
        self.payment_method = None
        self.transaction_id = None
    
    def process_payment(self, order_id, amount, currency, payment_method):
        """Process payment for order"""
        if self.status is not None:
            raise DomainException("Payment already processed")
        
        # Business rule validation
        if amount <= 0:
            raise DomainException("Payment amount must be positive")
        
        self.raise_event(OrderEvents.PAYMENT_REQUESTED, {
            'orderId': order_id,
            'amount': amount,
            'currency': currency,
            'paymentMethod': payment_method,
            'requestedAt': datetime.now().isoformat()
        })
    
    def complete_payment(self, transaction_id, gateway_response):
        """Complete payment processing"""
        if self.status != 'REQUESTED':
            raise DomainException(f"Cannot complete payment in status: {self.status}")
        
        if gateway_response['status'] == 'SUCCESS':
            self.raise_event(OrderEvents.PAYMENT_PROCESSED, {
                'transactionId': transaction_id,
                'gatewayResponse': gateway_response,
                'processedAt': datetime.now().isoformat()
            })
        else:
            self.raise_event(OrderEvents.PAYMENT_FAILED, {
                'transactionId': transaction_id,
                'failureReason': gateway_response.get('error', 'Unknown error'),
                'failedAt': datetime.now().isoformat()
            })
```

## Read Model Projections

### Order Summary Projection
```python
class OrderSummaryProjection:
    def __init__(self, dynamodb_table):
        self.table = dynamodb_table
    
    def handle_order_created(self, event):
        """Handle OrderCreated event"""
        self.table.put_item(Item={
            'OrderId': event.aggregate_id,
            'CustomerId': event.event_data['customerId'],
            'Status': 'CREATED',
            'TotalAmount': Decimal(str(event.event_data['totalAmount'])),
            'ItemCount': len(event.event_data['items']),
            'CreatedAt': event.event_data['createdAt'],
            'LastUpdated': event.timestamp.isoformat()
        })
    
    def handle_order_confirmed(self, event):
        """Handle OrderConfirmed event"""
        self.table.update_item(
            Key={'OrderId': event.aggregate_id},
            UpdateExpression='SET #status = :status, LastUpdated = :updated',
            ExpressionAttributeNames={'#status': 'Status'},
            ExpressionAttributeValues={
                ':status': 'CONFIRMED',
                ':updated': event.timestamp.isoformat()
            }
        )

class CustomerOrdersProjection:
    def __init__(self, dynamodb_table):
        self.table = dynamodb_table
    
    def handle_order_created(self, event):
        """Handle OrderCreated event for customer view"""
        self.table.put_item(Item={
            'CustomerId': event.event_data['customerId'],
            'OrderId': event.aggregate_id,
            'Status': 'CREATED',
            'TotalAmount': Decimal(str(event.event_data['totalAmount'])),
            'CreatedAt': event.event_data['createdAt']
        })
```

## Event Schema Evolution

### Versioning Strategy
```python
class EventVersioning:
    def __init__(self):
        self.current_versions = {
            'OrderCreated': 3,
            'OrderConfirmed': 2,
            'PaymentProcessed': 2
        }
        
        self.upgraders = {
            ('OrderCreated', 1, 2): self._upgrade_order_created_v1_to_v2,
            ('OrderCreated', 2, 3): self._upgrade_order_created_v2_to_v3,
            ('PaymentProcessed', 1, 2): self._upgrade_payment_processed_v1_to_v2
        }
    
    def upgrade_event(self, event):
        """Upgrade event to latest version"""
        event_type = event['eventType']
        current_version = event.get('version', 1)
        target_version = self.current_versions.get(event_type, 1)
        
        while current_version < target_version:
            upgrader_key = (event_type, current_version, current_version + 1)
            if upgrader_key in self.upgraders:
                event = self.upgraders[upgrader_key](event)
                current_version += 1
            else:
                break
        
        return event
    
    def _upgrade_order_created_v1_to_v2(self, event):
        """Upgrade OrderCreated from v1 to v2 (add currency field)"""
        event['eventData']['currency'] = 'USD'  # Default currency
        event['version'] = 2
        return event
    
    def _upgrade_order_created_v2_to_v3(self, event):
        """Upgrade OrderCreated from v2 to v3 (add tax information)"""
        event['eventData']['taxAmount'] = 0.0  # Default no tax
        event['eventData']['taxRate'] = 0.0
        event['version'] = 3
        return event
```

## Snapshot Implementation

### Snapshot Strategy
```python
class SnapshotManager:
    def __init__(self, snapshot_store, event_store):
        self.snapshot_store = snapshot_store
        self.event_store = event_store
        self.snapshot_frequency = 100  # Snapshot every 100 events
    
    def load_aggregate(self, aggregate_id, aggregate_class):
        """Load aggregate with snapshot optimization"""
        # Try to load latest snapshot
        snapshot = self.snapshot_store.get_latest_snapshot(aggregate_id)
        
        if snapshot:
            # Load from snapshot
            aggregate = aggregate_class(aggregate_id)
            aggregate.load_from_snapshot(snapshot)
            
            # Load events after snapshot
            events = self.event_store.get_events(
                aggregate_id, 
                from_version=snapshot['version']
            )
            aggregate.load_from_history(events)
        else:
            # Load from beginning
            aggregate = aggregate_class(aggregate_id)
            events = self.event_store.get_events(aggregate_id)
            aggregate.load_from_history(events)
        
        return aggregate
    
    def save_aggregate(self, aggregate):
        """Save aggregate with snapshot consideration"""
        # Save events
        self.event_store.save_events(
            aggregate.aggregate_id,
            aggregate.uncommitted_events,
            aggregate.version - len(aggregate.uncommitted_events)
        )
        
        # Create snapshot if needed
        if aggregate.version % self.snapshot_frequency == 0:
            snapshot_data = aggregate.create_snapshot()
            self.snapshot_store.save_snapshot(
                aggregate.aggregate_id,
                aggregate.version,
                snapshot_data
            )
        
        aggregate.mark_events_as_committed()
```

## Performance Considerations

### Event Store Optimization
```python
class EventStoreOptimizations:
    def __init__(self):
        self.batch_size = 25  # DynamoDB batch limit
        self.read_capacity_units = 100
        self.write_capacity_units = 100
    
    def configure_dynamodb_table(self):
        """Configure DynamoDB for optimal performance"""
        table_config = {
            'TableName': 'EventStore',
            'BillingMode': 'PROVISIONED',
            'ProvisionedThroughput': {
                'ReadCapacityUnits': self.read_capacity_units,
                'WriteCapacityUnits': self.write_capacity_units
            },
            'StreamSpecification': {
                'StreamEnabled': True,
                'StreamViewType': 'NEW_AND_OLD_IMAGES'
            },
            'PointInTimeRecoverySpecification': {
                'PointInTimeRecoveryEnabled': True
            }
        }
        return table_config
    
    def batch_write_events(self, events):
        """Write events in batches for better performance"""
        for i in range(0, len(events), self.batch_size):
            batch = events[i:i + self.batch_size]
            # Write batch to DynamoDB
            self._write_event_batch(batch)
```

## Monitoring and Observability

### Event Processing Metrics
```python
class EventSourcingMetrics:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
    
    def track_event_processing(self, event_type, processing_time, success):
        """Track event processing metrics"""
        self.cloudwatch.put_metric_data(
            Namespace='EventSourcing',
            MetricData=[
                {
                    'MetricName': 'EventProcessingTime',
                    'Value': processing_time,
                    'Unit': 'Milliseconds',
                    'Dimensions': [
                        {'Name': 'EventType', 'Value': event_type}
                    ]
                },
                {
                    'MetricName': 'EventProcessingResult',
                    'Value': 1 if success else 0,
                    'Unit': 'Count',
                    'Dimensions': [
                        {'Name': 'EventType', 'Value': event_type},
                        {'Name': 'Result', 'Value': 'Success' if success else 'Failure'}
                    ]
                }
            ]
        )
    
    def track_aggregate_load_time(self, aggregate_type, load_time, event_count):
        """Track aggregate loading performance"""
        self.cloudwatch.put_metric_data(
            Namespace='EventSourcing',
            MetricData=[
                {
                    'MetricName': 'AggregateLoadTime',
                    'Value': load_time,
                    'Unit': 'Milliseconds',
                    'Dimensions': [
                        {'Name': 'AggregateType', 'Value': aggregate_type}
                    ]
                },
                {
                    'MetricName': 'EventsLoaded',
                    'Value': event_count,
                    'Unit': 'Count',
                    'Dimensions': [
                        {'Name': 'AggregateType', 'Value': aggregate_type}
                    ]
                }
            ]
        )
```

## Migration Strategy

### Phase 1: Foundation (Weeks 1-4)
- Set up event store infrastructure
- Implement base aggregate and event classes
- Create command and query handlers
- Establish monitoring and alerting

### Phase 2: Core Domain (Weeks 5-8)
- Implement Order aggregate with event sourcing
- Create order-related read models
- Migrate order creation and confirmation flows
- Add comprehensive testing

### Phase 3: Payment Integration (Weeks 9-12)
- Implement Payment aggregate
- Integrate with existing payment systems
- Add payment-related projections
- Implement saga patterns for complex workflows

### Phase 4: Full Migration (Weeks 13-16)
- Migrate remaining domains (Inventory, Customer)
- Implement snapshot optimization
- Add event replay capabilities
- Complete monitoring and operational procedures

## Risk Mitigation

### Technical Risks
```yaml
Risk: Event Store Performance
Mitigation:
  - Implement snapshots for large aggregates
  - Use DynamoDB auto-scaling
  - Monitor and optimize read/write patterns
  - Implement caching for frequently accessed aggregates

Risk: Event Schema Evolution
Mitigation:
  - Version all events from the start
  - Implement event upgraders
  - Test schema changes thoroughly
  - Maintain backward compatibility

Risk: Eventual Consistency
Mitigation:
  - Design UI for eventual consistency
  - Implement proper error handling
  - Use saga patterns for complex workflows
  - Monitor projection lag
```

### Operational Risks
```yaml
Risk: Complexity Increase
Mitigation:
  - Comprehensive documentation
  - Team training and education
  - Gradual migration approach
  - Clear operational procedures

Risk: Debugging Difficulty
Mitigation:
  - Rich event logging and tracing
  - Event replay capabilities
  - Comprehensive monitoring
  - Clear error messages and handling
```

## Success Criteria

### Technical Success
- All events are persisted reliably with zero data loss
- Read model projections are eventually consistent within 5 seconds
- Aggregate loading performance is under 100ms for 95th percentile
- Event store can handle 10,000 events per second

### Business Success
- Complete audit trail for all business transactions
- Ability to reconstruct system state at any point in time
- Improved debugging and customer support capabilities
- Regulatory compliance requirements met

### Operational Success
- Comprehensive monitoring and alerting in place
- Clear operational procedures documented
- Team trained on event sourcing concepts
- Disaster recovery procedures tested

## Consequences

### Positive Outcomes
- **Audit Trail**: Complete history of all business events
- **Temporal Queries**: Ability to query system state at any time
- **Scalability**: Independent scaling of read and write operations
- **Reliability**: Natural backup and recovery capabilities
- **Integration**: Events provide natural integration points

### Trade-offs
- **Complexity**: Increased system complexity and learning curve
- **Eventual Consistency**: Read models may be temporarily inconsistent
- **Storage**: Higher storage requirements for event history
- **Performance**: Additional overhead for event processing

## Review and Updates

This ADR will be reviewed quarterly and updated based on:
- Implementation experience and lessons learned
- Performance metrics and optimization opportunities
- Business requirement changes
- Technology evolution and best practices

**Next Review Date**: July 15, 2024
**Responsible Team**: Platform Architecture Team
**Stakeholders**: Engineering, Product, Operations, Compliance
