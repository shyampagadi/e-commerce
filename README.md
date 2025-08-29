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

## 🚀 Quick Setup (Manual PostgreSQL)

### Prerequisites

- **Python** (3.11+ recommended)
- **Node.js** (v16 or higher)
- **PostgreSQL** (v12 or higher) - **Manually installed and configured**

### Database Configuration (Manual Setup)

This project uses a **manually configured PostgreSQL database** with the following settings:

```
Database: ecommerce_db
User: postgres
Password: admin
Host: localhost
Port: 5432
```

> **Note**: Make sure you have created the `ecommerce_db` database in your PostgreSQL installation before proceeding.

### Step-by-Step Setup

#### 1. Clone and Navigate to Project

```bash
git clone <repository-url>
cd e-commerce
```

#### 2. Install Dependencies

```bash
# Install main dependencies
pip install -r requirements.txt
```

#### 3. Database Setup (Single Command)

```bash
# Full database setup (validate + initialize clean database)
python database/setup.py --all

# Or run individual commands:
python database/setup.py --validate              # Validate connection
python database/setup.py --init-clean           # Clean initialization
python database/setup.py --init-sample          # With sample data
python database/setup.py --download-images      # Download sample images
python database/setup.py --reset                # Reset database
```

#### 4. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create and activate virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install backend dependencies
pip install -r requirements.txt

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
│   ├── delete_vpc_resources.py # AWS VPC cleanup utility
│   └── requirements.txt   # Python dependencies
├── database/               # Database setup and management
│   └── setup.py           # Comprehensive database setup script
├── frontend/               # React frontend
│   ├── public/            # Static files
│   ├── src/
│   │   ├── components/    # Reusable React components
│   │   ├── pages/         # Page components
│   │   ├── context/       # React context providers
│   │   ├── services/      # API services
│   │   └── utils/         # Utility functions
│   └── package.json       # Node.js dependencies
├── .env                   # Environment variables (configured for manual PostgreSQL)
├── .gitignore            # Git ignore rules
├── requirements.txt      # Main dependencies (psycopg2, boto3)
└── README.md             # This file
```

## 🛠️ Database Configuration

### Manual PostgreSQL Setup

The application is configured to use a **manually created PostgreSQL database**:

```env
# Database Configuration (Manual Setup)
DATABASE_URL=postgresql://postgres:admin@localhost:5432/ecommerce_db
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce_db
DB_USER=postgres
DB_PASSWORD=admin
```

### Creating the Database Manually

If you haven't created the database yet:

```sql
-- Connect to PostgreSQL as superuser
CREATE DATABASE ecommerce_db;
-- The postgres user should already exist with your chosen password
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
- **Database**: SQLAlchemy ORM with PostgreSQL (manual setup)
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

## 🔄 Alternative Setup Options

### Option 1: With Sample Data
If you want to start with sample products and data:

```bash
cd backend
python init_db.py  # Creates sample products with images
python download_images.py  # Downloads product images
```

### Option 2: Different Database Credentials
If you want to use different database credentials, update the `.env` file:

```env
DATABASE_URL=postgresql://your_user:your_password@localhost:5432/your_database
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=your_database
```

## 🚀 Production Deployment

### Environment Variables
Update the following for production:

```env
# Security
SECRET_KEY=your-production-secret-key-here
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
- Verify database `ecommerce_db` exists
- Check credentials: user `postgres`, password `admin`
- Test connection: `python validate_database.py`

**Backend Issues**
- Check Python version: `python --version` (3.11+ recommended)
- Ensure virtual environment is activated
- Verify all dependencies are installed: `pip list`
- Check `.env` file exists and is properly configured

**Frontend Issues**
- Check Node.js version: `node --version` (16+ required)
- Clear npm cache: `npm cache clean --force`
- Delete node_modules and reinstall: `rm -rf node_modules && npm install`

**CORS Issues**
- Verify CORS origins in backend configuration
- Check that frontend URL matches CORS settings
- Ensure `.env` file has correct BACKEND_CORS_ORIGINS format

**Permission Issues**
- On Windows/WSL: Check file permissions
- On Linux/macOS: Use `chmod +x` for script files

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
