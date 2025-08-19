from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, Float, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class Product(Base):
    __tablename__ = "products"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    slug = Column(String, unique=True, index=True, nullable=False)
    description = Column(Text, nullable=True)
    short_description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    compare_price = Column(Float, nullable=True)  # Original price for discounts
    cost_price = Column(Float, nullable=True)
    sku = Column(String, unique=True, index=True, nullable=False)
    barcode = Column(String, nullable=True)
    quantity = Column(Integer, default=0)
    min_quantity = Column(Integer, default=1)
    track_quantity = Column(Boolean, default=True)
    continue_selling = Column(Boolean, default=False)  # Allow selling when out of stock
    is_active = Column(Boolean, default=True)
    is_featured = Column(Boolean, default=False)
    weight = Column(Float, nullable=True)
    dimensions = Column(JSON, nullable=True)  # {"length": 10, "width": 5, "height": 3}
    images = Column(JSON, nullable=True)  # Array of image URLs
    tags = Column(JSON, nullable=True)  # Array of tags
    meta_title = Column(String, nullable=True)
    meta_description = Column(Text, nullable=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Foreign Keys
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    
    # Relationships
    category = relationship("Category", back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")
    cart_items = relationship("CartItem", back_populates="product")
    
    def __repr__(self):
        return f"<Product(id={self.id}, name='{self.name}', price={self.price})>"
    
    @property
    def is_in_stock(self):
        if not self.track_quantity:
            return True
        return self.quantity > 0 or self.continue_selling
    
    @property
    def discount_percentage(self):
        if self.compare_price and self.compare_price > self.price:
            return round(((self.compare_price - self.price) / self.compare_price) * 100, 2)
        return 0
