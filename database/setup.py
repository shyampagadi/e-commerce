#!/usr/bin/env python3
"""
🗄️ Complete E-Commerce Database Setup Script
============================================

This consolidated script handles ALL database operations for the e-commerce application.
It includes setup, sample data creation, image downloading, backup/restore, and maintenance.

📋 PREREQUISITES:
- PostgreSQL installed and running
- Database 'ecommerce_db' created manually
- User 'postgres' with password set
- Backend dependencies installed: pip install -r backend/requirements.txt

🚀 USAGE:
    python database/setup.py --help                    # Show all options
    python database/setup.py --validate               # Test database connection
    python database/setup.py --init-clean            # Clean database setup
    python database/setup.py --init-sample           # Setup with sample data
    python database/setup.py --download-images       # Download product images
    python database/setup.py --reset                 # Reset database
    python database/setup.py --all                   # Complete setup
    python database/setup.py --backup                # Create backup
    python database/setup.py --restore backup.sql    # Restore from backup

🔧 CONFIGURATION:
Update these variables in the script or use .env file:
    DB_HOST=localhost
    DB_PORT=5432
    DB_NAME=ecommerce_db
    DB_USER=postgres
    DB_PASSWORD=your_password

Author: E-Commerce Development Team
Version: 3.0 Consolidated
"""

import os
import sys
import argparse
import requests
import subprocess
import json
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any
from dotenv import load_dotenv

# ============================================================================
# CONFIGURATION AND SETUP
# ============================================================================

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
ENV_PATH = PROJECT_ROOT / ".env"
BACKEND_PATH = PROJECT_ROOT / "backend"
UPLOADS_PATH = BACKEND_PATH / "uploads" / "products"
BACKUP_PATH = PROJECT_ROOT / "database" / "backups"

# Load environment variables
load_dotenv(ENV_PATH)

# Add backend to Python path for imports
sys.path.insert(0, str(BACKEND_PATH))

# Database configuration - UPDATE THESE OR USE .env FILE
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 5432)),
    'database': os.getenv('DB_NAME', 'ecommerce_db'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'admin')  # Password set to 'admin'
}

DATABASE_URL = os.getenv('DATABASE_URL') or f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"

# Import required modules with error handling
try:
    import psycopg2
    from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
    from sqlalchemy import create_engine, text
    from sqlalchemy.orm import sessionmaker
    DEPENDENCIES_AVAILABLE = True
except ImportError as e:
    print(f"❌ Missing dependencies: {e}")
    print("📋 Please install: pip install -r backend/requirements.txt")
    DEPENDENCIES_AVAILABLE = False

# ============================================================================
# UTILITY FUNCTIONS FOR BEAUTIFUL OUTPUT
# ============================================================================

class Colors:
    """ANSI color codes for terminal output."""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'

def print_header(title: str) -> None:
    """Print formatted header with title."""
    print(f"\n{Colors.PURPLE}{'='*70}{Colors.NC}")
    print(f"{Colors.PURPLE}{Colors.BOLD}🚀 {title}{Colors.NC}")
    print(f"{Colors.PURPLE}{'='*70}{Colors.NC}")

def print_success(message: str) -> None:
    """Print success message in green."""
    print(f"{Colors.GREEN}✅ {message}{Colors.NC}")

def print_error(message: str) -> None:
    """Print error message in red."""
    print(f"{Colors.RED}❌ {message}{Colors.NC}")

def print_warning(message: str) -> None:
    """Print warning message in yellow."""
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.NC}")

def print_info(message: str) -> None:
    """Print info message in blue."""
    print(f"{Colors.BLUE}📋 {message}{Colors.NC}")

def print_step(message: str) -> None:
    """Print step message in cyan."""
    print(f"{Colors.CYAN}🔄 {message}{Colors.NC}")

