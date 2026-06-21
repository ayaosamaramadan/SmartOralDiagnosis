using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using MongoDB.Driver;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DiagnosticsController : ControllerBase
    {
        private readonly MongoDbService _mongo;
        private readonly ILogger<DiagnosticsController> _logger;

        public DiagnosticsController(MongoDbService mongo, ILogger<DiagnosticsController> logger)
        {
            _mongo = mongo;
            _logger = logger;
        }

        [HttpGet("mongo")]
        public async Task<IActionResult> GetMongoStatus()
        {
            try
            {
                var (ok, message) = await _mongo.PingAsync();
                long count = -1;
                string collName = "users";

                if (ok)
                {
                    try
                    {
                        var coll = _mongo.GetCollection<dynamic>(collName);
                        count = await coll.CountDocumentsAsync(FilterDefinition<dynamic>.Empty);
                    }
                    catch (System.Exception ex)
                    {
                        _logger.LogWarning(ex, "Unable to count documents in collection '{Coll}'", collName);
                    }
                }

                return Ok(new { ping = ok, message, collection = collName, count });
            }
            catch (System.InvalidOperationException invEx)
            {
                _logger.LogWarning(invEx, "Mongo not initialized");
                return Ok(new { ping = false, message = "Mongo not initialized (check connection string / DatabaseName)", collection = "users", count = -1 });
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Mongo diagnostics endpoint failed");
                return StatusCode(500, new { ping = false, message = "Unexpected error", detail = ex.Message });
            }
        }
    }
}
