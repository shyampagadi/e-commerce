#!/usr/bin/env python3
"""
Update product images in the database
"""

from app.database import engine
from app.models import Product
from sqlalchemy.orm import sessionmaker

def update_product_images():
    """Update product images in the database"""
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        # Define image paths for each product
        product_images = {
            "iphone-15-pro": ["products/iphone15pro.jpg", "products/iphone15pro_2.jpg"],
            "samsung-galaxy-s24": ["products/galaxys24.jpg", "products/galaxys24_2.jpg"],
            "macbook-air-m3": ["products/macbookair.jpg", "products/macbookair_2.jpg"],
            "sony-wh-1000xm5": ["products/sonywh1000xm5.jpg", "products/sonywh1000xm5_2.jpg"],
            "classic-denim-jacket": ["products/denimjacket.jpg", "products/denimjacket_2.jpg"],
            "premium-cotton-t-shirt": ["products/cottontshirt.jpg", "products/cottontshirt_2.jpg"],
            "smart-home-security-camera": ["products/securitycamera.jpg", "products/securitycamera_2.jpg"],
            "ceramic-plant-pot-set": ["products/plantpots.jpg", "products/plantpots_2.jpg"],
            "professional-yoga-mat": ["products/yogamat.jpg", "products/yogamat_2.jpg"],
            "camping-backpack-50l": ["products/campingbackpack.jpg", "products/campingbackpack_2.jpg"]
        }
        
        # Update each product
        for slug, images in product_images.items():
            product = db.query(Product).filter(Product.slug == slug).first()
            if product:
                print(f"Updating product: {product.name}")
                product.images = images
                db.add(product)
            else:
                print(f"Product with slug '{slug}' not found")
        
        # Commit changes
        db.commit()
        print("✅ Product images updated successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error updating product images: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    update_product_images()
