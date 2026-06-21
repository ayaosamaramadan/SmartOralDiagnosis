using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Data;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _db;

        public AdminController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet("dashboard-stats")]
        public async Task<IActionResult> DashboardStats()
        {
            var totalPatients = await _db.Users.CountAsync(u => u.Role == UserRole.Patient);
            var totalDoctors = await _db.Users.CountAsync(u => u.Role == UserRole.Doctor);
            var totalAppointments = await _db.Appointments.CountAsync();
            var totalMedicalRecords = await _db.MedicalRecords.CountAsync();
            var todayAppointments = await _db.Appointments.CountAsync(a => a.AppointmentDate.Date == DateTime.UtcNow.Date);

            return Ok(new {
                totalPatients,
                totalDoctors,
                totalAppointments,
                totalMedicalRecords,
                todayAppointments
            });
        }

        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _db.Users.ToListAsync();
            return Ok(users);
        }

        [HttpPut("users/{userId}/activate")]
        public async Task<IActionResult> ActivateUser(string userId)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user == null) return NotFound();
            user.IsActive = true;
            user.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpPut("users/{userId}/deactivate")]
        public async Task<IActionResult> DeactivateUser(string userId)
        {
            var user = await _db.Users.FindAsync(userId);
            if (user == null) return NotFound();
            user.IsActive = false;
            user.UpdatedAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
