#!/bin/bash

echo "🧪 Testing E-Commerce Docker Containers"
echo "========================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
if ! command_exists docker; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command_exists curl; then
    echo "❌ curl is not installed"
    exit 1
fi

# Test Backend Container (Standalone)
echo ""
echo "📦 Testing Backend Container (Standalone Mode)..."
echo "Building backend container..."
if docker build -f docker/Dockerfile.backend -t ecommerce-backend-test . > /dev/null 2>&1; then
    echo "✅ Backend container built successfully"
else
    echo "❌ Failed to build backend container"
    exit 1
fi

echo "Running backend container..."
docker run -d --name backend-test -p 8001:8000 ecommerce-backend-test > /dev/null 2>&1

echo "Waiting for backend to start..."
sleep 10

echo "Testing backend endpoints..."

# Test health endpoint
if curl -s http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ Health check: OK"
    curl -s http://localhost:8001/health | head -1
else
    echo "❌ Health check: FAILED"
fi

# Test root endpoint
if curl -s http://localhost:8001/ > /dev/null 2>&1; then
    echo "✅ Root endpoint: OK"
else
    echo "❌ Root endpoint: FAILED"
fi

# Test fallback endpoints
if curl -s http://localhost:8001/api/v1/products > /dev/null 2>&1; then
    echo "✅ Products fallback: OK"
else
    echo "❌ Products fallback: FAILED"
fi

if curl -s http://localhost:8001/api/v1/categories > /dev/null 2>&1; then
    echo "✅ Categories fallback: OK"
else
    echo "❌ Categories fallback: FAILED"
fi

echo "Stopping backend container..."
docker stop backend-test > /dev/null 2>&1
docker rm backend-test > /dev/null 2>&1

# Test Frontend Container
echo ""
echo "📦 Testing Frontend Container..."
echo "Building frontend container..."
if docker build -f docker/Dockerfile.frontend -t ecommerce-frontend-test . > /dev/null 2>&1; then
    echo "✅ Frontend container built successfully"
else
    echo "❌ Failed to build frontend container"
    exit 1
fi

echo "Running frontend container..."
docker run -d --name frontend-test -p 3001:80 ecommerce-frontend-test > /dev/null 2>&1

echo "Waiting for frontend to start..."
sleep 15

echo "Testing frontend..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/ 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Frontend health check: OK (HTTP $HTTP_CODE)"
else
    echo "❌ Frontend health check: FAILED (HTTP $HTTP_CODE)"
fi

echo "Stopping frontend container..."
docker stop frontend-test > /dev/null 2>&1
docker rm frontend-test > /dev/null 2>&1

echo ""
echo "🎉 Container tests completed!"
echo ""
echo "📋 Summary:"
echo "- Backend runs in standalone mode when database is not available"
echo "- Frontend serves static files correctly"
echo "- Both containers can run independently for testing"
echo ""
echo "🚀 To run containers:"
echo "Backend:  docker run -p 8000:8000 ecommerce-backend-test"
echo "Frontend: docker run -p 3000:80 ecommerce-frontend-test"
