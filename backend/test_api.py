#!/usr/bin/env python3
"""
Test the API endpoints
"""

import requests
import json

def test_api():
    """Test the API endpoints"""
    base_url = "http://localhost:8000/api/v1"
    
    # Test products endpoint
    print("Testing products endpoint...")
    try:
        response = requests.get(f"{base_url}/products")
        print(f"Status code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response type: {type(data)}")
            print(f"Response: {json.dumps(data, indent=2)}")
        else:
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test categories endpoint
    print("\nTesting categories endpoint...")
    try:
        response = requests.get(f"{base_url}/categories")
        print(f"Status code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response type: {type(data)}")
            print(f"Response: {json.dumps(data, indent=2)}")
        else:
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()
