# Exercise 4 Solution: Inter-Service Communication

## Solution Overview

This solution demonstrates the design and implementation of inter-service communication patterns for a microservices e-commerce platform, including synchronous and asynchronous communication, service discovery, circuit breakers, and error handling strategies.

## Task 1: Communication Pattern Selection

### Communication Pattern Matrix

| Service Pair | Communication Type | Pattern | Rationale |
|--------------|-------------------|---------|-----------|
| Client → API Gateway | Synchronous | REST | External client communication |
| API Gateway → Services | Synchronous | REST/gRPC | Request routing and load balancing |
| Order → Payment | Synchronous | gRPC | Critical payment processing |
| Order → Inventory | Synchronous | gRPC | Real-time inventory checks |
| Order → Customer | Synchronous | REST | Customer validation |
| Order → Notification | Asynchronous | Events | Non-critical notifications |
| Payment → Order | Asynchronous | Events | Payment status updates |
| Inventory → Order | Asynchronous | Events | Inventory updates |
| Customer → Marketing | Asynchronous | Events | Customer behavior tracking |

### Synchronous Communication Design

#### 1. Order Service → Payment Service
**Communication Type**: Synchronous gRPC
**Rationale**: Critical payment processing requires immediate response
**Implementation**:

```python
# Payment Service gRPC Definition
syntax = "proto3";

package payment;

service PaymentService {
    rpc ProcessPayment(PaymentRequest) returns (PaymentResponse);
    rpc RefundPayment(RefundRequest) returns (RefundResponse);
    rpc GetPaymentStatus(PaymentStatusRequest) returns (PaymentStatusResponse);
}

message PaymentRequest {
    string order_id = 1;
    string customer_id = 2;
    double amount = 3;
    string currency = 4;
    string payment_method = 5;
    string card_token = 6;
}

message PaymentResponse {
    string payment_id = 1;
    string status = 2;
    string transaction_id = 3;
    string error_message = 4;
}

# Order Service gRPC Client
import grpc
from payment_pb2 import PaymentRequest, PaymentResponse
from payment_pb2_grpc import PaymentServiceStub

class PaymentServiceClient:
    def __init__(self, payment_service_url: str):
        self.channel = grpc.insecure_channel(payment_service_url)
        self.stub = PaymentServiceStub(self.channel)
    
    def process_payment(self, order_id: str, customer_id: str, amount: float, 
                      payment_method: str, card_token: str) -> PaymentResponse:
        request = PaymentRequest(
            order_id=order_id,
            customer_id=customer_id,
            amount=amount,
            currency="USD",
            payment_method=payment_method,
            card_token=card_token
        )
        
        try:
            response = self.stub.ProcessPayment(request, timeout=30)
            return response
        except grpc.RpcError as e:
            raise PaymentServiceError(f"Payment processing failed: {e.details()}")
    
    def __del__(self):
        self.channel.close()

# Order Service Implementation
class OrderService:
    def __init__(self, payment_service_client: PaymentServiceClient):
        self._payment_service_client = payment_service_client
    
    def confirm_order(self, order_id: str):
        order = self._order_repository.get(order_id)
        
        # Process payment synchronously
        payment_response = self._payment_service_client.process_payment(
            order_id=order_id,
            customer_id=order.customer_id,
            amount=float(order.total_amount),
            payment_method=order.payment_method,
            card_token=order.card_token
        )
        
        if payment_response.status == "SUCCESS":
            order.status = "CONFIRMED"
            order.payment_id = payment_response.payment_id
            self._order_repository.save(order)
        else:
            raise PaymentFailedError(payment_response.error_message)
```

#### 2. Order Service → Inventory Service
**Communication Type**: Synchronous gRPC
**Rationale**: Real-time inventory validation required
**Implementation**:

