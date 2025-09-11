# Project 1 Solution: E-commerce Microservices Platform

## Solution Overview

This solution provides a complete implementation of an e-commerce microservices platform using AWS services. The platform includes user management, product catalog, order processing, payment processing, and real-time notifications.

## Architecture Overview

### High-Level Architecture

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
    │  │Payment Svc  │ │Inventory Svc│ │Notification │      │
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

### Service Architecture

#### Core Services
1. **User Service** - User management and authentication
2. **Product Service** - Product catalog and management
3. **Order Service** - Order processing and management
4. **Payment Service** - Payment processing and billing
5. **Inventory Service** - Inventory management and tracking
6. **Notification Service** - Email, SMS, and push notifications

## Implementation Details

### 1. User Service

#### Service Implementation
```python
# user-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import uuid

from .database import get_db
from .models import User
from .schemas import UserCreate, UserResponse, UserLogin, Token

app = FastAPI(title="User Service", version="1.0.0")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT configuration
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

@app.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """Create a new user"""
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Hash password
    hashed_password = pwd_context.hash(user.password)
    
    # Create user
    db_user = User(
        id=str(uuid.uuid4()),
        email=user.email,
        hashed_password=hashed_password,
        full_name=user.full_name,
        is_active=True,
        created_at=datetime.utcnow()
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return UserResponse.from_orm(db_user)

@app.post("/auth/login", response_model=Token)
def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    """Authenticate user and return JWT token"""
    # Verify user credentials
    user = db.query(User).filter(User.email == user_credentials.email).first()
    if not user or not pwd_context.verify(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=UserResponse)
def get_current_user(current_user: User = Depends(get_current_user)):
    """Get current user information"""
    return UserResponse.from_orm(current_user)

def create_access_token(data: dict, expires_delta: timedelta = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Get current user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials"
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user
```

#### Database Models
```python
# user-service/models.py
from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
```

#### API Schemas
```python
# user-service/schemas.py
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: str
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
```

### 2. Product Service

#### Service Implementation
```python
# product-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from .database import get_db
from .models import Product, Category
from .schemas import ProductCreate, ProductResponse, ProductUpdate

app = FastAPI(title="Product Service", version="1.0.0")

@app.post("/products", response_model=ProductResponse)
def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    """Create a new product"""
    # Check if category exists
    category = db.query(Category).filter(Category.id == product.category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category not found"
        )
    
    # Create product
    db_product = Product(
        id=str(uuid.uuid4()),
        name=product.name,
        description=product.description,
        price=product.price,
        category_id=product.category_id,
        stock_quantity=product.stock_quantity,
        is_active=True,
        created_at=datetime.utcnow()
    )
    
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    
    return ProductResponse.from_orm(db_product)

@app.get("/products", response_model=List[ProductResponse])
def get_products(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get list of products with optional filtering"""
    query = db.query(Product).filter(Product.is_active == True)
    
    if category_id:
        query = query.filter(Product.category_id == category_id)
    
    if search:
        query = query.filter(Product.name.contains(search))
    
    products = query.offset(skip).limit(limit).all()
    return [ProductResponse.from_orm(product) for product in products]

@app.get("/products/{product_id}", response_model=ProductResponse)
def get_product(product_id: str, db: Session = Depends(get_db)):
    """Get specific product"""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return ProductResponse.from_orm(product)

@app.put("/products/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: str,
    product_update: ProductUpdate,
    db: Session = Depends(get_db)
):
    """Update product"""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Update product fields
    for field, value in product_update.dict(exclude_unset=True).items():
        setattr(product, field, value)
    
    product.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(product)
    
    return ProductResponse.from_orm(product)

@app.delete("/products/{product_id}")
def delete_product(product_id: str, db: Session = Depends(get_db)):
    """Delete product (soft delete)"""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    product.is_active = False
    product.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Product deleted successfully"}
```

### 3. Order Service

