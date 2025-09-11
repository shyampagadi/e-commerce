# Messaging Design Patterns and Anti-Patterns

## Overview
This comprehensive guide covers proven messaging design patterns, common anti-patterns to avoid, and best practices for building robust event-driven systems. Understanding these patterns is crucial for designing scalable and maintainable messaging architectures.

## Core Messaging Patterns

### 1. Request-Reply Pattern
**Intent**: Enable synchronous communication over asynchronous messaging infrastructure.

```python
import asyncio
import uuid
from typing import Dict, Any, Optional

class RequestReplyPattern:
    def __init__(self, request_queue: str, response_queue: str):
        self.request_queue = request_queue
        self.response_queue = response_queue
        self.pending_requests: Dict[str, asyncio.Future] = {}
        
    async def send_request(self, message: Dict[str, Any], timeout: int = 30) -> Dict[str, Any]:
        """Send request and wait for response"""
        
        correlation_id = str(uuid.uuid4())
        
        # Prepare request message
        request_message = {
            'correlation_id': correlation_id,
            'reply_to': self.response_queue,
            'payload': message,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Create future for response
        response_future = asyncio.Future()
        self.pending_requests[correlation_id] = response_future
        
        try:
            # Send request
            await self._send_message(self.request_queue, request_message)
            
            # Wait for response with timeout
            response = await asyncio.wait_for(response_future, timeout=timeout)
            return response
            
        except asyncio.TimeoutError:
            raise TimeoutError(f"Request {correlation_id} timed out after {timeout}s")
        finally:
            # Clean up pending request
            self.pending_requests.pop(correlation_id, None)
    
    async def handle_response(self, response_message: Dict[str, Any]):
        """Handle incoming response message"""
        
        correlation_id = response_message.get('correlation_id')
        
        if correlation_id in self.pending_requests:
            future = self.pending_requests[correlation_id]
            if not future.done():
                future.set_result(response_message['payload'])

# Usage Example
async def example_request_reply():
    rr_client = RequestReplyPattern('order-requests', 'order-responses')
    
    try:
        response = await rr_client.send_request({
            'action': 'create_order',
            'customer_id': '12345',
            'items': [{'product_id': 'ABC', 'quantity': 2}]
        })
        print(f"Order created: {response}")
    except TimeoutError:
        print("Order creation timed out")
```

**When to Use**:
- Need synchronous behavior over async infrastructure
- Request processing requires immediate response
- Client needs confirmation of operation completion

**Trade-offs**:
- ✅ Familiar synchronous programming model
- ✅ Strong consistency guarantees
- ❌ Reduced scalability due to blocking
- ❌ Timeout management complexity

### 2. Publish-Subscribe Pattern
**Intent**: Decouple message producers from consumers through topic-based routing.

```python
class PublishSubscribePattern:
    def __init__(self, topic_name: str):
        self.topic_name = topic_name
        self.subscribers: Dict[str, callable] = {}
        
    def subscribe(self, subscriber_id: str, handler: callable, 
                 message_filter: Optional[callable] = None):
        """Subscribe to topic with optional message filtering"""
        
        self.subscribers[subscriber_id] = {
            'handler': handler,
            'filter': message_filter or (lambda msg: True)
        }
    
    def unsubscribe(self, subscriber_id: str):
        """Unsubscribe from topic"""
        self.subscribers.pop(subscriber_id, None)
    
    async def publish(self, message: Dict[str, Any]):
        """Publish message to all subscribers"""
        
        # Add metadata
        enriched_message = {
            'message_id': str(uuid.uuid4()),
            'topic': self.topic_name,
            'timestamp': datetime.utcnow().isoformat(),
            'payload': message
        }
        
        # Deliver to all matching subscribers
        delivery_tasks = []
        
        for subscriber_id, config in self.subscribers.items():
            if config['filter'](enriched_message):
                task = asyncio.create_task(
                    self._deliver_message(subscriber_id, config['handler'], enriched_message)
                )
                delivery_tasks.append(task)
        
        # Wait for all deliveries (with error handling)
        if delivery_tasks:
            results = await asyncio.gather(*delivery_tasks, return_exceptions=True)
            
            # Log delivery failures
            for i, result in enumerate(results):
                if isinstance(result, Exception):
                    print(f"Delivery failed for subscriber {list(self.subscribers.keys())[i]}: {result}")
    
    async def _deliver_message(self, subscriber_id: str, handler: callable, message: Dict[str, Any]):
        """Deliver message to individual subscriber"""
        try:
            await handler(message)
        except Exception as e:
            # In production, implement retry logic and dead letter handling
            print(f"Handler error for {subscriber_id}: {e}")
            raise

# Usage Example
async def example_pub_sub():
    order_events = PublishSubscribePattern('order-events')
    
    # Subscribe services
    async def inventory_handler(message):
        print(f"Inventory service processing: {message['payload']}")
    
    async def analytics_handler(message):
        print(f"Analytics service processing: {message['payload']}")
    
    # Filter for high-value orders only
    def high_value_filter(message):
        return message['payload'].get('total_amount', 0) > 1000
    
    order_events.subscribe('inventory-service', inventory_handler)
    order_events.subscribe('analytics-service', analytics_handler, high_value_filter)
    
    # Publish order event
    await order_events.publish({
        'order_id': 'ORD-123',
        'customer_id': 'CUST-456',
        'total_amount': 1500
    })
```

