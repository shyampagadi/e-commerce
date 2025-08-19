# 🛒 E-Commerce Application

A modern, full-stack e-commerce application built with **React**, **FastAPI**, and **PostgreSQL**. Features a clean, responsive UI with complete CRUD operations, user authentication, shopping cart, and order management.

## 🌟 Features

- **User Authentication**: Register, login, and profile management
- **Product Catalog**: Browse products with search and filtering
- **Shopping Cart**: Add, update, and remove items
- **Checkout Process**: Complete orders with shipping information
- **Admin Panel**: Manage products, orders, and users
- **Responsive Design**: Works on desktop, tablet, and mobile

## 🚀 Quick Setup

### Prerequisites

- **Python** (v3.8 or higher)
- **Node.js** (v16 or higher)
- **PostgreSQL** (v12 or higher)

### Option 1: Easy Setup Script

We've created a simple script that sets up everything for you:

```bash
# Run the easy setup script
python easy_setup.py
```

This script will:
1. Create a `.env` file with default configuration
2. Set up the PostgreSQL database
3. Set up the backend environment
4. Set up the frontend environment
5. Download product images
6. Initialize the database with sample data

### Option 2: Manual Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd e-commerce
```

#### 2. Create Environment File

Create a `.env` file in the root directory:

```
# Database
DATABASE_URL=postgresql://ecommerce_user:ecommerce_password@localhost:5432/ecommerce_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=ecommerce_user
DB_PASSWORD=ecommerce_password

# JWT
SECRET_KEY=your-super-secret-jwt-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API
API_V1_STR=/api/v1
PROJECT_NAME=E-Commerce API
```

#### 3. Set Up Database

```bash
# Run the database setup script
python setup_database.py
```

#### 4. Set Up Backend

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Download product images
python download_images.py

# Initialize database with sample data
python init_db.py

# Start the backend server
uvicorn main:app --reload
```

#### 5. Set Up Frontend

```bash
# Navigate to frontend directory (in a new terminal)
cd frontend

# Install dependencies
npm install

# Start the development server
npm start
```

## 📱 Accessing the Application

- **Backend API**: http://localhost:8000
  - API Documentation: http://localhost:8000/docs
- **Frontend**: http://localhost:3000

## 🔐 Default Login Credentials

### Admin Account
- **Email:** `admin@ecommerce.com`
- **Password:** `admin123`

### Regular User Account
- **Email:** `user@ecommerce.com`
- **Password:** `user123`

## 📋 Project Structure

```
e-commerce/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── core/           # Configuration and settings
│   │   ├── models/         # Database models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── routers/        # API endpoints
│   │   ├── utils/          # Utility functions
│   │   └── database.py     # Database configuration
│   ├── uploads/            # File uploads directory
│   ├── main.py            # FastAPI application
│   └── requirements.txt   # Python dependencies
├── frontend/               # React frontend
│   ├── public/            # Static files
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── context/       # React context providers
│   │   ├── services/      # API services
│   │   └── hooks/         # Custom hooks
│   └── package.json       # Node.js dependencies
├── .env                   # Environment variables
└── README.md             # This file
```

## 🛠️ API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `GET /api/v1/auth/me` - Get current user

### Products
- `GET /api/v1/products` - List products
- `GET /api/v1/products/{id}` - Get product by ID
- `POST /api/v1/products` - Create product (admin)
- `PUT /api/v1/products/{id}` - Update product (admin)
- `DELETE /api/v1/products/{id}` - Delete product (admin)

### Categories
- `GET /api/v1/categories` - List categories
- `GET /api/v1/categories/{id}` - Get category by ID
- `POST /api/v1/categories` - Create category (admin)
- `PUT /api/v1/categories/{id}` - Update category (admin)
- `DELETE /api/v1/categories/{id}` - Delete category (admin)

### Cart
- `GET /api/v1/cart` - Get user's cart
- `POST /api/v1/cart/items` - Add item to cart
- `PUT /api/v1/cart/items/{id}` - Update cart item
- `DELETE /api/v1/cart/items/{id}` - Remove from cart

### Orders
- `GET /api/v1/orders` - Get user's orders
- `GET /api/v1/orders/{id}` - Get order details
- `POST /api/v1/orders` - Create order
- `PUT /api/v1/orders/{id}` - Update order (admin)

## 🧪 Testing

### Backend Testing
```bash
cd backend
pytest
```

### Frontend Testing
```bash
cd frontend
npm test
```

## 🆘 Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check database credentials in `.env` file
- Verify database and user exist

### Backend Issues
- Check Python version (3.8+ required)
- Ensure all dependencies are installed
- Verify `.env` file exists and is properly configured

### Frontend Issues
- Check Node.js version (16+ required)
- Clear npm cache: `npm cache clean --force`
- Delete node_modules and reinstall: `rm -rf node_modules && npm install`

## 📄 License

This project is licensed under the MIT License.

---

**Happy Shopping! 🛍️**