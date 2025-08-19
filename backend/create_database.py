#!/usr/bin/env python3
"""
Simple Database Creation Script
Creates the ecommerce_db database if it doesn't exist.
"""

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv
import os

def create_database():
    """Create the ecommerce_db database"""
    load_dotenv()
    
    host = os.getenv('DB_HOST', 'localhost')
    port = int(os.getenv('DB_PORT', 5432))
    user = os.getenv('DB_USER', 'postgres')
    password = os.getenv('DB_PASSWORD', 'admin')
    database_name = os.getenv('DB_NAME', 'ecommerce_db')
    
    print(f"Creating database '{database_name}'...")
    print(f"Host: {host}:{port}")
    print(f"User: {user}")
    
    try:
        # Connect to postgres database
        conn = psycopg2.connect(
            host=host,
            port=port,
            database='postgres',
            user=user,
            password=password
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (database_name,))
        if cursor.fetchone():
            print(f"[INFO] Database '{database_name}' already exists")
        else:
            # Create database
            cursor.execute(f'CREATE DATABASE "{database_name}"')
            print(f"[SUCCESS] Database '{database_name}' created successfully!")
        
        cursor.close()
        conn.close()
        
        # Test connection to new database
        print(f"\nTesting connection to '{database_name}'...")
        test_conn = psycopg2.connect(
            host=host,
            port=port,
            database=database_name,
            user=user,
            password=password
        )
        test_conn.close()
        print(f"[SUCCESS] Can connect to '{database_name}' successfully!")
        
        print(f"\n[SUCCESS] Database setup complete!")
        print(f"You can now run: python init_db.py")
        
        return True
        
    except psycopg2.Error as e:
        print(f"[ERROR] Database creation failed: {e}")
        return False
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("Database Creation Script")
    print("=" * 30)
    create_database()
