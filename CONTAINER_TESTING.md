# 🐳 Container Testing Guide

This guide explains how to test the Docker containers independently with fallback functionality.

## 🎯 Features Added

### Backend Fallback
- ✅ **Database Connection Check**: Automatically detects if database is available
- ✅ **Standalone Mode**: Runs without database using sample data
- ✅ **Fallback Endpoints**: Provides demo data when database is unavailable
- ✅ **Status Indicators**: Clear messages about operational mode

### Frontend Fallback
- ✅ **Backend Detection**: Automatically checks if backend is available
- ✅ **Demo Mode Banner**: Shows warning when using fallback data
- ✅ **Sample Data**: Provides demo products, categories, and user data
- ✅ **Graceful Degradation**: Full UI functionality with demo data

## 🧪 Testing Scenarios

### 1. Backend Only (No Database)
```bash
# Build and run backend container
docker build -f docker/Dockerfile.backend -t ecommerce-backend .
docker run -p 8000:8000 ecommerce-backend

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/products
curl http://localhost:8000/api/v1/categories
```

**Expected Response:**
```json
{
  "status": "healthy",
  "message": "API is running in standalone mode",
  "database": "not_connected"
}
```

### 2. Frontend Only (No Backend)
```bash
# Build and run frontend container
docker build -f docker/Dockerfile.frontend -t ecommerce-frontend .
docker run -p 3000:80 ecommerce-frontend

# Visit http://localhost:3000
```

**Expected Behavior:**
- Yellow demo banner appears at top
- Sample products are displayed
- All UI functionality works with demo data

### 3. Both Containers (No Database)
```bash
# Run both containers
docker run -d --name backend -p 8000:8000 ecommerce-backend
docker run -d --name frontend -p 3000:80 ecommerce-frontend

# Visit http://localhost:3000
```

**Expected Behavior:**
- Backend provides fallback API responses
- Frontend connects to backend but shows demo banner
- Full e-commerce experience with sample data

## 🔧 Quick Test Script

Run the automated test script:
```bash
./test-containers.sh
```

This script will:
1. Build both containers
2. Test backend endpoints
3. Test frontend accessibility
4. Clean up containers
5. Provide summary report

## 📊 Fallback Data

### Products
- Sample Laptop ($999.99)
- Sample Phone ($599.99)
- Sample Shirt ($29.99)

### Categories
- Electronics
- Clothing

### User
- Demo User (demo@example.com)

## 🚀 Production vs Demo Mode

### Production Mode (All Connected)
```
Frontend → Backend → Database
   ✅        ✅        ✅
```

### Demo Mode (Containers Only)
```
Frontend → Backend → [No Database]
   ✅        ✅           ❌
   ↓         ↓
Demo Data  Fallback API
```

## 🎯 Use Cases

### Development
- Test frontend without setting up backend
- Test backend without database setup
- Rapid prototyping and UI development

### CI/CD Pipeline
- Container build verification
- Independent component testing
- Integration testing preparation

### Demonstrations
- Show application functionality
- Client presentations
- Portfolio showcases

## 🔍 Debugging

### Backend Logs
```bash
docker logs <backend-container-id>
```

Look for:
- `✅ Database and routers loaded successfully` (Full mode)
- `⚠️ Database/routers not available` (Standalone mode)

### Frontend Console
Open browser dev tools and look for:
- `✅ Backend is available` (Connected)
- `⚠️ Backend not available, using fallback data` (Demo mode)

## 📝 Configuration

### Backend Environment Variables
```env
# Force standalone mode (for testing)
DATABASE_URL=""
DB_HOST=""
```

### Frontend Environment Variables
```env
# Point to different backend
REACT_APP_API_URL=http://localhost:8000
REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
```

## ✅ Success Criteria

### Backend Container Test
- [ ] Container builds successfully
- [ ] Health endpoint returns 200
- [ ] Fallback endpoints return sample data
- [ ] No database errors in logs

### Frontend Container Test
- [ ] Container builds successfully
- [ ] Application loads at port 3000/80
- [ ] Demo banner appears when backend unavailable
- [ ] Sample products display correctly

### Integration Test
- [ ] Frontend connects to backend
- [ ] API calls return fallback data
- [ ] User can browse demo products
- [ ] Cart functionality works with demo data

## 🎉 Benefits

1. **Independent Testing**: Test containers without dependencies
2. **Faster Development**: No need to set up full stack for UI work
3. **Better Demos**: Always have working application for presentations
4. **CI/CD Friendly**: Containers can be tested in isolation
5. **Error Resilience**: Application gracefully handles missing services

---

**Ready to test your containers independently!** 🚀
