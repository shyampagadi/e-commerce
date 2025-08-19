#!/usr/bin/env python3
"""
PostgreSQL Connection Test Script
Tests various connection scenarios to help diagnose database connectivity issues.
"""

import os
import sys
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv

def load_env_config():
    """Load database configuration from .env file"""
    load_dotenv()
    config = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'port': int(os.getenv('DB_PORT', 5432)),
        'database': os.getenv('DB_NAME', 'ecommerce_db'),
        'user': os.getenv('DB_USER', 'postgres'),
        'password': os.getenv('DB_PASSWORD', 'postgres'),
        'database_url': os.getenv('DATABASE_URL', '')
    }
    return config

def test_connection(host, port, database, user, password, test_name):
    """Test a specific database connection"""
    print(f"\n--- Testing {test_name} ---")
    print(f"Host: {host}")
    print(f"Port: {port}")
    print(f"Database: {database}")
    print(f"User: {user}")
    print(f"Password: {'*' * len(password) if password else 'None'}")
    
    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password,
            connect_timeout=5
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        
        cursor.execute("SELECT current_database();")
        current_db = cursor.fetchone()[0]
        
        print(f"[SUCCESS] Connected successfully!")
        print(f"PostgreSQL Version: {version}")
        print(f"Current Database: {current_db}")
        
        cursor.close()
        conn.close()
        return True
        
    except psycopg2.OperationalError as e:
        print(f"[ERROR] Connection failed: {e}")
        return False
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return False

def test_database_exists(host, port, user, password, database_name):
    """Test if a specific database exists"""
    print(f"\n--- Checking if database '{database_name}' exists ---")
    
    try:
        # Connect to postgres database to check if target database exists
        conn = psycopg2.connect(
            host=host,
            port=port,
            database='postgres',
            user=user,
            password=password,
            connect_timeout=5
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (database_name,))
        exists = cursor.fetchone() is not None
        
        if exists:
            print(f"[SUCCESS] Database '{database_name}' exists")
        else:
            print(f"[WARNING] Database '{database_name}' does not exist")
        
        cursor.close()
        conn.close()
        return exists
        
    except Exception as e:
        print(f"[ERROR] Could not check database existence: {e}")
        return False

def test_user_exists(host, port, user, password, target_user):
    """Test if a specific user exists"""
    print(f"\n--- Checking if user '{target_user}' exists ---")
    
    try:
        conn = psycopg2.connect(
            host=host,
            port=port,
            database='postgres',
            user=user,
            password=password,
            connect_timeout=5
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT 1 FROM pg_user WHERE usename = %s", (target_user,))
        exists = cursor.fetchone() is not None
        
        if exists:
            print(f"[SUCCESS] User '{target_user}' exists")
        else:
            print(f"[WARNING] User '{target_user}' does not exist")
        
        cursor.close()
        conn.close()
        return exists
        
    except Exception as e:
        print(f"[ERROR] Could not check user existence: {e}")
        return False

def main():
    """Main function to test PostgreSQL connections"""
    print("PostgreSQL Connection Test")
    print("=" * 50)
    
    # Load configuration
    config = load_env_config()
    
    print(f"\nLoaded configuration:")
    print(f"Host: {config['host']}")
    print(f"Port: {config['port']}")
    print(f"Database: {config['database']}")
    print(f"User: {config['user']}")
    print(f"DATABASE_URL: {config['database_url']}")
    
    # Test 1: Connect to postgres database with configured user
    success1 = test_connection(
        config['host'], 
        config['port'], 
        'postgres', 
        config['user'], 
        config['password'],
        "Default postgres database with configured user"
    )
    
    # Test 2: Connect to target database with configured user
    success2 = test_connection(
        config['host'], 
        config['port'], 
        config['database'], 
        config['user'], 
        config['password'],
        "Target database with configured user"
    )
    
    # Test 3: Try common default credentials
    if not success1:
        print("\n" + "=" * 50)
        print("Trying common default credentials...")
        
        common_credentials = [
            ('postgres', ''),  # No password
            ('postgres', 'postgres'),
            ('postgres', 'password'),
            ('postgres', 'admin'),
        ]
        
        for user, password in common_credentials:
            if test_connection(config['host'], config['port'], 'postgres', user, password, f"postgres db with {user}:{password or 'no password'}"):
                print(f"\n[IDEA] Working credentials found: {user}:{password or 'no password'}")
                print("Update your .env file with these credentials:")
                print(f"DB_USER={user}")
                print(f"DB_PASSWORD={password}")
                print(f"DATABASE_URL=postgresql://{user}:{password}@{config['host']}:{config['port']}/{config['database']}")
                break
    
    # Additional checks if we can connect to postgres database
    if success1:
        test_database_exists(config['host'], config['port'], config['user'], config['password'], config['database'])
        test_user_exists(config['host'], config['port'], config['user'], config['password'], config['user'])
    
    print("\n" + "=" * 50)
    print("Connection Test Summary:")
    print(f"Default postgres database: {'[SUCCESS]' if success1 else '[FAILED]'}")
    print(f"Target database: {'[SUCCESS]' if success2 else '[FAILED]'}")
    
    if success2:
        print("\n[SUCCESS] Your database connection is working!")
        print("You can now run: python init_db.py")
    elif success1:
        print(f"\n[PARTIAL] Can connect to postgres, but '{config['database']}' database may not exist.")
        print("You may need to create the database first.")
        print("Try running: python setup_database.py")
    else:
        print("\n[ERROR] Cannot connect to PostgreSQL.")
        print("Please check:")
        print("1. PostgreSQL is installed and running")
        print("2. Connection credentials are correct")
        print("3. PostgreSQL is accepting connections on the specified host/port")
        print("4. Firewall is not blocking the connection")

if __name__ == "__main__":
    main()
