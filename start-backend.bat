@echo off
REM Start the .NET backend from repo root (Windows batch)
REM Usage: double-click or run from PowerShell/CMD in repo root.
cd /d "%~dp0\BackEnd"
dotnet run --project MedicalManagement.API.csproj
