# Exercise 5 Solution: API Design Patterns

## Solution Overview

This solution demonstrates the design and implementation of API patterns for a microservices e-commerce platform, including RESTful APIs, GraphQL schemas, gRPC services, API versioning, and API Gateway integration.

## Task 1: RESTful API Design

### API Design Principles

#### 1. Resource-Based URLs
**Principle**: URLs should represent resources, not actions
**Implementation**:

```python
# RESTful API Design
from fastapi import FastAPI, HTTPException, status, Depends
from typing import List, Optional
from pydantic import BaseModel
import uuid

app = FastAPI(title="E-commerce API", version="1.0.0")

# Resource Models
class Product(BaseModel):
    id: str
    name: str
    description: str
    price: float
    category_id: str
    stock_quantity: int
    is_active: bool
    created_at: str
    updated_at: str

class ProductCreate(BaseModel):
    name: str
    description: str
    price: float
    category_id: str
    stock_quantity: int

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    stock_quantity: Optional[int] = None

# Product Resource Endpoints
@app.get("/products", response_model=List[Product])
def get_products(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[str] = None,
    search: Optional[str] = None,
    sort_by: Optional[str] = "name",
    sort_order: Optional[str] = "asc"
):
    """Get list of products with filtering and pagination"""
    # Implementation would query database with filters
    pass

@app.get("/products/{product_id}", response_model=Product)
def get_product(product_id: str):
    """Get specific product by ID"""
    # Implementation would fetch product from database
    pass

@app.post("/products", response_model=Product, status_code=status.HTTP_201_CREATED)
def create_product(product: ProductCreate):
    """Create a new product"""
    # Implementation would create product in database
    pass

@app.put("/products/{product_id}", response_model=Product)
def update_product(product_id: str, product_update: ProductUpdate):
    """Update existing product"""
    # Implementation would update product in database
    pass

@app.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(product_id: str):
    """Delete product (soft delete)"""
    # Implementation would soft delete product
    pass

# Order Resource Endpoints
@app.get("/orders", response_model=List[Order])
def get_orders(
    customer_id: Optional[str] = None,
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
):
    """Get list of orders with filtering"""
    pass

@app.get("/orders/{order_id}", response_model=Order)
def get_order(order_id: str):
    """Get specific order by ID"""
    pass

@app.post("/orders", response_model=Order, status_code=status.HTTP_201_CREATED)
def create_order(order: OrderCreate):
    """Create a new order"""
    pass

@app.put("/orders/{order_id}/status", response_model=Order)
def update_order_status(order_id: str, status_update: OrderStatusUpdate):
    """Update order status"""
    pass
```

#### 2. HTTP Status Codes
**Principle**: Use appropriate HTTP status codes for different scenarios
**Implementation**:

```python
# HTTP Status Code Usage
from fastapi import HTTPException, status

# Success Responses
@app.get("/products/{product_id}", response_model=Product)
def get_product(product_id: str):
    product = product_repository.get(product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return product

@app.post("/products", response_model=Product, status_code=status.HTTP_201_CREATED)
def create_product(product: ProductCreate):
    # Validate input
    if not product.name or len(product.name) < 3:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Product name must be at least 3 characters"
        )
    
    # Check if product already exists
    existing_product = product_repository.get_by_name(product.name)
    if existing_product:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Product with this name already exists"
        )
    
    # Create product
    new_product = product_repository.create(product)
    return new_product

@app.put("/products/{product_id}", response_model=Product)
def update_product(product_id: str, product_update: ProductUpdate):
    product = product_repository.get(product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Update product
    updated_product = product_repository.update(product_id, product_update)
    return updated_product

@app.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(product_id: str):
    product = product_repository.get(product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Soft delete product
    product_repository.delete(product_id)
    return None

# Error Responses
@app.get("/products/{product_id}")
def get_product(product_id: str):
    try:
        product = product_repository.get(product_id)
        return product
    except ValidationError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid product ID: {e.message}"
        )
    except DatabaseError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )
```

