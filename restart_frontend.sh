#!/bin/bash

echo "🔄 Restarting Frontend with Updated Configuration..."
echo "=================================================="

# Navigate to frontend directory
cd /mnt/c/Users/MohanS/Documents/e-commerce/frontend

# Kill any existing React development server
echo "🛑 Stopping existing React server..."
pkill -f "react-scripts start" || echo "No React server found"

# Clear npm cache
echo "🧹 Clearing npm cache..."
npm cache clean --force

# Install dependencies if needed
echo "📦 Checking dependencies..."
npm install

# Start the development server
echo "🚀 Starting React development server..."
echo "Environment variables:"
echo "  REACT_APP_API_URL=http://localhost:8000"
echo "  REACT_APP_API_BASE_URL=http://localhost:8000/api/v1"
echo ""
echo "The frontend will be available at: http://localhost:3000"
echo "Make sure to:"
echo "  1. Login with: user@ecommerce.com / user123"
echo "  2. Check the cart functionality"
echo "  3. Verify that product images are displayed correctly"
echo ""

npm start
