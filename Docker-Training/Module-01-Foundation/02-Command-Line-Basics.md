# Command Line Basics for Docker

## Learning Objectives
- Master essential command line operations
- Understand file system navigation
- Learn process management basics
- Practice with hands-on exercises

## Essential Commands

### Navigation Commands
```bash
# Show current directory
pwd

# List files and directories
ls
ls -la  # detailed listing
ls -lh  # human readable sizes

# Change directory
cd /path/to/directory
cd ..    # go up one level
cd ~     # go to home directory
cd -     # go to previous directory
```

### File Operations
```bash
# Create files
touch filename.txt
echo "Hello World" > file.txt

# View file contents
cat filename.txt
less filename.txt  # paginated view
head filename.txt  # first 10 lines
tail filename.txt  # last 10 lines

# Copy and move
cp source.txt destination.txt
mv oldname.txt newname.txt

# Delete files
rm filename.txt
rm -rf directory/  # recursive delete (be careful!)
```

### Directory Operations
```bash
# Create directories
mkdir new-directory
mkdir -p path/to/nested/directory

# Remove directories
rmdir empty-directory
rm -rf directory-with-contents
```

### Process Management
```bash
# Show running processes
ps aux
top
htop  # if available

# Kill processes
kill PID
kill -9 PID  # force kill

# Background processes
command &
nohup command &
```

## Hands-On Exercise 1: File System Practice

Create this directory structure:
```
docker-practice/
├── projects/
│   ├── web-app/
│   └── api/
├── configs/
└── logs/
```

**Commands to practice:**
```bash
# 1. Create the structure
mkdir -p docker-practice/{projects/{web-app,api},configs,logs}

# 2. Navigate and create files
cd docker-practice
echo "Web application files" > projects/web-app/README.md
echo "API documentation" > projects/api/README.md
echo "server_config=production" > configs/app.conf

# 3. List everything
find . -type f

# 4. Check file sizes
ls -lah projects/*/README.md
```

## Hands-On Exercise 2: Process Monitoring

```bash
# 1. Start a long-running process
sleep 300 &

# 2. Find the process
ps aux | grep sleep

# 3. Monitor system resources
top
# Press 'q' to quit

# 4. Kill the process
kill $(pgrep sleep)
```

## Environment Variables

```bash
# Set environment variables
export MY_VAR="Hello Docker"
export PATH=$PATH:/new/path

# View environment variables
env
echo $MY_VAR
echo $PATH

# Unset variables
unset MY_VAR
```

## File Permissions

```bash
# View permissions
ls -la filename.txt

# Change permissions
chmod 755 script.sh    # rwxr-xr-x
chmod +x script.sh     # make executable
chmod -w filename.txt  # remove write permission

# Change ownership
chown user:group filename.txt
```

## Text Processing

```bash
# Search in files
grep "pattern" filename.txt
grep -r "pattern" directory/
grep -i "pattern" filename.txt  # case insensitive

# Count lines, words, characters
wc filename.txt
wc -l filename.txt  # just lines

# Sort and unique
sort filename.txt
sort filename.txt | uniq
```

## Pipes and Redirection

```bash
# Redirect output
command > output.txt      # overwrite
command >> output.txt     # append
command 2> error.log      # redirect errors

# Pipes
ls -la | grep ".txt"
ps aux | grep docker
cat file.txt | sort | uniq
```

## Practical Docker Preparation Exercise

Create a simple web project structure:

```bash
# 1. Create project structure
mkdir -p my-web-app/{src,config,logs,data}

# 2. Create application files
cd my-web-app

# Simple HTML file
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Docker App</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This app will be containerized soon.</p>
</body>
</html>
EOF

# Configuration file
cat > config/app.conf << 'EOF'
PORT=8080
DEBUG=true
LOG_LEVEL=info
EOF

# Simple startup script
cat > start.sh << 'EOF'
#!/bin/bash
echo "Starting web application..."
echo "Configuration loaded from: $(pwd)/config/app.conf"
echo "Serving files from: $(pwd)/src/"
python3 -m http.server 8080 --directory src/
EOF

# Make script executable
chmod +x start.sh

# 3. Test the structure
find . -type f -exec ls -la {} \;
```

## Command Line Tips for Docker

