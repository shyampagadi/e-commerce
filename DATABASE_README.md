# 🗄️ Database Setup - Quick Guide

## 📋 Prerequisites

1. **PostgreSQL installed and running**
2. **Create database manually:**
   ```sql
   CREATE DATABASE ecommerce_db;
   ```
3. **Set postgres user password** (update in setup.py)
4. **Install dependencies:**
   ```bash
   pip install -r backend/requirements.txt
   ```

## 🚀 Quick Setup

### **Complete Setup (Recommended)**
```bash
# One command - does everything
python database/setup.py --all
```

### **Step by Step**
```bash
# 1. Test connection
python database/setup.py --validate

# 2. Initialize with sample data
python database/setup.py --init-sample

# 3. Download product images
python database/setup.py --download-images
```

### **Clean Setup (Production)**
```bash
# No sample data
python database/setup.py --init-clean
```

## 🔧 Configuration

Update these variables in `database/setup.py`:

```python
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'ecommerce_db',
    'user': 'postgres',
    'password': 'your_password_here'  # UPDATE THIS
}
```

## 📊 What Gets Created

### **Users:**
- **Admin**: admin@ecommerce.com / admin123
- **User**: user@ecommerce.com / user123
- **Sample Users**: user1@example.com / password123 (10 users)

### **Categories:**
- Electronics, Clothing & Fashion, Home & Garden
- Sports & Outdoors, Books & Media, Health & Beauty

### **Products:**
- 11 realistic products with specifications
- Product images downloaded from Unsplash
- Proper pricing and inventory

## 🛠️ Available Commands

```bash
python database/setup.py --help                    # Show all options
python database/setup.py --validate               # Test connection
python database/setup.py --init-clean            # Clean setup
python database/setup.py --init-sample           # With sample data
python database/setup.py --download-images       # Download images
python database/setup.py --reset                 # Reset database
python database/setup.py --all                   # Complete setup
python database/setup.py --backup                # Create backup
python database/setup.py --restore backup.sql    # Restore backup
```

## 🚨 Troubleshooting

### **Connection Failed**
- Check PostgreSQL is running: `sudo systemctl status postgresql`
- Verify database exists: `psql -U postgres -l`
- Update password in setup.py

### **Import Errors**
- Install dependencies: `pip install -r backend/requirements.txt`
- Run from project root directory

### **Permission Denied**
- Check postgres user has database access
- Verify database 'ecommerce_db' exists

## ✅ Success Output

```
🚀 Sample Database Initialization
✅ PostgreSQL connection successful
✅ Database 'ecommerce_db' exists
✅ Database permissions verified
✅ Database tables created successfully
✅ Admin user created successfully
✅ Default user created successfully
✅ Created 10 sample users
✅ Created/verified 6 product categories
✅ Created 11 sample products
✅ Downloaded 22 images

🚀 Setup Completed Successfully!
```

## 🎯 Next Steps

After successful setup:

1. **Start Backend:**
   ```bash
   cd backend
   uvicorn main:app --reload
   ```

2. **Start Frontend:**
   ```bash
   cd frontend
   npm start
   ```

3. **Access Application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

**Your e-commerce database is ready! 🚀**
