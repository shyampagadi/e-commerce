# Exercise 6 Solution: Data Management Patterns

## Solution Overview

This solution demonstrates the implementation of data management patterns for microservices, including Database per Service, CQRS, Event Sourcing, and Saga Pattern for managing distributed transactions in an e-commerce platform.

## Task 1: Database per Service Implementation

### Service Database Design

#### 1. User Service Database
**Database Type**: PostgreSQL
**Schema Design**: Optimized for user management and authentication

```sql
-- User Service Database Schema
CREATE DATABASE user_service_db;

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    avatar_url VARCHAR(500),
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User addresses table
CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    address_type VARCHAR(20) DEFAULT 'home', -- home, work, billing
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_user_addresses_default ON user_addresses(user_id, is_default);
```

#### 2. Product Service Database
**Database Type**: PostgreSQL
**Schema Design**: Optimized for product catalog and search

```sql
-- Product Service Database Schema
CREATE DATABASE product_service_db;

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories(id),
    slug VARCHAR(100) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id UUID REFERENCES categories(id),
    brand VARCHAR(100),
    weight DECIMAL(8,2),
    dimensions JSONB, -- {length, width, height}
    attributes JSONB DEFAULT '{}', -- color, size, material, etc.
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product images table
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product reviews table
CREATE TABLE product_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- Reference to user in user service
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_product_images_product ON product_images(product_id);
CREATE INDEX idx_product_reviews_product ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_user ON product_reviews(user_id);
CREATE INDEX idx_product_reviews_rating ON product_reviews(rating);
```

#### 3. Order Service Database
**Database Type**: PostgreSQL
**Schema Design**: Optimized for order processing and tracking

```sql
-- Order Service Database Schema
CREATE DATABASE order_service_db;

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL, -- Reference to user in user service
    status VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, processing, shipped, delivered, cancelled
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address JSONB NOT NULL,
    billing_address JSONB,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending',
    shipping_method VARCHAR(50),
    tracking_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL, -- Reference to product in product service
    product_sku VARCHAR(100) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order status history table
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);
```

### Database per Service Implementation

```python
# Database per Service Implementation
from sqlalchemy import create_engine, Column, String, Integer, Float, Boolean, DateTime, Text, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# User Service Database
class UserServiceDatabase:
    def __init__(self):
        self.database_url = os.getenv("USER_SERVICE_DATABASE_URL")
        self.engine = create_engine(self.database_url)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)
        self.Base = declarative_base()
    
    def get_session(self):
        return self.SessionLocal()
    
    def create_tables(self):
        self.Base.metadata.create_all(bind=self.engine)

# Product Service Database
class ProductServiceDatabase:
    def __init__(self):
        self.database_url = os.getenv("PRODUCT_SERVICE_DATABASE_URL")
        self.engine = create_engine(self.database_url)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)
        self.Base = declarative_base()
    
    def get_session(self):
        return self.SessionLocal()
    
    def create_tables(self):
        self.Base.metadata.create_all(bind=self.engine)

# Order Service Database
class OrderServiceDatabase:
    def __init__(self):
        self.database_url = os.getenv("ORDER_SERVICE_DATABASE_URL")
        self.engine = create_engine(self.database_url)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)
        self.Base = declarative_base()
    
    def get_session(self):
        return self.SessionLocal()
    
    def create_tables(self):
        self.Base.metadata.create_all(bind=self.engine)

# Service-specific models
class UserServiceModels:
    def __init__(self, base):
        self.User = self._create_user_model(base)
        self.UserProfile = self._create_user_profile_model(base)
        self.UserAddress = self._create_user_address_model(base)
    
    def _create_user_model(self, base):
        class User(base):
            __tablename__ = "users"
            
            id = Column(String, primary_key=True)
            email = Column(String, unique=True, nullable=False)
            password_hash = Column(String, nullable=False)
            first_name = Column(String, nullable=False)
            last_name = Column(String, nullable=False)
            phone = Column(String)
            date_of_birth = Column(DateTime)
            is_active = Column(Boolean, default=True)
            email_verified = Column(Boolean, default=False)
            created_at = Column(DateTime)
            updated_at = Column(DateTime)
        
        return User
    
    def _create_user_profile_model(self, base):
        class UserProfile(base):
            __tablename__ = "user_profiles"
            
            id = Column(String, primary_key=True)
            user_id = Column(String, nullable=False)
            bio = Column(Text)
            avatar_url = Column(String)
            preferences = Column(JSON)
            created_at = Column(DateTime)
            updated_at = Column(DateTime)
        
        return UserProfile
    
    def _create_user_address_model(self, base):
        class UserAddress(base):
            __tablename__ = "user_addresses"
            
            id = Column(String, primary_key=True)
            user_id = Column(String, nullable=False)
            address_type = Column(String, default="home")
            street_address = Column(String, nullable=False)
            city = Column(String, nullable=False)
            state = Column(String, nullable=False)
            postal_code = Column(String, nullable=False)
            country = Column(String, nullable=False)
            is_default = Column(Boolean, default=False)
            created_at = Column(DateTime)
            updated_at = Column(DateTime)
        
        return UserAddress
```

