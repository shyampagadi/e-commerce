# Event-Driven Architecture Design

## Overview
Event-Driven Architecture (EDA) is a software architecture pattern that promotes the production, detection, consumption, and reaction to events. This approach enables highly scalable, loosely coupled systems that can respond to changes in real-time.

## Core EDA Principles

### Event-First Thinking
Design systems around events as first-class citizens rather than traditional request-response patterns.

**Event Characteristics:**
```yaml
Immutability:
  - Events represent facts that have already occurred
  - Cannot be changed once created
  - Provide audit trail and historical record

Temporal Ordering:
  - Events have timestamps indicating when they occurred
  - Ordering may be important for business logic
  - Causal relationships between events

Business Significance:
  - Events represent meaningful business occurrences
  - Domain experts can understand event names and meanings
  - Events align with business processes and workflows
```

### Loose Coupling Through Events
Events enable loose coupling between system components by eliminating direct dependencies.

**Coupling Reduction Benefits:**
```yaml
Temporal Decoupling:
  - Producers and consumers operate independently
  - No synchronous waiting for processing completion
  - System remains responsive under varying loads

Spatial Decoupling:
  - Components don't need to know about each other's location
  - Services can be deployed and scaled independently
  - Network topology changes don't affect business logic

Implementation Decoupling:
  - Different technologies can participate in same workflow
  - Services can evolve independently
  - New consumers can be added without changing producers
```

## Event Modeling and Design

### Event Storming Methodology
Collaborative technique for discovering domain events and designing event-driven systems.

**Event Storming Process:**
```yaml
Phase 1 - Chaotic Exploration:
  - Identify all domain events (orange sticky notes)
  - Focus on business-significant occurrences
  - Use past tense for event names (OrderPlaced, PaymentProcessed)

Phase 2 - Timeline Organization:
  - Arrange events in chronological order
  - Identify event flows and dependencies
  - Discover missing events and edge cases

Phase 3 - Actors and Commands:
  - Add actors who trigger events (blue sticky notes)
  - Identify commands that cause events (yellow sticky notes)
  - Map user actions to system events

Phase 4 - Aggregates and Boundaries:
  - Group related events into aggregates
  - Define bounded contexts and service boundaries
  - Identify data ownership and consistency requirements
```

### Event Design Patterns

#### Domain Events
Events that represent significant business occurrences within a specific domain.

**Example - E-commerce Domain Events:**
```json
{
  "eventType": "OrderPlaced",
  "eventId": "evt_12345",
  "timestamp": "2024-01-15T10:30:00Z",
  "aggregateId": "order_67890",
  "aggregateType": "Order",
  "version": 1,
  "data": {
    "orderId": "order_67890",
    "customerId": "customer_123",
    "items": [
      {
        "productId": "product_456",
        "quantity": 2,
        "unitPrice": 29.99
      }
    ],
    "totalAmount": 59.98,
    "shippingAddress": {
      "street": "123 Main St",
      "city": "Seattle",
      "state": "WA",
      "zipCode": "98101"
    }
  },
  "metadata": {
    "correlationId": "corr_abc123",
    "causationId": "cmd_place_order_xyz",
    "userId": "user_789",
    "source": "order-service"
  }
}
```

#### Integration Events
Events used for communication between different bounded contexts or external systems.

**Cross-Context Communication:**
```json
{
  "eventType": "CustomerRegistered",
  "eventId": "evt_54321",
  "timestamp": "2024-01-15T10:25:00Z",
  "source": "customer-service",
  "data": {
    "customerId": "customer_123",
    "email": "john.doe@example.com",
    "registrationDate": "2024-01-15T10:25:00Z",
    "customerTier": "standard",
    "preferences": {
      "newsletter": true,
      "promotions": false
    }
  },
  "schema": {
    "version": "1.0",
    "url": "https://schemas.company.com/customer/registered/v1.0"
  }
}
```

## Event Sourcing Pattern

### Concept and Benefits
Store all changes to application state as a sequence of events rather than current state snapshots.

**Event Sourcing Advantages:**
```yaml
Complete Audit Trail:
  - Every state change is recorded as an event
  - Full history of how current state was reached
  - Compliance and regulatory requirements satisfied

Temporal Queries:
  - Reconstruct state at any point in time
  - Analyze historical trends and patterns
  - Debug issues by replaying event sequences

Flexibility:
  - New projections can be created from existing events
  - Business logic changes can be applied retroactively
  - Multiple read models from same event stream
```

