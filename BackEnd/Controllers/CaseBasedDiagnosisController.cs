using Microsoft.AspNetCore.Mvc;
using MedicalManagement.API.DTOs;
using MedicalManagement.API.Services;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/case-based")]
    public class CaseBasedDiagnosisController : ControllerBase
    {
        private readonly CaseSimilarityService _caseService;

        public CaseBasedDiagnosisController(CaseSimilarityService caseService)
        {
            _caseService = caseService;
        }

        [HttpPost("similar")]
        public async Task<ActionResult<CaseSimilarityResponse>> FindSimilar([FromBody] CaseSimilarityRequest request, CancellationToken cancellationToken)
        {
            if (request == null)
            {
                return BadRequest(new { message = "Request body is required" });
            }

            if (string.IsNullOrWhiteSpace(request.Diagnosis) &&
                string.IsNullOrWhiteSpace(request.Description) &&
                string.IsNullOrWhiteSpace(request.Symptoms) &&
                string.IsNullOrWhiteSpace(request.Notes) &&
                string.IsNullOrWhiteSpace(request.Title))
            {
                return BadRequest(new { message = "Provide at least one of: diagnosis, title, description, symptoms, or notes." });
            }

            var result = await _caseService.FindSimilarCasesAsync(request, cancellationToken);
            return Ok(result);
        }
    }
}
