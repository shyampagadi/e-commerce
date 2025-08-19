from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.cart import CartItem
from app.models.product import Product
from app.models.user import User
from app.schemas.cart import CartItemCreate, CartItemUpdate, CartItemResponse, CartResponse, CartSummary
from app.utils.auth import get_current_active_user

router = APIRouter()

@router.get("", response_model=CartResponse)
@router.get("/", response_model=CartResponse)
async def get_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get user's cart with product details."""
    
    try:
        print(f"🛒 Getting cart for user: {current_user.id}")
        
        cart_items = db.query(CartItem).filter(CartItem.user_id == current_user.id).all()
        print(f"📦 Found {len(cart_items)} cart items")
        
        # Prepare response with product details
        items_with_products = []
        total_items = 0
        subtotal = 0.0
        
        for item in cart_items:
            product = db.query(Product).filter(Product.id == item.product_id).first()
            if product and product.is_active:
                # Create cart item response manually to avoid serialization issues
                cart_item_data = {
                    'id': item.id,
                    'product_id': item.product_id,
                    'quantity': item.quantity,
                    'created_at': item.created_at,
                    'updated_at': item.updated_at,
                    'product': {
                        'id': product.id,
                        'name': product.name,
                        'slug': product.slug,
                        'price': float(product.price),
                        'compare_price': float(product.compare_price) if product.compare_price else None,
                        'images': product.images,
                        'is_in_stock': product.is_in_stock,
                        'quantity': product.quantity if product.track_quantity else None
                    }
                }
                
                items_with_products.append(CartItemResponse(**cart_item_data))
                total_items += item.quantity
                subtotal += float(product.price) * item.quantity
                
                print(f"  ✅ Added item: {product.name} x {item.quantity}")
        
        response = CartResponse(
            items=items_with_products,
            total_items=total_items,
            subtotal=subtotal
        )
        
        print(f"🛒 Cart response: {total_items} items, subtotal: ${subtotal:.2f}")
        return response
        
    except Exception as e:
        print(f"❌ Error in get_cart: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get cart: {str(e)}"
        )

@router.get("/summary", response_model=CartSummary)
async def get_cart_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get cart summary (total items and subtotal)."""
    
    cart_items = db.query(CartItem).filter(CartItem.user_id == current_user.id).all()
    
    total_items = 0
    subtotal = 0.0
    
    for item in cart_items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if product and product.is_active:
            total_items += item.quantity
            subtotal += product.price * item.quantity
    
    return CartSummary(
        total_items=total_items,
        subtotal=subtotal
    )

@router.post("/items", response_model=CartItemResponse, status_code=status.HTTP_201_CREATED)
async def add_to_cart(
    item_data: CartItemCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Add item to cart or update quantity if item already exists."""
    
    try:
        print(f"🛒 Adding to cart: user_id={current_user.id}, product_id={item_data.product_id}, quantity={item_data.quantity}")
        
        # Check if product exists and is active
        product = db.query(Product).filter(
            Product.id == item_data.product_id,
            Product.is_active == True
        ).first()
        
        if not product:
            print(f"❌ Product not found: {item_data.product_id}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Product not found or inactive"
            )
        
        print(f"✅ Product found: {product.name}")
        
        # Check stock availability
        if product.track_quantity and not product.continue_selling:
            if product.quantity < item_data.quantity:
                print(f"❌ Insufficient stock: requested={item_data.quantity}, available={product.quantity}")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Only {product.quantity} items available in stock"
                )
        
        # Check if item already exists in cart
        existing_item = db.query(CartItem).filter(
            CartItem.user_id == current_user.id,
            CartItem.product_id == item_data.product_id
        ).first()
        
        if existing_item:
            print(f"🔄 Updating existing cart item: {existing_item.id}")
            # Update quantity
            new_quantity = existing_item.quantity + item_data.quantity
            
            # Check stock for new quantity
            if product.track_quantity and not product.continue_selling:
                if product.quantity < new_quantity:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Only {product.quantity} items available in stock"
                    )
            
            existing_item.quantity = new_quantity
            db.commit()
            db.refresh(existing_item)
            print(f"✅ Updated cart item: {existing_item}")
            
            # Return the cart item without product details for now
            return CartItemResponse(
                id=existing_item.id,
                product_id=existing_item.product_id,
                quantity=existing_item.quantity,
                created_at=existing_item.created_at,
                updated_at=existing_item.updated_at
            )
        else:
            print(f"➕ Creating new cart item")
            # Create new cart item
            cart_item = CartItem(
                user_id=current_user.id,
                product_id=item_data.product_id,
                quantity=item_data.quantity
            )
            
            db.add(cart_item)
            db.commit()
            db.refresh(cart_item)
            print(f"✅ Created cart item: {cart_item}")
            
            # Return the cart item without product details for now
            return CartItemResponse(
                id=cart_item.id,
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
                created_at=cart_item.created_at,
                updated_at=cart_item.updated_at
            )
            
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        print(f"❌ Unexpected error in add_to_cart: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}"
        )

@router.put("/items/{item_id}", response_model=CartItemResponse)
async def update_cart_item(
    item_id: int,
    item_update: CartItemUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Update cart item quantity."""
    
    # Get cart item
    cart_item = db.query(CartItem).filter(
        CartItem.id == item_id,
        CartItem.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cart item not found"
        )
    
    # Check product availability
    product = db.query(Product).filter(Product.id == cart_item.product_id).first()
    if not product or not product.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Product is no longer available"
        )
    
    # Check stock availability
    if product.track_quantity and not product.continue_selling:
        if product.quantity < item_update.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Only {product.quantity} items available in stock"
            )
    
    # Update quantity
    cart_item.quantity = item_update.quantity
    db.commit()
    db.refresh(cart_item)
    
    return cart_item

@router.delete("/items/{item_id}")
async def remove_from_cart(
    item_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Remove item from cart."""
    
    cart_item = db.query(CartItem).filter(
        CartItem.id == item_id,
        CartItem.user_id == current_user.id
    ).first()
    
    if not cart_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cart item not found"
        )
    
    db.delete(cart_item)
    db.commit()
    
    return {"message": "Item removed from cart"}

@router.delete("/")
async def clear_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Clear all items from cart."""
    
    db.query(CartItem).filter(CartItem.user_id == current_user.id).delete()
    db.commit()
    
    return {"message": "Cart cleared successfully"}