## Task 2: CQRS Implementation

### CQRS Architecture Design

#### 1. Command Side (Write Model)
**Purpose**: Handle write operations and business logic
**Implementation**:

```python
# CQRS Command Side Implementation
from dataclasses import dataclass
from typing import List, Optional
from datetime import datetime
import uuid

# Command Models
@dataclass
class CreateProductCommand:
    name: str
    description: str
    price: float
    category_id: str
    stock_quantity: int

@dataclass
class UpdateProductCommand:
    product_id: str
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    stock_quantity: Optional[int] = None

@dataclass
class CreateOrderCommand:
    customer_id: str
    items: List[dict]
    shipping_address: dict

@dataclass
class ConfirmOrderCommand:
    order_id: str

# Command Handlers
class ProductCommandHandler:
    def __init__(self, product_repository, event_store):
        self._product_repository = product_repository
        self._event_store = event_store
    
    def handle_create_product(self, command: CreateProductCommand):
        """Handle create product command"""
        # Validate command
        if not command.name or len(command.name) < 3:
            raise ValueError("Product name must be at least 3 characters")
        
        if command.price <= 0:
            raise ValueError("Product price must be positive")
        
        # Create product aggregate
        product_id = str(uuid.uuid4())
        product = Product(
            id=product_id,
            name=command.name,
            description=command.description,
            price=command.price,
            category_id=command.category_id,
            stock_quantity=command.stock_quantity,
            is_active=True,
            created_at=datetime.utcnow()
        )
        
        # Save to write database
        self._product_repository.save(product)
        
        # Publish domain event
        event = ProductCreated(
            product_id=product_id,
            name=command.name,
            price=command.price,
            category_id=command.category_id
        )
        self._event_store.publish(event)
        
        return product_id
    
    def handle_update_product(self, command: UpdateProductCommand):
        """Handle update product command"""
        product = self._product_repository.get(command.product_id)
        if not product:
            raise ValueError("Product not found")
        
        # Update product
        if command.name:
            product.name = command.name
        if command.description:
            product.description = command.description
        if command.price:
            product.price = command.price
        if command.stock_quantity:
            product.stock_quantity = command.stock_quantity
        
        product.updated_at = datetime.utcnow()
        
        # Save to write database
        self._product_repository.save(product)
        
        # Publish domain event
        event = ProductUpdated(
            product_id=command.product_id,
            name=product.name,
            price=product.price
        )
        self._event_store.publish(event)

class OrderCommandHandler:
    def __init__(self, order_repository, inventory_service, payment_service, event_store):
        self._order_repository = order_repository
        self._inventory_service = inventory_service
        self._payment_service = payment_service
        self._event_store = event_store
    
    def handle_create_order(self, command: CreateOrderCommand):
        """Handle create order command"""
        # Validate command
        if not command.items:
            raise ValueError("Order must have at least one item")
        
        # Create order aggregate
        order_id = str(uuid.uuid4())
        order_number = f"ORD-{order_id[:8].upper()}"
        
        order = Order(
            id=order_id,
            order_number=order_number,
            customer_id=command.customer_id,
            status="pending",
            total_amount=0,  # Will be calculated
            shipping_address=command.shipping_address,
            created_at=datetime.utcnow()
        )
        
        # Calculate total amount
        total_amount = 0
        for item in command.items:
            total_amount += item["quantity"] * item["unit_price"]
        
        order.total_amount = total_amount
        
        # Save to write database
        self._order_repository.save(order)
        
        # Publish domain event
        event = OrderCreated(
            order_id=order_id,
            customer_id=command.customer_id,
            total_amount=total_amount
        )
        self._event_store.publish(event)
        
        return order_id
    
    def handle_confirm_order(self, command: ConfirmOrderCommand):
        """Handle confirm order command"""
        order = self._order_repository.get(command.order_id)
        if not order:
            raise ValueError("Order not found")
        
        if order.status != "pending":
            raise ValueError("Order cannot be confirmed")
        
        # Check inventory availability
        for item in order.items:
            available = self._inventory_service.check_availability(
                item.product_id, item.quantity
            )
            if not available:
                raise ValueError(f"Insufficient inventory for product {item.product_id}")
        
        # Reserve inventory
        for item in order.items:
            self._inventory_service.reserve(item.product_id, item.quantity)
        
        # Process payment
        payment_result = self._payment_service.process_payment(
            order_id=command.order_id,
            amount=order.total_amount
        )
        
        if payment_result.success:
            order.status = "confirmed"
            order.payment_id = payment_result.payment_id
        else:
            raise ValueError("Payment processing failed")
        
        # Save to write database
        self._order_repository.save(order)
        
        # Publish domain event
        event = OrderConfirmed(
            order_id=command.order_id,
            customer_id=order.customer_id,
            total_amount=order.total_amount
        )
        self._event_store.publish(event)
```

