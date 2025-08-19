from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_, func
from app.database import get_db
from app.models.product import Product
from app.models.category import Category
from app.models.user import User
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse, ProductWithCategory, ProductListResponse
from app.utils.auth import get_current_admin_user
from app.utils.file_upload import process_and_save_image, delete_file
from app.utils.slug import create_unique_slug
import math

router = APIRouter()

@router.get("/", response_model=ProductListResponse)
async def get_products(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    category_id: Optional[int] = Query(None),
    search: Optional[str] = Query(None),
    min_price: Optional[float] = Query(None, ge=0),
    max_price: Optional[float] = Query(None, ge=0),
    featured_only: bool = Query(False),
    active_only: bool = Query(True),
    in_stock_only: bool = Query(False),
    sort_by: str = Query("created_at", regex="^(name|price|created_at|updated_at)$"),
    sort_order: str = Query("desc", regex="^(asc|desc)$"),
    db: Session = Depends(get_db)
):
    """Get products with filtering, searching, and pagination."""
    
    query = db.query(Product)
    
    # Apply filters
    if active_only:
        query = query.filter(Product.is_active == True)
    
    if category_id:
        query = query.filter(Product.category_id == category_id)
    
    if featured_only:
        query = query.filter(Product.is_featured == True)
    
    if in_stock_only:
        query = query.filter(
            or_(
                and_(Product.track_quantity == True, Product.quantity > 0),
                and_(Product.track_quantity == False),
                Product.continue_selling == True
            )
        )
    
    if min_price is not None:
        query = query.filter(Product.price >= min_price)
    
    if max_price is not None:
        query = query.filter(Product.price <= max_price)
    
    if search:
        search_term = f"%{search}%"
        query = query.filter(
            or_(
                Product.name.ilike(search_term),
                Product.description.ilike(search_term),
                Product.short_description.ilike(search_term),
                Product.sku.ilike(search_term)
            )
        )
    
    # Get total count before pagination
    total = query.count()
    
    # Apply sorting
    if sort_order == "desc":
        query = query.order_by(getattr(Product, sort_by).desc())
    else:
        query = query.order_by(getattr(Product, sort_by).asc())
    
    # Apply pagination
    products = query.offset(skip).limit(limit).all()
    
    # Add category information to each product
    products_with_categories = []
    for product in products:
        # Convert product to dict first
        product_dict = {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'short_description': product.short_description,
            'price': product.price,
            'compare_price': product.compare_price,
            'cost_price': product.cost_price,
            'sku': product.sku,
            'barcode': product.barcode,
            'quantity': product.quantity,
            'min_quantity': product.min_quantity,
            'track_quantity': product.track_quantity,
            'continue_selling': product.continue_selling,
            'is_active': product.is_active,
            'is_featured': product.is_featured,
            'weight': product.weight,
            'dimensions': product.dimensions,
            'tags': product.tags,
            'meta_title': product.meta_title,
            'meta_description': product.meta_description,
            'sort_order': product.sort_order,
            'category_id': product.category_id,
            'slug': product.slug,
            'images': product.images,
            'created_at': product.created_at,
            'updated_at': product.updated_at,
            'is_in_stock': product.is_in_stock,
            'discount_percentage': product.discount_percentage,
            'category': None
        }
        
        # Get category information
        if product.category_id:
            category = db.query(Category).filter(Category.id == product.category_id).first()
            if category:
                product_dict['category'] = {
                    'id': category.id,
                    'name': category.name,
                    'slug': category.slug
                }
        
        products_with_categories.append(product_dict)
    
    # Calculate pagination info
    pages = math.ceil(total / limit) if limit > 0 else 1
    page = (skip // limit) + 1 if limit > 0 else 1
    
    return {
        "products": products_with_categories,
        "total": total,
        "page": page,
        "per_page": limit,
        "pages": pages
    }

@router.get("/featured", response_model=List[ProductResponse])
async def get_featured_products(
    limit: int = Query(8, ge=1, le=20),
    db: Session = Depends(get_db)
):
    """Get featured products."""
    
    products = db.query(Product).filter(
        Product.is_featured == True,
        Product.is_active == True
    ).order_by(Product.sort_order, Product.created_at.desc()).limit(limit).all()
    
    return products

@router.get("/{product_id}", response_model=ProductWithCategory)
async def get_product(product_id: int, db: Session = Depends(get_db)):
    """Get product by ID with category information."""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Convert product to dict
    product_dict = {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'short_description': product.short_description,
        'price': product.price,
        'compare_price': product.compare_price,
        'cost_price': product.cost_price,
        'sku': product.sku,
        'barcode': product.barcode,
        'quantity': product.quantity,
        'min_quantity': product.min_quantity,
        'track_quantity': product.track_quantity,
        'continue_selling': product.continue_selling,
        'is_active': product.is_active,
        'is_featured': product.is_featured,
        'weight': product.weight,
        'dimensions': product.dimensions,
        'tags': product.tags,
        'meta_title': product.meta_title,
        'meta_description': product.meta_description,
        'sort_order': product.sort_order,
        'category_id': product.category_id,
        'slug': product.slug,
        'images': product.images,
        'created_at': product.created_at,
        'updated_at': product.updated_at,
        'is_in_stock': product.is_in_stock,
        'discount_percentage': product.discount_percentage,
        'category': None
    }
    
    # Get category information
    if product.category_id:
        category = db.query(Category).filter(Category.id == product.category_id).first()
        if category:
            product_dict['category'] = {
                'id': category.id,
                'name': category.name,
                'slug': category.slug
            }
    
    return product_dict

@router.get("/slug/{slug}", response_model=ProductWithCategory)
async def get_product_by_slug(slug: str, db: Session = Depends(get_db)):
    """Get product by slug with category information."""
    
    product = db.query(Product).filter(Product.slug == slug).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Convert product to dict
    product_dict = {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'short_description': product.short_description,
        'price': product.price,
        'compare_price': product.compare_price,
        'cost_price': product.cost_price,
        'sku': product.sku,
        'barcode': product.barcode,
        'quantity': product.quantity,
        'min_quantity': product.min_quantity,
        'track_quantity': product.track_quantity,
        'continue_selling': product.continue_selling,
        'is_active': product.is_active,
        'is_featured': product.is_featured,
        'weight': product.weight,
        'dimensions': product.dimensions,
        'tags': product.tags,
        'meta_title': product.meta_title,
        'meta_description': product.meta_description,
        'sort_order': product.sort_order,
        'category_id': product.category_id,
        'slug': product.slug,
        'images': product.images,
        'created_at': product.created_at,
        'updated_at': product.updated_at,
        'is_in_stock': product.is_in_stock,
        'discount_percentage': product.discount_percentage,
        'category': None
    }
    
    # Get category information
    if product.category_id:
        category = db.query(Category).filter(Category.id == product.category_id).first()
        if category:
            product_dict['category'] = {
                'id': category.id,
                'name': category.name,
                'slug': category.slug
            }
    
    return product_dict

@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_data: ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Create a new product (admin only)."""
    
    # Check if category exists
    category = db.query(Category).filter(Category.id == product_data.category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category not found"
        )
    
    # Check if SKU already exists
    existing_product = db.query(Product).filter(Product.sku == product_data.sku.upper()).first()
    if existing_product:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="SKU already exists"
        )
    
    # Create unique slug
    slug = create_unique_slug(db, Product, product_data.name)
    
    # Create product
    db_product = Product(
        name=product_data.name,
        slug=slug,
        description=product_data.description,
        short_description=product_data.short_description,
        price=product_data.price,
        compare_price=product_data.compare_price,
        cost_price=product_data.cost_price,
        sku=product_data.sku.upper(),
        barcode=product_data.barcode,
        quantity=product_data.quantity,
        min_quantity=product_data.min_quantity,
        track_quantity=product_data.track_quantity,
        continue_selling=product_data.continue_selling,
        is_active=product_data.is_active,
        is_featured=product_data.is_featured,
        weight=product_data.weight,
        dimensions=product_data.dimensions,
        tags=product_data.tags,
        meta_title=product_data.meta_title,
        meta_description=product_data.meta_description,
        sort_order=product_data.sort_order,
        category_id=product_data.category_id,
        images=[]
    )
    
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    
    return db_product

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    product_update: ProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Update product (admin only)."""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Check if new category exists (if category is being updated)
    if product_update.category_id:
        category = db.query(Category).filter(Category.id == product_update.category_id).first()
        if not category:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Category not found"
            )
    
    # Check if new SKU already exists (if SKU is being updated)
    if product_update.sku and product_update.sku.upper() != product.sku:
        existing_product = db.query(Product).filter(
            Product.sku == product_update.sku.upper(),
            Product.id != product_id
        ).first()
        if existing_product:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="SKU already exists"
            )
    
    # Update product fields
    update_data = product_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if field == 'sku' and value:
            setattr(product, field, value.upper())
        else:
            setattr(product, field, value)
    
    # Update slug if name changed
    if product_update.name:
        product.slug = create_unique_slug(db, Product, product_update.name, exclude_id=product_id)
    
    db.commit()
    db.refresh(product)
    
    return product