**When to Use**:
- Multiple consumers need same message
- Loose coupling between producers and consumers
- Dynamic subscription management required

**Trade-offs**:
- ✅ High decoupling and flexibility
- ✅ Easy to add new consumers
- ❌ No delivery guarantees by default
- ❌ Potential message duplication

### 3. Message Router Pattern
**Intent**: Route messages to different destinations based on content or rules.

```python
from typing import List, Tuple
import re

class MessageRouter:
    def __init__(self):
        self.routes: List[Tuple[callable, str]] = []
        
    def add_route(self, condition: callable, destination: str):
        """Add routing rule"""
        self.routes.append((condition, destination))
    
    def add_content_route(self, field_path: str, pattern: str, destination: str):
        """Add content-based routing rule"""
        def condition(message):
            value = self._get_nested_value(message, field_path)
            return re.match(pattern, str(value)) is not None
        
        self.add_route(condition, destination)
    
    def add_header_route(self, header_name: str, expected_value: str, destination: str):
        """Add header-based routing rule"""
        def condition(message):
            headers = message.get('headers', {})
            return headers.get(header_name) == expected_value
        
        self.add_route(condition, destination)
    
    async def route_message(self, message: Dict[str, Any]) -> List[str]:
        """Route message to appropriate destinations"""
        
        destinations = []
        
        for condition, destination in self.routes:
            try:
                if condition(message):
                    destinations.append(destination)
            except Exception as e:
                print(f"Routing condition error: {e}")
        
        # Default route if no matches
        if not destinations:
            destinations.append('default-queue')
        
        return destinations
    
    def _get_nested_value(self, obj: Dict, path: str):
        """Get nested dictionary value using dot notation"""
        keys = path.split('.')
        value = obj
        
        for key in keys:
            if isinstance(value, dict) and key in value:
                value = value[key]
            else:
                return None
        
        return value

# Usage Example
async def example_message_router():
    router = MessageRouter()
    
    # Add routing rules
    router.add_content_route('order.priority', 'high', 'high-priority-queue')
    router.add_content_route('order.total_amount', r'^[5-9]\d{3,}', 'high-value-queue')  # $5000+
    router.add_header_route('region', 'us-east-1', 'us-east-processing-queue')
    
    # Route messages
    messages = [
        {
            'order': {'priority': 'high', 'total_amount': 500},
            'headers': {'region': 'us-east-1'}
        },
        {
            'order': {'priority': 'normal', 'total_amount': 7500},
            'headers': {'region': 'eu-west-1'}
        }
    ]
    
    for message in messages:
        destinations = await router.route_message(message)
        print(f"Message routed to: {destinations}")
```

### 4. Saga Pattern (Distributed Transaction)
**Intent**: Manage distributed transactions across multiple services using compensating actions.

