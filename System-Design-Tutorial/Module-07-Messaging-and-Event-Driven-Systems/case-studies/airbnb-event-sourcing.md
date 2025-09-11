# Case Study: Airbnb's Event Sourcing Architecture

## Overview
Airbnb transformed their booking and payment systems using event sourcing to handle complex business workflows, ensure data consistency, and provide complete audit trails for financial transactions. This case study examines their journey from traditional CRUD operations to event-driven architecture.

## Business Context

### Scale and Complexity
- **7+ million listings** worldwide
- **150+ million users** across 220+ countries
- **500+ million guest arrivals** since founding
- **Complex booking workflows** with multiple states
- **Financial compliance** requirements across jurisdictions
- **Real-time pricing** and availability updates

### Critical Business Challenges
1. **Booking State Management**: Complex state transitions with cancellations, modifications
2. **Payment Processing**: Multi-currency, split payments, refunds, disputes
3. **Pricing Consistency**: Dynamic pricing with real-time updates
4. **Regulatory Compliance**: Audit trails for financial transactions
5. **Data Consistency**: Ensuring consistency across distributed services
6. **Scalability**: Handling peak booking periods and global growth

## Technical Challenges

### Traditional CRUD Limitations
```python
# Traditional booking system problems
class TraditionalBookingSystem:
    def __init__(self):
        self.bookings_db = BookingsDatabase()
        self.payments_db = PaymentsDatabase()
        self.pricing_db = PricingDatabase()
    
    def create_booking(self, booking_data):
        """Traditional approach with multiple database updates"""
        try:
            # Problem: Multiple database updates not atomic
            booking = self.bookings_db.create_booking(booking_data)
            payment = self.payments_db.create_payment(booking.id, booking_data.amount)
            self.pricing_db.update_availability(booking_data.listing_id, booking_data.dates)
            
            # Problem: No audit trail of what happened
            # Problem: Difficult to handle partial failures
            # Problem: Lost business context and intent
            
            return booking
        except Exception as e:
            # Problem: Complex rollback logic
            self._rollback_booking_creation(booking_data)
            raise e
```

### Event Sourcing Solution
```python
# Airbnb's event sourcing approach
class EventSourcedBookingSystem:
    def __init__(self):
        self.event_store = EventStore()
        self.command_handlers = CommandHandlers()
        self.event_bus = EventBus()
    
    def create_booking(self, create_booking_command):
        """Event sourcing approach"""
        # Generate events based on business logic
        events = self.command_handlers.handle_create_booking(create_booking_command)
        
        # Store events atomically
        self.event_store.append_events(
            aggregate_id=create_booking_command.booking_id,
            expected_version=0,
            events=events
        )
        
        # Publish events for other services
        for event in events:
            self.event_bus.publish(event)
        
        return events
```

## Event Sourcing Implementation