@router.post("/{product_id}/images", response_model=ProductResponse)
async def upload_product_images(
    product_id: int,
    files: List[UploadFile] = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Upload product images (admin only)."""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    if len(files) > 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 10 images allowed per product"
        )
    
    # Process and save images
    image_paths = []
    for file in files:
        try:
            image_path = await process_and_save_image(
                file,
                "products",
                max_size=(1200, 1200),
                quality=85
            )
            image_paths.append(image_path)
        except Exception as e:
            # Clean up already uploaded images on error
            for path in image_paths:
                await delete_file(path)
            raise e
    
    # Update product images
    current_images = product.images or []
    product.images = current_images + image_paths
    
    db.commit()
    db.refresh(product)
    
    return product

@router.delete("/{product_id}/images/{image_index}")
async def delete_product_image(
    product_id: int,
    image_index: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Delete a specific product image (admin only)."""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    if not product.images or image_index >= len(product.images) or image_index < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid image index"
        )
    
    # Delete image file
    image_path = product.images[image_index]
    await delete_file(image_path)
    
    # Remove from product images list
    product.images.pop(image_index)
    db.commit()
    db.refresh(product)
    
    return {"message": "Image deleted successfully"}

@router.delete("/{product_id}")
async def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Delete product (admin only)."""
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    
    # Delete all product images
    if product.images:
        for image_path in product.images:
            await delete_file(image_path)
    
    db.delete(product)
    db.commit()
    
    return {"message": "Product deleted successfully"}