def print_config_info() -> None:
    """Print current database configuration."""
    print_info(f"Database: {DB_CONFIG['database']}")
    print_info(f"User: {DB_CONFIG['user']}")
    print_info(f"Host: {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print_info(f"Backend path: {BACKEND_PATH}")

# ============================================================================
# CORE DATABASE VALIDATION AND CONNECTION
# ============================================================================

def validate_dependencies() -> bool:
    """Validate that all required dependencies are available."""
    if not DEPENDENCIES_AVAILABLE:
        print_error("Required Python dependencies are not installed")
        print_info("Please run: pip install -r backend/requirements.txt")
        return False
    return True

def validate_environment() -> bool:
    """Validate environment configuration and file structure."""
    print_step("Validating environment configuration...")
    
    # Check if backend directory exists
    if not BACKEND_PATH.exists():
        print_error(f"Backend directory not found at {BACKEND_PATH}")
        return False
    
    # Create necessary directories
    UPLOADS_PATH.mkdir(parents=True, exist_ok=True)
    BACKUP_PATH.mkdir(parents=True, exist_ok=True)
    
    print_success("Environment configuration is valid")
    return True

def validate_database() -> bool:
    """
    Validate PostgreSQL database connection and permissions.
    
    This function tests:
    - Database server connectivity
    - Database existence
    - User permissions
    - Basic SQL operations
    """
    print_header("Database Validation")
    
    if not validate_dependencies() or not validate_environment():
        return False
    
    try:
        # Test connection to database
        conn = psycopg2.connect(**DB_CONFIG)
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Get PostgreSQL version
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print_success("PostgreSQL connection successful")
        print_info(f"Version: {version.split(',')[0]}")
        
        # Verify database exists
        cursor.execute("SELECT datname FROM pg_database WHERE datname = %s;", (DB_CONFIG['database'],))
        if cursor.fetchone():
            print_success(f"Database '{DB_CONFIG['database']}' exists")
        else:
            print_error(f"Database '{DB_CONFIG['database']}' not found")
            print_info("Please create the database manually:")
            print_info(f"  CREATE DATABASE {DB_CONFIG['database']};")
            return False
        
        # Test basic permissions by creating and dropping a test table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS test_connection_temp (
                id SERIAL PRIMARY KEY,
                test_field VARCHAR(50)
            );
        """)
        cursor.execute("DROP TABLE IF EXISTS test_connection_temp;")
        print_success("Database permissions verified")
        
        cursor.close()
        conn.close()
        
        print_success("Database validation completed successfully!")
        return True
        
    except psycopg2.Error as e:
        print_error(f"Database connection failed: {e}")
        print_info("Troubleshooting steps:")
        print_info(f"  1. Ensure PostgreSQL is running")
        print_info(f"  2. Verify database '{DB_CONFIG['database']}' exists")
        print_info(f"  3. Check user '{DB_CONFIG['user']}' has correct password")
        print_info(f"  4. Update DB_CONFIG in this script with correct password")
        return False

# ============================================================================
# DATABASE SCHEMA INITIALIZATION
# ============================================================================

def initialize_database_schema() -> bool:
    """
    Initialize database schema by creating all tables.
    
    This function:
    1. Drops all existing tables (clean slate)
    2. Creates all tables defined in SQLAlchemy models
    3. Verifies table creation was successful
    """
    print_step("Initializing database schema...")
    
    try:
        # Import SQLAlchemy models and engine
        from app.database import Base, engine
        
        # Drop existing tables if they exist
        print_info("Dropping existing tables...")
        Base.metadata.drop_all(bind=engine)
        print_success("Existing tables dropped")
        
        # Create all tables from models
        print_info("Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print_success("Database tables created successfully")
        
        # Verify tables were created by querying information_schema
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name;
            """))
            tables = [row[0] for row in result]
            
        print_success(f"Created {len(tables)} tables:")
        for table in tables:
            print_info(f"  - {table}")
        
        return True
        
    except Exception as e:
        print_error(f"Schema initialization failed: {e}")
        return False

# ============================================================================
# USER CREATION FUNCTIONS
# ============================================================================

