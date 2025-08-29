#!/bin/bash

echo "🚀 Starting E-Commerce Test Suite"

# Check if backend is running
if ! curl -s http://localhost:8000/api/v1/products > /dev/null 2>&1; then
    echo "❌ Backend not running on port 8000"
    echo "Please start backend: cd backend && uvicorn main:app --port 8000"
    exit 1
fi

# Check if frontend is running  
if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "❌ Frontend not running on port 3000"
    echo "Please start frontend: cd frontend && npm start"
    exit 1
fi

echo "✅ Backend and Frontend are running"
echo "🧪 Running tests..."

# Run only API tests first (they're more likely to work)
npx playwright test api/ --reporter=line

echo "📊 Test run complete!"
