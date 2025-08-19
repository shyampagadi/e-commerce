#!/usr/bin/env python3
"""
Easy Setup Script for E-Commerce Application
This script creates the .env file, sets up the database, and initializes the application.
"""

import os
import sys
import subprocess
import platform

def create_env_file():
    """Create .env file with default configuration if it doesn't exist, or use existing values"""
    env_path = '.env'
    
    # Default configuration
    default_config = {
        # Database
        "DATABASE_URL": "postgresql://ecommerce_user:ecommerce_password@localhost:5432/ecommerce_db",
        "DB_HOST": "localhost",
        "DB_PORT": "5432",
        "DB_NAME": "ecommerce_db",
        "DB_USER": "ecommerce_user",
        "DB_PASSWORD": "ecommerce_password",
        
        # JWT
        "SECRET_KEY": "your-super-secret-jwt-key-change-this-in-production",
        "ALGORITHM": "HS256",
        "ACCESS_TOKEN_EXPIRE_MINUTES": "30",
        
        # API
        "API_V1_STR": "/api/v1",
        "PROJECT_NAME": "E-Commerce API",
        "ENVIRONMENT": "development",
        "DEBUG": "true",
        
        # CORS
        "BACKEND_CORS_ORIGINS": '["http://localhost:3000", "http://localhost:3001"]',
        
        # Frontend
        "REACT_APP_API_URL": "http://localhost:8000",
        "REACT_APP_API_BASE_URL": "http://localhost:8000/api/v1"
    }
    
    # Check if .env file exists
    if os.path.exists(env_path):
        print("📝 Found existing .env file, using existing values...")
        
        # Read existing configuration
        existing_config = {}
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    existing_config[key.strip()] = value.strip()
        
        # Merge with default configuration (keeping existing values)
        config = {**default_config, **existing_config}
        
        print("✅ Using existing .env configuration!")
    else:
        print("📝 Creating new .env file with default configuration...")
        config = default_config
        print("✅ .env file created with default values!")
    
    # Write configuration to .env file
    with open(env_path, 'w') as f:
        # Database section
        f.write("# Database\n")
        f.write(f"DATABASE_URL={config['DATABASE_URL']}\n")
        f.write(f"DB_HOST={config['DB_HOST']}\n")
        f.write(f"DB_PORT={config['DB_PORT']}\n")
        f.write(f"DB_NAME={config['DB_NAME']}\n")
        f.write(f"DB_USER={config['DB_USER']}\n")
        f.write(f"DB_PASSWORD={config['DB_PASSWORD']}\n\n")
        
        # JWT section
        f.write("# JWT\n")
        f.write(f"SECRET_KEY={config['SECRET_KEY']}\n")
        f.write(f"ALGORITHM={config['ALGORITHM']}\n")
        f.write(f"ACCESS_TOKEN_EXPIRE_MINUTES={config['ACCESS_TOKEN_EXPIRE_MINUTES']}\n\n")
        
        # API section
        f.write("# API\n")
        f.write(f"API_V1_STR={config['API_V1_STR']}\n")
        f.write(f"PROJECT_NAME={config['PROJECT_NAME']}\n")
        f.write(f"ENVIRONMENT={config['ENVIRONMENT']}\n")
        f.write(f"DEBUG={config['DEBUG']}\n\n")
        
        # CORS section
        f.write("# CORS\n")
        f.write(f"BACKEND_CORS_ORIGINS={config['BACKEND_CORS_ORIGINS']}\n\n")
        
        # Frontend section
        f.write("# Frontend\n")
        f.write(f"REACT_APP_API_URL={config['REACT_APP_API_URL']}\n")
        f.write(f"REACT_APP_API_BASE_URL={config['REACT_APP_API_BASE_URL']}\n")

def setup_database():
    """Set up the database using the setup_database.py script"""
    print("\n🔧 Setting up database...")
    
    try:
        subprocess.run([sys.executable, 'setup_database.py'], check=True)
        print("✅ Database setup completed!")
    except subprocess.CalledProcessError:
        print("❌ Database setup failed!")
        return False
    
    return True

