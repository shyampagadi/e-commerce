# Exercise 04: Event Sourcing Implementation

## Overview
Implement a complete event sourcing system for order management using DynamoDB as the event store, demonstrating event-driven architecture patterns with full audit trails and temporal queries.

## Learning Objectives
- Implement event sourcing patterns with AWS services
- Design and build event stores using DynamoDB
- Create CQRS read models for optimized queries
- Handle event schema evolution and versioning
- Build event replay and temporal query capabilities

## Prerequisites
- Completion of Exercises 01-03
- Understanding of event sourcing and CQRS concepts
- AWS CLI configured with DynamoDB permissions
- Python 3.8+ with boto3 library

## Business Scenario

### OrderMaster System
You're building an event-sourced order management system for a high-volume e-commerce platform that requires:
- Complete audit trail of all order changes
- Ability to reconstruct order state at any point in time
- Support for complex business workflows
- High availability and disaster recovery
- Regulatory compliance for financial transactions

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Commands      │    │   Aggregates    │    │   Events        │
│                 │    │                 │    │                 │
│ • CreateOrder   │───▶│ • OrderAggregate│───▶│ • OrderCreated  │
│ • ConfirmOrder  │    │ • PaymentAgg    │    │ • OrderConfirmed│
│ • CancelOrder   │    │ • InventoryAgg  │    │ • PaymentProc   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │  Command Bus    │    │   Event Store   │
                    │                 │    │   (DynamoDB)    │
                    └─────────────────┘    └─────────────────┘
                                                      │
                                                      ▼
                                          ┌─────────────────┐
                                          │   Read Models   │
                                          │                 │
                                          │ • OrderSummary  │
                                          │ • CustomerOrders│
                                          │ • OrderHistory  │
                                          └─────────────────┘
```

## Exercise Tasks

### Task 1: Event Store Implementation

#### 1.1 DynamoDB Event Store Setup
```python
import boto3
import json
from datetime import datetime
from typing import List, Dict, Optional
from dataclasses import dataclass, asdict
import uuid

@dataclass
class DomainEvent:
    event_id: str
    aggregate_id: str
    aggregate_type: str
    event_type: str
    event_data: Dict
    event_version: int
    timestamp: datetime
    correlation_id: Optional[str] = None
    causation_id: Optional[str] = None
    
    def to_dynamodb_item(self) -> Dict:
        """Convert event to DynamoDB item format"""
        # TODO: Implement conversion to DynamoDB item
        # Include all event fields with proper data types
        pass
    
    @classmethod
    def from_dynamodb_item(cls, item: Dict) -> 'DomainEvent':
        """Create event from DynamoDB item"""
        # TODO: Implement conversion from DynamoDB item
        # Handle data type conversions properly
        pass

class EventStore:
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def append_events(self, aggregate_id: str, expected_version: int, 
                     events: List[DomainEvent]) -> None:
        """Append events with optimistic concurrency control"""
        # TODO: Implement event appending with version checking
        # Requirements:
        # - Check expected version matches current version
        # - Append all events atomically
        # - Handle concurrency conflicts
        # - Update aggregate version
        pass
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[DomainEvent]:
        """Get events for aggregate reconstruction"""
        # TODO: Implement event retrieval
        # Requirements:
        # - Query by aggregate_id
        # - Filter by version if specified
        # - Return events in chronological order
        # - Handle pagination for large event streams
        pass
    
    def get_events_by_type(self, event_type: str, 
                          from_timestamp: datetime = None) -> List[DomainEvent]:
        """Get events by type for projections"""
        # TODO: Implement event type queries
        # Use GSI for efficient querying by event type
        pass
    
    def get_aggregate_version(self, aggregate_id: str) -> int:
        """Get current version of aggregate"""
        # TODO: Implement version retrieval
        # Return 0 if aggregate doesn't exist
        pass
```

#### 1.2 Create DynamoDB Table
```python
def create_event_store_table(table_name: str) -> str:
    """Create DynamoDB table for event store"""
    dynamodb = boto3.client('dynamodb')
    
    table_definition = {
        'TableName': table_name,
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
                ],
                'Projection': {'ProjectionType': 'ALL'},
                'BillingMode': 'PAY_PER_REQUEST'
            }
        ],
        'BillingMode': 'PAY_PER_REQUEST',
        'StreamSpecification': {
            'StreamEnabled': True,
            'StreamViewType': 'NEW_AND_OLD_IMAGES'
        }
    }
    
    # TODO: Create table and wait for it to be active
    # Return table ARN
    pass
```

### Task 2: Order Aggregate Implementation

#### 2.1 Order Aggregate
```python
from enum import Enum
from decimal import Decimal
from typing import List, Dict, Optional

