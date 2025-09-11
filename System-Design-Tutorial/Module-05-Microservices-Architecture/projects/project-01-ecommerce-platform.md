# Project 1: E-commerce Microservices Platform

## Project Overview

Build a comprehensive e-commerce platform using microservices architecture on AWS. The platform should handle user management, product catalog, order processing, payment processing, and real-time notifications.

## Requirements

### Functional Requirements

#### User Management
- User registration and authentication
- User profile management
- Role-based access control (Admin, Customer, Seller)
- Password reset and email verification

#### Product Catalog
- Product CRUD operations
- Category management
- Inventory tracking
- Product search and filtering
- Product reviews and ratings

#### Order Processing
- Shopping cart management
- Order creation and management
- Order status tracking
- Order history
- Order cancellation and returns

#### Payment Processing
- Multiple payment methods (Credit Card, PayPal, Stripe)
- Payment gateway integration
- Payment verification
- Refund processing
- Payment history

#### Notifications
- Email notifications (Order confirmation, shipping updates)
- SMS notifications (Order status updates)
- Push notifications (Mobile app)
- In-app notifications

### Non-Functional Requirements

#### Performance
- Response time < 200ms for 95% of requests
- Support 10,000 concurrent users
- Handle 1 million products
- Process 1,000 orders per minute

#### Scalability
- Horizontal scaling of all services
- Auto-scaling based on load
- Database scaling and sharding
- CDN for static content

#### Availability
- 99.9% uptime
- Multi-region deployment
- Disaster recovery
- Health monitoring

#### Security
- HTTPS for all communications
- JWT-based authentication
- API rate limiting
- Data encryption at rest and in transit
- PCI DSS compliance for payment data

## Architecture

### Service Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │   Load Balancer │    │   CDN (CloudFront) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Microservices                        │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │User Service │ │Product Svc  │ │Order Service│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Payment Svc  │ │Notification │ │Analytics Svc│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │   RDS       │ │  DynamoDB   │ │   ElastiCache│     │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Backend Services
- **Language**: Python (FastAPI) or Node.js (Express)
- **Framework**: FastAPI or Express.js
- **Database**: PostgreSQL (RDS) for transactional data
- **NoSQL**: DynamoDB for high-throughput data
- **Cache**: Redis (ElastiCache) for caching
- **Message Queue**: SQS for asynchronous processing

#### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Amazon ECS or EKS
- **API Gateway**: AWS API Gateway
- **Load Balancer**: Application Load Balancer
- **CDN**: CloudFront
- **Monitoring**: CloudWatch, X-Ray

#### External Services
- **Payment**: Stripe, PayPal APIs
- **Email**: Amazon SES
- **SMS**: Amazon SNS
- **Search**: Amazon OpenSearch

## Implementation

### Phase 1: Foundation Setup

#### 1.1 Infrastructure Setup
```bash
# Create VPC and networking
aws ec2 create-vpc --cidr-block 10.0.0.0/16
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.1.0/24

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier ecommerce-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password password123

# Create ElastiCache cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id ecommerce-cache \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

#### 1.2 Service Structure
```
ecommerce-platform/
├── services/
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   ├── payment-service/
│   └── notification-service/
├── infrastructure/
│   ├── terraform/
│   └── docker-compose.yml
├── shared/
│   ├── models/
│   ├── utils/
│   └── middleware/
└── docs/
    ├── api/
    └── architecture/
```

### Phase 2: Core Services Implementation

#### 2.1 User Service
```python
# user-service/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from .database import get_db
from .models import User
from .schemas import UserCreate, UserResponse

app = FastAPI(title="User Service", version="1.0.0")

@app.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # User creation logic
    pass

@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    # User retrieval logic
    pass

