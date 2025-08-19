#!/usr/bin/env python3
"""
Database Content Check Script
Checks what data exists in the database after initialization.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from dotenv import load_dotenv

def check_database_content():
    """Check what data exists in the database"""
    load_dotenv()
    
    database_url = os.getenv('DATABASE_URL')
    print("Database Content Check")
    print("=" * 40)
    print(f"Database URL: {database_url}")
    
    try:
        engine = create_engine(database_url)
        
        with engine.connect() as conn:
            # Check tables
            print("\n--- Tables ---")
            result = conn.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """))
            tables = [row[0] for row in result]
            for table in tables:
                print(f"  - {table}")
            
            # Check users
            print("\n--- Users ---")
            result = conn.execute(text("SELECT COUNT(*) FROM users"))
            user_count = result.fetchone()[0]
            print(f"Total users: {user_count}")
            
            if user_count > 0:
                result = conn.execute(text("""
                    SELECT username, email, is_admin, is_active 
                    FROM users 
                    ORDER BY created_at 
                    LIMIT 5
                """))
                print("Sample users:")
                for row in result:
                    admin_status = "[ADMIN]" if row[2] else "[USER]"
                    active_status = "[ACTIVE]" if row[3] else "[INACTIVE]"
                    print(f"  - {row[0]} ({row[1]}) {admin_status} {active_status}")
            
            # Check categories
            print("\n--- Categories ---")
            result = conn.execute(text("SELECT COUNT(*) FROM categories"))
            category_count = result.fetchone()[0]
            print(f"Total categories: {category_count}")
            
            if category_count > 0:
                result = conn.execute(text("SELECT name, slug FROM categories ORDER BY name"))
                print("Categories:")
                for row in result:
                    print(f"  - {row[0]} ({row[1]})")
            
            # Check products
            print("\n--- Products ---")
            result = conn.execute(text("SELECT COUNT(*) FROM products"))
            product_count = result.fetchone()[0]
            print(f"Total products: {product_count}")
            
            if product_count > 0:
                result = conn.execute(text("""
                    SELECT p.name, p.price, c.name as category_name 
                    FROM products p 
                    LEFT JOIN categories c ON p.category_id = c.id 
                    ORDER BY p.name 
                    LIMIT 10
                """))
                print("Sample products:")
                for row in result:
                    print(f"  - {row[0]} (${row[1]}) - {row[2] or 'No category'}")
            
            print(f"\n[SUCCESS] Database check completed!")
            print(f"Summary: {len(tables)} tables, {user_count} users, {category_count} categories, {product_count} products")
            
            # Check default login credentials
            print(f"\n--- Default Login Credentials ---")
            result = conn.execute(text("""
                SELECT username, email, is_admin 
                FROM users 
                WHERE username IN ('admin', 'user') 
                ORDER BY is_admin DESC
            """))
            
            for row in result:
                role = "Admin" if row[2] else "User"
                print(f"{role} Account:")
                print(f"  Username: {row[0]}")
                print(f"  Email: {row[1]}")
                print(f"  Password: {'admin123' if row[2] else 'user123'}")
                print()
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Database check failed: {e}")
        return False

if __name__ == "__main__":
    check_database_content()
