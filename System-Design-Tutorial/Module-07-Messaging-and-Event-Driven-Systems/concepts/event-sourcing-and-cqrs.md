# Event Sourcing and CQRS Patterns

## Overview
Event Sourcing and Command Query Responsibility Segregation (CQRS) are powerful architectural patterns that enable scalable, auditable, and flexible systems by treating events as the source of truth and separating read and write operations.

## Event Sourcing Fundamentals

### Core Principles
Event Sourcing stores all changes to application state as a sequence of immutable events, rather than storing current state directly.

```python
# Traditional State Storage
class Account:
    def __init__(self, account_id, balance=0):
        self.account_id = account_id
        self.balance = balance  # Current state only
    
    def deposit(self, amount):
        self.balance += amount  # State mutation

# Event Sourcing Approach
class AccountEvent:
    def __init__(self, event_type, data, timestamp):
        self.event_type = event_type
        self.data = data
        self.timestamp = timestamp

class AccountAggregate:
    def __init__(self, account_id):
        self.account_id = account_id
        self.events = []
        self.balance = 0
    
    def deposit(self, amount):
        event = AccountEvent('DEPOSIT', {'amount': amount}, datetime.now())
        self.events.append(event)
        self.apply_event(event)
    
    def apply_event(self, event):
        if event.event_type == 'DEPOSIT':
            self.balance += event.data['amount']
        elif event.event_type == 'WITHDRAWAL':
            self.balance -= event.data['amount']
    
    def rebuild_from_events(self, events):
        self.balance = 0
        for event in events:
            self.apply_event(event)
```

### Event Store Design

#### Event Schema
```json
{
  "eventId": "uuid-v4",
  "aggregateId": "account-123",
  "aggregateType": "Account",
  "eventType": "MoneyDeposited",
  "eventVersion": 1,
  "eventData": {
    "amount": 100.00,
    "currency": "USD",
    "depositMethod": "BANK_TRANSFER"
  },
  "metadata": {
    "userId": "user-456",
    "correlationId": "correlation-789",
    "causationId": "command-abc"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "position": 12345
}
```

#### DynamoDB Event Store Implementation
```python
import boto3
from decimal import Decimal
import json

class DynamoDBEventStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('EventStore')
    
    def append_events(self, aggregate_id, expected_version, events):
        """Append events with optimistic concurrency control"""
        try:
            with self.table.batch_writer() as batch:
                for i, event in enumerate(events):
                    item = {
                        'AggregateId': aggregate_id,
                        'Version': expected_version + i + 1,
                        'EventId': event.event_id,
                        'EventType': event.event_type,
                        'EventData': json.dumps(event.data, default=str),
                        'Timestamp': event.timestamp.isoformat(),
                        'Position': self._get_next_position()
                    }
                    batch.put_item(Item=item)
        except Exception as e:
            raise ConcurrencyException(f"Failed to append events: {e}")
    
    def get_events(self, aggregate_id, from_version=0):
        """Retrieve events for aggregate reconstruction"""
        response = self.table.query(
            KeyConditionExpression='AggregateId = :id AND Version > :version',
            ExpressionAttributeValues={
                ':id': aggregate_id,
                ':version': from_version
            },
            ScanIndexForward=True
        )
        return [self._deserialize_event(item) for item in response['Items']]
```

### Aggregate Reconstruction
```python
class EventSourcedAggregate:
    def __init__(self, aggregate_id):
        self.aggregate_id = aggregate_id
        self.version = 0
        self.uncommitted_events = []
    
    def load_from_history(self, events):
        """Rebuild aggregate state from events"""
        for event in events:
            self._apply_event(event)
            self.version += 1
    
    def _apply_event(self, event):
        """Apply event to aggregate state"""
        method_name = f"_apply_{event.event_type.lower()}"
        if hasattr(self, method_name):
            getattr(self, method_name)(event)
    
    def mark_events_as_committed(self):
        """Clear uncommitted events after persistence"""
        self.uncommitted_events.clear()

class BankAccount(EventSourcedAggregate):
    def __init__(self, account_id):
        super().__init__(account_id)
        self.balance = Decimal('0')
        self.is_closed = False
    
    def deposit(self, amount, deposit_method):
        if self.is_closed:
            raise AccountClosedException()
        
        event = MoneyDepositedEvent(amount, deposit_method)
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def _apply_moneydeposited(self, event):
        self.balance += event.amount
```