### Booking Aggregate Design
```python
from datetime import datetime, timedelta
from enum import Enum
from typing import List, Optional

class BookingStatus(Enum):
    REQUESTED = "requested"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    COMPLETED = "completed"
    DISPUTED = "disputed"

class BookingEvent:
    def __init__(self, event_type: str, data: dict, timestamp: datetime = None):
        self.event_type = event_type
        self.data = data
        self.timestamp = timestamp or datetime.now()
        self.event_id = str(uuid.uuid4())

class BookingAggregate:
    def __init__(self, booking_id: str):
        self.booking_id = booking_id
        self.version = 0
        self.uncommitted_events = []
        
        # Booking state
        self.status = None
        self.guest_id = None
        self.host_id = None
        self.listing_id = None
        self.check_in_date = None
        self.check_out_date = None
        self.total_amount = None
        self.currency = None
        self.payment_status = None
        self.cancellation_policy = None
        
        # Audit information
        self.created_at = None
        self.last_modified_at = None
        self.state_transitions = []
    
    def request_booking(self, guest_id: str, host_id: str, listing_id: str, 
                       check_in: datetime, check_out: datetime, 
                       total_amount: float, currency: str):
        """Request a new booking"""
        if self.status is not None:
            raise Exception("Booking already exists")
        
        # Business rule validation
        if check_in >= check_out:
            raise Exception("Check-in must be before check-out")
        
        if check_in <= datetime.now():
            raise Exception("Check-in must be in the future")
        
        # Generate event
        event = BookingEvent('BookingRequested', {
            'bookingId': self.booking_id,
            'guestId': guest_id,
            'hostId': host_id,
            'listingId': listing_id,
            'checkInDate': check_in.isoformat(),
            'checkOutDate': check_out.isoformat(),
            'totalAmount': total_amount,
            'currency': currency,
            'requestedAt': datetime.now().isoformat()
        })
        
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def confirm_booking(self, confirmation_code: str, payment_method_id: str):
        """Confirm a requested booking"""
        if self.status != BookingStatus.REQUESTED:
            raise Exception(f"Cannot confirm booking in status: {self.status}")
        
        # Check availability (would integrate with availability service)
        if not self._check_availability():
            raise Exception("Listing no longer available for selected dates")
        
        event = BookingEvent('BookingConfirmed', {
            'bookingId': self.booking_id,
            'confirmationCode': confirmation_code,
            'paymentMethodId': payment_method_id,
            'confirmedAt': datetime.now().isoformat()
        })
        
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def cancel_booking(self, cancelled_by: str, reason: str, refund_amount: float = None):
        """Cancel a booking"""
        if self.status in [BookingStatus.CANCELLED, BookingStatus.COMPLETED]:
            raise Exception(f"Cannot cancel booking in status: {self.status}")
        
        # Calculate refund based on cancellation policy
        calculated_refund = self._calculate_refund_amount()
        final_refund = refund_amount if refund_amount is not None else calculated_refund
        
        event = BookingEvent('BookingCancelled', {
            'bookingId': self.booking_id,
            'cancelledBy': cancelled_by,
            'reason': reason,
            'refundAmount': final_refund,
            'cancelledAt': datetime.now().isoformat()
        })
        
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def modify_booking(self, new_check_in: datetime = None, new_check_out: datetime = None):
        """Modify booking dates"""
        if self.status != BookingStatus.CONFIRMED:
            raise Exception(f"Cannot modify booking in status: {self.status}")
        
        changes = {}
        if new_check_in and new_check_in != self.check_in_date:
            changes['checkInDate'] = new_check_in.isoformat()
        
        if new_check_out and new_check_out != self.check_out_date:
            changes['checkOutDate'] = new_check_out.isoformat()
        
        if not changes:
            return  # No changes to apply
        
        # Recalculate pricing for new dates
        new_amount = self._calculate_new_amount(new_check_in, new_check_out)
        changes['newTotalAmount'] = new_amount
        
        event = BookingEvent('BookingModified', {
            'bookingId': self.booking_id,
            'changes': changes,
            'modifiedAt': datetime.now().isoformat()
        })
        
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def _apply_event(self, event: BookingEvent):
        """Apply event to aggregate state"""
        if event.event_type == 'BookingRequested':
            self._apply_booking_requested(event)
        elif event.event_type == 'BookingConfirmed':
            self._apply_booking_confirmed(event)
        elif event.event_type == 'BookingCancelled':
            self._apply_booking_cancelled(event)
        elif event.event_type == 'BookingModified':
            self._apply_booking_modified(event)
        elif event.event_type == 'PaymentProcessed':
            self._apply_payment_processed(event)
        
        self.version += 1
        self.last_modified_at = event.timestamp
        self.state_transitions.append({
            'from_status': self.status.value if self.status else None,
            'event_type': event.event_type,
            'timestamp': event.timestamp
        })
    
    def _apply_booking_requested(self, event: BookingEvent):
        """Apply BookingRequested event"""
        data = event.data
        self.status = BookingStatus.REQUESTED
        self.guest_id = data['guestId']
        self.host_id = data['hostId']
        self.listing_id = data['listingId']
        self.check_in_date = datetime.fromisoformat(data['checkInDate'])
        self.check_out_date = datetime.fromisoformat(data['checkOutDate'])
        self.total_amount = data['totalAmount']
        self.currency = data['currency']
        self.created_at = datetime.fromisoformat(data['requestedAt'])
    
    def _apply_booking_confirmed(self, event: BookingEvent):
        """Apply BookingConfirmed event"""
        self.status = BookingStatus.CONFIRMED
        self.payment_status = 'pending'
    
    def _apply_booking_cancelled(self, event: BookingEvent):
        """Apply BookingCancelled event"""
        self.status = BookingStatus.CANCELLED
    
    def _apply_booking_modified(self, event: BookingEvent):
        """Apply BookingModified event"""
        changes = event.data['changes']
        
        if 'checkInDate' in changes:
            self.check_in_date = datetime.fromisoformat(changes['checkInDate'])
        
        if 'checkOutDate' in changes:
            self.check_out_date = datetime.fromisoformat(changes['checkOutDate'])
        
        if 'newTotalAmount' in changes:
            self.total_amount = changes['newTotalAmount']
    
    def _apply_payment_processed(self, event: BookingEvent):
        """Apply PaymentProcessed event"""
        self.payment_status = event.data['status']
    
    def _check_availability(self) -> bool:
        """Check if listing is available for dates"""
        # Would integrate with availability service
        return True
    
    def _calculate_refund_amount(self) -> float:
        """Calculate refund based on cancellation policy"""
        if not self.check_in_date or not self.total_amount:
            return 0.0
        
        days_until_checkin = (self.check_in_date - datetime.now()).days
        
        # Flexible cancellation policy example
        if days_until_checkin >= 7:
            return self.total_amount * 0.95  # 95% refund
        elif days_until_checkin >= 3:
            return self.total_amount * 0.50  # 50% refund
        else:
            return 0.0  # No refund
    
    def _calculate_new_amount(self, new_check_in: datetime, new_check_out: datetime) -> float:
        """Calculate new amount for modified dates"""
        # Would integrate with pricing service
        nights = (new_check_out - new_check_in).days
        return nights * 100.0  # Simplified pricing
    
    def load_from_history(self, events: List[BookingEvent]):
        """Rebuild aggregate from event history"""
        for event in events:
            self._apply_event(event)
    
    def mark_events_as_committed(self):
        """Clear uncommitted events after persistence"""
        self.uncommitted_events.clear()
```

