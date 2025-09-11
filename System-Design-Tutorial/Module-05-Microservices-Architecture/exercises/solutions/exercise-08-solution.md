# Exercise 8 Solution: Monitoring and Observability

## Solution Overview

This solution demonstrates the implementation of comprehensive monitoring and observability for microservices, including health checks, metrics collection, distributed tracing, structured logging, and alerting for an e-commerce platform.

## Task 1: Health Check Implementation

### Health Check System

#### 1. Service Health Checks
**Strategy**: Implement comprehensive health checks for all services
**Implementation**:

```python
# Health Check Implementation
from fastapi import FastAPI, HTTPException, status
from typing import Dict, Any, List
from dataclasses import dataclass
from datetime import datetime
import asyncio
import aiohttp
import psutil
import time

@dataclass
class HealthCheckResult:
    service: str
    status: str  # healthy, unhealthy, degraded
    timestamp: datetime
    response_time: float
    details: Dict[str, Any]

class HealthChecker:
    def __init__(self, service_name: str, dependencies: List[str] = None):
        self.service_name = service_name
        self.dependencies = dependencies or []
        self.start_time = time.time()
    
    async def check_health(self) -> HealthCheckResult:
        """Perform comprehensive health check"""
        start_time = time.time()
        
        try:
            # Check basic service health
            basic_health = await self._check_basic_health()
            
            # Check dependencies
            dependency_health = await self._check_dependencies()
            
            # Check system resources
            system_health = self._check_system_resources()
            
            # Determine overall status
            overall_status = self._determine_status(basic_health, dependency_health, system_health)
            
            response_time = time.time() - start_time
            
            return HealthCheckResult(
                service=self.service_name,
                status=overall_status,
                timestamp=datetime.utcnow(),
                response_time=response_time,
                details={
                    "basic_health": basic_health,
                    "dependencies": dependency_health,
                    "system_resources": system_health,
                    "uptime": time.time() - self.start_time
                }
            )
        
        except Exception as e:
            return HealthCheckResult(
                service=self.service_name,
                status="unhealthy",
                timestamp=datetime.utcnow(),
                response_time=time.time() - start_time,
                details={"error": str(e)}
            )
    
    async def _check_basic_health(self) -> Dict[str, Any]:
        """Check basic service health"""
        return {
            "status": "healthy",
            "message": "Service is running normally"
        }
    
    async def _check_dependencies(self) -> Dict[str, Any]:
        """Check dependency health"""
        dependency_results = {}
        
        for dependency in self.dependencies:
            try:
                async with aiohttp.ClientSession() as session:
                    async with session.get(f"http://{dependency}/health", timeout=5) as response:
                        if response.status == 200:
                            dependency_results[dependency] = "healthy"
                        else:
                            dependency_results[dependency] = "unhealthy"
            except Exception as e:
                dependency_results[dependency] = f"error: {str(e)}"
        
        return dependency_results
    
    def _check_system_resources(self) -> Dict[str, Any]:
        """Check system resource usage"""
        return {
            "cpu_percent": psutil.cpu_percent(),
            "memory_percent": psutil.virtual_memory().percent,
            "disk_percent": psutil.disk_usage('/').percent,
            "load_average": psutil.getloadavg() if hasattr(psutil, 'getloadavg') else None
        }
    
    def _determine_status(self, basic_health: Dict, dependency_health: Dict, system_health: Dict) -> str:
        """Determine overall health status"""
        # Check if basic health is good
        if basic_health.get("status") != "healthy":
            return "unhealthy"
        
        # Check if any dependencies are unhealthy
        unhealthy_deps = [dep for dep, status in dependency_health.items() if status != "healthy"]
        if unhealthy_deps:
            return "degraded"
        
        # Check system resources
        if system_health.get("cpu_percent", 0) > 90 or system_health.get("memory_percent", 0) > 90:
            return "degraded"
        
        return "healthy"

# FastAPI Health Check Endpoints
app = FastAPI(title="Health Check Service")

@app.get("/health")
async def health_check():
    """Basic health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

@app.get("/health/detailed")
async def detailed_health_check():
    """Detailed health check endpoint"""
    health_checker = HealthChecker(
        service_name="user-service",
        dependencies=["product-service", "order-service", "payment-service"]
    )
    
    result = await health_checker.check_health()
    
    if result.status == "healthy":
        return result.__dict__
    else:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=result.__dict__
        )

@app.get("/health/ready")
async def readiness_check():
    """Readiness check endpoint"""
    # Check if service is ready to accept traffic
    health_checker = HealthChecker("user-service")
    result = await health_checker.check_health()
    
    if result.status in ["healthy", "degraded"]:
        return {"status": "ready"}
    else:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={"status": "not_ready"}
        )

@app.get("/health/live")
async def liveness_check():
    """Liveness check endpoint"""
    # Check if service is alive (not crashed)
    return {"status": "alive", "timestamp": datetime.utcnow().isoformat()}
```