## CQRS (Command Query Responsibility Segregation)

### Core Concepts
CQRS separates read and write operations into different models, optimizing each for their specific use case.

```python
# Command Side (Write Model)
class DepositMoneyCommand:
    def __init__(self, account_id, amount, deposit_method):
        self.account_id = account_id
        self.amount = amount
        self.deposit_method = deposit_method

class AccountCommandHandler:
    def __init__(self, event_store, event_bus):
        self.event_store = event_store
        self.event_bus = event_bus
    
    def handle_deposit_money(self, command):
        # Load aggregate from events
        events = self.event_store.get_events(command.account_id)
        account = BankAccount(command.account_id)
        account.load_from_history(events)
        
        # Execute business logic
        account.deposit(command.amount, command.deposit_method)
        
        # Persist new events
        self.event_store.append_events(
            command.account_id,
            account.version,
            account.uncommitted_events
        )
        
        # Publish events
        for event in account.uncommitted_events:
            self.event_bus.publish(event)
        
        account.mark_events_as_committed()

# Query Side (Read Model)
class AccountSummaryProjection:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('AccountSummary')
    
    def handle_money_deposited(self, event):
        """Update read model when money is deposited"""
        self.table.update_item(
            Key={'AccountId': event.aggregate_id},
            UpdateExpression='ADD Balance :amount SET LastUpdated = :timestamp',
            ExpressionAttributeValues={
                ':amount': event.amount,
                ':timestamp': event.timestamp
            }
        )

class AccountQueryHandler:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('AccountSummary')
    
    def get_account_summary(self, account_id):
        response = self.table.get_item(Key={'AccountId': account_id})
        return response.get('Item')
```

### Event Bus Implementation
```python
import boto3
import json

class SNSEventBus:
    def __init__(self, topic_arn):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
    
    def publish(self, event):
        message = {
            'eventType': event.event_type,
            'aggregateId': event.aggregate_id,
            'eventData': event.data,
            'timestamp': event.timestamp.isoformat()
        }
        
        self.sns.publish(
            TopicArn=self.topic_arn,
            Message=json.dumps(message),
            MessageAttributes={
                'eventType': {
                    'DataType': 'String',
                    'StringValue': event.event_type
                }
            }
        )

class EventBridgeEventBus:
    def __init__(self, event_bus_name):
        self.eventbridge = boto3.client('events')
        self.event_bus_name = event_bus_name
    
    def publish(self, event):
        self.eventbridge.put_events(
            Entries=[
                {
                    'Source': 'banking.accounts',
                    'DetailType': event.event_type,
                    'Detail': json.dumps({
                        'aggregateId': event.aggregate_id,
                        'eventData': event.data,
                        'timestamp': event.timestamp.isoformat()
                    }),
                    'EventBusName': self.event_bus_name
                }
            ]
        )
```

## Advanced Patterns

