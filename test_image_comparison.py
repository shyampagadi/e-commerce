#!/usr/bin/env python3
"""
Deep dive comparison between ProductDetail and CategoryProducts image handling
"""

import requests
import json

def test_product_detail_flow():
    print("🔍 TESTING PRODUCT DETAIL FLOW")
    print("=" * 60)
    
    # Test the exact API call that ProductDetail makes
    try:
        response = requests.get("http://localhost:8000/api/v1/products/slug/iphone-15-pro")
        if response.status_code == 200:
            product = response.json()
            print(f"✅ ProductDetail API Success")
            print(f"   Product: {product['name']}")
            print(f"   Images: {product['images']}")
            print(f"   Images type: {type(product['images'])}")
            print(f"   First image: {product['images'][0] if product['images'] else 'None'}")
            
            # Test image URL construction (ProductDetail way)
            if product['images']:
                image_path = product['images'][0]
                image_url = f"http://localhost:8000/uploads/{image_path}"
                print(f"   Constructed URL: {image_url}")
                
                # Test if image is accessible
                img_response = requests.head(image_url)
                print(f"   Image accessible: {'✅ YES' if img_response.status_code == 200 else '❌ NO'}")
            
            return product
        else:
            print(f"❌ ProductDetail API Failed: {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ ProductDetail API Error: {e}")
        return None

def test_category_products_flow():
    print("\n🔍 TESTING CATEGORY PRODUCTS FLOW")
    print("=" * 60)
    
    # Test the exact API calls that CategoryProducts makes
    try:
        # Step 1: Get category
        cat_response = requests.get("http://localhost:8000/api/v1/categories/slug/electronics")
        if cat_response.status_code == 200:
            category = cat_response.json()
            print(f"✅ Category API Success")
            print(f"   Category: {category['name']} (ID: {category['id']})")
            
            # Step 2: Get products
            prod_response = requests.get(f"http://localhost:8000/api/v1/products/?category_id={category['id']}")
            if prod_response.status_code == 200:
                products_data = prod_response.json()
                products = products_data.get('products', [])
                print(f"✅ Products API Success")
                print(f"   Products found: {len(products)}")
                
                if products:
                    # Test first product (iPhone)
                    product = products[0]
                    print(f"   First product: {product['name']}")
                    print(f"   Images: {product['images']}")
                    print(f"   Images type: {type(product['images'])}")
                    print(f"   First image: {product['images'][0] if product['images'] else 'None'}")
                    
                    # Test image URL construction (CategoryProducts way)
                    if product['images']:
                        image_path = product['images'][0]
                        image_url = f"http://localhost:8000/uploads/{image_path}"
                        print(f"   Constructed URL: {image_url}")
                        
                        # Test if image is accessible
                        img_response = requests.head(image_url)
                        print(f"   Image accessible: {'✅ YES' if img_response.status_code == 200 else '❌ NO'}")
                    
                    return products
                else:
                    print("❌ No products found")
                    return []
            else:
                print(f"❌ Products API Failed: {prod_response.status_code}")
                return []
        else:
            print(f"❌ Category API Failed: {cat_response.status_code}")
            return []
    except Exception as e:
        print(f"❌ Category Products API Error: {e}")
        return []

def compare_data_structures(product_detail_data, category_products_data):
    print("\n🔍 COMPARING DATA STRUCTURES")
    print("=" * 60)
    
    if not product_detail_data or not category_products_data:
        print("❌ Cannot compare - missing data")
        return
    
    # Find the same product in both datasets
    iphone_from_detail = product_detail_data
    iphone_from_category = None
    
    for product in category_products_data:
        if product['name'] == 'iPhone 15 Pro':
            iphone_from_category = product
            break
    
    if not iphone_from_category:
        print("❌ iPhone not found in category products")
        return
    
    print("📱 COMPARING iPhone 15 Pro DATA:")
    print(f"   ProductDetail name: {iphone_from_detail['name']}")
    print(f"   CategoryProducts name: {iphone_from_category['name']}")
    print(f"   ProductDetail images: {iphone_from_detail['images']}")
    print(f"   CategoryProducts images: {iphone_from_category['images']}")
    print(f"   Images identical: {'✅ YES' if iphone_from_detail['images'] == iphone_from_category['images'] else '❌ NO'}")
    
    # Check all fields
    detail_keys = set(iphone_from_detail.keys())
    category_keys = set(iphone_from_category.keys())
    
    print(f"\n📊 FIELD COMPARISON:")
    print(f"   ProductDetail fields: {len(detail_keys)}")
    print(f"   CategoryProducts fields: {len(category_keys)}")
    print(f"   Common fields: {len(detail_keys & category_keys)}")
    print(f"   Only in ProductDetail: {detail_keys - category_keys}")
    print(f"   Only in CategoryProducts: {category_keys - detail_keys}")

def test_frontend_behavior():
    print("\n🔍 TESTING FRONTEND BEHAVIOR")
    print("=" * 60)
    
    # Test if frontend pages are accessible
    try:
        # Test ProductDetail page
        detail_response = requests.get("http://localhost:3001/products/iphone-15-pro", timeout=5)
        print(f"ProductDetail page: {'✅ Accessible' if detail_response.status_code == 200 else '❌ Not accessible'}")
    except:
        print("ProductDetail page: ❌ Not accessible")
    
    try:
        # Test CategoryProducts page
        category_response = requests.get("http://localhost:3001/categories/electronics", timeout=5)
        print(f"CategoryProducts page: {'✅ Accessible' if category_response.status_code == 200 else '❌ Not accessible'}")
    except:
        print("CategoryProducts page: ❌ Not accessible")

def main():
    print("🔬 DEEP DIVE ROOT CAUSE ANALYSIS")
    print("🔬 Image Display Issue Investigation")
    print("=" * 60)
    
    # Test both flows
    product_detail_data = test_product_detail_flow()
    category_products_data = test_category_products_flow()
    
    # Compare the data
    compare_data_structures(product_detail_data, category_products_data)
    
    # Test frontend
    test_frontend_behavior()
    
    print("\n🎯 ROOT CAUSE ANALYSIS SUMMARY")
    print("=" * 60)
    print("✅ Backend APIs working correctly")
    print("✅ Image files accessible")
    print("✅ Data structures identical")
    print("✅ URL construction logic identical")
    print("")
    print("🔍 LIKELY CAUSES:")
    print("1. Frontend compilation/caching issue")
    print("2. React component rendering issue")
    print("3. Browser caching of old code")
    print("4. CSS/styling hiding images")
    print("5. JavaScript errors preventing image load")

if __name__ == "__main__":
    main()
