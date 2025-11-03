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
    public class DoctorsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public DoctorsController(AppDbContext db)
        {
            _db = db;
        }

        // GET: api/doctors
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetAll()
        {
            var doctors = await _db.Users.Where(u => u.Role == UserRole.Doctor).ToListAsync();
            return Ok(doctors);
        }

        // GET: api/doctors/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> Get(string id)
        {
            var doctor = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Doctor);
            if (doctor == null) return NotFound();
            return Ok(doctor);
        }

        // POST: api/doctors
        [HttpPost]
        public async Task<ActionResult<User>> Create(User dto)
        {
            dto.Role = UserRole.Doctor;
            dto.CreatedAt = DateTime.UtcNow;
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Users.Add(dto);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(Get), new { id = dto.Id }, dto);
        }

        // PUT: api/doctors/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, User dto)
        {
            if (id != dto.Id) return BadRequest();
            var exists = await _db.Users.AnyAsync(d => d.Id == id && d.Role == UserRole.Doctor);
            if (!exists) return NotFound();
            dto.Role = UserRole.Doctor; // ensure role
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Entry(dto).State = EntityState.Modified;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/doctors/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var doctor = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Doctor);
            if (doctor == null) return NotFound();
            _db.Users.Remove(doctor);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
