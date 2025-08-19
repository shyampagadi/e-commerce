@echo off
REM PostgreSQL Database Setup Script for E-Commerce Application (Windows)
REM This script creates the database, user, and updates the .env file

echo 🚀 PostgreSQL Database Setup for E-Commerce Application
echo ============================================================

REM Check if .env file exists
if not exist ".env" (
    echo ❌ .env file not found!
    pause
    exit /b 1
)

REM Load configuration from .env file
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="DB_NAME" set DB_NAME=%%b
    if "%%a"=="DB_USER" set DB_USER=%%b
    if "%%a"=="DB_PASSWORD" set DB_PASSWORD=%%b
    if "%%a"=="DB_HOST" set DB_HOST=%%b
    if "%%a"=="DB_PORT" set DB_PORT=%%b
)

REM Set default values if not provided
if "%DB_NAME%"=="" set DB_NAME=ecommerce_db
if "%DB_USER%"=="" set DB_USER=ecommerce_user
if "%DB_PASSWORD%"=="" set DB_PASSWORD=ecommerce_password
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_PORT%"=="" set DB_PORT=5432

echo 📋 Configuration:
echo    Database: %DB_NAME%
echo    User: %DB_USER%
echo    Host: %DB_HOST%
echo    Port: %DB_PORT%
echo.

REM Check if PostgreSQL is installed
psql --version >nul 2>&1
if errorlevel 1 (
    echo ❌ PostgreSQL is not installed or not in PATH
    echo.
    echo 💡 Please install PostgreSQL first:
    echo    Download from https://www.postgresql.org/download/windows/
    echo    Make sure to add PostgreSQL bin directory to your PATH
    pause
    exit /b 1
)

echo ✅ PostgreSQL found
psql --version

echo.
echo 🔧 Setting up database and user...

REM Create database (connect as postgres user to postgres database)
echo Creating database %DB_NAME%...
psql -U postgres -d postgres -c "CREATE DATABASE \"%DB_NAME%\";" 2>nul
if errorlevel 1 (
    echo ⚠️  Database '%DB_NAME%' might already exist or creation failed
) else (
    echo ✅ Database '%DB_NAME%' created successfully
)

REM Create user
echo Creating user %DB_USER%...
psql -U postgres -d postgres -c "CREATE USER \"%DB_USER%\" WITH PASSWORD '%DB_PASSWORD%';" 2>nul
if errorlevel 1 (
    echo ⚠️  User '%DB_USER%' might already exist, updating password...
    psql -U postgres -d postgres -c "ALTER USER \"%DB_USER%\" WITH PASSWORD '%DB_PASSWORD%';"
    echo ✅ Updated password for user '%DB_USER%'
) else (
    echo ✅ User '%DB_USER%' created successfully
)

REM Grant privileges
echo Granting privileges...
psql -U postgres -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE \"%DB_NAME%\" TO \"%DB_USER%\";"
psql -U postgres -d postgres -c "ALTER USER \"%DB_USER%\" CREATEDB;"
echo ✅ Granted privileges to user '%DB_USER%'

REM Test connection
echo.
echo 🧪 Testing database connection...
set PGPASSWORD=%DB_PASSWORD%
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ❌ Connection test failed
    echo 💡 You might need to configure PostgreSQL authentication
    pause
    exit /b 1
) else (
    echo ✅ Connection test successful
)

REM Update DATABASE_URL in .env file
echo.
echo 📝 Updating DATABASE_URL in .env file...
set DATABASE_URL=postgresql://%DB_USER%:%DB_PASSWORD%@%DB_HOST%:%DB_PORT%/%DB_NAME%

REM Create temporary file with updated content
set temp_file=%TEMP%\env_temp_%RANDOM%.txt
(
    for /f "delims=" %%i in (.env) do (
        echo %%i | findstr /b "DATABASE_URL=" >nul
        if errorlevel 1 (
            echo %%i
        ) else (
            echo DATABASE_URL=%DATABASE_URL%
        )
    )
) > "%temp_file%"

REM Replace the original file
move "%temp_file%" .env >nul

echo ✅ Updated DATABASE_URL in .env file
echo    DATABASE_URL=%DATABASE_URL%

echo.
echo 🎉 Database Setup Complete!
echo ============================================================
echo ✅ Database '%DB_NAME%' created
echo ✅ User '%DB_USER%' created with full privileges
echo ✅ .env file updated with correct DATABASE_URL
echo.
echo 🚀 Next steps:
echo    1. cd backend
echo    2. python init_db.py  # Initialize tables and sample data
echo    3. uvicorn main:app --reload  # Start the backend server
echo.
echo 🔐 Database Connection Details:
echo    Host: %DB_HOST%
echo    Port: %DB_PORT%
echo    Database: %DB_NAME%
echo    Username: %DB_USER%
echo    Password: [hidden]

pause
