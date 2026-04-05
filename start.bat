@echo off
REM Medical Management System Startup Script for Windows
REM This script starts both frontend and backend services

echo Starting Medical Management System...
echo =================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js is not installed. Please install Node.js 18+ and try again.
    pause
    exit /b 1
)

REM Check if .NET is installed
where dotnet >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ .NET SDK is not installed. Please install .NET 8 SDK and try again.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed!
echo.

REM Start Backend
echo Starting .NET Backend...
echo ========================
cd BackEnd

if not exist "MedicalManagement.API.csproj" (
    echo ❌ Backend project file not found. Please make sure you're in the correct directory.
    pause
    exit /b 1
)

REM Restore packages if needed
if not exist "bin" (
    echo 📦 Restoring .NET packages...
    dotnet restore
)

echo 🚀 Starting .NET Web API on %NEXT_BACKEND_SERVER%
start "Medical Management API" cmd /c "dotnet run --project MedicalManagement.API.csproj --urls=%NEXT_BACKEND_SERVER%"

REM Wait for backend to start
timeout /t 5 /nobreak >nul

REM Start Frontend
echo.
echo Starting Next.js Frontend...
echo ============================
cd ..\frontend

if not exist "package.json" (
    echo ❌ Frontend package.json not found. Please make sure you're in the correct directory.
    pause
    exit /b 1
)

REM Install packages if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing npm packages...
    npm install
)

REM Create .env.local if it doesn't exist
if not exist ".env.local" (
    echo 📝 Creating .env.local file...
    copy ".env.local.example" ".env.local"
)

echo 🚀 Starting Next.js on http://localhost:3000
start "Medical Management Frontend" cmd /c "npm run dev"

echo.
echo 🎉 Medical Management System is running!
echo =======================================
echo Frontend: http://localhost:3000
echo Backend API: %NEXT_BACKEND_SERVER%
echo API Documentation: %NEXT_BACKEND_SERVER%/swagger
echo.
echo Press any key to open the application in your browser...
pause >nul

REM Open browser
start http://localhost:3000

echo.
echo Services are running in separate windows.
echo Close the command windows to stop the services.
pause