```python
# Inventory Service gRPC Definition
syntax = "proto3";

package inventory;

service InventoryService {
    rpc CheckAvailability(AvailabilityRequest) returns (AvailabilityResponse);
    rpc ReserveItems(ReserveRequest) returns (ReserveResponse);
    rpc ReleaseReservation(ReleaseRequest) returns (ReleaseResponse);
}

message AvailabilityRequest {
    string product_id = 1;
    int32 quantity = 2;
}

message AvailabilityResponse {
    bool available = 1;
    int32 available_quantity = 2;
    string warehouse_id = 3;
}

# Order Service Implementation
class OrderService:
    def __init__(self, inventory_service_client: InventoryServiceClient):
        self._inventory_service_client = inventory_service_client
    
    def create_order(self, customer_id: str, items: List[OrderItem]):
        # Check inventory availability for each item
        for item in items:
            availability = self._inventory_service_client.check_availability(
                product_id=item.product_id,
                quantity=item.quantity
            )
            
            if not availability.available:
                raise InsufficientInventoryError(
                    f"Product {item.product_id} not available"
                )
        
        # Create order
        order = Order(customer_id, items)
        return self._order_repository.save(order)
    
    def confirm_order(self, order_id: str):
        order = self._order_repository.get(order_id)
        
        # Reserve inventory
        for item in order.items:
            reserve_response = self._inventory_service_client.reserve_items(
                product_id=item.product_id,
                quantity=item.quantity
            )
            
            if not reserve_response.success:
                raise InventoryReservationError(
                    f"Failed to reserve inventory for product {item.product_id}"
                )
        
        order.status = "CONFIRMED"
        self._order_repository.save(order)
```

### Asynchronous Communication Design

#### 1. Order Service → Notification Service
**Communication Type**: Asynchronous Events
**Rationale**: Non-critical notifications can be processed asynchronously
**Implementation**:

```python
# Domain Events
from dataclasses import dataclass
from datetime import datetime
from typing import Any
import json

@dataclass
class DomainEvent:
    event_id: str
    event_type: str
    aggregate_id: str
    occurred_at: datetime
    data: dict
    
    def to_json(self) -> str:
        return json.dumps({
            "event_id": self.event_id,
            "event_type": self.event_type,
            "aggregate_id": self.aggregate_id,
            "occurred_at": self.occurred_at.isoformat(),
            "data": self.data
        })

class OrderConfirmed(DomainEvent):
    def __init__(self, order_id: str, customer_id: str, total_amount: float):
        super().__init__(
            event_id=str(uuid.uuid4()),
            event_type="OrderConfirmed",
            aggregate_id=order_id,
            occurred_at=datetime.utcnow(),
            data={
                "customer_id": customer_id,
                "total_amount": total_amount,
                "order_id": order_id
            }
        )

# Event Publisher
class EventPublisher:
    def __init__(self, message_queue):
        self._message_queue = message_queue
    
    def publish(self, event: DomainEvent):
        self._message_queue.send(
            topic="order_events",
            message=event.to_json()
        )

# Order Service with Event Publishing
class OrderService:
    def __init__(self, event_publisher: EventPublisher):
        self._event_publisher = event_publisher
    
    def confirm_order(self, order_id: str):
        order = self._order_repository.get(order_id)
        order.status = "CONFIRMED"
        self._order_repository.save(order)
        
        # Publish domain event
        event = OrderConfirmed(
            order_id=order_id,
            customer_id=order.customer_id,
            total_amount=float(order.total_amount)
        )
        self._event_publisher.publish(event)

# Notification Service Event Handler
class NotificationService:
    def __init__(self, message_queue, email_service, sms_service):
        self._message_queue = message_queue
        self._email_service = email_service
        self._sms_service = sms_service
        self._setup_event_handlers()
    
    def _setup_event_handlers(self):
        self._message_queue.subscribe("order_events", self._handle_order_event)
    
    def _handle_order_event(self, message: str):
        event_data = json.loads(message)
        
        if event_data["event_type"] == "OrderConfirmed":
            self._send_order_confirmation(event_data["data"])
    
    def _send_order_confirmation(self, event_data: dict):
        order_id = event_data["order_id"]
        customer_id = event_data["customer_id"]
        
        # Get customer email
        customer = self._customer_service_client.get_customer(customer_id)
        
        # Send confirmation email
        self._email_service.send_email(
            to=customer.email,
            subject="Order Confirmation",
            template="order_confirmation",
            data={"order_id": order_id}
        )
```