#### 3. Pagination and Filtering
**Principle**: Implement consistent pagination and filtering patterns
**Implementation**:

```python
# Pagination and Filtering
from typing import Optional
from pydantic import BaseModel

class PaginationParams(BaseModel):
    skip: int = 0
    limit: int = 100
    sort_by: Optional[str] = "created_at"
    sort_order: Optional[str] = "desc"

class ProductFilters(BaseModel):
    category_id: Optional[str] = None
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    search: Optional[str] = None
    is_active: Optional[bool] = None

class PaginatedResponse(BaseModel):
    items: List[Product]
    total: int
    skip: int
    limit: int
    has_next: bool
    has_prev: bool

@app.get("/products", response_model=PaginatedResponse)
def get_products(
    pagination: PaginationParams = Depends(),
    filters: ProductFilters = Depends()
):
    """Get paginated and filtered products"""
    # Apply filters
    query = product_repository.get_query()
    
    if filters.category_id:
        query = query.filter(Product.category_id == filters.category_id)
    
    if filters.min_price:
        query = query.filter(Product.price >= filters.min_price)
    
    if filters.max_price:
        query = query.filter(Product.price <= filters.max_price)
    
    if filters.search:
        query = query.filter(Product.name.contains(filters.search))
    
    if filters.is_active is not None:
        query = query.filter(Product.is_active == filters.is_active)
    
    # Apply sorting
    if pagination.sort_by == "name":
        if pagination.sort_order == "asc":
            query = query.order_by(Product.name.asc())
        else:
            query = query.order_by(Product.name.desc())
    elif pagination.sort_by == "price":
        if pagination.sort_order == "asc":
            query = query.order_by(Product.price.asc())
        else:
            query = query.order_by(Product.price.desc())
    else:
        if pagination.sort_order == "asc":
            query = query.order_by(Product.created_at.asc())
        else:
            query = query.order_by(Product.created_at.desc())
    
    # Get total count
    total = query.count()
    
    # Apply pagination
    items = query.offset(pagination.skip).limit(pagination.limit).all()
    
    # Calculate pagination info
    has_next = pagination.skip + pagination.limit < total
    has_prev = pagination.skip > 0
    
    return PaginatedResponse(
        items=items,
        total=total,
        skip=pagination.skip,
        limit=pagination.limit,
        has_next=has_next,
        has_prev=has_prev
    )
```

## Task 2: GraphQL Schema Design

### GraphQL Schema Definition
**Implementation**: Comprehensive GraphQL schema for e-commerce platform
**Features**:
- Type definitions
- Queries and mutations
- Resolvers
- Data fetching optimization

