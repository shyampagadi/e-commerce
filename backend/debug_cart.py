#!/usr/bin/env python3

import sys
import traceback
from app.database import get_db
from app.models.cart import CartItem
from app.models.product import Product
from app.models.user import User

def test_cart_functionality():
    """Test cart functionality directly"""
    
    try:
        # Get database session
        db = next(get_db())
        
        print("🔍 Testing cart functionality...")
        
        # Check if user exists
        user = db.query(User).filter(User.email == "user@ecommerce.com").first()
        if not user:
            print("❌ User not found")
            return False
        print(f"✅ User found: {user.email} (ID: {user.id})")
        
        # Check if product exists
        product = db.query(Product).filter(Product.id == 1).first()
        if not product:
            print("❌ Product with ID 1 not found")
            return False
        print(f"✅ Product found: {product.name} (ID: {product.id})")
        
        # Check if cart item already exists
        existing_item = db.query(CartItem).filter(
            CartItem.user_id == user.id,
            CartItem.product_id == product.id
        ).first()
        
        if existing_item:
            print(f"🔄 Cart item already exists, updating quantity...")
            existing_item.quantity += 1
            db.commit()
            db.refresh(existing_item)
            print(f"✅ Updated cart item: {existing_item}")
        else:
            print(f"➕ Creating new cart item...")
            cart_item = CartItem(
                user_id=user.id,
                product_id=product.id,
                quantity=1
            )
            db.add(cart_item)
            db.commit()
            db.refresh(cart_item)
            print(f"✅ Created cart item: {cart_item}")
        
        # Get all cart items for user
        cart_items = db.query(CartItem).filter(CartItem.user_id == user.id).all()
        print(f"🛒 Total cart items for user: {len(cart_items)}")
        
        for item in cart_items:
            product = db.query(Product).filter(Product.id == item.product_id).first()
            print(f"  - {product.name}: {item.quantity} items")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print(f"📋 Traceback:")
        traceback.print_exc()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    success = test_cart_functionality()
    sys.exit(0 if success else 1)
