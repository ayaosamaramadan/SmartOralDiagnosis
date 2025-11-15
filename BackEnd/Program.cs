using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IO;
using MedicalManagement.API.Data;
using MedicalManagement.API.Services;
using MedicalManagement.API.Middleware;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter 'Bearer' [space] and then your valid token in the text input below."
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[] {}
        }
    });
});

// CORS (allow frontend during development)
var frontendOrigin = builder.Configuration.GetValue<string>("FrontendOrigin") ?? "http://localhost:3000";
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(frontendOrigin)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=OralDatabase.db";
// Choose provider: if the connection string points to a .db file use SQLite, otherwise use SQL Server
if (connectionString.IndexOf(".db", StringComparison.OrdinalIgnoreCase) >= 0)
{
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlite(connectionString));
}
else
{
    // SQL Server (for connection strings like: Server=...;Initial Catalog=...;...)
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
}

// JWT Authentication
var jwtSection = builder.Configuration.GetSection("Jwt");
var key = jwtSection.GetValue<string>("Key") ?? "dev-key";
var issuer = jwtSection.GetValue<string>("Issuer");
var audience = jwtSection.GetValue<string>("Audience");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
        RoleClaimType = "role"
    };
});

// App services
builder.Services.AddScoped<JwtService>();
// Register MongoDB service for DI so controllers can use it
builder.Services.AddSingleton<MongoDbService>();
// Register Mongo service for DI so controllers can write/read from MongoDB

var app = builder.Build();

// --- ADD: check MongoDB connectivity on startup ---
using (var scope = app.Services.CreateScope())
{
    var mongo = scope.ServiceProvider.GetService<MongoDbService>();
    if (mongo != null)
    {
        var (Ok, Message) = await mongo.PingAsync();
        if (Ok)
        {
            app.Logger.LogInformation("MongoDB: connected successfully.");
        }
        else
        {
            app.Logger.LogWarning("MongoDB: connection failed - {Message}", Message ?? "unknown error");
        }
    }
    else
    {
        app.Logger.LogWarning("MongoDbService is not registered. Skipping MongoDB connectivity check.");
    }
}
// --- end add ---

// Configure
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Global exception handler
app.UseGlobalExceptionHandler();

app.UseHttpsRedirection();

// Serve static files (for uploads)
// Only call UseStaticFiles if the web root folder actually exists to avoid noisy warnings
// when the project doesn't include a `wwwroot` folder.
if (Directory.Exists(app.Environment.WebRootPath))
{
    app.UseStaticFiles();
}
else
{
    app.Logger.LogInformation("WebRootPath '{path}' not found; skipping static file middleware.", app.Environment.WebRootPath);
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.UseCors("AllowFrontend");

// Seed data (development)
// Ensure database is created (no migrations required in dev) and seed sample data
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}
await SeedData.EnsureSeedDataAsync(app.Services);

// Check MongoDB connectivity and log the result so `dotnet run` output shows status
try
{
    using (var scope = app.Services.CreateScope())
    {
        var mongo = scope.ServiceProvider.GetService<MongoDbService>();
        if (mongo != null)
        {
            var (ok, message) = await mongo.PingAsync();
            if (ok)
            {
                app.Logger.LogInformation("MongoDB connection succeeded (database: {db})", builder.Configuration["DatabaseName"]);
            }
            else
            {
                app.Logger.LogWarning("MongoDB connection failed: {msg}", message);
            }
        }
        else
        {
            app.Logger.LogWarning("MongoDbService is not registered in DI. Skipping MongoDB connectivity check.");
        }
    }
}
catch (Exception ex)
{
    app.Logger.LogWarning(ex, "Exception while checking MongoDB connectivity");
}

app.Run();

public partial class Program { }