class OrderStatus(Enum):
    CREATED = "created"
    CONFIRMED = "confirmed"
    PAID = "paid"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class OrderAggregate:
    def __init__(self, order_id: str):
        self.order_id = order_id
        self.version = 0
        self.uncommitted_events: List[DomainEvent] = []
        
        # Order state
        self.status = None
        self.customer_id = None
        self.items: List[Dict] = []
        self.total_amount = Decimal('0')
        self.currency = None
        self.shipping_address = None
        self.created_at = None
        self.confirmed_at = None
        self.payment_method = None
    
    def create_order(self, customer_id: str, items: List[Dict], 
                    shipping_address: Dict, currency: str = 'USD'):
        """Create new order"""
        # TODO: Implement order creation
        # Requirements:
        # - Validate input parameters
        # - Calculate total amount
        # - Raise OrderCreated event
        # - Update aggregate state
        pass
    
    def confirm_order(self, payment_method_id: str):
        """Confirm order after payment validation"""
        # TODO: Implement order confirmation
        # Requirements:
        # - Validate current state allows confirmation
        # - Raise OrderConfirmed event
        # - Update aggregate state
        pass
    
    def cancel_order(self, reason: str, refund_amount: Optional[Decimal] = None):
        """Cancel order with optional refund"""
        # TODO: Implement order cancellation
        # Requirements:
        # - Validate cancellation is allowed
        # - Calculate refund amount if not provided
        # - Raise OrderCancelled event
        # - Update aggregate state
        pass
    
    def apply_event(self, event: DomainEvent):
        """Apply event to aggregate state"""
        # TODO: Implement event application
        # Requirements:
        # - Route to appropriate handler method
        # - Update version
        # - Update last modified timestamp
        pass
    
    def _apply_order_created(self, event: DomainEvent):
        """Apply OrderCreated event"""
        # TODO: Update aggregate state from event data
        pass
    
    def _apply_order_confirmed(self, event: DomainEvent):
        """Apply OrderConfirmed event"""
        # TODO: Update aggregate state from event data
        pass
    
    def _apply_order_cancelled(self, event: DomainEvent):
        """Apply OrderCancelled event"""
        # TODO: Update aggregate state from event data
        pass
    
    def load_from_history(self, events: List[DomainEvent]):
        """Rebuild aggregate from event history"""
        # TODO: Apply all events in sequence
        # Reset uncommitted events after loading
        pass
    
    def mark_events_as_committed(self):
        """Clear uncommitted events after persistence"""
        self.uncommitted_events.clear()
    
    def get_uncommitted_events(self) -> List[DomainEvent]:
        """Get events that haven't been persisted yet"""
        return self.uncommitted_events.copy()
```

### Task 3: Command Handlers

#### 3.1 Command Classes
```python
@dataclass
class CreateOrderCommand:
    order_id: str
    customer_id: str
    items: List[Dict]
    shipping_address: Dict
    currency: str = 'USD'

@dataclass
class ConfirmOrderCommand:
    order_id: str
    payment_method_id: str

@dataclass
class CancelOrderCommand:
    order_id: str
    reason: str
    refund_amount: Optional[Decimal] = None

class OrderCommandHandler:
    def __init__(self, event_store: EventStore, event_bus):
        self.event_store = event_store
        self.event_bus = event_bus
    
    def handle_create_order(self, command: CreateOrderCommand) -> str:
        """Handle create order command"""
        # TODO: Implement command handling
        # Requirements:
        # - Create new aggregate
        # - Execute business logic
        # - Save events to event store
        # - Publish events to event bus
        # - Return order ID
        pass
    
    def handle_confirm_order(self, command: ConfirmOrderCommand) -> bool:
        """Handle confirm order command"""
        # TODO: Implement command handling
        # Requirements:
        # - Load aggregate from event store
        # - Execute business logic
        # - Save new events
        # - Publish events
        # - Return success status
        pass
    
    def handle_cancel_order(self, command: CancelOrderCommand) -> bool:
        """Handle cancel order command"""
        # TODO: Implement command handling
        # Similar pattern to confirm order
        pass
    
    def _load_aggregate(self, order_id: str) -> OrderAggregate:
        """Load aggregate from event store"""
        # TODO: Load events and reconstruct aggregate
        pass
    
    def _save_aggregate(self, aggregate: OrderAggregate):
        """Save aggregate events to store"""
        # TODO: Save uncommitted events with version check
        pass
```

### Task 4: CQRS Read Models

#### 4.1 Order Summary Projection
```python
class OrderSummaryProjection:
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def handle_order_created(self, event: DomainEvent):
        """Handle OrderCreated event"""
        # TODO: Create order summary record
        # Include: order_id, customer_id, status, total_amount, created_at
        pass
    
    def handle_order_confirmed(self, event: DomainEvent):
        """Handle OrderConfirmed event"""
        # TODO: Update order summary with confirmation details
        pass
    
    def handle_order_cancelled(self, event: DomainEvent):
        """Handle OrderCancelled event"""
        # TODO: Update order summary with cancellation details
        pass
    
    def get_order_summary(self, order_id: str) -> Optional[Dict]:
        """Get order summary by ID"""
        # TODO: Query order summary table
        pass
    
    def get_customer_orders(self, customer_id: str) -> List[Dict]:
        """Get all orders for customer"""
        # TODO: Query by customer_id using GSI
        pass

