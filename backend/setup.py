#!/usr/bin/env python3
"""
Comprehensive Database Setup Script for E-Commerce Application

Usage:
    python database/setup.py --all                  # Full setup (validate + sample data + images)
    python database/setup.py --validate             # Validate database connection
    python database/setup.py --init-clean          # Initialize clean database
    python database/setup.py --init-sample         # Initialize with sample data
    python database/setup.py --download-images     # Download sample images
    python database/setup.py --reset               # Reset database
"""

import os
import sys
import argparse
import requests
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(env_path)

# Add backend to path for imports
backend_path = Path(__file__).parent.parent / "backend"
sys.path.insert(0, str(backend_path))

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 5432)),
    'database': os.getenv('DB_NAME', 'ecommerce_db'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'admin')
}

DATABASE_URL = os.getenv('DATABASE_URL') or f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"

def print_header(title):
    """Print formatted header"""
    print(f"\n{'='*60}")
    print(f"🚀 {title}")
    print(f"{'='*60}")

def print_success(message):
    """Print success message"""
    print(f"✅ {message}")

def print_error(message):
    """Print error message"""
    print(f"❌ {message}")

def print_info(message):
    """Print info message"""
    print(f"📋 {message}")

def validate_env_config():
    """Validate that all required environment variables are set"""
    required_vars = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'DATABASE_URL']
    missing_vars = []
    
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        print_error("Missing required environment variables:")
        for var in missing_vars:
            print_error(f"  - {var}")
        print_info("Please check your .env file in the project root directory")
        return False
    
    return True

