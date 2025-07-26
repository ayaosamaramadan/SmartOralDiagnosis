using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicalManagement.API.Models;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PatientsController : ControllerBase
    {
        private readonly IPatientService _patientService;

        public PatientsController(IPatientService patientService)
        {
            _patientService = patientService;
        }

        [HttpGet]
        [Authorize(Roles = "admin,doctor")]
        public async Task<ActionResult<List<PatientDto>>> GetAllPatients()
        {
            try
            {
                var patients = await _patientService.GetAllPatientsAsync();
                return Ok(patients);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PatientDto>> GetPatient(string id)
        {
            try
            {
                var patient = await _patientService.GetPatientByIdAsync(id);
                if (patient == null)
                {
                    return NotFound(new { message = "Patient not found" });
                }

                return Ok(patient);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<PatientDto>> CreatePatient([FromBody] Patient patient)
        {
            try
            {
                var result = await _patientService.CreatePatientAsync(patient);
                return CreatedAtAction(nameof(GetPatient), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "admin,patient")]
        public async Task<ActionResult<PatientDto>> UpdatePatient(string id, [FromBody] Patient patient)
        {
            try
            {
                var result = await _patientService.UpdatePatientAsync(id, patient);
                if (result == null)
                {
                    return NotFound(new { message = "Patient not found" });
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
        public async Task<ActionResult> DeletePatient(string id)
        {
            try
            {
                var result = await _patientService.DeletePatientAsync(id);
                if (!result)
                {
                    return NotFound(new { message = "Patient not found" });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("doctor/{doctorId}")]
        [Authorize(Roles = "doctor,admin")]
        public async Task<ActionResult<List<PatientDto>>> GetPatientsByDoctor(string doctorId)
        {
            try
            {
                var patients = await _patientService.GetPatientsByDoctorIdAsync(doctorId);
                return Ok(patients);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }
    }
}
