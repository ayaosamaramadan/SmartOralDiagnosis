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
    public class MedicalRecordsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public MedicalRecordsController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetAll()
        {
            return Ok(await _db.MedicalRecords.ToListAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<MedicalRecord>> Get(string id)
        {
            var record = await _db.MedicalRecords.FindAsync(id);
            if (record == null) return NotFound();
            return Ok(record);
        }

        [HttpPost]
        public async Task<ActionResult<MedicalRecord>> Create(MedicalRecord dto)
        {
            dto.CreatedAt = DateTime.UtcNow;
            dto.UpdatedAt = DateTime.UtcNow;
            _db.MedicalRecords.Add(dto);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(Get), new { id = dto.Id }, dto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, MedicalRecord dto)
        {
            if (id != dto.Id) return BadRequest();
            var exists = await _db.MedicalRecords.AnyAsync(m => m.Id == id);
            if (!exists) return NotFound();
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Entry(dto).State = EntityState.Modified;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var record = await _db.MedicalRecords.FindAsync(id);
            if (record == null) return NotFound();
            _db.MedicalRecords.Remove(record);
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetByPatient(string patientId)
        {
            var list = await _db.MedicalRecords.Where(m => m.PatientId == patientId).ToListAsync();
            return Ok(list);
        }

        [HttpGet("doctor/{doctorId}")]
        public async Task<ActionResult<IEnumerable<MedicalRecord>>> GetByDoctor(string doctorId)
        {
            var list = await _db.MedicalRecords.Where(m => m.DoctorId == doctorId).ToListAsync();
            return Ok(list);
        }
    }
}
