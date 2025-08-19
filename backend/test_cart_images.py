#!/usr/bin/env python3

import requests
import json

def test_cart_and_images():
    """Test cart functionality and image URLs"""
    
    base_url = "http://localhost:8000"
    
    print("🧪 Testing Cart and Image Functionality")
    print("=" * 50)
    
    # 1. Login to get token
    print("1. 🔐 Logging in...")
    login_response = requests.post(
        f"{base_url}/api/v1/auth/login",
        json={"email": "user@ecommerce.com", "password": "user123"}
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        return False
    
    token = login_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Login successful")
    
    # 2. Get cart contents
    print("\n2. 🛒 Getting cart contents...")
    cart_response = requests.get(f"{base_url}/api/v1/cart", headers=headers)
    
    if cart_response.status_code != 200:
        print(f"❌ Get cart failed: {cart_response.status_code}")
        print(f"Response: {cart_response.text}")
        return False
    
    cart_data = cart_response.json()
    print(f"✅ Cart retrieved: {cart_data['total_items']} items, ${cart_data['subtotal']:.2f}")
    
    # 3. Test image URLs
    print("\n3. 🖼️ Testing image URLs...")
    for item in cart_data['items']:
        product = item['product']
        if product and product.get('images'):
            for image_path in product['images']:
                image_url = f"{base_url}/uploads/{image_path}"
                print(f"   Testing: {image_url}")
                
                image_response = requests.head(image_url)
                if image_response.status_code == 200:
                    print(f"   ✅ Image accessible: {image_path}")
                else:
                    print(f"   ❌ Image not accessible: {image_path} (Status: {image_response.status_code})")
        else:
            print(f"   ⚠️ No images for product: {product.get('name', 'Unknown')}")
    
    # 4. Test adding item to cart
    print("\n4. ➕ Testing add to cart...")
    add_response = requests.post(
        f"{base_url}/api/v1/cart/items",
        headers=headers,
        json={"product_id": 2, "quantity": 1}
    )
    
    if add_response.status_code in [200, 201]:
        print("✅ Add to cart successful")
    else:
        print(f"❌ Add to cart failed: {add_response.status_code}")
        print(f"Response: {add_response.text}")
    
    print("\n" + "=" * 50)
    print("🎉 Cart and image functionality test completed!")
    return True

if __name__ == "__main__":
    test_cart_and_images()