```python
from enum import Enum
from dataclasses import dataclass
from typing import List, Dict, Any, Optional

class SagaStepStatus(Enum):
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    COMPENSATED = "COMPENSATED"

@dataclass
class SagaStep:
    step_id: str
    service_name: str
    action: str
    compensation_action: str
    payload: Dict[str, Any]
    status: SagaStepStatus = SagaStepStatus.PENDING
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None

class SagaOrchestrator:
    def __init__(self, saga_id: str):
        self.saga_id = saga_id
        self.steps: List[SagaStep] = []
        self.current_step = 0
        self.compensating = False
        
    def add_step(self, step: SagaStep):
        """Add step to saga"""
        self.steps.append(step)
    
    async def execute(self) -> bool:
        """Execute saga with compensation on failure"""
        
        try:
            # Execute forward steps
            for i, step in enumerate(self.steps):
                self.current_step = i
                
                success = await self._execute_step(step)
                
                if not success:
                    # Start compensation
                    await self._compensate()
                    return False
            
            return True
            
        except Exception as e:
            print(f"Saga execution error: {e}")
            await self._compensate()
            return False
    
    async def _execute_step(self, step: SagaStep) -> bool:
        """Execute individual saga step"""
        
        try:
            # Simulate service call
            result = await self._call_service(
                step.service_name, 
                step.action, 
                step.payload
            )
            
            step.status = SagaStepStatus.COMPLETED
            step.result = result
            return True
            
        except Exception as e:
            step.status = SagaStepStatus.FAILED
            step.error = str(e)
            return False
    
    async def _compensate(self):
        """Execute compensation actions for completed steps"""
        
        self.compensating = True
        
        # Compensate in reverse order
        for i in range(self.current_step, -1, -1):
            step = self.steps[i]
            
            if step.status == SagaStepStatus.COMPLETED:
                try:
                    await self._call_service(
                        step.service_name,
                        step.compensation_action,
                        step.result or step.payload
                    )
                    step.status = SagaStepStatus.COMPENSATED
                    
                except Exception as e:
                    print(f"Compensation failed for step {step.step_id}: {e}")
    
    async def _call_service(self, service: str, action: str, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Simulate service call"""
        # In real implementation, this would make actual service calls
        print(f"Calling {service}.{action} with {payload}")
        
        # Simulate failure for demo
        if action == "reserve_inventory" and payload.get("product_id") == "OUT_OF_STOCK":
            raise Exception("Product out of stock")
        
        return {"success": True, "transaction_id": str(uuid.uuid4())}

# Usage Example
async def example_saga_pattern():
    # Create order processing saga
    saga = SagaOrchestrator("order-saga-123")
    
    # Add saga steps
    saga.add_step(SagaStep(
        step_id="validate-order",
        service_name="order-service",
        action="validate_order",
        compensation_action="cancel_order",
        payload={"order_id": "ORD-123", "customer_id": "CUST-456"}
    ))
    
    saga.add_step(SagaStep(
        step_id="reserve-inventory",
        service_name="inventory-service", 
        action="reserve_inventory",
        compensation_action="release_inventory",
        payload={"product_id": "PROD-789", "quantity": 2}
    ))
    
    saga.add_step(SagaStep(
        step_id="process-payment",
        service_name="payment-service",
        action="charge_payment",
        compensation_action="refund_payment", 
        payload={"amount": 99.99, "payment_method": "card_123"}
    ))
    
    # Execute saga
    success = await saga.execute()
    print(f"Saga completed successfully: {success}")
```

## Advanced Patterns

### 5. Event Sourcing Pattern
**Intent**: Store all changes as a sequence of events rather than current state.