```python
# GraphQL Schema Definition
from graphene import ObjectType, String, Int, Float, Boolean, List, Field, Mutation
from graphene_sqlalchemy import SQLAlchemyObjectType
import graphene

# Type Definitions
class ProductType(SQLAlchemyObjectType):
    class Meta:
        model = Product
        interfaces = (graphene.relay.Node,)

class CategoryType(SQLAlchemyObjectType):
    class Meta:
        model = Category
        interfaces = (graphene.relay.Node,)

class OrderType(SQLAlchemyObjectType):
    class Meta:
        model = Order
        interfaces = (graphene.relay.Node,)

class OrderItemType(SQLAlchemyObjectType):
    class Meta:
        model = OrderItem
        interfaces = (graphene.relay.Node,)

class CustomerType(SQLAlchemyObjectType):
    class Meta:
        model = Customer
        interfaces = (graphene.relay.Node,)

# Input Types
class ProductInput(graphene.InputObjectType):
    name = String(required=True)
    description = String()
    price = Float(required=True)
    category_id = String(required=True)
    stock_quantity = Int(required=True)

class OrderInput(graphene.InputObjectType):
    customer_id = String(required=True)
    items = List(graphene.InputObjectType)

class OrderItemInput(graphene.InputObjectType):
    product_id = String(required=True)
    quantity = Int(required=True)
    unit_price = Float(required=True)

# Queries
class Query(ObjectType):
    # Product queries
    products = List(ProductType, 
                   category_id=String(),
                   search=String(),
                   min_price=Float(),
                   max_price=Float(),
                   is_active=Boolean())
    
    product = Field(ProductType, product_id=String(required=True))
    
    # Category queries
    categories = List(CategoryType)
    category = Field(CategoryType, category_id=String(required=True))
    
    # Order queries
    orders = List(OrderType,
                 customer_id=String(),
                 status=String())
    
    order = Field(OrderType, order_id=String(required=True))
    
    # Customer queries
    customer = Field(CustomerType, customer_id=String(required=True))
    
    def resolve_products(self, info, category_id=None, search=None, 
                        min_price=None, max_price=None, is_active=None):
        """Resolve products with filtering"""
        query = Product.query
        
        if category_id:
            query = query.filter(Product.category_id == category_id)
        
        if search:
            query = query.filter(Product.name.contains(search))
        
        if min_price:
            query = query.filter(Product.price >= min_price)
        
        if max_price:
            query = query.filter(Product.price <= max_price)
        
        if is_active is not None:
            query = query.filter(Product.is_active == is_active)
        
        return query.all()
    
    def resolve_product(self, info, product_id):
        """Resolve single product"""
        return Product.query.get(product_id)
    
    def resolve_categories(self, info):
        """Resolve all categories"""
        return Category.query.all()
    
    def resolve_category(self, info, category_id):
        """Resolve single category"""
        return Category.query.get(category_id)
    
    def resolve_orders(self, info, customer_id=None, status=None):
        """Resolve orders with filtering"""
        query = Order.query
        
        if customer_id:
            query = query.filter(Order.customer_id == customer_id)
        
        if status:
            query = query.filter(Order.status == status)
        
        return query.all()
    
    def resolve_order(self, info, order_id):
        """Resolve single order"""
        return Order.query.get(order_id)
    
    def resolve_customer(self, info, customer_id):
        """Resolve single customer"""
        return Customer.query.get(customer_id)

# Mutations
class CreateProduct(Mutation):
    class Arguments:
        product_data = ProductInput(required=True)
    
    product = Field(ProductType)
    
    def mutate(self, info, product_data):
        """Create new product"""
        product = Product(
            name=product_data.name,
            description=product_data.description,
            price=product_data.price,
            category_id=product_data.category_id,
            stock_quantity=product_data.stock_quantity
        )
        
        db.session.add(product)
        db.session.commit()
        
        return CreateProduct(product=product)

class UpdateProduct(Mutation):
    class Arguments:
        product_id = String(required=True)
        product_data = ProductInput(required=True)
    
    product = Field(ProductType)
    
    def mutate(self, info, product_id, product_data):
        """Update existing product"""
        product = Product.query.get(product_id)
        if not product:
            raise Exception("Product not found")
        
        # Update product fields
        product.name = product_data.name
        product.description = product_data.description
        product.price = product_data.price
        product.category_id = product_data.category_id
        product.stock_quantity = product_data.stock_quantity
        
        db.session.commit()
        
        return UpdateProduct(product=product)

class CreateOrder(Mutation):
    class Arguments:
        order_data = OrderInput(required=True)
    
    order = Field(OrderType)
    
    def mutate(self, info, order_data):
        """Create new order"""
        order = Order(
            customer_id=order_data.customer_id,
            status="PENDING"
        )
        
        db.session.add(order)
        db.session.flush()  # Get order ID
        
        # Add order items
        total_amount = 0
        for item_data in order_data.items:
            order_item = OrderItem(
                order_id=order.id,
                product_id=item_data.product_id,
                quantity=item_data.quantity,
                unit_price=item_data.unit_price,
                total_price=item_data.quantity * item_data.unit_price
            )
            db.session.add(order_item)
            total_amount += order_item.total_price
        
        order.total_amount = total_amount
        db.session.commit()
        
        return CreateOrder(order=order)

class Mutation(ObjectType):
    create_product = CreateProduct.Field()
    update_product = UpdateProduct.Field()
    create_order = CreateOrder.Field()

# Schema
schema = graphene.Schema(query=Query, mutation=Mutation)
```

