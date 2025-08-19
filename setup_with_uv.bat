@echo off
REM E-Commerce Application Setup Script using UV (Windows)
REM This script sets up the entire project with uv for fast dependency management

echo 🚀 E-Commerce Application Setup with UV
echo ========================================

REM Check if uv is installed
uv --version >nul 2>&1
if errorlevel 1 (
    echo ❌ UV is not installed!
    echo.
    echo 💡 Install UV first:
    echo    powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    echo    # or
    echo    pip install uv
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

REM Install dependencies with uv (much faster than pip)
echo 📦 Installing Python dependencies with uv...
uv pip install -r requirements.txt

echo ✅ Backend dependencies installed successfully!

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
echo ✅ Backend virtual environment created with uv
echo ✅ Python dependencies installed
echo ✅ Frontend dependencies installed
echo.
echo 🚀 Next steps:
echo.
echo 1️⃣  Setup Database:
echo    python setup_database.py
echo.
echo 2️⃣  Initialize Database:
echo    cd backend
echo    .venv\Scripts\activate.bat  # Activate virtual environment
echo    python init_db.py
echo.
echo 3️⃣  Start Backend Server:
echo    uvicorn main:app --reload
echo.
echo 4️⃣  Start Frontend (in new terminal):
echo    cd frontend
echo    npm start
echo.
echo 🔗 Application URLs:
echo    Frontend: http://localhost:3000
echo    Backend API: http://localhost:8000
echo    API Docs: http://localhost:8000/docs

pause
