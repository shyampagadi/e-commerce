# Exercise 2 Solution: Domain-Driven Design

## Solution Overview

This solution demonstrates the application of Domain-Driven Design (DDD) principles to identify bounded contexts, create domain models, and establish a ubiquitous language for a complex e-commerce platform.

## Task 1: Bounded Context Identification

### Identified Bounded Contexts

#### 1. User Management Context
**Domain**: User identity, authentication, and profile management
**Key Concepts**: User, Profile, Authentication, Authorization, Preferences
**Business Rules**:
- Users must have unique email addresses
- Passwords must meet security requirements
- User profiles can be public or private
- Authentication tokens expire after 30 minutes

**Context Map**:
```
User Management Context
├── User (Entity)
│   ├── UserId (Value Object)
│   ├── Email (Value Object)
│   ├── Password (Value Object)
│   └── Profile (Value Object)
├── Authentication (Service)
├── Authorization (Service)
└── UserRepository (Repository)
```

#### 2. Product Catalog Context
**Domain**: Product information, categories, and inventory
**Key Concepts**: Product, Category, Brand, SKU, Inventory
**Business Rules**:
- Products must belong to a category
- SKUs must be unique across the platform
- Products can have multiple variants
- Inventory levels must be tracked in real-time

**Context Map**:
```
Product Catalog Context
├── Product (Entity)
│   ├── ProductId (Value Object)
│   ├── SKU (Value Object)
│   ├── Name (Value Object)
│   ├── Description (Value Object)
│   ├── Price (Value Object)
│   └── Category (Entity)
├── Category (Entity)
├── Brand (Entity)
├── Inventory (Entity)
└── ProductRepository (Repository)
```

#### 3. Order Management Context
**Domain**: Order creation, processing, and fulfillment
**Key Concepts**: Order, OrderItem, OrderStatus, Fulfillment
**Business Rules**:
- Orders must have at least one item
- Order status follows a specific lifecycle
- Orders cannot be modified after confirmation
- Fulfillment must track shipping details

**Context Map**:
```
Order Management Context
├── Order (Aggregate Root)
│   ├── OrderId (Value Object)
│   ├── CustomerId (Value Object)
│   ├── OrderItems (Collection)
│   ├── Status (Value Object)
│   ├── TotalAmount (Value Object)
│   └── ShippingAddress (Value Object)
├── OrderItem (Entity)
├── OrderStatus (Enum)
├── Fulfillment (Entity)
└── OrderRepository (Repository)
```

#### 4. Payment Processing Context
**Domain**: Payment processing, billing, and financial transactions
**Key Concepts**: Payment, PaymentMethod, Transaction, Invoice
**Business Rules**:
- Payments must be associated with an order
- Payment methods must be validated
- Transactions are immutable once created
- Refunds must reference original transactions

**Context Map**:
```
Payment Processing Context
├── Payment (Aggregate Root)
│   ├── PaymentId (Value Object)
│   ├── OrderId (Value Object)
│   ├── Amount (Value Object)
│   ├── Currency (Value Object)
│   ├── PaymentMethod (Entity)
│   └── Status (Value Object)
├── PaymentMethod (Entity)
├── Transaction (Entity)
├── Invoice (Entity)
└── PaymentRepository (Repository)
```

#### 5. Inventory Management Context
**Domain**: Stock management, availability, and warehouse operations
**Key Concepts**: Stock, Warehouse, StockMovement, Reservation
**Business Rules**:
- Stock levels cannot go negative
- Reservations must be released after timeout
- Stock movements are immutable
- Warehouse locations must be tracked

**Context Map**:
```
Inventory Management Context
├── Stock (Aggregate Root)
│   ├── ProductId (Value Object)
│   ├── WarehouseId (Value Object)
│   ├── Quantity (Value Object)
│   ├── ReservedQuantity (Value Object)
│   └── AvailableQuantity (Value Object)
├── Warehouse (Entity)
├── StockMovement (Entity)
├── Reservation (Entity)
└── StockRepository (Repository)
```

### Context Relationships

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ User Management │    │ Product Catalog │    │ Order Management│
│                 │    │                 │    │                 │
│ • User          │    │ • Product       │    │ • Order         │
│ • Profile       │    │ • Category      │    │ • OrderItem     │
│ • Auth          │    │ • Inventory     │    │ • Fulfillment   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Shared Contexts                     │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │   Payment   │ │  Inventory  │ │Notification │      │
    │  │ Processing  │ │ Management  │ │             │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