### Event Store Implementation
```python
import boto3
import json
from decimal import Decimal

class DynamoDBEventStore:
    def __init__(self, table_name: str):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def append_events(self, aggregate_id: str, expected_version: int, events: List[BookingEvent]):
        """Append events with optimistic concurrency control"""
        try:
            with self.table.batch_writer() as batch:
                for i, event in enumerate(events):
                    version = expected_version + i + 1
                    
                    item = {
                        'AggregateId': aggregate_id,
                        'Version': version,
                        'EventId': event.event_id,
                        'EventType': event.event_type,
                        'EventData': json.dumps(event.data, default=str),
                        'Timestamp': event.timestamp.isoformat(),
                        'CreatedAt': datetime.now().isoformat()
                    }
                    
                    batch.put_item(Item=item)
                    
        except Exception as e:
            raise EventStoreException(f"Failed to append events: {e}")
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[BookingEvent]:
        """Get events for aggregate reconstruction"""
        try:
            response = self.table.query(
                KeyConditionExpression='AggregateId = :id AND Version > :version',
                ExpressionAttributeValues={
                    ':id': aggregate_id,
                    ':version': from_version
                },
                ScanIndexForward=True
            )
            
            events = []
            for item in response['Items']:
                event = BookingEvent(
                    event_type=item['EventType'],
                    data=json.loads(item['EventData']),
                    timestamp=datetime.fromisoformat(item['Timestamp'])
                )
                event.event_id = item['EventId']
                events.append(event)
            
            return events
            
        except Exception as e:
            raise EventStoreException(f"Failed to get events: {e}")
    
    def get_aggregate_version(self, aggregate_id: str) -> int:
        """Get current version of aggregate"""
        try:
            response = self.table.query(
                KeyConditionExpression='AggregateId = :id',
                ExpressionAttributeValues={':id': aggregate_id},
                ScanIndexForward=False,
                Limit=1,
                ProjectionExpression='Version'
            )
            
            if response['Items']:
                return response['Items'][0]['Version']
            return 0
            
        except Exception as e:
            raise EventStoreException(f"Failed to get aggregate version: {e}")

class EventStoreException(Exception):
    pass
```

## CQRS Implementation

