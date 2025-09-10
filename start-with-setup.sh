#!/bin/bash

# 🚀 E-Commerce Application Startup with Database Setup
# This script starts the application with automatic database initialization

echo "🚀 Starting E-Commerce Application with Database Setup..."

# Start database first
echo "📋 Step 1: Starting PostgreSQL database..."
docker-compose up -d database

# Wait for database to be healthy
echo "⏳ Step 2: Waiting for database to be ready..."
docker-compose up --wait database

# Run database setup
echo "🔧 Step 3: Setting up database schema and sample data..."
docker-compose up db-setup

# Start backend (will wait for db-setup to complete)
echo "🖥️  Step 4: Starting backend API..."
docker-compose up -d backend

# Start frontend
echo "🌐 Step 5: Starting frontend..."
docker-compose up -d frontend

echo "✅ Application started successfully!"
echo "📋 Access your application:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"

echo "🔐 Default Login Credentials:"
echo "   Admin: admin@ecommerce.com / admin123"
echo "   User:  user@ecommerce.com / user123"
