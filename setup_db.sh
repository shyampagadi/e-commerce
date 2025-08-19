#!/bin/bash

# PostgreSQL Database Setup Script for E-Commerce Application
# This script creates the database, user, and updates the .env file

set -e  # Exit on any error

echo "🚀 PostgreSQL Database Setup for E-Commerce Application"
echo "============================================================"

# Load configuration from .env file
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    exit 1
fi

# Source the .env file to get variables
source .env

# Set default values if not provided
DB_NAME=${DB_NAME:-ecommerce_db}
DB_USER=${DB_USER:-ecommerce_user}
DB_PASSWORD=${DB_PASSWORD:-ecommerce_password}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}

echo "📋 Configuration:"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed or not in PATH"
    echo ""
    echo "💡 Please install PostgreSQL first:"
    echo "   - Ubuntu/Debian: sudo apt-get install postgresql postgresql-contrib"
    echo "   - macOS: brew install postgresql"
    echo "   - Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

echo "✅ PostgreSQL found: $(psql --version)"

# Function to run SQL commands
run_sql() {
    local sql="$1"
    local db="${2:-postgres}"
    
    # Try different authentication methods
    if sudo -u postgres psql -d "$db" -c "$sql" 2>/dev/null; then
        return 0
    elif psql -U postgres -d "$db" -c "$sql" 2>/dev/null; then
        return 0
    elif psql -d "$db" -c "$sql" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Create database and user
echo "🔧 Setting up database and user..."

# Check if database exists
if run_sql "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';" | grep -q "1 row"; then
    echo "⚠️  Database '$DB_NAME' already exists"
else
    # Create database
    if run_sql "CREATE DATABASE \"$DB_NAME\";"; then
        echo "✅ Database '$DB_NAME' created successfully"
    else
        echo "❌ Failed to create database '$DB_NAME'"
        exit 1
    fi
fi

# Check if user exists
if run_sql "SELECT 1 FROM pg_user WHERE usename = '$DB_USER';" | grep -q "1 row"; then
    echo "⚠️  User '$DB_USER' already exists"
    # Update password
    if run_sql "ALTER USER \"$DB_USER\" WITH PASSWORD '$DB_PASSWORD';"; then
        echo "✅ Updated password for user '$DB_USER'"
    fi
else
    # Create user
    if run_sql "CREATE USER \"$DB_USER\" WITH PASSWORD '$DB_PASSWORD';"; then
        echo "✅ User '$DB_USER' created successfully"
    else
        echo "❌ Failed to create user '$DB_USER'"
        exit 1
    fi
fi

# Grant privileges
if run_sql "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$DB_USER\";"; then
    echo "✅ Granted database privileges to user '$DB_USER'"
fi

if run_sql "ALTER USER \"$DB_USER\" CREATEDB;"; then
    echo "✅ Granted CREATEDB privilege to user '$DB_USER'"
fi

# Test connection
echo "🧪 Testing database connection..."
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Connection test successful"
else
    echo "❌ Connection test failed"
    echo "💡 You might need to configure PostgreSQL authentication (pg_hba.conf)"
    exit 1
fi

# Update DATABASE_URL in .env file
echo "📝 Updating DATABASE_URL in .env file..."
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

# Create a temporary file with updated content
temp_file=$(mktemp)
while IFS= read -r line; do
    if [[ $line =~ ^DATABASE_URL= ]]; then
        echo "DATABASE_URL=$DATABASE_URL"
    else
        echo "$line"
    fi
done < .env > "$temp_file"

# Replace the original file
mv "$temp_file" .env

echo "✅ Updated DATABASE_URL in .env file"
echo "   DATABASE_URL=$DATABASE_URL"

echo ""
echo "🎉 Database Setup Complete!"
echo "============================================================"
echo "✅ Database '$DB_NAME' created"
echo "✅ User '$DB_USER' created with full privileges"
echo "✅ .env file updated with correct DATABASE_URL"
echo ""
echo "🚀 Next steps:"
echo "   1. cd backend"
echo "   2. python init_db.py  # Initialize tables and sample data"
echo "   3. uvicorn main:app --reload  # Start the backend server"
echo ""
echo "🔐 Database Connection Details:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   Database: $DB_NAME"
echo "   Username: $DB_USER"
echo "   Password: [hidden]"
