#!/bin/bash

echo "Setting up Medical Management System..."
echo

echo "Step 1: Setting up Backend (.NET API)"
cd backend
echo "Installing .NET dependencies..."
dotnet restore
if [ $? -ne 0 ]; then
    echo "Failed to restore .NET packages!"
    exit 1
fi

echo "Building .NET project..."
dotnet build
if [ $? -ne 0 ]; then
    echo "Failed to build .NET project!"
    exit 1
fi

echo
echo "Step 2: Setting up Frontend (Next.js)"
cd ../frontend
echo "Installing Node.js dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "Failed to install Node.js packages!"
    exit 1
fi

echo
echo "Step 3: Setting up environment variables"
if [ ! -f ".env.local" ]; then
    cp ".env.local.example" ".env.local"
    echo "Created .env.local file. Please update it with your configuration."
fi

echo
echo "Setup completed successfully!"
echo
echo "Next steps:"
echo "1. Start MongoDB (mongod)"
echo "2. Update connection strings in backend/appsettings.json"
echo "3. Update API URL in frontend/.env.local"
echo "4. Run 'cd backend && dotnet run' to start the API"
echo "5. Run 'cd frontend && npm run dev' to start the frontend"
echo