### Useful Aliases
Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Docker aliases (we'll use these later)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# General aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
```

### History and Shortcuts
```bash
# Command history
history
!!          # repeat last command
!n          # repeat command number n
!string     # repeat last command starting with string

# Keyboard shortcuts
Ctrl+C      # interrupt current command
Ctrl+Z      # suspend current command
Ctrl+A      # go to beginning of line
Ctrl+E      # go to end of line
Ctrl+R      # search command history
```

## Practice Challenges

### Challenge 1: Log Analysis
```bash
# Create a sample log file
cat > app.log << 'EOF'
2024-01-01 10:00:01 INFO Application started
2024-01-01 10:00:02 DEBUG Loading configuration
2024-01-01 10:00:03 INFO Server listening on port 8080
2024-01-01 10:01:15 ERROR Database connection failed
2024-01-01 10:01:16 WARN Retrying database connection
2024-01-01 10:01:17 INFO Database connected successfully
2024-01-01 10:02:30 ERROR Invalid user input
2024-01-01 10:03:45 INFO User logged in: user123
EOF

# Tasks:
# 1. Count total log entries
# 2. Find all ERROR messages
# 3. Count ERROR vs INFO messages
# 4. Extract unique log levels
```

**Solutions:**
```bash
# 1. Count total entries
wc -l app.log

# 2. Find ERROR messages
grep "ERROR" app.log

# 3. Count by level
grep -c "ERROR" app.log
grep -c "INFO" app.log

# 4. Extract unique levels
grep -o '\(INFO\|ERROR\|DEBUG\|WARN\)' app.log | sort | uniq
```

### Challenge 2: System Information
```bash
# Gather system information that Docker will need
echo "=== System Information ==="
uname -a
echo "=== CPU Information ==="
cat /proc/cpuinfo | grep "model name" | head -1
echo "=== Memory Information ==="
free -h
echo "=== Disk Space ==="
df -h
echo "=== Network Interfaces ==="
ip addr show | grep inet
```

## Next Steps

You're now ready for Docker! These command line skills will be essential when:
- Building Docker images
- Managing containers
- Debugging issues
- Automating deployments
- Working with Docker Compose

**Key takeaways:**
- Master basic navigation and file operations
- Understand process management
- Practice with pipes and redirection
- Get comfortable with text processing
- Learn to read system information

---

## 🛒 E-Commerce Application Section

### Setting Up Your E-Commerce Project Structure

Now let's apply these command line skills to create your e-commerce application that we'll containerize throughout this course.

#### Create E-Commerce Project Structure
```bash
# 1. Create the main project directory
mkdir -p ecommerce-docker-project
cd ecommerce-docker-project

# 2. Create service directories
mkdir -p {frontend,backend,database,nginx,scripts,docs,logs}

# 3. Create subdirectories for each service
mkdir -p frontend/{src,public,build}
mkdir -p backend/{src,config,tests}
mkdir -p database/{migrations,seeds,backup}
mkdir -p nginx/{conf,ssl}
mkdir -p scripts/{deployment,monitoring,backup}
```

#### Initialize Frontend (React/Vue/Angular)
```bash
# Navigate to frontend directory
cd frontend

# Create package.json for Node.js frontend
cat > package.json << 'EOF'
{
  "name": "ecommerce-frontend",
  "version": "1.0.0",
  "description": "E-commerce frontend application",
  "main": "src/index.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test"
  },
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-scripts": "5.0.1",
    "axios": "^1.0.0"
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
EOF

# Create basic React component
mkdir -p src/components
cat > src/App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // This will connect to our backend API
    fetch('/api/products')
      .then(response => response.json())
      .then(data => {
        setProducts(data);
        setLoading(false);
      })
      .catch(error => {
        console.error('Error fetching products:', error);
        setLoading(false);
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>My E-Commerce Store</h1>
        {loading ? (
          <p>Loading products...</p>
        ) : (
          <div className="products">
            {products.map(product => (
              <div key={product.id} className="product">
                <h3>{product.name}</h3>
                <p>${product.price}</p>
              </div>
            ))}
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
EOF

# Create environment file
cat > .env << 'EOF'
REACT_APP_API_URL=http://localhost:8000
REACT_APP_NAME=E-Commerce Frontend
PORT=3000
EOF

cd ..
```

#### Initialize Backend (Node.js/Express)
```bash
# Navigate to backend directory
cd backend

# Create package.json for Node.js backend
cat > package.json << 'EOF'
{
  "name": "ecommerce-backend",
  "version": "1.0.0",
  "description": "E-commerce backend API",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0",
    "pg": "^8.8.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^8.5.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.20",
    "jest": "^29.0.0"
  }
}
EOF

# Create basic Express server
cat > src/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Sample products data (will be replaced with database)
const products = [
  { id: 1, name: 'Laptop', price: 999.99, category: 'Electronics' },
  { id: 2, name: 'Smartphone', price: 699.99, category: 'Electronics' },
  { id: 3, name: 'Headphones', price: 199.99, category: 'Electronics' },
  { id: 4, name: 'Book', price: 29.99, category: 'Books' }
];

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'E-commerce API is running' });
});