def initialize_database():
    """Initialize the database with sample data"""
    print("\n🚀 Initializing database with sample data...")
    
    try:
        # Download product images
        print("📥 Downloading product images...")
        subprocess.run([sys.executable, 'backend/download_images.py'], check=True)
        
        # Initialize database
        print("🔧 Creating database tables and sample data...")
        subprocess.run([sys.executable, 'backend/init_db.py'], check=True)
        
        print("✅ Database initialized with sample data!")
    except subprocess.CalledProcessError:
        print("❌ Database initialization failed!")
        return False
    
    return True

def setup_backend():
    """Set up the backend environment"""
    print("\n📦 Setting up backend environment...")
    
    # Change to backend directory
    os.chdir('backend')
    
    # Create virtual environment
    print("🔧 Creating virtual environment...")
    if platform.system() == 'Windows':
        subprocess.run([sys.executable, '-m', 'venv', 'venv'], check=True)
        # Activate virtual environment and install requirements
        activate_cmd = 'venv\\Scripts\\activate.bat'
        pip_cmd = 'venv\\Scripts\\pip'
    else:
        subprocess.run([sys.executable, '-m', 'venv', 'venv'], check=True)
        # Activate virtual environment and install requirements
        activate_cmd = 'source venv/bin/activate'
        pip_cmd = 'venv/bin/pip'
    
    print("📦 Installing dependencies...")
    if platform.system() == 'Windows':
        subprocess.run(f'{pip_cmd} install -r requirements.txt', shell=True, check=True)
    else:
        subprocess.run(f'bash -c "{activate_cmd} && pip install -r requirements.txt"', shell=True, check=True)
    
    # Return to root directory
    os.chdir('..')
    
    print("✅ Backend setup completed!")
    return True

def setup_frontend():
    """Set up the frontend environment"""
    print("\n📦 Setting up frontend environment...")
    
    # Change to frontend directory
    os.chdir('frontend')
    
    # Install dependencies
    print("📦 Installing dependencies...")
    try:
        subprocess.run(['npm', 'install'], check=True)
    except subprocess.CalledProcessError:
        print("❌ Frontend setup failed! Make sure Node.js is installed.")
        return False
    
    # Return to root directory
    os.chdir('..')
    
    print("✅ Frontend setup completed!")
    return True

def main():
    """Main function to set up the application"""
    print("🚀 Easy Setup for E-Commerce Application")
    print("=" * 60)
    
    # Create .env file
    create_env_file()
    
    # Set up database
    if not setup_database():
        print("\n❌ Setup failed at database setup stage!")
        sys.exit(1)
    
    # Set up backend
    if not setup_backend():
        print("\n❌ Setup failed at backend setup stage!")
        sys.exit(1)
    
    # Set up frontend
    if not setup_frontend():
        print("\n❌ Setup failed at frontend setup stage!")
        sys.exit(1)
    
    # Initialize database
    if not initialize_database():
        print("\n❌ Setup failed at database initialization stage!")
        sys.exit(1)
    
    print("\n🎉 Setup Complete!")
    print("=" * 60)
    print("✅ Environment files created")
    print("✅ Database set up")
    print("✅ Backend dependencies installed")
    print("✅ Frontend dependencies installed")
    print("✅ Database initialized with sample data")
    
    print("\n🚀 Next steps:")
    if platform.system() == 'Windows':
        print("   1. cd backend")
        print("   2. venv\\Scripts\\activate")
        print("   3. uvicorn main:app --reload")
        print("\n   In a new terminal:")
        print("   4. cd frontend")
        print("   5. npm start")
    else:
        print("   1. cd backend")
        print("   2. source venv/bin/activate")
        print("   3. uvicorn main:app --reload")
        print("\n   In a new terminal:")
        print("   4. cd frontend")
        print("   5. npm start")
    
    print("\n🌐 The application will be available at:")
    print("   - Backend API: http://localhost:8000")
    print("   - Frontend: http://localhost:3000")
    
    print("\n🔐 Login credentials:")
    print("   - Admin: admin@ecommerce.com / admin123")
    print("   - User: user@ecommerce.com / user123")

if __name__ == "__main__":
    main()
