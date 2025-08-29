from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Database (Manual PostgreSQL Setup)
    DATABASE_URL: str = "postgresql://postgres:admin@localhost:5432/ecommerce_db"
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "ecommerce_db"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "admin"
    
    # JWT
    SECRET_KEY: str = "your-super-secret-jwt-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # API
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "E-Commerce API"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:3001"]
    
    # File Upload
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE: int = 5242880  # 5MB
    ALLOWED_EXTENSIONS: List[str] = ["jpg", "jpeg", "png", "gif", "webp"]
    
    # Frontend Configuration
    REACT_APP_API_URL: str = "http://localhost:8000"
    REACT_APP_API_BASE_URL: str = "http://localhost:8000/api/v1"
    
    # Email (Optional)
    SMTP_TLS: bool = True
    SMTP_PORT: int = 587
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Parse CORS origins from environment variable if it's a string
        cors_origins = os.getenv("BACKEND_CORS_ORIGINS")
        if cors_origins and isinstance(cors_origins, str):
            if cors_origins.startswith("[") and cors_origins.endswith("]"):
                # Handle JSON-like format
                import json
                try:
                    self.BACKEND_CORS_ORIGINS = json.loads(cors_origins)
                except json.JSONDecodeError:
                    # Fallback to comma-separated
                    self.BACKEND_CORS_ORIGINS = [origin.strip() for origin in cors_origins.strip("[]").replace('"', '').split(",")]
            else:
                # Handle comma-separated format
                self.BACKEND_CORS_ORIGINS = [origin.strip() for origin in cors_origins.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "allow"  # Allow extra fields from .env

settings = Settings()
