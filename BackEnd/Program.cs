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
using Microsoft.AspNetCore.Http;
using System.Diagnostics;

void LoadDotEnv()
{
    try
    {
        string? dir = Directory.GetCurrentDirectory();
        // Search upward up to 6 levels for a .env file to accommodate running from build output folders
        for (int i = 0; i < 7 && !string.IsNullOrEmpty(dir); i++)
        {
            var candidate = Path.Combine(dir, ".env");
            Console.WriteLine($"LoadDotEnv: checking {candidate}");
            if (File.Exists(candidate))
            {
                Console.WriteLine("LoadDotEnv: found .env at: " + candidate);
                var lines = File.ReadAllLines(candidate);
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
                        var existing = Environment.GetEnvironmentVariable(key);
                        if (string.IsNullOrEmpty(existing))
                        {
                            Environment.SetEnvironmentVariable(key, val);
                            Console.WriteLine($"LoadDotEnv: set {key}={val}");
                        }
                    }
                }
                break;
            }
            dir = Path.GetDirectoryName(dir);
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine("LoadDotEnv: exception while loading .env: " + ex.Message);
    }
}

LoadDotEnv();

// Debug: print key env vars to help troubleshoot .env loading
Console.WriteLine("DEBUG: NEXT_BACKEND_SERVER=" + (Environment.GetEnvironmentVariable("NEXT_BACKEND_SERVER") ?? "<null>"));
Console.WriteLine("DEBUG: NEXT_PUBLIC_BACKEND_URL=" + (Environment.GetEnvironmentVariable("NEXT_PUBLIC_BACKEND_URL") ?? "<null>"));
Console.WriteLine("DEBUG: RAILWAY_STATIC_URL=" + (Environment.GetEnvironmentVariable("RAILWAY_STATIC_URL") ?? "<null>"));
Console.WriteLine("DEBUG: PORT=" + (Environment.GetEnvironmentVariable("PORT") ?? "<null>"));

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
// Gather frontend origin(s) from configuration and common environment variable names
var frontendCandidates = new List<string>();
var cfgFrontend = builder.Configuration.GetValue<string>("FrontendOrigin");
if (!string.IsNullOrWhiteSpace(cfgFrontend)) frontendCandidates.Add(cfgFrontend);

var envNames = new[] { "FRONTEND_ORIGIN", "FRONTEND_ORIGINS", "NEXT_PUBLIC_APP_URL", "NEXT_PUBLIC_FRONTEND_URL", "NEXT_PUBLIC_BACK_URL", "NEXT_PUBLIC_BACKEND_URL", "VERCEL_URL" };
foreach (var n in envNames)
{
    var v = Environment.GetEnvironmentVariable(n);
    if (!string.IsNullOrWhiteSpace(v)) frontendCandidates.Add(v);
}

// Normalize candidates: split on commas/semicolons and ensure scheme present (assume https if missing host-only)
var frontendOrigins = frontendCandidates
    .SelectMany(c => (c ?? string.Empty).Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries))
    .Select(s => s.Trim())
    .Where(s => !string.IsNullOrEmpty(s))
    .Select(s => 
    {
        // If value looks like 'example.vercel.app' or 'example.com' (no scheme), assume https
        if (s.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || s.StartsWith("https://", StringComparison.OrdinalIgnoreCase)) return s;
        // Add https:// for host-only entries and strip any trailing slashes
        return "https://" + s.TrimEnd('/');
    })
    .Distinct(StringComparer.OrdinalIgnoreCase)
    .ToArray();

// Fallback to common local development hosts when nothing configured
if (frontendOrigins.Length == 0)
{
    frontendOrigins = new[] { "http://localhost:3000", "http://localhost:52552", "http://localhost:55695" };
}

Console.WriteLine("Resolved frontend origins for CORS: " + string.Join(", ", frontendOrigins));

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
// Read from config or common environment variable names (loaded from .env by LoadDotEnv()).
var aiBaseUrl = Environment.GetEnvironmentVariable("AI_SERVICE_BASEURL")
                ?? Environment.GetEnvironmentVariable("AI_SERVICE_BASE_URL")
                ?? Environment.GetEnvironmentVariable("AI_BASEURL")
                ?? Environment.GetEnvironmentVariable("AI_BASE_URL")
                ?? builder.Configuration.GetValue<string>("AIService:BaseUrl");
Console.WriteLine("Resolved AI service base URL: " + (aiBaseUrl ?? "<none>"));
builder.Services.AddHttpClient("AIService", client =>
{
    if (!string.IsNullOrEmpty(aiBaseUrl))
    {
        try { client.BaseAddress = new Uri(aiBaseUrl); }
        catch { /* ignore invalid URL here; will surface at runtime */ }
    }
});


builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<CaseSimilarityService>();

builder.Services.AddSingleton<MongoDbService>();

var mongoPingOnStartupRaw = builder.Configuration["MongoDB:PingOnStartup"]
                           ?? Environment.GetEnvironmentVariable("MONGODB_PING_ON_STARTUP");
var mongoPingOnStartup = bool.TryParse(mongoPingOnStartupRaw, out var shouldPingMongoOnStartup) && shouldPingMongoOnStartup;