## Task 2: Metrics Collection

### Metrics Collection System

#### 1. Prometheus Metrics
**Strategy**: Collect comprehensive metrics for monitoring
**Implementation**:

```python
# Prometheus Metrics Implementation
from prometheus_client import Counter, Histogram, Gauge, Summary, start_http_server
import time
from functools import wraps

# Define metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')
DATABASE_CONNECTIONS = Gauge('database_connections', 'Number of database connections')
CACHE_HITS = Counter('cache_hits_total', 'Total cache hits', ['cache_type'])
CACHE_MISSES = Counter('cache_misses_total', 'Total cache misses', ['cache_type'])
BUSINESS_METRICS = Counter('business_events_total', 'Total business events', ['event_type'])

class MetricsCollector:
    def __init__(self, service_name: str):
        self.service_name = service_name
        self.start_time = time.time()
    
    def record_request(self, method: str, endpoint: str, status_code: int, duration: float):
        """Record HTTP request metrics"""
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=status_code).inc()
        REQUEST_DURATION.labels(method=method, endpoint=endpoint).observe(duration)
    
    def record_business_event(self, event_type: str, count: int = 1):
        """Record business metrics"""
        BUSINESS_METRICS.labels(event_type=event_type).inc(count)
    
    def record_cache_operation(self, cache_type: str, hit: bool):
        """Record cache metrics"""
        if hit:
            CACHE_HITS.labels(cache_type=cache_type).inc()
        else:
            CACHE_MISSES.labels(cache_type=cache_type).inc()
    
    def update_active_connections(self, count: int):
        """Update active connections gauge"""
        ACTIVE_CONNECTIONS.set(count)
    
    def update_database_connections(self, count: int):
        """Update database connections gauge"""
        DATABASE_CONNECTIONS.set(count)

# Metrics Decorator
def track_metrics(func):
    """Decorator to track function metrics"""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = await func(*args, **kwargs)
            duration = time.time() - start_time
            
            # Record success metrics
            metrics_collector.record_request(
                method="GET",  # This would be dynamic
                endpoint=func.__name__,
                status_code=200,
                duration=duration
            )
            
            return result
        except Exception as e:
            duration = time.time() - start_time
            
            # Record error metrics
            metrics_collector.record_request(
                method="GET",
                endpoint=func.__name__,
                status_code=500,
                duration=duration
            )
            
            raise e
    
    return wrapper

# Service with Metrics
class UserService:
    def __init__(self, metrics_collector: MetricsCollector):
        self.metrics_collector = metrics_collector
    
    @track_metrics
    async def get_user(self, user_id: str):
        """Get user with metrics tracking"""
        # Simulate database call
        await asyncio.sleep(0.1)
        
        # Record business event
        self.metrics_collector.record_business_event("user_retrieved")
        
        return {"user_id": user_id, "name": "John Doe"}
    
    @track_metrics
    async def create_user(self, user_data: dict):
        """Create user with metrics tracking"""
        # Simulate database call
        await asyncio.sleep(0.2)
        
        # Record business event
        self.metrics_collector.record_business_event("user_created")
        
        return {"user_id": "123", "status": "created"}

# Initialize metrics collector
metrics_collector = MetricsCollector("user-service")

# Start Prometheus metrics server
start_http_server(8000)
```

#### 2. Custom Metrics Dashboard
**Strategy**: Create custom metrics for business insights
**Implementation**:

