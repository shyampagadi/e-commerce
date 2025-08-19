#!/usr/bin/env python3
"""
PostgreSQL Database Setup Script for E-Commerce Application
This script creates the database, user, and updates the .env file with the correct DATABASE_URL
"""

import os
import sys
import subprocess
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import re

def load_env_config():
    """Load database configuration from .env file"""
    env_path = '.env'
    config = {}
    
    if not os.path.exists(env_path):
        print("❌ .env file not found!")
        sys.exit(1)
    
    with open(env_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                config[key.strip()] = value.strip()
    
    return config

def check_postgresql_installed():
    """Check if PostgreSQL is installed and accessible"""
    # Try Linux/WSL psql first
    try:
        result = subprocess.run(['psql', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ PostgreSQL found: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        pass
    
    # Try Windows psql if Linux version not found
    try:
        result = subprocess.run(['psql.exe', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ PostgreSQL found: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        pass
    
    # Try common Windows PostgreSQL installation paths
    common_paths = [
        'C:\\Program Files\\PostgreSQL\\16\\bin\\psql.exe',
        'C:\\Program Files\\PostgreSQL\\15\\bin\\psql.exe',
        'C:\\Program Files\\PostgreSQL\\14\\bin\\psql.exe',
        'C:\\Program Files\\PostgreSQL\\13\\bin\\psql.exe',
    ]
    
    for path in common_paths:
        try:
            result = subprocess.run([path, '--version'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ PostgreSQL found at {path}: {result.stdout.strip()}")
                return True
        except (FileNotFoundError, OSError):
            continue
    
    print("❌ PostgreSQL not found in PATH or common installation locations")
    return False

def get_postgres_connection():
    """Get connection to PostgreSQL server (not specific database)"""
    try:
        # Try to connect as current user first
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            user=os.getenv('USER', 'postgres'),  # Use current user or postgres
            database='postgres'  # Connect to default postgres database
        )
        return conn, os.getenv('USER', 'postgres')
    except psycopg2.Error:
        try:
            # Try with postgres user
            conn = psycopg2.connect(
                host='localhost',
                port=5432,
                user='postgres',
                database='postgres'
            )
            return conn, 'postgres'
        except psycopg2.Error as e:
            print(f"❌ Cannot connect to PostgreSQL: {e}")
            print("\n💡 Make sure PostgreSQL is running and you have access.")
            print("   You might need to:")
            print("   1. Start PostgreSQL service")
            print("   2. Set up authentication (pg_hba.conf)")
            print("   3. Create a postgres user password")
            return None, None

def create_database_and_user(config):
    """Create database and user based on config"""
    db_name = config.get('DB_NAME', 'ecommerce_db')
    db_user = config.get('DB_USER', 'ecommerce_user')
    db_password = config.get('DB_PASSWORD', 'ecommerce_password')
    db_host = config.get('DB_HOST', 'localhost')
    db_port = config.get('DB_PORT', '5432')
    
    print(f"🔧 Setting up database: {db_name}")
    print(f"🔧 Creating user: {db_user}")
    
    # Get connection to PostgreSQL
    conn, admin_user = get_postgres_connection()
    if not conn:
        return False
    
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = conn.cursor()
    
    try:
        # Check if database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
        if cursor.fetchone():
            print(f"⚠️  Database '{db_name}' already exists")
        else:
            # Create database
            cursor.execute(f'CREATE DATABASE "{db_name}"')
            print(f"✅ Database '{db_name}' created successfully")
        
        # Check if user exists
        cursor.execute("SELECT 1 FROM pg_user WHERE usename = %s", (db_user,))
        if cursor.fetchone():
            print(f"⚠️  User '{db_user}' already exists")
            # Update password
            cursor.execute(f"ALTER USER \"{db_user}\" WITH PASSWORD %s", (db_password,))
            print(f"✅ Updated password for user '{db_user}'")
        else:
            # Create user
            cursor.execute(f'CREATE USER "{db_user}" WITH PASSWORD %s', (db_password,))
            print(f"✅ User '{db_user}' created successfully")
        
        # Grant privileges
        cursor.execute(f'GRANT ALL PRIVILEGES ON DATABASE "{db_name}" TO "{db_user}"')
        cursor.execute(f'ALTER USER "{db_user}" CREATEDB')
        print(f"✅ Granted privileges to user '{db_user}'")
        
        # Test connection with new user
        test_conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )
        test_conn.close()
        print(f"✅ Connection test successful")
        
        return True
        
    except psycopg2.Error as e:
        print(f"❌ Database setup failed: {e}")
        return False
    finally:
        cursor.close()
        conn.close()

def update_env_file(config):
    """Update the DATABASE_URL in .env file"""
    db_name = config.get('DB_NAME', 'ecommerce_db')
    db_user = config.get('DB_USER', 'ecommerce_user')
    db_password = config.get('DB_PASSWORD', 'ecommerce_password')
    db_host = config.get('DB_HOST', 'localhost')
    db_port = config.get('DB_PORT', '5432')
    
    # Construct the DATABASE_URL
    database_url = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    
    # Read current .env file
    env_path = '.env'
    with open(env_path, 'r') as f:
        content = f.read()
    
    # Update DATABASE_URL
    pattern = r'DATABASE_URL=.*'
    replacement = f'DATABASE_URL={database_url}'
    
    if re.search(pattern, content):
        content = re.sub(pattern, replacement, content)
    else:
        # Add DATABASE_URL if not exists
        content = f"DATABASE_URL={database_url}\n" + content
    
    # Write back to .env file
    with open(env_path, 'w') as f:
        f.write(content)
    
    print(f"✅ Updated DATABASE_URL in .env file")
    print(f"   DATABASE_URL={database_url}")

def main():
    """Main function to set up the database"""
    print("🚀 PostgreSQL Database Setup for E-Commerce Application")
    print("=" * 60)
    
    # Check if PostgreSQL is installed
    if not check_postgresql_installed():
        print("\n💡 Please install PostgreSQL first:")
        print("   - Ubuntu/Debian: sudo apt-get install postgresql postgresql-contrib")
        print("   - macOS: brew install postgresql")
        print("   - Windows: Download from https://www.postgresql.org/download/")
        sys.exit(1)
    
    # Load configuration
    print("\n📋 Loading configuration from .env file...")
    config = load_env_config()
    
    db_name = config.get('DB_NAME', 'ecommerce_db')
    db_user = config.get('DB_USER', 'ecommerce_user')
    
    print(f"   Database: {db_name}")
    print(f"   User: {db_user}")
    print(f"   Host: {config.get('DB_HOST', 'localhost')}")
    print(f"   Port: {config.get('DB_PORT', '5432')}")
    
    # Create database and user
    print(f"\n🔧 Creating database and user...")
    if create_database_and_user(config):
        print("✅ Database setup completed successfully!")
        
        # Update .env file
        print(f"\n📝 Updating .env file...")
        update_env_file(config)
        
        print(f"\n🎉 Setup Complete!")
        print("=" * 60)
        print("✅ Database and user created")
        print("✅ .env file updated with correct DATABASE_URL")
        print("\n🚀 Next steps:")
        print("   1. cd backend")
        print("   2. python init_db.py  # Initialize tables and sample data")
        print("   3. uvicorn main:app --reload  # Start the backend server")
        
    else:
        print("❌ Database setup failed!")
        print("\n💡 Troubleshooting:")
        print("   1. Make sure PostgreSQL is running")
        print("   2. Check if you have sufficient privileges")
        print("   3. Verify PostgreSQL authentication settings")
        sys.exit(1)

if __name__ == "__main__":
    main()
