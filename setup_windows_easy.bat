@echo off
REM Easy Windows Setup for E-Commerce Application
REM This script installs packages one by one to avoid build issues

echo 🚀 Easy Windows Setup for E-Commerce Application
echo =================================================

REM Check if uv is installed
uv --version >nul 2>&1
if errorlevel 1 (
    echo ❌ UV is not installed!
    echo.
    echo 💡 Install UV first:
    echo    powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    pause
    exit /b 1
)

echo ✅ UV found
uv --version

REM Navigate to backend directory
echo.
echo 📁 Setting up backend environment...
cd backend

REM Create virtual environment with uv
echo 🔧 Creating virtual environment with uv...
uv venv

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call .venv\Scripts\activate.bat

echo 📦 Installing core dependencies...

REM Install packages one by one to avoid build conflicts
echo Installing FastAPI...
uv pip install fastapi==0.104.1

echo Installing Uvicorn...
uv pip install "uvicorn[standard]==0.24.0"

echo Installing SQLAlchemy...
uv pip install sqlalchemy==2.0.23

echo Installing Alembic...
uv pip install alembic==1.12.1

echo Installing authentication packages...
uv pip install "python-jose[cryptography]==3.3.0"
uv pip install "passlib[bcrypt]==1.7.4"

echo Installing utility packages...
uv pip install python-multipart==0.0.6
uv pip install python-dotenv==1.0.0
uv pip install aiofiles==23.2.1
uv pip install python-slugify==8.0.1

echo Installing Pydantic...
uv pip install pydantic==2.5.0
uv pip install pydantic-settings==2.1.0
uv pip install email-validator==2.1.0

echo Installing development packages...
uv pip install pytest==7.4.3
uv pip install pytest-asyncio==0.21.1
uv pip install httpx==0.25.2
uv pip install faker==20.1.0

REM Try to install psycopg2-binary (database driver)
echo Installing PostgreSQL driver...
uv pip install psycopg2-binary==2.9.9
if errorlevel 1 (
    echo ⚠️  psycopg2-binary failed, trying alternative...
    uv pip install psycopg2-binary --no-build-isolation
    if errorlevel 1 (
        echo ❌ Failed to install PostgreSQL driver
        echo 💡 You can continue without it and install later
        echo    Alternative: Use SQLite for development
    )
)

REM Try to install Pillow (image processing)
echo Installing Pillow for image processing...
uv pip install pillow
if errorlevel 1 (
    echo ⚠️  Pillow failed, trying alternative...
    uv pip install pillow --no-build-isolation
    if errorlevel 1 (
        echo ❌ Failed to install Pillow
        echo 💡 You can continue without image processing for now
    )
)

echo ✅ Backend dependencies installed!

REM Go back to root directory
cd ..

REM Setup frontend
echo.
echo 📁 Setting up frontend environment...
cd frontend

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed!
    echo.
    echo 💡 Install Node.js first:
    echo    https://nodejs.org/en/download/
    pause
    exit /b 1
)

echo ✅ Node.js found
node --version

REM Install frontend dependencies
echo 📦 Installing frontend dependencies...
npm install

echo ✅ Frontend dependencies installed successfully!

REM Go back to root directory
cd ..

echo.
echo 🎉 Setup Complete!
echo ========================================
echo ✅ Backend virtual environment created
echo ✅ Most Python dependencies installed
echo ✅ Frontend dependencies installed
echo.
echo 🚀 Next steps:
echo.
echo 1️⃣  Setup Database:
echo    python setup_database.py
echo.
echo 2️⃣  Initialize Database:
echo    cd backend
echo    .venv\Scripts\activate.bat
echo    python init_db.py
echo.
echo 3️⃣  Start Backend Server:
echo    uvicorn main:app --reload
echo.
echo 4️⃣  Start Frontend (in new terminal):
echo    cd frontend
echo    npm start
echo.
echo 💡 If you had package installation issues:
echo    - For psycopg2: Install PostgreSQL with development headers
echo    - For Pillow: Install Visual C++ Build Tools
echo    - Alternative: Use SQLite for development (modify database.py)

pause