### Saga Pattern for Distributed Transactions
```python
class TransferMoneySaga:
    def __init__(self, saga_id, from_account, to_account, amount):
        self.saga_id = saga_id
        self.from_account = from_account
        self.to_account = to_account
        self.amount = amount
        self.state = 'STARTED'
        self.compensations = []
    
    def handle_money_withdrawn(self, event):
        if self.state == 'STARTED':
            # Proceed to deposit
            deposit_command = DepositMoneyCommand(
                self.to_account, 
                self.amount, 
                'TRANSFER'
            )
            self.command_bus.send(deposit_command)
            self.state = 'WITHDRAWN'
            
            # Record compensation
            self.compensations.append(
                DepositMoneyCommand(self.from_account, self.amount, 'COMPENSATION')
            )
    
    def handle_money_deposited(self, event):
        if self.state == 'WITHDRAWN':
            self.state = 'COMPLETED'
            # Saga completed successfully
    
    def handle_deposit_failed(self, event):
        if self.state == 'WITHDRAWN':
            # Execute compensations
            for compensation in reversed(self.compensations):
                self.command_bus.send(compensation)
            self.state = 'COMPENSATING'
```

### Snapshot Optimization
```python
class SnapshotStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table('Snapshots')
    
    def save_snapshot(self, aggregate_id, version, snapshot_data):
        self.table.put_item(
            Item={
                'AggregateId': aggregate_id,
                'Version': version,
                'SnapshotData': json.dumps(snapshot_data, default=str),
                'Timestamp': datetime.now().isoformat()
            }
        )
    
    def get_latest_snapshot(self, aggregate_id):
        response = self.table.query(
            KeyConditionExpression='AggregateId = :id',
            ExpressionAttributeValues={':id': aggregate_id},
            ScanIndexForward=False,
            Limit=1
        )
        return response['Items'][0] if response['Items'] else None

class OptimizedAggregate(EventSourcedAggregate):
    def load_from_history(self, events, snapshot=None):
        if snapshot:
            self._apply_snapshot(snapshot)
            # Only apply events after snapshot
            events = [e for e in events if e.version > snapshot['Version']]
        
        for event in events:
            self._apply_event(event)
            self.version += 1
        
        # Create snapshot every 100 events
        if self.version % 100 == 0:
            self._create_snapshot()
```

## Event Versioning and Schema Evolution

### Event Versioning Strategy
```python
class VersionedEvent:
    def __init__(self, event_type, version, data):
        self.event_type = event_type
        self.version = version
        self.data = data

class EventUpgrader:
    def __init__(self):
        self.upgraders = {
            ('MoneyDeposited', 1, 2): self._upgrade_money_deposited_v1_to_v2,
            ('MoneyDeposited', 2, 3): self._upgrade_money_deposited_v2_to_v3
        }
    
    def upgrade_event(self, event):
        current_version = event.version
        target_version = self._get_latest_version(event.event_type)
        
        while current_version < target_version:
            upgrader_key = (event.event_type, current_version, current_version + 1)
            if upgrader_key in self.upgraders:
                event = self.upgraders[upgrader_key](event)
                current_version += 1
            else:
                break
        
        return event
    
    def _upgrade_money_deposited_v1_to_v2(self, event):
        # Add currency field (default to USD)
        new_data = event.data.copy()
        new_data['currency'] = 'USD'
        return VersionedEvent(event.event_type, 2, new_data)
```

## Performance Optimization

### Event Store Partitioning
```python
class PartitionedEventStore:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
    
    def _get_partition_key(self, aggregate_id):
        # Distribute aggregates across partitions
        return f"partition_{hash(aggregate_id) % 10}"
    
    def append_events(self, aggregate_id, expected_version, events):
        partition_key = self._get_partition_key(aggregate_id)
        table = self.dynamodb.Table(f'EventStore_{partition_key}')
        
        # Use partition key for better distribution
        # Implementation similar to previous example
```

### Read Model Optimization
```python
class MaterializedViewProjection:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.summary_table = self.dynamodb.Table('AccountSummary')
        self.transaction_table = self.dynamodb.Table('TransactionHistory')
    
    def handle_money_deposited(self, event):
        # Update multiple read models atomically
        with self.dynamodb.batch_writer() as batch:
            # Update account summary
            batch.put_item(
                TableName='AccountSummary',
                Item={
                    'AccountId': event.aggregate_id,
                    'Balance': event.new_balance,
                    'LastTransaction': event.timestamp
                }
            )
            
            # Add to transaction history
            batch.put_item(
                TableName='TransactionHistory',
                Item={
                    'AccountId': event.aggregate_id,
                    'TransactionId': event.event_id,
                    'Type': 'DEPOSIT',
                    'Amount': event.amount,
                    'Timestamp': event.timestamp
                }
            )
```

