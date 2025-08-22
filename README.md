# 🛒 E-Commerce Application

A modern, full-stack e-commerce application built with **React**, **FastAPI**, and **PostgreSQL**. Features a clean, responsive UI with complete CRUD operations, user authentication, shopping cart, and order management.

## 🌟 Features

### Core E-Commerce Functionality
- **User Authentication**: Secure registration, login, and profile management
- **Product Catalog**: Browse products with search, filtering, and categorization
- **Shopping Cart**: Add, update, remove items with real-time cart management
- **Checkout Process**: Complete order processing with shipping information
- **Order Management**: Order tracking, history, and status updates
- **Admin Panel**: Comprehensive admin interface for managing products, orders, and users
- **Responsive Design**: Mobile-first design that works on all devices

### Advanced Features
- **Real-time Inventory**: Stock tracking and availability management
- **Image Management**: Product image upload and display
- **Category Management**: Hierarchical product categorization
- **User Profiles**: Complete user profile management
- **Order History**: Detailed order tracking and history
- **Admin Dashboard**: Analytics and management tools
- **API Documentation**: Auto-generated OpenAPI documentation

## 🚀 Quick Setup

### Prerequisites

- **Python** (3.11+ recommended)
- **Node.js** (v16 or higher)
- **PostgreSQL** (v12 or higher)

### Option 1: Easy Setup Script (Recommended)

Run the automated setup script that configures everything for you:

```bash
# Run the easy setup script
python easy_setup.py
```

This script will:
1. Create a `.env` file with default configuration
2. Set up the PostgreSQL database and user
3. Set up the backend environment and dependencies
4. Set up the frontend environment and dependencies
5. Download product images
6. Initialize the database with sample data

### Option 2: Manual Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd e-commerce
```

#### 2. Database Setup

Create a PostgreSQL database and user:

```sql
-- Connect to PostgreSQL as superuser
CREATE DATABASE ecommerce_db;
CREATE USER ecommerce_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE ecommerce_db TO ecommerce_user;
```

#### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL=postgresql://ecommerce_user:your_password@localhost:5432/ecommerce_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=ecommerce_user
DB_PASSWORD=your_password

# JWT Security
SECRET_KEY=your-super-secret-jwt-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API Configuration
API_V1_STR=/api/v1
PROJECT_NAME=E-Commerce API
ENVIRONMENT=development
DEBUG=true

# CORS Settings
BACKEND_CORS_ORIGINS=["http://localhost:3000", "http://localhost:3001"]

# Frontend Configuration
REACT_APP_API_URL=http://localhost:8000
REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
```

#### 4. Backend Setup

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

#### 5. Frontend Setup

```bash
# Navigate to frontend directory (in a new terminal)
cd frontend

# Install dependencies
npm install

# Start the development server
npm start
```

## 📱 Accessing the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Admin Panel**: http://localhost:3000/admin (admin login required)

## 🔐 Default Login Credentials

### Admin Account
- **Email:** `admin@ecommerce.com`
- **Password:** `admin123`

### Regular User Account
- **Email:** `user@ecommerce.com`
- **Password:** `user123`

> **Security Note**: Change these credentials before deploying to production.

## 📋 Project Structure

```
e-commerce/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── core/           # Configuration and settings
│   │   ├── models/         # Database models (SQLAlchemy)
│   │   ├── schemas/        # Pydantic schemas for validation
│   │   ├── routers/        # API endpoints
│   │   ├── utils/          # Utility functions
│   │   └── database.py     # Database configuration
│   ├── uploads/            # File uploads directory
│   ├── main.py            # FastAPI application entry point
│   ├── init_db.py         # Database initialization script
│   ├── download_images.py # Product images download script
│   └── requirements.txt   # Python dependencies
├── frontend/               # React frontend
│   ├── public/            # Static files
│   ├── src/
│   │   ├── components/    # Reusable React components
│   │   ├── pages/         # Page components
│   │   ├── context/       # React context providers
│   │   ├── services/      # API services
│   │   └── utils/         # Utility functions
│   └── package.json       # Node.js dependencies
├── .env                   # Environment variables
├── .gitignore            # Git ignore rules
├── easy_setup.py         # Automated setup script
├── setup_database.py     # Database setup helper
└── README.md             # This file
```

## 🛠️ API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `GET /api/v1/auth/me` - Get current user profile

