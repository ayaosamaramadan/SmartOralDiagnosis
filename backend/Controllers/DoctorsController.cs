using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicalManagement.API.Models;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DoctorsController : ControllerBase
    {
        private readonly IDoctorService _doctorService;

        public DoctorsController(IDoctorService doctorService)
        {
            _doctorService = doctorService;
        }

        [HttpGet]
        public async Task<ActionResult<List<DoctorDto>>> GetAllDoctors()
        {
            try
            {
                var doctors = await _doctorService.GetAllDoctorsAsync();
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<DoctorDto>> GetDoctor(string id)
        {
            try
            {
                var doctor = await _doctorService.GetDoctorByIdAsync(id);
                if (doctor == null)
                {
                    return NotFound(new { message = "Doctor not found" });
                }

                return Ok(doctor);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<DoctorDto>> CreateDoctor([FromBody] Doctor doctor)
        {
            try
            {
                var result = await _doctorService.CreateDoctorAsync(doctor);
                return CreatedAtAction(nameof(GetDoctor), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "admin,doctor")]
        public async Task<ActionResult<DoctorDto>> UpdateDoctor(string id, [FromBody] Doctor doctor)
        {
            try
            {
                var result = await _doctorService.UpdateDoctorAsync(id, doctor);
                if (result == null)
                {
                    return NotFound(new { message = "Doctor not found" });
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult> DeleteDoctor(string id)
        {
            try
            {
                var result = await _doctorService.DeleteDoctorAsync(id);
                if (!result)
                {
                    return NotFound(new { message = "Doctor not found" });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("specialization/{specialization}")]
        public async Task<ActionResult<List<DoctorDto>>> GetDoctorsBySpecialization(string specialization)
        {
            try
            {
                var doctors = await _doctorService.GetDoctorsBySpecializationAsync(specialization);
                return Ok(doctors);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }
    }
}
