@echo off
echo Setting up Medical Management System...
echo.

echo Step 1: Setting up Backend (.NET API)
cd backend
echo Installing .NET dependencies...
dotnet restore
if %errorlevel% neq 0 (
    echo Failed to restore .NET packages!
    pause
    exit /b 1
)

echo Building .NET project...
dotnet build
if %errorlevel% neq 0 (
    echo Failed to build .NET project!
    pause
    exit /b 1
)

echo.
echo Step 2: Setting up Frontend (Next.js)
cd ..\frontend
echo Installing Node.js dependencies...
npm install
if %errorlevel% neq 0 (
    echo Failed to install Node.js packages!
    pause
    exit /b 1
)

echo.
echo Step 3: Setting up environment variables
if not exist ".env.local" (
    copy ".env.local.example" ".env.local"
    echo Created .env.local file. Please update it with your configuration.
)

echo.
echo Setup completed successfully!
echo.
echo Next steps:
echo 1. Start MongoDB (mongod)
echo 2. Update connection strings in backend/appsettings.json
echo 3. Update API URL in frontend/.env.local
echo 4. Run 'cd backend && dotnet run' to start the API
echo 5. Run 'cd frontend && npm run dev' to start the frontend
echo.
pause
