using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MedicalManagement.API.Models;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MedicalRecordsController : ControllerBase
    {
        private readonly IMedicalRecordService _medicalRecordService;

        public MedicalRecordsController(IMedicalRecordService medicalRecordService)
        {
            _medicalRecordService = medicalRecordService;
        }

        [HttpGet]
        [Authorize(Roles = "admin")]
        public async Task<ActionResult<List<MedicalRecordDto>>> GetAllMedicalRecords()
        {
            try
            {
                var records = await _medicalRecordService.GetAllMedicalRecordsAsync();
                return Ok(records);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<MedicalRecordDto>> GetMedicalRecord(string id)
        {
            try
            {
                var record = await _medicalRecordService.GetMedicalRecordByIdAsync(id);
                if (record == null)
                {
                    return NotFound(new { message = "Medical record not found" });
                }

                return Ok(record);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPost]
        [Authorize(Roles = "doctor")]
        public async Task<ActionResult<MedicalRecordDto>> CreateMedicalRecord([FromBody] MedicalRecord record)
        {
            try
            {
                var result = await _medicalRecordService.CreateMedicalRecordAsync(record);
                return CreatedAtAction(nameof(GetMedicalRecord), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "doctor")]
        public async Task<ActionResult<MedicalRecordDto>> UpdateMedicalRecord(string id, [FromBody] MedicalRecord record)
        {
            try
            {
                var result = await _medicalRecordService.UpdateMedicalRecordAsync(id, record);
                if (result == null)
                {
                    return NotFound(new { message = "Medical record not found" });
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
        public async Task<ActionResult> DeleteMedicalRecord(string id)
        {
            try
            {
                var result = await _medicalRecordService.DeleteMedicalRecordAsync(id);
                if (!result)
                {
                    return NotFound(new { message = "Medical record not found" });
                }

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("patient/{patientId}")]
        public async Task<ActionResult<List<MedicalRecordDto>>> GetMedicalRecordsByPatient(string patientId)
        {
            try
            {
                var records = await _medicalRecordService.GetMedicalRecordsByPatientIdAsync(patientId);
                return Ok(records);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }

        [HttpGet("doctor/{doctorId}")]
        public async Task<ActionResult<List<MedicalRecordDto>>> GetMedicalRecordsByDoctor(string doctorId)
        {
            try
            {
                var records = await _medicalRecordService.GetMedicalRecordsByDoctorIdAsync(doctorId);
                return Ok(records);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
        }
    }
}
