import re
from slugify import slugify
from sqlalchemy.orm import Session
from typing import Type, Optional

def create_slug(text: str) -> str:
    """Create a URL-friendly slug from text."""
    return slugify(text, lowercase=True, max_length=100)

def create_unique_slug(
    db: Session,
    model: Type,
    text: str,
    slug_field: str = "slug",
    exclude_id: Optional[int] = None
) -> str:
    """Create a unique slug by appending numbers if necessary."""
    base_slug = create_slug(text)
    slug = base_slug
    counter = 1
    
    while True:
        # Build query
        query = db.query(model).filter(getattr(model, slug_field) == slug)
        
        # Exclude current record if updating
        if exclude_id:
            query = query.filter(model.id != exclude_id)
        
        # Check if slug exists
        if not query.first():
            return slug
        
        # Try next variation
        slug = f"{base_slug}-{counter}"
        counter += 1
        
        # Prevent infinite loop
        if counter > 1000:
            import uuid
            return f"{base_slug}-{uuid.uuid4().hex[:8]}"
