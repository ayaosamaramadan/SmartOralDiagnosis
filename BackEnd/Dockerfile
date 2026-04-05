FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY MedicalManagement.API.csproj ./
RUN dotnet restore MedicalManagement.API.csproj

COPY . ./
RUN dotnet publish MedicalManagement.API.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish ./

# Railway injects PORT at runtime; Program.cs handles binding fallback.
ENTRYPOINT ["dotnet", "MedicalManagement.API.dll"]
