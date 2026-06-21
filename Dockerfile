FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file first for better restore layer caching
COPY BackEnd/MedicalManagement.API.csproj BackEnd/
RUN dotnet restore BackEnd/MedicalManagement.API.csproj

# Copy the backend source and publish
COPY BackEnd/. BackEnd/
WORKDIR /src/BackEnd
RUN dotnet publish MedicalManagement.API.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

# Railway injects PORT at runtime. Program.cs already supports PORT fallback.
ENTRYPOINT ["dotnet", "MedicalManagement.API.dll"]