app.get('/api/products', (req, res) => {
  res.json(products);
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === parseInt(req.params.id));
  if (!product) {
    return res.status(404).json({ error: 'Product not found' });
  }
  res.json(product);
});

app.listen(PORT, () => {
  console.log(`E-commerce API server running on port ${PORT}`);
});
EOF

# Create environment file
cat > .env << 'EOF'
PORT=8000
NODE_ENV=development
DATABASE_URL=postgresql://postgres:password@localhost:5432/ecommerce
JWT_SECRET=your-secret-key-here
EOF

cd ..
```

#### Initialize Database Setup
```bash
# Navigate to database directory
cd database

# Create database initialization script
cat > init.sql << 'EOF'
-- E-commerce database schema
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    stock_quantity INTEGER DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, description, price, category, stock_quantity) VALUES
('Laptop', 'High-performance laptop', 999.99, 'Electronics', 10),
('Smartphone', 'Latest smartphone', 699.99, 'Electronics', 25),
('Headphones', 'Wireless headphones', 199.99, 'Electronics', 50),
('Book', 'Programming book', 29.99, 'Books', 100);
EOF

# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
# Database backup script
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backup"
mkdir -p $BACKUP_DIR

echo "Creating database backup..."
pg_dump -h localhost -U postgres ecommerce > $BACKUP_DIR/ecommerce_backup_$DATE.sql
echo "Backup created: $BACKUP_DIR/ecommerce_backup_$DATE.sql"
EOF

chmod +x backup.sh
cd ..
```

#### Create Management Scripts
```bash
# Navigate to scripts directory
cd scripts

# Create service start script
cat > start-services.sh << 'EOF'
#!/bin/bash
echo "Starting E-commerce services..."

# Start database (assuming PostgreSQL is installed)
echo "Starting database..."
sudo systemctl start postgresql

# Start backend API
echo "Starting backend API..."
cd ../backend
npm start &
BACKEND_PID=$!
echo "Backend started with PID: $BACKEND_PID"

# Start frontend
echo "Starting frontend..."
cd ../frontend
npm start &
FRONTEND_PID=$!
echo "Frontend started with PID: $FRONTEND_PID"

# Save PIDs for later use
echo $BACKEND_PID > ../logs/backend.pid
echo $FRONTEND_PID > ../logs/frontend.pid

echo "All services started!"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:8000"
EOF

# Create service stop script
cat > stop-services.sh << 'EOF'
#!/bin/bash
echo "Stopping E-commerce services..."

# Stop frontend
if [ -f ../logs/frontend.pid ]; then
    FRONTEND_PID=$(cat ../logs/frontend.pid)
    kill $FRONTEND_PID 2>/dev/null
    rm ../logs/frontend.pid
    echo "Frontend stopped"
fi

# Stop backend
if [ -f ../logs/backend.pid ]; then
    BACKEND_PID=$(cat ../logs/backend.pid)
    kill $BACKEND_PID 2>/dev/null
    rm ../logs/backend.pid
    echo "Backend stopped"
fi

echo "All services stopped!"
EOF

# Create monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "E-commerce Services Status"
echo "=========================="

