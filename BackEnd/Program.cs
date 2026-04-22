using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IO;
using System.Net;
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

bool IsLoopbackAiHost(string value)
{
    if (string.IsNullOrWhiteSpace(value)) return false;

    if (!Uri.TryCreate(value, UriKind.Absolute, out var uri))
    {
        if (!Uri.TryCreate($"http://{value}", UriKind.Absolute, out uri))
        {
            return false;
        }
    }

    var host = uri.Host;
    if (string.Equals(host, "localhost", StringComparison.OrdinalIgnoreCase)
        || string.Equals(host, "0.0.0.0", StringComparison.OrdinalIgnoreCase))
    {
        return true;
    }

    return IPAddress.TryParse(host, out var ipAddress) && IPAddress.IsLoopback(ipAddress);
}

bool IsLikelyHostedEnvironment()
{
    return !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("PORT"))
        || !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("RAILWAY_STATIC_URL"))
        || !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("RAILWAY_URL"));
}

string? NormalizeAiBaseUrl(string? rawValue)
{
    if (string.IsNullOrWhiteSpace(rawValue)) return null;

    var candidate = rawValue.Trim().TrimEnd('/');
    if (!candidate.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
        && !candidate.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
    {
        candidate = $"http://{candidate}";
    }

    if (!Uri.TryCreate(candidate, UriKind.Absolute, out var uri))
    {
        return null;
    }

    var absolute = uri.AbsoluteUri.TrimEnd('/');

    if (absolute.EndsWith("/api/ai/predict", StringComparison.OrdinalIgnoreCase))
    {
        absolute = absolute.Substring(0, absolute.Length - "/api/ai/predict".Length);
    }
    else if (absolute.EndsWith("/predict", StringComparison.OrdinalIgnoreCase))
    {
        absolute = absolute.Substring(0, absolute.Length - "/predict".Length);
    }

    return absolute.EndsWith('/') ? absolute : absolute + "/";
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


var allowedFrontendOrigin = "https://smod-ui.vercel.app";
Console.WriteLine("Configured CORS origin: " + allowedFrontendOrigin);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(allowedFrontendOrigin)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
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
var aiBaseUrlCandidates = new[]
{
    Environment.GetEnvironmentVariable("AI_SERVICE_BASEURL"),
    Environment.GetEnvironmentVariable("AI_SERVICE_BASE_URL"),
    Environment.GetEnvironmentVariable("AI_BASEURL"),
    Environment.GetEnvironmentVariable("AI_BASE_URL"),
    builder.Configuration.GetValue<string>("AiService:BaseUrl"),
    builder.Configuration.GetValue<string>("AIService:BaseUrl"),
    Environment.GetEnvironmentVariable("NEXT_PUBLIC_AI_URL"),
    "https://web-production-4e3e5.up.railway.app"
};

string? aiBaseUrl = null;
foreach (var candidate in aiBaseUrlCandidates)
{
    var normalizedCandidate = NormalizeAiBaseUrl(candidate);
    if (string.IsNullOrWhiteSpace(normalizedCandidate))
    {
        continue;
    }

    var allowLoopbackAi = builder.Environment.IsDevelopment() && !IsLikelyHostedEnvironment();

    if (IsLoopbackAiHost(normalizedCandidate) && !allowLoopbackAi)
    {
        Console.WriteLine("Skipping loopback AI service URL. Railway/public AI URL is required: " + normalizedCandidate);
        continue;
    }

    if (IsLoopbackAiHost(normalizedCandidate) && allowLoopbackAi)
    {
        Console.WriteLine("Allowing loopback AI service URL: " + normalizedCandidate);
    }

    aiBaseUrl = normalizedCandidate;
    break;
}

Console.WriteLine("Resolved AI service base URL: " + (aiBaseUrl ?? "<none>"));
if (string.IsNullOrWhiteSpace(aiBaseUrl))
{
    Console.WriteLine("WARNING: No valid AI service base URL resolved. '/api/ai/predict' requests will fail until AI_SERVICE_BASEURL or AiService:BaseUrl is set.");
}

builder.Services.AddHttpClient("AiService", client =>
{
    if (!string.IsNullOrEmpty(aiBaseUrl))
    {
        try { client.BaseAddress = new Uri(aiBaseUrl); }
        catch { /* ignore invalid URL here; will surface at runtime */ }
    }
    // Allow configuring AI request timeout via env or config. Default to 60s for
    // potentially slow model inference or cold-start scenarios.
    var aiTimeoutSeconds = 60;
    var envTimeout = Environment.GetEnvironmentVariable("AI_SERVICE_TIMEOUT_SECONDS");
    if (!string.IsNullOrWhiteSpace(envTimeout) && int.TryParse(envTimeout, out var parsedEnv) && parsedEnv > 0)
    {
        aiTimeoutSeconds = parsedEnv;
    }
    else
    {
        var confTimeout = builder.Configuration.GetValue<int?>("AiService:TimeoutSeconds")
                          ?? builder.Configuration.GetValue<int?>("AIService:TimeoutSeconds");
        if (confTimeout.HasValue && confTimeout.Value > 0)
        {
            aiTimeoutSeconds = confTimeout.Value;
        }
    }

    client.Timeout = TimeSpan.FromSeconds(aiTimeoutSeconds);
    Console.WriteLine($"AI service HTTP client timeout set to {aiTimeoutSeconds} seconds");
});

builder.Services.AddScoped<AiService>();


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

var resolvedListenUrls = backendUrlsRaw;
if (!string.IsNullOrWhiteSpace(platformPort))
{
    // On managed hosts like Railway, always bind to the injected runtime port.
    resolvedListenUrls = $"http://0.0.0.0:{platformPort}";
}

// Log what we resolved so you can confirm the value from .env / env vars.
Console.WriteLine("Resolved backend URLs from config/env: " + (backendUrlsRaw ?? "<none>"));
Console.WriteLine("Resolved backend listen URLs: " + (resolvedListenUrls ?? "<none>"));
if (!string.IsNullOrWhiteSpace(railwayPublicUrl))
{
    Console.WriteLine("Railway/Platform public URL detected: " + railwayPublicUrl + ". The app should be reachable via that domain if the platform routes to this process.");
}

if (!string.IsNullOrWhiteSpace(resolvedListenUrls))
{
    try
    {
        // UseUrls accepts a semicolon-separated list of URLs
        builder.WebHost.UseUrls(resolvedListenUrls);
    }
    catch (Exception ex)
    {
        Console.WriteLine("Failed to call UseUrls with value: " + resolvedListenUrls + " - " + ex.Message);
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

// Apply CORS policy before auth and endpoint mapping.
app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "ok" })).AllowAnonymous();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();

    // Development convenience: ensure `Location` column exists on Users table for SQLite.
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