### Implementation Architecture
```python
from abc import ABC, abstractmethod
from typing import List, Optional
import json
from datetime import datetime

class Event(ABC):
    def __init__(self, aggregate_id: str, version: int):
        self.aggregate_id = aggregate_id
        self.version = version
        self.timestamp = datetime.utcnow()
        self.event_id = str(uuid.uuid4())

class OrderPlaced(Event):
    def __init__(self, aggregate_id: str, version: int, customer_id: str, items: List, total_amount: float):
        super().__init__(aggregate_id, version)
        self.customer_id = customer_id
        self.items = items
        self.total_amount = total_amount

class OrderShipped(Event):
    def __init__(self, aggregate_id: str, version: int, tracking_number: str, carrier: str):
        super().__init__(aggregate_id, version)
        self.tracking_number = tracking_number
        self.carrier = carrier

class EventStore:
    def __init__(self):
        self.events = {}  # In production, use proper database
    
    def save_events(self, aggregate_id: str, events: List[Event], expected_version: int):
        """Save events with optimistic concurrency control"""
        if aggregate_id not in self.events:
            self.events[aggregate_id] = []
        
        current_version = len(self.events[aggregate_id])
        if current_version != expected_version:
            raise ConcurrencyException(f"Expected version {expected_version}, got {current_version}")
        
        for event in events:
            self.events[aggregate_id].append(event)
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[Event]:
        """Retrieve events for aggregate from specified version"""
        if aggregate_id not in self.events:
            return []
        
        return self.events[aggregate_id][from_version:]

class Order:
    def __init__(self, order_id: str):
        self.order_id = order_id
        self.version = 0
        self.uncommitted_events = []
        self.customer_id = None
        self.items = []
        self.total_amount = 0
        self.status = "pending"
        self.tracking_number = None
    
    def place_order(self, customer_id: str, items: List, total_amount: float):
        """Place new order"""
        if self.status != "pending":
            raise InvalidOperationException("Order already placed")
        
        event = OrderPlaced(self.order_id, self.version + 1, customer_id, items, total_amount)
        self.apply_event(event)
        self.uncommitted_events.append(event)
    
    def ship_order(self, tracking_number: str, carrier: str):
        """Ship existing order"""
        if self.status != "confirmed":
            raise InvalidOperationException("Order must be confirmed before shipping")
        
        event = OrderShipped(self.order_id, self.version + 1, tracking_number, carrier)
        self.apply_event(event)
        self.uncommitted_events.append(event)
    
    def apply_event(self, event: Event):
        """Apply event to update aggregate state"""
        if isinstance(event, OrderPlaced):
            self.customer_id = event.customer_id
            self.items = event.items
            self.total_amount = event.total_amount
            self.status = "confirmed"
        elif isinstance(event, OrderShipped):
            self.tracking_number = event.tracking_number
            self.status = "shipped"
        
        self.version = event.version
    
    def load_from_history(self, events: List[Event]):
        """Reconstruct aggregate from event history"""
        for event in events:
            self.apply_event(event)
        self.uncommitted_events = []

class OrderRepository:
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    def save(self, order: Order):
        """Save order by persisting uncommitted events"""
        if order.uncommitted_events:
            self.event_store.save_events(
                order.order_id,
                order.uncommitted_events,
                order.version - len(order.uncommitted_events)
            )
            order.uncommitted_events = []
    
    def get_by_id(self, order_id: str) -> Optional[Order]:
        """Reconstruct order from event history"""
        events = self.event_store.get_events(order_id)
        if not events:
            return None
        
        order = Order(order_id)
        order.load_from_history(events)
        return order
```

## CQRS (Command Query Responsibility Segregation)

### Concept and Motivation
Separate read and write operations to optimize for different access patterns and scalability requirements.

**CQRS Benefits:**
```yaml
Scalability:
  - Scale read and write sides independently
  - Optimize read models for query patterns
  - Use different storage technologies for reads and writes

Performance:
  - Denormalized read models for fast queries
  - Specialized indexes for different query types
  - Caching strategies optimized for read patterns

Flexibility:
  - Multiple read models from same write model
  - Different consistency requirements for reads and writes
  - Evolution of read models without affecting writes
```