## Task 3: gRPC Service Design

### gRPC Service Definition
**Implementation**: High-performance gRPC services for internal communication
**Features**:
- Protocol buffer definitions
- Service implementations
- Error handling
- Performance optimization

```protobuf
// Product Service gRPC Definition
syntax = "proto3";

package product;

import "google/protobuf/timestamp.proto";

service ProductService {
    rpc GetProduct(GetProductRequest) returns (GetProductResponse);
    rpc ListProducts(ListProductsRequest) returns (ListProductsResponse);
    rpc CreateProduct(CreateProductRequest) returns (CreateProductResponse);
    rpc UpdateProduct(UpdateProductRequest) returns (UpdateProductResponse);
    rpc DeleteProduct(DeleteProductRequest) returns (DeleteProductResponse);
    rpc SearchProducts(SearchProductsRequest) returns (SearchProductsResponse);
}

message Product {
    string id = 1;
    string name = 2;
    string description = 3;
    double price = 4;
    string category_id = 5;
    int32 stock_quantity = 6;
    bool is_active = 7;
    google.protobuf.Timestamp created_at = 8;
    google.protobuf.Timestamp updated_at = 9;
}

message GetProductRequest {
    string product_id = 1;
}

message GetProductResponse {
    Product product = 1;
    string error_message = 2;
}

message ListProductsRequest {
    int32 skip = 1;
    int32 limit = 2;
    string category_id = 3;
    double min_price = 4;
    double max_price = 5;
    bool is_active = 6;
}

message ListProductsResponse {
    repeated Product products = 1;
    int32 total_count = 2;
    string error_message = 3;
}

message CreateProductRequest {
    string name = 1;
    string description = 2;
    double price = 3;
    string category_id = 4;
    int32 stock_quantity = 5;
}

message CreateProductResponse {
    Product product = 1;
    string error_message = 2;
}

message UpdateProductRequest {
    string product_id = 1;
    string name = 2;
    string description = 3;
    double price = 4;
    string category_id = 5;
    int32 stock_quantity = 6;
}

message UpdateProductResponse {
    Product product = 1;
    string error_message = 2;
}

message DeleteProductRequest {
    string product_id = 1;
}

message DeleteProductResponse {
    bool success = 1;
    string error_message = 2;
}

message SearchProductsRequest {
    string query = 1;
    int32 skip = 2;
    int32 limit = 3;
}

message SearchProductsResponse {
    repeated Product products = 1;
    int32 total_count = 2;
    string error_message = 3;
}
```

### gRPC Service Implementation

```python
# gRPC Service Implementation
import grpc
from concurrent import futures
from product_pb2 import *
from product_pb2_grpc import ProductServiceServicer

class ProductServiceImplementation(ProductServiceServicer):
    def __init__(self, product_repository):
        self._product_repository = product_repository
    
    def GetProduct(self, request, context):
        """Get single product by ID"""
        try:
            product = self._product_repository.get(request.product_id)
            if not product:
                context.set_code(grpc.StatusCode.NOT_FOUND)
                context.set_details("Product not found")
                return GetProductResponse(error_message="Product not found")
            
            return GetProductResponse(product=product)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return GetProductResponse(error_message=str(e))
    
    def ListProducts(self, request, context):
        """List products with filtering"""
        try:
            products = self._product_repository.list(
                skip=request.skip,
                limit=request.limit,
                category_id=request.category_id,
                min_price=request.min_price,
                max_price=request.max_price,
                is_active=request.is_active
            )
            
            total_count = self._product_repository.count(
                category_id=request.category_id,
                min_price=request.min_price,
                max_price=request.max_price,
                is_active=request.is_active
            )
            
            return ListProductsResponse(
                products=products,
                total_count=total_count
            )
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return ListProductsResponse(error_message=str(e))
    
    def CreateProduct(self, request, context):
        """Create new product"""
        try:
            product = self._product_repository.create(
                name=request.name,
                description=request.description,
                price=request.price,
                category_id=request.category_id,
                stock_quantity=request.stock_quantity
            )
            
            return CreateProductResponse(product=product)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return CreateProductResponse(error_message=str(e))
    
    def UpdateProduct(self, request, context):
        """Update existing product"""
        try:
            product = self._product_repository.update(
                product_id=request.product_id,
                name=request.name,
                description=request.description,
                price=request.price,
                category_id=request.category_id,
                stock_quantity=request.stock_quantity
            )
            
            return UpdateProductResponse(product=product)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return UpdateProductResponse(error_message=str(e))
    
    def DeleteProduct(self, request, context):
        """Delete product"""
        try:
            success = self._product_repository.delete(request.product_id)
            return DeleteProductResponse(success=success)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return DeleteProductResponse(error_message=str(e))
    
    def SearchProducts(self, request, context):
        """Search products"""
        try:
            products = self._product_repository.search(
                query=request.query,
                skip=request.skip,
                limit=request.limit
            )
            
            total_count = self._product_repository.search_count(request.query)
            
            return SearchProductsResponse(
                products=products,
                total_count=total_count
            )
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(str(e))
            return SearchProductsResponse(error_message=str(e))

# gRPC Server Setup
def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    product_service = ProductServiceImplementation(product_repository)
    add_ProductServiceServicer_to_server(product_service, server)
    
    server.add_insecure_port('[::]:50051')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
```

