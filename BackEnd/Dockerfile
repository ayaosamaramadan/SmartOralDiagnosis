# Multi-stage Dockerfile for .NET 6 Web API
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# copy csproj and restore as distinct layers
COPY BackEnd/MedicalManagement.API.csproj BackEnd/MedicalManagement.API.csproj
RUN dotnet restore BackEnd/MedicalManagement.API.csproj

# copy everything and publish
COPY . .
RUN dotnet publish BackEnd/MedicalManagement.API.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Listen on port 5000 inside the container
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000
ENTRYPOINT ["dotnet", "MedicalManagement.API.dll"]