### CQRS Implementation
```python
from abc import ABC, abstractmethod

# Command Side (Write Model)
class Command(ABC):
    pass

class PlaceOrderCommand(Command):
    def __init__(self, order_id: str, customer_id: str, items: List):
        self.order_id = order_id
        self.customer_id = customer_id
        self.items = items

class CommandHandler(ABC):
    @abstractmethod
    def handle(self, command: Command):
        pass

class PlaceOrderCommandHandler(CommandHandler):
    def __init__(self, order_repository: OrderRepository, event_publisher):
        self.order_repository = order_repository
        self.event_publisher = event_publisher
    
    def handle(self, command: PlaceOrderCommand):
        # Create or load aggregate
        order = Order(command.order_id)
        
        # Execute business logic
        total_amount = sum(item.price * item.quantity for item in command.items)
        order.place_order(command.customer_id, command.items, total_amount)
        
        # Save aggregate
        self.order_repository.save(order)
        
        # Publish events
        for event in order.uncommitted_events:
            self.event_publisher.publish(event)

# Query Side (Read Model)
class OrderSummary:
    def __init__(self, order_id: str, customer_id: str, total_amount: float, status: str):
        self.order_id = order_id
        self.customer_id = customer_id
        self.total_amount = total_amount
        self.status = status
        self.created_date = datetime.utcnow()

class OrderQueryService:
    def __init__(self, read_database):
        self.db = read_database
    
    def get_order_summary(self, order_id: str) -> Optional[OrderSummary]:
        """Get optimized order summary for display"""
        result = self.db.query(
            "SELECT order_id, customer_id, total_amount, status FROM order_summaries WHERE order_id = ?",
            [order_id]
        )
        
        if result:
            return OrderSummary(**result[0])
        return None
    
    def get_customer_orders(self, customer_id: str) -> List[OrderSummary]:
        """Get all orders for customer with pagination"""
        results = self.db.query(
            "SELECT order_id, customer_id, total_amount, status FROM order_summaries WHERE customer_id = ? ORDER BY created_date DESC",
            [customer_id]
        )
        
        return [OrderSummary(**row) for row in results]

# Event Handlers for Read Model Updates
class OrderSummaryProjection:
    def __init__(self, query_database):
        self.db = query_database
    
    def handle_order_placed(self, event: OrderPlaced):
        """Update read model when order is placed"""
        self.db.execute(
            "INSERT INTO order_summaries (order_id, customer_id, total_amount, status, created_date) VALUES (?, ?, ?, ?, ?)",
            [event.aggregate_id, event.customer_id, event.total_amount, "confirmed", event.timestamp]
        )
    
    def handle_order_shipped(self, event: OrderShipped):
        """Update read model when order is shipped"""
        self.db.execute(
            "UPDATE order_summaries SET status = 'shipped' WHERE order_id = ?",
            [event.aggregate_id]
        )
```

## Saga Pattern for Distributed Transactions

### Orchestration vs Choreography
Two approaches for coordinating distributed transactions across multiple services.

#### Orchestration Approach
Central coordinator manages the entire transaction flow.

```python
class OrderProcessingSaga:
    def __init__(self, payment_service, inventory_service, shipping_service):
        self.payment_service = payment_service
        self.inventory_service = inventory_service
        self.shipping_service = shipping_service
        self.state = "started"
        self.compensations = []
    
    def execute(self, order_data):
        """Execute saga with compensation tracking"""
        try:
            # Step 1: Reserve inventory
            reservation_id = self.inventory_service.reserve_items(order_data.items)
            self.compensations.append(lambda: self.inventory_service.cancel_reservation(reservation_id))
            
            # Step 2: Process payment
            payment_id = self.payment_service.charge_customer(order_data.customer_id, order_data.total_amount)
            self.compensations.append(lambda: self.payment_service.refund_payment(payment_id))
            
            # Step 3: Create shipment
            shipment_id = self.shipping_service.create_shipment(order_data.shipping_address, order_data.items)
            self.compensations.append(lambda: self.shipping_service.cancel_shipment(shipment_id))
            
            self.state = "completed"
            return {"status": "success", "order_id": order_data.order_id}
            
        except Exception as e:
            # Execute compensations in reverse order
            self.compensate()
            self.state = "failed"
            return {"status": "failed", "error": str(e)}
    
    def compensate(self):
        """Execute compensation actions"""
        for compensation in reversed(self.compensations):
            try:
                compensation()
            except Exception as e:
                # Log compensation failure but continue
                print(f"Compensation failed: {e}")
```

