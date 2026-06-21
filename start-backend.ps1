# PowerShell script to start the .NET backend from the repository root
# Usage: Right-click -> "Run with PowerShell" or from PowerShell: .\start-backend.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptDir
Set-Location .\BackEnd
dotnet run --project MedicalManagement.API.csproj