```

## Task 2: Domain Model Design

### User Management Domain Model

```python
# User Management Domain Model
from dataclasses import dataclass
from typing import Optional
from datetime import datetime
import uuid

@dataclass(frozen=True)
class UserId:
    value: str
    
    def __post_init__(self):
        if not self.value:
            raise ValueError("User ID cannot be empty")

@dataclass(frozen=True)
class Email:
    value: str
    
    def __post_init__(self):
        if "@" not in self.value:
            raise ValueError("Invalid email format")

@dataclass(frozen=True)
class Password:
    value: str
    
    def __post_init__(self):
        if len(self.value) < 8:
            raise ValueError("Password must be at least 8 characters")

@dataclass
class UserProfile:
    full_name: str
    phone: Optional[str] = None
    address: Optional[str] = None
    preferences: dict = None
    
    def __post_init__(self):
        if not self.full_name:
            raise ValueError("Full name is required")
        if self.preferences is None:
            self.preferences = {}

class User:
    def __init__(self, user_id: UserId, email: Email, password: Password, profile: UserProfile):
        self._id = user_id
        self._email = email
        self._password = password
        self._profile = profile
        self._is_active = True
        self._created_at = datetime.utcnow()
        self._updated_at = datetime.utcnow()
    
    @property
    def id(self) -> UserId:
        return self._id
    
    @property
    def email(self) -> Email:
        return self._email
    
    @property
    def profile(self) -> UserProfile:
        return self._profile
    
    def update_profile(self, new_profile: UserProfile):
        self._profile = new_profile
        self._updated_at = datetime.utcnow()
    
    def deactivate(self):
        self._is_active = False
        self._updated_at = datetime.utcnow()
    
    def is_active(self) -> bool:
        return self._is_active

class AuthenticationService:
    def __init__(self, user_repository, password_hasher, token_generator):
        self._user_repository = user_repository
        self._password_hasher = password_hasher
        self._token_generator = token_generator
    
    def authenticate(self, email: Email, password: Password) -> Optional[str]:
        user = self._user_repository.find_by_email(email)
        if not user or not user.is_active():
            return None
        
        if self._password_hasher.verify(password.value, user._password.value):
            return self._token_generator.generate(user.id)
        
        return None
    
    def register(self, email: Email, password: Password, profile: UserProfile) -> User:
        if self._user_repository.find_by_email(email):
            raise ValueError("User already exists")
        
        hashed_password = Password(self._password_hasher.hash(password.value))
        user = User(UserId(str(uuid.uuid4())), email, hashed_password, profile)
        
        self._user_repository.save(user)
        return user
```

### Product Catalog Domain Model

```python
# Product Catalog Domain Model
from dataclasses import dataclass
from typing import List, Optional
from decimal import Decimal
import uuid

@dataclass(frozen=True)
class ProductId:
    value: str

@dataclass(frozen=True)
class SKU:
    value: str
    
    def __post_init__(self):
        if not self.value or len(self.value) < 3:
            raise ValueError("SKU must be at least 3 characters")

@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str
    
    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")
        if not self.currency or len(self.currency) != 3:
            raise ValueError("Currency must be 3 characters")

@dataclass
class ProductVariant:
    variant_id: str
    name: str
    sku: SKU
    price: Money
    attributes: dict
    
    def __post_init__(self):
        if not self.name:
            raise ValueError("Variant name is required")

class Category:
    def __init__(self, category_id: str, name: str, description: str, parent_id: Optional[str] = None):
        self._id = category_id
        self._name = name
        self._description = description
        self._parent_id = parent_id
        self._is_active = True
    
    @property
    def id(self) -> str:
        return self._id
    
    @property
    def name(self) -> str:
        return self._name
    
    def is_active(self) -> bool:
        return self._is_active

class Product:
    def __init__(self, product_id: ProductId, name: str, description: str, 
                 category: Category, base_price: Money):
        self._id = product_id
        self._name = name
        self._description = description
        self._category = category
        self._base_price = base_price
        self._variants: List[ProductVariant] = []
        self._is_active = True
    
    @property
    def id(self) -> ProductId:
        return self._id
    
    @property
    def name(self) -> str:
        return self._name
    
    @property
    def category(self) -> Category:
        return self._category
    
    def add_variant(self, variant: ProductVariant):
        if any(v.sku == variant.sku for v in self._variants):
            raise ValueError("Variant with this SKU already exists")
        self._variants.append(variant)
    
    def get_variant_by_sku(self, sku: SKU) -> Optional[ProductVariant]:
        return next((v for v in self._variants if v.sku == sku), None)
    
    def deactivate(self):
        self._is_active = False
    
    def is_active(self) -> bool:
        return self._is_active