class CustomerOrdersProjection:
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def handle_order_event(self, event: DomainEvent):
        """Handle any order event for customer view"""
        # TODO: Update customer's order list
        # Maintain denormalized view for fast customer queries
        pass
```

### Task 5: Event Replay and Temporal Queries

#### 5.1 Event Replay System
```python
class EventReplayService:
    def __init__(self, event_store: EventStore):
        self.event_store = event_store
    
    def replay_events_to_projection(self, projection, from_timestamp: datetime = None):
        """Replay events to rebuild projection"""
        # TODO: Implement event replay
        # Requirements:
        # - Get all events from specified timestamp
        # - Apply events to projection in chronological order
        # - Handle large event volumes with batching
        # - Provide progress feedback
        pass
    
    def rebuild_aggregate_at_timestamp(self, aggregate_id: str, 
                                     timestamp: datetime) -> OrderAggregate:
        """Rebuild aggregate state at specific point in time"""
        # TODO: Implement temporal query
        # Requirements:
        # - Get events up to specified timestamp
        # - Reconstruct aggregate state
        # - Return historical state
        pass
    
    def get_aggregate_history(self, aggregate_id: str) -> List[Dict]:
        """Get complete history of aggregate changes"""
        # TODO: Return chronological list of state changes
        # Include timestamp, event type, and key state changes
        pass
```

### Task 6: Event Schema Evolution

#### 6.1 Event Versioning
```python
class EventUpgrader:
    def __init__(self):
        self.upgraders = {
            ('OrderCreated', 1, 2): self._upgrade_order_created_v1_to_v2,
            ('OrderCreated', 2, 3): self._upgrade_order_created_v2_to_v3,
        }
    
    def upgrade_event(self, event: DomainEvent) -> DomainEvent:
        """Upgrade event to latest version"""
        # TODO: Implement event upgrading
        # Requirements:
        # - Check current version
        # - Apply sequential upgrades
        # - Return upgraded event
        pass
    
    def _upgrade_order_created_v1_to_v2(self, event: DomainEvent) -> DomainEvent:
        """Upgrade OrderCreated from v1 to v2"""
        # TODO: Add currency field (default to USD)
        # Update event version
        pass
    
    def _upgrade_order_created_v2_to_v3(self, event: DomainEvent) -> DomainEvent:
        """Upgrade OrderCreated from v2 to v3"""
        # TODO: Add tax information fields
        # Update event version
        pass
```

## Testing and Validation

### Integration Test
```python
def test_complete_order_lifecycle():
    """Test complete order processing with event sourcing"""
    # TODO: Implement comprehensive test
    # Requirements:
    # 1. Create order
    # 2. Confirm order
    # 3. Cancel order
    # 4. Verify event store contains all events
    # 5. Verify read models are updated correctly
    # 6. Test temporal queries
    # 7. Test event replay
    
    order_id = str(uuid.uuid4())
    customer_id = "customer-123"
    
    # Test implementation here
    print("Event sourcing integration test completed")

def test_event_replay():
    """Test event replay functionality"""
    # TODO: Test projection rebuilding from events
    pass

def test_temporal_queries():
    """Test querying historical state"""
    # TODO: Test aggregate state at different points in time
    pass
```

## Deliverables

### 1. Event Store Implementation
- Complete DynamoDB event store with optimistic concurrency
- Event serialization and deserialization
- Event querying capabilities

### 2. Order Aggregate
- Full order lifecycle implementation
- Event sourcing patterns
- Business rule validation

### 3. Command Handlers
- CQRS command processing
- Event persistence and publishing
- Error handling and validation

### 4. Read Models
- Order summary projections
- Customer order views
- Optimized query patterns

### 5. Advanced Features
- Event replay system
- Temporal queries
- Event schema evolution

### 6. Testing Suite
- Integration tests
- Event replay validation
- Temporal query verification

## Success Criteria

✅ **Event Store**: Reliable event persistence with concurrency control
✅ **Aggregates**: Proper event sourcing implementation with business logic
✅ **CQRS**: Separate read and write models with eventual consistency
✅ **Replay**: Ability to rebuild projections from events
✅ **Temporal Queries**: Query historical aggregate states
✅ **Schema Evolution**: Handle event version upgrades gracefully

## Extension Challenges

### Challenge 1: Snapshot Implementation
Add snapshot functionality to optimize aggregate loading for long event streams.

### Challenge 2: Saga Pattern
Implement distributed transaction coordination using the saga pattern.

### Challenge 3: Multi-Aggregate Transactions
Handle transactions spanning multiple aggregates with eventual consistency.

### Challenge 4: Event Sourcing Analytics
Build analytical queries directly on the event stream for business intelligence.

This exercise provides hands-on experience with event sourcing and CQRS patterns using AWS services, demonstrating how to build systems with complete audit trails and temporal query capabilities.
