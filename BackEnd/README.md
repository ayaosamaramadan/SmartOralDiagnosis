# BackEnd/ MedicalManagement.API

This is a minimal ASP.NET Core Web API for managing Doctor entities.

Quick start (Windows PowerShell):

1. Install .NET SDK 7.0 or later: https://dotnet.microsoft.com/download
2. Open PowerShell in this folder (`BackEnd`) and run:

```powershell
dotnet restore
dotnet build
dotnet ef migrations add InitialCreate --startup-project . --project . || echo "Run migrations manually if ef tool not installed"
dotnet run
```

The API will be available at https://localhost:5001 (or the address shown in console). Swagger UI is enabled in Development.

Notes:
- This project uses SQLite by default (`appsettings.json` Data Source `medical.db`).
- If you want SQL Server or another provider, change the connection string in `appsettings.json` and the provider in `Program.cs`.
