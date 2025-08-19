#!/usr/bin/env python3
"""
Comprehensive E-Commerce Application Test Script
Tests all major functionality and API endpoints
"""

import requests
import json
import sys
from datetime import datetime

# Configuration
API_BASE_URL = "http://localhost:8000/api/v1"
FRONTEND_URL = "http://localhost:3001"

def test_api_endpoint(endpoint, method="GET", data=None, headers=None):
    """Test an API endpoint and return the result"""
    try:
        url = f"{API_BASE_URL}{endpoint}"
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=10)
        
        return {
            "success": response.status_code < 400,
            "status_code": response.status_code,
            "data": response.json() if response.content else None,
            "error": None
        }
    except Exception as e:
        return {
            "success": False,
            "status_code": None,
            "data": None,
            "error": str(e)
        }

def print_test_result(test_name, result):
    """Print formatted test result"""
    status = "✅ PASS" if result["success"] else "❌ FAIL"
    print(f"{status} {test_name}")
    if not result["success"]:
        print(f"   Error: {result.get('error', 'HTTP ' + str(result.get('status_code', 'Unknown')))}")
    return result["success"]

def main():
    print("🚀 E-Commerce Application Comprehensive Test")
    print("=" * 50)
    
    passed_tests = 0
    total_tests = 0
    
    # Test 1: Health Check
    total_tests += 1
    result = test_api_endpoint("/../../health")
    if print_test_result("Health Check", result):
        passed_tests += 1
    
    # Test 2: Categories List
    total_tests += 1
    result = test_api_endpoint("/categories/")
    if print_test_result("Categories List", result):
        passed_tests += 1
        if result["data"]:
            print(f"   Found {len(result['data'])} categories")
    
    # Test 3: Products List
    total_tests += 1
    result = test_api_endpoint("/products/")
    if print_test_result("Products List", result):
        passed_tests += 1
        if result["data"] and "products" in result["data"]:
            products = result["data"]["products"]
            print(f"   Found {len(products)} products")
            
            # Check if products have categories
            products_with_categories = [p for p in products if p.get("category")]
            print(f"   Products with categories: {len(products_with_categories)}/{len(products)}")
            
            # Test single product
            if products:
                first_product = products[0]
                product_slug = first_product.get("slug")
                
                if product_slug:
                    # Test 4: Single Product by Slug
                    total_tests += 1
                    result = test_api_endpoint(f"/products/slug/{product_slug}")
                    if print_test_result(f"Single Product ({product_slug})", result):
                        passed_tests += 1
                        if result["data"] and result["data"].get("category"):
                            print(f"   Category: {result['data']['category']['name']}")
    
    # Test 5: Featured Products
    total_tests += 1
    result = test_api_endpoint("/products/featured")
    if print_test_result("Featured Products", result):
        passed_tests += 1
        if result["data"]:
            print(f"   Found {len(result['data'])} featured products")
    
    # Test 6: Authentication Endpoints
    total_tests += 1
    auth_data = {
        "email": "admin@ecommerce.com",
        "password": "admin123"
    }
    result = test_api_endpoint("/auth/login", method="POST", data=auth_data)
    if print_test_result("Admin Login", result):
        passed_tests += 1
        if result["data"] and "access_token" in result["data"]:
            token = result["data"]["access_token"]
            headers = {"Authorization": f"Bearer {token}"}
            
            # Test 7: Protected Endpoint (User Profile)
            total_tests += 1
            result = test_api_endpoint("/auth/me", headers=headers)
            if print_test_result("User Profile (Protected)", result):
                passed_tests += 1
                if result["data"]:
                    print(f"   User: {result['data'].get('email', 'Unknown')}")
    
    # Test Frontend Accessibility
    total_tests += 1
    try:
        response = requests.get(FRONTEND_URL, timeout=10)
        frontend_success = response.status_code == 200
        if print_test_result("Frontend Accessibility", {"success": frontend_success}):
            passed_tests += 1
    except Exception as e:
        print_test_result("Frontend Accessibility", {"success": False, "error": str(e)})
    
    # Summary
    print("\n" + "=" * 50)
    print(f"📊 Test Summary: {passed_tests}/{total_tests} tests passed")
    
    if passed_tests == total_tests:
        print("🎉 All tests passed! Your e-commerce application is working correctly.")
        return 0
    else:
        print("⚠️  Some tests failed. Please check the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
