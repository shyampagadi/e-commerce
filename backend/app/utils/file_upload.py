import os
import uuid
from typing import List, Optional
from fastapi import UploadFile, HTTPException
from PIL import Image
import aiofiles
from app.core.config import settings

async def save_upload_file(upload_file: UploadFile, destination: str) -> str:
    """Save an uploaded file to the specified destination."""
    try:
        async with aiofiles.open(destination, 'wb') as f:
            content = await upload_file.read()
            await f.write(content)
        return destination
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Could not save file: {str(e)}")

def validate_image_file(file: UploadFile) -> bool:
    """Validate if the uploaded file is a valid image."""
    if not file.content_type or not file.content_type.startswith('image/'):
        return False
    
    # Check file extension
    file_extension = file.filename.split('.')[-1].lower() if file.filename else ''
    if file_extension not in settings.ALLOWED_EXTENSIONS:
        return False
    
    return True

def generate_unique_filename(original_filename: str) -> str:
    """Generate a unique filename while preserving the extension."""
    if not original_filename:
        return f"{uuid.uuid4().hex}.jpg"
    
    file_extension = original_filename.split('.')[-1].lower()
    unique_name = f"{uuid.uuid4().hex}.{file_extension}"
    return unique_name

async def process_and_save_image(
    upload_file: UploadFile,
    folder: str,
    max_size: tuple = (1200, 1200),
    quality: int = 85
) -> str:
    """Process and save an image with resizing and optimization."""
    
    # Validate file
    if not validate_image_file(upload_file):
        raise HTTPException(
            status_code=400,
            detail="Invalid image file. Only JPG, JPEG, PNG, GIF, and WEBP files are allowed."
        )
    
    # Check file size
    content = await upload_file.read()
    if len(content) > settings.MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size too large. Maximum size is {settings.MAX_FILE_SIZE / 1024 / 1024:.1f}MB"
        )
    
    # Create directory if it doesn't exist
    upload_dir = os.path.join(settings.UPLOAD_DIR, folder)
    os.makedirs(upload_dir, exist_ok=True)
    
    # Generate unique filename
    filename = generate_unique_filename(upload_file.filename)
    file_path = os.path.join(upload_dir, filename)
    
    try:
        # Save original file temporarily
        temp_path = f"{file_path}.temp"
        with open(temp_path, "wb") as temp_file:
            temp_file.write(content)
        
        # Process image with PIL
        with Image.open(temp_path) as img:
            # Convert to RGB if necessary
            if img.mode in ('RGBA', 'LA', 'P'):
                img = img.convert('RGB')
            
            # Resize if larger than max_size
            if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
                img.thumbnail(max_size, Image.Resampling.LANCZOS)
            
            # Save optimized image
            img.save(file_path, optimize=True, quality=quality)
        
        # Remove temporary file
        os.remove(temp_path)
        
        # Return relative path for database storage
        return f"{folder}/{filename}"
        
    except Exception as e:
        # Clean up files on error
        for path in [file_path, f"{file_path}.temp"]:
            if os.path.exists(path):
                os.remove(path)
        raise HTTPException(status_code=500, detail=f"Could not process image: {str(e)}")

async def delete_file(file_path: str) -> bool:
    """Delete a file from the uploads directory."""
    try:
        full_path = os.path.join(settings.UPLOAD_DIR, file_path)
        if os.path.exists(full_path):
            os.remove(full_path)
            return True
        return False
    except Exception:
        return False

def get_file_url(file_path: Optional[str]) -> Optional[str]:
    """Get the full URL for a file."""
    if not file_path:
        return None
    return f"/uploads/{file_path}"
