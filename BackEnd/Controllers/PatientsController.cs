using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Data;
using MedicalManagement.API.Models;
using MedicalManagement.API.DTOs;
using Microsoft.Extensions.Logging;
using MongoDB.Driver;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PatientsController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly MongoDbService _mongo;
        private readonly ILogger<PatientsController> _logger;

        public PatientsController(AppDbContext db, MongoDbService mongo, ILogger<PatientsController> logger)
        {
            _db = db;
            _mongo = mongo;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetAll()
        {
            var patients = await _db.Users.Where(u => u.Role == UserRole.Patient).ToListAsync();
            return Ok(patients);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<User>> Get(string id)
        {
            var patient = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Patient);
            if (patient == null) return NotFound();
            return Ok(patient);
        }

        [HttpPost]
        public async Task<ActionResult<User>> Create(User dto)
        {
            dto.Role = UserRole.Patient;
            dto.CreatedAt = DateTime.UtcNow;
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Users.Add(dto);
            await _db.SaveChangesAsync();

            // Attempt to sync new patient to MongoDB (non-fatal)
            try
            {
                var coll = _mongo.GetCollection<User>("users");
                var filter = Builders<User>.Filter.Eq(u => u.Id, dto.Id);
                await coll.ReplaceOneAsync(filter, dto, new ReplaceOptions { IsUpsert = true });
            }
            catch (InvalidOperationException)
            {
                _logger.LogInformation("MongoDB not initialized - skipping patient create sync.");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to sync created patient to MongoDB");
            }

            return CreatedAtAction(nameof(Get), new { id = dto.Id }, dto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, UpdateUserDto dto)
        {
            var patient = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Patient);
            if (patient == null) return NotFound();

            if (dto.FirstName != null) patient.FirstName = dto.FirstName;
            if (dto.LastName != null) patient.LastName = dto.LastName;
            if (dto.PhoneNumber != null) patient.PhoneNumber = dto.PhoneNumber;
            if (dto.Photo != null) patient.Photo = dto.Photo;
            if (dto.Location != null) patient.Location = dto.Location;
            if (dto.DateOfBirth != null) patient.DateOfBirth = dto.DateOfBirth;

            patient.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();

            // Attempt to sync update to MongoDB (non-fatal)
            try
            {
                var coll = _mongo.GetCollection<User>("users");
                var filter = Builders<User>.Filter.Eq(u => u.Id, patient.Id);
                await coll.ReplaceOneAsync(filter, patient, new ReplaceOptions { IsUpsert = true });
            }
            catch (InvalidOperationException)
            {
                _logger.LogInformation("MongoDB not initialized - skipping patient update sync.");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to sync updated patient to MongoDB");
            }

            return Ok(patient);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var patient = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Patient);
            if (patient == null) return NotFound();
            _db.Users.Remove(patient);
            await _db.SaveChangesAsync();

            // Attempt to remove from MongoDB (non-fatal)
            try
            {
                var coll = _mongo.GetCollection<User>("users");
                var filter = Builders<User>.Filter.Eq(u => u.Id, patient.Id);
                await coll.DeleteOneAsync(filter);
            }
            catch (InvalidOperationException)
            {
                _logger.LogInformation("MongoDB not initialized - skipping patient delete sync.");
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to delete patient from MongoDB");
            }

            return NoContent();
        }
    }
}
