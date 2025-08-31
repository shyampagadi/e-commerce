from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv
from starlette.requests import Request
import logging

# Load environment variables
load_dotenv()

# Try to import database and routers, fallback if not available
try:
    from app.database import engine, Base
    from app.routers import auth, products, categories, orders, users, cart
    from app.core.config import settings
    DATABASE_AVAILABLE = True
    print("✅ Database and routers loaded successfully")
except Exception as e:
    print(f"⚠️ Database/routers not available: {e}")
    DATABASE_AVAILABLE = False
    # Fallback settings
    class FallbackSettings:
        PROJECT_NAME = "E-Commerce API (Standalone)"
        API_V1_STR = "/api/v1"
    settings = FallbackSettings()

@asynccontextmanager
async def lifespan(app: FastAPI):
    if DATABASE_AVAILABLE:
        try:
            # Create database tables
            Base.metadata.create_all(bind=engine)
            
            # Create uploads directory
            os.makedirs("uploads", exist_ok=True)
            os.makedirs("uploads/products", exist_ok=True)
            print("✅ Database initialized successfully")
        except Exception as e:
            print(f"⚠️ Database initialization failed: {e}")
    else:
        print("⚠️ Running in standalone mode without database")
    
    yield

# Create FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="A modern e-commerce API built with FastAPI",
    version="1.0.0",
    lifespan=lifespan,
    redirect_slashes=False
)

# Lightweight request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    try:
        headers_preview = {k: v for k, v in list(request.headers.items())[:5]}
        print(f"[REQ] {request.method} {request.url.path} headers={headers_preview}")
    except Exception:
        print("[REQ] error while logging request")
    response = await call_next(request)
    return response

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001", "http://127.0.0.1:3000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Mount static files if uploads directory exists
try:
    if os.path.exists("uploads"):
        app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
        print("✅ Static files mounted successfully")
    else:
        print("⚠️ Uploads directory not found, skipping static files")
except Exception as e:
    print(f"⚠️ Failed to mount static files: {e}")

# Include routers only if database is available
if DATABASE_AVAILABLE:
    app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
    app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["Users"])
    app.include_router(categories.router, prefix=f"{settings.API_V1_STR}/categories", tags=["Categories"])
    app.include_router(products.router, prefix=f"{settings.API_V1_STR}/products", tags=["Products"])
    app.include_router(cart.router, prefix=f"{settings.API_V1_STR}/cart", tags=["Cart"])
    app.include_router(orders.router, prefix=f"{settings.API_V1_STR}/orders", tags=["Orders"])

@app.get("/")
async def root():
    if DATABASE_AVAILABLE:
        return {"message": "Welcome to E-Commerce API", "version": "1.0.0", "status": "fully_operational"}
    else:
        return {
            "message": "E-Commerce API - Standalone Mode", 
            "version": "1.0.0", 
            "status": "standalone",
            "note": "Database not connected. This is a standalone container for testing."
        }

@app.get("/health")
async def health_check():
    if DATABASE_AVAILABLE:
        return {"status": "healthy", "message": "API is running with database"}
    else:
        return {"status": "healthy", "message": "API is running in standalone mode", "database": "not_connected"}

# Fallback endpoints when database is not available
if not DATABASE_AVAILABLE:
    @app.get(f"{settings.API_V1_STR}/products")
    async def get_products_fallback():
        return {
            "message": "Database not connected",
            "products": [
                {"id": 1, "name": "Sample Product", "price": 99.99, "description": "Test product"},
                {"id": 2, "name": "Another Product", "price": 149.99, "description": "Another test product"}
            ],
            "total": 2,
            "note": "This is sample data. Connect database for real products."
        }

    @app.get(f"{settings.API_V1_STR}/categories")
    async def get_categories_fallback():
        return {
            "message": "Database not connected",
            "categories": [
                {"id": 1, "name": "Electronics", "slug": "electronics"},
                {"id": 2, "name": "Clothing", "slug": "clothing"}
            ],
            "note": "This is sample data. Connect database for real categories."
        }

    @app.get(f"{settings.API_V1_STR}/auth/me")
    async def get_user_fallback():
        return {
            "message": "Database not connected",
            "user": {"id": 1, "email": "demo@example.com", "name": "Demo User"},
            "note": "This is sample data. Connect database for authentication."
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
