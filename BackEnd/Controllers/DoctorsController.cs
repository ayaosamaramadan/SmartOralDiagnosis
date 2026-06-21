using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Data;
using MedicalManagement.API.Models;
using MedicalManagement.API.DTOs;

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
        public async Task<IActionResult> Update(string id, UpdateUserDto dto)
        {
            var doctor = await _db.Users.FirstOrDefaultAsync(u => u.Id == id && u.Role == UserRole.Doctor);
            if (doctor == null) return NotFound();

            if (dto.FirstName != null) doctor.FirstName = dto.FirstName;
            if (dto.LastName != null) doctor.LastName = dto.LastName;
            if (dto.PhoneNumber != null) doctor.PhoneNumber = dto.PhoneNumber;
            if (dto.Photo != null) doctor.Photo = dto.Photo;
            if (dto.Location != null) doctor.Location = dto.Location;
            if (dto.DateOfBirth != null) doctor.DateOfBirth = dto.DateOfBirth;

            doctor.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return Ok(doctor);
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