### Command Side (Write Model)
```python
class BookingCommandHandler:
    def __init__(self, event_store: DynamoDBEventStore, event_bus):
        self.event_store = event_store
        self.event_bus = event_bus
    
    def handle_create_booking(self, command):
        """Handle create booking command"""
        # Create new aggregate
        booking = BookingAggregate(command.booking_id)
        
        # Execute business logic
        booking.request_booking(
            guest_id=command.guest_id,
            host_id=command.host_id,
            listing_id=command.listing_id,
            check_in=command.check_in_date,
            check_out=command.check_out_date,
            total_amount=command.total_amount,
            currency=command.currency
        )
        
        # Persist events
        self.event_store.append_events(
            command.booking_id,
            0,  # New aggregate
            booking.uncommitted_events
        )
        
        # Publish events
        for event in booking.uncommitted_events:
            self.event_bus.publish(event)
        
        booking.mark_events_as_committed()
        return booking.booking_id
    
    def handle_confirm_booking(self, command):
        """Handle confirm booking command"""
        # Load aggregate from events
        events = self.event_store.get_events(command.booking_id)
        booking = BookingAggregate(command.booking_id)
        booking.load_from_history(events)
        
        current_version = booking.version
        
        # Execute business logic
        booking.confirm_booking(
            confirmation_code=command.confirmation_code,
            payment_method_id=command.payment_method_id
        )
        
        # Persist new events
        self.event_store.append_events(
            command.booking_id,
            current_version,
            booking.uncommitted_events
        )
        
        # Publish events
        for event in booking.uncommitted_events:
            self.event_bus.publish(event)
        
        booking.mark_events_as_committed()
        return True
```

### Query Side (Read Model)
```python
class BookingReadModel:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.bookings_table = self.dynamodb.Table('BookingReadModel')
        self.guest_bookings_table = self.dynamodb.Table('GuestBookings')
        self.host_bookings_table = self.dynamodb.Table('HostBookings')
    
    def handle_booking_requested(self, event):
        """Update read model when booking is requested"""
        data = event.data
        
        booking_item = {
            'BookingId': data['bookingId'],
            'Status': 'REQUESTED',
            'GuestId': data['guestId'],
            'HostId': data['hostId'],
            'ListingId': data['listingId'],
            'CheckInDate': data['checkInDate'],
            'CheckOutDate': data['checkOutDate'],
            'TotalAmount': Decimal(str(data['totalAmount'])),
            'Currency': data['currency'],
            'CreatedAt': data['requestedAt'],
            'LastUpdated': event.timestamp.isoformat()
        }
        
        # Update main bookings table
        self.bookings_table.put_item(Item=booking_item)
        
        # Update guest bookings index
        self.guest_bookings_table.put_item(Item={
            'GuestId': data['guestId'],
            'BookingId': data['bookingId'],
            'Status': 'REQUESTED',
            'CheckInDate': data['checkInDate'],
            'ListingId': data['listingId']
        })
        
        # Update host bookings index
        self.host_bookings_table.put_item(Item={
            'HostId': data['hostId'],
            'BookingId': data['bookingId'],
            'Status': 'REQUESTED',
            'CheckInDate': data['checkInDate'],
            'ListingId': data['listingId']
        })
    
    def handle_booking_confirmed(self, event):
        """Update read model when booking is confirmed"""
        booking_id = event.data['bookingId']
        
        # Update main table
        self.bookings_table.update_item(
            Key={'BookingId': booking_id},
            UpdateExpression='SET #status = :status, LastUpdated = :updated',
            ExpressionAttributeNames={'#status': 'Status'},
            ExpressionAttributeValues={
                ':status': 'CONFIRMED',
                ':updated': event.timestamp.isoformat()
            }
        )
        
        # Update indexes (similar pattern)
    
    def get_booking(self, booking_id: str):
        """Get booking details"""
        response = self.bookings_table.get_item(Key={'BookingId': booking_id})
        return response.get('Item')
    
    def get_guest_bookings(self, guest_id: str):
        """Get all bookings for a guest"""
        response = self.guest_bookings_table.query(
            KeyConditionExpression='GuestId = :guest_id',
            ExpressionAttributeValues={':guest_id': guest_id}
        )
        return response['Items']
    
    def get_host_bookings(self, host_id: str):
        """Get all bookings for a host"""
        response = self.host_bookings_table.query(
            KeyConditionExpression='HostId = :host_id',
            ExpressionAttributeValues={':host_id': host_id}
        )
        return response['Items']
```

## Benefits Realized

### Business Benefits
1. **Complete Audit Trail**: Every booking change is recorded with full context
2. **Regulatory Compliance**: Immutable event log satisfies audit requirements
3. **Business Intelligence**: Rich event data enables advanced analytics
4. **Temporal Queries**: Can reconstruct system state at any point in time
5. **Debugging**: Easy to trace exactly what happened in complex workflows

### Technical Benefits
1. **Scalability**: Read and write models can be scaled independently
2. **Performance**: Optimized read models for different query patterns
3. **Reliability**: Event sourcing provides natural backup and recovery
4. **Flexibility**: Easy to add new projections and views
5. **Integration**: Events provide natural integration points