class ProductCatalogService:
    def __init__(self, product_repository, category_repository):
        self._product_repository = product_repository
        self._category_repository = category_repository
    
    def create_product(self, name: str, description: str, category_id: str, 
                      base_price: Money) -> Product:
        category = self._category_repository.find_by_id(category_id)
        if not category or not category.is_active():
            raise ValueError("Invalid category")
        
        product = Product(
            ProductId(str(uuid.uuid4())),
            name,
            description,
            category,
            base_price
        )
        
        self._product_repository.save(product)
        return product
    
    def add_product_variant(self, product_id: ProductId, variant: ProductVariant):
        product = self._product_repository.find_by_id(product_id)
        if not product:
            raise ValueError("Product not found")
        
        product.add_variant(variant)
        self._product_repository.save(product)
```

### Order Management Domain Model

```python
# Order Management Domain Model
from dataclasses import dataclass
from typing import List
from decimal import Decimal
from enum import Enum
import uuid

class OrderStatus(Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

@dataclass(frozen=True)
class OrderId:
    value: str

@dataclass(frozen=True)
class CustomerId:
    value: str

@dataclass
class OrderItem:
    product_id: str
    sku: str
    quantity: int
    unit_price: Decimal
    total_price: Decimal
    
    def __post_init__(self):
        if self.quantity <= 0:
            raise ValueError("Quantity must be positive")
        if self.unit_price < 0:
            raise ValueError("Unit price cannot be negative")
        if self.total_price != self.quantity * self.unit_price:
            raise ValueError("Total price calculation error")

@dataclass
class ShippingAddress:
    street: str
    city: str
    state: str
    zip_code: str
    country: str
    
    def __post_init__(self):
        if not all([self.street, self.city, self.state, self.zip_code, self.country]):
            raise ValueError("All address fields are required")

class Order:
    def __init__(self, order_id: OrderId, customer_id: CustomerId, 
                 shipping_address: ShippingAddress):
        self._id = order_id
        self._customer_id = customer_id
        self._shipping_address = shipping_address
        self._items: List[OrderItem] = []
        self._status = OrderStatus.PENDING
        self._total_amount = Decimal('0.00')
        self._created_at = datetime.utcnow()
        self._updated_at = datetime.utcnow()
    
    @property
    def id(self) -> OrderId:
        return self._id
    
    @property
    def customer_id(self) -> CustomerId:
        return self._customer_id
    
    @property
    def status(self) -> OrderStatus:
        return self._status
    
    @property
    def total_amount(self) -> Decimal:
        return self._total_amount
    
    def add_item(self, product_id: str, sku: str, quantity: int, unit_price: Decimal):
        if self._status != OrderStatus.PENDING:
            raise ValueError("Cannot modify order after confirmation")
        
        item = OrderItem(product_id, sku, quantity, unit_price, quantity * unit_price)
        self._items.append(item)
        self._recalculate_total()
        self._updated_at = datetime.utcnow()
    
    def remove_item(self, product_id: str, sku: str):
        if self._status != OrderStatus.PENDING:
            raise ValueError("Cannot modify order after confirmation")
        
        self._items = [item for item in self._items 
                      if not (item.product_id == product_id and item.sku == sku)]
        self._recalculate_total()
        self._updated_at = datetime.utcnow()
    
    def confirm(self):
        if not self._items:
            raise ValueError("Cannot confirm empty order")
        
        self._status = OrderStatus.CONFIRMED
        self._updated_at = datetime.utcnow()
    
    def cancel(self):
        if self._status in [OrderStatus.SHIPPED, OrderStatus.DELIVERED]:
            raise ValueError("Cannot cancel shipped or delivered order")
        
        self._status = OrderStatus.CANCELLED
        self._updated_at = datetime.utcnow()
    
    def _recalculate_total(self):
        self._total_amount = sum(item.total_price for item in self._items)

class OrderService:
    def __init__(self, order_repository, inventory_service, payment_service):
        self._order_repository = order_repository
        self._inventory_service = inventory_service
        self._payment_service = payment_service
    
    def create_order(self, customer_id: CustomerId, shipping_address: ShippingAddress) -> Order:
        order = Order(OrderId(str(uuid.uuid4())), customer_id, shipping_address)
        self._order_repository.save(order)
        return order
    
    def add_item_to_order(self, order_id: OrderId, product_id: str, sku: str, 
                         quantity: int, unit_price: Decimal):
        order = self._order_repository.find_by_id(order_id)
        if not order:
            raise ValueError("Order not found")
        
        # Check inventory availability
        if not self._inventory_service.is_available(product_id, sku, quantity):
            raise ValueError("Insufficient inventory")
        
        order.add_item(product_id, sku, quantity, unit_price)
        self._order_repository.save(order)
    
    def confirm_order(self, order_id: OrderId):
        order = self._order_repository.find_by_id(order_id)
        if not order:
            raise ValueError("Order not found")
        
        # Reserve inventory
        for item in order._items:
            self._inventory_service.reserve(item.product_id, item.sku, item.quantity)
        
        order.confirm()
        self._order_repository.save(order)
        
        # Process payment
        self._payment_service.process_payment(order_id, order.total_amount)
```

## Task 3: Ubiquitous Language

### Domain Dictionary

#### User Management Terms
- **User**: A person who can access the system
- **Profile**: Personal information associated with a user
- **Authentication**: Process of verifying user identity
- **Authorization**: Process of determining user permissions
- **Session**: Active user session with authentication token

#### Product Catalog Terms
- **Product**: An item that can be sold
- **Category**: Classification of products
- **SKU**: Stock Keeping Unit - unique identifier for product variants
- **Variant**: Different versions of a product (size, color, etc.)
- **Brand**: Manufacturer or company that produces products
- **Inventory**: Available stock of products

#### Order Management Terms
- **Order**: Customer's request to purchase products
- **Order Item**: Individual product in an order
- **Order Status**: Current state of an order in its lifecycle
- **Fulfillment**: Process of preparing and shipping orders
- **Shipping Address**: Where the order should be delivered

#### Payment Terms
- **Payment**: Financial transaction for an order
- **Payment Method**: How a customer pays (credit card, PayPal, etc.)
- **Transaction**: Record of a payment attempt
- **Invoice**: Document requesting payment
- **Refund**: Return of payment to customer

#### Inventory Terms
- **Stock**: Available quantity of a product
- **Warehouse**: Physical location where products are stored
- **Stock Movement**: Change in stock quantity
- **Reservation**: Temporary hold on stock for an order
- **Availability**: Whether a product can be ordered

### Business Rules Documentation

#### User Management Rules
1. **RULE-UM-001**: User email addresses must be unique across the system
2. **RULE-UM-002**: Passwords must be at least 8 characters long
3. **RULE-UM-003**: User accounts are active by default upon creation
4. **RULE-UM-004**: Authentication tokens expire after 30 minutes of inactivity
5. **RULE-UM-005**: Users can only modify their own profiles

#### Product Catalog Rules
1. **RULE-PC-001**: Products must belong to exactly one category
2. **RULE-PC-002**: SKUs must be unique across all product variants
3. **RULE-PC-003**: Product prices cannot be negative
4. **RULE-PC-004**: Inactive products cannot be added to orders
5. **RULE-PC-005**: Product variants must have unique SKUs within the same product

#### Order Management Rules
1. **RULE-OM-001**: Orders must contain at least one item
2. **RULE-OM-002**: Order status follows: PENDING → CONFIRMED → PROCESSING → SHIPPED → DELIVERED
3. **RULE-OM-003**: Orders cannot be modified after confirmation
4. **RULE-OM-004**: Cancelled orders cannot be reactivated
5. **RULE-OM-005**: Order total must equal sum of all item totals

#### Payment Rules
1. **RULE-PM-001**: Payments must be associated with exactly one order
2. **RULE-PM-002**: Payment amount must equal order total
3. **RULE-PM-003**: Payment methods must be validated before use
4. **RULE-PM-004**: Refunds cannot exceed original payment amount
5. **RULE-PM-005**: Failed payments must be retryable

#### Inventory Rules
1. **RULE-INV-001**: Stock quantities cannot be negative
2. **RULE-INV-002**: Reservations must be released after 15 minutes
3. **RULE-INV-003**: Stock movements are immutable once created
4. **RULE-INV-004**: Available quantity = Total quantity - Reserved quantity
5. **RULE-INV-005**: Products cannot be ordered if not available

## Task 4: Context Mapping

### Context Relationships

#### Customer-Supplier Relationships
- **Order Management** → **User Management**: Orders need customer information
- **Order Management** → **Product Catalog**: Orders need product information
- **Order Management** → **Inventory Management**: Orders need stock availability
- **Order Management** → **Payment Processing**: Orders need payment processing

#### Shared Kernel
- **Common Value Objects**: Money, Address, Email, Phone
- **Common Enums**: Currency, Country, OrderStatus
- **Common Interfaces**: Repository patterns, Domain Events

#### Anti-Corruption Layer
- **External Payment Gateway**: Payment service translates between domain and external API
- **External Shipping Service**: Fulfillment service translates between domain and external API
- **External Notification Service**: Notification service translates between domain and external API

### Integration Patterns

#### Synchronous Integration
- **Order → Inventory**: Check availability before order confirmation
- **Order → Payment**: Process payment immediately after order confirmation
- **User → Authentication**: Validate user credentials for each request

#### Asynchronous Integration
- **Order → Notification**: Send order confirmation emails
- **Payment → Order**: Update order status after payment processing
- **Inventory → Order**: Notify when stock becomes available

### Domain Events

```python
# Domain Events
from dataclasses import dataclass
from datetime import datetime
from typing import Any

@dataclass
class DomainEvent:
    event_id: str
    occurred_at: datetime
    aggregate_id: str
    event_type: str
    data: dict

class UserRegistered(DomainEvent):
    def __init__(self, user_id: str, email: str, full_name: str):
        super().__init__(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            aggregate_id=user_id,
            event_type="UserRegistered",
            data={"email": email, "full_name": full_name}
        )

class OrderConfirmed(DomainEvent):
    def __init__(self, order_id: str, customer_id: str, total_amount: Decimal):
        super().__init__(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            aggregate_id=order_id,
            event_type="OrderConfirmed",
            data={"customer_id": customer_id, "total_amount": str(total_amount)}
        )

class PaymentProcessed(DomainEvent):
    def __init__(self, payment_id: str, order_id: str, amount: Decimal, status: str):
        super().__init__(
            event_id=str(uuid.uuid4()),
            occurred_at=datetime.utcnow(),
            aggregate_id=payment_id,
            event_type="PaymentProcessed",
            data={"order_id": order_id, "amount": str(amount), "status": status}
        )
```

## Best Practices Applied

### Domain Modeling
1. **Rich Domain Models**: Entities contain business logic and behavior
2. **Value Objects**: Immutable objects for concepts like Money, Email
3. **Aggregates**: Consistency boundaries for related entities
4. **Domain Services**: Business logic that doesn't belong to entities
5. **Repositories**: Abstract data access for aggregates

### Context Design
1. **Clear Boundaries**: Each context has well-defined responsibilities
2. **Minimal Dependencies**: Contexts depend on each other minimally
3. **Explicit Interfaces**: Clear contracts between contexts
4. **Event-Driven**: Use events for loose coupling
5. **Anti-Corruption Layers**: Protect domain from external systems

### Language Design
1. **Consistent Terminology**: Same terms used throughout the domain
2. **Business-Focused**: Language reflects business concepts
3. **Precise Definitions**: Clear definitions for all terms
4. **Living Documentation**: Language evolves with the domain
5. **Team Alignment**: All team members use the same language

## Lessons Learned

### Key Insights
1. **Context Boundaries**: Getting context boundaries right is crucial
2. **Language Consistency**: Consistent language improves communication
3. **Domain Focus**: Focus on business domain, not technical implementation
4. **Event-Driven Design**: Events enable loose coupling between contexts
5. **Iterative Refinement**: Domain models evolve with understanding

### Common Pitfalls
1. **Anemic Domain Models**: Don't put business logic in services
2. **Context Bleeding**: Don't mix concerns across contexts
3. **Technical Language**: Use business language, not technical terms
4. **Over-Engineering**: Don't over-complicate the domain model
5. **Ignoring Events**: Use events for context integration

### Recommendations
1. **Start with Contexts**: Identify contexts before detailed modeling
2. **Use Events**: Use events for context communication
3. **Iterate**: Refine the model as understanding grows
4. **Document Language**: Keep language documentation up to date
5. **Team Collaboration**: Involve business experts in modeling

## Next Steps

1. **Implementation**: Implement the domain models in code
2. **Testing**: Create comprehensive tests for domain logic
3. **Events**: Implement event handling and publishing
4. **Integration**: Implement context integration patterns
5. **Refinement**: Continuously refine based on feedback
