from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import datetime
from app.models.order import OrderStatus, PaymentStatus

class OrderItemBase(BaseModel):
    product_id: int
    quantity: int
    
    @validator('quantity')
    def validate_quantity(cls, v):
        if v <= 0:
            raise ValueError('Quantity must be greater than 0')
        return v

class OrderItemCreate(OrderItemBase):
    pass

class OrderItemResponse(BaseModel):
    id: int
    product_id: int
    product_name: str
    product_sku: str
    product_image: Optional[str] = None
    quantity: int
    unit_price: float
    total_price: float
    created_at: datetime
    
    class Config:
        from_attributes = True

class ShippingAddress(BaseModel):
    first_name: str
    last_name: str
    address: str
    city: str
    state: str
    zip_code: str
    country: str
    
    @validator('first_name', 'last_name', 'address', 'city', 'state', 'zip_code', 'country')
    def validate_required_fields(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('This field is required')
        return v.strip()

class BillingAddress(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None
    country: Optional[str] = None

class OrderCreate(BaseModel):
    items: List[OrderItemCreate]
    customer_email: EmailStr
    customer_phone: Optional[str] = None
    shipping_address: ShippingAddress
    billing_address: Optional[BillingAddress] = None
    notes: Optional[str] = None
    
    @validator('items')
    def validate_items(cls, v):
        if not v or len(v) == 0:
            raise ValueError('Order must contain at least one item')
        return v

class OrderUpdate(BaseModel):
    status: Optional[OrderStatus] = None
    payment_status: Optional[PaymentStatus] = None
    tracking_number: Optional[str] = None
    notes: Optional[str] = None

class OrderResponse(BaseModel):
    id: int
    order_number: str
    status: OrderStatus
    payment_status: PaymentStatus
    subtotal: float
    tax_amount: float
    shipping_amount: float
    discount_amount: float
    total_amount: float
    customer_email: str
    customer_phone: Optional[str] = None
    shipping_first_name: str
    shipping_last_name: str
    shipping_address: str
    shipping_city: str
    shipping_state: str
    shipping_zip_code: str
    shipping_country: str
    billing_first_name: Optional[str] = None
    billing_last_name: Optional[str] = None
    billing_address: Optional[str] = None
    billing_city: Optional[str] = None
    billing_state: Optional[str] = None
    billing_zip_code: Optional[str] = None
    billing_country: Optional[str] = None
    notes: Optional[str] = None
    tracking_number: Optional[str] = None
    shipped_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    user_id: Optional[int] = None
    
    class Config:
        from_attributes = True

class OrderWithItems(OrderResponse):
    order_items: List[OrderItemResponse] = []

class OrderListResponse(BaseModel):
    orders: List[OrderResponse]
    total: int
    page: int
    per_page: int
    pages: int