def create_admin_user(db_session) -> bool:
    """
    Create the default admin user.
    
    Creates admin user with:
    - Email: admin@ecommerce.com
    - Password: admin123 (securely hashed)
    - Full admin privileges
    - Complete profile information
    """
    try:
        from app.models import User
        from app.utils.auth import get_password_hash
        
        # Check if admin user already exists
        existing_admin = db_session.query(User).filter(User.email == "admin@ecommerce.com").first()
        if existing_admin:
            print_info("Admin user already exists, skipping creation")
            return True
        
        # Create admin user with comprehensive profile
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
        
        db_session.add(admin_user)
        db_session.commit()
        
        print_success("Admin user created successfully")
        print_info("  Email: admin@ecommerce.com")
        print_info("  Password: admin123")
        
        return True
        
    except Exception as e:
        print_error(f"Failed to create admin user: {e}")
        db_session.rollback()
        return False

def create_default_user(db_session) -> bool:
    """
    Create a default regular user for testing.
    
    Creates regular user with:
    - Email: user@ecommerce.com
    - Password: user123 (securely hashed)
    - Regular user privileges (no admin access)
    - Complete profile information
    """
    try:
        from app.models import User
        from app.utils.auth import get_password_hash
        
        # Check if user already exists
        existing_user = db_session.query(User).filter(User.email == "user@ecommerce.com").first()
        if existing_user:
            print_info("Default user already exists, skipping creation")
            return True
        
        # Create regular user with complete profile
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
        
        db_session.add(regular_user)
        db_session.commit()
        
        print_success("Default user created successfully")
        print_info("  Email: user@ecommerce.com")
        print_info("  Password: user123")
        
        return True
        
    except Exception as e:
        print_error(f"Failed to create default user: {e}")
        db_session.rollback()
        return False