```python
# Custom Metrics Dashboard
from prometheus_client import Gauge, Counter, Histogram
import json

# Business Metrics
ORDERS_CREATED = Counter('orders_created_total', 'Total orders created')
ORDERS_COMPLETED = Counter('orders_completed_total', 'Total orders completed')
ORDERS_CANCELLED = Counter('orders_cancelled_total', 'Total orders cancelled')
REVENUE_TOTAL = Counter('revenue_total', 'Total revenue', ['currency'])
CUSTOMER_REGISTRATIONS = Counter('customer_registrations_total', 'Total customer registrations')
PRODUCT_VIEWS = Counter('product_views_total', 'Total product views', ['product_id'])
CART_ABANDONMENT = Counter('cart_abandonment_total', 'Total cart abandonments')

# Performance Metrics
API_RESPONSE_TIME = Histogram('api_response_time_seconds', 'API response time', ['endpoint'])
DATABASE_QUERY_TIME = Histogram('database_query_time_seconds', 'Database query time', ['query_type'])
CACHE_HIT_RATIO = Gauge('cache_hit_ratio', 'Cache hit ratio', ['cache_type'])

# System Metrics
MEMORY_USAGE = Gauge('memory_usage_bytes', 'Memory usage in bytes')
CPU_USAGE = Gauge('cpu_usage_percent', 'CPU usage percentage')
DISK_USAGE = Gauge('disk_usage_bytes', 'Disk usage in bytes')

class BusinessMetricsCollector:
    def __init__(self):
        self.metrics = {
            'orders_created': ORDERS_CREATED,
            'orders_completed': ORDERS_COMPLETED,
            'orders_cancelled': ORDERS_CANCELLED,
            'revenue_total': REVENUE_TOTAL,
            'customer_registrations': CUSTOMER_REGISTRATIONS,
            'product_views': PRODUCT_VIEWS,
            'cart_abandonment': CART_ABANDONMENT
        }
    
    def record_order_created(self, order_id: str, amount: float, currency: str = "USD"):
        """Record order creation"""
        ORDERS_CREATED.inc()
        REVENUE_TOTAL.labels(currency=currency).inc(amount)
    
    def record_order_completed(self, order_id: str):
        """Record order completion"""
        ORDERS_COMPLETED.inc()
    
    def record_order_cancelled(self, order_id: str):
        """Record order cancellation"""
        ORDERS_CANCELLED.inc()
    
    def record_customer_registration(self, customer_id: str):
        """Record customer registration"""
        CUSTOMER_REGISTRATIONS.inc()
    
    def record_product_view(self, product_id: str):
        """Record product view"""
        PRODUCT_VIEWS.labels(product_id=product_id).inc()
    
    def record_cart_abandonment(self, customer_id: str):
        """Record cart abandonment"""
        CART_ABANDONMENT.inc()

# Usage in services
class OrderService:
    def __init__(self, metrics_collector: BusinessMetricsCollector):
        self.metrics_collector = metrics_collector
    
    async def create_order(self, order_data: dict):
        """Create order with metrics"""
        order_id = "order_123"
        amount = order_data.get("total_amount", 0)
        
        # Create order logic here
        await self._create_order_in_db(order_data)
        
        # Record metrics
        self.metrics_collector.record_order_created(order_id, amount)
        
        return {"order_id": order_id, "status": "created"}
    
    async def complete_order(self, order_id: str):
        """Complete order with metrics"""
        # Complete order logic here
        await self._complete_order_in_db(order_id)
        
        # Record metrics
        self.metrics_collector.record_order_completed(order_id)
        
        return {"order_id": order_id, "status": "completed"}
```

## Task 3: Distributed Tracing

### Distributed Tracing Implementation

#### 1. OpenTelemetry Integration
**Strategy**: Implement distributed tracing across all services
**Implementation**:

