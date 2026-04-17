using MongoDB.Driver;
using MongoDB.Bson;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

public class MongoDbService
{
    private readonly IMongoDatabase? _database;
    private readonly ILogger<MongoDbService>? _logger;

    public MongoDbService(IConfiguration config, ILogger<MongoDbService>? logger = null)
    {
        _logger = logger;
<<<<<<< HEAD
        var mongoEnabled = GetBoolSetting(config, "MongoDB:Enabled", "MONGODB_ENABLED", true);
        if (!mongoEnabled)
        {
            _logger?.LogInformation("MongoDB is disabled by configuration (MongoDB:Enabled/MONGODB_ENABLED=false).");
            _database = null;
            return;
        }

        var connectionString = config.GetConnectionString("MongoDB");
        var dbName = config["DatabaseName"];
=======
        var connectionString = ResolveMongoConnectionString(config);
        var dbName = ResolveDatabaseName(config);
>>>>>>> a1bad86a04ec8ea7647e92b92663c7d726463ed2

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            _logger?.LogWarning("MongoDB connection string is missing. Set ConnectionStrings__MongoDB, MONGODB_URI, or MONGODB_USERNAME/MONGODB_PASSWORD/MONGODB_HOST in environment variables.");
            _database = null;
            return;
        }

        if (string.IsNullOrWhiteSpace(dbName))
        {
            _logger?.LogWarning("MongoDB database name is missing. Set DatabaseName or MONGODB_DATABASE in environment variables.");
            _database = null;
            return;
        }

        try
        {
            var settings = MongoClientSettings.FromConnectionString(connectionString);
            settings.ServerSelectionTimeout = TimeSpan.FromSeconds(GetPositiveIntSetting(config, "MongoDB:ServerSelectionTimeoutSeconds", "MONGODB_SERVER_SELECTION_TIMEOUT_SECONDS", 5));
            settings.ConnectTimeout = TimeSpan.FromSeconds(GetPositiveIntSetting(config, "MongoDB:ConnectTimeoutSeconds", "MONGODB_CONNECT_TIMEOUT_SECONDS", 5));
            settings.SocketTimeout = TimeSpan.FromSeconds(GetPositiveIntSetting(config, "MongoDB:SocketTimeoutSeconds", "MONGODB_SOCKET_TIMEOUT_SECONDS", 10));

            var client = new MongoClient(settings);
            _database = client.GetDatabase(dbName);
            _logger?.LogInformation("MongoDbService initialized for database '{DbName}'.", dbName);
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Failed to initialize MongoClient with connection string. Mongo features will be disabled.");
            _database = null;
        }
    }

    public IMongoCollection<T> GetCollection<T>(string name)
    {
        if (_database == null)
            throw new InvalidOperationException("MongoDB is not initialized. Check the MongoDB environment variables and database name configuration.");
        return _database.GetCollection<T>(name);
    }

    /// <summary>
    /// Pings the MongoDB server to verify connectivity. Returns (true, null) on success or (false, errorMessage) on failure.
    /// </summary>
    public async Task<(bool Ok, string? Message)> PingAsync()
    {
        try
        {
            var command = new BsonDocument("ping", 1);
            if (_database == null)
            {
                return (false, "MongoDB not initialized");
            }
            await _database.RunCommandAsync<BsonDocument>(command);
            return (true, null);
        }
        catch (System.Exception ex)
        {
            return (false, ex.Message);
        }
    }

<<<<<<< HEAD
    private static bool GetBoolSetting(IConfiguration config, string configKey, string envKey, bool defaultValue)
    {
        var raw = config[configKey] ?? Environment.GetEnvironmentVariable(envKey);
        return bool.TryParse(raw, out var parsed) ? parsed : defaultValue;
    }

    private static int GetPositiveIntSetting(IConfiguration config, string configKey, string envKey, int defaultValue)
    {
        var raw = config[configKey] ?? Environment.GetEnvironmentVariable(envKey);
        return int.TryParse(raw, out var parsed) && parsed > 0 ? parsed : defaultValue;
=======
    private static string? ResolveMongoConnectionString(IConfiguration config)
    {
        var configuredValue = config.GetConnectionString("MongoDB");
        if (!string.IsNullOrWhiteSpace(configuredValue))
        {
            return configuredValue;
        }

        var envConnectionString = GetFirstValue(config, "MongoDB:ConnectionString", "MONGODB_URI", "MONGODB_CONNECTION_STRING", "ConnectionStrings__MongoDB");
        if (!string.IsNullOrWhiteSpace(envConnectionString))
        {
            return envConnectionString;
        }

        var username = GetFirstValue(config, "MongoDB:Username", "MONGODB_USERNAME");
        var password = GetFirstValue(config, "MongoDB:Password", "MONGODB_PASSWORD");
        var host = GetFirstValue(config, "MongoDB:Host", "MONGODB_HOST");

        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(host))
        {
            return null;
        }

        var databaseName = ResolveDatabaseName(config);
        var authSource = GetFirstValue(config, "MongoDB:AuthSource", "MONGODB_AUTH_SOURCE") ?? "admin";
        var appName = GetFirstValue(config, "MongoDB:AppName", "MONGODB_APP_NAME") ?? "SmartOralDiagnosis";

        host = host.Trim().TrimEnd('/');

        if (host.StartsWith("mongodb+srv://", StringComparison.OrdinalIgnoreCase) || host.StartsWith("mongodb://", StringComparison.OrdinalIgnoreCase))
        {
            return host;
        }

        var queryParts = new List<string>
        {
            "retryWrites=true",
            "w=majority",
            $"appName={Uri.EscapeDataString(appName)}"
        };

        if (!string.IsNullOrWhiteSpace(authSource))
        {
            queryParts.Add($"authSource={Uri.EscapeDataString(authSource)}");
        }

        var safeUser = Uri.EscapeDataString(username);
        var safePassword = Uri.EscapeDataString(password);
        var databaseSegment = string.IsNullOrWhiteSpace(databaseName) ? string.Empty : $"/{Uri.EscapeDataString(databaseName)}";

        return $"mongodb+srv://{safeUser}:{safePassword}@{host}{databaseSegment}?{string.Join("&", queryParts)}";
    }

    private static string? ResolveDatabaseName(IConfiguration config)
    {
        return GetFirstValue(config, "DatabaseName", "MongoDB:DatabaseName", "MONGODB_DATABASE", "MONGODB_DB");
    }

    private static string? GetFirstValue(IConfiguration config, string configKey, params string[] envNames)
    {
        var configValue = config[configKey];
        if (!string.IsNullOrWhiteSpace(configValue))
        {
            return configValue;
        }

        foreach (var envName in envNames)
        {
            var envValue = Environment.GetEnvironmentVariable(envName);
            if (!string.IsNullOrWhiteSpace(envValue))
            {
                return envValue;
            }
        }

        return null;
>>>>>>> a1bad86a04ec8ea7647e92b92663c7d726463ed2
    }
}