## Task 4: API Versioning Strategy

### API Versioning Implementation
**Strategy**: URL-based versioning with backward compatibility
**Features**:
- Version management
- Backward compatibility
- Deprecation handling
- Migration support

```python
# API Versioning Implementation
from fastapi import FastAPI, APIRouter, Depends, HTTPException
from typing import Dict, Any
import json

# Version 1 API
v1_router = APIRouter(prefix="/api/v1")

@v1_router.get("/products")
def get_products_v1():
    """Version 1 products endpoint"""
    return {"version": "1.0", "products": []}

@v1_router.get("/products/{product_id}")
def get_product_v1(product_id: str):
    """Version 1 product endpoint"""
    return {"version": "1.0", "product_id": product_id}

# Version 2 API
v2_router = APIRouter(prefix="/api/v2")

@v2_router.get("/products")
def get_products_v2():
    """Version 2 products endpoint with enhanced features"""
    return {"version": "2.0", "products": [], "enhanced": True}

@v2_router.get("/products/{product_id}")
def get_product_v2(product_id: str):
    """Version 2 product endpoint with enhanced features"""
    return {"version": "2.0", "product_id": product_id, "enhanced": True}

# Version 3 API
v3_router = APIRouter(prefix="/api/v3")

@v3_router.get("/products")
def get_products_v3():
    """Version 3 products endpoint with latest features"""
    return {"version": "3.0", "products": [], "latest": True}

@v3_router.get("/products/{product_id}")
def get_product_v3(product_id: str):
    """Version 3 product endpoint with latest features"""
    return {"version": "3.0", "product_id": product_id, "latest": True}

# Main FastAPI app
app = FastAPI(title="E-commerce API", version="3.0.0")

# Include version routers
app.include_router(v1_router, tags=["v1"])
app.include_router(v2_router, tags=["v2"])
app.include_router(v3_router, tags=["v3"])

# Version deprecation handling
@app.middleware("http")
async def version_deprecation_middleware(request, call_next):
    """Handle version deprecation warnings"""
    response = await call_next(request)
    
    # Add deprecation warning for v1
    if request.url.path.startswith("/api/v1"):
        response.headers["Warning"] = "299 - This API version is deprecated. Please upgrade to v3."
        response.headers["Sunset"] = "2024-12-31"
    
    # Add deprecation warning for v2
    elif request.url.path.startswith("/api/v2"):
        response.headers["Warning"] = "299 - This API version is deprecated. Please upgrade to v3."
        response.headers["Sunset"] = "2025-06-30"
    
    return response

# Version migration support
class VersionMigration:
    def __init__(self):
        self._migration_rules = {
            "v1_to_v2": self._migrate_v1_to_v2,
            "v2_to_v3": self._migrate_v2_to_v3
        }
    
    def migrate_data(self, from_version: str, to_version: str, data: Dict[Any, Any]) -> Dict[Any, Any]:
        """Migrate data between API versions"""
        migration_key = f"{from_version}_to_{to_version}"
        
        if migration_key in self._migration_rules:
            return self._migration_rules[migration_key](data)
        
        return data
    
    def _migrate_v1_to_v2(self, data: Dict[Any, Any]) -> Dict[Any, Any]:
        """Migrate data from v1 to v2"""
        # Add enhanced fields
        data["enhanced"] = True
        data["version"] = "2.0"
        return data
    
    def _migrate_v2_to_v3(self, data: Dict[Any, Any]) -> Dict[Any, Any]:
        """Migrate data from v2 to v3"""
        # Add latest fields
        data["latest"] = True
        data["version"] = "3.0"
        return data

# API Gateway Integration
class APIGatewayIntegration:
    def __init__(self):
        self._version_routing = {
            "v1": "http://product-service-v1:8000",
            "v2": "http://product-service-v2:8000",
            "v3": "http://product-service-v3:8000"
        }
    
    def route_request(self, version: str, path: str, method: str, data: Dict[Any, Any] = None):
        """Route request to appropriate service version"""
        if version not in self._version_routing:
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported API version: {version}"
            )
        
        service_url = self._version_routing[version]
        
        # Route request to appropriate service
        # Implementation would use HTTP client to forward request
        pass
```

