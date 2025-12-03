using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using Microsoft.AspNetCore.Authorization;
using System.Linq;
using System;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly MongoDbService _mongo;
        private readonly ILogger<ChatController> _logger;

        public ChatController(MongoDbService mongo, ILogger<ChatController> logger)
        {
            _mongo = mongo;
            _logger = logger;
        }

        [AllowAnonymous]
        [HttpPost("messages")]
        public async Task<IActionResult> PostMessage([FromBody] ChatMessageDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.SessionId) || string.IsNullOrWhiteSpace(dto.Role) || string.IsNullOrWhiteSpace(dto.Content))
                return BadRequest(new { message = "sessionId, role and content are required" });

            try
            {
                var coll = _mongo.GetCollection<BsonDocument>("chat_messages");
                var doc = new BsonDocument
                {
                    { "sessionId", dto.SessionId },
                    { "role", dto.Role },
                    { "content", dto.Content },
                    { "createdAt", DateTime.UtcNow }
                };
                await coll.InsertOneAsync(doc);
                return Ok(new { id = doc.GetValue("_id").ToString() });
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Failed to insert chat message");
                return StatusCode(500, new { message = "Failed to save message", detail = ex.Message });
            }
        }

        [AllowAnonymous]
        [HttpGet("messages/{sessionId}")]
        public async Task<IActionResult> GetMessages(string sessionId, int limit = 100)
        {
            if (string.IsNullOrWhiteSpace(sessionId)) return BadRequest(new { message = "sessionId is required" });
            try
            {
                var coll = _mongo.GetCollection<BsonDocument>("chat_messages");
                var filter = Builders<BsonDocument>.Filter.Eq("sessionId", sessionId);
                var sort = Builders<BsonDocument>.Sort.Ascending("createdAt");
                var docs = await coll.Find(filter).Sort(sort).Limit(limit).ToListAsync();
                var result = docs.Select(d => new {
                    id = d.GetValue("_id").ToString(),
                    sessionId = d.GetValue("sessionId").AsString,
                    role = d.GetValue("role").AsString,
                    content = d.GetValue("content").AsString,
                    createdAt = d.GetValue("createdAt").ToUniversalTime()
                });
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Failed to get chat messages");
                return StatusCode(500, new { message = "Failed to fetch messages", detail = ex.Message });
            }
        }
    }

    public class ChatMessageDto
    {
        public string SessionId { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty; // user | assistant | system
        public string Content { get; set; } = string.Empty;
    }
}
