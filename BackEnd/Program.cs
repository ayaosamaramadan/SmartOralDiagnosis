using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IO;
using MedicalManagement.API.Data;
using MedicalManagement.API.Services;
using MedicalManagement.API.Middleware;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authorization;

void LoadDotEnv()
{
    try
    {
        string? cwd = Directory.GetCurrentDirectory();
        var candidates = new[] {
            Path.Combine(cwd, ".env"),
            Path.Combine(cwd, "..", ".env"),
            Path.Combine(cwd, "..", "..", ".env")
        };

        foreach (var path in candidates)
        {
            if (File.Exists(path))
            {
                var lines = File.ReadAllLines(path);
                foreach (var raw in lines)
                {
                    var line = raw.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("#")) continue;
                    var idx = line.IndexOf('=');
                    if (idx <= 0) continue;
                    var key = line.Substring(0, idx).Trim();
                    var val = line.Substring(idx + 1).Trim().Trim('"').Trim('\'');
                    if (!string.IsNullOrEmpty(key))
                    {
                        // If env var already present, don't overwrite
                        if (Environment.GetEnvironmentVariable(key) == null)
                        {
                            Environment.SetEnvironmentVariable(key, val);
                        }
                    }
                }
                break;
            }
        }
    }
    catch
    {
          }
}

LoadDotEnv();

var builder = WebApplication.CreateBuilder(args);


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


// Support multiple frontend origins (comma-separated) and include flutter web default host/port
var frontendOriginsRaw = builder.Configuration.GetValue<string>("FrontendOrigin") ?? "http://localhost:3000,http://localhost:52552,http://localhost:55695";
var frontendOrigins = frontendOriginsRaw.Split(new[] {',',';'}, StringSplitOptions.RemoveEmptyEntries)
    .Select(s => s.Trim()).Where(s => !string.IsNullOrEmpty(s)).ToArray();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        // If no specific origins configured, fall back to allowing localhost origins used in development
        if (frontendOrigins.Length == 0)
        {
            policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
        }
        else
        {
            policy.WithOrigins(frontendOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
    });
});


var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=OralDatabase.db";
if (connectionString.IndexOf(".db", StringComparison.OrdinalIgnoreCase) >= 0)
{
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlite(connectionString));
}
else
{
     builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
}


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
        ValidateIssuer = !string.IsNullOrEmpty(issuer),
        ValidateAudience = !string.IsNullOrEmpty(audience),
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
        RoleClaimType = "role",
        ValidateLifetime = true
    };
});

// Require authentication globally by default. Controllers/actions marked with
// [AllowAnonymous] will opt out (e.g. register/login).
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();

    // Helpful role-based policies for controllers/actions to use.
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("DoctorOrAdmin", policy => policy.RequireRole("Doctor", "Admin"));
});

// Register an HttpClient for contacting the external AI inference service.
var aiBaseUrl = builder.Configuration.GetValue<string>("AIService:BaseUrl") ?? Environment.GetEnvironmentVariable("AI_SERVICE_BASEURL");
builder.Services.AddHttpClient("AIService", client =>
{
    if (!string.IsNullOrEmpty(aiBaseUrl)) client.BaseAddress = new Uri(aiBaseUrl);
});


builder.Services.AddScoped<JwtService>();

builder.Services.AddSingleton<MongoDbService>();


// Allow configuring which URLs Kestrel will listen on. Default includes 5000 and
// the Flutter web dev port 52552 so the backend can be reached from the browser
// when developing Flutter web locally. This can be overridden by environment
// variable 'BackendUrls' or the standard 'ASPNETCORE_URLS'. Configure the
// WebHost URLs before building the app.
var backendUrlsRaw = builder.Configuration["BackendUrls"] ?? Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://localhost:5000;http://localhost:52552";
try
{
    // UseUrls accepts a semicolon-separated list of URLs
    builder.WebHost.UseUrls(backendUrlsRaw);
}
catch
{
    // We'll log later once the app exists
}

var app = builder.Build();


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

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseGlobalExceptionHandler();


var httpsConfigured = false;

var httpsEnv = Environment.GetEnvironmentVariable("ASPNETCORE_HTTPS_PORT") ??
               Environment.GetEnvironmentVariable("ASPNETCORE_URLS");
if (!string.IsNullOrWhiteSpace(httpsEnv))
{
    httpsConfigured = httpsEnv.Contains("https://") || httpsEnv.Any(char.IsDigit);
}


var kestrelHttps = builder.Configuration["Kestrel:Endpoints:Https:Url"]; 
if (!string.IsNullOrWhiteSpace(kestrelHttps)) httpsConfigured = true;

if (httpsConfigured)
{
    app.UseHttpsRedirection();
}
else
{
    app.Logger.LogInformation("Skipping HTTPS redirection: no HTTPS endpoint detected. To enable, set 'ASPNETCORE_HTTPS_PORT' or configure Kestrel endpoints in appsettings.json or launchSettings.json.");
}


if (Directory.Exists(app.Environment.WebRootPath))
{
    app.UseStaticFiles();
}
else
{
    app.Logger.LogInformation("WebRootPath '{path}' not found; skipping static file middleware.", app.Environment.WebRootPath);
}

// Apply CORS policy early so preflight (OPTIONS) requests are handled
// before authentication/authorization middleware runs.
app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();


using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();

    // Development convenience: ensure `Location` column exists on Users table for SQLite
    // This helps when adding properties to the model without running EF migrations.
    try
    {
        var conn = db.Database.GetDbConnection();
        conn.Open();
        using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = "PRAGMA table_info('Users');";
            using var reader = cmd.ExecuteReader();
            var hasLocation = false;
            while (reader.Read())
            {
                // second column is name
                var name = reader.IsDBNull(1) ? null : reader.GetString(1);
                if (string.Equals(name, "Location", StringComparison.OrdinalIgnoreCase))
                {
                    hasLocation = true;
                    break;
                }
            }
            if (!hasLocation)
            {
                using var addCmd = conn.CreateCommand();
                addCmd.CommandText = "ALTER TABLE Users ADD COLUMN Location TEXT;";
                addCmd.ExecuteNonQuery();
            }
        }
    }
    catch (Exception ex)
    {
        // Non-fatal: log and continue. In production, proper migrations should be used.
        app.Logger.LogWarning(ex, "Failed to ensure Location column on Users table");
    }
}
await SeedData.EnsureSeedDataAsync(app.Services);

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
