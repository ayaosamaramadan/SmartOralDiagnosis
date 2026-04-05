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
        var mongoEnabled = GetBoolSetting(config, "MongoDB:Enabled", "MONGODB_ENABLED", true);
        if (!mongoEnabled)
        {
            _logger?.LogInformation("MongoDB is disabled by configuration (MongoDB:Enabled/MONGODB_ENABLED=false).");
            _database = null;
            return;
        }

        var connectionString = config.GetConnectionString("MongoDB");
        var dbName = config["DatabaseName"];

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            _logger?.LogWarning("MongoDB connection string is empty or missing (ConnectionStrings:MongoDB). Mongo features will be disabled.");
            _database = null;
            return;
        }

        if (string.IsNullOrWhiteSpace(dbName))
        {
            _logger?.LogWarning("MongoDB database name is empty or missing (DatabaseName). Mongo features will be disabled.");
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
            throw new InvalidOperationException("MongoDB is not initialized. Check connection string and DatabaseName in configuration.");
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

    private static bool GetBoolSetting(IConfiguration config, string configKey, string envKey, bool defaultValue)
    {
        var raw = config[configKey] ?? Environment.GetEnvironmentVariable(envKey);
        return bool.TryParse(raw, out var parsed) ? parsed : defaultValue;
    }

    private static int GetPositiveIntSetting(IConfiguration config, string configKey, string envKey, int defaultValue)
    {
        var raw = config[configKey] ?? Environment.GetEnvironmentVariable(envKey);
        return int.TryParse(raw, out var parsed) && parsed > 0 ? parsed : defaultValue;
    }
}
