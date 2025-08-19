#!/usr/bin/env python3
"""
Database initialization script for E-Commerce application.
This script creates the database tables and populates them with sample data.
"""

import os
import sys
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from faker import Faker

# Add the app directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import Base, engine
from app.models import User, Category, Product, Order, OrderItem, CartItem
from app.utils.auth import get_password_hash
from app.utils.slug import create_slug

fake = Faker()

def create_tables():
    """Create all database tables."""
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("[SUCCESS] Database tables created successfully!")

def create_sample_data():
    """Create sample data for the application."""
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        print("Creating sample data...")
        
        # Check if admin user already exists
        existing_admin = db.query(User).filter(User.username == "admin").first()
        if existing_admin:
            print("[INFO] Admin user already exists, skipping user creation")
        else:
            # Create admin user
            admin_user = User(
                email="admin@ecommerce.com",
                username="admin",
                first_name="Admin",
                last_name="User",
                hashed_password=get_password_hash("admin123"),
                is_active=True,
                is_admin=True,
                phone="+1-555-0123",
                address="123 Admin Street",
                city="New York",
                state="NY",
                zip_code="10001",
                country="USA"
            )
            db.add(admin_user)
            
            # Create regular user
            regular_user = User(
                email="user@ecommerce.com",
                username="user",
                first_name="John",
                last_name="Doe",
                hashed_password=get_password_hash("user123"),
                is_active=True,
                is_admin=False,
                phone="+1-555-0456",
                address="456 User Avenue",
                city="Los Angeles",
                state="CA",
                zip_code="90210",
                country="USA"
            )
            db.add(regular_user)
            
            # Create sample users
            for i in range(10):
                user = User(
                    email=fake.email(),
                    username=fake.user_name() + str(i),
                    first_name=fake.first_name(),
                    last_name=fake.last_name(),
                    hashed_password=get_password_hash("password123"),
                    is_active=True,
                    is_admin=False,
                    phone=fake.phone_number(),
                    address=fake.street_address(),
                    city=fake.city(),
                    state=fake.state_abbr(),
                    zip_code=fake.zipcode(),
                    country="USA"
                )
                db.add(user)
            
            db.commit()
            print("[SUCCESS] Users created successfully!")
        
        # Check if categories already exist
        existing_categories = db.query(Category).first()
        if existing_categories:
            print("[INFO] Categories already exist, using existing categories")
            categories = db.query(Category).all()
        else:
            # Create categories
            categories_data = [
                {
                    "name": "Electronics",
                    "description": "Latest gadgets and electronic devices",
                    "sort_order": 1
                },
                {
                    "name": "Clothing",
                    "description": "Fashion and apparel for all occasions",
                    "sort_order": 2
                },
                {
                    "name": "Home & Garden",
                    "description": "Everything for your home and garden",
                    "sort_order": 3
                },
                {
                    "name": "Sports & Outdoors",
                    "description": "Sports equipment and outdoor gear",
                    "sort_order": 4
                },
                {
                    "name": "Books",
                    "description": "Books, magazines, and educational materials",
                    "sort_order": 5
                },
                {
                    "name": "Health & Beauty",
                    "description": "Health, beauty, and personal care products",
                    "sort_order": 6
                },
                {
                    "name": "Toys & Games",
                    "description": "Toys, games, and entertainment for all ages",
                    "sort_order": 7
                },
                {
                    "name": "Automotive",
                    "description": "Car parts, accessories, and automotive tools",
                    "sort_order": 8
                }
            ]
            
            categories = []
            for cat_data in categories_data:
                category = Category(
                    name=cat_data["name"],
                    slug=create_slug(cat_data["name"]),
                    description=cat_data["description"],
                    is_active=True,
                    sort_order=cat_data["sort_order"]
                )
                db.add(category)
                categories.append(category)
            
            db.commit()
            print("[SUCCESS] Categories created successfully!")
        
        # Create products
        products_data = [
            # Electronics
            {
                "name": "iPhone 15 Pro",
                "description": "The latest iPhone with advanced camera system and A17 Pro chip. Features include a 6.1-inch Super Retina XDR display, A17 Pro chip with 6-core CPU and 5-core GPU, Pro camera system with 48MP main camera, and all-day battery life.",
                "short_description": "Latest iPhone with pro camera system",
                "price": 999.99,
                "compare_price": 1099.99,
                "cost_price": 750.00,
                "sku": "IPH15PRO001",
                "category": "Electronics",
                "is_featured": True,
                "quantity": 50,
                "images": ["products/iphone15pro.jpg", "products/iphone15pro_2.jpg"]
            },
            {
                "name": "Samsung Galaxy S24",
                "description": "Flagship Android phone with AI-powered features. The Galaxy S24 features a stunning 6.2-inch Dynamic AMOLED 2X display, Snapdragon 8 Gen 3 processor, 50MP triple camera system, and 4,000mAh battery with fast charging.",
                "short_description": "AI-powered flagship Android phone",
                "price": 899.99,
                "compare_price": 999.99,
                "cost_price": 650.00,
                "sku": "SGS24001",
                "category": "Electronics",
                "is_featured": True,
                "quantity": 30,
                "images": ["products/galaxys24.jpg", "products/galaxys24_2.jpg"]
            },
            {
                "name": "MacBook Air M3",
                "description": "Ultra-thin laptop with M3 chip and all-day battery life. The MacBook Air features a 13.6-inch Liquid Retina display, M3 chip with 8-core CPU and 10-core GPU, 8GB unified memory, and up to 18 hours of battery life.",
                "short_description": "Ultra-thin laptop with M3 chip",
                "price": 1299.99,
                "cost_price": 950.00,
                "sku": "MBA15M3001",
                "category": "Electronics",
                "is_featured": True,
                "quantity": 25,
                "images": ["products/macbookair.jpg", "products/macbookair_2.jpg"]
            },
            {
                "name": "Sony WH-1000XM5",
                "description": "Industry-leading noise canceling wireless headphones. The Sony WH-1000XM5 features industry-leading noise cancellation, 30-hour battery life, premium sound quality, and comfortable design for all-day wear.",
                "short_description": "Premium noise canceling headphones",
                "price": 349.99,
                "compare_price": 399.99,
                "cost_price": 200.00,
                "sku": "SWXM5001",
                "category": "Electronics",
                "quantity": 75,
                "images": ["products/sonywh1000xm5.jpg", "products/sonywh1000xm5_2.jpg"]
            },
            
            # Clothing
            {
                "name": "Classic Denim Jacket",
                "description": "Timeless denim jacket perfect for any season. Made from premium denim fabric, this jacket features a comfortable fit, button closure, and multiple pockets. It's versatile enough to pair with any outfit.",
                "short_description": "Timeless denim jacket",
                "price": 79.99,
                "compare_price": 99.99,
                "cost_price": 35.00,
                "sku": "CDJ001",
                "category": "Clothing",
                "is_featured": True,
                "quantity": 100,
                "images": ["products/denimjacket.jpg", "products/denimjacket_2.jpg"]
            },
            {
                "name": "Premium Cotton T-Shirt",
                "description": "Soft, comfortable cotton t-shirt in various colors. Made from 100% organic cotton, this t-shirt is breathable, durable, and perfect for everyday wear. Available in multiple colors and sizes.",
                "short_description": "Premium cotton t-shirt",
                "price": 24.99,
                "cost_price": 8.00,
                "sku": "PCT001",
                "category": "Clothing",
                "quantity": 200,
                "images": ["products/cottontshirt.jpg", "products/cottontshirt_2.jpg"]
            },
            
            # Home & Garden
            {
                "name": "Smart Home Security Camera",
                "description": "WiFi security camera with night vision and mobile app. This smart camera features 1080p HD video, two-way audio, motion detection, and night vision. It connects to your smartphone for real-time monitoring.",
                "short_description": "WiFi security camera with night vision",
                "price": 129.99,
                "compare_price": 159.99,
                "cost_price": 65.00,
                "sku": "SHSC001",
                "category": "Home & Garden",
                "is_featured": True,
                "quantity": 40,
                "images": ["products/securitycamera.jpg", "products/securitycamera_2.jpg"]
            },
            {
                "name": "Ceramic Plant Pot Set",
                "description": "Set of 3 decorative ceramic plant pots. These elegant pots come in small, medium, and large sizes, perfect for indoor plants. They feature a drainage hole and a modern, minimalist design.",
                "short_description": "Set of 3 decorative plant pots",
                "price": 39.99,
                "cost_price": 15.00,
                "sku": "CPPS001",
                "category": "Home & Garden",
                "quantity": 60,
                "images": ["products/plantpots.jpg", "products/plantpots_2.jpg"]
            },
            
            # Sports & Outdoors
            {
                "name": "Professional Yoga Mat",
                "description": "Non-slip yoga mat with alignment guides. This premium yoga mat is 6mm thick for extra comfort, features alignment marks to help with proper positioning, and has a non-slip surface for safety during practice.",
                "short_description": "Non-slip yoga mat with guides",
                "price": 49.99,
                "compare_price": 69.99,
                "cost_price": 20.00,
                "sku": "PYM001",
                "category": "Sports & Outdoors",
                "quantity": 80,
                "images": ["products/yogamat.jpg", "products/yogamat_2.jpg"]
            },
            {
                "name": "Camping Backpack 50L",
                "description": "Durable hiking backpack with multiple compartments. This 50L backpack is made from water-resistant material, has adjustable straps for comfort, and features multiple compartments for organized storage during your outdoor adventures.",
                "short_description": "50L hiking backpack",
                "price": 149.99,
                "cost_price": 75.00,
                "sku": "CBP50001",
                "category": "Sports & Outdoors",
                "is_featured": True,
                "quantity": 35,
                "images": ["products/campingbackpack.jpg", "products/campingbackpack_2.jpg"]
            }
        ]
        
        # Check if products already exist
        existing_products = db.query(Product).first()
        if existing_products:
            print("[INFO] Products already exist, skipping product creation")
        else:
            # Create category lookup
            category_lookup = {cat.name: cat for cat in categories}
            
            for prod_data in products_data:
                category = category_lookup[prod_data["category"]]
                
                # Make sure to include images
                images = prod_data.get("images", [])
                
                product = Product(
                    name=prod_data["name"],
                    slug=create_slug(prod_data["name"]),
                    description=prod_data["description"],
                    short_description=prod_data["short_description"],
                    price=prod_data["price"],
                    compare_price=prod_data.get("compare_price"),
                    cost_price=prod_data["cost_price"],
                    sku=prod_data["sku"],
                    quantity=prod_data["quantity"],
                    is_active=True,
                    is_featured=prod_data.get("is_featured", False),
                    category_id=category.id,
                    images=images,  # Make sure images are set properly
                    tags=["popular", "bestseller"] if prod_data.get("is_featured") else ["new"],
                    meta_title=prod_data["name"],
                    meta_description=prod_data["short_description"]
                )
                db.add(product)
            
            db.commit()
            print("[SUCCESS] Products created successfully!")
        
        
        print("[SUCCESS] Sample data created successfully!")
        print("\n" + "="*50)
        print("DATABASE INITIALIZATION COMPLETE!")
        print("="*50)
        print("\n[EMAIL] Admin Login:")
        print("   Email: admin@ecommerce.com")
        print("   Password: admin123")
        print("\n[USER] User Login:")
        print("   Email: user@ecommerce.com")
        print("   Password: user123")
        print("\n[ROCKET] You can now start the application!")
        
    except Exception as e:
        print(f"[ERROR] Error creating sample data: {e}")
        db.rollback()
        raise
    finally:
        db.close()

def main():
    """Main function to initialize the database."""
    print("[ROCKET] Initializing E-Commerce Database...")
    print("="*50)
    
    try:
        # Create tables
        create_tables()
        
        # Create sample data
        create_sample_data()
        
    except Exception as e:
        print(f"[ERROR] Database initialization failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