```python
from abc import ABC, abstractmethod
from typing import List, Type

class Event(ABC):
    def __init__(self, aggregate_id: str, version: int):
        self.aggregate_id = aggregate_id
        self.version = version
        self.timestamp = datetime.utcnow()
        self.event_id = str(uuid.uuid4())

class OrderCreated(Event):
    def __init__(self, aggregate_id: str, version: int, customer_id: str, items: List[Dict]):
        super().__init__(aggregate_id, version)
        self.customer_id = customer_id
        self.items = items

class OrderShipped(Event):
    def __init__(self, aggregate_id: str, version: int, tracking_number: str):
        super().__init__(aggregate_id, version)
        self.tracking_number = tracking_number

class EventSourcedAggregate(ABC):
    def __init__(self, aggregate_id: str):
        self.aggregate_id = aggregate_id
        self.version = 0
        self.uncommitted_events: List[Event] = []
    
    def apply_event(self, event: Event):
        """Apply event to aggregate state"""
        self._handle_event(event)
        self.version = event.version
    
    def raise_event(self, event: Event):
        """Raise new event"""
        event.version = self.version + 1
        self.apply_event(event)
        self.uncommitted_events.append(event)
    
    @abstractmethod
    def _handle_event(self, event: Event):
        """Handle specific event types"""
        pass
    
    def get_uncommitted_events(self) -> List[Event]:
        return self.uncommitted_events.copy()
    
    def mark_events_as_committed(self):
        self.uncommitted_events.clear()

class Order(EventSourcedAggregate):
    def __init__(self, aggregate_id: str):
        super().__init__(aggregate_id)
        self.customer_id = None
        self.items = []
        self.status = "PENDING"
        self.tracking_number = None
    
    def create_order(self, customer_id: str, items: List[Dict]):
        if self.customer_id is not None:
            raise ValueError("Order already created")
        
        self.raise_event(OrderCreated(self.aggregate_id, 0, customer_id, items))
    
    def ship_order(self, tracking_number: str):
        if self.status != "CONFIRMED":
            raise ValueError("Order must be confirmed before shipping")
        
        self.raise_event(OrderShipped(self.aggregate_id, self.version, tracking_number))
    
    def _handle_event(self, event: Event):
        if isinstance(event, OrderCreated):
            self.customer_id = event.customer_id
            self.items = event.items
            self.status = "CREATED"
        elif isinstance(event, OrderShipped):
            self.tracking_number = event.tracking_number
            self.status = "SHIPPED"
```

### 6. CQRS (Command Query Responsibility Segregation)
**Intent**: Separate read and write operations using different models.

```python
class CommandHandler:
    def __init__(self, event_store):
        self.event_store = event_store
    
    async def handle_create_order(self, command: Dict[str, Any]) -> str:
        """Handle create order command"""
        
        order_id = str(uuid.uuid4())
        order = Order(order_id)
        
        # Execute business logic
        order.create_order(
            command['customer_id'],
            command['items']
        )
        
        # Persist events
        events = order.get_uncommitted_events()
        await self.event_store.save_events(order_id, events)
        order.mark_events_as_committed()
        
        return order_id

class QueryHandler:
    def __init__(self, read_model_db):
        self.db = read_model_db
    
    async def get_order_summary(self, order_id: str) -> Dict[str, Any]:
        """Get order summary from read model"""
        
        # Query optimized read model
        result = await self.db.query(
            "SELECT * FROM order_summaries WHERE order_id = ?",
            [order_id]
        )
        
        return result[0] if result else None
    
    async def get_customer_orders(self, customer_id: str) -> List[Dict[str, Any]]:
        """Get all orders for customer"""
        
        return await self.db.query(
            "SELECT * FROM order_summaries WHERE customer_id = ? ORDER BY created_at DESC",
            [customer_id]
        )

class ReadModelProjector:
    def __init__(self, read_model_db):
        self.db = read_model_db
    
    async def handle_order_created(self, event: OrderCreated):
        """Project OrderCreated event to read model"""
        
        await self.db.execute(
            """INSERT INTO order_summaries 
               (order_id, customer_id, item_count, status, created_at)
               VALUES (?, ?, ?, ?, ?)""",
            [event.aggregate_id, event.customer_id, len(event.items), 
             "CREATED", event.timestamp]
        )
    
    async def handle_order_shipped(self, event: OrderShipped):
        """Update read model when order ships"""
        
        await self.db.execute(
            """UPDATE order_summaries 
               SET status = ?, tracking_number = ?, shipped_at = ?
               WHERE order_id = ?""",
            ["SHIPPED", event.tracking_number, event.timestamp, event.aggregate_id]
        )
```

## Anti-Patterns to Avoid

### 1. Chatty Messaging Anti-Pattern
**Problem**: Excessive small messages causing performance degradation.