# Check frontend
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend: Running (http://localhost:3000)"
else
    echo "❌ Frontend: Not responding"
fi

# Check backend API
if curl -s http://localhost:8000/api/health > /dev/null; then
    echo "✅ Backend API: Running (http://localhost:8000)"
else
    echo "❌ Backend API: Not responding"
fi

# Check database
if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✅ Database: Running"
else
    echo "❌ Database: Not responding"
fi

echo ""
echo "Resource Usage:"
echo "==============="
free -h | head -2
df -h | grep -E "/$|/home"
EOF

# Make scripts executable
chmod +x *.sh
cd ..
```

#### Create Documentation
```bash
# Navigate to docs directory
cd docs

# Create README for the project
cat > README.md << 'EOF'
# E-Commerce Docker Project

This is a complete e-commerce application that we'll progressively containerize using Docker.

## Architecture

- **Frontend**: React application (Port 3000)
- **Backend**: Node.js/Express API (Port 8000)
- **Database**: PostgreSQL (Port 5432)

## Getting Started

### Prerequisites
- Node.js 16+
- PostgreSQL 13+
- Git

### Installation

1. Install dependencies:
```bash
# Frontend
cd frontend && npm install

# Backend
cd ../backend && npm install
```

2. Set up database:
```bash
# Create database and run migrations
cd database
psql -U postgres -f init.sql
```

3. Start services:
```bash
cd scripts
./start-services.sh
```

4. Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Health: http://localhost:8000/api/health

### Development Commands

```bash
# Start all services
./scripts/start-services.sh

# Stop all services
./scripts/stop-services.sh

# Monitor services
./scripts/monitor.sh

# Backup database
./database/backup.sh
```

## Docker Journey

This project will be progressively containerized:

- **Module 1**: Linux foundation and project setup ✅
- **Module 2**: Basic containerization of each service
- **Module 3**: Custom Dockerfiles and optimization
- **Module 4**: Nginx reverse proxy and load balancing
- **Module 5**: Docker Compose orchestration
- **Module 6**: AWS deployment
- **Module 7**: Advanced Docker features
- **Module 8**: Production deployment on AWS

## Project Structure

```
ecommerce-docker-project/
├── frontend/          # React frontend application
├── backend/           # Node.js API server
├── database/          # Database setup and migrations
├── nginx/             # Nginx configuration (added later)
├── scripts/           # Management and deployment scripts
├── docs/              # Documentation
└── logs/              # Application logs
```
EOF

cd ..
```

#### Test Your E-Commerce Setup

```bash
# 1. Verify project structure
echo "Project structure:"
find . -type d -name "node_modules" -prune -o -type f -print | head -20

# 2. Check file permissions
echo -e "\nScript permissions:"
ls -la scripts/*.sh

# 3. Verify configuration files
echo -e "\nConfiguration files:"
find . -name "*.env" -o -name "*.json" -o -name "*.sql" | head -10

# 4. Test scripts (dry run)
echo -e "\nTesting monitor script:"
cd scripts && bash -n monitor.sh && echo "✅ Monitor script syntax OK"
```

### E-Commerce Command Line Practice

Practice these commands with your e-commerce project:

```bash
# 1. Navigate through your project
cd ecommerce-docker-project
ls -la
cd frontend && ls -la && cd ..
cd backend && ls -la && cd ..

# 2. Search for specific configurations
grep -r "PORT" . --include="*.env" --include="*.js"
grep -r "localhost" . --include="*.js" --include="*.json"

# 3. Monitor log files (create some first)
mkdir -p logs
echo "$(date): Application started" >> logs/app.log
tail -f logs/app.log &
# Press Ctrl+C to stop

# 4. Check file sizes and permissions
find . -name "*.js" -exec ls -lh {} \;
find . -name "*.sh" -exec ls -lh {} \;

# 5. Create backup of your project
tar -czf ecommerce-backup-$(date +%Y%m%d).tar.gz ecommerce-docker-project/
ls -lh *.tar.gz
```

### Next Module Preview

In **Module 2: Docker Fundamentals**, you'll:

1. **Containerize Frontend**: `docker run -p 3000:3000 ecommerce-frontend`
2. **Containerize Backend**: `docker run -p 8000:8000 ecommerce-backend`
3. **Containerize Database**: `docker run -p 5432:5432 postgres:13`
4. **Connect Services**: Create Docker networks for service communication
5. **Persist Data**: Use Docker volumes for database and uploads

Your e-commerce application is now ready for the Docker journey!

---

Move to **Module 2: Docker Fundamentals** when you're comfortable with these commands and have your e-commerce project set up.