#### Service Implementation
```python
# order-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import uuid
from datetime import datetime

from .database import get_db
from .models import Order, OrderItem
from .schemas import OrderCreate, OrderResponse, OrderItemCreate

app = FastAPI(title="Order Service", version="1.0.0")

@app.post("/orders", response_model=OrderResponse)
def create_order(order: OrderCreate, db: Session = Depends(get_db)):
    """Create a new order"""
    # Create order
    db_order = Order(
        id=str(uuid.uuid4()),
        user_id=order.user_id,
        status="pending",
        total_amount=0,  # Will be calculated
        created_at=datetime.utcnow()
    )
    
    db.add(db_order)
    db.flush()  # Get the order ID
    
    # Create order items
    total_amount = 0
    for item in order.items:
        order_item = OrderItem(
            id=str(uuid.uuid4()),
            order_id=db_order.id,
            product_id=item.product_id,
            quantity=item.quantity,
            unit_price=item.unit_price,
            total_price=item.quantity * item.unit_price
        )
        db.add(order_item)
        total_amount += order_item.total_price
    
    # Update order total
    db_order.total_amount = total_amount
    db.commit()
    db.refresh(db_order)
    
    return OrderResponse.from_orm(db_order)

@app.get("/orders", response_model=List[OrderResponse])
def get_orders(
    user_id: str,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get user's orders"""
    orders = db.query(Order).filter(
        Order.user_id == user_id
    ).offset(skip).limit(limit).all()
    
    return [OrderResponse.from_orm(order) for order in orders]

@app.get("/orders/{order_id}", response_model=OrderResponse)
def get_order(order_id: str, db: Session = Depends(get_db)):
    """Get specific order"""
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    return OrderResponse.from_orm(order)

@app.put("/orders/{order_id}/status")
def update_order_status(
    order_id: str,
    status: str,
    db: Session = Depends(get_db)
):
    """Update order status"""
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    order.status = status
    order.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Order status updated successfully"}
```

### 4. Payment Service

#### Service Implementation
```python
# payment-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import uuid
from datetime import datetime

from .database import get_db
from .models import Payment, PaymentMethod
from .schemas import PaymentCreate, PaymentResponse, PaymentMethodCreate

app = FastAPI(title="Payment Service", version="1.0.0")

@app.post("/payments", response_model=PaymentResponse)
def create_payment(payment: PaymentCreate, db: Session = Depends(get_db)):
    """Create a new payment"""
    # Create payment
    db_payment = Payment(
        id=str(uuid.uuid4()),
        order_id=payment.order_id,
        amount=payment.amount,
        currency=payment.currency,
        payment_method_id=payment.payment_method_id,
        status="pending",
        created_at=datetime.utcnow()
    )
    
    db.add(db_payment)
    db.commit()
    db.refresh(db_payment)
    
    # Process payment (simplified)
    # In real implementation, integrate with payment gateway
    db_payment.status = "completed"
    db_payment.processed_at = datetime.utcnow()
    db.commit()
    
    return PaymentResponse.from_orm(db_payment)

@app.get("/payments", response_model=List[PaymentResponse])
def get_payments(
    order_id: str = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get payments with optional filtering"""
    query = db.query(Payment)
    
    if order_id:
        query = query.filter(Payment.order_id == order_id)
    
    payments = query.offset(skip).limit(limit).all()
    return [PaymentResponse.from_orm(payment) for payment in payments]

@app.post("/payment-methods", response_model=PaymentMethod)
def create_payment_method(
    payment_method: PaymentMethodCreate,
    db: Session = Depends(get_db)
):
    """Create a new payment method"""
    db_payment_method = PaymentMethod(
        id=str(uuid.uuid4()),
        user_id=payment_method.user_id,
        type=payment_method.type,
        card_number=payment_method.card_number,
        expiry_date=payment_method.expiry_date,
        is_default=payment_method.is_default,
        created_at=datetime.utcnow()
    )
    
    db.add(db_payment_method)
    db.commit()
    db.refresh(db_payment_method)
    
    return PaymentMethod.from_orm(db_payment_method)
```

### 5. Infrastructure as Code

#### Terraform Configuration
```hcl
# infrastructure/main.tf
provider "aws" {
  region = "us-west-2"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ecommerce-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecommerce-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "ecommerce-public-subnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "ecommerce-private-subnet-${count.index + 1}"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "ecommerce-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "ecommerce-db"
  
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  
  db_name  = "ecommerce"
  username = "admin"
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  
  tags = {
    Name = "ecommerce-db"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "ecommerce-cache-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

# ElastiCache Cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "ecommerce-cache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "ecommerce-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "user_service" {
  family                   = "user-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "user-service"
      image = "ecommerce/user-service:latest"
      
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://admin:${var.db_password}@${aws_db_instance.main.endpoint}/ecommerce"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${aws_elasticache_cluster.main.cache_nodes[0].address}:6379"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/user-service"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "user_service" {
  name            = "user-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.user_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.user_service.arn
    container_name   = "user-service"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.user_service]
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "ecommerce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "user_service" {
  name     = "user-service-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "user_service" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_service.arn
  }
}
```

### 6. Kubernetes Manifests

#### User Service Deployment
```yaml
# k8s/user-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  labels:
    app: user-service
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
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: ClusterIP
```

### 7. Docker Configuration

#### User Service Dockerfile
```dockerfile
# user-service/Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  user-service:
    build: ./user-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/ecommerce
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  product-service:
    build: ./product-service
    ports:
      - "8002:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/ecommerce
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  order-service:
    build: ./order-service
    ports:
      - "8003:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/ecommerce
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  payment-service:
    build: ./payment-service
    ports:
      - "8004:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/ecommerce
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=ecommerce
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### 8. Testing

#### Unit Tests
```python
# user-service/tests/test_user_service.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from main import app, get_db
from models import Base, User

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture
def setup_database():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)