@app.put("/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user: UserCreate, db: Session = Depends(get_db)):
    # User update logic
    pass
```

#### 2.2 Product Service
```python
# product-service/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from .database import get_db
from .models import Product, Category
from .schemas import ProductCreate, ProductResponse

app = FastAPI(title="Product Service", version="1.0.0")

@app.post("/products", response_model=ProductResponse)
def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    # Product creation logic
    pass

@app.get("/products", response_model=List[ProductResponse])
def get_products(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # Product listing logic
    pass

@app.get("/products/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)):
    # Product retrieval logic
    pass
```

### Phase 3: Integration and Communication

#### 3.1 API Gateway Configuration
```yaml
# api-gateway-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-gateway-config
data:
  routes.yaml: |
    routes:
      - path: /api/users
        service: user-service
        methods: [GET, POST, PUT, DELETE]
      - path: /api/products
        service: product-service
        methods: [GET, POST, PUT, DELETE]
      - path: /api/orders
        service: order-service
        methods: [GET, POST, PUT, DELETE]
```

#### 3.2 Service Communication
```python
# shared/http_client.py
import httpx
from typing import Optional

class ServiceClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.client = httpx.AsyncClient()
    
    async def get(self, endpoint: str, params: Optional[dict] = None):
        response = await self.client.get(f"{self.base_url}{endpoint}", params=params)
        return response.json()
    
    async def post(self, endpoint: str, data: dict):
        response = await self.client.post(f"{self.base_url}{endpoint}", json=data)
        return response.json()
```

### Phase 4: Data Management

#### 4.1 Database Schema
```sql
-- User Service Database
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Service Database
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    inventory_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4.2 Event Sourcing
```python
# shared/events.py
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict

@dataclass
class DomainEvent:
    event_id: str
    event_type: str
    aggregate_id: str
    event_data: Dict[str, Any]
    timestamp: datetime
    version: int

class EventStore:
    def __init__(self):
        self.events = []
    
    def append(self, event: DomainEvent):
        self.events.append(event)
    
    def get_events(self, aggregate_id: str):
        return [e for e in self.events if e.aggregate_id == aggregate_id]
```

### Phase 5: Monitoring and Observability

#### 5.1 Health Checks
```python
# shared/health.py
from fastapi import FastAPI
from sqlalchemy.orm import Session
from .database import get_db

@app.get("/health")
def health_check(db: Session = Depends(get_db)):
    try:
        # Check database connection
        db.execute("SELECT 1")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
```

#### 5.2 Metrics Collection
```python
# shared/metrics.py
from prometheus_client import Counter, Histogram, Gauge
import time

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Number of active connections')

def track_request(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
            return result
        finally:
            REQUEST_DURATION.observe(time.time() - start_time)
    return wrapper
```

## Testing

### Unit Tests
```python
# tests/test_user_service.py
import pytest
from fastapi.testclient import TestClient
from user_service.main import app

client = TestClient(app)

def test_create_user():
    response = client.post("/users", json={
        "email": "test@example.com",
        "password": "password123",
        "first_name": "John",
        "last_name": "Doe"
    })
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"

def test_get_user():
    response = client.get("/users/1")
    assert response.status_code == 200
    assert "email" in response.json()
```

### Integration Tests
```python
# tests/test_integration.py
import pytest
from fastapi.testclient import TestClient
from order_service.main import app

client = TestClient(app)

def test_create_order():
    # Create user
    user_response = client.post("/users", json={"email": "test@example.com"})
    user_id = user_response.json()["id"]
    
    # Create product
    product_response = client.post("/products", json={"name": "Test Product", "price": 10.00})
    product_id = product_response.json()["id"]
    
    # Create order
    order_response = client.post("/orders", json={
        "user_id": user_id,
        "items": [{"product_id": product_id, "quantity": 2}]
    })
    assert order_response.status_code == 201
```

## Deployment

### Docker Configuration
```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Kubernetes Deployment
```yaml
# k8s/user-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: ecommerce/user-service:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
```

## Monitoring

### CloudWatch Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "user-service"],
          ["AWS/ECS", "MemoryUtilization", "ServiceName", "user-service"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-west-2",
        "title": "Service Performance"
      }
    }
  ]
}
```

## Documentation

### API Documentation
```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: E-commerce Platform API
  version: 1.0.0
  description: Microservices-based e-commerce platform

paths:
  /api/users:
    get:
      summary: Get all users
      responses:
        '200':
          description: List of users
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserCreate'
```

## Solution

Complete solution available in the `solutions/` directory including:
- Full source code for all services
- Infrastructure as code (Terraform)
- Kubernetes manifests
- Docker configurations
- Test suites
- API documentation
- Monitoring dashboards

## Next Steps

After completing this project:
1. **Review the Solution**: Compare your implementation with the provided solution
2. **Identify Improvements**: Look for areas to optimize and improve
3. **Apply Learnings**: Use the knowledge in your own projects
4. **Move to Project 2**: Continue with the next project