#### Choreography Approach
Services coordinate through events without central coordinator.

```python
class InventoryService:
    def __init__(self, event_publisher):
        self.event_publisher = event_publisher
    
    def handle_order_placed(self, event):
        """Handle order placed event"""
        try:
            reservation_id = self.reserve_items(event.items)
            
            # Publish success event
            self.event_publisher.publish(InventoryReserved(
                order_id=event.order_id,
                reservation_id=reservation_id,
                items=event.items
            ))
        except InsufficientInventoryException:
            # Publish failure event
            self.event_publisher.publish(InventoryReservationFailed(
                order_id=event.order_id,
                reason="Insufficient inventory"
            ))

class PaymentService:
    def __init__(self, event_publisher):
        self.event_publisher = event_publisher
    
    def handle_inventory_reserved(self, event):
        """Handle inventory reserved event"""
        try:
            payment_id = self.process_payment(event.order_id, event.amount)
            
            self.event_publisher.publish(PaymentProcessed(
                order_id=event.order_id,
                payment_id=payment_id,
                amount=event.amount
            ))
        except PaymentFailedException:
            # Trigger compensation
            self.event_publisher.publish(PaymentFailed(
                order_id=event.order_id,
                reason="Payment processing failed"
            ))
    
    def handle_inventory_reservation_failed(self, event):
        """Handle inventory reservation failure"""
        # No payment needed if inventory reservation failed
        self.event_publisher.publish(OrderProcessingFailed(
            order_id=event.order_id,
            reason="Inventory not available"
        ))
```

## Event Streaming Architecture

### Stream Processing Patterns
Process continuous streams of events for real-time analytics and decision making.

**Stream Processing Use Cases:**
```yaml
Real-Time Analytics:
  - Live dashboards and metrics
  - Fraud detection and alerting
  - Recommendation engines
  - A/B testing and experimentation

Event Transformation:
  - Data enrichment and normalization
  - Format conversion and routing
  - Aggregation and windowing
  - Complex event processing (CEP)

State Management:
  - Session tracking and management
  - Real-time feature computation
  - Stateful stream processing
  - Event-driven state machines
```

### Kafka Streams Implementation
```python
from kafka import KafkaProducer, KafkaConsumer
import json
from collections import defaultdict
import time

class EventStreamProcessor:
    def __init__(self, bootstrap_servers):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        
        self.consumer = KafkaConsumer(
            'order-events',
            bootstrap_servers=bootstrap_servers,
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            group_id='order-analytics'
        )
        
        # State stores for aggregations
        self.order_counts = defaultdict(int)
        self.revenue_totals = defaultdict(float)
        self.customer_metrics = defaultdict(lambda: {"orders": 0, "revenue": 0})
    
    def process_events(self):
        """Process incoming events and maintain aggregations"""
        for message in self.consumer:
            event = message.value
            event_type = event.get('eventType')
            
            if event_type == 'OrderPlaced':
                self.process_order_placed(event)
            elif event_type == 'OrderCancelled':
                self.process_order_cancelled(event)
            
            # Publish aggregated metrics periodically
            if int(time.time()) % 60 == 0:  # Every minute
                self.publish_metrics()
    
    def process_order_placed(self, event):
        """Process order placed event"""
        customer_id = event['data']['customerId']
        amount = event['data']['totalAmount']
        region = event['data'].get('region', 'unknown')
        
        # Update aggregations
        self.order_counts[region] += 1
        self.revenue_totals[region] += amount
        
        self.customer_metrics[customer_id]['orders'] += 1
        self.customer_metrics[customer_id]['revenue'] += amount
        
        # Detect high-value customers
        if self.customer_metrics[customer_id]['revenue'] > 10000:
            self.producer.send('high-value-customers', {
                'customerId': customer_id,
                'totalRevenue': self.customer_metrics[customer_id]['revenue'],
                'totalOrders': self.customer_metrics[customer_id]['orders'],
                'timestamp': event['timestamp']
            })
    
    def publish_metrics(self):
        """Publish aggregated metrics"""
        metrics = {
            'timestamp': int(time.time()),
            'orderCounts': dict(self.order_counts),
            'revenueTotals': dict(self.revenue_totals),
            'topCustomers': self.get_top_customers(10)
        }
        
        self.producer.send('order-metrics', metrics)
    
    def get_top_customers(self, limit):
        """Get top customers by revenue"""
        sorted_customers = sorted(
            self.customer_metrics.items(),
            key=lambda x: x[1]['revenue'],
            reverse=True
        )
        
        return [
            {
                'customerId': customer_id,
                'revenue': metrics['revenue'],
                'orders': metrics['orders']
            }
            for customer_id, metrics in sorted_customers[:limit]
        ]
```