#### 2. Query Side (Read Model)
**Purpose**: Handle read operations and data presentation
**Implementation**:

```python
# CQRS Query Side Implementation
from typing import List, Optional
from dataclasses import dataclass

# Query Models
@dataclass
class ProductQuery:
    product_id: Optional[str] = None
    category_id: Optional[str] = None
    search: Optional[str] = None
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    is_active: Optional[bool] = None
    skip: int = 0
    limit: int = 100

@dataclass
class OrderQuery:
    order_id: Optional[str] = None
    customer_id: Optional[str] = None
    status: Optional[str] = None
    skip: int = 0
    limit: int = 100

# Query Handlers
class ProductQueryHandler:
    def __init__(self, product_read_repository):
        self._product_read_repository = product_read_repository
    
    def handle_get_product(self, product_id: str):
        """Handle get product query"""
        return self._product_read_repository.get_by_id(product_id)
    
    def handle_list_products(self, query: ProductQuery):
        """Handle list products query"""
        return self._product_read_repository.list(
            category_id=query.category_id,
            search=query.search,
            min_price=query.min_price,
            max_price=query.max_price,
            is_active=query.is_active,
            skip=query.skip,
            limit=query.limit
        )
    
    def handle_search_products(self, search_term: str, limit: int = 20):
        """Handle search products query"""
        return self._product_read_repository.search(search_term, limit)

class OrderQueryHandler:
    def __init__(self, order_read_repository):
        self._order_read_repository = order_read_repository
    
    def handle_get_order(self, order_id: str):
        """Handle get order query"""
        return self._order_read_repository.get_by_id(order_id)
    
    def handle_list_orders(self, query: OrderQuery):
        """Handle list orders query"""
        return self._order_read_repository.list(
            customer_id=query.customer_id,
            status=query.status,
            skip=query.skip,
            limit=query.limit
        )
    
    def handle_get_customer_orders(self, customer_id: str, limit: int = 50):
        """Handle get customer orders query"""
        return self._order_read_repository.get_by_customer(customer_id, limit)

# Read Model Projections
class ProductReadModel:
    def __init__(self, product_id: str, name: str, description: str, 
                 price: float, category_name: str, stock_quantity: int,
                 is_active: bool, created_at: datetime):
        self.product_id = product_id
        self.name = name
        self.description = description
        self.price = price
        self.category_name = category_name
        self.stock_quantity = stock_quantity
        self.is_active = is_active
        self.created_at = created_at

class OrderReadModel:
    def __init__(self, order_id: str, order_number: str, customer_name: str,
                 status: str, total_amount: float, item_count: int,
                 created_at: datetime):
        self.order_id = order_id
        self.order_number = order_number
        self.customer_name = customer_name
        self.status = status
        self.total_amount = total_amount
        self.item_count = item_count
        self.created_at = created_at

# Event Handlers for Read Model Updates
class ProductReadModelEventHandler:
    def __init__(self, product_read_repository):
        self._product_read_repository = product_read_repository
    
    def handle_product_created(self, event: ProductCreated):
        """Handle product created event"""
        # Update read model
        self._product_read_repository.create_read_model(
            product_id=event.product_id,
            name=event.name,
            price=event.price,
            category_id=event.category_id
        )
    
    def handle_product_updated(self, event: ProductUpdated):
        """Handle product updated event"""
        # Update read model
        self._product_read_repository.update_read_model(
            product_id=event.product_id,
            name=event.name,
            price=event.price
        )

class OrderReadModelEventHandler:
    def __init__(self, order_read_repository, customer_service_client):
        self._order_read_repository = order_read_repository
        self._customer_service_client = customer_service_client
    
    def handle_order_created(self, event: OrderCreated):
        """Handle order created event"""
        # Get customer name from user service
        customer = self._customer_service_client.get_customer(event.customer_id)
        customer_name = f"{customer.first_name} {customer.last_name}"
        
        # Update read model
        self._order_read_repository.create_read_model(
            order_id=event.order_id,
            customer_name=customer_name,
            total_amount=event.total_amount
        )
    
    def handle_order_confirmed(self, event: OrderConfirmed):
        """Handle order confirmed event"""
        # Update read model
        self._order_read_repository.update_status(
            order_id=event.order_id,
            status="confirmed"
        )
```

