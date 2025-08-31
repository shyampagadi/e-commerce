#!/usr/bin/env python3
"""Simple test to verify backend starts in fallback mode"""

import subprocess
import time
import requests
import sys

def test_backend():
    print("🧪 Testing backend in standalone mode...")
    
    # Start backend process
    try:
        process = subprocess.Popen([
            sys.executable, "-c", 
            "import sys; sys.path.insert(0, 'backend'); import uvicorn; uvicorn.run('main:app', host='127.0.0.1', port=8001, log_level='error')"
        ], cwd="/mnt/c/Users/Shyam/Documents/e-commerce")
        
        # Wait for server to start
        time.sleep(3)
        
        # Test endpoints
        tests = [
            ("Health Check", "http://127.0.0.1:8001/health"),
            ("Root Endpoint", "http://127.0.0.1:8001/"),
            ("Products Fallback", "http://127.0.0.1:8001/api/v1/products"),
            ("Categories Fallback", "http://127.0.0.1:8001/api/v1/categories")
        ]
        
        for test_name, url in tests:
            try:
                response = requests.get(url, timeout=5)
                if response.status_code == 200:
                    print(f"✅ {test_name}: OK")
                else:
                    print(f"❌ {test_name}: HTTP {response.status_code}")
            except Exception as e:
                print(f"❌ {test_name}: {e}")
        
    except Exception as e:
        print(f"❌ Failed to start backend: {e}")
    
    finally:
        # Clean up
        try:
            process.terminate()
            process.wait(timeout=5)
        except:
            process.kill()
    
    print("🎉 Backend test completed!")

if __name__ == "__main__":
    test_backend()