```python
# Distributed Tracing Implementation
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
import requests

# Initialize tracing
def init_tracing(service_name: str, jaeger_endpoint: str):
    """Initialize OpenTelemetry tracing"""
    trace.set_tracer_provider(TracerProvider())
    tracer = trace.get_tracer(__name__)
    
    # Create Jaeger exporter
    jaeger_exporter = JaegerExporter(
        agent_host_name="localhost",
        agent_port=14268,
    )
    
    # Create span processor
    span_processor = BatchSpanProcessor(jaeger_exporter)
    trace.get_tracer_provider().add_span_processor(span_processor)
    
    # Instrument FastAPI
    FastAPIInstrumentor.instrument_app(app, tracer_provider=trace.get_tracer_provider())
    
    # Instrument requests
    RequestsInstrumentor().instrument()
    
    # Instrument SQLAlchemy
    SQLAlchemyInstrumentor().instrument()
    
    return tracer

# Service with Tracing
class UserService:
    def __init__(self, tracer):
        self.tracer = tracer
    
    async def get_user(self, user_id: str):
        """Get user with tracing"""
        with self.tracer.start_as_current_span("get_user") as span:
            span.set_attribute("user_id", user_id)
            span.set_attribute("service", "user-service")
            
            try:
                # Simulate database call
                with self.tracer.start_as_current_span("database_query") as db_span:
                    db_span.set_attribute("query", "SELECT * FROM users WHERE id = ?")
                    db_span.set_attribute("user_id", user_id)
                    
                    # Simulate database delay
                    await asyncio.sleep(0.1)
                    
                    user_data = {"user_id": user_id, "name": "John Doe"}
                    db_span.set_attribute("result_count", 1)
                
                # Simulate external API call
                with self.tracer.start_as_current_span("external_api_call") as api_span:
                    api_span.set_attribute("api", "profile-service")
                    api_span.set_attribute("endpoint", "/profile")
                    
                    # Simulate API call
                    await asyncio.sleep(0.05)
                    
                    profile_data = {"avatar": "avatar.jpg", "bio": "Software Engineer"}
                    api_span.set_attribute("status_code", 200)
                
                # Combine results
                result = {**user_data, **profile_data}
                span.set_attribute("result_size", len(str(result)))
                
                return result
            
            except Exception as e:
                span.set_attribute("error", True)
                span.set_attribute("error_message", str(e))
                raise e

# Cross-service tracing
class OrderService:
    def __init__(self, tracer, user_service_client, product_service_client):
        self.tracer = tracer
        self.user_service_client = user_service_client
        self.product_service_client = product_service_client
    
    async def create_order(self, customer_id: str, items: list):
        """Create order with cross-service tracing"""
        with self.tracer.start_as_current_span("create_order") as span:
            span.set_attribute("customer_id", customer_id)
            span.set_attribute("item_count", len(items))
            span.set_attribute("service", "order-service")
            
            try:
                # Validate customer
                with self.tracer.start_as_current_span("validate_customer") as customer_span:
                    customer_span.set_attribute("customer_id", customer_id)
                    
                    customer = await self.user_service_client.get_user(customer_id)
                    customer_span.set_attribute("customer_name", customer.get("name"))
                
                # Validate products
                with self.tracer.start_as_current_span("validate_products") as product_span:
                    product_span.set_attribute("product_count", len(items))
                    
                    for item in items:
                        product = await self.product_service_client.get_product(item["product_id"])
                        product_span.set_attribute(f"product_{item['product_id']}_name", product.get("name"))
                
                # Create order
                with self.tracer.start_as_current_span("create_order_in_db") as db_span:
                    order_id = "order_123"
                    total_amount = sum(item["quantity"] * item["price"] for item in items)
                    
                    db_span.set_attribute("order_id", order_id)
                    db_span.set_attribute("total_amount", total_amount)
                    
                    # Simulate database operation
                    await asyncio.sleep(0.1)
                
                span.set_attribute("order_id", order_id)
                span.set_attribute("total_amount", total_amount)
                
                return {"order_id": order_id, "status": "created", "total_amount": total_amount}
            
            except Exception as e:
                span.set_attribute("error", True)
                span.set_attribute("error_message", str(e))
                raise e
```

## Task 4: Structured Logging

### Structured Logging Implementation

#### 1. Logging Configuration
**Strategy**: Implement structured logging across all services
**Implementation**:

```python
# Structured Logging Implementation
import logging
import json
import sys
from datetime import datetime
from typing import Dict, Any
import traceback

class StructuredFormatter(logging.Formatter):
    """Custom formatter for structured logging"""
    
    def format(self, record):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        
        # Add extra fields if present
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        if hasattr(record, 'service'):
            log_entry['service'] = record.service
        if hasattr(record, 'operation'):
            log_entry['operation'] = record.operation
        if hasattr(record, 'duration'):
            log_entry['duration'] = record.duration
        if hasattr(record, 'status_code'):
            log_entry['status_code'] = record.status_code
        
        # Add exception info if present
        if record.exc_info:
            log_entry['exception'] = {
                'type': record.exc_info[0].__name__,
                'message': str(record.exc_info[1]),
                'traceback': traceback.format_exception(*record.exc_info)
            }
        
        return json.dumps(log_entry)

class StructuredLogger:
    def __init__(self, name: str, service: str):
        self.logger = logging.getLogger(name)
        self.service = service
        self._setup_logger()
    
    def _setup_logger(self):
        """Setup logger with structured formatting"""
        self.logger.setLevel(logging.INFO)
        
        # Remove existing handlers
        for handler in self.logger.handlers[:]:
            self.logger.removeHandler(handler)
        
        # Create console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(StructuredFormatter())
        self.logger.addHandler(console_handler)
        
        # Prevent propagation to root logger
        self.logger.propagate = False
    
    def info(self, message: str, **kwargs):
        """Log info message with extra fields"""
        self._log(logging.INFO, message, **kwargs)
    
    def warning(self, message: str, **kwargs):
        """Log warning message with extra fields"""
        self._log(logging.WARNING, message, **kwargs)
    
    def error(self, message: str, **kwargs):
        """Log error message with extra fields"""
        self._log(logging.ERROR, message, **kwargs)
    
    def debug(self, message: str, **kwargs):
        """Log debug message with extra fields"""
        self._log(logging.DEBUG, message, **kwargs)
    
    def _log(self, level: int, message: str, **kwargs):
        """Log message with extra fields"""
        extra = {
            'service': self.service,
            **kwargs
        }
        self.logger.log(level, message, extra=extra)

# Service with Structured Logging
class UserService:
    def __init__(self):
        self.logger = StructuredLogger("user-service", "user-service")
    
    async def get_user(self, user_id: str, request_id: str = None):
        """Get user with structured logging"""
        start_time = datetime.utcnow()
        
        self.logger.info(
            "Getting user",
            user_id=user_id,
            request_id=request_id,
            operation="get_user"
        )
        
        try:
            # Simulate database call
            await asyncio.sleep(0.1)
            
            user_data = {"user_id": user_id, "name": "John Doe"}
            
            duration = (datetime.utcnow() - start_time).total_seconds()
            
            self.logger.info(
                "User retrieved successfully",
                user_id=user_id,
                request_id=request_id,
                operation="get_user",
                duration=duration,
                status_code=200
            )
            
            return user_data
        
        except Exception as e:
            duration = (datetime.utcnow() - start_time).total_seconds()
            
            self.logger.error(
                "Failed to get user",
                user_id=user_id,
                request_id=request_id,
                operation="get_user",
                duration=duration,
                status_code=500,
                error=str(e)
            )
            
            raise e
    
    async def create_user(self, user_data: dict, request_id: str = None):
        """Create user with structured logging"""
        start_time = datetime.utcnow()
        
        self.logger.info(
            "Creating user",
            request_id=request_id,
            operation="create_user",
            user_email=user_data.get("email")
        )
        
        try:
            # Simulate database call
            await asyncio.sleep(0.2)
            
            new_user_id = "user_123"
            duration = (datetime.utcnow() - start_time).total_seconds()
            
            self.logger.info(
                "User created successfully",
                user_id=new_user_id,
                request_id=request_id,
                operation="create_user",
                duration=duration,
                status_code=201
            )
            
            return {"user_id": new_user_id, "status": "created"}
        
        except Exception as e:
            duration = (datetime.utcnow() - start_time).total_seconds()
            
            self.logger.error(
                "Failed to create user",
                request_id=request_id,
                operation="create_user",
                duration=duration,
                status_code=500,
                error=str(e)
            )
            
            raise e
```

## Best Practices Applied

### Health Checks
1. **Comprehensive Checks**: Check all aspects of service health
2. **Dependency Monitoring**: Monitor external dependencies
3. **Resource Monitoring**: Monitor system resources
4. **Graceful Degradation**: Handle degraded states gracefully
5. **Fast Response**: Ensure health checks are fast

### Metrics Collection
1. **Business Metrics**: Track business-relevant metrics
2. **Performance Metrics**: Monitor performance indicators
3. **System Metrics**: Track system resource usage
4. **Custom Metrics**: Create custom metrics for specific needs
5. **Metric Aggregation**: Aggregate metrics appropriately

### Distributed Tracing
1. **End-to-End Tracing**: Trace requests across all services
2. **Context Propagation**: Propagate trace context
3. **Span Relationships**: Define proper span relationships
4. **Error Tracking**: Track errors in traces
5. **Performance Analysis**: Use traces for performance analysis

### Structured Logging
1. **Consistent Format**: Use consistent log format
2. **Contextual Information**: Include relevant context
3. **Correlation IDs**: Use correlation IDs for request tracking
4. **Log Levels**: Use appropriate log levels
5. **Error Details**: Include detailed error information

## Lessons Learned

### Key Insights
1. **Observability**: Comprehensive observability is crucial for microservices
2. **Monitoring**: Monitor all aspects of the system
3. **Tracing**: Distributed tracing helps with debugging
4. **Logging**: Structured logging improves debugging
5. **Alerting**: Set up appropriate alerts

### Common Pitfalls
1. **Poor Health Checks**: Don't implement poor health checks
2. **No Metrics**: Don't skip metrics collection
3. **No Tracing**: Don't skip distributed tracing
4. **Poor Logging**: Don't use unstructured logging
5. **No Alerting**: Don't skip alerting setup

### Recommendations
1. **Start Early**: Implement observability from the start
2. **Comprehensive Coverage**: Cover all aspects of observability
3. **Automation**: Automate monitoring and alerting
4. **Documentation**: Document monitoring and alerting procedures
5. **Regular Review**: Regularly review and improve observability

## Next Steps

1. **Implementation**: Implement comprehensive observability
2. **Monitoring**: Set up monitoring dashboards
3. **Alerting**: Configure alerting rules
4. **Testing**: Test observability systems
5. **Optimization**: Optimize observability performance
