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
    public class AppointmentsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public AppointmentsController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetAll()
        {
            return Ok(await _db.Appointments.ToListAsync());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Appointment>> Get(string id)
        {
            var appt = await _db.Appointments.FindAsync(id);
            if (appt == null) return NotFound();
            return Ok(appt);
        }

        [HttpPost]
        public async Task<ActionResult<Appointment>> Create(Appointment dto)
        {
            dto.CreatedAt = DateTime.UtcNow;
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Appointments.Add(dto);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(Get), new { id = dto.Id }, dto);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, Appointment dto)
        {
            if (id != dto.Id) return BadRequest();
            var exists = await _db.Appointments.AnyAsync(a => a.Id == id);
            if (!exists) return NotFound();
            dto.UpdatedAt = DateTime.UtcNow;
            _db.Entry(dto).State = EntityState.Modified;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var appt = await _db.Appointments.FindAsync(id);
            if (appt == null) return NotFound();
            _db.Appointments.Remove(appt);
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetByPatient(string patientId)
        {
            var list = await _db.Appointments.Where(a => a.PatientId == patientId).ToListAsync();
            return Ok(list);
        }

        [HttpGet("doctor/{doctorId}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetByDoctor(string doctorId)
        {
            var list = await _db.Appointments.Where(a => a.DoctorId == doctorId).ToListAsync();
            return Ok(list);
        }

        [HttpGet("date/{date}")]
        public async Task<ActionResult<IEnumerable<Appointment>>> GetByDate(string date)
        {
            if (!DateTime.TryParse(date, out var dt)) return BadRequest("Invalid date");
            var list = await _db.Appointments.Where(a => a.AppointmentDate.Date == dt.Date).ToListAsync();
            return Ok(list);
        }
    }
}