#### 2. Payment Service → Order Service
**Communication Type**: Asynchronous Events
**Rationale**: Payment status updates can be processed asynchronously
**Implementation**:

```python
# Payment Service Event Publishing
class PaymentService:
    def __init__(self, event_publisher: EventPublisher):
        self._event_publisher = event_publisher
    
    def process_payment(self, order_id: str, amount: float, payment_method: str):
        # Process payment
        payment_result = self._payment_gateway.process_payment(amount, payment_method)
        
        # Publish payment event
        if payment_result.success:
            event = PaymentProcessed(
                order_id=order_id,
                payment_id=payment_result.payment_id,
                amount=amount,
                status="SUCCESS"
            )
        else:
            event = PaymentFailed(
                order_id=order_id,
                amount=amount,
                status="FAILED",
                error_message=payment_result.error_message
            )
        
        self._event_publisher.publish(event)

# Order Service Event Handler
class OrderService:
    def __init__(self, message_queue):
        self._message_queue = message_queue
        self._setup_event_handlers()
    
    def _setup_event_handlers(self):
        self._message_queue.subscribe("payment_events", self._handle_payment_event)
    
    def _handle_payment_event(self, message: str):
        event_data = json.loads(message)
        
        if event_data["event_type"] == "PaymentProcessed":
            self._handle_payment_success(event_data["data"])
        elif event_data["event_type"] == "PaymentFailed":
            self._handle_payment_failure(event_data["data"])
    
    def _handle_payment_success(self, event_data: dict):
        order_id = event_data["order_id"]
        payment_id = event_data["payment_id"]
        
        order = self._order_repository.get(order_id)
        order.payment_id = payment_id
        order.status = "PAID"
        self._order_repository.save(order)
    
    def _handle_payment_failure(self, event_data: dict):
        order_id = event_data["order_id"]
        error_message = event_data["error_message"]
        
        order = self._order_repository.get(order_id)
        order.status = "PAYMENT_FAILED"
        order.error_message = error_message
        self._order_repository.save(order)
```

## Task 2: Service Discovery Implementation

### Service Discovery Architecture

#### 1. Service Registry
**Implementation**: Consul-based service registry
**Features**:
- Service registration and deregistration
- Health checks
- Service discovery
- Configuration management

```python
# Service Registry Implementation
import consul
from typing import List, Dict
import socket

class ServiceRegistry:
    def __init__(self, consul_host: str = "localhost", consul_port: int = 8500):
        self.consul = consul.Consul(host=consul_host, port=consul_port)
    
    def register_service(self, service_name: str, service_port: int, 
                        health_check_url: str = "/health"):
        # Get local IP address
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        
        # Register service
        self.consul.agent.service.register(
            name=service_name,
            service_id=f"{service_name}-{local_ip}-{service_port}",
            address=local_ip,
            port=service_port,
            check=consul.Check.http(
                url=f"http://{local_ip}:{service_port}{health_check_url}",
                interval="10s"
            )
        )
    
    def discover_service(self, service_name: str) -> List[Dict]:
        """Discover healthy instances of a service"""
        services = self.consul.health.service(service_name, passing=True)[1]
        
        instances = []
        for service in services:
            instances.append({
                "address": service["Service"]["Address"],
                "port": service["Service"]["Port"],
                "service_id": service["Service"]["ID"]
            })
        
        return instances
    
    def deregister_service(self, service_id: str):
        self.consul.agent.service.deregister(service_id)

# Service Registration
class OrderService:
    def __init__(self, service_registry: ServiceRegistry):
        self._service_registry = service_registry
        self._register_service()
    
    def _register_service(self):
        self._service_registry.register_service(
            service_name="order-service",
            service_port=8000,
            health_check_url="/health"
        )
    
    def __del__(self):
        self._service_registry.deregister_service("order-service")
```

#### 2. Service Discovery Client
**Implementation**: Client-side service discovery with caching
**Features**:
- Service instance caching
- Load balancing
- Health check integration
- Failover support