### Operational Benefits
1. **Monitoring**: Rich event stream enables comprehensive monitoring
2. **Testing**: Event replay enables thorough testing scenarios
3. **Recovery**: Can rebuild system state from events
4. **Analytics**: Events provide rich data for business analytics

## Challenges and Solutions

### Challenge 1: Event Schema Evolution
```python
class EventUpgrader:
    def __init__(self):
        self.upgraders = {
            ('BookingRequested', 1, 2): self._upgrade_booking_requested_v1_to_v2,
            ('BookingRequested', 2, 3): self._upgrade_booking_requested_v2_to_v3
        }
    
    def upgrade_event(self, event):
        """Upgrade event to latest version"""
        current_version = event.get('version', 1)
        target_version = self._get_latest_version(event['event_type'])
        
        while current_version < target_version:
            upgrader_key = (event['event_type'], current_version, current_version + 1)
            if upgrader_key in self.upgraders:
                event = self.upgraders[upgrader_key](event)
                current_version += 1
            else:
                break
        
        return event
```

### Challenge 2: Snapshot Optimization
```python
class BookingSnapshotStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('BookingSnapshots')
    
    def save_snapshot(self, aggregate_id: str, version: int, aggregate_state: dict):
        """Save aggregate snapshot"""
        self.table.put_item(Item={
            'AggregateId': aggregate_id,
            'Version': version,
            'SnapshotData': json.dumps(aggregate_state, default=str),
            'CreatedAt': datetime.now().isoformat()
        })
    
    def get_latest_snapshot(self, aggregate_id: str):
        """Get latest snapshot for aggregate"""
        response = self.table.query(
            KeyConditionExpression='AggregateId = :id',
            ExpressionAttributeValues={':id': aggregate_id},
            ScanIndexForward=False,
            Limit=1
        )
        
        if response['Items']:
            item = response['Items'][0]
            return {
                'version': item['Version'],
                'data': json.loads(item['SnapshotData'])
            }
        return None
```

## Key Lessons Learned

### Technical Insights
1. **Event Design**: Events should capture business intent, not just data changes
2. **Aggregate Boundaries**: Careful design of aggregate boundaries is crucial
3. **Eventual Consistency**: Embrace eventual consistency between read models
4. **Schema Evolution**: Plan for event schema changes from the beginning
5. **Snapshot Strategy**: Implement snapshots for long-lived aggregates

### Operational Insights
1. **Monitoring**: Comprehensive monitoring of event processing is essential
2. **Testing**: Event replay enables powerful testing scenarios
3. **Debugging**: Event logs provide excellent debugging capabilities
4. **Performance**: Read model optimization is crucial for query performance
5. **Backup**: Events provide natural backup and disaster recovery

### Business Impact
- **Audit Compliance**: Complete audit trail for all booking transactions
- **Customer Support**: Detailed history enables better customer service
- **Business Analytics**: Rich event data powers business intelligence
- **Fraud Detection**: Event patterns help identify fraudulent activity
- **Operational Excellence**: Better visibility into system behavior

## Architecture Evolution

### Phase 1: Traditional CRUD (2008-2014)
- Monolithic Rails application
- PostgreSQL database
- Simple CRUD operations
- Limited audit capabilities

### Phase 2: Service-Oriented Architecture (2014-2017)
- Service decomposition
- API-first architecture
- Distributed data management
- Increased complexity

### Phase 3: Event Sourcing Implementation (2017-Present)
- Event-driven architecture
- CQRS implementation
- Comprehensive audit trails
- Scalable read models

## Conclusion

Airbnb's adoption of event sourcing for their booking and payment systems demonstrates the power of event-driven architecture for complex business domains. Key success factors include:

1. **Business Alignment**: Events capture business intent and domain concepts
2. **Technical Excellence**: Robust event store and CQRS implementation
3. **Operational Maturity**: Comprehensive monitoring and operational procedures
4. **Gradual Migration**: Incremental adoption rather than big-bang approach
5. **Team Education**: Investment in team knowledge and best practices

The event sourcing architecture has enabled Airbnb to:
- Handle complex booking workflows reliably
- Provide complete audit trails for compliance
- Scale read and write operations independently
- Enable rich business analytics and insights
- Improve system reliability and debuggability

This case study illustrates how event sourcing can transform complex business systems, providing both technical and business benefits while enabling future growth and innovation.
