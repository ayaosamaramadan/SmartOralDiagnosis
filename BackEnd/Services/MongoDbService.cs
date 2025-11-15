using MongoDB.Driver;
using MongoDB.Bson;
using System.Threading.Tasks;

public class MongoDbService
{
    private readonly IMongoDatabase _database;

    public MongoDbService(IConfiguration config)
    {
        var connectionString = config.GetConnectionString("MongoDB");
        var client = new MongoClient(connectionString);
        _database = client.GetDatabase(config["DatabaseName"]);
    }

    public IMongoCollection<T> GetCollection<T>(string name)
    {
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
            await _database.RunCommandAsync<BsonDocument>(command);
            return (true, null);
        }
        catch (System.Exception ex)
        {
            return (false, ex.Message);
        }
    }
}
