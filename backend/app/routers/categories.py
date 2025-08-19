from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models.category import Category
from app.models.product import Product
from app.models.user import User
from app.schemas.category import CategoryCreate, CategoryUpdate, CategoryResponse, CategoryWithProducts
from app.utils.auth import get_current_admin_user
from app.utils.file_upload import process_and_save_image, delete_file
from app.utils.slug import create_unique_slug

router = APIRouter()

@router.get("/", response_model=List[CategoryWithProducts])
async def get_categories(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    active_only: bool = Query(True),
    db: Session = Depends(get_db)
):
    """Get all categories with product counts."""
    
    query = db.query(Category)
    
    if active_only:
        query = query.filter(Category.is_active == True)
    
    categories = query.order_by(Category.sort_order, Category.name).offset(skip).limit(limit).all()
    
    # Add product counts
    result = []
    for category in categories:
        products_count = db.query(func.count(Product.id)).filter(
            Product.category_id == category.id,
            Product.is_active == True
        ).scalar()
        
        category_dict = CategoryWithProducts.from_orm(category).dict()
        category_dict['products_count'] = products_count
        result.append(CategoryWithProducts(**category_dict))
    
    return result

@router.get("/{category_id}", response_model=CategoryResponse)
async def get_category(category_id: int, db: Session = Depends(get_db)):
    """Get category by ID."""
    
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    return category

@router.get("/slug/{slug}", response_model=CategoryResponse)
async def get_category_by_slug(slug: str, db: Session = Depends(get_db)):
    """Get category by slug."""
    
    category = db.query(Category).filter(Category.slug == slug).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    return category

@router.post("/", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
async def create_category(
    category_data: CategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Create a new category (admin only)."""
    
    # Check if category name already exists
    existing_category = db.query(Category).filter(Category.name == category_data.name).first()
    if existing_category:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category name already exists"
        )
    
    # Create unique slug
    slug = create_unique_slug(db, Category, category_data.name)
    
    # Create category
    db_category = Category(
        name=category_data.name,
        slug=slug,
        description=category_data.description,
        is_active=category_data.is_active,
        sort_order=category_data.sort_order
    )
    
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    
    return db_category

@router.put("/{category_id}", response_model=CategoryResponse)
async def update_category(
    category_id: int,
    category_update: CategoryUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Update category (admin only)."""
    
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    # Check if new name already exists (if name is being updated)
    if category_update.name and category_update.name != category.name:
        existing_category = db.query(Category).filter(
            Category.name == category_update.name,
            Category.id != category_id
        ).first()
        if existing_category:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Category name already exists"
            )
    
    # Update category fields
    update_data = category_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)
    
    # Update slug if name changed
    if category_update.name:
        category.slug = create_unique_slug(db, Category, category_update.name, exclude_id=category_id)
    
    db.commit()
    db.refresh(category)
    
    return category

@router.post("/{category_id}/image", response_model=CategoryResponse)
async def upload_category_image(
    category_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Upload category image (admin only)."""
    
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    # Delete old image if exists
    if category.image:
        await delete_file(category.image)
    
    # Save new image
    image_path = await process_and_save_image(
        file,
        "categories",
        max_size=(800, 600),
        quality=85
    )
    
    category.image = image_path
    db.commit()
    db.refresh(category)
    
    return category

@router.delete("/{category_id}/image", response_model=CategoryResponse)
async def delete_category_image(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Delete category image (admin only)."""
    
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    # Delete image file
    if category.image:
        await delete_file(category.image)
        category.image = None
        db.commit()
        db.refresh(category)
    
    return category

@router.delete("/{category_id}")
async def delete_category(
    category_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Delete category (admin only)."""
    
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    # Check if category has products
    products_count = db.query(func.count(Product.id)).filter(Product.category_id == category_id).scalar()
    if products_count > 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot delete category with {products_count} products. Move or delete products first."
        )
    
    # Delete image file if exists
    if category.image:
        await delete_file(category.image)
    
    db.delete(category)
    db.commit()
    
    return {"message": "Category deleted successfully"}
