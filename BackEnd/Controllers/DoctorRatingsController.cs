using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MongoDB.Driver;
using MongoDB.Bson;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/doctors/ratings")]
    public class DoctorRatingsController : ControllerBase
    {
        private readonly MongoDbService _mongo;

        public DoctorRatingsController(MongoDbService mongo)
        {
            _mongo = mongo;
        }

        // POST: api/doctors/ratings
        // Body: { doctorId, score, comment }
        [HttpPost]
        [Authorize]
        public async Task<ActionResult<DoctorRating>> Create([FromBody] DoctorRating dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.DoctorId))
                return BadRequest("doctorId is required");

            var col = _mongo.GetCollection<DoctorRating>("doctorRatings");

            // associate current user if available
            var userId = User?.FindFirst("sub")?.Value ?? User?.Identity?.Name;
            dto.UserId = dto.UserId ?? userId;
            dto.CreatedAt = DateTime.UtcNow;

            await col.InsertOneAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = dto.Id }, dto);
        }

        // GET: api/doctors/ratings/{id}
        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<ActionResult<DoctorRating>> GetById(string id)
        {
            var col = _mongo.GetCollection<DoctorRating>("doctorRatings");
            var filter = Builders<DoctorRating>.Filter.Eq(r => r.Id, id);
            var item = await col.Find(filter).FirstOrDefaultAsync();
            if (item == null) return NotFound();
            return Ok(item);
        }

        // GET: api/doctors/ratings/doctor/{doctorId}
        [HttpGet("doctor/{doctorId}")]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<DoctorRating>>> GetByDoctor(string doctorId)
        {
            var col = _mongo.GetCollection<DoctorRating>("doctorRatings");
            var filter = Builders<DoctorRating>.Filter.Eq(r => r.DoctorId, doctorId);
            var items = await col.Find(filter).SortByDescending(r => r.CreatedAt).ToListAsync();
            return Ok(items);
        }

        // GET: api/doctors/ratings/average/{doctorId}
        [HttpGet("average/{doctorId}")]
        [AllowAnonymous]
        public async Task<ActionResult> GetAverage(string doctorId)
        {
            var col = _mongo.GetCollection<DoctorRating>("doctorRatings");
            var filter = Builders<DoctorRating>.Filter.Eq(r => r.DoctorId, doctorId);
            var pipeline = new BsonDocument[] {
                new BsonDocument{"$match", new BsonDocument("doctorId", doctorId) },
                new BsonDocument{"$group", new BsonDocument{ {"_id", "$doctorId"}, {"avg", new BsonDocument("$avg", "$score")}, {"count", new BsonDocument("$sum", 1)} } }
            };

            var db = _mongo.GetCollection<DoctorRating>("doctorRatings");
            var agg = await db.AggregateAsync<BsonDocument>(pipeline);
            var result = await agg.FirstOrDefaultAsync();
            if (result == null) return Ok(new { average = 0m, count = 0 });

            decimal avg = 0m;
            int count = 0;

            if (result.Contains("avg") && !result["avg"].IsBsonNull)
            {
                var v = result["avg"];
                if (v.IsDouble) avg = Convert.ToDecimal(v.AsDouble);
                else if (v.IsDecimal128) avg = Convert.ToDecimal(v.AsDecimal128.ToDecimal());
                else if (v.IsInt32) avg = v.AsInt32;
                else if (v.IsInt64) avg = Convert.ToDecimal(v.AsInt64);
            }

            if (result.Contains("count") && !result["count"].IsBsonNull)
            {
                var c = result["count"];
                if (c.IsInt32) count = c.AsInt32;
                else if (c.IsInt64) count = (int)c.AsInt64;
            }
            return Ok(new { average = avg, count });
        }
    }
}