## Testing Strategies

### Event Sourcing Tests
```python
import unittest
from unittest.mock import Mock

class TestBankAccount(unittest.TestCase):
    def test_deposit_money_creates_event(self):
        # Given
        account = BankAccount('account-123')
        
        # When
        account.deposit(Decimal('100.00'), 'BANK_TRANSFER')
        
        # Then
        self.assertEqual(len(account.uncommitted_events), 1)
        event = account.uncommitted_events[0]
        self.assertEqual(event.event_type, 'MoneyDeposited')
        self.assertEqual(event.amount, Decimal('100.00'))
    
    def test_account_reconstruction_from_events(self):
        # Given
        events = [
            MoneyDepositedEvent(Decimal('100.00'), 'BANK_TRANSFER'),
            MoneyWithdrawnEvent(Decimal('30.00'), 'ATM')
        ]
        
        # When
        account = BankAccount('account-123')
        account.load_from_history(events)
        
        # Then
        self.assertEqual(account.balance, Decimal('70.00'))
        self.assertEqual(account.version, 2)

class TestCQRSHandlers(unittest.TestCase):
    def test_command_handler_processes_deposit(self):
        # Given
        event_store = Mock()
        event_bus = Mock()
        handler = AccountCommandHandler(event_store, event_bus)
        command = DepositMoneyCommand('account-123', Decimal('100.00'), 'TRANSFER')
        
        # When
        handler.handle_deposit_money(command)
        
        # Then
        event_store.append_events.assert_called_once()
        event_bus.publish.assert_called()
```

## Best Practices

### Event Design Guidelines
1. **Immutable Events**: Events should never be modified after creation
2. **Rich Events**: Include all necessary data to avoid external lookups
3. **Versioning**: Plan for event schema evolution from the start
4. **Idempotency**: Ensure event handlers can process events multiple times safely

### CQRS Implementation Tips
1. **Eventual Consistency**: Accept that read models may be slightly behind
2. **Separate Databases**: Use different storage optimized for reads vs writes
3. **Event Ordering**: Maintain event ordering within aggregates
4. **Error Handling**: Implement robust error handling and retry mechanisms

### Performance Considerations
1. **Snapshot Strategy**: Implement snapshots for long-lived aggregates
2. **Event Batching**: Process events in batches for better throughput
3. **Projection Optimization**: Optimize read models for query patterns
4. **Caching**: Cache frequently accessed projections

## Common Pitfalls

### Event Sourcing Challenges
- **Event Schema Evolution**: Plan for backward compatibility
- **Large Event Streams**: Implement snapshotting and archiving
- **Complex Queries**: CQRS read models may be necessary
- **Debugging**: Event sourcing can make debugging more complex

### CQRS Challenges
- **Eventual Consistency**: Handle timing issues in user interfaces
- **Complexity**: Don't use CQRS unless you need the benefits
- **Data Synchronization**: Ensure read models stay in sync
- **Testing**: More complex testing scenarios with multiple models

## Conclusion

Event Sourcing and CQRS are powerful patterns that provide:
- **Complete Audit Trail**: Every change is recorded as an event
- **Temporal Queries**: Query system state at any point in time
- **Scalability**: Separate read and write concerns for optimal performance
- **Flexibility**: Easy to add new projections and views

These patterns are particularly valuable for:
- Financial systems requiring audit trails
- Systems with complex business logic
- Applications needing high read/write scalability
- Domains where historical data is important

When implemented correctly, Event Sourcing and CQRS enable building robust, scalable, and maintainable distributed systems.