// Allow configuring which URLs Kestrel will listen on. Default includes 5000 and
// the Flutter web dev port 52552 so the backend can be reached from the browser
// when developing Flutter web locally. This can be overridden by environment
// variable 'BackendUrls' or the standard 'ASPNETCORE_URLS'. Configure the
// WebHost URLs before building the app.
// Allow configuring which URLs Kestrel will listen on. Try config key first,
// then common environment variable names. `LoadDotEnv()` above will populate
// environment variables from a `.env` file if present.
// Prefer explicit backend server variables commonly used in this repo
var backendUrlsRaw = builder.Configuration.GetValue<string>("BackendUrls")
                     ?? Environment.GetEnvironmentVariable("NEXT_PUBLIC_BACKEND_URL")
                     ?? Environment.GetEnvironmentVariable("NEXT_BACKEND_SERVER")
                     ?? Environment.GetEnvironmentVariable("BACKEND_URL")
                     ?? Environment.GetEnvironmentVariable("BACKEND_URLS")
                     ?? Environment.GetEnvironmentVariable("ASPNETCORE_URLS");

// Public hosting platforms (Railway/Heroku) provide a public URL (RAILWAY_STATIC_URL)
// and a runtime `PORT` to bind to. If the public URL exists but no explicit
// backend listen URL is configured, prefer binding to 0.0.0.0:$PORT so the
// platform can route the public domain to the process.
var railwayPublicUrl = Environment.GetEnvironmentVariable("RAILWAY_STATIC_URL")
                       ?? Environment.GetEnvironmentVariable("RAILWAY_URL");
var platformPort = Environment.GetEnvironmentVariable("PORT");

if (string.IsNullOrWhiteSpace(backendUrlsRaw))
{
    if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("NEXT_BACKEND_SERVER")))
    {
        backendUrlsRaw = Environment.GetEnvironmentVariable("NEXT_BACKEND_SERVER");
    }
    else if (!string.IsNullOrWhiteSpace(platformPort))
    {
        backendUrlsRaw = $"http://0.0.0.0:{platformPort}";
    }
}

// Log what we resolved so you can confirm the value from .env / env vars.
Console.WriteLine("Resolved backend URLs from config/env: " + (backendUrlsRaw ?? "<none>"));
if (!string.IsNullOrWhiteSpace(railwayPublicUrl))
{
    Console.WriteLine("Railway/Platform public URL detected: " + railwayPublicUrl + ". The app should be reachable via that domain if the platform routes to this process.");
}

if (!string.IsNullOrWhiteSpace(backendUrlsRaw))
{
    try
    {
        // UseUrls accepts a semicolon-separated list of URLs
        builder.WebHost.UseUrls(backendUrlsRaw);
    }
    catch (Exception ex)
    {
        Console.WriteLine("Failed to call UseUrls with value: " + backendUrlsRaw + " - " + ex.Message);
    }
}

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseGlobalExceptionHandler();


var httpsConfigured = false;

var httpsPortEnv = Environment.GetEnvironmentVariable("ASPNETCORE_HTTPS_PORT");
if (!string.IsNullOrWhiteSpace(httpsPortEnv) && int.TryParse(httpsPortEnv, out _))
{
    httpsConfigured = true;
}

var aspnetcoreUrlsEnv = Environment.GetEnvironmentVariable("ASPNETCORE_URLS");
if (!string.IsNullOrWhiteSpace(aspnetcoreUrlsEnv) &&
    aspnetcoreUrlsEnv.Contains("https://", StringComparison.OrdinalIgnoreCase))
{
    httpsConfigured = true;
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

// Fallback CORS middleware: echo the request Origin when it's allowed
// and ensure OPTIONS preflight requests return the necessary headers.
app.Use(async (context, next) =>
{
    var origin = context.Request.Headers["Origin"].FirstOrDefault();
    var allowAll = string.Equals(Environment.GetEnvironmentVariable("ALLOW_ALL_ORIGINS"), "true", StringComparison.OrdinalIgnoreCase);

    if (!string.IsNullOrEmpty(origin))
    {
        // If the origin matches configured frontend origins OR the host has allowed all origins,
        // echo the origin back so the browser accepts it. This avoids using a wildcard when
        // credentials are involved.
        if (allowAll || frontendOrigins.Contains(origin, StringComparer.OrdinalIgnoreCase))
        {
            context.Response.Headers["Access-Control-Allow-Origin"] = origin;
            context.Response.Headers["Vary"] = "Origin";
        }
    }

    context.Response.Headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,PATCH,DELETE,OPTIONS";
    context.Response.Headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization";

    // If credentials are allowed by policy or in permissive mode, expose the credential header.
    if (allowAll || frontendOrigins.Length > 0)
    {
        context.Response.Headers["Access-Control-Allow-Credentials"] = "true";
    }

    if (HttpMethods.IsOptions(context.Request.Method))
    {
        context.Response.StatusCode = StatusCodes.Status204NoContent;
        await context.Response.CompleteAsync();
        return;
    }

    await next();
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "ok" })).AllowAnonymous();


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

if (mongoPingOnStartup)
{
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
}
else
{
    app.Logger.LogInformation("Skipping MongoDB startup connectivity check (set MongoDB:PingOnStartup=true or MONGODB_PING_ON_STARTUP=true to enable).");
}

app.Run();

public partial class Program { }
