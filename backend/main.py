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

from app.database import engine, Base
from app.routers import auth, products, categories, orders, users, cart
from app.core.config import settings

# Load environment variables
load_dotenv()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create database tables
    Base.metadata.create_all(bind=engine)
    
    # Create uploads directory
    os.makedirs("uploads", exist_ok=True)
    os.makedirs("uploads/products", exist_ok=True)
    
    yield

# Create FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="A modern e-commerce API built with FastAPI",
    version="1.0.0",
    lifespan=lifespan,
    redirect_slashes=False  # Prevent automatic redirects that lose CORS headers
)

# Lightweight request logging middleware to help debug client requests (method/path).
@app.middleware("http")
async def log_requests(request: Request, call_next):
    try:
        # Print method and path; avoid reading body to not consume stream
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

# Mount static files
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Include routers
app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["Users"])
app.include_router(categories.router, prefix=f"{settings.API_V1_STR}/categories", tags=["Categories"])
app.include_router(products.router, prefix=f"{settings.API_V1_STR}/products", tags=["Products"])
app.include_router(cart.router, prefix=f"{settings.API_V1_STR}/cart", tags=["Cart"])
app.include_router(orders.router, prefix=f"{settings.API_V1_STR}/orders", tags=["Orders"])

@app.get("/")
async def root():
    return {"message": "Welcome to E-Commerce API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "API is running"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