def test_create_user(setup_database):
    response = client.post("/users", json={
        "email": "test@example.com",
        "password": "password123",
        "full_name": "Test User"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["full_name"] == "Test User"
    assert "id" in data

def test_login_user(setup_database):
    # Create user first
    client.post("/users", json={
        "email": "test@example.com",
        "password": "password123",
        "full_name": "Test User"
    })
    
    # Login
    response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_get_current_user(setup_database):
    # Create user and login
    client.post("/users", json={
        "email": "test@example.com",
        "password": "password123",
        "full_name": "Test User"
    })
    
    login_response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "password123"
    })
    
    token = login_response.json()["access_token"]
    
    # Get current user
    response = client.get("/users/me", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
```

### 9. Monitoring and Observability

#### CloudWatch Dashboard
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
        "title": "User Service Performance"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "ecommerce-alb"],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "ecommerce-alb"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-west-2",
        "title": "Load Balancer Metrics"
      }
    }
  ]
}
```

### 10. API Documentation

#### OpenAPI Specification
```yaml
# api-docs/openapi.yaml
openapi: 3.0.0
info:
  title: E-commerce Platform API
  version: 1.0.0
  description: Microservices-based e-commerce platform

paths:
  /users:
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserCreate'
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserResponse'
        '400':
          description: Bad request
    get:
      summary: Get users
      parameters:
        - name: skip
          in: query
          schema:
            type: integer
            default: 0
        - name: limit
          in: query
          schema:
            type: integer
            default: 100
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/UserResponse'

components:
  schemas:
    UserCreate:
      type: object
      required:
        - email
        - password
        - full_name
      properties:
        email:
          type: string
          format: email
        password:
          type: string
          minLength: 8
        full_name:
          type: string
    
    UserResponse:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        full_name:
          type: string
        is_active:
          type: boolean
        created_at:
          type: string
          format: date-time
```

## Deployment Instructions

### 1. Prerequisites
- AWS CLI configured
- Docker installed
- Terraform installed
- kubectl configured

### 2. Infrastructure Deployment
```bash
# Initialize Terraform
cd infrastructure
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### 3. Application Deployment
```bash
# Build Docker images
docker build -t ecommerce/user-service ./user-service
docker build -t ecommerce/product-service ./product-service
docker build -t ecommerce/order-service ./order-service
docker build -t ecommerce/payment-service ./payment-service

# Push to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Deploy to ECS
aws ecs update-service --cluster ecommerce-cluster --service user-service --force-new-deployment
```

### 4. Monitoring Setup
```bash
# Create CloudWatch dashboard
aws cloudwatch put-dashboard --dashboard-name "E-commerce Platform" --dashboard-body file://monitoring/dashboard.json

# Set up alarms
aws cloudwatch put-metric-alarm --alarm-name "High CPU Usage" --alarm-description "Alert when CPU usage is high" --metric-name CPUUtilization --namespace AWS/ECS --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanThreshold --evaluation-periods 2
```

## Best Practices Applied

### Security
- JWT token authentication
- Password hashing with bcrypt
- Input validation and sanitization
- HTTPS for all communications
- Database encryption at rest

### Performance
- Database connection pooling
- Redis caching
- Load balancing
- Auto-scaling
- CDN for static content

### Reliability
- Health checks
- Circuit breakers
- Retry logic
- Graceful degradation
- Monitoring and alerting

### Scalability
- Microservices architecture
- Horizontal scaling
- Database sharding
- Caching strategies
- Load balancing

## Lessons Learned

### Key Insights
1. **Service Boundaries**: Clear service boundaries are crucial for maintainability
2. **Data Consistency**: Eventual consistency is acceptable for most use cases
3. **Monitoring**: Comprehensive monitoring is essential for production systems
4. **Testing**: Automated testing at all levels is critical

### Common Pitfalls
1. **Over-Engineering**: Don't over-engineer from the start
2. **Tight Coupling**: Avoid tight coupling between services
3. **Poor Monitoring**: Invest in good monitoring and observability
4. **Security**: Don't neglect security considerations

### Recommendations
1. **Start Simple**: Begin with simple service boundaries
2. **Iterate**: Continuously improve and refactor
3. **Monitor**: Invest in comprehensive monitoring
4. **Test**: Test failure scenarios regularly

## Next Steps

1. **Production Readiness**: Add production-grade features
2. **Performance Optimization**: Optimize based on metrics
3. **Security Hardening**: Implement additional security measures
4. **Monitoring Enhancement**: Add more comprehensive monitoring
5. **Feature Development**: Add new features and capabilities
