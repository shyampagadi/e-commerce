#!/usr/bin/env python3
"""Test backend fallback functionality"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

# Test without database imports
print("🧪 Testing backend fallback...")

# Simulate missing database by temporarily renaming the app directory
app_dir = os.path.join(os.path.dirname(__file__), 'backend', 'app')
app_backup = os.path.join(os.path.dirname(__file__), 'backend', 'app_backup')

try:
    # Backup app directory to simulate missing dependencies
    if os.path.exists(app_dir):
        os.rename(app_dir, app_backup)
    
    # Import main module (should use fallback)
    from backend.main import app, DATABASE_AVAILABLE
    
    print(f"✅ Backend loaded successfully")
    print(f"📊 Database available: {DATABASE_AVAILABLE}")
    
    if not DATABASE_AVAILABLE:
        print("✅ Fallback mode activated correctly")
    else:
        print("⚠️ Expected fallback mode but database is available")

finally:
    # Restore app directory
    if os.path.exists(app_backup):
        os.rename(app_backup, app_dir)

print("🎉 Backend fallback test completed!")
