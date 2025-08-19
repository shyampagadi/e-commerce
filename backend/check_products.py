#!/usr/bin/env python3
"""
Check products in the database
"""

from app.database import engine
from app.models import Product
from sqlalchemy.orm import sessionmaker

def check_products():
    """Check products in the database"""
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        products = db.query(Product).all()
        print(f"Found {len(products)} products")
        
        for product in products:
            print(f"Product: {product.name}")
            print(f"  - ID: {product.id}")
            print(f"  - Slug: {product.slug}")
            print(f"  - Images: {product.images}")
            print()
    finally:
        db.close()

if __name__ == "__main__":
    check_products()
