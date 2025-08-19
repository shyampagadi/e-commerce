from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.database import get_db
from app.models.order import Order, OrderItem, OrderStatus, PaymentStatus
from app.models.product import Product
from app.models.cart import CartItem
from app.models.user import User
from app.schemas.order import OrderCreate, OrderUpdate, OrderResponse, OrderWithItems, OrderListResponse
from app.utils.auth import get_current_active_user, get_current_admin_user
import uuid
import math
from datetime import datetime

router = APIRouter()

def generate_order_number() -> str:
    """Generate a unique order number."""
    timestamp = datetime.now().strftime("%Y%m%d")
    unique_id = str(uuid.uuid4().hex[:8]).upper()
    return f"ORD-{timestamp}-{unique_id}"

@router.get("/", response_model=OrderListResponse)
async def get_orders(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[OrderStatus] = Query(None),
    payment_status: Optional[PaymentStatus] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get user's orders with pagination and filtering."""
    
    query = db.query(Order).filter(Order.user_id == current_user.id)
    
    # Apply filters
    if status:
        query = query.filter(Order.status == status)
    
    if payment_status:
        query = query.filter(Order.payment_status == payment_status)
    
    # Get total count
    total = query.count()
    
    # Apply pagination and ordering
    orders = query.order_by(desc(Order.created_at)).offset(skip).limit(limit).all()
    
    # Calculate pagination info
    pages = math.ceil(total / limit) if limit > 0 else 1
    page = (skip // limit) + 1 if limit > 0 else 1
    
    return OrderListResponse(
        orders=orders,
        total=total,
        page=page,
        per_page=limit,
        pages=pages
    )

@router.get("/admin", response_model=OrderListResponse)
async def get_all_orders(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[OrderStatus] = Query(None),
    payment_status: Optional[PaymentStatus] = Query(None),
    user_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Get all orders (admin only)."""
    
    query = db.query(Order)
    
    # Apply filters
    if status:
        query = query.filter(Order.status == status)
    
    if payment_status:
        query = query.filter(Order.payment_status == payment_status)
    
    if user_id:
        query = query.filter(Order.user_id == user_id)
    
    # Get total count
    total = query.count()
    
    # Apply pagination and ordering
    orders = query.order_by(desc(Order.created_at)).offset(skip).limit(limit).all()
    
    # Calculate pagination info
    pages = math.ceil(total / limit) if limit > 0 else 1
    page = (skip // limit) + 1 if limit > 0 else 1
    
    return OrderListResponse(
        orders=orders,
        total=total,
        page=page,
        per_page=limit,
        pages=pages
    )

@router.get("/{order_id}", response_model=OrderWithItems)
async def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Get order by ID with items."""
    
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    # Check if user owns the order or is admin
    if order.user_id != current_user.id and not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    # Get order items
    order_items = db.query(OrderItem).filter(OrderItem.order_id == order_id).all()
    
    order_dict = OrderWithItems.from_orm(order).dict()
    order_dict['order_items'] = order_items
    
    return OrderWithItems(**order_dict)

@router.post("/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    order_data: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Create a new order from cart or provided items."""
    
    # Validate and calculate order totals
    subtotal = 0.0
    order_items_data = []
    
    for item in order_data.items:
        product = db.query(Product).filter(
            Product.id == item.product_id,
            Product.is_active == True
        ).first()
        
        if not product:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product with ID {item.product_id} not found or inactive"
            )
        
        # Check stock availability
        if product.track_quantity and not product.continue_selling:
            if product.quantity < item.quantity:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Only {product.quantity} items available for {product.name}"
                )
        
        item_total = product.price * item.quantity
        subtotal += item_total
        
        order_items_data.append({
            'product_id': product.id,
            'product_name': product.name,
            'product_sku': product.sku,
            'product_image': product.images[0] if product.images else None,
            'quantity': item.quantity,
            'unit_price': product.price,
            'total_price': item_total
        })
    
    # Calculate totals (you can add tax and shipping logic here)
    tax_amount = 0.0  # Add tax calculation logic
    shipping_amount = 0.0  # Add shipping calculation logic
    discount_amount = 0.0  # Add discount logic
    total_amount = subtotal + tax_amount + shipping_amount - discount_amount
    
    # Create order
    order = Order(
        order_number=generate_order_number(),
        user_id=current_user.id,
        status=OrderStatus.PENDING,
        payment_status=PaymentStatus.PENDING,
        subtotal=subtotal,
        tax_amount=tax_amount,
        shipping_amount=shipping_amount,
        discount_amount=discount_amount,
        total_amount=total_amount,
        customer_email=order_data.customer_email,
        customer_phone=order_data.customer_phone,
        shipping_first_name=order_data.shipping_address.first_name,
        shipping_last_name=order_data.shipping_address.last_name,
        shipping_address=order_data.shipping_address.address,
        shipping_city=order_data.shipping_address.city,
        shipping_state=order_data.shipping_address.state,
        shipping_zip_code=order_data.shipping_address.zip_code,
        shipping_country=order_data.shipping_address.country,
        notes=order_data.notes
    )
    
    # Add billing address if provided
    if order_data.billing_address:
        order.billing_first_name = order_data.billing_address.first_name
        order.billing_last_name = order_data.billing_address.last_name
        order.billing_address = order_data.billing_address.address
        order.billing_city = order_data.billing_address.city
        order.billing_state = order_data.billing_address.state
        order.billing_zip_code = order_data.billing_address.zip_code
        order.billing_country = order_data.billing_address.country
    
    db.add(order)
    db.commit()
    db.refresh(order)
    
    # Create order items
    for item_data in order_items_data:
        order_item = OrderItem(
            order_id=order.id,
            **item_data
        )
        db.add(order_item)
    
    # Update product quantities
    for item in order_data.items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if product and product.track_quantity:
            product.quantity -= item.quantity
    
    # Clear cart items for the ordered products
    for item in order_data.items:
        db.query(CartItem).filter(
            CartItem.user_id == current_user.id,
            CartItem.product_id == item.product_id
        ).delete()
    
    db.commit()
    
    return order

@router.put("/{order_id}", response_model=OrderResponse)
async def update_order(
    order_id: int,
    order_update: OrderUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """Update order status (admin only)."""
    
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    # Update order fields
    update_data = order_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(order, field, value)
    
    # Set timestamps for status changes
    if order_update.status == OrderStatus.SHIPPED and not order.shipped_at:
        order.shipped_at = datetime.utcnow()
    elif order_update.status == OrderStatus.DELIVERED and not order.delivered_at:
        order.delivered_at = datetime.utcnow()
    
    db.commit()
    db.refresh(order)
    
    return order

@router.delete("/{order_id}")
async def cancel_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    """Cancel order (only if pending)."""
    
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    # Check if user owns the order or is admin
    if order.user_id != current_user.id and not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    
    # Only allow cancellation of pending orders
    if order.status not in [OrderStatus.PENDING, OrderStatus.CONFIRMED]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order cannot be cancelled at this stage"
        )
    
    # Restore product quantities
    order_items = db.query(OrderItem).filter(OrderItem.order_id == order_id).all()
    for item in order_items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if product and product.track_quantity:
            product.quantity += item.quantity
    
    # Update order status
    order.status = OrderStatus.CANCELLED
    db.commit()
    
    return {"message": "Order cancelled successfully"}