## Event Schema Evolution

### Schema Versioning Strategies
Handle changes to event schemas while maintaining backward compatibility.

**Versioning Approaches:**
```yaml
Semantic Versioning:
  - Major: Breaking changes requiring consumer updates
  - Minor: Backward-compatible additions
  - Patch: Bug fixes and clarifications

Schema Registry:
  - Centralized schema management
  - Compatibility checking
  - Schema evolution policies
  - Version negotiation between producers and consumers

Forward/Backward Compatibility:
  - Forward: New producers, old consumers
  - Backward: Old producers, new consumers
  - Full: Both forward and backward compatible
```

### Schema Evolution Example
```python
# Version 1.0 - Initial schema
order_placed_v1 = {
    "eventType": "OrderPlaced",
    "version": "1.0",
    "data": {
        "orderId": "order_123",
        "customerId": "customer_456",
        "totalAmount": 99.99
    }
}

# Version 1.1 - Added optional fields (backward compatible)
order_placed_v1_1 = {
    "eventType": "OrderPlaced", 
    "version": "1.1",
    "data": {
        "orderId": "order_123",
        "customerId": "customer_456", 
        "totalAmount": 99.99,
        "currency": "USD",  # New optional field
        "discountAmount": 10.00  # New optional field
    }
}

# Version 2.0 - Breaking changes (requires migration)
order_placed_v2 = {
    "eventType": "OrderPlaced",
    "version": "2.0", 
    "data": {
        "orderId": "order_123",
        "customerId": "customer_456",
        "items": [  # Changed from totalAmount to items array
            {
                "productId": "product_789",
                "quantity": 2,
                "unitPrice": 49.99
            }
        ],
        "pricing": {
            "subtotal": 99.98,
            "tax": 8.00,
            "discount": 10.00,
            "total": 97.98
        }
    }
}

class EventVersionHandler:
    def __init__(self):
        self.handlers = {
            "1.0": self.handle_v1_0,
            "1.1": self.handle_v1_1, 
            "2.0": self.handle_v2_0
        }
    
    def process_event(self, event):
        """Process event based on version"""
        version = event.get("version", "1.0")
        handler = self.handlers.get(version)
        
        if handler:
            return handler(event)
        else:
            raise UnsupportedVersionException(f"Version {version} not supported")
    
    def handle_v1_0(self, event):
        """Handle version 1.0 events"""
        return {
            "orderId": event["data"]["orderId"],
            "customerId": event["data"]["customerId"],
            "totalAmount": event["data"]["totalAmount"],
            "currency": "USD",  # Default value
            "discountAmount": 0.0  # Default value
        }
    
    def handle_v1_1(self, event):
        """Handle version 1.1 events"""
        return {
            "orderId": event["data"]["orderId"],
            "customerId": event["data"]["customerId"], 
            "totalAmount": event["data"]["totalAmount"],
            "currency": event["data"].get("currency", "USD"),
            "discountAmount": event["data"].get("discountAmount", 0.0)
        }
    
    def handle_v2_0(self, event):
        """Handle version 2.0 events"""
        return {
            "orderId": event["data"]["orderId"],
            "customerId": event["data"]["customerId"],
            "totalAmount": event["data"]["pricing"]["total"],
            "currency": "USD",  # Could be extracted from pricing
            "discountAmount": event["data"]["pricing"]["discount"]
        }
```

This comprehensive guide provides the foundation for designing robust event-driven architectures that can scale, evolve, and maintain consistency across distributed systems.