## Task 3: Event Sourcing Implementation

### Event Store Design

#### 1. Event Store Implementation
**Purpose**: Store and retrieve domain events
**Implementation**:

```python
# Event Store Implementation
from typing import List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import uuid

@dataclass
class DomainEvent:
    event_id: str
    aggregate_id: str
    event_type: str
    event_data: dict
    occurred_at: datetime
    version: int

class EventStore:
    def __init__(self, database):
        self._database = database
    
    def save_events(self, aggregate_id: str, events: List[DomainEvent], expected_version: int):
        """Save events for an aggregate"""
        # Check version for optimistic concurrency control
        current_version = self._get_aggregate_version(aggregate_id)
        if current_version != expected_version:
            raise ConcurrencyError(f"Expected version {expected_version}, got {current_version}")
        
        # Save events
        for event in events:
            self._save_event(event)
        
        # Update aggregate version
        self._update_aggregate_version(aggregate_id, expected_version + len(events))
    
    def get_events(self, aggregate_id: str, from_version: int = 0) -> List[DomainEvent]:
        """Get events for an aggregate"""
        query = """
            SELECT event_id, aggregate_id, event_type, event_data, occurred_at, version
            FROM events
            WHERE aggregate_id = ? AND version > ?
            ORDER BY version ASC
        """
        
        results = self._database.execute(query, (aggregate_id, from_version))
        events = []
        
        for row in results:
            event = DomainEvent(
                event_id=row[0],
                aggregate_id=row[1],
                event_type=row[2],
                event_data=json.loads(row[3]),
                occurred_at=datetime.fromisoformat(row[4]),
                version=row[5]
            )
            events.append(event)
        
        return events
    
    def get_events_by_type(self, event_type: str, from_date: Optional[datetime] = None) -> List[DomainEvent]:
        """Get events by type"""
        query = """
            SELECT event_id, aggregate_id, event_type, event_data, occurred_at, version
            FROM events
            WHERE event_type = ?
        """
        params = [event_type]
        
        if from_date:
            query += " AND occurred_at >= ?"
            params.append(from_date.isoformat())
        
        query += " ORDER BY occurred_at ASC"
        
        results = self._database.execute(query, params)
        events = []
        
        for row in results:
            event = DomainEvent(
                event_id=row[0],
                aggregate_id=row[1],
                event_type=row[2],
                event_data=json.loads(row[3]),
                occurred_at=datetime.fromisoformat(row[4]),
                version=row[5]
            )
            events.append(event)
        
        return events
    
    def _save_event(self, event: DomainEvent):
        """Save a single event"""
        query = """
            INSERT INTO events (event_id, aggregate_id, event_type, event_data, occurred_at, version)
            VALUES (?, ?, ?, ?, ?, ?)
        """
        
        self._database.execute(query, (
            event.event_id,
            event.aggregate_id,
            event.event_type,
            json.dumps(event.event_data),
            event.occurred_at.isoformat(),
            event.version
        ))
    
    def _get_aggregate_version(self, aggregate_id: str) -> int:
        """Get current version of an aggregate"""
        query = "SELECT version FROM aggregates WHERE aggregate_id = ?"
        result = self._database.execute(query, (aggregate_id,)).fetchone()
        return result[0] if result else 0
    
    def _update_aggregate_version(self, aggregate_id: str, version: int):
        """Update aggregate version"""
        query = """
            INSERT OR REPLACE INTO aggregates (aggregate_id, version, updated_at)
            VALUES (?, ?, ?)
        """
        
        self._database.execute(query, (
            aggregate_id,
            version,
            datetime.utcnow().isoformat()
        ))

# Event Sourced Aggregates
class EventSourcedAggregate:
    def __init__(self, aggregate_id: str):
        self._id = aggregate_id
        self._version = 0
        self._uncommitted_events = []
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def version(self) -> int:
        return self._version
    
    def get_uncommitted_events(self) -> List[DomainEvent]:
        return self._uncommitted_events.copy()
    
    def mark_events_as_committed(self):
        self._uncommitted_events.clear()
    
    def _apply_event(self, event: DomainEvent):
        """Apply event to aggregate state"""
        self._version = event.version
        # Override in subclasses to handle specific events
    
    def _add_event(self, event_type: str, event_data: dict):
        """Add new event to uncommitted events"""
        event = DomainEvent(
            event_id=str(uuid.uuid4()),
            aggregate_id=self._id,
            event_type=event_type,
            event_data=event_data,
            occurred_at=datetime.utcnow(),
            version=self._version + len(self._uncommitted_events) + 1
        )
        self._uncommitted_events.append(event)
        self._apply_event(event)

# Event Sourced Product Aggregate
class EventSourcedProduct(EventSourcedAggregate):
    def __init__(self, aggregate_id: str):
        super().__init__(aggregate_id)
        self._name = ""
        self._description = ""
        self._price = 0.0
        self._category_id = ""
        self._stock_quantity = 0
        self._is_active = False
    
    @classmethod
    def create(cls, name: str, description: str, price: float, category_id: str, stock_quantity: int):
        """Create new product aggregate"""
        product = cls(str(uuid.uuid4()))
        product._add_event("ProductCreated", {
            "name": name,
            "description": description,
            "price": price,
            "category_id": category_id,
            "stock_quantity": stock_quantity
        })
        return product
    
    @classmethod
    def from_events(cls, aggregate_id: str, events: List[DomainEvent]):
        """Reconstruct aggregate from events"""
        product = cls(aggregate_id)
        for event in events:
            product._apply_event(event)
        product._version = events[-1].version if events else 0
        return product
    
    def update(self, name: str = None, description: str = None, price: float = None, stock_quantity: int = None):
        """Update product"""
        if not self._is_active:
            raise ValueError("Cannot update inactive product")
        
        event_data = {}
        if name is not None:
            event_data["name"] = name
        if description is not None:
            event_data["description"] = description
        if price is not None:
            event_data["price"] = price
        if stock_quantity is not None:
            event_data["stock_quantity"] = stock_quantity
        
        if event_data:
            self._add_event("ProductUpdated", event_data)
    
    def deactivate(self):
        """Deactivate product"""
        if not self._is_active:
            raise ValueError("Product is already inactive")
        
        self._add_event("ProductDeactivated", {})
    
    def _apply_event(self, event: DomainEvent):
        """Apply event to product state"""
        super()._apply_event(event)
        
        if event.event_type == "ProductCreated":
            self._name = event.event_data["name"]
            self._description = event.event_data["description"]
            self._price = event.event_data["price"]
            self._category_id = event.event_data["category_id"]
            self._stock_quantity = event.event_data["stock_quantity"]
            self._is_active = True
        
        elif event.event_type == "ProductUpdated":
            if "name" in event.event_data:
                self._name = event.event_data["name"]
            if "description" in event.event_data:
                self._description = event.event_data["description"]
            if "price" in event.event_data:
                self._price = event.event_data["price"]
            if "stock_quantity" in event.event_data:
                self._stock_quantity = event.event_data["stock_quantity"]
        
        elif event.event_type == "ProductDeactivated":
            self._is_active = False
```