```python
# ❌ Anti-Pattern: Chatty messaging
async def update_user_profile_chatty(user_id: str, updates: Dict[str, Any]):
    """Bad: Send separate message for each field update"""
    
    for field, value in updates.items():
        await send_message('user-updates', {
            'user_id': user_id,
            'field': field,
            'value': value,
            'timestamp': datetime.utcnow().isoformat()
        })

# ✅ Better: Batch updates in single message
async def update_user_profile_batched(user_id: str, updates: Dict[str, Any]):
    """Good: Send single message with all updates"""
    
    await send_message('user-updates', {
        'user_id': user_id,
        'updates': updates,
        'timestamp': datetime.utcnow().isoformat()
    })
```

### 2. Shared Database Anti-Pattern
**Problem**: Multiple services sharing the same database violates service boundaries.

```python
# ❌ Anti-Pattern: Services sharing database
class OrderService:
    def create_order(self, order_data):
        # Direct database access
        db.orders.insert(order_data)
        
        # Direct access to inventory database (BAD!)
        inventory_item = db.inventory.find_one({'product_id': order_data['product_id']})
        if inventory_item['quantity'] < order_data['quantity']:
            raise InsufficientInventoryError()

# ✅ Better: Service communication via messages
class OrderService:
    def create_order(self, order_data):
        # Store in own database
        order_id = self.db.orders.insert(order_data)
        
        # Request inventory check via message
        await self.send_message('inventory-requests', {
            'action': 'check_availability',
            'order_id': order_id,
            'product_id': order_data['product_id'],
            'quantity': order_data['quantity']
        })
```

### 3. Synchronous Event Processing Anti-Pattern
**Problem**: Processing events synchronously blocks the publisher.

```python
# ❌ Anti-Pattern: Synchronous event processing
async def publish_order_created_sync(order_data):
    """Bad: Wait for all event handlers to complete"""
    
    # This blocks until all handlers complete
    await notify_inventory_service(order_data)
    await notify_analytics_service(order_data)
    await notify_shipping_service(order_data)
    await send_customer_email(order_data)
    
    return "Order created"

# ✅ Better: Asynchronous event processing
async def publish_order_created_async(order_data):
    """Good: Fire and forget event publishing"""
    
    # Publish event and return immediately
    await publish_event('order-created', order_data)
    
    return "Order created"
```

### 4. Message Ordering Dependency Anti-Pattern
**Problem**: Assuming message ordering across different message streams.

```python
# ❌ Anti-Pattern: Assuming cross-stream ordering
class OrderProcessor:
    def __init__(self):
        self.expected_sequence = {}
    
    async def process_order_event(self, event):
        """Bad: Assumes events arrive in order across different queues"""
        
        order_id = event['order_id']
        sequence = event['sequence_number']
        
        # This assumption is dangerous in distributed systems
        if order_id not in self.expected_sequence:
            self.expected_sequence[order_id] = 1
        
        if sequence != self.expected_sequence[order_id]:
            raise OrderingError(f"Expected sequence {self.expected_sequence[order_id]}, got {sequence}")

# ✅ Better: Design for out-of-order processing
class OrderProcessor:
    def __init__(self):
        self.order_states = {}
    
    async def process_order_event(self, event):
        """Good: Handle events idempotently regardless of order"""
        
        order_id = event['order_id']
        event_type = event['event_type']
        
        # Use event timestamps and idempotency
        if self._is_event_already_processed(order_id, event['event_id']):
            return  # Idempotent processing
        
        # Apply event based on current state, not sequence
        await self._apply_event_to_state(order_id, event)
```

## Best Practices Summary

### Design Principles
1. **Loose Coupling**: Services should not depend on each other's internal implementation
2. **High Cohesion**: Related functionality should be grouped together
3. **Idempotency**: Operations should be safe to retry
4. **Eventual Consistency**: Accept that distributed systems are eventually consistent
5. **Fault Tolerance**: Design for partial failures and network issues

### Implementation Guidelines
- Use correlation IDs for request tracing
- Implement proper timeout and retry mechanisms
- Design messages to be self-contained
- Version your message schemas
- Monitor message processing metrics
- Implement circuit breakers for external dependencies
- Use dead letter queues for failed messages
- Design for horizontal scaling

These patterns provide a solid foundation for building robust, scalable messaging systems while avoiding common pitfalls that can lead to maintenance nightmares and performance issues.
