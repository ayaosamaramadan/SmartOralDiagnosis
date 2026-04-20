using MedicalManagement.API.Models;
using MedicalManagement.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MedicalManagement.API.Controllers;

[ApiController]
[Route("api/ai")]
public class AiController : ControllerBase
{
    private readonly AiService _aiService;
    private readonly ILogger<AiController> _logger;

    public AiController(AiService aiService, ILogger<AiController> logger)
    {
        _aiService = aiService;
        _logger = logger;
    }

    [AllowAnonymous]
    [HttpPost("predict")]
    public async Task<IActionResult> Predict([FromBody] AiRequest? request, CancellationToken cancellationToken)
    {
        if (Request.HasFormContentType)
        {
            var form = await Request.ReadFormAsync(cancellationToken);
            var image = form.Files.GetFile("image") ?? form.Files.GetFile("file") ?? form.Files.FirstOrDefault();

            if (image == null || image.Length == 0)
            {
                return BadRequest(new { message = "Image file is required in form field 'image' or 'file'." });
            }

            var imageResult = await _aiService.PredictFromImageAsync(image, cancellationToken);
            if (!imageResult.IsSuccess)
            {
                _logger.LogWarning("AI image predict failed with status {StatusCode}: {ErrorMessage}", imageResult.StatusCode, imageResult.ErrorMessage);
                return StatusCode(imageResult.StatusCode, new { message = imageResult.ErrorMessage });
            }

            return Ok(imageResult.Data);
        }

        if (request == null || string.IsNullOrWhiteSpace(request.Text))
        {
            return BadRequest(new { message = "The 'text' field is required." });
        }

        var result = await _aiService.PredictAsync(request, cancellationToken);
        if (!result.IsSuccess)
        {
            _logger.LogWarning("AI predict failed with status {StatusCode}: {ErrorMessage}", result.StatusCode, result.ErrorMessage);
            return StatusCode(result.StatusCode, new { message = result.ErrorMessage });
        }

        return Ok(result.Data);
    }
}
