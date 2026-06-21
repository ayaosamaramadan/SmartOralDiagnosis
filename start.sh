#!/bin/bash

# Medical Management System Startup Script
# This script starts both frontend and backend services

echo "Starting Medical Management System..."
echo "================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ and try again."
    exit 1
fi

if ! command_exists dotnet; then
    echo "❌ .NET SDK is not installed. Please install .NET 8 SDK and try again."
    exit 1
fi

echo "✅ Prerequisites check passed!"
echo ""

# Start Backend
echo "Starting .NET Backend..."
echo "========================"
cd BackEnd

if [ ! -f "MedicalManagement.API.csproj" ]; then
    echo "❌ Backend project file not found. Please make sure you're in the correct directory."
    exit 1
fi

# Restore packages if needed
if [ ! -d "bin" ] || [ ! -d "obj" ]; then
    echo "📦 Restoring .NET packages..."
    dotnet restore
fi

echo "🚀 Starting .NET Web API on $NEXT_BACKEND_SERVER"
dotnet run --project MedicalManagement.API.csproj --urls="$NEXT_BACKEND_SERVER" &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 5

# Start Frontend
echo ""
echo "Starting Next.js Frontend..."
echo "============================"
cd ../frontend

if [ ! -f "package.json" ]; then
    echo "❌ Frontend package.json not found. Please make sure you're in the correct directory."
    kill $BACKEND_PID
    exit 1
fi

# Install packages if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm packages..."
    npm install
fi

# Create .env.local if it doesn't exist
if [ ! -f ".env.local" ]; then
    echo "📝 Creating .env.local file..."
    cp .env.local.example .env.local
fi

echo "🚀 Starting Next.js on http://localhost:3000"
npm run dev &
FRONTEND_PID=$!

echo ""
echo "🎉 Medical Management System is running!"
echo "======================================="
echo "Frontend: http://localhost:3000"
echo "Backend API: $NEXT_BACKEND_SERVER"
echo "API Documentation: $NEXT_BACKEND_SERVER/swagger"
echo ""
echo "Press Ctrl+C to stop all services"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $FRONTEND_PID 2>/dev/null
    kill $BACKEND_PID 2>/dev/null
    echo "✅ All services stopped."
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup INT TERM

# Wait for either process to exit
wait
