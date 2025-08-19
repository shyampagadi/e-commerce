#!/bin/bash

# E-Commerce Application Setup Script using UV
# This script sets up the entire project with uv for fast dependency management

set -e  # Exit on any error

echo "🚀 E-Commerce Application Setup with UV"
echo "========================================"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ UV is not installed!"
    echo ""
    echo "💡 Install UV first:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "   # or"
    echo "   pip install uv"
    exit 1
fi

echo "✅ UV found: $(uv --version)"

# Navigate to backend directory
echo ""
echo "📁 Setting up backend environment..."
cd backend

# Create virtual environment with uv
echo "🔧 Creating virtual environment with uv..."
uv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source .venv/bin/activate

# Install dependencies with uv (much faster than pip)
echo "📦 Installing Python dependencies with uv..."
uv pip install -r requirements.txt

echo "✅ Backend dependencies installed successfully!"

# Go back to root directory
cd ..

# Setup frontend
echo ""
echo "📁 Setting up frontend environment..."
cd frontend

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo ""
    echo "💡 Install Node.js first:"
    echo "   https://nodejs.org/en/download/"
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
npm install

echo "✅ Frontend dependencies installed successfully!"

# Go back to root directory
cd ..

echo ""
echo "🎉 Setup Complete!"
echo "========================================"
echo "✅ Backend virtual environment created with uv"
echo "✅ Python dependencies installed"
echo "✅ Frontend dependencies installed"
echo ""
echo "🚀 Next steps:"
echo ""
echo "1️⃣  Setup Database:"
echo "   python setup_database.py"
echo ""
echo "2️⃣  Initialize Database:"
echo "   cd backend"
echo "   source .venv/bin/activate  # Activate virtual environment"
echo "   python init_db.py"
echo ""
echo "3️⃣  Start Backend Server:"
echo "   uvicorn main:app --reload"
echo ""
echo "4️⃣  Start Frontend (in new terminal):"
echo "   cd frontend"
echo "   npm start"
echo ""
echo "🔗 Application URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