## Task 4: Saga Pattern Implementation

### Saga Pattern for Distributed Transactions

#### 1. Order Processing Saga
**Purpose**: Manage distributed transaction for order processing
**Implementation**:

```python
# Saga Pattern Implementation
from abc import ABC, abstractmethod
from enum import Enum
from typing import List, Dict, Any
from dataclasses import dataclass
import uuid

class SagaStatus(Enum):
    STARTED = "started"
    COMPLETED = "completed"
    FAILED = "failed"
    COMPENSATING = "compensating"

@dataclass
class SagaStep:
    step_id: str
    action: str
    compensation: str
    status: str = "pending"
    data: Dict[Any, Any] = None

class Saga(ABC):
    def __init__(self, saga_id: str):
        self._id = saga_id
        self._status = SagaStatus.STARTED
        self._steps: List[SagaStep] = []
        self._current_step_index = 0
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def status(self) -> SagaStatus:
        return self._status
    
    def add_step(self, step: SagaStep):
        """Add step to saga"""
        self._steps.append(step)
    
    def execute(self):
        """Execute saga steps"""
        try:
            for i, step in enumerate(self._steps):
                self._current_step_index = i
                self._execute_step(step)
                step.status = "completed"
            
            self._status = SagaStatus.COMPLETED
        except Exception as e:
            self._status = SagaStatus.FAILED
            self._compensate()
            raise e
    
    def _execute_step(self, step: SagaStep):
        """Execute individual step"""
        # Override in subclasses
        pass
    
    def _compensate(self):
        """Compensate for failed saga"""
        self._status = SagaStatus.COMPENSATING
        
        # Execute compensation steps in reverse order
        for step in reversed(self._steps[:self._current_step_index + 1]):
            if step.status == "completed":
                self._execute_compensation(step)
                step.status = "compensated"
    
    def _execute_compensation(self, step: SagaStep):
        """Execute compensation for step"""
        # Override in subclasses
        pass

# Order Processing Saga
class OrderProcessingSaga(Saga):
    def __init__(self, order_id: str, customer_id: str, items: List[Dict], 
                 inventory_service, payment_service, order_service):
        super().__init__(str(uuid.uuid4()))
        self._order_id = order_id
        self._customer_id = customer_id
        self._items = items
        self._inventory_service = inventory_service
        self._payment_service = payment_service
        self._order_service = order_service
        
        # Define saga steps
        self._setup_steps()
    
    def _setup_steps(self):
        """Setup saga steps"""
        # Step 1: Create order
        self.add_step(SagaStep(
            step_id="create_order",
            action="create_order",
            compensation="cancel_order",
            data={"order_id": self._order_id, "customer_id": self._customer_id, "items": self._items}
        ))
        
        # Step 2: Reserve inventory
        self.add_step(SagaStep(
            step_id="reserve_inventory",
            action="reserve_inventory",
            compensation="release_inventory",
            data={"items": self._items}
        ))
        
        # Step 3: Process payment
        self.add_step(SagaStep(
            step_id="process_payment",
            action="process_payment",
            compensation="refund_payment",
            data={"order_id": self._order_id, "amount": self._calculate_total_amount()}
        ))
        
        # Step 4: Confirm order
        self.add_step(SagaStep(
            step_id="confirm_order",
            action="confirm_order",
            compensation="cancel_order",
            data={"order_id": self._order_id}
        ))
    
    def _execute_step(self, step: SagaStep):
        """Execute individual step"""
        if step.step_id == "create_order":
            self._create_order(step.data)
        elif step.step_id == "reserve_inventory":
            self._reserve_inventory(step.data)
        elif step.step_id == "process_payment":
            self._process_payment(step.data)
        elif step.step_id == "confirm_order":
            self._confirm_order(step.data)
    
    def _execute_compensation(self, step: SagaStep):
        """Execute compensation for step"""
        if step.step_id == "create_order":
            self._cancel_order(step.data)
        elif step.step_id == "reserve_inventory":
            self._release_inventory(step.data)
        elif step.step_id == "process_payment":
            self._refund_payment(step.data)
        elif step.step_id == "confirm_order":
            self._cancel_order(step.data)
    
    def _create_order(self, data: Dict[str, Any]):
        """Create order"""
        order = self._order_service.create_order(
            order_id=data["order_id"],
            customer_id=data["customer_id"],
            items=data["items"]
        )
        return order
    
    def _reserve_inventory(self, data: Dict[str, Any]):
        """Reserve inventory for order items"""
        for item in data["items"]:
            success = self._inventory_service.reserve(
                product_id=item["product_id"],
                quantity=item["quantity"]
            )
            if not success:
                raise Exception(f"Failed to reserve inventory for product {item['product_id']}")
    
    def _process_payment(self, data: Dict[str, Any]):
        """Process payment for order"""
        payment_result = self._payment_service.process_payment(
            order_id=data["order_id"],
            amount=data["amount"]
        )
        if not payment_result.success:
            raise Exception(f"Payment processing failed: {payment_result.error_message}")
        return payment_result
    
    def _confirm_order(self, data: Dict[str, Any]):
        """Confirm order"""
        self._order_service.confirm_order(data["order_id"])
    
    def _cancel_order(self, data: Dict[str, Any]):
        """Cancel order (compensation)"""
        self._order_service.cancel_order(data["order_id"])
    
    def _release_inventory(self, data: Dict[str, Any]):
        """Release inventory (compensation)"""
        for item in data["items"]:
            self._inventory_service.release(
                product_id=item["product_id"],
                quantity=item["quantity"]
            )
    
    def _refund_payment(self, data: Dict[str, Any]):
        """Refund payment (compensation)"""
        self._payment_service.refund_payment(
            order_id=data["order_id"],
            amount=data["amount"]
        )
    
    def _calculate_total_amount(self) -> float:
        """Calculate total amount for order"""
        total = 0.0
        for item in self._items:
            total += item["quantity"] * item["unit_price"]
        return total

# Saga Manager
class SagaManager:
    def __init__(self, event_store):
        self._event_store = event_store
        self._active_sagas = {}
    
    def start_saga(self, saga: Saga):
        """Start saga execution"""
        self._active_sagas[saga.id] = saga
        
        try:
            saga.execute()
            self._publish_saga_event("SagaCompleted", saga.id)
        except Exception as e:
            self._publish_saga_event("SagaFailed", saga.id, str(e))
        finally:
            del self._active_sagas[saga.id]
    
    def _publish_saga_event(self, event_type: str, saga_id: str, error_message: str = None):
        """Publish saga event"""
        event_data = {
            "saga_id": saga_id,
            "event_type": event_type
        }
        if error_message:
            event_data["error_message"] = error_message
        
        event = DomainEvent(
            event_id=str(uuid.uuid4()),
            aggregate_id=saga_id,
            event_type=event_type,
            event_data=event_data,
            occurred_at=datetime.utcnow(),
            version=1
        )
        
        self._event_store.publish(event)
```