### Products
- `GET /api/v1/products` - List products (with filtering, pagination, search)
- `GET /api/v1/products/{id}` - Get product by ID
- `GET /api/v1/products/slug/{slug}` - Get product by slug
- `POST /api/v1/products` - Create product (admin only)
- `PUT /api/v1/products/{id}` - Update product (admin only)
- `DELETE /api/v1/products/{id}` - Delete product (admin only)
- `POST /api/v1/products/{id}/images` - Upload product images (admin only)

### Categories
- `GET /api/v1/categories` - List categories
- `GET /api/v1/categories/{id}` - Get category by ID
- `GET /api/v1/categories/slug/{slug}` - Get category by slug
- `POST /api/v1/categories` - Create category (admin only)
- `PUT /api/v1/categories/{id}` - Update category (admin only)
- `DELETE /api/v1/categories/{id}` - Delete category (admin only)

### Shopping Cart
- `GET /api/v1/cart` - Get user's cart
- `GET /api/v1/cart/summary` - Get cart summary
- `POST /api/v1/cart/items` - Add item to cart
- `PUT /api/v1/cart/items/{id}` - Update cart item quantity
- `DELETE /api/v1/cart/items/{id}` - Remove item from cart
- `DELETE /api/v1/cart` - Clear entire cart

### Orders
- `GET /api/v1/orders` - Get user's orders
- `GET /api/v1/orders/{id}` - Get order details
- `POST /api/v1/orders` - Create order (checkout)
- `PUT /api/v1/orders/{id}` - Update order status (admin only)
- `DELETE /api/v1/orders/{id}` - Cancel order
- `GET /api/v1/orders/admin` - Get all orders (admin only)

### Users
- `GET /api/v1/users` - List users (admin only)
- `GET /api/v1/users/{id}` - Get user by ID (admin only)
- `PUT /api/v1/users/profile` - Update user profile
- `POST /api/v1/users/{id}/avatar` - Upload user avatar
- `DELETE /api/v1/users/{id}/avatar` - Delete user avatar

## 🧪 Testing

### Backend Testing
```bash
cd backend
# Run with pytest (if tests are added)
pytest
```

### Frontend Testing
```bash
cd frontend
npm test
```

### Manual API Testing
Visit http://localhost:8000/docs for interactive API documentation and testing.

## 🔧 Development

### Backend Development
- **Framework**: FastAPI with automatic OpenAPI documentation
- **Database**: SQLAlchemy ORM with PostgreSQL
- **Authentication**: JWT tokens with bcrypt password hashing
- **Validation**: Pydantic schemas for request/response validation
- **File Uploads**: Handled with proper validation and storage

### Frontend Development
- **Framework**: React 18 with functional components and hooks
- **Styling**: Tailwind CSS for responsive design
- **State Management**: React Context API for global state
- **API Client**: Axios with interceptors for authentication
- **Routing**: React Router v6 for navigation
- **Forms**: Controlled components with validation

### Database Schema
- **Users**: Authentication and profile information
- **Categories**: Product categorization
- **Products**: Product catalog with inventory management
- **Cart Items**: Shopping cart persistence
- **Orders**: Order processing and tracking
- **Order Items**: Detailed order line items

## 🚀 Production Deployment

### Environment Variables
Update the following for production:

```env
# Security
SECRET_KEY=your-production-secret-key
DEBUG=false
ENVIRONMENT=production

# Database
DATABASE_URL=your-production-database-url

# CORS
BACKEND_CORS_ORIGINS=["https://yourdomain.com"]

# Frontend
REACT_APP_API_URL=https://api.yourdomain.com
REACT_APP_API_BASE_URL=https://api.yourdomain.com/api/v1
```

### Security Checklist
- [ ] Change default admin credentials
- [ ] Update JWT secret key
- [ ] Configure HTTPS
- [ ] Set up proper CORS origins
- [ ] Configure production database
- [ ] Set up file storage (AWS S3, etc.)
- [ ] Configure email service for notifications
- [ ] Set up monitoring and logging

## 🆘 Troubleshooting

### Common Issues

**Database Connection Issues**
- Ensure PostgreSQL is running
- Check database credentials in `.env` file
- Verify database and user exist

**Backend Issues**
- Check Python version (3.11+ recommended)
- Ensure all dependencies are installed
- Verify `.env` file exists and is properly configured

**Frontend Issues**
- Check Node.js version (16+ required)
- Clear npm cache: `npm cache clean --force`
- Delete node_modules and reinstall: `rm -rf node_modules && npm install`

**CORS Issues**
- Verify CORS origins in backend configuration
- Check that frontend URL matches CORS settings

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions:
- Check the API documentation at `/docs`
- Review the troubleshooting section
- Check the GitHub issues

---

**Happy Shopping! 🛍️**
