#!/usr/bin/env bash
# Start the .NET backend from the repository root (Unix/macOS/Linux)
# Usage: ./start-backend.sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/BackEnd" || exit 1
dotnet run --project MedicalManagement.API.csproj