## Best Practices Applied

### Database per Service
1. **Service Isolation**: Each service owns its data completely
2. **Technology Diversity**: Use appropriate database for each service
3. **Data Consistency**: Accept eventual consistency where appropriate
4. **Data Synchronization**: Use events for data synchronization
5. **Migration Strategy**: Plan for database migrations

### CQRS
1. **Separation of Concerns**: Separate read and write models
2. **Optimization**: Optimize each model for its purpose
3. **Event-Driven**: Use events to update read models
4. **Scalability**: Scale read and write models independently
5. **Consistency**: Accept eventual consistency for read models

### Event Sourcing
1. **Event Store**: Centralized event storage
2. **Aggregate Reconstruction**: Rebuild state from events
3. **Version Control**: Use optimistic concurrency control
4. **Event Replay**: Support event replay for debugging
5. **Snapshot Strategy**: Use snapshots for performance

### Saga Pattern
1. **Compensation**: Implement compensation for each step
2. **Idempotency**: Make steps idempotent
3. **Monitoring**: Monitor saga execution
4. **Error Handling**: Handle failures gracefully
5. **Testing**: Test saga scenarios thoroughly

## Lessons Learned

### Key Insights
1. **Data Management**: Proper data management is crucial for microservices
2. **Event-Driven**: Events enable loose coupling and scalability
3. **Consistency**: Accept eventual consistency where appropriate
4. **Compensation**: Implement compensation for distributed transactions
5. **Monitoring**: Monitor data consistency and saga execution

### Common Pitfalls
1. **Shared Databases**: Don't share databases between services
2. **Synchronous Updates**: Don't use synchronous updates for read models
3. **No Compensation**: Don't skip compensation logic
4. **Poor Event Design**: Don't design events poorly
5. **No Monitoring**: Don't skip monitoring and observability

### Recommendations
1. **Start Simple**: Begin with simple data management patterns
2. **Use Events**: Use events for data synchronization
3. **Plan Compensation**: Plan compensation from the start
4. **Monitor Everything**: Monitor data consistency and saga execution
5. **Test Thoroughly**: Test all data management scenarios

## Next Steps

1. **Implementation**: Implement the data management patterns
2. **Testing**: Test all data management scenarios
3. **Monitoring**: Set up comprehensive monitoring
4. **Optimization**: Optimize data management performance
5. **Evolution**: Evolve patterns based on requirements
