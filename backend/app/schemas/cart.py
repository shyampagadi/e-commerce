from pydantic import BaseModel, validator
from typing import List, Optional, Dict, Any
from datetime import datetime

class CartItemBase(BaseModel):
    product_id: int
    quantity: int
    
    @validator('quantity')
    def validate_quantity(cls, v):
        if v <= 0:
            raise ValueError('Quantity must be greater than 0')
        return v

class CartItemCreate(CartItemBase):
    pass

class CartItemUpdate(BaseModel):
    quantity: int
    
    @validator('quantity')
    def validate_quantity(cls, v):
        if v <= 0:
            raise ValueError('Quantity must be greater than 0')
        return v

class CartItemResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    product: Optional[Dict[str, Any]] = None  # Product details
    
    class Config:
        from_attributes = True

class CartResponse(BaseModel):
    items: List[CartItemResponse]
    total_items: int
    subtotal: float
    
class CartSummary(BaseModel):
    total_items: int
    subtotal: float