def validate_database():
    """Validate PostgreSQL database connection"""
    print_header("Database Validation")
    
    if not validate_env_config():
        return False
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print_success(f"PostgreSQL connection successful")
        print_info(f"Version: {version.split(',')[0]}")
        
        cursor.execute("SELECT datname FROM pg_database WHERE datname = %s;", (DB_CONFIG['database'],))
        if cursor.fetchone():
            print_success(f"Database '{DB_CONFIG['database']}' exists")
        else:
            print_error(f"Database '{DB_CONFIG['database']}' not found")
            return False
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS test_connection (
                id SERIAL PRIMARY KEY,
                test_field VARCHAR(50)
            );
        """)
        cursor.execute("DROP TABLE IF EXISTS test_connection;")
        print_success("Database permissions verified")
        
        cursor.close()
        conn.close()
        
        print_success("Database validation completed successfully!")
        return True
        
    except psycopg2.Error as e:
        print_error(f"Database connection failed: {e}")
        print_info("Please ensure:")
        print_info(f"  1. PostgreSQL is running")
        print_info(f"  2. Database '{DB_CONFIG['database']}' exists")
        print_info(f"  3. User '{DB_CONFIG['user']}' has access with password")
        return False

def init_database_clean():
    """Initialize database with clean setup (no sample data)"""
    print_header("Clean Database Initialization")
    
    if not validate_env_config():
        return False
    
    try:
        from app.database import Base, engine
        from app.models import User, Category
        from app.utils.auth import get_password_hash
        from app.utils.slug import create_slug
        
        print_info("Dropping existing tables...")
        Base.metadata.drop_all(bind=engine)
        print_success("Tables dropped")
        
        print_info("Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print_success("Tables created")
        
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        try:
            print_info("Creating essential data...")
            
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
            
            db.commit()
            print_success("Users created")
            
            categories_data = [
                ("Electronics", "Latest gadgets and electronic devices"),
                ("Clothing", "Fashion and apparel for all occasions"),
                ("Home & Garden", "Everything for your home and garden"),
                ("Sports & Outdoors", "Sports equipment and outdoor gear"),
                ("Books", "Books, magazines, and educational materials"),
                ("Health & Beauty", "Health, beauty, and personal care products")
            ]
            
            for i, (name, description) in enumerate(categories_data, 1):
                category = Category(
                    name=name,
                    slug=create_slug(name),
                    description=description,
                    sort_order=i
                )
                db.add(category)
            
            db.commit()
            print_success("Categories created")
            
            print_success("Clean database initialization completed!")
            print_info("Created:")
            print_info("  - 2 Users (admin and regular user)")
            print_info("  - 6 Product categories")
            print_info("  - 0 Products (clean slate)")
            print_info("\n🔐 Login Credentials:")
            print_info("  Admin: admin@ecommerce.com / admin123")
            print_info("  User:  user@ecommerce.com / user123")
            
        except Exception as e:
            db.rollback()
            raise
        finally:
            db.close()
            
        return True
        
    except Exception as e:
        print_error(f"Database initialization failed: {e}")
        return False

def init_database_sample():
    """Initialize database with sample data"""
    print_header("Sample Database Initialization")
    
    if not validate_env_config():
        return False
    
    try:
        from app.database import Base, engine
        from app.models import User, Category, Product
        from app.utils.auth import get_password_hash
        from app.utils.slug import create_slug
        from faker import Faker
        
        fake = Faker()
        
        print_info("Dropping existing tables...")
        Base.metadata.drop_all(bind=engine)
        print_success("Tables dropped")
        
        print_info("Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print_success("Tables created")
        
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        try:
            print_info("Creating users...")
            
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
            print_success("Users created")
            
            categories_data = [
                ("Electronics", "Latest gadgets and electronic devices"),
                ("Clothing", "Fashion and apparel for all occasions"),
                ("Home & Garden", "Everything for your home and garden"),
                ("Sports & Outdoors", "Sports equipment and outdoor gear"),
                ("Books", "Books, magazines, and educational materials"),
                ("Health & Beauty", "Health, beauty, and personal care products")
            ]
            
            categories = []
            for i, (name, description) in enumerate(categories_data, 1):
                category = Category(
                    name=name,
                    slug=create_slug(name),
                    description=description,
                    sort_order=i
                )
                categories.append(category)
                db.add(category)
            
            db.commit()
            print_success("Categories created")
            
            print_info("Creating sample products...")
            sample_products = [
                # Electronics
                {"name": "iPhone 15 Pro", "description": "Latest iPhone with advanced features", "price": 999.99, "category": categories[0], "quantity": 50, "sku": "IPH15PRO001"},
                {"name": "MacBook Air", "description": "Lightweight laptop for professionals", "price": 1299.99, "category": categories[0], "quantity": 25, "sku": "MBA001"},
                {"name": "Samsung Galaxy S24", "description": "Premium Android smartphone", "price": 899.99, "category": categories[0], "quantity": 40, "sku": "SGS24001"},
                {"name": "iPad Pro", "description": "Professional tablet for creativity", "price": 799.99, "category": categories[0], "quantity": 30, "sku": "IPADPRO001"},
                {"name": "AirPods Pro", "description": "Wireless earbuds with noise cancellation", "price": 249.99, "category": categories[0], "quantity": 100, "sku": "APP001"},
                
                # Clothing
                {"name": "Cotton T-Shirt", "description": "Comfortable cotton t-shirt", "price": 29.99, "category": categories[1], "quantity": 100, "sku": "CTS001"},
                {"name": "Denim Jacket", "description": "Classic denim jacket", "price": 79.99, "category": categories[1], "quantity": 30, "sku": "DJ001"},
                {"name": "Running Shoes", "description": "Comfortable athletic shoes", "price": 129.99, "category": categories[1], "quantity": 60, "sku": "RS001"},
                {"name": "Hoodie", "description": "Warm and cozy hoodie", "price": 59.99, "category": categories[1], "quantity": 45, "sku": "HD001"},
                {"name": "Jeans", "description": "Classic blue jeans", "price": 89.99, "category": categories[1], "quantity": 70, "sku": "JN001"},
                
                # Home & Garden
                {"name": "Plant Pots Set", "description": "Set of decorative plant pots", "price": 49.99, "category": categories[2], "quantity": 40, "sku": "PPS001"},
                {"name": "Coffee Maker", "description": "Automatic drip coffee maker", "price": 159.99, "category": categories[2], "quantity": 20, "sku": "CM001"},
                {"name": "Throw Pillow", "description": "Decorative throw pillow", "price": 24.99, "category": categories[2], "quantity": 80, "sku": "TP001"},
                {"name": "Table Lamp", "description": "Modern LED table lamp", "price": 89.99, "category": categories[2], "quantity": 35, "sku": "TL001"},
                {"name": "Garden Tools Set", "description": "Complete gardening tool kit", "price": 119.99, "category": categories[2], "quantity": 25, "sku": "GTS001"},
                
                # Sports & Outdoors
                {"name": "Yoga Mat", "description": "Non-slip exercise yoga mat", "price": 39.99, "category": categories[3], "quantity": 60, "sku": "YM001"},
                {"name": "Water Bottle", "description": "Insulated stainless steel bottle", "price": 34.99, "category": categories[3], "quantity": 90, "sku": "WB001"},
                {"name": "Backpack", "description": "Hiking and travel backpack", "price": 149.99, "category": categories[3], "quantity": 40, "sku": "BP001"},
                
                # Books
                {"name": "Programming Book", "description": "Learn Python programming", "price": 49.99, "category": categories[4], "quantity": 50, "sku": "PB001"},
                
                # Health & Beauty
                {"name": "Face Cream", "description": "Moisturizing face cream", "price": 39.99, "category": categories[5], "quantity": 75, "sku": "FC001"}
            ]
            
            for i, product_data in enumerate(sample_products):
                product = Product(
                    name=product_data["name"],
                    slug=create_slug(product_data["name"]),
                    description=product_data["description"],
                    price=product_data["price"],
                    category_id=product_data["category"].id,
                    quantity=product_data["quantity"],
                    sku=product_data["sku"],
                    images=[f"product_{i+1}_1.jpg", f"product_{i+1}_2.jpg"]
                )
                db.add(product)
            
            db.commit()
            print_success("Sample products created")
            
            print_success("Sample database initialization completed!")
            print_info("Created:")
            print_info("  - 12 Users (admin, regular user, 10 sample users)")
            print_info("  - 6 Product categories")
            print_info("  - 5 Sample products")
            
        except Exception as e:
            db.rollback()
            raise
        finally:
            db.close()
            
        return True
        
    except Exception as e:
        print_error(f"Sample database initialization failed: {e}")
        return False

def download_images():
    """Download sample product images"""
    print_header("Downloading Product Images")
    
    uploads_dir = Path(__file__).parent.parent / "backend" / "uploads" / "products"
    uploads_dir.mkdir(parents=True, exist_ok=True)
    
    images = {
        # Electronics
        "product_1_1.jpg": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop",  # iPhone
        "product_1_2.jpg": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop",
        "product_2_1.jpg": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=400&fit=crop",  # MacBook
        "product_2_2.jpg": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop",
        "product_3_1.jpg": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=400&fit=crop",  # Samsung
        "product_3_2.jpg": "https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=400&h=400&fit=crop",
        "product_4_1.jpg": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&h=400&fit=crop",  # iPad
        "product_4_2.jpg": "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400&h=400&fit=crop",
        "product_5_1.jpg": "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400&h=400&fit=crop",  # AirPods
        "product_5_2.jpg": "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400&h=400&fit=crop",
        
        # Clothing
        "product_6_1.jpg": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",  # T-Shirt
        "product_6_2.jpg": "https://images.unsplash.com/photo-1583743814966-8936f37f4678?w=400&h=400&fit=crop",
        "product_7_1.jpg": "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400&h=400&fit=crop",  # Denim Jacket
        "product_7_2.jpg": "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&h=400&fit=crop",
        "product_8_1.jpg": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop",  # Shoes
        "product_8_2.jpg": "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop",
        "product_9_1.jpg": "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400&h=400&fit=crop",  # Hoodie
        "product_9_2.jpg": "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=400&fit=crop",
        "product_10_1.jpg": "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400&h=400&fit=crop", # Jeans
        "product_10_2.jpg": "https://images.unsplash.com/photo-1582552938357-32b906df40cb?w=400&h=400&fit=crop",
        
        # Home & Garden
        "product_11_1.jpg": "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&h=400&fit=crop", # Plant Pots
        "product_11_2.jpg": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=400&fit=crop",
        "product_12_1.jpg": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=400&fit=crop", # Coffee Maker
        "product_12_2.jpg": "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop",
        "product_13_1.jpg": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop", # Pillow
        "product_13_2.jpg": "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=400&fit=crop",
        "product_14_1.jpg": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop", # Lamp
        "product_14_2.jpg": "https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=400&h=400&fit=crop",
        "product_15_1.jpg": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=400&fit=crop", # Garden Tools
        "product_15_2.jpg": "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=400&h=400&fit=crop",
        
        # Sports & Outdoors
        "product_16_1.jpg": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop", # Yoga Mat
        "product_16_2.jpg": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
        "product_17_1.jpg": "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400&h=400&fit=crop", # Water Bottle
        "product_17_2.jpg": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop",
        "product_18_1.jpg": "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop", # Backpack
        "product_18_2.jpg": "https://images.unsplash.com/photo-1581605405669-fcdf81165afa?w=400&h=400&fit=crop",
        
        # Books
        "product_19_1.jpg": "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop", # Books
        "product_19_2.jpg": "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=400&fit=crop",
        
        # Health & Beauty
        "product_20_1.jpg": "https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop", # Face Cream
        "product_20_2.jpg": "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop"
    }
    
    downloaded = 0
    for filename, url in images.items():
        try:
            file_path = uploads_dir / filename
            if file_path.exists():
                print_info(f"Skipping {filename} (already exists)")
                continue
                
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            
            with open(file_path, 'wb') as f:
                f.write(response.content)
            
            print_success(f"Downloaded {filename}")
            downloaded += 1
            
        except Exception as e:
            print_error(f"Failed to download {filename}: {e}")
    
    print_success(f"Downloaded {downloaded} images to {uploads_dir}")
    return True

def reset_database():
    """Reset database (drop all tables)"""
    print_header("Database Reset")
    
    if not validate_env_config():
        return False
    
    try:
        from app.database import Base, engine
        
        print_info("Dropping all tables...")
        Base.metadata.drop_all(bind=engine)
        print_success("All tables dropped")
        print_info("Database reset completed. Run --init-clean or --init-sample to reinitialize.")
        return True
        
    except Exception as e:
        print_error(f"Database reset failed: {e}")
        return False

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="E-Commerce Database Setup Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python database/setup.py --validate              # Validate database connection
  python database/setup.py --init-clean           # Initialize clean database
  python database/setup.py --init-sample          # Initialize with sample data
  python database/setup.py --download-images      # Download sample images
  python database/setup.py --reset                # Reset database
  python database/setup.py --all                  # Full setup (validate + sample data + images)
        """
    )
    
    parser.add_argument('--validate', action='store_true', help='Validate database connection')
    parser.add_argument('--init-clean', action='store_true', help='Initialize clean database')
    parser.add_argument('--init-sample', action='store_true', help='Initialize with sample data')
    parser.add_argument('--download-images', action='store_true', help='Download sample images')
    parser.add_argument('--reset', action='store_true', help='Reset database')
    parser.add_argument('--all', action='store_true', help='Full setup (validate + sample data + images)')
    
    args = parser.parse_args()
    
    if not any(vars(args).values()):
        parser.print_help()
        return
    
    print_header("E-Commerce Database Setup")
    print_info(f"Environment file: {env_path}")
    print_info(f"Database: {DB_CONFIG['database']}")
    print_info(f"User: {DB_CONFIG['user']}")
    print_info(f"Host: {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    
    success = True
    
    if args.all:
        success &= validate_database()
        if success:
            success &= init_database_sample()
        if success:
            success &= download_images()
    else:
        if args.validate:
            success &= validate_database()
        
        if args.reset:
            success &= reset_database()
        
        if args.init_clean:
            success &= init_database_clean()
        
        if args.init_sample:
            success &= init_database_sample()
        
        if args.download_images:
            success &= download_images()
    
    if success:
        print_header("Setup Completed Successfully!")
        print_success("Your e-commerce database is ready!")
    else:
        print_header("Setup Failed!")
        print_error("Please check the errors above and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main()
