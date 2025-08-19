#!/usr/bin/env python3
"""
Detailed Database Diagnostic Script
Provides comprehensive information about the database state.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text, inspect
from dotenv import load_dotenv

def diagnose_database():
    """Comprehensive database diagnosis"""
    load_dotenv()
    
    database_url = os.getenv('DATABASE_URL')
    print("DETAILED DATABASE DIAGNOSIS")
    print("=" * 50)
    print(f"Database URL: {database_url}")
    
    try:
        engine = create_engine(database_url)
        inspector = inspect(engine)
        
        with engine.connect() as conn:
            # Check database connection
            print(f"\n[SUCCESS] Connected to database successfully")
            
            # Get database name
            result = conn.execute(text("SELECT current_database()"))
            db_name = result.fetchone()[0]
            print(f"Current database: {db_name}")
            
            # Check all schemas
            print(f"\n--- All Schemas ---")
            result = conn.execute(text("""
                SELECT schema_name 
                FROM information_schema.schemata 
                ORDER BY schema_name
            """))
            schemas = [row[0] for row in result]
            for schema in schemas:
                print(f"  - {schema}")
            
            # Check all tables in all schemas
            print(f"\n--- All Tables (All Schemas) ---")
            result = conn.execute(text("""
                SELECT table_schema, table_name, table_type
                FROM information_schema.tables 
                WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
                ORDER BY table_schema, table_name
            """))
            
            tables_found = False
            for row in result:
                tables_found = True
                print(f"  - {row[0]}.{row[1]} ({row[2]})")
            
            if not tables_found:
                print("  [WARNING] No user tables found!")
            
            # Check public schema specifically
            print(f"\n--- Public Schema Tables ---")
            public_tables = inspector.get_table_names(schema='public')
            if public_tables:
                for table in public_tables:
                    print(f"  - {table}")
                    
                    # Get row count for each table
                    try:
                        result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
                        count = result.fetchone()[0]
                        print(f"    Rows: {count}")
                    except Exception as e:
                        print(f"    Error counting rows: {e}")
            else:
                print("  [WARNING] No tables found in public schema!")
            
            # Check if our expected tables exist
            expected_tables = ['users', 'categories', 'products', 'orders', 'order_items', 'cart_items']
            print(f"\n--- Expected E-commerce Tables ---")
            
            for table in expected_tables:
                if table in public_tables:
                    try:
                        result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
                        count = result.fetchone()[0]
                        print(f"  [OK] {table}: {count} rows")
                        
                        # Show sample data for key tables
                        if table == 'users' and count > 0:
                            result = conn.execute(text("SELECT username, email, is_admin FROM users LIMIT 3"))
                            print("    Sample users:")
                            for row in result:
                                role = "[ADMIN]" if row[2] else "[USER]"
                                print(f"      - {row[0]} ({row[1]}) {role}")
                        
                        elif table == 'categories' and count > 0:
                            result = conn.execute(text("SELECT name FROM categories LIMIT 5"))
                            categories = [row[0] for row in result]
                            print(f"    Sample categories: {', '.join(categories)}")
                        
                        elif table == 'products' and count > 0:
                            result = conn.execute(text("SELECT name, price FROM products LIMIT 3"))
                            print("    Sample products:")
                            for row in result:
                                print(f"      - {row[0]} (${row[1]})")
                                
                    except Exception as e:
                        print(f"  [MISSING] {table}: Error - {e}")
                else:
                    print(f"  [MISSING] {table}: Table not found")
            
            # Check table structure for users table
            if 'users' in public_tables:
                print(f"\n--- Users Table Structure ---")
                columns = inspector.get_columns('users')
                for col in columns:
                    print(f"  - {col['name']}: {col['type']}")
            
            print(f"\n[SUCCESS] Database diagnosis completed!")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Database diagnosis failed: {e}")
        return False

if __name__ == "__main__":
    diagnose_database()