```python
# Service Discovery Client
import random
from typing import List, Dict
import time

class ServiceDiscoveryClient:
    def __init__(self, service_registry: ServiceRegistry, cache_ttl: int = 30):
        self._service_registry = service_registry
        self._cache_ttl = cache_ttl
        self._service_cache = {}
        self._cache_timestamps = {}
    
    def get_service_instance(self, service_name: str) -> Dict:
        """Get a healthy service instance with load balancing"""
        instances = self._get_cached_instances(service_name)
        
        if not instances:
            raise ServiceUnavailableError(f"No instances available for {service_name}")
        
        # Simple round-robin load balancing
        instance = random.choice(instances)
        return instance
    
    def _get_cached_instances(self, service_name: str) -> List[Dict]:
        """Get cached service instances or refresh cache"""
        current_time = time.time()
        
        # Check if cache is valid
        if (service_name in self._service_cache and 
            service_name in self._cache_timestamps and
            current_time - self._cache_timestamps[service_name] < self._cache_ttl):
            return self._service_cache[service_name]
        
        # Refresh cache
        instances = self._service_registry.discover_service(service_name)
        self._service_cache[service_name] = instances
        self._cache_timestamps[service_name] = current_time
        
        return instances

# Service Client with Discovery
class PaymentServiceClient:
    def __init__(self, service_discovery_client: ServiceDiscoveryClient):
        self._service_discovery_client = service_discovery_client
    
    def process_payment(self, order_id: str, amount: float, payment_method: str):
        # Discover payment service instance
        instance = self._service_discovery_client.get_service_instance("payment-service")
        
        # Make gRPC call
        channel = grpc.insecure_channel(f"{instance['address']}:{instance['port']}")
        stub = PaymentServiceStub(channel)
        
        request = PaymentRequest(
            order_id=order_id,
            amount=amount,
            payment_method=payment_method
        )
        
        try:
            response = stub.ProcessPayment(request, timeout=30)
            return response
        except grpc.RpcError as e:
            raise PaymentServiceError(f"Payment processing failed: {e.details()}")
        finally:
            channel.close()
```

## Task 3: Circuit Breaker Implementation

### Circuit Breaker Pattern
**Implementation**: Hystrix-style circuit breaker
**Features**:
- Failure threshold detection
- Circuit state management
- Fallback mechanisms
- Automatic recovery

```python
# Circuit Breaker Implementation
import time
from enum import Enum
from typing import Callable, Any
import threading

class CircuitState(Enum):
    CLOSED = "CLOSED"  # Normal operation
    OPEN = "OPEN"      # Circuit is open, failing fast
    HALF_OPEN = "HALF_OPEN"  # Testing if service is back

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, timeout: int = 60, 
                 recovery_timeout: int = 30):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.recovery_timeout = recovery_timeout
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
        self.lock = threading.Lock()
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker protection"""
        with self.lock:
            if self.state == CircuitState.OPEN:
                if self._should_attempt_reset():
                    self.state = CircuitState.HALF_OPEN
                else:
                    raise CircuitBreakerOpenError("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e
    
    def _should_attempt_reset(self) -> bool:
        """Check if enough time has passed to attempt reset"""
        if self.last_failure_time is None:
            return True
        
        return time.time() - self.last_failure_time >= self.recovery_timeout
    
    def _on_success(self):
        """Handle successful call"""
        with self.lock:
            self.failure_count = 0
            if self.state == CircuitState.HALF_OPEN:
                self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        """Handle failed call"""
        with self.lock:
            self.failure_count += 1
            self.last_failure_time = time.time()
            
            if self.failure_count >= self.failure_threshold:
                self.state = CircuitState.OPEN

# Circuit Breaker Integration
class PaymentServiceClient:
    def __init__(self, service_discovery_client: ServiceDiscoveryClient):
        self._service_discovery_client = service_discovery_client
        self._circuit_breaker = CircuitBreaker(
            failure_threshold=5,
            timeout=60,
            recovery_timeout=30
        )
    
    def process_payment(self, order_id: str, amount: float, payment_method: str):
        """Process payment with circuit breaker protection"""
        try:
            return self._circuit_breaker.call(
                self._process_payment_internal,
                order_id, amount, payment_method
            )
        except CircuitBreakerOpenError:
            # Fallback to cached payment methods or alternative provider
            return self._fallback_payment_processing(order_id, amount, payment_method)
    
    def _process_payment_internal(self, order_id: str, amount: float, payment_method: str):
        """Internal payment processing logic"""
        instance = self._service_discovery_client.get_service_instance("payment-service")
        
        channel = grpc.insecure_channel(f"{instance['address']}:{instance['port']}")
        stub = PaymentServiceStub(channel)
        
        request = PaymentRequest(
            order_id=order_id,
            amount=amount,
            payment_method=payment_method
        )
        
        try:
            response = stub.ProcessPayment(request, timeout=30)
            return response
        finally:
            channel.close()
    
    def _fallback_payment_processing(self, order_id: str, amount: float, payment_method: str):
        """Fallback payment processing when circuit breaker is open"""
        # Use alternative payment provider or cached payment methods
        return PaymentResponse(
            payment_id="fallback-payment-id",
            status="PENDING",
            transaction_id="fallback-transaction-id",
            error_message="Using fallback payment processing"
        )
```

