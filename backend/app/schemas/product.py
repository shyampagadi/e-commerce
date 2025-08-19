from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from datetime import datetime

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    short_description: Optional[str] = None
    price: float
    compare_price: Optional[float] = None
    cost_price: Optional[float] = None
    sku: str
    barcode: Optional[str] = None
    quantity: int = 0
    min_quantity: int = 1
    track_quantity: bool = True
    continue_selling: bool = False
    is_active: bool = True
    is_featured: bool = False
    weight: Optional[float] = None
    dimensions: Optional[Dict[str, float]] = None
    tags: Optional[List[str]] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    sort_order: int = 0
    category_id: int

class ProductCreate(ProductBase):
    @validator('name')
    def validate_name(cls, v):
        if len(v.strip()) < 2:
            raise ValueError('Product name must be at least 2 characters long')
        return v.strip()
    
    @validator('price')
    def validate_price(cls, v):
        if v <= 0:
            raise ValueError('Price must be greater than 0')
        return v
    
    @validator('sku')
    def validate_sku(cls, v):
        if len(v.strip()) < 2:
            raise ValueError('SKU must be at least 2 characters long')
        return v.strip().upper()

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    short_description: Optional[str] = None
    price: Optional[float] = None
    compare_price: Optional[float] = None
    cost_price: Optional[float] = None
    sku: Optional[str] = None
    barcode: Optional[str] = None
    quantity: Optional[int] = None
    min_quantity: Optional[int] = None
    track_quantity: Optional[bool] = None
    continue_selling: Optional[bool] = None
    is_active: Optional[bool] = None
    is_featured: Optional[bool] = None
    weight: Optional[float] = None
    dimensions: Optional[Dict[str, float]] = None
    tags: Optional[List[str]] = None
    meta_title: Optional[str] = None
    meta_description: Optional[str] = None
    sort_order: Optional[int] = None
    category_id: Optional[int] = None
    
    @validator('name')
    def validate_name(cls, v):
        if v is not None and len(v.strip()) < 2:
            raise ValueError('Product name must be at least 2 characters long')
        return v.strip() if v else v
    
    @validator('price')
    def validate_price(cls, v):
        if v is not None and v <= 0:
            raise ValueError('Price must be greater than 0')
        return v
    
    @validator('sku')
    def validate_sku(cls, v):
        if v is not None and len(v.strip()) < 2:
            raise ValueError('SKU must be at least 2 characters long')
        return v.strip().upper() if v else v

class ProductResponse(ProductBase):
    id: int
    slug: str
    images: Optional[List[str]] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_in_stock: bool
    discount_percentage: float
    
    class Config:
        from_attributes = True

class ProductWithCategory(ProductResponse):
    category: Optional[Dict[str, Any]] = None

class ProductListResponse(BaseModel):
    products: List[ProductWithCategory]
    total: int
    page: int
    per_page: int
    pages: int
