using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Data;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PatientsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public PatientsController(AppDbContext db)
        {
            _db = db;
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
            return CreatedAtAction(nameof(Get), new { id = dto.Id }, dto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, User dto)
        {
            if (id != dto.Id) return BadRequest();
            var exists = await _db.Users.AnyAsync(u => u.Id == id && u.Role == UserRole.Patient);
            if (!exists) return NotFound();
            dto.Role = UserRole.Patient;
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Entry(dto).State = EntityState.Modified;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var patient = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Patient);
            if (patient == null) return NotFound();
            _db.Users.Remove(patient);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