## Task 4: Error Handling Strategy

### Error Handling Framework
**Implementation**: Comprehensive error handling with retry logic
**Features**:
- Error classification
- Retry mechanisms
- Dead letter queues
- Error monitoring

```python
# Error Classification
class ServiceError(Exception):
    """Base class for service errors"""
    def __init__(self, message: str, error_code: str = None, retryable: bool = False):
        super().__init__(message)
        self.error_code = error_code
        self.retryable = retryable

class PaymentServiceError(ServiceError):
    """Payment service specific errors"""
    def __init__(self, message: str, error_code: str = None, retryable: bool = False):
        super().__init__(message, error_code, retryable)

class InventoryServiceError(ServiceError):
    """Inventory service specific errors"""
    def __init__(self, message: str, error_code: str = None, retryable: bool = False):
        super().__init__(message, error_code, retryable)

class CircuitBreakerOpenError(ServiceError):
    """Circuit breaker is open"""
    def __init__(self, message: str = "Circuit breaker is open"):
        super().__init__(message, "CIRCUIT_BREAKER_OPEN", retryable=True)

# Retry Mechanism
import time
import random
from typing import Callable, Any

class RetryMechanism:
    def __init__(self, max_retries: int = 3, base_delay: float = 1.0, 
                 max_delay: float = 60.0, backoff_multiplier: float = 2.0):
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.backoff_multiplier = backoff_multiplier
    
    def execute(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with retry logic"""
        last_exception = None
        
        for attempt in range(self.max_retries + 1):
            try:
                return func(*args, **kwargs)
            except ServiceError as e:
                last_exception = e
                
                if not e.retryable or attempt == self.max_retries:
                    raise e
                
                # Calculate delay with exponential backoff and jitter
                delay = min(
                    self.base_delay * (self.backoff_multiplier ** attempt),
                    self.max_delay
                )
                jitter = random.uniform(0, delay * 0.1)
                time.sleep(delay + jitter)
        
        raise last_exception

# Error Handling Integration
class OrderService:
    def __init__(self, payment_service_client: PaymentServiceClient,
                 inventory_service_client: InventoryServiceClient):
        self._payment_service_client = payment_service_client
        self._inventory_service_client = inventory_service_client
        self._retry_mechanism = RetryMechanism(max_retries=3)
    
    def confirm_order(self, order_id: str):
        """Confirm order with comprehensive error handling"""
        order = self._order_repository.get(order_id)
        
        try:
            # Process payment with retry
            payment_response = self._retry_mechanism.execute(
                self._payment_service_client.process_payment,
                order_id=order_id,
                amount=float(order.total_amount),
                payment_method=order.payment_method
            )
            
            if payment_response.status == "SUCCESS":
                # Reserve inventory with retry
                self._retry_mechanism.execute(
                    self._reserve_inventory,
                    order.items
                )
                
                order.status = "CONFIRMED"
                order.payment_id = payment_response.payment_id
                self._order_repository.save(order)
            else:
                raise PaymentFailedError(payment_response.error_message)
                
        except ServiceError as e:
            # Handle service errors
            if e.retryable:
                # Log retryable error and potentially retry later
                self._log_error(f"Retryable error: {e.message}", order_id)
                raise OrderProcessingError(f"Order processing failed: {e.message}")
            else:
                # Handle non-retryable errors
                self._handle_non_retryable_error(e, order_id)
                raise OrderProcessingError(f"Order processing failed: {e.message}")
    
    def _reserve_inventory(self, items: List[OrderItem]):
        """Reserve inventory for order items"""
        for item in items:
            reserve_response = self._inventory_service_client.reserve_items(
                product_id=item.product_id,
                quantity=item.quantity
            )
            
            if not reserve_response.success:
                raise InventoryReservationError(
                    f"Failed to reserve inventory for product {item.product_id}"
                )
    
    def _log_error(self, message: str, order_id: str):
        """Log error for monitoring and debugging"""
        # Log to centralized logging system
        pass
    
    def _handle_non_retryable_error(self, error: ServiceError, order_id: str):
        """Handle non-retryable errors"""
        # Update order status to failed
        order = self._order_repository.get(order_id)
        order.status = "FAILED"
        order.error_message = error.message
        self._order_repository.save(order)
        
        # Send notification to customer
        self._notification_service.send_order_failed_notification(order_id, error.message)
```