## Best Practices Applied

### RESTful API Design
1. **Resource-Based URLs**: URLs represent resources, not actions
2. **HTTP Methods**: Use appropriate HTTP methods (GET, POST, PUT, DELETE)
3. **Status Codes**: Use appropriate HTTP status codes
4. **Pagination**: Implement consistent pagination patterns
5. **Filtering**: Provide flexible filtering options

### GraphQL Design
1. **Schema-First**: Design schema before implementation
2. **Type Safety**: Use strong typing for all fields
3. **Resolver Optimization**: Optimize data fetching in resolvers
4. **Error Handling**: Implement comprehensive error handling
5. **Documentation**: Provide comprehensive schema documentation

### gRPC Design
1. **Protocol Buffers**: Use efficient binary serialization
2. **Service Definition**: Define clear service interfaces
3. **Error Handling**: Use gRPC status codes appropriately
4. **Performance**: Optimize for high-performance communication
5. **Streaming**: Use streaming for large data sets

### API Versioning
1. **Backward Compatibility**: Maintain backward compatibility
2. **Deprecation Strategy**: Plan for API deprecation
3. **Migration Support**: Provide migration tools and documentation
4. **Version Discovery**: Make version information easily discoverable
5. **Sunset Dates**: Communicate sunset dates clearly

## Lessons Learned

### Key Insights
1. **API Design**: Good API design is crucial for adoption
2. **Versioning**: Plan for API evolution from the start
3. **Documentation**: Comprehensive documentation is essential
4. **Performance**: Consider performance implications of API design
5. **Consistency**: Maintain consistency across all APIs

### Common Pitfalls
1. **Poor URL Design**: Don't use action-based URLs
2. **Inconsistent Patterns**: Don't mix different API patterns
3. **No Versioning**: Don't skip API versioning
4. **Poor Error Handling**: Don't ignore error handling
5. **No Documentation**: Don't skip API documentation

### Recommendations
1. **Start with REST**: Begin with RESTful APIs
2. **Add GraphQL**: Add GraphQL for flexible queries
3. **Use gRPC**: Use gRPC for internal communication
4. **Plan Versioning**: Plan for API versioning from the start
5. **Document Everything**: Document all APIs comprehensively

## Next Steps

1. **Implementation**: Implement the API designs
2. **Testing**: Test all API endpoints thoroughly
3. **Documentation**: Create comprehensive API documentation
4. **Versioning**: Implement API versioning strategy
5. **Monitoring**: Set up API monitoring and analytics
