#!/usr/bin/env python3
"""
Download product images for the e-commerce application.
This script downloads high-quality product images from Unsplash and saves them to the uploads directory.
"""

import os
import sys
import requests
import shutil
from pathlib import Path

# Image URLs - high-quality product images from Unsplash and other free sources
PRODUCT_IMAGES = {
    # Electronics
    "products/iphone15pro.jpg": "https://images.unsplash.com/photo-1696446701796-da61225697cc?w=800&auto=format&fit=crop",
    "products/iphone15pro_2.jpg": "https://images.unsplash.com/photo-1591337676887-a217a6970a8a?w=800&auto=format&fit=crop",
    
    "products/galaxys24.jpg": "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=800&auto=format&fit=crop",
    "products/galaxys24_2.jpg": "https://images.unsplash.com/photo-1565849904461-04a58ad377e0?w=800&auto=format&fit=crop",
    
    "products/macbookair.jpg": "https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800&auto=format&fit=crop",
    "products/macbookair_2.jpg": "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800&auto=format&fit=crop",
    
    "products/sonywh1000xm5.jpg": "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&auto=format&fit=crop",
    "products/sonywh1000xm5_2.jpg": "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=800&auto=format&fit=crop",
    
    # Clothing
    "products/denimjacket.jpg": "https://images.unsplash.com/photo-1578681994506-b8f463449011?w=800&auto=format&fit=crop",
    "products/denimjacket_2.jpg": "https://images.unsplash.com/photo-1591213954196-2d0ccb3f8d4c?w=800&auto=format&fit=crop",
    
    "products/cottontshirt.jpg": "https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=800&auto=format&fit=crop",
    "products/cottontshirt_2.jpg": "https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&auto=format&fit=crop",
    
    # Home & Garden
    "products/securitycamera.jpg": "https://images.unsplash.com/photo-1582139329536-e7284fece509?w=800&auto=format&fit=crop",
    "products/securitycamera_2.jpg": "https://images.unsplash.com/photo-1557324232-b8917d3c3dcb?w=800&auto=format&fit=crop",
    
    "products/plantpots.jpg": "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=800&auto=format&fit=crop",
    "products/plantpots_2.jpg": "https://images.unsplash.com/photo-1602923668104-8f9e03e77e62?w=800&auto=format&fit=crop",
    
    # Sports & Outdoors
    "products/yogamat.jpg": "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&auto=format&fit=crop",
    "products/yogamat_2.jpg": "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop",
    
    "products/campingbackpack.jpg": "https://images.unsplash.com/photo-1580087256394-dc596e1c8f4f?w=800&auto=format&fit=crop",
    "products/campingbackpack_2.jpg": "https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=800&auto=format&fit=crop",
}

def download_image(url, save_path):
    """Download an image from a URL and save it to the specified path"""
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        with open(save_path, 'wb') as f:
            shutil.copyfileobj(response.raw, f)
        
        print(f"✅ Downloaded: {save_path}")
        return True
    except Exception as e:
        print(f"❌ Error downloading {url}: {e}")
        return False

def main():
    """Main function to download all product images"""
    print("🚀 Downloading product images...")
    print("=" * 60)
    
    # Create uploads directory if it doesn't exist
    uploads_dir = Path("uploads")
    uploads_dir.mkdir(exist_ok=True)
    
    # Create products directory if it doesn't exist
    products_dir = uploads_dir / "products"
    products_dir.mkdir(exist_ok=True)
    
    # Download each image
    success_count = 0
    for image_path, image_url in PRODUCT_IMAGES.items():
        save_path = uploads_dir / image_path
        
        # Create parent directories if they don't exist
        save_path.parent.mkdir(exist_ok=True, parents=True)
        
        if download_image(image_url, save_path):
            success_count += 1
    
    print("=" * 60)
    print(f"✅ Downloaded {success_count} of {len(PRODUCT_IMAGES)} images")
    
    if success_count < len(PRODUCT_IMAGES):
        print(f"⚠️  {len(PRODUCT_IMAGES) - success_count} images failed to download")
        print("   You may need to manually add images to the uploads directory")
    
    print("\n🎉 Image download complete!")

if __name__ == "__main__":
    main()