## Best Practices Applied

### Communication Design
1. **Pattern Selection**: Choose appropriate communication patterns based on requirements
2. **Synchronous for Critical**: Use synchronous communication for critical operations
3. **Asynchronous for Non-Critical**: Use asynchronous communication for non-critical operations
4. **Event-Driven**: Use events for loose coupling and scalability
5. **Protocol Selection**: Choose appropriate protocols (REST, gRPC, GraphQL)

### Service Discovery
1. **Health Checks**: Implement comprehensive health checks
2. **Load Balancing**: Use appropriate load balancing strategies
3. **Caching**: Cache service instances for performance
4. **Failover**: Implement failover mechanisms
5. **Monitoring**: Monitor service discovery health

### Circuit Breaker
1. **Failure Threshold**: Set appropriate failure thresholds
2. **Recovery Timeout**: Configure recovery timeouts
3. **Fallback Mechanisms**: Implement fallback strategies
4. **Monitoring**: Monitor circuit breaker states
5. **Testing**: Test circuit breaker behavior

### Error Handling
1. **Error Classification**: Classify errors by type and retryability
2. **Retry Logic**: Implement exponential backoff with jitter
3. **Dead Letter Queues**: Use dead letter queues for failed messages
4. **Monitoring**: Monitor error rates and patterns
5. **Graceful Degradation**: Implement graceful degradation strategies

## Lessons Learned

### Key Insights
1. **Communication Patterns**: Choose patterns based on requirements and constraints
2. **Service Discovery**: Essential for dynamic service environments
3. **Circuit Breakers**: Critical for preventing cascading failures
4. **Error Handling**: Comprehensive error handling improves system reliability
5. **Monitoring**: Monitor all aspects of service communication

### Common Pitfalls
1. **Over-Synchronous**: Don't use synchronous communication for everything
2. **Poor Error Handling**: Don't ignore error handling
3. **No Circuit Breakers**: Don't skip circuit breaker implementation
4. **Poor Service Discovery**: Don't hardcode service endpoints
5. **No Monitoring**: Don't skip monitoring and observability

### Recommendations
1. **Start Simple**: Begin with simple communication patterns
2. **Add Resilience**: Add circuit breakers and retry logic
3. **Monitor Everything**: Implement comprehensive monitoring
4. **Test Failures**: Test failure scenarios regularly
5. **Iterate**: Continuously improve communication patterns

## Next Steps

1. **Implementation**: Implement the communication patterns
2. **Testing**: Test all communication scenarios
3. **Monitoring**: Set up comprehensive monitoring
4. **Optimization**: Optimize communication performance
5. **Evolution**: Evolve patterns based on requirements