def create_sample_users(db_session, count: int = 10) -> bool:
    """Create multiple sample users with realistic data using Faker."""
    try:
        from app.models import User
        from app.utils.auth import get_password_hash
        from faker import Faker
        
        fake = Faker()
        print_step(f"Creating {count} sample users...")
        
        created_users = []
        for i in range(count):
            username = f"user{i+1}"
            email = f"user{i+1}@example.com"
            
            # Check if user already exists
            existing_user = db_session.query(User).filter(User.email == email).first()
            if existing_user:
                continue
            
            user = User(
                email=email,
                username=username,
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
            
            created_users.append(user)
            db_session.add(user)
        
        db_session.commit()
        
        print_success(f"Created {len(created_users)} sample users")
        print_info("  Password for all sample users: password123")
        
        return True
        
    except Exception as e:
        print_error(f"Failed to create sample users: {e}")
        db_session.rollback()
        return False

# ============================================================================
# CATEGORY AND PRODUCT CREATION
# ============================================================================

def create_product_categories(db_session) -> List:
    """Create default product categories for the e-commerce store."""
    try:
        from app.models import Category
        from app.utils.slug import create_slug
        
        print_step("Creating product categories...")
        
        categories_data = [
            {"name": "Electronics", "description": "Latest gadgets, smartphones, laptops, tablets, and electronic devices", "sort_order": 1},
            {"name": "Clothing & Fashion", "description": "Fashion and apparel for men, women, and children", "sort_order": 2},
            {"name": "Home & Garden", "description": "Everything for your home, garden, and living spaces", "sort_order": 3},
            {"name": "Sports & Outdoors", "description": "Sports equipment, outdoor gear, fitness accessories", "sort_order": 4},
            {"name": "Books & Media", "description": "Books, magazines, movies, music, and educational materials", "sort_order": 5},
            {"name": "Health & Beauty", "description": "Health, beauty, wellness, and personal care products", "sort_order": 6}
        ]
        
        categories = []
        for cat_data in categories_data:
            existing_cat = db_session.query(Category).filter(Category.name == cat_data["name"]).first()
            if existing_cat:
                categories.append(existing_cat)
                continue
            
            category = Category(
                name=cat_data["name"],
                slug=create_slug(cat_data["name"]),
                description=cat_data["description"],
                sort_order=cat_data["sort_order"]
            )
            categories.append(category)
            db_session.add(category)
        
        db_session.commit()
        
        print_success(f"Created/verified {len(categories)} product categories")
        for cat in categories:
            print_info(f"  - {cat.name} ({cat.slug})")
        
        return categories
        
    except Exception as e:
        print_error(f"Failed to create categories: {e}")
        db_session.rollback()
        return []

def create_sample_products(db_session, categories: List) -> bool:
    """Create comprehensive sample products with realistic data."""
    try:
        from app.models import Product
        from app.utils.slug import create_slug
        
        print_step("Creating sample products...")
        
        sample_products = [
            # Electronics
            {"name": "iPhone 15 Pro Max", "description": "Latest iPhone with A17 Pro chip, titanium design, and advanced camera system", "price": 1199.99, "category_idx": 0, "quantity": 50, "sku": "IPH15PROMAX001", "images": ["iphone_15_pro_1.jpg", "iphone_15_pro_2.jpg"]},
            {"name": "MacBook Air M3", "description": "Supercharged by the M3 chip, portable powerhouse with 13.6-inch Liquid Retina display", "price": 1299.99, "category_idx": 0, "quantity": 25, "sku": "MBAM3001", "images": ["macbook_air_m3_1.jpg", "macbook_air_m3_2.jpg"]},
            {"name": "Samsung Galaxy S24 Ultra", "description": "Premium Android smartphone with S Pen, 200MP camera, and AI-powered features", "price": 1299.99, "category_idx": 0, "quantity": 40, "sku": "SGS24ULTRA001", "images": ["galaxy_s24_ultra_1.jpg", "galaxy_s24_ultra_2.jpg"]},
            
            # Clothing & Fashion
            {"name": "Premium Cotton T-Shirt", "description": "Ultra-soft 100% organic cotton t-shirt with perfect fit. Sustainably sourced", "price": 29.99, "category_idx": 1, "quantity": 100, "sku": "PCOTTS001", "images": ["cotton_tshirt_1.jpg", "cotton_tshirt_2.jpg"]},
            {"name": "Classic Denim Jacket", "description": "Timeless denim jacket crafted from premium denim with vintage wash finish", "price": 89.99, "category_idx": 1, "quantity": 30, "sku": "CDENJKT001", "images": ["denim_jacket_1.jpg", "denim_jacket_2.jpg"]},
            
            # Home & Garden
            {"name": "Smart Coffee Maker", "description": "WiFi-enabled coffee maker with app control, programmable brewing, and built-in grinder", "price": 299.99, "category_idx": 2, "quantity": 20, "sku": "SMARTCM001", "images": ["smart_coffee_maker_1.jpg", "smart_coffee_maker_2.jpg"]},
            {"name": "Ceramic Plant Pot Set", "description": "Set of 3 beautiful ceramic plant pots with drainage holes and saucers", "price": 49.99, "category_idx": 2, "quantity": 40, "sku": "CPLANTPOT001", "images": ["plant_pot_set_1.jpg", "plant_pot_set_2.jpg"]},
            
            # Sports & Outdoors
            {"name": "Professional Yoga Mat", "description": "Premium non-slip yoga mat made from eco-friendly TPE material. Extra thick for comfort", "price": 49.99, "category_idx": 3, "quantity": 60, "sku": "PROYOGMAT001", "images": ["yoga_mat_1.jpg", "yoga_mat_2.jpg"]},
            {"name": "Stainless Steel Water Bottle", "description": "Insulated water bottle keeps drinks cold for 24 hours or hot for 12 hours", "price": 34.99, "category_idx": 3, "quantity": 90, "sku": "SSWB001", "images": ["water_bottle_1.jpg", "water_bottle_2.jpg"]},
            
            # Books & Media
            {"name": "Python Programming Masterclass", "description": "Comprehensive guide to Python programming from beginner to advanced", "price": 59.99, "category_idx": 4, "quantity": 50, "sku": "PYPROGMC001", "images": ["python_book_1.jpg", "python_book_2.jpg"]},
            
            # Health & Beauty
            {"name": "Vitamin C Face Serum", "description": "Powerful anti-aging serum with 20% Vitamin C, hyaluronic acid, and vitamin E", "price": 39.99, "category_idx": 5, "quantity": 75, "sku": "VITCSER001", "images": ["vitamin_c_serum_1.jpg", "vitamin_c_serum_2.jpg"]}
        ]
        
        created_products = []
        for product_data in sample_products:
            existing_product = db_session.query(Product).filter(Product.sku == product_data["sku"]).first()
            if existing_product:
                created_products.append(existing_product)
                continue
            
            category = categories[product_data["category_idx"]]
            
            product = Product(
                name=product_data["name"],
                slug=create_slug(product_data["name"]),
                description=product_data["description"],
                price=product_data["price"],
                category_id=category.id,
                quantity=product_data["quantity"],
                sku=product_data["sku"],
                images=product_data.get("images", [])
            )
            
            created_products.append(product)
            db_session.add(product)
        
        db_session.commit()
        
        print_success(f"Created {len(created_products)} sample products")
        for product in created_products:
            print_info(f"  - {product.name} (${product.price}) - Stock: {product.quantity}")
        
        return True
        
    except Exception as e:
        print_error(f"Failed to create sample products: {e}")
        db_session.rollback()
        return False

# ============================================================================
# IMAGE DOWNLOAD FUNCTIONS
# ============================================================================

def download_images() -> bool:
    """Download sample product images from Unsplash."""
    print_header("Downloading Product Images")
    
    # Create uploads directory
    UPLOADS_PATH.mkdir(parents=True, exist_ok=True)
    
    # High-quality product images from Unsplash
    images = {
        # Electronics
        "iphone_15_pro_1.jpg": "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=400&fit=crop",
        "iphone_15_pro_2.jpg": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop",
        "macbook_air_m3_1.jpg": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=400&fit=crop",
        "macbook_air_m3_2.jpg": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop",
        "galaxy_s24_ultra_1.jpg": "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=400&fit=crop",
        "galaxy_s24_ultra_2.jpg": "https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=400&h=400&fit=crop",
        
        # Clothing
        "cotton_tshirt_1.jpg": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",
        "cotton_tshirt_2.jpg": "https://images.unsplash.com/photo-1583743814966-8936f37f4678?w=400&h=400&fit=crop",
        "denim_jacket_1.jpg": "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400&h=400&fit=crop",
        "denim_jacket_2.jpg": "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400&h=400&fit=crop",
        
        # Home & Garden
        "smart_coffee_maker_1.jpg": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=400&fit=crop",
        "smart_coffee_maker_2.jpg": "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop",
        "plant_pot_set_1.jpg": "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&h=400&fit=crop",
        "plant_pot_set_2.jpg": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&h=400&fit=crop",
        
        # Sports & Outdoors
        "yoga_mat_1.jpg": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop",
        "yoga_mat_2.jpg": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop",
        "water_bottle_1.jpg": "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400&h=400&fit=crop",
        "water_bottle_2.jpg": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop",
        
        # Books & Media
        "python_book_1.jpg": "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&h=400&fit=crop",
        "python_book_2.jpg": "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=400&fit=crop",
        
        # Health & Beauty
        "vitamin_c_serum_1.jpg": "https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop",
        "vitamin_c_serum_2.jpg": "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop"
    }
    
    downloaded = 0
    for filename, url in images.items():
        try:
            file_path = UPLOADS_PATH / filename
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
    
    print_success(f"Downloaded {downloaded} images to {UPLOADS_PATH}")
    return True

# ============================================================================
# DATABASE BACKUP AND RESTORE
# ============================================================================

def backup_database() -> bool:
    """Create database backup with timestamp."""
    print_header("Database Backup")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_PATH / f"backup_{timestamp}.sql"
    
    try:
        print_step("Creating database backup...")
        
        # Use pg_dump to create backup
        cmd = [
            "pg_dump",
            "-h", DB_CONFIG['host'],
            "-p", str(DB_CONFIG['port']),
            "-U", DB_CONFIG['user'],
            "-d", DB_CONFIG['database'],
            "-f", str(backup_file)
        ]
        
        # Set password via environment variable
        env = os.environ.copy()
        env['PGPASSWORD'] = DB_CONFIG['password']
        
        result = subprocess.run(cmd, env=env, capture_output=True, text=True)
        
        if result.returncode == 0:
            print_success(f"Database backup created: {backup_file}")
            print_info(f"Backup size: {backup_file.stat().st_size / 1024:.1f} KB")
            return True
        else:
            print_error(f"Backup failed: {result.stderr}")
            return False
            
    except Exception as e:
        print_error(f"Backup failed: {e}")
        return False

def restore_database(backup_file: str) -> bool:
    """Restore database from backup file."""
    print_header("Database Restore")
    
    backup_path = Path(backup_file)
    if not backup_path.exists():
        print_error(f"Backup file not found: {backup_file}")
        return False
    
    try:
        print_step(f"Restoring database from {backup_file}...")
        print_warning("This will overwrite the current database!")
        
        # Use psql to restore backup
        cmd = [
            "psql",
            "-h", DB_CONFIG['host'],
            "-p", str(DB_CONFIG['port']),
            "-U", DB_CONFIG['user'],
            "-d", DB_CONFIG['database'],
            "-f", str(backup_path)
        ]
        
        # Set password via environment variable
        env = os.environ.copy()
        env['PGPASSWORD'] = DB_CONFIG['password']
        
        result = subprocess.run(cmd, env=env, capture_output=True, text=True)
        
        if result.returncode == 0:
            print_success("Database restored successfully")
            return True
        else:
            print_error(f"Restore failed: {result.stderr}")
            return False
            
    except Exception as e:
        print_error(f"Restore failed: {e}")
        return False

# ============================================================================
# MAIN DATABASE OPERATIONS
# ============================================================================

def init_database_clean() -> bool:
    """Initialize database with clean setup (no sample data)."""
    print_header("Clean Database Initialization")
    
    if not validate_dependencies() or not validate_environment():
        return False
    
    try:
        # Initialize schema
        if not initialize_database_schema():
            return False
        
        # Create database session
        from app.database import engine
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        try:
            print_step("Creating essential users...")
            
            # Create admin and default users
            if not create_admin_user(db):
                return False
            if not create_default_user(db):
                return False
            
            print_step("Creating product categories...")
            categories = create_product_categories(db)
            if not categories:
                return False
            
            print_success("Clean database initialization completed!")
            print_info("Created:")
            print_info("  - 2 Users (admin and regular user)")
            print_info("  - 6 Product categories")
            print_info("  - 0 Products (clean slate)")
            print_info("\n🔐 Login Credentials:")
            print_info("  Admin: admin@ecommerce.com / admin123")
            print_info("  User:  user@ecommerce.com / user123")
            
            return True
            
        except Exception as e:
            db.rollback()
            raise
        finally:
            db.close()
            
    except Exception as e:
        print_error(f"Database initialization failed: {e}")
        return False

def init_database_sample() -> bool:
    """Initialize database with sample data."""
    print_header("Sample Database Initialization")
    
    if not validate_dependencies() or not validate_environment():
        return False
    
    try:
        # Initialize schema
        if not initialize_database_schema():
            return False
        
        # Create database session
        from app.database import engine
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        db = SessionLocal()
        
        try:
            print_step("Creating users...")
            
            # Create admin and default users
            if not create_admin_user(db):
                return False
            if not create_default_user(db):
                return False
            
            # Create sample users
            if not create_sample_users(db, 10):
                return False
            
            print_step("Creating product categories...")
            categories = create_product_categories(db)
            if not categories:
                return False
            
            print_step("Creating sample products...")
            if not create_sample_products(db, categories):
                return False
            
            print_success("Sample database initialization completed!")
            print_info("Created:")
            print_info("  - 12 Users (admin, regular user, 10 sample users)")
            print_info("  - 6 Product categories")
            print_info("  - 11 Sample products with realistic data")
            print_info("\n🔐 Login Credentials:")
            print_info("  Admin: admin@ecommerce.com / admin123")
            print_info("  User:  user@ecommerce.com / user123")
            print_info("  Sample Users: user1@example.com / password123")
            
            return True
            
        except Exception as e:
            db.rollback()
            raise
        finally:
            db.close()
            
    except Exception as e:
        print_error(f"Sample database initialization failed: {e}")
        return False

def reset_database() -> bool:
    """Reset database (drop all tables)."""
    print_header("Database Reset")
    
    if not validate_dependencies():
        return False
    
    try:
        from app.database import Base, engine
        
        print_step("Dropping all tables...")
        Base.metadata.drop_all(bind=engine)
        print_success("All tables dropped")
        print_info("Database reset completed. Run --init-clean or --init-sample to reinitialize.")
        return True
        
    except Exception as e:
        print_error(f"Database reset failed: {e}")
        return False

# ============================================================================
# MAIN FUNCTION AND ARGUMENT PARSING
# ============================================================================

def main():
    """Main function with comprehensive argument parsing."""
    parser = argparse.ArgumentParser(
        description="Complete E-Commerce Database Setup Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
🚀 EXAMPLES:
  python database/setup.py --validate              # Test database connection
  python database/setup.py --init-clean           # Clean database setup
  python database/setup.py --init-sample          # Setup with sample data
  python database/setup.py --download-images      # Download product images
  python database/setup.py --reset                # Reset database
  python database/setup.py --all                  # Complete setup
  python database/setup.py --backup               # Create backup
  python database/setup.py --restore backup.sql   # Restore from backup

🔧 CONFIGURATION:
Update DB_CONFIG in this script or create .env file with:
  DB_HOST=localhost
  DB_PORT=5432
  DB_NAME=ecommerce_db
  DB_USER=postgres
  DB_PASSWORD=your_password

📋 PREREQUISITES:
  - PostgreSQL installed and running
  - Database 'ecommerce_db' created manually
  - User 'postgres' with password set
  - Backend dependencies: pip install -r backend/requirements.txt
        """
    )
    
    parser.add_argument('--validate', action='store_true', help='Validate database connection')
    parser.add_argument('--init-clean', action='store_true', help='Initialize clean database')
    parser.add_argument('--init-sample', action='store_true', help='Initialize with sample data')
    parser.add_argument('--download-images', action='store_true', help='Download sample images')
    parser.add_argument('--reset', action='store_true', help='Reset database')
    parser.add_argument('--all', action='store_true', help='Complete setup (validate + sample data + images)')
    parser.add_argument('--backup', action='store_true', help='Create database backup')
    parser.add_argument('--restore', metavar='FILE', help='Restore database from backup file')
    
    args = parser.parse_args()
    
    if not any(vars(args).values()):
        parser.print_help()
        return
    
    print_header("E-Commerce Database Setup")
    print_config_info()
    
    success = True
    
    if args.all:
        # Complete setup: validate + sample data + images
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
        
        if args.backup:
            success &= backup_database()
        
        if args.restore:
            success &= restore_database(args.restore)
    
    if success:
        print_header("Setup Completed Successfully!")
        print_success("Your e-commerce database is ready!")
        print_info("Next steps:")
        print_info("  1. Start the backend: cd backend && uvicorn main:app --reload")
        print_info("  2. Start the frontend: cd frontend && npm start")
        print_info("  3. Access the application: http://localhost:3000")
    else:
        print_header("Setup Failed!")
        print_error("Please check the errors above and try again.")
        sys.exit(1)

if __name__ == "__main__":
    main()
