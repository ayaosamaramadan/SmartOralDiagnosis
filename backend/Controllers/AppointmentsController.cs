using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicalManagement.API.Models;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AppointmentsController : ControllerBase
    {
        private readonly IAppointmentService _appointmentService;

        public AppointmentsController(IAppointmentService appointmentService)
        {
            _appointmentService = appointmentService;
        }

        [HttpGet]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<List<AppointmentDto>>> GetAllAppointments()
        {
            try
            {
                var appointments = await _appointmentService.GetAllAppointmentsAsync();
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AppointmentDto>> GetAppointment(string id)
        {
            try
            {
                var appointment = await _appointmentService.GetAppointmentByIdAsync(id);
                if (appointment == null)
                {
                    return NotFound(new { message = "Appointment not found" });
                }

                return Ok(appointment);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<AppointmentDto>> CreateAppointment([FromBody] CreateAppointmentRequest request)
        {
            try
            {
                var result = await _appointmentService.CreateAppointmentAsync(request);
                return CreatedAtAction(nameof(GetAppointment), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "admin,doctor")]
        public async Task<ActionResult<AppointmentDto>> UpdateAppointment(string id, [FromBody] Appointment appointment)
        {
            try
            {
                var result = await _appointmentService.UpdateAppointmentAsync(id, appointment);
                if (result == null)
                {
                    return NotFound(new { message = "Appointment not found" });
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "admin,patient")]
        public async Task<ActionResult> DeleteAppointment(string id)
        {
            try
            {
                var result = await _appointmentService.DeleteAppointmentAsync(id);
                if (!result)
                {
                    return NotFound(new { message = "Appointment not found" });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<List<AppointmentDto>>> GetAppointmentsByPatient(string patientId)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByPatientIdAsync(patientId);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("doctor/{doctorId}")]
        public async Task<ActionResult<List<AppointmentDto>>> GetAppointmentsByDoctor(string doctorId)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByDoctorIdAsync(doctorId);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("date/{date}")]
        public async Task<ActionResult<List<AppointmentDto>>> GetAppointmentsByDate(DateTime date)
        {
            try
            {
                var appointments = await _appointmentService.GetAppointmentsByDateAsync(date);
                return Ok(appointments);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }
    }
}
